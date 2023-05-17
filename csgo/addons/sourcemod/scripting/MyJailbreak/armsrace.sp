/*
 * MyJailbreak - Arms Race Event Day Plugin.
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
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <hosties>
#include <lastrequest>
#include <warden>
#include <myjbwarden>
#include <myjailbreak>
#include <myweapons>
#include <smartjaildoors>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsArmsRace = false;
bool g_bStartArmsRace = false;
bool g_bIsRoundEnd = true;

// Plugin bools
bool gp_bWarden;
bool gp_bMyJBWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bMyJailbreak;
bool gp_bMyWeapons;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bVote;
ConVar gc_iCooldownStart;
ConVar gc_bSpawnCell;
ConVar gc_bSpawnRandom;
ConVar gc_iRoundTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iCooldownDay;
ConVar gc_iTruceTime;
ConVar gc_iRounds;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;
ConVar gc_bKillLoser;

ConVar gc_bBeginSetA;
ConVar gc_bBeginSetW;
ConVar gc_bBeginSetV;
ConVar gc_bBeginSetVW;
ConVar gc_bTeleportSpawn;

// Extern Convars

// Integers
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

int g_iLevel[MAXPLAYERS+1];
int g_iMaxLevel;

// Floats
float g_fPos[3];

// Handles
Handle g_hTimerTruce;
Handle g_hTimerBeacon;
Handle g_aWeapons;

// Strings
char g_sPrefix[64];
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sOverlayStartPath[256];

// Info
public Plugin myinfo = 
{
	name = "MyJailbreak - Arms Race",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.ArmsRace.phrases");

	// Client Commands
	RegConsoleCmd("sm_setarmsrace", Command_Setarmsrace, "Allows the Admin or Warden to set ArmsRace");
	RegConsoleCmd("sm_armsrace", Command_VoteArmsRace, "Allows players to vote for a ArmsRace");

	// AutoExecConfig
	AutoExecConfig_SetFile("ArmsRace", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_armsrace_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_armsrace_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_armsrace_prefix", "[{green}MyJB.ArmsRace{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_armsrace_cmds_vote", "arms, ar", "Set your custom chat command for Event voting(!armsrace (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_armsrace_cmds_set", "sar, setarms", "Set your custom chat command for set Event(!setarmsrace (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_armsrace_warden", "1", "0 - disabled, 1 - allow warden to set armsrace round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_armsrace_admin", "1", "0 - disabled, 1 - allow admin/vip to set armsrace round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_armsrace_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_armsrace_vote", "1", "0 - disabled, 1 - allow player to vote for armsrace", _, true, 0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_armsrace_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true, 0.0, true, 1.0);
	gc_bSpawnRandom = AutoExecConfig_CreateConVar("sm_armsrace_randomspawn", "1", "0 - disabled, 1 - use random spawns on map (sm_armsrace_spawn 1)", _, true, 0.0, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_armsrace_begin_admin", "1", "When admin set event (!setarmsrace) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_armsrace_begin_warden", "1", "When warden set event (!setarmsrace) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_armsrace_begin_vote", "0", "When users vote for event (!armsrace) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_armsrace_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bTeleportSpawn = AutoExecConfig_CreateConVar("sm_armsrace_teleport_spawn", "0", "0 - start event in current round from current player positions, 1 - teleport players to spawn when start event on current round(only when sm_*_begin_admin, sm_*_begin_warden, sm_*_begin_vote or sm_*_begin_daysvote is on '1')", _, true, 0.0, true, 1.0);

	gc_iRounds = AutoExecConfig_CreateConVar("sm_armsrace_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_armsrace_roundtime", "10", "Round time in minutes for a single armsrace round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_armsrace_trucetime", "8", "Time in seconds players can't deal damage", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_armsrace_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_armsrace_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_armsrace_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set armsrace round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_armsrace_sounds_enable", "1", "0 - disabled, 1 - enable sounds", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_armsrace_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_armsrace_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_armsrace_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bKillLoser = AutoExecConfig_CreateConVar("sm_armsrace_kill_loser", "0", "0 - disabled, 1 - Kill loserteam on event end / not for sm_armsrace_allow_lr '1'", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));

	// Logs
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");
}


// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayStartPath);
		}
	}
	else if (convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundStartPath);
		}
	}
	else if (convar == gc_sPrefix)
	{
		strcopy(g_sPrefix, sizeof(g_sPrefix), newValue);
	}
}

public void OnAllPluginsLoaded()
{
	gp_bWarden = LibraryExists("warden");
	gp_bMyJBWarden = LibraryExists("myjbwarden");
	gp_bHosties = LibraryExists("lastrequest");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bMyJailbreak = LibraryExists("myjailbreak");
	gp_bMyWeapons = LibraryExists("myweapons");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "warden"))
	{
		gp_bWarden = false;
	}
	else if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = false;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = false;
	}
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = false;
	}
	else if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailbreak = false;
	}
	else if (StrEqual(name, "myweapons"))
	{
		gp_bMyWeapons = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "warden"))
	{
		gp_bWarden = true;
	}
	else if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = true;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = true;
	}
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = true;
	}
	else if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailbreak = true;
	}
	else if (StrEqual(name, "myweapons"))
	{
		gp_bMyWeapons = true;
	}
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	// FindConVar
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;

	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));

	GetWeapons();

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Vote
	gc_sCustomCommandVote.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_VoteArmsRace, "Allows players to vote for a ArmsRace");
		}
	}

	// Set
	gc_sCustomCommandSet.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_Setarmsrace, "Allows the Admin or Warden to set a armsrace");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("armsrace");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("armsrace");
}



/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_Setarmsrace(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_disabled");

		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartEventRound(gc_bBeginSetVW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event armsrace was started by groupvoting");
		}
	}
	else if (MyJB_CheckVIPFlags(client, "sm_armsrace_flag", gc_sAdminFlag, "sm_armsrace_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_setbyadmin");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetA.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Free for all was started by admin %L", client);
		}
	}
	else if (gp_bWarden) // Called by warden
	{
		if (!warden_iswarden(client))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");

			return Plugin_Handled;
		}
		
		if (!gc_bSetW.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_setbywarden");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Free for all was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteArmsRace(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_disabled");

		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_voting");

		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_minplayer");

		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_progress", EventDay);

			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_wait", g_iCoolDown);

		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "armsrace_voted");

		return Plugin_Handled;
	}

	int playercount = (GetClientCount(true) / 2);
	g_iVoteCount += 1;

	int Missing = playercount - g_iVoteCount + 1;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "%s, %s", g_sHasVoted, steamid);

	if (g_iVoteCount > playercount)
	{
		StartEventRound(gc_bBeginSetV.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Free for all was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%s %t", g_sPrefix, "armsrace_need", Missing, client);
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = false;

	if (!g_bStartArmsRace && !g_bIsArmsRace)
	{
		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				g_iCoolDown = gc_iCooldownDay.IntValue + 1;
			}
			else if (g_iCoolDown > 0)
			{
				g_iCoolDown -= 1;
			}
		}
		else if (g_iCoolDown > 0)
		{
			g_iCoolDown -= 1;
		}

		return;
	}

	g_bIsArmsRace = true;
	g_bStartArmsRace = false;

	PrepareDay(false);
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = true;

	if (g_bIsArmsRace)
	{
		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "armsrace_twin_nc");
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "armsrace_ctwin_nc");
		}

		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
		{
			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'

			if (gc_bKillLoser.BoolValue && g_iLevel[i] != g_iMaxLevel)
			{
				ForcePlayerSuicide(i);
			}
		}

		delete g_hTimerTruce;
		delete g_hTimerBeacon;
		g_iTruceTime = gc_iTruceTime.IntValue;

		if (g_iRound == g_iMaxRound)
		{
			g_bIsArmsRace = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");

			if (gp_bHosties)
			{
				SetCvar("sm_hosties_lr", 1);
			}

			if (gp_bMyJBWarden)
			{
				warden_enable(true);
			}

			if (gp_bMyWeapons)
			{
				MyWeapons_AllowTeam(CS_TEAM_T, false);
				MyWeapons_AllowTeam(CS_TEAM_CT, true);
			}

			if (gc_bSpawnRandom.BoolValue)
			{
				SetCvar("mp_randomspawn", 0);
				SetCvar("mp_randomspawn_los", 0);
			}

			if (gp_bMyJailbreak)
			{
				MyJailbreak_SetEventDayRunning(false, winner);
				MyJailbreak_SetEventDayName("none");
			}

			SetCvar("mp_friendlyfire", 0);
			SetCvar("sm_menu_enable", 1);
			SetCvar("mp_death_drop_gun", 1);
			SetCvar("mp_teammates_are_enemies", 0);

			CPrintToChatAll("%s %t", g_sPrefix, "armsrace_end");
		}
	}
	if (g_bStartArmsRace)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "armsrace_next");
		PrintCenterTextAll("%t", "armsrace_next_nc");
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	g_bIsArmsRace = false;
	g_bStartArmsRace = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
}

// Map End
public void OnMapEnd()
{
	g_bIsArmsRace = false;
	g_bStartArmsRace = false;

	delete g_hTimerTruce;
	delete g_hTimerBeacon;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

public void MyJailbreak_ResetEventDay()
{
	g_bStartArmsRace = false;

	if (g_bIsArmsRace)
	{
		g_iRound = g_iMaxRound;
		ResetEventDay();
	}
}

void ResetEventDay()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'

		StripAllPlayerWeapons(i);

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			FakeClientCommand(i, "sm_weapons");
		}

		GivePlayerItem(i, "weapon_knife");

		SetEntityMoveType(i, MOVETYPE_WALK);

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		EnableWeaponFire(i, true);
	}

	delete g_hTimerTruce;
	delete g_hTimerBeacon;
	g_iTruceTime = gc_iTruceTime.IntValue;

	g_bIsArmsRace = false;
	g_iRound = 0;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "");

	if (gp_bHosties)
	{
		SetCvar("sm_hosties_lr", 1);
	}

	if (gp_bMyJBWarden)
	{
		warden_enable(true);
	}

	if (gp_bMyWeapons)
	{
		MyWeapons_AllowTeam(CS_TEAM_T, false);
		MyWeapons_AllowTeam(CS_TEAM_CT, true);
	}

	if (gc_bSpawnRandom.BoolValue)
	{
		SetCvar("mp_randomspawn", 0);
		SetCvar("mp_randomspawn_los", 0);
	}

	if (gp_bMyJailbreak)
	{
		MyJailbreak_SetEventDayRunning(false, 0);
		MyJailbreak_SetEventDayName("none");
	}

	SetCvar("mp_friendlyfire", 0);
	SetCvar("sm_menu_enable", 1);
	SetCvar("mp_death_drop_gun", 1);
	SetCvar("mp_teammates_are_enemies", 0);

	CPrintToChatAll("%s %t", g_sPrefix, "armsrace_end");
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Prepare Event for next round
void StartEventRound(bool thisround)
{
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;

	if (gp_bMyJailbreak)
	{
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "armsrace_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsArmsRace = true;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			EnableWeaponFire(i, false);

			SetEntityMoveType(i, MOVETYPE_NONE);
		}
		
		CreateTimer(3.0, Timer_PrepareEvent);
		
		CPrintToChatAll("%s %t", g_sPrefix, "armsrace_now");
		PrintCenterTextAll("%t", "armsrace_now_nc");
		
	}
	else
	{
		g_bStartArmsRace = true;
		g_iCoolDown++;

		CPrintToChatAll("%s %t", g_sPrefix, "armsrace_next");
		PrintCenterTextAll("%t", "armsrace_next_nc");
	}

	if (gc_bSpawnRandom.BoolValue)
	{
		SetCvar("mp_randomspawn", 1);
		SetCvar("mp_randomspawn_los", 1);
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	if (!g_bIsArmsRace)
		return Plugin_Handled;

	PrepareDay(true);

	return Plugin_Handled;
}


void PrepareDay(bool thisround)
{
	g_iRound++;

	if (gp_bSmartJailDoors)
	{
		SJD_OpenDoors();
	}

	if ((thisround && gc_bTeleportSpawn.BoolValue) || !gc_bSpawnRandom.BoolValue && !gc_bSpawnCell.BoolValue || !gp_bSmartJailDoors || (gc_bSpawnCell.BoolValue && (SJD_IsCurrentMapConfigured() != true))) // spawn Terrors to CT Spawn 
	{
		int RandomCT = 0;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, false))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				CS_RespawnPlayer(i);
				RandomCT = i;
				break;
			}
		}

		if (RandomCT)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, true, false))
					continue;

				GetClientAbsOrigin(RandomCT, g_fPos);
				
				g_fPos[2] = g_fPos[2] + 5;
				
				TeleportEntity(i, g_fPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}

	char buffer[32];

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 2);  // 2 - none / 5 - 'default'

		SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

		EnableWeaponFire(i, false);

		CreateInfoPanel(i);

		g_iLevel[i] = 0;

		StripAllPlayerWeapons(i);

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			GivePlayerItem(i, "weapon_knife");
		}
		else
		{
			GivePlayerItem(i, "weapon_knife_t");
		}

		GetArrayString(g_aWeapons, g_iLevel[i], buffer, sizeof(buffer));
		GivePlayerItem(i, buffer);
	}

	if (gp_bMyJailbreak)
	{
		SetCvar("sm_menu_enable", 0);

		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);

		MyJailbreak_FogOn();
	}

	if (gp_bMyJBWarden)
	{
		warden_enable(false);
	}

	if (gp_bHosties)
	{
		SetCvar("sm_hosties_lr", 0);
	}

	if (gp_bMyWeapons)
	{
		MyWeapons_AllowTeam(CS_TEAM_T, false);
		MyWeapons_AllowTeam(CS_TEAM_CT, false);
	}

	CPrintToChatAll("%s %t", g_sPrefix, "armsrace_rounds", g_iRound, g_iMaxRound);

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	SetCvar("mp_death_drop_gun", 0);
	SetCvar("mp_teammates_are_enemies", 1);
	SetCvar("mp_friendlyfire", 1);

	g_hTimerTruce = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "armsrace_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "armsrace_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "armsrace_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "armsrace_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "armsrace_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "armsrace_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "armsrace_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "armsrace_info_line7", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	Format(info, sizeof(info), "%T", "warden_close", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_NullCancel, 20);

	delete InfoPanel;
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Start Timer
public Action Timer_StartEvent(Handle timer)
{
	g_iTruceTime--;

	if (g_iTruceTime > 0)
	{
		if (g_iTruceTime == gc_iTruceTime.IntValue-3)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, true, false))
					continue;

				SetEntityMoveType(i, MOVETYPE_WALK);
			}
		}

		PrintCenterTextAll("%t", "armsrace_damage_nc", g_iTruceTime);

		return Plugin_Continue;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		EnableWeaponFire(i, true);

		SetEntityMoveType(i, MOVETYPE_WALK);

		if (gc_bOverlays.BoolValue)
		{
			ShowOverlay(i, g_sOverlayStartPath, 2.0);
		}
	}

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sSoundStartPath);
	}

	if (gp_bMyJailbreak)
	{
		MyJailbreak_FogOff();
	}

	g_hTimerTruce = null;

	PrintCenterTextAll("%t", "armsrace_start_nc");
	CPrintToChatAll("%s %t", g_sPrefix, "armsrace_start");

	return Plugin_Stop;
}

// Beacon Timer
public Action Timer_BeaconOn(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, false))
			continue;

		MyJailbreak_BeaconOn(i, 2.0);
	}

	g_hTimerBeacon = null;
}

void GetWeapons()
{
	char g_filename[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, g_filename, sizeof(g_filename), "configs/MyJailbreak/armsrace.ini");

	File hFile = OpenFile(g_filename, "rt");

	if (hFile == null)
	{
		delete hFile;
		SetFailState("MyJailbreak Arms Race - Can't read %s correctly! (ImportFromFile)", g_filename);
	}

	g_aWeapons = CreateArray(32);

	while (!IsEndOfFile(hFile))
	{
		char line[128];

		if (!ReadFileLine(hFile, line, sizeof(line)))
			break;

		TrimString(line);

		if (StrContains(line, "/", false) != -1)
			continue;

		if (!line[0])
			continue;

		PushArrayString(g_aWeapons, line);
	}

	delete hFile;

	g_iMaxLevel = GetArraySize(g_aWeapons);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if (!g_bIsArmsRace)
		return;

	int victim = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id
	int attacker = GetClientOfUserId(event.GetInt("attacker")); // Get the attacker clients id

	if (IsValidClient(attacker, true, false) && (attacker != victim) && IsValidClient(victim, true, true))
	{
		g_iLevel[attacker] += 1;

		char sWeaponUsed[50];
		event.GetString("weapon", sWeaponUsed, sizeof(sWeaponUsed));

		if (g_iLevel[attacker] == g_iMaxLevel)
		{
			CPrintToChat(attacker, "%s %t", g_sPrefix, "armsrace_youwon");
			CPrintToChatAll("%s %t", g_sPrefix, "armsrace_winner", attacker);
			CS_TerminateRound(5.0, CSRoundEnd_Draw);
			return;
		}
		else if (StrContains(sWeaponUsed, "knife", false) != -1)
		{
			g_iLevel[attacker] -= 1;
			g_iLevel[victim] -= 1;
			if (g_iLevel[victim] <= -1)
			{
				g_iLevel[victim] = 0;
			}
			
			CPrintToChat(victim, "%s %t", g_sPrefix, "armsrace_downgraded");
			CPrintToChat(attacker, "%s %t", g_sPrefix, "armsrace_downgrade", victim);
		}
		else
		{
			StripAllPlayerWeapons(attacker);
			
			char buffer[32];
			GetArrayString(g_aWeapons, g_iLevel[attacker], buffer, sizeof(buffer));
			GivePlayerItem(attacker, buffer);
			
			if (g_iLevel[attacker] != g_iMaxLevel)
			{
				if (GetClientTeam(attacker) == CS_TEAM_CT)
				{
					GivePlayerItem(attacker, "weapon_knife");
				}
				else
				{
					GivePlayerItem(attacker, "weapon_knife_t");
				}
			}
			

			ReplaceString(buffer, sizeof(buffer), "weapon_", "", false);
			StringToUpper(buffer);
			CPrintToChat(attacker, "%s %t", g_sPrefix, "armsrace_levelup", buffer);
		}
	}
	
	CreateTimer (2.0, Timer_Respawn, GetClientUserId(victim));
}

public Action Timer_Respawn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Handled;
	}

	CS_RespawnPlayer(client);

	StripAllPlayerWeapons(client);

	char buffer[32];
	GetArrayString(g_aWeapons, g_iLevel[client], buffer, sizeof(buffer));
	GivePlayerItem(client, buffer);

	if (g_iLevel[client] != g_iMaxLevel)
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			GivePlayerItem(client, "weapon_knife");
		}
		else
		{
			GivePlayerItem(client, "weapon_knife_t");
		}
	}

	return Plugin_Handled;
}

// Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
}

// Knife only
public Action OnWeaponCanUse(int client, int weapon)
{
	if (!g_bIsArmsRace)
	{
		return Plugin_Continue;
	}

	if (g_iLevel[client] == g_iMaxLevel)
	{
		return Plugin_Continue;
	}

	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	char buffer[32];
	GetArrayString(g_aWeapons, g_iLevel[client], buffer, sizeof(buffer));

	if ((StrEqual(sWeapon, buffer) || StrEqual(sWeapon, "weapon_knife") || StrEqual(sWeapon, "weapon_knife_t")) && IsValidClient(client, true, false))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

//Deny weapon drops
public Action OnWeaponDrop(int client, int weapon)
{
	if (!g_bIsArmsRace)
	{
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (!g_bIsArmsRace)
	{
		return Plugin_Continue;
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if (g_iLevel[i] == g_iMaxLevel)
		{
			return Plugin_Continue;
		}
	}

	return Plugin_Handled;
}

bool MyJB_CheckVIPFlags(int client, const char[] command, ConVar flags, char[] feature)
{
	if (gp_bMyJailbreak)
		return MyJailbreak_CheckVIPFlags(client, command, flags, feature);

	char sBuffer[32];
	flags.GetString(sBuffer, sizeof(sBuffer));

	if (strlen(sBuffer) == 0) // ???
		return true;

	int iFlags = ReadFlagString(sBuffer);

	return CheckCommandAccess(client, command, iFlags);
}