/*
 * MyJailbreak - Torch Relay Plugin.
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
#include <smartjaildoors>
#include <CustomPlayerSkins>
#include <myjailbreak>
#include <myweapons>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Defines
#define IsSprintUsing   (1<<0)
#define IsSprintCoolDown  (1<<1)

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsTorch = false;
bool g_bStartTorch = false;
bool g_bOnTorch[MAXPLAYERS+1] = {false, ...};
bool g_bImmuneTorch[MAXPLAYERS+1] = {false, ...};
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
ConVar gc_bOverlays;
ConVar gc_bStayOverlay;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iRoundTime;
ConVar gc_bSpawnCell;
ConVar gc_iTruceTime;
ConVar gc_sOverlayOnTorch;
ConVar gc_bWallhack;
ConVar gc_bSprintUse;
ConVar gc_iSprintCooldown;
ConVar gc_bSprint;
ConVar gc_fSprintSpeed;
ConVar gc_fSprintTime;
ConVar gc_sSoundStartPath;
ConVar gc_sOverlayStartPath;
ConVar gc_sSoundOnTorchPath;
ConVar gc_sSoundClearTorchPath;
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
int g_iTruceTime;
int g_iRound;
int g_iSprintStatus[MAXPLAYERS+1];
int g_iMaxRound;
int g_iBurningZero = -1;

// Handles
Handle g_hTimerSprint[MAXPLAYERS+1];
Handle g_hTimerTruce;

// Strings
char g_sPrefix[64];
char g_sSoundClearTorchPath[256];
char g_sSoundOnTorchPath[256];
char g_sHasVoted[1500];
char g_sOverlayOnTorch[256];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sOverlayStartPath[256];

// Floats
float g_fPos[3];

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - Torch Relay",
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
	LoadTranslations("MyJailbreak.Torch.phrases");

	// Client Commands
	RegConsoleCmd("sm_settorch", Command_SetTorch, "Allows the Admin or Warden to set torch as next round");
	RegConsoleCmd("sm_torch", Command_VoteTorch, "Allows players to vote for a torch ");
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Start sprinting!");

	// AutoExecConfig
	AutoExecConfig_SetFile("Torch", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_torch_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_torch_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_torch_prefix", "[{green}MyJB.TorchRelay{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_torch_cmds_vote", "tor", "Set your custom chat command for Event voting(!torch (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_torch_cmds_set", "storch, stor", "Set your custom chat command for set Event(!settorch (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_torch_warden", "1", "0 - disabled, 1 - allow warden to set torch round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_torch_admin", "1", "0 - disabled, 1 - allow admin/vip to set torch round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_torch_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_torch_vote", "1", "0 - disabled, 1 - allow player to vote for torch", _, true, 0.0, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_torch_begin_admin", "1", "When admin set event (!settorch) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_torch_begin_warden", "1", "When warden set event (!settorch) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_torch_begin_vote", "0", "When users vote for event (!torch) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_torch_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bTeleportSpawn = AutoExecConfig_CreateConVar("sm_torch_teleport_spawn", "0", "0 - start event in current round from current player positions, 1 - teleport players to spawn when start event on current round(only when sm_*_begin_admin, sm_*_begin_warden, sm_*_begin_vote or sm_*_begin_daysvote is on '1')", _, true, 0.0, true, 1.0);

	gc_iRounds = AutoExecConfig_CreateConVar("sm_torch_rounds", "3", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_torch_roundtime", "9", "Round time in minutes for a single torch round", _, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_torch_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_torch_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_torch_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set torch round", _, true, 0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_torch_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true, 0.0, true, 1.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_torch_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_torch_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayOnTorch = AutoExecConfig_CreateConVar("sm_torch_overlaytorch_path", "overlays/MyJailbreak/fire", "Path to the g_bOnTorch Overlay DONT TYPE .vmt or .vft");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_torch_trucetime", "10", "Time in seconds players can't deal damage", _, true, 0.0);
	gc_bWallhack = AutoExecConfig_CreateConVar("sm_torch_wallhack", "1", "0 - disabled, 1 - enable wallhack for the torch to find enemeys", _, true, 0.0, true, 1.0);
	gc_bStayOverlay = AutoExecConfig_CreateConVar("sm_torch_stayoverlay", "1", "0 - overlays will removed after 3sec., 1 - overlays will stay until untorch", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_torch_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_torch_sounds_start", "music/MyJailbreak/burn.mp3", "Path to the soundfile which should be played for a start.");
	gc_sSoundOnTorchPath = AutoExecConfig_CreateConVar("sm_torch_sounds_torch", "music/MyJailbreak/fire.mp3", "Path to the soundfile which should be played on torch.");
	gc_sSoundClearTorchPath = AutoExecConfig_CreateConVar("sm_torch_sounds_untorch", "music/MyJailbreak/water.mp3", "Path to the soundfile which should be played on untorch.");
	gc_bSprint = AutoExecConfig_CreateConVar("sm_torch_sprint_enable", "1", "0 - disabled, 1 - enable ShortSprint", _, true, 0.0, true, 1.0);
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_torch_sprint_button", "1", "0 - disabled, 1 - enable +use button for sprint", _, true, 0.0, true, 1.0);
	gc_iSprintCooldown= AutoExecConfig_CreateConVar("sm_torch_sprint_cooldown", "10", "Time in seconds the player must wait for the next sprint", _, true, 0.0);
	gc_fSprintSpeed = AutoExecConfig_CreateConVar("sm_torch_sprint_speed", "1.25", "Ratio for how fast the player will sprint", _, true, 1.01);
	gc_fSprintTime = AutoExecConfig_CreateConVar("sm_torch_sprint_time", "3.0", "Time in seconds the player will sprint", _, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_team", Event_PlayerTeamDeath);
	HookEvent("player_death", Event_PlayerTeamDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayOnTorch, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundOnTorchPath, OnSettingChanged);
	HookConVarChange(gc_sSoundClearTorchPath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sSoundOnTorchPath.GetString(g_sSoundOnTorchPath, sizeof(g_sSoundOnTorchPath));
	gc_sSoundClearTorchPath.GetString(g_sSoundClearTorchPath, sizeof(g_sSoundClearTorchPath));
	gc_sOverlayOnTorch.GetString(g_sOverlayOnTorch, sizeof(g_sOverlayOnTorch));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));

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
	if (convar == gc_sSoundOnTorchPath)
	{
		strcopy(g_sSoundOnTorchPath, sizeof(g_sSoundOnTorchPath), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundOnTorchPath);
		}
	}
	else if (convar == gc_sSoundClearTorchPath)
	{
		strcopy(g_sSoundClearTorchPath, sizeof(g_sSoundClearTorchPath), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundClearTorchPath);
		}
	}
	else if (convar == gc_sOverlayOnTorch)
	{
		strcopy(g_sOverlayOnTorch, sizeof(g_sOverlayOnTorch), newValue);

		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayOnTorch);
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
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;

	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sSoundOnTorchPath.GetString(g_sSoundOnTorchPath, sizeof(g_sSoundOnTorchPath));
	gc_sSoundClearTorchPath.GetString(g_sSoundClearTorchPath, sizeof(g_sSoundClearTorchPath));
	gc_sOverlayOnTorch.GetString(g_sOverlayOnTorch, sizeof(g_sOverlayOnTorch));
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
			RegConsoleCmd(sCommand, Command_VoteTorch, "Allows players to vote for a torch ");
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
			RegConsoleCmd(sCommand, Command_SetTorch, "Allows the Admin or Warden to set torch as next round");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("torch");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("torch");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetTorch(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_disabled");

		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartEventRound(gc_bBeginSetVW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Torch Relay was started by groupvoting");
		}
	}
	else if (MyJB_CheckVIPFlags(client, "sm_torch_flag", gc_sAdminFlag, "sm_torch_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "torch_setbyadmin");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "torch_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "torch_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "torch_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetA.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Torch Relay was started by admin %L", client);
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
			CReplyToCommand(client, "%s %t", g_sPrefix, "torch_setbywarden");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "torch_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "torch_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "torch_wait", g_iCoolDown);

			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetW.BoolValue);

		if (!gp_bMyJailbreak)
			return Plugin_Handled;

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Torch Relay was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}


// Voting for Event
public Action Command_VoteTorch(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_disabled");

		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_voting");

		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_minplayer");

		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "torch_progress", EventDay);

			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_wait", g_iCoolDown);

		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_voted");

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
			LogToFileEx(g_sEventsLogFile, "Event Torch Relay was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%s %t", g_sPrefix, "torch_need", Missing, client);
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

	if (!g_bStartTorch && !g_bIsTorch)
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

	g_bIsTorch = true;
	g_bStartTorch = false;

	PrepareDay(false);
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = true;

	if (g_bIsTorch)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
		{
			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'

			CreateTimer(0.0, DeleteOverlay, GetClientUserId(i));

			SetEntityRenderColor(i, 255, 255, 255, 0);

			g_iSprintStatus[i] = 0;
			g_bOnTorch[i] = false;
			g_bImmuneTorch[i] = false;

			if (gp_bCustomPlayerSkins && gc_bWallhack.BoolValue)
			{
				UnhookWallhack(i);
			}
		}

		g_iBurningZero = -1;

		delete g_hTimerTruce;

		if (g_iRound == g_iMaxRound)
		{
			g_bIsTorch = false;
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

			if (gp_bMyJailbreak)
			{
				SetCvar("sm_menu_enable", 1);

				MyJailbreak_SetEventDayRunning(false, 0);
				MyJailbreak_SetEventDayName("none");
			}

			CPrintToChatAll("%s %t", g_sPrefix, "torch_end");
		}
	}

	if (g_bStartTorch)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "torch_next");
		PrintCenterTextAll("%t", "torch_next_nc");
	}
}

// Check for dying torch
public void Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsTorch)
	{
		return;
	}

	CheckStatus();

	ResetSprint(GetClientOfUserId(event.GetInt("userid")));
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	g_bIsTorch = false;
	g_bStartTorch = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundOnTorchPath);
		PrecacheSoundAnyDownload(g_sSoundClearTorchPath);
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
		PrecacheDecalAnyDownload(g_sOverlayOnTorch);
	}

	PrecacheSound("player/suit_sprint.wav", true);
}

public void MyJailbreak_ResetEventDay()
{
	g_bStartTorch = false;

	if (g_bIsTorch)
		ResetEventDay();
}

void ResetEventDay()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'

		CreateTimer(0.0, DeleteOverlay, GetClientUserId(i));

		SetEntityRenderColor(i, 255, 255, 255, 0);

		IgniteEntity(i, 0.0);

		g_iSprintStatus[i] = 0;
		g_bOnTorch[i] = false;
		g_bImmuneTorch[i] = false;

		if (gp_bCustomPlayerSkins && gc_bWallhack.BoolValue)
		{
			UnhookWallhack(i);
		}

		SetEntityMoveType(i, MOVETYPE_WALK);

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		EnableWeaponFire(i, true);
	}

	g_iBurningZero = -1;

	delete g_hTimerTruce;

	g_bIsTorch = false;
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

	if (gp_bMyJailbreak)
	{
		SetCvar("sm_menu_enable", 1);

		MyJailbreak_SetEventDayRunning(false, 0);
		MyJailbreak_SetEventDayName("none");
	}

	CPrintToChatAll("%s %t", g_sPrefix, "torch_end");
}

// Map End
public void OnMapEnd()
{
	g_bIsTorch = false;
	g_bStartTorch = false;
	g_iBurningZero = -1;

	delete g_hTimerTruce;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

public void OnClientPutInServer(int client)
{
	g_bOnTorch[client] = false;
	g_bImmuneTorch[client] = false;

	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
}

// Torch & g_bOnTorch
public Action OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (!IsValidClient(victim, true, false)|| attacker == victim || !IsValidClient(attacker, true, false))
		return Plugin_Continue;

	if (!g_bIsTorch)
		return Plugin_Continue;

	if (!g_bImmuneTorch[victim] && g_bOnTorch[attacker])
	{
		TorchEm(victim);
		ExtinguishEm(attacker);
	}

	return Plugin_Handled;
}

// Knife only
public Action OnWeaponCanUse(int client, int weapon)
{
	if (g_bIsTorch)
	{
		if (IsValidClient(client, true, false))
		{
			char sWeapon[32];
			GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

			if (!StrEqual(sWeapon, "weapon_knife"))
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void OnClientDisconnect_Post(int client)
{
	if (!g_bIsTorch)
	{
		return;
	}

	CheckStatus();
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
		Format(buffer, sizeof(buffer), "%T", "torch_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsTorch = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			EnableWeaponFire(i, false);

			SetEntityMoveType(i, MOVETYPE_NONE);
		}

		CreateTimer(3.0, Timer_PrepareEvent);

		CPrintToChatAll("%s %t", g_sPrefix, "torch_now");
		PrintCenterTextAll("%t", "torch_now_nc");
	}
	else
	{
		g_bStartTorch = true;
		g_iCoolDown++;

		CPrintToChatAll("%s %t", g_sPrefix, "torch_next");
		PrintCenterTextAll("%t", "torch_next_nc");
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	if (!g_bIsTorch)
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

	if ((thisround && gc_bTeleportSpawn.BoolValue) || !gc_bSpawnCell.BoolValue || !gp_bSmartJailDoors || (gc_bSpawnCell.BoolValue && (SJD_IsCurrentMapConfigured() != true))) // spawn Terrors to CT Spawn 
	{
		int RandomCT = 0;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				RandomCT = i;
				break;
			}
		}

		if (RandomCT)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				GetClientAbsOrigin(RandomCT, g_fPos);
				
				g_fPos[2] = g_fPos[2] + 5;
				
				TeleportEntity(i, g_fPos, NULL_VECTOR, NULL_VECTOR);
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
		
		StripAllPlayerWeapons(i);

		GivePlayerItem(i, "weapon_knife");

		CreateInfoPanel(i);

		g_iSprintStatus[i] = 0;
		g_bOnTorch[i] = false;
		g_bImmuneTorch[i] = false;
	}

	if (gp_bMyJailbreak)
	{
		SetCvar("sm_menu_enable", 0);

		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);
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

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	g_hTimerTruce = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);

	CPrintToChatAll("%s %t", g_sPrefix, "torch_rounds", g_iRound, g_iMaxRound);
}

// Set client as torch
void TorchEm(int client)
{
	g_bOnTorch[client] = true;

	ShowOverlay(client, g_sOverlayOnTorch, 0.0);

	SetEntityRenderColor(client, 255, 120, 0, 255);

	ExtinguishEntity(client);
	IgniteEntity(client, 999.0);

	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToClientAny(client, g_sSoundOnTorchPath);
	}

	if (!gc_bStayOverlay.BoolValue)
	{
		CreateTimer(3.0, DeleteOverlay, GetClientUserId(client));
	}

	CPrintToChatAll("%s %t", g_sPrefix, "torch_torchem", client);
}

// remove client as torch
void ExtinguishEm(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		g_bImmuneTorch[i] = false;
	}

	g_bOnTorch[client] = false;
	g_bImmuneTorch[client] = true;

	ExtinguishEntity(client);
	SetEntityRenderColor(client, 0, 0, 0, 255);

	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);

	CreateTimer(0.0, DeleteOverlay, GetClientUserId(client));

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToClientAny(client, g_sSoundClearTorchPath);
	}

	CPrintToChatAll("%s %t", g_sPrefix, "torch_untorch", client);
}

// check is torch still alive
void CheckStatus()
{
	int number = 0;

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (IsPlayerAlive(i) && g_bOnTorch[i])
		number++;

	if (number == 0)
	{
		CS_TerminateRound(5.0, CSRoundEnd_Draw);
		CPrintToChatAll("%s %t", g_sPrefix, "torch_win");
	}
}

// Perpare client for wallhack
void Setup_WallhackSkin(int client)
{
	char sModel[PLATFORM_MAX_PATH];
	GetClientModel(client, sModel, sizeof(sModel));

	int iSkin = CPS_SetSkin(client, sModel, CPS_RENDER);
	if (iSkin == -1)
	{
		return;
	}

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

	int iRed = 155;
	int iGreen = 0;
	int iBlue = 10;

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

		if (!CPS_HasSkin(i) || !g_bOnTorch[client])
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
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "torch_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "torch_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "torch_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "torch_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "torch_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "torch_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "torch_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "torch_info_line7", client);
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

public Action Timer_StartEvent(Handle timer)
{
	if (g_iTruceTime > 0)
	{
		g_iTruceTime--;

		if (g_iTruceTime == gc_iTruceTime.IntValue-3)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, true, false))
					continue;

				SetEntityMoveType(i, MOVETYPE_WALK);
			}
		}

		PrintCenterTextAll("%t", "torch_damage_nc", g_iTruceTime);

		return Plugin_Continue;
	}

	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iBurningZero = GetRandomAlivePlayer();

	if (g_iBurningZero > 0)
	{
		CPrintToChatAll("%s %t", g_sPrefix, "torch_random", g_iBurningZero);

		SetEntityRenderColor(g_iBurningZero, 255, 120, 0, 255);
		g_bOnTorch[g_iBurningZero] = true;

		ShowOverlay(g_iBurningZero, g_sOverlayOnTorch, 0.0);

		IgniteEntity(g_iBurningZero, 200.0);
		SetEntPropFloat(g_iBurningZero, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);

		if (gc_bSounds.BoolValue)
		{
			EmitSoundToClientAny(g_iBurningZero, g_sSoundOnTorchPath);
		}

		if (!gc_bStayOverlay.BoolValue)
		{
			CreateTimer(3.0, DeleteOverlay, GetClientUserId(g_iBurningZero));
		}
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		if (gp_bCustomPlayerSkins && gc_bWallhack.BoolValue)
		{
			Setup_WallhackSkin(i);
		}

		if (i != g_iBurningZero)
		{
			SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

			if (gc_bOverlays.BoolValue)
			{
				ShowOverlay(i, g_sOverlayStartPath, 2.0);
			}
		}

		EnableWeaponFire(i, true);
	}

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sSoundStartPath);
	}

	g_hTimerTruce = null;

	PrintCenterTextAll("%t", "torch_start_nc");
	CPrintToChatAll("%s %t", g_sPrefix, "torch_start");

	return Plugin_Stop;
}

/******************************************************************************
                   SPRINT MODULE
******************************************************************************/

// Sprint
public Action Command_StartSprint(int client, int args)
{
	if (!g_bIsTorch)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_disabled");

		return Plugin_Handled;
	}

	if (!gc_bSprint.BoolValue || g_bOnTorch[client])
	{
		return Plugin_Handled;
	}

	if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1 && !(g_iSprintStatus[client] & IsSprintUsing) && !(g_iSprintStatus[client] & IsSprintCoolDown))
	{
		g_iSprintStatus[client] |= IsSprintUsing | IsSprintCoolDown;

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
		EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);

		CReplyToCommand(client, "%s %t", g_sPrefix, "torch_sprint");

		g_hTimerSprint[client] = CreateTimer(gc_fSprintTime.FloatValue, Timer_SprintEnd, GetClientUserId(client));
	}

	return Plugin_Handled;
}

public void OnGameFrame()
{
	if (!g_bIsTorch || !gc_bSprintUse.BoolValue)
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
			CPrintToChat(client, "%s %t", g_sPrefix, "torch_sprintend", gc_iSprintCooldown.IntValue);
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
		CPrintToChat(client, "%s %t", g_sPrefix, "torch_sprintagain", gc_iSprintCooldown.IntValue);
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