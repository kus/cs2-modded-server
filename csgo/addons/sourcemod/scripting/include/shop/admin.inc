/**
 *	Called when an item from admin panel is being displayed
 *	-
 *	@param client			Client index an item is being shown to
 *	@param buffer			Buffer to store display name
 *	@param maxlength		Max length of the buffer
 *	-
 *	@noreturn
*/
functag public AdminDisplay(client, String:buffer[], maxlength);

/**
 *	Called when an item from admin panel is being selected
 *	-
 *	@param client			Client index performing selection
 *	-
 *	@return true to allow performing and false to block
*/
functag public bool:AdminSelect(client);

/**
 *	Adds an item to the admin panel
 *	-
 *	@param callback_display			Callback when the item is being shown. Set display name in the callback
 *	@param callback_select			Callback when the item is being selected
 *	-
 *	@noreturn
*/
native Shop_AddToAdminMenu(AdminDisplay:callback_display, AdminSelect:callback_select);

/**
 *	Removes an item from the admin panel
 *	-
 *	@param callback_display			Callback to remove
 *	@param callback_select			Callback to remove
 *	-
 *	@return true on success, false otherwise
*/
native bool:Shop_RemoveFromAdminMenu(AdminDisplay:callback_display, AdminSelect:callback_select);

/**
 *	Shows admin panel to a player
 *	-
 *	@param client			Client index to show to
 *	-
 *	@noreturn
*/
native Shop_ShowAdminMenu(client);