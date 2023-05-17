_AbilityEvent_OnPluginStart()
{
	HookEvent("weapon_reload", Event_WeaponReload);
	HookEvent("ability_use", Event_AbilityUse);
}

/*			CONNECTIVITY EVENTS			*/

public Action:Event_WeaponReload(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsClientIndexOutOfRange(client) && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2) ExecCheatCommand(client, "give", "ammo");
}

public Action:Event_AbilityUse(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(client) || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 3 || 
	    (	!ClassHunter[client] && !ClassSpitter[client]	)) return;
	decl String:AbilityUsed[64];
	GetEventString(event, "ability", AbilityUsed, sizeof(AbilityUsed));
	
	if (StrContains(AbilityUsed, "lunge", true) > -1)
	{
		GetClientAbsOrigin(client, Float:StartPounceLocation[client]);
	}
	if (StrContains(AbilityUsed, "spit", true) > -1 && SuperUpgradeSpitter[client])
	{
		CreateTimer(0.2, SetInvisState, client);
	}
}

public Action:SetInvisState(Handle:timer, any:client)
{
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, GetConVarInt(InfectedTier3Color[0]), GetConVarInt(InfectedTier3Color[1]), GetConVarInt(InfectedTier3Color[2]), 0);
	SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
	CreateTimer(GetConVarFloat(SpitterInvisTime), RemoveSpitterInvis, client);
}

public Action:OnPlayerRunCmd(client, &buttons)
{
	if (!IsHuman(client) || (!ClassJockey[client] && !GravityBoots[client] && !ClassSmoker[client])) return;
	decl Float:vel_z;
	vel_z = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	if (ClassJockey[client])
	{
		if (GetEntityFlags(client) & FL_ONGROUND) JockeyJumping[client] = false;
		if ((buttons & IN_ATTACK) && (vel_z == 0.0) && !JockeyJumping[client])
		{
			JockeyJumping[client] = true;
			GetClientAbsOrigin(client, StartingJockeyLocation[client]);
		}
		else if (SuperUpgradeJockey[client] && !JockeyJumpCooldown[client] && (buttons & IN_JUMP))
		{
			JockeyJumpCooldown[client] = true;
			CreateTimer(2.0, RemoveJockeyJump, client, TIMER_FLAG_NO_MAPCHANGE);
			CallJockeyJump(client);
		}
	}
	else if (GravityBoots[client] && !CoveredInBile[client] && !HeavyBySpit[client] && !BrokenLegs[client] && (GetEntityFlags(client) & FL_ONGROUND))
	{
		if (Ensnared[client])
		{
			if (L4D2_GetInfectedAttacker(client) == -1) Ensnared[client] = false;
		}
		if ((buttons & IN_JUMP) && GravityBoots[client] > 0 && !Ensnared[client])
		{
			new number = GetRandomInt(GetConVarInt(PersonalAbilityLossMin), GetConVarInt(PersonalAbilityLossMax));
			GravityBoots[client] -= number;
			if (GravityBoots[client] < 1)
			{
				PrintToChat(client, "%s \x01Your Gravity Boots run out of super fuel.", INFO);
				GravityBoots[client] = 0;
			}
			SetEntityGravity(client, GetConVarFloat(GravityBootsGravity));
			CreateTimer(0.5, CheckForGrounding, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (ClassSmoker[client])
	{
		if ((buttons & IN_ATTACK) && (SuperUpgradeSmoker[client] || SmokerLevel[client] >= GetConVarInt(InfectedTier3Level)) && !SmokerWhipCooldown[client])
		{
			SmokerWhipCooldown[client] = true;
			CreateTimer(3.0, RemoveSmokerWhip, client, TIMER_FLAG_NO_MAPCHANGE);
			CallSmokerWhip(client);
		}
	}
}

CallJockeyJump(client)
{
	new victim = JockeyVictim[client];
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim) || !IsRiding[client] || !Ensnared[victim]) return;
	new Float:vel[3];
	vel[0] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[0]");
	vel[1] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[1]");
	vel[2] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[2]");
	new Float:velo[3];
	velo[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	velo[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	velo[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	vel[2] += GetConVarFloat(JockeyRideJumpForce);
	velo[2] += GetConVarFloat(JockeyRideJumpForce);
	TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vel);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velo);
}

CallSmokerWhip(client)
{
	new victim = SmokeVictim[client];
	if (IsClientIndexOutOfRange(victim) || !IsClientInGame(victim) || IsFakeClient(victim) || !IsPlayerAlive(victim) || !IsSmoking[client] || !Ensnared[victim]) return;
	new Float:pullrand;
	new Float:lungerand;
	new pullnumber = GetRandomInt(1, 2);
	new lungenumber = GetRandomInt(1, 2);
	new Float:vel[3];
	vel[0] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[0]");
	vel[1] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[1]");
	vel[2] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[2]");
	new Float:whipforce = GetRandomFloat(GetConVarFloat(SmokerWhipForceMin), GetConVarFloat(SmokerWhipForceMax));
	vel[2] += whipforce;
	if (pullnumber == 1) pullrand = GetRandomFloat(GetConVarFloat(SmokerWhipMin1), GetConVarFloat(SmokerWhipMin2));
	else pullrand = GetRandomFloat(GetConVarFloat(SmokerWhipMax1), GetConVarFloat(SmokerWhipMax2));
	if (lungenumber == 1) lungerand = GetRandomFloat(GetConVarFloat(SmokerWhipPullMin1), GetConVarFloat(SmokerWhipPullMin2));
	else lungerand = GetRandomFloat(GetConVarFloat(SmokerWhipPullMax1), GetConVarFloat(SmokerWhipPullMax2));
	
	if (pullrand < 0.0 && vel[0] > 0.0)
	{
		vel[0] *= -1.0;
	}
	vel[0] += pullrand;
	if (lungerand < 0.0 && vel[1] > 0.0)
	{
		vel[1] *= -1.0;
	}
	vel[1] += lungerand;
	
	TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vel);
}

public OnEntityCreated(entity, const String:classname[])
{	
	if(StrEqual(classname, "infected", false) && UncommonType != 0)
	{
		if (UncommonType == 1 || UncommonType == 4) SetEntityModel(entity, "models/infected/common_male_mud.mdl");
		if (UncommonType == 2 || UncommonType == 5) SetEntityModel(entity, "models/infected/common_male_jimmy.mdl");
		else if (UncommonType == 3 || UncommonType == 6) SetEntityModel(entity, "models/infected/common_male_riot.mdl");
		else if (UncommonType == 4 || UncommonType == 8) SetEntityModel(entity, "models/infected/common_male_roadcrew.mdl");
		else if (UncommonType == 9)
		{
			// Uncommon Panic Event! A bunch of random uncommons!
			new number = GetRandomInt(1, 4);
			if (number == 1) SetEntityModel(entity, "models/infected/common_male_mud.mdl");
			else if (number == 2) SetEntityModel(entity, "models/infected/common_male_jimmy.mdl");
			else if (number == 3) SetEntityModel(entity, "models/infected/common_male_riot.mdl");
			else if (number == 4) SetEntityModel(entity, "models/infected/common_male_roadcrew.mdl");
		}
		UncommonRemaining--;
		if (UncommonRemaining < 1)
		{
			UncommonRemaining = 0;
			UncommonType = 0;
		}
	}
}