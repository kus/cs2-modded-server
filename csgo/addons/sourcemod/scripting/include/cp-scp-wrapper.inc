#if defined _cp_scp_wrapper_included
  #endinput
#endif
#define _cp_scp_wrapper_included

#define CHATFLAGS_INVALID		0
#define CHATFLAGS_ALL			(1<<0)
#define CHATFLAGS_TEAM			(1<<1)
#define CHATFLAGS_SPEC			(1<<2)
#define CHATFLAGS_DEAD			(1<<3)

/**********************************************************************
 * When a player types a chat message
 *
 * NOTES:
 * Use MAXLENGTH_  constants above for formating the strings
 * Do not rely on the recipients handle to exist beyond the forward
 * Do not start another usermessage (PrintToChat) within this forward
 *
 * @param 		author							The client index of the player who sent the chat message (Byref)
 * @param 		recipients					The handle to the client index adt array of the players who should recieve the chat message
 * @param 		name							The client's name of the player who sent the chat message (Byref)
 * @param 		message						The contents of the chat message (Byref)
 * @noreturn
 **********************************************************************/
forward Action OnChatMessage(int& author, Handle recipients, char[] name, char[] message);


/**********************************************************************
 * Called after all OnChatMessage forwards have been fired and the message is being broadcast.
 *
 * NOTES:
 * Use MAXLENGTH_  constants above for formating the strings
 * Do not rely on the recipients handle to exist beyond the forward
 *
 * @param 		author							The client index of the player who sent the chat message
 * @param 		recipients					The handle to the client index adt array of the players who are receiting the chat message
 * @param 		name							The client's name of the player who sent the chat message (after any replacements)
 * @param 		message						The contents of the chat message (after any replacements)
 * @noreturn
 **********************************************************************/
forward int OnChatMessage_Post(int author, Handle recipients, const char[] name, const char[] message);


/**********************************************************************
 * Gets the current flags for the chat message
 * Should only be called within OnChatMessage() or OnChatMessage_Post()
 *
 * @return		The current type of chat message (see constants)
 **********************************************************************/
 native int GetMessageFlags();


#if !defined REQUIRE_PLUGIN
public void __pl_cp_scp_wrapper_SetNTVOptional()
{
	MarkNativeAsOptional("GetMessageFlags");
}
#endif

public SharedPlugin __pl_cp_scp_wrapper =
{
	name = "cp-scp-wrapper",
	file = "cp-scp-wrapper.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};
