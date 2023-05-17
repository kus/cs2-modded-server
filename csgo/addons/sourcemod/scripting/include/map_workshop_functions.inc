/**
 * vim: set ts=4 :
 * =============================================================================
 * Map Workshop Functions
 * Functions for comparing workshop map names to normal map names
 *
 * Map Workshop Functions (C)2014-2015 Powerlord (Ross Bemrose).
 * All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#if defined _mapworkshopfunctions_included_
  #endinput
#endif
#define _mapworkshopfunctions_included_

// This is in SourceMod 1.7 format

/**
 * Remove the path from the map name
 * This was intended to remove workshop paths.
 * Used internally by MapEqual and FindMapStringInArray.
 * 
 * @param map			Map name
 * @param destination	String to copy map name to
 * @param maxlen		Length of destination string
 * 
 * @return			True if path was removed, false if map and destination are the same
 */
stock bool RemoveMapPath(const char[] map, char[] destination, int maxlen)
{
	if (strlen(map) < 1)
	{
		ThrowError("Bad map name: %s", map);
	}
	
	// UNIX paths
	int pos = FindCharInString(map, '/', true);
	if (pos == -1)
	{
		// Windows paths
		pos = FindCharInString(map, '\\', true);
		if (pos == -1)
		{
			// Copy the path out unchanged, but return false
			// This was added by request, but also simplifies MapEqual a LOT
			strcopy(destination, maxlen, map);
			return false;
		}
	}

	// pos + 1 is because pos is the last / or \ location and we want to start one char further
	// maxlen is because strcopy will auto-stop if it hits '\0' before maxlen
	strcopy(destination, maxlen, map[pos+1]);
	
	return true;
}

/**
 * Check if two maps are the same map.
 * Takes workshop paths into account.
 * 
 * @param map		First map
 * @param map2	Second map
 * 
 * @return		true if they're the same map, false if not.
 */
stock bool MapEqual(const char[] map, const char[] map2)
{
	char pathlessMap[PLATFORM_MAX_PATH];
	char pathlessMap2[PLATFORM_MAX_PATH];
	
	RemoveMapPath(map, pathlessMap, sizeof(pathlessMap));
	RemoveMapPath(map2, pathlessMap2, sizeof(pathlessMap2));
	
	return !strcmp(pathlessMap, pathlessMap2);
}

/**
 * A replacement for FindStringInArray, but using MapEqual to compare elements.
 * Returns the index for the first occurence of the provided map. If the map cannot be located, -1 will be returned.
 * 
 * @param array		ArrayList Handle.
 * @param map			Map to search for
 *
 * @return 			Array index, or -1 on failure
 */
stock int FindMapStringInMapArray(ArrayList array, const char[] map)
{
	for (int i = 0; i < array.Length; i++)
	{
		char arrayMap[PLATFORM_MAX_PATH];
		array.GetString(i, arrayMap, sizeof(arrayMap));
		if (MapEqual(arrayMap, map))
		{
			return i;
		}
	}
	
	return -1;
}
