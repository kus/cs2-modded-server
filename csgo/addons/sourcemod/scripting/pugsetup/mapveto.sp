/**
 * Map vetoing functions
 */
public void CreateMapVeto() {
  if (GetConVarInt(g_RandomizeMapOrderCvar) != 0) {
    RandomizeArray(g_MapList);
  }

  ClearArray(g_MapVetoed);
  for (int i = 0; i < g_MapList.Length; i++) {
    g_MapVetoed.Push(false);
  }

  GiveVetoMenu(g_capt1);
}

public void GiveVetoMenu(int client) {
  Menu menu = new Menu(VetoHandler);
  menu.ExitButton = false;
  menu.SetTitle("%T", "VetoMenuTitle", client);

  for (int i = 0; i < g_MapList.Length; i++) {
    if (!g_MapVetoed.Get(i)) {
      AddMapIndexToMenu(menu, g_MapList, i);
    }
  }
  DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

static int GetNumMapsLeft() {
  int count = 0;
  for (int i = 0; i < g_MapList.Length; i++) {
    if (!g_MapVetoed.Get(i))
      count++;
  }
  return count;
}

static int GetFirstMapLeft() {
  for (int i = 0; i < g_MapList.Length; i++) {
    if (!g_MapVetoed.Get(i))
      return i;
  }
  return -1;
}

public int VetoHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    int index = GetMenuInt(menu, param2);
    char map[PLATFORM_MAX_PATH];
    FormatMapName(g_MapList, index, map, sizeof(map));

    char captString[64];
    FormatPlayerName(client, client, captString);
    PugSetup_MessageToAll("%t", "PlayerVetoed", captString, map);

    g_MapVetoed.Set(index, true);
    if (GetNumMapsLeft() == 1) {
      ChangeMap(g_MapList, GetFirstMapLeft());
    } else {
      int other = OtherCaptain(client);
      GiveVetoMenu(other);
      for (int i = 1; i <= MaxClients; i++) {
        if (IsPlayer(i) && i != other) {
          VetoStatusDisplay(i);
        }
      }
    }

  } else if (action == MenuAction_End) {
    CloseHandle(menu);
  }
}

static void VetoStatusDisplay(int client) {
  Menu menu = new Menu(VetoStatusHandler);
  SetMenuExitButton(menu, true);
  SetMenuTitle(menu, "%T", "MapsLeft", client);
  for (int i = 0; i < g_MapList.Length; i++) {
    if (!g_MapVetoed.Get(i)) {
      AddMapIndexToMenu(menu, g_MapList, i, true);
    }
  }
  DisplayMenu(menu, client, 30);
}

public int VetoStatusHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_End) {
    CloseHandle(menu);
  }
}
