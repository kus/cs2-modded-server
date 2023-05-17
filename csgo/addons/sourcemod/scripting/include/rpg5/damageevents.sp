_DamageEvents_OnPluginStart()
{
	HookEvent("infected_death", Event_InfectedDeath);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_incapacitated", Event_PlayerIncapacitated);
	HookEvent("player_shoved", Event_PlayerShoved);
	HookEvent("zombie_ignited", Event_ZombieIgnited);
	HookEvent("finale_escape_start", Event_FinaleEscapeStart);
}

/*				PREVENT RESPAWNS WHEN THE FINALE HAS BEGIN					*/

public Action:Event_FinaleEscapeStart(Handle:event, String:event_name[], bool:dontBroadcast)
{
	RescueCalled = true;
	PrintToSurvivors("%s \x01Rescue Vehicle has been Called. \x03Respawns \x04DISABLED\x01.", INFO);
}

/*				EVENTS FOR EARNING POINTS THROUGH KILLING THINGS			*/

public Action:Event_PlayerShoved(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(client) || !IsClientInGame(client) || GetClientTeam(client) != 3 || 
		!ClassBoomer[client] || !SuperUpgradeBoomer[client] || !IsPlayerAlive(client)) return;
	SetEntityHealth(client, 1);
	IgniteEntity(client, 1.0);
}

public Action:Event_ZombieIgnited(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 2) return;
	experience_explosion_increase(attacker, 1);
}

public Action:Event_InfectedDeath(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 2) return;
	new bool:headshot = GetEventBool(event, "headshot");
	new bool:blast = GetEventBool(event, "blast");
	if (!blast)
	{
		if (headshot)
		{
			SurvivorHeadshotValue[attacker]++;
			experience_increase(attacker, 1 + GetConVarInt(HSXP));
			RoundHS[attacker]++;
			if (RoundHS[attacker] > BestSurvivorHS[0])
			{
				BestSurvivorHS[0] = RoundHS[attacker];
				BestSurvivorHS[1] = attacker;
			}
		}
		else experience_increase(attacker, 1);
	}
	if (blast)
	{
		experience_explosion_increase(attacker, 1);
	}
	RoundKills[attacker]++;
	if (IsClientIndexOutOfRange(BestKills[1]) || !IsClientInGame(BestKills[1]))
	{
		BestKills[0] = 0;
	}
	if (RoundKills[attacker] > BestKills[0])
	{
		BestKills[0] = RoundKills[attacker];
		BestKills[1] = attacker;
	}
	SurvivorCommonValue[attacker]++;
	TeamCommonValue++;
	experience_multiplier(attacker);
}

public Action:Event_PlayerDeath(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim	 = GetClientOfUserId(GetEventInt(event, "userid"));
	decl oldattacker;
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim) && 
		GetClientTeam(victim) == 2)
	{
		oldattacker = LastToHurtMe[victim];
	}
	if (!IsClientIndexOutOfRange(oldattacker) && IsClientInGame(oldattacker) && !IsFakeClient(oldattacker) && 
		GetClientTeam(oldattacker) == 3 && GetClientTeam(oldattacker) != GetClientTeam(victim))
	{
		// Check if the survivor player was the infected player's nemesis, and also set the
		// infected player as the survivor player's nemesis.
		decl String:Key[64];
		GetClientAuthString(victim, Key, 65);
		if (StrEqual(Key, Nemesis[oldattacker]))
		{
			// The Infected player killed the survivor who was his nemesis.
			// Award the XP, announce it to the world, and then set the survivor's nemesis.
			new count = 1;		// 1 for the player, obviously.

			// How many other people had this player as their nemesis? Let's find out.
			// Remove the player from their list if so, but add a counter.
			// The counter multiplies the value of the bounty.
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 3 || i == oldattacker) continue;

				// If this survivor isn't the nemesis of an oldattacker, ignore them.
				if (!StrEqual(Key, Nemesis[i])) continue;

				PrintToChat(i, "%s \x01Your nemesis, \x03%N\x01, was killed by \x04%N \x01for \x04%d \x01XP!", INFO, victim, oldattacker, (GetConVarInt(NemesisAward) * count));
				count++;
				Nemesis[i] = "killed";
			}
			Nemesis[oldattacker] = "revenge";
			if (ClassHunter[oldattacker]) HunterExperience[oldattacker] += ((GetConVarInt(NemesisAward) * count)/2);
			else if (ClassSmoker[oldattacker]) SmokerExperience[oldattacker] += ((GetConVarInt(NemesisAward) * count)/2);
			else if (ClassBoomer[oldattacker]) BoomerExperience[oldattacker] += ((GetConVarInt(NemesisAward) * count)/2);
			else if (ClassJockey[oldattacker]) JockeyExperience[oldattacker] += ((GetConVarInt(NemesisAward) * count)/2);
			else if (ClassCharger[oldattacker]) ChargerExperience[oldattacker] += ((GetConVarInt(NemesisAward) * count)/2);
			else if (ClassSpitter[oldattacker]) SpitterExperience[oldattacker] += ((GetConVarInt(NemesisAward) * count)/2);
			else if (ClassTank[oldattacker]) TankExperience[oldattacker] += ((GetConVarInt(NemesisAward) * count)/2);
			InfectedExperience[oldattacker] += (GetConVarInt(NemesisAward) * count);
			PrintToChat(oldattacker, "%s \x01You took revenge on your nemesis, \x03%N \x01for \x04%d \x01XP!", INFO, victim, (GetConVarInt(NemesisAward) * count));
			PrintToChat(oldattacker, "%s \x03%N \x01was Nemesis to \x04%d \x01other players!", INFO, victim, count);
			experience_increase(oldattacker, 0);
		}
		GetClientAuthString(oldattacker, Key, 65);
		Nemesis[victim] = Key;
		GetClientName(oldattacker, NemesisName[victim], 257);
		PrintToChat(victim, "%s \x04%N \x01is your new nemesis!", INFO, oldattacker);
	}
	else
	{
		if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim) && 
			GetClientTeam(victim) == 2)
		{
			Nemesis[victim] = "none";
		}
	}
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim) && GetClientTeam(victim) == 2)
	{
		LocationSaved[victim] = true;
		GetClientAbsOrigin(victim, SurvivorDeathSpot[victim]);
	}
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim) && GetClientTeam(victim) == 3)
	{
		TeamSpecialValue++;
		InfectedTeamPoints += (HurtAward[victim] * GetConVarFloat(InfectedTeamPointsMP));
		// Assign the infected player his hurt points in experience and points.
		
		if (HunterHurtAward[victim] > 0.0) HunterExperience[victim] += RoundToFloor(HunterHurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		if (SmokerHurtAward[victim] > 0.0) SmokerExperience[victim] += RoundToFloor(SmokerHurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		if (BoomerHurtAward[victim] > 0.0) BoomerExperience[victim] += RoundToFloor(BoomerHurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		if (JockeyHurtAward[victim] > 0.0) JockeyExperience[victim] += RoundToFloor(JockeyHurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		if (ChargerHurtAward[victim] > 0.0) ChargerExperience[victim] += RoundToFloor(ChargerHurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		if (SpitterHurtAward[victim] > 0.0) SpitterExperience[victim] += RoundToFloor(SpitterHurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		if (TankHurtAward[victim] > 0.0) TankExperience[victim] += RoundToFloor(TankHurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		if (HurtAward[victim] > 0.0) InfectedExperience[victim] += RoundToFloor(HurtAward[victim] * GetConVarFloat(HurtAwardInfectedXP));
		HunterHurtAward[victim] = 0.0;
		SmokerHurtAward[victim] = 0.0;
		BoomerHurtAward[victim] = 0.0;
		JockeyHurtAward[victim] = 0.0;
		ChargerHurtAward[victim] = 0.0;
		SpitterHurtAward[victim] = 0.0;
		TankHurtAward[victim] = 0.0;
		experience_increase(victim, 0);
		
		if (ClassTank[victim]) HurtAward[victim] *= GetConVarFloat(HurtAwardTankPoints);
		else HurtAward[victim] *= GetConVarFloat(HurtAwardInfectedPoints);
		InfectedPoints[victim] += HurtAward[victim];
		if (HurtAward[victim] > 0.0) PrintToChat(victim, "%s \x01Hurt Damage: \x04%3.3f \x01Point(s).", POINTS_INFO, HurtAward[victim]);
		HurtAward[victim] = 0.0;

		// Wall of Fire triggers automatically if a players level is above a certain point.
		if (!InfectedGhost[victim])
		{
			if (ClassHunter[victim] && HunterLevel[victim] >= GetConVarInt(WallOfFireLevel) || 
				ClassSmoker[victim] && SmokerLevel[victim] >= GetConVarInt(WallOfFireLevel) || 
				ClassBoomer[victim] && BoomerLevel[victim] >= GetConVarInt(WallOfFireLevel) || 
				ClassJockey[victim] && JockeyLevel[victim] >= GetConVarInt(WallOfFireLevel) || 
				ClassCharger[victim] && ChargerLevel[victim] >= GetConVarInt(WallOfFireLevel) || 
				ClassSpitter[victim] && SpitterLevel[victim] >= GetConVarInt(WallOfFireLevel) || 
				ClassTank[victim] && TankLevel[victim] >= GetConVarInt(WallOfFireLevel)) CreateFireEx(victim);
		}
		// Spawn Anywhere triggers automatically if a players level is above a certain point.
		CreateTimer(0.1, CheckForSpawnAnywhere, victim, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		// Wall of Fire is now redundant, since we have a new method for how to create it.
		//if (WallOfFire[victim]) CreateFireEx(victim);
		/// Spawn Anywhere is now redundant, since we have a new method for how to check for it.
		//if (SpawnAnywhere[victim]) CreateTimer(0.5, EnableSpawnAnywhere, victim, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	if (!IsClientIndexOutOfRange(attacker) && IsClientInGame(attacker) && !IsFakeClient(attacker) && GetClientTeam(attacker) == 2)
	{
		// We want to get the total number of kills the survivor player has
		// As they are rewarded phyiscal experience at the end of a round.
		RoundKills[attacker]++;
		new bool:headshot = GetEventBool(event, "headshot");
		if (headshot)
		{
			if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim)) experience_increase(attacker, RoundToFloor(0.3 * InfectedLevel[victim]) + (GetConVarInt(SIXP) + GetConVarInt(HSXP)));
			SurvivorHeadshotValue[attacker]++;
			RoundHS[attacker]++;
			if (RoundHS[attacker] > BestSurvivorHS[0])
			{
				BestSurvivorHS[0] = RoundHS[attacker];
				BestSurvivorHS[1] = attacker;
			}
		}
		else
		{
			if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim)) experience_increase(attacker, RoundToFloor(0.3 * InfectedLevel[victim]) + GetConVarInt(SIXP));
		}
		SurvivorSpecialValue[attacker]++;
		experience_multiplier(attacker);
		if (IsClientIndexOutOfRange(BestKills[1]) || !IsClientInGame(BestKills[1]))
		{
			BestKills[0] = 0;
		}
		if (RoundKills[attacker] > BestKills[0])
		{
			BestKills[0] = RoundKills[attacker];
			BestKills[1] = attacker;
		}
		if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim))
		{
			// Survivors earn points through damage dealt.
			// End of round experience bonuses are also through damage dealt.
			if (!IsFakeClient(victim)) InfectedGhost[victim] = true;
			InfectedPlayerHasDied(victim);
		}
	}
}

public Action:Event_PlayerIncapacitated(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim	 = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim) && GetClientTeam(victim) == 2)
	{
		CreateTimer(1.0, CheckIfEnsnared, victim, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (DeepFreezeAmount > 0 && !DeepFreezeCooldown)
		{
			new number = GetRandomInt(1, 100);
			if (number <= DeepFreezeAmount)
			{
				DeepFreezeCooldown = true;
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 2) continue;
					PlayerMovementSpeed[i] -= GetConVarFloat(DeepFreezeSlowDown);
					if (IsPlayerAlive(i)) SetEntDataFloat(i, laggedMovementOffset, PlayerMovementSpeed[i], true);
				}
				CreateTimer(GetConVarFloat(DeepFreezeTime), RemoveDeepFreeze, _, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(GetConVarFloat(DeepFreezeDisableTime), EnableDeepFreeze, _, TIMER_FLAG_NO_MAPCHANGE);
				PrintToChatAll("%s \x04Deep Freeze \x01is in effect!", INFO);
			}
		}
	}
}

public Action:Event_PlayerHurt(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim	 = GetClientOfUserId(GetEventInt(event, "userid"));
	new damage	 = GetEventInt(event, "dmg_health");
	if (!IsClientIndexOutOfRange(attacker) && IsClientInGame(attacker) && !IsFakeClient(attacker) && GetClientTeam(attacker) == 2 && 
		!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim) && GetClientTeam(victim) == 2)
	{
		if (!LockedWeaponUsed(attacker) && IsPlayerAlive(victim) && attacker != victim)
		{
			CallHealAmmo(attacker, victim);
		}
	}
	if (!IsClientIndexOutOfRange(attacker) && IsClientInGame(attacker) && !IsFakeClient(attacker) && GetClientTeam(attacker) == 2 && GetClientTeam(victim) != 2)
	{
		if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim))
		{
			// we set the damage increase bonuses for each weapon, to properly award the survivor
			// for each weapon used on the infected player when the infected player dies.
			CallWeaponDamage(attacker, victim, damage);
			new Class = GetEntProp(victim, Prop_Send, "m_zombieClass");
			CallScoutAbility(attacker, victim, Class);
			if (!LockedWeaponUsed(attacker) && !IsFakeClient(victim) && IsPlayerAlive(victim))
			{
				CallBlindAmmo(attacker, victim);
				CallBloatAmmo(attacker, victim);
				CallIceAmmo(attacker, victim);
			}
		}
		// We want to tally the total damage a player has done in a round
		// Because they are awarded bonus physical experience based on it.
		RoundAward[attacker] += damage;
		AssistHurtInfected[attacker][victim] += damage;
		RoundSurvivorDamage[attacker] += damage;
		if (RoundSurvivorDamage[attacker] > BestSurvivorDamage[0])
		{
			BestSurvivorDamage[0] = RoundSurvivorDamage[attacker];
			BestSurvivorDamage[1] = attacker;
		}
	}
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && GetClientTeam(victim) == 2)	// no attacker specified since commons can deal damage to the player.
	{
		new String:WeaponCallBack[32];
		GetEventString(event, "weapon", WeaponCallBack, 32);
		if (CoveredInBile[victim] && !StrEqual(WeaponCallBack, "inferno") && !StrEqual(WeaponCallBack, "insect_swarm"))
		{
			BoomerActionPoints[victim] += (SurvivorMultiplier[victim] * GetConVarFloat(BoomerAwardPoints));
		}
		if (!IsClientIndexOutOfRange(attacker) && IsClientInGame(attacker) && !IsFakeClient(attacker) && GetClientTeam(attacker) == 3 && 
			!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim) && GetClientTeam(victim) == 2)
		{
			if (GetClientTeam(attacker) != GetClientTeam(victim)) LastToHurtMe[victim] = attacker;
			RoundDamage[attacker] += damage;
			if (IsClientIndexOutOfRange(MapBestDamage[1]) || !IsClientInGame(MapBestDamage[1]))
			{
				MapBestDamage[0] = 0;
			}
			if (RoundDamage[attacker] > MapBestDamage[0])
			{
				MapBestDamage[0] = RoundDamage[attacker];
				MapBestDamage[1] = attacker;
			}
			// Tally their round total damage.
			RoundAward[attacker] += damage;
			
			// We only want to give class-specific points if the player is alive.
			// Ex. If spit does damage after the spitter dies, infected XP only.
			if (IsPlayerAlive(attacker))
			{
				// Now we go through and give specific points and stuff to the infected player.
				// New feature, for each class you earn XP as, you get XP in that category.
				if (ClassHunter[attacker]) HunterHurtAward[attacker] += (damage * GetConVarFloat(HunterDamageNerf));
				else if (ClassSmoker[attacker]) SmokerHurtAward[attacker] += (damage * GetConVarFloat(SmokerDamageNerf));
				else if (ClassBoomer[attacker]) BoomerHurtAward[attacker] += (damage * GetConVarFloat(BoomerDamageNerf));
				else if (ClassJockey[attacker]) JockeyHurtAward[attacker] += (damage * GetConVarFloat(JockeyDamageNerf));
				else if (ClassCharger[attacker]) ChargerHurtAward[attacker] += (damage * GetConVarFloat(ChargerDamageNerf));
				else if (ClassSpitter[attacker]) SpitterHurtAward[attacker] += (damage * GetConVarFloat(SpitterDamageNerf));
				else if (ClassTank[attacker])
				{
					// Check if the Tank is a Tier 4 Tank!
					if (TankLevel[attacker] >= GetConVarInt(InfectedTier4Level))
					{
						if (IsPlayerAlive(victim) && !FireTankImmune[victim] && GetClientHealth(victim) >= GetConVarInt(FireTankMinimumHealth))
						{
							FireTankImmune[victim] = true;
							FireTankCount[victim] = -1.0;
							IgniteEntity(victim, GetConVarFloat(FireTankTime));
							CreateTimer(1.0, RemoveFireTankImmune, victim, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							TankHurtAward[attacker] += (GetConVarFloat(FireTankTime) * GetConVarInt(FireTankDamage));
						}
					}
					TankHurtAward[attacker] += damage;
				}
			}
			// Basic Hurt Award goes to the players infected level and usepoints. Cumulative of all damages.
			// This is also the only award given if the player is no longer alive.
			if (IsPlayerAlive(attacker) && !ClassSpitter[attacker] && !ClassCharger[attacker]) HurtAward[attacker] += damage;
			else if (IsPlayerAlive(attacker) && ClassCharger[attacker]) HurtAward[attacker] += (damage * GetConVarFloat(ChargerDamageNerf));
			else if (IsPlayerAlive(attacker) && ClassSpitter[attacker]) HurtAward[attacker] += (damage * GetConVarFloat(SpitterDamageNerf));
			// Add Smoker Burn and Spitter Slow here.
			if (ClassSmoker[attacker] && (UpgradeSmoker[attacker] || SmokerLevel[attacker] >= GetConVarInt(InfectedTier2Level)))
			{
				if (GetClientHealth(victim) > GetConVarInt(SmokerBurnDamage) && !BurnDamageImmune[victim] && IsPlayerAlive(victim))
				{
					BurnDamageImmune[victim] = true;
					CreateTimer(5.0, EnableBurnDamage, victim);
					IgniteEntity(victim, 3.0);
					SetEntityHealth(victim, GetClientHealth(victim) - GetConVarInt(SmokerBurnDamage));
					HurtAward[attacker] += GetConVarInt(SmokerBurnDamage);
				}
			}
			if (ClassSpitter[attacker] && (UpgradeSpitter[attacker] || SpitterLevel[attacker] >= GetConVarInt(InfectedTier2Level)) && !SpitterImmune[victim] && 
				!BrokenLegs[victim])
			{
				if (HazmatBoots[victim] > 0)
				{
					new number = GetRandomInt(GetConVarInt(PersonalAbilityLossMin), GetConVarInt(PersonalAbilityLossMax));
					HazmatBoots[victim] -= number;
					if (HazmatBoots[victim] < 1)
					{
						PrintToChat(victim, "%s \x01Your Hazmat Boots' composition breaks apart.", INFO);
						HazmatBoots[victim] = 0;
					}
				}
				else
				{
					SpitterImmune[victim] = true;
					if (IsPlayerAlive(victim)) SetEntDataFloat(victim, laggedMovementOffset, GetConVarFloat(StickySpitSpeed), true);
					CreateTimer(GetConVarFloat(StickySpitTime), RemoveStickySpit, victim);

					if (SpitterLevel[attacker] >= GetConVarInt(InfectedTier4Level) && !HeavyBySpit[victim])
					{
						HeavyBySpit[victim] = true;
						SetEntityGravity(victim, 5.0);
						CreateTimer(2.0, RemoveHeavySpit, victim, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
}

CallBlindAmmo(attacker, victim)
{
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim) || BlindAmmoImmune[victim]) return;
	new String:WeaponUsed[64];
	GetClientWeapon(attacker, WeaponUsed, sizeof(WeaponUsed));
	if (StrEqual(WeaponUsed, "weapon_pistol", true) || 
		StrEqual(WeaponUsed, "weapon_pistol_magnum", true))
	{
		if (!BlindAmmoPistol[attacker] || BlindAmmoAmountPistol[attacker] < 1) return;
		BlindAmmoAmountPistol[attacker]--;
		if (BlindAmmoAmountPistol[attacker] < 1) BlindAmmoPistol[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_melee", true))
	{
		return;
	}
	else if (StrEqual(WeaponUsed, "weapon_smg", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_silenced", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_mp5", true))
	{
		if (!BlindAmmoSmg[attacker] || BlindAmmoAmountSmg[attacker] < 1) return;
		BlindAmmoAmountSmg[attacker]--;
		if (BlindAmmoAmountSmg[attacker] < 1) BlindAmmoSmg[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_autoshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_pumpshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_spas", true))
	{
		if (!BlindAmmoShotgun[attacker] || BlindAmmoAmountShotgun[attacker] < 1) return;
		BlindAmmoAmountShotgun[attacker]--;
		if (BlindAmmoAmountShotgun[attacker] < 1) BlindAmmoShotgun[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_rifle", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_ak47", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_desert", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_m60", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_sg552", true))
	{
		if (!BlindAmmoRifle[attacker] || BlindAmmoAmountRifle[attacker] < 1) return;
		BlindAmmoAmountRifle[attacker]--;
		if (BlindAmmoAmountRifle[attacker] < 1) BlindAmmoRifle[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_sniper_awp", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_military", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_scout", true) || 
			 StrEqual(WeaponUsed, "weapon_hunting_rifle", true))
	{
		if (!BlindAmmoSniper[attacker] || BlindAmmoAmountSniper[attacker] < 1) return;
		BlindAmmoAmountSniper[attacker]--;
		if (BlindAmmoAmountSniper[attacker] < 1) BlindAmmoSniper[attacker] = false;
	}

	BlindPlayer(victim, GetConVarInt(BlindAmount));
	CreateTimer(GetConVarFloat(BlindAmmoTime), RemoveBlindAmmo, victim, TIMER_FLAG_NO_MAPCHANGE);
	BlindAmmoImmune[victim] = true;
}

CallBloatAmmo(attacker, victim)
{
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim) || BloatAmmoImmune[victim]) return;
	new String:WeaponUsed[64];
	GetClientWeapon(attacker, WeaponUsed, sizeof(WeaponUsed));
	if (StrEqual(WeaponUsed, "weapon_pistol", true) || 
		StrEqual(WeaponUsed, "weapon_pistol_magnum", true))
	{
		if (!BloatAmmoPistol[attacker] || BloatAmmoAmountPistol[attacker] < 1) return;
		BloatAmmoAmountPistol[attacker]--;
		if (BloatAmmoAmountPistol[attacker] < 1) BloatAmmoPistol[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_melee", true))
	{
		return;
	}
	else if (StrEqual(WeaponUsed, "weapon_smg", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_silenced", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_mp5", true))
	{
		if (!BloatAmmoSmg[attacker] || BloatAmmoAmountSmg[attacker] < 1) return;
		BloatAmmoAmountSmg[attacker]--;
		if (BloatAmmoAmountSmg[attacker] < 1) BloatAmmoSmg[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_autoshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_pumpshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_spas", true))
	{
		if (!BloatAmmoShotgun[attacker] || BloatAmmoAmountShotgun[attacker] < 1) return;
		BloatAmmoAmountShotgun[attacker]--;
		if (BloatAmmoAmountShotgun[attacker] < 1) BloatAmmoShotgun[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_rifle", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_ak47", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_desert", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_m60", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_sg552", true))
	{
		if (!BloatAmmoRifle[attacker] || BloatAmmoAmountRifle[attacker] < 1) return;
		BloatAmmoAmountRifle[attacker]--;
		if (BloatAmmoAmountRifle[attacker] < 1) BloatAmmoRifle[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_sniper_awp", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_military", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_scout", true) || 
			 StrEqual(WeaponUsed, "weapon_hunting_rifle", true))
	{
		if (!BloatAmmoSniper[attacker] || BloatAmmoAmountSniper[attacker] < 1) return;
		BloatAmmoAmountSniper[attacker]--;
		if (BloatAmmoAmountSniper[attacker] < 1) BloatAmmoSniper[attacker] = false;
	}
	SetEntityGravity(victim, GetConVarFloat(BloatAmount));
	CreateTimer(GetConVarFloat(BloatAmmoTime), RemoveBloatAmmo, victim, TIMER_FLAG_NO_MAPCHANGE);
	BloatAmmoImmune[victim] = true;
}

CallIceAmmo(attacker, victim)
{
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim) || IceAmmoImmune[victim]) return;
	new String:WeaponUsed[64];
	GetClientWeapon(attacker, WeaponUsed, sizeof(WeaponUsed));
	if (StrEqual(WeaponUsed, "weapon_pistol", true) || 
		StrEqual(WeaponUsed, "weapon_pistol_magnum", true))
	{
		if (!IceAmmoPistol[attacker] || IceAmmoAmountPistol[attacker] < 1) return;
		IceAmmoAmountPistol[attacker]--;
		if (IceAmmoAmountPistol[attacker] < 1) IceAmmoPistol[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_melee", true))
	{
		return;
	}
	else if (StrEqual(WeaponUsed, "weapon_smg", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_silenced", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_mp5", true))
	{
		if (!IceAmmoSmg[attacker] || IceAmmoAmountSmg[attacker] < 1) return;
		IceAmmoAmountSmg[attacker]--;
		if (IceAmmoAmountSmg[attacker] < 1) IceAmmoSmg[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_autoshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_pumpshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_spas", true))
	{
		if (!IceAmmoShotgun[attacker] || IceAmmoAmountShotgun[attacker] < 1) return;
		IceAmmoAmountShotgun[attacker]--;
		if (IceAmmoAmountShotgun[attacker] < 1) IceAmmoShotgun[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_rifle", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_ak47", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_desert", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_m60", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_sg552", true))
	{
		if (!IceAmmoRifle[attacker] || IceAmmoAmountRifle[attacker] < 1) return;
		IceAmmoAmountRifle[attacker]--;
		if (IceAmmoAmountRifle[attacker] < 1) IceAmmoRifle[attacker] = false;
	}
	else if (StrEqual(WeaponUsed, "weapon_sniper_awp", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_military", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_scout", true) || 
			 StrEqual(WeaponUsed, "weapon_hunting_rifle", true))
	{
		if (!IceAmmoSniper[attacker] || IceAmmoAmountSniper[attacker] < 1) return;
		IceAmmoAmountSniper[attacker]--;
		if (IceAmmoAmountSniper[attacker] < 1) IceAmmoSniper[attacker] = false;
	}
	SetEntDataFloat(victim, laggedMovementOffset, PlayerMovementSpeed[victim] - GetConVarFloat(IceAmount), true);
	CreateTimer(GetConVarFloat(IceAmmoTime), RemoveIceAmmo, victim, TIMER_FLAG_NO_MAPCHANGE);
	IceAmmoImmune[victim] = true;
}

CallHealAmmo(attacker, victim)
{
	if (IsClientIndexOutOfRange(victim)) return;
	if (!IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim)) return;
	// If the players health pool is above their maximum health pool, don't let them be the
	// recipient of heal ammo.
	if (GetClientHealth(victim) >= (100 + PhysicalLevel[victim])) return;
	new String:WeaponUsed[64];
	GetClientWeapon(attacker, WeaponUsed, sizeof(WeaponUsed));
	if (StrEqual(WeaponUsed, "weapon_pistol", true) || 
		StrEqual(WeaponUsed, "weapon_pistol_magnum", true))
	{
		if (!HealAmmoPistol[attacker] || HealAmmoAmountPistol[attacker] < 1) return;
		HealAmmoAmountPistol[attacker]--;
		if (HealAmmoAmountPistol[attacker] < 1)
		{
			HealAmmoPistol[attacker] = false;
			HealAmmoDisabled[attacker] = true;
			HealAmmoCounter[attacker] = -1.0;
			CreateTimer(1.0, EnableHealAmmo, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (GetClientHealth(victim) + PistolLevel[attacker] > GetClientHealth(victim) + PhysicalLevel[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + PhysicalLevel[victim]);
		}
		else
		{
			SetEntityHealth(victim, GetClientHealth(victim) + PistolLevel[attacker]);
		}
		RoundHealing[attacker] += PistolLevel[attacker];
	}
	else if (StrEqual(WeaponUsed, "weapon_melee", true))
	{
		return;
	}
	else if (StrEqual(WeaponUsed, "weapon_smg", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_silenced", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_mp5", true))
	{
		if (!HealAmmoSmg[attacker] || HealAmmoAmountSmg[attacker] < 1) return;
		HealAmmoAmountSmg[attacker]--;
		if (HealAmmoAmountSmg[attacker] < 1)
		{
			HealAmmoSmg[attacker] = false;
			HealAmmoDisabled[attacker] = true;
			HealAmmoCounter[attacker] = -1.0;
			CreateTimer(1.0, EnableHealAmmo, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (GetClientHealth(victim) + UziLevel[attacker] > GetClientHealth(victim) + PhysicalLevel[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + PhysicalLevel[victim]);
		}
		else
		{
			SetEntityHealth(victim, GetClientHealth(victim) + UziLevel[attacker]);
		}
		RoundHealing[attacker] += UziLevel[attacker];
	}
	else if (StrEqual(WeaponUsed, "weapon_autoshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_pumpshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_spas", true))
	{
		if (!HealAmmoShotgun[attacker] || HealAmmoAmountShotgun[attacker] < 1) return;
		HealAmmoAmountShotgun[attacker]--;
		if (HealAmmoAmountShotgun[attacker] < 1)
		{
			HealAmmoShotgun[attacker] = false;
			HealAmmoDisabled[attacker] = true;
			HealAmmoCounter[attacker] = -1.0;
			CreateTimer(1.0, EnableHealAmmo, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (GetClientHealth(victim) + ShotgunLevel[attacker] > GetClientHealth(victim) + PhysicalLevel[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + PhysicalLevel[victim]);
		}
		else
		{
			SetEntityHealth(victim, GetClientHealth(victim) + ShotgunLevel[attacker]);
		}
		RoundHealing[attacker] += ShotgunLevel[attacker];
	}
	else if (StrEqual(WeaponUsed, "weapon_rifle", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_ak47", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_desert", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_m60", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_sg552", true))
	{
		if (!HealAmmoRifle[attacker] || HealAmmoAmountRifle[attacker] < 1) return;
		HealAmmoAmountRifle[attacker]--;
		if (HealAmmoAmountRifle[attacker] < 1)
		{
			HealAmmoRifle[attacker] = false;
			HealAmmoDisabled[attacker] = true;
			HealAmmoCounter[attacker] = -1.0;
			CreateTimer(1.0, EnableHealAmmo, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (GetClientHealth(victim) + RifleLevel[attacker] > GetClientHealth(victim) + PhysicalLevel[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + PhysicalLevel[victim]);
		}
		else
		{
			SetEntityHealth(victim, GetClientHealth(victim) + RifleLevel[attacker]);
		}
		RoundHealing[attacker] += RifleLevel[attacker];
	}
	else if (StrEqual(WeaponUsed, "weapon_sniper_awp", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_military", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_scout", true) || 
			 StrEqual(WeaponUsed, "weapon_hunting_rifle", true))
	{
		if (!HealAmmoSniper[attacker] || HealAmmoAmountSniper[attacker] < 1) return;
		HealAmmoAmountSniper[attacker]--;
		if (HealAmmoAmountSniper[attacker] < 1)
		{
			HealAmmoSniper[attacker] = false;
			HealAmmoDisabled[attacker] = true;
			HealAmmoCounter[attacker] = -1.0;
			CreateTimer(1.0, EnableHealAmmo, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (GetClientHealth(victim) + SniperLevel[attacker] > GetClientHealth(victim) + PhysicalLevel[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + PhysicalLevel[victim]);
		}
		else
		{
			SetEntityHealth(victim, GetClientHealth(victim) + SniperLevel[attacker]);
		}
		RoundHealing[attacker] += SniperLevel[attacker];
	}
	if (RoundHealing[attacker] > BestHealing[0])
	{
		BestHealing[0] = RoundHealing[attacker];
		BestHealing[1] = attacker;
	}
}

CallScoutAbility(attacker, victim, Class)
{
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim)) return;
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || !Scout[attacker]) return;
	decl String:ClassName[128];
	if (Class == ZOMBIECLASS_HUNTER) Format(ClassName, sizeof(ClassName), "Hunter Lv. %d (%d)", HunterLevel[victim], InfectedLevel[victim]);
	if (Class == ZOMBIECLASS_SMOKER) Format(ClassName, sizeof(ClassName), "Smoker Lv. %d (%d)", SmokerLevel[victim], InfectedLevel[victim]);
	if (Class == ZOMBIECLASS_BOOMER) Format(ClassName, sizeof(ClassName), "Boomer Lv. %d (%d)", BoomerLevel[victim], InfectedLevel[victim]);
	if (Class == ZOMBIECLASS_JOCKEY) Format(ClassName, sizeof(ClassName), "Jockey Lv. %d (%d)", JockeyLevel[victim], InfectedLevel[victim]);
	if (Class == ZOMBIECLASS_CHARGER) Format(ClassName, sizeof(ClassName), "Charger Lv. %d (%d)", ChargerLevel[victim], InfectedLevel[victim]);
	if (Class == ZOMBIECLASS_SPITTER) Format(ClassName, sizeof(ClassName), "Spitter Lv. %d (%d)", SpitterLevel[victim], InfectedLevel[victim]);
	if (Class == ZOMBIECLASS_TANK) Format(ClassName, sizeof(ClassName), "Tank Lv. %d (%d)", TankLevel[victim], InfectedLevel[victim]);
	PrintHintText(attacker, "%s\nHealth: %d", ClassName, GetClientHealth(victim));
}

CallWeaponDamage(attacker, victim, value)
{
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim)) return;
	new damageBonus = 0;
	new String:weaponused[64];
	GetClientWeapon(attacker, weaponused, sizeof(weaponused));
	if (StrEqual(weaponused, "weapon_pistol", true) || 
		(StrEqual(weaponused, "weapon_pistol_magnum", true) && PistolLevel[attacker] >= GetConVarInt(PistolDeagleLevel)))
	{
		// If the survivor is using heal ammo, don't add damage modifiers, and return the health to the infected player.
		if (HealAmmoPistol[attacker])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + value);
			return;
		}
		PistolDamage[attacker][victim] += value;
		damageBonus = RoundToFloor(PistolLevel[attacker] * GetConVarFloat(WeaponBonusDamage));
		if (DrugsUsed[attacker] > 0 && DrugEffect[attacker])
		{
			damageBonus += RoundToFloor(DrugsUsed[attacker] * GetConVarFloat(DrugBonusDamage));
		}
		if (IsPlayerAlive(victim) && (GetClientHealth(victim) - damageBonus) > 0)
		{
			SetEntityHealth(victim, GetClientHealth(victim) - damageBonus);
			RoundAward[attacker] += damageBonus;
			AssistHurtInfected[attacker][victim] += damageBonus;
		}
		
	}
		
	else if (StrEqual(weaponused, "weapon_melee", true))
	{
		MeleeDamage[attacker][victim] += value;
		damageBonus = RoundToFloor(MeleeLevel[attacker] * GetConVarFloat(WeaponBonusDamage));
		if (DrugsUsed[attacker] > 0 && DrugEffect[attacker])
		{
			damageBonus += RoundToFloor(DrugsUsed[attacker] * GetConVarFloat(DrugBonusDamage));
		}
		if (IsPlayerAlive(victim) && (GetClientHealth(victim) - damageBonus) > 0)
		{
			SetEntityHealth(victim, GetClientHealth(victim) - damageBonus);
			RoundAward[attacker] += damageBonus;
			AssistHurtInfected[attacker][victim] += damageBonus;
		}
	}
	
	else if ((StrEqual(weaponused, "weapon_smg", true) && PhysicalLevel[attacker] >= GetConVarInt(UziLevelUnlock) && UziLevel[attacker] >= GetConVarInt(UziMac10Level)) || 
			(StrEqual(weaponused, "weapon_smg_mp5", true) && PhysicalLevel[attacker] >= GetConVarInt(UziLevelUnlock) && UziLevel[attacker] >= GetConVarInt(UziMp5Level)) || 
			(StrEqual(weaponused, "weapon_smg_silenced", true) && PhysicalLevel[attacker] >= GetConVarInt(UziLevelUnlock) && UziLevel[attacker] >= GetConVarInt(UziMp5Level)))
	{
		// If the survivor is using heal ammo, don't add damage modifiers, and return the health to the infected player.
		if (HealAmmoSmg[attacker])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + value);
			return;
		}
		UziDamage[attacker][victim] += value;
		damageBonus = RoundToFloor(UziLevel[attacker] * GetConVarFloat(WeaponBonusDamage));
		if (DrugsUsed[attacker] > 0 && DrugEffect[attacker])
		{
			damageBonus += RoundToFloor(DrugsUsed[attacker] * GetConVarFloat(DrugBonusDamage));
		}
		if (IsPlayerAlive(victim) && (GetClientHealth(victim) - damageBonus) > 0)
		{
			SetEntityHealth(victim, GetClientHealth(victim) - damageBonus);
			RoundAward[attacker] += damageBonus;
			AssistHurtInfected[attacker][victim] += damageBonus;
		}
	}
			
	else if ((StrEqual(weaponused, "weapon_autoshotgun", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunAutoLevel)) || 
			(StrEqual(weaponused, "weapon_pumpshotgun", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunPumpLevel)) || 
			(StrEqual(weaponused, "weapon_shotgun_chrome", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunChromeLevel)) || 
			(StrEqual(weaponused, "weapon_shotgun_spas", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunSpasLevel)))
	{
		// If the survivor is using heal ammo, don't add damage modifiers, and return the health to the infected player.
		if (HealAmmoShotgun[attacker])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + value);
			return;
		}
		ShotgunDamage[attacker][victim] += value;
		damageBonus = RoundToFloor(ShotgunLevel[attacker] * GetConVarFloat(WeaponBonusDamage));
		if (DrugsUsed[attacker] > 0 && DrugEffect[attacker])
		{
			damageBonus += RoundToFloor(DrugsUsed[attacker] * GetConVarFloat(DrugBonusDamage));
		}
		if (IsPlayerAlive(victim) && (GetClientHealth(victim) - damageBonus) > 0)
		{
			SetEntityHealth(victim, GetClientHealth(victim) - damageBonus);
			RoundAward[attacker] += damageBonus;
			AssistHurtInfected[attacker][victim] += damageBonus;
		}
	}
	else if ((StrEqual(weaponused, "weapon_rifle", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleM16Level)) || 
			(StrEqual(weaponused, "weapon_rifle_ak47", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleAK47Level)) || 
			(StrEqual(weaponused, "weapon_rifle_desert", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleDesertLevel)) || 
			(StrEqual(weaponused, "weapon_rifle_m60", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleM60Level)) || 
			(StrEqual(weaponused, "weapon_rifle_sg552", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleSG552Level)))
	{
		// If the survivor is using heal ammo, don't add damage modifiers, and return the health to the infected player.
		if (HealAmmoRifle[attacker])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + value);
			return;
		}
		RifleDamage[attacker][victim] += value;
		damageBonus = RoundToFloor(RifleLevel[attacker] * GetConVarFloat(WeaponBonusDamage));
		if (DrugsUsed[attacker] > 0 && DrugEffect[attacker])
		{
			damageBonus += RoundToFloor(DrugsUsed[attacker] * GetConVarFloat(DrugBonusDamage));
		}
		if (IsPlayerAlive(victim) && (GetClientHealth(victim) - damageBonus) > 0)
		{
			SetEntityHealth(victim, GetClientHealth(victim) - damageBonus);
			RoundAward[attacker] += damageBonus;
			AssistHurtInfected[attacker][victim] += damageBonus;
		}
	}
	else if ((StrEqual(weaponused, "weapon_sniper_awp", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperAwpLevel)) || 
			(StrEqual(weaponused, "weapon_sniper_military", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperMilitaryLevel)) || 
			(StrEqual(weaponused, "weapon_sniper_scout", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperScoutLevel)) || 
			(StrEqual(weaponused, "weapon_hunting_rifle", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperHuntingLevel)))
	{
		// If the survivor is using heal ammo, don't add damage modifiers, and return the health to the infected player.
		if (HealAmmoSniper[attacker])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + value);
			return;
		}
		SniperDamage[attacker][victim] += value;
		damageBonus = RoundToFloor(SniperLevel[attacker] * GetConVarFloat(WeaponBonusDamage));
		if (DrugsUsed[attacker] > 0 && DrugEffect[attacker])
		{
			damageBonus += RoundToFloor(DrugsUsed[attacker] * GetConVarFloat(DrugBonusDamage));
		}
		if (IsPlayerAlive(victim) && (GetClientHealth(victim) - damageBonus) > 0)
		{
			SetEntityHealth(victim, GetClientHealth(victim) - damageBonus);
			RoundAward[attacker] += damageBonus;
			AssistHurtInfected[attacker][victim] += damageBonus;
		}
	}
}

InfectedPlayerHasDied(infected)
{
	if (IsClientIndexOutOfRange(infected)) return;
	if (!IsClientInGame(infected)) return;
	
	decl Float:point_reward;
	decl xp_reward;
	// We check if tank is > 0 to make sure that it wasn't a tank spawned on the finale (with 1 health)
	if (ClassTank[infected])
	{
		TankCount--;
		TankCooldownTime = -1.0;
		if (TankCount < 1)
		{
			TankCount = 0;
			CreateTimer(1.0, EnableTankPurchases, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	/*		Was this player alone? Find out			*/
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 2 || !IsPlayerAlive(i)) continue;
		if (AssistHurtInfected[i][infected] > 0.0)
		{
			point_reward = 0.0;
			xp_reward = 0;
			if (!ClassTank[infected])
			{
				point_reward = ((AssistHurtInfected[i][infected] * GetConVarFloat(SurvivorAssistPoints)) * SurvivorMultiplier[i]) * GetConVarFloat(SurvivorAssistMultiplier);
				xp_reward = RoundToFloor(AssistHurtInfected[i][infected] * GetConVarFloat(XPPerRoundDamageSurvivor));
			}
			else
			{
				point_reward = ((AssistHurtInfected[i][infected] * GetConVarFloat(SurvivorAssistPoints)) * SurvivorMultiplier[i]) * GetConVarFloat(SurvivorTankAssistPoints);
				xp_reward = RoundToFloor(AssistHurtInfected[i][infected] * GetConVarFloat(XPPerTankDamageSurvivor));
			}
			SurvivorTeamPoints += (point_reward * GetConVarFloat(SurvivorTeamPointsMP));
			if (showpoints[i] == 1)
			{
				PrintToChat(i, "%s \x01DMG \x04%N \x01: \x05%d \x01for \x05 %3.3f \x01point(s). (%3.3f)", POINTS_INFO, infected, AssistHurtInfected[i][infected], point_reward, SurvivorMultiplier[i]);
			}
			SurvivorPoints[i] += point_reward;
			PhysicalExperience[i] += RoundToFloor(xp_reward * GetConVarFloat(EventMoreXPFriday));
			AssistHurtInfected[i][infected] = 0;
			// give 0 experience since we gave them physical experience.
			experience_increase(i, 0);
			continue;
		}
	}
	
	// now we need to award them for each of the weapon categories they used, if they have that category unlocked.
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 2 || !IsPlayerAlive(i)) continue;
		PistolDamage[i][infected] = RoundToFloor(PistolDamage[i][infected] * GetConVarFloat(XPPerRoundDamageSurvivor));
		MeleeDamage[i][infected] = RoundToFloor(MeleeDamage[i][infected] * GetConVarFloat(XPPerRoundDamageSurvivor));
		UziDamage[i][infected] = RoundToFloor(UziDamage[i][infected] * GetConVarFloat(XPPerRoundDamageSurvivor));
		ShotgunDamage[i][infected] = RoundToFloor(ShotgunDamage[i][infected] * GetConVarFloat(XPPerRoundDamageSurvivor));
		SniperDamage[i][infected] = RoundToFloor(SniperDamage[i][infected] * GetConVarFloat(XPPerRoundDamageSurvivor));
		RifleDamage[i][infected] = RoundToFloor(RifleDamage[i][infected] * GetConVarFloat(XPPerRoundDamageSurvivor));
		/*
		if (showpoints[i])
		{
			if (PistolDamage[i][infected] > 0) PrintToChat(i, "%s \x01Pistol : \x05%d", XP_INFO, PistolDamage[i][infected]);
			if (MeleeDamage[i][infected] > 0) PrintToChat(i, "%s \x01Melee : \x05%d", XP_INFO, MeleeDamage[i][infected]);
			if (UziDamage[i][infected] > 0) PrintToChat(i, "%s \x01Uzi : \x05%d", XP_INFO, UziDamage[i][infected]);
			if (ShotgunDamage[i][infected] > 0) PrintToChat(i, "%s \x01Shotgun : \x05%d", XP_INFO, ShotgunDamage[i][infected]);
			if (SniperDamage[i][infected] > 0) PrintToChat(i, "%s \x01Sniper : \x05%d", XP_INFO, SniperDamage[i][infected]);
			if (RifleDamage[i][infected] > 0) PrintToChat(i, "%s \x01Rifle : \x05%d", XP_INFO, RifleDamage[i][infected]);
		}
		*/
		PistolExperience[i] += RoundToFloor(PistolDamage[i][infected] * GetConVarFloat(EventMoreXPFriday));
		MeleeExperience[i] += RoundToFloor(MeleeDamage[i][infected] * GetConVarFloat(EventMoreXPFriday));
		UziExperience[i] += RoundToFloor(UziDamage[i][infected] * GetConVarFloat(EventMoreXPFriday));
		ShotgunExperience[i] += RoundToFloor(ShotgunDamage[i][infected] * GetConVarFloat(EventMoreXPFriday));
		SniperExperience[i] += RoundToFloor(SniperDamage[i][infected] * GetConVarFloat(EventMoreXPFriday));
		RifleExperience[i] += RoundToFloor(RifleDamage[i][infected] * GetConVarFloat(EventMoreXPFriday));
		PistolDamage[i][infected] = 0;
		MeleeDamage[i][infected] = 0;
		UziDamage[i][infected] = 0;
		ShotgunDamage[i][infected] = 0;
		SniperDamage[i][infected] = 0;
		RifleDamage[i][infected] = 0;
		experience_increase(i, 0);
	}
}