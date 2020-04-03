int statsAssisterClientid       = 0;
int statsAssisterTeam           = 0;
int statsSaver                  = 0;
int statsScorerClientid         = 0;
int statsScorerTeam             = 0;

int statsGoalsCT                = 0;
int statsGoalsT                 = 0;
int statsAssistsCT              = 0;
int statsAssistsT               = 0;
int statsOwnGoalsCT             = 0;
int statsOwnGoalsT              = 0;
int statsHitsCT                 = 0;
int statsHitsT                  = 0;
int statsPassesCT               = 0;
int statsPassesT                = 0;
int statsInterceptionsCT        = 0;
int statsInterceptionsT         = 0;
int statsBallLossesCT           = 0;
int statsBallLossesT            = 0;
int statsSavesCT                = 0;
int statsSavesT                 = 0;
int statsRoundsWonCT            = 0;
int statsRoundsWonT             = 0;
int statsRoundsLostCT           = 0;
int statsRoundsLostT            = 0;

float statsAssisterTimestamp    = 0.0;
float statsScorerTimestamp      = 0.0;
float statsCTGKAreaMinX         = 0.0;
float statsCTGKAreaMinY         = 0.0;
float statsCTGKAreaMinZ         = 0.0;
float statsCTGKAreaMaxX         = 0.0;
float statsCTGKAreaMaxY         = 0.0;
float statsCTGKAreaMaxZ         = 0.0;
float statsTGKAreaMinX          = 0.0;
float statsTGKAreaMinY          = 0.0;
float statsTGKAreaMinZ          = 0.0;
float statsTGKAreaMaxX          = 0.0;
float statsTGKAreaMaxY          = 0.0;
float statsTGKAreaMaxZ          = 0.0;
float statsPossessionTotal      = 0.0;
float statsPossessionCT         = 0.0;
float statsPossessionT          = 0.0;

KeyValues statsKeygroupMatch;
KeyValues statsKeygroupRound;

char statsAssisterName[MAX_NAME_LENGTH]     = "";
char statsAssisterSteamid[32]               = "";
char statsScorerName[MAX_NAME_LENGTH]       = "";
char statsScorerSteamid[32]                 = "";

char statsKeygroupGoalkeeperAreas[PLATFORM_MAX_PATH];
// char statsKeygroupRound[PLATFORM_MAX_PATH];
// char statsKeygroupMatch[PLATFORM_MAX_PATH];

// ********************************************************************************************************************
// ************************************************** ENTITY OUTPUTS **************************************************
// ********************************************************************************************************************
public void StatsOnAwakened(int caller, int activator)
{
    int index;
    while ((index = GetEntityIndexByName("gk_area_beam", "env_beam")) != -1) AcceptEntityInput(index, "Kill");
}

public void StatsOnTakeDamage(int ball, int client)
{
    // Handle timer;

    bool save = false;
    bool pass = false;
    bool interception = false;
    bool ball_loss = false;
    float possession;

    char steamid[32];
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

    char name[MAX_NAME_LENGTH];
    GetClientName(client, name, sizeof(name));

    int team = GetClientTeam(client);
    if (team == 2) statsHitsT++;
    else if (team == 3) statsHitsCT++;

    // AddPlayerStatInt(name, steamid, "hits", rankingPointsForHit);

    // char table[32] = "soccer_mod_public_stats";
    // if (matchStarted) table = "soccer_mod_match_stats";

    // char queryString[1024];
    // Format(queryString, sizeof(queryString), "UPDATE %s SET hits = (hits + 1), points = (points + %i) WHERE steamid = '%s'", 
    //  table, rankingPointsForHit, steamid);
    // ExecuteQuery(queryString);

    int saverClientid;
    char saverSteamid[32];
    char saverName[MAX_NAME_LENGTH];

    float ballPosition[3];
    GetEntPropVector(ball, Prop_Send, "m_vecOrigin", ballPosition);

    if (statsSaver)
    {
        if (IsClientConnected(statsSaver))
        {
            saverClientid = statsSaver;
            GetClientAuthId(statsSaver, AuthId_Engine, saverSteamid, sizeof(saverSteamid));
            GetClientName(statsSaver, saverName, sizeof(saverName));

            if (!(statsCTGKAreaMinX <= ballPosition[0] <= statsCTGKAreaMaxX && 
                statsCTGKAreaMinY <= ballPosition[1] <= statsCTGKAreaMaxY && 
                statsCTGKAreaMinZ <= ballPosition[2] <= statsCTGKAreaMaxZ))
            {
                save = true;
                statsSavesCT++;
                // AddPlayerStatInt(saverName, saverSteamid, "saves", rankingPointsForSave);

                // Format(queryString, sizeof(queryString), "UPDATE %s SET saves = (saves + 1), points = (points + %i) WHERE steamid = '%s'", 
                //  table, rankingPointsForSave, saverSteamid);
                // ExecuteQuery(queryString);

                if (debuggingEnabled) PrintToChatAll("%s %N has made a save", PREFIX, statsSaver);
            }
            else if (!(statsTGKAreaMinX <= ballPosition[0] <= statsTGKAreaMaxX && 
                statsTGKAreaMinY <= ballPosition[1] <= statsTGKAreaMaxY && 
                statsTGKAreaMinZ <= ballPosition[2] <= statsTGKAreaMaxZ))
            {
                save = true;
                statsSavesT++;
                // AddPlayerStatInt(saverName, saverSteamid, "saves", rankingPointsForSave);

                // Format(queryString, sizeof(queryString), "UPDATE %s SET saves = (saves + 1), points = (points + %i) WHERE steamid = '%s'", 
                //  table, rankingPointsForSave, saverSteamid);
                // ExecuteQuery(queryString);

                if (debuggingEnabled) PrintToChatAll("%s %N has made a save", PREFIX, statsSaver);
            }
        }

        statsSaver = 0;
    }

    if (team == 3 && 
        statsCTGKAreaMinX <= ballPosition[0] <= statsCTGKAreaMaxX && 
        statsCTGKAreaMinY <= ballPosition[1] <= statsCTGKAreaMaxY && 
        statsCTGKAreaMinZ <= ballPosition[2] <= statsCTGKAreaMaxZ)
    {
        statsSaver = client;
        if (debuggingEnabled) PrintToChatAll("%s %N has knifed the ball in the CT gk area", PREFIX, client);
    }
    else if (team == 2 && 
        statsTGKAreaMinX <= ballPosition[0] <= statsTGKAreaMaxX && 
        statsTGKAreaMinY <= ballPosition[1] <= statsTGKAreaMaxY && 
        statsTGKAreaMinZ <= ballPosition[2] <= statsTGKAreaMaxZ)
    {
        statsSaver = client;
        if (debuggingEnabled) PrintToChatAll("%s %N has knifed the ball in the T gk area", PREFIX, client);
    }

    if (client != statsScorerClientid)
    {
        statsAssisterTimestamp = statsScorerTimestamp;
        statsScorerTimestamp = GetGameTime();

        if (statsScorerClientid)
        {
            statsAssisterClientid = statsScorerClientid;
            statsAssisterName = statsScorerName;
            statsAssisterSteamid = statsScorerSteamid;
            statsAssisterTeam = statsScorerTeam;

            // statsScorerClientid = client;
            // statsScorerSteamid = steamid;
            // statsScorerName = name;
            // statsScorerTeam = team;
            // statsScorerClientid = client;
            // GetClientName(client, statsScorerName, sizeof(statsScorerName));
            // statsScorerTeam = GetClientTeam(client);
            // GetClientAuthId(client, AuthId_Engine, statsScorerSteamid, sizeof(statsScorerSteamid));

            possession = statsScorerTimestamp - statsAssisterTimestamp;
            if (statsAssisterTeam == 2) statsPossessionT += possession;
            else if (statsAssisterTeam == 3) statsPossessionCT += possession;
            statsPossessionTotal += possession;
            // AddPlayerStatPossession(statsAssisterSteamid, possession, statsAssisterTeam);
            if (debuggingEnabled) PrintToChatAll("%s %s had the ball for %f", PREFIX, statsAssisterName, possession);

            if (team == statsAssisterTeam)
            {
                pass = true;
                if (statsAssisterTeam == 2) statsPassesT++;
                else if (statsAssisterTeam == 3) statsPassesCT++;
                // AddPlayerStatInt(statsAssisterName, statsAssisterSteamid, "passes", rankingPointsForPass);

                // Format(queryString, sizeof(queryString), "UPDATE %s SET passes = (passes + 1), points = (points + %i) WHERE steamid = '%s'", 
                //  table, rankingPointsForPass, statsAssisterSteamid);
                // ExecuteQuery(queryString);

                // if (IsClientInGame(statsAssisterClientid) && IsClientConnected(statsAssisterClientid)) SetPlayerStats(timer, statsAssisterClientid);
                if (debuggingEnabled) PrintToChatAll("%s %s has passed the ball to %s", PREFIX, statsAssisterName, name);
            }
            else
            {
                interception = true;
                if (team == 2) statsInterceptionsT++;
                else if (team == 3) statsInterceptionsCT++;
                // AddPlayerStatInt(name, steamid, "interceptions", rankingPointsForInterception);

                // Format(queryString, sizeof(queryString), "UPDATE %s SET interceptions = (interceptions + 1), points = (points + %i) WHERE steamid = '%s'", 
                //  table, rankingPointsForInterception, steamid);
                // ExecuteQuery(queryString);

                if (debuggingEnabled) PrintToChatAll("%s %s has intercepted the ball from %s", PREFIX, name, statsAssisterName);

                ball_loss = true;
                if (statsAssisterTeam == 2) statsBallLossesT++;
                else if (statsAssisterTeam == 3) statsBallLossesCT++;
                // AddPlayerStatInt(statsAssisterName, statsAssisterSteamid, "ball_losses", rankingPointsForBallLoss);

                // Format(queryString, sizeof(queryString), "UPDATE %s SET ball_losses = (ball_losses + 1), points = (points + %i) WHERE steamid = '%s'", 
                //  table, rankingPointsForBallLoss, statsAssisterSteamid);
                // ExecuteQuery(queryString);

                // if (IsClientInGame(statsAssisterClientid) && IsClientConnected(statsAssisterClientid)) SetPlayerStats(timer, statsAssisterClientid);
                if (debuggingEnabled) PrintToChatAll("%s %s has lost the ball to %s", PREFIX, statsAssisterName, name);
            }
        }
        // else
        // {
        statsScorerClientid = client;
        statsScorerSteamid = steamid;
        statsScorerName = name;
        statsScorerTeam = team;
        // statsScorerClientid = client;
        // GetClientName(client, statsScorerName, sizeof(statsScorerName));
        // statsScorerTeam = GetClientTeam(client);
        // GetClientAuthId(client, AuthId_Engine, statsScorerSteamid, sizeof(statsScorerSteamid));
        // }
    }

    // KeyValues keygroupRound = new KeyValues("roundStatistics");
    // KeyValues keygroupMatch = new KeyValues("matchStatistics");

    // keygroupRound.ImportFromFile(statsKeygroupRound);
    // keygroupMatch.ImportFromFile(statsKeygroupMatch);

    statsKeygroupRound.JumpToKey(steamid, true);
    statsKeygroupMatch.JumpToKey(steamid, true);

    statsKeygroupRound.SetString("name", name);
    statsKeygroupMatch.SetString("name", name);

    int keyValue = statsKeygroupRound.GetNum("hits", 0);
    statsKeygroupRound.SetNum("hits", keyValue + 1);

    keyValue = statsKeygroupMatch.GetNum("hits", 0);
    keyValue++;
    statsKeygroupMatch.SetNum("hits", keyValue + 1);

    if (StrEqual(game, "csgo")) SetEntProp(client, Prop_Data, "m_iDeaths", keyValue);

    int points;
    points += rankingPointsForHit;

    if (interception)
    {
        keyValue = statsKeygroupRound.GetNum("interceptions", 0);
        statsKeygroupRound.SetNum("interceptions", keyValue + 1);

        keyValue = statsKeygroupMatch.GetNum("interceptions", 0);
        statsKeygroupMatch.SetNum("interceptions", keyValue + 1);

        points += rankingPointsForInterception;
    }

    keyValue = statsKeygroupRound.GetNum("points", 0);
    keyValue += points;
    statsKeygroupRound.SetNum("points", keyValue);

    keyValue = statsKeygroupMatch.GetNum("points", 0);
    keyValue += points;
    statsKeygroupMatch.SetNum("points", keyValue);

    if (StrEqual(game, "csgo")) CS_SetClientContributionScore(client, keyValue);
    else SetEntProp(client, Prop_Data, "m_iDeaths", keyValue);

    statsKeygroupRound.Rewind();
    statsKeygroupMatch.Rewind();

    if (pass || ball_loss || possession)
    {
        points = 0;

        statsKeygroupRound.JumpToKey(statsAssisterSteamid, true);
        statsKeygroupMatch.JumpToKey(statsAssisterSteamid, true);

        statsKeygroupRound.SetString("name", statsAssisterName);
        statsKeygroupMatch.SetString("name", statsAssisterName);

        if (pass)
        {
            keyValue = statsKeygroupRound.GetNum("passes", 0);
            statsKeygroupRound.SetNum("passes", keyValue + 1);

            keyValue = statsKeygroupMatch.GetNum("passes", 0);
            statsKeygroupMatch.SetNum("passes", keyValue + 1);

            points += rankingPointsForPass;
        }

        if (ball_loss)
        {
            keyValue = statsKeygroupRound.GetNum("ball_losses", 0);
            statsKeygroupRound.SetNum("ball_losses", keyValue + 1);

            keyValue = statsKeygroupMatch.GetNum("ball_losses", 0);
            statsKeygroupMatch.SetNum("ball_losses", keyValue + 1);

            points += rankingPointsForBallLoss;
        }

        if (possession)
        {
            float keyValueFloat = statsKeygroupMatch.GetFloat("possession", 0.0);
            statsKeygroupMatch.SetFloat("possession", keyValueFloat + possession);
        }

        keyValue = statsKeygroupRound.GetNum("points", 0);
        keyValue += points;
        statsKeygroupRound.SetNum("points", keyValue);

        keyValue = statsKeygroupMatch.GetNum("points", 0);
        keyValue += points;
        statsKeygroupMatch.SetNum("points", keyValue);

        if (IsClientInGame(statsAssisterClientid) && IsClientConnected(statsAssisterClientid))
        {
            if (StrEqual(game, "csgo")) CS_SetClientContributionScore(statsAssisterClientid, keyValue);
            else SetEntProp(statsAssisterClientid, Prop_Data, "m_iDeaths", keyValue);
        }
    }

    statsKeygroupRound.Rewind();
    statsKeygroupMatch.Rewind();

    if (save)
    {
        statsKeygroupRound.JumpToKey(saverSteamid, true);
        statsKeygroupMatch.JumpToKey(saverSteamid, true);

        statsKeygroupRound.SetString("name", saverName);
        statsKeygroupMatch.SetString("name", saverName);

        keyValue = statsKeygroupRound.GetNum("saves", 0);
        statsKeygroupRound.SetNum("saves", keyValue + 1);

        keyValue = statsKeygroupMatch.GetNum("saves", 0);
        statsKeygroupMatch.SetNum("saves", keyValue + 1);

        keyValue = statsKeygroupRound.GetNum("points", 0);
        keyValue += rankingPointsForSave;
        statsKeygroupRound.SetNum("points", keyValue);

        keyValue = statsKeygroupMatch.GetNum("points", 0);
        keyValue += rankingPointsForSave;
        statsKeygroupMatch.SetNum("points", keyValue);

        if (IsClientInGame(saverClientid) && IsClientConnected(saverClientid))
        {
            if (StrEqual(game, "csgo")) CS_SetClientContributionScore(saverClientid, keyValue);
            else SetEntProp(saverClientid, Prop_Data, "m_iDeaths", keyValue);
        }
    }

    statsKeygroupRound.Rewind();
    statsKeygroupMatch.Rewind();

    // keygroupRound.ExportToFile(statsKeygroupRound);
    // keygroupMatch.ExportToFile(statsKeygroupMatch);

    // keygroupRound.Close();
    // keygroupMatch.Close();

    //SetPlayerStats(timer, client);
}

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void StatsOnPluginStart()
{
    BuildPath(Path_SM, statsKeygroupGoalkeeperAreas, sizeof(statsKeygroupGoalkeeperAreas), "data/soccer_mod_gk_areas.txt");
    // BuildPath(Path_SM, statsKeygroupMatch, sizeof(statsKeygroupMatch), "data/soccer_mod_match_stats.txt");
    // BuildPath(Path_SM, statsKeygroupRound, sizeof(statsKeygroupRound), "data/soccer_mod_round_stats.txt");

    statsKeygroupMatch = new KeyValues("matchStatistics");
    statsKeygroupRound = new KeyValues("roundStatistics");
}

public void StatsOnMapStart()
{
    ResetMatchStats();
    ResetRoundStats();
}

public void StatsEventPlayerSpawn(Event event)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);

    CreateTimer(0.01, SetPlayerStats, client);
}

public void StatsEventRoundStart(Event event)
{
    ResetRoundStats();

    KeyValues keygroup = new KeyValues("gk_areas");
    keygroup.ImportFromFile(statsKeygroupGoalkeeperAreas);

    char mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));

    char bits[3][64];
    ExplodeString(mapName, "/", bits, sizeof(bits), sizeof(bits[]));
    if (bits[2][0]) keygroup.JumpToKey(bits[2], false);
    else keygroup.JumpToKey(bits[0], false);

    statsCTGKAreaMinX = keygroup.GetFloat("ct_min_x", 0.0);
    statsCTGKAreaMinY = keygroup.GetFloat("ct_min_y", 0.0);
    statsCTGKAreaMinZ = keygroup.GetFloat("ct_min_z", 0.0);
    statsCTGKAreaMaxX = keygroup.GetFloat("ct_max_x", 0.0);
    statsCTGKAreaMaxY = keygroup.GetFloat("ct_max_y", 0.0);
    statsCTGKAreaMaxZ = keygroup.GetFloat("ct_max_z", 0.0);
    if (debuggingEnabled) PrintToChatAll("%s CT GK Area: %.1f, %.1f, %.1f, %.1f, %.1f, %.1f", PREFIX, statsCTGKAreaMinX, statsCTGKAreaMinY, statsCTGKAreaMinZ, 
        statsCTGKAreaMaxX, statsCTGKAreaMaxY, statsCTGKAreaMaxZ);

    statsTGKAreaMinX = keygroup.GetFloat("t_min_x", 0.0);
    statsTGKAreaMinY = keygroup.GetFloat("t_min_y", 0.0);
    statsTGKAreaMinZ = keygroup.GetFloat("t_min_z", 0.0);
    statsTGKAreaMaxX = keygroup.GetFloat("t_max_x", 0.0);
    statsTGKAreaMaxY = keygroup.GetFloat("t_max_y", 0.0);
    statsTGKAreaMaxZ = keygroup.GetFloat("t_max_z", 0.0);
    if (debuggingEnabled) PrintToChatAll("%s T GK Area: %.1f, %.1f, %.1f, %.1f, %.1f, %.1f", PREFIX, statsTGKAreaMinX, statsTGKAreaMinY, statsTGKAreaMinZ, 
        statsTGKAreaMaxX, statsTGKAreaMaxY, statsTGKAreaMaxZ);

    keygroup.Close();

    if (statsCTGKAreaMinX != 0 && statsCTGKAreaMinY != 0 && statsCTGKAreaMinZ != 0 && statsCTGKAreaMaxX != 0 && statsCTGKAreaMaxY != 0 && statsCTGKAreaMaxZ != 0 && 
        statsTGKAreaMinX != 0 && statsTGKAreaMinY != 0 && statsTGKAreaMinZ != 0 && statsTGKAreaMaxX != 0 && statsTGKAreaMaxY != 0 && statsTGKAreaMaxZ != 0)
    {
        DrawLaser("gk_area_beam", statsCTGKAreaMinX, statsCTGKAreaMinY, statsCTGKAreaMinZ, statsCTGKAreaMaxX, statsCTGKAreaMinY, statsCTGKAreaMinZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMaxX, statsCTGKAreaMinY, statsCTGKAreaMinZ, statsCTGKAreaMaxX, statsCTGKAreaMaxY, statsCTGKAreaMinZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMaxX, statsCTGKAreaMaxY, statsCTGKAreaMinZ, statsCTGKAreaMinX, statsCTGKAreaMaxY, statsCTGKAreaMinZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMinX, statsCTGKAreaMaxY, statsCTGKAreaMinZ, statsCTGKAreaMinX, statsCTGKAreaMinY, statsCTGKAreaMinZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMinX, statsCTGKAreaMinY, statsCTGKAreaMaxZ, statsCTGKAreaMaxX, statsCTGKAreaMinY, statsCTGKAreaMaxZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMaxX, statsCTGKAreaMinY, statsCTGKAreaMaxZ, statsCTGKAreaMaxX, statsCTGKAreaMaxY, statsCTGKAreaMaxZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMaxX, statsCTGKAreaMaxY, statsCTGKAreaMaxZ, statsCTGKAreaMinX, statsCTGKAreaMaxY, statsCTGKAreaMaxZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMinX, statsCTGKAreaMaxY, statsCTGKAreaMaxZ, statsCTGKAreaMinX, statsCTGKAreaMinY, statsCTGKAreaMaxZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMinX, statsCTGKAreaMinY, statsCTGKAreaMinZ, statsCTGKAreaMinX, statsCTGKAreaMinY, statsCTGKAreaMaxZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMaxX, statsCTGKAreaMinY, statsCTGKAreaMinZ, statsCTGKAreaMaxX, statsCTGKAreaMinY, statsCTGKAreaMaxZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMinX, statsCTGKAreaMaxY, statsCTGKAreaMinZ, statsCTGKAreaMinX, statsCTGKAreaMaxY, statsCTGKAreaMaxZ, "0 0 255");
        DrawLaser("gk_area_beam", statsCTGKAreaMaxX, statsCTGKAreaMaxY, statsCTGKAreaMinZ, statsCTGKAreaMaxX, statsCTGKAreaMaxY, statsCTGKAreaMaxZ, "0 0 255");

        DrawLaser("gk_area_beam", statsTGKAreaMinX, statsTGKAreaMinY, statsTGKAreaMinZ, statsTGKAreaMaxX, statsTGKAreaMinY, statsTGKAreaMinZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMaxX, statsTGKAreaMinY, statsTGKAreaMinZ, statsTGKAreaMaxX, statsTGKAreaMaxY, statsTGKAreaMinZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMaxX, statsTGKAreaMaxY, statsTGKAreaMinZ, statsTGKAreaMinX, statsTGKAreaMaxY, statsTGKAreaMinZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMinX, statsTGKAreaMaxY, statsTGKAreaMinZ, statsTGKAreaMinX, statsTGKAreaMinY, statsTGKAreaMinZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMinX, statsTGKAreaMinY, statsTGKAreaMaxZ, statsTGKAreaMaxX, statsTGKAreaMinY, statsTGKAreaMaxZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMaxX, statsTGKAreaMinY, statsTGKAreaMaxZ, statsTGKAreaMaxX, statsTGKAreaMaxY, statsTGKAreaMaxZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMaxX, statsTGKAreaMaxY, statsTGKAreaMaxZ, statsTGKAreaMinX, statsTGKAreaMaxY, statsTGKAreaMaxZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMinX, statsTGKAreaMaxY, statsTGKAreaMaxZ, statsTGKAreaMinX, statsTGKAreaMinY, statsTGKAreaMaxZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMinX, statsTGKAreaMinY, statsTGKAreaMinZ, statsTGKAreaMinX, statsTGKAreaMinY, statsTGKAreaMaxZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMaxX, statsTGKAreaMinY, statsTGKAreaMinZ, statsTGKAreaMaxX, statsTGKAreaMinY, statsTGKAreaMaxZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMinX, statsTGKAreaMaxY, statsTGKAreaMinZ, statsTGKAreaMinX, statsTGKAreaMaxY, statsTGKAreaMaxZ, "255 0 0");
        DrawLaser("gk_area_beam", statsTGKAreaMaxX, statsTGKAreaMaxY, statsTGKAreaMinZ, statsTGKAreaMaxX, statsTGKAreaMaxY, statsTGKAreaMaxZ, "255 0 0");
    }
}

public void StatsEventRoundEnd(Event event)
{
    int winner = event.GetInt("winner");
    // Handle keygroup;
    // char queryString[1024];

    if (winner > 1)
    {
        if (statsScorerClientid)
        {
            float possession = GetGameTime() - statsScorerTimestamp;
            AddPlayerStatPossession(statsScorerSteamid, possession, statsScorerTeam);
            if (debuggingEnabled) PrintToChatAll("%s %s had the ball for %f", PREFIX, statsScorerName, possession);

            if (statsScorerTeam == winner)
            {
                if (statsScorerTeam == 2) statsGoalsT++;
                else if (statsScorerTeam == 3) statsGoalsCT++;

                if (statsScorerTeam == 2)
                {
                    statsRoundsLostCT++;
                    statsRoundsWonT++;
                }
                else if (statsScorerTeam == 3)
                {
                    statsRoundsLostT++;
                    statsRoundsWonCT++;
                }

                AddPlayerStatInt(statsScorerName, statsScorerSteamid, "goals", rankingPointsForGoal);

                // Format(queryString, sizeof(queryString), "UPDATE %s SET goals = (goals + 1), points = (points + %i) WHERE steamid = '%s'", 
                //  table, rankingPointsForGoal, statsScorerSteamid);
                // ExecuteQuery(queryString);

                for (int client = 1; client <= MaxClients; client++)
                {
                    if (IsClientInGame(client) && IsClientConnected(client)) PrintToChat(client, "[Soccer Mod]\x04 %t", "Goal scored by $player", statsScorerName);
                }

                if (statsAssisterClientid > 0 && statsAssisterTeam == winner)
                {
                    if (statsAssisterTeam == 2) statsAssistsT++;
                    else if (statsAssisterTeam == 3) statsAssistsCT++;

                    AddPlayerStatInt(statsAssisterName, statsAssisterSteamid, "assists", rankingPointsForAssist);

                    // Format(queryString, sizeof(queryString), "UPDATE %s SET assists = (assists + 1), points = (points + %i) WHERE steamid = '%s'", 
                    //  table, rankingPointsForAssist, statsAssisterSteamid);
                    // ExecuteQuery(queryString);

                    for (int client = 1; client <= MaxClients; client++)
                    {
                        if (IsClientInGame(client) && IsClientConnected(client)) PrintToChat(client, "[Soccer Mod]\x04 %t", "Assist given by $player", statsAssisterName);
                    }

                    if (matchStarted)
                    {
                        char timeString[16];
                        getTimeString(timeString, matchTime);
                        LogMessage("%s | %i - %i | Goal: %s <%s>, Assist: %s <%s>", timeString, matchScoreCT, matchScoreT, 
                            statsScorerName, statsScorerSteamid, statsAssisterName, statsAssisterSteamid);
                    }
                    else LogMessage("%i - %i | Goal: %s <%s>, Assist: %s <%s>", matchScoreCT, matchScoreT, statsScorerName, 
                        statsScorerSteamid, statsAssisterName, statsAssisterSteamid);
                }
                else
                {
                    if (matchStarted)
                    {
                        char timeString[16];
                        getTimeString(timeString, matchTime);
                        LogMessage("%s | %i - %i | Goal: %s <%s>", timeString, matchScoreCT, matchScoreT, statsScorerName, statsScorerSteamid);
                    }
                    else LogMessage("%i - %i | Goal: %s <%s>", matchScoreCT, matchScoreT, statsScorerName, statsScorerSteamid);
                }
            }
            else
            {
                if (statsScorerTeam == 2) statsOwnGoalsT++;
                else if (statsScorerTeam == 3) statsOwnGoalsCT++;

                if (statsScorerTeam == 2)
                {
                    statsRoundsLostT++;
                    statsRoundsWonCT++;
                }
                else if (statsScorerTeam == 3)
                {
                    statsRoundsLostCT++;
                    statsRoundsWonT++;
                }

                AddPlayerStatInt(statsScorerName, statsScorerSteamid, "own_goals", rankingPointsForOwnGoal);

                // Format(queryString, sizeof(queryString), "UPDATE %s SET own_goals = (own_goals + 1), points = (points + %i) WHERE steamid = '%s'", 
                //  table, rankingPointsForOwnGoal, statsScorerSteamid);
                // ExecuteQuery(queryString);

                for (int client = 1; client <= MaxClients; client++)
                {
                    if (IsClientInGame(client) && IsClientConnected(client)) PrintToChat(client, "[Soccer Mod]\x04 %t", "Own goal scored by $player", statsScorerName);
                }

                if (matchStarted)
                {
                    char timeString[16];
                    getTimeString(timeString, matchTime);
                    LogMessage("%s | %i - %i | Own goal: %s <%s>", timeString, matchScoreCT, matchScoreT, statsScorerName, statsScorerSteamid);
                }
                else LogMessage("%i - %i | Own goal: %s <%s>", matchScoreCT, matchScoreT, statsScorerName, statsScorerSteamid);
            }

            // keygroup = new KeyValues("matchStatistics");
            // keygroup.ImportFromFile(statsKeygroupMatch);

            for (int client = 1; client <= MaxClients; client++)
            {
                if (IsClientInGame(client) && IsClientConnected(client))
                {
                    int team = GetClientTeam(client);
                    if (team > 1)
                    {
                        char steamid[32];
                        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

                        statsKeygroupMatch.JumpToKey(steamid, true);

                        if (team == winner)
                        {
                            int keyValue = statsKeygroupMatch.GetNum("rounds_won", 0);
                            statsKeygroupMatch.SetNum("rounds_won", keyValue + 1);
                            keyValue = statsKeygroupMatch.GetNum("points", 0);
                            statsKeygroupMatch.SetNum("points", keyValue + rankingPointsForRoundWon);

                            // Format(queryString, sizeof(queryString), "UPDATE %s SET rounds_won = (rounds_won + 1), points = (points + %i) WHERE steamid = '%s'", 
                            //  table, rankingPointsForRoundWon, steamid);
                            // ExecuteQuery(queryString);
                        }
                        else
                        {
                            int keyValue = statsKeygroupMatch.GetNum("rounds_lost", 0);
                            statsKeygroupMatch.SetNum("rounds_lost", keyValue + 1);
                            keyValue = statsKeygroupMatch.GetNum("points", 0);
                            statsKeygroupMatch.SetNum("points", keyValue + rankingPointsForRoundLost);

                            // Format(queryString, sizeof(queryString), "UPDATE %s SET rounds_lost = (rounds_lost + 1), points = (points + %i) WHERE steamid = '%s'", 
                            //  table, rankingPointsForRoundLost, steamid);
                            // ExecuteQuery(queryString);
                        }
                    }
                }
            }

            statsKeygroupMatch.Rewind();
            // keygroup.ExportToFile(statsKeygroupMatch);
            // keygroup.Close();

            for (int client = 1; client <= MaxClients; client++)
            {
                if (IsClientInGame(client) && IsClientConnected(client))
                {
                    CreateTimer(0.01, SetPlayerStats, client);
                }
            }

            ShowMVP();

            if (matchStoppageTimeStarted) EndStoppageTime();
        }
    }

    char queryString[1024];
    char table[32] = "soccer_mod_public_stats";
    if (matchStarted) table = "soccer_mod_match_stats";

    // keygroup = new KeyValues("roundStatistics");
    // keygroup.ExportToFile(statsKeygroupRound);
    statsKeygroupRound.GotoFirstSubKey();

    do
    {
        int goals = statsKeygroupRound.GetNum("goals", 0);
        int assists = statsKeygroupRound.GetNum("assists", 0);
        int own_goals = statsKeygroupRound.GetNum("own_goals", 0);
        int rounds_won = statsKeygroupRound.GetNum("rounds_won", 0);
        int rounds_lost = statsKeygroupRound.GetNum("rounds_lost", 0);
        int hits = statsKeygroupRound.GetNum("hits", 0);
        int saves = statsKeygroupRound.GetNum("saves", 0);
        int passes = statsKeygroupRound.GetNum("passes", 0);
        int interceptions = statsKeygroupRound.GetNum("interceptions", 0);
        int ball_losses = statsKeygroupRound.GetNum("ball_losses", 0);
        int points = statsKeygroupRound.GetNum("points", 0);

        // char clanTag[64];
        // CS_GetClientClanTag(client, clanTag, sizeof(clanTag));

        char steamid[32];
        statsKeygroupRound.GetSectionName(steamid, sizeof(steamid));

        Format(queryString, sizeof(queryString), "UPDATE %s SET goals = (goals + %i), assists = (assists + %i), own_goals = (own_goals + %i), rounds_won = (rounds_won + %i), \
            rounds_lost = (rounds_lost + %i), hits = (hits + %i), saves = (saves + %i), passes = (passes + %i), interceptions = (interceptions + %i), ball_losses = (ball_losses + %i), \
            points = (points + %i) WHERE steamid = '%s'", table, goals, assists, own_goals, rounds_won, rounds_lost, hits, saves, passes, interceptions, ball_losses, points, steamid);
        ExecuteQuery(queryString);
    }
    while (statsKeygroupRound.GotoNextKey());

    statsKeygroupRound.Rewind();
    // keygroup.Close();
}

public void StatsEventCSWinPanelMatch(Event event)
{
    ShowManOfTheMatch();
}

// *********************************************************************************************************************
// ************************************************** STATISTICS MENU **************************************************
// *********************************************************************************************************************
public void OpenStatisticsMenu(int client)
{
    Menu menu = new Menu(StatisticsMenuHandler);

    char langString[64];
    Format(langString, sizeof(langString), "Soccer Mod - %T", "Statistics", client);
    menu.SetTitle(langString);

    Format(langString, sizeof(langString), "%T", "Team CT", client);
    menu.AddItem("team_ct", langString);

    Format(langString, sizeof(langString), "%T", "Team T", client);
    menu.AddItem("team_t", langString);

    Format(langString, sizeof(langString), "%T", "Player", client);
    menu.AddItem("player", langString);

    Format(langString, sizeof(langString), "%T", "Current round", client);
    menu.AddItem("round", langString);

    Format(langString, sizeof(langString), "%T", "Current match", client);
    menu.AddItem("map", langString);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int StatisticsMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[32];
        menu.GetItem(choice, menuItem, sizeof(menuItem));

        char langString[64], langString1[64], langString2[64];
        Format(langString1, sizeof(langString1), "%T", "Statistics", client);

        if (StrEqual(menuItem, "team_ct"))
        {
            Format(langString2, sizeof(langString2), "%T", "Team CT", client);
            Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
            OpenTeamStatisticsMenu(client, langString, statsGoalsCT, statsAssistsCT, 
                statsOwnGoalsCT, statsPossessionCT, statsSavesCT, statsPassesCT, statsRoundsWonCT, statsRoundsLostCT, statsInterceptionsCT, statsBallLossesCT, statsHitsCT);
        }
        else if (StrEqual(menuItem, "team_t"))
        {
            Format(langString2, sizeof(langString2), "%T", "Team T", client);
            Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
            OpenTeamStatisticsMenu(client, langString, statsGoalsT, statsAssistsT, 
                statsOwnGoalsT, statsPossessionT, statsSavesT, statsPassesT, statsRoundsWonT, statsRoundsLostT, statsInterceptionsT, statsBallLossesT, statsHitsT);
        }
        else if (StrEqual(menuItem, "player"))              OpenSelectPlayerStatisticsMenu(client);
        else if (StrEqual(menuItem, "round"))               OpenRoundStatisticsMenu(client);
        else if (StrEqual(menuItem, "map"))                 OpenMapStatisticsMenu(client);
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenMenuSoccer(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// **************************************************************************************************************************
// ************************************************** TEAM STATISTICS MENU **************************************************
// **************************************************************************************************************************
public void OpenTeamStatisticsMenu
(
    int client, char title[64], int goals, int assists, int ownGoals, float possession, int saves,
    int passes, int roundsWon, int roundsLost, int interceptions, int ballLosses, int hits
)
{
    Menu menu = new Menu(TeamStatisticsMenuHandler);
    menu.SetTitle(title);

    char menuString[32];
    AddStatisticsMenuItem(client, menu, menuString, "Goals",            goals,          "goals");
    AddStatisticsMenuItem(client, menu, menuString, "Assists",          assists,        "assists");
    AddStatisticsMenuItem(client, menu, menuString, "Own goals",        ownGoals,       "own_goals");

    char langString[64];
    Format(langString, sizeof(langString), "%T", "Possession", client);

    if (statsPossessionTotal > 0)
    {
        int value = RoundToNearest(possession / statsPossessionTotal * 100);
        Format(menuString, sizeof(menuString), "%s: %i%", langString, value);
        menu.AddItem("possession", menuString, ITEMDRAW_DISABLED);
    }
    else
    {
        Format(menuString, sizeof(menuString), "%s: 0%", langString);
        menu.AddItem("possession", menuString, ITEMDRAW_DISABLED);
    }

    AddStatisticsMenuItem(client, menu, menuString, "Saves",            saves,          "saves");
    AddStatisticsMenuItem(client, menu, menuString, "Passes",           passes,         "passes");
    AddStatisticsMenuItem(client, menu, menuString, "Rounds won",       roundsWon,      "rounds_won");
    AddStatisticsMenuItem(client, menu, menuString, "Rounds lost",      roundsLost,     "rounds_lost");
    AddStatisticsMenuItem(client, menu, menuString, "Interceptions",    interceptions,  "interceptions");
    AddStatisticsMenuItem(client, menu, menuString, "Ball losses",      ballLosses,     "ball_losses");
    AddStatisticsMenuItem(client, menu, menuString, "Hits",             hits,           "hits");

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int TeamStatisticsMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)                        OpenStatisticsMenu(client);
    else if (action == MenuAction_Cancel && choice == -6)   OpenStatisticsMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ****************************************************************************************************************************
// ************************************************** PLAYER STATISTICS MENU **************************************************
// ****************************************************************************************************************************
public void OpenSelectPlayerStatisticsMenu(int client)
{
    Menu menu = new Menu(MenuHandlerSelectPlayerStatistics);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Statistics", client);
    Format(langString2, sizeof(langString2), "%T", "Player", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsClientConnected(player))
        {
            char playerid[8];
            IntToString(player, playerid, sizeof(playerid));

            char playerName[MAX_NAME_LENGTH];
            GetClientName(player, playerName, sizeof(playerName));

            menu.AddItem(playerid, playerName);
        }
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerSelectPlayerStatistics(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)
    {
        char menuItem[8];
        menu.GetItem(choice, menuItem, sizeof(menuItem));
        int target = StringToInt(menuItem);

        if (IsClientInGame(target) && IsClientConnected(target)) OpenPlayerStatisticsMenu(client, target);
        else
        {
            PrintToChat(client, "[Soccer Mod]\x04 %t", "Player is no longer on the server");
            OpenStatisticsMenu(client);
        }
    }
    else if (action == MenuAction_Cancel && choice == -6)   OpenStatisticsMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

public void OpenPlayerStatisticsMenu(int client, int target)
{
    Menu menu = new Menu(MenuHandlerPlayerStatistics);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Statistics", client);
    Format(langString2, sizeof(langString2), "%T", "Player", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    char steamid[32];
    GetClientAuthId(target, AuthId_Engine, steamid, sizeof(steamid));

    // Handle keygroup = new KeyValues("matchStatistics");
    // keygroup.ImportFromFile(statsKeygroupMatch);

    statsKeygroupMatch.JumpToKey(steamid, true);

    char playerName[MAX_NAME_LENGTH];
    GetClientName(target, playerName, sizeof(playerName));

    char menuString[32];
    Format(langString, sizeof(langString), "%T", "Name", client);
    Format(menuString, sizeof(menuString), "%s: %s", langString, playerName);
    menu.AddItem("name", menuString, ITEMDRAW_DISABLED);

    AddStatisticsMenuItem(client, menu, menuString, "Points",           statsKeygroupMatch.GetNum("points", 0),          "points");
    AddStatisticsMenuItem(client, menu, menuString, "Goals",            statsKeygroupMatch.GetNum("goals", 0),           "goals");
    AddStatisticsMenuItem(client, menu, menuString, "Assists",          statsKeygroupMatch.GetNum("assists", 0),         "assists");
    AddStatisticsMenuItem(client, menu, menuString, "Own goals",        statsKeygroupMatch.GetNum("own_goals", 0),       "own_goals");

    Format(langString, sizeof(langString), "%T", "Possession", client);

    if (statsPossessionTotal > 0)
    {
        int value = RoundToNearest(statsKeygroupMatch.GetFloat("possession", 0.0) / statsPossessionTotal * 100);
        Format(menuString, sizeof(menuString), "%s: %i%", langString, value);
        menu.AddItem("possession", menuString, ITEMDRAW_DISABLED);
    }
    else
    {
        Format(menuString, sizeof(menuString), "%s: 0%", langString);
        menu.AddItem("possession", menuString, ITEMDRAW_DISABLED);
    }

    AddStatisticsMenuItem(client, menu, menuString, "Saves",            statsKeygroupMatch.GetNum("saves", 0),           "saves");
    AddStatisticsMenuItem(client, menu, menuString, "Passes",           statsKeygroupMatch.GetNum("passes", 0),          "passes");
    AddStatisticsMenuItem(client, menu, menuString, "Rounds won",       statsKeygroupMatch.GetNum("rounds_won", 0),      "rounds_won");
    AddStatisticsMenuItem(client, menu, menuString, "Rounds lost",      statsKeygroupMatch.GetNum("rounds_lost", 0),     "rounds_lost");
    AddStatisticsMenuItem(client, menu, menuString, "Interceptions",    statsKeygroupMatch.GetNum("interceptions", 0),   "interceptions");
    AddStatisticsMenuItem(client, menu, menuString, "Ball losses",      statsKeygroupMatch.GetNum("ball_losses", 0),     "ball_losses");
    AddStatisticsMenuItem(client, menu, menuString, "Hits",             statsKeygroupMatch.GetNum("hits", 0),            "hits");

    statsKeygroupMatch.Rewind();
    // keygroup.Close();

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandlerPlayerStatistics(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)                        OpenStatisticsMenu(client);
    else if (action == MenuAction_Cancel && choice == -6)   OpenStatisticsMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ***************************************************************************************************************************
// ************************************************** ROUND STATISTICS MENU **************************************************
// ***************************************************************************************************************************
public void OpenRoundStatisticsMenu(int client)
{
    Menu menu = new Menu(RoundStatisticsMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Statistics", client);
    Format(langString2, sizeof(langString2), "%T", "Current round", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    char steamid[32];
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

    // KeyValues keygroup = new KeyValues("roundStatistics");
    // keygroup.ExportToFile(statsKeygroupRound);

    statsKeygroupRound.JumpToKey(steamid, true);

    char menuString[32];
    AddStatisticsMenuItem(client, menu, menuString, "Points",           statsKeygroupRound.GetNum("points", 0),          "points");
    AddStatisticsMenuItem(client, menu, menuString, "Goals",            statsKeygroupRound.GetNum("goals", 0),           "goals");
    AddStatisticsMenuItem(client, menu, menuString, "Assists",          statsKeygroupRound.GetNum("assists", 0),         "assists");
    AddStatisticsMenuItem(client, menu, menuString, "Own goals",        statsKeygroupRound.GetNum("own_goals", 0),       "own_goals");
    AddStatisticsMenuItem(client, menu, menuString, "Saves",            statsKeygroupRound.GetNum("saves", 0),           "saves");
    AddStatisticsMenuItem(client, menu, menuString, "Passes",           statsKeygroupRound.GetNum("passes", 0),          "passes");
    AddStatisticsMenuItem(client, menu, menuString, "Interceptions",    statsKeygroupRound.GetNum("interceptions", 0),   "interceptions");
    AddStatisticsMenuItem(client, menu, menuString, "Ball losses",      statsKeygroupRound.GetNum("ball_losses", 0),     "ball_losses");
    AddStatisticsMenuItem(client, menu, menuString, "Hits",             statsKeygroupRound.GetNum("hits", 0),            "hits");

    statsKeygroupRound.Rewind();
    // keygroup.Close();

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int RoundStatisticsMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)                        OpenRoundStatisticsMenu(client);
    else if (action == MenuAction_Cancel && choice == -6)   OpenStatisticsMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// *************************************************************************************************************************
// ************************************************** MAP STATISTICS MENU **************************************************
// *************************************************************************************************************************
public void OpenMapStatisticsMenu(int client)
{
    Menu menu = new Menu(MapStatisticsMenuHandler);

    char langString[64], langString1[64], langString2[64];
    Format(langString1, sizeof(langString1), "%T", "Statistics", client);
    Format(langString2, sizeof(langString2), "%T", "Current match", client);
    Format(langString, sizeof(langString), "Soccer Mod - %s - %s", langString1, langString2);
    menu.SetTitle(langString);

    char steamid[32];
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

    // Handle keygroup = new KeyValues("matchStatistics");
    // keygroup.ImportFromFile(statsKeygroupMatch);

    statsKeygroupMatch.JumpToKey(steamid, true);

    char menuString[32];
    AddStatisticsMenuItem(client, menu, menuString, "Points",           statsKeygroupMatch.GetNum("points", 0),          "points");
    AddStatisticsMenuItem(client, menu, menuString, "Goals",            statsKeygroupMatch.GetNum("goals", 0),           "goals");
    AddStatisticsMenuItem(client, menu, menuString, "Assists",          statsKeygroupMatch.GetNum("assists", 0),         "assists");
    AddStatisticsMenuItem(client, menu, menuString, "Own goals",        statsKeygroupMatch.GetNum("own_goals", 0),       "own_goals");

    Format(langString, sizeof(langString), "%T", "Possession", client);

    if (statsPossessionTotal > 0)
    {
        int value = RoundToNearest(statsKeygroupMatch.GetFloat("possession", 0.0) / statsPossessionTotal * 100);
        Format(menuString, sizeof(menuString), "%s: %i%", langString, value);
        menu.AddItem("possession", menuString, ITEMDRAW_DISABLED);
    }
    else
    {
        Format(menuString, sizeof(menuString), "%s: 0%", langString);
        menu.AddItem("possession", menuString, ITEMDRAW_DISABLED);
    }

    AddStatisticsMenuItem(client, menu, menuString, "Saves",            statsKeygroupMatch.GetNum("saves", 0),           "saves");
    AddStatisticsMenuItem(client, menu, menuString, "Passes",           statsKeygroupMatch.GetNum("passes", 0),          "passes");
    AddStatisticsMenuItem(client, menu, menuString, "Rounds won",       statsKeygroupMatch.GetNum("rounds_won", 0),      "rounds_won");
    AddStatisticsMenuItem(client, menu, menuString, "Rounds lost",      statsKeygroupMatch.GetNum("rounds_lost", 0),     "rounds_lost");
    AddStatisticsMenuItem(client, menu, menuString, "Interceptions",    statsKeygroupMatch.GetNum("interceptions", 0),   "interceptions");
    AddStatisticsMenuItem(client, menu, menuString, "Ball losses",      statsKeygroupMatch.GetNum("ball_losses", 0),     "ball_losses");
    AddStatisticsMenuItem(client, menu, menuString, "Hits",             statsKeygroupMatch.GetNum("hits", 0),            "hits");

    statsKeygroupMatch.Rewind();
    // keygroup.Close();

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MapStatisticsMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
    if (action == MenuAction_Select)                        OpenMapStatisticsMenu(client);
    else if (action == MenuAction_Cancel && choice == -6)   OpenStatisticsMenu(client);
    else if (action == MenuAction_End)                      menu.Close();
}

// ************************************************************************************************************
// ************************************************** TIMERS **************************************************
// ************************************************************************************************************
public Action SetPlayerStats(Handle timer, any client)
{
    if (IsClientInGame(client) && IsClientConnected(client))
    {
        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

        // Handle keygroup = new KeyValues("matchStatistics");
        // keygroup.ImportFromFile(statsKeygroupMatch);

        statsKeygroupMatch.JumpToKey(steamid, true);

        SetEntProp(client, Prop_Data, "m_iFrags", statsKeygroupMatch.GetNum("goals", 0));

        if (StrEqual(game, "csgo"))
        {
            CS_SetClientAssists(client, statsKeygroupMatch.GetNum("assists", 0));
            CS_SetClientContributionScore(client, statsKeygroupMatch.GetNum("points", 0));
            SetEntProp(client, Prop_Data, "m_iDeaths", statsKeygroupMatch.GetNum("hits", 0));
        }
        else SetEntProp(client, Prop_Data, "m_iDeaths", statsKeygroupMatch.GetNum("points", 0));

        CS_SetMVPCount(client, statsKeygroupMatch.GetNum("mvpCount", 0));

        statsKeygroupMatch.Rewind();
        // keygroup.Close();
    }
}

// ***************************************************************************************************************
// ************************************************** FUNCTIONS **************************************************
// ***************************************************************************************************************
public void ResetMatchStats()
{
    statsPossessionTotal    = 0.0;
    statsPossessionCT       = 0.0;
    statsPossessionT        = 0.0;
    statsGoalsCT            = 0;
    statsGoalsT             = 0;
    statsAssistsCT          = 0;
    statsAssistsT           = 0;
    statsOwnGoalsCT         = 0;
    statsOwnGoalsT          = 0;
    statsHitsCT             = 0;
    statsHitsT              = 0;
    statsPassesCT           = 0;
    statsPassesT            = 0;
    statsInterceptionsCT    = 0;
    statsInterceptionsT     = 0;
    statsBallLossesCT       = 0;
    statsBallLossesT        = 0;
    statsSavesCT            = 0;
    statsSavesT             = 0;
    statsRoundsWonCT        = 0;
    statsRoundsWonT         = 0;
    statsRoundsLostCT       = 0;
    statsRoundsLostT        = 0;

    statsKeygroupMatch.Close();
    statsKeygroupMatch = new KeyValues("matchStatistics");

    statsKeygroupRound.Close();
    statsKeygroupRound = new KeyValues("roundStatistics");
}

public void ResetRoundStats()
{
    statsScorerClientid     = 0;
    statsScorerName         = "";
    statsScorerTeam         = 1;
    statsScorerTimestamp    = GetGameTime();

    statsAssisterClientid   = 0;
    statsAssisterName       = "";
    statsAssisterTeam       = 1;
    statsAssisterTimestamp  = GetGameTime();

    statsSaver              = 0;

    statsKeygroupRound.Close();
    statsKeygroupRound = new KeyValues("roundStatistics");
}

public void AddPlayerStatInt(char name[32], char steamid[32], char stat[16], int points)
{
    // Handle keygroup = new KeyValues("matchStatistics");
    // keygroup.ImportFromFile(statsKeygroupMatch);

    statsKeygroupMatch.JumpToKey(steamid, true);

    int keyValue = statsKeygroupMatch.GetNum(stat, 0);
    statsKeygroupMatch.SetNum(stat, keyValue + 1);

    keyValue = statsKeygroupMatch.GetNum("points", 0);
    statsKeygroupMatch.SetNum("points", keyValue + points);
    statsKeygroupMatch.SetString("name", name);

    statsKeygroupMatch.Rewind();
    // keygroup.ExportToFile(statsKeygroupMatch);
    // keygroup.Close();

    // keygroup = new KeyValues("roundStatistics");
    // keygroup.ExportToFile(statsKeygroupRound);

    statsKeygroupRound.JumpToKey(steamid, true);

    keyValue = statsKeygroupRound.GetNum(stat, 0);
    statsKeygroupRound.SetNum(stat, keyValue + 1);

    keyValue = statsKeygroupRound.GetNum("points", 0);
    statsKeygroupRound.SetNum("points", keyValue + points);
    statsKeygroupRound.SetString("name", name);

    statsKeygroupRound.Rewind();
    // keygroup.ExportToFile(statsKeygroupRound);
    // keygroup.Close();
}

public void AddPlayerStatPossession(char steamid[32], float possession, int team)
{
    if (team == 2) statsPossessionT += possession;
    else if (team == 3) statsPossessionCT += possession;
    statsPossessionTotal += possession;

    // Handle keygroup = new KeyValues("matchStatistics");
    // keygroup.ImportFromFile(statsKeygroupMatch);

    statsKeygroupMatch.JumpToKey(steamid, true);

    float keyValue = statsKeygroupMatch.GetFloat("possession", 0.0);
    statsKeygroupMatch.SetFloat("possession", keyValue + possession);

    statsKeygroupMatch.Rewind();
    // keygroup.ExportToFile(statsKeygroupMatch);
    // keygroup.Close();
}

public void ShowMVP()
{
    int highestScore = 0;
    char roundMVP[MAX_NAME_LENGTH];
    // char steamid[32];
    char steamidMVP[32];
    char queryString[1024];

    // KeyValues keygroup = new KeyValues("roundStatistics");
    // keygroup.ExportToFile(statsKeygroupRound);
    statsKeygroupRound.GotoFirstSubKey();

    // int sizeCT = GetTeamClientCount(3);
    // int sizeT = GetTeamClientCount(2);

    do
    {
        // keygroup.GetSectionName(steamid, sizeof(steamid));

        // if (sizeCT > 1 && sizeT > 1)
        // {
        //  Format(queryString, sizeof(queryString), "UPDATE soccer_mod_players SET money = (money + %i) WHERE steamid = '%s'", keyValue, steamid);
        //  ExecuteQuery(queryString);
        // }

        int keyValue = statsKeygroupRound.GetNum("points", 0);
        if (keyValue > highestScore)
        {
            statsKeygroupRound.GetString("name", roundMVP, sizeof(roundMVP));
            statsKeygroupRound.GetSectionName(steamidMVP, sizeof(steamidMVP));
            highestScore = keyValue;
        }
    }
    while (statsKeygroupRound.GotoNextKey());
    statsKeygroupRound.Rewind();
    // keygroup.Close();

    if (highestScore)
    {
        // keygroup = new KeyValues("matchStatistics");
        // keygroup.ImportFromFile(statsKeygroupMatch);

        statsKeygroupMatch.JumpToKey(steamidMVP, true);

        int keyValue = statsKeygroupMatch.GetNum("mvpCount", 0);
        statsKeygroupMatch.SetNum("mvpCount", keyValue + 1);
        keyValue = statsKeygroupMatch.GetNum("points", 0);
        statsKeygroupMatch.SetNum("points", keyValue + rankingPointsForMVP);

        statsKeygroupMatch.Rewind();
        // keygroup.ExportToFile(statsKeygroupMatch);
        // keygroup.Close();

        char table[32];

        if (matchStarted) table = "soccer_mod_match_stats";
        else table = "soccer_mod_public_stats";

        Format(queryString, sizeof(queryString), "UPDATE %s SET mvp = (mvp + 1), points = (points + %i) WHERE steamid = '%s'", 
            table, rankingPointsForMVP, steamidMVP);
        ExecuteQuery(queryString);

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "$player was the MVP this round with $number points", roundMVP, highestScore);
        }

        LogMessage("%s <%s> was the MVP this round with %i points", roundMVP, steamidMVP, highestScore);
    }
    else
    {
        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "MVP: No player scored more than 0 points this round");
        }
    }
}

public void ShowManOfTheMatch()
{
    int highestScore = 0;
    char matchMVP[MAX_NAME_LENGTH];
    char steamidMVP[32];

    // Handle keygroup = new KeyValues("matchStatistics");
    // keygroup.ImportFromFile(statsKeygroupMatch);
    statsKeygroupMatch.GotoFirstSubKey();

    do
    {
        int keyValue = statsKeygroupMatch.GetNum("points", 0);
        if (keyValue > highestScore)
        {
            statsKeygroupMatch.GetString("name", matchMVP, sizeof(matchMVP));
            statsKeygroupMatch.GetSectionName(steamidMVP, sizeof(steamidMVP));
            highestScore = keyValue;
        }
    }
    while (statsKeygroupMatch.GotoNextKey());

    statsKeygroupMatch.Rewind();
    // keygroup.Close();

    if (highestScore)
    {
        // keygroup = new KeyValues("matchStatistics");
        // keygroup.ImportFromFile(statsKeygroupMatch);

        statsKeygroupMatch.JumpToKey(steamidMVP, true);

        int keyValue = statsKeygroupMatch.GetNum("motm", 0);
        statsKeygroupMatch.SetNum("motm", keyValue + 1);

        statsKeygroupMatch.Rewind();
        // keygroup.ExportToFile(statsKeygroupMatch);
        // keygroup.Close();

        char table[32];
        char queryString[1024];

        if (matchStarted) table = "soccer_mod_match_stats";
        else table = "soccer_mod_public_stats";

        Format(queryString, sizeof(queryString), "UPDATE %s SET motm = (motm + 1), points = (points + %i) WHERE steamid = '%s'", 
            table, rankingPointsForMOTM, steamidMVP);
        ExecuteQuery(queryString);

        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "The man of the match was $player with $number points", matchMVP, highestScore);
        }

        LogMessage("The man of the match was %s <%s> with %i points", matchMVP, steamidMVP, highestScore);
    }
    else
    {
        for (int player = 1; player <= MaxClients; player++)
        {
            if (IsClientInGame(player) && IsClientConnected(player)) PrintToChat(player, "[Soccer Mod]\x04 %t", "MOTM: No player scored more than 0 points this match");
        }
    }
}

public void AddStatisticsMenuItem(int client, Menu menu, char menuString[32], char text[32], int value, char item[32])
{
    char langString[64];
    Format(langString, sizeof(langString), "%T", text, client);
    Format(menuString, sizeof(menuString), "%s: %i", langString, value);
    menu.AddItem(item, menuString, ITEMDRAW_DISABLED);
}