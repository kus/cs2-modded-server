#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#define MENU_TIME_LENGTH 15

bool g_SilencedM4[MAXPLAYERS+1];
bool g_AwpChoice[MAXPLAYERS+1];
Handle g_hM4ChoiceCookie = INVALID_HANDLE;
Handle g_hAwpChoiceCookie = INVALID_HANDLE;

public Plugin myinfo = {
    name = "CS:GO Retakes: standard weapon allocator",
    author = "splewis",
    description = "Defines a simple weapon allocation policy and lets players set weapon preferences",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-retakes"
};

public void OnPluginStart() {
    g_hM4ChoiceCookie = RegClientCookie("retakes_m4choice", "", CookieAccess_Private);
    g_hAwpChoiceCookie = RegClientCookie("retakes_awpchoice", "", CookieAccess_Private);
}

public void OnClientConnected(int client) {
    g_SilencedM4[client] = false;
    g_AwpChoice[client] = false;
}

public void Retakes_OnGunsCommand(int client) {
    GiveWeaponsMenu(client);
}

public void Retakes_OnWeaponsAllocated(ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite) {
    WeaponAllocator(tPlayers, ctPlayers, bombsite);
}

/**
 * Updates client weapon settings according to their cookies.
 */
public void OnClientCookiesCached(int client) {
    if (IsFakeClient(client))
        return;

    g_SilencedM4[client] = GetCookieBool(client, g_hM4ChoiceCookie);
    g_AwpChoice[client] = GetCookieBool(client, g_hAwpChoiceCookie);
}

static void SetNades(char nades[NADE_STRING_LENGTH]) {
    int rand = GetRandomInt(0, 3);
    switch(rand) {
        case 0: nades = "";
        case 1: nades = "s";
        case 2: nades = "f";
        case 3: nades = "h";
    }
}

public void WeaponAllocator(ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite) {
    int tCount = GetArraySize(tPlayers);
    int ctCount = GetArraySize(ctPlayers);

    char primary[WEAPON_STRING_LENGTH];
    char secondary[WEAPON_STRING_LENGTH];
    char nades[NADE_STRING_LENGTH];
    int health = 100;
    int kevlar = 100;
    bool helmet = true;
    bool kit = true;

    bool giveTAwp = true;
    bool giveCTAwp = true;

    for (int i = 0; i < tCount; i++) {
        int client = GetArrayCell(tPlayers, i);

        if (giveTAwp && g_AwpChoice[client]) {
            primary = "weapon_awp";
            giveTAwp = false;
        } else {
            primary = "weapon_ak47";
        }

        secondary = "weapon_glock";
        health = 100;
        kevlar = 100;
        helmet = true;
        kit = false;
        SetNades(nades);

        Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
    }

    for (int i = 0; i < ctCount; i++) {
        int client = GetArrayCell(ctPlayers, i);

        if (giveCTAwp && g_AwpChoice[client]) {
            primary = "weapon_awp";
            giveCTAwp = false;
        } else if (g_SilencedM4[client]) {
            primary = "weapon_m4a1_silencer";
        } else {
            primary = "weapon_m4a1";
        }

        secondary = "weapon_hkp2000";
        kit = true;
        health = 100;
        kevlar = 100;
        helmet = true;
        SetNades(nades);

        Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
    }
}

public void GiveWeaponsMenu(int client) {
    Handle menu = CreateMenu(MenuHandler_M4);
    SetMenuTitle(menu, "Select a CT rifle:");
    AddMenuBool(menu, false, "M4A4");
    AddMenuBool(menu, true, "M4A1-S");
    DisplayMenu(menu, client, MENU_TIME_LENGTH);
}

public int MenuHandler_M4(Handle menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        bool useSilenced = GetMenuBool(menu, param2);
        g_SilencedM4[client] = useSilenced;
        SetCookieBool(client, g_hM4ChoiceCookie, useSilenced);
        GiveAwpMenu(client);
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
}

public void GiveAwpMenu(int client) {
    Handle menu = CreateMenu(MenuHandler_AWP);
    SetMenuTitle(menu, "Allow yourself to receive AWPs?");
    AddMenuBool(menu, true, "Yes");
    AddMenuBool(menu, false, "No");
    DisplayMenu(menu, client, MENU_TIME_LENGTH);
}

public int MenuHandler_AWP(Handle menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        bool allowAwps = GetMenuBool(menu, param2);
        g_AwpChoice[client] = allowAwps;
        SetCookieBool(client, g_hAwpChoiceCookie, allowAwps);
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
}
