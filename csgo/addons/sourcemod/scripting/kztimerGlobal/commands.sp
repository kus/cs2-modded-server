public Action:Client_Stopsound(client, args)
{
	if (IsValidClient(client))
	{
		ClientCommand(client,"snd_playsounds Music.StopAllExceptMusic");
		PrintToChat(client, "%t", "stopsound", MOSSGREEN,WHITE);
	}
	return Plugin_Handled;
}

public Action Client_PersonalBest(int client, int args)
{
	if (IsValidClient(client))
	{
		PrintToChat(client, "[%cKZ%c] Your personal bests for current map:", MOSSGREEN, WHITE);

		if (g_fPersonalRecordPro[client] <= 0.0 && g_fPersonalRecord[client] <= 0.0)
		{
			PrintToChat(client, "[%cKZ%c] %cPRO Time%c: NONE", MOSSGREEN, WHITE, DARKBLUE, WHITE);
			PrintToChat(client, "[%cKZ%c] %cTP Time%c: NONE", MOSSGREEN, WHITE, YELLOW, WHITE);
		}

		else
		{
			if (g_fPersonalRecordPro[client] <= 0.0)
			{
				char formattedTime[32];
				FormatTimeFloat(client, g_fPersonalRecord[client], 3, formattedTime, sizeof(formattedTime));

				PrintToChat(client, "[%cKZ%c] %cPRO Time%c: NONE", MOSSGREEN, WHITE, DARKBLUE, WHITE);
				PrintToChat(client, "[%cKZ%c] %cTP Time%c: %s (#%d/%d)", MOSSGREEN, WHITE, YELLOW, WHITE, formattedTime, g_MapRankTp[client], g_MapTimesCountTp);
			}

			else if (g_fPersonalRecord[client] <= 0.0)
			{
				char formattedTime[32];
				FormatTimeFloat(client, g_fPersonalRecordPro[client], 3, formattedTime, sizeof(formattedTime));

				PrintToChat(client, "[%cKZ%c] %cPRO Time%c: %s (#%d/%d)", MOSSGREEN, WHITE, DARKBLUE, WHITE, formattedTime, g_MapRankPro[client], g_MapTimesCountPro);
				PrintToChat(client, "[%cKZ%c] %cTP Time%c: NONE", MOSSGREEN, WHITE, YELLOW, WHITE);
			}

			else
			{
				char formattedTime[32];
				char formattedTimePro[32];
				FormatTimeFloat(client, g_fPersonalRecord[client], 3, formattedTime, sizeof(formattedTime));
				FormatTimeFloat(client, g_fPersonalRecordPro[client], 3, formattedTimePro, sizeof(formattedTimePro));

				PrintToChat(client, "[%cKZ%c] %cPRO Time%c: %s (#%d/%d)", MOSSGREEN, WHITE, DARKBLUE, WHITE, formattedTimePro, g_MapRankPro[client], g_MapTimesCountPro);
				PrintToChat(client, "[%cKZ%c] %cTP Time%c: %s (#%d/%d)", MOSSGREEN, WHITE, YELLOW, WHITE, formattedTime, g_MapRankTp[client], g_MapTimesCountTp);
			}
		}
	}
	return Plugin_Handled;
}


// TODO Make these into translations
public Action Client_ToggleGoto(int client, int args)
{
	DisableGoTo(client);

	if (!g_bGoToClient[client]) {
		PrintToChat(client, "[%cKZ%c] Goto'ing to you is now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
	}

	else {
		PrintToChat(client, "[%cKZ%c] Goto'ing to you is now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleErrorSounds(int client, int args)
{
	DisableSounds(client);

	if (!g_bErrorSounds[client]) {
		PrintToChat(client, "[%cKZ%c] Error sounds are now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
	}

	else {
		PrintToChat(client, "[%cKZ%c] Error sounds are now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleTimerText(int client, int args)
{
	ShowTime(client);

	if (!g_bShowTime[client]) {
		PrintToChat(client, "[%cKZ%c] Timer text is now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
	}

	else {
		PrintToChat(client, "[%cKZ%c] Timer text is now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleSpeclist(int client, int args)
{
	HideSpecs(client);

	switch(g_ShowSpecs[client])
	{
		case 0: PrintToChat(client, "[%cKZ%c] Spec list is now set to %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
		case 1: PrintToChat(client, "[%cKZ%c] Spec list is now set to %ccount only%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
		case 2: PrintToChat(client, "[%cKZ%c] Spec list is now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleStartWeapon(int client, int args)
{
	SwitchStartWeapon(client);

	if (!g_bStartWithUsp[client]) {
		PrintToChat(client, "[%cKZ%c] Starting weapon is now %cknife%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	else {
		PrintToChat(client, "[%cKZ%c] Starting weapon is now %cusp%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleMenuSounds(int client, int args)
{
	ClimbersMenuSounds(client);

	if (!g_bClimbersMenuSounds[client]) {
		PrintToChat(client, "[%cKZ%c] Menu sounds are now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
	}

	else {
		PrintToChat(client, "[%cKZ%c] Menu sounds are now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleQuakeSounds(int client, int args)
{
	QuakeSounds(client);

	switch(g_EnableQuakeSounds[client])
	{
		case 0: PrintToChat(client, "[%cKZ%c] Quake sounds are now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
		case 1: PrintToChat(client, "[%cKZ%c] Quake sounds are now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
		case 2: PrintToChat(client, "[%cKZ%c] Quake sounds are now set to %cgodlikes+ & records only%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
		case 3: PrintToChat(client, "[%cKZ%c] Quake sounds are now set to %crecords only%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleCPDoneMessage(int client, int args)
{
	CPMessage(client);

	if (!g_bCPTextMessage[client]) {
		PrintToChat(client, "[%cKZ%c] Checkpoint done messages are now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
	}

	else {
		PrintToChat(client, "[%cKZ%c] Checkpoint done messages are now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleAdvInfoPanel(int client, int args)
{
	AdvInfoPanel(client);

	if (!g_bAdvInfoPanel[client]) {
		PrintToChat(client, "[%cKZ%c] Advanced Info panel is now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
	}

	else {
		PrintToChat(client, "[%cKZ%c] Advanced Info panel is now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Client_ToggleJumpstatsColorChat(int client, int args)
{
	ColorChat(client);

	switch(g_ColorChat[client])
	{
		case 0: PrintToChat(client, "[%cKZ%c] Jumpstats color chat is now %cdisabled%c", MOSSGREEN, WHITE, RED, WHITE);
		case 1: PrintToChat(client, "[%cKZ%c] Jumpstats color chat is now %cenabled%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
		case 2: PrintToChat(client, "[%cKZ%c] Jumpstats color chat is now set to %cgodlikes+ & records only%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
		case 3: PrintToChat(client, "[%cKZ%c] Jumpstats color chat is now set to %cnone (except yours)%c", MOSSGREEN, WHITE, LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action:Command_Specs(client, args)
{
	new count;
	decl String:szNameList[1024];
	Format(szNameList,1024,"");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || IsPlayerAlive(i))
			continue;
		if (GetClientTeam(i) == 1)
		{
			decl String:clientname[16];
			GetClientName(i,clientname,16);
			if (StrEqual(szNameList,""))
				Format(szNameList,1024,"%s",clientname);
			else
				Format(szNameList,1024,"%s%c;%c %s",szNameList, MOSSGREEN,WHITE,clientname);
			count++;
		}
	}
	if (count > 0)
		PrintToChat(client, "%t", "SpectatorMessage1", YELLOW,GRAY,LIMEGREEN,count,GRAY,WHITE,szNameList);
	else
		PrintToChat(client, "%t", "SpectatorMessage2", YELLOW,GRAY,LIMEGREEN,count,GRAY);

	return Plugin_Handled;
}


public Action:Client_RankingSystem(client, args)
{
	PrintToChat(client, "%t", "RankingSystem", MOSSGREEN,WHITE,LIMEGREEN);
	ShowMOTDPanel(client, "rankingsystem" ,"http://kuala-lumpur-court-8417.pancakeapps.com/ranking_index.html", 2);
	return Plugin_Handled;
}

public Action:Client_Ljblock(client, args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
		LJBlockMenu(client);
	return Plugin_Handled;
}

public Action:Client_Wr(client, args)
{
	if (IsValidClient(client))
	{
		if (g_fGlobalRecordTp_Time == 9999999.0 && g_fGlobalRecordPro_Time == 9999999.0 && g_fRecordTimePro == 9999999.0 && g_fRecordTime == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", MOSSGREEN,WHITE);
		else
			PrintMapRecords(client);
	}
	return Plugin_Handled;
}

public Action:Client_MapTier(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	else
	{
		if(gB_KZTimerAPI)
		{
			KZTimerAPI_PrintMapTier(client);
		}
		PrintMapTier(client);
	}
	return Plugin_Handled;
}

public Action:Client_TierHelp(client, args)
{
	if (IsValidClient(client))
	{
		PrintToChat(client,"[%cKZ%c]%c Loading html page.. (requires cl_disablehtmlmotd 0)", MOSSGREEN,WHITE,LIMEGREEN);
		ShowMOTDPanel(client, "TierInfo" ,"http://tokyo-lane-2453.pancakeapps.com/TierInfo.html", 2);
	}

	return Plugin_Handled;
}


public LJBlockMenu(client)
{
	decl String:buffer[32];
	new Handle:ljblockmenu = CreateMenu(LjBlockMenuHandler);
	Format(buffer, sizeof(buffer), "%T", "BlockMenuTitle", client);
	SetMenuTitle(ljblockmenu, buffer); 
	Format(buffer, sizeof(buffer), "%T", "BlockMenu_SelectDest", client);
	AddMenuItem(ljblockmenu, "0", buffer);
	Format(buffer, sizeof(buffer), "%T", "BlockMenu_ResetDest", client);
	AddMenuItem(ljblockmenu, "0", buffer);
	SetMenuOptionFlags(ljblockmenu, MENUFLAG_BUTTON_EXIT);
	g_bMenuOpen[client]=true;
	DisplayMenu(ljblockmenu, client, MENU_TIME_FOREVER);
}

public LjBlockMenuHandler(Handle:ljblockmenu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			Function_BlockJump(client);
			LJBlockMenu(client);
		}
		else if(select == 1)
		{
			g_bLJBlock[client] = false;
			LJBlockMenu(client);
		}
	}
}

public Action:Client_Flashlight(client, args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
		SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
	return Plugin_Handled;
}


//MACRODOX BHOP PROTECTION
//https://forums.alliedmods.net/showthread.php?p=1678026
public Action:Command_Stats(client, args)
{
	if (args < 1)
	{
	ReplyToCommand(client, "%t", "Macrodox_Usage", MOSSGREEN,WHITE);
	return Plugin_Handled;
	}
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	if ((target_count = ProcessTargetString(
	arg,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_NO_IMMUNITY,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
	PrintToConsole(client, "%t", "Macrodox_InvalidParam");
	return Plugin_Handled;
	}
	if (target_count > 3)
	PrintToChat(client, "%t", "MacrodoxOutput", MOSSGREEN,WHITE);
	for (new i = 0; i < target_count; i++)
	{
	if (target_count > 3)
	PerformStats(client, target_list[i],true);
	else
	PerformStats(client, target_list[i],false);
	}
	return Plugin_Handled;
}

public Action:Client_Challenge(client, args)
{
	if (!g_bChallenge[client] && !g_bChallenge_Request[client])
	{
		if(IsPlayerAlive(client))
		{
			g_bMenuOpen[client]=true;
			new Handle:challengemenu = CreateMenu(ChallengeMenuHandler1);
			decl String:buffer[128];
			if (g_bAllowCheckpoints)
			{
				SetMenuTitle(challengemenu, "%T", "Challenge_TitleCP", client);
				Format(buffer, sizeof(buffer), "%T", "Challenge_CP_YES", client);
				AddMenuItem(challengemenu, "Yes", buffer);
			}
			else
			{
				SetMenuTitle(challengemenu, "%T", "Challenge_TitleNoCP", client);
			}

			Format(buffer, sizeof(buffer), "%T", "Challenge_CP_No", client);
			AddMenuItem(challengemenu, "No", buffer);
			SetMenuOptionFlags(challengemenu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(challengemenu, client, MENU_TIME_FOREVER);
		}
		else
			PrintToChat(client, "%t", "ChallengeFailed1",RED,WHITE);
	}
	else
		PrintToChat(client, "%t", "ChallengeFailed3",RED,WHITE);
	return Plugin_Handled;
}

public ChallengeMenuHandler1(Handle:challengemenu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:buffer[64];
		GetMenuItem(challengemenu, param2, info, sizeof(info));
		if(StrEqual(info,"Yes"))
			g_bChallenge_Checkpoints[param1]=true;
		else
			g_bChallenge_Checkpoints[param1]=false;
		new Handle:menu2 = CreateMenu(ChallengeMenuHandler2);
		g_bMenuOpen[param1]=true;
		decl String:tmp[64];
		if (g_bPointSystem && g_bChallengePoints)
			Format(tmp, 64, "%T", "Challenge_Bets", param1, g_pr_points[param1]);
		else
			Format(tmp, 64, "%T", "Challenge_PointsDisabled", param1, g_pr_points[param1]);
		SetMenuTitle(menu2, tmp);
		Format(buffer, sizeof(buffer), "%T", "Challenge_NoBet", param1);
		AddMenuItem(menu2, "0", buffer);
		if (g_bPointSystem && g_bChallengePoints)
		{
			Format(tmp, 64, "%i", g_pr_PointUnit*50);
			if (g_pr_PointUnit*5  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);
			Format(tmp, 64, "%i", (g_pr_PointUnit*100));
			if ((g_pr_PointUnit*10)  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);
			Format(tmp, 64, "%i", (g_pr_PointUnit*250));
			if ((g_pr_PointUnit*25)  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);
			Format(tmp, 64, "%i", (g_pr_PointUnit*500));
			if ((g_pr_PointUnit*50)  <= g_pr_points[param1])
				AddMenuItem(menu2, tmp, tmp);
		}
		SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(challengemenu);
	}
}

public ChallengeMenuHandler2(Handle:challengemenu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(challengemenu, param2, info, sizeof(info));
		new value = StringToInt(info);
		if (value == g_pr_PointUnit*50)
			g_Challenge_Bet[param1] = 50;
		else
			if (value == (g_pr_PointUnit*100))
				g_Challenge_Bet[param1] = 100;
			else
				if (value == (g_pr_PointUnit*250))
					g_Challenge_Bet[param1] = 250;
				else
					if (value == (g_pr_PointUnit*500))
						g_Challenge_Bet[param1] = 500;
					else
						g_Challenge_Bet[param1] = 0;
		decl String:szPlayerName[MAX_NAME_LENGTH];
		new Handle:menu2 = CreateMenu(ChallengeMenuHandler3);
		SetMenuTitle(menu2, "%T", "Challenge_SelectOpponent", param1);
		new playerCount=0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1  && !IsFakeClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				AddMenuItem(menu2, szPlayerName, szPlayerName);
				playerCount++;
			}
		}
		if (playerCount>0)
		{
			g_bMenuOpen[param1]=true;
			SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
		}
		else
		{
			PrintToChat(param1, "%t", "ChallengeFailed4",MOSSGREEN,WHITE);
		}

	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(challengemenu);
	}
}

public ChallengeMenuHandler3(Handle:challengemenu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		decl String:szTargetName[MAX_NAME_LENGTH];
		GetClientName(param1, szPlayerName, MAX_NAME_LENGTH);
		GetMenuItem(challengemenu, param2, info, sizeof(info));
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
			{
				GetClientName(i, szTargetName, MAX_NAME_LENGTH);

				if(StrEqual(info,szTargetName))
				{
					if (!g_bChallenge[i])
					{
						if ((g_pr_PointUnit*g_Challenge_Bet[param1]) <= g_pr_points[i])
						{
							//id of challenger
							decl String:szSteamId[32];
							GetClientAuthId(i, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
							Format(g_szChallenge_OpponentID[param1], 32, szSteamId);
							decl String:cp[16];
							if (g_bChallenge_Checkpoints[param1])
								Format(cp, 16, " allowed");
							else
								Format(cp, 16, " forbidden");
							new value = g_pr_PointUnit * g_Challenge_Bet[param1];
							PrintToChat(param1, "%t", "Challenge1", RED,WHITE, YELLOW, szTargetName, value,cp);
							//target msg
							EmitSoundToClient(i,"buttons/button15.wav",i);
							PrintToChat(i, "%t", "Challenge2", RED,WHITE, YELLOW, szPlayerName, GREEN, WHITE, value,cp);
							g_fChallenge_RequestTime[param1] = GetEngineTime();
							g_bChallenge_Request[param1]=true;
						}
						else
						{
							PrintToChat(param1, "%t", "ChallengeFailed5", RED,WHITE, szTargetName, g_pr_points[i]);
						}
					}
					else
						PrintToChat(param1, "%t", "ChallengeFailed6", RED,WHITE, szTargetName);
				}
			}
		}
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(challengemenu);
	}
}

public Action:Client_Abort(client, args)
{
	if (g_bChallenge[client])
	{
		if (g_bChallenge_Abort[client])
		{
			g_bChallenge_Abort[client]=false;
			PrintToChat(client, "%t", "Challenge_Disagree_Abort", RED, WHITE);
		}
		else
		{
			g_bChallenge_Abort[client]=true;
			PrintToChat(client, "%t", "Challenge_Agree_Abort", RED, WHITE);
		}
	}
	return Plugin_Handled;
}

public Action:Client_Accept(client, args)
{
	decl String:szSteamId[32];
	decl String:szCP[32];
	GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && i != client && g_bChallenge_Request[i])
		{
			if(StrEqual(szSteamId,g_szChallenge_OpponentID[i]))
			{
				GetClientAuthId(i, AuthId_Steam2, g_szChallenge_OpponentID[client], 32, true);
				g_bChallenge_Request[i]=false;
				g_bChallenge[i]=true;
				g_bChallenge[client]=true;
				g_bChallenge_Abort[client]=false;
				g_bChallenge_Abort[i]=false;
				g_Challenge_Bet[client] = g_Challenge_Bet[i];
				g_bChallenge_Checkpoints[client] = g_bChallenge_Checkpoints[i];

				g_fTeleportValidationTime[client] = GetEngineTime();
				CS_RespawnPlayer(client);
				SetEntityMoveType(client, MOVETYPE_NONE);
				CreateTimer(0.5, SetChallengeSpawnPoint, i,TIMER_FLAG_NO_MAPCHANGE);

				g_CountdownTime[i] = 10;
				g_CountdownTime[client] = 10;
				CreateTimer(1.0, Timer_Countdown, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, Timer_Countdown, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				PrintToChat(client, "%t", "Challenge3",RED,WHITE, YELLOW);
				PrintToChat(i, "%t", "Challenge3",RED,WHITE, YELLOW);
				decl String:szPlayer1[MAX_NAME_LENGTH];
				decl String:szPlayer2[MAX_NAME_LENGTH];
				GetClientName(i, szPlayer1, MAX_NAME_LENGTH);
				GetClientName(client, szPlayer2, MAX_NAME_LENGTH);

				if (g_bChallenge_Checkpoints[i])
					Format(szCP, sizeof(szCP), "Allowed");
				else
					Format(szCP, sizeof(szCP), "Forbidden");
				new points = g_Challenge_Bet[i]*2*g_pr_PointUnit;
				PrintToChatAll("%t", "Challenge5", RED,WHITE,MOSSGREEN,szPlayer1,WHITE,MOSSGREEN,szPlayer2,WHITE);
				PrintToChatAll("%t", "Challenge6", RED,WHITE,GRAY,szCP,WHITE,GRAY,points);

				new r1 = GetRandomInt(55, 255);
				new r2 = GetRandomInt(55, 255);
				new r3 = GetRandomInt(0, 55);
				SetEntityRenderColor(i, r1, r2, r3, g_TransPlayerModels);
				SetEntityRenderColor(client, r1, r2, r3, g_TransPlayerModels);
				g_bTimeractivated[client] = false;
				g_bTimeractivated[i] = false;
				g_fPlayerCordsUndoTp[i][0] = 0.0;
				g_fPlayerCordsUndoTp[i][1] = 0.0;
				g_fPlayerCordsUndoTp[i][2] = 0.0;
				g_CurrentCp[i] = -1;
				g_CounterCp[i] = 0;
				g_OverallCp[i] = 0;
				g_OverallTp[i] = 0;
				g_fPlayerCordsUndoTp[client][0] = 0.0;
				g_fPlayerCordsUndoTp[client][1] = 0.0;
				g_fPlayerCordsUndoTp[client][2] = 0.0;
				g_CurrentCp[client] = -1;
				g_CounterCp[client] = 0;
				g_OverallCp[client] = 0;
				g_OverallTp[client] = 0;
				CreateTimer(1.0, CheckChallenge, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, CheckChallenge, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	return Plugin_Handled;
}

public Action:Client_Avg(client, args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;

	decl String:szTpTime[32];
	FormatTimeFloat(client, g_favg_tptime, 3, szTpTime, sizeof(szTpTime));
	decl String:szProTime[32];
	FormatTimeFloat(client, g_favg_protime, 3, szProTime, sizeof(szProTime));

	if (g_MapTimesCountPro==0)
		Format(szProTime,32,"00:00:00");
	if (g_MapTimesCountTp==0)
		Format(szTpTime,32,"00:00:00");
	PrintToChat(client, "%t", "AvgTime", MOSSGREEN,WHITE,GRAY,DARKBLUE,WHITE,szProTime,g_MapTimesCountPro,YELLOW,WHITE,szTpTime,g_MapTimesCountTp);
	return Plugin_Handled;
}


public Action:Client_HideWeapon(client, args)
{
	HideViewModel(client);
	if (g_bViewModel[client])
		PrintToChat(client, "%t", "HideViewModel2",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "HideViewModel1",MOSSGREEN, WHITE);
	return Plugin_Handled;
}

public HideViewModel(client)
{
	if (!g_bViewModel[client])
	{
		g_bViewModel[client]=true;
		Client_SetDrawViewModel(client,true);
	}
	else
	{
		g_bViewModel[client]=false;
		Client_SetDrawViewModel(client,false);
	}
}

public Action:Client_Usp(client, args)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Handled;

	if(Client_HasWeapon(client, "weapon_hkp2000"))
	{
		new weapon = Client_GetWeapon(client, "weapon_hkp2000");
		InstantSwitch(client, weapon);
	}
	else
		GivePlayerItem(client, "weapon_usp_silencer");
	return Plugin_Handled;
}

InstantSwitch(client, weapon, timer = 0)
{
	if (weapon==-1)
		return;

	new Float:GameTime = GetGameTime();
	if (!timer && IsValidClient(client))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GameTime);
	}
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GameTime);
	new ViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	SetEntProp(ViewModel, Prop_Send, "m_nSequence", 0);
}

public Action:Client_Surrender (client, args)
{
	decl String:szSteamIdOpponent[32];
	decl String:szNameOpponent[MAX_NAME_LENGTH];
	decl String:szName[MAX_NAME_LENGTH];
	if (g_bChallenge[client])
	{
		GetClientName(client, szName, MAX_NAME_LENGTH);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != client)
			{
				GetClientAuthId(i, AuthId_Steam2, szSteamIdOpponent, sizeof(szSteamIdOpponent), true);
				if (StrEqual(szSteamIdOpponent,g_szChallenge_OpponentID[client]))
				{
					GetClientName(i, szNameOpponent, MAX_NAME_LENGTH);
					g_bChallenge[i]=false;
					g_bChallenge[client]=false;
					db_insertPlayerChallenge(i);
					SetEntityRenderColor(i, 255,255,255,g_TransPlayerModels);
					SetEntityRenderColor(client, 255,255,255,g_TransPlayerModels);

					//msg
					for (new j = 1; j <= MaxClients; j++)
					{
						if (IsValidClient(j) && IsValidEntity(j))
						{
								PrintToChat(j, "%t", "Challenge4",RED,WHITE,MOSSGREEN,szNameOpponent, WHITE,MOSSGREEN,szName,WHITE);
						}
					}
					//win ratio
					SetEntityMoveType(client, MOVETYPE_WALK);
					SetEntityMoveType(i, MOVETYPE_WALK);

					if (g_Challenge_Bet[client] > 0)
					{
						g_pr_showmsg[i] = true;
						PrintToChat(i, "%t", "Rc_PlayerRankStart", MOSSGREEN,WHITE,GRAY);
						PrintToChat(client, "%t", "Rc_PlayerRankStart", MOSSGREEN,WHITE,GRAY);
						new lostpoints = g_Challenge_Bet[client] * g_pr_PointUnit;
						for (new j = 1; j <= MaxClients; j++)
							if (IsValidClient(j) && IsValidEntity(j))
								PrintToChat(j, "%t", "Challenge_Lost_Points", MOSSGREEN, WHITE, PURPLE,szName, GRAY, RED, lostpoints,GRAY);
					}
					//db update
					CreateTimer(0.0, UpdatePlayerProfile, i,TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.5, UpdatePlayerProfile, client,TIMER_FLAG_NO_MAPCHANGE);
					i = MaxClients+1;
				}
			}
		}
	}
	return Plugin_Handled;
}

//public Action:Command_ext_Menu(client, String:command[32])
public Action:Command_ext_Menu(client, const String:command[], argc)
{
	StopClimbersMenu(client);
	return Plugin_Handled;
}

public StopClimbersMenu(client)
{

	g_bMenuOpen[client] = true;
	if (g_hclimbersmenu[client] != INVALID_HANDLE)
	{
		g_hclimbersmenu[client] = INVALID_HANDLE;
	}
	if (g_bClimbersMenuOpen[client])
		g_bClimbersMenuwasOpen[client]=true;
	else
		g_bClimbersMenuwasOpen[client]=false;
	g_bClimbersMenuOpen[client] = false;
}

//https://forums.alliedmods.net/showthread.php?t=206308
public Action:Command_JoinTeam(client, const String:command[], argc)
{
	if(!IsValidClient(client) || argc < 1)
		return Plugin_Handled;

	if (g_bCantJoin[client])
	{
		PrintToChat(client, "[%cKZ%c] You cant join a team so soon!", MOSSGREEN, WHITE);
		return Plugin_Handled;
	}

	decl String:arg[4];
	GetCmdArg(1, arg, sizeof(arg));
	new toteam = StringToInt(arg);

	// Check if valid team (HUGE thanks to Fusion! <3) 
 	if (toteam != CS_TEAM_SPECTATOR && toteam != CS_TEAM_CT && toteam != CS_TEAM_T)
 	{
		return Plugin_Handled;
 	}
	
	if (g_Team_Restriction > 0)
	{
		new BadTeam;
		new GoodTeam;
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
		// Get the players current team
		new Current_Team = GetClientTeam(client);

		if (Current_Team == toteam)
		{
			return Plugin_Handled;
		}

		if (Current_Team == BadTeam && toteam == GoodTeam)
		{
			ForcePlayerSuicide(client);
			return Plugin_Continue;
		}

		if (Current_Team == GoodTeam && toteam == BadTeam)
		{
			return Plugin_Handled;
		}

		if (!((toteam == GoodTeam) || (toteam == BadTeam) || (toteam == CS_TEAM_SPECTATOR)))
		{
			CS_SwitchTeam(client, GoodTeam);
			ForcePlayerSuicide(client);
			g_bCantJoin[client] = true;
			CreateTimer(0.75, TeamDelay, client, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Handled;
		}
	}

	TeamChangeActual(client, toteam);
	return Plugin_Handled;
}

//https://forums.alliedmods.net/showthread.php?t=206308
TeamChangeActual(client, toteam)
{
	if (g_bPause[client])
	{
		PauseMethod(client);
	}

	g_bCantPause[client] = true;
	g_bCantJoin[client] = true;
	CreateTimer(0.1, PauseDelay, client, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.75, TeamDelay, client, TIMER_FLAG_NO_MAPCHANGE);

	// Client is auto-assigning
	if(toteam == 0)
		toteam = GetRandomInt(2, 3);

	if(g_bSpectate[client])
	{
		if(g_fStartTime[client] != -1.0 && g_bTimeractivated[client] == true)
			g_fPauseTime[client] = GetEngineTime() - g_fStartPauseTime[client];

		g_bSpectate[client] = false;
	}

	ChangeClientTeam(client, toteam);
	return;
}

public Action:BlockKill(client, args)
{
	return Plugin_Handled;
}

public Action:Client_OptionMenu(client, args)
{
	StopClimbersMenu(client);
	g_bMenuOpen[client]=true;
	CreateTimer(0.1, OpenOptionsMenu, client,TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action:Client_Next(client, args)
{
	if(g_CurrentCp[client] == -1)
	{
		PrintToChat(client, "%t", "NoCheckpointsFound", MOSSGREEN,WHITE);
		return Plugin_Handled;
	}
	DoTeleport(client,1);
	return Plugin_Handled;
}
public Action:Client_Undo(client, args)
{
	new Float:fLastUndo = GetEngineTime() - g_fLastUndo[client];
	if (IsValidClient(client) && !g_bPause[client] && !g_bInvalidUndoGround[client] && fLastUndo > 1.0)
	{
		if(g_fPlayerCordsUndoTp[client][0] == 0.0 && g_fPlayerCordsUndoTp[client][1] == 0.0 && g_fPlayerCordsUndoTp[client][2] == 0.0)
			return Plugin_Handled;
		if (GetClientDistanceToGround(g_fPlayerCordsUndoTp[client]) < 66.0)
		{
			g_fLastUndo[client] = GetEngineTime();
			DoValidTeleport(client, g_fPlayerCordsUndoTp[client],g_fPlayerAnglesUndoTp[client], Float:{0.0,0.0,-100.0});
			g_js_GODLIKE_Count[client] = 0;
		}
		else
		{
			if (g_bErrorSounds[client])
			{
				EmitSoundToClient(client,"buttons/button10.wav",client);
			}
			PrintToChat(client, "%t", "UndoMidAir",MOSSGREEN, WHITE,RED);
		}
	}
	else
	{
		if (g_bInvalidUndoGround[client])
		{
			if (g_bErrorSounds[client])
			{
				EmitSoundToClient(client,"buttons/button10.wav",client);
			}
			PrintToChat(client, "%t", "UndoLadder",MOSSGREEN, WHITE,RED);
		}
	}
	return Plugin_Handled;
}


public Action:NoClip(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	if (g_bNoClipS || GetUserFlagBits(client) & ADMFLAG_RESERVATION || GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC || StrEqual(g_pr_rankname[client],"MAPPER"))
	{
		if (!g_bMapFinished[client])
		{
			//BEST RANK || ADMIN || VIP || MAPPER
			if ((StrEqual(g_pr_rankname[client],g_szSkillGroups[8]) || StrEqual(g_pr_rankname[client],"MAPPER") || GetUserFlagBits(client) & ADMFLAG_RESERVATION || GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC) && !g_bNoClip[client])
				Action_NoClip(client);
			else
				PrintToChat(client, "%t", "NoclipNotAvailable2",MOSSGREEN, WHITE, g_szSkillGroups[8]);
		}
		else
			if (!g_bNoClip[client])
				Action_NoClip(client);
	}
	else
		if (IsValidClient(client))
			PrintToChat(client, "%t", "NoclipNotAvailable3",MOSSGREEN, WHITE);
	return Plugin_Handled;
}

public Action:UnNoClip(client, args)
{
	if (g_bNoClip[client] == true)
		Action_UnNoClip(client);
	return Plugin_Handled;
}

public Action:Client_Prev(client, args)
{
	if(g_CurrentCp[client] == -1)
	{
		PrintToChat(client, "%t", "NoCheckpointsFound", MOSSGREEN,WHITE);
		return Plugin_Handled;
	}
	DoTeleport(client,-1);
	return Plugin_Handled;
}

public Action:Client_Save(client, args)
{
	DoCheckpoint(client);
	return Plugin_Handled;
}

public Action:Client_Tele(client, args)
{
	DoTeleport(client,0);
	return Plugin_Handled;
}

public Action:Client_Top(client, args)
{
	g_bTopMenuOpen[client]=true;
	g_bMenuOpen[client]=true;
	CreateTimer(0.1, OpenTopMenu, client,TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action:Client_Profile(client, args)
{
	g_bMenuOpen[client]=true;
	if (IsValidClient(client))
		ProfileMenu(client,args);
	return Plugin_Handled;
}

public Action:Client_MapTop(client, args)
{
	if (args==0)
	{
		MapTopMenu(client,g_szMapName);
		return Plugin_Handled;
	}
	decl String:szArg[128];
	GetCmdArg(1, szArg, 128);
	db_selectMapTopClimbers(client,szArg);
	return Plugin_Handled;
}

public Action:Client_Spec(client, args)
{
	if (IsFakeClient(client) || !IsClientInGame(client))
		return Plugin_Handled;

	if (g_bCantJoin[client])
	{
		PrintToChat(client, "[%cKZ%c] You cant join a team so soon!", MOSSGREEN, WHITE);
		return Plugin_Handled;
	}

	StopClimbersMenu(client);
	g_bMenuOpen[client]=true;
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		SpecPlayer(client, args);
	}
	return Plugin_Handled;
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Command_Menu(client,args)
{
	//Credits: Measure by DaFox
	//https://forums.alliedmods.net/showthread.php?t=88830
	
	decl String:buffer[64];
	
	g_hMainMenu = CreateMenu(Handler_MainMenu)
	Format(buffer, sizeof(buffer), "%T", "MeasureMenuTitle", client);
	SetMenuTitle(g_hMainMenu, buffer);
	Format(buffer, sizeof(buffer), "%T", "Measure_Point1", client);
	AddMenuItem(g_hMainMenu, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Measure_Point2", client);
	AddMenuItem(g_hMainMenu, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Measure_FindDist", client);
	AddMenuItem(g_hMainMenu, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Measure_Reset", client);
	AddMenuItem(g_hMainMenu, "", buffer);
	
	StopClimbersMenu(client);
	g_bMenuOpen[client]=true;
	CreateTimer(0.1, OpenMeasureMenu, client,TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Handler_MainMenu(Handle:menu,MenuAction:action,param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: {	//Point 1 (Red)
				GetPos(param1,0);
			}
			case 1: {	//Point 2 (Green)
				GetPos(param1,1);
			}
			case 2: {	//Find Distance
				if(g_bMeasurePosSet[param1][0] && g_bMeasurePosSet[param1][1])
				{
					new Float:vDist = GetVectorDistance(g_fvMeasurePos[param1][0],g_fvMeasurePos[param1][1]);
					new Float:vHightDist = (g_fvMeasurePos[param1][0][2] - g_fvMeasurePos[param1][1][2]);
					PrintToChat(param1, "%t", "Measure1",MOSSGREEN,WHITE,vDist,vHightDist);
					Beam(param1,g_fvMeasurePos[param1][0],g_fvMeasurePos[param1][1],4.0,2.0,0,0,255);
				}
				else
					PrintToChat(param1, "%t", "Measure2",MOSSGREEN,WHITE);
			}
			case 3: {	//Reset
				ResetPos(param1);
			}
		}
		DisplayMenu(g_hMainMenu,param1,MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1] = false;
		ResetPos(param1);
	}
}

public SpecPlayer(client,args)
{
	decl String:szPlayerName[MAX_NAME_LENGTH];
	decl String:szPlayerName2[128];
	decl String:szOrgTargetName[MAX_NAME_LENGTH];
	decl String:szTargetName[MAX_NAME_LENGTH];
	decl String:szArg[MAX_NAME_LENGTH];
	Format(szTargetName, MAX_NAME_LENGTH, "");
	Format(szOrgTargetName, MAX_NAME_LENGTH, "");

	if (IsFakeClient(client) || !IsClientInGame(client))
		return;

	if (args==0)
	{
		new Handle:menu = CreateMenu(SpecMenuHandler);

		if(g_bSpectate[client])
			SetMenuTitle(menu, "%T", "SpecMenu1", client);
		else
			SetMenuTitle(menu, "%T", "SpecMenu2", client);
		new playerCount=0;

		//add replay bots
		if (g_ProBot != -1 || g_TpBot != -1)
		{
			if (g_ProBot != -1 && IsValidClient(g_ProBot) && IsPlayerAlive(g_ProBot))
			{
				Format(szPlayerName2, 128, "%T", "ProRecord_Replay", client, g_szReplayTime);
				AddMenuItem(menu, "PRO RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
			if (g_TpBot != -1 && IsValidClient(g_TpBot) && IsPlayerAlive(g_TpBot))
			{
				Format(szPlayerName2, 128, "%T", "TPRecord_Replay", client, g_szReplayTimeTp);
				AddMenuItem(menu, "TP RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}

		new count = 0;
		new client1, client2;
		//add players
		for (new i = 1; i <= MaxClients; i++)
		{
			//
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
			{
				if (count==0)
				{
					new QuickestPlayerId;
					new Float:fl_besttime = 999999999.0;
					new maprank;
					new bestrank = 99999999;
					decl String:szTopName[16];
					decl String:szTopMapName[16];
					for (new x = 1; x <= MaxClients; x++)
					{
						if (!IsValidClient(x) || !IsPlayerAlive(x) || x == client || IsFakeClient(x)) continue;
						//time
						if (g_fPersonalRecord[x] < fl_besttime && g_fPersonalRecord[x] > 0.0)
						{
							fl_besttime = g_fPersonalRecord[x];
							maprank = g_MapRankTp[x];
							QuickestPlayerId = x;
							GetClientName(x,szTopMapName,16);
							client1 = x;
						}
						if (g_fPersonalRecordPro[x] < fl_besttime && g_fPersonalRecordPro[x] > 0.0)
						{
							fl_besttime = g_fPersonalRecordPro[x];
							maprank=  g_MapRankPro[x];
							QuickestPlayerId = x;
							GetClientName(x,szTopMapName,16);
							client1 = x;
						}

						//rank
						if (g_PlayerRank[x] > 0)
							if (g_PlayerRank[x] <= bestrank)
							{
								bestrank = g_PlayerRank[x];
								GetClientName(x,szTopName,16);
								client2 = x;
							}
					}
					//add rank
					decl String:szMenu[128];
					Format(szMenu, 128, "%T", "TopRankedPlayer", client, szTopName, bestrank);
					AddMenuItem(menu, "best_playertop", szMenu);

					//add time
					decl String:szTime[32];
					decl String:szId[4];
					FormatTimeFloat(client, fl_besttime, 3, szTime, sizeof(szTime));
					Format (szId,4,"%i",QuickestPlayerId);

					if (fl_besttime < 999999999.0)
					{
						Format(szMenu, 128, "%T", "TopRankedOnMap", client, szTopMapName, maprank, szTime);
						AddMenuItem(menu, szId, szMenu);
					}
					AddMenuItem(menu, "", "",ITEMDRAW_SPACER);
				}
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				Format(szPlayerName2, 128, "%s (%s)",szPlayerName, g_pr_rankname[i]);
				if (i != client1 && i != client2)
					AddMenuItem(menu, szPlayerName, szPlayerName2);
				playerCount++;
				count++;
			}
		}

		if (playerCount>0 || g_ProBot != -1 || g_TpBot != -1)
		{
			g_bMenuOpen[client]=true;
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
		else
			PrintToChat(client, "%t", "ChallengeFailed4",MOSSGREEN,WHITE);

	}
	else
	{
		for (new i = 1; i < 20; i++)
		{
			GetCmdArg(i, szArg, MAX_NAME_LENGTH);
			if (!StrEqual(szArg, "", false))
			{
				if (i==1)
					Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg);
				else
					Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg);
			}
		}
		Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName);
		StringToUpper(szTargetName);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client )
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				StringToUpper(szPlayerName);
				if ((StrContains(szPlayerName, szTargetName) != -1))
				{
					ChangeClientTeam(client, 1);
					g_bCantJoin[client] = true;
					g_SpecTarget2[client] = i;
					CreateTimer(0.75, TeamDelay, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.1, SelectSpecTarget, client, TIMER_FLAG_NO_MAPCHANGE);
					return;
				}
			}
		}
		PrintToChat(client, "%t", "PlayerNotFound",MOSSGREEN,WHITE, szOrgTargetName);
	}
}

public SpecMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));

		new iInfo = StringToInt(info);
		if (1 < iInfo < MAXPLAYERS)
		{
			ChangeClientTeam(param1, 1);
			g_bCantJoin[param1] = true;
			g_SpecTarget2[param1] = iInfo;
			CreateTimer(0.75, TeamDelay, param1, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.1, SelectSpecTarget, param1, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
			if(StrEqual(info,"best_playertop"))
			{
				new playerid;
				new count = 0;
				new bestrank = 99999999;
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i) && IsPlayerAlive(i) && i != param1 && !IsFakeClient(i))
					{
						if (g_PlayerRank[i] <= bestrank)
						{
							bestrank = g_PlayerRank[i];
							playerid = i;
							count++;
						}
					}
				}
				if (count!=0)
				{
					ChangeClientTeam(param1, 1);
					g_bCantJoin[param1] = true;
					g_SpecTarget2[param1] = playerid;
					CreateTimer(0.75, TeamDelay, param1, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.1, SelectSpecTarget, param1, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
					{
						GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
						if (i == g_TpBot)
							Format(szPlayerName, MAX_NAME_LENGTH, "TP RECORD REPLAY");
						else
							if (i == g_ProBot)
								Format(szPlayerName, MAX_NAME_LENGTH, "PRO RECORD REPLAY");
						if(StrEqual(info,szPlayerName))
						{
							ChangeClientTeam(param1, 1);
							g_bCantJoin[param1] = true;
							g_SpecTarget2[param1] = i;
							CreateTimer(0.75, TeamDelay, param1, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, SelectSpecTarget, param1, TIMER_FLAG_NO_MAPCHANGE);

						}
					}
				}
			}
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:Client_Kzmenu(client, args)
{
	if (!g_bAllowCheckpoints && IsValidClient(client))
		PrintToChat(client, "%t", "CMenuDisabled",MOSSGREEN, WHITE);
	else
	{
		g_bMenuOpen[client]=false;
		g_bClimbersMenuOpen[client] = true;
		CreateTimer(0.1, OpenCheckpointMenu, client,TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}


public CompareMenu(client,args)
{
	decl String:szArg[MAX_NAME_LENGTH];
	decl String:szPlayerName[MAX_NAME_LENGTH];
	if (args == 0)
	{
		Format(szPlayerName, MAX_NAME_LENGTH, "");
		new Handle:menu = CreateMenu(CompareSelectMenuHandler);
		SetMenuTitle(menu, "%T", "CompareMenuTitle", client);
		new playerCount=0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				AddMenuItem(menu, szPlayerName, szPlayerName);
				playerCount++;
			}
		}
		if (playerCount>0)
		{
			g_bMenuOpen[client]=true;
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
		else
			PrintToChat(client, "%t", "Compare_NoValidPlayers", MOSSGREEN,WHITE);
		return;
	}
	else
	{
		for (new i = 1; i < 20; i++)
		{
			GetCmdArg(i, szArg, MAX_NAME_LENGTH);
			if (!StrEqual(szArg, "", false))
			{
				if (i==1)
					Format(szPlayerName, MAX_NAME_LENGTH, "%s", szArg);
				else
					Format(szPlayerName, MAX_NAME_LENGTH, "%s %s",  szPlayerName, szArg);
			}
		}
		//player ingame? new name?
		if (!StrEqual(szPlayerName,"",false))
		{
			new id = -1;
			decl String:szName[MAX_NAME_LENGTH];
			decl String:szName2[MAX_NAME_LENGTH];
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i!=client)
				{
					GetClientName(i, szName, MAX_NAME_LENGTH);
					StringToUpper(szName);
					Format(szName2, MAX_NAME_LENGTH, "%s", szPlayerName);
					if ((StrContains(szName, szName2) != -1))
					{
						id=i;
						continue;
					}
				}
			}
			if (id != -1)
				db_viewPlayerRank2(client, g_szSteamID[id]);
			else
				db_viewPlayerAll2(client, szPlayerName);
		}
	}
}

public CompareSelectMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != param1)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				if(StrEqual(info,szPlayerName))
				{
					db_viewPlayerRank2(param1, g_szSteamID[param1]);
				}
			}
		}
		CompareMenu(param1,0);
	}
	else
	if(action == MenuAction_Cancel)
	{
		if (IsValidClient(param1))
			g_bMenuOpen[param1]=false;
	}
	else if (action == MenuAction_End)
	{
		if (IsValidClient(param1))
			g_bSelectProfile[param1]=false;
		CloseHandle(menu);
	}
}

public ProfileMenu(client,args)
{
	//spam protection
	new Float:diff = GetEngineTime() - g_fProfileMenuLastQuery[client];
	if (diff < 0.5)
	{
		StopClimbersMenu(client);
		g_bSelectProfile[client]=false;
		return;
	}
	g_fProfileMenuLastQuery[client] = GetEngineTime();

	decl String:szArg[MAX_NAME_LENGTH];
	//no argument
	if (args == 0)
	{
		decl String:szPlayerName[MAX_NAME_LENGTH];
		new Handle:menu = CreateMenu(ProfileSelectMenuHandler);
		SetMenuTitle(menu, "%T", "ProfileMenuTitle", client);
		GetClientName(client, szPlayerName, MAX_NAME_LENGTH);
		AddMenuItem(menu, szPlayerName, szPlayerName);
		new playerCount=1;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != client && !IsFakeClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				AddMenuItem(menu, szPlayerName, szPlayerName);
				playerCount++;
			}
		}
		g_bMenuOpen[client]=true;
		g_bSelectProfile[client]=true;
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return;
	}
	//get name
	else
	{
		if (args != -1)
		{
			g_bSelectProfile[client]=false;
			Format(g_szProfileName[client], MAX_NAME_LENGTH, "");
			for (new i = 1; i < 20; i++)
			{
				GetCmdArg(i, szArg, MAX_NAME_LENGTH);
				if (!StrEqual(szArg, "", false))
				{
					if (i==1)
						Format( g_szProfileName[client], MAX_NAME_LENGTH, "%s", szArg);
					else
						Format( g_szProfileName[client], MAX_NAME_LENGTH, "%s %s",  g_szProfileName[client], szArg);
				}
			}
		}
	}
	//player ingame? new name?
	if (args != 0 && !StrEqual(g_szProfileName[client],"",false))
	{
		new bool:bPlayerFound=false;
		decl String:szSteamId2[32];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szName2[MAX_NAME_LENGTH];
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				GetClientName(i, szName, MAX_NAME_LENGTH);
				StringToUpper(szName);
				Format(szName2, MAX_NAME_LENGTH, "%s", g_szProfileName[client]);
				if ((StrContains(szName, szName2) != -1))
				{
					bPlayerFound=true;
					GetClientAuthId(i, AuthId_Steam2, szSteamId2, sizeof(szSteamId2), true);
					continue;
				}
			}
		}
		if (bPlayerFound)
			db_viewPlayerRank(client, szSteamId2);
		else
			db_viewPlayerProfile1(client, g_szProfileName[client]);
	}
}

public ProfileSelectMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				if(StrEqual(info,szPlayerName))
				{
					Format(g_szProfileName[param1], MAX_NAME_LENGTH, "%s", szPlayerName);
					decl String:szSteamId[32];
					GetClientAuthId(i, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
					db_viewPlayerRank(param1, szSteamId);
				}
			}
		}
	}
	else if (action == MenuAction_End)
	{
		if (IsValidClient(param1))
			g_bSelectProfile[param1]=false;
		CloseHandle(menu);
	}
}

public Action:Client_AutoBhop(client, args)
{
	AutoBhop(client);
	if (g_bAutoBhop)
	{
		if (!g_bAutoBhopClient[client])
			PrintToChat(client, "%t", "AutoBhop2",MOSSGREEN,WHITE);
		else
			PrintToChat(client, "%t", "AutoBhop1",MOSSGREEN,WHITE);
	}
	return Plugin_Handled;
}

public AutoBhop(client)
{
	if (!g_bAutoBhop)
		PrintToChat(client, "%t", "AutoBhop3",MOSSGREEN,WHITE);
	if (!g_bAutoBhopClient[client])
		g_bAutoBhopClient[client] = true;
	else
		g_bAutoBhopClient[client] = false;
}

public Action:Client_Hide(client, args)
{
	HideMethod(client);
	if (!g_bHide[client])
		PrintToChat(client, "%t", "Hide1",MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Hide2",MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public HideMethod(client)
{
	if (!g_bHide[client])
		g_bHide[client] = true;
	else
		g_bHide[client] = false;
}

public ReplayRoute(client)
{
	if (!g_bReplayRoute[client])
		g_bReplayRoute[client] = true;
	else
		g_bReplayRoute[client] = false;
}

public Action:Client_Latest(client, args)
{
	db_ViewLatestRecords(client);
	return Plugin_Handled;
}

public Action:Client_Showsettings(client, args)
{
	ShowSrvSettings(client);
	return Plugin_Handled;
}

public Action:Client_Help(client, args)
{
	HelpPanel(client);
	return Plugin_Handled;
}

public Action:Client_Ranks(client, args)
{
	if (IsValidClient(client))
		PrintToChat(client, "[%cKZ%c] %c%s (0p)  %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)   %c%s%c (%ip)",
		MOSSGREEN,WHITE, WHITE, g_szSkillGroups[0],WHITE,g_szSkillGroups[1],WHITE,g_pr_rank_Percentage[1], GRAY, g_szSkillGroups[2],GRAY,g_pr_rank_Percentage[2],LIGHTBLUE,
		g_szSkillGroups[3],LIGHTBLUE,g_pr_rank_Percentage[3],BLUE, g_szSkillGroups[4],BLUE,g_pr_rank_Percentage[4],DARKBLUE,g_szSkillGroups[5],DARKBLUE,g_pr_rank_Percentage[5],
		PINK,g_szSkillGroups[6],PINK,g_pr_rank_Percentage[6],LIGHTRED,g_szSkillGroups[7],LIGHTRED,g_pr_rank_Percentage[7],DARKRED,g_szSkillGroups[8],DARKRED,g_pr_rank_Percentage[8]);
	return Plugin_Handled;
}

public Action:Client_Compare(client, args)
{
	CompareMenu(client,args);
	return Plugin_Handled;
}

public Action:Client_Start(client, args)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) == 1 || g_bPause[client])
		return Plugin_Handled;

	new Float: e_time = GetEngineTime();
	new Float: diff = e_time - g_fStartCommandUsed_LastTime[client];
	if (diff < 0.8)
		return Plugin_Handled;

	//spawn at Timer
	if (g_bSSPSet[client])
	{
		g_bTimeractivated[client] = false;
		g_fStartTime[client] = -1.0;
		g_fCurrentRunTime[client] = -1.0;
		DoValidTeleport(client, g_fPlayerSSPPos[client],g_fPlayerSSPAngles[client],Float:{0.0,0.0,-100.0});
	}
	else if (g_bRespawnAtTimer[client]==true)
	{
		DoValidTeleport(client, g_fPlayerCordsRestart[client],g_fPlayerAnglesRestart[client],Float:{0.0,0.0,-100.0});
	}
	else //else spawn at spawnpoint
	{
		g_fTeleportValidationTime[client] = GetEngineTime();
		CS_RespawnPlayer(client);
	}

	if (g_bAutoTimer)
		CL_OnStartTimerPress(client);

	g_js_bPlayerJumped[client] = false;
	g_bNoClip[client] = false;
	return Plugin_Handled;
}

public Action:Client_Pause(client, args)
{
	if (GetClientTeam(client) == 1)
		return Plugin_Handled;

	if( !(GetEntityFlags(client) & FL_ONGROUND) && !g_bPause[client] )
	{
		if (g_bErrorSounds[client])
		{
			EmitSoundToClient(client,"buttons/button10.wav",client);
		}
		PrintToChat(client, "%t", "Pause5", MOSSGREEN, WHITE, RED, WHITE);
		return Plugin_Handled;
	}

	if (g_bCantPause[client])
	{
		PrintToChat(client, "[%cKZ%c] You cant pause so soon!", MOSSGREEN, WHITE);
		return Plugin_Handled;
	}

	PauseMethod(client);

	if (!g_bPause[client] && g_bCanPause[client])
		PrintToChat(client, "%t", "Pause2",MOSSGREEN, WHITE, RED, WHITE);
		
	else if (GetEngineTime() - g_fLastPauseUsed[client] >= 2 || g_bCanPause[client] && !g_bUnpausedSoon[client])
		PrintToChat(client, "%t", "Pause3",MOSSGREEN, WHITE);
	
	return Plugin_Handled;
}

public PauseMethod(client)
{
	new Float: fDiff = GetEngineTime() - g_fLastUndo[client];

	if (GetClientTeam(client) == 1 || fDiff < 1.0) 
		return;

	if (g_bPause[client]==false && IsValidEntity(client))
	{
		if (g_bPauseServerside==false && client != g_ProBot && client != g_TpBot)
		{
			PrintToChat(client, "%t", "Pause1",MOSSGREEN, WHITE,RED,WHITE);
			return;
		}

		if(GetEngineTime() - g_fLastPauseUsed[client] < 2)
		{
			new Float: delay = 2 - (GetEngineTime() - g_fLastPauseUsed[client]);
			g_bCanPause[client] = false;
			PrintToChat(client, "%t", "Pause4", MOSSGREEN, WHITE, RED, WHITE, delay);
			if (g_bErrorSounds[client])
			{
				EmitSoundToClient(client, "buttons/button10.wav", client);
			}
			return;
		}

		g_fUnpauseDelay[client] = GetEngineTime();
		g_fLastPauseUsed[client] = GetEngineTime();
		g_fLastTimeDoubleDucked[client] -= 500.0;
		g_bCanPause[client] = true;
		g_bPause[client]=true;
		new Float:fVel[3] = {0.000000,0.000000,0.000000};
		SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);
		SetEntityMoveType(client, MOVETYPE_NONE);
		//Timer enabled?
		if(g_bTimeractivated[client] == true)
		{
			g_fStartPauseTime[client] = GetEngineTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];
		}
		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	}
	else
	{
		if(g_fStartTime[client] != -1.0 && g_bTimeractivated[client] == true)
		{
			g_fPauseTime[client] = GetEngineTime() - g_fStartPauseTime[client];
		}

		if (g_bPause[client] && (GetEngineTime() - g_fUnpauseDelay[client] < 0.40))
		{
			g_bUnpausedSoon[client] = true;
			g_bPause[client] = true;
			if (g_bErrorSounds[client])
			{
				EmitSoundToClient(client, "buttons/button10.wav", client);
			}
			PrintToChat(client, "%t", "Pause6", MOSSGREEN, WHITE, RED, WHITE);
			return;
		}

		g_bNoClip[client]=false;
		g_bPause[client]=false;
		g_bUnpausedSoon[client] = false;
		if (!g_bRoundEnd)
			SetEntityMoveType(client, MOVETYPE_WALK);

		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		DoValidTeleport(client, NULL_VECTOR,NULL_VECTOR, Float:{0.0,0.0,-100.0});
	}
}

public Action:Client_CPMessage(client, args)
{
	CPMessage(client);
	if (g_bCPTextMessage[client] == true)
		PrintToChat(client, "%t", "CpMessage1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "CpMessage2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}


public CPMessage(client)
{
	g_bCPTextMessage[client] = !g_bCPTextMessage[client];
}

public Action:Command_Spectate(client, const String:command[], argc)
{
	return Plugin_Handled;
}



public HideSpecs(client)
{
	switch(g_ShowSpecs[client])
	{
		case 0: g_ShowSpecs[client] = 1;
		case 1: g_ShowSpecs[client] = 2;
		case 2: g_ShowSpecs[client] = 0;
	}
}

public Action:Client_AdvClimbersMenu(client, args)
{
	AdvClimbersMenu(client);
	if (g_bAdvancedClimbersMenu[client])
		PrintToChat(client, "%t", "AdvClimbersMenu1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "AdvClimbersMenu2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}


public AdvClimbersMenu(client)
{
	if (g_bAdvancedClimbersMenu[client])
		g_bAdvancedClimbersMenu[client] = false;
	else
		g_bAdvancedClimbersMenu[client] = true;
}

public Action:Client_HideChat(client, args)
{
	HideChat(client);
	if (g_bHideChat[client])
		PrintToChat(client, "%t", "HideChat1",MOSSGREEN, WHITE);
	else
		PrintToChat(client, "%t", "HideChat2",MOSSGREEN, WHITE);
	return Plugin_Handled;
}

public HideChat(client)
{
	if (!g_bHideChat[client])
	{
		g_bHideChat[client]=true;
		SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_CHAT);
	}
	else
	{
		g_bHideChat[client]=false;
		SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
	}
}

public ShowTime(client)
{
	g_bShowTime[client] = !g_bShowTime[client];
}

public DisableGoTo(client)
{
	g_bGoToClient[client] = !g_bGoToClient[client];
}

public DisableSounds(client)
{
	g_bErrorSounds[client] = !g_bErrorSounds[client];
}

public GoToMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				if(StrEqual(info,szPlayerName))
				{
					GotoMethod(param1,i);
				}
				else
				{
					if (i == MaxClients)
					{
						PrintToChat(param1, "%t", "Goto4", MOSSGREEN,WHITE, szPlayerName);
						Client_GoTo(param1,0);
					}
				}
			}
		}
	}
	else
	if(action == MenuAction_Cancel)
	{
		g_bMenuOpen[param1]=false;
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public GotoMethod(client, i)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;
	decl String:szTargetName[MAX_NAME_LENGTH];
	GetClientName(i, szTargetName, MAX_NAME_LENGTH);
	if (GetEntityFlags(i) & FL_ONGROUND)
	{
		new ducked = GetEntProp(i, Prop_Send, "m_bDucked");
		new ducking = GetEntProp(i, Prop_Send, "m_bDucking");
		if (!(GetClientButtons(client) & IN_DUCK) && ducked == 0 && ducking == 0)
		{
			g_js_bPlayerJumped[client] = false;
			decl Float:position[3];
			decl Float:angles[3];
			GetClientAbsOrigin(i,position);
			GetClientEyeAngles(i,angles);
			decl Float:fVelocity[3];
			fVelocity[0] = 0.0;
			fVelocity[1] = 0.0;
			fVelocity[2] = 0.0;
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			DoValidTeleport(client, position,angles,Float:{0.0,0.0,-100.0});
			decl String:szClientName[MAX_NAME_LENGTH];
			GetClientName(client, szClientName, MAX_NAME_LENGTH);
			PrintToChat(i, "%t", "Goto5", MOSSGREEN,WHITE, szClientName);

			if(g_bTimeractivated[client])
			{
				Client_Stop(client, 0);
			}

		}
		else
		{
			PrintToChat(client, "%t", "Goto6", MOSSGREEN,WHITE, szTargetName);
			Client_GoTo(client,0);
		}
	}
	else
	{
		PrintToChat(client, "%t", "Goto7", MOSSGREEN,WHITE, szTargetName);
		Client_GoTo(client,0);
	}
}


public Action:Client_GoTo(client, args)
{
	if (!g_bGoToServer)
		PrintToChat(client, "%t", "Goto1",MOSSGREEN,WHITE,RED,WHITE);
	else
	if (g_bTimeractivated[client])
		PrintToChat(client, "%t", "Goto3",MOSSGREEN,WHITE, GREEN,WHITE);
	else
	{
		decl String:szPlayerName[MAX_NAME_LENGTH];
		decl String:szOrgTargetName[MAX_NAME_LENGTH];
		decl String:szTargetName[MAX_NAME_LENGTH];
		decl String:szArg[MAX_NAME_LENGTH];
		if (args==0)
		{
			new Handle:menu = CreateMenu(GoToMenuHandler);
			SetMenuTitle(menu, "%T", "GoToMenuTitle", client);
			new playerCount=0;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
					AddMenuItem(menu, szPlayerName, szPlayerName);
					playerCount++;
				}
			}
			if (playerCount>0)
			{
				g_bMenuOpen[client]=true;
				SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
			}
			else
			{
				CloseHandle(menu);
				PrintToChat(client, "%t", "ChallengeFailed4",MOSSGREEN,WHITE);
			}
		}
		else
		{
			for (new i = 1; i < 20; i++)
			{
				GetCmdArg(i, szArg, MAX_NAME_LENGTH);
				if (!StrEqual(szArg, "", false))
				{
					if (i==1)
						Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg);
					else
						Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg);
				}
			}
			Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName);
			StringToUpper(szTargetName);
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != client )
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
					StringToUpper(szPlayerName);
					if ((StrContains(szPlayerName, szTargetName) != -1))
					{
						GotoMethod(client,i);
						return Plugin_Handled;
					}
				}
			}
			PrintToChat(client, "%t", "PlayerNotFound",MOSSGREEN,WHITE, szOrgTargetName);
		}
	}
	return Plugin_Handled;
}


public Action:Client_StrafeSync(client, args)
{
	StrafeSync(client);
	if (g_bStrafeSync[client])
		PrintToChat(client, "%t", "StrafeSync1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "StrafeSync2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public Action:Client_Route(client, args)
{
	ReplayRoute(client);
	if (g_bReplayRoute[client])
		PrintToChat(client, "%t", "Route1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Route2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public Action:Client_SetStartPosition(client, args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		g_bSSPSet[client] = true;
		GetClientAbsOrigin(client, g_fPlayerSSPPos[client]);
		GetClientEyeAngles(client, g_fPlayerSSPAngles[client]);
		PrintToChat(client, "[%cKZ%c] %cStart position set!",MOSSGREEN, WHITE, GRAY); 
	}
	return Plugin_Handled;
}

public Action:Client_ClearStartPosition(client, args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		g_bSSPSet[client] = false;
		PrintToChat(client, "[%cKZ%c] %cStart position cleared!",MOSSGREEN, WHITE, GRAY); 
	}
	return Plugin_Handled;
}


public StrafeSync(client)
{
	if (g_bStrafeSync[client])
		g_bStrafeSync[client] = false;
	else
		g_bStrafeSync[client] = true;
}


public ClimbersMenuSounds(client)
{
	g_bClimbersMenuSounds[client] = !g_bClimbersMenuSounds[client];
}

public QuakeSounds(client)
{
	switch(g_EnableQuakeSounds[client])
	{
		case 0: g_EnableQuakeSounds[client] = 1;
		case 1: g_EnableQuakeSounds[client] = 2;
		case 2: g_EnableQuakeSounds[client] = 3;
		case 3: g_EnableQuakeSounds[client] = 0;
	}
}
public Action:Client_InfoPanel(client, args)
{
	InfoPanel(client);
	if (g_bInfoPanel[client] == true)
		PrintToChat(client, "%t", "Info1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Info2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public InfoPanel(client)
{
	if (g_bInfoPanel[client])
		g_bInfoPanel[client] = false;
	else
	{
		g_bInfoPanel[client] = true;
	}
}

public AdvInfoPanel(client)
{
	g_bAdvInfoPanel[client] = !g_bAdvInfoPanel[client];
}


public Action:Client_PlayerJumpBeam(client, args)
{
	PlayerJumpBeam(client);
	if (g_bJumpBeam[client])
		PrintToChat(client, "%t", "PlayerJumpBeam1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "PlayerJumpBeam2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public PlayerJumpBeam(client)
{
	if (g_bJumpBeam[client])
		g_bJumpBeam[client] = false;
	else
		g_bJumpBeam[client] = true;
}

public ColorChat(client)
{
	switch(g_ColorChat[client])
	{
		case 0: g_ColorChat[client] = 1;
		case 1: g_ColorChat[client] = 2;
		case 2: g_ColorChat[client] = 3;
		case 3: g_ColorChat[client] = 0;
	}
}

public Action:Client_Stop(client, args)
{
	if (g_bTimeractivated[client])
	{
		g_bClimbersMenuOpen[client]=false;
		PlayerPanel(client);
		g_bTimeractivated[client] = false;
		g_fStartTime[client] = -1.0;
		g_fCurrentRunTime[client] = -1.0;
		PrintToChat(client, "%t", "TimerStopped1",MOSSGREEN,WHITE);
	}
	return Plugin_Handled;
}

public Action:Client_lj(client, args)
{
	db_selectTopLj(client);
	return Plugin_Handled;
}

public Action:Client_bhop(client, args)
{
	db_selectTopBhop(client);
	return Plugin_Handled;
}

public DoCheckpoint(client)
{
	if (!g_bAllowCheckpoints || !IsValidClient(client) || !IsPlayerAlive(client) || g_bPause[client] || !g_bClientGroundFlag[client])
		return;

	if (StrEqual("kzpro", g_szMapPrefix[0]) && g_bTimeractivated[client])
	{
		EmitSoundToClient(client,"buttons/button10.wav",client);
		PrintToChat(client, "%t", "KZPro_NotSupported", MOSSGREEN,WHITE,RED);
		return;
	}


	if (!g_bChallenge_Checkpoints[client] && g_bChallenge[client])
	{
		PrintToChat(client, "%t", "NoCpsDuringChallenge", RED,WHITE);
		return;
	}

	MoveType mt = GetEntityMoveType(client);

	//on ground or on ladder?
	if (GetEntityFlags(client)&FL_ONGROUND || mt == MOVETYPE_LADDER)
	{
		if (CPLIMIT == g_CounterCp[client])
		{
			g_CurrentCp[client] = -1;
			g_CounterCp[client] = 0;
		}

		//on bhop block?
		if (g_bOnBhopPlattform[client])
		{
			if (g_bErrorSounds[client])
			{
				EmitSoundToClient(client,"buttons/button10.wav",client);
			}
			if (mt == MOVETYPE_LADDER)
			{
				PrintToChat(client, "%t", "Cant_Checkpoint_Just_Landed", MOSSGREEN,WHITE,RED);
			}
			else
			{
				PrintToChat(client, "%t", "CheckpointsNotonBhopPlattforms", MOSSGREEN,WHITE,RED);
			}
			return;
		}

		//save coordinates for new cp
		GetClientAbsOrigin(client,g_fPlayerCords[client][g_CounterCp[client]]);
		GetClientEyeAngles(client,g_fPlayerAngles[client][g_CounterCp[client]]);

		//increase counters
		g_CurrentCp[client] = g_CounterCp[client];
		g_CounterCp[client]++;
		g_OverallCp[client]++;
		if (g_bClimbersMenuSounds[client])
			EmitSoundToClient(client,"buttons/blip1.wav",client);
		if (g_bCPTextMessage[client])
		{
			PrintToChat(client, "%t", "CheckpointSaved", MOSSGREEN,WHITE,GRAY, LIGHTBLUE, g_OverallCp[client], GRAY);
		}
	}
	else
	{
		if (g_bErrorSounds[client])
		{
			EmitSoundToClient(client,"buttons/button10.wav",client);
		}
		PrintToChat(client, "%t", "CheckpointsNotinAir", MOSSGREEN,WHITE,RED);
	}
}

public DoTeleport(client,pos)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || g_CurrentCp[client] == -1 || g_bPause[client])
		return;

	if (!g_bAllowCheckpoints)
	{
		PrintToChat(client, "%t", "CheckpointsDisabled", MOSSGREEN,WHITE);
		return;
	}
	new current = g_CurrentCp[client];
	new CounterCp = g_CounterCp[client];
	if (g_OverallCp[client] > CPLIMIT)
	{
		//if on last slot and next
		if(current == CPLIMIT-1 && pos == 1)
		{
			//reset to first
			g_CurrentCp[client] = -1;
			current = -1;
		}
		//if on first slot and previous
		if(current == 0  && pos == -1)
		{
			//reset to last
			g_CurrentCp[client] = CPLIMIT;
			current = CPLIMIT;
		}
	}
	else
	{
		//if on last slot and next
		if(current == CounterCp-1 && pos == 1)
		{
			//reset to first
			g_CurrentCp[client] = -1;
			current = -1;
		}
		//if on first slot and previous
		if(current == 0  && pos == -1)
		{
			//reset to last
			g_CurrentCp[client] = CounterCp;
			current = CounterCp;
		}
	}

	new actual = current+pos;
	if(actual < 0 || actual > g_OverallCp[client])
		PrintToChat(client, "%t", "NoCheckpointsFound", MOSSGREEN,WHITE);
	else
	{
		g_js_bPlayerJumped[client] = false;
		g_js_StrafeCount[client] = 0;
		g_js_GroundFrames[client] = 0;
		g_js_MultiBhop_Count[client] = 1;
		g_OverallTp[client]++;
		decl Float:fVelocity[3];
		fVelocity[0] = 0.0;
		fVelocity[1] = 0.0;
		fVelocity[2] = 0.0;
		if (IsValidClient(client))
		{
			if(client != g_ProBot && client != g_TpBot){
				Call_KZTimer_OnJumpstatInvalid(client);
			}
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			GetClientAbsOrigin(client, g_fPlayerCordsUndoTp[client]);
			GetClientEyeAngles(client,g_fPlayerAnglesUndoTp[client]);
			CreateTimer(0.02, ZeroVelocity, client);
			if (!(GetEntityFlags(client) & FL_ONGROUND))
				g_js_GODLIKE_Count[client] = 0;

			if (GetEntityMoveType(client) == MOVETYPE_LADDER)
				g_bInvalidUndoGround[client]=true;
			else
				g_bInvalidUndoGround[client]=false;
			
			if (!IsValidPlayerPos(client, g_fPlayerCords[client][actual]))
			{
				SetEntPropFloat(client, Prop_Send, "m_flDuckAmount", 1.0, 0);
			}
			
			// hopefully a temporary fix :)
			float flDefaultKnifeSpeed = 1.0;
			float flDefaultUspSpeed= 1.041667;
			float flUnarmedSpeed = 0.96154;
			
			//get weapon
			char weapon[128];
			GetClientWeapon(client, weapon, sizeof(weapon));
			TrimString(weapon);
			
			if (StrContains(weapon, "weapon") != -1)
			{
				if (StrEqual(weapon, "weapon_hkp2000") || StrEqual(weapon, "weapon_usp_silencer"))
				{
					SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flDefaultUspSpeed);
					g_PrestrafeVelocity[client] = flDefaultUspSpeed;
				}
				else
				{
					SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flDefaultKnifeSpeed);
					g_PrestrafeVelocity[client] = flDefaultKnifeSpeed;
				}
			}
			else
			{
				SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flUnarmedSpeed);
				g_PrestrafeVelocity[client] = flUnarmedSpeed;
			}
			
			g_PrestrafeFrameCounter[client] = 0;
			
			SetEntityMoveType(client, MOVETYPE_LADDER);
			
			DoValidTeleport(client, g_fPlayerCords[client][actual],g_fPlayerAngles[client][actual], Float:{0.0,0.0,-100.0});
			g_CurrentCp[client] += pos;
			if (g_bClimbersMenuSounds[client]==true)
				EmitSoundToClient(client,"buttons/blip1.wav",client);
		}
	}
}

public Action_NoClip(client)
{
	if(IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		new team = GetClientTeam(client);
		if (team==2 || team==3)
		{
			new MoveType:mt = GetEntityMoveType(client);
			if(mt == MOVETYPE_WALK)
			{
				if (g_bTimeractivated[client])
				{
					PrintToConsole(client, "%t", "TimerStopped_Noclip");
					g_bTimeractivated[client] = false;
					g_fStartTime[client] = -1.0;
					g_fCurrentRunTime[client] = -1.0;
				}
				g_fLastTimeNoClipUsed[client] = GetEngineTime();
				ResetJump(client);
				SetEntityMoveType(client, MOVETYPE_NOCLIP);
				SetEntityRenderMode(client , RENDER_NONE);
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				g_js_DuckCounter[client] = 0;
				g_bNoClip[client] = true;
			}
		}
	}
	return;
}

public Action_UnNoClip(client)
{
	if(IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		new team = GetClientTeam(client);
		if (team==2 || team==3)
		{
			new MoveType:mt = GetEntityMoveType(client);
			if(mt == MOVETYPE_NOCLIP)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				g_bNoClip[client] = false;
			}
		}
	}
	return;
}

public ClimbersMenu(client)
{
	if(!IsPlayerAlive(client) || GetClientTeam(client) == 1 || !g_bAllowCheckpoints)
	{
		g_bClimbersMenuOpen[client] = false;
		return;
	}
	g_bClimbersMenuOpen[client] = true;
	decl String:buffer[64];
	decl String:title[128];
	g_hclimbersmenu[client] = CreateMenu(ClimbersMenuHandler);
	if (g_bTimeractivated[client])
	{
		GetcurrentRunTime(client);
		SetMenuTitle(g_hclimbersmenu[client], g_szTimerTitle[client]);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu1_1", client, g_OverallCp[client]);
		AddMenuItem(g_hclimbersmenu[client], "!save", buffer);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu2_1", client, g_OverallTp[client]);
		AddMenuItem(g_hclimbersmenu[client], "!tele", buffer);
		if (g_bAdvancedClimbersMenu[client])
		{
			if (g_OverallCp[client] > 1)
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);
			}
			Format(buffer, sizeof(buffer), "%T", "ClimbersMenu5", client);
			if(g_fPlayerCordsUndoTp[client][0] == 0.0 && g_fPlayerCordsUndoTp[client][1] == 0.0 && g_fPlayerCordsUndoTp[client][2] == 0.0)
				AddMenuItem(g_hclimbersmenu[client], "!undo", buffer,ITEMDRAW_DISABLED);
			else
				AddMenuItem(g_hclimbersmenu[client], "!undo", buffer);
			if (g_bPause[client])
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu7", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu6", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}
			Format(buffer, sizeof(buffer), "%T", "ClimbersMenu8", client);
			AddMenuItem(g_hclimbersmenu[client], "!restart", buffer);
		}
		else
		{
			if (g_bPause[client])
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu7", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu6", client);
				AddMenuItem(g_hclimbersmenu[client], "!pause", buffer);
			}
			Format(buffer, sizeof(buffer), "%T", "ClimbersMenu8", client);
			AddMenuItem(g_hclimbersmenu[client], "!restart", buffer);
		}
	}
	else
	{
		Format(title, 128, "%T", "ClimbersMenu10", client, g_szPlayerPanelText[client],GetSpeed(client));
		SetMenuTitle(g_hclimbersmenu[client], title);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu11", client);
		AddMenuItem(g_hclimbersmenu[client], "!save", buffer);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu12", client);
		AddMenuItem(g_hclimbersmenu[client], "!tele", buffer);
		if (g_bAdvancedClimbersMenu[client])
		{
			Format(title, 128, "%T", "ClimbersMenu10", client, g_szPlayerPanelText[client],GetSpeed(client));
			SetMenuTitle(g_hclimbersmenu[client], title);
			if (g_OverallCp[client] > 1)
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu3", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);
				Format(buffer, sizeof(buffer), "%T", "ClimbersMenu4", client);
				AddMenuItem(g_hclimbersmenu[client], "", buffer,ITEMDRAW_DISABLED);
			}
		}
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu8", client);
		AddMenuItem(g_hclimbersmenu[client], "!restart", buffer);
		Format(buffer, sizeof(buffer), "%T", "ClimbersMenu9", client);
		AddMenuItem(g_hclimbersmenu[client], "!Options", buffer);
	}
	SetMenuPagination(g_hclimbersmenu[client], MENU_NO_PAGINATION);
	SetMenuOptionFlags(g_hclimbersmenu[client], MENUFLAG_NO_SOUND|MENUFLAG_BUTTON_EXIT);
	DisplayMenu(g_hclimbersmenu[client], client, MENU_TIME_FOREVER);
}


public ClimbersMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		char paramInfo[32];
		GetMenuItem(menu, param2, paramInfo, sizeof(paramInfo));
		
		if (g_bTimeractivated[param1])
		{
			if (g_bAdvancedClimbersMenu[param1])
			{
				switch(param2)
				{
					case 0: DoCheckpoint(param1);
					case 1: DoTeleport(param1,0);
					case 2: Client_Prev(param1,0);
					case 3: Client_Next(param1,0);
					case 4: Client_Undo(param1,0);
					case 5: Client_Pause(param1, 0);
					case 6: Client_Start(param1, 0);
				}
			}
			else
				switch(param2)
				{
					case 0: DoCheckpoint(param1);
					case 1: DoTeleport(param1,0);
					case 2: Client_Pause(param1, 0);
					case 3: Client_Start(param1, 0);
				}
		}
		else
		{
			if (g_bAdvancedClimbersMenu[param1])
			switch(param2)
			{
				case 0: DoCheckpoint(param1);
				case 1: DoTeleport(param1,0);
				case 2: Client_Prev(param1,0);
				case 3: Client_Next(param1,0);
				case 4: Client_Start(param1, 0);
				case 5: OptionMenu(param1);
			}
			else
				switch(param2)
				{
					case 0: DoCheckpoint(param1);
					case 1: DoTeleport(param1,0);
					case 2: Client_Start(param1, 0);
					case 3: OptionMenu(param1);
				}
		}
		//note: options menu priority
		if (!(g_bTimeractivated[param1] == false && StrEqual(paramInfo, "!Options")))
		{
			ClimbersMenu(param1);
		}
	}
	else
		if(action == MenuAction_Cancel)
		{
			if (param2 == -3)
				g_bClimbersMenuOpen[param1]=false;
		}
		else
			if (action == MenuAction_End)
			{
				CloseHandle(menu);
			}
}


public KZTopMenu(client)
{
	decl String:buffer[64];

	g_MenuLevel[client]=-1;
	g_bTopMenuOpen[client]=true;
	g_bClimbersMenuOpen[client]=false;
	new Handle:topmenu = CreateMenu(TopMenuHandler);
	SetMenuTitle(topmenu, "%T", "TopMenuTitle", client);
	if (g_bPointSystem)
	{
	Format(buffer, sizeof(buffer), "%T", "Top100Players", client);
	AddMenuItem(topmenu, "Top 100 Players", buffer);
	}

	Format(buffer, sizeof(buffer), "%T", "Top5Challengers", client);
	AddMenuItem(topmenu, "Top 5 Challengers", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top5ProJumpers", client);
	AddMenuItem(topmenu, "Top 5 Pro Jumpers", buffer);
	if (g_bAllowCheckpoints)
	{
		Format(buffer, sizeof(buffer), "%T", "Top5TPJumpers", client);
		AddMenuItem(topmenu, "Top 5 TP Jumpers", buffer);
	}

	else
	{
		Format(buffer, sizeof(buffer), "%T", "Top5TPJumpers", client);
		AddMenuItem(topmenu, "Top 5 TP Jumpers", buffer, ITEMDRAW_DISABLED);
	}

	Format(buffer, sizeof(buffer), "%T", "MapTop", client);
	AddMenuItem(topmenu, "Map Top", buffer);

	if (g_bJumpStats)
	{
		Format(buffer, sizeof(buffer), "%T", "JumpTop", client);
		AddMenuItem(topmenu, "Jump Top", buffer);
	}
	SetMenuOptionFlags(topmenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(topmenu, client, MENU_TIME_FOREVER);
}

public TopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		if(g_bPointSystem)
		{
			switch(param2)
			{
				case 0: db_selectTopPlayers(param1);
				case 1: db_selectTopChallengers(param1);
				case 2: db_selectTopProRecordHolders(param1);
				case 3: db_selectTopTpRecordHolders(param1);
				case 4: MapTopMenu(param1,g_szMapName);
				case 5: JumpTopMenu(param1);
			}
			if (param2==5 && !g_bJumpStats)
				PrintToChat(param1, "%t", "JumpstatsDisabled",MOSSGREEN,WHITE);
		}
		else
		{
			switch(param2)
			{
				case 0: db_selectTopChallengers(param1);
				case 1: db_selectTopProRecordHolders(param1);
				case 2: db_selectTopTpRecordHolders(param1);
				case 3: MapTopMenu(param1,g_szMapName);
				case 4: JumpTopMenu(param1);
			}
			if (param2==4 && !g_bJumpStats)
				PrintToChat(param1, "%t", "JumpStatsDisabled",MOSSGREEN,WHITE);
		}
	}
	else
		if(action == MenuAction_Cancel)
		{
			g_bTopMenuOpen[param1]=false;
		}
		else
			if (action == MenuAction_End)
			{
				CloseHandle(menu);
			}
}

public MapTopMenu(client, String:szMap[128])
{
	Format(g_szMapTopName[client],128, "%s", szMap);
	new Handle:topmenu2 = CreateMenu(MapTopMenuHandler);
	decl String:title[128];
	decl String:buffer[64];
	Format(title, 128, "%T", "MapTopTitle", client, szMap, g_Server_Tickrate);
	SetMenuTitle(topmenu2, title);
	g_bMapMenuOpen[client]=true;
	g_bClimbersMenuOpen[client]=false;
	if (g_bAllowCheckpoints)
	{
		Format(buffer, sizeof(buffer), "%T", "Top50Overall", client);
		AddMenuItem(topmenu2, "!topclimbers", buffer);
		Format(buffer, sizeof(buffer), "%T", "Top20Pro", client);
		AddMenuItem(topmenu2, "!proclimbers", buffer);
		Format(buffer, sizeof(buffer), "%T", "Top20TP", client);
		AddMenuItem(topmenu2, "!cpclimbers", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "Top50Overall", client);
		AddMenuItem(topmenu2, "!topclimbers", buffer);
		Format(buffer, sizeof(buffer), "%T", "Top20Pro", client);
		AddMenuItem(topmenu2, "!proclimbers", buffer, ITEMDRAW_DISABLED);
		Format(buffer, sizeof(buffer), "%T", "Top20TP", client);
		AddMenuItem(topmenu2, "!cpclimbers", buffer, ITEMDRAW_DISABLED);
	}

	new bool:FileSize1=true;
	if (StrEqual(szMap,g_szMapName))
	{
		if (!g_global_ValidFileSize)
			FileSize1=false;
	}

	if (g_global_ValidedMap && !g_global_VersionBlocked && g_hDbGlobal != INVALID_HANDLE && FileSize1)
	{
	Format(buffer, sizeof(buffer), "%T", "GlobalTop", client);
	AddMenuItem(topmenu2, "", buffer);
	}

	SetMenuOptionFlags(topmenu2, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(topmenu2, client, MENU_TIME_FOREVER);
}

public MapTopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: db_selectTopClimbers(param1,g_szMapTopName[param1]);
			case 1: db_selectProClimbers(param1,g_szMapTopName[param1]);
			case 2: db_selectTPClimbers(param1,g_szMapTopName[param1]);
			case 3:
			{

				decl String:globalmap[128];
				if (StrEqual(g_szMapTopName[param1],g_szMapName))
					Format(globalmap,128,"%s", g_global_szGlobalMapName);
				else
					Format(globalmap,128,"%s", g_szMapTopName[param1]);
				GlobalTopMenu(param1, globalmap);
			}
		}
	}
	else
		if(action == MenuAction_Cancel)
		{
			if (g_bTopMenuOpen[param1])
				KZTopMenu(param1);
			g_bMapMenuOpen[param1]=false;
		}
		else
			if (action == MenuAction_End)
			{
				CloseHandle(menu);
			}
}

public GlobalTopMenu(client, String:szMap[128])
{
	Format(g_szMapTopName[client],128, "%s", szMap);
	new Handle:globalmenu = CreateMenu(GlobalTopMenuHandler);
	decl String:title[128];
	decl String:buffer[64];
	Format(title, 128, "%T", "GlobalTopTitle", client, szMap, g_Server_Tickrate);
	SetMenuTitle(globalmenu, title);
	g_bMapMenuOpen[client]=true;
	g_bClimbersMenuOpen[client]=false;
	Format(buffer, sizeof(buffer), "%T", "GlobalTop20Overall", client);
	AddMenuItem(globalmenu, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "GlobalTop20Pro", client);
	AddMenuItem(globalmenu, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "GlobalTop20TP", client);
	AddMenuItem(globalmenu, "", buffer);
	SetMenuOptionFlags(globalmenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(globalmenu, client, MENU_TIME_FOREVER);
}

public GlobalTopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		decl String:globalmap[128];
		if (StrEqual(g_szMapTopName[param1],g_szMapName))
			Format(globalmap,128,"%s", g_global_szGlobalMapName);
		else
			Format(globalmap,128,"%s", g_szMapTopName[param1]);
		switch(param2)
		{
			case 0: db_selectGlobalTopClimbers(param1,globalmap,0);
			case 1: db_selectGlobalTopClimbers(param1,globalmap,1);
			case 2: db_selectGlobalTopClimbers(param1,globalmap,2);
		}
	}
	else
		if(action == MenuAction_Cancel)
		{
			if (g_bTopMenuOpen[param1])
				MapTopMenu(param1,g_szMapName);
		}
		else
			if (action == MenuAction_End)
			{
				CloseHandle(menu);
			}
}

public Action:Global_IPCheck(client, args)
{

	 if(StrEqual(g_szSteamID[client],"STEAM_1:1:43259299") ||
		StrEqual(g_szSteamID[client],"STEAM_1:0:31861748") ||
		StrEqual(g_szSteamID[client],"STEAM_1:0:31339383") ||
		StrEqual(g_szSteamID[client],"STEAM_1:0:16599865") ||
		StrEqual(g_szSteamID[client],"STEAM_1:0:8845346")  ||
		StrEqual(g_szSteamID[client],"STEAM_1:1:21505111"))
    {

	if (args < 1)
	{
	ReplyToCommand(client, "[%cKZ%c] Usage: /ipcheck <name> | @all | @me", MOSSGREEN,WHITE);
	return Plugin_Handled;
	}

	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_BOTS, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
	PrintToConsole(client, "Player not found or invalid parameter.");
	return Plugin_Handled;
	}

	if (target_count > 3)
	PrintToChat(client, "[%cKZ%c] See console for output!", MOSSGREEN,WHITE);

	for (new i = 0; i < target_count; i++)
	{

	if (target_count >= 3)
	PerformIPCheck(client, target_list[i],true);

	else
	PerformIPCheck(client, target_list[i],false);
	}

	}
	return Plugin_Handled;
}

public PerformIPCheck(client, target,bool:console_only)
{

	if (IsValidClient(client) && !IsFakeClient(target))
	{
		decl String:IpString[30];
		decl String:NameString[64];
		decl String:SteamIDString[32];
		GetClientIP(target, IpString, sizeof(IpString));
		GetClientName(target, NameString , sizeof(NameString));
		GetClientAuthId(target, AuthId_Steam2, SteamIDString, sizeof(SteamIDString));


		if (!console_only)
		{
			PrintToChat(client, "[%cKZ%c] %s %c>>%c %cIP Address%c: %s", MOSSGREEN, WHITE, NameString, GREEN, WHITE, RED, WHITE, IpString);
			PrintToChat(client, "[%cKZ%c] %s %c>>%c %cSTEAMID%c: %s", MOSSGREEN, WHITE, NameString, GREEN, WHITE, BLUE, WHITE, SteamIDString);
			PrintToChat(client, "-----------------------------------------------------------------");
		}

		PrintToConsole(client, "[KZ] %s >> IP Address: %s || SteamID: %s", NameString, IpString, SteamIDString);
	}
	return;
}


public JumpTopMenu(client)
{
	g_bTopMenuOpen[client]=true;
	g_bClimbersMenuOpen[client]=false;
	new Handle:topmenu2 = CreateMenu(JumpTopMenuHandler);
	decl String:title[128];
	decl String:buffer[64];
	Format(title, sizeof(title), "%T", "JumpTopTitle", client, g_Server_Tickrate);
	SetMenuTitle(topmenu2, title);
	Format(buffer, sizeof(buffer), "%T", "Top20Longjump", client);
	AddMenuItem(topmenu2, "!lj", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top20BlockLongjump", client);
	AddMenuItem(topmenu2, "!ljblock", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top20Bhop", client);
	AddMenuItem(topmenu2, "!bhop", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top20Multibhop", client);
	AddMenuItem(topmenu2, "!multibhop", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top20DropBhop", client);
	AddMenuItem(topmenu2, "!dropbhop", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top20Weirdjump", client);
	AddMenuItem(topmenu2, "!wj", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top20Ladderjump", client);
	AddMenuItem(topmenu2, "!ladderjump", buffer);
	Format(buffer, sizeof(buffer), "%T", "Top20Countjump", client);
	AddMenuItem(topmenu2, "!countjump", buffer);
	SetMenuPagination(topmenu2, MENU_NO_PAGINATION);
	SetMenuOptionFlags(topmenu2, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(topmenu2, client, MENU_TIME_FOREVER);
}

public JumpTopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: db_selectTopLj(param1);
			case 1: db_selectTopLjBlock(param1);
			case 2: db_selectTopBhop(param1);
			case 3: db_selectTopMultiBhop(param1);
			case 4: db_selectTopDropBhop(param1);
			case 5: db_selectTopWj(param1);
			case 6: db_selectTopLadderJump(param1);
			case 7: db_selectTopCj(param1);
		}
	}
	else
	if(action == MenuAction_Cancel)
	{
		KZTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public HelpPanel(client)
{
	PrintConsoleInfo(client);
	g_bMenuOpen[client] = true;
	g_bClimbersMenuOpen[client]=false;
	new Handle:panel = CreatePanel();
	decl String:title[64];
	Format(title, 64, "KZ Timer Help (1/4) - v%s\nby 1NuTWunDeR",VERSION);
	DrawPanelText(panel, title);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!help - opens this menu");
	DrawPanelText(panel, "!help2 - explanation of the ranking system");
	DrawPanelText(panel, "!menu - checkpoint menu");
	DrawPanelText(panel, "!options - player options menu");
	DrawPanelText(panel, "!top / !globaltop - top / globaltop menu");
	DrawPanelText(panel, "!latest - prints in console the last map records");
	DrawPanelText(panel, "!profile/!rank - opens your profile");
	DrawPanelText(panel, "!checkpoint / !gocheck - checkpoint / gocheck");
	DrawPanelText(panel, "!prev / !next - previous or next checkpoint");
	DrawPanelText(panel, "!undo - undoes your last teleport");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "next page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanelHandler, 10000);
	CloseHandle(panel);
}

public HelpPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2==1)
			HelpPanel2(param1);
		else
		{
			g_bMenuOpen[param1] = false;
			ClimbersMenu(param1);
		}
	}
}

public HelpPanel2(client)
{
	new Handle:panel = CreatePanel();
	decl String:szTmp[64];
	Format(szTmp, 64, "KZ Timer Help (2/4) - v%s\nby 1NuTWunDeR",VERSION);
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!start/!r - go back to start");
	DrawPanelText(panel, "!stop - stops the timer");
	DrawPanelText(panel, "!pause - on/off pause");
	DrawPanelText(panel, "!stopsound - stops map music");
	DrawPanelText(panel, "!challenge - allows you to start a race against others");
	DrawPanelText(panel, "!spec - select a player you want to watch");
	DrawPanelText(panel, "!goto - teleports you to a given player");
	DrawPanelText(panel, "!compare <name> - compare your challenge results with a given player");
	DrawPanelText(panel, "!showsettings - shows kztiimer plugin settings");
	DrawPanelText(panel, "!wr - prints in chat the record of the current map");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "next page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel2Handler, 10000);
	CloseHandle(panel);
}

public HelpPanel2Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2==1)
			HelpPanel(param1);
		else
			if(param2==2)
				HelpPanel3(param1);
			else
			{
				g_bMenuOpen[param1] = false;
				ClimbersMenu(param1);
			}
	}
}

public HelpPanel3(client)
{
	new Handle:panel = CreatePanel();
	decl String:szTmp[64];
	Format(szTmp, 64, "KZ Timer Help (3/4) - v%s\nby 1NuTWunDeR",VERSION);
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!maptop - map top menu (optional: <mapname>)");
	DrawPanelText(panel, "!bhopcheck <name> - checks bhop stats for a given player");
	DrawPanelText(panel, "!ljblock - registers a lj block");
	DrawPanelText(panel, "!flashlight - on/off flashlight");
	DrawPanelText(panel, "!ranks - prints in chat all available ranks");
	DrawPanelText(panel, "!measure - allows you to measure the distance between 2 points");
	DrawPanelText(panel, "!globalcheck - checks whether the global record system is enabled");
	DrawPanelText(panel, "!avg - prints in chat the average map time");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "next page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel3Handler, 10000);
	CloseHandle(panel);
}

public HelpPanel3Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2==1)
			HelpPanel2(param1);
		else
			if(param2==2)
				HelpPanel4(param1);
			else
			{
				g_bMenuOpen[param1] = false;
				ClimbersMenu(param1);
			}
	}
}

public HelpPanel4(client)
{
	new Handle:panel = CreatePanel();
	decl String:szTmp[64];
	Format(szTmp, 64, "KZ Timer Help (4/4) - v%s\nby 1NuTWunDeR",VERSION);
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!specs - prints in chat a list of all specs");
	DrawPanelText(panel, "!mapinfo - prints in chat global info about the current map");
	DrawPanelText(panel, "!checkpoint / !gocheck - checkpoint / teleport");
	DrawPanelText(panel, "!route - on/off shows the route of the quickest replay");
	DrawPanelText(panel, "!beam - on/off showing the trajectory of your last jump");
	DrawPanelText(panel, "!sync -  on/off prints in chat your strafe sync");
	DrawPanelText(panel, "!hidechat -  on/off in-game chat");
	DrawPanelText(panel, "!hideweapon - on/off weapon model");
	DrawPanelText(panel, "!speed/!showkeys - on/off center panel");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel4Handler, 10000);
	CloseHandle(panel);
}

public HelpPanel4Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2==1)
			HelpPanel3(param1);
		else
		{
			g_bMenuOpen[param1] = false;
			ClimbersMenu(param1);
		}
	}
}

public ShowSrvSettings(client)
{
	PrintToConsole(client, " ");
	PrintToConsole(client, "-----------------");
	PrintToConsole(client, "KZ Timer settings");
	PrintToConsole(client, "-----------------");
	PrintToConsole(client, "kz_admin_clantag %b", g_bAdminClantag);
	PrintToConsole(client, "kz_attack_spam_protection %b", g_bAttackSpamProtection);
	PrintToConsole(client, "kz_anticheat_ban_duration %.1fh", g_fBanDuration);
	PrintToConsole(client, "kz_auto_bhop %i (climb maps are not supported)", g_bAutoBhopConVar);
	PrintToConsole(client, "kz_auto_timer %i", g_bAutoTimer);
	PrintToConsole(client, "kz_autoheal %i (requires kz_godmode 0)", g_Autohealing_Hp);
	PrintToConsole(client, "kz_autorespawn %b", g_bAutoRespawn);
	PrintToConsole(client, "kz_bhop_single_touch %b", g_bSingleTouch);
	PrintToConsole(client, "kz_challenge_points %b", g_bChallengePoints);
	PrintToConsole(client, "kz_checkpoints %b", g_bAllowCheckpoints);
	PrintToConsole(client, "kz_clean_weapons %b", g_bCleanWeapons);
	PrintToConsole(client, "kz_connect_msg %b", g_bConnectMsg);
	PrintToConsole(client, "kz_country_tag %b", g_bCountry);
	PrintToConsole(client, "kz_custom_models %b", g_bPlayerSkinChange);
	PrintToConsole(client, "kz_dist_min_lj %.1f", g_dist_min_lj);
	PrintToConsole(client, "kz_dist_perfect_lj %.1f", g_dist_perfect_lj);
	PrintToConsole(client, "kz_dist_impressive_lj %.1f", g_dist_impressive_lj);
	PrintToConsole(client, "kz_dist_god_lj %.1f", g_dist_god_lj);
	PrintToConsole(client, "kz_dist_min_cj %.1f", g_dist_min_countjump);
	PrintToConsole(client, "kz_dist_perfect_cj %.1f", g_dist_perfect_countjump);
	PrintToConsole(client, "kz_dist_impressive_cj %.1f", g_dist_impressive_countjump);
	PrintToConsole(client, "kz_dist_god_cj %.1f", g_dist_god_countjump);
	PrintToConsole(client, "kz_dist_min_bhop %.1f", g_dist_min_bhop);
	PrintToConsole(client, "kz_dist_perfect_bhop %.1f", g_dist_perfect_bhop);
	PrintToConsole(client, "kz_dist_impressive_bhop %.1f", g_dist_impressive_bhop);
	PrintToConsole(client, "kz_dist_god_bhop %.1f", g_dist_god_bhop);
	PrintToConsole(client, "kz_dist_min_multibhop %.1f", g_dist_min_multibhop);
	PrintToConsole(client, "kz_dist_perfect_multibhop %.1f", g_dist_perfect_multibhop);
	PrintToConsole(client, "kz_dist_impressive_multibhop %.1f", g_dist_impressive_multibhop);
	PrintToConsole(client, "kz_dist_god_multibhop %.1f", g_dist_god_multibhop);
	PrintToConsole(client, "kz_dist_min_dropbhop %.1f", g_dist_min_dropbhop);
	PrintToConsole(client, "kz_dist_perfect_dropbhop %.1f", g_dist_perfect_dropbhop);
	PrintToConsole(client, "kz_dist_impressive_dropbhop %.1f", g_dist_impressive_dropbhop);
	PrintToConsole(client, "kz_dist_god_dropbhop %.1f", g_dist_god_dropbhop);
	PrintToConsole(client, "kz_dist_min_wj %.1f", g_dist_min_weird);
	PrintToConsole(client, "kz_dist_perfect_wj %.1f", g_dist_perfect_weird);
	PrintToConsole(client, "kz_dist_impressive_wj %.1f", g_dist_impressive_weird);
	PrintToConsole(client, "kz_dist_god_wj %.1f", g_dist_god_weird);
	PrintToConsole(client, "kz_dist_min_ladder %.1f", g_dist_min_ladder);
	PrintToConsole(client, "kz_dist_perfect_ladder %.1f", g_dist_perfect_ladder);
	PrintToConsole(client, "kz_dist_impressive_ladder %.1f", g_dist_impressive_ladder);
	PrintToConsole(client, "kz_dist_god_ladder %.1f", g_dist_god_ladder);
	PrintToConsole(client, "kz_double_duck %b", g_bDoubleDuckCvar);
	PrintToConsole(client, "kz_dynamic_timelimit %b (requires kz_map_end 1)", g_bDynamicTimelimit);
	PrintToConsole(client, "kz_godmode %b", g_bgodmode);
	PrintToConsole(client, "kz_goto %b", g_bGoToServer);
	PrintToConsole(client, "kz_info_bot %b", g_bInfoBot);
	PrintToConsole(client, "kz_jumpstats %b", g_bJumpStats);
	PrintToConsole(client, "kz_noclip %b", g_bNoClipS);
	PrintToConsole(client, "kz_prespeed_cap %.1f (speed-limiter)", g_fBhopSpeedCap);
	PrintToConsole(client, "kz_map_end %b", g_bMapEnd);
	PrintToConsole(client, "kz_max_prespeed_bhop_dropbhop %.1f", g_fMaxBhopPreSpeed);
	PrintToConsole(client, "kz_min_skill_group %i", g_MinSkillGroup);
	PrintToConsole(client, "kz_pause %b", g_bPauseServerside);
	PrintToConsole(client, "kz_player_transparency %i", g_TransPlayerModels);
	PrintToConsole(client, "kz_point_system %b", g_bPointSystem);
	PrintToConsole(client, "kz_prestrafe %b", g_bPreStrafe);
	PrintToConsole(client, "kz_ranking_extra_points_firsttime %i", g_ExtraPoints2);
	PrintToConsole(client, "kz_ranking_extra_points_improvements %i", g_ExtraPoints);
	PrintToConsole(client, "kz_replay_bot %b", g_bReplayBot);
	PrintToConsole(client, "kz_restore %b", g_bRestore);
	PrintToConsole(client, "kz_round_end %b", g_bAllowRoundEndCvar);
	PrintToConsole(client, "kz_settings_enforcer %b", g_bEnforcer);
	PrintToConsole(client, "kz_slay_on_endbutton_press %b", g_bSlayPlayers);
	PrintToConsole(client, "kz_speclist_advert_interval %.1f", g_fSpecsAdvert);
	PrintToConsole(client, "kz_team_restriction %i", g_Team_Restriction);
	PrintToConsole(client, "kz_use_radio %b", g_bRadioCommands);
	PrintToConsole(client, "kz_vip_clantag %b", g_bVipClantag);
	PrintToConsole(client, "---------------");
	PrintToConsole(client, "Server settings");
	PrintToConsole(client, "---------------");
	new Handle:hTmp;
	hTmp = FindConVar("sv_airaccelerate");
	new Float: flAA = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_accelerate");
	new Float: flA = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_friction");
	new Float: flFriction = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_gravity");
	new Float: flGravity = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_enablebunnyhopping");
	new iBhop = GetConVarInt(hTmp);
	hTmp = FindConVar("sv_maxspeed");
	new Float: flMaxSpeed = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_maxvelocity");
	new Float: flMaxVel = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_staminalandcost");
	new Float: flStamLand = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_staminajumpcost");
	new Float: flStamJump = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_wateraccelerate");
	new Float: flWaterA = GetConVarFloat(hTmp);
	hTmp = FindConVar("sv_ladder_scale_speed");
	new Float: flLadderSpeed = GetConVarFloat(hTmp);
	if (hTmp != INVALID_HANDLE)
		CloseHandle(hTmp);
	PrintToConsole(client, "sv_accelerate %.1f", flA);
	PrintToConsole(client, "sv_airaccelerate %.1f", flAA);
	PrintToConsole(client, "sv_friction %.1f", flFriction);
	PrintToConsole(client, "sv_gravity %.1f", flGravity);
	PrintToConsole(client, "sv_enablebunnyhopping %i", iBhop);
	PrintToConsole(client, "sv_ladder_scale_speed %.1f", flLadderSpeed);
	PrintToConsole(client, "sv_maxspeed %.1f", flMaxSpeed);
	PrintToConsole(client, "sv_maxvelocity %.1f", flMaxVel);
	PrintToConsole(client, "sv_staminalandcost %.2f", flStamLand);
	PrintToConsole(client, "sv_staminajumpcost %.2f", flStamJump);
	PrintToConsole(client, "sv_wateraccelerate %.1f", flWaterA);
	PrintToConsole(client, "-------------------------------------");
	PrintToChat(client, "%t", "ConsoleOutput", MOSSGREEN,WHITE);
}

public SetClientLang(client)
{
	switch(g_ClientLang[client])
	{
		case 0: g_ClientLang[client] = 1;
		case 1: g_ClientLang[client] = 2;
		case 2: g_ClientLang[client] = 3;
		case 3: g_ClientLang[client] = 4;
		case 4: g_ClientLang[client] = 5;
		case 5: g_ClientLang[client] = 6;
		case 6: g_ClientLang[client] = 7;
  		case 7: g_ClientLang[client] = 0;
	}
	SetClientLangByID(client,g_ClientLang[client])
}

public SetClientLangByID(client,lang_id)
{
	decl String:sLangID[4];
	IntToString(GetLanguageByName(g_szLanguages[lang_id]), sLangID, sizeof(sLangID));
	new iLangID = StringToInt(sLangID);
	SetClientLanguage(client, iLangID);
}

public OptionMenu(client)
{
	g_bMenuOpen[client] = true;
	new Handle:optionmenu = CreateMenu(OptionMenuHandler);
	SetMenuTitle(optionmenu, "KZTimer - Options");

	decl String:buffer[64];

	//0
	switch(g_ClientLang[client])
	{
		case 0: Format(buffer, sizeof(buffer), "%T", "options_lang_en", client);
		case 1: Format(buffer, sizeof(buffer), "%T", "options_lang_de", client);
		case 2: Format(buffer, sizeof(buffer), "%T", "options_lang_sv", client);
		case 3: Format(buffer, sizeof(buffer), "%T", "options_lang_fr", client);
		case 4: Format(buffer, sizeof(buffer), "%T", "options_lang_ru", client);
		case 5: Format(buffer, sizeof(buffer), "%T", "options_lang_cn", client);
		case 6: Format(buffer, sizeof(buffer), "%T", "options_lang_pt", client);
		case 7: Format(buffer, sizeof(buffer), "%T", "options_lang_fi", client);
	}
	AddMenuItem(optionmenu, "", buffer);

	//1
	if (g_bAdvancedClimbersMenu[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_adv_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_adv_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//2
	if (g_bHide[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_hide_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_hide_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//3
	if (g_bReplayRoute[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_rp_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_rp_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}

	//4
	if (g_ColorChat[client] == 0)
	{
		Format(buffer, sizeof(buffer), "%T", "options_colorchat_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
		if (g_ColorChat[client] == 1)
		{
			Format(buffer, sizeof(buffer), "%T", "options_colorchat_on", client);
			AddMenuItem(optionmenu, "", buffer);
		}
		else if (g_ColorChat[client] == 2)
		{
			Format(buffer, sizeof(buffer), "%T", "options_colorchat_only_red", client);
			AddMenuItem(optionmenu, "", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%T", "options_colorchat_none_only_yours", client);
			AddMenuItem(optionmenu, "", buffer);
		}
	//5
	if (g_bCPTextMessage[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_cpmessage_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_cpmessage_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//6
	if (g_bClimbersMenuSounds[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_menusounds_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_menusounds_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//7
	if (g_EnableQuakeSounds[client] == 0 )
	{
		Format(buffer, sizeof(buffer), "%T", "options_quakesounds_none", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
		if (g_EnableQuakeSounds[client] == 1 )
		{
			Format(buffer, sizeof(buffer), "%T", "options_quakesounds_all", client);
			AddMenuItem(optionmenu, "", buffer);
		}
		else if (g_EnableQuakeSounds[client] == 2)
		{
			Format(buffer, sizeof(buffer), "%T", "options_quakesounds_godlike_records_only", client);
			AddMenuItem(optionmenu, "", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%T", "options_quakesounds_records_only", client);
			AddMenuItem(optionmenu, "", buffer);
		}
	//8
	if (g_bStrafeSync[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_strafesync_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_strafesync_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//9
	if (g_bShowTime[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_timertext_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_timertext_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//10
	if (g_ShowSpecs[client] == 0)
	{
		Format(buffer, sizeof(buffer), "%T", "options_speclist_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
		if (g_ShowSpecs[client] == 1)
		{
			Format(buffer, sizeof(buffer), "%T", "options_speclist_counter_only", client);
			AddMenuItem(optionmenu, "", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%T", "options_speclist_off", client);
			AddMenuItem(optionmenu, "", buffer);
		}
	//11
	if (g_bInfoPanel[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_centerpanel_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_centerpanel_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//12
	if (g_bAdvInfoPanel[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_advcp_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_advcp_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//13
	if (g_bStartWithUsp[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_start_weapon_usp", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_start_weapon_knife", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//14
	if (g_bJumpBeam[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_jumpbeam_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_jumpbeam_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//15
	if (g_bHideChat[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_chat_hidden", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_chat_visible", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//16
	if (g_bViewModel[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_weaponmodel_visible", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_weaponmodel_hidden", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//17
	if (g_bGoToClient[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_gotome_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_gotome_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//18
	if (g_bErrorSounds[client])
	{
		Format(buffer, sizeof(buffer), "%T", "options_error_sounds_on", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "options_error_sounds_off", client);
		AddMenuItem(optionmenu, "", buffer);
	}
	//19
	if (g_bAutoBhop)
	{
		if (g_bAutoBhopClient[client])
		{
			Format(buffer, sizeof(buffer), "%T", "options_autobhop_on", client);
			AddMenuItem(optionmenu, "", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "%T", "options_autobhop_off", client);
			AddMenuItem(optionmenu, "", buffer);
		}
	}
	

	SetMenuOptionFlags(optionmenu, MENUFLAG_BUTTON_EXIT);
	if (g_OptionsMenuLastPage[client] < 6)
		DisplayMenuAtItem(optionmenu, client, 0, MENU_TIME_FOREVER);
	else
		if (g_OptionsMenuLastPage[client] < 12)
			DisplayMenuAtItem(optionmenu, client, 6, MENU_TIME_FOREVER);
		else
			if (g_OptionsMenuLastPage[client] < 18)
				DisplayMenuAtItem(optionmenu, client, 12, MENU_TIME_FOREVER);
			else
				if (g_OptionsMenuLastPage[client] < 24)
					DisplayMenuAtItem(optionmenu, client, 18, MENU_TIME_FOREVER);
}

public OptionMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: SetClientLang(param1);
			case 1: AdvClimbersMenu(param1);
			case 2: HideMethod(param1);
			case 3: ReplayRoute(param1);
			case 4: ColorChat(param1);
			case 5: CPMessage(param1);
			case 6: ClimbersMenuSounds(param1);
			case 7: QuakeSounds(param1);
			case 8: StrafeSync(param1);
			case 9: ShowTime(param1);
			case 10: HideSpecs(param1);
			case 11: InfoPanel(param1);
			case 12: AdvInfoPanel(param1);
			case 13: SwitchStartWeapon(param1);
			case 14: PlayerJumpBeam(param1);
			case 15: HideChat(param1);
			case 16: HideViewModel(param1);
			case 17: DisableGoTo(param1);
			case 18: DisableSounds(param1);
			case 19: AutoBhop(param1);
		}
		g_OptionsMenuLastPage[param1] = param2;
		OptionMenu(param1);
	}
	else
		if(action == MenuAction_Cancel)
		{
			if (param2!=9)
				g_bMenuOpen[param1]=false;
		}
		else
			if (action == MenuAction_End)
			{
				CloseHandle(menu);
			}
}

public SwitchStartWeapon(client)
{
	g_bStartWithUsp[client] = !g_bStartWithUsp[client];
}
