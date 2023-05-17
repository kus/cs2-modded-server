/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  infect.inc
 *  Type:		  Core
 *  Description:   Client infection functions.
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
 * Array for flagging client as zombie.
 */
bool bZombie[MAXPLAYERS + 1];

/**
 * Called after a player has become a zombie.
 * 
 * @param client			The client that was infected.
 * @param attacker		  The the infecter. (-1 if there is no infecter)
 * @param motherInfect	  If the client is a mother zombie.
 * @param respawnOverride   True if the respawn cvar was overridden.
 * @param respawn		   The value that respawn was overridden with.
 */
public int ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	// Mark player as zombie.
	bZombie[client] = true;
	// Emit scream sound if enabled.
	ZombieSoundsScream(client);
	SEffectsOnClientInfected(client);
}

/**
 * Called after a player has become a human. (Through an admin command.)
 * 
 * @param client			The client index.
 * @param respawn		   Whether the client was respawned.
 * @param protect		   Whether the client has spawn protection.
 */
public int ZR_OnClientHumanPost(int client, bool respawn, bool protect)
{
	// Mark player as human.
	bZombie[client] = false;
	// Forward event to modules.
	SEffectsOnClientHuman(client);
}


/**
 * Client is joining a team.
 * 
 * @param client	The client index.
 * @param team	  The team index. 
 */
void InfectOnClientTeam(int client, int team)
{
	// If client isn't joining spec, then stop.
	if (team != CS_TEAM_SPECTATOR)
	{
		return;
	}
	
	// Disable zombie flag on client.
	bZombie[client] = false;
}


/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void InfectOnClientSpawn(int client)
{
	// Disable zombie flag on client.
	bZombie[client] = false;
}

/**
 * The round is ending.
 */
public Action InfectOnRoundEnd()
{
	// x = client index.
	for (int x = 1; x <=  MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// Disable zombie flag on client.
		bZombie[x] = false;
	}
}


/**
 * Returns if a client is infected.
 * 
 * @param client	The client index.
 * @return		  True if the client has been infected, false otherwise.
 */	
bool InfectIsClientInfected(int client)
{
	// If client is invalid, then stop.
	if (!ZRIsClientValid(client))
	{
		return false;
	}
	
	// Return client's zombie flag.
	return bZombie[client];
}
