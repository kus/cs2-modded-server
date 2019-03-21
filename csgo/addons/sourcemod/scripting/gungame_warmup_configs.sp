#pragma semicolon 1

#include <sourcemod>
#include <gungame_const>
#include <gungame>
#include <gungame_config>

public Plugin:myinfo = {
    name = "GunGame:SM Warmup Configs Execution",
    author = GUNGAME_AUTHOR,
    description = "Execute warmup configs on warmup start and end",
    version = GUNGAME_VERSION,
    url = GUNGAME_URL
};

public GG_OnWarmupEnd() {
    decl String:ConfigGameDirName[PLATFORM_MAX_PATH];
    GG_ConfigGetDir(ConfigGameDirName, sizeof(ConfigGameDirName));
    InsertServerCommand("exec \\%s\\gungame.warmupend.cfg", ConfigGameDirName);
}

public GG_OnWarmupStart() {
    decl String:ConfigGameDirName[PLATFORM_MAX_PATH];
    GG_ConfigGetDir(ConfigGameDirName, sizeof(ConfigGameDirName));
    InsertServerCommand("exec \\%s\\gungame.warmupstart.cfg", ConfigGameDirName);
}
