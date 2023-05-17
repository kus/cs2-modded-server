/*
**
*/
#if defined _SimpleStats_included
 #endinput
#endif
#define _SimpleStats_included

/**
 * Retrieve the amount of kills.
 *
 * @param client					Client index.
 * @return                          Amount of kills.
 */
native int SS_GetKillsAmount(int client);

/**
 * Retrieve the amount of deaths.
 *
 * @param client					Client index.
 * @return                          Amount of deaths.
 */
native int SS_GetDeathsAmount(int client);

/**
 * Retrieve the amount of shots.
 *
 * @param client					Client index.
 * @return                          Amount of shots.
 */
native int SS_GetShotsAmount(int client);

/**
 * Retrieve the amount of hits.
 *
 * @param client					Client index.
 * @return                          Amount of hits.
 */
native int SS_GetHitsAmount(int client);

/**
 * Retrieve the amount of headshots.
 *
 * @param client					Client index.
 * @return                          Amount of headshots.
 */
native int SS_GetHeadshotsAmount(int client);

/**
 * Retrieve the amount of assists.
 *
 * @param client					Client index.
 * @return                          Amount of assists.
 */
native int SS_GetAssistsAmount(int client);

/**
 * Retrieve the total amount of seconds played on the server.
 *
 * @param client					Client index.
 * @return                          Amount of seconds played.
 */
native int SS_GetPlayTimeAmount(int client);


public SharedPlugin __pl_SimpleStats =
{
	name = "SimpleStats",
	file = "SimpleStats.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};
