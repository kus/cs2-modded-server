/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  spawnprotect.inc
 *  Type:		  Module
 *  Description:   Protects late-joining players from zombies for x seconds.
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
 * Array for storing spawn protect timer handles per client.
 */
Handle tSpawnProtect[MAXPLAYERS + 1];

/**
 * Array for storing time left for spawn protection per client.
 */
int pSpawnProtectTime[MAXPLAYERS + 1];
 
/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void SpawnProtectClientInit(int client)
{
	// Reset timer handle.
	tSpawnProtect[client] = INVALID_HANDLE;
}

/**
 * Client is spawning into the game. *Post
 * 
 * @param client	The client index.
 */   
void SpawnProtectOnClientSpawnPost(int client)
{
	// If client is dead, then they are joining the server, not spawning.
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	// If timer is currently running, kill it.
	if (tSpawnProtect[client] != INVALID_HANDLE)
	{
		KillTimer(tSpawnProtect[client]);
	}
	
	// Reset timer handle.
	tSpawnProtect[client] = INVALID_HANDLE;
	
	// If protect cvar is disabled, then stop.
	bool protect = GetConVarBool(g_hCvarsList[CVAR_SPAWNPROTECT]);
	if (!protect)
	{
		return;
	}
	
	// Disable spawn protection on client.
	bInfectImmune[client] = false;
	
	// Start spawn protection.
	SpawnProtectStart(client);
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void SpawnProtectOnClientDeath(int client)
{
	// If timer is running, kill it.
	if (tSpawnProtect[client] != INVALID_HANDLE)
	{
		KillTimer(tSpawnProtect[client]);
	}
	
	// Reset timer handle.
	tSpawnProtect[client] = INVALID_HANDLE;
}

/**
 * Start spawn protection on a client.
 * 
 * @param client	The client index.
 */
void SpawnProtectStart(int client)
{
	// If client is dead, then stop.
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	// If zombie hasn't spawned, then stop.
	if (!g_bZombieSpawned)
	{
		return;
	}
	
	// If client is a zombie, then stop.
	if (InfectIsClientInfected(client))
	{
		return;
	}
	
	// Get spawn protect attribute cvars.
	float speed = GetConVarFloat(g_hCvarsList[CVAR_SPAWNPROTECT_SPEED]);
	int alpha = GetConVarInt(g_hCvarsList[CVAR_SPAWNPROTECT_ALPHA]);
	
	// Validate attributes
	float min;
	float max;
	switch (ClassSpeedMethod)
	{
		case ClassSpeed_LMV:
		{
			min = ZR_CLASS_SPEED_LMV_MIN;
			max = ZR_CLASS_SPEED_LMV_MAX;
		}
		case ClassSpeed_Prop:
		{
			min = ZR_CLASS_SPEED_PROP_MIN;
			max = ZR_CLASS_SPEED_PROP_MAX;
		}
	}
	if (speed < min && speed > max)
	{
		// Log a warning and abort.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, view_as<LogModules>(LogModule_Config), "Config validation", "Out of range value in cvar zr_spawnprotect_speed (%f). Aborting spawn protection.", speed);
		return;
	}
	if (alpha < ZR_CLASS_ALPHA_INITIAL_MIN && alpha > ZR_CLASS_ALPHA_INITIAL_MAX)
	{
		// Log a warning and abort.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, view_as<LogModules>(LogModule_Config), "Config validation", "Out of range value in cvar zr_spawnprotect_alpha (%d). Aborting spawn protection.", alpha);
		return;
	}
	
	// Set spawn protect flag on client.
	bInfectImmune[client] = true;
	
	// Set spawn protect attributes.
	ClassApplySpeedEx(client, speed);
	ToolsSetClientAlpha(client, alpha);
	
	// Set time left to zr_protect_time's value.
	int protect_time = GetConVarInt(g_hCvarsList[CVAR_SPAWNPROTECT_TIME]);
	pSpawnProtectTime[client] = protect_time;
	
	// Tell client they are being protected.
	TranslationPrintToChat(client, "Spawn protection begin", protect_time);
	
	// Send time left in a hud message.
	TranslationPrintHintText(client, "Spawn Protect", pSpawnProtectTime[client]);
	
	// Start repeating timer.
	tSpawnProtect[client] = CreateTimer(1.0, SpawnProtectTimer, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

/**
 * Timer callback function, countdown for spawn protection.
 * 
 * @param timer	 The timer handle.
 * @param client	The client index.
 */	
public Action SpawnProtectTimer(Handle timer, any client)
{
	// If client leaves, then stop timer.
	if (!IsClientInGame(client))
	{
		// Reset timer handle.
		tSpawnProtect[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	// If client has become a zombie, then stop timer.
	if (!InfectIsClientHuman(client))
	{
		// Reset timer handle.
		tSpawnProtect[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	// Decrement time left.
	pSpawnProtectTime[client]--;
	
	// Print time left to client.
	TranslationPrintHintText(client, "Spawn Protect", pSpawnProtectTime[client]);
	
	// Time has expired.
	if (pSpawnProtectTime[client] <= 0)
	{
		// Remove protect flag.
		bInfectImmune[client] = false;
		
		// Tell client spawn protection is over.
		TranslationPrintHintText(client, "Spawn protection end");
		
		// Fix attributes.
		ToolsSetClientAlpha(client, ClassGetAlphaInitial(client));
		ClassApplySpeedEx(client, ClassGetSpeed(client));
		
		// Clear timer handle.
		tSpawnProtect[client] = INVALID_HANDLE;
		
		// Stop timer.
		return Plugin_Stop;
	}
	
	// Allow timer to continue repeating.
	return Plugin_Continue;
}
