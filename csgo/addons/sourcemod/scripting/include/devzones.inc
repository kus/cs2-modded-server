/** Double-include prevention */
#if defined _devzones_included_
  #endinput
#endif
#define _devzones_included_


/**
 * Check if a player are there in a zone
 *
 * @param client     Player for check
 * @String zone     Zone name
 * @bool equal     Check exact zone name or parcial name
 * @bool caseSensitive     If true, comparison is case sensitive. If false, comparison is case insensitive.
 * @return true if player are there in the zone given in Zone String
 */
native bool Zone_IsClientInZone(int client, const char[] zone, bool equal = true, bool caseSensitive = false);

/**
 * Check if a position is in a zone
 *
 * @param client     Player for check
 * @String zone     Zone name
 * @float posx      X-Pos
 * @float posx      Y-Pos
 * @float posx      Z-Pos
 * @bool equal     Check exact zone name or parcial name
 * @bool caseSensitive     If true, comparison is case sensitive. If false, comparison is case insensitive.
 * @return true if position is in a zone or not
 * @note 					If you compare a player's origin inside Zone_OnClientEntry, this returns false.
 */
native bool Zone_isPositionInZone(const char[] zone, float posx, float posy, float posz, bool equal = true, bool caseSensitive = false);

/**
 * Check if zone exists
 *
 * @String zone     Zone name
 * @bool equal     Check exact zone name or parcial name
 * @bool caseSensitive     If true, comparison is case sensitive. If false, comparison is case insensitive.
 * @return true if zone exist
 */
native bool Zone_CheckIfZoneExists(const char [] zone, bool equal = true, bool caseSensitive = false);

/**
 * Called when a player has entered in a zone.
 * @param client   client that has entered in the zone.
 * @String zone   Zone name.
 */
forward void Zone_OnClientEntry(int client, const char [] zone);

/**
 * Called when a player has left a zone.
 * @param client   client that has left the zone.
 * @String zone   Zone name.
 */
forward void Zone_OnClientLeave(int client, const char [] zone);

/**
 * Get a zone position
 * @String zone   Zone name to search position.
 * @bool caseSensitive     If true, comparison is case sensitive. If false, comparison is case insensitive.
 * @Float Position   Array when the zone position will be copied
 * @return true on successfully, false otherwise
 */
native int Zone_GetZonePosition(const char [] zone, bool caseSensitive = false, float Position[3]);

/**
 * Get a zone coordinates
 * @String zone   Zone name to search coordinates.
 * @bool caseSensitive     If true, comparison is case sensitive. If false, comparison is case insensitive.
 * @Float CordA   Array when the zone coordinates A will be copied
 * @Float CordB   Array when the zone coordinates B will be copied
 * @return true on successfully, false otherwise
 */
native int Zone_GetZoneCord(const char [] zone, bool caseSensitive = false, float CordA[3], float CordB[3]);


/**
 * @Param1 -> int client
 * @Param2 -> char[64] zoneBuffer	
 * @return true if zone found false if not
 */
native bool Zone_getMostRecentActiveZone(int client, char zoneBuffer[64]); 

/**
 * Called when a zone is created.
 * @String zone   Zone name.
 */
forward void Zone_OnCreated(const char [] zone);
