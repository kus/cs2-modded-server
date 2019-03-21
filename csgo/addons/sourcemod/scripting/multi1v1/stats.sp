char g_TableFormat[][] = {
    "accountID INT NOT NULL default 0",     "serverID INT NOT NULL default 0",
    "auth varchar(72) NOT NULL default ''", "name varchar(72) NOT NULL default ''",
    "wins INT NOT NULL default 0",          "losses INT NOT NULL default 0",
    "rating FLOAT NOT NULL default 1500.0", "lastTime INT default 0 NOT NULL",
    "recentRounds INT default 0 NOT NULL",  "PRIMARY KEY (accountID, serverID)"};

/**
 * Attempts to connect to the database.
 * Creates the stats (TABLE_NAME) if needed.
 */
public void DB_Connect() {
  char error[255];
  db = SQL_Connect(DATABASE_CONFIG_NAME, true, error, sizeof(error));
  if (db == INVALID_HANDLE) {
    LogError("Could not connect: %s", error);
  } else {
    db.SetCharset("utf8");
    // Auto-create tables/update columns.
    if (g_AutoCreateTablesCvar.IntValue != 0) {
      SQL_LockDatabase(db);

      // Create the player stats table.
      SQL_CreateTable(db, TABLE_NAME, g_TableFormat, sizeof(g_TableFormat));

      // Add new columns/key for backwards compatability reaons.
      SQL_AddColumn(db, TABLE_NAME, "serverID INT NOT NULL default 0");
      SQL_AddColumn(db, TABLE_NAME, "recentRounds INT default 0 NOT NULL");
      for (int i = 0; i < g_numRoundTypes; i++) {
        if (HasRoundTypeSpecificRating(i)) {
          char buffer[255];
          Format(buffer, sizeof(buffer), "%s FLOAT NOT NULL default 1500.0",
                 g_RoundTypeFieldNames[i]);
          SQL_AddColumn(db, TABLE_NAME, buffer);
        }
      }

      // Update primary keys for backwards compatibility.
      SQL_UpdatePrimaryKey(db, TABLE_NAME, "`accountID`,`serverID`");

      SQL_UnlockDatabase(db);
    }
  }
}

/**
 * Generic SQL threaded query error callback.
 */
public void SQLErrorCheckCallback(Handle owner, Handle hndl, const char[] error, int data) {
  if (!StrEqual("", error)) {
    LogError("Last SQL Error: %s", error);
  }
}

/**
 * Adds a player, updating their name if they already exist, to the database.
 */
public void DB_AddPlayer(int client) {
  if (db != INVALID_HANDLE && IsConnected(client)) {
    int id = GetSteamAccountID(client);
    if (id == 0) {
      LogMessage("Failed GetSteamAccountID for client %L", client);
      return;
    }

    // steam id
    char auth[32];
    if (!GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth))) {
      LogMessage("Failed to get steam2 id for %L", client);
      return;
    }

    char authSanitized[sizeof(auth) * 2 + 1];
    if (!SQL_EscapeString(db, auth, authSanitized, sizeof(authSanitized))) {
      LogMessage("Failed to get sanitized auth string for %L", client);
      return;
    }

    int serverID = g_DatabaseServerIdCvar.IntValue;

    // insert if not already in the table
    char query[1024];
    Format(query, sizeof(query),
           "INSERT IGNORE INTO %s (accountID,serverID,auth) VALUES (%d, %d, '%s');", TABLE_NAME, id,
           serverID, authSanitized);
    db.Query(Callback_Insert, query, GetClientSerial(client));
  }
}

public void Callback_Insert(Handle owner, Handle hndl, const char[] error, int serial) {
  if (!StrEqual("", error)) {
    LogError("Callback_Insert SQL Error: %s", error);
  } else {
    int client = GetClientFromSerial(serial);
    if (!IsConnected(client))
      return;

    int id = GetSteamAccountID(client);

    if (id > 0) {
      DB_FetchRatings(client);

      char name[32];
      if (!GetClientName(client, name, sizeof(name))) {
        LogError("Failed to get name for %L", client);
        return;
      }

      char sanitized_name[sizeof(name) * 2 + 1];
      if (!SQL_EscapeString(db, name, sanitized_name, sizeof(sanitized_name))) {
        LogError("Failed to get sanitized name for %L", client);
        return;
      }

      // update the player name and last connect time
      int serverID = g_DatabaseServerIdCvar.IntValue;
      char query[1024];
      Format(query, sizeof(query),
             "UPDATE %s SET name = '%s', lastTime = %d WHERE accountID = %d AND serverID = %d",
             TABLE_NAME, sanitized_name, GetTime(), id, serverID);
      db.Query(SQLErrorCheckCallback, query);
    }
  }
}

/**
 * Reads a player rating from the database.
 */
public void DB_FetchRatings(int client) {
  g_FetchedPlayerInfo[client] = false;
  if (db != INVALID_HANDLE && IsConnected(client)) {
    int id = GetSteamAccountID(client);
    if (id != 0) {
      int serverID = g_DatabaseServerIdCvar.IntValue;

      char roundTypeRatings[1024] = "";
      int count = 0;
      for (int i = 0; i < g_numRoundTypes; i++) {
        if (!HasRoundTypeSpecificRating(i))
          continue;

        if (count > 0)
          StrCat(roundTypeRatings, sizeof(roundTypeRatings), ", ");
        count++;

        StrCat(roundTypeRatings, sizeof(roundTypeRatings), g_RoundTypeFieldNames[i]);
      }

      char query[2048];
      Format(query, sizeof(query),
             "SELECT rating, wins, losses, %s FROM %s WHERE accountID = %d AND serverID = %d",
             roundTypeRatings, TABLE_NAME, GetSteamAccountID(client), serverID);
      db.Query(Callback_FetchRating, query, GetClientSerial(client));
    }
  }
}

public void Callback_FetchRating(Handle owner, Handle hndl, const char[] error, int serial) {
  int client = GetClientFromSerial(serial);
  if (!IsConnected(client) || g_FetchedPlayerInfo[client])
    return;

  g_FetchedPlayerInfo[client] = false;
  if (hndl == INVALID_HANDLE) {
    LogError("Query failed: (error: %s)", error);
  } else if (SQL_FetchRow(hndl)) {
    g_Rating[client] = SQL_FetchFloat(hndl, 0);
    g_Wins[client] = SQL_FetchInt(hndl, 1);
    g_Losses[client] = SQL_FetchInt(hndl, 2);

    int fieldIndex = 3;
    for (int i = 0; i < g_numRoundTypes; i++) {
      if (!HasRoundTypeSpecificRating(i))
        continue;
      g_RoundTypeRating[client][i] = SQL_FetchFloat(hndl, fieldIndex);
      fieldIndex++;
    }

    g_FetchedPlayerInfo[client] = true;
    Call_StartForward(g_hOnStatsCached);
    Call_PushCell(client);
    Call_Finish();
  } else {
    LogError("Failed to fetch statistics for for %L", client);
  }
}

/**
 * Writes the rating for a player, if the rating is valid, back to the database.
 */
public void DB_WriteRatings(int client) {
  if (g_FetchedPlayerInfo[client] && IsPlayer(client)) {
    int serverID = g_DatabaseServerIdCvar.IntValue;

    char roundTypeRatings[1024] = "";

    for (int i = 0; i < g_numRoundTypes; i++) {
      if (!HasRoundTypeSpecificRating(i))
        continue;

      char buffer[128];
      Format(buffer, sizeof(buffer), ", %s = %f", g_RoundTypeFieldNames[i],
             g_RoundTypeRating[client][i]);
      StrCat(roundTypeRatings, sizeof(roundTypeRatings), buffer);
    }

    char query[2048];
    Format(query, sizeof(query),
           "UPDATE %s set rating = %f %s WHERE accountID = %d AND serverID = %d", TABLE_NAME,
           g_Rating[client], roundTypeRatings, GetSteamAccountID(client), serverID);
    db.Query(SQLErrorCheckCallback, query);
  }
}

/**
 * Performs all stats-related round-update logic for
 * a winner/loser pair.
 */
public void DB_RoundUpdate(int winner, int loser, bool forceLoss) {
  if (IsPlayer(winner) && IsPlayer(loser) && g_UseDatabaseCvar.IntValue != 0) {
    // TODO: this is a temporary band-aid for the first round ending
    //  too early sometimes and unfairly punishes early connectors
    if (forceLoss && g_totalRounds <= 3) {
      return;
    }

    int arena = g_Ranking[winner];
    int roundType = g_roundTypes[arena];
    if (!g_RoundTypeRanked[roundType])
      return;

    g_Losses[loser]++;
    Increment(loser, "losses");

    if (forceLoss) {
      g_Losses[winner]++;
      Increment(winner, "losses");
    } else {
      g_Wins[winner]++;
      Increment(winner, "wins");
    }

    Increment(winner, "recentRounds");
    Increment(loser, "recentRounds");
    UpdateRatings(winner, loser, forceLoss, roundType);
  }
}

/**
 * Increments a named field in the database.
 */
public void Increment(int client, const char[] field) {
  if (db != INVALID_HANDLE && IsPlayer(client)) {
    int id = GetSteamAccountID(client);
    if (id >= 1) {
      int serverid = g_DatabaseServerIdCvar.IntValue;
      char query[1024];
      Format(query, sizeof(query),
             "UPDATE %s SET %s = %s + 1 WHERE accountID = %d AND serverID = %d", TABLE_NAME, field,
             field, id, serverid);
      db.Query(SQLErrorCheckCallback, query);
    }
  }
}

/**
 * Fetches, if needed, and calculates the relevent players' new ratings.
 */
static void UpdateRatings(int winner, int loser, bool forceLoss, int roundType) {
  if (db != INVALID_HANDLE && CountActivePlayers() >= g_MinPlayersForRatingChangesCvar.IntValue) {
    // go fetch the ratings if needed
    if (!g_FetchedPlayerInfo[winner]) {
      DB_FetchRatings(winner);
    }

    if (!g_FetchedPlayerInfo[loser]) {
      DB_FetchRatings(loser);
    }

    // give up - we don't have the ratings yet, better luck next time?
    if (!g_FetchedPlayerInfo[winner] || !g_FetchedPlayerInfo[loser]) {
      return;
    }

    bool block = g_BlockStatChanges[winner] || g_BlockStatChanges[loser];
    if (block) {
      return;
    }

    if (forceLoss) {
      ForceLoss(winner, loser);
    } else {
      float delta = Multi1v1_ELORatingDelta(g_Rating[winner], g_Rating[loser], K_FACTOR);
      g_Rating[winner] += delta;
      g_Rating[loser] -= delta;
      RatingMessage(winner, loser, g_Rating[winner], g_Rating[loser], delta);

      if (HasRoundTypeSpecificRating(roundType)) {
        delta = Multi1v1_ELORatingDelta(g_RoundTypeRating[winner][roundType],
                                        g_RoundTypeRating[loser][roundType], K_FACTOR);
        g_RoundTypeRating[winner][roundType] += delta;
        g_RoundTypeRating[loser][roundType] -= delta;
      }

      DB_WriteRatings(winner);
      DB_WriteRatings(loser);
    }
  }
}

static void ForceLoss(int winner, int loser) {
  float delta = K_FACTOR / 2.0;
  g_Rating[winner] -= delta;
  g_Rating[loser] -= delta;
  DB_WriteRatings(winner);
  DB_WriteRatings(loser);
  ForceLossMessage(winner, g_Rating[winner], delta);
  ForceLossMessage(loser, g_Rating[loser], delta);
}

static void RatingMessage(int winner, int loser, float winner_rating, float loser_rating,
                          float delta) {
  int winner_int = RoundToNearest(winner_rating);
  int loser_int = RoundToNearest(loser_rating);
  if (!g_HideStats[winner])
    Multi1v1_Message(winner, "%t", "WonMessage", winner_int, delta, loser, loser_int, delta);
  if (!g_HideStats[loser])
    Multi1v1_Message(loser, "%t", "LossMessage", loser_int, delta, winner, winner_int, delta);
}

static void ForceLossMessage(int client, float rating, float delta) {
  if (!g_HideStats[client])
    Multi1v1_Message(client, "%t", "TimeRanOut", RoundToNearest(rating), delta);
}

static bool HasRoundTypeSpecificRating(int roundType) {
  return g_RoundTypeRanked[roundType] && !StrEqual(g_RoundTypeFieldNames[roundType], "");
}

public bool AreStatsEnabled() {
  return g_UseDatabaseCvar.IntValue != 0 && SQL_CheckConfig(DATABASE_CONFIG_NAME);
}

static int CountActivePlayers() {
  int count = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      int team = GetClientTeam(i);
      if (team == CS_TEAM_T || team == CS_TEAM_CT) {
        count++;
      }
    }
  }
  return count;
}
