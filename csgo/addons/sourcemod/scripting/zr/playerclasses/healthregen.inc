/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  healthregen.inc
 *  Type:		  Core 
 *  Description:   Functions for managing health regeneration on a client.
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

int ClientHealthRegenAmount[MAXPLAYERS + 1];
int ClientHealthRegenMax[MAXPLAYERS + 1];
Handle tHealthRegen[MAXPLAYERS + 1];

/**
 * Resets all timer handles. (called from classevents)
 */
void ClassHealthRegenInit()
{
	for (int client = 0; client < MAXPLAYERS + 1; client++)
	{
		tHealthRegen[client] = INVALID_HANDLE;
	}
}

/**
 * Prepares and starts HP regeneration on a client.
 *
 * @param client		The client to apply HP regeneration on.
 * @param interval	  Regeneration interval.
 * @param amount		HP amount per interval.
 * @param max		   Regeneration limit. Don't give HP if player HP is above
 *					  this value.
 */
void ClassHealthRegenInitClient(int client, float interval, int amount, int max)
{
	ClientHealthRegenAmount[client] = amount;
	ClientHealthRegenMax[client] = max;
	ClassHealthRegenStart(client, interval);
}

/**
 * Starts HP regeneration on a client using current client settings.
 *
 * @param client		The client index.
 * @param interval	  Regeneration interval.
 */
void ClassHealthRegenStart(int client, float interval)
{
	// Stop timer if it already exist.
	ClassHealthRegenStop(client);
	
	// Create new timer.
	tHealthRegen[client] = CreateTimer(interval, ClassHealthRegenTimer, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * Stops HP regeneration on a client.
 *
 * @param client	The client index.
 */
void ClassHealthRegenStop(int client)
{
	// Kill the timer if it exist.
	if (tHealthRegen[client] != INVALID_HANDLE)
	{
		KillTimer(tHealthRegen[client]);
		tHealthRegen[client] = INVALID_HANDLE;
	}
}

/**
 * Timer callback for HP regeneration.
 */
public Action ClassHealthRegenTimer(Handle timer, any client)
{
	// Kill the timer if the player is dead or not in game.
	if (!IsClientConnected(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		tHealthRegen[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	int health = GetClientHealth(client);	
	health += ClientHealthRegenAmount[client];
	
	// Check if the health points is below the limit.
	if (health < ClientHealthRegenMax[client])
	{
		// Increase health.
		SetEntityHealth(client, health);
	}
	
	return Plugin_Continue;
}
