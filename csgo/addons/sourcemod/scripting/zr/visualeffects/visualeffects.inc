/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  visualeffects.inc
 *  Type:		  Module
 *  Description:   Visual effects API.
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

#include "zr/visualeffects/visualambience"
#include "zr/visualeffects/ragdoll"

/**
 * The map is ending.
 */
void VEffectsOnMapEnd()
{
	// Forward event to sub-modules.
	VAmbienceOnMapEnd();
}

/**
 * Visual effect loading.
 */
void VEffectsLoad()
{
	// Forward event to sub-modules.
	VAmbienceLoad();
}

/**
 * Plugin has just finished creating/hooking cvars.
 */
void VEffectsOnCvarInit()
{
	// Hook zr_veffects_* cvars.
	VAmbienceCvarsHook();
}

/**
 * Find VEffects-specific offsets here.
 */
void VEffectsOnOffsetsFound()
{
	// Forward event to sub-modules
	RagdollOnOffsetsFound();
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void VEffectsOnClientDeath(int client)
{
	// Forward event to sub-modules.
	RagdollOnClientDeath(client);
}

/**
 * Create an energy splash effect.
 * 
 * @param client		The client index.
 * @param origin		The origin of the effect.
 * @param direction	 The direction of the effect.
 */
void VEffectsCreateEnergySplash(const float origin[3], const float direction[3], bool explosive)
{
	TE_SetupEnergySplash(origin, direction, explosive);
	TE_SendToAll();
}

/**
 * Create an explosion effect with strict flags.
 * 
 * @param origin	The (x, y, z) coordinate of the explosion.
 * @param flags	 The flags to set on the explosion.
 */
void VEffectsCreateExplosion(const float origin[3], int flags)
{
	// Create an explosion entity.
	int explosion = CreateEntityByName("env_explosion");
	
	// If explosion entity isn't valid, then stop.
	if (explosion == -1)
	{
		return;
	}
	
	// Get and modify flags on explosion.
	int spawnflags = GetEntProp(explosion, Prop_Data, "m_spawnflags");
	spawnflags = spawnflags | EXP_NODAMAGE | EXP_NODECAL | flags;
	
	// Set modified flags on entity.
	SetEntProp(explosion, Prop_Data, "m_spawnflags", spawnflags);
	
	// Spawn the entity into the world.
	DispatchSpawn(explosion);
	
	// Set the origin of the explosion.
	DispatchKeyValueVector(explosion, "origin", origin);
	
	// Set fireball material.
	PrecacheModel("materials/sprites/xfireball3.vmt");
	DispatchKeyValue(explosion, "fireballsprite", "materials/sprites/xfireball3.vmt");
	
	// Tell the entity to explode.
	AcceptEntityInput(explosion, "Explode");
	
	// Remove entity from world.
	AcceptEntityInput(explosion, "Kill");
}

/**
 * Shake a client's screen with specific parameters.
 * 
 * @param client		The client index.
 * @param amplitude	 The amplitude (intensity) of the shaking.
 * @param frequency	 The frequency (speed) of the shaking.
 * @param duration	  The duration (time) of the shaking.
 */
void VEffectsShakeClientScreen(int client, float amplitude, float frequency, float duration)
{
	Handle hShake = StartMessageOne("Shake", client);
	
	// Validate.
	if (hShake == INVALID_HANDLE)
	{
		return;
	}
	
	if (GetUserMessageType() == UM_Protobuf)
	{
		PbSetInt(hShake, "command", 0);
		PbSetFloat(hShake, "local_amplitude", amplitude);
		PbSetFloat(hShake, "frequency", frequency);
		PbSetFloat(hShake, "duration", duration);
	}
	else
	{
		BfWriteByte(hShake, 0);
		BfWriteFloat(hShake, amplitude);
		BfWriteFloat(hShake, frequency);
		BfWriteFloat(hShake, duration);
	}
	EndMessage();
}
