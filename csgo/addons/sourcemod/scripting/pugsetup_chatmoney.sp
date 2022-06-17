#include <cstrike>
#include <sourcemod>

#include "include/pugsetup.inc"
#include "pugsetup/util.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_hEnabled;

// clang-format off
public Plugin myinfo = {
    name = "CS:GO PugSetup: write team money to chat",
    author = "Versatile_BFG/jkroepke",
    description = "Write the team members' money to the chat (like WarMod)",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-pug-setup"
};
// clang-format on

public void OnPluginStart() {
  LoadTranslations("pugsetup.phrases");
  g_hEnabled = CreateConVar("sm_pugsetup_chatmoney_enabled", "1", "Whether the plugin is enabled");
  AutoExecConfig(true, "pugsetup_chatmoney", "sourcemod/pugsetup");
  HookEvent("round_start", Event_Round_Start);
}

public Action Event_Round_Start(Event event, const char[] name, bool dontBroadcast) {
  if (!PugSetup_IsMatchLive() || g_hEnabled.IntValue == 0)
    return;

  ArrayList players = new ArrayList();

  // sort by money
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && OnActiveTeam(i)) {
      players.Push(i);
    }
  }

  SortADTArrayCustom(players, SortMoneyFunction);

  char player_money[16];
  char has_weapon[4];
  int pri_weapon;

  int numPlayers = players.Length;

  // display team players money
  for (int i = 0; i < numPlayers; i++) {
    for (int j = 0; j < numPlayers; j++) {
      int displayClient = players.Get(i);
      int moneyClient = players.Get(j);

      if (GetClientTeam(displayClient) == GetClientTeam(moneyClient)) {
        pri_weapon = GetPlayerWeaponSlot(moneyClient, 0);
        if (pri_weapon == -1) {
          has_weapon = ">";
        } else {
          has_weapon = "\0";
        }
        IntToMoney(GetClientMoney(moneyClient), player_money, sizeof(player_money));
        PugSetup_Message(displayClient, "\x01$%s \x04%s> \x03%N", player_money, has_weapon,
                         moneyClient);
      }
    }
  }

  delete players;
}

public int SortMoneyFunction(int index1, int index2, Handle array, Handle hnd) {
  int client1 = GetArrayCell(array, index1);
  int client2 = GetArrayCell(array, index2);
  int money1 = GetClientMoney(client1);
  int money2 = GetClientMoney(client2);

  if (money1 > money2) {
    return -1;
  } else if (money1 == money2) {
    return 0;
  } else {
    return 1;
  }
}

public int GetClientMoney(int client) {
  int offset = FindSendPropInfo("CCSPlayer", "m_iAccount");
  return GetEntData(client, offset);
}

/**
* Get the comma'd string version of an integer
*
* @param  OldMoney          the integer to convert
* @param  String:NewMoney   the buffer to save the string in
* @param  size              the size of the buffer
* @noreturn
*/
public void IntToMoney(int OldMoney, char[] NewMoney, int size) {
  char Temp[32];
  char OldMoneyStr[32];
  char tempChar;
  int RealLen = 0;

  IntToString(OldMoney, OldMoneyStr, sizeof(OldMoneyStr));

  for (int i = strlen(OldMoneyStr) - 1; i >= 0; i--) {
    if (RealLen % 3 == 0 && RealLen != strlen(OldMoneyStr) && i != strlen(OldMoneyStr) - 1) {
      tempChar = OldMoneyStr[i];
      Format(Temp, sizeof(Temp), "%s,%s", tempChar, Temp);
    } else {
      tempChar = OldMoneyStr[i];
      Format(Temp, sizeof(Temp), "%s%s", tempChar, Temp);
    }
    RealLen++;
  }
  Format(NewMoney, size, "%s", Temp);
}
