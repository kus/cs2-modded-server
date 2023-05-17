/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  roundend.inc
 *  Type:		  Core
 *  Description:   Handles round end actions.
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
 * Delay between round ending and new round starting. (Normal)
 */
#define ROUNDEND_DELAY 5.0
 
/**
 * Possible round end outcomes.
 */
enum RoundEndOutcome
{
	Restart,		/** Round is restarting. */
	Draw,		   /** Round has ended in unexpected way. */
	HumansWin,	  /** Humans have killed all zombies. */
	ZombiesWin,	 /** Zombies have infected all humans. */
}

/**
 * Global variable to store round win timer handle.
 */
Handle tRoundEnd = INVALID_HANDLE;

/**
 * Map is starting.
 */ 
void RoundEndOnMapStart()
{
	// Reset timer handle.
	tRoundEnd = INVALID_HANDLE;
}

/**
 * Client has been killed.
 */
void RoundEndOnClientDeath()
{
	// Terminate the round if the last player was killed.
	RoundEndOutcome outcome;
	if (RoundEndGetRoundStatus(outcome))
	{
		RoundEndTerminateRound(ROUNDEND_DELAY, outcome);
	}
}

/**
 * Client has been infected.
 */
void RoundEndOnClientInfected()
{
	// Terminate the round if the last player was infected.
	RoundEndOutcome outcome;
	if (RoundEndGetRoundStatus(outcome))
	{
		RoundEndTerminateRound(ROUNDEND_DELAY, outcome);
	}
}

/**
 * The round is starting.
 */
void RoundEndOnRoundStart()
{
	// Stop all overlays.
	RoundEndOverlayStop();
	
	// If round end timer is running, then kill it.
	if (tRoundEnd != INVALID_HANDLE)
	{
		// Kill timer.
		KillTimer(tRoundEnd);
		
		// Reset timer handle.
		tRoundEnd = INVALID_HANDLE;
	}
}

/**
 * The freeze time is ending.
 */
void RoundEndOnRoundFreezeEnd()
{
	// Calculate round length, in seconds.
	// Get mp_roundtime. (in minutes)
	float roundtime = GetConVarFloat(FindConVar("mp_roundtime"));
	
	// Convert to seconds.
	roundtime *= 60.0;
	
	// Subtract one second if running CS: GO to prevent round draw when round
	// ends. For some reason the timing doesn't match the actual round end.
	// Thanks to Jargon.
	if (g_Game == Game_CSGO)
	{
		roundtime--;
	}
	
	// Start timer.
	tRoundEnd = CreateTimer(roundtime, RoundEndTimer, _, TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * The round is ending.
 * 
 * @param winner	winner
 */
void RoundEndOnRoundEnd(int winner)
{
	// If round end timer is running, then kill it.
	if (tRoundEnd != INVALID_HANDLE)
	{
		// Kill timer.
		KillTimer(tRoundEnd);
		
		// Reset timer handle.
		tRoundEnd = INVALID_HANDLE;
	}
	
	// Tell plugin no zombies have been spawned.
	g_bZombieSpawned = false;
	
	// Update team scores.
	int teamscore;
	switch(winner)
	{
		// Zombies won the round.
		case CS_TEAM_T:
		{
			// Increment T score.
			teamscore = GetTeamScore(CS_TEAM_T);
			SetTeamScore(CS_TEAM_T, ++teamscore);
		}
		// Humans won the round.
		case CS_TEAM_CT:
		{
			// Increment CT score.
			teamscore = GetTeamScore(CS_TEAM_CT);
			SetTeamScore(CS_TEAM_CT, ++teamscore);
		}
	}
	
	// Display the overlay to all clients.
	RoundEndOverlayStart(winner);
	
	// Balance teams if enabled.
	if (GetConVarBool(g_hCvarsList[CVAR_ROUNDEND_BALANCE_TEAMS]))
	{
		RoundEndBalanceTeams();
	}
}

/**
 * Timer callback, called when round time reaches 0.
 *
 * @param timer	 The timer handle.
 */
public Action RoundEndTimer(Handle timer)
{
	// Set the global timer handle variable to INVALID_HANDLE.
	tRoundEnd = INVALID_HANDLE;
	
	// If there aren't clients on both teams, then stop.
	if (!ZRTeamHasClients())
	{
		return;
	}
	
	// Terminate the round with humans as the winner.
	RoundEndTerminateRound(ROUNDEND_DELAY, HumansWin);
}

/**
 * Checks if the round is over.
 * 
 * @param outcome   Set to the outcome of the round, if round is over.
 * @return		  True if the round is over, false otherwise.
 */
bool RoundEndGetRoundStatus(RoundEndOutcome &outcome)
{
	// If zombie hasn't spawned, then stop.
	if (!g_bZombieSpawned)
	{
		// Round isn't over.
		return false;
	}
	
	// Initialize count variables
	int zombiecount;
	int humancount;
	
	// Count valid clients. (true to only allow living clients)
	ZRCountValidClients(zombiecount, humancount, true);
	
	// If there are no clients on either teams, then stop.
	if (!zombiecount && !humancount)
	{
		// Round isn't active.
		return false;
	}
	
	// If there are clients on both teams, then stop.
	if (zombiecount && humancount)
	{
		// Round isn't over.
		return false;
	}
	
	// We know here, that either zombiecount or humancount is 0. (not both)
	
	// If there are zombies, then zombies won the round.
	if (zombiecount)
	{
		outcome = ZombiesWin;
	}
	// If there are no zombies, that means there must be humans, they win the round.
	else
	{
		outcome = HumansWin;
	}
	
	// Round is over.
	return true;
}

/**
 * Ends the round with the given outcome and delay.
 * 
 * @param delay	 Delay before new round starts. 
 * @param outcome   The outcome of the round.
 */
void RoundEndTerminateRound(float delay, RoundEndOutcome outcome = Restart)
{
	switch(outcome)
	{
		// Round is restarting.
		case Restart:
		{
			CS_TerminateRound(delay, CSRoundEnd_GameStart, false);
		}
		// Round was a draw.
		case Draw:
		{
			CS_TerminateRound(delay, CSRoundEnd_Draw, false);
		}
		// Zombies won.
		case ZombiesWin:
		{
			CS_TerminateRound(delay, CSRoundEnd_TerroristWin, false);
		}
		// Humans won.
		case HumansWin:
		{
			CS_TerminateRound(delay, CSRoundEnd_CTWin, false);
		}
	}
}

/**
 * Balances teams.
 */
void RoundEndBalanceTeams()
{
	// Create eligible player list.
	Handle arrayEligibleClients = INVALID_HANDLE;
	int eligibleclients = ZRCreateEligibleClientList(arrayEligibleClients, true);
	
	// If there are no eligible client's then stop.
	if (!eligibleclients)
	{
		// Destroy handle.
		CloseHandle(arrayEligibleClients);
		
		return;
	}
	
	int client;
	
	// Move all clients to T
	
	// x = Array index.
	// client = client index.
	for (int x = 0; x < eligibleclients; x++)
	{
		// Get client stored in array index.
		client = GetArrayCell(arrayEligibleClients, x);
		
		// Switch client to T
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	
	// Move every other client back to CT
	
	// x = array index
	// client = client index.
	for (int x = 0; x < eligibleclients; x += 2)
	{
		// Get client stored in array index.
		client = GetArrayCell(arrayEligibleClients, x);
		
		// Switch client to CT
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	
	// Destroy handle.
	CloseHandle(arrayEligibleClients);
}

/**
 * Displays overlays to clients, depending on the winner.
 * 
 * @param time	  Time to display overlays.
 * @param winner   The winner of the round.
 */
void RoundEndOverlayStart(int winner)
{
	// If round end overlays are disabled, then stop.
	bool overlay = GetConVarBool(g_hCvarsList[CVAR_ROUNDEND_OVERLAY]);
	if (!overlay)
	{
		return;
	}
	
	char overlaypath[PLATFORM_MAX_PATH];
	
	switch(winner)
	{
		// Show "zombies win" overlay.
		case CS_TEAM_T:
		{
			GetConVarString(g_hCvarsList[CVAR_ROUNDEND_OVERLAY_ZOMBIE], overlaypath, sizeof(overlaypath));
		}
		// Show "humans win" overlay.
		case CS_TEAM_CT:
		{
			GetConVarString(g_hCvarsList[CVAR_ROUNDEND_OVERLAY_HUMAN], overlaypath, sizeof(overlaypath));
		}
		// Show no overlay.
		default:
		{
			strcopy(overlaypath, sizeof(overlaypath), "");
		}
	}
	
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If client is fake (or bot), then stop.
		if (IsFakeClient(x))
		{
			continue;
		}
		
		OverlaysClientSetChannelPath(x, OVERLAYS_CHANNEL_ROUNDEND, overlaypath);
		OverlaysClientSetChannelState(x, OVERLAYS_CHANNEL_ROUNDEND, true, false, true);
	}
}

void RoundEndOverlayStop()
{
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If client is fake (or bot), then stop.
		if (IsFakeClient(x))
		{
			continue;
		}
		
		// Disable roundend overlay channel.
		OverlaysClientSetChannelState(x, OVERLAYS_CHANNEL_ROUNDEND, true, false, false, true);
	}
}