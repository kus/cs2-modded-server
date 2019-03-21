#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#define cDefault 0x01
#define cLightGreen 0x03
#define cGreen 0x04
#define cDarkGreen 0x05

#define PLUGIN_VERSION "1.4.2"

// Uncomment for debugging
// #define DEBUG 1

public Plugin:myinfo = 
{
    name = "NoBlock",
    author = "Otstrel.ru Team",
    description = "Removes player collisions.",
    version = PLUGIN_VERSION,
    url = "http://otstrel.ru"
};

// ===========================================================================
// GLOBALS
// ===========================================================================

new g_offsCollisionGroup;
new bool:g_enabled;
new bool:g_enabled_nades;
new bool:g_enabled_hostages;
new bool:g_noblock_allow_block;
new Float:g_noblock_allow_block_time;

new Handle:sm_noblock;
new Handle:sm_noblock_nades;
new Handle:sm_noblock_hostages;
new Handle:sm_noblock_allow_block;
new Handle:sm_noblock_allow_block_time;
new Handle:g_hTimer[MAXPLAYERS+1];

new Handle:sm_noblock_blockafterspawn_time;
new Float:g_blockTime;

// ===========================================================================
// LOAD & UNLOAD
// ===========================================================================

public OnPluginStart()
{
    #if defined DEBUG
        LogError("[DEBUG] Plugin started.");
    #endif
    
    new Handle:Cvar_Version = CreateConVar("sm_noblock_version", PLUGIN_VERSION,    "NoBlock Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
    /* Just to make sure they it updates the convar version if they just had the plugin reload on map change */
    SetConVarString(Cvar_Version, PLUGIN_VERSION);
    
    g_offsCollisionGroup = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");
    if (g_offsCollisionGroup == -1)
    {
        SetFailState("[NoBlock] Failed to get offset for CBaseEntity::m_CollisionGroup.");
    }
    
    sm_noblock = CreateConVar("sm_noblock", "1", "Removes player vs. player collisions");
    g_enabled = GetConVarBool(sm_noblock);
    HookConVarChange(sm_noblock, OnConVarChange);

    sm_noblock_nades = CreateConVar("sm_noblock_nades", "1", "Removes player vs. nade collisions");
    g_enabled_nades = GetConVarBool(sm_noblock_nades);
    HookConVarChange(sm_noblock_nades, OnConVarChange);

    sm_noblock_hostages = CreateConVar("sm_noblock_hostages", "0", "Removes player vs. hostage collisions");
    g_enabled_hostages = GetConVarBool(sm_noblock_hostages);
    HookConVarChange(sm_noblock_hostages, OnConVarChange);

    sm_noblock_allow_block = CreateConVar("sm_noblock_allow_block", "1.0", "Allow players to use say !block", _, true, 0.0, true, 1.0);
    g_noblock_allow_block = GetConVarBool(sm_noblock_allow_block);
    HookConVarChange(sm_noblock_allow_block, OnConVarChange);

    sm_noblock_allow_block_time = CreateConVar("sm_noblock_allow_block_time", "20.0", "Time limit to say !block command", _, true, 0.0, true, 600.0);
    g_noblock_allow_block_time = GetConVarFloat(sm_noblock_allow_block_time);
    HookConVarChange(sm_noblock_allow_block_time, OnConVarChange);

    sm_noblock_blockafterspawn_time = CreateConVar("sm_noblock_blockafterspawn_time", "0.0", "Disable blocking only for that time from spawn.", _, true, 0.0, true, 600.0);
    g_blockTime = GetConVarFloat(sm_noblock_blockafterspawn_time);
    HookConVarChange(sm_noblock_blockafterspawn_time, OnConVarChange);
    

    if ( g_enabled ) {
        StartHook();
    }

    RegConsoleCmd("say", Command_Say);
    RegConsoleCmd("say_team", Command_Say);
}

// ===========================================================================
// EVENTS
// ===========================================================================

public OnConVarChange(Handle:hCvar, const String:oldValue[], const String:newValue[])
{
    #if defined DEBUG
        LogError("[DEBUG] Cvar changed.");
    #endif
    if ( hCvar == sm_noblock ) {
        g_enabled = GetConVarBool(sm_noblock);
        if ( g_enabled ) {
            UnblockClientAll();
            if ( sm_noblock_hostages ) {
                UnblockHostages();
            }
            StartHook();
        } else {
            StopHook();
            BlockClientAll();
            if ( sm_noblock_hostages ) {
                BlockHostages();
            }
        }
        return;
    }
    if ( hCvar == sm_noblock_nades ) {
        g_enabled_nades = GetConVarBool(sm_noblock_nades);
        return;
    }
    if ( hCvar == sm_noblock_hostages ) {
        g_enabled_hostages = GetConVarBool(sm_noblock_hostages);
        if ( g_enabled ) {
            if ( g_enabled_hostages ) {
                UnblockHostages();
                HookEvent("round_start", OnRoundStart, EventHookMode_Post);
            } else {
                UnhookEvent("round_start", OnRoundStart, EventHookMode_Post);
                BlockHostages();
            }
        }
        return;
    }
    if ( hCvar == sm_noblock_blockafterspawn_time ) {
        g_blockTime = GetConVarFloat(sm_noblock_blockafterspawn_time);
        return;
    }
    if ( hCvar == sm_noblock_allow_block ) {
        g_noblock_allow_block = GetConVarBool(sm_noblock_allow_block);
        return;
    }
    if ( hCvar == sm_noblock_allow_block_time ) {
        g_noblock_allow_block_time = GetConVarFloat(sm_noblock_allow_block_time);
        return;
    }
}

public OnSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    #if defined DEBUG
        LogError("[DEBUG] Player spawned.");
    #endif

    new userid = GetEventInt(event, "userid");
    new client = GetClientOfUserId(userid);
    #if defined DEBUG
        LogError("[DEBUG] ... player %i.", client);
    #endif
    if ( g_hTimer[client] != INVALID_HANDLE )
    {
        CloseHandle(g_hTimer[client]);
        g_hTimer[client] = INVALID_HANDLE;
        PrintToChat(client, "%c[NoBlock] %cBlocking has been Disabled because of respawn", cLightGreen, cDefault);
    }

    UnblockEntity(client);
    
    if ( g_blockTime )
    {
        CreateTimer(g_blockTime, Timer_PlayerBlock, client);
    }
}

//Enable NoBlock on hostages on roundstart
public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    #if defined DEBUG
        LogError("[DEBUG] Round started.");
    #endif
    
    UnblockHostages();
}

public Action:Command_Say(client, args)
{
    #if defined DEBUG
        LogError("[DEBUG] Player %i sayd something.", client);
    #endif
    if ( !g_enabled || !client || !g_noblock_allow_block )
    {
        return Plugin_Continue;
    }

    decl String:text[192], String:command[64];
    new startidx = 0;
    if (GetCmdArgString(text, sizeof(text)) < 1)
    {
        return Plugin_Continue;
    }
 
    if (text[strlen(text)-1] == '"')
    {
        text[strlen(text)-1] = '\0';
        startidx = 1;
    }

    if (strcmp(command, "say2", false) == 0)
    {
        startidx += 4;
    }

    if ( (strcmp(text[startidx], "!block", false) == 0) && !g_blockTime )
    {
        if ( g_hTimer[client] != INVALID_HANDLE )
        {
            CloseHandle(g_hTimer[client]);
            g_hTimer[client] = INVALID_HANDLE;            
            PrintToChat(client, "%c[NoBlock] %cBlocking has been Disabled by the client", cLightGreen, cDefault);
            
            UnblockEntity(client);
            return Plugin_Continue;
        }
        
        g_hTimer[client] = CreateTimer(g_noblock_allow_block_time, Timer_PlayerUnblock, client);
        PrintToChat(client, "%c[NoBlock] %cBlocking has been Enabled for %.0f seconds", cLightGreen, cDefault, g_noblock_allow_block_time);
        
        BlockEntity(client);
    }
 
    return Plugin_Continue;
}

//Player Blocking Expires
public Action:Timer_PlayerUnblock(Handle:timer, any:client)
{
    #if defined DEBUG
        LogError("[DEBUG] Timer unblocks client %i.", client);
    #endif
    //Disable Blocking on the Client
    g_hTimer[client] = INVALID_HANDLE;            
    if ( !g_enabled || !client || !IsClientInGame(client) || !IsPlayerAlive(client) )
    {
        return Plugin_Continue;
    }
    
    PrintToChat(client, "%c[NoBlock] %cBlocking is now Disabled", cLightGreen, cDefault);
    
    UnblockEntity(client);
    return Plugin_Continue;
}

public Action:Timer_PlayerBlock(Handle:timer, any:client)
{
    //Enable Blocking on the Client
    if ( !g_enabled || !client || !IsClientInGame(client) || !IsPlayerAlive(client) )
    {
        return Plugin_Continue;
    }
    
    BlockEntity(client);
    return Plugin_Continue;
}

public OnEntityCreated(entity, const String:classname[])
{
    if ( g_enabled_nades )
    {
        //Enable NoBlock on Nades
        if (StrEqual(classname, "hegrenade_projectile")) {
            UnblockEntity(entity);
        } else if (StrEqual(classname, "flashbang_projectile")) {
            UnblockEntity(entity);
        } else if (StrEqual(classname, "smokegrenade_projectile")) {
            UnblockEntity(entity);
        }
    }
}

// ===========================================================================
// HELPERS
// ===========================================================================

StartHook() {
    HookEvent("player_spawn", OnSpawn, EventHookMode_Post);
    if ( g_enabled_hostages ) {
        HookEvent("round_start", OnRoundStart, EventHookMode_Post);
    }
}

StopHook() {
    UnhookEvent("player_spawn", OnSpawn, EventHookMode_Post);
    if ( g_enabled_hostages ) {
        UnhookEvent("round_start", OnRoundStart, EventHookMode_Post);
    }
}

UnblockHostages() {
    new String:sClassName[32];
    new iMaxEntities = GetMaxEntities();
    
    /* Apparently the clients are always at the start of the entity list,
        so we can skip them in hopes of reducing roundstart lag */
        
    for ( new iEntity = MaxClients + 1; iEntity < iMaxEntities; iEntity++ )
    {
        if ( !IsValidEntity(iEntity) || !IsValidEdict(iEntity) ) {
            continue;
        }        
        GetEdictClassname(iEntity, sClassName, sizeof(sClassName));
        if ( StrEqual("hostage_entity", sClassName) ) {
            UnblockEntity(iEntity);
        }
    }
}    

BlockHostages() {
    new String:sClassName[32];
    new iMaxEntities = GetMaxEntities();
    
    /* Apparently the clients are always at the start of the entity list,
        so we can skip them in hopes of reducing roundstart lag */
        
    for ( new iEntity = MaxClients + 1; iEntity < iMaxEntities; iEntity++ )
    {
        if ( !IsValidEntity(iEntity) || !IsValidEdict(iEntity) ) {
            continue;
        }        
        GetEdictClassname(iEntity, sClassName, sizeof(sClassName));
        if ( StrEqual("hostage_entity", sClassName) ) {
            BlockEntity(iEntity);
        }
    }
}    

BlockEntity(client)
{
    #if defined DEBUG
        LogError("[DEBUG] BLOCK client %i.", client);
    #endif
    SetEntData(client, g_offsCollisionGroup, 5, 4, true);
}

UnblockEntity(client)
{
    #if defined DEBUG
        LogError("[DEBUG] UNBLOCK client %i.", client);
    #endif
    SetEntData(client, g_offsCollisionGroup, 2, 4, true);
}

BlockClientAll()
{
    #if defined DEBUG
        LogError("[DEBUG] Block all.");
    #endif
    for (new i = 1; i <= MaxClients; i++)
    {
        if ( IsClientInGame(i) && IsPlayerAlive(i) )
        {
            BlockEntity(i);
        }
    }
}

UnblockClientAll()
{
    #if defined DEBUG
        LogError("[DEBUG] Unblock all.");
    #endif
    for (new i = 1; i <= MaxClients; i++)
    {
        if ( IsClientInGame(i) && IsPlayerAlive(i) )
        {
            UnblockEntity(i);
        }
    }
}

