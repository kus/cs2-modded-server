/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  restrict.inc
 *  Type:		  Core
 *  Description:   Weapon restriction system.
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
 * Maximum types allowed for a single weapon.
 */
#define WEAPONS_RESTRICT_MAX_TYPES 8

/**
 * Restrict config data indexes.
 */
enum RestrictData
{
	RESTRICT_DATA_NAME = 0,
}

/**
 * Array that stores the "HookID" to be later unhooked on player disconnect.
 */
int g_iCanUseHookID[MAXPLAYERS + 1] = {-1, ...};

/**
 * Array to block any client from picking up weapons.
 */
bool g_bRestrictBlockWeapon[MAXPLAYERS + 1];

/**
 * Array to store a list of different weapon groups
 */
Handle arrayWeaponTypes = INVALID_HANDLE;

/**
 * Query results returned when (un)restricting a weapon.
 */
enum RestrictQuery
{
	Query_Successful,   /** (Un)restrict was successful. */
	Query_Stopped,	  /** (Un)restrict was stopped because action was redundant. */
	Query_Locked,	   /** (Un)restrict was stopped because the weapon is marked "untoggleable." */
	Query_Invalid,	  /** (Un)restrict failed because invalid info was given. */
}

/**
 * Initialize data and hook commands.
 */
void RestrictInit()
{
	// Hook buy command.
	RegConsoleCmd("buy", RestrictBuyCommand);
	RegConsoleCmd("autobuy", RestrictBuyCommand);
	RegConsoleCmd("rebuy", RestrictBuyCommand);
}

/**
 * Auto-create a list of types loaded by weapons module.
 */ 
void RestrictLoad()
{
	// If array exists, then destroy it.
	if (arrayWeaponTypes != INVALID_HANDLE)
	{
		CloseHandle(arrayWeaponTypes);
	}
	
	// Initialize array.
	arrayWeaponTypes = CreateArray(WEAPONS_MAX_LENGTH);
	
	char weapontype[WEAPONS_MAX_LENGTH];
	char weapontypes[WEAPONS_RESTRICT_MAX_TYPES][WEAPONS_MAX_LENGTH];
	
	// x = Array index.
	int size = GetArraySize(arrayWeapons);
	for (int x = 0; x < size; x++)
	{
		WeaponsGetType(x, weapontype, sizeof(weapontype));
		
		ExplodeString(weapontype, ",", weapontypes, sizeof(weapontypes), sizeof(weapontypes[]));
		for (int y = 0; y < WEAPONS_RESTRICT_MAX_TYPES; y++)
		{
			// Cut off whitespace.
			TrimString(weapontypes[y]);
			
			// If we've reached the end of the weapon's types, then stop.
			if (!weapontypes[y][0])
			{
				break;
			}
			
			// If the weapon type isn't in the main array, then push it in.
			if (FindStringInArray(arrayWeaponTypes, weapontypes[y]) == -1)
			{
				// Push weapon type name into weapon type array.
				PushArrayString(arrayWeaponTypes, weapontypes[y]);
			}
		}
	}
}

/**
 * Hook commands related to restrict here.
 */
void RestrictOnCommandsCreate()
{
	// Create weapon admin commands.
	RegConsoleCmd("zr_restrict", RestrictCommand, "Restricts a weapon or a weapon type. Usage: zr_restrict <weapon|weapon type> [weapon2|weapontype2] ...");
	RegConsoleCmd("zr_unrestrict", UnrestrictCommand, "Unrestricts a weapon or a weapon type. Usage: zr_unrestrict <weapon|weapon type> [weapon2|weapontype2] ...");
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void RestrictClientInit(int client)
{
	// Hook "Weapon_CanUse" on client.
	#if defined USE_SDKHOOKS
		SDKHook(client, SDKHook_WeaponCanUse, RestrictCanUse);
		
		// Set dummy value so it think it's hooked.
		g_iCanUseHookID[client] = 1;
	#else
		g_iCanUseHookID[client] = ZRTools_HookWeapon_CanUse(client, RestrictCanUse);
	#endif
	
	// Reset block weapons flag.
	g_bRestrictBlockWeapon[client] = false;
}

/**
 * Unhook Weapon_CanUse function on a client.
 * 
 * @param client	The client index.
 */
void RestrictOnClientDisconnect(int client)
{
	// Unhook "Weapon_CanUse" callback, and reset variable.
	if (g_iCanUseHookID[client] != -1)
	{
		#if defined USE_SDKHOOKS
			SDKUnhook(client, SDKHook_WeaponCanUse, RestrictCanUse);
		#else
			ZRTools_UnhookWeapon_CanUse(g_iCanUseHookID[client]);
		#endif
		
		g_iCanUseHookID[client] = -1;
	}
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void RestrictOnClientSpawn(int client)
{
	// Re-hook "canuse" on client.
	#if defined USE_SDKHOOKS
		SDKUnhook(client, SDKHook_WeaponCanUse, RestrictCanUse);	 // <--- What happens if it's not already hooked???
		SDKHook(client, SDKHook_WeaponCanUse, RestrictCanUse);
		g_iCanUseHookID[client] = 1;
	#else
		ZRTools_UnhookWeapon_CanUse(g_iCanUseHookID[client]);
		g_iCanUseHookID[client] = ZRTools_HookWeapon_CanUse(client, RestrictCanUse);
	#endif
	
	// H4x.  Unfortunately I can't disable this flag early enough for CS:S to give start USP/Glock.
	// So I have to give BOOTLEG weapons.  (Sorry Valve)
	if (g_bRestrictBlockWeapon[client])
	{
		// Reset block weapons flag.
		g_bRestrictBlockWeapon[client] = false;
		
		if (ZRIsClientOnTeam(client, CS_TEAM_T))
		{
			if (g_Game != Game_CSGO) GivePlayerItem(client, WEAPONS_SPAWN_T_WEAPON);
		}
		else if (ZRIsClientOnTeam(client, CS_TEAM_CT))
		{
			if (g_Game != Game_CSGO) GivePlayerItem(client, WEAPONS_SPAWN_CT_WEAPON);
		}
	}
}

/**
 * The round is ending.
 */
void RestrictOnRoundEnd()
{
	bool restrictzombieequip = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_RESTRICT_ENDEQUIP]);
	if (!restrictzombieequip)
	{
		return;
	}
	
	// x = Client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If client is a human, then stop.
		if (InfectIsClientHuman(x))
		{
			continue;
		}
		
		// Enable block weapon flag.
		g_bRestrictBlockWeapon[x] = true;
	}
}

/**
 * Command callback function for the "buy" command
 * Used to block use of this command under certain conditions.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action RestrictBuyCommand(int client, int argc)
{
	// If client isn't valid, then stop.
	if (!ZRIsClientValid(client) || !IsClientInGame(client))
	{
		return Plugin_Continue;
	}
	
	// If the client isn't in a buyzone, then stop.
	if (!WeaponsIsClientInBuyZone(client))
	{
		return Plugin_Continue;
	}
	
	// If player is a zombie, then block command.
	if (InfectIsClientInfected(client))
	{
		TranslationPrintToChat(client, "Zombie cant use weapon");
		
		// Block command
		return Plugin_Handled;
	}
	
	char weapon[WEAPONS_MAX_LENGTH];
	GetCmdArg(1, weapon, sizeof(weapon));
	
	// If the weapon is restricted, then prevent pickup.
	char weaponname[WEAPONS_MAX_LENGTH];
	int weaponindex = WeaponsEntityToDisplay(weapon, weaponname, sizeof(weaponname), true);
	
	// If weapon isn't configged, then allow pickup.
	if (weaponindex == -1)
	{
		// Allow command.
		return Plugin_Continue;
	}
	
	// If weapon is restricted, then stop.
	if (RestrictIsWeaponRestricted(weaponindex))
	{
		TranslationPrintToChat(client, "Weapon is restricted", weaponname);
		
		// Block command.
		return Plugin_Handled;
	}
	
	// Allow command.
	return Plugin_Continue;
}

/**
 * Restricts (or unrestricts) a given weapon or weapon type.
 * 
 * @param restrict	  True to restrict, false to unrestrict.
 * @param target		Weapon or weapon type to restrict/unrestrict.
 * @param single		True if a single weapon is being restricted, false if weapon type.
 * @param returntarget  The proper targetname. (same as param 'target' if invalid)
 * @param maxlen		The maximum length of param 'returntarget.'
 * @return			  Query result. (See enum RestrictQuery)
 */
RestrictQuery RestrictWeapon(bool restrict, const char[] target, bool &single = true, char[] returntarget, int maxlen)
{
	// Copy 'target' to 'returntarget' to be possibly changed later.
	strcopy(returntarget, maxlen, target);
	
	// Find index of the given weapon type.
	int typeindex = RestrictTypeToIndex(returntarget);
	
	// Single weapon.
	if (typeindex == -1)
	{
		single = true;
		
		int weaponindex = WeaponsNameToIndex(returntarget);
		
		// If weapon index is invalid, then return invalid.
		if (weaponindex == -1)
		{
			return Query_Invalid;
		}
		
		// Return proper weapon name.
		WeaponsGetName(weaponindex, returntarget, maxlen);
		
		// If weapon is untoggleable, then return locked.
		if (!WeaponsGetToggleable(weaponindex))
		{
			return Query_Locked;
		}
		
		// If weapon restriction is redundant then return stopped.
		if (RestrictIsWeaponRestricted(weaponindex) == restrict)
		{
			return Query_Stopped;
		}
		
		// Set weapon's restricted state.
		RestrictSetWeaponRestricted(weaponindex, false, restrict);
		
		// Successfully restricted weapon.
		return Query_Successful;
	}
	// Weapon type.
	else
	{
		single = false;
		
		// Get all weapons in the given type.
		Handle arrayTypeWeapons;
		int count = RestrictGetTypeWeapons(typeindex, arrayTypeWeapons);
		
		// Return proper weapon name.
		RestrictWeaponTypeGetName(typeindex, returntarget, maxlen);
		
		// If weapon restriction is redundant then return stopped.
		if (RestrictIsTypeUniform(restrict, typeindex))
		{
			return Query_Stopped;
		}
		
		for (int x = 0; x < count; x++)
		{
			// Get weapon index.
			int weaponindex = GetArrayCell(arrayTypeWeapons, x);
			
			// If weapon is untoggleable, then stop.
			if (!WeaponsGetToggleable(weaponindex))
			{
				continue;
			}
			
			// Set weapon's restricted state.
			RestrictSetWeaponRestricted(weaponindex, false, restrict);
		}
		
		// Successfully restricted weapon type.
		return Query_Successful;
	}
}

/** Print weapon (un)restriction query result to client(s).
 *
 * @param client	The client to print response to. (0 for all clients)
 * @param query	 The query result.
 * @param single	True if a single weapon is being restricted.
 * @param restrict  True if the query was to restrict/unrestrict a weapon.
 * @param target	The target to be restricted/unrestricted.
 */
void RestrictPrintQueryResponse(int client, RestrictQuery query, bool single, bool restrict, const char[] target)
{
	switch(query)
	{
		// Query was successful.
		case Query_Successful:
		{
			if (single)
			{
				if (restrict)
				{
					TranslationPrintToChatAll(true, false, "Restrict weapon", target);
				}
				else
				{
					TranslationPrintToChatAll(true, false, "Unrestrict weapon", target);
				}
			}
			else
			{
				if (restrict)
				{
					TranslationPrintToChatAll(true, false, "Restrict weapon type", target);
				}
				else
				{
					TranslationPrintToChatAll(true, false, "Unrestrict weapon type", target);
				}
			}
		}
		// Query was redundant.
		case Query_Stopped:
		{
			if (single)
			{
				if (restrict)
				{
					TranslationReplyToCommand(client, "Restrict weapon stopped", target);
				}
				else
				{
					TranslationReplyToCommand(client, "Unrestrict weapon stopped", target);
				}
			}
			else
			{
				if (restrict)
				{
					TranslationReplyToCommand(client, "Restrict weapon type stopped", target);
				}
				else
				{
					TranslationReplyToCommand(client, "Unrestrict weapon type stopped", target);
				}
			}
		}
		// Weapon is untoggleable.
		case Query_Locked:
		{
			TranslationReplyToCommand(client, "Restrict weapon untoggleable", target);
		}
		// Weapon was invalid.
		case Query_Invalid:
		{
			TranslationReplyToCommand(client, "Weapon invalid", target);
		}
	}
}

stock int RestrictTypeToIndex(const char[] type)
{
	char typename[WEAPONS_MAX_LENGTH];
	
	// x = Array index.
	int size = GetArraySize(arrayWeaponTypes);
	for (int x = 0; x < size; x++)
	{
		RestrictWeaponTypeGetName(x, typename, sizeof(typename));
		
		// If types match, then return index.
		if (StrEqual(type, typename, false))
		{
			return x;
		}
	}
	
	// Type doesn't exist.
	return -1;
}

/**
 * Gets the name of a weapon type at a given index.
 * @param index	 The weapon type index.
 * @param weapon	The string to return name in.
 * @param maxlen	The max length of the string.
 */
stock void RestrictWeaponTypeGetName(int index, char[] weapontype, int maxlen)
{
	// Get weapon type name at given index.
	GetArrayString(arrayWeaponTypes, index, weapontype, maxlen);
}

/**
 * Returns an array containing all weapon indexes matching the given type.
 * 
 * @param index			 The weapon type index.
 * @param arrayTypeWeapons  A handle to store array containing matching weapons.
 *						  Don't forget to close this!
 */
stock int RestrictGetTypeWeapons(int index, Handle &arrayTypeWeapons)
{
	// Create array to hold weapons of the given type.
	arrayTypeWeapons = CreateArray();
	
	// Get name of the weapon type at given index.
	char typename[WEAPONS_MAX_LENGTH];
	RestrictWeaponTypeGetName(index, typename, sizeof(typename));
	
	int count;
	char weapontype[WEAPONS_MAX_LENGTH];
	char weapontypes[WEAPONS_RESTRICT_MAX_TYPES][WEAPONS_MAX_LENGTH];
	
	// x = Array index.
	int size = GetArraySize(arrayWeapons);
	for (int x = 0; x < size; x++)
	{
		WeaponsGetType(x, weapontype, sizeof(weapontype));
		
		ExplodeString(weapontype, ",", weapontypes, sizeof(weapontypes), sizeof(weapontypes[]));
		for (int y = 0; y < WEAPONS_RESTRICT_MAX_TYPES; y++)
		{
			// Cut off whitespace.
			TrimString(weapontypes[y]);
			
			// If we've reached the end of the weapon's types, then stop.
			if (!weapontypes[y][0])
			{
				break;
			}
			
			// If types match, then add weapon to array.
			if (StrEqual(typename, weapontypes[y], false))
			{
				PushArrayCell(arrayTypeWeapons, x);
				count++;
			}
		}
	}
	
	// Return number of weapons of the given type.
	return count;
}

/**
 * Gets the restricted status on a weapon.
 * 
 * @param index	 The weapon index.
 * @param toggle	If true, the value is toggled, otherwise 'restrict' param is used.
 * @param restrict  (Only if 'toggle' is 'false') Restricted status of the weapon.
 */
stock void RestrictSetWeaponRestricted(int index, bool toggle, bool restrict = false)
{
	// Get array handle of weapon at given index.
	Handle arrayWeapon = GetArrayCell(arrayWeapons, index);
	
	// Set restricted status.
	bool value = toggle ? !RestrictIsWeaponRestricted(index) : restrict;
	SetArrayCell(arrayWeapon, view_as<int>(WEAPONS_DATA_RESTRICTED), value);
}

/**
 * Gets the restricted status on a weapon.
 * 
 * @param index	 The weapon index.
 * @return		  True if weapon is restricted, false if not.
 */
stock bool RestrictIsWeaponRestricted(int index)
{
	// Get array handle of weapon at given index.
	Handle arrayWeapon = GetArrayCell(arrayWeapons, index);
	
	// Return restricted status.
	return view_as<bool>(GetArrayCell(arrayWeapon, view_as<int>(WEAPONS_DATA_RESTRICTED)));
}

/**
 * Used to check if all weapons of a type are restricted.
 * 
 * @param restricted	True to check if all weapons of given type are restricted.
 * @param index		 The weapon type index.
 * @return			  True if all weapons of the given type are restricted or not, false if not.
 */
stock bool RestrictIsTypeUniform(bool restricted, int index)
{
	Handle arrayTypeWeapons;
	int count = RestrictGetTypeWeapons(index, arrayTypeWeapons);
	
	// x = array index
	for (int x = 0; x < count; x++)
	{
		// Get weapon index to check restricted status of.
		int weaponindex = GetArrayCell(arrayTypeWeapons, x);
		
		// If weapon is toggleable and it's not uniform with the given status, then return false.
		if (WeaponsGetToggleable(weaponindex) && RestrictIsWeaponRestricted(weaponindex) != restricted)
		{
			return false;
		}
	}
	
	// All weapons are restricted, so return true.
	return true;
}

/**
 * Hook callback, called when a player is trying to pick up a weapon.
 * @param client	The client index.
 * @param weapon	The weapon index.
 * @return		  Return ZRTools_Handled to stop weapon pickup.
 *				  ZRTools_Continue to allow weapon pickup.
 */
#if defined USE_SDKHOOKS
public Action RestrictCanUse(int client, int weapon)
#else
public ZRTools_Action RestrictCanUse(int client, int weapon)
#endif
{
	if(g_allweapons[client])
	{
		return ACTION_CONTINUE;
	}
	
	char weaponentity[WEAPONS_MAX_LENGTH];
	GetEdictClassname(weapon, weaponentity, sizeof(weaponentity));
	
	// If weapon is a knife, then allow pickup.
	if (StrEqual(weaponentity, "weapon_knife"))
	{
		return ACTION_CONTINUE;
	}
	
	// If the player is a zombie, then prevent pickup.
	if (InfectIsClientInfected(client))
	{
		return ACTION_HANDLED;
	}
	
	// If client is flagged for not picking up weapons, then stop.
	if (g_bRestrictBlockWeapon[client])
	{
		return ACTION_HANDLED;
	}
	
	// If weapons module is disabled, then stop.
	bool weapons = GetConVarBool(g_hCvarsList[CVAR_WEAPONS]);
	if (!weapons)
	{
		return ACTION_CONTINUE;
	}
	
	// If restrict module is disabled, then stop.
	bool restrict = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_RESTRICT]);
	if (!restrict)
	{
		return ACTION_CONTINUE;
	}
	
	// If the weapon is restricted, then prevent pickup.
	char weaponname[WEAPONS_MAX_LENGTH];
	int weaponindex = WeaponsEntityToDisplay(weaponentity, weaponname, sizeof(weaponname));
	
	// If weapon isn't configged, then allow pickup.
	if (weaponindex == -1)
	{
		// Allow pickup.
		return ACTION_CONTINUE;
	}
	
	// If weapon is restricted, then stop.
	if (RestrictIsWeaponRestricted(weaponindex))
	{
		return ACTION_HANDLED;
	}
	
	// Forward event to weapons module.
	WeaponsOnItemPickup(client, weapon);
	
	// Allow pickup.
	return ACTION_CONTINUE;
}

/**
 * Command callbacks.
 */

/**
 * Command callback (zr_restrict)
 * Restricts a weapon or group
 *   
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action RestrictCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// If weapons module is disabled, then stop.
	bool weapons = GetConVarBool(g_hCvarsList[CVAR_WEAPONS]);
	if (!weapons)
	{
		// Tell client command is disabled.
		TranslationReplyToCommand(client, "Feature is disabled");
		return Plugin_Handled;
	}
	
	// If restrict module is disabled, then stop.
	bool restrict = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_RESTRICT]);
	if (!restrict)
	{
		// Tell client command is disabled.
		TranslationReplyToCommand(client, "Feature is disabled");
		return Plugin_Handled;
	}
	
	// If not enough arguments given, then stop.
	if (argc < 1)
	{
		TranslationReplyToCommand(client, "Weapons command restrict syntax");
		return Plugin_Handled;
	}
	
	char target[WEAPONS_MAX_LENGTH];
	
	int args = GetCmdArgs();
	for (int x = 1; x <= args; x++)
	{
		// Get target to restrict.
		GetCmdArg(x, target, sizeof(target));
		
		// Query restrict on this target, and get a result back.
		bool single;
		char returntarget[WEAPONS_MAX_LENGTH];
		RestrictQuery query = RestrictWeapon(true, target, single, returntarget, sizeof(returntarget));
		
		// Print response to client(s).
		RestrictPrintQueryResponse(client, query, single, true, returntarget);
	}
	
	return Plugin_Handled;
}

/**
 * Command callback (zr_unrestrict)
 * Unrestricts a weapon or group
 *   
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action UnrestrictCommand(int client, int argc)
{
	// Check if privileged.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		TranslationReplyToCommand(client, "No access to command");
		return Plugin_Handled;
	}
	
	// If weapons module is disabled, then stop.
	bool weapons = GetConVarBool(g_hCvarsList[CVAR_WEAPONS]);
	if (!weapons)
	{
		// Tell client command is disabled.
		TranslationReplyToCommand(client, "Feature is disabled");
		return Plugin_Handled;
	}
	
	// If restrict module is disabled, then stop.
	bool restrict = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_RESTRICT]);
	if (!restrict)
	{
		// Tell client command is disabled.
		TranslationReplyToCommand(client, "Feature is disabled");
		return Plugin_Handled;
	}
	
	// If not enough arguments given, then stop.
	if (argc < 1)
	{
		TranslationReplyToCommand(client, "Weapons command unrestrict syntax");
		return Plugin_Handled;
	}
	
	// arg1 = weapon being restricted
	char target[WEAPONS_MAX_LENGTH];
	
	int args = GetCmdArgs();
	for (int x = 1; x <= args; x++)
	{
		// Get target to restrict.
		GetCmdArg(x, target, sizeof(target));
		
		// Query unrestrict on this target, and get a result back.
		bool single;
		char returntarget[WEAPONS_MAX_LENGTH];
		RestrictQuery query = RestrictWeapon(false, target, single, returntarget, sizeof(returntarget));
		
		// Print response to client(s).
		RestrictPrintQueryResponse(client, query, single, false, returntarget);
	}
	
	return Plugin_Handled;
}
