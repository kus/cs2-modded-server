/** Double-include prevention */
#if defined _left4loading_included_
  #endinput
#endif
#define _left4loading_included_

public SharedPlugin:__pl_l4l = 
{
	name = "left4loading",
	file = "left4loading.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public __pl_l4l_SetNTVOptional()
{
	MarkNativeAsOptional("IsReadyUpActive");
	MarkNativeAsOptional("IsReadyUpAboutToEnd");
	MarkNativeAsOptional("GetReadyUpCountdown");
}

/**
 * Returns whether Left 4 Loading is still in ready up.
 * 
 * @return				True if still in ready up, false if not.
 */
native bool:IsReadyUpActive();

/**
 * Returns whether Left 4 Loading's ready up is about to end 
 * (in countdown).
 * 
 * @return				True if ready up is ending soon, false if not.
 */
native bool:IsReadyUpAboutToEnd();

/**
 * Get the countdown for ready up before round begins.
 * 
 * @return				How many seconds to round start, -1 if no timer is running.
 */
native GetReadyUpCountdown();

/**
 * Called when ready up starts.
 * 
 * @noreturn
 */
forward OnReadyUpStart();

/**
 * Called when ready up is about to end.
 * 
 * @noreturn
 */
forward OnReadyUpAboutToEnd();

/**
 * Called when ready up ended.
 * 
 * @noreturn
 */
forward OnReadyUpEnd();

/**
 * Called when the first client have loaded.
 * 
 * @noreturn
 */
forward OnFirstClientLoaded();

/**
 * Called when all clients have loaded, or when Left 4 Loading decides to move 
 * on.
 * 
 * @param allClientsLoaded Boolean for whether all clients loaded in the ready
 *							up time or l4l force started the next state.
 * @noreturn
 */
forward OnAllClientsLoaded(bool:allClientsLoaded);