/**
 * Roundtype runtime registration/selection code.
 */

public void LoadRoundTypes() {
  Multi1v1_ClearRoundTypes();
  Multi1v1_AddStandardRounds();
  AddCustomRounds();
  Call_StartForward(g_hOnRoundTypesAdded);
  Call_Finish();

  for (int i = 0; i < g_numRoundTypes; i++) {
    char cookieName[128];
    Format(cookieName, sizeof(cookieName), "multi1v1_allow%s", g_RoundTypeNames[i]);
    g_AllowedRoundTypeCookies[i] =
        RegClientCookie(cookieName, "multi1v1 cookie", CookieAccess_Protected);
  }
}

/**
 * Returns a round type appropriate for a given pair of players.
 * This function is *NOT* pure since it uses randomness
 * to select a round type in some situations.
 */
public int GetRoundType(int arena, int client1, int client2) {
  if (g_numRoundTypes == 0) {
    ThrowError("No round types are registered");
    return -1;
  }

  if (!IsPlayer(client1) || !IsPlayer(client2)) {
    return 0;
  }

  ArrayList types = new ArrayList();
  for (int roundType = 0; roundType < g_numRoundTypes; roundType++) {
    if (!g_RoundTypeEnabled[roundType])
      continue;

    if (!g_RoundTypeOptional[roundType]) {
      AddRounds(types, client1, client2, roundType);
    } else {
      AddRounds_CheckAllowed(types, client1, client2, roundType);
    }
  }

  int choice = 0;
  if (GetArraySize(types) > 0) {
    int index = GetArrayRandomIndex(types);
    choice = GetArrayCell(types, index);
  }
  delete types;

  Call_StartForward(g_hOnRoundTypeDecided);
  Call_PushCell(arena);
  Call_PushCell(client1);
  Call_PushCell(client2);
  Call_PushCellRef(choice);
  Call_Finish();

  return choice;
}

static void AddRounds(ArrayList types, int client1, int client2, int roundType) {
  int weight = 1;

  int prefWeight = g_PreferenceWeightCvar.IntValue;
  if (g_Preference[client1] == roundType)
    weight += prefWeight;
  if (g_Preference[client2] == roundType)
    weight += prefWeight;

  PushArrayCellReplicated(types, roundType, weight);
}

static void AddRounds_CheckAllowed(ArrayList types, int client1, int client2, int roundType) {
  if (g_AllowedRoundTypes[client1][roundType] && g_AllowedRoundTypes[client2][roundType]) {
    AddRounds(types, client1, client2, roundType);
  }
}

public int AddRoundType(Handle pluginSource, const char[] displayName, const char[] internalName,
                 RoundTypeWeaponHandler weaponHandler, bool optional, bool ranked,
                 const char[] ratingFieldName, bool enabled) {
  if (g_numRoundTypes >= MAX_ROUND_TYPES) {
    LogError("Tried to add new round when %d round types already added", MAX_ROUND_TYPES);
    return -1;
  }

  g_RoundTypeSourcePlugin[g_numRoundTypes] = pluginSource;
  strcopy(g_RoundTypeDisplayNames[g_numRoundTypes], ROUND_TYPE_NAME_LENGTH, displayName);
  String_ToLower(internalName, g_RoundTypeNames[g_numRoundTypes], ROUND_TYPE_NAME_LENGTH);
  g_RoundTypeWeaponHandlers[g_numRoundTypes] = weaponHandler;
  g_RoundTypeOptional[g_numRoundTypes] = optional;
  g_RoundTypeRanked[g_numRoundTypes] = ranked;
  strcopy(g_RoundTypeFieldNames[g_numRoundTypes], ROUND_TYPE_NAME_LENGTH, ratingFieldName);
  g_RoundTypeEnabled[g_numRoundTypes] = enabled;
  g_numRoundTypes++;
  return g_numRoundTypes - 1;
}

/*************************
 *                       *
 *  Default round types  *
 *                       *
 *************************/

public void AddStandardRounds() {
  AddRoundType(INVALID_HANDLE, "Rifle", "rifle", RifleHandler, false, true, "rifleRating", true);
  AddRoundType(INVALID_HANDLE, "Pistol", "pistol", PistolHandler, true, true, "pistolRating", true);
  AddRoundType(INVALID_HANDLE, "AWP", "awp", AwpHandler, true, true, "awpRating", true);
}

public void RifleHandler(int client) {
  GiveWeapon(client, g_PrimaryWeapon[client]);
  Client_SetHelmet(client, true);
  Client_SetArmor(client, 100);

  int pistolBehavior = g_PistolBehaviorCvar.IntValue;
  if (pistolBehavior == 0 || pistolBehavior == 3) {
    GiveWeapon(client, g_SecondaryWeapon[client]);
  } else if (pistolBehavior == 2) {
    char defaultPistol[WEAPON_NAME_LENGTH];
    g_DefaultPistolCvar.GetString(defaultPistol, sizeof(defaultPistol));
    GiveWeapon(client, defaultPistol);
  }
  Multi1v1_GivePlayerKnife(client);
}

public void PistolHandler(int client) {
  GiveWeapon(client, g_SecondaryWeapon[client]);
  Client_SetHelmet(client, false);
  bool giveKevlar = IsDefaultPistol(g_SecondaryWeapon[client]);
  if (giveKevlar) {
    Client_SetArmor(client, 100);
  } else {
    Client_SetArmor(client, 0);
  }
  Multi1v1_GivePlayerKnife(client);
}

public void AwpHandler(int client) {
  GiveWeapon(client, "weapon_awp");
  Client_SetHelmet(client, true);

  int pistolBehavior = g_PistolBehaviorCvar.IntValue;
  if (pistolBehavior == 0) {
    GiveWeapon(client, g_SecondaryWeapon[client]);
  } else if (pistolBehavior == 2 || pistolBehavior == 3) {
    char defaultPistol[WEAPON_NAME_LENGTH];
    g_DefaultPistolCvar.GetString(defaultPistol, sizeof(defaultPistol));
    GiveWeapon(client, defaultPistol);
  }
  Multi1v1_GivePlayerKnife(client);
}
