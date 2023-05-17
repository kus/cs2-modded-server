/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  knockback.sp
 *  Type:		  Test plugin
 *  Description:   Tests basic knock back.
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
#include <sdktools>
#include <sdkhooks-2.2>

public Plugin:myinfo =
{
	name = "Knock back",
	author = "Greyscale | Richard Helgeby",
	description = "Tests basic knock back.",
	version = "1.0.0",
	url = "http://code.google.com/p/zombiereloaded/"
};

new Handle:hKnockBackMultiplier;
new g_iToolsVelocity;
new bool:VelocityMonitor[MAXPLAYERS];

public OnPluginStart()
{
	hKnockBackMultiplier = CreateConVar("zrtest_knockback", "4.0", "Knock back multiplier.");
	
	if (!HookEventEx("player_hurt", Event_PlayerHurt))
	{
		LogError("Failed to hook event player_hurt.");
	}
	
	// If offset "m_vecVelocity[0]" can't be found, then stop the plugin.
	g_iToolsVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");
	if (g_iToolsVelocity == -1)
	{
		LogError("Offset \"CBasePlayer::m_vecVelocity[0]\" was not found.");
	}
	
	RegConsoleCmd("zrtest_push_player", Command_PushPlayer, "Push a player. Usage: zrtest_push_player <x> <y> <z> [0|1 - base velocity]");
	RegConsoleCmd("zrtest_parent", Command_Parent, "Prints your parent entity.");
	RegConsoleCmd("zrtest_friction", Command_Friction, "Prints your floor friction multiplier.");
	RegConsoleCmd("zrtest_maxspeed", Command_MaxSpeed, "Prints your max speed.");
}

public Action:Command_PushPlayer(client, argc)
{
	if (argc < 3)
	{
		ReplyToCommand(client, "Push a player. Usage: zrtest_push_player <x> <y> <z> [0|1 - base velocity]");
		return Plugin_Handled;
	}
	
	new Float:velocity[3];
	new String:buffer[32];
	new bool:baseVelocity = false;
	
	for (new i = 0; i < 3; i++)
	{
		GetCmdArg(i + 1, buffer, sizeof(buffer));
		velocity[i] = StringToFloat(buffer);
	}
	
	if (argc > 3)
	{
		GetCmdArg(4, buffer, sizeof(buffer));
		baseVelocity = bool:StringToInt(buffer);
	}
	
	PrintToChatAll("Applying velocity on client %d (base: %d): %0.2f | %0.2f | %0.2f", client, baseVelocity, velocity[0], velocity[1], velocity[2]);
	
	if (baseVelocity)
	{
		SetBaseVelocity(client, velocity);
	}
	else
	{
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		//SetVelocity(client, velocity);
	}
	
	return Plugin_Handled;
}

public Action:Command_Parent(client, argc)
{
	new parent = GetParent(client);
	ReplyToCommand(client, "Parent index: %d", parent);
	
	return Plugin_Handled;
}

public Action:Command_Friction(client, argc)
{
	new Float:friction = GetFriction(client);
	ReplyToCommand(client, "Friction: %0.2f", friction);
	
	return Plugin_Handled;
}

public Action:Command_MaxSpeed(client, argc)
{
	new Float:maxSpeed = GetMaxSpeed(client);
	ReplyToCommand(client, "Max speed: %0.2f", maxSpeed);
	
	return Plugin_Handled;
}

public OnClientPutInServer(client)
{
	//SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	//SDKHook(client, SDKHook_PreThink, PreThink);
	//SDKHook(client, SDKHook_PreThinkPost, PreThinkPost);
	SDKHook(client, SDKHook_PostThink, PostThink);
	//SDKHook(client, SDKHook_PostThinkPost, PostThinkPost);
}

public OnClientDisconnect(client)
{
	//SDKUnhook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	//SDKUnhook(client, SDKHook_PreThink, PreThink);
	//SDKUnhook(client, SDKHook_PreThinkPost, PreThinkPost);
	SDKUnhook(client, SDKHook_PostThink, PostThink);
	//SDKUnhook(client, SDKHook_PostThinkPost, PostThinkPost);
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new damage = GetEventInt(event, "dmg_health");
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	KnockbackOnClientHurt(victim, attacker, float(damage));
}

/*public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	KnockbackOnClientHurt(victim, attacker, Float:damage);
	
	// Allow damage.
	return Plugin_Continue;
}

public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3])
{
	if (attacker > 0 && attacker < MaxClients)
	{
		KnockbackOnClientHurt(victim, attacker, Float:damage);
	}
}*/

/*public PreThink(client)
{
	//if (VelocityMonitor[client])
	{
		PrintVelocity(client, "PreThink");
	}
}*/

/*public PreThinkPost(client)
{
	//if (VelocityMonitor[client])
	{
		PrintVelocity(client, "PreThinkPost");
	}
}*/

public PostThink(client)
{
	//if (VelocityMonitor[client])
	/*{
		PrintVelocity(client, "PostThink");
	}*/
	
	SetMaxSpeed(client, 1000.0);
}

/*public PostThinkPost(client)
{
	//if (VelocityMonitor[client])
	{
		PrintVelocity(client, "PostThinkPost");
		VelocityMonitor[client] = false;
	}
}*/

stock PrintVelocity(client, const String:prefix[])
{
	new Float:velocity[3];
	GetVelocity(client, velocity);
	PrintToChatAll("%s | client: %d | %0.2f | %0.2f | %0.2f", prefix, client, velocity[0], velocity[1], velocity[2]);
}

/** Client has been hurt.
 *
 * @param client		The client index. (zombie)
 * @param attacker	  The attacker index. (human)
 * @param weapon		The weapon used.
 * @param hitgroup	  Hitgroup attacker has damaged. 
 * @param dmg_health	Damage done.
 */
KnockbackOnClientHurt(client, attacker, Float:dmg_health)
{
	// If attacker is invalid, then stop.
	if (!(attacker > 0 && attacker < MaxClients))
	{
		return;
	}
	
	// Get zombie knockback value.
	new Float:knockback = GetConVarFloat(hKnockBackMultiplier);
	
	new Float:clientloc[3];
	new Float:attackerloc[3];
	
	GetClientAbsOrigin(client, clientloc);
	
	// Get attackers eye position.
	GetClientEyePosition(attacker, attackerloc);
	
	// Get attackers eye angles.
	new Float:attackerang[3];
	GetClientEyeAngles(attacker, attackerang);
	
	// Calculate knockback end-vector.
	TR_TraceRayFilter(attackerloc, attackerang, MASK_ALL, RayType_Infinite, KnockbackTRFilter);
	TR_GetEndPosition(clientloc);
	
	// Apply damage knockback multiplier.
	knockback *= dmg_health;
	
	// Apply knockback.
	PrintToChat(attacker, "Applying knock back: %0.2f", knockback);
	VelocityMonitor[client] = true;
	KnockbackSetVelocity(client, attackerloc, clientloc, knockback);
}

/**
 * Sets velocity on a player.
 *  
 * @param client		The client index.
 * @param startpoint	The starting coordinate to push from.
 * @param endpoint	  The ending coordinate to push towards.
 * @param magnitude	 Magnitude of the push.
 */  
KnockbackSetVelocity(client, const Float:startpoint[3], const Float:endpoint[3], Float:magnitude)
{
	// Create vector from the given starting and ending points.
	new Float:vector[3];
	MakeVectorFromPoints(startpoint, endpoint, vector);
	
	// Normalize the vector (equal magnitude at varying distances).
	NormalizeVector(vector, vector);
	
	// Changes by zephyrus:
	//new flags = GetEntityFlags(client);
	//if(flags & FL_ONGROUND)
	//	vector[2]=0.5;
	
	// Apply the magnitude by scaling the vector (multiplying each of its components).
	ScaleVector(vector, magnitude);
	
	// Changes by zephyrus:
	//if(flags & FL_ONGROUND)
	//	if(vector[2]>350.0)
	//		vector[2]=350.0;
	
	new flags = GetEntityFlags(client);
	if (flags & FL_ONGROUND)
	{
		if (vector[2] < 251.0)
		{
			vector[2] = 251.0;
		}
	}
	
	// ADD the given vector to the client's current velocity.
	PrintToChatAll("Applying velocity on client %d: %0.2f | %0.2f | %0.2f", client, vector[0], vector[1], vector[2]);
	ToolsClientVelocity(client, vector);
}

/**
 * Get or set a client's velocity.
 * @param client		The client index.
 * @param vecVelocity   Array to store vector in, or velocity to set on client.
 * @param retrieve	  True to get client's velocity, false to set it.
 * @param stack		 If modifying velocity, then true will stack new velocity onto the client's
 *					  current velocity, false will reset it.
 */
stock ToolsClientVelocity(client, Float:vecVelocity[3], bool:apply = true, bool:stack = true)
{
	// If retrieve if true, then get client's velocity.
	if (!apply)
	{
		// x = vector component.
		for (new x = 0; x < 3; x++)
		{
			vecVelocity[x] = GetEntDataFloat(client, g_iToolsVelocity + (x*4));
		}
		
		// Stop here.
		return;
	}
	
	// If stack is true, then add client's velocity.
	if (stack)
	{
		// Get client's velocity.
		new Float:vecClientVelocity[3];
		
		// x = vector component.
		for (new x = 0; x < 3; x++)
		{
			vecClientVelocity[x] = GetEntDataFloat(client, g_iToolsVelocity + (x*4));
		}
		
		AddVectors(vecClientVelocity, vecVelocity, vecVelocity);
	}
	
	// Apply velocity on client.
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

/**
 * Trace Ray forward, used as a filter to continue tracing if told so. (See sdktools_trace.inc)
 *  
 * @param entity		The entity index.
 * @param contentsMask  The contents mask.
 * @return			  True to allow hit, false to continue tracing. 
 */ 
public bool:KnockbackTRFilter(entity, contentsMask)
{
	// If entity is a player, continue tracing.
	if (entity > 0 && entity < MAXPLAYERS)
	{
		return false;
	}
	
	// Allow hit.
	return true;
}

stock GetVelocity(client, Float:velocity[3])
{
	velocity[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	velocity[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	velocity[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
}

stock SetVelocity(client, const Float:velocity[3])
{
	SetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]", velocity[0]);
	SetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]", velocity[1]);
	SetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]", velocity[2]);
}

stock GetBaseVelocity(client, Float:velocity[3])
{
	GetEntPropVector(client, Prop_Send, "m_vecBaseVelocity", velocity);
}

stock SetBaseVelocity(client, const Float:velocity[3])
{
	SetEntPropVector(client, Prop_Send, "m_vecBaseVelocity", velocity);
}

stock GetParent(client)
{
	return GetEntProp(client, Prop_Send, "moveparent");
}

stock Float:GetFriction(client)
{
	return GetEntPropFloat(client, Prop_Send, "m_flFriction");
}

stock Float:GetMaxSpeed(client)
{
	return GetEntPropFloat(client, Prop_Send, "m_flMaxspeed");
}

stock SetMaxSpeed(client, Float:maxSpeed = 250.0)
{
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", maxSpeed);
}
