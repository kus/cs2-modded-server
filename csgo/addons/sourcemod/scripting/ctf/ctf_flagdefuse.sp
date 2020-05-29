void StartDefusingFlag(int client)
{
	//b_DefusingFlag[client] = true;
	
	//int StartedDefusing = RoundToNearest(GetGameTime() + 1050);
	//SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	//SetEntProp(client, Prop_Send, "m_iProgressBarDuration",RoundToNearest(StartedDefusing-GetGameTime()));
	
	//DefuseTimer[client] = CreateTimer(10.0, TimerDefuse, client);

	int team = GetClientTeam(client);
	if(IsClientValid(client))
	{
		if(team == CS_TEAM_CT)
		{
			SpawnFlag(CS_TEAM_CT, FLAGTYPE_SPAWN, true, -1);
			Sound_BlueFlagReturned();	
		} else if(team == CS_TEAM_T) {
			SpawnFlag(CS_TEAM_T, FLAGTYPE_SPAWN, true, -1);
			Sound_RedFlagReturned();
		}
	}
	
}

public void OnEndTouch(int entity, int client) 
{
	if(!IsClientValid(client))
		return;
	
	if(DefuseTimer[client] != null)
		StopDefusing(client);
}

public Action TimerDefuse(Handle tmr, any client)
{
	StopDefusing(client);
	int team = GetClientTeam(client);
	if(IsClientValid(client))
	{
		if(team == CS_TEAM_CT)
		{
			SpawnFlag(CS_TEAM_CT, FLAGTYPE_SPAWN, true, -1);
			Sound_BlueFlagReturned();	
		} else if(team == CS_TEAM_T) {
			SpawnFlag(CS_TEAM_T, FLAGTYPE_SPAWN, true, -1);
			Sound_RedFlagReturned();
		}
	}
	
}


void StopDefusing(int client)
{
	if(b_DefusingFlag[client])
	{
		SetEntProp(client, Prop_Send, "m_iProgressBarDuration",0);	
		b_DefusingFlag[client] = false;
	}
	
	KillDefuseTimer(client);
}


void KillDefuseTimer(client)
{
	if (DefuseTimer[client] != null)
	{
		KillTimer(DefuseTimer[client]);
		DefuseTimer[client] = null;
	}
}