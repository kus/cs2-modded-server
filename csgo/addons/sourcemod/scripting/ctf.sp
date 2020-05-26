#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "boomix"
#define PLUGIN_VERSION "1.2"

#include <sdkhooks>
#include <emitsoundany>
#include <autoexecconfig>
#include "ctf/ctf_globals.sp"
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include "ctf/ctf_other.sp"
#include <ctf>
#include <capturetheflag>
#include "ctf/ctf_admin.sp"
#include "ctf/ctf_flags.sp"
#include "ctf/ctf_flagdefuse.sp"
#include "ctf/ctf_particles.sp"
#include "ctf/ctf_sounds.sp"
#include "ctf/ctf_hintbox.sp"
#include "ctf/ctf_weapons.sp"
#include "ctf/ctf_cvars.sp"
#include "ctf/ctf_respawn.sp"
#include "ctf/ctf_bombsite.sp"
#include "ctf/ctf_removebomb.sp"
#include "ctf/ctf_roundend.sp"
#include "ctf/ctf_configs.sp"
#include "ctf/ctf_natives.sp"


public Plugin myinfo = 
{
	name = "Capture the flag for CS:GO",
	author = PLUGIN_AUTHOR,
	description = "Capture the flag gamemode made by boomix",
	version = PLUGIN_VERSION,
	url = "http://burst.lv"
};

public void OnPluginStart()
{

	RegAdminCmd("sm_ctf", 		CMD_CTF, 		ADMFLAG_ROOT);
	RegConsoleCmd("sm_guns", 	CMD_Guns, 		"Weapons");
	RegConsoleCmd("sm_weapons", CMD_Guns, 		"Weapons 2");
	HookEvent("round_start", 	CTF_RoundStart);
	HookEvent("player_death", 	CTF_PlayerDeath);
	HookEvent("player_spawn", 	CTF_PlayerSpawn);
	HookEvent("player_team", 	CTF_PlayerTeam);
	
	LoopAllPlayers(i)
	{
		SDKHook(i, SDKHook_PostThink, Radar);
		b_AutoGiveWeapons[i] = false;
		b_DefusingFlag[i] = false;
		b_FlagCarrier[i] = false;
	}
		
	SetCvars();
	CreateConfigs();
	UpdateConvars();
	
}

public Radar(client)
{
    if(b_FlagCarrier[client])
        SetEntPropEnt(client, Prop_Send, "m_bSpotted", 1);
}  


public Action CTF_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	RoundEnd_OnRoundStart();
	Flags_OnRoundStart();
}

public Action CTF_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	Flags_OnPlayerDeath(client);
	Respawn_OnPlayerDeath(client);
}

public void OnClientDisconnect(int client)
{
	Flags_OnPlayerDeath(client);
	Respawn_OnPlayeDisconnect(client);
}

public void OnGameFrame()
{
	HintBox_OnGameFrame();
	RoundEnd_OnGameFrame();
}