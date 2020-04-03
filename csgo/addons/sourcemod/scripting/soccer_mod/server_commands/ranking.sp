int rankingPointsForGoal            = 25;
int rankingPointsForAssist          = 15;
int rankingPointsForOwnGoal         = -50;
int rankingPointsForHit             = 1;
int rankingPointsForPass            = 5;
int rankingPointsForInterception    = 3;
int rankingPointsForBallLoss        = -3;
int rankingPointsForSave            = 10;
int rankingPointsForRoundWon        = 10;
int rankingPointsForRoundLost       = -10;
int rankingPointsForMVP             = 15;
int rankingPointsForMOTM            = 50;

public void RegisterServerCommandsRanking()
{
    RegServerCmd
    (
        "soccer_mod_ranking_points_goal",
        ServerCommandsRanking,
        "Sets the number of points received for scoring a goal - values: -100-100, default: 25"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_assist",
        ServerCommandsRanking,
        "Sets the number of points received for giving an assist - values: -100-100, default: 15"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_own_goal",
        ServerCommandsRanking,
        "Sets the number of points received for scoring an own goal - values: -100-100, default: -50"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_hit",
        ServerCommandsRanking,
        "Sets the number of points received for hitting the ball - values: -100-100, default: 1"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_pass",
        ServerCommandsRanking,
        "Sets the number of points received for passing to a team mate - values: -100-100, default: 5"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_interception",
        ServerCommandsRanking,
        "Sets the number of points received for intercepting the ball - values: -100-100, default: 3"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_ball_loss",
        ServerCommandsRanking,
        "Sets the number of points received for losing the ball - values: -100-100, default: -3"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_save",
        ServerCommandsRanking,
        "Sets the number of points received for saving the ball - values: -100-100, default: 10"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_round_won",
        ServerCommandsRanking,
        "Sets the number of points received for winning a round - values: -100-100, default: 10"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_round_lost",
        ServerCommandsRanking,
        "Sets the number of points received for losing a round - values: -100-100, default: -10"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_mvp",
        ServerCommandsRanking,
        "Sets the number of points received for being the most valuable player during a round - values: -100-100, default: 15"
    );
    RegServerCmd
    (
        "soccer_mod_ranking_points_motm",
        ServerCommandsRanking,
        "Sets the number of points received for being the man of the match - values: -100-100, default: 50"
    );
}

public Action ServerCommandsRanking(int args)
{
    char serverCommand[50], cmdArg1[32];
    GetCmdArg(0, serverCommand, sizeof(serverCommand));
    GetCmdArg(1, cmdArg1, sizeof(cmdArg1));

    int value = StringToInt(cmdArg1);
    if (value > 100) value = 100;
    else value = -100;

    if (StrEqual(serverCommand, "soccer_mod_ranking_points_goal"))
    {
        rankingPointsForGoal = value;

        PrintToServer("%s Number of points received for scoring a goal set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for scoring a goal set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_assist"))
    {
        rankingPointsForAssist = value;

        PrintToServer("%s Number of points received for giving an assist set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for giving an assist set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_own_goal"))
    {
        rankingPointsForOwnGoal = value;

        PrintToServer("%s Number of points received for scoring an own goal set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for scoring an own goal set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_hit"))
    {
        rankingPointsForHit = value;

        PrintToServer("%s Number of points received for hitting the ball set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for hitting the ball set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_pass"))
    {
        rankingPointsForPass = value;

        PrintToServer("%s Number of points received for passing to a team mate set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for passing to a team mate set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_interception"))
    {
        rankingPointsForInterception = value;

        PrintToServer("%s Number of points received for intercepting the ball set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for intercepting the ball set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_ball_loss"))
    {
        rankingPointsForBallLoss = value;

        PrintToServer("%s Number of points received for losing the ball set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for losing the ball set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_save"))
    {
        rankingPointsForSave = value;

        PrintToServer("%s Number of points received for saving the ball set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for saving the ball set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_round_won"))
    {
        rankingPointsForRoundWon = value;

        PrintToServer("%s Number of points received for winning the round set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for winning the round set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_round_lost"))
    {
        rankingPointsForRoundLost = value;

        PrintToServer("%s Number of points received for losing the round set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for losing the round set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_mvp"))
    {
        rankingPointsForMVP = value;

        PrintToServer("%s Number of points received for being the mvp set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for being the mvp set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_ranking_points_motm"))
    {
        rankingPointsForMOTM = value;

        PrintToServer("%s Number of points received for being the motm set to %i", PREFIX, value);
        PrintToChatAll("%s Number of points received for being the motm set to %i", PREFIX, value);
    }

    return Plugin_Handled;
}