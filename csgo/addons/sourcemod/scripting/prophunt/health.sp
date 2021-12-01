void Client_SeekerFiredWeapon(int iClient, int iWeapon)
{
	if(g_iRoundStart == 0)
		return;
	
	if(GetClientTeam(iClient) != CS_TEAM_CT)
		return;
	
	// Don't check for targets for the following weapon types;
	switch(g_iWeapontype[iClient])
	{
		case WEAPONTYPE_HEALTHSHOT: return;
		case WEAPONTYPE_GRENADE: return;
		case WEAPONTYPE_C4: return;
	}
	
	// How much HP to take for this weapon type
	int iTakeHealth;
	if(g_cvWeaponUseHealth[g_iWeapontype[iClient]] != null)
		iTakeHealth = g_cvWeaponUseHealth[g_iWeapontype[iClient]].IntValue;
	// Otherwise use default
	else iTakeHealth = g_cvWeaponUseHealthDefault.IntValue;
	
	// Forward
	Call_StartForward(g_OnSeekerUseWeapon);
	Call_PushCell(iClient);
	Call_PushCell(iWeapon);
	Call_PushCell(g_iWeapontype[iClient]);
	Call_PushCellRef(iTakeHealth);
	Call_Finish();
	
	// Amount of HP changed below 1, abort
	if(iTakeHealth < 1)
		return;
	
	g_iDelayedDmg[iClient] += iTakeHealth;
	
	// Delay damage in case we hit something, if we hit something we survive eventually
	RequestFrame(DelayedDamage, iClient);
	
	// No hit prediction for targets for the following weapon types;
	switch(g_iWeapontype[iClient])
	{
		case WEAPONTYPE_KNIFE: return;
		case WEAPONTYPE_TASER: return;
	}
	
	int iTarget = PredictSeekerShot(iClient);
	
	if(iTarget > 0)
	{
		float fNull[3];
		Client_SimulateHiderDamage(iTarget, iClient, iWeapon, iWeapon, 25.0, DMG_BULLET, fNull, fNull, false);
	}
}

/* Delay damage, if a hit event occurs this frame it will be handled instantly */

void DelayedDamage(int iClient)
{
	if(g_iRoundStart == 0)
		return;
	
	if(iClient < 1 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
	{
		g_iDelayedDmg[iClient] = 0;
		return;
	}
	
	if(g_iDelayedDmg[iClient] == 0)
		return;
	
	// TODO Missed shoot forward
	
	int iHealth = GetClientHealth(iClient);
	int iNewHealth = iHealth - g_iDelayedDmg[iClient];
	
	if(iNewHealth < 1)
	{
		// Suicide
		if(g_cvSeekerCanKillSelf.BoolValue)
		{
			ForcePlayerSuicide(iClient);
			g_iDelayedDmg[iClient] = 0;
			return;
		}
		else iNewHealth = 1;
	}
	
	SetEntityHealth(iClient, iNewHealth);
	
	g_iDelayedDmg[iClient] = 0;
}

public Action Hook_OnTraceAttack(int iVictim, int &iAttacker, int &inflictor, float &fDamage, int &iDamagetype, int &iAmmotype, int iHitbox, int iHitgroup) 
{ 
	if(!Ready())
		return Plugin_Continue;
	
	if(g_iRoundStart == 0)
		return Plugin_Handled;
	
	if(g_bBlockFakeProp[iVictim])
		return Plugin_Continue;
	
	if(GetClientTeam(iVictim) == CS_TEAM_T)
	{
		// Block dmg caused by bullets to hide dmg sounds and dmg done to the invisible player's hitbox
		if(iDamagetype & DMG_BULLET)
			return Plugin_Handled;
		
		return Plugin_Continue;
	}
	
	return Plugin_Continue; 
} 

public Action Hook_OnTakeDamage(int iVictim, int &iAttacker, int &iInflictor, float &fDamage, int &iDamagetype, int &iWeapon, float fDamageForce[3], float fDamagePosition[3])
{
	if(!Ready())
		return Plugin_Continue;
	
	if(g_iRoundStart == 0)
		return Plugin_Handled;
	
	bool bForce;
	
	// If the player takes damage from a non-player source try to get the owner of that source
	if(iInflictor > MaxClients && HasEntProp(iInflictor, Prop_Send, "m_hOwnerEntity"))
	{
		iAttacker = GetEntPropEnt(iInflictor, Prop_Send, "m_hOwnerEntity");
		bForce = true;
	}
	
	// Hider only take damage by seekers
	if(GetClientTeam(iVictim) == CS_TEAM_T)
	{
		if(Entity_IsPlayer(iAttacker) && GetClientTeam(iAttacker) == CS_TEAM_CT)
		{
			if(!g_bIsPlayerDead[iVictim]) Client_SimulateHiderDamage(iVictim, iAttacker, iInflictor, iWeapon, fDamage, iDamagetype, fDamageForce, fDamagePosition, bForce);
			
			return g_bBlockFakeProp[iVictim] ? Plugin_Continue : Plugin_Handled;
		}
		
		return Plugin_Continue;
	}
	
	// Seekers shouldn't attack seekers
	if(Entity_IsPlayer(iAttacker) && GetClientTeam(iAttacker) == CS_TEAM_CT)
		return Plugin_Handled;
	
	// Allow fall damage etc.
	return Plugin_Continue;
}

public Action Hook_OnDamageFakeProp(int iEntity, int &iAttacker, int &iInflictor, float &fDamage, int &iDamagetype, int &iWeapon, float fDamageForce[3], float fDamagePosition[3])
{
	if(!Ready())
		return Plugin_Continue;
	
	if(g_iRoundStart == 0)
		return Plugin_Handled;
	
	// Search fakeprop owner
	
	int iVictim;
	LoopIngameClients(iClient)
	{
		if(Client_GetFakeProp(iClient) == iEntity)
		{
			iVictim = iClient;
			break;
		}
	}
	
	Client_SimulateHiderDamage(iVictim, iAttacker, iInflictor, iWeapon, fDamage, iDamagetype, fDamageForce, fDamagePosition, false);
	
	return Plugin_Handled;
}

void Client_SimulateHiderDamage(int iVictim, int iAttacker, int iInflictor, int iWeapon, float fDamage, int iDamagetype, float fDamageForce[3], float fDamagePosition[3], bool bForce)
{
	if(g_iRoundStart == 0)
		return;
	
	if(!ClientIsValid(iVictim) || GetClientTeam(iVictim) != CS_TEAM_T)
		return;
	
	if(!ClientIsValid(iAttacker) || GetClientTeam(iAttacker) != CS_TEAM_CT)
		return;
	
	if(!bForce && g_iDelayedDmg[iAttacker] == 0) // Looks like this function was already called this tick (ignoring multi hits)
		return;
	
	// Hider health
	
	int iHNewHealth = GetClientHealth(iVictim) - RoundToFloor(fDamage);
	bool bLethal = iHNewHealth < 1;
	
	// Give & Steal points
	
	if(bLethal)
	{
		SetPoints(iVictim, 0.0); // Reset hider points
		AddPoints(iAttacker, g_cvPointsSeekerKill.FloatValue + (g_cvPointsSeekerSteal.FloatValue * GetPoints(iVictim))); // Give seeker points
	}
	
	// Seeker health
	
	int iBonus = GetHPBonus(iAttacker, bLethal); // Health a seeker gets for hitting/killing a hider
	
	if(bForce)
	{
		if (bLethal) 
			iBonus = g_cvWeaponKillHealthDefault.IntValue;
		else iBonus = 1 + RoundToFloor(fDamage / 8.1); // Max inferno dmg + 0.1
	}
	
	int iTake = g_iDelayedDmg[iAttacker];
	g_iDelayedDmg[iAttacker] = 0;
	
	// Forward
	Call_StartForward(g_OnHiderHit);
	Call_PushCell(iVictim);
	Call_PushCell(iAttacker);
	Call_PushCell(iWeapon);
	Call_PushCell(bLethal);
	Call_PushFloatRef(fDamage);
	Call_PushCellRef(iBonus);
	Call_PushCellRef(iTake);
	Call_Finish();
	
	// Simulate damage done at hider
	if(fDamage >= 1.0)
	{
		if(bLethal)
		{
			if(iInflictor < 1)
				iInflictor = iWeapon;

			//Use point_hurt to do damage to hiders, but damage direction and force will be lost, anyway rag-dolls will be deleted later on so why not?
			if(g_cvAlterHurt.BoolValue)
			{
				static char weapon_name[33];
            	int iItemDefIndex = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
            	CS_WeaponIDToAlias(CS_ItemDefIndexToID(iItemDefIndex), weapon_name, sizeof(weapon_name)); 
				g_bIsPlayerDead[iVictim] = true;
				DamageHurt(iAttacker, iVictim, 1000, 0.0, 0, weapon_name);
			}
			else SDKHooks_TakeDamage(iVictim, iInflictor, iAttacker, fDamage + 1000.0, iDamagetype, iWeapon, fDamageForce, fDamagePosition); // Allow hitsounds when the hider will die anyway
		}
		else SetEntityHealth(iVictim, iHNewHealth); 
	}
	
	// Simulate damage or heal hider
	int iHealthDiff = iBonus - iTake;
	if(iHealthDiff != 0)
	{
		int iSNewHealth = GetClientHealth(iAttacker) + iHealthDiff;
		
		if(iSNewHealth < 1)
		{
			// Suicide
			if(g_cvSeekerCanKillSelf.BoolValue)
			{
				ForcePlayerSuicide(iAttacker);
				return;
			}
			else iSNewHealth = 1;
		}
		
		if(iSNewHealth > g_cvSeekerMaxHealth.IntValue)
			iSNewHealth = g_cvSeekerMaxHealth.IntValue;
		
		SetEntityHealth(iAttacker, iSNewHealth); 
	}
}

int GetHPBonus(int iClient, bool bLethal)
{
	if(bLethal)
	{
		if(g_cvWeaponKillHealth[g_iWeapontype[iClient]] != null)
			return g_cvWeaponKillHealth[g_iWeapontype[iClient]].IntValue;
		return g_cvWeaponKillHealthDefault.IntValue;
	}
	
	if(g_cvWeaponHitHealth[g_iWeapontype[iClient]] != null)
		return g_cvWeaponHitHealth[g_iWeapontype[iClient]].IntValue;
	return g_cvWeaponHitHealthDefault.IntValue;
}

void DamageHurt(int client, int victim, int damage, float radius = 0.0, int damagetype = 0, char[] classname = "") {
    int entity = CreateEntityByName("point_hurt");
    if (entity == -1) 
		return;
    SetEntProp(entity, Prop_Data, "m_nDamage", damage);
	
    static char targetname[128];
    GetEntPropString(victim, Prop_Data, "m_iName", targetname, sizeof(targetname));

    DispatchKeyValue(victim, "targetname", "point_hurt");
    DispatchKeyValue(entity, "DamageTarget", "point_hurt");

    if (radius) 
		SetEntPropFloat(entity, Prop_Data, "m_flRadius", radius);
    if (damagetype) 
		SetEntProp(entity, Prop_Data, "m_bitsDamageType", damagetype);
    if (strlen(classname)) 
		DispatchKeyValue(entity, "classname", classname);

    DispatchSpawn(entity);
    ActivateEntity(entity);
    SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
    AcceptEntityInput(entity, "Hurt", client);
    AcceptEntityInput(entity, "Kill");
    DispatchKeyValue(victim, "targetname", targetname);
}
