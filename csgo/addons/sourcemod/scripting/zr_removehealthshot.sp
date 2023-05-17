#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <zombiereloaded>

public Plugin myinfo =
{
	name = "ZR Remove Healthshots on Infect",
	author = "Franc1sco franug",
	description = "",
	version = "1.0",
	url = "http://steamcommunity.com/id/franug"
};

public int ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	CreateTimer(0.1, Timer_Remove, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Remove(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return;
	
	
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	
	for (int i = 0; i < size; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if (IsValidWeapon(weapon))
		{
			int wid = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			if(wid == view_as<int>(CSWeapon_HEALTHSHOT))
			{
				RemovePlayerItem(client, weapon);
				AcceptEntityInput(weapon, "Kill");
			}
		}
		
	}
}

stock bool IsValidWeapon(int weaponEntity)
{
	if (weaponEntity > 4096 && weaponEntity != INVALID_ENT_REFERENCE) {
		weaponEntity = EntRefToEntIndex(weaponEntity);
	}
	
	if (!IsValidEdict(weaponEntity) || !IsValidEntity(weaponEntity) || weaponEntity == -1) {
		return false;
	}
	
	char weaponClass[64];
	GetEdictClassname(weaponEntity, weaponClass, sizeof(weaponClass));
	
	return StrContains(weaponClass, "weapon_") == 0;
}