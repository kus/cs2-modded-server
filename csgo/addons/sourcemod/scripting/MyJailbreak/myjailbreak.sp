/*
 * MyJailbreak - Core Plugin.
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
#include <autoexecconfig>
#include <mystocks>
#include <myjailbreak>

#undef REQUIRE_PLUGIN
#include <hosties>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bTag;
ConVar gc_bLogging;
ConVar gc_bShootButton;
ConVar gc_sCustomCommandEndRound;
ConVar gc_bEndRound;
ConVar gc_iRandomEventDay;
ConVar gc_iRandomEventDayPercent;
ConVar gc_iRandomEventDayStartDelay;
ConVar gc_iRandomEventDayType;
ConVar gc_bDisableMedic;

ConVar gc_sTags;

// Booleans
bool g_bEventDayPlanned = false;
bool g_bEventDayRunning = false;
bool g_bLastGuardRuleActive = false;
bool gp_bHosties;

// Integers
int g_iRandomArraySize = 0;
int g_iRoundNumber = 0;

// Handles
Handle gF_OnEventDayStart;
Handle gF_OnEventDayEnd;
Handle gF_ResetEventDay;
Handle gF_OnCheckVIP;

ArrayList g_aEventDayList = null;

ConVar Cvar_sm_hosties_announce_rebel_down;
ConVar Cvar_sm_hosties_rebel_color;
ConVar Cvar_sm_hosties_mute;
ConVar Cvar_sm_hosties_announce_attack;
ConVar Cvar_sm_hosties_announce_wpn_attack;
ConVar Cvar_sm_hosties_freekill_notify;
ConVar Cvar_sm_hosties_freekill_treshold;

int OldCvar_sm_hosties_rebel_color;
int OldCvar_sm_hosties_announce_rebel_down;
int OldCvar_sm_hosties_mute;
int OldCvar_sm_hosties_announce_attack;
int OldCvar_sm_hosties_announce_wpn_attack;
int OldCvar_sm_hosties_freekill_notify;
int OldCvar_sm_hosties_freekill_treshold;

// Strings
char g_sEventDayName[128] = "none";

// Modules
#include "MyJailbreak/Modules/fog.sp"
#include "MyJailbreak/Modules/beacon.sp"

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Core",
	author = "shanapu",
	description = "MyJailbreak - core plugin",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Admin commands
	RegAdminCmd("sm_endround", Command_EndRound, ADMFLAG_ROOT);
	RegAdminCmd("sm_resetevent", Command_ResetEvent, ADMFLAG_ROOT);

	// AutoExecConfig
	DirExistsEx("cfg/MyJailbreak/EventDays");

	AutoExecConfig_SetFile("MyJailbreak", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	// Create Console Variables
	gc_bTag = AutoExecConfig_CreateConVar("sm_myjb_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", _, true, 0.0, true, 1.0);
	gc_bLogging = AutoExecConfig_CreateConVar("sm_myjb_log", "1", "Allow MyJailbreak to log events, freekills & eventdays in logs/MyJailbreak", _, true, 0.0, true, 1.0);
	gc_bShootButton = AutoExecConfig_CreateConVar("sm_myjb_shoot_buttons", "1", "0 - disabled, 1 - allow player to trigger a map button by shooting it", _, true, 0.0, true, 1.0);
	gc_sCustomCommandEndRound = AutoExecConfig_CreateConVar("sm_myjb_cmds_endround", "er, stopround, end", "Set your custom chat commands for admins to end the current round(!endround (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_bEndRound = AutoExecConfig_CreateConVar("sm_myjb_allow_endround", "0", "0 - disabled, 1 - enable !endround command for testing (disable against abusing)", _, true, 0.0, true, 1.0);
	gc_iRandomEventDay = AutoExecConfig_CreateConVar("sm_myjb_random_round", "6", "0 - disabled / Every x round could be an event day or voting", _, true, 0.0);
	gc_iRandomEventDayType = AutoExecConfig_CreateConVar("sm_myjb_random_type", "1", "0 - Start an eventday voting / 1 - start an random eventday", _, true, 0.0, true, 1.0);
	gc_iRandomEventDayPercent = AutoExecConfig_CreateConVar("sm_myjb_random_chance", "60", "Chance that the choosen round would be an event day", _, true, 1.0, true, 100.0);
	gc_iRandomEventDayStartDelay = AutoExecConfig_CreateConVar("sm_myjb_random_mapstart_delay", "6", "Wait after mapchange x rounds before try first random eventday or voting", _, true, 0.0);
	gc_bDisableMedic = AutoExecConfig_CreateConVar("sm_myjb_medic", "1", "0 - disabled, 1 - disable medic room when event day running", _, true, 0.0, true, 1.0);

	Beacon_OnPluginStart();

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	char sBuffer[256];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "logs/MyJailbreak");
	DirExistsEx(sBuffer);

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);

	g_aEventDayList = new ArrayList(32);
	
	// Find Cvars
	gc_sTags = FindConVar("sv_tags");
}

public void OnAllPluginsLoaded()
{
	gp_bHosties = LibraryExists("lastrequest");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = true;
	}
}

// Initialize Plugin - check/set sv_tags for MyJailbreak
public void OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// End round
	gc_sCustomCommandEndRound.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ","");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegAdminCmd(sCommand, Command_EndRound, ADMFLAG_CHANGEMAP);
		}
	}

	if (!gc_bTag.BoolValue)
		return;

	char sTags[128];
	gc_sTags.GetString(sTags, sizeof(sTags));

	if (StrContains(sTags, "MyJailbreak", false) != -1)
		return;

	StrCat(sTags, sizeof(sTags), ", MyJailbreak");
	gc_sTags.SetString(sTags);
}


/******************************************************************************
                   COMMANDS
******************************************************************************/

// End the current round instandly
public Action Command_EndRound(int client, int args)
{
	if (!gc_bEndRound.BoolValue)
		return Plugin_Handled;

	CS_TerminateRound(5.5, CSRoundEnd_Draw, true);

	return Plugin_Handled;
}

public Action Command_ResetEvent(int client, int args)
{
	if (g_bEventDayPlanned || g_bEventDayRunning)
	{
		g_bEventDayPlanned = false;
		g_bEventDayRunning = false;
		Format(g_sEventDayName, sizeof(g_sEventDayName), "none");

		Call_StartForward(gF_ResetEventDay);
		Call_Finish();
	}
	else
	{
		ReplyToCommand(client, "[MyJB] No Event Day planned/running");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (gc_bShootButton.BoolValue)
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "func_button")) != -1)
		{
			SetEntProp(ent, Prop_Data, "m_spawnflags", GetEntProp(ent, Prop_Data, "m_spawnflags")|512);
		}
	}

	if (gc_iRandomEventDay.IntValue == 0 || g_iRandomArraySize == 0)
		return;

	if (MyJailbreak_IsEventDayPlanned() || MyJailbreak_IsEventDayRunning())
		return;

	g_iRoundNumber++;

	if (g_iRoundNumber <= gc_iRandomEventDayStartDelay.IntValue)
		return;

	g_iRoundNumber -= gc_iRandomEventDay.IntValue;

	int chance = GetRandomInt(0, 100);
	if (chance > gc_iRandomEventDayPercent.IntValue)
		return;

	//hinweis chat random round

	if (gc_iRandomEventDayType.BoolValue)
	{
		char buffer[32];
		int randomEvent = GetRandomInt(0, g_aEventDayList.Length-1);
		g_aEventDayList.GetString(randomEvent, buffer, sizeof(buffer));
		ServerCommand("sm_set%s", buffer);
	}
	else
	{
		ServerCommand("sm_voteday");
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Prepare modules
public void OnMapStart()
{
	Fog_OnMapStart();
	Beacon_OnMapStart();
	g_bLastGuardRuleActive = false;
	g_iRoundNumber = 0;

	g_aEventDayList.Clear();
}

// Reset Plugin
public void OnMapEnd()
{
	g_bEventDayPlanned = false;
	g_bEventDayRunning = false;
	g_bLastGuardRuleActive = false;

	MyJailbreak_SetEventDayName("none");

	Beacon_OnMapEnd();
}


/******************************************************************************
                   NATIVES
******************************************************************************/

// Register Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Game is not supported. CS:GO ONLY");
	}

	CreateNative("MyJailbreak_AddEventDay", Native_AddEventDay);
	CreateNative("MyJailbreak_RemoveEventDay", Native_RemoveEventDay);

	CreateNative("MyJailbreak_GetEventDays", Native_GetEventDays);

	CreateNative("MyJailbreak_SetEventDayName", Native_SetEventDayName);
	CreateNative("MyJailbreak_GetEventDayName", Native_GetEventDayName);
	CreateNative("MyJailbreak_IsEventDayRunning", Native_IsEventDayRunning);
	CreateNative("MyJailbreak_SetEventDayRunning", Native_SetEventDayRunning);
	CreateNative("MyJailbreak_SetEventDayPlanned", Native_SetEventDayPlanned);
	CreateNative("MyJailbreak_IsEventDayPlanned", Native_IsEventDayPlanned);
	CreateNative("MyJailbreak_IsLastGuardRule", Native_IsLastGuardRule);
	CreateNative("MyJailbreak_SetLastGuardRule", Native_SetLastGuardRule);

	CreateNative("MyJailbreak_ActiveLogging", Native_GetActiveLogging);

	CreateNative("MyJailbreak_FogOn", Native_FogOn);
	CreateNative("MyJailbreak_FogOff", Native_FogOff);

	CreateNative("MyJailbreak_BeaconOn", Native_BeaconOn);
	CreateNative("MyJailbreak_BeaconOff", Native_BeaconOff);

	CreateNative("MyJailbreak_CheckVIPFlags", Native_CheckVIPFlags);

	gF_OnEventDayStart = CreateGlobalForward("MyJailbreak_OnEventDayStart", ET_Ignore, Param_String);
	gF_OnEventDayEnd = CreateGlobalForward("MyJailbreak_OnEventDayEnd", ET_Ignore, Param_String, Param_Cell);
	gF_ResetEventDay = CreateGlobalForward("MyJailbreak_ResetEventDay", ET_Ignore);
	gF_OnCheckVIP = CreateGlobalForward("MyJailbreak_OnCheckVIP", ET_Single, Param_Cell, Param_String);

	RegPluginLibrary("myjailbreak");

	return APLRes_Success;
}


public int Native_GetEventDays(Handle plugin, int argc)
{
	ArrayList array = view_as<ArrayList>(GetNativeCell(1));
	
	if (array == null)
		return;

	char eventname[PLATFORM_MAX_PATH];

	for (int i = 0; i < g_aEventDayList.Length; i++)
	{
		g_aEventDayList.GetString(i, eventname, sizeof(eventname));
		array.PushString(eventname);
	}

	return;
}


public int Native_AddEventDay(Handle plugin, int argc)
{
	char sBuffer[32];

	GetNativeString(1, sBuffer, sizeof(sBuffer));

	int iIndex = g_aEventDayList.FindString(sBuffer);
	if (iIndex != -1)
		return;

	g_aEventDayList.PushString(sBuffer);

	SortEventDays();
}

public int Native_RemoveEventDay(Handle plugin, int argc)
{
	char sBuffer[32];
	GetNativeString(1, sBuffer, sizeof(sBuffer));

	int iIndex = g_aEventDayList.FindString(sBuffer);
	if (iIndex != -1)
	{
		g_aEventDayList.Erase(iIndex);
	}
}

// Boolean Is Event Day running (true = running)
public int Native_IsEventDayRunning(Handle plugin, int argc)
{
	if (!g_bEventDayRunning)
		return false;

	return true;
}

// Boolean Is Event Day planned (true = planned)
public int Native_IsEventDayPlanned(Handle plugin, int argc)
{
	if (!g_bEventDayPlanned)
		return false;

	return true;
}

// Boolean Set Event Day planned (true = planned)
public int Native_SetEventDayPlanned(Handle plugin, int argc)
{
	g_bEventDayPlanned = GetNativeCell(1);
}

// Set Event Day Name
public int Native_SetEventDayName(Handle plugin, int argc)
{
	char buffer[64];
	GetNativeString(1, buffer, 64);

	Format(g_sEventDayName, sizeof(g_sEventDayName), buffer);
}

// Get Event Day Name
public int Native_GetEventDayName(Handle plugin, int argc)
{
	SetNativeString(1, g_sEventDayName, sizeof(g_sEventDayName));
}

// Boolean Is Last Guard Rule active (true = active)
public int Native_IsLastGuardRule(Handle plugin, int argc)
{
	if (!g_bLastGuardRuleActive)
		return false;

	return true;
}

// Boolean Set Last Guard Rule active (true = active)
public int Native_SetLastGuardRule(Handle plugin, int argc)
{
	g_bLastGuardRuleActive = GetNativeCell(1);
}

// Check if logging is active
public int Native_GetActiveLogging(Handle plugin, int argc)
{
	if (!gc_bLogging.BoolValue)
		return false;

	return true;
}

// Boolean Set Event Day running (true = running)
public int Native_SetEventDayRunning(Handle plugin, int argc)
{
	g_bEventDayRunning = GetNativeCell(1);
	int winner = GetNativeCell(2);

	if (g_bEventDayRunning)
	{
		Call_StartForward(gF_OnEventDayStart);
		Call_PushString(g_sEventDayName);
		Call_Finish();

		if (gp_bHosties)
		{
			ToggleConVars(true);
		}

		ToggleHeal(false);
	}
	else
	{
		Call_StartForward(gF_OnEventDayEnd);
		Call_PushString(g_sEventDayName);
		Call_PushCell(winner);
		Call_Finish();

		if (gp_bHosties)
		{
			ToggleConVars(false);
		}

		ToggleHeal(true);
	}
}


public int Native_CheckVIPFlags(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	char sCommand[24];
	GetNativeString(2, sCommand, sizeof(sCommand));

	char sBuffer[32];
	ConVar cFlags = GetNativeCell(3);
	cFlags.GetString(sBuffer, sizeof(sBuffer));

	if (strlen(sBuffer) == 0) // ???
		return true;

	int iFlags = ReadFlagString(sBuffer);
	if (CheckCommandAccess(client, sCommand, iFlags))
		return true;

	GetNativeString(4, sBuffer, sizeof(sBuffer));

	bool result = false;
	Call_StartForward(gF_OnCheckVIP);
	Call_PushCell(client);
	Call_PushString(sBuffer);
	Call_Finish(result);

	return result;
}


void ToggleConVars(bool IsEventDay)
{
	if (!gp_bHosties)
		return;

	if (IsEventDay)
	{
		// Get the Cvar Value
		Cvar_sm_hosties_announce_rebel_down = FindConVar("sm_hosties_announce_rebel_down");
		Cvar_sm_hosties_rebel_color = FindConVar("sm_hosties_rebel_color");
		Cvar_sm_hosties_mute = FindConVar("sm_hosties_mute");
		Cvar_sm_hosties_announce_attack = FindConVar("sm_hosties_announce_attack");
		Cvar_sm_hosties_announce_wpn_attack = FindConVar("sm_hosties_announce_wpn_attack");
		Cvar_sm_hosties_freekill_notify = FindConVar("sm_hosties_freekill_notify");
		Cvar_sm_hosties_freekill_treshold = FindConVar("sm_hosties_freekill_treshold");

		// Save the Cvar Value
		OldCvar_sm_hosties_rebel_color = Cvar_sm_hosties_rebel_color.IntValue;
		OldCvar_sm_hosties_announce_rebel_down = Cvar_sm_hosties_announce_rebel_down.IntValue;
		OldCvar_sm_hosties_mute = Cvar_sm_hosties_mute.IntValue;
		OldCvar_sm_hosties_announce_attack = Cvar_sm_hosties_announce_attack.IntValue;
		OldCvar_sm_hosties_announce_wpn_attack = Cvar_sm_hosties_announce_wpn_attack.IntValue;
		OldCvar_sm_hosties_freekill_notify = Cvar_sm_hosties_freekill_notify.IntValue;
		OldCvar_sm_hosties_freekill_treshold = Cvar_sm_hosties_freekill_treshold.IntValue;

		// Change the Cvar Value
		Cvar_sm_hosties_announce_rebel_down.IntValue = 0;
		Cvar_sm_hosties_rebel_color.IntValue = 0;
		Cvar_sm_hosties_mute.IntValue = 0;
		Cvar_sm_hosties_announce_attack.IntValue = 0;
		Cvar_sm_hosties_announce_wpn_attack.IntValue = 0;
		Cvar_sm_hosties_freekill_notify.IntValue = 0;
		Cvar_sm_hosties_freekill_treshold.IntValue = 0;
	}
	else
	{
		// Replace the Cvar Value with old value
		Cvar_sm_hosties_announce_rebel_down.IntValue = OldCvar_sm_hosties_announce_rebel_down;
		Cvar_sm_hosties_rebel_color.IntValue = OldCvar_sm_hosties_rebel_color;
		Cvar_sm_hosties_mute.IntValue = OldCvar_sm_hosties_mute;
		Cvar_sm_hosties_announce_attack.IntValue = OldCvar_sm_hosties_announce_attack;
		Cvar_sm_hosties_announce_wpn_attack.IntValue = OldCvar_sm_hosties_announce_wpn_attack;
		Cvar_sm_hosties_freekill_notify.IntValue = OldCvar_sm_hosties_freekill_notify;
		Cvar_sm_hosties_freekill_treshold.IntValue = OldCvar_sm_hosties_freekill_treshold;
	}
}

void ToggleHeal(bool heal)
{
	if (!gc_bDisableMedic.BoolValue)
		return;

	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "trigger_hurt")) != -1)
	{
		if (GetEntPropFloat(ent, Prop_Data, "m_flDamage") < 0)
		{
			AcceptEntityInput(ent, heal ? "Enable" : "Disable");
		}
	}
}

void SortEventDays()
{
	char sBuffer[100];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "configs/MyJailbreak/sorting_events.ini");
	File hFile = OpenFile(sBuffer, "r");
	if (hFile == null)
	{
		LogError("couldn't read from file: %s", sBuffer);
		delete hFile;
		return;
	}
	
	int num = -1;
	while (hFile.EndOfFile() && hFile.ReadLine(sBuffer, sizeof(sBuffer)))
	{
		TrimString(sBuffer);

		int index = g_aEventDayList.FindString(sBuffer);
		if (index != -1)
		{
			num++;
			g_aEventDayList.ShiftUp(num);
			g_aEventDayList.SetString(num, sBuffer);
			g_aEventDayList.Erase(index+1);
		}
	}
	delete hFile;
}