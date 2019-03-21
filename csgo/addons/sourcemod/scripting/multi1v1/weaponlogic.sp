/**
 * Initializes weapon-related data on map start.
 * This includes the server-specific weapon config file configs/multi1v1_weapons.cfg.
 */
public void Weapons_Init() {
  g_numPistols = 0;
  g_numRifles = 0;

  char configFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, configFile, sizeof(configFile), "configs/multi1v1_weapons.cfg");

  if (!FileExists(configFile)) {
    LogError("The weapon config file does not exist: %s", configFile);
    LoadBackupConfig();
    return;
  }

  KeyValues kv = new KeyValues("Weapons");
  kv.ImportFromFile(configFile);

  // Parse the rifles section
  if (!KvJumpToKey(kv, "Rifles")) {
    LogError("The weapon config file did not contain a \"Rifles\" section: %s", configFile);
    delete kv;
    LoadBackupConfig();
    return;
  }
  if (!kv.GotoFirstSubKey()) {
    LogError("No rifles were found.");
  }
  do {
    kv.GetSectionName(g_Rifles[g_numRifles][0], WEAPON_NAME_LENGTH);
    kv.GetString("name", g_Rifles[g_numRifles][1], WEAPON_NAME_LENGTH, g_Rifles[g_numRifles][0]);
    kv.GetString("team", g_Rifles[g_numRifles][2], WEAPON_NAME_LENGTH, "ANY");
    g_numRifles++;
  } while (kv.GotoNextKey());
  kv.Rewind();

  // Parse the pistols section
  if (!KvJumpToKey(kv, "Pistols")) {
    LogError("The weapon config file did not contain a \"Pistols\" section: %s", configFile);
    delete kv;
    LoadBackupConfig();
    return;
  }

  if (!kv.GotoFirstSubKey()) {
    LogError("No pistols were found.");
  }
  do {
    kv.GetSectionName(g_Pistols[g_numPistols][0], WEAPON_NAME_LENGTH);
    kv.GetString("name", g_Pistols[g_numPistols][1], WEAPON_NAME_LENGTH,
                 g_Pistols[g_numPistols][0]);
    kv.GetString("team", g_Pistols[g_numPistols][2], WEAPON_NAME_LENGTH, "ANY");
    g_numPistols++;
  } while (kv.GotoNextKey());

  delete kv;
}

/**
 * A simple backup with just a few weapons so bad config files don't totally break the server.
 */
static void LoadBackupConfig() {
  LogError("Plugin forced to fallback to backup weapons only");
  g_Rifles[0][0] = "weapon_ak47";
  g_Rifles[0][1] = "AK47";
  g_Rifles[0][2] = "T";
  g_Rifles[1][0] = "weapon_m4a1";
  g_Rifles[1][1] = "M4A1";
  g_Rifles[1][2] = "CT";
  g_numRifles = 2;

  g_Pistols[0][0] = "weapon_glock";
  g_Pistols[0][1] = "Glock";
  g_Pistols[0][2] = "T";
  g_Pistols[1][0] = "weapon_p250";
  g_Pistols[1][1] = "P250";
  g_Pistols[1][2] = "ANY";
  g_numPistols = 2;
}

static int TeamStringToTeam(const char[] teamString) {
  if (StrEqual(teamString, "CT", false))
    return CS_TEAM_CT;
  else if (StrEqual(teamString, "T", false))
    return CS_TEAM_T;
  else
    return -1;
}

/**
 * Returns the cstrike team a weapon is intended for, or -1 if any can use the weapon.
 * This is only valid for weapons in the server's weapons config file.
 */
public int GetWeaponTeam(const char[] weapon) {
  for (int i = 0; i < g_numRifles; i++) {
    if (StrEqual(weapon[0], g_Rifles[i][0])) {
      return TeamStringToTeam(g_Rifles[i][2][0]);
    }
  }
  for (int i = 0; i < g_numPistols; i++) {
    if (StrEqual(weapon[0], g_Pistols[i][0])) {
      return TeamStringToTeam(g_Pistols[i][2][0]);
    }
  }
  return -1;
}

/**
 * Sets all the weapon choices based on the client's cookies.
 */
public void UpdatePreferencesOnCookies(int client) {
  for (int i = 0; i < g_numRoundTypes; i++) {
    g_AllowedRoundTypes[client][i] = GetCookieBool(client, g_AllowedRoundTypeCookies[i]);
  }

  char cookieValue[WEAPON_LENGTH];
  GetClientCookie(client, g_PrimaryWeaponCookie, cookieValue, sizeof(cookieValue));
  if (IsAllowedRifle(cookieValue))
    strcopy(g_PrimaryWeapon[client], WEAPON_LENGTH, cookieValue);

  GetClientCookie(client, g_SecondaryWeaponCookie, cookieValue, sizeof(cookieValue));
  if (IsAllowedPistol(cookieValue))
    strcopy(g_SecondaryWeapon[client], WEAPON_LENGTH, cookieValue);

  GetClientCookie(client, g_PreferenceCookie, cookieValue, sizeof(cookieValue));
  g_Preference[client] = Multi1v1_GetRoundTypeIndex(cookieValue);

  g_HideStats[client] = GetCookieBool(client, g_HideStatsCookie, HIDESTATS_DEAFULT);
  g_AutoSpec[client] = GetCookieBool(client, g_AutoSpecCookie, AUTOSPEC_DEFAULT);

  // This checks if the player has a preference set
  // By not having one set, we can conclude the client has never selected anything in the guns menu
  if (!StrEqual(cookieValue, "") && g_AutoGunsMenuBehaviorCvar.IntValue == 1) {
    g_GivenGunsMenu[client] = true;
  }
}

/**
 * Gives a player a weapon, taking care of getting them the appropriate skin.
 */
public void GiveWeapon(int client, const char[] weapon) {
  int playerteam = GetEntProp(client, Prop_Data, "m_iTeamNum");
  int weaponteam = GetWeaponTeam(weapon);
  if (weaponteam > 0)
    SetEntProp(client, Prop_Data, "m_iTeamNum", weaponteam);
  GivePlayerItem(client, weapon);
  SetEntProp(client, Prop_Data, "m_iTeamNum", playerteam);
}

/**
 * Returns if the given weapon is a default starting pistol.
 */
public bool IsDefaultPistol(const char[] weapon) {
  char defaultPistols[][] = {"weapon_glock", "weapon_hkp2000", "weapon_usp_silencer"};
  for (int i = 0; i < sizeof(defaultPistols); i++) {
    if (StrEqual(weapon, defaultPistols[i])) {
      return true;
    }
  }
  return false;
}

public bool IsAllowedRifle(const char[] weapon) {
  if (g_RifleMenuCvar.IntValue == 0) {
    return false;
  }
  for (int i = 0; i < g_numRifles; i++) {
    if (StrEqual(g_Rifles[i][0], weapon, false)) {
      return true;
    }
  }
  return false;
}

public bool IsAllowedPistol(const char[] weapon) {
  if (g_PistolMenuCvar.IntValue == 0) {
    return false;
  }
  for (int i = 0; i < g_numPistols; i++) {
    if (StrEqual(g_Pistols[i][0], weapon, false)) {
      return true;
    }
  }
  return false;
}

public int GetRifleIndex(int client) {
  for (int i = 0; i < g_numRifles; i++) {
    if (StrEqual(g_Rifles[i][0], g_PrimaryWeapon[client])) {
      return i;
    }
  }
  return 0;
}

public int GetPistolIndex(int client) {
  for (int i = 0; i < g_numPistols; i++) {
    if (StrEqual(g_Pistols[i][0], g_SecondaryWeapon[client])) {
      return i;
    }
  }
  return 0;
}
