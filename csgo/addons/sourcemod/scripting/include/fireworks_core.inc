/**
 * Is firework plugin readed configs
 *
 * @return 						true if exists, false otherwise
 */
native bool:Fireworks_IsFireworksLoaded();

/**
 * Is firework with this name exists
 * 
 * @param	sFireworkName		firework name to check
 *
 * @return 						true if exists, false otherwise
 */
native bool:Fireworks_IsFireworkExists(const String:sFireworkName[]);

/**
 * Spawns firework with given parametrs
 * 
 * @param	sFireworkName		firework name
 * @param	vOrigin				origin to spawn
 * @param	vDirectionAngles	direction angles
 *
 * @noreturn 					
 */
native Fireworks_SpawnFirework(const String:sFireworkName[], const Float:vOrigin[3], const Float:vDirectionAngles[3]={0.0, 0.0, 0.0});

/**
 * Get array with firework names
 * Do not close or edit handle unless you know what you doing
 * 
 * @return 						handle to array with firework names
 */
native Handle:Fireworks_GetFireworksNames();

/**
 * Reload fireworks_setttings.txt
 * 
 * @noreturn 					
 */
native Fireworks_ReloadFireworks();

/**
 * Called when fireworks configs are readed
 * 
 * @noreturn 					
 */
functag public Fireworks_OnFireworksLoaded();

/**
 * Max length of firework name
 */
#define LENGTH_FIREWORK_NAME		64

/**
 * DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU DO
 * -------------------------------------------------------
 */
public SharedPlugin __pl_fireworks_core = 
{
	name = "fireworks_core",
	file = "fireworks_core.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
 
#if !defined REQUIRE_PLUGIN
public void __pl_fireworks_core_SetNTVOptional()
{
	MarkNativeAsOptional("Fireworks_IsFireworksLoaded");
	MarkNativeAsOptional("Fireworks_IsFireworkExists");
	MarkNativeAsOptional("Fireworks_SpawnFirework");
	MarkNativeAsOptional("Fireworks_GetFireworksNames");
	MarkNativeAsOptional("Fireworks_ReloadFireworks");
}
#endif