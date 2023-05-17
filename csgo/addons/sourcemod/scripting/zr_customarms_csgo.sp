/*  ZR Custom CS:GO Arms
 *
 *  Copyright (C) 2017-2019 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <zombiereloaded>
#include <cstrike>

#define DEFAULT_ARMS "models/weapons/ct_arms_gign.mdl"

public Plugin:myinfo =
{
	name = "ZR Custom CS:GO Arms",
	author = "Franc1sco franug",
	description = "",
	version = "5.1",
	url = "http://steamcommunity.com/id/franug"
};

new Handle:kv;
new Handle:hPlayerClasses, String:sClassPath[PLATFORM_MAX_PATH] = "configs/zr/playerclasses.txt";

new Handle:trie_classes;

public OnPluginStart() 
{
	trie_classes = CreateTrie();

	HookEvent("player_spawn", OnSpawn);
}

public OnMapStart()
{
	PrecacheModel(DEFAULT_ARMS);
}

public Action:OnSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.7, Timer_SafeApply, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public ZR_OnClientInfected(client, attacker, bool:motherInfect, bool:respawnOverride, bool:respawn)
{
	CreateTimer(0.7, Timer_SafeApply, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	//Arms(client);
}

public Action Timer_SafeApply(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	
	if (!client || !IsClientInGame(client))return;
	Arms(client);
	
}

public ZR_OnClientHumanPost(client, bool:respawn, bool:protect)
{
	CreateTimer(0.7, Timer_SafeApply, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

Arms(client)
{
	if(!IsPlayerAlive(client)) return;
	
	new cindex = ZR_GetActiveClass(client);
	if(!ZR_IsValidClassIndex(cindex)) return;
	
	decl String:namet[64],String:model[128], String:currentmodel[128];
	ZR_GetClassDisplayName(cindex, namet, sizeof(namet));
	if(!GetTrieString(trie_classes, namet, model, sizeof(model))) return;
	
	GetEntPropString(client, Prop_Send, "m_szArmsModel", currentmodel, sizeof(currentmodel));
	
	if(strlen(model) > 3) 
	{

			int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(activeWeapon != -1)
			{
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
			}
			if(activeWeapon != -1)
			{
				DataPack dpack;
				CreateDataTimer(0.1, ResetGlovesTimer2, dpack);
				dpack.WriteCell(client);
				dpack.WriteCell(activeWeapon);
				dpack.WriteString(model);
			}
			int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
			if(ent != -1)
			{
				AcceptEntityInput(ent, "KillHierarchy");
			}
			SetEntPropString(client, Prop_Send, "m_szArmsModel", model);
	}
	else
	{
			int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(activeWeapon != -1)
			{
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
			}
			if(activeWeapon != -1)
			{
				DataPack dpack;
				CreateDataTimer(0.1, ResetGlovesTimer2, dpack);
				dpack.WriteCell(client);
				dpack.WriteCell(activeWeapon);
				dpack.WriteString(DEFAULT_ARMS);
			}
			int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
			if(ent != -1)
			{
				AcceptEntityInput(ent, "KillHierarchy");
			}
			SetEntPropString(client, Prop_Send, "m_szArmsModel", DEFAULT_ARMS);
		//PrintToChat(client, "used %s with class %i",manos[client], cindex);
	}
}

public Action ResetGlovesTimer2(Handle timer, DataPack pack)
{
	char model[128];
	ResetPack(pack);
	int clientIndex = pack.ReadCell();
	int activeWeapon = pack.ReadCell();
	pack.ReadString(model, 128);
	
	if(IsClientInGame(clientIndex))
	{
		SetEntPropString(clientIndex, Prop_Send, "m_szArmsModel", model);
		
		if(IsValidEntity(activeWeapon)) SetEntPropEnt(clientIndex, Prop_Send, "m_hActiveWeapon", activeWeapon);
	}
}

public OnAllPluginsLoaded()
{
	if (hPlayerClasses != INVALID_HANDLE)
	{
		UnhookConVarChange(hPlayerClasses, OnClassPathChange);
		CloseHandle(hPlayerClasses);
	}
	if ((hPlayerClasses = FindConVar("zr_config_path_playerclasses")) == INVALID_HANDLE)
	{
		SetFailState("Zombie:Reloaded is not running on this server");
	}
	HookConVarChange(hPlayerClasses, OnClassPathChange);
}

public OnClassPathChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	strcopy(sClassPath, sizeof(sClassPath), newValue);
	OnConfigsExecuted();
}

public OnConfigsExecuted()
{
	CreateTimer(0.2, OnConfigsExecutedPost);
}

public Action:OnConfigsExecutedPost(Handle:timer)
{
	if (kv != INVALID_HANDLE)
	{
		CloseHandle(kv);
	}
	kv = CreateKeyValues("classes");
	
	decl String:buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), "%s", sClassPath);
	
	if (!FileToKeyValues(kv, buffer))
	{
		SetFailState("Class data file \"%s\" not found", buffer);
	}
	
	if (KvGotoFirstSubKey(kv))
	{
		ClearTrie(trie_classes);
		decl String:name[64],String:model[128];
		
		do
		{
			KvGetString(kv, "name", name, sizeof(name));
			KvGetString(kv, "arms_path", model, sizeof(model), " ");
			
			SetTrieString(trie_classes, name, model);
			
			if(strlen(model) > 3 && FileExists(model) && !IsModelPrecached(model)) PrecacheModel(model);
			
		} while (KvGotoNextKey(kv));
	}
	KvRewind(kv);
}
	