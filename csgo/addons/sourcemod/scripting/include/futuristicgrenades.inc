#if defined futuristicgrenades_include
  #endinput
#endif
#define futuristicgrenades_include

enum DecoyMode
{
	DecoyMode_Normal = 0,
	DecoyMode_Blackhole,
	DecoyMode_Forcefield,
	DecoyMode_ForceExplosion,
	DecoyMode_ForceImplosion,
	DecoyMode_Max
}

enum ForceFieldMode
{
	ForcefieldMode_Normal = 0,
	ForcefieldMode_Self,
	ForcefieldMode_Max
}

enum ForceExplosionMode
{
	ForceExplosionMode_Ground = 0,
	ForceExplosionMode_World,
	ForceExplosionMode_Max
}

enum ForceImplosionMode
{
	ForceImplosionMode_Ground = 0,
	ForceImplosionMode_World,
	ForceImplosionMode_Max
}

/**
 * Returns if friendly fire is activated
 *
 * @return  bool				friendly fire convar
 */
native bool FGrenades_IsFriendlyFire();

/**
 * Returns clients grenade mode
 *
 * @return  DecoyMode			client decoy mode
 */
native DecoyMode FGrenades_GetMode(int client);

/**
 * Returns clients forcefield mode
 *
 * @return  ForceFieldMode		client forcefield mode
 */
native ForceFieldMode FGrenades_GetForcefieldMode(int client);

/**
 * Returns clients force explosion mode
 *
 * @return  ForceExplosionMode	client force explosion mode
 */
native ForceExplosionMode FGrenades_GetForceExplosionMode(int client);

/**
 * Returns clients force implosion mode
 *
 * @return  ForceImplosionMode	client force implosion mode
 */
native ForceImplosionMode FGrenades_GetForceImplosionMode(int client);

/**
 * Returns the amount of active black holes
 *
 * @return  int					amount of active black holes
 */
native int FGrenades_GetAmountBlackholes();

/**
 * Returns the amount of active force fields
 *
 * @return  int					amount of active force fields
 */
native int FGrenades_GetAmountForcefields();

/**
 * Called when a player throws a decoy grenade
 * @param client client index
 * @param entity decoy entity index
 * @param mode clients active mode
 * @noreturn
 */
forward void FGrenades_OnThrowGrenade(int client, int entity, DecoyMode mode);

/**
 * Called when a player dies inside a black hole
 * @param client client index
 * @param ragdoll ragdoll entity index (Will be killed same frame)
 * @noreturn
 */
forward void FGrenades_OnBlackHoleDeath(int client, int ragdoll);

/**
 * Called when either a blackhole or forcefield expires
 * @param client client index
 * @param mode grenade type
 * @noreturn
 */
forward void FGrenades_OnGrenadeExpire(float pos[3], DecoyMode mode);

/**
 * Called when a grenade hits the ground and bounces up
 * @param entity grenade entity index
 * @param mode grenade type
 * @noreturn
 */
forward void FGrenades_OnGrenadePreStart(int entity, DecoyMode mode);

/**
 * Called when a grenade starts
 * @param owner client index
 * @param particle entity reference
 * @param pos grenade origin
 * @param mode grenade type
 * @param duration duration of the grenade (Force explosion and implosion returns 0)
 * @noreturn
 */
forward void FGrenades_OnGrenadeStart(int owner, int &particle, float pos[3], DecoyMode mode, int duration);

/**
 * Called when client switches mode
 * @param client client index
 * @param previousmode previous grenade mode
 * @param newmode current grenade mode
 * @param weapon active weapon entity index
 * @return Plugin_Handled to prevent from switching modes, Plugin_Continue otherwise
 */
forward Action FGrenades_OnSwitchMode(int client, DecoyMode previousmode, DecoyMode &newmode, int weapon);


/**
 * Force a client to change the FNade mode
 * @param client client index
 * @param newDecoyMode   New mode of decoy
 * @param newForceFieldMode New mode of forcefield decoy
 * @param newForceExplosionMode New mode of ForceExplosion decoy
 * @param newForceImplosionMode New mode of ForceImplosion decoy
 */
native void FGrenades_SwitchMode(int client, DecoyMode newDecoyMode, ForceFieldMode newForceFieldMode = ForcefieldMode_Normal, ForceExplosionMode newForceExplosionMode = ForceExplosionMode_Ground, ForceImplosionMode newForceImplosionMode = ForceImplosionMode_Ground);

public SharedPlugin __pl_futuristicgrenades  =
{
	name = "futuristicgrenades",
	file = "futuristicgrenades.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_futuristicgrenades_SetNTVOptional()
{	
	MarkNativeAsOptional("FGrenades_IsFriendlyFire");
	MarkNativeAsOptional("FGrenades_GetMode");
	MarkNativeAsOptional("FGrenades_GetForcefieldMode");
	MarkNativeAsOptional("FGrenades_GetForceExplosionMode");
	MarkNativeAsOptional("FGrenades_GetForceImplosionMode");
	MarkNativeAsOptional("FGrenades_GetAmountBlackholes");
	MarkNativeAsOptional("FGrenades_GetAmountForcefields");
	MarkNativeAsOptional("FGrenades_SwitchMode");
}
#endif
