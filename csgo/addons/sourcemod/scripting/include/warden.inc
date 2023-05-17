#if defined _warden_included
  #endinput
#endif
#define _warden_included


public SharedPlugin __pl_warden =
{
	name = "warden",
	file = "warden.smx",

	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};


#if !defined REQUIRE_PLUGIN
public __pl_warden_SetNTVOptional()
{
	MarkNativeAsOptional("warden_exist");
	MarkNativeAsOptional("warden_iswarden");
	MarkNativeAsOptional("warden_set");
	MarkNativeAsOptional("warden_remove");
}
#endif


/*********************************************************
 * Called everytime the warden position become free.
 * On wardens dead, disconnect, removed...
 * 
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenRemoved(int client);


/*********************************************************
 * Called when a client become warden
 * By player, admin, randomchoose...
 *
 * @param client		The client who become warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenCreated(int client);



/*********************************************************
 * Checks if any warden exist
 *
 *
 * @return 				true on match, false if not
 *********************************************************/
native bool warden_exist();


/*********************************************************
 * returns if client is warden
 *
 * @param client		The client to run the check on
 * @return				true on match, false if not
 *********************************************************/
native bool warden_iswarden(int client);


/*********************************************************
 * Set a client as warden
 *
 * @param client		The client to set as warden
 * @param caller		The client who set the new warden
 * @NoReturn
 *********************************************************/
native void warden_set(int client, int caller);


/*********************************************************
 * Removes the current warden if he exists
 *
 * @param client		The warden client to remove
 * @NoReturn
 *********************************************************/
native void warden_remove(int client);