#if defined _stamm_core_included
	#endinput
#endif
#define _stamm_core_included





/**
 * A list of possible games stamm can running on.
 */
enum StammGame
{
	GameOTHER = 0,
	GameCSS,
	GameCSGO,
	GameTF2,
	GameDOD
};


/**
 * A list with possible types, how a player can get stamm points.
 */
enum StammType
{
	KILLS = 1,
	ROUNDS,
	TIME,
	KILLS_ROUNDS,
	KILLS_TIME,
	ROUNDS_TIME,
	KILLS_ROUNDS_TIME
};






/**
 * Executes when Stamm is fully loaded.
 * Here you can be sure to access all Stamm stuff successfully.
 */
forward STAMM_OnReady();


/**
 * Executes when Happy Hour starts.
 *
 * @param time          Runtime of the happy hour in seconds.
 * @param factor        Multiplication Factor for Stamm points.
 */
forward STAMM_OnHappyHourStart(time, factor);


/**
 * Executes when Happy Hour ends.
 */
forward STAMM_OnHappyHourEnd();


/**
 * Executes when a client requests the command menu.
 * Here you can add your commands.
 * Use the parameter client to format language phrases or whether he can use that command or not.
 *
 * @param client      Client that requests the command menu.
 */
forward STAMM_OnClientRequestCommands(client);





/**
 * Returns how a player can get Stamm points.
 *
 * @return              KILLS, ROUNDS, TIME, KILLS_ROUNDS, KILLS_TIME, ROUNDS_TIME, KILLS_ROUNDS_TIME
 */
native StammType:STAMM_GetType();


/**
 * Returns the game Stamm is running on (game of the server).
 *
 * @return             GameOTHER, GameCSS, GameCSGO, GameTF2, GameDOD
 */
native StammGame:STAMM_GetGame();


/**
 * Returns whether the server admin want auto updates for Stamm.
 * You can use this to know whether to auto update your feature.
 *
 * @return              True if he want, false otherwise.
 */
native bool:STAMM_AutoUpdate();


/**
 * Returns true when Stamm is fully loaded.
 * Use this if you are unsure whether you can use stamm stuff.
 *
 * @return              true if fully loaded, otherwise false.
 */
native bool:STAMM_IsLoaded();


/**
 * Starts Happy Hour.
 *
 * @param time          Runtime in minutes (must be greater than 1).
 * @param factor        Multiplication Factor for Stamm points.
 *
 * @return              Return false when happy hour already running, otherwise true.
 * @error               Time or factor invalid.
 */
native bool:STAMM_StartHappyHour(time, factor);


/**
 * Ends Happy Hour.
 *
 * @return              Return false when happy hour already off, otherwise true.
 */
native bool:STAMM_EndHappyHour();


/**
 * Logs a Message to the Stamm Log File.
 *
 * @param debug         If true write to debug log file, otherwise to normal log file.
 * @param fmt           Format string.
 * @param ...           Format arguments.
 *
 * @noreturn
 */
native STAMM_WriteToLog(bool:debug, const String:fmt[], any:...);


/**
 * Gets the Stamm Chat Tag.
 * You can use this to print messages with the specific tag.
 *
 * @param tag           String to save tag in.
 * @param maxlength     Maxlength of the string.
 *
 * @noreturn
 */
native STAMM_GetTag(String:tag[], maxlength);


/**
 * Only use this in forward STAMM_OnClientRequestCommands
 *
 * Adds a new command to the command list in the stamm menu.
 * Use this to inform the player of a command you registered for your feature.
 *
 * @param command       The real command to add.
 * @param name          The name of the command.
 * @param ...           The name Format arguments.
 *
 * @error               Max Commands reached, outside forward STAMM_OnClientRequestCommands
 *
 * @noreturn
 */
native STAMM_AddCommand(const String:command[], const String:name[], any:...);


/**
 * Loads a Stamm Feature.
 *
 * @param plugin        Handle of the plugin.
 *
 * @return              -1 = already loaded, 0 = no such Feature, 1 = success.
 */
native STAMM_LoadFeature(Handle:plugin);


/**
 * Unloads a Stamm Feature.
 *
 * @param plugin        Handle of the plugin.
 *
 * @return              -1 = already unloaded, 0 = no such Feature, 1 = success.
 */
native STAMM_UnloadFeature(Handle:plugin);



/**
 * Checks whether stamm is available on the server.
 * Use this to stop your feature, when stamm isn't available.
 *
 * @return              True when stamm is available, otherwise false.
 */
stock STAMM_IsAvailable()
{
	return LibraryExists("stamm");
}







public SharedPlugin:__pl_stamm = 
{
	name = "stamm",
	file = "stamm.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};



#if !defined REQUIRE_PLUGIN
	public __pl_stamm_SetNTVOptional()
	{
		MarkNativeAsOptional("STAMM_AddFeature");
		MarkNativeAsOptional("STAMM_RegisterFeature");
		MarkNativeAsOptional("STAMM_AddFeatureText");
		MarkNativeAsOptional("STAMM_AddBlockDescription");
		MarkNativeAsOptional("STAMM_IsMyFeature");
		MarkNativeAsOptional("STAMM_GetLevel");
		MarkNativeAsOptional("STAMM_GetBlockLevel");
		/* TODO: MarkNativeAsOptional("STAMM_GetPoints"); */
		/* TODO: MarkNativeAsOptional("STAMM_IsShop"); */
		MarkNativeAsOptional("STAMM_GetBlockCount");
		MarkNativeAsOptional("STAMM_GetBlockName");
		MarkNativeAsOptional("STAMM_GetBlockOfName");
		MarkNativeAsOptional("STAMM_GetBasename");
		MarkNativeAsOptional("STAMM_GetClientPoints");
		MarkNativeAsOptional("STAMM_GetClientLevel");
		MarkNativeAsOptional("STAMM_GetLevelName");
		MarkNativeAsOptional("STAMM_IsLevelPrivate");
		MarkNativeAsOptional("STAMM_GetLevelNumber");
		MarkNativeAsOptional("STAMM_GetLevelPoints");
		MarkNativeAsOptional("STAMM_GetLevelCount");
		MarkNativeAsOptional("STAMM_GetType");
		MarkNativeAsOptional("STAMM_GetGame");
		MarkNativeAsOptional("STAMM_GetClientBlock");
		MarkNativeAsOptional("STAMM_AddClientPoints");
		MarkNativeAsOptional("STAMM_DelClientPoints");
		MarkNativeAsOptional("STAMM_SetClientPoints");
		MarkNativeAsOptional("STAMM_HaveClientFeature");
		MarkNativeAsOptional("STAMM_IsClientVip");
		MarkNativeAsOptional("STAMM_IsClientValid");
		MarkNativeAsOptional("STAMM_IsClientAdmin");
		MarkNativeAsOptional("STAMM_IsLoaded");
		MarkNativeAsOptional("STAMM_WantClientFeature");
		MarkNativeAsOptional("STAMM_StartHappyHour");
		MarkNativeAsOptional("STAMM_EndHappyHour");
		MarkNativeAsOptional("STAMM_LoadFeature");
		MarkNativeAsOptional("STAMM_UnloadFeature");
		MarkNativeAsOptional("STAMM_WriteToLog");
		MarkNativeAsOptional("STAMM_AutoUpdate");
		MarkNativeAsOptional("STAMM_GetTag");
	}
#endif