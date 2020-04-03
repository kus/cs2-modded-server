char keygroupRefereeCards[PLATFORM_MAX_PATH];

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void RefereeOnPluginStart()
{
    BuildPath(Path_SM, keygroupRefereeCards, sizeof(keygroupRefereeCards), "data/soccer_mod_referee_cards.txt");
}

public void RefereeEventPlayerSpawn(Event event)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);

    char clientSteamid[32];
    GetClientAuthId(client, AuthId_Engine, clientSteamid, sizeof(clientSteamid));

    if (PlayerHasCard(clientSteamid, "red"))
    {
        ChangeClientTeam(client, 1);
        PrintToChat(client, "[Soccer Mod]\x04 %t", "You have been put to spectator because you have a red card");
    }
}

// ***********************************************************************************************************
// ************************************************** MENUS **************************************************
// ***********************************************************************************************************
public void OpenRefereeMenu(int client)
{
    Menu menu = new Menu(RefereeMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Referee", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Yellow card", client);
    menu.AddItem("yellow", langString);

    Format(langString, sizeof(langString), "%T", "Red card", client);
    menu.AddItem("red", langString);

    Format(langString, sizeof(langString), "%T", "Remove red card", client);
    menu.AddItem("remove_red", langString);

    Format(langString, sizeof(langString), "%T", "Remove all cards", client);
    menu.AddItem("remove_all", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int RefereeMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "yellow"))                   OpenRefereeYellowCardMenu(client);
        else if (StrEqual(menuItem, "red"))                 OpenRefereeRedCardMenu(client);
        else if (StrEqual(menuItem, "remove_red"))          OpenRemoveRedCardMenu(client);
        else if (StrEqual(menuItem, "remove_all"))          RemoveAllCards(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuAdmin(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenRefereeYellowCardMenu(int client)
{
    Menu menu = new Menu(RefereeYellowCardMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Referee", client);
    Format(langString3, sizeof(langString3), "%T", "Yellow card", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s", langString1, langString2, langString3);
    menu.SetTitle(langString);

    int count = 0;
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player))
        {
            char playerSteamid[32];
            GetClientAuthId(player, AuthId_Engine, playerSteamid, sizeof(playerSteamid));

            if (!PlayerHasCard(playerSteamid, "red"))
            {
                count++;

                char playerid[8];
                IntToString(player, playerid, sizeof(playerid));

                char playerName[MAX_NAME_LENGTH];
                GetClientName(player, playerName, sizeof(playerName));

                Format(langString1, sizeof(langString1), "%T", "Yellow", client);
                if (PlayerHasCard(playerSteamid, "yellow")) Format(playerName, sizeof(playerName), "%s (%s)", playerName, langString1);

                menu.AddItem(playerid, playerName);
            }
        }
    }

    if (count)
    {
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
        PrintToChat(client, "[Soccer Mod]\x04 %t", "All players already have a red card");
        OpenRefereeMenu(client);
    }
}

public int RefereeYellowCardMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[8];
        menu.GetItem(choice, menuItem, sizeof(menuItem));
        int target = StringToInt(menuItem);

        if (IsClientInGame(target) && IsClientConnected(target))
        {
            char clientSteamid[32];
            GetClientAuthId(client, AuthId_Engine, clientSteamid, sizeof(clientSteamid));

            char targetSteamid[32];
            GetClientAuthId(target, AuthId_Engine, targetSteamid, sizeof(targetSteamid));

            KeyValues keygroup = new KeyValues("refereeCards");
            keygroup.ImportFromFile(keygroupRefereeCards);
            keygroup.JumpToKey(targetSteamid, true);

            char targetName[MAX_NAME_LENGTH];
            GetClientName(target, targetName, sizeof(targetName));
            keygroup.SetString("name", targetName);

            if (keygroup.GetNum("yellow", 0))
            {
                keygroup.SetNum("yellow", 0);
                keygroup.SetNum("red", 1);

                ChangeClientTeam(target, 1);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has given a second yellow card to $target", client, target);
                }

                LogMessage("%N <%s> has given a second yellow card to %N <%s>", client, clientSteamid, target, targetSteamid);
            }
            else
            {
                keygroup.SetNum("yellow", 1);
                keygroup.SetNum("red", 0);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has given a yellow card to $target", client, target);
                }

                LogMessage("%N <%s> has given a yellow card to %N <%s>", client, clientSteamid, target, targetSteamid);
            }

            keygroup.Rewind();
            keygroup.ExportToFile(keygroupRefereeCards);
            keygroup.Close();
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Player is no longer on the server");

        OpenRefereeMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenRefereeMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenRefereeRedCardMenu(int client)
{
    Menu menu = new Menu(RefereeRedCardMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Referee", client);
    Format(langString3, sizeof(langString3), "%T", "Red card", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s", langString1, langString2, langString3);
    menu.SetTitle(langString);

    int count = 0;
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player))
        {
            char playerSteamid[32];
            GetClientAuthId(player, AuthId_Engine, playerSteamid, sizeof(playerSteamid));

            if (!PlayerHasCard(playerSteamid, "red"))
            {
                count++;

                char playerid[8];
                IntToString(player, playerid, sizeof(playerid));

                char playerName[MAX_NAME_LENGTH];
                GetClientName(player, playerName, sizeof(playerName));

                Format(langString1, sizeof(langString1), "%T", "Yellow", client);
                if (PlayerHasCard(playerSteamid, "yellow")) Format(playerName, sizeof(playerName), "%s (%s)", playerName, langString1);

                menu.AddItem(playerid, playerName);
            }
        }
    }

    if (count)
    {
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
        PrintToChat(client, "[Soccer Mod]\x04 %t", "All players already have a red card");
        OpenRefereeMenu(client);
    }
}

public int RefereeRedCardMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[8];
        menu.GetItem(choice, menuItem, sizeof(menuItem));
        int target = StringToInt(menuItem);

        if (IsClientInGame(target) && IsClientConnected(target))
        {
            char targetSteamid[32];
            GetClientAuthId(target, AuthId_Engine, targetSteamid, sizeof(targetSteamid));

            KeyValues keygroup = new KeyValues("refereeCards");
            keygroup.ImportFromFile(keygroupRefereeCards);
            keygroup.JumpToKey(targetSteamid, true);

            if (!keygroup.GetNum("red", 0))
            {
                char targetName[MAX_NAME_LENGTH];
                GetClientName(target, targetName, sizeof(targetName));
                keygroup.SetString("name", targetName);

                keygroup.SetNum("yellow", 0);
                keygroup.SetNum("red", 1);

                ChangeClientTeam(target, 1);

                char clientSteamid[32];
                GetClientAuthId(client, AuthId_Engine, clientSteamid, sizeof(clientSteamid));

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has given a red card to $target", client, target);
                }

                LogMessage("%N <%s> has given a red card to %N <%s>", client, clientSteamid, target, targetSteamid);
            }
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "Player already has a red card");

            keygroup.Rewind();
            keygroup.ExportToFile(keygroupRefereeCards);
            keygroup.Close();
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Player is no longer on the server");

        OpenRefereeMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenRefereeMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenRemoveRedCardMenu(int client)
{
    Menu menu = new Menu(RemoveRedCardMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Referee", client);
    Format(langString3, sizeof(langString3), "%T", "Remove red card", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s", langString1, langString2, langString3);
    menu.SetTitle(langString);

    int count = 0;
    char playerName[MAX_NAME_LENGTH];
    char playerSteamid[32];

    KeyValues keygroup = new KeyValues("refereeCards");
    keygroup.ImportFromFile(keygroupRefereeCards);
    keygroup.GotoFirstSubKey();

    do
    {
        if (keygroup.GetNum("red", 0))
        {
            count++;

            keygroup.GetSectionName(playerSteamid, sizeof(playerSteamid));
            keygroup.GetString("name", playerName, sizeof(playerName));
            menu.AddItem(playerSteamid, playerName);
        }
    }
    while (keygroup.GotoNextKey());
    keygroup.Close();

    if (count)
    {
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
        PrintToChat(client, "[Soccer Mod]\x04 %t", "There are no players with a red card");
        OpenRefereeMenu(client);
    }
}

public int RemoveRedCardMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char targetSteamid[32];
        menu.GetItem(choice, targetSteamid, sizeof(targetSteamid));

        KeyValues keygroup = new KeyValues("refereeCards");
        keygroup.ImportFromFile(keygroupRefereeCards);
        keygroup.JumpToKey(targetSteamid, true);

        if (keygroup.GetNum("red", 0))
        {
            char clientSteamid[32];
            GetClientAuthId(client, AuthId_Engine, clientSteamid, sizeof(clientSteamid));

            char playerName[MAX_NAME_LENGTH];
            keygroup.GetString("name", playerName, sizeof(playerName));

            char playerSteamid[32];
            keygroup.GetSectionName(playerSteamid, sizeof(playerSteamid));

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has removed the red card from $target", client, playerName);
            }

            LogMessage("%N <%s> has removed the red card from %s <%s>", client, clientSteamid, playerName, playerSteamid);

            keygroup.SetNum("yellow", 0);
            keygroup.SetNum("red", 0);

            keygroup.Rewind();
            keygroup.ExportToFile(keygroupRefereeCards);
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Red card already removed");

        keygroup.Close();

        OpenRefereeMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenRefereeMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ***************************************************************************************************************
// ************************************************** FUNCTIONS **************************************************
// ***************************************************************************************************************
public bool PlayerHasCard(char[] steamid, char[] card)
{
    KeyValues keygroup = new KeyValues("refereeCards");
    keygroup.ImportFromFile(keygroupRefereeCards);

    keygroup.JumpToKey(steamid, true);

    if (keygroup.GetNum(card, 0)) return true;
    return false;
}

public void RemoveAllCards(int client)
{
    DeleteFile(keygroupRefereeCards);

    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has removed all cards", client);
    }

    char clientSteamid[32];
    GetClientAuthId(client, AuthId_Engine, clientSteamid, sizeof(clientSteamid));

    LogMessage("%N <%s> removed all cards", client, clientSteamid);

    OpenRefereeMenu(client);
}