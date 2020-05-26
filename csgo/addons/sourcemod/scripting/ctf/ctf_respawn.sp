void Respawn_OnPlayerDeath(int client)
{
	CreateTimer(8.0, RespawnPlayer, client);
	i_RespawnTime[client] = 8;
	RespawnTimers[client] = CreateTimer(1.0, RespawnTimerHnd, client, TIMER_REPEAT);
}

public Action CTF_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	float fRespawnTime = float(RespawnTime);
	CreateTimer(fRespawnTime, RespawnPlayer, client);
	
	i_RespawnTime[client] = RespawnTime;
	KillRespawnTmr(client);
	RespawnTimers[client] = CreateTimer(1.0, RespawnTimerHnd, client, TIMER_REPEAT);
}

void Respawn_OnPlayeDisconnect(int client)
{
	KillRespawnTmr(client);
}

public Action RespawnTimerHnd(Handle tmr, any client)
{
	if(IsClientInGame(client) && !IsPlayerAlive(client))
	{
		i_RespawnTime[client]--;
		PrintCenterText(client, "Respawing in %i sec", i_RespawnTime[client]);
	} else {
		KillRespawnTmr(client);
	}
	if(i_RespawnTime[client] == 0)
		KillRespawnTmr(client);
}

public Action RespawnPlayer(Handle tmr, any client)
{
	if(IsClientInGame(client) && !IsPlayerAlive(client))
		CS_RespawnPlayer(client);
}

void KillRespawnTmr(int client)
{
	if (RespawnTimers[client] != null)
	{
		KillTimer(RespawnTimers[client]);
		RespawnTimers[client] = null;
	}
}
