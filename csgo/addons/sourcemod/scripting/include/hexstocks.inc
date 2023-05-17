/*
**
*/
#if defined _hexstocks_included
#endinput
#endif
#define _hexstocks_included

#define MAX_ENTITIES 2048

/*
INCLUDE MERGE OF MYSTOCKS(shanpu)teamgames-stocks/menu-stocks(KissLick) & some other!
*/

//Easy loops
#pragma deprecated Dont use macro loops
#define LoopClients(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1))
#pragma deprecated Dont use macro loops
#define LoopValidClients(%1,%2,%3) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsValidClient(%1,%2,%3))
	
/*************************************** CLIENT ***************************/

/**
* Check if for a valid client
*
*
* @param client				Client Index
* @param AllowBots				Allow Bots?
* @param AllowDead				Allow Dead players?
* @noreturn
*/
stock bool IsValidClient(int client, bool AllowBots = false, bool AllowDead = false)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !AllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!AllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}

/**
* Checks if user flags (Root is always true)
*
*
* @param client			Client Index
* @param flags				Flags to check, enter comma to separate flags.
* @return					True if client has the flags, false otherwise.
*/
stock bool CheckAdminFlag(int client, const char[] flags)
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

/**
* Checks if user flags
*
*
* @param client			Client Index
* @param flags				Flags to check, enter comma to separate flags.
* @return					True if client has the flags, false otherwise.
*/
stock bool CheckAdminFlagEx(int client, const char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i]) == ReadFlagString(sflagNeed[i])))
		{
			bEntitled = true;
			break;
		}
	}
	
	return bEntitled;
}






/**
* Get the target client
*
* @param client			Client Index
* @param argnum			Number of the arg
* @return					Client Index or -1 on failure.
*/
stock int GetTarget(int client, int argnum)
{
	char sTarget[32];
	
	GetCmdArg(argnum, sTarget, sizeof(sTarget));
	return FindTarget(client, sTarget);
}


/**
* Get player count of a team
*
* @param team				Team (-1 for total)
* @param alive				Count only alive players?
* @return					Team Count
*/
stock int GetAliveTeamCount(int team = -1, bool alive = true)
{
	int number = 0;
	for (int i; i <= MaxClients; i++)if (IsPlayerAlive(i) || !alive) && (GetClientTeam(i) == team || team = -1)
	number++;
	return number;
}



/**
* Get random player of a team
*
*
* @param team				Team, -1 for any
* @param True				True to include only alive players.
* @noreturn
*/
stock int GetRandomPlayer(int team = -1, bool OnlyAlive = true)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && (team == -1 || GetClientTeam(i) == team) && (!OnlyAlive || !IsPlayerAlive(i)))
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
	
}



/*********************************** NUMBERS *****************************/

/**
* Checks if an number is even
*
*
* @param num				Number to check
* @return					True if number is even, false otherwise.
*/
stock bool IsEven(int num)
{
	return (num & 1) == 0;
}

/**
* Checks if an number is odd
*
*
* @param num				Number to check
* @return					True if number is odd, false otherwise.
*/
stock bool IsOdd(int num)
{
	return (num & 1) == 1;
}

/********************************** WEAPONS ********************************/


/**
* Strip All Weapons & the knife slot twice for taser
*
*
* @param client				Client Index
* @noreturn
*/
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
	
	if ((weapon = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE)) != -1) // strip knife slot 2 times for taser
	{
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}
}

/**
* Gives an Item to a client with custom ammos
*
* @param client			Client Index
* @param weapon			Weapon Name
* @param clip				Ammo ammount in the clip
* @param ammo				Total ammo ammount
* @return					Entity Index
*/
stock int GivePlayerItemAmmo(int client, const char[] weapon, int ammo = -1, int clip = -1)
{
	int weaponEnt = GivePlayerItem(client, weapon);
	
	SetPlayerWeaponAmmo(client, weaponEnt, clip, ammo);
	
	return weaponEnt;
}

/**
* Set ammo account for a weapon
*
* @param client			Client Index
* @param weapon			Weapon Index
* @param clip				Ammo ammount in the clip
* @param ammo				Total ammo ammount
* @noreturn
*/
stock void SetPlayerWeaponAmmo(int client, int weaponEnt, int clip = -1, int ammo = -1)
{
	if (IsValidEdict(weaponEnt))
	{
		if (clip != -1)
			SetEntProp(weaponEnt, Prop_Data, "m_iClip1", clip);
		if (ammo != -1)
		{
			SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
			SetEntProp(weaponEnt, Prop_Send, "m_iSecondaryReserveAmmoCount", ammo);
		}
	}
}

/**
* Gives an Item to a client removing the current weapon
*
* @param client			Client Index
* @param weapon
* @return					Iteam Index
*/
stock int GivePlayerItemRemove(int client, int weapon, int slot)
{
	if ((weapon = GetPlayerWeaponSlot(client, slot)) != -1)
	{
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}
	return GivePlayerItem(client, weapon);
}

/****************************** COMMAND ARGS **************************/


/**
* Retrives a command argument given its index as int, from the console or server command
*
* @param argnum			Arg number
* @return					Int Value of Arg
*/
stock int GetCmdArgInt(int argnum)
{
	char value[256];
	GetCmdArg(argnum, value, sizeof(value));
	return StringToInt(value);
}

/**
* Retrives a command argument given its index as float, from the console or server command
*
* @param argnum			Arg number
* @return					Float Value of Arg
*/
stock float GetCmdArgFloat(int argnum)
{
	char value[256];
	GetCmdArg(argnum, value, sizeof(value));
	return StringToFloat(value);
}

/**
* Retrives a command argument given its index as bool, from the console or server command
*
* @param argnum			Arg number
* @return					Bool Value of Arg
*/
stock bool GetCmdArgBool(int argnum)
{
	char value[256];
	GetCmdArg(argnum, value, sizeof(value));
	return view_as<bool>(StringToInt(value));
}

/********************************** CVARS **************************************/

/**
* Easy silent change of ConVars - Boolean
*
*
* @param cvarName				Name of cvar
* @param value					New value of cvar
* @noreturn
*/
stock void SetCvar(char cvarName[64], int value)
{
	Handle IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	
	int flags = GetConVarFlags(IntCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(IntCvar, flags);
	
	SetConVarInt(IntCvar, value);
	
	flags |= FCVAR_NOTIFY;
	SetConVarFlags(IntCvar, flags);
}



/**
* Easy silent change of ConVars - Floats
*
*
* @param cvarName				Name of cvar
* @param value					New value of cvar
* @noreturn
*/
stock void SetCvarFloat(char cvarName[64], float value)
{
	Handle FloatCvar = FindConVar(cvarName);
	if (FloatCvar == INVALID_HANDLE)return;
	
	int flags = GetConVarFlags(FloatCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(FloatCvar, flags);
	
	SetConVarFloat(FloatCvar, value);
	
	flags |= FCVAR_NOTIFY;
	SetConVarFlags(FloatCvar, flags);
}



/**
* Easy silent change of ConVars - Strings
*
*
* @param cvarName				Name of cvar
* @param value					New value of cvar
* @noreturn
*/
stock void SetCvarString(char cvarName[64], char[] value)
{
	Handle cvar = FindConVar(cvarName);
	SetConVarString(cvar, value, true);
}


/********************************************** ENTITIES *********************************************/


stock bool IsValidEnt(int ent)
{
	if (ent == INVALID_ENT_REFERENCE && ent <= MaxClients && !(IsValidEntity(ent) || IsValidEdict(ent))
	{
		return false;
	}
	return true;
}

/**
* Sets an entity's speed
*
* @param entity			Entity Index
* @param speed				Speed to set
* @noreturn
*/
stock void SetEntitySpeed(int entity, float speed)
{
	SetEntPropFloat(entity, Prop_Data, "m_flLaggedMovementValue", speed);
}

/**
* Gets an entity's Speed
*
* @param entity			Entity Index
* @return					Amount of Speed
*/
stock float GetEntitySpeed(int entity)
{
	return GetEntPropFloat(entity, Prop_Data, "m_flLaggedMovementValue");
}

stock void SetEntityName(int entity, char[] format, any ...)
{
	char sName[128];
	VFormat(sName, sizeof(sName), format, 3);
	
	SetEntPropString(entity, Prop_Data, "m_iName", sName); 
}

/**
* Get an entity origin
*
* @param entity		Entity index.
* @param origin		Vector to store origin.
* @noreturn
*/
stock void GetEntityOrigin(int entity, float origin[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
}

/**
* Get an entity angles
*
* @param entity		Entity index.
* @param origin		Vector to store origin.
* @noreturn
*/
stock void GetEntityAngles(int entity, float angles[3])
{
	GetEntPropVector(entity, Prop_Data, "m_angRotation", angles);
}

/**
* Get an entity model
*
* @param entity		Entity index.
* @param origin		String to store model.
* @noreturn
*/
stock void GetEntityModel(int entity, char model[PLATFORM_MAX_PATH])
{
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
}

/********************************** MISC *********************************/

/** Reset client Render Color
*
* @param client				Client Index
* @noreturn
*/
stock void ResetRenderColor(int client)
{
	SetEntityRenderColor(client, 255, 255, 255, 255);
}


/**
* Appends a new item to the end of a menu with a format.
*
* @param menu				Menu Handle.
* @param info				Item information string.
* @param display			Default item display string.
* @param style				Drawing style flags.  Anything other than DEFAULT or
* @param format			Formatting rules
* @param ...				Variable number of format parameters
* @return					True on success, false on failure.
* @error					Invalid Handle or item limit reached.
*/
stock bool AddMenuItemFormat(Handle menu, const char[] info, int style = ITEMDRAW_DEFAULT, const char[] format, any...)
{
	char display[128];
	VFormat(display, sizeof(display), format, 5);
	
	return AddMenuItem(menu, info, display, style);
}


/**
*
* @param LogFile		Buffer to store the path
* @param FileName		File to write the log in
* @param FolderName	Directory/Folder to write the logs in
* @noreturn
*/
stock void SetLogFile(char LogFile[PLATFORM_MAX_PATH], char[] FileName, char[] FolderName)
{
	char sDate[12];
	FormatTime(sDate, sizeof(sDate), "%y-%m-%d");
	Format(LogFile, sizeof(LogFile), "logs/%s/%s-%s.log", FolderName, FileName, sDate);
	
	BuildPath(Path_SM, LogFile, sizeof(LogFile), LogFile);
}


/**
 * Opens and creates, returning a File handle on success. File handles
 * should be closed with delete or CloseHandle().
 *
 * The open mode may be one of the following strings:
 *   "r": Open an existing file for reading.
 *   "w": Create a file for writing, or truncate (delete the contents of) an
 *        existing file and then open it for writing.
 *   "a": Create a file for writing, or open an existing file such that writes
 *        will be appended to the end.
 *   "r+": Open an existing file for both reading and writing.
 *   "w+": Create a file for reading and writing, or truncate an existing file
 *         and then open it for reading and writing.
 *   "a+": Create a file for both reading and writing, or open an existing file
 *         such that writes will be appended to the end.
 *
 * The open mode may also contain an additional character after "r", "w", or "a",
 * but before any "+" sign. This character may be "b" (indicating binary mode) or
 * "t" (indicating text mode). By default, "text" mode is implied. On Linux and
 * Mac, this has no distinction from binary mode. On Windows, it causes the '\n'
 * character (0xA) to be written as "\r\n" (0xD, 0xA).
 *
 * Example: "rb" opens a binary file for writing; "at" opens a text file for
 * appending.
 *
 * @param file			File to open.
 * @param mode			Open mode.
 * @param use_valve_fs  If true, the Valve file system will be used instead.
 *                      This can be used to find files existing in valve
 *						search paths, rather than solely files existing directly
 *						in the gamedir.
 * @param valve_path_id	If use_valve_fs, a search path from gameinfo or NULL_STRING for all search paths.
 * @return				A File handle, or null if the file could not be opened.
 */
stock File OpenFileEx(const char[] file, const char[] mode, bool use_valve_fs = false, const char[] valve_path_id = "GAME")
{
	if (!FileExists(file))
	{
		File hFile = OpenFile(file, "w");
		hFile.Close();
	}
	return OpenFile(file, mode, use_valve_fs, valve_path_id);
}


/**
* Kills a Timer and reset its Handle to null
*
* @param timer		 Timer Handle to kill
* @noreturn
*/
stock void StopTimer(Handle &timer)
{
	if (timer != INVALID_HANDLE)
	{
		timer.Close();
		timer = INVALID_HANDLE;
	}
}

/**
* Returns if warmup is in progress
*
* @return		True if it is, false otherwise
*/
stock bool IsWarmup()
{
	return (GameRules_GetProp("m_bWarmupPeriod") == 1);
}