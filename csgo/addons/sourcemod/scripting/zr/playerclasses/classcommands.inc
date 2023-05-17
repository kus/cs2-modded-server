/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		classcommands.inc
 *  Type:		Core 
 *  Description: Console commands for working with classes.
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

void ClassOnCommandsCreate()
{
	// Register ZClass command.
	RegConsoleCmd(SAYHOOKS_KEYWORD_ZCLASS, ZClassCommand, "Opens class selection menu.");
	
	// Create base class commands.
	RegConsoleCmd("zr_class_dump", ClassDumpCommand, "Dumps class data at a specified index in the specified cache. Usage: zr_class_dump <cachetype> <index|targetname>");
	RegConsoleCmd("zr_class_dump_multipliers", ClassDumpMultipliersCommand, "Dumps class attribute multipliers for the specified team. Usage: zr_class_dump_multipliers <\"zombies\"|\"humans\">");
	RegConsoleCmd("zr_class_modify", ClassModifyCommand, "Modify class data on one or more classes. Usage: zr_class_modify <classname|\"zombies\"|\"humans\"|\"admins\"> <attribute> <value> [is_multiplier]");
	RegConsoleCmd("zr_class_set_multiplier", ClassSetMultiplierCommand, "Sets the multiplier on a class attribute. Usage: zr_class_set_multiplier <\"zombies\"|\"humans\"> <attribute> <value>");
	RegConsoleCmd("zr_class_reload", ClassReloadCommand, "Refreshes the player cache and reloads class attributes on one or more players. Usage: zr_class_reload <target>");
}

/**
 * Hook commands related to classes here.
 */
void ClassOnCommandsHook()
{
	// Forward event to sub-modules.
	ClassOverlayOnCommandsHook();
}

/**
 * Command callback (zclass)
 * Opens class selection menu.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZClassCommand(int client, int argc)
{
	// If client is console, then stop and tell them this feature is for players only.
	if (ZRIsConsole(client))
	{
		TranslationPrintToChat(client, "Must be player");
		return Plugin_Handled;
	}
	
	// Send class menu.
	ClassMenuMain(client);
	
	// This stops the "Unknown command" message in client's console.
	return Plugin_Handled;
}

/**
 * Command callback. (zr_class_dump)
 * Dumps class data at a specified index in the specified cache.
 *   
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ClassDumpCommand(int client, int argc)
{
	char syntax[320];
	syntax[0] = 0;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Generic))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	if (argc < 2)
	{
		// Write syntax info.
		StrCat(syntax, sizeof(syntax), "Dumps class data at a specified index in the specified cache. Usage: zr_class_dump <cachetype> <index|targetname>\n\n");
		StrCat(syntax, sizeof(syntax), "Cache types:\n");
		StrCat(syntax, sizeof(syntax), "original - Unmodified class data\n");
		StrCat(syntax, sizeof(syntax), "modified - Newest class data\n");
		StrCat(syntax, sizeof(syntax), "player   - Players class data\n");
		ReplyToCommand(client, syntax);
		
		return Plugin_Handled;
	}
	
	int cachetype = -1;
	int index = -1;
	
	char type[64];
	char target[64];
	char buffer[2048];
	
	// Quick initialize buffer.
	buffer[0] = 0;
	
	// Get cache type.
	GetCmdArg(1, type, sizeof(type));
	
	// Set cache type depending on parameter setting.
	if (StrEqual(type, "original", false))
	{
		cachetype = ZR_CLASS_CACHE_ORIGINAL;
	}
	else if (StrEqual(type, "modified", false))
	{
		cachetype = ZR_CLASS_CACHE_MODIFIED;
	}
	else if (StrEqual(type, "player", false))
	{
		cachetype = ZR_CLASS_CACHE_PLAYER;
		
		// Get client index.
		GetCmdArg(2, target, sizeof(target));
		index = FindTarget(client, target, _, false);
		
		// Check if failed.
		if (index < 0)
		{
			// Note: FindTarget automatically write error messages.
			return Plugin_Handled;
		}
	}
	
	// Check if cachetype is valid.
	if (cachetype < 0)
	{
		ReplyToCommand(client, "Invalid cache type.");
		return Plugin_Handled;
	}
	
	// Validate class index.
	if (cachetype != ZR_CLASS_CACHE_PLAYER)
	{
		// Get class index.
		GetCmdArg(2, target, sizeof(target));
		index = StringToInt(target);
		
		if (!ClassValidateIndex(index))
		{
			ReplyToCommand(client, "Invalid class index.");
			return Plugin_Handled;
		}
	}
	
	// Dump the specified cache.
	ReplyToCommand(client, "DUMPING CACHE: \"%s\" (%d classes total)\n========================================\n", type, ClassCount);
	ClassDumpData(index, cachetype, buffer, sizeof(buffer));
	
	// Print all data to client.
	char partbuffer[1024];
	int pos;
	int cellswritten = 1;   // Initialize for the loop.

	while (cellswritten)
	{
		cellswritten = strcopy(partbuffer, sizeof(partbuffer), buffer[pos]);
		ReplyToCommand(client, partbuffer);
		pos += cellswritten;
	}
	
	return Plugin_Handled;
}

/**
 * Command callback. (zr_class_dump_multipliers)
 * Dumps class attribute multipliers for the specified team.
 *   
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ClassDumpMultipliersCommand(int client, int argc)
{
	char buffer[512];
	char linebuffer[128];
	char arg[16];
	buffer[0] = 0;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Generic))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	if (argc < 1)
	{
		// Write syntax info.
		ReplyToCommand(client, "Dumps class attribute multipliers for the specified team. Usage: zr_class_dump_multipliers <\"zombies\"|\"humans\">");
		return Plugin_Handled;
	}
	
	int teamid = -1;
	
	// Get team id.
	GetCmdArg(1, arg, sizeof(arg));
	if (StrEqual(arg, "zombies", false))
	{
		teamid = ZR_CLASS_TEAM_ZOMBIES;
	}
	else if (StrEqual(arg, "humans", false))
	{
		teamid = ZR_CLASS_TEAM_HUMANS;
	}
	
	if (teamid >= 0)
	{
		Format(linebuffer, sizeof(linebuffer), "Dumping multipliers for team: %s\n----------------------------------------\n", arg);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		Format(linebuffer, sizeof(linebuffer), "Napalm time:		   %f\n", ClassMultiplierCache[teamid][ClassM_NapalmTime]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Health:				%f\n", ClassMultiplierCache[teamid][ClassM_Health]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Health regen interval: %f\n", ClassMultiplierCache[teamid][ClassM_HealthRegenInterval]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Health regen amount:   %f\n", ClassMultiplierCache[teamid][ClassM_HealthRegenAmount]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Health infect gain:	%f\n", ClassMultiplierCache[teamid][ClassM_HealthInfectGain]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Speed:				 %f\n", ClassMultiplierCache[teamid][ClassM_Speed]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Knock back:			%f\n", ClassMultiplierCache[teamid][ClassM_Knockback]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Jump height:		   %f\n", ClassMultiplierCache[teamid][ClassM_JumpHeight]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		Format(linebuffer, sizeof(linebuffer), "Jump distance:		 %f", ClassMultiplierCache[teamid][ClassM_JumpDistance]);
		StrCat(buffer, sizeof(buffer), linebuffer);
		
		ReplyToCommand(client, buffer);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "Invalid team name specified.");
		return Plugin_Handled;
	}
}

/**
 * Modifies class data on one or more classes.
 *
 * Syntax: zr_class_modify <class> <attribute> <value> [is_multiplier]
 *
 * class:		   The class to modify. Can be any class name, or one of the
 *				  following team names; "all", "humans", "zombies" or
 *				  "admins".
 * attribute:	   The name of the class attribute.
 * value:		   Value to set. Use quotes if value is a string.
 * is_multiplier:   Optional. specifies wether the original value should be
 *				  multiplied by the specified value. Defaults to false.
 *
 * Note: Original values are retrieved from the original class cache, not the
 *	   modified class cache.
 */
public Action ClassModifyCommand(int client, int argc)
{
	char syntax[1024];
	syntax[0] = 0;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	if (argc < 3)
	{
		// Write syntax info.
		StrCat(syntax, sizeof(syntax), "Modifies class data on one or more classes. Usage: zr_class_modify <class> <attribute> <value> [is_multiplier]\n\n");
		StrCat(syntax, sizeof(syntax), "class:		   The class to modify. Can be any class name, or one of the following team names; all, humans, zombies or admins.\n");
		StrCat(syntax, sizeof(syntax), "attribute:	   The name of the class attribute.\n");
		StrCat(syntax, sizeof(syntax), "value:		   Value to set. Use quotes if value is a string.\n");
		StrCat(syntax, sizeof(syntax), "is_multiplier:   Optional. specifies wether the original value should be multiplied by the specified value. Not all attributes support multipliers. Defaults to false.\n\n");
		StrCat(syntax, sizeof(syntax), "Note: Original values are retrieved from the original class cache, not the modified class cache.");
		ReplyToCommand(client, syntax);
		
		return Plugin_Handled;
	}
	
	char classname[64];
	char attributename[128];
	char value[256];
	char ismultiplier[4];
	
	int attributeflag;
	ClassDataTypes attributetype;
	bool isgroup;
	bool hasmultiplier;
	Handle classlist;
	
	int classindex;
	bool listresult;
	classlist = CreateArray();
	
	// Get command arguments.
	GetCmdArg(1, classname, sizeof(classname));
	GetCmdArg(2, attributename, sizeof(attributename));
	GetCmdArg(3, value, sizeof(value));
	
	// Get last command argument if specified.
	if (argc == 4)
	{
		GetCmdArg(4, ismultiplier, sizeof(ismultiplier));
		if (StringToInt(ismultiplier))
		{
			hasmultiplier = true;
		}
	}
	
	// Get attribute flag.
	attributeflag = ClassAttributeNameToFlag(attributename);
	
	// Validate attribute flag.
	if (attributeflag < 0)
	{
		ReplyToCommand(client, "Invalid class attribute specified.");
		return Plugin_Handled;
	}
	
	// Get attribute data type.
	attributetype = ClassGetAttributeType(attributeflag);
	
	// Check if classname is a group. Add classes to the class list
	// and use the specified team filter.
	if (StrEqual(classname, "all", false))
	{
		listresult = ClassAddToArray(classlist);
		isgroup = true;
	}
	else if (StrEqual(classname, "humans", false))
	{
		listresult = ClassAddToArray(classlist, ZR_CLASS_TEAM_HUMANS);
		isgroup = true;
	}
	else if (StrEqual(classname, "zombies", false))
	{
		listresult = ClassAddToArray(classlist, ZR_CLASS_TEAM_ZOMBIES);
		isgroup = true;
	}
	else if (StrEqual(classname, "admins", false))
	{
		listresult = ClassAddToArray(classlist, ZR_CLASS_TEAM_ADMINS);
		isgroup = true;
	}
	
	// Check if classname is a group.
	if (isgroup)
	{
		// Check if the list is valid.
		if (!listresult)
		{
			ReplyToCommand(client, "Failed to get classes in the specified team: \"%s\".", classname);
			return Plugin_Handled;
		}
		
		// Loop through all classes in the list.
		int listsize = GetArraySize(classlist);
		
		for (int i = 0; i < listsize; i++)
		{
			classindex = GetArrayCell(classlist, i);
			
			switch (attributetype)
			{
				case ClassDataType_Boolean:
				{
					if (!ClassModifyBoolean(classindex, attributeflag, view_as<bool>(StringToInt(value))))
					{
						ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
					}
				}
				case ClassDataType_Integer:
				{
					if (hasmultiplier)
					{
						if (!ClassModifyInteger(classindex, attributeflag, StringToInt(value), StringToFloat(value)))
						{
							ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
						}
					}
					else
					{
						if (!ClassModifyInteger(classindex, attributeflag, StringToInt(value)))
						{
							ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
						}
					}
				}
				case ClassDataType_Float:
				{
					if (!ClassModifyFloat(classindex, attributeflag, StringToFloat(value), hasmultiplier))
					{
						ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
					}
				}
				case ClassDataType_String:
				{
					if (!ClassModifyString(classindex, attributeflag, value))
					{
						ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
					}
				}
			}
		}
	}
	else
	{
		// It's a single class.
		classindex = ClassGetIndex(classname);
		
		// Validate classindex.
		if (!ClassValidateIndex(classindex))
		{
			ReplyToCommand(client, "Invalid class name specified.");
			return Plugin_Handled;
		}
		
		switch (attributetype)
		{
			case ClassDataType_Boolean:
			{
				if (!ClassModifyBoolean(classindex, attributeflag, view_as<bool>(StringToInt(value))))
				{
					ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
				}
			}
			case ClassDataType_Integer:
			{
				if (hasmultiplier)
				{
					if (!ClassModifyInteger(classindex, attributeflag, StringToInt(value), StringToFloat(value)))
					{
						ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
					}
				}
				else
				{
					if (!ClassModifyInteger(classindex, attributeflag, StringToInt(value)))
					{
						ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
					}
				}
			}
			case ClassDataType_Float:
			{
				if (!ClassModifyFloat(classindex, attributeflag, StringToFloat(value)), hasmultiplier)
				{
					ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
				}
			}
			case ClassDataType_String:
			{
				if (!ClassModifyString(classindex, attributeflag, value))
				{
					ReplyToCommand(client, "Failed to set \"%s\" to \"%s\" in class \"%d\".", attributename, value, classindex);
				}
			}
		}
	}
	
	return Plugin_Handled;
}

/**
 * Sets the multiplier on a class attribute.
 *
 * Syntax: zr_class_modify <class> <attribute> <value> [is_multiplier]
 *
 * class:		   The class to modify. Can be any class name, or one of the
 *				  following team names; "all", "humans", "zombies" or
 *				  "admins".
 * attribute:	   The name of the class attribute.
 * value:		   Value to set. Use quotes if value is a string.
 * is_multiplier:   Optional. specifies wether the original value should be
 *				  multiplied by the specified value. Defaults to false.
 *
 * Note: Original values are retrieved from the original class cache, not the
 *	   modified class cache.
 */
public Action ClassSetMultiplierCommand(int client, int argc)
{
	char syntax[320];
	syntax[0] = 0;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	if (argc < 3)
	{
		// Write syntax info.
		StrCat(syntax, sizeof(syntax), "Sets the multiplier on a class attribute. Usage: zr_class_set_multiplier <\"zombies\"|\"humans\"> <attribute> <value>\n\n");
		StrCat(syntax, sizeof(syntax), "Valid attributes:\n----------------------------------------\n");
		StrCat(syntax, sizeof(syntax), "napalm_time\nhealth\nhealth_regen_interval\nhealth_regen_amount\nhealth_infect_gain\nspeed\nknockback\njump_height\njump_distance");
		ReplyToCommand(client, syntax);
		return Plugin_Handled;
	}
	
	char teamname[16];
	char attributename[32];
	char multiplier[32];
	
	int teamid = -1;
	ClassMultipliers attribute;
	float value;
	
	// Get arguments.
	GetCmdArg(1, teamname, sizeof(teamname));
	GetCmdArg(2, attributename, sizeof(attributename));
	GetCmdArg(3, multiplier, sizeof(multiplier));
	
	// Get team id.
	if (StrEqual(teamname, "zombies", false))
	{
		teamid = ZR_CLASS_TEAM_ZOMBIES;
	}
	else if (StrEqual(teamname, "humans", false))
	{
		teamid = ZR_CLASS_TEAM_HUMANS;
	}
	
	// Validate team id.
	if (teamid < 0)
	{
		ReplyToCommand(client, "Invalid team name: %s", teamname);
		return Plugin_Handled;
	}
	
	// Get attribute type.
	attribute = ClassAttributeNameToMultiplier(attributename);
	
	// Validate type.
	if (attribute == ClassM_Invalid)
	{
		ReplyToCommand(client, "Attribute is invalid or not a multiplier: %s", attributename);
		return Plugin_Handled;
	}
	
	// Get value.
	value = StringToFloat(multiplier);
	
	// Set multiplier.
	ClassMultiplierCache[teamid][attribute] = value;
	
	return Plugin_Handled;
}

/**
 * Command callback. (zr_class_reload)
 * Dumps class data at a specified index in the specified cache.
 *   
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ClassReloadCommand(int client, int argc)
{
	char arg[MAX_TARGET_LENGTH];
	char targetname[MAX_TARGET_LENGTH];
	int targetlist[MAXPLAYERS + 1];
	int targetcount;
	bool tn_is_ml;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Generic))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	if (argc < 1)
	{
		// Write syntax info.
		ReplyToCommand(client, "Refreshes the player cache and reloads class attributes on one or more players. Usage: zr_class_reload <target>");
		
		return Plugin_Handled;
	}
	
	// Get the target string.
	GetCmdArg(1, arg, sizeof(arg));
	
	// Get target clients.
	if ((targetcount = ProcessTargetString(arg, client, targetlist, sizeof(targetlist), 0, targetname, sizeof(targetname), tn_is_ml)) <= 0)
	{
		// Failed to get targets.
		ReplyToTargetError(client, targetcount);
		return Plugin_Handled;
	}
	
	// Loop through each target.
	for (int target = 0; target < targetcount; target++)
	{
		ClassReloadPlayer(targetlist[target]);
	}
	
	// Check phrase format.
	if (tn_is_ml)
	{
		ReplyToCommand(client, "Refreshed cache to %t.", targetname);
	}
	else
	{
		ReplyToCommand(client, "Refreshed cache to %s.", targetname);
	}
	
	return Plugin_Handled;
}

/**
 * Modify class boolean attribute on a class.
 *
 * @param classindex		The class index.
 * @param attributeflag	 Attribute to modify (a single attribute flag).
 * @param value			 New value to set.
 * @return				  True on success, false otherwise.
 */
stock bool ClassModifyBoolean(int classindex, int attributeflag, bool value)
{
	// Validate class index.
	if (!ClassValidateIndex(classindex))
	{
		return false;
	}
	
	switch (attributeflag)
	{
		case ZR_CLASS_ENABLED:
		{
			ClassDataCache[classindex][Class_Enabled] = view_as<bool>(value);
			return true;
		}
		case ZR_CLASS_NVGS:
		{
			ClassDataCache[classindex][Class_Nvgs] = view_as<bool>(value);
			return true;
		}
		case ZR_CLASS_NO_FALL_DAMAGE:
		{
			ClassDataCache[classindex][Class_NoFallDamage] = view_as<bool>(value);
			return true;
		}
		case ZR_CLASS_HAS_NAPALM:
		{
			ClassDataCache[classindex][Class_HasNapalm] = view_as<bool>(value);
			return true;
		}
	}
	
	// Invalid flag or multiple flags combined.
	return false;
}

/**
 * Modify class integer attribute on a class.
 *
 * @param classindex		The class index.
 * @param attributeflag	 Attribute to modify (a single attribute flag).
 * @param value			 New value to set, or multiply with.
 * @param multiplier		Optional. Use a multiplier instead of the value,
 *						  that multiplies with the original class value.
 *						  Not all attributes support multipliers. 0.0 to
 *						  disable. Value is ignored if this is non-zero.
 * @return				  True on success, false otherwise.
 */
stock int ClassModifyInteger(int classindex, int attributeflag, int value, float multiplier = 0.0)
{
	// Validate class index.
	if (!ClassValidateIndex(classindex))
	{
		return false;
	}
	
	// Check if multiplier is specified.
	bool ismultiplier = (multiplier != 0.0) ? true : false;
	
	switch (attributeflag)
	{
		case ZR_CLASS_FLAGS:
		{
			ClassDataCache[classindex][Class_Flags] = value;
			return true;
		}
		case ZR_CLASS_MODEL_SKIN_INDEX:
		{
			ClassDataCache[classindex][Class_ModelSkinIndex] = value;
			return true;
		}
		case ZR_CLASS_ALPHA_INITIAL:
		{
			if (ismultiplier)
			{
				value = RoundToNearest(float(ClassData[classindex][Class_AlphaInitial]) * multiplier);
			}
			ClassDataCache[classindex][Class_AlphaInitial] = value;
			return true;
		}
		case ZR_CLASS_ALPHA_DAMAGED:
		{
			if (ismultiplier)
			{
				value = RoundToNearest(float(ClassData[classindex][Class_AlphaDamaged]) * multiplier);
			}
			ClassDataCache[classindex][Class_AlphaDamaged] = value;
			return true;
		}
		case ZR_CLASS_ALPHA_DAMAGE:
		{
			if (ismultiplier)
			{
				value = RoundToNearest(float(ClassData[classindex][Class_AlphaDamage]) * multiplier);
			}
			ClassDataCache[classindex][Class_AlphaDamage] = value;
			return true;
		}
		case ZR_CLASS_FOV:
		{
			ClassDataCache[classindex][Class_Fov] = value;
			return true;
		}
		case ZR_CLASS_IMMUNITY_AMOUNT:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_ImmunityAmount] * value;
			}
			ClassDataCache[classindex][Class_ImmunityAmount] = value;
			return true;
		}
		case ZR_CLASS_IMMUNITY_COOLDOWN:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_ImmunityCooldown] * value;
			}
			ClassDataCache[classindex][Class_ImmunityCooldown] = value;
			return true;
		}
		case ZR_CLASS_HEALTH:
		{
			if (ismultiplier)
			{
				value = RoundToNearest(float(ClassData[classindex][Class_Health]) * multiplier);
			}
			ClassDataCache[classindex][Class_Health] = value;
			return true;
		}
		case ZR_CLASS_HEALTH_REGEN_AMOUNT:
		{
			if (ismultiplier)
			{
				value = RoundToNearest(float(ClassData[classindex][Class_HealthRegenAmount]) * multiplier);
			}
			ClassDataCache[classindex][Class_HealthRegenAmount] = value;
			return true;
		}
		case ZR_CLASS_HEALTH_INFECT_GAIN:
		{
			if (ismultiplier)
			{
				value = RoundToNearest(float(ClassData[classindex][Class_HealthInfectGain]) * multiplier);
			}
			ClassDataCache[classindex][Class_HealthInfectGain] = value;
			return true;
		}
		case ZR_CLASS_KILL_BONUS:
		{
			if (ismultiplier)
			{
				value = RoundToNearest(float(ClassData[classindex][Class_KillBonus]) * multiplier);
			}
			ClassDataCache[classindex][Class_KillBonus] = value;
			return true;
		}
	}
	
	// Invalid flag or multiple flags combined.
	return false;
}

/**
 * Modify class float attribute on a class.
 *
 * @param classindex		The class index.
 * @param attributeflag	 Attribute to modify (a single attribute flag).
 * @param value			 New value to set, or multiply with.
 * @param ismultiplier	  Optional. Specifies wether to use value as a
 *						  multiplier that is multiplied with the original
 *						  class value. Unsupported attributes are ignored.
 * @return				  True on success, false otherwise.
 */
stock int ClassModifyFloat(int classindex, int attributeflag, float value, bool ismultiplier = false)
{
	// Validate class index.
	if (!ClassValidateIndex(classindex))
	{
		return false;
	}
	
	switch (attributeflag)
	{
		case ZR_CLASS_NAPALM_TIME:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_NapalmTime] * value;
			}
			ClassDataCache[classindex][Class_NapalmTime] = value;
			return true;
		}
		case ZR_CLASS_HEALTH_REGEN_INTERVAL:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_HealthRegenInterval] * value;
			}
			ClassDataCache[classindex][Class_HealthRegenInterval] = value;
			return true;
		}
		case ZR_CLASS_SPEED:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_Speed] * value;
			}
			ClassDataCache[classindex][Class_Speed] = value;
			return true;
		}
		case ZR_CLASS_KNOCKBACK:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_KnockBack] * value;
			}
			ClassDataCache[classindex][Class_KnockBack] = value;
			return true;
		}
		case ZR_CLASS_JUMP_HEIGHT:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_JumpHeight] * value;
			}
			ClassDataCache[classindex][Class_JumpHeight] = value;
			return true;
		}
		case ZR_CLASS_JUMP_DISTANCE:
		{
			if (ismultiplier)
			{
				value = ClassData[classindex][Class_JumpDistance] * value;
			}
			ClassDataCache[classindex][Class_JumpDistance] = value;
			return true;
		}
	}
	
	// Invalid flag or multiple flags combined.
	return false;
}

/**
 * Modify class string attribute on a class.
 *
 * @param classindex		The class index.
 * @param attributeflag	 Attribute to modify (a single attribute flag).
 * @param value			 New value to set.
 * @return				  True on success, false otherwise.
 */
stock int ClassModifyString(int classindex, int attributeflag, const char[] value)
{
	// Validate class index.
	if (!ClassValidateIndex(classindex))
	{
		return false;
	}
	
	switch (attributeflag)
	{
		case ZR_CLASS_GROUP:
		{
			strcopy(ClassDataCache[classindex][Class_Group], 64, value);
			return true;
		}
		case ZR_CLASS_SM_FLAGS:
		{
			strcopy(ClassDataCache[classindex][Class_SM_Flags], 64, value);
			return true;
		}
		case ZR_CLASS_NAME:
		{
			strcopy(ClassDataCache[classindex][Class_Name], 64, value);
			return true;
		}
		case ZR_CLASS_DESCRIPTION:
		{
			strcopy(ClassDataCache[classindex][Class_Description], 256, value);
			return true;
		}
		case ZR_CLASS_MODEL_PATH:
		{
			strcopy(ClassDataCache[classindex][Class_ModelPath], PLATFORM_MAX_PATH, value);
			return true;
		}
		case ZR_CLASS_OVERLAY_PATH:
		{
			strcopy(ClassDataCache[classindex][Class_OverlayPath], PLATFORM_MAX_PATH, value);
			return true;
		}
		case ZR_CLASS_IMMUNITY_MODE:
		{
			// Convert to mode.
			ImmunityMode mode = ImmunityStringToMode(value);
			
			// Validate.
			if (mode != Immunity_Invalid)
			{
				ClassDataCache[classindex][Class_ImmunityMode] = mode;
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	
	// Invalid flag or multiple flags combined.
	return false;
}
