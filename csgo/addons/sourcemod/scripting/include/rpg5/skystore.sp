public Handle:Sky_Store (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Sky Store\nYou have %d Sky Points", SkyPoints[client]);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Buy Experience");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Buy Items/Abilities");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Buy XP Multiplier - %3.1f minutes, %3.1fx Multiplier (%d cost)", GetConVarFloat(BuyXPMultiplierAmount), GetConVarFloat(BuyXPMultiplier), GetConVarInt(BuyXPMultiplierCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "May stack XP Multiplier time (forever!)");
	DrawPanelText(menu, text);
	if (XPMultiplierTime[client] > 0)
	{
		new seconds = XPMultiplierTime[client];
		new minutes = 0;
		while (seconds >= 60)
		{
			minutes++;
			seconds -= 60;
		}
		Format(text, sizeof(text), "Multiplier Time Remaining: %d min(s), %d sec(s)", minutes, seconds);
		DrawPanelText(menu, text);
	}
	Format(text, sizeof(text), "How to buy sky points:");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "PayPal to Mikel.toth@gmail.com (include your steam_id)");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "20 SP - 1$\n100 SP + 1month Reserve Slot per 5$");
	DrawPanelText(menu, text);

	return menu;
}

public Sky_Store_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Sky_StoreXPSelect(client), client, Sky_StoreXPSelect_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				SendPanelToClient(Sky_StoreItems(client), client, Sky_StoreItems_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (SkyPoints[client] < GetConVarInt(BuyXPMultiplierCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyXPMultiplierCost) - SkyPoints[client]));
					return;
				}
				XPMultiplierTime[client] += RoundToFloor(GetConVarFloat(BuyXPMultiplierAmount) * 60.0);
				if (!XPMultiplierTimer[client])
				{
					XPMultiplierTimer[client] = true;
					CreateTimer(1.0, DeductMultiplierTime, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				SkyPoints[client] -= GetConVarInt(BuyXPMultiplierCost);
				PrintToChat(client, "%s \x01%3.1f Time remaining of \x04%3.1fx \x01XP Multiplier.", XPMultiplierTime[client], GetConVarFloat(BuyXPMultiplier));
				SaveSkyPoints(client);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else if (GetClientTeam(client) == 3) SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Sky_StoreXPSelect (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Sky Store\nYou have %d Sky Points", SkyPoints[client]);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Buy Survivor Experience");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Buy Infected Experience");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Buy XP in pre-set chunks above");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Buy Survivor Next Level XP");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Buy Infected Next Level XP");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Buy XP needed for the next lv. in a category.");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "15% cheaper than pre-set costs, when buying in bulk!");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "\nHow to buy sky points:");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "PayPal to Mikel.toth@gmail.com (include your steam_id)");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "20 SP - 1$\n100 SP + 1month Reserve Slot per 5$");
	DrawPanelText(menu, text);

	return menu;
}

public Sky_StoreXPSelect_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Sky_StoreSurvNormXP(client), client, Sky_StoreSurvNormXP_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				SendPanelToClient(Sky_StoreInfeNormXP(client), client, Sky_StoreInfeNormXP_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				SendPanelToClient(Sky_StoreSurvNextXP(client), client, Sky_StoreSurvNextXP_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				SendPanelToClient(Sky_StoreInfeNextXP(client), client, Sky_StoreInfeNextXP_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else if (GetClientTeam(client) == 3) SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Sky_StoreSurvNormXP (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Sky Store\nYou have %d Sky Points", SkyPoints[client]);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Pistol (%d XP) (%d Cost)", GetConVarInt(BuyPistolXP), GetConVarInt(BuyPistolXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Melee (%d XP) (%d Cost)", GetConVarInt(BuyMeleeXP), GetConVarInt(BuyMeleeXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Uzi (%d XP) (%d Cost)", GetConVarInt(BuyUziXP), GetConVarInt(BuyUziXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Shotgun (%d XP) (%d Cost)", GetConVarInt(BuyShotgunXP), GetConVarInt(BuyShotgunXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Sniper (%d XP) (%d Cost)", GetConVarInt(BuySniperXP), GetConVarInt(BuySniperXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Rifle (%d XP) (%d Cost)", GetConVarInt(BuyRifleXP), GetConVarInt(BuyRifleXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Grenade (%d XP) (%d Cost)", GetConVarInt(BuyGrenadeXP), GetConVarInt(BuyGrenadeXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Item (%d XP) (%d Cost)", GetConVarInt(BuyItemXP), GetConVarInt(BuyItemXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Physical (%d XP) (%d Cost)", GetConVarInt(BuyPhysicalXP), GetConVarInt(BuyPhysicalXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "How to buy sky points:");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "PayPal to Mikel.toth@gmail.com (include your steam_id)");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "20 SP for each 1$\nOR\n100 SP + 1month Reserve Slot for each 5$");
	DrawPanelText(menu, text);

	return menu;
}

public Sky_StoreSurvNormXP_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (SkyPoints[client] < GetConVarInt(BuyPistolXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyPistolXPCost) - SkyPoints[client]));
					return;
				}
				PistolExperience[client] += GetConVarInt(BuyPistolXP);
				SkyPoints[client] -= GetConVarInt(BuyPistolXPCost);
				PrintToChat(client, "%s \x01%d Pistol XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyPistolXP));
				SaveSkyPoints(client);
			}
			case 2:
			{
				if (SkyPoints[client] < GetConVarInt(BuyMeleeXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyMeleeXPCost) - SkyPoints[client]));
					return;
				}
				MeleeExperience[client] += GetConVarInt(BuyMeleeXP);
				SkyPoints[client] -= GetConVarInt(BuyMeleeXPCost);
				PrintToChat(client, "%s \x01%d Melee XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyMeleeXP));
				SaveSkyPoints(client);
			}
			case 3:
			{
				if (SkyPoints[client] < GetConVarInt(BuyUziXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyUziXPCost) - SkyPoints[client]));
					return;
				}
				UziExperience[client] += GetConVarInt(BuyUziXP);
				SkyPoints[client] -= GetConVarInt(BuyUziXPCost);
				PrintToChat(client, "%s \x01%d Uzi XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyUziXP));
				SaveSkyPoints(client);
			}
			case 4:
			{
				if (SkyPoints[client] < GetConVarInt(BuyShotgunXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyShotgunXPCost) - SkyPoints[client]));
					return;
				}
				ShotgunExperience[client] += GetConVarInt(BuyShotgunXP);
				SkyPoints[client] -= GetConVarInt(BuyShotgunXPCost);
				PrintToChat(client, "%s \x01%d Shotgun XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyShotgunXP));
				SaveSkyPoints(client);
			}
			case 5:
			{
				if (SkyPoints[client] < GetConVarInt(BuySniperXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuySniperXPCost) - SkyPoints[client]));
					return;
				}
				SniperExperience[client] += GetConVarInt(BuySniperXP);
				SkyPoints[client] -= GetConVarInt(BuySniperXPCost);
				PrintToChat(client, "%s \x01%d Sniper XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuySniperXP));
				SaveSkyPoints(client);
			}
			case 6:
			{
				if (SkyPoints[client] < GetConVarInt(BuyRifleXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyRifleXPCost) - SkyPoints[client]));
					return;
				}
				RifleExperience[client] += GetConVarInt(BuyRifleXP);
				SkyPoints[client] -= GetConVarInt(BuyRifleXPCost);
				PrintToChat(client, "%s \x01%d Rifle XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyRifleXP));
				SaveSkyPoints(client);
			}
			case 7:
			{
				if (SkyPoints[client] < GetConVarInt(BuyGrenadeXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyGrenadeXPCost) - SkyPoints[client]));
					return;
				}
				GrenadeExperience[client] += GetConVarInt(BuyGrenadeXP);
				SkyPoints[client] -= GetConVarInt(BuyGrenadeXPCost);
				PrintToChat(client, "%s \x01%d Grenade XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyGrenadeXP));
				SaveSkyPoints(client);
			}
			case 8:
			{
				if (SkyPoints[client] < GetConVarInt(BuyItemXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyItemXPCost) - SkyPoints[client]));
					return;
				}
				ItemExperience[client] += GetConVarInt(BuyItemXP);
				SkyPoints[client] -= GetConVarInt(BuyItemXPCost);
				PrintToChat(client, "%s \x01%d Item XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyItemXP));
				SaveSkyPoints(client);
			}
			case 9:
			{
				if (SkyPoints[client] < GetConVarInt(BuyPhysicalXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyPhysicalXPCost) - SkyPoints[client]));
					return;
				}
				PhysicalExperience[client] += GetConVarInt(BuyPhysicalXP);
				SkyPoints[client] -= GetConVarInt(BuyPhysicalXPCost);
				PrintToChat(client, "%s \x01%d Physical XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyPhysicalXP));
				SaveSkyPoints(client);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else if (GetClientTeam(client) == 3) SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

// Infected Store
public Handle:Sky_StoreInfeNormXP (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Sky Store\nYou have %d Sky Points", SkyPoints[client]);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Hunter (%d XP) (%d Cost)", GetConVarInt(BuyHunterXP), GetConVarInt(BuyHunterXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Smoker (%d XP) (%d Cost)", GetConVarInt(BuySmokerXP), GetConVarInt(BuySmokerXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Boomer (%d XP) (%d Cost)", GetConVarInt(BuyBoomerXP), GetConVarInt(BuyBoomerXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Jockey (%d XP) (%d Cost)", GetConVarInt(BuyJockeyXP), GetConVarInt(BuyJockeyXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Charger (%d XP) (%d Cost)", GetConVarInt(BuyChargerXP), GetConVarInt(BuyChargerXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Spitter (%d XP) (%d Cost)", GetConVarInt(BuySpitterXP), GetConVarInt(BuySpitterXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Tank (%d XP) (%d Cost)", GetConVarInt(BuyTankXP), GetConVarInt(BuyTankXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Infected (%d XP) (%d Cost)", GetConVarInt(BuyInfectedXP), GetConVarInt(BuyInfectedXPCost));
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "How to buy sky points:");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "PayPal to Mikel.toth@gmail.com (include your steam_id)");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "20 SP for each 1$\nOR\n100 SP + 1month Reserve Slot for each 5$");
	DrawPanelText(menu, text);

	return menu;
}

public Sky_StoreInfeNormXP_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (SkyPoints[client] < GetConVarInt(BuyHunterXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyHunterXPCost) - SkyPoints[client]));
					return;
				}
				HunterExperience[client] += GetConVarInt(BuyHunterXP);
				SkyPoints[client] -= GetConVarInt(BuyHunterXPCost);
				PrintToChat(client, "%s \x01%d Hunter XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyHunterXP));
				SaveSkyPoints(client);
			}
			case 2:
			{
				if (SkyPoints[client] < GetConVarInt(BuySmokerXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuySmokerXPCost) - SkyPoints[client]));
					return;
				}
				SmokerExperience[client] += GetConVarInt(BuySmokerXP);
				SkyPoints[client] -= GetConVarInt(BuySmokerXPCost);
				PrintToChat(client, "%s \x01%d Smoker XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuySmokerXP));
				SaveSkyPoints(client);
			}
			case 3:
			{
				if (SkyPoints[client] < GetConVarInt(BuyBoomerXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyBoomerXPCost) - SkyPoints[client]));
					return;
				}
				BoomerExperience[client] += GetConVarInt(BuyBoomerXP);
				SkyPoints[client] -= GetConVarInt(BuyBoomerXPCost);
				PrintToChat(client, "%s \x01%d Boomer XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyBoomerXP));
				SaveSkyPoints(client);
			}
			case 4:
			{
				if (SkyPoints[client] < GetConVarInt(BuyJockeyXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyJockeyXPCost) - SkyPoints[client]));
					return;
				}
				JockeyExperience[client] += GetConVarInt(BuyJockeyXP);
				SkyPoints[client] -= GetConVarInt(BuyJockeyXPCost);
				PrintToChat(client, "%s \x01%d Jockey XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyJockeyXP));
				SaveSkyPoints(client);
			}
			case 5:
			{
				if (SkyPoints[client] < GetConVarInt(BuyChargerXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyChargerXPCost) - SkyPoints[client]));
					return;
				}
				ChargerExperience[client] += GetConVarInt(BuyChargerXP);
				SkyPoints[client] -= GetConVarInt(BuyChargerXPCost);
				PrintToChat(client, "%s \x01%d Charger XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyChargerXP));
				SaveSkyPoints(client);
			}
			case 6:
			{
				if (SkyPoints[client] < GetConVarInt(BuySpitterXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuySpitterXPCost) - SkyPoints[client]));
					return;
				}
				SpitterExperience[client] += GetConVarInt(BuySpitterXP);
				SkyPoints[client] -= GetConVarInt(BuySpitterXPCost);
				PrintToChat(client, "%s \x01%d Spitter XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuySpitterXP));
				SaveSkyPoints(client);
			}
			case 7:
			{
				if (SkyPoints[client] < GetConVarInt(BuyTankXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyTankXPCost) - SkyPoints[client]));
					return;
				}
				TankExperience[client] += GetConVarInt(BuyTankXP);
				SkyPoints[client] -= GetConVarInt(BuyTankXPCost);
				PrintToChat(client, "%s \x01%d Tank XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyTankXP));
				SaveSkyPoints(client);
			}
			case 8:
			{
				if (SkyPoints[client] < GetConVarInt(BuyInfectedXPCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyInfectedXPCost) - SkyPoints[client]));
					return;
				}
				InfectedExperience[client] += GetConVarInt(BuyInfectedXP);
				SkyPoints[client] -= GetConVarInt(BuyInfectedXPCost);
				PrintToChat(client, "%s \x01%d Infected XP awarded to your account!", PURCHASE_INFO, GetConVarInt(BuyInfectedXP));
				SaveSkyPoints(client);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else if (GetClientTeam(client) == 3) SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Sky_StoreItems (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Sky Store\nYou have %d Sky Points", SkyPoints[client]);
	SetPanelTitle(menu, text);
	if (Preset4[client] == 0) Format(text, sizeof(text), "Unlock Preset 4 (%d Cost)", GetConVarInt(BuyPresetCost));
	else Format(text, sizeof(text), "Preset 4 (Unlocked!)");
	DrawPanelItem(menu, text);
	if (Preset5[client] == 0) Format(text, sizeof(text), "Unlock Preset 5 (%d Cost)", GetConVarInt(BuyPresetCost));
	else Format(text, sizeof(text), "Preset 5 (Unlocked!)");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Prev Page");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "How to buy sky points:");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "PayPal to Mikel.toth@gmail.com (include your steam_id)");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "20 SP for each 1$\nOR\n100 SP + 1month Reserve Slot for each 5$");
	DrawPanelText(menu, text);

	return menu;
}

public Sky_StoreItems_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (SkyPoints[client] < GetConVarInt(BuyPresetCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyPresetCost) - SkyPoints[client]));
					return;
				}
				if (Preset4[client] == 1)
				{
					PrintToChat(client, "%s \x01We're flattered, but you already own this item.", ERROR_INFO);
					SendPanelToClient(Sky_StoreItems(client), client, Sky_StoreItems_Init, MENU_TIME_FOREVER);
				}
				else
				{
					Preset4[client] = 1;
					SkyPoints[client] -= GetConVarInt(BuyPresetCost);
					PrintToChat(client, "%s \x01%Preset 4 unlocked for your account!", PURCHASE_INFO);
					SaveSkyPoints(client);
				}
			}
			case 2:
			{
				if (SkyPoints[client] < GetConVarInt(BuyPresetCost))
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, (GetConVarInt(BuyPresetCost) - SkyPoints[client]));
					return;
				}
				if (Preset5[client] == 1)
				{
					PrintToChat(client, "%s \x01We're flattered, but you already own this item.", ERROR_INFO);
					SendPanelToClient(Sky_StoreItems(client), client, Sky_StoreItems_Init, MENU_TIME_FOREVER);
				}
				else
				{
					Preset5[client] = 1;
					SkyPoints[client] -= GetConVarInt(BuyPresetCost);
					PrintToChat(client, "%s \x01%Preset 5 unlocked for your account!", PURCHASE_INFO);
					SaveSkyPoints(client);
				}
			}
			case 3:
			{
				SendPanelToClient(Sky_Store(client), client, Sky_Store_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else if (GetClientTeam(client) == 3) SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Sky_StoreSurvNextXP (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Sky Store\nYou have %d Sky Points", SkyPoints[client]);
	SetPanelTitle(menu, text);

	NextXPCost[client] = PistolNextLevel[client] - PistolExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyPistolXP)) * GetConVarInt(BuyPistolXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && PistolExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && PistolExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (PistolNextLevel[client] - PistolExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Pistol (%d XP -> Lv.%d) (%d Cost)", PistolNextLevel[client] - PistolExperience[client], PistolLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = MeleeNextLevel[client] - MeleeExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyMeleeXP)) * GetConVarInt(BuyMeleeXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && MeleeExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && MeleeExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (MeleeNextLevel[client] - MeleeExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Melee (%d XP -> Lv.%d) (%d Cost)", MeleeNextLevel[client] - MeleeExperience[client], MeleeLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = UziNextLevel[client] - UziExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyUziXP)) * GetConVarInt(BuyUziXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && UziExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && UziExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (UziNextLevel[client] - UziExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Uzi (%d XP -> Lv.%d) (%d Cost)", UziNextLevel[client] - UziExperience[client], UziLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = ShotgunNextLevel[client] - ShotgunExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyShotgunXP)) * GetConVarInt(BuyShotgunXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && ShotgunExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && ShotgunExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (ShotgunNextLevel[client] - ShotgunExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Shotgun (%d XP -> Lv.%d) (%d Cost)", ShotgunNextLevel[client] - ShotgunExperience[client], ShotgunLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = SniperNextLevel[client] - SniperExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuySniperXP)) * GetConVarInt(BuySniperXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && SniperExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && SniperExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (SniperNextLevel[client] - SniperExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Sniper (%d XP -> Lv.%d) (%d Cost)", SniperNextLevel[client] - SniperExperience[client], SniperLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = RifleNextLevel[client] - RifleExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyRifleXP)) * GetConVarInt(BuyRifleXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && RifleExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && RifleExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (RifleNextLevel[client] - RifleExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Rifle (%d XP -> Lv.%d) (%d Cost)", RifleNextLevel[client] - RifleExperience[client], RifleLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = GrenadeNextLevel[client] - GrenadeExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyGrenadeXP)) * GetConVarInt(BuyGrenadeXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && GrenadeExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && GrenadeExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (GrenadeNextLevel[client] - GrenadeExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Grenade (%d XP -> Lv.%d) (%d Cost)", GrenadeNextLevel[client] - GrenadeExperience[client], GrenadeLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = ItemNextLevel[client] - ItemExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyItemXP)) * GetConVarInt(BuyItemXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && ItemExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && ItemExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (ItemNextLevel[client] - ItemExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Item (%d XP -> Lv.%d) (%d Cost)", ItemNextLevel[client] - ItemExperience[client], ItemLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = PhysicalNextLevel[client] - PhysicalExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyPhysicalXP)) * GetConVarInt(BuyPhysicalXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && PhysicalExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && PhysicalExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (PhysicalNextLevel[client] - PhysicalExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Physical (%d XP -> Lv.%d) (%d Cost)", PhysicalNextLevel[client] - PhysicalExperience[client], PhysicalLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	Format(text, sizeof(text), "How to buy sky points:");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "PayPal to Mikel.toth@gmail.com (include your steam_id)");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "20 SP for each 1$\nOR\n100 SP + 1month Reserve Slot for each 5$");
	DrawPanelText(menu, text);

	return menu;
}

public Sky_StoreSurvNextXP_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				NextXPCost[client] = PistolNextLevel[client] - PistolExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyPistolXP)) * GetConVarInt(BuyPistolXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && PistolExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && PistolExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (PistolNextLevel[client] - PistolExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Pistol XP awarded to your account!", PURCHASE_INFO, PistolNextLevel[client] - PistolExperience[client]);
				PistolExperience[client] = PistolNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 2:
			{
				NextXPCost[client] = MeleeNextLevel[client] - MeleeExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyMeleeXP)) * GetConVarInt(BuyMeleeXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && MeleeExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && MeleeExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (MeleeNextLevel[client] - MeleeExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Melee XP awarded to your account!", PURCHASE_INFO, MeleeNextLevel[client] - MeleeExperience[client]);
				MeleeExperience[client] = MeleeNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 3:
			{
				NextXPCost[client] = UziNextLevel[client] - UziExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyUziXP)) * GetConVarInt(BuyUziXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && UziExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && UziExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (UziNextLevel[client] - UziExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Uzi XP awarded to your account!", PURCHASE_INFO, UziNextLevel[client] - UziExperience[client]);
				UziExperience[client] = UziNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 4:
			{
				NextXPCost[client] = ShotgunNextLevel[client] - ShotgunExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyShotgunXP)) * GetConVarInt(BuyShotgunXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && ShotgunExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && ShotgunExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (ShotgunNextLevel[client] - ShotgunExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Shotgun XP awarded to your account!", PURCHASE_INFO, ShotgunNextLevel[client] - ShotgunExperience[client]);
				ShotgunExperience[client] = ShotgunNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 5:
			{
				NextXPCost[client] = SniperNextLevel[client] - SniperExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuySniperXP)) * GetConVarInt(BuySniperXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && SniperExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && SniperExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (SniperNextLevel[client] - SniperExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Sniper XP awarded to your account!", PURCHASE_INFO, SniperNextLevel[client] - SniperExperience[client]);
				SniperExperience[client] = SniperNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 6:
			{
				NextXPCost[client] = RifleNextLevel[client] - RifleExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyRifleXP)) * GetConVarInt(BuyRifleXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && RifleExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && RifleExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (RifleNextLevel[client] - RifleExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Rifle XP awarded to your account!", PURCHASE_INFO, RifleNextLevel[client] - RifleExperience[client]);
				RifleExperience[client] = RifleNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 7:
			{
				NextXPCost[client] = GrenadeNextLevel[client] - GrenadeExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyGrenadeXP)) * GetConVarInt(BuyGrenadeXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && GrenadeExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && GrenadeExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (GrenadeNextLevel[client] - GrenadeExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Grenade XP awarded to your account!", PURCHASE_INFO, GrenadeNextLevel[client] - GrenadeExperience[client]);
				GrenadeExperience[client] = GrenadeNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 8:
			{
				NextXPCost[client] = ItemNextLevel[client] - ItemExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyItemXP)) * GetConVarInt(BuyItemXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && ItemExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && ItemExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (ItemNextLevel[client] - ItemExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Item XP awarded to your account!", PURCHASE_INFO, ItemNextLevel[client] - ItemExperience[client]);
				ItemExperience[client] = ItemNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 9:
			{
				NextXPCost[client] = PhysicalNextLevel[client] - PhysicalExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyPhysicalXP)) * GetConVarInt(BuyPhysicalXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && PhysicalExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && PhysicalExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (PhysicalNextLevel[client] - PhysicalExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Physical XP awarded to your account!", PURCHASE_INFO, PhysicalNextLevel[client] - PhysicalExperience[client]);
				PhysicalExperience[client] = PhysicalNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else if (GetClientTeam(client) == 3) SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Sky_StoreInfeNextXP (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Sky Store\nYou have %d Sky Points", SkyPoints[client]);
	SetPanelTitle(menu, text);

	NextXPCost[client] = HunterNextLevel[client] - HunterExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyHunterXP)) * GetConVarInt(BuyHunterXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && HunterExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && HunterExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (HunterNextLevel[client] - HunterExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	Format(text, sizeof(text), "Hunter (%d XP -> Lv.%d) (%d Cost)", HunterNextLevel[client] - HunterExperience[client], HunterLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = SmokerNextLevel[client] - SmokerExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuySmokerXP)) * GetConVarInt(BuySmokerXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && SmokerExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && SmokerExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (SmokerNextLevel[client] - SmokerExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	Format(text, sizeof(text), "Smoker (%d XP -> Lv.%d) (%d Cost)", SmokerNextLevel[client] - SmokerExperience[client], SmokerLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = BoomerNextLevel[client] - BoomerExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyBoomerXP)) * GetConVarInt(BuyBoomerXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && BoomerExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && BoomerExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (BoomerNextLevel[client] - BoomerExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	Format(text, sizeof(text), "Boomer (%d XP -> Lv.%d) (%d Cost)", BoomerNextLevel[client] - BoomerExperience[client], BoomerLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = JockeyNextLevel[client] - JockeyExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyJockeyXP)) * GetConVarInt(BuyJockeyXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && JockeyExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && JockeyExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (JockeyNextLevel[client] - JockeyExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Jockey (%d XP -> Lv.%d) (%d Cost)", JockeyNextLevel[client] - JockeyExperience[client], JockeyLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = ChargerNextLevel[client] - ChargerExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyChargerXP)) * GetConVarInt(BuyChargerXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && ChargerExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && ChargerExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (ChargerNextLevel[client] - ChargerExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Charger (%d XP -> Lv.%d) (%d Cost)", ChargerNextLevel[client] - ChargerExperience[client], ChargerLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = SpitterNextLevel[client] - SpitterExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuySpitterXP)) * GetConVarInt(BuySpitterXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && SpitterExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && SpitterExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (SpitterNextLevel[client] - SpitterExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Spitter (%d XP -> Lv.%d) (%d Cost)", SpitterNextLevel[client] - SpitterExperience[client], SpitterLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = TankNextLevel[client] - TankExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyTankXP)) * GetConVarInt(BuyTankXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && TankExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && TankExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (TankNextLevel[client] - TankExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Tank (%d XP -> Lv.%d) (%d Cost)", TankNextLevel[client] - TankExperience[client], TankLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	NextXPCost[client] = InfectedNextLevel[client] - InfectedExperience[client];
	NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyInfectedXP)) * GetConVarInt(BuyInfectedXPCost);
	NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
	if (NextXPCost[client] < 1 && InfectedExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
	else if (NextXPCost[client] < 1 && InfectedExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (InfectedNextLevel[client] - InfectedExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
	
	Format(text, sizeof(text), "Infected (%d XP -> Lv.%d) (%d Cost)", InfectedNextLevel[client] - InfectedExperience[client], InfectedLevel[client] + 1, NextXPCost[client]);
	DrawPanelItem(menu, text);

	Format(text, sizeof(text), "How to buy sky points:");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "PayPal to Mikel.toth@gmail.com (include your steam_id)");
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "20 SP for each 1$\nOR\n100 SP + 1month Reserve Slot for each 5$");
	DrawPanelText(menu, text);

	return menu;
}

public Sky_StoreInfeNextXP_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				NextXPCost[client] = HunterNextLevel[client] - HunterExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyHunterXP)) * GetConVarInt(BuyHunterXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && HunterExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && HunterExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (HunterNextLevel[client] - HunterExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Hunter XP awarded to your account!", PURCHASE_INFO, HunterNextLevel[client] - HunterExperience[client]);
				HunterExperience[client] = HunterNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 2:
			{
				NextXPCost[client] = SmokerNextLevel[client] - SmokerExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuySmokerXP)) * GetConVarInt(BuySmokerXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && SmokerExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && SmokerExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (SmokerNextLevel[client] - SmokerExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Smoker XP awarded to your account!", PURCHASE_INFO, SmokerNextLevel[client] - SmokerExperience[client]);
				SmokerExperience[client] = SmokerNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 3:
			{
				NextXPCost[client] = BoomerNextLevel[client] - BoomerExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyBoomerXP)) * GetConVarInt(BuyBoomerXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && BoomerExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && BoomerExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (BoomerNextLevel[client] - BoomerExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Boomer XP awarded to your account!", PURCHASE_INFO, BoomerNextLevel[client] - BoomerExperience[client]);
				BoomerExperience[client] = BoomerNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 4:
			{
				NextXPCost[client] = JockeyNextLevel[client] - JockeyExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyJockeyXP)) * GetConVarInt(BuyJockeyXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && JockeyExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && JockeyExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (JockeyNextLevel[client] - JockeyExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Jockey XP awarded to your account!", PURCHASE_INFO, JockeyNextLevel[client] - JockeyExperience[client]);
				JockeyExperience[client] = JockeyNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 5:
			{
				NextXPCost[client] = ChargerNextLevel[client] - ChargerExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyChargerXP)) * GetConVarInt(BuyChargerXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && ChargerExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && ChargerExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (ChargerNextLevel[client] - ChargerExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Charger XP awarded to your account!", PURCHASE_INFO, ChargerNextLevel[client] - ChargerExperience[client]);
				ChargerExperience[client] = ChargerNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 6:
			{
				NextXPCost[client] = SpitterNextLevel[client] - SpitterExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuySpitterXP)) * GetConVarInt(BuySpitterXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && SpitterExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && SpitterExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (SpitterNextLevel[client] - SpitterExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Spitter XP awarded to your account!", PURCHASE_INFO, SpitterNextLevel[client] - SpitterExperience[client]);
				SpitterExperience[client] = SpitterNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 7:
			{
				NextXPCost[client] = TankNextLevel[client] - TankExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyTankXP)) * GetConVarInt(BuyTankXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && TankExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && TankExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (TankNextLevel[client] - TankExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Tank XP awarded to your account!", PURCHASE_INFO, TankNextLevel[client] - TankExperience[client]);
				TankExperience[client] = TankNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			case 8:
			{
				NextXPCost[client] = InfectedNextLevel[client] - InfectedExperience[client];
				NextXPCost[client] = (NextXPCost[client] / GetConVarInt(BuyInfectedXP)) * GetConVarInt(BuyInfectedXPCost);
				NextXPCost[client] = RoundToCeil(NextXPCost[client] * GetConVarFloat(BulkXPDiscount));
				if (NextXPCost[client] < 1 && InfectedExperience[client] < GetConVarInt(MustExceedXPForFreeUpgrade)) NextXPCost[client] = 1;
				else if (NextXPCost[client] < 1 && InfectedExperience[client] >= GetConVarInt(MustExceedXPForFreeUpgrade) && (InfectedNextLevel[client] - InfectedExperience[client]) < GetConVarInt(FreeXPUpgradeRange)) NextXPCost[client] = 0;
				
				if (SkyPoints[client] < NextXPCost[client])
				{
					PrintToChat(client, "%s \x01Not enough Sky Points, you need %d more!", ERROR_INFO, NextXPCost[client]);
					return;
				}
				
				SkyPoints[client] -= NextXPCost[client];
				PrintToChat(client, "%s \x01%d Infected XP awarded to your account!", PURCHASE_INFO, InfectedNextLevel[client] - InfectedExperience[client]);
				InfectedExperience[client] = InfectedNextLevel[client];
				experience_increase(client, 0);
				SaveSkyPoints(client);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else if (GetClientTeam(client) == 3) SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}