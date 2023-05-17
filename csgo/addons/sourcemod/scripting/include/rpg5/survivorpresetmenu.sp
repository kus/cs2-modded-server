public Handle:Customize_Settings (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Statistics Page", client);
	SetPanelTitle(menu, text);

	if (PhysicalLevel[client] < GetConVarInt(UnlockPresetLevel[0])) Format(text, sizeof(text), "Preset 1 (Unlocks at Physical Lv.%d)", GetConVarInt(UnlockPresetLevel[0]));
	else Format(text, sizeof(text), "Preset 1 (%s)", PrimaryPreset1[client]);
	DrawPanelItem(menu, text);
	
	if (PhysicalLevel[client] < GetConVarInt(UnlockPresetLevel[1])) Format(text, sizeof(text), "Preset 2 (Unlocks at Physical Lv.%d)", GetConVarInt(UnlockPresetLevel[1]));
	else Format(text, sizeof(text), "Preset 2 (%s)", PrimaryPreset2[client]);
	DrawPanelItem(menu, text);

	if (PhysicalLevel[client] < GetConVarInt(UnlockPresetLevel[2])) Format(text, sizeof(text), "Preset 3 (Unlocks at Physical Lv.%d)", GetConVarInt(UnlockPresetLevel[2]));
	else Format(text, sizeof(text), "Preset 3 (%s)", PrimaryPreset3[client]);
	DrawPanelItem(menu, text);

	if (Preset4[client] == 0) Format(text, sizeof(text), "Preset 4 (Buy in the Sky Store!)");
	else Format(text, sizeof(text), "Preset 4 (%s)", PrimaryPreset4[client]);
	DrawPanelItem(menu, text);

	if (Preset5[client] == 0) Format(text, sizeof(text), "Preset 5 (Buy in the Sky Store!)");
	else Format(text, sizeof(text), "Preset 5 (%s)", PrimaryPreset5[client]);
	DrawPanelItem(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Customize_Settings_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (PhysicalLevel[client] < GetConVarInt(UnlockPresetLevel[0])) return;
				PresetViewer[client] = 0;
				SendPanelToClient(Survivor_PresetMenu(client), client, Survivor_PresetMenu_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (PhysicalLevel[client] < GetConVarInt(UnlockPresetLevel[1])) return;
				PresetViewer[client] = 1;
				SendPanelToClient(Survivor_PresetMenu(client), client, Survivor_PresetMenu_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (PhysicalLevel[client] < GetConVarInt(UnlockPresetLevel[2])) return;
				PresetViewer[client] = 2;
				SendPanelToClient(Survivor_PresetMenu(client), client, Survivor_PresetMenu_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (Preset4[client] == 0) return;
				PresetViewer[client] = 3;
				SendPanelToClient(Survivor_PresetMenu(client), client, Survivor_PresetMenu_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				if (Preset4[client] == 0) return;
				PresetViewer[client] = 4;
				SendPanelToClient(Survivor_PresetMenu(client), client, Survivor_PresetMenu_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

// For the preset layout, we give the player 4 lines describing what they currently have saved in each slot
// And then 6 options. 4 to change those slots, and 1 to save, and 1 to load.

public Handle:Survivor_PresetMenu (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Statistics Page", client);
	SetPanelTitle(menu, text);

	if (PresetViewer[client] == 0) Format(text, sizeof(text), "Primary Weapon: %s", PrimaryPreset1[client]);
	else if (PresetViewer[client] == 1) Format(text, sizeof(text), "Primary Weapon: %s", PrimaryPreset2[client]);
	else if (PresetViewer[client] == 2) Format(text, sizeof(text), "Primary Weapon: %s", PrimaryPreset3[client]);
	else if (PresetViewer[client] == 3) Format(text, sizeof(text), "Primary Weapon: %s", PrimaryPreset4[client]);
	else if (PresetViewer[client] == 4) Format(text, sizeof(text), "Primary Weapon: %s", PrimaryPreset5[client]);
	DrawPanelText(menu, text);
	if (PresetViewer[client] == 0) Format(text, sizeof(text), "Secondary Weapon: %s", SecondaryPreset1[client]);
	else if (PresetViewer[client] == 1) Format(text, sizeof(text), "Secondary Weapon: %s", SecondaryPreset2[client]);
	else if (PresetViewer[client] == 2) Format(text, sizeof(text), "Secondary Weapon: %s", SecondaryPreset3[client]);
	else if (PresetViewer[client] == 3) Format(text, sizeof(text), "Secondary Weapon: %s", SecondaryPreset4[client]);
	else if (PresetViewer[client] == 4) Format(text, sizeof(text), "Secondary Weapon: %s", SecondaryPreset5[client]);
	DrawPanelText(menu, text);
	if (PresetViewer[client] == 0) Format(text, sizeof(text), "Health Item: %s", Option1Preset1[client]);
	else if (PresetViewer[client] == 1) Format(text, sizeof(text), "Health Item: %s", Option1Preset2[client]);
	else if (PresetViewer[client] == 2) Format(text, sizeof(text), "Health Item: %s", Option1Preset3[client]);
	else if (PresetViewer[client] == 3) Format(text, sizeof(text), "Health Item: %s", Option1Preset4[client]);
	else if (PresetViewer[client] == 4) Format(text, sizeof(text), "Health Item: %s", Option1Preset5[client]);
	DrawPanelText(menu, text);
	if (PresetViewer[client] == 0) Format(text, sizeof(text), "Grenade: %s", Option2Preset1[client]);
	else if (PresetViewer[client] == 1) Format(text, sizeof(text), "Grenade: %s", Option2Preset2[client]);
	else if (PresetViewer[client] == 2) Format(text, sizeof(text), "Grenade: %s", Option2Preset3[client]);
	else if (PresetViewer[client] == 3) Format(text, sizeof(text), "Grenade: %s", Option2Preset4[client]);
	else if (PresetViewer[client] == 4) Format(text, sizeof(text), "Grenade: %s", Option2Preset5[client]);
	DrawPanelText(menu, text);

	Format(text, sizeof(text), "Set Primary Weapon");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Set Secondary Weapon");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Set Health Item");
	DrawPanelItem(menu, text);
	Format(text, sizeof(text), "Set Grenades");
	DrawPanelItem(menu, text);

	Format(text, sizeof(text), "Load This Preset");
	DrawPanelItem(menu, text);
	
	DrawPanelItem(menu, "Main Menu");
	return menu;
}

public Survivor_PresetMenu_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Survivor_SetPrimary(client), client, Survivor_SetPrimary_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				SendPanelToClient(Survivor_SetSecondary(client), client, Survivor_SetSecondary_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				SendPanelToClient(Survivor_SetItem(client), client, Survivor_SetItem_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				SendPanelToClient(Survivor_SetGrenade(client), client, Survivor_SetGrenade_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				LoadPresets(client);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetPrimary (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	SetPanelTitle(menu, "Equipment Locker");
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
	
	return menu;
}

public Survivor_SetPrimary_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (PhysicalLevel[client] >= GetConVarInt(UziLevelUnlock)) SendPanelToClient(Survivor_SetUzis(client), client, Survivor_SetUzis_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (PhysicalLevel[client] >= GetConVarInt(ShotgunLevelUnlock)) SendPanelToClient(Survivor_SetShotgun(client), client, Survivor_SetShotgun_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (PhysicalLevel[client] >= GetConVarInt(SniperLevelUnlock)) SendPanelToClient(Survivor_SetSniper(client), client, Survivor_SetSniper_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (PhysicalLevel[client] >= GetConVarInt(RifleLevelUnlock)) SendPanelToClient(Survivor_SetRifle(client), client, Survivor_SetRifle_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Survivor_MainMenu(client), client, Survivor_MainMenu_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetSecondary (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	SetPanelTitle(menu, "Equipment Locker");
	DrawPanelItem(menu, "Pistols");
	if (PhysicalLevel[client] >= GetConVarInt(MeleeLevelUnlock)) Format(text, sizeof(text), "Melee");
	else Format(text, sizeof(text), "Melee (Unlocks at Physical Lv.%d)", GetConVarInt(MeleeLevelUnlock));
	DrawPanelItem(menu, text);
	
	return menu;
}

public Survivor_SetSecondary_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				SendPanelToClient(Survivor_SetPistols(client), client, Survivor_SetPistols_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (PhysicalLevel[client] >= GetConVarInt(MeleeLevelUnlock)) SendPanelToClient(Survivor_SetMelee(client), client, Survivor_SetMelee_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetPistols (client)
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

	return menu;
}

public Survivor_SetPistols_Init (Handle:topmenu, MenuAction:action, client, param2)
{
	if (topmenu != INVALID_HANDLE) CloseHandle(topmenu);

	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (PresetViewer[client] == 0) SecondaryPreset1[client] = "pistol";
				else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "pistol";
				else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "pistol";
				else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "pistol";
				else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "pistol";
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (PistolLevel[client] >= GetConVarInt(PistolDeagleLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "pistol_magnum";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "pistol_magnum";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "pistol_magnum";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "pistol_magnum";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "pistol_magnum";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetUzis (client)
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

	return menu;
}

public Survivor_SetUzis_Init (Handle:topmenu, MenuAction:action, client, param2)
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
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "smg_mp5";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "smg_mp5";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "smg_mp5";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "smg_mp5";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "smg_mp5";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (UziLevel[client] >= GetConVarInt(UziMac10Level))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "smg";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "smg";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "smg";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "smg";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "smg";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (UziLevel[client] >= GetConVarInt(UziTmpLevel))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "smg_silenced";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "smg_silenced";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "smg_silenced";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "smg_silenced";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "smg_silenced";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetShotgun (client)
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

	return menu;
}

public Survivor_SetShotgun_Init (Handle:topmenu, MenuAction:action, client, param2)
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
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "shotgun_chrome";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "shotgun_chrome";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "shotgun_chrome";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "shotgun_chrome";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "shotgun_chrome";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (ShotgunLevel[client] >= GetConVarInt(ShotgunPumpLevel))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "pumpshotgun";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "pumpshotgun";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "pumpshotgun";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "pumpshotgun";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "pumpshotgun";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (ShotgunLevel[client] >= GetConVarInt(ShotgunSpasLevel))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "shotgun_spas";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "shotgun_spas";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "shotgun_spas";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "shotgun_spas";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "shotgun_spas";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (ShotgunLevel[client] >= GetConVarInt(ShotgunAutoLevel))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "autoshotgun";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "autoshotgun";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "autoshotgun";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "autoshotgun";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "autoshotgun";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetSniper (client)
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

	return menu;
}

public Survivor_SetSniper_Init (Handle:topmenu, MenuAction:action, client, param2)
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
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "sniper_scout";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "sniper_scout";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "sniper_scout";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "sniper_scout";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "sniper_scout";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (SniperLevel[client] >= GetConVarInt(SniperAwpLevel))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "sniper_awp";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "sniper_awp";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "sniper_awp";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "sniper_awp";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "sniper_awp";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (SniperLevel[client] >= GetConVarInt(SniperMilitaryLevel))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "sniper_military";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "sniper_military";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "sniper_military";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "sniper_military";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "sniper_military";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (SniperLevel[client] >= GetConVarInt(SniperHuntingLevel))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "hunting_rifle";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "hunting_rifle";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "hunting_rifle";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "hunting_rifle";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "hunting_rifle";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetRifle (client)
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

	return menu;
}

public Survivor_SetRifle_Init (Handle:topmenu, MenuAction:action, client, param2)
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
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "rifle_desert";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "rifle_desert";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "rifle_desert";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "rifle_desert";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "rifle_desert";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleM16Level))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "rifle";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "rifle";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "rifle";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "rifle";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "rifle";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleSG552Level))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "rifle_sg552";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "rifle_sg552";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "rifle_sg552";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "rifle_sg552";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "rifle_sg552";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleAK47Level))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "rifle_ak47";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "rifle_ak47";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "rifle_ak47";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "rifle_ak47";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "rifle_ak47";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				if (RifleLevel[client] >= GetConVarInt(RifleM60Level))
				{
					if (PresetViewer[client] == 0) PrimaryPreset1[client] = "rifle_m60";
					else if (PresetViewer[client] == 1) PrimaryPreset2[client] = "rifle_m60";
					else if (PresetViewer[client] == 2) PrimaryPreset3[client] = "rifle_m60";
					else if (PresetViewer[client] == 3) PrimaryPreset4[client] = "rifle_m60";
					else if (PresetViewer[client] == 4) PrimaryPreset5[client] = "rifle_m60";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetMelee (client)
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

	return menu;
}

public Survivor_SetMelee_Init (Handle:topmenu, MenuAction:action, client, param2)
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
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "electric_guitar";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "electric_guitar";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "electric_guitar";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "electric_guitar";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "electric_guitar";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelPanLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "frying_pan";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "frying_pan";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "frying_pan";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "frying_pan";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "frying_pan";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelCricketLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "cricket_bat";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "cricket_bat";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "cricket_bat";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "cricket_bat";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "cricket_bat";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelFireaxeLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "fireaxe";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "fireaxe";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "fireaxe";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "fireaxe";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "fireaxe";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 5:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelGolfclubLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "golfclub";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "golfclub";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "golfclub";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "golfclub";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "golfclub";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 6:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelTonfaLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "tonfa";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "tonfa";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "tonfa";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "tonfa";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "tonfa";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 7:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelChainsawLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "chainsaw";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "chainsaw";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "chainsaw";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "chainsaw";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "chainsaw";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 8:
			{
				if (MeleeLevel[client] >= GetConVarInt(MelMacheteLevel))
				{
					if (PresetViewer[client] == 0) SecondaryPreset1[client] = "machete";
					else if (PresetViewer[client] == 1) SecondaryPreset2[client] = "machete";
					else if (PresetViewer[client] == 2) SecondaryPreset3[client] = "machete";
					else if (PresetViewer[client] == 3) SecondaryPreset4[client] = "machete";
					else if (PresetViewer[client] == 4) SecondaryPreset5[client] = "machete";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetGrenade (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	
	if (GrenadeLevel[client] >= GetConVarInt(GrenPipeLevel))
	{
		Format(text, sizeof(text), "Pipe Bomb");
	}
	else Format(text, sizeof(text), "Pipe Bomb (Unlocks at Grenade Lv. %d)", GetConVarInt(GrenPipeLevel));
	DrawPanelItem(menu, text);
	
	if (GrenadeLevel[client] >= GetConVarInt(GrenJarLevel))
	{
		Format(text, sizeof(text), "Vomit Jar");
	}
	else Format(text, sizeof(text), "Vomit Jar (Unlocks at Grenade Lv. %d)", GetConVarInt(GrenJarLevel));
	DrawPanelItem(menu, text);
	
	if (GrenadeLevel[client] >= GetConVarInt(GrenMolLevel))
	{
		Format(text, sizeof(text), "Molotov");
	}
	else Format(text, sizeof(text), "Molotov (Unlocks at Grenade Lv. %d)", GetConVarInt(GrenMolLevel));
	DrawPanelItem(menu, text);

	return menu;
}

public Survivor_SetGrenade_Init (Handle:topmenu, MenuAction:action, client, param2)
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
					if (PresetViewer[client] == 0) Option2Preset1[client] = "pipe_bomb";
					else if (PresetViewer[client] == 1) Option2Preset2[client] = "pipe_bomb";
					else if (PresetViewer[client] == 2) Option2Preset3[client] = "pipe_bomb";
					else if (PresetViewer[client] == 3) Option2Preset4[client] = "pipe_bomb";
					else if (PresetViewer[client] == 4) Option2Preset5[client] = "pipe_bomb";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (GrenadeLevel[client] >= GetConVarInt(GrenJarLevel) && GrenadeCount[client] > 0)
				{
					if (PresetViewer[client] == 0) Option2Preset1[client] = "vomitjar";
					else if (PresetViewer[client] == 1) Option2Preset2[client] = "vomitjar";
					else if (PresetViewer[client] == 2) Option2Preset3[client] = "vomitjar";
					else if (PresetViewer[client] == 3) Option2Preset4[client] = "vomitjar";
					else if (PresetViewer[client] == 4) Option2Preset5[client] = "vomitjar";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (GrenadeLevel[client] >= GetConVarInt(GrenMolLevel) && GrenadeCount[client] > 0)
				{
					if (PresetViewer[client] == 0) Option2Preset1[client] = "molotov";
					else if (PresetViewer[client] == 1) Option2Preset2[client] = "molotov";
					else if (PresetViewer[client] == 2) Option2Preset3[client] = "molotov";
					else if (PresetViewer[client] == 3) Option2Preset4[client] = "molotov";
					else if (PresetViewer[client] == 4) Option2Preset5[client] = "molotov";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

public Handle:Survivor_SetItem (client)
{
	new Handle:menu = CreatePanel();
	
	new String:text[64];
	Format(text, sizeof(text), "%N Equipment Locker", client);
	SetPanelTitle(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthPillsLevel))
	{
		Format(text, sizeof(text), "Pain Killers");
	}
	else Format(text, sizeof(text), "Pain Killers (Unlocks at Health Lv. %d)", GetConVarInt(HealthPillsLevel));
	DrawPanelItem(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthPackLevel))
	{
		Format(text, sizeof(text), "Medkits");
	}
	else Format(text, sizeof(text), "Medkits (Unlocks at Health Lv. %d)", GetConVarInt(HealthPackLevel));
	DrawPanelItem(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthAdrenLevel))
	{
		Format(text, sizeof(text), "Adrenaline");
	}
	else Format(text, sizeof(text), "Adrenaline (Unlocks at Health Lv. %d)", GetConVarInt(HealthAdrenLevel));
	DrawPanelItem(menu, text);
	
	if (ItemLevel[client] >= GetConVarInt(HealthIncapLevel))
	{
		Format(text, sizeof(text), "Incap Protection");
	}
	else Format(text, sizeof(text), "Incap Protection (Unlocks at Health Lv. %d)", GetConVarInt(HealthIncapLevel));
	DrawPanelItem(menu, text);
	
	return menu;
}

public Survivor_SetItem_Init (Handle:topmenu, MenuAction:action, client, param2)
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
					if (PresetViewer[client] == 0) Option1Preset1[client] = "pain_pills";
					else if (PresetViewer[client] == 1) Option1Preset2[client] = "pain_pills";
					else if (PresetViewer[client] == 2) Option1Preset3[client] = "pain_pills";
					else if (PresetViewer[client] == 3) Option1Preset4[client] = "pain_pills";
					else if (PresetViewer[client] == 4) Option1Preset5[client] = "pain_pills";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 2:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthPackLevel) && HealCount[client] > 0)
				{
					if (PresetViewer[client] == 0) Option1Preset1[client] = "first_aid_kit";
					else if (PresetViewer[client] == 1) Option1Preset2[client] = "first_aid_kit";
					else if (PresetViewer[client] == 2) Option1Preset3[client] = "first_aid_kit";
					else if (PresetViewer[client] == 3) Option1Preset4[client] = "first_aid_kit";
					else if (PresetViewer[client] == 4) Option1Preset5[client] = "first_aid_kit";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 3:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthAdrenLevel) && TempHealCount[client] > 0)
				{
					if (PresetViewer[client] == 0) Option1Preset1[client] = "adrenaline";
					else if (PresetViewer[client] == 1) Option1Preset2[client] = "adrenaline";
					else if (PresetViewer[client] == 2) Option1Preset3[client] = "adrenaline";
					else if (PresetViewer[client] == 3) Option1Preset4[client] = "adrenaline";
					else if (PresetViewer[client] == 4) Option1Preset5[client] = "adrenaline";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			case 4:
			{
				if (ItemLevel[client] >= GetConVarInt(HealthIncapLevel) && HealCount[client] > 0)
				{
					if (PresetViewer[client] == 0) Option1Preset1[client] = "incap_protection";
					else if (PresetViewer[client] == 1) Option1Preset2[client] = "incap_protection";
					else if (PresetViewer[client] == 2) Option1Preset3[client] = "incap_protection";
					else if (PresetViewer[client] == 3) Option1Preset4[client] = "incap_protection";
					else if (PresetViewer[client] == 4) Option1Preset5[client] = "incap_protection";
				}
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
			default:
			{
				SendPanelToClient(Customize_Settings(client), client, Customize_Settings_Init, MENU_TIME_FOREVER);
			}
		}
	}
}

// Load player preset data
LoadPresets(client)
{
	if (PresetViewer[client] == 0 && !StrEqual(SecondaryPreset1[client], "none") || 
		PresetViewer[client] == 1 && !StrEqual(SecondaryPreset2[client], "none") || 
		PresetViewer[client] == 2 && !StrEqual(SecondaryPreset3[client], "none") || 
		PresetViewer[client] == 3 && !StrEqual(SecondaryPreset4[client], "none") || 
		PresetViewer[client] == 4 && !StrEqual(SecondaryPreset5[client], "none"))
	{
		L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
		if (PresetViewer[client] == 0) ExecCheatCommand(client, "give", SecondaryPreset1[client]);
		else if (PresetViewer[client] == 1) ExecCheatCommand(client, "give", SecondaryPreset2[client]);
		else if (PresetViewer[client] == 2) ExecCheatCommand(client, "give", SecondaryPreset3[client]);
		else if (PresetViewer[client] == 3) ExecCheatCommand(client, "give", SecondaryPreset4[client]);
		else if (PresetViewer[client] == 4) ExecCheatCommand(client, "give", SecondaryPreset5[client]);
	}
	if (PresetViewer[client] == 0 && !StrEqual(Option1Preset1[client], "none") || 
		PresetViewer[client] == 1 && !StrEqual(Option1Preset2[client], "none") || 
		PresetViewer[client] == 2 && !StrEqual(Option1Preset3[client], "none") || 
		PresetViewer[client] == 3 && !StrEqual(Option1Preset4[client], "none") || 
		PresetViewer[client] == 4 && !StrEqual(Option1Preset5[client], "none"))
	{
		if (PresetViewer[client] == 0 && (StrEqual(Option1Preset1[client], "pain_pills") || StrEqual(Option1Preset1[client], "adrenaline")) || 
			PresetViewer[client] == 1 && (StrEqual(Option1Preset2[client], "pain_pills") || StrEqual(Option1Preset2[client], "adrenaline")) || 
			PresetViewer[client] == 2 && (StrEqual(Option1Preset3[client], "pain_pills") || StrEqual(Option1Preset3[client], "adrenaline")) || 
			PresetViewer[client] == 3 && (StrEqual(Option1Preset4[client], "pain_pills") || StrEqual(Option1Preset4[client], "adrenaline")) || 
			PresetViewer[client] == 4 && (StrEqual(Option1Preset5[client], "pain_pills") || StrEqual(Option1Preset5[client], "adrenaline")))
		{
			if (TempHealCount[client] > 0)
			{
				L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Pills);
				TempHealCount[client]--;
				if (PresetViewer[client] == 0) ExecCheatCommand(client, "give", Option1Preset1[client]);
				else if (PresetViewer[client] == 1) ExecCheatCommand(client, "give", Option1Preset2[client]);
				else if (PresetViewer[client] == 2) ExecCheatCommand(client, "give", Option1Preset3[client]);
				else if (PresetViewer[client] == 3) ExecCheatCommand(client, "give", Option1Preset4[client]);
				else if (PresetViewer[client] == 4) ExecCheatCommand(client, "give", Option1Preset5[client]);
			}
		}
		else if (PresetViewer[client] == 0 && StrEqual(Option1Preset1[client], "first_aid_kit") || 
				 PresetViewer[client] == 1 && StrEqual(Option1Preset2[client], "first_aid_kit") || 
				 PresetViewer[client] == 2 && StrEqual(Option1Preset3[client], "first_aid_kit") || 
				 PresetViewer[client] == 3 && StrEqual(Option1Preset4[client], "first_aid_kit") || 
				 PresetViewer[client] == 4 && StrEqual(Option1Preset5[client], "first_aid_kit"))
		{
			if (HealCount[client] > 0)
			{
				L4D_RemoveWeaponSlot(client, L4DWeaponSlot_FirstAid);
				HealCount[client]--;
				if (PresetViewer[client] == 0) ExecCheatCommand(client, "give", Option1Preset1[client]);
				else if (PresetViewer[client] == 1) ExecCheatCommand(client, "give", Option1Preset2[client]);
				else if (PresetViewer[client] == 2) ExecCheatCommand(client, "give", Option1Preset3[client]);
				else if (PresetViewer[client] == 3) ExecCheatCommand(client, "give", Option1Preset4[client]);
				else if (PresetViewer[client] == 4) ExecCheatCommand(client, "give", Option1Preset5[client]);
			}
		}
		else if (PresetViewer[client] == 0 && StrEqual(Option1Preset1[client], "incap_protection") || 
				 PresetViewer[client] == 1 && StrEqual(Option1Preset2[client], "incap_protection") || 
				 PresetViewer[client] == 2 && StrEqual(Option1Preset3[client], "incap_protection") || 
				 PresetViewer[client] == 3 && StrEqual(Option1Preset4[client], "incap_protection") || 
				 PresetViewer[client] == 4 && StrEqual(Option1Preset5[client], "incap_protection"))
		{
			if (HealCount[client] > 0 && IncapProtection[client] == 0)
			{
				PrintToChat(client, "%s \x01Incap Protection Added.", INFO);
				IncapProtection[client] = GetConVarInt(IncapCount);
				HealCount[client]--;
				CreateTimer(1.0, CheckIfEnsnared, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);	
			}
		}
	}
	if (PresetViewer[client] == 0 && !StrEqual(Option2Preset1[client], "none") || 
		PresetViewer[client] == 1 && !StrEqual(Option2Preset2[client], "none") || 
		PresetViewer[client] == 2 && !StrEqual(Option2Preset3[client], "none") || 
		PresetViewer[client] == 3 && !StrEqual(Option2Preset4[client], "none") || 
		PresetViewer[client] == 4 && !StrEqual(Option2Preset5[client], "none"))
	{
		if (GrenadeCount[client] > 0)
		{
			L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Grenade);
			if (PresetViewer[client] == 0) ExecCheatCommand(client, "give", Option2Preset1[client]);
			else if (PresetViewer[client] == 1) ExecCheatCommand(client, "give", Option2Preset2[client]);
			else if (PresetViewer[client] == 2) ExecCheatCommand(client, "give", Option2Preset3[client]);
			else if (PresetViewer[client] == 3) ExecCheatCommand(client, "give", Option2Preset4[client]);
			else if (PresetViewer[client] == 4) ExecCheatCommand(client, "give", Option2Preset5[client]);
			GrenadeCount[client]--;
		}
	}

	// We give the primary last, so it's in their hands when they begin.
	// We also do this so that when ammo upgrades gets added to the preset screen
	// that the correct weapon gets the ammo added to it.

	if (PresetViewer[client] == 0 && !StrEqual(PrimaryPreset1[client], "none") || 
		PresetViewer[client] == 1 && !StrEqual(PrimaryPreset2[client], "none") || 
		PresetViewer[client] == 2 && !StrEqual(PrimaryPreset3[client], "none") || 
		PresetViewer[client] == 3 && !StrEqual(PrimaryPreset4[client], "none") || 
		PresetViewer[client] == 4 && !StrEqual(PrimaryPreset5[client], "none"))
	{
		if (PresetViewer[client] == 0 && StrEqual(PrimaryPreset1[client], "rifle_m60") || 
			PresetViewer[client] == 1 && StrEqual(PrimaryPreset2[client], "rifle_m60") || 
			PresetViewer[client] == 2 && StrEqual(PrimaryPreset3[client], "rifle_m60") || 
			PresetViewer[client] == 3 && StrEqual(PrimaryPreset4[client], "rifle_m60") || 
			PresetViewer[client] == 4 && StrEqual(PrimaryPreset5[client], "rifle_m60"))
		{
			if (M60CD[client]) return;
			M60CD[client] = true;
			M60COUNT[client] = -1.0;
			CreateTimer(1.0, EnableM60, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
		if (PresetViewer[client] == 0)
		{
			ExecCheatCommand(client, "give", PrimaryPreset1[client]);
			LastWeaponOwned[client] = PrimaryPreset1[client];
		}
		else if (PresetViewer[client] == 1)
		{
			ExecCheatCommand(client, "give", PrimaryPreset2[client]);
			LastWeaponOwned[client] = PrimaryPreset2[client];
		}
		else if (PresetViewer[client] == 2)
		{
			ExecCheatCommand(client, "give", PrimaryPreset3[client]);
			LastWeaponOwned[client] = PrimaryPreset3[client];
		}
		else if (PresetViewer[client] == 3)
		{
			ExecCheatCommand(client, "give", PrimaryPreset4[client]);
			LastWeaponOwned[client] = PrimaryPreset4[client];
		}
		else if (PresetViewer[client] == 4)
		{
			ExecCheatCommand(client, "give", PrimaryPreset5[client]);
			LastWeaponOwned[client] = PrimaryPreset5[client];
		}
		ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
	}
}