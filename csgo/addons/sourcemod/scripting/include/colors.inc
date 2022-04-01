/**************************************************************************
 *                                                                        *
 *                       Colored Chat Functions                           *
 *                            Author: exvel                               *
 *                           Version: 1.0.5                               *
 *                                                                        *
 **************************************************************************/

#if defined _colors_included
 #endinput
#endif
#define _colors_included
 
#define MAX_MESSAGE_LENGTH 250
#define MAX_COLORS 6

#define SERVER_INDEX 0
#define NO_INDEX -1
#define NO_PLAYER -2

enum Colors
{
    Color_Default = 0,
    Color_Green,
    Color_Lightgreen,
    Color_Red,
    Color_Blue,
    Color_Olive
}

/* Colors' properties */
new String:CTag[][] = {"{default}", "{green}", "{lightgreen}", "{red}", "{blue}", "{olive}"};
new String:CTagCode[][] = {"\x01", "\x04", "\x03", "\x03", "\x03", "\x05"};
new bool:CTagReqSayText2[] = {false, false, true, true, true, false};
new bool:CEventIsHooked = false;
new bool:CSkipList[MAXPLAYERS+1] = {false,...};

/* Game default profile */
new bool:CProfile_Colors[] = {true, true, false, false, false, false};
new CProfile_TeamIndex[] = {NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX};
new bool:CProfile_SayText2 = false;
new bool:IsGameCsgo = false;

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags.
 *
 * @param client      Client index.
 * @param szMessage   Message (formatting rules).
 * @return            No return
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
    if (IsGameCsgo) {
        Format(szBuffer, sizeof(szBuffer), "\x01\x0B%s", szMessage);
    } else {
        Format(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
    }
    VFormat(szCMessage, sizeof(szCMessage), szBuffer, 3);
    
    new index = CFormat(szCMessage, sizeof(szCMessage));
    if (index == NO_INDEX)
    {
        PrintToChat(client, szCMessage);
    }
    else
    {
        CSayText2(client, index, szCMessage);
    }
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags.
 *
 * @param client      Client index.
 * @param szMessage   Message (formatting rules)
 * @return            No return
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
            CPrintToChat(i, szBuffer);
        }
        
        CSkipList[i] = false;
    }
}

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param client      Client index.
 * @param author      Author index whose color will be used for teamcolor tag.
 * @param szMessage   Message (formatting rules).
 * @return            No return
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
    if (IsGameCsgo) {
        Format(szBuffer, sizeof(szBuffer), "\x01\x0B%s", szMessage);
    } else {
        Format(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
    }
    VFormat(szCMessage, sizeof(szCMessage), szBuffer, 4);
    
    new index = CFormat(szCMessage, sizeof(szCMessage), author);
    if (index == NO_INDEX)
    {
        PrintToChat(client, szCMessage);
    }
    else
    {
        CSayText2(client, author, szCMessage);
    }
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param author      Author index whos color will be used for teamcolor tag.
 * @param szMessage   Message (formatting rules).
 * @return            No return
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
            CPrintToChatEx(i, author, szBuffer);
        }
        
        CSkipList[i] = false;
    }
}

/**
 * Removes color tags from the string.
 *
 * @param szMessage   String.
 * @return            No return
 */
stock CRemoveTags(String:szMessage[], maxlength)
{
    for (new i = 0; i < MAX_COLORS; i++)
    {
        ReplaceString(szMessage, maxlength, CTag[i], "");
    }
    
    ReplaceString(szMessage, maxlength, "{teamcolor}", "");
}

/**
 * This function should only be used right in front of
 * CPrintToChatAll or CPrintToChatAllEx and it tells
 * to those funcions to skip specified client when printing
 * message to all clients. After message is printed client will
 * no more be skipped.
 * 
 * @param client   Client index
 * @return         No return
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
 * @return            Client index that can be used for SayText2 author index
 * 
 * On error/Errors:   If there is more then one team color is used an error will be thrown.
 */
stock CFormat(String:szMessage[], maxlength, author=NO_INDEX)
{
    /* Hook event for auto profile setup on map start */
    if (!CEventIsHooked)
    {
        CSetupProfile();
        HookEvent("server_spawn", CEvent_MapStart, EventHookMode_PostNoCopy);
        CEventIsHooked = true;
    }
    
    new iRandomPlayer = NO_INDEX;
    
    /* If author was specified replace {teamcolor} tag */
    if (author != NO_INDEX)
    {
        if (CProfile_SayText2)
        {
            ReplaceString(szMessage, maxlength, "{teamcolor}", "\x03");
            iRandomPlayer = author;
        }
        /* If saytext2 is not supported by game replace {teamcolor} with green tag  */
        else
        {
            ReplaceString(szMessage, maxlength, "{teamcolor}", CTagCode[Color_Green]);
        }
    }
    else
    {
        ReplaceString(szMessage, maxlength, "{teamcolor}", "");
    }
    
    /* For other color tags we need a loop */
    for (new i = 0; i < MAX_COLORS; i++)
    {
        /* If tag not found - skip */
        if (StrContains(szMessage, CTag[i]) == -1)
        {
            continue;
        }
        /* If tag is not supported by game replace it with green tag */
        else if (!CProfile_Colors[i])
        {
            ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green]);
        }
        /* If tag doesn't need saytext2 simply replace */
        else if (!CTagReqSayText2[i])
        {
            ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i]);
        }
        /* Tag needs saytext2 */
        else
        {
            /* If saytext2 is not supported by game replace tag with green tag */
            if (!CProfile_SayText2)
            {
                ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green]);
            }
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
                    {
                        ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green]);
                    }
                    /* If player was found simply replace */
                    else
                    {
                        ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i]);
                    }
                    
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
 * @return            Client index or NO_PLAYER if no player found
 */
stock CFindRandomPlayerByTeam(color_team)
{
    if (color_team == SERVER_INDEX)
    {
        return 0;
    }
    else
    {
        for (new i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && GetClientTeam(i) == color_team)
            {
                return i;
            }
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
 * @return            No return.
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
 * @return            No return.
 */
stock CSetupProfile()
{
    decl String:szGameName[30];
    GetGameFolderName(szGameName, sizeof(szGameName));
    
    if (StrEqual(szGameName, "cstrike", false) || StrEqual(szGameName, "csgo", false))
    {
        IsGameCsgo = StrEqual(szGameName, "csgo", false);
        CProfile_Colors[Color_Lightgreen] = true;
        CProfile_Colors[Color_Red] = true;
        CProfile_Colors[Color_Blue] = true;
        CProfile_Colors[Color_Olive] = true;
        CProfile_TeamIndex[Color_Lightgreen] = SERVER_INDEX;
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
    {
        CSkipList[i] = false;
    }
}