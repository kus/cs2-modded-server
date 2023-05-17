/*		THESE TIMERS ARE ASSOCIATED WITH THE EQUIPMENT LOCKER AND NOT THE ACTUAL USEPOINTS SYSTEM		*/

public EnableMultiplierTimers()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsHuman(i) || XPMultiplierTime[i] <= 0 || XPMultiplierTimer[i]) continue;
		XPMultiplierTimer[i] = true;
		CreateTimer(1.0, DeductMultiplierTime, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:DeductMultiplierTime(Handle:timer, any:client)
{
	if (IsClientIndexOutOfRange(client)) return Plugin_Stop;
	if (!IsClientInGame(client) || IsFakeClient(client) || !XPMultiplierTimer[client]) return Plugin_Stop;
	if (RoundReset)
	{
		XPMultiplierTimer[client] = false;
		return Plugin_Stop;
	}
	if (IsPlayerAlive(client))
	{
		XPMultiplierTime[client]--;
		if (XPMultiplierTime[client] <= 0)
		{
			XPMultiplierTime[client] = 0;
			XPMultiplierTimer[client] = false;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action:DrugsUsedCounter(Handle:timer, any:attacker)
{
	if (IsClientIndexOutOfRange(attacker)) return Plugin_Stop;
	if (RoundReset)
	{
		DrugTimer[attacker] = -1.0;
		return Plugin_Stop;
	}
	if (!IsClientInGame(attacker) || IsFakeClient(attacker) || !IsPlayerAlive(attacker)) return Plugin_Stop;
	if (DrugTimer[attacker] == -1.0) DrugTimer[attacker] = GetConVarFloat(DrugTimerStart);
	if (DrugTimer[attacker] == 0.0)
	{
		DrugTimer[attacker] = -1.0;
		ForcePlayerSuicide(attacker);
		PrintToSurvivors("%s \x03%N \x01died due to a drug overdose.", INFO, attacker);
		return Plugin_Stop;
	}
	PrintHintText(attacker, "You're addicted!\n%3.1f sec(s) remaining to get your fix!", DrugTimer[attacker]);
	DrugTimer[attacker]--;
	return Plugin_Continue;
}

public Action:EnableUncommonEvent(Handle:timer)
{
	if (UncommonPanicEventCount == -1.0) UncommonPanicEventCount = 0.0;
	if (UncommonPanicEventCount >= GetConVarFloat(UncommonPanicEventTimer) || RoundReset)
	{
		UncommonPanicEventCount = -1.0;
		return Plugin_Stop;
	}
	UncommonPanicEventCount++;
	return Plugin_Continue;
}

public Action:EnableHealAmmo(Handle:timer, any:attacker)
{
	if (IsClientIndexOutOfRange(attacker)) return Plugin_Stop;
	if (!IsClientInGame(attacker) || IsFakeClient(attacker)) return Plugin_Stop;
	if (HealAmmoCounter[attacker] == -1.0) HealAmmoCounter[attacker] = 0.0;
	if (HealAmmoCounter[attacker] >= GetConVarFloat(HealAmmoCooldown))
	{
		HealAmmoCounter[attacker] = -1.0;
		HealAmmoDisabled[attacker] = false;
		PrintToChat(attacker, "%s \x03Heal Ammo \x01is available.", INFO);
		return Plugin_Stop;
	}
	HealAmmoCounter[attacker]++;
	return Plugin_Continue;
}

public Action:SetTheVip(Handle:timer)
{
	// We need to set a VIP.

	VipName = 0;
	VipExperience = 0;
	new PotentialVipFound = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i)) continue;
		if (!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) continue;
		if (PhysicalLevel[i] < GetConVarInt(VipMinimumLevel)) continue;
		PotentialVipFound++;
	}
	if (PotentialVipFound >= 2)
	{
		new i = 0;
		while (VipExperience == 0)
		{
			i = GetRandomInt(1, MaxClients);
			if (!IsClientIndexOutOfRange(i) && IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
			{
				if (PhysicalLevel[i] >= GetConVarInt(VipMinimumLevel))
				{
					PrintToSurvivors("%s \x03%N \x01is your VIP! Protect Them!", INFO, i);
					PrintToInfected("%s \x04%N \x01is the Survivor VIP! \x04KILL THEM!", INFO, i);
					VipName = i;
					VipExperience = GetConVarInt(VipAward) * PhysicalLevel[i];
					SetEntityRenderMode(i, RENDER_TRANSCOLOR);
					SetEntityRenderColor(i, GetConVarInt(VipColor[0]), GetConVarInt(VipColor[1]), GetConVarInt(VipColor[2]), 255);
				}
			}
		}
	}
}

public Action:RemoveFireTankImmune(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim) || GetClientTeam(victim) != 2) return Plugin_Stop;
	if (FireTankCount[victim] == -1.0) FireTankCount[victim] = 0.0;
	if (FireTankCount[victim] < GetConVarFloat(FireTankTime))
	{
		FireTankCount[victim]++;
		if (GetClientHealth(victim) - GetConVarInt(FireTankDamage) >= 1)
		{
			SetEntityHealth(victim, GetClientHealth(victim) - GetConVarInt(FireTankDamage));
		}
		else
		{
			FireTankImmune[victim] = false;
			return Plugin_Stop;
		}
		if (GetClientHealth(victim) > GetConVarInt(FireTankHealthEnd))
		{
			FireTankImmune[victim] = false;
			return Plugin_Stop;
		}
		return Plugin_Continue;
	}
	else
	{
		FireTankImmune[victim] = false;
		return Plugin_Stop;
	}
}

public Action:RemoveDrugEffect(Handle:timer, any:attacker)
{
	if (IsClientIndexOutOfRange(attacker)) return Plugin_Stop;
	if (!IsClientInGame(attacker) || IsFakeClient(attacker)) return Plugin_Stop;
	DrugEffect[attacker] = false;
	PrintToChat(attacker, "%s \x01The drugs effects have worn off.", INFO);
	return Plugin_Stop;
}

public Action:RemoveBlindAmmo(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	BlindPlayer(victim, 0);
	CreateTimer(GetConVarFloat(BlindAmmoCooldown), RemoveBlindImmune, victim, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

public Action:RemoveBlindImmune(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	BlindAmmoImmune[victim] = false;
	return Plugin_Stop;
}

public Action:RemoveBloatAmmo(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	if (IsPlayerAlive(victim)) SetEntityGravity(victim, 1.0);
	CreateTimer(GetConVarFloat(BloatAmmoCooldown), RemoveBloatImmune, victim, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

public Action:RemoveBloatImmune(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	BloatAmmoImmune[victim] = false;
	return Plugin_Stop;
}

public Action:RemoveIceAmmo(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	// Set speed to the level speed of the victim.
	if (IsPlayerAlive(victim)) SetEntDataFloat(victim, laggedMovementOffset, PlayerMovementSpeed[victim], true);
	CreateTimer(GetConVarFloat(IceAmmoCooldown), RemoveIceImmune, victim, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

public Action:RemoveIceImmune(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	IceAmmoImmune[victim] = false;
	return Plugin_Stop;
}

public Action:RemoveHeavySpit(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	HeavyBySpit[victim] = false;
	SetEntityGravity(victim, 1.0);
	return Plugin_Stop;
}

public Action:RemoveStickySpit(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	if (IsPlayerAlive(victim)) SetEntDataFloat(victim, laggedMovementOffset, 1.0, true);
	CreateTimer(GetConVarFloat(StickySpitImmuneTime), RemoveStickySpitImmune, victim);
	return Plugin_Stop;
}

public Action:RemoveStickySpitImmune(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	SpitterImmune[victim] = false;
	return Plugin_Stop;
}

public Action:RewardBoomerPoints(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	CoveredInBile[victim] = false;
	new attacker = WhoWasBoomer[victim];
	if (!IsClientInGame(attacker)) return Plugin_Stop;
	InfectedPoints[attacker] += BoomerActionPoints[victim];
	BoomerExperience[attacker] += RoundToFloor(BoomerActionPoints[victim] * GetConVarFloat(BileHitXP));
	if (BoomerActionPoints[victim] > 0.0) PrintToChat(attacker, "%s \x04%3.3f \x01Bile Hurt point(s) against \x03%N", POINTS_INFO, BoomerActionPoints[victim], victim);
	// Give them no experience, since we've forced experience to their boomer pool.
	// Do this in case the experience is awarded after they're no longer a boomer.
	BoomerActionPoints[victim] = 0.0;
	experience_increase(attacker, 0);
	return Plugin_Stop;
}

public Action:EnableIncapTimer(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	IncapDisabled[victim] = false;
	return Plugin_Stop;
}

public Action:SetIncapProtectionHealth(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	if (!IsPlayerAlive(victim)) return Plugin_Stop;
	SetEntityHealth(victim, 50);
	return Plugin_Stop;
}

public Action:EnableIncapProtection(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	IncapProtection[victim] = 0;
	PrintToChat(victim , "%s \x04Incap Protection \x01is now available for purchase.", INFO);
	return Plugin_Stop;
}

public Action:EnableTankPurchases(Handle:timer)
{
	if (TankCooldownTime == -1.0) TankCooldownTime = 1.0;
	TankCooldownTime++;
	if (TankCooldownTime >= GetConVarFloat(TankCooldown) || RoundReset)
	{
		TankCooldownTime = 0.0;
		PrintToInfected("%s \x01Tank purchases are \x05no longer restricted\x01.", INFO);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:EnableM60(Handle:timer, any:client)
{
	if (IsClientIndexOutOfRange(client)) return Plugin_Stop;
	if (!IsClientInGame(client) || IsFakeClient(client)) return Plugin_Stop;
	if (!M60CD[client]) return Plugin_Stop;
	if (M60COUNT[client] == -1.0) M60COUNT[client] = 0.0;
	M60COUNT[client]++;
	if (M60COUNT[client] >= GetConVarFloat(M60CDTIME))
	{
		M60COUNT[client] = 0.0;
		M60CD[client] = false;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:CheckForGrounding(Handle:timer, any:client)
{
	if (IsClientIndexOutOfRange(client)) return Plugin_Stop;
	if (!IsClientInGame(client) || IsFakeClient(client)) return Plugin_Stop;
	if (GetClientTeam(client) != 2 || !IsPlayerAlive(client)) return Plugin_Stop;
	if (GetEntityFlags(client) & FL_ONGROUND)
	{
		SetEntityGravity(client, 1.0);
		return Plugin_Stop;
	}
	else if (CoveredInBile[client] || Ensnared[client])
	{
		SetEntityGravity(client, 1.0);
		return Plugin_Stop;
	}
	else if (HeavyBySpit[client])
	{
		SetEntityGravity(client, 5.0);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:CheckIfEnsnared(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return Plugin_Stop;
	if (GetClientTeam(victim) != 2 || IncapProtection[victim] < 1 || !IsIncapacitated(victim) || IncapDisabled[victim]) return Plugin_Stop;
	if (L4D2_GetInfectedAttacker(victim) == -1)
	{
		IncapDisabled[victim] = true;
		CreateTimer(5.0, EnableIncapTimer, victim, TIMER_FLAG_NO_MAPCHANGE);
		
		Ensnared[victim] = false;
		IncapProtection[victim]--;
		ExecCheatCommand(victim, "give", "health");
		
		if (IncapProtection[victim] < 1)
		{
			PrintToChat(victim, "%s \x01No Incap Protection charges remaining.", INFO);
			IncapProtection[victim] = -1;
			CreateTimer(GetConVarFloat(IncapProtectionDisabled), EnableIncapProtection, victim, TIMER_FLAG_NO_MAPCHANGE);
			PrintToChat(victim, "%s \x03%2.1f \x01second(s) until \x04Incap Protection \x01may be purchased.", INFO, GetConVarFloat(IncapProtectionDisabled));
		}
		else PrintToChat(victim, "%s \x03%d \x01charges of \x04Incap Protection \x01remaining.", INFO, IncapProtection[victim]);
		CreateTimer(0.1, SetIncapProtectionHealth, victim, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:RemoveDeepFreeze(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i)) continue;
		if (!IsClientInGame(i) || IsFakeClient(i)) continue;
		if (GetClientTeam(i) != 2) continue;
		PlayerMovementSpeed[i] += GetConVarFloat(DeepFreezeSlowDown);
		if (!IsPlayerAlive(i)) continue;
		SetEntDataFloat(i, laggedMovementOffset, PlayerMovementSpeed[i], true);
	}
}

public Action:RemoveSmokerWhip(Handle:timer, any:client)
{
	if (IsClientIndexOutOfRange(client)) return Plugin_Stop;
	if (!IsClientInGame(client) || IsFakeClient(client)) return Plugin_Stop;
	SmokerWhipCooldown[client] = false;
	return Plugin_Stop;
}

public Action:RemoveJockeyJump(Handle:timer, any:client)
{
	if (IsClientIndexOutOfRange(client)) return Plugin_Stop;
	if (!IsClientInGame(client) || IsFakeClient(client)) return Plugin_Stop;
	JockeyJumpCooldown[client] = false;
	return Plugin_Stop;
}

public Action:CheckForSpawnAnywhere(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	if (GetClientTeam(victim) != 3) return Plugin_Stop;
	if (IsPlayerGhost(victim))
	{
		ClassHunter[victim] = false;
		ClassSmoker[victim] = false;
		ClassBoomer[victim] = false;
		ClassJockey[victim] = false;
		ClassCharger[victim] = false;
		ClassSpitter[victim] = false;

		new Class = GetEntProp(victim, Prop_Send, "m_zombieClass");
		if (Class == ZOMBIECLASS_HUNTER) ClassHunter[victim] = true;
		else if (Class == ZOMBIECLASS_SMOKER) ClassSmoker[victim] = true;
		else if (Class == ZOMBIECLASS_BOOMER) ClassBoomer[victim] = true;
		else if (Class == ZOMBIECLASS_JOCKEY) ClassJockey[victim] = true;
		else if (Class == ZOMBIECLASS_CHARGER) ClassCharger[victim] = true;
		else if (Class == ZOMBIECLASS_SPITTER) ClassSpitter[victim] = true;

		if (ClassHunter[victim] && HunterLevel[victim] >= GetConVarInt(SpawnAnywhereLevel) || 
			ClassSmoker[victim] && SmokerLevel[victim] >= GetConVarInt(SpawnAnywhereLevel) || 
			ClassBoomer[victim] && BoomerLevel[victim] >= GetConVarInt(SpawnAnywhereLevel) || 
			ClassJockey[victim] && JockeyLevel[victim] >= GetConVarInt(SpawnAnywhereLevel) || 
			ClassCharger[victim] && ChargerLevel[victim] >= GetConVarInt(SpawnAnywhereLevel) || 
			ClassSpitter[victim] && SpitterLevel[victim] >= GetConVarInt(SpawnAnywhereLevel))
		{
			SDKHook(victim, SDKHook_PreThinkPost, Hook_SpawnAnywhere);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:EnableSpawnAnywhere(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	if (GetClientTeam(victim) != 3) return Plugin_Stop;
	if (IsPlayerGhost(victim))
	{
		SDKHook(victim, SDKHook_PreThinkPost, Hook_SpawnAnywhere);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:EnableUncommonPurchases(Handle:timer)
{
	if (!UncommonCooldown) return Plugin_Stop;
	if (UncommonCooldownCount < GetConVarFloat(UncommonCooldownTime))
	{
		UncommonCooldownCount++;
		return Plugin_Continue;
	}
	else if (UncommonCooldownCount >= GetConVarFloat(UncommonCooldownTime))
	{
		UncommonCooldownCount = 0.0;
		UncommonCooldown = false;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:EnableDeepFreeze(Handle:timer)
{
	DeepFreezeCooldown = false;
	PrintToChatAll("%s \x04Deep Freeze \x01can be triggered again!", INFO);
	return Plugin_Stop;
}

public Action:EnableBurnDamage(Handle:timer, any:victim)
{
	if (IsClientIndexOutOfRange(victim)) return Plugin_Stop;
	if (!IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Stop;
	if (!IsPlayerAlive(victim)) return Plugin_Stop;
	BurnDamageImmune[victim] = false;
	return Plugin_Stop;
}

public Action:RemoveSpitterInvis(Handle:timer, any:client)
{
	if (IsClientIndexOutOfRange(client)) return Plugin_Stop;
	if (!IsClientInGame(client) || IsFakeClient(client)) return Plugin_Stop;
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	if (SpitterLevel[client] < GetConVarInt(InfectedTier4Level)) SetEntityRenderColor(client, GetConVarInt(InfectedTier3Color[0]), GetConVarInt(InfectedTier3Color[1]), GetConVarInt(InfectedTier3Color[2]), 255);
	else SetEntityRenderColor(client, GetConVarInt(InfectedTier4Color[0]), GetConVarInt(InfectedTier4Color[1]), GetConVarInt(InfectedTier4Color[2]), 235);
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	return Plugin_Stop;
}