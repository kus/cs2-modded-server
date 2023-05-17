/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			survivorhandling.sp
 *  Type:			Module
 *  Description:	Freezes survivors if needed.
 *
 *  Copyright (C) 2010  Mr. Zero <mrzerodk@gmail.com>
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

// --------------------
//       Private
// --------------------

static	const	Float:	FREEZE_SURVIVORS_INTERVAL		= 1.0;

static	const	String:	GOD_MODE_CVAR[]					= "god";
static			Handle:	g_hGodMode_Cvar					= INVALID_HANDLE;

static	const	String:	SB_STOP_CVAR[]					= "sb_stop";
static			Handle:	g_hSBStop_Cvar					= INVALID_HANDLE;

static			bool:	g_bIsSurvivorsFrozen			= false;
static			bool:	g_bForceFreezeState				= false;

// **********************************************
//                 Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _SurvivorHandling_OnPluginStart()
{
	HookReadyUpEvent(READYUP_EVENT_START, _SH_OnReadyUpStart);
	HookReadyUpEvent(READYUP_EVENT_END, _SH_OnReadyUpEnd);
	HookReadyUpEvent(READYUP_EVENT_ABOUTTOEND, _SH_OnReadyUpAboutToEnd);

	g_hGodMode_Cvar = FindConVar(GOD_MODE_CVAR);
	g_hSBStop_Cvar = FindConVar(SB_STOP_CVAR);
}

/**
 * On plugin end.
 *
 * @noreturn
 */
public _SurvivorHandling_OnPluginEnd()
{
	UnfreezeAllSurvivors();
	SetGodMode(false);
	SetBotState(true);
}

/**
 * On map end.
 *
 * @noreturn
 */
public _SurvivorHandling_OnMapEnd()
{
	SetGodMode(false);
}

/**
 * On ready up start.
 *
 * @noreturn
 */
public _SH_OnReadyUpStart()
{
	g_bIsSurvivorsFrozen = false;
	CreateTimer(FREEZE_SURVIVORS_INTERVAL, _SH_FreezeSurvivors_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	SetGodMode(true);
	SetBotState(false);
}

/**
 * On ready up end.
 *
 * @noreturn
 */
public _SH_OnReadyUpEnd()
{
	g_bForceFreezeState = false;
	UnfreezeAllSurvivors();
	SetGodMode(false);
	SetBotState(true);
}

/**
 * On ready up about to end.
 *
 * @noreturn
 */
public _SH_OnReadyUpAboutToEnd()
{
	SetBotState(true);
}

/**
 * Called when freeze survivors interval has elapsed.
 *
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop to stop a repeating timer, any other value for
 *						default behavior.
 */
public Action:_SH_FreezeSurvivors_Timer(Handle:timer)
{
	if (!InReadyUpMode()) return Plugin_Stop;
	new door = GetCheckpointDoor();
	if (!g_bForceFreezeState && door && IsValidEntity(door)) // No need to freeze survivors, door is locked
	{
		if (g_bIsSurvivorsFrozen) UnfreezeAllSurvivors(); // Unfeeze survivors if we have frozen them before
		return Plugin_Continue;
	}

	for (new client = FIRST_CLIENT; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) ||					// If not ingame
			GetClientTeam(client) != TEAM_SURVIVOR ||	// Or not a survivor
			!IsPlayerAlive(client))						// Or not alive
			continue;

		SetEntityMoveType(client, MOVETYPE_NONE);		// Freeze client
	}
	g_bIsSurvivorsFrozen = true;
	return Plugin_Continue;
}

// **********************************************
//                 Public API
// **********************************************

/**
 * Gets survivors freeze state.
 * 
 * @return				True if frozen, false otherwise.
 */
stock bool:IsSurvivorsFrozen() return g_bIsSurvivorsFrozen;

/**
 * Forces survivors to be frozen on ready up start.
 *
 * @param freeze		Whether or not survivors are frozen.
 * @noreturn
 */
stock ForceFreezeSurvivors(bool:freeze)
{
	g_bForceFreezeState = freeze;
}

// **********************************************
//                 Private API
// **********************************************

/**
 * Unfreeze all survivors.
 * 
 * @noreturn
 */
static UnfreezeAllSurvivors()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || 
			GetClientTeam(client) != TEAM_SURVIVOR || 
			!IsPlayerAlive(client)) 
			continue;

		SetEntityMoveType(client, MOVETYPE_CUSTOM); // Unfreeze client
	}
	g_bIsSurvivorsFrozen = false;
}

/**
 * Set god mode.
 * 
 * @param enable		Sets whether god mode is enable.
 * @noreturn
 */
static SetGodMode(bool:enable)
{
	new flags = GetConVarFlags(g_hGodMode_Cvar);
	if (flags & FCVAR_NOTIFY) SetConVarFlags(g_hGodMode_Cvar, flags ^ FCVAR_NOTIFY);
	SetConVarBool(g_hGodMode_Cvar, enable);
	SetConVarFlags(g_hGodMode_Cvar, flags);
}

/**
 * Set bot state.
 * 
 * @param enable		Sets whether bots are enable.
 * @noreturn
 */
static SetBotState(bool:enable)
{
	SetConVarBool(g_hSBStop_Cvar, !enable);
}