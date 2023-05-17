/*
 * MyJailbreak - EventDay DevZones Plugin.
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


#include <sourcemod>
#include <sdktools>
#include <devzones>
#include <myjailbreak>
#include <mystocks>

#pragma semicolon 1
#pragma newdecls required

float g_fZonePos[MAXPLAYERS+1][3];
Handle g_hClientTimers[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};


public Plugin myinfo = 
{
	name = "MyJailbreak - EventDay DevZones",
	author = "shanapu & Franc1sco franug",
	description = "Block areas on Event Day with Dev Zones",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};


public void OnClientDisconnect(int client)
{
	if (g_hClientTimers[client] != null)
	{
		KillTimer(g_hClientTimers[client]);
	}

	g_hClientTimers[client] = null;
}


public int Zone_OnClientEntry(int client, char[] zone)
{
	if (!MyJailbreak_IsEventDayRunning())
		return;

	if(!IsValidClient(client, true, false))
		return;

	if(StrContains(zone, "MyJB-NoGo", false) == 0)
	{
		Zone_GetZonePosition(zone, false, g_fZonePos[client]);

		g_hClientTimers[client] = CreateTimer(0.1, Timer_Repeat, GetClientUserId(client), TIMER_REPEAT);
		PrintHintText(client, "You can't enter here on a event day!");
	}
}


public int Zone_OnClientLeave(int client, char[] zone)
{
	if(!IsValidClient(client, true, false))
		return;

	if(StrContains(zone, "MyJB-NoGo", false) == 0)
	{
		if (g_hClientTimers[client] != null)
		{
			KillTimer(g_hClientTimers[client]);
		}

		g_hClientTimers[client] = null;
	}
}


public Action Timer_Repeat(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(!IsValidClient(client, true, false) || !MyJailbreak_IsEventDayRunning())
	{
		if (g_hClientTimers[client] != null)
		{
			KillTimer(g_hClientTimers[client]);
		}

		g_hClientTimers[client] = null;

		return Plugin_Stop;
	}

	float clientloc[3];
	GetClientAbsOrigin(client, clientloc);

	KnockbackSetVelocity(client, g_fZonePos[client], clientloc, 300.0);
	return Plugin_Continue;
}


void KnockbackSetVelocity(int client, const float startpoint[3], const float endpoint[3], float magnitude)
{
	// Create vector from the given starting and ending points.
	float vector[3];
	MakeVectorFromPoints(startpoint, endpoint, vector);

	// Normalize the vector (equal magnitude at varying distances).
	NormalizeVector(vector, vector);

	// Apply the magnitude by scaling the vector (multiplying each of its components).
	ScaleVector(vector, magnitude);

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vector);
}