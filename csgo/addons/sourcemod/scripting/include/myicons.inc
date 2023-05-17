#if defined _myicons_included
  #endinput
#endif
#define _myicons_included


public SharedPlugin:__pl_myicons =
{
	name = "myicons",
	file = "myicons.smx",

	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public __pl_myicons_SetNTVOptional()
{
	MarkNativeAsOptional("MyIcons_BlockClientIcon");
}
#endif

/*********************************************************
 * Block the players icon bool
 *
 * @param client		The client to block icon
 * @param status		true or false
 * @NoReturn
 *********************************************************/
native MyIcons_BlockClientIcon(int client, bool status);
