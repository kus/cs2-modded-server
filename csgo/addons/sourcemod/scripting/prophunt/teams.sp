Handle g_aQueue = null; // List of players which like to join CT

void UpdateTeams()
{
	CleanUpQueue();
	
	int iPlayers;
	int iMaxCTs = GetMaxAllowedSeekers(iPlayers);
	
	// Get CTs
	bool bMoveToCT[MAXPLAYERS + 1];
	int iCTs;
	
	// Player queue
	int iNext;
	while((iNext = GetClientQueueNext()) != -1)
	{
		if(iCTs > iMaxCTs)
			break;
		
		RemoveFromArray(g_aQueue, 0); // Remove him from queue
		
		bMoveToCT[iNext] = true;
		iCTs++;
		iPlayers--;
	}
	
	int iLast;
	// Do not disturb the only player on the server
	if(iPlayers > 1 && iCTs < iMaxCTs)
	{
		// Get random players to play as CT
		int ttl = 50;
		int ttlprio = 10;
		while(iCTs < iMaxCTs && ttl > 0)
		{
			ttl--;
			
			int iNewTarget = GetRandomClient(CS_TEAM_NONE);
			
			if(iNewTarget <= 1)
				break; // No clients available?
			
			if(ttlprio >= ttl || iNewTarget != iLast || !g_bSeeker[iLast])
			{
				iLast = iNewTarget;
				if(!bMoveToCT[iNewTarget] && GetClientTeam(iNewTarget) > CS_TEAM_SPECTATOR)
				{
					bMoveToCT[iNewTarget] = true;
					iCTs++;
				}
			}
		}
	
		// Random method failed, lets do a simple loop for missing CTs
		if(iCTs < iMaxCTs)
		{
			LoopIngameClients(iNextTarget)
			{
				if(bMoveToCT[iNextTarget])
					continue;
					
				if(IsClientSourceTV(iNextTarget))
					continue;
				
				if(GetClientTeam(iNextTarget) <= CS_TEAM_SPECTATOR)
					continue;
				
				bMoveToCT[iNextTarget] = true;
				iCTs++;
				
				if(iCTs == iMaxCTs)
					break;
			}
		}
	}
	
	LoopIngameClients(i)
	{
		if(IsClientSourceTV(i))
			continue;
		
		if(bMoveToCT[i])
			MovePlayerToTeam(i, CS_TEAM_CT); // Ignored when player is already on CT side
		else MovePlayerToTeam(i, CS_TEAM_T);
	}
}

bool g_bAllowTeamChange[MAXPLAYERS + 1];

void MovePlayerToTeam(int iClient, int team)
{
	if (GetClientTeam(iClient) == team)
		return;
	
	g_bAllowTeamChange[iClient] = true; // Allow client to pass inside Hook_ChangeTeamChange()
	
	if (team > CS_TEAM_SPECTATOR)
	{
		CS_SwitchTeam(iClient, team); // Switch team using cstrike extension
		
		if(team == CS_TEAM_CT) // Don't override hider models
			CS_UpdateClientModel(iClient); // Update CT skin
	}
	else ChangeClientTeam(iClient, team); // Silent team change is enought, the player will die anyway if alive
	
	g_bAllowTeamChange[iClient] = false; // We can reset this here already, the callback is instant
}

public Action Hook_ChangeTeamChange(int iClient, const char[] command, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	CreateTimer(1.0, Timer_CheckRestart, _, TIMER_FLAG_NO_MAPCHANGE);
	
	if (iArgs < 1)
		return Plugin_Handled;
	
	// Bots will join anyway
	if(IsFakeClient(iClient))
		return Plugin_Continue;
	
	char sArg[4];
	GetCmdArg(1, sArg, sizeof(sArg));
	
	int team_to = StringToInt(sArg);
	int team_from = GetClientTeam(iClient);
	
	if(g_bAllowTeamChange[iClient])
		return Plugin_Continue; // Teamchange called by MovePlayerToTeam()
	
	if (team_to == CS_TEAM_SPECTATOR && team_from == CS_TEAM_NONE)
		return Plugin_Continue; // First team join (when player fully connected)
	
	// Late join?
	
	int iHideTime = PH_CanChangeModel();
	if(iHideTime > 0)
	{
		bool bAliveCTs;
		
		LoopAlivePlayers(i)
		{
			if(i == iClient)
				continue;
			
			if(GetClientTeam(i) != CS_TEAM_CT)
				continue;
			
			bAliveCTs = true;
			break;
		}
		
		if(bAliveCTs)
		{
			// There is another alive CTs, let him pass
			MovePlayerToTeam(iClient, CS_TEAM_T);
			CS_RespawnPlayer(iClient);
			return Plugin_Handled;
		}
		
		if (team_to == CS_TEAM_T && team_from == CS_TEAM_CT && !bAliveCTs)
			return Plugin_Handled;
	}
	
	// From here we only handle manual team join requests
	
	if(team_to == CS_TEAM_CT)
	{
		// If the player likes to join CT lets enqueue him
		CPrintToChat(iClient, "%s %t", PREFIX , "You have been added to seeker team", AddClientToQueue(iClient));
		return Plugin_Continue; // Always allow joining CT (fuck team spec glow wh, force all dead players to CT)
	}
	
	// Allow joining spectators and seekers always
	if(team_to == CS_TEAM_SPECTATOR)
		return Plugin_Handled;
	
	// Don't allow to change team while alive
	if(IsPlayerAlive(iClient))
		return Plugin_Handled;
	
	// Move to CT by default
	MovePlayerToTeam(iClient, CS_TEAM_CT);
	
	return Plugin_Handled;
}

void StartCheckTeamsTimer()
{
	if(g_hCheckTeams != null)
		delete g_hCheckTeams;
	
	g_hCheckTeams = CreateTimer(1.5, Timer_CheckRestart, _, TIMER_FLAG_NO_MAPCHANGE);
}

// Check if a round restart is required
public Action Timer_CheckRestart(Handle timer, any data)
{
	if(!Ready())
		return Plugin_Continue;
	
	g_hCheckTeams = null;
	
	int iCTs, iCTsAlive;
	int iTs, iTsAlive;
	int iPlayers;
	
	LoopIngameClients(i)
	{
		if(IsClientSourceTV(i))
			continue;
		
		int iTeam = GetClientTeam(i);
		if(iTeam == CS_TEAM_CT)
		{
			iPlayers++;
			iCTs++;
			if(IsPlayerAlive(i))
				iCTsAlive++;
		}
		else if(iTeam == CS_TEAM_T)
		{
			iPlayers++;
			iTs++;
			if(IsPlayerAlive(i))
				iTsAlive++;
		}
	}
	
	if(iPlayers == 0) // Teams have no players
		return Plugin_Handled;
	
	if(iCTsAlive > 0 && iTsAlive > 0) // Both teams have alive players
		return Plugin_Handled;
	
	if((iCTsAlive == 0 && iCTs > iCTsAlive) || (iTsAlive == 0 && iTs > iTsAlive)) // No alive players on one side but dead players
		ForceRoundEnd(CS_TEAM_NONE, true);
	
	if((iTsAlive == 0 && iCTs > iCTsAlive)) // No alive Ts but CTs wait for respawn
		ForceRoundEnd(CS_TEAM_NONE, true);
	
	if((iTsAlive == 0 && iCTs > 1)) // No alive Ts but multiple CTs
		ForceRoundEnd(CS_TEAM_NONE, true);
	
	return Plugin_Handled;
}

// Used by Request frame
public void MovetoCT(any userid)
{
	int iClient = GetClientOfUserId(userid);
	
	if(iClient && !IsPlayerAlive(iClient))
		MovePlayerToTeam(iClient, CS_TEAM_CT);
}

// Returns the max amount of seekers allows by the current amount of players
int GetMaxAllowedSeekers(int &iCount)
{
	LoopIngameClients(i)
	{
		if(IsClientSourceTV(i))
			continue;
			
		if(GetClientTeam(i) <= CS_TEAM_SPECTATOR)
			continue;
		
		iCount++;
	}
	
	if(iCount == 1)
		return 1;
	
	for (int i = 0; i < sizeof(g_cvBalancer); i++)
	{
		if(iCount >= g_cvBalancer[i][0].IntValue)
			return g_cvBalancer[i][1].IntValue;
	}
	
	return 1;
}

/* Seeker Queue System */

int AddClientToQueue(int iClient)
{
	CleanUpQueue();
	
	// Player already in queue, just return queue position
	if(IsClientInQueue(iClient))
		return GetClientQueuePosition(iClient);
		
	PushArrayCell(g_aQueue, GetClientUserId(iClient));
	
	CleanUpQueue();
	
	int iPos = GetClientQueuePosition(iClient);
	
	return iPos;
}

bool IsClientInQueue(int iClient)
{
	CleanUpQueue();
	
	LoopArray(i, g_aQueue)
	{
		int iClient2 = GetClientOfUserId(GetArrayCell(g_aQueue, i));
		
		// Player already in queue
		if(iClient == iClient2)
			return true;
	}
	
	return false;
}

int GetClientQueuePosition(int iClient)
{
	CleanUpQueue();
	
	LoopArray(i, g_aQueue)
	{
		int iClient2 = GetClientOfUserId(GetArrayCell(g_aQueue, i));
		
		// Player already in queue
		if(iClient == iClient2)
			return i+1;
	}
	
	return -1;
}

int GetClientQueueNext()
{
	CleanUpQueue();
	
	if(GetArraySize(g_aQueue) < 1)
		return -1;
	
	return GetClientOfUserId(GetArrayCell(g_aQueue, 0));
}

void CleanUpQueue()
{
	if(g_aQueue == null)
		g_aQueue = CreateArray(1);
	
	LoopArray(i, g_aQueue)
	{
		int iClient = GetClientOfUserId(GetArrayCell(g_aQueue, i));
		
		// Client is ingame and not observing
		if(iClient && !IsClientSourceTV(iClient))
			continue;
		
		// Player is not ingame anymore, has joined a team or is observing
		RemoveFromArray(g_aQueue, i);
		i--;
	}
	
	//SortADTArrayCustom(g_aQueue, SortQueueVIP);
}

/*
public int SortQueueVIP(int index1, int index2, Handle array, Handle hndl)
{
	int iClient[2];
	iClient[0] = GetClientOfUserId(GetArrayCell(array, index1));
	iClient[1] = GetClientOfUserId(GetArrayCell(array, index2));
	
	int iVIP[2];
	
	for (int i = 0; i < 2; i++)
	{
		if(Client_HasAdminFlags(iClient[i], ADMFLAG_RESERVATION))
			iVIP[i] += 1;
		if(Client_HasAdminFlags(iClient[i], ADMFLAG_BAN))
			iVIP[i] += 2;
		if(Client_HasAdminFlags(iClient[i], ADMFLAG_ROOT))
			iVIP[i] += 4;
	}
	
	int sort;
	
	if(iVIP[0] < iVIP[1])
		sort = 1;
	else if(iVIP[0] > iVIP[1])
		sort = -1;
	
	return sort;
}
*/