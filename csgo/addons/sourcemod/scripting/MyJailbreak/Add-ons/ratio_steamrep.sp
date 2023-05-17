/*
 * MyJailbreak - Ratio - SteamRep Support.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * https://steamrep.com/plugin.php
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors>
#include <autoexecconfig>
#include <mystocks>
#include <socket>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_iMinSteamRepPoints;

// Bools
bool g_bIsLateLoad = false;
bool g_IsScammer[MAXPLAYERS+1];

// Convars
ConVar gc_bcheckIP;
ConVar gc_sExclude;

char g_sPrefixR[64];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Ratio - SteamRep Support", 
	author = "shanapu, Jameless, good_live", 
	description = "Adds support for Jameless steamrep plugin to MyJB ratio", 
	version = MYJB_VERSION, 
	url = MYJB_URL_LINK
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");

	// AutoExecConfig
	AutoExecConfig_SetFile("Ratio", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	gc_sExclude = AutoExecConfig_CreateConVar("sm_ratio_steamrep_exclude","","Which tags you DO NOT trust for reported scammers. Input the tags here for any community whose bans you DO NOT TRUST.");
	gc_bcheckIP = AutoExecConfig_CreateConVar("sm_ratio_steamrep_checkip","1","Include IP address of connecting players in query. Set to 0 to disable");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			OnClientConnected(i);
			OnClientPostAdminCheck(i);
		}

		g_bIsLateLoad = false;
	}
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("myratio"))
		SetFailState("You're missing the MyJailbreak - Ratio (ratio.smx) plugin");
}

public void OnConfigsExecuted()
{
	ConVar cBuffer = FindConVar("sm_ratio_prefix");
	cBuffer.GetString(g_sPrefixR, sizeof(g_sPrefixR));
}

public void OnClientConnected(int client)
{
	g_IsScammer[client]=false;
}

public void OnClientPostAdminCheck(int client)
{
	g_IsScammer[client]=false;

	Handle socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketSetArg(socket, GetClientUserId(client));
	SocketSetOption(socket, SocketSendTimeout, 5160);
	SocketSetOption(socket, SocketReceiveTimeout, 5160);
	// connect the socket
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, "steamrep.com", 80);
}

public int OnSocketConnected(Handle socket, int userid)
{
	// socket is connected, send the http request
	int client = GetClientOfUserId(userid);

	if (client == 0) {
		CloseHandle(socket);
		return;
	}

	if (IsClientConnected(client) && !CheckCommandAccess(client, "SkipSR", ADMFLAG_ROOT, true) && !IsFakeClient(client)) {
		char steamid[32];
		char requestStr[450];
		char excludetags[128];
		char ip[17]="";
		
		if (GetConVarInt(gc_bcheckIP) == 1){GetClientIP(client,ip,sizeof(ip));}
		GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
		// GetClientAuthString(client,steamid,sizeof(steamid));
		GetConVarString(gc_sExclude,excludetags,sizeof(excludetags));
		Format(requestStr, sizeof(requestStr), "GET /%s%s%s%s%s%s%s1.1.5 HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", "id2rep.php?steamID32=",steamid,"&ignore=",excludetags,"&IP=",ip,"&version=","steamrep.com");
		SocketSend(socket, requestStr);
	}
	else
	{
		CloseHandle(socket);
	}
}

public int OnSocketReceive(Handle socket, char[] receiveData, const int dataSize, int userid)
{
	// receive chunk
	int client = GetClientOfUserId(userid);

	if (client == 0)
	{
		CloseHandle(socket);
		return;
	}

	g_IsScammer[client] = true;
}

public int OnSocketDisconnected(Handle socket, int client)
{
	// Connection: close advises the webserver to close the connection when the transfer is finished
	CloseHandle(socket);
}

public int OnSocketError(Handle socket, const int errorType, const int errorNum, int client)
{
	// a socket error occured
	LogError("socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

public Action MyJailbreak_OnJoinGuardQueue(int client)
{
	if (g_IsScammer[client])
	{
		CPrintToChat(client, "%s %t", g_sPrefixR, "ratio_steamrep");
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool bDontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!IsValidClient(client, false, false))
		return Plugin_Continue;

	if (GetClientTeam(client) != CS_TEAM_CT)
		return Plugin_Continue;

	if (MyJailbreak_IsEventDayRunning())
		return Plugin_Continue;

	if (g_IsScammer[client])
	{
		CPrintToChat(client, "%s %t", g_sPrefixR, "ratio_steamrep", gc_iMinSteamRepPoints.IntValue);
		CreateTimer(5.0, Timer_SlayPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}

	return Plugin_Continue;
}

public Action Timer_SlayPlayer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if ((IsValidClient(client, false, false)) && (GetClientTeam(client) == CS_TEAM_CT))
	{
		ForcePlayerSuicide(client);
		ChangeClientTeam(client, CS_TEAM_T);
		CS_RespawnPlayer(client);
		MinusDeath(client);
	}

	return Plugin_Stop;
}

void MinusDeath(int client)
{
	if (IsValidClient(client, true, true))
	{
		int frags = GetEntProp(client, Prop_Data, "m_iFrags");
		int deaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		SetEntProp(client, Prop_Data, "m_iFrags", (frags+1));
		SetEntProp(client, Prop_Data, "m_iDeaths", (deaths-1));
	}
}