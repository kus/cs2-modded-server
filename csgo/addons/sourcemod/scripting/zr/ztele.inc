/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  ztele.inc
 *  Type:		  Module
 *  Description:   ZTele handle functions.
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
 * Array to store client's spawn location.
 */
float g_vecZTeleSpawn[MAXPLAYERS + 1][3];

/**
 * Array to store client's current location.
 */
float g_vecZTeleOrigin[MAXPLAYERS + 1][3];

/**
 * Array to store the tele count of each client.
 */
int g_iZTeleCount[MAXPLAYERS + 1];

/**
 * Array for storing ZTele timer handles per client.
 */
Handle tZTele[MAXPLAYERS + 1];

/**
 * Array to store time left before teleport.
 */
int g_iZTeleTimeLeft[MAXPLAYERS + 1];

/**
 * Create commands specific to ZTele.
 */
void ZTeleOnCommandsCreate()
{
	// Register ZTele command.
	RegConsoleCmd(SAYHOOKS_KEYWORD_ZTELE, ZTeleCommand, "Teleport back to spawn if you are stuck.");
	
	// Register admin command to force ZTele.
	RegConsoleCmd("zr_ztele_force", ZTeleForceCommand, "Force ZTele on a client. Usage: zr_ztele_force <client>");
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void ZTeleClientInit(int client)
{
	// Reset timer handle.
	tZTele[client] = INVALID_HANDLE;
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void ZTeleOnClientSpawn(int client)
{
	// Reset tele count.
	g_iZTeleCount[client] = 0;
	
	// Get spawn location.
	GetClientAbsOrigin(client, g_vecZTeleSpawn[client]);
	
	// If timer is running, kill it.
	if (tZTele[client] != INVALID_HANDLE)
	{
		KillTimer(tZTele[client]);
	}
	
	// Reset timer handle.
	tZTele[client] = INVALID_HANDLE;
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void ZTeleOnClientDeath(int client)
{
	// If timer is running, kill it.
	if (tZTele[client] != INVALID_HANDLE)
	{
		KillTimer(tZTele[client]);
	}
	
	// Reset timer handle.
	tZTele[client] = INVALID_HANDLE;
}

/**
 * Player has been infected.
 * 
 * @param client	The client index.
 */
void ZTeleOnClientInfected(int client)
{
	// If timer is running, kill it.
	if (tZTele[client] != INVALID_HANDLE)
	{
		KillTimer(tZTele[client]);
	}
	
	// Reset timer handle.
	tZTele[client] = INVALID_HANDLE;
}

/**
 * Teleports a client back to spawn if conditions are met.
 * 
 * @param client	The client index.
 * @param force	 (Optional) True to force teleporting of the client, false to follow rules.
 * @param zombie	(Optional) True to teleport instantly, false to use delay.
 * @return		  True if teleport was successful, false otherwise. 
 */
bool ZTeleClient(int client, bool force = false)
{
	// If the client is dead, then stop.
	if (!IsPlayerAlive(client))
	{
		return false;
	}
	
	bool infected = InfectIsClientInfected(client);
	
	// If zombie cvar is disabled and the client is a zombie, then stop.
	bool ztelezombie = GetConVarBool(g_hCvarsList[CVAR_ZTELE_ZOMBIE]);
	if (!force && infected && !ztelezombie)
	{
		// Tell client they must be human to use this feature.
		TranslationPrintToChat(client, "Must be human");
		return false;
	}
	
	// If zombie has spawned, get before value, get the after value otherwise.
	// If the cvar is disabled and the client is a human, then stop.
	bool ztelehuman = g_bZombieSpawned ? GetConVarBool(g_hCvarsList[CVAR_ZTELE_HUMAN_AFTER]) : GetConVarBool(g_hCvarsList[CVAR_ZTELE_HUMAN_BEFORE]);
	if (!force && !infected && !ztelehuman)
	{
		// Tell client that feature is restricted at this time.
		TranslationPrintToChat(client, "ZTele restricted human");
		return false;
	}
	
	// If the tele limit has been reached, then stop.
	int ztelemax = infected ? GetConVarInt(g_hCvarsList[CVAR_ZTELE_MAX_ZOMBIE]) : GetConVarInt(g_hCvarsList[CVAR_ZTELE_MAX_HUMAN]);
	if (!force && g_iZTeleCount[client] >= ztelemax)
	{
		// Tell client that they have already reached their limit.
		TranslationPrintToChat(client, "ZTele max", ztelemax);
		return false;
	}
	
	// If teleport is already in progress, then stop.
	if (tZTele[client] != INVALID_HANDLE)
	{
		if (!force)
		{
			TranslationPrintToChat(client, "ZTele in progress");
		}
		
		return false;
	}
	
	// If we are forcing, then teleport now and stop.
	if (force)
	{
		// Teleport client to spawn.
		ZTeleTeleportClient(client);
		
		return true;
	}
	
	// Get current location.
	GetClientAbsOrigin(client, g_vecZTeleOrigin[client]);
	
	// Set timeleft array to value of respective cvar.
	g_iZTeleTimeLeft[client] = infected ? GetConVarInt(g_hCvarsList[CVAR_ZTELE_DELAY_ZOMBIE]) : GetConVarInt(g_hCvarsList[CVAR_ZTELE_DELAY_HUMAN]);
	if (g_iZTeleTimeLeft[client] > 0)
	{
		// Tell client how much time is left until teleport.
		TranslationPrintCenterText(client, "ZTele countdown", g_iZTeleTimeLeft[client]);
		
		// Start timer.
		tZTele[client] = CreateTimer(1.0, ZTeleTimer, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	else
	{
		// Teleport client to spawn.
		ZTeleTeleportClient(client);
		
		// Increment teleport count.
		g_iZTeleCount[client]++;
		
		// If we're forcing the ZTele, then don't increment the count or print how many teleports they have used.
		// Tell client they've been teleported.
		TranslationPrintCenterText(client, "ZTele countdown end", g_iZTeleCount[client], ztelemax);
	}
	
	return true;
}

/**
 * Teleport client to their spawn location.
 * 
 * @param client	The client index.
 */
void ZTeleTeleportClient(int client)
{
	// Teleport client.
	TeleportEntity(client, g_vecZTeleSpawn[client], NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
}

/**
 * Menu callback (ztele_force)
 * Forces ZTele on a client.
 * 
 * @param menu	  The menu handle.
 * @param action	Action client is doing in menu.
 * @param client	The client index.
 * @param slot	  The menu slot selected. (starting from 0)
 */
public int ZTeleForceHandle(Handle menu_ztele_force, MenuAction action, int client, int slot)
{
	// Client selected an option.
	if (action == MenuAction_Select)
	{
		// Get the client index of the selected client.
		int target = MenuGetClientIndex(menu_ztele_force, slot);
		
		// If the target is 0, then the client left before being selected from the menu.
		if (target == 0)
		{
			// Re-send the menu.
			MenuClientList(client, ZTeleForceHandle, true, true, false, "ZTele clients title");
			
			return;
		}
		
		// Get the target's name for future use.
		char targetname[MAX_NAME_LENGTH];
		GetClientName(target, targetname, sizeof(targetname));
		
		// Force ZSpawn on the target.
		bool success = ZTeleClient(target, true);
		
		// Tell admin the outcome of the action.
		if (success)
		{
			TranslationReplyToCommand(client, "ZTele command force successful", targetname);
		}
		else
		{
			TranslationReplyToCommand(client, "ZTele command force unsuccessful", targetname);
		}
		
		// Re-send the menu.
		MenuClientList(client, ZTeleForceHandle, true, true, false, "ZTele clients title");
	}
	// Client closed the menu.
	if (action == MenuAction_Cancel)
	{
		// Client hit "Back" button.
		if (slot == MenuCancel_ExitBack)
		{
			// Re-open admin menu.
			ZAdminMenu(client);
		}
	}
	// Client exited menu.
	if (action == MenuAction_End)
	{
		CloseHandle(menu_ztele_force);
	}
}

/**
 * Command callback (zr_ztele_force)
 * Force ZSpawn on a client.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZTeleForceCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Generic))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// If not enough arguments given, then stop.
	if (argc < 1)
	{
		TranslationReplyToCommand(client, "ZTele command force syntax");
		return Plugin_Handled;
	}
	
	char target[MAX_NAME_LENGTH], targetname[MAX_NAME_LENGTH];
	int targets[MAXPLAYERS];
	bool tn_is_ml;
	int result;
	
	// Get targetname.
	GetCmdArg(1, target, sizeof(target));
	
	// Find a target.
	result = ProcessTargetString(target, client, targets, sizeof(targets), COMMAND_FILTER_ALIVE, targetname, sizeof(targetname), tn_is_ml);
		
	// Check if there was a problem finding a client.
	if (result <= 0)
	{
		ZRReplyToTargetError(client, result);
		return Plugin_Handled;
	}
	
	// x = Client index.
	for (int x = 0; x < result; x++)
	{
		// Give client the item.
		bool success = ZTeleClient(targets[x], true);
		
		// Tell admin the outcome of the command if only 1 client was targetted.
		if (result == 1)
		{
			if (success)
			{
				TranslationReplyToCommand(client, "ZTele command force successful", targetname);
			}
			else
			{
				TranslationReplyToCommand(client, "ZTele command force unsuccessful", targetname);
			}
		}
		
		// Log action to game events.
		LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_ZTele, "Force ZTele", "\"%L\" teleported \"%L\" to spawn.", client, targets[x]);
	}
	
	return Plugin_Handled;
}

/**
 * Command callback (ztele)
 * Teleport back to spawn if you are stuck.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZTeleCommand(int client, int argc)
{
	// If client is console, then stop and tell them this feature is for players only.
	if (ZRIsConsole(client))
	{
		TranslationPrintToServer("Must be player");
		return Plugin_Handled;
	}
	
	// Start teleportation process.
	ZTeleClient(client);
	
	// This stops the "Unknown command" message in client's console.
	return Plugin_Handled;
}

/**
 * Timer callback, counts down teleport to the client.
 * 
 * @param timer	 The timer handle.
 * @param client	The client index.
 */
public Action ZTeleTimer(Handle timer, any client)
{
	// If client leaves, then stop timer.
	if (!IsClientInGame(client))
	{
		return Plugin_Stop;
	}
	
	bool zteleautocancel = GetConVarBool(g_hCvarsList[CVAR_ZTELE_AUTOCANCEL]);
	if (zteleautocancel)
	{
		// If client has been running around after using ZTele, then stop timer.
		float vecClient[3];
		GetClientAbsOrigin(client, vecClient);
		
		float distance = GetVectorDistance(vecClient, g_vecZTeleOrigin[client]);
		float autocanceldistance = GetConVarFloat(g_hCvarsList[CVAR_ZTELE_AUTOCANCEL_DISTANCE]);
		
		// Convert cvar units
		float unitdistance = ZRConvertUnitsFloat(autocanceldistance, CONVERSION_FEET_TO_UNITS);
		
		// Check if distance has been surpassed.
		if (distance > unitdistance)
		{
			// Reset timer handle.
			tZTele[client] = INVALID_HANDLE;
			
			// Tell client teleport has been cancelled.
			TranslationPrintCenterText(client, "ZTele autocancel centertext");
			TranslationPrintToChat(client, "ZTele autocancel text", RoundToNearest(autocanceldistance));
			
			// Stop timer.
			return Plugin_Stop;
		}
	}
	
	// Decrement time left.
	g_iZTeleTimeLeft[client]--;
	
	// Tell client how much time is left until teleport.
	TranslationPrintCenterText(client, "ZTele countdown", g_iZTeleTimeLeft[client]);
	
	// Time has expired.
	if (g_iZTeleTimeLeft[client] <= 0)
	{
		// Teleport client.
		TeleportEntity(client, g_vecZTeleSpawn[client], NULL_VECTOR, NULL_VECTOR);
		
		// Increment teleport count.
		g_iZTeleCount[client]++;
		
		// Get max teleports per round.
		int ztelemax = InfectIsClientInfected(client) ? GetConVarInt(g_hCvarsList[CVAR_ZTELE_MAX_ZOMBIE]) : GetConVarInt(g_hCvarsList[CVAR_ZTELE_MAX_HUMAN]);
		
		// Tell client spawn protection is over.
		TranslationPrintCenterText(client, "ZTele countdown end", g_iZTeleCount[client], ztelemax);
		
		// Clear timer handle.
		tZTele[client] = INVALID_HANDLE;
		
		// Stop timer.
		return Plugin_Stop;
	}
	
	// Allow timer to continue repeating.
	return Plugin_Continue;
}
