#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <eyal-jailbreak>

#define semicolon 1
#define newdecls required

native int JailBreakShop_GetClientCash(int client);

native int JailBreakShop_GiveClientCash(int client, int amount, bool includeMultipliers);

native void JailBreakShop_SetClientCash(int client, int amount);

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public void OnMapStart()
{
	AddFileToDownloadsTable("models/items/cs_gift.dx80.vtx")
	AddFileToDownloadsTable("models/items/cs_gift.dx90.vtx")
	AddFileToDownloadsTable("models/items/cs_gift.mdl")
	AddFileToDownloadsTable("models/items/cs_gift.phy")
	AddFileToDownloadsTable("models/items/cs_gift.sw.vtx")
	AddFileToDownloadsTable("models/items/cs_gift.vvd")
	AddFileToDownloadsTable("materials/models/items/cs_gift.vmt")
	AddFileToDownloadsTable("materials/models/items/cs_gift.vtf")
}

public Action Event_PlayerDeath(Event event, char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	float fOrigin[3];
	if(victim == 0)
	{
		return;
	}
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", fOrigin);
	if (victim != attacker && GetClientTeam(victim) == CS_TEAM_CT)
	{
		SpawnCase(fOrigin);
	}
}

void SpawnCase(float fOrigin[3])
{
	int iProp = CreateEntityByName("prop_physics_override");
	if (IsValidEntity(iProp))
	{
		DispatchKeyValue(iProp, "model", "models/items/cs_gift.mdl");
		DispatchKeyValue(iProp, "disableshadows", "1");
		DispatchKeyValue(iProp, "disablereceiveshadows", "1");
		DispatchKeyValue(iProp, "solid", "1");
		DispatchKeyValue(iProp, "PerformanceMode", "1");
		DispatchKeyValue(iProp, "classname", "jail_case");
		DispatchSpawn(iProp);
		TeleportEntity(iProp, fOrigin, NULL_VECTOR, NULL_VECTOR);
		SDKHook(iProp, SDKHook_Touch, OnTouch);
	}
}

public void OnTouch(int entity, int client)
{
	if (!(0 < client <= MaxClients))
	{
		return;
	}
	
	else if(GetClientTeam(client) == CS_TEAM_T)
	{
		int iRandomCredits = GetRandomInt(100, 1000);
		
		iRandomCredits = JailBreakShop_GiveClientCash(client, iRandomCredits, true);
		PrintToChatAll("%s \x02%N \x01has opened a gift and received \x7%d \x01credits!", PREFIX, client, iRandomCredits);
		AcceptEntityInput(entity, "Kill");
	}
}