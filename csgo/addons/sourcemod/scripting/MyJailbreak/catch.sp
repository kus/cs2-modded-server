/*
 * MyJailbreak - Catch & Freeze Event Day Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: olegtsvetkov
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
#include <smartdm>
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
#include <smartjaildoors>
#include <CustomPlayerSkins>
#include <myjailbreak>
#include <myweapons>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Defines
#define IsSprintUsing    (1 << 0)
#define IsSprintCoolDown (1 << 1)

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsCatch = false;
bool g_bStartCatch = false;
bool g_bCatched[MAXPLAYERS+1] = {false, ...};
bool g_bIsRoundEnd = true;

// Plugin bools
bool gp_bWarden;
bool gp_bMyJBWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bCustomPlayerSkins;
bool gp_bMyJailbreak;
bool gp_bMyWeapons;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bVote;
ConVar gc_bSounds;
ConVar gc_sItemModel;
ConVar gc_bOverlays;
ConVar gc_bStayOverlay;
ConVar gc_sOverlayStartPath;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iRoundTime;
ConVar gc_bWallhack;
ConVar gc_fBeaconTime;
ConVar gc_iFreezeTime;
ConVar gc_sOverlayFreeze;
ConVar gc_bSprintUse;
ConVar gc_iSprintCooldown;
ConVar gc_bSprint;
ConVar gc_fSprintSpeed;
ConVar gc_fSprintTime;
ConVar gc_sSoundStartPath;
ConVar gc_sSoundFreezePath;
ConVar gc_sSoundUnFreezePath;
ConVar gc_iRounds;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;
ConVar gc_iCatchCount;
ConVar gc_bAllowLR;
ConVar gc_bKillLoser;

ConVar gc_bBeginSetA;
ConVar gc_bBeginSetW;
ConVar gc_bBeginSetV;
ConVar gc_bBeginSetVW;
ConVar gc_bTeleportSpawn;

// Extern Convars
ConVar g_iTerrorForLR;

// Integers
int g_iVoteCount;
int g_iCoolDown;
int g_iRound;
int g_iSprintStatus[MAXPLAYERS+1];
int g_iCatchCounter[MAXPLAYERS+1];
int g_iMaxRound;
int g_iFreezeTime;
int g_iTsLR;
int g_iIceEntity[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE, ...};

// Handles
Handle g_hTimerSprint[MAXPLAYERS+1];
Handle g_hTimerFreeze;
Handle g_hTimerBeacon;

// Strings
char g_sPrefix[64];
char g_sSoundUnFreezePath[256];
char g_sSoundFreezePath[256];
char g_sHasVoted[1500];
char g_sOverlayFreeze[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sSoundStartPath[256];
char g_sOverlayStartPath[256];
char g_sItemModel[64];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Catch & Freeze",
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
	LoadTranslations("MyJailbreak.Catch.phrases");

	// Client Commands
	RegConsoleCmd("sm_setcatch", Command_SetCatch, "Allows the Admin or Warden to set catch as next round");
	RegConsoleCmd("sm_catch", Command_VoteCatch, "Allows players to vote for a catch ");
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Start sprinting!");

	// AutoExecConfig
	AutoExecConfig_SetFile("Catch", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_catch_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_catch_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_catch_prefix", "[{green}MyJB.Catch{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_catch_cmds_vote", "cat, catchfreeze", "Set your custom chat command for Event voting(!catch (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_catch_cmds_set", "scat, scatchfreeze", "Set your custom chat command for set Event(!setcatch (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_catch_warden", "1", "0 - disabled, 1 - allow warden to set catch round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_catch_admin", "1", "0 - disabled, 1 - allow admin/vip to set catch round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_catch_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_catch_vote", "1", "0 - disabled, 1 - allow player to vote for catch", _, true, 0.0, true, 1.0);
	gc_iCatchCount = AutoExecConfig_CreateConVar("sm_catch_count", "0", "How many times a terror can be catched before he get killed. 0 = T dont get killed ever all T must be catched", _, true, 0.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_catch_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_bWallhack = AutoExecConfig_CreateConVar("sm_catch_wallhack", "1", "0 - disabled, 1 - enable wallhack for CT to see freezed enemeys", _, true,  0.0, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_catch_begin_admin", "1", "When admin set event (!setcatch) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_catch_begin_warden", "1", "When warden set event (!setcatch) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_catch_begin_vote", "0", "When users vote for event (!catch) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_catch_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bTeleportSpawn = AutoExecConfig_CreateConVar("sm_catch_teleport_spawn", "0", "0 - start event in current round from current player positions, 1 - teleport players to spawn when start event on current round(only when sm_*_begin_admin, sm_*_begin_warden, sm_*_begin_vote or sm_*_begin_daysvote is on '1')", _, true, 0.0, true, 1.0);

	gc_iRounds = AutoExecConfig_CreateConVar("sm_catch_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_catch_roundtime", "5", "Round time in minutes for a single catch round", _, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_catch_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_catch_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_catch_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set catch round", _, true, 0.0, true, 1.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_catch_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_catch_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayFreeze = AutoExecConfig_CreateConVar("sm_catch_overlayfreeze_path", "overlays/MyJailbreak/frozen", "Path to the Freeze Overlay DONT TYPE .vmt or .vft");
	gc_bStayOverlay = AutoExecConfig_CreateConVar("sm_catch_stayoverlay", "0", "0 - overlays will removed after 3sec., 1 - overlays will stay until unfreeze", _, true, 0.0, true, 1.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_catch_freezetime", "15", "Time in seconds CTs are freezed", _, true, 0.0);
	gc_sItemModel = AutoExecConfig_CreateConVar("sm_catch_model", "models/spree/spree.mdl", "path to the ice model");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_catch_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_catch_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_sSoundFreezePath = AutoExecConfig_CreateConVar("sm_catch_sounds_freeze", "music/MyJailbreak/freeze.mp3", "Path to the soundfile which should be played on freeze.");
	gc_sSoundUnFreezePath = AutoExecConfig_CreateConVar("sm_catch_sounds_unfreeze", "music/MyJailbreak/unfreeze.mp3", "Path to the soundfile which should be played on unfreeze.");
	gc_bSprint = AutoExecConfig_CreateConVar("sm_catch_sprint_enable", "1", "0 - disabled, 1 - enable ShortSprint", _, true, 0.0, true, 1.0);
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_catch_sprint_button", "1", "0 - disabled, 1 - enable +use button for sprint", _, true, 0.0, true, 1.0);
	gc_iSprintCooldown= AutoExecConfig_CreateConVar("sm_catch_sprint_cooldown", "10", "Time in seconds the player must wait for the next sprint", _, true, 0.0);
	gc_fSprintSpeed = AutoExecConfig_CreateConVar("sm_catch_sprint_speed", "1.25", "Ratio for how fast the player will sprint", _, true, 1.01);
	gc_fSprintTime = AutoExecConfig_CreateConVar("sm_catch_sprint_time", "3.0", "Time in seconds the player will sprint", _, true, 1.0);
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_catch_allow_lr", "0", "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);
	gc_bKillLoser = AutoExecConfig_CreateConVar("sm_catch_kill_loser", "0", "0 - disabled, 1 - Kill loserteam on event end / not for sm_catch_allow_lr '1'", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayFreeze, OnSettingChanged);
	HookConVarChange(gc_sSoundFreezePath, OnSettingChanged);
	HookConVarChange(gc_sSoundUnFreezePath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);
	HookConVarChange(gc_sItemModel, OnSettingChanged);

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_death", Event_PlayerTeam);

	// FindConVar
	g_iMaxRound = gc_iRounds.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sSoundFreezePath.GetString(g_sSoundFreezePath, sizeof(g_sSoundFreezePath));
	gc_sSoundUnFreezePath.GetString(g_sSoundUnFreezePath, sizeof(g_sSoundUnFreezePath));
	gc_sOverlayFreeze.GetString(g_sOverlayFreeze, sizeof(g_sOverlayFreeze));
	gc_sItemModel.GetString(g_sItemModel, sizeof(g_sItemModel));

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
	if (convar == gc_sSoundFreezePath)
	{
		strcopy(g_sSoundFreezePath, sizeof(g_sSoundFreezePath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundFreezePath);
		}
	}
	else if (convar == gc_sSoundUnFreezePath)
	{
		strcopy(g_sSoundUnFreezePath, sizeof(g_sSoundUnFreezePath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundUnFreezePath);
		}
	}
	else if (convar == gc_sOverlayFreeze)
	{
		strcopy(g_sOverlayFreeze, sizeof(g_sOverlayFreeze), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayFreeze);
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
	else if (convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayStartPath);
		}
	}
	else if (convar == gc_sItemModel)
	{
		strcopy(g_sItemModel, sizeof(g_sItemModel), newValue);
		Downloader_AddFileToDownloadsTable(g_sItemModel);
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
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	// FindConVar
	g_iMaxRound = gc_iRounds.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;

	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sSoundFreezePath.GetString(g_sSoundFreezePath, sizeof(g_sSoundFreezePath));
	gc_sSoundUnFreezePath.GetString(g_sSoundUnFreezePath, sizeof(g_sSoundUnFreezePath));
	gc_sOverlayFreeze.GetString(g_sOverlayFreeze, sizeof(g_sOverlayFreeze));
	gc_sItemModel.GetString(g_sItemModel, sizeof(g_sItemModel));

	// FindConVar
	if (gp_bHosties)
	{
		g_iTerrorForLR = FindConVar("sm_hosties_lr_ts_max");
	}

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
			RegConsoleCmd(sCommand, Command_VoteCatch, "Allows players to vote for a catch ");
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
			RegConsoleCmd(sCommand, Command_SetCatch, "Allows the Admin or Warden to set catch as next round");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("catch");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("catch");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetCatch(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_disabled");

		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartEventRound(gc_bBeginSetVW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Catch was started by groupvoting");
		}
	}
	else if (MyJB_CheckVIPFlags(client, "sm_catch_flag", gc_sAdminFlag, "sm_catch_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "catch_setbyadmin");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "catch_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "catch_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "catch_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetA.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Catch was started by admin %L", client);
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
			CReplyToCommand(client, "%s %t", g_sPrefix, "catch_setbywarden");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "catch_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "catch_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "catch_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Catch was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteCatch(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_disabled");

		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_voting");

		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_minplayer");

		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "catch_progress", EventDay);

			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_wait", g_iCoolDown);

		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_voted");

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
			LogToFileEx(g_sEventsLogFile, "Event Catch was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%s %t", g_sPrefix, "catch_need", Missing, client);
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

	if (!g_bStartCatch && !g_bIsCatch)
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

	g_bIsCatch = true;
	g_bStartCatch = false;

	PrepareDay(false);
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = true;

	if (g_bIsCatch)
	{
		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "catch_twin_nc");
		}
		else if (winner == 3)
		{
			PrintCenterTextAll("%t", "catch_ctwin_nc");
		}

		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
		{
			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'

			CreateTimer(0.0, DeleteOverlay, GetClientUserId(i));
			SetEntityRenderColor(i, 255, 255, 255, 0);

			g_iSprintStatus[i] = 0;
			g_bCatched[i] = false;
			
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				StripAllPlayerWeapons(i);
			}

			if (gc_bWallhack.BoolValue && gp_bCustomPlayerSkins)
			{
				UnhookWallhack(i);
			}

			if (gc_bKillLoser.BoolValue && GetClientTeam(i) != winner)
			{
				ForcePlayerSuicide(i);
			}
		}

		delete g_hTimerFreeze;
		delete g_hTimerBeacon;
		g_iFreezeTime = gc_iFreezeTime.IntValue;

		if (g_iRound == g_iMaxRound)
		{
			g_bIsCatch = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");

			if (gp_bMyJBWarden)
			{
				warden_enable(true);
			}

			if (gp_bHosties)
			{
				SetCvar("sm_hosties_lr", 1);
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
				MyJailbreak_SetEventDayName("none");
			}

			CPrintToChatAll("%s %t", g_sPrefix, "catch_end");
		}
	}

	if (g_bStartCatch)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "catch_next");
		PrintCenterTextAll("%t", "catch_next_nc");
	}
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsCatch)
		return;

	CheckStatus();

	int client = GetClientOfUserId(event.GetInt("userid"));

	g_bCatched[client] = false,
	ResetSprint(client);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	g_bIsCatch = false;
	g_bStartCatch = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundFreezePath);
		PrecacheSoundAnyDownload(g_sSoundUnFreezePath);
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayFreeze);
	}

	PrecacheModel(g_sItemModel);

	PrecacheSound("player/suit_sprint.wav", true);
}

// Map End
public void OnMapEnd()
{
	g_bIsCatch = false;
	g_bStartCatch = false;

	delete g_hTimerFreeze;
	delete g_hTimerBeacon;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

// Terror win Round if time runs out
public Action CS_OnTerminateRound(float &delay,  CSRoundEndReason &reason)
{
	if (g_bIsCatch)   // TODO: does this trigger??
	{
		if (reason == CSRoundEnd_Draw)
		{
			reason = CSRoundEnd_TerroristWin;
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

// Catch & Freeze
public Action OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (!g_bIsCatch)
		return Plugin_Continue;

	if (!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false))
		return Plugin_Continue;

	if (GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT && !g_bCatched[victim])
	{
		if (gc_iCatchCount.IntValue != 0 && g_iCatchCounter[victim] >= gc_iCatchCount.IntValue)
		{
			ForcePlayerSuicide(victim);
		}
		else
		{
			CatchEm(victim, attacker);
		}
	}
	else if (GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_T && g_bCatched[victim] && !g_bCatched[attacker])
	{
		FreeEm(victim, attacker);
	}

	CheckStatus();

	return Plugin_Handled;
}

public void OnClientDisconnect_Post(int client)
{
	if (!g_bIsCatch)
		return;

	CheckStatus();
}

// Set Client Hook
public void OnClientPutInServer(int client)
{
	g_bCatched[client] = false;

	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
}

// Knife only
public Action OnWeaponCanUse(int client, int weapon)
{
	if (!g_bIsCatch)
		return Plugin_Continue;

	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if (!StrEqual(sWeapon, "weapon_knife") && IsValidClient(client, true, false))
		return Plugin_Handled;

	return Plugin_Continue;
}

public void MyJailbreak_ResetEventDay()
{
	g_bStartCatch = false;

	if (g_bIsCatch)
	{
		g_iRound = g_iMaxRound;
		ResetEventDay();
	}
}

// Listen for Last Lequest
public void OnAvailableLR(int Announced)
{
	if (g_bIsCatch && gc_bAllowLR.BoolValue && (g_iTsLR > g_iTerrorForLR.IntValue))
	{
		ResetEventDay();
	}
}

void ResetEventDay()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, false, true))
			continue;

		g_iSprintStatus[i] = 0;
		g_bCatched[i] = false;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'

		CreateTimer(0.0, DeleteOverlay, GetClientUserId(i));

		SetEntityRenderColor(i, 255, 255, 255, 0);
		SetEntityHealth(i, 100);

		StripAllPlayerWeapons(i);

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			FakeClientCommand(i, "sm_weapons");
		}

		GivePlayerItem(i, "weapon_knife");

		if (gc_bWallhack.BoolValue && gp_bCustomPlayerSkins)
		{
			UnhookWallhack(i);
		}

		SetEntityMoveType(i, MOVETYPE_WALK);

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		EnableWeaponFire(i, true);
	}

	delete g_hTimerFreeze;
	delete g_hTimerBeacon;
	g_iFreezeTime = gc_iFreezeTime.IntValue;

	if (g_iRound == g_iMaxRound)
	{
		g_bIsCatch = false;
		g_iRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");

		SetCvar("sm_hosties_lr", 1);

		if (gp_bMyWeapons)
		{
			MyWeapons_AllowTeam(CS_TEAM_T, false);
			MyWeapons_AllowTeam(CS_TEAM_CT, true);
		}

		if (gp_bMyJBWarden)
		{
			warden_enable(false);
		}

		if (gp_bMyJailbreak)
		{
			SetCvar("sm_menu_enable", 1);

			MyJailbreak_SetEventDayName("none");
			MyJailbreak_SetEventDayRunning(false, 0);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "catch_end");
	}
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
		Format(buffer, sizeof(buffer), "%T", "catch_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsCatch = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			EnableWeaponFire(i, false);

			SetEntityMoveType(i, MOVETYPE_NONE);
		}

		CreateTimer(3.0, Timer_PrepareEvent);

		CPrintToChatAll("%s %t", g_sPrefix, "catch_now");
		PrintCenterTextAll("%t", "catch_now_nc");
	}
	else
	{
		g_bStartCatch = true;
		g_iCoolDown++;
		
		CPrintToChatAll("%s %t", g_sPrefix, "catch_next");
		PrintCenterTextAll("%t", "catch_next_nc");
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	if (!g_bIsCatch)
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

	if ((thisround && gc_bTeleportSpawn.BoolValue) || !gp_bSmartJailDoors || (gp_bSmartJailDoors && (SJD_IsCurrentMapConfigured() != true))) // spawn Terrors to CT Spawn 
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
		if (!IsClientInGame(i))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 2);  // 2 - none / 5 - 'default'

		SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

		EnableWeaponFire(i, false);

		SetEntityMoveType(i, MOVETYPE_NONE);

		CreateInfoPanel(i);

		StripAllPlayerWeapons(i);

		GivePlayerItem(i, "weapon_knife");

		g_iSprintStatus[i] = 0;
		g_iCatchCounter[i] = 0;
		g_bCatched[i] = false;
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

	if (gp_bHosties)
	{
		// enable lr on last round
		g_iTsLR = GetAlivePlayersCount(CS_TEAM_T);

		if (gc_bAllowLR.BoolValue)
		{
			if (g_iRound == g_iMaxRound && g_iTsLR > g_iTerrorForLR.IntValue)
			{
				SetCvar("sm_hosties_lr", 1);
			}
		}
	}

	CPrintToChatAll("%s %t", g_sPrefix, "catch_rounds", g_iRound, g_iMaxRound);

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	g_hTimerFreeze = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
}

void CatchEm(int client, int attacker)
{
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	SetEntityRenderColor(client, 0, 0, 205, 255);

	g_bCatched[client] = true;
	g_iCatchCounter[client] += 1;

	ShowOverlay(client, g_sOverlayFreeze, 0.0);

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sSoundFreezePath);
	}

	if (!gc_bStayOverlay.BoolValue)
	{
		CreateTimer(3.0, DeleteOverlay, GetClientUserId(client));
	}

	CPrintToChatAll("%s %t", g_sPrefix, "catch_catch", attacker, client);

	int iEntity = CreateEntityByName("prop_dynamic_override");

	if (iEntity == -1)
		return;

	SetEntityModel(iEntity, g_sItemModel);
	SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 2);

	float vec[3];
	GetClientAbsOrigin(client, vec);

	TeleportEntity(client, vec, NULL_VECTOR, NULL_VECTOR);
	TeleportEntity(iEntity, vec, NULL_VECTOR, NULL_VECTOR);
	g_iIceEntity[client] = EntIndexToEntRef(iEntity);
}


void FreeEm(int client, int attacker)
{
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 0);

	g_bCatched[client] = false;

	CreateTimer(0.0, DeleteOverlay, GetClientUserId(client));

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sSoundUnFreezePath);
	}

	CPrintToChatAll("%s %t", g_sPrefix, "catch_unfreeze", attacker, client);

	if (g_iIceEntity[client] == INVALID_ENT_REFERENCE)
		return;

	int iEntity = EntRefToEntIndex(g_iIceEntity[client]);
	if (iEntity == INVALID_ENT_REFERENCE)
		return;

	AcceptEntityInput(iEntity, "kill");
	g_iIceEntity[client] = INVALID_ENT_REFERENCE;
}


void CheckStatus()
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !g_bCatched[i])
		{
			count++;
		}
	}

	if (count == 0)
	{
		CS_TerminateRound(5.0, CSRoundEnd_CTWin);
		CPrintToChatAll("%s %t", g_sPrefix, "catch_win");
	}
}


// Perpare client for wallhack
void Setup_WallhackSkin(int client)
{
	char sModel[PLATFORM_MAX_PATH];
	GetClientModel(client, sModel, sizeof(sModel));

	int iSkin = CPS_SetSkin(client, sModel, CPS_RENDER);
	if (iSkin == -1)
		return;

	if (SDKHookEx(iSkin, SDKHook_SetTransmit, OnSetTransmit_Wallhack))
	{
		Setup_Wallhack(iSkin);
	}
}


// set client wallhacked
void Setup_Wallhack(int iSkin)
{
	int iOffset;

	if ((iOffset = GetEntSendPropOffs(iSkin, "m_clrGlow")) == -1)
		return;

	SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(iSkin, Prop_Send, "m_nGlowStyle", 0);
	SetEntPropFloat(iSkin, Prop_Send, "m_flGlowMaxDist", 10000000.0);

	int iRed = 60;
	int iGreen = 60;
	int iBlue = 200;

	SetEntData(iSkin, iOffset, iRed, _, true);
	SetEntData(iSkin, iOffset + 1, iGreen, _, true);
	SetEntData(iSkin, iOffset + 2, iBlue, _, true);
	SetEntData(iSkin, iOffset + 3, 255, _, true);
}

// Who can see wallhack if vaild
public Action OnSetTransmit_Wallhack(int iSkin, int client)
{
	if (!IsPlayerAlive(client) || GetClientTeam(client) != CS_TEAM_CT)
		return Plugin_Handled;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (!CPS_HasSkin(i) || !g_bCatched[i])
			continue;

		if (EntRefToEntIndex(CPS_GetSkin(i)) != iSkin)
			continue;

		return Plugin_Continue;
	}

	return Plugin_Handled;
}


// remove wallhack
void UnhookWallhack(int client)
{
	if (IsValidClient(client, false, true))
	{
		int iSkin = CPS_GetSkin(client);
		if (iSkin != INVALID_ENT_REFERENCE)
		{
			SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", false, true);
			SDKUnhook(iSkin, SDKHook_SetTransmit, OnSetTransmit_Wallhack);
		}
	}
}


/******************************************************************************
                   TIMER
******************************************************************************/

// Start Timer
public Action Timer_StartEvent(Handle timer)
{
	g_iFreezeTime--;

	if (g_iFreezeTime > 0)
	{
		if (g_iFreezeTime <= gc_iFreezeTime.IntValue - 3)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, true, false))
					continue;

				if (GetClientTeam(i) == CS_TEAM_T)
				{
					SetEntityMoveType(i, MOVETYPE_WALK);
				}
			}
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, false))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				PrintCenterText(i, "%t", "catch_timetounfreeze_nc", g_iFreezeTime);
			}
			else if (GetClientTeam(i) == CS_TEAM_T)
			{
				PrintCenterText(i, "%t", "catch_timeuntilstart_nc", g_iFreezeTime);
			}
		}

		return Plugin_Continue;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.4);
		}

		SetEntityMoveType(i, MOVETYPE_WALK);

		if (gc_bOverlays.BoolValue)
		{
			ShowOverlay(i, g_sOverlayStartPath, 2.0);
		}

		if (gc_bWallhack.BoolValue && gp_bCustomPlayerSkins)
		{
			Setup_WallhackSkin(i);
		}

		EnableWeaponFire(i, true);
	}

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sSoundStartPath);
	}

	PrintCenterTextAll("%t", "catch_start_nc");

	CPrintToChatAll("%s %t", g_sPrefix, "catch_start");

	g_hTimerFreeze = null;

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

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "catch_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "catch_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "catch_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "catch_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "catch_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "catch_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "catch_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "catch_info_line7", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	Format(info, sizeof(info), "%T", "warden_close", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_NullCancel, 20);
	delete InfoPanel;
}

/******************************************************************************
                   SPRINT MODULE
******************************************************************************/

// Sprint
public Action Command_StartSprint(int client, int args)
{
	if (!g_bIsCatch)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_disabled");

		return Plugin_Handled;
	}

	if (!gc_bSprint.BoolValue || GetClientTeam(client) != CS_TEAM_T || g_bCatched[client])
	{
		return Plugin_Handled;
	}

	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1 && !(g_iSprintStatus[client] & IsSprintUsing) && !(g_iSprintStatus[client] & IsSprintCoolDown))
	{
		g_iSprintStatus[client] |= IsSprintUsing | IsSprintCoolDown;

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
		EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);

		CReplyToCommand(client, "%s %t", g_sPrefix, "catch_sprint");

		g_hTimerSprint[client] = CreateTimer(gc_fSprintTime.FloatValue, Timer_SprintEnd, GetClientUserId(client));
	}

	return Plugin_Handled;
}

public void OnGameFrame()
{
	if (!g_bIsCatch || !gc_bSprintUse.BoolValue)
	{
		return;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (GetClientButtons(i) & IN_USE)
		{
			Command_StartSprint(i, 0);
		}
	}
}

void ResetSprint(int client)
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
			CPrintToChat(client, "%s %t", g_sPrefix, "catch_sprintend", gc_iSprintCooldown.IntValue);
		}
	}

	return Plugin_Handled;
}

public Action Timer_SprintCooldown(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	g_hTimerSprint[client] = null;

	if (IsClientInGame(client) && (g_iSprintStatus[client] & IsSprintCoolDown))
	{
		g_iSprintStatus[client] &= ~ IsSprintCoolDown;
		CPrintToChat(client, "%s %t", g_sPrefix, "catch_sprintagain", gc_iSprintCooldown.IntValue);
	}

	return Plugin_Handled;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	ResetSprint(client);
	g_iSprintStatus[client] &= ~ IsSprintCoolDown;
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