#if defined _smlib_weapons_included
	#endinput
#endif
#define _smlib_weapons_included

#include <sourcemod>
#include <sdktools_functions>
#include <smlib/entities>

#define MAX_WEAPON_OFFSET		64
#define MAX_WEAPON_SLOTS		6	// hud item selection slots
#define MAX_WEAPON_POSITIONS	20	// max number of items within a slot
#define MAX_WEAPONS				48	// Max number of weapons availabl
#define WEAPON_NOCLIP			-1	// clip sizes set to this tell the weapon it doesn't use a clip
#define	MAX_AMMO_TYPES			32
#define MAX_AMMO_SLOTS 			32	// not really slots

#define MAX_WEAPON_STRING		80
#define MAX_WEAPON_PREFIX		16
#define MAX_WEAPON_AMMO_NAME	32

/*
 * Gets the owner (usually a client) of the weapon
 * 
 * @param weapon		Weapon Entity.
 * @return				Owner of the weapon or INVALID_ENT_REFERENCE if the weapon has no owner.
 */
stock Weapon_GetOwner(weapon)
{
	return GetEntPropEnt(weapon, Prop_Data, "m_hOwner");
}

/*
 * Sets the owner (usually a client) of the weapon
 * 
 * @param weapon		Weapon Entity.
 * @param entity		Entity Index.
 * @noreturn
 */
stock Weapon_SetOwner(weapon, entity)
{
	SetEntPropEnt(weapon, Prop_Data, "m_hOwner", entity);
}

/*
 * Checks whether the entity is a valid weapon or not.
 * 
 * @param weapon		Weapon Entity.
 * @return				True if the entity is a valid weapon, false otherwise.
 */
stock Weapon_IsValid(weapon)
{
	if (!IsValidEdict(weapon)) {
		return false;
	}
	
	return Entity_ClassNameMatches(weapon, "weapon_", true);
}

/*
 * Create's a weapon and spawns it in the world at the specified location.
 * 
 * @param className		Classname String of the weapon to spawn
 * @param absOrigin		Absolute Origin Vector where to spawn the weapon.
 * @param absAngles		Absolute Angles Vector.
 * @return				Weapon Index of the created weapon or INVALID_ENT_REFERENCE on error.
 */
stock Weapon_Create(const String:className[], Float:absOrigin[3], Float:absAngles[3])
{
	new weapon = Entity_Create(className);
	
	if (weapon == INVALID_ENT_REFERENCE) {
		return INVALID_ENT_REFERENCE;
	}
	
	Entity_SetAbsOrigin(weapon, absOrigin);
	Entity_SetAbsAngles(weapon, absAngles);
	
	DispatchSpawn(weapon);
	
	return weapon;
}

/*
 * Create's a weapon and spawns it in the world at the specified location.
 * 
 * @param className		Classname String of the weapon to spawn
 * @param absOrigin		Absolute Origin Vector where to spawn the weapon.
 * @param absAngles		Absolute Angles Vector.
 * @return				Weapon Index of the created weapon or INVALID_ENT_REFERENCE on error.
 */
stock Weapon_CreateForOwner(client, const String:className[])
{
	decl Float:absOrigin[3], Float:absAngles[3];
	Entity_GetAbsOrigin(client, absOrigin);
	Entity_GetAbsAngles(client, absAngles);
	
	new weapon = Weapon_Create(className, absOrigin, absAngles);
	
	if (weapon == INVALID_ENT_REFERENCE) {
		return INVALID_ENT_REFERENCE;
	}

	Entity_SetOwner(weapon, client);
	
	return weapon;
}

/*
 * Gets the weapon's subtype.
 * The subtype is only used when a player has multiple weapons of the same type.
 * 
 * @param weapon		Weapon Entity.
 * @return				Subtype of the weapon.
 */
stock Weapon_GetSubType(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iSubType");
}

/*
 * Is the weapon currently reloading ?
 * 
 * @param weapon		Weapon Entity.
 * @return				True if weapon is currently reloading, false if not.
 */
stock bool:Weapon_IsReloading(weapon)
{
	return bool:GetEntProp(weapon, Prop_Data, "m_bInReload");
}

/*
 * Weapon m_iState
 */
#define WEAPON_IS_ONTARGET				0x40
#define WEAPON_NOT_CARRIED				0	// Weapon is on the ground
#define WEAPON_IS_CARRIED_BY_PLAYER		1	// This client is carrying this weapon.
#define WEAPON_IS_ACTIVE				2	// This client is carrying this weapon and it's the currently held weapon

/*
 * Get's the state of the weapon.
 * This returns whether the weapon is currently carried by a client,
 * if it is active and if it is on a target.
 * 
 * @param weapon		Weapon Entity.
 * @return				Weapon State.
 */
stock Weapon_GetState(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iState");
}

/*
 * Returns whether the weapon can fire primary ammo under water.
 * 
 * @param weapon		Weapon Entity.
 * @return				True or False.
 */
stock bool:Weapon_FiresUnderWater(weapon)
{
	return bool:GetEntProp(weapon, Prop_Data, "m_bFiresUnderwater");
}

/*
 * Sets if the weapon can fire primary ammo under water.
 * 
 * @param weapon		Weapon Entity.
 * @param can			True or False.
 * @noreturn
 */
stock Weapon_SetFiresUnderWater(weapon, bool:can=true)
{
	SetEntProp(weapon, Prop_Data, "m_bFiresUnderwater", _:can);
}

/*
 * Returns whether the weapon can fire secondary ammo under water.
 * 
 * @param weapon		Weapon Entity.
 * @return				True or False.
 */
stock bool:Weapon_FiresUnderWaterAlt(weapon)
{
	return bool:GetEntProp(weapon, Prop_Data, "m_bAltFiresUnderwater");
}

/*
 * Sets if the weapon can fire secondary ammo under water.
 * 
 * @param weapon		Weapon Entity.
 * @param can			True or False.
 * @noreturn
 */
stock Weapon_SetFiresUnderWaterAlt(weapon, bool:can=true)
{
	SetEntProp(weapon, Prop_Data, "m_bAltFiresUnderwater", _:can);
}

/*
 * Gets the primary ammo Type (int offset)
 * 
 * @param weapon		Weapon Entity.
 * @return				Primary ammo type value.
 */
stock Weapon_GetPrimaryAmmoType(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");
}

/*
 * Sets the primary ammo Type (int offset)
 * 
 * @param weapon		Weapon Entity.
 * @param type			Primary ammo type value.
 */
stock Weapon_SetPrimaryAmmoType(weapon,type)
{
	return SetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType", type);
}

/*
 * Gets the secondary ammo Type (int offset)
 * 
 * @param weapon		Weapon Entity.
 * @return				Secondary ammo type value.
 */
stock Weapon_GetSecondaryAmmoType(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iSecondaryAmmoType");
}

/*
 * Sets the secondary ammo Type (int offset)
 * 
 * @param weapon		Weapon Entity.
 * @param type			Secondary ammo type value.
 */
stock Weapon_SetSecondaryAmmoType(weapon,type)
{
	return SetEntProp(weapon, Prop_Data, "m_iSecondaryAmmoType", type);
}

/*
 * Gets the primary clip count of a weapon.
 * 
 * @param weapon		Weapon Entity.
 * @return				Primary Clip count.
 */
stock Weapon_GetPrimaryClip(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iClip1");
}

/*
 * Sets the primary clip count of a weapon.
 * 
 * @param weapon		Weapon Entity.
 * @param value			Clip Count value.
 */
stock Weapon_SetPrimaryClip(weapon, value)
{
	SetEntProp(weapon, Prop_Data, "m_iClip1", value);
}

/*
 * Gets the secondary clip count of a weapon.
 * 
 * @param weapon		Weapon Entity.
 * @return				Secondy Clip count.
 */
stock Weapon_GetSecondaryClip(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iClip2");
}

/*
 * Sets the secondary clip count of a weapon.
 * 
 * @param weapon		Weapon Entity.
 * @param value			Clip Count value.
 */
stock Weapon_SetSecondaryClip(weapon, value)
{
	SetEntProp(weapon, Prop_Data, "m_iClip2", value);
}

/*
 * Sets the primary & secondary clip count of a weapon.
 * 
 * @param weapon		Weapon Entity.
 * @param primary		Primary Clip Count value.
 * @param secondary		Primary Clip Count value.
 */
stock Weapon_SetClips(weapon, primary, secondary)
{
	Weapon_SetPrimaryClip(weapon, primary);
	Weapon_SetSecondaryClip(weapon, secondary);
}

/*
 * Gets the primary ammo count of a weapon.
 * This is only used when the weapon is not carried
 * by a player to give a player ammo when he picks up
 * the weapon.
 * 
 * @param weapon		Weapon Entity.
 * @return				Primary Ammo Count.
 */
stock Weapon_GetPrimaryAmmoCount(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoCount");
}

/*
 * Sets the primary ammo count of a weapon.
 * This is only used when the weapon is not carried
 * by a player to give a player ammo when he picks up
 * the weapon.
 * 
 * @param weapon		Weapon Entity.
 * @param value			Primary Ammo Count.
 * @noreturn
 */
stock Weapon_SetPrimaryAmmoCount(weapon, value)
{
	SetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoCount", value);
}

/*
 * Gets the secondary ammo count of a weapon.
 * This is only used when the weapon is not carried
 * by a player to give a player ammo when he picks up
 * the weapon.
 * 
 * @param weapon		Weapon Entity.
 * @return				Secondary Ammo Count.
 */
stock Weapon_GetSecondaryAmmoCount(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iSecondaryAmmoCount");
}

/*
 * Sets the secodary ammo count of a weapon.
 * This is only used when the weapon is not carried
 * by a player to give a player ammo when he picks up
 * the weapon.
 * 
 * @param weapon		Weapon Entity.
 * @param value			Secondary Ammo Count.
 * @noreturn
 */
stock Weapon_SetSecondaryAmmoCount(weapon, value)
{
	SetEntProp(weapon, Prop_Data, "m_iSecondaryAmmoCount", value);
}

/*
 * Sets both, the primary & the secondary ammo count of a weapon.
 * This is only used when the weapon is not carried
 * by a player to give a player ammo when he picks up
 * the weapon.
 * 
 * @param weapon		Weapon Entity.
 * @value primary		Primary Ammo Count.
 * @value secondary		Secondary Ammo Count.
 * @noreturn
 */
stock Weapon_SetAmmoCounts(weapon, primary, secondary)
{
	Weapon_SetPrimaryAmmoCount(weapon, primary);
	Weapon_SetSecondaryAmmoCount(weapon, secondary);
}

/*
 * Gets the Model Index of the weapon's view model.
 * 
 * @param weapon		Weapon Entity.
 * @return				View Model Index.
 */
stock Weapon_GetViewModelIndex(weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_nViewModelIndex");
}

/*
 * Sets the Model Index of the weapon's view model.
 * You can get the Model Index by precaching a model with PrecacheModel().
 * 
 * @param weapon		Weapon Entity.
 * @param index			Model Index.
 * @noreturn
 */
stock Weapon_SetViewModelIndex(weapon, index)
{
	SetEntProp(weapon, Prop_Data, "m_nViewModelIndex", index);
	ChangeEdictState(weapon, FindDataMapInfo(weapon, "m_nViewModelIndex"));
}

