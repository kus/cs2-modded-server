#include <clientprefs>
#include <cstrike>
#include <sourcemod>

#include "include/logdebug.inc"
#include "include/priorityqueue.inc"
#include "include/pugsetup.inc"
#include "pugsetup/util.sp"

#pragma semicolon 1
#pragma newdecls required

/*
 * This isn't meant to be a comprehensive stats system, it's meant to be a simple
 * way to balance teams to replace manual stuff using a (exponentially) weighted moving average.
 * The update takes place every round, following this equation
 *
 * R' = (1-a) * R_prev + alpha * R
 * Where
 *    R' is the new rating
 *    a is the alpha factor (how much a new round counts into the new rating)
 *    R is the round-rating
 *
 * Alpha is made to be variable, where it decreases linearly to allow
 * ratings to change more quickly early on when a player has few rounds played.
 */
#define ALPHA_INIT 0.1
#define ALPHA_FINAL 0.003
#define ROUNDS_FINAL 250.0
#define AUTH_METHOD AuthId_Steam2

/** Client cookie handles **/
Handle g_RWSCookie = INVALID_HANDLE;
Handle g_RoundsPlayedCookie = INVALID_HANDLE;

/** Client stats **/
float g_PlayerRWS[MAXPLAYERS + 1];
int g_PlayerRounds[MAXPLAYERS + 1];
bool g_PlayerHasStats[MAXPLAYERS + 1];

/** Rounds stats **/
int g_RoundPoints[MAXPLAYERS + 1];

/** Cvars **/
ConVar g_AllowRWSCommandCvar;
ConVar g_RecordRWSCvar;
ConVar g_PugSetup_SetCaptainsByRWSCvar;
ConVar g_ShowRWSOnMenuCvar;

bool g_ManuallySetCaptains = false;
bool g_SetTeamBalancer = false;

// clang-format off
public Plugin myinfo = {
    name = "CS:GO PugSetup: RWS balancer",
    author = "splewis",
    description = "Sets player teams based on historical RWS ratings stored via clientprefs cookies",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-pug-setup"
};
// clang-format on

public void OnPluginStart() {
  InitDebugLog(DEBUG_CVAR, "rwsbalance");
  LoadTranslations("pugsetup.phrases");
  LoadTranslations("common.phrases");

  HookEvent("bomb_defused", Event_Bomb);
  HookEvent("bomb_planted", Event_Bomb);
  HookEvent("player_death", Event_PlayerDeath);
  HookEvent("player_hurt", Event_DamageDealt);
  HookEvent("round_end", Event_RoundEnd);

  RegAdminCmd("sm_showrws", Command_DumpRWS, ADMFLAG_KICK,
              "Dumps all player historical rws and rounds played");
  RegConsoleCmd("sm_rws", Command_RWS, "Show player's historical rws");
  PugSetup_AddChatAlias(".rws", "sm_rws");

  g_AllowRWSCommandCvar =
      CreateConVar("sm_pugsetup_rws_allow_rws_command", "0",
                   "Whether players can use the .rws or !rws command on other players");
  g_RecordRWSCvar = CreateConVar(
      "sm_pugsetup_rws_record_stats", "1",
      "Whether rws should be recorded during live matches (set to 0 to disable changing players rws stats)");
  g_PugSetup_SetCaptainsByRWSCvar = CreateConVar(
      "sm_pugsetup_rws_set_captains", "1",
      "Whether to set captains to the highest-rws players in a game using captains. Note: this behavior can be overwritten by the pug-leader or admins.");
  g_ShowRWSOnMenuCvar =
      CreateConVar("sm_pugsetup_rws_display_on_menu", "0",
                   "Whether rws stats are to be displayed on captain-player selection menus");

  AutoExecConfig(true, "pugsetup_rwsbalancer", "sourcemod/pugsetup");

  g_RWSCookie = RegClientCookie("pugsetup_rws", "Pugsetup RWS rating", CookieAccess_Protected);
  g_RoundsPlayedCookie =
      RegClientCookie("pugsetup_roundsplayed", "Pugsetup rounds played", CookieAccess_Protected);
}

public void OnAllPluginsLoaded() {
  g_SetTeamBalancer = PugSetup_SetTeamBalancer(BalancerFunction);
}

public void OnPluginEnd() {
  if (g_SetTeamBalancer)
    PugSetup_ClearTeamBalancer();
}

public void OnMapStart() {
  g_ManuallySetCaptains = false;
}

public void PugSetup_OnPermissionCheck(int client, const char[] command, Permission p, bool& allow) {
  if (StrEqual(command, "sm_capt", false)) {
    g_ManuallySetCaptains = true;
  }
}

public void OnClientCookiesCached(int client) {
  if (IsFakeClient(client))
    return;

  g_PlayerRWS[client] = GetCookieFloat(client, g_RWSCookie);
  g_PlayerRounds[client] = GetCookieInt(client, g_RoundsPlayedCookie);
  g_PlayerHasStats[client] = true;
}

public void OnClientConnected(int client) {
  g_PlayerRWS[client] = 0.0;
  g_PlayerRounds[client] = 0;
  g_RoundPoints[client] = 0;
  g_PlayerHasStats[client] = false;
}

public void OnClientDisconnect(int client) {
  WriteStats(client);
}

public bool HasStats(int client) {
  return g_PlayerHasStats[client];
}

public void WriteStats(int client) {
  if (!IsValidClient(client) || IsFakeClient(client) || !g_PlayerHasStats[client])
    return;

  SetCookieInt(client, g_RoundsPlayedCookie, g_PlayerRounds[client]);
  SetCookieFloat(client, g_RWSCookie, g_PlayerRWS[client]);
}

/**
 * Here the teams are actually set to use the rws stuff.
 */
public void BalancerFunction(ArrayList players) {
  Handle pq = PQ_Init();

  for (int i = 0; i < players.Length; i++) {
    int client = players.Get(i);
    PQ_Enqueue(pq, client, g_PlayerRWS[client]);
    LogDebug("PQ_Enqueue(%L, %f)", client, g_PlayerRWS[client]);
  }

  int count = 0;

  while (!PQ_IsEmpty(pq) && count < PugSetup_GetPugMaxPlayers()) {
    int p1 = PQ_Dequeue(pq);
    int p2 = PQ_Dequeue(pq);

    if (IsPlayer(p1)) {
      SwitchPlayerTeam(p1, CS_TEAM_CT);
      LogDebug("CT: PQ_Dequeue() = %L, rws=%f", p1, g_PlayerRWS[p1]);
    }

    if (IsPlayer(p2)) {
      SwitchPlayerTeam(p2, CS_TEAM_T);
      LogDebug("T : PQ_Dequeue() = %L, rws=%f", p2, g_PlayerRWS[p2]);
    }

    count += 2;
  }

  while (!PQ_IsEmpty(pq)) {
    int client = PQ_Dequeue(pq);
    if (IsPlayer(client))
      SwitchPlayerTeam(client, CS_TEAM_SPECTATOR);
  }

  CloseHandle(pq);
}

/**
 * These events update player "rounds points" for computing rws at the end of each round.
 */
public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
  if (!PugSetup_IsMatchLive())
    return;

  int victim = GetClientOfUserId(event.GetInt("userid"));
  int attacker = GetClientOfUserId(event.GetInt("attacker"));

  bool validAttacker = IsValidClient(attacker);
  bool validVictim = IsValidClient(victim);

  if (validAttacker && validVictim && HelpfulAttack(attacker, victim)) {
    g_RoundPoints[attacker] += 100;
  }
}

public Action Event_Bomb(Event event, const char[] name, bool dontBroadcast) {
  if (!PugSetup_IsMatchLive())
    return;

  int client = GetClientOfUserId(event.GetInt("userid"));
  g_RoundPoints[client] += 50;
}

public Action Event_DamageDealt(Event event, const char[] name, bool dontBroadcast) {
  if (!PugSetup_IsMatchLive())
    return;

  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  int victim = GetClientOfUserId(event.GetInt("userid"));
  bool validAttacker = IsValidClient(attacker);
  bool validVictim = IsValidClient(victim);

  if (validAttacker && validVictim && HelpfulAttack(attacker, victim)) {
    int damage = event.GetInt("dmg_health");
    g_RoundPoints[attacker] += damage;
  }
}

public bool HelpfulAttack(int attacker, int victim) {
  if (!IsValidClient(attacker) || !IsValidClient(victim)) {
    return false;
  }
  int ateam = GetClientTeam(attacker);
  int vteam = GetClientTeam(victim);
  return ateam != vteam && attacker != victim;
}

/**
 * Round end event, updates rws values for everyone.
 */
public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
  if (!PugSetup_IsMatchLive() || g_RecordRWSCvar.IntValue == 0)
    return;

  int winner = event.GetInt("winner");
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && HasStats(i)) {
      int team = GetClientTeam(i);
      if (team == CS_TEAM_CT || team == CS_TEAM_T)
        RWSUpdate(i, team == winner);
    }
  }
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && HasStats(i)) {
      g_RoundPoints[i] = 0;
    }
  }
}

/**
 * Here we apply magic updates to a player's rws based on the previous round.
 */
static void RWSUpdate(int client, bool winner) {
  float rws = 0.0;
  if (winner) {
    int playerCount = 0;
    int sum = 0;
    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i)) {
        if (GetClientTeam(i) == GetClientTeam(client)) {
          sum += g_RoundPoints[i];
          playerCount++;
        }
      }
    }

    if (sum != 0) {
      // scaled so it's always considered "out of 5 players" so different team sizes
      // don't give inflated rws
      rws = 100.0 * float(playerCount) / 5.0 * float(g_RoundPoints[client]) / float(sum);
    } else {
      return;
    }

  } else {
    rws = 0.0;
  }

  float alpha = GetAlphaFactor(client);
  g_PlayerRWS[client] = (1.0 - alpha) * g_PlayerRWS[client] + alpha * rws;
  g_PlayerRounds[client]++;
  LogDebug("RoundUpdate(%L), alpha=%f, round_rws=%f, new_rws=%f", client, alpha, rws,
           g_PlayerRWS[client]);
}

static float GetAlphaFactor(int client) {
  float rounds = float(g_PlayerRounds[client]);
  if (rounds < ROUNDS_FINAL) {
    return ALPHA_INIT + (ALPHA_INIT - ALPHA_FINAL) / (-ROUNDS_FINAL) * rounds;
  } else {
    return ALPHA_FINAL;
  }
}

public int rwsSortFunction(int index1, int index2, Handle array, Handle hndl) {
  int client1 = GetArrayCell(array, index1);
  int client2 = GetArrayCell(array, index2);
  return g_PlayerRWS[client1] < g_PlayerRWS[client2];
}

public void PugSetup_OnReadyToStartCheck(int readyPlayers, int totalPlayers) {
  if (!g_ManuallySetCaptains && g_PugSetup_SetCaptainsByRWSCvar.IntValue != 0 &&
      totalPlayers >= PugSetup_GetPugMaxPlayers() && PugSetup_GetTeamType() == TeamType_Captains) {
    // The idea is to set the captains to the 2 highest rws players,
    // so they are thrown into an array and sorted by rws,
    // then the captains are set to the first 2 elements of the array.

    ArrayList players = new ArrayList();

    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i))
        PushArrayCell(players, i);
    }

    SortADTArrayCustom(players, rwsSortFunction);

    if (players.Length >= 1)
      PugSetup_SetCaptain(1, GetArrayCell(players, 0));

    if (players.Length >= 2)
      PugSetup_SetCaptain(2, GetArrayCell(players, 1));

    delete players;
  }
}

public Action Command_DumpRWS(int client, int args) {
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && HasStats(i)) {
      ReplyToCommand(client, "%L has RWS=%f, roundsplayed=%d", i, g_PlayerRWS[i],
                     g_PlayerRounds[i]);
    }
  }

  return Plugin_Handled;
}

public Action Command_RWS(int client, int args) {
  if (g_AllowRWSCommandCvar.IntValue == 0) {
    return Plugin_Handled;
  }

  char arg1[32];
  if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
    int target = FindTarget(client, arg1, true, false);
    if (target != -1) {
      if (HasStats(target))
        PugSetup_Message(client, "%N has a RWS of %.1f with %d rounds played", target,
                         g_PlayerRWS[target], g_PlayerRounds[target]);
      else
        PugSetup_Message(client, "%N does not currently have stats stored", target);
    }
  } else {
    PugSetup_Message(client, "Usage: .rws <player>");
  }

  return Plugin_Handled;
}

public void PugSetup_OnPlayerAddedToCaptainMenu(Menu menu, int client, char[] menuString, int length) {
  if (g_ShowRWSOnMenuCvar.IntValue != 0 && HasStats(client)) {
    Format(menuString, length, "%N [%.1f RWS]", client, g_PlayerRWS[client]);
  }
}
