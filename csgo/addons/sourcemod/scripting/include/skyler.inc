/*
**
*/
#if defined _INCLUDE_included
 #endinput
#endif
#define _INCLUDE_included


stock int GetAlivePlayerAmount()
{
	int amount;
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && IsPlayerAlive(i) && IsValidClient(i))
		amount++;
	
	return amount;
}

/*
 * Returns All players are alive in the Counter Terrorist.
 *
 * @return
 */
stock int GetAlivePlayerAmountTeamCT()
{
	int amount;
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT && IsValidClient(i))
		amount++;
	
	return amount;
}

/*
 * Returns All players are alive in the Terrorist.
 *
 * @return
 */
stock int GetAlivePlayerAmountTeamT()
{
	int amount;
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && IsValidClient(i))
		amount++;
	
	return amount;
}

/*
 * Give ammout of all players are in the counter terrorist team.
 *
 * @return
 */
stock int GetPlayerAmountTeamCT()
{
	int amount;
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_CT && IsValidClient(i))
		amount++;
	
	return amount;
}

/*
 * Give ammout of all players are in the terrorist team.
 *
 * @return
 */
stock int GetPlayerAmountTeamT()
{
	int amount;
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsValidClient(i))
		amount++;
	
	return amount;
}

/*
 * Returns All players are True Players.
 *
 * @return
 */
stock bool IsValidClient(int client)
{
	if (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		return true;
	}
	
	return false;
}
/*
 * Gets the primary clip count of a weapon.
 * 
 * @param weapon        Weapon Entity.
 * @return                Primary Clip count.
 */
stock skyler_GetPrimaryAmmo(weapon)
{
    return GetEntProp(weapon, Prop_Data, "m_iClip1");
}
/*
 * Sets the primary ammo count of a weapon.
 * 
 * @param weapon        Weapon Entity.
 * @param value            Clip Count value.
 */
stock skyler_SetPrimaryAmmo(weapon,ammo)
{
    SetEntProp(weapon, Prop_Data, "m_iClip1", ammo);
}
/*
 * Gets the secondary clip count of a weapon.
 * 
 * @param weapon        Weapon Entity.
 * @return                Primary Clip count.
 */
stock skyler_GetSecondaryAmmo(weapon)
{
    return     GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
}
/*
 * Sets the secondary ammo count of a weapon.
 * 
 * @param weapon        Weapon Entity.
 * @param value            Clip Count value.
 */
stock skyler_SetSecondaryAmmo(weapon,ammo)
{
    SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
}
/*
 * Sets the primarty and secondary ammo count of a weapon.
 * 
 * @param weapon        Weapon Entity.
 * @param value            Primary ammo Count value.
 * @param value            Primary ammo Count value.
 */
stock skyler_SetWeaponAmmo(weapon,primaryammo,secondaryammo)
{
    skyler_SetPrimaryAmmo(weapon, primaryammo);
    skyler_SetSecondaryAmmo(weapon, secondaryammo);
}
/*
 * Gets the primary and secondary clip count of a weapon.
 * 
 * @param weapon                     Weapon Entity.
 * @param primaryammo                Primary Clip count.
 * @param secondaryammo                Secondary Clip count.
 */
stock skyler_GetWeaponAmmo(weapon,&primaryammo,&secondaryammo)
{
    primaryammo = skyler_GetPrimaryAmmo(weapon);
    secondaryammo = skyler_GetSecondaryAmmo(weapon);
}  

/*stock RemoveAllWeapons(int client)
{
	int iWeapon;
	for (int k = 0; k <= 6; k++)
	{
		iWeapon = GetPlayerWeaponSlot(client, k);
		
		if (IsValidEdict(iWeapon))
		{
			RemovePlayerItem(client, iWeapon);
			RemoveEdict(iWeapon);
		}
	}
}*/

enum DaysStatus( += 1)
{
    Days_None = 0, 
    Days_Scout, 
    Days_Backstab, 
    Days_Tag, 
    Days_War,
    Days_HNS, 
    Days_Grenede, 
    Days_Pistol, 
    Days_Knife, 
    Days_Headshot, 
    Days_Shotgun, 
    Days_Laser, 
    Days_Dogeball
};