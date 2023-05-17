_ResetVariables_OnPluginStart()
{
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("spawner_give_item", Event_SpawnerGiveItem);

	HookEvent("mission_lost", Event_Mission_Lost);

	RegConsoleCmd("up", Trigger_MainMenu);
	RegConsoleCmd("buy", Trigger_MainMenu);
	RegConsoleCmd("usepoints", Trigger_MainMenu);
	RegConsoleCmd("csm", Trigger_MainMenu);
	RegConsoleCmd("cp", Trigger_MainMenu);
	RegAdminCmd("reload", Trigger_ReloadPlugin, ADMFLAG_KICK);
	RegConsoleCmd("micro", Trigger_Micro);
	RegConsoleCmd("hidepoints", Trigger_HidePoints);
	RegConsoleCmd("preset", Trigger_LoadPreset);
}

public Action:Trigger_LoadPreset(client, args)
{
	if (GetClientTeam(client) != 2) return Plugin_Handled;
	if (args < 1)
	{
		PrintToChat(client, "%s \x01Syntax: [preset] [value]", INFO);
		return Plugin_Handled;
	}
	decl String:arg[16];
	GetCmdArg(1, arg, sizeof(arg));
	if (StringToInt(arg) == 1 && PhysicalLevel[client] >= GetConVarInt(UnlockPresetLevel[0]))
	{
		PresetViewer[client] = 0;
		LoadPresets(client);
	}
	else if (StringToInt(arg) == 2 && PhysicalLevel[client] >= GetConVarInt(UnlockPresetLevel[1]))
	{
		PresetViewer[client] = 1;
		LoadPresets(client);
	}
	else if (StringToInt(arg) == 3 && PhysicalLevel[client] >= GetConVarInt(UnlockPresetLevel[2]))
	{
		PresetViewer[client] = 2;
		LoadPresets(client);
	}
	else if (StringToInt(arg) == 4 && Preset4[client] == 1)
	{
		PresetViewer[client] = 3;
		LoadPresets(client);
	}
	else if (StringToInt(arg) == 5 && Preset5[client] == 1)
	{
		PresetViewer[client] = 4;
		LoadPresets(client);
	}
	return Plugin_Handled;
}

public Action:Trigger_Micro(client, args)
{
	if (showinfo[client] == 1)
	{
		showinfo[client] = 0;
		PrintToChat(client, "%s \x01Minimal menu and game information will be displayed to you.", INFO);
	}
	else
	{
		showinfo[client] = 1;
		PrintToChat(client, "%s \x01All menu and game information will be displayed to you.", INFO);
	}
	return Plugin_Handled;
}

public Action:Trigger_HidePoints(client, args)
{
	if (showpoints[client] == 1)
	{
		showpoints[client] = 0;
		PrintToChat(client, "%s \x01Point earning will no longer show to you.", INFO);
	}
	else
	{
		showpoints[client] = 1;
		PrintToChat(client, "%s \x01Point earning will now show to you.", INFO);
	}
	return Plugin_Handled;
}

public Action:Trigger_ReloadPlugin(client, args)
{
	ResetEverything();
	PrintToChatAll("\x04Usepoints\x055\x04 reloaded.");
}

public Event_SpawnerGiveItem(Handle:event, const String:name[], bool:dontBroadcast)
{
	new ent = GetEventInt(event, "spawner");
	if (IsValidEdict(ent)) RemoveEdict(ent);
}

public Action:Event_Mission_Lost(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new String:GameTypeCurrent[256];
	GetConVarString(FindConVar("mp_gamemode"), GameTypeCurrent, 128);
	if (StrEqual(GameTypeCurrent, "versus")) return;
	RoundEnd();
}

public Action:Event_PlayerTeam(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(client) || !IsClientInGame(client) || IsFakeClient(client)) return;
	showpoints[client] = true;
	InJump[client] = false;
	BlindAmmoImmune[client] = false;
	PlayerMovementSpeed[client] = 1.0;
	HurtAward[client] = 0.0;
	SurvivorMultiplier[client] = 1.0;

	XPMultiplierTimer[client] = false;
		
	/*		SURVIVOR RESETS		*/
	IncapProtection[client] = 0;
	HealCount[client] = GetConVarInt(HealSupply);
	TempHealCount[client] = GetConVarInt(TempHealSupply);
	GrenadeCount[client] = GetConVarInt(GrenadeSupply);
	SurvivorMultiplier[client] = 1.0;
	SurvivorPoints[client] = 0.0;
	Meds[client] = 0;
	Difference[client] = 0;
	CoveredInBile[client] = false;
	BoomerActionPoints[client] = 0.0;
	BlindAmmo[client] = 0;
	BloatAmmo[client] = 0;
	IceAmmo[client] = 0;
	HealAmmo[client] = 0;
	Scout[client] = false;
	Ensnared[client] = false;
	IncapDisabled[client] = false;
	M60CD[client] = false;

	JockeyRideTime[client] = 0;
		
	SurvivorHeadshotValue[client] = 0;
	SurvivorSpecialValue[client] = 0;
	SurvivorCommonValue[client] = 0;
	SurvivorPistolValue[client] = 0;
	SurvivorMeleeValue[client] = 0;
	SurvivorSmgValue[client] = 0;
	SurvivorShotgunValue[client] = 0;
	SurvivorRifleValue[client] = 0;
	SurvivorSniperValue[client] = 0;
		
	SurvivorHeadshotGoal[client] = GetConVarInt(SurvivorHeadshotStart);
	SurvivorSpecialGoal[client] = GetConVarInt(SurvivorSpecialStart);
	SurvivorCommonGoal[client] = GetConVarInt(SurvivorCommonStart);
	SurvivorPistolGoal[client] = GetConVarInt(SurvivorPistolStart);
	SurvivorMeleeGoal[client] = GetConVarInt(SurvivorMeleeStart);
	SurvivorSmgGoal[client] = GetConVarInt(SurvivorSmgStart);
	SurvivorShotgunGoal[client] = GetConVarInt(SurvivorShotgunStart);
	SurvivorRifleGoal[client] = GetConVarInt(SurvivorRifleStart);
	SurvivorSniperGoal[client] = GetConVarInt(SurvivorSniperStart);
	
	BloatAmmoPistol[client] = false;
	BlindAmmoPistol[client] = false;
	IceAmmoPistol[client] = false;
	HealAmmoPistol[client] = false;
	BloatAmmoAmountPistol[client] = 0;
	BlindAmmoAmountPistol[client] = 0;
	IceAmmoAmountPistol[client] = 0;
	HealAmmoAmountPistol[client] = 0;

	BloatAmmoSmg[client] = false;
	BlindAmmoSmg[client] = false;
	IceAmmoSmg[client] = false;
	HealAmmoSmg[client] = false;
	BloatAmmoAmountSmg[client] = 0;
	BlindAmmoAmountSmg[client] = 0;
	IceAmmoAmountSmg[client] = 0;
	HealAmmoAmountSmg[client] = 0;

	BloatAmmoShotgun[client] = false;
	BlindAmmoShotgun[client] = false;
	IceAmmoShotgun[client] = false;
	HealAmmoShotgun[client] = false;
	BloatAmmoAmountShotgun[client] = 0;
	BlindAmmoAmountShotgun[client] = 0;
	IceAmmoAmountShotgun[client] = 0;
	HealAmmoAmountShotgun[client] = 0;

	BloatAmmoRifle[client] = false;
	BlindAmmoRifle[client] = false;
	IceAmmoRifle[client] = false;
	HealAmmoRifle[client] = false;
	BloatAmmoAmountRifle[client] = 0;
	BlindAmmoAmountRifle[client] = 0;
	IceAmmoAmountRifle[client] = 0;
	HealAmmoAmountRifle[client] = 0;

	BloatAmmoSniper[client] = false;
	BlindAmmoSniper[client] = false;
	IceAmmoSniper[client] = false;
	HealAmmoSniper[client] = false;
	BloatAmmoAmountSniper[client] = 0;
	BlindAmmoAmountSniper[client] = 0;
	IceAmmoAmountSniper[client] = 0;
	HealAmmoAmountSniper[client] = 0;
	
	SurvivorTeamPurchase[client] = false;
	Tier2Cost[client] = GetConVarFloat(Tier2StartCost);
	HealthItemCost[client] = GetConVarFloat(HealthItemStartCost);
	PersonalAbilitiesCost[client] = GetConVarFloat(PersonalAbilitiesStartCost);
	WeaponUpgradeCost[client] = GetConVarFloat(WeaponUpgradeStartCost);
	
	HazmatBoots[client] = 0;
	EyeGoggles[client] = 0;
	GravityBoots[client] = 0;
	RespawnType[client] = 0;
	PlayerMovementSpeed[client] = 1.0;
	RoundKills[client] = 0;
	RoundDamage[client] = 0;

	OnDrugs[client] = false;
	DrugsUsed[client] = 0;
	DrugEffect[client] = false;
	DrugTimer[client] = -1.0;
	JockeyRideBlind[client] = false;

		/*		INFECTED RESETS		*/
	InfectedPoints[client] = 0.0;
	BerserkerKill[client] = false;
	ClassHunter[client] = false;
	ClassSmoker[client] = false;
	ClassBoomer[client] = false;
	ClassJockey[client] = false;
	ClassCharger[client] = false;
	ClassSpitter[client] = false;
	ClassTank[client] = false;
	UpgradeHunter[client] = false;
	UpgradeSmoker[client] = false;
	UpgradeBoomer[client] = false;
	UpgradeJockey[client] = false;
	UpgradeCharger[client] = false;
	UpgradeSpitter[client] = false;
	SuperUpgradeHunter[client] = false;
	SuperUpgradeSmoker[client] = false;
	SuperUpgradeBoomer[client] = false;
	SuperUpgradeJockey[client] = false;
	SuperUpgradeCharger[client] = false;
	SuperUpgradeSpitter[client] = false;
	BloatAmmoImmune[client] = false;
	IceAmmoImmune[client] = false;
	SpitterImmune[client] = false;
	JockeyJumping[client] = false;
	IsSmoking[client] = false;
	RoundHealing[client] = 0;
	SpecialPurchaseValue[client] = GetConVarFloat(SpecialPurchaseStart);
	TankPurchaseValue[client] = GetConVarFloat(TankPurchaseStart);
	UncommonPurchaseValue[client] = GetConVarFloat(UncommonPurchaseStart);
	TeamUpgradesPurchaseValue[client] = GetConVarFloat(TeamUpgradesPurchaseStart);
	PersonalUpgradesPurchaseValue[client] = GetConVarFloat(PersonalUpgradesPurchaseStart);
	
	PersonalUpgrades[client] = 0;
	SpawnAnywhere[client] = false;
	WallOfFire[client] = false;
	SmokerWhipCooldown[client] = false;
	IsRiding[client] = false;
	IsSmoking[client] = false;
	JockeyJumpCooldown[client] = false;
	
	RoundHS[client] = 0;
	RoundSurvivorDamage[client] = 0;
	LocationSaved[client] = false;
	FireTankImmune[client] = false;

	HealAmmoDisabled[client] = false;

	InfectedGhost[client] = true;
	BrokenLegs[client] = false;
	HeavyBySpit[client] = false;

	RoundRescuer[client] = 0;
	
	SetEntityGravity(client, 1.0);
	// We check, to make sure the player didn't switch teams after earning XP.
	// If we don't check and we load, they lose everything when they switch teams, and
	// are put back at what they had last.
	decl String:clientName[256];
	GetClientName(client, clientName, sizeof(clientName));
	if (StrContains(clientName, "`", false) > -1 || StrContains(clientName, "'", false) > -1)
	{
		PrintToChat(client, "%s \x01your name contains \x04` \x01or \x04' \x01characters. Will not save or load data.", ERROR_INFO);
		return;
	}
	if (PhysicalLevel[client] < 1 || PhysicalNextLevel[client] < 1 || 
		InfectedLevel[client] < 1 || InfectedNextLevel[client] < 1)
	{
		LoadData(client);
	}
	if (XPMultiplierTime[client] > 0 && !XPMultiplierTimer[client])
	{
		XPMultiplierTimer[client] = true;
		CreateTimer(1.0, DeductMultiplierTime, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:Event_RoundStart(Handle:event, String:event_name[], bool:dontBroadcast)
{
	RoundStart();
}

public Action:Event_RoundEnd(Handle:event, String:event_name[], bool:dontBroadcast)
{
	RoundEndCount++;
	RoundEnd();
}

RoundStart()
{
	ResetEverything();
}

RoundEnd()
{
	// For the database thing.
	new String:WinnerName[256];
	if (RoundEndCount == 1 || RoundEndCount == 3)
	{
		RoundReset = true;
		if (!IsClientIndexOutOfRange(VipName) && IsClientInGame(VipName) && !IsFakeClient(VipName) && GetClientTeam(VipName) == 2)
		{
			if (IsPlayerAlive(VipName))
			{
				SetEntityRenderMode(VipName, RENDER_NORMAL);
				SetEntityRenderColor(VipName, 255, 255, 255, 255);
				PrintToChatAll("%s \x01The VIP \x03Survived\x01! Survivors earn \x03%d \x01XP!", INFO, VipExperience);
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 2) continue;
					PhysicalExperience[i] += VipExperience;
				}
			}
			else
			{
				PrintToChatAll("%s \x01The VIP \x04Was Killed\x01! Infected earn \x04%d \x01XP!", INFO, VipExperience);
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 3) continue;
					InfectedExperience[i] += VipExperience;
				}
			}
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 3 || HurtAward[i] < 1.0) continue;
			if (HunterHurtAward[i] > 0.0) HunterExperience[i] += RoundToFloor(HunterHurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			if (SmokerHurtAward[i] > 0.0) SmokerExperience[i] += RoundToFloor(SmokerHurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			if (BoomerHurtAward[i] > 0.0) BoomerExperience[i] += RoundToFloor(BoomerHurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			if (JockeyHurtAward[i] > 0.0) JockeyExperience[i] += RoundToFloor(JockeyHurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			if (ChargerHurtAward[i] > 0.0) ChargerExperience[i] += RoundToFloor(ChargerHurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			if (SpitterHurtAward[i] > 0.0) SpitterExperience[i] += RoundToFloor(SpitterHurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			if (TankHurtAward[i] > 0.0) TankExperience[i] += RoundToFloor(TankHurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			if (HurtAward[i] > 0.0) InfectedExperience[i] += RoundToFloor(HurtAward[i] * GetConVarFloat(HurtAwardInfectedXP));
			HunterHurtAward[i] = 0.0;
			SmokerHurtAward[i] = 0.0;
			BoomerHurtAward[i] = 0.0;
			JockeyHurtAward[i] = 0.0;
			ChargerHurtAward[i] = 0.0;
			SpitterHurtAward[i] = 0.0;
			TankHurtAward[i] = 0.0;
			HurtAward[i] = 0.0;
			experience_increase(i, 0);
		}
		decl String:clientName[256];
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i)) continue;
			GetClientName(i, clientName, sizeof(clientName));
			if (StrContains(clientName, "`", false) > -1 || StrContains(clientName, "'", false) > -1)
			{
				PrintToChat(i, "%s \x01your name contains \x04` \x01or \x04' \x01characters. Will not save or load data.", ERROR_INFO);
				continue;
			}
			if (PhysicalLevel[i] > 0 || PhysicalNextLevel[i] > 0 || 
				InfectedLevel[i] > 0 || InfectedNextLevel[i] > 0)
			{
				SaveData(i);
			}
			else continue;
		}
		PrintToChatAll("%s \x04Player Data has been automatically saved.", INFO);
		if (BestKills[0] > MapBestKills && 
			!IsClientIndexOutOfRange(BestKills[1]) && 
			IsClientInGame(BestKills[1]) && 
			!IsFakeClient(BestKills[1]))
		{
			PrintToSurvivors("%s \x04%N \x01broke the \x03Survivor Infected Kills Record\x01: \x04%d \x01for \x03%d \x01Physical XP!", INFO, BestKills[1], BestKills[0], RoundToFloor(BestKills[0] * GetConVarFloat(MapKillsXPEach)));
			PhysicalExperience[BestKills[1]] += RoundToFloor(BestKills[0] * GetConVarFloat(MapKillsXPEach));
			experience_increase(BestKills[1], 0);
			
			MapBestKills = BestKills[0];
			GetClientName(BestKills[1], WinnerName, sizeof(WinnerName));
			MapBestKillsName = WinnerName;
			BestKills[0] = 0;
		}
		
		if (BestSurvivorDamage[0] > MapBestSurvivorDamage && 
			!IsClientIndexOutOfRange(BestSurvivorDamage[1]) && 
			IsClientInGame(BestSurvivorDamage[1]) && 
			!IsFakeClient(BestSurvivorDamage[1]))
		{
			PrintToSurvivors("%s \x04%N \x01broke the \x03Survivor Damage Map Record\x01: \x04%d \x01for \x03%d \x01Physical XP!", INFO, BestSurvivorDamage[1], BestSurvivorDamage[0], RoundToFloor(BestSurvivorDamage[0] * GetConVarFloat(MapSurvivorDamageXPEach)));
			PhysicalExperience[BestSurvivorDamage[1]] += RoundToFloor(BestSurvivorDamage[0] * GetConVarFloat(MapSurvivorDamageXPEach));
			experience_increase(BestSurvivorDamage[1], 0);
			
			MapBestSurvivorDamage = BestSurvivorDamage[0];
			GetClientName(BestSurvivorDamage[1], WinnerName, sizeof(WinnerName));
			MapBestSurvivorDamageName = WinnerName;
			BestSurvivorDamage[0] = 0;
		}
		if (BestSurvivorHS[0] > MapBestSurvivorHS && 
			!IsClientIndexOutOfRange(BestSurvivorHS[1]) && 
			IsClientInGame(BestSurvivorHS[1]) && 
			!IsFakeClient(BestSurvivorHS[1]))
		{
			PrintToSurvivors("%s \x04%N \x01broke the \x03Survivor Headshot Map Record\x01: \x04%d \x01for \x03%d \x01Physical XP!", INFO, BestSurvivorHS[1], BestSurvivorHS[0], RoundToFloor(BestSurvivorHS[0] * GetConVarFloat(MapHSXPEach)));
			PhysicalExperience[BestSurvivorHS[1]] += RoundToFloor(BestSurvivorHS[0] * GetConVarFloat(MapHSXPEach));
			experience_increase(BestSurvivorHS[1], 0);
			
			MapBestSurvivorHS = BestSurvivorHS[0];
			GetClientName(BestSurvivorHS[1], WinnerName, sizeof(WinnerName));
			MapBestSurvivorHSName = WinnerName;
			BestSurvivorHS[0] = 0;
		}
		if (MapBestDamage[0] > MapBestInfectedDamage && 
			!IsClientIndexOutOfRange(MapBestDamage[1]) && 
			IsClientInGame(MapBestDamage[1]) && 
			!IsFakeClient(MapBestDamage[1]))
		{
			PrintToInfected("%s \x04%N \x01broke the \x04Infected Damage Map Record\x01: \x04%d \x01for \x04%d \x01Infected XP!", INFO, MapBestDamage[1], MapBestDamage[0], RoundToFloor(MapBestInfectedDamage * GetConVarFloat(MapDamageXPEach)));
			InfectedExperience[MapBestDamage[1]] += RoundToFloor(MapBestInfectedDamage * GetConVarFloat(MapDamageXPEach));
			experience_increase(MapBestDamage[1], 0);
			
			MapBestInfectedDamage = MapBestDamage[0];
			GetClientName(MapBestDamage[1], WinnerName, sizeof(WinnerName));
			MapBestInfectedDamageName = WinnerName;
			MapBestDamage[0] = 0;
		}
		if (BestHealing[0] > MapBestHealing && 
			!IsClientIndexOutOfRange(BestHealing[1]) && 
			IsClientInGame(BestHealing[1]) && 
			!IsFakeClient(BestHealing[1]))
		{
			PrintToSurvivors("%s \x04%N \x01broke the \x04Medic Healing Record\x01: \x04%d \x01for \x04%d \x01Physical XP!", INFO, BestHealing[1], BestHealing[0], RoundToFloor(MapBestHealing * GetConVarFloat(MapHealingXPEach)));
			PhysicalExperience[BestHealing[1]] += RoundToFloor(MapBestHealing * GetConVarFloat(MapHealingXPEach));
			experience_increase(BestHealing[1], 0);
			
			MapBestHealing = BestHealing[0];
			GetClientName(BestHealing[1], WinnerName, sizeof(WinnerName));
			MapBestHealingName = WinnerName;
			BestHealing[0] = 0;
		}
		if (BestRescuer[0] > MapBestRescuer && 
			IsHuman(BestRescuer[1]))
		{
			PrintToSurvivors("%s \x04%N \x01broke the \x04Survivor Savior Record\x01: \x04%d \x01for \x04%d \x01Physical XP!", INFO, BestRescuer[1], BestRescuer[0], RoundToFloor(MapBestRescuer * GetConVarFloat(MapRescuerXPEach)));
			PhysicalExperience[BestRescuer[1]] += RoundToFloor(MapBestRescuer * GetConVarFloat(MapRescuerXPEach));
			experience_increase(BestRescuer[1], 0);
			
			MapBestRescuer = BestRescuer[0];
			GetClientName(BestRescuer[1], WinnerName, sizeof(WinnerName));
			MapBestRescuerName = WinnerName;
			BestRescuer[0] = 0;
		}
		Save_MapRecords();
		BestKills[0] = 0;
		MapBestDamage[0] = 0;
		BestSurvivorDamage[0] = 0;
		BestSurvivorHS[0] = 0;
		BestHealing[0] = 0;
		BestRescuer[0] = 0;
		ResetEverything();
	}
}

ResetEverything()
{
	/*			SURVIVOR TEAM RESETS		*/
	SurvivorTeamPoints = 0.0;
	
	/*			INFECTED TEAM RESETS		*/
	InfectedTeamPoints = 0.0;
	TankCooldownTime = 0.0;
	TankCount = 0;
	TankLimit = GetConVarInt(TankLimitStart);
	TeamSpecialValue = 0;
	TeamCommonValue = 0;
	TeamSpecialGoal = GetConVarInt(SurvivorTeamSpecialStart);
	TeamCommonGoal = GetConVarInt(SurvivorTeamCommonStart);
	Format(LastUncommon, sizeof(LastUncommon), "none");
	UncommonType = 0;
	UncommonRemaining = 0;
	UncommonPanicEventCount = -1.0;
	
	RescueCalled = false;
	SetConVarInt(FindConVar("sv_disable_glow_faritems"), 0);
	SetConVarInt(FindConVar("z_head_damage_causes_wounds"), 0);
	SetConVarInt(FindConVar("z_use_next_difficulty_damage_factor"), 0);
	MoreCommons = false;
	SetConVarInt(FindConVar("z_common_limit"), GetConVarInt(CommonLimitNormal));
	CommonHeadshots = false;
	SetConVarFloat(FindConVar("z_non_head_damage_factor_multiplier"), 1.0);
	SetConVarInt(FindConVar("z_ghost_delay_min"), GetConVarInt(SpawnTimerStart));
	SetConVarInt(FindConVar("z_ghost_delay_max"), GetConVarInt(SpawnTimerStart));
	SpawnTimer = GetConVarInt(SpawnTimerStart);
	DeepFreezeAmount = 0;
	TankLimit = GetConVarInt(TankLimitStart);
	SteelTongue = false;
	SurvivorRealism = false;
	UncommonCooldown = false;
	UncommonCooldownCount = 0.0;
	DeepFreezeCooldown = false;
	BestKills[0] = 0;
	MapBestDamage[0] = 0;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i)) continue;
		RoundHealing[i] = 0;
		showpoints[i] = true;
		InJump[i] = false;
		BlindAmmoImmune[i] = false;
		PlayerMovementSpeed[i] = 1.0;
		HurtAward[i] = 0.0;
		SurvivorMultiplier[i] = 1.0;
		FireTankImmune[i] = false;

		XPMultiplierTimer[i] = false;
		
		/*		SURVIVOR RESETS		*/
		IncapProtection[i] = 0;
		HealCount[i] = GetConVarInt(HealSupply);
		TempHealCount[i] = GetConVarInt(TempHealSupply);
		GrenadeCount[i] = GetConVarInt(GrenadeSupply);
		SurvivorMultiplier[i] = 1.0;
		SurvivorPoints[i] = 0.0;
		Meds[i] = 0;
		Difference[i] = 0;
		CoveredInBile[i] = false;
		BoomerActionPoints[i] = 0.0;
		BlindAmmo[i] = 0;
		BloatAmmo[i] = 0;
		IceAmmo[i] = 0;
		Scout[i] = false;
		Ensnared[i] = false;
		IncapDisabled[i] = false;
		SurvivorHeadshotValue[i] = 0;
		SurvivorSpecialValue[i] = 0;
		SurvivorCommonValue[i] = 0;
		SurvivorPistolValue[i] = 0;
		SurvivorMeleeValue[i] = 0;
		SurvivorSmgValue[i] = 0;
		SurvivorShotgunValue[i] = 0;
		SurvivorRifleValue[i] = 0;
		SurvivorSniperValue[i] = 0;
		SurvivorHeadshotGoal[i] = GetConVarInt(SurvivorHeadshotStart);
		SurvivorSpecialGoal[i] = GetConVarInt(SurvivorSpecialStart);
		SurvivorCommonGoal[i] = GetConVarInt(SurvivorCommonStart);
		SurvivorPistolGoal[i] = GetConVarInt(SurvivorPistolStart);
		SurvivorMeleeGoal[i] = GetConVarInt(SurvivorMeleeStart);
		SurvivorSmgGoal[i] = GetConVarInt(SurvivorSmgStart);
		SurvivorShotgunGoal[i] = GetConVarInt(SurvivorShotgunStart);
		SurvivorRifleGoal[i] = GetConVarInt(SurvivorRifleStart);
		SurvivorSniperGoal[i] = GetConVarInt(SurvivorSniperStart);
		BloatAmmoPistol[i] = false;
		BlindAmmoPistol[i] = false;
		IceAmmoPistol[i] = false;
		HealAmmoPistol[i] = false;
		BloatAmmoAmountPistol[i] = 0;
		BlindAmmoAmountPistol[i] = 0;
		IceAmmoAmountPistol[i] = 0;
		HealAmmoAmountPistol[i] = 0;

		BloatAmmoSmg[i] = false;
		BlindAmmoSmg[i] = false;
		IceAmmoSmg[i] = false;
		HealAmmoSmg[i] = false;
		BloatAmmoAmountSmg[i] = 0;
		BlindAmmoAmountSmg[i] = 0;
		IceAmmoAmountSmg[i] = 0;
		HealAmmoAmountSmg[i] = 0;

		BloatAmmoShotgun[i] = false;
		BlindAmmoShotgun[i] = false;
		IceAmmoShotgun[i] = false;
		HealAmmoShotgun[i] = false;
		BloatAmmoAmountShotgun[i] = 0;
		BlindAmmoAmountShotgun[i] = 0;
		IceAmmoAmountShotgun[i] = 0;
		HealAmmoAmountShotgun[i] = 0;

		BloatAmmoRifle[i] = false;
		BlindAmmoRifle[i] = false;
		IceAmmoRifle[i] = false;
		HealAmmoRifle[i] = false;
		BloatAmmoAmountRifle[i] = 0;
		BlindAmmoAmountRifle[i] = 0;
		IceAmmoAmountRifle[i] = 0;
		HealAmmoAmountRifle[i] = 0;

		BloatAmmoSniper[i] = false;
		BlindAmmoSniper[i] = false;
		IceAmmoSniper[i] = false;
		HealAmmoSniper[i] = false;
		BloatAmmoAmountSniper[i] = 0;
		BlindAmmoAmountSniper[i] = 0;
		IceAmmoAmountSniper[i] = 0;
		HealAmmoAmountSniper[i] = 0;
		SurvivorTeamPurchase[i] = false;
		Tier2Cost[i] = GetConVarFloat(Tier2StartCost);
		HealthItemCost[i] = GetConVarFloat(HealthItemStartCost);
		PersonalAbilitiesCost[i] = GetConVarFloat(PersonalAbilitiesStartCost);
		WeaponUpgradeCost[i] = GetConVarFloat(WeaponUpgradeStartCost);
		HazmatBoots[i] = 0;
		EyeGoggles[i] = 0;
		GravityBoots[i] = 0;
		RespawnType[i] = 0;
		PlayerMovementSpeed[i] = 1.0;
		RoundKills[i] = 0;
		RoundDamage[i] = 0;
		RoundSurvivorDamage[i] = 0;
		RoundHS[i] = 0;

		M60CD[i] = false;

		OnDrugs[i] = false;
		DrugsUsed[i] = 0;
		DrugEffect[i] = false;
		DrugTimer[i] = -1.0;

		JockeyRideBlind[i] = false;

		HealAmmoDisabled[i] = false;

		BrokenLegs[i] = false;
		HeavyBySpit[i] = false;
		
		/*		INFECTED RESETS		*/
		InfectedPoints[i] = 0.0;
		BerserkerKill[i] = false;
		ClassHunter[i] = false;
		ClassSmoker[i] = false;
		ClassBoomer[i] = false;
		ClassJockey[i] = false;
		ClassCharger[i] = false;
		ClassSpitter[i] = false;
		ClassTank[i] = false;
		UpgradeHunter[i] = false;
		UpgradeSmoker[i] = false;
		UpgradeBoomer[i] = false;
		UpgradeJockey[i] = false;
		UpgradeCharger[i] = false;
		UpgradeSpitter[i] = false;
		SuperUpgradeHunter[i] = false;
		SuperUpgradeSmoker[i] = false;
		SuperUpgradeBoomer[i] = false;
		SuperUpgradeJockey[i] = false;
		SuperUpgradeCharger[i] = false;
		SuperUpgradeSpitter[i] = false;
		BloatAmmoImmune[i] = false;
		IceAmmoImmune[i] = false;
		SpitterImmune[i] = false;
		JockeyJumping[i] = false;
		IsSmoking[i] = false;
		SpecialPurchaseValue[i] = GetConVarFloat(SpecialPurchaseStart);
		TankPurchaseValue[i] = GetConVarFloat(TankPurchaseStart);
		UncommonPurchaseValue[i] = GetConVarFloat(UncommonPurchaseStart);
		TeamUpgradesPurchaseValue[i] = GetConVarFloat(TeamUpgradesPurchaseStart);
		PersonalUpgradesPurchaseValue[i] = GetConVarFloat(PersonalUpgradesPurchaseStart);
		
		PersonalUpgrades[i] = 0;
		SpawnAnywhere[i] = false;
		WallOfFire[i] = false;
		SmokerWhipCooldown[i] = false;
		
		IsRiding[i] = false;
		IsSmoking[i] = false;
		JockeyJumpCooldown[i] = false;
		BurnDamageImmune[i] = false;
		
		LocationSaved[i] = false;

		JockeyRideTime[i] = 0;
		InfectedGhost[i] = true;

		RoundRescuer[i] = 0;
		
		SetEntityGravity(i, 1.0);
	}
	PrintToChatAll("%s Data's Refreshed!", INFO);
	CreateTimer(10.0, AttemptStartTimers);
	//PrintToChatAll("%s \x01Round Has Ended. Calculating Totals!", INFO);
}