#define MESSAGE_PREFIX "[\x05PracticeMode\x01]"

/**
 * Natives.
 */
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  g_ChatAliases = new ArrayList(ALIAS_LENGTH);
  g_ChatAliasesCommands = new ArrayList(COMMAND_LENGTH);
  CreateNative("PM_StartPracticeMode", Native_StartPracticeMode);
  CreateNative("PM_ExitPracticeMode", Native_ExitPracticeMode);
  CreateNative("PM_AddSetting", Native_AddSetting);
  CreateNative("PM_IsPracticeModeEnabled", Native_IsPracticeModeEnabled);
  CreateNative("PM_IsSettingEnabled", Native_IsSettingEnabled);
  CreateNative("PM_Message", Native_Message);
  CreateNative("PM_MessageToAll", Native_MessageToAll);
  CreateNative("PM_AddChatAlias", Native_AddChatAlias);
  RegPluginLibrary("practicemode");
}

public int Native_StartPracticeMode(Handle plugin, int numParams) {
  if (g_InPracticeMode) {
    return false;
  } else {
    LaunchPracticeMode();
    return true;
  }
}

public int Native_ExitPracticeMode(Handle plugin, int numParams) {
  if (g_InPracticeMode) {
    ExitPracticeMode();
    return true;
  } else {
    return false;
  }
}

public int Native_AddSetting(Handle plugin, int numParams) {
  char settingId[OPTION_NAME_LENGTH];
  char name[OPTION_NAME_LENGTH];

  GetNativeString(1, settingId, sizeof(settingId));
  GetNativeString(2, name, sizeof(name));
  ArrayList enabledCvars = view_as<ArrayList>(GetNativeCell(3));
  ArrayList enabledValues = view_as<ArrayList>(GetNativeCell(4));
  bool enabled = GetNativeCell(5);
  bool changeable = GetNativeCell(6);
  ArrayList disabledCvars = null;
  ArrayList disabledValues = null;
  if (numParams >= 8) {
    disabledCvars = view_as<ArrayList>(GetNativeCell(7));
    disabledValues = view_as<ArrayList>(GetNativeCell(8));
  }

  if (enabledCvars.Length != enabledValues.Length) {
    ThrowNativeError(SP_ERROR_PARAM, "Cvar name list size (%d) mismatch with cvar value list (%d)",
                     enabledCvars.Length, enabledValues.Length);
  }

  g_BinaryOptionIds.PushString(settingId);
  g_BinaryOptionNames.PushString(name);
  g_BinaryOptionEnabled.Push(enabled);
  g_BinaryOptionChangeable.Push(changeable);
  g_BinaryOptionEnabledCvars.Push(enabledCvars);
  g_BinaryOptionEnabledValues.Push(enabledValues);
  g_BinaryOptionCvarRestore.Push(INVALID_HANDLE);
  g_BinaryOptionDisabledCvars.Push(disabledCvars);
  g_BinaryOptionDisabledValues.Push(disabledValues);

  return g_BinaryOptionIds.Length - 1;
}

public int Native_IsPracticeModeEnabled(Handle plugin, int numParams) {
  return g_InPracticeMode;
}

public int Native_IsSettingEnabled(Handle plugin, int numParams) {
  int index = GetNativeCell(1);
  if (index < 0 || index >= g_BinaryOptionIds.Length) {
    ThrowNativeError(SP_ERROR_PARAM, "Setting %d is not valid", index);
  }
  return g_BinaryOptionEnabled.Get(index);
}

public int Native_Message(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  if (client != 0 && (!IsClientConnected(client) || !IsClientInGame(client)))
    return;

  char buffer[1024];
  int bytesWritten = 0;
  SetGlobalTransTarget(client);
  FormatNativeString(0, 2, 3, sizeof(buffer), bytesWritten, buffer);

  char prefix[64] = MESSAGE_PREFIX;

  char finalMsg[1024];
  if (StrEqual(prefix, ""))
    Format(finalMsg, sizeof(finalMsg), " %s", buffer);
  else
    Format(finalMsg, sizeof(finalMsg), "%s %s", prefix, buffer);

  if (client == 0) {
    Colorize(finalMsg, sizeof(finalMsg), false);
    PrintToConsole(client, finalMsg);
  } else if (IsClientInGame(client)) {
    Colorize(finalMsg, sizeof(finalMsg));
    PrintToChat(client, finalMsg);
  }
}

public int Native_MessageToAll(Handle plugin, int numParams) {
  char prefix[64] = MESSAGE_PREFIX;
  char buffer[1024];
  int bytesWritten = 0;

  for (int i = 0; i <= MaxClients; i++) {
    if (i != 0 && (!IsClientConnected(i) || !IsClientInGame(i)))
      continue;

    SetGlobalTransTarget(i);
    FormatNativeString(0, 1, 2, sizeof(buffer), bytesWritten, buffer);

    char finalMsg[1024];
    if (StrEqual(prefix, ""))
      Format(finalMsg, sizeof(finalMsg), " %s", buffer);
    else
      Format(finalMsg, sizeof(finalMsg), "%s %s", prefix, buffer);

    if (i != 0) {
      Colorize(finalMsg, sizeof(finalMsg));
      PrintToChat(i, finalMsg);
    } else {
      Colorize(finalMsg, sizeof(finalMsg), false);
      PrintToConsole(i, finalMsg);
    }
  }
}

public int Native_AddChatAlias(Handle plugin, int numParams) {
  char alias[ALIAS_LENGTH];
  char command[COMMAND_LENGTH];
  GetNativeString(1, alias, sizeof(alias));
  GetNativeString(2, command, sizeof(command));

  // don't allow duplicate aliases to be added
  if (g_ChatAliases.FindString(alias) == -1) {
    g_ChatAliases.PushString(alias);
    g_ChatAliasesCommands.PushString(command);
  }
}
