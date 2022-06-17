stock void ChangeMap(ArrayList mapList, int mapIndex = -1, float delay = 3.0,
                     bool toFinalMap = true) {
  char map[PLATFORM_MAX_PATH];

  if (mapIndex == -1) {
    mapIndex = GetArrayRandomIndex(mapList);
  }

  // print the formatted name
  FormatMapName(mapList, mapIndex, map, sizeof(map));
  PugSetup_MessageToAll("%t", "ChangeMapMessage", map);

  // pass the "true" name to a timer to changelevel
  mapList.GetString(mapIndex, map, sizeof(map));
  DataPack pack = CreateDataPack();
  pack.WriteString(map);
  pack.WriteCell(toFinalMap);
  CreateTimer(delay, Timer_DelayedChangeMap, pack);
}

public Action Timer_DelayedChangeMap(Handle timer, Handle data) {
  char map[PLATFORM_MAX_PATH];
  DataPack pack = view_as<DataPack>(data);
  pack.Reset();
  pack.ReadString(map, sizeof(map));
  bool toFinalMap = pack.ReadCell();
  delete pack;

  if (toFinalMap) {
    g_OnDecidedMap = true;
  }

  g_SwitchingMaps = true;

  if (IsMapValid(map)) {
    ServerCommand("changelevel %s", map);
  } else if (StrContains(map, "workshop") == 0) {
    ServerCommand("host_workshop_map %d", GetMapIdFromString(map));
  }

  return Plugin_Handled;
}

public void AddBackupMaps(ArrayList maplist) {
  char backupMaps[][] = {
      "de_ancient", "de_cbble", "de_dust2", "de_inferno", "de_mirage", "de_nuke", "de_overpass", "de_train", "de_vertigo",
  };

  for (int i = 0; i < sizeof(backupMaps); i++)
    AddMap(backupMaps[i], maplist);
}

public bool GetMapList(const char[] fileName, ArrayList mapList) {
  mapList.Clear();
  char mapFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, mapFile, sizeof(mapFile), "configs/pugsetup/%s", fileName);

  if (!FileExists(mapFile)) {
    LogError("Missing map file: %s", mapFile);
    return false;
  } else {
    File file = OpenFile(mapFile, "r");
    if (file != null) {
      char mapName[PLATFORM_MAX_PATH];
      while (!file.EndOfFile() && file.ReadLine(mapName, sizeof(mapName))) {
        TrimString(mapName);
        AddMap(mapName, mapList);
      }
      delete file;
    } else {
      LogError("Failed to open maplist for reading: %s", mapFile);
      return false;
    }
  }

  return true;
}

public bool WriteMapList(const char[] fileName, ArrayList mapList) {
  char mapFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, mapFile, sizeof(mapFile), "configs/pugsetup/%s", fileName);

  if (!FileExists(mapFile)) {
    LogError("Missing map file: %s", mapFile);
  } else {
    File file = OpenFile(mapFile, "w");
    if (file != null) {
      char mapName[PLATFORM_MAX_PATH];
      for (int i = 0; i < mapList.Length; i++) {
        mapList.GetString(i, mapName, sizeof(mapName));
        file.WriteLine(mapName);
      }
      delete file;
      return true;
    } else {
      LogError("Failed to open maplist for reading: %s", mapFile);
      return false;
    }
  }

  return false;
}

public bool AddToMapList(const char[] mapName) {
  if (UsingWorkshopCollection())
    return false;

  char maplist[PLATFORM_MAX_PATH];
  g_MapListCvar.GetString(maplist, sizeof(maplist));

  char mapFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, mapFile, sizeof(mapFile), "configs/pugsetup/%s", maplist);

  File file = OpenFile(mapFile, "a");
  if (file != null) {
    file.WriteLine(mapName);
    delete file;
    return true;
  } else {
    LogError("Failed to open maplist for writing: %s", mapFile);
  }
  return false;
}

public bool RemoveMapFromList(const char[] mapName) {
  if (UsingWorkshopCollection())
    return false;

  char maplist[PLATFORM_MAX_PATH];
  g_MapListCvar.GetString(maplist, sizeof(maplist));

  ArrayList tmpList = new ArrayList(PLATFORM_MAX_PATH);
  GetMapList(maplist, tmpList);

  if (!RemoveMap(mapName, tmpList))
    return false;

  if (!WriteMapList(maplist, tmpList))
    return false;

  return true;
}

public bool AddMap(const char[] mapName, ArrayList mapList) {
  bool isComment = strlen(mapName) >= 2 && mapName[0] == '/' && mapName[1] == '/';
  if (strlen(mapName) <= 2 || isComment) {
    return false;
  }

  // only add valid maps and non-duplicate maps
  if ((IsMapValid(mapName) || StrContains(mapName, "workshop") == 0) &&
      mapList.FindString(mapName) == -1) {
    mapList.PushString(mapName);
    return true;
  }

  return false;
}

public bool RemoveMap(const char[] mapName, ArrayList mapList) {
  int index = mapList.FindString(mapName);

  if (index == -1) {
    return false;
  } else {
    mapList.Erase(index);
    return true;
  }
}

public void FormatMapName(ArrayList mapList, int mapIndex, char[] buffer, int len) {
  char map[PLATFORM_MAX_PATH];
  mapList.GetString(mapIndex, map, sizeof(map));

  // explode map by '/' so we can remove any directory prefixes (e.g. workshop stuff)
  char buffers[4][PLATFORM_MAX_PATH];
  int numSplits = ExplodeString(map, "/", buffers, sizeof(buffers), PLATFORM_MAX_PATH);
  int mapStringIndex = (numSplits > 0) ? (numSplits - 1) : (0);
  strcopy(map, len, buffers[mapStringIndex]);

  // not do it with backslashes too
  numSplits = ExplodeString(map, "\\", buffers, sizeof(buffers), PLATFORM_MAX_PATH);
  mapStringIndex = (numSplits > 0) ? (numSplits - 1) : (0);
  strcopy(buffer, len, buffers[mapStringIndex]);
}

stock void AddMapIndexToMenu(Menu menu, ArrayList mapList, int mapIndex, bool disabled = false) {
  char mapName[128];
  FormatMapName(mapList, mapIndex, mapName, sizeof(mapName));
  if (disabled)
    AddMenuIntDisabled(menu, mapIndex, mapName);
  else
    AddMenuInt(menu, mapIndex, mapName);
}

public bool OnAimMap() {
  char currentMap[PLATFORM_MAX_PATH];
  GetCurrentMap(currentMap, sizeof(currentMap));

  // if the map starts with 'aim' or exists in the aim map list
  bool ret = StrContains(currentMap, "aim") == 0 || g_AimMapList.FindString(currentMap) >= 0;
  return ret;
}

public void ChangeToAimMap() {
  if (g_AimMapList.Length > 0) {
    ChangeMap(g_AimMapList, GetArrayRandomIndex(g_AimMapList), 5.0, false);
  }
}

public int GetMapIdFromString(const char[] map) {
  char buffers[4][PLATFORM_MAX_PATH];
  ExplodeString(map, "/", buffers, sizeof(buffers), PLATFORM_MAX_PATH);
  return StringToInt(buffers[1]);
}

public bool IsStockMap(const char[] map) {
  static StringMap stockMaps;
  if (stockMaps == null) {
    stockMaps = new StringMap();
    stockMaps.SetValue("cs_assault", 0);
    stockMaps.SetValue("cs_italy", 0);
    stockMaps.SetValue("cs_militia", 0);
    stockMaps.SetValue("cs_office", 0);
    stockMaps.SetValue("de_ancient", 0);
    stockMaps.SetValue("de_cbble", 0);
    stockMaps.SetValue("de_dust", 0);
    stockMaps.SetValue("de_dust2", 0);
    stockMaps.SetValue("de_inferno", 0);
    stockMaps.SetValue("de_mirage", 0);
    stockMaps.SetValue("de_canals", 0);
    stockMaps.SetValue("de_nuke", 0);
    stockMaps.SetValue("de_overpass", 0);
    stockMaps.SetValue("de_train", 0);
    stockMaps.SetValue("de_vertigo", 0);
  }

  int dummy;
  return stockMaps.GetValue(map, dummy);
}
