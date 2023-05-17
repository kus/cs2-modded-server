/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   volcommands.inc
 *  Type:		   Module
 *  Description:	Command handler for volumetric features.
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

/*
Add volume
------------

Syntax:

	zr_vol_add <x1> <y1> <z1> <x2> <y2> <z2> <type> [params]

Parameters:

	zn, yn, zn	  Max and min location.
	type			Feature type.
	params		  A string with optional parameters:
						team=all|humans|zombies
						delay=0
						effect=none|wireframe|smoke
						effect_color=0,0,0
						enabled=1

Example:

	zr_vol_add 0 0 0 100 200 300 anticamp team=humans delay=5 amount=100
*/


/**
 * Creates commands for managing volumes.
 */
void VolOnCommandsCreate()
{
	RegConsoleCmd("zr_vol_add", VolAddVolumeCommand, "Creates a rectangular volume in the map. Usage: zr_vol_add <x1> <y1> <z1> <x2> <y2> <z2> <type> [params]");
	RegConsoleCmd("zr_vol_remove", VolRemoveVolumeCommand, "Removes an existing volume in the map. Usage: zr_vol_remove <volume index>");
	RegConsoleCmd("zr_vol_list", VolListCommand, "Lists existing volumes in the map, or dumps detail data to the specified volume. Usage: zr_vol_list [volume index]");
	RegConsoleCmd("zr_vol_dumpstates", VolDumpStatesCommand, "Dumps volume states for the specified player. Usage: zr_vol_dumpstates <index|targetname>");
}

/**
 * Command callback for creating a new volume.
 */
public Action VolAddVolumeCommand(int client, int argc)
{
	char buffer[640];
	buffer[0] = 0;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}

	if (argc < 7)
	{
		// Write syntax info.
		StrCat(buffer, sizeof(buffer), "Creates a rectangular volume in the map. Usage: zr_vol_add <x1> <y1> <z1> <x2> <y2> <z2> <type> [params]\n\n");
		StrCat(buffer, sizeof(buffer), "Parameters:\n");
		StrCat(buffer, sizeof(buffer), "x1, y1, z1  Coordinates to first corner (any corner)\n");
		StrCat(buffer, sizeof(buffer), "x2, y2, z2  Coordinates to oposite corner (diagonally to oposite height)\n");
		StrCat(buffer, sizeof(buffer), "type		Volumetric feature type:\n");
		StrCat(buffer, sizeof(buffer), "				anticamp\n");
		StrCat(buffer, sizeof(buffer), "				classedit\n");
		StrCat(buffer, sizeof(buffer), "params	  Parameter string with additional volume data. Generic parameters:\n");
		StrCat(buffer, sizeof(buffer), "				teamfilter=all|humans|zombies\n");
		StrCat(buffer, sizeof(buffer), "				delay=0\n");
		StrCat(buffer, sizeof(buffer), "				effect=none|wireframe|smoke\n");
		StrCat(buffer, sizeof(buffer), "				effect_color=0,0,0\n");
		StrCat(buffer, sizeof(buffer), "				enabled=1");
		
		ReplyToCommand(client, buffer);
		return Plugin_Handled;
	}
	
	float x1;
	float y1;
	float z1;
	float x2;
	float y2;
	float z2;
	float min[3];
	float max[3];
	VolumeFeatureTypes voltype;
	float floatbuffer;
	int volindex;
	int dataindex;
	int paramcount;
	
	char params[512];
	char argbuffer[256];
	
	params[0] = 0;
	
	// Get a free volume index.
	volindex = VolGetFreeVolume();
	
	// Validate index.
	if (!VolIsValidIndex(volindex))
	{
		ReplyToCommand(client, "Cannot add volume. Maximum number of volumes reached.");
		return Plugin_Handled;
	}	
	
	// Get positions.
	GetCmdArg(1, argbuffer, sizeof(argbuffer));
	x1 = StringToFloat(argbuffer);
	
	GetCmdArg(2, argbuffer, sizeof(argbuffer));
	y1 = StringToFloat(argbuffer);
	
	GetCmdArg(3, argbuffer, sizeof(argbuffer));
	z1 = StringToFloat(argbuffer);
	
	GetCmdArg(4, argbuffer, sizeof(argbuffer));
	x2 = StringToFloat(argbuffer);
	
	GetCmdArg(5, argbuffer, sizeof(argbuffer));
	y2 = StringToFloat(argbuffer);
	
	GetCmdArg(6, argbuffer, sizeof(argbuffer));
	z2 = StringToFloat(argbuffer);
	
	// Check if both locations are equal.
	if (FloatCompare(x1, x2) == 0)
	{
		if (FloatCompare(y1, y2) == 0)
		{
			if (FloatCompare(z1, z2) == 0)
			{
				ReplyToCommand(client, "Cannot add volume. Both locations are equal.");
				return Plugin_Handled;
			}
		}
	}
	
	// Sort out max and min values so 1-values are smaller.
	if (FloatCompare(x1, x2) == 1)
	{
		// x1 is bigger than x2. Swap values.
		floatbuffer = x1;
		x1 = x2;
		x2 = floatbuffer;
	}
	if (FloatCompare(y1, y2) == 1)
	{
		// y1 is bigger than y2. Swap values.
		floatbuffer = y1;
		y1 = y2;
		y2 = floatbuffer;
	}
	if (FloatCompare(z1, z2) == 1)
	{
		// z1 is bigger than z2. Swap values.
		floatbuffer = z1;
		z1 = z2;
		z2 = floatbuffer;
	}
	
	// Copy coordinates to location vectors.
	min[0] = x1;
	min[1] = y1;
	min[2] = z1;
	max[0] = x2;
	max[1] = y2;
	max[2] = z2;
	
	// Get volume type.
	GetCmdArg(7, argbuffer, sizeof(argbuffer));
	voltype = VolGetTypeFromString(argbuffer);
	
	// Validate volume type.
	if (voltype == VolFeature_Invalid)
	{
		ReplyToCommand(client, "Cannot add volume. Invalid volume type: %s", argbuffer);
		return Plugin_Handled;
	}
	
	// Get free data index for the specified type.
	dataindex = VolGetFreeDataIndex(voltype);
	
	// Validate data index.
	if (dataindex < 0)
	{
		ReplyToCommand(client, "Cannot add volume. Out of free data indexes for type \"%s\"", argbuffer);
		return Plugin_Handled;
	}
	
	// Add volume.
	volindex = VolAdd(volindex, min, max, voltype, dataindex);
	
	// Get additional parameters if they exist.
	if (argc >= 8)
	{
		// Join the last parameters in a string.
		for (int arg = 8; arg <= argc; arg++)
		{
			GetCmdArg(arg, argbuffer, sizeof(argbuffer));
			StrCat(params, sizeof(params), argbuffer);
			
			// Add space, except on the last parameter.
			if (arg < argc)
			{
				StrCat(params, sizeof(params), " ");
			}
		}
		
		// Set attributes.
		paramcount = VolSetAttributes(volindex, params);
	}
	else
	{
		// No attributes set.
		paramcount = 0;
	}
	
	if (paramcount < 1)
	{
		Format(buffer, sizeof(buffer), "No additional attributes set.");
	}
	else
	{
		Format(buffer, sizeof(buffer), "Additional attributes set: %d", paramcount);
	}
	
	// Send enable event to volume.
	VolOnEnabled(volindex);
	
	ReplyToCommand(client, "Added volume at index %d. %s", volindex, buffer);
	return Plugin_Handled;
}

/**
 * Command callback for removing a volume.
 */
public Action VolRemoveVolumeCommand(int client, int argc)
{
	char arg[16];
	int volindex;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	if (argc < 1)
	{
		// Write syntax info.
		ReplyToCommand(client, "Removes an existing volume in the map. Usage: zr_vol_remove <volume index>");
		return Plugin_Handled;
	}
	
	// Get volume index.
	GetCmdArg(1, arg, sizeof(arg));
	volindex = StringToInt(arg);
	
	// Validate index.
	if (!VolIsValidIndex(volindex))
	{
		ReplyToCommand(client, "Invalid volume index.");
		return Plugin_Handled;
	}
	
	// Check if volume exist.
	if (!Volumes[volindex][Vol_InUse])
	{
		ReplyToCommand(client, "Volume %d doesn't exist.", volindex);
		return Plugin_Handled;
	}
	
	// Remove volume.
	VolRemove(volindex);
	
	ReplyToCommand(client, "Successfully disabled and removed volume %d.", volindex);
	return Plugin_Handled;
}

/**
 * Command callback for listing volumes or dumping data.
 */
public Action VolListCommand(int client, int argc)
{
	char buffer[1022];	   // Two chars reserved for newline and null terminator.
	char linebuffer[128];
	char valuebuffer[32];
	char arg[16];
	
	buffer[0] = 0;
	linebuffer[0] = 0;
	
	int volindex;
	int volcount;
	int volcache[VolumeAttributes];
	
	if (argc < 1)
	{
		// No volume specified. Display syntax and list volumes.
		StrCat(buffer, sizeof(buffer), "Lists existing volumes in the map, or dumps detail data to the specified volume. Usage: zr_vol_list [volume index]\n\n");
		StrCat(buffer, sizeof(buffer), "ID:  Type:		   Min loc:						Max loc:\n");
		StrCat(buffer, sizeof(buffer), "--------------------------------------------------------------------------------");
		ReplyToCommand(client, buffer);
		
		// Loop through all indexes.
		for (volindex = 0; volindex < ZR_VOLUMES_MAX; volindex++)
		{
			// Check if in use.
			if (Volumes[volindex][Vol_InUse])
			{
				// Cache volume data.
				volcache = Volumes[volindex];
				
				// Add to list.
				VolTypeToString(volcache[Vol_Type], valuebuffer, sizeof(valuebuffer), true);
				Format(linebuffer, sizeof(linebuffer), "%-4d %-15s %-8.2f %-8.2f %-8.2f	  %-8.2f %-8.2f %-8.2f",
					volindex,
					valuebuffer,
					volcache[Vol_xMin],
					volcache[Vol_yMin],
					volcache[Vol_zMin],
					volcache[Vol_xMax],
					volcache[Vol_yMax],
					volcache[Vol_zMax]);
				
				ReplyToCommand(client, linebuffer);
				volcount++;
			}
		}
		
		Format(linebuffer, sizeof(linebuffer), "\nTotal volumes: %d", volcount);
		ReplyToCommand(client, linebuffer);
		return Plugin_Handled;
	}
	else
	{
		// Dump data for the specified volume.
		
		// Get volume index.
		GetCmdArg(1, arg, sizeof(arg));
		volindex = StringToInt(arg);
		
		// Validate index.
		if (!VolIsValidIndex(volindex))
		{
			ReplyToCommand(client, "The specified volume index is invalid: %d", volindex);
			return Plugin_Handled;
		}
		
		// Check if unused.
		if (!VolInUse(volindex))
		{
			ReplyToCommand(client, "The specified volume doesn't exist: %d.", volindex);
			return Plugin_Handled;
		}
		
		// Cache volume data.
		volcache = Volumes[volindex];
		
		// Dump generic volume data.
		Format(linebuffer, sizeof(linebuffer), "Volume data at index %d:\n", volindex);
		StrCat(buffer, sizeof(buffer), linebuffer);
		StrCat(buffer, sizeof(buffer), "--------------------------------------------------------------------------------");
		ReplyToCommand(client, buffer);
		
		// Clear buffer.
		buffer[0] = 0;
		
		Format(linebuffer, sizeof(linebuffer), "ID:				 %d\n", volindex);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		Format(linebuffer, sizeof(linebuffer), "Enabled:			%d\n", volcache[Vol_Enabled]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		VolTypeToString(volcache[Vol_Type], valuebuffer, sizeof(valuebuffer));
		Format(linebuffer, sizeof(linebuffer), "Type:			   %s\n", valuebuffer);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		Format(linebuffer, sizeof(linebuffer), "Min loc:			%-8.2f %-8.2f %-8.2f\n", volcache[Vol_xMin], volcache[Vol_yMin], volcache[Vol_zMin]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		Format(linebuffer, sizeof(linebuffer), "Max loc:			%-8.2f %-8.2f %-8.2f\n", volcache[Vol_xMax], volcache[Vol_yMax], volcache[Vol_zMax]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		VolEffectToString(volcache[Vol_Effect], valuebuffer, sizeof(valuebuffer));
		Format(linebuffer, sizeof(linebuffer), "Effect:			 %s\n", valuebuffer);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		Format(linebuffer, sizeof(linebuffer), "Effect color:	   %d, %d, %d\n", volcache[Vol_EffectColor][0], volcache[Vol_EffectColor][1], volcache[Vol_EffectColor][2]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		VolTeamToString(volcache[Vol_TeamFilter], valuebuffer, sizeof(valuebuffer));
		Format(linebuffer, sizeof(linebuffer), "Team filter:		%s\n", valuebuffer);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		Format(linebuffer, sizeof(linebuffer), "Trigger delay:	  %.2f", volcache[Vol_TriggerDelay]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		// Print generic attributes.
		ReplyToCommand(client, buffer);
		
		// Clear buffer.
		buffer[0] = 0;
		
		// Get type spesific attributes.
		switch (volcache[Vol_Type])
		{
			case VolFeature_Anticamp:
			{
				VolAnticampDumpData(volcache[Vol_DataIndex], buffer, sizeof(buffer));
			}
			case VolFeature_ClassEdit:
			{
				VolClassEditDumpData(volcache[Vol_DataIndex], buffer, sizeof(buffer));
			}
		}
		
		// Print type spesific attributes if any.
		if (strlen(buffer) > 0)
		{
			ReplyToCommand(client, buffer);
		}
		
		return Plugin_Handled;
	}
}

public Action VolDumpStatesCommand(int client, int argc)
{
	char target[64];
	int targetclient;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Generic))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	if (argc < 1)
	{
		ReplyToCommand(client, "Dumps volume states for the specified player. Usage: zr_vol_dumpstates <index|targetname>");
		return Plugin_Handled;
	}
	
	// Get target.
	GetCmdArg(1, target, sizeof(target));
	targetclient = FindTarget(client, target);
	
	// Validate target.
	if (targetclient <= 0)
	{
		// Note: FindTarget automatically print error messages.
		return Plugin_Handled;
	}
	
	// Print header.
	ReplyToCommand(client, "Volume ID:  Player in volume:\n----------------------------------------");
	
	// Get player states.
	bool statebuffer[ZR_VOLUMES_MAX];
	VolGetPlayerStates(targetclient, statebuffer, sizeof(statebuffer));
	
	// Set language.
	SetGlobalTransTarget(client);
	
	// Loop through each volume.
	for (int volumeindex = 0; volumeindex < ZR_VOLUMES_MAX; volumeindex++)
	{
		// Check if volume is in use.
		if (VolInUse(volumeindex))
		{
			// Dump state.
			ReplyToCommand(client, "%-11d %t", volumeindex, statebuffer[volumeindex] ? "Yes" : "No");
		}
	}
	
	return Plugin_Handled;
}

/**
 * Creates a new volume with minimum parameters.
 *
 * Note: Extra volume attributes must be set using VolSetAttributes.
 *
 * @param index		 Optional. Add volume at the specified index.
 * @param locMin		Minimum x, y and z values.
 * @param locMax		Maximum x, y and z values.
 * @param volumeType	Specifies the volumetric feature type.
 * @param dataIndex	 Data index in remote array for feature data.
 *
 * @return			  The new volume index, or -1 if failed.
 */
int VolAdd(int volumeIndex = -1, float locMin[3], float locMax[3], VolumeFeatureTypes volumeType, int dataIndex)
{
	if (volumeIndex < 0)
	{
		// Get a free volume index.
		volumeIndex = VolGetFreeVolume();
	}
	
	// Validate index.
	if (VolIsValidIndex(volumeIndex))
	{
		// Mark volume as enabled and in use.
		Volumes[volumeIndex][Vol_Enabled] = true;
		Volumes[volumeIndex][Vol_InUse] = true;
		
		// Set location data.
		Volumes[volumeIndex][Vol_xMin] = locMin[0];
		Volumes[volumeIndex][Vol_yMin] = locMin[1];
		Volumes[volumeIndex][Vol_zMin] = locMin[2];
		
		Volumes[volumeIndex][Vol_xMax] = locMax[0];
		Volumes[volumeIndex][Vol_yMax] = locMax[1];
		Volumes[volumeIndex][Vol_zMax] = locMax[2];
		
		// Set type.
		Volumes[volumeIndex][Vol_Type] = volumeType;
		Volumes[volumeIndex][Vol_DataIndex] = dataIndex;
		
		// Update number of volumes.
		VolumeCount++;
		
		// Return the new index.
		return volumeIndex;
	}
	else
	{
		// No free volumes or invalid index.
		return -1;
	}
}

/**
 * Removes the specified volume.
 *
 * @param volumeIndex   The volume index.
 * @return			  True if successful, false otherwise.
 */
bool VolRemove(int volumeIndex)
{
	// Validate index.
	if (VolIsValidIndex(volumeIndex))
	{
		// Trigger event to clean up data and stop timers.
		VolOnDisabled(volumeIndex);
		
		// Clear feature data.
		switch (Volumes[volumeIndex][Vol_Type])
		{
			case VolFeature_Anticamp:
			{
				VolAnticampReset(Volumes[volumeIndex][Vol_DataIndex]);
			}
		}
		
		// Clear volume data.
		VolClear(volumeIndex);
		
		return true;
	}
	else
	{
		// Invalid index.
		return false;
	}
}

/**
 * Clears volume data at the specified index.
 *
 * @param volumeIndex   The volume index.
 */
void VolClear(int volumeIndex)
{
	Volumes[volumeIndex][Vol_Enabled] = false;
	Volumes[volumeIndex][Vol_InUse] = false;
	
	Volumes[volumeIndex][Vol_xMin] = 0.0;
	Volumes[volumeIndex][Vol_yMin] = 0.0;
	Volumes[volumeIndex][Vol_zMin] = 0.0;
	
	Volumes[volumeIndex][Vol_xMax] = 0.0;
	Volumes[volumeIndex][Vol_yMax] = 0.0;
	Volumes[volumeIndex][Vol_zMax] = 0.0;
	
	Volumes[volumeIndex][Vol_Effect] = VolEffect_None;
	Volumes[volumeIndex][Vol_EffectColor][0] = 0;
	Volumes[volumeIndex][Vol_EffectColor][1] = 0;
	Volumes[volumeIndex][Vol_EffectColor][2] = 0;
	
	int dataindex = Volumes[volumeIndex][Vol_DataIndex];
	if (dataindex >= 0)
	{
		switch (Volumes[volumeIndex][Vol_Type])
		{
			case VolFeature_Anticamp:
			{
				VolAnticampReset(dataindex);
			}
			case VolFeature_ClassEdit:
			{
				VolClassEditReset(dataindex);
			}
		}
	}
	
	Volumes[volumeIndex][Vol_Type] = VolFeature_Invalid;
	Volumes[volumeIndex][Vol_DataIndex] = -1;
	
	Volumes[volumeIndex][Vol_TeamFilter] = VolTeam_All;
	Volumes[volumeIndex][Vol_TriggerDelay] = 0.0;
}

/**
 * Clears all volumes.
 */
void VolClearAll()
{
	for (int volindex = 0; volindex < ZR_VOLUMES_MAX; volindex++)
	{
		VolClear(volindex);
	}
}

/**
 * Sets extra attributes on a volume.
 *
 * @param volumeIndex   The volume index.
 * @param attributes	A string with one or more attributes in key=value
 *					  format.
 * @return			  Number of successful attributes set, -1 on error.
 */
int VolSetAttributes(int volumeIndex, const char[] attributes)
{
	int attribCount;
	int successfulCount;
	VolumeFeatureTypes voltype;
	int dataindex;
	char attribName[64];
	char attribValue[256];
	
	// Validate volume index.
	if (!VolIsValidIndex(volumeIndex))
	{
		return -1;
	}
	
	// Count attributes.
	attribCount = GetParameterCount(attributes);
	
	// Check if empty.
	if (!attribCount)
	{
		return -1;
	}
	
	// Get volumetric feature type.
	voltype = Volumes[volumeIndex][Vol_Type];
	
	// Get feature data index.
	dataindex = Volumes[volumeIndex][Vol_DataIndex];
	
	// Loop through all attributes.
	for (int attrib = 0; attrib < attribCount; attrib++)
	{
		// Get attribute name.
		GetParameterName(attribName, sizeof(attribName), attributes, attrib);
		
		// Get attribute value.
		GetParameterValue(attribValue, sizeof(attribValue), attributes, attribName);
		
		LogEvent(_, LogType_Normal, LOG_DEBUG, LogModule_Volfeatures, "Set attribute", "Got parameter: \"%s\" = \"%s\"", attribName, attribValue);
		
		// Check generic attributes.
		if (StrEqual(attribName, "teamfilter", false))
		{
			// Parse team string value.
			if (VolSetTeamString(volumeIndex, attribValue))
			{
				successfulCount++;
			}
		}
		else if (StrEqual(attribName, "delay", false))
		{
			// Parse delay string value.
			if (VolSetDelayString(volumeIndex, attribValue))
			{
				successfulCount++;
			}
		}
		else if (StrEqual(attribName, "effect", false))
		{
			// Parse effect string value.
			if (VolSetEffectString(volumeIndex, attribValue))
			{
				successfulCount++;
			}
		}
		else if (StrEqual(attribName, "effect_color", false))
		{
			// Parse effect color string value.
			if (VolSetEffectColorString(volumeIndex, attribValue))
			{
				successfulCount++;
			}
		}
		else if (StrEqual(attribName, "enabled", false))
		{
			// Parse enabled string value.
			if (VolSetEnabledString(volumeIndex, attribValue))
			{
				successfulCount++;
			}
		}
		
		// Pass attribute onto the volumetric feature attribute handler.
		else
		{
			switch (voltype)
			{
				case VolFeature_Anticamp:
				{
					if (VolAnticampSetAttribute(dataindex, attribName, attribValue))
					{
						successfulCount++;
					}
				}
				case VolFeature_ClassEdit:
				{
					if (VolClassEditSetAttribute(dataindex, attribName, attribValue))
					{
						successfulCount++;
					}
				}
			}
		}
	}
	
	// Return number of successfully attributes set.
	return successfulCount;
}
