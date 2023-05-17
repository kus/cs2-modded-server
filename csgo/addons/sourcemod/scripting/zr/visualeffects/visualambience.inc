/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  visualambience.inc
 *  Type:		  Module
 *  Description:   Fog, light style, sky, sun rendering, etc
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
 * Default sky of current map.
 */
char g_VAmbienceDefaultSky[PLATFORM_MAX_PATH];

/**
 * The map is ending.
 */
void VAmbienceOnMapEnd()
{
	// Reset the default sky cache to empty, to be re-cached for the next map.
	g_VAmbienceDefaultSky[0] = 0;
}

/**
 * Validate cvar data.
 */
void VAmbienceLoad()
{
	// Apply all visual effects now.
	VAmbienceApplyAll();
	
	// If sky is disabled, then stop.
	bool sky = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_SKY]);
	if (!sky)
	{
		return;
	}
	
	char downloadpath[PLATFORM_MAX_PATH];
	char skypath[PLATFORM_MAX_PATH];
	
	// Get sky path.
	GetConVarString(g_hCvarsList[CVAR_VEFFECTS_SKY_PATH], skypath, sizeof(skypath));
	
	// Prepend materials/skybox to the path.
	Format(downloadpath, sizeof(downloadpath), "materials/skybox/%s", skypath);
	
	// Add skybox file to downloads table.
	AddFileToDownloadsTable(downloadpath);
}

/**
 * Hook zr_veffects_* cvar changes.
 * 
 * @param unhook	If true, cvars will be unhooked, false to hook cvars.
 */
void VAmbienceCvarsHook(bool unhook = false)
{
	// If unhook is true, then continue.
	if (unhook)
	{
		// Unhook lightstyle cvars.
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE], VAmbienceCvarsHookLightStyle);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE_VALUE], VAmbienceCvarsHookLightStyle);
		
		// Unhook sky cvars.
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_SKY], VAmbienceCvarsHookSky);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_SKY_PATH], VAmbienceCvarsHookSky);
		
		// Unhook sun cvars.
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_SUN_DISABLE], VAmbienceCvarsHookSunDisable);
		
		// Unhook fog cvars.
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG], VAmbienceCvarsHookFog);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_OVERRIDE], VAmbienceCvarsHookFog);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_PCOLOR], VAmbienceCvarsHookFog);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_SCOLOR], VAmbienceCvarsHookFog);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_DENSITY], VAmbienceCvarsHookFog);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_STARTDIST], VAmbienceCvarsHookFog);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_ENDDIST], VAmbienceCvarsHookFog);
		UnhookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_FARZ], VAmbienceCvarsHookFog);
		
		// Stop after unhooking cvars.
		return;
	}
	
	// Hook lightstyle cvars.
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE], VAmbienceCvarsHookLightStyle);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE_VALUE], VAmbienceCvarsHookLightStyle);
	
	// Hook sky cvars.
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_SKY], VAmbienceCvarsHookSky);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_SKY_PATH], VAmbienceCvarsHookSky);
	
	// Hook sun cvars.
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_SUN_DISABLE], VAmbienceCvarsHookSunDisable);
	
	// Hook fog cvars.
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG], VAmbienceCvarsHookFog);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_OVERRIDE], VAmbienceCvarsHookFog);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_PCOLOR], VAmbienceCvarsHookFog);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_SCOLOR], VAmbienceCvarsHookFog);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_DENSITY], VAmbienceCvarsHookFog);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_STARTDIST], VAmbienceCvarsHookFog);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_ENDDIST], VAmbienceCvarsHookFog);
	HookConVarChange(g_hCvarsList[CVAR_VEFFECTS_FOG_FARZ], VAmbienceCvarsHookFog);
}

/**
 * Cvar hook callback (zr_veffects_lightstyle, zr_veffects_lightstyle_value)
 * Updated server to cvar values.
 * 
 * @param convar	The cvar handle.
 * @param oldvalue  The value before change.
 * @param newvalue  The new value.
 */
public void VAmbienceCvarsHookLightStyle(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	// If lightstyle is disabled, then disable.
	bool lightstyle = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE]);
	
	// Apply light style.
	VAmbienceApplyLightStyle(!lightstyle);
}

/**
 * Cvar hook callback (zr_veffects_sky, zr_veffects_sky_path)
 * Updated server to cvar values.
 * 
 * @param convar	The cvar handle.
 * @param oldvalue  The value before change.
 * @param newvalue  The new value.
 */
public void VAmbienceCvarsHookSky(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	// If sky is disabled, then disable.
	bool sky = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_SKY]);
	
	// Apply new sky.
	VAmbienceApplySky(!sky);
}

/**
 * Cvar hook callback (zr_veffects_sun_disable)
 * Updated server to cvar values.
 * 
 * @param convar	The cvar handle.
 * @param oldvalue  The value before change.
 * @param newvalue  The new value.
 */
public void VAmbienceCvarsHookSunDisable(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	// If fog is disabled, then disable.
	bool sun = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_SUN_DISABLE]);
	
	// Apply fog.
	VAmbienceApplySunDisable(!sun);
}

/**
 * Cvar hook callback (zr_veffects_fog_*)
 * Updated server to cvar values.
 * 
 * @param convar	The cvar handle.
 * @param oldvalue  The value before change.
 * @param newvalue  The new value.
 */
public void VAmbienceCvarsHookFog(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	// If fog is disabled, then disable.
	bool fogoverride = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_FOG_OVERRIDE]);
	
	// Apply fog.
	VAmbienceApplyFog(fogoverride);
}

/**
 * Apply all cvar values on server.
 */
void VAmbienceApplyAll()
{
	// If lightstyle is disabled, then disable.
	bool lightstyle = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE]);
	
	// Apply light style.
	VAmbienceApplyLightStyle(!lightstyle);
	
	// If sky is disabled, then disable.
	bool sky = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_SKY]);
	
	// Apply new sky.
	VAmbienceApplySky(!sky);
	
	// If fog is disabled, then disable.
	bool fogoverride = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_FOG_OVERRIDE]);
	
	// Apply fog.
	VAmbienceApplyFog(fogoverride);
}

void VAmbienceApplyLightStyle(bool disable = false)
{
	// If default, then set to normal light style.
	if (disable)
	{
		// Set light style.
		SetLightStyle(0, "n");
		
		return;
	}
	
	// Get light value.
	char lightstylevalue[4];
	GetConVarString(g_hCvarsList[CVAR_VEFFECTS_LIGHTSTYLE_VALUE], lightstylevalue, sizeof(lightstylevalue));
	
	// Set light style.
	SetLightStyle(0, lightstylevalue);
}

void VAmbienceApplySky(bool disable = false)
{
	// If we can't find the sv_skyname cvar, then stop.
	Handle hSkyname = FindConVar("sv_skyname");
	if (hSkyname == INVALID_HANDLE)
	{
		return;
	}
	
	// Store map's default sky before applying new one.
	if (!g_VAmbienceDefaultSky[0])
	{
		GetConVarString(hSkyname, g_VAmbienceDefaultSky, sizeof(g_VAmbienceDefaultSky));
	}
	
	// If default, then set to default sky.
	if (disable)
	{
		if (g_VAmbienceDefaultSky[0])
		{
			// Set default sky on all clients.
			SetConVarString(hSkyname, g_VAmbienceDefaultSky, true);
		}
		
		return;
	}
	
	// Get sky path.
	char skypath[PLATFORM_MAX_PATH];
	GetConVarString(g_hCvarsList[CVAR_VEFFECTS_SKY_PATH], skypath, sizeof(skypath));
	
	// Set new sky on all clients.
	SetConVarString(hSkyname, skypath, true);
}

void VAmbienceApplySunDisable(bool disable = false)
{
	// Find sun entity.
	int sun = FindEntityByClassname(-1, "env_sun");
	
	// If sun is invalid, then stop.
	if (sun == -1)
	{
		return;
	}
	
	// If default, then re-enable sun rendering.
	if (disable)
	{
		// Turn on sun rendering.
		AcceptEntityInput(sun, "TurnOn");
		
		return;
	}
	
	// Turn off sun rendering.
	AcceptEntityInput(sun, "TurnOff");
}

void VAmbienceApplyFog(bool override = false)
{
	// If fog is disabled, then stop.
	bool fog = GetConVarBool(g_hCvarsList[CVAR_VEFFECTS_FOG]);
	
	if (!fog)
	{
		return;
	}
	
	// Find current fog index
	int fogindex = FindEntityByClassname(-1, "env_fog_controller");
	
	// If override is enabled, then continue.
	if (override)
	{
		// If there is fog, then continue.
		if (fogindex != -1)
		{
			// Delete fog.
			AcceptEntityInput(fogindex, "Kill");
			fogindex = -1;
		}
	}
	
	// If there is no fog on the map, create new fog.
	if (fogindex == -1)
	{
		// Create and spawn fog.
		fogindex = CreateEntityByName("env_fog_controller");
		DispatchSpawn(fogindex);
	}
	
	char fogcolor[16];
	
	// Set primary fog color.
	GetConVarString(g_hCvarsList[CVAR_VEFFECTS_FOG_PCOLOR], fogcolor, sizeof(fogcolor));
	VAmbienceSetFogColor(fogindex, fogcolor, true);
	
	// Set secondary fog color.
	GetConVarString(g_hCvarsList[CVAR_VEFFECTS_FOG_SCOLOR], fogcolor, sizeof(fogcolor));
	VAmbienceSetFogColor(fogindex, fogcolor, false);
	
	// Set fog's density.
	float fogdensity = GetConVarFloat(g_hCvarsList[CVAR_VEFFECTS_FOG_DENSITY]);
	VAmbienceSetFogDensity(fogindex, fogdensity);
	
	// Set fog's start distance.
	int fogstart = GetConVarInt(g_hCvarsList[CVAR_VEFFECTS_FOG_STARTDIST]);
	VAmbienceSetFogStartDist(fogindex, fogstart);
	
	// Set fog's end distance.
	int fogend = GetConVarInt(g_hCvarsList[CVAR_VEFFECTS_FOG_ENDDIST]);
	VAmbienceSetFogEndDist(fogindex, fogend);
	
	// Set fog's far z distance.
	int fogfarz = GetConVarInt(g_hCvarsList[CVAR_VEFFECTS_FOG_FARZ]);
	VAmbienceSetFogFarZ(fogindex, fogfarz);
}

/**
 * Set fog's primary or secondary color.
 * 
 * @param fogindex  Edict index of the fog to modify.
 * @param color	 The rgb color of the fog. 
 * @param primary   (Optional) True to set primary, false otherwise.
 */
void VAmbienceSetFogColor(int fogindex, const char[] color, bool primary = true)
{
	// Set primary color.
	if (primary)
	{
		// Set new color.
		SetVariantString(color);
		AcceptEntityInput(fogindex, "SetColor");
	}
	// Set secondary color.
	else
	{
		// Set new color.
		SetVariantString(color);
		AcceptEntityInput(fogindex, "SetColorSecondary");
	}
}

/**
 * Set fog's density.
 * 
 * @param fogindex  Edict index of the fog to modify.
 * @param density   The density of the fog. 
 */
void VAmbienceSetFogDensity(int fogindex, float density)
{
	// Set density.
	DispatchKeyValueFloat(fogindex, "fogmaxdensity", density);
}

/**
 * Set fog's start distance.
 * 
 * @param fogindex	  Edict index of the fog to modify.
 * @param startdist	 The start distance of the fog. 
 */
void VAmbienceSetFogStartDist(int fogindex, int startdist)
{
	// Set start distance.
	SetVariantInt(startdist);
	AcceptEntityInput(fogindex, "SetStartDist");
}

/**
 * Set fog's end distance.
 * 
 * @param fogindex	  Edict index of the fog to modify.
 * @param enddist	   The end distance of the fog. 
 */
void VAmbienceSetFogEndDist(int fogindex, int enddist)
{
	// Set end distance.
	SetVariantInt(enddist);
	AcceptEntityInput(fogindex, "SetEndDist");
}

/**
 * Set fog's far z distance.
 * 
 * @param fogindex	  Edict index of the fog to modify.
 * @param farz		  The far z distance of the fog. 
 */
void VAmbienceSetFogFarZ(int fogindex, int farz)
{
	// Set far z distance.
	SetVariantInt(farz);
	AcceptEntityInput(fogindex, "SetFarZ");
}
