/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  filtertools.inc
 *  Type:		  Core 
 *  Description:   Class system tools; validating, getting indexes or lists
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
 * Validates the team requirements in a class cache and check that theres at
 * least one class for each team. Minium team requirements are zombies and
 * humans. The admin team is optinal and not validated.
 *
 * @param cachetype Optional. Specifies what class cache to validate. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL (default, unchanged class data),
 *				  ZR_CLASS_CACHE_MODIFIED (modified class data).
 * @return		  True if validation was successful, false otherwise.
 */
stock bool ClassValidateTeamRequirements(int cachetype = ZR_CLASS_CACHE_ORIGINAL)
{
	int zombieindex;
	int humanindex;
	
	// Check if there are no classes.
	if (ClassCount == 0)
	{
		return false;
	}
	
	// Test if a zombie and human class was found.
	zombieindex = ClassGetFirstClass(ZR_CLASS_TEAM_ZOMBIES, _, cachetype);
	humanindex = ClassGetFirstClass(ZR_CLASS_TEAM_HUMANS, _, cachetype);
	
	// Validate indexes.
	if (ClassValidateIndex(zombieindex) && ClassValidateIndex(humanindex))
	{
		return true;
	}
	
	return false;
}

/**
 * Validates that there's a class marked as team default for each team.
 *
 * @param cachetype Optional. Specifies what class cache to validate. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL (default, unchanged class data),
 *				  ZR_CLASS_CACHE_MODIFIED (modified class data).
 * @return		  True if validation was successful, false otherwise.
 */
stock bool ClassValidateTeamDefaults(int cachetype = ZR_CLASS_CACHE_ORIGINAL)
{
	int zombieindex;
	int humanindex;
	
	// Check if there are no classes.
	if (ClassCount == 0)
	{
		return false;
	}
	
	// Test if a default zombie and human class was found.
	zombieindex = ClassGetDefaultClass(ZR_CLASS_TEAM_ZOMBIES, _, cachetype);
	humanindex = ClassGetDefaultClass(ZR_CLASS_TEAM_HUMANS, _, cachetype);
	
	// Validate indexes.
	if (ClassValidateIndex(zombieindex) && ClassValidateIndex(humanindex))
	{
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * Validates all the class attributes in the original class data array, to
 * check if they have invalid values. Boolean settings are not validated.
 *
 * @param classindex	The index of the class to validate.
 * @param logErrors	 Log invalid attributes.
 * @return			  A value with attribute error flags.
 */
stock int ClassValidateAttributes(int classindex, bool logErrors = false)
{
	int flags;
	
	// Team.
	int team = ClassData[classindex][Class_Team];
	if (team < ZR_CLASS_TEAM_MIN || team > ZR_CLASS_TEAM_MAX)
	{
		flags += ZR_CLASS_TEAM;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid team at index %d: %d", classindex, team);
		}
	}
	
	// Class flags.
	int class_flags = ClassData[classindex][Class_Flags];
	if (class_flags < ZR_CLASS_FLAGS_MIN || class_flags > ZR_CLASS_FLAGS_MAX)
	{
		flags += ZR_CLASS_FLAGS;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid flags at index %d: %d", classindex, class_flags);
		}
	}
	
	// Group.
	char group[64];
	group[0] = 0;
	if (strcopy(group, sizeof(group), ClassData[classindex][Class_Group]) > 0)
	{
		// Check if the group exist.
		if (FindAdmGroup(group) == INVALID_GROUP_ID)
		{
			flags += ZR_CLASS_GROUP;
			if (logErrors)
			{
				LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid group at index %d: \"%s\"", classindex, group);
			}
		}
	}
	
	// Name.
	char name[64];
	name[0] = 0;
	if (strcopy(name, sizeof(name), ClassData[classindex][Class_Name]) < ZR_CLASS_NAME_MIN)
	{
		flags += ZR_CLASS_NAME;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Missing name at index %d.", classindex);
		}
	}
	else
	{
		// Check for reserved name keyworks. These aren't allowed as names.
		if (StrEqual(name, "all", false) ||
			StrEqual(name, "humans", false) ||
			StrEqual(name, "zombies", false) ||
			StrEqual(name, "admins", false))
		{
			flags += ZR_CLASS_NAME;
			if (logErrors)
			{
				LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid name at index %d. Cannot be a team name: \"%s\"", classindex, name);
			}
		}
	}
	
	// Description.
	if (strlen(ClassData[classindex][Class_Description]) < ZR_CLASS_DESCRIPTION_MIN)
	{
		flags += ZR_CLASS_DESCRIPTION;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Missing description at index %d.", classindex);
		}
	}
	
	// Model path.
	char model_path[PLATFORM_MAX_PATH];
	if (strcopy(model_path, sizeof(model_path), ClassData[classindex][Class_ModelPath]) == 0)
	{
		flags += ZR_CLASS_MODEL_PATH;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Missing model_path at index %d.", classindex, model_path);
		}
	}
	else
	{
		// Validate only if not a pre-defined setting.
		if (!StrEqual(model_path, "random", false) &&
			!StrEqual(model_path, "random_public", false) &&
			!StrEqual(model_path, "random_hidden", false) &&
			!StrEqual(model_path, "random_admin", false) &&
			!StrEqual(model_path, "random_mother_zombie", false) &&
			!StrEqual(model_path, "default", false) &&
			!StrEqual(model_path, "no_change", false))
		{
			// Check if the file exists.
			if (!FileExists(model_path, true))
			{
				flags += ZR_CLASS_MODEL_PATH;
				if (logErrors)
				{
					LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid model_path at index %d. File not found: \"%s\"", classindex, model_path);
				}
			}
		}
	}
	
	// Model skin index.
	int model_skin_index = ClassData[classindex][Class_ModelSkinIndex];
	if (model_skin_index < ZR_CLASS_MODEL_SKIN_INDEX_MIN)
	{
		flags += ZR_CLASS_MODEL_SKIN_INDEX;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid model_skin_index at index %d: %d", classindex, model_skin_index);
		}
	}
	
	// Alpha, initial.
	int alpha_initial = ClassData[classindex][Class_AlphaInitial];
	if (!(alpha_initial >= ZR_CLASS_ALPHA_INITIAL_MIN && alpha_initial <= ZR_CLASS_ALPHA_INITIAL_MAX))
	{
		flags += ZR_CLASS_ALPHA_INITIAL;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid alpha_inital at index %d: %d", classindex, alpha_initial);
		}
	}
	
	// Alpha, damaged.
	int alpha_damaged = ClassData[classindex][Class_AlphaDamaged];
	if (!(alpha_damaged >= ZR_CLASS_ALPHA_DAMAGED_MIN && alpha_damaged <= ZR_CLASS_ALPHA_DAMAGED_MAX))
	{
		flags += ZR_CLASS_ALPHA_DAMAGED;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid alpha_damaged at index %d: %d", classindex, alpha_damaged);
		}
	}
	
	// Alpha, damage.
	int alpha_damage = ClassData[classindex][Class_AlphaDamage];
	if (!(alpha_damage >= ZR_CLASS_ALPHA_DAMAGE_MIN && alpha_damage <= ZR_CLASS_ALPHA_DAMAGE_MAX))
	{
		flags += ZR_CLASS_ALPHA_DAMAGE;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid alpha_damage at index %d: %d", classindex, alpha_damage);
		}
	}
	
	// Overlay path.
	char overlay_path[PLATFORM_MAX_PATH];
	char overlay[PLATFORM_MAX_PATH];
	if (strcopy(overlay_path, sizeof(overlay_path), ClassData[classindex][Class_OverlayPath]) > 0)
	{
		// Check if the file exists.
		Format(overlay, sizeof(overlay), "materials/%s.vmt", overlay_path);
		if (!FileExists(overlay, true))
		{
			flags += ZR_CLASS_OVERLAY_PATH;
			if (logErrors)
			{
				LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid overlay_path at index %d. File not found: \"%s\"", classindex, overlay_path);
			}
		}
	}
	
	// Field of view.
	int fov = ClassData[classindex][Class_Fov];
	if (!(fov >= ZR_CLASS_FOV_MIN && fov <= ZR_CLASS_FOV_MAX))
	{
		flags += ZR_CLASS_FOV;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid fov at index %d: %d", classindex, fov);
		}
	}
	
	// Napalm time.
	float napalm_time = ClassData[classindex][Class_NapalmTime];
	if (!(napalm_time >= ZR_CLASS_NAPALM_TIME_MIN && napalm_time <= ZR_CLASS_NAPALM_TIME_MAX))
	{
		flags += ZR_CLASS_NAPALM_TIME;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid napalm_time at index %d: %0.2f", classindex, napalm_time);
		}
	}
	
	// Immunity mode.
	ImmunityMode immunityMode = ClassData[classindex][Class_ImmunityMode];
	if (immunityMode == Immunity_Invalid)
	{
		flags += ZR_CLASS_IMMUNITY_MODE;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid immunity_mode at index %d.", classindex);
		}
	}
	
	// Immunity amount.
	int immunityAmount = ClassData[classindex][Class_ImmunityAmount];
	if (!ImmunityIsValidAmount(immunityMode, immunityAmount))
	{
		flags += ZR_CLASS_IMMUNITY_AMOUNT;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid immunity_amount at index %d.", classindex);
		}
	}
	
	// Immunity cooldown.
	int immunityCooldown = ClassData[classindex][Class_ImmunityCooldown];
	if (!ImmunityIsValidCooldown(immunityMode, immunityCooldown))
	{
		flags += ZR_CLASS_IMMUNITY_COOLDOWN;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid immunity_cooldown at index %d.", classindex);
		}
	}
	
	// Health.
	int health = ClassData[classindex][Class_Health];
	if (!(health >= ZR_CLASS_HEALTH_MIN && health <= ZR_CLASS_HEALTH_MAX))
	{
		flags += ZR_CLASS_HEALTH;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid health at index %d: %d", classindex, health);
		}
	}
	
	// Health regen interval.
	float regen_interval = ClassData[classindex][Class_HealthRegenInterval];
	if (!(regen_interval >= ZR_CLASS_REGEN_INTERVAL_MIN && regen_interval <= ZR_CLASS_REGEN_INTERVAL_MAX))
	{
		flags += ZR_CLASS_HEALTH_REGEN_INTERVAL;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid health_regen_interval at index %d: %0.2f", classindex, regen_interval);
		}
	}
	
	// Health regen amount.
	int regen_amount = ClassData[classindex][Class_HealthRegenAmount];
	if (!(regen_amount >= ZR_CLASS_REGEN_AMOUNT_MIN && regen_amount <= ZR_CLASS_REGEN_AMOUNT_MAX))
	{
		flags += ZR_CLASS_HEALTH_REGEN_AMOUNT;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid health_regen_amount at index %d: %d", classindex, regen_amount);
		}
	}
	
	// Health infect gain.
	int infect_gain = ClassData[classindex][Class_HealthInfectGain];
	if (!(infect_gain >= ZR_CLASS_HEALTH_INFECT_GAIN_MIN && infect_gain <= ZR_CLASS_HEALTH_INFECT_GAIN_MAX))
	{
		flags += ZR_CLASS_HEALTH_INFECT_GAIN;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid health_infect_gain at index %d: %d", classindex, infect_gain);
		}
	}
	
	// Kill bonus.
	int kill_bonus = ClassData[classindex][Class_KillBonus];
	if (!(kill_bonus >= ZR_CLASS_KILL_BONUS_MIN && kill_bonus <= ZR_CLASS_KILL_BONUS_MAX))
	{
		flags += ZR_CLASS_KILL_BONUS;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid kill_bonus at index %d: %d", classindex, kill_bonus);
		}
	}
	
	// Speed.
	float speed = ClassData[classindex][Class_Speed];
	float min;
	float max;
	switch (ClassSpeedMethod)
	{
		case ClassSpeed_LMV:
		{
			min = ZR_CLASS_SPEED_LMV_MIN;
			max = ZR_CLASS_SPEED_LMV_MAX;
		}
		case ClassSpeed_Prop:
		{
			min = ZR_CLASS_SPEED_PROP_MIN;
			max = ZR_CLASS_SPEED_PROP_MAX;
		}
	}
	if (!(speed >= min && speed <= max))
	{
		flags += ZR_CLASS_SPEED;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid speed at index %d: %0.2f", classindex, speed);
		}
	}
	
	// Knockback.
	float knockback = ClassData[classindex][Class_KnockBack];
	if (!(knockback >= ZR_CLASS_KNOCKBACK_MIN && knockback <= ZR_CLASS_KNOCKBACK_MAX))
	{
		flags += ZR_CLASS_KNOCKBACK;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid knockback at index %d: %0.2f", classindex, knockback);
		}
	}
	
	// Jump height.
	float jump_height = ClassData[classindex][Class_JumpHeight];
	if (!(jump_height >= ZR_CLASS_JUMP_HEIGHT_MIN && jump_height <= ZR_CLASS_JUMP_HEIGHT_MAX))
	{
		flags += ZR_CLASS_JUMP_HEIGHT;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid jump_height at index %d: %0.2f", classindex, jump_height);
		}
	}
	
	// Jump distance.
	float jump_distance = ClassData[classindex][Class_JumpDistance];
	if (!(jump_distance >= ZR_CLASS_JUMP_DISTANCE_MIN && jump_distance <= ZR_CLASS_JUMP_DISTANCE_MAX))
	{
		flags += ZR_CLASS_JUMP_DISTANCE;
		if (logErrors)
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid jump_distance at index %d: %0.2f", classindex, jump_distance);
		}
	}
	
	return flags;
}

/**
 * Validates a set of editable attributes.
 *
 * @param attributes	Attribute set to validate.
 * @return			  0 if successful, or a bit field (positivie number) of
 *					  failed attributes.
 */
stock int ClassValidateEditableAttributes(attributes[ClassEditableAttributes])
{
	int flags;
	
	// Model skin index.
	int model_skin_index = attributes[ClassEdit_ModelSkinIndex];
	if (model_skin_index < ZR_CLASS_MODEL_SKIN_INDEX_MIN)
	{
		flags += ZR_CLASS_MODEL_SKIN_INDEX;
	}
	
	// Alpha initial.
	int alphaInitial = attributes[ClassEdit_AlphaInitial];
	if (alphaInitial >= 0)
	{
		if (!(alphaInitial >= ZR_CLASS_ALPHA_INITIAL_MIN && alphaInitial <= ZR_CLASS_ALPHA_INITIAL_MAX))
		{
			flags += ZR_CLASS_ALPHA_INITIAL;
		}
	}
	
	// Alpha damaged.
	int alphaDamaged = attributes[ClassEdit_AlphaDamaged];
	if (alphaDamaged >= 0)
	{
		if (!(alphaDamaged >= ZR_CLASS_ALPHA_DAMAGED_MIN && alphaDamaged <= ZR_CLASS_ALPHA_DAMAGED_MAX))
		{
			flags += ZR_CLASS_ALPHA_DAMAGED;
		}
	}
	
	// Alpha damage.
	int alphaDamage = attributes[ClassEdit_AlphaDamage];
	if (alphaDamage >= 0)
	{
		if (!(alphaDamage >= ZR_CLASS_ALPHA_DAMAGE_MIN && alphaDamage <= ZR_CLASS_ALPHA_DAMAGE_MAX))
		{
			flags += ZR_CLASS_ALPHA_DAMAGE;
		}
	}
	
	// Overlay.
	if (!StrEqual(attributes[ClassEdit_OverlayPath], "nochange", false))
	{
		char overlay_path[PLATFORM_MAX_PATH];
		char overlay[PLATFORM_MAX_PATH];
		if (strcopy(overlay_path, sizeof(overlay_path), attributes[ClassEdit_OverlayPath]) > 0)
		{
			// Check if the file exists.
			Format(overlay, sizeof(overlay), "materials/%s.vmt", overlay_path);
			if (!FileExists(overlay, true))
			{
				flags += ZR_CLASS_OVERLAY_PATH;
			}
		}
	}
	
	// Fov.
	int fov = attributes[ClassEdit_Fov];
	if (fov >= 0)
	{
		if (!(fov >= ZR_CLASS_FOV_MIN && fov <= ZR_CLASS_FOV_MAX))
		{
			flags += ZR_CLASS_FOV;
		}
	}
	
	// Napalm time.
	float napalmTime = attributes[ClassEdit_NapalmTime];
	if (napalmTime >= 0.0)
	{
		if (!(napalmTime >= ZR_CLASS_NAPALM_TIME_MIN && napalmTime <= ZR_CLASS_NAPALM_TIME_MAX))
		{
			flags += ZR_CLASS_NAPALM_TIME;
		}
	}
	
	// Immunity mode.
	ImmunityMode immunityMode = attributes[ClassEdit_ImmunityMode];
	if (immunityMode == Immunity_Invalid)
	{
		flags += ZR_CLASS_IMMUNITY_MODE;
	}
	
	// Immunity amount.
	// TODO: Validate amount value. This depends on the immunity mode.
	
	// Health regen interval.
	float healthRegenInterval = attributes[ClassEdit_RegenInterval];
	if (healthRegenInterval >= 0.0)
	{
		if (!(healthRegenInterval >= ZR_CLASS_REGEN_INTERVAL_MIN && healthRegenInterval <= ZR_CLASS_REGEN_INTERVAL_MAX))
		{
			flags += ZR_CLASS_REGEN_INTERVAL;
		}
	}
	
	// Health regen amount.
	int healthRegenAmount = attributes[ClassEdit_RegenAmount];
	if (healthRegenAmount >= 0)
	{
		if (!(healthRegenAmount >= ZR_CLASS_REGEN_AMOUNT_MIN && healthRegenAmount <= ZR_CLASS_REGEN_AMOUNT_MAX))
		{
			flags += ZR_CLASS_REGEN_AMOUNT;
		}
	}
	
	// Infect gain.
	int infectGain = attributes[ClassEdit_InfectGain];
	if (infectGain >= 0)
	{
		if (!(infectGain >= ZR_CLASS_HEALTH_INFECT_GAIN_MIN && infectGain <= ZR_CLASS_HEALTH_INFECT_GAIN_MAX))
		{
			flags += ZR_CLASS_HEALTH_INFECT_GAIN;
		}
	}
	
	// Kill bonus.
	int killBonus = attributes[ClassEdit_KillBonus];
	if (killBonus >= 0)
	{
		if (!(killBonus >= ZR_CLASS_KILL_BONUS_MIN && killBonus <= ZR_CLASS_KILL_BONUS_MAX))
		{
			flags += ZR_CLASS_KILL_BONUS;
		}
	}
	
	// Speed.
	float speed = attributes[ClassEdit_Speed];
	if (speed >= 0)
	{
		float min;
		float max;
		switch (ClassSpeedMethod)
		{
			case ClassSpeed_LMV:
			{
				min = ZR_CLASS_SPEED_LMV_MIN;
				max = ZR_CLASS_SPEED_LMV_MAX;
			}
			case ClassSpeed_Prop:
			{
				min = ZR_CLASS_SPEED_PROP_MIN;
				max = ZR_CLASS_SPEED_PROP_MAX;
			}
		}
		if (!(speed >= min && speed <= max))
		{
			flags += ZR_CLASS_SPEED;
		}
	}
	
	// Knock back.
	float knockBack = attributes[ClassEdit_KnockBack];
	if (knockBack > ZR_CLASS_KNOCKBACK_IGNORE)
	{
		if (!(knockBack >= ZR_CLASS_KNOCKBACK_MIN && knockBack <= ZR_CLASS_KNOCKBACK_MAX))
		{
			flags += ZR_CLASS_KNOCKBACK;
		}
	}
	
	// Jump heigt.
	float jumpHeight = attributes[ClassEdit_JumpHeight];
	if (jumpHeight >= 0.0)
	{
		if (!(jumpHeight >= ZR_CLASS_JUMP_HEIGHT_MIN && jumpHeight <= ZR_CLASS_JUMP_HEIGHT_MAX))
		{
			flags += ZR_CLASS_JUMP_HEIGHT;
		}
	}
	
	// Jump distance.
	float jumpDistance = attributes[ClassEdit_JumpDistance];
	if (jumpDistance >= 0.0)
	{
		if (!(jumpDistance >= ZR_CLASS_JUMP_DISTANCE_MIN && jumpDistance <= ZR_CLASS_JUMP_DISTANCE_MAX))
		{
			flags += ZR_CLASS_JUMP_DISTANCE;
		}
	}
	
	return flags;
}

/**
 * Checks if the specified class index is a valid index.
 *
 * @param classIndex	The class index to validate.
 * @return			  True if the class exist, false otherwise.
 */
stock bool ClassValidateIndex(int classIndex)
{
	if (classIndex >= 0 && classIndex < ClassCount)
	{
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * Compares the class team ID with a team ID.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param teamid	The team ID to compare with the class.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 *				  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is used,
 *				  index will be used as a client index.
 * @return		  True if equal, false otherwise.
 */
stock bool ClassTeamCompare(int index, int teamid, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			if (ClassData[index][Class_Team] == teamid)
			{
				return true;
			}
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			if (ClassDataCache[index][Class_Team] == teamid)
			{
				return true;
			}
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			if (ClassPlayerCache[index][Class_Team] == teamid)
			{
				return true;
			}
		}
	}
	return false;
}

/**
 * Gets the first class index of a class with the specified name (not a case
 * sensitive search).
 *
 * @param name	  The name to search for.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 * @return		  The class index if successful, -1 otherwise.
 */
stock int ClassGetIndex(const char[] name, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	char current_name[64];

	// Check if there are no classes, or reading from player cache.
	if (ClassCount == 0 || cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		return -1;
	}
	
	// Loop through all classes.
	for (int classindex = 0; classindex < ClassCount; classindex++)
	{
		// Get its name and compare it with the specified class name.
		ClassGetName(classindex, current_name, sizeof(current_name), cachetype);
		if (strcmp(name, current_name, false) == 0)
		{
			return classindex;
		}
	}
	
	// The class index wasn't found.
	return -1;
}

/**
 * Gets the currently active class index that the player is using.
 * Note: Does not check if the player is dead.
 *
 * @param client	The client index.
 * @return  The active class index. -1 on error or if a spectactor.
 */
stock int ClassGetActiveIndex(int client)
{
	int teamid;
	
	if (!ZRIsClientOnTeam(client))
	{
		// No active team.
		return -1;
	}
	
	// Check if the player currently is in admin mode.
	if (ClassPlayerInAdminMode[client])
	{
		teamid = ZR_CLASS_TEAM_ADMINS;
	}
	else
	{
		// Not in admin mode, check if player is human or zombie.
		if (InfectIsClientHuman(client))
		{
			teamid = ZR_CLASS_TEAM_HUMANS;
		}
		else
		{
			teamid = ZR_CLASS_TEAM_ZOMBIES;
		}
	}
	
	// Return the active class for the active team.
	return ClassSelected[client][teamid];
}

/**
 * Gets the multiplier for the specified team and attribute.
 *
 * @param client		The client index.
 * @param attribute	 Specifies what attribute multiplier to get.
 * @return	  Multiplier for the specified team and attribute. 1.0 if the
 *			  client is in admin mode.
 */
stock float ClassGetAttributeMultiplier(int client, ClassMultipliers attribute)
{
	int teamid;
	
	// Check if player is not in admin mode.
	if (!ClassPlayerInAdminMode[client])
	{
		// Not in admin mode, check if player is human or zombie.
		if (InfectIsClientHuman(client))
		{
			teamid = ZR_CLASS_TEAM_HUMANS;
		}
		else
		{
			teamid = ZR_CLASS_TEAM_ZOMBIES;
		}
		
		// Get multiplier for the specified team and attribute.
		return view_as<float>(ClassMultiplierCache[teamid][attribute]);
	}
	else
	{
		// Do not use multipliers on admin classes.
		return 1.0;
	}
}

/**
 * Check if a class pass the specified filter.
 * 
 * @param index		 Index of the class in a class cache or a client index,
 *					  depending on the cache type specified.
 * @param filter		Structure with filter settings.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest
 *					  class data.
 *					  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is
 *					  used index will be used as a client index.
 * @return			  True if passed, false otherwise.
 */
stock bool ClassFilterMatch(int index, filter[ClassFilter], int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	// Check if the class is disabled and the enabled attribute is NOT ignored.
	if (!filter[ClassFilter_IgnoreEnabled] && !ClassIsEnabled(index, cachetype))
	{
		return false;
	}
	
	// Check if class flags pass the flag filter.
	if (!ClassFlagFilterMatch(index, filter[ClassFilter_RequireFlags], filter[ClassFilter_DenyFlags], cachetype))
	{
		return false;
	}
	
	// Get class group name.
	char groupname[64];
	groupname[0] = 0;
	ClassGetGroup(index, groupname, sizeof(groupname), cachetype);

	// Get class sm_flags.
	char sm_flags[64];
	sm_flags[0] = 0;
	ClassGetSM_Flags(index, sm_flags, sizeof(sm_flags), cachetype);
	
	// Check if a client is specified in the filter.
	int client = filter[ClassFilter_Client];
	if (ZRIsClientValid(client))
	{
		// Check if a group is set on the class.
		if (strlen(groupname))
		{
			// Check if the client is not a member of that group.
			if (!ZRIsClientInGroup(client, groupname))
			{
				return false;
			}
		}
		// Check if there are any sm_flags set.
		if (strlen(sm_flags))
		{
			int flags = ReadFlagString(sm_flags);

			// No valid flag, blocked for everyone.
			if(!flags)
				return false;

			// Check if user doesn't have the required flags.
			if(GetUserFlagBits(client) & flags != flags)
			return false;
		}
	}
	
	// Check if classes with groups are set to be excluded.
	if (client < 0)
	{
		// Exclude class if it has a group name.
		if (strlen(groupname))
		{
			return false;
		}

		// Exclude class if it requires flags.
		if (strlen(sm_flags))
		{
			return false;
		}
	}
	
	// The class passed the filter.
	return true;
}

/**
 * Check if a class pass the specified flag filters.
 * 
 * @param index		 Index of the class in a class cache or a client index,
 *					  depending on the cache type specified.
 * @param require	   Class flags to require. 0 for no filter.
 * @param deny		  Class flags to exclude. 0 for no filter.
 * @param cachetype	 Specifies what class cache to read from. Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest
 *					  class data.
 *					  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is
 *					  used index will be used as a client index.
 * @return			  True if passed, false otherwise.
 */
stock bool ClassFlagFilterMatch(int index, int require, int deny, int cachetype)
{
	int flags;
	bool requirepassed = false;
	bool denypassed = false;
	
	// Do quick check for optimization reasons: Check if no flags are specified.
	if (require == 0 && deny == 0)
	{
		return true;
	}
	
	// Cache flags.
	flags = ClassGetFlags(index, cachetype);
	
	// Match require filter.
	if (require == 0 || flags & require)
	{
		// All required flags are set.
		requirepassed = true;
	}
	
	// Match deny filter.
	if (deny == 0 || !(flags & deny))
	{
		// No denied flags are set.
		denypassed = true;
	}
	
	// Check if required and denied flags passed the filter.
	if (requirepassed && denypassed)
	{
		// The class pass the filter.
		return true;
	}
	
	// The class didn't pass the filter.
	return false;
}

/**
 * Decides whether a class selection menu should be enabled. The decision is
 * based on zr_class_allow_* console variables.
 *
 * @param team	  Optional. Team ID to match. Default is all.
 * @param filter	Optional. Filter to use on classes.
 * @return		  True if allowed, false otherwise.
 */
bool ClassAllowSelection(int client, int team = -1, filter[ClassFilter] = ClassNoFilter)
{
	// Get selection settings.
	bool zombie = GetConVarBool(g_hCvarsList[CVAR_CLASSES_ZOMBIE_SELECT]);
	bool human = GetConVarBool(g_hCvarsList[CVAR_CLASSES_HUMAN_SELECT]);
	bool admin = GetConVarBool(g_hCvarsList[CVAR_CLASSES_ADMIN_SELECT]);
	
	// Since admin mode classes are optional they must be counted to verify
	// that they exist.
	bool adminexist;
	
	// Check if player is admin.
	bool isadmin = ZRIsClientAdmin(client);
	
	// Only count admin mode classes if client is admin.
	if (isadmin)
	{
		adminexist = ClassCountTeam(ZR_CLASS_TEAM_ADMINS, filter) > 0;
	}
	
	// Check if a team id is specified.
	if (team >= 0)
	{
		// Check team and return the corresponding selection setting.
		switch (team)
		{
			case ZR_CLASS_TEAM_ZOMBIES:
			{
				return zombie;
			}
			case ZR_CLASS_TEAM_HUMANS:
			{
				return human;
			}
			case ZR_CLASS_TEAM_ADMINS:
			{
				// Player must be admin to select admin mode classes.
				return admin && isadmin && adminexist;
			}
		}
		
		// Team ID didn't match.
		return false;
	}
	else
	{
		// Check zombie and human.
		return zombie || human;
	}
}

/**
 * Gets all class indexes or from a specified team, and adds them to the
 * specified array.
 * 
 * @param array			 The destination array to add class indexes.
 * @param teamfilter		Optional. The team ID to filter. A negative value
 *						  for no filter (default).
 * @param filter			Optional. Structure with filter settings.
 * @param cachetype		 Optional. Specifies what class cache to read from.
 *						  Options:
 *						  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *						  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest
 *						  class data.
 * @return  True on success. False on error or if no classes were added or
 *		  found.
 */
stock bool ClassAddToArray(Handle array, int teamfilter = -1, int filter[ClassFilter] = ClassNoFilter, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	// Validate the array.
	if (array == INVALID_HANDLE)
	{
		return false;
	}
	
	// Check if there are no classes.
	if (ClassCount == 0)
	{
		return false;
	}
	
	// Store a local boolean that says if the user specified a team filter or not.
	bool hasteamfilter = view_as<bool>((teamfilter >= 0));
	int classesadded;
	
	// Loop through all classes.
	for (int classindex = 0; classindex < ClassCount; classindex++)
	{
		// Validate filter settings.
		if (!ClassFilterMatch(classindex, filter, cachetype))
		{
			// The class is didn't pass the filter, skip class.
			continue;
		}
		
		// Check team filtering.
		if (hasteamfilter)
		{
			// Only add classes with matching team ID.
			if (ClassGetTeamID(classindex, cachetype) == teamfilter)
			{
				// Team ID match. Add class index to array.
				PushArrayCell(array, classindex);
				classesadded++;
			}
		}
		else
		{
			// No filter. Add any class to the array.
			PushArrayCell(array, classindex);
			classesadded++;
		}
	}
	
	if (classesadded)
	{
		return true;
	}
	else
	{
		// No classes were found/added.
		return false;
	}
}

/**
 * Counts total classes or classes in the specified team.
 *
 * @param teamfilter		Optional. The team ID to filter. Negative value for
 *						  no filter (default).
 * @param filter			Optional. Structure with filter settings.
 * @param cachetype		 Optional. Specifies what class cache to read from.
 *						  Options:
 *						  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *						  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest
 *						  class data.
 * @return  Number of total classes or classes in the specified team.
 */
stock int ClassCountTeam(int teamfilter = -1, filter[ClassFilter] = ClassNoFilter, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	// Check if there are no classes.
	if (ClassCount == 0)
	{
		return 0;
	}
	
	// Store a local boolean that says if the user specified a team filter or not.
	bool hasteamfilter = view_as<bool>((teamfilter >= 0));
	int count;
	
	// Loop through all classes.
	for (int classindex = 0; classindex < ClassCount; classindex++)
	{
		// Validate filter settings.
		if (!ClassFilterMatch(classindex, filter, cachetype))
		{
			// The class is didn't pass the filter, skip class.
			continue;
		}
		
		// Check team filtering.
		if (hasteamfilter)
		{
			// Only add classes with matching team ID.
			if (ClassGetTeamID(classindex, cachetype) == teamfilter)
			{
				// Team ID match. Increment counter.
				count++;
			}
		}
		else
		{
			// No filter. Increment counter.
			count++;
		}
	}
	
	// Return number of classes found.
	return count;
}

/**
 * Gets a random class index from a specified team or from all classes.
 *
 * @param teamfilter		Optional. The team ID to filter. A negative value
 *						  for no filter (default).
 * @param filter			Optional. Structure with filter settings.
 * @param cachetype		 Optional. Specifies what class cache to read from.
 *						  Options:
 *						  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *						  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest
 *						  class data.
 * @return  The class index if successful, or -1 on error.
 */
stock int ClassGetRandomClass(int teamfilter = -1, filter[ClassFilter] = ClassNoSpecialClasses, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	Handle classarray;
	int arraycount;
	int randnum;
	int buffer;
	
	classarray = CreateArray();
	
	// Try to get a class list.
	if (ClassAddToArray(classarray, teamfilter, filter, cachetype))
	{
		// Get a random index from the new class array.
		arraycount = GetArraySize(classarray);
		randnum = GetRandomInt(0, arraycount - 1);
		
		// Return the value at the random index.
		buffer = GetArrayCell(classarray, randnum);
		CloseHandle(classarray);
		return buffer;
	}
	else
	{
		// Failed to get a random class.
		CloseHandle(classarray);
		return -1;
	}
}

/**
 * Gets the first class index, or the first class index with the specified team
 * ID.
 *
 * @param teamfilter		Optional. The team ID to filter. A negative value
 *						  for no filter (default).
 * @param filter			Optional. Structure with filter settings.
 * @param cachetype		 Optional. Specifies what class cache to read from.
 *						  Options:
 *						  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *						  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest
 *						  class data.
 * @return  The first class index, or the first class index with the specified
 *		  team ID. -1 on error.
 */
stock int ClassGetFirstClass(int teamfilter = -1, filter[ClassFilter] = ClassNoSpecialClasses, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	// Check if there are no classes.
	if (ClassCount == 0)
	{
		return false;
	}
	
	bool hasteamfilter = view_as<bool>((teamfilter >= 0));
	
	// Loop through all classes.
	for (int classindex = 0; classindex < ClassCount; classindex++)
	{
		// Validate filter settings.
		if (!ClassFilterMatch(classindex, filter, cachetype))
		{
			// The class is didn't pass the filter, skip class.
			continue;
		}
		
		if (hasteamfilter)
		{
			if (teamfilter == ClassGetTeamID(classindex, cachetype))
			{
				// Team ID match. Return the class index.
				return classindex;
			}
		}
		else
		{
			// No team filter. Return the class index.
			return classindex;
		}
	}
	
	return -1;
}

/**
 * Gets the first class marked as default for the specified team.
 *
 * @param teamid			The team ID.
 * @param filter			Optional. Structure with filter settings. Default
 *						  is to deny classes with special flags
 *						  (ZR_CLASS_SPECIALFLAGS).
 * @param cachetype		 Optional. Specifies what class cache to read from.
 *						  Options:
 *						  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *						  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest
 *						  class data.
 * @return  The first default class index. -1 on error.
 */
stock int ClassGetDefaultClass(int teamid, filter[ClassFilter] = ClassNoSpecialClasses, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	Handle classarray;
	int arraycount;
	int classindex;
	
	classarray = CreateArray();
	
	// Get all classes from the specified team.
	if (!ClassAddToArray(classarray, teamid, filter, cachetype))
	{
		// Failed to get classes.
		CloseHandle(classarray);
		return -1;
	}
	
	// Loop through all classes and return the first class marked as team default.
	arraycount = GetArraySize(classarray);
	for (int i = 0; i < arraycount; i++)
	{
		// Get class index from the array.
		classindex = GetArrayCell(classarray, i);
		
		// Check if the current class is marked as team default.
		if (ClassGetTeamDefault(classindex, cachetype))
		{
			// Default class found.
			CloseHandle(classarray);
			return classindex;
		}
	}
	
	CloseHandle(classarray);
	return -1;
}

/**
 * Gets the default class index for the specified team configured to be used
 * when players join the server.
 *
 * @param teamid	The team ID.
 * @param filter	Optional. Structure with filter settings. Default is to
 *				  deny classes with special flags (ZR_CLASS_SPECIALFLAGS).
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 * @return  The class index of the default class for the specified team if
 *		  successful. -1 on critical errors. Otherwise it will try to fall
 *		  back on the first class in the specified team.
 */
stock int ClassGetDefaultSpawnClass(int teamid, filter[ClassFilter] = ClassNoSpecialClasses, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	char classname[64];
	int classindex;
	
	// Get the default class name from the correct CVAR depending on teamid.
	switch (teamid)
	{
		case ZR_CLASS_TEAM_ZOMBIES:
		{
			GetConVarString(g_hCvarsList[CVAR_CLASSES_DEFAULT_ZOMBIE], classname, sizeof(classname));
		}
		case ZR_CLASS_TEAM_HUMANS:
		{
			GetConVarString(g_hCvarsList[CVAR_CLASSES_DEFAULT_HUMAN], classname, sizeof(classname));
		}
		case ZR_CLASS_TEAM_ADMINS:
		{
			GetConVarString(g_hCvarsList[CVAR_CLASSES_DEFAULT_ADMIN_MODE], classname, sizeof(classname));
		}
		default:
		{
			// Invalid team ID.
			return -1;
		}
	}
	
	// Check if the class name isn't empty.
	if (strlen(classname) > 0)
	{
		// Check if the user set "random" as default class.
		if (StrEqual(classname, "random", false))
		{
			// Get a list of all classes with the specified team ID. Deny
			// classes with special flags.
			classindex = ClassGetRandomClass(teamid, filter, cachetype);
			
			// Validate the result, in case there were errors.
			if (ClassValidateIndex(classindex))
			{
				return classindex;
			}
			else
			{
				// Invalid index. The ClassGetRandomClass function is pretty
				// failsafe. So if we can't get a class index here, it's a
				// critical error. No reason to fall back on other solutions.
				return -1;
			}
		}
		else
		{
			// The user set a spesific class.
			
			// Try to get the class index with the specified class name.
			classindex = ClassGetIndex(classname, cachetype);
			
			// Validate the class index and check if the team IDs match.
			if (ClassValidateIndex(classindex) && (teamid == ClassGetTeamID(classindex, cachetype)))
			{
				return classindex;
			}
			else
			{
				// The class index is invalid or the team IDs didn't match.
				// Because it's user input, we'll fall back to the first class
				// in the specified team, and log a warning.
				classindex = ClassGetFirstClass(teamid, filter, cachetype);
				
				LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Default Spawn Class", "Warning: Failed to set \"%s\" as default spawn class for team %d. The class doesn't exist or the team IDs doesn't match. Falling back to the first class in the team.", classname, teamid);
				
				// Validate the new index.
				if (ClassValidateIndex(classindex))
				{
					// Log a warning.
					//LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Default Spawn Class", "Warning: The default class name \"%s\" does not exist or matches the team ID.", classname);
					return classindex;
				}
				else
				{
					// Something went wrong. This is a critical error. There's
					// probably missing classes with no special flags set.
					return -1;
				}
			}
		}
	}
	else
	{
		// Blank class name, get the default class and return the index.
		return ClassGetDefaultClass(teamid, filter, cachetype);
	}
}
