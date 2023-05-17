#if defined _smrpg_helpers_included
  #endinput
#endif
#define _smrpg_helpers_included

#include <smrpg>

// Make sure sdktools isn't a required extension, but restore old define.
#if defined REQUIRE_EXTENSIONS
	#define REQUIRE_SDKTOOLS
#endif
#undef REQUIRE_EXTENSIONS
#include <sdktools>

#if defined REQUIRE_SDKTOOLS
	#define REQUIRE_EXTENSIONS
#endif
#undef REQUIRE_SDKTOOLS

/**
 * Wrapper to emit sound to all clients that have the sound effects activated for this upgrade.
 *
 * @param shortname     Shortname of the upgrade.
 * @param sample        Sound file name relative to the "sounds" folder.
 * @param entity        Entity to emit from.
 * @param channel       Channel to emit with.
 * @param level         Sound level.
 * @param flags         Sound flags.
 * @param volume        Sound volume.
 * @param pitch         Sound pitch.
 * @param speakerentity Unknown.
 * @param origin        Sound origin.
 * @param dir           Sound direction.
 * @param updatePos     Unknown (updates positions?)
 * @param soundtime     Alternate time to play sound for.
 * @error Invalid client index.
 */
stock void SMRPG_EmitSoundToAllEnabled(const char[] shortname, 
				 const char[] sample,
				 int entity = SOUND_FROM_PLAYER,
				 int channel = SNDCHAN_AUTO,
				 int level = SNDLEVEL_NORMAL,
				 int flags = SND_NOFLAGS,
				 float volume = SNDVOL_NORMAL,
				 int pitch = SNDPITCH_NORMAL,
				 int speakerentity = -1,
				 const float origin[3] = NULL_VECTOR,
				 const float dir[3] = NULL_VECTOR,
				 bool updatePos = true,
				 float soundtime = 0.0)
{
	int[] iClients = new int[MaxClients];
	int iNumClients;
	for(int i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && SMRPG_ClientWantsCosmetics(i, shortname, SMRPG_FX_Sounds))
			iClients[iNumClients++] = i;
	}

	if(!iNumClients)
		return;

	EmitSound(iClients, iNumClients, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

/**
 * Broadcasts the current temp entity to all clients that have the visual effects activated for this upgrade.
 * @note See TE_Start().
 *
 * @param shortname Shortname of the upgrade.
 * @param delay     Delay in seconds to send the TE.
 */
stock void SMRPG_TE_SendToAllEnabled(const char[] shortname, float delay=0.0)
{
	int[] iClients = new int[MaxClients];
	int iNumClients;
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && SMRPG_ClientWantsCosmetics(i, shortname, SMRPG_FX_Visuals))
		{
			iClients[iNumClients++] = i;
		}
	}
	TE_Send(iClients, iNumClients, delay);
}