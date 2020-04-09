#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "1.2.0"


public Plugin:myinfo = 
{
    name = "Command Time-Traveler",
    author = "DarthNinja",
    description = "Run commands in future... NOW!",
    version = PLUGIN_VERSION,
    url = "DarthNinja.com"
}

public OnPluginStart()
{
		RegAdminCmd("sm_future", CmdFuture, ADMFLAG_ROOT);
		CreateConVar("sm_futureexe_version", PLUGIN_VERSION, "Plugin Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
}

public Action:CmdFuture(client, args)
{
	if (args != 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_future <Time in minutes> \"Command +Args\"");
		return Plugin_Handled;	
	}
	decl String:Fcmd[255];
	decl String:time_S[25];
	GetCmdArg(1, time_S, sizeof(time_S));
	GetCmdArg(2, Fcmd, sizeof(Fcmd));
	ShowActivity2(client, "[SM] ","Executing \"%s\" in %s minutes", Fcmd, time_S);
	new Float:time_float;
	time_float = StringToFloat(time_S);
	new Float:time_float_minutes;
	time_float_minutes = time_float*60;
	
	decl String:name[255] = "CONSOLE";
	decl String:steamid[255] = "CONSOLE";
	LogAction(client, -1, "%L used Future-Execute to execute command %s in %s minutes.", client, Fcmd, time_S); //log
	//Fix quotes
	ReplaceString(Fcmd, sizeof(Fcmd), "'","\"")
	
	new Handle:pack
	CreateDataTimer(time_float_minutes, Timer_FUExec, pack)
	WritePackString(pack, name); //Client's name
	WritePackString(pack, steamid); //Client's steamid
	WritePackString(pack,Fcmd); //command + args
	WritePackString(pack,time_S); //time as string
	return Plugin_Handled;
}


public Action:Timer_FUExec(Handle:timer, Handle:pack)
{
	decl String:cmd[255]
	decl String:time[25]
	decl String:name[255]
	decl String:steamid[255]
	
	ResetPack(pack)
	ReadPackString(pack, name, sizeof(name))
	ReadPackString(pack, steamid, sizeof(steamid))
	ReadPackString(pack, cmd, sizeof(cmd))
	ReadPackString(pack, time, sizeof(time))
	
	LogAction(-1,-1,"\"%s\"(%s) used Future-Execute to execute command %s: Called %s minutes ago.", name, steamid, cmd, time); //log
	ServerCommand("%s", cmd)
	
	return Plugin_Stop;
}
