public void Spawns_MapStart() {
  FindMapSpawnsForTeam(g_CTSpawns, "info_player_counterterrorist");
  FindMapSpawnsForTeam(g_TSpawns, "info_player_terrorist");

  // Initialize the saved spawn names.
  char mapName[PLATFORM_MAX_PATH];
  GetCleanMapName(mapName, sizeof(mapName));
  char path[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, path, sizeof(path), "data/practicemode/spawns/%s.cfg", mapName);

  delete g_NamedSpawnsKv;
  g_NamedSpawnsKv = new KeyValues("NamedSpawns");
  g_NamedSpawnsKv.ImportFromFile(path);
}

public void Spawns_MapEnd() {
  char dir[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, dir, sizeof(dir), "data/practicemode/spawns");
  if (!DirExists(dir)) {
    if (!CreateDirectory(dir, 511))
      LogError("Failed to create directory %s", dir);
  }

  char mapName[PLATFORM_MAX_PATH];
  GetCleanMapName(mapName, sizeof(mapName));
  char path[PLATFORM_MAX_PATH];
  Format(path, sizeof(path), "%s/%s.cfg", dir, mapName);

  DeleteFile(path);
  if (!g_NamedSpawnsKv.ExportToFile(path)) {
    LogError("Failed to write spawn names to %s", path);
  }
}

public Action Command_SaveSpawn(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char arg[64];
  if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
    int team = GetClientTeam(client);
    SaveNamedSpawn(client, team, arg);
    PM_Message(client, "Saved spawn \"%s\"", arg);
    TeleportToNamedSpawn(client, team, arg);
    SetEntityMoveType(client, MOVETYPE_WALK);
  } else {
    PM_Message(client, "Usage: .namespawn <name>");
  }

  return Plugin_Handled;
}

public Action Command_GotoSpawn(int client, int args) {
  return SpawnCommandWrapper(client, args, GetClientTeam(client));
}

public Action Command_GotoSpawnT(int client, int args) {
  return SpawnCommandWrapper(client, args, CS_TEAM_T);
}

public Action Command_GotoSpawnCT(int client, int args) {
  return SpawnCommandWrapper(client, args, CS_TEAM_CT);
}

public Action SpawnCommandWrapper(int client, int args, int team) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!IsPlayerAlive(client)) {
    CS_RespawnPlayer(client);
    return Plugin_Handled;
  }

  if (IsPlayer(client)) {
    ArrayList spawnList = null;
    if (team == CS_TEAM_CT) {
      spawnList = g_CTSpawns;
    } else {
      spawnList = g_TSpawns;
    }

    char arg[32];
    int spawnIndex = -1;
    // Note: the spawn_number argumment in .spawn <spawn_number> is 1-indexed for users.
    if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
      // If 0, then we use the arg as the user setting or going to a named location
      int argInt = StringToInt(arg);
      if (argInt == 0 && !StrEqual(arg, "0")) {
        if (DoesNamedSpawnExist(team, arg)) {
          TeleportToNamedSpawn(client, team, arg);
          PM_Message(client, "Moved to spawn \"%s\"", arg);
        } else {
          PM_Message(
              client,
              "There is no spawn for \"%s\", use .namespawn <name> to add a name for your nearest spawn point",
              arg);
        }
        return Plugin_Handled;

      } else {
        spawnIndex = argInt - 1;
      }
    } else {
      spawnIndex = FindNearestSpawnIndex(client, spawnList);
    }

    if (spawnIndex < 0 || spawnIndex >= spawnList.Length) {
      PM_Message(client, "Spawn number out of range. (%d max)", spawnList.Length);
      return Plugin_Handled;
    }

    int ent = spawnList.Get(spawnIndex);
    TeleportToSpawnEnt(client, ent);
    SetEntityMoveType(client, MOVETYPE_WALK);
    PM_Message(client, "Moved to spawn %d (of %d).", spawnIndex + 1, spawnList.Length);
  }
  return Plugin_Handled;
}

public Action Command_GotoWorstSpawn(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (IsPlayer(client)) {
    ArrayList spawnList = null;
    if (GetClientTeam(client) == CS_TEAM_CT) {
      spawnList = g_CTSpawns;
    } else {
      spawnList = g_TSpawns;
    }

    char arg[32];
    int spawnIndex = -1;
    if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
      spawnIndex = StringToInt(arg) - 1;  // One-indexed for users.
    } else {
      spawnIndex = FindFurthestSpawnIndex(client, spawnList);
    }

    if (spawnIndex < 0 || spawnIndex >= spawnList.Length) {
      PM_Message(client, "Spawn number out of range. (%d max)", spawnList.Length);
      return Plugin_Handled;
    }

    int ent = spawnList.Get(spawnIndex);
    TeleportToSpawnEnt(client, ent);
    SetEntityMoveType(client, MOVETYPE_WALK);
    PM_Message(client, "Moved to spawn %d (of %d).", spawnIndex + 1, spawnList.Length);
  }
  return Plugin_Handled;
}

static void FindMapSpawnsForTeam(ArrayList list, const char[] spawnClassName) {
  list.Clear();
  int minPriority = -1;

  // First pass over spawns to find minPriority.
  int ent = -1;
  while ((ent = FindEntityByClassname(ent, spawnClassName)) != -1) {
    int priority = GetEntProp(ent, Prop_Data, "m_iPriority");
    if (priority < minPriority || minPriority == -1) {
      minPriority = priority;
    }
  }

  // Second pass only adds spawns with the lowest priority to the list.
  ent = -1;
  while ((ent = FindEntityByClassname(ent, spawnClassName)) != -1) {
    int priority = GetEntProp(ent, Prop_Data, "m_iPriority");
    int enabled = GetEntProp(ent, Prop_Data, "m_bEnabled");
    if (enabled && priority == minPriority) {
      list.Push(ent);
    }
  }
}

public void TeleportToSpawnEnt(int client, int ent) {
  float origin[3];
  float angles[3];
  float velocity[3];
  GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);
  GetEntPropVector(ent, Prop_Data, "m_angRotation", angles);
  TeleportEntity(client, origin, angles, velocity);
}

public int FindNearestSpawnIndex(int client, ArrayList list) {
  float clientOrigin[3];
  GetClientAbsOrigin(client, clientOrigin);

  float origin[3];
  int closestIndex = -1;
  float minDist = 0.0;

  for (int i = 0; i < list.Length; i++) {
    int ent = list.Get(i);
    GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);
    float dist = GetVectorDistance(clientOrigin, origin);
    if (closestIndex < 0 || dist < minDist) {
      minDist = dist;
      closestIndex = i;
    }
  }

  return closestIndex;
}

public int FindFurthestSpawnIndex(int client, ArrayList list) {
  float clientOrigin[3];
  GetClientAbsOrigin(client, clientOrigin);

  float origin[3];
  int farthestIndex = -1;
  float maxDist = 0.0;

  for (int i = 0; i < list.Length; i++) {
    int ent = list.Get(i);
    GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);
    float dist = GetVectorDistance(clientOrigin, origin);
    if (farthestIndex < 0 || dist > maxDist) {
      maxDist = dist;
      farthestIndex = i;
    }
  }

  return farthestIndex;
}

#define TEAM_STRING(%1) (%1 == CS_TEAM_CT ? "ct" : "t")

public bool DoesNamedSpawnExist(int team, const char[] name) {
  bool found = false;
  if (g_NamedSpawnsKv.JumpToKey(TEAM_STRING(team))) {
    if (g_NamedSpawnsKv.JumpToKey(name)) {
      found = true;
      g_NamedSpawnsKv.GoBack();
    }
    g_NamedSpawnsKv.GoBack();
  }

  return found;
}

public void SaveNamedSpawn(int client, int team, const char[] name) {
  ArrayList list = (team == CS_TEAM_CT) ? g_CTSpawns : g_TSpawns;
  int index = FindNearestSpawnIndex(client, list);
  if (g_NamedSpawnsKv.JumpToKey(TEAM_STRING(team), true)) {
    g_NamedSpawnsKv.SetNum(name, index);
    g_NamedSpawnsKv.GoBack();
  }
}

public void TeleportToNamedSpawn(int client, int team, const char[] name) {
  ArrayList list = (team == CS_TEAM_CT) ? g_CTSpawns : g_TSpawns;
  int index = -1;
  if (g_NamedSpawnsKv.JumpToKey(TEAM_STRING(team))) {
    index = g_NamedSpawnsKv.GetNum(name, -1);
    g_NamedSpawnsKv.GoBack();
  }

  if (index >= 0) {
    TeleportToSpawnEnt(client, list.Get(index));
  }
}
