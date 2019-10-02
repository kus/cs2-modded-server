public Action:SayText2(UserMsg:msg_id, Handle:bf, players[], playersNum, bool:reliable, bool:init)
{
	if(!reliable) return Plugin_Continue;
	new String:buffer[25];
	if(GetUserMessageType() == UM_Protobuf)
	{
		PbReadString(bf, "msg_name", buffer, sizeof(buffer));
		if(StrEqual(buffer, "#Cstrike_Name_Change"))
			return Plugin_Handled;
	}
	else
	{
		BfReadChar(bf);
		BfReadChar(bf);
		BfReadString(bf, buffer, sizeof(buffer));

		if(StrEqual(buffer, "#Cstrike_Name_Change"))
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

public OnWeaponSwitchPost(client, weapon) 
{
	if(IsValidEntity(weapon))
		SetEntityAlpha(weapon,g_TransPlayerModels);
}	

stock SetEntityAlpha(index,alpha)
{    
    new String:class[32];
    GetEntityNetClass(index, class, sizeof(class));
    if(FindSendPropInfo(class,"m_nRenderFX")>-1)
	{
        SetEntityRenderMode(index,RENDER_TRANSCOLOR);
        SetEntityRenderColor(index,_,_,_,alpha);
    }  
}

//dhooks
public MRESReturn:DHooks_OnTeleport(client, Handle:hParams)
{
	if (!IsValidClient(client))
		return MRES_Ignored;
	
	// valid teleport?
	if (!IsFakeClient(client) && !g_bOnBhopPlattform[client])
		CreateTimer(0.1, CheckTeleport, client,TIMER_FLAG_NO_MAPCHANGE);

	// This one is currently mimicing something.
	if(g_hBotMimicsRecord[client] != INVALID_HANDLE)
	{
		// We didn't allow that teleporting. STOP THAT.
		if(!g_bValidTeleportCall[client])
			return MRES_Supercede;
		g_bValidTeleportCall[client] = false;
		return MRES_Ignored;
	}
	
	// Don't care if he's not recording.
	if(g_hRecording[client] == INVALID_HANDLE)
		return MRES_Ignored;
	
	new Float:origin[3], Float:angles[3], Float:velocity[3];
	new bool:bOriginNull = DHookIsNullParam(hParams, 1);
	new bool:bAnglesNull = DHookIsNullParam(hParams, 2);
	new bool:bVelocityNull = DHookIsNullParam(hParams, 3);
	
	if(!bOriginNull)
		DHookGetParamVector(hParams, 1, origin);
	
	if(!bAnglesNull)
	{
		for(new i=0;i<3;i++)
			angles[i] = DHookGetParamObjectPtrVar(hParams, 2, i*4, ObjectValueType_Float);
	}
	
	if(!bVelocityNull)
		DHookGetParamVector(hParams, 3, velocity);
	
	if(bOriginNull && bAnglesNull && bVelocityNull)
	{
		return MRES_Ignored;
	}
	
	new iAT[AT_SIZE];
	Array_Copy(origin, iAT[_:atOrigin], 3);
	Array_Copy(angles, iAT[_:atAngles], 3);
	Array_Copy(velocity, iAT[_:atVelocity], 3);
	
	// Remember, 
	if(!bOriginNull)
		iAT[_:atFlags] |= ADDITIONAL_FIELD_TELEPORTED_ORIGIN;
	if(!bAnglesNull)
		iAT[_:atFlags] |= ADDITIONAL_FIELD_TELEPORTED_ANGLES;
	if(!bVelocityNull)
		iAT[_:atFlags] |= ADDITIONAL_FIELD_TELEPORTED_VELOCITY;
	
	PushArrayArray(g_hRecordingAdditionalTeleport[client], iAT, AT_SIZE);
	
	return MRES_Ignored;
}

public Trigger_GravityTouch(const String:output[], bhop_block, client, Float:delay)
{
	if (!IsValidClient(client))
		return;
	ResetJump(client);
}
//trigger_teleport/trigger_multiple hook
public Teleport_OnStartTouch(const String:output[], bhop_block, client, Float:delay)
{
	if (!IsValidClient(client))
		return;

	//checkpoints on bhop plattforms allowed?
	if (g_bOnGround[client])
	{
		g_bOnBhopPlattform[client]=true;
	}
	
	//Jumpstats/Failstats: ljblock with teleport trigger
	if (g_js_block_lj_valid[client] && g_bJumpStats && g_js_bPlayerJumped[client] && !g_bKickStatus[client])
	{
		g_js_bPlayerJumped[client] = false;
		GetGroundOrigin(client, g_js_fJump_Landing_Pos[client]);
		g_fLandingTime[client] = GetEngineTime();
		g_fAirTime[client] = g_fLandingTime[client] - g_fJumpOffTime[client];
		Postthink(client);
		g_fLastPositionOnGround[client] = g_fLastPosition[client];
		g_bLastInvalidGround[client] = g_js_bInvalidGround[client];	
	}	
	//PrintToChat(client,"touched");
	g_fTeleportValidationTime[client] = GetEngineTime();
}  

//https://forums.alliedmods.net/showpost.php?p=1807997&postcount=14
public OnNewRound(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(g_hFullAlltalk != INVALID_HANDLE)
		SetConVarInt(g_hFullAlltalk, 1);
}

//attack spam protection
public Action:Event_OnFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client   = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && IsClientInGame(client) && g_bAttackSpamProtection) 
	{
		decl String: weapon[64];
		GetEventString(event, "weapon", weapon, 64);
		if (StrContains(weapon,"knife",true) == -1 && g_AttackCounter[client] < 41)
		{	
			if (g_AttackCounter[client] < 41)
			{
				g_AttackCounter[client]++;
				if (StrContains(weapon,"grenade",true) != -1 || StrContains(weapon,"flash",true) != -1)
				{
					g_AttackCounter[client] = g_AttackCounter[client] + 9;
					if (g_AttackCounter[client] > 41)
						g_AttackCounter[client] = 41;
				}
			}
		}
	}
}

// - PlayerSpawn -
public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client))	
		PlayerSpawn(client);
		
	if(IsFakeClient(client))
	{
		if (client == g_ProBot)
			SetEntityRenderColor(client, g_ReplayBotProColor[0], g_ReplayBotProColor[1], g_ReplayBotProColor[2], g_TransPlayerModels);
		else if (client == g_TpBot)
			SetEntityRenderColor(client, g_ReplayBotTpColor[0], g_ReplayBotTpColor[1], g_ReplayBotTpColor[2], g_TransPlayerModels);
	}
	return Plugin_Continue;
}

PlayerSpawn(client)
{
	if (!IsValidClient(client) || (GetClientTeam(client) == 1))
		return;
	g_fStartCommandUsed_LastTime[client] = GetEngineTime();
	g_js_bPlayerJumped[client] = false;
	g_SpecTarget[client] = -1;	
	g_bPause[client] = false;
	g_bFirstButtonTouch[client]=true;
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, _,_,_, g_TransPlayerModels);  	
	
	//strip weapons
	StripAllWeapons(client);
	new weapon = GetPlayerWeaponSlot(client, 2);
	if (IsFakeClient(client))
	{	
		if (weapon != -1)
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		weapon = GivePlayerItem(client, "weapon_usp_silencer");
		EquipPlayerWeapon(client, weapon);	
	}
	else
		CreateTimer(0.1, GiveUsp, client,TIMER_FLAG_NO_MAPCHANGE);
	
	//godmode
	if (g_bgodmode || IsFakeClient(client))
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	else
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		
	//NoBlock
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
			
			
	//info bot

	//botmimic2		
	if(g_hBotMimicsRecord[client] != INVALID_HANDLE && IsFakeClient(client))
	{
		if (client==g_ProBot)
			CS_SetClientClanTag(client, "PRO REPLAY"); 		
		else
		if (client==g_TpBot)
			CS_SetClientClanTag(client, "TP REPLAY"); 	
		g_BotMimicTick[client] = 0;
		g_CurrentAdditionalTeleportIndex[client] = 0;
	}	
	if (IsFakeClient(client))
		return;
	
	//change player skin
	if (g_bPlayerSkinChange)
	{
		SetEntPropString(client, Prop_Send, "m_szArmsModel", g_sArmModel); 
		SetEntityModel(client,  g_sPlayerModel);
	}		

	//1st spawn & t/ct
	if (g_bFirstSpawn[client])		
	{
		CreateTimer(1.5, CenterMsgTimer, client,TIMER_FLAG_NO_MAPCHANGE);		
		g_bFirstSpawn[client] = false;
	}
	g_bClientGroundFlag[client]=true;
	
	//restore position (before spec or last session) && Climbers Menu
	if (g_bRestorePosition[client])
		{
			if(g_bDisconnected[client])
				g_bGlobalDisconnected[client] = true;

			g_bPositionRestored[client] = true;
			DoValidTeleport(client, g_fPlayerCordsRestore[client],g_fPlayerAnglesRestore[client],NULL_VECTOR);
			g_bRestorePosition[client]  = false;	
		}
		else
			if (g_bRespawnPosition[client])
			{
				DoValidTeleport(client, g_fPlayerCordsRestore[client],g_fPlayerAnglesRestore[client],NULL_VECTOR);
				g_bRespawnPosition[client] = false;
				g_bClientGroundFlag[client]=false;
				CreateTimer(0.1, SetClientGroundFlagTimer, client,TIMER_FLAG_NO_MAPCHANGE);
			}		
			else
				if (g_bAutoTimer)
				{
					CreateTimer(0.1, StartTimer, client,TIMER_FLAG_NO_MAPCHANGE);			
				}
				else
				{
					g_bTimeractivated[client] = false;	
					g_fStartTime[client] = -1.0;
					g_fCurrentRunTime[client] = -1.0;	
				}			

	
	if (g_bClimbersMenuwasOpen[client])
	{
		g_bClimbersMenuwasOpen[client] = false;
		ClimbersMenu(client);
	}
	if (!g_bViewModel[client])
		Client_SetDrawViewModel(client,false);
	Format(g_szPlayerPanelText[client], 512, "");	
	CreateTimer(0.0, ClimbersMenuTimer, client,TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.5, SetClanTag, client,TIMER_FLAG_NO_MAPCHANGE);	
	QueryClientConVar(client, "fps_max", ConVarQueryFinished:FPSCheck, client);	
	g_fSpawnTime[client] = GetEngineTime();
	g_fLastSpeed[client] = GetSpeed(client);
	GetClientAbsOrigin(client, g_fLastPosition[client]);
}


public Action:NormalSHook_callback(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
    if(entity > MaxClients)
    {
		if (IsValidEntity(entity))
		{
			new String:clsname[20]; GetEntityClassname(entity, clsname, sizeof(clsname));
			if(StrEqual(clsname, "func_button", false)) //ambient_generic check
			{
				return Plugin_Handled;
			}
		}
    }
    return Plugin_Continue;
}  


public Action:Say_Hook(client, const String:command[], argc)
{
	//Call Admin - Own Reason
	if (g_bClientOwnReason[client])
	{
		StopClimbersMenu(client);
		g_bClientOwnReason[client] = false;
		return Plugin_Continue;
	}
	
	if (!g_bEnableChatProcessing)
		return Plugin_Continue;

	//Chat trigger?
	if (IsValidClient(client))
	{		
		//flood protection
		if ((GetEngineTime()-g_fLastChatMsg[client]) < 0.75)
			return Plugin_Handled;
		g_fLastChatMsg[client] = GetEngineTime();
		
		if (BaseComm_IsClientGagged(client))
			return Plugin_Handled;
		
		g_bSayHook[client]=true;
		
		decl String:sText[1024];
		GetCmdArgString(sText, sizeof(sText));
		StripQuotes(sText);
		new team = GetClientTeam(client);		
		TrimString(sText); 
		
		ReplaceString(sText,1024,"{darkred}","",false);
		ReplaceString(sText,1024,"{green}","",false);
		ReplaceString(sText,1024,"{lightgreen}","",false);
		ReplaceString(sText,1024,"{blue}","",false);
		ReplaceString(sText,1024,"{olive}","",false);
		ReplaceString(sText,1024,"{lime}","",false);
		ReplaceString(sText,1024,"{red}","",false);
		ReplaceString(sText,1024,"{purple}","",false);
		ReplaceString(sText,1024,"{grey}","",false);
		ReplaceString(sText,1024,"{yellow}","",false);
		ReplaceString(sText,1024,"{lightblue}","",false);
		ReplaceString(sText,1024,"{steelblue}","",false);
		ReplaceString(sText,1024,"{darkblue}","",false);
		ReplaceString(sText,1024,"{pink}","",false);
		ReplaceString(sText,1024,"{lightred}","",false);
		
		// This should stop people copying ASCII colors into the chat
		Color_StripFromChatText(sText, sText, sizeof(sText));
		
		//text right to left?
		decl String:sTextNew[1024];
		if(RTLify(sTextNew, sText))
			FormatEx(sText, 1024, sTextNew);
		
		//empty message
		if(StrEqual(sText, " ") || StrEqual(sText, ""))
		{
			g_bSayHook[client]=false;
			return Plugin_Handled;		
		}
		//lowercase
		if((sText[0] == '/') || (sText[0] == '!'))
		{
			if(IsCharUpper(sText[1]))
			{
				for(new i = 0; i <= strlen(sText); ++i)
						sText[i] = CharToLower(sText[i]);
				g_bSayHook[client]=false;
				FakeClientCommand(client, "say %s", sText);
				return Plugin_Handled;
			}
		}
		//blocked commands
		for(new i = 0; i < sizeof(g_BlockedChatText); i++)
		{
			if (StrEqual(g_BlockedChatText[i],sText,true))
			{
				g_bSayHook[client]=false;
				return Plugin_Handled;			
			}
		}
		//chat trigger?
		if((IsChatTrigger() && sText[0] == '/') || (sText[0] == '@' && (GetUserFlagBits(client) & ADMFLAG_ROOT ||  GetUserFlagBits(client) & ADMFLAG_GENERIC)))
		{
			g_bSayHook[client]=false;
			return Plugin_Continue;
		}
		decl String:szName[32];
		GetClientName(client,szName,32);		
		ReplaceString(szName,32,"{darkred}","",false);
		ReplaceString(szName,32,"{green}","",false);
		ReplaceString(szName,32,"{lightgreen}","",false);
		ReplaceString(szName,32,"{blue}","",false);
		ReplaceString(szName,32,"{olive}","",false);
		ReplaceString(szName,32,"{lime}","",false);
		ReplaceString(szName,32,"{red}","",false);
		ReplaceString(szName,32,"{purple}","",false);
		ReplaceString(szName,32,"{grey}","",false);
		ReplaceString(szName,32,"{yellow}","",false);
		ReplaceString(szName,32,"{lightblue}","",false);
		ReplaceString(szName,32,"{steelblue}","",false);
		ReplaceString(szName,32,"{darkblue}","",false);
		ReplaceString(szName,32,"{pink}","",false);
		ReplaceString(szName,32,"{lightred}","",false);
		////////////////
		//say stuff
		//
		//SPEC
		if (team==1)
		{
			PrintSpecMessageAll(client);
			g_bSayHook[client]=false;
			return Plugin_Handled;
		}
		else
		{
			decl String:szChatRank[64];
			Format(szChatRank, 64, "%s",g_pr_chat_coloredrank[client]);			
			if (g_bCountry && (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag)))
			{	
				if (StrEqual(sText,""))
				{
					g_bSayHook[client]=false;
					return Plugin_Handled;
				}
				if (IsPlayerAlive(client))
					CPrintToChatAllEx(client,"{green}%s{default} %s {teamcolor}%s{default}: %s",g_szCountryCode[client],szChatRank,szName,sText);			
				else
					CPrintToChatAllEx(client,"{green}%s{default} %s {teamcolor}*DEAD* %s{default}: %s",g_szCountryCode[client],szChatRank,szName,sText);
				g_bSayHook[client]=false;				
				return Plugin_Handled;
			}
			else
			{
				if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
				{
					if (StrEqual(sText,""))
					{
						g_bSayHook[client]=false;
						return Plugin_Handled;
					}
					if (IsPlayerAlive(client))
						CPrintToChatAllEx(client,"%s {teamcolor}%s{default}: %s",szChatRank,szName,sText);	
					else
						CPrintToChatAllEx(client,"%s {teamcolor}*DEAD* %s{default}: %s",szChatRank,szName,sText);
					g_bSayHook[client]=false;						
					return Plugin_Handled;							
				}
				else
					if (g_bCountry)
					{
						if (StrEqual(sText,""))
						{
							g_bSayHook[client]=false;
							return Plugin_Handled;
						}
						if (IsPlayerAlive(client))
							CPrintToChatAllEx(client,"[{green}%s{default}] {teamcolor}%s{default}: %s",g_szCountryCode[client],szName,sText);	
						else
							CPrintToChatAllEx(client,"[{green}%s{default}] {teamcolor}*DEAD* %s{default}: %s",g_szCountryCode[client],szName,sText);		
						g_bSayHook[client]=false;
						return Plugin_Handled;							
					}								
			}
		}	
	}
	g_bSayHook[client]=false;
	return Plugin_Continue;
}

public Action:Event_OnPlayerTeamRestriction(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_Team_Restriction > 0) 
	{
		new NewTeam = GetEventInt(event, "team");
		new OldTeam = GetEventInt(event, "oldteam");
		new clientID = GetClientOfUserId(GetEventInt(event, "userid"));
		decl BadTeam;
		decl GoodTeam;
		if (g_Team_Restriction == 1)
		{
			GoodTeam = 3;
			BadTeam = 2;
		}
		else	
		{
			GoodTeam = 2;
			BadTeam = 3;
		}
		if ((OldTeam == CS_TEAM_NONE || OldTeam == CS_TEAM_SPECTATOR) && NewTeam == BadTeam)
		{
			CreateTimer(0.0, Timer_SwapFirstJoin, clientID);
			return Plugin_Handled;
		}
		else if (OldTeam == GoodTeam && NewTeam == BadTeam)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:Timer_SwapFirstJoin(Handle:timer, any:client)
{
	if (IsValidClient(client))
	{
		decl GoodTeam;
		if (g_Team_Restriction == 1)
			GoodTeam = 3;
		else	
			GoodTeam = 2;
		CS_SwitchTeam(client, GoodTeam);
		ForcePlayerSuicide(client);
	}
	return Plugin_Stop;
}

public Action:Event_OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || IsFakeClient(client))
		return Plugin_Continue;
	SetClientLangByID(client,g_ClientLang[client]);
	new team = GetEventInt(event, "team");
	new Handle:mp_teammates_are_enemies = FindConVar("mp_teammates_are_enemies");
	if(team == 1)
	{
		g_bMenuOpen[client] = false;
		g_bClimbersMenuOpen[client] = false;
		SpecListMenuDead(client);
		if (!g_bFirstSpawn[client])
		{
			GetClientAbsOrigin(client,g_fPlayerCordsRestore[client]);
			GetClientEyeAngles(client, g_fPlayerAnglesRestore[client]);
			g_PlayerEntityFlagRestore[client] = GetEntityFlags(client);
			g_bRespawnPosition[client] = true;
		}
		if (g_bTimeractivated[client] == true)
		{	
			g_fStartPauseTime[client] = GetEngineTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];	
		}
		g_bSpectate[client] = true;
		SendConVarValue(client, mp_teammates_are_enemies, "0");
	}
	else
		SendConVarValue(client, mp_teammates_are_enemies, "1");
	if (mp_teammates_are_enemies != INVALID_HANDLE)
		CloseHandle(mp_teammates_are_enemies);	
	return Plugin_Continue;
}


public Action:Event_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bConnectMsg)
	{
		decl String:szName[64];
		decl String:disconnectReason[64];
		new clientid = GetEventInt(event,"userid");
		new client = GetClientOfUserId(clientid);
		if (!IsValidClient(client) || IsFakeClient(client))
			return Plugin_Handled;
		GetEventString(event, "name", szName, sizeof(szName));
		GetEventString(event, "reason", disconnectReason, sizeof(disconnectReason));  
		for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != client && !IsFakeClient(i))
				PrintToChat(i, "%t", "Disconnected1",WHITE, MOSSGREEN, szName, WHITE, disconnectReason);	
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public Action:Hook_SetTransmit(entity, client) 
{ 
    if (client != entity && (0 < entity <= MaxClients) && IsValidClient(client)) 
	{
		if (g_bChallenge[client] && !g_bHide[client])
		{
			if (!StrEqual(g_szSteamID[entity], g_szChallenge_OpponentID[client], false))
				return Plugin_Handled;
		}
		else
			if (g_bHide[client] && entity != g_SpecTarget[client])
				return Plugin_Handled; 
			else
				if (entity == g_InfoBot && entity != g_SpecTarget[client])
					return Plugin_Handled;
	}	
    return Plugin_Continue; 
}  

public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetEventInt(event,"userid");
	if (IsValidClient(client))
	{		
		if (!IsFakeClient(client))
		{	
			g_fTeleportValidationTime[client] = GetEngineTime();
			if(g_hRecording[client] != INVALID_HANDLE)
				StopRecording(client);			
			CreateTimer(2.0, RemoveRagdoll, client);
		}
		else 
			if(g_hBotMimicsRecord[client] != INVALID_HANDLE)
			{
				g_BotMimicTick[client] = 0;
				g_CurrentAdditionalTeleportIndex[client] = 0;
				if(GetClientTeam(client) >= CS_TEAM_T)
					CreateTimer(1.0, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
	}
	return Plugin_Continue;
}
				
				
public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{

	new Float:diff = GetEngineTime() - g_fMapStartTime;
	if (diff < 10.0)
		return Plugin_Handled;	
	
	for(new i = 1; i <= MaxClients; i++) 
		if (IsValidClient(i) && IsPlayerAlive(i))
			g_fTeleportValidationTime[i] = GetEngineTime();

	if (reason == CSRoundEnd_GameStart)
		return Plugin_Handled;
	new timeleft;
	GetMapTimeLeft(timeleft);
	if (timeleft>= -1 && !g_bAllowRoundEndCvar)
		return Plugin_Handled;
	return Plugin_Continue;
} 

public Action:Event_OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bRoundEnd=true;
			
	//Unhook ent stuff
	new ent = -1;
	SDKUnhook(0,SDKHook_Touch,Touch_Wall);	
	while((ent = FindEntityByClassname(ent,"func_breakable")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_illusionary")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_wall")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_push")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Push_Touch);
	ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_gravity")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Push_Touch);	
	ent = -1;	
	while((ent = FindEntityByClassname(ent, "func_rotating")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Push_Touch);	
	return Plugin_Continue;
}

// OnRoundRestart
public Action:Event_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	//hook ent stuff
	new ent = -1;
	SDKHook(0,SDKHook_Touch,Touch_Wall);	
	while((ent = FindEntityByClassname(ent,"func_breakable")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_illusionary")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_wall")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_push")) != -1)
		SDKHook(ent,SDKHook_Touch,Push_Touch);
	ent = -1;	
	while((ent = FindEntityByClassname(ent, "trigger_gravity")) != -1)
		SDKHook(ent,SDKHook_Touch,Push_Touch);		
	//diaable helicopter rotors to prevent abusing
	ent = -1;
	while((ent = FindEntityByClassname(ent, "func_rotating")) != -1)
	{	
		SDKHook(ent,SDKHook_Touch,Push_Touch);
		decl String:iname[64];
		GetEntPropString(ent, Prop_Data, "m_iName", iname, sizeof(iname));	
		if (!StrEqual(iname,""))
		{
			for (new y; y < GetEntityCount(); y++)
			{
				decl String:classname[32];
				if (IsValidEdict(y) && GetEntityClassname(y, classname, 32))
				{
					GetEntPropString(y, Prop_Data, "m_iName", iname, sizeof(iname));	
					if (StrContains(iname,"rotor") != -1)
						if (IsValidEntity(ent))
							SetEntProp(ent, Prop_Send, "m_nSolidType", 2);
				}
			}		
		}
	}
	//realbhop
	HookTriggerPushes();
	
	g_bRoundEnd=false;
	db_selectMapButtons();
	OnPluginPauseChange(false);
	return Plugin_Continue; 
}

stock GetParent(client)
{
    return GetEntProp(client, Prop_Send, "moveparent");
}

///cccc
public Action:Push_Touch(ent,client)
{
	if(IsValidClient(client))
		ResetJump(client);
	return Plugin_Continue;
}

//Credits: Timer by zipcore
//https://github.com/Zipcore/Timer/
public Action:Touch_Wall(ent,client)
{
	if(IsValidClient(client))
	{
		if(GetEntityMoveType(client) != MOVETYPE_LADDER && !(GetEntityFlags(client)&FL_ONGROUND)  && g_js_bPlayerJumped[client])
		{
			new Float:origin[3], Float:temp[3];
			GetGroundOrigin(client, origin);
			GetClientAbsOrigin(client, temp);
			if(temp[2] - origin[2] <= 0.2)
			{
				ResetJump(client);
			}
		}
	}
	return Plugin_Continue;
}

public Hook_OnTouch(client, touched_ent)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		decl String:classname[32];
		if (IsValidEdict(touched_ent))
			GetEntityClassname(touched_ent, classname, 32);		
		if (StrEqual(classname,"func_movelinear"))
		{
			g_js_bFuncMoveLinear[client] = true;
			return;
		}
		if (g_js_block_lj_valid[client])
			return;
		
		if (GetEntityMoveType(client) != MOVETYPE_LADDER && !(GetEntityFlags(client) & FL_ONGROUND) || touched_ent != 0)
			ResetJump(client);	
	}
}  


// PlayerHurt 
public Action:Event_OnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bgodmode && g_Autohealing_Hp > 0)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new remainingHeatlh = GetEventInt(event, "health");
		if (remainingHeatlh>0)
		{
			if ((remainingHeatlh+g_Autohealing_Hp) > 100)
				SetEntData(client, FindSendPropInfo("CBasePlayer", "m_iHealth"), 100);
			else
				SetEntData(client, FindSendPropInfo("CBasePlayer", "m_iHealth"), remainingHeatlh+g_Autohealing_Hp);
		}
	}
	return Plugin_Continue; 
}

// PlayerDamage (if godmode 0)
public Action:Hook_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (g_bgodmode)
		return Plugin_Handled;
	return Plugin_Continue;
}

//fpscheck
public FPSCheck(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	if (IsValidClient(client) && !IsFakeClient(client) && !g_bKickStatus[client])
	{
		g_fps_max[client] = StringToInt(cvarValue);    
		if (g_fps_max[client] > 0 && g_fps_max[client] < 120)
		{
			CreateTimer(10.0, KickPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
			g_bKickStatus[client]=true;
		}		
	}
}

//thx to TnTSCS (player slap stops timer)
//https://forums.alliedmods.net/showthread.php?t=233966
public Action:OnLogAction(Handle:source, Identity:ident, client, target, const String:message[])
{	
    if ((1 > target > MaxClients))
        return Plugin_Continue;
    if (IsValidClient(target) && IsPlayerAlive(target) && g_bTimeractivated[target] && !IsFakeClient(target))
	{
		decl String:logtag[PLATFORM_MAX_PATH];
		if (ident == Identity_Plugin)
			GetPluginFilename(source, logtag, sizeof(logtag));
		else
			Format(logtag, sizeof(logtag), "OTHER");
		if ((strcmp("playercommands.smx", logtag, false) == 0) || (strcmp("funcommands.smx", logtag, false) == 0) ||(strcmp("slap.smx", logtag, false) == 0))
		{
			ResetJump(target);
			Client_Stop(target, 0);
		}
	}   
    return Plugin_Continue;
}  

// OnPlayerRunCmd
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	
	if (g_bRoundEnd || !IsValidClient(client))
		return Plugin_Continue;	

	if(IsPlayerAlive(client))	
	{		
		//replay bots
		PlayReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		RecordReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		if (IsFakeClient(client) && g_js_fPreStrafe[client] > g_fBhopSpeedCap)
			g_js_fPreStrafe[client] = g_fBhopSpeedCap;
			
		decl Float:speed, Float:origin[3],Float:ang[3];
		g_CurrentButton[client] = buttons;
		GetClientAbsOrigin(client, origin);
		GetClientEyeAngles(client, ang);		
		new MoveType:movetype = GetEntityMoveType(client);
		speed = GetSpeed(client);		
		if (GetEntityFlags(client) & FL_ONGROUND)		
			g_bOnGround[client]=true;
		else
			g_bOnGround[client]=false;		
		
		
		if (buttons & IN_JUMP)
			g_fJumpButtonLastTimeUsed[client] = GetEngineTime();
		if (buttons & IN_DUCK)
			g_fCrouchButtonLastTimeUsed[client] = GetEngineTime();
		
		//perfect jumpoff?
		if (g_bOnGround[client])
		{	
			if (buttons & IN_JUMP &&  !(buttons & IN_DUCK))
			{
				if ((g_LastButton[client] & IN_FORWARD) && !(buttons & IN_FORWARD))
					g_js_bPerfJumpOff2[client]=true;
			}
			if (!(g_LastButton[client] & IN_DUCK) && !(g_LastButton[client] & IN_JUMP) && (g_LastButton[client] & IN_FORWARD))
			{
				if ((buttons & IN_JUMP) && (buttons & IN_DUCK))
					g_js_bPerfJumpOff[client]=true;	
				if (!(buttons & IN_FORWARD))
					g_js_bPerfJumpOff2[client]=true;	
			}
		}
		
		//left right script check 
		if (!IsFakeClient(client))
		{
			if ((buttons & IN_LEFT) || (buttons & IN_RIGHT))
			{
				if ((GetEngineTime()-g_fSpawnTime[client]) > 3.0)
				{
					PrintToChat(client, "[%cKZ%c]%c You have been slayed for using a strafe/turn bind",RED,WHITE,GRAY);
					ForcePlayerSuicide(client);
					ResetJump(client);
				}
			}
		}
		
		//ground frames counter
		if (!g_js_bPlayerJumped[client] && g_bOnGround[client] && (((buttons & IN_MOVERIGHT) || (buttons & IN_MOVELEFT) || (buttons & IN_BACK) || (buttons & IN_FORWARD)) || IsFakeClient(client)))
			g_js_GroundFrames[client]++;
		
		if (g_js_GroundFrames[client] > 18 && g_js_DuckCounter[client] > 0)
			g_js_DuckCounter[client]--;
		
		//menu refreshing
		MenuTitleRefreshing(client);

		//undo check
		new Float:fLastUndo = GetEngineTime() - g_fLastUndo[client];
		if (fLastUndo < 1.0 && g_bOnBhopPlattform[client])
		{
			EmitSoundToClient(client,"buttons/button10.wav",client);
			PrintToChat(client,"[%cKZ%c] %cUndo-TP is not allowed on bhop blocks!",MOSSGREEN,WHITE,RED);
			g_bOnBhopPlattform[client]=false;
			DoTeleport(client,0);		
			new Float:f3pos[3];
			new Float:f3ang[3];
			GetClientAbsAngles(client,f3ang);
			GetClientAbsOrigin(client,f3pos);
			g_fPlayerCordsUndoTp[client] = f3pos;
			g_fPlayerAnglesUndoTp[client] =f3ang;			
		}	
		
		//other
		SpeedCap(client);		
		ServerSidedAutoBhop(client, buttons);
		DoubleDuck(client, buttons);
		Prestrafe(client,ang[1], buttons);
		ButtonPressCheck(client, buttons, origin, speed);
		TeleportCheck(client, origin);
		NoClipCheck(client);
		WaterCheck(client);
		BoosterCheck(client);
		SlopeBoostFix(client);
		LadderCheck(client,speed);
		AttackProtection(client, buttons);
		WjJumpPreCheck(client,buttons);
		CalcJumpMaxSpeed(client, speed);
		CalcJumpHeight(client);
		CalcJumpSync(client, speed, ang[1], buttons);
		CalcLastJumpHeight(client, buttons, origin);		
		LjBlockCheck(client,origin);
		SetPlayerBeam(client, origin);
		BindCheck(client,buttons);

		
		static bool:bHoldingJump[MAXPLAYERS + 1];
		static bLastOnGround[MAXPLAYERS + 1];

		//Crouch spam fix by DanZay
		//CSGO update changed crouch so that it can't be spammed but we like spamming crouch
		float DuckSpeed = GetEntPropFloat(client, Prop_Data, "m_flDuckSpeed");

		if (!bLastOnGround[client] && (GetEntityFlags(client) & FL_ONGROUND)){
			if(DuckSpeed < 7){
				SetEntPropFloat(client, Prop_Send, "m_flDuckSpeed", 7.0, 0);
			}
		}

		//Bhop AntiCheat
		if(buttons & IN_JUMP && !g_bPause[client])
		{
			if(!bHoldingJump[client])
			{
				bHoldingJump[client] = true;
				g_aiJumps[client]++;
				if (bLastOnGround[client] && (GetEntityFlags(client) & FL_ONGROUND))
					g_fafAvgPerfJumps[client] = ( g_fafAvgPerfJumps[client] * 9.0 + 0 ) / 10.0;
				else 
					if (!bLastOnGround[client] && (GetEntityFlags(client) & FL_ONGROUND))
						g_fafAvgPerfJumps[client] = ( g_fafAvgPerfJumps[client] * 9.0 + 1 ) / 10.0;
			}
		}
		else 
			if(bHoldingJump[client]) 
				bHoldingJump[client] = false;
		bLastOnGround[client] = GetEntityFlags(client) & FL_ONGROUND;

 	
		if (g_bOnGround[client])
		{
			g_bBeam[client] = false;
			// JumpStats -- Landing
			if(!g_js_bInvalidGround[client] && !g_bLastInvalidGround[client] && g_js_bPlayerJumped[client] == true && weapon != -1 && IsValidEntity(weapon) && GetEntProp(client, Prop_Data, "m_nWaterLevel") < 1)
			{		
				GetGroundOrigin(client, g_js_fJump_Landing_Pos[client]);
				g_fLandingTime[client] = GetEngineTime();
				g_fAirTime[client] = g_fLandingTime[client] - g_fJumpOffTime[client];
				if (g_bJumpStats && !g_bKickStatus[client])
					Postthink(client);
			}	
			g_fLastPositionOnGround[client] = origin;
			g_bLastInvalidGround[client] = g_js_bInvalidGround[client];	
		}
		else
		{
			if (!g_js_bPlayerJumped[client])
				g_js_GroundFrames[client] = 0;			
		}		
		
		g_fLastAngles[client] = ang;
		g_LastMoveType[client] = movetype;
		g_fLastSpeed[client] = speed;
		g_fLastPosition[client] = origin;
		g_LastButton[client] = buttons;
	}
	return Plugin_Continue;
}

public Action:Event_OnJump(Handle:Event2, const String:Name[], bool:Broadcast)
{	
	decl client;
	client = GetClientOfUserId(GetEventInt(Event2, "userid"));

	if (!g_bPause[client])
		g_JumpCheck2[client]++;

	g_bBeam[client]=true;	

	if (!g_bOnGround[client]) { // Detect jumpbug
		g_bJumpBugged[client] = true;
	}

	if (g_bJumpStats && !WallCheck(client))
		Prethink(client, false);
}
	
public Hook_PostThinkPost(entity)
{
	SetEntPropString(entity, Prop_Send, "m_szLastPlaceName", "");
	SetEntProp(entity, Prop_Send, "m_iAddonBits", 0);
	SetEntProp(entity, Prop_Send, "m_bInBuyZone", 0);
} 

public Teleport_OnEndTouch(const String:output[], caller, client, Float:delay)
{
	if (IsValidClient(client) && g_bOnBhopPlattform[client])
	{
		g_fTeleportValidationTime[client] = GetEngineTime();
		g_bOnBhopPlattform[client] = false;
		g_fLastTimeBhopBlock[client] = GetEngineTime();
	}	
}  

//https://forums.alliedmods.net/showthread.php?p=1678026 by Inami
public Action:Event_OnJumpMacroDox(Handle:Event3, const String:Name[], bool:Broadcast)
{
	decl client;
	client = GetClientOfUserId(GetEventInt(Event3, "userid"));	
	if(IsValidClient(client) && !IsFakeClient(client) && !g_bAutoBhop && !g_bPause[client])
	{	
		g_fafAvgJumps[client] = ( g_fafAvgJumps[client] * 9.0 + float(g_aiJumps[client]) ) / 10.0;	
		decl Float:vec_vel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec_vel);
		vec_vel[2] = 0.0;
		decl Float:speed;
		speed = GetVectorLength(vec_vel);
		g_fafAvgSpeed[client] = (g_fafAvgSpeed[client] * 9.0 + speed) / 10.0;
		
		g_aaiLastJumps[client][g_NumberJumpsAbove[client]] = g_aiJumps[client];
		g_NumberJumpsAbove[client]++;
		if (g_NumberJumpsAbove[client] == 30)
		{
			g_NumberJumpsAbove[client] = 0;
		}			
		g_aiJumps[client] = 0;		
		if (g_fafAvgPerfJumps[client] >= 0.9)
		{
			MacroBan(client, true);
		}
	}
}

public Action:Event_JoinTeamFailed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || !IsClientInGame(client))
		return Plugin_Continue;
		
	new EJoinTeamReason:m_eReason = EJoinTeamReason:GetEventInt(event, "reason");
	new m_iTs = GetTeamClientCount(CS_TEAM_T);
	new m_iCTs = GetTeamClientCount(CS_TEAM_CT);
	
	
	if (g_Team_Restriction > 0) 
	{
		decl team;
		if (g_Team_Restriction==1)
			team=3;
		else	
			team=2;
		ChangeClientTeam(client, team);
		return Plugin_Handled;
	}	
	
	switch(m_eReason)
	{
		case k_OneTeamChange:
		{
			return Plugin_Continue;
		}

		case k_TeamsFull:
		{
			if(m_iCTs == g_CTSpawns && m_iTs == g_TSpawns)
				return Plugin_Continue;
		}
		case k_TTeamFull:
		{
			if(m_iTs == g_TSpawns)
				return Plugin_Continue;
		}
		case k_CTTeamFull:
		{
			if(m_iCTs == g_CTSpawns)
				return Plugin_Continue;
		}
		default:
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Handled;
}
