#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "boomix"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <capturetheflag>

public Plugin myinfo = 
{
	name = "Capture the flag natives/forwards",
	author = PLUGIN_AUTHOR,
	description = "Events and stuff for capture the flag",
	version = PLUGIN_VERSION,
	url = "http://burst.lv"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_haveflag", CMD_HaveFlag, ADMFLAG_BAN);
}

public Action CMD_HaveFlag(int client, int args)
{
	bool b_HasFlag = CaptureTheFlag_HasFlag(client);
	if(b_HasFlag)
		PrintToChat(client, "You have the flag!");
	else
		PrintToChat(client, "You don't have the flag!");
}

public int CaptureTheFlag_OnFlagDropped(int client)
{
	PrintToChatAll("%N dropped flag", client);
}

public int CaptureTheFlag_OnFlagScore(int client)
{
	PrintToChatAll("%N score for team %i", client, GetClientTeam(client));
}

public int CaptureTheFlag_OnFlagTaken(int client)
{
	PrintToChatAll("%N took enemy's flag", client);
}