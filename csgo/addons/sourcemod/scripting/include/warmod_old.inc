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
#define PLAYER_READY				1
#define PLAYER_UNREADY			2

#define SCORE_T					0
#define SCORE_CT					1

#define SCORE_FIRST_HALF			0
#define SCORE_SECOND_HALF		1

#define DMG_MSG_SIZE				8192

#define MAX_PARAM_SIZE			512

#define NUM_WEAPONS				41
#define LOG_HIT_OFFSET			7

#define LOG_HIT_SHOTS			0
#define LOG_HIT_HITS				1
#define LOG_HIT_KILLS			2
#define LOG_HIT_HEADSHOTS		3
#define LOG_HIT_TEAMKILLS		4
#define LOG_HIT_DAMAGE			5
#define LOG_HIT_DEATHS			6
#define LOG_HIT_GENERIC			7
#define LOG_HIT_HEAD				8
#define LOG_HIT_CHEST			9
#define LOG_HIT_STOMACH			10
#define LOG_HIT_LEFTARM			11
#define LOG_HIT_RIGHTARM			12
#define LOG_HIT_LEFTLEG			13
#define LOG_HIT_RIGHTLEG			14
#define LOG_HIT_NUM				15

#define ASSIST_COUNT				0
#define ASSIST_COUNT_TK			1
#define ASSIST_NUM				2

#define CLUTCH_LAST				0
#define CLUTCH_VERSUS			1
#define CLUTCH_FRAGS				2
#define CLUTCH_WON				3
#define CLUTCH_NUM				4

// Offsets
new g_iAccount = -1;

new String:g_team_name_cache[16][64];

/**
 *  called when a match starting LiveOn3 
 * 
 * @noreturn		
 */
forward OnLiveOn3();


/**
 *  called when a match reaches half time
 *  includes when in overtime
 * 
 * @noreturn
 */
forward OnHalfTime();


/**
 *  called when a match reaches full time
 *  not called if match is prematurely reset
 * 
 * @noreturn
 */
forward OnEndMatch();


/**
 *  called when a match half is reset
 *  only occurs if match was currently underway
 * 
 * @noreturn
 */
forward OnResetHalf();


/**
 *  called when a match is reset
 *  only occurs if match was currently underway
 * 
 * @noreturn
 */
forward OnResetMatch();

/**
 * Sets the money for clients
 *
 * @param num1    Start Money as an integer.
 * @return        String - error or comfirm setting
 */
native Set_StartMoney(num1);

/**
 * print a message to chat using the warmod prefix, splitting the message
 * by any newlines (12 max)
 *
 * @param  client			client to print the message to
 * @param  String:format	format string
 * @param  any:...			format string parameters (optional)
 * @noreturn
 */

stock WM_PrintToChat(client, String:format[], any:...)
{
	decl String:message[4096];
	VFormat(message, sizeof(message), format, 3);
	new String:lines[12][256];
	new numLines = ExplodeString(message, "\n", lines, 12, 256, true);
	for (new i = 0; i < numLines; i++)
	{
		TrimString(lines[i]);
		if (!StrEqual(lines[i], ""))
		{
			PrintToChat(client, "%s%s", CHAT_PREFIX, lines[i]);
		}
	}
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

stock CS_GetStandardLogString(client, String:LogString[], size)
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

	new userid;
	new String:authid[32];
	new String:team_name[64];
	
	GetClientAuthString(client, authid, sizeof(authid));
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

stock CS_GetLogString(client, String:LogString[], size)
{
	if (client == 0)
	{
		strcopy(LogString, size, "{\"name\": \"Console\", \"userId\": 0, \"uniqueId\": \"Console\", \"team\": 0}");
		return client;
	}
	
	if (!IsClientInGame(client))
	{
		Format(LogString, size, "null");
		return -1;
	}

	new String:player_name[64];
	new userid;
	new String:authid[32];
	
	GetClientName(client, player_name, sizeof(player_name));
	GetClientAuthString(client, authid, sizeof(authid));
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

stock CS_GetAdvLogString(client, String:LogString[], size)
{
	if (client == 0 || !IsClientInGame(client))
	{
		Format(LogString, size, "null");
		return -1;
	}
	
	new String:player_name[64];
	new userid;
	new String:authid[32];
	new Float:player_origin[3];
	new Float:eye_angles[3];
	
	GetClientName(client, player_name, sizeof(player_name));
	GetClientAuthString(client, authid, sizeof(authid));
	userid = GetClientUserId(client);
	
	GetClientAbsOrigin(client, player_origin);
	GetClientEyeAngles(client, eye_angles);

	EscapeString(player_name, sizeof(player_name));
	EscapeString(authid, sizeof(authid));
	Format(LogString, size, "{\"name\": \"%s\", \"userId\": %d, \"uniqueId\": \"%s\", \"team\": %d, \"origin\": [%.2f, %.2f, %.2f], \"velocity\": [%.2f, %.2f, %.2f], \"view\": [%.2f, %.2f, %.2f], \"health\": %d, \"armor\": %d, \"helmet\": %d}", player_name, userid, authid, GetClientTeam(client), player_origin[0], player_origin[1], player_origin[2] + GetEntPropFloat(client, Prop_Send, "m_vecViewOffset[2]"), GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]"), GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]"), GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]"), eye_angles[0], eye_angles[1], eye_angles[2], GetEntProp(client, Prop_Send, "m_iHealth"), GetEntProp(client, Prop_Send, "m_ArmorValue"), GetEntProp(client, Prop_Send, "m_bHasHelmet"));

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

stock IntToMoney(OldMoney, String:NewMoney[], size)
{
	new String:Temp[32];
	new String:OldMoneyStr[32];
	new tempChar;
	new RealLen = 0;

	IntToString(OldMoney, OldMoneyStr, sizeof(OldMoneyStr));

	for (new i = strlen(OldMoneyStr) - 1; i >= 0; i--)
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

stock GetOtherTeam(team)
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

stock CS_SwapTeams()
{
	for (new i = 1; i <= MaxClients; i++)
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

stock CS_GetPlayingCount()
{
	new count;
	for (new i = 1; i <= MaxClients; i++)
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

stock CS_StripButKnife(client, bool:equip=true)
{
	if (!IsClientInGame(client) || GetClientTeam(client) <= 1)
	{
		return false;
	}
	
	new item_index;
	for (new i = 0; i < 5; i++)
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

stock GetNumAlive(team)
{
	new count;
	for (new i = 1; i <= MaxClients; i++)
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

stock CS_EquipKnife(client)
{
	ClientCommand(client, "slot3");
}


/**
 *  removing filename invalid characters
 * 
 * @noreturn
 */

stock StripFilename(String:filename[], size)
{
	ReplaceString(filename, size, "\\", "");
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
}


/**
 *  converting a string to lowercase
 * 
 * @noreturn
 */

stock StringToLower(String:input[], size)
{
	for (new i = 0; i < size; i++)
	{
		input[i] = CharToLower(input[i]);
	}
}


/**
 *  hide setting an int cvar
 * 
 * @noreturn
 */
 
stock SetConVarIntHidden(Handle:cvar, const value)
{
	new String:cvar_name[64];
	new String:value_string[512];
	new flags = GetConVarFlags(cvar);
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
 
stock SetConVarStringHidden(Handle:cvar, String:value[])
{
	new String:cvar_name[64];
	new flags = GetConVarFlags(cvar);
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

stock EscapeString(String:value[], size)
{
	ReplaceString(value, size, "\\", "\\\\");
	ReplaceString(value, size, "\"", "\\\"");
	ReplaceString(value, size, "\b", "\\b");
	ReplaceString(value, size, "\t", "\\t");
	ReplaceString(value, size, "\n", "\\n");
	ReplaceString(value, size, "\f", "\\f");
	ReplaceString(value, size, "\r", "\\r");
}


/**
 * get the team name given by the game (e.g. TERRORIST and CT)
 *
 * @param  index			the team index
 * @param  String:team_name	the string buffer to place the name
 * @param  size				size of the buffer
 * @noreturn
 */

stock GetTeamName2(index, String:team_name[], size)
{
	if (StrEqual(g_team_name_cache[index], ""))
	{
		GetTeamName(index, team_name, size);
		strcopy(g_team_name_cache[index], size, team_name);
	}
	
	strcopy(team_name, size, g_team_name_cache[index]);
}

// Get player's Frags
public GetFrags(client)
{
	return GetClientFrags(client);
}

// Set player's Frags
public SetFrags(client, score)
{
	SetEntProp(client, Prop_Data, "m_iFrags", score);
}

// Set player's death count
public SetDeaths(client, deaths)
{
	SetEntProp(client, Prop_Data, "m_iDeaths", deaths);
}

// Get player's death count
public GetDeaths(client)
{
	return GetEntProp(client, Prop_Data, "m_iDeaths");
}

// Set player's cash if game is CSGO
public SetCash(client, cash)
{
	SetEntData(client, g_iAccount, cash, 4, true);
}

// Simply get player's CSGO cash
public GetCash(client)
{
	return GetEntData(client, g_iAccount);
}

// Set player's assist
public SetAssists(client, assists)
{
	CS_SetClientAssists(client, assists);
}

// Simply get player's CSGO assist
public GetAssists(client)
{
	return CS_GetClientAssists(client);
}

// Set player's real score
public SetRealScore(client, realscore)
{
	CS_SetClientContributionScore(client, realscore);
}

// Simply get player's CSGO real score
public GetRealScore(client)
{
	return CS_GetClientContributionScore(client);
}