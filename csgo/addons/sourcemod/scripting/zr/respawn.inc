/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  respawn.inc
 *  Type:		  Module 
 *  Description:   Players come back to life
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
 * Conditions for respawning players.
 */
enum RespawnCondition
{
	Repsawn_Default = -1,	   /** Let ZR decide according to its settings. */
	Respawn_Human = 0,		  /** Respawn as a human. */
	Respawn_Zombie,			 /** Respawn as a zombie. */
	Respawn_ZombieIfSuicide	 /** Respawn as a zombie if killed by world damage. */
}

/**
 * Array for storing respawn timer handles per client.
 */
Handle tRespawn[MAXPLAYERS + 1];

/**
 * Array for flagging zombies who were killed by world.
 */ 
bool bKilledByWorld[MAXPLAYERS + 1];

/**
 * Client is joining the server.
 */ 
void RespawnClientInit(int client)
{
	// Reset timer handle.
	tRespawn[client] = INVALID_HANDLE;
	
	// Init bKilledByWorld for client.
	bKilledByWorld[client] = false;
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void RespawnOnClientSpawn(int client)
{
	// If timer is running, kill it.
	if (tRespawn[client] != INVALID_HANDLE)
	{
		KillTimer(tRespawn[client]);
	}
	
	// Reset timer handle.
	tRespawn[client] = INVALID_HANDLE;
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void RespawnOnClientDeath(int client, int attacker, const char[] weapon)
{
	// If client is a zombie, check if they were killed by world.
	if (InfectIsClientInfected(client))
	{
		// Set bKilledByWorld to true if attacker is not a valid client.
		bKilledByWorld[client] = !ZRIsClientValid(attacker);
	}
	
	// If timer is running, kill it.
	if (tRespawn[client] != INVALID_HANDLE)
	{
		KillTimer(tRespawn[client]);
	}
	
	// If player was infected, then stop.
	if (g_Game == Game_CSGO)
	{
		if(StrEqual(weapon, "zombie_walking_csgo", false)) return;
	}
	if (StrEqual(weapon, "zombie_claws_of_death", false)) return;
	
	// If respawn is disabled, stop here.
	bool respawn = GetConVarBool(g_hCvarsList[CVAR_RESPAWN]);
	if (!respawn)
	{
		return;
	}
	
	// Start respawn timer.
	float delay = GetConVarFloat(g_hCvarsList[CVAR_RESPAWN_DELAY]);
	tRespawn[client] = CreateTimer(delay, RespawnTimer, client, TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * The round is ending.
 */
void RespawnOnRoundEnd()
{
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If timer isn't currently running, then stop.
		if (tRespawn[x] == INVALID_HANDLE)
		{
			continue;
		}
		
		// Stop timer.
		KillTimer(tRespawn[x]);
		
		// Reset timer handle.
		tRespawn[x] = INVALID_HANDLE;
	}
}

/**
 * Spawns a player into the round.
 * 
 * @param client			The client index.
 * @param zombie			Respawn as zombie.
 * @param zombieIfSuicide   Respawn as zombie if killed by world damage.
 *
 * @return	  True if the player was spawned, false otherwise.
 */
bool RespawnSpawnClient(int client, bool zombie = false, bool zombieIfSuicide = false)
{
	// If client isn't in-game, then stop.
	if (!IsClientInGame(client))
	{
		return false;
	}
	
	// Get respawn condition.
	RespawnCondition condition = RespawnToContition(zombie, zombieIfSuicide);
	
	// Trigger API forward.
	Action result = APIOnClientRespawn(client, condition);
	
	// Check if respawn should be stopped.
	if (result == Plugin_Handled)
	{
		return false;
	}
	
	// Restore respawn condition.
	RespawnRestoreCondition(condition, zombie, zombieIfSuicide);
	
	bool ragdollremove = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_REMOVE]);
	if (!ragdollremove)
	{
		// Detatch ragdoll so it's not removed on respawn.
		RagdollResetClientRagdoll(client);
	}
	
	// Spawn player.
	CS_RespawnPlayer(client);
	
	// Check if first zombie has spawned.
	if (g_bZombieSpawned)
	{
		// Infect if player should spawn as zombie.
		if (zombie)
		{
			InfectHumanToZombie(client);
		}
		// Infect if player committed suicide by world damage.
		else if (zombieIfSuicide && bKilledByWorld[client])
		{
			InfectHumanToZombie(client);
			bKilledByWorld[client] = false;
		}
	}
	
	// Forward event to modules.
	APIOnClientRespawned(client, condition);
	
	return true;
}

/**
 * Timer callback, respawns a player.
 * 
 * @param timer	 The timer handle.
 * @param client	The client index.
 */	
public Action RespawnTimer(Handle timer, any client)
{
	// Reset timer handle.
	tRespawn[client] = INVALID_HANDLE;
	
	// If client isn't in-game, then stop.
	if (!IsClientInGame(client))
	{
		return;
	}
	
	// If player already is alive, then stop.
	if (IsPlayerAlive(client))
	{
		return;
	}
	
	// Get client team.
	int team = GetClientTeam(client);
	
	// If player isn't on a team, then stop.
	if (team != CS_TEAM_T && team != CS_TEAM_CT)
	{
		return;
	}
	
	// Get whether player should respawn as zombie.
	bool zombie = GetConVarBool(g_hCvarsList[CVAR_RESPAWN_TEAM_ZOMBIE]);
	
	// Get whether zombies died by suicide should respawn as zombies.
	bool zombieIfSuicide = GetConVarBool(g_hCvarsList[CVAR_RESPAWN_TEAM_ZOMBIE_WORLD]);
	
	// Spawn player.
	RespawnSpawnClient(client, zombie, zombieIfSuicide);
}

/**
 * Converts separate conditions into a single condition value.
 */
RespawnCondition RespawnToContition(bool zombie, bool zombieIfSuicide)
{
	if (zombie)
	{
		return Respawn_Zombie;
	}
	else if (zombieIfSuicide)
	{
		return Respawn_ZombieIfSuicide;
	}
	
	return Respawn_Human;
}

/**
 * Restores respawn condition to individual variables. If the condition invalid,
 * nothing will be changed.
 *
 * @param condition		 Condition to restore.
 * @param zombie			Output.
 * @param zombieIfSucidie   Output.
 */
void RespawnRestoreCondition(RespawnCondition condition, bool &zombie, bool &zombieIfSuicide)
{
	switch (condition)
	{
		case Respawn_Human:
		{
			zombie = false;
			zombieIfSuicide = false;
		}
		case Respawn_Zombie:
		{
			zombie = true;
			zombieIfSuicide = false;
		}
		case Respawn_ZombieIfSuicide:
		{
			zombie = false;
			zombieIfSuicide = true;
		}
	}
}
