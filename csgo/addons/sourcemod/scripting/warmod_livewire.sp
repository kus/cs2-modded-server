#pragma semicolon 1

#include <sourcemod>
#include <protobuf>
#include <sdktools>
#include <socket>
#include <Base64>
#include <geoip>
#include <warmod>
#pragma newdecls required


/* cvars */
ConVar lw_enabled;
ConVar lw_address;
ConVar lw_port;
ConVar lw_bindaddress;
ConVar lw_group_name;
ConVar lw_group_password;

/* livewire */
Handle g_h_lw_socket = INVALID_HANDLE;
bool g_lw_connecting = false;
bool g_lw_connected = false;
char g_map[64];

/* Plugin info */
#define WM_VERSION				"0.5.4"
#define WM_DESCRIPTION			"Warmod LiveWire is a TCP logging plugin using Socket extension"

public Plugin myinfo = {
	name = "[BFG] WarMod LiveWire",
	author = "Versatile_BFG",
	description = WM_DESCRIPTION,
	version = WM_VERSION,
	url = "www.sourcemod.net"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("livewire");
	return APLRes_Success;
}

public void OnPluginStart()
{
	RegAdminCmd("lw_reconnect", LiveWire_ReConnect, ADMFLAG_ROOT, "Reconnects LiveWire if lw_enabled is 1");
	
	lw_enabled = CreateConVar("lw_enabled", "0", "Enable or disable LiveWire", FCVAR_NOTIFY);
	lw_address = CreateConVar("lw_address", "", "Sets the ip/host that LiveWire will use to connect", FCVAR_NOTIFY);
	lw_port = CreateConVar("lw_port", "", "Sets the port that LiveWire will use to connect", FCVAR_NOTIFY, true, 1.0);
	lw_bindaddress = CreateConVar("lw_bindaddress", "", "Optional setting to specify which ip LiveWire will bind to (for servers with multiple ips) - blank = automatic/primary", FCVAR_NOTIFY);
	lw_group_name = CreateConVar("lw_group_name", "", "Sets the group name that LiveWire will use", FCVAR_PROTECTED|FCVAR_DONTRECORD);
	lw_group_password = CreateConVar("lw_group_password", "", "Sets the group password that LiveWire will use", FCVAR_PROTECTED|FCVAR_DONTRECORD);
	
	HookConVarChange(lw_enabled, OnLiveWireChange);
}

public void OnMapStart()
{
	if (GetConVarBool(lw_enabled) && !g_lw_connected)
	{
		// connect to livewire
		LiveWire_Connect();
	}
	char g_MapName[64];
	char g_WorkShopID[64];
	char g_CurMap[128];
	GetCurrentMap(g_CurMap, sizeof(g_CurMap));
	if (StrContains(g_CurMap, "workshop", false) != -1)
	{
		GetCurrentWorkshopMap(g_MapName, sizeof(g_MapName), g_WorkShopID, sizeof(g_WorkShopID));
	}
	else
	{
		strcopy(g_map, sizeof(g_map), g_CurMap);
	}
	StringToLower(g_map, sizeof(g_map));
}

stock void GetCurrentWorkshopMap(char[] g_MapName, int iMapBuf, char[] g_WorkShopID, int iWorkShopBuf)
{
	char g_CurMap[128];
	char g_CurMapSplit[2][64];
	
	GetCurrentMap(g_CurMap, sizeof(g_CurMap));
	
	ReplaceString(g_CurMap, sizeof(g_CurMap), "workshop/", "", false);
	
	ExplodeString(g_CurMap, "/", g_CurMapSplit, 2, 64);
	
	strcopy(g_WorkShopID, iWorkShopBuf, g_CurMapSplit[0]);
	strcopy(g_MapName, iMapBuf, g_CurMapSplit[1]);
	strcopy(g_map, iMapBuf, g_CurMapSplit[1]);
}

public void OnLiveWireChange(Handle cvar, const char[] oldVal, const char[] newVal)
{
	if (StrEqual(newVal, "1"))
	{
		LiveWire_Connect();
		CreateTimer(600.0, LiveWire_Check, 0, TIMER_REPEAT);
		CreateTimer(1800.0, LiveWire_Ping, _, TIMER_REPEAT);
	}
	else
	{
		LiveWire_Disconnect();
	}
}

public Action LiveWire_ReConnect(int client, int args)
{
	if (GetConVarBool(lw_enabled))
	{
		LiveWire_Disconnect();
		LiveWire_Connect();
	}
	else
	{
		ReplyToCommand(client, "LiveWire not enabled!");
	}
	return Plugin_Handled;
}

void LiveWire_Connect()
{
	if (!g_lw_connecting)
	{
		g_h_lw_socket = SocketCreate(SOCKET_TCP, OnSocketError);
		char address[256];
		GetConVarString(lw_address, address, sizeof(address));
		int port = GetConVarInt(lw_port);
		
		// bind socket to ip address - used for servers with multiple ips
		char bindaddress[32];
		GetConVarString(lw_bindaddress, bindaddress, sizeof(bindaddress));
		if (StrEqual(bindaddress, ""))
		{
			int hostIP = GetConVarInt(FindConVar("hostip"));
			Format(bindaddress, 32, "%d.%d.%d.%d", hostIP >> 24, hostIP >> 16 & 255, hostIP >> 8 & 255, hostIP & 255);
		}
		// TODO: validate as ip?
		PrintToServer("<LiveWire> Binding socket to \"%s\"", bindaddress);
		SocketBind(g_h_lw_socket, bindaddress, 0);
		
		PrintToServer("<LiveWire> Connecting to \"%s:%d\"", address, port);
		
		SocketConnect(g_h_lw_socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, address, port);
		g_lw_connecting = true;
	}
}

public void LiveWireLogEvent(const char[] event)
{
	LiveWire_Send(event);
}

void LiveWire_Send(const char[] format, any ...)
{
	char event[1024];
	char eventB64[1024];
	// format arguments
	VFormat(event, sizeof(event), format, 2);
	if (GetConVarBool(lw_enabled) && g_lw_connected)
	{
		// add a newline to each event
		//StrCat(event, sizeof(event), "\n");
		EncodeBase64(eventB64, sizeof(eventB64), event);
		// send to socket
		//SocketSend(g_h_lw_socket, event);
		SocketSend(g_h_lw_socket, eventB64);
	}
}

void LiveWire_Disconnect()
{
	g_lw_connecting = false;
	// check if connected
	if (g_lw_connected)
	{
		g_lw_connected = false;
		// close socket
		CloseHandle(g_h_lw_socket);
	}
}

public int OnSocketConnected(Handle socket, any arg)
{
	g_lw_connecting = false;
	g_lw_connected = true;
	PrintToServer("<LiveWire> Connected");
	char username[64];
	char password[512];
	char servername[255];
	GetConVarString(FindConVar("hostname"), servername, sizeof(servername));
	GetConVarString(lw_group_name, username, sizeof(username));
	GetConVarString(lw_group_password, password, sizeof(password));
	
	int hostIP = GetConVarInt(FindConVar("hostip"));
	char ipAddress[32];
	// convert ip address to standard dotted notation
	Format(ipAddress, sizeof(ipAddress), "%d.%d.%d.%d", hostIP >>> 24, 0xFF & (hostIP >>> 16), 0xFF & (hostIP >>> 8), 0xFF & hostIP);
	
	EscapeStringLive(username, sizeof(username));
	EscapeStringLive(password, sizeof(password));
	LogLiveWireEvent("{\"event\": \"server_status\", \"game\": \"csgo\", \"version\": \"%s\", \"map\": \"%s\", \"server\": {\"name\": \"%s\", \"ip\": \"%s\", \"port\": %d}, \"username\": \"%s\", \"password\": \"%s\", \"unixTime\": %d}", WM_VERSION, g_map, servername, ipAddress, GetConVarInt(FindConVar("hostport")), username, password, GetTime());
	
	LogPlayers();
}

public int OnSocketReceive(Handle socket, char[] receiveData, const int dataSize, any arg)
{
	/* do nothing */
}

public int OnSocketDisconnected(Handle socket, any arg)
{
	g_lw_connecting = false;
	g_lw_connected = false;
	CloseHandle(socket);
	PrintToServer("<LiveWire> Disconnected");
}

public int OnSocketError(Handle socket, const int errorType, const int errorNum, any hFile)
{
	g_lw_connecting = false;
	g_lw_connected = false;
	LogError("Warmod LiveWire - Socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

public void OnClientConnected(int client)
{
	if (!GetConVarBool(lw_enabled)) {
		return;
	}
	
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			count++;
		}
	}
	if (count == 1)
	{
		// reconnect livewire on first player join, server seems to go to sleep
		// when there are no players in the server (e.g. server start)
		LiveWire_ReConnect(0, 0);
	}
}

public Action LiveWire_Check(Handle timer)
{
	if (!g_lw_connected && GetConVarBool(lw_enabled))
	{
		LiveWire_Connect();
	}
}

public Action LiveWire_Ping(Handle timer)
{
	if (g_lw_connected)
	{
		LogLiveWireEvent("{\"event\": \"ping\"}");
	}
}

void LogPlayers()
{
	char ip_address[32];
	char country[2];
	char log_string[384];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			GetClientIP(i, ip_address, sizeof(ip_address));
			GeoipCode2(ip_address, country);
			CS_GetLogString(i, log_string, sizeof(log_string));
			
			EscapeStringLive(ip_address, sizeof(ip_address));
			EscapeStringLive(country, sizeof(country));
			LogLiveWireEvent("{\"event\": \"player_status\", \"player\": %s, \"address\": \"%s\", \"country\": \"%s\"}", log_string, ip_address, country);
		}
	}
}

stock void LogLiveWireEvent(const char[] format, any ...)
{
	char event[1024];
	VFormat(event, sizeof(event), format, 2);
	
	// inject timestamp into JSON object, hacky but quite simple
	char timestamp[64];
	FormatTime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S");
	
	// remove leading '{' from the event and add the timestamp in, including new '{'
	Format(event, sizeof(event), "{\"timestamp\": \"%s\", %s", timestamp, event[1]);
	
	LiveWire_Send(event);
}


/**
 *  escape a string, designed for JSON encoding
 * 
 * @noreturn
 */

stock void EscapeStringLive(char[] value, int size)
{
	ReplaceString(value, size, "\\", "\\\\");
	ReplaceString(value, size, "\"", "\\\"");
	ReplaceString(value, size, "\b", "\\b");
	ReplaceString(value, size, "\t", "\\t");
	ReplaceString(value, size, "\n", "\\n");
	ReplaceString(value, size, "\f", "\\f");
	ReplaceString(value, size, "\r", "\\r");
}
