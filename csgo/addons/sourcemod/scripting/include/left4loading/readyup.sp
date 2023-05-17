/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *	File:			readyup.sp
 *	Type:			Module
 *	Description:	Handles the ready up events and forwards.
 *
 *	Copyright (C) 2010  Mr. Zero <mrzerodk@gmail.com>
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
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
//       Public
// --------------------

/*
 * Event types
 * This defines which events is availble for modules to hook.
 */
enum READYUP_EVENTS
{
	READYUP_EVENT_START,
	READYUP_EVENT_END,
	READYUP_EVENT_ABOUTTOEND
}

// --------------------
//       Private
// --------------------

static			bool:	g_bInReadyUp				= false;
static			bool:	g_bIsReadyUpAboutToEnd		= false;
static					g_iCountdown				= -1;

static			Handle:	g_hGFwd_OnReadyUpStart		= INVALID_HANDLE;
static			Handle:	g_hGFwd_OnReadyUpAboutToEnd	= INVALID_HANDLE;
static			Handle:	g_hGFwd_OnReadyUpEnd		= INVALID_HANDLE;

static			Handle:	g_hFwd_OnReadyUpStart		= INVALID_HANDLE;
static			Handle:	g_hFwd_OnReadyUpAboutToEnd	= INVALID_HANDLE;
static			Handle:	g_hFwd_OnReadyUpEnd			= INVALID_HANDLE;

// **********************************************
//					  Natives
// **********************************************

/**
 * Native function for IsReadyUpActive. Returns whether Left 4 Loading is 
 * still in ready up mode.
 * 
 * @param plugin		Handle to calling plugin.
 * @param numParams		Number of parameters.
 * @return				True if still in ready up mode, false otherwise.
 */
public Native_IsReadyUpActive(Handle:plugin, numParams)
{
	return _:g_bInReadyUp;
}

/**
 * Native function for IsReadyUpAboutToEnd. Returns whether Left 4 Loading's
 * ready up mode is about to end (in countdown).
 * 
 * @param plugin		Handle to calling plugin.
 * @param numParams		Number of parameters.
 * @return				True if ready up mode is about to end, false otherwise.
 */
public Native_IsReadyUpAboutToEnd(Handle:plugin, numParams)
{
	return _:g_bIsReadyUpAboutToEnd;
}

/**
 * Native function for GetReadyUpCountdown. Returns how many seconds left
 * before the round starts.
 * 
 * @param plugin		Handle to calling plugin.
 * @param numParams		Number of parameters.
 * @return				How many seconds to round start, -1 if no timer is running.
 */
public Native_GetReadyUpCountdown(Handle:plugin, numParams)
{
	return _:g_iCountdown;
}

// **********************************************
//					  Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _ReadyUp_OnPluginStart()
{
	g_hGFwd_OnReadyUpStart = CreateGlobalForward("OnReadyUpStart", ET_Ignore);
	g_hGFwd_OnReadyUpAboutToEnd = CreateGlobalForward("OnReadyUpAboutToEnd", ET_Ignore);
	g_hGFwd_OnReadyUpEnd = CreateGlobalForward("OnReadyUpEnd", ET_Ignore);

	g_hFwd_OnReadyUpStart = CreateForward(ET_Ignore);
	g_hFwd_OnReadyUpAboutToEnd = CreateForward(ET_Ignore);
	g_hFwd_OnReadyUpEnd = CreateForward(ET_Ignore);

	#if defined DEBUG
	RegAdminCmdEx("debug_setreadyup", _RU_SetReadyUp_Command, ADMFLAG_ROOT, "Sets ready up state. Valid options: start, end, abouttoend");
	#endif
}

/**
 * On map start.
 *
 * @noreturn
 */
public _ReadyUp_OnMapStart()
{
	g_iCountdown = -1;
}

/**
 * Called when ready up countdown interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_RU_Countdown_Timer(Handle:timer)
{
	if (!g_bInReadyUp || !g_bIsReadyUpAboutToEnd) // If no longer in ready up (some module changed state)
	{
		g_iCountdown = -1;
		return Plugin_Stop;
	}
	if (g_iCountdown > 0)
	{
		g_iCountdown--;
		return Plugin_Continue;
	}
	g_iCountdown = -1;
	SetReadyUpState(READYUP_EVENT_END);
	return Plugin_Continue;
}

#if defined DEBUG
public Action:_RU_SetReadyUp_Command(client, args)
{
	decl String:buffer[32];
	GetCmdArg(1, buffer, sizeof(buffer));
	if (StrEqual(buffer, "start"))
	{
		PrintToChat(client, "Set ready up state to start");
		SetReadyUpState(READYUP_EVENT_START);
	}
	else if (StrEqual(buffer, "end"))
	{
		PrintToChat(client, "Set ready up state to end");
		SetReadyUpState(READYUP_EVENT_END);
	}
	else if (StrEqual(buffer, "abouttoend"))
	{
		PrintToChat(client, "Set ready up state to about to end");
		SetReadyUpState(READYUP_EVENT_ABOUTTOEND);
	}
	else
	{
		PrintToChat(client, "Valid options: start, end, abouttoend");
	}
	return Plugin_Handled;
}
#endif

// **********************************************
//                 Public API
// **********************************************

/**
 * Adds a function to the forward of selected ready up event.
 * 
 * @param type			The type of event to forward.
 * @param func			The function to add.
 * @return				True on success, false otherwise.
 */
stock bool:HookReadyUpEvent(const READYUP_EVENTS:type, Function:func)
{
	new Handle:fwd = INVALID_HANDLE;
	if (type == READYUP_EVENT_START)
	{
		fwd = g_hFwd_OnReadyUpStart;
	}
	else if (type == READYUP_EVENT_END)
	{
		fwd = g_hFwd_OnReadyUpEnd;
	}
	else if (type == READYUP_EVENT_ABOUTTOEND)
	{
		fwd = g_hFwd_OnReadyUpAboutToEnd;
	}
	if (fwd == INVALID_HANDLE) return false; // Invalid selection

	return AddToForward(fwd, INVALID_HANDLE, func);
}

/**
 * Removes a function from the forward of selected event type.
 * 
 * @param type			The type of event to forward.
 * @param func			The function to remove.
 * @return				True on success, false otherwise.
 */
stock bool:UnhookReadyUpEvent(const READYUP_EVENTS:type, Function:func)
{
	new Handle:fwd = INVALID_HANDLE;
	if (type == READYUP_EVENT_START)
	{
		fwd = g_hFwd_OnReadyUpStart;
	}
	else if (type == READYUP_EVENT_END)
	{
		fwd = g_hFwd_OnReadyUpEnd;
	}
	else if (type == READYUP_EVENT_ABOUTTOEND)
	{
		fwd = g_hFwd_OnReadyUpAboutToEnd;
	}
	if (fwd == INVALID_HANDLE) return false; // Invalid selection

	return RemoveFromForward(fwd, INVALID_HANDLE, func);
}

/**
 * Removes a function from the forward of selected event type.
 * 
 * @param readyState	Sets current ready up state.
 * @noreturn
 */
stock SetReadyUpState(READYUP_EVENTS:readyState)
{
	new Handle:fwd = INVALID_HANDLE;
	new Handle:gFwd = INVALID_HANDLE;

	if (readyState == READYUP_EVENT_START && !InReadyUpMode())
	{
		fwd = g_hFwd_OnReadyUpStart;
		gFwd = g_hGFwd_OnReadyUpStart;
		g_bInReadyUp = true;
		g_bIsReadyUpAboutToEnd = false;
	}
	else if (readyState == READYUP_EVENT_END && InReadyUpMode())
	{
		fwd = g_hFwd_OnReadyUpEnd;
		gFwd = g_hGFwd_OnReadyUpEnd;
		g_bInReadyUp = false;
		g_bIsReadyUpAboutToEnd = false;
	}
	else if (readyState == READYUP_EVENT_ABOUTTOEND && !IsReadyUpAboutToEnd())
	{
		fwd = g_hFwd_OnReadyUpAboutToEnd;
		gFwd = g_hGFwd_OnReadyUpAboutToEnd;
		g_bInReadyUp = true;
		g_bIsReadyUpAboutToEnd = true;
	}

	if (fwd == INVALID_HANDLE) return; // Invalid selection

	Call_StartForward(fwd);
	Call_Finish();
	Call_StartForward(gFwd);
	Call_Finish();
}

/**
 * Starts a timer to count down until we ready up.
 * 
 * @param time			How many seconds before round begins.
 * @param extend		Set to true if you want to add time if a timer is
 *						already running.
 * @return				True if successfully started timer or added time, false otherwise
 */
stock bool:StartReadyUpCountDown(time, bool:extend)
{
	if (!g_bInReadyUp || (g_iCountdown != -1 && !extend)) return false;

	if (g_iCountdown != -1) 
	{
		g_iCountdown += time;
		return true;
	}

	SetReadyUpState(READYUP_EVENT_ABOUTTOEND);
	g_iCountdown = time;
	CreateTimer(1.0, _RU_Countdown_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	return true;
}

/**
 * Adds time to ready up countdown.
 * 
 * @param time			Seconds to add to countdown.
 * @return				True if added, false if no timer is active.
 */
stock bool:AddTimeToReadyUp(time)
{
	if (g_iCountdown == -1) return false;
	g_iCountdown += time;
	return true;
}

/**
 * Check whether we are still in ready up mode.
 * 
 * @return				True if still in ready up mode, false if not.
 */
stock bool:InReadyUpMode() return g_bInReadyUp;

/**
 * Check whether ready up mode is about to end.
 * 
 * @return				True if its about to end, false if not.
 */
stock bool:IsReadyUpAboutToEnd() return g_bIsReadyUpAboutToEnd;

/**
 * Get the countdown for ready up before round begins.
 * 
 * @return				How many seconds to round start, -1 if no timer is running.
 */
stock GetReadyUpCountdown() return g_iCountdown;