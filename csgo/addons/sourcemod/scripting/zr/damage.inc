/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  damage.inc
 *  Type:		  Core
 *  Description:   Modify damage stuff here.
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

#if defined USE_SDKHOOKS
	/**
	 * @section Counter Strike: Source specific damage flags.
	 */
	#define DMG_CSS_FALL		(DMG_FALL)	  // Client was damaged by falling.
	#define DMG_CSS_BLAST	   (DMG_BLAST)	 // Client was damaged by explosion.
	#define DMG_CSS_BURN		(DMG_BURN)	// Client was damaged by fire.
	#define DMG_CSS_BULLET	  (DMG_NEVERGIB)  // Client was shot or knifed.
	#define DMG_CSS_HEADSHOT	(1 << 30)	   // Client was shot in the head.
	/**
	 * @endsection
	 */
#endif

/**
 * @section Suicide intercept defines.
 */
#define DAMAGE_SUICIDE_MAX_CMDS 5
#define DAMAGE_SUICIDE_MAX_LENGTH 16
/**
 * @endsection
 */

/**
 * Array to store TraceAttack HookIDs.
 */
int g_iDamageTraceAttackHookID[MAXPLAYERS + 1] = {-1, ...};

/**
 * Array to store OnTakeDamage HookIDs.
 */
int g_iDamageOnTakeDamageHookID[MAXPLAYERS + 1] = {-1, ...};

/**
 * Array to keep track of normal/mother zombies.
 */
bool g_bDamageMotherZombie[MAXPLAYERS + 1];

/**
 * Hook commands related to damage here.
 * Note: This isn't OnCommandsHook because this depends on cvars.
 */
bool g_bSuicideCmdsHooked = false;
void DamageLoad()
{
	if (g_bSuicideCmdsHooked)
	{
		return;
	}
	
	// Create command callbacks (intercepts) for listed suicide commands.
	char suicidecmds[DAMAGE_SUICIDE_MAX_CMDS * DAMAGE_SUICIDE_MAX_LENGTH];
	GetConVarString(g_hCvarsList[CVAR_DAMAGE_SUICIDE_CMDS], suicidecmds, sizeof(suicidecmds));
	
	// Create array to store cmds
	char arrayCmds[DAMAGE_SUICIDE_MAX_CMDS][DAMAGE_SUICIDE_MAX_LENGTH];
	
	// Explode string into array indexes.
	int cmdcount = ExplodeString(suicidecmds, ",", arrayCmds, sizeof(arrayCmds), sizeof(arrayCmds[]));
	
	// x = Array index.
	// arrayCmds[x] = suicide command.
	for (int x = 0; x <= cmdcount - 1; x++)
	{
		// Trim whitespace.
		TrimString(arrayCmds[x]);
		
		// Prepare intercept for this command.
		RegConsoleCmd(arrayCmds[x], DamageSuicideIntercept);
	}
	
	// Important: If ZR can be unloaded some day, make sure to remove the listeners and set this to false.
	g_bSuicideCmdsHooked = true;
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.  
 */
void DamageClientInit(int client)
{
	// Hook damage callbacks.
	#if defined USE_SDKHOOKS
		SDKHook(client, SDKHook_TraceAttack, DamageTraceAttack);
		SDKHook(client, SDKHook_OnTakeDamage, DamageOnTakeDamage);
		
		// Set dummy values so it think it's hooked.
		g_iDamageTraceAttackHookID[client] = 1;
		g_iDamageOnTakeDamageHookID[client] = 1;
	#else
		g_iDamageTraceAttackHookID[client] = ZRTools_HookTraceAttack(client, DamageTraceAttack);
		g_iDamageOnTakeDamageHookID[client] = ZRTools_HookOnTakeDamage(client, DamageOnTakeDamage);
	#endif
}

/**
 * Client is leaving the server.
 * 
 * @param client	The client index.
 */
void DamageOnClientDisconnect(int client)
{
	// Unhook damage callbacks, and reset variables.
	
	if (g_iDamageTraceAttackHookID[client] != -1)
	{
		#if defined USE_SDKHOOKS
			SDKUnhook(client, SDKHook_TraceAttack, DamageTraceAttack);
		#else
			ZRTools_UnhookTraceAttack(g_iDamageTraceAttackHookID[client]);
		#endif
		
		g_iDamageTraceAttackHookID[client] = -1;
	}
	
	if (g_iDamageOnTakeDamageHookID[client] != -1)
	{
		#if defined USE_SDKHOOKS
			SDKUnhook(client, SDKHook_OnTakeDamage, DamageOnTakeDamage);
		#else
			ZRTools_UnhookOnTakeDamage(g_iDamageOnTakeDamageHookID[client]);
		#endif
		
		g_iDamageOnTakeDamageHookID[client] = -1;
	}
}

/**
 * A client was infected.
 * 
 * @param client		The client index.
 * @param motherinfect  True if the zombie is mother, false if not.
 */
void DamageOnClientInfected(int client, bool motherinfect)
{
	// Update if client is a mother zombie or not.
	g_bDamageMotherZombie[client] = motherinfect;
}

/**
 * Hook: TraceAttack
 * Called right before the bullet enters a client.
 * 
 * @param client		The client index.
 * @param inflictor	 The entity index of the inflictor.
 * @param attacker	  The client index of the attacker.
 * @param damage		The amount of damage inflicted.
 * @param hitbox		The hitbox index.
 * @param hitgroup	  The hitgroup index.  
 * @return			  Return ZRTools_Handled to stop bullet from hitting client.
 *					  ZRTools_Continue to allow bullet to hit client.
 */
#if defined USE_SDKHOOKS
public Action DamageTraceAttack(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
#else
public ZRTools_Action DamageTraceAttack(int client, int inflictor, int attacker, float damage, int hitbox, int hitgroup)
#endif
{
	// If attacker isn't valid, then stop.
	if (!ZRIsClientValid(attacker))
	{
		return ACTION_CONTINUE;
	}
	
	// If client is attacking himself, then stop.
	if(attacker == client)
	{
		return ACTION_CONTINUE;
	}
	
	// Get zombie flag for each client.
	bool clientzombie = InfectIsClientInfected(client);
	bool attackerzombie = InfectIsClientInfected(attacker);
	
	// If the flags are the same on both clients, then stop.
	if (clientzombie == attackerzombie)
	{
		// If friendly fire is blocked, then allow damage.
		bool damageblockff = GetConVarBool(g_hCvarsList[CVAR_DAMAGE_BLOCK_FF]);
		if (!damageblockff)
		{
			return ACTION_CONTINUE;
		}
		
		// Stop bullet from hurting client.
		return ACTION_HANDLED;
	}
	
	// Here we know that attacker and client are different teams.
	
	// Check if immunity module requires damage to be blocked.
	if (ImmunityOnClientTraceAttack(client, attacker, damage, hitgroup, damagetype))
	{
		// Block damage.
		return ACTION_HANDLED;
	}
	
	// If client is a human, then allow damage.
	if (InfectIsClientHuman(client))
	{
		// Allow damage.
		return ACTION_CONTINUE;
	}
	
	// If damage hitgroups cvar is disabled, then allow damage.
	// TODO: There are two cvars: zr_hitgroups and zr_damage_hitgroups. Maybe
	//	   just use zr_hitgroups?
	bool damagehitgroups = GetConVarBool(g_hCvarsList[CVAR_DAMAGE_HITGROUPS]);
	if (!damagehitgroups)
	{
		// Allow damage.
		return ACTION_CONTINUE;
	}
	
	// If damage is disabled for this hitgroup, then stop.
	int index = HitgroupToIndex(hitgroup);
	
	// If index can't be found, then allow damage.
	if (index == -1)
	{
		// Allow damage.
		return ACTION_CONTINUE;
	}
	
	bool candamage = HitgroupsCanDamage(index);
	if (!candamage)
	{
		// Stop bullet from hurting client.
		return ACTION_HANDLED;
	}
	
	// Allow damage.
	return ACTION_CONTINUE;
}

/**
 * Hook: OnTakeDamage
 * Called right before damage is done.
 * 
 * @param client		The client index.
 * @param inflictor	 The entity index of the inflictor.
 * @param attacker	  The client index of the attacker.
 * @param damage		The amount of damage inflicted.
 * @param damagetype	The type of damage inflicted.
 * @param ammotype	  The ammo type of the attacker's weapon. 
 * @return			  Return ZRTools_Handled to stop the damage to client.
 *					  ZRTools_Continue to allow damage to client.
 */
#if defined USE_SDKHOOKS
public Action DamageOnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
#else
public ZRTools_Action DamageOnTakeDamage(int client, int inflictor, int attacker, float damage, int damagetype, int ammotype)
#endif
{
	// Get classname of the inflictor.
	char classname[64];
	GetEdictClassname(inflictor, classname, sizeof(classname));
	
	// If entity is a trigger, then allow damage. (Map is damaging client)
	if (StrContains(classname, "trigger") > -1)
	{
		return ACTION_CONTINUE;
	}
	
	int action;
	
	// Forward this hook to another module an return (or not) what it wants.
	action = NapalmOnTakeDamage(client, damagetype);
	
	// If the napalm module wants to return here, then return the int casted into the action type.
	if (action > -1)
	{
		#if defined USE_SDKHOOKS
			return view_as<Action>(action);
		#else
			return ZRTools_Action action;
		#endif
	}
	
	// Client was shot or knifed.
	if (damagetype & DMG_CSS_BULLET)
	{
		// If attacker isn't valid, then allow damage.
		if (!ZRIsClientValid(attacker))
		{
			return ACTION_CONTINUE;
		}
		
		// Get zombie flag for each client.
		bool clientzombie = InfectIsClientInfected(client);
		bool attackerzombie = InfectIsClientInfected(attacker);
		
		// If client and attacker are on the same team, then let CS:S handle the rest.
		if (clientzombie == attackerzombie)
		{
			return ACTION_CONTINUE;
		}
		
		// We know that clientzombie is the opposite of attacker zombie.
		
		// If the client is a zombie, then allow damage.
		if (clientzombie)
		{
			return ACTION_CONTINUE;
		}
		
		// Check if immunity module blocked or modified the damage.
		Action immunityAction = ImmunityOnClientDamage(client, attacker, damage);
		if (immunityAction != Plugin_Continue)
		{
			// Damage was blocked or modified.
			return immunityAction;
		}
		
		// Client is about to be infected, re-add HP so they aren't killed by
		// knife. But only do this when immunity mode is disabled.
		if (ClassGetImmunityMode(client) == Immunity_None)
		{
			if(!g_allweapons[attackerzombie])
			{
				int health = GetClientHealth(client);
				SetEntityHealth(client, health + RoundToNearest(damage));
			}
			// Allow damage.
			return ACTION_CONTINUE;
		}
	}
	// Client was damaged by explosion.
	else if (damagetype & DMG_CSS_BLAST)
	{
		// If blast damage is blocked, then stop.
		bool damageblockblast = GetConVarBool(g_hCvarsList[CVAR_DAMAGE_BLOCK_BLAST]);
		if (!damageblockblast)
		{
			return ACTION_CONTINUE;
		}
		
		// If attacker isn't valid, then allow damage.
		if (!ZRIsClientValid(attacker))
		{
			return ACTION_CONTINUE;
		}
		
		// If client is a zombie, then allow damage.
		if (InfectIsClientInfected(client))
		{
			return ACTION_CONTINUE;
		}
		
		// Stop damage.
		return ACTION_HANDLED;
	}
	// Client was damaged by fire.
	else if (damagetype & DMG_CSS_BURN)
	{
		// If fire damage is blocked, then stop.
		bool damageblockfire = GetConVarBool(g_hCvarsList[CVAR_DAMAGE_BLOCK_FIRE]);
		if (!damageblockfire)
		{
			return ACTION_CONTINUE;
		}
		
		// If attacker isn't valid, then allow damage.
		if (!ZRIsClientValid(attacker))
		{
			return ACTION_CONTINUE;
		}
		
		// If client is a zombie, then allow damage.
		if (InfectIsClientInfected(client))
		{
			return ACTION_CONTINUE;
		}
		
		// Stop damage.
		return ACTION_HANDLED;
	}
	// Client was damaged by falling.
	else if (damagetype & DMG_CSS_FALL)
	{
		// If class has "nofalldamage" disabled, then allow damage.
		bool blockfalldamage = ClassGetNoFallDamage(client);
		if (!blockfalldamage)
		{
			return ACTION_CONTINUE;
		}
		
		// Stop damage.
		return ACTION_HANDLED;
	}
	
	// Allow damage.
	return ACTION_CONTINUE;
}

/**
 * Command callback (kill, spectate, jointeam, joinclass)
 * Block command if plugin thinks they are trying to commit suicide.
 * 
 * @param client	The client index.
 * @param argc	  The number of arguments in command string.
 */	 
public Action DamageSuicideIntercept(int client, int argc)
{
	// Get suicide interception settings.
	bool suicideAfterInfect = GetConVarBool(g_hCvarsList[CVAR_SUICIDE_AFTER_INFECT]);
	bool suicideZombie = GetConVarBool(g_hCvarsList[CVAR_DAMAGE_SUICIDE_ZOMBIE]);
	bool suicideZombieMother = GetConVarBool(g_hCvarsList[CVAR_DAMAGE_SUICIDE_MZOMBIE]);
	bool suicideHuman = GetConVarBool(g_hCvarsList[CVAR_DAMAGE_SUICIDE_HUMAN]);
	
	// Check various criterias that will _allow_ the command. If no criterias
	// match, block it.
	if(!IsClientInGame(client))
		return Plugin_Continue;
	
	// Check general criterias.
	if ((suicideAfterInfect && !g_bZombieSpawned) ||	// Check if it should block suicides before mother zombie.
		!ZRIsClientValid(client) ||					 // Validate client (to stop console).
		!IsPlayerAlive(client))						 // Check if dead.
	{
		// Allow command.
		return Plugin_Continue;
	}
	
	// Check zombie criterias.
	if (InfectIsClientInfected(client))
	{
		if (g_bDamageMotherZombie[client] && !suicideZombieMother ||	// Check if suicide is allowed for mother zombies.
			(!g_bDamageMotherZombie[client] && !suicideZombie))		 // Check if suicide is allowed for regular zombies.
		{
			// Allow command.
			return Plugin_Continue;
		}
	}
	
	// Check human criterias.
	// Allow suicide if player is a human and humans can suicide.
	if (InfectIsClientHuman(client) && !suicideHuman)
	{
		// Allow command.
		return Plugin_Continue;
	}
	
	// Tell client their command has been intercepted, and log.
	TranslationPrintToChat(client, "Damage suicide intercept");
	LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Damage, "Suicide Intercept", "\"%L\" attempted suicide.", client);
	
	// Block command.
	return Plugin_Handled;
}
