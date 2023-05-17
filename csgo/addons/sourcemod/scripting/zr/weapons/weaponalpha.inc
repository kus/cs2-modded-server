/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  weaponalpha.inc
 *  Type:		  Core 
 *  Description:   Weapon alpha functions, and alpha updating on drop/pickup.
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
 * Default alpha on any CS:S weapon.
 */
#define WEAPONALPHA_DEFAULT_VALUE 255

/**
 * Array that stores the "HookID" to be later unhooked on player disconnect.
 */
int g_iWeaponDropHookID[MAXPLAYERS + 1] = {-1, ...};

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void WeaponAlphaClientInit(int client)
{
	// Hook "Weapon_Drop" on client.
	#if defined USE_SDKHOOKS
		SDKHook(client, SDKHook_WeaponDrop, WeaponAlphaDrop);
		
		// Set dummy value so it think it's hooked.
		g_iWeaponDropHookID[client] = 1;
	#else
		g_iWeaponDropHookID[client] = ZRTools_HookWeapon_Drop(client, WeaponAlphaDrop);
	#endif
}

/**
 * Client is leaving the server.
 * 
 * @param client	The client index.
 */
void WeaponAlphaOnClientDisconnect(int client)
{
	// Unhook "Weapon_Drop" callback, and reset variable.
	if (g_iWeaponDropHookID[client] != -1)
	{
		#if defined USE_SDKHOOKS
			SDKUnhook(client, SDKHook_WeaponDrop, WeaponAlphaDrop);
		#else
			ZRTools_UnhookWeapon_Drop(g_iWeaponDropHookID[client]);
		#endif
		
		g_iWeaponDropHookID[client] = -1;
	}
}

/**
 * Client has just picked up a weapon.
 * 
 * @param client	The client index.
 * @param weapon	The weapon index.   
 */
void WeaponAlphaOnItemPickupPost(int client, int weapon)
{
	if (Entity_HasChildren(weapon))
	{
		// Don't apply alpha value if weapon has children. Render mode is
		// recursively applied to child entities that may not have the render
		// mode attribute - and cause errors like this:
		// Native "SetEntProp" reported: Property "m_nRenderMode" not found
		// (entity 666/info_particle_system)
		return;
	}
	
	// Get client's current alpha.
	int alpha = ToolsGetEntityAlpha(client);
	
	// Set new alpha on weapons.
	WeaponAlphaApplyWeaponAlpha(weapon, alpha);
}

/**
 * Callback function for Weapon_Drop.
 * Called when a client drops their weapon.
 * 
 * @param client	The client index.
 * @param weapon	The weapon index.
 */
#if defined USE_SDKHOOKS
public Action WeaponAlphaDrop(int client, int weapon)
#else
public ZRTools_Action WeaponAlphaDrop(int client, int weapon)
#endif
{
	// If weapon isn't a valid entity, then stop.
	if (weapon < MaxClients)
	{
		return;
	}
	
	// Set new alpha on weapons.
	WeaponAlphaApplyWeaponAlpha(weapon, WEAPONALPHA_DEFAULT_VALUE);
}

/**
 * A client's alpha has been changed by the plugin.
 * 
 * @param client	The client index.
 */
void WeaponAlphaOnClientAlphaChanged(int client, int alpha)
{
	// Set new alpha on weapons.
	WeaponAlphaApplyWeaponAlpha(client, alpha);
}

/**
 * Set's the alpha on a client's weapons.
 * 
 * @param entity	If client index is given, alpha will be set on all their weapons.
 *				  If a non-client index is given, alpha will be set on given entity.
 * @param alpha	 The alpha to set the weapons to.
 */
void WeaponAlphaApplyWeaponAlpha(int entity, int alpha)
{
	if (entity > MaxClients)
	{
		if(!HasEntProp(entity, Prop_Send, "m_nRenderMode"))
			return;
			
			
		// Turn rendermode on, on the weapon.
		SetEntityRenderMode(entity, RENDER_TRANSALPHA);
		
		// Set alpha value on the weapon.
		SetEntityRenderColor(entity, _, _, _, alpha);
		
		// Entity alpha has been set, so stop.
		return;
	}
	
	// Get client's list of weapons.
	int weapons[WeaponsSlot];
	WeaponsGetClientWeapons(entity, weapons);
	
	// Loop through array slots and set alpha.
	// x = weapon slot.
	for (int x = 0; x < WEAPONS_SLOTS_MAX; x++)
	{
		// If weapon is invalid, then stop.
		if (weapons[x] == -1)
		{
			continue;
		}
		
		if(!HasEntProp(weapons[x], Prop_Send, "m_nRenderMode"))
			continue;
			
			
		// Turn rendermode on, on the weapon.
		SetEntityRenderMode(weapons[x], RENDER_TRANSALPHA);
		
		// Set alpha value on the weapon.
		SetEntityRenderColor(weapons[x], _, _, _, alpha);
	}
}
