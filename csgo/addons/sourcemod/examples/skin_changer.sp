#include <sourcemod>
#include <sdktools>
#include <n_arms_fix>

public Plugin myinfo =
{
	name = "Example: My basic player skin changer",
	author = "NomisCZ",
	description = "Skin for players",
	version = "1.0",
	url = "http://steamcommunity.com/id/olympic-nomis-p"
}

public void OnPluginStart()
{
}

public void N_ArmsFix_OnClientReady(int client)
{
	SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/xxx/yyy_arms.mdl");
	SetEntityModel(client, "models/player/custom_player/xxx/yyy.mdl");
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client)) ? true : false;
}
