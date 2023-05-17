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

#if defined _menulist_included
 #endinput
#endif
#define _menulist_included

/**
 * @brief Called before show a main menu.
 * 
 * @param client            The client index.
 *
 * @return                  Plugin_Handled or Plugin_Stop to block showing. Anything else
 *                              (like Plugin_Continue) to allow showing.
 **/
forward Action ZP_OnClientValidateButton(int client);

/**
 * @brief Called before show a slot in the main/sub menu.
 * 
 * @param client            The client index.
 * @param menuID            The slot index.
 * @param iSub              The submenu index.
 *
 * @return                  Plugin_Handled to disactivate showing and Plugin_Stop to disabled showing. Anything else
 *                              (like Plugin_Continue) to allow showing and selecting.
 **/
forward Action ZP_OnClientValidateMenu(int client, int menuID, int iSub);

/**
 * @brief Gets the amount of all menus.
 **/
native int ZP_GetNumberMenu();

/**
 * @brief Gets the name of a menu at a given index.
 *
 * @param menuID            The menu index.
 * @param name              The string to return name in.
 * @param maxlenght         The lenght of string.
 * @param iSub              (Optional) The submenu index.
 **/
native void ZP_GetMenuName(int menuID, char[] name, int maxlenght = 32, int iSub = 0);

/**
 * @brief Gets the group of a menu at a given index.
 *
 * @param menuID            The menu index.
 * @param group             The string to return group in.
 * @param maxlenght         The lenght of string.
 * @param iSub              (Optional) The submenu index.
 **/
native void ZP_GetMenuGroup(int menuID, char[] group, int maxlenght = 32, int iSub = 0);

/**
 * @brief Gets the class of a menu at a given index.
 *
 * @param menuID            The menu index.
 * @param class             The string to return class in.
 * @param maxlenght         The lenght of string.
 * @param iSub              (Optional) The submenu index.
 **/
native void ZP_GetMenuClass(int menuID, char[] class, int maxlenght = 128, int iSub = 0);

/**
 * @brief Gets the hide value of the menu.
 *
 * @param menuID            The menu index.
 * @param iSub              (Optional) The submenu index.
 *
 * @return                  True if menu is hide, false if not.
 **/
native bool ZP_IsMenuHide(int costumeID, int iSub = 0);

/**
 * @brief Gets the array of a menu at a given command.
 *
 * @param command           The menu command.
 * @param index             The array to return indexes in.
 * @param maxlenght         The lenght of array.
 *
 * @note Array contains the menu index and the submenu index.
 **/
native void ZP_GetMenuCommandID(char[] command, int[] index, int maxlenght = 2);

/**
 * @brief Gets the command of a menu at a given index.
 *
 * @param menuID            The menu index.
 * @param command           The string to return command in.
 * @param maxlenght         The lenght of string.
 * @param iSub              (Optional) The submenu index.
 **/
native void ZP_GetMenuCommand(int menuID, char[] command, int maxlenght = 32, int iSub = 0);

/**
 * Opens the submenu of the menu.
 *
 * @param client            The client index.
 * @param menuID            The menu index.
 *
 * @note If a submenu is not exist will open the main menu instead.
 **/
native void ZP_OpenMenuSub(int client, int menuID);
