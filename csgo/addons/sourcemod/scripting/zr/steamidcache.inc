/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  steamidcache.inc
 *  Type:		  Core
 *  Description:   A SteamID caching API.
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
 * The maximum length of a SteamID
 */
#define STEAMIDCACHE_MAX_LENGTH 16

/**
 * Creates a steamid cache.
 * 
 * @return  Handle to SteamID cache.
 */
stock Handle SteamidCacheCreate()
{
	// Return steamid cache handle.
	return CreateArray(STEAMIDCACHE_MAX_LENGTH);
}

/**
 * Add client serial number to the SteamID cache.
 * 
 * @param steamidcache  The SteamID cache to add client to.
 * @param client		The client index.
 * @return			  True if the client was added successfully, false if the client already exists.
 */
stock bool SteamidCacheAddClient(Handle steamidcache, int client)
{
	// Check if client is in the cache.
	if (SteamidCacheClientExists(steamidcache, client))
	{
		return false;
	}
	
	// Get client's SteamID.
	char steamid[STEAMIDCACHE_MAX_LENGTH];
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
	
	// Push SteamID into the SteamID cache.
	PushArrayString(steamidcache, steamid);
	
	// Client added successfully.
	return true;
}

/**
 * Check if a client is in the SteamID cache.
 * 
 * @param steamidcache  The SteamID cache to check in.
 * @param client		The client index.
 * @return			  True if the client exists, false otherwise.
 */
stock bool SteamidCacheClientExists(Handle steamidcache, int client)
{
	// Get client's SteamID.
	char steamid[STEAMIDCACHE_MAX_LENGTH];
	GetClientAuthId(client, AuthId_Engine,steamid, sizeof(steamid));
	
	// Return true if client was found, false otherwise.
	return (FindStringInArray(steamidcache, steamid) != -1);
}

/**
 * Reset SteamID cache.
 * 
 * @param steamidcache  The SteamID cache to reset.
 */
stock void SteamidCacheReset(Handle steamidcache)
{
	// Clear array.
	ClearArray(steamidcache);
}
