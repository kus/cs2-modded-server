/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  event.inc
 *  Type:		  Core
 *  Description:   Event hooking and forwarding.
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
 * Prevents a double event bug in Round End
 */
bool g_bRoundEnd = false;

/**
 * Init function for event module.
 */
void EventInit()
{
	// Hook all events used by plugin.
	EventsHook();
}

/**
 * Hook events used by plugin.
 * 
 * @param unhook	If true, then unhook all events, if false, then hook.
 */ 
void EventsHook(bool unhook = false)
{
	// If unhook is true, then continue.
	if (unhook)
	{
		// Unhook all events.
		UnhookEvent("round_start", EventRoundStart);
		UnhookEvent("round_end", EventRoundEnd);
		UnhookEvent("player_team", EventPlayerTeam, EventHookMode_Pre);
		UnhookEvent("player_spawn", EventPlayerSpawn);
		UnhookEvent("player_hurt", EventPlayerHurt);
		UnhookEvent("player_death", EventPlayerDeath);
		
		// Stop after unhooking events.
		return;
	}
	
	// Hook all events used by plugin.
	HookEvent("round_start", EventRoundStart);
	HookEvent("round_end", EventRoundEnd);
	HookEvent("player_team", EventPlayerTeam, EventHookMode_Pre);
	HookEvent("player_spawn", EventPlayerSpawn);
	HookEvent("player_hurt", EventPlayerHurt);
	HookEvent("player_death", EventPlayerDeath);
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_bRoundEnd = false;
	SEffectsOnRoundStart();
}

/**
 * Event callback (round_end)
 * The round is ending.
 * 
 * @param event	 The event handle.
 * @param name	  Name of the event.
 * @dontBroadcast   If true, event is broadcasted to all clients, false if not.
 */
public Action EventRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bRoundEnd)
	{
		g_bRoundEnd = true;
		// Get all required event info.
		int winner = GetEventInt(event, "winner");

		SEffectsOnRoundEnd(winner);
		InfectOnRoundEnd();
	}
}

/**
 * Event callback (player_team)
 * Client is joining a team.
 * 
 * @param event	 The event handle.
 * @param name	  Name of the event.
 * @dontBroadcast   If true, event is broadcasted to all clients, false if not.
 */
public Action EventPlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	// Get all required event info.
	int index = GetClientOfUserId(GetEventInt(event, "userid"));
	int team = GetEventInt(event, "team");

	InfectOnClientTeam(index, team);
}

/**
 * Event callback (player_spawn)
 * Client is spawning into the game.
 * 
 * @param event	 The event handle.
 * @param name	  Name of the event.
 * @dontBroadcast   If true, event is broadcasted to all clients, false if not.
 */
public Action EventPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	// Get all required event info.
	int index = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// Forward event to modules.
	InfectOnClientSpawn(index);
	SEffectsOnClientSpawn(index);
	
	// Fire post player_spawn event.
	CreateTimer(0.1, EventPlayerSpawnPost, index);
}

/**
 * Event callback (player_spawn)
 * Client is spawning into the game. *Post
 * 
 * @param event	 The event handle.
 * @param name	  Name of the event.
 * @dontBroadcast   If true, event is broadcasted to all clients, false if not.
 */
public Action EventPlayerSpawnPost(Handle timer, any client)
{
	// If client isn't in-game, then stop.
	if (!IsClientInGame(client))
	{
		return;
	}

	SEffectsOnClientSpawnPost(client);
}

/**
 * Event callback (player_hurt)
 * Client is being hurt.
 * 
 * @param event	 The event handle.
 * @param name	  Name of the event.
 * @dontBroadcast   If true, event is broadcasted to all clients, false if not.
 */
public Action EventPlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	// Get all required event info.
	int index = GetClientOfUserId(GetEventInt(event, "userid"));
	
	SEffectsOnClientHurt(index);


}

/**
 * Event callback (player_death)
 * Client has been killed.
 * 
 * @param event	 The event handle.
 * @param name	  Name of the event.
 * @dontBroadcast   If true, event is broadcasted to all clients, false if not.
 */
public Action EventPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	// Get all required event info.
	int index = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// Validate client.
	if (!ZRIsClientValid(index))
	{
		// If the client isn't a player, a player really didn't die now. Some
		// other mods might sent this event with bad data.
		return;
	}

	SEffectsOnClientDeath(index);
}