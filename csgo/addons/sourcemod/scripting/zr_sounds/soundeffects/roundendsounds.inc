/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  roundendsounds.inc
 *  Type:		  Core 
 *  Description:   Round End sound effects.
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
 * Path to sound files.
 */
char g_sSOUND_ROUNDEND_HUMANS[PLATFORM_MAX_PATH];
char g_sSOUND_ROUNDEND_ZOMBIE[PLATFORM_MAX_PATH];

/**
 * @endsection
 */

void RoundEndSoundsStart()
{
	if (!g_hCvarsList.g_bCVAR_ROUNDEND_SOUNDS)
	{
		return;
	}

	RoundEndSoundsGetRandomSound(g_aHumansSoundsArray, g_sSOUND_ROUNDEND_HUMANS, sizeof(g_sSOUND_ROUNDEND_HUMANS));
	RoundEndSoundsGetRandomSound(g_aZombisSoundsArray, g_sSOUND_ROUNDEND_ZOMBIE, sizeof(g_sSOUND_ROUNDEND_ZOMBIE));
}

void RoundEndSoundsEnd(int winner)
{
	if (!g_hCvarsList.g_bCVAR_ROUNDEND_SOUNDS)
	{
		return;
	}
	
	// Get Volume Cvar
	float LevelVolume = g_hCvarsList.g_fCVAR_ROUNDEND_VOLUME;
	
	switch(winner)
	{
		// Show "zombies win" RoundSoundsWim
		case CS_TEAM_T:
		{	
			//Check if any sound file has been recorded.
			if(strlen(g_sSOUND_ROUNDEND_ZOMBIE) == 0) return;
			
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
				// From Cliente Round end sound Zombis Wim.
				//RoundEndSoundsSoundFromClient(x, soundre, LevelVolume);
				RoundEndSoundsSoundFromClient(x, g_sSOUND_ROUNDEND_ZOMBIE, LevelVolume);
			}
		}
		// Show "humans win" RoundSoundsWim
		case CS_TEAM_CT:
		{
			//Check if any sound file has been recorded.
			if(strlen(g_sSOUND_ROUNDEND_HUMANS) == 0) return;
			
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
				// From Cliente Round end sound Humans Wim.
				RoundEndSoundsSoundFromClient(x, g_sSOUND_ROUNDEND_HUMANS, LevelVolume);
			}
		}
		// Show no overlay.
		default:
		{
			//strcopy(overlaypath, sizeof(overlaypath), "");
		}
	}
}

bool RoundEndSoundsGetRandomSound(ArrayList arraySounds, char[] soundre, int soundSize)
{
	// Choose a random integer from the sound file index.
	int randonsound = GetRandomInt(0, (arraySounds.Length - 1));
	
	//Get sound file from array
	arraySounds.GetString(randonsound, soundre, soundSize);
	
	//Check if any sound file has been recorded.
	if(strlen(soundre) != 0)
	{
		// Found sound.
		return true;
	}
	// No handled case was given.
	return false;
}

void RoundEndSoundsSoundFromClient(int client, const char[] soundre, float level = 1.0)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		// Emit sound from client.
		if (g_bZRoundEndCookie[client]) EmitSoundToClient(client, soundre, _, SNDCHAN_AUTO, _, _, level);
	}
}