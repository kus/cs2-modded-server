/**************************************************************************
 *                                                                        *
 *                       Colored Chat Functions                           *
 *                   Author: exvel, Editor: Popoklopsi, Powerlord, Bara   *
 *                           Version: 1.2.3                               *
 *                                                                        *
 **************************************************************************/
 

#if defined _colors_included
 #endinput
#endif
#define _colors_included
 
#define MAX_MESSAGE_LENGTH 250
#define MAX_COLORS 12

#define SERVER_INDEX 0
#define NO_INDEX -1
#define NO_PLAYER -2

enum Colors
{
 	Color_Default = 0,
	Color_Darkred,
	Color_Green,
	Color_Lightgreen,
	Color_Red,
	Color_Blue,
	Color_Olive,
	Color_Lime,
	Color_Lightred,
	Color_Purple,
	Color_Grey,
	Color_Orange
}

/* Colors' properties */
new String:CTag[][] = {"{default}", "{darkred}", "{green}", "{lightgreen}", "{red}", "{blue}", "{olive}", "{lime}", "{lightred}", "{purple}", "{grey}", "{orange}"};
new String:CTagCode[][] = {"\x01", "\x02", "\x04", "\x03", "\x03", "\x03", "\x05", "\x06", "\x07", "\x03", "\x08", "\x09"};
new bool:CTagReqSayText2[] = {false, false, false, true, true, true, false, false, false, false, false, false};
new bool:CEventIsHooked = false;
new bool:CSkipList[MAXPLAYERS+1] = {false,...};

/* Game default profile */
new bool:CProfile_Colors[] = {true, false, true, false, false, false, false, false, false, false, false, false};
new CProfile_TeamIndex[] = {NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX};
new bool:CProfile_SayText2 = false;

static Handle:sm_show_activity = INVALID_HANDLE;

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags.
 *
 * @param client	  Client index.
 * @param szMessage   Message (formatting rules).
 * @return			  No return
 * 
 * On error/Errors:   If the client is not connected an error will be thrown.
 */
stock CPrintToChat(client, const String:szMessage[], any:...)
{
	if (client <= 0 || client > MaxClients)
		ThrowError("Invalid client index %d", client);
	
	if (!IsClientInGame(client))
		ThrowError("Client %d is not in game", client);
	
	decl String:szBuffer[MAX_MESSAGE_LENGTH];
	decl String:szCMessage[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(client);
	
	Format(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
	VFormat(szCMessage, sizeof(szCMessage), szBuffer, 3);
	
	new index = CFormat(szCMessage, sizeof(szCMessage));
	
	if (index == NO_INDEX)
		PrintToChat(client, "%s", szCMessage);
	else
		CSayText2(client, index, szCMessage);
}

/**
 * Reples to a message in a command. A client index of 0 will use PrintToServer().
 * If the command was from the console, PrintToConsole() is used. If the command was from chat, CPrintToChat() is used.
 * Supports color tags.
 *
 * @param client	  Client index, or 0 for server.
 * @param szMessage   Formatting rules.
 * @param ...         Variable number of format parameters.
 * @return			  No return
 * 
 * On error/Errors:   If the client is not connected or invalid.
 */
stock CReplyToCommand(client, const String:szMessage[], any:...)
{
	decl String:szCMessage[MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(szCMessage, sizeof(szCMessage), szMessage, 3);
	
	if (client == 0)
	{
		CRemoveTags(szCMessage, sizeof(szCMessage));
		PrintToServer("%s", szCMessage);
	}
	else if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(szCMessage, sizeof(szCMessage));
		PrintToConsole(client, "%s", szCMessage);
	}
	else
	{
		CPrintToChat(client, "%s", szCMessage);
	}
}

/**
 * Reples to a message in a command. A client index of 0 will use PrintToServer().
 * If the command was from the console, PrintToConsole() is used. If the command was from chat, CPrintToChat() is used.
 * Supports color tags.
 *
 * @param client	  Client index, or 0 for server.
 * @param author      Author index whose color will be used for teamcolor tag.
 * @param szMessage   Formatting rules.
 * @param ...         Variable number of format parameters.
 * @return			  No return
 * 
 * On error/Errors:   If the client is not connected or invalid.
 */
stock CReplyToCommandEx(client, author, const String:szMessage[], any:...)
{
	decl String:szCMessage[MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(szCMessage, sizeof(szCMessage), szMessage, 4);
	
	if (client == 0)
	{
		CRemoveTags(szCMessage, sizeof(szCMessage));
		PrintToServer("%s", szCMessage);
	}
	else if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(szCMessage, sizeof(szCMessage));
		PrintToConsole(client, "%s", szCMessage);
	}
	else
	{
		CPrintToChatEx(client, author, "%s", szCMessage);
	}
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags.
 *
 * @param client	  Client index.
 * @param szMessage   Message (formatting rules)
 * @return			  No return
 */
stock CPrintToChatAll(const String:szMessage[], any:...)
{
	decl String:szBuffer[MAX_MESSAGE_LENGTH];
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && !CSkipList[i])
		{
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);
			
			CPrintToChat(i, "%s", szBuffer);
		}
		
		CSkipList[i] = false;
	}
}

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param client	  Client index.
 * @param author	  Author index whose color will be used for teamcolor tag.
 * @param szMessage   Message (formatting rules).
 * @return			  No return
 * 
 * On error/Errors:   If the client or author are not connected an error will be thrown.
 */
stock CPrintToChatEx(client, author, const String:szMessage[], any:...)
{
	if (client <= 0 || client > MaxClients)
		ThrowError("Invalid client index %d", client);
	
	if (!IsClientInGame(client))
		ThrowError("Client %d is not in game", client);
	
	if (author < 0 || author > MaxClients)
		ThrowError("Invalid client index %d", author);
	
	decl String:szBuffer[MAX_MESSAGE_LENGTH];
	decl String:szCMessage[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(client);
	
	Format(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
	VFormat(szCMessage, sizeof(szCMessage), szBuffer, 4);
	
	new index = CFormat(szCMessage, sizeof(szCMessage), author);
	
	if (index == NO_INDEX)
		PrintToChat(client, "%s", szCMessage);
	else
		CSayText2(client, author, szCMessage);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param author	  Author index whos color will be used for teamcolor tag.
 * @param szMessage   Message (formatting rules).
 * @return			  No return
 * 
 * On error/Errors:   If the author is not connected an error will be thrown.
 */
stock CPrintToChatAllEx(author, const String:szMessage[], any:...)
{
	if (author < 0 || author > MaxClients)
		ThrowError("Invalid client index %d", author);
	
	if (!IsClientInGame(author))
		ThrowError("Client %d is not in game", author);
	
	decl String:szBuffer[MAX_MESSAGE_LENGTH];
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && !CSkipList[i])
		{
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
			
			CPrintToChatEx(i, author, "%s", szBuffer);
		}
		
		CSkipList[i] = false;
	}
}

/**
 * Removes color tags from the string.
 *
 * @param szMessage   String.
 * @return			  No return
 */
stock CRemoveTags(String:szMessage[], maxlength)
{
	for (new i = 0; i < MAX_COLORS; i++)
		ReplaceString(szMessage, maxlength, CTag[i], "", false);
	
	ReplaceString(szMessage, maxlength, "{teamcolor}", "", false);
}

/**
 * Checks whether a color is allowed or not
 *
 * @param tag   		Color Tag.
 * @return			 	True when color is supported, otherwise false
 */
stock CColorAllowed(Colors:color)
{
	if (!CEventIsHooked)
	{
		CSetupProfile();
		
		CEventIsHooked = true;
	}
	
	return CProfile_Colors[color];
}

/**
 * Replace the color with another color
 * Handle with care!
 *
 * @param color   			color to replace.
 * @param newColor   		color to replace with.
 * @noreturn
 */
stock CReplaceColor(Colors:color, Colors:newColor)
{
	if (!CEventIsHooked)
	{
		CSetupProfile();
		
		CEventIsHooked = true;
	}
	
	CProfile_Colors[color] = CProfile_Colors[newColor];
	CProfile_TeamIndex[color] = CProfile_TeamIndex[newColor];
	
	CTagReqSayText2[color] = CTagReqSayText2[newColor];
	Format(CTagCode[color], sizeof(CTagCode[]), CTagCode[newColor])
}

/**
 * This function should only be used right in front of
 * CPrintToChatAll or CPrintToChatAllEx and it tells
 * to those funcions to skip specified client when printing
 * message to all clients. After message is printed client will
 * no more be skipped.
 * 
 * @param client   Client index
 * @return		   No return
 */
stock CSkipNextClient(client)
{
	if (client <= 0 || client > MaxClients)
		ThrowError("Invalid client index %d", client);
	
	CSkipList[client] = true;
}

/**
 * Replaces color tags in a string with color codes
 *
 * @param szMessage   String.
 * @param maxlength   Maximum length of the string buffer.
 * @return			  Client index that can be used for SayText2 author index
 * 
 * On error/Errors:   If there is more then one team color is used an error will be thrown.
 */
stock CFormat(String:szMessage[], maxlength, author=NO_INDEX)
{
	decl String:szGameName[30];
	
	GetGameFolderName(szGameName, sizeof(szGameName));
	
	/* Hook event for auto profile setup on map start */
	if (!CEventIsHooked)
	{
		CSetupProfile();
		HookEvent("server_spawn", CEvent_MapStart, EventHookMode_PostNoCopy);
		
		CEventIsHooked = true;
	}
	
	new iRandomPlayer = NO_INDEX;
	
	// On CS:GO set invisible precolor
	if (StrEqual(szGameName, "csgo", false)) 
		Format(szMessage, maxlength, " \x01\x0B\x01%s", szMessage);
	
	/* If author was specified replace {teamcolor} tag */
	if (author != NO_INDEX)
	{
		if (CProfile_SayText2)
		{
			ReplaceString(szMessage, maxlength, "{teamcolor}", "\x03", false);
			
			iRandomPlayer = author;
		}
		/* If saytext2 is not supported by game replace {teamcolor} with green tag  */
		else
			ReplaceString(szMessage, maxlength, "{teamcolor}", CTagCode[Color_Green], false);
	}
	else
		ReplaceString(szMessage, maxlength, "{teamcolor}", "", false);
	
	/* For other color tags we need a loop */
	for (new i = 0; i < MAX_COLORS; i++)
	{
		/* If tag not found - skip */
		if (StrContains(szMessage, CTag[i], false) == -1)
			continue;
			
		/* If tag is not supported by game replace it with green tag */
		else if (!CProfile_Colors[i])
			ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green], false);
		
		/* If tag doesn't need saytext2 simply replace */
		else if (!CTagReqSayText2[i])
			ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i], false);

		/* Tag needs saytext2 */
		else
		{
			/* If saytext2 is not supported by game replace tag with green tag */
			if (!CProfile_SayText2)
				ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green], false);
				
			/* Game supports saytext2 */
			else 
			{
				/* If random player for tag wasn't specified replace tag and find player */
				if (iRandomPlayer == NO_INDEX)
				{
					/* Searching for valid client for tag */
					iRandomPlayer = CFindRandomPlayerByTeam(CProfile_TeamIndex[i]);
					
					/* If player not found replace tag with green color tag */
					if (iRandomPlayer == NO_PLAYER)
						ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green], false);

					/* If player was found simply replace */
					else
						ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i], false);
					
				}
				/* If found another team color tag throw error */
				else
				{
					//ReplaceString(szMessage, maxlength, CTag[i], "");
					ThrowError("Using two team colors in one message is not allowed");
				}
			}
			
		}
	}
	
	return iRandomPlayer;
}

/**
 * Founds a random player with specified team
 *
 * @param color_team  Client team.
 * @return			  Client index or NO_PLAYER if no player found
 */
stock CFindRandomPlayerByTeam(color_team)
{
	if (color_team == SERVER_INDEX)
		return 0;
	else
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == color_team)
				return i;
		}	
	}

	return NO_PLAYER;
}

/**
 * Sends a SayText2 usermessage to a client
 *
 * @param szMessage   Client index
 * @param maxlength   Author index
 * @param szMessage   Message
 * @return			  No return.
 */
stock CSayText2(client, author, const String:szMessage[])
{
	new Handle:hBuffer = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
	{
		PbSetInt(hBuffer, "ent_idx", author);
		PbSetBool(hBuffer, "chat", true);
		PbSetString(hBuffer, "msg_name", szMessage);
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
	}
	else
	{
		BfWriteByte(hBuffer, author);
		BfWriteByte(hBuffer, true);
		BfWriteString(hBuffer, szMessage);
	}
	
	EndMessage();
}

/**
 * Creates game color profile 
 * This function must be edited if you want to add more games support
 *
 * @return			  No return.
 */
stock CSetupProfile()
{
	decl String:szGameName[30];
	GetGameFolderName(szGameName, sizeof(szGameName));
	
	if (StrEqual(szGameName, "cstrike", false))
	{
		CProfile_Colors[Color_Lightgreen] = true;
		CProfile_Colors[Color_Red] = true;
		CProfile_Colors[Color_Blue] = true;
		CProfile_Colors[Color_Olive] = true;
		CProfile_TeamIndex[Color_Lightgreen] = SERVER_INDEX;
		CProfile_TeamIndex[Color_Red] = 2;
		CProfile_TeamIndex[Color_Blue] = 3;
		CProfile_SayText2 = true;
	}
	else if (StrEqual(szGameName, "csgo", false))
	{
		CProfile_Colors[Color_Red] = true;
		CProfile_Colors[Color_Blue] = true;
		CProfile_Colors[Color_Olive] = true;
		CProfile_Colors[Color_Darkred] = true;
		CProfile_Colors[Color_Lime] = true;
		CProfile_Colors[Color_Lightred] = true;
		CProfile_Colors[Color_Purple] = true;
		CProfile_Colors[Color_Grey] = true;
		CProfile_Colors[Color_Orange] = true;
		CProfile_TeamIndex[Color_Red] = 2;
		CProfile_TeamIndex[Color_Blue] = 3;
		CProfile_SayText2 = true;
	}
	else if (StrEqual(szGameName, "tf", false))
	{
		CProfile_Colors[Color_Lightgreen] = true;
		CProfile_Colors[Color_Red] = true;
		CProfile_Colors[Color_Blue] = true;
		CProfile_Colors[Color_Olive] = true;
		CProfile_TeamIndex[Color_Lightgreen] = SERVER_INDEX;
		CProfile_TeamIndex[Color_Red] = 2;
		CProfile_TeamIndex[Color_Blue] = 3;
		CProfile_SayText2 = true;
	}
	else if (StrEqual(szGameName, "left4dead", false) || StrEqual(szGameName, "left4dead2", false))
	{
		CProfile_Colors[Color_Lightgreen] = true;
		CProfile_Colors[Color_Red] = true;
		CProfile_Colors[Color_Blue] = true;
		CProfile_Colors[Color_Olive] = true;		
		CProfile_TeamIndex[Color_Lightgreen] = SERVER_INDEX;
		CProfile_TeamIndex[Color_Red] = 3;
		CProfile_TeamIndex[Color_Blue] = 2;
		CProfile_SayText2 = true;
	}
	else if (StrEqual(szGameName, "hl2mp", false))
	{
		/* hl2mp profile is based on mp_teamplay convar */
		if (GetConVarBool(FindConVar("mp_teamplay")))
		{
			CProfile_Colors[Color_Red] = true;
			CProfile_Colors[Color_Blue] = true;
			CProfile_Colors[Color_Olive] = true;
			CProfile_TeamIndex[Color_Red] = 3;
			CProfile_TeamIndex[Color_Blue] = 2;
			CProfile_SayText2 = true;
		}
		else
		{
			CProfile_SayText2 = false;
			CProfile_Colors[Color_Olive] = true;
		}
	}
	else if (StrEqual(szGameName, "dod", false))
	{
		CProfile_Colors[Color_Olive] = true;
		CProfile_SayText2 = false;
	}
	/* Profile for other games */
	else
	{
		if (GetUserMessageId("SayText2") == INVALID_MESSAGE_ID)
		{
			CProfile_SayText2 = false;
		}
		else
		{
			CProfile_Colors[Color_Red] = true;
			CProfile_Colors[Color_Blue] = true;
			CProfile_TeamIndex[Color_Red] = 2;
			CProfile_TeamIndex[Color_Blue] = 3;
			CProfile_SayText2 = true;
		}
	}
}

public Action:CEvent_MapStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	CSetupProfile();
	
	for (new i = 1; i <= MaxClients; i++)
		CSkipList[i] = false;
}

/**
 * Displays usage of an admin command to users depending on the 
 * setting of the sm_show_activity cvar.  
 *
 * This version does not display a message to the originating client 
 * if used from chat triggers or menus.  If manual replies are used 
 * for these cases, then this function will suffice.  Otherwise, 
 * CShowActivity2() is slightly more useful.
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 * @error
 */
stock CShowActivity(client, const String:format[], any:...)
{
	if (sm_show_activity == INVALID_HANDLE)
		sm_show_activity = FindConVar("sm_show_activity");
		
	new String:tag[] = "[SM] ";
	
	decl String:szBuffer[MAX_MESSAGE_LENGTH];
	//decl String:szCMessage[MAX_MESSAGE_LENGTH];
	new value = GetConVarInt(sm_show_activity);
	new ReplySource:replyto = GetCmdReplySource();
	
	new String:name[MAX_NAME_LENGTH] = "Console";
	new String:sign[MAX_NAME_LENGTH] = "ADMIN";
	new bool:display_in_chat = false;
	if (client != 0)
	{
		if (client < 0 || client > MaxClients || !IsClientConnected(client))
			ThrowError("Client index %d is invalid", client);
		
		GetClientName(client, name, sizeof(name));
		new AdminId:id = GetUserAdmin(client);
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
			
			CRemoveTags(szBuffer, sizeof(szBuffer));
			PrintToConsole(client, "%s%s\n", tag, szBuffer);
			display_in_chat = true;
		}
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 3);
		
		CRemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s\n", tag, szBuffer);
	}
	
	if (!value)
	{
		return 1;
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)
			|| IsFakeClient(i)
			|| (display_in_chat && i == client))
		{
			continue;
		}
		new AdminId:id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID
			|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2))
			{
				new String:newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 2) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 3);
				
				CPrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else
		{
			/* Treat this as an admin user */
			new bool:is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
			if ((value & 4)
				|| (value & 8)
				|| ((value & 16) && is_root))
			{
				new String:newsign[MAX_NAME_LENGTH]
				newsign = sign;
				if ((value & 8) || ((value & 16) && is_root) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 3);
				
				CPrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}
	
	return 1;
}

/**
 * Same as CShowActivity(), except the tag parameter is used instead of "[SM] " (note that you must supply any spacing).
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param tags			Tag to display with.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 * @error
 */
stock CShowActivityEx(client, const String:tag[], const String:format[], any:...)
{
	if (sm_show_activity == INVALID_HANDLE)
		sm_show_activity = FindConVar("sm_show_activity");
		
	decl String:szBuffer[MAX_MESSAGE_LENGTH];
	//decl String:szCMessage[MAX_MESSAGE_LENGTH];
	new value = GetConVarInt(sm_show_activity);
	new ReplySource:replyto = GetCmdReplySource();
	
	new String:name[MAX_NAME_LENGTH] = "Console";
	new String:sign[MAX_NAME_LENGTH] = "ADMIN";
	new bool:display_in_chat = false;
	if (client != 0)
	{
		if (client < 0 || client > MaxClients || !IsClientConnected(client))
			ThrowError("Client index %d is invalid", client);
		
		GetClientName(client, name, sizeof(name));
		new AdminId:id = GetUserAdmin(client);
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
			
			CRemoveTags(szBuffer, sizeof(szBuffer));
			PrintToConsole(client, "%s%s\n", tag, szBuffer);
			display_in_chat = true;
		}
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);
		
		CRemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s\n", tag, szBuffer);
	}
	
	if (!value)
	{
		return 1;
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)
			|| IsFakeClient(i)
			|| (display_in_chat && i == client))
		{
			continue;
		}
		new AdminId:id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID
			|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2))
			{
				new String:newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 2) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				CPrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else
		{
			/* Treat this as an admin user */
			new bool:is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
			if ((value & 4)
				|| (value & 8)
				|| ((value & 16) && is_root))
			{
				new String:newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 8) || ((value & 16) && is_root) || (i == client))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				CPrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
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
stock CShowActivity2(client, const String:tag[], const String:format[], any:...)
{
	if (sm_show_activity == INVALID_HANDLE)
		sm_show_activity = FindConVar("sm_show_activity");
	
	decl String:szBuffer[MAX_MESSAGE_LENGTH];
	//decl String:szCMessage[MAX_MESSAGE_LENGTH];
	new value = GetConVarInt(sm_show_activity);
	new ReplySource:replyto = GetCmdReplySource();
	
	new String:name[MAX_NAME_LENGTH] = "Console";
	new String:sign[MAX_NAME_LENGTH] = "ADMIN";
	if (client != 0)
	{
		if (client < 0 || client > MaxClients || !IsClientConnected(client))
			ThrowError("Client index %d is invalid", client);
		
		GetClientName(client, name, sizeof(name));
		new AdminId:id = GetUserAdmin(client);
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
		CPrintToChatEx(client, client, "%s%s", tag, szBuffer);
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);
		
		CRemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s\n", tag, szBuffer);
	}
	
	if (!value)
	{
		return 1;
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)
		|| IsFakeClient(i)
		|| i == client)
		{
			continue;
		}
		new AdminId:id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID
		|| !GetAdminFlag(id, Admin_Generic, Access_Effective))
		{
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2))
			{
				new String:newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 2))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				CPrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else
		{
			/* Treat this as an admin user */
			new bool:is_root = GetAdminFlag(id, Admin_Root, Access_Effective);
			if ((value & 4)
			|| (value & 8)
			|| ((value & 16) && is_root))
			{
				new String:newsign[MAX_NAME_LENGTH];
				newsign = sign;
				if ((value & 8) || ((value & 16) && is_root))
				{
					newsign = name;
				}
				VFormat(szBuffer, sizeof(szBuffer), format, 4);
				
				CPrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}
	
	return 1;	
}