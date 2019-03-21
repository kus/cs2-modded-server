#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <ggdm>

public Plugin:myinfo = 
{
	name = "DeathMatch:SM Spawn Protection",
	author = GGDM_AUTHORS,
	description = "DeathMatch:SM Spawn Protection for SourceMod.",
	version = GGDM_VERSION,
	url = GGDM_URL
};

new Handle:g_Cvar_SPTime;
new Handle:g_Cvar_ChangeColor;
new Float:g_SPTime;
new bool:g_ChangeColor;

new g_RenderModeOffset;
new g_RenderClrOffset;
new g_Color[4] = {255, 255, 255, 128};
new g_NormColor[4] = {255, 255, 255, 255};

new Handle:g_Cvar_RemoveOnFire;
new bool:g_removeOnFire;
new Handle:g_Timers[MAXPLAYERS + 1];

new Handle:g_Cvar_SpEnabled;
new bool:g_spEnabled;

public OnPluginStart()
{
	g_Cvar_SPTime = CreateConVar("sm_ggdm_sptime", "2", "Sets the amount of seconds user's will be protected from getting killed on their respawn");
	g_Cvar_ChangeColor = CreateConVar("sm_ggdm_spchangecolor", "1", "Change color on spawn protected players");
	g_Cvar_RemoveOnFire = CreateConVar("sm_ggdm_sp_removeonfire", "0", "Removes spawn protection if player fires");
	g_Cvar_SpEnabled = CreateConVar("sm_ggdm_sp_enable", "1", "Enable spawn protection");

	g_SPTime = GetConVarFloat(g_Cvar_SPTime);
	g_ChangeColor = GetConVarBool(g_Cvar_ChangeColor);
	g_removeOnFire = GetConVarBool(g_Cvar_RemoveOnFire);
	g_spEnabled = GetConVarBool(g_Cvar_SpEnabled);

	HookConVarChange(g_Cvar_SPTime, CvarChanged);
	HookConVarChange(g_Cvar_ChangeColor, CvarChanged);
	HookConVarChange(g_Cvar_RemoveOnFire, CvarChanged);
	HookConVarChange(g_Cvar_SpEnabled, CvarChanged);
	
	g_RenderModeOffset = FindSendPropOffs("CCSPlayer", "m_nRenderMode");
	g_RenderClrOffset = FindSendPropOffs("CCSPlayer", "m_clrRender");

	StartHook();	
}

StartHook() {
	HookEvent("player_spawn", PlayerSpawn);
	if ( g_removeOnFire ) {
		HookEvent("weapon_fire", Event_WeaponFire);
	}
}

public CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) {
	if ( cvar == g_Cvar_SPTime ) {
		g_SPTime = GetConVarFloat(g_Cvar_SPTime);
		return;
	}
	if ( cvar == g_Cvar_ChangeColor ) {
		g_ChangeColor = GetConVarBool(g_Cvar_ChangeColor);
		return;
	}
	if ( cvar == g_Cvar_RemoveOnFire ) {
		g_removeOnFire = GetConVarBool(g_Cvar_RemoveOnFire);
		if ( g_removeOnFire ) {
			HookEvent("weapon_fire", Event_WeaponFire);
		} else {
			UnhookEvent("weapon_fire", Event_WeaponFire);
		}
		return;
	}
	if ( cvar == g_Cvar_SpEnabled ) {
		g_spEnabled = GetConVarBool(g_Cvar_SpEnabled);
		if ( g_spEnabled ) {
			StartHook();
		} else {
			UnhookEvent("player_spawn", PlayerSpawn);
			if ( g_removeOnFire ) {
				UnhookEvent("weapon_fire", Event_WeaponFire);
			}
			for (new i = 1; i <= MaxClients; i++) {
				if ( g_Timers[i] != INVALID_HANDLE ) {
					CloseHandle(g_Timers[i]);
					RemoveProtectionClient(i);
				}
			}
		}
		return;
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new Team = GetClientTeam(client);
	
	if ( IsPlayerAlive(client) && (Team == 2 || Team == 3) )
	{
		SpawnProtectClient(client);
	}
	
	return Plugin_Continue;
}

SpawnProtectClient(client)
{
	if ( !g_SPTime )
	{
		return;
	}
		
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	g_Timers[client] = CreateTimer(g_SPTime, RemoveSpawnProtection, client);
	
	if ( g_ChangeColor )
	{
		UTIL_Render(client, g_Color);
	}
	
	return;
}

public Action:RemoveSpawnProtection(Handle:Timer, any:client)
{
	RemoveProtectionClient(client);

	return;
}

RemoveProtectionClient(client) {
	g_Timers[client] = INVALID_HANDLE;

	if ( !IsClientInGame(client) || !IsPlayerAlive(client) )
	{
		return;
	}
	
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	
	if ( g_ChangeColor )
	{
		UTIL_Render(client, g_NormColor);
	}
}

UTIL_Render(client, const color[4])
{
	new mode = (color[3] == 255) ? K_RENDER_NORMAL : K_RENDER_TRANS_COLOR;
	
	SetEntData(client, g_RenderModeOffset, mode, 1);
	SetEntDataArray(client, g_RenderClrOffset, color, 4, 1);
	ChangeEdictState(client);
}


public Event_WeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if ( g_Timers[client] == INVALID_HANDLE ) {
		return;
	}
	CloseHandle(g_Timers[client]);

	RemoveProtectionClient(client);
}
