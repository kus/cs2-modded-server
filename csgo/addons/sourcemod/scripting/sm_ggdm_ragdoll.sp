#pragma semicolon 1

#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <ggdm>

public Plugin:myinfo = 
{
    name = "DeathMatch:SM Ragdoll Remover",
    author = GGDM_AUTHORS,
    description = "DeathMatch:SM Ragdoll Remover for SourceMod.",
    version = GGDM_VERSION,
    url = GGDM_URL
};

new Handle:g_Cvar_RemoveRagdolls          = INVALID_HANDLE;
new g_ragdollrem;

new Handle:g_Cvar_RagdollTime           = INVALID_HANDLE;
new Float:g_ragdollTime;

public OnPluginStart()
{
    g_Cvar_RagdollTime = CreateConVar("sm_ggdm_ragdolltime", "1.5", "Remove ragdoll time");
    g_ragdollTime = GetConVarFloat(g_Cvar_RagdollTime);
    
    g_Cvar_RemoveRagdolls = CreateConVar("sm_ggdm_removeragdolls", "1", "Remove Ragdolls (1 is on, 0 is off)");
    g_ragdollrem        = GetConVarBool(g_Cvar_RemoveRagdolls);
    
    HookConVarChange(g_Cvar_RemoveRagdolls, CvarChanged);
    HookConVarChange(g_Cvar_RagdollTime, CvarChanged);
    
    HookEvent("player_death", Event_PlayerDeath);
}

public CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if ( cvar == g_Cvar_RagdollTime )
    {
        g_ragdollTime = GetConVarFloat(g_Cvar_RagdollTime);
        if ( g_ragdollTime < 0 )
        {
            g_ragdollTime = 0.0;
        }
        return;
    }
    if ( cvar == g_Cvar_RemoveRagdolls )
    {
        g_ragdollrem = GetConVarBool(g_Cvar_RemoveRagdolls);
        if ( g_ragdollrem ) {
            HookEvent("player_death", Event_PlayerDeath);
        } else {
            UnhookEvent("player_death", Event_PlayerDeath);
        }
        return;
    }
}

public Action:Event_PlayerDeath(Handle:event,const String:name[],bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    if ( g_ragdollrem )
    {
        if ( IsValidEntity(client) )
        {
            new ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
            if ( ragdoll >= 0 )
            {
                CreateTimer(g_ragdollTime, RemRagDoll, ragdoll);
            }   
        }
    }
}

public Action:RemRagDoll(Handle:timer, any:ragdoll)
{
    if ( IsValidEntity(ragdoll) )
    {
        AcceptEntityInput(ragdoll, "kill");
    }
    
    return Plugin_Stop;
}
