public Handle:Survivor_MainMenu (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Survivor Main Menu");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], SurvivorPoints[client], SurvivorTeamPoints);
	DrawPanelText(menu, text);
	
	Format(text, sizeof(text), "Equipment Locker");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Pick from weapons you've unlocked here");
	Format(text, sizeof(text), "Spend Points");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Spend your (team) points earned in-game");
	Format(text, sizeof(text), "Status Screen");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "View experience, and stuff like that");
	Format(text, sizeof(text), "Challenge Board");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "View The Survivor Challenge Board!");
	Format(text, sizeof(text), "Preset Configurations");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Spend Sky Points bought on our site, on anything!");
	Format(text, sizeof(text), "In-Game Store");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Spend Sky Points you've earned through donating!");

	return menu;
}

public Survivor_MainMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				SendPanelToClient(Survivor_BuyMenu(client), client, Survivor_BuyMenu_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				SendPanelToClient(Survivor_Stats(client), client, Survivor_Stats_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				SendPanelToClient(Challenge_Board(client), client, Challenge_Board_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 6:
			{
				SendPanelToClient(Sky_Store(client), client, Sky_Store_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Stats (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Statistics Page", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Pistol:       %d /%d xp | Lv.%d", PistolExperience[client], PistolNextLevel[client], PistolLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Melee:      %d /%d xp | Lv.%d", MeleeExperience[client], MeleeNextLevel[client], MeleeLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Uzi:          %d /%d xp | Lv.%d", UziExperience[client], UziNextLevel[client], UziLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Shotgun:   %d /%d xp | Lv.%d", ShotgunExperience[client], ShotgunNextLevel[client], ShotgunLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Sniper:     %d /%d xp | Lv.%d", SniperExperience[client], SniperNextLevel[client], SniperLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Rifle:        %d /%d xp | Lv.%d", RifleExperience[client], RifleNextLevel[client], RifleLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Grenade:   %d /%d xp | Lv.%d", GrenadeExperience[client], GrenadeNextLevel[client], GrenadeLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Item:        %d /%d xp | Lv.%d", ItemExperience[client], ItemNextLevel[client], ItemLevel[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Physical:   %d /%d xp | Lv.%d", PhysicalExperience[client], PhysicalNextLevel[client], PhysicalLevel[client]);
	DrawPanelText(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Stats_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Locker (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	SetPanelTitle(menu, "Equipment Locker");
	DrawPanelItem(menu, "Pistols");
	if (PhysicalLevel[client] >= GetConVarInt(UziLevelUnlock)) Format(text, sizeof(text), "Uzis");
	else Format(text, sizeof(text), "Uzis (Unlocks at Physical Lv.%d)", GetConVarInt(UziLevelUnlock));
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] >= GetConVarInt(ShotgunLevelUnlock)) Format(text, sizeof(text), "Shotguns");
	else Format(text, sizeof(text), "Shotguns (Unlocks at Physical Lv.%d)", GetConVarInt(ShotgunLevelUnlock));
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] >= GetConVarInt(SniperLevelUnlock)) Format(text, sizeof(text), "Snipers");
	else Format(text, sizeof(text), "Snipers (Unlocks at Physical Lv.%d)", GetConVarInt(SniperLevelUnlock));
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] >= GetConVarInt(RifleLevelUnlock)) Format(text, sizeof(text), "Rifles");
	else Format(text, sizeof(text), "Rifles (Unlocks at Physical Lv.%d)", GetConVarInt(RifleLevelUnlock));
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] >= GetConVarInt(MeleeLevelUnlock)) Format(text, sizeof(text), "Melee");
	else Format(text, sizeof(text), "Melee (Unlocks at Physical Lv.%d)", GetConVarInt(MeleeLevelUnlock));
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] >= GetConVarInt(GrenadeLevelUnlock)) Format(text, sizeof(text), "Grenades");
	else Format(text, sizeof(text), "Grenades (Unlocks at Physical Lv.%d)", GetConVarInt(GrenadeLevelUnlock));
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] >= GetConVarInt(ItemLevelUnlock)) Format(text, sizeof(text), "Health Items");
	else Format(text, sizeof(text), "Health Items (Unlocks at Physical Lv.%d)", GetConVarInt(ItemLevelUnlock));
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] >= GetConVarInt(SpecialAmmoUnlock)) Format(text, sizeof(text), "Ammo Upgrades");
	else Format(text, sizeof(text), "Ammo Upgrades (Unlocks at Physical Lv.%d", GetConVarInt(SpecialAmmoUnlock));
	DrawPanelItem(menu, text);
	
	return menu;
}

public Survivor_Locker_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Survivor_Pistols(client), client, Survivor_Pistols_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (PhysicalLevel[client] >= GetConVarInt(UziLevelUnlock)) SendPanelToClient(Survivor_Uzis(client), client, Survivor_Uzis_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (PhysicalLevel[client] >= GetConVarInt(ShotgunLevelUnlock)) SendPanelToClient(Survivor_Shotgun(client), client, Survivor_Shotgun_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (PhysicalLevel[client] >= GetConVarInt(SniperLevelUnlock)) SendPanelToClient(Survivor_Sniper(client), client, Survivor_Sniper_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				if (PhysicalLevel[client] >= GetConVarInt(RifleLevelUnlock)) SendPanelToClient(Survivor_Rifle(client), client, Survivor_Rifle_Init, MENU_TIME_FOREVER);
			}
			case 6:
			{
				if (PhysicalLevel[client] >= GetConVarInt(MeleeLevelUnlock)) SendPanelToClient(Survivor_Melee(client), client, Survivor_Melee_Init, MENU_TIME_FOREVER);
			}
			case 7:
			{
				if (PhysicalLevel[client] >= GetConVarInt(GrenadeLevelUnlock)) SendPanelToClient(Survivor_Grenade(client), client, Survivor_Grenade_Init, MENU_TIME_FOREVER);
			}
			case 8:
			{
				if (PhysicalLevel[client] >= GetConVarInt(ItemLevelUnlock)) SendPanelToClient(Survivor_Item(client), client, Survivor_Item_Init, MENU_TIME_FOREVER);
			}
			case 9:
			{
				if (PhysicalLevel[client] >= GetConVarInt(SpecialAmmoUnlock)) SendPanelToClient(Survivor_Ammo(client), client, Survivor_Ammo_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Pistols (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Pistols");
	DrawPanelItem(menu, text);
	if (PistolLevel[client] >= GetConVarInt(PistolDeagleLevel)) Format(text, sizeof(text), "D. Eagle");
	else Format(text, sizeof(text), "D. Eagle (Unlocks at Pistol Lv. %d)", GetConVarInt(PistolDeagleLevel));
	DrawPanelItem(menu, text);

	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Pistols_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				ExecCheatCommand(client, "give", "pistol");
			}
			case 2:
			{
				if (PistolLevel[client] >= GetConVarInt(PistolDeagleLevel)) ExecCheatCommand(client, "give", "pistol_magnum");
			}
			case 3:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Uzis (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	if (UziLevel[client] >= GetConVarInt(UziMp5Level)) Format(text, sizeof(text), "Mp5");
	else Format(text, sizeof(text), "Mp5 (Unlocks at Uzi Lv. %d)", GetConVarInt(UziMp5Level));
	DrawPanelItem(menu, text);
	if (UziLevel[client] >= GetConVarInt(UziMac10Level)) Format(text, sizeof(text), "Mac10");
	else Format(text, sizeof(text), "Mac10 (Unlocks at Uzi Lv. %d)", GetConVarInt(UziMac10Level));
	DrawPanelItem(menu, text);
	if (UziLevel[client] >= GetConVarInt(UziTmpLevel)) Format(text, sizeof(text), "Tmp-Silenced");
	else Format(text, sizeof(text), "Tmp-Silenced (Unlocks at Uzi Lv. %d)", GetConVarInt(UziTmpLevel));
	DrawPanelItem(menu, text);

	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Uzis_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (UziLevel[client] >= GetConVarInt(UziMp5Level))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "smg_mp5");
					LastWeaponOwned[client] = "smg_mp5";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 2:
			{
				if (UziLevel[client] >= GetConVarInt(UziMac10Level))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "smg");
					LastWeaponOwned[client] = "smg";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 3:
			{
				if (UziLevel[client] >= GetConVarInt(UziTmpLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "smg_silenced");
					LastWeaponOwned[client] = "smg_silenced";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 4:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Shotgun (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	if (ShotgunLevel[client] >= GetConVarInt(ShotgunChromeLevel)) Format(text, sizeof(text), "Chrome Shotgun");
	else Format(text, sizeof(text), "Chrome Shotgun (Unlocks at Shotgun Lv. %d)", GetConVarInt(ShotgunChromeLevel));
	DrawPanelItem(menu, text);
	if (ShotgunLevel[client] >= GetConVarInt(ShotgunPumpLevel)) Format(text, sizeof(text), "Pump Shotgun");
	else Format(text, sizeof(text), "Pump Shotgun (Unlocks at Shotgun Lv. %d)", GetConVarInt(ShotgunPumpLevel));
	DrawPanelItem(menu, text);
	if (ShotgunLevel[client] >= GetConVarInt(ShotgunSpasLevel)) Format(text, sizeof(text), "SPAS Shotgun");
	else Format(text, sizeof(text), "SPAS Shotgun (Unlocks at Shotgun Lv. %d)", GetConVarInt(ShotgunSpasLevel));
	DrawPanelItem(menu, text);
	if (ShotgunLevel[client] >= GetConVarInt(ShotgunAutoLevel)) Format(text, sizeof(text), "Auto-Shotgun");
	else Format(text, sizeof(text), "Auto-Shotgun (Unlocks at Shotgun Lv. %d)", GetConVarInt(ShotgunAutoLevel));
	DrawPanelItem(menu, text);


	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Shotgun_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (ShotgunLevel[client] >= GetConVarInt(ShotgunChromeLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "shotgun_chrome");
					LastWeaponOwned[client] = "shotgun_chrome";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 2:
			{
				if (ShotgunLevel[client] >= GetConVarInt(ShotgunPumpLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "pumpshotgun");
					LastWeaponOwned[client] = "pumpshotgun";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 3:
			{
				if (ShotgunLevel[client] >= GetConVarInt(ShotgunSpasLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "shotgun_spas");
					LastWeaponOwned[client] = "shotgun_spas";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 4:
			{
				if (ShotgunLevel[client] >= GetConVarInt(ShotgunAutoLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "autoshotgun");
					LastWeaponOwned[client] = "autoshotgun";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 5:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Sniper (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	if (SniperLevel[client] >= GetConVarInt(SniperScoutLevel)) Format(text, sizeof(text), "Scout");
	else Format(text, sizeof(text), "Scout (Unlocks at Sniper Lv. %d)", GetConVarInt(SniperScoutLevel));
	DrawPanelItem(menu, text);
	if (SniperLevel[client] >= GetConVarInt(SniperAwpLevel)) Format(text, sizeof(text), "AWP");
	else Format(text, sizeof(text), "AWP (Unlocks at Sniper Lv. %d)", GetConVarInt(SniperAwpLevel));
	DrawPanelItem(menu, text);
	if (SniperLevel[client] >= GetConVarInt(SniperMilitaryLevel)) Format(text, sizeof(text), "Military");
	else Format(text, sizeof(text), "Military (Unlocks at Sniper Lv. %d)", GetConVarInt(SniperMilitaryLevel));
	DrawPanelItem(menu, text);
	if (SniperLevel[client] >= GetConVarInt(SniperHuntingLevel)) Format(text, sizeof(text), "Hunting Rifle");
	else Format(text, sizeof(text), "Hunting Rifle (Unlocks at Sniper Lv. %d)", GetConVarInt(SniperHuntingLevel));
	DrawPanelItem(menu, text);


	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Sniper_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (SniperLevel[client] >= GetConVarInt(SniperScoutLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "sniper_scout");
					LastWeaponOwned[client] = "sniper_scout";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 2:
			{
				if (SniperLevel[client] >= GetConVarInt(SniperAwpLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "sniper_awp");
					LastWeaponOwned[client] = "sniper_awp";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 3:
			{
				if (SniperLevel[client] >= GetConVarInt(SniperMilitaryLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "sniper_military");
					LastWeaponOwned[client] = "sniper_military";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 4:
			{
				if (SniperLevel[client] >= GetConVarInt(SniperHuntingLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "hunting_rifle");
					LastWeaponOwned[client] = "hunting_rifle";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 5:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Rifle (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	if (RifleLevel[client] >= GetConVarInt(RifleDesertLevel)) Format(text, sizeof(text), "Desert Rifle");
	else Format(text, sizeof(text), "Desert Rifle (Unlocks at Rifle Lv. %d)", GetConVarInt(RifleDesertLevel));
	DrawPanelItem(menu, text);
	if (RifleLevel[client] >= GetConVarInt(RifleM16Level)) Format(text, sizeof(text), "M16");
	else Format(text, sizeof(text), "M16 (Unlocks at Rifle Lv. %d)", GetConVarInt(RifleM16Level));
	DrawPanelItem(menu, text);
	if (RifleLevel[client] >= GetConVarInt(RifleSG552Level)) Format(text, sizeof(text), "SG552");
	else Format(text, sizeof(text), "SG552 (Unlocks at Rifle Lv. %d)", GetConVarInt(RifleSG552Level));
	DrawPanelItem(menu, text);
	if (RifleLevel[client] >= GetConVarInt(RifleAK47Level)) Format(text, sizeof(text), "AK47");
	else Format(text, sizeof(text), "AK47 (Unlocks at Rifle Lv. %d)", GetConVarInt(RifleAK47Level));
	DrawPanelItem(menu, text);
	if (RifleLevel[client] >= GetConVarInt(RifleM60Level) && !M60CD[client]) Format(text, sizeof(text), "M60");
	else if (M60CD[client]) Format(text, sizeof(text), "M60 %3.1f sec(s) cooldown", GetConVarFloat(M60CDTIME) - M60COUNT[client]);
	else Format(text, sizeof(text), "M60 (Unlocks at Rifle Lv. %d)", GetConVarInt(RifleM60Level));
	DrawPanelItem(menu, text);

	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Rifle_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleDesertLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "rifle_desert");
					LastWeaponOwned[client] = "rifle_desert";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 2:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleM16Level))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "rifle");
					LastWeaponOwned[client] = "rifle";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 3:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleSG552Level))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "rifle_sg552");
					LastWeaponOwned[client] = "rifle_sg552";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 4:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleAK47Level))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "rifle_ak47");
					LastWeaponOwned[client] = "rifle_ak47";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 5:
			{
				if (M60CD[client]) return;
				if (RifleLevel[client] >= GetConVarInt(RifleM60Level))
				{
					M60CD[client] = true;
					M60COUNT[client] = -1.0;
					CreateTimer(1.0, EnableM60, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					ExecCheatCommand(client, "give", "rifle_m60");
					LastWeaponOwned[client] = "rifle_m60";
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 6:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Melee (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelGuitarLevel)) Format(text, sizeof(text), "Electric Guitar");
	else Format(text, sizeof(text), "Electric Guitar (Unlocks at Mel Lv. %d)", GetConVarInt(MelGuitarLevel));
	DrawPanelItem(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelPanLevel)) Format(text, sizeof(text), "Frying Pan");
	else Format(text, sizeof(text), "Frying Pan (Unlocks at Mel Lv. %d)", GetConVarInt(MelPanLevel));
	DrawPanelItem(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelCricketLevel)) Format(text, sizeof(text), "Cricket Bat");
	else Format(text, sizeof(text), "Cricket Bat (Unlocks at Mel Lv. %d)", GetConVarInt(MelCricketLevel));
	DrawPanelItem(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelFireaxeLevel)) Format(text, sizeof(text), "Fireaxe");
	else Format(text, sizeof(text), "Fireaxe (Unlocks at Mel Lv. %d)", GetConVarInt(MelFireaxeLevel));
	DrawPanelItem(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelGolfclubLevel)) Format(text, sizeof(text), "Golf Club");
	else Format(text, sizeof(text), "Golf Club (Unlocks at Mel Lv. %d)", GetConVarInt(MelGolfclubLevel));
	DrawPanelItem(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelTonfaLevel)) Format(text, sizeof(text), "Tonfa");
	else Format(text, sizeof(text), "Tonfa (Unlocks at Mel Lv. %d)", GetConVarInt(MelTonfaLevel));
	DrawPanelItem(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelChainsawLevel)) Format(text, sizeof(text), "Chainsaw");
	else Format(text, sizeof(text), "Chainsaw (Unlocks at Mel Lv. %d)", GetConVarInt(MelChainsawLevel));
	DrawPanelItem(menu, text);
	if (MeleeLevel[client] >= GetConVarInt(MelMacheteLevel)) Format(text, sizeof(text), "Machete");
	else Format(text, sizeof(text), "Machete (Unlocks at Mel Lv. %d)", GetConVarInt(MelMacheteLevel));
	DrawPanelItem(menu, text);

	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Melee_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelGuitarLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "electric_guitar");
				}
			}
			case 2:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelPanLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "frying_pan");
				}
			}
			case 3:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelCricketLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "cricket_bat");
				}
			}
			case 4:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelFireaxeLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "fireaxe");
				}
			}
			case 5:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelGolfclubLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "golfclub");
				}
			}
			case 6:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelTonfaLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "tonfa");
				}
			}
			case 7:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelChainsawLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "chainsaw");
				}
			}
			case 8:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelMacheteLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
					ExecCheatCommand(client, "give", "machete");
				}
			}
			case 9:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Grenade (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	
	if (GrenadeLevel[client] >= GetConVarInt(GrenPipeLevel))
	{
		if (GrenadeCount[client] < 1) Format(text, sizeof(text), "Pipe Bomb (Out of Stock)");
		else Format(text, sizeof(text), "Pipe Bomb (%d in Stock)", GrenadeCount[client]);
	}
	else Format(text, sizeof(text), "Pipe Bomb (Unlocks at Grenade Lv. %d)", GetConVarInt(GrenPipeLevel));
	DrawPanelItem(menu, text);
	
	if (GrenadeLevel[client] >= GetConVarInt(GrenJarLevel))
	{
		if (GrenadeCount[client] < 1) Format(text, sizeof(text), "Vomit Jar (Out of Stock)");
		else Format(text, sizeof(text), "Vomit Jar (%d in Stock)", GrenadeCount[client]);
	}
	else Format(text, sizeof(text), "Vomit Jar (Unlocks at Grenade Lv. %d)", GetConVarInt(GrenJarLevel));
	DrawPanelItem(menu, text);
	
	if (GrenadeLevel[client] >= GetConVarInt(GrenMolLevel))
	{
		if (GrenadeCount[client] < 1) Format(text, sizeof(text), "Molotov (Out of Stock)");
		else Format(text, sizeof(text), "Molotov (%d in Stock)", GrenadeCount[client]);
	}
	else Format(text, sizeof(text), "Molotov (Unlocks at Grenade Lv. %d)", GetConVarInt(GrenMolLevel));
	DrawPanelItem(menu, text);
	
	if (GrenadeLevel[client] >= GetConVarInt(GrenLauncherLevel))
	{
		if (GrenadeCount[client] < 1) Format(text, sizeof(text), "G. Launcher (Out of Stock)");
		else Format(text, sizeof(text), "G. Launcher (Expends all stock)");
	}
	else Format(text, sizeof(text), "Grenade Launcher (Unlocks at Gren Lv. %d)", GetConVarInt(GrenLauncherLevel));
	DrawPanelItem(menu, text);

	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Grenade_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (GrenadeLevel[client] >= GetConVarInt(GrenPipeLevel) && GrenadeCount[client] > 0)
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Grenade);
					GrenadeCount[client]--;
					ExecCheatCommand(client, "give", "pipe_bomb");
				}
			}
			case 2:
			{
				if (GrenadeLevel[client] >= GetConVarInt(GrenJarLevel) && GrenadeCount[client] > 0)
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Grenade);
					GrenadeCount[client]--;
					ExecCheatCommand(client, "give", "vomitjar");
				}
			}
			case 3:
			{
				if (GrenadeLevel[client] >= GetConVarInt(GrenMolLevel) && GrenadeCount[client] > 0)
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Grenade);
					GrenadeCount[client]--;
					ExecCheatCommand(client, "give", "molotov");
				}
			}
			case 4:
			{
				if (GrenadeLevel[client] >= GetConVarInt(GrenLauncherLevel))
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
					GrenadeCount[client] = 0;
					ExecCheatCommand(client, "give", "grenade_launcher");
					ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
				}
			}
			case 5:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Item (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthPillsLevel))
	{
		if (TempHealCount[client] < 1) Format(text, sizeof(text), "Pain Killers (Out of Stock)");
		else Format(text, sizeof(text), "Pain Killers (%d in Stock)", TempHealCount[client]);
	}
	else Format(text, sizeof(text), "Pain Killers (Unlocks at Health Lv. %d)", GetConVarInt(HealthPillsLevel));
	DrawPanelItem(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthPackLevel))
	{
		if (HealCount[client] < 1) Format(text, sizeof(text), "Medkits (Out of Stock)");
		else Format(text, sizeof(text), "Medkits (%d in Stock)", HealCount[client]);
	}
	else Format(text, sizeof(text), "Medkits (Unlocks at Health Lv. %d)", GetConVarInt(HealthPackLevel));
	DrawPanelItem(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthAdrenLevel))
	{
		if (TempHealCount[client] < 1) Format(text, sizeof(text), "Adrenaline (Out of Stock)");
		else Format(text, sizeof(text), "Adrenaline (%d in Stock)", TempHealCount[client]);
	}
	else Format(text, sizeof(text), "Adrenaline (Unlocks at Health Lv. %d)", GetConVarInt(HealthAdrenLevel));
	DrawPanelItem(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthHealLevel))
	{
		if (HealCount[client] < 1) Format(text, sizeof(text), "Instant Heal (Out of Stock)");
		else Format(text, sizeof(text), "Instant Heal (%d in Stock)", HealCount[client]);
	}
	else Format(text, sizeof(text), "Instant Heal (Unlocks at Health Lv. %d)", GetConVarInt(HealthHealLevel));
	DrawPanelItem(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthIncapLevel))
	{
		if (HealCount[client] < 1) Format(text, sizeof(text), "Incap Protection (Out of Stock)");
		else Format(text, sizeof(text), "Incap Protection (%d in Stock)", HealCount[client]);
	}
	else Format(text, sizeof(text), "Incap Protection (Unlocks at Health Lv. %d)", GetConVarInt(HealthIncapLevel));
	DrawPanelItem(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Item_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthPillsLevel) && TempHealCount[client] > 0)
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Pills);
					TempHealCount[client]--;
					ExecCheatCommand(client, "give", "pain_pills");
				}
			}
			case 2:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthPackLevel) && HealCount[client] > 0)
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_FirstAid);
					HealCount[client]--;
					ExecCheatCommand(client, "give", "first_aid_kit");
				}
			}
			case 3:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthAdrenLevel) && TempHealCount[client] > 0)
				{
					L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Pills);
					TempHealCount[client]--;
					ExecCheatCommand(client, "give", "adrenaline");
				}
			}
			case 4:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthHealLevel) && HealCount[client] > 0)
				{
					ExecCheatCommand(client, "give", "health");
					HealCount[client]--;
				}
			}
			case 5:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthIncapLevel) && HealCount[client] > 0)
				{
					if (IncapProtection[client] == -1)
					{
						PrintToChat(client, "%s \x01Incap Protection is on cooldown.", ERROR_INFO);
						return;
					}
					if (IncapProtection[client] > 0)
					{
						PrintToChat(client, "%s \x01still have \x05%d \x01uses remaining.", ERROR_INFO, IncapProtection[client]);
						return;
					}
					PrintToChat(client, "%s \x01Incap Protection Added.", INFO);
					IncapProtection[client] = GetConVarInt(IncapCount);
					HealCount[client]--;
					CreateTimer(1.0, CheckIfEnsnared, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);				
				}
			}
			case 6:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_Locker(client), client, Survivor_Locker_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_BuyMenu (client)
{
	new Handle:menu = CreatePanel();
	
	SetPanelTitle(menu, "Survivor Main Menu");
	new String:text[64];
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], SurvivorPoints[client], SurvivorTeamPoints);
	DrawPanelText(menu, text);
	
	Format(text, sizeof(text), "Weapons");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Tier 2 Weapons");
	
	Format(text, sizeof(text), "Health Items");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Health Items");
	
	Format(text, sizeof(text), "Abilities");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Personal Abilities");
	
	Format(text, sizeof(text), "Weapon Upgrades");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Weapon Upgrades");
	
	Format(text, sizeof(text), "Multiplier Status");
	DrawPanelItem(menu, text);
	if (showinfo[client] == 1) DrawPanelText(menu, "Your Multiplier Status Screen");

	return menu;
}

public Survivor_BuyMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Survivor_Weapons(client), client, Survivor_Weapons_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (!IsPlayerAlive(client)) return;
				SendPanelToClient(Survivor_HealthMenu(client), client, Survivor_HealthMenu_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				SendPanelToClient(Survivor_Abilities(client), client, Survivor_Abilities_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				SendPanelToClient(Survivor_Upgrades(client), client, Survivor_Upgrades_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				SendPanelToClient(Survivor_Multiplier(client), client, Survivor_Multiplier_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Multiplier (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Statistics Page", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Pistol:     %d /%d kills", SurvivorPistolValue[client], SurvivorPistolGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Melee:   %d /%d kills", SurvivorMeleeValue[client], SurvivorMeleeGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Uzi:        %d /%d kills", SurvivorSmgValue[client], SurvivorSmgGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Shotgun: %d /%d kills", SurvivorShotgunValue[client], SurvivorShotgunGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Sniper:   %d /%d kills", SurvivorSniperValue[client], SurvivorSniperGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Rifle:      %d /%d kills", SurvivorRifleValue[client], SurvivorRifleGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Headshot:  %d /%d kills", SurvivorHeadshotValue[client], SurvivorHeadshotGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Common:   %d /%d kills", SurvivorCommonValue[client], SurvivorCommonGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Team Common: %d /%d kills", TeamCommonValue, TeamCommonGoal);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "SI:          %d /%d kills", SurvivorSpecialValue[client], SurvivorSpecialGoal[client]);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Team SI:  %d /%d kills", TeamSpecialValue, TeamSpecialGoal);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Multiplier: %3.3f", SurvivorMultiplier[client]);
	DrawPanelText(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Multiplier_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Weapons (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "Weapons Menu", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], SurvivorPoints[client], SurvivorTeamPoints);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Auto Shotgun");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "SPAS Shotgun");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "M16 Rifle");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "AK47 Rifle");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Desert Rifle");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "SG552 Rifle");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Awp Sniper Rifle");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Military Sniper Rifle");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Hunting Rifle");
	DrawPanelItem(menu, text);
	
	Format(text, sizeof(text), "Tier 2 Cost: %3.3f", Tier2Cost[client]);
	DrawPanelText(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Weapons_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				ItemName[client] = "autoshotgun";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 2:
			{
				ItemName[client] = "shotgun_spas";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 3:
			{
				ItemName[client] = "rifle";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 4:
			{
				ItemName[client] = "rifle_ak47";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 5:
			{
				ItemName[client] = "rifle_desert";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 6:
			{
				ItemName[client] = "rifle_sg552";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 7:
			{
				ItemName[client] = "sniper_awp";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 8:
			{
				ItemName[client] = "sniper_military";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			case 9:
			{
				ItemName[client] = "hunting_rifle";
				PurchaseItem[client] = 1;
				SurvivorPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_HealthMenu (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "Health Menu", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], SurvivorPoints[client], SurvivorTeamPoints);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Medical Pack");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Pain Killers");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Adrenaline");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Instant Heal");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Incap Protection");
	DrawPanelItem(menu, text);
	
	Format(text, sizeof(text), "Health Item Cost: %3.3f", HealthItemCost[client]);
	DrawPanelText(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_HealthMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				ItemName[client] = "first_aid_kit";
				PurchaseItem[client] = 2;
				SurvivorPurchaseFunc(client);
			}
			case 2:
			{
				ItemName[client] = "pain_pills";
				PurchaseItem[client] = 2;
				SurvivorPurchaseFunc(client);
			}
			case 3:
			{
				ItemName[client] = "adrenaline";
				PurchaseItem[client] = 2;
				SurvivorPurchaseFunc(client);
			}
			case 4:
			{
				if (Ensnared[client] && IsIncapacitated(client))
				{
					PrintToChat(client, "%s \x01You are ensnared and incapped! Healing would kill you!", ERROR_INFO);
					return;
				}
				ItemName[client] = "health";
				PurchaseItem[client] = 2;
				SurvivorPurchaseFunc(client);
			}
			case 5:
			{
				if (IncapProtection[client] == -1)
				{
					PrintToChat(client, "%s \x01Incap Protection is on cooldown.", ERROR_INFO);
					return;
				}
				if (IncapProtection[client] > 0)
				{
					PrintToChat(client, "%s \x01still have \x05%d \x01uses remaining.", ERROR_INFO, IncapProtection[client]);
					return;
				}
				ItemName[client] = "incap_protection";
				PurchaseItem[client] = 2;
				SurvivorPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Abilities (client)
{
	new Handle:menu = CreatePanel();
	
	new String:Pct[32];
	Format(Pct, sizeof(Pct), "%");
	new String:text[64];
	Format(text, sizeof(text), "Personal Abilities Menu", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], SurvivorPoints[client], SurvivorTeamPoints);
	DrawPanelText(menu, text);
	Format(text, sizeof(text), "Respawn (Saferoom)");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Respawn (Corpse)");
	DrawPanelItem(menu, text);
	if (!Scout[client]) Format(text, sizeof(text), "Scout (Detects Enemies)");
	else Format(text, sizeof(text), "Scout (Purchased)");
	DrawPanelItem(menu, text);
	if (HazmatBoots[client] < 1) Format(text, sizeof(text), "Hazmat Boots (Non-stick)");
	else Format(text, sizeof(text), "Hazmat Boots (%d%s condition)", HazmatBoots[client], Pct);
	DrawPanelItem(menu, text);
	if (EyeGoggles[client] < 1) Format(text, sizeof(text), "Eye Goggles (No-Blind)");
	else Format(text, sizeof(text), "Eye Goggles (%d%s condition)", EyeGoggles[client], Pct);
	DrawPanelItem(menu, text);
	if (GravityBoots[client] < 1) Format(text, sizeof(text), "Gravity Boots (HI-Jump)");
	else Format(text, sizeof(text), "Gravity Boots (%d%s condition)", GravityBoots[client], Pct);
	DrawPanelItem(menu, text);
	
	Format(text, sizeof(text), "Personal Abilities Cost: %3.3f", PersonalAbilitiesCost[client]);
	DrawPanelText(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Abilities_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (IsPlayerAlive(client)) return;
				if (VipName == client)
				{
					PrintToChat(client, "%s \x01You were the VIP... You are gone, forever.", ERROR_INFO);
					return;
				}
				if (OnDrugs[client])
				{
					PrintToChat(client, "%s \x01You had a drug addiction... This is the \x04REAL \x01death.", ERROR_INFO);
					return;
				}
				ItemName[client] = "respawn_saferoom";
				PurchaseItem[client] = 3;
				SurvivorPurchaseFunc(client);
			}
			case 2:
			{
				if (IsPlayerAlive(client)) return;
				if (VipName == client)
				{
					PrintToChat(client, "%s \x01You were the VIP... You are gone, forever.", ERROR_INFO);
					return;
				}
				if (OnDrugs[client])
				{
					PrintToChat(client, "%s \x01You had a drug addiction... This is the \x04REAL \x01death.", ERROR_INFO);
					return;
				}
				if (!LocationSaved[client])
				{
					PrintToChat(client, "%s \x01No record of you dying!", INFO);
					return;
				}
				ItemName[client] = "respawn_corpse";
				PurchaseItem[client] = 3;
				SurvivorPurchaseFunc(client);
			}
			case 3:
			{
				if (Scout[client])
				{
					PrintToChat(client, "%s \x01Scout is a permanent ability!", ERROR_INFO);
					return;
				}
				ItemName[client] = "scout_ability";
				PurchaseItem[client] = 3;
				SurvivorPurchaseFunc(client);
			}
			case 4:
			{
				if (HazmatBoots[client] > 0)
				{
					PrintToChat(client, "%s \x01You already have hazmat boots!", ERROR_INFO);
					return;
				}
				ItemName[client] = "hazmat_boots";
				PurchaseItem[client] = 3;
				SurvivorPurchaseFunc(client);
			}
			case 5:
			{
				if (EyeGoggles[client] > 0)
				{
					PrintToChat(client, "%s \x01You already have eye goggles!", ERROR_INFO);
					return;
				}
				ItemName[client] = "eye_goggles";
				PurchaseItem[client] = 3;
				SurvivorPurchaseFunc(client);
			}
			case 6:
			{
				if (GravityBoots[client] > 0)
				{
					PrintToChat(client, "%s \x01You already have gravity boots!", ERROR_INFO);
					return;
				}
				ItemName[client] = "gravity_boots";
				PurchaseItem[client] = 3;
				SurvivorPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Upgrades (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Weapon Upgrades Menu", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], SurvivorPoints[client], SurvivorTeamPoints);
	DrawPanelText(menu, text);
	if (!BloatAmmoPistol[client] && !BloatAmmoSmg[client] && !BloatAmmoShotgun[client] && 
		!BloatAmmoRifle[client] && !BloatAmmoSniper[client]) Format(text, sizeof(text), "Bloat Ammo");
	else if (BloatAmmoPistol[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Pistols)", BloatAmmoAmountPistol[client]);
	else if (BloatAmmoSmg[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, SMGs)", BloatAmmoAmountSmg[client]);
	else if (BloatAmmoShotgun[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Shotguns)", BloatAmmoAmountShotgun[client]);
	else if (BloatAmmoRifle[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Rifles)", BloatAmmoAmountRifle[client]);
	else if (BloatAmmoSniper[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Snipers)", BloatAmmoAmountSniper[client]);
	DrawPanelItem(menu, text);
	if (!BlindAmmoPistol[client] && !BlindAmmoSmg[client] && !BlindAmmoShotgun[client] && 
		!BlindAmmoRifle[client] && !BlindAmmoSniper[client]) Format(text, sizeof(text), "Blind Ammo");
	else if (BlindAmmoPistol[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Pistols)", BlindAmmoAmountPistol[client]);
	else if (BlindAmmoSmg[client]) Format(text, sizeof(text), "Blind Ammo (%d left, SMGs)", BlindAmmoAmountSmg[client]);
	else if (BlindAmmoShotgun[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Shotguns)", BlindAmmoAmountShotgun[client]);
	else if (BlindAmmoRifle[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Rifles)", BlindAmmoAmountRifle[client]);
	else if (BlindAmmoSniper[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Snipers)", BlindAmmoAmountSniper[client]);
	DrawPanelItem(menu, text);
	if (!IceAmmoPistol[client] && !IceAmmoSmg[client] && !IceAmmoShotgun[client] && 
		!IceAmmoRifle[client] && !IceAmmoSniper[client]) Format(text, sizeof(text), "Ice Ammo");
	else if (IceAmmoPistol[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Pistols)", IceAmmoAmountPistol[client]);
	else if (IceAmmoSmg[client]) Format(text, sizeof(text), "Ice Ammo (%d left, SMGs)", IceAmmoAmountSmg[client]);
	else if (IceAmmoShotgun[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Shotguns)", IceAmmoAmountShotgun[client]);
	else if (IceAmmoRifle[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Rifles)", IceAmmoAmountRifle[client]);
	else if (IceAmmoSniper[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Snipers)", IceAmmoAmountSniper[client]);
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] < GetConVarInt(HealAmmoLevel)) Format(text, sizeof(text), "Heal Ammo (Unlocks at Physical Lv.%d)", GetConVarInt(HealAmmoLevel));
	else if (HealAmmoDisabled[client]) Format(text, sizeof(text), "Heal Ammo (%3.1f sec(s) Cooldown)", (GetConVarFloat(HealAmmoCooldown) - HealAmmoCounter[client]));
	else
	{
		if (!HealAmmoPistol[client] && !HealAmmoSmg[client] && !HealAmmoShotgun[client] && 
			!HealAmmoRifle[client] && !HealAmmoSniper[client]) Format(text, sizeof(text), "Heal Ammo");
		else if (HealAmmoPistol[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Pistols)", HealAmmoAmountPistol[client]);
		else if (HealAmmoSmg[client]) Format(text, sizeof(text), "Heal Ammo (%d left, SMGs)", HealAmmoAmountSmg[client]);
		else if (HealAmmoShotgun[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Shotguns)", HealAmmoAmountShotgun[client]);
		else if (HealAmmoRifle[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Rifles)", HealAmmoAmountRifle[client]);
		else if (HealAmmoSniper[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Snipers)", HealAmmoAmountSniper[client]);
	}
	DrawPanelItem(menu, text);
	
	Format(text, sizeof(text), "Weapon Upgrade Cost: %3.3f", WeaponUpgradeCost[client]);
	DrawPanelText(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Upgrades_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (BloatAmmoPistol[client] || BloatAmmoSmg[client] || BloatAmmoShotgun[client] || 
					BloatAmmoRifle[client] || BloatAmmoSniper[client]) return;
				ItemName[client] = "bloat_ammo";
				PurchaseItem[client] = 4;
				SurvivorPurchaseFunc(client);
			}
			case 2:
			{
				if (BlindAmmoPistol[client] || BlindAmmoSmg[client] || BlindAmmoShotgun[client] || 
					BlindAmmoRifle[client] || BlindAmmoSniper[client]) return;
				ItemName[client] = "blind_ammo";
				PurchaseItem[client] = 4;
				SurvivorPurchaseFunc(client);
			}
			case 3:
			{
				if (IceAmmoPistol[client] || IceAmmoSmg[client] || IceAmmoShotgun[client] || 
					IceAmmoRifle[client] || IceAmmoSniper[client]) return;
				ItemName[client] = "ice_ammo";
				PurchaseItem[client] = 4;
				SurvivorPurchaseFunc(client);
			}
			case 4:
			{
				if (PhysicalLevel[client] < GetConVarInt(HealAmmoLevel)) return;
				if (HealAmmoDisabled[client]) return;
				if (HealAmmoPistol[client] || HealAmmoSmg[client] || HealAmmoShotgun[client] || 
					HealAmmoRifle[client] || HealAmmoSniper[client]) return;
				ItemName[client] = "heal_ammo";
				PurchaseItem[client] = 4;
				SurvivorPurchaseFunc(client);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Challenge_Board (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "Challenge Board", client);
	SetPanelTitle(menu, text);
	if (GetClientTeam(client) == 2)
	{
		Format(text, sizeof(text), "Survivor Challenges");
		DrawPanelText(menu, text);
		Format(text, sizeof(text), "Kills:        %d / %d , held by %s , value: %d XP", RoundKills[client], MapBestKills, MapBestKillsName, RoundToFloor(MapBestKills * GetConVarFloat(MapKillsXPEach)));
		DrawPanelText(menu, text);
		Format(text, sizeof(text), "Damage:   %d / %d , held by %s , value: %d XP", RoundSurvivorDamage[client], MapBestSurvivorDamage, MapBestSurvivorDamageName, RoundToFloor(MapBestSurvivorDamage * GetConVarFloat(MapSurvivorDamageXPEach)));
		DrawPanelText(menu, text);
		Format(text, sizeof(text), "Headshots: %d / %d , held by %s , value: %d XP", RoundHS[client], MapBestSurvivorHS, MapBestSurvivorHSName, RoundToFloor(MapBestSurvivorHS * GetConVarFloat(MapKillsXPEach)));
		DrawPanelText(menu, text);
		Format(text, sizeof(text), "Medic!    %d / %d , held by %s , value: %d XP", RoundHealing[client], MapBestHealing, MapBestHealingName, RoundToFloor(MapBestHealing * GetConVarFloat(MapHealingXPEach)));
		DrawPanelText(menu, text);
		Format(text, sizeof(text), "Savior:    %d / %d , held by %s , value: %d XP", RoundRescuer[client], MapBestRescuer, MapBestRescuerName, RoundToFloor(MapBestRescuer * GetConVarFloat(MapRescuerXPEach)));
		DrawPanelText(menu, text);
		if (!IsClientIndexOutOfRange(VipName) && IsClientInGame(VipName) && !IsFakeClient(VipName))
		{
			if (IsPlayerAlive(VipName)) Format(text, sizeof(text), "Protect The Survivor VIP: %N , worth: %d XP", VipName, VipExperience);
			else Format(text, sizeof(text), "Your VIP was Killed!");
			DrawPanelText(menu, text);
		}
	}
	else if (GetClientTeam(client) == 3)
	{
		Format(text, sizeof(text), "Infected Challenges");
		DrawPanelText(menu, text);
		Format(text, sizeof(text), "Damage:   %d / %d , held by %s , value: %d XP", RoundDamage[client], MapBestInfectedDamage, MapBestInfectedDamageName, RoundToFloor(MapBestInfectedDamage * GetConVarFloat(MapDamageXPEach)));
		DrawPanelText(menu, text);
		new count = 0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientIndexOutOfRange(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 3) continue;
			// If this survivor isn't the nemesis of an attacker, ignore them.
			if (!StrEqual(Nemesis[client], Nemesis[i])) continue;
			count++;
		}
		if (!StrEqual(Nemesis[client], "killed") && 
			!StrEqual(Nemesis[client], "revenge") && 
			!StrEqual(Nemesis[client], "none")) Format(text, sizeof(text), "Your Nemesis: %s , worth : %d XP (%d class XP)", NemesisName[client], (GetConVarInt(NemesisAward) * count), ((GetConVarInt(NemesisAward) * count)/2));
		else if (StrEqual(Nemesis[client], "killed")) Format(text, sizeof(text), "Your Nemesis, %s , was killed...", NemesisName[client]);
		else if (StrEqual(Nemesis[client], "revenge")) Format(text, sizeof(text), "You killed your Nemesis, %s!", NemesisName[client]);
		else if (StrEqual(Nemesis[client], "none")) Format(text, sizeof(text), "You have no Nemesis...");
		DrawPanelText(menu, text);
		if (!IsClientIndexOutOfRange(VipName) && IsClientInGame(VipName) && !IsFakeClient(VipName))
		{
			if (IsPlayerAlive(VipName)) Format(text, sizeof(text), "Kill The Survivor VIP: %N , worth : %d XP", VipName, VipExperience);
			else Format(text, sizeof(text), "The Survivor VIP was Killed!");
			DrawPanelText(menu, text);
		}
	}
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Challenge_Board_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				if (GetClientTeam(client) == 2) SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
				else SendPanelToClient(Infected_MainMenu(client), client, Infected_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_Ammo (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[128];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	Format(text, sizeof(text), "Sky Points: %d\nYour Points: %3.2f\nTeam Points: %3.2f", SkyPoints[client], SurvivorPoints[client], SurvivorTeamPoints);
	DrawPanelText(menu, text);
	if (!BloatAmmoPistol[client] && !BloatAmmoSmg[client] && !BloatAmmoShotgun[client] && 
		!BloatAmmoRifle[client] && !BloatAmmoSniper[client]) Format(text, sizeof(text), "Bloat Ammo");
	else if (BloatAmmoPistol[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Pistols)", BloatAmmoAmountPistol[client]);
	else if (BloatAmmoSmg[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, SMGs)", BloatAmmoAmountSmg[client]);
	else if (BloatAmmoShotgun[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Shotguns)", BloatAmmoAmountShotgun[client]);
	else if (BloatAmmoRifle[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Rifles)", BloatAmmoAmountRifle[client]);
	else if (BloatAmmoSniper[client]) Format(text, sizeof(text), "Bloat Ammo (%d left, Snipers)", BloatAmmoAmountSniper[client]);
	DrawPanelItem(menu, text);
	if (!BlindAmmoPistol[client] && !BlindAmmoSmg[client] && !BlindAmmoShotgun[client] && 
		!BlindAmmoRifle[client] && !BlindAmmoSniper[client]) Format(text, sizeof(text), "Blind Ammo");
	else if (BlindAmmoPistol[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Pistols)", BlindAmmoAmountPistol[client]);
	else if (BlindAmmoSmg[client]) Format(text, sizeof(text), "Blind Ammo (%d left, SMGs)", BlindAmmoAmountSmg[client]);
	else if (BlindAmmoShotgun[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Shotguns)", BlindAmmoAmountShotgun[client]);
	else if (BlindAmmoRifle[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Rifles)", BlindAmmoAmountRifle[client]);
	else if (BlindAmmoSniper[client]) Format(text, sizeof(text), "Blind Ammo (%d left, Snipers)", BlindAmmoAmountSniper[client]);
	DrawPanelItem(menu, text);
	if (!IceAmmoPistol[client] && !IceAmmoSmg[client] && !IceAmmoShotgun[client] && 
		!IceAmmoRifle[client] && !IceAmmoSniper[client]) Format(text, sizeof(text), "Ice Ammo");
	else if (IceAmmoPistol[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Pistols)", IceAmmoAmountPistol[client]);
	else if (IceAmmoSmg[client]) Format(text, sizeof(text), "Ice Ammo (%d left, SMGs)", IceAmmoAmountSmg[client]);
	else if (IceAmmoShotgun[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Shotguns)", IceAmmoAmountShotgun[client]);
	else if (IceAmmoRifle[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Rifles)", IceAmmoAmountRifle[client]);
	else if (IceAmmoSniper[client]) Format(text, sizeof(text), "Ice Ammo (%d left, Snipers)", IceAmmoAmountSniper[client]);
	DrawPanelItem(menu, text);
	if (PhysicalLevel[client] < GetConVarInt(HealAmmoLevel)) Format(text, sizeof(text), "Heal Ammo (Unlocks at Physical Lv.%d)", GetConVarInt(HealAmmoLevel));
	else if (HealAmmoDisabled[client]) Format(text, sizeof(text), "Heal Ammo (%3.1f sec(s) Cooldown)", (GetConVarFloat(HealAmmoCooldown) - HealAmmoCounter[client]));
	else
	{
		if (!HealAmmoPistol[client] && !HealAmmoSmg[client] && !HealAmmoShotgun[client] && 
			!HealAmmoRifle[client] && !HealAmmoSniper[client]) Format(text, sizeof(text), "Heal Ammo");
		else if (HealAmmoPistol[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Pistols)", HealAmmoAmountPistol[client]);
		else if (HealAmmoSmg[client]) Format(text, sizeof(text), "Heal Ammo (%d left, SMGs)", HealAmmoAmountSmg[client]);
		else if (HealAmmoShotgun[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Shotguns)", HealAmmoAmountShotgun[client]);
		else if (HealAmmoRifle[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Rifles)", HealAmmoAmountRifle[client]);
		else if (HealAmmoSniper[client]) Format(text, sizeof(text), "Heal Ammo (%d left, Snipers)", HealAmmoAmountSniper[client]);
	}
	DrawPanelItem(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_Ammo_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (BloatAmmoPistol[client] || BloatAmmoSmg[client] || BloatAmmoShotgun[client] || 
					BloatAmmoRifle[client] || BloatAmmoSniper[client]) return;
				ItemName[client] = "bloat_ammo";
				SetAmmoType(client);
			}
			case 2:
			{
				if (BlindAmmoPistol[client] || BlindAmmoSmg[client] || BlindAmmoShotgun[client] || 
					BlindAmmoRifle[client] || BlindAmmoSniper[client]) return;
				ItemName[client] = "blind_ammo";
				SetAmmoType(client);
			}
			case 3:
			{
				if (IceAmmoPistol[client] || IceAmmoSmg[client] || IceAmmoShotgun[client] || 
					IceAmmoRifle[client] || IceAmmoSniper[client]) return;
				ItemName[client] = "ice_ammo";
				SetAmmoType(client);
			}
			case 4:
			{
				if (PhysicalLevel[client] < GetConVarInt(HealAmmoLevel)) return;
				if (HealAmmoDisabled[client]) return;
				if (HealAmmoPistol[client] || HealAmmoSmg[client] || HealAmmoShotgun[client] || 
					HealAmmoRifle[client] || HealAmmoSniper[client]) return;
				ItemName[client] = "heal_ammo";
				SetAmmoType(client);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

SetAmmoType(client)
{
	new String:WeaponUsed[64];
	GetClientWeapon(client, WeaponUsed, sizeof(WeaponUsed));
	if (StrEqual(WeaponUsed, "weapon_pistol", true) || 
		StrEqual(WeaponUsed, "weapon_pistol_magnum", true))
	{
		if (IceAmmoPistol[client] || BlindAmmoPistol[client] || HealAmmoPistol[client] || 
			BloatAmmoPistol[client]) return;
		if (StrEqual(ItemName[client], "bloat_ammo", false))
		{
			BloatAmmoPistol[client] = true;
			BloatAmmoAmountPistol[client] = GetConVarInt(BloatAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "blind_ammo", false))
		{
			BlindAmmoPistol[client] = true;
			BlindAmmoAmountPistol[client] = GetConVarInt(BlindAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "ice_ammo", false))
		{
			IceAmmoPistol[client] = true;
			IceAmmoAmountPistol[client] = GetConVarInt(IceAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "heal_ammo", false))
		{
			HealAmmoPistol[client] = true;
			HealAmmoAmountPistol[client] = GetConVarInt(HealAmmoAmount);
		}
	}
	else if (StrEqual(WeaponUsed, "weapon_smg", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_silenced", true) || 
			 StrEqual(WeaponUsed, "weapon_smg_mp5", true))
	{
		if (IceAmmoSmg[client] || BlindAmmoSmg[client] || HealAmmoSmg[client] || 
			BloatAmmoSmg[client]) return;
		if (StrEqual(ItemName[client], "bloat_ammo", false))
		{
			BloatAmmoSmg[client] = true;
			BloatAmmoAmountSmg[client] = GetConVarInt(BloatAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "blind_ammo", false))
		{
			BlindAmmoSmg[client] = true;
			BlindAmmoAmountSmg[client] = GetConVarInt(BlindAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "ice_ammo", false))
		{
			IceAmmoSmg[client] = true;
			IceAmmoAmountSmg[client] = GetConVarInt(IceAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "heal_ammo", false))
		{
			HealAmmoSmg[client] = true;
			HealAmmoAmountSmg[client] = GetConVarInt(HealAmmoAmount);
		}
	}
	else if (StrEqual(WeaponUsed, "weapon_autoshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_pumpshotgun", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) || 
			 StrEqual(WeaponUsed, "weapon_shotgun_spas", true))
	{
		if (IceAmmoShotgun[client] || BlindAmmoShotgun[client] || HealAmmoShotgun[client] || 
			BloatAmmoShotgun[client]) return;
		if (StrEqual(ItemName[client], "bloat_ammo", false))
		{
			BloatAmmoShotgun[client] = true;
			BloatAmmoAmountShotgun[client] = GetConVarInt(BloatAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "blind_ammo", false))
		{
			BlindAmmoShotgun[client] = true;
			BlindAmmoAmountShotgun[client] = GetConVarInt(BlindAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "ice_ammo", false))
		{
			IceAmmoShotgun[client] = true;
			IceAmmoAmountShotgun[client] = GetConVarInt(IceAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "heal_ammo", false))
		{
			HealAmmoShotgun[client] = true;
			HealAmmoAmountShotgun[client] = GetConVarInt(HealAmmoAmount);
		}
	}
	else if (StrEqual(WeaponUsed, "weapon_rifle", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_ak47", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_desert", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_m60", true) || 
			 StrEqual(WeaponUsed, "weapon_rifle_sg552", true))
	{
		if (IceAmmoRifle[client] || BlindAmmoRifle[client] || HealAmmoRifle[client] || 
			BloatAmmoRifle[client]) return;
		if (StrEqual(ItemName[client], "bloat_ammo", false))
		{
			BloatAmmoRifle[client] = true;
			BloatAmmoAmountRifle[client] = GetConVarInt(BloatAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "blind_ammo", false))
		{
			BlindAmmoRifle[client] = true;
			BlindAmmoAmountRifle[client] = GetConVarInt(BlindAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "ice_ammo", false))
		{
			IceAmmoRifle[client] = true;
			IceAmmoAmountRifle[client] = GetConVarInt(IceAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "heal_ammo", false))
		{
			HealAmmoRifle[client] = true;
			HealAmmoAmountRifle[client] = GetConVarInt(HealAmmoAmount);
		}
	}
	else if (StrEqual(WeaponUsed, "weapon_sniper_awp", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_military", true) || 
			 StrEqual(WeaponUsed, "weapon_sniper_scout", true) || 
			 StrEqual(WeaponUsed, "weapon_hunting_rifle", true))
	{
		if (IceAmmoSniper[client] || BlindAmmoSniper[client] || HealAmmoSniper[client] || 
			BloatAmmoSniper[client]) return;
		if (StrEqual(ItemName[client], "bloat_ammo", false))
		{
			BloatAmmoSniper[client] = true;
			BloatAmmoAmountSniper[client] = GetConVarInt(BloatAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "blind_ammo", false))
		{
			BlindAmmoSniper[client] = true;
			BlindAmmoAmountSniper[client] = GetConVarInt(BlindAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "ice_ammo", false))
		{
			IceAmmoSniper[client] = true;
			IceAmmoAmountSniper[client] = GetConVarInt(IceAmmoAmount);
		}
		else if (StrEqual(ItemName[client], "heal_ammo", false))
		{
			HealAmmoSniper[client] = true;
			HealAmmoAmountSniper[client] = GetConVarInt(HealAmmoAmount);
		}
	}
}