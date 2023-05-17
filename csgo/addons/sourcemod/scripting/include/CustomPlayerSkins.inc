//Custom Player Skins include file

#if defined _CustomPlayerSkins_included
 #endinput
#endif
#define _CustomPlayerSkins_included

#define CPS_NOFLAGS         0
#define CPS_RENDER          (1 << 0) //Does not make the model invisible. (useful for glows) (used on RemoveSkin it will not force the player's render back to Normal.)
#define CPS_NOATTACHMENT    (1 << 1) //Does not 'SetParentAttachment' variant. (Useful for non-bone merging)
#define CPS_IGNOREDEATH     (1 << 2) //This will prevent the removal of the skin on death.

/**
 * Sets the client's skin from the given path.
 *
 * @param client	Client index
 * @param model		User input for model path
 * @param flags		flags are used to determine what this function does and does not do.
 * @noreturn 
 * @error			Invalid client.
 */
native CPS_SetSkin(client, String:model[], flags);

/**
 * Gets the client's skin entity reference.
 *
 * @param client	Client index
 * @return 			Returns the entity reference of the player's skin, INVALID_ENT_REFERENCE if there is no skin.
 * @error			Invalid client.
 */
native CPS_GetSkin(client);

/**
 * Simple check if the client already has a skin.
 *
 * @param client	Client index
 * @return 			Returns if the client has a skin currently. (will not check if the player is alive, etc.)
 * @error			Invalid client.
 */
native bool:CPS_HasSkin(client);

/**
 * Removes and resets the player and their skin.
 *
 * @param client	Client index
 * @noreturn
 * @error			Invalid client.
 */
native CPS_RemoveSkin(client, flags = CPS_NOFLAGS);


/**
 * Sets the client's transmit variable (see below)
 * NOTE: Check if the player is between 0 and MAXPLAYERS.
 *
 * @param owner		Client index of the skin's owner
 * @param client	Client index of the player that will see the skin.
 * @param transmit	0 - Do not transmit at all.
					1 - Transmit only if other cases pass.
					2 - Override other checks.
 * @noreturn 
 * @error			Invalid client.
 */
native CPS_SetTransmit(owner, client, transmit);


/**
 * Simple native to return the skin's flags
 * NOTE: Check if the player is between 0 and MAXPLAYERS.
 *
 * @param client	Client index
 * @return 			Returns the client index's skin flags.
 */
native CPS_GetFlags(client);

public SharedPlugin:__pl_CustomPlayerSkins =
{
	name = "CustomPlayerSkins",
	file = "CustomPlayerSkins.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_CustomPlayerSkins_SetNTVOptional()
{
	MarkNativeAsOptional("CPS_SetSkin");
	MarkNativeAsOptional("CPS_GetSkin");
	MarkNativeAsOptional("CPS_HasSkin");
	MarkNativeAsOptional("CPS_RemoveSkin");
	MarkNativeAsOptional("CPS_SetTransmit");
	MarkNativeAsOptional("CPS_GetFlags");
}
#endif
