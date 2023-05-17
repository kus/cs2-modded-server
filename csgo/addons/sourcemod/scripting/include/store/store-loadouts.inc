#if defined _store_loadouts_included
#endinput
#endif
#define _store_loadouts_included

//Forwards
forward void Store_OnClientLoadoutChanged(int client);

/**
 * Opens the loadout menu for a client.
 *
 * @param client			Client index.
 *
 * @noreturn
 */
native void Store_OpenLoadoutMenu(int client);

/**
 * Gets client current loadout.
 *
 * @param client			Client index.
 *
 * @return Loadout index.
 */
native int Store_GetClientLoadout(int client);

/**
 * Sets client current loadout.
 *
 * @param client			Client index.
 *
 * @noreturn
 */
native void Store_SetClientLoadout(int client, int loadout_id);

public SharedPlugin __pl_store_loadouts = 
{
	name = "store-loadouts", 
	file = "store-loadouts.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if defined REQUIRE_PLUGIN
public __pl_store_loadouts_SetNTVOptional()
{
	MarkNativeAsOptional("Store_OpenLoadoutMenu");
	MarkNativeAsOptional("Store_GetClientLoadout");
	MarkNativeAsOptional("Store_SetClientLoadout");
}
#endif