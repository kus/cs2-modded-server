/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  attributes.inc
 *  Type:		  Core
 *  Description:   Retrieving class attributes from certain caches.
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
 * ------------------------------------
 *
 *		 GENERAL ATTRIBUTES
 *
 * ------------------------------------
 */
 
/**
 * Checks if the specified class is enabled.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 *				  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is used,
 *				  index will be used as a client index.
 * @return		  True if it's enabled, false otherwise.
 */
stock bool ClassIsEnabled(int index, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_Enabled];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_Enabled];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_Enabled];
		}
	}
	return false;
}

/**
 * Gets the team ID for the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return		  The team ID if successful, -1 otherwise.
 */
stock int ClassGetTeamID(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_Team];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_Team];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_Team];
		}
	}
	return -1;
}

/**
 * Checks if the specified class is marked as the default class for its current
 * team.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 *				  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is used,
 *				  index will be used as a client index.
 * @return		  True if it's default for its current team, false otherwise.
 */
stock bool ClassGetTeamDefault(int index, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_TeamDefault];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_TeamDefault];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_TeamDefault];
		}
	}
	return false;
}

/**
 * Gets flags for the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 *				  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is used,
 *				  index will be used as a client index.
 * @return		  Class flags, or -1 if failed.
 */
stock int ClassGetFlags(int index, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_Flags];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_Flags];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_Flags];
		}
	}
	return -1;
}

/**
 * Do bitwise compare on flags in the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param flags	 Class flags to check.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED (default) - Changed/newest class
 *				  data.
 *				  ZR_CLASS_CACHE_PLAYER - Player cache. If this one is used,
 *				  index will be used as a client index.
 * @return		  True if the flags are set, false otherwise or if failed.
 */
stock bool ClassHasFlags(int index, int flags, int cachetype = ZR_CLASS_CACHE_MODIFIED)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return view_as<bool>((ClassData[index][Class_Flags] & flags));
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return view_as<bool>((ClassDataCache[index][Class_Flags] & flags));
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return view_as<bool>((ClassPlayerCache[index][Class_Flags] & flags));
		}
	}
	return false;
}

/**
 * Gets the class group required to be a member of to use the class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param buffer	The destination string buffer.
 * @param maxlen	The length of the destination string buffer.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return		  Number of cells written. -1 on error.
 */
stock int ClassGetGroup(int index, char[] buffer, int maxlen, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return strcopy(buffer, maxlen, ClassData[index][Class_Group]);
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return strcopy(buffer, maxlen, ClassDataCache[index][Class_Group]);
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return strcopy(buffer, maxlen, ClassPlayerCache[index][Class_Group]);
		}
	}
	
	return -1;
}

/**
 * Gets the class sourcemod flags required to use the class.
 *
 * @param index     Index of the class in a class cache or a client index,
 *                  depending on the cache type specified.
 * @param buffer    The destination string buffer.
 * @param maxlen    The length of the destination string buffer.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *                  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *                  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *                  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *                  is used, index will be used as a client index.
 * @return          Number of cells written. -1 on error.
 */
stock int ClassGetSM_Flags(int index, char[] buffer, int maxlen, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return strcopy(buffer, maxlen, ClassData[index][Class_SM_Flags]);
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return strcopy(buffer, maxlen, ClassDataCache[index][Class_SM_Flags]);
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return strcopy(buffer, maxlen, ClassPlayerCache[index][Class_SM_Flags]);
		}
	}

	return -1;
}

/**
 * Gets the class name displayed in the class menu.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param buffer	The destination string buffer.
 * @param maxlen	The length of the destination string buffer.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return		  Number of cells written. -1 on error.
 */
stock int ClassGetName(int index, char[] buffer, int maxlen, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return strcopy(buffer, maxlen, ClassData[index][Class_Name]);
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return strcopy(buffer, maxlen, ClassDataCache[index][Class_Name]);
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return strcopy(buffer, maxlen, ClassPlayerCache[index][Class_Name]);
		}
	}
	
	return -1;
}

/**
 * Gets the menu description string for the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param buffer	The destination string buffer.
 * @param maxlen	The length of the destination string buffer.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Number of cells written. -1 on error.
 */
stock int ClassGetDescription(int index, char[] buffer, int maxlen, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return strcopy(buffer, maxlen, ClassData[index][Class_Description]);
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return strcopy(buffer, maxlen, ClassDataCache[index][Class_Description]);
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return strcopy(buffer, maxlen, ClassPlayerCache[index][Class_Description]);
		}
	}
	return -1;
}



/*
 * ------------------------------------
 *
 *		  MODEL ATTRIBUTES
 *
 * ------------------------------------
 */

/**
 * Gets the model path string from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param buffer	The destination string buffer.
 * @param maxlen	The length of the destination string buffer.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Number of cells written. -1 on error.
 */
stock int ClassGetModelPath(int index, char[] buffer, int maxlen, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return strcopy(buffer, maxlen, ClassData[index][Class_ModelPath]);
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return strcopy(buffer, maxlen, ClassDataCache[index][Class_ModelPath]);
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return strcopy(buffer, maxlen, ClassPlayerCache[index][Class_ModelPath]);
		}
	}
	return -1;
}


/**
 * Gets the Arms model path string from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param buffer	The destination string buffer.
 * @param maxlen	The length of the destination string buffer.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Number of cells written. -1 on error.
 */
stock int ClassGetArmsPath(int index, char[] buffer, int maxlen, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return strcopy(buffer, maxlen, ClassData[index][Class_Arms_Path]);
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return strcopy(buffer, maxlen, ClassDataCache[index][Class_Arms_Path]);
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return strcopy(buffer, maxlen, ClassPlayerCache[index][Class_Arms_Path]);
		}
	}
	return -1;
}

/**
 * Gets the model skin index from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The model skin index in the specified class. -1 on error.
 */
stock int ClassGetModelSkinIndex(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_ModelSkinIndex];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_ModelSkinIndex];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_ModelSkinIndex];
		}
	}
	return -1;
}

/**
 * Gets the initial alpha value from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The initial alpha value from the specified class. -1 on error.
 */
stock int ClassGetAlphaInitial(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_AlphaInitial];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_AlphaInitial];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_AlphaInitial];
		}
	}
	return -1;
}

/**
 * Gets the alpha value when damaged, from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The alpha value when damaged, from the specified class. -1 on
 *		  error.
 */
stock int ClassGetAlphaDamaged(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_AlphaDamaged];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_AlphaDamaged];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_AlphaDamaged];
		}
	}
	return -1;
}

/**
 * Gets the damage amount needed to change alpha, from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The damage amount needed to change alpha, from the specified class.
 *		  -1 on error.
 */
stock int ClassGetAlphaDamage(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_AlphaDamage];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_AlphaDamage];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_AlphaDamage];
		}
	}
	return -1;
}



/*
 * ------------------------------------
 *
 *		   HUD ATTRIBUTES
 *
 * ------------------------------------
 */

/**
 * Gets the overlay path from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param buffer	The destination string buffer.
 * @param maxlen	The length of the destination string buffer.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Number of cells written. -1 on error.
 */
stock int ClassGetOverlayPath(int index, char[] buffer, int maxlen, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return strcopy(buffer, maxlen, ClassData[index][Class_OverlayPath]);
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return strcopy(buffer, maxlen, ClassDataCache[index][Class_OverlayPath]);
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return strcopy(buffer, maxlen, ClassPlayerCache[index][Class_OverlayPath]);
		}
	}
	return -1;	
}

/**
 * Gets the night vision setting from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The night vision setting from the specified class. False on error.
 */
stock bool ClassGetNvgs(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_Nvgs];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_Nvgs];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_Nvgs];
		}
	}
	return false;
}

/**
 * Gets the field of view value from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The field of view value from the specified class. -1 on error.
 */
stock int ClassGetFOV(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_Fov];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_Fov];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_Fov];
		}
	}
	return -1;
}



/*
 * ------------------------------------
 *
 *			  EFFECTS
 *
 * ------------------------------------
 */

/**
 * Gets the napalm setting from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  True if the class has napalm grenades, false otherwise.
 */
stock bool ClassGetHasNapalm(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_HasNapalm];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_HasNapalm];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_HasNapalm];
		}
	}
	return false;
}

/**
 * Gets the napalm grenades time from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The napalm grenades time from the specified class. -1.0 on error.
 */
stock float ClassGetNapalmTime(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_NapalmTime];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_NapalmTime];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_NapalmTime] * ClassGetAttributeMultiplier(index, ClassM_NapalmTime);
		}
	}
	return -1.0;
}



/*
 * ------------------------------------
 *
 *		  PLAYER BEHAVIOUR
 *
 * ------------------------------------
 */

/**
 * Gets the immunity mode for the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Current immunity mode to the specified class. Immunity_Invalid on
 *		  error.
 */
stock ImmunityMode ClassGetImmunityMode(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_ImmunityMode];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_ImmunityMode];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_ImmunityMode];
		}
	}
	return Immunity_Invalid;
}

/**
 * Gets the immunity amount for the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Current immunity amount fot the specified class. -1 on error.
 */
stock int ClassGetImmunityAmount(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_ImmunityAmount];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_ImmunityAmount];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_ImmunityAmount];
		}
	}
	return -1;
}

/**
 * Gets the immunity cooldown for the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Current immunity cooldown for the specified class. -1 on error.
 */
stock int ClassGetImmunityCooldown(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_ImmunityCooldown];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_ImmunityCooldown];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_ImmunityCooldown];
		}
	}
	return -1;
}

/**
 * Gets the no fall damage setting from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The no fall damage setting from the specified class. False on
 * error.
 */
stock bool ClassGetNoFallDamage(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_NoFallDamage];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_NoFallDamage];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_NoFallDamage];
		}
	}
	return false;
}

/**
 * Gets the health points from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  Health points from the specified class. -1 on error.
 */
stock int ClassGetHealth(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_Health];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_Health];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return RoundToCeil(ClassPlayerCache[index][Class_Health] * ClassGetAttributeMultiplier(index, ClassM_Health));
		}
	}
	return -1;
}

/**
 * Gets the health regen interval time from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The health regen interval time from the specified class. -1.0 on
 *		  error.
 */
stock float ClassGetHealthRegenInterval(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_HealthRegenInterval];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_HealthRegenInterval];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_HealthRegenInterval] * ClassGetAttributeMultiplier(index, ClassM_HealthRegenInterval);
		}
	}
	return -1.0;
}

/**
 * Gets the health regen amount value from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The health regen amount value from the specified class. -1 on
 *		  error.
 */
stock int ClassGetHealthRegenAmount(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_HealthRegenAmount];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_HealthRegenAmount];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return RoundToCeil(ClassPlayerCache[index][Class_HealthRegenAmount] * ClassGetAttributeMultiplier(index, ClassM_HealthRegenAmount));
		}
	}
	return -1;
}

/**
 * Gets the health infect gain value from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The health infect gain value from the specified class. -1 on
 *		  error.
 */
stock int ClassGetHealthInfectGain(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_HealthInfectGain];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_HealthInfectGain];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return RoundToCeil(ClassPlayerCache[index][Class_HealthInfectGain] * ClassGetAttributeMultiplier(index, ClassM_HealthInfectGain));
		}
	}
	return -1;
}

/**
 * Gets the kill bonus points from the specified class.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The kill bonus points from the specified class.
 */
stock int ClassGetKillBonus(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_KillBonus];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_KillBonus];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_KillBonus];
		}
	}
	return -1;
}

/**
 * Gets the running speed value from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The running speed value from the specified class. -1.0 on error.
 */
stock float ClassGetSpeed(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_Speed];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_Speed];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			float speed = ClassPlayerCache[index][Class_Speed];
			float multiplier = ClassGetAttributeMultiplier(index, ClassM_Speed);
			
			// Apply multiplier.
			if (ClassSpeedMethod == ClassSpeed_Prop)
			{
				// Prop speed is an offset. Convert to absolute value.
				speed += 250;
				
				// Apply multiplier.
				speed *= multiplier;
				
				// Convert back to speed offset.
				speed -= 250;
			}
			else
			{
				speed *= multiplier;
			}
			return speed;
		}
	}
	return -1.0;
}

/**
 * Gets the knock back boost from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The knock back boost from the specified class. 0.0 on error.
 */
stock float ClassGetKnockback(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_KnockBack];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_KnockBack];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_KnockBack] * ClassGetAttributeMultiplier(index, ClassM_Knockback);
		}
	}
	return 0.0;
}

/**
 * Gets the jump height boost from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The jump height boost from the specified class. -1.0 on error.
 */
stock float ClassGetJumpHeight(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_JumpHeight];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_JumpHeight];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_JumpHeight] * ClassGetAttributeMultiplier(index, ClassM_JumpHeight);
		}
	}
	return -1.0;
}

/**
 * Gets the jump distance boost from the specified class.
 *
 * Note: Multiplier is used if cache type is player cache.
 *
 * @param index	 Index of the class in a class cache or a client index,
 *				  depending on the cache type specified.
 * @param cachetype Optional. Specifies what class cache to read from. Options:
 *				  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *				  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *				  ZR_CLASS_CACHE_PLAYER (default) - Player cache. If this one
 *				  is used, index will be used as a client index.
 * @return  The jump distance boost from the specified class. -1.0 on error.
 */
stock float ClassGetJumpDistance(int index, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	switch (cachetype)
	{
		case ZR_CLASS_CACHE_ORIGINAL:
		{
			return ClassData[index][Class_JumpDistance];
		}
		case ZR_CLASS_CACHE_MODIFIED:
		{
			return ClassDataCache[index][Class_JumpDistance];
		}
		case ZR_CLASS_CACHE_PLAYER:
		{
			return ClassPlayerCache[index][Class_JumpDistance] * ClassGetAttributeMultiplier(index, ClassM_JumpDistance);
		}
	}
	return -1.0;
}

/**
 * Gets the attribute flag that represent the specified attribute.
 *
 * @param attributename	 The attribute name.
 * @return				  The flag that represent the specified attribute.
 *						  -1 on error.
 */
stock int ClassAttributeNameToFlag(const char[] attributename)
{
	// Check attribute names.
	if (StrEqual(attributename, "enabled", false))
	{
		return ZR_CLASS_ENABLED;
	}
	else if (StrEqual(attributename, "team", false))
	{
		return ZR_CLASS_TEAM;
	}
	else if (StrEqual(attributename, "team_default", false))
	{
		return ZR_CLASS_TEAM_DEFAULT;
	}
	else if (StrEqual(attributename, "flags", false))
	{
		return ZR_CLASS_FLAGS;
	}
	else if (StrEqual(attributename, "group", false))
	{
		return ZR_CLASS_GROUP;
	}
	else if (StrEqual(attributename, "sm_flags", false))
	{
		return ZR_CLASS_SM_FLAGS;
	}
	else if (StrEqual(attributename, "name", false))
	{
		return ZR_CLASS_NAME;
	}
	else if (StrEqual(attributename, "description", false))
	{
		return ZR_CLASS_DESCRIPTION;
	}
	else if (StrEqual(attributename, "model_path", false))
	{
		return ZR_CLASS_MODEL_PATH;
	}
	else if (StrEqual(attributename, "model_skin_index", false))
	{
		return ZR_CLASS_MODEL_SKIN_INDEX;
	}
	else if (StrEqual(attributename, "alpha_initial", false))
	{
		return ZR_CLASS_ALPHA_INITIAL;
	}
	else if (StrEqual(attributename, "alpha_damaged", false))
	{
		return ZR_CLASS_ALPHA_DAMAGED;
	}
	else if (StrEqual(attributename, "alpha_damage", false))
	{
		return ZR_CLASS_ALPHA_DAMAGE;
	}
	else if (StrEqual(attributename, "overlay_path", false))
	{
		return ZR_CLASS_OVERLAY_PATH;
	}
	else if (StrEqual(attributename, "nvgs", false))
	{
		return ZR_CLASS_NVGS;
	}
	else if (StrEqual(attributename, "fov", false))
	{
		return ZR_CLASS_FOV;
	}
	else if (StrEqual(attributename, "has_napalm", false))
	{
		return ZR_CLASS_HAS_NAPALM;
	}
	else if (StrEqual(attributename, "napalm_time", false))
	{
		return ZR_CLASS_NAPALM_TIME;
	}
	else if (StrEqual(attributename, "immunity_mode", false))
	{
		return ZR_CLASS_IMMUNITY_MODE;
	}
	else if (StrEqual(attributename, "immunity_amount", false))
	{
		return ZR_CLASS_IMMUNITY_AMOUNT;
	}
	else if (StrEqual(attributename, "immunity_cooldown", false))
	{
		return ZR_CLASS_IMMUNITY_COOLDOWN;
	}
	else if (StrEqual(attributename, "no_fall_damage", false))
	{
		return ZR_CLASS_NO_FALL_DAMAGE;
	}
	else if (StrEqual(attributename, "health", false))
	{
		return ZR_CLASS_HEALTH;
	}
	else if (StrEqual(attributename, "health_regen_interval", false))
	{
		return ZR_CLASS_HEALTH_REGEN_INTERVAL;
	}
	else if (StrEqual(attributename, "health_regen_amount", false))
	{
		return ZR_CLASS_HEALTH_REGEN_AMOUNT;
	}
	else if (StrEqual(attributename, "health_infect_gain", false))
	{
		return ZR_CLASS_HEALTH_INFECT_GAIN;
	}
	else if (StrEqual(attributename, "kill_bonus", false))
	{
		return ZR_CLASS_KILL_BONUS;
	}
	else if (StrEqual(attributename, "speed", false))
	{
		return ZR_CLASS_SPEED;
	}
	else if (StrEqual(attributename, "knockback", false))
	{
		return ZR_CLASS_KNOCKBACK;
	}
	else if (StrEqual(attributename, "jump_height", false))
	{
		return ZR_CLASS_JUMP_HEIGHT;
	}
	else if (StrEqual(attributename, "jump_distance", false))
	{
		return ZR_CLASS_JUMP_DISTANCE;
	}
	
	// Invalid attribute name.
	return -1;
}

/**
 * Converts a attribute name to a multiplier type.
 *
 * @param attributename	 The attribute name.
 * @return				  The multiplier that represent the specified attribute.
 *						  ClassM_Invalid if failed.
 */
stock ClassMultipliers ClassAttributeNameToMultiplier(const char[] attributename)
{
	// Check attribute names.
	if (StrEqual(attributename, "napalm_time", false))
	{
		return ClassM_NapalmTime;
	}
	else if (StrEqual(attributename, "health", false))
	{
		return ClassM_Health;
	}
	else if (StrEqual(attributename, "health_regen_interval", false))
	{
		return ClassM_HealthRegenInterval;
	}
	else if (StrEqual(attributename, "health_regen_amount", false))
	{
		return ClassM_HealthRegenAmount;
	}
	else if (StrEqual(attributename, "health_infect_gain", false))
	{
		return ClassM_HealthInfectGain;
	}
	else if (StrEqual(attributename, "speed", false))
	{
		return ClassM_Speed;
	}
	else if (StrEqual(attributename, "knockback", false))
	{
		return ClassM_Knockback;
	}
	else if (StrEqual(attributename, "jump_height", false))
	{
		return ClassM_JumpHeight;
	}
	else if (StrEqual(attributename, "jump_distance", false))
	{
		return ClassM_JumpDistance;
	}
	
	// Invalid attribute name or not a multiplier.
	return ClassM_Invalid;
}

/**
 * Returns the datatype used in the specified attribute.
 *
 * @param attributeflag	 A flag specifying the attribute to check.
 * @return	  The data type used in the specified attribute, or
 *			  ClassType_InvalidType if failed.
 */
stock ClassDataTypes ClassGetAttributeType(int attributeflag)
{
	switch (attributeflag)
	{
		// Boolean.
		case ZR_CLASS_ENABLED,
			  ZR_CLASS_NVGS,
			  ZR_CLASS_HAS_NAPALM,
			  ZR_CLASS_NO_FALL_DAMAGE:
		{
			return ClassDataType_Boolean;
		}
		
		// Integer.
		case ZR_CLASS_FLAGS,
			  ZR_CLASS_MODEL_SKIN_INDEX,
			  ZR_CLASS_ALPHA_INITIAL,
			  ZR_CLASS_ALPHA_DAMAGED,
			  ZR_CLASS_ALPHA_DAMAGE,
			  ZR_CLASS_FOV,
			  ZR_CLASS_IMMUNITY_AMOUNT,
			  ZR_CLASS_IMMUNITY_COOLDOWN,
			  ZR_CLASS_HEALTH,
			  ZR_CLASS_HEALTH_REGEN_AMOUNT,
			  ZR_CLASS_HEALTH_INFECT_GAIN,
			  ZR_CLASS_KILL_BONUS:
		{
			return ClassDataType_Integer;
		}
		
		// Float.
		case ZR_CLASS_NAPALM_TIME,
			  ZR_CLASS_HEALTH_REGEN_INTERVAL,
			  ZR_CLASS_SPEED,
			  ZR_CLASS_KNOCKBACK,
			  ZR_CLASS_JUMP_HEIGHT,
			  ZR_CLASS_JUMP_DISTANCE:
		{
			return ClassDataType_Float;
		}
		
		// String.
		case ZR_CLASS_GROUP,
			  ZR_CLASS_NAME,
			  ZR_CLASS_DESCRIPTION,
			  ZR_CLASS_MODEL_PATH,
			  ZR_CLASS_OVERLAY_PATH,
			  ZR_CLASS_IMMUNITY_MODE:
		{
			return ClassDataType_String;
		}
	}
	
	// Invalid flag or multiple flags combined.
	return ClassDataType_InvalidType;
}
