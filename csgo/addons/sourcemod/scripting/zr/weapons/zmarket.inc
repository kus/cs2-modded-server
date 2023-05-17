/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zmarket.inc
 *  Type:		  Module
 *  Description:   ZMarket module, provides menu of weapons to buy from.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/**
 * @section Name of the cookies for ZMarket rebuy/auto-rebuy data.
 */
#define ZMARKET_COOKIE_AUTOREBUY "zr_zmarket_autorebuy"
#define ZMARKET_COOKIE_REBUY "zr_zmarket_rebuy"
/**
 * @endsection
 */

/**
 * Variable to store buyzone offset value.
 */
int g_iToolsInBuyZone;

/**
 * Array to store the client's current weapon type within menu.
 */
int g_iZMarketCurType[MAXPLAYERS + 1];

/**
 * Array handle to store the amount of purchases left for a weapon.
 */
Handle g_hZMarketPurchaseCount[MAXPLAYERS + 1];

/**
 * Cookie handle for auto-rebuy.
 */
Handle g_hZMarketAutoRebuyCookie = INVALID_HANDLE;

/**
 * Whether weapons has been bought automatically. Used to prevent double rebuy
 * when cookies are loaded after the player was spawned.
 */
bool g_bZMarketWeaponsBought[MAXPLAYERS + 1];

/**
 * Cookie handle array for weapon loadouts.
 */
Handle g_hZMarketLoadoutCookie[WEAPONS_SLOTS_MAX + 1];

/**
 * Create Zmarket Gun Command Status
 */
bool g_bZMarketCommandInitialized = false;

/**
 * Create commands specific to ZMarket.
 */
void ZMarketOnCommandsCreate()
{
	// Register ZMarket command.
	RegConsoleCmd(SAYHOOKS_KEYWORD_ZMARKET, ZMarketCommand, "Opens custom buymenu.");
	
	// Hold on Register the Zmarket Gun Command
	g_bZMarketCommandInitialized = false;
}

void ZMarketOnCookiesCreate()
{
	// Create auto-rebuy cookie handle if doesn't exist.
	if (g_hZMarketAutoRebuyCookie == INVALID_HANDLE)
	{
		g_hZMarketAutoRebuyCookie = RegClientCookie(ZMARKET_COOKIE_AUTOREBUY, "The toggle state of auto-rebuy.", CookieAccess_Protected);
	}
	
	char rebuycookiename[32];
	char rebuycookiedesc[64];
	
	// x = Weapon slot.
	for (int x = 0; x < WEAPONS_SLOTS_MAX + 1; x++)
	{
		// Format cookie name and description.
		Format(rebuycookiename, sizeof(rebuycookiename), "%s_%d", ZMARKET_COOKIE_REBUY, x);
		Format(rebuycookiedesc, sizeof(rebuycookiedesc), "Current loadout weapon for slot %d", x);
		
		// Create loadout cookie handle if it doesn't exist.
		if (g_hZMarketLoadoutCookie[x] == INVALID_HANDLE)
		{
			g_hZMarketLoadoutCookie[x] = RegClientCookie(rebuycookiename, rebuycookiedesc, CookieAccess_Protected);
		}
	}
}

void ZMarketLoad()
{
	// Do not register commands multiple times
	if(g_bZMarketCommandInitialized)
		return;

	char zmarketcommand[CONFIG_MAX_LENGTH];
	char weaponname[WEAPONS_MAX_LENGTH];

	int size = GetArraySize(arrayWeapons);
	for (int weaponindex = 0; weaponindex < size; weaponindex++)
	{
		WeaponsGetZMarketCommand(weaponindex, zmarketcommand, sizeof(zmarketcommand));
		if(zmarketcommand[0])
		{
			WeaponsGetName(weaponindex, weaponname, sizeof(weaponname));

			if (FindCharInString(zmarketcommand, ',') != -1)
			{
				int idx;
				int lastidx;
				while ((idx = FindCharInString(zmarketcommand[lastidx], ',')) != -1)
				{
					char out[16];
					char fmt[8];
					Format(fmt, sizeof(fmt), "%%.%ds", idx);
					Format(out, sizeof(out), fmt, zmarketcommand[lastidx]);
					RegConsoleCmd(out, ZMarketBuyCommand, weaponname);
					lastidx += ++idx;

					if (FindCharInString(zmarketcommand[lastidx], ',') == -1 && zmarketcommand[lastidx+1] != '\0')
						RegConsoleCmd(zmarketcommand[lastidx], ZMarketBuyCommand, weaponname);
				}
			}
			else
			{
				RegConsoleCmd(zmarketcommand, ZMarketBuyCommand, weaponname);
			}
		}
	}

	g_bZMarketCommandInitialized = true;
}

public Action ZMarketBuyCommand(int client, int argc)
{
    char command[CONFIG_MAX_LENGTH];
    char zmarketcommand[CONFIG_MAX_LENGTH];
    char weaponname[WEAPONS_MAX_LENGTH];

    GetCmdArg(0, command, sizeof(command));

    int size = GetArraySize(arrayWeapons);
    for (int weaponindex = 0; weaponindex < size; weaponindex++)
    {
        WeaponsGetZMarketCommand(weaponindex, zmarketcommand, sizeof(zmarketcommand));

        if (FindCharInString(zmarketcommand, ',') != -1)
        {
            int idx;
            int lastidx;
            while ((idx = FindCharInString(zmarketcommand[lastidx], ',')) != -1)
            {
                if (!strncmp(command, zmarketcommand[lastidx], idx))
                {
                    WeaponsGetName(weaponindex, weaponname, sizeof(weaponname));
                    ZMarketEquip(client, weaponname);
                    return Plugin_Handled;
                }

                lastidx += ++idx;

                if (FindCharInString(zmarketcommand[lastidx], ',') == -1 && zmarketcommand[lastidx+1] != '\0')
                {
                    if (!strncmp(command, zmarketcommand[lastidx], idx))
                    {
                        WeaponsGetName(weaponindex, weaponname, sizeof(weaponname));
                        ZMarketEquip(client, weaponname);
                        return Plugin_Handled;
                    }
                }
            }
        }
        else
        {
            if(StrEqual(command, zmarketcommand))
            {
                WeaponsGetName(weaponindex, weaponname, sizeof(weaponname));
                ZMarketEquip(client, weaponname);
                return Plugin_Handled;
            }
        }
    }

    return Plugin_Handled;
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.  
 */
void ZMarketClientInit(int client)
{
	// If purchase count data exists, then destroy before creating again.
	if (g_hZMarketPurchaseCount[client] != INVALID_HANDLE)
	{
		CloseHandle(g_hZMarketPurchaseCount[client]);
	}
	
	// Create a new array handle to store purchase count data for client.
	g_hZMarketPurchaseCount[client] = CreateTrie();
	
	// No weapons bought automatically.
	g_bZMarketWeaponsBought[client] = false;
}

/**
 * Called once a client's saved cookies have been loaded from the database.
 * 
 * @param client		Client index.
 */
void ZMarketOnCookiesCached(int client)
{
	// Initialize auto-rebuy data.
	char zmarketautorebuy[8];
	GetClientCookie(client, g_hZMarketAutoRebuyCookie, zmarketautorebuy, sizeof(zmarketautorebuy));
	
	// If the cookie is empty, then set the default value.
	if (!zmarketautorebuy[0])
	{
		// Set cookie to false.
		CookiesSetClientCookieBool(client, g_hZMarketAutoRebuyCookie, false);
		return;
	}
	
	// Rebuy wapons (if auto-rebuy is enabled, and not bought already).
	if (!g_bZMarketWeaponsBought[client])
	{
		ZMarketCheckRebuy(client);
	}
}

/**
 * Client is leaving the server.
 * 
 * @param client	The client index.
 */
void ZMarketOnClientDisconnect(int client)
{
	// Destroy ZMarket array data for client.
	if (g_hZMarketPurchaseCount[client] != INVALID_HANDLE)
	{
		CloseHandle(g_hZMarketPurchaseCount[client]);
	}
	
	// Reset handle.
	g_hZMarketPurchaseCount[client] = INVALID_HANDLE;
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void ZMarketOnClientSpawnPost(int client)
{
	// Reset purchase counts for client.
	ZMarketResetPurchaseCount(client);
	
	// Rebuy if auto-rebuy is enabled.
	ZMarketCheckRebuy(client);
}

/**
 * Rebuys weapons if auto-rebuy is enabled and player is a human (alive).
 *
 * @param client	The client index.
 */
void ZMarketCheckRebuy(int client)
{
	// If auto-rebuy is disabled, then ensure it is also disabled on the client as well.
	bool zmarketrebuyauto = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_ZMARKET_REBUY_AUTO]);
	if (!zmarketrebuyauto)
	{
		CookiesSetClientCookieBool(client, g_hZMarketAutoRebuyCookie, false);
	}
	
	// If client hasn't spawned into the game yet, then stop.
	if (!IsClientConnected(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	// If client is a zombie, then stop.
	if (InfectIsClientInfected(client))
	{
		return;
	}
	
	// If auto-rebuy is enabled, then force client to rebuy weapons.
	if (CookiesGetClientCookieBool(client, g_hZMarketAutoRebuyCookie))
	{
		ZMarketRebuy(client, true);
		g_bZMarketWeaponsBought[client] = true;
	}
}

/**
 * Reset the purchase count(s) for a client.
 * 
 * @param client	The client index.
 */
void ZMarketResetPurchaseCount(int client)
{
	// Clear out the trie of all data.
	if (g_hZMarketPurchaseCount[client] != INVALID_HANDLE)
	{
		ClearTrie(g_hZMarketPurchaseCount[client]);
	}
}

/**
 * Set the purchases left for a client of a weapon.
 * 
 * @param client	The client index.
 * @param weapon	The weapon name.
 * @param value	 The amount of purchases left for the weapon.
 */
void ZMarketSetPurchaseCount(int client, const char[] weapon, int value, bool add = false)
{
	// Initialize variable (value is 0)
	int purchasemax;
	
	// If we are adding, then update variable with current ammo value.
	if (add)
	{
		purchasemax = ZMarketGetPurchaseCount(client, weapon);
	}
	
	// Set value in client's trie.
	SetTrieValue(g_hZMarketPurchaseCount[client], weapon, purchasemax + value);
}

/**
 * Get the purchases left for a client of a weapon.
 * 
 * @param client	The client index.
 * @param weapon	The weapon name.
 * @param return	The amount of purchases left for the weapon.
 */
int ZMarketGetPurchaseCount(int client, const char[] weapon)
{
	// Get value in client's trie.
	int value;
	GetTrieValue(g_hZMarketPurchaseCount[client], weapon, value);
	return value;
}

/**
 * Sends main ZMarket menu to client.
 *  
 * @param client	The client index.
 * @return		  True if the menu was sent successfully, false if not.
 */
bool ZMarketMenuMain(int client)
{
	// If weapons module is disabled, then stop.
	bool weapons = GetConVarBool(g_hCvarsList[CVAR_WEAPONS]);
	if (!weapons)
	{
		// Telle client feature is disabled.
		TranslationPrintToChat(client, "Feature is disabled");
		return false;
	}
	
	// If ZMarket module is disabled, then stop.
	bool zmarket = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_ZMARKET]);
	if (!zmarket)
	{
		// Telle client feature is disabled.
		TranslationPrintToChat(client, "Feature is disabled");
		return false;
	}
	
	// Create menu handle.
	Handle menu_zmarket_main = CreateMenu(ZMarketMenuMainHandle);
	
	// Set translation target as client.
	SetGlobalTransTarget(client);
	
	// If rebuy is enabled, then add it to the menu.
	bool zmarketrebuy = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_ZMARKET_REBUY]);
	bool zmarketrebuyauto = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_ZMARKET_REBUY_AUTO]);
	
	// Add "Get Current Loadout" option.
	char title[MENU_LINE_TITLE_LENGTH];
	char getloadout[MENU_LINE_REG_LENGTH];
	char viewloadout[MENU_LINE_REG_LENGTH];
	char rebuy[MENU_LINE_REG_LENGTH];
	char rebuyauto[MENU_LINE_REG_LENGTH];
	char weaponslist[MENU_LINE_REG_LENGTH];
	
	// Get auto-rebuy setting.
	char rebuyautosetting[MENU_LINE_SMALL_LENGTH];
	ConfigBoolToSetting(CookiesGetClientCookieBool(client, g_hZMarketAutoRebuyCookie), rebuyautosetting, sizeof(rebuyautosetting), true, client);
	
	// Format menu options.
	Format(title, sizeof(title), "%t\n ", "Weapons menu zmarket main title");
	Format(getloadout, sizeof(getloadout), "%t", "Weapons menu zmarket main get loadout");
	Format(viewloadout, sizeof(viewloadout), "%t", "Weapons menu zmarket main view loadout");
	Format(rebuy, sizeof(rebuy), "%t", "Weapons menu zmarket main rebuy");
	Format(rebuyauto, sizeof(rebuyauto), "%t", "Weapons menu zmarket main auto-rebuy", rebuyautosetting);
	Format(weaponslist, sizeof(weaponslist), "%t", "Weapons menu zmarket main weapons list");
	
	// Add formatted options to menu.
	SetMenuTitle(menu_zmarket_main, title);
	AddMenuItem(menu_zmarket_main, "Get Loadout", getloadout, MenuGetItemDraw(zmarketrebuy || zmarketrebuyauto));
	AddMenuItem(menu_zmarket_main, "View Loadout", viewloadout, MenuGetItemDraw(zmarketrebuy || zmarketrebuyauto));
	AddMenuItem(menu_zmarket_main, "Rebuy", rebuy, MenuGetItemDraw(zmarketrebuy || zmarketrebuyauto));
	AddMenuItem(menu_zmarket_main, "Auto-Rebuy", rebuyauto, MenuGetItemDraw(zmarketrebuyauto));
	AddMenuItem(menu_zmarket_main, "Weapons List", weaponslist);
	
	// Set exit back button.
	SetMenuExitBackButton(menu_zmarket_main, true);
		
	DisplayMenu(menu_zmarket_main, client, MENU_TIME_FOREVER);
	
	// Menu sent successfully.
	return true;
}

/**
 * Called when client selects option in the main ZMarket menu, and handles it.
 *  
 * @param menu_zmarket_main	Handle of the menu being used.
 * @param action				The action done on the menu (see menus.inc, enum MenuAction).
 * @param client				The client index.
 * @param slot				  The slot index selected (starting from 0).
 */ 
public int ZMarketMenuMainHandle(Handle menu_zmarket_main, MenuAction action, int client, int slot)
{
	// Client selected an option.
	if (action == MenuAction_Select)
	{
		switch(slot)
		{
			// Get loadout.
			case 0:
			{
				// Gets a client's current loadout.
				ZMarketGetCurrentLoadout(client);
				
				// Resend menu.
				ZMarketMenuMain(client);
			}
			// View loadout.
			case 1:
			{
				// Show a client their current loadout.
				ZMarketMenuLoadout(client);
			}
			// Rebuy.
			case 2:
			{
				// Force client to rebuy weapons.
				ZMarketRebuy(client);
				
				// Resend menu.
				ZMarketMenuMain(client);
			}
			// Auto-rebuy.
			case 3:
			{
				// Toggle the auto-rebuy cookie.
				ZMarketToggleAutoRebuy(client);
				
				// Resend menu.
				ZMarketMenuMain(client);
			}
			// Weapons list.
			case 4:
			{
				// Send the weapon types list.
				ZMarketMenuTypes(client);
			}
		}
	}
	// Client closed the menu.
	if (action == MenuAction_Cancel)
	{
		// Client hit "Back" button.
		if (slot == MenuCancel_ExitBack)
		{
			ZMenuMain(client);
		}
	}
	// Client hit "Exit" button.
	else if (action == MenuAction_End)
	{
		CloseHandle(menu_zmarket_main);
	}
}

/**
 * Sends list of weapons in a client's loadout to the client.
 *  
 * @param client	The client index.
 */
bool ZMarketMenuLoadout(int client)
{
	// Create menu handle.
	Handle menu_zmarket_loadout = CreateMenu(ZMarketMenuLoadoutHandle);
	
	// Transfer cookie values into an array.
	char rebuyweapons[WeaponsSlot][WEAPONS_MAX_LENGTH];
	ZMarketCookiesToArray(client, rebuyweapons, WEAPONS_SLOTS_MAX + 1, sizeof(rebuyweapons[]));
	
	SetGlobalTransTarget(client);
	
	// Get the empty translation.
	char empty[MENU_LINE_SMALL_LENGTH];
	Format(empty, sizeof(empty), "%t", "Weapons menu zmarket loadout empty");
	
	// x = Rebuy weapon slot.
	for (int x = 0; x < sizeof(rebuyweapons); x++)
	{
		// Ignore the NVG slot, we handle this separately.
		if (view_as<WeaponsSlot>(x) == Slot_NVGs)
		{
			continue;
		}
		
		// If the client doesn't have a weapon in this slot, then set the weapon to the empty translation.
		if (!rebuyweapons[x][0])
		{
			strcopy(rebuyweapons[x], sizeof(rebuyweapons[]), empty);
		}
	}
	
	// Copy "Yes/No" to NVGs string.
	char nvgsbool[MENU_LINE_SMALL_LENGTH];
	ConfigBoolToSetting(view_as<bool>(rebuyweapons[Slot_NVGs][0]), nvgsbool, sizeof(nvgsbool), true, client);
	
	char title[MENU_LINE_HUGE_LENGTH];
	char primary[MENU_LINE_REG_LENGTH];
	char secondary[MENU_LINE_REG_LENGTH];
	char melee[MENU_LINE_REG_LENGTH];
	char projectile[MENU_LINE_REG_LENGTH];
	char explosive[MENU_LINE_REG_LENGTH];
	char nvgs[MENU_LINE_REG_LENGTH];
	
	// Format all the lines of the menu.
	Format(title, sizeof(title), "%t\n ", "Weapons menu zmarket loadout title");
	Format(primary, sizeof(primary), "%t", "Weapons menu zmarket loadout primary", rebuyweapons[Slot_Primary]);
	Format(secondary, sizeof(secondary), "%t", "Weapons menu zmarket loadout secondary", rebuyweapons[Slot_Secondary]);
	Format(melee, sizeof(melee), "%t", "Weapons menu zmarket loadout melee", rebuyweapons[Slot_Melee]);
	Format(projectile, sizeof(projectile), "%t", "Weapons menu zmarket loadout projectile", rebuyweapons[Slot_Projectile]);
	Format(explosive, sizeof(explosive), "%t", "Weapons menu zmarket loadout explosive", rebuyweapons[Slot_Explosive]);
	Format(nvgs, sizeof(nvgs), "%t", "Weapons menu zmarket loadout nvgs", nvgsbool);
	
	// Add formatted options to menu.
	SetMenuTitle(menu_zmarket_loadout, title);
	AddMenuItem(menu_zmarket_loadout, "0", primary, MenuGetItemDraw(!StrEqual(rebuyweapons[Slot_Primary], empty)));
	AddMenuItem(menu_zmarket_loadout, "1", secondary, MenuGetItemDraw(!StrEqual(rebuyweapons[Slot_Secondary], empty)));
	AddMenuItem(menu_zmarket_loadout, "2", melee, MenuGetItemDraw(!StrEqual(rebuyweapons[Slot_Melee], empty)));
	AddMenuItem(menu_zmarket_loadout, "3", projectile, MenuGetItemDraw(!StrEqual(rebuyweapons[Slot_Projectile], empty)));
	AddMenuItem(menu_zmarket_loadout, "4", explosive, MenuGetItemDraw(!StrEqual(rebuyweapons[Slot_Explosive], empty)));
	AddMenuItem(menu_zmarket_loadout, "5", nvgs, MenuGetItemDraw(view_as<bool>(rebuyweapons[Slot_NVGs][0])));
	
	// Set exit back button.
	SetMenuExitBackButton(menu_zmarket_loadout, true);
	
	// Send menu to client.
	DisplayMenu(menu_zmarket_loadout, client, MENU_TIME_FOREVER);
}

/**
 * Allow the user to press the "Back" button to go to main ZMarket menu.
 *  
 * @param menu_zmarket_loadout	Handle of the menu being used.
 * @param action				The action done on the menu (see menus.inc, enum MenuAction).
 * @param client				The client index.
 * @param slot				  The slot index selected (starting from 0).
 */ 
public int ZMarketMenuLoadoutHandle(Handle menu_zmarket_loadout, MenuAction action, int client, int slot)
{
	// Client selected an option.
	if (action == MenuAction_Select)
	{
		// Clear rebuy slot.
		ZMarketSetRebuyCookie(client, view_as<WeaponsSlot>(slot), "");
		
		// Re-send menu.
		ZMarketMenuLoadout(client);
	}
	// Client closed the menu.
	if (action == MenuAction_Cancel)
	{
		// Client hit "Back" button.
		if (slot == MenuCancel_ExitBack)
		{
			ZMarketMenuMain(client);
		}
	}
	// Client hit "Exit" button.
	else if (action == MenuAction_End)
	{
		CloseHandle(menu_zmarket_loadout);
	}
}

/**
 * Sends weapon type list to client.
 *  
 * @param client	The client index.
 */
void ZMarketMenuTypes(int client)
{
	// Create menu handle.
	Handle menu_zmarket_types = CreateMenu(ZMarketMenuTypesHandle);
	
	// Set translation target as client.
	SetGlobalTransTarget(client);
	
	char title[MENU_LINE_TITLE_LENGTH];
	Format(title, sizeof(title), "%t\n ", "Weapons menu zmarket types title");
	SetMenuTitle(menu_zmarket_types, title);
	
	char typename[WEAPONS_MAX_LENGTH];
	
	// x = Array index.
	int size = GetArraySize(arrayWeaponTypes);
	for (int x = 0; x < size; x++)
	{
		// Get name of type.
		RestrictWeaponTypeGetName(x, typename, sizeof(typename));
		
		// Add item to menu.
		AddMenuItem(menu_zmarket_types, typename, typename);
	}
	
	// If there are no weapons, add an "(Empty)" line.
	if (size == 0)
	{
		SetGlobalTransTarget(client);
		
		char empty[MENU_LINE_SMALL_LENGTH];
		Format(empty, sizeof(empty), "%t", "Menu empty");
		
		AddMenuItem(menu_zmarket_types, "empty", empty, ITEMDRAW_DISABLED);
	}
	
	// Set exit back button.
	SetMenuExitBackButton(menu_zmarket_types, true);
		
	DisplayMenu(menu_zmarket_types, client, MENU_TIME_FOREVER);
}

/**
 * Called when client selects option in the weapons list menu, and handles it.
 *  
 * @param menu_zmarket_types	Handle of the menu being used.
 * @param action				The action done on the menu (see menus.inc, enum MenuAction).
 * @param client				The client index.
 * @param slot				  The slot index selected (starting from 0).
 */ 
public int ZMarketMenuTypesHandle(Handle menu_zmarket_types, MenuAction action, int client, int slot)
{
	// Client selected an option.
	if (action == MenuAction_Select)
	{
		char weapontype[WEAPONS_MAX_LENGTH];
		GetMenuItem(menu_zmarket_types, slot, weapontype, sizeof(weapontype));
		
		// Get weapon index.
		int weapontypeindex = RestrictTypeToIndex(weapontype);
		
		// If weapon type index is -1, then something went very wrong.
		if (weapontypeindex == -1)
		{
			// Resend menu.
			ZMarketMenuTypes(client);
			
			return;
		}
		
		// Menu slot index is = weapon type index.
		g_iZMarketCurType[client] = weapontypeindex;
		
		// Send weapons of the selected type in a menu to client.
		ZMarketMenuTypeWeapons(client);
	}
	// Client closed the menu.
	if (action == MenuAction_Cancel)
	{
		// Client hit "Back" button.
		if (slot == MenuCancel_ExitBack)
		{
			ZMarketMenuMain(client);
		}
	}
	// Client hit "Exit" button.
	else if (action == MenuAction_End)
	{
		CloseHandle(menu_zmarket_types);
	}
}

/**
 * Sends a list of weapons of a certain type in a menu to the client.
 *  
 * @param client	The client index.
 */
void ZMarketMenuTypeWeapons(int client)
{
	// Create menu handle.
	Handle menu_zmarket_typeweapons = CreateMenu(ZMarketMenuTypeWeaponsHandle);
	
	// Get name of current weapon type.
	char typename[WEAPONS_MAX_LENGTH];
	RestrictWeaponTypeGetName(g_iZMarketCurType[client], typename, sizeof(typename));
	
	char title[MENU_LINE_TITLE_LENGTH];
	char typeweapon[WEAPONS_MAX_LENGTH];
	char typeweapondisplay[MENU_LINE_REG_LENGTH];
	char typeweaponentity[WEAPONS_MAX_LENGTH];
	char display[MENU_LINE_BIG_LENGTH];
	
	// Get an array populated with all weapons of the given type.
	Handle arrayTypeWeapons;
	int count = RestrictGetTypeWeapons(g_iZMarketCurType[client], arrayTypeWeapons);
	
	SetGlobalTransTarget(client);
	
	// x = Array index.
	for (int x = 0; x < count; x++)
	{
		// Get weapon index to check restricted status of.
		int weaponindex = GetArrayCell(arrayTypeWeapons, x);
		
		// Get name of weapon.
		WeaponsGetName(weaponindex, typeweapon, sizeof(typeweapon));
		
		// Get entity name of weapon.
		WeaponsGetEntity(weaponindex, typeweaponentity, sizeof(typeweaponentity));
		
		// Check if client is buying the weapon or ammo for it, and get the price of the item.
		bool hasweapon = WeaponsClientHasWeapon(client, typeweaponentity);
		
		// DO ITEM PRICE STUFF HERE.
		
		int itemprice;
		
		// Do appropriate formatting for the type of item client is buying.
		WeaponsSlot slot = WeaponsGetSlot(weaponindex);
		if (!hasweapon || slot == Slot_Projectile)
		{
			// Get the weapon price.
			itemprice = WeaponsGetZMarketPrice(weaponindex);
		}
		else
		{
			// Get the weapon's ammo price.
			itemprice = WeaponsGetAmmoPrice(weaponindex);
			
			// Tell client they are buying ammo.
			Format(typeweapondisplay, sizeof(typeweapondisplay), "%s %t", typeweapon, "Weapons menu zmarket types weapon ammo");
		}
		
		// If the itemprice is invalid, then set to known integer to be later replaced.
		if (itemprice < 0)
		{
			itemprice = -1;
		}
		
		// DO RESTRICTED WEAPON STUFF HERE.
		
		// Get restricted status on the weapon.
		bool restricted = RestrictIsWeaponRestricted(weaponindex);
		
		// If weapon is restricted then format "[]" around it.
		strcopy(typeweapondisplay, sizeof(typeweapondisplay), typeweapon);
		if (restricted)
		{
			Format(typeweapondisplay, sizeof(typeweapondisplay), "[%s]", typeweapon);
		}
		
		// DO PURCHASE MAX STUFF HERE.
		
		// Get the purchase count information for this weapon.
		int purchasemax = WeaponsGetZMarketPurchaseMax(weaponindex);
		int purchasecount = ZMarketGetPurchaseCount(client, typeweapon);
		int purchasesleft = purchasemax - purchasecount;
		
		// If the purchases left for the weapon goes below 0, fix it.
		if (purchasesleft < 0)
		{
			purchasesleft = 0;
		}
		
		// If max purchases is disabled for the weapon, then set as known integer to be later replaced.
		if (purchasemax <= 0)
		{
			purchasesleft = -1;
		}
		
		// Format all the information together.
		
		// Format price onto the menu entry.
		Format(display, sizeof(display), "%t", "Weapons menu zmarket types weapon info", typeweapondisplay, itemprice, purchasesleft);
		
		// Remove the known invalid number from the string, and replace with N/A, and remove currency symbol.
		ReplaceString(display, sizeof(display), "$-1", "N/A");
		ReplaceString(display, sizeof(display), "-1", "N/A");
		
		// Disable option if it isn't toggleable.
		bool itemdraw = ((itemprice > -1) && !restricted && (purchasemax <= 0 || purchasesleft > 0));
		AddMenuItem(menu_zmarket_typeweapons, typeweapon, display, MenuGetItemDraw(itemdraw));
	}
	
	Format(title, sizeof(title), "%t\n ", "Weapons menu zmarket types weapon type title", typename);
	SetMenuTitle(menu_zmarket_typeweapons, title);
	
	// Destroy the array handle.
	CloseHandle(arrayTypeWeapons);
	
	// Set menu back button.
	SetMenuExitBackButton(menu_zmarket_typeweapons, true);
	
	// Display menu to client.
	DisplayMenu(menu_zmarket_typeweapons, client, MENU_TIME_FOREVER);
}

/**
 * Called when client selects option in the weapon group menu, and handles it.
 *  
 * @param menu_zmarket_typeweapons  Handle of the menu being used.
 * @param action					The action done on the menu (see menus.inc, enum MenuAction).
 * @param client					The client index.
 * @param slot					  The slot index selected (starting from 0).
 */ 
public int ZMarketMenuTypeWeaponsHandle(Handle menu_zmarket_typeweapons, MenuAction action, int client, int slot)
{
	// Client selected an option.
	if (action == MenuAction_Select)
	{
		// Get name of current weapon type.
		char typename[WEAPONS_MAX_LENGTH];
		RestrictWeaponTypeGetName(g_iZMarketCurType[client], typename, sizeof(typename));
		
		char typeweapon[WEAPONS_MAX_LENGTH];
		GetMenuItem(menu_zmarket_typeweapons, slot, typeweapon, sizeof(typeweapon));
		
		// Equip weapon on client.
		ZMarketEquip(client, typeweapon);
		
		// Open types menu.
		ZMarketMenuTypes(client);
	}
	// Client closed the menu.
	if (action == MenuAction_Cancel)
	{
		// Client hit "Back" button.
		if (slot == MenuCancel_ExitBack)
		{
			ZMarketMenuTypes(client);
		}
	}
	// Client hit "Exit" button.
	else if (action == MenuAction_End)
	{
		CloseHandle(menu_zmarket_typeweapons);
	}
}

/**
 * Equip a weapon on a client.
 * 
 * @param client	The client index.
 * @param weapon	The weapon to equip. (must be in weapons config file)
 * @param rebuy	 (Optional) If client is rebuying, ammo will be ignored.
 */
stock bool ZMarketEquip(int client, const char[] weapon, bool rebuy = false)
{
	// Get weapon index.
	int weaponindex = WeaponsNameToIndex(weapon);
	
	// If weapon index is -1, then something went very wrong.
	if (weaponindex == -1)
	{
		LogEvent(false, LogType_Error, LOG_CORE_EVENTS, LogModule_Weapons, "ZMarket Equip", "Invalid weapon (%s) selected from the ZMarket menu.", weapon);
		return false;
	}
	
	// Get slot index of the weapon being purchased.
	WeaponsSlot slot = WeaponsGetSlot(weaponindex);
	
	// If client is dead or a zombie, update weapon loadout instead.
	if (!IsPlayerAlive(client) || InfectIsClientInfected(client))
	{
		// Update cookie with new weapon.
		ZMarketSetRebuyCookie(client, slot, weapon);
		
		TranslationPrintToChat(client, "Weapons zmarket updated loadout");
		return false;
	}
	
	bool zmarketbuyzone = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_ZMARKET_BUYZONE]);
	if (!rebuy && zmarketbuyzone && !WeaponsIsClientInBuyZone(client))
	{
		// Update cookie with new weapon.
		ZMarketSetRebuyCookie(client, slot, weapon);
		
		TranslationPrintToChat(client, "Weapons zmarket updated loadout");
		return false;
	}
	
	// Get entity name of the weapon.
	char weaponentity[WEAPONS_MAX_LENGTH];
	WeaponsGetEntity(weaponindex, weaponentity, sizeof(weaponentity));
	
	// Get the appropriate price of the item being purchased.
	bool hasweapon = WeaponsClientHasWeapon(client, weaponentity);
	int itemprice = (hasweapon && slot != Slot_Projectile) ? WeaponsGetAmmoPrice(weaponindex) : WeaponsGetZMarketPrice(weaponindex);
	
	// If the weapon price is below 0, then something went wrong.
	if (itemprice < 0)
	{
		return false;
	}
	
	// Get the display name for the weapon.
	char weapondisplay[WEAPONS_MAX_LENGTH];
	WeaponsGetName(weaponindex, weapondisplay, sizeof(weapondisplay));
	
	// Check to make sure the weapon isn't restricted.
	bool restricted = RestrictIsWeaponRestricted(weaponindex);
	if (restricted)
	{
		TranslationPrintToChat(client, "Weapon is restricted", weapondisplay);
		return false;
	}
	
	// Get the purchase count information for this weapon.
	int purchasemax = WeaponsGetZMarketPurchaseMax(weaponindex);
	int purchasecount = ZMarketGetPurchaseCount(client, weapon);
	int purchasesleft = purchasemax - purchasecount;
	if (purchasemax > 0 && purchasesleft <= 0)
	{
		TranslationPrintToChat(client, "Weapons zmarket purchase max", weapondisplay, purchasemax);
		return false;
	}
	
	// If the slot is a projectile, then get information we need to compare later.
	if (slot == Slot_Projectile)
	{
		// Get the grenade type the client is trying to buy.
		WeaponAmmoGrenadeType grenadetype = WeaponAmmoEntityToGrenadeType(weaponentity);
		
		if (grenadetype == GrenadeType_Invalid)
		{
			LogEvent(false, LogType_Error, LOG_GAME_EVENTS, LogModule_Weapons, "Grenades", "Client \"%L\" attempted to buy weapon entity \"%s\" marked as a projectile. Check your weapon config.", client, weaponentity);
			return false;
		}
		
		// How many grenades does the client currently have?
		int grenadecount = WeaponAmmoGetGrenadeCount(client, grenadetype);
		
		// How many grenades can the client hold?
		int grenadelimit = WeaponAmmoGetGrenadeLimit(grenadetype);
		
		// If client is at, or exceeds the grenade limit, then stop.
		if (grenadecount >= grenadelimit)
		{
			// Client can't carry any more of this type of grenade.
			TranslationPrintToChat(client, "Weapons zmarket grenade max", grenadelimit);
			return false;
		}
	}
	
	// Get client's current money.
	int cash = AccountGetClientCash(client);
	
	// If client doesn't have enough money, tell them, resend menu, and then stop.
	if (cash < itemprice)
	{
		// Update cookie with new weapon.
		ZMarketSetRebuyCookie(client, slot, weapon);
		
		TranslationPrintToChat(client, "Weapons zmarket updated loadout");
		return false;
	}
	
	// Set client's new cash after purchase.
	AccountSetClientCash(client, cash - itemprice);
	
	// Get a list of the client's current weapons.
	int weapons[WeaponsSlot];
	WeaponsGetClientWeapons(client, weapons);
	
	// Check if client is buying the weapon or ammo for it.
	if (!hasweapon || slot == Slot_Projectile || slot == Slot_NVGs)
	{
		// If the item is a projectile or NVGs, then skip.
		if (slot != Slot_Projectile && slot != Slot_NVGs)
		{
			// If there is already a weapon in the slot, then force client to drop it.
			if (weapons[slot] > -1)
			{
				// Force client to drop the weapon.
				WeaponsForceClientDrop(client, weapons[slot]);
			}
		}
		if (StrEqual(weaponentity, "item_kevlar"))
		{
			SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
		}
		else
		{
			// Give client the weapon.
			GivePlayerItem(client, weaponentity);
		}
		
		// Update cookie with new weapon.
		ZMarketSetRebuyCookie(client, slot, weapon);
		
		// Add 1 to the client's purchase count.
		ZMarketSetPurchaseCount(client, weapon, 1, true);
		
		// If client isn't rebuying the weapon, then tell them the weapon has been purchased.
		if (!rebuy)
		{
			// Tell client they bought a weapon.
			TranslationPrintToChat(client, "Weapons zmarket purchase", weapondisplay);
		}
	}
	else if (rebuy || hasweapon || slot == Slot_Projectile || slot == Slot_NVGs)
	{
		// If the item is a projectile or NVGs, then skip.
		if (slot != Slot_Projectile && slot != Slot_NVGs)
		{
			// If there is already a weapon in the slot, then force client to drop it.
			if (weapons[slot] > -1)
			{
				// Force client to drop the weapon.
				WeaponsForceClientDrop(client, weapons[slot]);
			}
		}
		
		// Give client the weapon.
		GivePlayerItem(client, weaponentity);
		
		TranslationPrintToChat(client, "Weapons zmarket purchase", weapondisplay);

		// Add 1 to the client's purchase count.
		ZMarketSetPurchaseCount(client, weapon, 1, true);
	}
	
	return true;
}

/**
 * Gets the client's current weapons and puts them in the rebuy cache.
 * 
 * @param client	The client index.
 * @return		  True if the menu sent successfully, false if not.
 */
bool ZMarketGetCurrentLoadout(int client)
{
	// If client is dead, then tell them they must be alive and stop.
	if (!IsPlayerAlive(client))
	{
		TranslationPrintToChat(client, "Must be alive");
		return false;
	}
	
	// If client is a zombie, then tell them they must be human and stop.
	if (!IsPlayerAlive(client))
	{
		TranslationPrintToChat(client, "Must be human");
		return false;
	}
	
	// Get all of client's current weapons.
	int weapons[WeaponsSlot];
	WeaponsGetClientWeapons(client, weapons);
	
	char weaponname[WEAPONS_MAX_LENGTH];
	char weaponentity[WEAPONS_MAX_LENGTH];
	
	// x = Weapon slot.
	for (int x = 0; x < WEAPONS_SLOTS_MAX; x++)
	{
		// If slot is empty, then clear this slot in rebuy cache and stop.
		if (weapons[x] == -1)
		{
			// Empty rebuy slot.
			ZMarketSetRebuyCookie(client, view_as<WeaponsSlot>(x), "");
			continue;
		}
		
		// Get the name of the weapon.
		GetEdictClassname(weapons[x], weaponentity, sizeof(weaponentity));
		
		// Get the entity name of the weapon.
		WeaponsEntityToDisplay(weaponentity, weaponname, sizeof(weaponname));
		
		// Copy the name to the rebuy cache.
		ZMarketSetRebuyCookie(client, view_as<WeaponsSlot>(x), weaponname);
	}
	
	// Update nightvision ownership.
	bool nightvision = ToolsGetClientNightVision(client);
	if (!nightvision)
	{
		// Empty rebuy slot.
		ZMarketSetRebuyCookie(client, Slot_NVGs, "");
	}
	else
	{
		ZMarketSetRebuyCookie(client, Slot_NVGs, "nvgs");
	}
	
	// Tell client their loadout has been updated.
	TranslationPrintToChat(client, "Weapons zmarket get current loadout");
	
	return true;
}

/**
 * Transfer array values to rebuy cookies.
 * 
 * @param client		The client index.
 * @param rebuyweapons  The string array to copy results from.
 * @param maxweapons	The max amount of weapons in the array.
 * @param maxlen		The max length of each cookie result.
 */
stock void ZMarketArrayToCookies(int client, char rebuyweapons[WeaponsSlot][WEAPONS_MAX_LENGTH], int maxweapons, int maxlen)
{
	char rebuycookiename[32];
	Handle rebuycookie;
	
	// x = Weapon slot.
	for (int x = 0; x < maxweapons; x++)
	{
		// Format cookie name.
		Format(rebuycookiename, sizeof(rebuycookiename), "%s_%d", ZMARKET_COOKIE_REBUY, x);
		
		// Find cookie handle, and retrieve its value.
		rebuycookie = FindClientCookie(rebuycookiename);
		SetClientCookie(client, rebuycookie, rebuyweapons[x]);
		CloseHandle(rebuycookie);
	}
}

/**
 * Transfer rebuy cookies to an array for easier access.
 * 
 * @param client		The client index.
 * @param rebuyweapons  The string array to copy results to
 * @param maxweapons	The max amount of weapons in the array.
 * @param maxlen		The max length of each cookie result.
 */
stock void ZMarketCookiesToArray(int client, char rebuyweapons[WeaponsSlot][WEAPONS_MAX_LENGTH], int maxweapons, int maxlen)
{
	char rebuycookiename[32];
	Handle rebuycookie;
	
	// x = Weapon slot.
	for (int x = 0; x < maxweapons; x++)
	{
		// Format cookie name.
		Format(rebuycookiename, sizeof(rebuycookiename), "%s_%d", ZMARKET_COOKIE_REBUY, x);
		
		// Find cookie handle, and retrieve its value.
		rebuycookie = FindClientCookie(rebuycookiename);
		GetClientCookie(client, rebuycookie, rebuyweapons[x], maxlen);
		CloseHandle(rebuycookie);
	}
}

/**
 * Set a weapon slot cookie given the slot and value.
 * 
 * @param client	The client index.
 * @param slot	  The weapon slot to set value to.
 * @param value	 The value (weaponname) of the slot.
 */
stock void ZMarketSetRebuyCookie(int client, WeaponsSlot slot, const char[] value)
{
	// Format cookie name.
	char rebuycookiename[32];
	Format(rebuycookiename, sizeof(rebuycookiename), "%s_%d", ZMARKET_COOKIE_REBUY, view_as<int>(slot));
	
	// Find cookie handle, and retrieve its value.
	Handle rebuycookie = FindClientCookie(rebuycookiename);
	if (rebuycookie == INVALID_HANDLE)
	{
		return;
	}
	
	// Set weapon to cookie.
	SetClientCookie(client, rebuycookie, value);
	CloseHandle(rebuycookie);
}

/**
 * Force a client to rebuy their weapons.
 * 
 * @param client	The client index.
 */
void ZMarketRebuy(int client, bool autorebuy = false)
{
	// If client is dead, then stop.
	if (!IsPlayerAlive(client))
	{
		TranslationPrintToChat(client, "Must be alive");
		return;
	}
	
	// If client is a zombie, then stop.
	if (InfectIsClientInfected(client))
	{
		TranslationPrintToChat(client, "Must be human");
		return;
	}
	
	bool zmarketbuyzone = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_ZMARKET_BUYZONE]);
	if (!autorebuy && zmarketbuyzone && !WeaponsIsClientInBuyZone(client))
	{
		TranslationPrintToChat(client, "Weapons zmarket buyzone");
		return;
	}
	
	// Transfer cookie values into an array.
	char rebuyweapons[WeaponsSlot][WEAPONS_MAX_LENGTH];
	ZMarketCookiesToArray(client, rebuyweapons, WEAPONS_SLOTS_MAX + 1, sizeof(rebuyweapons[]));
	
	// x = Weapon slot.
	for (int x = 0; x < WEAPONS_SLOTS_MAX + 1; x++)
	{
		// If slot is empty, then stop.
		if (!rebuyweapons[x][0])
		{
			continue;
		}
		
		ZMarketEquip(client, rebuyweapons[x], true);
	}
}

/**
 * Toggle auto-rebuy on a client.
 * 
 * @param client	The client index.
 */
void ZMarketToggleAutoRebuy(int client)
{
	// If auto-rebuy is disabled, then stop.
	bool zmarketrebuyauto = GetConVarBool(g_hCvarsList[CVAR_WEAPONS_ZMARKET_REBUY_AUTO]);
	if (!zmarketrebuyauto)
	{
		return;
	}
	
	// Get the cookie value.
	bool autorebuystate = CookiesGetClientCookieBool(client, g_hZMarketAutoRebuyCookie);
	
	// Toggle the value.
	CookiesSetClientCookieBool(client, g_hZMarketAutoRebuyCookie, !autorebuystate);
	
	// If auto-rebuy was enabled, then tell client it has been disabled.
	if (autorebuystate)
	{
		TranslationPrintToChat(client, "Weapons zmarket auto-rebuy toggle off");
	}
	// If auto-rebuy was disabled, then tell client it has been enabled.
	else
	{
		TranslationPrintToChat(client, "Weapons zmarket auto-rebuy toggle on");
	}
}

/**
 * Command callback (zmarket)
 * Opens custom buymenu.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZMarketCommand(int client, int argc)
{
	// If client is console, then stop and tell them this feature is for players only.
	if (ZRIsConsole(client))
	{
		TranslationPrintToServer("Must be player");
		return Plugin_Handled;
	}
	
	// Send ZMarket menu.
	ZMarketMenuMain(client);
	
	// This stops the "Unknown command" message in client's console.
	return Plugin_Handled;
}
