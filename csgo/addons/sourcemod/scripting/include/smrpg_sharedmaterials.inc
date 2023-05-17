#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

/**
 * Loads the smrpg_sharedmaterials.games gamedata file and errors if it fails.
 */
stock void SMRPG_GC_CheckSharedMaterialsAndSounds(const char[] sGameDataFile = "smrpg_sharedmaterials.games")
{
	if(SMRPG_GC_GetSMRPGGameData(sGameDataFile) == null)
		SetFailState("Missing required gamedata %s!", sGameDataFile);
}

/**
 * Gets a keyvalue from the smrpg_sharedmaterials.games gameconfig file.
 * 
 * @param key	The key to search for in the gamedata file.
 * @return		The value of the key in the gamedata file.
 */
stock char[] SMRPG_GC_GetKeyValue(const char[] key)
{
	char sBuffer[PLATFORM_MAX_PATH];
	GameConfGetKeyValue(SMRPG_GC_GetSMRPGGameData(), key, sBuffer, sizeof(sBuffer));
	return sBuffer;
}

/**
 * Precaches the model and caches the model index.
 * 
 * @param key	The key of the modelpath in the gamedata file.
 * @return		Modelindex of the precached model.
 */
stock int SMRPG_GC_PrecacheModel(const char[] key)
{
	char sBuffer[PLATFORM_MAX_PATH];
	sBuffer = SMRPG_GC_GetKeyValue(key);
	int iIndex = -1;
	if(sBuffer[0] != '\0')
	{
		iIndex = PrecacheModel(sBuffer);
		SetTrieValue(SMRPG_GC_GetGameDataCache(), key, iIndex);
	}
	return iIndex;
}

/**
 * Precaches a sound from the gamedata file.
 * 
 * @param key	The key of the soundpath in the gamedata file.
 * @return		True if precached successfully, false otherwise.
 */
stock bool SMRPG_GC_PrecacheSound(const char[] key)
{
	char sBuffer[PLATFORM_MAX_PATH];
	sBuffer = SMRPG_GC_GetKeyValue(key);
	bool bSuccess;
	if(sBuffer[0] != '\0')
	{
		bSuccess = PrecacheSound(sBuffer, true);
	}
	return bSuccess;
}

/**
 * Gets the model index of a precached model in the gamedata file.
 * 
 * @param key	The key of the model in the gamedata file.
 * @return		The precached model index if it was precached, -1 if not precached or failed.
 */
stock int SMRPG_GC_GetPrecachedIndex(const char[] key)
{
	int iValue = -1;
	GetTrieValue(SMRPG_GC_GetGameDataCache(), key, iValue);
	return iValue;
}


/***********************************
 * INTERNAL
 ***********************************/

/**
 * Gets the Handle to the smrpg_sharedmaterials.games gameconfig.
 * 
 * @return Handle to the smrpg_sharedmaterials.games gameconfig or null if not found.
 */
stock Handle SMRPG_GC_GetSMRPGGameData(const char[] sGameDataFile = "")
{
	static Handle hGameData = null;
	if(!hGameData && sGameDataFile[0] != '\0')
	{
		hGameData = LoadGameConfigFile(sGameDataFile);
	}
	
	return hGameData;
}

/**
 * Gets the Handle to the precached models indices trie.
 * 
 * @return Handle to the precached models indices trie.
 */
stock StringMap SMRPG_GC_GetGameDataCache()
{
	static StringMap hCache = null;
	if(!hCache)
	{
		hCache = new StringMap();
	}
	return hCache;
}