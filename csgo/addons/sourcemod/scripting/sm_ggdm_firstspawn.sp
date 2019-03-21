#pragma semicolon 1

#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <ggdm>

// ============================================================================
// >> GLOBAL VARS
// ============================================================================
new g_alreadySpawned[MAXPLAYERS + 1];
new Handle:g_lastDisconnectedTime;
new g_connectedTime[MAXPLAYERS + 1];
new g_disconnectedTime[MAXPLAYERS + 1];

new bool:g_enabled;
new Handle:g_Cvar_Enabled;
new g_protectionTime;
new Handle:g_Cvar_ProtectionTime;

// ============================================================================
// >> PLUGIN INFO
// ============================================================================
public Plugin:myinfo = {
    name = "DeathMatch:SM First Spawn",
    author = "Otstrel.ru Team",
    description = "Spawns new connected players in the middle of the round.",
    version = GGDM_VERSION,
    url = GGDM_URL
};

// ============================================================================
// >> LOAD
// ============================================================================
public OnPluginStart() {
    LoadTranslations("ggdm_firstrespawn");

    g_lastDisconnectedTime = CreateTrie();
    
    RegConsoleCmd("spawn", Cmd_Spawn);
    RegConsoleCmd("joinclass", Event_JoinClass);

    g_Cvar_Enabled  = CreateConVar("sm_ggdm_fspawn_enable", "0", "Enable manual first spawn");
    g_enabled       = GetConVarBool(g_Cvar_Enabled);
    HookConVarChange(g_Cvar_Enabled, Event_CvarChanged);

    g_Cvar_ProtectionTime = CreateConVar("sm_ggdm_fspawn_ptime", "420", "Reconnect protection time");
    g_protectionTime      = GetConVarInt(g_Cvar_ProtectionTime);
    HookConVarChange(g_Cvar_ProtectionTime, Event_CvarChanged);

    if ( g_enabled ) {
        startHook();
    }
}

// ============================================================================
// >> GAME GLOBAL FORWARDS
// ============================================================================
public OnClientConnected(client) {
    g_connectedTime[client] = GetTime();
    g_disconnectedTime[client] = 0;
    g_alreadySpawned[client] = 0;
}

public OnMapStart() {
    for (new i = 1; i < MaxClients; i++) {
        if ( IsClientConnected(i) ) {
            g_alreadySpawned[i] = 0;
            g_connectedTime[i] = GetTime();
            g_disconnectedTime[i] = -1;
        }
    }
    ClearTrie(g_lastDisconnectedTime);
}

public OnClientDisconnect(client) {
    if ( !g_alreadySpawned[client] ) {
        return;
    }

    if ( IsFakeClient(client) ) {
        return;
    }

    decl String:steamid[64];
    new result = GetClientAuthString(client, steamid, sizeof(steamid));
    if ( !result ) {
        return;
    }

    SetTrieValue(g_lastDisconnectedTime, steamid, GetTime());
}

public OnClientAuthorized(client, const String:steamid[]) {
    new time;
    new result;
    result = GetTrieValue(g_lastDisconnectedTime, steamid, time);
    if ( result ) {
        g_disconnectedTime[client] = time;
    } else {
        g_disconnectedTime[client] = -1;
    }
}

// ============================================================================
// >> GAME HOOKS
// ============================================================================
public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( !g_alreadySpawned[client] ) {
        new team = GetClientTeam(client);
        if ( team > 1 ) {
            g_alreadySpawned[client] = 1;
        }
    }

    return Plugin_Continue;
}

public Action:Event_JoinClass(client, args) {
    if ( !g_enabled ) {
        return Plugin_Continue;
    }

    CreateTimer(1.0, Timer_Notify, client);
    return Plugin_Continue;
}

public Event_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) {
    if ( cvar == g_Cvar_Enabled ) {
        if ( g_enabled != GetConVarBool(g_Cvar_Enabled) ) {
            g_enabled = !g_enabled;
            if ( g_enabled ) {
                startHook();
            } else {
                stopHook();
            }
        }
        return;
    } else if ( cvar == g_Cvar_ProtectionTime ) {
        g_protectionTime      = GetConVarInt(g_Cvar_ProtectionTime);
        return;
    }
}

public Action:Cmd_Spawn(client, args) {
    if ( !g_enabled ) {
        return Plugin_Continue;
    }

    new error = canSpawn(client);
    if ( error ) {
        if ( error == 1 ) {
            ReplyToCommand(client, "%T", "[spawn] You have not joined any team.", client);
        } else if ( error == 2 ) {
            ReplyToCommand(client, "%T", "[spawn] You have already spawned after conneted.", client);
        } else if ( error == 3 ) {
            ReplyToCommand(client, "%T", "[spawn] You are not authorized.", client);
        } else if ( error == 4 ) {
            ReplyToCommand(client, "%T", "[spawn] You can not spawn because you reconnected too fast.", client);
        } else if ( error == 5 ) {
            ReplyToCommand(client, "%T", "[spawn] You are already alive.", client);
        } else {
            ReplyToCommand(client, "%T", "[spawn] Unknown error.", client, error);
            LogError("Unknown error %i for client %i", error, client);
        }
    } else {
        CS_RespawnPlayer(client);
    }

    return Plugin_Handled;
}

// ============================================================================
// >> TIMERS
// ============================================================================
public Action:Timer_Notify(Handle:timer, any:client) {
    if ( !IsClientInGame(client) ) {
        return Plugin_Stop;
    }

    new error = canSpawn(client);
    if ( error ) {
        if ( error == 3 ) {
            PrintToChat(client, "%T", "[spawn] Say !spawn for spawn for the first time.", client);
        }
    } else {
        CS_RespawnPlayer(client);
    }

    return Plugin_Stop;
}

// ============================================================================
// >> HELPER FUNCTIONS
// ============================================================================

startHook() {
    HookEvent("player_spawn", Event_PlayerSpawn);
}

stopHook() {
    UnhookEvent("player_spawn", Event_PlayerSpawn);
}

canSpawn(client) {
    if ( IsPlayerAlive(client) ) {
        return 5;
    }
    new team = GetClientTeam(client);
    if ( team < 2 ) {
        return 1;
    }
    if ( g_alreadySpawned[client] ) {
        return 2;
    }
    if ( !g_disconnectedTime[client] ) {
        return 3;
    }
    if ( (g_disconnectedTime[client] > 0) && (g_connectedTime[client] - g_disconnectedTime[client] < g_protectionTime) ) {
        return 4;
    }
    return 0;
}
