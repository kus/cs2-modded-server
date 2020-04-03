// *****************************************************************************************************************
// ************************************************** SOCCER MENU **************************************************
// *****************************************************************************************************************
public void OpenMenuSoccer(int client)
{
    Menu menu = new Menu(MenuHandlerSoccer);
    menu.SetTitle("Soccer Mod");

    char langString[64];

    if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC))
    {
        Format(langString, sizeof(langString), "%T", "Admin", client);
        menu.AddItem("admin", langString);
    }

    Format(langString, sizeof(langString), "%T", "Ranking", client);
    menu.AddItem("ranking", langString);

    Format(langString, sizeof(langString), "%T", "Statistics", client);
    menu.AddItem("stats", langString);

    Format(langString, sizeof(langString), "%T", "Positions", client);
    menu.AddItem("positions", langString);

    Format(langString, sizeof(langString), "%T", "Help", client);
    menu.AddItem("help", langString);

    Format(langString, sizeof(langString), "%T", "Credits", client);
    menu.AddItem("credits", langString);

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerSoccer(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "admin"))
        {
            if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC)) OpenMenuAdmin(client);
            else
            {
                PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not allowed to use this option");
                OpenMenuSoccer(client);
            }
        }
        else if (StrEqual(menuItem, "help"))        OpenMenuHelp(client);
        else if (StrEqual(menuItem, "credits"))     OpenMenuCredits(client);
        else if (currentMapAllowed)
        {
            if (StrEqual(menuItem, "positions"))    OpenCapPositionMenu(client);
            else if (StrEqual(menuItem, "ranking")) OpenRankingMenu(client);
            else if (StrEqual(menuItem, "stats"))   OpenStatisticsMenu(client);
        }
        else
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
            OpenMenuSoccer(client);
        }
    }
    else if (action == MenuAction_End) menu.Close();
}

// ****************************************************************************************************************
// ************************************************** ADMIN MENU **************************************************
// ****************************************************************************************************************
public void OpenMenuAdmin(int client)
{
    Menu menu = new Menu(MenuHandlerAdmin);

    char langString[64];
    Format(langString, sizeof(langString), "Soccer Mod - %T", "Admin", client);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Match", client);
    menu.AddItem("match", langString);

    Format(langString, sizeof(langString), "%T", "Cap", client);
    menu.AddItem("cap", langString);

    Format(langString, sizeof(langString), "%T", "Referee", client);
    menu.AddItem("referee", langString);

    Format(langString, sizeof(langString), "%T", "Training", client);
    menu.AddItem("training", langString);

    Format(langString, sizeof(langString), "%T", "Spec player", client);
    menu.AddItem("spec", langString);

    Format(langString, sizeof(langString), "%T", "Settings", client);
    menu.AddItem("settings", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerAdmin(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "settings"))                 OpenMenuSettings(client);
        else if (StrEqual(menuItem, "spec"))                OpenMenuSpecPlayer(client);
        else if (currentMapAllowed)
        {
            if (StrEqual(menuItem, "match"))                OpenMatchMenu(client);
            else if (StrEqual(menuItem, "cap"))             OpenCapMenu(client);
            else if (StrEqual(menuItem, "referee"))         OpenRefereeMenu(client);
            else if (StrEqual(menuItem, "training"))        OpenTrainingMenu(client);
        }
        else
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
            OpenMenuAdmin(client);
        }
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSoccer(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// *******************************************************************************************************************
// ************************************************** SETTINGS MENU **************************************************
// *******************************************************************************************************************
public void OpenMenuSettings(int client)
{
    Menu menu = new Menu(MenuHandlerSettings);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Settings", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Skins", client);
    menu.AddItem("skins", langString);

    if (debuggingEnabled) menu.AddItem("gk_areas", "Set gk area's");

    Format(langString, sizeof(langString), "%T", "Allowed maps", client);
    menu.AddItem("maps", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerSettings(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "maps"))                     OpenMenuMaps(client);
        else if (currentMapAllowed)
        {
            if (StrEqual(menuItem, "skins"))                OpenSkinsMenu(client);
            else if (StrEqual(menuItem, "gk_areas"))        OpenMenuGKAreas(client);
        }
        else
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Soccer Mod is not allowed on this map");
            OpenMenuSettings(client);
        }
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuAdmin(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ************************************************** TEST **************************************************
public void OpenMenuGKAreas(int client)
{
    Menu menu = new Menu(MenuHandlerGKAreas);
    menu.SetTitle("Soccer Mod - Admin - Settings - GK area's");

    int index;
    char entityName[64];

    while ((index = FindEntityByClassname(index, "trigger_once")) != INVALID_ENT_REFERENCE)
    {
        char playerIndex[8];
        IntToString(index, playerIndex, sizeof(playerIndex));
        GetEntPropString(index, Prop_Data, "m_iName", entityName, sizeof(entityName));
        menu.AddItem(playerIndex, entityName);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerGKAreas(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char chosenMenuItem[32];
        menu.GetItem(choice, chosenMenuItem, sizeof(chosenMenuItem));
        int index = StringToInt(chosenMenuItem);

        float start[3];
        float end[3];
        float origin[3];
        GetEntPropVector(index, Prop_Data, "m_vecMins", start);
        GetEntPropVector(index, Prop_Data, "m_vecMaxs", end);
        GetEntPropVector(index, Prop_Data, "m_vecOrigin", origin);

        float xWidth;
        float yWidth;
        float zWidth;
        xWidth = end[0] - start[0];
        yWidth = end[1] - start[1];
        zWidth = end[2] - start[2];

        float ballPosition[3];
        int ball = GetEntityIndexByName("ball", "prop_physics");
        GetEntPropVector(ball, Prop_Send, "m_vecOrigin", ballPosition);

        float deltaX;
        float deltaY;
        float deltaZ;
        deltaX = origin[0] - ballPosition[0];
        deltaY = origin[1] - ballPosition[1];
        deltaZ = origin[2] - ballPosition[2];

        float distance;
        // IN YARDS
        // distance = SquareRoot((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ)) / 36.0;
        // IN METERS
        distance = SquareRoot((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ)) * 0.0254;
        PrintToChatAll("%s dist: %fm | x: %f, y: %f, z: %f | x len: %f, y len: %f, z len: %f", PREFIX, distance, origin[0], origin[1], origin[2], xWidth, yWidth, zWidth);

        int beam;
        while ((beam = GetEntityIndexByName("gk_area_beam", "env_beam")) != -1) AcceptEntityInput(beam, "Kill");
        DrawLaser("gk_area_beam", origin[0], origin[1], origin[2], origin[0] + 200.0, origin[1], origin[2], "0 0 255");

        OpenMenuGKAreas(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSettings(client);
    else if (action == MenuAction_End)                      menu.Close();
}
// ************************************************** END TEST **************************************************

// **********************************************************************************************************************
// ************************************************** SPEC PLAYER MENU **************************************************
// **********************************************************************************************************************
public void OpenMenuSpecPlayer(int client)
{
    Menu menu = new Menu(MenuHandlerSpecPlayer);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Spec player", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    int number = 0;
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player) && GetClientTeam(player) != 1)
        {
            number++;

            char playerid[8];
            IntToString(player, playerid, sizeof(playerid));

            char playerName[MAX_NAME_LENGTH];
            GetClientName(player, playerName, sizeof(playerName));

            menu.AddItem(playerid, playerName);
        }
    }

    if (number)
    {
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
        PrintToChat(client, "[Soccer Mod]\x04 %t", "All players already are in spectator");
        OpenMenuAdmin(client);
    }
}

public int MenuHandlerSpecPlayer(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[8];
        menu.GetItem(choice, menuItem, sizeof(menuItem));
        int target = StringToInt(menuItem);

        if (IsClientInGame(target) && IsClientConnected(target))
        {
            if (GetClientTeam(target) != 1)
            {
                ChangeClientTeam(target, 1);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has put $target to spectator", client, target);
                }

                char clientSteamid[32];
                GetClientAuthId(client, AuthId_Engine, clientSteamid, sizeof(clientSteamid));

                char targetSteamid[32];
                GetClientAuthId(target, AuthId_Engine, targetSteamid, sizeof(targetSteamid));

                LogMessage("%N <%s> has put %N <%s> to spectator", client, clientSteamid, target, targetSteamid);
            }
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "Player is already in spectator");
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Player is no longer on the server");

        OpenMenuAdmin(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuAdmin(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ***************************************************************************************************************
// ************************************************** MAPS MENU **************************************************
// ***************************************************************************************************************
public void OpenMenuMaps(int client)
{
    Menu menu = new Menu(MenuHandlerMaps);

    char langString[64], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Settings", client);
    Format(langString3, sizeof(langString3), "%T", "Allowed maps", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s", langString1, langString2, langString3);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Add", client);
    menu.AddItem("add", langString);

    Format(langString, sizeof(langString), "%T", "Change", client);
    menu.AddItem("change", langString);

    Format(langString, sizeof(langString), "%T", "Remove", client);
    menu.AddItem("remove", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerMaps(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[16];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "add"))                      OpenMenuMapsAdd(client);
        else if (StrEqual(menuItem, "change"))              OpenMenuMapsChange(client);
        else if (StrEqual(menuItem, "remove"))              OpenMenuMapsRemove(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSettings(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ******************************************************************************************************************
// ************************************************** ADD MAP MENU **************************************************
// ******************************************************************************************************************
public void OpenMenuMapsAdd(int client)
{
    Menu menu = new Menu(MenuHandlerMapsAdd);

    char langString[128], langString1[64], langString2[64], langString3[64], langString4[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Settings", client);
    Format(langString3, sizeof(langString3), "%T", "Allowed maps", client);
    Format(langString4, sizeof(langString4), "%T", "Add", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s - %s", langString1, langString2, langString3, langString4);
    menu.SetTitle(langString);

    OpenMapsDirectory("maps", menu);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerMapsAdd(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char map[128];
        menu.GetItem(choice, map, sizeof(map));

        if (FindStringInArray(allowedMaps, map) > -1) PrintToChat(client, "[Soccer Mod]\x04 %t", "$map is already added to the allowed maps list", map);
        else
        {
            PushArrayString(allowedMaps, map);
            SaveAllowedMaps();

            PrintToChat(client, "[Soccer Mod]\x04 %t", "$map added to the allowed maps list", map);
        }

        OpenMenuMaps(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuMaps(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// *********************************************************************************************************************
// ************************************************** CHANGE MAP MENU **************************************************
// *********************************************************************************************************************
public void OpenMenuMapsChange(int client)
{
    File file = OpenFile(allowedMapsConfigFile, "r");

    if (file != null)
    {
        Menu menu = new Menu(MenuHandlerMapsChange);

        char langString[128], langString1[64], langString2[64], langString3[64], langString4[64];
        Format(langString1, sizeof(langString1), "%T", "Admin", client);
        Format(langString2, sizeof(langString2), "%T", "Settings", client);
        Format(langString3, sizeof(langString3), "%T", "Allowed maps", client);
        Format(langString4, sizeof(langString4), "%T", "Change", client);
        Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s - %s", langString1, langString2, langString3, langString4);
        menu.SetTitle(langString);

        char map[128];
        int length;

        while (!file.EndOfFile() && file.ReadLine(map, sizeof(map)))
        {
            length = strlen(map);
            if (map[length - 1] == '\n') map[--length] = '\0';

            if (map[0] != '/' && map[1] != '/' && map[0] && IsMapValid(map)) menu.AddItem(map, map);
        }

        file.Close();
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
        PrintToChat(client, "[Soccer Mod]\x04 %t", "Allowed maps list is empty");
        OpenMenuMaps(client);
    }
}

public int MenuHandlerMapsChange(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char map[128];
        menu.GetItem(choice, map, sizeof(map));

        char command[128];
        Format(command, sizeof(command), "changelevel %s", map);

        Handle pack;
        CreateDataTimer(3.0, DelayedServerCommand, pack);
        WritePackString(pack, command);

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has changed the map to $map", client, map);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has changed the map to %s", client, steamid, map);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuMaps(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// *********************************************************************************************************************
// ************************************************** REMOVE MAP MENU **************************************************
// *********************************************************************************************************************
public void OpenMenuMapsRemove(int client)
{
    File file = OpenFile(allowedMapsConfigFile, "r");

    if (file != null)
    {
        Menu menu = new Menu(MenuHandlerMapsRemove);

        char langString[128], langString1[64], langString2[64], langString3[64], langString4[64];
        Format(langString1, sizeof(langString1), "%T", "Admin", client);
        Format(langString2, sizeof(langString2), "%T", "Settings", client);
        Format(langString3, sizeof(langString3), "%T", "Allowed maps", client);
        Format(langString4, sizeof(langString4), "%T", "Remove", client);
        Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s - %s", langString1, langString2, langString3, langString4);
        menu.SetTitle(langString);

        char map[128];
        int length;

        while (!file.EndOfFile() && file.ReadLine(map, sizeof(map)))
        {
            length = strlen(map);
            if (map[length - 1] == '\n') map[--length] = '\0';

            if (map[0] != '/' && map[1] != '/' && map[0]) menu.AddItem(map, map);
        }

        file.Close();
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
        PrintToChat(client, "[Soccer Mod]\x04 %t", "Allowed maps list is empty");
        OpenMenuMaps(client);
    }
}

public int MenuHandlerMapsRemove(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char map[128];
        menu.GetItem(choice, map, sizeof(map));

        if (FindStringInArray(allowedMaps, map) > -1)
        {
            int index = FindStringInArray(allowedMaps, map);
            RemoveFromArray(allowedMaps, index);
            SaveAllowedMaps();
            LoadAllowedMaps();

            PrintToChat(client, "[Soccer Mod]\x04 %t", "$map removed from the allowed maps list", map);
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "$map is already removed from the allowed maps list", map);

        OpenMenuMaps(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuMaps(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ***************************************************************************************************************
// ************************************************** HELP MENU **************************************************
// ***************************************************************************************************************
public void OpenMenuHelp(int client)
{
    Menu menu = new Menu(MenuHandlerHelp);

    char langString[64];
    Format(langString, sizeof(langString), "Soccer Mod - %T", "Help", client);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Chat commands", client);
    menu.AddItem("commands", langString);

    Format(langString, sizeof(langString), "%T", "Hold the walk key to sprint", client);
    menu.AddItem("sprint", langString, ITEMDRAW_DISABLED);

    Format(langString, sizeof(langString), "%T", "Guide", client);
    menu.AddItem("guide", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerHelp(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "commands"))                 OpenMenuCommands(client);
        else if (StrEqual(menuItem, "sprint"))              OpenMenuHelp(client);
        else if (StrEqual(menuItem, "guide"))
        {
            PrintToChat(client, "%s http://steamcommunity.com/sharedfiles/filedetails/?id=267151106", PREFIX);
            OpenMenuHelp(client);
        }
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSoccer(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenMenuCommands(int client)
{
    Menu menu = new Menu(MenuHandlerCommands);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Help", client);
    Format(langString2, sizeof(langString2), "%T", "Chat commands", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    menu.AddItem("soccer", "/soccer");
    menu.AddItem("stats", "/soccer stats");
    menu.AddItem("rank", "/soccer rank");
    menu.AddItem("gk", "/soccer gk");
    menu.AddItem("pick", "/soccer pick");
    menu.AddItem("admin", "/soccer admin");
    menu.AddItem("cap", "/soccer cap");
    menu.AddItem("match", "/soccer match");
    menu.AddItem("training", "/soccer training");
    menu.AddItem("restart", "/soccer rr");
    menu.AddItem("commands", "/soccer commands");
    menu.AddItem("help", "/soccer help");
    menu.AddItem("credits", "/soccer credits");

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerCommands(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "soccer"))           PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod main menu");
        else if (StrEqual(menuItem, "help"))        PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod help menu");
        else if (StrEqual(menuItem, "stats"))       PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod statistics menu");
        else if (StrEqual(menuItem, "rank"))        PrintToChat(client, "[Soccer Mod]\x04 %t", "Shows your public ranking");
        else if (StrEqual(menuItem, "gk"))          PrintToChat(client, "[Soccer Mod]\x04 %t", "Enables or disables the goalkeeper skin");
        else if (StrEqual(menuItem, "pick"))        PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod cap picking menu");
        else if (StrEqual(menuItem, "admin"))       PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod admin menu");
        else if (StrEqual(menuItem, "cap"))         PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod cap match menu");
        else if (StrEqual(menuItem, "match"))       PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod match menu");
        else if (StrEqual(menuItem, "training"))    PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod training menu");
        else if (StrEqual(menuItem, "restart"))     PrintToChat(client, "[Soccer Mod]\x04 %t", "Restarts the round");
        else if (StrEqual(menuItem, "commands"))    PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod commands menu");
        else if (StrEqual(menuItem, "credits"))     PrintToChat(client, "[Soccer Mod]\x04 %t", "Opens the Soccer Mod credits menu");

        OpenMenuCommands(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuHelp(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ******************************************************************************************************************
// ************************************************** CREDITS MENU **************************************************
// ******************************************************************************************************************
public void OpenMenuCredits(int client)
{
    Menu menu = new Menu(MenuHandlerCredits);

    char langString[64];
    Format(langString, sizeof(langString), "Soccer Mod - %T", "Credits", client);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "Marco Boogers (%T)", "Script", client);
    menu.AddItem("marco", langString);

    Format(langString, sizeof(langString), "Arctic God (%T)", "Player models", client);
    menu.AddItem("arctic", langString);

    Format(langString, sizeof(langString), "%T", "Soccer Mod group", client);
    menu.AddItem("group", langString);

    Format(langString, sizeof(langString), "%T", "Soccer Mod version: $version", client, PLUGIN_VERSION);
    menu.AddItem("group", langString, ITEMDRAW_DISABLED);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerCredits(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "marco"))        PrintToChat(client, "%s http://steamcommunity.com/id/fcd_marco/", PREFIX);
        else if (StrEqual(menuItem, "arctic"))  PrintToChat(client, "%s http://steamcommunity.com/id/quixomatic/", PREFIX);
        else if (StrEqual(menuItem, "group"))   PrintToChat(client, "%s http://steamcommunity.com/groups/soccer_mod", PREFIX);

        OpenMenuCredits(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSoccer(client);
    else if (action == MenuAction_End)                      menu.Close();
}