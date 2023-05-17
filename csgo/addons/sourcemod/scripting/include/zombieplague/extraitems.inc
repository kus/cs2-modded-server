/**
 * =============================================================================
 * Zombie Plague X Copyright (C) 2015-2020 Nikita Ushakov (Ireland, Dublin).
 * =============================================================================
 *
 * This file is part of the Zombie Plague Core.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 **/

#if defined _extraitems_included
 #endinput
#endif
#define _extraitems_included

/**
 * @brief Called before show an extraitem in the equipment menu.
 * 
 * @param client            The client index.
 * @param itemID            The item index.
 *
 * @return                  Plugin_Handled to disactivate showing and Plugin_Stop to disabled showing. Anything else
 *                              (like Plugin_Continue) to allow showing and calling the ZP_OnClientBuyExtraItem() forward.
 **/
forward Action ZP_OnClientValidateExtraItem(int client, int itemID);

/**
 * @brief Called after select an extraitem in the equipment menu.
 * 
 * @param client            The client index.
 * @param itemID            The item index.
 **/
forward void ZP_OnClientBuyExtraItem(int client, int itemID);

/**
 * @brief Give the extra item to the client.
 * 
 * @param client            The client index.
 * @param itemID            The item index.
 *
 * @param                   True or false.
 **/
native bool ZP_GiveClientExtraItem(int client, int itemID);

/**
 * @brief Sets the buy limit of the current player item.
 * 
 * @param client            The client index.
 * @param itemID            The item index.
 * @param limit             The limit amount.
 **/
native void ZP_SetClientExtraItemLimit(int client, int itemID, int limit);

/**
 * @brief Gets the buy limit of the current player item.
 * 
 * @param client            The client index.
 * @param itemID            The item index.
 *
 * @return                  The limit amount.
 **/
native int ZP_GetClientExtraItemLimit(int client, int itemID);

/**
 * @brief Gets the amount of all extra items.
 *
 * @return                  The extra item amount.    
 */
native int ZP_GetNumberExtraItem();

/**
 * @brief Gets the index of a extra item at a given name.
 * 
 * @param name              The item name.
 *
 * @return                  The item index, or -1 on failure.
 **/
native int ZP_GetExtraItemNameID(char[] name);

/**
 * @brief Gets the name of a extra item at a given index.
 *
 * @param itemID            The item index.
 * @param name              The string to return name in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetExtraItemName(int itemID, char[] name, int maxlenght = 32);

/**
 * @brief Gets the info of a extra item at a given index.
 *
 * @param itemID            The item index.
 * @param info              The string to return info in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetExtraItemInfo(int itemID, char[] info, int maxlenght = 128);

/**
 * @brief Gets the cost of the extra item.
 * 
 * @param itemID            The item index.
 *
 * @return                  The cost amount.    
 **/
native int ZP_GetExtraItemCost(int itemID);

/**
 * @brief Gets the level of the extra item.
 * 
 * @param itemID            The item index.
 *
 * @return                  The level amount.    
 **/
native int ZP_GetExtraItemLevel(int itemID);

/**
 * @brief Gets the online of the extra item.
 * 
 * @param itemID            The item index.
 *
 * @return                  The online amount.    
 **/
native int ZP_GetExtraItemOnline(int itemID);

/**
 * @brief Gets the limit of the extra item.
 * 
 * @param itemID            The item index.
 *
 * @return                  The limit amount.    
 **/
native int ZP_GetExtraItemLimit(int itemID);

/**
 * @brief Gets the group of a extra item at a given index.
 *
 * @param itemID            The item index.
 * @param group             The string to return group in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetExtraItemGroup(int itemID, char[] group, int maxlenght = 32);

/**
 * @brief Gets the class of a extra item at a given index.
 *
 * @param itemID            The item index.
 * @param class             The string to return class in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetExtraItemClass(int itemID, char[] class, int maxlenght = 128);
