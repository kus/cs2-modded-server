#define DEFAULT_KEY_LENGTH 64

stock void GiveMainReplaysMenu(int client, int pos = 0) {
  Menu menu = new Menu(ReplaysMenuHandler);
  menu.SetTitle("Replay list");
  menu.AddItem("add_new", "Add new replay");
  menu.AddItem("exit", "Exit replay mode");
  DeleteReplayIfEmpty(client);

  g_ReplayId[client] = "";
  g_CurrentEditingRole[client] = -1;

  char id[REPLAY_ID_LENGTH];
  char name[REPLAY_NAME_LENGTH];
  if (g_ReplaysKv.GotoFirstSubKey()) {
    do {
      g_ReplaysKv.GetSectionName(id, sizeof(id));
      g_ReplaysKv.GetString("name", name, sizeof(name));
      char display[128];
      Format(display, sizeof(display), "%s (id %s)", name, id);
      menu.AddItem(id, display);
    } while (g_ReplaysKv.GotoNextKey());
    g_ReplaysKv.GoBack();
  }

  menu.DisplayAt(client, pos, MENU_TIME_FOREVER);
}

public int ReplaysMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    char buffer[REPLAY_ID_LENGTH + 1];
    menu.GetItem(param2, buffer, sizeof(buffer));

    if (StrEqual(buffer, "add_new")) {
      IntToString(GetNextReplayId(), g_ReplayId[client], REPLAY_NAME_LENGTH);
      SetReplayName(g_ReplayId[client], DEFAULT_REPLAY_NAME);
      PM_Message(client, "Started new replay with id %s", g_ReplayId[client]);

    } else if (StrContains(buffer, "exit") == 0) {
      ExitReplayMode();

    } else {
      strcopy(g_ReplayId[client], REPLAY_NAME_LENGTH, buffer);
    }

    GiveReplayEditorMenu(client);
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

public void MaybeWriteNewReplayData() {
  if (g_UpdatedReplayKv) {
    g_ReplaysKv.Rewind();
    BackupFiles("replays");

    char map[PLATFORM_MAX_PATH];
    GetCleanMapName(map, sizeof(map));
    char replayFile[PLATFORM_MAX_PATH + 1];
    BuildPath(Path_SM, replayFile, sizeof(replayFile), "data/practicemode/replays/%s.cfg", map);
    DeleteFile(replayFile);
    if (!g_ReplaysKv.ExportToFile(replayFile)) {
      LogError("Failed to write replays to %s", replayFile);
    }

    g_UpdatedReplayKv = false;
  }
}

public void DeleteReplayIfEmpty(int client) {
  bool empty = true;

  for (int i = 0; i < MAX_REPLAY_CLIENTS; i++) {
    if (HasRoleRecorded(g_ReplayId[client], i)) {
      empty = false;
    }
  }

  char name[REPLAY_NAME_LENGTH];
  GetReplayName(g_ReplayId[client], name, sizeof(name));
  if (!StrEqual(name, DEFAULT_REPLAY_NAME)) {
    empty = false;
  }

  // Okay, let's delete this replay since it's useless.
  if (empty) {
    DeleteReplay(g_ReplayId[client]);
  }
}

public int GetNextReplayId() {
  int largest = -1;
  char id[REPLAY_ID_LENGTH];
  if (g_ReplaysKv.GotoFirstSubKey()) {
    do {
      g_ReplaysKv.GetSectionName(id, sizeof(id));
      int idvalue = StringToInt(id);
      if (idvalue > largest) {
        largest = idvalue;
      }
    } while (g_ReplaysKv.GotoNextKey());
    g_ReplaysKv.GoBack();
  }
  return largest + 1;
}

public void GetRoleKeyString(int role, char buf[DEFAULT_KEY_LENGTH]) {
  Format(buf, sizeof(buf), "role%d", role + 1);
}

public void DeleteReplay(const char[] id) {
  if (g_ReplaysKv.JumpToKey(id)) {
    g_UpdatedReplayKv = true;
    g_ReplaysKv.DeleteThis();
    g_ReplaysKv.Rewind();
  }
}

public void DeleteReplayRole(const char[] id, int role) {
  if (g_ReplaysKv.JumpToKey(id)) {
    char roleString[DEFAULT_KEY_LENGTH];
    GetRoleKeyString(role, roleString);
    if (g_ReplaysKv.JumpToKey(roleString)) {
      g_UpdatedReplayKv = true;
      g_ReplaysKv.DeleteThis();
    }
  }

  g_ReplaysKv.Rewind();
}

public bool ReplayExists(const char[] id) {
  if (StrEqual(id, "")) {
    return false;
  }

  bool ret = false;
  if (g_ReplaysKv.JumpToKey(id)) {
    ret = true;
    g_ReplaysKv.GoBack();
  }
  return ret;
}

public void GetReplayName(const char[] id, char[] buffer, int length) {
  if (g_ReplaysKv.JumpToKey(id)) {
    g_ReplaysKv.GetString("name", buffer, length);
    g_ReplaysKv.GoBack();
  }
}

public void SetReplayName(const char[] id, const char[] newName) {
  g_UpdatedReplayKv = true;
  if (g_ReplaysKv.JumpToKey(id, true)) {
    g_ReplaysKv.SetString("name", newName);
    g_ReplaysKv.GoBack();
  }
  MaybeWriteNewReplayData();
}

public bool HasRoleRecorded(const char[] id, int index) {
  char buf[PLATFORM_MAX_PATH];
  return GetRoleFile(id, index, buf, sizeof(buf));
}

static bool GetRoleKVString(const char[] id, int index, const char[] key, char[] buffer, int len) {
  bool ret = false;
  if (g_ReplaysKv.JumpToKey(id)) {
    char role[DEFAULT_KEY_LENGTH];
    GetRoleKeyString(index, role);
    if (g_ReplaysKv.JumpToKey(role)) {
      g_ReplaysKv.GetString(key, buffer, len);
      ret = !StrEqual(buffer, "");
      g_ReplaysKv.GoBack();
    }
    g_ReplaysKv.GoBack();
  }
  return ret;
}

static bool SetRoleKVString(const char[] id, int index, const char[] key, const char[] value) {
  g_UpdatedReplayKv = true;
  bool ret = false;
  if (g_ReplaysKv.JumpToKey(id, true)) {
    char role[DEFAULT_KEY_LENGTH];
    GetRoleKeyString(index, role);
    if (g_ReplaysKv.JumpToKey(role, true)) {
      ret = true;
      g_ReplaysKv.SetString(key, value);
      g_ReplaysKv.GoBack();
    }
    g_ReplaysKv.GoBack();
  }
  return ret;
}

public bool GetRoleFile(const char[] id, int index, char[] buffer, int len) {
  return GetRoleKVString(id, index, "file", buffer, len);
}

public bool SetRoleFile(const char[] id, int index, const char[] filepath) {
  return SetRoleKVString(id, index, "file", filepath);
}

public int GetRoleTeam(const char[] id, int index) {
  char buffer[64];
  if (GetRoleKVString(id, index, "team", buffer, sizeof(buffer))) {
    return StrEqual(buffer, "CT", false) ? CS_TEAM_CT : CS_TEAM_T;
  }
  return CS_TEAM_T;
}

public bool SetRoleTeam(const char[] id, int index, int team) {
  char teamString[64] = "T";
  if (team == CS_TEAM_CT) {
    teamString = "CT";
  }
  return SetRoleKVString(id, index, "team", teamString);
}

public bool GetRoleName(const char[] id, int index, char[] buffer, int len) {
  return GetRoleKVString(id, index, "name", buffer, len);
}

public bool SetRoleName(const char[] id, int index, const char[] name) {
  return SetRoleKVString(id, index, "name", name);
}

public void SetRoleNades(const char[] id, int index, int client) {
  g_UpdatedReplayKv = true;
  ArrayList list = g_NadeReplayData[client];
  if (g_ReplaysKv.JumpToKey(id, true)) {
    char role[DEFAULT_KEY_LENGTH];
    GetRoleKeyString(index, role);
    if (g_ReplaysKv.JumpToKey(role, true) && g_ReplaysKv.JumpToKey("nades", true)) {
      for (int i = 0; i < list.Length; i++) {
        char key[DEFAULT_KEY_LENGTH];
        IntToString(i, key, sizeof(key));
        g_ReplaysKv.JumpToKey(key, true);

        GrenadeType type;
        float delay;
        float origin[3];
        float angles[3];
        float grenadeOrigin[3];
        float grenadeVelocity[3];
        GetReplayNade(client, i, type, delay, origin, angles, grenadeOrigin, grenadeVelocity);

        char typeString[DEFAULT_KEY_LENGTH];
        GrenadeTypeString(type, typeString, sizeof(typeString));
        g_ReplaysKv.SetVector("origin", origin);
        g_ReplaysKv.SetVector("angles", angles);
        g_ReplaysKv.SetVector("grenadeOrigin", grenadeOrigin);
        g_ReplaysKv.SetVector("grenadeVelocity", grenadeVelocity);
        g_ReplaysKv.SetString("grenadeType", typeString);
        g_ReplaysKv.SetFloat("delay", delay);
        g_ReplaysKv.GoBack();
      }
    }
  }
  g_ReplaysKv.Rewind();
}

public void GetRoleNades(const char[] id, int index, int client) {
  g_NadeReplayData[client].Clear();
  if (g_ReplaysKv.JumpToKey(id, true)) {
    char role[DEFAULT_KEY_LENGTH];
    GetRoleKeyString(index, role);
    if (g_ReplaysKv.JumpToKey(role, true) && g_ReplaysKv.JumpToKey("nades", true)) {
      if (g_ReplaysKv.GotoFirstSubKey()) {
        do {
          GrenadeType type;
          char typeString[DEFAULT_KEY_LENGTH];
          float delay;
          float origin[3];
          float angles[3];
          float grenadeOrigin[3];
          float grenadeVelocity[3];

          char nadeId[GRENADE_ID_LENGTH];
          g_ReplaysKv.GetString("id", nadeId, sizeof(nadeId));
          if (!StrEqual(nadeId, "")) {
            // TODO: get the nade data form the grenade kv.
            // one day...
          }

          g_ReplaysKv.GetVector("origin", origin);
          g_ReplaysKv.GetVector("angles", angles);
          g_ReplaysKv.GetVector("grenadeOrigin", grenadeOrigin);
          g_ReplaysKv.GetVector("grenadeVelocity", grenadeVelocity);
          g_ReplaysKv.GetString("grenadeType", typeString, sizeof(typeString));
          type = GrenadeTypeFromString(typeString);
          delay = g_ReplaysKv.GetFloat("delay");
          AddReplayNade(client, type, delay, origin, angles, grenadeOrigin, grenadeVelocity);
        } while (g_ReplaysKv.GotoNextKey());
      }
    }
  }
  g_ReplaysKv.Rewind();
}

public void GarbageCollectReplays() {
  if (!g_BotMimicLoaded) {
    return;
  }

  ArrayList replaysInUse = new ArrayList(PLATFORM_MAX_PATH + 1);

  // Get all replays currently in use.
  AddReplayFilesToList(g_ReplaysKv, replaysInUse);

  // Get all the replays still in a backup file.
  char map[PLATFORM_MAX_PATH + 1];
  GetCleanMapName(map, sizeof(map));
  for (int version = 1; version <= kMaxBackupsPerMap; version++) {
    char path[PLATFORM_MAX_PATH + 1];
    BuildPath(Path_SM, path, sizeof(path), "data/practicemode/replays/backups/%s.%d.cfg", map,
              version);
    KeyValues kv = new KeyValues("Replays");
    if (kv.ImportFromFile(path)) {
      AddReplayFilesToList(kv, replaysInUse);
    }
    delete kv;
  }

  char path[PLATFORM_MAX_PATH + 1];
  ArrayList loadedRecords = BotMimic_GetLoadedRecordList();  // Don't close this.
  for (int i = 0; i < loadedRecords.Length; i++) {
    loadedRecords.GetString(i, path, sizeof(path));
    if (FindStringInList(replaysInUse, sizeof(path), path) == -1) {
      BotMimic_DeleteRecord(path);
    }
  }

  delete replaysInUse;
}

public void AddReplayFilesToList(KeyValues kv, ArrayList list) {
  if (kv.GotoFirstSubKey()) {
    do {
      for (int i = 0; i < MAX_REPLAY_CLIENTS; i++) {
        char role[64];
        Format(role, sizeof(role), "role%d", i + 1);
        if (kv.JumpToKey(role)) {
          char buffer[PLATFORM_MAX_PATH + 1];
          kv.GetString("file", buffer, sizeof(buffer));
          list.PushString(buffer);
          kv.GoBack();
        }
      }
    } while (kv.GotoNextKey());
    kv.GoBack();
  }
}

public void CopyReplay(const char[] originalID, const char[] newID) {
  KeyValues tmp = new KeyValues("tmp");
  g_ReplaysKv.JumpToKey(originalID, true);
  tmp.Import(g_ReplaysKv);
  g_ReplaysKv.GoBack();

  g_ReplaysKv.JumpToKey(newID, true);
  KvCopySubkeys(tmp, g_ReplaysKv);
  g_ReplaysKv.Rewind();
  delete tmp;
}
