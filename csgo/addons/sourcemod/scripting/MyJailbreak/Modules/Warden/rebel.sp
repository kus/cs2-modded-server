/*
 * MyJailbreak - Warden - Mark Rebel Module.
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

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <hosties>
#include <lastrequest>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bMarkRebel;
ConVar gc_bMarkRebelDeputy;
ConVar gc_sCustomCommandRebel;


// Start
public void MarkRebel_OnPluginStart()
{
	// Translation
	LoadTranslations("hosties.phrases");

	// Client commands
	RegConsoleCmd("sm_markrebel", Command_MarkRebel, "Allows Warden to mark/unmark prisoner as rebel");

	// AutoExecConfig
	gc_bMarkRebel = AutoExecConfig_CreateConVar("sm_warden_mark_rebel", "1", "0 - disabled, 1 - enable allow warden to mark/unmark prisoner as rebel (hosties)", _, true, 0.0, true, 1.0);
	gc_bMarkRebelDeputy = AutoExecConfig_CreateConVar("sm_warden_mark_rebel_deputy", "1", "0 - disabled, 1 - enable 'mark/unmark prisoner as rebel'-feature for deputy, too", _, true, 0.0, true, 1.0);
	gc_sCustomCommandRebel = AutoExecConfig_CreateConVar("sm_warden_cmds_rebel", "sr, srebel, setrebel, rebelmenu", "Set your custom chat commands for un/mark rebel(!markrebel (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_MarkRebel(int client, int args)
{
	if (gc_bPlugin.BoolValue && g_bEnabled && gp_bHosties && gp_bLastRequest)
	{
		if (gc_bMarkRebel.BoolValue)
		{
			if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bMarkRebelDeputy.BoolValue))
			{
				Menu_MarkRebelMenu(client);
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
		}
	}

	return Plugin_Handled;
}


/******************************************************************************
                   MENUS
******************************************************************************/


public Action Menu_MarkRebelMenu(int client)
{
	char menuinfo[255];

	Menu MarkMenu = new Menu(Handler_MarkRebelMenu);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_rebel_title", client);
	MarkMenu.SetTitle(menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_rebel_mark", client);
	MarkMenu.AddItem("rebel", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_rebel_unmark", client);
	MarkMenu.AddItem("unrebel", menuinfo);

	MarkMenu.ExitButton = true;
	MarkMenu.Display(client, MENU_TIME_FOREVER);
}


public int Handler_MarkRebelMenu(Menu MarkMenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		MarkMenu.GetItem(selection, info, sizeof(info));
		
		if (strcmp(info, "rebel") == 0)
		{
			char info1[255];
			Menu MarkRebel = CreateMenu(Handler_MarkRebel);
			Format(info1, sizeof(info1), "%T", "warden_choose", client);
			MarkRebel.SetTitle(info1);
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
			{
				if (!IsClientRebel(i)&& (GetClientTeam(i) == CS_TEAM_T))
				{
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N", i);
					MarkRebel.AddItem(userid, username);
				}
			}
			MarkRebel.ExitBackButton = true;
			MarkRebel.ExitButton = true;
			MarkRebel.Display(client, MENU_TIME_FOREVER);
		}
		if (strcmp(info, "unrebel") == 0)
		{
			char info1[255];
			Menu UnMarkMenu = CreateMenu(Handler_UnMarkRebel);
			Format(info1, sizeof(info1), "%T", "warden_choose", client);
			UnMarkMenu.SetTitle(info1);
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
			{
				if (IsClientRebel(i))
				{
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N", i);
					UnMarkMenu.AddItem(userid, username);
				}
			}
			UnMarkMenu.ExitBackButton = true;
			UnMarkMenu.ExitButton = true;
			UnMarkMenu.Display(client, MENU_TIME_FOREVER);
		}
	}
	else if (action == MenuAction_Cancel) 
	{
		if (selection == MenuCancel_ExitBack) 
		{
			Menu_MarkRebelMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete MarkMenu;
	}
}


public int Handler_MarkRebel(Menu MarkRebel, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		MarkRebel.GetItem(selection, info, sizeof(info));
		int i = GetClientOfUserId(StringToInt(info));
		ChangeRebelStatus(i, true);
		
		Menu_MarkRebelMenu(client);
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
		delete MarkRebel;
	}
}


public int Handler_UnMarkRebel(Menu UnMarkRebel, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		UnMarkRebel.GetItem(selection, info, sizeof(info));
		int i = GetClientOfUserId(StringToInt(info));
		ChangeRebelStatus(i, false);
		SetEntityRenderColor(i, 255, 255, 255, 255);
		
		Menu_MarkRebelMenu(client);
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
		delete UnMarkRebel;
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Rebel_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Custom rebel command
	gc_sCustomCommandRebel.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_MarkRebel, "Allows Warden to mark/unmark prisoner as rebel");
	}
}