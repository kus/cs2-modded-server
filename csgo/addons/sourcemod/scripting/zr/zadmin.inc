/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  zadmin.inc
 *  Type:		  Core
 *  Description:   Handle admin functions and menus.
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
 * Create commands specific to ZAdmin.
 */
void ZAdminOnCommandsCreate()
{
	// Register ZAdmin command.
	RegConsoleCmd(SAYHOOKS_KEYWORD_ZADMIN, ZAdminCommand, "Opens ZR admin menu.");
}

/**
 * Command callback (zadmin)
 * Opens ZR admin menu.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ZAdminCommand(int client, int argc)
{
	// If client is console, then stop and tell them this feature is for players only.
	if (ZRIsConsole(client))
	{
		TranslationPrintToServer("Must be player");
		return Plugin_Handled;
	}
	
	// Send admin menu.
	ZAdminMenu(client);
	
	// This stops the "Unknown command" message in client's console.
	return Plugin_Handled;
}

/**
 * Main admin menu.
 * 
 * @param client	The client index.
 */
bool ZAdminMenu(int client)
{
	// If client isn't an generic admin, then stop.
	if (!ZRIsClientAdmin(client))
	{
		TranslationPrintToChat(client, "Must be admin");
		return false;
	}
	
	// Boolean that tell if client is allowed to do configuration.
	bool configallowed = ZRIsClientPrivileged(client, OperationType_Configuration);
	
	// Create menu handle.
	Handle menu_zadmin = CreateMenu(ZAdminMenuHandle);
	
	// Set translation target as the client.
	SetGlobalTransTarget(client);
	
	char title[MENU_LINE_TITLE_LENGTH];
	char classmultipliers[MENU_LINE_REG_LENGTH];
	char weapons[MENU_LINE_REG_LENGTH];
	char hitgroups[MENU_LINE_REG_LENGTH];
	char infect[MENU_LINE_REG_LENGTH];
	char zspawn[MENU_LINE_REG_LENGTH];
	char ztele[MENU_LINE_REG_LENGTH];
	
	Format(title, sizeof(title), "%t\n ", "ZAdmin main title");
	Format(classmultipliers, sizeof(classmultipliers), "%t", "ZAdmin main class multipliers");
	Format(weapons, sizeof(weapons), "%t", "ZAdmin main weapons");
	Format(hitgroups, sizeof(hitgroups), "%t", "ZAdmin main hitgroups");
	Format(infect, sizeof(infect), "%t", "ZAdmin main zombie");
	Format(zspawn, sizeof(zspawn), "%t", "ZAdmin main force zspawn");
	Format(ztele, sizeof(ztele), "%t", "ZAdmin main force ztele");
	
	// Get conditions for options.
	int configdraw = MenuGetItemDraw(configallowed);
	int moderatordraw = MenuGetItemDraw(ZRIsClientPrivileged(client, OperationType_Generic));
	int hitgroupdraw = MenuGetItemDraw(GetConVarBool(g_hCvarsList[CVAR_HITGROUPS]) && configallowed);
	
	// Add items to menu.
	SetMenuTitle(menu_zadmin, title);
	AddMenuItem(menu_zadmin, "classmultipliers", classmultipliers, configdraw);
	AddMenuItem(menu_zadmin, "weapons", weapons, configdraw);
	AddMenuItem(menu_zadmin, "hitgroups", hitgroups, hitgroupdraw);
	AddMenuItem(menu_zadmin, "infect", infect, moderatordraw);
	AddMenuItem(menu_zadmin, "zspawn", zspawn, moderatordraw);
	AddMenuItem(menu_zadmin, "ztele", ztele, moderatordraw);
	
	// Set "Back" button.
	SetMenuExitBackButton(menu_zadmin, true);
	
	// Send menu to client.
	DisplayMenu(menu_zadmin, client, MENU_TIME_FOREVER);
	
	return true;
}

/**
 * Menu callback (zadmin)
 * Handles options selected in the admin menu.
 * 
 * @param menu	  The menu handle.
 * @param action	Action client is doing in menu.
 * @param client	The client index.
 * @param slot	  The menu slot selected. (starting from 0)
 */
public int ZAdminMenuHandle(Handle menu_zadmin, MenuAction action, int client, int slot)
{
	if (action == MenuAction_Select)
	{
		// Create variable to possible resend menu later.
		bool resend = true;
		
		switch(slot)
		{
			// Class multipliers.
			case 0:
			{
				resend = !ClassTeamSelect(client);
			}
			// Weapon management.
			case 1:
			{
				resend = !WeaponsMenuMain(client);
			}
			// Hitgroup management.
			case 2:
			{
				resend = !HitgroupsMenuHitgroups(client);
			}
			// Zombie management.
			case 3:
			{
				// We're not resending this menu.
				resend = false;
				
				// Send list of clients to infect.
				InfectMenuClients(client);
			}
			// Force ZSpawn.
			case 4:
			{
				// We're not resending this menu.
				resend = false;
				
				// Send list of clients to infect.
				MenuClientList(client, ZSpawnForceHandle, true, false, true, "ZSpawn clients title");
			}
			// Force ZTele.
			case 5:
			{
				// We're not resending this menu.
				resend = false;
				
				// Send list of clients to infect.
				MenuClientList(client, ZTeleForceHandle, true, true, false, "ZTele clients title");
			}
		}
		
		// Re-send menu if selection failed.
		if (resend)
		{
			ZAdminMenu(client);
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (slot == MenuCancel_ExitBack)
		{
			// Exit back to main menu.
			ZMenuMain(client);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu_zadmin);
	}
}
