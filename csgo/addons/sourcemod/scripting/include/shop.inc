/*
	Library of the [Shop] Core v2
	Author: FrozDark
	www.hlmod.ru
*/

#if defined _shop_included
 #endinput
#endif
#define _shop_included

#define SHOP_VERSION	"2.0.22"
#define SHOP_MAX_STRING_LENGTH 64

enum CategoryId
{
	INVALID_CATEGORY = -1
}

enum ItemId
{
	INVALID_ITEM = 0
}

enum ItemType
{
	Item_None = 0,		/**< Can not be used */
	Item_Finite = 1,	/**< Can be used like a medkit */
	Item_Togglable = 2,	/**< Can be switched on or off */
	Item_BuyOnly = 3	/**< Only for buy */
}

enum ToggleState
{
	Toggle,
	Toggle_On,
	Toggle_Off
}

enum ShopAction
{
	Shop_Raw = 0,
	Shop_UseOn = 1,
	Shop_UseOff = 2
}

enum ShopMenu
{
	Menu_Main,
	Menu_Buy,
	Menu_Inventory,
	Menu_Functions,
	Menu_AdditionalFunctions,
	Menu_AdminPanel,
	Menu_CreditsTransfer,
	Menu_ItemTransfer
}

#define	IGNORE_FORWARD_HOOK	-5				//**< Param to set to avoid calling forward hook */
#define	CREDITS_BY_LUCK	-4					//**< Credits being processed by item luck */
#define	CREDITS_BY_TRANSFER	-3				//**< Credits being processed by credits transfer */
#define	CREDITS_BY_BUY_OR_SELL	-2			//**< Credits being processed by buying or selling an item */
#define	CREDITS_BY_NATIVE	-1				//**< Credits being processed by native */
#define	CREDITS_BY_COMMAND	0				//**< Credits being processed by server console or rcon command */
//**< Any higher value is admin index */

#include <shop/admin>
#include <shop/functions>
#include <shop/db>
#include <shop/items>
#include <shop/players>
#include <shop/register>

/**
 *	Called when the shop is ready to register items
 *	-
 *	@noparams
 *	-
 *	@noreturn
*/
forward Shop_Started();

/**
 *	Called when the plugin has loaded the player's data
 *	-
 *	@param client		Client index
 *	-
 *	@noreturn
 */
forward Shop_OnAuthorized(client);

/**
 *	Called when a menu is being titled
 *	-
 *	@param client			Client index to whom a menu is being titled
 *	@param menu_action		Menu that is being titled
 *	@param title			Current title is being set
 *	@param buffer			New title to set
 *	@param maxlength		Maxlength of the title
 *	-
 *	@return true to apply new value and false to ignore
*/
forward bool:Shop_OnMenuTitle(client, ShopMenu:menu_action, const String:title[], String:buffer[], maxlength);

/**
 *	Called when credits are being sent to a player
 *	-
 *	@param client			Client index who is sending credits
 *	@param target			Client index to whom credits being sent
 *	@param amount_give		Amount of credits being given to a target player. By reference
 *	@param amount_remove	Amount of credits being taken from performing player. By reference
 *	-
 *	@return Plugin_Changed to apply new values. >= Plugin_Handled to block
*/
forward Action:Shop_OnCreditsTransfer(client, target, &amount_give, &amount_remove);

/**
 *	Called when credits has been sent to a player
 *	-
 *	@param client			Client index who sent credits
 *	@param target			Client index to whom credits were sent
 *	@param amount_give		Amount of credits has been given to a target player
 *	@param amount_remove	Amount of credits has been taken from a performing player
 *	-
 *	@noreturn
*/
forward Shop_OnCreditsTransfered(client, target, amount_give, amount_remove);

/**
 *	Called when a player is being given credits to
 *	-
 *	@param client			Client index who is being given to
 *	@param credits			Amount of credits a client is being given to. By reference
 *	@param by_who			See CREDITS_BY_* definitions for more info and any higher values is the admin index
 *	-
 *	@return Plugin_Changed to apply new values. >= Plugin_Handled to block
*/
forward Action:Shop_OnCreditsGiven(client, &credits, by_who);

/**
 *	Called when a player is being taken credits from
 *	-
 *	@param client			Client index who is being taken from
 *	@param credits			Amount of credits a client is being taken for. By reference
 *	@param by_who			See CREDITS_BY_* definitions for more info and any higher value is the admin index
 *	-
 *	@return Plugin_Changed to apply new values. >= Plugin_Handled to block
*/
forward Action:Shop_OnCreditsTaken(client, &credits, by_who);

/**
 *	Called when a player is trying to try a luck
 *	-
 *	@param client			Client index who is perfroming
 *	-
 *	@return true to allow performing and false to block
*/
forward bool:Shop_OnLuckProcess(client);

/**
 *	Called when a player is nearly to win an item
 *	-
 *	@param client			Client index who is nearly to win
 *	@param item_id			Item id of the item
 *	-
 *	@return true to allow and false to block
*/
forward bool:Shop_OnItemLuck(client, ItemId:item_id);

/**
 *	Called when a player has won an item
 *	-
 *	@param client			Client index who has won
 *	@param item_id			Item id of the item
 *	-
 *	@noreturn
*/
forward Shop_OnItemLucked(client, ItemId:item_id);

/**
 *	Checks whether the shop has been started
 *	-
 *	@noparams
 *	-
 *	@return	True if the shop is already started, false otherwise
*/
native bool:Shop_IsStarted();

/**
 *	This must be called on PluginEnd. Fully unregisters the plugin. Unregisters items, categories and removes them from the shop and players' inventory
 *	-
 *	@noparams
 *	-
 *	@noreturn
*/
native Shop_UnregisterMe();

/**
 *	Shows a player an item's panel
 *	-
 *	@param client			Client index
 *	@param item_id			Item id of the item
 *	-
 *	@return true if a panel has been shown, false otherwise
*/
native bool:Shop_ShowItemPanel(client, ItemId:item_id);

/**
 *	Opens main menu for a player
 *	-
 *	@param client			Client index
 *	-
 *	@noreturn
*/
native Shop_OpenMainMenu(client);

/**
 *	Shows a player categories of the shop
 *	-
 *	@param client			Client index
 *	-
 *	@return true if categories has been shown, false otherwise
*/
native bool:Shop_ShowCategory(client);

/**
 *	Shows a player his inventory
 *	-
 *	@param client			Client index
 *	-
 *	@return true if the inventory has been shown, false otherwise
*/
native bool:Shop_ShowInventory(client);

/**
 *	Shows a player items of a category
 *	-
 *	@param client			Client index
 *	@param category_id		Category id to show
 *	@param inventory		To show items of his inventory
 *	-
 *	@return true if the items has been shown, false otherwise
*/
native bool:Shop_ShowItemsOfCategory(client, CategoryId:category_id, bool:inventory = false);

/**
 *	Get path to the main config folder of the Shop
 *	-
 *	@param buffer			Buffer to store the path in
 *	@param size				Max buffer length
 *	@param file				File to retrieve the path for
 *	-
 *	@noreturn
*/
stock Shop_GetCfgFile(String:buffer[], size, const String:file[])
{
	BuildPath(Path_SM, buffer, size, "configs/shop/%s", file);
}

public SharedPlugin:__pl_shop = 
{
	name = "shop",
	file = "shop.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_shop_SetNTVOptional()
{
	MarkNativeAsOptional("Shop_IsStarted");
	MarkNativeAsOptional("Shop_UnregisterMe");
	MarkNativeAsOptional("Shop_ShowItemPanel");
	MarkNativeAsOptional("Shop_OpenMainMenu");
	MarkNativeAsOptional("Shop_ShowCategory");
	MarkNativeAsOptional("Shop_ShowInventory");
	MarkNativeAsOptional("Shop_ShowItemsOfCategory");
	MarkNativeAsOptional("Shop_GetDatabase");
	MarkNativeAsOptional("Shop_GetDatabasePrefix");
	
	MarkNativeAsOptional("Shop_ShowAdminMenu");
	MarkNativeAsOptional("Shop_AddToAdminMenu");
	MarkNativeAsOptional("Shop_RemoveFromAdminMenu");
	
	MarkNativeAsOptional("Shop_ShowFunctionsMenu");
	MarkNativeAsOptional("Shop_AddToFunctionsMenu");
	MarkNativeAsOptional("Shop_RemoveFromFunctionsMenu");
	
	MarkNativeAsOptional("Shop_RegisterCategory");
	MarkNativeAsOptional("Shop_StartItem");
	MarkNativeAsOptional("Shop_SetInfo");
	MarkNativeAsOptional("Shop_SetCallbacks");
	MarkNativeAsOptional("Shop_SetCustomInfo");
	MarkNativeAsOptional("Shop_SetCustomInfoFloat");
	MarkNativeAsOptional("Shop_SetCustomInfoString");
	MarkNativeAsOptional("Shop_KvCopySubKeysCustomInfo");
	MarkNativeAsOptional("Shop_EndItem");
	
	MarkNativeAsOptional("Shop_GetItemCustomInfo");
	MarkNativeAsOptional("Shop_SetItemCustomInfo");
	MarkNativeAsOptional("Shop_GetItemCustomInfoFloat");
	MarkNativeAsOptional("Shop_SetItemCustomInfoFloat");
	MarkNativeAsOptional("Shop_GetItemCustomInfoString");
	MarkNativeAsOptional("Shop_SetItemCustomInfoString");
	MarkNativeAsOptional("Shop_KvCopySubKeysItemCustomInfo");
	MarkNativeAsOptional("Shop_GetItemPrice");
	MarkNativeAsOptional("Shop_SetItemPrice");
	MarkNativeAsOptional("Shop_GetItemSellPrice");
	MarkNativeAsOptional("Shop_SetItemSellPrice");
	MarkNativeAsOptional("Shop_GetItemValue");
	MarkNativeAsOptional("Shop_SetItemValue");
	MarkNativeAsOptional("Shop_IsItemExists");
	MarkNativeAsOptional("Shop_IsValidCategory");
	MarkNativeAsOptional("Shop_GetItemId");
	MarkNativeAsOptional("Shop_GetItemById");
	MarkNativeAsOptional("Shop_GetItemCategoryId");
	MarkNativeAsOptional("Shop_GetCategoryId");
	MarkNativeAsOptional("Shop_GetCategoryById");
	MarkNativeAsOptional("Shop_FillArrayByItems");
	MarkNativeAsOptional("Shop_FormatItem");
	
	MarkNativeAsOptional("Shop_GetClientId");
	MarkNativeAsOptional("Shop_SetClientItemTimeleft");
	MarkNativeAsOptional("Shop_GetClientItemTimeleft");
	MarkNativeAsOptional("Shop_GetClientItemSellPrice");
	MarkNativeAsOptional("Shop_IsClientItemToggled");
	MarkNativeAsOptional("Shop_IsClientHasItem");
	MarkNativeAsOptional("Shop_ToggleClientItem");
	MarkNativeAsOptional("Shop_ToggleClientCategoryOff");
	MarkNativeAsOptional("Shop_IsAuthorized");
	MarkNativeAsOptional("Shop_IsAdmin");
	MarkNativeAsOptional("Shop_GiveClientCredits");
	MarkNativeAsOptional("Shop_TakeClientCredits");
	MarkNativeAsOptional("Shop_GetClientCredits");
	MarkNativeAsOptional("Shop_SetClientCredits");
	MarkNativeAsOptional("Shop_BuyClientItem");
	MarkNativeAsOptional("Shop_RemoveClientItem");
	MarkNativeAsOptional("Shop_GetClientItemCount");
	MarkNativeAsOptional("Shop_UseClientItem");
}
#endif