public Action Command_DebugInfo(int client, int args) {
  char path[PLATFORM_MAX_PATH + 1];

  if (args == 0 || !GetCmdArg(1, path, sizeof(path))) {
    BuildPath(Path_SM, path, sizeof(path), "logs/practicemode_debuginfo.txt");
  }

  File f = OpenFile(path, "w");
  if (f == null) {
    LogError("Failed to open practicemode_debuginfo.txt for writing");
    return Plugin_Handled;
  }

  AddVersionInfo(f);
  AddSpacing(f);
  AddInterestingCvars(f);
  AddSpacing(f);
  AddLogLines(f, "errors_", 50);
  AddSpacing(f);
  AddPluginList(f);

  delete f;

  ReplyToCommand(client, "Wrote debug data to %s", path);
  return Plugin_Handled;
}

// Helper functions.

static void AddSpacing(File f) {
  for (int i = 0; i < 3; i++) {
    f.WriteLine("");
  }
}

static bool GetCvarValue(const char[] name, char[] value, int len) {
  ConVar cvar = FindConVar(name);
  if (cvar == null) {
    Format(value, len, "NULL CVAR");
    return false;
  } else {
    cvar.GetString(value, len);
    return true;
  }
}

static void WriteCvarString(File f, const char[] cvar) {
  char buffer[128];
  GetCvarValue(cvar, buffer, sizeof(buffer));
  f.WriteLine("%s = %s", cvar, buffer);
}

// Actual debug info.

static void AddVersionInfo(File f) {
  char time[128];
  FormatTime(time, sizeof(time), NULL_STRING, GetTime());
  f.WriteLine("Time: %s", time);
  f.WriteLine("Plugin version: %s", PLUGIN_VERSION);
  WriteCvarString(f, "sourcemod_version");
  WriteCvarString(f, "metamod_version");
  WriteCvarString(f, "sm_csutils_version");
  WriteCvarString(f, "sm_botmimic_version");
  WriteCvarString(f, "sm_pugsetup_version");
}

static void AddInterestingCvars(File f) {
  f.WriteLine("Interesting cvars:");
  WriteCvarString(f, "mp_freezetime");
  WriteCvarString(f, "mp_match_end_restart");
  WriteCvarString(f, "mp_maxrounds");
  WriteCvarString(f, "mp_round_restart_delay");
  WriteCvarString(f, "mp_warmup_pausetimer");
  WriteCvarString(f, "mp_warmuptime_all_players_connected");
  WriteCvarString(f, "sm_allow_noclip");
  WriteCvarString(f, "sm_practicemode_autostart");
  WriteCvarString(f, "sm_practicemode_can_be_started");
  WriteCvarString(f, "sv_cheats");
  WriteCvarString(f, "sv_coaching_enabled");
}

static void AddLogLines(File f, const char[] pattern, int maxLines) {
  char logsDir[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, logsDir, sizeof(logsDir), "logs");
  DirectoryListing dir = OpenDirectory(logsDir);
  if (dir == null) {
    f.WriteLine("Can't open logs dir at %s", logsDir);
    return;
  }

  char filename[PLATFORM_MAX_PATH];
  FileType type;
  ArrayList logFilenames = new ArrayList(sizeof(filename));
  while (dir.GetNext(filename, sizeof(filename), type)) {
    if (type == FileType_File && StrContains(filename, pattern) >= 0) {
      char fullPath[PLATFORM_MAX_PATH];
      Format(fullPath, sizeof(fullPath), "%s/%s", logsDir, filename);
      logFilenames.PushString(fullPath);
    }
  }
  SortADTArray(logFilenames, Sort_Descending, Sort_String);
  if (logFilenames.Length > 0) {
    logFilenames.GetString(0, filename, sizeof(filename));
    File logFile = OpenFile(filename, "r");
    if (logFile != null) {
      f.WriteLine("Last log info from %s:", filename);
      int maxLineLength = 1024;
      ArrayList lines = new ArrayList(maxLineLength);
      char[] line = new char[maxLineLength];
      while (logFile.ReadLine(line, maxLineLength)) {
        lines.PushString(line);
      }

      for (int i = 0; i < maxLines; i++) {
        int idx = lines.Length - 1 - i;
        if (idx < 0 || idx >= lines.Length) {
          break;
        }
        lines.GetString(idx, line, maxLineLength);
        f.WriteString(line, true);
      }

      delete logFile;
    } else {
      f.WriteLine("Couldn't read log file %s", filename);
    }
  }

  delete dir;
}

static void AddPluginList(File f) {
  f.WriteLine("sm plugins list:");
  Handle iter = GetPluginIterator();
  while (MorePlugins(iter)) {
    Handle plugin = ReadPlugin(iter);
    char filename[PLATFORM_MAX_PATH + 1];
    GetPluginFilename(plugin, filename, sizeof(filename));
    char name[128];
    char author[128];
    char desc[128];
    char version[128];
    char url[128];
    GetPluginInfo(plugin, PlInfo_Name, name, sizeof(name));
    GetPluginInfo(plugin, PlInfo_Author, author, sizeof(author));
    GetPluginInfo(plugin, PlInfo_Description, desc, sizeof(desc));
    GetPluginInfo(plugin, PlInfo_Version, version, sizeof(version));
    GetPluginInfo(plugin, PlInfo_URL, url, sizeof(url));
    f.WriteLine("%s: %s by %s: %s (%s, %s)", filename, name, author, desc, version, url);
  }
  CloseHandle(iter);
}
