#pragma semicolon 1

#include <sourcemod>
#include <gungame_const>
#include <gungame>

/**
 * This is a plugin for hlstatx logging of the winner of the gungame current level.
 */

public Plugin:myinfo = {
    name = "GunGame:SM Winner Logger",
    author = GUNGAME_AUTHOR,
    description = "Logging of winner for external stats plugin",
    version = GUNGAME_VERSION,
    url = GUNGAME_URL
};

public GG_OnWinner(client, const String:Weapon[], victim) {
    LogEventToGame("gg_win", client);
    LogEventToGame("gg_lose", victim);

    new teamWin = GetClientTeam(client);
    new teamLose = (teamWin == TEAM_CT)? TEAM_T: TEAM_CT;
    new team;
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            team = GetClientTeam(i);
            if (team == teamWin) {
                LogEventToGame("gg_team_win", i);
            } else if (team == teamLose) {
                LogEventToGame("gg_team_lose", i);
            }
        }
    }
}

public GG_OnTripleLevel(client) {
    LogEventToGame("gg_triple_level", client);
}

public GG_OnLeaderChange(client, level, totalLevels) {
    if (client && IsClientInGame(client)) {
        LogEventToGame("gg_leader", client);
    }
}

public Action:GG_OnClientLevelChange(client, level, difference, bool:steal, bool:last, bool:knife) {
    if (!difference) {
        return;
    }
    if (difference > 0) {
        LogEventToGame("gg_levelup", client);
        if (steal) {
            LogEventToGame("gg_knife_steal", client);
        }
        if (last) {
            LogEventToGame("gg_last_level", client);
        }
        if (knife) {
            LogEventToGame("gg_knife_level", client);
        }
    } else {
        LogEventToGame("gg_leveldown", client);
        for (new i = difference; i < 0; i++) {
            LogEventToGame("gg_leveldown", client);
        }
    }
}

LogEventToGame(const String:event[], client) {
    decl String:Auth[64];

    GetClientAuthString(client, Auth, sizeof(Auth));
    if (!GetClientAuthString(client, Auth, sizeof(Auth))) {
        strcopy(Auth, sizeof(Auth), "UNKNOWN");
    }

    new team = GetClientTeam(client), UserId = GetClientUserId(client);
    LogToGame("\"%N<%d><%s><%s>\" triggered \"%s\"", client, UserId, Auth, (team == TEAM_T) ? "TERRORIST" : "CT", event);
}
