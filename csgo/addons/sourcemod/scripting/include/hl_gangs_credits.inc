#if defined hl_gangs_credits_include
  #endinput
#endif
#define hl_gangs_credits_include
 

/**
 * Returns the client's credit ammount
 *
 * @param	client			client index
 * @return  int				credits
 */
native int Gangs_GetCredits(int client)

/**
 * Sets a client's credit ammount
 *
 * @param	client			client index
 * @param	amount			credits to give
 * @return  no return
 */
native void Gangs_SetCredits(int client, int amount);


public SharedPlugin __pl_hl_gangs_credits =
{
	name = "hl_gangs_credits",
	file = "hl_gangs_credits.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_hl_gangs_credits_SetNTVOptional()
{	
	MarkNativeAsOptional("Gangs_GetCredits");
	MarkNativeAsOptional("Gangs_SetCredits");
}
#endif 