int matchLastScored             = 0;
int matchPeriod                 = 1;
int matchScoreCT                = 0;
int matchScoreT                 = 0;
int matchStoppageTime           = 0;
int matchTime                   = 0;
int matchToss                   = 2;
bool matchGoldenGoalActive      = false;
bool matchKickOffTaken          = false;
bool matchPaused                = false;
bool matchPeriodBreak           = false;
bool matchStoppageTimeStarted   = false;
bool matchUnpausing             = false;
Handle matchTimer               = null;

float matchBallStartPosition[3];

// ********************************************************************************************************************
// ************************************************** ENTITY OUTPUTS **************************************************
// ********************************************************************************************************************
public void MatchOnAwakened(int caller, int activator)
{
    if (matchStarted && !matchKickOffTaken)
    {
        matchKickOffTaken = true;
        KillMatchTimer();

        if (matchGoldenGoalActive) matchTimer = CreateTimer(0.0, MatchGoldenGoalTimer, matchTime);
        else if (matchStoppageTimeStarted) matchTimer = CreateTimer(0.0, MatchPeriodStoppageTimer, matchStoppageTime);
        else matchTimer = CreateTimer(0.0, MatchPeriodTimer, matchTime);
    }
}

public void MatchOnStartTouch(int caller, int activator)
{
    EndStoppageTime();
}

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void MatchOnMapStart()
{
    MatchReset();
}

public void MatchEventPlayerSpawn(Event event)
{
    if (matchStarted)
    {
        int userid = event.GetInt("userid");
        int client = GetClientOfUserId(userid);
        int team = GetClientTeam(client);

        if (team > 1)
        {
            if (GetTeamClientCount(team) > matchMaxPlayers)
            {
                ChangeClientTeam(client, 1);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", 
                        "$player has been put to spectator because the maximum number of players per team during a match is $number", client, matchMaxPlayers);
                }

                char steamid[32];
                GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
                LogMessage("%N <%s> has been put to spectator because the maximum number of players per team during a match is %i", client, steamid, matchMaxPlayers);
            }
            else if (matchPaused || matchPeriodBreak) CreateTimer(0.01, DelayFreezePlayer, client);
        }
    }
}

public void MatchEventRoundStart(Event event)
{
    UnfreezeAll();

    if (matchStarted)
    {
        matchKickOffTaken = false;

        if (matchPaused || matchPeriodBreak) FreezeAll();

        if (matchGoldenGoalActive || !matchPeriodBreak)
        {
            KillMatchTimer();
            matchTimer = CreateTimer(0.0, MatchDisplayTimerMessage);
        }

        LoadConfigMatch();
    }
    else LoadConfigPublic();

    CS_SetTeamScore(2, matchScoreT);
    CS_SetTeamScore(3, matchScoreCT);
    SetTeamScore(2, matchScoreT);
    SetTeamScore(3, matchScoreCT);

    int index = GetEntityIndexByName("ball", "prop_physics");
    if (index == -1) {
        index = GetEntityIndexByName("ball", "func_physbox");
    }
    if (index == -1) {
        index = GetEntityIndexByName("ballon", "func_physbox");
    }
    if (index != -1) GetEntPropVector(index, Prop_Send, "m_vecOrigin", matchBallStartPosition);
}

public void MatchEventRoundEnd(Event event)
{
    if (matchGoldenGoalActive) CreateTimer(0.1, DelayMatchEnd);
    else if (matchStarted && !matchPeriodBreak && !matchPaused)
    {
        KillMatchTimer();
        matchTimer = CreateTimer(0.0, MatchDisplayTimerMessage);
    }

    if (!matchPaused && !matchPeriodBreak)
    {
        int winner = event.GetInt("winner");
        if (winner > 1)
        {
            if (winner == 2)
            {
                matchScoreT++;
                matchLastScored = 2;
            }
            else
            {
                matchScoreCT++;
                matchLastScored = 3;
            }
        }
    }

    CS_SetTeamScore(2, matchScoreT);
    CS_SetTeamScore(3, matchScoreCT);
    SetTeamScore(2, matchScoreT);
    SetTeamScore(3, matchScoreCT);
}

public void MatchEventCSWinPanelMatch(Event event)
{
    MatchReset();
}

// ****************************************************************************************************************
// ************************************************** MATCH MENU **************************************************
// ****************************************************************************************************************
public void OpenMatchMenu(int client)
{
    Menu menu = new Menu(MatchMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Match", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Start", client);
    menu.AddItem("start", langString);

    Format(langString, sizeof(langString), "%T", "Pause", client);
    menu.AddItem("pause", langString);

    Format(langString, sizeof(langString), "%T", "Unpause", client);
    menu.AddItem("unpause", langString);

    Format(langString, sizeof(langString), "%T", "Score", client);
    menu.AddItem("score", langString);

    Format(langString, sizeof(langString), "%T", "Stop", client);
    menu.AddItem("stop", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MatchMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "start"))
        {
            MatchStart(client);
            OpenMatchMenu(client);
        }
        else if (StrEqual(menuItem, "pause"))
        {
            MatchPause(client);
            OpenMatchMenu(client);
        }
        else if (StrEqual(menuItem, "unpause"))
        {
            MatchUnpause(client);
            OpenMatchMenu(client);
        }
        else if (StrEqual(menuItem, "stop"))
        {
            MatchStop(client);
            OpenMatchMenu(client);
        }
        else if (StrEqual(menuItem, "score"))               OpenMatchScoreMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuAdmin(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ***********************************************************************************************************************
// ************************************************** MATCH SCORE MENU  **************************************************
// ***********************************************************************************************************************
public void OpenMatchScoreMenu(int client)
{
    Menu menu = new Menu(MatchScoreMenuHandler);

    char langString[64], langString1[64], langString2[64], langString3[64];
    Format(langString1, sizeof(langString1), "%T", "Admin", client);
    Format(langString2, sizeof(langString2), "%T", "Match", client);
    Format(langString3, sizeof(langString3), "%T", "Score", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s - %s", langString1, langString2, langString3);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Add a goal to $team", client, "counter-terrorists");
    menu.AddItem("add_ct", langString);

    Format(langString, sizeof(langString), "%T", "Remove a goal from $team", client, "counter-terrorists");
    menu.AddItem("remove_ct", langString);

    Format(langString, sizeof(langString), "%T", "Add a goal to $team", client, "terrorists");
    menu.AddItem("add_t", langString);

    Format(langString, sizeof(langString), "%T", "Remove a goal from $team", client, "terrorists");
    menu.AddItem("remove_t", langString);

    Format(langString, sizeof(langString), "%T", "Reset", client);
    menu.AddItem("reset", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MatchScoreMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        if (StrEqual(menuItem, "add_ct"))
        {
            matchScoreCT++;
            CS_SetTeamScore(3, matchScoreCT);
            SetTeamScore(3, matchScoreCT);

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has added a goal to $team", client, "counter-terrorists");
            }

            char steamid[32];
            GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
            LogMessage("%N <%s> has added a goal to the counter-terrorists", client, steamid);

            OpenMatchScoreMenu(client);
        }
        else if (StrEqual(menuItem, "remove_ct"))
        {
            if (matchScoreCT > 0)
            {
                matchScoreCT--;
                CS_SetTeamScore(3, matchScoreCT);
                SetTeamScore(3, matchScoreCT);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has removed a goal from $team", client, "counter-terrorists");
                }

                char steamid[32];
                GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
                LogMessage("%N <%s> has removed a goal from the counter-terrorists", client, steamid);
            }
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "Score is already 0");

            OpenMatchScoreMenu(client);
        }
        else if (StrEqual(menuItem, "add_t"))
        {
            matchScoreT++;
            CS_SetTeamScore(2, matchScoreT);
            SetTeamScore(2, matchScoreT);

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has added a goal to $team", client, "terrorists");
            }

            char steamid[32];
            GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
            LogMessage("%N <%s> has added a goal to the terrorists", client, steamid);

            OpenMatchScoreMenu(client);
        }
        else if (StrEqual(menuItem, "remove_t"))
        {
            if (matchScoreT > 0)
            {
                matchScoreT--;
                CS_SetTeamScore(2, matchScoreT);
                SetTeamScore(2, matchScoreT);

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has removed a goal from $team", client, "terrorists");
                }

                char steamid[32];
                GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
                LogMessage("%N <%s> has removed a goal from the terrorists", client, steamid);
            }
            else PrintToChat(client, "[Soccer Mod]\x04 %t", "Score is already 0");

            OpenMatchScoreMenu(client);
        }
        else if (StrEqual(menuItem, "reset"))
        {
            matchScoreCT = 0;
            matchScoreT = 0;
            CS_SetTeamScore(2, matchScoreT);
            SetTeamScore(2, matchScoreT);
            CS_SetTeamScore(3, matchScoreCT);
            SetTeamScore(3, matchScoreCT);

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has reset the score", client);
            }

            char steamid[32];
            GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
            LogMessage("%N <%s> has reset the score", client, steamid);

            OpenMatchScoreMenu(client);
        }
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMatchMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ************************************************************************************************************
// ************************************************** TIMERS **************************************************
// ************************************************************************************************************
public Action MatchDisplayTimerMessage(Handle timer)
{
    //int matchLength = matchPeriods * matchPeriodLength;
    //GameRules_SetPropFloat("m_fRoundStartTime", GetGameTime() - float(GameRules_GetProp("m_iRoundTime")) + matchLength - matchTime);

    char langString[64];
    char timeString[16];
    getTimeString(timeString, matchTime);

    if (matchPaused)
    {
        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player))
            {
                Format(langString, sizeof(langString), "%T", "Paused", player);
                PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
            }
        }
    }
    else if (roundEnded)
    {
        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player))
            {
                Format(langString, sizeof(langString), "%T", "Goal scored", player);
                PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
            }
        }
    }
    else
    {
        if (matchKickOffTaken) PrintHintTextToAll("CT %i - %i T | %s", matchScoreCT, matchScoreT, timeString);
        else
        {
            if (matchLastScored > 1)
            {
                if (matchLastScored == 2)
                {
                    for (int player = 1; player <= MaxClients; player++)
                    {
                        if (IsClientInGame(player) && IsClientConnected(player))
                        {
                            Format(langString, sizeof(langString), "%T", "Kick off $team", player, "CT");
                            PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
                        }
                    }
                }
                else
                {
                    for (int player = 1; player <= MaxClients; player++)
                    {
                        if (IsClientInGame(player) && IsClientConnected(player))
                        {
                            Format(langString, sizeof(langString), "%T", "Kick off $team", player, "T");
                            PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
                        }
                    }
                }
            }
            else
            {
                if (matchToss == 2)
                {
                    for (int player = 1; player <= MaxClients; player++)
                    {
                        if (IsClientInGame(player) && IsClientConnected(player))
                        {
                            Format(langString, sizeof(langString), "%T", "Kick off $team", player, "CT");
                            PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
                        }
                    }
                }
                else
                {
                    for (int player = 1; player <= MaxClients; player++)
                    {
                        if (IsClientInGame(player) && IsClientConnected(player))
                        {
                            Format(langString, sizeof(langString), "%T", "Kick off $team", player, "T");
                            PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
                        }
                    }
                }
            }
        }
    }

    matchTimer = CreateTimer(1.0, MatchDisplayTimerMessage);
}

public Action MatchPeriodTimer(Handle timer, any time)
{
    //int matchLength = matchPeriods * matchPeriodLength;
    //GameRules_SetPropFloat("m_fRoundStartTime", GetGameTime() - float(GameRules_GetProp("m_iRoundTime")) + matchLength - matchTime);

    matchTime = time;

    char timeString[16];
    getTimeString(timeString, matchTime);
    PrintHintTextToAll("CT %i - %i T | %s", matchScoreCT, matchScoreT, timeString);

    int periodEnd = matchPeriod * matchPeriodLength;
    if (time < periodEnd) matchTimer = CreateTimer(1.0, MatchPeriodTimer, time + 1);
    else
    {
        matchStoppageTimeStarted = true;

        int index = CreateEntityByName("trigger_once");
        if (index != -1)
        {
            DispatchKeyValue(index, "targetname", "end_stoppage_time");
            DispatchKeyValue(index, "spawnflags", "8");

            DispatchSpawn(index);
            ActivateEntity(index);

            TeleportEntity(index, matchBallStartPosition, NULL_VECTOR, NULL_VECTOR);

            if (!IsModelPrecached("models/props/cs_office/vending_machine.mdl")) PrecacheModel("models/props/cs_office/vending_machine.mdl");
            SetEntityModel(index, "models/props/cs_office/vending_machine.mdl");

            float minbounds[3] = {-2000.0, -1.0, -10.0};
            float maxbounds[3] = {2000.0, 1.0, 5000.0};
            SetEntPropVector(index, Prop_Send, "m_vecMins", minbounds);
            SetEntPropVector(index, Prop_Send, "m_vecMaxs", maxbounds);

            SetEntProp(index, Prop_Send, "m_nSolidType", 2);

            int enteffects = GetEntProp(index, Prop_Send, "m_fEffects");
            enteffects |= 32;
            SetEntProp(index, Prop_Send, "m_fEffects", enteffects);
        }

        matchTimer = CreateTimer(0.0, MatchPeriodStoppageTimer, matchStoppageTime);
    }
}

public Action MatchPeriodStoppageTimer(Handle timer, any time)
{
    matchStoppageTime = time;

    char timeString[16];
    getTimeString(timeString, matchTime);
    char stoppageTimeString[16];
    getTimeString(stoppageTimeString, matchStoppageTime);
    PrintHintTextToAll("CT %i - %i T | %s +%s", matchScoreCT, matchScoreT, timeString, stoppageTimeString);

    matchTimer = CreateTimer(1.0, MatchPeriodStoppageTimer, matchStoppageTime + 1);
}

public Action MatchPeriodBreakTimer(Handle timer, any time)
{
    //int matchLength = matchPeriods * matchPeriodLength;
    //GameRules_SetPropFloat("m_fRoundStartTime", GetGameTime() - float(GameRules_GetProp("m_iRoundTime")) + matchLength - matchTime);

    char matchTimerMessage[32] = "";

    if (matchPeriods > 2) matchTimerMessage = "Period break: ";
    else matchTimerMessage = "Half time: ";

    char timeString[16];
    getTimeString(timeString, time);
    PrintHintTextToAll("%sCT %i - %i T | %s", matchTimerMessage, matchScoreCT, matchScoreT, timeString);

    if (time < 1)
    {
        matchPeriodBreak = false;
        matchLastScored = 0;

        ServerCommand("mp_restartgame 1");
        KillMatchTimer();

        if (matchToss == 2) matchToss = 3;
        else matchToss = 2;
    }
    else matchTimer = CreateTimer(1.0, MatchPeriodBreakTimer, time - 1);
}

public Action MatchGoldenGoalTimer(Handle timer, any time)
{
    matchTime = time;

    char langString[64];
    char timeString[16];
    getTimeString(timeString, time);

    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player))
        {
            Format(langString, sizeof(langString), "%T", "Golden goal", player);
            PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
        }
    }

    matchTimer = CreateTimer(1.0, MatchGoldenGoalTimer, time + 1);
}

public Action MatchUnpauseCountdown(Handle timer, any time)
{
    matchUnpausing = true;
    if (time > 1) PrintHintTextToAll("Unpausing in %i seconds", time);
    else PrintHintTextToAll("Unpausing in %i second", time);

    if (time < 1)
    {
        matchUnpausing = false;
        UnfreezeAll();

        if (matchGoldenGoalActive)
        {
            if (matchKickOffTaken) matchTimer = CreateTimer(0.0, MatchGoldenGoalTimer, matchTime);
            else matchTimer = CreateTimer(0.0, MatchDisplayTimerMessage);
        }
        else if (matchStoppageTimeStarted)
        {
            if (matchKickOffTaken) matchTimer = CreateTimer(0.0, MatchPeriodStoppageTimer, matchStoppageTime);
            else matchTimer = CreateTimer(0.0, MatchDisplayTimerMessage);
        }
        else
        {
            if (matchKickOffTaken) matchTimer = CreateTimer(0.0, MatchPeriodTimer, matchTime);
            else matchTimer = CreateTimer(0.0, MatchDisplayTimerMessage);
        }
    }
    else matchTimer = CreateTimer(1.0, MatchUnpauseCountdown, time - 1);
}

public Action DelayFreezePlayer(Handle timer, any client)
{
    SetEntityMoveType(client, MOVETYPE_NONE);
}

public Action DelayMatchEnd(Handle timer)
{
    char langString[64];
    char timeString[16];
    getTimeString(timeString, matchTime);

    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player))
        {
            Format(langString, sizeof(langString), "%T", "Goal scored", player);
            PrintHintText(player, "%s: CT %i - %i T | %s", langString, matchScoreCT, matchScoreT, timeString);
            Format(langString, sizeof(langString), "%T", "Final score", player);
            PrintToChat(player, "[Soccer Mod]\x04 %s: CT %i - %i T", langString, matchScoreCT, matchScoreT);
        }
    }

    LogMessage("Final score: CT %i - %i T", matchScoreCT, matchScoreT);

    ShowManOfTheMatch();
    MatchReset();
    ServerCommand("mp_restartgame 5");
}

// ***************************************************************************************************************
// ************************************************** FUNCTIONS **************************************************
// ***************************************************************************************************************
public void MatchReset()
{
    matchGoldenGoalActive       = false;
    matchStarted                = false;
    matchKickOffTaken           = false;
    matchPaused                 = false;
    matchPeriodBreak            = false;
    matchUnpausing              = false;
    matchStoppageTimeStarted    = false;

    matchTime = 0;
    matchStoppageTime = 0;
    matchPeriod = 1;
    KillMatchTimer();

    matchToss = 2;
    matchLastScored = 0;

    matchScoreT = 0;
    matchScoreCT = 0;
}

public void MatchStart(int client)
{
    if (!matchStarted)
    {
        ServerCommand("mp_restartgame 5");

        FreezeAll();
        MatchReset();
        LoadConfigMatch();
        ResetMatchStats();

        matchStarted = true;
        matchKickOffTaken = true;
        matchToss = GetRandomInt(2, 3);

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has started a match", client);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has started a match", client, steamid);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "Match already started");
}

public void MatchPause(int client)
{
    if (matchStarted)
    {
        if (!matchPaused)
        {
            matchPaused = true;

            if (!matchPeriodBreak)
            {
                FreezeAll();
                KillMatchTimer();
                matchTimer = CreateTimer(0.0, MatchDisplayTimerMessage);
            }

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has paused the match", client);
            }

            char steamid[32];
            GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
            LogMessage("%N <%s> has paused the match", client, steamid);
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Match already paused");
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "No match started");
}

public void MatchUnpause(int client)
{
    if (matchStarted)
    {
        if (matchPaused)
        {
            matchPaused = false;

            if (!matchPeriodBreak)
            {
                KillMatchTimer();
                matchTimer = CreateTimer(0.0, MatchUnpauseCountdown, 5);
            }

            for (int player = 1; player <= MaxClients; player++)
            {
                if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has unpaused the match", client);
            }

            char steamid[32];
            GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
            LogMessage("%N <%s> has unpaused the match", client, steamid);
        }
        else PrintToChat(client, "[Soccer Mod]\x04 %t", "Match already unpaused");
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "No match started");
}

public void MatchStop(int client)
{
    if (matchStarted)
    {
        MatchReset();
        UnfreezeAll();

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player has stopped the match", client);
        }

        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
        LogMessage("%N <%s> has stopped the match", client, steamid);
    }
    else PrintToChat(client, "[Soccer Mod]\x04 %t", "No match started");
}

stock bool getTimeString(char[] name, int time)
{
    int hours = RoundToFloor(time / 3600.0);
    int minutes = RoundToFloor((time - (hours * 3600.0)) / 60.0);
    int seconds = time - (hours * 3600) - (minutes * 60);

    char hoursString[4];
    char minutesString[4];
    char secondsString[4];

    if (time >= 3600)
    {
        if (hours < 10) Format(hoursString, sizeof(hoursString), "0%i", hours);
        else Format(hoursString, sizeof(hoursString), "%i", hours);
    }
    if (minutes < 10) Format(minutesString, sizeof(minutesString), "0%i", minutes)
    else Format(minutesString, sizeof(minutesString), "%i", minutes);
    if (seconds < 10) Format(secondsString, sizeof(secondsString), "0%i", seconds);
    else Format(secondsString, sizeof(secondsString), "%i", seconds);

    char timeString[16];
    if (time >= 3600) Format(timeString, sizeof(timeString), "%s:%s:%s", hoursString, minutesString, secondsString);
    else Format(timeString, sizeof(timeString), "%s:%s", minutesString, secondsString);

    strcopy(name, 16, timeString);
    return true;
}

public void EndStoppageTime()
{
    if (matchStoppageTimeStarted)
    {
        KillMatchTimer();

        matchStoppageTimeStarted = false;
        matchStoppageTime = 0;
        matchPeriod++;

        if (matchPeriod <= matchPeriods)
        {
            matchPeriodBreak = true;
            FreezeAll();
            matchTimer = CreateTimer(0.0, MatchPeriodBreakTimer, matchPeriodBreakLength);
        }
        else
        {
            if (matchGoldenGoal && matchScoreCT == matchScoreT)
            {
                matchGoldenGoalActive = true;
                matchToss = GetRandomInt(2, 3);

                FreezeAll();

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "The match ended in a draw and will continue with a golden goal");
                }

                ServerCommand("mp_restartgame 5");
            }
            else
            {
                char langString[64];

                for (int player = 1; player <= MaxClients; player++)
                {
                    if (IsClientInGame(player) && IsClientConnected(player))
                    {
                        Format(langString, sizeof(langString), "%T", "Final score", player);
                        PrintToChat(player, "[Soccer Mod]\x04 %s: CT %i - %i T", langString, matchScoreCT, matchScoreT);
                    }
                }

                LogMessage("Final score: CT %i - %i T", matchScoreCT, matchScoreT);

                ShowManOfTheMatch();
                MatchReset();
                ServerCommand("mp_restartgame 5");
            }
        }
    }
}

public void KillMatchTimer()
{
    if (matchTimer != null)
    {
        KillTimer(matchTimer);
        matchTimer = null;
    }
}