#if defined _store_loadout_included
  #endinput
#endif
#define _store_loadout_included

forward Store_OnClientLoadoutChanged(client);

/**
 * Opens the loadout menu for a client.
 *
 * @param client			Client index.
 *
 * @noreturn
 */
native Store_OpenLoadoutMenu(client);

/**
 * Gets client current loadout.
 *
 * @param client			Client index.
 *
 * @return Loadout index.
 */
native Store_GetClientLoadout(client);

public SharedPlugin:__pl_loadout_store =
{
    name = "store-loadout",
    file = "store-loadout.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if defined REQUIRE_PLUGIN
public __pl_store_loadout_SetNTVOptional()
{
	MarkNativeAsOptional("Store_OpenLoadoutMenu");  
	MarkNativeAsOptional("Store_GetClientLoadout");  
}
#endif