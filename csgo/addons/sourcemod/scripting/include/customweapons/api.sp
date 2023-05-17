/*
 *  • Registeration of all natives and forwards.
 *  • Registeration of the plugin library.
 */

#if !defined COMPILING_FROM_MAIN
#error "Attemped to compile from the wrong file"
#endif

int ValidateCustomWeapon(CustomWeapon custom_weapon)
{
	int entity = EntRefToEntIndex(view_as<int>(custom_weapon));
	
	if (entity == INVALID_ENT_REFERENCE)
	{
		ThrowError("Invalid CustomWeapon");
	}
	
	return entity;
}

// Forward handles.
PrivateForward g_ModelHook;
PrivateForward g_SoundHook;

void InitializeAPI()
{
	CreateNatives();
	CreateForwards();
	
	RegPluginLibrary("customweapons");
}

// Natives
void CreateNatives()
{
	// CustomWeapon(int entity)
	CreateNative("CustomWeapon.CustomWeapon", Native_CustomWeapon);
	
	// property int EntityIndex
	CreateNative("CustomWeapon.EntityIndex.get", Native_GetEntityIndex);
	
	// void SetModel(CustomWeapon_ModelType model_type, const char[] source)
	CreateNative("CustomWeapon.SetModel", Native_SetModel);
	
	// int GetModel(CustomWeapon_ModelType model_type, char[] buffer, int maxlength)
	CreateNative("CustomWeapon.GetModel", Native_GetModel);
	
	// void SetShotSound(const char source[PLATFORM_MAX_PATH])
	CreateNative("CustomWeapon.SetShotSound", Native_SetShotSound);
	
	// int GetShotSound(char[] buffer, int maxlength)
	CreateNative("CustomWeapon.GetShotSound", Native_GetShotSound);
	
	// void AddModelHook(ModelHookCallback callback)
	CreateNative("CustomWeapon.AddModelHook", Native_AddModelHook);
	
	// void RemoveModelHook(ModelHookCallback callback)
	CreateNative("CustomWeapon.RemoveModelHook", Native_RemoveModelHook);
}

any Native_CustomWeapon(Handle plugin, int numParams)
{
	// Param 1: 'entity'
	int entity = GetNativeCell(1);
	
	if (!(0 <= entity <= GetMaxEntities()))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Entity index out of bounds. (%d)", entity);
	}
	
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Entity %d is not valid", entity);
	}
	
	if (!IsEntityWeapon(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Entity %d is not a valid weapon", entity);
	}
	
	int entity_reference = EntIndexToEntRef(entity);
	if (entity_reference == INVALID_ENT_REFERENCE)
	{
		return 0;
	}
	
	return view_as<CustomWeapon>(entity_reference);
}

any Native_GetEntityIndex(Handle plugin, int numParams)
{
	// Param 1: 'CustomWeapon' [this] / entity reference
	int entity_reference = GetNativeCell(1);
	
	if (!entity_reference)
	{
		return -1;
	}
	
	return EntRefToEntIndex(entity_reference);
}

any Native_SetModel(Handle plugin, int numParams)
{
	// Param 1: 'CustomWeapon' [this]
	CustomWeapon custom_weapon = GetNativeCell(1);
	
	int entity = ValidateCustomWeapon(custom_weapon);
	
	// Param 2: 'model_type'
	CustomWeapon_ModelType model_type = GetNativeCell(2);
	
	// Param 3: 'source'
	char source[PLATFORM_MAX_PATH];
	
	// Check for any errors.
	Native_CheckStringParamLength(3, "model file path", sizeof(source), true);
	
	GetNativeString(3, source, sizeof(source));
	
	int precache_index = GetModelPrecacheIndex(source);
	if (precache_index == INVALID_STRING_INDEX && model_type != CustomWeaponModel_Dropped)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Custom model is not precached (%s)", source);
	}
	
	CustomWeaponData custom_weapon_data;
	if (!custom_weapon_data.GetMyselfByReference(view_as<int>(custom_weapon)))
	{
		custom_weapon_data.plugin = plugin;
	}
	else if (custom_weapon_data.plugin != plugin)
	{
		ThrowNativeError(SP_ERROR_MEMACCESS, "Access violation");
	}
	
	switch (model_type)
	{
		case CustomWeaponModel_View:
		{
			custom_weapon_data.view_model = source;
			
			ReEquipWeaponEntity(entity);
		}
		case CustomWeaponModel_World:
		{
			custom_weapon_data.world_model = source;
			
			ReEquipWeaponEntity(entity);
		}
		case CustomWeaponModel_Dropped:
		{
			custom_weapon_data.dropped_model = source;
		}
		// Invalid model type, throw an expection.
		default:
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid model type (%d)", model_type);
		}
	}
	
	custom_weapon_data.UpdateMyself(view_as<int>(custom_weapon));
	
	return 0;
}

any Native_GetModel(Handle plugin, int numParams)
{
	// Param 1: 'CustomWeapon' [this]
	CustomWeapon custom_weapon = GetNativeCell(1);
	
	ValidateCustomWeapon(custom_weapon);
	
	// Param 2: 'model_type'
	CustomWeapon_ModelType model_type = GetNativeCell(2);
	
	CustomWeaponData custom_weapon_data;
	if (!custom_weapon_data.GetMyselfByReference(view_as<int>(custom_weapon)))
	{
		return 0;
	}
	else if (custom_weapon_data.plugin != plugin)
	{
		ThrowNativeError(SP_ERROR_MEMACCESS, "Access violation");
	}
	
	int maxlength = GetNativeCell(4);
	
	switch (model_type)
	{
		case CustomWeaponModel_View:
		{
			int num_bytes;
			SetNativeString(3, custom_weapon_data.view_model, maxlength, .bytes = num_bytes);
			
			return num_bytes;
		}
		case CustomWeaponModel_World:
		{
			int num_bytes;
			SetNativeString(3, custom_weapon_data.world_model, maxlength, .bytes = num_bytes);
			
			return num_bytes;
		}
		case CustomWeaponModel_Dropped:
		{
			int num_bytes;
			SetNativeString(3, custom_weapon_data.dropped_model, maxlength, .bytes = num_bytes);
			
			return num_bytes;
		}
		// Invalid model type, throw an expection.
		default:
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid model type (%d)", model_type);
		}
	}
	
	return 0;
}

any Native_SetShotSound(Handle plugin, int numParams)
{
	// Param 1: 'CustomWeapon' [this]
	CustomWeapon custom_weapon = GetNativeCell(1);
	
	ValidateCustomWeapon(custom_weapon);
	
	// Param 2: 'source'
	char source[PLATFORM_MAX_PATH];
	
	// Check for any errors.
	Native_CheckStringParamLength(2, "shot sound file path", sizeof(source), true);
	
	GetNativeString(2, source, sizeof(source));
	
	CustomWeaponData custom_weapon_data;
	if (!custom_weapon_data.GetMyselfByReference(view_as<int>(custom_weapon)))
	{
		custom_weapon_data.plugin = plugin;
	}
	else if (custom_weapon_data.plugin != plugin)
	{
		ThrowNativeError(SP_ERROR_MEMACCESS, "Access violation");
	}
	
	custom_weapon_data.shot_sound = source;
	
	custom_weapon_data.UpdateMyself(view_as<int>(custom_weapon));
	
	return 0;
}

any Native_GetShotSound(Handle plugin, int numParams)
{
	// Param 1: 'CustomWeapon' [this]
	CustomWeapon custom_weapon = GetNativeCell(1);
	
	ValidateCustomWeapon(custom_weapon);
	
	CustomWeaponData custom_weapon_data;
	if (!custom_weapon_data.GetMyselfByReference(view_as<int>(custom_weapon)))
	{
		return 0;
	}
	else if (custom_weapon_data.plugin != plugin)
	{
		ThrowNativeError(SP_ERROR_MEMACCESS, "Access violation");
	}
	
	int num_bytes;
	SetNativeString(2, custom_weapon_data.shot_sound, GetNativeCell(3), .bytes = num_bytes);
	
	return num_bytes;
}

any Native_AddModelHook(Handle plugin, int numParams)
{
	// Param 1: 'CustomWeapon' [this]
	ValidateCustomWeapon(view_as<CustomWeapon>(GetNativeCell(1)));
	
	g_ModelHook.AddFunction(plugin, GetNativeFunction(2));
	
	return 0;
}

any Native_RemoveModelHook(Handle plugin, int numParams)
{
	// Param 1: 'CustomWeapon' [this]
	ValidateCustomWeapon(view_as<CustomWeapon>(GetNativeCell(1)));
	
	g_ModelHook.RemoveFunction(plugin, GetNativeFunction(2));
	
	return 0;
}

void Native_CheckStringParamLength(int param_number, const char[] item_name, int max_length, bool can_be_empty = false, int &param_length = 0)
{
	int error;
	
	if ((error = GetNativeStringLength(param_number, param_length)) != SP_ERROR_NONE)
	{
		ThrowNativeError(error, "Failed to retrieve %s.", item_name);
	}
	
	if (!can_be_empty && !param_length)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s cannot be empty.", item_name);
	}
	
	if (param_length >= max_length)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s cannot be %d characters long (max: %d)", item_name, param_length, max_length - 1);
	}
}

void CreateForwards()
{
	g_ModelHook = new PrivateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_String);
	g_SoundHook = new PrivateForward(ET_Hook, Param_Cell, Param_Cell, Param_String);
}

Action Call_OnModel(int client, int weapon, CustomWeapon_ModelType model_type, char model[PLATFORM_MAX_PATH])
{
	Action result;
	
	Call_StartForward(g_ModelHook);
	Call_PushCell(client);
	Call_PushCell(weapon);
	Call_PushCell(model_type);
	Call_PushStringEx(model, sizeof(model), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(result);
	
	return result;
}

Action Call_OnSound(int client, int weapon, char sound[PLATFORM_MAX_PATH])
{
	Action result;
	
	Call_StartForward(g_SoundHook);
	Call_PushCell(client);
	Call_PushCell(weapon);
	Call_PushStringEx(sound, sizeof(sound), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(result);
	
	return result;
} 