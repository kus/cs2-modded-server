/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   volevents.inc
 *  Type:		   Module
 *  Description:	Handles generic events for volumetric features.
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
 * Called when a player enters a volume.
 *
 * @param client		The client index.
 * @param volumeIndex   The volume index.
 */
void VolOnPlayerEnter(int client, int volumeIndex)
{
	// Check if volumetric features is enabled.
	if (!VolEnabled)
	{
		// Volumetric features disabled.
		return;
	}
	
	LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Event", "Player %N entered volume %d.", client, volumeIndex);
	
	// Forward event to features.
	VolumeFeatureTypes voltype = Volumes[volumeIndex][Vol_Type];
	switch (voltype)
	{
		case VolFeature_ClassEdit:
		{
			VolClassEditOnPlayerEnter(client, volumeIndex);
		}
	}
}

/**
 * Called when a player leaves a volume.
 *
 * @param client		The client index.
 * @param volumeIndex   The volume index.
 */
void VolOnPlayerLeave(int client, int volumeIndex)
{
	// Check if volumetric features is enabled.
	if (!VolEnabled)
	{
		// Volumetric features disabled.
		return;
	}
	
	LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Event", "Player %N left volume %d.", client, volumeIndex);
	
	// Forward event to features.
	VolumeFeatureTypes voltype = Volumes[volumeIndex][Vol_Type];
	switch (voltype)
	{
		case VolFeature_Anticamp:
		{
			VolAnticampOnPlayerLeave(client, volumeIndex);
		}
		case VolFeature_ClassEdit:
		{
			VolClassEditOnPlayerLeave(client, volumeIndex);
		}
	}
}

/**
 * Called when a player spawned. Used for initializing player data.
 *
 * @param client	The client index.
 */
void VolOnPlayerSpawn(int client)
{
	// Check if volumetric features is enabled.
	if (!VolEnabled)
	{
		// Volumetric features disabled.
		return;
	}
	
	// Cache player location.
	VolUpdatePlayerLocation(client);
}

/**
 * Called when a player died.
 *
 * @param client	The client index.
 */
void VolOnPlayerDeath(int client)
{
	// Send player left volume event to all volumes the player was in.
	for (int volindex = 0; volindex < ZR_VOLUMES_MAX; volindex++)
	{
		// Check if volume is unused.
		if (!Volumes[volindex][Vol_InUse])
		{
			continue;
		}
		
		// Check if volume is disabled.
		if (!Volumes[volindex][Vol_Enabled])
		{
			continue;
		}
		
		// Check if player is inside the volume.
		if (VolPlayerInVolume[client][volindex])
		{
			// Mark as not in the volume and trigger event.
			VolPlayerInVolume[client][volindex] = false;
			VolOnPlayerLeave(client, volindex);
		}
	}
}

/**
 * Called when a player disconnects.
 *
 * @param client	The client index.
 */
void VolOnPlayerDisconnect(int client)
{
	// Disable trigger delay counters.
	VolResetCountDown(client);
	
	// Trigger death event to clean up.
	VolOnPlayerDeath(client);
}

/**
 * Called when the round starts. Main enable event for volumetric features.
 */
void VolOnRoundStart()
{
	// Check if volumetric features is enabled.
	if (!VolEnabled)
	{
		// Volumetric features disabled.
		return;
	}
	
	// Start main timer.
	VolStartUpdateTimer();
	
	// Start volumes.
	VolEnableVolumes();
}

/**
 * Called when the round ends. Main disable event for volumetric features.
 */
void VolOnRoundEnd()
{
	// Stop main timer.
	VolStopUpdateTimer();
	
	// Stop volumes.
	VolDisableVolumes();
}

/**
 * Called right before the map ends.
 */
void VolOnMapEnd()
{
	// Make sure timers and volumes are stopped. Foreward event.
	VolOnRoundEnd();
}

/**
 * Called when a volume is disabled.
 * @param volumeIndex   The volume index.
 */
void VolOnDisabled(int volumeIndex)
{
	// Check if volumetric features is enabled.
	if (!VolEnabled)
	{
		// Volumetric features disabled.
		return;
	}
	
	VolumeFeatureTypes voltype = Volumes[volumeIndex][Vol_Type];
	
	// Forward stop event to features.
	switch (voltype)
	{
		case VolFeature_Anticamp:
		{
			VolAnticampDisable(volumeIndex);
		}
		case VolFeature_ClassEdit:
		{
			VolClassEditOnDisabled(volumeIndex);
		}
	}
}

/**
 * Called when a volume is enabled.
 * @param volumeIndex   The volume index.
 */
void VolOnEnabled(int volumeIndex)
{
	// Check if volumetric features is enabled.
	if (!VolEnabled)
	{
		// Volumetric features disabled.
		return;
	}
	
	VolumeFeatureTypes voltype = Volumes[volumeIndex][Vol_Type];
	
	// Forward enable event to features.
	switch (voltype)
	{
		case VolFeature_Anticamp:
		{
			VolAnticampEnable(volumeIndex);
		}
	}
}
