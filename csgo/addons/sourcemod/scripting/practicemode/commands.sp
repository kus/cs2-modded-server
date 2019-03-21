public Action Command_LaunchPracticeMode(int client, int args) {
  if (!CanStartPracticeMode(client)) {
    PM_Message(client, "You cannot start practice mode right now.");
    return Plugin_Handled;
  }

  if (!g_InPracticeMode) {
    if (g_PugsetupLoaded && PugSetup_GetGameState() >= GameState_Warmup) {
      return Plugin_Continue;
    }
    LaunchPracticeMode();
    if (IsPlayer(client)) {
      GivePracticeMenu(client);
    }
  }
  return Plugin_Handled;
}

public Action Command_ExitPracticeMode(int client, int args) {
  if (g_InPracticeMode) {
    ExitPracticeMode();
  }
  return Plugin_Handled;
}

public Action Command_NoFlash(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  g_ClientNoFlash[client] = !g_ClientNoFlash[client];
  if (g_ClientNoFlash[client]) {
    PM_Message(client, "Enabled noflash. Use .noflash again to disable.");
    RequestFrame(KillFlashEffect, GetClientSerial(client));
  } else {
    PM_Message(client, "Disabled noflash.");
  }
  return Plugin_Handled;
}

public Action Command_Time(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!g_RunningTimeCommand[client]) {
    // Start command.
    PM_Message(client, "When you start moving a timer will run until you stop moving.");
    g_RunningTimeCommand[client] = true;
    g_RunningLiveTimeCommand[client] = false;
    g_TimerType[client] = TimerType_Movement;
  } else {
    // Early stop command.
    g_RunningTimeCommand[client] = false;
    g_RunningLiveTimeCommand[client] = false;
    StopClientTimer(client);
  }

  return Plugin_Handled;
}

public Action Command_Time2(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!g_RunningTimeCommand[client]) {
    // Start command.
    PM_Message(client, "Type .timer2 to stop the timer again.");
    g_RunningTimeCommand[client] = true;
    g_RunningLiveTimeCommand[client] = false;
    g_TimerType[client] = TimerType_Manual;
    StartClientTimer(client);
  } else {
    // Stop command.
    g_RunningTimeCommand[client] = false;
    g_RunningLiveTimeCommand[client] = false;
    StopClientTimer(client);
  }

  return Plugin_Handled;
}

public void StartClientTimer(int client) {
  g_LastTimeCommand[client] = GetEngineTime();
  CreateTimer(0.1, Timer_DisplayClientTimer, GetClientSerial(client),
              TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void StopClientTimer(int client) {
  float dt = GetEngineTime() - g_LastTimeCommand[client];
  PM_Message(client, "Timer result: %.2f seconds", dt);
  PrintHintText(client, "<b>Time: %.2f</b> seconds", dt);
}

public Action Timer_DisplayClientTimer(Handle timer, int serial) {
  int client = GetClientFromSerial(serial);
  if (IsPlayer(client) && g_RunningTimeCommand[client]) {
    if (g_RunningTimeCommand[client]) {
      float dt = GetEngineTime() - g_LastTimeCommand[client];
      PrintHintText(client, "<b>Time: %.1f</b> seconds", dt);
      return Plugin_Continue;
    } else {
      return Plugin_Stop;
    }
  }
  return Plugin_Stop;
}

public Action Command_CopyGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!IsPlayer(client) || args != 1) {
    PM_Message(client, "Usage: .copy <id>");
    return Plugin_Handled;
  }

  char name[MAX_NAME_LENGTH];
  char id[GRENADE_ID_LENGTH];
  GetCmdArg(1, id, sizeof(id));

  char targetAuth[AUTH_LENGTH];
  if (FindId(id, targetAuth, sizeof(targetAuth))) {
    int newid = CopyGrenade(targetAuth, id, client);
    if (newid != -1) {
      PM_Message(client, "Copied nade to new id %d", newid);
    } else {
      PM_Message(client, "Could not find grenade %s from %s", newid, name);
    }
  }

  return Plugin_Handled;
}

public Action Command_Respawn(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!IsPlayerAlive(client)) {
    CS_RespawnPlayer(client);
    return Plugin_Handled;
  }

  g_SavedRespawnActive[client] = true;
  GetClientAbsOrigin(client, g_SavedRespawnOrigin[client]);
  GetClientEyeAngles(client, g_SavedRespawnAngles[client]);
  PM_Message(
      client,
      "Saved respawn point. When you die will you respawn here, use {GREEN}.stop {NORMAL}to cancel.");
  return Plugin_Handled;
}

public Action Command_StopRespawn(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  g_SavedRespawnActive[client] = false;
  PM_Message(client, "Cancelled respawning at your saved position.");
  return Plugin_Handled;
}

public Action Command_Spec(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  FakeClientCommand(client, "jointeam 1");
  return Plugin_Handled;
}

public Action Command_JoinT(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  FakeClientCommand(client, "jointeam 2");
  return Plugin_Handled;
}

public Action Command_JoinCT(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  FakeClientCommand(client, "jointeam 3");
  return Plugin_Handled;
}

public Action Command_StopAll(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }
  if (g_SavedRespawnActive[client]) {
    Command_StopRespawn(client, 0);
  }
  if (g_TestingFlash[client]) {
    Command_StopFlash(client, 0);
  }
  if (g_RunningRepeatedCommand[client]) {
    Command_StopRepeat(client, 0);
  }
  if (g_BotMimicLoaded && IsReplayPlaying()) {
    CancelAllReplays();
  }
  if (g_BotMimicLoaded && BotMimic_IsPlayerRecording(client)) {
    BotMimic_StopRecording(client, false /* save */);
  }
  return Plugin_Handled;
}

public Action Command_FastForward(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (g_FastfowardRequiresZeroVolumeCvar.IntValue != 0) {
    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i) && g_ClientVolume[i] > 0.01) {
        PM_Message(client, "All players must turn volume below 0.01 to allow the .ff command.");
        return Plugin_Handled;
      }
    }
  }

  // Freeze clients so its not really confusing.
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      g_PreFastForwardMoveTypes[i] = GetEntityMoveType(i);
      SetEntityMoveType(i, MOVETYPE_NONE);
    }
  }

  // Smokes last around 18 seconds.
  PM_MessageToAll("Fastforwarding 20 seconds...");
  SetCvar("host_timescale", 10);
  CreateTimer(20.0, Timer_ResetTimescale);

  return Plugin_Handled;
}

public Action Timer_ResetTimescale(Handle timer) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  SetCvar("host_timescale", 1);

  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      SetEntityMoveType(i, g_PreFastForwardMoveTypes[i]);
    }
  }
  return Plugin_Handled;
}

public Action Command_Repeat(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (args < 2) {
    PM_Message(client, "Usage: .repeat <interval in seconds> <any chat command>");
    return Plugin_Handled;
  }

  char timeString[64];
  char fullString[256];
  if (GetCmdArgString(fullString, sizeof(fullString)) &&
      SplitOnSpace(fullString, timeString, sizeof(timeString), g_RunningRepeatedCommandArg[client],
                   sizeof(fullString))) {
    float time = StringToFloat(timeString);
    if (time <= 0.0) {
      PM_Message(client, "Usage: .repeat <interval in seconds> <any chat command>");
      return Plugin_Handled;
    }

    g_RunningRepeatedCommand[client] = true;
    FakeClientCommand(client, "say %s", g_RunningRepeatedCommandArg[client]);
    CreateTimer(time, Timer_RepeatCommand, GetClientSerial(client),
                TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    PM_Message(client, "Running command every %.1f seconds.", time);
    PM_Message(client, "Use {GREEN}.stop {NORMAL}when you are done.");
  }

  return Plugin_Handled;
}

public Action Timer_RepeatCommand(Handle timer, int serial) {
  int client = GetClientFromSerial(serial);
  if (!IsPlayer(client) || !g_RunningRepeatedCommand[client]) {
    return Plugin_Stop;
  }

  FakeClientCommand(client, "say %s", g_RunningRepeatedCommandArg[client]);
  return Plugin_Continue;
}

public Action Command_RoundRepeat(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (args < 2) {
    PM_Message(client,
               "Usage: .roundrepeat <delay from round start in seconds> <any chat command>");
    return Plugin_Handled;
  }

  char timeString[64];
  char fullString[256];
  char cmd[256];
  if (GetCmdArgString(fullString, sizeof(fullString)) &&
      SplitOnSpace(fullString, timeString, sizeof(timeString), cmd, sizeof(cmd))) {
    float time = StringToFloat(timeString);
    if (time < 0.0) {
      PM_Message(client,
                 "Usage: .roundrepeat <delay from round start in seconds> <any chat command>");
      return Plugin_Handled;
    }

    g_RunningRepeatedCommand[client] = true;
    PM_Message(client, "Running command every %.1f seconds after round start.", time);
    PM_Message(client, "Use {GREEN}.stop {NORMAL}when you are done.");
    g_RunningRoundRepeatedCommandDelay[client].Push(time);
    g_RunningRoundRepeatedCommandArg[client].PushString(cmd);
  }

  return Plugin_Handled;
}

public void FreezeEnd_RoundRepeat(int client) {
  if (g_RunningRepeatedCommand[client]) {
    for (int i = 0; i < g_RunningRoundRepeatedCommandDelay[client].Length; i++) {
      float delay = g_RunningRoundRepeatedCommandDelay[client].Get(i);
      char cmd[256];
      g_RunningRoundRepeatedCommandArg[client].GetString(i, cmd, sizeof(cmd));
      DataPack p = new DataPack();
      p.WriteCell(GetClientSerial(client));
      p.WriteString(cmd);
      CreateTimer(delay, Timer_RoundRepeatCommand, p);
    }
  }
}

public Action Timer_RoundRepeatCommand(Handle timer, DataPack p) {
  p.Reset();
  int client = GetClientFromSerial(p.ReadCell());
  if (!IsPlayer(client) || !g_RunningRepeatedCommand[client]) {
    return Plugin_Stop;
  }

  char cmd[256];
  p.ReadString(cmd, sizeof(cmd));
  FakeClientCommand(client, "say %s", cmd);
  return Plugin_Continue;
}

public Action Command_StopRepeat(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (g_RunningRepeatedCommand[client]) {
    g_RunningRepeatedCommand[client] = false;
    g_RunningRoundRepeatedCommandArg[client].Clear();
    g_RunningRoundRepeatedCommandDelay[client].Clear();
    PM_Message(client, "Cancelled repeating command.");
  }
  return Plugin_Handled;
}

public Action Command_Delay(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (args < 2) {
    PM_Message(client, "Usage: .delay <interval in seconds> <any chat command>");
    return Plugin_Handled;
  }

  char timeString[64];
  char fullString[256];
  if (GetCmdArgString(fullString, sizeof(fullString)) &&
      SplitOnSpace(fullString, timeString, sizeof(timeString), g_RunningRepeatedCommandArg[client],
                   sizeof(fullString))) {
    float time = StringToFloat(timeString);
    if (time <= 0.0) {
      PM_Message(client, "Usage: .repeat <interval in seconds> <any chat command>");
      return Plugin_Handled;
    }

    CreateTimer(time, Timer_DelayedComand, GetClientSerial(client));
  }

  return Plugin_Handled;
}

public Action Timer_DelayedComand(Handle timer, int serial) {
  int client = GetClientFromSerial(serial);
  if (IsPlayer(client)) {
    FakeClientCommand(client, "say %s", g_RunningRepeatedCommandArg[client]);
  }
  return Plugin_Stop;
}

public Action Command_Map(int client, int args) {
  char arg[PLATFORM_MAX_PATH];
  if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
    // Before trying to change to the arg first, check to see if
    // there's a clear match in the maplist
    for (int i = 0; i < g_MapList.Length; i++) {
      char map[PLATFORM_MAX_PATH];
      g_MapList.GetString(i, map, sizeof(map));
      if (StrContains(map, arg, false) >= 0) {
        ChangeMap(map);
        return Plugin_Handled;
      }
    }
    ChangeMap(arg);

  } else {
    Menu menu = new Menu(ChangeMapHandler);
    menu.ExitButton = true;
    menu.ExitBackButton = true;
    menu.SetTitle("Select a map:");
    for (int i = 0; i < g_MapList.Length; i++) {
      char map[PLATFORM_MAX_PATH];
      g_MapList.GetString(i, map, sizeof(map));
      char cleanedMapName[PLATFORM_MAX_PATH];
      CleanMapName(map, cleanedMapName, sizeof(cleanedMapName));
      AddMenuInt(menu, i, cleanedMapName);
    }
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
  }

  return Plugin_Handled;
}

public int ChangeMapHandler(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int index = GetMenuInt(menu, param2);
    char map[PLATFORM_MAX_PATH];
    g_MapList.GetString(index, map, sizeof(map));
    ChangeMap(map);
  } else if (action == MenuAction_End) {
    delete menu;
  }
}

public void ChangeSettingById(const char[] id, bool setting) {
  for (int i = 0; i < g_BinaryOptionIds.Length; i++) {
    char name[OPTION_NAME_LENGTH];
    g_BinaryOptionIds.GetString(i, name, sizeof(name));
    if (StrEqual(name, id, false)) {
      ChangeSetting(i, setting, true);
    }
  }
}

public Action Command_DryRun(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  SetCvar("mp_freezetime", g_DryRunFreezeTimeCvar.IntValue);
  ChangeSettingById("allradar", false);
  ChangeSettingById("blockroundendings", false);
  ChangeSettingById("grenadetrajectory", false);
  ChangeSettingById("infiniteammo", false);
  ChangeSettingById("noclip", false);
  ChangeSettingById("respawning", false);
  ChangeSettingById("showimpacts", false);

  for (int i = 1; i <= MaxClients; i++) {
    g_TestingFlash[i] = false;
    g_RunningRepeatedCommand[i] = false;
    g_SavedRespawnActive[i] = false;
    g_ClientNoFlash[client] = false;
    if (IsPlayer(i)) {
      SetEntityMoveType(i, MOVETYPE_WALK);
    }
  }

  ServerCommand("mp_restartgame 1");
  return Plugin_Handled;
}

static void ChangeSettingArg(int client, const char[] arg, bool enabled) {
  if (StrEqual(arg, "all", false)) {
    for (int i = 0; i < g_BinaryOptionIds.Length; i++) {
      ChangeSetting(i, enabled, true);
    }
    return;
  }

  ArrayList indexMatches = new ArrayList();
  for (int i = 0; i < g_BinaryOptionIds.Length; i++) {
    char name[OPTION_NAME_LENGTH];
    g_BinaryOptionNames.GetString(i, name, sizeof(name));
    if (StrContains(name, arg, false) >= 0) {
      indexMatches.Push(i);
    }
  }

  if (indexMatches.Length == 0) {
    PM_Message(client, "No settings matched \"%s\"", arg);
  } else if (indexMatches.Length == 1) {
    if (!ChangeSetting(indexMatches.Get(0), enabled, true)) {
      PM_Message(client, "That is already enabled.");
    }
  } else {
    PM_Message(client, "Multiple settings matched \"%s\"", arg);
  }

  delete indexMatches;
}

public Action Command_Enable(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char arg[128];
  GetCmdArgString(arg, sizeof(arg));
  ChangeSettingArg(client, arg, true);
  return Plugin_Handled;
}

public Action Command_Disable(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char arg[128];
  GetCmdArgString(arg, sizeof(arg));
  ChangeSettingArg(client, arg, false);
  return Plugin_Handled;
}

public Action Command_God(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!GetCvarIntSafe("sv_cheats")) {
    PM_Message(client, ".god requires sv_cheats to be enabled.");
    return Plugin_Handled;
  }

  FakeClientCommand(client, "god");
  return Plugin_Handled;
}

public Action Command_EndRound(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!GetCvarIntSafe("sv_cheats")) {
    PM_Message(client, ".endround requires sv_cheats to be enabled.");
    return Plugin_Handled;
  }

  ServerCommand("endround");
  return Plugin_Handled;
}

public Action Command_Break(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int ent = -1;
  while ((ent = FindEntityByClassname(ent, "func_breakable")) != -1) {
    AcceptEntityInput(ent, "Break");
  }
  while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != -1) {
    AcceptEntityInput(ent, "Break");
  }

  PM_MessageToAll("Broke all breakable entities.");
  return Plugin_Handled;
}
