#if defined _store_backend_included
#endinput
#endif
#define _store_backend_included

//Globals
enum Store_AcquireMethod
{
	Store_Shop,
	Store_Trade,
	Store_Gift,
	Store_Admin,
	Store_Web,
	Store_Unknown
}

//Defines
#define MAX_CATEGORIES	64
#define MAX_ITEMS 		2048
#define MAX_LOADOUTS	64
#define MAX_QUERY_SIZES	2048

#define STORE_MAX_NAME_LENGTH			32
#define STORE_MAX_DISPLAY_NAME_LENGTH	64
#define STORE_MAX_DESCRIPTION_LENGTH	128
#define STORE_MAX_TYPE_LENGTH			32
#define STORE_MAX_REQUIREPLUGIN_LENGTH	32

#define STORE_MAX_LOADOUTSLOT_LENGTH	32
#define STORE_MAX_LOADOUTGAME_LENGTH	32
#define STORE_MAX_LOADOUTCLASS_LENGTH	32

#define STORE_MAX_ATTRIBUTES_LENGTH		10 * 1024

//Prototypes
typedef Store_GetItemsCallback = function void(int[] items, int count, any data);
typedef Store_GetUserItemsCallback = function void(int[] useritems, bool[] equipped, int[] useritemCount, int count, int loadoutId, any data);
typedef Store_GetUserLoadoutsCallback = function void(int accountId, int[] ids, int count, any data);

typeset Store_ItemGetAttributesCallback 
{
	function void(const char[] itemName, const char[] attrs);
	function void(const char[] itemName, const char[] attrs, any data);
}

typedef Store_AccountCallback = function void(int accountId, any data);

typedef Store_GetCreditsCallback = function void(int credits, any data);
typedef Store_GiveCreditsCallback = function void(int accountId, int credits, any data);
typedef Store_RemoveCreditsCallback = function void(int accountId, int credits, bool bIsNegative, any data);

typedef Store_BuyItemCallback = function void(bool success, any data);
typedef Store_EquipItemCallback = function void(int accountId, int itemId, int loadoutId, any data);
typedef Store_UseItemCallback = function void(int accountId, int itemId, any data);
typedef Store_GetUserItemsCountCallback = function void(int count, any data);

////////////////////
//Natives

/**
 * Registers the plugin module for the webpanel to handle.
 * It's recommended that all modules register & refresh each plugin load. This is required in order for the webpanel to manage modules properly.
 *
 * @param sName		    	Name of the plugin, this is just for reference.
 * @param sDescription		Description of the plugin, this is just for reference as well.
 * @param sVersion_ConVar	Name of the version ConVar the plugin uses.
 * @param sVersion			Current version number of the plugin.
 * @noreturn
 */
native void Store_RegisterPluginModule(const char[] sName, const char[] sDescription, const char[] sVersion_ConVar, const char[] sVersion);

/**
 * Queries the database and returns data to a callback. (Send SQL Queries to the Store database without creating a new connection in your plugin)
 *
 * @param callback		Callback to send results to.
 * @param query			Query to execute.
 * @param data			Data to pass through callback.
 * @param prio			Database priority to give.
 * @noreturn
 */
native void Store_SQLTQuery(SQLTCallback callback, const char[] query, any data = 0, DBPriority prio = DBPrio_Normal, const char[] sQuery = "Native");

/**
 * Pushes the base URL set to other plugins for them to use. ( Example  "http //www.domain.com/store/" )
 *
 * @param sBaseURL		String to set the URL in.
 * @param size			Size of the string.
 *
 * @noreturn
 */
native void Store_GetStoreBaseURL(char[] sBaseURL, int size);

/**
 * Registers a player in the database 
 * 
 * - If the player is already in the database, his name will be updated according
 *   to the 'name' parameter provided.
 *
 * - If the player is not in the database (for example, a new player who just joined
 *   the server for the first time), he will be added using the account ID and name 
 *   provided.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId			The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param name 				The name of the player.
 * @param credits 			The amount of credits to give to the player if it's his first register. 
 *
 * @noreturn
 */
native void Store_Register(int  accountId, const char[] name = "", int credits = 0);

/**
 * Registers a player in the database, provided his client index only. 
 *
 * This method converts the client index provided to an account id, retrieves 
 * the player's name, and calls Store_Register using that information.
 *
 * The logic of registering a player is explained in the Store_Register documentation.
 *
 * The store-core module calls this method every time a player joins the server.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param client			Client index.
 * @param credits 			The amount of credits to give to the player if it's his first register. 
 *
 * @noreturn
 */
native void Store_RegisterClient(int client, int credits = 0);

/**
 * This function was added back in 1.2.2 in order to add backwards compatibility for older modules.
 * 
 * This essentially just pulls the AccountID of the client using the 'GetSteamAccountID' function.
 * 
 * If you're building a module for the store, It's best that you just use that instead but you can use this if you so desire.
 *
 * @param client			Client index.
 *
 * @return Steam account ID on success, 0 on error.
 */
native int Store_GetClientAccountID(int client);

/**
 * Retrieves a clients UserID from the database.
 *
 * @param client			Client index.
 *
 * @return Database UserID on success, -1 on failure.
 */
native int Store_GetClientUserID(int client);

/**
 * Retrieves all item categories from the database. 
 *
 * The store-backend module builds a cache of the categories retrieved the first time 
 * this method is called, for faster access the next time it's called.
 *
 * You can set the loadFromCache parameter of this method to false to retrieve categories
 * from the database and not from the cache.
 *
 * The store-core module calls this method when it is loaded to build a cache of 
 * categories.
 *
 * It also provides the store_reloaditems command to reload items and categories 
 * from the database. 
 *
 * To use this method, you can provide a callback for when the categories are loaded.
 * The callback will provide an array of the categories' IDs. You can then loop the array,
 * and find info about each category using the Store_GetCategory* methods.
 *
 * For example 
 * 
 *  Store_GetCategories(OnCategoriesLoaded);
 *
 *  public OnCategoriesLoaded(categories, count, any data)
 *  {
 *      for (new category = 0; category < count; category++)
 *      {
 *          decl char[] displayName[32];
 *          Store_GetCategoryDisplayName(categories[category], displayName, sizeof(displayName));
 *          
 *          PrintToServer(displayName);
 *      }
 *  }
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param callback		    A callback which will be called when the categories are loaded.
 * @param loadFromCache     Whether to load categories from cache. If false, the method will 
 *                          query the database and rebuild its cache.
 * @param sPriority		    Priority string to use when querying database for categories. (Primarily used with the shop module)
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetCategories(Store_GetItemsCallback callback = INVALID_FUNCTION, bool loadFromCache = true, const char[] sPriority, any data = 0);

/**
 * Retrieves a category's priority number by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all categories.
 * 
 * @param id                Category's ID.
 *
 * @return Categories priority number.
 */
native int Store_GetCategoryPriority(int id);

/**
 * Retrieves a category's display name by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all categories.
 * 
 * @param id                Category's ID.
 * @param displayName       Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetCategoryDisplayName(int id, char[] displayName, int maxlength);

/**
 * Retrieves a category's description by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all categories.
 * 
 * @param id 				Category's ID.
 * @param description       Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetCategoryDescription(int id, char[] description, int maxlength);

/**
 * Retrieves the plugin name that is required for a specific category. 
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all categories.
 * 
 * @param id                Category's ID.
 * @param pluginRequired    Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetCategoryPluginRequired(int id, char[] pluginRequired, int maxlength);

/**
 * Retrieves a category's status with server restrictions by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all categories.
 * 
 * @param id                Category's ID.
 *
 * @return	True if enabled, false otherwise.
 */
native bool Store_GetCategoryServerRestriction(int id);

/**
 * Retrieves items from the database. 
 *
 * The store-backend module builds a cache of the items retrieved the first time 
 * this method is called, for faster access the next time it's called.
 *
 * You can set the loadFromCache parameter of this method to false to retrieve categories
 * from the database and not from the cache.
 *
  * You can use the filter parameter to filter items returned by the following properties 
 *  - category_id (cell)
 *  - is_buyable (cell)
 *  - is_tradeable (cell)
 *  - is_refundable (cell)
 *  - type (string)
 *
 * To use it, set it to a trie with some or all of the above properties.
 * IMPORTANT  You are *not* resposible for closing the filter trie's handle, 
 *            the store-backend module is.
 *
 * The store-backend module calls this method when it is loaded to build a cache of 
 * categories. It also provides the store_reloaditems command to reload items and categories 
 * from the database. 
 *
 * To use this method, you can provide a callback for when the items are loaded.
 * The callback will provide an array of the items' IDs. You can then loop the array,
 * and find info about each item using the Store_GetItem* methods.
 *
 * For example 
 * 
 *	new Handle filter = CreateTrie();
 * 	SetTrieString(filter, "type", "equipment");
 *	SetTrieValue(filter, "is_buyable", 1);
 * 
 *  Store_GetItems(filter, OnItemsLoaded);
 *
 *  public OnItemsLoaded(items, count, any data)
 *  {
 *      for (new item = 0; item < count; item++)
 *      {
 *          decl char[] displayName[32];
 *          Store_GetItemDisplayName(items[item], displayName, sizeof(displayName));
 *          
 *          PrintToServer(displayName);
 *      }
 *  }
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param filter            A trie which will be used to filter the loadouts returned.
 * @param callback		    A callback which will be called when the items are loaded.
 * @param loadFromCache     Whether to load items from cache. If false, the method will 
 *                          query the database and rebuild its cache.
 * @param sPriority		    Priority string to use when querying database for items. (Primarily used with the shop module)
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetItems(Handle filter = INVALID_HANDLE, Store_GetItemsCallback callback = INVALID_FUNCTION, bool loadFromCache = true, const char[] sPriority, any data = 0);

/**
 * Retrieves an item's name by its ID.
 *
 * The difference between an item's name and an item's display name is
 * that its name is a lowered-case unique identifier of it, and
 * its display name is what actually displayed in the store UI (which
 * doesnt has to be unique).
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Category's ID.
 * @param name 				Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetItemName(int id, char[] name, int maxlength);

/**
 * Retrieves an item's priority number by its ID.
 *
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Item's ID.
 *
 * @return Item priority number.
 */
native int Store_GetItemPriority(int id);

/**
 * Retrieves an item's display name by its ID.
 *
 * The difference between an item's name and an item's display name is
 * that its name is a lowered-case unique identifier of it, and
 * its display name is what actually displayed in the store UI (which
 * doesnt has to be unique).
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Category's ID.
 * @param displayName       Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetItemDisplayName(int id, char[] displayName, int maxlength);

/**
 * Retrieves an item's description by its ID.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Category's ID.
 * @param description       Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetItemDescription(int id, char[] description, int maxlength);

/**
 * Retrieves an item's type by its ID.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Category's ID.
 * @param type              Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetItemType(int id, char[] type, int maxlength);

/**
 * Retrieves an item's loadout slot by its ID.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Category's ID.
 * @param loadoutSlot       Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetItemLoadoutSlot(int id, char[] loadoutSlot, int maxlength);

/**
 * Retrieves an item's price by its ID.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Category's ID.
 *
 * @return The item's price.
 */
native int Store_GetItemPrice(int id);

/**
 * Retrieves an item's category by its ID.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Category's ID.
 *
 * @return The item's category ID.
 */
native int Store_GetItemCategory(int id);

/**
 * Determines whether or not an item is buyable.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Item's ID.
 *
 * @return True if buyable, false otherwise.
 */
native bool Store_IsItemBuyable(int id);

/**
 * Determines whether or not an item is tradeable.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Item's ID.
 *
 * @return True if tradeable, false otherwise.
 */
native bool Store_IsItemTradeable(int id);

/**
 * Determines whether or not an item is refundable.
 * 
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all items.
 * 
 * @param id                Item's ID.
 *
 * @return True if refundable, false otherwise.
 */
native bool Store_IsItemRefundable(int id);

/** 
 * Retrieves item attributes asynchronously.
 *
 * @param itemName			Item's name.
 *
 * @noreturn
 */
native void Store_GetItemAttributes(const char[] itemName, Store_ItemGetAttributesCallback callback = INVALID_FUNCTION, any data = 0);

/** 
 * Modifies item attributes asynchronously.
 *
 * @param itemName			Item's name.
 *
 * @noreturn
 */
native void Store_WriteItemAttributes(const char[] itemName, const char[] attrs, Store_BuyItemCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Retrieves an item's status with server restrictions by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all categories.
 * 
 * @param id                Item's ID.
 *
 * @return	True if enabled, false otherwise.
 */
native bool Store_GetItemServerRestriction(int id);

/**
 * Retrieves loadouts from the database. 
 *
 * The store-backend module builds a cache of the loadouts retrieved the first time 
 * this method is called, for faster access the next time it's called.
 *
 * You can set the loadFromCache parameter of this method to false to retrieve loadouts
 * from the database and not from the cache.
 *
 * You can use the filter parameter to filter loadouts returned by the following properties 
 *  - game (string)
 *  - team (cell)
 *  - class (string)
 *
 * To use it, set it to a trie with some or all of the above properties.
 * IMPORTANT  You are *not* resposible for closing the filter trie's handle, 
 *            the store-backend module is.
 * 
 * The store-loadout module calls this method when it is loaded to build a cache of 
 * loadouts.
 *
 * To use this method, you can provide a callback for when the items are loaded.
 * The callback will provide an array of the loadouts' IDs. You can then loop the array,
 * and find info about each item using the Store_GetLoadout* methods.
 *
 * For example 
 *
 *	new Handle filter = CreateTrie();
 * 	SetTrieString(filter, "game", "tf");
 *	SetTrieValue(filter, "team", GetClientTeam(client));
 *  
 *  Store_GetLoadouts(filter, OnLoadoutsLoaded);
 *
 *  public OnLoadoutsLoaded(loadouts, count, any data)
 *  {
 *      for (new loadout = 0; loadout < count; loadout++)
 *      {
 *          decl char[] displayName[32];
 *          Store_GetLoadoutDisplayName(loadouts[loadout], displayName, sizeof(displayName));
 *          
 *          PrintToServer(displayName);
 *      }
 *  }
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param filter            A trie which will be used to filter the loadouts returned.
 * @param callback		   	A callback which will be called when the items are loaded.
 * @param loadFromCache     Whether to load items from cache. If false, the method will 
 *                          query the database and rebuild its cache.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetLoadouts(Handle filter = INVALID_HANDLE, Store_GetItemsCallback callback = INVALID_FUNCTION, bool loadFromCache = true, any data = 0);

/**
 * Retrieves a loadout's display name by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all loadouts.
 * 
 * @param id                Category's ID.
 * @param displayName       Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetLoadoutDisplayName(int id, char[] displayName, int maxlength);

/**
 * Retrieves a loadout's game by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all loadouts.
 * 
 * @param id                Category's ID.
 * @param game              Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetLoadoutGame(int id, char[] game, int maxlength);

/**
 * Retrieves a loadout's class by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all loadouts.
 * 
 * @param id                Category's ID.
 * @param class             Buffer to store string in.
 * @param maxlength         Maximum length of string buffer.
 *
 * @noreturn
 */
native void Store_GetLoadoutClass(int id, char[] class, int maxlength);

/**
 * Retrieves a loadout's team by its ID.
 *
 * IMPORTANT  This method only works if the store-backend module has a cache
 * of all loadouts.
 * 
 * @param id                Category's ID.
 *
 * @return The loadout's team.
 */
native int Store_GetLoadoutTeam(int id);

/**
 * Retrieves a clients loadouts.
 * 
 * - If the player is already in the database, his name will be updated according
 *   to the 'name' parameter provided.
 *
 * - If the player is not in the database (for example, a new player who just joined
 *   the server for the first time), he will be added using the account ID and name 
 *   provided.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId			The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param callback		   	A callback which will be called when the loadouts are retrieved.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetClientLoadouts(int accountId, Store_GetUserLoadoutsCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Retrieves items of a specific player in a specific category. 
 *
 * To use this method, you can provide a callback for when the items are loaded.
 * The callback will provide an array of the items' IDs. You can then loop the array,
 * and find info about each item using the Store_GetItem* methods.
 * 
 * You can use the filter parameter to filter items returned by the following properties 
 *  - category_id (cell)
 *  - is_buyable (cell)
 *  - is_tradeable (cell)
 *  - is_refundable (cell)
 *  - type (string)
 *
 * To use it, set it to a trie with some or all of the above properties.
 * IMPORTANT  You are *not* resposible for closing the filter trie's handle, 
 *            the store-backend module is.
 *
 * The items returned by this method are grouped by the item's name. That means that 
 * if a player has multiple items with the same name (the unique identifier of the item, NOT its 
 * display name), then the array will only have one element of that item.
 *
 * To determine how many items the player has of the same name, the callback provides the
 * itemCount[] array.
 *
 * To deremine whether or not an item is equipped in the loadout specified, the callback
 * provides the equipped[] array.
 *
 * For example 
 *
 *	new Handle filter = CreateTrie();
 * 	SetTrieString(filter, "type", "equipment");
 *	SetTrieValue(filter, "is_refundable", 1); 
 *
 *  Store_GetUserItems(filter,
 *                      GetSteamAccountID(client), 
 *                      Store_GetClientLoadout(client), 
 *                      GetUserItemsCallback);
 *
 *  public GetUserItemsCallback(items, bool equipped, itemCount, count, loadoutId, any data)
 *  {
 *      PrintToServer("Player's Inventory");
 *       
 *      for (new item = 0; item < count; item++)
 *      {
 *          decl char[] displayName[32];
 *          Store_GetItemDisplayName(items[item], displayName, sizeof(displayName));
 *          
 *          PrintToServer("Item  %s, Equipped  %b, Count  %d", displayName, equipped[item], itemCount[item]);
 *      }
 *  }
 *
 * For a full example of a usage of this method, see the store-inventory module.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param filter			A trie which will be used to filter the loadouts returned.
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param loadoutId         The loadout which will be used to determine whether an item is equipped or not.
 * @param callback		    A callback which will be called when the items are loaded.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetUserItems(Handle filter, int accountId, int loadoutId, Store_GetUserItemsCallback callback, any data = 0);

/**
 * Retrieves the amount of the same item a user has.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param itemName          The name of the item.
 * @param callback		    A callback which will be called when the items are loaded.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetUserItemsCount(int accountId, const char[] itemName, Store_GetUserItemsCountCallback callback, any data = 0);

/**
 * Retrieves the amount of credits that a player currently has.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param callback		    A callback which will be called when the credits amount is loaded.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetCredits(int accountId, Store_GetCreditsCallback callback, any data = 0);

/**
 * Retrieves the amount of credits that a player currently has. (Difference between this and the normal native is this doesn't use function calls, just retrieves the amount)
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 *
 * @return Amount of credits.
 */
native int Store_GetCreditsEx(int accountId);

/**
 * Gives a player a specific amount of credits. 
 * 
 * You can also set the credits parameter to a negative value to take credits
 * from the player.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param credits           The amount of credits to give to the player.
 * @param callback		    A callback which will be called when the operation is finished.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GiveCredits(int accountId, int credits, Store_GiveCreditsCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Gives multiple players a specific amount of credits. 
 * 
 * You can also set the credits parameter to a negative value to take credits
 * from the players.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountIds	    The account IDs of the players, use GetSteamAccountID to convert a client index to account ID.
 * @param accountIdsLength  Players count.
 * @param credits           The amount of credits to give to the players.
 *
 * @noreturn
 */
native void Store_GiveCreditsToUsers(int[] accountIds, int accountIdsLength, int credits);

/**
 * Gives multiple players different amounts of credits. 
 * 
 * You can also set the credits parameter to a negative value to take credits
 * from the players.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountIds	    The account IDs of the players, use GetSteamAccountID to convert a client index to account ID.
 * @param accountIdsLength  Players count.
 * @param credits           Amount of credits per player. 
 *
 * @noreturn
 */
native void Store_GiveDifferentCreditsToUsers(int[] accountIds, int accountIdsLength, int[] credits);

/**
 * Removes a player a specific amount of credits. 
 * 
 * You can also set the credits parameter to a negative value to take credits
 * from the player.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param credits           The amount of credits to remove from the player.
 * @param callback		    A callback which will be called when the operation is finished.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_RemoveCredits(int accountId, int credits, Store_RemoveCreditsCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Removes multiple players a specific amount of credits. 
 * 
 * You can also set the credits parameter to a positive value to give credits
 * to the players.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountIds	    The account IDs of the players, use GetSteamAccountID to convert a client index to account ID.
 * @param accountIdsLength  Players count.
 * @param credits           The amount of credits to remove from the players.
 *
 * @noreturn
 */
native void Store_RemoveCreditsFromUsers(int[] accountIds, int[] accountIdsLength, int credits);

/**
 * Removes from multiple players different amounts of credits. 
 * 
 * You can also set the credits parameter to a positive value to give credits
 * to the players.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountIds	    The account IDs of the players, use GetSteamAccountID to convert a client index to account ID.
 * @param accountIdsLength  Players count.
 * @param credits           Amount of credits per player. 
 *
 * @noreturn
 */
native void Store_RemoveDifferentCreditsFromUsers(int[] accountIds, int[] accountIdsLength, int[] credits);

/**
 * Gives player an item.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param itemId 			The ID of the item to give to the player.
 * @param acquireMethod 		
 * @param callback		    A callback which will be called when the operation is finished.
 * @param plugin			The plugin owner of the callback.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GiveItem(int accountId, int itemId, Store_AcquireMethod acquireMethod = Store_Unknown, Store_AccountCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Buys an item for a player, using his credits.
 * 
 * To determine whether or not the process of buying that item was successful,
 * use the 'success' parameter that is provided by the callback.
 * A false value of that parameter probably means that the user didn't have enough credits.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param itemId            The ID of the item to buy.
 * @param callback		    A callback which will be called when the operation is finished.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_BuyItem(int accountId, int itemId, Store_BuyItemCallback callback, any data = 0);

/**
 * Removes one copy of an item from a player's inventory.
 * 
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param itemId            The ID of the item to use.
 * @param callback		    A callback which will be called when the operation is finished.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_RemoveUserItem(int accountId, int itemId, Store_UseItemCallback callback, any data = 0);

/**
 * Changes item equipped state in a specific loadout for a player.
 * 
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param itemId            The ID of the item to change equipped state to.
 * @param loadoutId         The loadout to equip the item in.
 * @param isEquipped		Whether or not the item is equipped in the specified loadout.
 * @param callback		    A callback which will be called when the operation is finished.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_SetItemEquippedState(int accountId, int itemId, int loadoutId, bool isEquipped, Store_EquipItemCallback callback, any data = 0);

/**
 * Retrieves equipped items of a specific player in a specific type. 
 *
 * To use this method, you can provide a callback for when the items are loaded.
 * The callback will provide an array of the items' IDs. You can then loop the array,
 * and find info about each item using the Store_GetItem* methods.
 * 
 * The items returned by this method are grouped by the item's name. That means that 
 * if a player has multiple items with the same name (the unique identifier of the item, NOT its 
 * display name), then the array will only have one element of that item.
 *
 * To determine how many items the player has of the same name, the callback provides the
 * itemCount[] array.
 *
 * To deremine whether or not an item is equipped in the loadout specified, the callback
 * provides the equipped[] array.
 *
 * For example 
 * 
 *  Store_GetUserItems(GetSteamAccountID(client), 
 *                      categoryId, 
 *                      Store_GetClientLoadout(client), 
 *                      GetUserItemsCallback);
 *
 *  public GetUserItemsCallback(items, bool equipped, itemCount, count, loadoutId, any data)
 *  {
 *      PrintToServer("Player's Inventory");
 *       
 *      for (new item = 0; item < count; item++)
 *      {
 *          decl char[] displayName[32];
 *          Store_GetItemDisplayName(items[item], displayName, sizeof(displayName));
 *          
 *          PrintToServer("Item  %s, Equipped  %b, Count  %d", displayName, equipped[item], itemCount[item]);
 *      }
 *  }
 *
 * For a full example of a usage of this method, see the store-inventory module.
 *
 * As with all other store-backend methods, this method is completely asynchronous.
 *
 * @param accountId		    The account ID of the player, use GetSteamAccountID to convert a client index to account ID.
 * @param type              The category of the items you want to retrieve.
 * @param loadoutId         The loadout which will be used to determine whether an item is equipped or not.
 * @param callback		    A callback which will be called when the items are loaded.
 * @param data              Extra data value to pass to the callback.
 *
 * @noreturn
 */
native void Store_GetEquippedItemsByType(int accountId, const char[] type, int loadoutId, Store_GetItemsCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Query the database for items and categories, so that the store-backend module will have a cache of them.
 *
 * @noreturn
 */
native void Store_ReloadCacheStacks();

/**
 * Queries the database and returns data to a callback. (Send SQL Queries to the Store database without creating a new connection in your plugin)
 *
 * @param sOriginal		String to escape.
 * @param sNew			String buffer to store escaped string in.
 * @param size			Size of the escaped string. (Should be (2 * size + 1))
 * @noreturn
 */
native void Store_SQLEscapeString(const char[] sOriginal, char[] sNew, int size);

/**
 * Process a ServerID & CategoryID to see if they're valid in the cache. (for category restrictions)
 *
 * @param ServerID		ServerID to check in the cache.
 * @param CategoryID	CategoryID to check in the cache.
 * @return	True if passed, false otherwise.
 */
native bool Store_ProcessCategory(int ServerID, int CategoryID);

/**
 * Process a ServerID & ItemID to see if they're valid in the cache. (for item restrictions)
 *
 * @param ServerID		ServerID to check in the cache.
 * @param ItemID		ItemID to check in the cache.
 * @return	True if passed, false otherwise.
 */
native bool Store_ProcessItem(int ServerID, int ItemID);

////////////////////
//Forwards

/**
 * Called when the database initializes successfully without errors.
 *
 * @noaction
 */
forward void Store_OnDatabaseInitialized();

/**
 * Called when the items cache is loaded pre. (No reason to make this an action... unless you want to mess up your store on purpose)
 *
 * @noaction
 */
forward void Store_OnReloadItems();

/**
 * Called when the items cache is loaded post.
 *
 * @noaction
 */
forward void Store_OnReloadItemsPost();

////////////////////
//Include Info

public SharedPlugin __pl_store_backend =
{
	name = "store-backend",
	file = "store-backend.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if defined REQUIRE_PLUGIN
public __pl_store_backend_SetNTVOptional()
{
	MarkNativeAsOptional("Store_ReloadCacheStacks");
	MarkNativeAsOptional("Store_RegisterPluginModule");
	
	MarkNativeAsOptional("Store_Register");
	MarkNativeAsOptional("Store_RegisterClient");
	MarkNativeAsOptional("Store_GetClientAccountID");
	MarkNativeAsOptional("Store_GetClientUserID");

	MarkNativeAsOptional("Store_GetCategories");
	MarkNativeAsOptional("Store_GetCategoryPriority");
	MarkNativeAsOptional("Store_GetCategoryDisplayName");
	MarkNativeAsOptional("Store_GetCategoryDescription");
	MarkNativeAsOptional("Store_GetCategoryPluginRequired");
	MarkNativeAsOptional("Store_GetCategoryServerRestriction");
	
	MarkNativeAsOptional("Store_GetItems");
	MarkNativeAsOptional("Store_GetItemPriority");
	MarkNativeAsOptional("Store_GetItemDisplayName");
	MarkNativeAsOptional("Store_GetItemDescription");
	MarkNativeAsOptional("Store_GetItemType");
	MarkNativeAsOptional("Store_GetItemLoadoutSlot");
	MarkNativeAsOptional("Store_GetItemPrice");
	MarkNativeAsOptional("Store_IsItemTradeable");
	MarkNativeAsOptional("Store_IsItemBuyable");
	MarkNativeAsOptional("Store_IsItemRefundable");	
	MarkNativeAsOptional("Store_GetItemAttributes");
	MarkNativeAsOptional("Store_WriteItemAttributes");
	MarkNativeAsOptional("Store_GetItemServerRestriction");

	MarkNativeAsOptional("Store_GetUserItems");
	MarkNativeAsOptional("Store_GetUserItemsCount");
	MarkNativeAsOptional("Store_GetCredits");
	MarkNativeAsOptional("Store_GetCreditsEx");
	
	MarkNativeAsOptional("Store_GiveCredits");
	MarkNativeAsOptional("Store_GiveCreditsToUsers");
	MarkNativeAsOptional("Store_GiveDifferentCreditsToUsers");
	MarkNativeAsOptional("Store_GiveItem");
	
	MarkNativeAsOptional("Store_RemoveCredits");
	MarkNativeAsOptional("Store_RemoveCreditsFromUsers");
	MarkNativeAsOptional("Store_RemoveDifferentCreditsFromUsers");

	MarkNativeAsOptional("Store_BuyItem");
	MarkNativeAsOptional("Store_RemoveUserItem");
	
	MarkNativeAsOptional("Store_SetItemEquippedState");
	MarkNativeAsOptional("Store_GetEquippedItemsByType");
	
	MarkNativeAsOptional("Store_SQLTQuery");
	MarkNativeAsOptional("Store_SQLEscapeString");
	
	MarkNativeAsOptional("Store_ProcessCategory");
	MarkNativeAsOptional("Store_ProcessItem");
}
#endif