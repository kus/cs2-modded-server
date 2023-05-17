/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  playerclasses.inc
 *  Type:		  Core 
 *  Description:   Provides functions for managing classes.
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
	Ideas for immunity modes for humans:
	- Zombies have to stab x times to infect.
	- Zombies have to hurt humans so they loose hp. When the hp reach zero (or
	  below) they turn into zombies.
	- Fully imune to all damage. Can't take or give damage. Sould only be used
	  on admin mode classes.
	
	TODO: Make class attributes for for changing model render mode and colors.
	
	TODO: Make class attributes for fancy effects, like a glow (if possible).
	
	TODO: Make immunity settings suitable for both teams, or certain zombie-
		  only/human-only settings.
*/

/**
 * Total number of classes that can be stored in each cache.
 */
#define ZR_CLASS_MAX 64

/**
 * @section Class cache types. Specifies what data array to use.
 */
#define ZR_CLASS_CACHE_ORIGINAL 0   /** Points ClassData array. A cache that is never changed after loading. */
#define ZR_CLASS_CACHE_MODIFIED 1   /** Points to ClassDataCache array. Modified by admins or overrides. */
#define ZR_CLASS_CACHE_PLAYER   2   /** Points to ClassPlayerCache array. Current player attributes. */
/**
 * @endsection
 */

/**
 * Number of available class teams.
 */
#define ZR_CLASS_TEAMCOUNT	  3

/**
 * @section Available class teams. The admin team is optional and not required
 * in class configs.
 */
#define ZR_CLASS_TEAM_ZOMBIES   0
#define ZR_CLASS_TEAM_HUMANS	1
#define ZR_CLASS_TEAM_ADMINS	2   /** Note: Will set you in a special mode where you don't really participates in the game, but just walk around. */
/**
 * @endsection
 */

/**
 * @section Damage immunity modes. The mode effects will vary depending on the
 * class team.
 */
#define ZR_CLASS_IMMUNITY_DISABLED  0   /** No immunity. */
#define ZR_CLASS_IMMUNITY_CONSTANT  1   /** Always imune. Should only be used in special cases like on admin classes. */
#define ZR_CLASS_IMMUNITY_TIMED	 2   /** Imune to damage for n seconds. The time is specified in a class as immunity amount. */
/**
 * @endsection
 */

/**
 * @section Flags for special classes.
 */
#define ZR_CLASS_FLAG_ADMIN_ONLY		(1<<0)  /** Class is usable by admins only. */
#define ZR_CLASS_FLAG_MOTHER_ZOMBIE	 (1<<1)  /** Class is usable by mother zombies only. */

/** A combination of special class flags. Used to exclude special classes. */
#define ZR_CLASS_SPECIALFLAGS		   ZR_CLASS_FLAG_ADMIN_ONLY + ZR_CLASS_FLAG_MOTHER_ZOMBIE
/**
 * @endsection
 */

/**
 * @section Overall default class settings. Since this is a zombie plugin the
 * default values represent a zombie.
 */
#define ZR_CLASS_DEFAULT_ENABLED				"yes"
#define ZR_CLASS_DEFAULT_TEAM				   ZR_CLASS_TEAM_ZOMBIES
#define ZR_CLASS_DEFAULT_TEAM_DEFAULT		   "yes"
#define ZR_CLASS_DEFAULT_FLAGS				  0
#define ZR_CLASS_DEFAULT_GROUP				  ""
#define ZR_CLASS_DEFAULT_SM_FLAGS               ""
#define ZR_CLASS_DEFAULT_NAME				   "classic"
#define ZR_CLASS_DEFAULT_DESCRIPTION			"Need brains!!! Arrrrggghh!"
#define ZR_CLASS_DEFAULT_MODEL_PATH			 "models/player/zh/zh_zombie003.mdl"
#define ZR_CLASS_DEFAULT_ARMS_MODEL_PATH			 "default"
#define ZR_CLASS_DEFAULT_MODEL_SKIN_INDEX	   0
#define ZR_CLASS_DEFAULT_ALPHA_INITIAL		  255
#define ZR_CLASS_DEFAULT_ALPHA_DAMAGED		  255
#define ZR_CLASS_DEFAULT_ALPHA_DAMAGE		   0
#define ZR_CLASS_DEFAULT_OVERLAY_PATH		   "overlays/zr/zvision"
#define ZR_CLASS_DEFAULT_NVGS				   "no"
#define ZR_CLASS_DEFAULT_FOV					90
#define ZR_CLASS_DEFAULT_HAS_NAPALM			 "no"
#define ZR_CLASS_DEFAULT_NAPALM_TIME			10.0
#define ZR_CLASS_DEFAULT_IMMUNITY_MODE		  "none"
#define ZR_CLASS_DEFAULT_IMMUNITY_AMOUNT		1
#define ZR_CLASS_DEFAULT_IMMUNITY_COOLDOWN	  60
#define ZR_CLASS_DEFAULT_NO_FALL_DAMAGE		 "yes"
#define ZR_CLASS_DEFAULT_HEALTH				 6000
#define ZR_CLASS_DEFAULT_HEALTH_REGEN_INTERVAL  0.0
#define ZR_CLASS_DEFAULT_HEALTH_REGEN_AMOUNT	2
#define ZR_CLASS_DEFAULT_HEALTH_INFECT_GAIN	 800
#define ZR_CLASS_DEFAULT_KILL_BONUS			 2
#define ZR_CLASS_DEFAULT_SPEED				  0.0
#define ZR_CLASS_DEFAULT_KNOCKBACK			  2.0
#define ZR_CLASS_DEFAULT_JUMP_HEIGHT			10.0
#define ZR_CLASS_DEFAULT_JUMP_DISTANCE		  0.2
/**
 * @endsection
 */

/**
 * @section Attribute limit values. Used when validating.
 */
#define ZR_CLASS_TEAM_MIN				   0
#define ZR_CLASS_TEAM_MAX				   2
#define ZR_CLASS_FLAGS_MIN				  0
#define ZR_CLASS_FLAGS_MAX				  3
#define ZR_CLASS_NAME_MIN				   1
#define ZR_CLASS_DESCRIPTION_MIN			1
/** Model path is checked for existance. */
#define ZR_CLASS_MODEL_SKIN_INDEX_MIN	   0
#define ZR_CLASS_ALPHA_INITIAL_MIN		  0
#define ZR_CLASS_ALPHA_INITIAL_MAX		  255
#define ZR_CLASS_ALPHA_DAMAGED_MIN		  0
#define ZR_CLASS_ALPHA_DAMAGED_MAX		  255
#define ZR_CLASS_ALPHA_DAMAGE_MIN		   0
#define ZR_CLASS_ALPHA_DAMAGE_MAX		   20000
/** Overlay path is optional, and file is checked for existance if specified. */
#define ZR_CLASS_FOV_MIN					15
#define ZR_CLASS_FOV_MAX					165
#define ZR_CLASS_NAPALM_TIME_MIN			0.0
#define ZR_CLASS_NAPALM_TIME_MAX			600.0
#define ZR_CLASS_IMMUNITY_COOLDOWN_MIN	  0
#define ZR_CLASS_IMMUNITY_COOLDOWN_MAX	  600
#define ZR_CLASS_HEALTH_MIN				 1
#define ZR_CLASS_HEALTH_MAX				 100000
#define ZR_CLASS_REGEN_INTERVAL_MIN		 0.0
#define ZR_CLASS_REGEN_INTERVAL_MAX		 900.0
#define ZR_CLASS_REGEN_AMOUNT_MIN		   0
#define ZR_CLASS_REGEN_AMOUNT_MAX		   10000
#define ZR_CLASS_HEALTH_INFECT_GAIN_MIN	 0
#define ZR_CLASS_HEALTH_INFECT_GAIN_MAX	 20000
#define ZR_CLASS_KILL_BONUS_MIN			 0
#define ZR_CLASS_KILL_BONUS_MAX			 16
#define ZR_CLASS_SPEED_LMV_MIN			  10.0
#define ZR_CLASS_SPEED_LMV_MAX			  2000.0
#define ZR_CLASS_SPEED_PROP_MIN			 -200.0
#define ZR_CLASS_SPEED_PROP_MAX			 1750.0
#define ZR_CLASS_KNOCKBACK_MIN			  -30.0
#define ZR_CLASS_KNOCKBACK_MAX			  30.0
#define ZR_CLASS_KNOCKBACK_IGNORE		   -31.0   /** Used by class editor volumetric feature. */
#define ZR_CLASS_JUMP_HEIGHT_MIN			0.0
#define ZR_CLASS_JUMP_HEIGHT_MAX			5.0
#define ZR_CLASS_JUMP_DISTANCE_MIN		  0.0
#define ZR_CLASS_JUMP_DISTANCE_MAX		  5.0
#define ZR_CLASS_ARMSPATH_MIN			1
/**
 * @endsection
 */

/**
 * @section Class attribute flags.
 */
#define ZR_CLASS_ENABLED				(1<<0)
#define ZR_CLASS_TEAM				   (1<<1)
#define ZR_CLASS_TEAM_DEFAULT		   (1<<2)
#define ZR_CLASS_FLAGS				  (1<<3)
#define ZR_CLASS_GROUP				  (1<<4)
#define ZR_CLASS_SM_FLAGS               (1<<5)
#define ZR_CLASS_NAME				   (1<<6)
#define ZR_CLASS_DESCRIPTION			(1<<7)
#define ZR_CLASS_MODEL_PATH			 (1<<8)
#define ZR_CLASS_ARMS_MODEL_PATH		  (1<<9)
#define ZR_CLASS_MODEL_SKIN_INDEX	   (1<<10)
#define ZR_CLASS_ALPHA_INITIAL		  (1<<11)
#define ZR_CLASS_ALPHA_DAMAGED		  (1<<12)
#define ZR_CLASS_ALPHA_DAMAGE		   (1<<13)
#define ZR_CLASS_OVERLAY_PATH		   (1<<14)
#define ZR_CLASS_NVGS				   (1<<15)
#define ZR_CLASS_FOV					(1<<16)
#define ZR_CLASS_HAS_NAPALM			 (1<<17)
#define ZR_CLASS_NAPALM_TIME			(1<<18)
#define ZR_CLASS_IMMUNITY_MODE		  (1<<19)
#define ZR_CLASS_IMMUNITY_AMOUNT		(1<<20)
#define ZR_CLASS_IMMUNITY_COOLDOWN	  (1<<21)
#define ZR_CLASS_NO_FALL_DAMAGE		 (1<<22)
#define ZR_CLASS_HEALTH				 (1<<23)
#define ZR_CLASS_HEALTH_REGEN_INTERVAL  (1<<24)
#define ZR_CLASS_HEALTH_REGEN_AMOUNT	(1<<25)
#define ZR_CLASS_HEALTH_INFECT_GAIN	 (1<<26)
#define ZR_CLASS_KILL_BONUS			 (1<<27)
#define ZR_CLASS_SPEED				  (1<<28)
#define ZR_CLASS_KNOCKBACK			  (1<<29)
#define ZR_CLASS_JUMP_HEIGHT			(1<<30)
#define ZR_CLASS_JUMP_DISTANCE		  (1<<31)
/**
 * @endsection
 */

/**
 * Generic player attributes.
 *
 * Stuff that must be updated when new attributes are added:
 * ZR_CLASS_DEFAULT_... define
 * ZR_CLASS_..._MAX/MIN defines
 * ZR_CLASS_... define (place in same order as listed in ClassAttributes, bump bit numbers + update numbers in docs)
 * ClassLoad
 * ClassReloadDataCache
 * ClassReloadPlayerCache
 * ClassDumpData
 * attributes.inc - Add new Get-function
 * ClassAttributeNameToFlag
 * ClassGetAttributeType
 * ClassValidateAttributes
 * ClassModify* in classcommands.inc
 * VolEmptyAttributes
 * Update docs with detailed attribute description
 */
enum ClassAttributes
{
	/* General */
	bool:Class_Enabled,
	Class_Team,
	bool:Class_TeamDefault,
	Class_Flags,
	String:Class_Group[64],
	String:Class_SM_Flags[64],
	
	String:Class_Name[64],
	String:Class_Description[256],
	
	/* Model */
	String:Class_ModelPath[PLATFORM_MAX_PATH],
	String:Class_Arms_Path[PLATFORM_MAX_PATH],
	Class_ModelSkinIndex,
	Class_AlphaInitial,
	Class_AlphaDamaged,
	Class_AlphaDamage,
	
	/* Hud */
	String:Class_OverlayPath[PLATFORM_MAX_PATH],
	bool:Class_Nvgs,
	Class_Fov,
	
	/* Effects */
	bool:Class_HasNapalm,
	Float:Class_NapalmTime,
	
	/* Player behaviour */
	ImmunityMode:Class_ImmunityMode,
	Class_ImmunityAmount,
	Class_ImmunityCooldown,
	bool:Class_NoFallDamage,
	
	Class_Health,
	Float:Class_HealthRegenInterval,
	Class_HealthRegenAmount,
	Class_HealthInfectGain,
	Class_KillBonus,
	
	Float:Class_Speed,
	Float:Class_KnockBack,
	Float:Class_JumpHeight,
	Float:Class_JumpDistance
}

/**
 * Structure of class attributes that are allowed to be modified directly,
 * while the player is alive.
 *
 * Note: This structure is also used as a mask to tell if a individual
 *	   attribute should be ignored or not. Negative valueas usually indicate
 *	   ignored attributes. Booleans are now ints so they can be negative.
 *	   Strings have reserved keywords like "nochange" that indicate a ignored
 *	   attribute.
 */
enum ClassEditableAttributes
{
	/* Model */
	ClassEdit_ModelSkinIndex = 0,
	ClassEdit_AlphaInitial,
	ClassEdit_AlphaDamaged,
	ClassEdit_AlphaDamage,
	
	/* Hud */
	String:ClassEdit_OverlayPath[PLATFORM_MAX_PATH],
	ClassEdit_Nvgs,
	ClassEdit_Fov,
	
	/* Effects */
	ClassEdit_HasNapalm,
	Float:ClassEdit_NapalmTime,
	
	/* Player behavior */
	ImmunityMode:ClassEdit_ImmunityMode,
	ClassEdit_ImmunityAmount,
	ClassEdit_ImmunityCooldown,
	
	ClassEdit_NoFallDamage,
	Float:ClassEdit_RegenInterval,
	ClassEdit_RegenAmount,
	ClassEdit_InfectGain,
	ClassEdit_KillBonus,
	
	Float:ClassEdit_Speed,
	Float:ClassEdit_KnockBack,
	Float:ClassEdit_JumpHeight,
	Float:ClassEdit_JumpDistance
}

/**
 * Class attributes that support multipliers.
 */
enum ClassMultipliers
{
	ClassM_Invalid = 0,
	Float:ClassM_NapalmTime,
	Float:ClassM_Health,
	Float:ClassM_HealthRegenInterval,
	Float:ClassM_HealthRegenAmount,
	Float:ClassM_HealthInfectGain,
	Float:ClassM_Speed,
	Float:ClassM_Knockback,
	Float:ClassM_JumpHeight,
	Float:ClassM_JumpDistance
}

/**
 * Available class teams, used to specify targets.
 */
enum ClassTeams
{
	ClassTeam_Zombies = 0,
	ClassTeam_Humans,
	ClassTeam_Admins,
	ClassTeam_All
}

/**
 * Data types used in class attributes.
 */
enum ClassDataTypes
{
	ClassDataType_InvalidType,  /** Invalid type */
	ClassDataType_Boolean,	  /** Boolean value */
	ClassDataType_Integer,	  /** Integer value */
	ClassDataType_Float,		/** Floating point value */
	ClassDataType_String		/** String value */
}

/**
 * Structure for class filter settings passed to various functions.
 */
enum ClassFilter
{
	bool:ClassFilter_IgnoreEnabled,	 /** Ignore whether the class is disabled or not. */
	ClassFilter_RequireFlags,		   /** Flags the classes must have set. */
	ClassFilter_DenyFlags,			  /** Flags the classes cannot have set. */
	ClassFilter_Client				  /** The client to check for class group permissions. Use 0 to ignore group filter and negative to exclude classes with groups set. */
}

/**
 * Speed methods for applying player speed.
 */
enum ClassSpeedMethods
{
	ClassSpeed_Invalid = -1,
	ClassSpeed_LMV,			 /** Modifies lagged movement value. */
	ClassSpeed_Prop,			/** Modifies players' max speed property(m_flMaxspeed). */
}

/**
 * Results when selecting a class for a player.
 */
enum ClassSelectResult
{
	ClassSelected_NoChange,	 /** No class change was necessary (class already selected). */
	ClassSelected_Instant,	  /** Class was instantly changed. */
	ClassSelected_NextSpawn	 /** Class will be used next spawn. */
}

/**
 * Empty filter structure.
 */
int ClassNoFilter[ClassFilter];

/**
 * Filter structure for excluding special classes.
 */
int ClassNoSpecialClasses[ClassFilter] = {false, 0, ZR_CLASS_SPECIALFLAGS, -1};

/**
 * The original class data. This array is only changed when class data is
 * loaded. ZR_CLASS_CACHE_ORIGINAL is the cache type to this array.
 */
int ClassData[ZR_CLASS_MAX][ClassAttributes];

/**
 * The class data cache that can be modified. ZR_CLASS_CACHE_MODIFIED is the
 * cache type to this array.
 */
int ClassDataCache[ZR_CLASS_MAX][ClassAttributes];

/**
 * Cache for player attributes. Makes it possible for one or more players to
 * have custom attributes. ZR_CLASS_CACHE_PLAYER is the cache type to this
 * array.
 */
int ClassPlayerCache[MAXPLAYERS + 1][ClassAttributes];

/**
 * Cache for storing global multipliers, per team and per attribute when
 * possible. Only attributes that support multipliers will be used, others are
 * ignored.
 */
float ClassMultiplierCache[ZR_CLASS_TEAMCOUNT][ClassMultipliers];

/**
 * Number of classes loaded.
 */
int ClassCount;

/**
 * Specifies whether the class team requirements and attributes are valid or not.
 * Used to block events that happend before the module is done loading.
 */
bool ClassValidated;

/**
 * Stores what class the player has selected, for each team.
 */
int ClassSelected[MAXPLAYERS + 1][ZR_CLASS_TEAMCOUNT];

/**
 * Stores what class to be restored on next spawn, if available.
 */
int ClassSelectedNext[MAXPLAYERS + 1][ZR_CLASS_TEAMCOUNT];

/**
 * Cache for the currently selected team (admin menus).
 */
int ClassAdminTeamSelected[MAXPLAYERS + 1];

/**
 * Cookies for storing class indexes.
 */
Handle g_hClassCookieClassSelected[ZR_CLASS_TEAMCOUNT];

/**
 * Cache for the currently selected attribute multiplier (admin menus).
 */
ClassMultipliers ClassAdminAttributeSelected[MAXPLAYERS + 1];

/**
 * Specifies whether a player is currently in admin mode.
 */
bool ClassPlayerInAdminMode[MAXPLAYERS + 1];

/**
 * Specifies whether a player is allowed to change class with instant effect.
 * This is only used on human classes, and in combination with the
 * zr_classes_change_timelimit time limit, but could be used other places too.
 * The class menu will automatically check this setting and apply attributes if
 * set to true.
 */
bool ClassAllowInstantChange[MAXPLAYERS + 1];

/**
 * Cache for storing original model path before applying custom models. Used
 * when restoring to old model.
 */
char ClassOriginalPlayerModel[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

/**
 * Specifies whether a player has spawned.
 */
bool ClassPlayerSpawned[MAXPLAYERS + 1];

/**
 * What method used to apply speed on players.
 */
ClassSpeedMethods ClassSpeedMethod = ClassSpeed_Prop;

#include "zr/playerclasses/filtertools"
#include "zr/playerclasses/attributes"
#include "zr/playerclasses/apply"
#include "zr/playerclasses/clientoverlays"
#include "zr/playerclasses/clientalpha"
#include "zr/playerclasses/healthregen"
#include "zr/playerclasses/classevents"
#include "zr/playerclasses/classmenus"
#include "zr/playerclasses/classcommands"

/**
 * Loads class attributes from the class file into ClassData array. If any
 * error occur the plugin load will fail, and errors will be logged.
 *
 * @param keepMultipliers   Optional. Don't reset multipliers. Default is
 *						  false.
 */
void ClassLoad()
{
	// Register config file.
	ConfigRegisterConfig(File_Classes, Structure_Keyvalue, CONFIG_FILE_ALIAS_CLASSES);
	
	Handle kvClassData;
	
	// Make sure kvClassData is ready to use.
	kvClassData = CreateKeyValues(CONFIG_FILE_ALIAS_CLASSES);
	
	// Get weapons config path.
	char pathclasses[PLATFORM_MAX_PATH];
	bool exists = ConfigGetCvarFilePath(CVAR_CONFIG_PATH_CLASSES, pathclasses);
	
	// If file doesn't exist, then log and stop.
	if (!exists)
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Missing playerclasses config file \"%s\"", pathclasses);
		
		// Remove key/value cache.
		CloseHandle(kvClassData);
		kvClassData = INVALID_HANDLE;
		
		return;
	}
	
	// Log what class file that is loaded.
	LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Loading classes from file \"%s\".", pathclasses);
	
	// Put file data into memory.
	FileToKeyValues(kvClassData, pathclasses);
	
	// Try to find the first class.
	KvRewind(kvClassData);
	if (!KvGotoFirstSubKey(kvClassData))
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Can't find any classes in \"%s\"", pathclasses);
	}
	
	char name[64];
	char group[64];
	char sm_flags[64];
	char description[256];
	char model_path[PLATFORM_MAX_PATH];
	char arms_path[PLATFORM_MAX_PATH];
	char immunity_mode[32];
	char overlay_path[PLATFORM_MAX_PATH];
	
	ClassCount = 0;
	int failedcount;
	int ClassErrorFlags;
	
	// Loop through all classes and store attributes in the ClassData array.
	do
	{
		if (ClassCount >= ZR_CLASS_MAX)
		{
			// Maximum classes reached. Write a warning and exit the loop.
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Maximum classes reached (%d). Skipping other classes.", ZR_CLASS_MAX + 1);
			
			break;
		}
		
		/* General */
		ClassData[ClassCount][Class_Enabled] = ConfigKvGetStringBool(kvClassData, "enabled", ZR_CLASS_DEFAULT_ENABLED);
		ClassData[ClassCount][Class_Team] = KvGetNum(kvClassData, "team", ZR_CLASS_DEFAULT_TEAM);
		ClassData[ClassCount][Class_TeamDefault] = ConfigKvGetStringBool(kvClassData, "team_default", ZR_CLASS_DEFAULT_TEAM_DEFAULT);
		ClassData[ClassCount][Class_Flags] = KvGetNum(kvClassData, "flags", ZR_CLASS_DEFAULT_FLAGS);
		
		KvGetString(kvClassData, "group", group, sizeof(group), ZR_CLASS_DEFAULT_GROUP);
		strcopy(ClassData[ClassCount][Class_Group], 64, group);
		
		KvGetString(kvClassData, "sm_flags", sm_flags, sizeof(sm_flags), ZR_CLASS_DEFAULT_SM_FLAGS);
		strcopy(ClassData[ClassCount][Class_SM_Flags], 64, sm_flags);
		
		KvGetString(kvClassData, "name", name, sizeof(name), ZR_CLASS_DEFAULT_NAME);
		strcopy(ClassData[ClassCount][Class_Name], 64, name);
		
		KvGetString(kvClassData, "description", description, sizeof(description), ZR_CLASS_DEFAULT_DESCRIPTION);
		strcopy(ClassData[ClassCount][Class_Description], 256, description);
		
		
		/* Model */
		KvGetString(kvClassData, "model_path", model_path, sizeof(model_path), ZR_CLASS_DEFAULT_MODEL_PATH);
		strcopy(ClassData[ClassCount][Class_ModelPath], PLATFORM_MAX_PATH, model_path);
		
		KvGetString(kvClassData, "arms_path", arms_path, sizeof(arms_path), ZR_CLASS_DEFAULT_ARMS_MODEL_PATH);
		strcopy(ClassData[ClassCount][Class_Arms_Path], PLATFORM_MAX_PATH, arms_path);
		
		ClassData[ClassCount][Class_ModelSkinIndex] = KvGetNum(kvClassData, "model_skin_index", ZR_CLASS_DEFAULT_MODEL_SKIN_INDEX);
		ClassData[ClassCount][Class_AlphaInitial] = KvGetNum(kvClassData, "alpha_initial", ZR_CLASS_DEFAULT_ALPHA_INITIAL);
		ClassData[ClassCount][Class_AlphaDamaged] = KvGetNum(kvClassData, "alpha_damaged", ZR_CLASS_DEFAULT_ALPHA_DAMAGED);
		ClassData[ClassCount][Class_AlphaDamage] = KvGetNum(kvClassData, "alpha_damage", ZR_CLASS_DEFAULT_ALPHA_DAMAGE);
		
		
		/* Hud */
		KvGetString(kvClassData, "overlay_path", overlay_path, sizeof(overlay_path), ZR_CLASS_DEFAULT_OVERLAY_PATH);
		strcopy(ClassData[ClassCount][Class_OverlayPath], PLATFORM_MAX_PATH, overlay_path);
		
		ClassData[ClassCount][Class_Nvgs] = ConfigKvGetStringBool(kvClassData, "nvgs", ZR_CLASS_DEFAULT_NVGS);
		ClassData[ClassCount][Class_Fov] = KvGetNum(kvClassData, "fov", ZR_CLASS_DEFAULT_FOV);
		
		
		/* Effects */
		ClassData[ClassCount][Class_HasNapalm] = ConfigKvGetStringBool(kvClassData, "has_napalm", ZR_CLASS_DEFAULT_HAS_NAPALM);
		ClassData[ClassCount][Class_NapalmTime] = KvGetFloat(kvClassData, "napalm_time", ZR_CLASS_DEFAULT_NAPALM_TIME);
		
		
		/* Player behaviour */
		KvGetString(kvClassData, "immunity_mode", immunity_mode, sizeof(immunity_mode), ZR_CLASS_DEFAULT_IMMUNITY_MODE);
		ClassData[ClassCount][Class_ImmunityMode] = ImmunityStringToMode(immunity_mode);
		ClassData[ClassCount][Class_ImmunityAmount] = KvGetNum(kvClassData, "immunity_amount", ZR_CLASS_DEFAULT_IMMUNITY_AMOUNT);
		ClassData[ClassCount][Class_ImmunityCooldown] = KvGetNum(kvClassData, "immunity_cooldown", ZR_CLASS_DEFAULT_IMMUNITY_COOLDOWN);
		ClassData[ClassCount][Class_NoFallDamage] = ConfigKvGetStringBool(kvClassData, "no_fall_damage", ZR_CLASS_DEFAULT_NO_FALL_DAMAGE);
		
		ClassData[ClassCount][Class_Health] = KvGetNum(kvClassData, "health", ZR_CLASS_DEFAULT_HEALTH);
		ClassData[ClassCount][Class_HealthRegenInterval] = KvGetFloat(kvClassData, "health_regen_interval", ZR_CLASS_DEFAULT_HEALTH_REGEN_INTERVAL);
		ClassData[ClassCount][Class_HealthRegenAmount] = KvGetNum(kvClassData, "health_regen_amount", ZR_CLASS_DEFAULT_HEALTH_REGEN_AMOUNT);
		ClassData[ClassCount][Class_HealthInfectGain] = KvGetNum(kvClassData, "health_infect_gain", ZR_CLASS_DEFAULT_HEALTH_INFECT_GAIN);
		ClassData[ClassCount][Class_KillBonus] = KvGetNum(kvClassData, "kill_bonus", ZR_CLASS_DEFAULT_KILL_BONUS);
		
		ClassData[ClassCount][Class_Speed] = KvGetFloat(kvClassData, "speed", ZR_CLASS_DEFAULT_SPEED);
		ClassData[ClassCount][Class_KnockBack] = KvGetFloat(kvClassData, "knockback", ZR_CLASS_DEFAULT_KNOCKBACK);
		ClassData[ClassCount][Class_JumpHeight] = KvGetFloat(kvClassData, "jump_height", ZR_CLASS_DEFAULT_JUMP_HEIGHT);
		ClassData[ClassCount][Class_JumpDistance] = KvGetFloat(kvClassData, "jump_distance", ZR_CLASS_DEFAULT_JUMP_DISTANCE);
		
		// Validate class attributes if class is enabled.
		if (ClassData[ClassCount][Class_Enabled])
		{
			ClassErrorFlags = ClassValidateAttributes(ClassCount, true);
			if (ClassErrorFlags > 0)
			{
				// There's one or more invalid class attributes. Disable the class
				// and log an error message.
				ClassData[ClassCount][Class_Enabled] = false;
				LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Warning: Invalid class at index %d, disabled class. Class error flags: %d.", ClassCount, ClassErrorFlags);
				
				failedcount++;
			}
		}
		
		// Update the counter.
		ClassCount++;
	} while (KvGotoNextKey(kvClassData));
	
	// Validate team requirements.
	if (!ClassValidateTeamRequirements())
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "The class configuration doesn't match the team requirements.");
	}
	
	// Validate team default requirements.
	if (!ClassValidateTeamDefaults())
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Couldn't find a default class for one or more teams. At least one class per team must be marked as default.");
	}
	
	// Cache class data.
	ClassReloadDataCache();
	
	// Reset selected class indexes for next spawn.
	ClassResetNextIndexes();
	
	// Mark classes as valid.
	ClassValidated = true;
	
	// Log summary.
	LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Playerclasses, "Config Validation", "Total: %d | Successful: %d | Unsuccessful: %d", ClassCount, ClassCount - failedcount, failedcount);
	
	// Set config data.
	ConfigSetConfigLoaded(File_Classes, true);
	ConfigSetConfigReloadFunc(File_Classes, GetFunctionByName(GetMyHandle(), "ClassOnConfigReload"));
	ConfigSetConfigPath(File_Classes, pathclasses);
	
	// Remove key/value cache.
	CloseHandle(kvClassData);
	kvClassData = INVALID_HANDLE;
}

/**
 * Called when configs are being reloaded.
 * 
 * @param config	The config being reloaded. (only if 'all' is false)
 */
public void ClassOnConfigReload(ConfigFile config)
{
	// Reload class config.
	ClassLoad();
}

/** 
 * Gets the speed method.
 *
 * @return  Speed method, or ClassSpeed_Invalid on error.
 */
ClassSpeedMethods ClassGetSpeedMethod()
{
	char speedMethod[16];
	speedMethod[0] = 0;
	
	GetConVarString(g_hCvarsList[CVAR_CLASSES_SPEED_METHOD], speedMethod, sizeof(speedMethod));
	
	if (StrEqual(speedMethod, "lmv", false))
	{
		return ClassSpeed_LMV;
	}
	else if (StrEqual(speedMethod, "prop", false))
	{
		return ClassSpeed_Prop;
	}
	
	return ClassSpeed_Invalid;
}

/**
 * Updates the class data cache. Original values are retrieved from ClassData.
 *
 * @return	  True on success, false otherwise.
 */
bool ClassReloadDataCache()
{
	// Check if there are no classes.
	if (ClassCount == 0)
	{
		return false;
	}
	
	// Loop through all classes.
	for (int classindex = 0; classindex < ClassCount; classindex++)
	{
		/* General */
		ClassDataCache[classindex][Class_Enabled] = ClassData[classindex][Class_Enabled];
		ClassDataCache[classindex][Class_Team] = ClassData[classindex][Class_Team];
		ClassDataCache[classindex][Class_TeamDefault] = ClassData[classindex][Class_TeamDefault];
		ClassDataCache[classindex][Class_Flags] = ClassData[classindex][Class_Flags];
		strcopy(ClassDataCache[classindex][Class_Group], 64, ClassData[classindex][Class_Group]);
		strcopy(ClassDataCache[classindex][Class_SM_Flags], 64, ClassData[classindex][Class_SM_Flags]);
		strcopy(ClassDataCache[classindex][Class_Name], 64, ClassData[classindex][Class_Name]);
		strcopy(ClassDataCache[classindex][Class_Description], 256, ClassData[classindex][Class_Description]);
		
		/* Model */
		strcopy(ClassDataCache[classindex][Class_ModelPath], PLATFORM_MAX_PATH, ClassData[classindex][Class_ModelPath]);
		strcopy(ClassDataCache[classindex][Class_Arms_Path], PLATFORM_MAX_PATH, ClassData[classindex][Class_Arms_Path]);
		ClassDataCache[classindex][Class_ModelSkinIndex] = ClassData[classindex][Class_ModelSkinIndex];
		ClassDataCache[classindex][Class_AlphaInitial] = ClassData[classindex][Class_AlphaInitial];
		ClassDataCache[classindex][Class_AlphaDamaged] = ClassData[classindex][Class_AlphaDamaged];
		ClassDataCache[classindex][Class_AlphaDamage] = ClassData[classindex][Class_AlphaDamage];
		
		/* Hud */
		strcopy(ClassDataCache[classindex][Class_OverlayPath], PLATFORM_MAX_PATH, ClassData[classindex][Class_OverlayPath]);
		ClassDataCache[classindex][Class_Nvgs] = ClassData[classindex][Class_Nvgs];
		ClassDataCache[classindex][Class_Fov] = ClassData[classindex][Class_Fov];
		
		/* Effects */
		ClassDataCache[classindex][Class_HasNapalm] = ClassData[classindex][Class_HasNapalm];
		ClassDataCache[classindex][Class_NapalmTime] = ClassData[classindex][Class_NapalmTime];
		
		/* Player behavior */
		ClassDataCache[classindex][Class_ImmunityMode] = ClassData[classindex][Class_ImmunityMode];
		ClassDataCache[classindex][Class_ImmunityAmount] = ClassData[classindex][Class_ImmunityAmount];
		ClassDataCache[classindex][Class_ImmunityCooldown] = ClassData[classindex][Class_ImmunityCooldown];
		ClassDataCache[classindex][Class_NoFallDamage] = ClassData[classindex][Class_NoFallDamage];
		ClassDataCache[classindex][Class_Health] = ClassData[classindex][Class_Health];
		ClassDataCache[classindex][Class_HealthRegenInterval] = ClassData[classindex][Class_HealthRegenInterval];
		ClassDataCache[classindex][Class_HealthRegenAmount] = ClassData[classindex][Class_HealthRegenAmount];
		ClassDataCache[classindex][Class_HealthInfectGain] = ClassData[classindex][Class_HealthInfectGain];
		ClassDataCache[classindex][Class_KillBonus] = ClassData[classindex][Class_KillBonus];
		ClassDataCache[classindex][Class_Speed] = ClassData[classindex][Class_Speed];
		ClassDataCache[classindex][Class_KnockBack] = ClassData[classindex][Class_KnockBack];
		ClassDataCache[classindex][Class_JumpHeight] = ClassData[classindex][Class_JumpHeight];
		ClassDataCache[classindex][Class_JumpDistance] = ClassData[classindex][Class_JumpDistance];
	}
	
	return true;
}

/**
 * Refresh the specified player's cache from the specified class data cache.
 *
 * @param client		The client index.
 * @param classindex	The index of the class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options: ZR_CLASS_CACHE_ORIGINAL (unchanged class
 *					  data), ZR_CLASS_CACHE_MODIFIED (default, modified class
 *					  data).
 * @return	  True if successful, false otherwise.
 */
bool ClassReloadPlayerCache(int client, int classindex, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	// Validate indexes.
	if (!ClassValidateIndex(classindex) || !ZRIsClientValid(client))
	{
		return false;
	}
	
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			/* General */
			ClassPlayerCache[client][Class_Enabled] = ClassData[classindex][Class_Enabled];
			ClassPlayerCache[client][Class_Team] = ClassData[classindex][Class_Team];
			ClassPlayerCache[client][Class_TeamDefault] = ClassData[classindex][Class_TeamDefault];
			ClassPlayerCache[client][Class_Flags] = ClassData[classindex][Class_Flags];
			strcopy(ClassPlayerCache[client][Class_Group], 64, ClassData[classindex][Class_Group]);
			strcopy(ClassPlayerCache[client][Class_SM_Flags], 64, ClassData[classindex][Class_SM_Flags]);
			strcopy(ClassPlayerCache[client][Class_Name], 64, ClassData[classindex][Class_Name]);
			strcopy(ClassPlayerCache[client][Class_Description], 256, ClassData[classindex][Class_Description]);
			
			/* Model */
			strcopy(ClassPlayerCache[client][Class_ModelPath], PLATFORM_MAX_PATH, ClassData[classindex][Class_ModelPath]);
			strcopy(ClassPlayerCache[client][Class_Arms_Path], PLATFORM_MAX_PATH, ClassData[classindex][Class_Arms_Path]);
			ClassPlayerCache[client][Class_ModelSkinIndex] = ClassData[classindex][Class_ModelSkinIndex];
			ClassPlayerCache[client][Class_AlphaInitial] = ClassData[classindex][Class_AlphaInitial];
			ClassPlayerCache[client][Class_AlphaDamaged] = ClassData[classindex][Class_AlphaDamaged];
			ClassPlayerCache[client][Class_AlphaDamage] = ClassData[classindex][Class_AlphaDamage];
			
			/* Hud */
			strcopy(ClassPlayerCache[client][Class_OverlayPath], PLATFORM_MAX_PATH, ClassData[classindex][Class_OverlayPath]);
			ClassPlayerCache[client][Class_Nvgs] = ClassData[classindex][Class_Nvgs];
			ClassPlayerCache[client][Class_Fov] = ClassData[classindex][Class_Fov];
			
			/* Effects */
			ClassPlayerCache[client][Class_HasNapalm] = ClassData[classindex][Class_HasNapalm];
			ClassPlayerCache[client][Class_NapalmTime] = ClassData[classindex][Class_NapalmTime];
			
			/* Player behavior */
			ClassPlayerCache[client][Class_ImmunityMode] = ClassData[classindex][Class_ImmunityMode];
			ClassPlayerCache[client][Class_ImmunityAmount] = ClassData[classindex][Class_ImmunityAmount];
			ClassPlayerCache[client][Class_ImmunityCooldown] = ClassData[classindex][Class_ImmunityCooldown];
			ClassPlayerCache[client][Class_NoFallDamage] = ClassData[classindex][Class_NoFallDamage];
			ClassPlayerCache[client][Class_Health] = ClassData[classindex][Class_Health];
			ClassPlayerCache[client][Class_HealthRegenInterval] = ClassData[classindex][Class_HealthRegenInterval];
			ClassPlayerCache[client][Class_HealthRegenAmount] = ClassData[classindex][Class_HealthRegenAmount];
			ClassPlayerCache[client][Class_HealthInfectGain] = ClassData[classindex][Class_HealthInfectGain];
			ClassPlayerCache[client][Class_KillBonus] = ClassData[classindex][Class_KillBonus];
			ClassPlayerCache[client][Class_Speed] = ClassData[classindex][Class_Speed];
			ClassPlayerCache[client][Class_KnockBack] = ClassData[classindex][Class_KnockBack];
			ClassPlayerCache[client][Class_JumpHeight] = ClassData[classindex][Class_JumpHeight];
			ClassPlayerCache[client][Class_JumpDistance] = ClassData[classindex][Class_JumpDistance];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			/* General */
			ClassPlayerCache[client][Class_Enabled] = ClassDataCache[classindex][Class_Enabled];
			ClassPlayerCache[client][Class_Team] = ClassDataCache[classindex][Class_Team];
			ClassPlayerCache[client][Class_TeamDefault] = ClassDataCache[classindex][Class_TeamDefault];
			ClassPlayerCache[client][Class_Flags] = ClassDataCache[classindex][Class_Flags];
			strcopy(ClassPlayerCache[client][Class_Group], 64, ClassDataCache[classindex][Class_Group]);
			strcopy(ClassPlayerCache[client][Class_SM_Flags], 64, ClassDataCache[classindex][Class_SM_Flags]);
			strcopy(ClassPlayerCache[client][Class_Name], 64, ClassDataCache[classindex][Class_Name]);
			strcopy(ClassPlayerCache[client][Class_Description], 256, ClassDataCache[classindex][Class_Description]);
			
			/* Model */
			strcopy(ClassPlayerCache[client][Class_ModelPath], PLATFORM_MAX_PATH, ClassDataCache[classindex][Class_ModelPath]);
			strcopy(ClassPlayerCache[client][Class_Arms_Path], PLATFORM_MAX_PATH, ClassDataCache[classindex][Class_Arms_Path]);
			ClassPlayerCache[client][Class_ModelSkinIndex] = ClassDataCache[classindex][Class_ModelSkinIndex];
			ClassPlayerCache[client][Class_AlphaInitial] = ClassDataCache[classindex][Class_AlphaInitial];
			ClassPlayerCache[client][Class_AlphaDamaged] = ClassDataCache[classindex][Class_AlphaDamaged];
			ClassPlayerCache[client][Class_AlphaDamage] = ClassDataCache[classindex][Class_AlphaDamage];
			
			/* Hud */
			strcopy(ClassPlayerCache[client][Class_OverlayPath], PLATFORM_MAX_PATH, ClassDataCache[classindex][Class_OverlayPath]);
			ClassPlayerCache[client][Class_Nvgs] = ClassDataCache[classindex][Class_Nvgs];
			ClassPlayerCache[client][Class_Fov] = ClassDataCache[classindex][Class_Fov];
			
			/* Effects */
			ClassPlayerCache[client][Class_HasNapalm] = ClassDataCache[classindex][Class_HasNapalm];
			ClassPlayerCache[client][Class_NapalmTime] = ClassDataCache[classindex][Class_NapalmTime];
			
			/* Player behavior */
			ClassPlayerCache[client][Class_ImmunityMode] = ClassDataCache[classindex][Class_ImmunityMode];
			ClassPlayerCache[client][Class_ImmunityAmount] = ClassDataCache[classindex][Class_ImmunityAmount];
			ClassPlayerCache[client][Class_ImmunityCooldown] = ClassDataCache[classindex][Class_ImmunityCooldown];
			ClassPlayerCache[client][Class_NoFallDamage] = ClassDataCache[classindex][Class_NoFallDamage];
			ClassPlayerCache[client][Class_Health] = ClassDataCache[classindex][Class_Health];
			ClassPlayerCache[client][Class_HealthRegenInterval] = ClassDataCache[classindex][Class_HealthRegenInterval];
			ClassPlayerCache[client][Class_HealthRegenAmount] = ClassDataCache[classindex][Class_HealthRegenAmount];
			ClassPlayerCache[client][Class_HealthInfectGain] = ClassDataCache[classindex][Class_HealthInfectGain];
			ClassPlayerCache[client][Class_KillBonus] = ClassDataCache[classindex][Class_KillBonus];
			ClassPlayerCache[client][Class_Speed] = ClassDataCache[classindex][Class_Speed];
			ClassPlayerCache[client][Class_KnockBack] = ClassDataCache[classindex][Class_KnockBack];
			ClassPlayerCache[client][Class_JumpHeight] = ClassDataCache[classindex][Class_JumpHeight];
			ClassPlayerCache[client][Class_JumpDistance] = ClassDataCache[classindex][Class_JumpDistance];
		}
		default:
		{
			// Invalid cache specified.
			return false;
		}
	}
	
	return true;
}

/**
 * Refresh the specified player's cache and re-apply attributes.
 *
 * @param client		The client index.
 * @return			  True if successful, false otherwise.
 */
bool ClassReloadPlayer(int client)
{
	int activeclass;
	
	// Get active class index.
	activeclass = ClassGetActiveIndex(client);
	
	// Validate index.
	if (activeclass < 0)
	{
		return false;
	}
	
	// Refresh cache and re-apply attributes.
	ClassOnClientDeath(client);		 // Dummy event to clean up and turn off stuff.
	ClassReloadPlayerCache(client, activeclass);
	ClassApplyAttributes(client);
	
	return true;
}

/**
 * Reset all class attribute multipliers to 1.0.
 */
void ClassResetMultiplierCache()
{
	// Loop through all teams.
	for (int teamid = 0; teamid < ZR_CLASS_TEAMCOUNT; teamid++)
	{
		ClassMultiplierCache[teamid][ClassM_NapalmTime] = 1.0;
		ClassMultiplierCache[teamid][ClassM_Health] = 1.0;
		ClassMultiplierCache[teamid][ClassM_HealthRegenInterval] = 1.0;
		ClassMultiplierCache[teamid][ClassM_HealthRegenAmount] = 1.0;
		ClassMultiplierCache[teamid][ClassM_HealthInfectGain] = 1.0;
		ClassMultiplierCache[teamid][ClassM_Speed] = 1.0;
		ClassMultiplierCache[teamid][ClassM_Knockback] = 1.0;
		ClassMultiplierCache[teamid][ClassM_JumpHeight] = 1.0;
		ClassMultiplierCache[teamid][ClassM_JumpDistance] = 1.0;
	}
}

/**
 * Resets the selected class indexes for next spawn on one or all clients.
 *
 * @param client	Optional. Specify client to reset. Default is all.
 */
void ClassResetNextIndexes(int client = -1)
{
	int teamid;
	
	if (client > 0)
	{
		for (teamid = 0; teamid < ZR_CLASS_TEAMCOUNT; teamid++)
		{
			ClassSelectedNext[client][teamid] = -1;
		}
	}
	else
	{
		for (client = 1; client <= MAXPLAYERS; client++)
		{
			for (teamid = 0; teamid < ZR_CLASS_TEAMCOUNT; teamid++)
			{
				ClassSelectedNext[client][teamid] = -1;
			}
		}
	}
}

/**
 * Restores next class indexes on a player, if available.
 * Note: Does not apply attributes. The classes are only marked as selected.
 *
 * @param client		The client index.
 * @param excludeTeam   Optional. Do not restore the specified team.
 */
void ClassRestoreNextIndexes(int client, int excludeTeam = -1)
{
	// Get next class indexes.
	int zombie = ClassSelectedNext[client][ZR_CLASS_TEAM_ZOMBIES];
	int human = ClassSelectedNext[client][ZR_CLASS_TEAM_HUMANS];
	int admin = ClassSelectedNext[client][ZR_CLASS_TEAM_ADMINS];
	
	// Check if the zombie team should be excluded.
	if (excludeTeam != ZR_CLASS_TEAM_ZOMBIES)
	{
		// Validate zombie class index.
		if (ClassValidateIndex(zombie))
		{
			// Mark next zombie class as selected.
			ClassSelected[client][ZR_CLASS_TEAM_ZOMBIES] = zombie;
		}
		
		// Reset index.
		ClassSelectedNext[client][ZR_CLASS_TEAM_ZOMBIES] = -1;
	}
	
	// Check if the human team should be excluded.
	if (excludeTeam != ZR_CLASS_TEAM_HUMANS)
	{
		// Validate human class index.
		if (ClassValidateIndex(human))
		{
			// Mark next zombie class as selected.
			ClassSelected[client][ZR_CLASS_TEAM_HUMANS] = human;
		}
		
		// Reset index.
		ClassSelectedNext[client][ZR_CLASS_TEAM_HUMANS] = -1;
	}
	
	// Check if the human team should be excluded.
	if (excludeTeam != ZR_CLASS_TEAM_ADMINS)
	{
		// Validate admin class index.
		if (ClassValidateIndex(admin))
		{
			// Mark next zombie class as selected.
			ClassSelected[client][ZR_CLASS_TEAM_ADMINS] = admin;
		}
		
		// Reset index.
		ClassSelectedNext[client][ZR_CLASS_TEAM_ADMINS] = -1;
	}
}

/**
 * Sets default class indexes for each team on all players, or a single player
 * if specified.
 *
 * @param client	Optional. The client index. If specified, cookies are used.
 */
void ClassClientSetDefaultIndexes(int client = -1)
{
	bool clientvalid = ZRIsClientValid(client);
	int filter[ClassFilter];
	bool saveclasses = GetConVarBool(g_hCvarsList[CVAR_CLASSES_SAVE]);
	
	int zombieindex;
	int humanindex;
	int adminindex;
	
	bool haszombie;
	bool hashuman;
	bool hasadmin;
	
	
	/*
	 *  SETUP CLASS FILTER
	 */
	
	// Do not require any class flags to be set.
	filter[ClassFilter_RequireFlags] = 0;
	
	// Set filter to hide mother zombie classes.
	filter[ClassFilter_DenyFlags] = ZR_CLASS_FLAG_MOTHER_ZOMBIE;
	
	// Set filter to also hide admin-only classes if not admin.
	filter[ClassFilter_DenyFlags] += !ZRIsClientAdmin(client) ? ZR_CLASS_FLAG_ADMIN_ONLY : 0;
	
	// Specify client so it can check group permissions.
	filter[ClassFilter_Client] = client;
	
	
	/*
	 *  GET CLASS INDEXES
	 */
	
	// Check if a client is specified.
	if (clientvalid)
	{
		// Get cookie indexes if enabled.
		if (saveclasses)
		{
			zombieindex = CookiesGetInt(client, g_hClassCookieClassSelected[ZR_CLASS_TEAM_ZOMBIES]);
			humanindex = CookiesGetInt(client, g_hClassCookieClassSelected[ZR_CLASS_TEAM_HUMANS]);
			adminindex = CookiesGetInt(client, g_hClassCookieClassSelected[ZR_CLASS_TEAM_ADMINS]);
		}
		else
		{
			// Do not use indexes in cookies. Set invalid values so it will
			// fall back to default class.
			zombieindex = 0;
			humanindex = 0;
			adminindex = 0;
		}
		
		// Note: When class indexes are set on cookies, they're incremented by
		//	   one so zero means no class set and will result in a invalid
		//	   class index when restored.
		
		// Check if class indexes are set and that the client pass the filter.
		// Also check that the saved class' team id match with the loaded class.
		// If not, fall back to default class indexes. Otherwise substract
		// index by one.
		if (zombieindex <= 0 ||
			!ClassTeamCompare(zombieindex - 1, ZR_CLASS_TEAM_ZOMBIES) ||
			!ClassFilterMatch(zombieindex - 1, filter))
		{
			zombieindex = ClassGetDefaultSpawnClass(ZR_CLASS_TEAM_ZOMBIES, filter);
		}
		else
		{
			zombieindex--;
			haszombie = true;
		}
		
		if (humanindex <= 0 ||
			!ClassTeamCompare(humanindex - 1, ZR_CLASS_TEAM_HUMANS) ||
			!ClassFilterMatch(humanindex - 1, filter))
		{
			humanindex = ClassGetDefaultSpawnClass(ZR_CLASS_TEAM_HUMANS, filter);
		}
		else
		{
			humanindex--;
			hashuman = true;
		}
		
		if (adminindex <= 0 ||
			!ClassTeamCompare(adminindex - 1, ZR_CLASS_TEAM_ADMINS) ||
			!ClassFilterMatch(adminindex - 1, filter))
		{
			adminindex = ClassGetDefaultSpawnClass(ZR_CLASS_TEAM_ADMINS, filter);
		}
		else
		{
			adminindex--;
			hasadmin = true;
		}
	}
	else
	{
		// Set filter to exclude classes that require groups.
		filter[ClassFilter_Client] = -1;
		
		// Get default class indexes.
		zombieindex = ClassGetDefaultSpawnClass(ZR_CLASS_TEAM_ZOMBIES, filter);
		humanindex = ClassGetDefaultSpawnClass(ZR_CLASS_TEAM_HUMANS, filter);
		adminindex = ClassGetDefaultSpawnClass(ZR_CLASS_TEAM_ADMINS, filter);
	}
	
	
	/*
	 *  VALIDATE INDEXES
	 */
	if (!ClassValidateIndex(zombieindex))
	{
		// Invalid class index. Fall back to default class in class config and
		// log a warning.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Set Default Indexes", "Warning: Failed to get the specified zombie class, falling back to default class in class config. Check spelling in \"zr_classes_default_zombie\".");
		
		// Use default class.
		zombieindex = ClassGetDefaultClass(ZR_CLASS_TEAM_ZOMBIES, filter);
	}
	
	if (!ClassValidateIndex(humanindex))
	{
		// Invalid class index. Fall back to default class in class config and
		// log a warning.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Playerclasses, "Set Default Indexes", "Warning: Failed to get the specified human class, falling back to default class in class config. Check spelling in \"zr_classes_default_human\".");
		
		// Use default class.
		humanindex = ClassGetDefaultClass(ZR_CLASS_TEAM_HUMANS, filter);
	}
	
	if (!ClassValidateIndex(adminindex))
	{
		// Invalid class index. Fall back to default class in class config if
		// possible. A invalid class index (-1) can also be stored if there are
		// no admin classes at all.
		adminindex = ClassGetDefaultClass(ZR_CLASS_TEAM_ADMINS, filter);
	}
	
	
	/*
	 *  MARK INDEXES AS SELECTED, UPDATE CACHE AND COOKIES
	 */
	
	// Check if a client is specified.
	if (clientvalid)
	{
		// Set selected class idexes.
		ClassSelected[client][ZR_CLASS_TEAM_ZOMBIES] = zombieindex;
		ClassSelected[client][ZR_CLASS_TEAM_HUMANS] = humanindex;
		ClassSelected[client][ZR_CLASS_TEAM_ADMINS] = adminindex;
		
		// Copy human class data to player cache.
		ClassReloadPlayerCache(client, humanindex);
		
		// Save indexes in cookies if enabled, and not already saved.
		if (saveclasses)
		{
			if (!haszombie)
			{
				CookiesSetInt(client, g_hClassCookieClassSelected[ZR_CLASS_TEAM_ZOMBIES], zombieindex + 1);
			}
			if (!hashuman)
			{
				CookiesSetInt(client, g_hClassCookieClassSelected[ZR_CLASS_TEAM_HUMANS], humanindex + 1);
			}
			if (!hasadmin)
			{
				CookiesSetInt(client, g_hClassCookieClassSelected[ZR_CLASS_TEAM_ADMINS], adminindex + 1);
			}
		}
	}
	else
	{
		// No client specified. Loop through all players.
		for (int clientindex = 1; clientindex <= MaxClients; clientindex++)
		{
			// Set selected class idexes.
			ClassSelected[clientindex][ZR_CLASS_TEAM_ZOMBIES] = zombieindex;
			ClassSelected[clientindex][ZR_CLASS_TEAM_HUMANS] = humanindex;
			ClassSelected[clientindex][ZR_CLASS_TEAM_ADMINS] = adminindex;
			
			// Copy human class data to player cache.
			ClassReloadPlayerCache(client, humanindex);
		}
	}
}

/**
 * Selects a class for a player.
 *
 * Human class attribute may be instantly applied if player is alive, human and
 * instant class change is enabled. Otherwise only the selected index will be
 * updated for next spawn.
 *
 * Class selection will be saved in client cookies if enabled.
 *
 * @param client			Client index.
 * @param classIndex		Class index.
 * @param applyIfPossible   Optional. Apply class attributes if conditions allow
 *						  it. Default is true.
 * @param saveIfEnabled	 Optional. Save class selection in client cookies if
 *						  enabled. Default is true.
 *
 * @return				  Class selection result. See enum ClassSelectResult.
 */
ClassSelectResult ClassSelectClientClass(int client, int classIndex, bool applyIfPossible = true, bool saveIfEnabled = true)
{
	bool iszombie = InfectIsClientInfected(client);
	int teamid = ClassGetTeamID(classIndex, ZR_CLASS_CACHE_MODIFIED);
	ClassSelectResult selectResult = ClassSelected_NoChange;
	
	// Allow instant class change if enabled and both class and player is human.
	if (applyIfPossible &&
		ClassAllowInstantChange[client] &&
		!iszombie && teamid == ZR_CLASS_TEAM_HUMANS)
	{
		// Update selected class index.
		ClassSelected[client][teamid] = classIndex;
		
		// Update cache and apply attributes.
		ClassReloadPlayerCache(client, classIndex);
		ClassApplyAttributes(client);
		
		selectResult = ClassSelected_Instant;
	}
	else
	{
		// Set next spawn index if the player is changing the class on
		// his active team.
		if (IsPlayerAlive(client) &&
			(iszombie && teamid == ZR_CLASS_TEAM_ZOMBIES) ||
			(!iszombie && teamid == ZR_CLASS_TEAM_HUMANS) ||
			(ClassPlayerInAdminMode[client] && teamid == ZR_CLASS_TEAM_ADMINS))
		{
			// Check if selecting the same class that the player already is.
			if (ClassSelected[client][teamid] == classIndex)
			{
				// Player is already the specified class. No need to change
				// class next spawn.
				ClassSelectedNext[client][teamid] = -1;
				selectResult = ClassSelected_NoChange;
			}
			else
			{
				// Set class to be used on next spawn.
				ClassSelectedNext[client][teamid] = classIndex;
				selectResult = ClassSelected_NextSpawn;
			}
		}
		else
		{
			// Directly change the selected class index.
			ClassSelected[client][teamid] = classIndex;
			selectResult = ClassSelected_NextSpawn;
		}
	}
	
	// Save selected class index in cookie if enabled.
	// Note: Saved indexes are increased by one.
	if (saveIfEnabled && GetConVarBool(g_hCvarsList[CVAR_CLASSES_SAVE]))
	{
		CookiesSetInt(client, g_hClassCookieClassSelected[teamid], classIndex + 1);
	}
	
	return selectResult;
}

/**
 * Dump class data into a string. String buffer length should be at about 2048
 * cells.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 *				  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is used,
 *				  index will be used as a client index.
 * @return		  Number of cells written.
 */
int ClassDumpData(int index, int cachetype, char[] buffer, int maxlen)
{
	int cellcount;
	char attribute[320];
	char format_buffer[256];
	
	if (maxlen == 0)
	{
		return 0;
	}
	
	Format(format_buffer, sizeof(format_buffer), "Class data at index %d:\n", index);
	cellcount += StrCat(buffer, maxlen, format_buffer);
	cellcount += StrCat(buffer, maxlen, "-------------------------------------------------------------------------------\n");
	
	Format(attribute, sizeof(attribute), "enabled:			   \"%d\"\n", ClassIsEnabled(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "team:				  \"%d\"\n", ClassGetTeamID(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "team_default:		  \"%d\"\n", ClassGetTeamDefault(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "flags:				 \"%d\"\n", ClassGetFlags(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ClassGetGroup(index, format_buffer, sizeof(format_buffer), cachetype);
	Format(attribute, sizeof(attribute), "group:				 \"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ClassGetSM_Flags(index, format_buffer, sizeof(format_buffer), cachetype);
	Format(attribute, sizeof(attribute), "sm_flags:               \"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ClassGetName(index, format_buffer, sizeof(format_buffer), cachetype);
	Format(attribute, sizeof(attribute), "name:				  \"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ClassGetDescription(index, format_buffer, sizeof(format_buffer), cachetype);
	Format(attribute, sizeof(attribute), "description:		   \"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ClassGetModelPath(index, format_buffer, sizeof(format_buffer), cachetype);
	Format(attribute, sizeof(attribute), "model_path:			\"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ClassGetArmsPath(index, format_buffer, sizeof(format_buffer), cachetype);
	Format(attribute, sizeof(attribute), "arms_path:		   \"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "model_skin_index:	  \"%d\"\n", ClassGetModelSkinIndex(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "alpha_initial:		 \"%d\"\n", ClassGetAlphaInitial(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "alpha_damaged:		 \"%d\"\n", ClassGetAlphaDamaged(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "alpha_damage:		  \"%d\"\n", ClassGetAlphaDamage(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ClassGetOverlayPath(index, format_buffer, sizeof(format_buffer), cachetype);
	Format(attribute, sizeof(attribute), "overlay_path:		  \"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "nvgs:				  \"%d\"\n", ClassGetNvgs(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "fov:				   \"%d\"\n", ClassGetFOV(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "has_napalm:			\"%d\"\n", ClassGetHasNapalm(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "napalm_time:		   \"%f\"\n", ClassGetNapalmTime(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	ImmunityModeToString(ClassGetImmunityMode(index, cachetype), format_buffer, sizeof(format_buffer));
	Format(attribute, sizeof(attribute), "immunity_mode:		 \"%s\"\n", format_buffer);
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "immunity_amount:	   \"%d\"\n", ClassGetImmunityAmount(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "immunity_cooldown:	 \"%d\"\n", ClassGetImmunityCooldown(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "no_fall_damage:		\"%d\"\n", ClassGetNoFallDamage(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "health:				\"%d\"\n", ClassGetHealth(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "health_regen_interval: \"%f\"\n", ClassGetHealthRegenInterval(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "health_regen_amount:   \"%d\"\n", ClassGetHealthRegenAmount(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "health_infect_gain:	\"%d\"\n", ClassGetHealthInfectGain(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "kill_bonus:			\"%d\"\n", ClassGetKillBonus(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "speed:				 \"%f\"\n", ClassGetSpeed(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "knockback:			 \"%f\"\n", ClassGetKnockback(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "jump_height:		   \"%f\"\n", ClassGetJumpHeight(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	Format(attribute, sizeof(attribute), "jump_distance:		 \"%f\"\n", ClassGetJumpDistance(index, cachetype));
	cellcount += StrCat(buffer, maxlen, attribute);
	
	return cellcount;
}

/**
 * Converts a multiplier attribute to a human readable string.
 *
 * @param client		The client index to translate correct language. 
 * @param attribute	 Attribute to convert.
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of buffer.
 * @return			  Number of cells written.
 */
int ClassMultiplierToString(int client, ClassMultipliers attribute, char[] buffer, int maxlen)
{
	char phrase[48];
	
	SetGlobalTransTarget(client);
	switch (attribute)
	{
		case ClassM_NapalmTime:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Napalm Time");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_Health:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Health");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_HealthRegenInterval:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Regen Interval");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_HealthRegenAmount:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Regen Amount");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_HealthInfectGain:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Infect Gain");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_Speed:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Speed");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_Knockback:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Knockback");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_JumpHeight:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Jump Height");
			return strcopy(buffer, maxlen, phrase);
		}
		case ClassM_JumpDistance:
		{
			Format(phrase, sizeof(phrase), "%t", "Classes Attrib Jump Distance");
			return strcopy(buffer, maxlen, phrase);
		}
	}
	
	return 0;
}
