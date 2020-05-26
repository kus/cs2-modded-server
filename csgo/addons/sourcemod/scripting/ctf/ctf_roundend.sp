void RoundEnd_OnRoundStart()
{
	b_JustEnded = false;
	g_roundStartedTime = GetTime();
}

void RoundEnd_OnGameFrame()
{
	if(GetTotalRoundTime() == GetCurrentRoundTime())
	{
		if(!b_JustEnded)
		{
			b_JustEnded = true;
			CreateTimer(1.0, JustEndedFalse);
		}
	}
}

public Action JustEndedFalse(Handle tmr, any client)
{
	OnTeamWin(CS_TEAM_NONE);
}

void OnTeamWin(int team)
{
	if(team == CS_TEAM_CT)
		CS_TerminateRound(10.0, CSRoundEnd_CTWin, true);
	else if(team == CS_TEAM_T)
		CS_TerminateRound(10.0, CSRoundEnd_TerroristWin, true);
	else if(team == CS_TEAM_NONE)
		CS_TerminateRound(10.0, CSRoundEnd_Draw, true);
		
	SetCvar("mp_maxrounds", "0");
	SetCvar("mp_timelimit", "0");
	SetCvar("mp_ignore_round_win_conditions", "1");
}