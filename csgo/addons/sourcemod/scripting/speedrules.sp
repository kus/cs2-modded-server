#define PLUGIN_AUTHOR ".#Zipcore"
#define PLUGIN_NAME "Speed Rules"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_DESCRIPTION "Advanced system to sync speed rules"
#define PLUGIN_URL "zipcore.net"

#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <speedrules>

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

#define LoopClients(%1) for(int %1=1;%1<=MaxClients;++%1)

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define LoopArray(%1,%2) for(int %1=0;%1<GetArraySize(%2);++%1)

ArrayList g_aNames[MAXPLAYERS + 1];
ArrayList g_aType[MAXPLAYERS + 1];
ArrayList g_aAmount[MAXPLAYERS + 1];
ArrayList g_aTime[MAXPLAYERS + 1];
ArrayList g_aPriority[MAXPLAYERS + 1];

Handle g_OnClientAdd;
Handle g_OnClientAddPost;
Handle g_OnClientRemoved;
Handle g_OnClientReset;
Handle g_OnClientExpired;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("speedrules");
	
	for (int iClient = 1; iClient <= MAXPLAYERS; iClient++) // MaxClients is not set on AskPluginLoad2
	{
		g_aNames[iClient] = new ArrayList(32);
		g_aType[iClient] = new ArrayList();
		g_aAmount[iClient] = new ArrayList();
		g_aTime[iClient] = new ArrayList();
		g_aPriority[iClient] = new ArrayList();
	}
	
	CreateNative("SpeedRules_Reset", Native_Reset);
	CreateNative("SpeedRules_ResetTemp", Native_ResetTemp);
	CreateNative("SpeedRules_ResetType", Native_ResetType);
	CreateNative("SpeedRules_ResetName", Native_ResetName);
	CreateNative("SpeedRules_ClientReset", Native_ClientReset);
	CreateNative("SpeedRules_ClientResetTemp", Native_ClientResetTemp);
	CreateNative("SpeedRules_ClientResetType", Native_ClientResetType);
	CreateNative("SpeedRules_ClientResetName", Native_ClientResetName);
	CreateNative("SpeedRules_ClientRemove", Native_ClientRemove);
	CreateNative("SpeedRules_ClientAdd", Native_ClientAdd);
	CreateNative("SpeedRules_ClientGetCount", Native_ClientGetCount);
	CreateNative("SpeedRules_ClientGetActive", Native_ClientGetActive);
	CreateNative("SpeedRules_ClientFind", Native_ClientFind);
	CreateNative("SpeedRules_ClientGetInfo", Native_ClientGetInfo);
	CreateNative("SpeedRules_ClientGetTime", Native_ClientGetTime);
	CreateNative("SpeedRules_ClientGetSpeed", Native_ClientGetSpeed);
	
	g_OnClientAdd = CreateGlobalForward("SpeedRules_OnClientAdd", ET_Event, Param_Cell, Param_String, Param_Cell, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnClientAddPost = CreateGlobalForward("SpeedRules_OnClientAddPost", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_OnClientRemoved = CreateGlobalForward("SpeedRules_OnClientRemoved", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_OnClientReset = CreateGlobalForward("SpeedRules_OnClientReset", ET_Ignore, Param_Cell);
	g_OnClientExpired = CreateGlobalForward("SpeedRules_OnClientExpired", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell);
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("speedrules_version", PLUGIN_VERSION, "Speed rules version", FCVAR_DONTRECORD|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	CreateTimer(0.1, Timer_Update, _, TIMER_REPEAT);
	
	HookEvent("player_spawn", Event_OnPlayerSpawnPre, EventHookMode_Pre);
}

public void OnClientPutInServer(int iClient)
{
	ResetClient(iClient);
}

public Action Event_OnPlayerSpawnPre(Handle event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetClient(iClient);
	
	return Plugin_Continue;
}

public Action Timer_Update(Handle timer)
{
	LoopAlivePlayers(iClient)
		UpdateSpeed(iClient);
	
	return Plugin_Continue;
}

void UpdateSpeed(int iClient)
{
	float fSpeed = GetClientSpeed(iClient, true);
	
	if(fSpeed != GetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue"))
		SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", fSpeed);
}

float GetClientSpeed(int iClient, bool clear)
{
	if(clear)
		ClearTemp(iClient); // Cleanup table of outdated rules
	
	bool bRules[6] =  { false, ...};
	float fAmounts[6] =  { 1.0, 1.0, 1.0, 0.0, 0.0, 1.0};
	int iPriorities[6] =  { -1, -1, -1, -1, -1, -1};
	
	LoopArray(iIndex, g_aType[iClient])
	{
		float fAmount = g_aAmount[iClient].Get(iIndex);
		int iPriority = g_aPriority[iClient].Get(iIndex);
		int iType = g_aType[iClient].Get(iIndex);
		
		// Dismiss
		if(iPriorities[iType] > iPriority)
			continue;
		
		// Same priority
		if(iPriorities[iType] == iPriority)
		{
			// Override if greater amount
			if(fAmount > fAmounts[iType])
				fAmounts[iType] = fAmount;
		}
		// Higher priority
		else
		{
			// Override
			fAmounts[iType] = fAmount;
			iPriorities[iType] = iPriority;
		}
		
		bRules[iType] = true;
	}
	
	float fSpeed;
	
	// Base
	if(bRules[SR_Base])
		fSpeed = fAmounts[SR_Base];
	
	// Mul
	if(bRules[SR_Mul])
		fSpeed *= fAmounts[SR_Mul];
	
	// Add
	if(bRules[SR_Add])
		fSpeed += fAmounts[SR_Add];
	
	// Sub
	if(bRules[SR_Sub])
		fSpeed -= fAmounts[SR_Sub];
	
	// Max
	if(bRules[SR_Max] && fAmounts[SR_Max] < fSpeed)
		fSpeed = fAmounts[SR_Max];
	
	// Min
	if(bRules[SR_Min] && fAmounts[SR_Min] > fSpeed)
		fSpeed = fAmounts[SR_Min];
		
	return fSpeed;
}

/* Helper */

void ResetClient(int iClient)
{
	g_aNames[iClient].Clear();
	g_aType[iClient].Clear();
	g_aAmount[iClient].Clear();
	g_aTime[iClient].Clear();
	g_aPriority[iClient].Clear();
			
	Call_StartForward(g_OnClientReset);
	Call_PushCell(iClient);
	Call_Finish();
}

void EraseByIndex(int iClient, int iIndex, bool bByNative)
{
	if(bByNative)
	{
		char sName[32];
		g_aNames[iClient].GetString(iIndex, sName, sizeof(sName));
		int iType = g_aType[iClient].Get(iIndex);
		float fAmount = g_aAmount[iClient].Get(iIndex);
		int iPriority = g_aPriority[iClient].Get(iIndex);
			
		Call_StartForward(g_OnClientRemoved);
		Call_PushCell(iClient);
		Call_PushString(sName);
		Call_PushCell(iType);
		Call_PushCell(fAmount);
		Call_PushCell(iPriority);
		Call_Finish();
	}
	
	g_aNames[iClient].Erase(iIndex);
	g_aType[iClient].Erase(iIndex);
	g_aAmount[iClient].Erase(iIndex);
	g_aTime[iClient].Erase(iIndex);
	g_aPriority[iClient].Erase(iIndex);
}

void ClearTemp(int iClient)
{
	float fTime = GetGameTime();
	
	LoopArray(iIndex, g_aTime[iClient])
	{
		float fTime2 = g_aTime[iClient].Get(iIndex);
		
		if(fTime2 != -1 && fTime2 < fTime) // Is temp & outdated
		{
			char sName[32];
			g_aNames[iClient].GetString(iIndex, sName, sizeof(sName));
			int iType = g_aType[iClient].Get(iIndex);
			float fAmount = g_aAmount[iClient].Get(iIndex);
			int iPriority = g_aPriority[iClient].Get(iIndex);
			
			g_aNames[iClient].Erase(iIndex);
			g_aType[iClient].Erase(iIndex);
			g_aAmount[iClient].Erase(iIndex);
			g_aTime[iClient].Erase(iIndex);
			g_aPriority[iClient].Erase(iIndex);
			
			Call_StartForward(g_OnClientExpired);
			Call_PushCell(iClient);
			Call_PushString(sName);
			Call_PushCell(iType);
			Call_PushCell(fAmount);
			Call_PushCell(iPriority);
			Call_Finish();
		}
	}
}

bool AddSpeedRule(int iClient, char sName[32], int iType, float fAmount, float fTTL, int iPriority)
{
	// Let other plugins modify or block new speedrules
	Action aResult;
	Call_StartForward(g_OnClientAdd);
	Call_PushCell(iClient);
	Call_PushString(sName);
	Call_PushCell(iType);
	Call_PushCellRef(fAmount);
	Call_PushCellRef(fTTL);
	Call_PushCellRef(iPriority);
	Call_Finish(aResult);
	
	if((aResult == Plugin_Handled || aResult == Plugin_Stop))
		return false; // Don't add this speedrule
	
	// Only allow one rule per name for each type
	int iIndex = -1
	while ((iIndex = FindRule(iClient, iType, sName)) != -1)
		EraseByIndex(iClient, iIndex, false); 
	
	// Save rule
	g_aNames[iClient].PushString(sName);
	g_aType[iClient].Push(iType);
	g_aAmount[iClient].Push(fAmount);
	g_aTime[iClient].Push(fTTL > 0.0 ? GetGameTime() + fTTL : -1.0);
	g_aPriority[iClient].Push(iPriority);
	
	// Announce new rule added
	Call_StartForward(g_OnClientAddPost);
	Call_PushCell(iClient);
	Call_PushString(sName);
	Call_PushCell(iType);
	Call_PushCell(fAmount);
	Call_PushCell(fTTL);
	Call_PushCell(iPriority);
	Call_Finish();
	
	return true;
}

int GetActive(int iClient, int iType)
{
	int iPriority = -1;
	int iReturn = -1;
	LoopArray(iIndex, g_aTime[iClient])
	{
		if(g_aType[iClient].Get(iIndex) != iType)
			continue;
		
		if(g_aPriority[iClient].Get(iIndex) < iPriority)
			continue;
		
		if(iReturn > -1 && g_aPriority[iClient].Get(iIndex) == iPriority && g_aAmount[iClient].Get(iReturn) < g_aAmount[iClient].Get(iIndex))
			continue;
		
		iPriority = g_aPriority[iClient].Get(iIndex);
		iReturn = iIndex;
	}
	
	return iReturn;
}

void ResetTemp(int iClient, bool bByNative)
{
	LoopArray(iIndex, g_aTime[iClient])
	{
		if(g_aTime[iClient].Get(iIndex) == -1.0)
			continue;
		
		EraseByIndex(iClient, iIndex, bByNative);
	}
}

void ResetType(int iClient, int iType, bool bByNative)
{
	LoopArray(iIndex, g_aTime[iClient])
	{
		if(g_aType[iClient].Get(iIndex) != iType)
			continue;
		
		EraseByIndex(iClient, iIndex, bByNative);
	}
}

void ResetByName(int iClient, char sName[32], bool bByNative)
{
	int iIndex = -1;
	while((iIndex = g_aNames[iClient].FindString(sName)) != -1)
		EraseByIndex(iClient, iIndex, bByNative);
}

int FindRule(int iClient, int iType, char[] sName)
{
	char sBuffer[32];
	LoopArray(iIndex, g_aTime[iClient])
	{
		if(g_aType[iClient].Get(iIndex) != iType)
			continue;
		
		g_aNames[iClient].GetString(iIndex, sBuffer, sizeof(sBuffer));
		
		if(StrEqual(sBuffer, sName))
			return iIndex;
	}
	
	return -1;
}

/* Natives: Global */

public int Native_Reset(Handle plugin, int numParams)
{
	LoopClients(iClient)
		ResetClient(iClient);
}

public int Native_ResetTemp(Handle plugin, int numParams)
{
	LoopClients(iClient)
		ResetTemp(iClient, true);
}

public int Native_ResetName(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(1, sName, sizeof(sName));
	
	LoopClients(iClient)
		ResetByName(iClient, sName, true);
}

public int Native_ResetType(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	LoopClients(iClient)
		ResetType(iClient, iType, true);
}

/* Natives: Client*/

public int Native_ClientReset(Handle plugin, int numParams)
{
	ResetClient(GetNativeCell(1));
}

public int Native_ClientResetTemp(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	ResetTemp(iClient, true);
}

public int Native_ClientResetType(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	ResetType(iClient, GetNativeCell(2), true);
}

public int Native_ClientResetName(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(2, sName, sizeof(sName));
	ResetByName(GetNativeCell(1), sName, true);
}

public int Native_ClientRemove(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	int iIndex = GetNativeCell(2);
	
	if(g_aType[iClient].Length <= iIndex)
		return false;
		
	EraseByIndex(iClient, iIndex, true);
	return true;
}

public int Native_ClientAdd(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(2, sName, sizeof(sName));
	
	return AddSpeedRule(GetNativeCell(1), sName, GetNativeCell(3), GetNativeCell(4), GetNativeCell(5), GetNativeCell(6));
}

public int Native_ClientGetCount(Handle plugin, int numParams)
{
	return g_aType[GetNativeCell(1)].Length;
}

public int Native_ClientGetActive(Handle plugin, int numParams)
{
	return GetActive(GetNativeCell(1), GetNativeCell(2));
}

public int Native_ClientFind(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(3, sName, sizeof(sName));
	
	return FindRule(GetNativeCell(1), GetNativeCell(2), sName);
}

public int Native_ClientGetInfo(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	int iIndex = GetNativeCell(2);
	
	char sName[32];
	g_aNames[iClient].GetString(iIndex, sName, sizeof(sName));
	SetNativeString(3, sName, sizeof(sName));
	
	SetNativeCellRef(4, g_aType[iClient].Get(iIndex));
	SetNativeCellRef(5, g_aAmount[iClient].Get(iIndex));
	SetNativeCellRef(6, g_aTime[iClient].Get(iIndex));
	SetNativeCellRef(7, g_aPriority[iClient].Get(iIndex));
}

public int Native_ClientGetTime(Handle plugin, int numParams)
{
	return g_aTime[GetNativeCell(1)].Get(GetNativeCell(2));
}

public int Native_ClientGetSpeed(Handle plugin, int numParams)
{
	return view_as<int>(GetClientSpeed(GetNativeCell(1), GetNativeCell(2)));
}