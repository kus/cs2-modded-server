int matchMaxPlayers         = 6;
int matchPeriodBreakLength  = 60;
int matchPeriodLength       = 900;
int matchPeriods            = 2;
bool matchGoldenGoal        = true;

public void RegisterServerCommandsMatch()
{
    RegServerCmd
    (
        "soccer_mod_match_periods",
        ServerCommandsMatch,
        "Sets the number of periods of a match - values: 1-10, default: 2"
    );
    RegServerCmd
    (
        "soccer_mod_match_period_length",
        ServerCommandsMatch,
        "Sets the length of a period (in seconds) - values: 5-86400, default: 900"
    );
    RegServerCmd
    (
        "soccer_mod_match_period_break_length",
        ServerCommandsMatch,
        "Sets the length of a period break (in seconds) - values: 5-3600, default: 60"
    );
    RegServerCmd
    (
        "soccer_mod_match_max_players",
        ServerCommandsMatch,
        "Sets the maximum number of players per team during a match - values: 1-32, default: 6"
    );
    RegServerCmd
    (
        "soccer_mod_match_golden_goal",
        ServerCommandsMatch,
        "Enables or disables match golden goal - values: 0/1, default: 1"
    );
}

public Action ServerCommandsMatch(int args)
{
    char serverCommand[50], cmdArg1[8];
    GetCmdArg(0, serverCommand, sizeof(serverCommand));
    GetCmdArg(1, cmdArg1, sizeof(cmdArg1));
    int number = StringToInt(cmdArg1);

    if (StrEqual(serverCommand, "soccer_mod_match_periods"))
    {
        if (1 <= number <= 10) matchPeriods = number;
        else if (number > 10) matchPeriods = 10;
        else matchPeriods = 1;

        PrintToServer("%s Match periods set to %i", PREFIX, matchPeriods);
        PrintToChatAll("%s Match periods set to %i", PREFIX, matchPeriods);
    }
    else if (StrEqual(serverCommand, "soccer_mod_match_period_length"))
    {
        if (5 <= number <= 86400) matchPeriodLength = number;
        else if (number > 86400) matchPeriodLength = 86400;
        else matchPeriodLength = 5;

        PrintToServer("%s Match period length set to %i", PREFIX, matchPeriodLength);
        PrintToChatAll("%s Match period length set to %i", PREFIX, matchPeriodLength);
    }
    else if (StrEqual(serverCommand, "soccer_mod_match_period_break_length"))
    {
        if (5 <= number <= 3600) matchPeriodBreakLength = number;
        else if (number > 3600) matchPeriodBreakLength = 3600;
        else matchPeriodBreakLength = 5;

        PrintToServer("%s Match period break length set to %i", PREFIX, matchPeriodBreakLength);
        PrintToChatAll("%s Match period break length set to %i", PREFIX, matchPeriodBreakLength);
    }
    else if (StrEqual(serverCommand, "soccer_mod_match_max_players"))
    {
        if (1 <= number <= 32) matchMaxPlayers = number;
        else if (number > 32) matchMaxPlayers = 32;
        else matchMaxPlayers = 1;

        PrintToServer("%s Maximum number of players per team during a match set to %i", PREFIX, matchMaxPlayers);
        PrintToChatAll("%s Maximum number of players per team during a match set to %i", PREFIX, matchMaxPlayers);
    }
    else if (StrEqual(serverCommand, "soccer_mod_match_golden_goal"))
    {
        if (StringToInt(cmdArg1))
        {
            matchGoldenGoal = true;
            PrintToServer("%s Match golden goal enabled", PREFIX);
            PrintToChatAll("%s Match golden goal enabled", PREFIX);
        }
        else
        {
            matchGoldenGoal = false;
            PrintToServer("%s Match golden goal disabled", PREFIX);
            PrintToChatAll("%s Match golden goal disabled", PREFIX);
        }
    }

    return Plugin_Handled;
}