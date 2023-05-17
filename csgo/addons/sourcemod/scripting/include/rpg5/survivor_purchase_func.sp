SurvivorPurchaseFunc(client)
{
	if (GetClientTeam(client) != 2) return;
	if (PurchaseItem[client] == 1) ItemCost[client] = Tier2Cost[client];
	else if (PurchaseItem[client] == 2) ItemCost[client] = HealthItemCost[client];
	else if (PurchaseItem[client] == 3) ItemCost[client] = PersonalAbilitiesCost[client];
	else if (PurchaseItem[client] == 4) ItemCost[client] = WeaponUpgradeCost[client];
	
	if (SurvivorPoints[client] < ItemCost[client])
	{
		if ((SurvivorPoints[client] + SurvivorTeamPoints) < ItemCost[client] || SurvivorPoints[client] < 1.0)
		{
			PrintToChat(client, "%s \x01Insufficient points to purchase %s", INFO, ItemName[client]);
			return;
		}
		else SurvivorTeamPurchase[client] = true;
	}
	else SurvivorTeamPurchase[client] = false;
	
	if (PurchaseItem[client] == 1)
	{
		L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
		ExecCheatCommand(client, "give", ItemName[client]);
		LastWeaponOwned[client] = ItemName[client];
	}
	else if (PurchaseItem[client] == 2)
	{
		if (StrEqual(ItemName[client], "incap_protection", false))
		{
			IncapProtection[client] = GetConVarInt(IncapCount);
			CreateTimer(1.0, CheckIfEnsnared, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		else ExecCheatCommand(client, "give", ItemName[client]);
	}
	else if (PurchaseItem[client] == 3)
	{
		if (StrEqual(ItemName[client], "respawn_saferoom", false))
		{
			if (RescueCalled)
			{
				PrintToChat(client, "%s \x01The Final Hold-out is in progress, you cannot respawn!", ERROR_INFO);
				return;
			}
			if (RespawnType[client] == 2)
			{
				PrintToChat(client, "%s \x01Now queued to respawn at start of map.", INFO);
				RespawnType[client] = 1;
				return;
			}
			else RespawnType[client] = 1;
		}
		else if (StrEqual(ItemName[client], "respawn_corpse", false))
		{
			if (RescueCalled)
			{
				PrintToChat(client, "%s \x01The Final Hold-out is in progress, you cannot respawn!", ERROR_INFO);
				return;
			}
			if (RespawnType[client] == 1)
			{
				PrintToChat(client, "%s \x01Now queued to respawn on your corpse.", INFO);
				RespawnType[client] = 2;
				return;
			}
			else RespawnType[client] = 2;
		}
		else if (StrEqual(ItemName[client], "scout_ability", false)) Scout[client] = true;
		else if (StrEqual(ItemName[client], "hazmat_boots", false)) HazmatBoots[client] = GetConVarInt(PersonalAbilityAmmo);
		else if (StrEqual(ItemName[client], "eye_goggles", false)) EyeGoggles[client] = GetConVarInt(PersonalAbilityAmmo);
		else if (StrEqual(ItemName[client], "gravity_boots", false)) GravityBoots[client] = GetConVarInt(PersonalAbilityAmmo);
	}
	else if (PurchaseItem[client] == 4)
	{
		new String:WeaponUsed[64];
		GetClientWeapon(client, WeaponUsed, sizeof(WeaponUsed));
		if (StrEqual(WeaponUsed, "weapon_pistol", true) || 
			StrEqual(WeaponUsed, "weapon_pistol_magnum", true))
		{
			if (IceAmmoPistol[client] || BlindAmmoPistol[client] || HealAmmoPistol[client] || 
				BloatAmmoPistol[client]) return;
			if (StrEqual(ItemName[client], "bloat_ammo", false))
			{
				BloatAmmoPistol[client] = true;
				BloatAmmoAmountPistol[client] = GetConVarInt(BloatAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "blind_ammo", false))
			{
				BlindAmmoPistol[client] = true;
				BlindAmmoAmountPistol[client] = GetConVarInt(BlindAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "ice_ammo", false))
			{
				IceAmmoPistol[client] = true;
				IceAmmoAmountPistol[client] = GetConVarInt(IceAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "heal_ammo", false))
			{
				HealAmmoPistol[client] = true;
				HealAmmoAmountPistol[client] = GetConVarInt(HealAmmoAmount);
			}
		}
		else if (StrEqual(WeaponUsed, "weapon_smg", true) || 
				 StrEqual(WeaponUsed, "weapon_smg_silenced", true) || 
				 StrEqual(WeaponUsed, "weapon_smg_mp5", true))
		{
			if (IceAmmoSmg[client] || BlindAmmoSmg[client] || HealAmmoSmg[client] || 
				BloatAmmoSmg[client]) return;
			if (StrEqual(ItemName[client], "bloat_ammo", false))
			{
				BloatAmmoSmg[client] = true;
				BloatAmmoAmountSmg[client] = GetConVarInt(BloatAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "blind_ammo", false))
			{
				BlindAmmoSmg[client] = true;
				BlindAmmoAmountSmg[client] = GetConVarInt(BlindAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "ice_ammo", false))
			{
				IceAmmoSmg[client] = true;
				IceAmmoAmountSmg[client] = GetConVarInt(IceAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "heal_ammo", false))
			{
				HealAmmoSmg[client] = true;
				HealAmmoAmountSmg[client] = GetConVarInt(HealAmmoAmount);
			}
		}
		else if (StrEqual(WeaponUsed, "weapon_autoshotgun", true) || 
				 StrEqual(WeaponUsed, "weapon_pumpshotgun", true) || 
				 StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) || 
				 StrEqual(WeaponUsed, "weapon_shotgun_spas", true))
		{
			if (IceAmmoShotgun[client] || BlindAmmoShotgun[client] || HealAmmoShotgun[client] || 
				BloatAmmoShotgun[client]) return;
			if (StrEqual(ItemName[client], "bloat_ammo", false))
			{
				BloatAmmoShotgun[client] = true;
				BloatAmmoAmountShotgun[client] = GetConVarInt(BloatAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "blind_ammo", false))
			{
				BlindAmmoShotgun[client] = true;
				BlindAmmoAmountShotgun[client] = GetConVarInt(BlindAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "ice_ammo", false))
			{
				IceAmmoShotgun[client] = true;
				IceAmmoAmountShotgun[client] = GetConVarInt(IceAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "heal_ammo", false))
			{
				HealAmmoShotgun[client] = true;
				HealAmmoAmountShotgun[client] = GetConVarInt(HealAmmoAmount);
			}
		}
		else if (StrEqual(WeaponUsed, "weapon_rifle", true) || 
				 StrEqual(WeaponUsed, "weapon_rifle_ak47", true) || 
				 StrEqual(WeaponUsed, "weapon_rifle_desert", true) || 
				 StrEqual(WeaponUsed, "weapon_rifle_m60", true) || 
				 StrEqual(WeaponUsed, "weapon_rifle_sg552", true))
		{
			if (IceAmmoRifle[client] || BlindAmmoRifle[client] || HealAmmoRifle[client] || 
				BloatAmmoRifle[client]) return;
			if (StrEqual(ItemName[client], "bloat_ammo", false))
			{
				BloatAmmoRifle[client] = true;
				BloatAmmoAmountRifle[client] = GetConVarInt(BloatAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "blind_ammo", false))
			{
				BlindAmmoRifle[client] = true;
				BlindAmmoAmountRifle[client] = GetConVarInt(BlindAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "ice_ammo", false))
			{
				IceAmmoRifle[client] = true;
				IceAmmoAmountRifle[client] = GetConVarInt(IceAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "heal_ammo", false))
			{
				HealAmmoRifle[client] = true;
				HealAmmoAmountRifle[client] = GetConVarInt(HealAmmoAmount);
			}
		}
		else if (StrEqual(WeaponUsed, "weapon_sniper_awp", true) || 
				 StrEqual(WeaponUsed, "weapon_sniper_military", true) || 
				 StrEqual(WeaponUsed, "weapon_sniper_scout", true) || 
				 StrEqual(WeaponUsed, "weapon_hunting_rifle", true))
		{
			if (IceAmmoSniper[client] || BlindAmmoSniper[client] || HealAmmoSniper[client] || 
				BloatAmmoSniper[client]) return;
			if (StrEqual(ItemName[client], "bloat_ammo", false))
			{
				BloatAmmoSniper[client] = true;
				BloatAmmoAmountSniper[client] = GetConVarInt(BloatAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "blind_ammo", false))
			{
				BlindAmmoSniper[client] = true;
				BlindAmmoAmountSniper[client] = GetConVarInt(BlindAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "ice_ammo", false))
			{
				IceAmmoSniper[client] = true;
				IceAmmoAmountSniper[client] = GetConVarInt(IceAmmoAmount);
			}
			else if (StrEqual(ItemName[client], "heal_ammo", false))
			{
				HealAmmoSniper[client] = true;
				HealAmmoAmountSniper[client] = GetConVarInt(HealAmmoAmount);
			}
		}
	}
	if (SurvivorTeamPurchase[client])
	{
		ItemCost[client] -= SurvivorPoints[client];
		SurvivorPoints[client] = 0.0;
		SurvivorTeamPoints -= ItemCost[client];
		SurvivorTeamPurchase[client] = false;
	}
	else SurvivorPoints[client] -= ItemCost[client];
	if (ItemCost[client] > 0.0)
	{
		if (PurchaseItem[client] == 1) Tier2Cost[client] += GetConVarFloat(Tier2IncrementCost);
		if (PurchaseItem[client] == 2) HealthItemCost[client] += GetConVarFloat(HealthItemIncrementCost);
		if (PurchaseItem[client] == 3) PersonalAbilitiesCost[client] += GetConVarFloat(PersonalAbilitiesIncrementCost);
		if (PurchaseItem[client] == 4) WeaponUpgradeCost[client] += GetConVarFloat(WeaponUpgradeIncrementCost);
	}
	PrintToChat(client, "%s Purchased %s", PURCHASE_INFO, ItemName[client]);
}