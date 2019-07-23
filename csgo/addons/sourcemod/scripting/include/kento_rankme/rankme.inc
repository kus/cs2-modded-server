#if defined _rankme_included
  #endinput
#endif
#define _rankme_included

enum WEAPONS_ENUM{
	KNIFE,
	GLOCK,
	HKP2000,
	USP_SILENCER,
	P250,
	DEAGLE,
	ELITE,
	FIVESEVEN,
	TEC9,
	CZ75A,
	REVOLVER,
	NOVA,
	XM1014,
	MAG7,
	SAWEDOFF,
	BIZON,
	MAC10,
	MP9,
	MP7,
	UMP45,
	P90,
	GALILAR,
	AK47,
	SCAR20,
	FAMAS,
	M4A1,
	M4A1_SILENCER,
	AUG,
	SSG08,
	SG556,
	AWP,
	G3SG1,
	M249,
	NEGEV,
	HEGRENADE,
	FLASHBANG,
	SMOKEGRENADE,
	INFERNO,
	DECOY,
	TASER,
	MP5SD,
	BREACHCHARGE,
}

enum STATS_NAMES{
	SCORE,
	KILLS,
	DEATHS,
	ASSISTS,
	SUICIDES,
	TK,
	SHOTS,
	HITS,
	HEADSHOTS,
	CONNECTED,
	ROUNDS_TR,
	ROUNDS_CT,
	C4_PLANTED,
	C4_EXPLODED,
	C4_DEFUSED,
	CT_WIN,
	TR_WIN,
	HOSTAGES_RESCUED,
	VIP_KILLED,
	VIP_ESCAPED,
	VIP_PLAYED,
	MVP,
	DAMAGE,
	MATCH_WIN,
	MATCH_DRAW,
	MATCH_LOSE,
	FB,
	NS,
	NSD
}

enum HITBOXES{
	NULL_HITBOX,
	HEAD,
	CHEST,
	STOMACH,
	LEFT_ARM,
	RIGHT_ARM,
	LEFT_LEG,
	RIGHT_LEG
}


public SharedPlugin __pl_rankme= 
{
	name = "rankme",
	file = "kento_rankme.smx",
	#if defined REQUIRE_PLUGIN
	required = 1
	#else
	required = 0
	#endif
}

typedef RankCallback = function Action(int client, int rank, any data);

public void __pl_rankme_SetNTVOptional()
{
	MarkNativeAsOptional("RankMe_GivePoint");
	MarkNativeAsOptional("RankMe_GetRank");
	MarkNativeAsOptional("RankMe_GetPoints");
	MarkNativeAsOptional("RankMe_GetStats");
	MarkNativeAsOptional("RankMe_GetSession");
	MarkNativeAsOptional("RankMe_GetWeaponStats");
	MarkNativeAsOptional("RankMe_GetHitbox");
	MarkNativeAsOptional("RankMe_IsPlayerLoaded");
}

/*********************************************************
 * Give point(s) to a player on the server
 *
 * @param client	The client index of the player to receive the points
 * @param points		Points to be given to the player
 * @param reason	The reason to be given the points
 * @param printtoplayer	Print the change to the player
 * @param printtoall	Print the change to the everyone
 * @noreturn		
 *********************************************************/
native void RankMe_GivePoint(int client, int points, char[] reason, int printtoplayer, int printtoall);

/*********************************************************
 * Get rank of a player on the server
 *
 * @param client	The client index of the player to get the rank
 * @param callback	The return Callback
 * @param data	Any data you would like that return on the callback
 * @noreturn		
 *********************************************************/
native void RankMe_GetRank(int client, RankCallback callback, any data = 0);

/*********************************************************
 * Get the score (points) of a player on the server
 *
 * @param client	The client index of the player to get the rank
 * @param data	Any data you would like that return on the callback
 * @return		The score of the client
 *********************************************************/
native int RankMe_GetPoints(int client);

/*********************************************************
 * Get stats of a player on the server
 *
 * @param client	The client index of the player to get the stats
 * @param stats_return	The array that will return the data following the ENUM STATS_NAME;
 * @noreturn		
 *********************************************************/
native void RankMe_GetStats(int client, int[] stats_return);

/*********************************************************
 * Get session of a player on the server
 *
 * @param client	The client index of the player to get the session
 * @param session_return	The array that will return the data following the ENUM STATS_NAME;
 * @noreturn		
 *********************************************************/
native void RankMe_GetSession(int client,int[] session_return);

/*********************************************************
 * Get weapon stats of a player on the server
 *
 * @param client	The client index of the player to get the session
 * @param session_return	The array that will return the data following the ENUM WEAPONS_ENUM;
 * @noreturn		
 *********************************************************/
native void RankMe_GetWeaponStats(int client, int[] weapons_return);

/*********************************************************
 * Get hitbox stats of a player on the server
 *
 * @param client	The client index of the player to get the session
 * @param session_return	The array that will return the data following the ENUM HITBOXES;
 * @noreturn		
 *********************************************************/
native void RankMe_GetHitbox(int client, int[] hitbox_return);

/*********************************************************
 * Get if player is loaded 
 *
 * @param client	Client index
 * @return			If the client is loaded
 *********************************************************/
native void RankMe_IsPlayerLoaded(int client);

/**********************************************************************
 * When a player has been loaded
 * *
 * @param         client        The client index of the player that has been loaded
 * @noreturn
 **********************************************************************/
forward Action RankMe_OnPlayerLoaded(int client);

/**********************************************************************
 * When a player has been saved
 * *
 * @param         client        The client index of the player that has been saved
 * @noreturn
 **********************************************************************/
forward Action RankMe_OnPlayerSaved(int client);