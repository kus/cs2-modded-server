float NO_VELOCITY[3] = {0.0, 0.0, 0.0};

bool Client_IsFreezed(int iClient)
{
	return g_bClientIsFrozen[iClient];
}

void Client_ToggleFreeze(int iClient)
{
	if (Client_IsFreezed(iClient))
	{
		if(Client_SetFreezed(iClient, false))
			CPrintToChat(iClient, "%s %t", PREFIX, "You're able to move again.");
	} 
	else if(Client_SetFreezed(iClient, true))
		CPrintToChat(iClient, "%s %t", PREFIX, "Youre now frozen");
}

bool Client_SetFreezed(int iClient, bool freeze)
{
	if(freeze)
	{
		// Forward
		Action result;
		Call_StartForward(g_OnHiderFreeze);
		Call_PushCell(iClient);
		Call_Finish(result);
		
		// Aborted by forward result
		
		if(result == Plugin_Stop || result == Plugin_Handled)
			return false;
		
		float fVel[3];
		GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", fVel);
		if(fVel[2] != 0.0) // The following checks are only needed when the player is on a solid surface
		{
			// Fallspeed
			if(fVel[2] < g_cvHiderFreezeFallspeedMax.FloatValue)
			{
				CPrintToChat(iClient, "%s %t", PREFIX, "You can't freeze while falling 2 fast");
				return false;
			}
			
			// Don't allow freezing high above the ground or above water
			float fHeight = GetHeightAboveGround(iClient);
			float fHeightWater = GetHeightAboveWater(iClient);
			
			// Check if the water surface distance is smaller as ground distance
			if(!g_cvHiderFreezeAboveWater.BoolValue && fHeightWater < fHeight)
			{
				CPrintToChat(iClient, "%s %t", PREFIX, "You can't freeze above water.");
				return false;
			}
			
			// Check height above ground
			if((g_bUpgradeFreezeAir[iClient] && fHeight > g_cvShopHiderAirFreezeHeight.FloatValue) || (!g_bUpgradeFreezeAir[iClient] && fHeight > g_cvHiderFreezeHeightMax.FloatValue))
			{
				CPrintToChat(iClient, "%s %t", PREFIX, "You can't freeze that high above ground");
				return false;
			}
		}
	}
	
	// Freeze player
	if (!Client_IsFreezed(iClient) && freeze && !g_bBlockFakeProp[iClient])
	{
		if(!Client_HasFakeProp(iClient))
			return false;
		
		SetEntityMoveType(iClient, MOVETYPE_NONE);
		
		TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, NO_VELOCITY);
		g_bClientIsFrozen[iClient] = true;
		
		// Detach fake prop and correct it's position
		if(Client_HasFakeProp(iClient))
		{
			Client_DetachFakeProp(iClient);
			Entity_TeleportToFix(Client_GetFakeProp(iClient), iClient, true);
		}
		
		delete g_hAutoFreezeTimers[iClient];
		
		return true;
	} 
	
	// Unfreeze player
	if (!freeze && Client_IsFreezed(iClient))
	{
		if(!Client_HasFakeProp(iClient))
			return false;
		
		Call_StartForward(g_OnHiderUnFreeze);
		Call_PushCell(iClient);
		Call_Finish();
		
		SetEntityMoveType(iClient, MOVETYPE_WALK);
		
		g_bClientIsFrozen[iClient] = false;
		
		// Detach fake prop and correct it's position
		Entity_TeleportToFix(Client_GetFakeProp(iClient), iClient, true);
		Client_AttachFakeProp(iClient);
		
		delete g_hAutoFreezeTimers[iClient];
		
		return true;
	}
	
	return false;
}