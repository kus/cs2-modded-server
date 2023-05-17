/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  soundeffects.inc
 *  Type:		  Core 
 *  Description:   Basic sound-management API.
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
 * Maximum sound path length.
 */
#define SOUND_MAX_PATH 128

/**
 * Ambient sound channel.
 */
#define SOUND_AMBIENT_CHANNEL 8

#include "zr_sounds/soundeffects/zrsounds"
#include "zr_sounds/soundeffects/voice"
#include "zr_sounds/soundeffects/ambientsounds"
#include "zr_sounds/soundeffects/zombiesounds"
#include "zr_sounds/soundeffects/countdownsounds"
#include "zr_sounds/soundeffects/roundendsounds"

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void SEffectsClientInit(int client)
{
	// Forward event to sub-modules.
	AmbientSoundsClientInit(client);
	ZombieSoundsClientInit(client);
}

/**
 * The round is starting.
 */
void SEffectsOnRoundStart()
{
	// Forward event to sub-modules.
	VoiceOnRoundStart();
	AmbientSoundsOnRoundStart();
	RoundEndSoundsStart();
}

/**
 * The round is ending.
 */
void SEffectsOnRoundEnd(int winner)
{
	// Forward event to sub-modules.
	VoiceOnRoundEnd();
	AmbientSoundsOnRoundEnd();
	ZombieSoundsOnRoundEnd();
	RoundEndSoundsEnd(winner);
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void SEffectsOnClientSpawn(int client)
{
	// Forward event to sub-modules.
	VoiceOnClientSpawn(client);
	ZombieSoundsOnClientSpawn(client);
}

/**
 * Client is spawning into the game. *Post
 * 
 * @param client	The client index.
 */
void SEffectsOnClientSpawnPost(int client)
{
	// Forward event to sub-modules.
	CreateTimer(1.0, AmbientSoundsOnClientSpawnPost, client);
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void SEffectsOnClientDeath(int client)
{
	// Forward event to sub-modules.
	ZombieSoundsOnClientDeath(client);
}

/**
 * Client has been hurt.
 * 
 * @param client	The client index.
 */
void SEffectsOnClientHurt(int client)
{
	// Forward event to sub-modules.
	ZombieSoundsOnClientHurt(client);
}

/**
 * Client has been infected.
 * 
 * @param client	The client index.
 */
void SEffectsOnClientInfected(int client)
{
	// Forward event to sub-modules.
	VoiceOnClientInfected(client);
	ZombieSoundsOnClientInfected(client);
}

/**
 * Client has been turned back human.
 * 
 * @param client	The client index.
 */
void SEffectsOnClientHuman(int client)
{
	// Forward event to sub-modules.
	VoiceOnClientHuman(client);
}

/**
 * Emits an ambient sound
 * 
 * @param sound		 The path to the sound file (relative to sounds/)
 * @param soundvolume   The volume of the sound (0.0 - 1.0)
 * @param client		(Optional) Client index to play sound to.
 */
 
void SEffectsEmitAmbientSound(const char[] sound, float ambientvolume = 1.0, int client = -1)
{
	if (ZRIsClientValid(client))
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && !bAmbientSoundsIsPlaying[client])
		{
			// Emit ambient sound.
			EmitSoundToClient(client, sound, _, SNDCHAN_AUTO, _, _, ambientvolume);

			// Flag client that sound is playing.
			bAmbientSoundsIsPlaying[client] = true;
		}
	}
	else
	{
		for (int x = 1; x <= MaxClients; x++)
		{
			// If client isn't in-game, then stop.
			if (IsClientInGame(x) && !IsFakeClient(x) && !bAmbientSoundsIsPlaying[x])
			{
				// Emit ambient sound.
				EmitSoundToClient(x, sound, _, SNDCHAN_AUTO, _, _, ambientvolume);

				// Flag client that sound is playing.
				bAmbientSoundsIsPlaying[x] = true;
			}
		}
	}
}

/**
 * Stop an ambient sound
 *  
 * @param sound	 The path to the sound file (relative to sounds/) 
 */

void SEffectsStopAmbientSound(const char[] sound)
{
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (IsClientInGame(x) && !IsFakeClient(x))
		{
			// Stop ambient sound.
			StopSound(x, SNDCHAN_AUTO, sound);
			bAmbientSoundsIsPlaying[x] = false;
		}
	}
}

/**
 * Replay an ambient sound
 * 
 * @param sound	 The path to the sound file (relative to sounds/)
 */

/**
 * Emits a sound from a client.
 * 
 * @param client	The client index.
 * @param sound	 The sound file relative to the sound/ directory.
 * @param level	 The attenuation of the sound.
 */

void SEffectsEmitSoundFromClient(int client, const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			// Emit sound from client.
			if (g_bZombiesECookie[i]) EmitSoundToClient(i, sound, client, SNDCHAN_AUTO, _, _, g_fZrSoundsCookie[i]);
		}
	}
}
