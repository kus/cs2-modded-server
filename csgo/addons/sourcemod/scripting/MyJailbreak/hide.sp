/*
 * MyJailbreak - Hide in the Dark Event Day Plugin.
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
#include <myicons>
#define REQUIRE_PLUGIN

#define WEAPON_SHOTGUN	4

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsHide = false;
bool g_bStartHide = false;
bool g_bIsRoundEnd = true;
bool g_bShotgun[MAXPLAYERS + 1] = {false, ...};

// Plugin bools
bool gp_bWarden;
bool gp_bMyJBWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bMyJailbreak;
bool gp_bMyIcons;
bool gp_bMyWeapons;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bVote;
ConVar gc_bOverlays;
ConVar gc_bFreezeHider;
ConVar gc_bBlackout;
ConVar gc_iRoundTime;
ConVar gc_fBeaconTime;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iFreezeTime;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iRounds;
ConVar gc_iTAgrenades;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;

ConVar gc_bBeginSetA;
ConVar gc_bBeginSetW;
ConVar gc_bBeginSetV;
ConVar gc_bBeginSetVW;
ConVar gc_bTeleportSpawn;

ConVar gc_bHPSeekerEnable;
ConVar gc_iHPSeekerDec;
ConVar gc_iHPSeekerInc;
ConVar gc_iHPSeekerIncShotgun;
ConVar gc_iHPSeekerBonus;

// Extern Convars
ConVar g_sOldSkyName;
ConVar g_iTerrorForLR;

// Integers
int g_iFreezeTime;
int g_iCoolDown;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iMaxTA;
int g_iTA[MAXPLAYERS + 1];
int g_iTsLR;

// Handles
Handle g_hTimerFreeze;
Handle g_hTimerBeacon;

// Strings
char g_sPrefix[64];
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sSkyName[256];
char g_sOverlayStartPath[256];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - HideInTheDark",
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
	LoadTranslations("MyJailbreak.Hide.phrases");

	// Client Commands
	RegConsoleCmd("sm_sethide", Command_SetHide, "Allows the Admin or Warden to set hide as next round");
	RegConsoleCmd("sm_hide", Command_VoteHide, "Allows players to vote for a hide");

	// AutoExecConfig
	AutoExecConfig_SetFile("Hide", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_hide_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hide_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_hide_prefix", "[{green}MyJB.Hide{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_hide_cmds_vote", "hidenseek", "Set your custom chat command for Event voting(!hide (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_hide_cmds_set", "shide", "Set your custom chat command for set Event(!hide (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_hide_warden", "1", "0 - disabled, 1 - allow warden to set hide round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_hide_admin", "1", "0 - disabled, 1 - allow admin/vip to set hide round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_hide_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_hide_vote", "1", "0 - disabled, 1 - allow player to vote for hide round", _, true, 0.0, true, 1.0);
	gc_bFreezeHider = AutoExecConfig_CreateConVar("sm_hide_freezehider", "1", "0 - disabled, 1 - enable freeze hider when hidetime gone", _, true, 0.0, true, 1.0);
	gc_bBlackout = AutoExecConfig_CreateConVar("sm_hide_blackout", "1", "0 - disabled, 1 - enable black out seekers screen on hide time", _, true, 0.0, true, 1.0);
	gc_iTAgrenades = AutoExecConfig_CreateConVar("sm_hide_tagrenades", "3", "how many tagrenades a guard have?", _, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_hide_begin_admin", "1", "When admin set event (!sethide) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_hide_begin_warden", "1", "When warden set event (!sethide) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_hide_begin_vote", "0", "When users vote for event (!hide) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_hide_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bTeleportSpawn = AutoExecConfig_CreateConVar("sm_hide_teleport_spawn", "0", "0 - start event in current round from current player positions, 1 - teleport players to spawn when start event on current round(only when sm_*_begin_admin, sm_*_begin_warden, sm_*_begin_vote or sm_*_begin_daysvote is on '1')", _, true, 0.0, true, 1.0);

	gc_iRounds = AutoExecConfig_CreateConVar("sm_hide_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hide_roundtime", "5", "Round time in minutes for a single war round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_hide_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_hide_hidetime", "30", "Time in seconds to hide / CT freezed", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_hide_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_hide_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_hide_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set hide round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_hide_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_hide_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_hide_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_hide_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_hide_allow_lr", "0", "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);

	gc_bHPSeekerEnable = AutoExecConfig_CreateConVar("sm_hide_hp_seeker_enable", "1", "Should CT lose HP when shooting, 0 = off/1 = on.", _, true, 0.0, true, 1.0);
	gc_iHPSeekerDec = AutoExecConfig_CreateConVar("sm_hide_hp_seeker_dec", "5", "How many hp should a CT lose on shooting?", _, true, 0.00);
	gc_iHPSeekerInc = AutoExecConfig_CreateConVar("sm_hide_hp_seeker_inc", "15", "How many hp should a CT gain when hitting a hider?", _, true, 0.00);
	gc_iHPSeekerIncShotgun = AutoExecConfig_CreateConVar("sm_hide_hp_seeker_inc_shotgun", "5", "How many hp should a CT gain when hitting a hider with shotgun? (CS:GO only)", _, true, 0.00);
	gc_iHPSeekerBonus = AutoExecConfig_CreateConVar("sm_hide_hp_seeker_bonus", "50", "How many hp should a CT gain when killing a hider?", _, true, 0.00);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("tagrenade_detonate", Event_TA_Detonate);
	HookEvent("weapon_fire", Event_OnWeaponFire);
	HookEvent("item_equip", Event_ItemEquip);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
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
	// FindConVar
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	g_iMaxTA = gc_iTAgrenades.IntValue - 1;

	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));

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
			RegConsoleCmd(sCommand, Command_VoteHide, "Allows players to vote for a hide");
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
			RegConsoleCmd(sCommand, Command_SetHide, "Allows the Admin or Warden to set hide as next round");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("hide");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("hide");
}



/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetHide(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "hide_disabled");

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
	else if (MyJB_CheckVIPFlags(client, "sm_hide_flag", gc_sAdminFlag, "sm_hide_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "hide_setbyadmin");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "hide_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "hide_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "hide_wait", g_iCoolDown);

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
			CReplyToCommand(client, "%s %t", g_sPrefix, "hide_setbywarden");

			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "hide_minplayer");

			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "hide_progress", EventDay);

				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "hide_wait", g_iCoolDown);

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
public Action Command_VoteHide(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "hide_disabled");

		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "hide_voting");

		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "hide_minplayer");

		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "hide_progress", EventDay);

			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "hide_wait", g_iCoolDown);

		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "hide_voted");

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
		CPrintToChatAll("%s %t", g_sPrefix, "hide_need", Missing, client);
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)	// todo clean up a bit
{
	if (attacker > 0 && attacker <= MaxClients && victim > 0 && victim <= MaxClients)
	{
		if (g_bIsHide && GetClientTeam(victim) == CS_TEAM_CT)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup) 
{
	if (!g_bIsHide)
		return Plugin_Continue;

	if (attacker < 1 || attacker > MaxClients || !IsPlayerAlive(attacker))
		return Plugin_Continue;

	if (GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT)
	{
		int remainingHealth = GetClientHealth(victim) - RoundToFloor(damage);

		if (gc_bHPSeekerEnable.BoolValue)
		{
			int decrease = gc_iHPSeekerDec.IntValue;

			if (g_bShotgun[attacker])
			{
				SetEntityHealth(attacker, GetClientHealth(attacker) + gc_iHPSeekerIncShotgun.IntValue + decrease);
			}
			else
			{
				SetEntityHealth(attacker, GetClientHealth(attacker) + gc_iHPSeekerInc.IntValue + decrease);
			}

			// give bonus health if the hider died
			if (remainingHealth < 0)
			{
				SetEntityHealth(attacker, GetClientHealth(attacker) + gc_iHPSeekerBonus.IntValue);
			}
		}

		if (remainingHealth < 0)
		{
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}

// Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = false;

	if (!g_bStartHide && !g_bIsHide)
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

	g_bIsHide = true;
	g_bStartHide = false;

	PrepareDay(false);
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = true;

	if (g_bIsHide)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			g_iTA[i] = 0;
			g_bShotgun[i] = false;

			if (gp_bMyIcons)
			{
				MyIcons_BlockClientIcon(i, false);
			}
		}

		delete g_hTimerBeacon;
		delete g_hTimerFreeze;
		g_iFreezeTime = gc_iFreezeTime.IntValue;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "hide_twin_nc");
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "hide_ctwin_nc");
		}

		if (g_iRound >= g_iMaxRound)
		{
			g_bIsHide = false;
			g_bStartHide = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");

			SetCvarString("sv_skyname", g_sSkyName);

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

				MyJailbreak_SetEventDayRunning(false, winner);
				MyJailbreak_SetEventDayName("none");
				MyJailbreak_FogOff();
			}

			CPrintToChatAll("%s %t", g_sPrefix, "hide_end");
		}
	}

	if (g_bStartHide)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "hide_next");
		PrintCenterTextAll("%t", "hide_next_nc");
	}
}

// Give new TA
public void Event_TA_Detonate(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bIsHide)
	{
		int target = GetClientOfUserId(event.GetInt("userid"));
		if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
		{
			return;
		}

		if (g_iTA[target] != g_iMaxTA)
		{
			GivePlayerItem(target, "weapon_tagrenade");
			int g_iTAgot = (g_iMaxTA - g_iTA[target]);
			g_iTA[target]++;

			CPrintToChat(target, "%s %t", g_sPrefix, "hide_stillta", g_iTAgot);
		}
		else CPrintToChat(target, "%s %t", g_sPrefix, "hide_nota");
	}
}

public void Event_ItemEquip(Event event, const char[] name, bool dontBroadcast) 
{
	if (!g_bIsHide)
		return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	int type = event.GetInt("weptype");
	if (type == WEAPON_SHOTGUN) 
	{
		g_bShotgun[client] = true;
	} 
	else
	{
		g_bShotgun[client] = false;
	}
}

public void Event_OnWeaponFire(Event event, const char[] name, bool dontBroadcast) {
	if (!gc_bHPSeekerEnable.BoolValue || g_bIsRoundEnd || !g_bIsHide)
		return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	int decreaseHP = gc_iHPSeekerDec.IntValue;
	int clientHealth = GetClientHealth(client);

	if ((clientHealth - decreaseHP) > 0) 
	{
		SetEntityHealth(client, (clientHealth - decreaseHP));
	} 
	else 
	{
		CreateTimer(0.1, Timer_SlayClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
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
	g_bIsHide = false;
	g_bStartHide = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_sOldSkyName = FindConVar("sv_skyname");
	g_sOldSkyName.GetString(g_sSkyName, sizeof(g_sSkyName));

	// Precache Sound & Overlay
	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) 
	{
		g_iTA[i] = 0;
		g_bShotgun[i] = false;
	}
}

// Terror win Round if time runs out
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (g_bIsHide)	 // TODO: does this trigger??
	{
		if (reason == CSRoundEnd_Draw)
		{
			reason = CSRoundEnd_TerroristWin;
			return Plugin_Changed;
		}

		return Plugin_Continue;
	}

	return Plugin_Continue;
}

public void OnMapEnd()
{
	g_bIsHide = false;
	g_bStartHide = false;

	delete g_hTimerBeacon;
	delete g_hTimerFreeze;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

// Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
	g_bShotgun[client] = false;
}


// Knife only for Terrorists
public Action OnWeaponCanUse(int client, int weapon)
{
	if (!g_bIsHide)
	{
		return Plugin_Continue;
	}

	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if ((GetClientTeam(client) == CS_TEAM_T && StrEqual(sWeapon, "weapon_knife")) || (GetClientTeam(client) == CS_TEAM_CT))
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			return Plugin_Continue;
		}
	}

	return Plugin_Handled;
}

public void MyJailbreak_ResetEventDay()
{
	g_bStartHide = false;

	if (g_bIsHide)
	{
		g_iRound = g_iMaxRound;
		ResetEventDay();
	}
}

// Listen for Last Lequest
public void OnAvailableLR(int Announced)
{
	if (g_bIsHide && gc_bAllowLR.BoolValue && (g_iTsLR > g_iTerrorForLR.IntValue))
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
		SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
		g_iTA[i] = 0;
		g_bShotgun[i] = false;
		
		if (gp_bMyIcons)
		{
			MyIcons_BlockClientIcon(i, false);
		}

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

	delete g_hTimerFreeze;
	delete g_hTimerBeacon;
	g_iFreezeTime = gc_iFreezeTime.IntValue;

	if (g_iRound == g_iMaxRound)
	{
		g_bIsHide = false;
		g_bStartHide = false;
		g_iRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");

		if (gp_bMyJBWarden)
		{
			warden_enable(true);
		}

		SetCvarString("sv_skyname", g_sSkyName);
		SetCvar("sm_hosties_lr", 1);

		if (gp_bMyWeapons)
		{
			MyWeapons_AllowTeam(CS_TEAM_T, false);
			MyWeapons_AllowTeam(CS_TEAM_CT, true);
		}

		if (gp_bMyJailbreak)
		{
			SetCvar("sm_menu_enable", 1);

			MyJailbreak_SetEventDayName("none");
			MyJailbreak_SetEventDayRunning(false, 0);

			MyJailbreak_FogOff();
		}

		CPrintToChatAll("%s %t", g_sPrefix, "hide_end");
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
		Format(buffer, sizeof(buffer), "%T", "hide_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsHide = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			EnableWeaponFire(i, false);

			SetEntityMoveType(i, MOVETYPE_NONE);
		}

		CreateTimer(3.0, Timer_PrepareEvent);

		CPrintToChatAll("%s %t", g_sPrefix, "hide_now");
		PrintCenterTextAll("%t", "hide_now_nc");
	}
	else
	{
		g_bStartHide = true;
		g_iCoolDown++;

		CPrintToChatAll("%s %t", g_sPrefix, "hide_next");
		PrintCenterTextAll("%t", "hide_next_nc");
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	if (!g_bIsHide)
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

		if (GetClientTeam(i) == CS_TEAM_T)
		{
			if (gp_bMyIcons)
			{
				MyIcons_BlockClientIcon(i, true);
			}
		}
		else if (GetClientTeam(i) == CS_TEAM_CT)
		{
			GivePlayerItem(i, "weapon_tagrenade");

			if (gc_bBlackout.BoolValue)
			{
				DarkenScreen(i, true);
			}
		}
	}

	if (gp_bMyJailbreak)
	{
		SetCvar("sm_menu_enable", 0);

		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);

		MyJailbreak_FogOn();

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
		MyWeapons_AllowTeam(CS_TEAM_CT, true);
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

	CPrintToChatAll("%s %t", g_sPrefix, "hide_rounds", g_iRound, g_iMaxRound);

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	SetCvarString("sv_skyname", "cs_baggage_skybox_");

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

	Format(info, sizeof(info), "%T", "hide_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "hide_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "hide_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line7", client);
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
			if (!IsValidClient(i, true, false))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				PrintCenterText(i, "%t", "hide_timetounfreeze_nc", g_iFreezeTime);
			}
			else if (GetClientTeam(i) == CS_TEAM_T)
			{
				PrintCenterText(i, "%t", "hide_timetohide_nc", g_iFreezeTime);
			}
		}

		return Plugin_Continue;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		EnableWeaponFire(i, true);

		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			SetEntityMoveType(i, MOVETYPE_WALK);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.4);

			DarkenScreen(i, false);
		}
		else if (GetClientTeam(i) == CS_TEAM_T)
		{
			if (gc_bFreezeHider.BoolValue)
			{
				SetEntityMoveType(i, MOVETYPE_NONE);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
			}
			else
			{
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.8);
			}
		}

		if (gc_bOverlays.BoolValue)
		{
			ShowOverlay(i, g_sOverlayStartPath, 2.0);
		}
	}

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sSoundStartPath);
	}

	PrintCenterTextAll("%t", "hide_start_nc");

	CPrintToChatAll("%s %t", g_sPrefix, "hide_start");

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

public Action Timer_SlayClient(Handle timer, int userid) 
{
	int client = GetClientOfUserId(userid);
	if (!client)
		return Plugin_Stop;
		
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;

	ForcePlayerSuicide(client);
	return Plugin_Stop;
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