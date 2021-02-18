/*  CS:GO Gloves SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
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

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#include "gloves/globals.sp"
#include "gloves/hooks.sp"
#include "gloves/helpers.sp"
#include "gloves/database.sp"
#include "gloves/config.sp"
#include "gloves/menus.sp"
#include "gloves/natives.sp"

public Plugin myinfo = 
{
	name = "Gloves",
	author = "kgns | oyunhost.net",
	description = "CS:GO Gloves Management",
	version = "1.0.5",
	url = "https://www.oyunhost.net"
};

public void OnPluginStart()
{
	LoadTranslations("gloves.phrases");
	
	g_Cvar_DBConnection = CreateConVar("sm_gloves_db_connection", "storage-local", "Database connection name in databases.cfg to use");
	g_Cvar_TablePrefix = CreateConVar("sm_gloves_table_prefix", "", "Prefix for database table (example: 'xyz_')");
	g_Cvar_ChatPrefix = CreateConVar("sm_gloves_chat_prefix", "[oyunhost.net]", "Prefix for chat messages");
	g_Cvar_EnableFloat = CreateConVar("sm_gloves_enable_float", "1", "Enable/Disable gloves float options");
	g_Cvar_FloatIncrementSize = CreateConVar("sm_gloves_float_increment_size", "0.2", "Increase/Decrease by value for gloves float");
	g_Cvar_EnableWorldModel = CreateConVar("sm_gloves_enable_world_model", "1", "Enable/Disable gloves to be seen by other living players");
	
	AutoExecConfig(true, "gloves");
	
	RegConsoleCmd("sm_gloves", CommandGlove);
	RegConsoleCmd("sm_glove", CommandGlove);
	RegConsoleCmd("sm_eldiven", CommandGlove);
	RegConsoleCmd("sm_gllang", CommandGloveLang);
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	
	AddCommandListener(ChatListener, "say");
	AddCommandListener(ChatListener, "say2");
	AddCommandListener(ChatListener, "say_team");
}

public void OnConfigsExecuted()
{
	GetConVarString(g_Cvar_DBConnection, g_DBConnection, sizeof(g_DBConnection));
	GetConVarString(g_Cvar_TablePrefix, g_TablePrefix, sizeof(g_TablePrefix));
	
	if(g_DBConnectionOld[0] != EOS && strcmp(g_DBConnectionOld, g_DBConnection) != 0 && db != null)
	{
		delete db;
		db = null;
	}
	
	if(db == null)
	{
		Database.Connect(SQLConnectCallback, g_DBConnection);
	}
	
	strcopy(g_DBConnectionOld, sizeof(g_DBConnectionOld), g_DBConnection);
	
	g_Cvar_ChatPrefix.GetString(g_ChatPrefix, sizeof(g_ChatPrefix));
	g_iEnableFloat = g_Cvar_EnableFloat.IntValue;
	g_fFloatIncrementSize = g_Cvar_FloatIncrementSize.FloatValue;
	g_iFloatIncrementPercentage = RoundFloat(g_fFloatIncrementSize * 100.0);
	g_iEnableWorldModel = g_Cvar_EnableWorldModel.IntValue;
	ReadConfig();
}

public Action CommandGlove(int client, int args)
{
	if (IsValidClient(client))
	{
		CreateMainMenu(client).Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action CommandGloveLang(int client, int args)
{
	if (IsValidClient(client))
	{
		CreateLanguageMenu(client).Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public void OnClientPostAdminCheck(int client)
{
	if(IsValidClient(client))
	{
		char steam32[20];
		char temp[20];
		GetClientAuthId(client, AuthId_Steam3, steam32, sizeof(steam32));
		strcopy(temp, sizeof(temp), steam32[5]);
		int index;
		if((index = StrContains(temp, "]")) > -1)
		{
			temp[index] = '\0';
		}
		g_iSteam32[client] = StringToInt(temp);
		GetPlayerData(client);
		QueryClientConVar(client, "cl_language", ConVarCallBack);
	}
}

public void ConVarCallBack(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(!g_smLanguageIndex.GetValue(cvarValue, g_iClientLanguage[client]))
	{
		g_iClientLanguage[client] = 0;
	}
}

public void GivePlayerGloves(int client)
{
	int playerTeam = GetClientTeam(client);
	if(g_iGloves[client][playerTeam] != 0)
	{
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
		if(ent != -1)
		{
			AcceptEntityInput(ent, "KillHierarchy");
		}
		FixCustomArms(client);
		ent = CreateEntityByName("wearable_item");
		if(ent != -1)
		{
			SetEntProp(ent, Prop_Send, "m_iItemIDLow", -1);
			
			if(g_iGloves[client][playerTeam] == -1)
			{
				char buffer[20];
				char buffers[2][10];
				GetRandomSkin(client, playerTeam, buffer, sizeof(buffer), g_iGroup[client][playerTeam]);
				ExplodeString(buffer, ";", buffers, 2, 10);
				SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", StringToInt(buffers[0]));
				SetEntProp(ent, Prop_Send,  "m_nFallbackPaintKit", StringToInt(buffers[1]));
			}
			else
			{
				SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", g_iGroup[client][playerTeam]);
				SetEntProp(ent, Prop_Send,  "m_nFallbackPaintKit", g_iGloves[client][playerTeam]);
			}
			SetEntPropFloat(ent, Prop_Send, "m_flFallbackWear", g_fFloatValue[client][playerTeam]);
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
			SetEntPropEnt(ent, Prop_Data, "m_hParent", client);
			if(g_iEnableWorldModel) SetEntPropEnt(ent, Prop_Data, "m_hMoveParent", client);
			SetEntProp(ent, Prop_Send, "m_bInitialized", 1);
			
			DispatchSpawn(ent);
			
			SetEntPropEnt(client, Prop_Send, "m_hMyWearables", ent);
			if(g_iEnableWorldModel) SetEntProp(client, Prop_Send, "m_nBody", 1);
		}
	}
}
