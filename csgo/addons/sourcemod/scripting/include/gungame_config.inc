#if defined _gungame_cfg_natives_included_
  #endinput
#endif
#define _gungame_cfg_natives_included_

/**
 * Called news section of the config reader changes
 *
 * @param NewSection        The news section of the config file.
 * @noreturn
 */
forward GG_ConfigNewSection(const String:name[]);

/**
 * Called when the leader change player.
 *
 * @param Key           Key of cvar (Think of a better description)
 * @param Value     Value of setting
 * @noreturn
 */
forward GG_ConfigKeyValue(const String:key[], const String:value[]);

/**
 * Called when a file is fully parsed.
 *
 * @noparam
 * @noreturn
 */
forward GG_ConfigParseEnd();

/**
 * Called when all the config file are fully parsed.
 *
 * @noparam
 * @noreturn
 */
forward GG_ConfigEnd();

/**
 * Get cfg dir name;
 *
 * @param dirName        Dir name.
 * @param dirNameSize    Dir name string size.
 * @return          void.
 */
native GG_ConfigGetDir(String:dirName[], dirNameSize);

/* Do not edit the code below. */
public SharedPlugin:__pl_gungame_cfg =
{
    name = "gungame_cfg",
    file = "gungame_config.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};
