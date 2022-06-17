public Action Command_Pugstatus(int client, int args) {
  ReplyToCommand(client, "Pugsetup version: %s", PLUGIN_VERSION);
#if defined COMMIT_STRING
  ReplyToCommand(client, "Compiled from commit %s", COMMIT_STRING);
#endif

  char stateString[64];
  switch (g_GameState) {
    case GameState_None:
      Format(stateString, sizeof(stateString), "None");
    case GameState_Warmup:
      Format(stateString, sizeof(stateString), "In warmup phase");
    case GameState_PickingPlayers:
      Format(stateString, sizeof(stateString), "Captains are picking players");
    case GameState_WaitingForStart:
      Format(stateString, sizeof(stateString), "Waiting for .start command from the leader");
    case GameState_Countdown:
      Format(stateString, sizeof(stateString), "Countdown timer active");
    case GameState_KnifeRound:
      Format(stateString, sizeof(stateString), "In knife round");
    case GameState_WaitingForKnifeRoundDecision:
      Format(stateString, sizeof(stateString), "Waiting for knife winner to pick sides");
    case GameState_GoingLive:
      Format(stateString, sizeof(stateString), "Going live");
    case GameState_Live:
      Format(stateString, sizeof(stateString), "Live");
    default:
      Format(stateString, sizeof(stateString), "Unknown");
  }

  char buffer[256];
  ReplyToCommand(client, "Current pug game state: %s", stateString);

  if (g_GameState != GameState_None) {
    int leader = PugSetup_GetLeader();
    if (IsPlayer(leader))
      ReplyToCommand(client, "Pug leader: %L", leader);
    else
      ReplyToCommand(client, "Pug leader: none");

    if (UsingCaptains()) {
      if (IsPlayer(g_capt1))
        ReplyToCommand(client, "Captain 1: %L", g_capt1);
      else
        ReplyToCommand(client, "Captain 1: not selected");

      if (IsPlayer(g_capt2))
        ReplyToCommand(client, "Captain 2: %L", g_capt2);
      else
        ReplyToCommand(client, "Captain 2: not selected");
    }
  }

  if (g_GameState == GameState_Warmup) {
    GetTeamString(buffer, sizeof(buffer), g_TeamType);
    ReplyToCommand(client, "Team Type (%d vs %d): %s", g_PlayersPerTeam, g_PlayersPerTeam, buffer);

    GetMapString(buffer, sizeof(buffer), g_MapType);
    ReplyToCommand(client, "Map Type: %s", buffer);

    GetEnabledString(buffer, sizeof(buffer), g_RecordGameOption);
    ReplyToCommand(client, "Recording: %s", buffer);

    GetEnabledString(buffer, sizeof(buffer), g_AutoLive);
    ReplyToCommand(client, "Autolive: %s", buffer);

    GetEnabledString(buffer, sizeof(buffer), g_DoKnifeRound);
    ReplyToCommand(client, "Knife round: %s", buffer);

    if (g_MapType == MapType_Vote || g_MapType == MapType_Veto) {
      GetTrueString(buffer, sizeof(buffer), g_OnDecidedMap);
      ReplyToCommand(client, "Map decided: %s", buffer);
    }

    if (g_OnDecidedMap) {
      GetCurrentMap(buffer, sizeof(buffer));
      ReplyToCommand(client, "On map %s", buffer);
    }

    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i)) {
        if (PugSetup_IsReady(i))
          ReplyToCommand(client, "  Player %L is READY", i);
        else
          ReplyToCommand(client, "  Player %L is NOT READY", i);
      }
    }
  }

  if (g_GameState >= GameState_WaitingForStart) {
    ReplyToCommand(client, "CT Team (score = %d):", CS_GetTeamScore(CS_TEAM_CT));
    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i) && GetClientTeam(i) == CS_TEAM_CT)
        ReplyToCommand(client, "  %L", i);
    }

    ReplyToCommand(client, "T Team (score = %d):", CS_GetTeamScore(CS_TEAM_T));
    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i) && GetClientTeam(i) == CS_TEAM_T)
        ReplyToCommand(client, "  %L", i);
    }
  }

  return Plugin_Handled;
}

public Action Command_ShowPermissions(int client, int args) {
  char command[COMMAND_LENGTH];
  char permission[64];

  for (int i = 0; i < g_Commands.Length; i++) {
    g_Commands.GetString(i, command, sizeof(command));
    Permission p = Permission_All;
    g_PermissionsMap.GetValue(command, p);
    switch (p) {
      case Permission_All:
        Format(permission, sizeof(permission), "all");
      case Permission_Captains:
        Format(permission, sizeof(permission), "captains");
      case Permission_Leader:
        Format(permission, sizeof(permission), "leader");
      case Permission_Admin:
        Format(permission, sizeof(permission), "admin");
    }
    ReplyToCommand(client, "%s: %s", command, permission);
  }

  return Plugin_Handled;
}

public Action Command_ShowChatAliases(int client, int args) {
  char command[COMMAND_LENGTH];
  char alias[ALIAS_LENGTH];

  for (int i = 0; i < g_ChatAliases.Length; i++) {
    g_ChatAliases.GetString(i, alias, sizeof(alias));
    g_ChatAliasesCommands.GetString(i, command, sizeof(command));
    ReplyToCommand(client, "%s -> %s", alias, command);
  }

  return Plugin_Handled;
}
