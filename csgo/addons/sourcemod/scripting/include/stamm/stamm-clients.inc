#if defined _stamm_clients_included
	#endinput
#endif
#define _stamm_clients_included




/**
 * These are some main forwards and natives to work with clients.
 */





/**
 * Executes when a client reaches a new level.
 *
 * @param client        Client index of the new VIP.
 * @param oldlevel      Old level of the client.
 * @param newlevel      New level of the client.
 */
forward STAMM_OnClientBecomeVip(client, oldlevel, newlevel);


/**
 * Executes when a player is fully initialized by Stamm after connecting.
 *
 * @param client        Client index of the new player.
 */
forward STAMM_OnClientReady(client);


/**
 * Executes when a player is saved to the database.
 *
 * @param client        Client index of the saved player.
 */
forward STAMM_OnSaveClient(client);


/**
 * Executes after a player got some Stamm points.
 *
 * @param client        Client index of the client.
 * @param points        The number of points, the player got.
 */
forward STAMM_OnClientGetPoints(client, points);


/**
 * Executes BEFORE a player get Stamm points.
 *
 * @param client        Client index of the client.
 * @param points        The number of points the player get (changeable).
 *
 * @return              Plugin_Continue, Plugin_Changed to give points, anything else to prevent it.
 */
forward Action:STAMM_OnClientGetPoints_PRE(client, &points);








/**
 * Give stamm points to a player.
 *
 * @param client        Client.
 * @param points        Number of points to add.
 *
 * @return              Return true on success, otherwise false.
 * @error               Client is invalid.
 */
native bool:STAMM_AddClientPoints(client, points);


/**
 * Deletes stamm points from a player.
 *
 * @param client        Client.
 * @param points        Number of points to delete.
 *
 * @return              Return true on success, otherwise false.
 * @error               Client is invalid.
 */
native bool:STAMM_DelClientPoints(client, points);


/**
 * Sets stamm points of a player.
 *
 * @param client        Client.
 * @param points        Number of points to set.
 *
 * @return              Return true on success, otherwise false.
 * @error               Client is invalid.
 */
native bool:STAMM_SetClientPoints(client, points);


/**
 * Returns the current stamm points a player have.
 *
 * @param client        Client.
 *
 * @return              Points of player.
 * @error               Client is invalid.
 */
native STAMM_GetClientPoints(client);


/**
 * Returns the stamm level of a client
 *
 * @param client        Client.
 *
 * @return              0=no VIP, x=Level.
 * @error               Client is invalid.
 */
native STAMM_GetClientLevel(client);


/**
 * Return whether the client has a specific level.
 *
 * @param client        Client.
 * @param level         Level to check.
 * @param min           true = Player has minimum the given level, false = Player has exact level.
 *
 * @return              true if Client is VIP, otherwise false.
 * @error               Client is invalid.
 */
#pragma deprecated Use STAMM_GetClientLevel instead!
native bool:STAMM_IsClientVip(client, level, bool:min=true);


/**
 * Returns true when the specific player is completely loaded by Stamm, otherwise false.
 *
 * @param client        Client.
 *
 * @return              true if fully loaded, otherwise false.
 */
native bool:STAMM_IsClientValid(client);


/**
 * Returns true when the specific player is a Stamm admin, otherwise false.
 *
 * @param client        Client.
 *
 * @return              true if admin, otherwise false.
 */
native bool:STAMM_IsClientAdmin(client);
