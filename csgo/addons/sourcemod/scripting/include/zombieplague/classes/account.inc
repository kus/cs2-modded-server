/**
 * =============================================================================
 *  Plague X Copyright (C) 2015-2020 Nikita Ushakov (Ireland, Dublin).
 * =============================================================================
 *
 * This file is part of the  Plague Core.
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

#if defined _account_included
 #endinput
#endif
#define _account_included

/**
 * @brief Called when a client receive money.
 * 
 * @param client            The client index.
 * @param money             The money amount.
 *
 * @noreturn
 **/
forward void ZP_OnClientMoney(int client, int &money);

/**
 * @brief Gets the player amount of money.
 *
 * @param client            The client index.
 *  
 * @return                  The money amount.
 **/
native int ZP_GetClientMoney(int client);

/**
 * @brief Sets the player amount of money.
 *
 * @param client            The client index.
 * @param money             The money amount.
 *  
 * @noreturn
 **/
native void ZP_SetClientMoney(int client, int money);

/**
 * @brief Gets the player amount of previous money spended.
 *
 * @param client            The client index.
 *  
 * @return                  The money amount.
 **/
native int ZP_GetClientLastPurchase(int client);

/**
 * @brief Sets the player amount of money spending.
 *
 * @param client            The client index.
 * @param money             The money amount.
 *  
 * @noreturn
 **/
native void ZP_SetClientLastPurchase(int client, int money);