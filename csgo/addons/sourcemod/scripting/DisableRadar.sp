#include <sourcemod>

#define HIDE_RADAR_CSGO 1<<12

#define PLUGIN_NAME "DisableRadar"
#define PLUGIN_VERSION "1.2.2"

new String:strGame[10];
new bool:g_bEnabled;

public Plugin:myinfo = 
{
	name = "Disable Radar",
	author = "Internet Bully, some random guy",
	description = "Turns off Radar on spawn",
	version     = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
}

public OnPluginStart() 
{
	new Handle:hRandom;
	HookConVarChange((hRandom = CreateConVar("sm_disableradar_enabled", "1", 
	"Plugin enabled? - Hides the Radar top-left", _, true, 0.0, true, 1.0)), OnEnabledChanged);
	g_bEnabled = GetConVarBool(hRandom);
	CloseHandle(hRandom);

	AutoExecConfig(true);

	HookEvent("player_spawn", Player_Spawn);
	
	GetGameFolderName(strGame, sizeof(strGame));
	
	if(StrContains(strGame, "cstrike") != -1) 
		HookEvent("player_blind", Event_PlayerBlind, EventHookMode_Post);
}
public Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.0, RemoveRadar, GetClientUserId(client));
}  

public Action:RemoveRadar(Handle:timer, any:userid) 
{
	new client = GetClientOfUserId(userid);

	if(client == 0) return;

	if(! g_bEnabled) return;

	if(StrContains(strGame, "csgo") != -1) SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR_CSGO);
	else if(StrContains(strGame, "cstrike") != -1) 
		CSSHideRadar(client);
} 

public Event_PlayerBlind(Handle:event, const String:name[], bool:dontBroadcast)  // from GoD-Tony's "Radar Config" https://forums.alliedmods.net/showthread.php?p=1471473
{
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	if (client && GetClientTeam(client) > 1)
	{
		new Float:fDuration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
		CreateTimer(fDuration, RemoveRadar, GetClientUserId(client));
	}
}

CSSHideRadar(client)
{
	SetEntPropFloat(client, Prop_Send, "m_flFlashDuration", 3600.0);
	SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 0.5);
}


public OnEnabledChanged(Handle:cvar, const String:oldVal[], const String:newVal[]) {
	g_bEnabled = GetConVarBool(cvar);
}