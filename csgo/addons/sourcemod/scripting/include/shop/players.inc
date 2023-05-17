/**
 *	Gets a player's id for the database
 *	-
 *	@param client			Client index to get for
 *	-
 *	@return player id in the database
*/
native Shop_GetClientId(client);

/**
 *	Sets timeleft for an item. 0 to set no timelimit
 *	-
 *	@param client			Client index to set to
 *	@param item_id		Item id to set for
 *	@param timeleft		Timeleft to set. 0 to make it forever
 *	-
 *	@return True on success and false it client has not this item
*/
native bool:Shop_SetClientItemTimeleft(client, ItemId:item_id, timeleft);

/**
 *	Gets timeleft for an item
 *	-
 *	@param client			Client index to get from
 *	@param item_id		Item id to get for
 *	-
 *	@return item timeleft in seconds. 0 if item has no timelimit
*/
native Shop_GetClientItemTimeleft(client, ItemId:item_id);

/**
 *	Gets an absolute sell price for an item a player hold
 *	-
 *	@param client			Client index to get from
 *	@param item_id		Item id to get for
 *	-
 *	@return sell price of the item
*/
native Shop_GetClientItemSellPrice(client, ItemId:item_id);

/**
 *	Whether a player has toggled on an item
 *	-
 *	@param client			Client index to check to
 *	@param item_id		Item id to check
 *	-
 *	@return true if player has item toggled on and false otherwise
*/
native bool:Shop_IsClientItemToggled(client, ItemId:item_id);

/**
 *	Whether a player has an item
 *	-
 *	@param client			Client index to check to
 *	@param item_id		Item id to check
 *	-
 *	@return true if player has item and false otherwise
*/
native bool:Shop_IsClientHasItem(client, ItemId:item_id);

/**
 *	Toggles a client's item
 *	-
 *	@param client			Client index
 *	@param item_id		Item id to toggle
 *	@param toggle		Toggle state. See ToggleState enum
 *	-
 *	@return true on success and false otherwise
*/
native bool:Shop_ToggleClientItem(client, ItemId:item_id, ToggleState:toggle = Toggle);

/**
 *	Toggles all items of category off
 *	-
 *	@param client			Client index
 *	@param category_id		The category id
 *	-
 *	@noreturn
*/
native Shop_ToggleClientCategoryOff(client, CategoryId:category_id);

/**
 *	Checks whether the player has been loaded from database
 *	-
 *	@param client	Client index to check
 *	-
	@return	True if the player loaded, false otherwise
*/
native bool:Shop_IsAuthorized(client);

/**
 *	Checks whether a player has access to admin panel
 *	-
 *	@param client	Client index to check
 *	-
	@return	True if the player has access, false otherwise
*/
native bool:Shop_IsAdmin(client);

/**
 *	Gives certain amount of credits to the player
 *	-
 *	@param client			Client index
 *	@param amount			Amount to give
 *	@param by_who			Optional param to set by who the credits being given from
 *	-
 *	@return	New amount of credits
*/
native Shop_GiveClientCredits(client, amount, by_who = CREDITS_BY_NATIVE);

/**
 *	Takes certain amount of credits from the player
 *	-
 *	@param client			Client index
 *	@param amount			Amount to take
 *	@param by_who			Optional param to set by who the credits being given from
 *	-
 *	@return	New amount of credits
*/
native Shop_TakeClientCredits(client, amount, by_who = CREDITS_BY_NATIVE);

/**
 *	Gets the amount of credits of the player
 *	-
 *	@param client			Client index
 *	-
 *	@return	Amount of credits a player has, -1 on failure
*/
native Shop_GetClientCredits(client);

/**
 *	Sets the amount of credits to the player
 *	-
 *	@param client			Client index
 *	@param credits			Amount of credits to set
 *	-
 *	@noreturn
*/
native Shop_SetClientCredits(client, credits);

/**
 *	Forces the player to buy the item from the shop
 *	-
 *	@param client			Client index
 *	@param item_id			The item id
 *	-
 *	@return	True if the player successfuly bought, false otherwise
*/
native bool:Shop_BuyClientItem(client, ItemId:item_id);

/**
 *	Remove the item from the player's inventory
 *	-
 *	@param client			Client index
 *	@param item_id			The item id
 *	@param count			Number of count to remove
 *	-
 *	@return	True on success, false otherwise
*/
native bool:Shop_RemoveClientItem(client, ItemId:item_id, count = 0);

/**
 *	Get's count of an item a player has
 *	-
 *	@param client			Client index
 *	@param item_id			The item id
 *	-
 *	@return	True on success, false otherwise
*/
native Shop_GetClientItemCount(client, ItemId:item_id);

/**
 *	Forces a player to use an item
 *	-
 *	@param client			Client index to force to
 *	@param item_id		Item id to force for
 *	-
 *	@return true on success and false otherwise
*/
native bool:Shop_UseClientItem(client, ItemId:item_id);