/*
 * MyJailbreak - Deal Damage Event Day Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: 8guawong
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

#define TEAM_BLUE 1
#define TEAM_RED 2

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <mystocks>
#include <smartdm>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <hosties>
#include <lastrequest>
#include <warden>
#include <myjbwarden>
#include <myjailbreak>
#include <myweapons>
#include <myicons>
#include <CustomPlayerSkins>
#include <smartjaildoors>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsTruce = false;
bool g_bIsDealDamage = false;
bool g_bStartDealDamage = false;
bool g_bIsRoundEnd = true;

// Plugin bools
bool gp_bWarden;
bool gp_bMyJBWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bCustomPlayerSkins;
bool gp_bMyJailbreak;
bool gp_bMyIcons;
bool gp_bMyWeapons;

// Console Variables    gc_i = global convar integer / gc_b = global convar bool ...
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bSetW;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bSpawnCell;
ConVar gc_bVote;
ConVar gc_fBeaconTime;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_iRounds;
ConVar gc_sSoundStartPath;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_bChat;
ConVar gc_bConsole;
ConVar gc_bShowPanel;
ConVar gc_bSpawnRandom;
ConVar gc_sAdminFlag;
ConVar gc_bKillLoser;

ConVar gc_bModel;
ConVar gc_sModelPathBlue;
ConVar gc_sModelPathRed;
ConVar gc_bColor;
ConVar gc_sOverlayBluePath;
ConVar gc_sOverlayRedPath;

ConVar gc_bBeginSetA;
ConVar gc_bBeginSetW;
ConVar gc_bBeginSetV;
ConVar gc_bBeginSetVW;
ConVar gc_bTeleportSpawn;


// Extern Convars
ConVar g_bHUD;

// Integers    g_i = global integer
int g_iOldHUD;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iDamageBLUE;
int g_iDamageRED;
int g_iDamageDealed[MAXPLAYERS+1];
int g_iBestRED = -1;
int g_iBestBLUE = -1;
int g_iBestREDdamage = 0;
int g_iBestBLUEdamage = 0;
int g_iBestPlayer = -1;
int g_iTotalDamage = 0;
int g_iClientTeam[MAXPLAYERS+1] = -1;
int g_iBlueTeamCount;
int g_iRedTeamCount;

// Handles
Handle g_hTimerTruce;
Handle g_hTimerBeacon;

// Strings    g_s = global string
char g_sPrefix[64];
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sOverlayStartPath[256];
char g_sOverlayBluePath[256];
char g_sOverlayRedPath[256];
char g_sModelPathBlue[256];
char g_sModelPathRed[256];
char g_sModelPathPrevious[MAXPLAYERS+1][256];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - DealDamage",
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
	LoadTranslations("MyJailbreak.DealDamage.phrases");

	// Client Commands
	RegConsoleCmd("sm_setdealdamage", Command_SetDealDamage, "Allows the Admin or Warden to set dealdamage as next round");
	RegConsoleCmd("sm_dealdamage", Command_VoteDealDamage, "Allows players to vote for a dealdamage");

	// AutoExecConfig
	AutoExecConfig_SetFile("DealDamage", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_dealdamage_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_dealdamage_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_dealdamage_prefix", "[{green}MyJB.DealDamage{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_dealdamage_cmds_vote", "dd, damage, deal", "Set your custom chat command for Event voting(!dealdamage (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_dealdamage_cmds_set", "sdd, sdeal, sdamage", "Set your custom chat command for set Event(!setdealdamage (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_dealdamage_warden", "1", "0 - disabled, 1 - allow warden to set dealdamage round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_dealdamage_admin", "1", "0 - disabled, 1 - allow admin/vip to set dealdamage round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_dealdamage_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_dealdamage_vote", "1", "0 - disabled, 1 - allow player to vote for dealdamage", _, true, 0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_dealdamage_spawn", "1", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true, 0.0, true, 1.0);
	gc_bSpawnRandom = AutoExecConfig_CreateConVar("sm_dealdamage_randomspawn", "1", "0 - disabled, 1 - use random spawns on map (sm_dealdamage_spawn 1)", _, true, 0.0, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_dealdamage_begin_admin", "1", "When admin set event (!setdealdamage) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_dealdamage_begin_warden", "1", "When warden set event (!setdealdamage) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_dealdamage_begin_vote", "0", "When users vote for event (!dealdamage) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_dealdamage_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bTeleportSpawn = AutoExecConfig_CreateConVar("sm_dealdamage_teleport_spawn", "0", "0 - start event in current round from current player positions, 1 - teleport players to spawn when start event on current round(only when sm_*_begin_admin, sm_*_begin_warden, sm_*_begin_vote or sm_*_begin_daysvote is on '1')", _, true, 0.0, true, 1.0);
	gc_bKillLoser = AutoExecConfig_CreateConVar("sm_dealdamage_kill_loser", "0", "0 - disabled, 1 - Kill loserteam on event end", _, true, 0.0, true, 1.0);

	gc_bShowPanel = AutoExecConfig_CreateConVar("sm_dealdamage_panel", "1", "0 - disabled, 1 - enable show results on a Panel", _, true, 0.0, true, 1.0);
	gc_bChat = AutoExecConfig_CreateConVar("sm_dealdamage_chat", "1", "0 - disabled, 1 - enable print results in chat", _, true, 0.0, true, 1.0);
	gc_bConsole = AutoExecConfig_CreateConVar("sm_dealdamage_console", "1", "0 - disabled, 1 - enable print results in client console", _, true, 0.0, true, 1.0);
	gc_bColor = AutoExecConfig_CreateConVar("sm_dealdamage_color", "1", "0 - disabled, 1 - color the model of the players", _, true, 0.0, true, 1.0);
	gc_bModel = AutoExecConfig_CreateConVar("sm_dealdamage_model_enable", "1", "0 - disabled, 1 - enable model ", _, true, 0.0, true, 1.0);
	gc_sModelPathBlue = AutoExecConfig_CreateConVar("sm_dealdamage_model_blue", "models/player/prisoner/prisoner_new_blue.mdl", "Path to the model for team blue.");
	gc_sModelPathRed = AutoExecConfig_CreateConVar("sm_dealdamage_model_red", "models/player/prisoner/prisoner_new_red.mdl", "Path to the model for team red.");
	gc_iRounds = AutoExecConfig_CreateConVar("sm_dealdamage_rounds", "2", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_dealdamage_roundtime", "2", "Round time in minutes for a single dealdamage round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_dealdamage_beacon_time", "110", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_dealdamage_trucetime", "15", "Time in seconds players can't deal damage", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_dealdamage_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_dealdamage_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_dealdamage_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set dealdamage round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_dealdamage_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_dealdamage_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_dealdamage_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_dealdamage_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayBluePath = AutoExecConfig_CreateConVar("sm_dealdamage_overlays_blue", "overlays/MyJailbreak/blue", "Path to the blue Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayRedPath = AutoExecConfig_CreateConVar("sm_dealdamage_overlays_red", "overlays/MyJailbreak/red", "Path to the red Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayBluePath, OnSettingChanged);
	HookConVarChange(gc_sOverlayRedPath, OnSettingChanged);
	HookConVarChange(gc_sModelPathRed, OnSettingChanged);
	HookConVarChange(gc_sModelPathBlue, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// Find
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sOverlayBluePath.GetString(g_sOverlayBluePath, sizeof(g_sOverlayBluePath));
	gc_sOverlayRedPath.GetString(g_sOverlayRedPath, sizeof(g_sOverlayRedPath));
	gc_sModelPathRed.GetString(g_sModelPathRed, sizeof(g_sModelPathRed));
	gc_sModelPathBlue.GetString(g_sModelPathBlue, sizeof(g_sModelPathBlue));

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
	if (convar == gc_sModelPathRed)
	{
		if (gc_bModel.BoolValue)
		{
			strcopy(g_sModelPathRed, sizeof(g_sModelPathRed), newValue);
			Downloader_AddFileToDownloadsTable(g_sModelPathRed);
			PrecacheModel(g_sModelPathRed);
		}
	}
	else if (convar == gc_sModelPathBlue)
	{
		if (gc_bModel.BoolValue)
		{
			strcopy(g_sModelPathBlue, sizeof(g_sModelPathBlue), newValue);
			Downloader_AddFileToDownloadsTable(g_sModelPathBlue);
			PrecacheModel(g_sModelPathBlue);
		}
	}
	else if (convar == gc_sOverlayStartPath)    // Add overlay to download and precache table if changed
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayStartPath);
		}
	}
	else if (convar == gc_sOverlayBluePath)
	{
		strcopy(g_sOverlayBluePath, sizeof(g_sOverlayBluePath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayBluePath);
		}
	}
	else if (convar == gc_sOverlayRedPath)
	{
		strcopy(g_sOverlayRedPath, sizeof(g_sOverlayRedPath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayRedPath);
		}
	}
	else if (convar == gc_sSoundStartPath)    // Add sound to download and precache table if changed
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
	gp_bCustomPlayerSkins = LibraryExists("CustomPlayerSkins");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bMyJailbreak = LibraryExists("myjailbreak");
	gp_bMyWeapons = LibraryExists("myweapons");
	gp_bMyIcons = LibraryExists("myicons");
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
	else if (StrEqual(name, "CustomPlayerSkins"))
	{
		gp_bCustomPlayerSkins = false;
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
	else if (StrEqual(name, "myicons"))
	{
		gp_bMyIcons = false;
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
	else if (StrEqual(name, "CustomPlayerSkins"))
	{
		gp_bCustomPlayerSkins = true;
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
	else if (StrEqual(name, "myicons"))
	{
		gp_bMyIcons = true;
	}
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	// Find Convar Times
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;

	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sOverlayBluePath.GetString(g_sOverlayBluePath, sizeof(g_sOverlayBluePath));
	gc_sOverlayRedPath.GetString(g_sOverlayRedPath, sizeof(g_sOverlayRedPath));
	gc_sModelPathRed.GetString(g_sModelPathRed, sizeof(g_sModelPathRed));
	gc_sModelPathBlue.GetString(g_sModelPathBlue, sizeof(g_sModelPathBlue));

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
			RegConsoleCmd(sCommand, Command_VoteDealDamage, "Allows players to vote for a dealdamage");
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
			RegConsoleCmd(sCommand, Command_SetDealDamage, "Allows the Admin or Warden to set dealdamage as next round");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("dealdamage");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("dealdamage");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetDealDamage(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_disabled");

		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartEventRound(gc_bBeginSetVW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by groupvoting");
		}
	}
	else if (MyJB_CheckVIPFlags(client, "sm_dealdamage_flag", gc_sAdminFlag, "sm_dealdamage_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_setbyadmin");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetA.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by admin %L", client);
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
			CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_setbywarden");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteDealDamage(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_disabled");

		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_voting");

		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_progress", EventDay);

			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_wait", g_iCoolDown);

		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "dealdamage_voted");

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
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_need", Missing, client);
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

	if (!g_bStartDealDamage && !g_bIsDealDamage)
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

	g_bIsDealDamage = true;
	g_bStartDealDamage = false;

	PrepareDay(false);
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = true;

	if (g_bIsDealDamage) // if event was running this round
	{
		CalcResults();
		
		if (gc_bKillLoser.BoolValue)
		{
			if (g_iDamageBLUE > g_iDamageRED) 
			{

				for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (g_iClientTeam[i] == TEAM_RED)
				{
					ForcePlayerSuicide(i);
				}
			}
			else if (g_iDamageBLUE < g_iDamageRED)
			{

				for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (g_iClientTeam[i] == TEAM_BLUE)
				{
					ForcePlayerSuicide(i);
				}
			}
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
			SetEntityModel(i, g_sModelPathPrevious[i]);
			if (gp_bCustomPlayerSkins) UnhookGlow(i);
			CreateTimer(0.5, DeleteOverlay, GetClientUserId(i));
			g_iClientTeam[i] = 0;
			if (gp_bMyIcons)
			{
				MyIcons_BlockClientIcon(i, false);
			}
		}

		delete g_hTimerTruce; // kill start time if still running
		delete g_hTimerBeacon;
		g_iTruceTime = gc_iTruceTime.IntValue;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "dealdamage_twin_nc", g_iDamageRED);
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "dealdamage_ctwin_nc", g_iDamageBLUE);
		}

		if (g_iRound == g_iMaxRound) // if this was the last round
		{
			// return to default start values
			g_bIsDealDamage = false;
			g_bStartDealDamage = false;
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

			if (gc_bSpawnRandom.BoolValue)
			{
				SetCvar("mp_randomspawn", 0);
				SetCvar("mp_randomspawn_los", 0);
			}

			if (gp_bMyWeapons)
			{
				MyWeapons_AllowTeam(CS_TEAM_T, false);
				MyWeapons_AllowTeam(CS_TEAM_CT, true);
			}

			if (gp_bMyJailbreak)
			{
				SetCvar("sm_menu_enable", 1);

				MyJailbreak_SetEventDayRunning(false, winner);
				MyJailbreak_SetEventDayName("none"); // tell myjailbreak event is ended
			}

			SetCvar("sv_infinite_ammo", 0);
			SetCvar("sm_hud_enable", g_iOldHUD);

			CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_end");
		}
	}

	if (g_bStartDealDamage)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_next");
		PrintCenterTextAll("%t", "dealdamage_next_nc");
	}
}

public Action CS_OnTerminateRound(float &delay,  CSRoundEndReason &reason)
{
	if (g_bIsDealDamage)   // TODO: does this trigger??
	{
		reason = CSRoundEnd_Draw;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	// set default start values
	g_iVoteCount = 0; // how many player voted for the event
	g_iRound = 0;
	g_bIsDealDamage = false;
	g_bStartDealDamage = false;

	// Precache Sound & Overlay
	if (gc_bSounds.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
		PrecacheDecalAnyDownload(g_sOverlayBluePath);
		PrecacheDecalAnyDownload(g_sOverlayRedPath);
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}

	if (gc_bModel.BoolValue)
	{
		Downloader_AddFileToDownloadsTable(g_sModelPathRed);
		Downloader_AddFileToDownloadsTable(g_sModelPathBlue);
		PrecacheModel(g_sModelPathBlue);
		PrecacheModel(g_sModelPathRed);
	}
}

// Map End
public void OnMapEnd()
{
	// return to default start values
	g_bIsDealDamage = false;
	g_bStartDealDamage = false;

	delete g_hTimerTruce; // kill start time if still running
	delete g_hTimerBeacon;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}


public void MyJailbreak_ResetEventDay()
{
	g_bStartDealDamage = false;

	if (g_bIsDealDamage)
		ResetEventDay();
}

void ResetEventDay()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default' // disbale noblock

		SetEntityModel(i, g_sModelPathPrevious[i]);

		if (gp_bCustomPlayerSkins)
		{
			UnhookGlow(i);
		}

		CreateTimer(0.5, DeleteOverlay, GetClientUserId(i));

		g_iClientTeam[i] = 0;

		if (gp_bMyIcons)
		{
			MyIcons_BlockClientIcon(i, false);
		}

		SetEntityMoveType(i, MOVETYPE_WALK);

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		EnableWeaponFire(i, true);
	}

	delete g_hTimerTruce; // kill start time if still running
	delete g_hTimerBeacon;
	g_iTruceTime = gc_iTruceTime.IntValue;

	// return to default start values
	g_bIsDealDamage = false;
	g_bStartDealDamage = false;
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

	if (gc_bSpawnRandom.BoolValue)
	{
		SetCvar("mp_randomspawn", 0);
		SetCvar("mp_randomspawn_los", 0);
	}

	if (gp_bMyWeapons)
	{
		MyWeapons_AllowTeam(CS_TEAM_T, false);
		MyWeapons_AllowTeam(CS_TEAM_CT, true);
	}

	if (gp_bMyJailbreak)
	{
		SetCvar("sm_menu_enable", 1);

		MyJailbreak_SetEventDayRunning(false, 0);
		MyJailbreak_SetEventDayName("none"); // tell myjailbreak event is ended
	}

	SetCvar("sv_infinite_ammo", 0);
	SetCvar("sm_hud_enable", g_iOldHUD);

	CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_end");
}

// Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
}

public Action OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false) || !g_bIsDealDamage)
		return Plugin_Continue;

	if (g_iClientTeam[attacker] == TEAM_BLUE && g_iClientTeam[victim] == TEAM_RED && !g_bIsTruce)
	{
		g_iDamageBLUE = g_iDamageBLUE + RoundToCeil(damage);
	}

	if (g_iClientTeam[attacker] == TEAM_RED && g_iClientTeam[victim] == TEAM_BLUE && !g_bIsTruce)
	{
		g_iDamageRED = g_iDamageRED + RoundToCeil(damage);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		PrintHintText(i, "<font face='Arial' color='#0055FF'>%t  </font> %i %t \n<font face='Arial' color='#FF0000'>%t  </font> %i %t \n<font face='Arial' color='#00FF00'>%t  </font> %i %t", "dealdamage_ctdealed", g_iDamageBLUE, "dealdamage_hpdamage", "dealdamage_tdealed", g_iDamageRED, "dealdamage_hpdamage", "dealdamage_clientdealed", g_iDamageDealed[i], "dealdamage_hpdamage");
	}

	if (g_iClientTeam[attacker] !=  g_iClientTeam[victim])
	{
		g_iDamageDealed[attacker] = g_iDamageDealed[attacker] + RoundToCeil(damage);
	}

	return Plugin_Handled;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Prepare Event
void StartEventRound(bool thisround)
{
	g_iCoolDown = gc_iCooldownDay.IntValue;
	g_iVoteCount = 0;

	g_bHUD = FindConVar("sm_hud_enable");
	if (g_bHUD != null)
		g_iOldHUD = g_bHUD.IntValue;

	if (gp_bMyJailbreak)
	{
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "dealdamage_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsDealDamage = true;
		g_bIsTruce = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			EnableWeaponFire(i, false);

			SetEntityMoveType(i, MOVETYPE_NONE);
		}

		CreateTimer(3.0, Timer_PrepareEvent);

		CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_now");
		PrintCenterTextAll("%t", "dealdamage_now_nc");
	}
	else
	{
		g_bStartDealDamage = true;
		g_iCoolDown++;

		CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_next");
		PrintCenterTextAll("%t", "dealdamage_next_nc");
	}

	if (gc_bSpawnRandom.BoolValue)
	{
		SetCvar("mp_randomspawn", 1);
		SetCvar("mp_randomspawn_los", 1);
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	if (!g_bIsDealDamage)
		return Plugin_Handled;

	PrepareDay(true);

	return Plugin_Handled;
}

void PrepareDay(bool thisround)
{
	g_iRound++;

	bool bFlip = view_as<bool>(GetRandomInt(0,1));
	g_iBlueTeamCount = 0;
	g_iRedTeamCount = 0;

	g_iBestRED = 0;
	g_iBestBLUE = 0;
	g_iBestREDdamage = 0;
	g_iBestBLUEdamage = 0;
	g_iBestPlayer = 0;
	g_iDamageBLUE = 0;
	g_iDamageRED = 0;
	g_iTotalDamage = 0;

	if (gp_bSmartJailDoors)
	{
		SJD_OpenDoors();
	}

	if ((thisround && gc_bTeleportSpawn.BoolValue) || !gc_bSpawnCell.BoolValue || !gp_bSmartJailDoors || (gc_bSpawnCell.BoolValue && (SJD_IsCurrentMapConfigured() != true))) // spawn Terrors to CT Spawn 
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

				if (gc_bSpawnCell.BoolValue || !gp_bSmartJailDoors || (gp_bSmartJailDoors && (SJD_IsCurrentMapConfigured() != true)))
				{
					TeleportEntity(i, g_fPosCT, NULL_VECTOR, NULL_VECTOR);
				}
				else if (g_iClientTeam[i] == TEAM_BLUE)
				{
					TeleportEntity(i, g_fPosT, NULL_VECTOR, NULL_VECTOR);
				}
				else if (g_iClientTeam[i] == TEAM_RED)
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

		SetEntityMoveType(i, MOVETYPE_NONE);

		g_iDamageDealed[i] = 0;

		if (bFlip)
		{
			g_iClientTeam[i] = TEAM_BLUE;
			g_iBlueTeamCount++;
			bFlip = false;
			if (gc_bColor.BoolValue) SetEntityRenderColor(i, 0, 0, 240, 0);
			CPrintToChat(i, "%s %t", g_sPrefix, "dealdamage_teamblue");
			CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_playerteamblue", i);
			PrintCenterText(i, "%t \n<font face='Arial' color='#0000FF'>%t</font>", "dealdamage_start_nc", "dealdamage_teamblue_nc");
			if (gc_bOverlays.BoolValue)ShowOverlay(i, g_sOverlayBluePath, 0.0);
		}
		else
		{
			g_iClientTeam[i] = TEAM_RED;
			g_iRedTeamCount++;
			bFlip = true;
			if (gc_bColor.BoolValue) SetEntityRenderColor(i, 240, 0, 0, 0);
			CPrintToChat(i, "%s %t", g_sPrefix, "dealdamage_teamred");
			CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_playerteamred", i);
			PrintCenterText(i, "%t \n<font face='Arial' color='#FF0000'>%t</font>", "dealdamage_start_nc", "dealdamage_teamred_nc");
			if (gc_bOverlays.BoolValue)ShowOverlay(i, g_sOverlayRedPath, 0.0);
		}

		CreateInfoPanel(i);

		if (gp_bMyIcons)
		{
			MyIcons_BlockClientIcon(i, true);
		}

		if (gc_bModel.BoolValue)
		{
			CreateTimer (1.1, Timer_SetModel, GetClientUserId(i));
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
		MyWeapons_AllowTeam(CS_TEAM_T, true);
		MyWeapons_AllowTeam(CS_TEAM_CT, true);
	}

	CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_rounds", g_iRound, g_iMaxRound);

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	SetCvar("sm_hud_enable", 0); 

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
	if (g_iClientTeam[client] == TEAM_BLUE)
	{
		Format(info, sizeof(info), "%T", "dealdamage_info_blueteam", client);
	}
	else if (g_iClientTeam[client] == TEAM_RED)
	{
		Format(info, sizeof(info), "%T", "dealdamage_info_redteam", client);
	}
	else
	{
		Format(info, sizeof(info), "%T", "dealdamage_info_line1", client);
	}
	InfoPanel.DrawText("                                   ");
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "dealdamage_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line7", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	Format(info, sizeof(info), "%T", "warden_close", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_NullCancel, 20); // open info Panel

	delete InfoPanel;
}

void SendResults(int client)
{
	char info[128];

	Panel InfoPanel = new Panel();
	Format(info, sizeof(info), "%t", "dealdamage_result");
	InfoPanel.SetTitle(info);

	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_result");
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%t", "dealdamage_total", g_iTotalDamage);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_total", g_iTotalDamage);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_most", g_iBestPlayer, g_iDamageDealed[g_iBestPlayer]);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_most", g_iBestPlayer, g_iDamageDealed[g_iBestPlayer]);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%t", "dealdamage_ct", g_iDamageBLUE);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_ct", g_iDamageBLUE);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_t", g_iDamageRED);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_t", g_iDamageRED);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%t", "dealdamage_bestct", g_iBestBLUE, g_iBestBLUEdamage);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_bestct", g_iBestBLUE, g_iBestBLUEdamage);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_bestt", g_iBestRED, g_iBestREDdamage);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_bestt", g_iBestRED, g_iBestREDdamage);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_client", g_iDamageDealed[client]);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%s %t", g_sPrefix, "dealdamage_client", g_iDamageDealed[client]);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);

	if (gc_bShowPanel.BoolValue) InfoPanel.Send(client, Handler_NullCancel, 20); // open info Panel

	delete InfoPanel;
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Start Timer
public Action Timer_StartEvent(Handle timer)
{
	g_iTruceTime--;

	if (g_iTruceTime > 0) // countdown to start
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

		PrintCenterTextAll("%t", "dealdamage_timeuntilstart_nc", g_iTruceTime);

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

	PrintCenterTextAll("%t", "dealdamage_start_nc");
	CPrintToChatAll("%s %t", g_sPrefix, "dealdamage_start");

	CreateTimer(2.2, Timer_Overlay);

	g_hTimerTruce = null;

	g_bIsTruce = false;

	return Plugin_Stop;
}

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

void CalcResults()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (g_iClientTeam[i] == TEAM_BLUE && (g_iDamageDealed[i] > g_iBestBLUEdamage))
		{
			g_iBestBLUEdamage = g_iDamageDealed[i];
			g_iBestBLUE = i;
		}
		else if (g_iClientTeam[i] == TEAM_RED && (g_iDamageDealed[i] > g_iBestREDdamage))
		{
			g_iBestREDdamage = g_iDamageDealed[i];
			g_iBestRED = i;
		}
	}

	if (g_iBestBLUEdamage > g_iBestREDdamage)
	{
		g_iBestPlayer = g_iBestBLUE;
	}
	else g_iBestPlayer = g_iBestRED;

	g_iTotalDamage = g_iDamageBLUE + g_iDamageRED;

	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true))
	{
		SendResults(i);
	}

	if (MyJailbreak_ActiveLogging())
	{
		LogToFileEx(g_sEventsLogFile, "Damage Deal Result: Best Blue: %N Dmg: %i Best Red: %N Dmg: %i CT Damage: %i T Damage: %i Total Damage: %i", g_iBestBLUE, g_iBestBLUEdamage, g_iBestRED, g_iBestREDdamage, g_iDamageBLUE, g_iDamageRED, g_iTotalDamage);
	}
}

// Perpare client for glow
void SetupGlowSkin(int client)
{
	char sModel[PLATFORM_MAX_PATH];
	GetClientModel(client, sModel, sizeof(sModel));

	int iSkin = CPS_SetSkin(client, sModel, CPS_RENDER);
	if (iSkin == -1)
	{
		return;
	}

	if (SDKHookEx(iSkin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin))
	{
		GlowSkin(client, iSkin);
	}
}

// set client glow
void GlowSkin(int client, int iSkin)
{
	int iOffset;

	if ((iOffset = GetEntSendPropOffs(iSkin, "m_clrGlow")) == -1)
		return;

	SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(iSkin, Prop_Send, "m_nGlowStyle", 1);
	SetEntPropFloat(iSkin, Prop_Send, "m_flGlowMaxDist", 10000000.0);

	int iRed = 255;
	int iGreen = 255;
	int iBlue = 255;

	if (g_iClientTeam[client] == TEAM_BLUE)
	{
		iRed = 0;
		iGreen = 0;
		iBlue = 255;
	}
	else if (g_iClientTeam[client] == TEAM_RED)
	{
		iRed = 255;
		iGreen = 0;
		iBlue = 0;
	}

	SetEntData(iSkin, iOffset, iRed, _, true);
	SetEntData(iSkin, iOffset + 1, iGreen, _, true);
	SetEntData(iSkin, iOffset + 2, iBlue, _, true);
	SetEntData(iSkin, iOffset + 3, 255, _, true);
}

// Who can see the glow if vaild
public Action OnSetTransmit_GlowSkin(int iSkin, int client)
{
	if (!IsPlayerAlive(client))
		return Plugin_Handled;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (!CPS_HasSkin(i))
		{
			continue;
		}

		if (EntRefToEntIndex(CPS_GetSkin(i)) != iSkin)
		{
			continue;
		}

		return Plugin_Continue;
	}

	return Plugin_Handled;
}

// remove glow
void UnhookGlow(int client)
{
	if (IsValidClient(client, false, true))
	{
		int iSkin = CPS_GetSkin(client);
		if (iSkin != INVALID_ENT_REFERENCE)
		{
			SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", false, true);
			SDKUnhook(iSkin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin);
		}
	}
}


public Action Timer_SetModel(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	
	if (!client)
		return Plugin_Stop;
		
	GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPathPrevious[client], sizeof(g_sModelPathPrevious[]));

	if (g_iClientTeam[client] == TEAM_BLUE)
	{
		SetEntityModel(client, g_sModelPathBlue);
	}
	else if (g_iClientTeam[client] == TEAM_RED)
	{
		SetEntityModel(client, g_sModelPathRed);
	}

	if (gp_bCustomPlayerSkins) SetupGlowSkin(client);
	
	return Plugin_Stop;
}


public Action Timer_Overlay(Handle timer, int client)
{
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
	{
		if (g_iClientTeam[i] == TEAM_BLUE)
		{
			PrintCenterText(i, "%t \n<font face='Arial' color='#0000FF'>%t</font>", "dealdamage_start_nc", "dealdamage_teamblue_nc");
			if (gc_bOverlays.BoolValue)ShowOverlay(i, g_sOverlayBluePath, 0.0);
		}
		else if (g_iClientTeam[i] == TEAM_RED)
		{
			PrintCenterText(i, "%t \n<font face='Arial' color='#FF0000'>%t</font>", "dealdamage_start_nc", "dealdamage_teamred_nc");
			if (gc_bOverlays.BoolValue)ShowOverlay(i, g_sOverlayRedPath, 0.0);
		}
	}
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