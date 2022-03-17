/*
	kztimer-momsurffix Plugin Include
	
	Website: https://bitbucket.org/kztimerglobalteam/kztimerglobal
*/

#if defined _kztimer_momsurffix_included_
#endinput
#endif
#define _kztimer_momsurffix_included_

// =====[ DEPENDENCY ]=====

public SharedPlugin __pl_kztimer_momsurffix = 
{
	name = "kztimer-momsurffix", 
	file = "kztimer-momsurffix.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};