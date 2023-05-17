/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  cvars.inc
 *  Type:		  Core
 *  Description:   Config creation and cvar control.
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
 * @section Locked cvar value defines.
 */
#define CVARS_AUTOTEAMBALANCE_LOCKED 0
#define CVARS_LIMITTEAMS_LOCKED 0
/**
 * @endsection
 */

/**
 * List of cvars used by the plugin.
 */
enum CvarsList
{
	Handle:CVAR_ENABLE,
	Handle:CVAR_LOG,
	Handle:CVAR_LOG_FLAGS,
	Handle:CVAR_LOG_MODULE_FILTER,
	Handle:CVAR_LOG_IGNORE_CONSOLE,
	Handle:CVAR_LOG_ERROR_OVERRIDE,
	Handle:CVAR_LOG_PRINT_ADMINS,
	Handle:CVAR_LOG_PRINT_CHAT,
	Handle:CVAR_CONFIG_PATH_MODELS,
	Handle:CVAR_CONFIG_PATH_DOWNLOADS,
	Handle:CVAR_CONFIG_PATH_CLASSES,
	Handle:CVAR_CONFIG_PATH_WEAPONS,
	Handle:CVAR_CONFIG_PATH_HITGROUPS,
	Handle:CVAR_CLASSES_ARMS,
	Handle:CVAR_PERMISSIONS_USE_GROUPS,
	Handle:CVAR_CLASSES_MENU_SPAWN,
	Handle:CVAR_CLASSES_MENU_JOIN,
	Handle:CVAR_CLASSES_RANDOM,
	Handle:CVAR_CLASSES_CHANGE_TIMELIMIT,
	Handle:CVAR_CLASSES_SAVE,
	Handle:CVAR_CLASSES_DEFAULT_ZOMBIE,
	Handle:CVAR_CLASSES_DEFAULT_M_ZOMB,
	Handle:CVAR_CLASSES_DEFAULT_HUMAN,
	Handle:CVAR_CLASSES_DEFAULT_ADMIN,
	Handle:CVAR_CLASSES_DEFAULT_ADMIN_MODE,
	Handle:CVAR_CLASSES_MENU_AUTOCLOSE,
	Handle:CVAR_CLASSES_OVERLAY_TOGGLE,
	Handle:CVAR_CLASSES_OVERLAY_TOGGLECMDS,
	Handle:CVAR_CLASSES_OVERLAY_DEFAULT,
	Handle:CVAR_CLASSES_ZOMBIE_SELECT,
	Handle:CVAR_CLASSES_HUMAN_SELECT,
	Handle:CVAR_CLASSES_ADMIN_SELECT,
	Handle:CVAR_CLASSES_SPEED_METHOD,
	Handle:CVAR_CLASSES_CSGO_KNOCKBACK_AIRMULTIPLIER,
	Handle:CVAR_WEAPONS,
	Handle:CVAR_WEAPONS_RESTRICT,
	Handle:CVAR_WEAPONS_RESTRICT_ENDEQUIP,
	Handle:CVAR_WEAPONS_ZMARKET,
	Handle:CVAR_WEAPONS_ZMARKET_BUYZONE,
	Handle:CVAR_WEAPONS_ZMARKET_REBUY,
	Handle:CVAR_WEAPONS_ZMARKET_REBUY_AUTO,
	Handle:CVAR_HITGROUPS,
	Handle:CVAR_DAMAGE_HITGROUPS,
	Handle:CVAR_DAMAGE_BLOCK_FF,
	Handle:CVAR_DAMAGE_BLOCK_BLAST,
	Handle:CVAR_DAMAGE_BLOCK_FIRE,
	Handle:CVAR_DAMAGE_SUICIDE_ZOMBIE,
	Handle:CVAR_DAMAGE_SUICIDE_MZOMBIE,
	Handle:CVAR_DAMAGE_SUICIDE_HUMAN,
	Handle:CVAR_DAMAGE_SUICIDE_CMDS,
	Handle:CVAR_SUICIDE_AFTER_INFECT,
	Handle:CVAR_SAYHOOKS_QUIET,
	Handle:CVAR_SAYHOOKS_QUIET_FILTER,
	Handle:CVAR_SAYHOOKS_QUIET_FLAGS,
	Handle:CVAR_OVERLAYS_UPDATE_TIME,
	Handle:CVAR_OVERLAYS_MIN_DXLEVEL,
	Handle:CVAR_ROUNDEND_OVERLAY,
	Handle:CVAR_ROUNDEND_OVERLAY_ZOMBIE,
	Handle:CVAR_ROUNDEND_OVERLAY_HUMAN,
	Handle:CVAR_ROUNDEND_BALANCE_TEAMS,
	Handle:CVAR_INFECT_SPAWNTIME_MIN,
	Handle:CVAR_INFECT_SPAWNTIME_MAX,
	Handle:CVAR_INFECT_CONSECUTIVE_BLOCK,
	Handle:CVAR_INFECT_WEAPONS_DROP,
	Handle:CVAR_INFECT_MZOMBIE_MODE,
	Handle:CVAR_INFECT_MZOMBIE_RATIO,
	Handle:CVAR_INFECT_MZOMBIE_MIN,
	Handle:CVAR_INFECT_MZOMBIE_MAX,
	Handle:CVAR_INFECT_MZOMBIE_COUNTDOWN,
	Handle:CVAR_INFECT_MZOMBIE_RESPAWN,
	Handle:CVAR_INFECT_EXPLOSION,
	Handle:CVAR_INFECT_FIREBALL,
	Handle:CVAR_INFECT_SMOKE,
	Handle:CVAR_INFECT_SPARKS,
	Handle:CVAR_INFECT_ESPLASH,
	Handle:CVAR_INFECT_SHAKE,
	Handle:CVAR_INFECT_SHAKE_AMP,
	Handle:CVAR_INFECT_SHAKE_FREQUENCY,
	Handle:CVAR_INFECT_SHAKE_DURATION,
	Handle:CVAR_ACCOUNT_CASHFILL,
	Handle:CVAR_ACCOUNT_CASHFILL_VALUE,
	Handle:CVAR_ACCOUNT_CASHDMG,
	Handle:CVAR_VEFFECTS_LIGHTSTYLE,
	Handle:CVAR_VEFFECTS_LIGHTSTYLE_VALUE,
	Handle:CVAR_VEFFECTS_SKY,
	Handle:CVAR_VEFFECTS_SKY_PATH,
	Handle:CVAR_VEFFECTS_SUN_DISABLE,
	Handle:CVAR_VEFFECTS_FOG,
	Handle:CVAR_VEFFECTS_FOG_OVERRIDE,
	Handle:CVAR_VEFFECTS_FOG_PCOLOR,
	Handle:CVAR_VEFFECTS_FOG_SCOLOR,
	Handle:CVAR_VEFFECTS_FOG_DENSITY,
	Handle:CVAR_VEFFECTS_FOG_STARTDIST,
	Handle:CVAR_VEFFECTS_FOG_ENDDIST,
	Handle:CVAR_VEFFECTS_FOG_FARZ,
	Handle:CVAR_VEFFECTS_RAGDOLL_REMOVE,
	Handle:CVAR_VEFFECTS_RAGDOLL_DISSOLVE,
	Handle:CVAR_VEFFECTS_RAGDOLL_DELAY,
	Handle:CVAR_ANTISTICK,
	Handle:CVAR_ANTISTICK_DEFAULT_WIDTH,
	Handle:CVAR_ANTISTICK_FILE_PATH,
	Handle:CVAR_SPAWNPROTECT,
	Handle:CVAR_SPAWNPROTECT_TIME,
	Handle:CVAR_SPAWNPROTECT_SPEED,
	Handle:CVAR_SPAWNPROTECT_ALPHA,
	Handle:CVAR_RESPAWN,
	Handle:CVAR_RESPAWN_DELAY,
	Handle:CVAR_RESPAWN_TEAM_ZOMBIE,
	Handle:CVAR_RESPAWN_TEAM_ZOMBIE_WORLD,
	Handle:CVAR_NAPALM_IGNITE,
	Handle:CVAR_NAPALM_TIME_RESET,
	Handle:CVAR_NAPALM_DOUSE,
	Handle:CVAR_JUMPBOOST_BHOP_PROTECT,
	Handle:CVAR_JUMPBOOST_BHOP_MAX,
	Handle:CVAR_VOL,
	Handle:CVAR_VOL_UPDATE_INTERVAL,
	Handle:CVAR_VOL_TRIGGER_INTERVAL,
	Handle:CVAR_ZSPAWN,
	Handle:CVAR_ZSPAWN_TEAM_OVERRIDE,
	Handle:CVAR_ZSPAWN_TEAM_ZOMBIE,
	Handle:CVAR_ZSPAWN_BLOCK_REJOIN,
	Handle:CVAR_ZSPAWN_TIMELIMIT,
	Handle:CVAR_ZSPAWN_TIMELIMIT_TIME,
	Handle:CVAR_ZSPAWN_TIMELIMIT_ZOMBIE,
	Handle:CVAR_ZTELE_ZOMBIE,
	Handle:CVAR_ZTELE_HUMAN_BEFORE,
	Handle:CVAR_ZTELE_HUMAN_AFTER,
	Handle:CVAR_ZTELE_DELAY_ZOMBIE,
	Handle:CVAR_ZTELE_DELAY_HUMAN,
	Handle:CVAR_ZTELE_MAX_ZOMBIE,
	Handle:CVAR_ZTELE_MAX_HUMAN,
	Handle:CVAR_ZTELE_AUTOCANCEL,
	Handle:CVAR_ZTELE_AUTOCANCEL_DISTANCE,
	Handle:CVAR_ZHP,
	Handle:CVAR_ZHP_DEFAULT,
	Handle:CVAR_ZMENU_ENABLED
}

/**
 * Array to store cvar data in.
 */
g_hCvarsList[CvarsList];

/**
 * @section Global cvar handles.
 */
Handle g_hAutoTeamBalance = INVALID_HANDLE;
Handle g_hLimitTeams = INVALID_HANDLE;
Handle g_hRestartGame = INVALID_HANDLE;
/**
 * @endsection
 */

/**
 * Cvars module init function.
 */
void CvarsInit()
{
	// Retrieve handles of CS:S cvars.
	g_hAutoTeamBalance = FindConVar("mp_autoteambalance");
	g_hLimitTeams = FindConVar("mp_limitteams");
	g_hRestartGame = FindConVar("mp_restartgame");
	
	// Create zombiereloaded cvars.
	CvarsCreate();
	
	// Hook cvars.
	CvarsHook();
	
	// Create public cvar for tracking.
	char description[64];
	Format(description, sizeof(description), "%s Current version of this plugin", TRANSLATION_PHRASE_PREFIX);
	CreateConVar("gs_zombiereloaded_version", VERSION, description, FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	#if defined ADD_VERSION_INFO
		CreateConVar("zombiereloaded_revision", ZR_VER_REVISION, "Revision number for this plugin in source code repository.", FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	#endif
	
	// Forward event to modules.
	VEffectsOnCvarInit();
}

/**
 * Create all cvars for plugin.
 */
void CvarsCreate()
{
	// ===========================
	// Log (core)
	// ===========================
	g_hCvarsList[CVAR_LOG]					   =	CreateConVar("zr_log",					"1",	"Enable logging of events in the plugin. Fatal errors are always logged.");
	g_hCvarsList[CVAR_LOG_FLAGS]				 =	CreateConVar("zr_log_flags",			  "2",	"A bit field that specify what event types to log. See logging section (3.3) in manual for details.");
	g_hCvarsList[CVAR_LOG_MODULE_FILTER]		 =	CreateConVar("zr_log_module_filter",	  "0",	"Enable module filtering. Only events from listed modules will be logged.");
	g_hCvarsList[CVAR_LOG_IGNORE_CONSOLE]		=	CreateConVar("zr_log_ignore_console",	 "1",	"Don't log events triggered by console commands that are executed by the console itself, like commands in configs. Enable this command to avoid spamming logs with events like weapon restrictions.");
	g_hCvarsList[CVAR_LOG_ERROR_OVERRIDE]		=	CreateConVar("zr_log_error_override",	 "1",	"Always log error messages no matter what logging flags or modules filters that are enabled.");
	g_hCvarsList[CVAR_LOG_PRINT_ADMINS]		  =	CreateConVar("zr_log_print_admins",	   "0",	"Print log events to admin chat in addition to the log file.");
	g_hCvarsList[CVAR_LOG_PRINT_CHAT]			=	CreateConVar("zr_log_print_chat",		 "0",	"Print log events to public chat in addition to the log file.");
	
	
	// ===========================
	// Config (core)
	// ===========================
	g_hCvarsList[CVAR_CONFIG_PATH_MODELS]		=	CreateConVar("zr_config_path_models",		 "configs/zr/models.txt",				"Path, relative to root sourcemod directory, to models config file.");
	g_hCvarsList[CVAR_CONFIG_PATH_DOWNLOADS]	 =	CreateConVar("zr_config_path_downloads",	  "configs/zr/downloads.txt",			 "Path, relative to root sourcemod directory, to downloads file.");
	g_hCvarsList[CVAR_CONFIG_PATH_CLASSES]	   =	CreateConVar("zr_config_path_playerclasses",  "configs/zr/playerclasses.txt",		 "Path, relative to root sourcemod directory, to playerclasses config file.");
	g_hCvarsList[CVAR_CONFIG_PATH_WEAPONS]	   =	CreateConVar("zr_config_path_weapons",		"configs/zr/weapons.txt",			   "Path, relative to root sourcemod directory, to weapons config file.");
	g_hCvarsList[CVAR_CONFIG_PATH_HITGROUPS]	 =	CreateConVar("zr_config_path_hitgroups",	  "configs/zr/hitgroups.txt",			 "Path, relative to root sourcemod directory, to hitgroups config file.");
	g_hCvarsList[CVAR_CLASSES_ARMS]				=	CreateConVar("zr_classes_arms",				"0",									"Enable Class Arms Apply.");
	
	
	// ===========================
	// Permission Settings
	// ===========================
	g_hCvarsList[CVAR_PERMISSIONS_USE_GROUPS]	=	CreateConVar("zr_permissions_use_groups",	 "0",	"Use group authentication instead of flags to access admin features. Generic admin flag is still required on some features.");
	
	
	// ===========================
	// Classes (core)
	// ===========================
	
	// General
	g_hCvarsList[CVAR_CLASSES_MENU_SPAWN]			   =	CreateConVar("zr_classes_menu_spawn",			  "0",			"Re-display class selection menu every spawn.");
	g_hCvarsList[CVAR_CLASSES_MENU_JOIN]				=	CreateConVar("zr_classes_menu_join",			   "0",			"Display class selection menu when a player spawn for the first time.");
	g_hCvarsList[CVAR_CLASSES_RANDOM]				   =	CreateConVar("zr_classes_random",				  "0",			"Player is assigned a random class every spawn. [Override: zr_classes_default_*]");
	g_hCvarsList[CVAR_CLASSES_CHANGE_TIMELIMIT]		 =	CreateConVar("zr_classes_change_timelimit",		"20",		   "Time limit to change human class with instant change after spawning. Time is in seconds. Use 0 or negative to disable.");
	g_hCvarsList[CVAR_CLASSES_SAVE]					 =	CreateConVar("zr_classes_save",					"1",			"Save players' class selections in server cookies and restore when connecting. [Override: zr_classes_default_*]");
	g_hCvarsList[CVAR_CLASSES_DEFAULT_ZOMBIE]		   =	CreateConVar("zr_classes_default_zombie",		  "random",	   "Zombie class assigned to players on connect. [\"random\" = Random zombie class | \"\" = Class config default]");
	g_hCvarsList[CVAR_CLASSES_DEFAULT_M_ZOMB]		   =	CreateConVar("zr_classes_default_mother_zombie",   "motherzombies","Zombie class assigned to mother zombies. [\"motherzombies\" = Random mother zombie class | \"random\" = Random regular zombie class | \"disabled\" = Don't change class on mother zombies]");
	g_hCvarsList[CVAR_CLASSES_DEFAULT_HUMAN]			=	CreateConVar("zr_classes_default_human",		   "random",	   "Human class assigned to players on connect. [\"random\" = Random human class | \"\" = Class config default]");
	g_hCvarsList[CVAR_CLASSES_DEFAULT_ADMIN]			=	CreateConVar("zr_classes_default_admin",		   "default",	  "(Not implemented!) Admin-only class assigned to admins on connect, if any. [\"default\" = Default human class | \"random\" = Random admin-only class]");
	g_hCvarsList[CVAR_CLASSES_DEFAULT_ADMIN_MODE]	   =	CreateConVar("zr_classes_default_admin_mode",	  "random",	   "(Incomplete) Admin-mode class assigned to admins on connect. Do not confuse this with admin-only classes. [\"random\" = Random admin class | \"\" = Class config default]");
	g_hCvarsList[CVAR_CLASSES_ZOMBIE_SELECT]			=	CreateConVar("zr_classes_zombie_select",		   "1",			"Allow players to select zombie classes.");
	g_hCvarsList[CVAR_CLASSES_HUMAN_SELECT]			 =	CreateConVar("zr_classes_human_select",			"1",			"Allow players to select human classes.");
	g_hCvarsList[CVAR_CLASSES_ADMIN_SELECT]			 =	CreateConVar("zr_classes_admin_select",			"1",			"Allow admins to select admin mode classes. (Not to be confused by admin-only classes!)");
	g_hCvarsList[CVAR_CLASSES_SPEED_METHOD]			 =	CreateConVar("zr_classes_speed_method",			"prop",		 "Speed method to use when applying player speed. Do not touch this if you don't know what you're doing! [\"lmv\" = Lagged movement value | \"prop\" = Player speed property");
	g_hCvarsList[CVAR_CLASSES_CSGO_KNOCKBACK_AIRMULTIPLIER]	 =	CreateConVar("zr_classes_csgo_knockback_airmultiplier",	"0.5",			"CS:GO only: Multiplier for knockback on the air");
	// Menu
	g_hCvarsList[CVAR_CLASSES_MENU_AUTOCLOSE]		   =	CreateConVar("zr_classes_menu_autoclose",	  "1",			"Automatically close class selection menu after selecting a class.");
	
	// Overlays
	g_hCvarsList[CVAR_CLASSES_OVERLAY_TOGGLE]		   =	CreateConVar("zr_classes_overlay_toggle",	  "1",			"Allow players to toggle class overlay.");
	g_hCvarsList[CVAR_CLASSES_OVERLAY_TOGGLECMDS]	   =	CreateConVar("zr_classes_overlay_togglecmds",  "nightvision",  "List of commands to hook that players can use to toggle class overlay. [Dependency: zr_classes_overlay_toggle | Delimiter: \",\"]");
	g_hCvarsList[CVAR_CLASSES_OVERLAY_DEFAULT]		  =	CreateConVar("zr_classes_overlay_default",	 "1",			"Default class overlay toggle state set on connecting player.");
	
	
	// ===========================
	// Weapons (core)
	// ===========================
	
	// General
	g_hCvarsList[CVAR_WEAPONS]						  =	CreateConVar("zr_weapons",					 "1",	"Enable weapons module, disabling this will disable any weapons-related features. (weapon restrictions, weapon knockback multipliers, etc)");
	
	// Restrict
	g_hCvarsList[CVAR_WEAPONS_RESTRICT]				 =	CreateConVar("zr_weapons_restrict",			"1",	"Enable weapon restriction module, disabling this will disable weapon restriction commands.");
	g_hCvarsList[CVAR_WEAPONS_RESTRICT_ENDEQUIP]		=	CreateConVar("zr_weapons_restrict_endequip",   "1",	"Restricts zombies from picking up weapons after the round has ended but before the next round has begun.");
	
	// ZMarket
	g_hCvarsList[CVAR_WEAPONS_ZMARKET]				  =	CreateConVar("zr_weapons_zmarket",			 "1",			"Allow player to buy from a list of weapons in the weapons config.");
	g_hCvarsList[CVAR_WEAPONS_ZMARKET_BUYZONE]		  =	CreateConVar("zr_weapons_zmarket_buyzone",	 "1",			"Requires player to be inside a buyzone to use ZMarket. [Dependency: zr_weapons_zmarket]");
	g_hCvarsList[CVAR_WEAPONS_ZMARKET_REBUY]			=	CreateConVar("zr_weapons_zmarket_rebuy",	   "1",			"Allow players to rebuy their previous weapons. [Dependency: zr_weapons_zmarket]");
	g_hCvarsList[CVAR_WEAPONS_ZMARKET_REBUY_AUTO]	   =	CreateConVar("zr_weapons_zmarket_rebuy_auto",  "1",			"Allow players to automatically rebuy their previous weapons. [Dependency: zr_weapons_zmarket&zr_weapons_zmarket_rebuy]");
	
	
	// ===========================
	// Hitgroups (core)
	// ===========================
	g_hCvarsList[CVAR_HITGROUPS]						=	CreateConVar("zr_hitgroups",   "1",	"Enable hitgroups module, disabling this will disable hitgroup-related features. (hitgroup knockback multipliers, hitgroup damage control)");
	
	
	// ===========================
	// Infect (core)
	// ===========================
	
	// General
	g_hCvarsList[CVAR_INFECT_MZOMBIE_MODE]			  =	CreateConVar("zr_infect_mzombie_mode",		 "dynamic",						  "Mother zombie infection mode. ['dynamic' = every n-th zombie (ratio) | 'absolute' = n zombies (ratio) | 'range' = min/max]");
	g_hCvarsList[CVAR_INFECT_MZOMBIE_RATIO]			 =	CreateConVar("zr_infect_mzombie_ratio",		"7",								"Dynamic mode: Infection ratio. Every n-th player is infected. | Absolute mode: Number of zombies to infect (positive ratio), or number of humans to keep (negative ratio).");
	g_hCvarsList[CVAR_INFECT_MZOMBIE_MIN]			   =	CreateConVar("zr_infect_mzombie_min",		  "1",								"Minimum number of mother zombies. Range mode only, cannot be zero.");
	g_hCvarsList[CVAR_INFECT_MZOMBIE_MAX]			   =	CreateConVar("zr_infect_mzombie_max",		  "3",								"Maximum number of mother zombies. Range mode only, cannot be zero.");
	g_hCvarsList[CVAR_INFECT_MZOMBIE_COUNTDOWN]		 =	CreateConVar("zr_infect_mzombie_countdown",	"0",								"Counts down to the first infection of the round.  Countdown is printed in the middle of the client's screen.");
	g_hCvarsList[CVAR_INFECT_MZOMBIE_RESPAWN]		   =	CreateConVar("zr_infect_mzombie_respawn",	  "0",								"Teleport mother zombies back to spawn on infect.");
	g_hCvarsList[CVAR_INFECT_SPAWNTIME_MIN]			 =	CreateConVar("zr_infect_spawntime_min",		"30.0",							 "Minimum time from the start of the round until picking the mother zombie(s).");
	g_hCvarsList[CVAR_INFECT_SPAWNTIME_MAX]			 =	CreateConVar("zr_infect_spawntime_max",		"50.0",							 "Maximum time from the start of the round until picking the mother zombie(s).");
	g_hCvarsList[CVAR_INFECT_CONSECUTIVE_BLOCK]		 =	CreateConVar("zr_infect_consecutive_block",	"1",								"Prevent a player from being chosen as mother zombie two rounds in a row.");
	g_hCvarsList[CVAR_INFECT_WEAPONS_DROP]			  =	CreateConVar("zr_infect_weapons_drop",		 "1",								"Force player to drop all weapons on infect, disabling this will strip weapons instead.");
	
	// Effects
	g_hCvarsList[CVAR_INFECT_EXPLOSION]				 =	CreateConVar("zr_infect_explosion",			"1",								"Disabling this will disable the fireball, smoke cloud, and sparks in a more efficient way.");
	g_hCvarsList[CVAR_INFECT_FIREBALL]				  =	CreateConVar("zr_infect_fireball",			 "1",								"Spawn a fireball effect around player on infection. [Dependency: zr_infect_explosion]");
	g_hCvarsList[CVAR_INFECT_SMOKE]					 =	CreateConVar("zr_infect_smoke",				"1",								"Spawn a smoke cloud effect around player on infection. [Dependency: zr_infect_explosion]");
	g_hCvarsList[CVAR_INFECT_SPARKS]					=	CreateConVar("zr_infect_sparks",			   "1",								"Emit sparks from player on infection. [Dependency: zr_infect_explosion]");
	g_hCvarsList[CVAR_INFECT_ESPLASH]				   =	CreateConVar("zr_infect_esplash",			  "1",								"Emit an energy splash from player on infection.");
	g_hCvarsList[CVAR_INFECT_SHAKE]					 =	CreateConVar("zr_infect_shake",				"1",								"Shake player's view on infect.");
	g_hCvarsList[CVAR_INFECT_SHAKE_AMP]				 =	CreateConVar("zr_infect_shake_amp",			"15.0",							 "Amplitude of shaking effect. [Dependency: zr_infect_shake]");
	g_hCvarsList[CVAR_INFECT_SHAKE_FREQUENCY]		   =	CreateConVar("zr_infect_shake_frequency",	  "1.0",							  "Frequency of shaking effect. [Dependency: zr_infect_shake]");
	g_hCvarsList[CVAR_INFECT_SHAKE_DURATION]			=	CreateConVar("zr_infect_shake_duration",	   "5.0",							  "Duration of shaking effect. [Dependency: zr_infect_shake]"); 
	
	
	// ===========================
	// Damage (core)
	// ===========================
	
	// Hitgroup Damage
	g_hCvarsList[CVAR_DAMAGE_HITGROUPS]				 =	CreateConVar("zr_damage_hitgroups",		"1",							"Read hitgroup damage control from hitgroup config file, disabling this allows all zombie hitgroups to be shot.");
	
	// Block Damage Types
	g_hCvarsList[CVAR_DAMAGE_BLOCK_FF]				  =	CreateConVar("zr_damage_block_ff",		 "1",							"Block friendly fire.");
	g_hCvarsList[CVAR_DAMAGE_BLOCK_BLAST]			   =	CreateConVar("zr_damage_block_blast",	  "1",							"Block blast damage inflicted on self or teammates.");
	g_hCvarsList[CVAR_DAMAGE_BLOCK_FIRE]				=	CreateConVar("zr_damage_block_fire",		 "1",							"Block fire damage inflicted on self or teammates.");

	// Suicide Intercept
	g_hCvarsList[CVAR_DAMAGE_SUICIDE_ZOMBIE]			=	CreateConVar("zr_damage_suicide_zombie",   "0",									"Intercept suicide commands attempted by zombies.");
	g_hCvarsList[CVAR_DAMAGE_SUICIDE_MZOMBIE]		   =	CreateConVar("zr_damage_suicide_mzombie",  "1",									"Intercept suicide commands attempted by mother zombies.");
	g_hCvarsList[CVAR_DAMAGE_SUICIDE_HUMAN]			 =	CreateConVar("zr_damage_suicide_human",	"0",									"Intercept suicide commands attempted by humans.");
	g_hCvarsList[CVAR_DAMAGE_SUICIDE_CMDS]			  =	CreateConVar("zr_damage_suicide_cmds",	 "kill, spectate, jointeam, joinclass, explode",  "List of client commands to intercept as suicide attempts. [Delimiter: \", \"]");
	g_hCvarsList[CVAR_SUICIDE_AFTER_INFECT]			 =	CreateConVar("zr_damage_suicide_after_infect",	"1",							 "Intercept suicide commands only after the first zombie has spawned.");
	
	
	// ===========================
	// Overlays (core)
	// ===========================
	g_hCvarsList[CVAR_OVERLAYS_UPDATE_TIME]			 =	CreateConVar("zr_overlays_update_time",	"1.0",	  "How often to update overlays on players. [0.0 = Disabled]");
	g_hCvarsList[CVAR_OVERLAYS_MIN_DXLEVEL]			 =	CreateConVar("zr_overlays_min_dxlevel",	"80",	   "Minimum DirectX level allowed for overlays (mat_dxlevel).");
	
	
	// ===========================
	// Round End (core)
	// ===========================
	g_hCvarsList[CVAR_ROUNDEND_OVERLAY]				 =	CreateConVar("zr_roundend_overlay",			"1",							"Show specified overlay to players depending on winner when the round ends.");
	g_hCvarsList[CVAR_ROUNDEND_OVERLAY_HUMAN]		   =	CreateConVar("zr_roundend_overlays_human",	 "overlays/zr/humans_win",	   "Overlay, relative to \"materials\" folder, to display when humans win the round. [Dependency: zr_roundend_overlay]");
	g_hCvarsList[CVAR_ROUNDEND_OVERLAY_ZOMBIE]		  =	CreateConVar("zr_roundend_overlays_zombie",	"overlays/zr/zombies_win",	  "Overlay, relative to \"materials\" folder, to display when zombies win the round. [Dependency: zr_roundend_overlay]");
	g_hCvarsList[CVAR_ROUNDEND_BALANCE_TEAMS]		   =	CreateConVar("zr_roundend_balance_teams",	  "1",							"Balances the team every time the round ends. Disable this if you use something else to balance teams.");
	
	
	// ===========================
	// Account (module)
	// ===========================
	g_hCvarsList[CVAR_ACCOUNT_CASHFILL]				 =	CreateConVar("zr_account_cashfill",			"1",		"Reset player's cash each spawn.");
	g_hCvarsList[CVAR_ACCOUNT_CASHFILL_VALUE]		   =	CreateConVar("zr_account_cashfill_value",	  "12000",	"Amount of cash to set player's account to. [Dependency: zr_account_cashfill]");
	g_hCvarsList[CVAR_ACCOUNT_CASHDMG]				  =	CreateConVar("zr_account_cashdmg",			 "0",		"Attacker receives amount of cash equivalent to the damage that was inflicted.");
	
	
	// ===========================
	// Visual Effects (module)
	// ===========================
	
	// Lightstyle
	g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE]			  =	CreateConVar("zr_veffects_lightstyle",		 "0",					"Change lightstyle (brightness) of the map.");
	g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE_VALUE]		=	CreateConVar("zr_veffects_lightstyle_value",   "b",					"Lightstyle value. ['a' = Darkest | 'z' = Brightest | Dependency: zr_veffects_lightstyle]");
	
	// Sky
	g_hCvarsList[CVAR_VEFFECTS_SKY]					 =	CreateConVar("zr_veffects_sky",				"0",					"Change map skybox.");
	g_hCvarsList[CVAR_VEFFECTS_SKY_PATH]				=	CreateConVar("zr_veffects_sky_path",		   "sky_borealis01up.vmt", "Skybox file, relative to \"materials/skybox\" folder, to change map skybox to.  This file is automatically downloaded to clients. [Dependency: zr_veffects_sky]");
	
	// Sun
	g_hCvarsList[CVAR_VEFFECTS_SUN_DISABLE]			 =	CreateConVar("zr_veffects_sun_disable",		"0",					"Disable sun rendering on map.");
	
	// Fog
	g_hCvarsList[CVAR_VEFFECTS_FOG]					 =	CreateConVar("zr_veffects_fog",				"0",					"(UNSUPPORTED) Enable fog rendering on the map.");
	g_hCvarsList[CVAR_VEFFECTS_FOG_OVERRIDE]			=	CreateConVar("zr_veffects_fog_override",	   "0",					"(UNSUPPORTED) If fog exists already on the map, then replace with new modified fog. [Dependency: zr_veffects_fog]");
	g_hCvarsList[CVAR_VEFFECTS_FOG_PCOLOR]			  =	CreateConVar("zr_veffects_fog_pcolor",		 "255 255 255",		  "(UNSUPPORTED) Primary color of the fog. [Dependency: zr_veffects_fog]");
	g_hCvarsList[CVAR_VEFFECTS_FOG_SCOLOR]			  =	CreateConVar("zr_veffects_fog_scolor",		 "255 255 255",		  "(UNSUPPORTED) Secondary color of the fog. [Dependency: zr_veffects_fog]");
	g_hCvarsList[CVAR_VEFFECTS_FOG_DENSITY]			 =	CreateConVar("zr_veffects_fog_density",		"0.8",				  "(UNSUPPORTED) Density (thickness) of the fog. [Dependency: zr_veffects_fog]");
	g_hCvarsList[CVAR_VEFFECTS_FOG_STARTDIST]		   =	CreateConVar("zr_veffects_fog_startdist",	  "0",					"(UNSUPPORTED) Distance from player to start rendering foremost fog. [Dependency: zr_veffects_fog]");
	g_hCvarsList[CVAR_VEFFECTS_FOG_ENDDIST]			 =	CreateConVar("zr_veffects_fog_enddist",		"400",				  "(UNSUPPORTED) Distance from player to stop rendering fog. [Dependency: zr_veffects_fog]");
	g_hCvarsList[CVAR_VEFFECTS_FOG_FARZ]				=	CreateConVar("zr_veffects_fog_farz",		   "2000",				 "(UNSUPPORTED) Vertical clipping plane.");
	
	
	// Ragdoll
	g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_REMOVE]		  =	CreateConVar("zr_veffects_ragdoll_remove",	 "1",					"Remove players' ragdolls from the game after a delay.");
	g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_DISSOLVE]		=	CreateConVar("zr_veffects_ragdoll_dissolve",   "-1",				   "The ragdoll removal effect. ['-2' = Effectless removal | '-1' = Random effect | '0' = Energy dissolve | '1' = Heavy electrical dissolve | '2' = Light electrical dissolve | '3' = Core dissolve | Dependency: zr_veffects_ragdoll_remove]");
	g_hCvarsList[CVAR_VEFFECTS_RAGDOLL_DELAY]		   =	CreateConVar("zr_veffects_ragdoll_delay",	  "0.5",				  "Time to wait before removing the ragdoll. [Dependency: zr_veffects_ragdoll_remove]");
	
	// ===========================
	// Anti-Stick (module)
	// ===========================
	g_hCvarsList[CVAR_ANTISTICK]						=	CreateConVar("zr_antistick",			   "1",					"Automatically unstick players when stuck within each others' collision hull.");
	
	// ===========================
	// Spawn Protect (module)
	// ===========================
	g_hCvarsList[CVAR_SPAWNPROTECT]					 =	CreateConVar("zr_spawnprotect",		"1",			"Player will be protected from infection when spawning into the game late.");
	g_hCvarsList[CVAR_SPAWNPROTECT_TIME]				=	CreateConVar("zr_spawnprotect_time",   "10",		   "Amount of time to protect player. [Dependency: zr_spawnprotect]");
	g_hCvarsList[CVAR_SPAWNPROTECT_SPEED]			   =	CreateConVar("zr_spawnprotect_speed",  "250.0",		"Speed of the player during protection. See the manual for more information. [Dependency: zr_spawnprotect]");
	g_hCvarsList[CVAR_SPAWNPROTECT_ALPHA]			   =	CreateConVar("zr_spawnprotect_alpha",  "0",			"Alpha of the player during protection. ['255' = Fully visible | '0' = Completely invisible | Dependency: zr_spawnprotect]");
	
	
	// ===========================
	// Respawn (module)
	// ===========================
	g_hCvarsList[CVAR_RESPAWN]						  =	CreateConVar("zr_respawn",					 "0",	"Respawn players after death. [Recommended: (Enable) zr_zspawn*]");
	g_hCvarsList[CVAR_RESPAWN_DELAY]					=	CreateConVar("zr_respawn_delay",			   "1",	"Time after death to delay player respawn. [Dependency: zr_respawn]");
	g_hCvarsList[CVAR_RESPAWN_TEAM_ZOMBIE]			  =	CreateConVar("zr_respawn_team_zombie",		 "1",	"Respawn player as a zombie. [Dependency: zr_respawn]");
	g_hCvarsList[CVAR_RESPAWN_TEAM_ZOMBIE_WORLD]		=	CreateConVar("zr_respawn_team_zombie_world",   "1",	"Respawn player as a zombie if player was a zombie and killed by world damage. [Override: zr_respawn_team_zombie]");
	
	
	// ===========================
	// Napalm (module)
	// ===========================
	g_hCvarsList[CVAR_NAPALM_IGNITE]					=	CreateConVar("zr_napalm_ignite",	   "1",	"Ignite grenade in mid-air after player throws it. [Dependency: Human Attribute 'has_napalm']");
	g_hCvarsList[CVAR_NAPALM_TIME_RESET]				=	CreateConVar("zr_napalm_time_reset",   "1",	"The burn-time is reset when being naded multiple times. [0: Original burn-time is used.]");
	g_hCvarsList[CVAR_NAPALM_DOUSE]					 =	CreateConVar("zr_napalm_douse",		"0",	"Minimum water-saturation before flame is extinguished. ['0' = Disabled | '1' = Feet | '2' = Waist | '3' = Full submersion]");
	
	
	// ===========================
	// Jump Boost (module)
	// ===========================
	g_hCvarsList[CVAR_JUMPBOOST_BHOP_PROTECT]		   =	CreateConVar("zr_jumpboost_bhop_protect",	  "1",	"Prevent players from using forward jump boost multipliers to bunny hop.");
	g_hCvarsList[CVAR_JUMPBOOST_BHOP_MAX]			   =	CreateConVar("zr_jumpboost_bhop_max",		  "300",  "The maximum horizontal velocity a player can achieve before bunnyhop protection kicks in. [Dependency: zr_jumpboost_bhop_protect]");
	
	
	// ===========================
	// Volumetric Features (module)
	// ===========================
	g_hCvarsList[CVAR_VOL]							  =	CreateConVar("zr_vol",					 "1",	"Enables volumetric features.");
	g_hCvarsList[CVAR_VOL_UPDATE_INTERVAL]			  =	CreateConVar("zr_vol_update_interval",	 "0.5",  "How often to update player positions and trigger events, in seconds.");
	g_hCvarsList[CVAR_VOL_TRIGGER_INTERVAL]			 =	CreateConVar("zr_vol_trigger_interval",	"0.5",  "How often to check for delayed events, in seconds. Use lower values for more precise delays.");
	
	
	// ===========================
	// ZSpawn (module)
	// ===========================
	g_hCvarsList[CVAR_ZSPAWN]						   =	CreateConVar("zr_zspawn",					  "1",		"Allow players to spawn into the game late.");
	
	g_hCvarsList[CVAR_ZSPAWN_TEAM_OVERRIDE]			 =	CreateConVar("zr_zspawn_team_override",		"1",		"Override spawn team when spawning by means of ZSpawn.");
	g_hCvarsList[CVAR_ZSPAWN_TEAM_ZOMBIE]			   =	CreateConVar("zr_zspawn_team_zombie",		  "0",		"Spawn player on zombie team when spawning by means of ZSpawn. [Dependency: zr_zspawn_team_override | Override: zr_respawn_team_zombie]");
	g_hCvarsList[CVAR_ZSPAWN_BLOCK_REJOIN]			  =	CreateConVar("zr_zspawn_block_rejoin",		 "1",		"Block players disconnecting and rejoing the game using zspawn.");
	
	g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT]				 =	CreateConVar("zr_zspawn_timelimit",			"1",		"Put a time limit on the use of ZSpawn.");
	g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT_TIME]			=	CreateConVar("zr_zspawn_timelimit_time",	   "120.0",	"Time from the start of the round to allow ZSpawn. [Dependency: zr_zspawn_timelimit]");
	g_hCvarsList[CVAR_ZSPAWN_TIMELIMIT_ZOMBIE]		  =	CreateConVar("zr_zspawn_timelimit_zombie",	 "1",		"Spawn player on the zombie team AFTER the timelimit is up. ['-1' = Block ZSpawn | '0' = Spawn as human | '1' = Spawn as zombie | Dependency: zr_zspawn_timelimit]");
	
	
	// ===========================
	// ZTele (module)
	// ===========================
	g_hCvarsList[CVAR_ZTELE_ZOMBIE]					 =	CreateConVar("zr_ztele_zombie",				"1",	"Allow zombies to use ZTele.");
	g_hCvarsList[CVAR_ZTELE_HUMAN_BEFORE]			   =	CreateConVar("zr_ztele_human_before",		  "1",	"Allow humans to use ZTele before the mother zombie has spawned.");
	g_hCvarsList[CVAR_ZTELE_HUMAN_AFTER]				=	CreateConVar("zr_ztele_human_after",		   "1",	"Allow humans to use ZTele after the mother zombie has spawned.");
	g_hCvarsList[CVAR_ZTELE_DELAY_ZOMBIE]			   =	CreateConVar("zr_ztele_delay_zombie",		  "3.0",  "Time between using ZTele command and teleportation for zombies. [Dependency: zr_ztele_zombie]");
	g_hCvarsList[CVAR_ZTELE_DELAY_HUMAN]				=	CreateConVar("zr_ztele_delay_human",		   "3.0",  "Time between using ZTele command and teleportation for humans. [Dependency: zr_ztele_human_(before)/(after)]");
	g_hCvarsList[CVAR_ZTELE_MAX_ZOMBIE]				 =	CreateConVar("zr_ztele_max_zombie",			"3",	"Max number of times a zombie is allowed to use ZTele per round. [Dependency: zr_ztele_zombie]");
	g_hCvarsList[CVAR_ZTELE_MAX_HUMAN]				  =	CreateConVar("zr_ztele_max_human",			 "1",	"Max number of times a human is allowed to use ZTele per round. [Dependency: zr_ztele_human_(before)/(after)]");
	g_hCvarsList[CVAR_ZTELE_AUTOCANCEL]				 =	CreateConVar("zr_ztele_autocancel",			"1",	"Automatically cancel ZTele if player moves out of a set boundary. [Dependency: zr_ztele_(zombie)/(human)[_(before)/(after)]]");
	g_hCvarsList[CVAR_ZTELE_AUTOCANCEL_DISTANCE]		=	CreateConVar("zr_ztele_autocancel_distance",   "20",   "Maximum distance, in feet, player is allowed to travel before teleport is cancelled. [Dependency: zr_ztele_autocancel]");
	
	
	// ===========================
	// ZHP (module)
	// ===========================
	g_hCvarsList[CVAR_ZHP]							  =	CreateConVar("zr_zhp",			 "1",	"Allow player to toggle real HP display as a zombie.");
	g_hCvarsList[CVAR_ZHP_DEFAULT]					  =	CreateConVar("zr_zhp_default",	 "1",	"Default ZHP toggle state set on connecting player. [Dependency: zr_zhp]");
	
	g_hCvarsList[CVAR_ZMENU_ENABLED]					  =	CreateConVar("zr_zmenu_enable",	 "1",	"Enable/disable main menu command.");
	
	
	// Auto-generate config file if it doesn't exist, then execute.
	AutoExecConfig(true, "zombiereloaded", "sourcemod/zombiereloaded");
}

/**
 * Hook cvar changes.
 * 
 * @param unhook	If true, cvars will be unhooked, false to hook cvars.
 */
void CvarsHook(bool unhook = false)
{
	// If unhook is true, then continue.
	if (unhook)
	{
		// Unhook all cvars.
		UnhookConVarChange(g_hAutoTeamBalance, CvarsHookLocked);
		UnhookConVarChange(g_hLimitTeams, CvarsHookLocked);
		UnhookConVarChange(g_hRestartGame, CvarsHookRestartGame);
		
		UnhookConVarChange(g_hCvarsList[CVAR_VOL], VolEnabledChanged);
		
		// Stop after unhooking cvars.
		return;
	}
	
	// Set locked cvars to their locked value.
	SetConVarInt(g_hAutoTeamBalance, CVARS_AUTOTEAMBALANCE_LOCKED);
	SetConVarInt(g_hLimitTeams, CVARS_LIMITTEAMS_LOCKED);
	
	// Hook cvar to prevent it from changing.
	HookConVarChange(g_hAutoTeamBalance, CvarsHookLocked);
	HookConVarChange(g_hLimitTeams, CvarsHookLocked);
	HookConVarChange(g_hRestartGame, CvarsHookRestartGame);
	
	HookConVarChange(g_hCvarsList[CVAR_VOL], VolEnabledChanged);
}

/**
 * Cvar hook callback (mp_autoteambalance, mp_limitteams)
 * Prevents changes to cvar.
 * 
 * @param convar	The cvar handle.
 * @param oldvalue  The value before the attempted change.
 * @param newvalue  The new value.
 */
public void CvarsHookLocked(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	// If cvar is mp_autoteambalance, then continue.
	if (cvar == g_hAutoTeamBalance)
	{
		// If plugin is reverting value, then stop.
		if (StringToInt(newvalue) == CVARS_AUTOTEAMBALANCE_LOCKED)
		{
			return;
		}
		
		// Revert to locked value.
		SetConVarInt(g_hAutoTeamBalance, CVARS_AUTOTEAMBALANCE_LOCKED);
		
		// If log flag check fails, then don't log.
		LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Cvars, "Cvar Locked", "Cvar \"mp_autoteambalance\" was reverted back to %d.", CVARS_AUTOTEAMBALANCE_LOCKED);
	}
	// If cvar is mp_limitteams, then continue.
	else if (cvar == g_hLimitTeams)
	{
		// If plugin is reverting value, then stop.
		if (StringToInt(newvalue) == CVARS_LIMITTEAMS_LOCKED)
		{
			return;
		}
		
		// Revert to locked value.
		SetConVarInt(g_hLimitTeams, CVARS_LIMITTEAMS_LOCKED);
		
		// If log flag check fails, then don't log.
		LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Cvars, "Cvar Locked", "Cvar \"mp_limitteams\" was reverted back to %d.", CVARS_LIMITTEAMS_LOCKED);
	}
}

/**
 * Cvar hook callback (mp_restartgame)
 * Stops restart and just ends the round.
 * 
 * @param convar	The cvar handle.
 * @param oldvalue  The value before the attempted change.
 * @param newvalue  The new value.
 */
public void CvarsHookRestartGame(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	// Prevent round restart.
	SetConVarInt(cvar, 0);
	
	// If value was invalid or 0, then stop.
	float delay = StringToFloat(newvalue);
	if (delay <= 0)
	{
		return;
	}
	
	// Terminate the round with restart time as delay.
	RoundEndTerminateRound(delay);
	
	// If log flag check fails, then don't log.
	LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Cvars, "Restart Game", "\"mp_restartgame\" was caught and blocked, commencing round.");
}
