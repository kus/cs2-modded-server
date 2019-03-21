/** Double-include prevention */
#if defined _warmod_included_
  #endinput
#endif
#define _warmod_included_

#define SPECTATOR_TEAM			1
#define TERRORIST_TEAM			2
#define COUNTER_TERRORIST_TEAM	3

#define DEFAULT_SPECTATOR_NAME	"Spectators"
#define DEFAULT_T_NAME			"Terrorists"
#define DEFAULT_CT_NAME			"Counter-Terrorists"

#define PLAYER_DISC				-1
#define PLAYER_READY			1
#define PLAYER_UNREADY			2

#define SCORE_T					0
#define SCORE_CT				1

#define SCORE_FIRST_HALF		0
#define SCORE_SECOND_HALF		1

#define DMG_MSG_SIZE			8192

#define MAX_PARAM_SIZE			512

#define NUM_WEAPONS				41
#define LOG_HIT_OFFSET			7

#define LOG_HIT_SHOTS			0
#define LOG_HIT_HITS			1
#define LOG_HIT_KILLS			2
#define LOG_HIT_HEADSHOTS		3
#define LOG_HIT_TEAMKILLS		4
#define LOG_HIT_DAMAGE			5
#define LOG_HIT_DEATHS			6
#define LOG_HIT_GENERIC			7
#define LOG_HIT_HEAD			8
#define LOG_HIT_CHEST			9
#define LOG_HIT_STOMACH			10
#define LOG_HIT_LEFTARM			11
#define LOG_HIT_RIGHTARM		12
#define LOG_HIT_LEFTLEG			13
#define LOG_HIT_RIGHTLEG		14
#define LOG_HIT_TEAM_HITS		15
#define LOG_HIT_TEAM_DAMAGE		16
#define LOG_HIT_NUM				17

#define ASSIST_COUNT			0
#define ASSIST_COUNT_TK			1
#define ASSIST_NUM				2

#define CLUTCH_LAST				0
#define CLUTCH_VERSUS			1
#define CLUTCH_FRAGS			2
#define CLUTCH_WON				3
#define CLUTCH_NUM				4

#define MATCH_SHOTS				0
#define MATCH_HITS				1
#define MATCH_KILLS				2
#define MATCH_HEADSHOTS			3
#define MATCH_TEAMKILLS			4
#define MATCH_DAMAGE			5
#define MATCH_ASSIST			6
#define MATCH_DEATHS			7
#define MATCH_ATA				8
#define MATCH_1K				9
#define MATCH_2K				10
#define MATCH_3K				11
#define MATCH_4K				12
#define MATCH_5K				13
#define MATCH_ROUND				14
#define MATCH_LAST				15
#define MATCH_WON				16
#define MATCH_NUM				17

char g_team_name_cache[16][64];

/**
 *  called when a log event is produced 
 * 
 * @noreturn		
 */
forward void LiveWireLogEvent(const char[] event);

/**
 *  called when a match starting LiveOn3 
 * 
 * @noreturn		
 */
forward void OnLiveOn3();

/**
 *  called when a match reaches half time
 *  includes when in overtime
 * 
 * @noreturn
 */
forward void OnRoundEnd(const char[] ct_name, int ct_score, int t_score, const char[] t_name);


/**
 *  called when a match reaches half time
 *  includes when in overtime
 * 
 * @noreturn
 */
forward void OnHalfTime(const char[] ct_name, int ct_score, int t_score, const char[] t_name);


/**
 *  called when a match reaches full time
 *  not called if match is prematurely reset
 * 
 * @noreturn
 */
forward void OnEndMatch(const char[] ct_name, int ct_score, int t_score, const char[] t_name);


/**
 *  called when a match half is reset
 *  only occurs if match was currently underway
 * 
 * @noreturn
 */
forward void OnResetHalf();


/**
 *  called when a match is reset
 *  only occurs if match was currently underway
 * 
 * @noreturn
 */
forward void OnResetMatch();

/**
 * Sets the money for clients
 *
 * @param num1    Start Money as an integer.
 * @return        String - error or comfirm setting
 */

stock void WM_PrintToChat(int client, char[] format, any ...)
{
	char message[4096];
	VFormat(message, sizeof(message), format, 3);
	char lines[12][256];
	int numLines = ExplodeString(message, "\n", lines, 12, 256, true);
	for (int i = 0; i < numLines; i++)
	{
		TrimString(lines[i]);
		if (!StrEqual(lines[i], ""))
		{
			PrintToChat(client, "%s%s", CHAT_PREFIX, lines[i]);
		}
	}
}

stock void GetServerString(char[] format, int size)
{
	char NetIP[32];
	int pieces[4];
	int longip = GetConVarInt(FindConVar("hostip"));
	char servername[255];
	GetConVarString(FindConVar("hostname"), servername, sizeof(servername));
	
	pieces[0] = (longip >> 24) & 0x000000FF;
	pieces[1] = (longip >> 16) & 0x000000FF;
	pieces[2] = (longip >> 8) & 0x000000FF;
	pieces[3] = longip & 0x000000FF;

	Format(NetIP, sizeof(NetIP), "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);
	
	Format(format, size, "{\"name\": \"%s\", \"ip\": \"%s\", \"port\": %i}", servername, NetIP, GetConVarInt(FindConVar("hostport")));
}

/**
 *  get the standard logstring ("player<userid><authid><team>") for the specified client
 * 
 * @param  client			the client index to get name for
 * @param  String:LogString	the buffer to save the logstring in
 * @param  size				the size of the buffer
 * @return 					-1 on not connected
 *							client index
 */

stock int CS_GetStandardLogString(int client, char[] LogString, int size)
{
	if (client == 0)
	{
		strcopy(LogString, size, "Console<0><Console><Console>");
		return client;
	}
	
	if (!IsClientInGame(client))
	{
		Format(LogString, size, "null");
		return -1;
	}

	int userid;
	char authid[32];
	char team_name[64];
	
	GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
	userid = GetClientUserId(client);
	GetTeamName2(GetClientTeam(client), team_name, sizeof(team_name));
	
	Format(LogString, size, "%N<%d><%s><%s>", client, userid, authid, team_name);

	return client;
}


/**
 *  get the warmod logstring for the specified client in json format
 * 
 * @param  client			the client index to get name for
 * @param  String:LogString	the buffer to save the logstring in
 * @param  size				the size of the buffer
 * @return 					-1 on not connected
 *							client index
 */

stock int CS_GetLogString(int client, char[] LogString, int size)
{
	if (client == 0)
	{
		strcopy(LogString, size, "{\"name\": \"Console\", \"userId\": 0, \"uniqueId\": \"Console\", \"team\": 0}");
		return client;
	}
	
	if (!IsClientInGame(client))
	{
		Format(LogString, size, "{}");
		return -1;
	}

	char player_name[64];
	int userid;
	char authid[32];
	
	GetClientName(client, player_name, sizeof(player_name));
	GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
	userid = GetClientUserId(client);
	
	EscapeString(player_name, sizeof(player_name));
	EscapeString(authid, sizeof(authid));
	Format(LogString, size, "{\"name\": \"%s\", \"userId\": %d, \"uniqueId\": \"%s\", \"team\": %d}", player_name, userid, authid, GetClientTeam(client));

	return client;
}


/**
 *  get the advanced logstring for the specified client in json format
 * 
 * @param  client			the client index to get name for
 * @param  String:LogString	the buffer to save the logstring in
 * @param  size				the size of the buffer
 * @return 					-1 on not connected
 *							client index
 */

stock int CS_GetAdvLogString(int client, char[] LogString, int size)
{
	if (client == 0 || !IsClientInGame(client))
	{
		Format(LogString, size, "{}");
		return -1;
	}
	
	char player_name[64];
	int userid;
	char authid[32];
	float player_origin[3];
	float eye_angles[3];
	
	GetClientName(client, player_name, sizeof(player_name));
	GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
	userid = GetClientUserId(client);
	
	GetClientAbsOrigin(client, player_origin);
	GetClientEyeAngles(client, eye_angles);

	EscapeString(player_name, sizeof(player_name));
	EscapeString(authid, sizeof(authid));
	Format(LogString, size, "{\"name\": \"%s\", \"userId\": %d, \"uniqueId\": \"%s\", \"team\": %d, \"origin\": {\"x\": %.2f, \"y\": %.2f, \"z\": %.2f}, \"velocity\": {\"x\": %.2f, \"y\": %.2f, \"z\": %.2f}, \"view\": {\"x\": %.2f, \"y\": %.2f, \"z\": %.2f}, \"health\": %d, \"armor\": %d, \"helmet\": %d}", player_name, userid, authid, GetClientTeam(client), player_origin[0], player_origin[1], player_origin[2] + GetEntPropFloat(client, Prop_Send, "m_vecViewOffset[2]"), GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]"), GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]"), GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]"), eye_angles[0], eye_angles[1], eye_angles[2], GetEntProp(client, Prop_Send, "m_iHealth"), GetEntProp(client, Prop_Send, "m_ArmorValue"), GetEntProp(client, Prop_Send, "m_bHasHelmet"));

	return client;
}


/**
 *  get the comma'd string version of an integer
 * 
 * @param  OldMoney			the integer to convert
 * @param  String:NewMoney	the buffer to save the string in
 * @param  size				the size of the buffer
 * @noreturn
 */

stock void IntToMoney(int OldMoney, char[] NewMoney, int size)
{
	char Temp[32];
	char OldMoneyStr[32];
	int tempChar;
	int RealLen = 0;

	IntToString(OldMoney, OldMoneyStr, sizeof(OldMoneyStr));

	for (int i = strlen(OldMoneyStr) - 1; i >= 0; i--)
	{
		if (RealLen % 3 == 0 && RealLen != strlen(OldMoneyStr) && i != strlen(OldMoneyStr)-1)
		{
			tempChar = OldMoneyStr[i];
			Format(Temp, sizeof(Temp), "%s,%s", tempChar, Temp);
		}
		else
		{
			tempChar = OldMoneyStr[i];
			Format(Temp, sizeof(Temp), "%s%s", tempChar, Temp);
		}
		RealLen++;
	}
	Format(NewMoney, size, "%s", Temp);
}


/**
 *  get the team index opposite to the specified team
 * 
 * @param  team		team index to get opposite of
 * @return			false on error
 *					team index
 */

stock int GetOtherTeam(int team)
{
	if (team == 2)
	{
		return 3;
	}
	else if (team == 3)
	{
		return 2;
	}
	else
	{
		return false;
	}
}


/**
 *  swap all players to the opposite team
 *  allows for skin choice
 * 
 * @noreturn
 */

stock void CS_SwapTeams()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
		{
			ChangeClientTeam(i, GetOtherTeam(GetClientTeam(i)));
		}
	}
}


/**
 *  returns number of clients currently playing on a team
 * 
 * return		count
 */

stock int CS_GetPlayingCount()
{
	int count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
		{
			count++;
		}
	}
	return count;
}


/**
 *  strip all weapons from specified client but the knife
 * 
 * @noreturn
 */

stock bool CS_StripButKnife(int client, bool equip=true)
{
	if (!IsClientInGame(client) || GetClientTeam(client) <= 1)
	{
		return false;
	}
	
	int item_index;
	for (int i = 0; i < 5; i++)
	{
		if (i == 2)
		{
			continue;
		}
		if ((item_index = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, item_index);
			RemoveEdict(item_index);
		}
		if (equip)
		{
			CS_EquipKnife(client);
		}
	}

	return true;
}


/**
 *  return the number of players alive on a given team
 * 
 * @noreturn
 */

stock int GetNumAlive(int team)
{
	int count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
		{
			count++;
		}
	}
	return count;
}


/**
 *  equip the specified client with the knife
 * 
 * @noreturn
 */

stock void CS_EquipKnife(int client)
{
	ClientCommand(client, "slot3");
}


/**
 *  removing filename invalid characters
 * 
 * @noreturn
 */

stock void StripFilename(char[] filename, int size)
{
	char cleanedName[64]; 
	int pos_cleanedName = 0; 
	for (int i = 0; i < size; i++)
	{ 
		if (IsCharAlpha(filename[i]) || IsCharNumeric(filename[i]))
		{ 
			cleanedName[pos_cleanedName++] = filename[i]; 
		} 
	} 

	// Terminate the string with 0 
	cleanedName[pos_cleanedName] = '\0';
	
	strcopy(filename, size, cleanedName);
}

/*	ReplaceString(filename, size, "\\", "");
	ReplaceString(filename, size, "/", "");
	ReplaceString(filename, size, ":", "");
	ReplaceString(filename, size, "#", "");
	ReplaceString(filename, size, "*", "");
	ReplaceString(filename, size, "?", "");
	ReplaceString(filename, size, "<", "");
	ReplaceString(filename, size, ">", "");
	ReplaceString(filename, size, "|", "");
	ReplaceString(filename, size, "'", "");
	ReplaceString(filename, size, ";", "");
	ReplaceString(filename, size, "+", "-");
	ReplaceString(filename, size, "`", "");
	ReplaceString(filename, size, "~", "");
	ReplaceString(filename, size, " ", "_");
}*/


/**
 *  converting a string to lowercase
 * 
 * @noreturn
 */

stock void StringToLower(char[] input, int size)
{
	for (int i = 0; i < size; i++)
	{
		input[i] = CharToLower(input[i]);
	}
}

/**
 *  converting a string to uppercase
 * 
 * @noreturn
 */

stock void StringToUpper(char[] input, int size)
{
	for (int i = 0; i < size; i++)
	{
		input[i] = CharToUpper(input[i]);
	}
}


/**
 *  hide setting an int cvar
 * 
 * @noreturn
 */
 
stock void SetConVarIntHidden(Handle cvar, const int value)
{
	char cvar_name[64];
	char value_string[512];
	int flags = GetConVarFlags(cvar);
	SetConVarFlags(cvar, flags & ~FCVAR_NOTIFY);
	SetConVarInt(cvar, value);
	GetConVarName(cvar, cvar_name, sizeof(cvar_name));
	IntToString(value, value_string, sizeof(value_string));
	SetConVarFlags(cvar, flags);
}


/**
 *  hide setting a string cvar
 * 
 * @noreturn
 */
 
stock void SetConVarStringHidden(Handle cvar, char[] value)
{
	char cvar_name[64];
	int flags = GetConVarFlags(cvar);
	SetConVarFlags(cvar, flags & ~FCVAR_NOTIFY);
	SetConVarString(cvar, value);
	GetConVarName(cvar, cvar_name, sizeof(cvar_name));
	SetConVarFlags(cvar, flags);
}


/**
 *  escape a string, designed for JSON encoding
 * 
 * @noreturn
 */

stock void EscapeString(char[] value, int size)
{
	ReplaceString(value, size, "\\", "\\\\");
	ReplaceString(value, size, "\"", "\\\"");
	ReplaceString(value, size, "\b", "\\b");
	ReplaceString(value, size, "\t", "\\t");
	ReplaceString(value, size, "\n", "\\n");
	ReplaceString(value, size, "\f", "\\f");
	ReplaceString(value, size, "\r", "\\r");
	ReplaceString(value, size, "\\", "");
	ReplaceString(value, size, "/", "");
	ReplaceString(value, size, "#", "");
	ReplaceString(value, size, "*", "");
	ReplaceString(value, size, "?", "");
	ReplaceString(value, size, "<", "");
	ReplaceString(value, size, ">", "");
	ReplaceString(value, size, "|", "");
	ReplaceString(value, size, "'", "");
	ReplaceString(value, size, ";", "");
	ReplaceString(value, size, "`", "");
	ReplaceString(value, size, "~", "");
}


/**
 * get the team name given by the game (e.g. TERRORIST and CT)
 *
 * @param  index			the team index
 * @param  String:team_name	the string buffer to place the name
 * @param  size				size of the buffer
 * @noreturn
 */

stock void GetTeamName2(int index,char[] team_name, int size)
{
	if (StrEqual(g_team_name_cache[index], ""))
	{
		GetTeamName(index, team_name, size);
		strcopy(g_team_name_cache[index], size, team_name);
	}
	
	strcopy(team_name, size, g_team_name_cache[index]);
}

stock bool InWarmup()
{
	return GameRules_GetProp("m_bWarmupPeriod") != 0;
}

stock bool IsPaused()
{ 
	return GameRules_GetProp("m_bMatchWaitingForResume") != 0; 
}