/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  downloads.inc
 *  Type:		  Core
 *  Description:   Download validation.
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
 * Array that stores a list of downloadable files.
 */
Handle arrayDownloads = INVALID_HANDLE;

/**
 * Prepare all model/download data.
 */
void DownloadsLoad()
{
	// Register config file.
	ConfigRegisterConfig(File_Downloads, Structure_List, CONFIG_FILE_ALIAS_DOWNLOADS);
	
	// Get downloads file path.
	char pathdownloads[PLATFORM_MAX_PATH];
	bool exists = ConfigGetCvarFilePath(CVAR_CONFIG_PATH_DOWNLOADS, pathdownloads);
	
	// If file doesn't exist, then log and stop.
	if (!exists)
	{
		// Log failure and stop plugin.
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Downloads, "Config Validation", "Missing downloads file: \"%s\"", pathdownloads);
	}
	
	// Set the path to the config file.
	ConfigSetConfigPath(File_Downloads, pathdownloads);
	
	// Load config from file and create array structure.
	bool success = ConfigLoadConfig(File_Downloads, arrayDownloads, PLATFORM_MAX_PATH);
	
	// Unexpected error, stop plugin.
	if (!success)
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Downloads, "Config Validation", "Unexpected error encountered loading: %s", pathdownloads);
	}
	
	int downloadcount;
	int downloadvalidcount;
	
	char downloadpath[PLATFORM_MAX_PATH];
	
	int downloads = downloadcount = GetArraySize(arrayDownloads);
	
	// x = download array index.
	for (int x = 0; x < downloads; x++)
	{
		// Get download path
		GetArrayString(arrayDownloads, x, downloadpath, sizeof(downloadpath));
		
		// If file doesn't exist, then remove, log, and stop.
		if (!FileExists(downloadpath, true))
		{
			// Remove client from array.
			RemoveFromArray(arrayDownloads, x);
			
			// Subtract one from count.
			downloads--;
			
			// Backtrack one index, because we deleted it out from under the loop.
			x--;
			
			LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Downloads, "Config Validation", "Missing file \"%s\"", downloadpath);
			continue;
		}
		
		// Increment downloadvalidcount
		downloadvalidcount++;
		
		// Precache model file and add to downloads table.
		AddFileToDownloadsTable(downloadpath);
	}
	
	// Log model validation info.
	LogEvent(false, LogType_Normal, LOG_CORE_EVENTS, LogModule_Downloads, "Config Validation", "Total: %d | Successful: %d | Unsuccessful: %d", downloadcount, downloadvalidcount, downloadcount - downloadvalidcount);
	
	// Set config data.
	ConfigSetConfigLoaded(File_Downloads, true);
	ConfigSetConfigReloadFunc(File_Downloads, GetFunctionByName(GetMyHandle(), "DownloadsOnConfigReload"));
	ConfigSetConfigHandle(File_Downloads, arrayDownloads);

	// zombie_walking_csgo Svg
	if(g_Game == Game_CSGO) AddFileToDownloadsTable("materials/panorama/images/icons/equipment/zombie_walking_csgo.svg");
}

/**
 * Called when configs are being reloaded.
 * 
 * @param config	The config being reloaded. (only if 'all' is false)
 */
public void DownloadsOnConfigReload(ConfigFile config)
{
	// Reload download config.
	DownloadsLoad();
}
