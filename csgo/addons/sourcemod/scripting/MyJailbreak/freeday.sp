/*
 * MyJailbreak - Freeday Event Day Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Headline
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

// m_takedamage values
#define DAMAGE_NO 0
#define DAMAGE_EVENTS_ONLY 1 // Call damage functions, but don't modify health
#define DAMAGE_YES 2
#define DAMAGE_AIM 3

// Booleans
bool g_bIsFreeday = false;
bool g_bStartFreeday = false;
bool g_bAutoFreeday = false;
bool g_bAllowRespawn = false;
bool g_bRepeatFirstFreeday = false;
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
ConVar gc_bFirst;
ConVar gc_bAuto;
ConVar gc_iRespawn;
ConVar gc_iRespawnTime;
ConVar gc_bdamage;
ConVar gc_bWarden;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;

ConVar gc_bBeginSetA;
ConVar gc_bBeginSetW;
ConVar gc_bBeginSetV;
ConVar gc_bBeginSetVW;


// Integers
int g_iCoolDown;
int g_iVoteCount;

// Strings
char g_sPrefix[64];
char g_sHasVoted[1500];
char g_sEventsLogFile[PLATFORM_MAX_PATH];

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - Freeday",
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
	LoadTranslations("MyJailbreak.FreeDay.phrases");

	// Client Commands
	RegConsoleCmd("sm_setfreeday", Command_SetFreeday, "Allows the Admin or Warden to set freeday as next round");
	RegConsoleCmd("sm_freeday", Command_VoteFreeday, "Allows players to vote for a freeday");

	// AutoExecConfig
	AutoExecConfig_SetFile("Freeday", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_freeday_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_freeday_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_freeday_prefix", "[{green}MyJB.FreeDay{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_freeday_cmds_vote", "fd, free", "Set your custom chat command for Event voting(!freeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_freeday_cmds_set", "sfreeday, sfd", "Set your custom chat command for set Event(!setfreeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_freeday_warden", "1", "0 - disabled, 1 - allow warden to set freeday round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_freeday_admin", "1", "0 - disabled, 1 - allow admin/vip to set freeday round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_freeday_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_freeday_vote", "1", "0 - disabled, 1 - allow player to vote for freeday", _, true, 0.0, true, 1.0);

	gc_bBeginSetA = AutoExecConfig_CreateConVar("sm_freeday_begin_admin", "1", "When admin set event (!setfreeday) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetW = AutoExecConfig_CreateConVar("sm_freeday_begin_warden", "1", "When warden set event (!setfreeday) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetV = AutoExecConfig_CreateConVar("sm_freeday_begin_vote", "0", "When users vote for event (!freeday) = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);
	gc_bBeginSetVW = AutoExecConfig_CreateConVar("sm_freeday_begin_daysvote", "0", "When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round", _, true, 0.0, true, 1.0);

	gc_bAuto = AutoExecConfig_CreateConVar("sm_freeday_noct", "1", "0 - disabled, 1 - auto freeday when there is no CT", _, true, 0.0, true, 1.0);
	gc_bWarden = AutoExecConfig_CreateConVar("sm_freeday_allow_warden", "0", "0 - warden disabled, 1 - allow player to become warden", _, true, 0.0, true, 1.0);
	gc_iRespawn = AutoExecConfig_CreateConVar("sm_freeday_respawn", "1", "1 - respawn on NoCT Freeday / 2 - respawn on firstround/vote/set Freeday / 3 - Both", _, true, 1.0, true, 3.0);
	gc_iRespawnTime = AutoExecConfig_CreateConVar("sm_freeday_respawn_time", "120", "Time in seconds player will respawn after round begin", _, true, 1.0);
	gc_bFirst = AutoExecConfig_CreateConVar("sm_freeday_firstround", "0", "0 - disabled, 1 - auto freeday first round after mapstart", _, true, 0.0, true, 1.0);
	gc_bdamage = AutoExecConfig_CreateConVar("sm_freeday_damage", "1", "0 - disabled, 1 - enable damage on freedays", _, true, 0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_freeday_roundtime", "5", "Round time in minutes for a single freeday round", _, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_freeday_cooldown_day", "0", "Rounds until freeday can be started again.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_freeday_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set freeday round", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;

	// Logs
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sPrefix)
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

// Initialize Event
public void OnConfigsExecuted()
{
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));

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
			RegConsoleCmd(sCommand, Command_VoteFreeday, "Allows players to vote for a freeday");
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
			RegConsoleCmd(sCommand, Command_SetFreeday, "Allows the Admin or Warden to set freeday as next round");
		}
	}

	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_AddEventDay("freeday");
}

public void OnPluginEnd()
{
	if (!gp_bMyJailbreak)
		return;

	MyJailbreak_RemoveEventDay("freeday");
}



/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetFreeday(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_disabled");
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
			LogToFileEx(g_sEventsLogFile, "Event Freeday was started by groupvoting");
		}
	}
	else if (MyJB_CheckVIPFlags(client, "sm_freeday_flag", gc_sAdminFlag, "sm_freeday_flag")) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_setbyadmin");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetA.BoolValue);

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by admin %L", client);
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
			CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_setbywarden");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartEventRound(gc_bBeginSetW.BoolValue);

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteFreeday(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_disabled");
		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_voting");
		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_progress", EventDay);
			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_wait", g_iCoolDown);
		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "freeday_voted");
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
			LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%s %t", g_sPrefix, "freeday_need", Missing, client);
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

	if ((GetTeamClientCount(CS_TEAM_CT) < 1) && gc_bAuto.BoolValue)
	{
		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!MyJailbreak_IsEventDayPlanned())
			{
				g_bStartFreeday = true;
				g_iCoolDown = gc_iCooldownDay.IntValue + 1;
				g_iVoteCount = 0;
				char buffer[32];
				Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
				MyJailbreak_SetEventDayName(buffer);
				MyJailbreak_SetEventDayRunning(true, 0);
				g_bAutoFreeday = true;
			}
		}
	}

	if (!g_bStartFreeday && !g_bRepeatFirstFreeday)
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

	g_bIsFreeday = true;
	g_bStartFreeday = false;
	g_bAllowRespawn = true;

	PrepareDay();
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsRoundEnd = true;

	if (g_bIsFreeday && !g_bRepeatFirstFreeday)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true))
		{
			SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
		}

		g_bIsFreeday = false;
		g_bStartFreeday = false;
		g_bAllowRespawn = false;
		g_bAutoFreeday = false;
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
			MyJailbreak_SetEventDayName("none"); // tell myjailbreak event is ended
			MyJailbreak_SetEventDayRunning(false, 0);
		}

		SetCvar("mp_teammates_are_enemies", 0);

//		g_iMPRoundTime.IntValue = g_iOldRoundTime;

		CPrintToChatAll("%s %t", g_sPrefix, "freeday_end");
	}

	if (g_bStartFreeday)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			CreateInfoPanel(i);
		}

		CPrintToChatAll("%s %t", g_sPrefix, "freeday_next");
		PrintCenterTextAll("%t", "freeday_next_nc");
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if ((g_bAutoFreeday && gc_iRespawn.IntValue == 1) || (g_bIsFreeday && gc_iRespawn.IntValue == 2) || ((g_bIsFreeday || g_bAutoFreeday) && gc_iRespawn.IntValue == 3))
	{
		int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

		if (((GetAlivePlayersCount(CS_TEAM_CT) >= 1) && (GetClientTeam(client) == CS_TEAM_CT) && g_bAllowRespawn) || ((GetAlivePlayersCount(CS_TEAM_T) >= 1) && (GetClientTeam(client) == CS_TEAM_T) && g_bAllowRespawn))
		{
			CreateTimer (2.0, Timer_Respawn, GetClientUserId(client));
		}
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;

	g_bIsFreeday = false;
	g_bAutoFreeday = false;
	g_bRepeatFirstFreeday = false;

	if (gc_bFirst.BoolValue)
	{
		g_bStartFreeday = true;

//		g_iOldRoundTime = g_iMPRoundTime.IntValue;
//		g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;

		if (gp_bMyJailbreak)
		{
			char buffer[32];
			Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
			MyJailbreak_SetEventDayName(buffer);
			MyJailbreak_SetEventDayRunning(true, 0);
		}
	}
	else
	{
		g_bStartFreeday = false;
	}
}

// Map End
public void OnMapEnd()
{
	if (gc_bFirst.BoolValue)
	{
		g_bStartFreeday = true;
	}
	else
	{
		g_bStartFreeday = false;
	}

	g_bIsFreeday = false;
	g_bAutoFreeday = false;
	g_bAllowRespawn = false;

	g_iVoteCount = 0;
	g_sHasVoted[0] = '\0';
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
		Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	if (thisround && g_bIsRoundEnd)
	{
		thisround = false;
	}

	if (thisround)
	{
		g_bIsFreeday = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			if (IsPlayerAlive(i))
			{
				SetEntProp(i, Prop_Data, "m_takedamage", DAMAGE_NO, 1);

				SetEntityMoveType(i, MOVETYPE_NONE);
			}
		}

		CreateTimer(3.0, Timer_PrepareEvent);

		CPrintToChatAll("%s %t", g_sPrefix, "freeday_now");
		PrintCenterTextAll("%t", "freeday_now_nc");
	}
	else
	{
		g_bStartFreeday = true;
		g_iCoolDown++;

		CPrintToChatAll("%s %t", g_sPrefix, "freeday_next");
		PrintCenterTextAll("%t", "freeday_next_nc");
	}
}

public Action Timer_PrepareEvent(Handle timer)
{
	PrepareDay();
}

void PrepareDay()
{
	if (gp_bSmartJailDoors)
	{
		SJD_OpenDoors();
	}

/*
	if (!gp_bSmartJailDoors || (gp_bSmartJailDoors && (SJD_IsCurrentMapConfigured() != true))) // spawn Terrors to CT Spawn 
	{
		float g_fPos[3];
		int RandomCT = 0;
		for (int i = 1; i <= MaxClients; i++)		{
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
			for (int i = 1; i <= MaxClients; i++)GetClientAbsOrigin(RandomCT, g_fPos);
				
				g_fPos[2] = g_fPos[2] + 5;
				
				TeleportEntity(i, g_fPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
*/
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		CreateInfoPanel(i);

		if (IsPlayerAlive(i))
		{
			SetEntProp(i, Prop_Send, "m_CollisionGroup", 2);  // 2 - none / 5 - 'default'

			if (!gc_bdamage.BoolValue)
			{
				SetEntProp(i, Prop_Data, "m_takedamage", DAMAGE_NO, 1); // Disable damage received (godmode)
			}
			else
			{
				SetEntProp(i, Prop_Data, "m_takedamage", DAMAGE_YES, 1); // Allow damage receive (no godmode, normal)
			}

			SetEntityMoveType(i, MOVETYPE_WALK);
		}
	}

	if (gp_bMyJailbreak)
	{
		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);
	}

	if (gp_bMyJBWarden && !gc_bWarden.BoolValue)
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

	if (g_bRepeatFirstFreeday)
	{
		SetTeamScore(CS_TEAM_CT, 0);
		SetTeamScore(CS_TEAM_T, 0);
		g_bRepeatFirstFreeday = false;
	}

	if (gc_bFirst.BoolValue)
	{
		if (((GetTeamClientCount(CS_TEAM_CT) == 0) || (GetTeamClientCount(CS_TEAM_T) == 0)) && (GetTeamScore(CS_TEAM_CT) + GetTeamScore(CS_TEAM_T) == 0))
		{
			g_bRepeatFirstFreeday = true;
		}
	}

	GameRules_SetProp("m_iRoundTime", gc_iRoundTime.IntValue*60, 4, 0, true);

	CreateTimer (gc_iRespawnTime.FloatValue, Timer_StopRespawn);

	PrintCenterTextAll("%t", "freeday_start_nc");
	CPrintToChatAll("%s %t", g_sPrefix, "freeday_start");
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "freeday_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "freeday_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "freeday_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line7", client);
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

public Action Timer_StopRespawn(Handle timer)
{
	g_bAllowRespawn = false;
}

public Action Timer_Respawn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client)
		return Plugin_Handled;

	CS_RespawnPlayer(client);

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