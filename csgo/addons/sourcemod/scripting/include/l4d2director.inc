/**
 * vim: set ts=4 :
 * =============================================================================
 * Left 4 Downtown 2 SourceMod Extension
 * Copyright (C) 2010 Michael "ProdigySim" Busby
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */
 
 #if defined _l4d2director_included
  #endinput
#endif
#define _l4d2director_included

/**
 * @brief Gets the number of tanks currently in play.
 * @remarks This value is tracked by the director, and should be a good 
 *		indicator that a tank is in play
 * 
 * @return 	current tank count
 */
native L4D2_GetTankCount();

/**
 * @brief Gets the campaign scores stored in the Versus Director
 * @remarks These are the actual values used for campaign scores--not proxies
 * 
 * @param scores 		Array to store the campaign scores in
 * @noreturn 				
 */
native L4D2_GetVersusCampaignScores(scores[2]);

/**
 * @brief Sets the campaign scores stored in the Versus Director
 * @remarks These are the actual values used for campaign scores--not proxies
 * 
 * @param scores 		Array of campaign scores to set the director's values to.
 * @noreturn 				
 */
native L4D2_SetVersusCampaignScores(const scores[2]);

/**
 * @brief Gets the flow percent for tank spawns for both versus rounds.
 * @remarks These values are checked against as the survivors move through the
 *		map. Once they are passed, the tank spawns. Note that this is flow
 *		as a percent of the map's flow, not flow distance.
 * 
 * @param tankFlows	Array to store the Tank Spawn Flow percents in
 * @noreturn 				
 */
native L4D2_GetVersusTankFlowPercent(Float:tankFlows[2]);

/**
 * @brief Sets the flow percent for tank spawns for both versus rounds.
 * @remarks These values are checked against as the survivors move through the
 *		map. Once they are passed, the tank spawns. Note that this is flow
 *		as a percent of the map's flow, not flow distance.
 * 
 * @param tankFlows	Array of Tank Spawn Flow percents to store in director
 * @noreturn 				
 */
native L4D2_SetVersusTankFlowPercent(const Float:tankFlows[2]);

