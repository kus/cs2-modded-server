/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  voice.inc
 *  Type:		  Module
 *  Description:   Alter listening/speaking states of humans/zombies.
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
 * Updates every round with the value of the cvar.
 */
bool g_bVoice;

/**
 * The round is starting.
 */
void VoiceOnRoundStart()
{
	// If the cvar has changed, then reset the voice permissions.
	if (g_bVoice != g_hCvarsList.g_bCVAR_VOICE)
	{
		VoiceReset();
	}
	
	// Update g_bVoice with new value.
	g_bVoice = g_hCvarsList.g_bCVAR_VOICE;
}

/**
 * The round is ending.
 */
void VoiceOnRoundEnd()
{
	// If voice module is disabled, then stop.
	if (!g_bVoice)
	{
		return;
	}
	
	// Allow everyone to listen/speak with each other.
	VoiceAllTalk();
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void VoiceOnClientSpawn(int client)
{
	// Give client proper verbal permissions.
	VoiceUpdateClient(client);
}

/**
 * Client has been infected.
 * 
 * @param client	The client index.
 */
void VoiceOnClientInfected(int client)
{
	// Give client proper verbal permissions.
	VoiceUpdateClient(client);
}

/**
 * Client has been turned back human.
 * 
 * @param client	The client index.
 */
void VoiceOnClientHuman(int client)
{
	// Give client proper verbal permissions.
	VoiceUpdateClient(client);
}

/**
 * Set the receiver ability to listen to the sender.
 * Note:  This function is from sdktools_voice, it fails if iSender is muted.
 *
 * @param iReceiver		The listener index.
 * @param iSender		The sender index.
 * @return				True if successful otherwise false.
 */
stock bool VoiceSetClientListening(int iReceiver, int iSender, bool bListen)
{
	// If the sender is muted, then return false.
	if (VoiceIsClientMuted(iSender))
	{
		return false;
	}
	
	ListenOverride override = bListen ? Listen_Yes : Listen_No;
	
	return SetListenOverride(iReceiver, iSender, override);
}

/**
 * Allow all clients to listen and speak with each other.
 */
stock void VoiceAllTalk()
{
	// x = Receiver index.
	// y = Sender index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If receiver isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		for (int y = 1; y <= MaxClients; y++)
		{
			// If sender isn't in-game, then stop.
			if (!IsClientInGame(y))
			{
				continue;
			}
			
			// No need to alter listening/speaking flags between one client.
			if (x == y)
			{
				continue;
			}
			
			// Receiver (x) can now hear the sender (y), only if sender isn't muted.
			VoiceSetClientListening(x, y, true);
		}
	}
}

/**
 * Set which team the client is allowed to listen/speak with.
 * 
 * @param client	The client index.
 * @param zombie	True to permit verbal communication to zombies only, false for humans only.
 */
stock void VoiceSetClientTeam(int client, bool zombie)
{
	// x = Client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If sender isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// No need to alter listening/speaking flags between one client.
		if (client == x)
		{
			continue;
		}
		
		// Client can only listen/speak if the sender is on their team.
		bool canlisten = (zombie == InfectIsClientInfected(x));
		
		// (Dis)allow clients to listen/speak with each other, don't touch if the sender is muted.
		VoiceSetClientListening(client, x, canlisten);
		VoiceSetClientListening(x, client, canlisten);
	}
}

/**
 * Update a client's listening/speaking status.
 * 
 * @param client	The client index.
 */
stock void VoiceUpdateClient(int client)
{
	// If voice module is disabled, then stop.
	if (!g_bVoice)
	{
		return;
	}
	
	// Set the client's listening/speaking status to their current team.
	VoiceSetClientTeam(client, InfectIsClientInfected(client));
}

/**
 * This function returns if the client is muted.
 * 
 * @param client	The client index.
 * @return		  True if the client is muted, false if not.
 */
stock bool VoiceIsClientMuted(int client)
{
	// Return true if the mute flag isn't on the client.
	return view_as<bool>((GetClientListeningFlags(client) & VOICE_MUTED));
}

/**
 * Reset voice listening/speaking permissions back to normal according to sv_alltalk.
 */
stock void VoiceReset()
{
	// Is alltalk enabled?
	bool alltalk = GetConVarBool(FindConVar("sv_alltalk"));
	
	// Determine new voice flags based off of alltalk.
	int voiceflags = alltalk ? VOICE_SPEAKALL | VOICE_LISTENALL : VOICE_TEAM | VOICE_LISTENTEAM;
	
	// x = Client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// Apply new voice flags.
		SetClientListeningFlags(x, voiceflags);
	}
}