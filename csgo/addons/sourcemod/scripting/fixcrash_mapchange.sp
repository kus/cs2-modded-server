#pragma semicolon 1
#pragma newdecls required

#include <sourcemod> 

public Plugin myinfo =
{
	name = "Reconnect Players",
	author = "Ilusion9",
	description = "Reconnect players on map change.",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

char g_ChangeLevelArgs[PLATFORM_MAX_PATH];

public void OnPluginStart()
{
	AddCommandListener(CommandListener_Map, "map");
	AddCommandListener(CommandListener_ChangeLevel, "changelevel");
}

public void OnMapStart()
{
	g_ChangeLevelArgs[0] = 0;
}

public Action CommandListener_Map(int client, const char[] command, int args)
{
	if (client)
	{
		return Plugin_Continue;
	}
	
	if (g_ChangeLevelArgs[0])
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action CommandListener_ChangeLevel(int client, const char[] command, int args)
{
	if (client)
	{
		return Plugin_Continue;
	}
	
	char arguments[PLATFORM_MAX_PATH];
	GetCmdArgString(arguments, sizeof(arguments));
	
	if (g_ChangeLevelArgs[0])
	{
		if (StrEqual(arguments, g_ChangeLevelArgs, true))
		{
			return Plugin_Continue;
		}
		
		return Plugin_Handled;
	}
	
	strcopy(g_ChangeLevelArgs, sizeof(g_ChangeLevelArgs), arguments);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
		{
			continue;
		}
		
		ClientCommand(i, "disconnect;retry");
	}
	
	DataPack pk;
	CreateDataTimer(0.2, Timer_ForceChangeLevel, pk, TIMER_FLAG_NO_MAPCHANGE);
	
	pk.WriteString(command);
	pk.WriteString(arguments);
	
	return Plugin_Handled;
}

public Action Timer_ForceChangeLevel(Handle timer, DataPack pk)
{
	pk.Reset();
	
	char command[256];
	pk.ReadString(command, sizeof(command));
	
	char arguments[PLATFORM_MAX_PATH];
	pk.ReadString(arguments, sizeof(arguments));
	
	ServerCommand("%s %s", command, arguments);
}
