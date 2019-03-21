/**
 * Some generic helpers functions.
 */

public bool IsGrenadeProjectile(const char[] className) {
  static char projectileTypes[][] = {
      "hegrenade_projectile", "smokegrenade_projectile", "decoy_projectile",
      "flashbang_projectile", "molotov_projectile",
  };

  return FindStringInArray2(projectileTypes, sizeof(projectileTypes), className) >= 0;
}

public bool IsGrenadeWeapon(const char[] weapon) {
  static char grenades[][] = {
      "weapon_incgrenade", "weapon_molotov",   "weapon_hegrenade",
      "weapon_decoy",      "weapon_flashbang", "weapon_smokegrenade",
  };

  return FindStringInArray2(grenades, sizeof(grenades), weapon) >= 0;
}

stock void TeleportToGrenadeHistoryPosition(int client, int index,
                                            MoveType moveType = MOVETYPE_WALK) {
  float origin[3];
  float angles[3];
  float velocity[3];
  g_GrenadeHistoryPositions[client].GetArray(index, origin, sizeof(origin));
  g_GrenadeHistoryAngles[client].GetArray(index, angles, sizeof(angles));
  TeleportEntity(client, origin, angles, velocity);
  SetEntityMoveType(client, moveType);
}

public bool FindId(const char[] idStr, char[] auth, int authLen) {
  if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
    do {
      g_GrenadeLocationsKv.GetSectionName(auth, authLen);

      // Inner iteration by grenades for a user.
      if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
        do {
          char currentId[GRENADE_ID_LENGTH];
          g_GrenadeLocationsKv.GetSectionName(currentId, sizeof(currentId));
          if (StrEqual(idStr, currentId)) {
            g_GrenadeLocationsKv.Rewind();
            return true;
          }
        } while (g_GrenadeLocationsKv.GotoNextKey());
        g_GrenadeLocationsKv.GoBack();
      }

    } while (g_GrenadeLocationsKv.GotoNextKey());
    g_GrenadeLocationsKv.GoBack();
  }

  return false;
}

public bool TryJumpToId(const char[] idStr) {
  char auth[AUTH_LENGTH];
  if (FindId(idStr, auth, sizeof(auth))) {
    g_GrenadeLocationsKv.JumpToKey(auth, true);
    g_GrenadeLocationsKv.JumpToKey(idStr, true);
    return true;
  }

  return false;
}

public bool TryJumpToOwnerId(const char[] idStr, char[] ownerAuth, int authLength, char[] ownerName,
                      int nameLength) {
  if (FindId(idStr, ownerAuth, authLength)) {
    g_GrenadeLocationsKv.JumpToKey(ownerAuth, true);
    g_GrenadeLocationsKv.GetString("name", ownerName, nameLength);
    g_GrenadeLocationsKv.JumpToKey(idStr, true);
    return true;
  }

  return false;
}

public bool TeleportToSavedGrenadePosition(int client, const char[] id) {
  float origin[3];
  float angles[3];
  float velocity[3];
  char description[GRENADE_DESCRIPTION_LENGTH];
  char category[GRENADE_CATEGORY_LENGTH];
  bool success = false;
  float delay = 0.0;
  char typeString[32];
  GrenadeType type = GrenadeType_None;

  // Update the client's current grenade id.
  g_CurrentSavedGrenadeId[client] = StringToInt(id);

  char targetAuth[AUTH_LENGTH];
  char targetName[MAX_NAME_LENGTH];
  if (TryJumpToOwnerId(id, targetAuth, sizeof(targetAuth), targetName, sizeof(targetName))) {
    char grenadeName[GRENADE_NAME_LENGTH];
    success = true;
    g_GrenadeLocationsKv.GetVector("origin", origin);
    g_GrenadeLocationsKv.GetVector("angles", angles);
    g_GrenadeLocationsKv.GetString("name", grenadeName, sizeof(grenadeName));
    g_GrenadeLocationsKv.GetString("description", description, sizeof(description));
    g_GrenadeLocationsKv.GetString("categories", category, sizeof(category));
    g_GrenadeLocationsKv.GetString("grenadeType", typeString, sizeof(typeString));
    type = GrenadeTypeFromString(typeString);
    delay = g_GrenadeLocationsKv.GetFloat("delay");
    TeleportEntity(client, origin, angles, velocity);
    SetEntityMoveType(client, MOVETYPE_WALK);
    PM_Message(client, "Teleporting to grenade id %s, \"%s\".", id, grenadeName);

    if (!StrEqual(description, "")) {
      PM_Message(client, "Description: %s", description);
    }

    if (!StrEqual(category, "")) {
      ReplaceString(category, sizeof(category), ";", ", ");
      // Cut off the last two characters of the category string to avoid
      // an extraneous comma and space.
      // Only do this for strings sufficiently long, since the data may have been changed by users.
      int len = strlen(category);
      if (len >= 2 && category[len - 2] == ';') {
        category[len - 2] = '\0';
      }
      PM_Message(client, "Categories: %s", category);
    }

    if (delay > 0.0) {
      PM_Message(client, "Grenade delay: %.1f seconds", delay);
    }

    if (type != GrenadeType_None && GetSetting(client, UserSetting_SwitchToNadeOnSelect)) {
      char weaponName[64];
      GetGrenadeWeapon(type, weaponName, sizeof(weaponName));
      FakeClientCommand(client, "use %s", weaponName);

      // This is a dirty hack since saved nade data doesn't differentiate between a inc and molotov
      // grenade. See the problem in GrenadeFromProjectileName in csutils.inc. If that is fixed this
      // can be removed.
      if (type == GrenadeType_Molotov) {
        FakeClientCommand(client, "use weapon_incgrenade");
      } else if (type == GrenadeType_Incendiary) {
        FakeClientCommand(client, "use weapon_molotov");
      }
    }

    g_GrenadeLocationsKv.Rewind();
  }

  return success;
}

stock bool ThrowGrenade(int client, const char[] id, float delay = 0.0) {
  if (!g_CSUtilsLoaded) {
    return false;
  }

  char typeString[32];
  float grenadeOrigin[3];
  float grenadeVelocity[3];
  char auth[AUTH_LENGTH];
  bool success = false;

  if (!FindId(id, auth, sizeof(auth))) {
    return false;
  }

  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      g_GrenadeLocationsKv.GetVector("grenadeOrigin", grenadeOrigin);
      g_GrenadeLocationsKv.GetVector("grenadeVelocity", grenadeVelocity);
      g_GrenadeLocationsKv.GetString("grenadeType", typeString, sizeof(typeString));
      GrenadeType type = GrenadeTypeFromString(typeString);
      if (IsGrenade(type)) {
        success = true;
        if (delay > 0.1) {
          CSU_DelayThrowGrenade(delay, 0, type, grenadeOrigin, grenadeVelocity);
        } else {
          CSU_ThrowGrenade(client, type, grenadeOrigin, grenadeVelocity);
        }
      }
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }

  return success;
}

stock int SaveGrenadeToKv(int client, const float origin[3], const float angles[3],
                          const float grenadeOrigin[3], const float grenadeVelocity[3],
                          GrenadeType type, const char[] name, const char[] description = "",
                          const char[] categoryString = "") {
  g_UpdatedGrenadeKv = true;
  char idStr[GRENADE_ID_LENGTH];
  IntToString(g_NextID, idStr, sizeof(idStr));

  char auth[AUTH_LENGTH];
  char clientName[MAX_NAME_LENGTH];
  GetClientAuthId(client, AUTH_METHOD, auth, sizeof(auth));
  GetClientName(client, clientName, sizeof(clientName));
  g_GrenadeLocationsKv.JumpToKey(auth, true);
  g_GrenadeLocationsKv.SetString("name", clientName);

  g_GrenadeLocationsKv.JumpToKey(idStr, true);

  g_GrenadeLocationsKv.SetString("name", name);
  g_GrenadeLocationsKv.SetVector("origin", origin);
  g_GrenadeLocationsKv.SetVector("angles", angles);
  if (g_CSUtilsLoaded && IsGrenade(type)) {
    char grenadeTypeString[32];
    GrenadeTypeString(type, grenadeTypeString, sizeof(grenadeTypeString));
    g_GrenadeLocationsKv.SetString("grenadeType", grenadeTypeString);
    g_GrenadeLocationsKv.SetVector("grenadeOrigin", grenadeOrigin);
    g_GrenadeLocationsKv.SetVector("grenadeVelocity", grenadeVelocity);
  }
  g_GrenadeLocationsKv.SetString("description", description);
  g_GrenadeLocationsKv.SetString("categories", categoryString);

  g_GrenadeLocationsKv.GoBack();
  g_GrenadeLocationsKv.GoBack();
  g_NextID++;
  return g_NextID - 1;
}

public bool DeleteGrenadeFromKv(const char[] nadeIdStr) {
  g_UpdatedGrenadeKv = true;
  char auth[AUTH_LENGTH];
  FindId(nadeIdStr, auth, sizeof(auth));
  bool deleted = false;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    char name[GRENADE_NAME_LENGTH];
    if (g_GrenadeLocationsKv.JumpToKey(nadeIdStr)) {
      g_GrenadeLocationsKv.GetString("name", name, sizeof(name));
      g_GrenadeLocationsKv.GoBack();
    }

    deleted = g_GrenadeLocationsKv.DeleteKey(nadeIdStr);
    g_GrenadeLocationsKv.GoBack();
  }

  // If the grenade deleted has the highest grenadeId, reset nextid to it so that
  // we don't waste spots in the greandeId-space.
  if (deleted) {
    if (StringToInt(nadeIdStr) + 1 == g_NextID) {
      g_NextID--;
    }
  }

  return deleted;
}

public bool FindTargetNameByAuth(const char[] inputAuth, char[] name, int nameLen) {
  if (g_GrenadeLocationsKv.JumpToKey(inputAuth, false)) {
    g_GrenadeLocationsKv.GetString("name", name, nameLen);
    g_GrenadeLocationsKv.GoBack();
    return true;
  }
  return false;
}

public void AddGrenadeToHistory(int client) {
  if (GetArraySize(g_GrenadeHistoryPositions[client]) >= g_MaxHistorySizeCvar.IntValue) {
    RemoveFromArray(g_GrenadeHistoryPositions[client], 0);
    RemoveFromArray(g_GrenadeHistoryAngles[client], 0);
  }

  float position[3];
  float angles[3];
  GetClientAbsOrigin(client, position);
  GetClientEyeAngles(client, angles);
  PushArrayArray(g_GrenadeHistoryPositions[client], position, sizeof(position));
  PushArrayArray(g_GrenadeHistoryAngles[client], angles, sizeof(angles));
  g_GrenadeHistoryIndex[client] = g_GrenadeHistoryPositions[client].Length;
}

public bool FindTargetInGrenadesKvByName(const char[] inputName, char[] name, int nameLen, char[] auth,
                                  int authLen) {
  if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
    do {
      g_GrenadeLocationsKv.GetSectionName(auth, authLen);
      g_GrenadeLocationsKv.GetString("name", name, nameLen);

      if (StrContains(name, inputName, false) != -1) {
        g_GrenadeLocationsKv.GoBack();
        return true;
      }

    } while (g_GrenadeLocationsKv.GotoNextKey());
    g_GrenadeLocationsKv.GoBack();
  }
  return false;
}

public void SetGrenadeData(const char[] auth, const char[] id, const char[] key, const char[] value) {
  g_UpdatedGrenadeKv = true;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      g_GrenadeLocationsKv.SetString(key, value);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
}

public void SetGrenadeInt(const char[] auth, const char[] id, const char[] key, int value) {
  g_UpdatedGrenadeKv = true;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      g_GrenadeLocationsKv.SetNum(key, value);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
}

public void SetGrenadeFloat(const char[] auth, const char[] id, const char[] key, float value) {
  g_UpdatedGrenadeKv = true;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      g_GrenadeLocationsKv.SetFloat(key, value);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
}

public void GetGrenadeData(const char[] auth, const char[] id, const char[] key, char[] value,
                    int valueLength) {
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      g_GrenadeLocationsKv.GetString(key, value, valueLength);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
}

public int GetGrenadeInt(const char[] auth, const char[] id, const char[] key) {
  int value = 0;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      value = g_GrenadeLocationsKv.GetNum(key);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
  return value;
}

public float GetGrenadeFloat(const char[] auth, const char[] id, const char[] key) {
  float value = 0.0;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      value = g_GrenadeLocationsKv.GetFloat(key);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
  return value;
}

public void GetGrenadeVector(const char[] auth, const char[] id, const char[] key, float vector[3]) {
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      g_GrenadeLocationsKv.GetVector(key, vector);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
}

public void SetGrenadeVectors(const char[] auth, const char[] id, const float[3] origin,
                       const float[3] angles) {
  g_UpdatedGrenadeKv = true;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      g_GrenadeLocationsKv.SetVector("origin", origin);
      g_GrenadeLocationsKv.SetVector("angles", angles);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
}

public void SetGrenadeParameters(const char[] auth, const char[] id, GrenadeType type,
                          const float[3] grenadeOrigin, const float[3] grenadeVelocity) {
  if (!IsGrenade(type)) {
    return;
  }

  g_UpdatedGrenadeKv = true;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.JumpToKey(id)) {
      char typeString[32];
      GrenadeTypeString(type, typeString, sizeof(typeString));
      g_GrenadeLocationsKv.SetString("grenadeType", typeString);
      g_GrenadeLocationsKv.SetVector("grenadeOrigin", grenadeOrigin);
      g_GrenadeLocationsKv.SetVector("grenadeVelocity", grenadeVelocity);
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
}

public void SetClientGrenadeData(int id, const char[] key, const char[] value) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  SetGrenadeData(auth, nadeId, key, value);
}

public void GetClientGrenadeData(int id, const char[] key, char[] value, int valueLength) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  GetGrenadeData(auth, nadeId, key, value, valueLength);
}

public void SetClientGrenadeInt(int id, const char[] key, int value) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  SetGrenadeInt(auth, nadeId, key, value);
}

public int GetClientGrenadeInt(int id, const char[] key) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  return GetGrenadeInt(auth, nadeId, key);
}

public void SetClientGrenadeFloat(int id, const char[] key, float value) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  SetGrenadeFloat(auth, nadeId, key, value);
}

public float GetClientGrenadeFloat(int id, const char[] key) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  return GetGrenadeFloat(auth, nadeId, key);
}

public void SetClientGrenadeVectors(int id, const float[3] origin, const float[3] angles) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  SetGrenadeVectors(auth, nadeId, origin, angles);
}

public void SetClientGrenadeParameters(int id, GrenadeType type, const float[3] grenadeOrigin,
                                const float[3] grenadeVelocity) {
  char auth[AUTH_LENGTH];
  char nadeId[GRENADE_ID_LENGTH];
  IntToString(id, nadeId, sizeof(nadeId));
  FindId(nadeId, auth, sizeof(auth));
  SetGrenadeParameters(auth, nadeId, type, grenadeOrigin, grenadeVelocity);
}

public void UpdateGrenadeName(int id, const char[] name) {
  SetClientGrenadeData(id, "name", name);
}

public void UpdateGrenadeDescription(int id, const char[] description) {
  SetClientGrenadeData(id, "description", description);
}

public void AddGrenadeCategory(int id, const char[] category) {
  char categoryString[GRENADE_CATEGORY_LENGTH];
  GetClientGrenadeData(id, "categories", categoryString, sizeof(categoryString));

  if (StrContains(categoryString, category, false) >= 0) {
    return;
  }

  StrCat(categoryString, sizeof(categoryString), category);
  StrCat(categoryString, sizeof(categoryString), ";");
  SetClientGrenadeData(id, "categories", categoryString);

  CheckNewCategory(category);
}

public bool RemoveGrenadeCategory(int id, const char[] category) {
  char categoryString[GRENADE_CATEGORY_LENGTH];
  GetClientGrenadeData(id, "categories", categoryString, sizeof(categoryString));

  char removeString[GRENADE_CATEGORY_LENGTH];
  Format(removeString, sizeof(removeString), "%s;", category);

  int numreplaced = ReplaceString(categoryString, sizeof(categoryString), removeString, "", false);
  SetClientGrenadeData(id, "categories", categoryString);
  return numreplaced > 0;
}

public int DeleteGrenadeCategory(int client, const char[] category) {
  char auth[AUTH_LENGTH];
  GetClientAuthId(client, AUTH_METHOD, auth, sizeof(auth));
  ArrayList ids = new ArrayList();

  char grenadeId[GRENADE_ID_LENGTH];
  if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
    do {
      if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
        do {
          g_GrenadeLocationsKv.GetSectionName(grenadeId, sizeof(grenadeId));
          if (CanEditGrenade(client, StringToInt(grenadeId))) {
            ids.Push(StringToInt(grenadeId));
          }
        } while (g_GrenadeLocationsKv.GotoNextKey());
        g_GrenadeLocationsKv.GoBack();
      }
    } while (g_GrenadeLocationsKv.GotoNextKey());
    g_GrenadeLocationsKv.GoBack();
  }

  int count = 0;
  for (int i = 0; i < ids.Length; i++) {
    if (RemoveGrenadeCategory(ids.Get(i), category)) {
      count++;
    }
  }

  return count;
}

public bool FindGrenadeTarget(const char[] nameInput, char[] name, int nameLen, char[] auth, int authLen) {
  int target = AttemptFindTarget(nameInput);
  if (IsPlayer(target) && GetClientAuthId(target, AUTH_METHOD, auth, authLen) &&
      GetClientName(target, name, nameLen)) {
    return true;
  } else {
    return FindTargetInGrenadesKvByName(nameInput, name, nameLen, auth, authLen);
  }
}

public bool FindMatchingCategory(const char[] catinput, char[] output, int length) {
  char[] lastMatching = new char[length];
  int matchingCount = 0;

  for (int i = 0; i < g_KnownNadeCategories.Length; i++) {
    char cat[GRENADE_CATEGORY_LENGTH];
    g_KnownNadeCategories.GetString(i, cat, sizeof(cat));
    if (StrEqual(cat, catinput, false)) {
      strcopy(output, length, cat);
      return true;
    }

    if (StrContains(cat, catinput, false) >= 0) {
      strcopy(lastMatching, length, cat);
      matchingCount++;
    }
  }

  if (matchingCount == 1) {
    strcopy(output, length, lastMatching);
    return true;
  } else {
    return false;
  }
}

public int CountGrenadesForPlayer(const char[] auth) {
  int count = 0;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
      do {
        count++;
      } while (g_GrenadeLocationsKv.GotoNextKey());

      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
  return count;
}

public void FindGrenadeCategories() {
  IterateGrenades(_FindGrenadeCategories_Helper);
}

public Action _FindGrenadeCategories_Helper(const char[] ownerName, const char[] ownerAuth,
                                     const char[] name, const char[] description, ArrayList cats,
                                     const char[] grenadeId, const float origin[3],
                                     const float angles[3], any data) {
  for (int i = 0; i < cats.Length; i++) {
    char cat[64];
    cats.GetString(i, cat, sizeof(cat));
    CheckNewCategory(cat);
  }
  return Plugin_Continue;
}

public void CheckNewCategory(const char[] cat) {
  if (!StrEqual(cat, "") &&
      FindStringInList(g_KnownNadeCategories, GRENADE_CATEGORY_LENGTH, cat, false) == -1) {
    g_KnownNadeCategories.PushString(cat);
    SortADTArray(g_KnownNadeCategories, Sort_Ascending, Sort_String);
  }
}

public int AddCategoriesToList(const char[] categoryString, ArrayList list) {
  const int maxCats = 10;
  const int catSize = 64;
  char parts[maxCats][catSize];
  int foundCats = ExplodeString(categoryString, ";", parts, maxCats, catSize);
  for (int i = 0; i < foundCats; i++) {
    if (!StrEqual(parts[i], ""))
      list.PushString(parts[i]);
  }
  return foundCats;
}

public void TranslateGrenades(float dx, float dy, float dz) {
  DataPack p = CreateDataPack();
  p.WriteFloat(dx);
  p.WriteFloat(dy);
  p.WriteFloat(dz);
  g_UpdatedGrenadeKv = true;
  IterateGrenades(TranslateGrenadeHelper, p);
  delete p;
}

public Action TranslateGrenadeHelper(const char[] ownerName, const char[] ownerAuth, const char[] name,
                              const char[] description, ArrayList categories,
                              const char[] grenadeId, float origin[3], float angles[3], any data) {
  DataPack p = view_as<DataPack>(data);
  p.Reset();
  float dx = p.ReadFloat();
  float dy = p.ReadFloat();
  float dz = p.ReadFloat();
  origin[0] += dx;
  origin[1] += dy;
  origin[2] += dz;
}

public int FindNextGrenadeId(int client, int currentId) {
  char auth[AUTH_LENGTH];
  GetClientAuthId(client, AUTH_METHOD, auth, sizeof(auth));

  int ret = -1;
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
      do {
        char idBuffer[GRENADE_ID_LENGTH];
        g_GrenadeLocationsKv.GetSectionName(idBuffer, sizeof(idBuffer));
        int id = StringToInt(idBuffer);
        if (id > currentId) {
          ret = id;
          break;
        }
      } while (g_GrenadeLocationsKv.GotoNextKey());
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }

  return ret;
}

public int CopyGrenade(const char[] ownerAuth, const char[] nadeId, int client) {
  float origin[3];
  float angles[3];
  float grenadeOrigin[3];
  float grenadeVelocity[3];
  char grenadeTypeString[32];
  char grenadeName[GRENADE_NAME_LENGTH];
  char description[GRENADE_DESCRIPTION_LENGTH];
  char categoryString[GRENADE_CATEGORY_LENGTH];
  bool success = false;

  if (g_GrenadeLocationsKv.JumpToKey(ownerAuth)) {
    if (g_GrenadeLocationsKv.JumpToKey(nadeId)) {
      success = true;
      g_GrenadeLocationsKv.GetVector("origin", origin);
      g_GrenadeLocationsKv.GetVector("angles", angles);
      g_GrenadeLocationsKv.GetVector("grenadeOrigin", grenadeOrigin);
      g_GrenadeLocationsKv.GetVector("grenadeVelocity", grenadeVelocity);
      g_GrenadeLocationsKv.GetString("grenadeType", grenadeTypeString, sizeof(grenadeTypeString));
      g_GrenadeLocationsKv.GetString("name", grenadeName, sizeof(grenadeName));
      g_GrenadeLocationsKv.GetString("description", description, sizeof(description));
      g_GrenadeLocationsKv.GetString("categories", categoryString, sizeof(categoryString));
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }

  if (success) {
    return SaveGrenadeToKv(client, origin, angles, grenadeOrigin, grenadeVelocity,
                           GrenadeTypeFromString(grenadeTypeString), grenadeName, description,
                           categoryString);
  } else {
    return -1;
  }
}

// Normalizes grenade ids so they are unique across all users.
// Grenades ids previously always started at 0 for each client, this translates the ids so
// that they start at 0 globally (for all users). This translation is done for to guarantee
// that uniqueness, and has to stay for backwards compatibility.
static KeyValues g_NewKv;

static ArrayList g_AllIds;
static bool g_RepeatIdSeen;

public void MaybeCorrectGrenadeIds() {
  // Determine if we need to do this first. Iterate over all grenades and store the ids as an int.
  // If we see a repeat, then we need to do the correction.
  g_AllIds = new ArrayList();
  g_RepeatIdSeen = false;
  IterateGrenades(IsCorrectionNeededHelper);

  // But first... let's make sure the nextid field is always right.
  SortADTArray(g_AllIds, Sort_Ascending, Sort_Integer);
  int biggestID = 0;
  if (g_AllIds.Length > 0) {
    biggestID = g_AllIds.Get(g_AllIds.Length - 1);
  }
  g_NextID = biggestID + 1;

  delete g_AllIds;

  if (g_RepeatIdSeen) {
    CorrectGrenadeIds();
  }
}

public Action IsCorrectionNeededHelper(const char[] ownerName, const char[] ownerAuth, const char[] name,
                                const char[] description, ArrayList categories,
                                const char[] grenadeId, float origin[3], float angles[3],
                                any data) {
  int id = StringToInt(grenadeId);
  if (g_AllIds.FindValue(id) >= 0) {
    g_RepeatIdSeen = true;
  }
  g_AllIds.Push(id);
}

public void CorrectGrenadeIds() {
  // We'll do the correction; use a temp kv structure to copy data over using new ids and
  // swap it into the existing g_GrenadeLocationsKv structure.
  LogMessage("Updating grenadeIds since duplicates were found...");
  g_NewKv = new KeyValues("Grenades");
  g_NextID = 1;
  IterateGrenades(CorrectGrenadeIdsHelper);

  // Move the temp g_NewKv to replace data in g_GrenadeLocationsKv.
  delete g_GrenadeLocationsKv;
  g_GrenadeLocationsKv = g_NewKv;
  g_NewKv = null;
  g_UpdatedGrenadeKv = true;
}

public Action CorrectGrenadeIdsHelper(const char[] ownerName, const char[] ownerAuth, const char[] name,
                               const char[] description, ArrayList categories,
                               const char[] grenadeId, float origin[3], float angles[3], any data) {
  char newId[64];
  IntToString(g_NextID, newId, sizeof(newId));
  g_NextID++;

  char categoryString[GRENADE_CATEGORY_LENGTH];
  for (int i = 0; i < categories.Length; i++) {
    char tempCat[GRENADE_CATEGORY_LENGTH];
    categories.GetString(i, tempCat, sizeof(tempCat));
    StrCat(categoryString, sizeof(categoryString), tempCat);
    StrCat(categoryString, sizeof(categoryString), ";");
  }

  if (g_NewKv.JumpToKey(ownerAuth, true)) {
    g_NewKv.SetString("name", ownerName);
    if (g_NewKv.JumpToKey(newId, true)) {
      g_NewKv.SetString("name", name);
      g_NewKv.SetVector("origin", origin);
      g_NewKv.SetVector("angles", angles);
      g_NewKv.SetString("description", description);
      g_NewKv.SetString("categories", categoryString);
      g_NewKv.GoBack();
    }
  }
  g_NewKv.Rewind();
}

public bool CanEditGrenade(int client, int id) {
  if (!CheckCommandAccess(client, "sm_gotogrenade", ADMFLAG_CHANGEMAP)) {
    return false;
  }

  if (g_SharedAllNadesCvar.IntValue != 0) {
    return true;
  }

  char strId[32];
  IntToString(id, strId, sizeof(strId));
  char clientAuth[AUTH_LENGTH];
  GetClientAuthId(client, AUTH_METHOD, clientAuth, sizeof(clientAuth));
  char ownerAuth[AUTH_LENGTH];
  return FindId(strId, ownerAuth, sizeof(ownerAuth)) && StrEqual(clientAuth, ownerAuth, false);
}
