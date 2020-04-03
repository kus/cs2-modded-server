public void RegisterClientCommands()
{
    char langString[64];
    Format(langString, sizeof(langString), "%T", "Opens the Soccer Mod main menu", LANG_SERVER);
    RegConsoleCmd("soccer", ClientCommands, langString);
}

public Action ClientCommands(int client, int args)
{
    char cmdArg[32];
    GetCmdArg(1, cmdArg, sizeof(cmdArg));

    if (StrEqual(cmdArg, "admin"))
    {
        if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC)) OpenMenuAdmin(client);
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not allowed to use this option");
    }
    else if (StrEqual(cmdArg, "cap"))
    {
        if (currentMapAllowed)
        {
            if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC)) OpenCapMenu(client);
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not allowed to use this option");
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "match"))
    {
        if (currentMapAllowed)
        {
            if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC)) OpenMatchMenu(client);
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not allowed to use this option");
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "training"))
    {
        if (currentMapAllowed)
        {
            if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC)) OpenTrainingMenu(client);
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not allowed to use this option");
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "rr"))
    {
        if (currentMapAllowed)
        {
            if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC))
            {
                // TEMPORARY CODE TO FIND FIX FOR DISSAPPEARING BALL
                int index = GetEntityIndexByName("ball", "prop_physics");
                float position[3];
                GetEntPropVector(index, Prop_Send, "m_vecOrigin", position);
                LogMessage("Ball position (round restarted): %f, %f, %f", position[0], position[1], position[2]);
                // END TEMPORARY CODE

                CS_TerminateRound(1.0, CSRoundEnd_Draw);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has restarted the round", client);
                }

                char steamid[20];
                GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
                LogMessage("%N <%s> has restarted the round", client, steamid);
            }
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not allowed to use this option");
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "pick"))
    {
        if (currentMapAllowed) OpenCapPickMenu(client);
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "getview"))
    {
        if (currentMapAllowed)
        {
            if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC))
            {
                float viewCoord[3];
                GetAimOrigin(client, viewCoord);
                PrintToChat(client, "%s X: %f, Y: %f, Z: %f", PREFIX, viewCoord[0], viewCoord[1], viewCoord[2]);
            }
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not allowed to use this option");
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "stats"))
    {
        if (currentMapAllowed) OpenStatisticsMenu(client);
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "rank"))
    {
        if (currentMapAllowed) ClientCommandPublicRanking(client);
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "gk"))
    {
        if (currentMapAllowed) ClientCommandSetGoalkeeperSkin(client);
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "pos") || StrEqual(cmdArg, "position"))
    {
        if (currentMapAllowed) OpenCapPositionMenu(client);
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "sprint"))
    {
        if (currentMapAllowed) ClientCommandSprint(client);
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
    }
    else if (StrEqual(cmdArg, "help"))                                  OpenMenuHelp(client);
    else if (StrEqual(cmdArg, "commands"))                              OpenMenuCommands(client);
    else if (StrEqual(cmdArg, "credits") || StrEqual(cmdArg, "info"))   OpenMenuCredits(client);
    else OpenMenuSoccer(client);

    return Plugin_Handled;
}