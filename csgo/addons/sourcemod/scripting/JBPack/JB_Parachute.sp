#include <sdktools>
#include <sourcemod>
#include <eyal-jailbreak>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name        = "JailBreak Parachute",
	author      = "Eyal282",
	description = "Parachute API plugin",
	version     = "1.0",
	url         = ""
};

native bool LR_isParachuteEnabled();
native bool LR_isParticipant(int client);

Handle hcv_Parachute      = INVALID_HANDLE;
Handle hcv_ParachuteSpeed = INVALID_HANDLE;

public void OnPluginStart()
{
	AutoExecConfig_SetFile("JB_Parachute", "sourcemod/JBPack");

	hcv_Parachute      = UC_CreateConVar("jb_parachute", "1", "Does your server want parachute? That's mostly for Israeli servers.");
	hcv_ParachuteSpeed = UC_CreateConVar("jb_parachute_speed", "50", "Speed of falling with parachute");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (!GetConVarBool(hcv_Parachute))
		return Plugin_Continue;

	// Abort by released button
	else if (!(buttons & IN_USE) || !IsPlayerAlive(client))
		return Plugin_Continue;

	// Abort by up speed
	float fVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);

	if (fVel[2] >= 0.0)
		return Plugin_Continue;

	// Abort by on ground flag
	else if (GetEntityFlags(client) & FL_ONGROUND)
		return Plugin_Continue;

	else if(LR_isParticipant(client) && !LR_isParachuteEnabled())
		return Plugin_Continue;

	// decrease fallspeed
	float fOldSpeed = fVel[2];

	// Player is falling to fast, lets slow him to max gc_fSpeed
	if (fVel[2] < GetConVarFloat(hcv_ParachuteSpeed) * (-1.0))
	{
		fVel[2] = GetConVarFloat(hcv_ParachuteSpeed) * (-1.0);
	}

	// fallspeed changed
	if (fOldSpeed != fVel[2])
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVel);

	return Plugin_Continue;
}