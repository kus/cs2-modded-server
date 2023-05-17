/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  respawnapi.sp
 *  Type:		  Test plugin
 *  Description:   Tests the infection API.
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
	name = "Zombie:Reloaded Infection API Test",
	author = "Greyscale | Richard Helgeby",
	description = "Tests the infection API for ZR",
	version = "1.0.0",
	url = "http://code.google.com/p/zombiereloaded/"
};

new Handle:cvarBlockInfect;
new Handle:cvarBlockHuman;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	RegConsoleCmd("zrtest_iszombie", IsZombieCommand, "Returns whether a player is a zombie or not. Usage: zrtest_iszombie <target>");
	RegConsoleCmd("zrtest_ishuman", IsHumanCommand, "Returns whether a player is a human or not. Usage: zrtest_ishuman <target>");
	
	RegConsoleCmd("zrtest_infect", InfectClientCommand, "Infects a player. Usage: zrtest_infect <target>");
	RegConsoleCmd("zrtest_human", HumanClientCommand, "Turns a player back into a human. Usage: zrtest_human <target>");
	
	cvarBlockInfect = CreateConVar("zrtest_block_infect", "0", "Block infection.");
	cvarBlockHuman = CreateConVar("zrtest_block_human", "0", "Block turning players back into humans.");
}

public Action:IsZombieCommand(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	else
	{
		ReplyToCommand(client, "Returns whether a player is a zombie or not. Usage: zrtest_iszombie <target>");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Client %d is a zombie: %d", client, ZR_IsClientZombie(target));
	
	return Plugin_Handled;
}

public Action:IsHumanCommand(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	else
	{
		ReplyToCommand(client, "Returns whether a player is a human or not. Usage: zrtest_ishuman <target>");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Client %d is a human: %d", client, ZR_IsClientHuman(target));
	
	return Plugin_Handled;
}

public Action:InfectClientCommand(client, argc)
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
		ReplyToCommand(client, "Infects a player. Usage: zrtest_infect <target>");
		return Plugin_Handled;
	}

	ZR_InfectClient(target);
	
	return Plugin_Handled;
}

public Action:HumanClientCommand(client, argc)
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
		ReplyToCommand(client, "Turns a player back into a human. Usage: zrtest_human <target>");
		return Plugin_Handled;
	}

	ZR_HumanClient(target);
	
	return Plugin_Handled;
}

public Action:ZR_OnClientInfect(&client, &attacker, &bool:motherInfect, &bool:respawnOverride, &bool:respawn)
{
	if (GetConVarBool(cvarBlockInfect))
	{
		PrintToChatAll("Infection blocked on client %d.", client);
		return Plugin_Handled;
	}
	
	PrintToChatAll("Client %d is about to be infected. Attacker: %d, Mother zombie: %d, Respawn override: %d, Respawn: %d.", client, attacker, motherInfect, respawnOverride, respawn);
	return Plugin_Continue;
}

public ZR_OnClientInfected(client, attacker, bool:motherInfect, bool:respawnOverride, bool:respawn)
{
	PrintToChatAll("Client %d was infected. Attacker: %d, Mother zombie: %d, Respawn override: %d, Respawn: %d.", client, attacker, motherInfect, respawnOverride, respawn);
}

public Action:ZR_OnClientHuman(&client, &bool:respawn, &bool:protect)
{
	if (GetConVarBool(cvarBlockHuman))
	{
		PrintToChatAll("Turning human blocked on client %d.", client);
		return Plugin_Handled;
	}
	
	PrintToChatAll("Client %d is about to become a human. Respawn: %d, Spawn protect: %d", client, respawn, protect);
	return Plugin_Continue;
}

public ZR_OnClientHumanPost(client, bool:respawn, bool:protect)
{
	PrintToChatAll("Client %d turned a human. Respawn: %d, Spawn protect: %d", client, respawn, protect);
}
