#include <sourcemod>
#include <cstrike>
#include <sdktools>

native RankMe_GetPoints(client);

public Plugin:myinfo = 
{
	name = "sm_rankshuffle",
	author = "Eyal282",
	description = "Shuffle teams by the rank of the players.",
	version = "1.0",
	url = "None."
}

public OnPluginStart()
{
	RegAdminCmd("sm_rankshuffle", RankScramble, ADMFLAG_KICK);
	RegAdminCmd("sm_rankscramble", RankScramble, ADMFLAG_KICK);		
}

public Action:CheckCommandAccess_Root(client, args)
{
	return Plugin_Handled;
}

public Action:RankScramble(client, args)
{
	new players[MAXPLAYERS], num = 0;
	
	for(new i=0;i <= MaxClients;i++)
	{
		players[i] = 0;
	}
	
	for(new i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		else if(IsFakeClient(i))
			continue;
			
		else if(GetClientTeam(i) != CS_TEAM_CT && GetClientTeam(i) != CS_TEAM_T)
			continue;
			
		players[num] = i;
		num++;
		ChangeClientTeam(i, 1);
	}
	
	SortCustom1D(players, MAXPLAYERS, SortByPPM);
	
	new bool:Terror = false;
	for(new i=0;i < MAXPLAYERS;i++)
	{
		new target = players[i];
		if(target == 0)
			continue;
			
		if(Terror)
			CS_SwitchTeam(target, CS_TEAM_T);
		
		else
			CS_SwitchTeam(target, CS_TEAM_CT);
			
		CS_RespawnPlayer(target);
		
		Terror = !Terror;
	}
}


public SortByPPM(player1, player2, Array[], Handle:hndl)
{		
	if(player1 == -1 && player2 == -1) 
		return 0;
	
	else if(player1 == -1 && player2 != -1)
		return 1;
	
	else if(player1 != -1 && player2 == -1)
		return -1;
		
	if(RankMe_GetPoints(player1) > RankMe_GetPoints(player2))
		return -1;
	
	else if(RankMe_GetPoints(player1) < RankMe_GetPoints(player2))
		return 1;
		
	return 0;
}
