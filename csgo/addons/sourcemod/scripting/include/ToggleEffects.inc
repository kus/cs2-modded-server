/** Include File for Global Special Effects **/
#if defined _GlobalEffects_Included_
	#endinput
#endif
#define _GlobalEffects_Included_

public SharedPlugin:__pl_specialfx =
{
        name = "specialfx",
        file = "ToggleEffects.smx",
#if defined REQUIRE_PLUGIN
        required = 1,
#else
        required = 0,
#endif
};

public __pl_specialfx_SetNTVOptional()
{
        MarkNativeAsOptional("ShowClientEffects");
}

/**
 * Returns whether the client would like special effects on or off.
 *
 * @param client	The client index of the player
 * @return			True/False
 */
native bool:ShowClientEffects(client);
