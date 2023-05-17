#include <sdktools>
#include <sourcemod>
#include <eyal-jailbreak>

#pragma semicolon 1
#pragma newdecls  required

native void LR_isAutoBhopEnabled();

public Plugin myinfo =
{
	name        = "JailBreak Bhop",
	author      = "Eyal282",
	description = "Bhop API plugin",
	version     = "1.0",
	url         = ""
};

Handle hcv_AutoBhop         = INVALID_HANDLE;
Handle hcv_OriginalAutoBhop = INVALID_HANDLE;

public void OnPluginStart()
{
	AutoExecConfig_SetFile("JB_Bhop", "sourcemod/JBPack");
	
	hcv_AutoBhop = UC_CreateConVar("jb_autobunnyhopping", "1", "Is auto bunnyhop enabled by default?");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

	hcv_OriginalAutoBhop = FindConVar("sv_autobunnyhopping");


	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
}

public void OnMapStart()
{
	SetConVarBool(hcv_OriginalAutoBhop, GetConVarBool(hcv_AutoBhop));
}

public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (client == 0 || !IsPlayerAlive(client))
		return Plugin_Continue;

	else if (IsFakeClient(client))
		return Plugin_Continue;

	SetConVarBool(hcv_OriginalAutoBhop, GetConVarBool(hcv_AutoBhop));

	return Plugin_Continue;
}

public void LastRequest_OnLRStarted(int Prisoner, int Guard)
{
	if (!GetConVarBool(hcv_AutoBhop))
	{
		SetConVarBool(hcv_OriginalAutoBhop, false);
		return;
	}

	if (LR_isAutoBhopEnabled())
	{
		SetConVarBool(hcv_OriginalAutoBhop, true);
	}
	else
	{
		SetConVarBool(hcv_OriginalAutoBhop, false);
	}
}
