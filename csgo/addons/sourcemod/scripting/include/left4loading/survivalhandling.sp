/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			survivalhandling.sp
 *  Type:			Module
 *  Description:	Handles survival maps.
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

static	const	String:	NETPROP_SPAWNFLAGS[]			= "m_spawnflags";

static 					OFFSET_SPAWNFLAGS 				= 0;

static	const			SPAWNFLAG_IGNOREUSE 			= -32768; // Spawn flag of "IGNORE_USE", found through hammer and testing

static					g_iForceOpenTime				= 60; // How many seconds after ready up ended we force the game to begin and door to open.
static					g_iForceOpenCountdown			= 0; // Used to countdown
static	const	String:	DIRECTOR_FORCE_SUR_START[]		= "director_force_panic_event";

// **********************************************
//                   Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _DoorHandling_OnPluginStart()
{
	OFFSET_SPAWNFLAGS = FindSendPropInfo(SERVERCLASS_CHECKPOINT, NETPROP_SPAWNFLAGS);
	OFFSET_LOCKED = FindSendPropInfo(SERVERCLASS_CHECKPOINT, NETPROP_LOCKED);

	HookReadyUpEvent(READYUP_EVENT_START, _DH_OnReadyUpStart);
	HookReadyUpEvent(READYUP_EVENT_END, _DH_OnReadyUpEnd);

	SetConVarInt(FindConVar(FORCE_START_TIME_CVAR), FORCE_START_TIME);
	HookConVarChange(FindConVar(FORCE_START_TIME_CVAR), _DH_ForceStartTime_CvarChange);
}

/**
 * On plugin end.
 *
 * @noreturn
 */
public _DoorHandling_OnPluginEnd()
{
	UnhookConVarChange(FindConVar(FORCE_START_TIME_CVAR), _DH_ForceStartTime_CvarChange);
	ResetConVar(FindConVar(FORCE_START_TIME_CVAR));
	UnlockCheckpointDoor(GetCheckpointDoor());
}

/**
 * Force start time cvar changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _DH_ForceStartTime_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SetConVarInt(convar, FORCE_START_TIME);
}

/**
 * On ready up start.
 *
 * @noreturn
 */
public _DH_OnReadyUpStart()
{
	CreateTimer(0.1, _DH_OnReadyUpStart_Timer, _, TIMER_FLAG_NO_MAPCHANGE); // We find the checkpoint door later to make sure that custom mapping can place one for us to find first
}

/**
 * Called when ready up start interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_DH_OnReadyUpStart_Timer(Handle:timer)
{
	g_iCheckpointDoor = 0;
	new door = FindCheckpointDoor();

	if (door && (IsCoop() || IsVersus()))
	{
		LockCheckpointDoor(door);
		g_iCheckpointDoor = EntIndexToEntRef(door);
	}
}

/**
 * On ready up end.
 *
 * @noreturn
 */
public _DH_OnReadyUpEnd()
{
	UnlockCheckpointDoor(GetCheckpointDoor());

	if (IsVersus())
	{
		g_iForceOpenCountdown = g_iForceOpenTime;
		CreateTimer(1.0, _DH_ForceOpen_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

/**
 * Called when force open interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop to stop a repeating timer, any other value for
 *						default behavior.
 */
public Action:_DH_ForceOpen_Timer(Handle:timer)
{
	if (InReadyUpMode())
	{
		g_iForceOpenCountdown = 0;
		return Plugin_Stop;
	}
	if (g_iForceOpenCountdown > -1)
	{
		g_iForceOpenCountdown--;
		return Plugin_Continue;
	}

	g_iForceOpenCountdown = 0;
	ForceGameToStart();
	CreateTimer(g_fCheckIfDoorIsStuck, _DH_CheckIfStuckDoor_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

/**
 * Called when check if door is stuck interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop to stop a repeating timer, any other value for
 *						default behavior.
 */
public Action:_DH_CheckIfStuckDoor_Timer(Handle:timer)
{
	if (InReadyUpMode()) return;
	new door = GetCheckpointDoor();
	if (door && IsValidEntity(door) && IsCheckpointDoorLocked(door)) 
	{
		RemoveEdict(door);
		g_iCheckpointDoor = 0;
	}
}

/**
 * On remove door command.
 *
 * @param client		Client id that performed the command.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_DH_RemoveDoor_Command(client, args)
{
	if (InReadyUpMode())
	{
		ReplyToCommand(client, "[%s] Still in ready up, wait til the timer runs out...", PLUGIN_TAG);
		return Plugin_Handled;
	}

	_DH_OnReadyUpEnd();
	new doorEntity = GetCheckpointDoor();
	if (doorEntity && IsValidEntity(doorEntity)) 
	{
		RemoveEdict(doorEntity); // Remove checkpoint door
		g_iCheckpointDoor = 0;
	}

	return Plugin_Handled;
}

// **********************************************
//                 Public API
// **********************************************

/**
 * Returns checkpoint door entity index. Entity index may be invalid!
 *
 * @return				Entity index of checkpoint door, 0 if not found.
 */
stock GetCheckpointDoor()
{
	return EntRefToEntIndex(g_iCheckpointDoor);
}

/**
 * Checks if the checkpoint door is locked.
 *
 * @return				True if door is locked, false if not locked or invalid door entity.
 */
stock bool:IsCheckpointDoorLocked(door)
{
	if (!door || !IsValidEntity(door)) return false;
	return bool:GetEntData(door, OFFSET_LOCKED, 1);
}

// **********************************************
//                 Private API
// **********************************************

/**
 * Find checkpoint door entity.
 *
 * @return				Entity index of checkpoint door, 0 if not found.
 */
static FindCheckpointDoor()
{
	new ent = -1;
	while ((ent = FindEntityByClassnameEx(ent, CLASSNAME_CHECKPOINT)) != -1)
	{
		if (!IsValidEntity(ent)) continue;
		if (!bool:GetEntData(ent, OFFSET_LOCKED, 1)) continue;
		return ent;
	}
	return 0;
}

/**
 * Lock checkpoint door.
 * 
 * @param doorEntity	Entity index of the checkpoint door.
 * @noreturn
 */
static LockCheckpointDoor(doorEntity)
{
	if (doorEntity < 1 || doorEntity > MAX_ENTITIES || !IsValidEntity(doorEntity)) return;
	SetEntData(doorEntity,
		OFFSET_SPAWNFLAGS,
		GetEntData(doorEntity, OFFSET_SPAWNFLAGS) | SPAWNFLAG_IGNOREUSE,
		_,
		true);
}

/**
 * Unlock checkpoint door.
 * 
 * @param doorEntity	Entity index of the checkpoint door.
 * @noreturn
 */
static UnlockCheckpointDoor(doorEntity)
{
	if (doorEntity < 1 || doorEntity > MAX_ENTITIES || !IsValidEntity(doorEntity)) return;
	SetEntData(doorEntity,
		OFFSET_SPAWNFLAGS,
		GetEntData(doorEntity, OFFSET_SPAWNFLAGS) ^ SPAWNFLAG_IGNOREUSE,
		_,
		true);
}

/**
 * Forces the game to start and open the door.
 * 
 * @noreturn
 */
static ForceGameToStart()
{
	new client = GetAnyClient(true);
	if (!client) client = SERVER_INDEX;

	// Remove the cheat flag from the force versus start command and execute it
	new flags = GetCommandFlags(DIRECTOR_FORCE_VS_START);
	if (flags & FCVAR_CHEAT) SetCommandFlags(DIRECTOR_FORCE_VS_START, flags ^ FCVAR_CHEAT);
	if (client == SERVER_INDEX)
	{
		ServerCommand(DIRECTOR_FORCE_VS_START);
	}
	else
	{
		FakeClientCommand(client, DIRECTOR_FORCE_VS_START);
	}
	SetCommandFlags(DIRECTOR_FORCE_VS_START, flags);
}