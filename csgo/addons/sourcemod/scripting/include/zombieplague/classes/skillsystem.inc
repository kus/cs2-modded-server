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

#if defined _skillsystem_included
 #endinput
#endif
#define _skillsystem_included

/**
 * @brief Called when a client use a skill.
 * 
 * @param client            The client index.
 *
 * @return                  Plugin_Handled or Plugin_Stop to block using skill. Anything else
 *                              (like Plugin_Continue) to allow use.
 **/
forward Action ZP_OnClientSkillUsed(int client);

/**
 * @brief Called when a skill duration is over.
 * 
 * @param client            The client index.
 *
 * @noreturn
 **/
forward void ZP_OnClientSkillOver(int client);

/**
 * @brief Gets the player skill state.
 *
 * @param client            The client index.
 *  
 * @return                  True or false.
 **/
native bool ZP_GetClientSkillUsage(int client);

/**
 * @brief Gets the player skill countdown.
 *
 * @param client            The client index.
 *  
 * @return                  The current countdown.
 **/
native float ZP_GetClientSkillCountdown(int client);

/**
 * @brief Stop the player skill or countdown. 
 *
 * @param client            The client index.
 *  
 * @noreturn
 **/
native void ZP_ResetClientSkill(int client);