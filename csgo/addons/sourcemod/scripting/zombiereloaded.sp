/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zombiereloaded.sp
 *  Type:		  Base
 *  Description:   Plugin's base file.
 *
 *  Copyright (C) 2009  Greyscale, Richard Helgeby, Francisco 'Franc1sco' García
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

// Comment to use ZR Tools Extension, otherwise SDK Hooks Extension will be used.
#define USE_SDKHOOKS

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <cstrike>

#pragma newdecls required

#undef REQUIRE_EXTENSIONS
#include <hitboxchanger>

#if defined USE_SDKHOOKS
	#include <sdkhooks>
	
	#define ACTION_CONTINUE	 Plugin_Continue
	#define ACTION_CHANGED	  Plugin_Changed
	#define ACTION_HANDLED	  Plugin_Handled
#else
	#include <zrtools>
	
	#define ACTION_CONTINUE	 ZRTools_Continue
	#define ACTION_CHANGED	  ZRTools_Changed
	#define ACTION_HANDLED	  ZRTools_Handled
#endif



#define VERSION "3.6.5 Franug edition"

bool g_allweapons[MAXPLAYERS + 1];

// Comment this line to exclude version info command. Enable this if you have
// the repository and HG installed (Mercurial or TortoiseHG).
#define ADD_VERSION_INFO

// Header includes.
#include "zr/log.h"
#include "zr/models.h"
#include "zr/immunityhandler.h"

#if defined ADD_VERSION_INFO
#include "zr/hgversion.h"
#endif

// Core includes.
#include "zr/zombiereloaded"

#if defined ADD_VERSION_INFO
#include "zr/versioninfo"
#endif

#include "zr/translation"
#include "zr/cvars"
#include "zr/admintools"
#include "zr/log"
#include "zr/config"
#include "zr/steamidcache"
#include "zr/sayhooks"
#include "zr/tools"
#include "zr/menu"
#include "zr/cookies"
#include "zr/paramtools"
#include "zr/paramparser"
#include "zr/shoppinglist"
#include "zr/downloads"
#include "zr/overlays"
#include "zr/playerclasses/playerclasses"
#include "zr/models"
#include "zr/weapons/weapons"
#include "zr/hitgroups"
#include "zr/roundstart"
#include "zr/roundend"
#include "zr/infect"
#include "zr/immunityhandler"
#include "zr/damage"
#include "zr/event"
#include "zr/zadmin"
#include "zr/commands"
//#include "zr/global"

// Modules
#include "zr/account"
#include "zr/visualeffects/visualeffects"
#include "zr/antistick"
#include "zr/knockback"
#include "zr/spawnprotect"
#include "zr/respawn"
#include "zr/napalm"
#include "zr/jumpboost"
#include "zr/zspawn"
#include "zr/ztele"
#include "zr/zhp"
#include "zr/zcookies"
#include "zr/volfeatures/volfeatures"
#include "zr/debugtools"

#include "zr/api/api"

/**
 * Record plugin info.
 */
public Plugin myinfo =
{
	name = "Zombie:Reloaded",
	author = "Greyscale | Richard Helgeby and Franc1sco franug | Anubis Edition",
	description = "Infection/survival style gameplay",
	version = VERSION,
	url = "https://github.com/Franc1sco/sm-zombiereloaded-3-Franug-Edition"
};

/**
 * Called before plugin is loaded.
 * 
 * @param myself	The plugin handle.
 * @param late	  True if the plugin was loaded after map change, false on map start.
 * @param error	 Error message if load failed.
 * @param err_max   Max length of the error message.
 *
 * @return		  APLRes_Success for load success, APLRes_Failure or APLRes_SilentFailure otherwise.
 */
public APLRes AskPluginLoad2(Handle myself, bool late, char []error, int err_max)
{
	//Register the plugin library.
	RegPluginLibrary("zombiereloaded");
	
	MarkNativeAsOptional("SetNumHitboxes");
	
	// Load API.
	APIInit();
	
	// Let plugin load.
	return APLRes_Success;
}
	
/**
 * Plugin is loading.
 */
public void OnPluginStart()
{
	UpdateGameFolder();
	
	// Forward event to modules.
	LogInit();		  // Doesn't depend on CVARs.
	TranslationInit();
	CvarsInit();
	ToolsInit();
	CookiesInit();
	CommandsInit();
	WeaponsInit();
	EventInit();
}

/**
 * All plugins have finished loading.
 */
public void OnAllPluginsLoaded()
{
	// Forward event to modules.
	WeaponsOnAllPluginsLoaded();
	ConfigOnAllPluginsLoaded();
}

/**
 * A library was added.
 */
public void OnLibraryAdded(const char[] name)
{
	// Forward event to modules.
	ConfigOnLibraryAdded(name);
}

/**
 * A library was removed.
 */
public void OnLibraryRemoved(const char[] name)
{
	ConfigOnLibraryRemoved(name);
}

/**
 * The map is starting.
 */
public void OnMapStart()
{
	// Forward event to modules.
	ClassOnMapStart();
	OverlaysOnMapStart();
	RoundEndOnMapStart();
	ZSpawnOnMapStart();
	VolInit();
	
	// Fixed crashes on CS:GO
	ModelsLoad();
	DownloadsLoad();
	VEffectsLoad();
}

/**
 * The map is ending.
 */
public void OnMapEnd()
{
	// Forward event to modules.
	InfectOnMapEnd();
	VolOnMapEnd();
	VEffectsOnMapEnd();
	ImmunityOnMapEnd();
}

/**
 * Main configs were just executed.
 */
public void OnAutoConfigsBuffered()
{
	// Load map configurations.
	ConfigLoad();
}

/**
 * Configs just finished getting executed.
 */
public void OnConfigsExecuted()
{
	// Forward event to modules. (OnConfigsExecuted)

	WeaponsLoad();
	HitgroupsLoad();
	DamageLoad();
	ClassOnConfigsExecuted();
	ClassLoad();
	VolLoad();
	
	// Forward event to modules. (OnModulesLoaded)
	ConfigOnModulesLoaded();
	ClassOnModulesLoaded();
}

/**
 * Client has just connected to the server.
 */
public void OnClientConnected(int client)
{
	g_allweapons[client] = false;
	// Forward event to modules.
	ClassOnClientConnected(client);
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
public void OnClientPutInServer(int client)
{
	// Forward event to modules.
	ClassClientInit(client);
	OverlaysClientInit(client);
	WeaponsClientInit(client);
	InfectClientInit(client);
	DamageClientInit(client);
	AntiStickClientInit(client);
	SpawnProtectClientInit(client);
	RespawnClientInit(client);
	ZTeleClientInit(client);
	ZHPClientInit(client);
	ImmunityClientInit(client);
}

/**
 * Called once a client's saved cookies have been loaded from the database.
 * 
 * @param client		Client index.
 */
public void OnClientCookiesCached(int client)
{
	// Check if client disconnected before cookies were done caching.
	if (!IsClientConnected(client))
	{
		return;
	}
	
	// Forward "OnCookiesCached" event to modules.
	ClassOnCookiesCached(client);
	WeaponsOnCookiesCached(client);
	ZHPOnCookiesCached(client);
}

/**
 * Called once a client is authorized and fully in-game, and 
 * after all post-connection authorizations have been performed.  
 *
 * This callback is gauranteed to occur on all clients, and always 
 * after each OnClientPutInServer() call.
 *
 * @param client		Client index.
 * @noreturn
 */
public void OnClientPostAdminCheck(int client)
{
	// Forward authorized event to modules that depend on client admin info.
	ClassOnClientPostAdminCheck(client);
}

/**
 * Client is leaving the server.
 * 
 * @param client	The client index.
 */
public void OnClientDisconnect(int client)
{
	// Forward event to modules.
	ClassOnClientDisconnect(client);
	WeaponsOnClientDisconnect(client);
	InfectOnClientDisconnect(client);
	DamageOnClientDisconnect(client);
	AntiStickOnClientDisconnect(client);
	ZSpawnOnClientDisconnect(client);
	VolOnPlayerDisconnect(client);
	ImmunityOnClientDisconnect(client);
}

/**
 * Called when a clients movement buttons are being processed
 *
 * @param client	Index of the client.
 * @param buttons	Copyback buffer containing the current commands (as bitflags - see entity_prop_stocks.inc).
 * @param impulse	Copyback buffer containing the current impulse command.
 * @param vel		Players desired velocity.
 * @param angles	Players desired view angles.
 * @param weapon	Entity index of the new weapon if player switches weapon, 0 otherwise.
 * @return 			Plugin_Handled to block the commands from being processed, Plugin_Continue otherwise.
 */
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	Class_OnPlayerRunCmd(client, vel);
	return Plugin_Continue;
}
