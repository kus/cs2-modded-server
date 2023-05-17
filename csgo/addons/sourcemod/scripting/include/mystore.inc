
#if defined _mystore_included
	#endinput
#endif
#define _mystore_included_

public SharedPlugin __pl_mystore =
{
	name = "mystore",
	file = "mystore.smx",

#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};


#if !defined REQUIRE_PLUGIN
public void __pl_mystore_SetNTVOptional()
{
	MarkNativeAsOptional("MyStore_RegisterHandler");
	MarkNativeAsOptional("MyStore_RegisterItemHandler");
	MarkNativeAsOptional("MyStore_SetDataIndex");
	MarkNativeAsOptional("MyStore_GetDataIndex");
	MarkNativeAsOptional("MyStore_GetEquippedItem");
	MarkNativeAsOptional("MyStore_IsClientLoaded");
	MarkNativeAsOptional("MyStore_DisplayItemMenu");
	MarkNativeAsOptional("MyStore_DisplayPreviousMenu");
	MarkNativeAsOptional("MyStore_SetClientPreviousMenu");
	MarkNativeAsOptional("MyStore_GetClientCredits");
	MarkNativeAsOptional("MyStore_SetClientCredits");
	MarkNativeAsOptional("MyStore_IsClientVIP");
	MarkNativeAsOptional("MyStore_IsClientAdmin");
	MarkNativeAsOptional("MyStore_HasClientAccess");
	MarkNativeAsOptional("MyStore_IsItemInBoughtPackage");
	MarkNativeAsOptional("MyStore_DisplayConfirmMenu");
	MarkNativeAsOptional("MyStore_ShouldConfirm");
	MarkNativeAsOptional("MyStore_IsInRecurringMenu");
	MarkNativeAsOptional("MyStore_SetClientRecurringMenu");
	MarkNativeAsOptional("MyStore_GetItemIdbyUniqueId");
	MarkNativeAsOptional("MyStore_GetItem");
	MarkNativeAsOptional("MyStore_GetHandler");
	MarkNativeAsOptional("MyStore_GiveItem");
	MarkNativeAsOptional("MyStore_RemoveItem");
	MarkNativeAsOptional("MyStore_EquipItem");
	MarkNativeAsOptional("MyStore_UnequipItem");
	MarkNativeAsOptional("MyStore_GetClientItem");
	MarkNativeAsOptional("MyStore_GetClientTarget");
	MarkNativeAsOptional("MyStore_TransferClientItem");
	MarkNativeAsOptional("MyStore_SellClientItem");
	MarkNativeAsOptional("MyStore_HasClientItem");
	MarkNativeAsOptional("MyStore_IterateEquippedItems");
	MarkNativeAsOptional("MyStore_SQLQuery");
	MarkNativeAsOptional("MyStore_SQLTransaction");
}
#endif

#define ITEM_NAME_LENGTH 64
#define STORE_MAX_ITEMS 2048
#define STORE_MAX_TYPES 72
#define STORE_MAX_ITEM_HANDLERS 8
#define STORE_MAX_PLANS 8
#define STORE_MAX_SLOTS 5

#define MENU_ADMIN 0
#define MENU_STORE 1
#define MENU_ITEM 2
#define MENU_PREVIEW 3
#define MENU_RESET 4
#define MENU_PLAN 5
#define MENU_PARENT 6

#define LOG_ERROR 0
#define LOG_CREDITS 1
#define LOG_ADMIN 2
#define LOG_EVENT 3

#define ITEM_EQUIP_FAIL 1
#define ITEM_EQUIP_KEEP 1
#define ITEM_EQUIP_REMOVE 0
#define ITEM_EQUIP_SUCCESS -1

#define UNIQUE_ID 0
#define DATE_PURCHASE 1
#define DATE_EXPIRATION 2
#define PRICE_PURCHASE 3
#define DELETED 4
#define SYNCED 5
#define CLIENT_ITEM_SIZE 6


enum Item_Data
{
	String:szName[ITEM_NAME_LENGTH],
	String:szUniqueId[PLATFORM_MAX_PATH],
	String:szShortcut[64],
	String:szDescription[64],
	String:szSteam[256],

	iId,
	iPrice,
	iParent,
	iHandler,
	iFlagBits,
	iDataIndex,
	iPlans,

	bool:bPreview,
	bool:bBuyable,
	bool:bIgnoreVIP,

	StringMap:hAttributes
}

enum Type_Handler
{
	String:szType[64],
	
	bool:bEquipable,
	bool:bRaw,
	
	Handle:hPlugin,
	
	Function:fnMapStart,
	Function:fnReset,
	Function:fnConfig,
	Function:fnUse,
	Function:fnRemove
}

/**
 * Register a item type (plugin) to the core.
 *
 * @param type			Type of item.
 * @param mapstart		Optional function to call on store mapstart.
 * @param reset			Optional function to call for reset items.
 * @param config		Optional function to call for add item configs.
 * @param use			Function to call for use/equip item.
 * @param remove		Optional function to call for remove/unequip item.
 * @param equipable		Optional if set to true, the item is equipable.
 * @param raw			Optional if set to true, type will be "only a menu entry".
 *						Shows no menu item like use or equip.
 * 
 * @return				-1 if failed to add (reached STORE_MAX_HANDLERS)
 *						else the index of this typehandler.
 */
native int MyStore_RegisterHandler(char[] type, StoreMapStart mapstart = INVALID_FUNCTION, StoreItemReset reset = INVALID_FUNCTION, StoreItemConfig config = INVALID_FUNCTION, StoreItemUse use = INVALID_FUNCTION, StoreItemRemove remove = INVALID_FUNCTION, bool equipable = true, bool raw = false);

/**
 * Register a item handler (plugin) to the core.
 *
 * @param identifier	Identifier for this handler.
 * @param menu			Function to call on display item menu.
 * @param handler		Function to call on select item handler.
 * 
 * @return				-1 if failed to add (reached STORE_MAX_HANDLERS)
 *						else the index of this itemhandler.
 */
native int MyStore_RegisterItemHandler(char[] identifier, StoreItemMenu menu, StoreItemMenuHandler handler);

/**
 * Set the DataIndex of a item.
 *
 * @param itemid		ID of the item.
 * @param index			DataIndex of the item.
 * 
 * @noreturn
 */
native void MyStore_SetDataIndex(int itemid, int index);

/**
 * Get the DataIndex of a item.
 *
 * @param itemid		ID of the selected item.
 * 
 * @return				DataIndex of the item.
 */
native int MyStore_GetDataIndex(int itemid);

/**
 * Get clients equipt item.
 *
 * @param client		Index of client.
 * @param type			Type of the item.
 * @param slot			Optional slot of the item.
 * 
 * @return				ID of the item.
 */
native int MyStore_GetEquippedItem(int client, char[] type, int slot = 0);

/**
 * Check client for vip flag "mystore_vip_flag"
 *
 * @param client		Index of client.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_IsClientVIP(int client);

/**
 * Check client for admin flag "mystore_admin_flag"
 *
 * @param client		Index of client.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_IsClientAdmin(int client);

/**
 * Check client for access flag "mystore_access_flag"
 *
 * @param client		Index of client.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_HasClientAccess(int client);

/**
 * Check if client data is loaded from database
 *
 * @param client		Index of client.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_IsClientLoaded(int client);

/**
 * Check if a comfirm is required "mystore_confirm"
 * 
 * @return				True for comfirm, otherwise false.
 */
native bool MyStore_ShouldConfirm();

/**
 * Display the comfirm window to a client.
 * 
 * @param client		Index of client.
 * @param title			Title of the comfirm window.
 * @param callback		Function to call on postive comfirm.
 * @param data			Data to pass through menus.
 * 
 * @noreturn
 */
native void MyStore_DisplayConfirmMenu(int client, char[] title, StoreConfirmMenu callback, int data);

/**
 * Display the a given item to a client.
 * 
 * @param client		Index of client.
 * @param itemid		ID of the item.
 * 
 * @noreturn
 */
native void MyStore_DisplayItemMenu(int client, int itemid);

/**
 * Display the previous menu window to a client.
 * 
 * @param client		Index of client.
 * 
 * @noreturn
 */
native void MyStore_DisplayPreviousMenu(int client);

/**
 * Set the menu nummer as previous menu for a client.
 * 
 * @param client		Index of client.
 * @param num			Nummer of menu.
 * 						MENU_ADMIN
 * 						MENU_STORE
 * 						MENU_ITEM
 * 						MENU_PREVIEW
 * 						MENU_RESET
 * 						MENU_PLAN
  						MENU_PARENT
 *
 * @noreturn
 */
native void MyStore_SetClientPreviousMenu(int client, int num);

/**
 * Check if player is in a recurring menu. (most likely gambling)
 *
 * @param client		Index of client.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_IsInRecurringMenu(int client);

/**
 * Set if player is in a recurring menu.
 *
 * @param client		Index of client.
 * @param active		True is in menu, otherwise false.
 * 
 * @noreturn
 */
native void MyStore_SetClientRecurringMenu(int client, bool active);

/**
 * Get clients credits.
 *
 * @param client		Index of client.
 * 
 * @return				Amount of credits.
 */
native int MyStore_GetClientCredits(int client);

/**
 * Set clients credits.
 *
 * @param client		Index of client.
 * @param credits		Amount of credits.
 * @param reason		Optional reason for changed credits.
 * 
 * @noreturn
 */
native void MyStore_SetClientCredits(int client, int credits, char[] reason = "External plugin");

/**
 * Check if client has a item
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_HasClientItem(int client, int itemid);

/**
 * Check if client has a item
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 * @param uid			Optional ID of the package.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_IsItemInBoughtPackage(int client, int itemid, int uid = -1);

/**
 * Get item data.
 *
 * @param itemid		ID of the item.
 * @param output		Buffer to store item data.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_GetItem(int itemid, int output[Item_Data]);

/**
 * Get item data.
 *
 * @param unique_id		Unique indentfy sting.
 * 
 * @return				The item ID, -1 on false.
 */
native int MyStore_GetItemIdbyUniqueId(char[] unique_id);

/**
 * Get type data.
 *
 * @param index			Index of the type.
 * @param output		Buffer to store type data.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_GetHandler(int index, int output[Type_Handler]);

/**
 * Give a client a item.
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 * @param purchase		Optional date of purchase.
 * @param expiration	Optional date of expiration.
 * @param price			Optional price of purchase.
 * 
 * @noreturn
 */
native void MyStore_GiveItem(int client, int itemid, int purchase = 0, int expiration = 0, int price = 0);

/**
 * Unequip & removes a client a item.
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 *
 * @noreturn
 */
native void MyStore_RemoveItem(int client, int itemid);

/**
 * Equip a client a item.
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 *
 * @noreturn
 */
native void MyStore_EquipItem(int client, int itemid);

/**
 * Unequip a client a item.
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 *
 * @noreturn
 */
native void MyStore_UnequipItem(int client, int itemid);

/**
 * Unequip a client a item.
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 * @param ratio			Ratio of price of pruchase to recieve.
 *
 * @return				True for success, otherwise false.
 */
native bool MyStore_SellClientItem(int client, int itemid, float ratio);

/**
 * Transfers a item safe from one client to another.
 *
 * @param client		Index of sender.
 * @param recipient		Index of recipient.
 * @param itemid		ID of the item.
 *
 * @return				True for success,
 *						false when sender don't own item
 *						or itemid is invalid.
 */
native bool MyStore_TransferClientItem(int client, int recipient, int itemid);

/**
 * Get a clients item data.
 *
 * @param client		Index of client.
 * @param itemid		ID of the item.
 * @param output		Buffer to store client item data.
 * 
 * @return				True for success, otherwise false.
 */
native bool MyStore_GetClientItem(int client, int itemid, int output[6]);

/**
 * Get a clients target.
 *
 * @param client		Index of client.
 * 
 * @return				Index of target client.
 */
native int MyStore_GetClientTarget(int client);

/**
 * Iterate throuh all equipped items of a client.
 *
 * @param client		Index of client.
 * @param start			Start Index of client equipt items (value increases through iterate).
 * @param attributes	Only return items with attribues.
 *
 * @return				Itemid if the item
 */
native int MyStore_IterateEquippedItems(int client, int &start, bool attributes = false);

/**
 * Iterate throuh all equipped items of a client.
 *
 * @param tnx			Transaction to query
 * @param callback		Callback to recieve answer from db
 * @param data			data to pass to callback
 *
 * @return				-1 if db is not connected else 1
 */
native int MyStore_SQLTransaction(Transaction tnx, SQLTxnSuccess callback, any data);

/**
 * Iterate throuh all equipped items of a client.
 *
 * @param query			Query to send to db
 * @param callback		Callback to recieve answer from db
 * @param data			data to pass to callback
 *
 * @return				-1 if db is not connected else 1
 */
native int MyStore_SQLQuery(char[] query, SQLQueryCallback callback, any data);

/**
 * Iterate throuh all equipped items of a client.
 *
 * @param client		Client triggered logging event
 * @param callback		Message to log
 * @param data			Log Level
 * 						LOG_ERROR
 * 						LOG_CREDITS
 * 						LOG_ADMIN
 * 						LOG_EVENT
 *
 * @noreturn
 */
native void MyStore_LogMessage(int client = 0, int level, char[] message, any ...);




/**
 * Called when a item price is queried.
 * Best place to change item price.
 *
 * @param client		Index of client.
 * @param itemid		ID of the selected item.
 * @param price			Price of the item.
 * 
 * @return				Plugin_Continue for pass.
 *						Plugin_Changed to indicate reduced price.
 */
forward Action MyStore_OnGetEndPrice(int client, int itemid, int &price);

/**
 * Called before a item is bought by a client.
 * Best place to restrict buying a item.
 *
 * @param client		Index of client.
 * @param itemid		ID of the selected item.
 * @param price			Price before MyStore_OnGetEndPrice().
 * @param costs			Costs after MyStore_OnGetEndPrice().
 * 
 * @return				Plugin_Continue for pass.
 *						Plugin_Handled for decline.
 */
forward Action MyStore_OnBuyItem(int client, int itemid, int price, int &costs);

/**
 * Called after a client use/equipt a item.
 *
 * @param client		Index of client.
 * @param itemid		ID of the selected item.
 * 
 * @noreturn
 */
forward void MyStore_OnItemEquipt(int client, int itemid);

/**
 * Called when a client preview a item.
 *
 * @param enable		Convar to handle "mystore_enable".
 * @param name			Name of the store "mystore_name".
 * @param prefix		Chat prefix of store "mystore_chat_tag".
 * @param credits		Name of the store credits "mystore_credits_name".
 * 
 * @noreturn
 */
forward void MyStore_OnConfigExecuted(ConVar enable, char[] name, char[] prefix, char[] credits);

/**
 * Called when a client preview a item.
 *
 * @param client		Index of client.
 * @param type			Type of item.
 * @param index			DataIndex of item.
 * 
 * @noreturn
 */
forward void MyStore_OnPreviewItem(int client, char[] type, int index);




/**
 * Called when DisplayConfirmMenu return as comfirmed.
 *
 * @param &menu			INVALID_HANDLE / null when comfirmed.
 * @param action		Optionally set which actions to receive.  Select, 
 *						Cancel, and End will always be received regardless
 *						of whether they are set or not.  They are also
 *						the only default actions.
 * @param client		Index of client who called DisplayConfirmMenu.
 * @param data			values passed throught confirm menu.
 * 
 * @noreturn
 */
typedef StoreConfirmMenu = function void (Menu menu, MenuAction action, int client, int data);

/**
 * Called when stores OnMapStart() is fired.
 * 
 * @noreturn
 */
typedef StoreMapStart = function void ();

/**
 * Called before store (re)load the items configs.
 * 
 * @noreturn
 */
typedef StoreItemReset = function void ();

/**
 * Called when store go through the items configs to register items.
 *
 * @param &kv			KeyValues handle to read config file.
 * @param itemid		ID of the actual item in the list.
 * 
 * @return 				True for success, otherwise false.
 */
typedef StoreItemConfig = function bool (KeyValues &kv, int itemid);

/**
 * Function types for item use.
 */
typeset StoreItemUse
{
	/**
	 * Called when store item is selected to use/equip.
	 *
	 * @param client		Index of client to use/equip the item.
	 * @param itemid		ID of the selected item.
	 * 
	 * @return 				True for success, otherwise false.
	 */
	function int (int client, int itemid);

	/**
	 * Called when selected store item is a raw item.
	 *
	 * @param client		Index of client to use the item.
	 * @param itemid		ID of the selected item.
	 * 
	 * @noreturn
	 */
	function void (int client, int itemid);
}

/**
 * Function types for remove/unequip item.
 */
typeset StoreItemRemove
{
	/**
	 * Called when store item is selected to unequip.
	 *
	 * @param client		Index of client to unequip the item.
	 * @param itemid		ID of the selected item.
	 * 
	 * @return 				Slot of the item, otherwise ITEM_EQUIP_REMOVE.
	 */
	function int (int client, int itemid);

	/**
	 * Called when store item is removed by native.
	 *
	 * @param client		Index of client to unequip the item.
	 * @param itemid		ID of the selected item.
	 * 
	 * @noreturn
	 */
	function void (int client, int itemid);
}

/**
 * Called before store item is displayed.
 *
 * @param &menu			Menu handle to insert menu items.
 * @param client		Index of client to display menu.
 * @param itemid		ID of the selected item.
 * 
 * @return 				True for success, otherwise false.
 */
typedef StoreItemMenu = function void (Menu &menu, int client, int itemid);

/**
 * Called when item handler is selected.
 *
 * @param &menu			Menu handle to insert menu items.
 * @param client		Index of client to display menu.
 * @param itemid		ID of the selected item.
 * 
 * @return 				True for success, otherwise false.
 */
typedef StoreItemMenuHandler = function bool (int client, char[] selection, int itemid);