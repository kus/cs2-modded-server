_HealEvents_OnPluginStart()
{
	HookEvent("heal_success", Event_HealSuccess);
	HookEvent("heal_begin", Event_HealBegin);
	HookEvent("revive_success", Event_ReviveSuccess);
	HookEvent("adrenaline_used", Event_AdrenalineUsed);
	HookEvent("pills_used", Event_PillsUsed);
}

/*			EVENTS FOR EARNING POINTS THROUGH HEALTH-RELATED STUFF			*/

public Action:Event_PillsUsed(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "subject"));
	if (IsClientIndexOutOfRange(attacker)) return;
	if (!IsClientInGame(attacker) || IsFakeClient(attacker)) return;
	if (ItemLevel[attacker] >= GetConVarInt(DrugDealerLevel))
	{
		DrugsUsed[attacker]++;
		if (OnDrugs[attacker])
		{
			DrugTimer[attacker] = GetConVarFloat(DrugTimerStart);
			PrintToChat(attacker, "%s \x01You satisfy your drug addiction.", INFO);
		}
		if (DrugsUsed[attacker] == GetConVarInt(DrugAddiction))
		{
			DrugTimer[attacker] = -1.0;
			CreateTimer(1.0, DrugsUsedCounter, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			OnDrugs[attacker] = true;
		}
		if (!DrugEffect[attacker])
		{
			DrugEffect[attacker] = true;
			PrintToChat(attacker, "%s \x01You feel... \x04STRONGER!", INFO);
			CreateTimer(GetConVarFloat(DrugEffectTime), RemoveDrugEffect, attacker, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action:Event_AdrenalineUsed(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(attacker)) return;
	if (!IsClientInGame(attacker) || IsFakeClient(attacker)) return;
	if (BrokenLegs[attacker])
	{
		PrintToChat(attacker, "%s \x01Drugs... Make your legs better! Wow!", INFO);
		BrokenLegs[attacker] = false;
		SetEntDataFloat(attacker, laggedMovementOffset, PlayerMovementSpeed[attacker], true);
	}
	if (ItemLevel[attacker] >= GetConVarInt(DrugDealerLevel))
	{
		DrugsUsed[attacker]++;
		if (OnDrugs[attacker])
		{
			DrugTimer[attacker] = GetConVarFloat(DrugTimerStart);
			PrintToChat(attacker, "%s \x01You satisfy your drug addiction.", INFO);
		}
		if (DrugsUsed[attacker] == GetConVarInt(DrugAddiction))
		{
			DrugTimer[attacker] = -1.0;
			CreateTimer(1.0, DrugsUsedCounter, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			OnDrugs[attacker] = true;
		}
		if (!DrugEffect[attacker])
		{
			DrugEffect[attacker] = true;
			PrintToChat(attacker, "%s \x01You feel... \x04STRONGER!", INFO);
			CreateTimer(GetConVarFloat(DrugEffectTime), RemoveDrugEffect, attacker, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action:Event_HealSuccess(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject	 = GetClientOfUserId(GetEventInt(event, "subject"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 2) return;
	if (IsClientIndexOutOfRange(subject) || !IsClientInGame(subject) || IsFakeClient(subject) || GetClientTeam(subject) != 2) return;
	if (attacker != subject) experience_medical_increase(attacker, GetConVarInt(HHP) + RoundToFloor(((PhysicalLevel[attacker] * PhysicalLevel[subject]) * GetConVarFloat(HHPMULT))));
	else experience_medical_increase(attacker, GetConVarInt(HHP));
	
	/*	Give the attacker (healer) points for healing.	*/
	if (showpoints[attacker])
	{
		if (attacker != subject && showpoints[attacker] == 1) PrintToChat(attacker, "%s Used Medical Pack: %3.3f Point(s).", POINTS_INFO, SurvivorMultiplier[attacker] * GetConVarFloat(HealPoints));
		else if (showpoints[attacker] == 1) PrintToChat(attacker, "%s Used Medical Pack: %3.3f Point(s).", POINTS_INFO, GetConVarFloat(HealPoints));
	}
	if (attacker != subject) SurvivorPoints[attacker] += (SurvivorMultiplier[attacker] * GetConVarFloat(HealPoints));
	else SurvivorPoints[attacker] += GetConVarFloat(HealPoints);
	
	new HealthRestored = GetEventInt(event, "health_restored");
	RoundHealing[attacker] += HealthRestored;
	if (RoundHealing[attacker] > BestHealing[0])
	{
		BestHealing[0] = RoundHealing[attacker];
		BestHealing[1] = attacker;
	}
	new MaxHealth = 100;
	if (HealthRestored >= Meds[attacker])
	{
		if (Difference[subject] + Meds[attacker] > MaxHealth) SetEntityHealth(subject, MaxHealth);
		Meds[attacker] = 0;
	}
	else if (HealthRestored < Meds[attacker])
	{
		Meds[attacker] -= HealthRestored;
		PrintToChat(attacker, "%s \x05%d \x01meds remaining.", INFO, Meds[attacker]);
		ExecCheatCommand(attacker, "give", "first_aid_kit");
	}
}

public Action:Event_HealBegin(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject	 = GetClientOfUserId(GetEventInt(event, "subject"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 2) return;
	if (Meds[attacker] <= 0 || Meds[attacker] > GetConVarInt(MedsAmount))
	{
		Meds[attacker] = GetConVarInt(MedsAmount);
		PrintToChat(attacker, "%s \x05%d \x01meds remaining.", INFO, Meds[attacker]);
	}
	if (IsClientIndexOutOfRange(subject) || !IsClientInGame(subject) || IsFakeClient(subject) || GetClientTeam(subject) != 2) return;
	Difference[subject] = GetClientHealth(subject);
}

public Action:Event_ReviveSuccess(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject	 = GetClientOfUserId(GetEventInt(event, "subject"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 2) return;
	experience_medical_increase(attacker, GetConVarInt(HHP) + RoundToFloor(((PhysicalLevel[attacker] * PhysicalLevel[subject]) * GetConVarFloat(HHPMULT))));
	if (showpoints[attacker])
	{
		if (showpoints[attacker] == 1) PrintToChat(attacker, "%s Revive Teammate: %3.3f Point(s).", POINTS_INFO, SurvivorMultiplier[attacker] * GetConVarFloat(HealPoints));
	}
	RoundRescuer[attacker] += RoundToFloor(SurvivorMultiplier[attacker] * GetConVarFloat(HealPoints));
	if (RoundRescuer[attacker] > BestRescuer[0])
	{
		BestRescuer[0] = RoundRescuer[attacker];
		BestRescuer[1] = attacker;
	}
	SurvivorPoints[attacker] += (SurvivorMultiplier[attacker] * GetConVarFloat(HealPoints));
}