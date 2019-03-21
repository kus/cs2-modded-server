#pragma semicolon 1

#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <ggdm>

public Plugin:myinfo = 
{
    name = "DeathMatch:SM",
    author = GGDM_AUTHORS,
    description = "DeathMatch:SM for SourceMod.",
    version = GGDM_VERSION,
    url = GGDM_URL
};

new Handle:g_Respawn[MAXPLAYERS + 1]    = {INVALID_HANDLE, ...};

new Handle:g_Cvar_RespawnTime           = INVALID_HANDLE;
new Float:g_respawnTime;

new bool:g_roundStarted;
new g_playerClass[MAXPLAYERS + 1];

new Handle:g_Cvar_DmEnabled             = INVALID_HANDLE;
new bool:g_dmEnabled;

new g_respawnIn[MAXPLAYERS + 1];

public OnPluginStart()
{
    LoadTranslations("ggdm");

    g_Cvar_DmEnabled = CreateConVar("sm_ggdm_enable", "1", "Enable deathmatch");
    g_dmEnabled = GetConVarBool(g_Cvar_DmEnabled);

    g_Cvar_RespawnTime = CreateConVar("sm_ggdm_respawntime", "2.0", "Respawn time");
    g_respawnTime = GetConVarFloat(g_Cvar_RespawnTime);

    new Handle:Cvar_Version = CreateConVar("sm_ggdm_version", GGDM_VERSION, "GunGame Deathmatch", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
    /* Just to make sure they it updates the convar version if they just had the plugin reload on map change */
    SetConVarString(Cvar_Version, GGDM_VERSION);
    
    HookConVarChange(g_Cvar_RespawnTime, CvarChanged);
    HookConVarChange(g_Cvar_DmEnabled, CvarChanged);

    RegConsoleCmd("joinclass", Event_JoinClass);
    StartHook();
}

StartHook() {
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("player_team", Event_PlayerTeam);

    g_roundStarted = true;
    for (new i = 1; i <= MaxClients; i++) {
        g_playerClass[i] = 1;
        if ( CanClientSpawn(i) ) {
            StartRespawnTimer(i);
        }
    }

    ServerCommand("sm_ggdm_elimination 0");
}

StopHook() {
    UnhookEvent("player_death", Event_PlayerDeath);
    UnhookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    UnhookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    UnhookEvent("player_team", Event_PlayerTeam);
}

public Action:Event_JoinClass(client, args)
{
    if ( !g_dmEnabled ) {
        return Plugin_Continue;
    }
    g_playerClass[client] = 1;
    StartRespawnTimer(client);
    return Plugin_Continue;
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
    if ( cvar == g_Cvar_DmEnabled )
    {
        g_dmEnabled = GetConVarBool(g_Cvar_DmEnabled);
        if ( g_dmEnabled ) {
            StartHook();
        } else {
            StopHook();
        }
        return;
    }
}

public Action:Event_RoundEnd(Handle:event,const String:name[],bool:dontBroadcast)
{
    g_roundStarted = false;
}

public Action:Event_RoundStart(Handle:event,const String:name[],bool:dontBroadcast)
{
    g_roundStarted = true;
}

public Action:Event_PlayerDeath(Handle:event,const String:name[],bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    StartRespawnTimer(client);
}

StartRespawnTimer(client) {
    g_Respawn[client] = CreateTimer(g_respawnTime, ExecRespawn, client);
    g_respawnIn[client] = RoundFloat(g_respawnTime);
    CreateTimer(1.0, Timer_Notify, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_Notify(Handle:timer, any:client) {
    if ( !client || !CanClientSpawn(client) || !g_playerClass[client] )    {
        if ( g_Respawn[client] != INVALID_HANDLE ) {
            CloseHandle(g_Respawn[client]);
            g_Respawn[client] = INVALID_HANDLE;
        }
        return Plugin_Stop;
    }
    g_respawnIn[client]--;
    PrintHintText(client, "%T", "restart in", client, g_respawnIn[client]/60, g_respawnIn[client]%60);
    if ( g_respawnIn[client] < 2 ) {
        return Plugin_Stop;
    } else {
        return Plugin_Continue;
    }
}

CanClientSpawn(client) {
    return IsClientInGame(client) && (GetClientTeam(client) > 1) && (!IsPlayerAlive(client));
}

public Action:ExecRespawn(Handle:timer, any:client)
{
    if ( client && CanClientSpawn(client) && g_playerClass[client] )
    {
        if ( !g_roundStarted )
        {
            PrintToChat(client,"\x01\x04[GGDM] You will respawn next round");
        }
        else
        {
            CS_RespawnPlayer(client);
        }
    }    
    return Plugin_Stop;
}

public Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
    new newTeam = GetEventInt(event, "team");
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    if ( !client || (newTeam < 2) )
    {
        return;
    }
    
    if ( IsFakeClient(client) )
    {
        g_playerClass[client] = 1;
        // Fake clients does not exec joinclass, so we need to spawn them 
        // just when they joined team
        g_Respawn[client] = CreateTimer(g_respawnTime, ExecRespawn, client);
    }
    else
    {
        g_playerClass[client] = 0;
    }
}
