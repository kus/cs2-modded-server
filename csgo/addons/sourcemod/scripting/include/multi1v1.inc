
#if defined _multi1v1_included
#endinput
#endif
#define _multi1v1_included

#define WEAPON_NAME_LENGTH 32
#define MAX_ROUND_TYPES 32

/**
 * Called right before the plugin puts players into the ranking queue.
 * This is the best place to put players into the front of the queue.
 *
 * @param rankingQueue empty adt array to be used for arena placement
 * @noreturn
 */
forward void Multi1v1_OnPreArenaRankingsSet(ArrayList rankingQueue);

/**
 * Called after the plugin is done putting players into the ranking queue.
 *
 * @param rankingQueue adt array of the players in order of their arena placement
 * @noreturn
 */
forward void Multi1v1_OnPostArenaRankingsSet(ArrayList rankingQueue);

/**
 * Called when all players have been placed into their arena.
 * GetArenaNumber is now valid to call for clients.
 *
 * @noreturn
 */
forward void Multi1v1_OnArenasReady();

/**
 * Called after a player's spawn setup (e.g. giving weapons) is processed.
 *
 * @param client Player's index.
 * @noreturn
 */
forward void Multi1v1_AfterPlayerSpawn(int client);

/**
 * Called after core player setup functions (teleporting, printing their opponent to chat, giving
 * weapons)
 * are completed.
 *
 * @param client Player's index.
 * @noreturn
 */
forward void Multi1v1_AfterPlayerSetup(int client);

/**
 * Called when an arena finishes it's fighting.
 *
 * @param winner Winner's client index.
 * @param loser Loser's client index.
 * @param forceLoss Whether it was a "force loss" for both payers (e.g. time ran out)
 * @noreturn
 */
forward void Multi1v1_OnRoundWon(int winner, int loser, bool forceLoss);

/**
 * Called when a client's stats have been fetched successfully.
 *
 * @param client Player's index.
 * @noreturn
 */
forward void Multi1v1_OnStatsCached(int client);

/**
 * Called after the menu is built, but before it's displayed to the client
 * Note that the info strings used by the weapons menu are
 * "rifle", "pistol", "pref", and "allowx" (where x is an integer),
 * so you should avoid adding these into the menu.
 *
 * @param client Player's index.
 * @param menu Menu being displayed to the client.
 * @noreturn
 */
forward void Multi1v1_OnGunsMenuCreated(int client, Menu menu);

/**
 * Called directly by the guns menu callback.
 * @noreturn
 */
forward void Multi1v1_GunsMenuCallback(Menu menu, MenuAction action, int param1, int param2);

/**
 * Called each map start after the standard round types have been added.
 * You should use this to add round types via Multi1v1_AddRoundType.
 *
 * @noreturn
 */
forward void Multi1v1_OnRoundTypesAdded();

/**
 * Called after a round type for an arena has been decided.
 *
 * @param arena The arena number.
 * @param player1 Player 1's index.
 * @param player2 Player 2's index.
 * @param roundtype Round type index
 * @noreturn
 */
forward void Multi1v1_OnRoundTypeDecided(int arena, int player1, int player2, int& roundType);

/**
 * Called each map start after spawns have been read from the map and
 * partitioned into arenas.
 * @param cOrigins Counter-Terrorist spawn points
 * @param ctOrigins Counter-Terrorist spawn angles
 * @param tOrigins Terrorist spawn points
 * @param tOrigins Terrorist spawn angles
 *
 * @note Each of the ArrayList parameters is an ArrayList of ArrayLists of 3-vectors, where each
 * internal
 *       list is representing the spawns for an arena. To put it another way,
 *       they have type ArrayList<ArrayList<float[3]>>
 *
 * @noreturn
*/
forward void Multi1v1_OnSpawnsFound(ArrayList ctOrigins, ArrayList ctAngles, ArrayList tOrigins,
                                    ArrayList tAngles);

forward void Multi1v1_OnSpawnSet(int client, int arena, bool onCT, int spawnIndex);

/**
 * Returns if a player is actively in an arena.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native bool Multi1v1_IsInArena(int client);

/**
 * Prints a plugin-formatted message to a client.
 *
 * @param client Player's index.
 * @param format Format string
 * @error Client not connected.
 */
native void Multi1v1_Message(int client, const char[] format, any...);

/**
 * Prints a plugin-formatted message to all clients.
 *
 * @param format Format string
 */
native void Multi1v1_MessageToAll(const char[] format, any...);

/**
 * Returns the maximum number of arenas the map allows.
 */
native int Multi1v1_GetMaximumArenas();

/**
 * Returns the active number of arenas.
 */
native int Multi1v1_GetNumActiveArenas();

/**
 * Returns if a player is inside the waiting queue.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native bool Multi1v1_IsInWaitingQueue(int client);

/**
 * Returns if a client has a rating stored.
 * This should be checked before trying to fetch
 * statistics results for a client.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native bool Multi1v1_HasStats(int client);

/**
 * Sets a client rating.
 *
 * @param client Player's index.
 * @param rating The new rating.
 * @error Client not connected.
 * @noreturn
 */
native void Multi1v1_SetRating(int client, float rating);

/**
 * Returns a client rating.
 *
 * @param client Player's index.
 * @param roundType The roundtype rating to get, or -1
 *                  for the overall rating.
 * @error Client not connected.
 */
native float Multi1v1_GetRating(int client, int roundType = -1);

/**
 * Returns a client rating.
 *
 * @param client Player's index.
 * @param roundType The roundtype rating to get, or -1
 *                  for the overall rating.
 * @error Client not connected.
 */
native int Multi1v1_GetRoundsPlayed(int client);

/**
 * Returns the number of wins a client has.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native int Multi1v1_GetWins(int client);

/**
 * Returns the number of losses a client has.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native int Multi1v1_GetLosses(int client);

/**
 * Returns the arena number a client is in.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native int Multi1v1_GetArenaNumber(int client);

/**
 * Returns the 1st player in an arena.
 *
 * @param arena Arena number.
 * @error Invalid arena number.
 */
native int Multi1v1_GetArenaPlayer1(int arena);

/**
 * Returns the 2nd player in an arena.
 *
 * @param arena Arena number.
 * @error Invalid arena number.
 */
native int Multi1v1_GetArenaPlayer2(int arena);

/**
 * Returns the number of rounds a client has spent at arena 1.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native int Multi1v1_GetRoundsAtArena1(int client);

/**
 * Returns the clients current opponent, or -1 if they have none.
 *
 * @param client Player's index.
 * @error Client not connected.
 */
native int Multi1v1_GetOpponent(int client);

/**
 * Returns if the database is connected and valid.
 */
native bool Multi1v1_HasDatabase();

/**
 * Returns a clone of the database handle.
 * You should check Multi1v1_HasDatabase before calling this.
 */
native Handle Multi1v1_GetDatabase();

/**
 * Gives a player his weapons according to a round type by calling the
 * round type handler.
 *
 * @param client Player's index.
 * @param roundType Roundtype index.
 * @error Client not connected or invalid round type.
 */
native void Multi1v1_GivePlayerArenaWeapons(int client, int roundType);

// These are helpers you can use to supress normal plugin behavior.
// You can block rating changes and the chat messages about
// 'you are in arena %d facing off against %N' using these.
native void Multi1v1_BlockRatingChanges(int client);
native void Multi1v1_UnblockRatingChanges(int client);
native void Multi1v1_BlockChatMessages(int client);
native void Multi1v1_UnblockChatMessages(int client);
native void Multi1v1_BlockMVPStars(int client);
native void Multi1v1_UnblockMVPStars(int client);
native void Multi1v1_BlockArenaDones(int arena);
native void Multi1v1_UnblockArenaDones(int arena);

/**
 * Sets an offset value for arena numbering when giving
 * players "Arena %d" team tags.
 *
 * @param value The new arena offset value.
 * @noreturn
 */
native void Multi1v1_SetArenaOffsetValue(int value);

/**
 * Returns the rating delta from a winner/loser matchup.
 * This number will always be positive.
 *
 * @param winner_rating Rating of the winner.
 * @param loser_rating Rating of the loser.
 * @param K K factor.
 */
native float Multi1v1_ELORatingDelta(float winner_rating, float loser_rating, float K);

/**
 * Returns the number of spawns (per team) in an arena.
 * If one team has less spawns than the other team,
 * the smaller of the two will be returned.
 *
 * @param arena Arena number.
 * @error Invalid arena number.
 */
native int Multi1v1_GetNumSpawnsInArena(int arena);

/**
 * Gets a spawn point/angle pair from an arena for a given team.
 *
 * @param arena Arena number.
 * @param team Team (CS_TEAM_CT or CS_TEAM_T).
 * @param origin Array to fill the spawn point into.
 * @param angle Array to fill the spawn angles into.
 * @error Invalid arena number or team.
 */
native int Multi1v1_GetArenaSpawn(int arena, int team, float origin[3], float angle[3]);

/**
 * Finds the arena number of a position. This may be inaccurate if the
 * given position isn't actually inside any arena as it uses the spawns
 * to determine the closest arena.
 * Note: arena numbers are ordered between [1, Multi1v1_GetMaximumArenas()]
 *
 * @param origin Position vector.
 */
native int Multi1v1_FindArenaNumber(const float origin[3]);

/**
 * Gets the rifle the client has selected in the weapons menu.
 *
 * @param client Client index.
 * @param buffer Buffer to fill the result into.
 * @error Client not connected.
 */
native void Multi1v1_GetRifleChoice(int client, char buffer[WEAPON_NAME_LENGTH]);

/**
 * Gets the pistol the client has selected in the weapons menu.
 *
 * @param client Client index.
 * @param buffer Buffer to fill the result into.
 * @error Client not connected.
 */
native void Multi1v1_GetPistolChoice(int client, char buffer[WEAPON_NAME_LENGTH]);

typedef RoundTypeWeaponHandler = function void(int client);
typedef RoundTypeMenuHandler = function void(int client);

/**
 * Registers a new round type within the plugin.
 * NOTE: this should only be called within the Multi1v1_OnRoundTypesAdded forward.
 *
 * @param displayName The name to be shown to clients on the weapons menu
 * @param internalName The unique name used for internal mechanisms (e.g. cookies)
 * @param weaponsHandler The function called on each client when that round type is chosen
 * @param menuHandler The function called for a client when they "allowed" the round type in the
 * menu
 * @param optional Whether the round type is optional or not (i.e. if they get to chose to disallow
 * it)
 * @param ranked Whether those rounds count toward player ratings
 * @param ratingFieldName Name of the field for round-type specific rating updates
 *                        leave as the empty string for no round-type specific rating
 * @param enabled Whether the round type should be considered enabled or not.
 * @error If the number of round types registered exceeds the max allowed round types.
 * @return the unique int identifier for the round type (an index into an internal array)
 */
native int Multi1v1_AddRoundType(const char[] displayName, const char[] internalName,
                                 RoundTypeWeaponHandler weaponsHandler, bool optional = true,
                                 bool ranked = false, const char[] ratingFieldName = "",
                                 bool enabled = true);

/**
 * Clears all registered round types.
 *
 * @noreturn
 */
native void Multi1v1_ClearRoundTypes();

/**
 * Adds the stock, standard round types.
 *
 * @noreturn
 */
native void Multi1v1_AddStandardRounds();

/**
 * Returns the unique identifier (the index) of a round type given its internal name.
 */
native int Multi1v1_GetRoundTypeIndex(const char[] internalName);

// Helper null callback for round types that don't need to give players weapons on spawn.
public void Multi1v1_NullWeaponHandler(int client) {}

native bool Multi1v1_IsRoundTypeEnabled(int roundType);
native void Multi1v1_EnableRoundType(int roundType);
native void Multi1v1_DisableRoundType(int roundType);
native void Multi1v1_GetRoundTypeDisplayName(int roundType, char[] buffer, int bufferLength);

/**
 * Returns the current round type in an arena.
 *
 * @error Invalid arena number.
 */
native int Multi1v1_GetCurrentRoundType(int arena);

/**
 * Returns the number of active round types.
 */
native int Multi1v1_GetNumRoundTypes();

/**
 * Returns if a player allows a given round type.
 *
 * @error Client not connected.
 */
native bool Multi1v1_PlayerAllowsRoundType(int client, int roundType);

/**
 * Returns the round type a player marked as his preference.
 * A return of -1 indicates no preference.
 *
 * @error Client not connected.
 */
native int Multi1v1_PlayerPreference(int client);

/**
 * Returns if a player is currently hiding stats from being displayed.
 *
 * @error Client not connected.
 */
native bool Multi1v1_IsHidingStats(int client);

/**
 * Gives a player the guns menu.
 */
native void Multi1v1_GiveWeaponsMenu(int client, int pos = 0);

/**
 * Gives a player a knife.
 */
native void Multi1v1_GivePlayerKnife(int cilent);

public SharedPlugin __pl_multi1v1 = {
    name = "multi1v1", file = "multi1v1.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_multi1v1_SetNTVOptional() {
  MarkNativeAsOptional("Multi1v1_IsInArena");
  MarkNativeAsOptional("Multi1v1_GetMaximumArenas");
  MarkNativeAsOptional("Multi1v1_GetNumActiveArenas");
  MarkNativeAsOptional("Multi1v1_IsInWaitingQueue");
  MarkNativeAsOptional("Multi1v1_HasStats");
  MarkNativeAsOptional("Multi1v1_GetRating");
  MarkNativeAsOptional("Multi1v1_GetArenaNumber");
  MarkNativeAsOptional("Multi1v1_GetArenaPlayer1");
  MarkNativeAsOptional("Multi1v1_GetArenaPlayer2");
  MarkNativeAsOptional("Multi1v1_GetRoundsAtArena1");
  MarkNativeAsOptional("Multi1v1_GetOpponent");
  MarkNativeAsOptional("Multi1v1_GetRoundsPlayed");
  MarkNativeAsOptional("Multi1v1_GetWins");
  MarkNativeAsOptional("Multi1v1_GetLosses");
  MarkNativeAsOptional("Multi1v1_HasDatabase");
  MarkNativeAsOptional("Multi1v1_GivePlayerArenaWeapons");
  MarkNativeAsOptional("Multi1v1_Message");
  MarkNativeAsOptional("Multi1v1_MessageToAll");
  MarkNativeAsOptional("Multi1v1_BlockRatingChanges");
  MarkNativeAsOptional("Multi1v1_UnblockRatingChanges");
  MarkNativeAsOptional("Multi1v1_BlockChatMessages");
  MarkNativeAsOptional("Multi1v1_UnblockChatMessages");
  MarkNativeAsOptional("Multi1v1_BlockMVPStars");
  MarkNativeAsOptional("Multi1v1_UnblockMVPStars");
  MarkNativeAsOptional("Multi1v1_BlockArenaDones");
  MarkNativeAsOptional("Multi1v1_UnblockArenaDones");
  MarkNativeAsOptional("Multi1v1_SetArenaOffsetValue");
  MarkNativeAsOptional("Multi1v1_ELORatingDelta");
  MarkNativeAsOptional("Multi1v1_GetNumSpawnsInArena");
  MarkNativeAsOptional("Multi1v1_GetArenaSpawn");
  MarkNativeAsOptional("Multi1v1_FindArenaNumber");
  MarkNativeAsOptional("Multi1v1_GetRifleChoice");
  MarkNativeAsOptional("Multi1v1_GetPistolChoice");
  MarkNativeAsOptional("Multi1v1_AddRoundType");
  MarkNativeAsOptional("Multi1v1_ClearRoundTypes");
  MarkNativeAsOptional("Multi1v1_GetRoundTypeIndex");
  MarkNativeAsOptional("Multi1v1_AddStandardRounds");
  MarkNativeAsOptional("Multi1v1_GetCurrentRoundType");
  MarkNativeAsOptional("Multi1v1_GetNumRoundTypes");
  MarkNativeAsOptional("Multi1v1_PlayerAllowsRoundType");
  MarkNativeAsOptional("Multi1v1_PlayerPreference");
  MarkNativeAsOptional("Multi1v1_IsHidingStats");
  MarkNativeAsOptional("Multi1v1_IsRoundTypeEnabled");
  MarkNativeAsOptional("Multi1v1_EnableRoundType");
  MarkNativeAsOptional("Multi1v1_DisableRoundType");
  MarkNativeAsOptional("Multi1v1_GiveWeaponsMenu");
  MarkNativeAsOptional("Multi1v1_GetRoundTypeDisplayName");
  MarkNativeAsOptional("Multi1v1_GivePlayerKnife");
}
#endif
