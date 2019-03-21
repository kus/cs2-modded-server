stock void GivePracticeMenu(int client, int style = ITEMDRAW_DEFAULT, int pos = -1) {
  Menu menu = new Menu(PracticeMenuHandler);
  SetMenuTitle(menu, "Practice Settings");
  SetMenuExitButton(menu, true);

  if (!g_InPracticeMode) {
    bool canLaunch =
        CanStartPracticeMode(client) && CheckCommandAccess(client, "sm_prac", ADMFLAG_CHANGEMAP);
    AddMenuItem(menu, "launch_practice", "Start practice mode", EnabledIf(canLaunch));
    style = ITEMDRAW_DISABLED;
  } else {
    AddMenuItem(menu, "end_menu", "Exit practice mode", style);
  }

  if (LibraryExists("get5")) {
    AddMenuItem(menu, "get5", "Get5 options");
  }

  for (int i = 0; i < g_BinaryOptionNames.Length; i++) {
    if (!g_BinaryOptionChangeable.Get(i)) {
      continue;
    }

    char name[OPTION_NAME_LENGTH];
    g_BinaryOptionNames.GetString(i, name, sizeof(name));

    char enabled[32];
    GetEnabledString(enabled, sizeof(enabled), g_BinaryOptionEnabled.Get(i), client);

    char buffer[128];
    Format(buffer, sizeof(buffer), "%s: %s", name, enabled);
    AddMenuItem(menu, name, buffer, style);
  }

  if (pos == -1) {
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
  } else {
    DisplayMenuAtItem(menu, client, pos, MENU_TIME_FOREVER);
  }
}

public int PracticeMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    char buffer[OPTION_NAME_LENGTH];
    int pos = GetMenuSelectionPosition();
    menu.GetItem(param2, buffer, sizeof(buffer));

    for (int i = 0; i < g_BinaryOptionNames.Length; i++) {
      char name[OPTION_NAME_LENGTH];
      g_BinaryOptionNames.GetString(i, name, sizeof(name));
      if (StrEqual(name, buffer)) {
        bool setting = !g_BinaryOptionEnabled.Get(i);
        ChangeSetting(i, setting);
        GivePracticeMenu(client, ITEMDRAW_DEFAULT, pos);
        return 0;
      }
    }

    if (StrEqual(buffer, "launch_practice")) {
      LaunchPracticeMode();
      GivePracticeMenu(client);
    }
    if (StrEqual(buffer, "get5")) {
      FakeClientCommand(client, "sm_get5");
    }
    if (StrEqual(buffer, "end_menu")) {
      ExitPracticeMode();
      if (g_PugsetupLoaded) {
        PugSetup_GiveSetupMenu(client);
      }
    }

  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

stock void GiveGrenadeMenu(int client, GrenadeMenuType type, int position = 0,
                           const char[] data = "", ArrayList ids = null,
                           GrenadeMenuType forceMatch = GrenadeMenuType_Invalid) {
  g_ClientLastMenuType[client] = type;
  strcopy(g_ClientLastMenuData[client], AUTH_LENGTH, data);

  if (type == GrenadeMenuType_PlayersAndCategories || type == GrenadeMenuType_Categories) {
    g_ClientLastTopMenuType[client] = type;
    strcopy(g_ClientLastTopMenuData[client], AUTH_LENGTH, data);
  }

  Menu menu;
  int count = 0;
  if (type == GrenadeMenuType_PlayersAndCategories) {
    menu = new Menu(Grenade_PlayerAndCategoryHandler);
    menu.SetTitle("Select a player/category:");
    menu.AddItem("all", "All nades");
    count = AddPlayersToMenu(menu) + AddCategoriesToMenu(menu);

  } else if (type == GrenadeMenuType_Categories) {
    menu = new Menu(Grenade_PlayerAndCategoryHandler);
    menu.SetTitle("Select a category:");
    menu.AddItem("all", "All nades");
    count = AddCategoriesToMenu(menu);

    // Fall back to all nades.
    if (count == 0) {
      GiveGrenadeMenu(client, GrenadeMenuType_OneCategory, 0, "all");
      delete menu;
      return;
    }

  } else {
    menu = new Menu(Grenade_NadeHandler);
    bool deleteIds = false;
    if (ids == null) {
      deleteIds = true;
      char unused[128];
      ids = new ArrayList(GRENADE_ID_LENGTH);
      FindGrenades(data, ids, unused, sizeof(unused), forceMatch);
    }
    count = ids.Length;
    AddIdsToMenu(menu, ids);
    if (deleteIds) {
      delete ids;
    }

    if (type == GrenadeMenuType_OnePlayer) {
      char name[MAX_NAME_LENGTH];
      FindTargetNameByAuth(data, name, sizeof(name));
      menu.SetTitle("Grenades for %s:", name);
    } else if (type == GrenadeMenuType_OneCategory) {
      if (StrEqual(data, "") || StrEqual(data, "all")) {
        menu.SetTitle("All nades");
      } else {
        menu.SetTitle("Category: %s", data);
      }
    } else if (type == GrenadeMenuType_MatchingName) {
      menu.SetTitle("Nades matching %s", data);
    } else {
      menu.SetTitle("Nades:");
    }
  }

  if (count == 0) {
    PM_Message(client, "No grenades found.");
    delete menu;
    return;
  }

  menu.ExitButton = true;
  menu.ExitBackButton = true;
  menu.DisplayAt(client, position, MENU_TIME_FOREVER);
}

static int AddPlayersToMenu(Menu menu) {
  int count = 0;
  if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
    do {
      int nadeCount = 0;
      if (g_GrenadeLocationsKv.GotoFirstSubKey()) {
        do {
          nadeCount++;
        } while (g_GrenadeLocationsKv.GotoNextKey());
        g_GrenadeLocationsKv.GoBack();
      }

      char auth[AUTH_LENGTH];
      char name[MAX_NAME_LENGTH];
      g_GrenadeLocationsKv.GetSectionName(auth, sizeof(auth));
      g_GrenadeLocationsKv.GetString("name", name, sizeof(name));

      char info[256];
      Format(info, sizeof(info), "%s %s", auth, name);

      char display[256];
      Format(display, sizeof(display), "%s (%d saved)", name, nadeCount);
      if (nadeCount > 0) {
        count++;
        menu.AddItem(info, display);
      }

    } while (g_GrenadeLocationsKv.GotoNextKey());
    g_GrenadeLocationsKv.GoBack();
  }
  return count;
}

static int AddCategoriesToMenu(Menu menu) {
  int numCategories = 0;

  for (int i = 0; i < g_KnownNadeCategories.Length; i++) {
    char cat[64];
    g_KnownNadeCategories.GetString(i, cat, sizeof(cat));
    int categoryCount = CountCategoryNades(cat);

    char info[256];
    Format(info, sizeof(info), "cat %s", cat);
    char display[256];
    Format(display, sizeof(display), "Category: %s (%d saved)", cat, categoryCount);

    if (categoryCount > 0) {
      numCategories++;
      menu.AddItem(info, display);
    }
  }
  return numCategories;
}

static void AddIdsToMenu(Menu menu, ArrayList ids) {
  if (g_AlphabetizeNadeMenusCvar.BoolValue) {
    SortADTArrayCustom(ids, SortIdArrayByName);
  }

  char id[GRENADE_ID_LENGTH];
  char auth[AUTH_LENGTH];
  char name[MAX_NAME_LENGTH];
  for (int i = 0; i < ids.Length; i++) {
    ids.GetString(i, id, sizeof(id));
    if (TryJumpToOwnerId(id, auth, sizeof(auth), name, sizeof(name))) {
      // TODO: do we need the owner name here?
      AddKvGrenadeToMenu(menu, g_GrenadeLocationsKv, name);
      g_GrenadeLocationsKv.Rewind();
    }
  }
}

// Handlers for the grenades menu.

public int Grenade_PlayerAndCategoryHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select && g_InPracticeMode) {
    int client = param1;
    g_ClientLastTopMenuPos[client] = GetMenuSelectionPosition();
    char buffer[MAX_NAME_LENGTH + AUTH_LENGTH + 1];
    menu.GetItem(param2, buffer, sizeof(buffer));

    if (StrEqual(buffer, "all")) {
      GiveGrenadeMenu(client, GrenadeMenuType_OneCategory, 0, "all");
      return;
    }

    // split buffer from "auth name" (seperated by whitespace)
    char arg1[AUTH_LENGTH];      // 'cat' or ownerAuth
    char arg2[MAX_NAME_LENGTH];  // categoryName or ownerName
    SplitOnSpace(buffer, arg1, sizeof(arg1), arg2, sizeof(arg2));

    if (StrEqual(arg1, "cat")) {
      GiveGrenadeMenu(client, GrenadeMenuType_OneCategory, 0, arg2);
    } else {
      GiveGrenadeMenu(client, GrenadeMenuType_OnePlayer, 0, arg1);
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

public int Grenade_NadeHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select && g_InPracticeMode) {
    int client = param1;
    g_ClientLastMenuPos[client] = GetMenuSelectionPosition();
    HandleGrenadeSelected(client, menu, param2);
    if (GetSetting(client, UserSetting_LeaveNadeMenuOpen)) {
      GiveGrenadeMenu(client, g_ClientLastMenuType[client], g_ClientLastMenuPos[client],
                      g_ClientLastMenuData[client], null, g_ClientLastMenuType[client]);
    }
  } else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack) {
    int client = param1;
    GiveGrenadeMenu(client, g_ClientLastTopMenuType[client], g_ClientLastTopMenuPos[client],
                    g_ClientLastTopMenuData[client]);
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

int SortIdArrayByName(int index1, int index2, Handle array, Handle hndl) {
  // This code is totally pointless, but is harmless and there's no way to supress the warning
  // for hndl being unused. :/
  if (hndl != INVALID_HANDLE) {
    delete hndl;
  }

  char id1[GRENADE_ID_LENGTH];
  char id2[GRENADE_ID_LENGTH];
  GetArrayString(array, index1, id1, sizeof(id1));
  GetArrayString(array, index2, id2, sizeof(id2));

  char name1[GRENADE_DESCRIPTION_LENGTH];
  char name2[GRENADE_DESCRIPTION_LENGTH];

  if (TryJumpToId(id1)) {
    g_GrenadeLocationsKv.GetString("name", name1, sizeof(name1));
    g_GrenadeLocationsKv.Rewind();
  }
  if (TryJumpToId(id2)) {
    g_GrenadeLocationsKv.GetString("name", name2, sizeof(name2));
    g_GrenadeLocationsKv.Rewind();
  }

  return strcmp(name1, name2, false);
}

stock void AddGrenadeToMenu(Menu menu, const char[] ownerName, const char[] strId,
                            const char[] name, bool showPlayerName = false) {
  char display[128];
  if (showPlayerName && g_SharedAllNadesCvar.IntValue == 0 && !StrEqual(ownerName, "")) {
    Format(display, sizeof(display), "%s (%s-%s)", name, ownerName, strId);
  } else {
    Format(display, sizeof(display), "%s (id %s)", name, strId);
  }

  menu.AddItem(strId, display);
}

public void AddKvGrenadeToMenu(Menu menu, KeyValues kv, const char[] ownerName) {
  char name[GRENADE_NAME_LENGTH];
  char strId[GRENADE_ID_LENGTH];
  kv.GetSectionName(strId, sizeof(strId));
  kv.GetString("name", name, sizeof(name));
  AddGrenadeToMenu(menu, ownerName, strId, name);
}

public void HandleGrenadeSelected(int client, Menu menu, int param2) {
  char id[GRENADE_ID_LENGTH];
  menu.GetItem(param2, id, sizeof(id));
  TeleportToSavedGrenadePosition(client, id);
}

public int CountCategoryNades(const char[] category) {
  DataPack p = CreateDataPack();
  p.WriteCell(0);
  p.WriteString(category);
  IterateGrenades(_CountCategoryNades_Helper, p);
  p.Reset();
  int count = p.ReadCell();
  delete p;
  return count;
}

public Action _CountCategoryNades_Helper(const char[] ownerName, const char[] ownerAuth, const char[] name,
                                  const char[] description, ArrayList categories,
                                  const char[] grenadeId, const float origin[3],
                                  const float angles[3], any data) {
  DataPack p = view_as<DataPack>(data);
  ResetPack(p, false);
  int count = p.ReadCell();
  char cat[64];
  p.ReadString(cat, sizeof(cat));

  if (FindStringInList(categories, GRENADE_CATEGORY_LENGTH, cat, false) >= 0) {
    count++;
    ResetPack(p, true);
    p.WriteCell(count);
    p.WriteString(cat);
  }
}
