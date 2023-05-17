#if defined _zr_rank_included
  #endinput
#endif
#define _zr_rank_included


/*********************************************************
 * Get's the number of a player's points
 *
 * @param client		The client to get the points
 * @return				The number of points		
 *********************************************************/
native int ZR_Rank_GetPoints(int client);

/*********************************************************
 * Get's the number of a player's Zombie Kills
 *
 * @param client		The client to get the zombie kills
 * @return				The number of points		
 *********************************************************/
native int ZR_Rank_GetZombieKills(int client);

/*********************************************************
 * Get's the number of a player's Human Infects
 *
 * @param client		The client to get the zombie kills
 * @return				The number of points		
 *********************************************************/
native int ZR_Rank_GetHumanInfects(int client);

/*********************************************************
 * Get's the number of a player's Round Wins as Zombie
 *
 * @param client		The client to get the round wins
 * @return				The number of round wins		
 *********************************************************/
native int ZR_Rank_GetRoundWins_Zombie(int client);

/*********************************************************
 * Get's the number of a player's Round Wins as Human
 *
 * @param client		The client to get the round wins
 * @return				The number of round wins		
 *********************************************************/
native int ZR_Rank_GetRoundWins_Human(int client);

/*********************************************************
 * Sets points to a certain player
 *
 * @param client		The client to get the points
 * @param points		Number of points to set
 * @noreturn	
 *********************************************************/
native bool ZR_Rank_SetPoints(int client, int points);

/*********************************************************
 * Reset a Player's Stats
 *
 * @param client		The client to reset the data
 * @noreturn
 *********************************************************/
native bool ZR_Rank_ResetPlayer(int client);