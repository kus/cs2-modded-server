#include <cstrike>
#include <sourcemod>

#include "include/pugsetup.inc"
#include "pugsetup/util.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_hAutoColorize;
ConVar g_hAllowDmgCommand;
ConVar g_hEnabled;
ConVar g_hMessageFormat;

int g_DamageDone[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_DamageDoneHits[MAXPLAYERS + 1][MAXPLAYERS + 1];
bool g_GotKill[MAXPLAYERS + 1][MAXPLAYERS + 1];

// clang-format off
public Plugin myinfo = {
    name = "CS:GO PugSetup: damage printer",
    author = "splewis",
    description = "Writes out player damage on round end or when .dmg is used",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-pug-setup"
};
// clang-format on

public void OnPluginStart() {
  LoadTranslations("pugsetup.phrases");
  g_hAutoColorize = CreateConVar(
      "sm_pugsetup_damageprint_auto_color", "0",
      "Whether colors are automatically inserted for damage values, changing depending on if the damage resulted in a kill");
  g_hEnabled =
      CreateConVar("sm_pugsetup_damageprint_enabled", "1", "Whether the plugin is enabled");
  g_hAllowDmgCommand = CreateConVar("sm_pugsetup_damageprint_allow_dmg_command", "1",
                                    "Whether players can type .dmg to see damage done");
  g_hMessageFormat = CreateConVar(
      "sm_pugsetup_damageprint_format",
      "--> ({DMG_TO} dmg / {HITS_TO} hits) to ({DMG_FROM} dmg / {HITS_FROM} hits) from {NAME} ({HEALTH} HP)",
      "Format of the damage output string. Avaliable tags are in the default, color tags such as {LIGHT_RED} and {GREEN} also work.");

  AutoExecConfig(true, "pugsetup_damageprint", "sourcemod/pugsetup");

  RegConsoleCmd("sm_dmg", Command_Damage, "Displays damage done");
  PugSetup_AddChatAlias(".dmg", "sm_dmg");

  HookEvent("round_start", Event_RoundStart);
  HookEvent("player_hurt", Event_DamageDealt, EventHookMode_Pre);
  HookEvent("player_death", Event_PlayerDeath);
  HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
}

static void GetDamageColor(char color[16], bool damageGiven, int damage, bool gotKill) {
  if (damage == 0) {
    Format(color, sizeof(color), "NORMAL");
  } else if (damageGiven) {
    if (gotKill) {
      Format(color, sizeof(color), "GREEN");
    } else {
      Format(color, sizeof(color), "LIGHT_GREEN");
    }
  } else {
    if (gotKill) {
      Format(color, sizeof(color), "DARK_RED");
    } else {
      Format(color, sizeof(color), "LIGHT_RED");
    }
  }
}

static void PrintDamageInfo(int client) {
  if (!IsValidClient(client))
    return;

  int team = GetClientTeam(client);
  if (team != CS_TEAM_T && team != CS_TEAM_CT)
    return;

  char message[256];

  int otherTeam = (team == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsValidClient(i) && GetClientTeam(i) == otherTeam) {
      int health = IsPlayerAlive(i) ? GetClientHealth(i) : 0;
      char name[64];
      GetClientName(i, name, sizeof(name));

      g_hMessageFormat.GetString(message, sizeof(message));

      if (g_hAutoColorize.IntValue == 0) {
        ReplaceStringWithInt(message, sizeof(message), "{DMG_TO}", g_DamageDone[client][i]);
        ReplaceStringWithInt(message, sizeof(message), "{HITS_TO}", g_DamageDoneHits[client][i]);
        ReplaceStringWithInt(message, sizeof(message), "{DMG_FROM}", g_DamageDone[i][client]);
        ReplaceStringWithInt(message, sizeof(message), "{HITS_FROM}", g_DamageDoneHits[i][client]);
        ReplaceString(message, sizeof(message), "{NAME}", name);
        ReplaceStringWithInt(message, sizeof(message), "{HEALTH}", health);
        Colorize(message, sizeof(message));
      } else {
        // Strip colors first.
        Colorize(message, sizeof(message), true);
        char color[16];

        GetDamageColor(color, true, g_DamageDone[client][i], g_GotKill[client][i]);
        ReplaceStringWithColoredInt(message, sizeof(message), "{DMG_TO}", g_DamageDone[client][i],
                                    color);
        ReplaceStringWithColoredInt(message, sizeof(message), "{HITS_TO}",
                                    g_DamageDoneHits[client][i], color);

        GetDamageColor(color, false, g_DamageDone[i][client], g_GotKill[i][client]);
        ReplaceStringWithColoredInt(message, sizeof(message), "{DMG_FROM}", g_DamageDone[i][client],
                                    color);
        ReplaceStringWithColoredInt(message, sizeof(message), "{HITS_FROM}",
                                    g_DamageDoneHits[i][client], color);

        ReplaceString(message, sizeof(message), "{NAME}", name);
        ReplaceStringWithInt(message, sizeof(message), "{HEALTH}", health);
        Colorize(message, sizeof(message));
      }

      PrintToChat(client, message);
    }
  }
}

public Action Command_Damage(int client, int args) {
  if (!PugSetup_IsMatchLive() || g_hEnabled.IntValue == 0 || g_hAllowDmgCommand.IntValue == 0)
    return Plugin_Handled;

  if (IsPlayerAlive(client)) {
    PugSetup_Message(client, "You cannot use that command when alive.");
    return Plugin_Handled;
  }

  PrintDamageInfo(client);
  return Plugin_Handled;
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
  if (!PugSetup_IsMatchLive() || g_hEnabled.IntValue == 0)
    return;

  for (int i = 1; i <= MaxClients; i++) {
    if (IsValidClient(i)) {
      PrintDamageInfo(i);
    }
  }
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
  for (int i = 1; i <= MaxClients; i++) {
    for (int j = 1; j <= MaxClients; j++) {
      g_DamageDone[i][j] = 0;
      g_DamageDoneHits[i][j] = 0;
      g_GotKill[i][j] = false;
    }
  }
}

public Action Event_DamageDealt(Event event, const char[] name, bool dontBroadcast) {
  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  int victim = GetClientOfUserId(event.GetInt("userid"));
  bool validAttacker = IsValidClient(attacker);
  bool validVictim = IsValidClient(victim);

  if (validAttacker && validVictim) {
    int preDamageHealth = GetClientHealth(victim);
    int damage = event.GetInt("dmg_health");
    int postDamageHealth = event.GetInt("health");

    // this maxes the damage variables at 100,
    // so doing 50 damage when the player had 2 health
    // only counts as 2 damage.
    if (postDamageHealth == 0) {
      damage += preDamageHealth;
    }

    g_DamageDone[attacker][victim] += damage;
    g_DamageDoneHits[attacker][victim]++;
  }
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  int victim = GetClientOfUserId(event.GetInt("userid"));
  bool validAttacker = IsValidClient(attacker);
  bool validVictim = IsValidClient(victim);

  if (validAttacker && validVictim) {
    g_GotKill[attacker][victim] = true;
  }
}
