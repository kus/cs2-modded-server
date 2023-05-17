#if defined _tf2items_included
#endinput
#endif
#define _tf2items_included

#include <tf2>

// ====[ CONSTANTS ]===========================================================
#define OVERRIDE_CLASSNAME		(1 << 0)	// Item will override the entity's classname.
#define OVERRIDE_ITEM_DEF			(1 << 1)	// Item will override the item's definition index.
#define OVERRIDE_ITEM_LEVEL		(1 << 2)	// Item will override the entity's level.
#define OVERRIDE_ITEM_QUALITY		(1 << 3)	// Item will override the entity's quality.
#define OVERRIDE_ATTRIBUTES		(1 << 4)	// Item will override the attributes for the item with the given ones.
#define OVERRIDE_ALL				(0b11111)	// Magically enables all the other flags.

#define PRESERVE_ATTRIBUTES		(1 << 5)
#define FORCE_GENERATION		(1 << 6)

// ====[ NATIVES ]=============================================================

/**
 * WARNING: This is for ADVANCED users only!
 * You probably want to be using the forward instead of this.
 *
 * This native will perform a GiveNamedItem call for the specified client in
 * order to generate an object based on the specifications of the TF2Items
 * object passed to it.
 * 
 * Since the item generation requires all the information that can be passed by
 * the extensions natives, the flags will be ignored and all the given
 * information will be used.
 * 
 * Remember that if your values aren't correct, this call may end up in a crash,
 * so please make sure you fill out everything: Classname, item definition index,
 * quality, level and attributes.
 * 
 * @param iClient	Client that the item will be generated for.
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			Entity index of the newly created item.
 */
native TF2Items_GiveNamedItem(iClient, Handle:hItem);

/**
 * Creates a TF2Items object, wich can be used to override the parameters of an
 * item before it's given to the client, or to create a new completely new one
 * with GiveNamedItem. Remember to free the object with CloseHandle()
 *
 * @param iFlags		Flags used to specify what to override.
 * @return				Handle to the TFItems object.
 */
native Handle:TF2Items_CreateItem(iFlags);

/**
 * Sets the flags to determine what the item will override on the GiveNamedItem.
 * Use the OVERRIDE_ defines to set what you will be changing.
 *
 * @param hItem			Handle to the TF2Items object that we'll be operating with.
 * @param iFlags		Flags used to specify what to override.
 * @noreturn
 */
native TF2Items_SetFlags(Handle:hItem, iFlags);

/**
 * Sets the new entity classname used for the item's entity.
 *
 * @param hItem				Handle to the TF2Items object that we'll be operating with.
 * @param strClassName		New classname to use for the entity.
 * @noreturn
 */
native TF2Items_SetClassname(Handle:hItemOverride, String:strClassName[]);

/**
 * Sets the item's Definition Index, wich tells the game what item it is. Each
 * weapon/hat/item has an unique definition index. Find these out in the
 * game_items.txt
 * 
 * @param hItem				Handle to the TF2Items object that we'll be operating with.
 * @param iItemDefIndex		New definition index.
 * @noreturn
 */
native TF2Items_SetItemIndex(Handle:hItem, iItemDefIndex);

/**
 * Sets the item's quality value, wich determines what color will be used for
 * the item name. Valid values are from 0 to 9.
 * 
 * @param hItem					Handle to the TF2Items object that we'll be operating with.
 * @param iEntityQuality		New item quality.
 * @noreturn
 */
native TF2Items_SetQuality(Handle:hItem, iEntityQuality);

/**
 * Sets the item's level value. This value can range from 0 to 127.
 * 
 * @param hItem				Handle to the TF2Items object that we'll be operating with.
 * @param iEntityLevel		New item level.
 * @noreturn
 */
native TF2Items_SetLevel(Handle:hItem, iEntityLevel);

/**
 * Sets the number of attributes that will be used on the item. The maximum
 * number of attributes that can be allocated ranges from 0 to 15.
 * 
 * @param hItem					Handle to the TF2Items object that we'll be operating with.
 * @param iNumAttributes		Number of attributes.
 * @noreturn
 */
native TF2Items_SetNumAttributes(Handle:hItem, iNumAttributes);

/**
 * Setups the given attribute index to use the attribute and values specified
 * with iAttribDefIndex and flValue. Remember the iSlotIndex ranges from 0 to 15.
 * 
 * @param hItem					Handle to the TF2Items object that we'll be operating with.
 * @param iSlotIndex			The attribute slot index, ranges from 0 to 15.
 * @param iAttribDefIndex		The attribute definition index, as it appears on game_items.txt.
 * @param flValue				The value assigned to the attribute (how much health, damage, etc.).
 * @noreturn
 */
native TF2Items_SetAttribute(Handle:hItem, iSlotIndex, iAttribDefIndex, Float:flValue);

/**
 * Retrieves the flags used to determine what the item will override on the
 * GiveNamedItem call.
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			Returns the flags used by the item.
 */
native TF2Items_GetFlags(Handle:hItem);

/**
 * Gets the entity classname we'll use for the item.
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			New classname to use for the entity.
 */
native TF2Items_GetClassname(Handle:hItem, String:strDest[], iDestSize);

/**
 * Gets the new item definition index we'll use to override.
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			New definition index.
 */
native TF2Items_GetItemIndex(Handle:hItem); 

/**
 * Gets the item's quality value, wich determines what color will be used for
 * the item name. Valid values are from 0 to 9. But if set to 0 and attributes
 * are also changed, this value will be overridden to 9
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			New entity quality.
 */
native TF2Items_GetQuality(Handle:hItem); 

/**
 * Gets the item's level value. This value can range from 0 to 127.
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			New entity level.
 */
native TF2Items_GetLevel(Handle:hItem);

/**
 * Gets the number of attributes that will be used on the item. The maximum
 * number of attributes that can be allocated ranges from 0 to 15.
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			Number of attributes.
 */
native TF2Items_GetNumAttributes(Handle:hItem);

/**
 * Retrieves the attribute definition index used at the specified index on the
 * item object. Remember the iSlotIndex ranges from 0 to 15.
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			The attribute definition index to use.
 */
native TF2Items_GetAttributeId(Handle:hItem, iSlotIndex);

/**
 * Retrieves the value used for the attribute at the specified index on the item
 * object. Remember the iSlotIndex ranges from 0 to 15.
 *
 * @param hItem		Handle to the TF2Items object that we'll be operating with.
 * @return			The attribute value to use.
 */
native Float:TF2Items_GetAttributeValue(Handle:hItem, iSlotIndex); 

// ====[ FORWARDS ]============================================================
/**
 * Called when an item is about to be given to a client.
 * Return Plugin_Changed to override the item to use the configuration of the hItem object.
 * Return Plugin_Continue to keep them intact.
 * Return Plugin_Handled to stop the item being given to the player.
 * Make sure the client gets atleast one weapon.
 *
 * @param client				Client Index.
 * @param classname				The classname of the entity that will be generated.
 * @param iItemDefinitionIndex	Item definition index.
 * @param hItem					Handle to a TF2Item object wich describes what values will be overriden.
 */
forward Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem);

forward TF2Items_OnGiveNamedItem_Post(client, String:classname[], itemDefinitionIndex, itemLevel, itemQuality, entityIndex);

/**
 * Do not edit below this line!
 */
public Extension:__ext_tf2items = 
{
	name = "TF2Items",
	file = "tf2items.ext.2.ep2v",
	autoload = 0,
	#if defined REQUIRE_EXTENSIONS
		required = 1,
	#else
		required = 0,
	#endif
}

#if !defined REQUIRE_EXTENSIONS
public __ext_tf2items_SetNTVOptional()
{
	MarkNativeAsOptional("TF2Items_GetAttributeValue");
	MarkNativeAsOptional("TF2Items_GetAttributeId");
	MarkNativeAsOptional("TF2Items_GetNumAttributes");
	MarkNativeAsOptional("TF2Items_GetLevel");
	MarkNativeAsOptional("TF2Items_GetQuality");
	MarkNativeAsOptional("TF2Items_GetItemIndex");
	MarkNativeAsOptional("TF2Items_GetClassname");
	MarkNativeAsOptional("TF2Items_GetFlags");
	MarkNativeAsOptional("TF2Items_SetAttribute");
	MarkNativeAsOptional("TF2Items_SetNumAttributes");
	MarkNativeAsOptional("TF2Items_SetLevel");
	MarkNativeAsOptional("TF2Items_SetQuality");
	MarkNativeAsOptional("TF2Items_SetItemIndex");
	MarkNativeAsOptional("TF2Items_SetClassname");
	MarkNativeAsOptional("TF2Items_SetFlags");
	MarkNativeAsOptional("TF2Items_GiveNamedItem");
	MarkNativeAsOptional("TF2Items_CreateItem");
}
#endif
	
/**
* I'll just leave this here...
* 
* _(º< _(º< _(º< _(º< _(º< _(º< _(º< _(º< _(º< 
* \__) \__) \__) \__) \__) \__) \__) \__) \__) 
*                     .  .
*                    // //  __
*         __  ______||_//_.´.´
*       _/__`´            ¯ `
*      /  / _          _     \
*     /  /( · )      ( · )    |
*    /  |   ¯     __   ¯    _/\/|
*   |    \  ___.-´  `-.___  \   /
*    \    \(     ` ´      `)|   \
*     \     )              //     \
*      \/  /              | |     |
*     /   /               | |     |
*    ·   |                |  \___/
*    |    \_            _/      \  ____
*    ·      `----------´         |´    \
*     \                         /    _·´
*      \                       /  _-´ 
*        `-._               _·´-´
*        _.-´`---________--´ \ 
*       ´-.-. _--·   / .   ._ \
*            ´       `´ `·´  `´
* >º)_ >º)_ >º)_ >º)_ >º)_ >º)_ >º)_ >º)_ >º)_ 
* (__/ (__/ (__/ (__/ (__/ (__/ (__/ (__/ (__/ 
* 
*/
