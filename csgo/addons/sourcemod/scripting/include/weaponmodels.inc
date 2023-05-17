/**
 * =============================================================================
 * Custom Weapon Models
 *
 * Copyright (C) 2015 Andersso
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#if defined _weaponmodels_included
 #endinput
#endif
#define _weaponmodels_included

typeset WeaponModelsFunc
{
	function bool (int weaponIndex, int client, int weapon, const char[] className);
	function bool (int weaponIndex, int client, int weapon, const char[] className, int itemDefIndex);
};

public SharedPlugin __pl_weaponmodels = 
{
	name = "weaponmodels",
	file = "weaponmodels.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public void __pl_weaponmodels_SetNTVOptional()
{
	MarkNativeAsOptional("WeaponModels_AddWeaponByClassName");
	MarkNativeAsOptional("WeaponModels_AddWeaponByItemDefIndex");
	MarkNativeAsOptional("WeaponModels_RemoveWeaponModel");
}

/**
 * @brief Adds a weapon model
 *
 * @param		className		Class name of the weapon to add.
 * @param		viewModel		Model path of the view model, or NULL_STRING for no change.
 * @param		worldModel		Model path of the world model, or NULL_STRING for no change.
 * @param		function		Function to call when weapon is selected.
 * @return						The custom weapon model index, -1 on failure.
 * @error						Maximum amount of custom weapons has been reached.
 */
native void WeaponModels_AddWeaponByClassName(const char[] className, const char[] viewModel, const char[] worldModel, WeaponModelsFunc _function);

/**
 * @brief Adds a weapon model
 *
 * @param		itemDefIndex	item definition index of the weapon to add.
 * @param		viewModel		Model path of the view model, or NULL_STRING for no change.
 * @param		worldModel		Model path of the world model, or NULL_STRING for no change.
 * @param		function		Function to call when weapon is selected.
 * @return						The custom weapon model index, -1 on failure.
 * @error						Maximum amount of custom weapons has been reached.
 */
native void WeaponModels_AddWeaponByItemDefIndex(int itemDefIndex, const char[] viewModel, const char[] worldModel, WeaponModelsFunc _function);

/**
 * @brief Removes a weapon model
 *
 * @param		weaponIndex		The weapon index returned from WeaponModels_AddWeaponBy...()
 * @noreturn
 * @error						Weapon index is invalid
 */
native void WeaponModels_RemoveWeaponModel(int weaponIndex);
