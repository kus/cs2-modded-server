#if defined _afkmanager_included
  #endinput
#endif
#define _afkmanager_included

/**
 * Specifies AFK immunity types.
 */
enum AFKImmunity:
{
	AFKImmunity_None = 0,
	AFKImmunity_Move = 1,
	AFKImmunity_Kick = 2,
	AFKImmunity_Full = 3,
};

/**
 * Sets the AFK immunity type of the client index.
 *
 * @param client	The client index of the player whos immunity type is being set.
 * @param type		The client AFK immunity type.
 * @error			The client index is invalid or AFK immunity type is invalid.
 */
native void AFKM_SetClientImmunity(int client, AFKImmunity type);

/**
 * Gets the current AFK spectator team number.
 *
 * @noparam
 * @return			The spectator team number.
 * @noerror
 */
native int AFKM_GetSpectatorTeam();

/**
 * Gets the current AFK status of the client index.
 *
 * @param client	The client index of the player being checked.
 * @return			The clients AFK status.
 * @error			The client index is invalid.
 */
native bool AFKM_IsClientAFK(int client);

/**
 * Gets the current AFK time in seconds of the client index. If the client
 * has an invalid AFK time -1 will be returned.
 *
 * Examples of clients who would have invalid AFK time values:
 *		Admins with full immunity.
 *		Disconnected clients.
 *		Bots, Fake Clients or Source TV.
 *
 * @param client	The client index of the player being checked.
 * @return		The clients AFK time or -1 if there is an error.
 * @error		The client index is invalid or time is invalid.
 */
native int AFKM_GetClientAFKTime(int client);


// Private Forwards

// Global Forwards

/**
 * Called when an AFK InitializePlayer() fires.
 *
 * @param client	The client index of the client in the event.
 * @return			Plugin_Stop to stop creating AFK Timer (Full Immunity), any other value for default behavior.
 *
 */
forward Action AFKM_OnInitializePlayer(int client);


/**
 * Called when an AFK event fires.
 *
 * @param name		This is the name of the AFK event.
 *
 * Event Names:
 *
 *		"afk_spawn_move"	- Event fired when a client should be moved to spectator for Spawn AFK.
 *		"afk_move"			- Event fired when a client should be moved to spectator for normal AFK.
 *		"afk_kick"			- Event fired when a client should be kicked.
 *
 * @param client	The client index of the client in the event.
 * @return			Plugin_Continue to complete event.
 *
 */
forward Action AFKM_OnAFKEvent(const char[] name, int client);


/**
 * Called when a client has been set AFK.
 *
 * @param client	The client index of the player being flagged.
 * @noreturn
 */
forward void AFKM_OnClientAFK(int client);


/**
 * Called when a client is back from AFK.
 *
 * @param client	The client index of the player being flagged.
 * @noreturn
 */
forward void AFKM_OnClientBack(int client);


public SharedPlugin __pl_afkmanager = 
{
	name = "afkmanager",
	file = "afk_manager4.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_afkmanager_SetNTVOptional()
{
	MarkNativeAsOptional("AFKM_SetClientImmunity");
	MarkNativeAsOptional("AFKM_GetSpectatorTeam");
	MarkNativeAsOptional("AFKM_IsClientAFK");
	MarkNativeAsOptional("AFKM_GetClientAFKTime");
}
#endif