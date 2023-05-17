/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			gamemode.sp
 *  Type:			State helper
 *  Description:	Provides functions to see which gamemode is currently 
 *					active.
 *
 *  Copyright (C) 2010  Mr. Zero <mrzerodk@gmail.com>
 *  This file is part of Left 4 Loading.
 *
 *  Left 4 Loading is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Left 4 Loading is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Left 4 Loading.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/*
 * ==================================================
 *                    Preprocessor
 * ==================================================
 */

#define TOTAL_GAMEMODES 8

/*
 * ==================================================
 *                     Reference
 * ==================================================
 */

enum GameModes
{
	GameMode_Coop = 0,
	GameMode_Versus,
	GameMode_TeamVersus,
	GameMode_Survival,
	GameMode_SurvivalVersus,
	GameMode_Realism,
	GameMode_RealismVersus,
	GameMode_Scavenge
}

/*
 * ==================================================
 *                     Variables
 * ==================================================
 */

/*
 * --------------------
 *       Private
 * --------------------
 */

static	const	String:	GAMEMODE_CVAR[] = "mp_gamemode";
static			bool:	g_bIsGameMode[TOTAL_GAMEMODES];

static	const	String:	g_szGameModes[TOTAL_GAMEMODES][] = 
{
	/* IMPORTANT! Remember to put these as in the same order as the enum above! */
	"coop",			// Coop
	"versus",		// Versus
	"teamversus",	// Team Versus
	"survival",		// Survival
	"mutation15",	// Survival Versus
	"realism",		// Realism
	"mutation12",	// Realism Versus
	"scavenge"		// Scavenge
};

/*
 * ==================================================
 *                     Forwards
 * ==================================================
 */

/**
 * Called on plugin start.
 *
 * @noreturn
 */
public _GameMode_OnPluginStart()
{
	new Handle:cvar = FindConVar(GAMEMODE_CVAR);
	HookConVarChange(cvar, _GM_ConVarChange);

	decl String:buffer[128];
	GetConVarString(cvar, buffer, 128);
	_GM_ConVarChange(cvar, "", buffer);
}

/**
 * Called when gamemode value is changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _GM_ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	for (new i = 0; i < TOTAL_GAMEMODES; i++)
	{
		g_bIsGameMode[i] = false;
		if (StrEqual(g_szGameModes[i], newValue)) g_bIsGameMode[i] = true;
	}
}

/*
 * ==================================================
 *                     Public API
 * ==================================================
 */

/**
 * Return whether or not the game mode is Coop or any mutation of Coop.
 * 
 * @return				True if Coop, false otherwise.
 */
stock bool:IsGameModeCoop()
{
	return (g_bIsGameMode[GameMode_Coop] || 
			g_bIsGameMode[GameMode_Realism] ||
			g_bIsGameMode[GameMode_Survival]);
}

/**
 * Return whether or not the game mode is Versus or any mutation of Versus.
 * 
 * @return				True if Versus, false otherwise.
 */
stock bool:IsGameModeVersus()
{
	return bool:g_bIsGameMode[GameMode_Versus];
}

/**
 * Return whether or not the game mode is Realism or any mutation of Realism.
 * 
 * @return				True if Realism, false otherwise.
 */
stock bool:IsGameModeRealism()
{
	return (g_bIsGameMode[GameMode_Realism] ||
			g_bIsGameMode[GameMode_RealismVersus]);
}

/**
 * Return whether or not the game mode is Survival or any mutation of Survival.
 * 
 * @return				True if Survival, false otherwise.
 */
stock bool:IsGameModeSurvival()
{
	return bool:g_bIsGameMode[GameMode_SurvivalVersus];
}

/**
 * Return whether or not the game mode is Scavenge or any mutation of Scavenge.
 * 
 * @return				True if Scavenge, false otherwise.
 */
stock bool:IsGameModeScavenge()
{
	/* God this is weird, for some reason I get a tag mismatch on this return.
	 * Variable is bool, so I have no clue whats wrong. Function is tagged as
	 * bool. Anyway, easy to fix */
	return bool:g_bIsGameMode[GameMode_Scavenge];
}

/**
 * Return whether or not the given game mode is active.
 * 
 * @param gamemode		Game mode to check for.
 * @return				True if active, false otherwise.
 */
stock bool:IsGameMode(GameModes:gamemode)
{
	return (g_bIsGameMode[gamemode]);
}

/**
 * Return whether or not the given game mode is active.
 * 
 * @param gamemode		Game mode string to check for.
 * @return				True if active, false otherwise.
 */
stock bool:IsGameModeString(const String:gamemode[])
{
	for (new i = 0; i < TOTAL_GAMEMODES; i++)
	{
		if (StrEqual(g_szGameModes[i], gamemode) && g_bIsGameMode[i]) return true;
	}
	return false;
}