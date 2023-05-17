/*
 * MyJailbreak - Zombie Event Day Plugin.
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
#include <smartjaildoors>
#include <CustomPlayerSkins>
#include <myjailbreak>
#include <myweapons>
#include <armsfix>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsZombie = false;
bool g_bStartZombie = false;
bool g_bIsRoundEnd = true;

// Plugin bools
bool gp_bWarden;
bool gp_bMyJBWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bCustomPlayerSkins;
bool gp_bMyJailbreak;
bool gp_bMyWeapons;
bool gp_bArmsFix;

bool g_bTerrorZombies[MAXPLAYERS+1];

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_iCooldownStart;
ConVar gc_bVote;
ConVar gc_iRoundTime;
ConVar gc_fBeaconTime;
ConVar gc_iCooldownDay;
ConVar gc_iFreezeTime;
ConVar gc_bSpawnCell;
ConVar gc_iAmmo;
ConVar gc_iZombieHP;
ConVar gc_iZombieHPincrease;
ConVar gc_iHumanHP;
ConVar gc_bDark;
ConVar gc_bVision;
ConVar gc_bGlow;
ConVar gc_iGlowMode;
ConVar gc_sModelPathZombie;
ConVar gc_sModelPathZombieArms;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_iRounds;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;
ConVar gc_fKnockbackAmount;
ConVar gc_iRegen;
ConVar gc_bTerrorZombie;
ConVar gc_bTerrorInfect;
ConVar gc_fSpeed;

ConVar gc_bBeginSetA;
ConVar gc_bBeginSetW;
ConVar gc_bBeginSetV;
ConVar gc_bBeginSetVW;
ConVar gc_bTeleportSpawn;

// Extern Convars
ConVar g_iTerrorForLR;
ConVar g_sOldSkyName;

// Integers
int g_iFreezeTime;
int g_iCoolDown;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iTsLR;

// Handles
Handle g_hTimerFreeze;
Handle g_hTimerBeacon;
Handle g_hTimerRegen;
Handle g_hTimerReplenish;

// floats
float g_fPos[3];

// Strings
char g_sPrefix[64];
char g_sModelPathZombie[PLATFORM_MAX_PATH];
char g_sModelPathZombieArms[PLATFORM_MAX_PATH];
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sSkyName[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sModelPathPrevious[MAXPLAYERS+1][256];
char g_sOverlayStartPath[256];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Zombie",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	//Manually mark native as optional
	MarkNativeAsOptional("ArmsFix_ModelSafe");
}
// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Zombie.phrases");

	// Client Commands
	RegConsoleCmd("sm_setzombie", Command_SetZombie, "Allows the Admin or Warden to set Zombie as next round");
	RegConsoleCmd("sm_zombie", Command_VoteZombie, "Allows players to vote for a Zombie");

	// AutoExecConfig
	AutoExecConfig_SetFile("Zombie", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_zombie_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_zombie_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_zombie_prefix", "[{green}MyJB.Zombie{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_zombie_cmds_vote", "zd, zomb, z", "Set your custom chat command for Event voting(!zombie (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_zombie_cmds_set", "sz, szd, szombie", "Set your custom chat command for set Event(!setzombie (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_zombie_warden", "1", "0 - disabled, 1 - allow warden to set zombie round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_zombie_admin", "1", "0 - disabled, 1 - allow admin/vip to set zombie round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_zombie_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_zombie_vote", "1", "0 - disabled, 1 - allow player to vote for zombie", _, true, 0.0, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_zombie_begin_admin", "1", "When admin set event (!setzombie) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_zombie_begin_warden", "1", "When warden set event (!setzombie) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_zombie_begin_vote", "0", "When users vote for event (!zombie) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_zombie_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bTeleportSpawn = AutoExecConfig_CreateConVar("sm_zombie_teleport_spawn", "0", "0 - start event in current round from current player positions, 1 - teleport players to spawn when start event on current round(only when sm_*_begin_admin, sm_*_begin_warden, sm_*_begin_vote or sm_*_begin_daysvote is on '1')", _, true, 0.0, true, 1.0);

	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_zombie_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true, 0.0, true, 1.0);
	gc_iAmmo = AutoExecConfig_CreateConVar("sm_zombie_ammo", "0", "0 - disabled, 1 - enable infinite ammo and nades (with reload) for humans, 2 - enable infinite ammo (with reload) for humans", _, true, 0.0, true, 2.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_zombie_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_zombie_roundtime", "5", "Round time in minutes for a single zombie round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_zombie_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_zombie_freezetime", "35", "Time in seconds the zombies freezed", _, true, 0.0);
	gc_iZombieHP = AutoExecConfig_CreateConVar("sm_zombie_zombie_hp", "4000", "HP the Zombies got on Spawn", _, true, 1.0);
	gc_iZombieHPincrease = AutoExecConfig_CreateConVar("sm_zombie_zombie_hp_extra", "1000", "HP the Zombies get additional per extra Human", _, true, 1.0);
	gc_iHumanHP = AutoExecConfig_CreateConVar("sm_zombie_human_hp", "65", "HP the Humans got on Spawn", _, true, 1.0);
	gc_iRegen = AutoExecConfig_CreateConVar("sm_zombie_zombie_regen", "5", "0 - disabled, HPs a Zombie regenerates every 5 seconds", _, true, 0.0);
	gc_fSpeed = AutoExecConfig_CreateConVar("sm_zombie_speed", "1.4", "Movement speed of zombies - 1.0 normal speed", _, true, 1.0);
	gc_bDark = AutoExecConfig_CreateConVar("sm_zombie_dark", "1", "0 - disabled, 1 - enable Map Darkness", _, true, 0.0, true, 1.0);
	gc_bGlow = AutoExecConfig_CreateConVar("sm_zombie_glow", "1", "0 - disabled, 1 - enable Glow effect for humans", _, true, 0.0, true, 1.0);
	gc_iGlowMode = AutoExecConfig_CreateConVar("sm_zombie_glow_mode", "1", "1 - human contours with wallhack for zombies, 2 - human glow effect without wallhack for zombies", _, true, 1.0, true, 2.0);
	gc_bVision = AutoExecConfig_CreateConVar("sm_zombie_vision", "1", "0 - disabled, 1 - enable NightVision View for Zombies", _, true, 0.0, true, 1.0);
	gc_fKnockbackAmount = AutoExecConfig_CreateConVar("sm_zombie_knockback", "20.0", "Force of the knockback when shot at. Zombies only", _, true, 1.0, true, 100.0);
	gc_bTerrorZombie = AutoExecConfig_CreateConVar("sm_zombie_terror", "0", "0 - disabled, 1 - transform terrors into Zombie on death - experimental!", _, true, 0.0, true, 1.0);
	gc_bTerrorInfect = AutoExecConfig_CreateConVar("sm_zombie_terror_infect", "0", "0 - all dead terrors become zombie, 1 - only terrors killed by zombie transform into Zombie", _, true, 0.0, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_zombie_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_zombie_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_zombie_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set zombie round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_zombie_sounds_enable", "1", "0 - disabled, 1 - enable sounds", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_zombie_sounds_start", "music/MyJailbreak/zombie.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_zombie_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_zombie_overlays_start", "overlays/MyJailbreak/zombie", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sModelPathZombie = AutoExecConfig_CreateConVar("sm_zombie_model", "models/player/custom_player/zombie/revenant/revenant_v2.mdl", "Path to the model for zombies.");
	gc_sModelPathZombieArms = AutoExecConfig_CreateConVar("sm_zombie_arms_model", "models/player/custom_player/zombie/revenant/revenant_arms.mdl", "Path to the arms model for zombies. - Requires ArmsFix");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_zombie_allow_lr", "0", "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd_Pre, EventHookMode_Pre);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("weapon_reload", Event_WeaponReload); // sadly, this event is not triggered by auto-reloads (not clicking the reload button)
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sModelPathZombie, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sModelPathZombie.GetString(g_sModelPathZombie, sizeof(g_sModelPathZombie));
	gc_sModelPathZombieArms.GetString(g_sModelPathZombieArms, sizeof(g_sModelPathZombieArms));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));

	// Logs
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sModelPathZombie)
	{
		strcopy(g_sModelPathZombie, sizeof(g_sModelPathZombie), newValue);
		Downloader_AddFileToDownloadsTable(g_sModelPathZombie);
		PrecacheModel(g_sModelPathZombie);
	}
	else if (convar == gc_sModelPathZombieArms)
	{
		strcopy(g_sModelPathZombieArms, sizeof(g_sModelPathZombieArms), newValue);
		Downloader_AddFileToDownloadsTable(g_sModelPathZombieArms);
		PrecacheModel(g_sModelPathZombieArms);
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
	gp_bArmsFix = LibraryExists("ArmsFix");
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
	else if (StrEqual(name, "ArmsFix"))
	{
		gp_bArmsFix = false;
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
	else if (StrEqual(name, "ArmsFix"))
	{
		gp_bArmsFix = true;
	}
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	// FindConVar
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;

	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sModelPathZombie.GetString(g_sModelPathZombie, sizeof(g_sModelPathZombie));
	gc_sModelPathZombieArms.GetString(g_sModelPathZombieArms, sizeof(g_sModelPathZombieArms));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));

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
			RegConsoleCmd(sCommand, Command_VoteZombie, "Allows players to vote for a Zombie");
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
			RegConsoleCmd(sCommand, Command_SetZombie, "Allows the Admin or Warden to set Zombie as next round");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("zombie");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("zombie");
}

public Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen)
{
	if (!g_bIsZombie)
		return Plugin_Continue;
		
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		strcopy(model, modelLen, g_sModelPathZombie);
		strcopy(arms, armsLen, g_sModelPathZombieArms);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetZombie(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_disabled");
		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartEventRound(gc_bBeginSetVW.BoolValue);

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Zombie was started by groupvoting");
		}
	}
	else if (MyJB_CheckVIPFlags(client, "sm_zombie_flag", gc_sAdminFlag, "sm_zombie_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_setbyadmin");
			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_minplayer");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetA.BoolValue);

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Zombie was started by admin %L", client);
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
			CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_setbywarden");
			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_minplayer");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetW.BoolValue);

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Zombie was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteZombie(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_disabled");
		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_voting");
		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_minplayer");
		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_progress", EventDay);
			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_wait", g_iCoolDown);
		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "zombie_voted");
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
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Zombie was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%s %t", g_sPrefix, "zombie_need", Missing, client);
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

	if (!g_bStartZombie && !g_bIsZombie)
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

	g_bIsZombie = true;
	g_bStartZombie = false;

	PrepareDay(false);
}

// Round End
public void Event_RoundEnd_Pre(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsZombie)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
			SetEntProp(i, Prop_Send, "m_bNightVisionOn", 0);

			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);

			if (gp_bCustomPlayerSkins && gc_bGlow.BoolValue)
			{
				UnhookGlow(i);
			}

			if (g_bTerrorZombies[i])
			{
				ChangeClientTeam(i, CS_TEAM_T);
			}
		}

		delete g_hTimerFreeze;
		delete g_hTimerBeacon;
		delete g_hTimerRegen;
		delete g_hTimerReplenish;
		g_iFreezeTime = gc_iFreezeTime.IntValue;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "zombie_twin_nc");
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "zombie_ctwin_nc");
		}

		if (g_iRound == g_iMaxRound)
		{
			g_bIsZombie = false;
			g_bStartZombie = false;
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

			SetCvarString("sv_skyname", g_sSkyName);
			SetCvar("sv_infinite_ammo", 0);

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
				MyJailbreak_FogOff();
			}

			CPrintToChatAll("%s %t", g_sPrefix, "zombie_end");
		}
	}

	if (g_bStartZombie)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "zombie_next");
		PrintCenterTextAll("%t", "zombie_next_nc");
	}
}

public Action Event_PlayerHurt(Handle event, char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (!g_bIsZombie || !IsValidClient(attacker) || GetClientTeam(victim) == CS_TEAM_T)
		return;

	int damage = GetEventInt(event, "dmg_health");

	float knockback = gc_fKnockbackAmount.FloatValue; // knockback amount
	float clientloc[3];
	float attackerloc[3];

	GetClientAbsOrigin(victim, clientloc);

	// Get attackers eye position.
	GetClientEyePosition(attacker, attackerloc);

	// Get attackers eye angles.
	float attackerang[3];
	GetClientEyeAngles(attacker, attackerang);

	// Calculate knockback end-vector.
	TR_TraceRayFilter(attackerloc, attackerang, MASK_ALL, RayType_Infinite, KnockbackTRFilter);
	TR_GetEndPosition(clientloc);

	// Apply damage knockback multiplier.
	knockback *= damage;

	if (GetEntPropEnt(victim, Prop_Send, "m_hGroundEntity") == -1) knockback *= 0.5;

	// Apply knockback.
	KnockbackSetVelocity(victim, attackerloc, clientloc, knockback);
}

public Action Event_PlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (!g_bIsZombie || !gc_bTerrorZombie.BoolValue || (gc_bTerrorInfect.BoolValue && !IsValidClient(attacker, true, false)))
		return;

	if (GetClientTeam(victim) == CS_TEAM_CT || GetAlivePlayersCount(CS_TEAM_T) <= 1)
		return;

	g_bTerrorZombies[victim] = true;

	CreateTimer(4.0, Timer_MakeZombie, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_MakeZombie(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client, true, true))
	{
		ChangeClientTeam(client, CS_TEAM_CT);
		CS_RespawnPlayer(client);

		int zombieHP = gc_iZombieHP.IntValue;
		int difference = (GetAlivePlayersCount(CS_TEAM_T) - GetAlivePlayersCount(CS_TEAM_CT));
		if (difference > 0)
		{
			zombieHP = zombieHP + (gc_iZombieHPincrease.IntValue * difference);
		}

		SetEntityHealth(client, zombieHP);

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSpeed.FloatValue);

		StripAllPlayerWeapons(client);
		GivePlayerItem(client, "weapon_knife");

		if (gc_bVision.BoolValue)
		{
			SetEntProp(client, Prop_Send, "m_bNightVisionOn", 1);
		}

		if (gc_bOverlays.BoolValue)
		{
			ShowOverlay(client, g_sOverlayStartPath, 2.0);
		}

		if (gc_bSounds.BoolValue)
		{
			EmitSoundToClientAny(client, g_sSoundStartPath);
		}

		if (!gp_bArmsFix)
			CreateTimer (0.1, Timer_SetModel, client);
	}

	return Plugin_Stop;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	g_bIsZombie = false;
	g_bStartZombie = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_sOldSkyName = FindConVar("sv_skyname");
	g_sOldSkyName.GetString(g_sSkyName, sizeof(g_sSkyName));

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);   // Add sound to download and precache table
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);   // Add overlay to download and precache table
	}

	Downloader_AddFileToDownloadsTable(g_sModelPathZombie);
	Downloader_AddFileToDownloadsTable(g_sModelPathZombieArms);
	PrecacheModel(g_sModelPathZombie);
	PrecacheModel(g_sModelPathZombieArms);
}

// Map End
public void OnMapEnd()
{
	g_bIsZombie = false;
	g_bStartZombie = false;

	delete g_hTimerFreeze;
	delete g_hTimerBeacon;
	delete g_hTimerRegen;
	delete g_hTimerReplenish;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

public void MyJailbreak_ResetEventDay()
{
	g_bStartZombie = false;

	if (g_bIsZombie)
	{
		g_iRound = g_iMaxRound;
		ResetEventDay();
	}
}

// Listen for Last Lequest
public void OnAvailableLR(int Announced)
{
	if (g_bIsZombie && gc_bAllowLR.BoolValue && (g_iTsLR > g_iTerrorForLR.IntValue))
	{
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

		if (gp_bCustomPlayerSkins && gc_bGlow.BoolValue)
		{
			UnhookGlow(i);
		}

		SetEntProp(i, Prop_Send, "m_bNightVisionOn", 0);

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);

		EnableWeaponFire(i, true);

		StripAllPlayerWeapons(i);

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			FakeClientCommand(i, "sm_weapons");
			SetEntityModel(i, g_sModelPathPrevious[i]);
			SetEntityHealth(i, 100);
		}

		GivePlayerItem(i, "weapon_knife_t");

		if (g_bTerrorZombies[i])
		{
			ChangeClientTeam(i, CS_TEAM_T);
		}

		SetEntityMoveType(i, MOVETYPE_WALK);

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
	}

	delete g_hTimerFreeze;
	delete g_hTimerBeacon;
	delete g_hTimerRegen;
	delete g_hTimerReplenish;
	g_iFreezeTime = gc_iFreezeTime.IntValue;

	if (g_iRound == g_iMaxRound)
	{
		g_bIsZombie = false;
		g_bStartZombie = false;
		g_iRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");

		SetCvar("sm_hosties_lr", 1);

		if (gp_bMyWeapons)
		{
			MyWeapons_AllowTeam(CS_TEAM_T, false);
			MyWeapons_AllowTeam(CS_TEAM_CT, true);
		}

		SetCvarString("sv_skyname", g_sSkyName);
		SetCvar("sv_infinite_ammo", 0);

		if (gp_bMyJBWarden)
		{
			warden_enable(true);
		}

		if (gp_bMyJailbreak)
		{
			SetCvar("sm_menu_enable", 1);

			MyJailbreak_SetEventDayName("none");
			MyJailbreak_SetEventDayRunning(false, 0);
			MyJailbreak_FogOff();
		}

		CPrintToChatAll("%s %t", g_sPrefix, "zombie_end");
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

// Knife only for Zombies
public Action OnWeaponCanUse(int client, int weapon)
{
	if (!g_bIsZombie)
	{
		return Plugin_Continue;
	}

	if (!IsValidClient(client, true, false))
		return Plugin_Continue;

	if (GetClientTeam(client) != CS_TEAM_CT)
		return Plugin_Continue;

	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if ((StrContains(sWeapon, "knife", false) != -1) || (StrContains(sWeapon, "bayonet", false) != -1))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

public Action OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (!g_bIsZombie)
		return Plugin_Continue;

	if (!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false))
		return Plugin_Continue;

	if (GetClientTeam(victim) == GetClientTeam(attacker))
		return Plugin_Handled;

	return Plugin_Continue;
}

// Fixes maps that set the ammo of a weapon to 1 or weird values for sm_zombie_ammo 1 and 2
public Action OnWeaponEquipPost(int client, int weapon)
{
	if (!g_bIsZombie || !gc_iAmmo.BoolValue)
	{
		return Plugin_Continue;
	}
	
	if (!IsValidClient(client, false, false) || GetClientTeam(client) != CS_TEAM_T)
	{
		return Plugin_Continue;
	}
	if (!IsValidEdict(weapon))
	{
		return Plugin_Continue;
	}
	
	// If the weapon isn't a firearm (not a primary or secondary weapon), exit the function.
	if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != weapon && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != weapon)
	{
		return Plugin_Continue;
	}
	
	// Gives up to 1k ammo to the player. Caps at the maximum for the weapon.
	GivePlayerAmmo(client, 1000, GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"), true);
	return Plugin_Continue;
}

// for "sm_zombie_ammo 2": infinite ammo, without having infinite nades
public void Event_WeaponReload(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsZombie || gc_iAmmo.IntValue != 2)
	{
		return;
	}
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	ReplenishWeapons(client);
}

// Replenishes a player's weapons if necessary
void ReplenishWeapons(int client)
{
	if (!IsValidClient(client, false, false) || GetClientTeam(client) != CS_TEAM_T)
	{
		return;
	}
	
	// Find and replenish the primary weapon if it exists
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if (weapon != -1)
	{
		GivePlayerAmmo(client, 1000, GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"), true);
	}
	
	// Find and replenish the secondary weapon if it exists
	weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (weapon != -1)
	{
		GivePlayerAmmo(client, 1000, GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"), true);
	}
	return;
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
		Format(buffer, sizeof(buffer), "%T", "zombie_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsZombie = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			EnableWeaponFire(i, false);

			SetEntityMoveType(i, MOVETYPE_NONE);
		}

		CreateTimer(3.0, Timer_PrepareEvent);

		CPrintToChatAll("%s %t", g_sPrefix, "zombie_now");
		PrintCenterTextAll("%t", "zombie_now_nc");
	}
	else
	{
		g_bStartZombie = true;
		g_iCoolDown++;

		CPrintToChatAll("%s %t", g_sPrefix, "zombie_next");
		PrintCenterTextAll("%t", "zombie_next_nc");
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	if (!g_bIsZombie)
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
				CS_RespawnPlayer(i);
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

	int zombieHP = gc_iZombieHP.IntValue;
	int difference = (GetAlivePlayersCount(CS_TEAM_T) - GetAlivePlayersCount(CS_TEAM_CT));
	if (difference > 0)
	{
		zombieHP = zombieHP + (gc_iZombieHPincrease.IntValue * difference);
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

		g_bTerrorZombies[i] = false;

		GivePlayerItem(i, "weapon_knife");

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			SetEntityHealth(i, zombieHP);

			if (!gp_bArmsFix || thisround)
				CreateTimer (1.1, Timer_SetModel, i);

			DarkenScreen(i, true);
		}
		else if (GetClientTeam(i) == CS_TEAM_T)
		{
			SetEntityHealth(i, gc_iHumanHP.IntValue);
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

	if (gc_iAmmo.IntValue == 1)
	{
		SetCvar("sv_infinite_ammo", 2);
	}

	if (gp_bMyWeapons)
	{
		MyWeapons_AllowTeam(CS_TEAM_T, true);
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

	SetCvarString("sv_skyname", "cs_baggage_skybox_");

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	g_hTimerFreeze = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);

	CPrintToChatAll("%s %t", g_sPrefix, "zombie_rounds", g_iRound, g_iMaxRound);
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
		GlowSkin(iSkin);
	}
}

// set client glow
void GlowSkin(int iSkin)
{
	int iOffset;

	if ((iOffset = GetEntSendPropOffs(iSkin, "m_clrGlow")) == -1)
		return;

	SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", true, true);
	if (gc_iGlowMode.IntValue == 1) SetEntProp(iSkin, Prop_Send, "m_nGlowStyle", 0);
	if (gc_iGlowMode.IntValue == 2) SetEntProp(iSkin, Prop_Send, "m_nGlowStyle", 1);
	SetEntPropFloat(iSkin, Prop_Send, "m_flGlowMaxDist", 10000000.0);

	int iRed = 155;
	int iGreen = 0;
	int iBlue = 10;

	SetEntData(iSkin, iOffset, iRed, _, true);
	SetEntData(iSkin, iOffset + 1, iGreen, _, true);
	SetEntData(iSkin, iOffset + 2, iBlue, _, true);
	SetEntData(iSkin, iOffset + 3, 255, _, true);
}

// Who can see the glow if vaild
public Action OnSetTransmit_GlowSkin(int iSkin, int client)
{
	if (!IsPlayerAlive(client) || GetClientTeam(client) != CS_TEAM_CT)
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

void KnockbackSetVelocity(int client, const float startpoint[3], const float endpoint[3], float magnitude)
{
	// Create vector from the given starting and ending points.
	float vector[3];
	MakeVectorFromPoints(startpoint, endpoint, vector);

	// Normalize the vector (equal magnitude at varying distances).
	NormalizeVector(vector, vector);

	// Apply the magnitude by scaling the vector (multiplying each of its components).
	ScaleVector(vector, magnitude);

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vector);
}

public bool KnockbackTRFilter(int entity, int contentsMask)
{
	// If entity is a player, continue tracing.
	if (entity > 0 && entity < MAXPLAYERS)
	{
		return false;
	}

	// Allow hit.
	return true;
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "zombie_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "zombie_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "zombie_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "zombie_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "zombie_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "zombie_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "zombie_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "zombie_info_line7", client);
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
			if (!IsValidClient(i, false, true))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				PrintCenterText(i, "%t", "zombie_timetounfreeze_nc", g_iFreezeTime);
			}
			else
			{
				PrintCenterText(i, "%t", "zombie_timeuntilzombie_nc", g_iFreezeTime);
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
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", gc_fSpeed.FloatValue);
			DarkenScreen(i, false);

			if (gc_bVision.BoolValue)
			{
				SetEntProp(i, Prop_Send, "m_bNightVisionOn", 1);
			}
		}

		if (gp_bCustomPlayerSkins && gc_bGlow.BoolValue && (IsValidClient(i, true, true)) && (GetClientTeam(i) == CS_TEAM_T))
		{
			SetupGlowSkin(i);
		}

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

	if (gp_bMyJailbreak && gc_bDark.BoolValue && g_iRound == 1)
	{
		MyJailbreak_FogOn();
	}

	if (gc_iRegen.IntValue != 0)
	{
		delete g_hTimerRegen;
		g_hTimerRegen = CreateTimer(5.0, Timer_ReGenHealth, _, TIMER_REPEAT);
	}
	
	if (gc_iAmmo.IntValue == 2)
	{
		delete g_hTimerReplenish;
		g_hTimerReplenish = CreateTimer(5.0, Timer_ReplenishWeapon, _, TIMER_REPEAT);
	}

	PrintCenterTextAll("%t", "zombie_start_nc");

	CPrintToChatAll("%s %t", g_sPrefix, "zombie_start");

	g_hTimerFreeze = null;

	return Plugin_Stop;
}

// Delay Set model for sm_skinchooser
public Action Timer_SetModel(Handle timer, int client)
{
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPathPrevious[client], sizeof(g_sModelPathPrevious[]));
		SetEntityModel(client, g_sModelPathZombie);
		if (gp_bArmsFix)
		{
			if (ArmsFix_ModelSafe(client))
			{
				SetEntPropString(client, Prop_Send, "m_szArmsModel", g_sModelPathZombieArms);
			}
		}
	}
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

public Action Timer_ReGenHealth(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, false))
			continue;

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			SetEntityHealth(i, GetClientHealth(i)+gc_iRegen.IntValue);
		}
	}
}

public Action Timer_ReplenishWeapon(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		ReplenishWeapons(i);
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