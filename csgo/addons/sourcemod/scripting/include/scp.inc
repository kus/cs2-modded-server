/************************************************************************
*************************************************************************
Simple Plugins
Description:
	Included file for Simple Chat Processor in the Simple Plugins project
*************************************************************************
*************************************************************************
This file is part of Simple Plugins project.

This plugin is free software: you can redistribute 
it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or
later version. 

This plugin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this plugin.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************
*************************************************************************
File Information
$Id$
$Author$
$Revision$
$Date$
$LastChangedBy$
$LastChangedDate$
$URL$
$Copyright: (c) Simple Plugins 2008-2009$
*************************************************************************
*************************************************************************/

#if defined _scp_included
  #endinput
#endif
#define _scp_included

#define MAXLENGTH_INPUT			128 	// Inclues \0 and is the size of the chat input box.


#define CHATFLAGS_INVALID		0
#define CHATFLAGS_ALL				(1<<0)
#define CHATFLAGS_TEAM				(1<<1)
#define CHATFLAGS_SPEC				(1<<2)
#define CHATFLAGS_DEAD				(1<<3)



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
forward Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[]);


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
forward OnChatMessage_Post(author, Handle:recipients, const String:name[], const String:message[]);


/**********************************************************************
 * Gets the current flags for the chat message
 * Should only be called within OnChatMessage() or OnChatMessage_Post()
 *
 * @return		The current type of chat message (see constants) 
 **********************************************************************/
 native GetMessageFlags();

 
 
/**
Shared plugin information
**/
public SharedPlugin:_pl_scp = 
{
	name = "scp",
	file = "simple-chatprocessor.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public _pl_scp_SetNTVOptional()
{
	MarkNativeAsOptional("GetMessageFlags");
}
#endif