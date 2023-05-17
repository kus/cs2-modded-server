/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  apply.inc
 *  Type:		  Core
 *  Description:   Functions for applying attributes and effects on a client.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/**
 * Array that stores the client's current speed.
 */
float g_flClassApplySpeed[MAXPLAYERS + 1];

/**
 * Applies all class attributes on a player. Changing model, hp, speed, health,
 * effects etc. The players current team will be used to get the class index.
 *
 * @param client		The player to apply attributes on.
 * @param improved	  Optional. Gives advantages or improvements in some
 *					  attributes. To be used on mother zombies. Default is
 *					  false.
 * @return  True if all success on applying all attributes, false otherwise.
 */
bool ClassApplyAttributes(int client, bool improved = false)
{
	int classindex = ClassGetActiveIndex(client);
	
	// Validate class index.
	if (!ClassValidateIndex(classindex))
	{
		return false;
	}
	
	// Override improved settings if it's a mother zombie class.
	if (ClassHasFlags(classindex, ZR_CLASS_FLAG_MOTHER_ZOMBIE))
	{
		improved = false;
	}
	
	ClassApplyModel(client, classindex);
	ClassApplyAlpha(client, classindex);
	ClassApplyOverlay(client, classindex);
	ClassApplyNightVision(client, classindex);
	ClassApplyFOV(client, classindex);
	ClassApplyHealth(client, classindex, improved);
	ClassApplyHealthRegen(client, classindex);
	ClassApplySpeed(client, classindex);
	ClassApplyArms(client, classindex);
	
	return true;
}

/**
 * Changes the model on a player.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplyModel(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	bool isAttributePreset = false;
	char modelpath[PLATFORM_MAX_PATH];
	int index;
	ModelTeam team;
	int access;
	int model;
	int skinIndex = 0;
	
	// Get correct index according to cache type.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		index = client;
	}
	else
	{
		index = classindex;
	}
	
	// Get the model path from the specified cache.
	ClassGetModelPath(index, modelpath, sizeof(modelpath), cachetype);
	
	// Get model skin index.
	skinIndex = ClassGetModelSkinIndex(index, cachetype);
	
	// Get model team setting from the specified cache.
	team = ModelsTeamIdToTeam(ClassGetTeamID(index, cachetype));
	
	// Check if the user specified a pre-defined model setting. If so, setup
	// model filter settings.
	if (StrEqual(modelpath, "random", false))
	{
		// Set access filter flags.
		access = MODEL_ACCESS_PUBLIC | MODEL_ACCESS_ADMINS;
		
		// Specify client for including admin models if client is admin.
		index = client;
		
		isAttributePreset = true;
	}
	else if (StrEqual(modelpath, "random_public", false))
	{
		access = MODEL_ACCESS_PUBLIC;
		index = -1;
		isAttributePreset = true;
	}
	else if (StrEqual(modelpath, "random_hidden", false))
	{
		access = MODEL_ACCESS_HIDDEN;
		index = -1;
		isAttributePreset = true;
	}
	else if (StrEqual(modelpath, "random_admin", false))
	{
		access = MODEL_ACCESS_ADMINS;
		index = -1;
		isAttributePreset = true;
	}
	else if (StrEqual(modelpath, "random_mother_zombie", false))
	{
		access = MODEL_ACCESS_MOTHER_ZOMBIES;
		index = -1;
		isAttributePreset = true;
	}
	else if (StrEqual(modelpath, "default", false))
	{
		// Get current model.
		GetClientModel(client, modelpath, sizeof(modelpath));
		
		// Restore original model if not already set.
		if (!StrEqual(ClassOriginalPlayerModel[client], modelpath))
		{
			strcopy(modelpath, sizeof(modelpath), ClassOriginalPlayerModel[client]);
		}
		else
		{
			// Wanted model is already set, don't change.
			return true;
		}
	}
	else if (StrEqual(modelpath, "no_change", false))
	{
		// Do nothing.
		return true;
	}
	
	// Check if model setting is a attribute preset.
	if (isAttributePreset)
	{
		// Get model based on filter settings set up earlier.
		model = ModelsGetRandomModel(index, team, access);
		
		// Check if found.
		if (model >= 0)
		{
			// Get model path.
			ModelsGetFullPath(model, modelpath, sizeof(modelpath));
		}
		else
		{
			// Couldn't find any models based on filter. Fall back to a random
			// public model. Then get its path.
			model = ModelsGetRandomModel(-1, team, MODEL_ACCESS_PUBLIC);
			ModelsGetFullPath(model, modelpath, sizeof(modelpath));
		}
	}
	
	SetEntityModel(client, modelpath);
	SetEntProp(client, Prop_Send, "m_nSkin", skinIndex);
	
	return true;
}

/**
 * Sets transparency on a player.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplyAlpha(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	int alpha;
	
	// Get the alpha value from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		alpha = ClassGetAlphaInitial(client, cachetype);
	}
	else
	{
		alpha = ClassGetAlphaInitial(classindex, cachetype);
	}
	
	if (alpha < 0)
	{
		return false;
	}
	
	ToolsSetClientAlpha(client, alpha);
	return true;
}

/**
 * Apply the overlay on a player if not applied.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplyOverlay(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	char overlaypath[PLATFORM_MAX_PATH];
	
	// Get the overlay path from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		ClassGetOverlayPath(client, overlaypath, sizeof(overlaypath), cachetype);
	}
	else
	{
		ClassGetOverlayPath(classindex, overlaypath, sizeof(overlaypath), cachetype);
	}
	
	ClassOverlayInitialize(client, overlaypath);
	return true;
}

/**
 * Gives night vision to a player.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplyNightVision(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	bool nvgs;
	
	// Get the night vision setting from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		nvgs = ClassGetNvgs(client, cachetype);
	}
	else
	{
		nvgs = ClassGetNvgs(classindex, cachetype);
	}
	
	ToolsSetClientNightVision(client, nvgs);
	ToolsSetClientNightVision(client, nvgs, false);
	
	return true;
}

/**
 * Sets the field of view setting on a player.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplyFOV(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	int fov;
	
	// Get the field of view setting from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		fov = ClassGetFOV(client, cachetype);
	}
	else
	{
		fov = ClassGetFOV(classindex, cachetype);
	}
	
	ToolsSetClientDefaultFOV(client, fov);
	return true;
}

/**
 * Gives health points on a player.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param boost		 Double health boost. Default: false
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplyHealth(int client, int classindex, bool boost = false, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	int health;
	
	// Get the health points from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		health = ClassGetHealth(client, cachetype);
	}
	else
	{
		health = ClassGetHealth(classindex, cachetype);
	}
	
	if (boost)
	{
		health *= 2;
	}
	
	SetEntityHealth(client, health);
	return true;
}

/**
 * Applies health regeneration on a player if enabled.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param boost		 Double health boost. Default: false
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True if applied, false otherwise.
 */
bool ClassApplyHealthRegen(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	float interval;
	int amount;
	int max;
	
	// Get the health regeneration info from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		interval = ClassGetHealthRegenInterval(client, cachetype);
		amount = ClassGetHealthRegenAmount(client, cachetype);
		max = ClassGetHealth(client, cachetype);
	}
	else
	{
		interval = ClassGetHealthRegenInterval(classindex, cachetype);
		amount = ClassGetHealthRegenAmount(classindex, cachetype);
		max = ClassGetHealth(classindex, cachetype);
	}
	
	if (interval > 0)
	{
		ClassHealthRegenInitClient(client, interval, amount, max);
		return true;
	}
	else
	{
		// Make sure old timers are stopped.
		ClassHealthRegenStop(client);
		return false;
	}
}

/**
 * Sets the players speed.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplySpeed(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	float speed;
	
	// Get the health points from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		speed = ClassGetSpeed(client, cachetype);
	}
	else
	{
		speed = ClassGetSpeed(classindex, cachetype);
	}
	
	ClassApplySpeedEx(client, speed);
	return true;
}

/**
 * Applies the specified speed to the player.
 *
 * @param client	Client to apply to.
 * @param speed	 Speed value.
 */
void ClassApplySpeedEx(int client, float speed)
{
	// Check what speed method that's used and apply it.
	switch (ClassSpeedMethod)
	{
		case ClassSpeed_LMV:
		{
			ToolsSetClientLMV(client, speed);
		}
		case ClassSpeed_Prop:
		{
			g_flClassApplySpeed[client] = speed;
		}
	}
}

/**
 * Called before the client can "think"
 * Here we can change the client's speed through m_flMaxSpeed.
 * 
 * @param client	The client index.
 */
public void ClassPreThinkPost(int client)
{
	// Only apply speed if the prop method is used.
	if (ClassSpeedMethod == ClassSpeed_Prop)
	{
		if (!IsPlayerAlive(client))
		{
			return;
		}
		
		// Note: Default is around 200.0 - 250.0
		float newspeed = GetEntPropFloat(client, Prop_Data, "m_flMaxspeed") + g_flClassApplySpeed[client];
		SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", newspeed);
	}
}

/**
 * Called when a clients movement buttons are being processed
 *
 * @param client	Index of the client.
 * @param vel		Players desired velocity.
 */
void Class_OnPlayerRunCmd(int client, float vel[3])
{
	if (!IsPlayerAlive(client))
		return;
	
	// Only modify speed if the prop method is used.
	if (ClassSpeedMethod == ClassSpeed_Prop)
	{
		// x-axis speed.
		if (vel[0] < 0.0)
			vel[0] = -5000.0;
		
		else if (vel[0] > 0.0)
			vel[0] = 5000.0;
		
		// y-axis speed.
		if (vel[1] < 0.0)
			vel[1] = -5000.0;
		
		else if (vel[1] > 0.0)
			vel[1] = 5000.0;
	}
}

/**
 * Changes the Arms model on a player.
 *
 * @param client		The client index.
 * @param classindex	The class to read from.
 * @param cachetype	 Optional. Specifies what class cache to read from.
 *					  Options:
 *					  ZR_CLASS_CACHE_ORIGINAL - Unchanced class data.
 *					  ZR_CLASS_CACHE_MODIFIED - Changed/newest class data.
 *					  ZR_CLASS_CACHE_PLAYER (default) - Player cache.
 * @return  True on success, false otherwise.
 */
bool ClassApplyArms(int client, int classindex, int cachetype = ZR_CLASS_CACHE_PLAYER)
{
	/// If module is disabled, then stop.
	bool classes_arms = GetConVarBool(g_hCvarsList[CVAR_CLASSES_ARMS]);
	if (!classes_arms)
	{
		return true;
	}

	char arms_path[PLATFORM_MAX_PATH];

	// Get the overlay path from the specified cache.
	if (cachetype == ZR_CLASS_CACHE_PLAYER)
	{
		ClassGetArmsPath(client, arms_path, sizeof(arms_path), cachetype);
	}
	else
	{
		ClassGetArmsPath(classindex, arms_path, sizeof(arms_path), cachetype);
	}

	if (StrEqual(arms_path, "default", false))
	{
		// Do nothing.
		return true;
	}
	else if (StrEqual(arms_path, "no_change", false))
	{
		// Do nothing.
		return true;
	}

	int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
	if(ent != -1)
	{
		AcceptEntityInput(ent, "KillHierarchy");
	}
	SetEntPropString(client, Prop_Send, "m_szArmsModel", arms_path);
	
	return true;
}