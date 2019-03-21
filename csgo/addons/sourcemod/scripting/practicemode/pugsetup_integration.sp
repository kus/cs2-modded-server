/**
 * Pugsetup forwards.
 */
public Action PugSetup_OnSetupMenuOpen(int client, Menu menu, bool displayOnly) {
  if (!g_PugsetupLoaded) {
    return Plugin_Continue;
  }

  int leader = PugSetup_GetLeader(false);
  if (!IsPlayer(leader)) {
    PugSetup_SetLeader(client);
  }

  int style = ITEMDRAW_DEFAULT;
  if (!PugSetup_HasPermissions(client, Permission_Leader) || displayOnly) {
    style = ITEMDRAW_DISABLED;
  }

  if (g_InPracticeMode) {
    GivePracticeMenu(client, style);
    return Plugin_Stop;
  }

  AddMenuItem(menu, "launch_practice", "Launch practice mode",
              EnabledIf(CanStartPracticeMode(client)));

  return Plugin_Continue;
}

public void PugSetup_OnReadyToStart() {
  if (!g_PugsetupLoaded) {
    return;
  }

  if (g_InPracticeMode) {
    ExitPracticeMode();
  }
}

public void PugSetup_OnSetupMenuSelect(Menu menu, int client, const char[] selected_info,
                                int selected_position) {
  if (!g_PugsetupLoaded) {
    return;
  }

  if (StrEqual(selected_info, "launch_practice")) {
    LaunchPracticeMode();
    GivePracticeMenu(client);
  }
}

public void PugSetup_OnHelpCommand(int client, ArrayList replyMessages, int maxMessageSize, bool& block) {
  if (!g_PugsetupLoaded) {
    return;
  }

  if (g_InPracticeMode) {
    block = true;
    ShowHelpInfo(client);
  }
}
