/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  infect.zr.inc
 *  Type:		  Include
 *  Description:   Infect-related natives/forwards.
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
 * Returns true if the player is a zombie, false if not.
 *
 * @param client			The client index.
 *  
 * @return					True if zombie, false if not.
 * @error				   Invalid client index, not connected or not alive.
 */
native bool ZR_IsClientZombie(int client);

/**
 * Returns true if the player is a human, false if not.
 *
 * @param client			The client index.
 *  
 * @return					True if human, false if not.
 * @error				   Invalid client index, not connected or not alive.
 */
native bool ZR_IsClientHuman(int client);

/**
 * Infects a player.
 *
 * Note: If the player already is a zombie, the player will be re-infected.
 *
 * @param client			The client to infect.
 * @param attacker		  (Optional) The attacker who did the infect.
 * @param motherInfect	  (Optional) Infect as a mother zombie.
 * @param respawnOverride   (Optional) Set to true to override respawn cvar.
 * @param respawn		   (Optional) Value to override with.
 *
 * @error				   Invalid client index, not connected or not alive.
 */
native ZR_InfectClient(int client, int attacker = -1, bool motherInfect = false, bool respawnOverride = false, bool respawn = false);

/**
 * Turns a zombie back into a human.
 *
 * Note: If the player already is a human, this code will still run as the
 *	   player was a zombie.
 *
 * @param client			The client to make human.
 * @param respawn		   Teleport client back to spawn.
 * @param protect		   Start spawn protection on client.
 *
 * @error				   Invalid client index, not connected or not alive.
 */
native ZR_HumanClient(int client, bool respawn = false, bool protect = false);

/**
 * Called when a player is about to become a zombie.
 * Here you can modify any variable or block the infection entirely.
 * 
 * @param client			The client index.
 * @param attacker		  The the infecter. (-1 if there is no infecter)
 * @param motherInfect	  If the client is becoming a mother zombie.
 * @param respawnOverride   True if the respawn cvar is being overridden.
 * @param respawn		   The value that respawn is being overridden with.
 * 
 * @return				  Plugin_Handled to block infection. Anything else
 *						  (like Plugin_Continue) to allow infection.
 */
forward Action ZR_OnClientInfect(int &client, int &attacker, bool &motherInfect, bool &respawnOverride, bool &respawn);

/**
 * Called after a player has become a zombie.
 * 
 * @param client			The client that was infected.
 * @param attacker		  The the infecter. (-1 if there is no infecter)
 * @param motherInfect	  If the client is a mother zombie.
 * @param respawnOverride   True if the respawn cvar was overridden.
 * @param respawn		   The value that respawn was overridden with.
 */
forward ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn);

/**
 * Called when a player is about to become a human. (Through an admin command).
 * Here you can modify any variable or block the action entirely.
 * 
 * @param client			The client index.
 * @param respawn		   True if the client was respawned, false if not.
 * @param protect		   True if the client spawn protected, false if not.
 * 
 * @return				  Plugin_Handled to block infection. Anything else
 *						  (like Plugin_Continue) to allow acion.
 */
forward Action ZR_OnClientHuman(int &client, bool &respawn, bool &protect);

/**
 * Called after a player has become a human. (Through an admin command.)
 * 
 * @param client			The client index.
 * @param respawn		   Whether the client was respawned.
 * @param protect		   Whether the client has spawn protection.
 */
forward ZR_OnClientHumanPost(int client, bool respawn, bool protect);
