void Client_ResetFakeProp(int iClient)
{
	Client_RemoveFakeProp(iClient);
	Client_SetFreezed(iClient, false);
}

void Client_UpdateFakeProp(int iClient)
{
	// Clean up fake props for dead players
	if (GetClientTeam(iClient) != CS_TEAM_T || !IsPlayerAlive(iClient))
	{
		if (g_bShowFakeProp[iClient])
			g_bShowFakeProp[iClient] = false;
		
		if (Client_HasFakeProp(iClient) || Client_IsFreezed(iClient))
			Client_ResetFakeProp(iClient);
		
		return;
	}
	
	// No fake prop exist? Create a new one
	if (!Client_HasFakeProp(iClient))
	{
		if (g_bShowFakeProp[iClient])
			g_bShowFakeProp[iClient] = false;
		
		Client_ReCreateFakeProp(iClient);
	}
}

void Client_ReCreateFakeProp(int iClient)
{
	static int iFreeze = -1;
	
	if(iFreeze == -1)
		iFreeze = FindSendPropInfo("CBasePlayer", "m_fFlags");
	
	Client_RemoveFakeProp(iClient);
	
	if(g_bBlockFakeProp[iClient])
		return;
	
	//Create Fake Model
	int iEntity = CreateEntityByName("prop_physics_override");
	
	if (IsValidEntity(iEntity))
	{
		DispatchKeyValue(iEntity, "physdamagescale", "0.0");
		DispatchKeyValue(iEntity, "model", m_sModel[iClient]);
		
		SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", iClient);
		SetEntProp(iEntity, Prop_Data, "m_CollisionGroup", 1);
		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags", 12);
		SetEntProp(iEntity, Prop_Send, "m_nSolidType", 6);
		DispatchSpawn(iEntity);
		SetEntData(iEntity, iFreeze, FL_CLIENT | FL_ATCONTROLS, 4, true);
		SetEntityMoveType(iEntity, MOVETYPE_NONE);
		SetEntPropEnt(iEntity, Prop_Data, "m_hLastAttacker", iClient);
		
		SetEntProp(iEntity, Prop_Send, "m_nSkin", m_iSkin[iClient]);
		
		FX_Render(iEntity, view_as<FX>(FxDistort), m_iColor[iClient][0], m_iColor[iClient][1], m_iColor[iClient][2], view_as<Render>(RENDER_TRANSADD), m_iColor[iClient][3]);
		
		Client_SetFakeProp(iClient, iEntity);
		
		SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_EVENTS_ONLY, 1);
		SDKHook(iEntity, SDKHook_OnTakeDamage, Hook_OnDamageFakeProp);
	} 
	else Client_RemoveFakeProp(iClient);
}

bool Client_HasFakeProp(int iClient)
{
	int child = g_iClientFakeProps[iClient];
	return child != 0 && IsValidEntity(child);
}

int Client_GetFakeProp(int iClient)
{
	return g_iClientFakeProps[iClient];
}

void Client_SetFakeProp(int iClient, int child)
{
	if(g_bBlockFakeProp[iClient])
		return;
	
	if (Client_HasFakeProp(iClient) && child != g_iClientFakeProps[iClient])
		Client_RemoveFakeProp(iClient);
	
	g_iClientFakeProps[iClient] = child;
	
	if(Client_IsFreezed(iClient))
		Client_UpdateFakePropAngle(iClient);
	else Client_AttachFakeProp(iClient);
 }

void Client_RemoveFakeProp(int iClient)
{
	if (g_iClientFakeProps[iClient] != 0)
	{
		Client_DetachFakeProp(iClient);
		if (Client_HasFakeProp(iClient))
			AcceptEntityInput(Client_GetFakeProp(iClient), "kill");
		
		g_iClientFakeProps[iClient] = 0;
	}
}

void Client_AttachFakeProp(int iClient)
{
	if(g_bBlockFakeProp[iClient])
		return;
	
	if (Client_HasFakeProp(iClient))
	{
		int child = Client_GetFakeProp(iClient);
		Entity_TeleportToFix(child, iClient, true);
		
		SetVariantString("!activator");
		AcceptEntityInput(child, "SetParent", iClient, child, 0);
	}
}

void Client_DetachFakeProp(int iClient)
{
	if(g_bBlockFakeProp[iClient])
		return;
	
	if (Client_HasFakeProp(iClient))
	{
		SetVariantString("");
		AcceptEntityInput(Client_GetFakeProp(iClient), "ClearParent");
	}
}

void Client_UpdateFakePropAngle(int iClient)
{
	if(g_bBlockFakeProp[iClient])
		return;
	
	if (Client_HasFakeProp(iClient))
	{
		int child = Client_GetFakeProp(iClient);
		Entity_TeleportToFix(child, iClient, true);
	}
}

void Entity_TeleportToFix(int iEntity, int iClient, bool eyeangles)
{
	float fPos[3];
	GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", fPos);
	
	if(eyeangles) // Situation based use Eye or Abs angles
		GetClientEyeAngles(iClient, m_fFreezeAngle[iClient]);
	else GetClientAbsAngles(iClient, m_fFreezeAngle[iClient]);
	
	m_fFreezeAngle[iClient][0] = 0.0; //no x-axis rotation
	m_fFreezeAngle[iClient][2] = 0.0; //no z-axis rotation
	
	MoveRelative(fPos, m_fFreezeAngle[iClient], m_fOffset[iClient][0], fPos); // X
	
	m_fFreezeAngle[iClient][1] += 90.0;
	MoveRelative(fPos, m_fFreezeAngle[iClient], m_fOffset[iClient][1], fPos); // Y
	m_fFreezeAngle[iClient][1] -= 90.0;
	
	fPos[2] += m_fOffset[iClient][2]; // Z
	
	FixFreezeAngle(iClient);
	
	TeleportEntity(iEntity, fPos, m_fFreezeAngle[iClient], NULL_VECTOR);
}

void FixFreezeAngle(int iClient)
{
	for (int i = 0; i < 3; i++)
	{
		m_fFreezeAngle[iClient][i] += m_fAngle[iClient][i];
		
		while(m_fFreezeAngle[iClient][i] > 180.0)
			m_fFreezeAngle[iClient][i] -= 360.0;
			
		while(m_fFreezeAngle[iClient][i] < -180.0)
			m_fFreezeAngle[iClient][i] += 360.0;
	}
}