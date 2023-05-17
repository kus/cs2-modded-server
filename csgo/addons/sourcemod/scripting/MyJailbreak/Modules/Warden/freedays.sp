/*
 * MyJailbreak - Warden - Freedays Module.
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
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bGetFreeDay[MAXPLAYERS+1];
bool g_bHasFreeDay[MAXPLAYERS+1];

// Console Variables
ConVar gc_sCustomCommandGiveFreeDay;
ConVar gc_sCustomCommandRemoveFreeDay;
ConVar gc_bFreeDay;
ConVar gc_bFreeDayDeputy;
ConVar gc_bFreeDayGuards;
ConVar gc_iFreeDayColorRed;
ConVar gc_iFreeDayColorGreen;
ConVar gc_iFreeDayColorBlue;

// Handle
Handle g_hDataPackFreeday;

// Start
public void Freedays_OnPluginStart()
{
	// Client Commands
	RegConsoleCmd("sm_givefreeday", Command_FreeDay, "Allows a warden to give a freeday to a player");
	RegConsoleCmd("sm_removefreeday", Command_RemoveFreeDay, "Allows a warden to remove a freeday from a player");

	// AutoExecConfig
	gc_bFreeDay = AutoExecConfig_CreateConVar("sm_warden_freeday_enable", "1", "0 - disabled, 1 - Allow the warden to set a personal freeday", _, true, 0.0, true, 1.0);
	gc_sCustomCommandGiveFreeDay = AutoExecConfig_CreateConVar("sm_warden_cmds_freeday", "gfd, setfreeday, sfd", "Set your custom chat command for give a freeday(!givefreeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))", _, true, 0.0, true, 1.0);
	gc_sCustomCommandRemoveFreeDay = AutoExecConfig_CreateConVar("sm_warden_cmds_freeday_remove", "rfd, nofreeday", "Set your custom chat command for remove a freeday(!removefreeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))", _, true, 0.0, true, 1.0);
	gc_iFreeDayColorRed = AutoExecConfig_CreateConVar("sm_warden_freeday_color_red", "0", "What color to turn the player with freeday into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iFreeDayColorGreen = AutoExecConfig_CreateConVar("sm_warden_freeday_color_green", "200", "What color to turn the player with freeday into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iFreeDayColorBlue = AutoExecConfig_CreateConVar("sm_warden_freeday_color_blue", "0", "What color to turn the player with freeday into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_bFreeDayDeputy = AutoExecConfig_CreateConVar("sm_warden_freeday_deputy", "1", "0 - disabled, 1 - Allow the deputy to set a personal freeday", _, true, 0.0, true, 1.0);
	gc_bFreeDayGuards = AutoExecConfig_CreateConVar("sm_warden_freeday_guards", "0", "0 - disabled, 1 - Allow all the guards to set a personal freeday", _, true, 0.0, true, 1.0);

	// Hooks
	HookEvent("round_poststart", Freedays_Event_RoundStart_Post);
	HookEvent("round_end", Freedays_Event_RoundEnd);
}

/******************************************************************************
                    COMMANDS
******************************************************************************/

public Action Command_FreeDay(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bFreeDay.BoolValue)
		return Plugin_Continue;
		
	if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bFreeDayDeputy.BoolValue) || (GetClientTeam(client) == CS_TEAM_CT && gc_bFreeDayGuards.BoolValue))
	{
		char info1[255];
		Menu menu = CreateMenu(Handler_GiveFreeDayChoose);

		Format(info1, sizeof(info1), "%T", "warden_givefreeday", client);
		menu.SetTitle(info1);

		int iValidCount = 0;
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
		{
			if ((GetClientTeam(i) == CS_TEAM_T) && !g_bGetFreeDay[i] && !g_bHasFreeDay[i])
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				if (IsPlayerAlive(i))Format(username, sizeof(username), "%N", i);
				if (!IsPlayerAlive(i))Format(username, sizeof(username), "%N [†]", i);
				menu.AddItem(userid, username);
				iValidCount++;
			}
		}

		if (iValidCount == 0)
		{
			Format(info1, sizeof(info1), "%T", "warden_noplayer", client);
			menu.AddItem("", info1, ITEMDRAW_DISABLED);
		}

		menu.ExitBackButton = true;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");

	return Plugin_Handled;
}

public Action Command_RemoveFreeDay(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bFreeDay.BoolValue)
		return Plugin_Continue;
		
	if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bFreeDayDeputy.BoolValue) || (GetClientTeam(client) == CS_TEAM_CT && gc_bFreeDayGuards.BoolValue))
	{
		char info1[255];
		Menu menu = CreateMenu(Handler_RemoveFreeDayChoose);

		Format(info1, sizeof(info1), "%T", "warden_removefreeday", client);
		menu.SetTitle(info1);

		int iValidCount = 0;
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
		{
			if ((GetClientTeam(i) == CS_TEAM_T) && (g_bGetFreeDay[i] || g_bHasFreeDay[i]))
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				if (IsPlayerAlive(i))Format(username, sizeof(username), "%N", i);
				if (!IsPlayerAlive(i))Format(username, sizeof(username), "%N [†]", i);
				menu.AddItem(userid, username);
				iValidCount++;
			}
		}

		if (iValidCount == 0)
		{
			Format(info1, sizeof(info1), "%T","warden_noplayer", client);
			menu.AddItem("", info1, ITEMDRAW_DISABLED);
		}

		menu.ExitBackButton = true;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Freedays_Event_RoundStart_Post(Event event, char[] name, bool dontBroadcast)
{
	if (gp_bMyJailBreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);
		
		if (!StrEqual(EventDay, "none", false))
			return;
	}

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		if (g_bGetFreeDay[i] && GetClientTeam(i) == CS_TEAM_T)
		{
			CPrintToChatAll("%s %t", g_sPrefix, "warden_havefreeday", i);
			SetEntityRenderColor(i, gc_iFreeDayColorRed.IntValue, gc_iFreeDayColorGreen.IntValue, gc_iFreeDayColorBlue.IntValue, 255);
			g_bGetFreeDay[i] = false;
			g_bHasFreeDay[i] = true;
		}
	}
}

public void Freedays_Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_bHasFreeDay[i] = false;
	}
}

public void Freedays_OnClientDisconnect(int client)
{
		g_bHasFreeDay[client] = false;
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void Freedays_OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_bGetFreeDay[i] = false;
		g_bHasFreeDay[i] = false;
	}
}

public void Freedays_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	// Give freeday
	gc_sCustomCommandGiveFreeDay.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_FreeDay, "Allows a warden to give a freeday to a player");
	}
	
	// Remove freeday
	gc_sCustomCommandRemoveFreeDay.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_RemoveFreeDay, "Allows a warden to remove a freeday from a player");
	}
}

/******************************************************************************
                   MENUS
******************************************************************************/

public int Handler_GiveFreeDayChoose(Menu menu5, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char name[32];
		menu5.GetItem(Position, name, sizeof(name));
		int user = GetClientOfUserId(StringToInt(name));

		if (IsPlayerAlive(user))
		{
			g_hDataPackFreeday = CreateDataPack();
			WritePackCell(g_hDataPackFreeday, user);

			char info[255];
			Menu menu6 = CreateMenu(Handler_GiveFreeDay);
			
			Format(info, sizeof(info), "%T", "warden_freeday_title", user, client);
			menu6.SetTitle(info);
			Format(info, sizeof(info), "%T", "warden_freedaynow", client);
			menu6.AddItem("1", info);
			Format(info, sizeof(info), "%T", "warden_freedaynext", client);
			menu6.AddItem("0", info);
			menu6.ExitBackButton = true;
			menu6.ExitButton = true;
			menu6.Display(client, MENU_TIME_FOREVER);
		}
		else
		{
			g_bGetFreeDay[user] = true;
			CPrintToChatAll("%s %t", g_sPrefix, "warden_personalfreeday", user);
			CPrintToChat(user, "%s %t", g_sPrefix, "warden_freedayforyou");
			Command_FreeDay(client, 0); // reopen menu
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu5;
	}
}

public int Handler_RemoveFreeDayChoose(Menu menu5, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char name[32];
		menu5.GetItem(Position, name, sizeof(name));
		int user = GetClientOfUserId(StringToInt(name));

		g_bGetFreeDay[user] = false;
		g_bHasFreeDay[user] = false;

		int red, blue, green, alpha;
		GetEntityRenderColor(user, red, green, blue, alpha);

		if (red == gc_iFreeDayColorRed.IntValue && green == gc_iFreeDayColorGreen.IntValue && gc_iFreeDayColorBlue.IntValue == blue)
		{
			SetEntityRenderColor(user, 255, 255, 255, 255);
		}

		Command_RemoveFreeDay(client, 0); // reopen menu

		CPrintToChatAll("%s %t", g_sPrefix, "warden_removepersonalfreeday", user);
		CPrintToChat(user, "%s %t", g_sPrefix, "warden_removefreedayforyou");

	}
	else if (action == MenuAction_Cancel)
	{
		if (Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu5;
	}
}

public int Handler_GiveFreeDay(Menu menu6, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char info[32];

		ResetPack(g_hDataPackFreeday);
		int user = ReadPackCell(g_hDataPackFreeday);

		menu6.GetItem(Position, info, sizeof(info));

		if (strcmp(info, "0") == 0) // next round
		{
			g_bGetFreeDay[user] = true;
			CPrintToChatAll("%s %t", g_sPrefix, "warden_personalfreeday", user);
			CPrintToChat(user, "%s %t", g_sPrefix, "warden_freedayforyou");
			Command_FreeDay(client, 0);
		}
		else if (strcmp(info, "1") == 0) // thisround
		{
			g_bHasFreeDay[user] = true;
			CPrintToChatAll("%s %t", g_sPrefix, "warden_havefreeday", user);
			SetEntityRenderColor(user, gc_iFreeDayColorRed.IntValue, gc_iFreeDayColorGreen.IntValue, gc_iFreeDayColorBlue.IntValue, 255);
			Command_FreeDay(client, 0); // reopen freeday menu
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu6;
	}
}

/******************************************************************************
                   NATIVES
******************************************************************************/

// Remove current Warden
public int Native_GiveFreeday(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	g_bGetFreeDay[client] = true;
}

// Is Client in handcuffs
public int Native_HasClientFreeday(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	return g_bHasFreeDay[client];
}
