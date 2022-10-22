#pragma semicolon 1

#include <sourcemod>
#include <sdktools>


#define PLUGIN_NAME		 	"stuck"
#define PLUGIN_AUTHOR	   	"Erreur 500"
#define PLUGIN_DESCRIPTION	"Fix stuck players"
#define PLUGIN_VERSION	  	"1.3"
#define PLUGIN_CONTACT	  	"erreur500@hotmail.fr"

new TimeLimit;
new Counter[MAXPLAYERS+1] 		= {0, ...};
new StuckCheck[MAXPLAYERS+1] 	= {0, ...};
new Countdown[MAXPLAYERS+1] 	= {0, ...};

new bool:isStuck[MAXPLAYERS+1];

new Float:Step;
new Float:RadiusSize;
new Float:Ground_Velocity[3] = {0.0, 0.0, -300.0};

new Handle:c_Limit			= INVALID_HANDLE;
new Handle:c_Countdown 		= INVALID_HANDLE;
new Handle:c_Radius			= INVALID_HANDLE;
new Handle:c_Step 			= INVALID_HANDLE;


public Plugin:myinfo =
{
	name		= PLUGIN_NAME,
	author	  	= PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version	 	= PLUGIN_VERSION,
	url		 	= PLUGIN_CONTACT
};

public OnPluginStart()
{
	CreateConVar("stuck_version", PLUGIN_VERSION, "Stuck version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	c_Limit		= CreateConVar("stuck_limit", 				"7", 	"How many !stuck can a player use ? (0 = no limit)", FCVAR_PLUGIN, true, 0.0);
	c_Countdown	= CreateConVar("stuck_wait", 				"300", 	"Time to wait before earn new !stuck.", FCVAR_PLUGIN, true, 0.0);
	c_Radius	= CreateConVar("stuck_radius", 				"200", 	"Radius size to fix player position.", FCVAR_PLUGIN, true, 10.0);
	c_Step		= CreateConVar("stuck_step", 				"20", 	"Step between each position tested.", FCVAR_PLUGIN, true, 1.0);
	
	AutoExecConfig(true, "stuck");
	
	HookConVarChange(c_Countdown, CallBackCVarCountdown);
	HookConVarChange(c_Radius, CallBackCVarRadius);
	HookConVarChange(c_Step, CallBackCVarStep);
	
	TimeLimit = GetConVarInt(c_Countdown);
	if(TimeLimit < 0)
		TimeLimit = -TimeLimit;
		
	RadiusSize = GetConVarInt(c_Radius) * 1.0;
	if(RadiusSize < 10.0)
		RadiusSize = 10.0;
		
	Step = GetConVarInt(c_Step) * 1.0;
	if(Step < 1.0)
		Step = 1.0;
	
	RegConsoleCmd("stuck", StuckCmd, "Are you stuck ?");
	RegConsoleCmd("unstuck", StuckCmd, "Are you stuck ?");
	
	CreateTimer(1.0, Timer, INVALID_HANDLE, TIMER_REPEAT);
}

public OnMapStart() 
{
	for(new i=0; i<MaxClients; i++)
		Counter[i] = 0;
}

public CallBackCVarCountdown(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	TimeLimit = StringToInt(newVal);
	if(TimeLimit < 0)
		TimeLimit = -TimeLimit;
		
	LogMessage("stuck_wait = %i", TimeLimit);
}

public CallBackCVarRadius(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	RadiusSize = StringToInt(newVal) * 1.0;
	if(RadiusSize < 10.0)
		RadiusSize = 10.0;
	
	LogMessage("stuck_radius = %f", RadiusSize);
}

public CallBackCVarStep(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	Step = StringToInt(newVal) * 1.0;
	if(Step < 1.0)
		Step = 1.0;
		
	LogMessage("stuck_step = %f", Step);
}

stock bool:IsValidClient(iClient)
{
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	return IsClientInGame(iClient);
}

public Action:Timer(Handle:timer)
{
	for(new i=0; i<MaxClients; i++)
	{
		if(Counter[i] > 0)
		{
			Countdown[i]++;
			if(Countdown[i] >= TimeLimit)
			{
				Countdown[i] = 0;
				Counter[i]--;
			}
		}
		else if(Counter[i] == 0 && Countdown[i] != 0)
			Countdown[i] = 0;
	}
}

public Action:StuckCmd(iClient, Args)
{
	if(iClient <= 0) return;
	if(iClient > MaxClients) return;
	if(!IsPlayerAlive(iClient))
	{
		PrintToChat(iClient, "[!stuck] How a death can be stuck !?");
		return;
	}
	
	if(GetConVarInt(c_Limit) > 0 && Counter[iClient] >= GetConVarInt(c_Limit))
	{
		PrintToChat(iClient, "[!stuck] Sorry, you must wait %i seconds before use this command again.", TimeLimit - Countdown[iClient]);
		return;
	}
	
	Counter[iClient]++;
	StuckCheck[iClient] = 0;
	StartStuckDetection(iClient);
}

StartStuckDetection(iClient)
{
	StuckCheck[iClient]++;
	isStuck[iClient] = false;
	isStuck[iClient] = CheckIfPlayerIsStuck(iClient); // Check if player stuck in prop
	CheckIfPlayerCanMove(iClient, 0, 500.0, 0.0, 0.0);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//									Stuck Detection
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


stock bool:CheckIfPlayerIsStuck(iClient)
{
	decl Float:vecMin[3], Float:vecMax[3], Float:vecOrigin[3];
	
	GetClientMins(iClient, vecMin);
	GetClientMaxs(iClient, vecMax);
	GetClientAbsOrigin(iClient, vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_SOLID, TraceEntityFilterSolid);
	return TR_DidHit();	// head in wall ?
}


public bool:TraceEntityFilterSolid(entity, contentsMask) 
{
	return entity > 1;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//									More Stuck Detection
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


stock CheckIfPlayerCanMove(iClient, testID, Float:X=0.0, Float:Y=0.0, Float:Z=0.0)	// In few case there are issues with IsPlayerStuck() like clip
{
	decl Float:vecVelo[3];
	decl Float:vecOrigin[3];
	GetClientAbsOrigin(iClient, vecOrigin);
	
	vecVelo[0] = X;
	vecVelo[1] = Y;
	vecVelo[2] = Z;
	
	SetEntPropVector(iClient, Prop_Data, "m_vecBaseVelocity", vecVelo);
	
	new Handle:TimerDataPack;
	CreateDataTimer(0.1, TimerWait, TimerDataPack); 
	WritePackCell(TimerDataPack, iClient);
	WritePackCell(TimerDataPack, testID);
	WritePackFloat(TimerDataPack, vecOrigin[0]);
	WritePackFloat(TimerDataPack, vecOrigin[1]);
	WritePackFloat(TimerDataPack, vecOrigin[2]);
}

public Action:TimerWait(Handle:timer, Handle:data)
{	
	decl Float:vecOrigin[3];
	decl Float:vecOriginAfter[3];
	
	ResetPack(data, false);
	new iClient 		= ReadPackCell(data);
	new testID 			= ReadPackCell(data);
	vecOrigin[0]		= ReadPackFloat(data);
	vecOrigin[1]		= ReadPackFloat(data);
	vecOrigin[2]		= ReadPackFloat(data);
	
	
	GetClientAbsOrigin(iClient, vecOriginAfter);
	
	if(GetVectorDistance(vecOrigin, vecOriginAfter, false) < 10.0) // Can't move
	{
		if(testID == 0)
			CheckIfPlayerCanMove(iClient, 1, 0.0, 0.0, -500.0);	// Jump
		else if(testID == 1)
			CheckIfPlayerCanMove(iClient, 2, -500.0, 0.0, 0.0);
		else if(testID == 2)
			CheckIfPlayerCanMove(iClient, 3, 0.0, 500.0, 0.0);
		else if(testID == 3)
			CheckIfPlayerCanMove(iClient, 4, 0.0, -500.0, 0.0);
		else if(testID == 4)
			CheckIfPlayerCanMove(iClient, 5, 0.0, 0.0, 300.0);
		else
			FixPlayerPosition(iClient);
	}
	else
	{
		if(StuckCheck[iClient] < 2)
			PrintToChat(iClient, "[!stuck] Well Tried, but you are not stuck!");
		else
			PrintToChat(iClient, "[!stuck] Done!", StuckCheck[iClient]);
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//									Fix Position
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


FixPlayerPosition(iClient)
{
	if(isStuck[iClient]) // UnStuck player stuck in prop
	{
		new Float:pos_Z = 0.1;
		
		while(pos_Z <= RadiusSize && !TryFixPosition(iClient, 10.0, pos_Z))
		{	
			pos_Z = -pos_Z;
			if(pos_Z > 0.0)
				pos_Z += Step;
		}
		
		if(!CheckIfPlayerIsStuck(iClient) && StuckCheck[iClient] < 7) // If client was stuck => new check
			StartStuckDetection(iClient);
		else
			PrintToChat(iClient,"[!stuck] Sorry, I'm not able to fix your position.");
	
	}
	else // UnStuck player stuck in clip (invisible wall)
	{
		// if it is a clip on the sky, it will try to find the ground !
		new Handle:trace = INVALID_HANDLE;
		decl Float:vecOrigin[3];
		decl Float:vecAngle[3];
		
		GetClientAbsOrigin(iClient, vecOrigin);
		vecAngle[0] = 90.0;
		trace = TR_TraceRayFilterEx(vecOrigin, vecAngle, MASK_SOLID, RayType_Infinite, TraceEntityFilterSolid);		
		if(!TR_DidHit(trace)) 
		{
			CloseHandle(trace);
			return;
		}
		
		TR_GetEndPosition(vecOrigin, trace);
		CloseHandle(trace);
		vecOrigin[2] += 10.0;
		TeleportEntity(iClient, vecOrigin, NULL_VECTOR, Ground_Velocity);
		
		if(StuckCheck[iClient] < 7) // If client was stuck in invisible wall => new check
			StartStuckDetection(iClient);
		else
			PrintToChat(iClient,"[!stuck] Sorry, I'm not able to fix your position.");
	}
}

bool:TryFixPosition(iClient, Float:Radius, Float:pos_Z)
{
	decl Float:DegreeAngle;
	decl Float:vecPosition[3];
	decl Float:vecOrigin[3];
	decl Float:vecAngle[3];
	
	GetClientAbsOrigin(iClient, vecOrigin);
	GetClientEyeAngles(iClient, vecAngle);
	vecPosition[2] = vecOrigin[2] + pos_Z;

	DegreeAngle = -180.0;
	while(DegreeAngle < 180.0)
	{
		vecPosition[0] = vecOrigin[0] + Radius * Cosine(DegreeAngle * FLOAT_PI / 180); // convert angle in radian
		vecPosition[1] = vecOrigin[1] + Radius * Sine(DegreeAngle * FLOAT_PI / 180);
		
		TeleportEntity(iClient, vecPosition, vecAngle, Ground_Velocity);
		if(!CheckIfPlayerIsStuck(iClient))
			return true;
		
		DegreeAngle += 10.0; // + 10°
	}
	
	TeleportEntity(iClient, vecOrigin, vecAngle, Ground_Velocity);
	if(Radius <= RadiusSize)
		return TryFixPosition(iClient, Radius + Step, pos_Z);
	
	return false;
}



