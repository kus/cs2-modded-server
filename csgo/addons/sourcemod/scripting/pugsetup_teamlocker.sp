#include <cstrike>
#include <sourcemod>

#include "include/logdebug.inc"
#include "include/pugsetup.inc"
#include "pugsetup/util.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_hBlockSpecJoins;
ConVar g_hKickTime;
ConVar g_hLockTeamsEnabled;

// clang-format off
public Plugin myinfo = {
    name = "CS:GO PugSetup: team locker",
    author = "splewis",
    description = "Blocks team join events to full teams",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-pug-setup"
};
// clang-format on

public void OnPluginStart() {
  InitDebugLog(DEBUG_CVAR, "teamlock");

  g_hBlockSpecJoins = CreateConVar(
      "sm_pugsetup_block_spectate_joins", "1",
      "Whether players are blocked from joining spectator (admins excluded) during a live match.");
  g_hKickTime = CreateConVar(
      "sm_pugsetup_kick_time", "0",
      "If players don't join a team after this many seconds, they will be kicked. Use 0 to disable.");
  g_hLockTeamsEnabled = CreateConVar("sm_pugsetup_teamlocker_enabled", "1",
                                     "Whether teams are locked when matches are live.");

  AutoExecConfig(true, "pugsetup_teamlocker", "sourcemod/pugsetup");
  AddCommandListener(Command_JoinTeam, "jointeam");
  HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre);
}

public void OnClientPutInServer(int client) {
  if (PugSetup_GetGameState() == GameState_None) {
    return;
  }

  int kickTime = g_hKickTime.IntValue;
  if (kickTime != 0) {
    CreateTimer(float(kickTime), Timer_CheckIfSpectator, GetClientSerial(client));
  }
}

public Action Timer_CheckIfSpectator(Handle timer, int serial) {
  if (PugSetup_GetGameState() == GameState_None) {
    return Plugin_Handled;
  }

  int client = GetClientFromSerial(serial);
  if (IsPlayer(client) && !PugSetup_IsPugAdmin(client)) {
    int team = GetClientTeam(client);
    if (team == CS_TEAM_SPECTATOR || team == CS_TEAM_NONE) {
      KickClient(client, "You did not join a team in time");
    }
  }

  return Plugin_Handled;
}

public Action Event_OnPlayerTeam(Event event, const char[] name, bool dontBroadcast) {
  return Plugin_Continue;
}

public Action Command_JoinTeam(int client, const char[] command, int argc) {
  if (!IsValidClient(client))
    return Plugin_Stop;

  if (g_hLockTeamsEnabled.IntValue == 0)
    return Plugin_Continue;

  // blocks changes during team-selection/lo3-process
  if (PugSetup_IsPendingStart())
    return Plugin_Stop;

  // don't do anything if not live/not in startup phase
  if (!PugSetup_IsMatchLive())
    return Plugin_Continue;

  char arg[4];
  GetCmdArg(1, arg, sizeof(arg));
  int team_to = StringToInt(arg);

  LogDebug("%L jointeam command, from %d to %d", client, GetClientTeam(client), team_to);

  // don't let someone change to a "none" team (e.g. using auto-select)
  if (team_to == CS_TEAM_NONE)
    return Plugin_Stop;

  if (team_to == CS_TEAM_SPECTATOR && !PugSetup_IsPugAdmin(client) &&
      g_hBlockSpecJoins.IntValue != 0)
    return Plugin_Stop;

  int playerCount = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && GetClientTeam(i) == team_to) {
      playerCount++;
    }
  }

  LogDebug("playerCount on team %d = %d", team_to, playerCount);

  if (playerCount >= PugSetup_GetPugMaxPlayers() / 2) {
    LogDebug("blocking jointeam");
    return Plugin_Stop;
  } else {
    LogDebug("allowing jointeam");
    return Plugin_Continue;
  }
}
