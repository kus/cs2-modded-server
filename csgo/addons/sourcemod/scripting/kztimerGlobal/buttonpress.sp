// buttonpress.sp
public ButtonPress(const String:name[], caller, activator, Float:delay)
{
	if(!IsValidEntity(caller) || !IsValidClient(activator))
		return;		
	g_bLJBlock[activator] = false;
	decl String:targetname[128];
	GetEdictClassname(activator,targetname, sizeof(targetname));
	if(!StrEqual(targetname,"player"))
		return;
	GetEntPropString(caller, Prop_Data, "m_iName", targetname, sizeof(targetname));
	if(StrEqual(targetname,"climb_startbutton") && g_FramesOnGround[activator] >= MAX_BHOP_FRAMES)
	{
		Call_StartForward(hStartPress);
		Call_PushCell(activator);
		Call_PushCell(false);
		Call_Finish();
	} 
	else if(StrEqual(targetname,"climb_endbutton")) 
	{
		Call_StartForward(hEndPress);
		Call_PushCell(activator);
		Call_PushCell(false);
		Call_Finish();
	}
	return;
}

// - builded Climb buttons -
public OnUsePost(entity, activator, caller, UseType:type, Float:value)
{
	if(!IsValidEntity(entity) || !IsValidClient(activator))
		return;	
	decl String:targetname[128];
	GetEdictClassname(activator,targetname, sizeof(targetname));
	if(!StrEqual(targetname,"player"))
		return;
	GetEntPropString(entity, Prop_Data, "m_iName", targetname, sizeof(targetname));
	//new Float: speed = GetSpeed(activator);
	if(StrEqual(targetname,"climb_startbuttonx") && g_FramesOnGround[activator] >= MAX_BHOP_FRAMES)
	{		
		g_global_SelfBuiltButtons=true;
		Call_StartForward(hStartPress);
		Call_PushCell(activator);
		Call_PushCell(false);
		Call_Finish();
	}
	else if(StrEqual(targetname,"climb_endbuttonx")) 
	{
		g_global_SelfBuiltButtons=true;
		Call_StartForward(hEndPress);
		Call_PushCell(activator);
		Call_Finish();
	}
}  

// - Climb Button OnStartPress -
public void CL_OnStartTimerPress(int client, bool zone)
{		
	ClearArray(g_hRouteArray[client]);
	
	if (!IsFakeClient(client))
	{
		if (g_bNewReplay[client]
			|| !zone && !(g_bOnGround[client]) && !g_global_SelfBuiltButtons
			|| IsPlayerStuck(client)
			|| GetGameTime() - g_fLastTeleportTime[client] < TP_TIMER_BLOCK_TIME
			|| zone && g_FramesOnGroundLast[client] <= 1)
		{
			return;
		}
		
		//timer pos
		if (!zone && g_bFirstStartButtonPush[client])
		{
			GetClientAbsOrigin(client,g_fStartButtonPos[client]);
			g_bFirstStartButtonPush[client]=false;
		}	

		if (!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		{
			if(g_hRecording[client] != INVALID_HANDLE)
				StopRecording(client);
		}
		else
		{	
			if(g_hRecording[client] != INVALID_HANDLE)
				StopRecording(client);
			StartRecording(client);
		}		
	}
	
	if ((!g_bSpectate[client] && !g_bNoclipped[client]) || IsFakeClient(client))
	{	
		g_fPlayerCordsUndoTp[client][0] = 0.0;
		g_fPlayerCordsUndoTp[client][1] = 0.0;
		g_fPlayerCordsUndoTp[client][2] = 0.0;		
		g_CurrentCp[client] = -1;
		g_CounterCp[client] = 0;	
		g_OverallCp[client] = 0;
		g_OverallTp[client] = 0;
		g_fPauseTime[client] = 0.0;
		g_JumpCheck2[client] = 0;
		g_JumpCheck1[client] = 0;
		g_fStartPauseTime[client] = 0.0;
		g_bPause[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		g_fStartTime[client] = GetEngineTime();	
		g_bMenuOpen[client] = false;		
		g_bTopMenuOpen[client] = false;	
		g_bPositionRestored[client] = false;
		g_bGlobalDisconnected[client] = false;
		g_bDisconnected[client] = false;
		g_bMissedTpBest[client] = true;
		g_bMissedProBest[client] = true;
		new bool: act = g_bTimeractivated[client];
		g_bTimeractivated[client] = true;		
		decl String:szTime[32];
		
		if (g_bEnforcer)
			g_global_Enforcer[client]=true;
		else
			g_global_Enforcer[client]=false;
			
		if (g_iDoubleDuckCvar == 1)
			g_global_DoubleDuck[client]=true;
		else
			g_global_DoubleDuck[client]=false;			
			
		//valid players
		if (!IsFakeClient(client))
		{	
			//Get start position
			if (!zone)
			{
				g_bRespawnAtTimer[client] = true;
				GetClientAbsOrigin(client, g_fPlayerCordsRestart[client]);
				GetClientEyeAngles(client, g_fPlayerAnglesRestart[client]);		
			}
			
			if (g_bShowTimerInfo[client])
			{
				g_bShowTimerInfo[client] = false;

				//star message
				decl String:szTpTime[32];
				decl String:szProTime[32];
				if (g_fPersonalRecord[client]<=0.0)
				{
					Format(szTpTime, 32, "NONE");
				}

				else
				{
					g_bMissedTpBest[client] = false;
					FormatTimeFloat(client, g_fPersonalRecord[client], 3, szTime, sizeof(szTime));
					Format(szTpTime, 32, "%s (#%i/%i)", szTime,g_MapRankTp[client],g_MapTimesCountTp);
				}
				if (g_fPersonalRecordPro[client]<=0.0)
				{
						Format(szProTime, 32, "NONE");
				}

				else
				{
					g_bMissedProBest[client] = false;
					FormatTimeFloat(client, g_fPersonalRecordPro[client], 3, szTime, sizeof(szTime));
					Format(szProTime, 32, "%s (#%i/%i)", szTime,g_MapRankPro[client],g_MapTimesCountPro);
				}

				g_bOverlay[client]=true;
				g_fLastOverlay[client] = GetEngineTime()-2.5;

				if (act)
				{
					PrintHintText(client,"%t", "TimerStarted1", szProTime,szTpTime);
				}

				else
				{
					PrintHintText(client,"%t", "TimerStarted2", szProTime,szTpTime);
				}
			}

			if (g_bFirstButtonTouch[client])
			{
				PrintToChat(client, "%t", "AntiCheatEnabled", RED,WHITE,DARKRED);	
				g_bFirstButtonTouch[client]=false;
				Client_Avg(client, 0);
			}
		}	
	}
	
	//sound
	PlayButtonSound(client);	
	Call_StartForward(g_hFWD_TimerStart);
	Call_PushCell(client);
	Call_Finish();
}

// - Climb Button OnEndPress -
public CL_OnEndTimerPress(int client, bool zone)
{	
	//Format Final Time
	if (IsFakeClient(client) && g_bTimeractivated[client])
	{
		for(new i = 1; i <= MaxClients; i++) 
		{
			if (IsValidClient(i) && !IsPlayerAlive(i))
			{			
				new SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
				if (SpecMode == 4 || SpecMode == 5)
				{		
					new Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");	
					if (Target == client)
					{
						if (Target == g_TpBot)
							PrintToChat(i, "%t", "ReplayFinishingMsg", MOSSGREEN,WHITE,LIMEGREEN,g_szReplayNameTp,GRAY,LIMEGREEN,g_szReplayTimeTp,GRAY);
						else
						if (Target == g_ProBot)
							PrintToChat(i, "%t", "ReplayFinishingMsg", MOSSGREEN,WHITE,LIMEGREEN,g_szReplayName,GRAY,LIMEGREEN,g_szReplayTime,GRAY);
					}
				}					
			}		
		}	
		PlayButtonSound(client);
		g_bTimeractivated[client] = false;	
		return;
	}
	
	if (IsFakeClient(client))
	{
		return;
	}
	
	if (IsPlayerStuck(client))
	{
		return;
	}
	
	static float fLastButtonPushTime[MAXPLAYERS + 1];
	static float fLastActiveButtonPushTime[MAXPLAYERS + 1];
	
	//timer pos
	if (!zone && g_bFirstEndButtonPush[client]
		&& GetGameTime() - g_fLastTeleportTime[client] > TP_TIMER_BLOCK_TIME)
	{
		GetClientAbsOrigin(client, g_fEndButtonPos[client]);
		g_bFirstEndButtonPush[client] = false;
		PlayButtonSound(client);
	}
	else if (GetEngineTime() - fLastButtonPushTime[client] > 0.1
		  && GetEngineTime() - fLastActiveButtonPushTime[client] > 2.0)
	{
		PlayButtonSound(client);
	}
	
	fLastButtonPushTime[client] = GetEngineTime();

	if (!g_bTimeractivated[client]) 
	{
		return;
	}
	
	fLastActiveButtonPushTime[client] = GetEngineTime();
	
	//Negative Timer Fix
	if (g_fCurrentRunTime[client] < -1)
	{
		PrintToChat(client, "[%cKZ%c] Your time was less than 0 seconds (invalid)", RED, WHITE);
		g_bTimeractivated[client] = false;
		return;
	}

	// Prevent times shorter than 5 ticks!
	if (g_fCurrentRunTime[client] <= (5 * GetTickInterval()))
	{
		PrintToChat(client, "[%cKZ%c] Your time was less than 5 ticks (invalid)", RED, WHITE);
		g_bTimeractivated[client] = false;
		return;
	}

	//Final time if finishing paused
	if(g_bPause[client] && g_bTimeractivated[client])
	{
		g_fPauseTime[client] = GetEngineTime() - g_fStartPauseTime[client];
		g_fFinalTime[client] = GetEngineTime() - g_fStartTime[client] - g_fPauseTime[client];
		g_Tp_Final[client] = g_OverallTp[client];
		g_bTimeractivated[client] = false;
		Client_Pause(client, 0);  // Unpauses player so he doesnt get stuck in pause
	}

	//Final time if not finishing paused
	if(!g_bPause[client] && g_bTimeractivated[client])
	{
		g_fFinalTime[client] = GetEngineTime() - g_fStartTime[client] - g_fPauseTime[client];
		g_Tp_Final[client] = g_OverallTp[client];
		g_bTimeractivated[client] = false;
	}
	
	//decl
	new String:szName[MAX_NAME_LENGTH];	
	new String:szNameOpponent[MAX_NAME_LENGTH];	
	new String:szTime[32];
	new String:mapname[128];
	Format(mapname, 128, "%s", g_szMapName);
	new bool:bNewrecord;
	new bool:hasRecord=false;
	new Float: difference;
	g_FinishingType[client] = -1;
	g_Sound_Type[client] = -1;
	g_bMapRankToChat[client] = true;
	if (!IsValidClient(client))
		return;	
	GetClientName(client, szName, MAX_NAME_LENGTH);	
	FormatTimeFloat(client, g_fFinalTime[client], 3, szTime, sizeof(szTime));
	Format(g_szFinalTime[client], 32, "%s", szTime);
	g_bOverlay[client]=true;
	g_fLastOverlay[client] = GetEngineTime();
	PrintHintText(client,"%t", "TimerStopped", g_szFinalTime[client]);
	
	//calc difference
	if (g_Tp_Final[client]==0)
	{
		if (g_fPersonalRecordPro[client] > 0.0)
		{
			hasRecord=true;
			difference = g_fPersonalRecordPro[client] - g_fFinalTime[client];
			FormatTimeFloat(client, difference, 3, szTime, sizeof(szTime));
		}
		else
		{
			g_pr_finishedmaps_pro[client]++;
		}
		
	}
	else
	{
		if (g_fPersonalRecord[client] > 0.0 && g_Tp_Final[client] > 0)
		{		
			hasRecord=true;
			difference = g_fPersonalRecord[client]-g_fFinalTime[client];
			FormatTimeFloat(client, difference, 3,szTime,sizeof(szTime));
		}	
		else
		{
			g_pr_finishedmaps_tp[client]++;
		}
	}
	new bool: newbest;
	if (hasRecord)
	{
		if (difference > 0.0)
		{
			if (g_ExtraPoints > 0)
				g_pr_multiplier[client]+=1;
			Format(g_szTimeDifference[client], 32, "-%s", szTime);
			newbest=true;
		}
		else
			Format(g_szTimeDifference[client], 32, "+%s", szTime);
	}
	
	//Type of time
	if (!hasRecord)
	{
		if (g_Tp_Final[client]>0)
		{
			g_Time_Type[client] = 0;
			g_MapTimesCountTp++;
		}
		else
		{
			g_Time_Type[client] = 1;
			g_MapTimesCountPro++;
		}
	}
	else
	{
		if (difference> 0.0)
		{
			if (g_Tp_Final[client]>0)
				g_Time_Type[client] = 2;
			else
				g_Time_Type[client] = 3;
		}
		else
		{
			if (g_Tp_Final[client]>0)
				g_Time_Type[client] = 4;
			else
				g_Time_Type[client] = 5;
		}
	}
	
	if (gB_KZTimerAPI)
	{
		if (!g_bPositionRestored[client] && !g_global_DoubleDuck[client] && 
			!g_global_SelfBuiltButtons && !g_bFlagged[client] &&
			g_global_Enforcer[client] &&
			g_fFinalTime[client] > 5.0)
			{
				KZTimerAPI_InsertRecord(client, g_Tp_Final[client], g_fFinalTime[client]);
			}
	
			else
			{
				PrintToChat(client, "[KZ-API] Time not registered to API! [Settings dont match!]");
			}
	}
	
	//NEW PRO RECORD
	if((g_fFinalTime[client] < g_fRecordTimePro) && g_Tp_Final[client] <= 0)
	{
		bNewrecord=true;
		if (g_FinishingType[client] != 3 && g_FinishingType[client] != 4 && g_FinishingType[client] != 5)
			g_FinishingType[client] = 2;
		g_fRecordTimePro = g_fFinalTime[client]; 
		Format(g_szRecordPlayerPro, MAX_NAME_LENGTH, "%s", szName);
		if (g_Sound_Type[client] != 1)
			g_Sound_Type[client] = 2;
		
		if (g_fFinalTime[client] < g_fRecordTime)		
			SetupRouteArrays(client);
		
		//save replay	
		if (g_bReplayBot && !g_bPositionRestored[client])
		{
			g_bNewReplay[client]=true;
			CreateTimer(3.0, ProReplayTimer, client,TIMER_FLAG_NO_MAPCHANGE);
		}
		db_InsertLatestRecords(g_szSteamID[client], szName, g_fFinalTime[client], g_Tp_Final[client]);	
	} 
	
	//NEW TP RECORD
	if((g_fFinalTime[client] < g_fRecordTime) && g_Tp_Final[client] > 0)
	{
		bNewrecord=true;
		if (g_FinishingType[client] != 3 && g_FinishingType[client] != 4 && g_FinishingType[client] != 5)
			g_FinishingType[client] = 1;
		g_fRecordTime = g_fFinalTime[client];
		Format(g_szRecordPlayer, MAX_NAME_LENGTH, "%s", szName);
		if (g_Sound_Type[client] != 1)
			g_Sound_Type[client] = 3;
			
		if (g_fFinalTime[client] < g_fRecordTimePro)		
			SetupRouteArrays(client);
			
		//save replay	
		if (g_bReplayBot && !g_bPositionRestored[client])
		{
			g_bNewReplay[client]=true;
			CreateTimer(3.0, TpReplayTimer, client,TIMER_FLAG_NO_MAPCHANGE);
		}
		db_InsertLatestRecords(g_szSteamID[client], szName, g_fFinalTime[client], g_Tp_Final[client]);	
	}
	
	Call_StartForward(g_hFWD_TimerStopped);
	Call_PushCell(client);
	Call_PushCell(g_Tp_Final[client]);
	Call_PushFloat(g_fFinalTime[client]);
	Call_PushCell(bNewrecord);
	Call_Finish();
		
	if (newbest && g_Sound_Type[client] == -1)
		g_Sound_Type[client] = 5;
		
	//Challenge
	if (g_bChallenge[client])
	{
		SetEntityRenderColor(client, 255,255,255,g_TransPlayerModels);		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != client && i != g_ProBot && i != g_TpBot)
			{				
				if (StrEqual(g_szSteamID[i],g_szChallenge_OpponentID[client]))
				{	
					g_bChallenge[client]=false;
					g_bChallenge[i]=false;
					SetEntityRenderColor(i, 255,255,255,g_TransPlayerModels);
					db_insertPlayerChallenge(client);
					GetClientName(i, szNameOpponent, MAX_NAME_LENGTH);	
					for (new k = 1; k <= MaxClients; k++)
						if (IsValidClient(k))
							PrintToChat(k, "%t", "ChallengeW", RED,WHITE,MOSSGREEN,szName,WHITE,MOSSGREEN,szNameOpponent,WHITE); 			
					if (g_Challenge_Bet[client]>0)
					{										
						new lostpoints = g_Challenge_Bet[client] * g_pr_PointUnit;
						for (new j = 1; j <= MaxClients; j++)
							if (IsValidClient(j))
								PrintToChat(j, "%t", "ChallengeL", MOSSGREEN, WHITE, PURPLE,szNameOpponent, GRAY, RED, lostpoints,GRAY);		
						CreateTimer(0.5, UpdatePlayerProfile, i,TIMER_FLAG_NO_MAPCHANGE);
						g_pr_showmsg[client] = true;
					}					
					break;
				}
			}
		}		
	}
	
	//set mvp star
	g_MVPStars[client] += 1;
	CS_SetMVPCount(client,g_MVPStars[client]);		
	
	//local db update
	if ((g_fFinalTime[client] < g_fPersonalRecord[client] && g_Tp_Final[client] > 0 || g_fPersonalRecord[client] <= 0.0 && g_Tp_Final[client] > 0) || (g_fFinalTime[client] < g_fPersonalRecordPro[client] && g_Tp_Final[client] == 0 || g_fPersonalRecordPro[client] <= 0.0 && g_Tp_Final[client] == 0))
	{
		g_pr_showmsg[client] = true;
		db_selectRecord(client, mapname);
	}
	else
	{
		if (g_Tp_Final[client] > 0)
			db_viewMapRankTp(client);
		else
			db_viewMapRankPro(client);
	}

	
	if (!(g_bMomsurffixAvailable
		&& !g_global_DoubleDuck[client]
		&& g_global_Enforcer[client]
		&& !g_global_SelfBuiltButtons
		&& !g_bPositionRestored[client]
		&& !g_bFlagged[client]
		&& g_fFinalTime[client] > 5.0))
	{
		if(StrEqual(g_szMapPrefix[0],"kz") || StrEqual(g_szMapPrefix[0],"xc") || StrEqual(g_szMapPrefix[0],"bkz")  || StrEqual(g_szMapPrefix[0],"kzpro"))
		{
			if (g_global_SelfBuiltButtons)
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Self-built climb buttons detected. (only built-in buttons supported)%c",MOSSGREEN, WHITE, RED, WHITE);
			else
			if (!g_bEnforcer)
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kz_settings_enforcer is disabled.%c",MOSSGREEN, WHITE, RED, WHITE);
			else
			if (g_bFlagged[client])
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Bhop script detected%c",MOSSGREEN, WHITE, RED, WHITE);
			else
			if (g_iDoubleDuckCvar == 1)
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kz_double_duck is set to 1.%c",MOSSGREEN, WHITE, RED, WHITE);
			else
			if (!g_global_Enforcer[client])
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kz_settings_enforcer was disabled during your run.%c",MOSSGREEN, WHITE, RED, WHITE);
			else
			if (g_global_DoubleDuck[client])
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kz_double_duck was enabled during your run.%c",MOSSGREEN, WHITE, RED, WHITE);
			else
			if (g_bPositionRestored[client] || g_bGlobalDisconnected[client])
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Reconnecting is not allowed.%c",MOSSGREEN, WHITE, RED, WHITE);
			else if (!g_bMomsurffixAvailable)
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kztimer-momsurffix is not available.",MOSSGREEN,WHITE,RED);
		}
	}	
}

static bool IsPlayerStuck(int client)
{
	float vecMin[3];
	float vecMax[3];
	float vecOrigin[3];
	
	GetClientMins(client, vecMin);
	GetClientMaxs(client, vecMax);
	GetClientAbsOrigin(client, vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_PLAYERSOLID, TraceEntityFilterPlayer);
	return TR_DidHit();
}