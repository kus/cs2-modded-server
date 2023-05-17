/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  ragdoll.inc
 *  Type:		  Module
 *  Description:   Remove ragdolls with optional effects.
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
 * @section Different dissolve types.
 */
#define VEFFECTS_RAGDOLL_DISSOLVE_EFFECTLESS	-2
#define VEFFECTS_RAGDOLL_DISSOLVE_RANDOM		-1
#define VEFFECTS_RAGDOLL_DISSOLVE_ENERGY		0
#define VEFFECTS_RAGDOLL_DISSOLVE_ELECTRICALH   1
#define VEFFECTS_RAGDOLL_DISSOLVE_ELECTRICALL   2
#define VEFFECTS_RAGDOLL_DISSOLVE_CORE		  3
/**
 * @endsection
 */

/**
 * Variable to store ragdoll offset value.
 */
int g_iToolsRagdoll;

/**
 * Find VAmbience-specific offsets here.
 */
void RagdollOnOffsetsFound()
{
	// If offset "m_iAccount" can't be found, then stop the plugin.
	g_iToolsRagdoll = FindSendPropInfo("CCSPlayer", "m_hRagdoll");
	if (g_iToolsRagdoll == -1)
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_VEffects, "Offsets", "Offset \"CCSPlayer::m_hRagdoll\" was not found.");
	}
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void RagdollOnClientDeath(int client)
{
	// If ragdoll removal is disabled, then stop.
	bool ragdollremove = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_REMOVE]);
	if (!ragdollremove)
	{
		return;
	}
	
	int ragdoll = RagdollGetClientRagdoll(client);
	
	// If the ragdoll is invalid, then stop.
	if (ragdoll == -1)
	{
		return;
	}
	
	// Get the delay.
	float dissolvedelay = GetConVarFloat(g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_DELAY]);
	
	// If the delay is 0 or less, then remove right now.
	if (dissolvedelay <= 0)
	{
		RagdollTimer(INVALID_HANDLE, ragdoll);
		return;
	}
	
	// Create a timer to remove/dissolve ragdoll.
	CreateTimer(dissolvedelay, RagdollTimer, ragdoll, TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * Removed a ragdoll from the game following plugin settings.
 * 
 * @param ragdoll   The ragdoll index.
 */
void RagdollRemove(int ragdoll)
{
	// Get the dissolve type.
	int dissolve = GetConVarInt(g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_DISSOLVE]);
	
	if (dissolve == VEFFECTS_RAGDOLL_DISSOLVE_EFFECTLESS)
	{
		// Remove entity from world.
		AcceptEntityInput(ragdoll, "Kill");
		return;
	}
	
	// If random, set value to any between "energy" effect and "core" effect.
	if (dissolve == VEFFECTS_RAGDOLL_DISSOLVE_RANDOM)
	{
		dissolve = GetRandomInt(VEFFECTS_RAGDOLL_DISSOLVE_ENERGY, VEFFECTS_RAGDOLL_DISSOLVE_CORE);
	}
	
	// Prep the ragdoll for dissolving.
	char targetname[64];
	Format(targetname, sizeof(targetname), "zr_dissolve_%d", ragdoll);
	DispatchKeyValue(ragdoll, "targetname", targetname);
	
	// Prep the dissolve entity.
	int dissolver = CreateEntityByName("env_entity_dissolver");
	
	// Set the target to the ragdoll.
	DispatchKeyValue(dissolver, "target", targetname);
	
	// Set the dissolve type.
	char dissolvetype[16];
	Format(dissolvetype, sizeof(dissolvetype), "%d", dissolve);
	DispatchKeyValue(dissolver, "dissolvetype", dissolvetype);
	
	// Tell the entity to dissolve the ragdoll.
	AcceptEntityInput(dissolver, "Dissolve");
	
	// Remove the dissolver.
	AcceptEntityInput(dissolver, "Kill");
}

/**
 * Timer callback.  Removed a client's ragdoll.
 * 
 * @param timer	 The timer handle. 
 * @param ragdoll   The ragdoll index.
 */
public Action RagdollTimer(Handle timer, any ragdoll)
{
	// If ragdoll removal is disabled, then stop.
	bool ragdollremove = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_REMOVE]);
	if (!ragdollremove)
	{
		return;
	}
	
	// If the ragdoll is already gone, then stop.
	if (!IsValidEdict(ragdoll))
	{
		return;
	}
	
	// Make sure this edict is still a ragdoll and not become a new valid entity.
	char classname[64];
	GetEdictClassname(ragdoll, classname, sizeof(classname));
	if (!StrEqual(classname, "cs_ragdoll"))
	{
		return;
	}
	
	// Remove the ragdoll.
	RagdollRemove(ragdoll);
}

/** Finds the ragdoll entity of a client.
 * @param client	The client index.
 * @return		  The entity index of the client's ragdoll, -1 if none exists.
 */
int RagdollGetClientRagdoll(int client)
{
	return GetEntDataEnt2(client, g_iToolsRagdoll);
}

/**
 * Removes the ragdoll entity of a client.
 * @param client	The client index.
 */
void RagdollResetClientRagdoll(int client)
{
	SetEntDataEnt2(client, g_iToolsRagdoll, -1);
}
