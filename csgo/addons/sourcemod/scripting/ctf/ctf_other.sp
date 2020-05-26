void SetTeamFlag(int team, int entity)
{
	if(team == CS_TEAM_T)
		t_Flag = entity;
	else if(team == CS_TEAM_CT)
		ct_Flag = entity;
}

int GetTeamFlag(int team)
{
	if(team == CS_TEAM_T)
		return t_Flag;
	else if(team == CS_TEAM_CT)
		return ct_Flag;
		
	return -1;
}

void SetTeamPole(int team, int entity)
{
	if(team == CS_TEAM_T)
		t_Pole = entity;
	else if(team == CS_TEAM_CT)
		ct_Pole = entity;
}

int GetTeamPole(int team)
{
	if(team == CS_TEAM_T)
		return t_Pole;
	else if(team == CS_TEAM_CT)
		return ct_Pole;
		
	return -1;
}

bool IsClientValid(int client)
{
	if(client < 1 || client > MaxClients + 1)
		return false;
	
	if(!IsClientInGame(client) || !IsPlayerAlive(client))
		return false;
	
	return true;
}

public int GetTotalRoundTime() 
{
	return GameRules_GetProp("m_iRoundTime");
}

public int GetCurrentRoundTime() 
{
	Handle h_freezeTime = FindConVar("mp_freezetime");
	int freezeTime = GetConVarInt(h_freezeTime);
	return (GetTime() - g_roundStartedTime) - freezeTime;
}