_BoomerEvents_OnPluginStart()
{
	HookEvent("player_now_it", Event_PlayerNowIt);
}

/*			BOOMER TAGS PLAYER EVENT - SETTING UP BOOMER POINTS			*/

public Action:Event_PlayerNowIt(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker)) return;
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim)) return;
	// Just in case they have gravity boots - set their gravity to normal
	SetEntityGravity(victim, 1.0);
	if (GetClientTeam(attacker) == 2)
	{
		// The player tagged someone with a vomit jar. Give grenade experience if they have vomitjar unlocked.
		if (GrenadeLevel[attacker] >= GetConVarInt(GrenJarLevel))
		{
			if (PhysicalLevel[attacker] < InfectedLevel[victim]) experience_explosion_increase(attacker, 1 + (GetConVarInt(LevelDifferencePoints) * (InfectedLevel[victim] - PhysicalLevel[attacker])));
			else experience_explosion_increase(attacker, 1);
		}
	}
	if (SurvivorMultiplier[victim] < 1.0) SurvivorMultiplier[victim] = 1.0;
	WhoWasBoomer[victim] = attacker;
	CoveredInBile[victim] = true;
	CreateTimer(GetConVarFloat(BoomerPointsTime), RewardBoomerPoints, victim, TIMER_FLAG_NO_MAPCHANGE);
	if (UpgradeBoomer[attacker] || BoomerLevel[attacker] >= GetConVarInt(InfectedTier2Level))
	{
		if (EyeGoggles[victim] > 0)
		{
			new number = GetRandomInt(GetConVarInt(PersonalAbilityLossMin), GetConVarInt(PersonalAbilityLossMax));
			EyeGoggles[victim] -= number;
			if (EyeGoggles[victim] < 1)
			{
				PrintToChat(victim, "%s \x01Your Eye Goggles' crack, so you throw them away.", INFO);
				EyeGoggles[victim] = 0;
			}
		}
		else if (!BlindAmmoImmune[victim])
		{
			BlindAmmoImmune[victim] = true;
			BlindPlayer(victim, GetConVarInt(BlindAmount));
			CreateTimer(GetConVarFloat(BlindAmmoTime), RemoveBlindAmmo, victim, TIMER_FLAG_NO_MAPCHANGE);
			if (BoomerLevel[attacker] >= GetConVarInt(InfectedTier4Level) && !SpitterImmune[victim] && !BrokenLegs[victim])
			{
				SpitterImmune[victim] = true;
				if (IsPlayerAlive(victim)) SetEntDataFloat(victim, laggedMovementOffset, GetConVarFloat(StickySpitSpeed), true);
				CreateTimer(GetConVarFloat(StickySpitTime), RemoveStickySpit, victim);
			}
		}
	}
	new bool:exploded = GetEventBool(event, "exploded");
	decl pointEarn;
	decl levelDifference;
	levelDifference = (PhysicalLevel[victim] - InfectedLevel[attacker]) * GetConVarInt(LevelDifferencePoints);
	if (!exploded)
	{
		if (showpoints[attacker] == 1) PrintToChat(attacker, "%s \x01Vomitted on \x03%N \x01for \x05%3.3f \x01Point(s).", POINTS_INFO, victim, SurvivorMultiplier[victim] * GetConVarFloat(BoomerBilePoints));
		InfectedPoints[attacker] += (SurvivorMultiplier[victim] * GetConVarFloat(BoomerBilePoints));
		pointEarn = RoundToFloor((SurvivorMultiplier[victim] * GetConVarFloat(BoomerBilePoints)));
		if (pointEarn + levelDifference > 0) experience_increase(attacker, pointEarn + levelDifference);
		else experience_increase(attacker, pointEarn);
	}
	else
	{
		if (showpoints[attacker] == 1) PrintToChat(attacker, "%s \x01Exploded on \x03%N \x01for \x05%3.3f \x01Point(s).", POINTS_INFO, victim, SurvivorMultiplier[victim] * GetConVarFloat(BoomerBlowPoints));
		InfectedPoints[attacker] += (SurvivorMultiplier[victim] * GetConVarFloat(BoomerBlowPoints));
		pointEarn = RoundToFloor((SurvivorMultiplier[victim] * GetConVarFloat(BoomerBlowPoints)));
		if (pointEarn + levelDifference > 0) experience_increase(attacker, pointEarn + levelDifference);
		else experience_increase(attacker, pointEarn);
	}
}