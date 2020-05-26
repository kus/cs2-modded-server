public void MoveModels_OnClietPutInServer(int client)
{
	g_bCanMoveModels[client] = false;
}

public void MoveModels_OnPluginStart()
{
	LoopAllPlayers(i)
	{
		g_bCanMoveModels[i] = false;
	}
}

public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVelocity[3], float fAngles[3], int &iWeapon) 
{

	if(IsClientInGame(client) && IsAdmin(client))
	{
		if(g_bCanMoveModels[client])
		{
			// ** 	FIRST CLICK (RUNS ONCE) 	**//
			if(!(g_iPlayerPrevButtons[client] & IN_USE) && iButtons & IN_USE)
				FirstTimePress(client);
				
			//** 	SECOND CLICK (RUNS ALL TIME) 	**//
			else if (iButtons & IN_USE)
				StillPressingButton(client, iButtons);
				
			//** 	LAST CLICK (RUNS ONCE) 	**//
			else if(g_OnceStopped[client])
				StoppedMovingBlock(client);
				
			//** 	BLOCK ROTATE 	**//	
			if(iButtons & IN_RELOAD && !(g_iPlayerPrevButtons[client] & IN_RELOAD))
			{
				RotateBlock(g_iPlayerNewEntity[client], 10.0);
			}
			
			g_iPlayerPrevButtons[client] = iButtons;
		}
	}
	
}


public void FirstTimePress(int client)
{

	g_iPlayerSelectedBlock[client] = GetTargetBlock(client);
	
	if(IsValidEntity(g_iPlayerSelectedBlock[client]) && g_iPlayerSelectedBlock[client] != -1) 
	{
		
		g_OnceStopped[client] = true;
		
		if(!IsValidEntity(g_iPlayerNewEntity[client]) || g_iPlayerNewEntity[client] <= 0)
			g_iPlayerNewEntity[client] = CreateEntityByName("prop_dynamic");
		
		float TeleportNewEntityOrg[3];
		GetAimOrigin(client, TeleportNewEntityOrg);
		TeleportEntity(g_iPlayerNewEntity[client], TeleportNewEntityOrg, NULL_VECTOR, NULL_VECTOR);
		
		SetVariantString("!activator");
		AcceptEntityInput(g_iPlayerSelectedBlock[client], "SetParent", g_iPlayerNewEntity[client], g_iPlayerSelectedBlock[client], 0);
		
		float posent[3];
		float playerpos[3];
		GetClientEyePosition(client, playerpos);
		GetEntPropVector(g_iPlayerNewEntity[client], Prop_Send, "m_vecOrigin", posent);
		g_fPlayerSelectedBlockDistance[client] =  GetVectorDistance(playerpos, posent);
		
	}

}

void StillPressingButton(int client, int &iButtons)
{
	if (iButtons & IN_ATTACK)
		g_fPlayerSelectedBlockDistance[client] += 1.0;
					
	else if (iButtons & IN_ATTACK2)
		g_fPlayerSelectedBlockDistance[client] -= 1.0;
		
	MoveBlock(client);
}


void MoveBlock(int client)
{
	if (IsValidEntity(g_iPlayerSelectedBlock[client]) && IsValidEntity(g_iPlayerNewEntity[client])) {
		
		float posent[3];
		GetEntPropVector(g_iPlayerNewEntity[client], Prop_Send, "m_vecOrigin", posent);
		
		float playerpos[3];
		GetClientEyePosition(client, playerpos);

		float playerangle[3];
		GetClientEyeAngles(client, playerangle);
		
		float final[3];
		AddInFrontOf(playerpos, playerangle, g_fPlayerSelectedBlockDistance[client], final);
		
		TeleportEntity(g_iPlayerNewEntity[client], final, NULL_VECTOR, NULL_VECTOR);
	
	}
}


public void StoppedMovingBlock(int client)
{
	
	if(IsValidEntity(g_iPlayerSelectedBlock[client])) {
		
		SetVariantString("!activator");
		AcceptEntityInput(g_iPlayerSelectedBlock[client], "SetParent", g_iPlayerSelectedBlock[client], g_iPlayerSelectedBlock[client], 0);
	}
	
	g_OnceStopped[client] = false;

}

int GetTargetBlock(int client)
{
	int entity = GetClientAimTarget(client, false);
	if (IsValidEntity(entity))
	{
		char classname[32];
		GetEdictClassname(entity, classname, 32);
		
		if (StrContains(classname, "prop_dynamic") != -1)
			return entity;
	}
	return -1;
}

stock int GetAimOrigin(int client, float hOrigin[3]) 
{
    float vAngles[3];
    float fOrigin[3];
    GetClientEyePosition(client,fOrigin);
    GetClientEyeAngles(client, vAngles);

    Handle trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(hOrigin, trace);
        CloseHandle(trace);
        return 1;
    }

    CloseHandle(trace);
    return 0;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask) 
{
    return entity > GetMaxClients();
}

stock void AddInFrontOf(float vecOrigin[3], float vecAngle[3], float units, float output[3])
{
	float vecAngVectors[3];
	vecAngVectors = vecAngle; //Don't change input
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	for (int i; i < 3; i++)
	output[i] = vecOrigin[i] + (vecAngVectors[i] * units);
}


void RotateBlock(int entity, float rotatesize)
{
	if (IsValidEntity(entity))
	{
		float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		angles[0] += 0.0;
		angles[1] += rotatesize;
		angles[2] += 0.0;
		TeleportEntity(entity, NULL_VECTOR, angles, NULL_VECTOR);
	}
}