/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   volgenericattributes.inc
 *  Type:		   Module 
 *  Description:	Functions for getting or setting general volume attributes.
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
 * Parses a team string value and applies it to the specified volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param team		  A team string value. Valid options: "all", "humans"
 *					  and "zombies".
 * @return			  True if successfully set, false otherwise.
 */
stock bool VolSetTeamString(int volumeIndex, const char[] team)
{
	VolumeTeamFilters teamfilter;
	
	// Check if string value is empty.
	if (strlen(team) == 0)
	{
		return false;
	}
	
	// Convert value.
	if (StrEqual(team, "all", false))
	{
		teamfilter = VolTeam_All;
	}
	else if (StrEqual(team, "humans", false))
	{
		teamfilter = VolTeam_Humans;
	}
	else if (StrEqual(team, "zombies", false))
	{
		teamfilter = VolTeam_Zombies;
	}
	
	// Apply value.
	Volumes[volumeIndex][Vol_TeamFilter] = teamfilter;
	return true;
	
}

/**
 * Sets the feam filter attribute on a volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param team		  The team filter value.
 */
stock void VolSetTeam(int volumeIndex, VolumeTeamFilters[] team)
{
	Volumes[volumeIndex][Vol_TeamFilter] = team;
}

/**
 * Converts a team name type to a string.
 *
 * @param team		  Team type to convert.
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of destination buffer.
 * @param shortName	 Optional. Write short name or human readable name.
 *					  Default is human readable (false).
 * @return			  Number of cells written.
 */
stock int VolTeamToString(VolumeTeamFilters team, char[] buffer, int maxlen, bool shortName = false)
{
	switch (team)
	{
		case VolTeam_All:
		{
			return shortName ? strcopy(buffer, maxlen, "all") : strcopy(buffer, maxlen, "All");
		}
		case VolTeam_Humans:
		{
			return shortName ? strcopy(buffer, maxlen, "humans") : strcopy(buffer, maxlen, "Humans");
		}
		case VolTeam_Zombies:
		{
			return shortName ? strcopy(buffer, maxlen, "zombies") : strcopy(buffer, maxlen, "Zombies");
		}
	}
	
	return 0;
}

/**
 * Parses a delay string value and applies it to the specified volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param delay		 The delay to apply. A floating point number formatted
 *					  as a string. 
 * @return			  True if successfully set, false otherwise.
 */
stock bool VolSetDelayString(int volumeIndex, const char[] delay)
{
	float triggerdelay;
	
	// Check if string value is empty.
	if (strlen(delay) == 0)
	{
		return false;
	}
	
	// Convert value.
	triggerdelay = StringToFloat(delay);
	
	// Apply value.
	Volumes[volumeIndex][Vol_TriggerDelay] = triggerdelay;
	return true;
}

/**
 * Sets the trigger delay attribute on a volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param delay		 The trigger delay, in seconds.
 */
stock void VolSetDelay(int volumeIndex, float delay)
{
	Volumes[volumeIndex][Vol_TriggerDelay] = delay;
}

/**
 * Parses a effect string value and applies it to the specified volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param effect		A effect string value. Valid options: see VolumeEffects
 *					  enumeration, exclude prefix.
 * @return			  True if successfully set, false otherwise.
 */
stock bool VolSetEffectString(int volumeIndex, const char[] effect)
{
	// Check if string value is empty.
	if (strlen(effect) == 0)
	{
		return false;
	}
	
	// Check effect string values and apply them to the volume.
	if (StrEqual(effect, "none", false))
	{
		Volumes[volumeIndex][Vol_Effect] = VolEffect_None;
		return true;
	}
	else if (StrEqual(effect, "wireframe", false))
	{
		Volumes[volumeIndex][Vol_Effect] = VolEffect_Wireframe;
		return true;
	}
	else if (StrEqual(effect, "smoke", false))
	{
		Volumes[volumeIndex][Vol_Effect] = VolEffect_Smoke;
		return true;
	}
	
	// The string value didn't match any valid effects.
	return false;
}

/**
 * Sets the effect attribute on a volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param effect		Specifies what effect to apply on the volume.
 */
stock void VolSetEffect(int volumeIndex, VolumeEffects effect)
{
	Volumes[volumeIndex][Vol_Effect] = effect;
}

/**
 * Converts a volume effect type to a string.
 *
 * @param effect		Effect type to convert.
 * @param buffer		Destination string buffer.
 * @param maxlen		Size of destination buffer.
 * @param shortName	 Optional. Write short name or human readable name.
 *					  Default is human readable (false).
 * @return			  Number of cells written.
 */
stock int VolEffectToString(VolumeEffects effect, char[] buffer, int maxlen, bool shortName = false)
{
	switch (effect)
	{
		case VolEffect_None:
		{
			return shortName ? strcopy(buffer, maxlen, "none") : strcopy(buffer, maxlen, "No effect");
		}
		case VolEffect_Wireframe:
		{
			return shortName ? strcopy(buffer, maxlen, "wireframe") : strcopy(buffer, maxlen, "Wire frame");
		}
		case VolEffect_Smoke:
		{
			return shortName ? strcopy(buffer, maxlen, "smoke") : strcopy(buffer, maxlen, "Smoke");
		}
	}
	
	return 0;
}

/**
 * Parses a effect color string value and applies it to the specified volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param effect_color  A effect color string value. No whitespace! Format
 *					  (0-255): "red,green,blue".
 * @return			  True if successfully set, false otherwise.
 */
stock bool VolSetEffectColorString(int volumeIndex, const char[] effect_color)
{
	char colors[3][3];
	int red, green, blue;
	
	// Check if string value is empty.
	if (strlen(effect_color) == 0)
	{
		return false;
	}
	
	// Split values into a string array.
	ExplodeString(effect_color, ",", colors, 3, 3);
	
	// Convert values.
	red = StringToInt(colors[0]);
	green = StringToInt(colors[1]);
	blue = StringToInt(colors[2]);
	
	// Apply values.
	Volumes[volumeIndex][Vol_EffectColor][0] = red;
	Volumes[volumeIndex][Vol_EffectColor][1] = green;
	Volumes[volumeIndex][Vol_EffectColor][2] = blue;
	return true;
}

/**
 * Sets the effect color attribute on a volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param red		   Amount of red color. 0 to 255.
 * @param green		 Amount of green color. 0 to 255.
 * @param blue		  Amount of blue color. 0 to 255.
 */
stock void VolSetEffectColor(int volumeIndex, int red, int green, int blue)
{
	Volumes[volumeIndex][vol_effect_color][0] = red;
	Volumes[volumeIndex][vol_effect_color][1] = green;
	Volumes[volumeIndex][vol_effect_color][2] = blue;
}

/**
 * Parses a enabled string value and applies it to the specified volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param enabled	   A enabled string value. Valid options: A number that
 *					  evaluates to true or false, "yes" or "no".
 * @return			  True if successfully set, false otherwise.
 */
stock bool VolSetEnabledString(int volumeIndex, const char[] enabled)
{
	// Check if string value is empty.
	if (strlen(enabled) == 0)
	{
		return false;
	}
	
	bool val = view_as<bool>(StringToInt(enabled));
	
	// Check yes or no values first.
	if (StrEqual(enabled, "yes", false))
	{
		val = true;
	}
	else if (StrEqual(enabled, "no", false))
	{
		val = false;
	}
	
	// Check if the new value is different from the current.
	if (Volumes[volumeIndex][Vol_Enabled] != val)
	{
		// Forward event.
		if (val)
		{
			VolOnEnabled(volumeIndex);
		}
		else
		{
			VolOnDisabled(volumeIndex);
		}
	}
	
	// Apply converted value.
	Volumes[volumeIndex][Vol_Enabled] = val;
	return true;
}

/**
 * Sets the enabled attribute on a volume.
 *
 * @param volumeIndex   The volume index to apply to.
 * @param enabled	   Specifies if the volume should be enabled or not.
 */
stock void VolSetEnabled(int volumeIndex, bool enabled)
{
	// Check if the new value is different from the current.
	if (Volumes[volumeIndex][Vol_Enabled] != enabled)
	{
		// Forward event.
		if (enabled)
		{
			VolOnVolumeEnabled(volumeIndex);
		}
		else
		{
			VolOnVolumeDisabled(volumeIndex);
		}
	}

	Volumes[volumeIndex][Vol_Enabled] = enabled;
}
