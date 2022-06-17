#include <cstrike>
#include <sdktools>

#tryinclude "manual_version.sp"
#if !defined PLUGIN_VERSION
#define PLUGIN_VERSION "2.0.7"
#endif

#define DEBUG_CVAR "sm_pugsetup_debug"
#define MAX_INTEGER_STRING_LENGTH 16
#define MAX_FLOAT_STRING_LENGTH 32

static char _colorNames[][] = {"{NORMAL}", "{DARK_RED}",    "{PINK}",      "{GREEN}",
                               "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
                               "{ORANGE}", "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"};
static char _colorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06",
                               "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

stock void AddMenuOption(Menu menu, const char[] info, const char[] display, any:...) {
  char formattedDisplay[128];
  VFormat(formattedDisplay, sizeof(formattedDisplay), display, 4);
  menu.AddItem(info, formattedDisplay);
}

/**
 * Adds an integer to a menu as a string choice.
 */
stock void AddMenuInt(Menu menu, int value, const char[] display, any:...) {
  char formattedDisplay[128];
  VFormat(formattedDisplay, sizeof(formattedDisplay), display, 4);
  char buffer[MAX_INTEGER_STRING_LENGTH];
  IntToString(value, buffer, sizeof(buffer));
  menu.AddItem(buffer, formattedDisplay);
}

stock void AddMenuIntDisabled(Menu menu, int value, const char[] display, any:...) {
  char formattedDisplay[128];
  VFormat(formattedDisplay, sizeof(formattedDisplay), display, 4);
  char buffer[MAX_INTEGER_STRING_LENGTH];
  IntToString(value, buffer, sizeof(buffer));
  menu.AddItem(buffer, formattedDisplay, ITEMDRAW_DISABLED);
}

/**
 * Adds an integer to a menu, named by the integer itself.
 */
stock void AddMenuInt2(Menu menu, int value) {
  char buffer[MAX_INTEGER_STRING_LENGTH];
  IntToString(value, buffer, sizeof(buffer));
  menu.AddItem(buffer, buffer);
}

/**
 * Gets an integer to a menu from a string choice.
 */
stock int GetMenuInt(Menu menu, int param2) {
  char buffer[MAX_INTEGER_STRING_LENGTH];
  menu.GetItem(param2, buffer, sizeof(buffer));
  return StringToInt(buffer);
}

/**
 * Adds a boolean to a menu as a string choice.
 */
stock void AddMenuBool(Menu menu, bool value, const char[] display, any:...) {
  char formattedDisplay[128];
  VFormat(formattedDisplay, sizeof(formattedDisplay), display, 4);
  int convertedInt = value ? 1 : 0;
  AddMenuInt(menu, convertedInt, formattedDisplay);
}

/**
 * Gets a boolean to a menu from a string choice.
 */
stock bool GetMenuBool(Menu menu, int param2) {
  return GetMenuInt(menu, param2) != 0;
}

/**
 * Returns the number of human clients on a team.
 */
stock int GetNumHumansOnTeam(int team) {
  int count = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsValidClient(i) && !IsFakeClient(i) && GetClientTeam(i) == team)
      count++;
  }
  return count;
}

/**
 * Returns a random player client on the server.
 */
stock int RandomPlayer(int exclude = -1) {
  ArrayList clients = new ArrayList();

  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && i != exclude) {
      clients.Push(i);
    }
  }

  if (clients.Length == 0) {
    delete clients;
    return -1;
  }

  int client = GetArrayCellRandom(clients);
  delete clients;
  return client;
}

/**
 * Switches and respawns a player onto a new team.
 */
stock void SwitchPlayerTeam(int client, int team) {
  if (GetClientTeam(client) == team)
    return;

  if (team > CS_TEAM_SPECTATOR) {
    CS_SwitchTeam(client, team);
    CS_UpdateClientModel(client);
    CS_RespawnPlayer(client);
  } else {
    ChangeClientTeam(client, team);
  }
}

/**
 * Returns if a client is valid.
 */
stock bool IsValidClient(int client) {
  return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client);
}

stock bool IsPlayer(int client) {
  return IsValidClient(client) && !IsFakeClient(client);
}

stock bool IsPossibleLeader(int client) {
  return client > 0 && client <= MaxClients && IsClientConnected(client) && !IsFakeClient(client);
}

/**
 * Returns the number of clients that are actual players in the game.
 */
stock int GetRealClientCount() {
  int clients = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      clients++;
    }
  }
  return clients;
}

stock int CountAlivePlayersOnTeam(int team) {
  int count = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
      count++;
  }
  return count;
}

stock int SumHealthOfTeam(int team) {
  int sum = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && IsPlayerAlive(i) && team == GetClientTeam(i)) {
      sum += GetClientHealth(i);
    }
  }
  return sum;
}

/**
 * Returns a random index from an array.
 */
stock int GetArrayRandomIndex(ArrayList array) {
  int len = array.Length;
  if (len == 0)
    ThrowError("Can't get random index from empty array");
  return GetRandomInt(0, len - 1);
}

/**
 * Returns a random element from an array.
 */
stock int GetArrayCellRandom(ArrayList array) {
  int index = GetArrayRandomIndex(array);
  return array.Get(index);
}

stock void Colorize(char[] msg, int size, bool stripColor = false) {
  for (int i = 0; i < sizeof(_colorNames); i++) {
    if (stripColor)
      ReplaceString(msg, size, _colorNames[i], "\x01");  // replace with white
    else
      ReplaceString(msg, size, _colorNames[i], _colorCodes[i]);
  }
}

stock void RandomizeArray(ArrayList array) {
  int n = array.Length;
  for (int i = 0; i < n; i++) {
    int choice = GetRandomInt(0, n - 1);
    array.SwapAt(i, choice);
  }
}

stock bool IsTVEnabled() {
  Handle tvEnabledCvar = FindConVar("tv_enable");
  if (tvEnabledCvar == INVALID_HANDLE) {
    LogError("Failed to get tv_enable cvar");
    return false;
  }
  return GetConVarInt(tvEnabledCvar) != 0;
}

stock bool Record(const char[] demoName) {
  char szDemoName[256];
  strcopy(szDemoName, sizeof(szDemoName), demoName);
  ReplaceString(szDemoName, sizeof(szDemoName), "\"", "\\\"");
  ServerCommand("tv_record \"%s\"", szDemoName);

  if (!IsTVEnabled()) {
    LogError(
        "Autorecording will not work with current cvar \"tv_enable\"=0. Set \"tv_enable 1\" in server.cfg (or another config file) to fix this.");
    return false;
  }

  return true;
}

stock void StopRecording() {
  ServerCommand("tv_stoprecord");
}

stock bool InWarmup() {
  return GameRules_GetProp("m_bWarmupPeriod") != 0;
}

stock void EnsurePausedWarmup() {
  if (!InWarmup()) {
    StartWarmup();
  }

  ServerCommand("mp_warmup_pausetimer 1");
  ServerCommand("mp_do_warmup_period 1");
  ServerCommand("mp_warmup_pausetimer 1");
}

stock void StartWarmup(bool indefiniteWarmup = true, int warmupTime = 60) {
  ServerCommand("mp_do_warmup_period 1");
  ServerCommand("mp_warmuptime %d", warmupTime);
  ServerCommand("mp_warmup_start");

  // For some reason it needs to get sent twice. Ask Valve.
  if (indefiniteWarmup) {
    ServerCommand("mp_warmup_pausetimer 1");
    ServerCommand("mp_warmup_pausetimer 1");
  }
}

stock void EndWarmup() {
  ServerCommand("mp_warmup_end");
}

stock bool IsPaused() {
  return GameRules_GetProp("m_bMatchWaitingForResume") != 0;
}

stock void Pause() {
  ServerCommand("mp_pause_match");
}

stock void Unpause() {
  ServerCommand("mp_unpause_match");
}

stock void RestartGame(int delay) {
  ServerCommand("mp_restartgame %d", delay);
}

stock int GetCookieInt(int client, Handle cookie, int defaultValue = 0) {
  char buffer[MAX_INTEGER_STRING_LENGTH];
  GetClientCookie(client, cookie, buffer, sizeof(buffer));

  if (StrEqual(buffer, ""))
    return defaultValue;

  return StringToInt(buffer);
}

stock float GetCookieFloat(int client, Handle cookie, float defaultValue = 0.0) {
  char buffer[MAX_FLOAT_STRING_LENGTH];
  GetClientCookie(client, cookie, buffer, sizeof(buffer));

  if (StrEqual(buffer, ""))
    return defaultValue;

  return StringToFloat(buffer);
}

stock void SetCookieInt(int client, Handle cookie, int value) {
  char buffer[MAX_INTEGER_STRING_LENGTH];
  IntToString(value, buffer, sizeof(buffer));
  SetClientCookie(client, cookie, buffer);
}

stock void SetCookieFloat(int client, Handle cookie, float value) {
  char buffer[MAX_FLOAT_STRING_LENGTH];
  FloatToString(value, buffer, sizeof(buffer));
  SetClientCookie(client, cookie, buffer);
}

stock void SetConVarStringSafe(const char[] name, const char[] value) {
  Handle cvar = FindConVar(name);
  if (cvar == INVALID_HANDLE) {
    LogError("Failed to find cvar: \"%s\"", name);
  } else {
    SetConVarString(cvar, value);
  }
}

stock void SetTeamInfo(int team, const char[] name, const char[] flag = "") {
  int team_int = (team == CS_TEAM_CT) ? 1 : 2;

  char teamCvarName[32];
  char flagCvarName[32];
  Format(teamCvarName, sizeof(teamCvarName), "mp_teamname_%d", team_int);
  Format(flagCvarName, sizeof(flagCvarName), "mp_teamflag_%d", team_int);

  SetConVarStringSafe(teamCvarName, name);
  SetConVarStringSafe(flagCvarName, flag);
}

stock bool OnActiveTeam(int client) {
  if (!IsPlayer(client))
    return false;

  int team = GetClientTeam(client);
  return team == CS_TEAM_CT || team == CS_TEAM_T;
}

/**
 * Closes a nested adt-array.
 */
stock void CloseNestedArray(Handle array, bool closeOuterArray = true) {
  int n = GetArraySize(array);
  for (int i = 0; i < n; i++) {
    Handle h = GetArrayCell(array, i);
    CloseHandle(h);
  }

  if (closeOuterArray)
    CloseHandle(array);
}

stock void ClearNestedArray(Handle array) {
  int n = GetArraySize(array);
  for (int i = 0; i < n; i++) {
    Handle h = GetArrayCell(array, i);
    CloseHandle(h);
  }

  ClearArray(array);
}

stock void GetEnabledString(char[] buffer, int length, bool variable, int client = LANG_SERVER) {
  if (variable)
    Format(buffer, length, "%T", "Enabled", client);
  else
    Format(buffer, length, "%T", "Disabled", client);
}

stock void GetTrueString(char[] buffer, int length, bool variable, int client = LANG_SERVER) {
  if (variable)
    Format(buffer, length, "true");
  else
    Format(buffer, length, "false");
}

stock void ReplaceStringWithInt(char[] buffer, int len, const char[] replace, int value,
                                bool caseSensitive = false) {
  char intString[MAX_INTEGER_STRING_LENGTH];
  IntToString(value, intString, sizeof(intString));
  ReplaceString(buffer, len, replace, intString, caseSensitive);
}

stock void ReplaceStringWithColoredInt(char[] buffer, int len, const char[] replace, int value,
                                       const char[] color, bool caseSensitive = false) {
  char intString[MAX_INTEGER_STRING_LENGTH + 32];
  Format(intString, sizeof(intString), "{%s}%d{NORMAL}", color, value);
  ReplaceString(buffer, len, replace, intString, caseSensitive);
}

stock int GetCvarIntSafe(const char[] cvarName) {
  Handle cvar = FindConVar(cvarName);
  if (cvar == INVALID_HANDLE) {
    LogError("Failed to find cvar \"%s\"", cvar);
    return 0;
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

stock void GetCleanMapName(char[] buffer, int size) {
  char mapName[PLATFORM_MAX_PATH];
  GetCurrentMap(mapName, sizeof(mapName));
  int last_slash = 0;
  int len = strlen(mapName);
  for (int i = 0; i < len; i++) {
    if (mapName[i] == '/' || mapName[i] == '\\')
      last_slash = i + 1;
  }
  strcopy(buffer, size, mapName[last_slash]);
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

stock bool IsClientCoaching(int client) {
  return GetClientTeam(client) == CS_TEAM_SPECTATOR &&
         GetEntProp(client, Prop_Send, "m_iCoachingTeam") != 0;
}

stock int GetCoachTeam(int client) {
  return GetEntProp(client, Prop_Send, "m_iCoachingTeam");
}

stock void UpdateCoachTarget(int client, int csTeam) {
  SetEntProp(client, Prop_Send, "m_iCoachingTeam", csTeam);
}
