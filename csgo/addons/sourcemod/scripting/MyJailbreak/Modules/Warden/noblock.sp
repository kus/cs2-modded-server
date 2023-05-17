/*
 * MyJailbreak - Warden - No Block Module.
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
ConVar gc_bNoBlock;
ConVar gc_bNoBlockDeputy;
ConVar gc_bNoBlockMode;
ConVar gc_bNoBlockLR;
ConVar gc_sCustomCommandNoBlock;

// Extern Convars
ConVar g_bNoBlockSolid;

// Booleans
bool g_bNoBlock = true;

// Integers


// Start
public void NoBlock_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_noblock", Command_ToggleNoBlock, "Allows the Warden to toggle no block");

	// AutoExecConfig
	gc_bNoBlock = AutoExecConfig_CreateConVar("sm_warden_noblock", "1", "0 - disabled, 1 - enable noblock toggle for warden", _, true, 0.0, true, 1.0);
	gc_bNoBlockDeputy = AutoExecConfig_CreateConVar("sm_warden_noblock_deputy", "1", "0 - disabled, 1 - enable noblock toggle for deputy, too", _, true, 0.0, true, 1.0);
	gc_bNoBlockMode = AutoExecConfig_CreateConVar("sm_warden_noblock_mode", "1", "0 - collision only between CT & T, 1 - collision within a team.", _, true, 0.0, true, 1.0);
	gc_bNoBlockLR  = AutoExecConfig_CreateConVar("sm_warden_noblock_lr", "1", "0 - keep noblock changes on LR / 1 - release all noblock changes on LR, ", _, true, 0.0, true, 1.0);
	gc_sCustomCommandNoBlock = AutoExecConfig_CreateConVar("sm_warden_cmds_noblock", "block, unblock, collision", "Set your custom chat command for toggle no block (!noblock (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	// Hooks
	HookEvent("round_end", NoBlock_RoundEnd);

	// FindConVar
	g_bNoBlockSolid = FindConVar("mp_solid_teammates");
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_ToggleNoBlock(int client, int args)
{
	if (gc_bNoBlock.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bNoBlockDeputy.BoolValue))
		{
			if (!g_bNoBlock)
			{
				g_bNoBlock = true;
				CPrintToChatAll("%s %t", g_sPrefix, "warden_noblockon");
				for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
				{
					SetEntProp(i, Prop_Send, "m_CollisionGroup", 2);  // 2 - none / 5 - 'default'
				}
				if (gc_bNoBlockMode.BoolValue) SetCvar("mp_solid_teammates", 0);
			}
			else
			{
				g_bNoBlock = false;
				CPrintToChatAll("%s %t", g_sPrefix, "warden_noblockoff");
				for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
				{
					SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
				}
				if (gc_bNoBlockMode.BoolValue) SetCvar("mp_solid_teammates", 1);
			}
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void NoBlock_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	SetCvar("mp_solid_teammates", g_bNoBlockSolid.BoolValue);
}

void NoBlock_OnAvailableLR()
{
	if (!gc_bNoBlockLR.BoolValue)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		SetEntProp(i, Prop_Send, "m_CollisionGroup", 5);  // 2 - none / 5 - 'default'
	}

	if (gc_bNoBlockMode.BoolValue)
	{
		SetCvar("mp_solid_teammates", 1);
	}

	CPrintToChatAll("%s %t", g_sPrefix, "warden_noblockoff");
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void NoBlock_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// No Block
	gc_sCustomCommandNoBlock.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_ToggleNoBlock, "Allows the Warden to toggle no block");
	}
}