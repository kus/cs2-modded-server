/**
 * This is the include file for Custom Chat Colors
 * https://forums.alliedmods.net/showthread.php?t=186695
 * To check that Custom Chat Colors is installed and running, verify that the "ccc" library exists
 */

#if defined _ccc_included
  #endinput
#endif
#define _ccc_included

enum CCC_ColorType {
	CCC_TagColor,
	CCC_NameColor,
	CCC_ChatColor
};

#define COLOR_NONE		-1
#define COLOR_GREEN		-2
#define COLOR_OLIVE		-3
#define COLOR_TEAM		-4

/**
 * Gets a client's color as a hexadecimal integer.
 * 
 * @param client		Client index
 * @param type			Color type to retreive
 * @param alpha			Pass a boolean variable by reference here and it will be true if the color has alpha specified or false if it doesn't (or is a stock color)
 * @return				Color as a hexadecimal integer (use %X in formatting to get a hexadecimal string)
 * 
 * On error/errors:		Invalid client index or client is not in game
 */
native CCC_GetColor(client, CCC_ColorType:type, &bool:alpha = false);

/**
 * Sets a client's color as a hexadecimal integer.
 * 
 * @param client		Client index
 * @param type			Color type to set
 * @param color			Integer representation of the color (use StringToInt(input, 16) to convert a hexadecimal string) or one of the color defines
 * @param alpha			Are you specifying a color with alpha?
 * @return				True if the color is updated successfully, false otherwise
 * 
 * On error/errors:		Invalid client index or client is not in game
 */
native bool:CCC_SetColor(client, CCC_ColorType:type, color, bool:alpha);

/**
 * Gets a client's tag
 * 
 * @param client		Client index
 * @param buffer		Buffer to store the tag in
 * @param maxlen		Maximum buffer length
 * @noreturn
 * 
 * On error/errors:		Invalid client index or client is not in game
 */
native CCC_GetTag(client, String:buffer[], maxlen);

/**
 * Sets a client's tag
 * 
 * @param client		Client index
 * @param tag			String containing the new tag
 * @noreturn
 * 
 * On error/errors:		Invalid client index or client is not in game
 */
native CCC_SetTag(client, const String:tag[]);

/**
 * Resets a client's color to the value in the config file.
 * 
 * @param client		Client index
 * @param type			Color type to restore
 * @noreturn
 * 
 * On error/errors:		Invalid client index or client is not in game
 */
native CCC_ResetColor(client, CCC_ColorType:type);

/**
 * Resets a client's tag to the value in the config file.
 * 
 * @param client		Client index
 * @noreturn
 * 
 * On error/errors:		Invalid client index or client is not in game
 */
native CCC_ResetTag(client);

/**
 * Called when a cilent's name is about to be colored
 * DO NOT START A NEW USERMESSAGE (i.e. PrintToChat, PrintToChatAll) WITHIN THIS FORWARD
 * 
 * @param client		Client index
 * @return				Plugin_Handled to prevent coloring, Plugin_Continue to allow coloring
 */
#pragma deprecated Use CCC_OnColor instead
forward Action:CCC_OnNameColor(client);

/**
 * Called when a client's chat is about to be colored
 * DO NOT START A NEW USERMESSAGE (i.e. PrintToChat, PrintToChatAll) WITHIN THIS FORWARD
 * 
 * @param client		Client index
 * @return				Plugin_Handled to prevent coloring, Plugin_Continue to allow coloring
 */
#pragma deprecated Use CCC_OnColor instead
forward Action:CCC_OnChatColor(client);

/**
 * Called when a client's name is about to be tagged
 * DO NOT START A NEW USERMESSAGE (i.e. PrintToChat, PrintToChatAll) WITHIN THIS FORWARD
 * 
 * @param client		Client index
 * @return				Plugin_Handled to prevent tagging, Plugin_Continue to allow tagging
 */
#pragma deprecated Use CCC_OnColor instead
forward Action:CCC_OnTagApplied(client);

/**
 * Called when a client's name is about to be tagged
 * DO NOT START A NEW USERMESSAGE (i.e. PrintToChat, PrintToChatAll) WITHIN THIS FORWARD
 * 
 * @param client		Client index
 * @param message		Chat message that will be printed
 * @param type			What type of color will be applied. If this is CCC_TagColor, it controls whether the tag will be applied at all, not whether the tag will be colored.
 * @return				Plugin_Handled to prevent coloring, Plugin_Continue to allow coloring
 */
forward Action:CCC_OnColor(client, const String:message[], CCC_ColorType:type);

/**
 * Called when a message has been fully colored and will be sent, unless further plugins modify it through Simple Chat Processor
 * 
 * @param author		Author client index
 * @param message		Message
 * @param maxlen		Maximum length of message buffer
 * @noreturn
 */
forward CCC_OnChatMessage(author, String:message[], maxlen);

/**
 * Called when a client's colors and tag are about to be loaded from the config file
 * At this point, the client has NO COLORS
 * 
 * @param client		Client index
 * @return				Plugin_Handled or Plugin_Stop to prevent loading, Plugin_Continue or Plugin_Changed to allow
 */
forward Action:CCC_OnUserConfigPreLoaded(client);

/**
 * Called when a client's colors and tag have been loaded from the config file
 * 
 * @param client		Client index
 * @noreturn
 */
forward CCC_OnUserConfigLoaded(client);

/**
 * Called when the configuration file is reloaded with the sm_reloadccc command
 * 
 * @noreturn
 */
forward CCC_OnConfigReloaded();

public SharedPlugin:__pl_ccc = {
	name = "ccc",
	file = "custom-chatcolors.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_ccc_SetNTVOptional() {
	MarkNativeAsOptional("CCC_GetColor");
	MarkNativeAsOptional("CCC_SetColor");
	MarkNativeAsOptional("CCC_GetTag");
	MarkNativeAsOptional("CCC_ResetTag");
	MarkNativeAsOptional("CCC_ResetColor");
	MarkNativeAsOptional("CCC_ResetTag");
}
#endif