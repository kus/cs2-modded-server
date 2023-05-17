/**
 * vim: set ts=4 :
 * =============================================================================
 * Left 4 Downtown 2 SourceMod Extension
 * Copyright (C) 2010 Michael "ProdigySim" Busby
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */
 
 #if defined _l4d2timers_included
  #endinput
#endif
#define _l4d2timers_included

enum L4D2CountdownTimer
{
	L4D2CT_MobSpawnTimer,
	L4D2CT_SmokerSpawnTimer,
	L4D2CT_BoomerSpawnTimer,
	L4D2CT_HunterSpawnTimer,
	L4D2CT_SpitterSpawnTimer,
	L4D2CT_JockeySpawnTimer,
	L4D2CT_ChargerSpawnTimer,
	L4D2CT_VersusStartTimer,
	L4D2CT_UpdateMarkersTimer
};

enum L4D2IntervalTimer
{
	L4D2IT_SmokerDeathTimer,
	L4D2IT_BoomerDeathTimer,
	L4D2IT_HunterDeathTimer,
	L4D2IT_SpitterDeathTimer,
	L4D2IT_JockeyDeathTimer,
	L4D2IT_ChargerDeathTimer
};

/**
 * @brief Resets a given CountdownTimer (start again with same duration)
 * @remarks Equivalent to Start(timer, GetCountdownDuration(timer))
 * 
 * @param timer 		CountdownTimer to reset
 * @noreturn 				
 */
native L4D2_CTimerReset(L4D2CountdownTimer:timer);

/**
 * @brief Starts a given CountdownTimer with a given duration
 * @remarks This sets a new duration and sets up the end timestamp
 * 
 * @param timer 		CountdownTimer to start
 * @param duration		Duration for the timer to use
 * @noreturn 				
 */
native L4D2_CTimerStart(L4D2CountdownTimer:timer, Float:duration);

/**
 * @brief Invalidates a given CountdownTimer (Timer essentially does not run)
 * @remarks Sets the timestamp to -1.0f
 * 
 * @param timer 		CountdownTimer to Invalidate
 * @noreturn 				
 */
native L4D2_CTimerInvalidate(L4D2CountdownTimer:timer);

/**
 * @brief Tells if a given CountdownTimer has started
 * @remarks Checks to see if the end timestamp is greater than 0.0f
 * 
 * @param timer 		CountdownTimer to check
 * @return 				true if timer has started, false if timer is not started/invalid.
 */
native bool:L4D2_CTimerHasStarted(L4D2CountdownTimer:timer);

/**
 * @brief Tells if a given CountdownTimer is elapsed
 * @remarks If a timer is "up," e.g duration has passed since Start(), this returns true;
 * 
 * @param timer 		CountdownTimer to check
 * @return 				true if timer has elapsed or timer invalid/not started, false otherwise
 */
native bool:L4D2_CTimerIsElapsed(L4D2CountdownTimer:timer);

/**
 * @brief Gets elapsed time of a given CountdownTimer, from the timed it was Start()ed
 * @remarks Value is (Now() - timestamp) + duration
 * 
 * @param timer 		CountdownTimer to get elapsed time of
 * @return 				Float amount of time since timer started
 */
native Float:L4D2_CTimerGetElapsedTime(L4D2CountdownTimer:timer);

/**
 * @brief Gets remaining time on a given CountdownTimer
 * @remarks Value is (timestamp - Now())
 * 
 * @param timer 		CountdownTimer to get remaining time of
 * @return 				Float amount of time remaining on the timer
 */
native Float:L4D2_CTimerGetRemainingTime(L4D2CountdownTimer:timer);

/**
 * @brief Gets the duration of a given CountdownTimer
 * @remarks Value is (timestamp > 0.0f ? duration : 0.0f)
 * 
 * @param timer 		CountdownTimer to get duration of
 * @return 				0.0 for invalid/not started timers, timer duration otherwise.
 */
native Float:L4D2_CTimerGetCountdownDuration(L4D2CountdownTimer:timer);

/*************************************
	IntervalTimer Natives 
	***********************************/

/**
 * @brief Starts a given IntervalTimer
 * @remarks Just sets timestamp = Now(), so counting starts from now
 * 
 * @param timer 		IntervalTimer to start
 * @noreturn 				
 */
native L4D2_ITimerStart(L4D2IntervalTimer:timer);

/**
 * @brief Invalidates a given IntervalTimer
 * @remarks Just sets timestamp = -1.0f
 * 
 * @param timer 		IntervalTimer to Invalidate
 * @noreturn 				
 */
native L4D2_ITimerInvalidate(L4D2IntervalTimer:timer);

/**
 * @brief Tells whether a given IntervalTimer has started
 * @remarks Checks to see if timestamp > 0.0f
 * 
 * @param timer 		IntervalTimer to check
 * @return 				true if timer is started, false if it is invalid/not started
 */
native bool:L4D2_ITimerHasStarted(L4D2IntervalTimer:timer);
	
/**
 * @brief Gets the elapsed time of a given IntervalTimer
 * @remarks Value is Now() - Timestamp
 * 
 * @param timer 		IntervalTimer to get elapsed time of
 * @return				Elapsed time if timer started and valid, 99999.9f otherwise
 */
native Float:L4D2_ITimerGetElapsedTime(L4D2IntervalTimer:timer);
