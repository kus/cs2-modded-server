// Counter for tracking whose turn it is to pick based on the # of players picked.
// Tracking the "number of picks left" for the current captain.
int g_PickCounter = 0;

public Action Timer_InitialChoiceMenu(Handle timer) {
  int client = g_capt1;

  if (!g_DoKnifeRound) {
    // if no knife rounds, they get to choose between side/1st pick
    Menu menu = new Menu(InitialChoiceHandler);
    SetMenuTitle(menu, "%T", "InitialPickTitle", client);
    SetMenuExitButton(menu, false);
    AddMenuOption(menu, "side", "%T", "InitialPickSides", client);
    AddMenuOption(menu, "player", "%T", "InitialPickPlayer", client);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
  } else {
    // if using knife rounds, they just always get the 1st pick
    g_PickCounter = 0;
    CreateTimer(0.1, GivePlayerSelectionMenu, GetClientSerial(g_capt1));
  }

  return Plugin_Handled;
}

public int InitialChoiceHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    if (client != g_capt1)
      LogError("[InitialChoiceHandler] only the first captain should have gotten the intial menu!");

    char choice[64];
    menu.GetItem(param2, choice, sizeof(choice));

    char captString[64];
    FormatPlayerName(g_capt1, g_capt1, captString);

    if (StrEqual(choice, "player")) {
      PugSetup_MessageToAll("%T", "InitialPickPlayerChoice", client, captString);
      SideMenu(g_capt2);
    } else if (StrEqual(choice, "side")) {
      PugSetup_MessageToAll("%T", "InitialPickSideChoice", client, captString);
      SideMenu(g_capt1);
    } else {
      LogError("[InitialChoiceHandler] unknown intial choice=%s", choice);
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

public void SideMenu(int client) {
  Menu menu = new Menu(SideMenuHandler);
  SetMenuTitle(menu, "%T", "SideChoiceTitle", client);
  SetMenuExitButton(menu, false);
  AddMenuInt(menu, CS_TEAM_CT, "CT");
  AddMenuInt(menu, CS_TEAM_T, "T");
  DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SideMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    int teamPick = GetMenuInt(menu, param2);

    char captString[64];
    FormatPlayerName(client, client, captString);

    char teamString[8];
    if (teamPick == CS_TEAM_CT)
      Format(teamString, sizeof(teamString), "CT");
    else
      Format(teamString, sizeof(teamString), "T");

    PugSetup_MessageToAll("%t", "SideChoiceSelected", captString, teamString);

    int otherTeam = (teamPick == CS_TEAM_CT) ? CS_TEAM_T : CS_TEAM_CT;

    g_Teams[client] = teamPick;
    SwitchPlayerTeam(client, teamPick);

    int otherCaptain = OtherCaptain(client);
    g_Teams[otherCaptain] = otherTeam;
    SwitchPlayerTeam(otherCaptain, otherTeam);

    g_PickCounter = 0;
    ServerCommand("mp_restartgame 1");
    CreateTimer(1.0, GivePlayerSelectionMenu, GetClientSerial(otherCaptain));
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

/**
 * Player selection menus.
 */
public Action GivePlayerSelectionMenu(Handle timer, int serial) {
  if (g_GameState != GameState_PickingPlayers)
    return Plugin_Handled;

  int client = GetClientFromSerial(serial);
  if (IsPickingFinished()) {
    CreateTimer(1.0, FinishPicking);
  } else {
    if (IsValidClient(client)) {
      Menu menu = new Menu(PlayerMenuHandler);
      SetMenuTitle(menu, "%T", "PlayerPickTitle", client);
      SetMenuExitButton(menu, false);
      if (AddPlayersToMenu(menu) > 0) {
        DisplayMenu(menu, client, MENU_TIME_FOREVER);
      } else {
        PugSetup_MessageToAll("Not enough players for picking, aborting the game.");
        EndMatch(false);
        delete menu;
      }
    } else {
      PugSetup_MessageToAll("A captain is missing, aborting the game.");
      EndMatch(false);
    }
  }

  return Plugin_Handled;
}

public int PlayerMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (g_GameState != GameState_PickingPlayers)
    return;

  if (action == MenuAction_Select) {
    int client = param1;
    int selected = GetClientFromSerial(GetMenuInt(menu, param2));

    if (IsPlayer(selected)) {
      g_Teams[selected] = g_Teams[client];
      SwitchPlayerTeam(selected, g_Teams[client]);

      char captName[64];
      char selectedName[64];
      FormatPlayerName(client, client, captName);
      FormatPlayerName(client, selected, selectedName);
      PugSetup_MessageToAll("%t", "PlayerPickChoice", captName, selectedName);

      if (!IsPickingFinished()) {
        MoreMenuPicks(GetNextCaptain(client));
      } else {
        CreateTimer(1.0, FinishPicking);
      }
    } else {
      MoreMenuPicks(client);
    }

  } else if (action == MenuAction_Cancel) {
    PugSetup_MessageToAll("Failed to get captain pick. Aborting the game.");
    EndMatch(false);

  } else if (action == MenuAction_End) {
    delete menu;
  }
}

static void MoreMenuPicks(int client) {
  if (IsPickingFinished() || !IsValidClient(client) || !IsClientInGame(client)) {
    CreateTimer(5.0, FinishPicking);
    return;
  }
  CreateTimer(1.0, GivePlayerSelectionMenu, GetClientSerial(client));
}

/**
 * Helper functions for the player menus.
 */
static bool IsPickingFinished() {
  int numSelected = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayerPicked(i))
      numSelected++;
  }

  return numSelected >= 2 * g_PlayersPerTeam;
}

static bool IsPlayerPicked(int client) {
  int team = g_Teams[client];
  return team == CS_TEAM_T || team == CS_TEAM_CT;
}

static int GetNextCaptain(int captain) {
  if (GetConVarInt(g_SnakeCaptainsCvar) == 0) {
    return OtherCaptain(captain);
  }
  if (GetConVarInt(g_SnakeCaptainsCvar) == 1) {
    if (g_PickCounter == 0) {
      g_PickCounter = 1;
      return OtherCaptain(captain);
    } else {
      g_PickCounter--;
      return captain;
    }
  }
  if (GetConVarInt(g_SnakeCaptainsCvar) == 2) {
    if (g_PickCounter == 0) {
      g_PickCounter++;
      return OtherCaptain(captain);
    }
    if (g_PickCounter == 1) {
      g_PickCounter++;
      return captain;
    } else {
      return OtherCaptain(captain);
    }
  } else {
    if (g_PickCounter == 0) {
      g_PickCounter++;
      return OtherCaptain(captain);
    }
    if (g_PickCounter == 1) {
      g_PickCounter++;
      return captain;
    }
    if (g_PickCounter == 5) {
      g_PickCounter++;
      return captain;
    } else {
      g_PickCounter++;
      return OtherCaptain(captain);
    }
  }
}

public int OtherCaptain(int captain) {
  if (captain == g_capt1)
    return g_capt2;
  else
    return g_capt1;
}

static int AddPlayersToMenu(Menu menu) {
  char displayString[128];
  int count = 0;
  for (int client = 1; client <= MaxClients; client++) {
    if (IsValidClient(client) && !IsFakeClient(client) && g_Teams[client] == CS_TEAM_SPECTATOR &&
        g_Ready[client]) {
      GetClientName(client, displayString, sizeof(displayString));

      Call_StartForward(g_hOnPlayerAddedToCaptainMenu);
      Call_PushCell(menu);
      Call_PushCell(client);
      Call_PushStringEx(displayString, sizeof(displayString), SM_PARAM_STRING_COPY,
                        SM_PARAM_COPYBACK);
      Call_PushCell(sizeof(displayString));
      Call_Finish();

      AddMenuInt(menu, GetClientSerial(client), displayString);
      count++;
    }
  }
  return count;
}

public void FormatPlayerName(int capt, int client, char buffer[64]) {
  if (capt == g_capt1) {
    Format(buffer, sizeof(buffer), "{PINK}%N{NORMAL}", client);
  } else {
    Format(buffer, sizeof(buffer), "{LIGHT_GREEN}%N{NORMAL}", client);
  }
}
