/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zombiereloaded.inc
 *  Type:		  Core 
 *  Description:   General plugin functions and defines.
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
 * Index of server console.
 */
#define ZR_CONSOLE_INDEX 0

/**
 * Checks if a timer is currently running.
 * 
 * @param timer	 The timer handle.
 */
stock bool ZRIsTimerRunning(Handle timer)
{
	// Return true if the handle isn't empty.
	return (timer != INVALID_HANDLE);
}

/**
 * Wrapper functions for KilLTimer.
 * Ends a timer if running, and resets its timer handle variable.
 * 
 * @param timer	 The timer handle.
 * @param kill	  True to kill the timer and reset the variable, false to only reset the variable.
 *				  Using false is useful when calling from the timer callback, because the timer is already killed.
 * 
 * @return		  True if the handle wasn't INVALID_HANDLE, false if the handle wasn't valid.
 */
stock bool ZREndTimer(Handle &timer, bool kill = true)
{
	// If the timer is running, then kill it.
	if (ZRIsTimerRunning(timer))
	{
		// Kill if caller says to.
		if (kill)
		{
			KillTimer(timer);
		}
		
		// Reset variable.
		timer = INVALID_HANDLE;
		
		return true;
	}
	
	// Reset variable.
	timer = INVALID_HANDLE;
	
	return false;
}

/**
 * Check if a client index is a valid player.
 * 
 * @param client	The client index.
 * @param console   True to include console (index 0), false if not.
 * @return		  True if client is valid, false otherwise. 
 */	
stock bool ZRIsClientValid(int client, bool console = false)
{
	// If index is greater than max number of clients, then return false.
	if (client > MaxClients)
	{
		return false;
	}
	
	// If console is true, return if client is >= 0, if not, then return client > 0.
	return console ? (client >= 0) : (client > 0);
}

/**
 * Check if a given index is console.
 * 
 * @param client	The client index.
 * @param console   True to include console (index 0), false if not.
 * @return		  True if client is valid, false otherwise. 
 */	
stock bool ZRIsConsole(int index)
{
	// Return true if index is equal to console's index.
	return (index == ZR_CONSOLE_INDEX);
}

/**
 * Returns whether a player is a admin or not.
 *
 * @param client	The client index.
 * @param flag	  Optional. Flag to check. Default is generic admin flag.
 * @return		  True if generic admin, false otherwise.
 */
stock bool ZRIsClientAdmin(int client, AdminFlag flag = Admin_Generic)
{
	// If index is invalid, then stop.
	if (!ZRIsClientValid(client))
	{
		return false;
	}
	
	// If client doesn't have the specified flag, then stop.
	if (!GetAdminFlag(GetUserAdmin(client), flag))
	{
		return false;
	}
	
	// Client is an admin.
	return true;
}

/**
 * Converts a boolean value into a string.
 * 
 * @param value	 The value to convert to string.
 * @param output	The converted string.
 * @param maxlen	The maximum length of the string.
 */
void ZRBoolToString(bool value, char[] output, int maxlen)
{
	// If the value is true, then set string to "1".
	if (value)
	{
		strcopy(output, maxlen, "1");
	}
	// If the value is false, then set string to "0".
	else
	{
		strcopy(output, maxlen, "0");
	}
}

stock bool IsValidClient(int client, bool bzrAllowBots = false, bool bzrAllowDead = true)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bzrAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bzrAllowDead && !IsPlayerAlive(client)))
		return false;
	return true;
}