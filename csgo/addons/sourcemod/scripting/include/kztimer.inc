#if defined _KZTimer_included
 #endinput
#endif
#define _KZTimer_included

enum Jumptype {
	Jumptype_None = 0,
	Jumptype_Longjump,
	Jumptype_Bhop,
	Jumptype_Multihop,
	Jumptype_Weirdjump,
	Jumptype_Drophop,
	Jumptype_Countjump,
	Jumptype_Ladderjump,
	Jumptype_BlockLJ
}

enum Jumpcolor{
	Jumpcolor_None = 0,
	Jumpcolor_Perfect,
	Jumpcolor_Impressive,
	Jumpcolor_Godlike,
	Jumpcolor_Ownage
}

/* Natives */
native bool:KZTimer_GetTimerStatus(client); // returns (bool) timer status
native KZTimer_StopTimer(client); // stops the timer
native KZTimer_StopUpdatingOfClimbersMenu(client); // stops refreshing of the timer panel/menu
native KZTimer_EmulateStartButtonPress(client); // start button alternative
native KZTimer_EmulateStopButtonPress(client); // stop button alternative
native Float:KZTimer_GetCurrentTime(client); //returns (float) current run time
native Float:KZTimer_GetAvgTimeTp(); //avg tp time - returns (float) 0.0 if less than 5 map times (kztimer calculates the avg time on mapstart and if someone set a new time) 
native Float:KZTimer_GetAvgTimePro(); //avg pro time - returns (float) 0.0 if less than 5 map times (kztimer calculates the avg time on mapstart and if someone set a new time)
native KZTimer_GetSkillGroup(client); // skill group - returns (int) 0=NORANK, 1=NEWB,2=SCRUB,..,9=PRO 
native KZTimer_GetVersion();
native void KZTimer_GetVersion_Desc(char[] buffer, int size);
//KZTimer_GetSkillGroup can be helpful to set up a high ranked only server. This server has to share the database with your 'main' kztimer server

/**
 * Called when the timer is started.
 *
 * @param client that starts the timer.
 *
 * @noreturn
 */
forward KZTimer_TimerStarted(client);

/**
 * Called when the timer is stopped.
 *
 * @param client that stops the timer.
 * @param teleports
 * @param finish time
 * @param server record(1 = true)
 *
 * @noreturn
 */
forward KZTimer_TimerStopped(client, teleports, Float:time, record);

/**
 * Called when the timer is stopped.
 *
 * @note This is only called if the run is saved.
 *
 * @param client that stops the timer.
 * @param teleports
 * @param rank
 * @param finish time
 *
 * @noreturn
 */
forward KZTimer_TimerStoppedValid(client, teleports, rank, Float:time);

/**
 * Called when a jump with potential jumpstats starts
 *
 * @note
 *
 * @param client that jumps.
 * @param
 * @param
 * @param
 *
 * @noreturn
 */
forward KZTimer_OnJumpstatStarted(client);

/**
 * Called when a jumpstat is completed.
 *
 * @note This is only called if the jumpstat is valid and above normal.
 *
 * @param client that stops the timer.
 * @param jumpstat type (LJ, Bhop, etc)
 * @param distance
 *
 * @noreturn
 */
forward KZTimer_OnJumpstatCompleted(client, jumptype, jumpcolor, float distance, bool personalbest);

/**
 * Called when a jump is invalidated
 *
 * @note
 *
 * @param client that jumps.
 * @param
 * @param
 * @param
 *
 * @noreturn
 */
forward KZTimer_OnJumpstatInvalid(client);


public SharedPlugin:__pl_KZTimer =
{
	name = "KZTimer",
	file = "KZTimer.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public __pl_KZTimer_SetNTVOptional()
{
	MarkNativeAsOptional("KZTimer_GetTimerStatus");
	MarkNativeAsOptional("KZTimer_StopTimer");
	MarkNativeAsOptional("KZTimer_StopUpdatingOfClimbersMenu");
	MarkNativeAsOptional("KZTimer_EmulateStartButtonPress");	
	MarkNativeAsOptional("KZTimer_EmulateStopButtonPress");
	MarkNativeAsOptional("KZTimer_GetCurrentTime");
	MarkNativeAsOptional("KZTimer_GetAvgTimeTp");
	MarkNativeAsOptional("KZTimer_GetAvgTimePro");
	MarkNativeAsOptional("KZTimer_GetSkillGroup");
	MarkNativeAsOptional("KZTimer_GetVersion");
	MarkNativeAsOptional("KZTimer_GetVersion_Desc");
}