/**
 * =============================================================================
 * Zombie Plague X Copyright (C) 2015-2020 Nikita Ushakov (Ireland, Dublin).
 * =============================================================================
 *
 * This file is part of the Zombie Plague Core.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 **/

#if defined _weaponlist_included
 #endinput
#endif
#define _weaponlist_included

/**
 * @section Number of valid slots.
 **/
enum SlotType
{ 
	SlotType_Invalid = -1,        /** Used as return value when a slot doens't exist. */
	
	SlotType_Primary,             /** Primary slot */
	SlotType_Secondary,           /** Secondary slot */
	SlotType_Melee,               /** Melee slot */
	SlotType_Equipment,           /** Equipment slot */  
	SlotType_C4,                  /** C4 slot */  
};
/**
 * @endsection
 **/
 
/**
 * @section Number of valid menus.
 **/
enum MenuType
{
	MenuType_Invalid = -1,        /** Used as return value when a menu doens't exist. */
	
	MenuType_Pistols,             /** Pistol menu */
	MenuType_Shotguns,            /** Shotgun menu */
	MenuType_Rifles,              /** Rifle menu */
	MenuType_Snipers,             /** Sniper menu */
	MenuType_Machineguns,         /** Machineguns menu */
	MenuType_Knifes,              /** Knife menu */
	MenuType_Equipments           /** Equipment menu */
};
/**
 * @endsection
 **/
 
/**
 * @section Number of valid addons.
 **/
enum BitType
{
	BitType_Invalid = -1,         /** Used as return value when an bit doens't exist. */
	
	BitType_PrimaryWeapon,        /** Primary bit */
	BitType_SecondaryWeapon,      /** Secondary bit */
	BitType_Flashbang1,           /** Flashbang1 bit */
	BitType_Flashbang2,           /** Flashbang2 bit */
	BitType_HEGrenade,            /** Hegrenade bit */
	BitType_SmokeGrenade,         /** Smokegrenade bit */
	BitType_Decoy,                /** Decoy bit */
	BitType_Knife,                /** Knife bit */
	BitType_TaGrenade,            /** Tagrenade bit */
	BitType_C4,                   /** C4 bit */
	BitType_DefuseKit,            /** Defuse bit */
	BitType_Shield                /** Shield bit */
};
/**
 * @endsection
 **/
 
/**
 * @section Number of valid models.
 **/
enum ModelType
{
	ModelType_Invalid = -1,        /** Used as return value when a model doens't exist. */
	
	ModelType_View,                /** View model */
	ModelType_World,               /** World model */
	ModelType_Drop,                /** Dropped model */
	ModelType_Projectile           /** Projectile model */
};
/**
 * @endsection
 **/
 
/**
 * @brief Called before show a weapon in the weapons menu.
 * 
 * @param client            The client index.
 * @param weaponID          The weapon index.
 *
 * @return                  Plugin_Handled to disactivate showing and Plugin_Stop to disabled showing. Anything else
 *                              (like Plugin_Continue) to allow showing and selecting.
 **/
forward Action ZP_OnClientValidateWeapon(int client, int weaponID);
 
/**
 * @brief Called after a custom grenade is created. (Only for projectiles)
 *
 * @param client            The client index.
 * @param grenade           The grenade index.
 * @param weaponID          The weapon id.
 **/
forward void ZP_OnGrenadeCreated(int client, int grenade, int weaponID);

/**
 * @brief Called before a grenade sound is emitted.
 *
 * @param grenade           The grenade index.
 * @param weaponID          The weapon id.
 *
 * @return                  Plugin_Continue to allow sounds. Anything else
 *                              (like Plugin_Stop) to block sounds.
 **/
forward Action ZP_OnGrenadeSound(int grenade, int weaponID);

/**
 * @brief Called after a custom weapon is created.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 **/
forward void ZP_OnWeaponCreated(int client, int weapon, int weaponID);

/**
 * @brief Called on each frame of a weapon holding.
 *
 * @param client            The client index.
 * @param iButtons          The buttons buffer.
 * @param iLastButtons      The last buttons buffer.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @return                  Plugin_Continue to allow buttons. Anything else 
 *                                (like Plugin_Changed) to change buttons.
 **/
forward Action ZP_OnWeaponRunCmd(int client, int &iButtons, int iLastButtons, int weapon, int weaponID);

/**
 * @brief Called on deploy of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @noreturn
 **/
forward void ZP_OnWeaponDeploy(int client, int weapon, int weaponID);

/**
 * @brief Called on holster of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @noreturn
 **/
forward void ZP_OnWeaponHolster(int client, int weapon, int weaponID);

/**
 * @brief Called on reload of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @noreturn
 **/
forward void ZP_OnWeaponReload(int client, int weapon, int weaponID);

/**
 * @brief Called on bullet of a weapon.
 *
 * @param client            The client index.
 * @param vBullet           The position of a bullet hit.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @noreturn
 **/
forward void ZP_OnWeaponBullet(int client, float vBullet[3], int weapon, int weaponID);

/**
 * @brief Called on shoot of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @noreturn
 **/
forward void ZP_OnWeaponShoot(int client, int weapon, int weaponID);

/**
 * @brief Called on fire of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @noreturn
 **/
forward void ZP_OnWeaponFire(int client, int weapon, int weaponID);

/**
 * @brief Called on drop of a weapon.
 *
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 *
 * @noreturn
 **/
forward void ZP_OnWeaponDrop(int weapon, int weaponID);

/**
 * @brief Creates the weapon by a given id.
 *
 * @param weaponID          The weapon id.
 * @param origin            The origin of the spawn.
 * @param angle             The angle of the spawn.
 *
 * @return                  The weapon index.
 **/
native int ZP_CreateWeapon(int weaponID, float origin[3], float angle[3]);

/**
 * @brief Emulate bullet shot on the server and does the damage calculations.
 *
 * @param clientIndex       The client index.
 * @param weaponIndex       The weapon index.
 * @param origin            The position to the spawn.
 * @param angle             The angle to the spawn.
 * @param mode              The mode index.
 * @param seed              The randomizing seed.
 * @param inaccuracy        The inaccuracy variable.
 * @param spread            The spread variable.
 * @param fishtail          The fishtail variable.
 * @param sound             The sound type.
 * @param recoil            The recoil variable.
 *
 * @return                  True or false.
 **/
native void ZP_FireBullets(int clientIndex, int weaponIndex, float origin[3], float angle[3], int mode, int seed, float inaccuracy, float spread, float fishtail, int sound, float recoil);

/**
 * @brief Gives the weapon by a given name.
 *
 * @param client            The client index.
 * @param weaponID          The weapon ID.
 *
 * @return                  The weapon index.
 **/
native int ZP_GiveClientWeapon(int client, int weaponID);

/**
 * @brief Switches the weapon by an index.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 **/
native void ZP_SwitchClientWeapon(int client, int weapon);

/**
 * @brief Gets the client viewmodel. 
 *
 * @param client            The client index.
 * @param custom            True to gets the custom viewmodel, false the original.
 *           
 * @return                  The viewmodel index.
 **/
native int ZP_GetClientViewModel(int client, bool custom);

/**
 * @brief Gets the client attachmodel. (On the player's backpack)
 *
 * @param client            The client index.
 * @param bits              The bit type.
 *         
 * @return                  The attachmodel index.
 **/
native int ZP_GetClientAttachModel(int client, BitType bits);

/**
 * @brief Gets the custom weapon id from a given name.
 *
 * @param name              The weapon name.
 *
 * @return                  The weapon ID or -1 if no weapon was found.
 **/
native int ZP_GetWeaponNameID(char[] name);

/**
 * @brief Gets the amount of all weapons.
 *
 * @return                  The weapon amount.    
 **/
native int ZP_GetNumberWeapon();

/**
 * @brief Gets the name of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param name              The string to return name in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponName(int weaponID, char[] name, int maxlenght = 32);

/**
 * @brief Gets the info of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param info              The string to return info in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponInfo(int weaponID, char[] info, int maxlenght = 128);

/**
 * @brief Gets the defenition index of the weapon.
 *
 * @param weaponID          The weapon ID.
 *
 * @return                  The def index. 
 **/
native ItemDef ZP_GetWeaponDefIndex(int weaponID);

/**
 * @brief Gets the group of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param group             The string to return group in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponGroup(int weaponID, char[] group, int maxlenght = 32);

/**
 * @brief Gets the class of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param class             The string to return class in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponClass(int weaponID, char[] class, int maxlenght = 128);

/**
 * @brief Gets the cost of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The cost amount.    
 **/
native int ZP_GetWeaponCost(int weaponID);

/**
 * @brief Gets the menu slot of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The weapon slot.    
 **/
native MenuType ZP_GetWeaponSlot(int weaponID);

/**
 * @brief Gets the level of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The level amount.    
 **/
native int ZP_GetWeaponLevel(int weaponID);

/**
 * @brief Gets the online of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The online amount.    
 **/
native int ZP_GetWeaponOnline(int weaponID);

/**
 * @brief Gets the limit of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The limit amount.    
 **/
native int ZP_GetWeaponLimit(int weaponID);

/**
 * @brief Gets the damage of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The damage amount.    
 **/
native float ZP_GetWeaponDamage(int weaponID);

/**
 * @brief Gets the knockback of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The knockback amount.    
 **/
native float ZP_GetWeaponKnockBack(int weaponID);

/**
 * @brief Gets the clip ammo of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The clip ammo amount.
 **/
native int ZP_GetWeaponClip(int weaponID);

/**
 * @brief Gets the reserve clip of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The reserve ammo amount.    
 **/
native int ZP_GetWeaponAmmo(int weaponID);

/**
 * @brief Gets the ammunition cost of the weapon.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The ammunition cost.    
 **/
native int ZP_GetWeaponAmmunition(int weaponID);

/**
 * @brief Checks the drop state of the weapon.
 *
 * @param weaponID          The weapon ID.
 *
 * @return                  True or false.   
 **/
native bool ZP_IsWeaponDrop(int weaponID);

/**
 * @brief Gets the shoot delay of the weapon.
 *
 * @param weaponID          The weapon ID.
 *
 * @return                  The delay amount.    
 **/
native float ZP_GetWeaponSpeed(int weaponID);

/**
 * @brief Gets the reload duration of the weapon.
 *
 * @param weaponID          The weapon ID.
 *
 * @return                  The duration amount.    
 **/
native float ZP_GetWeaponReload(int weaponID);

/**
 * @brief Gets the delpoy duration of the weapon.
 *
 * @param weaponID          The weapon ID.
 *
 * @return                  The duration amount.    
 **/
native float ZP_GetWeaponDeploy(int weaponID);

/**
 * @brief Gets the sound key of the weapon.
 *
 * @param weaponID          The weapon ID.
 *
 * @return                  The key index.
 **/
native int ZP_GetWeaponSoundID(int weaponID);

/**
 * @brief Gets the icon of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param icon              The string to return icon in.
 * @param maxlenght         The lenght of string.
 **/
native int ZP_GetWeaponIcon(int weaponID, char[] icon, int maxlenght = 32);

/**
 * @brief Gets the viewmodel path of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param model             The string to return model in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponModelView(int weaponID, char[] model, int maxlenght = 256);

/**
* @brief Gets the index of the weapon viewmodel.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The viewmodel index.    
 **/
native int ZP_GetWeaponModelViewID(int weaponID);

/**
 * @brief Gets the worldmodel path of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param model             The string to return model in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponModelWorld(int weaponID, char[] model, int maxlenght = 256);

/**
 * @brief Gets the index of the weapon worldmodel.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The worldmodel index.    
 **/
native int ZP_GetWeaponModelWorldID(int weaponID);

/**
 * @brief Gets the dropmodel path of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param model             The string to return model in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponModelDrop(int weaponID, char[] model, int maxlenght = 256);

/**
 * @brief Gets the index of the weapon dropmodel.
 * 
 * @param weaponID          The weapon ID.
 *
 * @return                  The dropmodel index.    
 **/
native int ZP_GetWeaponModelDropID(int weaponID);

/**
 * @brief Gets the body index of the weapon model.
 *
 * @param weaponID          The weapon ID.
 * @param model             The model type.
 *
 * @return                  The body index.    
 **/
native int ZP_GetWeaponModelBody(int weaponID, ModelType model);

/**
 * @brief Gets the skin index of the weapon model.
 *
 * @param weaponID          The weapon ID.
 * @param model             The model type.
 *
 * @return                  The skin index.    
 **/
native int ZP_GetWeaponModelSkin(int weaponID, ModelType model);

/**
 * @brief Gets the muzzle name of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param muzzle            The string to return muzzle in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponModelMuzzle(int weaponID, char[] muzzle, int maxlenght = 64); 

/**
 * @brief Gets the shell name of a weapon at a given id.
 *
 * @param weaponID          The weapon ID.
 * @param shell             The string to return shell in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetWeaponModelShell(int weaponID, char[] shell, int maxlenght = 64); 

/**
 * @brief Gets the heat amount of the weapon model.
 *
 * @param weaponID          The weapon ID.
 *
 * @return                  The heat amount.    
 **/
native float ZP_GetWeaponModelHeat(int weaponID);

/**
 * @brief Returns index if the player has a current weapon.
 *
 * @param client            The client index.
 * @param weaponID          The weapon id.
 *
 * @return                  The weapon index.
 **/
stock int ZP_IsPlayerHasWeapon(int client, int weaponID)
{
	// i = weapon number
	static int iSize; if (!iSize) iSize = GetEntPropArraySize(client, Prop_Data, "m_hMyWeapons");
	for (int i = 0; i < iSize; i++)
	{
		// Gets weapon index
		int weapon = GetEntPropEnt(client, Prop_Data, "m_hMyWeapons", i);
		
		// If entity isn't valid, then skip
		if (weapon != -1)
		{
			// If weapon find, then return
			if (GetEntProp(weapon, Prop_Data, "m_iHammerID") == weaponID)
			{
				return weapon;
			}
		}
		
		// Go to next weapon
		continue;
	}

	// If wasn't found
	return -1;
}

/**
 * @brief Returns true if the player hold a current weapon, false if not.
 * 
 * @param client            The client index. 
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 * 
 * @return                  True or false.
 **/
stock bool ZP_IsPlayerHoldWeapon(int client, int &weapon, int weaponID)
{
	// Validate client
	if (!IsPlayerExist(client))
	{
		return false;
	}

	// Gets weapon index
	weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	// If entity isn't valid, then stop
	if (weapon == -1)
	{
		return false;
	}

	// If weapon didn't find, then stop
	if (GetEntProp(weapon, Prop_Data, "m_iHammerID") != weaponID)
	{
		return false;
	}

	// Return on success
	return true;
}

/**
 * @brief Gets the weapon shoot position.
 *
 * @param client            The client index.
 * @param flForward         (Optional) The forward distance.
 * @param flRight           (Optional) The right distance. 
 * @param flVertical        (Optional) The vertical distance.
 * @param vOutput           The calculated position vector output.
 **/
stock void ZP_GetPlayerGunPosition(int client, float flForward = 0.0, float flRight = 0.0, float flVertical = 0.0, float vOutput[3])
{
	// Initialize vectors
	static float vPosition[3]; static float vAngle[3]; static float vForward[3]; static float vRight[3];  static float vVertical[3]; 

	// Gets client eye angle
	GetClientEyePosition(client, vPosition);
	
	// Gets client eye angle
	GetClientEyeAngles(client, vAngle);

	// Returns vectors in the direction of an angle
	GetAngleVectors(vAngle, vForward, vRight, vVertical);

	// Calculate ends point by applying all vectors distances 
	vOutput[0] = vPosition[0] + (vForward[0] * flForward) + (vRight[0] * flRight) + (vVertical[0] * flVertical);
	vOutput[1] = vPosition[1] + (vForward[1] * flForward) + (vRight[1] * flRight) + (vVertical[1] * flVertical);
	vOutput[2] = vPosition[2] + (vForward[2] * flForward) + (vRight[2] * flRight) + (vVertical[2] * flVertical);
}

/**
 * @brief Gets the weapon animating index.
 *
 * @param client            The client index.
 *
 * @return                  The sequence index.
 **/
stock int ZP_GetWeaponAnimation(int client)
{
	// Gets client viewmodel
	int view = ZP_GetClientViewModel(client, true); /// Gets anims on the custom model 

	// Validate viewmodel
	if (view != -1)
	{
		// Gets animation
		return GetEntProp(view, Prop_Send, "m_nSequence");
	}
	
	// Return on unsuccess
	return -1;
}

/**
 * @brief Sets the weapon animating index.
 *
 * @param client            The client index.
 * @param nSequence         The sequence index.
 **/
stock void ZP_SetWeaponAnimation(int client, int nSequence)
{
	// Gets client viewmodel
	int view = ZP_GetClientViewModel(client, false); /// Play anims on the original model 

	// Validate viewmodel
	if (view != -1)
	{
		// Sets animation
		SetEntProp(view, Prop_Send, "m_nSequence", nSequence);
	}
}

/**
 * @brief Sets the weapon animating paired index. (Important for animations, which should played in the not-repeatable row, like an attack to avoid parity)
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param nSequence         The sequence array.
 **/
stock void ZP_SetWeaponAnimationPair(int client, int weapon, int nSequence[2])
{
	// Gets client viewmodel
	int view = ZP_GetClientViewModel(client, false); /// Play anims on the original model 

	// Validate viewmodel
	if (view != -1)
	{
		// Gets the current played state of animation
		bool bPrevAnim = view_as<bool>(GetEntProp(weapon, Prop_Send, "m_bSilencerOn"));
		
		// Sets animation
		SetEntProp(view, Prop_Send, "m_nSequence", nSequence[bPrevAnim ? 0 : 1]);
		
		// Sets inversed played state
		SetEntProp(weapon, Prop_Send, "m_bSilencerOn", !bPrevAnim);
	}
}

/**
 * @brief Returns index if the player has a weapon.
 *
 * @param client            The client index.
 * @param sType             The weapon entity.
 *
 * @return                  The weapon index.
 **/
stock int ZP_GetPlayerWeapon(int client, char[] sType)
{
	// Initialize name char
	static char sClassname[SMALL_LINE_LENGTH];

	// i = weapon number
	static int iSize; if (!iSize) iSize = GetEntPropArraySize(client, Prop_Data, "m_hMyWeapons");
	for (int i = 0; i < iSize; i++)
	{
		// Gets weapon index
		int weapon = GetEntPropEnt(client, Prop_Data, "m_hMyWeapons", i);

		// Validate weapon
		if (weapon != -1)
		{
			// Gets weapon classname
			GetEdictClassname(weapon, sClassname, sizeof(sClassname));

			// If weapon find, then return
			if (!strcmp(sClassname[7], sType[7], false))
			{
				return weapon;
			}
		}
	}

	// Weapon wasn't found
	return -1;
}

/**
 * @brief Remove a weapon from the player.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param slot              (Optional) The slot index to replace.
 **/
stock void ZP_RemoveWeapon(int client, int weapon, SlotType slot = SlotType_Melee)
{
	// Gets weapon index
	int weapon2 = GetPlayerWeaponSlot(client, view_as<int>(slot));
	
	// Validate weapon
	if (weapon2 != -1)
	{
		// Switch weapon
		ZP_SwitchClientWeapon(client, weapon2);
	}
	
	// Forces a player to remove weapon
	RemovePlayerItem(client, weapon);
	AcceptEntityInput(weapon, "Kill");
}

/**
 * @brief Create the tracer to a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param sAttach1          The attachment name. (view)
 * @param sAttach2          The attachment name. (world)
 * @param sEffect           The effect name.
 * @param vBullet           The position of a bullet hit.
 * @param flDurationTime    The duration of life.
 **/
stock void ZP_CreateWeaponTracer(int client, int weapon, char[] sAttach1, char[] sAttach2, char[] sEffect, float vBullet[3], float flDurationTime)
{
	// Validate name
	if (!hasLength(sEffect))
	{
		return;
	}
	
	#define ClientSrt  0
	#define ClientEnd  1
	#define ViewerSrt  2
	#define ViewerEnd  3
								/** Regards to Phoenix **/
							 /** Dont ask me how it works ;) **/

	// Gets client view/world model
	int view = ZP_GetClientViewModel(client, true);
	int world = GetEntPropEnt(weapon, Prop_Send, "m_hWeaponWorldModel");

	// Validate models
	if (view == -1 || world == -1)
	{    
		return;
	}

	// Validate attachments
	if ((sAttach1[0] != NULL_STRING[0] && !ZP_LookupAttachment(view, sAttach1)) || (sAttach2[0] != NULL_STRING[0] && !ZP_LookupAttachment(world, sAttach2)))
	{
		return;
	}

	// Create an attach particle entity
	static int entity[4];
	entity[ClientSrt] = CreateEntityByName("info_particle_system");
	entity[ClientEnd] = CreateEntityByName("info_particle_system");
	entity[ViewerSrt] = CreateEntityByName("info_particle_system");
	entity[ViewerEnd] = CreateEntityByName("info_particle_system");

	// If entity isn't valid, then skip
	if (entity[ViewerEnd] != -1) /// Check the last entity ;)
	{
		// Gets the client angle
		static float vAngle[3]; static float vEmpty[3];
		GetEntPropVector(client, Prop_Data, "m_angAbsRotation", vAngle);
		
		// Teleport the entity
		TeleportEntity(entity[ClientEnd], vBullet, vAngle, NULL_VECTOR);
		TeleportEntity(entity[ViewerEnd], vBullet, vAngle, NULL_VECTOR);

		// Dispatch main values of the entity
		static char sClassname[SMALL_LINE_LENGTH];
		FormatEx(sClassname, sizeof(sClassname), "particle%d", entity[ClientSrt]);
		DispatchKeyValue(entity[ClientSrt], "targetname", sClassname);
		DispatchKeyValue(entity[ClientEnd], "effect_name", sEffect);
		DispatchKeyValue(entity[ClientEnd], "cpoint1", sClassname);
		
		// Spawn the entity into the world
		DispatchSpawn(entity[ClientEnd]);
		
		// Sets owner to the entity 
		SetEntPropEnt(entity[ClientEnd], Prop_Data, "m_hOwnerEntity", client);
		
		// Dispatch main values of the entity
		FormatEx(sClassname, sizeof(sClassname), "particle%d",  entity[ViewerSrt]);
		DispatchKeyValue(entity[ViewerSrt], "targetname", sClassname);
		DispatchKeyValue(entity[ViewerEnd], "effect_name", sEffect);
		DispatchKeyValue(entity[ViewerEnd], "cpoint1", sClassname);
		
		// Spawn the entity into the world
		DispatchSpawn(entity[ViewerEnd]);
		
		// Sets owner to the entity 
		SetEntPropEnt(entity[ViewerEnd], Prop_Data, "m_hOwnerEntity", client);

		// Teleport the entity
		TeleportEntity(entity[ViewerSrt], NULL_VECTOR, vAngle, NULL_VECTOR);

		// Sets parent to the entity
		SetVariantString("!activator");
		AcceptEntityInput(entity[ViewerSrt], "SetParent", world,  entity[ViewerSrt]);
		
		// Sets attachment to the entity
		SetVariantString(sAttach2);
		AcceptEntityInput(entity[ViewerSrt], "SetParentAttachment",  entity[ViewerSrt], entity[ViewerSrt]);

		// Teleport the entity
		TeleportEntity(entity[ViewerSrt], vEmpty, NULL_VECTOR, NULL_VECTOR);

		// Sets parent to the entity
		SetVariantString("!activator");
		AcceptEntityInput(entity[ClientSrt], "SetParent", view, entity[ClientSrt]);
		
		// Sets attachment to the entity
		SetVariantString(sAttach1);
		AcceptEntityInput(entity[ClientSrt], "SetParentAttachment", entity[ClientSrt], entity[ClientSrt]);

		/*______________________________________________________________________________*/
		
		// Hook entity callbacks 
		SDKHook(entity[ClientEnd], SDKHook_SetTransmit, TracerClientTransmit);
		SDKHook(entity[ViewerEnd], SDKHook_SetTransmit, TracerViewerTransmit);

		// Activate the entity
		ActivateEntity(entity[ClientEnd]);
		AcceptEntityInput(entity[ClientEnd], "Start");
		ActivateEntity(entity[ViewerEnd]);
		AcceptEntityInput(entity[ViewerEnd], "Start");

		// Initialize time char
		UTIL_RemoveEntity(entity[ClientEnd], flDurationTime);
		UTIL_RemoveEntity(entity[ViewerEnd], flDurationTime);
		UTIL_RemoveEntity(entity[ClientSrt], flDurationTime);
		UTIL_RemoveEntity(entity[ViewerSrt], flDurationTime);
	}
}

/**
 * @brief Create the kickback effect to a weapon .
 *
 * @param client            The client index.
 * @param upBase            The upward base amount.
 * @param lateralBase       The lateral base amount.
 * @param upMod             The upward mod amount.
 * @param lateralMod        The lateral mod amount.
 * @param upMax             The upward max amount.
 * @param directionChange   The direction seed.
 **/
stock void ZP_CreateWeaponKickBack(int client, float upBase, float lateralBase, float upMod, float lateralMod, float upMax, float lateralMax, int directionChange)
{
	// Initialize variables
	static int iDirection; static int iShotsFired; static float vPunchAngle[3];
	GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", vPunchAngle);

	// Gets a shots fired
	if ((iShotsFired = GetEntProp(client, Prop_Send, "m_iShotsFired")) != 1)
	{
		// Calculate a base power
		upBase += iShotsFired * upMod;
		lateralBase += iShotsFired * lateralMod;
	}

	// Reduce a max power
	upMax *= -1.0;
	vPunchAngle[0] -= upBase;

	// Validate max angle
	if (upMax >= vPunchAngle[0])
	{
		vPunchAngle[0] = upMax;
	}

	// Gets a direction change
	if ((iDirection = GetEntProp(client, Prop_Send, "m_iDirection")))
	{
		// Increase the angle
		vPunchAngle[1] += lateralBase;

		// Validate min angle
		if (lateralMax < vPunchAngle[1])
		{
			vPunchAngle[1] = lateralMax;
		}
	}
	else
	{
		// Decrease the angle
		lateralMax *=  -1.0;
		vPunchAngle[1] -= lateralBase;

		// Validate max angle
		if (lateralMax > vPunchAngle[1])
		{
			vPunchAngle[1] = lateralMax;
		}
	}

	// Create a direction change
	if (!GetRandomInt(0, directionChange))
	{
		SetEntProp(client, Prop_Send, "m_iDirection", !iDirection);
	}

	// Sets a punch angle
	SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", vPunchAngle);
	SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", vPunchAngle);
}

//**********************************************
//* Tracer hooks.                              * 
//**********************************************

/**
 * Hook: SetTransmit
 * @brief Called right before the entity transmitting to other entities.
 *
 * @param entity            The entity index.
 * @param client            The client index.
 **/
public Action TracerClientTransmit(int entity, int client) 
{
	// Allow particle to be transmittable
	if (GetEdictFlags(entity) & FL_EDICT_ALWAYS)
	{
		SetEdictFlags(entity, (GetEdictFlags(entity) ^ FL_EDICT_ALWAYS));
	}
	
	// Gets the owner of the entity
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	
	// Validate observer mode
	if (owner == client || (GetEntProp(client, Prop_Data, "m_iObserverMode") == SPECMODE_FIRSTPERSON && owner == GetEntPropEnt(client, Prop_Data, "m_hObserverTarget")))
	{
		// Allow transmitting
		return Plugin_Continue;
	}
	
	// Block transmitting
	return Plugin_Handled;
}

/**
 * Hook: SetTransmit
 * @brief Called right before the entity transmitting to other entities.
 *
 * @param entity            The entity index.
 * @param client            The client index.
 **/
public Action TracerViewerTransmit(int entity, int client) 
{
	// Allow particle to be transmittable
	if (GetEdictFlags(entity) & FL_EDICT_ALWAYS)
	{
		SetEdictFlags(entity, (GetEdictFlags(entity) ^ FL_EDICT_ALWAYS));
	}
	
	// Gets the owner of the entity
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	
	// Validate observer mode
	if (owner == client || (GetEntProp(client, Prop_Data, "m_iObserverMode") == SPECMODE_FIRSTPERSON && owner == GetEntPropEnt(client, Prop_Data, "m_hObserverTarget")))
	{
		// Block transmitting
		return Plugin_Handled;
	}
	
	// Allow transmitting
	return Plugin_Continue;
}