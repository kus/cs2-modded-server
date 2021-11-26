public Action Event_OnRoundPreStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	UpdateTeams();
	
	return Plugin_Continue;
}

public Action Event_OnRoundPostStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	g_iRoundStart = GetTime();
	return Plugin_Continue;
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	SpawnMapModels();
	
	g_iRoundStart = GetTime();
	
	RemoveGameplayEdicts();
	
	g_hRoundEndTimer = CreateTimer(1.0, Timer_CheckRoundEnd, _ , TIMER_REPEAT);
	
	return Plugin_Continue;
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	RemoveMapModels();
	
	// round has ended. used to not decrease seekers hp on shoot
	g_iRoundStart = 0;
	
	delete g_hRoundTimeTimer;
	delete g_hAfterFreezeTimer;
	delete g_hRoundEndTimer;
	
	return Plugin_Continue;
}

// give terrorists frags
public Action Event_OnRoundEnd_Pre(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	int winnerTeam = GetEventInt(event, "winner");
	
	if (winnerTeam == CS_TEAM_T)
	{
		LoopAlivePlayers(i)
		{
			// Godmode for alive players
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_CheckRoundEnd(Handle timer)
{
	if(!Ready())
		return Plugin_Continue;
		
	int iTimeLeft = GameRules_GetProp("m_iRoundTime");
	
	if(iTimeLeft > 1)
		return Plugin_Continue;
	
	int winnerTeam;
	bool aliveTs;
	
	LoopAlivePlayers(i)
	{
		if (GetClientTeam(i) == CS_TEAM_T)
		{
			aliveTs = true;
			break;
		}
	}
	
	if (aliveTs)
		winnerTeam = CS_TEAM_T;
	else winnerTeam = CS_TEAM_CT;
	
	ForceRoundEnd(winnerTeam, true);
	g_hRoundEndTimer = null;
	
	return Plugin_Stop;
}

public Action Timer_AfterFreezeTime(Handle timer)
{
	if(!Ready())
		return Plugin_Continue;
	
	g_hAfterFreezeTimer = null;
	
	SortStopItems();
	
	StartCheckTeamsTimer();
	
	LoopIngameClients(iClient)
	{
		if(GetClientTeam(iClient) == CS_TEAM_CT)
			CPrintToChat(iClient, "%s %t", PREFIX, "Find all demons");
	}
	
	Call_StartForward(g_OnFreezeTimeEnd);
	Call_Finish();
	
	return Plugin_Continue;
}

int GetHideTimeLeft()
{
	int iDisable = g_iRoundStart + RoundFloat(g_cvHideTime.FloatValue);
	int iTime = GetTime();
	
	if(iDisable > iTime)
		return iDisable - iTime;
	
	return 0;
}