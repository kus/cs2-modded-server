/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  respawn.zr.inc
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
 * Conditions for respawning players.
 */
enum ZR_RespawnCondition
{
	ZR_Repsawn_Default = -1,	/** Let ZR decide according to its settings. */
	ZR_Respawn_Human = 0,	   /** Respawn as a human. */
	ZR_Respawn_Zombie,		  /** Respawn as a zombie. */
	ZR_Respawn_ZombieIfSuicide  /** Respawn as a zombie if killed by world damage. */
}

/**
 * Spawns a player into the round.
 * 
 * @param client			The client index.
 * @param condition		 Optional. Set respawn condition, defaults to current
 *						  ZR settings. See ZR_RespawnCondition for details.
 * @error				   Invalid client index, not connected or already alive.
 */
native ZR_RespawnClient(int client, ZR_RespawnCondition condition = ZR_Repsawn_Default);

/**
 * Called right before ZR is about to respawn a player.
 * Here you can modify any variable or stop the action entirely.
 * 
 * @param client			The client index.
 * @param condition		 Respawn condition. See ZR_RespawnCondition for
 *						  details.
 *
 * @return	  Plugin_Handled to block respawn.
 */
forward Action ZR_OnClientRespawn(int &client, ZR_RespawnCondition &condition);

/**
 * Called after ZR respawned a player.
 * 
 * @param client			The client index.
 * @param condition		 Current condition of the respawned player. See
 *						  ZR_RespawnCondition for details.
 */
forward ZR_OnClientRespawned(int client, ZR_RespawnCondition condition);

/**
 * Set if a player died by a suicide or world damage.
 
 * Note: This will change the respawn condition.
 * Note: This value is reset to default by ZR when a zombie player dies.
 * 
 * @param client	The client index.
 * @param suicide   True to say the player suicided, false if killed by another
 *				  player.
 *
 * @error		   Invalid client index or not connected.
 */
native ZR_SetKilledByWorld(int client, bool suicide);

/**
 * Get whether the player died by a suicide or world damage.
 *
 * Note: This value is only valid after death event, and before respawn.
 * 
 * @param client	The client index.
 * 
 * @return		  True if the player died by suicide, false if killed by
 *				  another player.
 * @error		   Invalid client index or not connected.
 */
native bool ZR_GetKilledByWorld(int client);
