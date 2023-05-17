/*
 * MyJailbreak - Request - Heal Module.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: good-live
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
#include <mystocks>

#undef REQUIRE_PLUGIN
#include <warden>
#include <myjbwarden>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bHeal;
ConVar gc_bHealthShot;
ConVar gc_fHealTime;
ConVar gc_iHealLimit;
ConVar gc_bHealthCheck;
ConVar gc_iHealColorRed;
ConVar gc_iHealColorGreen;
ConVar gc_iHealColorBlue;
ConVar gc_sCustomCommandHeal;
ConVar gc_sAdminFlagHeal;

// Booleans
bool g_bHealed[MAXPLAYERS+1];

// Integers
int g_iHealCounter[MAXPLAYERS+1];

// Handles
Handle g_hTimerHeal[MAXPLAYERS+1];

// Strings
char g_sAdminFlagHeal[64];

// Start
public void Heal_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_heal", Command_Heal, "Allows a Terrorist request healing");

	// AutoExecConfig
	gc_bHeal = AutoExecConfig_CreateConVar("sm_heal_enable", "1", "0 - disabled, 1 - enable heal");
	gc_sCustomCommandHeal = AutoExecConfig_CreateConVar("sm_heal_cmds", "cure, h, ouch", "Set your custom chat command for Heal(!heal (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bHealthShot = AutoExecConfig_CreateConVar("sm_heal_healthshot", "1", "0 - disabled, 1 - enable give healthshot on accept to terror");
	gc_bHealthCheck = AutoExecConfig_CreateConVar("sm_heal_check", "1", "0 - disabled, 1 - enable check if player is already full health");
	gc_iHealLimit = AutoExecConfig_CreateConVar("sm_heal_limit", "2", "Сount how many times you can use the command");
	gc_fHealTime = AutoExecConfig_CreateConVar("sm_heal_time", "10.0", "Time after the player gets his normal colors back");
	gc_iHealColorRed = AutoExecConfig_CreateConVar("sm_heal_color_red", "240", "What color to turn the heal Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iHealColorGreen = AutoExecConfig_CreateConVar("sm_heal_color_green", "0", "What color to turn the heal Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iHealColorBlue = AutoExecConfig_CreateConVar("sm_heal_color_blue", "100", "What color to turn the heal Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sAdminFlagHeal = AutoExecConfig_CreateConVar("sm_heal_flag", "a", "Set flag for admin/vip to get one more heal. No flag = feature is available for all players!");

	// Hooks 
	HookEvent("round_start", Heal_Event_RoundStart);
	HookConVarChange(gc_sAdminFlagHeal, Heal_OnSettingChanged);

	// FindConVar
	gc_sAdminFlagHeal.GetString(g_sAdminFlagHeal, sizeof(g_sAdminFlagHeal));
}

public void Heal_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sAdminFlagHeal)
	{
		strcopy(g_sAdminFlagHeal, sizeof(g_sAdminFlagHeal), newValue);
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// heal
public Action Command_Heal(int client, int args)
{
	if (gc_bPlugin.BoolValue && (gp_bWarden || gp_bMyJBWarden))
	{
		if (gc_bHeal.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && (IsPlayerAlive(client)))
			{
				if (g_hTimerHeal[client] == null)
				{
					if (g_iHealCounter[client] < gc_iHealLimit.IntValue)
					{
						if (warden_exist())
						{
							if ((GetClientHealth(client) < 100) || !gc_bHealthCheck.BoolValue)
							{
								if (!g_bIsRequest)
								{
									g_bIsRequest = true;
									g_hTimerRequest = CreateTimer (gc_fHealTime.FloatValue, Timer_IsRequest);
									g_bHealed[client] = true;
									g_iHealCounter[client]++;
									CPrintToChatAll("%s %t", g_sPrefix, "request_heal", client);
									SetEntityRenderColor(client, gc_iHealColorRed.IntValue, gc_iHealColorGreen.IntValue, gc_iHealColorBlue.IntValue, 255);
									g_hTimerHeal[client] = CreateTimer(gc_fHealTime.FloatValue, Timer_ResetColorHeal, GetClientUserId(client));
									for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) HealMenu(i);
								}
								else CReplyToCommand(client, "%s %t", g_sPrefix, "request_processing");
							}
							else CReplyToCommand(client, "%s %t", g_sPrefix, "request_fullhp");
						}
						else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_noexist");
					}
					else CReplyToCommand(client, "%s %t", g_sPrefix, "request_healtimes", gc_iHealLimit.IntValue);
				}
				else CReplyToCommand(client, "%s %t", g_sPrefix, "request_alreadyhealed");
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "request_notalivect");
		}
	}

	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void Heal_Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		delete g_hTimerHeal[i];

		g_iHealCounter[i] = 0;
		g_bHealed[i] = false;

		if (MyJB_CheckVIPFlags(i, "sm_heal_flag", gc_sAdminFlagHeal, "sm_heal_flag"))
		{
			g_iHealCounter[i] = -1;
		}
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Heal_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Capitulation
	gc_sCustomCommandHeal.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_Heal, "Allows a Terrorist request healing");
		}
	}
}

public void Heal_OnClientPutInServer(int client)
{
	g_iHealCounter[client] = 0;

	if (MyJB_CheckVIPFlags(client, "sm_heal_flag", gc_sAdminFlagHeal, "sm_heal_flag"))
	{
		g_iHealCounter[client] = -1;
	}

	g_bHealed[client] = false;
}

public void Heal_OnClientDisconnect(int client)
{
	delete g_hTimerHeal[client];
}


/******************************************************************************
                   MENUS
******************************************************************************/


void HealMenu(int client)
{
	if (warden_iswarden(client))
	{
		char info5[255], info6[255], info7[255];
		Menu menu1 = CreateMenu(HealMenuHandler);
		Format(info5, sizeof(info5), "%T", "request_acceptheal", client);
		menu1.SetTitle(info5);
		Format(info6, sizeof(info6), "%T", "warden_no", client);
		Format(info7, sizeof(info7), "%T", "warden_yes", client);
		menu1.AddItem("1", info7);
		menu1.AddItem("0", info6);
		menu1.Display(client, gc_fHealTime.IntValue);
	}
}


public int HealMenuHandler(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);
		if (choice == 1)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, false, true))
					continue;

				if (!g_bHealed[i])
					continue;

				g_bIsRequest = false;
				g_hTimerRequest = null;
				if (gc_bHealthShot.BoolValue) GivePlayerItem(i, "weapon_healthshot");
				CPrintToChat(i, "%s %t", g_sPrefix, "request_health");
				CPrintToChatAll("%s %t", g_sPrefix, "request_accepted", i, client);
			}
		}
		if (choice == 0)
		{
			g_bIsRequest = false;
			g_hTimerRequest = null;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, false, true))
					continue;

				if (!g_bHealed[i])
					continue;

				CPrintToChatAll("%s %t", g_sPrefix, "request_noaccepted", i, client);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_ResetColorHeal(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client,true,false))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}

	g_hTimerHeal[client] = null;
	g_bHealed[client] = false;
}