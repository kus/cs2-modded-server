experience_multiplier(attacker)
{
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker)) return;
	new String:WeaponUsed[64];
	GetClientWeapon(attacker, WeaponUsed, sizeof(WeaponUsed));
	
	if (StrEqual(WeaponUsed, "weapon_pistol", true) || 
		StrEqual(WeaponUsed, "weapon_pistol_magnum", true))
	{
		SurvivorPistolValue[attacker]++;
	}
	else if (StrEqual(WeaponUsed, "weapon_melee", true))
	{
		SurvivorMeleeValue[attacker]++;
	}
	else if (StrEqual(WeaponUsed, "weapon_smg", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_silenced", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_mp5", true))
	{
		SurvivorSmgValue[attacker]++;
	}
	else if (StrEqual(WeaponUsed, "weapon_autoshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_pumpshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_spas", true))
	{
		SurvivorShotgunValue[attacker]++;
	}
	else if (StrEqual(WeaponUsed, "weapon_rifle", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_ak47", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_desert", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_m60", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_sg552", true))
	{
		SurvivorRifleValue[attacker]++;
	}
	else if (StrEqual(WeaponUsed, "weapon_sniper_awp", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_military", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_scout", true) || 
			 StrEqual(WeaponUsed, "weapon_hunting_rifle", true))
	{
		SurvivorSniperValue[attacker]++;
	}
	new String:AWARD_TYPE[64];
	Format(AWARD_TYPE, sizeof(AWARD_TYPE), "none");
	if (SurvivorHeadshotValue[attacker] >= SurvivorHeadshotGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorHeadshotGoal[attacker] += RoundToFloor(SurvivorHeadshotGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Headshot Goal\x04]");
	}
	else if (SurvivorSpecialValue[attacker] >= SurvivorSpecialGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorSpecialGoal[attacker] += RoundToFloor(SurvivorSpecialGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Special Goal\x04]");
	}
	else if (SurvivorCommonValue[attacker] >= SurvivorCommonGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorCommonGoal[attacker] += RoundToFloor(SurvivorCommonGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Common Goal\x04]");
	}
	else if (SurvivorPistolValue[attacker] >= SurvivorPistolGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorPistolGoal[attacker] += RoundToFloor(SurvivorPistolGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Pistol Goal\x04]");
	}
	else if (SurvivorMeleeValue[attacker] >= SurvivorMeleeGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorMeleeGoal[attacker] += RoundToFloor(SurvivorMeleeGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Melee Goal\x04]");
	}
	else if (SurvivorSmgValue[attacker] >= SurvivorSmgGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorSmgGoal[attacker] += RoundToFloor(SurvivorSmgGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Smg Goal\x04]");
	}
	else if (SurvivorShotgunValue[attacker] >= SurvivorShotgunGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorShotgunGoal[attacker] += RoundToFloor(SurvivorShotgunGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Shotgun Goal\x04]");
	}
	else if (SurvivorRifleValue[attacker] >= SurvivorRifleGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorRifleGoal[attacker] += RoundToFloor(SurvivorRifleGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Rifle Goal\x04]");
	}
	else if (SurvivorSniperValue[attacker] >= SurvivorSniperGoal[attacker])
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		SurvivorSniperGoal[attacker] += RoundToFloor(SurvivorSniperGoal[attacker] * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Sniper Goal\x04]");
	}
	else if (TeamSpecialValue >= TeamSpecialGoal)
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		TeamSpecialGoal += RoundToFloor(TeamSpecialGoal * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i) || i == attacker || GetClientTeam(i) != 2) continue;
			SurvivorPoints[i] += (SurvivorMultiplier[attacker] * GetConVarFloat(MultiplierGoalPoints));
			PrintToChat(i, "%s \x01Team Special Infected Goal: \x03%3.3f \x01Points by \x03%N\x01's \x03%3.3f \x01multiplier.", POINTS_INFO, SurvivorMultiplier[attacker] * GetConVarFloat(MultiplierGoalPoints), attacker, SurvivorMultiplier[attacker]);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Team Special Goal\x04]");
	}
	else if (TeamCommonValue >= TeamCommonGoal)
	{
		SurvivorMultiplier[attacker] += GetConVarFloat(SurvivorMultiplierGoal);
		TeamCommonGoal += RoundToFloor(TeamCommonGoal * GetConVarFloat(SurvivorMultiplierIncrement));
		if (SurvivorMultiplier[attacker] > GetConVarFloat(SurvivorMaxMultiplier))
		{
			SurvivorMultiplier[attacker] = GetConVarFloat(SurvivorMaxMultiplier);
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i) || i == attacker || GetClientTeam(i) != 2) continue;
			SurvivorPoints[i] += (SurvivorMultiplier[attacker] * GetConVarFloat(MultiplierGoalPoints));
			PrintToChat(i, "%s \x01Team Common Infected Goal: \x03%3.3f \x01Points by \x03%N\x01's \x03%3.3f \x01multiplier.", POINTS_INFO, SurvivorMultiplier[attacker] * GetConVarFloat(MultiplierGoalPoints), attacker, SurvivorMultiplier[attacker]);
		}
		Format(AWARD_TYPE, sizeof(AWARD_TYPE), "\x04[\x03Team Common Goal\x04]");
	}
	if (!StrEqual(AWARD_TYPE, "none", false))
	{
		PrintToChat(attacker, "%s \x01Points Earned: \x03%3.3f \x01of Multiplier \x03%3.3f", AWARD_TYPE, SurvivorMultiplier[attacker] * GetConVarFloat(MultiplierGoalPoints), SurvivorMultiplier[attacker]);
		SurvivorPoints[attacker] += (SurvivorMultiplier[attacker] * GetConVarFloat(MultiplierGoalPoints));
	}
}