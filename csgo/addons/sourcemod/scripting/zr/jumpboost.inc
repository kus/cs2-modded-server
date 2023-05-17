/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  jumpboost.inc
 *  Type:		  Module
 *  Description:   Modified jump vector magnitudes.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/**
 * Client is jumping.
 * 
 * @param client	The client index.
 */
void JumpBoostOnClientJumpPost(int client)
{
	// Get class jump multipliers.
	float distancemultiplier = ClassGetJumpDistance(client);
	float heightmultiplier = ClassGetJumpHeight(client);
	
	// If both are set to 1.0, then stop here to save some work.
	if (distancemultiplier == 1.0 && heightmultiplier == 1.0)
	{
		return;
	}
	
	float vecVelocity[3];
	
	// Get client's current velocity.
	ToolsClientVelocity(client, vecVelocity, false);
	
	// Only apply horizontal multiplier if it's not a bhop.
	if (!JumpBoostIsBHop(vecVelocity))
	{
		// Apply horizontal multipliers to jump vector.
		vecVelocity[0] *= distancemultiplier;
		vecVelocity[1] *= distancemultiplier;
	}
	
	// Apply height multiplier to jump vector.
	vecVelocity[2] *= heightmultiplier;
	
	// Set new velocity.
	ToolsClientVelocity(client, vecVelocity, true, false);
}

/**
 * This function detects excessive bunnyhopping.
 * Note: This ONLY catches bunnyhopping that is worse than CS:S already allows.
 * 
 * @param vecVelocity   The velocity of the client jumping.
 * @return			  True if the client is bunnyhopping, false if not.
 */
stock bool JumpBoostIsBHop(const float[] vecVelocity)
{
	// If bunnyhop protection is disabled, then stop.
	bool bunnyhopprotect = GetConVarBool(g_hCvarsList[CVAR_JUMPBOOST_BHOP_PROTECT]);
	if (!bunnyhopprotect)
	{
		return false;
	}
	
	// Calculate the magnitude of jump on the xy plane.
	float magnitude = SquareRoot(Pow(vecVelocity[0], 2.0) + Pow(vecVelocity[1], 2.0));
	
	// Return true if the magnitude exceeds the max.
	float bunnyhopmax = GetConVarFloat(g_hCvarsList[CVAR_JUMPBOOST_BHOP_MAX]);
	return (magnitude > bunnyhopmax);
}