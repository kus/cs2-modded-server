#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo =
{
	name        = "BlockRadio",
	author      = "cra88y",
	description = "Blocks radio spam in chat",
	version     = "1.0"
};

public void OnPluginStart()
{
	if (GetUserMessageType() == UM_Protobuf)
	{
		HookUserMessage(GetUserMessageId("RadioText"), RadioMsg, true);
	}
}

public Action RadioMsg(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init)
{
	return Plugin_Handled;
}