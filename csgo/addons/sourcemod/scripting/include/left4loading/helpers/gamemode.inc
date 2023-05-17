/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			gamemode.inc
 *  Type:			Helper
 *  Description:	Provides functions to figure out which gamemode is active
 *
 *  Copyright (C) 2010  Mr. Zero
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

// Don't let the script be included more than once.
#if defined _gamemode_included
  #endinput
#endif
#define _gamemode_included

// --------------------
//       Private
// --------------------

// List of gamemodes
static	const			GAMEMODE_VERSUS					= 0;
static	const			GAMEMODE_TEAMVERSUS				= 1;
static	const			GAMEMODE_COOP					= 2;
static	const			GAMEMODE_REALISM				= 3;
static	const			GAMEMODE_REALISM_VERSUS			= 4;
static	const			GAMEMODE_SURVIVAL				= 5;
static	const			GAMEMODE_SURVIVAL_VERSUS		= 6;
static	const	String:	GAMEMODES[][]					= {"versus", "teamversus", "coop", "realism", "mutation12", "survival", "mutation15"};

//The cvar handle for mp_gamemode
static	const	String:	GAMEMODE_CVAR[]					= "mp_gamemode";
static			Handle:	g_hGamemode						= INVALID_HANDLE;

// Boolean for keep track of current gamemode
static			bool:	g_bGameMode[sizeof(GAMEMODES)]	= {false};

static			bool:	g_bIsModuleSetup				= false;

// **********************************************
//                 Forwards
// **********************************************

/**
 * Gamemode cvar was changed
 */
public _H_GM_ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	GetGamemode();
}

// **********************************************
//                 Public API
// **********************************************

/**
 * Returns whether the gamemode is versus.
 * 
 * @return		True upon the gamemode is versus or team versus, false if not.
 */
stock bool:IsVersus()
{
	SetupModule();

	if (g_bGameMode[GAMEMODE_TEAMVERSUS] ||
		g_bGameMode[GAMEMODE_REALISM_VERSUS] ||
		g_bGameMode[GAMEMODE_SURVIVAL_VERSUS]) 
		return true;
	return g_bGameMode[GAMEMODE_VERSUS];
}

/**
 * Returns whether the gamemode is coop.
 * 
 * @return		True upon the gamemode is coop, false if not.
 */
stock bool:IsCoop()
{
	SetupModule();

	if (g_bGameMode[GAMEMODE_REALISM] ||
		g_bGameMode[GAMEMODE_SURVIVAL]) 
		return true;
	return g_bGameMode[GAMEMODE_COOP];
}

/**
 * Returns whether the gamemode is survival.
 * 
 * @return		True upon the gamemode is survival, false if not.
 */
stock bool:IsSurvival()
{
	SetupModule();

	if (g_bGameMode[GAMEMODE_SURVIVAL_VERSUS]) return true;
	return g_bGameMode[GAMEMODE_SURVIVAL];
}

/**
 * Returns whether the gamemode is realism.
 * 
 * @return		True upon the gamemode is realism, false if not.
 */
stock bool:IsRealism()
{
	SetupModule();

	if (g_bGameMode[GAMEMODE_REALISM_VERSUS]) return true;
	return g_bGameMode[GAMEMODE_REALISM];
}

/**
 * Returns whether the gamemode is survival versus (mutation15).
 * 
 * @return		True upon the gamemode is survival versus, false otherwise.
 */
stock bool:IsSurvivalVersus()
{
	SetupModule();

	return g_bGameMode[GAMEMODE_SURVIVAL_VERSUS];
}

// **********************************************
//                 Private API
// **********************************************

/**
 * Setup module if needed.
 * 
 * @noreturn
 */
static SetupModule()
{
	if (g_bIsModuleSetup) return;

	g_hGamemode = FindConVar(GAMEMODE_CVAR);
	HookConVarChange(g_hGamemode, _H_GM_ConVarChange);

	GetGamemode();

	g_bIsModuleSetup = true;
}

/**
 * Gets the active gamemode and sets the boolean accordingly.
 * 
 * @noreturn
 */
static GetGamemode()
{
	decl String:sGamemode[32];
	GetConVarString(g_hGamemode, sGamemode, sizeof(sGamemode));

	for (new i = 0; i < sizeof(GAMEMODES); i++)
	{
		g_bGameMode[i] = false;
		if (StrEqual(GAMEMODES[i], sGamemode)) g_bGameMode[i] = true;
	}
}