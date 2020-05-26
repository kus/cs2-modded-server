#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "boomix"
#define PLUGIN_VERSION "1.20"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <smlib>
//#include <sdkhooks>

#include "modelsinmap/mim_globals.sp"
#include "modelsinmap/mim_functions.sp"
#include "modelsinmap/mim_modelmoving.sp"
#include "modelsinmap/mim_menu.sp"
#include "modelsinmap/mim_spawnmodels.sp"

public Plugin myinfo = 
{
	name = "Add models inside map",
	author = PLUGIN_AUTHOR,
	description = "Add models inside map",
	version = PLUGIN_VERSION,
	url = "http://google.lv"
};

public void OnPluginStart()
{

	HookEvent("round_start", 	MIM_RoundStart);
	RegAdminCmd("sm_props", 	CMD_Models, ADMFLAG_BAN);
	
	BuildPath(Path_SM, g_sModelConfig, sizeof(g_sModelConfig), "configs/models/main.cfg");
	BuildPath(Path_SM, g_sModelConfig2, sizeof(g_sModelConfig2), "configs/models/models.cfg");
	
	Function_OnPluginStart();

}


public bool IsAdmin(int client)
{
	if(Client_HasAdminFlags(client, ADMFLAG_GENERIC) || Client_HasAdminFlags(client, ADMFLAG_ROOT) || Client_HasAdminFlags(client, ADMFLAG_BAN))
		return true;
	else return false;
}
