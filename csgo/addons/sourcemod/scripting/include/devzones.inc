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
native bool:Zone_IsClientInZone(client, String:zone[], bool:equal = true, bool:caseSensitive = false);

/**
 * Check if a position is in a zone
 *
 * @param client     Player for check
 * @String zone     Zone name
 * @float posx      X-Pos
 * @float posx      Y-Pos
 * @float posx      Z-Pos
 * @return true if position is in a zone or not
 */
native bool Zone_isPositionInZone(char[] zone, float posx, float posy, float posz, bool equal = true);

/**
 * Check if zone exists
 *
 * @String zone     Zone name
 * @bool equal     Check exact zone name or parcial name
 * @bool caseSensitive     If true, comparison is case sensitive. If false, comparison is case insensitive.
 * @return true if zone exist
 */
native bool:Zone_CheckIfZoneExists(String:zone[], bool:equal = true, bool:caseSensitive = false);

/**
 * Called when a player has entered in a zone.
 * @param client   client that has entered in the zone.
 * @String zone   Zone name.
 */
forward Zone_OnClientEntry(client, String:zone[]);

/**
 * Called when a player has left a zone.
 * @param client   client that has left the zone.
 * @String zone   Zone name.
 */
forward Zone_OnClientLeave(client, String:zone[]);

/**
 * Get a zone position
 * @String zone   Zone name to search position.
 * @bool caseSensitive     If true, comparison is case sensitive. If false, comparison is case insensitive.
 * @Float Position   Array when the zone position will be copied
 * @return true on successfully, false otherwise
 */
native Zone_GetZonePosition(String:zone[], bool:caseSensitive = false, Float:Position[3]);


/*
		@Param1 -> int client
		@Param2 -> char[64] zoneBuffer
	
		@return true if zone found false if not
	*/
native bool Zone_getMostRecentActiveZone(int client, char zoneBuffer[64]); 
