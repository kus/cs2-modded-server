public Action Command_LastGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int index = g_GrenadeHistoryPositions[client].Length - 1;
  if (index >= 0) {
    TeleportToGrenadeHistoryPosition(client, index);
    PM_Message(client, "Teleporting back to position %d in grenade history.", index + 1);
  }

  return Plugin_Handled;
}

public Action Command_NextGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  int nextId = FindNextGrenadeId(client, nadeId);
  if (nextId != -1) {
    char auth[AUTH_LENGTH];
    GetClientAuthId(client, AUTH_METHOD, auth, sizeof(auth));

    char idBuffer[GRENADE_ID_LENGTH];
    IntToString(nextId, idBuffer, sizeof(idBuffer));
    TeleportToSavedGrenadePosition(client, idBuffer);
  }

  return Plugin_Handled;
}

public Action Command_GrenadeBack(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char argString[64];
  if (args >= 1 && GetCmdArg(1, argString, sizeof(argString))) {
    int index = StringToInt(argString) - 1;
    if (index >= 0 && index < g_GrenadeHistoryPositions[client].Length) {
      g_GrenadeHistoryIndex[client] = index;
      TeleportToGrenadeHistoryPosition(client, g_GrenadeHistoryIndex[client]);
      PM_Message(client, "Teleporting back to position %d in grenade history.",
                 g_GrenadeHistoryIndex[client] + 1);
    } else {
      PM_Message(client, "Your grenade history only goes from 1 to %d.",
                 g_GrenadeHistoryPositions[client].Length);
    }
    return Plugin_Handled;
  }

  if (g_GrenadeHistoryPositions[client].Length > 0) {
    g_GrenadeHistoryIndex[client]--;
    if (g_GrenadeHistoryIndex[client] < 0)
      g_GrenadeHistoryIndex[client] = 0;

    TeleportToGrenadeHistoryPosition(client, g_GrenadeHistoryIndex[client]);
    PM_Message(client, "Teleporting back to position %d in grenade history.",
               g_GrenadeHistoryIndex[client] + 1);
  }

  return Plugin_Handled;
}

public Action Command_SavePos(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  AddGrenadeToHistory(client);
  PM_Message(client, "Saved position. Use .back to go back to it.");
  return Plugin_Handled;
}

public Action Command_GrenadeForward(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (g_GrenadeHistoryPositions[client].Length > 0) {
    int max = g_GrenadeHistoryPositions[client].Length;
    g_GrenadeHistoryIndex[client]++;
    if (g_GrenadeHistoryIndex[client] >= max)
      g_GrenadeHistoryIndex[client] = max - 1;
    TeleportToGrenadeHistoryPosition(client, g_GrenadeHistoryIndex[client]);
    PM_Message(client, "Teleporting forward to position %d in grenade history.",
               g_GrenadeHistoryIndex[client] + 1);
  }

  return Plugin_Handled;
}

public Action Command_ClearNades(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  ClearArray(g_GrenadeHistoryPositions[client]);
  ClearArray(g_GrenadeHistoryAngles[client]);
  PM_Message(client, "Grenade history cleared.");

  return Plugin_Handled;
}

public Action Command_GotoNade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char arg[GRENADE_ID_LENGTH];
  if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
    char id[GRENADE_ID_LENGTH];
    if (!FindGrenade(arg, id) || !TeleportToSavedGrenadePosition(client, arg)) {
      PM_Message(client, "Grenade id %s not found.", arg);
      return Plugin_Handled;
    }
  } else {
    PM_Message(client, "Usage: .goto <grenadeid>");
  }

  return Plugin_Handled;
}

public Action Command_Grenades(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char arg[MAX_NAME_LENGTH];
  if (args >= 1 && GetCmdArgString(arg, sizeof(arg))) {
    ArrayList ids = new ArrayList(GRENADE_ID_LENGTH);
    char data[256];
    GrenadeMenuType type = FindGrenades(arg, ids, data, sizeof(data));
    if (type != GrenadeMenuType_Invalid) {
      GiveGrenadeMenu(client, type, 0, data, ids);
    } else {
      PM_Message(client, "No matching grenades found.");
    }
    delete ids;

  } else {
    bool categoriesOnly = (g_SharedAllNadesCvar.IntValue != 0);
    if (categoriesOnly) {
      GiveGrenadeMenu(client, GrenadeMenuType_Categories);
    } else {
      GiveGrenadeMenu(client, GrenadeMenuType_PlayersAndCategories);
    }
  }

  return Plugin_Handled;
}

public Action Command_Find(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char arg[MAX_NAME_LENGTH];
  if (args >= 1 && GetCmdArgString(arg, sizeof(arg))) {
    GiveGrenadeMenu(client, GrenadeMenuType_MatchingName, 0, arg, null,
                    GrenadeMenuType_MatchingName);
  } else {
    PM_Message(client, "Usage: .find <arg>");
  }

  return Plugin_Handled;
}

public Action Command_GrenadeDescription(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  char description[GRENADE_DESCRIPTION_LENGTH];
  GetCmdArgString(description, sizeof(description));

  UpdateGrenadeDescription(nadeId, description);
  PM_Message(client, "Added grenade description.");
  return Plugin_Handled;
}

public Action Command_RenameGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  char name[GRENADE_NAME_LENGTH];
  GetCmdArgString(name, sizeof(name));

  UpdateGrenadeName(nadeId, name);
  PM_Message(client, "Updated grenade name.");
  return Plugin_Handled;
}

public Action Command_DeleteGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  // get the grenade id first
  char grenadeIdStr[32];
  if (args < 1 || !GetCmdArg(1, grenadeIdStr, sizeof(grenadeIdStr))) {
    // if this fails, use the last grenade position
    IntToString(g_CurrentSavedGrenadeId[client], grenadeIdStr, sizeof(grenadeIdStr));
  }

  if (!CanEditGrenade(client, StringToInt(grenadeIdStr))) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  DeleteGrenadeFromKv(grenadeIdStr);
  PM_Message(client, "Deleted grenade id %s", grenadeIdStr);
  return Plugin_Handled;
}

public Action Command_SaveGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char name[GRENADE_NAME_LENGTH];
  GetCmdArgString(name, sizeof(name));
  TrimString(name);

  if (StrEqual(name, "")) {
    PM_Message(client, "Usage: .save <name>");
    return Plugin_Handled;
  }

  char auth[AUTH_LENGTH];
  GetClientAuthId(client, AUTH_METHOD, auth, sizeof(auth));
  char grenadeId[GRENADE_ID_LENGTH];
  if (FindGrenadeByName(auth, name, grenadeId)) {
    PM_Message(client, "You have already used that name.");
    return Plugin_Handled;
  }

  if (CountGrenadesForPlayer(auth) >= g_MaxGrenadesSavedCvar.IntValue) {
    PM_Message(client, "You have reached the maximum number of grenades you can save (%d).",
               g_MaxGrenadesSavedCvar.IntValue);
    return Plugin_Handled;
  }

  if (GetEntityMoveType(client) == MOVETYPE_NOCLIP) {
    PM_Message(client, "You can't save grenades while noclipped.");
    return Plugin_Handled;
  }

  float origin[3];
  float angles[3];
  GetClientAbsOrigin(client, origin);
  GetClientEyeAngles(client, angles);

  GrenadeType grenadeType = g_LastGrenadeType[client];
  float grenadeOrigin[3];
  float grenadeVelocity[3];
  grenadeOrigin = g_LastGrenadeOrigin[client];
  grenadeVelocity = g_LastGrenadeVelocity[client];

  if (grenadeType != GrenadeType_None && GetVectorDistance(origin, grenadeOrigin) >= 500.0) {
    PM_Message(
        client,
        "{LIGHT_RED}Warning: {NORMAL}your saved grenade lineup is very far from how your last grenade was thrown. If .throw doesn't work, manually throw the grenade at the linup and type .update to fix it.");
  }

  Action ret = Plugin_Continue;
  Call_StartForward(g_OnGrenadeSaved);
  Call_PushCell(client);
  Call_PushArray(origin, sizeof(origin));
  Call_PushArray(angles, sizeof(angles));
  Call_PushString(name);
  Call_Finish(ret);

  if (ret < Plugin_Handled) {
    int nadeId =
        SaveGrenadeToKv(client, origin, angles, grenadeOrigin, grenadeVelocity, grenadeType, name);
    g_CurrentSavedGrenadeId[client] = nadeId;
    PM_Message(
        client,
        "Saved grenade position (id %d). Type .desc <description> to add a description or .delete to delete this position.",
        nadeId);

    if (g_CSUtilsLoaded) {
      if (IsGrenade(g_LastGrenadeType[client])) {
        char grenadeName[64];
        GrenadeTypeString(g_LastGrenadeType[client], grenadeName, sizeof(grenadeName));
        PM_Message(
            client,
            "Saved %s throw. Use .clearthrow or .savethrow to change the grenade parameters.",
            grenadeName);
      } else {
        PM_Message(client,
                   "No grenade throw parameters saved. Throw it and use .savethrow to save them.");
      }
    }
  }

  g_LastGrenadeType[client] = GrenadeType_None;
  return Plugin_Handled;
}

public Action Command_MoveGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  if (GetEntityMoveType(client) == MOVETYPE_NOCLIP) {
    PM_Message(client, "You can't move grenades while noclipped.");
    return Plugin_Handled;
  }

  float origin[3];
  float angles[3];
  GetClientAbsOrigin(client, origin);
  GetClientEyeAngles(client, angles);
  SetClientGrenadeVectors(nadeId, origin, angles);
  PM_Message(client, "Updated grenade position.");
  return Plugin_Handled;
}

public Action Command_SaveThrow(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!g_CSUtilsLoaded) {
    PM_Message(client, "You need the csutils plugin installed to use that command.");
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  SetClientGrenadeParameters(nadeId, g_LastGrenadeType[client], g_LastGrenadeOrigin[client],
                             g_LastGrenadeVelocity[client]);
  PM_Message(client, "Updated grenade throw parameters.");
  g_LastGrenadeType[client] = GrenadeType_None;
  return Plugin_Handled;
}

public Action Command_UpdateGrenade(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  if (GetEntityMoveType(client) == MOVETYPE_NOCLIP) {
    PM_Message(client, "You can't update grenades while noclipped.");
    return Plugin_Handled;
  }

  float origin[3];
  float angles[3];
  GetClientAbsOrigin(client, origin);
  GetClientEyeAngles(client, angles);
  SetClientGrenadeVectors(nadeId, origin, angles);
  bool updatedParameters = false;
  if (g_CSUtilsLoaded && IsGrenade(g_LastGrenadeType[client])) {
    updatedParameters = true;
    SetClientGrenadeParameters(nadeId, g_LastGrenadeType[client], g_LastGrenadeOrigin[client],
                               g_LastGrenadeVelocity[client]);
  }

  if (updatedParameters) {
    PM_Message(client, "Updated grenade position and throwing parameters.");
  } else {
    PM_Message(client, "Updated grenade position.");
  }

  g_LastGrenadeType[client] = GrenadeType_None;
  return Plugin_Handled;
}

public Action Command_SetDelay(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!g_CSUtilsLoaded) {
    PM_Message(client, "You need the csutils plugin installed to use that command.");
    return Plugin_Handled;
  }

  if (args < 1) {
    PM_Message(client, "Usage: .delay <duration in seconds>");
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  char arg[64];
  GetCmdArgString(arg, sizeof(arg));
  float delay = StringToFloat(arg);
  SetClientGrenadeFloat(nadeId, "delay", delay);
  PM_Message(client, "Saved delay of %.1f seconds for grenade id %d.", delay, nadeId);
  return Plugin_Handled;
}

public Action Command_ClearThrow(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!g_CSUtilsLoaded) {
    PM_Message(client, "You need the csutils plugin installed to use that command.");
    return Plugin_Handled;
  }

  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  SetClientGrenadeParameters(nadeId, g_LastGrenadeType[client], g_LastGrenadeOrigin[client],
                             g_LastGrenadeVelocity[client]);
  PM_Message(client, "Cleared nade throwing parameters.");
  return Plugin_Handled;
}

static void ClientThrowGrenade(int client, const char[] id, float delay = 0.0) {
  if (!ThrowGrenade(client, id, delay)) {
    PM_Message(
        client,
        "No grenade parameters found for %s. Try \".goto %s\", throw the nade, and \".update\" and try again.",
        id, id);
  }
}

public Action Command_Throw(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!g_CSUtilsLoaded) {
    PM_Message(client, "You need the csutils plugin installed to use that command.");
    return Plugin_Handled;
  }

  char argString[256];
  GetCmdArgString(argString, sizeof(argString));
  if (args >= 1) {
    char data[128];
    ArrayList ids = new ArrayList(GRENADE_CATEGORY_LENGTH);

    GrenadeMenuType filterType;
    if (StrEqual(argString, "current", false)) {
      filterType = FindGrenades(g_ClientLastMenuData[client], ids, data, sizeof(data));
    } else {
      filterType = FindGrenades(argString, ids, data, sizeof(data));
    }

    // Print what's about to be thrown.
    if (filterType == GrenadeMenuType_OneCategory) {
      PM_Message(client, "Throwing category: %s", data);

    } else {
      char idString[256];
      for (int i = 0; i < ids.Length; i++) {
        char id[GRENADE_ID_LENGTH];
        ids.GetString(i, id, sizeof(id));
        StrCat(idString, sizeof(idString), id);
        if (i + 1 != ids.Length) {
          StrCat(idString, sizeof(idString), ", ");
        }
      }
      if (ids.Length == 1) {
        PM_Message(client, "Throwing nade id %s", idString);
      } else if (ids.Length > 1) {
        PM_Message(client, "Throwing nade ids %s", idString);
      }
    }

    // Actually do the throwing.
    for (int i = 0; i < ids.Length; i++) {
      char id[GRENADE_ID_LENGTH];
      ids.GetString(i, id, sizeof(id));
      float delay = 0.0;
      // Only support delays when throwing a category.
      if (filterType == GrenadeMenuType_OneCategory) {
        delay = GetClientGrenadeFloat(StringToInt(id), "delay");
      }
      ClientThrowGrenade(client, id, delay);
    }
    if (ids.Length == 0) {
      PM_Message(client, "No nades match %s", argString);
    }
    delete ids;

  } else {
    // No arg, throw last nade.
    if (IsGrenade(g_LastGrenadeType[client])) {
      PM_Message(client, "Throwing your last nade.");
      CSU_ThrowGrenade(client, g_LastGrenadeType[client], g_LastGrenadeOrigin[client],
                       g_LastGrenadeVelocity[client]);
    } else {
      PM_Message(client, "Can't throw you last nade; you haven't thrown any!");
    }
  }

  return Plugin_Handled;
}

public Action Command_TestFlash(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  g_TestingFlash[client] = true;
  PM_Message(
      client,
      "Saved your position. Throw a flashbang and you will be teleported back here to see the flashbang's effect.");
  PM_Message(client, "Use {GREEN}.stop {NORMAL}when you are done testing.");
  GetClientAbsOrigin(client, g_TestingFlashOrigins[client]);
  GetClientEyeAngles(client, g_TestingFlashAngles[client]);
  return Plugin_Handled;
}

public Action Command_StopFlash(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  g_TestingFlash[client] = false;
  PM_Message(client, "Disabled flash testing.");
  return Plugin_Handled;
}

public Action Command_Categories(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }
  GiveGrenadeMenu(client, GrenadeMenuType_Categories);
  return Plugin_Handled;
}

public Action Command_AddCategory(int client, int args) {
  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0 || !g_InPracticeMode || args < 1) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  char category[GRENADE_CATEGORY_LENGTH];
  GetCmdArgString(category, sizeof(category));
  AddGrenadeCategory(nadeId, category);

  PM_Message(client, "Added grenade category.");
  return Plugin_Handled;
}

public Action Command_AddCategories(int client, int args) {
  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0 || !g_InPracticeMode || args < 1) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  char category[GRENADE_CATEGORY_LENGTH];
  for (int i = 1; i <= args; i++) {
    GetCmdArg(i, category, sizeof(category));
    AddGrenadeCategory(nadeId, category);
  }

  PM_Message(client, "Added grenade category.");
  return Plugin_Handled;
}

public Action Command_RemoveCategory(int client, int args) {
  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0 || !g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  char category[GRENADE_CATEGORY_LENGTH];
  GetCmdArgString(category, sizeof(category));

  if (StrEqual(category, "")) {
    PM_Message(client, "You need to give a category name");
    return Plugin_Handled;
  }

  if (RemoveGrenadeCategory(nadeId, category)) {
    PM_Message(client, "Removed grenade category.");
  } else {
    PM_Message(client, "Category not found.");
  }

  return Plugin_Handled;
}

public Action Command_DeleteCategory(int client, int args) {
  char category[GRENADE_CATEGORY_LENGTH];
  GetCmdArgString(category, sizeof(category));

  if (StrEqual(category, "")) {
    PM_Message(client, "You need to give a category name");
    return Plugin_Handled;
  }

  if (DeleteGrenadeCategory(client, category) > 0) {
    PM_Message(client, "Removed grenade category.");
  } else {
    PM_Message(client, "Category not found.");
  }
  return Plugin_Handled;
}

public Action Command_ClearGrenadeCategories(int client, int args) {
  int nadeId = g_CurrentSavedGrenadeId[client];
  if (nadeId < 0 || !g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (!CanEditGrenade(client, nadeId)) {
    PM_Message(client, "You aren't the owner of this grenade.");
    return Plugin_Handled;
  }

  SetClientGrenadeData(nadeId, "categories", "");
  PM_Message(client, "Cleared grenade categories for id %d.", nadeId);

  return Plugin_Handled;
}

public Action Command_TranslateGrenades(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (args != 3) {
    ReplyToCommand(client, "Usage: sm_translategrenades <dx> <dy> <dz>");
    return Plugin_Handled;
  }

  char buffer[32];
  GetCmdArg(1, buffer, sizeof(buffer));
  float dx = StringToFloat(buffer);

  GetCmdArg(2, buffer, sizeof(buffer));
  float dy = StringToFloat(buffer);

  GetCmdArg(3, buffer, sizeof(buffer));
  float dz = StringToFloat(buffer);

  TranslateGrenades(dx, dy, dz);

  return Plugin_Handled;
}

public Action Command_FixGrenades(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  CorrectGrenadeIds();
  g_UpdatedGrenadeKv = true;
  ReplyToCommand(client, "Fixed grenade data.");
  return Plugin_Handled;
}
