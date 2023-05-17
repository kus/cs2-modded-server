/**
 *	Called when an item from functions menu is being displayed
 *	-
 *	@param client			Client index an item is being shown to
 *	@param buffer			Buffer to store display name
 *	@param maxlength		Max length of the buffer
 *	-
 *	@noreturn
*/
functag public FuncDisplay(client, String:buffer[], maxlength);

/**
 *	Called when an item from functions menu is being selected
 *	-
 *	@param client			Client index performing selection
 *	-
 *	@return true to allow performing and false to block
*/
functag public bool:FuncSelect(client);

/**
 *	Adds an item to the functions menu
 *	-
 *	@param callback_display			Callback when the item is being shown. Set display name in the callback
 *	@param callback_select			Callback when the item is being selected
 *	-
 *	@noreturn
*/
native Shop_AddToFunctionsMenu(FuncDisplay:callback_display, FuncSelect:callback_select);

/**
 *	Removes an item from the functions menu
 *	-
 *	@param callback_display			Callback to remove
 *	@param callback_select			Callback to remove
 *	-
 *	@return true on success, false otherwise
*/
native bool:Shop_RemoveFromFunctionsMenu(FuncDisplay:callback_display, FuncSelect:callback_select);

/**
 *	Shows functions menu to a player
 *	-
 *	@param client			Client index to show to
 *	-
 *	@noreturn
*/
native Shop_ShowFunctionsMenu(client);