/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  napalm.inc
 *  Type:		  Module 
 *  Description:   Grenades burn zombies when damaged by them.
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

/**
 * The fuse length of an hegrenade.
 */ 
#define GRENADE_FUSE_TIME 3.0

/**
 * @section m_nWaterLevel defines.
 */
#define NAPALM_WLEVEL_DRY 0
#define NAPALM_WLEVEL_FEET 1
#define NAPALM_WLEVEL_HALF 2
#define NAPALM_WLEVEL_FULL 3
/**
 * @endsection
 */

/**
 * Variable to store water-level offset value.
 */
int g_iToolsWaterLevel;

/**
 * Find napalm-specific offsets here.
 */
void NapalmOnOffsetsFound()
{
	// If offset "m_bInBuyZone" can't be found, then stop the plugin.
	g_iToolsWaterLevel = FindSendPropInfo("CBasePlayer", "m_nWaterLevel");
	if (g_iToolsWaterLevel == -1)
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Napalm, "Offsets", "Offset \"CBaseEntity::m_nWaterLevel\" was not found.");
	}
}

/**
 * Hook: OnTakeDamage
 * Forwarded from the damage module to check if we should extinguish any flames.
 * 
 * @param client		The client index.
 * @param damagetype	The type of damage inflicted.
 * @return			  Return ZRTools_Handled to stop the damage to client.
 *					  ZRTools_Continue to allow damage to client.
 *					  Return -1 to not return anything and let the damage module continue as usual.
 */
int NapalmOnTakeDamage(int client, int damagetype)
{
	// Client was damaged by fire.
	if (damagetype & DMG_CSS_BURN)
	{
		// Only take action if it isn't disabled, or the option is valid.
		int douse = GetConVarInt(g_hCvarsList[CVAR_NAPALM_DOUSE]);
		
		if (douse > NAPALM_WLEVEL_DRY && douse <= NAPALM_WLEVEL_FULL)
		{
			// If the client water-level is equal or higher than the given, then we want to extinguish the flame.
			if (NapalmGetClientWaterLevel(client) >= douse)
			{
				// Put the fire out.
				
				//ExtinguishEntity(client);  <-- Don't use this.  Takes off the FL_ONFIRE flag, but flame doesn't get extinguished.
				
				// This works.
				int fire = GetEntPropEnt(client, Prop_Data, "m_hEffectEntity");
				if (IsValidEntity(fire))
				{
					// Make sure the entity is a flame, so we can extinguish it.
					char classname[64];
					GetEdictClassname(fire, classname, sizeof(classname));
					if (StrEqual(classname, "entityflame", false))
					{
						SetEntPropFloat(fire, Prop_Data, "m_flLifetime", 0.0);
					}
					// Log what entity was in that property, for future reference.
					else
					{
						LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Napalm, "Napalm Douse", "Found unexpected entity in prop \"m_flLifetime\": \"%s\"", classname);
					}
				}
				
				return view_as<int>(ACTION_CONTINUE);
			}
		}
	}
	
	// Let the damage module continue as usual.
	return -1;
}

/**
 *  Client has been hurt.
 * 
 * @param client	The client index.
 * @param attacker  The attacker index.
 * @param weapon	The weapon name. 
 */
void NapalmOnClientHurt(int client, int attacker, const char[] weapon)
{
	// If there's no attacker, then stop.
	if (!attacker)
	{
		return;
	}
	
	// If player isn't a zombie, then stop.
	if (!InfectIsClientInfected(client))
	{
		return;
	}
	
	// If napalm time is invalid or 0, then stop.
	float napalm_time = ClassGetNapalmTime(client);
	if (napalm_time <= 0.0)
	{
		return;
	}
	
	// If the attacker can't throw napalm grenades, then stop.
	if (!ClassGetHasNapalm(attacker))
	{
		return;
	}
	
	// If weapon is a grenade, then ignite player.
	if (StrEqual(weapon, "hegrenade", false))
	{
		bool reset = GetConVarBool(g_hCvarsList[CVAR_NAPALM_TIME_RESET]);
		int flags = GetEntityFlags(client);
		
		if (reset || !(flags & FL_ONFIRE))
		{
			// This stops the fire before re-ignition.
			ExtinguishEntity(client);
			
			// Ignite client.
			IgniteEntity(client, napalm_time);
		}
	}
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void NapalmOnClientDeath(int client)
{
	// Extinguish any flames to stop burning sounds.
	ExtinguishEntity(client);
}

/**
 *  Weapon has been fired.
 *
 * @param client	   The client index.
 * @param weapon	   The weapon name.
 */
void NapalmOnWeaponFire(int client, const char[] weapon)
{
	// If grenade fire is disabled, then stop.
	bool napalmignite = GetConVarBool(g_hCvarsList[CVAR_NAPALM_IGNITE]);
	if (!napalmignite)
	{
		return;
	}
	
	// If human class can't throw napalm grenades, then stop.
	if (!ClassGetHasNapalm(client))
	{
		return;
	}
	
	// If weapon isn't a grenade, then stop.
	if (!StrEqual(weapon, "weapon_hegrenade", false))
	{
		return;
	}
	
	// Wait .1 seconds.
	CreateTimer(0.1, NapalmIgniteGrenade);
}

/**
 * Timer callback, ignite's all hegrenade projectiles.
 * 
 * @param timer	 The timer handle.
 */   
public Action NapalmIgniteGrenade(Handle timer)
{
	char classname[64];
	
	// Get max entities.
	int maxentities = GetMaxEntities();
	
	// x = entity index.
	for (int x = 0; x <= maxentities; x++)
	{
		// If entity is invalid, then stop.
		if(!IsValidEntity(x) || !IsValidEdict(x))
		{
			continue;
		}
		
		GetEdictClassname(x, classname, sizeof(classname));
		if(StrEqual(classname, "hegrenade_projectile"))
		{
			IgniteEntity(x, GRENADE_FUSE_TIME);
		}
	}
}

/**
 * Checks the current water-level on a client.
 * 
 * @param client	The client index.
 * @return		  A NAPALM_WLEVEL_ define. 
 */
stock int NapalmGetClientWaterLevel(int client)
{
	// Return client's water-level.
	return GetEntData(client, g_iToolsWaterLevel);
}