#define CVAR_NAME_MAX_LENGTH 255
#define CVAR_VALUE_MAX_LENGTH 255

// Returns a cvar Handle that can be used to restore cvars.
stock Handle SaveCvars(ArrayList cvarNames) {
  ArrayList storageList = CreateArray();
  ArrayList cvarNameList = new ArrayList(CVAR_NAME_MAX_LENGTH);
  ArrayList cvarValueList = new ArrayList(CVAR_VALUE_MAX_LENGTH);

  char nameBuffer[CVAR_NAME_MAX_LENGTH];
  char valueBuffer[CVAR_VALUE_MAX_LENGTH];
  for (int i = 0; cvarNames != null && i < cvarNames.Length; i++) {
    cvarNames.GetString(i, nameBuffer, sizeof(nameBuffer));

    Handle cvar = FindConVar(nameBuffer);
    if (cvar != INVALID_HANDLE) {
      GetConVarString(cvar, valueBuffer, sizeof(valueBuffer));
      cvarNameList.PushString(nameBuffer);
      cvarValueList.PushString(valueBuffer);
    }
  }

  storageList.Push(cvarNameList);
  storageList.Push(cvarValueList);
  return storageList;
}

// Restores cvars to their previous value using a return value of SaveCvars.
stock void RestoreCvars(Handle& cvarStorage, bool close = false) {
  ArrayList cvarNameList = view_as<ArrayList>(GetArrayCell(cvarStorage, 0));
  ArrayList cvarValueList = view_as<ArrayList>(GetArrayCell(cvarStorage, 1));

  char name[CVAR_NAME_MAX_LENGTH];
  char value[CVAR_VALUE_MAX_LENGTH];
  for (int i = 0; i < cvarNameList.Length; i++) {
    cvarNameList.GetString(i, name, sizeof(name));
    cvarValueList.GetString(i, value, sizeof(value));

    Handle cvar = FindConVar(name);
    if (cvar != INVALID_HANDLE) {
      SetConVarString(cvar, value);
    }
  }

  if (close) {
    CloseCvarStorage(cvarStorage);
  }
}

// Closes a cvar storage object returned by SaveCvars.
stock void CloseCvarStorage(Handle& cvarStorage) {
  CloseHandle(GetArrayCell(cvarStorage, 0));
  CloseHandle(GetArrayCell(cvarStorage, 1));
  CloseHandle(cvarStorage);
  cvarStorage = INVALID_HANDLE;
}

// Returns the first "word" in a line, as seperated by whitespace.
stock bool __firstWord(const char[] line, char[] buffer, int len) {
  char[] lineBuffer = new char[strlen(line)];
  strcopy(lineBuffer, strlen(line), line);
  TrimString(lineBuffer);
  int splitIndex = StrContains(line, " ");
  if (splitIndex == -1)
    splitIndex = StrContains(line, "\t");

  if (splitIndex == -1) {
    Format(buffer, len, "");
    return false;
  }

  int destLen = splitIndex + 1;
  if (destLen > len)
    destLen = len;

  strcopy(buffer, destLen, lineBuffer);
  return true;
}

// Wrapper for SetCvars from an arbitrary file.
// Returns if successful.
stock Handle ExecuteAndSaveCvars(const char[] cfgFile) {
  char lineBuffer[CVAR_NAME_MAX_LENGTH + CVAR_VALUE_MAX_LENGTH];
  char nameBuffer[CVAR_NAME_MAX_LENGTH];

  char filePath[PLATFORM_MAX_PATH];
  Format(filePath, sizeof(filePath), "cfg/%s", cfgFile);

  File file = OpenFile(filePath, "r");
  if (file != null) {
    ArrayList nameList = new ArrayList(CVAR_NAME_MAX_LENGTH);

    while (!file.EndOfFile() && file.ReadLine(lineBuffer, sizeof(lineBuffer))) {
      if (__firstWord(lineBuffer, nameBuffer, sizeof(nameBuffer))) {
        TrimString(nameBuffer);
        nameList.PushString(nameBuffer);
      }
    }

    Handle ret = SaveCvars(nameList);
    ServerCommand("exec %s", cfgFile);
    delete nameList;
    delete file;
    return ret;
  } else {
    LogError("Failed to open file for reading: %s", filePath);
    return INVALID_HANDLE;
  }
}
