/**
 * Check if a player playing in a dead game.
 *
 * @param client            client index
 * 
 * @return			        True or false.
 */
native bool DeadGames_IsOnGame(client);

/**
 * Check if a player playing in DM dead game.
 *
 * @param client            client index
 * 
 * @return			        True or false.
 */
native bool DeadGames_IsOnDM(client);

/**
 * Check if a player playing in BHOP dead game.
 *
 * @param client            client index
 * 
 * @return			        True or false.
 */
native bool DeadGames_IsOnBhop(client);


#if defined _franug_deadgames_included_
	#endinput
#endif
#define _franug_deadgames_included_


public SharedPlugin __pl_franug_deadgames =
{
	name = "franug_deadgames",
	file = "franug_deadgames.smx",

	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public void __pl_franug_deadgames_SetNTVOptional()
{
	MarkNativeAsOptional("DeadGames_IsOnGame");
	MarkNativeAsOptional("DeadGames_IsOnDM");
	MarkNativeAsOptional("DeadGames_IsOnBhop");
}
#endif
