#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

ConVar gCV_PluginEnable = null;

ConVar sv_alltalk = null;
ConVar sv_deadtalk = null;
ConVar sv_full_alltalk = null;
ConVar sv_talk_enemy_dead = null;
ConVar sv_talk_enemy_living = null;

bool gB_PluginEnable = true;
EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "Force AllTalk",
	author = "Nickelony",
	description = "Enables every 'talk' related CVar.",
	version = "1.1",
	url = "http://steamcommunity.com/id/nickelony/"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO)
	{
		SetFailState("This plugin is for CSGO only.");
	}
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	
	gCV_PluginEnable = CreateConVar("sm_alltalk", "1", "Enable or Disable forced AllTalk.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	sv_alltalk = FindConVar("sv_alltalk");
	sv_deadtalk = FindConVar("sv_deadtalk");
	sv_full_alltalk = FindConVar("sv_full_alltalk");
	sv_talk_enemy_dead = FindConVar("sv_talk_enemy_dead");
	sv_talk_enemy_living = FindConVar("sv_talk_enemy_living");
	
	gCV_PluginEnable.AddChangeHook(OnConVarChanged);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gB_PluginEnable = gCV_PluginEnable.BoolValue;
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(!gB_PluginEnable)
	{
		return;
	}
	
	if(sv_alltalk != null)
	{
		sv_alltalk.BoolValue = true;
	}
	
	if(sv_deadtalk != null)
	{
		sv_deadtalk.BoolValue = true;
	}
	
	if(sv_full_alltalk != null)
	{
		sv_full_alltalk.BoolValue = true;
	}
	
	if(sv_talk_enemy_dead != null)
	{
		sv_talk_enemy_dead.BoolValue = true;
	}
	
	if(sv_talk_enemy_living != null)
	{
		sv_talk_enemy_living.BoolValue = true;
	}
}
