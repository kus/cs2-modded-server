/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  classmenus.inc
 *  Type:		  Core
 *  Description:   Provides functions for managing class menus.
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


/* ------------------------------------
 *
 * MAIN CLASS MENU
 *
 * ------------------------------------
 */

/**
 * Displays the main class menu with the players class settings.
 *
 * @param client	The client index.
 */
void ClassMenuMain(int client)
{
	Handle menu = CreateMenu(ClassMenuMainHandle);
	
	SetGlobalTransTarget(client);
	
	char title[MENU_LINE_TITLE_LENGTH];
	
	char zombieclass[MENU_LINE_REG_LENGTH];
	char humanclass[MENU_LINE_REG_LENGTH];
	char adminclass[MENU_LINE_REG_LENGTH];
	
	char nextzombiename[MENU_LINE_REG_LENGTH];
	char nexthumanname[MENU_LINE_REG_LENGTH];
	char nextadminname[MENU_LINE_REG_LENGTH];
	
	char zombieselect[MENU_LINE_BIG_LENGTH];
	char humanselect[MENU_LINE_BIG_LENGTH];
	char adminselect[MENU_LINE_BIG_LENGTH];
		
	char inadminmnode[MENU_LINE_BIG_LENGTH];
	char adminmode[MENU_LINE_BIG_LENGTH];
	char toggleadminmode[MENU_LINE_BIG_LENGTH];
	
	// Setup filtering.
	// ----------------
	int filter[ClassFilter];
	
	// Hide mother zombie classes.
	filter[ClassFilter_DenyFlags] = ZR_CLASS_FLAG_MOTHER_ZOMBIE;
	
	// Hide admin-only classes if not admin.
	filter[ClassFilter_DenyFlags] += !ZRIsClientAdmin(client) ? ZR_CLASS_FLAG_ADMIN_ONLY : 0;
	
	// Specify client for checking class group permissions.
	filter[ClassFilter_Client] = client;
	
	// Setup item draw style.
	// ----------------------
	
	// Get number of enabled classes per team.
	int zombiecount = ClassCountTeam(ZR_CLASS_TEAM_ZOMBIES, filter);
	int humancount = ClassCountTeam(ZR_CLASS_TEAM_HUMANS, filter);
	int admincount = ClassCountTeam(ZR_CLASS_TEAM_ADMINS, filter);
	
	// Get next class indexes, if set.
	int nextzombie = ClassSelectedNext[client][ZR_CLASS_TEAM_ZOMBIES];
	int nexthuman = ClassSelectedNext[client][ZR_CLASS_TEAM_HUMANS];
	int nextadmin = ClassSelectedNext[client][ZR_CLASS_TEAM_ADMINS];
	
	// Set draw style on class options depending on number of enabled classes
	// and selection permissions. Disable class selection if there's only one
	// class.
	int zombie_itemdraw = (zombiecount > 1 && ClassAllowSelection(client, ZR_CLASS_TEAM_ZOMBIES, filter)) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
	int human_itemdraw = (humancount > 1 && ClassAllowSelection(client, ZR_CLASS_TEAM_HUMANS, filter)) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
	int admin_itemdraw = (admincount > 1 && ClassAllowSelection(client, ZR_CLASS_TEAM_ADMINS, filter)) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
	
	// Check if the player is in admin mode.
	if (ClassPlayerInAdminMode[client])
	{
		// Notify the player.
		Format(inadminmnode, sizeof(inadminmnode), "%t\n", "Classes admin mode enabled");
		AddMenuItem(menu, "", inadminmnode, ITEMDRAW_RAWLINE);
	}
	
	// List zombie class options.
	// --------------------------
	
	// Get current class name.
	ClassGetName(ClassSelected[client][ZR_CLASS_TEAM_ZOMBIES], zombieclass, sizeof(zombieclass), ZR_CLASS_CACHE_MODIFIED);
	
	// Check if next index is set.
	if (ClassValidateIndex(nextzombie))
	{
		// Get name of previous class index and format item text.
		ClassGetName(nextzombie, nextzombiename, sizeof(nextzombiename), ZR_CLASS_CACHE_MODIFIED);
		
		Format(zombieselect, sizeof(zombieselect), "%t\n	%t\n	%t", "Classes menu select zombie", "Classes menu active", zombieclass, "Classes menu next", nextzombiename);
	}
	else
	{
		// Use current class name and format item text.
		Format(zombieselect, sizeof(zombieselect), "%t\n	%s", "Classes menu select zombie", zombieclass);
	}
	
	// Add item to list.
	AddMenuItem(menu, "", zombieselect, zombie_itemdraw);
	
		
	// List human class options.
	// -------------------------
	
	// Get current class name.
	ClassGetName(ClassSelected[client][ZR_CLASS_TEAM_HUMANS], humanclass, sizeof(humanclass), ZR_CLASS_CACHE_MODIFIED);
	
	// Check if next index is set.
	if (ClassValidateIndex(nexthuman))
	{
		// Get name of previous class index and format item text.
		ClassGetName(nexthuman, nexthumanname, sizeof(nexthumanname), ZR_CLASS_CACHE_MODIFIED);
		
		Format(humanselect, sizeof(humanselect), "%t\n	%t\n	%t", "Classes menu select human", "Classes menu active", humanclass, "Classes menu next", nexthumanname);
	}
	else
	{
		// Use current class name and format item text.
		Format(humanselect, sizeof(humanselect), "%t\n	%s", "Classes menu select human", humanclass);
	}
	
	// Add item to list.
	AddMenuItem(menu, "", humanselect, human_itemdraw);
	
	
	// List admin class options, if they exist.
	// ----------------------------------------
	
	// Only display admin class options for admins, and if admin classes exist.
	if (ZRIsClientAdmin(client) && ClassCountTeam(ZR_CLASS_TEAM_ADMINS))
	{
		// Get current class name.
		ClassGetName(ClassSelected[client][ZR_CLASS_TEAM_ADMINS], adminclass, sizeof(adminclass), ZR_CLASS_CACHE_MODIFIED);
		
		// Check if next index is set.
		if (ClassValidateIndex(nextadmin))
		{
			// Get name of previous class index and format item text.
			ClassGetName(nextadmin, nextadminname, sizeof(nextadminname), ZR_CLASS_CACHE_MODIFIED);
			Format(adminselect, sizeof(adminselect), "%t\n	%t\n	%t", "Classes menu select admin", "Classes menu active", adminclass, "Classes menu next", nextadminname);
		}
		else
		{
			// Use current class name and format item text.
			Format(adminselect, sizeof(adminselect), "%t\n	%s", "Classes menu select admin", adminclass);
		}
		
		// Add item to list.
		AddMenuItem(menu, "", adminselect, admin_itemdraw);
		
		// Set admin mode status string.
		if (ClassPlayerInAdminMode[client])
		{
			Format(adminmode, sizeof(adminmode), "%t", "On");
		}
		else
		{
			Format(adminmode, sizeof(adminmode), "%t", "Off");
		}
		
		// Spacer. ITEMDRAW_SPACER not used because it use a slot.
		AddMenuItem(menu, "", " ", ITEMDRAW_RAWLINE);
		
		// Show admin mode toggle option.
		Format(toggleadminmode, sizeof(toggleadminmode), "%t\n	%s", "Classes menu admin mode toggle", adminmode);
		AddMenuItem(menu, "", toggleadminmode, admin_itemdraw);
	}
	
	Format(title, sizeof(title), "%t\n", "Classes menu title");
	SetMenuTitle(menu, title);
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/**
 * Main class menu handler.
 */
public int ClassMenuMainHandle(Handle menu, MenuAction action, int client, int slot)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch(slot)
			{
				case 0:
				{
					ClassMenuSelect(client, ZR_CLASS_TEAM_ZOMBIES);
				}
				case 1:
				{
					ClassMenuSelect(client, ZR_CLASS_TEAM_HUMANS);
				}
				case 2:
				{
					ClassMenuSelect(client, ZR_CLASS_TEAM_ADMINS);
				}
				case 3:
				{
					// ClassToggleAdminMode(client);
					ClassMenuMain(client);
				}
			}
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if (slot == MenuCancel_ExitBack)
			{
				ZMenuMain(client);
			}
		}
	}
}

/* ------------------------------------
 *
 * ZOMBIE CLASS SELECTION MENU
 *
 * ------------------------------------
 */

/**
 * Displays the class selection menu.
 *
 * @param client	The client index.
 * @param teamid	What class types to display.
 */
void ClassMenuSelect(int client, int teamid)
{
	Handle menu = CreateMenu(ClassMenuSelectHandle);
	int arraycount;
	int classindex;
	
	char title[MENU_LINE_TITLE_LENGTH];
	char classname[MENU_LINE_REG_LENGTH];
	char description[MENU_LINE_BIG_LENGTH];
	char menuitem[MENU_LINE_HUGE_LENGTH];
	
	SetGlobalTransTarget(client);
	
	// Set correct menu title depending on team ID.
	switch (teamid)
	{
		case ZR_CLASS_TEAM_ZOMBIES:
		{
			Format(title, sizeof(title), "%t:\n", "Classes menu select zombie");
		}
		case ZR_CLASS_TEAM_HUMANS:
		{
			Format(title, sizeof(title), "%t:\n", "Classes menu select human");
		}
		case ZR_CLASS_TEAM_ADMINS:
		{
			Format(title, sizeof(title), "%t:\n", "Classes menu select admin");
		}
	}
	SetMenuTitle(menu, title);
	
	// Create buffer array.
	Handle classarray = CreateArray();
	
	// Set up filtering
	// ----------------
	int filter[ClassFilter];
	
	// Hide mother zombie classes.
	filter[ClassFilter_DenyFlags] = ZR_CLASS_FLAG_MOTHER_ZOMBIE;
	
	// Hide admin-only classes if not admin.
	filter[ClassFilter_DenyFlags] += !ZRIsClientAdmin(client) ? ZR_CLASS_FLAG_ADMIN_ONLY : 0;
	
	// Specify client for checking class group permissions.
	filter[ClassFilter_Client] = client;
	
	// Get classes
	// -----------
	
	// Copy all class indexes into the array, with the specified filter settings.
	if (ClassAddToArray(classarray, teamid, filter))
	{
		// Get number of classes.
		arraycount = GetArraySize(classarray);
		
		// Loop through each class.
		for (int i = 0; i < arraycount; i++)
		{
			// Get index, name and description.
			classindex = GetArrayCell(classarray, i);
			ClassGetName(classindex, classname, sizeof(classname), ZR_CLASS_CACHE_MODIFIED);
			ClassGetDescription(classindex, description, sizeof(description), ZR_CLASS_CACHE_MODIFIED);
			
			// Add menu item. Using extra spaces for indention on the second line.
			Format(menuitem, sizeof(menuitem), "%s\n	%s", classname, description);
			AddMenuItem(menu, classname, menuitem);
		}
	}
	
	// Destroy array.
	CloseHandle(classarray);
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/**
 * Class selection menu handler.
 */
public int ClassMenuSelectHandle(Handle menu, MenuAction action, int client, int slot)
{
	char className[MENU_LINE_REG_LENGTH];
	int classIndex;
	bool autoclose = GetConVarBool(g_hCvarsList[CVAR_CLASSES_MENU_AUTOCLOSE]);
	
	switch (action)
	{
		case MenuAction_Select:
		{
			// Get class name from the information string.
			GetMenuItem(menu, slot, className, sizeof(className));
			
			// Solve class index from the name.
			classIndex = ClassGetIndex(className);
			
			// Select (and eventually apply) class.
			ClassSelectClientClass(client, classIndex);
		}
		case MenuAction_Cancel:
		{
			if (slot == MenuCancel_ExitBack)
			{
				ClassMenuMain(client);
			}
			
			// Stop so menu doesn't reopen.
			return;
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
			
			// Stop so menu doesn't reopen.
			return;
		}
	}
	
	// Redisplay the main class menu if autoclose is disabled.
	if (!autoclose)
	{
		ClassMenuMain(client);
	}
}

/* ------------------------------------
 *
 * TEAM SELECT MENU (ADMIN)
 *
 * ------------------------------------
 */

/**
 * Displays the team selection admin menu.
 *
 * @param client	The client index.
 * @return		  True if displayed, false otherwise.
 */
bool ClassTeamSelect(int client)
{	
	// Validate permissions.
	if (!ZRIsClientPrivileged(client, OperationType_Configuration))
	{
		return false;
	}
	
	// Create menu.
	Handle menu = CreateMenu(ClassTeamSelectHandle);
	
	char title[MENU_LINE_TITLE_LENGTH];
	char zombies[MENU_LINE_SMALL_LENGTH];
	char humans[MENU_LINE_SMALL_LENGTH];
	
	// Set translation language.
	SetGlobalTransTarget(client);
	
	// Translate phrases.
	Format(title, sizeof(title), "%t", "Classes Menu Team Select Title");
	Format(zombies, sizeof(zombies), "%t", "Classes Menu Zombies");
	Format(humans, sizeof(humans), "%t", "Classes Menu Humans");
	
	SetMenuTitle(menu, title);
	
	AddMenuItem(menu, "zombies", zombies);
	AddMenuItem(menu, "humans", humans);
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return true;
}

/**
 * Team selection menu handler.
 */
public int ClassTeamSelectHandle(Handle menu, MenuAction action, int client, int slot)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch(slot)
			{
				case 0:
				{
					ClassAdminTeamSelected[client] = ZR_CLASS_TEAM_ZOMBIES;
				}
				case 1:
				{
					ClassAdminTeamSelected[client] = ZR_CLASS_TEAM_HUMANS;
				}
			}
			
			// Display multiplier menu.
			ClassMultiplierSelectMenu(client);
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if (slot == MenuCancel_ExitBack)
			{
				ZAdminMenu(client);
			}
		}
	}
}

/* ------------------------------------
 *
 * MULTIPLIER SELECT MENU (ADMIN)
 *
 * ------------------------------------
 */

/**
 * Displays the multiplier selection admin menu.
 *
 * @param client	The client index.
 */
void ClassMultiplierSelectMenu(int client)
{
	// Create menu.
	Handle menu = CreateMenu(ClassMultiplierSelectHandle);
	
	int teamid = ClassAdminTeamSelected[client];
	bool zombiesselected = view_as<bool>((teamid == ZR_CLASS_TEAM_ZOMBIES));
	
	char title[MENU_LINE_TITLE_LENGTH];
	char napalmtime[MENU_LINE_REG_LENGTH];
	char health[MENU_LINE_REG_LENGTH];
	char regeninterval[MENU_LINE_REG_LENGTH];
	char regenamount[MENU_LINE_REG_LENGTH];
	char infectgain[MENU_LINE_REG_LENGTH];
	char speed[MENU_LINE_REG_LENGTH];
	char knockback[MENU_LINE_REG_LENGTH];
	char jumpheight[MENU_LINE_REG_LENGTH];
	char jumpdistance[MENU_LINE_REG_LENGTH];
	
	float currentnapalmtime;
	float currenthealth;
	float currentregeninterval;
	float currentregenamount;
	float currentinfectgain;
	float currentspeed;
	float currentknockback;
	float currentjumpheight;
	float currentjumpdistance;
	
	// Get current multipliers.
	currentnapalmtime = view_as<float>(ClassMultiplierCache[teamid][ClassM_NapalmTime]);
	currenthealth = view_as<float>(ClassMultiplierCache[teamid][ClassM_Health]);
	currentregeninterval = view_as<float>(ClassMultiplierCache[teamid][ClassM_HealthRegenInterval]);
	currentregenamount = view_as<float>(ClassMultiplierCache[teamid][ClassM_HealthRegenAmount]);
	currentinfectgain = view_as<float>(ClassMultiplierCache[teamid][ClassM_HealthInfectGain]);
	currentspeed = view_as<float>(ClassMultiplierCache[teamid][ClassM_Speed]);
	currentknockback = view_as<float>(ClassMultiplierCache[teamid][ClassM_Knockback]);
	currentjumpheight = view_as<float>(ClassMultiplierCache[teamid][ClassM_JumpHeight]);
	currentjumpdistance = view_as<float>(ClassMultiplierCache[teamid][ClassM_JumpDistance]);
	
	SetGlobalTransTarget(client);
	
	// Translate phrases.
	Format(title, sizeof(title), "%t\n", "Classes Menu Multiplier Select Title");
	Format(health, sizeof(health), "%t\n	%.2f", "Classes Attrib Health", currenthealth);
	Format(regeninterval, sizeof(regeninterval), "%t\n	%.2f", "Classes Attrib Regen Interval", currentregeninterval);
	Format(regenamount, sizeof(regenamount), "%t\n	%.2f", "Classes Attrib Regen Amount", currentregenamount);
	Format(speed, sizeof(speed), "%t\n	%.2f", "Classes Attrib Speed", currentspeed);
	Format(jumpheight, sizeof(jumpheight), "%t\n	%.2f", "Classes Attrib Jump Height", currentjumpheight);
	Format(jumpdistance, sizeof(jumpdistance), "%t\n	%.2f", "Classes Attrib Jump Distance", currentjumpdistance);
	
	// Only translate zombie phrases if zombie team is selected.
	if (zombiesselected)
	{
		Format(napalmtime, sizeof(napalmtime), "%t\n	%.2f", "Classes Attrib Napalm Time", currentnapalmtime);
		Format(infectgain, sizeof(infectgain), "%t\n	%.2f", "Classes Attrib Infect Gain", currentinfectgain);
		Format(knockback, sizeof(knockback), "%t\n	%.2f", "Classes Attrib Knockback", currentknockback);
	}
	
	SetMenuTitle(menu, title);
	
	// Add items. Don't add zombie attributes if human team is selected.
	if (zombiesselected) AddMenuItem(menu, "napalmtime", napalmtime);
	AddMenuItem(menu, "health", health);
	AddMenuItem(menu, "regeninterval", regeninterval);
	AddMenuItem(menu, "regenamount", regenamount);
	if (zombiesselected) AddMenuItem(menu, "infectgain", infectgain);
	AddMenuItem(menu, "speed", speed);
	if (zombiesselected) AddMenuItem(menu, "knockback", knockback);
	AddMenuItem(menu, "jumpheight", jumpheight);
	AddMenuItem(menu, "jumpdistance", jumpdistance);
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/**
 * Multiplier select menu handler.
 */
public int ClassMultiplierSelectHandle(Handle menu, MenuAction action, int client, int slot)
{
	char attributename[48];
	ClassMultipliers attribute;
	
	switch (action)
	{
		case MenuAction_Select:
		{
			// Get attribute name.
			GetMenuItem(menu, slot, attributename, sizeof(attributename));
			
			// Initialize in case of errors.
			attribute = ClassM_Knockback;
			
			// Convert type.
			if (StrEqual(attributename, "napalmtime", false))
			{
				attribute = ClassM_NapalmTime;
			}
			else if (StrEqual(attributename, "health", false))
			{
				attribute = ClassM_Health;
			}
			else if (StrEqual(attributename, "regeninterval", false))
			{
				attribute = ClassM_HealthRegenInterval;
			}
			else if (StrEqual(attributename, "regenamount", false))
			{
				attribute = ClassM_HealthRegenAmount;
			}
			else if (StrEqual(attributename, "infectgain", false))
			{
				attribute = ClassM_HealthInfectGain;
			}
			else if (StrEqual(attributename, "speed", false))
			{
				attribute = ClassM_Speed;
			}
			else if (StrEqual(attributename, "knockback", false))
			{
				attribute = ClassM_Knockback;
			}
			else if (StrEqual(attributename, "jumpheight", false))
			{
				attribute = ClassM_JumpHeight;
			}
			else if (StrEqual(attributename, "jumpdistance", false))
			{
				attribute = ClassM_JumpDistance;
			}
			
			// Display multiplier menu for the selected attribute.
			ClassMultiplierMenu(client, attribute);
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if (slot == MenuCancel_ExitBack)
			{
				ClassTeamSelect(client);
			}
		}
	}
}

/* ------------------------------------
 *
 * MULTIPLIER MENU (ADMIN)
 *
 * ------------------------------------
 */

/**
 * Displays multiplier menu for the specified attribute.
 */
void ClassMultiplierMenu(int client, ClassMultipliers attribute)
{
	// Cache selected attribute.
	ClassAdminAttributeSelected[client] = attribute;
	
	Handle menu = CreateMenu(ClassMultiplierHandle);
	
	char title[MENU_LINE_TITLE_LENGTH];
	char attributename[MENU_LINE_REG_LENGTH];
	char linebuffer[MENU_LINE_REG_LENGTH];
	
	// Get attribute string.
	ClassMultiplierToString(client, attribute, attributename, sizeof(attributename));
	
	SetGlobalTransTarget(client);
	Format(title, sizeof(title), "%t %s\n%t %.2f\n", "Classes Menu Adjust Value", attributename, "Current Value", view_as<float>(ClassMultiplierCache[ClassAdminTeamSelected[client]][attribute]));
	SetMenuTitle(menu, title);
	
	SetGlobalTransTarget(client);
	Format(linebuffer, sizeof(linebuffer), "%t", "Increase by", "0.5");
	AddMenuItem(menu, "increasehalf", linebuffer);
	Format(linebuffer, sizeof(linebuffer), "%t", "Increase by", "0.1");
	AddMenuItem(menu, "increasedeci", linebuffer);
	Format(linebuffer, sizeof(linebuffer), "%t", "Decrease by", "0.1");
	AddMenuItem(menu, "decreasedeci", linebuffer);
	Format(linebuffer, sizeof(linebuffer), "%t", "Decrease by", "0.5");
	AddMenuItem(menu, "decreasehalf", linebuffer);
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ClassMultiplierHandle(Handle menu, MenuAction action, int client, int slot)
{
	float value;
	
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (slot)
			{
				case 0:
				{
					value = 0.5;
				}
				case 1:
				{
					value = 0.1;
				}
				case 2:
				{
					value = -0.1;
				}
				case 3:
				{
					value = -0.5;
				}
			}
			
			// Update multiplier.
			ClassAddToMultiplier(ClassAdminTeamSelected[client], ClassAdminAttributeSelected[client], value);
			
			// Re-display menu.
			ClassMultiplierMenu(client, ClassAdminAttributeSelected[client]);
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if (slot == MenuCancel_ExitBack)
			{
				ClassMultiplierSelectMenu(client);
			}
		}
	}
}

/**
 * Add to the specified multiplier.
 *
 * @param teamid		The team to filter.
 * @param attribute	 The attribute to add to.
 * @param value		 Value to add.
 */
void ClassAddToMultiplier(int teamid, ClassMultipliers attribute, float value)
{
	ClassMultiplierCache[teamid][attribute] = ClassMultiplierCache[teamid][attribute] + value;
}
