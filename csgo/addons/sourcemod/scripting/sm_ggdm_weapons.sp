#pragma semicolon 1

#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <ggdm>

public Plugin:myinfo = 
{
    name = "DeathMatch:SM Weapons Remover",
    author = GGDM_AUTHORS,
    description = "DeathMatch:SM Weapons Remover for SourceMod.",
    version = GGDM_VERSION,
    url = GGDM_URL
};

new g_WeaponParent;

new Handle:g_Cvar_RemoveOnRoundStart   = INVALID_HANDLE;
new Handle:g_Cvar_RemoveOnKill         = INVALID_HANDLE;
new Handle:g_Cvar_KeepHegrenades       = INVALID_HANDLE;

new bool:g_removeWeaponsRoundStart;
new bool:g_removeWeaponsKill;
new bool:g_keepHegrenades;

public OnPluginStart()
{
    g_Cvar_RemoveOnRoundStart = CreateConVar("sm_ggdm_remweap_round", "1", "Remove weapons on round start");
    g_removeWeaponsRoundStart = GetConVarBool(g_Cvar_RemoveOnRoundStart);
    HookConVarChange(g_Cvar_RemoveOnRoundStart, CvarChanged);

    g_Cvar_RemoveOnKill = CreateConVar("sm_ggdm_remweap_kill", "0", "Remove weapons on player kill");
    g_removeWeaponsKill = GetConVarBool(g_Cvar_RemoveOnKill);
    HookConVarChange(g_Cvar_RemoveOnKill, CvarChanged);

    g_Cvar_KeepHegrenades = CreateConVar("sm_ggdm_keep_hegrenades", "1", "Keep hegrenades when removing weapons");
    g_keepHegrenades = GetConVarBool(g_Cvar_KeepHegrenades);
    HookConVarChange(g_Cvar_KeepHegrenades, CvarChanged);
    
    g_WeaponParent = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");

    if ( g_removeWeaponsKill ) {
        StartHookKill();
    }
    if ( g_removeWeaponsRoundStart ) {
        StartHookRound();
    }
}

StartHookKill() {
    HookEvent("player_death", Event_PlayerDeath);
}

StartHookRound() {
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

StopHookKill() {
    UnhookEvent("player_death", Event_PlayerDeath);
}

StopHookRound() {
    UnhookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

public CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) {
    if ( cvar == g_Cvar_RemoveOnKill ) {
        g_removeWeaponsKill = GetConVarBool(g_Cvar_RemoveOnKill);
        if ( g_removeWeaponsKill ) {
            StartHookKill();
        } else {
            StopHookKill();
        }
        return;
    }

    if ( cvar == g_Cvar_RemoveOnRoundStart ) {
        g_removeWeaponsRoundStart = GetConVarBool(g_Cvar_RemoveOnRoundStart);
        if ( g_removeWeaponsRoundStart ) {
            StartHookRound();
        } else {
            StopHookRound();
        }
        return;
    }

    if ( cvar == g_Cvar_KeepHegrenades ) {
        g_keepHegrenades = GetConVarBool(g_Cvar_KeepHegrenades);
        return;
    }
}

public Action:Event_RoundStart(Handle:event,const String:name[],bool:dontBroadcast)
{
    removeAllWeapons();
}

removeAllWeapons() {
    new maxent = GetMaxEntities(), String:weapon[64];
    for (new i = MaxClients; i < maxent; i++) {
        if ( IsValidEdict(i) && IsValidEntity(i) && GetEntDataEnt2(i, g_WeaponParent) == -1 ) {
            GetEdictClassname(i, weapon, sizeof(weapon));
            if ( ( StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 ) ) {
                if (g_keepHegrenades && StrEqual("weapon_hegrenade", weapon)) {
                    continue;
                }
                RemoveEdict(i);
            }
        }
    }
}

public Action:Event_PlayerDeath(Handle:event,const String:name[],bool:dontBroadcast)
{
    removeAllWeapons();
}
