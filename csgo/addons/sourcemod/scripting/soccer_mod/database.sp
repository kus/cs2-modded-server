public void ConnectToDatabase()
{
    char error[256];
    db = SQL_Connect(databaseConfig, false, error, sizeof(error));

    if (db == INVALID_HANDLE) LogError("Could not connect to the database: %s", error);
    else CreateTables();
}

public void CreateTables()
{
    char query[1024] = "CREATE TABLE soccer_mod_players (\
        steamid         VARCHAR(32)     PRIMARY KEY     NOT NULL,\
        name            VARCHAR(255)                    NOT NULL,\
        last_connected  INTEGER         DEFAULT '0'     NOT NULL,\
        created         INTEGER         DEFAULT '0'     NOT NULL,\
        play_time       INTEGER         DEFAULT '0'     NOT NULL,\
        player_ip       VARCHAR(16)                     NOT NULL,\
        server_ip       VARCHAR(16)                     NOT NULL\
    )";
    SQL_FastQuery(db, query);

    query = "CREATE TABLE soccer_mod_positions (\
        steamid         VARCHAR(32)     PRIMARY KEY     NOT NULL,\
        gk              INTEGER         DEFAULT '0'     NOT NULL,\
        lb              INTEGER         DEFAULT '0'     NOT NULL,\
        rb              INTEGER         DEFAULT '0'     NOT NULL,\
        mf              INTEGER         DEFAULT '0'     NOT NULL,\
        lw              INTEGER         DEFAULT '0'     NOT NULL,\
        rw              INTEGER         DEFAULT '0'     NOT NULL\
    )";
    SQL_FastQuery(db, query);

    query = "CREATE TABLE soccer_mod_match_stats (\
        steamid         VARCHAR(32)     PRIMARY KEY     NOT NULL,\
        goals           INTEGER         DEFAULT '0'     NOT NULL,\
        assists         INTEGER         DEFAULT '0'     NOT NULL,\
        own_goals       INTEGER         DEFAULT '0'     NOT NULL,\
        hits            INTEGER         DEFAULT '0'     NOT NULL,\
        passes          INTEGER         DEFAULT '0'     NOT NULL,\
        interceptions   INTEGER         DEFAULT '0'     NOT NULL,\
        ball_losses     INTEGER         DEFAULT '0'     NOT NULL,\
        saves           INTEGER         DEFAULT '0'     NOT NULL,\
        rounds_won      INTEGER         DEFAULT '0'     NOT NULL,\
        rounds_lost     INTEGER         DEFAULT '0'     NOT NULL,\
        points          INTEGER         DEFAULT '0'     NOT NULL\
    )";
    SQL_FastQuery(db, query);

    query = "CREATE TABLE soccer_mod_public_stats (\
        steamid         VARCHAR(32)     PRIMARY KEY     NOT NULL,\
        goals           INTEGER         DEFAULT '0'     NOT NULL,\
        assists         INTEGER         DEFAULT '0'     NOT NULL,\
        own_goals       INTEGER         DEFAULT '0'     NOT NULL,\
        hits            INTEGER         DEFAULT '0'     NOT NULL,\
        passes          INTEGER         DEFAULT '0'     NOT NULL,\
        interceptions   INTEGER         DEFAULT '0'     NOT NULL,\
        ball_losses     INTEGER         DEFAULT '0'     NOT NULL,\
        saves           INTEGER         DEFAULT '0'     NOT NULL,\
        rounds_won      INTEGER         DEFAULT '0'     NOT NULL,\
        rounds_lost     INTEGER         DEFAULT '0'     NOT NULL,\
        points          INTEGER         DEFAULT '0'     NOT NULL\
    )";
    SQL_FastQuery(db, query);

    ApplyPatches();
}

public void ApplyPatches()
{
    SQL_FastQuery(db, "ALTER TABLE soccer_mod_players ADD money INTEGER DEFAULT '0' NOT NULL");

    SQL_FastQuery(db, "ALTER TABLE soccer_mod_match_stats ADD mvp INTEGER DEFAULT '0' NOT NULL");
    SQL_FastQuery(db, "ALTER TABLE soccer_mod_match_stats ADD motm INTEGER DEFAULT '0' NOT NULL");

    SQL_FastQuery(db, "ALTER TABLE soccer_mod_public_stats ADD mvp INTEGER DEFAULT '0' NOT NULL");
    SQL_FastQuery(db, "ALTER TABLE soccer_mod_public_stats ADD motm INTEGER DEFAULT '0' NOT NULL");
}

public bool ExecuteQuery(char[] query)
{
    if (!SQL_TQuery(db, ExecuteQueryCallback, query))
    {
        char error[256];
        SQL_GetError(db, error, sizeof(error));
        LogError("Failed to query: %s (error: %s)", query, error);
        return false;
    }
    return true;
}

public void ExecuteQueryCallback(Handle owner, Handle hndl, const char[] error, any data)
{
    if (hndl == INVALID_HANDLE) LogError("Failed to query (error: %s)", error);
}

public void DatabaseCheckPlayer(int client)
{
    if (client && !IsFakeClient(client))
    {
        char steamid[32];
        GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));

        if (steamid[1])
        {
            char queryString[128];
            Format(queryString, sizeof(queryString), "SELECT steamid FROM soccer_mod_players WHERE steamid = '%s'", steamid);

            char name[MAX_NAME_LENGTH];
            char escapedName[MAX_NAME_LENGTH];
            GetClientName(client, name, sizeof(name));
            SQL_EscapeString(db, name, escapedName, sizeof(escapedName));

            char ip[32];
            GetClientIP(client, ip, sizeof(ip));

            char lastConnected[32];
            Format(lastConnected, sizeof(lastConnected), "%i", GetTime());

            DataPack pack = new DataPack();
            pack.WriteString(escapedName);
            pack.WriteString(steamid);
            pack.WriteString(ip);
            pack.WriteString(lastConnected);
            SQL_TQuery(db, DatabaseCheckPlayerCallback, queryString, pack);
        }
    }
}

public void DatabaseCheckPlayerCallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{
    if (hndl == INVALID_HANDLE) LogError("Failed to query (error: %s)", error);
    else
    {
        char name[64];
        char steamid[32];
        char playerIP[32];
        char lastConnected[32];

        pack.Reset();
        pack.ReadString(name, sizeof(name));
        pack.ReadString(steamid, sizeof(steamid));
        pack.ReadString(playerIP, sizeof(playerIP));
        pack.ReadString(lastConnected, sizeof(lastConnected));

        char serverIP[32];
        int pieces[4];
        int longip = GetConVarInt(FindConVar("hostip"));
        pieces[0] = (longip >> 24) & 0x000000FF;
        pieces[1] = (longip >> 16) & 0x000000FF;
        pieces[2] = (longip >> 8) & 0x000000FF;
        pieces[3] = longip & 0x000000FF;
        Format(serverIP, sizeof(serverIP), "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);

        char queryString[512];
        if (SQL_GetRowCount(hndl))
        {
            Format(queryString, sizeof(queryString), "UPDATE soccer_mod_players SET name = '%s', last_connected = '%s', player_ip = '%s', server_ip = '%s' WHERE steamid = '%s'", 
                name, lastConnected, playerIP, serverIP, steamid);
            ExecuteQuery(queryString);
        }
        else
        {
            Format(queryString, sizeof(queryString), "INSERT INTO soccer_mod_players (name, steamid, created, player_ip, server_ip) VALUES ('%s', '%s', '%s', '%s', '%s')", 
                name, steamid, lastConnected, playerIP, serverIP);
            ExecuteQuery(queryString);
            Format(queryString, sizeof(queryString), "INSERT INTO soccer_mod_match_stats (steamid) VALUES ('%s')", steamid);
            ExecuteQuery(queryString);
            Format(queryString, sizeof(queryString), "INSERT INTO soccer_mod_public_stats (steamid) VALUES ('%s')", steamid);
            ExecuteQuery(queryString);
        }
    }
}