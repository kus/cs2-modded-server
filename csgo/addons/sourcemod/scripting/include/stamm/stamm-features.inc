#if defined _stamm_features_included
	#endinput
#endif
#define _stamm_features_included




/**
 * Here are the forwards and natives you need to register your feature.
 * First of all use STAMM_AddFeature or STAMM_AddFastFeature on OnAllPluginsLoaded.
 * If you have translations, put them to addons/sourcemod/translations/stamm, then use STAMM_LoadTranslation to load your translations.
 *
 * If your feature is loaded by stamm, the forward STAMM_OnFeatureLoaded will be fired. 
 * From that moment on, you can start to work with your feature.
 * There you should add block descriptions and so on...
 */





/**
 * Max. features supported by Stamm.
 */
#define STAMM_MAX_FEATURES 100







/**
 * Executes when your feature is loaded by Stamm.
 * Here you can begin to work with your feature.
 *
 * @param basename      Basename of your feature.
 */
forward STAMM_OnFeatureLoaded(const String:basename[]);


/**
 * Executes when a player switched your feature on/off in the stamm menu.
 * Use this to add/remove your Feature from the client.
 *
 * TODO: bought/sold it.
 *
 * @param client        Client index of the client.
 * @param turnedOn      true = Switched the feature on (TODO: bought it), false = Switched the feature off (TODO: sold it).
 * TODO: @param isShop  true = Was called from shop, false = Was called from menu (Currently this is always false)
 */
forward STAMM_OnClientChangedFeature(client, bool:turnedOn, bool:isShop);


/**
 * Executes when a client requests information about your plugin.
 *
 * This will convert the block to the level and add a text in the stamm menu
 * with information what the player will get on this level, so make this detailed!
 *
 * Use the parameter client to format language phrases.
 *
 * @param client      Client that requests the feature menu.
 * @param block       Block the player wants information about.
 * @param array       An ADT Array. Push your information strings here in. Never close this!
 */
forward STAMM_OnClientRequestFeatureInfo(client, block, &Handle:array);







/**
 * Registers a new Stamm Feature.
 *
 * @param name          Short Name of the Feature.
 * @param allowChange   true = Player can switch Feature on/off, false = he can't.
 * @param standard      true = Plugin is default enabled, false = Player have to enable it first.
 *
 * @noreturn
 * @error               Max features reached.
 */
native STAMM_RegisterFeature(const String:name[], bool:allowChange=true, bool:standard=true);


/**
 * Checks whether a client has the minimum the level to get a specific block.
 * Also checks whether the client wants your feature.
 *
 * TODO: He bought it and wants it.
 *
 * @param client        Client.
 * @param block         Block to check access for.
 *
 * @return              true if clients level high enough and wants your feature, otherwise false.
 * @error               Client, feature or block is invalid.
 */
native bool:STAMM_HaveClientFeature(client, block=1);


/**
 * Returns true when the specific player enabled this feature in his menu, false otherwise.
 *
 * @param client        Client.
 *
 * @return              true if the player enabled it, otherwise false.
 * @error               Client or feature is invalid.
 */
native bool:STAMM_WantClientFeature(client);


/**
 * Returns whether the basename is the basename of your plugin
 *
 * @param basename      Basename to look for.
 *
 * @return              Returns true when the basename is your feature, otherwise false.
 * @error               Feature is invalid.
 */
native bool:STAMM_IsMyFeature(const String:basename[]);


/**
 * Returns the basename of your plugin.
 *
 * @param basename      String to store basename in.
 * @param maxlength     Maxlength of the basename.
 * @noreturn
 * @error               Feature is invalid.
 */
native STAMM_GetBasename(String:basename[], maxlength);


/**
 * DEPRECATED! Use STAMM_RegisterFeature instead!
 *
 * Registers a new Stamm Feature.
 *
 * @param name          Short Name of the Feature.
 * @param description   Feature description for all blocks (Also can be added with STAMM_AddBlockDescription).
 * @param allowChange   true = Player can switch Feature on/off, false = he can't.
 * @param standard      true = Plugin is default enabled, false = Player have to enable it first.
 *
 * @noreturn
 * @error               Max features reached.
 */
#pragma deprecated Use STAMM_RegisterFeature instead!
native STAMM_AddFeature(const String:name[], const String:description[]="", bool:allowChange=true, bool:standard=true);


/**
 * DEPRECATED! Does nothing. Use Forward STAMM_OnClientRequestFeatureInfo instead!
 *
 * Adds information about what a player get on a specific level with this feature.
 *
 * @param level         The level, 0=No VIP, x=Level.
 * @param description   What a player get on this level.
 *
 * @return              true = success, false = error.
 * @error               Level or feature is invalid.
 */
#pragma deprecated Does nothing. Use Forward STAMM_OnClientRequestFeatureInfo instead!
native bool:STAMM_AddFeatureText(level, const String:description[]);




/**
 * Loads the translation file of your feature in languages/stamm.
 *
 * @noreturn
 */
stock STAMM_LoadTranslation()
{
	decl String:basename[64];
	decl String:path[PLATFORM_MAX_PATH + 1];

	STAMM_GetBasename(basename, sizeof(basename));
	
	if (STAMM_IsMoreColorsAvailable())
	{
		BuildPath(Path_SM, path, sizeof(path), "translations/stamm/%s.morecolors.txt", basename);

		if (!FileExists(path))
		{
			Format(basename, sizeof(basename), "stamm/%s", basename);
		}
		else
		{
			Format(basename, sizeof(basename), "stamm/%s.morecolors", basename);
		}
	}
	else
	{
		Format(basename, sizeof(basename), "stamm/%s", basename);
	}
	
	LoadTranslations(basename);
}