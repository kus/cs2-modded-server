/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zhp.inc
 *  Type:		  Module
 *  Description:   Displays HP to zombies.
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
 * Name of the cookie for toggle state of ZHP
 */
#define ZHP_COOKIE_ENABLED "zr_zhp"

/**
 * Array for storing ZHP timer handles per client.
 */
Handle tZHP[MAXPLAYERS + 1];

/**
 * Cookie handle for the toggle state of ZHP on a client.
 */
Handle g_hZHPEnabledCookie = INVALID_HANDLE;

/**
 * Create commands specific to ZHP.
 */
void ZHPOnCommandsCreate()
{
	// Register ZHP command.
	RegConsoleCmd(SAYHOOKS_KEYWORD_ZHP, ZHPCommand, "Shows real HP as zombie.");
}

/**
 * Create ZHP-related cookies here.
 */
void ZHPOnCookiesCreate()
{
	// Create cookie handle if it doesn't exist.
	if (g_hZHPEnabledCookie == INVALID_HANDLE)
	{
		g_hZHPEnabledCookie = RegClientCookie(ZHP_COOKIE_ENABLED, "The toggle state of ZHP.", CookieAccess_Protected);
	}
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void ZHPClientInit(int client)
{
	// Reset timer handle.
	tZHP[client] = INVALID_HANDLE;
}

/**
 * Called once a client's saved cookies have been loaded from the database.
 * 
 * @param client		Client index.
 */
void ZHPOnCookiesCached(int client)
{
	// Get default client setting from cvar.
	bool zhp = GetConVarBool(g_hCvarsList[CVAR_ZHP_DEFAULT]);
	
	// Get ZHP enabled cookie value.
	char zhpenabled[8];
	GetClientCookie(client, g_hZHPEnabledCookie, zhpenabled, sizeof(zhpenabled));
	
	// If the cookie is empty, then set the default value.
	if (!zhpenabled[0])
	{
		// Set cookie to default value from cvar.
		CookiesSetClientCookieBool(client, g_hZHPEnabledCookie, zhp);
	}
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void ZHPOnClientSpawn(int client)
{
	// If timer is running, kill it.
	if (tZHP[client] != INVALID_HANDLE)
	{
		KillTimer(tZHP[client]);
	}
	
	// Reset timer handle.
	tZHP[client] = INVALID_HANDLE;
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void ZHPOnClientDeath(int client)
{
	// If timer is running, kill it.
	if (tZHP[client] != INVALID_HANDLE)
	{
		KillTimer(tZHP[client]);
	}
	
	// Reset timer handle.
	tZHP[client] = INVALID_HANDLE;
}

/**
 * Client has been infected.
 * 
 * @param client	The client index.
 */
void ZHPOnClientInfected(int client)
{
	// If ZHP is disabled, then stop.
	bool zhp = GetConVarBool(g_hCvarsList[CVAR_ZHP]);
	if (!zhp)
	{
		return;
	}
	
	// Update HP display.
	ZHPUpdateHUD(client);
	
	// If timer is currently running, kill it.
	if (tZHP[client] != INVALID_HANDLE)
	{
		KillTimer(tZHP[client]);
	}
	
	// Start repeating timer to update display.
	tZHP[client] = CreateTimer(5.0, ZHPTimer, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

/**
 * Client has been hurt.
 * 
 * @param client	The client index.
 */
void ZHPOnClientHurt(int client)
{
	// Update HP display.
	ZHPUpdateHUD(client);
}

/**
 * Zombie has gained health for infecting a player.
 * 
 * @param client	The client index.
 */
void ZHPOnHealthInfectGain(int client)
{
	// Update HP display.
	ZHPUpdateHUD(client);
}

/**
 * Toggle ZHP on a client.
 * 
 * @param client	The client index.
 */
bool ZHPToggle(int client)
{
	// If ZHP is disabled, then stop.
	bool zhp = GetConVarBool(g_hCvarsList[CVAR_ZHP]);
	if (!zhp)
	{
		// Tell client feature is disabled.
		TranslationPrintToChat(client, "Feature is disabled");
		
		// Stop.
		return false;
	}
	
	// Get the cookie value.
	bool zhpstate = CookiesGetClientCookieBool(client, g_hZHPEnabledCookie);
	
	// Toggle the value.
	CookiesSetClientCookieBool(client, g_hZHPEnabledCookie, !zhpstate);
	
	// If ZHP was enabled, then tell client it has been disabled.
	if (zhpstate)
	{
		TranslationPrintToChat(client, "ZHP disable");
	}
	// If ZHP was disabled, then tell client it has been enabled.
	else
	{
		TranslationPrintToChat(client, "ZHP enable");
		
		// Update HP display.
		ZHPUpdateHUD(client);
	}
	
	return true;
}

/**
 * Update HP display for a player.
 * 
 * @param client	The client index.
 */ 
void ZHPUpdateHUD(int client)
{
	// If ZHP is disabled, then stop.
	bool zhp = GetConVarBool(g_hCvarsList[CVAR_ZHP]);
	if (!zhp)
	{
		return;
	}
	
	// Get ZHP enabled cookie as a bool.
	bool zhpstate = CookiesGetClientCookieBool(client, g_hZHPEnabledCookie);
	
	// If player is a zombie, or has ZHP disabled, then stop.
	if (!InfectIsClientInfected(client) || !zhpstate)
	{
		return;
	}
	
	// Get health, and if below 0 then set back to 0. (for display purposes)
	int health = GetClientHealth(client);
	if (health < 0)
	{
		health = 0;
	}
	
	// Display HP
	TranslationPrintHintText(client, "Display HP", health);
}

/**
 * Command callback (zhp)
 * Shows real HP as zombie.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZHPCommand(int client, int argc)
{
	// If client is console, then stop and tell them this feature is for players only.
	if (ZRIsConsole(client))
	{
		TranslationPrintToServer("Must be player");
		return Plugin_Handled;
	}
	
	// Toggle ZHP setting.
	ZHPToggle(client);
	
	// This stops the "Unknown command" message in client's console.
	return Plugin_Handled;
}

/**
 * Timer callback.  Repetitively calls ZHPUpdateHUD() until stopped.
 * 
 * @param timer	 The timer handle. 
 * @param client	The client index.
 */
public Action ZHPTimer(Handle timer, any client)
{
	// If client leaves, then stop timer.
	if (!IsClientInGame(client))
	{
		return Plugin_Stop;
	}
	
	// Update HP display.
	ZHPUpdateHUD(client);
	
	// Allow timer to continue.
	return Plugin_Continue;
}
