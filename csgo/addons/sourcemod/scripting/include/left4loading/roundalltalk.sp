/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			roundalltalk.sp
 *  Type:			Module
 *  Description:	Enables all talk on round end.
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

// **********************************************
//                 Variables
// **********************************************

// --------------------
//       Private
// --------------------

static			Handle:	g_hAllTalkCvar = INVALID_HANDLE;
static			Handle:	g_hTagsCvar = INVALID_HANDLE;

static			bool:	g_bEnableOnRoundStart = false;
static			bool:	g_bEnableOnRoundEnd = false;
static			Float:	g_fRoundStartWait = 1.5;
static			Float:	g_fRoundEndWait = 1.5;

static			bool:	g_bIsModuleChangingCvar = false;
static			bool:	g_bIsAllTalkAdminChanged = false;
static			bool:	g_bCanOverride = false;

static			String:	g_sOnSound[] = "ui/menu_enter05.wav";
static			String:	g_sOffSound[] = "ui/pickup_misc42.wav";

// **********************************************
//                 Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _RoundAllTalk_OnPluginStart()
{
	g_hAllTalkCvar = FindConVar("sv_alltalk");
	g_hTagsCvar = FindConVar("sv_tags");
	HookConVarChange(g_hAllTalkCvar, _RAT_AllTalk_ConVarChanged);

	HookReadyUpEvent(READYUP_EVENT_START, _SH_OnReadyUpStart);
	HookEvent("round_end", _RAT_RoundEnd_Event);
	HookEvent("round_start", _RAT_RoundStart_Event);
	HookEvent("player_left_start_area", _RAT_PlayerLeftStartArea_Event);
}

/**
 * On plugin end.
 *
 * @noreturn
 */
public _RoundAllTalk_OnPluginEnd()
{
	UnhookConVarChange(g_hAllTalkCvar, _RAT_AllTalk_ConVarChanged);
	SetAllTalk(false);
}

/**
 * Called on map start.
 *
 * @noreturn
 */
public _RoundAllTalk_OnMapStart()
{
	PrecacheSound(g_sOnSound, true);
	PrecacheSound(g_sOffSound, true);
	SetAllTalk(true);
}

/**
 * Called on map end.
 *
 * @noreturn
 */
public _RoundAllTalk_OnMapEnd()
{
	SetAllTalk(false);
}

/**
 * Called when a console variable's value is changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _RAT_AllTalk_ConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(g_bIsModuleChangingCvar) // If it was this module that changed all talk
	{
		g_bIsModuleChangingCvar = false; // Ignore the change
		return;
	}

	if(GetConVarBool(convar) && !g_bCanOverride)
	{
		g_bIsAllTalkAdminChanged = true;
	}
	else
	{
		g_bIsAllTalkAdminChanged = false;
	}
}

/**
 * Called the ready up start.
 *
 * @noreturn
 */
public _RAT_OnReadyUpStart()
{
	SetAllTalk(true);
}

/**
 * Called on round start.
 *
 * @param event			Handle to event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast	True if event was not broadcast to clients, false otherwise.
 * @noreturn
 */
public _RAT_RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bEnableOnRoundStart && IsAllTalkOn())
	{
		SetAllTalk(false);
		return;
	}

	SetAllTalk(true);

	if(g_fRoundStartWait > 0.0)
	{
		CreateTimer(g_fRoundStartWait, _RAT_RoundStart_Timer);
	}
}

/**
 * Called when the round start timer interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop.
 */
public Action:_RAT_RoundStart_Timer(Handle:timer)
{
	SetAllTalk(false);
	return Plugin_Stop;
}

/**
 * Called on round start.
 *
 * @param event			Handle to event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast	True if event was not broadcast to clients, false otherwise.
 * @noreturn
 */
public _RAT_RoundEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bEnableOnRoundEnd) return;

	if(g_fRoundEndWait > 0.0)
	{
		CreateTimer(g_fRoundEndWait, _RAT_RoundEnd_Timer);
	}
	else
	{
		SetAllTalk(true);
	}
}

/**
 * Called when the round end timer interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop.
 */
public Action:_RAT_RoundEnd_Timer(Handle:timer)
{
	SetAllTalk(true);
	return Plugin_Stop;
}

/**
 * Called on player left start area.
 *
 * @param event			Handle to event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast	True if event was not broadcast to clients, false otherwise.
 * @noreturn
 */
public _RAT_PlayerLeftStartArea_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	SetAllTalk(false);
}

// **********************************************
//                 Private API
// **********************************************

/**
 * Returns whether or not all talk is on
 * 
 * @return				True if all talk is on, false otherwise.
 */
static bool:IsAllTalkOn()
{
	return GetConVarBool(g_hAllTalkCvar);
}

/**
 * Sets all talk silently.
 * 
 * @param enabled		Whether or not all talk is enabled.
 * @noreturn
 */
static SetAllTalk(bool:enabled)
{
	if (IsCoop()) return; // Do not change all talk in coop
	if (g_bIsAllTalkAdminChanged && !g_bCanOverride) return;
	if (IsAllTalkOn() == enabled) return;

	new alltalkFlags = GetConVarFlags(g_hAllTalkCvar);
	new tagsFlags = GetConVarFlags(g_hTagsCvar);

	SetConVarFlags(g_hAllTalkCvar, alltalkFlags & ~FCVAR_NOTIFY);
	SetConVarFlags(g_hTagsCvar, tagsFlags & ~FCVAR_NOTIFY);

	g_bIsModuleChangingCvar = true;
	SetConVarBool(g_hAllTalkCvar, enabled);

	PrintToChatAll("\x01* All talk is now %s%s\x01!", (enabled ? "\x05" : "\x04"), (enabled ? "enabled" : "disabled"));
	EmitSoundToAll((enabled ? g_sOnSound : g_sOffSound));

	SetConVarFlags(g_hAllTalkCvar, alltalkFlags);
	SetConVarFlags(g_hTagsCvar, tagsFlags);
}