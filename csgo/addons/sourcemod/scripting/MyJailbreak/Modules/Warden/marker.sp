/*
 * MyJailbreak - Warden - Marker Module.
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
ConVar gc_bMarker;
ConVar gc_bMarkerDeputy;

// Booleans
bool g_bCanMarker[MAXPLAYERS + 1];
bool g_bMarkerSetup[MAXPLAYERS + 1];
bool g_bCanZoom[MAXPLAYERS + 1];
bool g_bHasSilencer[MAXPLAYERS + 1];

// Integers
int g_iWrongWeapon[MAXPLAYERS+1];

// Strings
char g_sColorNamesRed[64];
char g_sColorNamesBlue[64];
char g_sColorNamesGreen[64];
char g_sColorNamesOrange[64];
char g_sColorNamesMagenta[64];
char g_sColorNamesRainbow[64];
char g_sColorNamesYellow[64];
char g_sColorNamesCyan[64];
char g_sColorNamesWhite[64];
char g_sColorNames[8][64] ={{""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}};

// float
float g_fMarkerRadiusMin = 100.0;
float g_fMarkerRadiusMax = 500.0;
float g_fMarkerRangeMax = 1500.0;
float g_fMarkerArrowHeight = 90.0;
float g_fMarkerArrowLength = 20.0;
float g_fMarkerSetupStartOrigin[3];
float g_fMarkerSetupEndOrigin[3];
float g_fMarkerOrigin[8][3];
float g_fMarkerRadius[8];

// Start
public void Marker_OnPluginStart()
{
	// AutoExecConfig
	gc_bMarker = AutoExecConfig_CreateConVar("sm_warden_marker", "1", "0 - disabled, 1 - enable Warden advanced markers ", _, true, 0.0, true, 1.0);
	gc_bMarkerDeputy = AutoExecConfig_CreateConVar("sm_warden_marker_deputy", "1", "0 - disabled, 1 - enable 'advanced markers'-feature for deputy, too", _, true, 0.0, true, 1.0);
	
	//Commands
	RegConsoleCmd("+beacons", Command_Beacons);
	RegConsoleCmd("-beacons", Command_Beacons);

	// Hooks
	HookEvent("item_equip", Marker_Event_ItemEquip);

	CreateTimer(1.0, Timer_DrawMakers, _, TIMER_REPEAT);

	PrepareMarkerNames();
}

public void PrepareMarkerNames()
{
	// Prepare translation for marker colors
	Format(g_sColorNamesRed, sizeof(g_sColorNamesRed), "{darkred}%T{default}", "warden_red", LANG_SERVER);
	Format(g_sColorNamesBlue, sizeof(g_sColorNamesBlue), "{blue}%T{default}", "warden_blue", LANG_SERVER);
	Format(g_sColorNamesGreen, sizeof(g_sColorNamesGreen), "{green}%T{default}", "warden_green", LANG_SERVER);
	Format(g_sColorNamesOrange, sizeof(g_sColorNamesOrange), "{lightred}%T{default}", "warden_orange", LANG_SERVER);
	Format(g_sColorNamesMagenta, sizeof(g_sColorNamesMagenta), "{purple}%T{default}", "warden_magenta", LANG_SERVER);
	Format(g_sColorNamesYellow, sizeof(g_sColorNamesYellow), "{orange}%T{default}", "warden_yellow", LANG_SERVER);
	Format(g_sColorNamesWhite, sizeof(g_sColorNamesWhite), "{default}%T{default}", "warden_white", LANG_SERVER);
	Format(g_sColorNamesCyan, sizeof(g_sColorNamesCyan), "{blue}%T{default}", "warden_cyan", LANG_SERVER);
	Format(g_sColorNamesRainbow, sizeof(g_sColorNamesRainbow), "{lightgreen}%T{default}", "warden_rainbow", LANG_SERVER);

	g_sColorNames[0] = g_sColorNamesWhite;
	g_sColorNames[1] = g_sColorNamesRed;
	g_sColorNames[3] = g_sColorNamesBlue;
	g_sColorNames[2] = g_sColorNamesGreen;
	g_sColorNames[7] = g_sColorNamesOrange;
	g_sColorNames[6] = g_sColorNamesMagenta;
	g_sColorNames[4] = g_sColorNamesYellow;
	g_sColorNames[5] = g_sColorNamesCyan;
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_Beacons(int client, int args)
{
	char sCommand[32];
	GetCmdArg(0, sCommand, sizeof(sCommand));
	
	if (client > 0)
	{
		g_bCanMarker[client] = StrContains(sCommand, "+") != -1;
	}
	
	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Marker_Event_ItemEquip(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	g_bCanZoom[client] = event.GetBool("canzoom");
	g_bHasSilencer[client] = event.GetBool("hassilencer");
	g_iWrongWeapon[client] = event.GetInt("weptype");
	/*
	WEAPONTYPE_KNIFE = 0
	WEAPONTYPE_TASER 8
	WEAPONTYPE_GRENADE 9
	*/
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public Action Marker_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bMarker.BoolValue)
		return Plugin_Continue;

	if (buttons & IN_ATTACK2 || g_bCanMarker[client])
	{
		if (!g_bCanZoom[client] && !g_bHasSilencer[client] && (g_iWrongWeapon[client] != 0) && (g_iWrongWeapon[client] != 8) && (g_iWrongWeapon[client] != 9) && (IsClientWarden(client) || (IsClientDeputy(client) && gc_bMarkerDeputy.BoolValue)))
		{
			if (!g_bMarkerSetup[client])
				GetClientAimTargetPos(client, g_fMarkerSetupStartOrigin);
			
			GetClientAimTargetPos(client, g_fMarkerSetupEndOrigin);
			
			float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
			
			if (radius > g_fMarkerRadiusMax)
				radius = g_fMarkerRadiusMax;
			else if (radius < g_fMarkerRadiusMin)
				radius = g_fMarkerRadiusMin;
			
			if (radius > 0)
			{
				TE_SetupBeamRingPoint(g_fMarkerSetupStartOrigin, radius, radius+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.1, 2.0, 0.0, {255, 255, 255, 255}, 10, 0);
				TE_SendToClient(client);
			}
			
			g_bMarkerSetup[client] = true;
		}
	}
	else if (g_bMarkerSetup[client])
	{
		MarkerMenu(client);
		g_bMarkerSetup[client] = false;
	}

	return Plugin_Continue;
}

public void Marker_OnWardenRemoved()
{
	RemoveAllMarkers();
}

public void Marker_OnAvailableLR(int announced)
{
	RemoveAllMarkers();
}

public void Marker_OnMapEnd()
{
	RemoveAllMarkers();
}

public void Marker_OnMapStart()
{
	RemoveAllMarkers();
}

/******************************************************************************
                   MENUS
******************************************************************************/

void MarkerMenu(int client)
{
	if (!IsValidClient(client, false, false) || (!IsClientWarden(client) && !IsClientDeputy(client)))
	{
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_notwarden");
		return;
	}

	int marker = IsMarkerInRange(g_fMarkerSetupStartOrigin);
	if (marker != -1)
	{
		RemoveMarker(marker);
		CPrintToChatAll("%s %t", g_sPrefix, "warden_marker_remove", g_sColorNames[marker]);
		return;
	}

	float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
	if (radius <= 0.0)
	{
		RemoveMarker(marker);
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_wrong");
		return;
	}

	float g_fPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", g_fPos);

	float range = GetVectorDistance(g_fPos, g_fMarkerSetupStartOrigin);
	if (range > g_fMarkerRangeMax)
	{
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_range");
		return;
	}

	if (0 < client < MaxClients)
	{
		Menu menu = CreateMenu(Handle_MarkerMenu);
		char menuinfo[255];

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_marker_title", client);
		SetMenuTitle(menu, menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_red", client);
		AddMenuItem(menu, "1", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_blue", client);
		AddMenuItem(menu, "3", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_green", client);
		AddMenuItem(menu, "2", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_orange", client);
		AddMenuItem(menu, "7", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_white", client);
		AddMenuItem(menu, "0", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_cyan", client);
		AddMenuItem(menu, "5", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_magenta", client);
		AddMenuItem(menu, "6", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_yellow", client);
		AddMenuItem(menu, "4", menuinfo);

		menu.Display(client, 20);
	}
}

public int Handle_MarkerMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		if(IsValidClient(client, false, false) && (!IsClientWarden(client) && !IsClientDeputy(client)))
		{
			char info[32];char info2[32];
			bool found = menu.GetItem(itemNum, info, sizeof(info), _, info2, sizeof(info2));
			int marker = StringToInt(info);

			if (found)
			{
				SetupMarker(marker);
				CPrintToChatAll("%s %t", g_sPrefix, "warden_marker_set", g_sColorNames[marker]);
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

public Action Timer_DrawMakers(Handle timer)
{
	Draw_Markers();

	return Plugin_Continue;
}

/******************************************************************************
                   STOCKS
******************************************************************************/

void Draw_Markers()
{
	if (g_iWarden == -1)
		return;

	for (int j = 0; j<8; j++)
	{
		if (g_fMarkerRadius[j] <= 0.0)
			continue;

		// FIX OR FEATURE    TODO ASK ZIPCORE
		float fWardenOrigin[3];
		GetEntPropVector(g_iWarden, Prop_Send, "m_vecOrigin", fWardenOrigin);

		if (GetVectorDistance(fWardenOrigin, g_fMarkerOrigin[j]) > g_fMarkerRangeMax)
		{
			CPrintToChat(g_iWarden, "%s %t", g_sPrefix, "warden_marker_faraway", g_sColorNames[j]);
			RemoveMarker(j);
			continue;
		}

		// FIX OR FEATURE    TODO ASK ZIPCORE
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, false))
		{
			// Show the ring
			TE_SetupBeamRingPoint(g_fMarkerOrigin[j], g_fMarkerRadius[j], g_fMarkerRadius[j]+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 2.0, 0.0, g_iColors[j], 10, 0);
			TE_SendToAll();

			// Show the arrow
			float fStart[3];
			AddVectors(fStart, g_fMarkerOrigin[j], fStart);
			fStart[2] += g_fMarkerArrowHeight;

			float fEnd[3];
			AddVectors(fEnd, fStart, fEnd);
			fEnd[2] += g_fMarkerArrowLength;

			TE_SetupBeamPoints(fStart, fEnd, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 2.0, 16.0, 1, 0.0, g_iColors[j], 5);
			TE_SendToAll();
		}
	}
}

void SetupMarker(int marker)
{
	g_fMarkerOrigin[marker][0] = g_fMarkerSetupStartOrigin[0];
	g_fMarkerOrigin[marker][1] = g_fMarkerSetupStartOrigin[1];
	g_fMarkerOrigin[marker][2] = g_fMarkerSetupStartOrigin[2];

	float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
	if (radius > g_fMarkerRadiusMax)
		radius = g_fMarkerRadiusMax;
	else if (radius < g_fMarkerRadiusMin)
		radius = g_fMarkerRadiusMin;
	g_fMarkerRadius[marker] = radius;
}

int GetClientAimTargetPos(int client, float g_fPos[3]) 
{
	if (client < 1)
		return -1;

	float vAngles[3];float vOrigin[3];

	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilterAllEntities, client);

	TR_GetEndPosition(g_fPos, trace);
	g_fPos[2] += 5.0;

	int entity = TR_GetEntityIndex(trace);

	CloseHandle(trace);

	return entity;
}

void RemoveMarker(int marker)
{
	if (marker != -1)
	{
		g_fMarkerRadius[marker] = 0.0;
	}
}

void RemoveAllMarkers()
{
	for (int i = 0; i < 8; i++)
		RemoveMarker(i);
}

int IsMarkerInRange(float g_fPos[3])
{
	for (int i = 0; i < 8; i++)
	{
		if (g_fMarkerRadius[i] <= 0.0)
			continue;

		if (GetVectorDistance(g_fMarkerOrigin[i], g_fPos) < g_fMarkerRadius[i])
			return i;
	}
	return -1;
}

public bool TraceFilterAllEntities(int entity, int contentsMask, int client)
{
	if (entity == client)
		return false;

	if (entity > MaxClients)
		return false;

	if (!IsClientInGame(entity))
		return false;

	if (!IsPlayerAlive(entity))
		return false;

	return true;
}