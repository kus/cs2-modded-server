/*
 * MyJailbreak - Warden - Painter Module.
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
ConVar gc_bPainter;
ConVar gc_bPainterDeputy;
ConVar gc_bPainterTDeputy;
ConVar gc_bPainterT;
ConVar gc_sAdminFlagPainter;
ConVar gc_sCustomCommandPainter;

// Boolean
bool g_bPainterUse[MAXPLAYERS+1] = {false, ...};
bool g_bPainter[MAXPLAYERS+1] = false;
bool g_bPainterT = false;
bool g_bPainterColorRainbow[MAXPLAYERS+1] = true;

// Integers
int g_iPainterColor[MAXPLAYERS+1];

// Floats
float g_fLastPainter[MAXPLAYERS+1][3];

// Start
public void Painter_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_painter", Command_PainterMenu, "Allows Warden to toggle on/off the wardens Painter");

	// AutoExecConfig
	gc_bPainter = AutoExecConfig_CreateConVar("sm_warden_painter", "1", "0 - disabled, 1 - enable Warden Painter with +E ", _, true, 0.0, true, 1.0);
	gc_bPainterDeputy = AutoExecConfig_CreateConVar("sm_warden_painter_deputy", "1", "0 - disabled, 1 - enable 'Warden Painter'-feature for deputy, too", _, true, 0.0, true, 1.0);
	gc_sAdminFlagPainter = AutoExecConfig_CreateConVar("sm_warden_painter_flag", "", "Set flag for admin/vip to get warden painter access. No flag = feature is available for all players!");
	gc_bPainterT= AutoExecConfig_CreateConVar("sm_warden_painter_terror", "1", "0 - disabled, 1 - allow Warden to toggle Painter for Terrorist ", _, true, 0.0, true, 1.0);
	gc_bPainterTDeputy= AutoExecConfig_CreateConVar("sm_warden_painter_terror_deputy", "1", "0 - disabled, 1 - allow to toggle Painter for Terrorist as deputy, too", _, true, 0.0, true, 1.0);
	gc_sCustomCommandPainter = AutoExecConfig_CreateConVar("sm_warden_cmds_painter", "paint, draw", "Set your custom chat commands for Painter menu(!painter (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	// Hooks
	HookEvent("round_end", Painter_Event_RoundEnd);
	HookEvent("player_team", Painter_Event_PlayerTeamDeath);
	HookEvent("player_death", Painter_Event_PlayerTeamDeath);
}


/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_PainterMenu(int client, int args)
{
	if (gc_bPainter.BoolValue)
	{
		if ((IsClientWarden(client)) || (IsClientDeputy(client) && gc_bPainterDeputy.BoolValue) || ((GetClientTeam(client) == CS_TEAM_T) && g_bPainterT))
		{
			if (MyJB_CheckVIPFlags(client, "sm_warden_painter_flag", gc_sAdminFlagPainter, "sm_warden_painter_flag") || (GetClientTeam(client) == CS_TEAM_T))
			{
				char menuinfo[255];

				Menu menu = new Menu(Handler_PainterMenu);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_painter_title", client);
				menu.SetTitle(menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_painter_off", client);
				if (g_bPainter[client]) menu.AddItem("off", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_paintert", client);
				if (GetClientTeam(client) == CS_TEAM_CT) menu.AddItem("terror", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_rainbow", client);
				menu.AddItem("rainbow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_white", client);
				menu.AddItem("white", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_red", client);
				menu.AddItem("red", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_green", client);
				menu.AddItem("green", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_blue", client);
				menu.AddItem("blue", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_yellow", client);
				menu.AddItem("yellow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_cyan", client);
				menu.AddItem("cyan", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_magenta", client);
				menu.AddItem("magenta", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_orange", client);
				menu.AddItem("orange", menuinfo);

				menu.ExitBackButton = true;
				menu.ExitButton = true;
				menu.Display(client, 20);
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_vipfeature");
		}
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Painter_Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	g_fLastPainter[client][0] = 0.0;
	g_fLastPainter[client][1] = 0.0;
	g_fLastPainter[client][2] = 0.0;
	g_bPainterUse[client] = false;
	g_bPainter[client] = false;
	g_iLastButtons[client] = 0;
}

public void Painter_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bPainterT = false;
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (g_bPainter[i]) g_bPainter[i] = false;
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void Painter_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Painter
	gc_sCustomCommandPainter.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_PainterMenu, "Allows Warden to toggle on/off the wardens Painter");
	}
}

public Action Painter_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!IsPlayerAlive(client))
		return;

	if ((IsClientWarden(client) && gc_bPainter.BoolValue && g_bPainter[client] && MyJB_CheckVIPFlags(client, "sm_warden_painter_flag", gc_sAdminFlagPainter, "sm_warden_painter_flag")) || ((GetClientTeam(client) == CS_TEAM_T) && gc_bPainter.BoolValue && g_bPainterT && g_bPainter[client]) || (IsClientDeputy(client) && gc_bPainterDeputy.BoolValue && g_bPainter[client]))
	{
		for (int i = 0; i < MAX_BUTTONS; i++)
		{
			int button = (1 << i);
			
			if ((buttons & button))
			{
				if (!(g_iLastButtons[client] & button))
				{
					OnButtonPress(client, button);
				}
			}
			else if ((g_iLastButtons[client] & button))
			{
				OnButtonRelease(client, button);
			}
		}
		g_iLastButtons[client] = buttons;
	}
}

public void Painter_OnMapStart()
{
	CreateTimer(0.1, Print_Painter, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	g_bPainterT = false;
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) g_bPainter[i] = false;
}

public void Painter_OnMapEnd()
{
	g_bPainterT = false;

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_fLastPainter[i][0] = 0.0;
		g_fLastPainter[i][1] = 0.0;
		g_fLastPainter[i][2] = 0.0;
		g_bPainterUse[i] = false;
		g_bPainter[i] = false;
	}
}

public void Painter_OnClientPutInServer(int client)
{
	g_bPainterUse[client] = false;
	g_bPainterColorRainbow[client] = true;
}

public void Painter_OnWardenRemoved(int client)
{
	g_bPainterT = false;
}

public void Painter_OnClientDisconnect(int client)
{
	if (IsClientWarden(client)) g_bPainterT = false;
	g_iLastButtons[client] = 0;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

public Action TogglePainterT(int client, int args)
{
	if (gc_bPainterT.BoolValue) 
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bPainterDeputy.BoolValue && gc_bPainterTDeputy.BoolValue))
		{
			if (!g_bPainterT) 
			{
				g_bPainterT = true;
				CPrintToChatAll("%s %t", g_sPrefix, "warden_tpainteron");
				
				for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true))
				{
					if (GetClientTeam(i) == CS_TEAM_T) Command_PainterMenu(i, 0);
				}
			}
			else
			{
				for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true))
				{
					if (GetClientTeam(i) == CS_TEAM_T)
					{
						g_fLastPainter[i][0] = 0.0;
						g_fLastPainter[i][1] = 0.0;
						g_fLastPainter[i][2] = 0.0;
						g_bPainterUse[i] = false;
					}
				}
				g_bPainterT = false;
				CPrintToChatAll("%s %t", g_sPrefix, "warden_tpainteroff");
			}
		}
	}
}

void OnButtonPress(int client, int button)
{
	if (button == IN_USE)
	{
		TraceEye(client, g_fLastPainter[client]);
		g_bPainterUse[client] = true;
	}
}

void OnButtonRelease(int client, int button)
{
	if (button == IN_USE)
	{
		g_fLastPainter[client][0] = 0.0;
		g_fLastPainter[client][1] = 0.0;
		g_fLastPainter[client][2] = 0.0;
		g_bPainterUse[client] = false;
	}
}

public Action Connect_Painter(float start[3], float end[3], int color[4])
{
	TE_SetupBeamPoints(start, end, g_iBeamSprite, 0, 0, 0, 25.0, 2.0, 2.0, 10, 0.0, color, 0);
	TE_SendToAll();
}

public Action TraceEye(int client, float g_fPos[3]) 
{
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

	if (TR_DidHit(INVALID_HANDLE)) TR_GetEndPosition(g_fPos, INVALID_HANDLE);
	return;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return (entity > MaxClients || !entity);
}


/******************************************************************************
                   MENUS
******************************************************************************/

public int Handler_PainterMenu(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));

		if (strcmp(info, "off") == 0)
		{
			g_bPainter[client] = false;
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteroff");
		}
		else if (strcmp(info, "terror") == 0)
		{
			TogglePainterT(client, 0);
		}
		else if (strcmp(info, "rainbow") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesRainbow);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = true;
		}
		else if (strcmp(info, "white") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesWhite);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 0;
		}
		else if (strcmp(info, "red") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesRed);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 1;
		}
		else if (strcmp(info, "green") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesGreen);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 2;
		}
		else if (strcmp(info, "blue") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesBlue);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 3;
		}
		else if (strcmp(info, "yellow") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesYellow);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 4;
		}
		else if (strcmp(info, "cyan") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesCyan);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 5;
		}
		else if (strcmp(info, "magenta") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesMagenta);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 6;
		}
		else if (strcmp(info, "orange") == 0)
		{
			if (!g_bPainter[client]) CPrintToChat(client, "%s %t", g_sPrefix, "warden_painteron");
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_painter", g_sColorNamesOrange);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 7;
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
		delete menu;
	}
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Print_Painter(Handle timer)
{
	float g_fPos[3];

	for (int Y = 1;Y <= MaxClients;Y++) 
	{
		if (g_bPainterColorRainbow[Y]) g_iPainterColor[Y] = GetRandomInt(0, 6);
		if (IsClientInGame(Y) && g_bPainterUse[Y])
		{
			TraceEye(Y, g_fPos);
			if (GetVectorDistance(g_fPos, g_fLastPainter[Y]) > 6.0) {
				Connect_Painter(g_fLastPainter[Y], g_fPos, g_iColors[g_iPainterColor[Y]]);
				g_fLastPainter[Y][0] = g_fPos[0];
				g_fLastPainter[Y][1] = g_fPos[1];
				g_fLastPainter[Y][2] = g_fPos[2];
			}
		}
	}
}