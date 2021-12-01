#if defined _prophunt_included
  #endinput
#endif
#define _prophunt_included

/* Forwards */

/**
 * Called when a seeker has been spawned.
 *
 * @param seeker		The seeker's client index.
 */
forward void PH_OnSeekerSpawn(int seeker);

/**
 * Called when a seeker got killed.
 *
 * @param seeker		The seeker's client index.
 * @param hider			The hider's client index.
 */
forward void PH_OnSeekerDeath(int seeker, int hider);

/**
 * Called once per round when seekers are allowed to move.
 *
 */
forward void PH_OnFreezeTimeEnd();

/**
 * Called when a hider has been spawned.
 * Right before the hider is is prepared.
 *
 * @param hider			The hider's client index.
 */
forward void PH_OnHiderSpawn(int hider);

/**
 * Called when a hider has been spawned and prepared.
 * Right after the hider is is prepared.
 *
 * @param hider			The hider's client index.
 */
forward void PH_OnHiderReady(int hider);

/**
 * Called when a hider changed his model.
 *
 * @param hider			The hider's client index.
 */
forward void PH_OnHiderSetModel(int hider);

/**
 * Called when a hider got killed.
 *
 * @param hider			The hider's client index.
 * @param seeker		The seeker's client index.
 */
forward void PH_OnHiderDeath(int hider, int seeker);

/**
 * Called when a hider is about to freeze.
 *
 * @param hider			The hider's client index.
 * @return 				>= Plugin_Handled to stop the player from freezing.
 */
forward Action PH_OnHiderFreeze(int client);

/**
 * Called when a hider un-freezes.
 *
 * @param hider			The hider's client index.
 */
forward void PH_OnHiderUnFreeze(int client);

/**
 * Called when a player opens the taunt menu.
 *
 * @param client			The players's client index.
 * @return 				Plugin_Handled or Plugin_Stop to block the menu.
 */
forward Action PH_OnOpenTauntMenu(int client);

/**
 * Called when a hider is about to taunt.
 *
 * @param hider			The hider's client index.
 * @param soundln		Length of the sound file.
 * @return 				>= Plugin_Changed to stop the player from playing the sound, Plugin_Continue to allow & Plugin_Changed to stop the sound but broadcast.
 */
forward Action PH_OnTauntPre(int hider, float &soundln);

/**
 * Called when a hider has whistled.
 *
 * @param hider			The hider's client index.
 * @param soundln		Length of the sound file.
 */
forward void PH_OnTaunt(int hider, float soundln);

/**
 * Called when someone is about to force someone to whistle.
 *
 * @param client			The client index.
 * @param hider			The hider's client index.
 * @param soundln		Length of the sound file.
 * @return 				>= Plugin_Changed to stop the player from playing the sound, Plugin_Continue to allow & Plugin_Changed to stop the sound but broadcast.
 */
forward Action PH_OnForceTauntPre(int client, int hider, float &soundln);

/**
 * Called when someone to whistled.
 *
 * @param client			The client index.
 * @param hider			The hider's client index.
 * @param soundln		Length of the sound file.
 */
forward void PH_OnForceTaunt(int client, int hider, float soundln);

/**
 * Called when a seeker used a weapon.
 *
 * @param seeker		The seeker's client index.
 * @param weapon		The used weapon index.
 * @param weaponType	The used weapon type.
 * @param takeHealth	If takeHealth < 1 no damage is done.
 */
forward void PH_OnSeekerUseWeapon(int seeker, int weapon, int weaponType, int &takeHealth);

/**
 * Called when a hider got hit by a seeker.
 *
 * @param hider			The hider's client index.
 * @param seeker		The seeker's client index.
 * @param weapon		The used weapon index index.
 * @param lethal			Set if hider would die.
 * @param damage		Damage done to the hider.
 * @param bonus		Seeker bonus health for hitting/killing a hider.
 * @param take			How much health the shot costs the seeker and will be taken from his health.
 */
forward void PH_OnHiderHit(int hider, int seeker, int weapon, bool lethal, float &damage, int &bonus, int &take);

/**
 * Called before the modelmenu is generated for a hider.
 *
 * @param hider			The hider's client index.
 * @param numModels	Num of models to use.
 *
 */
forward void PH_OnBuildModelMenu(int hider, int &numModels);

/**
 * Called when someone buys an item.
 *
 * @param client			The client index.
 * @param name		Item name.
 * @param Points		Amount of Points spend.
 * @return 				Return Plugin_Handled to confirm execution. 
 */
forward Action PH_OnBuyShopItem(int client, char[] name, int &points);

/**
 * Called when someone bought an item.
 *
 * @param client			The client index.
 * @param name		Item name.
 * @param Points		Amount of Points spend.
 * @noreturn 			
 */
forward void PH_OnBuyShopItemPost(int client, char[] name, int points);

/* Natives */

native bool PH_IsFrozen(int client);
native int PH_CanChangeModel();
native int PH_GetModelChangeCount(int client);

native bool PH_DisableFakeProp(int client); //Until next spawn
native bool PH_IsFakePropBlocked(int client);
native int PH_GetFakeProp(int client);

native void PH_GetModelName(int index, char name[32]);
native void PH_GetModelPath(int index, char model[PLATFORM_MAX_PATH]);
native void PH_GetModelOffset(int index, float offset[3]);
native void PH_GetModelAngles(int index, float angles[3]);
native void PH_GetModelColor(int index, int color[4]);

native void PH_GetModelSpeed(int index, float &speed);
native void PH_GetModelGravity(int index, float &gravity);
native int PH_GetModelSkin(int index);
native int PH_GetModelHealth(int index);

native void PH_GetClientModelName(int client, char name[32]);
native void PH_GetClientModelPath(int client, char model[PLATFORM_MAX_PATH]);
native void PH_GetClientModelOffset(int client, float offset[3]);
native void PH_GetClientModelAngles(int client, float angles[3]);
native void PH_GetClientModelColor(int client, int color[4]);

native void PH_GetClientModelSpeed(int client, float &speed);
native void PH_GetClientModelGravity(int client, float &gravity);
native int PH_GetClientModelSkin(int client);
native int PH_GetClientModelHealth(int client);

native int PH_ForceTaunt(int client, int forcer);
native int PH_GetTauntCooldown(int client);
native int PH_GetTauntCooldownLength(int client);

native float PH_GetClientFreezeAngles(int client, float &angle);

native float PH_GetPoints(int client);
native float PH_SetPoints(int client, float points);
native float PH_GivePoints(int client, float points);
native float PH_TakePoints(int client, float points);

native int PH_RegisterShopItem(char name[32], int team, int points, int sort, int unlockTime, bool reqFrozen);

native void PH_DisableShopItem(char name[32], int client);
native void PH_DisableShopItemForAll(char name[32]);
native void PH_EnableShopItem(char name[32], int client);
native void PH_EnableShopItemForAll(char name[32]);

public void __pl_prophunt_SetNTVOptional() 
{
	MarkNativeAsOptional("PH_IsFrozen");
	MarkNativeAsOptional("PH_CanChangeModel");
	MarkNativeAsOptional("PH_GetModelChangeCount");
	MarkNativeAsOptional("PH_DisableFakeProp");
	MarkNativeAsOptional("PH_IsFakePropBlocked");
	MarkNativeAsOptional("PH_GetFakeProp");
	MarkNativeAsOptional("PH_GetModelName");
	MarkNativeAsOptional("PH_GetModelPath");
	MarkNativeAsOptional("PH_GetModelOffset");
	MarkNativeAsOptional("PH_GetModelAngles");
	MarkNativeAsOptional("PH_GetModelColor");
	MarkNativeAsOptional("PH_GetModelSpeed");
	MarkNativeAsOptional("PH_GetModelGravity");
	MarkNativeAsOptional("PH_GetModelSkin");
	MarkNativeAsOptional("PH_GetModelHealth");
	MarkNativeAsOptional("PH_GetClientModelName");
	MarkNativeAsOptional("PH_GetClientModelPath");
	MarkNativeAsOptional("PH_GetClientModelOffset");
	MarkNativeAsOptional("PH_GetClientModelAngles");
	MarkNativeAsOptional("PH_GetClientModelColor");
	MarkNativeAsOptional("PH_GetClientModelSpeed");
	MarkNativeAsOptional("PH_GetClientModelGravity");
	MarkNativeAsOptional("PH_GetClientModelSkin");
	MarkNativeAsOptional("PH_GetClientModelHealth");
	MarkNativeAsOptional("PH_IsFrozen");
	MarkNativeAsOptional("PH_ForceTaunt");
	MarkNativeAsOptional("PH_GetTauntCooldown");
	MarkNativeAsOptional("PH_GetTauntCooldownLength");
	MarkNativeAsOptional("PH_GetClientFreezeAngles");
	MarkNativeAsOptional("PH_GetPoints");
	MarkNativeAsOptional("PH_SetPoints");
	MarkNativeAsOptional("PH_GivePoints");
	MarkNativeAsOptional("PH_TakePoints");
	MarkNativeAsOptional("PH_RegisterShopItem");
	MarkNativeAsOptional("PH_DisableShopItem");
	MarkNativeAsOptional("PH_DisableShopItemForAll");
	MarkNativeAsOptional("PH_EnableShopItem");
	MarkNativeAsOptional("PH_EnableShopItemForAll");
}

public SharedPlugin __pl_prophunt = 
{
    name = "prophunt", // Plugin library name
    file = "prophunt.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0
#endif
};  