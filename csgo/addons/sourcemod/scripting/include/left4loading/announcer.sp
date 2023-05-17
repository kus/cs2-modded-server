/*
 * ============================================================================
 *
 *  Left 4 Loading
 *
 *  File:			announcer.sp
 *  Type:			Module
 *  Description:	Announces team changes, connecting and disconnecting 
 *					players.
 *
 *  Copyright (C) 2010  Mr. Zero
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

// --------------------
//       Private
// --------------------

static			bool:	g_bClientJustJoined[MAXPLAYERS+1] 					= {false};
static			String:	g_sOldClientSTEAMIds[MAXPLAYERS+1][STEAMID_LENGTH];
static			bool:	g_bInRoundEndPause									= false;
static					g_iExpectNewTeam[MAXPLAYERS+1]						= {0};
static	const	Float:	ROUND_END_PAUSE_TIME								= 20.0;

// **********************************************
//                 Forwards
// **********************************************

/**
 * On plugin start.
 *
 * @noreturn
 */
public _Announcer_OnPluginStart()
{
	HookEvent("player_team", _An_ChangeTeam_Event);
	HookEvent("player_activate", _An_PlayerActivated_Event);
	HookEvent("player_connect", _An_PlayerConnect_Event, EventHookMode_Pre);
	HookEvent("player_disconnect", _An_PlayerDisconnect_Event, EventHookMode_Pre);
	HookEvent("round_end", _An_RoundEnd_Event);
	HookPublicEvent(EVENT_READYUP_END, _An_OnReadyUpEnd);
}

/**
 * On ready up end.
 *
 * @noreturn
 */
public _An_OnReadyUpEnd()
{
	ClearSteamIdArray();
	for (new client = FIRST_CLIENT; client <= MaxClients; client++)
	{
		g_iExpectNewTeam[client] = 0;
	}
}

public _An_ChangeTeam_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || IsFakeClient(client)) return;
	
	new team = GetEventInt(event, "team");
	if (team == TEAM_SPECTATOR) return;
	
	PrintToChatAll("expected team %i, team %i", g_iExpectNewTeam[client], team);
	if (g_iExpectNewTeam[client] == team)
	{
		g_iExpectNewTeam[client] = 0;
		return;
	}
	
	new oldTeam = GetEventInt(event, "oldteam");
	oldTeam = GetTeamIndexFromTeamId(oldTeam);
	decl String:changeType[128];
	if (oldTeam == TEAM_SPECTATOR || g_bClientJustJoined[client])
	{
		g_bClientJustJoined[client] = false;
		Format(changeType, sizeof(changeType), "joined The");
	}
	else
	{
		Format(changeType, sizeof(changeType), "changed team to The");
	}
	
	decl String:teamName[128];
	GetTeamNameEx(team, true, teamName, sizeof(teamName));
	
	decl String:clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, sizeof(clientName));
	
	decl String:auth[128];
	if (IsClientAuthorized(client))
	{
		GetClientAuthString(client, auth, sizeof(auth));
		Format(auth, sizeof(auth), " ( %s )", auth);
	}
	else
	{
		Format(auth, sizeof(auth), " ( INVALID STEAMID )");
	}

	for (new i = FIRST_CLIENT; i <= MaxClients; i++)
	{
		if (/*i == client ||*/ !IsClientInGame(i) || IsFakeClient(i)) continue;
		PrintToChat(i, "* %s%s %s %s", clientName, (IsAdmin(i, ADMFLAG_GENERIC) ? auth : ""), changeType, teamName);
	}
}

public _An_RoundEnd_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bInRoundEndPause) return;
	g_bInRoundEndPause = true;
	CreateTimer(ROUND_END_PAUSE_TIME, _An_RoundEnd_Timer); // To prevent double round end

	decl String:auth[STEAMID_LENGTH];
	for (new client = FIRST_CLIENT; client < MaxClients+1; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client) || !IsClientAuthorized(client)) continue;
		
		GetClientAuthString(client, auth, sizeof(auth));
		g_sOldClientSTEAMIds[client] = auth;
	}
	
	for (new client = FIRST_CLIENT; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client)) continue;
		g_iExpectNewTeam[client] = GetOppositeTeamIndex(GetClientTeam(client));
	}
}

public Action:_An_RoundEnd_Timer(Handle:timer)
{
	g_bInRoundEndPause = false;
}

public _An_PlayerActivated_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || IsFakeClient(client) || IsAnOldPlayer(client)) return;
	
	g_bClientJustJoined[client] = true;
	
	decl String:clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, sizeof(clientName));
	
	decl String:auth[128];
	if (IsClientAuthorized(client))
	{
		GetClientAuthString(client, auth, sizeof(auth));
		Format(auth, sizeof(auth), " ( %s )", auth);
	}
	else
	{
		Format(auth, sizeof(auth), " ( INVALID STEAMID )");
	}

	for (new i = FIRST_CLIENT; i <= MaxClients; i++)
	{
		if (/*i == client ||*/ !IsClientInGame(i) || IsFakeClient(i)) continue;
		PrintToChat(i, "%s connected%s", clientName, (IsAdmin(i, ADMFLAG_GENERIC) ? auth : ""));
	}
	g_iExpectNewTeam[client] = 0;
}

public Action:_An_PlayerConnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
    SetEventBroadcast(event, true); // Hide default connect message
}

public Action:_An_PlayerDisconnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	SetEventBroadcast(event, true); // Hide default disconnect message
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || IsFakeClient(client)) return;
	
	RemoveFromSteamIdArray(client);
	
	if (IsClientInKickQueue(client)) return;
	
	decl String:clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, sizeof(clientName));
	
	decl String:auth[128];
	if (IsClientAuthorized(client))
	{
		GetClientAuthString(client, auth, sizeof(auth));
		Format(auth, sizeof(auth), " ( %s )", auth);
	}
	else
	{
		Format(auth, sizeof(auth), " ( INVALID STEAMID )");
	}
	
	for (new i = FIRST_CLIENT; i <= MaxClients; i++)
	{
		if (/*i == client ||*/ !IsClientInGame(i) || IsFakeClient(i)) continue;
		PrintToChat(i, "%s disconnected%s", clientName, (IsAdmin(i, ADMFLAG_GENERIC) ? auth : ""));
	}
}

// **********************************************
//                 Private API
// **********************************************

static ClearSteamIdArray()
{
	for (new index = FIRST_CLIENT; index <= MaxClients; index++)
	{
		Format(g_sOldClientSTEAMIds[index], STEAMID_LENGTH, "");
	}
}

static RemoveFromSteamIdArray(client)
{
	if (!client || IsFakeClient(client) || !IsClientAuthorized(client)) return;
	decl String:auth[STEAMID_LENGTH];
	GetClientAuthString(client, auth, sizeof(auth));
	
	for (new index = FIRST_CLIENT; index <= MaxClients; index++)
	{
		if (!StrEqual(auth, g_sOldClientSTEAMIds[index])) continue;
		Format(g_sOldClientSTEAMIds[index], STEAMID_LENGTH, "");
	}
}

static bool:IsAnOldPlayer(client)
{
	if (!client || IsFakeClient(client) || !IsClientAuthorized(client)) return false;
	decl String:auth[STEAMID_LENGTH];
	GetClientAuthString(client, auth, sizeof(auth));
	
	for (new index = FIRST_CLIENT; index <= MaxClients; index++)
	{
		if (!StrEqual(auth, g_sOldClientSTEAMIds[index])) continue;
		Format(g_sOldClientSTEAMIds[index], STEAMID_LENGTH, "");
		return true;
	}
	return false;
}