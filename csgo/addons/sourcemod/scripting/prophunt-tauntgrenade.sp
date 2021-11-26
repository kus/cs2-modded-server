#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <soundlib>
#include <emitsoundany>
#include <prophunt>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "Prophunt - Taunt Grenade",
	author = ".#Zipcore",
	description = "Seekers can use t.a. grenades to taunt in range hiders.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

ConVar g_cvChanceAverage;
ConVar g_cvChanceSpotted;

ConVar g_cvChanceDistance1;
ConVar g_cvChanceDistance2;
ConVar g_cvChanceDistance3;

ConVar g_cvDistance1;
ConVar g_cvDistance2;
ConVar g_cvDistance3;

ConVar g_cvGrenades;

ConVar g_cvPrice;
ConVar g_cvSort;
ConVar g_cvUnlockTime;

public void OnPluginStart()
{
	g_cvChanceAverage = CreateConVar("ph_taunt_grenade_chance_average", "50.5", "Per player chance. (2 hiders half this value)");
	
	g_cvChanceSpotted = CreateConVar("ph_taunt_grenade_chance_spotted", "50.5", "Additional chance when spotted by taunt grenade.");
	
	g_cvChanceDistance1 = CreateConVar("ph_taunt_grenade_chance_dist1", "15.0", "Chance when in range #1.");
	g_cvChanceDistance2 = CreateConVar("ph_taunt_grenade_chance_dist2", "10.0", "Chance when in range #2.");
	g_cvChanceDistance3 = CreateConVar("ph_taunt_grenade_chance_dist3", "8.0", "Chance when in range #3.");
	
	g_cvDistance1 = CreateConVar("ph_taunt_grenade_dist1", "1250.0", "Check range #1.");
	g_cvDistance2 = CreateConVar("ph_taunt_grenade_dist2", "750.0", "Check range #2.");
	g_cvDistance3 = CreateConVar("ph_taunt_grenade_dist3", "550.0", "Check range #3.");
	
	g_cvGrenades = CreateConVar("ph_taunt_grenades", "1", "Limit amount of grenades a player can get at spawn.");
	
	g_cvPrice = CreateConVar("ph_taunt_grenade_price", "60", "Taunt grenade price.");
	g_cvSort = CreateConVar("ph_taunt_grenade_sort", "10", "Taunt grenade sort order.");
	g_cvUnlockTime = CreateConVar("ph_taunt_grenade_unlocktime", "110", "Taunt grenade price.");
	
	AutoExecConfig(true, "prophunt-tauntgrenade");
	
	HookEvent("tagrenade_detonate", OnTagrenadeDetonate);
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "prophunt"))
		PH_RegisterShopItem("Taunt Grenade", CS_TEAM_CT, g_cvPrice.IntValue, g_cvSort.IntValue, g_cvUnlockTime.IntValue, false);
}

public void OnMapStart()
{
	PH_RegisterShopItem("Taunt Grenade", CS_TEAM_CT, g_cvPrice.IntValue, g_cvSort.IntValue, g_cvUnlockTime.IntValue, false);
}

public void PH_OnSeekerSpawn(int iClient)
{
	for (int i = 0; i < g_cvGrenades.IntValue; i++)
		GivePlayerItem(iClient, "weapon_tagrenade");
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, "Taunt Grenade"))
		return Plugin_Handled;
	
	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, "Taunt Grenade"))
		GivePlayerItem(iClient, "weapon_tagrenade");
}

public void OnTagrenadeDetonate(Event event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(event.GetInt("userid", 0));
	int iEntity = event.GetInt("entityid", 0);
	
	float fPos[3];
	fPos[0] = event.GetFloat("x", 0.0);
	fPos[1] = event.GetFloat("y", 0.0);
	fPos[2] = event.GetFloat("z", 0.0);
	
	int iHidersAlive;
	LoopAlivePlayers(iTarget)
		if(GetClientTeam(iTarget) == CS_TEAM_T)
			iHidersAlive++;
		
	float fAverageChance = g_cvChanceAverage.FloatValue;
	float fChance = 2.0*fAverageChance/(float(iHidersAlive)+1); // Default chance for all hiders
	
	int iCount;
	LoopAlivePlayers(iTarget)
	{
		if(GetClientTeam(iTarget) != CS_TEAM_T)
			continue;
		
		float fPos2[3];
		GetClientAbsOrigin(iTarget, fPos2);
		
		// Target visible
		Handle trace = TR_TraceRayFilterEx(fPos, fPos2, MASK_VISIBLE, RayType_EndPoint, OnTraceForTagrenade, iEntity);
		if (TR_DidHit(trace) && TR_GetEntityIndex(trace) == iTarget)
			fChance += g_cvChanceSpotted.FloatValue; // Increase chance by being spotted by the grenade
		delete trace;
		
		// Increase chance by being close the grenade
		if(GetVectorDistance(fPos, fPos2) < g_cvDistance1.FloatValue)
			fChance += g_cvChanceDistance1.FloatValue;
		else if(GetVectorDistance(fPos, fPos2) < g_cvDistance2.FloatValue)
			fChance += g_cvChanceDistance2.FloatValue;
		else if(GetVectorDistance(fPos, fPos2) < g_cvDistance3.FloatValue)
			fChance += g_cvChanceDistance3.FloatValue;
		
		if(GetRandomFloat(0.0, 100.0) > fChance)
			continue;
		
		PH_ForceTaunt(iTarget, iClient);
		iCount++;
	}
}

public bool OnTraceForTagrenade(int entity, int contentsMask, any tagrenade)
{
	if (entity == tagrenade)
		return false;
	return true;
}