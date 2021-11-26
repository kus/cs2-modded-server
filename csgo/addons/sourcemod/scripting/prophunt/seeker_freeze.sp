bool g_bBlinded[MAXPLAYERS + 1];

bool Seeker_IsBlinded(int iClient)
{
	return g_bBlinded[iClient];
}

void StartBlindTimer()
{
	CreateTimer(0.1, Timer_BlindSeeker, _, TIMER_REPEAT);
}

public Action Timer_BlindSeeker(Handle timer, int data)
{
	if(!Ready())
		return Plugin_Continue;
	
	LoopClients(iClient)
	{
		if(!IsClientInGame(iClient))
			g_bBlinded[iClient] = false; // Reset
		else Seeker_Blind(iClient); // Update status
	}
	
	return Plugin_Continue;
}

void Seeker_Blind(int iClient, bool force = false, bool blind = false)
{
	if (iClient < 1 || !IsClientInGame(iClient))
		return;
	
	// No override: Freezetime active for seekers, is CT side & alive
	if (!force && float(GetTime() - g_iRoundStart) < g_cvHideTime.FloatValue && GetClientTeam(iClient) == CS_TEAM_CT && IsPlayerAlive(iClient))
		blind = true;
	
	if(blind || blind != g_bBlinded[iClient])
	{
		g_bBlinded[iClient] = blind;
		
		Client_Blind(iClient, blind);
		Client_BlockControls(iClient, blind);
		SetEntityMoveType(iClient, blind ? MOVETYPE_NONE : MOVETYPE_WALK);
	}
}