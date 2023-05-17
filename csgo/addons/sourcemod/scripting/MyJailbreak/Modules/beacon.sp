/*
 * MyJailbreak - Beacon Module.
 * by: shanapu
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
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

// Console Variables
ConVar gc_fBeaconRadius;
ConVar gc_fBeaconWidth;
ConVar gc_iCTColorRed;
ConVar gc_iTColorRed;
ConVar gc_iCTColorGreen;
ConVar gc_iTColorGreen;
ConVar gc_iCTColorBlue;
ConVar gc_iTColorBlue;

// Integers
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;

// Booleans
bool g_bBeaconOn[MAXPLAYERS+1] = false;

// Floats
public void Beacon_OnPluginStart()
{
	gc_fBeaconRadius = AutoExecConfig_CreateConVar("sm_myjb_beacon_radius", "850", "Sets the radius for the beacons rings.", _, true, 50.0, true, 1500.0);
	gc_fBeaconWidth = AutoExecConfig_CreateConVar("sm_myjb_beacon_width", "25", "Sets the thickness for the beacons rings.", _, true, 10.0, true, 30.0);
	gc_iCTColorRed = AutoExecConfig_CreateConVar("sm_myjb_beacon_CT_color_red", "0", "What color to turn the CT beacons into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iCTColorGreen = AutoExecConfig_CreateConVar("sm_myjb_beacon_CT_color_green", "0", "What color to turn the CT beacons into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iCTColorBlue = AutoExecConfig_CreateConVar("sm_myjb_beacon_CT_color_blue", "255", "What color to turn the CT beacons into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_iTColorRed = AutoExecConfig_CreateConVar("sm_myjb_beacon_T_color_red", "255", "What color to turn the T beacons  into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iTColorGreen = AutoExecConfig_CreateConVar("sm_myjb_beacon_T_color_green", "0", "What color to turn the T beacons into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iTColorBlue = AutoExecConfig_CreateConVar("sm_myjb_beacon_T_color_blue", "0", "What color to turn the T beacons into (rgB): x - blue value", _, true, 0.0, true, 255.0);

	// Hooks
	HookEvent("round_end", Beacon_Event_RoundEnd);
	HookEvent("player_death", Beacon_Event_PlayerTeamDeath);
	HookEvent("player_team", Beacon_Event_PlayerTeamDeath);
}

public void Beacon_Event_PlayerTeamDeath(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

	g_bBeaconOn[client] = false;
}

public void Beacon_Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) g_bBeaconOn[i] = false;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

public Action Timer_BeaconOn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client, true, false))
	{
		if (!g_bBeaconOn[client]) 
			return Plugin_Stop;

		float a_fOrigin[3];

		GetClientAbsOrigin(client, a_fOrigin);
		a_fOrigin[2] += 10;

		int color[4] = {255, 255, 255, 255};

		if (GetClientTeam(client) == CS_TEAM_CT) 
		{
			color[0] = gc_iCTColorRed.IntValue;
			color[1] = gc_iCTColorGreen.IntValue;
			color[2] = gc_iCTColorBlue.IntValue;
			EmitAmbientSound("buttons/blip1.wav", a_fOrigin, client, SNDLEVEL_RAIDSIREN);
		}

		if (GetClientTeam(client) == CS_TEAM_T) 
		{
			color[0] = gc_iTColorRed.IntValue;
			color[1] = gc_iTColorGreen.IntValue;
			color[2] = gc_iTColorBlue.IntValue;
			EmitAmbientSound("buttons/button1.wav", a_fOrigin, client, SNDLEVEL_RAIDSIREN);
		}

		TE_SetupBeamRingPoint(a_fOrigin, 10.0, gc_fBeaconRadius.FloatValue, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.6, gc_fBeaconWidth.FloatValue, 0.5, color, 5, 0);
		TE_SendToAll();
	//	GetClientEyePosition(client, a_fOrigin);
	}

	return Plugin_Continue;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Start
public void Beacon_OnMapStart()
{
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/light_glow02.vmt");
}

// Start
public void Beacon_OnMapEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_bBeaconOn[i] = false;
	}
}

public void OnAvailableLR(int Announced)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_bBeaconOn[i] = false;
	}
}

/******************************************************************************
                   NATIVES
******************************************************************************/

// Activate Beacon on client & set interval
public int Native_BeaconOn(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	float interval = GetNativeCell(2);

	if (!g_bBeaconOn[client])
	{
		g_bBeaconOn[client] = true;

		CreateTimer (interval, Timer_BeaconOn, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

// Remove beacon from client
public int Native_BeaconOff(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	g_bBeaconOn[client] = false;
}