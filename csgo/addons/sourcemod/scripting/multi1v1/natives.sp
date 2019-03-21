// See include/multi1v1.inc for documentation.

#define CHECK_CONNECTED(%1) \
  if (!IsConnected(%1))     \
  ThrowNativeError(SP_ERROR_PARAM, "Client %d is not connected", %1)
#define CHECK_ARENA(%1)             \
  if (%1 <= 0 || %1 > g_maxArenas) \
  ThrowNativeError(SP_ERROR_PARAM, "Arena %d is not valid", %1)
#define CHECK_ROUNDTYPE(%1)             \
  if (%1 < 0 || %1 >= g_numRoundTypes) \
  ThrowNativeError(SP_ERROR_PARAM, "Roundtype %d is not valid", %1)

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  CreateNative("Multi1v1_IsInArena", Native_IsInArena);
  CreateNative("Multi1v1_GetMaximumArenas", Native_GetMaximumArenas);
  CreateNative("Multi1v1_GetNumActiveArenas", Native_GetNumActiveArenas);
  CreateNative("Multi1v1_IsInWaitingQueue", Native_IsInWaitingQueue);
  CreateNative("Multi1v1_HasStats", Native_HasStats);
  CreateNative("Multi1v1_SetRating", Native_SetRating);
  CreateNative("Multi1v1_GetRating", Native_GetRating);
  CreateNative("Multi1v1_GetArenaNumber", Native_GetArenaNumber);
  CreateNative("Multi1v1_GetArenaPlayer1", Native_GetArenaPlayer1);
  CreateNative("Multi1v1_GetArenaPlayer2", Native_GetArenaPlayer2);
  CreateNative("Multi1v1_GetRoundsAtArena1", Native_GetRoundsAtArena1);
  CreateNative("Multi1v1_GetOpponent", Native_GetOpponent);
  CreateNative("Multi1v1_GetRoundsPlayed", Native_GetRoundsPlayed);
  CreateNative("Multi1v1_GetWins", Native_GetWins);
  CreateNative("Multi1v1_GetLosses", Native_GetLosses);
  CreateNative("Multi1v1_HasDatabase", Native_HasDatabase);
  CreateNative("Multi1v1_GetDatabase", Native_GetDatabase);
  CreateNative("Multi1v1_GivePlayerArenaWeapons", Native_GivePlayerArenaWeapons);
  CreateNative("Multi1v1_Message", Native_Multi1v1Message);
  CreateNative("Multi1v1_MessageToAll", Native_Multi1v1MessageToAll);
  CreateNative("Multi1v1_BlockRatingChanges", Native_BlockRatingChanges);
  CreateNative("Multi1v1_UnblockRatingChanges", Native_UnblockRatingChanges);
  CreateNative("Multi1v1_BlockChatMessages", Native_BlockChatMessages);
  CreateNative("Multi1v1_UnblockChatMessages", Native_UnblockChatMessages);
  CreateNative("Multi1v1_BlockMVPStars", Native_BlockMVPStars);
  CreateNative("Multi1v1_UnblockMVPStars", Native_UnblockMVPStars);
  CreateNative("Multi1v1_BlockArenaDones", Native_BlockArenaDones);
  CreateNative("Multi1v1_UnblockArenaDones", Native_UnblockArenaDones);
  CreateNative("Multi1v1_SetArenaOffsetValue", Native_SetArenaOffsetValue);
  CreateNative("Multi1v1_ELORatingDelta", Native_ELORatingDelta);
  CreateNative("Multi1v1_GetNumSpawnsInArena", Native_GetNumSpawnsInArena);
  CreateNative("Multi1v1_GetArenaSpawn", Native_GetArenaSpawn);
  CreateNative("Multi1v1_FindArenaNumber", Native_FindArenaNumber);
  CreateNative("Multi1v1_GetRifleChoice", Native_GetRifleChoice);
  CreateNative("Multi1v1_GetPistolChoice", Native_GetPistolChoice);
  CreateNative("Multi1v1_GetRoundTypeIndex", Native_GetRoundTypeIndex);
  CreateNative("Multi1v1_AddRoundType", Native_AddRoundType);
  CreateNative("Multi1v1_ClearRoundTypes", Native_ClearRoundTypes);
  CreateNative("Multi1v1_AddStandardRounds", Native_AddStandardRounds);
  CreateNative("Multi1v1_GetCurrentRoundType", Native_GetCurrentRoundType);
  CreateNative("Multi1v1_GetNumRoundTypes", Native_GetNumRoundTypes);
  CreateNative("Multi1v1_PlayerAllowsRoundType", Native_PlayerAllowsRoundType);
  CreateNative("Multi1v1_PlayerPreference", Native_PlayerPreference);
  CreateNative("Multi1v1_IsHidingStats", Native_IsHidingStates);
  CreateNative("Multi1v1_IsRoundTypeEnabled", Native_IsRoundTypeEnabled);
  CreateNative("Multi1v1_EnableRoundType", Native_EnableRoundType);
  CreateNative("Multi1v1_DisableRoundType", Native_DisableRoundType);
  CreateNative("Multi1v1_GiveWeaponsMenu", Native_GiveWeaponsMenu);
  CreateNative("Multi1v1_GetRoundTypeDisplayName", Native_GetRoundTypeDisplayName);
  CreateNative("Multi1v1_GivePlayerKnife", Native_GivePlayerKnife);
  RegPluginLibrary("multi1v1");
  return APLRes_Success;
}

public int Native_IsInArena(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_Ranking[client] > 0;
}

public int Native_GetMaximumArenas(Handle plugin, int numParams) {
  return g_maxArenas;
}

public int Native_GetNumActiveArenas(Handle plugin, int numParams) {
  return g_arenas;
}

public int Native_IsInWaitingQueue(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return Queue_Inside(g_waitingQueue, client);
}

public int Native_HasStats(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return !IsFakeClient(client) && g_FetchedPlayerInfo[client];
}

public int Native_GetRating(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  int roundType = GetNativeCell(2);
  CHECK_CONNECTED(client);

  if (roundType < 0) {
    return view_as<int>(g_Rating[client]);
  } else {
    CHECK_ROUNDTYPE(roundType);
    if (g_RoundTypeRanked[roundType])
      ThrowNativeError(SP_ERROR_PARAM, "Roundtype %d is not ranked", roundType);

    return view_as<int>(g_RoundTypeRating[client][roundType]);
  }
}

public int Native_SetRating(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  float rating = GetNativeCell(2);
  CHECK_CONNECTED(client);
  g_Rating[client] = rating;
}

public int Native_GetRoundsPlayed(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_Wins[client] + g_Losses[client];
}

public int Native_GetWins(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_Wins[client];
}

public int Native_GetLosses(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_Losses[client];
}

public int Native_GetArenaNumber(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_Ranking[client];
}

public int Native_GetRoundsAtArena1(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_RoundsLeader[client];
}

public int Native_GetArenaPlayer1(Handle plugin, int numParams) {
  int arena = GetNativeCell(1);
  CHECK_ARENA(arena);
  return g_ArenaPlayer1[arena];
}

public int Native_GetArenaPlayer2(Handle plugin, int numParams) {
  int arena = GetNativeCell(1);
  CHECK_ARENA(arena);
  return g_ArenaPlayer2[arena];
}

public int Native_GetOpponent(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  if (IsValidClient(client)) {
    int arena = g_Ranking[client];
    int other = -1;
    if (client != -1 && arena != -1) {
      other = g_ArenaPlayer1[arena];
      if (other == client)
        other = g_ArenaPlayer2[arena];
    }
    return other;
  }
  return -1;
}

public int Native_HasDatabase(Handle plugin, int numParams) {
  return g_UseDatabaseCvar.IntValue != 0 && db != null;
}

public int Native_GetDatabase(Handle plugin, int numParams) {
  if (!Multi1v1_HasDatabase()) {
    ThrowNativeError(SP_ERROR_PARAM, "The multi1v1 database is not connected");
    return view_as<int>(INVALID_HANDLE);
  } else {
    return view_as<int>(CloneHandle(db, plugin));
  }
}

public int Native_GivePlayerArenaWeapons(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  int roundType = GetNativeCell(2);
  CHECK_CONNECTED(client);
  CHECK_ROUNDTYPE(roundType);

  if (roundType < 0 || roundType >= g_numRoundTypes) {
    RifleHandler(client);
  } else {
    Handle pluginSource = g_RoundTypeSourcePlugin[roundType];
    RoundTypeWeaponHandler weaponHandler = g_RoundTypeWeaponHandlers[roundType];
    Client_RemoveAllWeapons(client);
    Call_StartFunction(pluginSource, weaponHandler);
    Call_PushCell(client);
    Call_Finish();
  }
}

public int Native_Multi1v1Message(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);

  char buffer[1024];
  int bytesWritten = 0;

  SetGlobalTransTarget(client);
  FormatNativeString(0, 2, 3, sizeof(buffer), bytesWritten, buffer);
  char finalMsg[1024];

  if (g_UseChatPrefixCvar.IntValue == 0)
    Format(finalMsg, sizeof(finalMsg), " %s", buffer);
  else
    Format(finalMsg, sizeof(finalMsg), "%s%s", MESSAGE_PREFIX, buffer);

  Colorize(finalMsg, sizeof(finalMsg));
  PrintToChat(client, finalMsg);
}

public int Native_Multi1v1MessageToAll(Handle plugin, int numParams) {
  char buffer[1024];
  char finalMsg[1024];

  int bytesWritten = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsValidClient(i)) {
      SetGlobalTransTarget(i);
      FormatNativeString(0, 1, 2, sizeof(buffer), bytesWritten, buffer);

      if (g_UseChatPrefixCvar.IntValue == 0)
        Format(finalMsg, sizeof(finalMsg), " %s", buffer);
      else
        Format(finalMsg, sizeof(finalMsg), "%s%s", MESSAGE_PREFIX, buffer);

      Colorize(finalMsg, sizeof(finalMsg));
      PrintToChat(i, finalMsg);
    }
  }
}

public int Native_BlockRatingChanges(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  g_BlockStatChanges[client] = true;
}

public int Native_UnblockRatingChanges(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  g_BlockStatChanges[client] = false;
}

public int Native_BlockChatMessages(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  g_BlockChatMessages[client] = true;
}

public int Native_UnblockChatMessages(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  g_BlockChatMessages[client] = false;
}

public int Native_BlockMVPStars(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  g_BlockMVPStars[client] = true;
}

public int Native_UnblockMVPStars(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  g_BlockMVPStars[client] = false;
}

public int Native_BlockArenaDones(Handle plugin, int numParams) {
  int arena = GetNativeCell(1);
  g_BlockArenaDones[arena] = true;
}

public int Native_UnblockArenaDones(Handle plugin, int numParams) {
  int arena = GetNativeCell(1);
  g_BlockArenaDones[arena] = false;
}

public int Native_SetArenaOffsetValue(Handle plugin, int numParams) {
  g_arenaOffsetValue = GetNativeCell(1);
}

public int Native_ELORatingDelta(Handle plugin, int numParams) {
  float winner_rating = GetNativeCell(1);
  float loser_rating = GetNativeCell(2);
  float K = GetNativeCell(3);
  float pWinner = 1.0 / (1.0 + Pow(10.0, (loser_rating - winner_rating) / DISTRIBUTION_SPREAD));
  float pLoser = 1.0 - pWinner;
  float winner_delta = K * pLoser;
  return view_as<int>(winner_delta);
}

public int Native_GetNumSpawnsInArena(Handle plugin, int numParams) {
  int arena = GetNativeCell(1);
  CHECK_ARENA(arena);

  ArrayList ct = view_as<ArrayList>(GetArrayCell(g_CTSpawnsList, arena - 1));
  ArrayList t = view_as<ArrayList>(GetArrayCell(g_TSpawnsList, arena - 1));
  return Math_Min(GetArraySize(ct), GetArraySize(t));
}

public int Native_GetArenaSpawn(Handle plugin, int numParams) {
  float origin[3];
  float angle[3];
  int arena = GetNativeCell(1);
  int team = GetNativeCell(2);

  CHECK_ARENA(arena);
  if (team != CS_TEAM_T && team != CS_TEAM_CT)
    ThrowNativeError(SP_ERROR_PARAM, "Invalid team: %d", team);

  ArrayList spawns;
  ArrayList angles;
  if (team == CS_TEAM_CT) {
    spawns = view_as<ArrayList>(GetArrayCell(g_CTSpawnsList, arena - 1));
    angles = view_as<ArrayList>(GetArrayCell(g_CTAnglesList, arena - 1));
  } else {
    spawns = view_as<ArrayList>(GetArrayCell(g_TSpawnsList, arena - 1));
    angles = view_as<ArrayList>(GetArrayCell(g_TAnglesList, arena - 1));
  }

  int count = GetArraySize(spawns);
  int index = GetRandomInt(0, count - 1);
  GetArrayArray(spawns, index, origin);
  GetArrayArray(angles, index, angle);

  SetNativeArray(3, origin, sizeof(origin));
  SetNativeArray(4, angle, sizeof(angle));

  return index;
}

public int Native_FindArenaNumber(Handle plugin, int numParams) {
  float origin[3];
  GetNativeArray(1, origin, 3);
  return FindClosestArenaNumber(origin);
}

public int Native_GetRifleChoice(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  SetNativeString(2, g_PrimaryWeapon[client], WEAPON_NAME_LENGTH);
}

public int Native_GetPistolChoice(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  SetNativeString(2, g_SecondaryWeapon[client], WEAPON_NAME_LENGTH);
}

public int Native_ClearRoundTypes(Handle plugin, int numParams) {
  g_numRoundTypes = 0;
}

public int Native_AddRoundType(Handle plugin, int numParams) {
  if (g_numRoundTypes >= MAX_ROUND_TYPES) {
    ThrowNativeError(SP_ERROR_PARAM, "Tried to add new round when %d round types already added",
                     MAX_ROUND_TYPES);
    return -1;
  }

  char displayName[ROUND_TYPE_NAME_LENGTH];
  char internalName[ROUND_TYPE_NAME_LENGTH];
  char ratingFieldName[ROUND_TYPE_NAME_LENGTH];

  GetNativeString(1, displayName, sizeof(displayName));
  GetNativeString(2, internalName, sizeof(internalName));

  if (StrEqual(internalName, "")) {
    ThrowNativeError(SP_ERROR_PARAM,
                     "You may not use the empty string as an internal name for round types");
    return -1;
  }

  // Check for duplicate internal names
  for (int i = 0; i < g_numRoundTypes; i++) {
    if (StrEqual(g_RoundTypeNames[i], internalName, false)) {
      ThrowNativeError(SP_ERROR_PARAM, "Tried to add duplicate round type internal name = \"%s\"",
                       internalName);
      return -1;
    }
  }

  RoundTypeWeaponHandler weaponHandler = view_as<RoundTypeWeaponHandler>(GetNativeFunction(3));
  bool optional = GetNativeCell(4);
  bool ranked = GetNativeCell(5);
  GetNativeString(6, ratingFieldName, sizeof(ratingFieldName));
  bool enabled = GetNativeCell(7);

  if (!ranked && !StrEqual(ratingFieldName, "")) {
    LogError("Warning: marked round type \"%s\" as unranked but passed rating field name \"%s\"",
             internalName, ratingFieldName);
  }

  return AddRoundType(plugin, displayName, internalName, weaponHandler, optional, ranked,
                      ratingFieldName, enabled);
}

public int Native_GetRoundTypeIndex(Handle plugin, int numParams) {
  char buffer[ROUND_TYPE_NAME_LENGTH];
  GetNativeString(1, buffer, sizeof(buffer));
  for (int i = 0; i < g_numRoundTypes; i++) {
    if (StrEqual(buffer, g_RoundTypeNames[i], false)) {
      return i;
    }
  }

  return -1;
}

public int Native_AddStandardRounds(Handle plugin, int numParams) {
  AddStandardRounds();
}

public int Native_GetCurrentRoundType(Handle plugin, int numParams) {
  int arena = GetNativeCell(1);
  CHECK_ARENA(arena);
  return g_roundTypes[arena];
}

public int Native_GetNumRoundTypes(Handle plugin, int numParams) {
  return g_numRoundTypes;
}

public int Native_PlayerAllowsRoundType(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);

  int roundType = GetNativeCell(2);
  CHECK_ROUNDTYPE(roundType);

  return g_RoundTypeOptional[roundType] || g_AllowedRoundTypes[client][roundType];
}

public int Native_PlayerPreference(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_Preference[client];
}

public int Native_IsHidingStates(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  return g_HideStats[client];
}

public int Native_IsRoundTypeEnabled(Handle plugin, int numParams) {
  int roundType = GetNativeCell(1);
  CHECK_ROUNDTYPE(roundType);
  return g_RoundTypeEnabled[roundType];
}

public int Native_EnableRoundType(Handle plugin, int numParams) {
  int roundType = GetNativeCell(1);
  CHECK_ROUNDTYPE(roundType);
  g_RoundTypeEnabled[roundType] = true;
}

public int Native_DisableRoundType(Handle plugin, int numParams) {
  int roundType = GetNativeCell(1);
  CHECK_ROUNDTYPE(roundType);
  g_RoundTypeEnabled[roundType] = false;
}

public int Native_GiveWeaponsMenu(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  int pos = GetNativeCell(2);
  GiveWeaponsMenu(client, pos);
}

public int Native_GetRoundTypeDisplayName(Handle plugin, int numParams) {
  int roundType = GetNativeCell(1);
  CHECK_ROUNDTYPE(roundType);
  int bufferLength = GetNativeCell(3);
  SetNativeString(2, g_RoundTypeDisplayNames[roundType], bufferLength);
}

public int Native_GivePlayerKnife(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  CHECK_CONNECTED(client);
  if (GetClientTeam(client) == CS_TEAM_T)
    GivePlayerItem(client, "weapon_knife_t");
  else
    GivePlayerItem(client, "weapon_knife");
}
