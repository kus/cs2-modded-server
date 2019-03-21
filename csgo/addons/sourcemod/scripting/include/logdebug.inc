/*
 * logdebug.inc by Dr. McKay
 *
 * A simple to use library for debug logging which can be redirected or disabled on-the-fly.
 * Employs transitional syntax - SourceMod 1.7 or newer is required to compile and run.
 */

#if defined _logdebug_included
#endinput
#endif
#define _logdebug_included

// define NO_DEBUG before including this file to completely disable all debugging
#if defined NO_DEBUG
stock void InitDebugLog(const char[] convarName, const char[] debugTag,
                        int adminFlags = ADMFLAG_GENERIC) {}
stock bool LogDebug(const char[] format, any...) {
  return false;
}
#endinput
#endif

#define DEBUG_SERVER_CONSOLE 1 /**< Message will be routed to server console */
#define DEBUG_CLIENT_CONSOLE 2 /**< Message will be routed to all clients' consoles */
#define DEBUG_ADMIN_CONSOLE \
  4 /**< Message will be routed to consoles of admins with a flag specified by plugin */
#define DEBUG_CLIENT_CHAT \
  8 /**< Message will be routed to all clients' chat boxes (and consequently consoles) */
#define DEBUG_ADMIN_CHAT \
  16 /**< Message will be routed to chat boxes of admins with a flag specified by plugin */
#define DEBUG_LOG_FILE 32 /**< Message will be routed to plugin's debug log */

ConVar g_cvarDebugMode;
char g_DebugLogFileName[PLATFORM_MAX_PATH];
char g_DebugTag[11];
char g_DebugCvarName[64];
int g_DebugAdminFlags;

/**
 * Inits debug logging. You must call this in OnPluginStart().
 *
 * @param convarName    A name to use for the cvar which controls debug log output. Also used as
 * filename for logfile.
 * @param debugTag      Tag to prepend to messages, without []. Max 10 characters.
 * @param adminFlag     One or more admin flagbits which define whether a user is an "admin". If you
 * pass multiple flags, users will need ALL flags.
 * @noreturn
 */
stock void InitDebugLog(const char[] convarName, const char[] debugTag,
                        int adminFlags = ADMFLAG_GENERIC) {
  BuildPath(Path_SM, g_DebugLogFileName, sizeof(g_DebugLogFileName), "logs/%s.log", convarName);

  char flagChars[32];
  AdminFlag flags[22];
  int numFlags = FlagBitsToArray(adminFlags, flags, sizeof(flags));
  for (int i = 0; i < numFlags; i++) {
    int len = strlen(flagChars);

    if (len > 0) {
      len += StrCat(flagChars, sizeof(flagChars), ", ");
    }

    int flag = 0;
    FindFlagChar(flags[i], flag);
    flagChars[len] = view_as<char>(flag);

    flagChars[len + 1] = '\0';
  }

  g_DebugAdminFlags = adminFlags;

  char convarDescription[512];
  Format(
      convarDescription, sizeof(convarDescription),
      "Add up values to enable debug logging to those locations\n  1 = server console\n  2 = all clients' consoles\n  4 = consoles of admins with '%s' flag%s or access to '%s' override\n  8 = all clients' chat\n  16 = chat of admins with '%s' flag%s or access to '%s' override\n  32 = debug log file %s",
      flagChars, flagChars[1] == '\0' ? "" : "s", convarName, flagChars,
      flagChars[1] == '\0' ? "" : "s", convarName, g_DebugLogFileName);
  g_cvarDebugMode =
      CreateConVar(convarName, "0", convarDescription, FCVAR_DONTRECORD, true, 0.0, true, 63.0);

  strcopy(g_DebugTag, sizeof(g_DebugTag), debugTag);
  strcopy(g_DebugCvarName, sizeof(g_DebugCvarName), convarName);
}

/**
 * Logs a message to all enabled debug output points
 *
 * @param format    Message text with formatting tokens
 * @param ...     Variable number of format parameters
 * @return        true if message was output to at least one place
 */
stock bool LogDebug(const char[] format, any...) {
  if (g_cvarDebugMode == null) {
    ThrowError("InitDebugLog must be called before LogDebug");
  }

  int output = g_cvarDebugMode.IntValue;
  if (output == 0) {
    return false;
  }

  char buffer[512];
  VFormat(buffer, sizeof(buffer), format, 2);

  if (output & DEBUG_SERVER_CONSOLE) {
    PrintToServer("[%s] %s", g_DebugTag, buffer);
  }

  if (output & DEBUG_CLIENT_CONSOLE) {
    for (int i = 1; i <= MaxClients; i++) {
      if (IsClientInGame(i) && !IsFakeClient(i)) {
        PrintToConsole(i, "[%s] %s", g_DebugTag, buffer);
      }
    }
  }

  if (output & DEBUG_ADMIN_CONSOLE) {
    for (int i = 1; i <= MaxClients; i++) {
      if (IsClientInGame(i) && !IsFakeClient(i) &&
          CheckCommandAccess(i, g_DebugCvarName, g_DebugAdminFlags, true)) {
        PrintToConsole(i, "[%s] %s", g_DebugTag, buffer);
      }
    }
  }

  if (output & DEBUG_CLIENT_CHAT) {
    PrintToChatAll("[%s] %s", g_DebugTag, buffer);
  }

  if (output & DEBUG_ADMIN_CHAT) {
    for (int i = 1; i <= MaxClients; i++) {
      if (IsClientInGame(i) && !IsFakeClient(i) &&
          CheckCommandAccess(i, g_DebugCvarName, g_DebugAdminFlags, true)) {
        PrintToChat(i, "[%s] %s", g_DebugTag, buffer);
      }
    }
  }

  if (output & DEBUG_LOG_FILE) {
    LogToFileEx(g_DebugLogFileName, "[%s] %s", g_DebugTag, buffer);
  }

  return true;
}

/**
 * Returns a bitstring containing bits enabled for each output location (see DEBUG_ constants)
 *
 * @return        bitstring for enabled outputs
 */
stock int GetDebugOutputs() {
  return g_cvarDebugMode.IntValue;
}
