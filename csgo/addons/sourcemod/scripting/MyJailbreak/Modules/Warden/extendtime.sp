/*
 * MyJailbreak - Warden - Extend Round Time Module.
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
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <myjbwarden>
#include <mystocks>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bExtend;
ConVar gc_bExtendDeputy;
ConVar gc_iExtendLimit;
ConVar gc_sCustomCommandExtend;

// Extern Convars
ConVar g_iMPRoundTime;

// Integers
int g_iExtendNumber[MAXPLAYERS+1];
int g_iRoundTime;

// Start
public void ExtendTime_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_extend", Command_ExtendRoundTime, "Allows the warden to extend the roundtime");

	// AutoExecConfig
	gc_bExtend = AutoExecConfig_CreateConVar("sm_warden_extend", "1", "0 - disabled, 1 - Allows the warden to extend the roundtime", _, true, 0.0, true, 1.0);
	gc_bExtendDeputy = AutoExecConfig_CreateConVar("sm_warden_extend_deputy", "1", "0 - disabled, 1 - enable the 'extend the roundtime'-feature for deputy, too", _, true, 0.0, true, 1.0);
	gc_iExtendLimit = AutoExecConfig_CreateConVar("sm_warden_extend_limit", "2", "How many time a warden can extend the round?", _, true, 1.0);
	gc_sCustomCommandExtend = AutoExecConfig_CreateConVar("sm_warden_cmds_extend", "extendtime, moretime", "Set your custom chat commands for extend time.(!extend (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	// Hooks
	HookEvent("round_start", ExtendTime_Event_RoundStart);
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_ExtendRoundTime(int client, int args)
{
	if (gc_bExtend.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bExtendDeputy.BoolValue))
		{
			if (g_iExtendNumber[client] > 0)
			{
				char menuinfo[255];
				
				Menu menu = new Menu(Handler_ExtendRoundTime);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_time_title", client);
				menu.SetTitle(menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_120", client);
				menu.AddItem("120", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_180", client);
				menu.AddItem("180", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_300", client);
				menu.AddItem("300", menuinfo);
				
				menu.ExitBackButton = true;
				menu.ExitButton = true;
				menu.Display(client, 20);
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_extendtimes", gc_iExtendLimit.IntValue);
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void ExtendTime_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) g_iExtendNumber[i] = gc_iExtendLimit.IntValue;

	g_iMPRoundTime = FindConVar("mp_roundtime");
	g_iRoundTime = g_iMPRoundTime.IntValue * 60;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

public Action ExtendTime(int client, int args)
{
	GameRules_SetProp("m_iRoundTime", GameRules_GetProp("m_iRoundTime", 4, 0)+args, 4, 0, true);
	int extendminute = (args/60);
	g_iRoundTime = g_iRoundTime + args;
	CPrintToChatAll("%s %t", g_sPrefix, "warden_extend", client, extendminute);

	return Plugin_Handled;
}

/******************************************************************************
                   MENUS
******************************************************************************/

public int Handler_ExtendRoundTime(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));

		if (strcmp(info, "120") == 0)
		{
			ExtendTime(client, 120);
		}
		else if (strcmp(info, "180") == 0)
		{
			ExtendTime(client, 180);
		}
		else if (strcmp(info, "300") == 0)
		{
			ExtendTime(client, 300);
		}

		if (g_bMenuClose != null)
		{
			if (!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
		g_iExtendNumber[client]--;
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
		delete menu;
	}
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void ExtendTime_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// extend time
	gc_sCustomCommandExtend.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_ExtendRoundTime, "Allows the warden to extend the roundtime");
	}
}