/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  damageinfo.sp
 *  Type:		  Test plugin
 *  Description:   Dumps damage information.
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
#include <sdkhooks-2.2>

public Plugin:myinfo =
{
	name = "Damage information",
	author = "Greyscale | Richard Helgeby",
	description = "Dumps damage information.",
	version = "1.0.0",
	url = "http://code.google.com/p/zombiereloaded/"
};

new Handle:hBlockOnTakeDamage;
new Handle:hBlockTraceAttack;

public OnPluginStart()
{
	hBlockOnTakeDamage = CreateConVar("zrtest_blockontakedamage", "0", "Block OnTakeDamage.");
	hBlockTraceAttack = CreateConVar("zrtest_blocktraceattack", "0", "Block TraceAttack.");
	
	if (!HookEventEx("player_hurt", Event_PlayerHurt))
	{
		LogError("Failed to hook event player_hurt.");
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_TraceAttack, TraceAttack);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new hitgroup = GetEventInt(event, "hitgroup");
	new damage = GetEventInt(event, "dmg_health");
	new damageArmor = GetEventInt(event, "dmg_armor");
	decl String:weapon[64];
	weapon[0] = 0;
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	
	decl String:msg[128];
	msg[0] = 0;
	
	Format(msg, sizeof(msg), "victim:%d | attacker:%d | hitgroup:%d | dmg:%d | dmg armor:%d | weapon:%s", victim, attacker, hitgroup, damage, damageArmor, weapon);
	
	PrintToChat(victim, "Receive hurt event -- %s", msg);
	PrintToConsole(victim, "Receive hurt event -- %s", msg);
	
	if (attacker > 0 && attacker < MaxClients)
	{
		PrintToChat(attacker, "Send hurt event -- %s", msg);
		PrintToConsole(attacker, "Send hurt event -- %s", msg);
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	/*
		Here we can control whether bullets or other damage that hits the
		victim's body should be allowed.
		
		If TraceAttack is blocked, bullets will go through the body and the
		attacker can't deal any damage to the victim.
		
		By blocking OnTakeDamage we can use this to allow players to actually
		hit a player without giving damage to him. This can be used as a simple
		trace, for example healing the victim instead of damaging him.
	*/
	
	decl String:msg[128];
	msg[0] = 0;
	
	Format(msg, sizeof(msg), "victim:%d | attacker:%d | inflictor:%d | dmg:%0.2f | dmg type:%d | weapon ent:%d | force:%0.2f | dmg pos:%0.2f", victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
	
	PrintToChat(victim, "Damage taken -- %s", msg);
	PrintToConsole(victim, "Damage taken -- %s", msg);
	
	if (attacker > 0 && attacker < MaxClients)
	{
		PrintToChat(attacker, "Damage given -- %s", msg);
		PrintToConsole(attacker, "Damage given -- %s", msg);
	}
	
	if (GetConVarBool(hBlockOnTakeDamage))
	{
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
}

public Action:TraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	/*
		Here we can control whether bullets or other damage is allowed to hit
		the player's body.
		
		If blocked, bullets will go through the body.
		
		OnTakeDamage decides whether damage is actually allowed.
	*/
	
	decl String:msg[128];
	msg[0] = 0;
	
	Format(msg, sizeof(msg), "victim:%d | attacker:%d | inflictor:%d | dmg:%0.2f | dmg type:%d | ammo type:%d | hitbox:%d | hitgroup: %d", victim, attacker, inflictor, damage, damagetype, ammotype, hitbox, hitgroup);
	
	PrintToChat(victim, "Receive attack -- %s", msg);
	PrintToConsole(victim, "Receive attack -- %s", msg);
	
	if (attacker > 0 && attacker < MaxClients)
	{
		PrintToChat(attacker, "Attacking -- %s", msg);
		PrintToConsole(attacker, "Attacking -- %s", msg);
	}
	
	if (GetConVarBool(hBlockTraceAttack))
	{
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
}
