//#define SM_GGDM_DEBUG 1

#pragma semicolon 1

#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <ggdm>

public Plugin:myinfo = 
{
    name = "DeathMatch:SM Elimination",
    author = "Otstrel.ru Team",
    description = "DeathMatch:SM Elimination for SourceMod.",
    version = GGDM_VERSION,
    url = GGDM_URL
};

// ============================================================================
// >> GLOBAL VARS
// ============================================================================

new bool:g_roundActive = false;
new g_roundNumber = 0;

new Handle:g_Cvar_RespawnTime = INVALID_HANDLE;
new Handle:g_Cvar_Elimination = INVALID_HANDLE;
new Handle:g_Cvar_EliminationSpawn = INVALID_HANDLE;

new Float:g_respawnTime;
new bool:g_elimination;
new bool:g_eliminationSpawn;

#define MAXPLAYERS_BYTES MAXPLAYERS / 32

new g_eliminated[MAXPLAYERS + 1][MAXPLAYERS_BYTES];

new Handle:g_Hanlde_RoundSpawned;

// ============================================================================
// >> LOAD
// ============================================================================

public OnPluginStart()
{
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("OnPluginStart");
    #endif
    g_Cvar_Elimination    = CreateConVar("sm_ggdm_elimination", "0", "1 Elimination on 0 is off");
    g_elimination       = GetConVarBool(g_Cvar_Elimination);
    HookConVarChange(g_Cvar_Elimination, CvarChanged);
    
    g_Cvar_RespawnTime = CreateConVar("sm_ggdm_el_respawntime", "2.0", "Elimination respawn time");
    g_respawnTime = GetConVarFloat(g_Cvar_RespawnTime);
    HookConVarChange(g_Cvar_RespawnTime, CvarChanged);
    
    g_Cvar_EliminationSpawn = CreateConVar("sm_ggdm_elimination_spawn", "1", "Spawn new connected players in the middle of the round (1 - enabled, 0 - disabled)");
    g_eliminationSpawn       = GetConVarBool(g_Cvar_EliminationSpawn);
    HookConVarChange(g_Cvar_EliminationSpawn, CvarChanged);
    
    if ( g_elimination ) {
        startHook();
    }

    RegConsoleCmd("joinclass", Event_JoinClass);
    
    clearEliminations();

    g_Hanlde_RoundSpawned = CreateTrie();
}

// ============================================================================
// >> GAME EVENTS
// ============================================================================

public OnMapStart() {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("OnMapStart");
    #endif
    g_roundActive = false;
    g_roundNumber = 0;
}

public Action:Event_RoundStart(Handle:event,const String:name[],bool:dontBroadcast) {
    g_roundActive = true;
    g_roundNumber += 1;

    #if defined SM_GGDM_DEBUG
        PrintToChatAll("Event_RoundStart(num=%i)",g_roundNumber);
    #endif
    clearEliminations();
}

public Action:Event_RoundEnd(Handle:event,const String:name[],bool:dontBroadcast) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("Event_RoundEnd");
    #endif
    g_roundActive = false;
    if ( g_eliminationSpawn ) {    
        ClearTrie(g_Hanlde_RoundSpawned);
    }
}

public OnClientConnected(client) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("OnClientConnected(client=%i)",client);
    #endif
    clearClientEliminations(client);
}
    
public Action:Event_JoinClass(client, args) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("Event_JoinClass(client=%i, team=%i)",client,GetClientTeam(client));
    #endif
    if ( !g_elimination ) {
        return;
    }
    if ( !g_eliminationSpawn ) {    
        return;
    }
    if ( GetClientTeam(client) < 2 ) {
        return;
    }

    decl String:steamid[64];
    GetClientAuthString(client, steamid, sizeof(steamid));

    new spawned = 0;
    if ( GetTrieValue(g_Hanlde_RoundSpawned, steamid, spawned) ) {
        if ( spawned ) {
            return;
        }
    }

    respawnPlayerDelayed(client);
}

public OnClientDisconnect(client) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("OnClientDisconnect(client=%i)",client);
    #endif
    respawnEliminatedDelayed(client);
}

public Action:Event_PlayerDeath(Handle:event,const String:name[],bool:dontBroadcast) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("Event_PlayerDeath(roundactive=%i)",g_roundActive);
    #endif
    if ( !g_roundActive ) {
        return;
    }
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("... victim=%i, killer=%i",client,killer);
    #endif

    if ( client == killer || killer == 0 ) {
        // suicide
        respawnPlayerDelayed(client);
    } else if ( GetClientTeam(client) == GetClientTeam(killer) ) {
        // teamkill
        respawnPlayerDelayed(client);
    } else {
        // normal kill
        // Add victim to the attackers eliminated players
        g_eliminated[killer][client >> 5] |= ( 1 << ( (client-1)&31 ) );
        #if defined SM_GGDM_DEBUG
            PrintToChatAll("... save eliminated high=%i low=%i",client >> 5,( 1 << ( (client-1)&31 ) ));
        #endif
    }
    // Check if victim had any Eliminated players
    respawnEliminatedDelayed(client);
}

public Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
    new newTeam = GetEventInt(event, "team");
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("Event_PlayerTeam(team=%i,client=%i)", newTeam, client);
    #endif

    if ( !client || (newTeam < 2) )
    {
        return;
    }
    
    if ( IsFakeClient(client) )
    {
        // Fake clients does not exec joinclass, so we need to spawn them 
        // just when they joined team
        respawnPlayerDelayed(client);
    }
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( GetClientTeam(client) < 2 ) {
        return;
    }

    decl String:steamid[64];
    GetClientAuthString(client, steamid, sizeof(steamid));

    SetTrieValue(g_Hanlde_RoundSpawned, steamid, 1);
}

// ============================================================================
// >> CUSTOM/HELPER FUNCTIONS
// ============================================================================

clearEliminations() {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("clearEliminations");
    #endif
    for (new j = 1; j <= MaxClients; j++)
    {
        for (new i = 0; i < MAXPLAYERS_BYTES; i++)
        {
            g_eliminated[j][i] = 0;
        }
    }
}

clearClientEliminations(client) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("clearClientEliminations(client=%i)", client);
    #endif
    for (new i = 0; i < MAXPLAYERS_BYTES; i++)
    {
        g_eliminated[client][i] = 0;
    }
}

respawnPlayerDelayed(client) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("respawnPlayerDelayed(client=%i)", client);
    #endif
    new Handle:data = CreateDataPack();
    WritePackCell(data, client);
    WritePackCell(data, g_roundNumber);
    CreateTimer(g_respawnTime, Timer_RespawnPlayer, data);
}

respawnEliminatedDelayed(client) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("respawnEliminatedDelayed(client=%i)", client);
    #endif
    new Handle:data = CreateDataPack();
    WritePackCell(data, client);
    WritePackCell(data, g_roundNumber);
    CreateTimer(g_respawnTime, Timer_RespawnEliminated, data);
}

public Action:Timer_RespawnEliminated (Handle:timer, any:data) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("Timer_RespawnEliminated(g_roundActive=%i)", g_roundActive);
    #endif
    if ( !g_roundActive ) {
        CloseHandle(data);
        return Plugin_Stop;
    }

    ResetPack(data);
    new client = ReadPackCell(data);
    new round = ReadPackCell(data);
    CloseHandle(data);

    #if defined SM_GGDM_DEBUG
        PrintToChatAll("... client = %i g_roundNumber = %i round = %i", client, g_roundNumber, round);
    #endif
    if ( g_roundNumber != round ) {
        return Plugin_Stop;
    }

    new clientId = 1;
    new k;
    for (new j = 0; j < MAXPLAYERS_BYTES; j++)
    {
        k = 1;
        for (new i = 0; i < 32; i++)
        {
            if ( g_eliminated[client][j] & k ) {
                #if defined SM_GGDM_DEBUG
                    PrintToChatAll("... found clientId=%i", clientId);
                #endif
                if ( !IsClientInGame(clientId) ) {
                    continue;
                }

                if ( IsPlayerAlive(clientId) || (GetClientTeam(clientId) < 2) ) {
                    continue;
                }

                #if defined SM_GGDM_DEBUG
                    PrintToChatAll("... respawn clientId=%i", clientId);
                #endif
                CS_RespawnPlayer(clientId);
            }

            k = k<<1;
            clientId++;
            if ( clientId > MaxClients ) {
                clearClientEliminations(client);
                return Plugin_Stop;
            }
        }
    }

    return Plugin_Stop;
}

public Action:Timer_RespawnPlayer(Handle:timer, any:data) {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("Timer_RespawnPlayer(g_roundActive=%i)", g_roundActive);
    #endif
    if ( !g_roundActive ) {
        CloseHandle(data);
        return Plugin_Stop;
    }

    ResetPack(data);
    new client = ReadPackCell(data);
    new round = ReadPackCell(data);
    CloseHandle(data);

    #if defined SM_GGDM_DEBUG
        PrintToChatAll("... client = %i g_roundNumber = %i round = %i", client, g_roundNumber, round);
    #endif
    if ( g_roundNumber != round ) {
        return Plugin_Stop;
    }

    if ( !client || !IsClientInGame(client) ) {
        return Plugin_Stop;
    }

    if ( (GetClientTeam(client) < 2) || (IsPlayerAlive(client)) ) {
        return Plugin_Stop;
    }

    #if defined SM_GGDM_DEBUG
        PrintToChatAll("... respawn clientId=%i", client);
    #endif

    CS_RespawnPlayer(client);

    return Plugin_Stop;
}


public CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if ( cvar == g_Cvar_RespawnTime )
    {
        g_respawnTime = GetConVarFloat(g_Cvar_RespawnTime);
        if ( g_respawnTime < 0 )
        {
            g_respawnTime = 0.0;
        }
        return;
    }
    if ( cvar == g_Cvar_Elimination )
    {
        g_elimination = GetConVarBool(g_Cvar_Elimination);
        #if defined SM_GGDM_DEBUG
            PrintToChatAll("CvarChanged(g_elimination=%i)", g_elimination);
        #endif
        if ( g_elimination ) {
            startHook();
        } else {
            stopHook();
        }
        return;
    }
    if ( cvar == g_Cvar_EliminationSpawn )
    {
        g_eliminationSpawn = GetConVarBool(g_Cvar_EliminationSpawn);
        if ( g_elimination ) {
            if ( g_eliminationSpawn ) {    
                HookEvent("player_spawn", Event_PlayerSpawn);
            } else {
                UnhookEvent("player_spawn", Event_PlayerSpawn);
            }
        }
        return;
    }
}

startHook() {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("startHook");
    #endif
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("player_team", Event_PlayerTeam);
    if ( g_eliminationSpawn ) {    
        HookEvent("player_spawn", Event_PlayerSpawn);
    }

    g_roundActive = true;
    g_roundNumber = 0;

    ServerCommand("sm_ggdm_enable 0");
}

stopHook() {
    #if defined SM_GGDM_DEBUG
        PrintToChatAll("stopHook");
    #endif
    UnhookEvent("player_death", Event_PlayerDeath);
    UnhookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    UnhookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    UnhookEvent("player_team", Event_PlayerTeam);
    if ( g_eliminationSpawn ) {    
        UnhookEvent("player_spawn", Event_PlayerSpawn);
    }
}
