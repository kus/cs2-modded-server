_HunterEvents_OnPluginStart()
{
	HookEvent("lunge_pounce", Event_LungePounce);
	HookEvent("pounce_stopped", Event_PounceStopped);
}

/*			HUNTER EVENTS			*/

public Action:Event_LungePounce(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker)) return;
	new Float:EndPounceLocation[3];
	GetClientAbsOrigin(attacker, EndPounceLocation);
	
	new Float:PounceDistance = GetVectorDistance(StartPounceLocation[attacker], EndPounceLocation);
	PounceDistance *= GetConVarFloat(HunterDistanceMultiplier);
	if (PounceDistance < 1.0) PounceDistance = 1.0;
	
	InfectedPoints[attacker] += PounceDistance;
	if (showpoints[attacker] == 1) PrintToChat(attacker, "%s \x01Pounce Distance: \x04%3.3f \x01Point(s).", POINTS_INFO, PounceDistance);
	if (PounceDistance >= 2.0) experience_increase(attacker, RoundToFloor(PounceDistance/2.0));
	else experience_increase(attacker, RoundToFloor(PounceDistance));
	
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim)) return;
	// Just in case they have gravity boots - set their gravity to normal
	SetEntityGravity(victim, 1.0);
	if (SuperUpgradeHunter[attacker])
	{
		// Super hunter! Make the player invisible with the hunter
		// And remove his glow. lol
		L4D2_SetPlayerSurvivorGlowState(victim, false);
		SetEntityRenderMode(victim, RENDER_TRANSCOLOR)
		if (IsBlackWhite[victim] && VipName != victim)
		{
			SetEntityRenderColor(victim, GetConVarInt(BlackWhiteColor[0]), GetConVarInt(BlackWhiteColor[1]), GetConVarInt(BlackWhiteColor[2]), 150);
		}
		else
		{
			if (VipName == victim) SetEntityRenderColor(victim, GetConVarInt(VipColor[0]), GetConVarInt(VipColor[1]), GetConVarInt(VipColor[2]), 150);
			else SetEntityRenderColor(victim, 255, 255, 255, 150);
		}
	}
	Ensnared[victim] = true;
	Hunter[victim] = attacker;
}

public Action:Event_PounceStopped(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new savior = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsHuman(savior))
	{
		SurvivorPoints[savior] += SurvivorMultiplier[savior] * GetConVarFloat(SaveSurvivorPoints);
		if (showpoints[savior] == 1) PrintToChat(savior, "%s \x01Save Survivor: \x03%3.3f \x01Point(s).", POINTS_INFO, SurvivorMultiplier[savior] * GetConVarFloat(SaveSurvivorPoints));
		experience_medical_increase(savior, RoundToFloor(SurvivorMultiplier[savior] * GetConVarFloat(SaveSurvivorPoints)));

		RoundRescuer[savior] += RoundToFloor(SurvivorMultiplier[savior] * GetConVarFloat(SaveSurvivorPoints));
		if (RoundRescuer[savior] > BestRescuer[0])
		{
			BestRescuer[0] = RoundRescuer[savior];
			BestRescuer[1] = savior;
		}
	}
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim)) return;
	Ensnared[victim] = false;
	if (!IsPlayerAlive(victim)) return;
	new hunter = Hunter[victim];
	if (!IsClientIndexOutOfRange(hunter) && IsClientInGame(hunter) && !IsFakeClient(hunter) && SuperUpgradeHunter[hunter])
	{
		L4D2_SetPlayerSurvivorGlowState(victim, true);
		if (IsPlayerAlive(victim)) SetEntityRenderMode(victim, RENDER_NORMAL);
		if (IsBlackWhite[victim])
		{
			if (IsPlayerAlive(victim))
			{
				if (VipName == victim) SetEntityRenderColor(victim, GetConVarInt(VipColor[0]), GetConVarInt(VipColor[1]), GetConVarInt(VipColor[2]), 200);
				else SetEntityRenderColor(victim, GetConVarInt(BlackWhiteColor[0]), GetConVarInt(BlackWhiteColor[1]), GetConVarInt(BlackWhiteColor[2]), 255);
			}
		}
		else
		{
			if (IsPlayerAlive(victim))
			{
				if (VipName == victim) SetEntityRenderColor(victim, GetConVarInt(VipColor[0]), GetConVarInt(VipColor[1]), GetConVarInt(VipColor[2]), 255);
				else SetEntityRenderColor(victim, 255, 255, 255, 255);
			}
		}
	}
}