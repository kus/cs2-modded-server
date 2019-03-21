public bool HasActiveReplay(int client) {
  return ReplayExists(g_ReplayId[client]);
}

public bool IsPossibleReplayBot(int client) {
  if (!IsValidClient(client) || !IsFakeClient(client) || IsClientSourceTV(client)) {
    return false;
  }
  return IsFakeClient(client) && !g_IsPMBot[client];
}

public bool IsReplayBot(int client) {
  return GetReplayRoleNumber(client) >= 0;
}

public int GetReplayRoleNumber(int client) {
  if (!IsPossibleReplayBot(client)) {
    return -1;
  }
  for (int i = 0; i < MAX_REPLAY_CLIENTS; i++) {
    if (g_ReplayBotClients[i] == client) {
      return i;
    }
  }
  return -1;
}

public int GetLargestBotUserId() {
  int largestUserid = -1;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsValidClient(i) && IsFakeClient(i) && !IsClientSourceTV(i)) {
      int userid = GetClientUserId(i);
      if (userid > largestUserid && !IsReplayBot(i)) {
        largestUserid = userid;
      }
    }
  }
  return largestUserid;
}

public int GetLiveBot(const char[] name) {
  int largestUserid = GetLargestBotUserId();
  if (largestUserid == -1) {
    return -1;
  }

  int bot = GetClientOfUserId(largestUserid);
  if (!IsValidClient(bot)) {
    return -1;
  }

  SetClientName(bot, name);
  CS_SwitchTeam(bot, CS_TEAM_T);
  KillBot(bot);
  return bot;
}

stock void RunReplay(const char[] id, int exclude = -1) {
  if (IsReplayPlaying()) {
    LogError("Called RunReplay with an active replay!");
    return;
  }

  for (int i = 0; i < MAX_REPLAY_CLIENTS; i++) {
    if (i == exclude) {
      continue;
    }

    int bot = g_ReplayBotClients[i];
    if (IsValidClient(bot) && HasRoleRecorded(id, i)) {
      ReplayRole(id, bot, i);
    }
  }
}

public void KillBot(int client) {
  float botOrigin[3] = {-7000.0, 0.0, 0.0};
  TeleportEntity(client, botOrigin, NULL_VECTOR, NULL_VECTOR);
  ForcePlayerSuicide(client);
}

// Starts a replay.
void ReplayRole(const char[] id, int client, int role) {
  if (!IsValidClient(client)) {
    return;
  }

  if (!IsReplayBot(client)) {
    LogError("Called ReplayRole on non-replay bot %L", client);
    return;
  }
  if (BotMimic_IsPlayerMimicing(client)) {
    LogError("Called ReplayRole on already-replaying bot %L", client);
    return;
  }

  char filepath[PLATFORM_MAX_PATH + 1];
  GetRoleFile(id, role, filepath, sizeof(filepath));
  GetRoleNades(id, role, client);

  char roleName[REPLAY_ROLE_DESCRIPTION_LENGTH];
  if (GetRoleName(id, role, roleName, sizeof(roleName))) {
    SetClientName(client, roleName);
  }

  g_CurrentReplayNadeIndex[client] = 0;
  CS_SwitchTeam(client, GetRoleTeam(id, role));
  CS_RespawnPlayer(client);
  DataPack pack = new DataPack();
  pack.WriteCell(client);
  pack.WriteString(filepath);
  g_StopBotSignal[client] = false;
  g_CurrentReplayNadeIndex[client] = 0;
  RequestFrame(StartReplay, pack);
}

// Delayed replay start until after the respawn is done to prevent crashes.
// TOOD: see if we really need this.
public void StartReplay(DataPack pack) {
  pack.Reset();
  int client = pack.ReadCell();
  char filepath[128];
  pack.ReadString(filepath, sizeof(filepath));

  if (g_BotReplayChickenMode) {
    SetEntityModel(client, CHICKEN_MODEL);
    SetEntPropFloat(client, Prop_Send, "m_flModelScale", 10.0);
  }

  BMError err = BotMimic_PlayRecordFromFile(client, filepath);
  if (err != BM_NoError) {
    char errString[128];
    BotMimic_GetErrorString(err, errString, sizeof(errString));
    LogError("Error playing record %s on client %d: %s", filepath, client, errString);
  }

  delete pack;
}

// Cancels all current replays.
public void CancelAllReplays() {
  for (int i = 0; i < MAX_REPLAY_CLIENTS; i++) {
    int bot = g_ReplayBotClients[i];
    if (IsValidClient(bot) && BotMimic_IsPlayerMimicing(bot)) {
      BotMimic_StopPlayerMimic(bot);
      RequestFrame(Timer_DelayKillBot, GetClientSerial(g_ReplayBotClients[i]));
    }
  }
}

// Delayed bot kill to prevent crashes.
// TODO: see if we really need this.
public void Timer_DelayKillBot(int serial) {
  int client = GetClientFromSerial(serial);
  if (IsReplayBot(client)) {
    float zero[3];
    TeleportEntity(client, zero, zero, zero);
    KillBot(client);

    int role = GetReplayRoleNumber(client);
    char name[64];
    Format(name, sizeof(name), "Replay Bot %d", role + 1);
    SetClientName(client, name);
  }
}

// Returns if a replay is currently playing.
stock bool IsReplayPlaying(int role = -1) {
  for (int i = 0; i < MAX_REPLAY_CLIENTS; i++) {
    if (role != -1 && role != i) {
      continue;
    }

    int bot = g_ReplayBotClients[i];
    if (IsValidClient(bot) && BotMimic_IsPlayerMimicing(bot)) {
      return true;
    }
  }
  return false;
}

// Teleports a client to the point where a replay begins.
public void GotoReplayStart(int client, const char[] id, int role) {
  char filepath[PLATFORM_MAX_PATH + 1];
  GetRoleFile(id, role, filepath, sizeof(filepath));
  int header[BMFileHeader];
  BMError error = BotMimic_GetFileHeaders(filepath, header, sizeof(header));
  if (error != BM_NoError) {
    char errorString[128];
    BotMimic_GetErrorString(error, errorString, sizeof(errorString));
    LogError("Failed to get %s headers: %s", filepath, errorString);
    return;
  }

  float origin[3];
  float angles[3];
  float velocity[3];
  Array_Copy(header[BMFH_initialPosition], origin, 3);
  Array_Copy(header[BMFH_initialAngles], angles, 3);
  TeleportEntity(client, origin, angles, velocity);
}

// Functions to add a replay nade during a recording session to the practicemode-extra data
// saved with replays.
public void AddReplayNade(int client, GrenadeType type, float delay, const float[3] personOrigin,
                   const float[3] personAngles, const float[3] grenadeOrigin,
                   const float[3] grenadeVelocity) {
  int index = g_NadeReplayData[client].Push(type);
  g_NadeReplayData[client].Set(index, view_as<int>(delay), 1);
  g_NadeReplayData[client].Set(index, view_as<int>(personOrigin[0]), 2);
  g_NadeReplayData[client].Set(index, view_as<int>(personOrigin[1]), 3);
  g_NadeReplayData[client].Set(index, view_as<int>(personOrigin[2]), 4);
  g_NadeReplayData[client].Set(index, view_as<int>(personAngles[0]), 5);
  g_NadeReplayData[client].Set(index, view_as<int>(personAngles[1]), 6);
  g_NadeReplayData[client].Set(index, view_as<int>(personAngles[2]), 7);
  g_NadeReplayData[client].Set(index, view_as<int>(grenadeOrigin[0]), 8);
  g_NadeReplayData[client].Set(index, view_as<int>(grenadeOrigin[1]), 9);
  g_NadeReplayData[client].Set(index, view_as<int>(grenadeOrigin[2]), 10);
  g_NadeReplayData[client].Set(index, view_as<int>(grenadeVelocity[0]), 11);
  g_NadeReplayData[client].Set(index, view_as<int>(grenadeVelocity[1]), 12);
  g_NadeReplayData[client].Set(index, view_as<int>(grenadeVelocity[2]), 13);
}

// Retrieves a grenade form the practicemode-specific data.
public void GetReplayNade(int client, int index, GrenadeType& type, float& delay, float personOrigin[3],
                   float personAngles[3], float grenadeOrigin[3], float grenadeVelocity[3]) {
  type = g_NadeReplayData[client].Get(index, 0);
  delay = g_NadeReplayData[client].Get(index, 1);
  personOrigin[0] = g_NadeReplayData[client].Get(index, 2);
  personOrigin[1] = g_NadeReplayData[client].Get(index, 3);
  personOrigin[2] = g_NadeReplayData[client].Get(index, 4);
  personAngles[0] = g_NadeReplayData[client].Get(index, 5);
  personAngles[1] = g_NadeReplayData[client].Get(index, 6);
  personAngles[2] = g_NadeReplayData[client].Get(index, 7);
  grenadeOrigin[0] = g_NadeReplayData[client].Get(index, 8);
  grenadeOrigin[1] = g_NadeReplayData[client].Get(index, 9);
  grenadeOrigin[2] = g_NadeReplayData[client].Get(index, 10);
  grenadeVelocity[0] = g_NadeReplayData[client].Get(index, 11);
  grenadeVelocity[1] = g_NadeReplayData[client].Get(index, 12);
  grenadeVelocity[2] = g_NadeReplayData[client].Get(index, 13);
}
