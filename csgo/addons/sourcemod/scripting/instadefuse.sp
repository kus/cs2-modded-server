#include <sdktools>
#include <cstrike>

new Float:g_c4PlantTime;
new bool:g_DefuseFlag;
new Float:g_activeIncendiary;
new Float:g_bombPosition[3];

public Plugin:myinfo =
{
	name = "Insta-Defuse",
	description = "Plugin to instantly defuse the bomb when no T's are alive and other circumstances",
	author = "Jacoblairm",
	version = "1.2",
	url = "http://steamcommunity.com/id/Jacoblairm"
};


public OnPluginStart()
{
	CreateConVar("sm_instadefuse_enabled", "1", "Whether the plugin is enabled", 0, false, 0.0, false, 0.0);
	HookEvent("bomb_begindefuse", Event_BeginDefuse);
	HookEvent("bomb_planted", Event_BombPlanted);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("molotov_detonate", molotov_explode);
	g_c4PlantTime = -1.0;
	g_activeIncendiary = -1.0;

}


public Action:Event_BeginDefuse(Handle:event, String:name[], bool:dontBroadcast)
{

	new Float:remaining = GetConVarFloat(FindConVar("mp_c4timer")) - (GetGameTime() - g_c4PlantTime);
	new iCount;
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			iCount++;
		}
		i++;
	}

	if((GetGameTime()-g_activeIncendiary)<7.0)
	{
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Active molotov present, Good luck defusing!", "Insta-Defuse");
	}
	
	if (GetConVarInt(FindConVar("sm_instadefuse_enabled")) == 1 && iCount < 1 && g_DefuseFlag && ((GetGameTime()-g_activeIncendiary)>=7.0))
	{

		if (remaining > 10.0 || (remaining > 5.0 && GetEventBool(event, "haskit", false)))
		{

			new userid = GetEventInt(event, "userid");
			CreateTimer(0.0, timer_delay, userid);
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 CT's defused the bomb in time! \x0F%.1fs\x01 remaining.", "Insta-Defuse", remaining);
			g_DefuseFlag = false;
		}

		if (remaining < 5.0 || (remaining < 10.0 && !GetEventBool(event, "haskit", false)))
		{

			CS_TerminateRound(1.5, CSRoundEndReason:8, false);
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 CT's didn't defuse in time! \x0F%.1fs\x01 remaining.", "Insta-Defuse", remaining);
			g_DefuseFlag = false;
		}
	}
	return Action:0;
}

public Action:Event_BombPlanted(Handle:event, String:name[], bool:dontBroadcast)
{
	g_c4PlantTime = GetGameTime();
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "planted_c4")) != -1)
	{
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", g_bombPosition);
	}
	
	return Action:0;
}

public Action:Event_RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	g_c4PlantTime = -1.0;
	g_DefuseFlag = true;
	g_activeIncendiary = 0.0;
	return Action:0;
}

public Action:timer_delay(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);

	if(client != 0)
	{
		if(IsPlayerAlive(client))
		{
			new c4 = FindEntityByClassname(MaxClients+1, "planted_c4");
			if(c4 != -1)
			{
				SetEntPropFloat(c4, Prop_Send, "m_flDefuseCountDown", 0);
				SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
			}
		}
	}
}


public molotov_explode(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	if(GetClientTeam(client) == 2)
	{
		new Float:f_Pos[3];
		f_Pos[0] = GetEventFloat(event, "x");
		f_Pos[1] = GetEventFloat(event, "y");
		f_Pos[2] = GetEventFloat(event, "z");

		if((FloatAbs(g_bombPosition[0])-FloatAbs(f_Pos[0]) < 170 ) && (FloatAbs(g_bombPosition[1])-FloatAbs(f_Pos[1]) < 170 ) && (FloatAbs(g_bombPosition[2])-FloatAbs(f_Pos[2]) < 170 ) )
		{
			g_activeIncendiary = GetGameTime();
		}
	}
}
