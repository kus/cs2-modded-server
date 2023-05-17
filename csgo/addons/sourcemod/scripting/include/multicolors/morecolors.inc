// MOAR COLORS
// By Dr. McKay
// Inspired by: https://forums.alliedmods.net/showthread.php?t=96831

#if defined _more_colors_included
 #endinput
#endif
#define _more_colors_included

#include <regex>

#define MORE_COLORS_VERSION     "2.0.0-MC"
#define MC_MAX_MESSAGE_LENGTH   256
#define MAX_BUFFER_LENGTH       (MC_MAX_MESSAGE_LENGTH * 4)

#define MCOLOR_RED              0xFF4040
#define MCOLOR_BLUE             0x99CCFF
#define MCOLOR_GRAY             0xCCCCCC
#define MCOLOR_GREEN            0x3EFF3E

#define MC_GAME_DODS           0

bool MC_SkipList[MAXPLAYERS + 1];
Handle MC_Trie;
int MC_TeamColors[][] = {{0xCCCCCC, 0x4D7942, 0xFF4040}}; // Multi-dimensional array for games that don't support SayText2. First index is the game index (as defined by the GAME_ defines), second index is team. 0 = spectator, 1 = team1, 2 = team2

static Handle sm_show_activity = INVALID_HANDLE;

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags.
 * 
 * @param client		Client index.
 * @param message		Message (formatting rules).
 * @noreturn
 * 
 * On error/Errors:		If the client is not connected an error will be thrown.
 */
stock void MC_PrintToChat(int client, const char[] message, any ...) {
	MC_CheckTrie();
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	if(!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 3);
	MC_ReplaceColorCodes(buffer2);
	MC_SendMessage(client, buffer2);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags.
 * 
 * @param client		Client index.
 * @param message		Message (formatting rules).
 * @noreturn
 */
stock void MC_PrintToChatAll(const char[] message, any ...) {
	MC_CheckTrie();
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	MuCo_LoopClients(i) {
		if(i == 0 || !IsClientInGame(i) || MC_SkipList[i]) {
			MC_SkipList[i] = false;
			continue;
		}
		SetGlobalTransTarget(i);
		Format(buffer, sizeof(buffer), "\x01%s", message);
		VFormat(buffer2, sizeof(buffer2), buffer, 2);
		MC_ReplaceColorCodes(buffer2);
		MC_SendMessage(i, buffer2);
	}
}

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags and teamcolor tag.
 * 
 * @param client		Client index.
 * @param author		Author index whose color will be used for teamcolor tag.
 * @param message		Message (formatting rules).
 * @noreturn
 * 
 * On error/Errors:		If the client or author are not connected an error will be thrown
 */
stock void MC_PrintToChatEx(int client, int author, const char[] message, any ...) {
	MC_CheckTrie();
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	if(!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}
	if(author <= 0 || author > MaxClients) {
		ThrowError("Invalid client index %i", author);
	}
	if(!IsClientInGame(author)) {
		ThrowError("Client %i is not in game", author);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 4);
	MC_ReplaceColorCodes(buffer2, author);
	MC_SendMessage(client, buffer2, author);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param author	  Author index whose color will be used for teamcolor tag.
 * @param message   Message (formatting rules).
 * @noreturn
 * 
 * On error/Errors:   If the author is not connected an error will be thrown.
 */
stock void MC_PrintToChatAllEx(int author, const char[] message, any ...) {
	MC_CheckTrie();
	if(author <= 0 || author > MaxClients) {
		ThrowError("Invalid client index %i", author);
	}
	if(!IsClientInGame(author)) {
		ThrowError("Client %i is not in game", author);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	MuCo_LoopClients(i) {
		if(i == 0 || !IsClientInGame(i) || MC_SkipList[i]) {
			MC_SkipList[i] = false;
			continue;
		}
		SetGlobalTransTarget(i);
		Format(buffer, sizeof(buffer), "\x01%s", message);
		VFormat(buffer2, sizeof(buffer2), buffer, 3);
		MC_ReplaceColorCodes(buffer2, author);
		MC_SendMessage(i, buffer2, author);
	}
}

/**
 * Sends a SayText2 usermessage
 * 
 * @param client	Client to send usermessage to
 * @param message	Message to send
 * @noreturn
 */
stock void MC_SendMessage(int client, const char[] message, int author = 0) {
	if(author == 0) {
		author = client;
	}
	char buffer[MC_MAX_MESSAGE_LENGTH];
	strcopy(buffer, sizeof(buffer), message);
	UserMsg index = GetUserMessageId("SayText2");
	if(index == INVALID_MESSAGE_ID) {
		if(GetEngineVersion() == Engine_DODS) {
			int team = GetClientTeam(author);
			if(team == 0) {
				ReplaceString(buffer, sizeof(buffer), "\x03", "\x04", false); // Unassigned gets green
			} else {
				char temp[16];
				Format(temp, sizeof(temp), "\x07%06X", MC_TeamColors[MC_GAME_DODS][team - 1]);
				ReplaceString(buffer, sizeof(buffer), "\x03", temp, false);
			}
		}
		PrintToChat(client, "%s", buffer);
		return;
	}
	Handle buf = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) {
		PbSetInt(buf, "ent_idx", author);
		PbSetBool(buf, "chat", true);
		PbSetString(buf, "msg_name", buffer);
		PbAddString(buf, "params", "");
		PbAddString(buf, "params", "");
		PbAddString(buf, "params", "");
		PbAddString(buf, "params", "");
	} else {
		BfWriteByte(buf, author); // Message author
		BfWriteByte(buf, true); // Chat message
		BfWriteString(buf, buffer); // Message text
	}
	EndMessage();
}

/**
 * This function should only be used right in front of
 * MC_PrintToChatAll or MC_PrintToChatAllEx. It causes those functions
 * to skip the specified client when printing the message.
 * After printing the message, the client will no longer be skipped.
 * 
 * @param client   Client index
 * @noreturn
 */
stock void MC_SkipNextClient(int client) {
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	MC_SkipList[client] = true;
}

/**
 * Checks if the colors trie is initialized and initializes it if it's not (used internally)
 * 
 * @return			No return
 */
stock void MC_CheckTrie() {
	if(MC_Trie == INVALID_HANDLE) {
		MC_Trie = MC_InitColorTrie();
	}
}

/**
 * Replaces color tags in a string with color codes (used internally by MC_PrintToChat, MC_PrintToChatAll, MC_PrintToChatEx, and MC_PrintToChatAllEx
 *
 * @param buffer		String.
 * @param author		Optional client index to use for {teamcolor} tags, or 0 for none
 * @param removeTags	Optional boolean value to determine whether we're replacing tags with colors, or just removing tags, used by MC_RemoveTags
 * @param maxlen		Optional value for max buffer length, used by MC_RemoveTags
 * @noreturn
 * 
 * On error/Errors:		If the client index passed for author is invalid or not in game.
 */
stock void MC_ReplaceColorCodes(char[] buffer, int author = 0, bool removeTags = false, int maxlen = MAX_BUFFER_LENGTH) {
	MC_CheckTrie();
	if(!removeTags) {
		ReplaceString(buffer, maxlen, "{default}", "\x01", false);
	} else {
		ReplaceString(buffer, maxlen, "{default}", "", false);
		ReplaceString(buffer, maxlen, "{teamcolor}", "", false);
	}
	if(author != 0 && !removeTags) {
		if(author < 0 || author > MaxClients) {
			ThrowError("Invalid client index %i", author);
		}
		if(!IsClientInGame(author)) {
			ThrowError("Client %i is not in game", author);
		}
		ReplaceString(buffer, maxlen, "{teamcolor}", "\x03", false);
	}
	int cursor = 0;
	int value;
	char tag[32], buff[32]; 
	char[] output = new char[maxlen];
	
	strcopy(output, maxlen, buffer);
	// Since the string's size is going to be changing, output will hold the replaced string and we'll search buffer
	
	Handle regex = CompileRegex("{[a-zA-Z0-9]+}");
	for(int i = 0; i < 1000; i++) { // The RegEx extension is quite flaky, so we have to loop here :/. This loop is supposed to be infinite and broken by return, but conditions have been added to be safe.
		if(MatchRegex(regex, buffer[cursor]) < 1) {
			CloseHandle(regex);
			strcopy(buffer, maxlen, output);
			return;
		}
		GetRegexSubString(regex, 0, tag, sizeof(tag));
		MC_StrToLower(tag);
		cursor = StrContains(buffer[cursor], tag, false) + cursor + 1;
		strcopy(buff, sizeof(buff), tag);
		ReplaceString(buff, sizeof(buff), "{", "");
		ReplaceString(buff, sizeof(buff), "}", "");
		
		if(!GetTrieValue(MC_Trie, buff, value)) {
			continue;
		}
		
		if(removeTags) {
			ReplaceString(output, maxlen, tag, "", false);
		} else {
			Format(buff, sizeof(buff), "\x07%06X", value);
			ReplaceString(output, maxlen, tag, buff, false);
		}
	}
	LogError("[MORE COLORS] Infinite loop broken.");
}

/**
 * Gets a part of a string
 * 
 * @param input			String to get the part from
 * @param output		Buffer to write to
 * @param maxlen		Max length of output buffer
 * @param start			Position to start at
 * @param numChars		Number of characters to return, or 0 for the end of the string
 * @noreturn
 */
stock void CSubString(const char[] input, char[] output, int maxlen, int start, int numChars = 0) {
	int i = 0;
	for(;;) {
		if(i == maxlen - 1 || i >= numChars || input[start + i] == '\0') {
			output[i] = '\0';
			return;
		}
		output[i] = input[start + i];
		i++;
	}
}

/**
 * Converts a string to lowercase
 * 
 * @param buffer		String to convert
 * @noreturn
 */
stock void MC_StrToLower(char[] buffer) {
	int len = strlen(buffer);
	for(int i = 0; i < len; i++) {
		buffer[i] = CharToLower(buffer[i]);
	}
}

/**
 * Adds a color to the colors trie
 *
 * @param name			Color name, without braces
 * @param color			Hexadecimal representation of the color (0xRRGGBB)
 * @return				True if color was added successfully, false if a color already exists with that name
 */
stock bool MC_AddColor(const char[] name, int color) {
	MC_CheckTrie();
	int value;
	if(GetTrieValue(MC_Trie, name, value)) {
		return false;
	}
	char newName[64];
	strcopy(newName, sizeof(newName), name);
	MC_StrToLower(newName);
	SetTrieValue(MC_Trie, newName, color);
	return true;
}

/**
 * Removes color tags from a message
 * 
 * @param message		Message to remove tags from
 * @param maxlen		Maximum buffer length
 * @noreturn
 */
stock void MC_RemoveTags(char[] message, int maxlen) {
	MC_ReplaceColorCodes(message, 0, true, maxlen);
}

/**
 * Replies to a command with colors
 * 
 * @param client		Client to reply to
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void MC_ReplyToCommand(int client, const char[] message, any ...) {
	char buffer[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), message, 3);
	if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
		MC_RemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "%s", buffer);
	} else {
		MC_PrintToChat(client, "%s", buffer);
	}
}

/**
 * Replies to a command with colors
 * 
 * @param client		Client to reply to
 * @param author		Client to use for {teamcolor}
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void MC_ReplyToCommandEx(int client, int author, const char[] message, any ...) {
	char buffer[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), message, 4);
	if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
		MC_RemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "%s", buffer);
	} else {
		MC_PrintToChatEx(client, author, "%s", buffer);
	}
}

/**
 * Displays usage of an admin command to users depending on the 
 * setting of the sm_show_activity cvar.  
 *
 * This version does not display a message to the originating client 
 * if used from chat triggers or menus.  If manual replies are used 
 * for these cases, then this function will suffice.  Otherwise, 
 * MC_ShowActivity2() is slightly more useful.
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 * @error
 */
stock int MC_ShowActivity(int client, const char[] format, any ...)
{
	if (sm_show_activity == INVALID_HANDLE)
		sm_show_activity = FindConVar("sm_show_activity");
		
	char tag[] = "[SM] ";
	
	char szBuffer[MC_MAX_MESSAGE_LENGTH];
	//char szCMessage[MC_MAX_MESSAGE_LENGTH];
	int value = GetConVarInt(sm_show_activity);
	ReplySource replyto = GetCmdReplySource();
	
	char name[MAX_NAME_LENGTH] = "Console";
	char sign[MAX_NAME_LENGTH] = "ADMIN";
	bool display_in_chat = false;
	if (client != 0)
	{
		if (client < 0 || client > MaxClients || !IsClientConnected(client))
			ThrowError("Client index %d is invalid", client);
		
		GetClientName(client, name, sizeof(name));
		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID
			|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			sign = "PLAYER";
		}
		
		/* Display the message to the client? */
		if (replyto == SM_REPLY_TO_CONSOLE)
		{
			SetGlobalTransTarget(client);
			VFormat(szBuffer, sizeof(szBuffer), format, 3);
			
			MC_RemoveTags(szBuffer, sizeof(szBuffer));
			PrintToConsole(client, "%s%s\n", tag, szBuffer);
			display_in_chat = true;
		}
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 3);
		
		MC_RemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s\n", tag, szBuffer);
	}
	
	if (!value)
	{
		return 1;
	}
	
	MuCo_LoopClients(i)
	{
		if (i == 0
			|| !IsClientInGame(i)
			|| IsFakeClient(i)
			|| (display_in_chat && i == client))
		{
			continue;
		}
		AdminId id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID
			|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2))
			{
				char newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 2) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 3);
				
				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else
		{
			/* Treat this as an admin user */
			bool is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
			if ((value & 4)
				|| (value & 8)
				|| ((value & 16) && is_root))
			{
				char newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 8) || ((value & 16) && is_root) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 3);
				
				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}
	
	return 1;
}

/**
 * Same as MC_ShowActivity(), except the tag parameter is used instead of "[SM] " (note that you must supply any spacing).
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param tags			Tag to display with.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 * @error
 */
stock int MC_ShowActivityEx(int client, const char[] tag, const char[] format, any ...)
{
	if (sm_show_activity == INVALID_HANDLE)
		sm_show_activity = FindConVar("sm_show_activity");
		
	char szBuffer[MC_MAX_MESSAGE_LENGTH];
	//char szCMessage[MC_MAX_MESSAGE_LENGTH];
	int value = GetConVarInt(sm_show_activity);
	ReplySource replyto = GetCmdReplySource();
	
	char name[MAX_NAME_LENGTH] = "Console";
	char sign[MAX_NAME_LENGTH] = "ADMIN";
	bool display_in_chat = false;
	if (client != 0)
	{
		if (client < 0 || client > MaxClients || !IsClientConnected(client))
			ThrowError("Client index %d is invalid", client);
		
		GetClientName(client, name, sizeof(name));
		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID
			|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			sign = "PLAYER";
		}
		
		/* Display the message to the client? */
		if (replyto == SM_REPLY_TO_CONSOLE)
		{
			SetGlobalTransTarget(client);
			VFormat(szBuffer, sizeof(szBuffer), format, 4);
			
			MC_RemoveTags(szBuffer, sizeof(szBuffer));
			PrintToConsole(client, "%s%s\n", tag, szBuffer);
			display_in_chat = true;
		}
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);
		
		MC_RemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s\n", tag, szBuffer);
	}
	
	if (!value)
	{
		return 1;
	}
	
	MuCo_LoopClients(i)
	{
		if (i == 0
			|| !IsClientInGame(i)
			|| IsFakeClient(i)
			|| (display_in_chat && i == client))
		{
			continue;
		}
		AdminId id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID
			|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2))
			{
				char newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 2) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else
		{
			/* Treat this as an admin user */
			bool is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
			if ((value & 4)
				|| (value & 8)
				|| ((value & 16) && is_root))
			{
				char newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 8) || ((value & 16) && is_root) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}
	
	return 1;
}

/**
 * Displays usage of an admin command to users depending on the setting of the sm_show_activity cvar.
 * All users receive a message in their chat text, except for the originating client, 
 * who receives the message based on the current ReplySource.
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param tags			Tag to prepend to the message.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 * @error
 */
stock int MC_ShowActivity2(int client, const char[] tag, const char[] format, any ...)
{
	if (sm_show_activity == INVALID_HANDLE)
		sm_show_activity = FindConVar("sm_show_activity");
	
	char szBuffer[MC_MAX_MESSAGE_LENGTH];
	//char szCMessage[MC_MAX_MESSAGE_LENGTH];
	int value = GetConVarInt(sm_show_activity);
	// ReplySource replyto = GetCmdReplySource();
	
	char name[MAX_NAME_LENGTH] = "Console";
	char sign[MAX_NAME_LENGTH] = "ADMIN";
	if (client != 0)
	{
		if (client < 0 || client > MaxClients || !IsClientConnected(client))
			ThrowError("Client index %d is invalid", client);
		
		GetClientName(client, name, sizeof(name));
		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID
		|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			sign = "PLAYER";
		}
		
		SetGlobalTransTarget(client);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);
		
		/* We don't display directly to the console because the chat text 
		 * simply gets added to the console, so we don't want it to print 
		 * twice.
		 */
		MC_PrintToChatEx(client, client, "%s%s", tag, szBuffer);
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);
		
		MC_RemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s\n", tag, szBuffer);
	}
	
	if (!value)
	{
		return 1;
	}
	
	MuCo_LoopClients(i)
	{
		if (i == 0
			|| !IsClientInGame(i)
			|| IsFakeClient(i)
			|| i == client)
		{
			continue;
		}
		AdminId id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID
		|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2))
			{
				char newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 2))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else
		{
			/* Treat this as an admin user */
			bool is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
			if ((value & 4)
			|| (value & 8)
			|| ((value & 16) && is_root))
			{
				char newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 8) || ((value & 16) && is_root))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}
	
	return 1;	
}

/**
 * Determines whether a color name exists
 * 
 * @param color			The color name to check
 * @return				True if the color exists, false otherwise
 */
stock bool CColorExists(const char[] color) {
	MC_CheckTrie();
	int temp;
	return GetTrieValue(MC_Trie, color, temp);
}

/**
 * Returns the hexadecimal representation of a client's team color (will NOT initialize the trie)
 *
 * @param client		Client to get the team color for
 * @return				Client's team color in hexadecimal, or green if unknown
 * On error/Errors:		If the client index passed is invalid or not in game.
 */
stock int CGetTeamColor(int client) {
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	if(!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}
	int value;
	switch(GetClientTeam(client)) {
		case 1: {
			value = MCOLOR_GRAY;
		}
		case 2: {
			value = MCOLOR_RED;
		}
		case 3: {
			value = MCOLOR_BLUE;
		}
		default: {
			value = MCOLOR_GREEN;
		}
	}
	return value;
}

stock Handle MC_InitColorTrie() {
	Handle hTrie = CreateTrie();
	SetTrieValue(hTrie, "aliceblue", 0xF0F8FF);
	SetTrieValue(hTrie, "allies", 0x4D7942); // same as Allies team in DoD:S
	SetTrieValue(hTrie, "ancient", 0xEB4B4B); // same as Ancient item rarity in Dota 2
	SetTrieValue(hTrie, "antiquewhite", 0xFAEBD7);
	SetTrieValue(hTrie, "aqua", 0x00FFFF);
	SetTrieValue(hTrie, "aquamarine", 0x7FFFD4);
	SetTrieValue(hTrie, "arcana", 0xADE55C); // same as Arcana item rarity in Dota 2
	SetTrieValue(hTrie, "axis", 0xFF4040); // same as Axis team in DoD:S
	SetTrieValue(hTrie, "azure", 0x007FFF);
	SetTrieValue(hTrie, "beige", 0xF5F5DC);
	SetTrieValue(hTrie, "bisque", 0xFFE4C4);
	SetTrieValue(hTrie, "black", 0x000000);
	SetTrieValue(hTrie, "blanchedalmond", 0xFFEBCD);
	SetTrieValue(hTrie, "blue", 0x99CCFF); // same as BLU/Counter-Terrorist team color
	SetTrieValue(hTrie, "blueviolet", 0x8A2BE2);
	SetTrieValue(hTrie, "brown", 0xA52A2A);
	SetTrieValue(hTrie, "burlywood", 0xDEB887);
	SetTrieValue(hTrie, "cadetblue", 0x5F9EA0);
	SetTrieValue(hTrie, "chartreuse", 0x7FFF00);
	SetTrieValue(hTrie, "chocolate", 0xD2691E);
	SetTrieValue(hTrie, "collectors", 0xAA0000); // same as Collector's item quality in TF2
	SetTrieValue(hTrie, "common", 0xB0C3D9); // same as Common item rarity in Dota 2
	SetTrieValue(hTrie, "community", 0x70B04A); // same as Community item quality in TF2
	SetTrieValue(hTrie, "coral", 0xFF7F50);
	SetTrieValue(hTrie, "cornflowerblue", 0x6495ED);
	SetTrieValue(hTrie, "cornsilk", 0xFFF8DC);
	SetTrieValue(hTrie, "corrupted", 0xA32C2E); // same as Corrupted item quality in Dota 2
	SetTrieValue(hTrie, "crimson", 0xDC143C);
	SetTrieValue(hTrie, "cyan", 0x00FFFF);
	SetTrieValue(hTrie, "darkblue", 0x00008B);
	SetTrieValue(hTrie, "darkcyan", 0x008B8B);
	SetTrieValue(hTrie, "darkgoldenrod", 0xB8860B);
	SetTrieValue(hTrie, "darkgray", 0xA9A9A9);
	SetTrieValue(hTrie, "darkgrey", 0xA9A9A9);
	SetTrieValue(hTrie, "darkgreen", 0x006400);
	SetTrieValue(hTrie, "darkkhaki", 0xBDB76B);
	SetTrieValue(hTrie, "darkmagenta", 0x8B008B);
	SetTrieValue(hTrie, "darkolivegreen", 0x556B2F);
	SetTrieValue(hTrie, "darkorange", 0xFF8C00);
	SetTrieValue(hTrie, "darkorchid", 0x9932CC);
	SetTrieValue(hTrie, "darkred", 0x8B0000);
	SetTrieValue(hTrie, "darksalmon", 0xE9967A);
	SetTrieValue(hTrie, "darkseagreen", 0x8FBC8F);
	SetTrieValue(hTrie, "darkslateblue", 0x483D8B);
	SetTrieValue(hTrie, "darkslategray", 0x2F4F4F);
	SetTrieValue(hTrie, "darkslategrey", 0x2F4F4F);
	SetTrieValue(hTrie, "darkturquoise", 0x00CED1);
	SetTrieValue(hTrie, "darkviolet", 0x9400D3);
	SetTrieValue(hTrie, "deeppink", 0xFF1493);
	SetTrieValue(hTrie, "deepskyblue", 0x00BFFF);
	SetTrieValue(hTrie, "dimgray", 0x696969);
	SetTrieValue(hTrie, "dimgrey", 0x696969);
	SetTrieValue(hTrie, "dodgerblue", 0x1E90FF);
	SetTrieValue(hTrie, "exalted", 0xCCCCCD); // same as Exalted item quality in Dota 2
	SetTrieValue(hTrie, "firebrick", 0xB22222);
	SetTrieValue(hTrie, "floralwhite", 0xFFFAF0);
	SetTrieValue(hTrie, "forestgreen", 0x228B22);
	SetTrieValue(hTrie, "frozen", 0x4983B3); // same as Frozen item quality in Dota 2
	SetTrieValue(hTrie, "fuchsia", 0xFF00FF);
	SetTrieValue(hTrie, "fullblue", 0x0000FF);
	SetTrieValue(hTrie, "fullred", 0xFF0000);
	SetTrieValue(hTrie, "gainsboro", 0xDCDCDC);
	SetTrieValue(hTrie, "genuine", 0x4D7455); // same as Genuine item quality in TF2
	SetTrieValue(hTrie, "ghostwhite", 0xF8F8FF);
	SetTrieValue(hTrie, "gold", 0xFFD700);
	SetTrieValue(hTrie, "goldenrod", 0xDAA520);
	SetTrieValue(hTrie, "gray", 0xCCCCCC); // same as spectator team color
	SetTrieValue(hTrie, "grey", 0xCCCCCC);
	SetTrieValue(hTrie, "green", 0x3EFF3E);
	SetTrieValue(hTrie, "greenyellow", 0xADFF2F);
	SetTrieValue(hTrie, "haunted", 0x38F3AB); // same as Haunted item quality in TF2
	SetTrieValue(hTrie, "honeydew", 0xF0FFF0);
	SetTrieValue(hTrie, "hotpink", 0xFF69B4);
	SetTrieValue(hTrie, "immortal", 0xE4AE33); // same as Immortal item rarity in Dota 2
	SetTrieValue(hTrie, "indianred", 0xCD5C5C);
	SetTrieValue(hTrie, "indigo", 0x4B0082);
	SetTrieValue(hTrie, "ivory", 0xFFFFF0);
	SetTrieValue(hTrie, "khaki", 0xF0E68C);
	SetTrieValue(hTrie, "lavender", 0xE6E6FA);
	SetTrieValue(hTrie, "lavenderblush", 0xFFF0F5);
	SetTrieValue(hTrie, "lawngreen", 0x7CFC00);
	SetTrieValue(hTrie, "legendary", 0xD32CE6); // same as Legendary item rarity in Dota 2
	SetTrieValue(hTrie, "lemonchiffon", 0xFFFACD);
	SetTrieValue(hTrie, "lightblue", 0xADD8E6);
	SetTrieValue(hTrie, "lightcoral", 0xF08080);
	SetTrieValue(hTrie, "lightcyan", 0xE0FFFF);
	SetTrieValue(hTrie, "lightgoldenrodyellow", 0xFAFAD2);
	SetTrieValue(hTrie, "lightgray", 0xD3D3D3);
	SetTrieValue(hTrie, "lightgrey", 0xD3D3D3);
	SetTrieValue(hTrie, "lightgreen", 0x99FF99);
	SetTrieValue(hTrie, "lightpink", 0xFFB6C1);
	SetTrieValue(hTrie, "lightsalmon", 0xFFA07A);
	SetTrieValue(hTrie, "lightseagreen", 0x20B2AA);
	SetTrieValue(hTrie, "lightskyblue", 0x87CEFA);
	SetTrieValue(hTrie, "lightslategray", 0x778899);
	SetTrieValue(hTrie, "lightslategrey", 0x778899);
	SetTrieValue(hTrie, "lightsteelblue", 0xB0C4DE);
	SetTrieValue(hTrie, "lightyellow", 0xFFFFE0);
	SetTrieValue(hTrie, "lime", 0x00FF00);
	SetTrieValue(hTrie, "limegreen", 0x32CD32);
	SetTrieValue(hTrie, "linen", 0xFAF0E6);
	SetTrieValue(hTrie, "magenta", 0xFF00FF);
	SetTrieValue(hTrie, "maroon", 0x800000);
	SetTrieValue(hTrie, "mediumaquamarine", 0x66CDAA);
	SetTrieValue(hTrie, "mediumblue", 0x0000CD);
	SetTrieValue(hTrie, "mediumorchid", 0xBA55D3);
	SetTrieValue(hTrie, "mediumpurple", 0x9370D8);
	SetTrieValue(hTrie, "mediumseagreen", 0x3CB371);
	SetTrieValue(hTrie, "mediumslateblue", 0x7B68EE);
	SetTrieValue(hTrie, "mediumspringgreen", 0x00FA9A);
	SetTrieValue(hTrie, "mediumturquoise", 0x48D1CC);
	SetTrieValue(hTrie, "mediumvioletred", 0xC71585);
	SetTrieValue(hTrie, "midnightblue", 0x191970);
	SetTrieValue(hTrie, "mintcream", 0xF5FFFA);
	SetTrieValue(hTrie, "mistyrose", 0xFFE4E1);
	SetTrieValue(hTrie, "moccasin", 0xFFE4B5);
	SetTrieValue(hTrie, "mythical", 0x8847FF); // same as Mythical item rarity in Dota 2
	SetTrieValue(hTrie, "navajowhite", 0xFFDEAD);
	SetTrieValue(hTrie, "navy", 0x000080);
	SetTrieValue(hTrie, "normal", 0xB2B2B2); // same as Normal item quality in TF2
	SetTrieValue(hTrie, "oldlace", 0xFDF5E6);
	SetTrieValue(hTrie, "olive", 0x9EC34F);
	SetTrieValue(hTrie, "olivedrab", 0x6B8E23);
	SetTrieValue(hTrie, "orange", 0xFFA500);
	SetTrieValue(hTrie, "orangered", 0xFF4500);
	SetTrieValue(hTrie, "orchid", 0xDA70D6);
	SetTrieValue(hTrie, "palegoldenrod", 0xEEE8AA);
	SetTrieValue(hTrie, "palegreen", 0x98FB98);
	SetTrieValue(hTrie, "paleturquoise", 0xAFEEEE);
	SetTrieValue(hTrie, "palevioletred", 0xD87093);
	SetTrieValue(hTrie, "papayawhip", 0xFFEFD5);
	SetTrieValue(hTrie, "peachpuff", 0xFFDAB9);
	SetTrieValue(hTrie, "peru", 0xCD853F);
	SetTrieValue(hTrie, "pink", 0xFFC0CB);
	SetTrieValue(hTrie, "plum", 0xDDA0DD);
	SetTrieValue(hTrie, "powderblue", 0xB0E0E6);
	SetTrieValue(hTrie, "purple", 0x800080);
	SetTrieValue(hTrie, "rare", 0x4B69FF); // same as Rare item rarity in Dota 2
	SetTrieValue(hTrie, "red", 0xFF4040); // same as RED/Terrorist team color
	SetTrieValue(hTrie, "rosybrown", 0xBC8F8F);
	SetTrieValue(hTrie, "royalblue", 0x4169E1);
	SetTrieValue(hTrie, "saddlebrown", 0x8B4513);
	SetTrieValue(hTrie, "salmon", 0xFA8072);
	SetTrieValue(hTrie, "sandybrown", 0xF4A460);
	SetTrieValue(hTrie, "seagreen", 0x2E8B57);
	SetTrieValue(hTrie, "seashell", 0xFFF5EE);
	SetTrieValue(hTrie, "selfmade", 0x70B04A); // same as Self-Made item quality in TF2
	SetTrieValue(hTrie, "sienna", 0xA0522D);
	SetTrieValue(hTrie, "silver", 0xC0C0C0);
	SetTrieValue(hTrie, "skyblue", 0x87CEEB);
	SetTrieValue(hTrie, "slateblue", 0x6A5ACD);
	SetTrieValue(hTrie, "slategray", 0x708090);
	SetTrieValue(hTrie, "slategrey", 0x708090);
	SetTrieValue(hTrie, "snow", 0xFFFAFA);
	SetTrieValue(hTrie, "springgreen", 0x00FF7F);
	SetTrieValue(hTrie, "steelblue", 0x4682B4);
	SetTrieValue(hTrie, "strange", 0xCF6A32); // same as Strange item quality in TF2
	SetTrieValue(hTrie, "tan", 0xD2B48C);
	SetTrieValue(hTrie, "teal", 0x008080);
	SetTrieValue(hTrie, "thistle", 0xD8BFD8);
	SetTrieValue(hTrie, "tomato", 0xFF6347);
	SetTrieValue(hTrie, "turquoise", 0x40E0D0);
	SetTrieValue(hTrie, "uncommon", 0xB0C3D9); // same as Uncommon item rarity in Dota 2
	SetTrieValue(hTrie, "unique", 0xFFD700); // same as Unique item quality in TF2
	SetTrieValue(hTrie, "unusual", 0x8650AC); // same as Unusual item quality in TF2
	SetTrieValue(hTrie, "valve", 0xA50F79); // same as Valve item quality in TF2
	SetTrieValue(hTrie, "vintage", 0x476291); // same as Vintage item quality in TF2
	SetTrieValue(hTrie, "violet", 0xEE82EE);
	SetTrieValue(hTrie, "wheat", 0xF5DEB3);
	SetTrieValue(hTrie, "white", 0xFFFFFF);
	SetTrieValue(hTrie, "whitesmoke", 0xF5F5F5);
	SetTrieValue(hTrie, "yellow", 0xFFFF00);
	SetTrieValue(hTrie, "yellowgreen", 0x9ACD32);
	return hTrie;
}