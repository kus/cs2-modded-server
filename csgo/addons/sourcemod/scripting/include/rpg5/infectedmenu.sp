public Handle:Infected_MainMenu (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Infected Main Menu");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], InfectedPoints[client], InfectedTeamPoints);
	DrawPanelText(menu, text);
	
	Format(text, sizeof(text), "Spend Points");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Spend your (team) points earned in-game");

	Format(text, sizeof(text), "Status Screen");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "View experience, and stuff like that");
	
	Format(text, sizeof(text), "Challenge Board");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "View The Server Challenge Board");

	if (showinfo[client] == 1) DrawPanelText(menu, "Spend Sky Points bought on our site, on anything!");
	Format(text, sizeof(text), "In-Game Store");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Spend Sky Points you've earned through donating!");
	DrawPanelItem(menu, "End Your Life");
	return menu;
}

public Infected_MainMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Infected_BuyMenu(client), client, Infected_BuyMenu_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				SendPanelToClient(Infected_Stats(client), client, Infected_Stats_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				SendPanelToClient(Challenge_Board(client), client, Challenge_Board_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				SendPanelToClient(Sky_Store(client), client, Sky_Store_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				if (GetClientTeam(client) != 3) return;
				new Class = GetEntProp(client, Prop_Send, "m_zombieClass");
				if (Class != ZOMBIECLASS_TANK) ForcePlayerSuicide(client);
			}
			default:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Infected_Stats (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Statistics Page", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Hunter:     %d /%d xp | Lv.%d", HunterExperience[client], HunterNextLevel[client], HunterLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Smoker:    %d /%d xp | Lv.%d", SmokerExperience[client], SmokerNextLevel[client], SmokerLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Boomer:    %d /%d xp | Lv.%d", BoomerExperience[client], BoomerNextLevel[client], BoomerLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Jockey:     %d /%d xp | Lv.%d", JockeyExperience[client], JockeyNextLevel[client], JockeyLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Charger:    %d /%d xp | Lv.%d", ChargerExperience[client], ChargerNextLevel[client], ChargerLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Spitter:     %d /%d xp | Lv.%d", SpitterExperience[client], SpitterNextLevel[client], SpitterLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Tank:       %d /%d xp | Lv.%d", TankExperience[client], TankNextLevel[client], TankLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Infected:   %d /%d xp | Lv.%d", InfectedExperience[client], InfectedNextLevel[client], InfectedLevel[client]);
	DrawPanelText(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Infected_Stats_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Infected_BuyMenu (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Infected Buy Menu");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], InfectedPoints[client], InfectedTeamPoints);
	DrawPanelText(menu, text);
	
	Format(text, sizeof(text), "Change Class");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Change your class if you're alive or in ghost");
	
	Format(text, sizeof(text), "Uncommon Infected");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Queue or Drop uncommon infected on players");

	Format(text, sizeof(text), "Team Upgrades");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Make your team more powerful");
	
	Format(text, sizeof(text), "Your Upgrades");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Make yourself more powerful");
	
	//DrawPanelItem(menu, "Suicide");

	return menu;
}

public Infected_BuyMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Infected_ClassChangeMenu(client), client, Infected_ClassChangeMenu_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				SendPanelToClient(Infected_CommonDrop(client), client, Infected_CommonDrop_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				SendPanelToClient(Infected_TeamUpgrades(client), client, Infected_TeamUpgrades_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (PersonalUpgrades[client] < 12) SendPanelToClient(Infected_Personal1(client), client, Infected_Personal1_Init, MENU_TIME_FOREVER);
				else
				{
					PrintToChat(client, "%s \x01You have all of the personal upgrades.", ERROR_INFO);
					return;
				}
			}
			/*case 5:
			{
				if (GetClientTeam(client) != 3) return;
				decl zombieclass;
				zombieclass = GetEntProp(client, Prop_Send, "m_zombieClass");
				if (zombieclass == ZOMBIECLASS_TANK) return;
				ForcePlayerSuicide(client);
			}*/
			default:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Infected_ClassChangeMenu (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Change Class Menu");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], InfectedPoints[client], InfectedTeamPoints);
	DrawPanelText(menu, text);
	
	Format(text, sizeof(text), "Hunter");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Smoker");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Boomer");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Jockey");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Charger");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Spitter");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Special Purchase: %3.3f Point(s).", SpecialPurchaseValue[client]);
	DrawPanelText(menu, text);
	
	Format(text, sizeof(text), "Tank");
	DrawPanelItem(menu, text);
	
	if (TankCooldownTime == 0.0) Format(text, sizeof(text), "Tanks Alive: %d of %d", TankCount, TankLimit);
	else if (TankCooldownTime == -1.0) Format(text, sizeof(text), "Tank is restricted %d of %d", TankCount, TankLimit);
	else Format(text, sizeof(text), "Tank unavailable %3.1f cooldown remaining", GetConVarFloat(TankCooldown) - TankCooldownTime);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Tank Purchase: %3.3f Point(s).", TankPurchaseValue[client]);
	DrawPanelText(menu, text);
	
	return menu;
}

public Infected_ClassChangeMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (ClassCharger[client] && !IsPlayerGhost(client) && IsPlayerAlive(client)) return;
				if (!IsPlayerAlive(client) || (ClassHunter[client] && !IsPlayerGhost(client))) return;
				ItemName[client] = "Hunter";
				PurchaseItem[client] = 1;
				InfectedPurchaseFunc(client);
			}
			case 2:
			{
				if (ClassCharger[client] && !IsPlayerGhost(client) && IsPlayerAlive(client)) return;
				if (!IsPlayerAlive(client) || (ClassSmoker[client] && !IsPlayerGhost(client))) return;
				ItemName[client] = "Smoker";
				PurchaseItem[client] = 1;
				InfectedPurchaseFunc(client);
			}
			case 3:
			{
				if (ClassCharger[client] && !IsPlayerGhost(client) && IsPlayerAlive(client)) return;
				if (!IsPlayerAlive(client) || (ClassBoomer[client] && !IsPlayerGhost(client))) return;
				ItemName[client] = "Boomer";
				PurchaseItem[client] = 1;
				InfectedPurchaseFunc(client);
			}
			case 4:
			{
				if (ClassCharger[client] && !IsPlayerGhost(client) && IsPlayerAlive(client)) return;
				if (!IsPlayerAlive(client) || (ClassJockey[client] && !IsPlayerGhost(client))) return;
				ItemName[client] = "Jockey";
				PurchaseItem[client] = 1;
				InfectedPurchaseFunc(client);
			}
			case 5:
			{
				if (ClassCharger[client] && !IsPlayerGhost(client) && IsPlayerAlive(client)) return;
				if (!IsPlayerAlive(client) || (ClassCharger[client] && !IsPlayerGhost(client))) return;
				ItemName[client] = "Charger";
				PurchaseItem[client] = 1;
				InfectedPurchaseFunc(client);
			}
			case 6:
			{
				if (ClassCharger[client] && !IsPlayerGhost(client) && IsPlayerAlive(client)) return;
				if (!IsPlayerAlive(client) || (ClassSpitter[client] && !IsPlayerGhost(client))) return;
				ItemName[client] = "Spitter";
				PurchaseItem[client] = 1;
				InfectedPurchaseFunc(client);
			}
			case 7:
			{
				if (ClassCharger[client] && !IsPlayerGhost(client) && IsPlayerAlive(client)) return;
				if (!IsPlayerAlive(client)) return;
				if (TankCooldownTime != 0.0 || TankCount >= TankLimit) return;
				ItemName[client] = "Tank";
				PurchaseItem[client] = 2;
				InfectedPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Infected_CommonDrop (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Common Drop Menu");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], InfectedPoints[client], InfectedTeamPoints);
	DrawPanelText(menu, text);
	
	Format(text, sizeof(text), "Brown Plop Drop");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Jimmy Drop");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Riot Drop");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Road Crew Drop");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Summon MudMen");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Summon Jimmy Gibbs");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Summon Riot Cops");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Summon Road Crew");
	DrawPanelItem(menu, text);
	if (UncommonPanicEventCount == -1.0) Format(text, sizeof(text), "Uncommon Panic Event");
	else Format(text, sizeof(text), "Uncommon Panic Event (%3.1f sec(s) Cooldown)", (GetConVarFloat(UncommonPanicEventTimer) - UncommonPanicEventCount));
	DrawPanelItem(menu, text);
	if (UncommonRemaining < 1 && !UncommonCooldown)
	{
		Format(text, sizeof(text), "%d Uncommons Available to drop!", GetConVarInt(UncommonDropAmount));
		DrawPanelText(menu, text);
		Format(text, sizeof(text), "%d Uncommons Available to be summoned!", GetConVarInt(UncommonQueueAmount));
		DrawPanelText(menu, text);
	}
	else if (UncommonRemaining < 1 && UncommonCooldown)
	{
		Format(text, sizeof(text), "%3.1f second(s) until uncommons can be purchased.", GetConVarFloat(UncommonCooldownTime) - UncommonCooldownCount);
		DrawPanelText(menu, text);
	}
	else
	{
		Format(text, sizeof(text), "%d Uncommons are still on their way...", UncommonRemaining);
		DrawPanelText(menu, text);
	}
	Format(text, sizeof(text), "Uncommon Infected Cost: %3.3f Point(s).", UncommonPurchaseValue[client]);
	DrawPanelText(menu, text);
	
	return menu;
}

public Infected_CommonDrop_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "mudmen_drop";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 2:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "jimmy_drop";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 3:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "riot_drop";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 4:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "road_drop";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 5:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "mudmen_queue";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 6:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "jimmy_queue";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 7:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "riot_queue";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 8:
			{
				if (UncommonRemaining > 0 || UncommonCooldown) return;
				ItemName[client] = "road_queue";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			case 9:
			{
				if (UncommonRemaining > 0 || UncommonCooldown || UncommonPanicEventCount != -1.0) return;
				ItemName[client] = "uncommon_event";
				PurchaseItem[client] = 3;
				InfectedPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Infected_TeamUpgrades (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Team Upgrades Menu");
	new String:Pct[32];
	Format(Pct, sizeof(Pct), "%");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], InfectedPoints[client], InfectedTeamPoints);
	DrawPanelText(menu, text);
	
	if (!SteelTongue) Format(text, sizeof(text), "Steel Tongue");
	else Format(text, sizeof(text), "Steel Tongue (Purchased)");
	DrawPanelItem(menu, text);
	if (TankLimit < GetConVarInt(TankLimitMax)) Format(text, sizeof(text), "Tank Limit");
	else Format(text, sizeof(text), "Tank Limit (Max. Amount Reached)");
	DrawPanelItem(menu, text);
	if (DeepFreezeAmount < GetConVarInt(DeepFreezeMax)) Format(text, sizeof(text), "Deep Freeze %d%s of %d%s", DeepFreezeAmount, Pct, GetConVarInt(DeepFreezeMax), Pct);
	else Format(text, sizeof(text), "Deep Freeze (%d%s Limit Reached)", DeepFreezeAmount, Pct);
	DrawPanelItem(menu, text);
	if (SpawnTimer > GetConVarInt(SpawnTimerMin)) Format(text, sizeof(text), "Spawn Timer %d Seconds (%d minimum)", SpawnTimer, GetConVarInt(SpawnTimerMin));
	else Format(text, sizeof(text), "Spawn Timer (%d Second(s) Minimum Reached)", SpawnTimer);
	DrawPanelItem(menu, text);
	if (!CommonHeadshots) Format(text, sizeof(text), "Common Headshots!");
	else Format(text, sizeof(text), "Common Headshots! (Purchased)");
	DrawPanelItem(menu, text);
	if (!MoreCommons) Format(text, sizeof(text), "More Commons!");
	else Format(text, sizeof(text), "More Commons! (Purchased)");
	DrawPanelItem(menu, text);
	if (!SurvivorRealism) Format(text, sizeof(text), "Survivor Realism-ish");
	else Format(text, sizeof(text), "Survivor Realism (Purchased)");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Team Upgrades Cost: %3.3f Point(s).", TeamUpgradesPurchaseValue[client]);
	DrawPanelText(menu, text);
	
	return menu;
}

public Infected_TeamUpgrades_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (SteelTongue) return;
				ItemName[client] = "steel_tongue";
				PurchaseItem[client] = 4;
				InfectedPurchaseFunc(client);
			}
			case 2:
			{
				if (TankLimit >= GetConVarInt(TankLimitMax)) return;
				ItemName[client] = "tank_limit";
				PurchaseItem[client] = 4;
				InfectedPurchaseFunc(client);
			}
			case 3:
			{
				if (DeepFreezeAmount >= GetConVarInt(DeepFreezeMax)) return;
				ItemName[client] = "deep_freeze";
				PurchaseItem[client] = 4;
				InfectedPurchaseFunc(client);
			}
			case 4:
			{
				if (SpawnTimer <= GetConVarInt(SpawnTimerMin)) return;
				ItemName[client] = "spawn_timer";
				PurchaseItem[client] = 4;
				InfectedPurchaseFunc(client);
			}
			case 5:
			{
				if (CommonHeadshots) return;
				ItemName[client] = "common_headshots";
				PurchaseItem[client] = 4;
				InfectedPurchaseFunc(client);
			}
			case 6:
			{
				if (MoreCommons) return;
				ItemName[client] = "more_commons";
				PurchaseItem[client] = 4;
				InfectedPurchaseFunc(client);
			}
			case 7:
			{
				if (SurvivorRealism) return;
				ItemName[client] = "survivor_realism";
				PurchaseItem[client] = 4;
				InfectedPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Infected_Personal1 (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Personal Upgrades Menu");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], InfectedPoints[client], InfectedTeamPoints);
	DrawPanelText(menu, text);
	
	if (!UpgradeHunter[client] && HunterLevel[client] < GetConVarInt(InfectedTier2Level)) Format(text, sizeof(text), "Hunter -> Tier 2");
	else if (!SuperUpgradeHunter[client] && HunterLevel[client] < GetConVarInt(InfectedTier3Level)) Format(text, sizeof(text), "Hunter -> Tier 3");
	else Format(text, sizeof(text), "Hunter (Tier 3 Upgraded)");
	DrawPanelItem(menu, text);
	if (!UpgradeSmoker[client] && SmokerLevel[client] < GetConVarInt(InfectedTier2Level)) Format(text, sizeof(text), "Smoker -> Tier 2");
	else if (!SuperUpgradeSmoker[client] && SmokerLevel[client] < GetConVarInt(InfectedTier3Level)) Format(text, sizeof(text), "Smoker -> Tier 3");
	else Format(text, sizeof(text), "Smoker (Tier 3 Upgraded)");
	DrawPanelItem(menu, text);
	if (!UpgradeBoomer[client] && BoomerLevel[client] < GetConVarInt(InfectedTier2Level)) Format(text, sizeof(text), "Boomer -> Tier 2");
	else if (!SuperUpgradeBoomer[client] && BoomerLevel[client] < GetConVarInt(InfectedTier3Level)) Format(text, sizeof(text), "Boomer -> Tier 3");
	else Format(text, sizeof(text), "Boomer (Tier 3 Upgraded)");
	DrawPanelItem(menu, text);
	if (!UpgradeJockey[client] && JockeyLevel[client] < GetConVarInt(InfectedTier2Level)) Format(text, sizeof(text), "Jockey -> Tier 2");
	else if (!SuperUpgradeJockey[client] && JockeyLevel[client] < GetConVarInt(InfectedTier3Level)) Format(text, sizeof(text), "Jockey -> Tier 3");
	else Format(text, sizeof(text), "Jockey (Tier 3 Upgraded)");
	DrawPanelItem(menu, text);
	if (!UpgradeCharger[client] && ChargerLevel[client] < GetConVarInt(InfectedTier2Level)) Format(text, sizeof(text), "Charger -> Tier 2");
	else if (!SuperUpgradeCharger[client] && ChargerLevel[client] < GetConVarInt(InfectedTier3Level)) Format(text, sizeof(text), "Charger -> Tier 3");
	else Format(text, sizeof(text), "Charger (Tier 3 Upgraded)");
	DrawPanelItem(menu, text);
	if (!UpgradeSpitter[client] && SpitterLevel[client] < GetConVarInt(InfectedTier2Level)) Format(text, sizeof(text), "Spitter -> Tier 2");
	else if (!SuperUpgradeSpitter[client] && SpitterLevel[client] < GetConVarInt(InfectedTier3Level)) Format(text, sizeof(text), "Spitter -> Tier 3");
	else Format(text, sizeof(text), "Spitter (Tier 3 Upgraded)");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Personal Upgrade Cost: %3.3f Point(s).", PersonalUpgradesPurchaseValue[client]);
	DrawPanelText(menu, text);
	
	return menu;
}

public Infected_Personal1_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (UpgradeHunter[client] && SuperUpgradeHunter[client] || HunterLevel[client] >= GetConVarInt(InfectedTier3Level)) return;
				if (UpgradeHunter[client] || HunterLevel[client] >= GetConVarInt(InfectedTier2Level)) ItemName[client] = "hunter_tier3";
				else ItemName[client] = "hunter_tier2";
				PurchaseItem[client] = 5;
				InfectedPurchaseFunc(client);
			}
			case 2:
			{
				if (UpgradeSmoker[client] && SuperUpgradeSmoker[client] || SmokerLevel[client] >= GetConVarInt(InfectedTier3Level)) return;
				if (UpgradeSmoker[client] || SmokerLevel[client] >= GetConVarInt(InfectedTier2Level)) ItemName[client] = "smoker_tier3";
				else ItemName[client] = "smoker_tier2";
				PurchaseItem[client] = 5;
				InfectedPurchaseFunc(client);
			}
			case 3:
			{
				if (UpgradeBoomer[client] && SuperUpgradeBoomer[client] || BoomerLevel[client] >= GetConVarInt(InfectedTier3Level)) return;
				if (UpgradeBoomer[client] || BoomerLevel[client] >= GetConVarInt(InfectedTier2Level)) ItemName[client] = "boomer_tier3";
				else ItemName[client] = "boomer_tier2";
				PurchaseItem[client] = 5;
				InfectedPurchaseFunc(client);
			}
			case 4:
			{
				if (UpgradeJockey[client] && SuperUpgradeJockey[client] || JockeyLevel[client] >= GetConVarInt(InfectedTier3Level)) return;
				if (UpgradeJockey[client] || JockeyLevel[client] >= GetConVarInt(InfectedTier2Level)) ItemName[client] = "jockey_tier3";
				else ItemName[client] = "jockey_tier2";
				PurchaseItem[client] = 5;
				InfectedPurchaseFunc(client);
			}
			case 5:
			{
				if (UpgradeCharger[client] && SuperUpgradeCharger[client] || ChargerLevel[client] >= GetConVarInt(InfectedTier3Level)) return;
				if (UpgradeCharger[client] || ChargerLevel[client] >= GetConVarInt(InfectedTier2Level)) ItemName[client] = "charger_tier3";
				else ItemName[client] = "charger_tier2";
				PurchaseItem[client] = 5;
				InfectedPurchaseFunc(client);
			}
			case 6:
			{
				if (UpgradeSpitter[client] && SuperUpgradeSpitter[client] || SpitterLevel[client] >= GetConVarInt(InfectedTier3Level)) return;
				if (UpgradeSpitter[client] || SpitterLevel[client] >= GetConVarInt(InfectedTier2Level)) ItemName[client] = "spitter_tier3";
				else ItemName[client] = "spitter_tier2";
				PurchaseItem[client] = 5;
				InfectedPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}