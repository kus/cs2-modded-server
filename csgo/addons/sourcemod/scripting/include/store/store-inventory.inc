#if defined _store_inventory_included
#endinput
#endif
#define _store_inventory_included

//Globals
enum Store_ItemUseAction
{
	Store_EquipItem, 
	Store_UnequipItem, 
	Store_DeleteItem, 
	Store_DoNothing
}

//Prototypes
typedef Store_ItemUseCallback = function Store_ItemUseAction(int client, int itemId, bool equipped);

/**
 * Opens the inventory menu for a client.
 *
 * @param client			Client index.
 *
 * @noreturn
 */
native void Store_OpenInventory(int client);

/**
 * Opens the inventory menu for a client in a specific category.
 *
 * @param client			Client index.
 * @param categoryId		The category that you want to open.
 *
 * @noreturn
 */
native void Store_OpenInventoryCategory(int client, int categoryId);

/**
 * Registers an item type. 
 *
 * A type of an item defines its behaviour. Once you register a type, 
 * the store will provide two callbacks for you:
 * 	- Use callback: called when a player selects your item in his inventory.
 *	- Attributes callback: called when the store loads the attributes of your item (optional).
 *
 * It is recommended that each plugin registers *one* item type. 
 *
 * @param type			Item type unique identifer - maximum 32 characters, no whitespaces, lower case only.
 * @param useCallback	Called when a player selects your item in his inventory.
 * @param attrsCallback	Called when the store loads the attributes of your item.
 *
 * @noreturn
 */
native void Store_RegisterItemType(const char[] type, Store_ItemUseCallback useCallback, Store_ItemGetAttributesCallback attrsCallback = INVALID_FUNCTION);

/**
 * Determines whether or not a specific item type string is registered.
 *
 * @param type			Item type unique identifer.
 *
 * @return True if registered, false otherwise.
 */
native bool Store_IsItemTypeRegistered(const char[] type);

/**
 * Calls item type's attributes callback.
 *
 * This method is designed for store-database, that loads attributes from the database.
 * It shouldn't be used anywhere else.
 *
 * @param type			Item type unique identifer.
 * @param itemName
 * @param attrs
 *
 * @return True if successful, false otherwise.
 */
native bool Store_CallItemAttrsCallback(const char[] type, const char[] itemName, const char[] attrs);

public SharedPlugin __pl_store_inventory = 
{
	name = "store-inventory", 
	file = "store-inventory.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if defined REQUIRE_PLUGIN
public __pl_store_inventory_SetNTVOptional()
{
	MarkNativeAsOptional("Store_OpenInventory");
	MarkNativeAsOptional("Store_OpenInventoryCategory");
	
	MarkNativeAsOptional("Store_RegisterItemType");
	MarkNativeAsOptional("Store_IsItemTypeRegistered");
	
	MarkNativeAsOptional("Store_CallItemAttrsCallback");
}
#endif