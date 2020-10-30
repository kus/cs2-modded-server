/*  CS:GO Weapons&Knives SourceMod Plugin
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

public void OnConfigsExecuted()
{
	GetConVarString(g_Cvar_DBConnection, g_DBConnection, sizeof(g_DBConnection));
	GetConVarString(g_Cvar_TablePrefix, g_TablePrefix, sizeof(g_TablePrefix));
	g_iGraceInactiveDays = g_Cvar_InactiveDays.IntValue;
	
	if(g_DBConnectionOld[0] != EOS && strcmp(g_DBConnectionOld, g_DBConnection) != 0)
	{
		delete db;
	}
	
	if(db == null)
	{
		g_iDatabaseState = 0;
		Database.Connect(SQLConnectCallback, g_DBConnection);
	}
	else
	{
		DeleteInactivePlayerData();
	}
	
	strcopy(g_DBConnectionOld, sizeof(g_DBConnectionOld), g_DBConnection);
	
	g_Cvar_ChatPrefix.GetString(g_ChatPrefix, sizeof(g_ChatPrefix));
	g_iKnifeStatTrakMode = g_Cvar_KnifeStatTrakMode.IntValue;
	g_bEnableFloat = g_Cvar_EnableFloat.BoolValue;
	g_bEnableNameTag = g_Cvar_EnableNameTag.BoolValue;
	g_bEnableStatTrak = g_Cvar_EnableStatTrak.BoolValue;
	g_bEnableSeed = g_Cvar_EnableSeed.BoolValue;
	g_fFloatIncrementSize = g_Cvar_FloatIncrementSize.FloatValue;
	g_iFloatIncrementPercentage = RoundFloat(g_fFloatIncrementSize * 100.0);
	g_bOverwriteEnabled = g_Cvar_EnableWeaponOverwrite.BoolValue;
	g_iGracePeriod = g_Cvar_GracePeriod.IntValue;
	if(g_iGracePeriod > 0)
	{
		HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
	
	ReadConfig();
}

public void OnClientPutInServer(int client)
{
	if(IsFakeClient(client))
	{
		if(g_bEnableStatTrak)
			SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
	else if(IsValidClient(client))
	{
		g_iIndex[client] = 0;
		g_FloatTimer[client] = INVALID_HANDLE;
		g_bWaitingForNametag[client] = false;
		g_bWaitingForSeed[client] = false;
		for (int i = 0; i < sizeof(g_WeaponClasses); i++)
		{
			g_iSeedRandom[client][i] = 0;
		}
		HookPlayer(client);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if(g_iDatabaseState > 1 && IsValidClient(client))
	{
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

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client))
	{
		if(g_bEnableStatTrak)
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
	else if(IsValidClient(client))
	{
		UnhookPlayer(client);
		for(int i = 0; i < sizeof(g_WeaponClasses); i++)
		{
			g_iSkins[client][i] = 0;
			g_iStatTrak[client][i] = 0;
			g_iStatTrakCount[client][i] = 0;
			g_NameTag[client][i] = "";
			g_fFloatValue[client][i] = 0.0;
			g_iWeaponSeed[client][i] = -1;
		}
		g_iKnife[client] = 0;
	}
}

public void OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientDisconnect(i);
		}
	}
}
