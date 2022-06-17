/** Begins the LO3 process. **/
public Action BeginLO3(Handle timer) {
  if (g_GameState == GameState_None)
    return Plugin_Handled;

  ChangeState(GameState_GoingLive);

  // force kill the warmup if we need to
  if (InWarmup()) {
    EndWarmup();
  }

  // reset player tags
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      UpdateClanTag(i, true);  // force strip them
    }
  }

  SetConVarInt(FindConVar("sv_cheats"), 0);
  Call_StartForward(g_hOnGoingLive);
  Call_Finish();

  if (GetConVarInt(g_QuickRestartsCvar) == 0) {
    // start lo3
    PugSetup_MessageToAll("%t", "RestartCounter", 1);
    RestartGame(1);
    CreateTimer(2.0, Restart2);
  } else {
    // single restart
    RestartGame(3);
    CreateTimer(3.1, MatchLive);
  }

  return Plugin_Handled;
}

public Action Restart2(Handle timer) {
  if (g_GameState == GameState_None)
    return Plugin_Handled;

  PugSetup_MessageToAll("%t", "RestartCounter", 2);
  RestartGame(1);
  CreateTimer(2.0, Restart3);

  return Plugin_Handled;
}

public Action Restart3(Handle timer) {
  if (g_GameState == GameState_None)
    return Plugin_Handled;

  PugSetup_MessageToAll("%t", "RestartCounter", 3);
  RestartGame(3);
  CreateTimer(3.1, MatchLive);

  return Plugin_Handled;
}

public Action MatchLive(Handle timer) {
  if (g_GameState == GameState_None)
    return Plugin_Handled;

  ChangeState(GameState_Live);
  Call_StartForward(g_hOnLive);
  Call_Finish();

  // Restore client clan tags since we're live.
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      RestoreClanTag(i);
    }
  }

  for (int i = 0; i < 5; i++) {
    PugSetup_MessageToAll("%t", "Live");
  }

  return Plugin_Handled;
}
