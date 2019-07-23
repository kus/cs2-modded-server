#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#define MENU_TIME_LENGTH 15

char g_PistolChoices[][][] = {
    // Default pistols:
    { "weapon_glock", "Glock" },
    { "weapon_usp_silencer", "USP" },
    { "weapon_hkp2000", "P2000" },

    // Upgraded pistols:
    { "weapon_p250", "P250" },
    { "weapon_tec9", "Tec-9" },
    { "weapon_fiveseven", "Five-Seven" },
    { "weapon_deagle", "Deagle" },
};

int g_PistolChoice[MAXPLAYERS+1];
Handle g_PistolChoiceCookie = INVALID_HANDLE;

public Plugin myinfo = {
    name = "CS:GO Retakes: Pistols and nades",
    author = "splewis, BatMen, Ejz",
    description = "Defines a simple weapon allocation policy that gives Pistols and nades",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-retakes"
};

public void OnPluginStart() {
    g_PistolChoiceCookie = RegClientCookie("retakes_pistolchoice", "", CookieAccess_Private);
}

public void OnClientConnected(int client) {
    g_PistolChoice[client] = 1;
}

public void Retakes_OnGunsCommand(int client) {
    GiveGunsMenu(client);
}

public void Retakes_OnWeaponsAllocated(ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite) {
    PistolAllocator(tPlayers, ctPlayers, bombsite);
}

public void OnClientCookiesCached(int client) {
    if (IsFakeClient(client))
        return;
    g_PistolChoice[client]  = GetCookieInt(client, g_PistolChoiceCookie);
}

public void SetNades(char nades[NADE_STRING_LENGTH]) {
    int rand = GetRandomInt(0, 3);
    switch(rand) {
        case 0: nades = "";
        case 1: nades = "s";
        case 2: nades = "f";
        case 3: nades = "h";
    }
}

public void PistolAllocator(ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite) {
    int tCount = GetArraySize(tPlayers);
    int ctCount = GetArraySize(ctPlayers);

    char primary[WEAPON_STRING_LENGTH];
    char secondary[WEAPON_STRING_LENGTH];
    char nades[NADE_STRING_LENGTH];
    int health = 100;
    int kevlar = 100;
    bool helmet = false;
    bool kit = true;

    for (int i = 0; i < tCount; i++) {
        int client = GetArrayCell(tPlayers, i);
        int choice = g_PistolChoice[client];
        strcopy(secondary, sizeof(secondary), g_PistolChoices[choice][0]);
        health = 100;
        kevlar = IsDefaultPistol(choice) ? 100 : 0;
        helmet = false;
        kit = false;
        SetNades(nades);
        Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
    }

    for (int i = 0; i < ctCount; i++) {
        int client = GetArrayCell(ctPlayers, i);
        int choice = g_PistolChoice[client];
        strcopy(secondary, sizeof(secondary), g_PistolChoices[choice][0]);
        kit = true;
        health = 100;
        kevlar = IsDefaultPistol(choice) ? 100 : 0;
        helmet = false;
        SetNades(nades);
        Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
    }
}

public void GiveGunsMenu(int client) {
    Menu menu = new Menu(GunsMenuHandler);
    SetMenuTitle(menu, "Select a pistol:");
    for (int i = 0; i < sizeof(g_PistolChoices); i++) {
        AddMenuInt(menu, i, g_PistolChoices[i][1]);
    }
    DisplayMenu(menu, client, MENU_TIME_LENGTH);
}

public int GunsMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        int choice = GetMenuInt(menu, param2);
        g_PistolChoice[client] = choice;
        SetCookieInt(client, g_PistolChoiceCookie, choice);
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
}

public bool IsDefaultPistol(int weaponIndex) {
    return weaponIndex <= 2;
}
