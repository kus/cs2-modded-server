/*
 * MyStocks - include file - function libary.
 * by: shanapu
 * https://github.com/shanapu/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Hexer10
 *
 * Version 13.0
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

#if defined _mystocks_included_
	#endinput
#endif
#define _mystocks_included_


/******************************************************************************
                   STOCKS
******************************************************************************/


// Check for valid clients with bool for bots & dead player 
stock bool IsValidClient(int client, bool bots = true, bool dead = true)
{
	if (client <= 0)
		return false;

	if (client > MaxClients)
		return false;

	if (!IsClientInGame(client))
		return false;

	if (IsFakeClient(client) && !bots)
		return false;

	if (IsClientSourceTV(client))
		return false;

	if (IsClientReplay(client))
		return false;

	if (!IsPlayerAlive(client) && !dead)
		return false;

	return true;
}


// Easy precache & prepare download for decals
stock void PrecacheDecalAnyDownload(char[] path)
{
	if (strlen(path) == 0)
		return;

	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "%s.vmt", path);
	PrecacheDecal(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", path);
	AddFileToDownloadsTable(sBuffer);

	Format(sBuffer, sizeof(sBuffer), "%s.vtf", path);
	PrecacheDecal(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", path);
	AddFileToDownloadsTable(sBuffer);
}


// Easy precache & prepare download for models (icons)
stock void PrecacheModelAnyDownload(char[] path)
{
	if (strlen(path) == 0)
		return;

	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", path);
	AddFileToDownloadsTable(sBuffer);
	PrecacheModel(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", path);
	AddFileToDownloadsTable(sBuffer);
	PrecacheModel(sBuffer, true);
}


// Easy precache & prepare download for sounds
stock void PrecacheSoundAnyDownload(char[] path)
{
	if (strlen(path) == 0)
		return;

	char sBuffer[256];
	PrecacheSoundAny(path);
	Format(sBuffer, sizeof(sBuffer), "sound/%s", path);
	AddFileToDownloadsTable(sBuffer);
}


// Strip All Weapons & the knife slot twice for taser
stock void StripAllPlayerWeapons(int client)
{
	int weapon;

	for (int i = 0; i <= 4; i++)
	{
		if ((weapon = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
		}
	}

	if ((weapon = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE)) != -1)   // strip knife slot 2 times for taser
	{
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}
}


// Show overlay to a client with lifetime | 0.0 = no auto remove
stock void ShowOverlay(int client, char[] path, float lifetime)
{
	if (!IsValidClient(client))
		return;

	ClientCommand(client, "r_screenoverlay \"%s.vtf\"", path);

	if (lifetime != 0.0)
	{
		CreateTimer(lifetime, DeleteOverlay, GetClientUserId(client));
	}
}


// Show overlay to all clients with lifetime | 0.0 = no auto remove
stock void ShowOverlayAll(char[] path, float lifetime)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

		ClientCommand(i, "r_screenoverlay \"%s.vtf\"", path);

		if (lifetime != 0.0)
		{
			CreateTimer(lifetime, DeleteOverlay, GetClientUserId(i));
		}
	}
}


// Remove overlay from a client
stock Action DeleteOverlay(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (!IsValidClient(client))
		return Plugin_Handled;

	ClientCommand(client, "r_screenoverlay \"\"");

	return Plugin_Handled;
}


// Easy silent change of ConVars - Boolean
stock void SetCvar(char[] cvar, int value)
{
	Handle hCvar = FindConVar(cvar);
	if (hCvar == null)
		return;

	int flags = GetConVarFlags(hCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(hCvar, flags);

	SetConVarInt(hCvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(hCvar, flags);
}


// Easy silent change of ConVars - Floats
stock void SetCvarFloat(char[] cvar, float value)
{
	Handle hCvar = FindConVar(cvar);
	if (hCvar == null)
		return;

	new flags = GetConVarFlags(hCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(hCvar, flags);

	SetConVarFloat(hCvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(hCvar, flags);
}


// Easy silent change of ConVars - Strings
stock void SetCvarString(char[] cvar, char[] value)
{
	Handle hCvar = FindConVar(cvar);
	SetConVarString(hCvar, value, true);
}


// Define filename & path for logging 
stock void SetLogFile(char path[PLATFORM_MAX_PATH], char[] file, char[] folder)
{
	char sDate[12];
	FormatTime(sDate, sizeof(sDate), "%y-%m-%d");
	Format(path, sizeof(path), "logs/%s/%s-%s.log", folder, file, sDate);

	BuildPath(Path_SM, path, sizeof(path), path);
}


// Set the players Ammo for active weapon
stock void SetPlayerAmmo(int client, int weapon, int clip = -1, int ammo = -1)
{
	if (weapon == INVALID_ENT_REFERENCE)
		return;

	if (clip != -1)
	{
		SetEntProp(weapon, Prop_Data, "m_iClip1", clip);
	}

	if (ammo != -1)
	{
		SetEntProp(weapon, Prop_Data, "m_iPrimaryReserveAmmoCount", ammo);
		SetEntProp(weapon, Prop_Data, "m_iSecondaryReserveAmmoCount", ammo);
	}
}



stock void EnableWeaponFire(int client, bool status = true) // rename EnableWeaponFire
{
	if (status) // true = allow shooting
	{
		SDKUnhook(client, SDKHook_PreThink, Stock_PreThinkWeapon);
	}
	else // false = suppress shooting
	{
		SDKHook(client, SDKHook_PreThink, Stock_PreThinkWeapon);
	}
}


stock Action Stock_PreThinkWeapon(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (weapon < 0 || !IsValidEdict(weapon) || !IsValidEntity(weapon))
		return Plugin_Continue;

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.25);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 0.25);

	return Plugin_Continue;
}


// Remove a players render color
stock Action Timer_RemoveColor(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (!IsValidClient(client, true))
		return Plugin_Handled;

	SetEntityRenderColor(client, 255, 255, 255, 255);

	return Plugin_Handled;
}


// Get random alive & non-rebeling player of a team (need lastrequest.inc)
stock int GetRandomPlayerNonRebel(int team)
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

		if (!IsClientRebel(i))  // bool in function
			continue;

		clients[clientCount++] = i;
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

// Get random alive player
stock int GetRandomPlayer(int team)   // bool in function for rebel instead GetRandomPlayerNonRebel
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

		if (GetClientTeam(i) != team)
			continue;

		clients[clientCount++] = i;
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}


//new
stock int GetRandomsPlayer(bool alive = true)
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, !alive))
			continue;

		clients[clientCount++] = i;
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

//old
stock int GetRandomAlivePlayer()
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, _, true))
			continue;

		clients[clientCount++] = i;
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

// NEW
stock int GetPlayerCount(bool alive = false, int team = -1)
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, !alive))
			continue;

		if (team != -1 && GetClientTeam(i) != team)
			continue;

		iCount++;
	}

	return iCount;
}

//old
// Get all player count of a team
stock int GetTeamPlayersCount(int team)
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
		if (IsValidClient(i, true, true) && GetClientTeam(i) == team)
		iCount++;

	return iCount;
}


// Get alive player count of a team
//old
stock int GetAlivePlayersCount(int team)
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, false))
			continue;

		if (GetClientTeam(i) != team)
			continue;

		iCount++;
	}

	return iCount;
}


// Get alive & non-rebeling player count of a team (need lastrequest.inc) MERGE WOITH GetAlivePlayersCount 
stock int GetAlivePlayersCountNonRebel(int team)
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, false))
			continue;

		if (GetClientTeam(i) != team)
			continue;

		if (!IsClientRebel(i))  // bool in function  
			continue;

		iCount++;
	}

	return iCount;
}


//old
// Get all player count of a team
stock int GetAllPlayersCount()
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
		if (IsValidClient(i, true, true))
		iCount++;

	return iCount;
}


//MERGE TO ONE FUNTION

// Get a alive random player of all teams



// Get last alive player of a team
stock int GetLastAlive(int team)
{
	int clientCount = 0;
	int client;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, false))
			continue;

		if (GetClientTeam(i) != team)
			continue;

		clientCount++;
		client = i;
	}

	return (clientCount > 1) ? -1 : client;
}


// Get a player for a certain admin flag
stock bool CheckVipFlag(int client, char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;

	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));

	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i]) == ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}

	return bEntitled;
}


// Menu Handler for Panels
stock int Handler_NullCancel(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			default: // cancel
			{
				return;
			}
		}
	}

	return;
}

stock void StringToUpper(char[] string)
{
	int len = strlen(string);

	for (int i = 0; i < len; i++)
	{
		if (IsCharLower(string[i]))
		{
			string[i] = CharToUpper(string[i]);
		}
	}
}

stock bool IsClientStuck(int client)
{
	float vOrigin[3], vMins[3], vMaxs[3];

	GetClientAbsOrigin(client, vOrigin);

	GetEntPropVector(client, Prop_Send, "m_vecMins", vMins);
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", vMaxs);

	TR_TraceHullFilter(vOrigin, vOrigin, vMins, vMaxs, MASK_ALL, FilterOnlyPlayers, client);

	return TR_DidHit();
}

stock bool FilterOnlyPlayers(int entity, int mask, any data)
{
	if(entity != data && entity > 0 && entity <= MaxClients) 
		return true;
	
	return false;
}

stock void DarkenScreen(int client, bool dark)
{
	Handle hFadeClient = StartMessageOne("Fade", client);
	PbSetInt(hFadeClient, "duration", 1);
	PbSetInt(hFadeClient, "hold_time", 3);
	if(!dark)
	{
		PbSetInt(hFadeClient, "flags", 0x0010); // FFADE_STAYOUT	0x0008		ignores the duration, stays faded out until new ScreenFade message received
	}
	else
	{
		PbSetInt(hFadeClient, "flags", 0x0008); // FFADE_PURGE		0x0010		Purges all other fades, replacing them with this one
	}
	PbSetColor(hFadeClient, "clr", {0, 0, 0, 255});
	EndMessage();
}

stock int GetRandomPlayerInView(int team, int client)
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, false))
			continue;

		if (GetClientTeam(i) != team)
			continue;

		if (!ClientViews(i, i))
			continue;

		clients[clientCount++] = i;
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

stock bool ClientViews(int viewer, int target, float fMaxDistance=0.0, float fThreshold=0.73)
{
	// Retrieve view and target eyes position
	float fViewPos[3];  GetClientEyePosition(viewer, fViewPos);
	float fViewAng[3];  GetClientEyeAngles(viewer, fViewAng);
	float fViewDir[3];
	float fTargetPos[3];GetClientEyePosition(target, fTargetPos);
	float fTargetDir[3];
	float fDistance[3];

	// Calculate view direction
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);

	// Calculate distance to viewer to see if it can be seen.
	fDistance[0] = fTargetPos[0]-fViewPos[0];
	fDistance[1] = fTargetPos[1]-fViewPos[1];
	fDistance[2] = 0.0;
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
			return false;
	}

	// Check dot product. If it's negative, that means the viewer is facing
	// backwards to the target.
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) < fThreshold)
		return false;

	// Now check if there are no obstacles in between through raycasting
	Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
	if (TR_DidHit(hTrace))
	{
		CloseHandle(hTrace);return false;
	}
	CloseHandle(hTrace);

	// Done, it's visible
	return true;
}

stock bool ClientViewsFilter(int entity, int mask, any junk)
{
	if (entity >= 1 && entity <= MaxClients) 
		return false;

	return true;
}

stock bool DirExistsEx(const char[] path)
{
	if (!DirExists(path))
	{
		CreateDirectory(path, 511);

		if (!DirExists(path))
		{
			LogError("Couldn't create folder! (%s)", path);
			return false;
		}
	}

	return true;
}

stock void DisablePlugin(char[] plugin)
{
	char sPath[64];
	BuildPath(Path_SM, sPath, sizeof(sPath), "plugins/%s.smx", plugin);

	if (!FileExists(sPath))
		return;

	char sNewPath[64];
	BuildPath(Path_SM, sNewPath, sizeof(sNewPath), "plugins/disabled/%s.smx", plugin);
	ServerCommand("sm plugins unload %s", plugin);
	if (FileExists(sNewPath))
	{
		DeleteFile(sNewPath);
	}
	RenameFile(sNewFile, sPath);
	LogMessage("%s was unloaded and moved to %s to avoid conflicts", sPath, sNewPath);
}