#if defined _get5_included_
#endinput
#endif
#define _get5_included_

enum Get5State {
  Get5State_None,                          // no setup has taken place
  Get5State_PreVeto,                       // warmup, waiting for the veto
  Get5State_Veto,                          // warmup, doing the veto
  Get5State_Warmup,                        // setup done, waiting for players to ready up
  Get5State_KnifeRound,                    // in the knife round
  Get5State_WaitingForKnifeRoundDecision,  // waiting for a .stay/.swap command after the knife
  Get5State_GoingLive,                     // in the lo3 process
  Get5State_Live,                          // the match is live
  Get5State_PostGame,                      // postgame screen + waiting for GOTV to finish broadcast
};

#define MATCHTEAM_COUNT 4

enum MatchTeam {
  MatchTeam_Team1,
  MatchTeam_Team2,
  MatchTeam_TeamSpec,
  MatchTeam_TeamNone,
  MatchTeam_Count,
};

enum MatchSideType {
  MatchSideType_Standard,     // Team that doesn't pick map gets side choice, leftovers go to knife
                              // rounds
  MatchSideType_AlwaysKnife,  // All maps use a knife round to pick sides
  MatchSideType_NeverKnife,   // Team 1 always starts CT
};

enum SideChoice {
  SideChoice_Team1CT,     // Team 1 will start on CT
  SideChoice_Team1T,      // Team 2 will start on T
  SideChoice_KnifeRound,  // There will be a knife round to choose sides
};

// Called each get5-event with JSON formatted event text.
forward void Get5_OnEvent(const char[] eventJson);

// Called when a series is first setup.
// Note: do not rely on the state of any cvars at this point.
forward void Get5_OnSeriesInit();

// Called each time in a match when a map is going live.
// The mapNumber parameter starts at 0.
forward void Get5_OnGoingLive(int mapNumber);

// Called whenever the gamestate phase is changed.
forward void Get5_OnGameStateChanged(Get5State oldState, Get5State newState);

// Called when the stats for the last round have been updated.
forward void Get5_OnRoundStatsUpdated();

// Called at the end of a map in a series.
forward void Get5_OnMapResult(const char[] map, MatchTeam mapWinner, int team1Score, int team2Score,
                              int mapNumber);

// Called at the end of a full match.
// Note: both Get5_OnMapResult and Get5_OnSeriesResult are called on the last map of a series.
forward void Get5_OnSeriesResult(MatchTeam seriesWinner, int team1MapScore, int team2MapScore);

forward void Get5_OnPreLoadMatchConfig(const char[] filePath);

// Called when a match config fails to load.
forward void Get5_OnLoadMatchConfigFailed(const char[] reason);

// Called when a team vetoes a map.
forward void Get5_OnMapVetoed(MatchTeam team, const char[] map);

// Called when a team selects a map.
// The team parameter will be MatchTeam_TeamNone if the map was selected as the last remaining map
// and not by one of the teams specifically.
forward void Get5_OnMapPicked(MatchTeam team, const char[] map);

// Called when a team selects a side.
forward void Get5_OnSidePicked(MatchTeam team, const char[] map, int side);

// Called when a demo finishes recording.
forward void Get5_OnDemoFinished(const char[] filename);

// Called when a match backup is restored.
forward void Get5_OnBackupRestore();

// Returns the current pug gamestate.
native Get5State Get5_GetGameState();

// Prints a plugin-formatted message to a client.
native void Get5_Message(int client, const char[] format, any:...);

// Prints a plugin-formatted message to a team.
native void Get5_MessageToTeam(MatchTeam team, const char[] format, any:...);

// Prints a plugin-formatted message to all clients.
native void Get5_MessageToAll(const char[] format, any:...);

// Loads a match config (keyvalues or JSON) from a local file.
// Returns true if the config was successfully loaded.
native bool Get5_LoadMatchConfig(const char[] filename);

// Loads a match config by downloading a remote config via a HTTP GET request.
// Request parameters should be left out of the url and put into the optional ArrayLists parameters.
native bool Get5_LoadMatchConfigFromURL(const char[] url, ArrayList paramNames = null,
                                        ArrayList paramValues = null);

// Adds a player to a match team. You can optionally force set a player name here as well.
// Returns if they were successfully added.
native bool Get5_AddPlayerToTeam(const char[] steamId, MatchTeam team,
                                 const char[] playerName = "");

// Force sets a steam64 to map to a specified playername
native bool Get5_SetPlayerName(const char[] steamId, const char[] playerName);

// Removes a player from all match teams.
// Returns if they were successfully removed (false if not round).
native bool Get5_RemovePlayerFromTeam(const char[] steamId);

// Returns the current match team a auth is mapped to.
native MatchTeam Get5_GetPlayerTeam(const char[] steamId);

// Translates a CS team (CS_TEAM_T, etc.) to a Match team.
native MatchTeam Get5_CSTeamToMatchTeam(int csTeam);

// Translate da MatchTeam to a CS team.
native int Get5_MatchTeamToCSTeam(MatchTeam team);

// Gets the scores for a match team.
native void Get5_GetTeamScores(MatchTeam team, int& seriesScore, int& currentMapScore);

// Gets the current matchid.
native void Get5_GetMatchID(char[] id, int length);

// Sets the current matchid.
native void Get5_SetMatchID(const char[] id);

// Returns the server ID as defined by get5_server_id.
native int Get5_GetServerID();

// Adds a cvar to be set when going live. If the cvar is already in the cvars for the match, the new
// value will replace the old value if the override parameter is true.
// Note: this should only be used when a match config loaded.
native void Get5_AddLiveCvar(const char[] name, const char[] value, bool override = true);

// Copies the current series stats into the passed KeyValues structure.
// Below are the keys used for stats in the kv copied.
// The caller is responsible for creating and deleting a KeyValues
// object if using this method.
native bool Get5_GetMatchStats(KeyValues kv);

// Increases an (integer-typed) player statistic in the plugin's stats keyvalue structure.
native int Get5_IncreasePlayerStat(int client, const char[] statName, int amount = 1);

// Series stats (root section)
#define STAT_SERIESWINNER "winner"
#define STAT_SERIESTYPE "series_type"
#define STAT_SERIES_TEAM1NAME "team1_name"
#define STAT_SERIES_TEAM2NAME "team2_name"
#define STAT_SERIES_FORFEIT "forfeit"

// Map stats (under "map0", "map1", etc.)
#define STAT_MAPNAME "mapname"
#define STAT_MAPWINNER "winner"
#define STAT_DEMOFILENAME "demo_filename"

// Team stats (under map section, then "team1" or "team2")
#define STAT_TEAMSCORE "score"

// Player stats (under map section, then team section, then player's steam64)
#define STAT_NAME "name"
#define STAT_KILLS "kills"
#define STAT_DEATHS "deaths"
#define STAT_ASSISTS "assists"
#define STAT_FLASHBANG_ASSISTS "flashbang_assists"
#define STAT_TEAMKILLS "teamkills"
#define STAT_SUICIDES "suicides"
#define STAT_DAMAGE "damage"
#define STAT_HEADSHOT_KILLS "headshot_kills"
#define STAT_ROUNDSPLAYED "roundsplayed"
#define STAT_BOMBDEFUSES "bomb_defuses"
#define STAT_BOMBPLANTS "bomb_plants"
#define STAT_1K "1kill_rounds"
#define STAT_2K "2kill_rounds"
#define STAT_3K "3kill_rounds"
#define STAT_4K "4kill_rounds"
#define STAT_5K "5kill_rounds"
#define STAT_V1 "v1"
#define STAT_V2 "v2"
#define STAT_V3 "v3"
#define STAT_V4 "v4"
#define STAT_V5 "v5"
#define STAT_FIRSTKILL_T "firstkill_t"
#define STAT_FIRSTKILL_CT "firstkill_ct"
#define STAT_FIRSTDEATH_T "firstdeath_t"
#define STAT_FIRSTDEATH_CT "firstdeath_ct"
#define STAT_TRADEKILL "tradekill"
#define STAT_KAST "kast"
#define STAT_CONTRIBUTION_SCORE "contribution_score"
#define STAT_MVP "mvp"

public SharedPlugin __pl_get5 = {
    name = "get5",
    file = "get5.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_get5_SetNTVOptional() {
  MarkNativeAsOptional("Get5_GetGameState");
  MarkNativeAsOptional("Get5_Message");
  MarkNativeAsOptional("Get5_MessageToTeam");
  MarkNativeAsOptional("Get5_MessageToAll");
  MarkNativeAsOptional("Get5_LoadMatchConfig");
  MarkNativeAsOptional("Get5_LoadMatchConfigFromURL");
  MarkNativeAsOptional("Get5_AddPlayerToTeam");
  MarkNativeAsOptional("Get5_SetPlayerName");
  MarkNativeAsOptional("Get5_RemovePlayerFromTeam");
  MarkNativeAsOptional("Get5_GetPlayerTeam");
  MarkNativeAsOptional("Get5_CSTeamToMatchTeam");
  MarkNativeAsOptional("Get5_MatchTeamToCSTeam");
  MarkNativeAsOptional("Get5_GetTeamScores");
  MarkNativeAsOptional("Get5_GetMatchID");
  MarkNativeAsOptional("Get5_SetMatchID");
  MarkNativeAsOptional("Get5_GetServerID");
  MarkNativeAsOptional("Get5_AddLiveCvar");
  MarkNativeAsOptional("Get5_IncreasePlayerStat");
  MarkNativeAsOptional("Get5_GetMatchStats");
}
#endif