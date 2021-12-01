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

#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "Prophunt - Anti ghosting",
	author = ".#Zipcore",
	description = "Anti ghosting system for prophunt.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

public void OnPluginStart()
{
	HookUserMessage(GetUserMessageId("ProcessSpottedEntityUpdate"), MsgHook_ProcessSpottedEntityUpdate, true);
	
	// Late load
	LoopIngamePlayers(iClient)
		OnClientPutInServer(iClient);
}

public void OnClientPutInServer(int iClient)
{
	// Hide player location info
	SDKHook(iClient, SDKHook_PostThinkPost, Hook_OnPostThinkPost);
	SDKHook(iClient, SDKHook_PostThink, Hook_OnPostThink);
	SDKHook(iClient, SDKHook_SetTransmit, Hook_OnTransmit);
}

public Action MsgHook_ProcessSpottedEntityUpdate(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
	return Plugin_Handled;
}

public void Hook_OnPostThink(int iClient)
{
	static Address g_aCanBeSpotted = view_as<Address>(-1);
	
	if(g_aCanBeSpotted <= view_as<Address>(-1))
		g_aCanBeSpotted = view_as<Address>(FindSendPropInfo("CBaseEntity", "m_bSpotted") - 4);
	
	if(GetClientTeam(iClient) != CS_TEAM_T)
		return;
	
	SetEntPropEnt(iClient, Prop_Send, "m_bSpotted", false);
	SetEntProp(iClient, Prop_Send, "m_bSpottedByMask", 0, 4, 0);
	SetEntProp(iClient, Prop_Send, "m_bSpottedByMask", 0, 4, 1);
	StoreToAddress(GetEntityAddress(iClient)+g_aCanBeSpotted, GetClientTeam(iClient) == CS_TEAM_T ? 0 : 9 , NumberType_Int32);
}

public void Hook_OnPostThinkPost(int iClient)
{
	SetEntProp(iClient, Prop_Send, "m_iAddonBits", 0);
	SetEntPropString(iClient, Prop_Send, "m_szLastPlaceName", "");
}

public Action Hook_OnTransmit(int iTarget, int iReceiver)
{
	// Invalid target? We don't care!
	if(0 >= iTarget > MaxClients)
		return Plugin_Continue;
	
	// Show self
	if(iTarget == iReceiver)
		return Plugin_Continue;
		
	// Receiver is alive
	if(IsPlayerAlive(iReceiver))
		return Plugin_Continue;
	
	// Target has no child
	if(PH_IsFakePropBlocked(iTarget))
		return Plugin_Continue;
		
	// Target not alive
	if(!IsPlayerAlive(iTarget))
		return Plugin_Continue;
		
	// Target is not a hider (anymore)
	if(GetClientTeam(iTarget) != CS_TEAM_T)
		return Plugin_Continue;
		
	// Receiver is spectating the target
	if(GetEntPropEnt(iReceiver, Prop_Send, "m_hObserverTarget") == iTarget)
		return Plugin_Continue;
	
	// Reject rest
	return Plugin_Handled;
}