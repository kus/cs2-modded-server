#if defined _teamgames_stocks_included_
  #endinput
#endif
#define _teamgames_stocks_included_

#include <cstrike>
#include <sdktools>

/**
 * Returns wheter players are enemies within given game type.
 * If there is not game type passed, game type of current game is taken.
 *
 * @param client1		First player
 * @param client2		Second player
 * @return				True if given players are enemies
 */
stock bool:TG_AreEnemies(client1, client2, TG_GameType:gameType = TG_None)
{
	new TG_Team:team1 = TG_GetPlayerTeam(client1);
	new TG_Team:team2 = TG_GetPlayerTeam(client2);

	return TG_AreTeamsEnemies(team1, team2, gameType);
}

/**
 * Returns wheter teams are enemies within given game type.
 * If there is not game type passed, game type of current game is taken.
 *
 * @param team1			First team
 * @param team2			Second team
 * @return				True if given team are enemies
 */
stock bool:TG_AreTeamsEnemies(TG_Team:team1, TG_Team:team2, TG_GameType:gameType = TG_None)
{
	if (gameType == TG_None)
		gameType = TG_GetCurrentGameType();

	if (gameType == TG_None)
		ThrowError("Function must be called while game is running or with set game type argument!");

	if (gameType == TG_TeamGame) {
		new TG_Team:opTeam1 = TG_GetOppositeTeam(team1);
		new TG_Team:opopTeam1 = TG_GetOppositeTeam(opTeam1);

		if (opTeam1 == team2 && opopTeam1 == team1)
			return true;
	}

	if (gameType == TG_RedOnly && team1 == TG_RedTeam && team1 == team2)
		return true;

	return false;
}

/**
 * Is player in TG team (Red or Blue)?
 *
 * @param client	Client index.
 * @return			True on success, false otherwise.
 */
stock bool:TG_IsPlayerRedOrBlue(client)
{
	return TG_IsTeamRedOrBlue(TG_GetPlayerTeam(client));
}

/**
 * Are players in different teams? (Red vs. Blue or Blue vs. Red)
 *
 * @param client1		Client 1 index.
 * @param client2		Client 2 index.
 * @return				True on (client 1 team != client 2 team), false otherwise.
 */
stock bool:TG_InOppositeTeams(client1, client2)
{
	new TG_Team:team1 = TG_GetPlayerTeam(client1);
	new TG_Team:team2 = TG_GetPlayerTeam(client2);

	if (team1 != TG_RedTeam && team1 != TG_BlueTeam)
		return false;

	if (team2 != TG_RedTeam && team2 != TG_BlueTeam)
		return false;

	return (team1 != team2);
}

/**
 * Converts string to TG team.
 *
 * @param team		String to convert.
 * @return			TG team.
 */
stock TG_Team:TG_GetTeamFromString(String:team[])
{
	if (StrContains(team, "red", false) != -1 || team[0] == '1')
		return TG_RedTeam;
	else if (StrContains(team, "blue", false) != -1 || team[0] == '2')
		return TG_BlueTeam;
	else if (StrContains(team, "none", false) != -1 || team[0] == '0')
		return TG_NoneTeam;
	else
		return TG_ErrorTeam;
}

/**
 * Returns oposite TG team.
 *
 * Red -> Blue
 *
 * Blue -> Red
 *
 * @param team 		TG team.
 * @return 			Oposite TG team.
 */
stock TG_Team:TG_GetOppositeTeam(TG_Team:team)
{
	return (team == TG_RedTeam) ? TG_BlueTeam : (team == TG_BlueTeam) ? TG_RedTeam : TG_ErrorTeam;
}

/**
 * Is TG team Red or Blue?
 *
 * @param team 		TG team.
 * @return 			True on success, false otherwise.
 */
stock bool:TG_IsTeamRedOrBlue(TG_Team:team)
{
	return (team == TG_RedTeam || team == TG_BlueTeam);
}

/**
 * Is TG team valid? (Red, Blue or None)
 *
 * @param team 		TG team.
 * @return 			True on success, false otherwise.
 */
stock bool:TG_IsTeamValid(TG_Team:team)
{
	return (TG_IsTeamRedOrBlue(team) || team == TG_NoneTeam);
}

/**
 * Get random client from TG team.
 *
 * @param team 		TG team.
 * @return 			Client index on success, 0 otherwise.
 */
stock TG_GetRandomClient(TG_Team:team)
{
	decl clients[MAXPLAYERS + 1];
	new count = 0;

	for (new i = 1; i <= MaxClients; i++) {
		if (TG_GetPlayerTeam(i) == team) {
			clients[count] = i;
			count++;
		}
	}

	if (count == 0)
		return 0;

	return clients[GetRandomInt(0, count - 1)];
}

/**
 * Checks player's TG module access via SourceMod override system.
 *
 * 1. step: Check access for "TG_MenuItem-ModuleID" or "TG_Game-ModuleID" (depending on module type).
 *
 * 2. step: Check access for "ModuleID".
 *
 * @param client 		Client index.
 * @param type 			Module type.
 * @param moduleID 		Module ID.
 * @return 				True on success, false otherwise.
 */
stock bool:TG_CheckModuleAccess(client, TG_ModuleType:type, const String:moduleID[])
{
	new String:typeID[128], iFlags;
	Format(typeID, sizeof(typeID), "%s-%s", (type == TG_MenuItem) ? "TG_MenuItem" : "TG_Game", moduleID);

	if (GetCommandOverride(typeID, Override_Command, iFlags)) {
		return CheckCommandAccess(client, typeID, iFlags);
	} else {
		if (GetCommandOverride(moduleID, Override_Command, iFlags)) {
			return CheckCommandAccess(client, moduleID, iFlags);
		}
	}

	return true;
}

//------------------------------------------------------------------------------------------------
// Some little helpers

stock bool:DispatchKeyValueFormat(entity, const String:keyName[], const String:format[], any:...)
{
	decl String:value[256];
	VFormat(value, sizeof(value), format, 4);
	return DispatchKeyValue(entity, keyName, value);
}

stock bool:DispatchKeyValueNum(entity, const String:keyName[], value)
{
	return DispatchKeyValueFormat(entity, keyName, "%d", value);
}

stock GetCmdArgInt(argnum)
{
	decl String:value[256];
	GetCmdArg(argnum, value, sizeof(value));
	return StringToInt(value);
}

stock GetCmdArgFloat(argnum)
{
	decl String:value[256];
	GetCmdArg(argnum, value, sizeof(value));
	return StringToFloat(value);
}

stock CreateDirectoryPath(const String:dirPath[], mode, bool:containsFile = false)
{
	new String:path[PLATFORM_MAX_PATH];

	strcopy(path, sizeof(path), dirPath);
	ReplaceString(path, sizeof(path), "\\", "/");
	ReplaceString(path, sizeof(path), "//", "/");

	if (path[0] ==  '/') {
		strcopy(path, sizeof(path), path);
	}

	if (path[strlen(path) - 1] ==  '/') {
		strcopy(path, sizeof(path) - 1, path);
	}

	new String:dir[PLATFORM_MAX_PATH];
	new slash, pos, i;

	while (strlen(path) > pos) {
		if ((slash = FindCharInString(path[pos], '/')) != -1) {
			i = slash + pos + 1;
		} else {
			if (containsFile) {
				return;
			} else {
				i = sizeof(dir);
			}
		}

		strcopy(dir, i, path);
		pos += i - pos;

		CreateDirectory(dir, mode);
	}
}

stock RequestFrame2(RequestFrameCallback:func, framesAhead = 1, any:data = 0)
{
	if (framesAhead < 1)
		return;

	if (framesAhead == 1) {
		RequestFrame(func, data);
	} else {
		new Handle:pack = CreateDataPack();
#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 7
		WritePackFunction(pack, func);
#else
		WritePackCell(pack, func);
#endif
		WritePackCell(pack, framesAhead);
		WritePackCell(pack, data);

		RequestFrame(RequestFrame2_CallBack, pack);
	}
}

public RequestFrame2_CallBack(any:pack)
{
	ResetPack(Handle:pack);
#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 7
	new RequestFrameCallback:func = RequestFrameCallback:ReadPackFunction(Handle:pack);
#else
	new RequestFrameCallback:func = RequestFrameCallback:ReadPackCell(Handle:pack);
#endif
	new framesAhead = ReadPackCell(Handle:pack) - 1;
	new data = ReadPackCell(Handle:pack);
	CloseHandle(Handle:pack);

	RequestFrame2(func, framesAhead, data);
}

//------------------------------------------------------------------------------------------------
// Weapons (safe to use in both CS:S and CS:GO)

stock GivePlayerWeaponAndAmmo(client, String:weapon[], clip = -1, ammo = -1)
{
	new weaponEnt = GivePlayerItem(client, weapon);

	if (weaponEnt != -1) {
		if (clip != -1)
			SetEntProp(weaponEnt, Prop_Send, "m_iClip1", clip);

		if (ammo != -1) {
			new iOffset = FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weaponEnt, Prop_Data, "m_iPrimaryAmmoType") * 4);
			SetEntData(client, iOffset, ammo, 4, true);

			if (GetEngineVersion() == Engine_CSGO) {
				SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
			}
		}
	}

	return weaponEnt;
}

stock SetPlayerWeaponAmmo(client, weaponEnt, clip = -1, ammo = -1)
{
	if (weaponEnt == INVALID_ENT_REFERENCE)
		return;

	if (clip != -1)
		SetEntProp(weaponEnt, Prop_Send, "m_iClip1", clip);

	if (ammo != -1) {
		new iOffset = FindDataMapOffs(client, "m_iAmmo") + (GetEntProp(weaponEnt, Prop_Data, "m_iPrimaryAmmoType") * 4);
		SetEntData(client, iOffset, ammo, 4, true);

		if (GetEngineVersion() == Engine_CSGO) {
			SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
		}
	}
}
