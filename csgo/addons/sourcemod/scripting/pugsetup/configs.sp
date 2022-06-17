#define CHAT_ALIAS_FILE "configs/pugsetup/chataliases.cfg"
#define SETUP_OPTIONS_FILE "configs/pugsetup/setupoptions.cfg"
#define PERMISSIONS_FILE "configs/pugsetup/permissions.cfg"

/**
 * Update maplist info and fetch any workshop info needed.
 */
public bool UsingWorkshopCollection() {
  char maplist[PLATFORM_MAX_PATH];
  g_MapListCvar.GetString(maplist, sizeof(maplist));
  int collectionID = StringToInt(maplist);
  return collectionID != 0;
}

public void FillMapList(ConVar cvar, ArrayList list) {
  list.Clear();

  char maplist[PLATFORM_MAX_PATH];
  cvar.GetString(maplist, sizeof(maplist));

  int collectionID = StringToInt(maplist);
  if (collectionID == 0) {
    // it's a regular map list
    GetMapList(maplist, list);
  } else {
    // it's a workshop collection id, setup the workshop cache
    UpdateWorkshopCache(maplist, list);
  }

  if (list.Length == 0) {
    AddBackupMaps(list);
  }
}

/**
 * Dealing with the chat alias config file.
 */
stock void ReadChatConfig() {
  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), CHAT_ALIAS_FILE);
  KeyValues kv = new KeyValues("ChatAliases");
  if (kv.ImportFromFile(configFile) && kv.GotoFirstSubKey(false)) {
    do {
      char alias[ALIAS_LENGTH];
      char command[COMMAND_LENGTH];
      kv.GetSectionName(alias, sizeof(alias));
      kv.GetString(NULL_STRING, command, sizeof(command));
      PugSetup_AddChatAlias(alias, command);
    } while (kv.GotoNextKey(false));
  }
  delete kv;
}

stock bool PugSetup_AddChatAliasToFile(const char[] alias, const char[] command) {
  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), CHAT_ALIAS_FILE);
  KeyValues kv = new KeyValues("ChatAliases");
  kv.ImportFromFile(configFile);
  kv.SetString(alias, command);
  kv.Rewind();
  bool success = kv.ExportToFile(configFile);
  delete kv;
  return success;
}

stock bool RemoveChatAliasFromFile(const char[] alias) {
  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), CHAT_ALIAS_FILE);
  KeyValues kv = new KeyValues("ChatAliases");
  kv.ImportFromFile(configFile);
  kv.DeleteKey(alias);
  kv.Rewind();
  bool success = kv.ExportToFile(configFile);
  delete kv;
  return success;
}

/**
 * Dealing with the setup options config file.
 */
static char g_SetupKeys[][] = {"maptype",  "teamtype", "autolive",  "kniferound",
                               "teamsize", "record",   "mapchange", "playout"};
static char g_SetupCoercions[][][] = {
    {"map", "maptype"},         {"teams", "teamtype"},   {"team", "teamtype"},
    {"knife", "kniferound"},    {"autolo3", "autolive"}, {"demo", "record"},
    {"changemap", "mapchange"}, {"aim", "aimwarmup"},    {"aimmap", "aimwarmup"},
};

stock bool CheckEnabledFromString(const char[] value) {
  char strs[][] = {"true", "enabled", "1", "yes", "on", "y"};
  for (int i = 0; i < sizeof(strs); i++) {
    if (StrEqual(value, strs[i], false)) {
      return true;
    }
  }
  return false;
}

stock bool CheckSetupOptionValidity(int client, char[] setting, const char[] value,
                                    bool setDefault = true, bool setDisplay = false) {
  for (int i = 0; i < sizeof(g_SetupCoercions); i++) {
    if (StrEqual(setting, g_SetupCoercions[i][0], false)) {
      int len = strlen(setting);
      strcopy(setting, len, g_SetupCoercions[i][1]);
      break;
    }
  }

  if (StrEqual(setting, "maptype", false)) {
    if (setDefault && !StrEqual(value, "vote") && !StrEqual(value, "veto") &&
        !StrEqual(value, "current")) {
      PugSetup_Message(
          client, "%s is not a valid option for setting %s, valid options are vote, veto, current",
          value, setting);
      return false;
    } else if (setDefault) {
      MapTypeFromString(value, g_MapType);
    }

    if (setDisplay)
      g_DisplayMapType = CheckEnabledFromString(value);
    return true;

  } else if (StrEqual(setting, "teamtype", false)) {
    if (setDefault && !StrEqual(value, "captains") && !StrEqual(value, "manual") &&
        !StrEqual(value, "random")) {
      PugSetup_Message(
          client,
          "%s is not a valid option for setting %s, valid options are captains, manual, random",
          value, setting);
      return false;
    } else if (setDefault) {
      TeamTypeFromString(value, g_TeamType);
    }

    if (setDisplay)
      g_DisplayTeamType = CheckEnabledFromString(value);
    return true;

  } else if (StrEqual(setting, "autolive", false)) {
    if (setDisplay)
      g_DisplayAutoLive = CheckEnabledFromString(value);
    if (setDefault)
      g_AutoLive = CheckEnabledFromString(value);

    return true;

  } else if (StrEqual(setting, "kniferound", false)) {
    if (setDisplay)
      g_DisplayKnifeRound = CheckEnabledFromString(value);
    if (setDefault)
      g_DoKnifeRound = CheckEnabledFromString(value);

    return true;

  } else if (StrEqual(setting, "teamsize", false)) {
    int teamsize = StringToInt(value);
    bool valid = teamsize >= 1;
    if (setDefault && !valid) {
      PugSetup_Message(client, "Teamsize %s is not valid", teamsize);
      return false;
    }

    if (setDisplay)
      g_DisplayTeamSize = CheckEnabledFromString(value);
    if (setDefault)
      g_PlayersPerTeam = teamsize;
    return true;

  } else if (StrEqual(setting, "record", false)) {
    if (setDisplay)
      g_DisplayRecordDemo = CheckEnabledFromString(value);
    if (setDefault)
      g_RecordGameOption = CheckEnabledFromString(value);
    return true;

  } else if (StrEqual(setting, "mapchange", false)) {
    if (setDisplay)
      g_DisplayMapChange = CheckEnabledFromString(value);
    return true;

  } else if (StrEqual(setting, "aimwarmup", false)) {
    if (setDisplay) {
      g_DisplayAimWarmup = CheckEnabledFromString(value);
    }
    return true;

  } else if (StrEqual(setting, "playout", false)) {
    if (setDisplay) {
      g_DoPlayout = CheckEnabledFromString(value);
    }
    return true;

  } else {
    char allSettings[128] = "\0";
    for (int i = 0; i < sizeof(g_SetupKeys); i++) {
      StrCat(allSettings, sizeof(allSettings), g_SetupKeys[i]);
      if (i < sizeof(g_SetupKeys) - 1)
        StrCat(allSettings, sizeof(allSettings), ", ");
    }

    PugSetup_Message(client, "%s is not a valid option", setting);
    PugSetup_Message(client, "Valid options are: %s", allSettings);
    return false;
  }
}

stock void ReadSetupOptions() {
  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), SETUP_OPTIONS_FILE);
  KeyValues kv = new KeyValues("SetupOptions");
  if (kv.ImportFromFile(configFile) && kv.GotoFirstSubKey()) {
    do {
      char setting[128];
      char buffer[128];
      kv.GetSectionName(setting, sizeof(setting));
      bool display = !!kv.GetNum("display_setting", 1);

      if (StrEqual(setting, "maptype", false)) {
        kv.GetString("default", buffer, sizeof(buffer), "vote");
        MapTypeFromString(buffer, g_MapType, true);
        g_DisplayMapType = display;

      } else if (StrEqual(setting, "teamtype", false)) {
        kv.GetString("default", buffer, sizeof(buffer), "captains");
        TeamTypeFromString(buffer, g_TeamType, true);
        g_DisplayTeamType = display;

      } else if (StrEqual(setting, "autolive", false)) {
        kv.GetString("default", buffer, sizeof(buffer), "0");
        g_AutoLive = CheckEnabledFromString(buffer);
        g_DisplayAutoLive = display;

      } else if (StrEqual(setting, "kniferound", false)) {
        kv.GetString("default", buffer, sizeof(buffer), "0");
        g_DoKnifeRound = CheckEnabledFromString(buffer);
        g_DisplayKnifeRound = display;

      } else if (StrEqual(setting, "teamsize", false)) {
        g_PlayersPerTeam = kv.GetNum("default", 5);
        g_DisplayTeamSize = display;

      } else if (StrEqual(setting, "record", false)) {
        kv.GetString("default", buffer, sizeof(buffer), "0");
        g_RecordGameOption = CheckEnabledFromString(buffer);
        g_DisplayRecordDemo = display;

      } else if (StrEqual(setting, "aimwarmup", false)) {
        kv.GetString("default", buffer, sizeof(buffer), "0");
        g_DoAimWarmup = CheckEnabledFromString(buffer);
        g_DisplayAimWarmup = display;

      } else if (StrEqual(setting, "mapchange", false)) {
        g_DisplayMapChange = display;

      } else if (StrEqual(setting, "playout", false)) {
        kv.GetString("default", buffer, sizeof(buffer), "0");
        g_DoPlayout = CheckEnabledFromString(buffer);
        g_DisplayPlayout = display;

      } else {
        LogError("Unknown section name in %s: \"%s\"", configFile, setting);
      }

    } while (kv.GotoNextKey());
  }
  delete kv;
}

stock bool SetDefaultInFile(const char[] setting, const char[] newValue) {
  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), SETUP_OPTIONS_FILE);
  KeyValues kv = new KeyValues("SetupOptions");
  kv.ImportFromFile(configFile);
  kv.JumpToKey(setting, true);
  kv.SetString("default", newValue);
  kv.Rewind();
  bool success = kv.ExportToFile(configFile);
  delete kv;
  return success;
}

stock bool SetDisplayInFile(const char[] setting, bool display) {
  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), SETUP_OPTIONS_FILE);
  KeyValues kv = new KeyValues("SetupOptions");
  kv.ImportFromFile(configFile);
  kv.JumpToKey(setting, true);
  kv.SetNum("display_setting", display);
  kv.Rewind();
  bool success = kv.ExportToFile(configFile);
  delete kv;
  return success;
}

/**
 * Dealing with (optionally set) command permissions.
 */
stock void ReadPermissions() {
  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), PERMISSIONS_FILE);
  KeyValues kv = new KeyValues("Permissions");
  kv.ImportFromFile(configFile);

  if (kv.ImportFromFile(configFile) && kv.GotoFirstSubKey(false)) {
    do {
      char command[128];
      char permission[128];
      kv.GetSectionName(command, sizeof(command));
      kv.GetString(NULL_STRING, permission, sizeof(permission));
      if (PugSetup_IsValidCommand(command)) {
        Permission p = Permission_All;
        if (PermissionFromString(permission, p, true)) {
          PugSetup_SetPermissions(command, p);
        }
      } else {
        LogError("Can't assign permissions to invalid command: %s", command);
      }
    } while (kv.GotoNextKey(false));
  }

  delete kv;
}
