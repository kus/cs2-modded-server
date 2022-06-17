/**
 * Displays a menu to select the captains for the game.
 */
public void Captain1Menu(int client) {
  Menu menu = new Menu(Captain1MenuHandler);
  char title[128];
  Format(title, sizeof(title), "%T", "ChooseCaptainTitle", client, 1);
  SetMenuTitle(menu, title);

  if (CountPotentialCaptains(g_capt2) >= 2)
    AddMenuInt(menu, -1, "%T", "Random", client);

  if (AddPotentialCaptains(menu, g_capt2) >= 1)
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
  else
    CloseHandle(menu);
}

public int Captain1MenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    int choice = GetMenuInt(menu, param2);
    if (choice == -1) {
      int randomClient = RandomPlayer();
      if (IsPlayer(randomClient))
        PugSetup_SetCaptain(1, randomClient, true);
    } else if (IsPlayer(choice)) {
      PugSetup_SetCaptain(1, choice, true);
    }

    Captain2Menu(client);
  } else if (action == MenuAction_End) {
    CloseHandle(menu);
  }
}

public void Captain2Menu(int client) {
  Menu menu = new Menu(Captain2MenuHandler);
  char title[128];
  Format(title, sizeof(title), "%T", "ChooseCaptainTitle", client, 2);
  SetMenuTitle(menu, title);

  if (CountPotentialCaptains(g_capt1) >= 2)
    AddMenuInt(menu, -1, "%T", "Random", client);

  if (AddPotentialCaptains(menu, g_capt1) >= 1)
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
  else
    CloseHandle(menu);
}

public int Captain2MenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int choice = GetMenuInt(menu, param2);
    if (choice == -1) {
      int randomClient = RandomPlayer(g_capt1);
      if (IsPlayer(randomClient))
        PugSetup_SetCaptain(2, randomClient, true);
    } else if (IsPlayer(choice)) {
      PugSetup_SetCaptain(2, choice, true);
    }
  } else if (action == MenuAction_End) {
    CloseHandle(menu);
  }
}

static int CountPotentialCaptains(int otherCaptain) {
  int count = 0;
  for (int client = 1; client <= MaxClients; client++) {
    if (IsPotentialCaptain(client, otherCaptain)) {
      count++;
    }
  }
  return count;
}

static bool IsPotentialCaptain(int client, int otherCaptain) {
  return IsPlayer(client) && otherCaptain != client;
}

static int AddPotentialCaptains(Menu menu, int otherCaptain) {
  int count = 0;
  for (int client = 1; client <= MaxClients; client++) {
    if (IsPotentialCaptain(client, otherCaptain)) {
      char name[MAX_NAME_LENGTH];
      GetClientName(client, name, sizeof(name));
      AddMenuInt(menu, client, name);
      count++;
    }
  }
  return count;
}

/**
 * Extra menu for selecting the leader of the game.
 */
public void LeaderMenu(int client) {
  Menu menu = new Menu(LeaderMenuHandler);
  SetMenuTitle(menu, "%T", "ChooseLeaderTitle", client);
  if (AddAllPlayers(menu) >= 1)
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
  else
    CloseHandle(menu);
}

public int LeaderMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int choice = GetMenuInt(menu, param2);
    PugSetup_SetLeader(choice);
  } else if (action == MenuAction_End) {
    CloseHandle(menu);
  }
}

static int AddAllPlayers(Menu menu) {
  int count = 0;
  for (int client = 1; client <= MaxClients; client++) {
    if (IsPlayer(client)) {
      char name[MAX_NAME_LENGTH];
      GetClientName(client, name, sizeof(name));
      AddMenuInt(menu, client, name);
      count++;
    }
  }
  return count;
}
