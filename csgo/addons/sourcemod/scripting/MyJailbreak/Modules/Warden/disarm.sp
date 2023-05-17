/*
 * MyJailbreak - Warden - Disarm Module.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Hexer10
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
ConVar gc_bDisarm;
ConVar gc_iDisarm;
ConVar gc_iDisarmMode;
ConVar gc_bDisarmKnife;

// Integers
int g_iDisarm;

// Start
public void Disarm_OnPluginStart()
{
	// AutoExecConfig
	gc_bDisarm = AutoExecConfig_CreateConVar("sm_warden_disarm", "1", "0 - disabled, 1 - enable disarm weapon on shot the arms/hands", _, true, 0.0, true, 1.0);
	gc_iDisarm = AutoExecConfig_CreateConVar("sm_warden_disarm_mode", "1", "1 - Only warden can disarm, 2 - warden & deputy can disarm, 3 - All CT can disarm, 4 - Everyone can disarm (CT & T)", _, true, 1.0, true, 3.0);
	gc_iDisarmMode = AutoExecConfig_CreateConVar("sm_warden_disarm_drop", "1", "1 - weapon will drop, 2 - weapon  disapear", _, true, 1.0, true, 2.0);
	gc_bDisarmKnife = AutoExecConfig_CreateConVar("sm_warden_disarm_knife", "1", "0 - negate the knife disarm, 1 - disarm all weapons", _, true, 0.0, true, 1.0); 

	// Hooks 
	HookEvent("player_hurt", Disarm_Event_PlayerHurt);
	HookEvent("round_start", Disarm_Event_RoundStart);
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Disarm_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iDisarm = gc_iDisarm.IntValue;
}

public Action Disarm_Event_PlayerHurt(Event event, char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bDisarm.BoolValue || g_bIsLR)
		return Plugin_Continue;

	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int hitgroup = event.GetInt("hitgroup");
	int victimweapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
		
	if (IsValidClient(attacker, true, false) && IsValidClient(victim, true, false))
	{
		if ((IsClientWarden(attacker) && g_iDisarm == 1) || ((IsClientWarden(attacker) || IsClientDeputy(attacker)) && g_iDisarm == 2) || ((GetClientTeam(attacker) == CS_TEAM_CT) && g_iDisarm == 3) || ((GetClientTeam(attacker) != GetClientTeam(victim)) && g_iDisarm == 4))
		{
			if (hitgroup == 4 || hitgroup == 5)
			{
				if (victimweapon != -1)
				{
					char sWeaponName[64];
					GetEdictClassname(victimweapon, sWeaponName, sizeof(sWeaponName));

					if (gc_bDisarmKnife.BoolValue && (StrContains(sWeaponName, "knife", false) != -1 || StrContains(sWeaponName, "bayonet", false) != -1))
						return Plugin_Handled;
					
					CPrintToChatAll("%s %t", g_sPrefix, "warden_disarmed", victim, attacker);
					PrintCenterText(victim, "%t", "warden_lostgun");
					
					if (gc_iDisarmMode.IntValue == 1)
					{
						CS_DropWeapon(victim, victimweapon, true, true);
						return Plugin_Stop;
					}
					else if (gc_iDisarmMode.IntValue == 2)
					{
						CS_DropWeapon(victim, victimweapon, true, true);
						
						if (IsValidEdict(victimweapon))
						{
							if (GetEntPropEnt(victimweapon, Prop_Data, "m_hOwnerEntity") == -1)
							{
								AcceptEntityInput(victimweapon, "Kill");
							}
						}
						return Plugin_Stop;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}