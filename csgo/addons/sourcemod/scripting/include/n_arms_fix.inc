#if defined n_arms_fix_include
  #endinput
#endif
#define n_arms_fix_include

/**
 * Called when default mode/arms are ready
 *
 * @param	client			client index
 * @return  no return
 */
forward void N_ArmsFix_OnClientReady(int client);

/**
 * Set default model & arms
 *
 * @param	client			client index
 * @return  no return
 */
native int N_ArmsFix_SetClientDefaults(int client);

/**
 * Set default model
 *
 * @param	client			client index
 * @return  no return
 */
native int N_ArmsFix_SetClientDefaultModel(int client);

/**
 * Set default arms
 *
 * @param	client			client index
 * @return  no return
 */
native int N_ArmsFix_SetClientDefaultArms(int client);

/**
 * Has default arms?
 *
 * @param	client			client index
 * @return  true/false
 */
native int N_ArmsFix_HasClientDefaultArms(int client);

public SharedPlugin n_arms_fix_include_shared =
{
	name = "-N- Arms Fix",
	file = "n_arms_fix.smx",
	#if defined REQUIRE_PLUGIN
		required = 1
	#else
		required = 0
	#endif
};