#include <clientprefs>
#include <cstrike>
#include <geoip>
#include <sourcemod>

#include "include/logdebug.inc"
#include "include/pugsetup.inc"
#include "pugsetup/util.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_UseCaptainNamesCvar;

/** Client cookie handles **/
Handle g_teamNameCookie = INVALID_HANDLE;
Handle g_teamFlagCookie = INVALID_HANDLE;
#define TEAM_NAME_LENGTH 128
#define TEAM_FLAG_LENGTH 4

// clang-format off
public Plugin myinfo = {
    name = "CS:GO PugSetup: team names setter",
    author = "splewis",
    description = "Sets team names/flags on game going live",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-pug-setup"
};
// clang-format on

public void OnPluginStart() {
  InitDebugLog(DEBUG_CVAR, "teamnames");
  LoadTranslations("common.phrases");
  LoadTranslations("pugsetup.phrases");
  RegAdminCmd(
      "sm_name", Command_Name, ADMFLAG_CHANGEMAP,
      "Sets a team name/flag to go with a player: sm_name <player> <teamname> <teamflag>, use quotes for the team name if it includes a space!");
  RegAdminCmd("sm_listnames", Command_ListNames, ADMFLAG_CHANGEMAP,
              "Lists all players' and their team names/flag, if they have one set.");
  g_teamNameCookie =
      RegClientCookie("pugsetup_teamname", "Pugsetup team name", CookieAccess_Protected);
  g_teamFlagCookie = RegClientCookie(
      "pugsetup_teamflag", "Pugsetup team flag (2-letter country code)", CookieAccess_Protected);
  g_UseCaptainNamesCvar = CreateConVar(
      "sm_pugsetup_use_captain_names", "1",
      "Whether to use captain's team name. If disabled, a random player's team name is chosen.");
}

public void PugSetup_OnGoingLive() {
  ArrayList ctNames = new ArrayList(TEAM_NAME_LENGTH);
  ArrayList ctFlags = new ArrayList(TEAM_FLAG_LENGTH);
  ArrayList tNames = new ArrayList(TEAM_NAME_LENGTH);
  ArrayList tFlags = new ArrayList(TEAM_FLAG_LENGTH);

  FillPotentialNames(CS_TEAM_CT, ctNames, ctFlags);
  FillPotentialNames(CS_TEAM_T, tNames, tFlags);

  int choice = -1;
  char name[TEAM_NAME_LENGTH];
  char flag[TEAM_FLAG_LENGTH];

  if (GetArraySize(ctNames) > 0) {
    choice = GetArrayRandomIndex(ctNames);
    GetArrayString(ctNames, choice, name, sizeof(name));
    GetArrayString(ctFlags, choice, flag, sizeof(flag));
    LogDebug("Setting ct name, flag = %s, %s", name, flag);
    SetTeamInfo(CS_TEAM_CT, name, flag);
  }

  if (GetArraySize(tNames) > 0) {
    choice = GetArrayRandomIndex(tNames);
    GetArrayString(tNames, choice, name, sizeof(name));
    GetArrayString(tFlags, choice, flag, sizeof(flag));
    LogDebug("Setting t name, flag = %s, %s", name, flag);
    SetTeamInfo(CS_TEAM_T, name, flag);
  }

  delete ctNames;
  delete ctFlags;
  delete tNames;
  delete tFlags;
}

public Action Command_ListNames(int client, int args) {
  int count = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && AreClientCookiesCached(i)) {
      char name[TEAM_NAME_LENGTH];
      char flag[TEAM_FLAG_LENGTH];
      GetClientCookie(i, g_teamNameCookie, name, sizeof(name));
      GetClientCookie(i, g_teamFlagCookie, flag, sizeof(flag));
      if (!StrEqual(name, "")) {
        ReplyToCommand(client, "%N: %s (%s)", i, name, flag);
        count++;
      }
    }
  }
  if (count == 0)
    ReplyToCommand(client, "Nobody has a team name/flag set.");

  return Plugin_Handled;
}

public Action Command_Name(int client, int args) {
  char arg1[MAX_NAME_LENGTH];
  char arg2[TEAM_NAME_LENGTH];

  if (args >= 2 && GetCmdArg(1, arg1, sizeof(arg1)) && GetCmdArg(2, arg2, sizeof(arg2))) {
    int target = FindTarget(client, arg1, true, false);
    char flag[3];

    if (IsPlayer(target)) {
      SetClientCookie(target, g_teamNameCookie, arg2);

      // by default, use arg3 from the command, otherwise try to use the ip address
      if (args <= 2 || !GetCmdArg(3, flag, sizeof(flag))) {
        if (GetPlayerFlagFromIP(target, flag))
          SetClientCookie(target, g_teamFlagCookie, flag);
      }
      SetClientCookie(target, g_teamFlagCookie, flag);
      ReplyToCommand(client, "Set team data for %L: name = %s, flag = %s", target, arg2, flag);
    }

  } else {
    ReplyToCommand(client, "Usage: sm_name <player> <team name> [team flag code]");
  }

  return Plugin_Handled;
}

static bool GetPlayerFlagFromIP(int client, char flag[3]) {
  char ip[32];
  if (!GetClientIP(client, ip, sizeof(ip)) || !GeoipCode2(ip, flag)) {
    Format(flag, sizeof(flag), "");
    return true;
  }
  return false;
}

public void FillPotentialNames(int team, ArrayList names, ArrayList flags) {
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && GetClientTeam(i) == team && AreClientCookiesCached(i)) {
      if (g_UseCaptainNamesCvar.IntValue != 0 && PugSetup_GetTeamType() == TeamType_Captains) {
        // Only allow captains
        if (i != PugSetup_GetCaptain(1) && i != PugSetup_GetCaptain(2))
          continue;
      }
      char name[TEAM_NAME_LENGTH];
      char flag[TEAM_FLAG_LENGTH];
      GetClientCookie(i, g_teamNameCookie, name, sizeof(name));
      GetClientCookie(i, g_teamFlagCookie, flag, sizeof(flag));

      if (StrEqual(name, ""))
        continue;

      names.PushString(name);
      flags.PushString(flag);
    }
  }

  // if we have no results, might as well throw in some geo-ip flags with empty names
  if (names.Length == 0) {
    for (int i = 1; i <= MaxClients; i++) {
      char flag[3];
      if (IsPlayer(i) && GetClientTeam(i) == team && GetPlayerFlagFromIP(i, flag)) {
        names.PushString("");
        flags.PushString(flag);
      }
    }
  }
}

/** Clear the names/flags when the game is over **/
public void PugSetup_OnMatchOver(bool hasDemo, const char[] demoFileName) {
  LogDebug("Match over - resetting team names");
  SetTeamInfo(CS_TEAM_T, "", "");
  SetTeamInfo(CS_TEAM_CT, "", "");
}
