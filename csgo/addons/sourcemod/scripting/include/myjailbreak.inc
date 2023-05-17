/*
 * MyJailbreak - Include File.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


// Defines
#define MYJB_VERSION "Beta 9.1.dev-<COMMIT>"
#define MYJB_URL_LINK "https://github.com/shanapu/MyJailbreak"


#if defined _myjailbreak_included_
	#endinput
#endif
#define _myjailbreak_included_


public SharedPlugin:__pl_myjailbreak =
{
	name = "myjailbreak",
	file = "myjailbreak.smx",
	
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public __pl_myjailbreak_SetNTVOptional()
{
	MarkNativeAsOptional("MyJailbreak_SetEventDayName");
	MarkNativeAsOptional("MyJailbreak_GetEventDayName");
	MarkNativeAsOptional("MyJailbreak_SetEventDayRunning");
	MarkNativeAsOptional("MyJailbreak_IsEventDayRunning");
	MarkNativeAsOptional("MyJailbreak_SetEventDayPlanned");
	MarkNativeAsOptional("MyJailbreak_IsEventDayPlanned");

	MarkNativeAsOptional("MyJailbreak_SetLastGuardRule");
	MarkNativeAsOptional("MyJailbreak_IsLastGuardRule");

	MarkNativeAsOptional("MyJailbreak_ActiveLogging");

	MarkNativeAsOptional("MyJailbreak_FogOn");
	MarkNativeAsOptional("MyJailbreak_FogOff");

	MarkNativeAsOptional("MyJailbreak_BeaconOn");
	MarkNativeAsOptional("MyJailbreak_BeaconOff");
}
#endif



/*****************************************************************************
                   FORWARDS
******************************************************************************/

/*********************************************************
 * Called when a client trys to join the Guards(CT) or GuardQueue
 *
 * @param status		Client ID
 * @return 				Return Plugin_Handled to block & Plugin_Continue to pass the client.
 *********************************************************/
forward Action MyJailbreak_OnJoinGuardQueue(int client);


/*********************************************************
 * Called when a the Last Guard Rule is active
 * 
 * @NoReturn
 *********************************************************/
forward void MyJailbreak_OnLastGuardRuleStart();



/*********************************************************
 * Called when a eventday has started
 *
 * @param EventDayName	The name of the event day
 * @NoReturn
 *********************************************************/
forward void MyJailbreak_OnEventDayStart(char[] EventDayName);


/*********************************************************
 * Called when a eventday has ended
 *
 * @param EventDayName	The name of the event day
 * @param winner		The winner team of this eventday. 0/1 = no winner
 * @NoReturn
 *********************************************************/
forward void MyJailbreak_OnEventDayEnd(char[] EventDayName, int winner);



/******************************************************************************
                   NATIVES
******************************************************************************/


/*********************************************************
 * Set the name of the planned/running Event Day
 *
 * @param name			The name of the Event Day
 * @NoReturn
 *********************************************************/
native void MyJailbreak_SetEventDayName(const char[] name);


/*********************************************************
 * Get the name of the planned/running Event Day
 *
 *
 * @Return				The name of the Event Day
 *********************************************************/
native void MyJailbreak_GetEventDayName(char[] name);


/*********************************************************
 * Set Boolean Event Day is running
 *
 * @param status		Boolean is running (true = running)
 * @param winner		Winning team when event day ends
 * @NoReturn
 *********************************************************/
native void MyJailbreak_SetEventDayRunning(bool status, int winner);


/*********************************************************
 * Check bool Event Day is running
 *
 *
 * @Return			true on running, false if not
 *********************************************************/
native bool MyJailbreak_IsEventDayRunning();


/*********************************************************
 * Set Boolean Event Day is planned
 *
 * @param status		Boolean is planned (true = running)
 * @NoReturn
 *********************************************************/
native void MyJailbreak_SetEventDayPlanned(bool status);


/*********************************************************
 * Check bool Event Day is planned
 *
 *
 * @Return			true on planned, false if not
 *********************************************************/
native bool MyJailbreak_IsEventDayPlanned();


/*********************************************************
 * Set Boolean Last Guard Rule is active
 *
 * @param status		Boolean is active (true = active)
 * @NoReturn
 *********************************************************/
native void MyJailbreak_SetLastGuardRule(bool status);


/*********************************************************
 * Check bool Last Guard Rule is active
 *
 *
 * @Return			true on active, false if not
 *********************************************************/
native bool MyJailbreak_IsLastGuardRule();


/*********************************************************
 * Check bool is logging active
 *
 *
 * @Return			true on active, false if not
 *********************************************************/
native bool MyJailbreak_ActiveLogging();


/*********************************************************
 * Set map fog
 *
 *
 * @noreturn
 *********************************************************/
native void MyJailbreak_FogOn();


/*********************************************************
 * Remove a map fog
 *
 *
 * @noreturn
 *********************************************************/
native void MyJailbreak_FogOff();


/*********************************************************
 * Set client Beacon
 *
 *
 * @noreturn
 *********************************************************/
native void MyJailbreak_BeaconOn(int client, float interval);


/*********************************************************
 * Remove client Beacon (auto remove on mapend/playerdeath/roundend)
 *
 *
 * @noreturn
 *********************************************************/
native void MyJailbreak_BeaconOff(int client);