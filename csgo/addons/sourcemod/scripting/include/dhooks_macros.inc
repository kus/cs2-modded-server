#if defined _dhooks_macros_include
#endinput
#else
#define _dhooks_macros_include
#endif

#if !defined SNAME
#define __SNAME ""
#else
#define __SNAME SNAME
#endif

#define ASSERT_FMT_STRING_LEN 512

#define ASSERT(%1,%2) if(%1) SetFailState(__SNAME...%2)
stock void ASSERT_FMT(bool result, char[] fmt, any ...)
{
	if(result)
	{
		char buff[ASSERT_FMT_STRING_LEN];
		VFormat(buff, sizeof(buff), fmt, 3);
		
		SetFailState(__SNAME..."%s", buff);
	}
}

/**
* Setups detour dhook (Handle DHOOK, CallingConvention, ReturnType, ThisPointerType, Handle GCONF, SDKFuncConfSource, char[] GCONF_NAME)
*/
#define DHOOK_SETUP_DETOUR(%1,%2,%3,%4,%5,%6,%7) Handle %1 = DHookCreateDetour(Address_Null,%2,%3,%4); \
ASSERT(!%1, "Failed to create detour. ["...%7..."]"); \
ASSERT(!DHookSetFromConf(%1,%5,%6,%7), "Failed to set from conf. ["...%7..."]")

/**
* Setups offset dhook (Handle DHOOK, HookType, ReturnType, ThisPointerType, DhookCallback, Handle GCONF, char[] GCONF_NAME)
*/
#define DHOOK_SETUP(%1,%2,%3,%4,%5,%6,%7) Handle %1 = DHookCreate(GameConfGetOffset(%6, %7), %2, %3, %4, %5); \
ASSERT(!%1, "Failed to create dhook. ["...%7..."]")

/**
* Setups gameconfig (Handle GCONF, Filename)
*/
#define SETUP_GAMECONF(%1,%2) Handle %1 = LoadGameConfigFile(%2); \
ASSERT(!%1, "Failed to open \""...%2...".txt\"")

