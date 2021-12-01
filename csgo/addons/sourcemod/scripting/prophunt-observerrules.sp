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
	name = "Prophunt - Observer Rules",
	author = ".#Zipcore",
	description = "Controlls who can spectate who and it's mode.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

#define SPECMODE_NONE           0
#define SPECMODE_FIRSTPERSON    4
#define SPECMODE_THIRDPERSON    5
#define SPECMODE_FREELOOK       6

bool g_bSpecForward[MAXPLAYERS + 1]; // Store observe switch direction to prevent observers stuck on one target, unable to switch targets

public void OnPluginStart()
{
	
	AddCommandListener(Cmd_spec_next, "spec_next");
	AddCommandListener(Cmd_spec_prev, "spec_prev");
	AddCommandListener(Cmd_spec_mode, "spec_mode");
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &impulse, float vel[3], float angles[3], int &iWeapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(IsPlayerAlive(iClient))
		return Plugin_Continue;
	
	CheckObserveTarget(iClient);
	
	return Plugin_Continue;
}

void CheckObserveTarget(int iClient)
{
	static int iLastTarget[MAXPLAYERS + 1];
	int iTarget = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
	
	// Save last target if available
	if(iLastTarget[iClient] != iTarget && iClient != iTarget)
		iLastTarget[iClient] = iTarget;
	
	// Let him continue to spectate
	if(CanSpectateTarget(iClient, iTarget))
		return;
	
	// Get next possible target
	iTarget = GetNextClient(iClient, iTarget, g_bSpecForward[iClient]);
	
	if (iTarget <= 0)
	{
		if(CanSpectateTarget(iClient, iLastTarget[iClient])) // Try to use last target if no new one can be found
			iTarget = iLastTarget[iClient];
		else return; // No valid target found, we don't need to block it in this case anyway
	}
	
	// Apply observer target
	ChangeClientTeam(iClient, CS_TEAM_CT);
	SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", iTarget);
	
	// Check spec mode
	int iSpecMode = GetEntProp(iClient, Prop_Send, "m_iObserverMode");
	if(iTarget > 0 && iSpecMode != SPECMODE_THIRDPERSON && iSpecMode != SPECMODE_FIRSTPERSON)
	{
		int iTeam = GetClientTeam(iTarget);
		SetEntProp(iClient, Prop_Send, "m_iObserverMode", iTeam == CS_TEAM_CT ? SPECMODE_FIRSTPERSON : SPECMODE_THIRDPERSON);
	}
}

// Client command: spec_next
// Validate observer target
public Action Cmd_spec_next(int iClient, const char[] command, int argc)
{
	g_bSpecForward[iClient] = true;
	SpecTarget(iClient);
	return Plugin_Handled;
}

// Client command: spec_prev
// Validate observer target
public Action Cmd_spec_prev(int iClient, const char[] command, int argc)
{
	g_bSpecForward[iClient] = false;
	SpecTarget(iClient, false);
	return Plugin_Handled;
}

// Client command: spec_mode
// Validate observer mode
public Action Cmd_spec_mode(int iClient, const char[] command, int argc)
{
	if (iClient == 0 || !IsClientInGame(iClient) || IsPlayerAlive(iClient))
		return Plugin_Handled;
	
	// Check observe target, just in case
	CheckObserveTarget(iClient);
	
	// We don't like to support freecam, so we let the player cycle only specmodes
	if(GetEntProp(iClient, Prop_Send, "m_iObserverMode") != SPECMODE_THIRDPERSON)
		SetEntProp(iClient, Prop_Send, "m_iObserverMode", SPECMODE_THIRDPERSON);
	else SetEntProp(iClient, Prop_Send, "m_iObserverMode", SPECMODE_FIRSTPERSON);
	
	return Plugin_Handled;
}

void SpecTarget(int iClient, bool fw = true)
{
	if (!iClient || !IsClientInGame(iClient) || IsPlayerAlive(iClient))
		return;
	
	int iTarget = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
	iTarget = GetNextClient(iClient, iTarget, fw);
	
	if (iTarget > 0)
		SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", iTarget);
}

stock int GetNextClient(int iClient, int iCurrent, bool fw = true)
{
	int d = (fw ? 1 : -1);
	int i = iCurrent;
	int begin = (fw ? 1 : MaxClients);
	int limit = (fw ? MaxClients + 1 : 0);
	
	int ttl = MaxClients; // One full circle
	
	while (ttl > 0)
	{
		ttl--;
		i = (i + d == limit ? begin : i + d);
		
		if(CanSpectateTarget(iClient, i))
			return i;
	}
	
	return -1;
}

bool CanSpectateTarget(int iClient, int iTarget)
{
	// Don't spec self
	if(iTarget == iClient)
		return false;
	
	// Invalid target
	if(iTarget <= 0 || !IsClientInGame(iTarget) || !IsPlayerAlive(iTarget))
		return false;
	
	// Players can only spectate CTs
	if(GetClientTeam(iTarget) == CS_TEAM_CT)
		return true;
	
	return false;
}