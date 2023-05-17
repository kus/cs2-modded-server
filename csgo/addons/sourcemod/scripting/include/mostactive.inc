#if defined _mostactive_included_
	#endinput
#endif
#define _mostactive_included_


public SharedPlugin __pl_mostactive =
{
	name = "mostactive",
	file = "mostactive.smx",
	
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public void __pl_mostactive_SetNTVOptional()
{
	MarkNativeAsOptional("MostActive_GetPlayTimeT");
	MarkNativeAsOptional("MostActive_GetPlayTimeCT");
	MarkNativeAsOptional("MostActive_GetPlayTimeSpec");
	MarkNativeAsOptional("MostActive_GetPlayTimeTotal");
}
#endif


/*********************************************************
 * Called when a new player will be written to db
 *
 * @param client		the new client that will be added
 * @NoReturn
 *********************************************************/
forward void MostActive_OnInsertNewPlayer(int client);


/*********************************************************
 * Return the playtime of the client in a team
 *
 * @Return				PlayTime as CT in seconds
 *********************************************************/
native int MostActive_GetPlayTimeCT(int client);


/*********************************************************
 * Return the playtime of the client in a team
 *
 * @Return				PlayTime as T in seconds
 *********************************************************/
native int MostActive_GetPlayTimeT(int client);


/*********************************************************
 * Return the playtime of the client in a team
 *
 * @Return				PlayTime as Spec in seconds
 *********************************************************/
native int MostActive_GetPlayTimeSpec(int client);


/*********************************************************
 * Return the playtime of the client in all teams
 *
 * @Return				Total PlayTime as CT, T & Spec in seconds
 *********************************************************/
native int MostActive_GetPlayTimeTotal(int client);