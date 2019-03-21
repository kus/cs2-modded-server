#define MESSAGE_PREFIX "[\x05Multi1v1\x01] "
#define HIDE_RADAR_BIT 1 << 12
#define DEBUG_CVAR "sm_multi1v1_debug"
#define INTEGER_STRING_LENGTH 20  // max number of digits a 64-bit integer can use up as a string
// this is for converting ints to strings when setting menu values/cookies

char g_ColorNames[][] = {"{NORMAL}",     "{DARK_RED}",    "{PURPLE}",    "{GREEN}",
                         "{MOSS_GREEN}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
                         "{ORANGE}",     "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"};
char g_ColorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06",
                         "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

#include <clientprefs>
#include <cstrike>

#define SPECMODE_FIRSTPERSON 4
#define SPECMODE_THIRDPERSON 5
#define SPECMODE_FREELOOK 6

/**
 * Removes the radar element from a client's HUD.
 */
public Action RemoveRadar(Handle timer, int client) {
  if (IsValidClient(client) && !IsFakeClient(client)) {
    int flags = GetEntProp(client, Prop_Send, "m_iHideHUD");
    SetEntProp(client, Prop_Send, "m_iHideHUD", flags | (HIDE_RADAR_BIT));
  }
  return Plugin_Continue;
}

/**
 * Function to identify if a client is valid and in game.
 */
stock bool IsValidClient(int client) {
  return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client);
}

stock bool IsConnected(int client) {
  return client > 0 && client <= MaxClients && IsClientConnected(client) && !IsFakeClient(client);
}

/**
 * Returns if a player is on an active/player team.
 */
stock bool IsPlayer(int client) {
  return IsValidClient(client) && !IsFakeClient(client);
}

/**
 * Returns if a player is on an active/player team.
 */
stock bool IsActivePlayer(int client) {
  if (!IsPlayer(client))
    return false;
  int client_team = GetClientTeam(client);
  return (client_team == CS_TEAM_CT) || (client_team == CS_TEAM_T);
}

/**
 * Adds a formatted display string to a menu.
 */
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

  char buffer[INTEGER_STRING_LENGTH];
  IntToString(value, buffer, sizeof(buffer));
  AddMenuItem(menu, buffer, formattedDisplay);
}

/**
 * Gets an integer to a menu from a string choice.
 */
stock int GetMenuInt(Menu menu, int param2) {
  char choice[INTEGER_STRING_LENGTH];
  GetMenuItem(menu, param2, choice, sizeof(choice));
  return StringToInt(choice);
}

/**
 * Adds a boolean to a menu as a string choice.
 */
stock void AddMenuBool(Menu menu, bool value, const char[] display) {
  int convertedInt = value ? 1 : 0;
  AddMenuInt(menu, convertedInt, display);
}

/**
 * Gets a boolean to a menu from a string choice.
 */
stock bool GetMenuBool(Menu menu, int param2) {
  return GetMenuInt(menu, param2) != 0;
}

/**
 * Sets a cookie to an integer value by converting it to a string.
 */
stock void SetCookieInt(int client, Handle cookie, int value) {
  char buffer[INTEGER_STRING_LENGTH];
  IntToString(value, buffer, sizeof(buffer));
  SetClientCookie(client, cookie, buffer);
}

/**
 * Fetches the value of a cookie that is an integer.
 */
stock int GetCookieInt(int client, Handle cookie, int defaultValue = 0) {
  char buffer[INTEGER_STRING_LENGTH];
  GetClientCookie(client, cookie, buffer, sizeof(buffer));
  if (StrEqual(buffer, "")) {
    return defaultValue;
  }

  return StringToInt(buffer);
}

/**
 * Sets a cookie to a boolean value.
 */
stock void SetCookieBool(int client, Handle cookie, bool value) {
  int convertedInt = value ? 1 : 0;
  SetCookieInt(client, cookie, convertedInt);
}

/**
 * Gets a cookie that represents a boolean.
 */
stock bool GetCookieBool(int client, Handle cookie, bool defaultValue = false) {
  return GetCookieInt(client, cookie, defaultValue) != 0;
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
 * Pushes an element to an array multiple times.
 */
stock void PushArrayCellReplicated(ArrayList array, int value, int times) {
  for (int i = 0; i < times; i++)
    array.Push(value);
}

/**
 * Given an array of vectors, returns the index of the index
 * that minimizes the euclidean distance between the vectors.
 */
stock int NearestNeighborIndex(const float vec[3], ArrayList others) {
  int closestIndex = -1;
  float closestDistance = 0.0;
  for (int i = 0; i < others.Length; i++) {
    float tmp[3];
    others.GetArray(i, tmp);
    float dist = GetVectorDistance(vec, tmp);
    if (closestIndex < 0 || dist < closestDistance) {
      closestDistance = dist;
      closestIndex = i;
    }
  }

  return closestIndex;
}

/**
 * Closes all handles within an arraylist of arraylists.
 */
stock void CloseNestedList(ArrayList list) {
  int n = list.Length;
  for (int i = 0; i < n; i++) {
    ArrayList tmp = view_as<ArrayList>(list.Get(i));
    delete tmp;
  }
  delete list;
}

/**
 * Creates a table given an array of table arguments.
 */
stock void SQL_CreateTable(Handle db_connection, const char[] table_name, const char[][] fields,
                           int num_fields) {
  char buffer[1024];
  Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS %s (", table_name);
  for (int i = 0; i < num_fields; i++) {
    StrCat(buffer, sizeof(buffer), fields[i]);
    if (i != num_fields - 1)
      StrCat(buffer, sizeof(buffer), ", ");
  }
  StrCat(buffer, sizeof(buffer), ")");

  if (!SQL_FastQuery(db_connection, buffer)) {
    char err[255];
    SQL_GetError(db_connection, err, sizeof(err));
    LogError(err);
  }
}

/**
 * Adds a new field to a table.
 */
stock void SQL_AddColumn(Handle db_connection, const char[] table_name, const char[] column_info) {
  char buffer[1024];
  Format(buffer, sizeof(buffer), "ALTER TABLE %s ADD COLUMN %s", table_name, column_info);
  if (!SQL_FastQuery(db_connection, buffer)) {
    char err[255];
    SQL_GetError(db_connection, err, sizeof(err));
    if (StrContains(err, "Duplicate column name", false) == -1) {
      LogError(err);
    }
  }
}

/**
 * Sets the primary key for a table.
 */
stock void SQL_UpdatePrimaryKey(Handle db_connection, const char[] table_name,
                                const char[] primary_key) {
  char buffer[1024];
  Format(buffer, sizeof(buffer), "ALTER TABLE %s DROP PRIMARY KEY, ADD PRIMARY KEY (%s)",
         table_name, primary_key);
  if (!SQL_FastQuery(db_connection, buffer)) {
    char err[255];
    SQL_GetError(db_connection, err, sizeof(err));
    LogError(err);
  }
}

/**
 * Applies colorized characters across a string to replace color tags.
 */
stock void Colorize(char[] msg, int size) {
  for (int i = 0; i < sizeof(g_ColorNames); i++) {
    ReplaceString(msg, size, g_ColorNames[i], g_ColorCodes[i]);
  }
}

// Thanks to KissLick https://forums.alliedmods.net/member.php?u=210752
/**
 * Splits a string to the right at the first occurance of a substring.
 */
stock bool SplitStringRight(const char[] source, const char[] split, char[] part, int partLen) {
  int index = StrContains(source, split);
  if (index == -1)
    return false;

  index += strlen(split);
  strcopy(part, partLen, source[index]);
  return true;
}

stock void Client_SetHelmet(int client, bool helmet) {
  int offset = FindSendPropInfo("CCSPlayer", "m_bHasHelmet");
  SetEntData(client, offset, helmet);
}

// Modified version of smlib's Client_RemoveAllWeapons with weapon substring matching
stock int Client_RemoveAllMatchingWeapons(int client, const char[] exclude,
                                          bool clearAmmo = false) {
  int offset = Client_GetWeaponsOffset(client) - 4;

  int numWeaponsRemoved = 0;
  for (int i = 0; i < MAX_WEAPONS; i++) {
    offset += 4;

    int weapon = GetEntDataEnt2(client, offset);

    if (!Weapon_IsValid(weapon)) {
      continue;
    }

    if (exclude[0] != '\0' && Entity_ClassNameMatches(weapon, exclude, true)) {
      Client_SetActiveWeapon(client, weapon);
      continue;
    }

    if (clearAmmo) {
      Client_SetWeaponPlayerAmmoEx(client, weapon, 0, 0);
    }

    if (RemovePlayerItem(client, weapon)) {
      Entity_Kill(weapon);
    }

    numWeaponsRemoved++;
  }

  return numWeaponsRemoved;
}

stock ConVar FindCvarAndLogError(const char[] name) {
  ConVar c = FindConVar(name);
  if (c == null) {
    LogError("ConVar \"%s\" could not be found");
  }
  return c;
}

stock void GetEnabledString(char[] buffer, int length, bool variable, int client = LANG_SERVER) {
  if (variable)
    Format(buffer, length, "%T", "Enabled", client);
  else
    Format(buffer, length, "%T", "Disabled", client);
}

public float fmin(float x, float y) {
  return (x < y) ? x : y;
}

public float fmax(float x, float y) {
  return (x < y) ? y : x;
}
