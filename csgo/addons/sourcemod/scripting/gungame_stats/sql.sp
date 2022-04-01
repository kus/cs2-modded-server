// non-threaded
SqlConnect()
{
    if ( g_DbConnection != INVALID_HANDLE )
    {
        return;
    }
    
    decl String:error[256];
    if ( SQL_CheckConfig("gungame") ) {
        g_DbConnection = SQL_Connect("gungame", false, error, sizeof(error));
    } else {
        g_DbConnection = SQL_Connect("storage-local", false, error, sizeof(error));
    }
    
    if ( g_DbConnection == INVALID_HANDLE )
    {
        SetFailState("Unable to connect to database (%s)", error);
        return;
    }
    
    new String:ident[16];
    SQL_ReadDriver(g_DbConnection, ident, sizeof(ident));
    if ( strcmp(ident, "sqlite") == 0 ) {
        g_DbType = DbTypeSqlite;
    } else if ( strcmp(ident, "mysql") == 0 ) {
        g_DbType = DbTypeMysql;
    } else if ( strcmp(ident, "pgsql") == 0 ) {
        g_DbType = DbTypePgsql;
    } else {
        CloseHandle(g_DbConnection);
        g_DbConnection = INVALID_HANDLE;
        SetFailState("Unknown db type (%s)", ident);
        return;
    }
    
    SQL_LockDatabase(g_DbConnection);
    
    new bool:tableExists = false;
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", g_sql_checkTableExists[g_DbType]);
    #endif
    new Handle:result = SQL_Query(g_DbConnection, g_sql_checkTableExists[g_DbType]);
    if ( result == INVALID_HANDLE )
    {
        SQL_GetError(g_DbConnection, error, sizeof(error));
        LogError("Failed to check table exists (error: %s)", error);
        SQL_UnlockDatabase(g_DbConnection);
        return;
    } else {
        tableExists = bool:SQL_GetRowCount(result);
        CloseHandle(result);
    }
    
    if ( !tableExists )
    {
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", g_sql_createPlayerTable[g_DbType]);
        #endif
        if ( !SQL_FastQuery(g_DbConnection, g_sql_createPlayerTable[g_DbType]) )
        {
            SQL_GetError(g_DbConnection, error, sizeof(error));
            LogError("Could not create players table (error: %s)", error);
            SQL_UnlockDatabase(g_DbConnection);
            return;
        }
        if ( g_sql_createPlayerTableIndex1[g_DbType][0] != 0 )
        {
            #if defined SQL_DEBUG
                LogError("[DEBUG-SQL] %s", g_sql_createPlayerTableIndex1[g_DbType]);
            #endif
            if ( !SQL_FastQuery(g_DbConnection, g_sql_createPlayerTableIndex1[g_DbType]) )
            {
                SQL_GetError(g_DbConnection, error, sizeof(error));
                LogError("Could not create players table index 1 (error: %s)", error);
                SQL_UnlockDatabase(g_DbConnection);
                return;
            }
        }
        if ( g_sql_createPlayerTableIndex2[g_DbType][0] != 0 )
        {
            #if defined SQL_DEBUG
                LogError("[DEBUG-SQL] %s", g_sql_createPlayerTableIndex2[g_DbType]);
            #endif
            if ( !SQL_FastQuery(g_DbConnection, g_sql_createPlayerTableIndex2[g_DbType]) )
            {
                SQL_GetError(g_DbConnection, error, sizeof(error));
                LogError("Could not create players table index 2 (error: %s)", error);
                SQL_UnlockDatabase(g_DbConnection);
                return;
            }
        }
    }
    SQL_UnlockDatabase(g_DbConnection);
}

// threaded
SavePlayerData(client)
{
    new wins = PlayerWinsData[client];
    if ( !wins )
    {
        return;
    }
    
    decl String:auth[64], String:name[MAX_NAME_SIZE];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    GetClientName(client, name, sizeof(name));

    new bufferLen = sizeof(name) * 2 + 1;
    decl String:nameQuoted[bufferLen];
 
    SQL_EscapeString(g_DbConnection, name, nameQuoted, bufferLen);
        
    decl String:query[1024];
    Format(query, sizeof(query), wins == 1 ? g_sql_insertPlayer : g_sql_updatePlayerByAuth, wins, nameQuoted, auth);
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", query);
    #endif
    SQL_TQuery(g_DbConnection, T_SavePlayerData, query);
}

// threaded
public T_SavePlayerData(Handle:owner, Handle:result, const String:error[], any:data)
{
    if ( result == INVALID_HANDLE )
    {
        LogError("Failed to save player data (error: %s)", error);
        return;
    }

    // Reload top rank data after winner has beed updated in the database
    LoadRank();
}

// non-threaded
GetPlayerPlaceInStat(client)
{
    // get from cache
    if ( !PlayerWinsData[client] || PlayerPlaceData[client] )
    {
        return PlayerPlaceData[client];
    }
    // get from database
    PlayerPlaceData[client] = GetPlayerPlace(client);
    return PlayerPlaceData[client];
}

// non-threaded
GetPlayerPlace(client)
{
    decl String:query[1024];
    Format(query, sizeof(query), g_sql_getPlayerPlaceByWins, PlayerWinsData[client]);
    SQL_LockDatabase(g_DbConnection);
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", query);
    #endif
    new Handle:result = SQL_Query(g_DbConnection, query);
    if ( result == INVALID_HANDLE )
    {
        new String:error[255];
        SQL_GetError(g_DbConnection, error, sizeof(error));
        LogError("Failed get player place in stats (error: %s)", error);
        SQL_UnlockDatabase(g_DbConnection);
        return 0;
    }
    SQL_UnlockDatabase(g_DbConnection);
    new place;
    if ( SQL_FetchRow(result) )
    {
        place = SQL_FetchInt(result, 0) + 1;
    }
    CloseHandle(result);
    return place;
}

CountPlayersInStat()
{
    return TotalWinners;
}

// threaded
RetrieveKeyValues(client, const String:auth[])
{
    if ( auth[0] == 'B' )
    {
        g_PlayerWinsLoaded[client] = true;
        PlayerWinsData[client] = 0;
        
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] FORWARD PLAYER WINS LOADED client=%i is BOT", client);
        #endif
        
        Call_StartForward(FwdLoadPlayerWins);
        Call_PushCell(client);
        Call_Finish();
        return;
    }
    decl String:query[1024];
    Format(query, sizeof(query), g_sql_getPlayerByAuth, auth);
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", query);
    #endif
    SQL_TQuery(g_DbConnection, T_RetrieveKeyValues, query, client);
}

public T_RetrieveKeyValues(Handle:owner, Handle:result, const String:error[], any:client)
{
    /* Make sure the client didn't disconnect while the thread was running */
    if ( !IsClientConnected(client) )
    {
        return;
    }
    if ( result == INVALID_HANDLE )
    {
        LogError("Failed to retrieve player by auth (error: %s)", error);
        return;
    }
    g_PlayerWinsLoaded[client] = true;
    if ( SQL_FetchRow(result) )
    {
        new id = SQL_FetchInt(result, 0);
        PlayerWinsData[client] = SQL_FetchInt(result, 1);
        
        // update player timestamp
        decl String:query[1024];
        Format(query, sizeof(query), g_sql_updatePlayerTsById, id);
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", query);
        #endif
        SQL_TQuery(g_DbConnection, T_FastQueryResult, query);
    }
    else
    {
        PlayerWinsData[client] = 0;
    }
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] FORWARD PLAYER WINS LOADED client=%i, wins=%i", client, PlayerWinsData[client]);
    #endif
    Call_StartForward(FwdLoadPlayerWins);
    Call_PushCell(client);
    Call_Finish();
}

public T_FastQueryResult(Handle:owner, Handle:result, const String:error[], any:data)
{
    if ( result == INVALID_HANDLE )
    {
        LogError("Fast query failed (error: %s)", error);
        return;
    }
    // reqest was successfull
}

// threaded
SavePlayerDataInfo()
{
    if (!Prune) {
        return;
    }

    decl String:query[1024];
    if ( g_DbType == DbTypeSqlite ) {
        Format(query, sizeof(query), g_sql_prunePlayers[g_DbType], GetTime() - Prune*86400);
    } else {
        Format(query, sizeof(query), g_sql_prunePlayers[g_DbType], Prune);
    }
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", query);
    #endif
    SQL_TQuery(g_DbConnection, T_SavePlayerDataInfo, query);
}

public T_SavePlayerDataInfo(Handle:owner, Handle:result, const String:error[], any:data)
{
    if ( result == INVALID_HANDLE )
    {
        LogError("Could not prune players (error: %s)", error);
        return;
    }
}

OnCreateKeyValues()
{
    SqlConnect();
    LoadRank();
}

// non-threaded
public Action:_CmdImport(client, args)
{
    decl String:EsFile[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, EsFile, sizeof(EsFile), "data/gungame/es_gg_winners_db.txt");

    if ( !FileExists(EsFile) )
    {
        ReplyToCommand(client, "[GunGame] es_gg_winners_db.txt does not exists to be imported.");
        return Plugin_Handled;
    }

    new Handle:KvGunGame = CreateKeyValues("gg_winners", BLANK, BLANK);
    FileToKeyValues(KvGunGame, EsFile);

    /* Go to first SubKey */
    if ( !KvGotoFirstSubKey(KvGunGame) )
    {
        ReplyToCommand(client, "[GunGame] You have no player data to import.");
        return Plugin_Handled;
    }

    decl String:query[1024], String:error[255];
    decl Wins, String:Name[64];
    decl ImportedWins, String:Auth[64];

    new bufferLen = sizeof(Name) * 2 + 1;
    decl String:nameQuoted[bufferLen];

    do
    {
        KvGetSectionName(KvGunGame, Auth, sizeof(Auth));
        ImportedWins = KvGetNum(KvGunGame, "wins");

        if ( !ImportedWins || Auth[0] != 'S' )
        {
            continue;
        }

        // Load player data        
        SQL_LockDatabase(g_DbConnection);
        Format(query, sizeof(query), g_sql_getPlayerByAuth, Auth);
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", query);
        #endif
        new Handle:result = SQL_Query(g_DbConnection, query);
        if ( result == INVALID_HANDLE )
        {
            SQL_GetError(g_DbConnection, error, sizeof(error));
            LogError("Failed to get player (error: %s)", error);
            SQL_UnlockDatabase(g_DbConnection);
            ReplyToCommand(client, "[GunGame] Import finished with sql error");
            CloseHandle(KvGunGame);
            return Plugin_Handled;
        }
        SQL_UnlockDatabase(g_DbConnection);
        if ( SQL_FetchRow(result) )
        {
            Wins = SQL_FetchInt(result, 1);
            SQL_FetchString(result, 2, Name, sizeof(Name));
        }
        else
        {
            Wins = 0;
        }
        CloseHandle(result);
        
        if ( Wins ) {
            SQL_EscapeString(g_DbConnection, Name, nameQuoted, bufferLen);
            Format(query, sizeof(query), g_sql_updatePlayerByAuth, Wins + ImportedWins, nameQuoted, Auth);
        } else {
            KvGetString(KvGunGame, "name", Name, sizeof(Name));
            SQL_EscapeString(g_DbConnection, Name, nameQuoted, bufferLen);
            Format(query, sizeof(query), g_sql_insertPlayer, ImportedWins, nameQuoted, Auth);
        }

        // SavePlayerData
        SQL_LockDatabase(g_DbConnection);
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", query);
        #endif
        if ( !SQL_FastQuery(g_DbConnection, query) )
        {
            SQL_GetError(g_DbConnection, error, sizeof(error));
            LogError("Could not save player (error: %s)", error);
            SQL_UnlockDatabase(g_DbConnection);
            ReplyToCommand(client, "[GunGame] Import finished with sql error");
            CloseHandle(KvGunGame);
            return Plugin_Handled;
        }
        SQL_UnlockDatabase(g_DbConnection);
    }
    while(KvGotoNextKey(KvGunGame));

    CloseHandle(KvGunGame);
    
    /* Reload the players wins in memory */
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientAuthorized(i) )
        {
            GetClientAuthId(i, AuthId_Steam2, Auth, sizeof(Auth));
            RetrieveKeyValues(i, Auth);
        }
    }

    ReplyToCommand(client, "[GunGame] Import of es player data completed. Please run gg_rebuild to update the top rank.");

    return Plugin_Handled;
}

// non-threaded
public Action:_CmdImportDb(client, args)
{
    decl String:PlayerDataFile[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, PlayerDataFile, sizeof(PlayerDataFile), "data/gungame/playerdata.txt");

    if ( !FileExists(PlayerDataFile) )
    {
        ReplyToCommand(client, "[GunGame] playerdata.txt does not exists to be imported.");
        return Plugin_Handled;
    }

    new Handle:KvGunGame = CreateKeyValues("gg_PlayerData", BLANK, BLANK);
    FileToKeyValues(KvGunGame, PlayerDataFile);

    /* Go to first SubKey */
    if ( !KvGotoFirstSubKey(KvGunGame) )
    {
        ReplyToCommand(client, "[GunGame] You have no player data to import.");
        return Plugin_Handled;
    }

    decl String:query[1024], String:error[255];
    decl Wins, String:Name[64];
    decl ImportedWins, String:Auth[64];

    new bufferLen = sizeof(Name) * 2 + 1;
    decl String:nameQuoted[bufferLen];

    do
    {
        KvGetSectionName(KvGunGame, Auth, sizeof(Auth));
        ImportedWins = KvGetNum(KvGunGame, "Wins");

        if ( !ImportedWins || Auth[0] != 'S' )
        {
            continue;
        }

        // Load player data        
        SQL_LockDatabase(g_DbConnection);
        Format(query, sizeof(query), g_sql_getPlayerByAuth, Auth);
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", query);
        #endif
        new Handle:result = SQL_Query(g_DbConnection, query);
        if ( result == INVALID_HANDLE )
        {
            SQL_GetError(g_DbConnection, error, sizeof(error));
            LogError("Failed to get player (error: %s)", error);
            SQL_UnlockDatabase(g_DbConnection);
            ReplyToCommand(client, "[GunGame] Import finished with sql error");
            CloseHandle(KvGunGame);
            return Plugin_Handled;
        }
        SQL_UnlockDatabase(g_DbConnection);
        if ( SQL_FetchRow(result) )
        {
            Wins = SQL_FetchInt(result, 1);
            SQL_FetchString(result, 2, Name, sizeof(Name));
        }
        else
        {
            Wins = 0;
        }
        CloseHandle(result);
        
        if ( Wins ) {
            SQL_EscapeString(g_DbConnection, Name, nameQuoted, bufferLen);
            Format(query, sizeof(query), g_sql_updatePlayerByAuth, Wins + ImportedWins, nameQuoted, Auth);
        } else {
            KvGetString(KvGunGame, "Name", Name, sizeof(Name));
            SQL_EscapeString(g_DbConnection, Name, nameQuoted, bufferLen);
            Format(query, sizeof(query), g_sql_insertPlayer, ImportedWins, nameQuoted, Auth);
        }

        // SavePlayerData
        SQL_LockDatabase(g_DbConnection);
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", query);
        #endif
        if ( !SQL_FastQuery(g_DbConnection, query) )
        {
            SQL_GetError(g_DbConnection, error, sizeof(error));
            LogError("Could not save player (error: %s)", error);
            SQL_UnlockDatabase(g_DbConnection);
            ReplyToCommand(client, "[GunGame] Import finished with sql error");
            CloseHandle(KvGunGame);
            return Plugin_Handled;
        }
        SQL_UnlockDatabase(g_DbConnection);
    }
    while(KvGotoNextKey(KvGunGame));

    CloseHandle(KvGunGame);
    
    /* Reload the players wins in memory */
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientAuthorized(i) )
        {
            GetClientAuthId(i, AuthId_Steam2, Auth, sizeof(Auth));
            RetrieveKeyValues(i, Auth);
        }
    }

    ReplyToCommand(client, "[GunGame] Import of player data completed. Please run gg_rebuild to update the top rank.");

    return Plugin_Handled;
}

// threaded
public Action:_CmdRebuild(client, args)
{
    LoadRank();
    ReplyToCommand(client, "[GunGame] Top rank has been rebuilt");
    return Plugin_Handled;
}

// non-threaded
public Action:_CmdReset(client, args)
{
    decl String:error[256];
    SQL_LockDatabase(g_DbConnection);
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", g_sql_dropPlayerTable);
    #endif
    if ( !SQL_FastQuery(g_DbConnection, g_sql_dropPlayerTable) )
    {
        SQL_GetError(g_DbConnection, error, sizeof(error));
        LogError("Could not drop players table (error: %s)", error);
        SQL_UnlockDatabase(g_DbConnection);
        ReplyToCommand(client, "[GunGame] Error reseting stats.");
        return Plugin_Handled;
    }
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", g_sql_createPlayerTable[g_DbType]);
    #endif
    if ( !SQL_FastQuery(g_DbConnection, g_sql_createPlayerTable[g_DbType]) )
    {
        SQL_GetError(g_DbConnection, error, sizeof(error));
        LogError("Could not create players table (error: %s)", error);
        SQL_UnlockDatabase(g_DbConnection);
        ReplyToCommand(client, "[GunGame] Error reseting stats.");
        return Plugin_Handled;
    }
    if ( g_sql_createPlayerTableIndex1[g_DbType][0] != 0 )
    {
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", g_sql_createPlayerTableIndex1[g_DbType]);
        #endif
        if ( !SQL_FastQuery(g_DbConnection, g_sql_createPlayerTableIndex1[g_DbType]) )
        {
            SQL_GetError(g_DbConnection, error, sizeof(error));
            LogError("Could not create players table index 1 (error: %s)", error);
            SQL_UnlockDatabase(g_DbConnection);
            return Plugin_Handled;
        }
    }
    if ( g_sql_createPlayerTableIndex2[g_DbType][0] != 0 )
    {
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] %s", g_sql_createPlayerTableIndex2[g_DbType]);
        #endif
        if ( !SQL_FastQuery(g_DbConnection, g_sql_createPlayerTableIndex2[g_DbType]) )
        {
            SQL_GetError(g_DbConnection, error, sizeof(error));
            LogError("Could not create players table index 2 (error: %s)", error);
            SQL_UnlockDatabase(g_DbConnection);
            return Plugin_Handled;
        }
    }
    SQL_UnlockDatabase(g_DbConnection);
    ReplyToCommand(client, "[GunGame] Stats has been reseted.");
    
    // reset current players data
    for (new i = 1; i <= MAXPLAYERS; i++)
    {
        PlayerWinsData[i] = 0;
        PlayerPlaceData[i] = 0;
    }
    
    // reset top 10 data
    TotalWinners = 0;
    g_cfgHandicapTopWins = 0;
    
    return Plugin_Handled;
}

// threaded
LoadRank()
{
    // reset top 10 data
    TotalWinners = 0;
    g_cfgHandicapTopWins = 0;
    for ( new i = 1; i <= MAXPLAYERS; i++ )
    {
        PlayerPlaceData[i] = 0;
    }
    
    CountWinners();
}

// threaded
CountWinners()
{
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", g_sql_getPlayersCount);
    #endif
    SQL_TQuery(g_DbConnection, T_CountWinners, g_sql_getPlayersCount);
}

public T_CountWinners(Handle:owner, Handle:result, const String:error[], any:data)
{
    if ( result == INVALID_HANDLE )
    {
        LogError("Failed to count players in stat (error: %s)", error);
        return;
    }
    new count = 0;
    if ( SQL_FetchRow(result) )
    {
        count = SQL_FetchInt(result, 0);
    }
    TotalWinners = count;
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] Found %i winners in the rank table", TotalWinners);
    #endif

    LoadTopRankData();
}

// threaded
LoadTopRankData()
{
    if ( !g_cfgHandicapTopRank )
    {
        g_cfgHandicapTopWins = 0;
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] Handicap top wins = 0 (handicap top rank is disabled)");
        #endif
        Call_StartForward(FwdLoadRank);
        Call_Finish();
        return;
    }
    
    if ( g_cfgHandicapTopRank >= TotalWinners )
    {
        g_cfgHandicapTopWins = 1;
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] Handicap top wins = 1 (handicap top rank is more then total winners)");
        #endif
        Call_StartForward(FwdLoadRank);
        Call_Finish();
        return;
    }

    decl String:query[1024];
    Format(query, sizeof(query), g_sql_getTopPlayers, 1, g_cfgHandicapTopRank - 1);
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", query);
    #endif
    SQL_TQuery(g_DbConnection, T_LoadTopRankData, query);
}

public T_LoadTopRankData(Handle:owner, Handle:result, const String:error[], any:data)
{
    if ( result == INVALID_HANDLE )
    {
        LogError("Failed to load rank data (error: %s)", error);
        g_cfgHandicapTopWins = 0;
        Call_StartForward(FwdLoadRank);
        Call_Finish();
        return;
    }
    
    if ( SQL_FetchRow(result) )
    {
        g_cfgHandicapTopWins = SQL_FetchInt(result, 1);
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] Handicap top wins = %i", g_cfgHandicapTopWins);
        #endif
    }
    else
    {
        g_cfgHandicapTopWins = 0;
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] Handicap top wins = 0 (cant fetch rows from sql)");
        #endif
    }

    Call_StartForward(FwdLoadRank);
    Call_Finish();
}

// threaded
ShowRank(client)
{
    new wins = PlayerWinsData[client];
    if ( !wins || PlayerPlaceData[client] )
    {
        ShowRankInChat(client);
        return;
    }
    
    decl String:query[1024];
    Format(query, sizeof(query), g_sql_getPlayerPlaceByWins, wins);
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] %s", query);
    #endif
    SQL_TQuery(g_DbConnection, T_ShowRank, query, client);
}

public T_ShowRank(Handle:owner, Handle:result, const String:error[], any:client)
{
    /* Make sure the client didn't disconnect while the thread was running */
    if ( !IsClientConnected(client) )
    {
        return;
    }
    if ( result == INVALID_HANDLE )
    {
        LogError("Failed to retrieve player place by wins (error: %s)", error);
        return;
    }
    if ( SQL_FetchRow(result) )
    {
        PlayerPlaceData[client] = SQL_FetchInt(result, 0) + 1;
    }
    ShowRankInChat(client);
}

ShowRankInChat(client)
{
    decl String:name[MAX_NAME_SIZE];
    GetClientName(client, name, sizeof(name));
    if ( !PlayerPlaceData[client] )
    {
        CPrintToChatAllEx(client, "%t", "Rank: not ranked", name);
    }
    else
    {
        for ( new i = 1; i <= MaxClients; i++ )
        {
            if ( IsClientInGame(i) && !IsFakeClient(i) )
            {
                decl String:subtext[64];
                SetGlobalTransTarget(i);
                FormatLanguageNumberTextEx(i, subtext, sizeof(subtext), PlayerWinsData[client], "with wins");
                CPrintToChatEx(i, client, "%t", "Rank: rank", name, PlayerPlaceData[client], subtext, TotalWinners);
            }
        }
    }
}


bool:IsPlayerInTopRank(client)
{
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] IsPlayerInTopRank client=%i", client);
    #endif
    if ( !g_cfgHandicapTopWins )
    {
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] ... false (top rank handicap wins not loaded)");
        #endif
        return false;
    }
    if ( PlayerWinsData[client] < g_cfgHandicapTopWins )
    {
        #if defined SQL_DEBUG
            LogError("[DEBUG-SQL] ... false (player wins less then top rank handicap wins)");
        #endif
        return false;
    }
    #if defined SQL_DEBUG
        LogError("[DEBUG-SQL] ... true (player wins more or equal to top rank handicap wins)");
    #endif
    return true;
}

