#if defined _myweapons_included
  #endinput
#endif
#define _myweapons_included


public SharedPlugin:__pl_myweapons =
{
	name = "weapons",
	file = "weapons.smx",

	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public __pl_myweapons_SetNTVOptional()
{
	MarkNativeAsOptional("MyWeapons_AllowTeam");
}
#endif

/*********************************************************
 * Allow a team to pick weapons from weapons menu
 *
 * @param team		the team to allow/block weapons menu
 * @param status	true or false = allow or block
 * @NoReturn
 *********************************************************/
native void MyWeapons_AllowTeam(int client, bool status);

/*********************************************************
 * Get team status if weapons are allowed
 *
 * @param team		the team request
 * @true on allowed, false if blocked
 *********************************************************/
native bool MyWeapons_GetTeamStatus(int iTeam);
