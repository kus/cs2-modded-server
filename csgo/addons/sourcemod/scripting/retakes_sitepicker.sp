#include <sourcemod>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name = "CS:GO Retakes: site picker",
    author = "splewis",
    description = "Adds admin commands to pick the bombsite being used",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-retakes"
};

bool g_forceSite;
Bombsite g_pickedSite;

public void OnPluginStart() {
    g_forceSite = false;
    RegAdminCmd("sm_site", Command_Site, ADMFLAG_CHANGEMAP);
}

public Action Command_Site(int client, int args) {
    char arg[32];
    if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
        if (StrEqual(arg, "a", false)) {
            g_forceSite = true;
            g_pickedSite = BombsiteA;
            Retakes_MessageToAll("Now only using bombsite A");
        } else  if (StrEqual(arg, "b", false)) {
            g_forceSite = true;
            g_pickedSite = BombsiteB;
            Retakes_MessageToAll("Now only using bombsite B");
        } else {
            g_forceSite = false;
            Retakes_MessageToAll("Now using all bombsites");
        }
    } else {
        Retakes_Message(client, "Usage: sm_site [a|b|any]");
    }
}

public void Retakes_OnSitePicked(Bombsite& site) {
    if (g_forceSite) {
        site = g_pickedSite;
    }
}
