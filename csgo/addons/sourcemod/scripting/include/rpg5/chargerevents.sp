_ChargerEvents_OnPluginStart()
{
	HookEvent("charger_pummel_end", Event_ChargerPummelEnd);
	HookEvent("charger_carry_start", Event_ChargerCarryStart);
	HookEvent("charger_carry_end", Event_ChargerCarryEnd);
	HookEvent("charger_impact", Event_ChargerImpact);
	HookEvent("charger_charge_start", Event_ChargeStart);
	HookEvent("charger_charge_end", Event_ChargeEnd);
}

/*			CHARGER EVENTS			*/

public Action:Event_ChargeStart(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || !SuperUpgradeCharger[attacker] || !IsPlayerAlive(attacker)) return;
	SetEntDataFloat(attacker, laggedMovementOffset, PlayerMovementSpeed[attacker] * GetConVarFloat(ChargerSpeedIncrease), true);
}

public Action:Event_ChargeEnd(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker) || !SuperUpgradeCharger[attacker] || !IsPlayerAlive(attacker)) return;
	SetEntDataFloat(attacker, laggedMovementOffset, PlayerMovementSpeed[attacker], true);
}

public Action:Event_ChargerPummelEnd(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim)) return;
	Ensnared[victim] = false;
}

public Action:Event_ChargerCarryStart(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	
	if (!IsClientIndexOutOfRange(attacker) && IsClientInGame(attacker) && !IsFakeClient(attacker))
	{
		GetClientAbsOrigin(attacker, Float:StartChargeLocation[attacker]);
		if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim))
		{		
			decl Float:EnsnareValue;
			EnsnareValue = SurvivorMultiplier[victim] * GetConVarFloat(SurvivorEnsnareValue);
			if (showpoints[attacker] == 1) PrintToChat(attacker, "%s \x01Survivor Ensnared: \x04%3.3f \x01Point(s).", POINTS_INFO, EnsnareValue);
			InfectedPoints[attacker] += EnsnareValue;
			
			experience_increase(attacker, RoundToFloor(EnsnareValue));
		}
	}
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim)) Ensnared[victim] = true;
}

public Action:Event_ChargerCarryEnd(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	
	if (!IsClientIndexOutOfRange(attacker) && IsClientInGame(attacker) && !IsFakeClient(attacker))
	{
		new Float:EndChargeLocation[3];
		GetClientAbsOrigin(attacker, EndChargeLocation);
		new Float:ChargeDistance = GetVectorDistance(StartChargeLocation[attacker], EndChargeLocation);
		ChargeDistance *= GetConVarFloat(ChargeDistanceMultiplier);
		
		if (showpoints[attacker] == 1) PrintToChat(attacker, "%s \x01Charge Distance: \x04%3.3f \x01Point(s).", POINTS_INFO, ChargeDistance);
		InfectedPoints[attacker] += ChargeDistance;
		
		experience_increase(attacker, RoundToFloor(ChargeDistance));
	}
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim)) Ensnared[victim] = false;
}

public Action:Event_ChargerImpact(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	
	if (!IsClientIndexOutOfRange(attacker) && IsClientInGame(attacker) && !IsFakeClient(attacker))
	{
		if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim))
		{
			if (showpoints[attacker] == 1) PrintToChat(attacker, "%s \x01Impact Survivor: \x04%3.3f \x01Point(s).", POINTS_INFO, SurvivorMultiplier[victim] * GetConVarFloat(SurvivorImpactPoints));
			InfectedPoints[attacker] += (SurvivorMultiplier[victim] * GetConVarFloat(SurvivorImpactPoints));
			
			experience_increase(attacker, RoundToFloor(SurvivorMultiplier[victim] * GetConVarFloat(SurvivorImpactPoints)));
			
			if (UpgradeCharger[attacker] || ChargerLevel[attacker] >= GetConVarInt(InfectedTier2Level))
			{
				BlindPlayer(victim, GetConVarInt(BlindAmount));
				CreateTimer(GetConVarFloat(ImpactBlindTime), RemoveBlindAmmo, victim, TIMER_FLAG_NO_MAPCHANGE);
			}
			if (ChargerLevel[attacker] >= GetConVarInt(InfectedTier4Level) && !BrokenLegs[victim])
			{
				if (IsPlayerAlive(victim))
				{
					BrokenLegs[victim] = true;
					SetEntDataFloat(victim, laggedMovementOffset, GetConVarFloat(BrokenLegsSpeed), true);
					PrintHintText(victim, "Your legs are broken!\nFind some adrenaline!\nDrugs will make you feel better!");
				}
			}
		}
	}
	if (!IsClientIndexOutOfRange(victim) && IsClientInGame(victim) && !IsFakeClient(victim)) Ensnared[victim] = false;
}