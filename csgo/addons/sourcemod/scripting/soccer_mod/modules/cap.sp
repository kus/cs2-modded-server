int capPicker       = 0;
int capCT           = 0;
int capT            = 0;
int capPicksLeft    = 0;

char pathCapPositionsFile[PLATFORM_MAX_PATH];

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void CapOnPluginStart()
{
    BuildPath(Path_SM, pathCapPositionsFile, sizeof(pathCapPositionsFile), "data/soccer_mod_cap_positions.txt");
}

public void CapEventPlayerDeath(Event event)
{
    if (capFightStarted)
    {
        int attacker = event.GetInt("attacker");

        if (attacker)
        {
            int attackerid = GetClientOfUserId(attacker);
            capPicker = attackerid;

            int userid = event.GetInt("userid");
            int deadid = GetClientOfUserId(userid);
            int team = GetClientTeam(attackerid);

            if (team == 2)
            {
                capCT = deadid;
                capT = attackerid;
            }
            else if (team == 3)
            {
                capCT = attackerid;
                capT = deadid;
            }
        }
    }
}

public void CapEventRoundEnd(Event event)
{
    if (capFightStarted)
    {
        capFightStarted = false;

        int winner = event.GetInt("winner");
        if (winner == 2) OpenCapPickMenu(capT);
        else if (winner == 3) OpenCapPickMenu(capCT);
    }
}

// **************************************************************************************************************
// ************************************************** CAP MENU **************************************************
// **************************************************************************************************************
public void OpenCapMenu(int client)
{
    Menu menu = new Menu(CapMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Cap", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Put all players to spectator", client);
    menu.AddItem("spec", langString);

    Format(langString, sizeof(langString), "%T", "Add random player", client);
    menu.AddItem("random", langString);

    Format(langString, sizeof(langString), "%T", "Start cap fight", client);
    menu.AddItem("start", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int CapMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        if (!matchStarted)
        {
            char menuItem[32];
            menu.GetItem(choice, menuItem, sizeof(menuItem));

            if (StrEqual(menuItem, "spec"))         CapPutAllToSpec(client);
            else if (StrEqual(menuItem, "random"))  CapAddRandomPlayer(client);
            else if (StrEqual(menuItem, "start"))   CapStartFight(client);
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "You can not use this option during a match");

        OpenCapMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuAdmin(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ***************************************************************************************************************
// ************************************************** PICK MENU **************************************************
// ***************************************************************************************************************
public void OpenCapPickMenu(int client)
{
    if (client)
    {
        if (client == capT || client == capCT)
        {
            if (client == capPicker)
            {
                int count;
                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player) && GetClientTeam(player) < 2 && !IsClientSourceTV(player)) count++;
                }

                if (count > 0)
                {
                    capPicker = client;
                    CapCreatePickMenu(client);
                }
                else PrintToChat(client, "[Soccer Mod]\x04 %t", "No players available to pick");
            }
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "It is not your turn to pick");
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "You are not a cap");
    }
}

public int CapPickMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        int target = StringToInt(menuItem);
        if (IsClientInGame(target) && IsClientConnected(target))
        {
            char steamid[32];
            GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

            char targetSteamid[32];
            GetClientAuthId(target, AuthId_Engine, targetSteamid, sizeof(targetSteamid));
            capPicksLeft--;

            if (client == capCT)
            {
                int team = GetClientTeam(capCT);
                ChangeClientTeam(target, team);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has picked $target", client, target);
                }

                LogMessage("%N <%s> has picked %N <%s>", client, steamid, target, targetSteamid);

                capPicker = capT;
                if (capPicksLeft > 0) OpenCapPickMenu(capT);
            }
            else if (client == capT)
            {
                int team = GetClientTeam(capT);
                ChangeClientTeam(target, team);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has picked $target", client, target);
                }

                LogMessage("%N <%s> has picked %N <%s>", client, steamid, target, targetSteamid);

                capPicker = capCT;
                if (capPicksLeft > 0) OpenCapPickMenu(capCT);
            }
        }
        else
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Player is no longer on the server");

            if (client == capCT) OpenCapPickMenu(capCT);
            else if (client == capT) OpenCapPickMenu(capT);
        }
    }
    else if (action == MenuAction_End) menu.Close();
}

// *******************************************************************************************************************
// ************************************************** POSITION MENU **************************************************
// *******************************************************************************************************************
public void OpenCapPositionMenu(int client)
{
    KeyValues keygroup = new KeyValues("capPositions");
    keygroup.ImportFromFile(pathCapPositionsFile);

    char steamid[32];
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    keygroup.JumpToKey(steamid, true);

    Menu menu = new Menu(CapPositionMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Cap", client);
    Format(langString2, sizeof(langString2), "%T", "Positions", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    int keyValue = keygroup.GetNum("gk", 0);
    Format(langString1, sizeof(langString1), "%T", "Goalkeeper", client);
    if (keyValue) Format(langString2, sizeof(langString2), "%T", "Yes", client);
    else Format(langString2, sizeof(langString2), "%T", "No", client);
    Format(langString, sizeof(langString), "%s: %s", langString1, langString2);
    menu.AddItem("gk", langString);

    keyValue = keygroup.GetNum("lb", 0);
    Format(langString1, sizeof(langString1), "%T", "Left back", client);
    if (keyValue) Format(langString2, sizeof(langString2), "%T", "Yes", client);
    else Format(langString2, sizeof(langString2), "%T", "No", client);
    Format(langString, sizeof(langString), "%s: %s", langString1, langString2);
    menu.AddItem("lb", langString);

    keyValue = keygroup.GetNum("rb", 0);
    Format(langString1, sizeof(langString1), "%T", "Right back", client);
    if (keyValue) Format(langString2, sizeof(langString2), "%T", "Yes", client);
    else Format(langString2, sizeof(langString2), "%T", "No", client);
    Format(langString, sizeof(langString), "%s: %s", langString1, langString2);
    menu.AddItem("rb", langString);

    keyValue = keygroup.GetNum("mf", 0);
    Format(langString1, sizeof(langString1), "%T", "Midfielder", client);
    if (keyValue) Format(langString2, sizeof(langString2), "%T", "Yes", client);
    else Format(langString2, sizeof(langString2), "%T", "No", client);
    Format(langString, sizeof(langString), "%s: %s", langString1, langString2);
    menu.AddItem("mf", langString);

    keyValue = keygroup.GetNum("lw", 0);
    Format(langString1, sizeof(langString1), "%T", "Left wing", client);
    if (keyValue) Format(langString2, sizeof(langString2), "%T", "Yes", client);
    else Format(langString2, sizeof(langString2), "%T", "No", client);
    Format(langString, sizeof(langString), "%s: %s", langString1, langString2);
    menu.AddItem("lw", langString);

    keyValue = keygroup.GetNum("rw", 0);
    Format(langString1, sizeof(langString1), "%T", "Right wing", client);
    if (keyValue) Format(langString2, sizeof(langString2), "%T", "Yes", client);
    else Format(langString2, sizeof(langString2), "%T", "No", client);
    Format(langString, sizeof(langString), "%s: %s", langString1, langString2);
    menu.AddItem("rw", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);

    keygroup.Close();
}

public int CapPositionMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

        KeyValues keygroup = new KeyValues("capPositions");
        keygroup.ImportFromFile(pathCapPositionsFile);

        keygroup.JumpToKey(steamid, true);

        int keyValue = keygroup.GetNum(menuItem, 0);
        if (keyValue) keygroup.SetNum(menuItem, 0);
        else keygroup.SetNum(menuItem, 1);

        keygroup.Rewind();
        keygroup.ExportToFile(pathCapPositionsFile);
        keygroup.Close();

        OpenCapPositionMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSoccer(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ************************************************************************************************************
// ************************************************** TIMERS **************************************************
// ************************************************************************************************************
public Action TimerCapFightCountDown(Handle timer, any seconds)
{
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player)) PrintCenterText(player, "[Soccer Mod]\x04 %t", "Cap fight will start in $number seconds", seconds);
    }
}

public Action TimerCapFightCountDownEnd(Handle timer)
{
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player))
        {
            PrintCenterText(player, "[Soccer Mod]\x04 %t", "FIGHT!");
            if (IsPlayerAlive(player)) SetEntProp(player, Prop_Data, "m_takedamage", 2, 1);
        }
    }

    UnfreezeAll();
}

// ***************************************************************************************************************
// ************************************************** FUNCTIONS **************************************************
// ***************************************************************************************************************
public void CapPutAllToSpec(int client)
{
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player))
        {
            PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has put all players to spectator", client);
            if (GetClientTeam(player) != 1) ChangeClientTeam(player, 1);
        }
    }

    char steamid[32];
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    LogMessage("%N <%s> has put all players to spectator", client, steamid);
}

public void CapAddRandomPlayer(int client)
{
    int players[32], count;
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player) && GetClientTeam(player) < 2 && !IsClientSourceTV(player))
        {
            players[count] = player;
            count++;
        }
    }

    if (count)
    {
        int randomPlayer = players[GetRandomInt(0, count - 1)];
        if (GetTeamClientCount(2) < GetTeamClientCount(3)) ChangeClientTeam(randomPlayer, 2);
        else ChangeClientTeam(randomPlayer, 3);

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has forced $target as random player", client, randomPlayer);
        }

        char steamid[32], targetSteamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        GetClientAuthId(client, AuthId_Engine, targetSteamid, sizeof(targetSteamid));
        LogMessage("%N <%s> has forced %N <%s> as random player", client, steamid, randomPlayer, targetSteamid);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "No players in spectator");
}

public void CapStartFight(int client)
{
    if (!capFightStarted)
    {
        capFightStarted = true;
        capPicksLeft = (matchMaxPlayers - 1) * 2;

        CreateTimer(0.0, TimerCapFightCountDown, 3);
        CreateTimer(1.0, TimerCapFightCountDown, 2);
        CreateTimer(2.0, TimerCapFightCountDown, 1);
        CreateTimer(3.0, TimerCapFightCountDownEnd);

        KeyValues keygroup = new KeyValues("capPositions");
        keygroup.ImportFromFile(pathCapPositionsFile);

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player))
            {
                if (IsPlayerAlive(player)) SetEntityMoveType(player, MOVETYPE_NONE);
                else
                {
                    char playerSteamid[32];
                    GetClientAuthId(player, AuthId_Engine, playerSteamid, sizeof(playerSteamid));
                    keygroup.JumpToKey(playerSteamid, true);

                    int gk = keygroup.GetNum("gk", 0);
                    int lb = keygroup.GetNum("lb", 0);
                    int rb = keygroup.GetNum("rb", 0);
                    int mf = keygroup.GetNum("mf", 0);
                    int lw = keygroup.GetNum("lw", 0);
                    int rw = keygroup.GetNum("rw", 0);

                    if (!gk && !lb && !rb && !mf && !lw && !rw)
                    {
                        OpenCapPositionMenu(player);
                        PrintToChat(client, "[Soccer Mod]\x04 %t", "Please set your position to help the caps with picking");
                    }
                }
            }
        }

        keygroup.Close();

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has started a cap fight", client);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has started a cap fight", client, steamid);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "Cap fight already started");
}

public void CapCreatePickMenu(int client)
{
    Menu menu = new Menu(CapPickMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Cap", client);
    Format(langString2, sizeof(langString2), "%T", "Pick", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    KeyValues keygroup = new KeyValues("capPositions");
    keygroup.ImportFromFile(pathCapPositionsFile);

    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player) && !IsFakeClient(player) && !IsClientSourceTV(player))
        {
            int team = GetClientTeam(player);
            if (team < 2)
            {
                char playerid[4];
                IntToString(player, playerid, sizeof(playerid));

                char playerName[MAX_NAME_LENGTH];
                GetClientName(player, playerName, sizeof(playerName));

                char steamid[32];
                GetClientAuthId(player, AuthId_Engine, steamid, sizeof(steamid));
                keygroup.JumpToKey(steamid, true);

                char positions[32] = "";
                if (keygroup.GetNum("gk", 0)) Format(positions, sizeof(positions), "%s[GK]", positions);
                if (keygroup.GetNum("lb", 0)) Format(positions, sizeof(positions), "%s[LB]", positions);
                if (keygroup.GetNum("rb", 0)) Format(positions, sizeof(positions), "%s[RB]", positions);
                if (keygroup.GetNum("mf", 0)) Format(positions, sizeof(positions), "%s[MF]", positions);
                if (keygroup.GetNum("lw", 0)) Format(positions, sizeof(positions), "%s[LW]", positions);
                if (keygroup.GetNum("rw", 0)) Format(positions, sizeof(positions), "%s[RW]", positions);

                char menuString[64];
                if (positions[0]) Format(menuString, sizeof(menuString), "%s %s", playerName, positions);
                else menuString = playerName;
                menu.AddItem(playerid, menuString);
            }
        }
    }

    delete keygroup;

    menu.Display(client, MENU_TIME_FOREVER);
}