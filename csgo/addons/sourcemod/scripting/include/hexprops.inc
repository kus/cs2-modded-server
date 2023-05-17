//
// My library
//

#if defined _hexprops_included
	#endinput
#endif
#define _hexprops_included

/*
 * Called when a client press '+use' on a prop (any distance).
 *
 * @param client		Client Index.
 * @param entity		Entity Index of the pressed prop.
 * @noreturn
 */
forward void OnClientPressProp(int client, int entity);

/*
 *	Returns if a entity is from HexProps.
 *
 *  @param entity		Entity Index
 *  @return				True if the entity comes from HexProps plugin, false otherwise.
 */
native bool IsEntProp(int entity) 

public SharedPlugin __pl_hexprops_library =
{
	name = "hexprops",
	file = "hexprops.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};








