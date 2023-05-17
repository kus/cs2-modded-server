/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zspawn.inc
 *  Type:		  Module
 *  Description:   Handles zspawn command, spawns late-joining clients into the game.
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
 * Global variable to store infect timer handle.
 */
Handle tZSpawn = INVALID_HANDLE;

/**
 * Global variable to store SteamID cache handle.
 */
Handle g_hZSpawnSteamIDCache = INVALID_HANDLE;

/**
 * Create commands specific to ZSpawn.
 */
void ZSpawnOnCommandsCreate()
{
	// Register ZSpawn command.
	RegConsoleCmd(SAYHOOKS_KEYWORD_ZSPAWN, ZSpawnCommand, "Spawn into the game after joining late.");
	
	// Register admin command to force ZSpawn.
	RegConsoleCmd("zr_zspawn_force", ZSpawnForceCommand, "Force ZSpawn on a client. Usage: zr_zspawn_force <client> ['0' = Spawn as human | '1' = Spawn as zombie]");
}

/**
 * Map is starting.
 */
void ZSpawnOnMapStart()
{
	// Reset timer handle.
	tZSpawn = INVALID_HANDLE;
	
	// If SteamID cache hasn't been created yet, then create.
	if (g_hZSpawnSteamIDCache == INVALID_HANDLE)
	{
		g_hZSpawnSteamIDCache = SteamidCacheCreate();
	}
	
	// Reset the SteamID cache.
	SteamidCacheReset(g_hZSpawnSteamIDCache);
}

/**
 * Client is leaving the server.
 * 
 * @param client	The client index.
 */
void ZSpawnOnClientDisconnect(int client)
{
	// So people who are connecting that click "cancel" aren't added to the list.
	if (!IsClientInGame(client))
	{
		return;
	}
	
	// Check if client is a bot.
	if (IsFakeClient(client))
	{
		return;
	}
	
	// Add client to the SteamID cache.
	SteamidCacheAddClient(g_hZSpawnSteamIDCache, client);
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void ZSpawnOnClientDeath(int client)
{
	// Add client to the SteamID cache.
	SteamidCacheAddClient(g_hZSpawnSteamIDCache, client);
}

/**
 * The round is starting.
 */
void ZSpawnOnRoundStart()
{
	// Reset the SteamID cache.
	SteamidCacheReset(g_hZSpawnSteamIDCache);
	
	// If zspawn timer is running, then kill it.
	if (tZSpawn != INVALID_HANDLE)
	{
		// Kill timer.
		KillTimer(tZSpawn);
		
		// Reset timer handle.
		tZSpawn = INVALID_HANDLE;
	}
}

/**
 * The freeze time is ending.
 */
void ZSpawnOnRoundFreezeEnd()
{
	// If infect timer is running, then kill it.
	if (tZSpawn != INVALID_HANDLE)
	{
		// Kill timer.
		KillTimer(tZSpawn);
	}
	
	// If zspawn is disabled, then stop.
	bool zspawn = GetConVarBool(g_hCvarsList[CVAR_ZSPAWN]);
	if (!zspawn)
	{
		return;
	}
	
	// If timelimit is disabled, then stop.
	bool zspawntimelimit = GetConVarBool(g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT]);
	if (!zspawntimelimit)
	{
		return;
	}
	
	// Get timelimit
	float zspawntime = GetConVarFloat(g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT_TIME]);
	
	// Start timer.
	tZSpawn = CreateTimer(zspawntime, ZSpawnTimer, _, TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * The round is ending.
 */
void ZSpawnOnRoundEnd()
{
	// If zspawn timer is running, then kill it.
	if (tZSpawn != INVALID_HANDLE)
	{
		// Kill timer.
		KillTimer(tZSpawn);
		
		// Reset timer handle.
		tZSpawn = INVALID_HANDLE;
	}
}

/**
 * Spawns a late-joining client into the game.
 * 
 * @param client	The client index.
 * @param force	 (Optional) True to force spawning of the client, false to follow rules.
 * @param zombie	(Optional) If you are forcing spawn, you must override the team here.
 * @return		  True if successful, false otherwise.
 */
bool ZSpawnClient(int client, bool force = false, bool zombie = false)
{
	// If zspawn is disabled, then stop.
	bool zspawn = GetConVarBool(g_hCvarsList[CVAR_ZSPAWN]);
	if (!force && !zspawn)
	{
		TranslationPrintToChat(client, "Feature is disabled");
		return false;
	}
	
	// If client isn't on a team, then stop.
	if (!ZRIsClientOnTeam(client))
	{
		if (!force)
		{
			// Tell client the command may only be used when on a team.
			TranslationPrintToChat(client, "Must be on team");
		}
		
		return false;
	}
	
	// If client is alive, then stop.
	if (IsPlayerAlive(client))
	{
		if (!force)
		{
			// Tell client the command may only be used when dead.
			TranslationPrintToChat(client, "Must be dead");
		}
		
		return false;
	}
	
	// Block if client has already played during this round.
	int blockrejoin = GetConVarBool(g_hCvarsList[CVAR_ZSPAWN_BLOCK_REJOIN]);
	if (!force && SteamidCacheClientExists(g_hZSpawnSteamIDCache, client) && blockrejoin)
	{
		// Tell client the command may only be used when joining late.
		TranslationPrintToChat(client, "ZSpawn double spawn");
		return false;
	}
	
	bool teamzombie;
	
	if (!force)
	{
		// Check if zspawn override is enabled, and if so get overidden value.
		bool teamoverride = GetConVarBool(g_hCvarsList[CVAR_ZSPAWN_TEAM_OVERRIDE]);
		teamzombie = teamoverride ? GetConVarBool(g_hCvarsList[CVAR_ZSPAWN_TEAM_ZOMBIE]) : GetConVarBool(g_hCvarsList[CVAR_RESPAWN_TEAM_ZOMBIE]);
		
		// Block is the time limit is up.
		bool zspawntimelimit = GetConVarBool(g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT]);
		if (zspawntimelimit)
		{
			if (tZSpawn == INVALID_HANDLE)
			{
				int zspawntimelimitzombie = GetConVarInt(g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT_ZOMBIE]);
				switch(zspawntimelimitzombie)
				{
					case -1:
					{
						// Get timelimit
						float zspawntime = GetConVarFloat(g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT_TIME]);
						
						// Tell client the timelimit for this command has expired.
						TranslationPrintToChat(client, "ZSpawn timelimit", RoundToNearest(zspawntime));
						return false;
					}
					case 0:
					{
						teamzombie = false;
					}
					case 1:
					{
						teamzombie = true;
					}
				}
			}
		}
	}
	else
	{
		// Use the override team in the function if were forcing the spawn.
		 teamzombie = zombie;
	}
	
	// Tell respawn module to respawn client.
	return RespawnSpawnClient(client, teamzombie, false);
}

/**
 * Menu callback (zspawn_force)
 * Forces ZSpawn on a client.
 * 
 * @param menu	  The menu handle.
 * @param action	Action client is doing in menu.
 * @param client	The client index.
 * @param slot	  The menu slot selected. (starting from 0)
 */
public int ZSpawnForceHandle(Handle menu_zspawn_force, MenuAction action, int client, int slot)
{
	// Client selected an option.
	if (action == MenuAction_Select)
	{
		// Get the client index of the selected client.
		int target = MenuGetClientIndex(menu_zspawn_force, slot);
		
		// If the target is 0, then the client left before being selected from the menu.
		if (target == 0)
		{
			// Re-send the menu.
			MenuClientList(client, ZSpawnForceHandle, true, true, false, "ZSpawn clients title");
			
			return;
		}
		
		// Get the target's name for future use.
		char targetname[MAX_NAME_LENGTH];
		GetClientName(target, targetname, sizeof(targetname));
		
		// Force ZSpawn on the target.
		bool success = ZSpawnClient(target, true);
		
		// Tell admin the outcome of the action.
		if (success)
		{
			TranslationReplyToCommand(client, "ZSpawn command force successful", targetname);
		}
		else
		{
			TranslationReplyToCommand(client, "ZSpawn command force unsuccessful", targetname);
		}
		
		// Re-send the menu.
		MenuClientList(client, ZSpawnForceHandle, true, false, true, "ZSpawn clients title");
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
		CloseHandle(menu_zspawn_force);
	}
}

/**
 * Command callback (zspawn)
 * Spawn into the game after joining late.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZSpawnCommand(int client, int argc)
{
	// If client is console, then stop and tell them this feature is for players only.
	if (ZRIsConsole(client))
	{
		TranslationPrintToServer("Must be player");
		return Plugin_Handled;
	}
	
	// Spawn client.
	ZSpawnClient(client);
	
	// This stops the "Unknown command" message in client's console.
	return Plugin_Handled;
}

/**
 * Command callback (zr_zspawn_force)
 * Force ZSpawn on a client.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZSpawnForceCommand(int client, int argc)
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
		TranslationReplyToCommand(client, "ZSpawn command force syntax");
		return Plugin_Handled;
	}
	
	char target[MAX_NAME_LENGTH], targetname[MAX_NAME_LENGTH];
	int targets[MAXPLAYERS];
	bool tn_is_ml;
	int result;
	
	// Get targetname.
	GetCmdArg(1, target, sizeof(target));
	
	// Find a target.
	result = ProcessTargetString(target, client, targets, sizeof(targets), COMMAND_FILTER_DEAD, targetname, sizeof(targetname), tn_is_ml);
		
	// Check if there was a problem finding a client.
	if (result <= 0)
	{
		ZRReplyToTargetError(client, result);
		return Plugin_Handled;
	}
	
	// Get item to give to client.
	char strZombie[4];
	GetCmdArg(2, strZombie, sizeof(strZombie));
	
	// Copy value of second (optional) parameter to 'zombie'.
	// It will be false if the parameter wasn't specified.
	bool zombie = view_as<bool>(StringToInt(strZombie));
	
	// x = Client index.
	for (int x = 0; x < result; x++)
	{
		// Give client the item.
		bool success = ZSpawnClient(targets[x], true, zombie);
		
		// Tell admin the outcome of the command if only 1 client was targetted.
		if (result == 1)
		{
			if (success)
			{
				TranslationReplyToCommand(client, "ZSpawn command force successful", targetname);
			}
			else
			{
				TranslationReplyToCommand(client, "ZSpawn command force unsuccessful", targetname);
			}
		}
	}
	
	// Log action to game events.
	LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_ZSpawn, "Force ZSpawn", "Admin \"%L\" forced player(s) to spawn. (zr_zspawn_force)", client);
	
	return Plugin_Handled;
}

/**
 * Timer callback, resets handle.
 * 
 * @param timer	 The timer handle.
 */
public Action ZSpawnTimer(Handle timer)
{
	// Reset timer handle.
	tZSpawn = INVALID_HANDLE;
}
