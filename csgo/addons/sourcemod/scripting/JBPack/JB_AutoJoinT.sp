#include <cstrike>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name        = "Auto Join On Connect",
	author      = "Author was lost by a thief :(",
	description = "Auto Join On Connect",
	version     = "1.0",
	url         = ""

};

public void OnPluginStart()
{
	HookEvent("player_connect_full", Event_OnFullConnect, EventHookMode_Post);
}

public Action Event_OnFullConnect(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (client != 0 && IsClientInGame(client) && !IsFakeClient(client))
	{
		CreateTimer(1.0, AssignTeam, GetClientUserId(client));
	}

	return Plugin_Continue;
}

public Action AssignTeam(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);

	if(client == 0)
		return Plugin_Continue;

	ChangeClientTeam(client, CS_TEAM_T);

	return Plugin_Continue;
}
