/*
 * MyJailbreak - Warden - Counter Module.
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
ConVar gc_bCounter;
ConVar gc_bCounterDeputy;
ConVar gc_iCounterMode;
ConVar gc_sCustomCommandCounter;

// Boolean
bool g_bCounted[MAXPLAYERS+1];

// Floats
float g_fDistance[MAXPLAYERS+1];

// Start
public void Counter_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_count", Command_Counter, "Allows a warden to count all terrorists in sight");
	
	
	// AutoExecConfig
	gc_bCounter = AutoExecConfig_CreateConVar("sm_warden_counter", "1", "0 - disabled, 1 - Allow the warden count player in radius", _, true, 0.0, true, 1.0);
	gc_bCounterDeputy = AutoExecConfig_CreateConVar("sm_warden_counter_deputy", "1", "0 - disabled, 1 - Allow the deputy count player in radius, too", _, true, 0.0, true, 1.0);
	gc_iCounterMode = AutoExecConfig_CreateConVar("sm_warden_counter_mode", "7", "1 - Show prisoner count in chat / 2 - Show prisoner count in HUD / 3 - Show prisoner count in chat & HUD / 4 - Show names in Menu / 5 - Show prisoner count in chat & show names in Menu / 6 - Show prisoner count in HUD & show names in Menu / 7 - Show prisoner count in chat & HUD & show names in Menu", _, true, 1.0, true, 7.0);
	gc_sCustomCommandCounter = AutoExecConfig_CreateConVar("sm_warden_cmds_counter", "count, sight", "Set your custom chat command for counter.(!counter (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
}

/******************************************************************************
					COMMANDS
******************************************************************************/

public Action Command_Counter(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)
		return Plugin_Handled;

	if ((IsClientWarden(client) || (IsClientDeputy(client) && gc_bCounterDeputy.BoolValue)) && gc_bCounter.BoolValue)
	{
		float wardenOrigin[3];
		GetClientAbsOrigin(client, wardenOrigin);
		int counter = 0;

		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
		{
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				g_bCounted[i] = false;
				g_fDistance[i] = 0.0;
				
				float clientOrigin[3];
				GetClientAbsOrigin(i, clientOrigin);
				
				float distance = GetVectorDistance(clientOrigin, wardenOrigin, false);
				
				if (ClientViews(client, i))
				{
					counter++;
					g_bCounted[i] = true;
					g_fDistance[i] = distance;
				}
			}
		}

		if ((gc_iCounterMode.IntValue == 1)|| (gc_iCounterMode.IntValue == 3)|| (gc_iCounterMode.IntValue == 5)|| (gc_iCounterMode.IntValue == 7)) CReplyToCommand(client, "%s %t", g_sPrefix, "warden_counter", counter);
		if ((gc_iCounterMode.IntValue == 2)|| (gc_iCounterMode.IntValue == 3)|| (gc_iCounterMode.IntValue == 6)|| (gc_iCounterMode.IntValue == 7)) PrintCenterText(client, "%t", "warden_counter", counter);
		if ((gc_iCounterMode.IntValue == 4)|| (gc_iCounterMode.IntValue == 5)|| (gc_iCounterMode.IntValue == 6)|| (gc_iCounterMode.IntValue == 7))
		{
			char info1[255];
			Panel InfoPanel = new Panel();
			Format(info1, sizeof(info1), "%T", "warden_info_counter", client);
			InfoPanel.SetTitle(info1);
			InfoPanel.DrawText("-----------------------------------");
			InfoPanel.DrawText("                                   ");
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
			{
				if (g_bCounted[i])
				{
					int userdistance = RoundToNearest(g_fDistance[i] * 0.01905);  // 0.01905 GAMEUNITS_TO_METERS
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N (%im)", i, userdistance);
					InfoPanel.DrawText(username);
				}
			}
			InfoPanel.DrawText("                                   ");
			InfoPanel.DrawText("-----------------------------------");
			Format(info1, sizeof(info1), "%T", "warden_close", client);
			InfoPanel.DrawItem(info1);
			InfoPanel.Send(client, Handler_NullCancel, 23);
			delete InfoPanel;
		}
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");

	return Plugin_Handled;
}

/******************************************************************************
					FORWARDS LISTENING
******************************************************************************/

public void Counter_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Capitulation
	gc_sCustomCommandCounter.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_Counter, "Allows a warden to count all terrorists in sight");
	}
}