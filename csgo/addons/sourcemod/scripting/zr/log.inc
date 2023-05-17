/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  log.inc
 *  Type:		  Core
 *  Description:   Logging API.
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
 * Note: See log.h.inc for header types and defines.
 */

void LogInit()
{
	// Destroy existing handle to prevent memory leak.
	if (hLogModuleFilter != INVALID_HANDLE)
	{
		CloseHandle(hLogModuleFilter);
	}
	
	// Initialize module filter array.
	hLogModuleFilter = CreateArray(32);
}

/**
 * Convert module type to a string.
 *
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of destination buffer.
 * @param module		Module type to convert.
 * @param shortName	 Optional. Use short name instead of human readable
 *					  names. Default is false
 * @return			  Number of cells written.
 */
int LogGetModuleNameString(char[] buffer, int maxlen, LogModules module, bool shortName = false)
{
	switch (module)
	{
		case LogModule_Account:
		{
			return shortName ? strcopy(buffer, maxlen, "account") : strcopy(buffer, maxlen, "Account");
		}
		case LogModule_AntiStick:
		{
			return shortName ? strcopy(buffer, maxlen, "antistick") : strcopy(buffer, maxlen, "Anti-Stick");
		}
		case LogModule_Config:
		{
			return shortName ? strcopy(buffer, maxlen, "config") : strcopy(buffer, maxlen, "Config");
		}
		case LogModule_Cvars:
		{
			return shortName ? strcopy(buffer, maxlen, "cvars") : strcopy(buffer, maxlen, "CVARs");
		}
		case LogModule_Damage:
		{
			return shortName ? strcopy(buffer, maxlen, "damage") : strcopy(buffer, maxlen, "Damage");
		}
		case LogModule_Downloads:
		{
			return shortName ? strcopy(buffer, maxlen, "downloads") : strcopy(buffer, maxlen, "Downloads");
		}
		case LogModule_Hitgroups:
		{
			return shortName ? strcopy(buffer, maxlen, "hitgroups") : strcopy(buffer, maxlen, "Hit Groups");
		}
		case LogModule_Infect:
		{
			return shortName ? strcopy(buffer, maxlen, "infect") : strcopy(buffer, maxlen, "Infect");
		}
		case LogModule_Models:
		{
			return shortName ? strcopy(buffer, maxlen, "models") : strcopy(buffer, maxlen, "Models");
		}
		case LogModule_Napalm:
		{
			return shortName ? strcopy(buffer, maxlen, "napalm") : strcopy(buffer, maxlen, "Napalm");
		}
		case LogModule_Playerclasses:
		{
			return shortName ? strcopy(buffer, maxlen, "playerclasses") : strcopy(buffer, maxlen, "Player Classes");
		}
		case LogModule_VEffects:
		{
			return shortName ? strcopy(buffer, maxlen, "veffects") : strcopy(buffer, maxlen, "Visual Effects");
		}
		case LogModule_Tools:
		{
			return shortName ? strcopy(buffer, maxlen, "tools") : strcopy(buffer, maxlen, "Tools");
		}
		case LogModule_Volfeatures:
		{
			return shortName ? strcopy(buffer, maxlen, "volfeatures") : strcopy(buffer, maxlen, "Volumetric Features");
		}
		case LogModule_Weapons:
		{
			return shortName ? strcopy(buffer, maxlen, "weapons") : strcopy(buffer, maxlen, "Weapons");
		}
		case LogModule_Weaponrestrict:
		{
			return shortName ? strcopy(buffer, maxlen, "weaponrestrict") : strcopy(buffer, maxlen, "Weapon Restrictions");
		}
		case LogModule_ZSpawn:
		{
			return shortName ? strcopy(buffer, maxlen, "zspawn") : strcopy(buffer, maxlen, "ZSpawn");
		}
		case LogModule_ZTele:
		{
			return shortName ? strcopy(buffer, maxlen, "ztele") : strcopy(buffer, maxlen, "ZTele");
		}
	}
	
	// Module mismatch.
	return 0;
}

/**
 * Converts a string module name into a module type.
 *
 * @param moduleName	A string with the short module name. Case insensitive,
 *					  but not trimmed for white space.
 * @return			  The matcing module type or LogModules_Invalid if failed.
 */
LogModules LogGetModule(const char[] moduleName)
{
	if (StrEqual(moduleName, "account", false))
	{
		return LogModule_Account;
	}
	else if (StrEqual(moduleName, "antistick", false))
	{
		return LogModule_AntiStick;
	}
	else if (StrEqual(moduleName, "config", false))
	{
		return LogModule_Config;
	}
	else if (StrEqual(moduleName, "cvars", false))
	{
		return LogModule_Cvars;
	}
	else if (StrEqual(moduleName, "damage", false))
	{
		return LogModule_Damage;
	}
	else if (StrEqual(moduleName, "downloads", false))
	{
		return LogModule_Downloads;
	}
	else if (StrEqual(moduleName, "hitgroups", false))
	{
		return LogModule_Hitgroups;
	}
	else if (StrEqual(moduleName, "infect", false))
	{
		return LogModule_Infect;
	}
	else if (StrEqual(moduleName, "models", false))
	{
		return LogModule_Models;
	}
	else if (StrEqual(moduleName, "napalm", false))
	{
		return LogModule_Napalm;
	}
	else if (StrEqual(moduleName, "playerclasses", false))
	{
		return LogModule_Playerclasses;
	}
	else if (StrEqual(moduleName, "veffects", false))
	{
		return LogModule_VEffects;
	}
	else if (StrEqual(moduleName, "tools", false))
	{
		return LogModule_Tools;
	}
	else if (StrEqual(moduleName, "volfeatures", false))
	{
		return LogModule_Volfeatures;
	}
	else if (StrEqual(moduleName, "weapons", false))
	{
		return LogModule_Weapons;
	}
	else if (StrEqual(moduleName, "weaponrestrict", false))
	{
		return LogModule_Weaponrestrict;
	}
	else if (StrEqual(moduleName, "zspawn", false))
	{
		return LogModule_ZSpawn;
	}
	else if (StrEqual(moduleName, "ztele", false))
	{
		return LogModule_ZTele;
	}
	
	// No match.
	return LogModule_Invalid;
}

/**
 * Check if the specified log flag is set.
 *
 * @param eventType	 The log flag to check.
 * @return			  True if set, false otherwise.
 */
bool LogCheckFlag(int eventType)
{
	// Check if eventType is set.
	if (GetConVarInt(g_hCvarsList[CVAR_LOG_FLAGS]) & eventType)
	{
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * Check if the specified module is enabled in the log module filter cache.
 *
 * @param module		Module to check.
 * @return			  True if enabled, false otherwise. 
 */
bool LogCheckModuleFilter(LogModules module)
{
	if (LogModuleFilterCache[module])
	{
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * Print a formatted message to logs depending on log settings.
 *
 * @param isConsole	 Optional. Specifies whether the log event came from
 *					  client 0. Used in console commands, do not mix with
 *					  regular log events. Default is false.
 * @param logType	   Optional. Log type and action. Default is
 *					  LogType_Normal.
 * @param eventType	 Optional. A log flag describing What kind of log event
 *					  it is. Default is LOG_CORE_EVENTS.
 * @param module		Module the log event were executed in.
 * @param description   Event type or function name. A short descriptive phrase
 *					  to group together similar logs.
 * @param text		  Log message. Can be formatted.
 * @param ...		   Formatting parameters.
 */
Action LogEvent(bool isConsole = false, LogTypes logType = LogType_Normal, int eventType = LOG_CORE_EVENTS, LogModules module, const char[] description, const char[] text, any ...)
{
	// Check filter overrides. Always log fatal errors, and check error override setting on error log types.
	if ((logType != LogType_Fatal && logType != LogType_Error) || (logType == LogType_Error && !GetConVarBool(g_hCvarsList[CVAR_LOG_ERROR_OVERRIDE])))
	{
		// Check if logging is disabled.
		if (!GetConVarBool(g_hCvarsList[CVAR_LOG]))
		{
			return;
		}
		
		// Check if console is ignored.
		if (isConsole && GetConVarBool(g_hCvarsList[CVAR_LOG_IGNORE_CONSOLE]))
		{
			return;
		}
		
		// Check event type (log flag).
		if (!LogCheckFlag(eventType))
		{
			return;
		}
		
		// Check if module filtering is enabled.
		if (GetConVarBool(g_hCvarsList[CVAR_LOG_MODULE_FILTER]))
		{
			// Check if the specified module is enabled.
			if (!LogCheckModuleFilter(module))
			{
				return;
			}
		}
	}
	
	// Format extra parameters into the log buffer.
	char logbuffer[LOG_MAX_LENGTH_FILE];
	VFormat(logbuffer, sizeof(logbuffer), text, 7);
	
	// Get human readable module name.
	char modulename[64];
	LogGetModuleNameString(modulename, sizeof(modulename), module);
	
	// Format 
	Format(logbuffer, sizeof(logbuffer), "[%s] [%s] %s", modulename, description, logbuffer);
	
	// Format other parameters onto the log text.
	switch (logType)
	{
		// Log type is normal.
		case LogType_Normal:
		{
			LogMessage(logbuffer);
		}
		// Log type is error.
		case LogType_Error:
		{
			LogError(logbuffer);
		}
		// Log type is fatal error.
		case LogType_Fatal:
		{
			SetFailState(logbuffer);
		}
	}
	
	// Note: The phrase "Literal text" is a blank phrase to pass any string we want into it.
	
	// Check if printing log events to admins is enabled.
	if (GetConVarBool(g_hCvarsList[CVAR_LOG_PRINT_ADMINS]))
	{
		// Print text to admins.
		TranslationPrintToChatAll(false, true, "Literal text", logbuffer);
	}
	
	// Check if printing log events to public chat is enabled.
	if (GetConVarBool(g_hCvarsList[CVAR_LOG_PRINT_CHAT]))
	{
		// Print text to public chat.
		TranslationPrintToChatAll(false, false, "Literal text", logbuffer);
	}
}

/**
 * Adds a module to the module filter and updates the cache. If it already
 * exist the command is ignored.
 *
 * @param module	The module to add.
 * @return		  True if added, false otherwise.
 */
bool LogModuleFilterAdd(LogModules module)
{
	char modulename[64];
	
	// Check if empty.
	if (strlen(modulename) == 0)
	{
		return false;
	}
	
	// Convert module name.
	LogGetModuleNameString(modulename, sizeof(modulename), module, true);
	
	// Check if the module isn't already is listed.
	if (FindStringInArray(hLogModuleFilter, modulename) < 0)
	{
		// Add module to filter.
		PushArrayString(hLogModuleFilter, modulename);
		return true;
	}
	
	return false;
}

/**
 * Removes a module to the module filter and updates the cache. If it doesn't
 * exist the command is ignored.
 *
 * @param module	The module to remove.
 * @return		  True if removed, false otherwise.
 */
bool LogModuleFilterRemove(LogModules module)
{
	char modulename[64];
	int moduleindex;
	
	// Check if empty.
	if (strlen(modulename) == 0)
	{
		return false;
	}
	
	// Convert module name.
	LogGetModuleNameString(modulename, sizeof(modulename), module, true);
	
	// Get the module index.
	moduleindex = FindStringInArray(hLogModuleFilter, modulename);
	
	// Check if successful.
	if (moduleindex >= 0)
	{
		// Remove module from filter.
		RemoveFromArray(hLogModuleFilter, moduleindex);
		return true;
	}
	
	return false;
}

/**
 * Update module filter cache.
 */
void LogModuleFilterCacheUpdate()
{
	char modulename[64];
	LogModules moduletype;
	int modulecount;
	int filtersize;
	
	// Clear all entries in module cache.
	modulecount = sizeof(LogModuleFilterCache);
	for (int module = 1; module < modulecount; module++)
	{
		LogModuleFilterCache[view_as<LogModules>(module)] = false;
	}
	
	// Loop through the module array.
	filtersize = GetArraySize(hLogModuleFilter);
	for (int index = 0; index < filtersize; index++)
	{
		// Get the module name.
		GetArrayString(hLogModuleFilter, index, modulename, sizeof(modulename));
		
		// Convert to type.
		moduletype = LogGetModule(modulename);
		
		// Validate type.
		if (moduletype != LogModule_Invalid)
		{
			// Set value in cache.
			LogModuleFilterCache[moduletype] = true;
		}
	}
}

/**
 * Creates commands for logging module. Called when commands are created.
 */
void LogOnCommandsCreate()
{
	RegConsoleCmd("zr_log_list", Command_LogList, "List available logging flags and modules with their status values.");
	RegConsoleCmd("zr_log_add_module", Command_LogAddModule, "Add one or more modules to the module filter. Usage: zr_log_add_module <module> [module] ...");
	RegConsoleCmd("zr_log_remove_module", Command_LogRemoveModule, "Remove one or more modules from the module filter. Usage: zr_log_remove_module <module> [module] ...");
}

/**
 * Handles the zr_log_list command. Displays flags and module filter cache.
 *
 * @param client	The client that executed the command.
 * @param argc	  Number of arguments passed.
 */
public Action Command_LogList(int client, int argc)
{
	char buffer[2048];
	char linebuffer[96];
	char modulename[64];
	char modulenameshort[64];
	
	int modulecount;
	
	// Strings to store translated phrases. Because formatting width settings
	// doesn't work with "%t", but "%s".
	char phrasegenericflag[32];
	char phrasevalue[32];
	char phrasemodule[32];
	char phraseshortname[32];
	
	// Quick initialize string buffer.
	buffer[0] = 0;
	
	// Set language.
	SetGlobalTransTarget(client);
	
	// Get phrases.
	Format(phrasegenericflag, sizeof(phrasegenericflag), "%t", "Log Generic Flag");
	Format(phrasevalue, sizeof(phrasevalue), "%t", "Log Value");
	Format(phrasemodule, sizeof(phrasemodule), "%t", "Log Module");
	Format(phraseshortname, sizeof(phraseshortname), "%t", "Log Module Short Name");
	
	// Log flags:
	Format(linebuffer, sizeof(linebuffer), "%-19s %-7s %t\n", phrasegenericflag, phrasevalue, "Log Status");
	StrCat(buffer, sizeof(buffer), linebuffer);
	StrCat(buffer, sizeof(buffer), "--------------------------------------------------------------------------------\n");
	
	Format(linebuffer, sizeof(linebuffer), "LOG_CORE_EVENTS	 1	   %t\n", LogCheckFlag(LOG_CORE_EVENTS) ? "On" : "Off");
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), "LOG_GAME_EVENTS	 2	   %t\n", LogCheckFlag(LOG_GAME_EVENTS) ? "On" : "Off");
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), "LOG_PLAYER_COMMANDS 4	   %t\n", LogCheckFlag(LOG_PLAYER_COMMANDS) ? "On" : "Off");
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), "LOG_DEBUG		   8	   %t\n", LogCheckFlag(LOG_DEBUG) ? "On" : "Off");
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), "LOG_DEBUG_DETAIL	16	  %t\n", LogCheckFlag(LOG_DEBUG_DETAIL) ? "On" : "Off");
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	ReplyToCommand(client, buffer);
	buffer[0] = 0;
	
	// Module filtering status:
	Format(linebuffer, sizeof(linebuffer), "%t %t\n\n", "Log Module Filtering", GetConVarBool(g_hCvarsList[CVAR_LOG_MODULE_FILTER]) ? "On" : "Off");
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), "%-23s %-19s %t\n", phrasemodule, phraseshortname, "Log Status");
	StrCat(buffer, sizeof(buffer), linebuffer);
	StrCat(buffer, sizeof(buffer), "--------------------------------------------------------------------------------");
	
	ReplyToCommand(client, buffer);
	buffer[0] = 0;
	
	// Module status:
	modulecount = sizeof(LogModuleFilterCache);
	for (int module = 1; module < modulecount; module++)
	{
		LogGetModuleNameString(modulename, sizeof(modulename), view_as<LogModules>(module));
		LogGetModuleNameString(modulenameshort, sizeof(modulenameshort), view_as<LogModules>(module), true);
		Format(linebuffer, sizeof(linebuffer), "%-23s %-19s %t", modulename, modulenameshort, LogModuleFilterCache[view_as<LogModules>(module)] ? "On" : "Off");
		ReplyToCommand(client, linebuffer);
	}
	
	return Plugin_Handled;
}

/**
 * Handles the zr_log_add_module command. Add one or modules to module filter.
 *
 * @param client	The client that executed the command.
 * @param argc	  Number of arguments passed.
 */
public Action Command_LogAddModule(int client, int argc)
{
	char buffer[256];
	char argument[32];
	buffer[0] = 0;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	LogModules logmodule;
	
	// Check if no arguments.
	if (argc < 1)
	{
		// Display syntax info.
		StrCat(buffer, sizeof(buffer), "Add one or more modules to the module filter. Usage: zr_log_add_module <module> [module] ...\n");
		StrCat(buffer, sizeof(buffer), "See zr_log_list to list available module names (short names).");
		ReplyToCommand(client, buffer);
	}
	
	// Loop through each argument.
	for (int arg = 1; arg <= argc; arg++)
	{
		// Get argument string.
		GetCmdArg(arg, argument, sizeof(argument));
		
		// Convert to module type.
		logmodule = LogGetModule(argument);
		
		// Check if invalid.
		if (logmodule == LogModule_Invalid)
		{
			ReplyToCommand(client, "Invalid module name: \"%s\"", argument);
			
			// Skip to next argument.
			continue;
		}
		
		LogModuleFilterAdd(logmodule);
		ReplyToCommand(client, "Added \"%s\" to module filter.", argument);
	}
	
	// Update cache.
	LogModuleFilterCacheUpdate();
	
	return Plugin_Handled;
}

/**
 * Handles the zr_log_add_module command. Remove one or modules to module filter.
 *
 * @param client	The client that executed the command.
 * @param argc	  Number of arguments passed.
 */
public Action Command_LogRemoveModule(int client, int argc)
{
	char buffer[256];
	char argument[32];
	buffer[0] = 0;
	
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	LogModules logmodule;
	
	// Check if no arguments.
	if (argc < 1)
	{
		// Display syntax info.
		StrCat(buffer, sizeof(buffer), "Remove one or more modules to the module filter. Usage: zr_log_remove_module <module> [module] ...\n");
		StrCat(buffer, sizeof(buffer), "See zr_log_list to list available module names (short names).");
		ReplyToCommand(client, buffer);
	}
	
	// Loop through each argument.
	for (int arg = 1; arg <= argc; arg++)
	{
		// Get argument string.
		GetCmdArg(arg, argument, sizeof(argument));
		
		// Convert to module type.
		logmodule = LogGetModule(argument);
		
		// Check if invalid.
		if (logmodule == LogModule_Invalid)
		{
			ReplyToCommand(client, "Invalid module name: \"%s\"", argument);
			
			// Skip to next argument.
			continue;
		}
		
		LogModuleFilterRemove(logmodule);
		ReplyToCommand(client, "Removed \"%s\" from module filter.", argument);
	}
	
	// Update cache.
	LogModuleFilterCacheUpdate();
	
	return Plugin_Handled;
}
