/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   voltools.inc
 *  Type:		   Module
 *  Description:	Provides functions for managing volumes.
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
 * Returns wether a point is within a certain location.
 *
 * @param point	 The point to check.
 * @param min	   Minimum x, y and z values of the location.
 * @param max	   Maximum x, y and z values of the location.
 * @return		  True if the position is within min and max values. False
 *				  otherwise.
 */
bool IsPointInLocation(float point[3], float min[3], float max[3])
{
	// Cache to avoid re-indexing arrays.
	float posX = point[0];
	float posY = point[1];
	float posZ = point[2];
	
	// Check if within x boundaries.
	if ((posX >= min[0]) && (posX <= max[0]))
	{
		// Check if within y boundaries.
		if ((posY >= min[1]) && (posY <= max[1]))
		{
			// Check if within x boundaries.
			if ((posZ >= min[2]) && (posZ <= max[2]))
			{
				// The point is within the location boundaries.
				return true;
			}
		}
	}
	
	// The point is outside the location boundaries.
	return false;
}

/**
 * Returns wether a volume is marked as in use.
 *
 * Note: Does not validate index.
 *
 * @param volumeIndex   The volume index.
 * @return			  True if in use, false otherwise.
 */
bool VolInUse(int volumeIndex)
{
	return Volumes[volumeIndex][Vol_InUse];
}

/**
 * Returns wether a volume is enabled or not.
 *
 * Note: Does not validate index.
 *
 * @param volumeIndex   The volume index.
 * @return			  True if enabled, false otherwise.
 */
bool VolIsEnabled(int volumeIndex)
{
	return Volumes[volumeIndex][Vol_Enabled];
}

/**
 * Validates a volume index.
 *
 * @param volumeIndex   The volume index.
 * @return			  True if valid, false otherwise.
 */
bool VolIsValidIndex(int volumeIndex)
{
	if (volumeIndex >= 0 && volumeIndex < ZR_VOLUMES_MAX)
	{
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * Gets the first free volume index.
 *
 * @return	  The first free volume index if successful, or -1 if there are
 *			  no free volumes.
 */
int VolGetFreeVolume()
{
	// Loop through all volumes.
	for (int iVolumeIndex = 0; iVolumeIndex < ZR_VOLUMES_MAX; iVolumeIndex++)
	{
		// Check if it's free.
		if (!VolInUse(iVolumeIndex))
		{
			return iVolumeIndex;
		}
	}
	
	// No free volumes found.
	return -1;
}

/**
 * Gets a free index in the data array for the specified volume type.
 *
 * @param volumeType	Volumetric feature type.
 * @return			  Data index, or -1 on error.
 */
int VolGetFreeDataIndex(VolumeFeatureTypes volumeType)
{
	switch (volumeType)
	{
		case VolFeature_Anticamp:
		{
			return VolAnticampGetFreeIndex();
		}
		case VolFeature_ClassEdit:
		{
			return VolClassEditGetFreeIndex();
		}
	}
	
	// No match.
	return -1;
}

/**
 * Checks if the specified client match the team filtering for the specified
 * volume.
 *
 * @param client		The client index.
 * @param volumeIndex   The volume to check team filtering on.
 * @return			  True if client pass the team filtering, false otherwise.
 */
bool VolTeamFilterMatch(int client, int volumeIndex)
{
	VolumeTeamFilters filter;
	
	// Chache filter value.
	filter = Volumes[volumeIndex][Vol_TeamFilter];
	
	switch (filter)
	{
		case VolTeam_All:
		{
			// All maches everyone.
			return true;
		}
		case VolTeam_Humans:
		{
			// Check if client is a human.
			return InfectIsClientHuman(client);
		}
		case VolTeam_Zombies:
		{
			// Check if client is a zombie.
			return InfectIsClientInfected(client);
		}
	}
	
	// Invalid filter value.
	return false;
}

/**
 * Checs if a volume is a certain type.
 *
 * @param volumeIndex   Volume to check.
 * @param volType	   Type to match.
 * @return			  True if the types match, false otherwise.
 */
bool VolIsType(int volumeIndex, VolumeFeatureTypes volType)
{
	return Volumes[volumeIndex][Vol_Type] == volType;
}

/**
 * Gets wether a client is within volumes or not. Result is stored in a boolean
 * array.
 *
 * @param client	The client index.
 * @param buffer	Destination buffer.
 * @param maxlen	Size of destination buffer.
 * @return		  Number of volumes the client is within.
 */
int VolGetPlayerStates(int client, bool[] buffer, int maxlen)
{
	int volumeBuffer[VolumeAttributes];
	int volCount;
	
	float volMinBuffer[3];
	float volMaxBuffer[3];
	
	// Loop through all available volumes.
	for (int iVolumeIndex = 0; iVolumeIndex < ZR_VOLUMES_MAX && iVolumeIndex < maxlen; iVolumeIndex++)
	{
		if (VolInUse(iVolumeIndex))
		{
			// Chache volume to avoid re-indexing.
			volumeBuffer = Volumes[iVolumeIndex];
			
			// Get min positions.
			volMinBuffer[0] = volumeBuffer[Vol_xMin];
			volMinBuffer[1] = volumeBuffer[Vol_yMin];
			volMinBuffer[2] = volumeBuffer[Vol_zMin];
			
			// Get max positions.
			volMaxBuffer[0] = volumeBuffer[Vol_xMax];
			volMaxBuffer[1] = volumeBuffer[Vol_yMax];
			volMaxBuffer[2] = volumeBuffer[Vol_zMax];
			
			// Check the cached player location.
			if (IsPointInLocation(VolPlayerLoc[client], volMinBuffer, volMaxBuffer))
			{
				// Mark player as in volume.
				buffer[iVolumeIndex] = true;
				volCount++;
			}
			else
			{
				// Do explicit reset.
				buffer[iVolumeIndex] = false;
			}
		}
	}
	
	return volCount;
}

/**
 * Converts a string into a volumetric feature type.
 *
 * @param volType   String to convert. Name of type.
 * @return		  Volumetric feature type or VolFeature_Invalid on error.
 */
VolumeFeatureTypes VolGetTypeFromString(const char[] volType)
{
	// Check if empty.
	if (strlen(volType) == 0)
	{
		return VolFeature_Invalid;
	}
	
	// Match types.
	if (StrEqual(volType, "anticamp", false))
	{
		return VolFeature_Anticamp;
	}
	else if (StrEqual(volType, "classedit", false))
	{
		return VolFeature_ClassEdit;
	}
	
	// No match.
	return VolFeature_Invalid;
}

/**
 * Converts a volume type to a string.
 *
 * @param volType	   Volume type to convert.
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of destination buffer.
 * @param shortName	 Optional. Write short name or human readable name.
 *					  Default is human readable (false).
 * @return			  Number of cells written.
 */
int VolTypeToString(VolumeFeatureTypes volType, char[] buffer, int maxlen, bool shortName = false)
{
	switch (volType)
	{
		case VolFeature_Invalid:
		{
			return shortName ? strcopy(buffer, maxlen, "") : strcopy(buffer, maxlen, "(none)");
		}
		case VolFeature_Anticamp:
		{
			return shortName ? strcopy(buffer, maxlen, "anticamp") : strcopy(buffer, maxlen, "Anti-Camp");
		}
		case VolFeature_ClassEdit:
		{
			return shortName ? strcopy(buffer, maxlen, "classedit") : strcopy(buffer, maxlen, "Class Editor");
		}
	}
	
	return 0;
}
