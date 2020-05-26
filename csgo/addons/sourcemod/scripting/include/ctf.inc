/*
**
*/
#if defined _INCLUDE_included
 #endinput
#endif
#define _INCLUDE_included

#define 	FLAGMODEL	"models/mapmodels/flags.mdl"
#define 	FLAGTYPE_AIM 	1
#define 	FLAGTYPE_UNDERBODY 2
#define		FLAGTYPE_SPAWN 3
#define 	FLAGTYPE_ABOVE 4


/**
* Removes (kills) a flag
*
* @param int				Which teams flag to remove
* @param bool				Remove pole with the flag
*/
stock RemoveFlag(int team, bool RemovePole)
{
	int ent = GetTeamFlag(team);
	
	if(ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
		
	SetTeamFlag(team, -1);
		
	if(RemovePole)
	{
		int pole = GetTeamPole(team);
		if(pole > 0 && IsValidEntity(pole))
			AcceptEntityInput(pole, "Kill");
			
		SetTeamPole(team, -1);
	}
}


/**
* Spawns a flag with your settings
*
* @param int				Which teams flag you want to spawn
* @param int				Flag spawn type (1. Client aim, 2. Under client body, 3. To flag spawn, 4.Above player) /FLAGTYPE_.../
* @param bool				Spawn pole [true/false]
* @param int				Important if 2nd or 3rd selected (aim pos)
* @return					returns flag entity ID
*/
stock SpawnFlag(int team, int type, bool spawnPole, int client)
{
	//Delete old flag
	RemoveFlag(team, true);
	//DeteleOldTeamFlag(team);
	
	float pos[3];
	//DeleteOldFlag(team);
	
	if(type == FLAGTYPE_AIM)
	{
	
		float clientEye[3], clientAngle[3];
		GetClientEyePosition(client, clientEye);
		GetClientEyeAngles(client, clientAngle);
		
		TR_TraceRayFilter(clientEye, clientAngle, MASK_SOLID, RayType_Infinite, HitSelf, client);
		if (TR_DidHit(INVALID_HANDLE))
			TR_GetEndPosition(pos);
		
	} else if(type == FLAGTYPE_UNDERBODY) {
		GetGroundOrg(client, pos);
		
		//---
		Call_StartForward(g_OnFlagDropped);
		Call_PushCell(client);
		Call_Finish();
		//---
		
	} else if(type == FLAGTYPE_SPAWN) {
		
		//Getting model path
		KeyValues kvModelPath = CreateKeyValues("Flags");

		
		kvModelPath.ImportFromFile(g_CTFconfig);
		char mapname[120];
		GetCurrentMap(mapname, sizeof(mapname));
		kvModelPath.JumpToKey(mapname);
		
		if(team == CS_TEAM_T)
		{
			pos[0] = kvModelPath.GetFloat("T-posx");
			pos[1] = kvModelPath.GetFloat("T-posz");
			pos[2] = kvModelPath.GetFloat("T-posy");

			f_TflagSpawnPos[0] = pos[0];
			f_TflagSpawnPos[1] = pos[1];
			f_TflagSpawnPos[2] = pos[2];
		}
		
		if(team == CS_TEAM_CT)
		{
			pos[0] = kvModelPath.GetFloat("CT-posx");
			pos[1] = kvModelPath.GetFloat("CT-posz");
			pos[2] = kvModelPath.GetFloat("CT-posy");
			
			f_CTflagSpawnPos[0] = pos[0];
			f_CTflagSpawnPos[1] = pos[1];
			f_CTflagSpawnPos[2] = pos[2];
		}
		
	} else if(type == FLAGTYPE_ABOVE) {
	
		GetClientAbsOrigin(client, pos);
		pos[2] += 20;
		
	}
	
	int ent = CreateEntityByName("prop_dynamic");
	SetEntityModel(ent, FLAGMODEL);
	
	SetEntProp(ent, Prop_Send, "m_clrRender", -1);
	if (team == CS_TEAM_T)
	{
		SetEntProp(ent, Prop_Send, "m_nBody", 3);
	} else if (team == CS_TEAM_CT) {
		SetEntProp(ent, Prop_Send, "m_nBody", 0);
	}
	DispatchSpawn(ent);
	SetVariantString("flag_idle1");
	AcceptEntityInput(ent, "SetAnimation");
	AcceptEntityInput(ent, "TurnOn");
	
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	SetTeamFlag(team, ent);
	
	
	if(type == FLAGTYPE_ABOVE)
	{		
		//Parent to player
		char sBuffer[120];
		Format(sBuffer, sizeof(sBuffer), "sctf_%N_flag_carrier", client);
		DispatchKeyValue(ent, "targetname", sBuffer);
		
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", client);	

		b_FlagCarrier[client] = true;
		
		//---
		Call_StartForward(g_OnFlagTaken);
		Call_PushCell(client);
		Call_Finish();
		//---

	}
	
	if(spawnPole)
	{
		
		int ent2 = CreateEntityByName("prop_dynamic"); 
		SetEntityModel(ent2, POLEMODEL);
		SetTeamPole(team, ent2);
		SetEntProp(ent2, Prop_Send, "m_usSolidFlags", 12);
		SetEntProp(ent2, Prop_Data, "m_nSolidType", 6);
		SetEntProp(ent2, Prop_Send, "m_CollisionGroup", 1);
		SDKHook(ent2, SDKHook_StartTouch, 	OnStartTouch);
		SDKHook(ent2, SDKHook_EndTouch, 	OnEndTouch);
		pos[2] += 40;
		TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);  	
		
	}
	
	return ent;
	
}


/**
* Checks which player carries the flag
*
* @param int				Team to which flag to check
* @return					client or -1
*/
stock GetFlagCarrier(int team)
{
	
	int client = -1;

	LoopAllPlayers(i)
		if(GetClientTeam(i) == team && b_FlagCarrier[i])
			client = i;
			
	return client;
}

stock IsFlagInSpawn(int team)
{
	
	int ent = GetTeamFlag(team);
	
	float org[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", org);
	
	if(team == CS_TEAM_T)
	{
		if(org[0] == f_TflagSpawnPos[0] && org[1] == f_TflagSpawnPos[1] && org[2] == f_TflagSpawnPos[2])
			return true;
		else
			return false;
	} else if(team == CS_TEAM_CT)
	{
		if(org[0] == f_CTflagSpawnPos[0] && org[1] == f_CTflagSpawnPos[1] && org[2] == f_CTflagSpawnPos[2])
			return true;
		else
			return false;
	}	
	
	return false;
	
}


public bool HitSelf(int entity, int contentsMask, any data)
{
	if (entity == data)
	{
		return false;
	}
	return true;
}

bool GetGroundOrg(int client, float pos[3])
{
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client,vOrigin);
	vAngles[0] = 90.0;
	vAngles[1] = 0.0;
	vAngles[2] = 0.0;
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer2);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

public bool TraceEntityFilterPlayer2(int entity, int contentsMask)
{
    return entity > GetMaxClients();
}

