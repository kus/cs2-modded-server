#include <cstrike>
#include <sourcemod>

#include "include/logdebug.inc"
#include "include/pugsetup.inc"
#include "pugsetup/util.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_AutoKickerEnabledCvar;
ConVar g_KickMessageCvar;
ConVar g_KickNotPickedCvar;
ConVar g_KickWhenLiveCvar;
ConVar g_TimeToReadyCvar;
ConVar g_TimeToReadyKickMessageCvar;
ConVar g_UseAdminImmunityCvar;

bool g_CompletedAdminCheck[MAXPLAYERS + 1];
int g_ClientReadyTime[MAXPLAYERS +
                      1];  // first time (seconds) when the client was capable of readying up

// clang-format off
public Plugin myinfo = {
    name = "CS:GO PugSetup: autokicker",
    author = "splewis",
    description = "Adds cvars to automatically kick players when they aren't part of the current pug",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-pug-setup"
};
// clang-format on

public void OnPluginStart() {
  LoadTranslations("pugsetup.phrases");
  g_AutoKickerEnabledCvar = CreateConVar("sm_pugsetup_autokicker_enabled", "1",
                                         "Whether the autokicker is enabled or not");
  g_KickMessageCvar = CreateConVar("sm_pugsetup_autokicker_message", "Sorry, this pug is full",
                                   "Message to show to clients when they are kicked");
  g_KickNotPickedCvar =
      CreateConVar("sm_pugsetup_autokicker_kick_not_picked", "1",
                   "Whether to kick players not selected by captains in a captain-style game");
  g_KickWhenLiveCvar = CreateConVar(
      "sm_pugsetup_autokicker_kick_when_live", "1",
      "Whether the autokicker kicks newly connecting clients during live matches when there are already full teams");
  g_TimeToReadyCvar = CreateConVar(
      "sm_pugsetup_autokicker_ready_time", "0",
      "The time (in seconds) clients have to ready up before being kicked, set to 0 to disable.");
  g_TimeToReadyKickMessageCvar = CreateConVar(
      "sm_pugsetup_autokicker_ready_time_kick_message", "You failed to ready up in time",
      "Message clients recieve when kicked for not readying up in time.");
  g_UseAdminImmunityCvar =
      CreateConVar("sm_pugsetup_autokicker_admin_immunity", "1",
                   "Whether admins (defined by pugsetup's admin flag cvar) are immune to kicks");
  AutoExecConfig(true, "pugsetup_autokicker", "sourcemod/pugsetup");
  InitDebugLog(DEBUG_CVAR, "autokicker");
}

public void OnClientConnected(int client) {
  g_CompletedAdminCheck[client] = false;
}

public void OnClientPostAdminCheck(int client) {
  g_CompletedAdminCheck[client] = true;
  bool enabled = g_AutoKickerEnabledCvar.IntValue != 0 && g_KickWhenLiveCvar.IntValue != 0;
  bool live = PugSetup_IsMatchLive() || PugSetup_IsPendingStart();

  if (enabled && live && !PugSetup_PlayerAtStart(client)) {
    int count = 0;
    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i)) {
        int team = GetClientTeam(i);
        if (team != CS_TEAM_NONE && team != CS_TEAM_SPECTATOR) {
          count++;
        }
      }
    }

    LogDebug("%L connected, count of players = %d", client, count);
    if (count >= PugSetup_GetPugMaxPlayers()) {
      Kick(client, g_KickMessageCvar);
    }
  }

  if (g_AutoKickerEnabledCvar.IntValue != 0) {
    g_ClientReadyTime[client] = GetTime();
  }
}

public void PugSetup_OnSetup() {
  for (int i = 1; i <= MaxClients; i++) {
    g_ClientReadyTime[i] = GetTime();
  }
}

public void PugSetup_OnNotPicked(int client) {
  if (g_AutoKickerEnabledCvar.IntValue != 0 && g_KickNotPickedCvar.IntValue != 0) {
    Kick(client, g_KickMessageCvar);
  }
}

public void PugSetup_OnReadyToStartCheck(int readyPlayers, int totalPlayers) {
  if (g_AutoKickerEnabledCvar.IntValue != 0 && g_TimeToReadyCvar.IntValue != 0) {
    for (int i = 1; i <= MaxClients; i++) {
      int dt = GetTime() - g_ClientReadyTime[i];
      if (g_CompletedAdminCheck[i] && IsPlayer(i) && !PugSetup_IsReady(i) &&
          dt > g_TimeToReadyCvar.IntValue) {
        Kick(i, g_TimeToReadyKickMessageCvar);
      }
    }
  }
}

static void Kick(int client, ConVar msgCvar) {
  if (g_UseAdminImmunityCvar.IntValue != 0 && PugSetup_IsPugAdmin(client)) {
    LogDebug("Blocking kick of %L since he is an admin", client);
    return;
  }

  char msg[1024];
  GetConVarString(msgCvar, msg, sizeof(msg));
  KickClient(client, msg);
  LogDebug("Kicking %L with message %s", client, msg);
}
