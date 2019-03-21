/**
 * This blocks all radio commands, assuming AddRadioCommandListeners is called.
 */

char g_radioCommands[][] = {
    "go",         "cheer",     "fallback",    "sticktog",   "holdpos",    "followme",
    "roger",      "negative",  "cheer",       "compliment", "thanks",     "enemyspot",
    "needbackup", "takepoint", "sectorclear", "inposition", "takingfire", "reportingin",
    "getout",     "enemydown", "coverme",     "regroup",
};

public void AddRadioCommandListeners() {
  for (int i = 0; i < sizeof(g_radioCommands); i++)
    AddCommandListener(Command_Radio, g_radioCommands[i]);
}

public Action Command_Radio(int client, const char[] command, int argc) {
  if (!g_Enabled) {
    return Plugin_Continue;
  }

  if (g_BlockRadioCvar.IntValue != 0) {
    return Plugin_Handled;
  } else {
    return Plugin_Continue;
  }
}
