public void OnClientPutInServer(int iClient)
{
	// Hook weapon pickup
	SDKHook(iClient, SDKHook_WeaponCanUse, Hook_OnWeaponCanUse);
	SDKHook(iClient, SDKHook_WeaponCanSwitchTo, Hook_OnWeaponCanUse);
	SDKHook(iClient, SDKHook_WeaponEquip, Hook_OnWeaponCanUse);
	SDKHook(iClient, SDKHook_WeaponSwitch, Hook_OnWeaponCanUse);
	
	// Give health back before weapon_fire event was called
	SDKHook(iClient, SDKHook_TraceAttack, Hook_OnTraceAttack); 
	SDKHook(iClient, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public void OnClientCookiesCached(int iClient)
{
	char sBuffer[8];
	GetClientCookie(iClient, g_hCookieTauntPack, sBuffer, sizeof(sBuffer));
	g_iTauntPack[iClient] = StringToInt(sBuffer);
	
	GetClientCookie(iClient, g_hCookieHudMode, sBuffer, sizeof(sBuffer));
	if(!StrEqual(sBuffer, ""))
		g_iHudMode[iClient] = StringToInt(sBuffer);
	else g_iHudMode[iClient] = HUD_HELP;
}

public void OnClientDisconnect(int iClient)
{
	// set the default values for cvar checking
	g_bInThirdPersonView[iClient] = false;
	g_iModelChangeCount[iClient] = 0;
	g_iSpawnTime[iClient] = 0;
	g_bSeeker[iClient] = false;
	
	delete g_hAutoFreezeTimers[iClient];
	
	g_bFirstSpawn[iClient] = true;
	g_iLowModelSteps[iClient] = 0;
	
	// AFK check
	for (int i = 0; i < 3; i++)
		g_fSpawnPosition[iClient][i] = 0.0;
	
	Client_RemoveFakeProp(iClient);
	
	CreateTimer(1.0, Timer_CheckRestart, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &impulse, float vel[3], float angles[3], int &iWeapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(!Ready())
		return Plugin_Continue;
	
	static int iOldButtons[MAXPLAYERS + 1];
	
	//Freeze and rotation fix
	Client_UpdateFakeProp(iClient);
	
	if(!IsPlayerAlive(iClient))
		return Plugin_Continue;
	
	if (GetClientTeam(iClient) == CS_TEAM_T)
	{
		if(!(iOldButtons[iClient] & IN_ATTACK) && (iButtons & IN_ATTACK))
			PlayTaunt(iClient); // Taunt
		if(!(iOldButtons[iClient] & IN_ATTACK2) && (iButtons & IN_ATTACK2))
			Menu_Shop(iClient); // Open shop
		
		// Remove clientside foot shadows, still visible when landing (iClient prediction I guess)
		// This also removes footsteps
		int flags = GetEntityFlags(iClient);
		if(!PH_IsFakePropBlocked(iClient))
			SetEntityFlags(iClient, flags & ~FL_ONGROUND);
		
		bool autofreeze = g_hAutoFreezeTimers[iClient] != null;
		
		bool moving = iButtons & IN_FORWARD || iButtons & IN_BACK || iButtons & IN_MOVELEFT || iButtons & IN_MOVERIGHT || iButtons & IN_JUMP;
		
		float vecVelocity[3];
		vecVelocity[0] = GetEntPropFloat(iClient, Prop_Send, "m_vecVelocity[0]");
		vecVelocity[1] = GetEntPropFloat(iClient, Prop_Send, "m_vecVelocity[1]");
		vecVelocity[2] = GetEntPropFloat(iClient, Prop_Send, "m_vecVelocity[2]");
		
		bool movement = (vecVelocity[0] != 0.0 || vecVelocity[1] != 0.0 || vecVelocity[2] != 0.0);
		
		// Unfreeze hider, he pressed a button and was frozen
		if (Client_IsFreezed(iClient) && moving)
			Cmd_Freeze(iClient, 0);
		
		// Abort autofreeze, hider was moving or pressed a button
		if ((movement || moving) && g_hAutoFreezeTimers[iClient] != null)
			delete g_hAutoFreezeTimers[iClient];
		
		// Hider was not moving and didn't press a button
		if (!movement && !moving)
		{
			// Start auto freeze
			if (g_cvAutoFreezeTime.FloatValue > 0.0 && !Client_IsFreezed(iClient) && g_hAutoFreezeTimers[iClient] == null)
			{
				Client_DetachFakeProp(iClient);
				g_hAutoFreezeTimers[iClient] = CreateTimer(g_cvAutoFreezeTime.FloatValue, Timer_AutoFreezeClient, iClient, TIMER_FLAG_NO_MAPCHANGE);
			}
			
			// Autofreeze is active, lets update the rotation of our fake prop
			if (g_hAutoFreezeTimers[iClient] != null)
				Client_UpdateFakePropAngle(iClient);
		}
		
		// Autofreeze timer got cancelled by movement
		if(autofreeze && g_hAutoFreezeTimers[iClient] == null)
			Client_AttachFakeProp(iClient);
	}
	else if (GetClientTeam(iClient) == CS_TEAM_CT)
	{
		if(iWeapon <= 0)
			iWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		
		// Don't allow shooting in the beginning of the round
		if (Seeker_IsBlinded(iClient))
			BlockWeapon(iClient, iWeapon, true, true, 1.0);
		// Don't allow secondary knife attack, but play taunt sound
		else if(g_iWeapontype[iClient] == WEAPONTYPE_KNIFE)
		{
			BlockWeapon(iClient, iWeapon, false, true);
			
			if(g_cvTauntForce.BoolValue && !(iOldButtons[iClient] & IN_ATTACK2) && (iButtons & IN_ATTACK2))
				PlayTaunt(iClient); // Force Taunt
			if(iButtons & IN_ATTACK2)
				Menu_Shop(iClient); // Open shop
		}
	}
	
	iOldButtons[iClient] = iButtons;
	
	return Plugin_Continue;
}

public Action Hook_OnWeaponCanUse(int iClient, int iWeapon)
{
	if(!Ready())
		return Plugin_Continue;
	
	StartCleanupTimer(); // Init weapon cleaner
	
	if(!IsClientInGame(iClient))
		return Plugin_Continue;
	
	// Seeker can use all weapons
	if(GetClientTeam(iClient) == CS_TEAM_CT)
		return Plugin_Continue;
	
	if(GetClientTeam(iClient) == CS_TEAM_T)
	{
		if(g_bBlockFakeProp[iClient])
		{
			char sWeapon[256];
			GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));
			
			if (StrContains(sWeapon, "knife") != -1 || StrContains(sWeapon, "taser") != -1 || StrContains(sWeapon, "bayonet") != -1)
				return Plugin_Continue;
		}
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

// Block weapon drop for seeker
public Action Hook_OnWeaponDrop(int iClient, const char[] command, int argc)
{
	if(!Ready())
		return Plugin_Continue;
	
	if(iClient < 1 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return Plugin_Continue;
	
	if(GetClientTeam(iClient) == CS_TEAM_CT)
	{
		switch(g_iWeapontype[iClient])
		{
			case WEAPONTYPE_GRENADE: return Plugin_Handled;
			case WEAPONTYPE_KNIFE: return Plugin_Handled;
			case WEAPONTYPE_TASER: return Plugin_Handled;
			case WEAPONTYPE_HEALTHSHOT: return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action Event_OnWeaponFire(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	int iWeapon = Client_GetActiveWeapon(iClient);
	Client_SeekerFiredWeapon(iClient, iWeapon);
	
	// Infinite ammo
	if(g_cvInfAmmo.BoolValue && WEAPONTYPE_PISTOL <= g_iWeapontype[iClient] <= WEAPONTYPE_MACHINEGUN)
	{
		if(IsValidEdict(iWeapon))
			Weapon_AddReserveAmmo(iWeapon, 1);
	}
	
	return Plugin_Continue;
}

public Action Event_ItemEquip(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	int iType = GetEventInt(event, "weptype");
	g_iWeapontype[iClient] = iType; // Store weapon type for weapon type detection
	
	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	int team = GetClientTeam(iClient);
	
	if (team <= CS_TEAM_SPECTATOR || !IsPlayerAlive(iClient))
		return Plugin_Continue;
	
	g_bInThirdPersonView[iClient] = false;
	g_bBlockFakeProp[iClient] = false;
	g_iSpawnTime[iClient] = GetTime();
	g_bIsPlayerDead[iClient] = false;
	
	g_iTauntNextUse[iClient] = 0;
	g_iTauntNextTry[iClient] = 0;
	g_iTauntCooldownLength[iClient] = 0;
	
	// Save time first T spawned
	if (g_iRoundStart == 0)
	{
		g_iRoundStart = GetTime();
		g_hAfterFreezeTimer = CreateTimer(g_cvHideTime.FloatValue, Timer_AfterFreezeTime);
	}
	
	ResetShopItems(iClient);
	
	if (team == CS_TEAM_CT)
		HandleCTSpawn(iClient);
	else HandleTSpawn(iClient);
	
	CreateTimer(0.0, Timer_RemoveClientRadar, iClient, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.5, Timer_SaveClientSpawnPosition, iClient, TIMER_FLAG_NO_MAPCHANGE); // When players spawn inside each other they are pushed away frome each other, so we get the position with a bit delay
	
	StartCheckTeamsTimer();
	
	return Plugin_Continue;
}

public Action Event_OnPlayerDeath_Pre(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!ClientIsValid(iClient))
		return Plugin_Continue;
	
	int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	Client_SetFreezed(iClient, false);
	Seeker_Blind(iClient, true, false);
	delete g_hAutoFreezeTimers[iClient];
	
	if(GetClientTeam(iClient) == CS_TEAM_T)
	{
		Call_StartForward(g_OnHiderDeath);
		Call_PushCell(iClient);
		Call_PushCell(iAttacker);
		Call_Finish();
	}
	else if(GetClientTeam(iClient) == CS_TEAM_CT)
	{
		Call_StartForward(g_OnSeekerDeath);
		Call_PushCell(iClient);
		Call_PushCell(iAttacker);
		Call_Finish();
	}
	
	return Plugin_Continue;
}

public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	SetThirdPersonView(iClient, false);
	RequestFrame(MovetoCT, GetClientUserId(iClient));
	
	// Remove ragdoll
	int iRagdoll = GetEntPropEnt(iClient, Prop_Send, "m_hRagdoll");
	if (iRagdoll < 0)
		return Plugin_Continue;
	
	RemoveEdict(iRagdoll);
	
	return Plugin_Continue;
}

public Action Timer_RemoveClientRadar(Handle timer, int iClient)
{
	if(!Ready())
		return Plugin_Continue;
	
	if (!IsClientInGame(iClient))
		return Plugin_Stop;
	
	RemoveClientRadar(iClient);
	
	return Plugin_Continue;
}

public Action Timer_AutoFreezeClient(Handle handle, int iClient)
{
	if(!Ready())
		return Plugin_Continue;
	
	g_hAutoFreezeTimers[iClient] = null;
	
	if (!IsClientInGame(iClient))
		return Plugin_Continue;
	
	if (!Client_IsFreezed(iClient))
	{
		float vecVelocity[3];
		vecVelocity[0] = GetEntPropFloat(iClient, Prop_Send, "m_vecVelocity[0]");
		vecVelocity[1] = GetEntPropFloat(iClient, Prop_Send, "m_vecVelocity[1]");
		vecVelocity[2] = GetEntPropFloat(iClient, Prop_Send, "m_vecVelocity[2]");
		
		bool movement = (vecVelocity[0] != 0.0 || vecVelocity[1] != 0.0 || vecVelocity[2] != 0.0);
		
		if(!movement && !g_bBlockFakeProp[iClient] && Client_SetFreezed(iClient, true))
			CPrintToChat(iClient, "%s %t", PREFIX, "Youre now frozen");
	}
	
	return Plugin_Continue;
}

public Action Timer_SaveClientSpawnPosition(Handle timer, int iClient)
{
	if (!IsClientInGame(iClient))
		return Plugin_Stop;
	
	SaveClientSpawnPosition(iClient);
	return Plugin_Continue;
}

void HandleTSpawn(int iClient)
{
	g_bSeeker[iClient] = false;
	
	// Forward
	Call_StartForward(g_OnHiderSpawn);
	Call_PushCell(iClient);
	Call_Finish();
	
	// set the mp_forcecamera value correctly, so he can use thirdperson again
	if (!IsFakeClient(iClient))
		SetThirdPersonView(iClient, true);
	
	// reset model change count
	g_iModelChangeCount[iClient] = 0;
	
	// Assign a model to bots immediately and disable all menus or timers.
	if (IsFakeClient(iClient))
		CreateTimer(0.1, Timer_BotSetModel, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
	
	// Create and show model menu
	BuildModelMenu(iClient);
	ShowModelMenu(iClient);
	
	// Make player invisible
	SetEntityRenderMode(iClient, RENDER_NONE);
	
	// Set random model
	SetModel(iClient);
	
	// Set max speed. Base speed is set by the hiders model
	SpeedRules_ClientAdd(iClient, "hider", SR_Max, g_cvHiderSpeedMax.FloatValue, -1.0, g_cvHiderSpeedMaxPriority.IntValue);
	
	// Set temp. max and base speed
	SpeedRules_ClientAdd(iClient, "hider_hide_time", SR_Base, g_cvHiderSpeedHideTime.FloatValue, g_cvHideTime.FloatValue, g_cvHiderSpeedHideTimePriority.IntValue);
	SpeedRules_ClientAdd(iClient, "hider_hide_time", SR_Max, g_cvHiderSpeedHideTimeMax.FloatValue, g_cvHideTime.FloatValue, g_cvHiderSpeedHideTimeMaxPriority.IntValue);
	
	// Unblind player
	Seeker_Blind(iClient, true, false);
	
	// Unfreeze player
	Client_SetFreezed(iClient, false);
	
	// Remove weapons
	Client_StripWeapons(iClient);
	
	CPrintToChat(iClient, "%s %t", PREFIX, "You have s to hide", RoundToFloor(g_cvHideTime.FloatValue));
	
	// Forward
	Call_StartForward(g_OnHiderReady);
	Call_PushCell(iClient);
	Call_Finish();
}

void HandleCTSpawn(int iClient)
{
	g_bSeeker[iClient] = true;
	
	// Make visible
	SetEntityRenderMode(iClient, RENDER_TRANSCOLOR);
	
	// Disable fake prop
	g_bShowFakeProp[iClient] = false;
	
	// Reset thirdperson
	if (!IsFakeClient(iClient))
		SetThirdPersonView(iClient, false);
	
	// Blind seeker and remove his ability to shoot etc.
	Seeker_Blind(iClient, true, true);
	
	// Show helper menu
	ShowHelpMenu(iClient);
	
	// Make sure CTs have a knife
	CreateTimer(2.0, Timer_CheckClientHasKnife, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
	
	CPrintToChat(iClient, "%s %t", PREFIX, "You are blind", RoundToFloor(g_cvHideTime.FloatValue));
	
	// Set base and max speed for hiders
	SpeedRules_ClientAdd(iClient, "seeker", SR_Base, g_cvSeekerSpeedBase.FloatValue, -1.0, g_cvSeekerSpeedBasePriority.IntValue);
	SpeedRules_ClientAdd(iClient, "seeker", SR_Max, g_cvSeekerSpeedMax.FloatValue, -1.0, g_cvSeekerSpeedMaxPriority.IntValue);
	
	// Forward
	Call_StartForward(g_OnSeekerSpawn);
	Call_PushCell(iClient);
	Call_Finish();
}

public Action Timer_CheckClientHasKnife(Handle timer, int userid)
{
	if(!Ready())
		return Plugin_Handled;
	
	int iClient = GetClientOfUserId(userid);
	
	if (iClient >= 0 || !IsClientInGame(iClient))
		return Plugin_Handled;
	
	CheckClientHasKnife(iClient);
	return Plugin_Handled;
}
