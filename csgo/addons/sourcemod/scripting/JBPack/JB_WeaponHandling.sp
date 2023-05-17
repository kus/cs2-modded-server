#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name        = "JailBreak Weapon Handling",
	author      = "Eyal282",
	description = "Handles weapon spawners ( game_player_equip ) for JailBreak",
	version     = "1.0",
	url         = ""
};

GlobalForward g_hOnShouldSpawnWeapons;

public void OnPluginStart()
{
	g_hOnShouldSpawnWeapons = CreateGlobalForward("JBPack_OnShouldSpawnWeapons", ET_Event, Param_Cell);
}

public void OnEntityCreated(int entity, const char[] Classname)
{
	if (StrEqual(Classname, "game_player_equip"))
	{
		SDKHook(entity, SDKHook_Use, OnShouldUseGPE);
	}
}

public Action OnShouldUseGPE(int gpe, int activator)
{
	if(!IsPlayer(activator))
		return Plugin_Continue;

	Call_StartForward(g_hOnShouldSpawnWeapons);

	Call_PushCell(activator);
	
	Action rtn;
	Call_Finish(rtn);

	return rtn;
}

stock bool IsPlayer(int client)
{
	if (client <= 0)
		return false;

	else if (client > MaxClients)
		return false;

	return true;
}
