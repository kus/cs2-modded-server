#if defined _stamm_levels_included
	#endinput
#endif
#define _stamm_levels_included




/**
 * Levels are configurated by the server admin.
 * Stamm supports up to 100 levels.
 *
 * Internally stamm uses level ids, if you have a name, you can get the id of a level by using STAMM_GetLevelNumber.
 *
 * Private levels are levels that can only achieved by special clients. 
 */





/**
 * Max. levels supported by Stamm
 */
#define STAMM_MAX_LEVELS 100




/**
 * Returns the name of a specific level id.
 *
 * @param level         Level id to get name for
 * @param name          String to save name in.
 * @param maxlength     Maxlength of string.
 *
 * @return              False on error, true on success.
 * @error               Level is invalid.
 */
native bool:STAMM_GetLevelName(level, String:name[], maxlength);


/**
 * Returns whether the level is a private level or not.
 *
 * @param level         Level id to check.
 *
 * @return              True=pivate, false=point based.
 * @error               Level is invalid.
 */
native bool:STAMM_IsLevelPrivate(level);


/**
 * Returns the level id of a specific level name.
 *
 * @param name          Name of the level.
 *
 * @return              0 = not found, x = level id.
 */
native STAMM_GetLevelNumber(const String:name[]);


/**
 * Returns how much points a player need for a specific Level.
 *
 * @param level         Level id to check.
 *
 * @return              How much points a client need, or -1 on error.
 * @error               Level is invalid.
 */
native STAMM_GetLevelPoints(level);


/**
 * Returns how much levels are configurated by the server admin.
 *
 * @return              How much levels are set.
 */
native STAMM_GetLevelCount();