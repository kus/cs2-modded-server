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

ArrayList g_aHumansSoundsArray;
ArrayList g_aZombisSoundsArray;

void DownloadsInit()
{
	g_aHumansSoundsArray = new ArrayList(512);
	g_aZombisSoundsArray = new ArrayList(512);
}

/**
 * Prepare all sounds data.
 */
void DownloadsLoadPreCached()
{
	ContDownSoundsLoad();
	ZombiesSoundsLoad();
	RoundEndSoundsLoad();
	AmbientSoundsLoad();
}

/**
 * Loads downloadable content data for Contdown module.
 */
void ContDownSoundsLoad()
{
	// If contdown sound is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_COUNTDOWN_SOUNDS)
	{
		return;
	}

	// Get infection sound.
	char ContMamPath[PLATFORM_MAX_PATH];
	char ContWomPath[PLATFORM_MAX_PATH];

	// Prepend sound/ to the path.
	Format(ContMamPath, sizeof(ContMamPath), "sound/%s", g_hCvarsList.g_sCVAR_COUNTDOWN_MAM_PATH);
	Format(ContWomPath, sizeof(ContWomPath), "sound/%s", g_hCvarsList.g_sCVAR_COUNTDOWN_WOMAN_PATH);

	
	char s_SoundsFile[64], s_PreCachePath[PLATFORM_MAX_PATH];

	FileType f_SoundsFileType;
	Handle h_MamSoundsDir = OpenDirectory(ContMamPath);

	if (h_MamSoundsDir != INVALID_HANDLE)
	{
		while(ReadDirEntry(h_MamSoundsDir, s_SoundsFile, sizeof(s_SoundsFile), f_SoundsFileType))     
		{
			if(f_SoundsFileType == FileType_File)
			{
				Format(s_PreCachePath, sizeof(s_PreCachePath), "%s%s", ContMamPath, s_SoundsFile);

				// Add sound file to downloads table.
				AddFileToDownloadsTable(s_PreCachePath);

				//Precache Sound
				ReplaceString(s_PreCachePath, sizeof(s_PreCachePath), "sound/", "");

				PrecacheSound(s_PreCachePath);
			}
		}
	}
	else if(h_MamSoundsDir == INVALID_HANDLE)
	{
		//LogError("Invalid Folder %s", ContMamPath);
	}
	CloseHandle(h_MamSoundsDir);

	Handle h_WomSoundsDir = OpenDirectory(ContWomPath);

	if (h_WomSoundsDir != INVALID_HANDLE)
	{
		while(ReadDirEntry(h_WomSoundsDir, s_SoundsFile, sizeof(s_SoundsFile), f_SoundsFileType))     
		{
			if(f_SoundsFileType == FileType_File)
			{
				Format(s_PreCachePath, sizeof(s_PreCachePath), "%s%s", ContWomPath, s_SoundsFile);

				// Add sound file to downloads table.
				AddFileToDownloadsTable(s_PreCachePath);

				//Precache Sound
				ReplaceString(s_PreCachePath, sizeof(s_PreCachePath), "sound/", "");

				PrecacheSound(s_PreCachePath);
			}
		}
	}
	else if (h_WomSoundsDir == INVALID_HANDLE)
	{
		//LogError("Invalid Folder %s", ContWomPath);
	}
	CloseHandle(h_WomSoundsDir);
}

/**
 * Loads downloadable content data for Infect module.
 */
void ZombiesSoundsLoad()
{
	// If zombies sound is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_ZOMBIES_SOUNDS)
	{
		return;
	}

	// Get round end sound.
	char ZombiesSoundsPath[PLATFORM_MAX_PATH];

	// Prepend sound/ to the path.
	Format(ZombiesSoundsPath, sizeof(ZombiesSoundsPath), "sound/%s", g_hCvarsList.g_sCVAR_ZOMBIES_SOUNDS_FILES);

	char s_SoundsFile[64], s_PreCachePath[PLATFORM_MAX_PATH];

	FileType f_SoundsFileType;
	Handle h_SoundsDir = OpenDirectory(ZombiesSoundsPath);


	if (h_SoundsDir != INVALID_HANDLE)
	{
		while(ReadDirEntry(h_SoundsDir, s_SoundsFile, sizeof(s_SoundsFile), f_SoundsFileType))     
		{
			if(f_SoundsFileType == FileType_File)
			{
				Format(s_PreCachePath, sizeof(s_PreCachePath), "%s%s", ZombiesSoundsPath, s_SoundsFile);

				// Add sound file to downloads table.
				AddFileToDownloadsTable(s_PreCachePath);

				//Precache Sound
				ReplaceString(s_PreCachePath, sizeof(s_PreCachePath), "sound/", "");

				PrecacheSound(s_PreCachePath);
			}
		}
	}
	else if (h_SoundsDir == INVALID_HANDLE)
	{
		//LogError("Invalid Folder %s", ZombiesSoundsPath);
	}
	CloseHandle(h_SoundsDir);
}

/**
 * Loads downloadable content data for RoundEnd module.
 */
void RoundEndSoundsLoad()
{
	// If contdown sound is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_COUNTDOWN_SOUNDS)
	{
		return;
	}
	
	g_aHumansSoundsArray.Clear();
	g_aZombisSoundsArray.Clear();

	// Get round end sound.
	char HumansWinPath[PLATFORM_MAX_PATH];
	char ZombieWinPath[PLATFORM_MAX_PATH];

	// Prepend sound/ to the path.
	Format(HumansWinPath, sizeof(HumansWinPath), "sound/%s", g_hCvarsList.g_sCVAR_ROUNDEND_HUMANS_WIN);
	Format(ZombieWinPath, sizeof(ZombieWinPath), "sound/%s", g_hCvarsList.g_sCVAR_ROUNDEND_ZOMBIE_WIN);

	
	char s_SoundsFile[64], s_PreCachePath[PLATFORM_MAX_PATH];

	FileType f_SoundsFileType;
	Handle h_HumSoundsDir = OpenDirectory(HumansWinPath);

	if (h_HumSoundsDir != INVALID_HANDLE)
	{
		while(ReadDirEntry(h_HumSoundsDir, s_SoundsFile, sizeof(s_SoundsFile), f_SoundsFileType))     
		{
			if(f_SoundsFileType == FileType_File)
			{
				Format(s_PreCachePath, sizeof(s_PreCachePath), "%s%s", HumansWinPath, s_SoundsFile);

				// Add sound file to downloads table.
				AddFileToDownloadsTable(s_PreCachePath);

				//Precache Sound
				ReplaceString(s_PreCachePath, sizeof(s_PreCachePath), "sound/", "");

				PrecacheSound(s_PreCachePath);
				g_aHumansSoundsArray.PushString(s_PreCachePath);
			}
		}
	}
	else if (h_HumSoundsDir == INVALID_HANDLE)
	{
		//LogError("Invalid Folder %s", HumansWinPath);
	}
	CloseHandle(h_HumSoundsDir);

	Handle h_ZmSoundsDir = OpenDirectory(ZombieWinPath);

	if (h_ZmSoundsDir != INVALID_HANDLE)
	{
		while(ReadDirEntry(h_ZmSoundsDir, s_SoundsFile, sizeof(s_SoundsFile), f_SoundsFileType))     
		{
			if(f_SoundsFileType == FileType_File)
			{
				Format(s_PreCachePath, sizeof(s_PreCachePath), "%s%s", ZombieWinPath, s_SoundsFile);

				// Add sound file to downloads table.
				AddFileToDownloadsTable(s_PreCachePath);

				//Precache Sound
				ReplaceString(s_PreCachePath, sizeof(s_PreCachePath), "sound/", "");

				PrecacheSound(s_PreCachePath);
				g_aZombisSoundsArray.PushString(s_PreCachePath);
			}
		}
	}
	else if (h_ZmSoundsDir == INVALID_HANDLE)
	{
		//LogError("Invalid Folder %s", ZombieWinPath);
	}
	CloseHandle(h_ZmSoundsDir);
}

/**
 * Loads downloadable content data for AmbientSounds module.
 */
void AmbientSoundsLoad()
{
	// If ambience is disabled, then stop.
	if (!g_hCvarsList.g_bCVAR_AMBIENTSOUNDS)
	{
		return;
	}
	
	// Get ambient sound file.
	char sound[PLATFORM_MAX_PATH];
	Format(sound, sizeof(sound), "sound/%s", g_hCvarsList.g_sCVAR_AMBIENTSOUNDS_FILE);
	
	// If file doesn't exist, then log error and stop.
	if (!FileExists(sound, true))
	{
		//LogError("Invalid File %s", sound);
		return;
	}

	// Add sound file to downloads table.
	AddFileToDownloadsTable(sound);

	//Precache Sound
	ReplaceString(sound, sizeof(sound), "sound/", "");
	//Precache Sound
	PrecacheSound(sound);
}