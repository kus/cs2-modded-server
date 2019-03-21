/**
 * Opens up the weapon menu for a client.
 */
stock void GiveWeaponsMenu(int client, int position = 0) {
  g_GivenGunsMenu[client] = true;
  Menu menu = new Menu(WeaponsMenuHandler);
  menu.SetTitle("%T", "WeaponsMenuTitle", client);
  menu.ExitButton = true;

  if (g_RifleMenuCvar.IntValue != 0) {
    AddMenuOption(menu, "rifle", "%T", "WeaponsMenuRifle", client,
                  g_Rifles[GetRifleIndex(client)][1]);
  }

  if (g_PistolMenuCvar.IntValue != 0) {
    AddMenuOption(menu, "pistol", "%T", "WeaponsMenuPistol", client,
                  g_Pistols[GetPistolIndex(client)][1]);
  }

  char prefString[64];
  Format(prefString, sizeof(prefString), "%T", "WeaponsMenuPreferenceNone", client);

  int pref = g_Preference[client];
  if (pref >= 0 && (g_AllowedRoundTypes[client][pref] || !g_RoundTypeOptional[pref])) {
    Format(prefString, sizeof(prefString), "%T", "WeaponsMenuPreference", client,
           g_RoundTypeDisplayNames[pref]);
  }
  int style =
      (CountRoundTypesAvaliableToClient(client) >= 2) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
  AddMenuItem(menu, "pref", prefString, style);

  for (int i = 0; i < g_numRoundTypes; i++) {
    if (g_RoundTypeEnabled[i] && g_RoundTypeOptional[i]) {
      char enabledString[32];
      GetEnabledString(enabledString, sizeof(enabledString), g_AllowedRoundTypes[client][i],
                       client);

      char infostring[128];
      Format(infostring, sizeof(infostring), "allow%d", i);
      AddMenuOption(menu, infostring, "%T", "WeaponsMenuRoundTypeEnabled", client,
                    g_RoundTypeDisplayNames[i], enabledString);
    }
  }

  Call_StartForward(g_hOnGunsMenuCreated);
  Call_PushCell(client);
  Call_PushCell(menu);
  Call_Finish();

  menu.DisplayAt(client, position, MENU_TIME_FOREVER);
}

public int WeaponsMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  Call_StartForward(g_hGunsMenuCallback);
  Call_PushCell(menu);
  Call_PushCell(action);
  Call_PushCell(param1);
  Call_PushCell(param2);
  Call_Finish();

  if (action == MenuAction_Select) {
    int client = param1;
    char buffer[128];
    menu.GetItem(param2, buffer, sizeof(buffer));

    int pos = GetMenuSelectionPosition();

    if (StrEqual(buffer, "rifle")) {
      RifleChoiceMenu(client);

    } else if (StrEqual(buffer, "pistol")) {
      PistolChoiceMenu(client);

    } else if (StrEqual(buffer, "pref")) {
      GivePreferenceMenu(client);

    } else if (StrContains(buffer, "allow") == 0) {
      int roundType = StringToInt(buffer[5]);
      g_AllowedRoundTypes[client][roundType] = !g_AllowedRoundTypes[client][roundType];
      SetCookieBool(client, g_AllowedRoundTypeCookies[roundType],
                    g_AllowedRoundTypes[client][roundType]);
      GiveWeaponsMenu(client, pos);
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

/**
 * Displays the round-type preference menu to a client.
 */
public void GivePreferenceMenu(int client) {
  Menu menu = new Menu(MenuHandler_Preference);
  menu.SetTitle("%T", "WeaponsMenuPreferenceTitle", client);
  menu.ExitButton = false;
  menu.ExitBackButton = true;
  AddMenuInt(menu, -1, "%T", "WeaponsMenuNoPreference", client);

  for (int i = 0; i < g_numRoundTypes; i++) {
    if (!g_RoundTypeEnabled[i]) {
      continue;
    }

    if (g_AllowedRoundTypes[client][i] || !g_RoundTypeOptional[i]) {
      char buffer[128];
      Format(buffer, sizeof(buffer), "%T", "WeaponsMenuPreferenceChoice", client,
             g_RoundTypeDisplayNames[i]);
      AddMenuInt(menu, i, buffer);
    }
  }

  menu.Display(client, MENU_TIME_FOREVER);
}

static int CountRoundTypesAvaliableToClient(int client) {
  int count = 0;
  for (int i = 0; i < g_numRoundTypes; i++) {
    if (g_RoundTypeEnabled[i] && (g_AllowedRoundTypes[client][i] || !g_RoundTypeOptional[i])) {
      count++;
    }
  }
  return count;
}

/**
 * Menu Handler for round-type preference menu.
 */
public int MenuHandler_Preference(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    int choice = GetMenuInt(menu, param2);
    g_Preference[client] = choice;

    if (choice == -1) {
      SetClientCookie(client, g_PreferenceCookie, "none");
    } else {
      SetClientCookie(client, g_PreferenceCookie, g_RoundTypeNames[choice]);
    }

    GiveWeaponsMenu(client);
  } else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack) {
    int client = param1;
    GiveWeaponsMenu(client);
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

/**
 * Primary weapon choice menu.
 */
public void RifleChoiceMenu(int client) {
  Menu menu = new Menu(MenuHandler_RifleChoice);
  menu.SetTitle("%T", "WeaponsMenuSelection", client);
  menu.ExitButton = false;
  menu.ExitBackButton = true;
  for (int i = 0; i < g_numRifles; i++) {
    menu.AddItem(g_Rifles[i][0], g_Rifles[i][1]);
  }
  menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Rifle weapon handler - updates primaryWeapon.
 */
public int MenuHandler_RifleChoice(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    GetMenuItem(menu, param2, g_PrimaryWeapon[client], WEAPON_LENGTH);
    SetClientCookie(client, g_PrimaryWeaponCookie, g_PrimaryWeapon[client]);
    GiveWeaponsMenu(client);
  } else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack) {
    int client = param1;
    GiveWeaponsMenu(client);
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

/**
 * Displays pistol menu to a player
 */
public void PistolChoiceMenu(int client) {
  Menu menu = new Menu(MenuHandler_PistolChoice);
  menu.ExitButton = false;
  menu.ExitBackButton = true;
  menu.SetTitle("%T", "PistolMenuTitle", client);
  for (int i = 0; i < g_numPistols; i++) {
    menu.AddItem(g_Pistols[i][0], g_Pistols[i][1]);
  }
  menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Pistol choice handler - updates secondary weapon.
 */
public int MenuHandler_PistolChoice(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    GetMenuItem(menu, param2, g_SecondaryWeapon[client], WEAPON_LENGTH);
    SetClientCookie(client, g_SecondaryWeaponCookie, g_SecondaryWeapon[client]);
    GiveWeaponsMenu(client);
  } else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack) {
    int client = param1;
    GiveWeaponsMenu(client);
  } else if (action == MenuAction_End) {
    delete menu;
  }
}
