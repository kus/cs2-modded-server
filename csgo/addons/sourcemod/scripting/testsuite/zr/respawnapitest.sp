/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  respawnapi.sp
 *  Type:		  Test plugin
 *  Description:   Tests the respawn API.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

#pragma semicolon 1
#include <sourcemod>
#include <zombiereloaded>

public Plugin:myinfo =
{
	name = "Zombie:Reloaded Respawn API Test",
	author = "Greyscale | Richard Helgeby",
	description = "Tests the respawn API for ZR",
	version = "1.0.0",
	url = "http://code.google.com/p/zombiereloaded/"
};

new Handle:cvarBlockRespawn;
new Handle:cvarAllSuicide;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	RegConsoleCmd("zrtest_killed_by_world", KilledByWorldCommand, "Gets or sets the killed by world value. Usage: zrtest_killed_by_world <target> [1|0]");
	RegConsoleCmd("zrtest_respawn", RespawnClientCommand, "Respawn a player. Usage: zrtest_respawn <target>");
	
	cvarBlockRespawn = CreateConVar("zrtest_block_respawn", "0", "Block respawning.");
	cvarAllSuicide = CreateConVar("zrtest_all_suicide", "0", "Treat all deaths as suicide.");
}

public Action:KilledByWorldCommand(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	
	if (target <= 0)
	{
		ReplyToCommand(client, "Gets or sets the killed by world value. Usage: zrtest_killed_by_world <target> [value]");
		return Plugin_Handled;
	}
	
	if (argc > 1)
	{
		// Set value.
		GetCmdArg(2, valueString, sizeof(valueString));
		ZR_SetKilledByWorld(target, bool:StringToInt(valueString));
	}
	else
	{
		// Print value.
		ReplyToCommand(client, "Killed by world: %d", ZR_GetKilledByWorld(target));
	}
	
	return Plugin_Handled;
}

public Action:RespawnClientCommand(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	
	if (target < 0)
	{
		ReplyToCommand(client, "Respawn a player. Usage: zrtest_respawn <target>");
		return Plugin_Handled;
	}

	ZR_RespawnClient(target, ZR_Repsawn_Default);
	
	return Plugin_Handled;
}

public Action:ZR_OnClientRespawn(&client, &ZR_RespawnCondition:condition)
{
	if (GetConVarBool(cvarBlockRespawn))
	{
		PrintToChatAll("Respawn blocked on client %d.", client);
		return Plugin_Handled;
	}
	
	PrintToChatAll("Client %d is about to respawn. Condition: %d", client, condition);
	
	if (GetConVarBool(cvarAllSuicide))
	{
		// Set client suicide.
		ZR_SetKilledByWorld(client, true);
		PrintToChatAll("Client %d is marked as suicide victim.");
	}
	
	return Plugin_Continue;
}

public ZR_OnClientRespawned(client, ZR_RespawnCondition:condition)
{
	PrintToChatAll("Client %d respawned.", client);
}
