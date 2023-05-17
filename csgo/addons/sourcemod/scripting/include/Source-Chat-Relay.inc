#if defined _Source_Chat_Relay_included
 #endinput
#endif
#define _Source_Chat_Relay_included

#if !defined MAX_EVENT_NAME_LENGTH
	#define MAX_EVENT_NAME_LENGTH 128
#endif

#if !defined MAX_COMMAND_LENGTH
	#define MAX_COMMAND_LENGTH 512
#endif

enum IdentificationType
{
	IdentificationInvalid = 0,
	IdentificationSteam,
	IdentificationDiscord,
	IdentificationTypeCount,
}

/**
 * Called upon sending a message via chat triggers
 * 
 * @param iClient 		Index of client that is sending the message
 * @param sClientName	Name of the client sending the message. The size of which is MAX_NAME_LENGTH
 * @param sMessage		Message content. The size of which is MAX_COMMAND_LENGTH
 */
forward Action SCR_OnMessageSend(int iClient, char[] sClientName, char[] sMessage);

/**
 * Called upon receiving a message
 * 
 * @param sEntityName	Entity name/hostname of the sending client
 * @param iIDType 		The IdentificationType of the ID
 * @param sID			String variant of the ID
 * @param sClientName	Name of the client that sent the message. The size of which is MAX_NAME_LENGTH
 * @param sMessage		Message content. The size of which is MAX_COMMAND_LENGTH
 */
forward Action SCR_OnMessageReceive(const char[] sEntityName, IdentificationType iIDType, const char[] sID, char[] sClientName, char[] sMessage);

/**
 * Called upon sending an event
 * 
 * @param sEvent		Name of the event. The size of which is MAX_EVENT_NAME_LENGTH
 * @param sData			Data of the event. The size of which is MAX_COMMAND_LENGTH
 */
forward Action SCR_OnEventSend(char[] sEvent, char[] sData);

/**
 * Called upon receiving an event
 * 
 * @param sEvent		Name of the event. The size of which is MAX_EVENT_NAME_LENGTH
 * @param sData			Data of the event. The size of which is MAX_COMMAND_LENGTH
 */
forward Action SCR_OnEventReceive(char[] sEvent, char[] sData);

/**
 * Sends a message to the router
 * 
 * @param iClient   Client ID to use as name display (If left at 0, it will display "CONSOLE")
 * @param fmt       Format string
 * @param ...       Format arguments
 */
native void SCR_SendMessage(int iClient = 0, const char[] fmt, any ...);

/**
 * Sends an event to the router
 * 
 * @param sEvent	Name of the event
 * @param sData		Data format string
 * @param ...		Format arguments
 */
native void SCR_SendEvent(const char[] sEvent, const char[] sData, any ...);

#if !defined REQUIRE_PLUGIN
public __pl_Source_Chat_Relay_SetNTVOptional()
{
	MarkNativeAsOptional("SCR_SendMessage");
	MarkNativeAsOptional("SCR_SendEvent");
}
#endif

public SharedPlugin __pl_Source_Chat_Relay =
{
	name = "Source-Chat-Relay",
	file = "Source-Chat-Relay.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};