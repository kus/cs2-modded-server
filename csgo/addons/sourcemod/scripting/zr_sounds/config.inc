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

