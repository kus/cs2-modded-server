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

#if defined _levelsystem_included
 #endinput
#endif
#define _levelsystem_included
 
/**
 * @brief Called when a client receive level.
 * 
 * @param client            The client index.
 * @param level             The level amount.
 *
 * @noreturn
 **/
forward void ZP_OnClientLevel(int client, int &level);

/**
 * @brief Gets the maximum level.
 *
 * @return                  The max level.     
 **/
native int ZP_GetLevelMax();

/**
 * @brief Gets the level experience limit.
 *
 * @param level             The level amount.
 *
 * @return                  The limit amount.
 **/
native int ZP_GetLevelLimit(int level);

/**
 * @brief Called when a client receive experience.
 * 
 * @param client            The client index.
 * @param exp               The experience amount.
 *
 * @noreturn
 **/
forward void ZP_OnClientExp(int client, int &exp);

/**
 * @brief Gets the player level.
 *
 * @param client            The client index.
 *  
 * @return                  The level amount.
 **/
native int ZP_GetClientLevel(int client);

/**
 * @brief Sets the player level.
 *
 * @param client            The client index.
 * @param level             The level amount.
 *  
 * @noreturn
 **/
native int ZP_SetClientLevel(int client, int level);

/**
 * @brief Gets the player experience.
 *
 * @param client            The client index.
 *  
 * @return                  The experience amount.
 **/
native int ZP_GetClientExp(int client);

/**
 * @brief Sets the player experience.
 *
 * @param client            The client index.
 * @param exp               The experience amount.
 *  
 * @noreturn
 **/
native int ZP_SetClientExp(int client, int exp);