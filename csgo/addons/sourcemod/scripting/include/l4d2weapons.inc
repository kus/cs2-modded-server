/**
 * vim: set ts=4 :
 * =============================================================================
 * Left 4 Downtown 2 SourceMod Extension
 * Copyright (C) 2010 Michael "ProdigySim" Busby
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
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */
 
 #if defined _l4d2weapons_included
  #endinput
#endif
#define _l4d2weapons_included

enum L4D2IntWeaponAttributes
{
	L4D2IWA_Damage,
	L4D2IWA_Bullets,
	L4D2IWA_ClipSize
};

/*
A note regarding Clipsize: Any nonstandard value will NOT be in effect at weapon pickup, which means the client
has to reload once to achieve the modified value. To fix this, add a weapon pickup hook in your plugin (eg "player_use")
and use something like this with a small timer delay of 0.1 seconds or more (dont you love this engine)
	
	new weapon = GetPlayerWeaponSlot(client, 0);
	if (weapon == INVALID_ENT_REFERENCE) return; 
	decl String:class[56];
	GetEdictClassname(weapon, class, sizeof(class));
	SetEntProp(weapon, Prop_Send, "m_iClip1", L4D2_GetIntWeaponAttribute(class, L4D2IWA_ClipSize));
*/

enum L4D2FloatWeaponAttributes
{
	L4D2FWA_MaxPlayerSpeed,
	L4D2FWA_SpreadPerShot,
	L4D2FWA_MaxSpread,
	L4D2FWA_SpreadDecay,
	L4D2FWA_MinDuckingSpread,
	L4D2FWA_MinStandingSpread,
	L4D2FWA_MinInAirSpread,
	L4D2FWA_MaxMovementSpread,
	L4D2FWA_PenetrationNumLayers,
	L4D2FWA_PenetrationPower,
	L4D2FWA_PenetrationMaxDist,
	L4D2FWA_CharPenetrationMaxDist,
	L4D2FWA_Range,
	L4D2FWA_RangeModifier,
	L4D2FWA_CycleTime
};

enum L4D2BoolMeleeWeaponAttributes
{
	L4D2BMWA_Decapitates
};

enum L4D2IntMeleeWeaponAttributes
{
	L4D2IMWA_DamageFlags,
	L4D2IMWA_RumbleEffect
};

enum L4D2FloatMeleeWeaponAttributes
{
	L4D2FMWA_Damage,
	L4D2FMWA_RefireDelay,
	L4D2FMWA_WeaponIdleTime
};


/**
 * @brief Checks for a given weapon string to exist in the WeaponInformationDatabase
 * @remarks Throws an error if Database is unavailable
 * 
 * @param weaponName 	Weapon to check up on
 * @return 				True if weapon is found, false if not
 */
native bool:L4D2_IsValidWeapon(const String:weaponName[]);

/**
 * @brief Read an int-typed attribute for a given weapon from the WeaponInformationDatabase
 * @remarks Throws an error if the weapon is not found or the attribute is incorrect
 * 
 * @param weaponName 	Weapon to lookup attribute for
 * @param attr			Attribute to read from the weapon's info struct
 * @return 				The value read.
 */
native L4D2_GetIntWeaponAttribute(const String:weaponName[], L4D2IntWeaponAttributes:attr);

/**
 * @brief Read a float-typed attribute for a given weapon from the WeaponInformationDatabase
 * @remarks Throws an error if the weapon is not found or the attribute is incorrect
 * 
 * @param weaponName 	Weapon to lookup attribute for
 * @param attr			Attribute to read from the weapon's info struct
 * @return 				The value read.
 */
native Float:L4D2_GetFloatWeaponAttribute(const String:weaponName[], L4D2FloatWeaponAttributes:attr);

/**
 * @brief Set an int-typed attribute for a given weapon from the WeaponInformationDatabase to a given value
 * @remarks Throws an error if the weapon is not found or the attribute is incorrect
 * 
 * @param weaponName 	Weapon to lookup attribute for
 * @param attr			Attribute to alter in the weapon's info struct
 * @param value			Value to set the attribute to
 * @noreturn
 */
native L4D2_SetIntWeaponAttribute(const String:weaponName[], L4D2IntWeaponAttributes:attr, value);

/**
 * @brief Set a float-typed attribute for a given weapon from the WeaponInformationDatabase to a given value
 * @remarks Throws an error if the weapon is not found or the attribute is incorrect
 * 
 * @param weaponName 	Weapon to lookup attribute for
 * @param attr			Attribute to alter in the weapon's info struct
 * @param value			Value to set the attribute to
 * @noreturn
 */
native Float:L4D2_SetFloatWeaponAttribute(const String:weaponName[], L4D2FloatWeaponAttributes:attr, Float:value);





/**
 * @brief Retrieve the index for a given melee weapon from the Melee Weapon Database
 * @remarks returns -1 if no match is found
 * 
 * @param weaponName 	Weapon to lookup index id for
 * @return 				The index id
 */
native L4D2_GetMeleeWeaponIndex(const String:weaponName[]);

/**
 * @brief Read an int-typed attribute for a given id from the Melee Weapon Database
 * @remarks Throws an error if the id is not found or the attribute is incorrect
 * 
 * @param id 			Melee id to lookup attribute for
 * @param attr			Attribute to read from the weapon's info struct
 * @return 				The value read.
 */
native L4D2_GetIntMeleeAttribute(id, L4D2IntMeleeWeaponAttributes:attr);

/**
 * @brief Read a float-typed attribute for a given id from the Melee Weapon Database
 * @remarks Throws an error if the id is not found or the attribute is incorrect
 * 
 * @param id 			Melee id to lookup attribute for
 * @param attr			Attribute to read from the weapon's info struct
 * @return 				The value read.
 */
native Float:L4D2_GetFloatMeleeAttribute(id, L4D2FloatMeleeWeaponAttributes:attr);

/**
 * @brief Read a bool-typed attribute for a given id from the Melee Weapon Database
 * @remarks Throws an error if the id is not found or the attribute is incorrect
 * 
 * @param id 			Melee id to lookup attribute for
 * @param attr			Attribute to read from the weapon's info struct
 * @return 				The value read.
 */
native bool:L4D2_GetBoolMeleeAttribute(id, L4D2BoolMeleeWeaponAttributes:attr);

/**
 * @brief Set an int-typed attribute for a given id from the Melee Weapon Database to a given value
 * @remarks Throws an error if the id is not found or the attribute is incorrect
 * 
 * @param id 			Melee id to lookup attribute for
 * @param attr			Attribute to alter in the weapon's info struct
 * @param value			Value to set the attribute to
 * @noreturn
 */
native L4D2_SetIntMeleeAttribute(id, L4D2IntMeleeWeaponAttributes:attr, value);

/**
 * @brief Set a float-typed attribute for a given id from the Melee Weapon Database to a given value
 * @remarks Throws an error if the id is not found or the attribute is incorrect
 * 
 * @param id 			Melee id to lookup attribute for
 * @param attr			Attribute to alter in the weapon's info struct
 * @param value			Value to set the attribute to
 * @noreturn
 */
native Float:L4D2_SetFloatMeleeAttribute(id, L4D2FloatMeleeWeaponAttributes:attr, Float:value);

/**
 * @brief Set a bool-typed attribute for a given id from the Melee Weapon Database to a given value
 * @remarks Throws an error if the id is not found or the attribute is incorrect
 * 
 * @param id 			Melee id to lookup attribute for
 * @param attr			Attribute to alter in the weapon's info struct
 * @param value			Value to set the attribute to
 * @noreturn
 */
native Float:L4D2_SetBoolMeleeAttribute(id, L4D2BoolMeleeWeaponAttributes:attr, bool:value);
