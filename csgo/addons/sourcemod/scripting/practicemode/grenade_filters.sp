// Generic utility to find a single grenade matching user input.
// Returns true if found.
public bool FindGrenade(const char[] input, char id[GRENADE_ID_LENGTH]) {
  // Match by id first.
  char auth[AUTH_LENGTH];
  if (FindId(input, auth, sizeof(auth))) {
    g_GrenadeLocationsKv.GoBack();
    strcopy(id, sizeof(id), input);
    return true;
  }

  // Then match by exact name.
  if (FindGrenadeByName(auth, input, id)) {
    return true;
  }

  // Then try substring, but it has to be unique.
  ArrayList substringMatches = new ArrayList(GRENADE_ID_LENGTH);
  if (FindMatchingGrenadesByName(input, substringMatches) && substringMatches.Length == 1) {
    substringMatches.GetString(0, id, sizeof(id));
    delete substringMatches;
    return true;
  }
  delete substringMatches;
  return false;
}

// Generic utility to find all grenades matching user input.
// Returns the filter type if found, otherwise GrenadeMenuType_Invalid.
stock GrenadeMenuType FindGrenades(const char[] input, ArrayList ids, char[] data, int len,
                                   GrenadeMenuType forceMatch = GrenadeMenuType_Invalid) {
  char id[GRENADE_ID_LENGTH];
  // Try a list of ids.
  if (forceMatch == GrenadeMenuType_Invalid || forceMatch == GrenadeMenuType_MatchingId) {
    int idx = 0;
    int cur_idx = 0;
    char auth[AUTH_LENGTH];
    while (idx >= 0) {
      idx = BreakString(input[cur_idx], id, sizeof(id));
      cur_idx += idx;
      if (FindId(id, auth, sizeof(auth))) {
        ids.PushString(id);
      }
    }
    if (ids.Length > 0) {
      strcopy(data, len, input);
      return GrenadeMenuType_MatchingId;
    }
  }

  // Try player name match first, and a steamid search.
  // data = auth.
  if (forceMatch == GrenadeMenuType_Invalid || forceMatch == GrenadeMenuType_MatchingName) {
    char name[MAX_NAME_LENGTH];
    if (strlen(input) >= 2 && FindGrenadeTarget(input, name, sizeof(name), data, len) &&
        FindPlayerNades(data, ids)) {
      return GrenadeMenuType_OnePlayer;
    }
    if (g_GrenadeLocationsKv.JumpToKey(input)) {
      g_GrenadeLocationsKv.GoBack();
      if (FindPlayerNades(input, ids)) {
        return GrenadeMenuType_OnePlayer;
      }
    }
  }

  // Then try a category match.
  // data = category name.

  if (forceMatch == GrenadeMenuType_Invalid || forceMatch == GrenadeMenuType_OneCategory) {
    if (StrEqual(input, "all", false)) {
      FindCategoryNades("all", ids);
      strcopy(data, len, "all");
      return GrenadeMenuType_OneCategory;
    }

    if (FindMatchingCategory(input, data, len) && FindCategoryNades(data, ids)) {
      return GrenadeMenuType_OneCategory;
    }
  }

  if (forceMatch == GrenadeMenuType_Invalid || forceMatch == GrenadeMenuType_MatchingName) {
    if (FindMatchingGrenadesByName(input, ids)) {
      strcopy(data, len, input);
      return GrenadeMenuType_MatchingName;
    }
  }

  return GrenadeMenuType_Invalid;
}

public bool FindPlayerNades(const char[] auth, ArrayList ids) {
  bool success = false;
  char id[GRENADE_ID_LENGTH];
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    success = true;
    if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
      do {
        g_GrenadeLocationsKv.GetSectionName(id, sizeof(id));
        ids.PushString(id);
      } while (g_GrenadeLocationsKv.GotoNextKey());
      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
  return success;
}

public bool FindCategoryNades(const char[] category, ArrayList ids) {
  bool success = false;
  char id[GRENADE_ID_LENGTH];
  bool allNades = StrEqual(category, "all", false);
  if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
    do {
      if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
        do {
          g_GrenadeLocationsKv.GetSectionName(id, sizeof(id));
          char categoryString[GRENADE_CATEGORY_LENGTH];
          g_GrenadeLocationsKv.GetString("categories", categoryString, sizeof(categoryString));
          ArrayList cats = new ArrayList(GRENADE_CATEGORY_LENGTH);
          AddCategoriesToList(categoryString, cats);
          if (allNades || FindStringInList(cats, GRENADE_CATEGORY_LENGTH, category, false) >= 0) {
            ids.PushString(id);
            success = true;
          }
          delete cats;
        } while (g_GrenadeLocationsKv.GotoNextKey());
        g_GrenadeLocationsKv.GoBack();
      }
    } while (g_GrenadeLocationsKv.GotoNextKey());
    g_GrenadeLocationsKv.GoBack();
  }
  return success;
}

public bool FindGrenadeByName(const char[] auth, const char[] lookupName,
                       char grenadeId[GRENADE_ID_LENGTH]) {
  char name[GRENADE_NAME_LENGTH];
  if (g_GrenadeLocationsKv.JumpToKey(auth)) {
    if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
      do {
        g_GrenadeLocationsKv.GetSectionName(grenadeId, sizeof(grenadeId));
        g_GrenadeLocationsKv.GetString("name", name, sizeof(name));
        if (StrEqual(name, lookupName)) {
          g_GrenadeLocationsKv.GoBack();
          g_GrenadeLocationsKv.GoBack();
          return true;
        }
      } while (g_GrenadeLocationsKv.GotoNextKey());

      g_GrenadeLocationsKv.GoBack();
    }
    g_GrenadeLocationsKv.GoBack();
  }
  return false;
}

public bool FindMatchingGrenadesByName(const char[] lookupName, ArrayList ids) {
  char auth[AUTH_LENGTH];
  char currentId[GRENADE_ID_LENGTH];
  char name[GRENADE_NAME_LENGTH];
  if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
    do {
      g_GrenadeLocationsKv.GetSectionName(auth, sizeof(auth));
      // Inner iteration by grenades for a user.
      if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
        do {
          g_GrenadeLocationsKv.GetSectionName(currentId, sizeof(currentId));
          g_GrenadeLocationsKv.GetString("name", name, sizeof(name));
          if (StrContains(name, lookupName, false) >= 0) {
            ids.PushString(currentId);
          }
        } while (g_GrenadeLocationsKv.GotoNextKey());
        g_GrenadeLocationsKv.GoBack();
      }

    } while (g_GrenadeLocationsKv.GotoNextKey());
    g_GrenadeLocationsKv.GoBack();
  }
  return ids.Length > 0;
}