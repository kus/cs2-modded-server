/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			waitmsghandling.sp
 *  Type:			Module
 *  Description:	Handles wait message to show to the survivors.
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

static			bool:	g_bInTipColddown[MAXPLAYERS+1] = {false};
static	const	Float:	RESET_TIP_TIME					= 8.5; // How long before showing the wait tip again

static	const	Float:	MAX_DOOR_DISTANCE				= 128.0; // Max distance from door to show tip
static	const	String:	LOCKED_SOUND[]					= "doors/latchlocked2.wav"; // Sound file for locked checkpoint door
static	const	Float:	RESET_SOUND_TIME				= 2.0; // How long before resetting the locked sound
static			bool:	g_bPlayedSoundRecently			= false; // If played the locked sound recently
static			Float:	g_vCheckpointDoor_Origin[3];

static	const			HINT_GAME_BEGUN_TIMEOUT			= 10; // How many seconds until hint kills itself

static	const	String:	CLASSNAME_INSTRUCTOR_HINT[] = "env_instructor_hint";

// **********************************************
//                 Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _WaitMsgHandling_OnPluginStart()
{
	HookReadyUpEvent(READYUP_EVENT_START, _WMH_OnReadyUpStart);
	HookReadyUpEvent(READYUP_EVENT_END, _WMH_OnReadyUpEnd);
	HookReadyUpEvent(READYUP_EVENT_ABOUTTOEND, _WMH_OnReadyUpAboutToEnd);
}

/**
 * On ready up start.
 *
 * @noreturn
 */
public _WMH_OnReadyUpStart()
{
	CreateTimer(0.1, _WMH_OnReadyUpStart_Timer);
}

/**
 * On ready up end.
 *
 * @noreturn
 */
public _WMH_OnReadyUpEnd()
{
	if (IsCoop()) return; // Don't print game has begun in coop
	new door = GetCheckpointDoor(), hint = -1;
	if (door != -1 && IsValidEntity(door))
	{
		hint = CreateInstructorHintAtTarget(door,
			_,
			"Game has begun!",
			"use",
			"use_binding",
			"icon_door",
			false,
			false,
			_,
			true,
			true,
			_,
			_,
			_,
			_,
			_,
			HINT_GAME_BEGUN_TIMEOUT,
			0);
	}
	else
	{
		new survivor = GetAnySurvivor(true);
		if (survivor)
		{
			hint = CreateInstructorHintAtTarget(survivor,
				_,
				"Game has begun!",
				_,
				"icon_info",
				"icon_info",
				false,
				true,
				_,
				true,
				false,
				_,
				_,
				_,
				_,
				_,
				HINT_GAME_BEGUN_TIMEOUT,
				0);
		}
	}

	if (hint != -1)
	{
		ShowInstructorHint(hint);
		CreateTimer(1.0, _WMH_KillHintUponExit_Timer, hint, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

/**
 * On ready up about to end.
 *
 * @noreturn
 */
public _WMH_OnReadyUpAboutToEnd()
{
	if (IsCoop()) return; // Don't show message in coop
	CreateTimer(1.0, _WMH_Countdown_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * On map start.
 *
 * @noreturn
 */
public _WaitMsgHandling_OnMapStart()
{
	// Precache locked door sound
	PrecacheSound(LOCKED_SOUND);
}

/**
 * Called when ready up start interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_WMH_OnReadyUpStart_Timer(Handle:timer)
{
	new door = GetCheckpointDoor();
	if (door == 0) return;
	GetEntityAbsOrigin(door, g_vCheckpointDoor_Origin);
}

/**
 * Called when countdown interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_WMH_Countdown_Timer(Handle:timer)
{
	static hint = -1;

	if (hint != -1)
	{
		KillInstructorHint(hint);
		hint = -1;
	}

	new time = GetReadyUpCountdown();
	if (time < 1) return Plugin_Stop;

	decl String:caption[128];
	Format(caption, sizeof(caption), "Game begins in %i seconds", time);

	new door = GetCheckpointDoor();
	if (door && IsValidEntity(door))
	{
		hint = CreateInstructorHintAtTarget(door,
			_,
			caption,
			_,
			"icon_alert",
			"icon_alert",
			false,
			false,
			_,
			true,
			true,
			_,
			_,
			_,
			_,
			_,
			0,
			0);
	}
	else
	{
		new survivor = GetAnySurvivor();
		if (survivor)
		{
			hint = CreateInstructorHintAtTarget(survivor,
				_,
				caption,
				_,
				"icon_alert",
				"icon_alert",
				false,
				true,
				_,
				true,
				true,
				_,
				50,
				_,
				_,
				_,
				0,
				0);
		}
	}

	if (hint != -1) ShowInstructorHint(hint);

	return Plugin_Continue;
}

/**
 * Called when kill hint upon exit interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_WMH_KillHintUponExit_Timer(Handle:timer, any:hint)
{
	if (!HasAnySurvivorLeftSafeArea()) return Plugin_Continue;
	KillInstructorHint(hint);
	return Plugin_Stop;
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
public Action:_WaitMsgHandling_OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!InReadyUpMode() ||
		IsFakeClient(client) ||
		GetClientTeam(client) != TEAM_SURVIVOR)
		return Plugin_Continue;

	if (IsSurvivorsFrozen())
	{
		if (!g_bInTipColddown[client] &&
			(buttons & IN_JUMP ||		// If in jump
			buttons & IN_FORWARD ||		// Or walking forward
			buttons & IN_BACK ||		// Or in back
			buttons & IN_MOVELEFT ||	// Or moving left
			buttons & IN_MOVERIGHT))	// Or moving right
		{
			ShowWaitTipToClient(client);
			g_bInTipColddown[client] = true;
			CreateTimer(RESET_TIP_TIME, _WMH_ResetTip_Timer, client);
		}
	}
	else if (buttons & IN_USE)
	{
		new door = GetCheckpointDoor();
		new target = GetClientAimTarget(client, false);
		if (target == door && door != 0)
		{
			decl Float:origin[3];
			GetClientAbsOrigin(client, origin);
			if (GetVectorDistance(origin, g_vCheckpointDoor_Origin) <= MAX_DOOR_DISTANCE)
			{
				if (!g_bPlayedSoundRecently)
				{
					// Play cue and start reset timer
					EmitSoundToAll(LOCKED_SOUND, door);
					g_bPlayedSoundRecently = true;
					CreateTimer(RESET_SOUND_TIME, _WMH_ResetSound_Timer);
				}

				if (!g_bInTipColddown[client] && !IsReadyUpAboutToEnd())
				{
					ShowWaitTipToClient(client, door);
					g_bInTipColddown[client] = true;
					CreateTimer(RESET_TIP_TIME, _WMH_ResetTip_Timer, client);
				}
			}
		}
	}
	return Plugin_Continue;
}

/**
 * Called when reset tip interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @param client        Client index to reset.
 * @noreturn
 */
public Action:_WMH_ResetTip_Timer(Handle:timer, any:client)
{
	g_bInTipColddown[client] = false;
}

/**
 * Called when reset sound interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @noreturn
 */
public Action:_WMH_ResetSound_Timer(Handle:timer)
{
	g_bPlayedSoundRecently = false;
}

// **********************************************
//                 Private API
// **********************************************

/**
 * Return any ingame survivor client.
 *
 * @param filterBots	If false bots are also returned.
 * @return				Client index of an ingame survivor client.
 */
static GetAnySurvivor(bool:filterBots = true)
{
	for (new client = FIRST_CLIENT; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || 
			(IsFakeClient(client) && filterBots) || 
			GetClientTeam(client) != TEAM_SURVIVOR) 
			continue;
		return client;
	}
	return 0;
}

/**
 * Creates an event with the matching gamemode, to fake a wait message for the
 *  client.
 * 
 * @param client		Client index to show the event for.
 * @param doorEntity	Optional: the entity index of the door client tried to 
 *						open. If not provided, entity index will be the client.
 * @noreturn
 */
static ShowWaitTipToClient(client, doorEntity = 0)
{
	new Handle:event = INVALID_HANDLE;

	if (IsVersus())
	{
		event = CreateEvent("waiting_door_used_versus", true);
	}
	else if (IsCoop())
	{
		event = CreateEvent("waiting_checkpoint_door_used", true);
	}

	if (event == INVALID_HANDLE) return;
	if (doorEntity == 0) doorEntity = client;

	SetEventInt(event, "userid", GetClientUserId(client));
	SetEventInt(event, "entindex", doorEntity);
	FireEvent(event);
}

/**
 * Creates a instructor hint at specific entity index.
 * 
 * @param target		Entity index of the target.
 * @param name			Name of hint.
 * @param caption		The text of the hint.
 * @param binding		If using 'show key bindings' for the onscreen icon, 
 *						this field should be the command we want to show 
 *						bindings for.
 * @param iconOnScreen	Icon string when on screen.
 * @param iconOffScreen	Icon string when off screen.
 * @param autoStart		When the player first sees it, it will automatically
 *						show for them.
 * @param isStatic		Either show at the position of the Target Entity. 
 *						Or show the hint directly on the hud at a fixed 
 *						position.
 * @param allowNoDrawTarget	Do we allow the hint to follow entites with nodraw 
 *						set?
 * @param forceCaption	Do we show the caption text even if the hint is 
 *						occluded by a wall?
 * @param showOffscreen	When the hint is offscreen, do we show an icon and 
 *						arrow?
 * @param color			The color of the caption text.
 * @param iconOffset	A height offset from the target entity's origin to 
 *						display the hint.
 * @param pulseOption	The icon size can pulsate.
 * @param alphaOption	The icon alpha can pulsate.
 * @param shakeOption	The icon can shake.
 * @param timeout		The automatic timeout for the hint. 0 will persist
 *						until stopped with EndHint.
 * @param range			The visible range of the hint. 0 will show it at any 
 *						distance.
 * @return				Entity index of hint, -1 for error.
 */
static CreateInstructorHintAtTarget(target,
									const String:name[] = "",
									const String:caption[] = "",
									const String:binding[] = "",
									const String:iconOnScreen[] = "icon_tip",
									const String:iconOffScreen[] = "icon_tip",
									bool:autoStart = true,
									bool:isStatic = false,
									bool:allowNoDrawTarget = true,
									bool:forceCaption = false,
									bool:showOffscreen = true,
									color[3] = {255, 255, 255},
									iconOffset = 0,
									pulseOption = 0,
									alphaOption = 0,
									shakeOption = 0,
									timeout = 0,
									range = 0)
{
	decl String:targetName[128];
	Format(targetName, sizeof(targetName), "hint_%d", target);
	if (target < 1 || 
		target > MAX_ENTITIES || 
		!IsValidEntity(target) ||
		!DispatchKeyValue(target, "targetname", targetName))
		return -1;

	return CreateInstructorHint(targetName,
		name,
		caption,
		binding,
		iconOnScreen,
		iconOffScreen,
		autoStart,
		isStatic,
		allowNoDrawTarget,
		forceCaption,
		showOffscreen,
		color,
		iconOffset,
		pulseOption,
		alphaOption,
		shakeOption,
		timeout,
		range);
}

/**
 * Creates a instructor hint.
 * 
 * @param target		Target name.
 * @param name			Name of hint.
 * @param caption		The text of the hint.
 * @param binding		If using 'show key bindings' for the onscreen icon, 
 *						this field should be the command we want to show 
 *						bindings for.
 * @param iconOnScreen	Icon string when on screen.
 * @param iconOffScreen	Icon string when off screen.
 * @param autoStart		When the player first sees it, it will automatically
 *						show for them.
 * @param isStatic		Either show at the position of the Target Entity. 
 *						Or show the hint directly on the hud at a fixed 
 *						position.
 * @param allowNoDrawTarget	Do we allow the hint to follow entites with nodraw 
 *						set?
 * @param forceCaption	Do we show the caption text even if the hint is 
 *						occluded by a wall?
 * @param showOffscreen	When the hint is offscreen, do we show an icon and 
 *						arrow?
 * @param color			The color of the caption text.
 * @param iconOffset	A height offset from the target entity's origin to 
 *						display the hint.
 * @param pulseOption	The icon size can pulsate.
 * @param alphaOption	The icon alpha can pulsate.
 * @param shakeOption	The icon can shake.
 * @param timeout		The automatic timeout for the hint. 0 will persist
 *						until stopped with EndHint.
 * @param range			The visible range of the hint. 0 will show it at any 
 *						distance.
 * @return				Entity index of hint, -1 for error.
 */
static CreateInstructorHint(const String:target[],
						   const String:name[] = "", 
						   const String:caption[] = "",
						   const String:binding[] = "",
						   const String:iconOnScreen[] = "icon_tip",
						   const String:iconOffScreen[] = "icon_tip",
						   bool:autoStart = true,
						   bool:isStatic = false,
						   bool:allowNoDrawTarget = true,
						   bool:forceCaption = false,
						   bool:showOffscreen = true,
						   color[3] = {255, 255, 255},
						   iconOffset = 0,
						   pulseOption = 0,
						   alphaOption = 0,
						   shakeOption = 0,
						   timeout = 0,
						   range = 0)
{
	decl String:buffer[256], Handle:array;
	array = CreateArray(256);
	if (array == INVALID_HANDLE) return -1;

	new entity = CreateEntityByName(CLASSNAME_INSTRUCTOR_HINT);
	if (entity == -1)
	{
		CloseHandle(array);
		return -1;
	}

	PushArrayString(array, "hint_range");
	IntToString(range, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "targetname");
	PushArrayString(array, name);

	PushArrayString(array, "hint_allow_nodraw_target");
	IntToString(int:allowNoDrawTarget, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_shakeoption");
	IntToString(shakeOption, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_alphaoption");
	IntToString(alphaOption, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_auto_start");
	IntToString(int:autoStart, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_target");
	PushArrayString(array, target);

	PushArrayString(array, "hint_binding");
	PushArrayString(array, binding);

	PushArrayString(array, "hint_pulseoption");
	IntToString(pulseOption, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_caption");
	PushArrayString(array, caption);

	PushArrayString(array, "hint_timeout");
	IntToString(timeout, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_color");
	new String:finalizedColorString[32];
	for (new i = 0; i < 3; i++)
	{
		IntToString(color[i], buffer, sizeof(buffer));
		Format(finalizedColorString, sizeof(finalizedColorString), "%s %s", finalizedColorString, buffer);
	}
	TrimString(finalizedColorString);
	PushArrayString(array, finalizedColorString);

	PushArrayString(array, "hint_forcecaption");
	IntToString(int:forceCaption, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_static");
	IntToString(int:isStatic, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_nooffscreen");
	showOffscreen = !showOffscreen;
	IntToString(int:showOffscreen, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	PushArrayString(array, "hint_icon_offscreen");
	PushArrayString(array, iconOffScreen);

	PushArrayString(array, "hint_icon_onscreen");
	PushArrayString(array, iconOnScreen);

	PushArrayString(array, "hint_icon_offset");
	IntToString(int:iconOffset, buffer, sizeof(buffer));
	PushArrayString(array, buffer);

	decl String:key[256];
	new bool:setValueFail = false;
	for (new i = 0; i < GetArraySize(array); i += 2)
	{
		GetArrayString(array, i, key, sizeof(key));
		GetArrayString(array, i + 1, buffer, sizeof(buffer));
		if (!DispatchKeyValue(entity, key, buffer))
		{
			setValueFail = true;
			break;
		}
	}

	if (setValueFail || !DispatchSpawn(entity))
	{
		RemoveEdict(entity);
		entity = -1;
	}

	CloseHandle(array);
	return entity;
}

static ShowInstructorHint(hint)
{
	if (!IsValidHint(hint)) return;
	AcceptEntityInput(hint, "ShowHint");
}

static KillInstructorHint(hint)
{
	if (!IsValidHint(hint)) return;
	AcceptEntityInput(hint, "EndHint");
	AcceptEntityInput(hint, "Kill");
}

static bool:IsValidHint(hint)
{
	if (hint < FIRST_CLIENT || 
		hint > MAX_ENTITIES || 
		!IsValidEntity(hint)) 
		return false;

	decl String:classname[32];
	GetEdictClassname(hint, classname, sizeof(classname));
	return StrEqual(classname, CLASSNAME_INSTRUCTOR_HINT, false);
}