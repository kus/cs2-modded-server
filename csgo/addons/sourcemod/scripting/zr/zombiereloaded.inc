/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zombiereloaded.inc
 *  Type:		  Core 
 *  Description:   General plugin functions and defines.
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
 * Index of server console.
 */
#define ZR_CONSOLE_INDEX 0

/**
 * @section Conversion factors.
 */
#define CONVERSION_UNITS_TO_FEET	16.000
#define CONVERSION_FEET_TO_UNITS	0.0625
/**
 * @endsection
 */

/**
 * Options that a condition must pass to be eligible.
 */
enum EligibleCondition
{
	Condition_False = 0,	/** Condition must be false. */
	Condition_True = 1,	 /** Condition must be true. */
	Condition_Either = -1   /** Condition can be either true or false. */
}

/**
 * Global variable set to true when the first zombie(s) is/are spawned.
 */
bool g_bZombieSpawned;

/**
 * Supported games.
 */
enum Game
{
	Game_Unknown = -1,
	Game_CSS,
	Game_CSGO
}

/**
 * Current game.
 */
Game g_Game = Game_Unknown;
#pragma unused g_Game

/**
 * Updates g_game. Will log a warning if a unsupported game is detected.
 */
void UpdateGameFolder()
{
	char gameFolder[PLATFORM_MAX_PATH];
	GetGameFolderName(gameFolder, sizeof(gameFolder));
	
	if (StrEqual(gameFolder, "cstrike", false))
	{
		g_Game = Game_CSS;
		PrintToServer("Game detected: cstrike");
		return;
	}
	else if (StrEqual(gameFolder, "csgo", false))
	{
		g_Game = Game_CSGO;
		PrintToServer("Game detected: csgo");
		return;
	}
	
	LogError("Warning: Zombie:Reloaded doesn't support this game: %s", gameFolder);
	g_Game = Game_Unknown;
}

/**
 * Function to convert numbers to defined units.
 * 
 * @param number		The number to convert.
 * @param conversion	The conversion factor to multiply by. (See defines above)
 * @return			  The converted number.
 */
float ZRConvertUnitsFloat(float number, float conversion)
{
	return number / conversion;
}

/**
 * Create an array populated with eligible clients to be zombie.
 * 
 * @param arrayEligibleClients  The handle of the array, don't forget to call CloseHandle
 *							  on it when finished!
 * @param team				  Client is only eligible if on a team.
 * @param alive				 Client is only eligible if alive.
 * @param human				 Client is only eligible if human.
 * @param immunity			  True to ignore clients immune from mother infect, false to count them.
 */  
stock int ZRCreateEligibleClientList(Handle &arrayEligibleClients, bool team = false, bool alive = false, bool human = false)
{
	// Create array.
	arrayEligibleClients = CreateArray();
	
	// Populate list with eligible clients.
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If client isn't on a team, then stop.
		if (team && !ZRIsClientOnTeam(x))
		{
			continue;
		}
		
		// If client is dead, then stop.
		if (alive && !IsPlayerAlive(x))
		{
			continue;
		}
		
		// If client is already zombie (via admin), then stop.
		if (human && !InfectIsClientHuman(x))
		{
			continue;
		}
		
		// Add eligible client to array.
		PushArrayCell(arrayEligibleClients, x);
	}
	
	return GetArraySize(arrayEligibleClients);
}

/**
 * Checks if a timer is currently running.
 * 
 * @param timer	 The timer handle.
 */
stock bool ZRIsTimerRunning(Handle timer)
{
	// Return true if the handle isn't empty.
	return (timer != INVALID_HANDLE);
}

/**
 * Wrapper functions for KilLTimer.
 * Ends a timer if running, and resets its timer handle variable.
 * 
 * @param timer	 The timer handle.
 * @param kill	  True to kill the timer and reset the variable, false to only reset the variable.
 *				  Using false is useful when calling from the timer callback, because the timer is already killed.
 * 
 * @return		  True if the handle wasn't INVALID_HANDLE, false if the handle wasn't valid.
 */
stock bool ZREndTimer(Handle &timer, bool kill = true)
{
	// If the timer is running, then kill it.
	if (ZRIsTimerRunning(timer))
	{
		// Kill if caller says to.
		if (kill)
		{
			KillTimer(timer);
		}
		
		// Reset variable.
		timer = INVALID_HANDLE;
		
		return true;
	}
	
	// Reset variable.
	timer = INVALID_HANDLE;
	
	return false;
}

/**
 * Check if a client index is a valid player.
 * 
 * @param client	The client index.
 * @param console   True to include console (index 0), false if not.
 * @return		  True if client is valid, false otherwise. 
 */	
stock bool ZRIsClientValid(int client, bool console = false)
{
	// If index is greater than max number of clients, then return false.
	if (client > MaxClients)
	{
		return false;
	}
	
	// If console is true, return if client is >= 0, if not, then return client > 0.
	return console ? (client >= 0) : (client > 0);
}

/**
 * Check if a given index is console.
 * 
 * @param client	The client index.
 * @param console   True to include console (index 0), false if not.
 * @return		  True if client is valid, false otherwise. 
 */	
stock bool ZRIsConsole(int index)
{
	// Return true if index is equal to console's index.
	return (index == ZR_CONSOLE_INDEX);
}

/**
 * Count clients on each team.
 * 
 * @param zombies   This is set to the number of clients that are zombies.
 * @param humans	This is set to the number of clients that are humans.
 * @param alive	 If true it will only count live players, false will count alive and dead.
 * @return		  True if successful (zombie has spawned), false otherwise.
 */
stock bool ZRCountValidClients(int &zombiecount = 0, int &humancount = 0, bool alive = true, bool ignorezombiespawned = false)
{
	// If zombie hasn't spawned and were not only counting humans, then stop.
	if (!g_bZombieSpawned && !ignorezombiespawned)
	{
		return false;
	}
	
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If client isn't on a team, then stop.
		if (!ZRIsClientOnTeam(x))
		{
			continue;
		}
		
		// If player must be alive, and player is dead, then stop.
		if (alive && !IsPlayerAlive(x))
		{
			continue;
		}
		
		// If player is a zombie, then increment zombie variable.
		if (InfectIsClientInfected(x))
		{
			zombiecount++;
		}
		// If player is a human, then increment human variable.
		else if (InfectIsClientHuman(x))
		{
			humancount++;
		}
	}
	
	return true;
}

/**
 * Check if a client index is on a team.
 * 
 * @param client	The client index.
 * @param team	  Team to check if player is on, -1 to check both. 
 * @return		  True if client is on a team, false otherwise. 
 */	
stock bool ZRIsClientOnTeam(int client, int team = -1)
{
	// If index is invalid, then stop.
	if (!ZRIsClientValid(client))
	{
		return false;
	}
	
	// Get client team.
	int clientteam = GetClientTeam(client);
	
	if (team == -1)
	{
		return (clientteam == CS_TEAM_T || clientteam == CS_TEAM_CT);
	}
	
	return (clientteam == team);
}

/**
 * Check if there are clients on a team.
 * 
 * @param team	  (Optional) Team to check if there are clients on.
 */
stock bool ZRTeamHasClients(int team = -1)
{
	// If team is
	if (team == -1)
	{
		// Return true if both teams have at least 1 client.
		return (GetTeamClientCount(CS_TEAM_T) && GetTeamClientCount(CS_TEAM_CT));
	}
	
	// Return true if given team has at least 1 client.
	return view_as<bool>(GetTeamClientCount(team));
}

/**
 * Returns whether a player is a admin or not.
 *
 * @param client	The client index.
 * @param flag	  Optional. Flag to check. Default is generic admin flag.
 * @return		  True if generic admin, false otherwise.
 */
stock bool ZRIsClientAdmin(int client, AdminFlag flag = Admin_Generic)
{
	// If index is invalid, then stop.
	if (!ZRIsClientValid(client))
	{
		return false;
	}
	
	// If client doesn't have the specified flag, then stop.
	if (!GetAdminFlag(GetUserAdmin(client), flag))
	{
		return false;
	}
	
	// Client is an admin.
	return true;
}

/**
 * Replies to a client with a given message describing a targetting 
 * failure reason. (formatted for ZR)
 *
 * Note: The translation phrases are found in common.phrases.txt.
 *
 * @param client		Client index, or 0 for server.
 * @param reason		COMMAND_TARGET reason.
 */
stock void ZRReplyToTargetError(int client, int reason)
{
	switch (reason)
	{
		case COMMAND_TARGET_NONE:
		{
			TranslationReplyToCommand(client, "No matching client");
		}
		case COMMAND_TARGET_NOT_ALIVE:
		{
			TranslationReplyToCommand(client, "Target must be alive");
		}
		case COMMAND_TARGET_NOT_DEAD:
		{
			TranslationReplyToCommand(client, "Target must be dead");
		}
		case COMMAND_TARGET_NOT_IN_GAME:
		{
			TranslationReplyToCommand(client, "Target is not in game");
		}
		case COMMAND_TARGET_IMMUNE:
		{
			TranslationReplyToCommand(client, "Unable to target");
		}
		case COMMAND_TARGET_EMPTY_FILTER:
		{
			TranslationReplyToCommand(client, "No matching clients");
		}
		case COMMAND_TARGET_NOT_HUMAN:
		{
			TranslationReplyToCommand(client, "Cannot target bot");
		}
		case COMMAND_TARGET_AMBIGUOUS:
		{
			TranslationReplyToCommand(client, "More than one client matched");
		}
	}
}

/**
 * Adds support for printing strings longer than 1 KB to console. Max 4 KB.
 *
 * Note: 1024 characters is max for the console, including newline and null
 *	   terminator.
 *
 * @param client		The client index.
 * @param text		  Long text to write.
 * @param splitsize	 Optional. Sets the split size. 1022 is default.
 *					  Allowed range: 128 to 1022.
 */
stock int ZRPrintToConsoleLong(int client, const char[] text, int splitsize = 1022)
{
	// Validate split size.
	if (splitsize < 128 || splitsize > 1022)
	{
		return;
	}
	
	char partbuffer[splitsize];
	int pos;
	int cellswritten = 1;		   // Initialize for the loop.

	while (cellswritten)
	{
		cellswritten = strcopy(partbuffer, splitsize, text[pos]);
		(client > 0) ? PrintToConsole(client, partbuffer) : PrintToServer(partbuffer);
		pos += cellswritten;
	}
}

/**
 * Converts a boolean value into a string.
 * 
 * @param value	 The value to convert to string.
 * @param output	The converted string.
 * @param maxlen	The maximum length of the string.
 */
void ZRBoolToString(bool value, char[] output, int maxlen)
{
	// If the value is true, then set string to "1".
	if (value)
	{
		strcopy(output, maxlen, "1");
	}
	// If the value is false, then set string to "0".
	else
	{
		strcopy(output, maxlen, "0");
	}
}

/**
 * (from SMLIB 0.10.2)
 * 
 * Returns a random, uniform Integer number in the specified (inclusive) range.
 * This is safe to use multiple times in a function.
 * The seed is set automatically for each plugin.
 * Rewritten by MatthiasVance, thanks.
 * 
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Random Integer number between min and max
 */
#define SIZE_OF_INT		2147483647		// without 0
stock int Math_GetRandomInt(int min, int max)
{
	int random = GetURandomInt();
	
	if (random == 0) {
		random++;
	}

	return RoundToCeil(float(random) / (float(SIZE_OF_INT) / float(max - min + 1))) + min - 1;
}

/**
 * (from SMLIB)
 * Gets the parent entity of an entity.
 * 
 * @param entity		Entity Index.
 * @return				Entity Index of the parent.
 */
stock int Entity_GetParent(int entity)
{
	return GetEntPropEnt(entity, Prop_Data, "m_pParent");
}

/**
 * Returns whether an entity is referred to as the parent entity.
 *
 * @praram entity	   Entity index.
 *
 * @return			  True if entity has children, false otherwise.
 */
stock bool Entity_HasChildren(int entity)
{
	int maxEntities = GetMaxEntities();
	
	// Loop through all entity indexes, after players.
	for (int loopEntity = MAXPLAYERS + 1; loopEntity < maxEntities; loopEntity++)
	{
		if (!IsValidEntity(loopEntity))
		{
			continue;
		}
		
		int parentEntity = Entity_GetParent(loopEntity);
		if (parentEntity == entity)
		{
			return true;
		}
	}
	
	return false;
}
