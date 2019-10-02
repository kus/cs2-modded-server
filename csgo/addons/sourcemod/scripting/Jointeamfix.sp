#include <sourcemod>
#include <sdktools>
#include <cstrike>

new Handle:kz_respawn_enable = INVALID_HANDLE;
new Handle:kz_respawn_delay = INVALID_HANDLE;
new Handle:kz_respawn_msgs = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "KZ Jointeam Fix",
	author = "Sikari",
	description = "Fixes player not spawning when cvar kz_team_restriction is set to 1 or 2. After the fix you can use KZ_team_restriction freely",
	version = "1.2",
	url = ""
};

public OnPluginStart()
{
	kz_respawn_enable = CreateConVar("kz_respawn_enable", "1", "Enables/disables JTFix");
	kz_respawn_delay = CreateConVar("kz_respawn_delay", "0", "How much to delay respawning");
	kz_respawn_msgs = CreateConVar("kz_respawn_msgs", "0", "Enables/disables respawning messages");

	HookEvent("player_team", Event_Spawn);
	HookEvent("player_death", Event_Death);
}


public Event_Spawn( Handle:Spawn_Event, const String:Death_Name[], bool:Death_Broadcast )
{
	if( GetConVarBool(kz_respawn_enable) )
	{
		new client = GetClientOfUserId( GetEventInt(Spawn_Event,"userid") );
		new team = GetEventInt(Spawn_Event, "team");

		if( client != 0 && team > 1 )
		{
			new Float:respawndelaytime = GetConVarFloat(kz_respawn_delay);
			CreateTimer(respawndelaytime, RespawnClient, any:client);

			if( GetConVarBool(kz_respawn_msgs) )
			{
				new respawndelaytimeint = GetConVarInt(kz_respawn_delay);
				PrintToChat(client, "\x01\x04[JTFix] \x01You will spawn in %d seconds...", respawndelaytimeint);
			}
		}
	}
}

public Event_Death( Handle:Death_Event, const String:Death_Name[], bool:Death_Broadcast )
{
	if( GetConVarBool(kz_respawn_enable) )
	{
		new client = GetClientOfUserId( GetEventInt(Death_Event,"userid") );

		if ( client != 0 )
		{
			new Float:respawndelaytime = GetConVarFloat(kz_respawn_delay);
			CreateTimer(respawndelaytime, RespawnClient, any:client);

			if( GetConVarBool(kz_respawn_msgs) )
			{
				new respawndelaytimeint = GetConVarInt(kz_respawn_delay);
				PrintToChat(client,"\x01\x04[JTFix] \x01You will spawn in %d seconds...", respawndelaytimeint);
			}
		}
	}
}

public Action:RespawnClient( Handle:timer, any:client )
{
	if( GetConVarBool(kz_respawn_enable) )
	{
	if (IsClientInGame(client) && GetClientTeam(client) == CS_TEAM_SPECTATOR) {
	return Plugin_Handled;
	} else {
		if ( IsValidEntity(client) && IsClientInGame(client) && !IsPlayerAlive(client) )
			{
			CS_RespawnPlayer(client);
			}
		}
	}
	
	return Plugin_Handled;
}
