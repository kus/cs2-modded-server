#if defined _chat_processor_included
  #endinput
#endif
#define _chat_processor_included

//Globals
#define MAXLENGTH_FLAG		32
#define MAXLENGTH_NAME		128
#define MAXLENGTH_MESSAGE	128
#define MAXLENGTH_BUFFER	255

//Natives
/**
* Retrieves the current format string assigned from a flag string.
* Example: "Cstrike_Chat_All" = "{1} :  {2}"
* You can find the config formats in either the translations or the configs.
*
* param sFlag			Flag string to retrieve the format string from.
* param sBuffer		Format string from the flag string.
* param iSize			Size of the format string buffer.
*
* noreturn
**/
native void ChatProcessor_GetFlagFormatString(const char[] sFlag, char[] sBuffer, int iSize);

//Forwards
/**
* Called while sending a chat message before It's sent.
* Limits on the name and message strings can be found above.
*
* param author			Author that created the message.
* param recipients		Array of clients who will receive the message.
* param flagstring		Flag string to determine the type of message.
* param name			Name string of the author to be pushed.
* param message		Message string from the author to be pushed.
* param processcolors	Toggle to process colors in the buffer strings.
* param removecolors	Toggle to remove colors in the buffer strings. (Requires bProcessColors = true)
*
* return types
*  - Plugin_Continue	Stops the message.
*  - Plugin_Stop		Stops the message.
*  - Plugin_Changed		Fires the post-forward below and prints out a message.
*  - Plugin_Handled		Fires the post-forward below but doesn't print a message.
**/
forward Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool & processcolors, bool & removecolors);

/**
* Called after the chat message is sent to the designated clients by the author.
*
* param author			Author that sent the message.
* param recipients		Array of clients who received the message.
* param flagstring		Flag string to determine the type of message.
* param formatstring	Format string used in the message based on the flag string.
* param name			Name string of the author.
* param message		Message string from the author.
* param processcolors	Check if colors were processed in the buffer strings.
* param removecolors	Check if colors were removed from the buffer strings.
*
* noreturn
**/
forward void CP_OnChatMessagePost(int author, ArrayList recipients, const char[] flagstring, const char[] formatstring, const char[] name, const char[] message, bool processcolors, bool removecolors);

/**
* Called before a chat message is sent, here the message is already processed.
*
* param sender			Author that sent the message.
* param reciver			Reciver of the message.
* param buffer			Message's buffer.
* param maxlength		Max length of the buffer.
*
* noreturn
**/
forward Action CP_OnChatMessageSendPre(int sender, int reciever, char[] buffer, int maxlength);

#if !defined REQUIRE_PLUGIN
public void __pl_chat_processor_SetNTVOptional()
{
	MarkNativeAsOptional("ChatProcessor_GetFlagFormatString");
}
#endif

public SharedPlugin __pl_chat_processor =
{
	name = "chat-processor",
	file = "chat-processor.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};