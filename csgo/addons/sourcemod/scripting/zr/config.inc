/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  config.inc
 *  Type:		  Core
 *  Description:   Config API and executing.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/*
	Using config API:
	
	-Before any of these helper functions can be used on a config file you must
	 "register" the module handling the data.
	
	Example:
	
	ConfigRegisterConfig(File_Example, Structure_List, "example");
	
	* The first parameter of this call is the config file we want to register.
	  this needs to be listed in the "ConfigFile" enum in config.inc.
	  
	* The second parameter is the structure of the config file we are loading.
	  The supported structures are listed in the "ConfigStructure" enum in config.inc
	  
	* The last parameter is the file's alias.  Or what we use to refer to the
	  config file from a non-developer's point of view.  For example zr_config_reload
	  requires the file alias to identify the config file the user wants to reload.
	
	-Next we need to define the config file's path.  To do this we first need to
	 retrieve the path file from cvar.
	 
	 Example:
	 
	 bool exists = ConfigGetCvarFilePath(CVAR_CONFIG_PATH_EXAMPLE, pathexample);
	 
	 * The first parameter is the cvar handle we are looking into.
	   
	 * The second parameter is the string to store the path in.
	   
	 * The return value is true if the file exists on the server, false if not.
	   If the file doesn't exist, handle it.  (Print log, stop plugin, etc)	 
	
	 Then store it in the config file data.
	 
	 Example:
	
	ConfigSetConfigPath(File_Example, pathexample);
	
	* The first parameter is the config file we want to set path to.
	  
	* The second parameter is the path we want to set to the config file.
	
	-Next we load config file and prepare its nested array structure.
	
	Example:
	
	bool success = ConfigLoadConfig(File_Example, arrayExample);
	
	* The first parameter is the config file we want to load.
	  
	* The second parameter is the array handle we want to prepare data structure in.
	  
	* The return value is true if the file was successfully loaded, false if the
	  config file couldn't be loaded.  (Invalid data, missing quotes, brackets, etc)
	
	-Next validate the config so far, stopping if no data was found or if ConfigLoadConfig
	 returned false.
	
	-Then cache the config file data into the arrays (only for Keyvalue structures)
	 by iterating through the data and pushing the values into the array.
	
	-Validate the values of the data.
	
	-Lastly we need to set specific info to the module now that it has successfully
	 loaded.
	
	Example:
	
	ConfigSetConfigLoaded(File_Example, true);
	ConfigSetConfigReloadFunc(File_Example, GetFunctionByName(GetMyHandle(), "ExampleOnConfigReload"));
	ConfigSetConfigHandle(File_Example, arrayExample);
	
	These functions will modify the config file data for other things to use.
	(such as zr_config_reload)
	
	* The first function call will set the loaded state of the config file to
	  true, failing to do this will cause the config module to think your
	  config file isn't loaded, therefore causing some undesired erroring.
	  
	* The second function sets the reload function of the config file.  This
	  function will be called upon its config file being reloaded.
	  
	* The third function stores the array handle for use by other parts of the
	  module.
*/

/**
 * The max length of any config string value.
 */
#define CONFIG_MAX_LENGTH 32

/**
 * @section Config file reference aliases.
 */
#define CONFIG_FILE_ALIAS_MODELS		"models"
#define CONFIG_FILE_ALIAS_DOWNLOADS	 "downloads"
#define CONFIG_FILE_ALIAS_CLASSES	   "classes"
#define CONFIG_FILE_ALIAS_WEAPONS	   "weapons"
#define CONFIG_FILE_ALIAS_HITGROUPS	 "hitgroups"
/**
 * @endsection
 */

/**
 * List of config formats used by the plugin.
 */
enum ConfigStructure
{
	Structure_List,	 /** Config is structured as a simple list of strings. */
	Structure_Keyvalue, /** Config is a keyvalue structure */
}

/**
 * List of config files used by the plugin.
 */
enum ConfigFile
{
	File_Invalid = -1,  /** Invalid config file. */
	File_Models,		/** <sourcemod root>/configs/zr/models.txt (default) */
	File_Downloads,	 /** <sourcemod root>/configs/zr/downloads.txt (default) */
	File_Classes,	   /** <sourcemod root>/configs/zr/playerclasses.txt (default) */
	File_Weapons,	   /** <sourcemod root>/configs/zr/weapons.txt (default) */
	File_Hitgroups,	 /** <sourcemod root>/configs/zr/hitgroups.txt (default) */
}

/**
 * Data container for each config file.
 */
enum ConfigData
{
	bool:			   Data_Loaded,					/** True if config is loaded, false if not. */
	ConfigStructure:	Data_Structure,				 /** Format of the config */
	Function:		   Data_ReloadFunc,				/** Function to call to reload config. */
	Handle:			 Data_Handle,					/** Handle of the config file. */
	String:			 Data_Path[PLATFORM_MAX_PATH],   /** Full path to config file. */
	String:			 Data_Alias[CONFIG_MAX_LENGTH],  /** Config file alias, used for client interaction. */
}

/**
 * Stores all config data.
 */
g_ConfigData[ConfigFile][ConfigData];

/**
 * Stores status of the optional ConfigList plugin.
 */
bool g_ConfigListAvailable = false;

/**
 * Actions to use when working on key/values.
 */
enum ConfigKvAction
{
	KvAction_Create,	/** Create a key. */
	KvAction_KVDelete,  /** Delete a key. */
	KvAction_KVSet,	 /** Modify setting of a key. */
	KvAction_KVGet,	 /** Get setting of a key. */
}

/**
 * Create commands related to config here.
 */
void ConfigOnCommandsCreate()
{
	// Create config admin commands.
	RegConsoleCmd("zr_config_reload", ConfigReloadCommand, "Reloads a config file. Usage: zr_config_reload <file alias>");
	RegConsoleCmd("zr_config_reloadall", ConfigReloadAllCommand, "Reloads all config files. Usage: zr_config_reloadall");
}

/**
 * Load plugin configs. Executes map configs.
 */
void ConfigLoad()
{
	char mapconfig[PLATFORM_MAX_PATH];
	
	// Get map name and format into config path.
	GetCurrentMap(mapconfig, sizeof(mapconfig));
	Format(mapconfig, sizeof(mapconfig), "sourcemod/zombiereloaded/%s.cfg", mapconfig);
	
	// Prepend cfg to path.
	char path[PLATFORM_MAX_PATH];
	Format(path, sizeof(path), "cfg/%s", mapconfig);
	
	// File doesn't exist, then stop.
	if (!FileExists(path))
	{
		return;
	}
	
	// Execute config file.
	ServerCommand("exec %s", mapconfig);
	
	// Log action.
	LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Config, "Map Configs", "Executed map config file: %s", path);
}

/**
 * Executed when modules are done loading. After all init calls in
 * OnConfigsExecuted.
 *
 * Executes post map configs if they exist.
 */
void ConfigOnModulesLoaded()
{
	char mapname[256];
	char mapconfig[PLATFORM_MAX_PATH];
	char path[PLATFORM_MAX_PATH];
	
	// Get map name and format into config path.
	GetCurrentMap(mapname, sizeof(mapname));
	Format(mapconfig, sizeof(mapconfig), "sourcemod/zombiereloaded/%s.post.cfg", mapname);
	
	// Prepend cfg to path.
	Format(path, sizeof(path), "cfg/%s", mapconfig);
	
	// Workaround for bug 3083 in SourceMod compiler. Having FileExist directly
	// in the if in this function makes it crash. Storing the result in a
	// boolean first works.
	
	// Check if the file exist.
	bool cfgexists = FileExists(path);
	if (!cfgexists)
	{
		// File doesn't exist, then stop.
		return;
	}
	
	// Check if ConfigList is available.
	if (g_ConfigListAvailable)
	{
		// Execute the zr_post_exec list before the map config file. This list
		// may not exist, but that's ok.
		ServerCommand("cfglist_exec_list zr_post_exec");
	}
	
	// Execute config file.
	ServerCommand("exec %s", mapconfig);
	
	// Log action.
	LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Config, "Post Map Configs", "Executed post map config file: %s", path);
}

/**
 * All plugins have finished loading.
 */
void ConfigOnAllPluginsLoaded()
{
	g_ConfigListAvailable = LibraryExists("configlist");
}

/**
 * A library was added.
 */
void ConfigOnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "configlist"))
	{
		// ConfigList loaded.
		g_ConfigListAvailable = true;
	}
}

/**
 * A library was removed.
 */
void ConfigOnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "configlist"))
	{
		// ConfigList was unloaded.
		g_ConfigListAvailable = false;
	}
}

/**
 * Used by modules that rely on configs to register their config file info.
 * (Don't forget to set 'loaded' to 'true' (ConfigSetConfigLoaded) in config load function)
 *
 * @param file	  Config file entry to register.
 * @param alias	 Config file alias, used for client interaction.
 */
stock void ConfigRegisterConfig(ConfigFile file, ConfigStructure structure, const char[] alias = "")
{
	// Copy file info to data container.
	g_ConfigData[file][Data_Loaded] = false;
	g_ConfigData[file][Data_Structure] = structure;
	g_ConfigData[file][Data_Handle] = INVALID_HANDLE;
	g_ConfigData[file][Data_ReloadFunc] = INVALID_FUNCTION;
	strcopy(g_ConfigData[file][Data_Path], PLATFORM_MAX_PATH, "");
	strcopy(g_ConfigData[file][Data_Alias], CONFIG_MAX_LENGTH, alias);
}

/**
 * Set the loaded state of a config file entry.
 * 
 * @param config	Config file to set load state of.
 * @param loaded	True to set as loaded, false to set as unloaded.
 */
stock void ConfigSetConfigLoaded(ConfigFile config, bool loaded)
{
	// Set load state.
	g_ConfigData[config][Data_Loaded] = loaded;
}

/**
 * Set the structure type of a config file entry.
 * 
 * @param config	Config file to set structure type of.
 * @param structure Structure to set as.
 */
stock void ConfigSetConfigStructure(ConfigFile config, ConfigStructure structure)
{
	// Set load state.
	g_ConfigData[config][Data_Structure] = structure;
}

/**
 * Set the reload function of a config file entry.
 * 
 * @param config		Config file to set reload function of.
 * @param reloadfunc	Reload function.
 */
stock void ConfigSetConfigReloadFunc(ConfigFile config, Function reloadfunc)
{
	// Set reload function.
	g_ConfigData[config][Data_ReloadFunc] = reloadfunc;
}

/**
 * Set the file handle of a config file entry.
 * 
 * @param config	Config file to set handle of.
 * @param loaded	Config file handle.
 */
stock void ConfigSetConfigHandle(ConfigFile config, Handle file)
{
	// Set file handle.
	g_ConfigData[config][Data_Handle] = file;
}

/**
 * Set the config file path of a config file entry.
 * 
 * @param config	Config file to set file path of.
 * @param loaded	File path.
 */
stock void ConfigSetConfigPath(ConfigFile config, const char[] path)
{
	// Set config file path.
	strcopy(g_ConfigData[config][Data_Path], PLATFORM_MAX_PATH, path);
}

/**
 * Set the alias of a config file entry.
 * 
 * @param config	Config file to set alias of.
 * @param loaded	Alias of the config file entry.
 */
stock void ConfigSetConfigAlias(ConfigFile config, const char[] alias)
{
	// Set config alias.
	strcopy(g_ConfigData[config][Data_Alias], CONFIG_MAX_LENGTH, alias);
}

/**
 * Returns if a config was successfully loaded.
 * 
 * @param config	Config file to check load status of.
 * @return		  True if config is loaded, false otherwise.
 */
stock bool ConfigIsConfigLoaded(ConfigFile config)
{
	// Return load status.
	return g_ConfigData[config][Data_Loaded];
}

/**
 * Returns config's structure type.
 * 
 * @param config	Config file to get structure type of.
 * @return		  Config structure type.
 */
stock ConfigStructure ConfigGetConfigStructure(ConfigFile config)
{
	// Return load status.
	return g_ConfigData[config][Data_Structure];
}

/**
 * Returns config's reload function.
 * 
 * @param config	Config file to get reload function of.
 * @return		  Config reload function.
 */
stock Function ConfigGetConfigReloadFunc(ConfigFile config)
{
	// Return load status.
	return g_ConfigData[config][Data_ReloadFunc];
}

/**
 * Returns config's file handle.
 * 
 * @param config	Config file to get file handle of.
 * @return		  Config file handle.
 */
stock Handle ConfigGetConfigHandle(ConfigFile config)
{
	// Return load status.
	return g_ConfigData[config][Data_Handle];
}

/**
 * Returns the path for a given config file entry.
 * 
 * @param config	Config file to get path of. (see ConfigFile enum)
 */
stock void ConfigGetConfigPath(ConfigFile config, char[] path, int maxlen)
{
	// Copy path to return string.
	strcopy(path, maxlen, g_ConfigData[config][Data_Path]);
}

/**
 * Returns the alias for a given config file entry.
 * 
 * @param config	Config file to get alias of. (see ConfigFile enum)
 */
stock void ConfigGetConfigAlias(ConfigFile config, char[] alias, int maxlen)
{
	// Copy alias to return string.
	strcopy(alias, maxlen, g_ConfigData[config][Data_Alias]);
}

/**
 * Loads a config file and sets up a nested array type data storage.
 * 
 * @param config		The config file to load.
 * @param arrayConfig   Handle of the main array containing file data.
 * @param blocksize	 The max length of the contained strings. 
 * @return			  True if file was loaded successfuly, false otherwise.
 */
stock bool ConfigLoadConfig(ConfigFile config, Handle &arrayConfig, int blocksize = CONFIG_MAX_LENGTH)
{
	// Get config's structure.
	ConfigStructure structure = ConfigGetConfigStructure(config);
	
	// Get config's alias
	char configalias[CONFIG_MAX_LENGTH];
	ConfigGetConfigAlias(config, configalias, sizeof(configalias));
	
	// Get config's file path.
	char configpath[PLATFORM_MAX_PATH];
	ConfigGetConfigPath(config, configpath, sizeof(configpath));
	
	// If array hasn't been created, then create.
	if (arrayConfig == INVALID_HANDLE)
	{
		// Create array in handle.
		arrayConfig = CreateArray(blocksize);
	}
	
	switch(structure)
	{
		case Structure_List:
		{
			// Open file.
			Handle hFile;
			int success = ConfigOpenConfigFile(config, hFile);
			
			// If config file failed to open, then stop.
			if (!success)
			{
				return false;
			}
			
			// Clear out array.
			ClearArray(arrayConfig);
			
			char line[PLATFORM_MAX_PATH];
			
			while(ReadFileLine(hFile, line, sizeof(line)))
			{
				// Cut out comments at the end of a line.
				if (StrContains(line, "//") > -1)
				{
					SplitString(line, "//", line, sizeof(line));
				}
				
				// Trim off whitespace.
				TrimString(line);
				
				// If line is empty, then stop.
				if (!line[0])
				{
					continue;
				}
				
				// Push line into array.
				PushArrayString(arrayConfig, line);
			}
			
			// We're done this file, so now we can destory it from memory. 
			CloseHandle(hFile);
			
			return true;
		}
		case Structure_Keyvalue:
		{
			// Open file.
			Handle hKeyvalue;
			int success = ConfigOpenConfigFile(config, hKeyvalue);
			
			// If config file failed to open, then stop.
			if (!success)
			{
				return false;
			}
			
			// Destroy all old data.
			ConfigClearKvArray(arrayConfig);
			
			if (KvGotoFirstSubKey(hKeyvalue))
			{
				do
				{
					// Create new array to store information for config entry.
					Handle arrayConfigEntry = CreateArray(blocksize);
					
					// Push the key name into the config entry's array.
					char keyname[CONFIG_MAX_LENGTH];
					KvGetSectionName(hKeyvalue, keyname, sizeof(keyname));
					
					PushArrayString(arrayConfigEntry, keyname); // Index: 0
					
					// Store this handle in the main array.
					PushArrayCell(arrayConfig, arrayConfigEntry);
				} while(KvGotoNextKey(hKeyvalue));
			}
			
			// We're done this file for now, so now we can destory it from memory. 
			CloseHandle(hKeyvalue);
			
			return true;
		}
	}
	
	return false;
}

/**
 * Reload a config file.
 * 
 * @param config	The config file entry to reload.
 * @return		  True if the config is loaded, false if not.
 */
stock bool ConfigReloadConfig(ConfigFile config)
{
	// If file isn't loaded, then stop.
	bool loaded = ConfigIsConfigLoaded(config);
	if (!loaded)
	{
		return false;
	}
	
	// Call reload function
	Function reloadfunc = ConfigGetConfigReloadFunc(config);
	
	// This should never be true unless someone has tampered with the code.
	if (reloadfunc == INVALID_FUNCTION)
	{
		// Get config alias.
		char configalias[CONFIG_MAX_LENGTH];
		ConfigGetConfigAlias(config, configalias, sizeof(configalias));
		
		// Print reload failure to logs.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Config, "Reload Function", "Invalid reload function for config: \"%s\"", configalias);
		
		return true;
	}
	
	// Call reload function.
	Call_StartFunction(GetMyHandle(), reloadfunc);
	Call_Finish();
	
	return true;
}

/**
 * Opens a config file with appropriate method.
 * 
 * @param config	The config file.
 * @param structure The structure of the config file.
 * @param hConfig   The handle of the opened file.
 */
stock bool ConfigOpenConfigFile(ConfigFile config, Handle &hConfig)
{
	// Get config's structure
	ConfigStructure structure = ConfigGetConfigStructure(config);
	
	// Get config's file path.
	char configpath[PLATFORM_MAX_PATH];
	ConfigGetConfigPath(config, configpath, sizeof(configpath));
	
	// Get config's alias
	char configalias[CONFIG_MAX_LENGTH];
	ConfigGetConfigAlias(config, configalias, sizeof(configalias));
	
	switch(structure)
	{
		case Structure_List:
		{
			// Open file.
			hConfig = OpenFile(configpath, "r");
			
			// If file couldn't be opened, then stop.
			if (hConfig == INVALID_HANDLE)
			{
				return false;
			}
			
			return true;
		}
		case Structure_Keyvalue:
		{
			hConfig = CreateKeyValues(configalias);
			return FileToKeyValues(hConfig, configpath);
		}
	}
	
	return false;
}

/**
 * Creates, deletes, sets, or gets any key/setting of any ZR config keyvalue file in memory.
 * Only use when interacting with a command or manipulating single keys/values,
 * using this function everywhere would be EXTREMELY inefficient.
 * 
 * @param config		Config file to modify.
 * @param action		Action to perform on keyvalue tree. (see enum ConfigKeyvalueAction)
 * @param keys		  Array containing keys to traverse into.
 * @param keysMax	   The size of the 'keys' array.
 * @param setting	   (Optional) The name of the setting to modify.
 * @param value		 (Optional) The new value to set.
 * @param maxlen		(Optional) The maxlength of the retrieved value.
 * @return			  True if the change was made successfully, false otherwise. 
 */
stock bool ConfigKeyvalueTreeSetting(ConfigFile config, ConfigKvAction action = KvAction_Create, const char[][] keys, int keysMax, const char[] setting = "", char[] value = "", int maxlen = 0)
{
	// Get config file's structure.
	ConfigStructure structure = ConfigGetConfigStructure(config);
	
	// If the config is any other structure beside keyvalue, then stop.
	if (structure != Structure_Keyvalue)
	{
		return false;
	}
	
	// Retrieve handle of the keyvalue tree.
	Handle hConfig;
	bool success = ConfigOpenConfigFile(config, hConfig);
	
	// If the file couldn't be opened, then stop.
	if (!success)
	{
		return false;
	}
	
	// Rewind keyvalue tree.
	KvRewind(hConfig);
	
	// x = keys index.
	// Traverse into the keygroup, stop if it fails.
	for (int x = 0; x < keysMax; x++)
	{
		// If key is empty, then break the loop.
		if (!keys[x][0])
		{
			break;
		}
		
		// Try to jump to next level in the transversal stack, create key if specified.
		bool exists = KvJumpToKey(hConfig, keys[x], (action == KvAction_Create));
		
		// If exists is false, then stop.
		if (!exists)
		{
			// Key doesn't exist.
			return false;
		}
	}
	
	switch(action)
	{
		case KvAction_Create:
		{
			if (!setting[0] || !value[0])
			{
				// We created the key already, so return true.
				return true;
			}
			
			// Set new value.
			KvSetString(hConfig, setting, value);
		}
		case KvAction_Delete:
		{
			// Return deletion result.
			return KvDeleteKey(hConfig, setting);
		}
		case KvAction_Set:
		{
			// Set new value.
			KvSetString(hConfig, setting, value);
		}
		case KvAction_Get:
		{
			// Get current value.
			KvGetString(hConfig, setting, value, maxlen);
		}
	}
	
	// We successfully set or got the value.
	return true;
}

/**
 * Destroy all array handles within an array, and clear main array.
 * 
 * @param arrayKv   The array converted from a keyvalue structure.
 */
void ConfigClearKvArray(Handle arrayKv)
{
	//  x = array index
	int size = GetArraySize(arrayKv);
	for (int x = 0; x < size; x++)
	{
		// Destroy nested arrays.
		Handle arrayKvKey = GetArrayCell(arrayKv, x);
		CloseHandle(arrayKvKey);
	}
	
	// Now that all data within has been destroyed, we can clear the main array.
	ClearArray(arrayKv);
}

/**
 * Load config file.
 * 
 * @param file  The cvar define of the path to the file.
 * @return	  True if the file exists, false if not.
 */
stock bool ConfigGetCvarFilePath(CvarsList cvar, char[] path)
{
	// Get cvar's path.
	char filepath[PLATFORM_MAX_PATH];
	GetConVarString(view_as<Handle>(g_hCvarsList[cvar]), filepath, sizeof(filepath));
	
	// Build full path in return string.
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, filepath);
	
	return FileExists(path);
}

/**
 * Finds a config file entry, (see ConfigFile enum) for a given alias.
 * 
 * @param alias	 The alias to find config file entry of.
 * @return		  Config file entry, ConfigInvalid is returned if alias was not found.
 */
stock ConfigFile ConfigAliasToConfigFile(const char[] alias)
{
	char checkalias[CONFIG_MAX_LENGTH];
	
	// x = config file entry index.
	for (int x = 0; x < sizeof(g_ConfigData); x++)
	{
		// Get config alias.
		ConfigGetConfigAlias(view_as<ConfigFile>(x), checkalias, sizeof(checkalias));
		
		// If alias doesn't match, then stop.
		if (!StrEqual(alias, checkalias, false))
		{
			continue;
		}
		
		// Return config file entry.
		return view_as<ConfigFile>(x);
	}
	
	// Invalid config file.
	return File_Invalid;
}

/**
 * Command callback (zr_config_reload)
 * Reloads a config file and forwards event to modules.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ConfigReloadCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// If not enough arguments given, then stop.
	if (argc < 1)
	{
		TranslationReplyToCommand(client, "Config command reload syntax");
		TranslationReplyToCommand(client, "Config command reload related commands");
		TranslationPrintToConsole(client, "Config command reload syntax aliases", CONFIG_FILE_ALIAS_MODELS, CONFIG_FILE_ALIAS_DOWNLOADS, CONFIG_FILE_ALIAS_CLASSES, CONFIG_FILE_ALIAS_WEAPONS, CONFIG_FILE_ALIAS_HITGROUPS);
		return Plugin_Handled;
	}
	
	char filealias[CONFIG_MAX_LENGTH];
	char path[PLATFORM_MAX_PATH];
	char logmessage[LOG_MAX_LENGTH_FILE];
	
	int args = GetCmdArgs();
	for (int x = 1; x <= args; x++)
	{
		// Get alias to restrict.
		GetCmdArg(x, filealias, sizeof(filealias));
		
		// If alias is invalid, then stop.
		ConfigFile config = ConfigAliasToConfigFile(filealias);
		if (config == File_Invalid)
		{
			TranslationReplyToCommand(client, "Config command reload invalid", filealias);
			return Plugin_Handled;
		}
		
		// Reload config file.
		bool loaded = ConfigReloadConfig(config);
		
		// Get config file path.
		ConfigGetConfigPath(config, path, sizeof(path));
		
		// Format log message
		Format(logmessage, sizeof(logmessage), "Admin \"%L\" reloaded config file \"%s\". (zr_config_reload)", client, path);
	
		// If file isn't loaded then tell client, then stop.
		if (!loaded)
		{
			TranslationReplyToCommand(client, "Config command reload not loaded", filealias);
			
			// Format a failed attempt string to the end of the log message.
			Format(logmessage, sizeof(logmessage), "%s -- attempt failed, config file not loaded", logmessage);
		}
		
		// Log action to game events.
		LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Config, "Reload Config", logmessage);
	}
	
	return Plugin_Handled;
}

/**
 * Command callback (zr_config_reloadall)
 * Reloads all config files and forwards event to all modules.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ConfigReloadAllCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// Begin statistics.
	TranslationReplyToCommand(client, "Config command reload all stats begin");
	
	char configalias[CONFIG_MAX_LENGTH];
	
	// x = config file entry index.
	for (int x = 0; x < sizeof(g_ConfigData); x++)
	{
		// Reload config file.
		bool successful = ConfigReloadConfig(view_as<ConfigFile>(x));
		
		// Get config's alias.
		ConfigGetConfigAlias(view_as<ConfigFile>(x), configalias, sizeof(configalias));
		
		if (successful)
		{
			TranslationReplyToCommand(client, "Config command reload all stats successful", configalias);
		}
		else
		{
			TranslationReplyToCommand(client, "Config command reload all stats failed", configalias);
		}
	}
	
	// Log action to game events.
	LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Config, "Reload All Config", "Admin \"%L\" reloaded all config files.", client);
	
	return Plugin_Handled;
}

/**
 * Converts string of "yes/on" or "no/off" to a boolean value.  Always uses english as yes/no/on/off language.
 * 
 * @param option	"yes/on" or "no/off" string to be converted.
 * @return		  True if string is "yes", false otherwise.
 */
stock bool ConfigSettingToBool(const char[] option)
{
	// If option is equal to "yes," then return true.
	if (StrEqual(option, "yes", false) || StrEqual(option, "on", false) || StrEqual(option, "1", false))
	{
		return true;
	}
	
	// Option isn't yes.
	return false;
}

/**
 * Converts boolean value to "yes" or "no".
 * 
 * @param bOption   True/false value to be converted to "yes/on"/"no/off", respectively.
 * @param option	Destination string buffer to store "yes/on" or "no/off" in.
 * @param maxlen	Length of destination string buffer.
 * @param yesno	 When true, returns "yes/no", false returns "on/off."
 * @param target	The target to use as translation language.
 */
stock void ConfigBoolToSetting(bool bOption, char[] option, int maxlen, bool yesno = true, int target = LANG_SERVER)
{
	char t_yes[16], t_on[32];
	char t_no[16], t_off[32];
	
	SetGlobalTransTarget(target);
	
	// Get the yes/no translations for the target.
	Format(t_yes, sizeof(t_yes), "%t", "Yes");  Format(t_on, sizeof(t_on), "%t", "On");
	Format(t_no, sizeof(t_no), "%t", "No");	 Format(t_off, sizeof(t_off), "%t", "Off");
	
	// If option is true, then copy "yes" to return string.
	if (bOption)
	{
		yesno ? strcopy(option, maxlen, t_yes) : strcopy(option, maxlen, t_on);
	}
	// If option is false, then copy "no" to return string.
	else
	{
		yesno ? strcopy(option, maxlen, t_no) : strcopy(option, maxlen, t_off);
	}
}

/**
 * Returns a "yes/no" string from config as a bool.
 * 
 * @param kv			The keyvalue handle.
 * @param key		   The keyname the value is under.
 * @param defaultvalue  (Optional) Value to return if setting is missing.
 */
stock bool ConfigKvGetStringBool(Handle kv, const char[] key, const char[] defaultvalue = "yes")
{
	char value[CONFIG_MAX_LENGTH];
	KvGetString(kv, key, value, sizeof(value), defaultvalue);
	
	return ConfigSettingToBool(value);
}
