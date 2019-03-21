#include "include/multi1v1.inc"
#include "multi1v1/generic.sp"
#include "multi1v1/version.sp"
#include <clientprefs>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

bool g_GiveFlash[MAXPLAYERS + 1];
Handle g_hFlashCookie = INVALID_HANDLE;

// clang-format off
public Plugin myinfo = {
  name = "CS:GO Multi1v1: flashbangs addon",
  author = "splewis",
  description = "Adds an option to give players flashbangs",
  version = PLUGIN_VERSION,
  url = "https://github.com/splewis/csgo-multi-1v1"
};
// clang-format on

public void OnPluginStart() {
  LoadTranslations("multi1v1.phrases");
  g_hFlashCookie = RegClientCookie("multi1v1_flashbang", "Multi-1v1 allow flashbangs in rounds",
                                   CookieAccess_Protected);
}

public void OnClientConnected(int client) {
  g_GiveFlash[client] = false;
}

public void Multi1v1_OnGunsMenuCreated(int client, Menu menu) {
  char enabledString[32];
  GetEnabledString(enabledString, sizeof(enabledString), g_GiveFlash[client], client);
  AddMenuOption(menu, "flashbangs", "Flashbangs: %s", enabledString);
}

public void Multi1v1_GunsMenuCallback(Menu menu, MenuAction action, int param1, int param2) {
  if (action == MenuAction_Select) {
    int client = param1;
    char buffer[128];
    menu.GetItem(param2, buffer, sizeof(buffer));
    if (StrEqual(buffer, "flashbangs")) {
      g_GiveFlash[client] = !g_GiveFlash[client];
      SetCookieBool(client, g_hFlashCookie, g_GiveFlash[client]);
      Multi1v1_GiveWeaponsMenu(client, GetMenuSelectionPosition());
    }
  }
}

public void Multi1v1_AfterPlayerSetup(int client) {
  if (!IsActivePlayer(client)) {
    return;
  }

  int arena = Multi1v1_GetArenaNumber(client);
  int p1 = Multi1v1_GetArenaPlayer1(arena);
  int p2 = Multi1v1_GetArenaPlayer2(arena);

  if (p1 >= 0 && p2 >= 0 && g_GiveFlash[p1] && g_GiveFlash[p2]) {
    GivePlayerItem(client, "weapon_flashbang");
  }
}

public void OnClientCookiesCached(int client) {
  if (IsFakeClient(client))
    return;
  g_GiveFlash[client] = GetCookieBool(client, g_hFlashCookie);
}
