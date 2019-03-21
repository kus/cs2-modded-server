#pragma semicolon 1

#include <sourcemod>
#include <gungame_const>
#include <gungame>
#include <gungame_config>
#include "gungame/stock.sp"

public Plugin:myinfo = {
    name = "GunGame:SM Map Vote Starter",
    author = GUNGAME_AUTHOR,
    description = "Start the map voting for next map",
    version = GUNGAME_VERSION,
    url = GUNGAME_URL
};

public GG_OnStartMapVote() {
    decl String:ConfigGameDirName[PLATFORM_MAX_PATH];
    GG_ConfigGetDir(ConfigGameDirName, sizeof(ConfigGameDirName));
    InsertServerCommand("exec \\%s\\gungame.mapvote.cfg", ConfigGameDirName);
}

public GG_OnDisableRtv() {
    decl String:ConfigGameDirName[PLATFORM_MAX_PATH];
    GG_ConfigGetDir(ConfigGameDirName, sizeof(ConfigGameDirName));
    InsertServerCommand("exec \\%s\\gungame.disable_rtv.cfg", ConfigGameDirName);
}
