_SpawnEvent_OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
}

/*			PLAYERSPAWN EVENT - SETTING UP INFECTED HEALTH BASED ON CLASS-LEVEL			*/

public Action:Event_PlayerSpawn(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 3) return;
	BerserkerKill[attacker] = false;												// Players Can Use This Skill Again.
	InJump[attacker] = false;
	SetEntityMoveType(attacker, MOVETYPE_WALK);
	SetEntityGravity(attacker, 1.0);
	PlayerZombieCheck(attacker);					// Bots go to a different function.
}

PlayerZombieCheck(attacker)
{
	if (IsClientIndexOutOfRange(attacker)) return;
	if (!IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 3 || !IsPlayerAlive(attacker)) return;
	InfectedGhost[attacker] = false;
	ClassHunter[attacker] = false;
	ClassSmoker[attacker] = false;
	ClassBoomer[attacker] = false;
	ClassJockey[attacker] = false;
	ClassCharger[attacker] = false;
	ClassSpitter[attacker] = false;
	new Class = GetEntProp(attacker, Prop_Send, "m_zombieClass");
	if (HunterLevel[attacker] >= GetConVarInt(InfectedTier2Level) && !UpgradeHunter[attacker])
	{
		UpgradeHunter[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (SmokerLevel[attacker] >= GetConVarInt(InfectedTier2Level) && !UpgradeSmoker[attacker])
	{
		UpgradeSmoker[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (BoomerLevel[attacker] >= GetConVarInt(InfectedTier2Level) && !UpgradeBoomer[attacker])
	{
		UpgradeBoomer[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (JockeyLevel[attacker] >= GetConVarInt(InfectedTier2Level) && !UpgradeJockey[attacker])
	{
		UpgradeJockey[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (ChargerLevel[attacker] >= GetConVarInt(InfectedTier2Level) && !UpgradeCharger[attacker])
	{
		UpgradeCharger[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (SpitterLevel[attacker] >= GetConVarInt(InfectedTier2Level) && !UpgradeSpitter[attacker])
	{
		UpgradeSpitter[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (HunterLevel[attacker] >= GetConVarInt(InfectedTier3Level) && !SuperUpgradeHunter[attacker])
	{
		SuperUpgradeHunter[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (SmokerLevel[attacker] >= GetConVarInt(InfectedTier3Level) && !SuperUpgradeSmoker[attacker])
	{
		SuperUpgradeSmoker[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (BoomerLevel[attacker] >= GetConVarInt(InfectedTier3Level) && !SuperUpgradeBoomer[attacker])
	{
		SuperUpgradeBoomer[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (JockeyLevel[attacker] >= GetConVarInt(InfectedTier3Level) && !SuperUpgradeJockey[attacker])
	{
		SuperUpgradeJockey[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (ChargerLevel[attacker] >= GetConVarInt(InfectedTier3Level) && !SuperUpgradeCharger[attacker])
	{
		SuperUpgradeCharger[attacker] = true;
		PersonalUpgrades[attacker]++;
	}
	if (SpitterLevel[attacker] >= GetConVarInt(InfectedTier3Level) && !SuperUpgradeSpitter[attacker])
	{
		SuperUpgradeSpitter[attacker] = true;
		PersonalUpgrades[attacker]++;
	}

	if (Class != ZOMBIECLASS_TANK)
	{
		if (	((Class == ZOMBIECLASS_HUNTER && HunterLevel[attacker] >= GetConVarInt(InfectedTier4Level)))	|| 
				((Class == ZOMBIECLASS_SMOKER && SmokerLevel[attacker] >= GetConVarInt(InfectedTier4Level)))	|| 
				((Class == ZOMBIECLASS_BOOMER && BoomerLevel[attacker] >= GetConVarInt(InfectedTier4Level)))	|| 
				((Class == ZOMBIECLASS_JOCKEY && JockeyLevel[attacker] >= GetConVarInt(InfectedTier4Level)))	|| 
				((Class == ZOMBIECLASS_CHARGER && ChargerLevel[attacker] >= GetConVarInt(InfectedTier4Level)))	|| 
				((Class == ZOMBIECLASS_SPITTER && SpitterLevel[attacker] >= GetConVarInt(InfectedTier4Level)))	)
		{
			if (!IsPlayerAlive(attacker)) return;
			SetEntityRenderMode(attacker, RENDER_TRANSCOLOR);
			if (Class != ZOMBIECLASS_HUNTER) SetEntityRenderColor(attacker, GetConVarInt(InfectedTier4Color[0]), GetConVarInt(InfectedTier4Color[1]), GetConVarInt(InfectedTier4Color[2]), 235);
			else SetEntityRenderColor(attacker, GetConVarInt(InfectedTier4Color[0]), GetConVarInt(InfectedTier4Color[1]), GetConVarInt(InfectedTier4Color[2]), 50);
		}
		else if (	((Class == ZOMBIECLASS_HUNTER && SuperUpgradeHunter[attacker]) || (Class == ZOMBIECLASS_HUNTER && HunterLevel[attacker] >= GetConVarInt(InfectedTier3Level)))	|| 
				((Class == ZOMBIECLASS_SMOKER && SuperUpgradeSmoker[attacker]) || (Class == ZOMBIECLASS_SMOKER && SmokerLevel[attacker] >= GetConVarInt(InfectedTier3Level)))	|| 
				((Class == ZOMBIECLASS_BOOMER && SuperUpgradeBoomer[attacker]) || (Class == ZOMBIECLASS_BOOMER && BoomerLevel[attacker] >= GetConVarInt(InfectedTier3Level)))	|| 
				((Class == ZOMBIECLASS_JOCKEY && SuperUpgradeJockey[attacker]) || (Class == ZOMBIECLASS_JOCKEY && JockeyLevel[attacker] >= GetConVarInt(InfectedTier3Level)))	|| 
				((Class == ZOMBIECLASS_CHARGER && SuperUpgradeCharger[attacker]) || (Class == ZOMBIECLASS_CHARGER && ChargerLevel[attacker] >= GetConVarInt(InfectedTier3Level)))	|| 
				((Class == ZOMBIECLASS_SPITTER && SuperUpgradeSpitter[attacker]) || (Class == ZOMBIECLASS_SPITTER && SpitterLevel[attacker] >= GetConVarInt(InfectedTier3Level)))	)
		{
			if (!IsPlayerAlive(attacker)) return;
			SetEntityRenderMode(attacker, RENDER_TRANSCOLOR);
			if (Class != ZOMBIECLASS_HUNTER) SetEntityRenderColor(attacker, GetConVarInt(InfectedTier3Color[0]), GetConVarInt(InfectedTier3Color[1]), GetConVarInt(InfectedTier3Color[2]), 255);
			else SetEntityRenderColor(attacker, GetConVarInt(InfectedTier3Color[0]), GetConVarInt(InfectedTier3Color[1]), GetConVarInt(InfectedTier3Color[2]), 100);
		}
		else if (	((Class == ZOMBIECLASS_HUNTER && UpgradeHunter[attacker]) || (Class == ZOMBIECLASS_HUNTER && HunterLevel[attacker] >= GetConVarInt(InfectedTier2Level)))	|| 
				((Class == ZOMBIECLASS_SMOKER && UpgradeSmoker[attacker]) || (Class == ZOMBIECLASS_SMOKER && SmokerLevel[attacker] >= GetConVarInt(InfectedTier2Level)))	|| 
				((Class == ZOMBIECLASS_BOOMER && UpgradeBoomer[attacker]) || (Class == ZOMBIECLASS_BOOMER && BoomerLevel[attacker] >= GetConVarInt(InfectedTier2Level)))	|| 
				((Class == ZOMBIECLASS_JOCKEY && UpgradeJockey[attacker]) || (Class == ZOMBIECLASS_JOCKEY && JockeyLevel[attacker] >= GetConVarInt(InfectedTier2Level)))	|| 
				((Class == ZOMBIECLASS_CHARGER && UpgradeCharger[attacker]) || (Class == ZOMBIECLASS_CHARGER && ChargerLevel[attacker] >= GetConVarInt(InfectedTier2Level)))	|| 
				((Class == ZOMBIECLASS_SPITTER && UpgradeSpitter[attacker]) || (Class == ZOMBIECLASS_SPITTER && SpitterLevel[attacker] >= GetConVarInt(InfectedTier2Level)))	)
		{
			if (!IsPlayerAlive(attacker)) return;
			SetEntityRenderMode(attacker, RENDER_TRANSCOLOR);
			if (Class != ZOMBIECLASS_HUNTER) SetEntityRenderColor(attacker, GetConVarInt(InfectedTier2Color[0]), GetConVarInt(InfectedTier2Color[1]), GetConVarInt(InfectedTier2Color[2]), 255);
			else SetEntityRenderColor(attacker, GetConVarInt(InfectedTier2Color[0]), GetConVarInt(InfectedTier2Color[1]), GetConVarInt(InfectedTier2Color[2]), 150);
		}
		
		if (Class == ZOMBIECLASS_HUNTER)
		{
			if (!IsPlayerAlive(attacker)) return;
			ClassHunter[attacker] = true;
			SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(HealthPerLevel) * HunterLevel[attacker])));
		}
		else ClassHunter[attacker] = false;
		if (Class == ZOMBIECLASS_SMOKER)
		{
			if (!IsPlayerAlive(attacker)) return;
			ClassSmoker[attacker] = true;
			SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(HealthPerLevel) * SmokerLevel[attacker])));
		}
		else ClassSmoker[attacker] = false;
		if (Class == ZOMBIECLASS_BOOMER)
		{
			if (!IsPlayerAlive(attacker)) return;
			ClassBoomer[attacker] = true;
			SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(HealthPerLevel) * BoomerLevel[attacker])));
		}
		else ClassBoomer[attacker] = false;
		if (Class == ZOMBIECLASS_JOCKEY)
		{
			if (!IsPlayerAlive(attacker)) return;
			ClassJockey[attacker] = true;
			SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(HealthPerLevel) * JockeyLevel[attacker])));
		}
		else ClassJockey[attacker] = false;
		if (Class == ZOMBIECLASS_CHARGER)
		{
			if (!IsPlayerAlive(attacker)) return;
			ClassCharger[attacker] = true;
			SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(HealthPerLevel) * ChargerLevel[attacker])));
		}
		else ClassCharger[attacker] = false;
		if (Class == ZOMBIECLASS_SPITTER)
		{
			if (!IsPlayerAlive(attacker)) return;
			ClassSpitter[attacker] = true;
			SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(HealthPerLevel) * SpitterLevel[attacker])));
		}
		else ClassSpitter[attacker] = false;
		ClassTank[attacker] = false;
	}
	else
	{
		ClassTank[attacker] = true;
		if (TankLevel[attacker] >= GetConVarInt(InfectedTier4Level))
		{
			if (!IsPlayerAlive(attacker)) return;
			SetEntityRenderMode(attacker, RENDER_TRANSCOLOR);
			SetEntityRenderColor(attacker, GetConVarInt(InfectedTier4Color[0]), GetConVarInt(InfectedTier4Color[1]), GetConVarInt(InfectedTier4Color[2]), 200);
		}
		else if (TankLevel[attacker] >= GetConVarInt(InfectedTier3Level))
		{
			if (!IsPlayerAlive(attacker)) return;
			SetEntityRenderMode(attacker, RENDER_TRANSCOLOR);
			SetEntityRenderColor(attacker, GetConVarInt(InfectedTier3Color[0]), GetConVarInt(InfectedTier3Color[1]), GetConVarInt(InfectedTier3Color[2]), 235);
		}
		else if (TankLevel[attacker] >= GetConVarInt(InfectedTier2Level))
		{
			if (!IsPlayerAlive(attacker)) return;
			SetEntityRenderMode(attacker, RENDER_TRANSCOLOR);
			SetEntityRenderColor(attacker, GetConVarInt(InfectedTier2Color[0]), GetConVarInt(InfectedTier2Color[1]), GetConVarInt(InfectedTier2Color[2]), 255);
		}
		if (IsPlayerAlive(attacker)) SetEntityHealth(attacker, (GetConVarInt(TankDefaultHealth) * GetConVarInt(SurvivorCount)));
		if (IsPlayerAlive(attacker)) SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(TankHealthPerLevel) * TankLevel[attacker])));
	}

	// Need to change how speeds work, maybe?


	if (IsClientIndexOutOfRange(attacker)) return;
	if (!IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 3 || !IsPlayerAlive(attacker)) return;
	SetEntityHealth(attacker, GetClientHealth(attacker) + RoundToFloor((GetConVarFloat(PhysicalHealthPerLevel) * InfectedLevel[attacker])));
	if (!ClassTank[attacker]) PlayerMovementSpeed[attacker] = 1.0 + (InfectedLevel[attacker] * GetConVarFloat(SpeedPerLevel));
	else PlayerMovementSpeed[attacker] = 0.7 + (InfectedLevel[attacker] * GetConVarFloat(SpeedPerLevel));
	if (IsPlayerAlive(attacker)) SetEntDataFloat(attacker, laggedMovementOffset, PlayerMovementSpeed[attacker], true);
}