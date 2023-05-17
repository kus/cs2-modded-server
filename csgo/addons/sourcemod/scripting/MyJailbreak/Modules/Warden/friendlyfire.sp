/*
 * MyJailbreak - Warden - Friendly Fire Module.
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
ConVar gc_bFF;
ConVar gc_bFFDeputy;
ConVar gc_sCustomCommandFF;
ConVar gc_sFFCT;

// Extern Convars
ConVar g_bFF;
ConVar Cvar_tg_team_none_attack;
ConVar Cvar_tg_cvar_friendlyfire;
ConVar Cvar_tg_ct_friendlyfire;

//Integer
int OldCvar_tg_team_none_attack;
int OldCvar_tg_cvar_friendlyfire;
int OldCvar_tg_ct_friendlyfire;

// Start
public void FriendlyFire_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_setff", Command_FriendlyFire, "Allows player to see the state and the Warden to toggle friendly fire");

	// AutoExecConfig
	gc_bFF = AutoExecConfig_CreateConVar("sm_warden_ff", "1", "0 - disabled, 1 - enable switch ff for the warden", _, true, 0.0, true, 1.0);
	gc_sFFCT = AutoExecConfig_CreateConVar("sm_warden_ff_ct_enable", "0", "0 - disabled, 1 - enable ff for cts also", _, true, 0.0, true, 1.0);
	gc_bFFDeputy = AutoExecConfig_CreateConVar("sm_warden_ff_deputy", "1", "0 - disabled, 1 - enable switch ff for the deputy, too", _, true, 0.0, true, 1.0);
	gc_sCustomCommandFF = AutoExecConfig_CreateConVar("sm_warden_cmds_ff", "isff, friendlyfire", "Set your custom chat commands for set/see friendly fire(!ff is reservered)(!setff (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");

	// Hooks
	HookEvent("round_end", FriendlyFire_Event_RoundEnd);
	HookEvent("player_death", FriendlyFire_Event_PlayerDeath);

	// FindConVar
	g_bFF = FindConVar("mp_teammates_are_enemies");
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_FriendlyFire(int client, int args)
{
	if (gc_bFF.BoolValue)
	{
		if (g_bFF.BoolValue)
		{
			if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bFFDeputy.BoolValue))
			{
				SetCvar("mp_teammates_are_enemies", 0);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%s %t", g_sPrefix, "warden_ffisoff");

				if (Cvar_tg_team_none_attack != null)
				{
					// Replace the Cvar Value with old value
					Cvar_tg_team_none_attack.IntValue = OldCvar_tg_team_none_attack;
					Cvar_tg_cvar_friendlyfire.IntValue = OldCvar_tg_cvar_friendlyfire;
					Cvar_tg_ct_friendlyfire.IntValue = OldCvar_tg_ct_friendlyfire;
				}
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_ffison");
		}
		else
		{
			if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bFFDeputy.BoolValue))
			{
				SetCvar("mp_teammates_are_enemies", 1);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%s %t", g_sPrefix, "warden_ffison");

				if (Cvar_tg_team_none_attack != null)
				{
					Cvar_tg_team_none_attack.IntValue = 1;
					Cvar_tg_cvar_friendlyfire.IntValue = 1;
					Cvar_tg_ct_friendlyfire.IntValue = 1;
				}
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_ffisoff");
		}
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/


public void FriendlyFire_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)
		return;

	if (!g_bFF.BoolValue)
		return;

	if (GetPlayerCount(true, CS_TEAM_T) < 1)
	{
		SetCvar("mp_teammates_are_enemies", 0);
		CS_TerminateRound(5.0, CSRoundEnd_CTWin, false);
	}
}

public void FriendlyFire_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)
		return;

	if (!g_bFF.BoolValue)
		return;

	SetCvar("mp_teammates_are_enemies", 0);
	g_bFF = FindConVar("mp_teammates_are_enemies");
	CPrintToChatAll("%s %t", g_sPrefix, "warden_ffisoff");

	if (Cvar_tg_team_none_attack != null)
	{
		// Replace the Cvar Value with old value
		Cvar_tg_team_none_attack.IntValue = OldCvar_tg_team_none_attack;
		Cvar_tg_cvar_friendlyfire.IntValue = OldCvar_tg_cvar_friendlyfire;
		Cvar_tg_ct_friendlyfire.IntValue = OldCvar_tg_ct_friendlyfire;
	}
}

public Action FriendlyFire_OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (gc_sFFCT.BoolValue)
		return Plugin_Continue;

	if (gp_bMyJailBreak && MyJailbreak_IsEventDayRunning())
		return Plugin_Continue;

	if (!IsValidClient(victim, true, false) || !IsValidClient(attacker, true, false))
	{
		return Plugin_Continue;
	}

	if ((victim != attacker) && ((GetClientTeam(victim) == GetClientTeam(attacker)) && (GetClientTeam(victim) == CS_TEAM_CT)))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void FriendlyFire_OnConfigsExecuted()
{
	// Get the Cvar Value
	Cvar_tg_team_none_attack = FindConVar("tg_team_none_attack");
	Cvar_tg_cvar_friendlyfire = FindConVar("tg_cvar_friendlyfire");
	Cvar_tg_ct_friendlyfire = FindConVar("tg_ct_friendlyfire");

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Friendly fire
	gc_sCustomCommandFF.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_FriendlyFire, "Allows player to see the state and the Warden to toggle friendly fire");
	}
}

public void FriendlyFire_OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, FriendlyFire_OnTraceAttack);
}

static int GetPlayerCount(bool alive = false, int team = -1)
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, !alive))
			continue;

		if (gp_bDeadGames)
		{
			if(DeadGames_IsOnGame(i))
				continue;
		}

		if (team != -1 && GetClientTeam(i) != team)
			continue;

		iCount++;
	}

	return iCount;
}
