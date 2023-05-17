/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zombiereloaded_sounds.sp
 *  Type:		  Base
 *  Description:   Plugin's base file.
 *
 *  Copyright (C) 2021  Anubis.
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

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <cstrike>
#include <zombiereloaded>

#pragma newdecls required

#define VERSION "3.7.3 Anubis edition"

#include "zr_sounds/zombiereloaded"

// Core includes.
#include "zr_sounds/global"
#include "zr_sounds/translation"
#include "zr_sounds/cvars"
#include "zr_sounds/config"
#include "zr_sounds/sayhooks"
#include "zr_sounds/cookies"
#include "zr_sounds/downloads"
#include "zr_sounds/menu"
#include "zr_sounds/commands"
#include "zr_sounds/soundeffects/soundeffects"
#include "zr_sounds/event"
#include "zr_sounds/infect"

public Plugin myinfo =
{
	name = "Zombie:Reloaded_Sounds",
	author = "Anúbis",
	description = "Sounds for Zombie:Reloaded-Anubis Edition.",
	version = VERSION,
	url = "https://github.com/Stewart-Anubis"
};

/**
 * Plugin is loading.
 */
public void OnPluginStart()
{
	// Forward event to modules.
	CvarsInit();
	TranslationInit();
	CookiesInit();
	CommandsInit();
	DownloadsInit();
}

/**
 * The map is starting.
 */
public void OnMapStart()
{
	// Forward event to modules.
	DownloadsLoadPreCached();
	EventInit();
	AmbientSoundsOnMapStart();
}

/**
 * The map is ending.
 */
public void OnMapEnd()
{
	// Forward event to modules.
	ZombieSoundsOnMapEnd();
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
public void OnClientPutInServer(int client)
{
	// Forward event to modules.
	SEffectsClientInit(client);
}

/**
 * Called once a client's saved cookies have been loaded from the database.
 * 
 * @param client		Client index.
 */
public void OnClientCookiesCached(int client)
{
	// Forward event to modules.
	ZrSoundsOnCookiesCached(client);
}