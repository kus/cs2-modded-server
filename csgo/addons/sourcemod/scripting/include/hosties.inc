/*
 * SourceMod Hosties Project
 * by: databomb & dataviruset
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Double include protection
#if defined _Hosties_Included_
	#endinput
#endif
#define _Hosties_Included_

// Change to include your own clan tag but leave the '%t' intact
#define 	CHAT_BANNER			"\x03[SM] \x04%t"
#define 	NORMAL_VISION			90
#define		INVALID_WEAPON			-1

enum GameType
{
	Game_Unknown = -1,
	Game_CSS,
	Game_CSGO
};

enum FreekillPunishment
{
	FP_Slay = 0,
	FP_Kick,
	FP_Ban
};

enum MediaType
{
	type_Generic = 0,
	type_Sound,
	type_Material,
	type_Model,
	type_Decal
};

stock void ShowOverlayToClient(int client, const  char[] overlaypath)
{
	ClientCommand(client, "r_screenoverlay \"%s\"", overlaypath);
}

stock void ShowOverlayToAll(const char[] overlaypath)
{
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (IsClientInGame(x) && !IsFakeClient(x))
		{
			ShowOverlayToClient(x, overlaypath);
		}
	}
}

stock void StripAllWeapons(int client)
{
	int iWeaponIndex = INVALID_WEAPON;
	for (int i = CS_SLOT_PRIMARY; i < CS_SLOT_GRENADE+1; i++)
	{
		iWeaponIndex = INVALID_WEAPON;
		while ((iWeaponIndex = GetPlayerWeaponSlot(client, i)) != INVALID_WEAPON)
		{
			RemovePlayerItem(client, iWeaponIndex);
			AcceptEntityInput(iWeaponIndex, "Kill");
		}
	}
}

stock void BlockEntity(int client, int cachedOffset)
{
	SetEntData(client, cachedOffset, 5, 4, true);
}

stock void UnblockEntity(int client, int cachedOffset)
{
	SetEntData(client, cachedOffset, 2, 4, true);
}

stock void BlockClientAll()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsClientInGame(i) && IsPlayerAlive(i) )
		{
			BlockEntity(i);
		}
	}
}

stock void UnblockClientAll()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsClientInGame(i) && IsPlayerAlive(i) )
		{
			UnblockEntity(i);
		}
	}
}

stock void MutePlayer(int client)
{
	SetClientListeningFlags(client, VOICE_MUTED);
}

stock void UnmutePlayer(int client)
{
	SetClientListeningFlags(client, VOICE_NORMAL);
}

stock void CacheTheFile(const char[] path, MediaType filetype)
{
	char sDownloadPath[PLATFORM_MAX_PATH];
	switch (filetype)
	{
		case type_Sound:
		{
			PrecacheSoundAny(path, true);
			Format(sDownloadPath, PLATFORM_MAX_PATH, "sound/%s", path);
			AddFileToDownloadsTable(sDownloadPath);
		}
		case type_Decal, type_Material:
		{
			PrecacheDecal(path, true);
			Format(sDownloadPath, PLATFORM_MAX_PATH, "materials/%s", path);
			AddFileToDownloadsTable(sDownloadPath);
		}
		case type_Model:
		{
			PrecacheModel(path, true);
			Format(sDownloadPath, PLATFORM_MAX_PATH, "models/%s", path);
			AddFileToDownloadsTable(sDownloadPath);
		}
		default:
		{
			PrecacheGeneric(path, true);
			AddFileToDownloadsTable(path);			
		}
	}
}
