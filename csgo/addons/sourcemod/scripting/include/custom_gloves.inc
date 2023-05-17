#if defined _custom_gloves_included_
	#endinput
#endif
#define _custom_gloves_included_

public SharedPlugin __pl_custom_gloves =
{
	name = "custom_gloves",
	file = "custom_gloves.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public void __pl_custom_gloves_SetNTVOptional()
{
	MarkNativeAsOptional("Custom_RemoveGloves");
}

/**
 *
 *
 *
 * @param client 	The client index to remove custom gloves.
 *
 * @noreturn
 *
 */

native Custom_RemoveGloves(int client);