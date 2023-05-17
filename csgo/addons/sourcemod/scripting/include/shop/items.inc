/**
 *	Called when an item is being drawn
 *	-
 *	@param client			Client index an item is being drawn to
 *	@param menu_action		Menu performing this action
 *	@param category_id		Category id of an item
 *	@param item_id			Item id of an item
 *	@param disabled			Whether an item should be disabled of to be selected
 *	-
 *	@return Plugin_Changed to apply new values. >= Plugin_Handled to block an item to shown. Plugin_Continue otherwise
*/
forward Action:Shop_OnItemDraw(client, ShopMenu:menu_action, CategoryId:category_id, ItemId:item_id, &bool:disabled);

/**
 *	Called when an item is being displayd
 *	-
 *	@param client			Client index an item is being displayed to
 *	@param menu_action		Menu performing this action
 *	@param category_id		Category id of an item
 *	@param item_id			Item id of an item
 *	@param display			Display name being shown
 *	@param buffer			Buffer to store new display name
 *	@param maxlength		Max length of the buffer
 *	-
 *	@return true to apply new display name, false otherwise
*/
forward bool:Shop_OnItemDisplay(client, ShopMenu:menu_action, CategoryId:category_id, ItemId:item_id, const String:display[], String:buffer[], maxlength);

/**
 *	Called when an item's description is being displayd
 *	-
 *	@param client			Client index an item's description is being displayed to
 *	@param menu_action		Menu performing this action
 *	@param category_id		Category id of an item
 *	@param item_id			Item id of an item
 *	@param description		Description being shown
 *	@param buffer			Buffer to store new description
 *	@param maxlength		Max length of the buffer
 *	-
 *	@return true to apply new description, false otherwise
*/
forward bool:Shop_OnItemDescription(client, ShopMenu:menu_action, CategoryId:category_id, ItemId:item_id, const String:description[], String:buffer[], maxlength);

/**
 *	Called when an item is being bought
 *	-
 *	@param client			Client index that performing this
 *	@param category_id		Category id of an item
 *	@param category			Category unique name
 *	@param item_id			Item id of an item
 *	@param item				Item's unique name
 *	@param type				Item type
 *	@param price			Price of the item. Set by reference
 *	@param sell_price		Sell price of the item. Set by reference
 *	@param value			Count if the item is finite and duration if the item is togglable or non-togglable. Set by reference
 *	-
 *	@return Plugin_Changed to apply new values. >= Plugin_Handled to block. Plugin_Continue otherwise
*/
forward Action:Shop_OnItemBuy(client, CategoryId:category_id, const String:category[], ItemId:item_id, const String:item[], ItemType:type, &price, &sell_price, &value);

/**
 *	Called when an item is being bought
 *	-
 *	@param client			Client index that performing this
 *	@param category_id		Category id of an item
 *	@param category			Category unique name
 *	@param item_id			Item id of an item
 *	@param item				Item's unique name
 *	@param type				Item type
 *	@param sell_price		Sell price of the item. Set by reference
 *	-
 *	@return Plugin_Changed to apply new values. >= Plugin_Handled to block. Plugin_Continue otherwise
*/
forward Action:Shop_OnItemSell(client, CategoryId:category_id, const String:category[], ItemId:item_id, const String:item[], ItemType:type, &sell_price);

/**
 *	Called when an item has been toggled
 *	-
 *	@param client			Client index that performing this
 *	@param category_id		Category id of an item
 *	@param category			Category unique name
 *	@param item_id			Item id of an item
 *	@param item				Item's unique name
 *	@param toggle			State of the toggle. See ToggleState enum
 *	-
 *	@noreturn
*/
forward Shop_OnItemToggled(client, CategoryId:category_id, const String:category[], ItemId:item_id, const String:item[], ToggleState:toggle);

/**
 *	Called when an item has been elapsed
 *	-
 *	@param client			Client index whose item has been elapsed
 *	@param category_id		Category id of an item
 *	@param category			Category unique name
 *	@param item_id			Item id of an item
 *	@param item				Item's unique name
 *	-
 *	@noreturn
*/
forward Shop_OnItemElapsed(client, CategoryId:category_id, const String:category[], ItemId:item_id, const String:item[]);

/**
 *	Called when a player is transferring an item
 *	-
 *	@param client			Origin player
 *	@param target			Destination player
 *	@param item_id			Item id of an item
 *	-
 *	@return true to allow transfer and false to block
*/
forward bool:Shop_OnItemTransfer(client, target, ItemId:item_id);

/**
 *	Called when a player has transfered an item
 *	-
 *	@param client			Origin player
 *	@param target			Destination player
 *	@param item_id			Item id of an item
 *	-
 *	@noreturn
*/
forward Shop_OnItemTransfered(client, target, ItemId:item_id);

/**
 *	Gets an item custom info
 *	-
 *	@param item_id				Item id
 *	@param info					Info key to get
 *	@param defaultvalue			Optional default value to use if the key is not found
 *	-
 *	@return Integer value of the key
*/
native Shop_GetItemCustomInfo(ItemId:item_id, const String:info[], defaultvalue = 0);

/**
 *	Sets an item custom info
 *	-
 *	@param item_id				Item id
 *	@param info					Info key to set
 *	@param value				Value to set
 *	-
 *	@return true on success, false otherwise
*/
native bool:Shop_SetItemCustomInfo(ItemId:item_id, const String:info[], value);

/**
 *	Gets an item custom info
 *	-
 *	@param item_id				Item id
 *	@param info					Info key to get
 *	@param defaultvalue			Optional default value to use if the key is not found
 *	-
 *	@return Float value of the key
*/
native Float:Shop_GetItemCustomInfoFloat(ItemId:item_id, const String:info[], Float:defaultvalue = 0.0);

/**
 *	Sets an item custom info
 *	-
 *	@param item_id				Item id
 *	@param info					Info key to set
 *	@param value				Value to set
 *	-
 *	@return true on success, false otherwise
*/
native bool:Shop_SetItemCustomInfoFloat(ItemId:item_id, const String:info[], Float:value);

/**
 *	Gets an item custom info
 *	-
 *	@param item_id				Item id
 *	@param info					Info key to get
 *	@param buffer				Buffer to store the value in
 *	@param maxlength			Max length of the buffer
 *	@param defaultvalue			Optional default value to use if the key is not found
 *	-
 *	@return Number of bytes written
*/
native Shop_GetItemCustomInfoString(ItemId:item_id, const String:info[], String:buffer[], maxlength, const String:defaultvalue[] = "");

/**
 *	Sets an item custom info
 *	-
 *	@param item_id				Item id
 *	@param info					Info key to set
 *	@param value				Value to set
 *	-
 *	@return true on success, false otherwise
*/
native bool:Shop_SetItemCustomInfoString(ItemId:item_id, const String:info[], const String:value[]);

/**
 *	Copies SubKeys of a KeyValue structure to the item info
 *	-
 *	@param item_id				Item id
 *	@param kv					KeyValue structure to copy
 *	-
 *	@return true on success, false otherwise
*/
native bool:Shop_KvCopySubKeysItemCustomInfo(ItemId:item_id, Handle:kv);

/**
 *	Gets an item price
 *	-
 *	@param item_id				Item id
 *	-
 *	@return Price of the item
*/
native Shop_GetItemPrice(ItemId:item_id);

/**
 *	Sets an item price
 *	-
 *	@param item_id				Item id
 *	@param price				Price to set
 *	-
 *	@noreturn
*/
native Shop_SetItemPrice(ItemId:item_id, price);

/**
 *	Gets an item sell price
 *	-
 *	@param item_id				Item id
 *	-
 *	@return Sell price of the item
*/
native Shop_GetItemSellPrice(ItemId:item_id);

/**
 *	Sets an item sell price
 *	-
 *	@param item_id				Item id
 *	@param sell_price			Sell price to set
 *	-
 *	@noreturn
*/
native Shop_SetItemSellPrice(ItemId:item_id, sell_price);

/**
 *	Gets an item count if item is finite and duration if item is togglable or non-togglable (-1 if duration is unlimited)
 *	-
 *	@param item_id				Item id
 *	-
 *	@return Value of the item id
*/
native Shop_GetItemValue(ItemId:item_id);

/**
 *	Sets an item count if item is finite and duration if item is togglable or non-togglable (-1 unlimited)
 *	-
 *	@param item_id				Item id
 *	-
 *	@noreturn
*/
native Shop_SetItemValue(ItemId:item_id, value);

/**
 *	Whether the item is exists (registered)
 *	-
 *	@param item_id				Item id
 *	-
 *	@return True if item is exists, false otherwise
*/
native bool:Shop_IsItemExists(ItemId:item_id);

/**
 *	Whether the category is valid (registered)
 *	-
 *	@param category_id				Category id
 *	-
 *	@return True if item is exists, false otherwise
*/
native bool:Shop_IsValidCategory(CategoryId:category_id);

/**
 *	Gets item id of the item unique name
 *	-
 *	@param category_id				Category id where the item is registered
 *	@param item						Item unique name to get for
 *	-
 *	@return Item id of the item
*/
native ItemId:Shop_GetItemId(CategoryId:category_id, const String:item[]);

/**
 *	Gets the item unique name by its id
 *	-
 *	@param item_id				Item id to get for
 *	@param buffer				Buffer to store the unique name
 *	@param maxlength			Max length of the buffer
 *	-
 *	@return Number of bytes written
*/
native Shop_GetItemById(ItemId:item_id, String:buffer[], maxlength);

/**
 *	Gets the item's category id
 *	-
 *	@param item_id				Item id to get category id from
 *	-
 *	@return Category id or INVALID_CATEGORY if category is not set or item id is invalid
*/
native CategoryId:Shop_GetItemCategoryId(ItemId:item_id);

/**
 *	Gets category id of the category unique name
 *	-
 *	@param category				Category unique name to get id for
 *	-
 *	@return Category id of the category
*/
native CategoryId:Shop_GetCategoryId(const String:category[]);

/**
 *	Gets the category unique name by its id
 *	-
 *	@param category_id			Category id to get for
 *	@param buffer				Buffer to store the unique name
 *	@param maxlength			Max length of the buffer
 *	-
 *	@return True on success, false otherwise
*/
native bool:Shop_GetCategoryById(CategoryId:category_id, String:buffer[], maxlength);

/**
 *	Fills an adt_array by the item ids. Note that array is cleared before being filled
 *	-
 *	@param array			ADT array to use
 *	-
 *	@noreturn
*/
native Shop_FillArrayByItems(Handle:array);

/**
 *	Formats item display name to use in menu
 *	-
 *	@param client			Client index to get format for
 *	@param item_id			Item id to format
 *	@param menu				Menu to get formatted for
 *	@param buffer			Buffer to store the result in
 *	@param maxlength		Max length of the buffer
 *	-
 *	@return True if item formatted, false if param menu is Menu_Inventory and the player has not this item and the item is not formatted
*/
native bool:Shop_FormatItem(client, ItemId:item_id, ShopMenu:menu, String:buffer[], maxlength);

/**
 *	Creates and ADT array of item ids
 *	-
 *	@param size			Optional param to store array size
 *	-
 *	@return Handle of the array
*/
stock Handle:Shop_CreateArrayOfItems(&size = 0)
{
	new Handle:_shop_array = CreateArray();
	size = Shop_FillArrayByItems(_shop_array);
	return _shop_array;
}

/**
 *	Retrieves an item id from an array
 *	-
 *	@param array			Array handle
 *	@param index			Index in the array
 *	-
 *	@return Item id
*/
stock ItemId:Shop_GetArrayItem(Handle:array, index)
{
	return ItemId:GetArrayCell(array, index);
}

/**
 *	Gets array size
 *	-
 *	@param array			Array handle
 *	-
 *	@return Size of the array
*/
stock Shop_GetArrayItemSize(Handle:array)
{
	return GetArraySize(array);
}