/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  cvars_sounds.inc
 *  Type:		  Core
 *  Description:   Config creation and cvar control.
 *
 *  Copyright (C) 2021 Anubis.
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
 * List of cvars used by the plugin.
 */

ConVar CVAR_VOICE = null;
ConVar CVAR_COUNTDOWN_SOUNDS = null;
ConVar CVAR_COUNTDOWN_MAM_PATH = null;
ConVar CVAR_COUNTDOWN_WOMAN_PATH = null;
ConVar CVAR_INFECT_SOUND = null;
ConVar CVAR_SEFFECTS_MOAN = null;
ConVar CVAR_SEFFECTS_GROAN = null;
ConVar CVAR_SEFFECTS_DEATH = null;
ConVar CVAR_SEFFECTS_COMMAND_LIMIT = null;
ConVar CVAR_SEFFECTS_COMMAND_TIMESPAN = null;
ConVar CVAR_ZOMBIES_SOUNDS_FILES = null;
ConVar CVAR_AMBIENTSOUNDS = null;
ConVar CVAR_AMBIENTSOUNDS_FILE = null;
ConVar CVAR_AMBIENTSOUNDS_LENGTH = null;
ConVar CVAR_AMBIENTSOUNDS_VOLUME = null;
ConVar CVAR_ROUNDEND_SOUNDS = null;
ConVar CVAR_ROUNDEND_HUMANS_WIN = null;
ConVar CVAR_ROUNDEND_ZOMBIE_WIN = null;
ConVar CVAR_ROUNDEND_VOLUME = null;
ConVar CVAR_ZOMBIES_SOUNDS = null;
ConVar CVAR_ZOMBIES_SOUNDS_DEFAULT = null;
ConVar CVAR_ROUNDEND_SOUNDS_DEFAULT = null;
ConVar CVAR_VOICECOUNT_DEFAULT = null;
ConVar CVAR_VOLUME_DEFAULT = null;

enum struct CvarsList
{
	bool g_bCVAR_VOICE;
	bool g_bCVAR_COUNTDOWN_SOUNDS;
	char g_sCVAR_COUNTDOWN_MAM_PATH[PLATFORM_MAX_PATH];
	char g_sCVAR_COUNTDOWN_WOMAN_PATH[PLATFORM_MAX_PATH];
	char g_sCVAR_INFECT_SOUND[PLATFORM_MAX_PATH];
	float g_fCVAR_SEFFECTS_MOAN;
	int g_iCVAR_SEFFECTS_GROAN;
	bool g_bCVAR_SEFFECTS_DEATH;
	int g_iCVAR_SEFFECTS_COMMAND_LIMIT;
	float g_fCVAR_SEFFECTS_COMMAND_TIMESPAN;
	char g_sCVAR_ZOMBIES_SOUNDS_FILES[PLATFORM_MAX_PATH];
	bool g_bCVAR_AMBIENTSOUNDS;
	char g_sCVAR_AMBIENTSOUNDS_FILE[PLATFORM_MAX_PATH];
	float g_fCVAR_AMBIENTSOUNDS_LENGTH;
	float g_fCVAR_AMBIENTSOUNDS_VOLUME;
	bool g_bCVAR_ROUNDEND_SOUNDS;
	char g_sCVAR_ROUNDEND_HUMANS_WIN[PLATFORM_MAX_PATH];
	char g_sCVAR_ROUNDEND_ZOMBIE_WIN[PLATFORM_MAX_PATH];
	float g_fCVAR_ROUNDEND_VOLUME;
	bool g_bCVAR_ZOMBIES_SOUNDS;
	bool g_bCVAR_ZOMBIES_SOUNDS_DEFAULT;
	bool g_bCVAR_ROUNDEND_SOUNDS_DEFAULT;
	int g_iCVAR_VOICECOUNT_DEFAULT;
	float g_fCVAR_VOLUME_DEFAULT;
}

/**
 * Array to store cvar data in.
 */
CvarsList g_hCvarsList;

/**
 * @endsection
 */

/**
 * Cvars module init function.
 */
void CvarsInit()
{
	// Create zombiereloaded cvars.
	CvarsCreate();

	// Create public cvar for tracking.
	char description[64];
	Format(description, sizeof(description), "%s Current version of this plugin", TRANSLATION_PHRASE_PREFIX);
	CreateConVar("gs_zombiereloaded_sounds_version", VERSION, description, FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
}

/**
 * Create all cvars for plugin.
 */
void CvarsCreate()
{
	// ===========================
	// Sound Effects (module)
	// ===========================

	// Voice
	CVAR_VOICE					  =	CreateConVar("zrs_voice",				 	  "0",							"(Incomplete) Modify sv_alltalk to obey zombie/human teams instead of t/ct.");

	//CountDown Sounds
	CVAR_COUNTDOWN_SOUNDS		  =	CreateConVar("zrs_countdown_sounds",	   		  "1",				"Enables or disables countdown sounds.");
	CVAR_COUNTDOWN_MAM_PATH		  =	CreateConVar("zrs_countdown_files_mam",	   	  "zr/countdown/",				"Folder referring to the counter sounds. Man.");
	CVAR_COUNTDOWN_WOMAN_PATH		  =	CreateConVar("zrs_countdown_files_woman",     "zr/countdown/female/",			"Folder referring to the counter sounds. Woman.");

	// Zombie Sounds
	CVAR_ZOMBIES_SOUNDS			  =	CreateConVar("zrs_zombies_sounds",	 		  "1",						    "Enable/disable sounds Zombies. Default '1'");
	CVAR_INFECT_SOUND			  =	CreateConVar("zrs_infect_sound",			      "fz_scream1.mp3",   			"Sound, relative to [zrs_files_zombie_sounds] folder, to play from player on infection. ['\"\"' = No sound]");
	CVAR_SEFFECTS_MOAN			  =	CreateConVar("zrs_seffects_moan",		      "30.0",					 	"Time between emission of a moan sound from a zombie.");
	CVAR_SEFFECTS_GROAN			  =	CreateConVar("zrs_seffects_groan",		      "5",							"The probability that a groan sound will be emitted from a zombie when shot. ['100' = 1% chance | '50' = 2% chance | '1' = 100% chance]");
	CVAR_SEFFECTS_DEATH			  =	CreateConVar("zrs_seffects_death",		      "1",							"Emit a death sound when a zombie dies.");
	CVAR_SEFFECTS_COMMAND_LIMIT	  =	CreateConVar("zrs_seffects_command_limit",    "4",							"Number of sound commands allowed within the time span, or total limit if time span is disabled. ['0' = Disable sound command limit]");
	CVAR_SEFFECTS_COMMAND_TIMESPAN	  =	CreateConVar("zrs_seffects_command_timespan", "10",					   		"Time span for sound command limiter (in seconds). ['0' = Disable time span check | positive number = Time span]");
	CVAR_ZOMBIES_SOUNDS_FILES		  =	CreateConVar("zrs_files_zombie_sounds",		  "zr/",							"Folder referring to the sounds of zombies.");

	// Ambient Sounds
	CVAR_AMBIENTSOUNDS			  =	CreateConVar("zrs_ambientsounds",		      "1",							"Play an ambient sound to all players during gameplay.");
	CVAR_AMBIENTSOUNDS_FILE		  =	CreateConVar("zrs_ambientsounds_file",	  	  "ambient/zr/zr_ambience.mp3", "Sound file, relative to \"sound\" folder, to play as ambience.  This file is automatically downloaded to clients. [Dependency: zrs_ambientsounds]");
	CVAR_AMBIENTSOUNDS_LENGTH		  =	CreateConVar("zrs_ambientsounds_length",	  "60.0",						"Length of the ambient sound. [Dependency: zrs_ambientsounds]");
	CVAR_AMBIENTSOUNDS_VOLUME		  =	CreateConVar("zrs_ambientsounds_volume",	  "0.8",						"Volume of the ambient sound. [1.0 = Max volume | 0.0001 = Not audible | Dependency: zrs_ambientsounds]");

	// Round End Sounds
	CVAR_ROUNDEND_SOUNDS			  =	CreateConVar("zrs_roundend_sounds",	 		  "1",	 						"Enable/disable togle sounds roundend. Default '1'");
	CVAR_ROUNDEND_HUMANS_WIN		  =	CreateConVar("zrs_files_humans_win",		  "roundend/humanswin/",		"Folder referring to the sounds of the round end. Humans win.");
	CVAR_ROUNDEND_ZOMBIE_WIN		  =	CreateConVar("zrs_files_zombie_win",		  "roundend/zombiewin/",		"Folder referring to the sounds of the round end. Zombie win.");
	CVAR_ROUNDEND_VOLUME	 	      =	CreateConVar("zrs_roundend_volume",	    	  "0.08",						"Volume of the roundend sound. [1.0 = Max volume | 0.0001 = Not audible | Dependency: zrs_roundend_sounds]");

	// ===========================
	// Voice ZrSounds (module)
	// ===========================

	CVAR_ZOMBIES_SOUNDS_DEFAULT	  =	CreateConVar("zrs_zombies_sounds_default",	  "1",							"Enable/disable Zombies Standard of the sound of the client. Default '1'");
	CVAR_ROUNDEND_SOUNDS_DEFAULT	  =	CreateConVar("zrs_roundend_sounds_default",	  "1",							"Enable/disable RoundEnd Standard of the sound of the client. Default '1'");	
	CVAR_VOICECOUNT_DEFAULT		  =	CreateConVar("zrs_voice_count_default",		  "1",							"Default Client countdown voice. ['1' = Mem  | '2' = Woman!] Default 1");
	CVAR_VOLUME_DEFAULT			  =	CreateConVar("zrs_volume_default",			  "0.5",						"Default Client volume Zr Sounds. Default '0.5'");

	// ===========================
	// Convar Load
	// ===========================

	g_hCvarsList.g_bCVAR_VOICE = CVAR_VOICE.BoolValue;
	g_hCvarsList.g_bCVAR_COUNTDOWN_SOUNDS = CVAR_COUNTDOWN_SOUNDS.BoolValue;
	GetConVarString(CVAR_COUNTDOWN_MAM_PATH, g_hCvarsList.g_sCVAR_COUNTDOWN_MAM_PATH, sizeof(g_hCvarsList.g_sCVAR_COUNTDOWN_MAM_PATH));
	GetConVarString(CVAR_COUNTDOWN_WOMAN_PATH, g_hCvarsList.g_sCVAR_COUNTDOWN_WOMAN_PATH, sizeof(g_hCvarsList.g_sCVAR_COUNTDOWN_WOMAN_PATH));
	g_hCvarsList.g_bCVAR_ZOMBIES_SOUNDS = CVAR_ZOMBIES_SOUNDS.BoolValue;
	GetConVarString(CVAR_INFECT_SOUND, g_hCvarsList.g_sCVAR_INFECT_SOUND, sizeof(g_hCvarsList.g_sCVAR_INFECT_SOUND));
	g_hCvarsList.g_fCVAR_SEFFECTS_MOAN = CVAR_SEFFECTS_MOAN.FloatValue;
	g_hCvarsList.g_iCVAR_SEFFECTS_GROAN = CVAR_SEFFECTS_GROAN.IntValue;
	g_hCvarsList.g_bCVAR_SEFFECTS_DEATH = CVAR_SEFFECTS_DEATH.BoolValue;
	g_hCvarsList.g_iCVAR_SEFFECTS_COMMAND_LIMIT = CVAR_SEFFECTS_COMMAND_LIMIT.IntValue;
	g_hCvarsList.g_fCVAR_SEFFECTS_COMMAND_TIMESPAN = CVAR_SEFFECTS_COMMAND_TIMESPAN.FloatValue;
	GetConVarString(CVAR_ZOMBIES_SOUNDS_FILES, g_hCvarsList.g_sCVAR_ZOMBIES_SOUNDS_FILES, sizeof(g_hCvarsList.g_sCVAR_ZOMBIES_SOUNDS_FILES));
	g_hCvarsList.g_bCVAR_AMBIENTSOUNDS = CVAR_AMBIENTSOUNDS.BoolValue;
	GetConVarString(CVAR_AMBIENTSOUNDS_FILE, g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE, sizeof(g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE));
	g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_LENGTH = CVAR_AMBIENTSOUNDS_LENGTH.FloatValue;
	g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_VOLUME = CVAR_AMBIENTSOUNDS_VOLUME.FloatValue;
	g_hCvarsList.g_bCVAR_ROUNDEND_SOUNDS = CVAR_ROUNDEND_SOUNDS.BoolValue;
	GetConVarString(CVAR_ROUNDEND_HUMANS_WIN ,g_hCvarsList.g_sCVAR_ROUNDEND_HUMANS_WIN, sizeof(g_hCvarsList.g_sCVAR_ROUNDEND_HUMANS_WIN));
	GetConVarString(CVAR_ROUNDEND_ZOMBIE_WIN ,g_hCvarsList.g_sCVAR_ROUNDEND_ZOMBIE_WIN, sizeof(g_hCvarsList.g_sCVAR_ROUNDEND_ZOMBIE_WIN));
	g_hCvarsList.g_fCVAR_ROUNDEND_VOLUME = CVAR_ROUNDEND_VOLUME.FloatValue;
	g_hCvarsList.g_bCVAR_ZOMBIES_SOUNDS_DEFAULT = CVAR_ZOMBIES_SOUNDS_DEFAULT.BoolValue;
	g_hCvarsList.g_bCVAR_ROUNDEND_SOUNDS_DEFAULT = CVAR_ROUNDEND_SOUNDS_DEFAULT.BoolValue;
	g_hCvarsList.g_iCVAR_VOICECOUNT_DEFAULT = CVAR_VOICECOUNT_DEFAULT.IntValue;
	g_hCvarsList.g_fCVAR_VOLUME_DEFAULT = CVAR_VOLUME_DEFAULT.FloatValue;

	//ConVarChange

	CVAR_VOICE.AddChangeHook(ConVarChange);
	CVAR_COUNTDOWN_SOUNDS.AddChangeHook(ConVarChange);
	CVAR_COUNTDOWN_MAM_PATH.AddChangeHook(ConVarChange);
	CVAR_COUNTDOWN_WOMAN_PATH.AddChangeHook(ConVarChange);
	CVAR_ZOMBIES_SOUNDS.AddChangeHook(ConVarChange);
	CVAR_INFECT_SOUND.AddChangeHook(ConVarChange);
	CVAR_SEFFECTS_MOAN.AddChangeHook(ConVarChange);
	CVAR_SEFFECTS_GROAN.AddChangeHook(ConVarChange);
	CVAR_SEFFECTS_DEATH.AddChangeHook(ConVarChange);
	CVAR_SEFFECTS_COMMAND_LIMIT.AddChangeHook(ConVarChange);
	CVAR_SEFFECTS_COMMAND_TIMESPAN.AddChangeHook(ConVarChange);
	CVAR_ZOMBIES_SOUNDS_FILES.AddChangeHook(ConVarChange);
	CVAR_AMBIENTSOUNDS.AddChangeHook(ConVarChange);
	CVAR_AMBIENTSOUNDS_FILE.AddChangeHook(ConVarChange);
	CVAR_AMBIENTSOUNDS_LENGTH.AddChangeHook(ConVarChange);
	CVAR_AMBIENTSOUNDS_VOLUME.AddChangeHook(ConVarChange);
	CVAR_ROUNDEND_SOUNDS.AddChangeHook(ConVarChange);
	CVAR_ROUNDEND_HUMANS_WIN.AddChangeHook(ConVarChange);
	CVAR_ROUNDEND_ZOMBIE_WIN.AddChangeHook(ConVarChange);
	CVAR_ROUNDEND_VOLUME.AddChangeHook(ConVarChange);
	CVAR_ZOMBIES_SOUNDS_DEFAULT.AddChangeHook(ConVarChange);
	CVAR_ROUNDEND_SOUNDS_DEFAULT.AddChangeHook(ConVarChange);
	CVAR_VOICECOUNT_DEFAULT.AddChangeHook(ConVarChange);
	CVAR_VOLUME_DEFAULT.AddChangeHook(ConVarChange);

	//solution found for cvars load delay
	if (FileExists("cfg/sourcemod/zombiereloaded/zombiereloaded_sounds.cfg"))
	{
		// Auto-exec config file .
		ServerCommand("exec sourcemod/zombiereloaded/zombiereloaded_sounds.cfg");
	}
	// Auto-generate config file if it doesn't exist, then execute.
	AutoExecConfig(true, "zombiereloaded_sounds", "sourcemod/zombiereloaded");
}

public void ConVarChange(ConVar convar, char[] oldValue, char[] newValue)
{
	//ConVarChange

	g_hCvarsList.g_bCVAR_VOICE = CVAR_VOICE.BoolValue;
	g_hCvarsList.g_bCVAR_COUNTDOWN_SOUNDS = CVAR_COUNTDOWN_SOUNDS.BoolValue;
	GetConVarString(CVAR_COUNTDOWN_MAM_PATH, g_hCvarsList.g_sCVAR_COUNTDOWN_MAM_PATH, sizeof(g_hCvarsList.g_sCVAR_COUNTDOWN_MAM_PATH));
	GetConVarString(CVAR_COUNTDOWN_WOMAN_PATH, g_hCvarsList.g_sCVAR_COUNTDOWN_WOMAN_PATH, sizeof(g_hCvarsList.g_sCVAR_COUNTDOWN_WOMAN_PATH));
	g_hCvarsList.g_bCVAR_ZOMBIES_SOUNDS = CVAR_ZOMBIES_SOUNDS.BoolValue;
	GetConVarString(CVAR_INFECT_SOUND, g_hCvarsList.g_sCVAR_INFECT_SOUND, sizeof(g_hCvarsList.g_sCVAR_INFECT_SOUND));
	g_hCvarsList.g_fCVAR_SEFFECTS_MOAN = CVAR_SEFFECTS_MOAN.FloatValue;
	g_hCvarsList.g_iCVAR_SEFFECTS_GROAN = CVAR_SEFFECTS_GROAN.IntValue;
	g_hCvarsList.g_bCVAR_SEFFECTS_DEATH = CVAR_SEFFECTS_DEATH.BoolValue;
	g_hCvarsList.g_iCVAR_SEFFECTS_COMMAND_LIMIT = CVAR_SEFFECTS_COMMAND_LIMIT.IntValue;
	g_hCvarsList.g_fCVAR_SEFFECTS_COMMAND_TIMESPAN = CVAR_SEFFECTS_COMMAND_TIMESPAN.FloatValue;
	GetConVarString(CVAR_ZOMBIES_SOUNDS_FILES, g_hCvarsList.g_sCVAR_ZOMBIES_SOUNDS_FILES, sizeof(g_hCvarsList.g_sCVAR_ZOMBIES_SOUNDS_FILES));
	g_hCvarsList.g_bCVAR_AMBIENTSOUNDS = CVAR_AMBIENTSOUNDS.BoolValue;
	GetConVarString(CVAR_AMBIENTSOUNDS_FILE, g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE, sizeof(g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE));
	g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_LENGTH = CVAR_AMBIENTSOUNDS_LENGTH.FloatValue;
	g_hCvarsList.g_fCVAR_AMBIENTSOUNDS_VOLUME = CVAR_AMBIENTSOUNDS_VOLUME.FloatValue;
	g_hCvarsList.g_bCVAR_ROUNDEND_SOUNDS = CVAR_ROUNDEND_SOUNDS.BoolValue;
	GetConVarString(CVAR_ROUNDEND_HUMANS_WIN ,g_hCvarsList.g_sCVAR_ROUNDEND_HUMANS_WIN, sizeof(g_hCvarsList.g_sCVAR_ROUNDEND_HUMANS_WIN));
	GetConVarString(CVAR_ROUNDEND_ZOMBIE_WIN ,g_hCvarsList.g_sCVAR_ROUNDEND_ZOMBIE_WIN, sizeof(g_hCvarsList.g_sCVAR_ROUNDEND_ZOMBIE_WIN));
	g_hCvarsList.g_fCVAR_ROUNDEND_VOLUME = CVAR_ROUNDEND_VOLUME.FloatValue;
	g_hCvarsList.g_bCVAR_ZOMBIES_SOUNDS_DEFAULT = CVAR_ZOMBIES_SOUNDS_DEFAULT.BoolValue;
	g_hCvarsList.g_bCVAR_ROUNDEND_SOUNDS_DEFAULT = CVAR_ROUNDEND_SOUNDS_DEFAULT.BoolValue;
	g_hCvarsList.g_iCVAR_VOICECOUNT_DEFAULT = CVAR_VOICECOUNT_DEFAULT.IntValue;
	g_hCvarsList.g_fCVAR_VOLUME_DEFAULT = CVAR_VOLUME_DEFAULT.FloatValue;
}