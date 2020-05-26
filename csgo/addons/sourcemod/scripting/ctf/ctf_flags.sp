void Flags_OnRoundStart()
{
	
	LoopAllPlayers(i)
	{
		b_FlagCarrier[i] = false;
		b_DefusingFlag[i] = false;
	}
	
	SpawnFlag(CS_TEAM_CT, FLAGTYPE_SPAWN, true, 0);
	SpawnFlag(CS_TEAM_T, FLAGTYPE_SPAWN, true, 0);
	
}

void Flags_OnPlayerDeath(int client)
{
	if(IsClientInGame(client))
	{
		int team = GetClientTeam(client);
		
		if(GetFlagCarrier(team) == client)
		{
			b_FlagCarrier[client] = false;
			
			if(team == CS_TEAM_CT) {
				SpawnFlag(CS_TEAM_T, FLAGTYPE_UNDERBODY, true, client);	
				Sound_RedFlagDropped();
			} else if(team == CS_TEAM_T) {
				SpawnFlag(CS_TEAM_CT, FLAGTYPE_UNDERBODY, true, client);	
				Sound_BlueFlagDropped();
			}
		}
	}

}

public void OnStartTouch(int entity, int client) 
{
	if(!IsClientValid(client))
		return;
		
	
	//All terrorist check
	if(GetClientTeam(client) == CS_TEAM_T)
	{
		//Touching T flag
		if(GetTeamPole(CS_TEAM_T) == entity)
		{
			//If flag is in spawn
			if(IsFlagInSpawn(CS_TEAM_T))
			{
				
				//If player is carrieng flag
				if(GetFlagCarrier(CS_TEAM_T) == client)
				{
					//Terrorists score
					SpawnFlag(CS_TEAM_CT, FLAGTYPE_SPAWN, true, -1);
					b_FlagCarrier[client] = false;
					//---
					Call_StartForward(g_OnFlagScore);
					Call_PushCell(client);
					Call_Finish();
					//--
					CreateParticle("weapon_confetti_balloons", CS_TEAM_CT);
					Sound_RedTeamScore();
					SetTeamScore(CS_TEAM_T, GetTeamScore(CS_TEAM_T) + 1);
					CS_SetMVPCount(client, CS_GetMVPCount(client) + 1);
					if(GetTeamScore(CS_TEAM_T) == MaxFlags)
						OnTeamWin(CS_TEAM_T);
				}
				
			//Wants to return the flag to base
			} else {
				StartDefusingFlag(client);
			}
		
		//Toching others teams flag
		} else if(GetTeamPole(CS_TEAM_CT) == entity) {
			
			SpawnFlag(CS_TEAM_CT, FLAGTYPE_ABOVE, false, client);
			Sound_RedTeamTakeFlag();
			LoopAllPlayers(i)
				if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT && DefuseTimer[i] != null)
					StopDefusing(i);

			
		}
	}
	
	
	
	//Counter-terrorist
	if(GetClientTeam(client) == CS_TEAM_CT)
	{
		if(GetTeamPole(CS_TEAM_CT) == entity)
		{
			if(IsFlagInSpawn(CS_TEAM_CT))
			{
				if(GetFlagCarrier(CS_TEAM_CT) == client)
				{
					//Event CT scores
					SpawnFlag(CS_TEAM_T, FLAGTYPE_SPAWN, true, -1);
					b_FlagCarrier[client] = false;
					//---
					Call_StartForward(g_OnFlagScore);
					Call_PushCell(client);
					Call_Finish();
					//--
					CreateParticle("weapon_confetti_balloons", CS_TEAM_T);
					Sound_BlueTeamScore();
					SetTeamScore(CS_TEAM_CT, GetTeamScore(CS_TEAM_CT) + 1);
					CS_SetMVPCount(client, CS_GetMVPCount(client) + 1);
					if(GetTeamScore(CS_TEAM_CT) == MaxFlags)
						OnTeamWin(CS_TEAM_CT);
				}

			} else {
				//Event - CT wants to return flag
				StartDefusingFlag(client);
			}

		} else if(GetTeamPole(CS_TEAM_T) == entity) {
			
			//Event - CT takes T flag
			SpawnFlag(CS_TEAM_T, FLAGTYPE_ABOVE, false, client);
			Sound_BlueTeamTakeFlag();
			
			LoopAllPlayers(i)
				if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && DefuseTimer[i] != null)
					StopDefusing(i);
			
		}
	}
	
	
}