/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			mapvote.sp
 *  Type:			Module
 *  Description:	Handles map vote on finale map.
 *
 *  Copyright (C) 2010  Mr. Zero <mrzerodk@gmail.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

// --------------------
//       Public
// --------------------

#define					MAX_MAP_VOTES 32

// --------------------
//       Private
// --------------------

static	const	bool:	IS_MAP_VOTE_ENABLED				= false;

static			bool:	g_bIsKeyFileLoaded				= false;
static			Handle:	g_hMapTrie 						= INVALID_HANDLE; // Trie to hold map info
static			Handle:	g_hMapArray 					= INVALID_HANDLE; // Array to hold trie info (making the trie iterateable)

static					g_iClientVote[MAXPLAYERS+1] 	= {-1};
static					g_iCampaignVotes[MAX_MAP_VOTES] = {0};
static					g_iNextCampaign 				= 0; // Next campaign to play
static					g_iPreviousCampaign				= -1;
static			Handle:	g_hVotePanel 					= INVALID_HANDLE;
static			Handle:	g_hVoteArray					= INVALID_HANDLE;

static			bool:	g_bIsFinaleMap					= false;
static			bool:	g_bIsFirstRound 				= false;
static			bool:	g_bPreventRoundEndDupe 			= false;

static			bool:	g_bCanVoteForCurrentCampaign 	= false; // Whether or not clients can vote for the current campaign they are playing
static			bool:	g_bCanVoteForLastCampaign		= false; // Whether or not clients can vote for the last campaign they played before

static					g_iExtraVoteTime				= 20; // How many extra seconds players get to vote before ready up ends
static	const			MAP_VOTE_ANNOUNCE_TIME 			= 5; // Time before showing the vote, annoucing the vote will start soon
static	const	Float:	CHANGE_MAP_TIME					= 10.0; // Time after round end, we change map

static	const	String:	DESCRIPTION_SPACER[] 			= "    "; // Spacer for the vote panel descriptions (making them indent)

#if defined DEBUG
static			bool:	g_bDebug_ThisIsATestVote 		= false;
#endif

// **********************************************
//					  Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _MapVote_OnPluginStart()
{
	if (!IS_MAP_VOTE_ENABLED) return;
	g_hMapTrie = CreateTrie();
	g_hMapArray = CreateArray(128);

	decl String:path[256];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s/mapvote.cfg", PLUGIN_SHORTNAME);
	if (!LoadMapVoteKeyFile(path, g_hMapTrie, g_hMapArray))
	{
		LogMessage("Unable to find or open \"%s\" for map vote module. Module disabled until plugin is reloaded", path);
		CloseHandle(g_hMapTrie);
		CloseHandle(g_hMapArray);
		return;
	}
	g_bIsKeyFileLoaded = true;

	HookReadyUpEvent(READYUP_EVENT_ABOUTTOEND, _MV_OnReadyUpAboutToEnd);
	HookReadyUpEvent(READYUP_EVENT_END, _MV_OnReadyUpEnd);
	HookEvent("round_end", _MV_RoundEnd_Event, EventHookMode_PostNoCopy);

#if defined DEBUG
	RegAdminCmdEx("debug_campaignvote", _MV_TestVote_Command, ADMFLAG_ROOT, "Runs a test vote for campaigns to see the constructed menu and voting process");
	RegAdminCmdEx("debug_revote", _MV_Revote_Command, ADMFLAG_ROOT, "Resets your campaign vote");
#endif
}

/**
 * On ready up about to end.
 *
 * @noreturn
 */
public _MV_OnReadyUpAboutToEnd()
{
	if (!IS_MAP_VOTE_ENABLED) return;
	if (!g_bIsFinaleMap || g_bIsFirstRound) return;
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, MAP_VOTE_ANNOUNCE_TIME);
	CreateTimer(1.0, _MV_VoteCommencing_Timer, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE |TIMER_DATA_HNDL_CLOSE);
}

/**
 * On ready up end.
 *
 * @noreturn
 */
public _MV_OnReadyUpEnd()
{
	if (!IS_MAP_VOTE_ENABLED) return;
#if !defined DEBUG
	if (!g_bIsFinaleMap || g_bIsFirstRound) return;
#else
	if (!g_bIsFinaleMap || (!g_bDebug_ThisIsATestVote && g_bIsFirstRound)) return;
#endif
	EndCampaignVoting();
}

/**
 * On map start.
 *
 * @noreturn
 */
public _MapVote_OnMapStart()
{
	if (!IS_MAP_VOTE_ENABLED) return;
	g_iNextCampaign = -1;
	g_bIsFinaleMap = false;
	if (!g_bIsKeyFileLoaded) return;
	if (GetCampaignIndexFromCurrentMap() != -1) g_bIsFinaleMap = true;
}

/**
 * On map end.
 *
 * @noreturn
 */
public _MapVote_OnMapEnd()
{
	if (!IS_MAP_VOTE_ENABLED) return;
	g_bIsFirstRound = true;
	g_bPreventRoundEndDupe = false;
}

/**
 * On client disconnect.
 *
 * @param client		Client index.
 * @noreturn
 */
public _MapVote_OnClientDisconnect(client)
{
	if (!IS_MAP_VOTE_ENABLED) return;
	g_iClientVote[client] = -1;
}

/**
 * Called when round end event is fired.
 *
 * @param event			INVALID_HANDLE, post no copy data.
 * @param name			String containing the name of the event.
 * @param dontBroadcast	True if event was not broadcast to clients, false otherwise.
 * @noreturn
 */
public _MV_RoundEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IS_MAP_VOTE_ENABLED) return;
	if (g_bPreventRoundEndDupe)
	{
#if defined DEBUG
		PrintToChatAll("Prevented dupe round end");
#endif
		g_bPreventRoundEndDupe = false;
		return;
	}
	g_bPreventRoundEndDupe = true;

	if (g_bIsFirstRound)
	{
		g_bIsFirstRound = false;
		return;
	}

	if (g_iNextCampaign == -1) return;
	decl String:intro[128];
	GetCampaignIntroFromIndex(g_iNextCampaign, intro, sizeof(intro));
	new Handle:pack = CreateDataPack();
	WritePackString(pack, intro);
	CreateTimer(CHANGE_MAP_TIME, _MV_ChangeLevel_Timer, pack, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
	CreateTimer(1.0, _MV_PrintChangingCampaign_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * Called when print changing campaign interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_MV_PrintChangingCampaign_Timer(Handle:timer)
{
	new String:title[128];
	GetCampaignTitleFromIndex(g_iNextCampaign, title, sizeof(title));
	PrintToChatAll("\x01* Changing campaign to \x05%s\x01...", title);
}

/**
 * Called when vote commencing print interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop to stop a repeating timer, any other value for
 *						default behavior.
 */
public Action:_MV_VoteCommencing_Timer(Handle:timer, any:pack)
{
	ResetPack(pack);
	new countdown = ReadPackCell(pack);
	if (countdown < 1)
	{
		StartCampaignVoting();
		AddTimeToReadyUp(g_iExtraVoteTime);
		return Plugin_Stop;
	}
	PrintHintTextToAll("Campaign vote will commence in %i second%s!", countdown, (countdown > 1 ? "s" : ""));
	countdown--;
	ResetPack(pack, true);
	WritePackCell(pack, countdown);
	return Plugin_Continue;
}

/**
 * Called when show votes interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop to stop a repeating timer, any other value for
 *						default behavior.
 */
public Action:_MV_ShowVotes_Timer(Handle:timer)
{
	if (!InReadyUpMode()) return Plugin_Stop;
	UpdateVotes();

	decl top3Array[3];
	GetTop3CampaignIndexVotes(top3Array);
	new humanCount = GetClientCountEx(true, true);
	new String:title[128], campaignVotes;
	decl String:buffer[1024];
	Format(buffer, sizeof(buffer), "");
	for (new i = 0; i < 3; i++)
	{
		GetCampaignTitleFromIndex(top3Array[i], title, sizeof(title));
		campaignVotes = GetCampaignVotesFromIndex(top3Array[i]);
		Format(buffer, sizeof(buffer), "%s%s%i. %s: %i/%i", buffer, (i != 0 ? "\n" : ""), i + 1, title, campaignVotes, humanCount);
	}

	PrintHintTextToAll(buffer);

	return Plugin_Continue;
}

/**
 * Called when send panels interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop to stop a repeating timer, any other value for
 *						default behavior.
 */
public Action:_MV_SendPanel_Timer(Handle:timer)
{
	if (!InReadyUpMode()) return Plugin_Stop;

	for (new client = FIRST_CLIENT; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client) || g_iClientVote[client] != -1) continue;
		SendPanelToClient(g_hVotePanel, client, _MV_VotePanelHandler, 1);
	}

	return Plugin_Continue;
}

/**
 * Called when a menu action for vote panel is completed.
 *
 * @param menu				The menu being acted upon.
 * @param action			The action of the menu.
 * @param param1			First action parameter (usually the client).
 * @param param2			Second action parameter (usually the item).
 * @noreturn
 */
public _MV_VotePanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select && InReadyUpMode())
	{
		decl String:campaign[128];
		GetArrayString(g_hVoteArray, param2 - 1, campaign, sizeof(campaign));
		g_iClientVote[param1] = GetCampaignIndexFromName(campaign);
#if defined DEBUG
		PrintToChatAll("client %i: \"%N\" picked option %i (\"%s\")", param1, param1, param2, campaign);
#endif
	}
}

/**
 * Called when send panels interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @param pack			Handle to pack.
 * @noreturn
 */
public Action:_MV_ChangeLevel_Timer(Handle:timer, any:pack)
{
	decl String:buffer[128];
	ResetPack(pack);
	ReadPackString(pack, buffer, sizeof(buffer));
	ServerCommand("changelevel %s", buffer);
}

#if defined DEBUG
public Action:_MV_TestVote_Command(client, args)
{
	g_bDebug_ThisIsATestVote = true;
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, MAP_VOTE_ANNOUNCE_TIME);
	CreateTimer(1.0, _MV_VoteCommencing_Timer, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
	PrintToChat(client, "Testing campaign voting");
	return Plugin_Handled;
}

public Action:_MV_Revote_Command(client, args)
{
	g_iClientVote[client] = -1;
	PrintToChat(client, "Reset vote");
	return Plugin_Handled;
}
#endif

// **********************************************
//                 Private API
// **********************************************

/**
 * Starts initializing campaign voting and send it out to clients.
 *
 * @noreturn 
 */
static StartCampaignVoting()
{
	for (new i = FIRST_CLIENT; i <= MaxClients; i++) g_iClientVote[i] = -1;
	for (new i = 0; i < MAX_MAP_VOTES; i++) g_iCampaignVotes[i] = 0;

	_MV_ShowVotes_Timer(INVALID_HANDLE);
	CreateTimer(1.0, _MV_ShowVotes_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	if (g_hVotePanel != INVALID_HANDLE)
	{
		CloseHandle(g_hVotePanel);
		g_hVotePanel = INVALID_HANDLE;
	}
	g_hVotePanel = ConstructMapVotePanel();

	_MV_SendPanel_Timer(INVALID_HANDLE);
	CreateTimer(1.0, _MV_SendPanel_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * Ends campaign voting and sets next campaign.
 *
 * @noreturn 
 */
static EndCampaignVoting()
{
	if (g_hVotePanel != INVALID_HANDLE)
	{
		CloseHandle(g_hVotePanel);
		g_hVotePanel = INVALID_HANDLE;
	}
	if (g_hVoteArray != INVALID_HANDLE)
	{
		CloseHandle(g_hVoteArray);
		g_hVoteArray = INVALID_HANDLE;
	}
	UpdateVotes();
	new campaignIndex = GetWinningCampaignIndex();

#if defined DEBUG
	if (!g_bDebug_ThisIsATestVote)
	{
		g_iPreviousCampaign = GetCampaignIndexFromCurrentMap();
		g_iNextCampaign = campaignIndex;
	}
	g_bDebug_ThisIsATestVote = false;
#else
	g_iPreviousCampaign = GetCampaignIndexFromCurrentMap();
	g_iNextCampaign = campaignIndex;
#endif

	new String:title[128];
	GetCampaignTitleFromIndex(campaignIndex, title, sizeof(title));
	new campaignVotes = GetCampaignVotesFromIndex(campaignIndex);
	new totalVotes = GetTotalVoters();

	if (totalVotes > 0)
	{
		PrintToChatAll("\x01* Next campaign: \x05%s\x01 (Won by %i out of %i vote%s)", title, campaignVotes, totalVotes, (totalVotes > 1 ? "s" : ""));
	}
	else
	{
		PrintToChatAll("\x01* Next campaign: \x05%s\x01", title);
	}
}

/**
 * Updates the global campaign votes variable with the client votes.
 *
 * @noreturn 
 */
static UpdateVotes()
{
	for (new i = 0; i < MAX_MAP_VOTES; i++) g_iCampaignVotes[i] = 0;
	decl clientVote;
	for (new i = FIRST_CLIENT; i <= MaxClients; i++)
	{
		clientVote = g_iClientVote[i];
		if (clientVote == -1) continue;
		g_iCampaignVotes[clientVote]++;
	}
}

/**
 * Counts how many people voted.
 *
 * @return				How many people voted.
 */
static GetTotalVoters()
{
	new counter = 0;
	for (new i = FIRST_CLIENT; i <= MaxClients; i++)
	{
		if (g_iClientVote[i] != -1) counter++;
	}
	return counter;
}

/**
 * Gets the current number 1 campaign index.
 *
 * @return				Campaign index, or -1 on error.
 */
static GetWinningCampaignIndex()
{
	new top3Array[3] = {-1};
	GetTop3CampaignIndexVotes(top3Array);
	return top3Array[0];
}

/**
 * Get top 3 winning campaign indexes.
 *
 * @param top3array		A 3 dimension int array to copy to.
 * @noreturn
 */
static GetTop3CampaignIndexVotes(top3array[3])
{
	new arraySize = GetArraySize(g_hMapArray);
	new curIndex = GetCampaignIndexFromCurrentMap();
	new lastIndex = g_iPreviousCampaign;

	/* Add all maps to array for sorting campaign votes */
	new Handle:array = CreateArray();
	for (new i = 0; i < arraySize; i++)
	{
		if (i == curIndex && !g_bCanVoteForCurrentCampaign ||
			(i == lastIndex && !g_bCanVoteForLastCampaign)) 
			continue;
		PushArrayCell(array, g_iCampaignVotes[i]);
	}
	SortADTArray(array, Sort_Descending, Sort_Integer); // Sort array with most votes in top
	ResizeArray(array, 3); // Resize the array to 3 to get top 3

	/* Find campaigns with matching votes */
	decl votes;
	new bool:usedIndexes[arraySize]; // Used to prevent dupes of the same campaign
	new bool:foundCampaign = false; // Used to prevent 2nd loop (if current campaign index bigger than 0) from running
	for (new i = 0; i < 3; i++)
	{
		votes = GetArrayCell(array, i);
		foundCampaign = false;
		for (new j = curIndex; j < arraySize; j++)
		{
			if (votes != g_iCampaignVotes[j] || // If votes not equal what is voted for this campaign
				(j == curIndex && !g_bCanVoteForCurrentCampaign) || // or the index is the current index and you can't vote for that
				(j == lastIndex && !g_bCanVoteForLastCampaign) || // or the index is the last index and you can't vote for that
				usedIndexes[j]) // Or its a index that is already used
				continue;
			top3array[i] = j;
			usedIndexes[j] = true;
			foundCampaign = true;
			break;
		}
		if (foundCampaign || curIndex <= 0) continue; // If we did find the campaign with matching votes or current index is less or equal to 0, continue
		for (new j = 0; j < curIndex; j++)
		{
			if (votes != g_iCampaignVotes[j] ||
				(j == lastIndex && !g_bCanVoteForLastCampaign) ||
				usedIndexes[j])
				continue;
			top3array[i] = j;
			usedIndexes[j] = true;
			break;
		}
	}
	CloseHandle(array);
}

/**
 * Gets campaign index's votes.
 *
 * @param index			Index of campaign.
 * @return				How many have voted for this campaign index.
 */
static GetCampaignVotesFromIndex(index)
{
	if (index < 0 || index >= MAX_MAP_VOTES) return 0;
	return g_iCampaignVotes[index];
}

/**
 * Gets campaigns title from index.
 *
 * @param index			Index of campaign.
 * @param dest			Destination string buffer to copy to.
 * @param destLen		Destination buffer length (includes null terminator).
 * @return				True if able to get it, false otherwise.
 */
static bool:GetCampaignTitleFromIndex(index, String:dest[], destLen)
{
	if (index < 0 || index >= GetArraySize(g_hMapArray)) return false;
	decl String:campaign[128], String:key[160];
	GetArrayString(g_hMapArray, index, campaign, sizeof(campaign));
	Format(key, sizeof(key), "%s_title", campaign);
	return bool:GetTrieString(g_hMapTrie, key, dest, destLen);
}

/**
 * Gets campaigns index from map name.
 *
 * @param name			Map name of campaign.
 * @return				Campaign index, or -1 if not found.
 */
static GetCampaignIndexFromName(const String:name[])
{
	decl String:campaign[128];
	new arraySize = GetArraySize(g_hMapArray);
	for (new i = 0; i < arraySize; i++)
	{
		GetArrayString(g_hMapArray, i, campaign, sizeof(campaign));
		if (StrEqual(campaign, name)) return i;
	}
	return -1;
}

/**
 * Get campaigns intro map from index.
 *
 * @param index			Index of campaign.
 * @param dest			Destination string buffer to copy to.
 * @param destLen		Destination buffer length (includes null terminator).
 * @return				True if found, false otherwise.
 */
static bool:GetCampaignIntroFromIndex(index, String:dest[], destLen)
{
	if (index < 0 || index >= GetArraySize(g_hMapArray)) return false;
	decl String:campaign[128], String:key[160];
	GetArrayString(g_hMapArray, index, campaign, sizeof(campaign));
	Format(key, sizeof(key), "%s_intro", campaign);
	return bool:GetTrieString(g_hMapTrie, key, dest, destLen);
}

/**
 * Get campaigns index from the current map.
 *
 * @return				Campaign index, or -1 if not found.
 */
static GetCampaignIndexFromCurrentMap()
{
	decl String:map[128], String:campaign[128];
	GetCurrentMap(map, sizeof(map));
	if (GetTrieString(g_hMapTrie, map, campaign, sizeof(campaign)))
	{
		return GetCampaignIndexFromName(campaign);
	}
	return -1;
}

/**
 * Constructs the map vote panel.
 *
 * @return				Handle to panel, invalid handle if could not be constructed.
 */
static Handle:ConstructMapVotePanel()
{
	new Handle:trie = g_hMapTrie, Handle:array = g_hMapArray;
	new Handle:panel = CreatePanel(INVALID_HANDLE);
	g_hVoteArray = CreateArray(128);

	SetPanelTitle(panel, "Vote for the next campaign!");

	new arraySize = GetArraySize(array);
	decl String:campaign[128], String:title[128], String:key[160], String:desc[128];
	new curCampaignIndex = GetCampaignIndexFromCurrentMap();
	new lastCampaignIndex = g_iPreviousCampaign;
	for (new i = 0; i < arraySize; i++)
	{
		if (i == curCampaignIndex && !g_bCanVoteForCurrentCampaign) continue;
		if (i == lastCampaignIndex && !g_bCanVoteForLastCampaign) continue;

		GetArrayString(array, i, campaign, sizeof(campaign));
		Format(key, sizeof(key), "%s_title", campaign);
		GetTrieString(trie, key, title, sizeof(title));
		DrawPanelItem(panel, title);

		Format(key, sizeof(key), "%s_desc", campaign);
		if (GetTrieString(trie, key, desc, sizeof(desc)))
		{
			Format(desc, sizeof(desc), "%s%s", DESCRIPTION_SPACER, desc);
			DrawPanelText(panel, desc);
		}
		PushArrayString(g_hVoteArray, campaign);
	}

	return panel;
}

/**
 * Loads the map voteing keyfile into a trie and array.
 *
 * @param path			Path to the map voteing keyfile.
 * @param trie			Handle to trie to copy to.
 * @param array			Handle to array to copy to.
 * @return				True if copied, false otherwise.
 */
static bool:LoadMapVoteKeyFile(const String:path[], &Handle:trie, &Handle:array)
{
	if (!FileExists(path))
	{
		return false;
	}

	new String:name[] = PLUGIN_FULLNAME;
	new Handle:kv = CreateKeyValues(name);
	if (!FileToKeyValues(kv, path)) 
	{
		CloseHandle(kv);
		return false;
	}

	if (!KvGotoFirstSubKey(kv, true)) 
	{
		CloseHandle(kv);
		return true;
	}

	ClearTrie(trie);
	ClearArray(array);

	decl String:campaign[128], String:intro[128], String:finale[128], String:title[128], String:desc[128], String:key[160];
	new counter = 0;
	do
	{
		counter++;
		if (!KvGetSectionName(kv, campaign, sizeof(campaign)))
		{
			LogMessage("Error on phasing mapvote keyfile: Failed to get campaign name! (counter %i)", campaign, counter);
			continue;
		}

		KvGetString(kv, "intro", intro, sizeof(intro));
		if (strlen(intro) == 0 || !IsMapValid(intro))
		{
			LogMessage("Error on phasing mapvote keyfile: Unable to find intro map for \"%s\" campaign!", campaign);
			continue;
		}

		KvGetString(kv, "finale", finale, sizeof(finale));
		if (strlen(finale) == 0 || !IsMapValid(finale))
		{
			LogMessage("Error on phasing mapvote keyfile: Unable to find finale map for \"%s\" campaign!", campaign);
			continue;
		}

		KvGetString(kv, "title", title, sizeof(title));
		if (strlen(title) == 0)
		{
			LogMessage("Error on phasing mapvote keyfile: Unable to find title for \"%s\" campaign!", campaign);
			continue;
		}

		KvGetString(kv, "desc", desc, sizeof(desc));
		if (strlen(desc) != 0)
		{
			Format(key, sizeof(key), "%s_desc", campaign);
			SetTrieString(trie, key, desc);
		}

		Format(key, sizeof(key), "%s_intro", campaign);
		SetTrieString(trie, key, intro);

		Format(key, sizeof(key), "%s_finale", campaign);
		SetTrieString(trie, key, finale);
		SetTrieString(trie, finale, campaign);

		Format(key, sizeof(key), "%s_title", campaign);
		SetTrieString(trie, key, title);

		PushArrayString(array, campaign);

		LogMessage("Added follow campaign to map vote: \"%s\", intro; \"%s\", finale; \"%s\"", title, intro, finale);
	}
	while (KvGotoNextKey(kv));

	CloseHandle(kv);
	return true;
}