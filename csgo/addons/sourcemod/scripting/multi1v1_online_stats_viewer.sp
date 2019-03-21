#include "include/logdebug.inc"
#include "include/multi1v1.inc"
#include <sourcemod>

#include "multi1v1/generic.sp"
#include "multi1v1/version.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_StatsURLCvar;
ConVar g_StatsTopURLCvar;

// clang-format off
public Plugin myinfo = {
  name = "CS:GO Multi1v1: online stats viewer",
  author = "splewis",
  description = "Opens up a motd-style panel for players to view their 1v1 stats",
  version = PLUGIN_VERSION,
  url = "https://github.com/splewis/csgo-multi-1v1"
};
// clang-format on

public void OnPluginStart() {
  InitDebugLog(DEBUG_CVAR, "statsview");
  LoadTranslations("common.phrases");
  g_StatsURLCvar = CreateConVar(
      "sm_multi1v1_stats_url", "",
      "URL to send player stats to. You may use tags for userid and serverid via: {USER} and {SERVER}.  For example: http://csgo1v1.splewis.net/redirect.php?id={USER}&serverid={SERVER}.");
  g_StatsTopURLCvar = CreateConVar(
      "sm_multi1v1_top_url", "",
      "Top 15 URL. You may a tag for the serverid via: {SERVER}.  For example: http://csgo1v1.splewis.net/redirect.php?serverid={SERVER}.");
  AutoExecConfig(true, "multi1v1_online_stats_viewer", "sourcemod/multi1v1");
  RegConsoleCmd("sm_stats", Command_Stats, "Displays a players multi-1v1 stats");
  RegConsoleCmd("sm_rank", Command_Stats, "Displays a players multi-1v1 stats");
  RegConsoleCmd("sm_rating", Command_Stats, "Displays a players multi-1v1 stats");
  RegConsoleCmd("sm_top", Command_Top, "Displays top 15");
}

public Action Command_Stats(int client, int args) {
  if (!Enabled()) {
    return Plugin_Continue;
  }

  char arg1[32];
  if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
    int target = FindTarget(client, arg1, true, false);
    if (target != -1) {
      ShowStatsForPlayer(client, target);
    }
  } else {
    ShowStatsForPlayer(client, client);
  }

  return Plugin_Handled;
}

public Action Command_Top(int client, int args) {
  if (!Enabled()) {
    return Plugin_Continue;
  }

  char url[255];
  g_StatsTopURLCvar.GetString(url, sizeof(url));
  if (StrEqual(url, "")) {
    Multi1v1_Message(client, "Sorry, there is no stats website for this server.");
    return Plugin_Handled;
  }

  ConVar idCvar = FindConVar("sm_multi1v1_database_server_id");
  if (idCvar == null) {
    LogError("Failed to get id cvar: sm_multi1v1_database_server_id");
  } else {
    char serverIDString[32];
    IntToString(idCvar.IntValue, serverIDString, sizeof(serverIDString));

    ReplaceString(url, sizeof(url), "{SID}", serverIDString, false);
    ReplaceString(url, sizeof(url), "{SERVER}", serverIDString, false);
    ReplaceString(url, sizeof(url), "{SERVERID}", serverIDString, false);

    LogDebug("Giving top url %s to player %L", url, client);
    ShowMOTDPanel(client, "Multi1v1 Stats", url, MOTDPANEL_TYPE_URL);
    QueryClientConVar(client, "cl_disablehtmlmotd", CheckMOTDAllowed, client);
  }

  return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
  char chatTriggers[][] = {"rank", ".rank"};
  for (int i = 0; i < sizeof(chatTriggers); i++) {
    if (strcmp(sArgs[0], chatTriggers[i], false) == 0) {
      ShowStatsForPlayer(client, client);
    }
  }
  return Plugin_Continue;
}

public void ShowStatsForPlayer(int client, int target) {
  if (!Enabled()) {
    return;
  }

  char url[255];
  g_StatsURLCvar.GetString(url, sizeof(url));
  if (StrEqual(url, "")) {
    Multi1v1_Message(client, "Sorry, there is no stats website for this server.");
    return;
  }

  ConVar idCvar = FindConVar("sm_multi1v1_database_server_id");
  if (idCvar == null) {
    LogError("Failed to get id cvar: sm_multi1v1_database_server_id");
  } else {
    char serverIDString[32];
    IntToString(idCvar.IntValue, serverIDString, sizeof(serverIDString));

    char accountIDString[32];
    IntToString(GetSteamAccountID(target), accountIDString, sizeof(accountIDString));

    ReplaceString(url, sizeof(url), "{UID}", accountIDString, false);
    ReplaceString(url, sizeof(url), "{USER}", accountIDString, false);
    ReplaceString(url, sizeof(url), "{USERID}", accountIDString, false);
    ReplaceString(url, sizeof(url), "{SID}", serverIDString, false);
    ReplaceString(url, sizeof(url), "{SERVER}", serverIDString, false);
    ReplaceString(url, sizeof(url), "{SERVERID}", serverIDString, false);
    LogDebug("Giving stats url %s to player %L, target = %L", url, client, target);

    ShowMOTDPanel(client, "Multi1v1 Stats", url, MOTDPANEL_TYPE_URL);
    QueryClientConVar(client, "cl_disablehtmlmotd", CheckMOTDAllowed, client);
  }
}

public void CheckMOTDAllowed(QueryCookie cookie, int client, ConVarQueryResult result,
                      const char[] cvarName, const char[] cvarValue) {
  if (!StrEqual(cvarValue, "0")) {
    Multi1v1_Message(
        client, "You must have {LIGHT_GREEN}cl_disablehtmlmotd 0 {NORMAL}to use that command.");
  }
}

public bool Enabled() {
  return FindConVar("sm_multi1v1_enabled").IntValue != 0;
}
