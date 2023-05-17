#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <zombiereloaded>
#include <cstrike>

new bool:started;

public Plugin:myinfo =
{
	name = "SM ZR Force Teams",
	author = "Franc1sco franug",
	description = "",
	version = "1.1",
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart() 
{
	HookEvent("player_spawn", OnSpawn);
	
	HookEvent("round_start", EventRoundStart, EventHookMode_Pre);
}

public Action:OnSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(started) return;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(GetClientTeam(client) == CS_TEAM_T) CS_SwitchTeam(client, CS_TEAM_CT);
}

public Action:EventRoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
	started = false;
}

public Action:ZR_OnClientInfect(&client, &attacker, &bool:motherInfect, &bool:respawnOverride, &bool:respawn)
{
	if(!started) started = true;
}
	