#if defined _customweapons_included
 #endinput
#endif
#define _customweapons_included

// Enumeration for weapon entity model types.
enum CustomWeapon_ModelType
{
    CustomWeaponModel_View,		/* Visible to the weapon owner only */
    CustomWeaponModel_World,	/* General model when the weapon isn't equipped by the owner */
    CustomWeaponModel_Dropped	/* Ground model */
}

/**
 * 	Called before a custom model is set on a weapon entity.
 *	
 *	@param client			Weapon owner client index. (0 if model_type == CustomWeaponModel_Dropped)
 *	@param weapon			Weapon entity index.
 *	@param model_type		Whether the model is view, world, dropped. See the enum above.
 *  @param model			Model file path. Changeable.
 *  
 *  @return             	An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       	Returning Plugin_Stop bypasses the post hook as well as the game function.
*/
typedef ModelHookCallback = function Action (int client, int weapon, CustomWeapon_ModelType model_type, char model[PLATFORM_MAX_PATH]);

/**
 * 	Called before a custom weapon sound is emited.
 *	
 *	@param client			Weapon owner client index.
 *	@param weapon			Weapon entity index.
 *  @param model			Sound file path. Changeable.
 *  
 *  @return             	An Action value. Returning Plugin_Handled bypasses the game function call.
 *                       	Returning Plugin_Stop bypasses the post hook as well as the game function.
*/
typedef SoundHookCallback = function Action (int client, int weapon, char sound[PLATFORM_MAX_PATH]);

methodmap CustomWeapon
{
	// Constructor of CustomWeapon. Can be used to manipulate features of a weapon entity.
	//
	// Note that this object is representing an entity reference and NOT a handle, 
	// which means that there's no need to delete it after use.
	//
	// @param entity     	The weapon entity index to perform customizations on.
	// 						This value can be accessed by many ways; most common
	//						ones are 'GetPlayerWeaponSlot()' / m_hActiveWeapon netprop /'GivePlayerItem()'.
	//
	// @return              CustomWeapon instance to the given entity, or 0 on failure.
	public native CustomWeapon(int entity);
	
	// Retrieves the weapon raw entity index.
    //
    // This native can be used to determine whether this
    // CustomWeapon data is still valid and available to use.
    //
    // Note that if this native returns -1, this means that this CustomWeapon
    // data is corrupted and can no longer be used!
    //
    // @return             Weapon entity index, or -1 if the entity is no longer available.
    property int EntityIndex
    {
        public native get();
    }
	
	// Customize the weapon model. (view, world, dropped)
	//
	// Note that the model must be precached before using this function.
	//
	// @param model_type    Model type to apply the new model on. See the enum above.
	// @param source    	New weapon model file path.
	//
	// @error				Invalid 'CustomWeapon', invalid model type, or the given model isn't precached.
	public native void SetModel(CustomWeapon_ModelType model_type, const char source[PLATFORM_MAX_PATH]);
	
	// Retrieves the weapon model. (view, world, dropped)
	//
	// Note that this native will only return models that are customized.
	// This will return a null terminated string if no custom model is set.
	//
	// @param model_type    Model type to apply the new model on. See the enum above.
	// @param buffer        Destination string buffer.
	// @param maxlength     Maximum length of output string buffer.
	//
	// @return              Number of cells written.
	// @error				Invalid 'CustomWeapon' or invalid model type.
	public native int GetModel(CustomWeapon_ModelType model_type, char[] buffer, int maxlength);
	
	// Customize the weapon shot sound. (both client and server side)
	//
	// Note that the sound should be precached before using this function.
	//
	// @param source    	New weapon shot sound file path.
	//
	// @error				Invalid 'CustomWeapon', or the given sound isn't precached.
	public native void SetShotSound(const char source[PLATFORM_MAX_PATH]);
	
	// Retrieves the weapon shot sound.
	//
	// The buffer will be a null terminated string
	// if there is no a custom shot sound set.
	//
	// @param buffer        Destination string buffer.
	// @param maxlength     Maximum length of output string buffer.
	//
	// @return              Number of cells written.
	// @error				Invalid 'CustomWeapon'
	public native int GetShotSound(char[] buffer, int maxlength);
	
	// Advanced API natives.
	// See the prototypes above for callback documentation.
	
	public native void AddModelHook(ModelHookCallback callback);
	
	public native void RemoveModelHook(ModelHookCallback callback);
	
	public native void AddSoundHook(SoundHookCallback callback);
	
	public native void RemoveSoundHook(SoundHookCallback callback);
}

#if !defined REQUIRE_PLUGIN
public void __pl_customweapons_SetNTVOptional()
{
	MarkNativeAsOptional("CustomWeapon.CustomWeapon");
	MarkNativeAsOptional("CustomWeapon.EntityIndex.get");
	MarkNativeAsOptional("CustomWeapon.SetModel");
	MarkNativeAsOptional("CustomWeapon.GetModel");
	MarkNativeAsOptional("CustomWeapon.SetShotSound");
	MarkNativeAsOptional("CustomWeapon.GetShotSound");
	MarkNativeAsOptional("CustomWeapon.AddModelHook");
	MarkNativeAsOptional("CustomWeapon.RemoveModelHook");
	MarkNativeAsOptional("CustomWeapon.AddSoundHook");
	MarkNativeAsOptional("CustomWeapon.RemoveSoundHook");
}
#endif

public SharedPlugin __pl_customweapons = 
{
	name = "customweapons", 
	file = "customweapons.smx", 
#if defined REQUIRE_PLUGIN
    required = 1, 
#else
    required = 0, 
#endif
};
