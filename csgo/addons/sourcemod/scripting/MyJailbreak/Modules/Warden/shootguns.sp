/*
 * MyJailbreak - Warden - Shoot Gun to remove Module.
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
ConVar gc_bShootGuns;
ConVar gc_iShootGunsMode;

// Start
public void ShootGuns_OnPluginStart()
{
	// AutoExecConfig
	gc_bShootGuns = AutoExecConfig_CreateConVar("sm_warden_shootguns_enable", "1", "0 - disabled, 1 - enable shoot guns on ground to remove", _, true, 0.0, true, 1.0);
	gc_iShootGunsMode = AutoExecConfig_CreateConVar("sm_warden_shootguns_mode", "1", "1 - only warden / 2 - warden & deputy / 3 - warden, deputy & ct / 4 - all player", _, true, 1.0, true, 4.0);

	// Hooks
	HookEvent("bullet_impact", ShootGuns_Event_BulletImpact);
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void ShootGuns_Event_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the clients id
	int weapon = GetClientAimTarget(client, false);

	if (gc_bShootGuns.BoolValue && ((gc_iShootGunsMode.IntValue == 1 && IsClientWarden(client)) || (gc_iShootGunsMode.IntValue == 2 && (IsClientWarden(client) || IsClientDeputy(client)) || (gc_iShootGunsMode.IntValue == 3 && (GetClientTeam(client) == CS_TEAM_CT)) || (gc_iShootGunsMode.IntValue == 4))))
	{
		if (IsValidEdict(weapon) && !IsValidClient(weapon, true, true))
		{
			char buffer[8];
			if (!GetEdictClassname(weapon, buffer, sizeof(buffer)))
				return;

			if (StrContains(buffer, "weapon_", false) != -1)
			{
				AcceptEntityInput(weapon, "Kill");
			}
		}
	}
}