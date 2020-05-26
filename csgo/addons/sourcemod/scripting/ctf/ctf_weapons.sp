public Action CMD_Guns(int client, int args)
{
	b_AutoGiveWeapons[client] = false;
	ShowMainMenu(client);
	return Plugin_Handled;
}

public Action CTF_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, ShowMenu, client);
	RemoveBomb_PlayerSpawn(client);
}

public Action ShowMenu(Handle tmr, any client)
{
	
	if(b_AutoGiveWeapons[client])
	{
		GivePlayerItem(client, g_LastPrimaryWeapon[client]);
		GivePlayerItem(client, g_LastSecondaryWeapon[client]);
	} else {
		RemoveAllWeapons(client, false);
		ShowMainMenu(client);
	}
	//ShowPrimaryWeaponMenu(client);
}

void ShowMainMenu(int client)
{
	Menu menu = new Menu(MenuHandlers_MainMenu);
	SetMenuTitle(menu, "Weapon menu");
	
	menu.AddItem("new", 			"New weapons");
	if(StrContains(g_LastPrimaryWeapon[client], "weapon_") != -1 && StrContains(g_LastSecondaryWeapon[client], "weapon_") != -1 )
	{
		menu.AddItem("last", 			"Last weapons");
		menu.AddItem("lastf", 			"Last weapons all the time");
	} else {
		menu.AddItem("", "Last weapons", ITEMDRAW_DISABLED);
		menu.AddItem("", "Last weapons all the time", ITEMDRAW_DISABLED);
	}
	menu.AddItem("random", 			"Random weapons");
	
	SetMenuExitButton(menu, true);
	menu.Display(client, 0);
}

public int MenuHandlers_MainMenu(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));

			if(!IsPlayerAlive(client))
				return;
			
			if(StrEqual(info, "new"))
			{
				ShowPrimaryWeaponMenu(client);
				return;
			}
			
			else if(StrEqual(info, "last"))
			{
				if(!HasWeapon(client))
				{
					GivePlayerItem(client, g_LastPrimaryWeapon[client]);
					GivePlayerItem(client, g_LastSecondaryWeapon[client]);
				}
				return;
			}
			
			else if(StrEqual(info, "lastf"))
			{
				if(!HasWeapon(client))
				{
					GivePlayerItem(client, g_LastPrimaryWeapon[client]);
					GivePlayerItem(client, g_LastSecondaryWeapon[client]);
				}
				b_AutoGiveWeapons[client] = true;
				return;
			}

			else if(StrEqual(info, "random"))
			{
				if(!HasWeapon(client))
				{
					GiveRandomPrimary(client);
					GiveRandomSecondary(client);
				}
				return;
			}

		}
	}
}



void ShowPrimaryWeaponMenu(int client)
{
	Menu menu = new Menu(MenuHandlers_PrimaryWeapon);
	SetMenuTitle(menu, "Primary weapon");
	
	menu.AddItem("weapon_ak47", 			"AK-47");
	menu.AddItem("weapon_aug", 				"AUG");
	menu.AddItem("weapon_famas", 			"Famas");
	menu.AddItem("weapon_galilar", 			"Gallil");
	menu.AddItem("weapon_m4a1", 			"M4A1");
	menu.AddItem("weapon_mac10", 			"MAC10");
	menu.AddItem("weapon_mp7", 				"MP7");
	menu.AddItem("weapon_mp9", 				"MP9");
	//menu.AddItem("weapon_awp", 				"AWP");
	menu.AddItem("weapon_sg556", 			"SG556");
	menu.AddItem("weapon_ssg08", 			"Scout");
	menu.AddItem("weapon_ump45", 			"UPM-45");
	menu.AddItem("weapon_m4a1_silencer", 	"M4A1-S");
	
	SetMenuExitButton(menu, false);
	menu.Display(client, 0);
}

public int MenuHandlers_PrimaryWeapon(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			if(!IsPlayerAlive(client))
				return;
			
			if(!HasWeapon(client))
				GivePlayerItem(client, info);
			
			g_LastPrimaryWeapon[client] = info;
			
			Menu menu2 = new Menu(MenuHandlers_SecondaryWeapon);
			SetMenuTitle(menu, "Secondary weapon");
			menu2.AddItem("weapon_deagle", 		"Deagle");
			menu2.AddItem("weapon_revolver", 	"Revolver");
			menu2.AddItem("weapon_elite", 		"Dual burretas");
			menu2.AddItem("weapon_fiveseven",	"Five seven");
			menu2.AddItem("weapon_glock", 		"Glock");
			menu2.AddItem("weapon_hkp2000", 	"USP");
			menu2.AddItem("weapon_p250", 		"P250");
			menu2.AddItem("weapon_tec9", 		"TEC-9");
			SetMenuExitButton(menu2, false);
			menu2.Display(client, 0);
			
		}
	}
}

public int MenuHandlers_SecondaryWeapon(Menu menu2, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(!IsPlayerAlive(client))
				return;
				
			char info[32];
			GetMenuItem(menu2, item, info, sizeof(info));
			if(!HasWeapon(client, true))
				GivePlayerItem(client, info);
			
			g_LastSecondaryWeapon[client] = info;
		}
	}
}

void GiveRandomPrimary(int client)
{
	int primary = GetRandomInt(0, 22);
	GivePlayerItem(client, PrimaryWeapon[primary]);
	g_LastPrimaryWeapon[client] = PrimaryWeapon[primary];
}

void GiveRandomSecondary(int client)
{
	int secondary = GetRandomInt(0, 8);
	GivePlayerItem(client, SecondaryWeapon[secondary]);	
	g_LastSecondaryWeapon[client] = SecondaryWeapon[secondary];
}

public void RemoveAllWeapons(int client, bool RemoveKnife)
{
	
	//Primary weapon check
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if(weapon > 0) {
		RemovePlayerItem(client, weapon);
		RemoveEdict(weapon);
	}
	
	//Secondary
	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(weapon2 > 0) {
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);
	}
	
	//Grenade
	int weapon3 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon3 > 0) {
		RemovePlayerItem(client, weapon3);
		RemoveEdict(weapon3);
	}
	
	//Grenade
	int weapon4 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon4 > 0) {
		RemovePlayerItem(client, weapon4);
		RemoveEdict(weapon4);
	}
	
	if(RemoveKnife)
	{
		int weapon5 = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
		if(weapon5 > 0) {
			RemovePlayerItem(client, weapon5);
			RemoveEdict(weapon5);
		}	
	}
	
}

bool HasWeapon(int client, bool Secondary = false)
{
	if(Secondary)
	{
		int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		if(weapon2 > 0)
			return true;
		else
			return false;
			
	} else {
	
		int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
		int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		if(weapon > 0 || weapon2 > 0)
			return true;
		else
			return false;
		
	}

}