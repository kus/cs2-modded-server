/*
 * MyJailbreak - Warden - Backstab Module.
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
ConVar gc_bBackstab;
ConVar gc_bBackstabDeputy;
ConVar gc_iBackstabNumber;
ConVar gc_sAdminFlagBackstab;

// Integers
int g_iBackstabNumber[MAXPLAYERS+1];

// Start
public void BackStab_OnPluginStart()
{
	// AutoExecConfig
	gc_bBackstab = AutoExecConfig_CreateConVar("sm_warden_backstab", "1", "0 - disabled, 1 - enable backstab protection for warden", _, true, 0.0, true, 1.0);
	gc_bBackstabDeputy = AutoExecConfig_CreateConVar("sm_warden_backstab_deputy", "1", "0 - disabled, 1 - enable backstab protection for deputy, too", _, true, 0.0, true, 1.0);
	gc_iBackstabNumber = AutoExecConfig_CreateConVar("sm_warden_backstab_number", "1", "How many time a warden get protected? 0 - alltime", _, true, 1.0);
	gc_sAdminFlagBackstab = AutoExecConfig_CreateConVar("sm_warden_backstab_flag", "", "Set flag for admin/vip to get warden/deputy backstab protection. No flag = feature is available for all players!");

	// Hooks
	HookEvent("round_start", BackStab_Event_RoundStart);
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void BackStab_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iBackstabNumber[i] = gc_iBackstabNumber.IntValue;
	}
}

public Action BackStab_OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!gc_bBackstab.BoolValue)
		return Plugin_Continue;

	if (damage < 99.0)
		return Plugin_Continue;

	if (!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false))
		return Plugin_Continue;

	if (gp_bHosties && gp_bLastRequest) if (IsClientInLastRequest(victim))
		return Plugin_Continue;

	if (IsClientWarden(victim) || (IsClientDeputy(victim) && gc_bBackstabDeputy.BoolValue))
	{
		if (!MyJB_CheckVIPFlags(victim, "sm_warden_backstab_flag", gc_sAdminFlagBackstab, "sm_warden_backstab_flag"))
			return Plugin_Continue;

		char sWeapon[32];
		if (IsValidEntity(weapon))
		{
			GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
		}

		if ((StrContains(sWeapon, "knife", false) != -1) || (StrContains(sWeapon, "bayonet", false) != -1))
		{
			if (gc_iBackstabNumber.IntValue == 0)
			{
				PrintCenterText(attacker, "%t", "warden_backstab");

				return Plugin_Handled;
			}
			else if (g_iBackstabNumber[victim] > 0)
			{
				PrintCenterText(attacker, "%t", "warden_backstab");
				g_iBackstabNumber[victim]--;

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void BackStab_OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, BackStab_OnTakedamage);
}