/*
 * MyJailbreak - Warden - Colorize Warden Module.
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
#include <autoexecconfig>
#include <warden>
#include <myjbwarden>
#include <mystocks>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bColor;
ConVar gc_iWardenColorRed;
ConVar gc_iWardenColorGreen;
ConVar gc_iWardenColorBlue;
ConVar gc_iDeputyColorRed;
ConVar gc_iDeputyColorGreen;
ConVar gc_iDeputyColorBlue;
ConVar gc_bWardenColorRandom;

// Info
public void Color_OnPluginStart()
{
	// AutoExecConfig
	gc_bColor = AutoExecConfig_CreateConVar("sm_warden_color_enable", "1", "0 - disabled, 1 - enable warden colored", _, true, 0.0, true, 1.0);
	gc_bWardenColorRandom = AutoExecConfig_CreateConVar("sm_warden_color_random", "1", "0 - disabled, 1 - enable warden rainbow colored", _, true, 0.0, true, 1.0);
	gc_iWardenColorRed = AutoExecConfig_CreateConVar("sm_warden_color_red", "0", "What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iWardenColorGreen = AutoExecConfig_CreateConVar("sm_warden_color_green", "0", "What color to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iWardenColorBlue = AutoExecConfig_CreateConVar("sm_warden_color_blue", "255", "What color to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_iDeputyColorRed = AutoExecConfig_CreateConVar("sm_warden_color_red_deputy", "0", "What color to turn the deputy into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iDeputyColorGreen = AutoExecConfig_CreateConVar("sm_warden_color_green_deputy", "155", "What color to turn the deputy into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iDeputyColorBlue = AutoExecConfig_CreateConVar("sm_warden_color_blue_deputy", "255", "What color to turn the deputy into (rgB): x - blue value", _, true, 0.0, true, 255.0);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void Color_OnWardenCreation(int client)
{
	CreateTimer(1.0, Timer_WardenFixColor, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void Color_OnWardenRemoved(int client)
{
	CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(client));
}

public void Color_OnDeputyCreation(int client)
{
	CreateTimer(1.0, Timer_WardenFixColor, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void Color_OnDeputyRemoved(int client)
{
	CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(client));
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_WardenFixColor(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client, false, false))
	{
		if (IsClientWarden(client) || IsClientDeputy(client))
		{
			if (gc_bPlugin.BoolValue && g_bEnabled)
			{
				if (gc_bColor.BoolValue)
				{
					if (IsClientDeputy(client)) SetEntityRenderColor(client, gc_iDeputyColorRed.IntValue, gc_iDeputyColorGreen.IntValue, gc_iDeputyColorBlue.IntValue, 255);
					else if (gc_bWardenColorRandom.BoolValue)
					{
						int i = GetRandomInt(1, 7);
						SetEntityRenderColor(client, g_iColors[i][0], g_iColors[i][1], g_iColors[i][2], g_iColors[i][3]);
					}
					else SetEntityRenderColor(client, gc_iWardenColorRed.IntValue, gc_iWardenColorGreen.IntValue, gc_iWardenColorBlue.IntValue, 255);
				}
			}
		}
		else
		{
			SetEntityRenderColor(client);

			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}