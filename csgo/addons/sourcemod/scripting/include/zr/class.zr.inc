/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  class.zr.inc
 *  Type:		  Include
 *  Description:   Player class API.
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
 * @section Internal class cache types. Specifies which class data to access.
 */
#define ZR_CLASS_CACHE_ORIGINAL 0   /** Original class data loaded from file. */
#define ZR_CLASS_CACHE_MODIFIED 1   /** Default cache. Class data modified by eventual multipliers, map configs, commands, etc. */
#define ZR_CLASS_CACHE_PLAYER   2   /** Current player class attributes. The class index parameter is used as client index when reading from this cache. */
/**
 * @endsection
 */

/**
 * Results when selecting a class for a player.
 */
enum ClassSelectResult
{
	ClassSelected_NoChange,	 /** No class change was necessary (class already selected). */
	ClassSelected_Instant,	  /** Class was instantly changed. */
	ClassSelected_NextSpawn	 /** Class will be used next spawn. */
}

/**
 * Returns whether a class index is valid or not.
 *
 * @param classIndex	Class index to validate.
 *
 * @return			  True if valid, false otherwise.
 */
native bool ZR_IsValidClassIndex(int classIndex);

/**
 * Gets the currently active class index that the player is using.
 *
 * @param client	The client index.
 *
 * @return		  The active class index.
 */
native bool ZR_GetActiveClass(int client);

/**
 * Selects a class for a player.
 *
 * Human class attribute may be instantly applied if player is alive, human and
 * instant class change is enabled. Otherwise only the selected index will be
 * updated for next spawn.
 *
 * Class selection will be saved in client cookies if enabled.
 *
 * @param client			Client index.
 * @param classIndex		Class index.
 * @param applyIfPossible   Optional. Apply class attributes if conditions allow
 *						  it. Default is true.
 * @param saveIfEnabled	 Optional. Save class selection in client cookies if
 *						  enabled. Default is true.
 *
 * @return				  Class selection result. See enum ClassSelectResult.
 */
native ClassSelectResult ZR_SelectClientClass(int client, int classIndex, bool applyIfPossible = true, bool saveIfEnabled = true);

/**
 * Gets the class index of the class with the specified name.
 *
 * Note: This search is linear and probably won't perform well in large loops.
 *
 * @param className	 Class name to search for.
 * @param cacheType	 Optional. Specifies which class cache to read from,
 *					  except player cache.
 *
 * @return			  Class index, or -1 if none found.
 */
native ZR_GetClassByName(const char[] className, int cacheType = ZR_CLASS_CACHE_MODIFIED);

/**
 * Gets the class name displayed in the class menu.
 *
 * @param index		 Index of the class in a class cache or a client index,
 *					  depending on the cache type specified.
 * @param buffer		The destination string buffer.
 * @param maxlen		The length of the destination string buffer.
 * @param cacheType	 Optional. Specifies which class cache to read from.
 * @return			  Number of cells written. -1 on error.
 */
native ZR_GetClassDisplayName(int index, char[] buffer, int maxlen, int cacheType = ZR_CLASS_CACHE_MODIFIED);
