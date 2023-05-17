/*
 * MyJailbreak - Player Tags Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Hexer10
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors>
#include <autoexecconfig>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#include <chat-processor>
#include <ccc>
#include <togsclantags>
#include <warden>
#include <myjbwarden>

#tryinclude <scp>
#if !defined _scp_included
#include <cp-scp-wrapper>
#endif
#define REQUIRE_PLUGIN


// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;
bool gp_bChatProcessor = false;
bool gp_bCCC = false;
bool gp_bTOGsTags = false;
bool gp_bMyJBWarden = false;
bool gp_bWarden = false;
bool g_bIncognito[MAXPLAYERS + 1] = false;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_sCustomCommand;
ConVar gc_bStats;
ConVar gc_bChat;
ConVar gc_bExtern;
ConVar gc_bNoOverwrite;
ConVar gc_bJoinIncognito;
ConVar gc_fIncognitoTime;

// Enum
enum struct Roles
{
	char SPECTATOR[64];
	char GUARD[64];
	char DEPUTY[64];
	char WARDEN[64];
	char PRISONER[64];
}

Roles g_sChatTag[MAXPLAYERS + 1];
Roles g_sStatsTag[MAXPLAYERS + 1];

// Strings
char g_sConfigFile[64];
char g_sPlayerTag[MAXPLAYERS + 1][64];
char g_sPrefix[64];

Handle g_hIncognitoTimer[MAXPLAYERS + 1] = null;

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - PlayerTags",
	description = "Define player tags in chat & stats for Jailbreak Server",
	author = "shanapu",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.PlayerTags.phrases");

	// Client commands
	RegAdminCmd("sm_incognito", Command_Incognito, ADMFLAG_RESERVATION, "Allows admin to toggle incognito - show default tags instead of admin tags");

	// AutoExecConfig
	AutoExecConfig_SetFile("PlayerTags", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_playertag_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_playertag_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_playertag_prefix", "[{green}MyJB.Tag{default}]", "Set your chat prefix for this plugin.");
	gc_bStats = AutoExecConfig_CreateConVar("sm_playertag_stats", "1", "0 - disabled, 1 - enable PlayerTag in stats", _, true, 0.0, true, 1.0);
	gc_bChat = AutoExecConfig_CreateConVar("sm_playertag_chat", "1", "0 - disabled, 1 - enable PlayerTag in chat", _, true, 0.0, true, 1.0);
	gc_bExtern = AutoExecConfig_CreateConVar("sm_playertag_extern", "1", "0 - disabled, 1 - don't overwrite chat tags given by extern plugins ccc, togsclantags or zephyrus store", _, true, 0.0, true, 1.0);
	gc_bNoOverwrite = AutoExecConfig_CreateConVar("sm_playertag_overwrite", "1", "0 - if no tag is set in config clear the tag (show nothing) / 1 - if no tag is set in config show players steam group tag", _, true, 0.0, true, 1.0);
	gc_bJoinIncognito = AutoExecConfig_CreateConVar("sm_playertag_incognito_join", "1", "0 - admins & VIP will recieve their tags right after join / 1 - admins & VIP will join incognito without admin tags.", _, true, 0.0, true, 1.0);
	gc_fIncognitoTime = AutoExecConfig_CreateConVar("sm_playertag_incognito_time", "120", "seconds how long admins stay incognito - 0 - disabled, you have to !incognito to enable", _, true, 0.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_playertag_cmds", "undercover, incog", "Set your custom chat commands for toggle incognito mode(!incognito (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	HookEvent("player_team", Event_CheckTag);

	HookConVarChange(gc_sPrefix, OnSettingChanged);

	BuildPath(Path_SM, g_sConfigFile, sizeof(g_sConfigFile), "configs/MyJailbreak/player_tags.cfg");

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			OnClientPostAdminCheck(i);
		}

		g_bIsLateLoad = false;
	}
}

// Check for supported plugins
public void OnAllPluginsLoaded()
{
	gp_bChatProcessor = LibraryExists("chat-processor");
	gp_bCCC = LibraryExists("ccc");
	gp_bTOGsTags = LibraryExists("togsclantags");
	gp_bWarden = LibraryExists("warden");
	gp_bMyJBWarden = LibraryExists("myjbwarden");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "chat-processor"))
	{
		gp_bChatProcessor = false;
	}
	else if (StrEqual(name, "ccc"))
	{
		gp_bCCC = false;
	}
	else if (StrEqual(name, "togsclantags"))
	{
		gp_bTOGsTags = false;
	}
	else if (StrEqual(name, "warden"))
	{
		gp_bWarden = false;
	}
	else if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "chat-processor"))
	{
		gp_bChatProcessor = true;
	}
	else if (StrEqual(name, "ccc"))
	{
		gp_bCCC = true;
	}
	else if (StrEqual(name, "togsclantags"))
	{
		gp_bTOGsTags = true;
	}
	else if (StrEqual(name, "warden"))
	{
		gp_bWarden = true;
	}
	else if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = true;
	}
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sPrefix)
	{
		strcopy(g_sPrefix, sizeof(g_sPrefix), newValue);
	}
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	gc_sCustomCommand.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegAdminCmd(sCommand,  Command_Incognito, ADMFLAG_RESERVATION, "Allows admin to toggle incognito - show default tags instead of admin tags");
		}
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_Incognito(int client, int args)
{
	if (!IsValidClient(client, false, true))
		return Plugin_Handled;

	if(g_bIncognito[client] && args == 0)
	{
		g_bIncognito[client] = false;

		if (g_hIncognitoTimer[client] != INVALID_HANDLE)
		{
			KillTimer(g_hIncognitoTimer[client]);
			g_hIncognitoTimer[client] = INVALID_HANDLE;
		}

		CReplyToCommand(client, "%s %t", g_sPrefix, "playertags_incognito_off");
	}
	else
	{
		g_bIncognito[client] = true;

		float fIncognitoTime = gc_fIncognitoTime.FloatValue;

		if (args != 0) // given time parameters
		{
			char sArgs[10];
			GetCmdArg(1, sArgs, sizeof(sArgs));
			fIncognitoTime = StringToFloat(sArgs);
		}
		
		if (g_hIncognitoTimer[client] != null)
		{
			delete g_hIncognitoTimer[client];
		}

		if (fIncognitoTime > 0)
		{
			g_hIncognitoTimer[client] = CreateTimer(fIncognitoTime, Timer_Incognito, GetClientUserId(client));

			CReplyToCommand(client, "%s %t", g_sPrefix, "playertags_incognito_on", fIncognitoTime);
		}
		else
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "playertags_incognito_on_perm", fIncognitoTime);
		}
	}

	// Search for matching tag in cfg
	LoadPlayerTags(client);

	// Apply tag first time
	HandleTag(client);

	return Plugin_Handled;
}


/****************************************************************************** 
                   EVENTS 
******************************************************************************/ 

//Thanks to https://forums.alliedmods.net/showpost.php?p=2573907&postcount=6
public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	char sKey[64];

	if (!kv.GetSectionName(sKey, sizeof(sKey)))
		return Plugin_Continue;

	if (StrEqual(sKey, "ClanTagChanged"))
	{
		RequestFrame(Frame_HandleTag, GetClientUserId(client));
	}

	return Plugin_Continue;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void OnClientPostAdminCheck(int client)
{
	CS_GetClientClanTag(client, g_sPlayerTag[client], sizeof(g_sPlayerTag[]));

	if (gc_bJoinIncognito.BoolValue)
	{
		g_bIncognito[client] = true;

		if (gc_fIncognitoTime.FloatValue > 0)
		{
			g_hIncognitoTimer[client] = CreateTimer(gc_fIncognitoTime.FloatValue, Timer_Incognito, GetClientUserId(client));
		}
	}

	// Search for matching tag in cfg
	LoadPlayerTags(client);

	// Apply tag first time
	HandleTag(client);
}

public Action Timer_Incognito(Handle tmr, int userid)
{
	int client = GetClientOfUserId(userid);

	g_bIncognito[client] = false;

	LoadPlayerTags(client);

	// Apply tag first time
	HandleTag(client);

	//CPrintToChat(client, "%s %t", g_sPrefix, "playertags_incognito_off");

	g_hIncognitoTimer[client] = null;

	return Plugin_Handled;
}

public void Event_CheckTag(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	HandleTag(client);
}

public void warden_OnWardenCreated(int client)
{
	HandleTag(client);
}

public void warden_OnWardenRemoved(int client)
{
	RequestFrame(Frame_HandleTag, GetClientUserId(client));
}

public void warden_OnDeputyCreated(int client)
{
	HandleTag(client);
}

public void warden_OnDeputyRemoved(int client)
{
	RequestFrame(Frame_HandleTag, GetClientUserId(client));
}

public void OnClientDisconnect(int client)
{
	if (g_hIncognitoTimer[client] != null)
	{
		delete g_hIncognitoTimer[client];
	}
}
/****************************************************************************** 
                   FRAME 
******************************************************************************/

public void Frame_HandleTag(int userid)
{
	int client = GetClientOfUserId(userid);
	
	if (!client)
		return;

	HandleTag(client);
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void LoadPlayerTags(int client)
{
	File hFile = OpenFile(g_sConfigFile, "rt");

	if (hFile == null)
	{
		delete hFile;
		SetFailState("MyJailbreak PlayerTags - Can't open File: %s", g_sConfigFile);
	}
	delete hFile;

	delete hFile;

	KeyValues kvMenu = new KeyValues("PlayerTags");

	if (!kvMenu.ImportFromFile(g_sConfigFile))
	{
		delete kvMenu;
		SetFailState("MyJailbreak PlayerTags - Can't read %s correctly! (ImportFromFile)", g_sConfigFile);
	}

	char steamid[24];
	if (!GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid)))
	{
		LogError("COULDN'T GET STEAMID of %L", client);

		if (kvMenu.JumpToKey("default", false))
		{
			GetTags(client, kvMenu);

			delete kvMenu;
			return;
		}
	}

	// incognito -> use the default tags
	if(g_bIncognito[client])
	{
		if (kvMenu.JumpToKey("default", false))
		{
			GetTags(client, kvMenu);

			delete kvMenu;
			return;
		}
	}

	// Check SteamID
	if (kvMenu.JumpToKey(steamid, false))
	{
		GetTags(client, kvMenu);

		delete kvMenu;
		return;
	}

	// Check SteamID again with bad steam universe
	steamid[6] = '0';

	if (kvMenu.JumpToKey(steamid, false))
	{
		GetTags(client, kvMenu);

		delete kvMenu;
		return;
	}

	// Check groups
	AdminId admin = GetUserAdmin(client);
	if (admin != INVALID_ADMIN_ID)
	{
		char sGroup[32];
		admin.GetGroup(0, sGroup, sizeof(sGroup));
		Format(sGroup, sizeof(sGroup), "@%s", sGroup);
		
		if (kvMenu.JumpToKey(sGroup))
		{
			GetTags(client, kvMenu);

			delete kvMenu;
			return;
		}
	}

	// Check flags
	char sFlags[21] = "abcdefghijklmnopqrstz";

	// backwards loop
	for (int i = sizeof(sFlags) - 1; i >= 0; i--)
	{
		char sFlag[1];
		sFlag[0] = sFlags[i]; //Get only one char
		
		if (ReadFlagString(sFlag) & GetUserFlagBits(client))
		{
			if (kvMenu.JumpToKey(sFlag))
			{
				GetTags(client, kvMenu);

				delete kvMenu;
				return;
			}
		}
	}

	// use the default tags
	if (kvMenu.JumpToKey("default", false))
	{
		GetTags(client, kvMenu);
	}

	delete kvMenu;
}

void GetTags(int client, KeyValues kvMenu)
{
	kvMenu.GetString("spectator", g_sStatsTag[client].SPECTATOR, sizeof(Roles::SPECTATOR), "");
	kvMenu.GetString("warden", g_sStatsTag[client].WARDEN, sizeof(Roles::WARDEN), "");
	kvMenu.GetString("deputy", g_sStatsTag[client].DEPUTY, sizeof(Roles::DEPUTY), "");
	kvMenu.GetString("guard", g_sStatsTag[client].GUARD, sizeof(Roles::GUARD), "");
	kvMenu.GetString("prisoner", g_sStatsTag[client].PRISONER, sizeof(Roles::PRISONER), "");

	kvMenu.GetString("spectator_chat", g_sChatTag[client].SPECTATOR, sizeof(Roles::SPECTATOR), "");
	kvMenu.GetString("warden_chat", g_sChatTag[client].WARDEN, sizeof(Roles::WARDEN), "");
	kvMenu.GetString("deputy_chat", g_sChatTag[client].DEPUTY, sizeof(Roles::DEPUTY), "");
	kvMenu.GetString("guard_chat", g_sChatTag[client].GUARD, sizeof(Roles::GUARD), "");
	kvMenu.GetString("prisoner_chat", g_sChatTag[client].PRISONER, sizeof(Roles::PRISONER), "");
}

// Give Tag
void HandleTag(int client)
{
	if (!gc_bPlugin.BoolValue)
		return;

	if (!gc_bStats.BoolValue || !IsValidClient(client, true, true))
		return;

	if (gp_bTOGsTags && !gc_bExtern.BoolValue)
	{
		if (TOGsClanTags_HasAnyTag(client))
			return;
	}

	if (GetClientTeam(client) == CS_TEAM_T)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client].PRISONER) < 1)
		{
			CS_SetClientClanTag(client, g_sPlayerTag[client]);
		}
		else
		{
			CS_SetClientClanTag(client, g_sStatsTag[client].PRISONER);
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (gp_bWarden && warden_iswarden(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client].WARDEN) < 1)
			{
				CS_SetClientClanTag(client, g_sPlayerTag[client]);
			}
			else
			{
				CS_SetClientClanTag(client, g_sStatsTag[client].WARDEN);
			}
		}
		else if (gp_bMyJBWarden && warden_deputy_isdeputy(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client].DEPUTY) < 1)
			{
				CS_SetClientClanTag(client, g_sPlayerTag[client]);
			}
			else
			{
				CS_SetClientClanTag(client, g_sStatsTag[client].DEPUTY);
			}
		}
		else
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client].GUARD) < 1)
			{
				CS_SetClientClanTag(client, g_sPlayerTag[client]);
			}
			else
			{
				CS_SetClientClanTag(client, g_sStatsTag[client].GUARD);
			}
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client].SPECTATOR) < 1)
		{
			CS_SetClientClanTag(client, g_sPlayerTag[client]);
		}
		else
		{
			CS_SetClientClanTag(client, g_sStatsTag[client].SPECTATOR);
		}
	}
}

// Check Chat & add Tag
public Action CP_OnChatMessage(int &client, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if (!gc_bPlugin.BoolValue || !gp_bChatProcessor)
		return Plugin_Continue;

	if (!gc_bChat.BoolValue)
		return Plugin_Continue;

	if (gp_bCCC && !gc_bExtern.BoolValue)
	{
		char sColor[32];
		CCC_GetTag(client, sColor, sizeof(sColor));

		if (strlen(sColor) > 0)
			return Plugin_Continue;
	}

	if (gp_bTOGsTags && !gc_bExtern.BoolValue)
	{
		if (TOGsClanTags_HasAnyTag(client))
			return Plugin_Continue;
	}

	if (GetClientTeam(client) == CS_TEAM_T)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].PRISONER) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].PRISONER, name);
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (gp_bWarden && warden_iswarden(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].WARDEN) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].WARDEN, name);
			}
		}
		else if (gp_bMyJBWarden && warden_deputy_isdeputy(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].DEPUTY) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].DEPUTY, name);
			}
		}
		else
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].GUARD) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].GUARD, name);
			}
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].SPECTATOR) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].SPECTATOR, name);
		}
	}

	Format(message, MAXLENGTH_MESSAGE, "{default}%s", message);

	return Plugin_Changed;
}

public Action OnChatMessage(int &client, Handle recipients, char[] name, char[] message)
{
	if (!gc_bPlugin.BoolValue || !gp_bChatProcessor)
		return Plugin_Continue;

	if (!gc_bChat.BoolValue)
		return Plugin_Continue;

	if (gp_bCCC && !gc_bExtern.BoolValue)
	{
		char sColor[32];
		CCC_GetTag(client, sColor, sizeof(sColor));

		if (strlen(sColor) > 0)
			return Plugin_Continue;
	}

	if (gp_bTOGsTags && !gc_bExtern.BoolValue)
	{
		if (TOGsClanTags_HasAnyTag(client))
			return Plugin_Continue;
	}

	if (GetClientTeam(client) == CS_TEAM_T)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].PRISONER) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].PRISONER, name);
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (gp_bWarden && warden_iswarden(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].WARDEN) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].WARDEN, name);
			}
		}
		else if (gp_bMyJBWarden && warden_deputy_isdeputy(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].DEPUTY) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].DEPUTY, name);
			}
		}
		else
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].GUARD) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].GUARD, name);
			}
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client].SPECTATOR) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client].SPECTATOR, name);
		}
	}

	return Plugin_Changed;
}