/*
 * MyJailbreak - Request Plugin.
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
#include <myjailbreak>
#include <smartjaildoors>
#include <warden>
#include <myjbwarden>
#define REQUIRE_PLUGIN

// Required Plugins
#include <hosties>
#include <lastrequest>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bSounds;
ConVar gc_sPrefix;
ConVar gc_sCustomCommandRequest;

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsRequest = false;
bool g_bIsLR = false;
bool gp_bMyJailBreak = false;
bool gp_bSmartJailDoors = false;
bool gp_bWarden = false;
bool gp_bMyJBWarden = false;

// Integers
int g_iKilledBy[MAXPLAYERS+1];
int g_iHasKilled[MAXPLAYERS+1];

// Handles
Handle g_hTimerRequest;

// Float
float g_fDeathOrigin[MAXPLAYERS+1][3];

// Strings
char g_sPrefix[64];

// Modules
#include "MyJailbreak/Modules/Request/refuse.sp"
#include "MyJailbreak/Modules/Request/capitulation.sp"
#include "MyJailbreak/Modules/Request/heal.sp"
#include "MyJailbreak/Modules/Request/repeat.sp"
#include "MyJailbreak/Modules/Request/freekill.sp"
#include "MyJailbreak/Modules/Request/killreason.sp"

// Info
public Plugin myinfo = 
{
	name = "MyJailbreak - Request",
	author = "shanapu",
	description = "Requests - refuse, capitulation/pardon, heal",
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
	LoadTranslations("MyJailbreak.Request.phrases");
	LoadTranslations("MyJailbreak.Warden.phrases");

	// Client Commands
	RegConsoleCmd("sm_request", Command_RequestMenu, "Open the requests menu");

	// AutoExecConfig
	AutoExecConfig_SetFile("Request", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_request_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_request_enable", "1", "0 - disabled, 1 - enable Request Plugin");
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_request_prefix", "[{green}MyJB.Request{default}]", "Set your chat prefix for this plugin.");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_request_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sCustomCommandRequest = AutoExecConfig_CreateConVar("sm_request_cmds", "req, requestmenu", "Set your custom chat command for requestmenu (!request (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	Refuse_OnPluginStart();
	Repeat_OnPluginStart();
	Heal_OnPluginStart();
	Capitulation_OnPluginStart();
	Freekill_OnPluginStart();
	KillReason_OnPluginStart();

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)		{
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
	if (convar == gc_sPrefix)
	{
		strcopy(g_sPrefix, sizeof(g_sPrefix), newValue);
	}
}

public void OnAllPluginsLoaded()
{
	gp_bMyJailBreak = LibraryExists("myjailbreak");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bWarden = LibraryExists("warden");
	gp_bMyJBWarden = LibraryExists("myjbwarden");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailBreak = false;
	}
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = false;
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
	if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailBreak = true;
	}
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = true;
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

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_RequestMenu(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (GetClientTeam(client) == CS_TEAM_T && IsValidClient(client, false, true))
		{
			Menu reqmenu = new Menu(Command_RequestMenuHandler);
			char menuinfo19[255], menuinfo20[255], menuinfo21[255], menuinfo22[255], menuinfo29[255];

			Format(menuinfo29, sizeof(menuinfo29), "%T", "request_menu_title", client);
			reqmenu.SetTitle(menuinfo29);

			if (gc_bFreeKill.BoolValue && (!IsPlayerAlive(client)))
			{
				Format(menuinfo19, sizeof(menuinfo19), "%T", "request_menu_freekill", client);
				reqmenu.AddItem("freekill", menuinfo19);
			}

			if (gc_bRefuse.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo19, sizeof(menuinfo19), "%T", "request_menu_refuse", client);
				reqmenu.AddItem("refuse", menuinfo19);
			}

			if (gc_bCapitulation.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo20, sizeof(menuinfo20), "%T", "request_menu_capitulation", client);
				reqmenu.AddItem("capitulation", menuinfo20);
			}

			if (gc_bRepeat.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo21, sizeof(menuinfo21), "%T", "request_menu_repeat", client);
				reqmenu.AddItem("repeat", menuinfo21);
			}

			if (gc_bHeal.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo22, sizeof(menuinfo22), "%T", "request_menu_heal", client);
				reqmenu.AddItem("heal", menuinfo22);
			}

			reqmenu.ExitButton = true;
			reqmenu.ExitBackButton = true;
			reqmenu.Display(client, MENU_TIME_FOREVER);
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "request_notalivect");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	delete g_hTimerRequest;

	g_bIsRequest = false;
	g_bIsLR = false;

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_iKilledBy[i] = 0;
		g_iHasKilled[i] = 0;
	}
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	g_bIsLR = false;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victimID = event.GetInt("userid"); // Get the dead user id
	int victim = GetClientOfUserId(victimID); // Get the dead clients id
	int attackerID = event.GetInt("attacker"); // Get the user clients id
	int attacker = GetClientOfUserId(attackerID); // Get the attacker clients id

	if (IsValidClient(attacker, true, false) && (attacker != victim))
	{
		g_iKilledBy[victim] = attackerID;
		g_iHasKilled[attacker] = victimID;
	}
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void OnMapStart()
{
	Refuse_OnMapStart();
	Capitulation_OnMapStart();
	Repeat_OnMapStart();

	g_bIsLR = false;
}

public void OnConfigsExecuted()
{
	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));

	Refuse_OnConfigsExecuted();
	Capitulation_OnConfigsExecuted();
	Heal_OnConfigsExecuted();
	Repeat_OnConfigsExecuted();

	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// request
	gc_sCustomCommandRequest.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_RequestMenu, "Open the requests menu");
	}
}

public void OnClientPutInServer(int client)
{
	Refuse_OnClientPutInServer(client);
	Capitulation_OnClientPutInServer(client);
	Heal_OnClientPutInServer(client);
	Repeat_OnClientPutInServer(client);
	Freekill_OnClientPutInServer(client);
}

public void OnClientDisconnect(int client)
{
	Refuse_OnClientDisconnect(client);
	Heal_OnClientDisconnect(client);
	Repeat_OnClientDisconnect(client);
}

public void OnAvailableLR(int Announced)
{
	Capitulation_OnAvailableLR(Announced);
	g_bIsLR = true;
}

/******************************************************************************
                   MENUS
******************************************************************************/

public int Command_RequestMenuHandler(Menu reqmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		reqmenu.GetItem(selection, info, sizeof(info));

		if (strcmp(info, "refuse") == 0)
		{
			FakeClientCommand(client, "sm_refuse");
		}
		else if (strcmp(info, "freekill") == 0)
		{
			FakeClientCommand(client, "sm_freekill");
		}
		else if (strcmp(info, "repeat") == 0)
		{
			FakeClientCommand(client, "sm_repeat");
		}
		else if (strcmp(info, "capitulation") == 0)
		{
			FakeClientCommand(client, "sm_capitulation");
		}
		else if (strcmp(info, "heal") == 0)
		{
			FakeClientCommand(client, "sm_heal");
		}
	}
	else if (action == MenuAction_Cancel) 
	{
		if (selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete reqmenu;
	}
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_IsRequest(Handle timer)
{
	g_bIsRequest = false;
	g_hTimerRequest = null;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			continue;

		if (!g_bFreeKilled[i])
			continue;

		g_bFreeKilled[i] = false;
	}
}

bool MyJB_CheckVIPFlags(int client, const char[] command, ConVar flags, char[] feature)
{
	if (gp_bMyJailBreak)
		return MyJailbreak_CheckVIPFlags(client, command, flags, feature);

	char sBuffer[32];
	flags.GetString(sBuffer, sizeof(sBuffer));

	if (strlen(sBuffer) == 0) // ???
		return true;

	int iFlags = ReadFlagString(sBuffer);

	return CheckCommandAccess(client, command, iFlags);
}