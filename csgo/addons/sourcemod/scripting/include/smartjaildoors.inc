// © Maxim "Kailo" Telezhenko, 2015
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>

#if defined _smartjaildoors_included_
  #endinput
#endif
#define _smartjaildoors_included_

/**
 * Open jail's doors on current map saved in Smart Jail Doors config.
 *
 * @noreturn
 */
native void SJD_OpenDoors();

/**
 * Close jail's doors on current map saved in Smart Jail Doors config.
 *
 * @noreturn
 */
native void SJD_CloseDoors();

/**
 * Toggle jail's doors on current map saved in Smart Jail Doors config.
 * If door can't be toggled - nothing.
 *
 * @noreturn
 */
native void SJD_ToggleDoors();

/**
 * Toggle jail's doors on current map saved in Smart Jail Doors config.
 * If door can't be toggled - open.
 *
 * @noreturn
 */
native void SJD_ToggleExDoors();

/**
 * Check if exist doors config for said map.
 *
 * @param mapName    String with map name for check.
 * @return
 */
native bool SJD_IsMapConfigured(const char[] mapName);

/**
 * Check if exist doors config for current map.
 */
stock bool SJD_IsCurrentMapConfigured()
{
	char mapName[64];
	GetCurrentMap(mapName, sizeof(mapName));
	
	return SJD_IsMapConfigured(mapName);
}

public SharedPlugin:__pl_smartjaildoors = 
{
	name = "smartjaildoors",
	file = "smartjaildoors.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_smartjaildoors_SetNTVOptional()
{
	MarkNativeAsOptional("SJD_OpenDoors");
	MarkNativeAsOptional("SJD_CloseDoors");
	MarkNativeAsOptional("SJD_ToggleDoors");
	MarkNativeAsOptional("SJD_IsMapConfigured");
}
#endif