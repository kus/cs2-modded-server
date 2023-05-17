/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  hitgroup.inc
 *  Type:		  Core
 *  Description:   API for loading hitgroup specific settings.
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

/**
 * Maximum length for a hitgroup name
 */
#define HITGROUPS_MAX_LENGTH 32

/**
 * @section Player hitgroup values.
 */
#define HITGROUP_GENERIC	0
#define HITGROUP_HEAD	   1
#define HITGROUP_CHEST	  2
#define HITGROUP_STOMACH	3
#define HITGROUP_LEFTARM	4
#define HITGROUP_RIGHTARM   5
#define HITGROUP_LEFTLEG	6
#define HITGROUP_RIGHTLEG   7
#define HITGROUP_GEAR	   10
/**
 * @endsection
 */

/**
 * Hitgroup config data indexes.
 */
enum HitgroupsData
{
	HITGROUPS_DATA_NAME = 0,
	HITGROUPS_DATA_INDEX,
	HITGROUPS_DATA_DAMAGE,
	HITGROUPS_DATA_KNOCKBACK,
}

/**
 * Array handle to store hitgroups data.
 */
Handle arrayHitgroups = INVALID_HANDLE;

/**
 * Create commands related to config here.
 */
void HitgroupsOnCommandsCreate()
{
	// Create config admin commands.
	RegConsoleCmd("zr_hitgroup", HitgroupsCommand, "Toggles or sets if a zombie's hitgroup can be damaged. Usage: zr_hitgroup <hitgroup name> [1/0]");
	RegConsoleCmd("zr_hitgroup_enable_all", HitgroupsEnableAllCommand, "Enables all zombie hitgroups to be damaged.  Usage: zr_hitgroup_enable_all");
	RegConsoleCmd("zr_hitgroup_headshots_only", HitgroupsHeadshotsOnlyCommand, "Disables all zombie hitgroups but the head.  Usage: zr_hitgroup_headshots_only");
}
	
/**
 * Loads hitgroup data from file.
 */ 
void HitgroupsLoad()
{
	// Register config file.
	ConfigRegisterConfig(File_Hitgroups, Structure_Keyvalue, CONFIG_FILE_ALIAS_HITGROUPS);
	
	// If module is disabled, then stop.
	bool hitgroups = GetConVarBool(g_hCvarsList[CVAR_HITGROUPS]);
	if (!hitgroups)
	{
		return;
	}
	
	// Get hitgroups config path.
	char pathhitgroups[PLATFORM_MAX_PATH];
	bool exists = ConfigGetCvarFilePath(CVAR_CONFIG_PATH_HITGROUPS, pathhitgroups);
	
	// If file doesn't exist, then log and stop.
	if (!exists)
	{
		// Log failure.
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Hitgroups, "Config Validation", "Missing hitgroups config file: %s", pathhitgroups);
		
		return;
	}
	
	// Set the path to the config file.
	ConfigSetConfigPath(File_Hitgroups, pathhitgroups);
	
	// Load config from file and create array structure.
	bool success = ConfigLoadConfig(File_Hitgroups, arrayHitgroups);
	
	// Unexpected error, stop plugin.
	if (!success)
	{
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Hitgroups, "Config Validation", "Unexpected error encountered loading: %s", pathhitgroups);
		
		return;
	}
	
	// Validate hitgroups config.
	int size = GetArraySize(arrayHitgroups);
	if (!size)
	{
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Hitgroups, "Config Validation", "No usable data found in hitgroups config file: %s", pathhitgroups);
	}
	
	// Now copy data to array structure.
	HitgroupsCacheData();
	
	// Set config data.
	ConfigSetConfigLoaded(File_Hitgroups, true);
	ConfigSetConfigReloadFunc(File_Hitgroups, GetFunctionByName(GetMyHandle(), "HitgroupsOnConfigReload"));
	ConfigSetConfigHandle(File_Hitgroups, arrayHitgroups);
}

/**
 * Caches hitgroup data from file into arrays.
 * Make sure the file is loaded before (ConfigLoadConfig) to prep array structure.
 */
void HitgroupsCacheData()
{
	// Get config's file path.
	char pathhitgroups[PLATFORM_MAX_PATH];
	ConfigGetConfigPath(File_Hitgroups, pathhitgroups, sizeof(pathhitgroups));
	
	Handle kvHitgroups;
	bool success = ConfigOpenConfigFile(File_Hitgroups, kvHitgroups);
	
	if (!success)
	{
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Hitgroups, "Config Validation", "Unexpected error caching data from hitgroups config file: %s", pathhitgroups);
	}
	
	char hitgroupname[HITGROUPS_MAX_LENGTH];
	
	// x = array index
	int size = GetArraySize(arrayHitgroups);
	for (int x = 0; x < size; x++)
	{
		HitgroupsGetName(x, hitgroupname, sizeof(hitgroupname));
		
		KvRewind(kvHitgroups);
		if (!KvJumpToKey(kvHitgroups, hitgroupname))
		{
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Hitgroups, "Config Validation", "Couldn't cache hitgroup data for: %s (check hitgroup config)", hitgroupname);
			continue;
		}
		
		// General
		int index = KvGetNum(kvHitgroups, "index", -1);
		
		// Damage
		bool damage = ConfigKvGetStringBool(kvHitgroups, "damage", "yes");
		
		// Knockback (module)
		float knockback = KvGetFloat(kvHitgroups, "knockback", 1.0);
		
		Handle arrayHitgroup = GetArrayCell(arrayHitgroups, x);
		
		// Push data into array.
		PushArrayCell(arrayHitgroup, index);		// Index: 1
		PushArrayCell(arrayHitgroup, damage);	   // Index: 2
		PushArrayCell(arrayHitgroup, knockback);	// Index: 3
	}
	
	// We're done with this file now, so we can close it.
	CloseHandle(kvHitgroups);
}

/**
 * Called when configs are being reloaded.
 * 
 * @param config	The config being reloaded. (only if 'all' is false)
 */
public void HitgroupsOnConfigReload(ConfigFile config)
{
	// Reload hitgroups config.
	HitgroupsLoad();
}

/**
 * Find the index at which the hitgroup's name is at.
 * 
 * @param hitgroup	  The higroup name.
 * @param maxlen		(Only if 'overwritename' is true) The max length of the hitgroup name. 
 * @param overwritename (Optional) If true, the hitgroup given will be overwritten with the name from the config.
 * @return		  The array index containing the given hitgroup name.
 */
stock int HitgroupsNameToIndex(char[] hitgroup, int maxlen = 0, bool overwritename = false)
{
	char hitgroupname[HITGROUPS_MAX_LENGTH];
	
	// x = Array index.
	int size = GetArraySize(arrayHitgroups);
	for (int x = 0; x < size; x++)
	{
		HitgroupsGetName(x, hitgroupname, sizeof(hitgroupname));
		
		// If names match, then return index.
		if (StrEqual(hitgroup, hitgroupname, false))
		{
			// If 'overwrite' name is true, then overwrite the old string with new.
			if (overwritename)
			{
				// Copy config name to return string.
				strcopy(hitgroup, maxlen, hitgroupname);
			}
			
			// Return this index.
			return x;
		}
	}
	
	// Name doesn't exist.
	return -1;
}

/**
 * Find the array index at which the hitgroup index is at.
 * 
 * @param hitgroup  The hitgroup index to search for.
 * @return		  The array index that contains the given hitgroup index.
 */
stock int HitgroupToIndex(int hitgroup)
{
	// x = Array index.
	int size = GetArraySize(arrayHitgroups);
	for (int x = 0; x < size; x++)
	{
		// Get hitgroup index at this array index.
		int index = HitgroupsGetIndex(x);
		
		// If hitgroup indexes match, then return array index.
		if (hitgroup == index)
		{
			return x;
		}
	}
	
	// Hitgroup index doesn't exist.
	return -1;
}

/**
 * Gets the name of a hitgroup at a given index. (static)
 * @param index	 The hitgroup index.
 * @param hitgroup  The string to return name in.
 * @param maxlen	The max length of the string.
 */
stock void HitgroupsGetName(int index, char[] hitgroup, int maxlen)
{
	// Get array handle of hitgroup at given index.
	Handle arrayHitgroup = GetArrayCell(arrayHitgroups, index);
	
	// Get hitgroup name.
	GetArrayString(arrayHitgroup, view_as<int>(HITGROUPS_DATA_NAME), hitgroup, maxlen);
}

/**
 * Retrieve hitgroup index. (static)
 * 
 * @param index	 The array index.
 * @return		  The hitgroup index.
 */
stock int HitgroupsGetIndex(int index)
{
	// Get array handle of hitgroup at given index.
	Handle arrayHitgroup = GetArrayCell(arrayHitgroups, index);
	
	// Return hitgroup index of the hitgroup.
	return GetArrayCell(arrayHitgroup, view_as<int>(HITGROUPS_DATA_INDEX));
}

/**
 * Set hitgroup damage value. (dynamic)
 * 
 * @param index	 The array index.
 * @param candamage True to allow damage to hitgroup, false to block damage.
 */
stock void HitgroupsSetDamage(int index, bool candamage)
{
	// Get array handle of hitgroup at given index.
	Handle arrayHitgroup = GetArrayCell(arrayHitgroups, index);
	
	// Return true if hitgroup can be damaged, false if not.
	SetArrayCell(arrayHitgroup, view_as<int>(HITGROUPS_DATA_DAMAGE), candamage);
}

/**
 * Retrieve hitgroup damage value. (dynamic)
 * 
 * @param index	 The array index.
 * @return		  True if hitgroup can be damaged, false if not.
 */
stock bool HitgroupsCanDamage(int index)
{
	// Get array handle of hitgroup at given index.
	Handle arrayHitgroup = GetArrayCell(arrayHitgroups, index);
	
	// Return true if hitgroup can be damaged, false if not.
	return view_as<bool>(GetArrayCell(arrayHitgroup, view_as<int>(HITGROUPS_DATA_DAMAGE)));
}

/**
 * Set hitgroup knockback value. (dynamic)
 * 
 * @param index	 The array index.
 * @param knockback The knockback multiplier for the hitgroup.
 */
stock void HitgroupsSetKnockback(int index, float knockback)
{
	// Get array handle of hitgroup at given index.
	Handle arrayHitgroup = GetArrayCell(arrayHitgroups, index);
	
	// Return the knockback multiplier for the hitgroup.
	SetArrayCell(arrayHitgroup, _:HITGROUPS_DATA_KNOCKBACK, knockback);
}

/**
 * Retrieve hitgroup knockback value. (dynamic)
 * 
 * @param index	 The array index.
 * @return		  The knockback multiplier of the hitgroup.
 */
stock float HitgroupsGetKnockback(int index)
{
	// Get array handle of hitgroup at given index.
	Handle arrayHitgroup = GetArrayCell(arrayHitgroups, index);
	
	// Return the knockback multiplier for the hitgroup.
	return view_as<float>(GetArrayCell(arrayHitgroup, view_as<int>(HITGROUPS_DATA_KNOCKBACK)));
}

/**
 * Sends list of hitgroups to client.
 *  
 * @param client	The client index.
 * @return		  True if sent successfully, false if not.
 */
bool HitgroupsMenuHitgroups(int client)
{
	// If hitgroups is disabled, then stop.
	bool hitgroups = GetConVarBool(g_hCvarsList[CVAR_HITGROUPS]);
	if (!hitgroups)
	{
		return false;
	}
	
	// Create menu handle.
	Handle menu_hitgroups = CreateMenu(HitgroupsMenuHitgroupsHandle);
	
	// Set client as translation target.
	SetGlobalTransTarget(client);
	
	char title[MENU_LINE_HUGE_LENGTH];
	char enableall[MENU_LINE_REG_LENGTH];
	char headshotsonly[MENU_LINE_REG_LENGTH];
	
	// Format menu options.
	Format(title, sizeof(title), "%t\n ", "Hitgroups menu hitgroups title");
	Format(enableall, sizeof(enableall), "%t", "Hitgroups menu hitgroups enable all");
	Format(headshotsonly, sizeof(headshotsonly), "%t\n ", "Hitgroups menu hitgroups headshots only");
	
	// Add options to menu.
	SetMenuTitle(menu_hitgroups, title);
	AddMenuItem(menu_hitgroups, "Enable All", enableall);
	AddMenuItem(menu_hitgroups, "Headshots Only", headshotsonly);
	
	char hitgroupoption[MENU_LINE_REG_LENGTH];
	char hitgroupcandamage[MENU_LINE_SMALL_LENGTH];
	char hitgroupid[4];
	
	// x = Hitgroup index.
	int size = GetArraySize(arrayHitgroups);
	for (int x = 0; x < size; x++)
	{
		// Get hitgroup name.
		HitgroupsGetName(x, hitgroupoption, sizeof(hitgroupoption));
		IntToString(x, hitgroupid, sizeof(hitgroupid));
		
		// Convert bool to "On/Off"
		ConfigBoolToSetting(HitgroupsCanDamage(x), hitgroupcandamage, sizeof(hitgroupcandamage), false, client);
		
		// Format "on/off" to the option.
		Format(hitgroupoption, sizeof(hitgroupoption), "%s: %s", hitgroupoption, hitgroupcandamage);
		
		// Add option to menu.
		AddMenuItem(menu_hitgroups, hitgroupid, hitgroupoption);
	}
	
	// Create a "Back" button to the main admin menu.
	SetMenuExitBackButton(menu_hitgroups, true);
	
	// Send menu.
	DisplayMenu(menu_hitgroups, client, MENU_TIME_FOREVER);
	
	return true;
}

/**
 * Called when client selects option in the infect clients menu, and handles it.
 * @param menu_hitgroups		Handle of the menu being used.
 * @param action				The action done on the menu (see menus.inc, enum MenuAction).
 * @param client				The client index.
 * @param slot				  The slot index selected (starting from 0).
 */ 
public int HitgroupsMenuHitgroupsHandle(Handle menu_hitgroups, MenuAction action, int client, int slot)
{
	// Client selected an option.
	if (action == MenuAction_Select)
	{
		switch(slot)
		{
			// Enable all hitgroups.
			case 0:
			{
				// x = Hitgroup index.
				int size = GetArraySize(arrayHitgroups);
				for (int x = 0; x < size; x++)
				{
					// Enable hitgroup.
					HitgroupsSetDamage(x, true);
				}
				
				// Tell the server that all hitgroups have been enabled.
				TranslationPrintToChatAll(true, false, "Hitgroups command enable all successful");
			}
			// Headshots only.
			case 1:
			{
				// x = Hitgroup index.
				int size = GetArraySize(arrayHitgroups);
				for (int x = 0; x < size; x++)
				{
					if (HitgroupsGetIndex(x) == HITGROUP_HEAD)
					{
						// Enable hitgroup.
						HitgroupsSetDamage(x, true);
						
						continue;
					}
					
					// Disable hitgroup.
					HitgroupsSetDamage(x, false);
				}
				
				// Tell the server that headshots only been enabled.
				TranslationPrintToChatAll(true, false, "Hitgroups command headshots only successful");
			}
			default:
			{
				// Get selected hitgroup index.
				char hitgroupid[4];
				GetMenuItem(menu_hitgroups, slot, hitgroupid, sizeof(hitgroupid));
				int hitgroup = StringToInt(hitgroupid);
				
				// Toggle value.
				bool hitgroupcandamage = HitgroupsCanDamage(hitgroup);
				HitgroupsSetDamage(hitgroup, !hitgroupcandamage);
			}
		}
		
		// Re-send menu.
		HitgroupsMenuHitgroups(client);
	}
	// Client closed the menu.
	if (action == MenuAction_Cancel)
	{
		// Client hit "Back" button.
		if (slot == MenuCancel_ExitBack)
		{
			// Re-open admin menu.
			ZAdminMenu(client);
		}
	}
	// Client hit "Exit" button.
	else if (action == MenuAction_End)
	{
		CloseHandle(menu_hitgroups);
	}
}

/**
 * Command callback (zr_hitgroup)
 * Toggles or sets if a zombie's hitgroup can be damaged.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action HitgroupsCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// If module is disabled, then stop.
	bool hitgroups = GetConVarBool(g_hCvarsList[CVAR_HITGROUPS]);
	if (!hitgroups)
	{
		TranslationReplyToCommand(client, "Feature is disabled");
		return Plugin_Handled;
	}
	
	// If not enough arguments given, then stop.
	if (argc < 1)
	{
		TranslationReplyToCommand(client, "Hitgroups command syntax");
		TranslationReplyToCommand(client, "Hitgroups command related commands");
		TranslationPrintToConsole(client, "Hitgroups command syntax names");
		
		// Print all the hitgroup names in the client's console.
		char hitgroupname[HITGROUPS_MAX_LENGTH];
		
		// x = Hitgroup index.
		int size = GetArraySize(arrayHitgroups);
		for (int x = 0; x < size; x++)
		{
			// Get the hitgroups name and print in console.
			HitgroupsGetName(x, hitgroupname, sizeof(hitgroupname));
			PrintToConsole(client, "* %s", hitgroupname);
		}
		
		return Plugin_Handled;
	}
	
	// Get hitgroup alias given.
	char target[HITGROUPS_MAX_LENGTH];
	GetCmdArg(1, target, sizeof(target));
	
	// If the hitgroup is invalid, then stop and tell client.
	int hitgroup = HitgroupsNameToIndex(target, sizeof(target), true);
	if (hitgroup == -1)
	{
		TranslationReplyToCommand(client, "Hitgroups command invalid hitgroup", target);
		return Plugin_Handled;
	}
	
	bool hitgroupdamage;
	
	// Check if value was given
	char value[4];
	GetCmdArg(2, value, sizeof(value));
	if (!value[0])
	{
		// Get the opposite value of the current hitgroup value.
		hitgroupdamage = !HitgroupsCanDamage(hitgroup);
	}
	else
	{
		// Cast the given value to a bool.
		hitgroupdamage = view_as<bool>(StringToInt(value));
	}
	
	// Set new value in the hitgroup data cache.
	HitgroupsSetDamage(hitgroup, hitgroupdamage);
	
	// Tell client the new value of the hitgroup.
	if (hitgroupdamage)
	{
		TranslationReplyToCommand(client, "Hitgroups command successful on", target);
	}
	else
	{
		TranslationReplyToCommand(client, "Hitgroups command successful off", target);
	}
	
	// Log action to game events.
	LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Hitgroups, "Headshots Toggle", "Admin \"%L\" toggled hitgroup \"%s\" to \"%d\". (zr_hitgroup)", client, target, hitgroupdamage);
	
	return Plugin_Handled;
}

/**
 * Command callback (zr_hitgroup_enable_all)
 * Enables all zombie hitgroups to be damaged.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action HitgroupsEnableAllCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// If module is disabled, then stop.
	bool hitgroups = GetConVarBool(g_hCvarsList[CVAR_HITGROUPS]);
	if (!hitgroups)
	{
		TranslationReplyToCommand(client, "Feature is disabled");
		return Plugin_Handled;
	}
	
	// x = Hitgroup index.
	int size = GetArraySize(arrayHitgroups);
	for (int x = 0; x < size; x++)
	{
		// Set that hitgroup index to true for damage.
		HitgroupsSetDamage(x, true);
	}
	
	// Tell the server that all hitgroups have been enabled.
	TranslationPrintToChatAll(true, false, "Hitgroups command enable all successful");
	
	// Log action to game events.
	LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Hitgroups, "Enable All", "Admin \"%L\" enabled all zombie hitgroups. (zr_hitgroup_enable_all)", client);
	
	return Plugin_Handled;
}

/**
 * Command callback (zr_hitgroup_enable_all)
 * Disables all zombie hitgroups but the head.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action HitgroupsHeadshotsOnlyCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// If module is disabled, then stop.
	bool hitgroups = GetConVarBool(g_hCvarsList[CVAR_HITGROUPS]);
	if (!hitgroups)
	{
		TranslationReplyToCommand(client, "Feature is disabled");
		return Plugin_Handled;
	}
	
	// x = Hitgroup index.
	int size = GetArraySize(arrayHitgroups);
	for (int x = 0; x < size; x++)
	{
		// If this hitgroup is the head, then enable it and stop.
		if (HitgroupsGetIndex(x) == HITGROUP_HEAD)
		{
			HitgroupsSetDamage(x, true);
			continue;
		}
		
		// Set that hitgroup index to true for damage.
		HitgroupsSetDamage(x, false);
	}
	
	// Tell the server that headshots only been enabled.
	TranslationPrintToChatAll(true, false, "Hitgroups command headshots only successful");
	
	// Log action to game events.
	LogEvent(false, LogType_Normal, LOG_GAME_EVENTS, LogModule_Hitgroups, "Headshots Only", "Admin \"%L\" enabled headshots only. (zr_hitgroup_headshots_only)", client);
	
	return Plugin_Handled;
}
