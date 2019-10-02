#if defined _smlib_teams_included
	#endinput
#endif
#define _smlib_teams_included

#include <sourcemod>
#include <smlib/clients>
#include <smlib/entities>

#define MAX_TEAMS				32	// Max number of teams in a game
#define MAX_TEAM_NAME_LENGTH	32	// Max length of a team's name

// Team Defines
#define	TEAM_INVALID	-1
#define TEAM_UNASSIGNED	0
#define TEAM_SPECTATOR	1
#define TEAM_ONE		2
#define TEAM_TWO		3
#define TEAM_THREE		4
#define TEAM_FOUR		5

/*
 * If one team is empty its assumed single team mode is enabled and the game won't start.
 *
 * @noparam
 * @return			True if one team is empty, false otherwise.			
 */
stock bool:Team_HaveAllPlayers(bool:countFakeClients=true) {

	new teamCount = GetTeamCount();
	for (new i=2; i < teamCount; i++) {
		
		if (Team_GetClientCount(i, ((countFakeClients) ? CLIENTFILTER_ALL : CLIENTFILTER_NOBOTS)) == 0) {
			return false;
		}
	}
	
	return true;
}

/*
 * Returns the client count of the players in a team.
 *
 * @param team					Team Index.
 * @param flags					Client Filter Flags (Use the CLIENTFILTER_ constants).
 * @return						Client count in the server.
 */
stock Team_GetClientCount(team, flags=0)
{
	flags |= CLIENTFILTER_INGAME;

	new numClients = 0;
	for (new client=1; client <= MaxClients; client++) {

		if (!Client_MatchesFilter(client, flags)) {
			continue;
		}

		if (GetClientTeam(client) == team) {
			numClients++;
		}
	}

	return numClients;
}

/*
 * Returns the client counts of the first two teams (eg.: Terrorists - Counter).
 * Use this function for optimization if you have to get the counts of both teams,
 * otherwise use Team_GetClientCount().
 *
 * @param team1					Pass an integer variable by reference
 * @param team2					Pass an integer variable by reference
 * @param flags					Client Filter Flags (Use the CLIENTFILTER_ constants).
 * @noreturn
 */
stock Team_GetClientCounts(&team1=0, &team2=0, flags=0)
{
	flags |= CLIENTFILTER_INGAME;

	for (new client=1; client <= MaxClients; client++) {

		if (!Client_MatchesFilter(client, flags)) {
			continue;
		}

		if (GetClientTeam(client) == TEAM_ONE) {
			team1++;
		}
		else if (GetClientTeam(client) == TEAM_TWO) {
			team2++;
		}
	}
}

/*
 * Gets the name of a team.
 * Don't call this before OnMapStart()
 *
 * @param index			Team Index.
 * @param str			String buffer
 * @param size			String Buffer Size
 * @return				True on success, false otherwise
 */
stock bool:Team_GetName(index, String:str[], size)
{
	new edict = Team_GetEdict(index);
	
	if (edict == -1) {
		str[0] = '\0';
		return false;
	}

	GetEntPropString(edict, Prop_Send, "m_szTeamname", str, size);
	
	return true;
}

/*
 * Changes a team's name.
 * Use this carefully !
 * Only set the teamname OnMapStart() or OnEntityCreated()
 * when no players are ingame, otherwise it can crash the server.
 *
 * @param index			Team Index.
 * @param name			New Name String
 * @return				True on success, false otherwise
 */
stock bool:Team_SetName(index, const String:name[])
{
	new edict = Team_GetEdict(index);
	
	if (edict == -1) {
		return false;
	}

	SetEntPropString(edict, Prop_Send, "m_szTeamname", name);
	ChangeEdictState(edict, GetEntSendPropOffs(edict, "m_szTeamname", true));
	
	return true;
}

/*
 * Changes a team's score.
 * Don't use this before OnMapStart().
 *
 * @param index			Team Index.
 * @return				Team Score or -1 if the team is not valid.
 */
stock Team_GetScore(index)
{
	new edict = Team_GetEdict(index);
	
	if (edict == -1) {
		return -1;
	}

	return GetEntProp(edict, Prop_Send, "m_iScore");
}

/*
 * Changes a team's score.
 * Don't use this before OnMapStart().
 *
 * @param index			Team Index.
 * @param score			Score value.
 * @return				True on success, false otherwise
 */
stock bool:Team_SetScore(index, score)
{
	new edict = Team_GetEdict(index);
	
	if (edict == -1) {
		return false;
	}

	SetEntProp(edict, Prop_Send, "m_iScore", score);
	
	ChangeEdictState(edict, GetEntSendPropOffs(edict, "m_iScore", true));
	
	return true;
}

/*
 * Gets a team's edict (*team_manager) Team Index.
 * Don't call this before OnMapStart()
 *
 * @param edict			Edict
 * @return				Team Index
 */
stock Team_EdictGetNum(edict)
{
	return GetEntProp(edict, Prop_Send, "m_iTeamNum");
}

/*
 * Check's whether the index is a valid team index or not.
 * Don't call this before OnMapStart()
 *
 * @param index			Index.
 * @return				True if the Index is a valid team, false otherwise.
 */
stock bool:Team_IsValid(index)
{
	return (Team_GetEdict(index) != -1);
}

/*
 * Gets a team's edict (team_manager) Team Index.
 * Don't call this before OnMapStart()
 *
 * @param index			Edict
 * @return				Team Index
 */
stock Team_EdictIsValid(edict)
{
	return GetEntProp(edict, Prop_Send, "m_iTeamNum");
}

/*
 * Gets a team's edict (team_manager).
 * This function caches found team edicts.
 * Don't call this before OnMapStart()
 *
 * @param index			Team Index.
 * @return				Team edict or -1 if not found
 */
stock Team_GetEdict(index)
{
	static teams[MAX_TEAMS] = { INVALID_ENT_REFERENCE, ... };

	if (index < 0 || index > MAX_TEAMS) {
		return -1;
	}

	new edict = teams[index];
	if (Entity_IsValid(edict)) {
		return edict;
	}

	new bool:foundTeamManager = false;

	new maxEntities = GetMaxEntities();
	for (new entity=MaxClients+1; entity < maxEntities; entity++) {

		if (!IsValidEntity(entity)) {
			continue;
		}

		if (Entity_ClassNameMatches(entity, "team_manager", true)) {
			foundTeamManager = true;
		}
		// Do not continue when no team managers are found anymore (for optimization)
		else if (foundTeamManager) {
			return -1;
		}
		else {
			continue;
		}

		new num = Team_EdictGetNum(entity);

		if (num >= 0 && num <= MAX_TEAMS) {
			teams[num] = EntIndexToEntRef(entity);
		}

		if (num == index) {
			return entity;
		}
	}

	return -1;
}

/*
 * Trys to find a client in the specified team.
 * This function is NOT random, it returns the first
 * or the cached player (Use Client_GetRandom() instead).
 *
 * @param index			Team Index.
 * @return				Client Index or -1 if no client was found in the specified team.
 */
stock Team_GetAnyClient(index)
{
	static client_cache[MAX_TEAMS] = -1;
	new client;

	if (index > 0) {
		client = client_cache[index];

		if (client > 0 && client <= MaxClients) {
			
			if (IsClientInGame(client) && GetClientTeam(client) == index) {
				return client;
			}
		}
		else {
			client = -1;
		}
	}

	for (client=1; client <= MaxClients; client++) {
		
		if (!IsClientInGame(client)) {
			continue;
		}
		
		if (GetClientTeam(client) != index) {
			continue;
		}

		client_cache[index] = client;

		return client;
	}
	
	return -1;
}
