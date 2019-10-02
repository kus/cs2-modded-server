#if defined _smlib_general_included
	#endinput
#endif
#define _smlib_general_included

#include <sourcemod>
#include <sdktools_stringtables>
#include <smlib/math>

#define TIME_TO_TICKS(%1)	( (int)( 0.5 + (float)(%1) / GetTickInterval() ) )
#define TICKS_TO_TIME(%1)	( GetTickInterval() * %1 )
#define ROUND_TO_TICKS(%1)	( TICK_INTERVAL * TIME_TO_TICKS( %1 ) )

/*
 * Precaches the given model.
 * It's best to call this OnMapStart().
 * 
 * @param material			Path of the material to precache.
 * @return					Returns the material index, INVALID_STRING_INDEX on error.
 */
stock PrecacheMaterial(const String:material[])
{
	static materialNames = INVALID_STRING_TABLE;

	if (materialNames == INVALID_STRING_TABLE) {
		if ((materialNames = FindStringTable("Materials")) == INVALID_STRING_TABLE) {
			return INVALID_STRING_INDEX;
		}
	}
	
	new index = FindStringIndex2(materialNames, material);
	if (index == INVALID_STRING_INDEX) {
		new numStrings = GetStringTableNumStrings(materialNames);
		if (numStrings >= GetStringTableMaxStrings(materialNames)) {
			return INVALID_STRING_INDEX;
		}
		
		AddToStringTable(materialNames, material);
		index = numStrings;
	}
	
	return index;
}

/*
 * Checks if the material is precached.
 * 
 * @param material			Path of the material.
 * @return					True if it is precached, false otherwise.
 */
stock bool:IsMaterialPrecached(const String:material[])
{
	static materialNames = INVALID_STRING_TABLE;

	if (materialNames == INVALID_STRING_TABLE) {
		if ((materialNames = FindStringTable("Materials")) == INVALID_STRING_TABLE) {
			return false;
		}
	}
	
	return (FindStringIndex2(materialNames, material) != INVALID_STRING_INDEX);
}

/*
 * Precaches the given particle system.
 * It's best to call this OnMapStart().
 * Code based on Rochellecrab's, thanks.
 * 
 * @param particleSystem	Name of the particle system to precache.
 * @return					Returns the particle system index, INVALID_STRING_INDEX on error.
 */
stock PrecacheParticleSystem(const String:particleSystem[])
{
	static particleEffectNames = INVALID_STRING_TABLE;

	if (particleEffectNames == INVALID_STRING_TABLE) {
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) {
			return INVALID_STRING_INDEX;
		}
	}

	new index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX) {
		new numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames)) {
			return INVALID_STRING_INDEX;
		}
		
		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}
	
	return index;
}

/*
 * Checks if the particle system is precached.
 * 
 * @param material			Name of the particle system
 * @return					True if it is precached, false otherwise.
 */
stock bool:IsParticleSystemPrecached(const String:particleSystem[])
{
	static particleEffectNames = INVALID_STRING_TABLE;

	if (particleEffectNames == INVALID_STRING_TABLE) {
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) {
			return false;
		}
	}
	
	return (FindStringIndex2(particleEffectNames, particleSystem) != INVALID_STRING_INDEX);
}

/*
 * Searches for the index of a given string in a string table. 
 * 
 * @param table			String table name.
 * @param str			String to find.
 * @return				String index if found, INVALID_STRING_INDEX otherwise.
 */
stock FindStringIndexByTableName(const String:table[], const String:str[])
{
	new tableIndex = INVALID_STRING_TABLE;
	if ((tableIndex = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) {
		return INVALID_STRING_INDEX;
	}
	
	return FindStringIndex2(tableIndex, str);
}

/*
 * Rewrite of FindStringIndex, because in my tests
 * FindStringIndex failed to work correctly.
 * Searches for the index of a given string in a string table. 
 * 
 * @param tableidx		A string table index.
 * @param str			String to find.
 * @return				String index if found, INVALID_STRING_INDEX otherwise.
 */
stock FindStringIndex2(tableidx, const String:str[])
{
	decl String:buf[1024];

	new numStrings = GetStringTableNumStrings(tableidx);
	for (new i=0; i < numStrings; i++) {
		ReadStringTable(tableidx, i, buf, sizeof(buf));
		
		if (StrEqual(buf, str)) {
			return i;
		}
	}
	
	return INVALID_STRING_INDEX;
}

/*
 * Converts a long IP to a dotted format String.
 * 
 * @param ip			IP Long
 * @param buffer		String Buffer (size = 16)
 * @param size			String Buffer size
 * @noreturn
 */
stock LongToIP(ip, String:buffer[], size)
{
	Format(
		buffer, size,
		"%d.%d.%d.%d",
			(ip >> 24)	& 0xFF,
			(ip >> 16)	& 0xFF,
			(ip >> 8 )	& 0xFF,
			ip        	& 0xFF
		);
}

/*
 * Converts a dotted format String IP to a long.
 * 
 * @param ip			IP String
 * @return				Long IP
 */
stock IPToLong(const String:ip[])
{
	decl String:pieces[4][4];

	if (ExplodeString(ip, ".", pieces, sizeof(pieces), sizeof(pieces[])) != 4) {
		return 0;
	}

	return (
		StringToInt(pieces[0]) << 24	|
		StringToInt(pieces[1]) << 16	|
		StringToInt(pieces[2]) << 8		|
		StringToInt(pieces[3])
	);
}

static localIPRanges[] = 
{
	10	<< 24,				// 10.
	127	<< 24 | 1		,	// 127.0.0.1
	127	<< 24 | 16	<< 16,	// 127.16.
	192	<< 24 | 168	<< 16,	// 192.168.
};

/*
 * Checks whether an IP is a private/internal IP
 * 
 * @param ip			IP Long
 * @return				True if the IP is local, false otherwise.
 */
stock bool:IsIPLocal(ip)
{
	new range, bits, move, bool:matches;

	for (new i=0; i < sizeof(localIPRanges); i++) {

		range = localIPRanges[i];
		matches = true;

		for (new j=0; j < 4; j++) {
			move = j * 8;
			bits = (range >> move) & 0xFF;

			if (bits && bits != ((ip >> move) & 0xFF)) {
				matches = false;
			}
		}

		if (matches) {
			return true;
		}
	}

	return false;
}

/*
 * Closes the given hindle and sets it to INVALID_HANDLE.
 * 
 * @param handle   handle
 * @noreturn
 */
stock ClearHandle(&Handle:handle)
{
	if (handle != INVALID_HANDLE) {
		CloseHandle(handle);
		handle = INVALID_HANDLE;
	}
}
