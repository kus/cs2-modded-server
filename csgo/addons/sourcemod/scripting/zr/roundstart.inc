/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  roundstart.inc
 *  Type:		  Core
 *  Description:   Handles round start actions.
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
 * List of objective entities.
 */
#define ROUNDSTART_OBJECTIVE_ENTITIES "func_bomb_target|func_hostage_rescue|c4|hostage_entity"

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void RoundStartOnClientSpawn(int client)
{
	// If client hasn't spawned yet, then stop.
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	// Print to client, how to access ZMenu.
	TranslationPrintToChat(client, "General zmenu reminder", SAYHOOKS_CHAT_PUBLIC_DEFAULT, SAYHOOKS_KEYWORD_ZMENU);
}

/**
 * The round is starting.
 */
void RoundStartOnRoundStart()
{
	// Print round objective to all clients.
	TranslationPrintToChatAll(true, false, "General round objective");
	
	// Kill all objective entities.
	RoundStartKillObjectives();
}

/**
 * Kills all objective entities.
 */
stock void RoundStartKillObjectives()
{
	char classname[64];
	
	// Get max entity count.
	int maxentities = GetMaxEntities();
	
	// x = entity index.
	for (int x = 0; x <= maxentities; x++)
	{
		// If entity isn't valid, then stop.
		if(!IsValidEdict(x))
		{
			continue;
		}
		
		// Get valid edict's classname.
		GetEdictClassname(x, classname, sizeof(classname));
		
		// Check if it matches any objective entities, then stop if it doesn't.
		if(StrContains(ROUNDSTART_OBJECTIVE_ENTITIES, classname) > -1)
		{
			// Entity is an objective, kill it.
			AcceptEntityInput(x, "Kill");
		}
	}
}
