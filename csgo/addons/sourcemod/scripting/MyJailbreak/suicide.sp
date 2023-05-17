/*
 * MyJailbreak - Suicide Bomber Event Day Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
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

// Defines
#define IsSprintUsing   (1<<0)
#define IsSprintCoolDown  (1<<1)
#define IsBombing  (1<<2)

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsSuicideBomber = false;
bool g_bStartSuicideBomber = false;
bool g_bBombActive = false;
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
ConVar gc_iKey;
ConVar gc_bStandStill;
ConVar gc_fBombRadius;
ConVar gc_fBombRadiusT;
ConVar gc_fBeaconTime;
ConVar gc_bSounds;
ConVar gc_bOverlays;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iRoundTime;
ConVar gc_iFreezeTime;
ConVar gc_sOverlayStartPath;
ConVar gc_bSprintUse;
ConVar gc_iSprintCooldown;
ConVar gc_bSprint;
ConVar gc_fSprintSpeed;
ConVar gc_iSprintTime;
ConVar gc_sSoundStartPath;
ConVar gc_sSoundSuicideBomberPath;
ConVar gc_sSoundBoomPath;
ConVar gc_iRounds;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;

ConVar gc_bBeginSetA;
ConVar gc_bBeginSetW;
ConVar gc_bBeginSetV;
ConVar gc_bBeginSetVW;
ConVar gc_bTeleportSpawn;


// Integers
int g_iVoteCount;
int g_iCoolDown;
int g_iFreezeTime;
int g_iRound;
int g_iSprintStatus[MAXPLAYERS+1];
int g_iMaxRound;

// Handles
Handle g_hTimerSprint[MAXPLAYERS+1];
Handle g_hTimerFreeze;
Handle g_hTimerBeacon;

// Strings
char g_sPrefix[64];
char g_sSoundBoomPath[256];
char g_sSoundSuicideBomberPath[256];
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sOverlayStartPath[256];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Suicide Bomber",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.SuicideBomber.phrases");

	// Client Commands
	RegConsoleCmd("sm_setsuicidebomber", Command_SetSuicideBomber, "Allows the Admin or Warden to set Suicide Bomber as next round");
	RegConsoleCmd("sm_suicidebomber", Command_VoteSuicideBomber, "Allows players to vote for a duckhunt");
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Starts the sprint");
	RegConsoleCmd("sm_makeboom", Command_BombSuicideBomber, "Suicide with bomb");

	// AutoExecConfig
	AutoExecConfig_SetFile("SuicideBomber", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_suicidebomber_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_suicidebomber_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_suicidebomber_prefix", "[{green}MyJB.SuicideBomber{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_suicidebomber_cmds_vote", "suicide, jihad, bomber", "Set your custom chat commands for Event voting(!suicidebomber (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_suicidebomber_cmds_set", "ssuicidebomber, ssuicide, sbomber, sjihad, setjihad", "Set your custom chat commands for set Event(!setsuicidebomber (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_suicidebomber_warden", "1", "0 - disabled, 1 - allow warden to set Suicide Bomber round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_suicidebomber_admin", "1", "0 - disabled, 1 - allow admin/vip to set Suicide Bomber round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_suicidebomber_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_suicidebomber_vote", "1", "0 - disabled, 1 - allow player to vote for Suicide Bomber", _, true, 0.0, true, 1.0);
	gc_iKey = AutoExecConfig_CreateConVar("sm_suicidebomber_key", "1", "1 - Inspect(look) weapon / 2 - walk / 3 - Secondary Attack", _, true, 1.0, true, 3.0);
	gc_bStandStill = AutoExecConfig_CreateConVar("sm_suicidebomber_standstill", "1", "0 - disabled, 1 - standstill(cant move) on Activate bomb", _, true, 0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_suicidebomber_rounds", "1", "Rounds to play in a row", _, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_suicidebomber_begin_admin", "1", "When admin set event (!setsuicidebomber) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_suicidebomber_begin_warden", "1", "When warden set event (!setsuicidebomber) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_suicidebomber_begin_vote", "0", "When users vote for event (!suicidebomber) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_suicidebomber_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bTeleportSpawn = AutoExecConfig_CreateConVar("sm_suicidebomber_teleport_spawn", "0", "0 - start event in current round from current player positions, 1 - teleport players to spawn when start event on current round(only when sm_*_begin_admin, sm_*_begin_warden, sm_*_begin_vote or sm_*_begin_daysvote is on '1')", _, true, 0.0, true, 1.0);

	gc_fBombRadius = AutoExecConfig_CreateConVar("sm_suicidebomber_bomb_radius", "200.0", "Radius for bomb damage on guards", _, true, 10.0, true, 999.0);
	gc_fBombRadiusT = AutoExecConfig_CreateConVar("sm_suicidebomber_bomb_radius_t", "200.0", "Radius for bomb damage on prisoners (reduce when you have problem with teamkiller) / 0 - disable team damage at all", _, true, 0.0, true, 999.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_suicidebomber_hidetime", "20", "Time to hide for CTs", _, true, 0.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_suicidebomber_roundtime", "5", "Round time in minutes for a single Suicide Bomber round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_suicidebomber_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_suicidebomber_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_suicidebomber_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_suicidebomber_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set suicide round", _, true, 0.0, true, 1.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_suicidebomber_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_suicidebomber_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for start.");
	gc_sSoundSuicideBomberPath = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_suicidebomber", "music/MyJailbreak/suicidebomber.mp3", "Path to the soundfile which should be played on activatebomb.");
	gc_sSoundBoomPath = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_boom", "music/MyJailbreak/boom.mp3", "Path to the soundfile which should be played on detonation.");
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_button", "1", "0 - disabled, 1 - enable +use button for sprint", _, true, 0.0, true, 1.0);
	gc_iSprintCooldown = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_cooldown", "7", "Time in seconds the player must wait for the next sprint", _, true, 0.0);
	gc_bSprint = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_enable", "1", "0 - disabled, 1 - enable ShortSprint", _, true, 0.0, true, 1.0);
	gc_fSprintSpeed = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_speed", "1.30", "Ratio for how fast the player will sprint", _, true, 1.01, true, 5.00);
	gc_iSprintTime = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_time", "2.5", "Time in seconds the player will sprint", _, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", Event_RoundEnd);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundSuicideBomberPath, OnSettingChanged);
	HookConVarChange(gc_sSoundBoomPath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	gc_sSoundSuicideBomberPath.GetString(g_sSoundSuicideBomberPath, sizeof(g_sSoundSuicideBomberPath));
	gc_sSoundBoomPath.GetString(g_sSoundBoomPath, sizeof(g_sSoundBoomPath));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));

	AddCommandListener(Command_LAW, "+lookatweapon");

	// Logs
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			OnClientPutInServer(i);
		}

		g_bIsLateLoad = false;
	}
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sSoundSuicideBomberPath)
	{
		strcopy(g_sSoundSuicideBomberPath, sizeof(g_sSoundSuicideBomberPath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundSuicideBomberPath);
		}
	}
	else if (convar == gc_sSoundBoomPath)
	{
		strcopy(g_sSoundBoomPath, sizeof(g_sSoundBoomPath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundBoomPath);
		}
	}
	else if (convar == gc_sOverlayStartPath)
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
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;

	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sSoundSuicideBomberPath.GetString(g_sSoundSuicideBomberPath, sizeof(g_sSoundSuicideBomberPath));
	gc_sSoundBoomPath.GetString(g_sSoundBoomPath, sizeof(g_sSoundBoomPath));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));

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
			RegConsoleCmd(sCommand, Command_VoteSuicideBomber, "Allows players to vote for a duckhunt");
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
			RegConsoleCmd(sCommand, Command_SetSuicideBomber, "Allows the Admin or Warden to set Suicide Bomber as next round");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("suicidebomber");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("suicidebomber");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetSuicideBomber(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_disabled");

		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartEventRound(gc_bBeginSetVW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by groupvoting");
		}
	}
	else if (MyJB_CheckVIPFlags(client, "sm_suicidebomber_flag", gc_sAdminFlag, "sm_suicidebomber_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_setbyadmin");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetA.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by admin %L", client);
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
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_setbywarden");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteSuicideBomber(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_disabled");

		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_voting");

		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_minplayer");

		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_progress", EventDay);

			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_wait", g_iCoolDown);

		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_voted");

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
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_need", Missing, client);
	}

	return Plugin_Handled;
}

// Set Button Suicide Bomber
public Action Command_LAW(int client, const char[] command, int argc)
{
	if (g_bIsSuicideBomber)
	{
		if (gc_iKey.IntValue == 1)
		{
			Command_BombSuicideBomber(client, 0);
		}
	}

	return Plugin_Continue;
}

// Activate Bombtimer
public Action Command_BombSuicideBomber(int client, int args)
{
	if (g_bIsSuicideBomber && g_bBombActive && IsValidClient(client, false, false))
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char weaponName[64];

		if (IsValidEdict(weapon))
		{
			GetEdictClassname(weapon, weaponName, sizeof(weaponName));

			if (GetClientTeam(client) == CS_TEAM_T)
			{
				if (StrEqual(weaponName, "weapon_c4"))
				{
					EmitSoundToAllAny(g_sSoundSuicideBomberPath);
					CreateTimer(1.0, Timer_DetonateBomb, GetClientUserId(client));
					if (gc_bStandStill.BoolValue)
					{
						SetEntityMoveType(client, MOVETYPE_NONE);
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
					}
				}
			}
		}
	}
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = false;

	if (!g_bStartSuicideBomber && !g_bIsSuicideBomber)
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

	g_bIsSuicideBomber = true;
	g_bStartSuicideBomber = false;

	PrepareDay(false);
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = true;

	if (g_bIsSuicideBomber)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
			g_iSprintStatus[i] = 0;
		}

		delete g_hTimerFreeze;
		delete g_hTimerBeacon;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "suicidebomber_twin_nc");
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "suicidebomber_ctwin_nc");
		}

		g_bBombActive = false;

		if (g_iRound == g_iMaxRound)
		{
			g_bIsSuicideBomber = false;
			g_bStartSuicideBomber = false;
			g_bBombActive = false;
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

			SetCvar("sv_infinite_ammo", 0);

			if (gp_bMyJailbreak)
			{
				SetCvar("sm_menu_enable", 1);

				MyJailbreak_SetEventDayRunning(false, winner);
				MyJailbreak_SetEventDayName("none");
			}

			CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_end");
		}
	}

	if (g_bStartSuicideBomber)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_next");
		PrintCenterTextAll("%t", "suicidebomber_next_nc");
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
	g_bIsSuicideBomber = false;
	g_bStartSuicideBomber = false;
	g_bBombActive = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundSuicideBomberPath);
		PrecacheSoundAnyDownload(g_sSoundBoomPath);
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}

	PrecacheSound("player/suit_sprint.wav", true);
}

// Map End
public void OnMapEnd()
{
	g_bIsSuicideBomber = false;
	g_bStartSuicideBomber = false;
	g_bBombActive = false;

	delete g_hTimerFreeze;
	delete g_hTimerBeacon;

	g_hTimerFreeze = null;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

public void MyJailbreak_ResetEventDay()
{
	g_bStartSuicideBomber = false;

	if (g_bIsSuicideBomber)
	{
		g_iRound = g_iMaxRound;
		ResetEventDay();
	}
}


void ResetEventDay()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
		g_iSprintStatus[i] = 0;

		SetEntityMoveType(i, MOVETYPE_WALK);

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		EnableWeaponFire(i, true);
	}

	delete g_hTimerFreeze;
	delete g_hTimerBeacon;

	g_bBombActive = false;

	g_bIsSuicideBomber = false;
	g_bStartSuicideBomber = false;
	g_bBombActive = false;
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

	SetCvar("sv_infinite_ammo", 0);

	if (gp_bMyJailbreak)
	{
		SetCvar("sm_menu_enable", 1);

		MyJailbreak_SetEventDayRunning(false, 0);
		MyJailbreak_SetEventDayName("none");
	}

	CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_end");
}

// Check pressed buttons
public void OnGameFrame()
{
	if (g_bIsSuicideBomber)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			if (gc_iKey.IntValue == 2)
			{
				if (IsClientInGame(i) && (GetClientButtons(i) & IN_SPEED))
				{
					Command_BombSuicideBomber(i, 0);
				}
			}
			else if (gc_iKey.IntValue == 3)
			{
				if (IsClientInGame(i) && (GetClientButtons(i) & IN_ATTACK2))
				{
					Command_BombSuicideBomber(i, 0);
				}
			}
			if (gc_bSprintUse.BoolValue)
			{
				if (IsClientInGame(i) && (GetClientButtons(i) & IN_USE))
				{
					Command_StartSprint(i, 0);
				}
			}
		}
	}

	return;
}

// Disable Bomb Drop
public Action CS_OnCSWeaponDrop(int client, int weapon)
{
	if (g_bIsSuicideBomber && IsValidClient(client, false, false))
	{
		char g_sWeaponName[80];
		if (weapon > MaxClients && GetClientTeam(client) == CS_TEAM_T && GetEntityClassname(weapon, g_sWeaponName, sizeof(g_sWeaponName)))
		{
			if (StrEqual("weapon_c4", g_sWeaponName, false))
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

// Counter-Terror win Round if time runs out
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (g_bIsSuicideBomber)   // TODO: does this trigger??
	{
		if (reason == CSRoundEnd_Draw)
		{
			reason = CSRoundEnd_CTWin;
			return Plugin_Changed;
		}

		return Plugin_Continue;
	}

	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

// Knife & c4 only
public Action OnWeaponCanUse(int client, int weapon)
{
	if (!g_bIsSuicideBomber)
		return Plugin_Continue;

	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if ((GetClientTeam(client) == CS_TEAM_T && !StrEqual(sWeapon, "weapon_c4")) || (GetClientTeam(client) == CS_TEAM_CT && !StrEqual(sWeapon, "weapon_knife")) && IsValidClient(client, true, false))
	{
		if (g_bIsSuicideBomber)
			return Plugin_Handled;
	}

	return Plugin_Continue;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Prepare Event
void StartEventRound(bool thisround)
{
	g_iCoolDown = gc_iCooldownDay.IntValue;
	g_iVoteCount = 0;

	if (gp_bMyJailbreak)
	{
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "suicidebomber_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsSuicideBomber = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			EnableWeaponFire(i, false);

			SetEntityMoveType(i, MOVETYPE_NONE);
		}

		CreateTimer(3.0, Timer_PrepareEvent);

		CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_now");
		PrintCenterTextAll("%t", "suicidebomber_now_nc");
	}
	else
	{
		g_bStartSuicideBomber = true;
		g_iCoolDown++;

		CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_next");
		PrintCenterTextAll("%t", "suicidebomber_next_nc");
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	if (!g_bIsSuicideBomber)
		return Plugin_Handled;

	PrepareDay(true);

	return Plugin_Handled;
}

void PrepareDay(bool thisround)
{
	g_iRound++;

	if (gp_bSmartJailDoors)
	{
		SJD_CloseDoors();
	}

	if ((thisround && gc_bTeleportSpawn.BoolValue)) // spawn Terrors to CT Spawn 
	{
		int RandomCT = 0;
		int RandomT = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, false))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				CS_RespawnPlayer(i);
				RandomCT = i;
			}
			else if (GetClientTeam(i) == CS_TEAM_T)
			{
				CS_RespawnPlayer(i);
				RandomT = i;
			}
			if (RandomCT != 0 && RandomT != 0)
			{
				break;
			}
		}

		if (RandomCT && RandomT)
		{
			float g_fPosT[3], g_fPosCT[3];
			GetClientAbsOrigin(RandomT, g_fPosT);
			GetClientAbsOrigin(RandomCT, g_fPosCT);
			g_fPosT[2] = g_fPosT[2] + 5;
			g_fPosCT[2] = g_fPosCT[2] + 5;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				if (!gp_bSmartJailDoors || (SJD_IsCurrentMapConfigured() != true))
				{
					TeleportEntity(i, g_fPosCT, NULL_VECTOR, NULL_VECTOR);
				}
				else if (GetClientTeam(i) == CS_TEAM_T)
				{
					TeleportEntity(i, g_fPosT, NULL_VECTOR, NULL_VECTOR);
				}
				else if (GetClientTeam(i) == CS_TEAM_CT)
				{
					TeleportEntity(i, g_fPosCT, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 2);  // 2 - none / 5 - 'default'

		SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

		EnableWeaponFire(i, false);

		CreateInfoPanel(i);

		StripAllPlayerWeapons(i);

		g_iSprintStatus[i] = 0;

		if (GetClientTeam(i) == CS_TEAM_T)
		{
			GivePlayerItem(i, "weapon_c4");
		}
		else if (GetClientTeam(i) == CS_TEAM_CT)
		{
			GivePlayerItem(i, "weapon_knife");
		}
	}

	if (gp_bMyJailbreak)
	{
		SetCvar("sm_menu_enable", 0);

		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);

		if (gc_fBeaconTime.FloatValue > 0.0)
		{
			g_hTimerBeacon = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		}
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

	CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_rounds", g_iRound, g_iMaxRound);

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	g_hTimerFreeze = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "suicidebomber_info_title", client);
	InfoPanel.SetTitle(info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "suicidebomber_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "suicidebomber_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line7", client);
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
	if (g_iFreezeTime > 0)
	{
		g_iFreezeTime--;

		if (g_iFreezeTime <= gc_iFreezeTime.IntValue - 3)
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false) && GetClientTeam(i) == CS_TEAM_CT)
			{
				SetEntityMoveType(i, MOVETYPE_WALK);
			}
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, false, false))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				PrintCenterText(i, "%t", "suicidebomber_timetohide_nc", g_iFreezeTime);
			}
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				PrintCenterText(i, "%t", "suicidebomber_timeuntilopen_nc", g_iFreezeTime);
			}
		}

		return Plugin_Continue;
	}

	g_iFreezeTime = gc_iFreezeTime.IntValue;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (IsValidClient(i, true, true))
		{
			SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

			EnableWeaponFire(i, true);

			SetEntityMoveType(i, MOVETYPE_WALK);
		}

		if (gc_bOverlays.BoolValue)
		{
			ShowOverlay(i, g_sOverlayStartPath, 2.0);
		}

		if (gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sSoundStartPath);
		}
	}

	PrintCenterTextAll("%t", "suicidebomber_start_nc");

	CPrintToChatAll("%s %t", g_sPrefix, "suicidebomber_start");

	if (gp_bSmartJailDoors)
	{
		SJD_OpenDoors();
	}

	g_hTimerFreeze = null;

	g_bBombActive = true;

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

// Detonate Bomb / Kill Player
public Action Timer_DetonateBomb(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	EmitSoundToAllAny(g_sSoundBoomPath);

	float suicide_bomber_vec[3];
	GetClientAbsOrigin(client, suicide_bomber_vec);

	int deathList[MAXPLAYERS+1]; // store players that this bomb kills
	int numKilledPlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		// Check that client is a real player who is alive and is a CT
		if (IsValidClient(i, true, false))
		{
			float ct_vec[3];
			GetClientAbsOrigin(i, ct_vec);

			float distance = GetVectorDistance(ct_vec, suicide_bomber_vec, false);

			// If CT was in explosion radius, damage or kill them
			// Formula used: damage = 200 - (d/2)
			int damage = RoundToFloor(GetClientTeam(i) == CS_TEAM_T ? gc_fBombRadiusT.FloatValue - (distance / 2.0) : gc_fBombRadius.FloatValue - (distance / 2.0));

			if (damage <= 0) // this player was not damaged 
				continue;

			// damage the surrounding players
			int curHP = GetClientHealth(i);

			if (curHP - damage <= 0) 
			{
				deathList[numKilledPlayers] = i;
				numKilledPlayers++;
			}
			else
			{ // Survivor
				SetEntityHealth(i, curHP - damage);
				IgniteEntity(i, 2.0);
			}
		}
	}
	if (numKilledPlayers > 0) 
	{
		for (int i = 0; i < numKilledPlayers;++i)
		{
			ForcePlayerSuicide(deathList[i]);
		}
	}
	ForcePlayerSuicide(client);
}

/******************************************************************************
                   SPRINT MODULE
******************************************************************************/

// Sprint
public Action Command_StartSprint(int client, int args)
{
	if (g_bIsSuicideBomber)
	{
		if (gc_bSprint.BoolValue && client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1 && !(g_iSprintStatus[client] & IsSprintUsing) && !(g_iSprintStatus[client] & IsSprintCoolDown))
		{
			g_iSprintStatus[client] |= IsSprintUsing | IsSprintCoolDown;
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
			EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
			CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_sprint");
			g_hTimerSprint[client] = CreateTimer(gc_iSprintTime.FloatValue, Timer_SprintEnd, GetClientUserId(client));
		}

		return Plugin_Handled;
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "suicidebomber_disabled");

	return Plugin_Handled ;
}

public Action ResetSprint(int client)
{
	if (g_hTimerSprint[client] != null)
	{
		KillTimer(g_hTimerSprint[client]);
		g_hTimerSprint[client] = null;
	}

	if (GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 1)
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}

	if (g_iSprintStatus[client] & IsSprintUsing)
	{
		g_iSprintStatus[client] &= ~ IsSprintUsing;
	}

	return;
}

public Action Timer_SprintEnd(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	g_hTimerSprint[client] = null;

	if (IsClientInGame(client) && (g_iSprintStatus[client] & IsSprintUsing))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		g_iSprintStatus[client] &= ~ IsSprintUsing;
		if (IsPlayerAlive(client) && GetClientTeam(client) > 1)
		{
			g_hTimerSprint[client] = CreateTimer(gc_iSprintCooldown.FloatValue, Timer_SprintCooldown, userid);
			CPrintToChat(client, "%s %t", g_sPrefix, "suicidebomber_sprintend", gc_iSprintCooldown.IntValue);
		}
	}

	return;
}

public Action Timer_SprintCooldown(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	g_hTimerSprint[client] = null;

	if (IsClientInGame(client) && (g_iSprintStatus[client] & IsSprintCoolDown))
	{
		g_iSprintStatus[client] &= ~ IsSprintCoolDown;
		CPrintToChat(client, "%s %t", g_sPrefix, "suicidebomber_sprintagain", gc_iSprintCooldown.IntValue);
	}

	return;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	ResetSprint(client);
	g_iSprintStatus[client] &= ~ IsSprintCoolDown;

	return;
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