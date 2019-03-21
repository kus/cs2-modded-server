#if defined _gungame_natives_included_
  #endinput
#endif
#define _gungame_natives_included_

/**
 * Forwards
 */

/**
 * Called when gungame is enabled
 *
 * @param Command       True if gungame was enabled by command.
 * @noreturn
 */
forward GG_OnStartup(bool:Command);

/**
 * Called when gungame is disabled.
 *
 * @param Command       True if gungame was disabled by command.
 * @noreturn
 */
forward GG_OnShutdown(bool:Command);

/**
 * Called when the player level changed.
 *
 * @param client        Player index.
 * @param level     Player current level (starting from 0). 
 * @param difference    The difference in the level change.
 * @param steal     true if it was a knife steal otherwise false
 * @param last      true if player reached last level.
 * @param knife     true if player reached knife level.
 * @return          Plugin_Handled; to stop the level change.
 */
forward Action:GG_OnClientLevelChange(client, level, difference, bool:steal, bool:last, bool:knife);

/**
 * Called when the player point per level changed.
 *
 * @param client        Player index.
 * @param point     Player current point per level.
 * @param difference    The difference in point change.
 * @return          Plugin_Handled; to stop the level change.
 */
forward Action:GG_OnClientPointChange(client, point, difference);

/**
 * Called when a client won the game.
 *
 * @param client        Player index.
 * @param Weapon        The player weapon they won with.
 * @param victim        Player index of victim (or 0 if there was no victim).
 * @noreturn
 */
forward GG_OnWinner(client, const String:Weapon[], victim);

/**
 * Called when a client triple leveled.
 *
 * @param client        Player index.
 * @noreturn
 */
forward GG_OnTripleLevel(client);

/**
 * Called when warmup has ended.
 *
 * @noreturn
 */
forward GG_OnWarmupEnd();

/**
 * Called when warmup has started.
 *
 * @noreturn
 */
forward GG_OnWarmupStart();

/**
 * Called when the leader change player.
 *
 * @param client        Player index.
 * @param level         The player current level (starting from 0).
 * @param totalLevels   Total number of levels (max level from config)
 * @noreturn
 */
forward GG_OnLeaderChange(client, level, totalLevels);

/**
 * Called when to start the map voting for next map
 *
 * @noparam
 * @noreturn
 */
forward GG_OnStartMapVote();

/**
 * Called when a player died.
 *
 * @param killer        Killer's index.
 * @param victim        Victim's index.
 * @param WeaponId      The weapon index the player was killed with.
 * @param TeamKilled    True if they were killed by a team mate.
 */
forward Action:GG_OnClientDeath(killer, victim, WeaponId, bool:TeamKilled);

/**
 * Called before winner sound starts to play.
 *
 * @param client    Winner's index.
 * @return          Plugin_Handled; to prevent winner sound to play.
 */
forward Action:GG_OnSoundWinner(client);

/**
 * Gives the client the average/minimum level of all players in the server.
 *
 * Handicap mode: 
 *    1 - Average level
 *    2 - Minimum level
 *
 * @param client        Player index.
 * @return              If level was set then return 1. 
 *                      0 - level was not changed.
 */
native GG_GiveHandicapLevel(client);

/**
 * Get the player current level.
 *
 * @param client        Player index
 * @return          The player current level (starting from 1).
 */
native GG_GetClientLevel(client);

/**
 * Retrieves the max level.
 *
 * @param return        The max level (starting from 1).
 */
native GG_GetMaxLevel();

/**
 * Add a level to the player current level.
 * This does not tell the client that they have leveled.
 *
 * @param client        Player index.
 * @return          The player current level.
 */
native GG_AddALevel(client);

/**
 * Remove a level from the player current level.
 *
 * This does not tell the client that they have lost a level.
 * This also obeys the max level per round.
 *
 * @param client        Player index.
 * @return          The player current level.
 */
native GG_RemoveALevel(client);

/**
 * Remove multi levels from the player current level.
 *
 * This does not tell the client that they have lost a level.
 * This also obeys the max level per round.
 *
 * @param client        Player index.
 * @param loose         Levels to loose.
 * @return          The player current level.
 */
native GG_RemoveLevelMulti(client, level);

/**
 * Add a point to the player point per level.
 *
 * This does not tell the client if they gain a point
 * nor does it tell the client that they leveled due to reaching the max point.
 *
 * @param client        Player index.
 * @return          The current player point per level or 0 if they leveled.
 */
native GG_AddAPoint(client);

/**
 * Removes a point to the player point per level.
 *
 * This does not tell the client if they lost a point
 * nor does it tell the client that they lost a level.
 *
 * @param client        Player index.
 * @return          The current player point per level or GG_GetClientMaxPointLevel() - 1 if they lost a level.
 */
native GG_RemoveAPoint(client);

/**
 * Retrieves the client current point per level.
 *
 * @param client        Player index.
 * @return          The current player point per level.
 */
native GG_GetClientPointLevel(client);

/**
 * Retrieves the client max point per level.
 *
 * @param client        Player index.
 * @return          The player max point per level.
 */
native GG_GetClientMaxPointLevel(client);

/**
 * Set the level weapon by weapon index.
 *
 * @param level     The weapon level (starting from 1)
 * @param weapon        The weapon index
 * @noreturn
 */
native GG_SetWeaponLevel(level, weapon);

/**
 * Set the level weapon by weapon name.
 *
 * @param level     The weapon level (starting from 1)
 * @param weapon        The weapon name
 */
native GG_SetWeaponLevelByName(level, const String:weapon[]);

/**
 * Set the maximum level the player can achieve to win the game.
 *
 * @param level     The level (starting from 1)
 * @noreturn
 * @error               If level is greater than the define maximum.
 *
 */
native GG_SetMaxLevel(level);

/**
 * Retrieves the weapon index from weapon name.
 *
 * @param weapon        The short weapon name. ie awp, glock.
 * @return          0 if weapon is not found or the weapon index.
 */
native GG_GetWeaponIndex(const String:weapon[]);

/**
 * Get weapon name from level.
 *
 * @param level         The current level (starting from 1).
 * @param weapon        The weapon name to get.
 * @param maxlength     Max length of weapon String.
 * @noreturn
 */
native GG_GetLevelWeaponName(level, String:weapon[], maxlength);

/**
 * Retrieves if warmup is in progress.
 *
 * @noparam
 * @return          Return true if warmup is in progress otherwise false.
 */
native bool:GG_IsWarmupInProgress();

/**
 * Return weapon id for knife weapon.
 *
 * @noparam
 * @return          Return weapon id for knife weapon.
 */
native GG_GetWeaponIdKnife();

/**
 * Return true if weapon is knife.
 *
 * @param weaponId  The weapon id to ckeck.
 * @return          Return weapon id for knife weapon.
 */
native bool:GG_IsWeaponKnife(weaponId);

/**
 * Return weapon id for hegrenade weapon.
 *
 * @noparam
 * @return          Return weapon id for hegrenade weapon.
 */
native GG_GetWeaponIdHegrenade();

/* Do not edit the code below. */
public SharedPlugin:__pl_gungame =
{
    name = "gungame",
    file = "gungame.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};
