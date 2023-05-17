#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

public Plugin myinfo = 
{
	name = "Strip on Spawn",
	author = "Kieran",
	description = "Strip weapons on spawn",
	version = "1.0",
	url = "https://github.com/KieranFYI"
};

ConVar cvMPCTDefaultMelee, cvMPCTDefaultPrimary, cvMPCTDefaultSecondary, cvMPTDefaultMelee, cvMPTDefaultPrimary, cvMPTDefaultSecondary;

char stMPCTDefaultMelee[50], stMPCTDefaultPrimary[50], stMPCTDefaultSecondary[50], stMPTDefaultMelee[50], stMPTDefaultPrimary[50], stMPTDefaultSecondary[50];

public void OnPluginStart()
{ 
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("round_prestart", OnRoundPreStart);

	cvMPCTDefaultMelee = FindConVar("mp_ct_default_melee");
	cvMPCTDefaultMelee.AddChangeHook(OnConvarChangedString);
	cvMPCTDefaultMelee.GetString(stMPCTDefaultMelee, sizeof(stMPCTDefaultMelee));

	cvMPCTDefaultSecondary = FindConVar("mp_ct_default_secondary");
	cvMPCTDefaultSecondary.AddChangeHook(OnConvarChangedString);
	cvMPCTDefaultSecondary.GetString(stMPCTDefaultSecondary, sizeof(stMPCTDefaultSecondary));

	cvMPCTDefaultPrimary = FindConVar("mp_ct_default_primary");
	cvMPCTDefaultPrimary.AddChangeHook(OnConvarChangedString);
	cvMPCTDefaultPrimary.GetString(stMPCTDefaultPrimary, sizeof(stMPCTDefaultPrimary));

	cvMPTDefaultMelee = FindConVar("mp_t_default_melee");
	cvMPTDefaultMelee.AddChangeHook(OnConvarChangedString);
	cvMPTDefaultMelee.GetString(stMPTDefaultMelee, sizeof(stMPTDefaultMelee));

	cvMPTDefaultSecondary = FindConVar("mp_t_default_secondary");
	cvMPTDefaultSecondary.AddChangeHook(OnConvarChangedString);
	cvMPTDefaultSecondary.GetString(stMPTDefaultSecondary, sizeof(stMPTDefaultSecondary));

	cvMPTDefaultPrimary = FindConVar("mp_t_default_primary");
	cvMPTDefaultPrimary.AddChangeHook(OnConvarChangedString);
	cvMPTDefaultPrimary.GetString(stMPTDefaultPrimary, sizeof(stMPTDefaultPrimary));
}

public Action OnRoundPreStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (IsClientInGame(i)) {
			StripWeapons(i);
		}
	}
	return Plugin_Continue;
}

public Action OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	StripWeapons(client);

	if (GetClientTeam(client) == CS_TEAM_CT) {

		if (strlen(stMPCTDefaultMelee) != 0) {
			GivePlayerItem(client, stMPCTDefaultMelee);
		}

		if (strlen(stMPCTDefaultSecondary) != 0) {
			GivePlayerItem(client, stMPCTDefaultSecondary);
		}

		if (strlen(stMPCTDefaultPrimary) != 0) {
			GivePlayerItem(client, stMPCTDefaultPrimary);
		}

		GivePlayerItem(client, "item_assaultsuit");

	} else if (GetClientTeam(client) == CS_TEAM_T) {

		if (strlen(stMPTDefaultMelee) != 0) {
			GivePlayerItem(client, stMPTDefaultMelee);
		}

		if (strlen(stMPTDefaultSecondary) != 0) {
			GivePlayerItem(client, stMPTDefaultSecondary);
		}

		if (strlen(stMPTDefaultPrimary) != 0) {
			GivePlayerItem(client, stMPTDefaultPrimary);
		}
	}

	return Plugin_Continue;
}

public void OnConvarChangedString(ConVar convar, char[] oldValue, char[] newValue)
{
	if (convar == cvMPCTDefaultMelee) {
		cvMPCTDefaultMelee.GetString(stMPCTDefaultMelee, sizeof(stMPCTDefaultMelee));
	}

	if (convar == cvMPCTDefaultSecondary) {
		cvMPCTDefaultSecondary.GetString(stMPCTDefaultSecondary, sizeof(stMPCTDefaultSecondary));
	}

	if (convar == cvMPCTDefaultPrimary) {
		cvMPCTDefaultPrimary.GetString(stMPCTDefaultPrimary, sizeof(stMPCTDefaultPrimary));
	}

	if (convar == cvMPTDefaultMelee) {
		cvMPTDefaultMelee.GetString(stMPTDefaultMelee, sizeof(stMPTDefaultMelee));
	}

	if (convar == cvMPTDefaultSecondary) {
		cvMPTDefaultSecondary.GetString(stMPTDefaultSecondary, sizeof(stMPTDefaultSecondary));
	}

	if (convar == cvMPTDefaultPrimary) {
		cvMPTDefaultPrimary.GetString(stMPTDefaultPrimary, sizeof(stMPTDefaultPrimary));
	}
}


stock void StripWeapons(int client)
{
	int index;
	int weapon;
	
	while((weapon = GetNextWeapon(client, index)) != -1)
	{
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}

	SetEntProp(client, Prop_Send, "m_bHasHeavyArmor", 0);
	SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
	SetEntProp(client, Prop_Send, "m_ArmorValue", 0.0);
}

stock int GetNextWeapon(int client, int &weaponIndex)
{
	static int weaponsOffset = -1;
	if (weaponsOffset == -1)
		weaponsOffset = FindDataMapInfo(client, "m_hMyWeapons");
	
	int offset = weaponsOffset + (weaponIndex * 4);
	
	int weapon;
	while (weaponIndex < 48) 
	{
		weaponIndex++;
		
		weapon = GetEntDataEnt2(client, offset);
		
		if (IsValidEdict(weapon)) 
			return weapon;
		
		offset += 4;
	}
	
	return -1;
} 