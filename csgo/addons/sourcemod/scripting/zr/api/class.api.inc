/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  class.api.inc
 *  Type:		  Core
 *  Description:   Native handlers for the ZR API. (Class module)
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
 * Initializes all natives and forwards related to infection.
 */
void APIClassInit()
{
	// Class module natives/forwards (class.zr.inc)
	
	// Natives
	CreateNative("ZR_IsValidClassIndex", APIIsValidClassIndex);
	CreateNative("ZR_GetActiveClass", APIGetActiveClass);
	CreateNative("ZR_SelectClientClass", APISelectClientClass);
	CreateNative("ZR_GetClassByName", APIGetClassByName);
	CreateNative("ZR_GetClassDisplayName", APIGetClassDisplayName);
}

/**
 * Native call function (ZR_IsValidClassIndex)
 *
 * bool:ZR_IsValidClassIndex(classIndex);
 */
public int APIIsValidClassIndex(Handle plugin, int numParams)
{
	int classIndex = GetNativeCell(1);
	
	return ClassValidateIndex(classIndex);
}

/**
 * Native call function (ZR_GetActiveClass)
 *
 * native bool:ZR_GetActiveClass(client);
 */
public int APIGetActiveClass(Handle plugin, int numParams)
{
	int  client = GetNativeCell(1);
	
	// Validate the client index. Player must be alive.
	APIValidateClientIndex(client, Condition_True);
	
	return ClassGetActiveIndex(client);
}

/**
 * Native call function (ZR_SelectClientClass)
 *
 * native ClassSelectResult:ZR_SelectClientClass(client, classIndex, bool:applyIfPossible = true, bool:saveIfEnabled = true)
 */
public int APISelectClientClass(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int classIndex = GetNativeCell(2);
	bool applyIfPossible = view_as<bool>(GetNativeCell(3));
	bool saveIfEnabled = view_as<bool>(GetNativeCell(4));
	
	// Validate the client index.
	APIValidateClientIndex(client, Condition_Either);
	
	// Validate class index.
	if (!ClassValidateIndex(classIndex))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid class index. (%d)", classIndex);
		return -1;
	}
	
	return view_as<int>(ClassSelectClientClass(client, classIndex, applyIfPossible, saveIfEnabled));
}

/**
 * Native call function (ZR_GetClassByName)
 *
 * native ZR_GetClassByName(const String:className[], cacheType = ZR_CLASS_CACHE_MODIFIED);
 */
public int APIGetClassByName(Handle plugin, int numParams)
{
	char className[64];
	className[0] = 0;
	
	// Get class name.
	if (GetNativeString(1, className, sizeof(className)) != SP_ERROR_NONE)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Unexpected error when reading className parameter. Possibly corrupt or missing data.");
		return -1;
	}
	
	int cacheType = GetNativeCell(2);
	if (cacheType == ZR_CLASS_CACHE_PLAYER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid cache type. Player cache is not allowed in this function.");
		return -1;
	}
	
	return ClassGetIndex(className, cacheType);
}

/**
 * Native call function (ZR_GetClassDisplayName)
 *
 * native ZR_GetClassDisplayName(classIndex, String:buffer[], maxlen, cacheType = ZR_CLASS_CACHE_MODIFIED);
 */
public int APIGetClassDisplayName(Handle plugin, int numParams)
{
	int index = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	int cacheType = GetNativeCell(4);
	
	if (maxlen <= 0)
	{
		// No buffer size.
		return 0;
	}
	
	// Validate index.
	if (cacheType == ZR_CLASS_CACHE_PLAYER)
	{
		// Client index.
		APIValidateClientIndex(index, Condition_Either);
	}
	else
	{
		// Class index.
		if (!ClassValidateIndex(index))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid class index. (%d)", index);
			return 0;
		}
	}
	
	//char displayName[maxlen];
	char displayName[64];
	
	int bytes = ClassGetName(index, displayName, maxlen, cacheType);
	if (bytes <= 0)
	{
		// The class doesn't have a name for some reason. Make sure the buffer is empty.
		displayName[0] = 0;
	}
	
	SetNativeString(2, displayName, maxlen);
	
	return bytes;
}
