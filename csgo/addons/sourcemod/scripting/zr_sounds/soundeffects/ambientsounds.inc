/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  ambientsounds.inc
 *  Type:		  Core 
 *  Description:   Plays ambient sounds to clients.
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
 * Global variable to store ambient sounds timer handle.
 */
Handle tAmbientSounds = INVALID_HANDLE;

/**
 * Array for flagging client to play sound.
 */
bool bAmbientSoundsIsPlaying[MAXPLAYERS + 1]; 

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void AmbientSoundsClientInit(int client)
{
	// Reset flag to play sound on client.
	bAmbientSoundsIsPlaying[client] = false;
}

/**
 * Map is starting.
 */
void AmbientSoundsOnMapStart()
{
	// Reset timer handle.
	tAmbientSounds = INVALID_HANDLE;
}

/**
 * The round is starting.
 */
void AmbientSoundsOnRoundStart()
{
	// x = client index
	for (int x = 1; x <= MaxClients; x++)
	{
		bAmbientSoundsIsPlaying[x] = false;
	}
	// Restart ambient sound for all clients.
	if (g_hCvarsList.g_bCVAR_AMBIENTSOUNDS) AmbientSoundsRestart();
}

/**
 * The round is ending.
 */
void AmbientSoundsOnRoundEnd()
{
	// If timer is running, kill it.
	if (tAmbientSounds != INVALID_HANDLE)
	{
		KillTimer(tAmbientSounds);
		tAmbientSounds = INVALID_HANDLE;
	}

	// If ambience is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_AMBIENTSOUNDS)
	{
		return;
	}

	// Stop sound before playing again.
	SEffectsStopAmbientSound(g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE);
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
public Action AmbientSoundsOnClientSpawnPost(Handle abstime, any client)
{
	// If ambience is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_AMBIENTSOUNDS)
	{
		return;
	}

	// If flag is enabled, then stop.
	if (!IsClientInGame(client) || IsFakeClient(client) || bAmbientSoundsIsPlaying[client])
	{
		return;
	}

	// Emit ambient sound.
	SEffectsEmitAmbientSound(g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE, g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_VOLUME, client);
}

/**
 * Restart ambient sound for all clients.
 */
void AmbientSoundsRestart()
{
	// If timer is running, kill it.
	if (tAmbientSounds != INVALID_HANDLE)
	{
		KillTimer(tAmbientSounds);
		tAmbientSounds = INVALID_HANDLE;
	}
	
	// If ambience is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_AMBIENTSOUNDS)
	{
		return;
	}
	
	// Start ambient sounds timer.
	tAmbientSounds = CreateTimer(g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_LENGTH, AmbientSoundsTimer, _, TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * Timer callback, Replays ambient sound on all clients.
 * 
 * @param timer	 The timer handle.  
*/
public Action AmbientSoundsTimer(Handle timer)
{
	// If ambience is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_AMBIENTSOUNDS)
	{
		return;
	}
	
	// Stop sound before playing again.
	SEffectsStopAmbientSound(g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE);
	
	// Emit ambient sound.
	SEffectsEmitAmbientSound(g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE, g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_VOLUME);
	
	// Start new timer with sound length as delay.
	tAmbientSounds = CreateTimer(g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_LENGTH, AmbientSoundsTimer, _, TIMER_FLAG_NO_MAPCHANGE);
}
