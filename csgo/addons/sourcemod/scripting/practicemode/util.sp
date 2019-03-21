#include <cstrike>
#include <sdktools>

#define DEFAULT_MENU_LENGTH 128

#tryinclude "manual_version.sp"
#if !defined PLUGIN_VERSION
#define PLUGIN_VERSION "1.3.3"
#endif

static char _colorNames[][] = {"{NORMAL}", "{DARK_RED}",    "{PINK}",      "{GREEN}",
                               "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
                               "{ORANGE}", "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"};
static char _colorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06",
                               "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

stock void SwitchPlayerTeam(int client, int team) {
  if (GetClientTeam(client) == team)
    return;

  if (team > CS_TEAM_SPECTATOR) {
    ForcePlayerSuicide(client);
    CS_SwitchTeam(client, team);
    CS_UpdateClientModel(client);
    CS_RespawnPlayer(client);
  } else {
    ChangeClientTeam(client, team);
  }
}

stock bool IsValidClient(int client) {
  return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client);
}

stock bool IsPlayer(int client) {
  return IsValidClient(client) && !IsFakeClient(client) && !IsClientSourceTV(client);
}

stock void Colorize(char[] msg, int size, bool stripColor = false) {
  for (int i = 0; i < sizeof(_colorNames); i++) {
    if (stripColor)
      ReplaceString(msg, size, _colorNames[i], "\x01");  // replace with white
    else
      ReplaceString(msg, size, _colorNames[i], _colorCodes[i]);
  }
}

public void SetCvar(const char[] name, int value) {
  Handle cvar = FindConVar(name);
  if (cvar == INVALID_HANDLE) {
    LogError("cvar \"%s\" could not be found", name);
  } else {
    SetConVarInt(cvar, value);
  }
}

stock void SetConVarStringSafe(const char[] name, const char[] value) {
  Handle cvar = FindConVar(name);
  if (cvar == INVALID_HANDLE) {
    LogError("Failed to find cvar: \"%s\"", name);
  } else {
    SetConVarString(cvar, value);
  }
}

/**
 * Closes a nested adt-array.
 */
stock void CloseNestedArray(ArrayList array, bool closeOuterArray = true) {
  for (int i = 0; i < array.Length; i++) {
    ArrayList h = view_as<ArrayList>(array.Get(i));
    delete h;
  }

  if (closeOuterArray)
    delete array;
}

stock void ClearNestedArray(ArrayList array) {
  for (int i = 0; i < array.Length; i++) {
    ArrayList h = view_as<ArrayList>(array.Get(i));
    delete h;
  }

  ClearArray(array);
}

stock int FindAndErase(ArrayList array, int value) {
  int count = 0;
  for (int i = 0; i < array.Length; i++) {
    if (array.Get(i) == value) {
      array.Erase(i);
      i--;
      count++;
    }
  }
  return count;
}

stock void GetEnabledString(char[] buffer, int length, bool variable, int client = LANG_SERVER) {
  if (variable)
    Format(buffer, length, "enabled");
  else
    Format(buffer, length, "disabled");
}

stock int GetCvarIntSafe(const char[] cvarName, int defaultValue = 0) {
  Handle cvar = FindConVar(cvarName);
  if (cvar == INVALID_HANDLE) {
    LogError("Failed to find cvar \"%s\"", cvar);
    return defaultValue;
  } else {
    return GetConVarInt(cvar);
  }
}

stock int FindStringInArray2(const char[][] array, int len, const char[] string,
                             bool caseSensitive = true) {
  for (int i = 0; i < len; i++) {
    if (StrEqual(string, array[i], caseSensitive)) {
      return i;
    }
  }

  return -1;
}

stock int FindStringInList(ArrayList list, int len, const char[] string,
                           bool caseSensitive = true) {
  char[] buffer = new char[len];
  for (int i = 0; i < list.Length; i++) {
    list.GetString(i, buffer, len);
    if (StrEqual(string, buffer, caseSensitive)) {
      return i;
    }
  }

  return -1;
}

stock void GetCleanMapName(char[] buffer, int size) {
  char mapName[PLATFORM_MAX_PATH];
  GetCurrentMap(mapName, sizeof(mapName));
  CleanMapName(mapName, buffer, size);
}

stock void CleanMapName(const char[] input, char[] buffer, int size) {
  int last_slash = 0;
  int len = strlen(input);
  for (int i = 0; i < len; i++) {
    if (input[i] == '/' || input[i] == '\\')
      last_slash = i + 1;
  }
  strcopy(buffer, size, input[last_slash]);
}

stock void RemoveCvarFlag(Handle cvar, int flag) {
  SetConVarFlags(cvar, GetConVarFlags(cvar) & ~flag);
}

stock int min(int x, int y) {
  return (x < y) ? x : y;
}

stock bool SplitOnSpaceFirstPart(const char[] str, char[] buf1, int len1) {
  for (int i = 0; i < strlen(str); i++) {
    if (str[i] == ' ') {
      strcopy(buf1, min(len1, i + 1), str);
      return true;
    }
  }
  return false;
}

stock bool SplitOnSpace(const char[] str, char[] buf1, int len1, char[] buf2, int len2) {
  for (int i = 0; i < strlen(str); i++) {
    if (str[i] == ' ') {
      strcopy(buf1, min(len1, i + 1), str);
      strcopy(buf2, len2, str[i + 1]);
      return true;
    }
  }
  return false;
}

stock ArrayList SplitStringToList(const char[] str, const char[] split, int maxlen) {
  ArrayList list = new ArrayList(maxlen);
  int index = 0;
  while (index != -1) {
    char[] buffer = new char[maxlen];
    int ret = SplitString(str[index], split, buffer, maxlen);
    if (ret != -1) {
      list.PushString(buffer);
      index += ret;
    } else {
      list.PushString(str[index]);
      index = -1;
    }
  }
  return list;
}

stock ConVar GetCvar(const char[] name) {
  ConVar cvar = FindConVar(name);
  if (cvar == null) {
    SetFailState("Failed to find cvar: \"%s\"", name);
  }
  return cvar;
}

stock int AttemptFindTarget(const char[] target) {
  char target_name[MAX_TARGET_LENGTH];
  int target_list[1];
  bool tn_is_ml;
  int flags = COMMAND_FILTER_NO_MULTI | COMMAND_FILTER_NO_BOTS | COMMAND_FILTER_NO_IMMUNITY;

  if (ProcessTargetString(target, 0, target_list, 1, flags, target_name, sizeof(target_name),
                          tn_is_ml) > 0) {
    return target_list[0];
  } else {
    return -1;
  }
}

stock void LowerString(char[] string) {
  int len = strlen(string);
  for (int i = 0; i < len; i++) {
    string[i] = CharToLower(string[i]);
  }
}

stock void UpperString(char[] string) {
  int len = strlen(string);
  for (int i = 0; i < len; i++) {
    string[i] = CharToUpper(string[i]);
  }
}

stock void SetCookieInt(int client, Handle cookie, int value) {
  char buffer[32];
  IntToString(value, buffer, sizeof(buffer));
  SetClientCookie(client, cookie, buffer);
}

stock int GetCookieInt(int client, Handle cookie, int defaultValue = 0) {
  char buffer[32];
  GetClientCookie(client, cookie, buffer, sizeof(buffer));
  if (StrEqual(buffer, "")) {
    return defaultValue;
  }

  return StringToInt(buffer);
}

stock void SetCookieBool(int client, Handle cookie, bool value) {
  int convertedInt = value ? 1 : 0;
  SetCookieInt(client, cookie, convertedInt);
}

stock bool GetCookieBool(int client, Handle cookie, bool defaultValue = false) {
  return GetCookieInt(client, cookie, defaultValue) != 0;
}

stock void SetCookieFloat(int client, Handle cookie, float value) {
  char buffer[32];
  FloatToString(value, buffer, sizeof(buffer));
  SetClientCookie(client, cookie, buffer);
}

stock float GetCookieFloat(int client, Handle cookie, float defaultValue = 0.0) {
  char buffer[32];
  GetClientCookie(client, cookie, buffer, sizeof(buffer));
  if (StrEqual(buffer, "")) {
    return defaultValue;
  }

  return StringToFloat(buffer);
}

public bool EnforceDirectoryExists(const char[] smPath) {
  char dir[PLATFORM_MAX_PATH + 1];
  BuildPath(Path_SM, dir, sizeof(dir), smPath);
  if (!DirExists(dir)) {
    if (!CreateDirectory(dir, 511)) {
      LogError("Failed to create directory %s", dir);
      return false;
    }
  }
  return true;
}

stock void ExecuteCvarLists(ArrayList cvars, ArrayList values) {
  char cvar[CVAR_NAME_LENGTH];
  char value[CVAR_VALUE_LENGTH];
  for (int i = 0; i < cvars.Length; i++) {
    cvars.GetString(i, cvar, sizeof(cvar));
    values.GetString(i, value, sizeof(value));
    ServerCommand("%s %s", cvar, value);
  }
}

stock void ReadCvarKv(KeyValues kv, ArrayList cvars, ArrayList values) {
  char cvarName[CVAR_NAME_LENGTH];
  char cvarValue[CVAR_VALUE_LENGTH];
  if (kv.GotoFirstSubKey(false)) {
    do {
      kv.GetSectionName(cvarName, sizeof(cvarName));
      cvars.PushString(cvarName);
      kv.GetString(NULL_STRING, cvarValue, sizeof(cvarValue));
      values.PushString(cvarValue);
    } while (kv.GotoNextKey(false));
    kv.GoBack();
  }
}

stock void ChangeMap(const char[] map, float delay = 3.0) {
  PM_MessageToAll("Changing map to %s...", map);
  DataPack pack = CreateDataPack();
  pack.WriteString(map);
  CreateTimer(delay, Timer_DelayedChangeMap, pack);
}

stock Action Timer_DelayedChangeMap(Handle timer, Handle data) {
  char map[PLATFORM_MAX_PATH];
  DataPack pack = view_as<DataPack>(data);
  pack.Reset();
  pack.ReadString(map, sizeof(map));
  delete pack;

  if (IsMapValid(map)) {
    ServerCommand("changelevel %s", map);
  } else if (StrContains(map, "workshop") == 0) {
    ServerCommand("host_workshop_map %d", GetMapIdFromString(map));
  }

  return Plugin_Handled;
}

stock int GetMapIdFromString(const char[] map) {
  char buffers[4][PLATFORM_MAX_PATH];
  ExplodeString(map, "/", buffers, sizeof(buffers), PLATFORM_MAX_PATH);
  return StringToInt(buffers[1]);
}

stock void AddMenuInt(Menu menu, int value, const char[] display, any:...) {
  char formattedDisplay[128];
  VFormat(formattedDisplay, sizeof(formattedDisplay), display, 4);
  char buffer[32];
  IntToString(value, buffer, sizeof(buffer));
  menu.AddItem(buffer, formattedDisplay);
}

stock void AddMenuIntStyle(Menu menu, int value, int style, const char[] display, any:...) {
  char formattedDisplay[128];
  VFormat(formattedDisplay, sizeof(formattedDisplay), display, 5);
  char buffer[32];
  IntToString(value, buffer, sizeof(buffer));
  menu.AddItem(buffer, formattedDisplay, style);
}

stock int GetMenuInt(Menu menu, int param2) {
  char buffer[32];
  menu.GetItem(param2, buffer, sizeof(buffer));
  return StringToInt(buffer);
}

stock int EnabledIf(bool condition) {
  return condition ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
}

stock void GetPlayerBoundingBox(int client, float min[3], float max[3]) {
  float clientMin[3];
  float clientMax[3];
  float clientOrigin[3];
  GetClientMins(client, clientMin);
  GetClientMaxs(client, clientMax);
  GetClientAbsOrigin(client, clientOrigin);
  for (int i = 0; i < 3; i++) {
    min[i] = clientOrigin[i] + clientMin[i];
    max[i] = clientOrigin[i] + clientMax[i];
  }
}

stock bool DoPlayersCollide(int client1, int client2) {
  float client1Min[3];
  float client1Max[3];
  float client2Min[3];
  float client2Max[3];
  GetPlayerBoundingBox(client1, client1Min, client1Max);
  GetPlayerBoundingBox(client2, client2Min, client2Max);
  return (client1Min[0] <= client2Max[0] && client1Max[0] >= client2Min[0]) &&
         (client1Min[1] <= client2Max[1] && client1Max[1] >= client2Min[1]) &&
         (client1Min[2] <= client2Max[2] && client1Max[2] >= client2Min[2]);
}

stock float GetFlashDuration(int client) {
  return GetEntDataFloat(client, FindSendPropInfo("CCSPlayer", "m_flFlashDuration"));
}

stock int RemoveDuplicates(ArrayList list, int stringLength) {
  // Yeah it's really inefficient.
  int count = 0;
  for (int i = list.Length - 1; i > 0; i--) {
    char[] buf = new char[stringLength];
    list.GetString(i, buf, stringLength);

    // Remove all duplicates that come before i.
    int found;
    while ((found = list.FindString(buf)) != i) {
      list.Erase(found);
      i--;
      count++;
    }
  }
  return count;
}
