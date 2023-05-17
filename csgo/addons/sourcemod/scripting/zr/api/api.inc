/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  api.inc
 *  Type:		  Core
 *  Description:   Native handlers for the ZR API.
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
 * Application Programming Interface (API)
 * 
 * To allow other plugins or extensions to interact directly with Zombie:Reloaded we need to implement
 * an API.  SourceMod allows us to do this by creating global "natives" or "forwards."
 * 
 * Natives are basically functions that can be called from any plugin that includes its definition.
 * Forwards are functions that are called on a given event. (Such as OnClientPutInServer)
 * ZR's API files are located in sourcemod/scripting/include/zr/category.zr.inc.  We chose to create multiple
 * files simply for organization.  Including zr.inc will automatically include the rest of the files as well.
 * 
 * To better understand how natives and forwards are created, go here:
 * http://wiki.alliedmods.net/Creating_Natives_(SourceMod_Scripting)
 * http://wiki.alliedmods.net/Function_Calling_API_(SourceMod_Scripting) 
 */

#include "zr/api/infect.api"
#include "zr/api/respawn.api"
#include "zr/api/class.api"
#include "zr/api/weapons.api"
#include "zr/api/sounds.api"

/**
 * Initializes all main natives and forwards.
 */
void APIInit()
{
	// Forward event to sub-modules.
	APIInfectInit();
	APIRespawnInit();
	APIClassInit();
	APIWeapons();
	APISoundsInit();
}

/**
 * Validates a client index and when it fails, an error is thrown.
 * 
 * @param client	The client index to validate.
 * @param alive	 Set to true to validate that the client is alive, false to ignore.
 * 
 * @error		   Throws an error when the client isn't valid.
 */
stock void APIValidateClientIndex(int client, EligibleCondition alive = Condition_Either)
{
	// Verify client index.
	if (client < 1 || client > MaxClients)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index. (%d)", client);
		return;
	}
	
	// Verify that the client is connected.
	if (!IsClientConnected(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected.", client);
		return;
	}
	
	// Check if the player must be dead or alive.
	bool bAlive = view_as<bool>(alive);
	if (alive != Condition_Either)
	{
		if (bAlive && !IsPlayerAlive(client))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Client %d must be alive.", client);
		}
		else if (!bAlive && IsPlayerAlive(client))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Client %d must be dead.", client);
		}
	}
}
