/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			playerhandling.sp
 *  Type:			Module
 *  Description:	Handle loading players and set ready up state acoording.
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

static			bool:	g_bIsClientLoading[MAXPLAYERS+1]	= {true};
static			bool:	g_bIsFirstRound						= true;
static			bool:	g_bFirstClientHasLoaded				= false;
static			bool:	g_bJustLoaded						= true;

static					g_iPrepareTime_1stRound				= 60;
static					g_iPrepareTime_2ndRound				= 30;

static			Float:	g_fMinWaitForLoadTime				= 15.0;
static			Float:	g_fMaxWaitForLoadTime				= 60.0;
static	const	Float:	CHECK_FOR_LOADING_CLIENTS_TIME		= 1.0;

static	const	String:	GFWD_ONFIRSTCLIENTLOADED_NAME[]		= "OnFirstClientLoaded";
static			Handle:	g_hGFwd_OnFirstClientLoaded			= INVALID_HANDLE;
static	const	String:	GFWD_ONALLCLIENTSLOADED_NAME[]		= "OnAllClientsLoaded";
static			Handle:	g_hGFwd_OnAllClientsLoaded			= INVALID_HANDLE;

static			bool:	g_bHaveMapStartRun					= false;
static			bool:	g_bIsEventHooked_PlayerActivate		= false;

// **********************************************
//                 Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _PlayerHandling_OnPluginStart()
{
	HookEvent("round_start", _PH_RoundStart_Event, EventHookMode_PostNoCopy);
}

/**
 * On map start.
 *
 * @noreturn
 */
public _PlayerHandling_OnMapStart()
{
	/* Creation of global forwards */
	if (g_hGFwd_OnFirstClientLoaded != INVALID_HANDLE)
	{
		CloseHandle(g_hGFwd_OnFirstClientLoaded);
		g_hGFwd_OnFirstClientLoaded = INVALID_HANDLE;
	}
	g_hGFwd_OnFirstClientLoaded = CreateGlobalForward(GFWD_ONFIRSTCLIENTLOADED_NAME, ET_Ignore);
	if (g_hGFwd_OnFirstClientLoaded == INVALID_HANDLE) ThrowError("Failed to create global forward: OnFirstClientLoaded");

	if (g_hGFwd_OnAllClientsLoaded != INVALID_HANDLE)
	{
		CloseHandle(g_hGFwd_OnAllClientsLoaded);
		g_hGFwd_OnAllClientsLoaded = INVALID_HANDLE;
	}
	g_hGFwd_OnAllClientsLoaded = CreateGlobalForward(GFWD_ONALLCLIENTSLOADED_NAME, ET_Ignore, Param_Cell);
	if (g_hGFwd_OnAllClientsLoaded == INVALID_HANDLE) ThrowError("Failed to create global forward: OnAllClientsLoaded");

	/* Check for loading clients */
	for (new client = FIRST_CLIENT; client <= MaxClients; client++)
	{
		if (!IsClientConnected(client) || !IsClientInGame(client) || IsFakeClient(client)) continue;
		g_bIsClientLoading[client] = false;
		if (!g_bFirstClientHasLoaded) // Global forward, OnFirstClientLoaded
		{
			Call_StartForward(g_hGFwd_OnFirstClientLoaded);
			Call_Finish(g_hGFwd_OnFirstClientLoaded);
		}
		g_bFirstClientHasLoaded = true;
	}
	if (!g_bIsEventHooked_PlayerActivate)
	{
		HookEvent("player_activate", _PH_PlayerActivate_Event);
		g_bIsEventHooked_PlayerActivate = true;
	}

	g_bHaveMapStartRun = true;

	// To prevent ready up starting when reloading plugin or late load
	if (g_bJustLoaded)
	{
		g_bJustLoaded = false;
		if (!HasAnySurvivorLeftSafeArea())
		{
			StartReadyUp();
		}
		else
		{
			g_bIsFirstRound = false;
		}
		return;
	}

	StartReadyUp();
}

/**
 * On map end.
 *
 * @noreturn
 */
public _PlayerHandling_OnMapEnd()
{
	if (g_bIsEventHooked_PlayerActivate)
	{
		UnhookEvent("player_activate", _PH_PlayerActivate_Event);
		g_bIsEventHooked_PlayerActivate = false;
	}
	g_bHaveMapStartRun = false;
	g_bIsFirstRound = true;
	g_bFirstClientHasLoaded = false;
	for (new i = FIRST_CLIENT; i <= MaxClients; i++) g_bIsClientLoading[i] = true; // Set all clients as loading
	SetReadyUpState(READYUP_EVENT_END); // End ready up mode
}

/**
 * Called on player activate.
 *
 * @param event			Handle to event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast	True if event was not broadcast to clients, false otherwise.
 * @noreturn
 */
public _PH_PlayerActivate_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || IsFakeClient(client)) return;
	g_bIsClientLoading[client] = false; // Client is no longer loading
	if (!g_bFirstClientHasLoaded) // Global forward, OnFirstClientLoaded
	{
		Call_StartForward(g_hGFwd_OnFirstClientLoaded);
		Call_Finish(g_hGFwd_OnFirstClientLoaded);
	}
	g_bFirstClientHasLoaded = true; // First client has now loaded
}

/**
 * Called when round start event is fired.
 *
 * @param event			INVALID_HANDLE, post no copy data.
 * @param name			String containing the name of the event.
 * @param dontBroadcast	True if event was not broadcast to clients, false otherwise.
 * @noreturn
 */
public _PH_RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bHaveMapStartRun) return;
	StartReadyUp();
}

/**
 * Called when check loading clients interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_PH_CheckLoadingClients_Timer(Handle:timer)
{
	static Float:curWaitTime = -1.0;

	if (!g_bFirstClientHasLoaded &&		// If first client havent loaded yet
		InReadyUpMode() &&				// and we are still in readup mode
		GetClientCountEx(false, true))	// and there is still players on the server
		return Plugin_Continue;			// continue

	if (curWaitTime == -1.0) curWaitTime = CHECK_FOR_LOADING_CLIENTS_TIME;
	curWaitTime += CHECK_FOR_LOADING_CLIENTS_TIME;

	if (curWaitTime <= g_fMinWaitForLoadTime ||
		(curWaitTime <= g_fMaxWaitForLoadTime &&
		GetLoadingPlayers() > 0))
		return Plugin_Continue;

	curWaitTime = -1.0;

	/* Global Forward, On all clients loaded */
	Call_StartForward(g_hGFwd_OnAllClientsLoaded);
	Call_PushCell((GetLoadingPlayers() == 0 ? true : false));
	Call_Finish(g_hGFwd_OnAllClientsLoaded);

	AboutToEndReadyUp();

	return Plugin_Stop;
}

// **********************************************
//                 Private API
// **********************************************

/**
 * Starts ready up.
 * 
 * @noreturn
 */
static StartReadyUp()
{
	if (InReadyUpMode() || (!IsVersus() && !IsCoop())) return; // If in ready up already or neither versus or coop, return

	SetReadyUpState(READYUP_EVENT_START);

	if (g_bIsFirstRound) // If first round on map
	{
		CreateTimer(CHECK_FOR_LOADING_CLIENTS_TIME, _PH_CheckLoadingClients_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		return;
	}

	AboutToEndReadyUp();
}

/**
 * Sets ready up to about to end and starts countdown.
 * 
 * @noreturn
 */
static AboutToEndReadyUp()
{
	SetReadyUpState(READYUP_EVENT_ABOUTTOEND); // Set ready up mode to about to end

	new time = (g_bIsFirstRound ? g_iPrepareTime_1stRound : g_iPrepareTime_2ndRound);
	g_bIsFirstRound = false;

	StartReadyUpCountDown(time, false);
}

/**
 * Returns number of clients that are currently loading.
 *
 * @return				Count of loading clients.
 */
static GetLoadingPlayers()
{
	new counter;
	for (new client = FIRST_CLIENT; client <= MaxClients; client++)
	{
		if (!IsClientConnected(client) || 
			IsFakeClient(client) || 
			IsClientInGame(client) ||
			!g_bIsClientLoading[client])
			continue;
		counter++;
	}
	return counter;
}