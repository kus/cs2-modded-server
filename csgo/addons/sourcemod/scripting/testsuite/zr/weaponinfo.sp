/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  weaponinfo.sp
 *  Type:		  Test plugin
 *  Description:   Dumps weapon information.
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

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "Weapon information",
	author = "Greyscale | Richard Helgeby",
	description = "Dumps weapon information.",
	version = "1.0.0",
	url = "http://code.google.com/p/zombiereloaded/"
};

new m_hActiveWeapon;
new m_hMyWeapons;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	m_hActiveWeapon = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
	if (m_hActiveWeapon == -1)
	{
		LogError("Can't find CBasePlayer::m_hActiveWeapon");
	}
	
	m_hMyWeapons = FindSendPropOffs("CBasePlayer", "m_hMyWeapons");
	if (m_hMyWeapons == -1)
	{
		LogError("Can't find CBasePlayer::m_hMyWeapons");
	}
	
	RegConsoleCmd("zrtest_weaponslots", Command_ListWeaponSlots, "Lists weapon slots. Usage: zrtest_weaponslots [target]");
	RegConsoleCmd("zrtest_weaponlist", Command_ListWeapons, "Lists all weapons. Usage: zrtest_weaponlist [target]");
	RegConsoleCmd("zrtest_knife", Command_Knife, "Gives a knife. Usage: zrtest_knife [target]");
	RegConsoleCmd("zrtest_removeweapons", Command_RemoveWeapons, "Removes all weapons. Usage: zrtest_removeweapons [target]");
}

public Action:Command_ListWeaponSlots(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	
	if (target <= 0)
	{
		ReplyToCommand(client, "Lists weapon slots. Usage: zrtest_weaponlist [target]");
		return Plugin_Handled;
	}
	
	if (argc >= 1)
	{
		ListWeaponSlots(target, client);
	}
	else
	{
		ListWeaponSlots(client, client);
	}
	
	return Plugin_Handled;
}

public Action:Command_ListWeapons(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	
	if (target <= 0)
	{
		ReplyToCommand(client, "Lists all weapon. Usage: zrtest_weaponlist [target]");
		return Plugin_Handled;
	}
	
	if (argc >= 1)
	{
		ListWeapons(target, client);
	}
	else
	{
		ListWeapons(client, client);
	}
	
	return Plugin_Handled;
}

public Action:Command_Knife(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	
	if (target <= 0)
	{
		ReplyToCommand(client, "Gives a knife. Usage: zrtest_knife [target]");
		return Plugin_Handled;
	}
	
	if (argc >= 1)
	{
		GiveKnife(target);
	}
	else
	{
		GiveKnife(client);
	}
	
	return Plugin_Handled;
}

public Action:Command_RemoveWeapons(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	
	if (target <= 0)
	{
		ReplyToCommand(client, "Removes all weapons. Usage: zrtest_removeweapons [target]");
		return Plugin_Handled;
	}
	
	if (argc >= 1)
	{
		RemoveAllClientWeapons(target, client);
	}
	else
	{
		RemoveAllClientWeapons(client, client);
	}
	
	return Plugin_Handled;
}

/**
 * Lists weapon entity indexes in each weapon slot.
 *
 * @param client		Source client.
 * @param observer	  Client that will receive output.
 * @param count		 Optional. Number of slots to check.
 **/
ListWeaponSlots(client, observer, count = 10)
{
	ReplyToCommand(observer, "Slot:\tEntity:\tClassname:");
	
	// Loop through slots.
	for (new slot = 0; slot < count; slot++)
	{
		new weapon = GetPlayerWeaponSlot(client, slot);
			
		if (weapon < 0)
		{
			ReplyToCommand(observer, "%d\t(empty/invalid)", slot);
			continue;
		}
		
		new String:classname[64];
		GetEntityClassname(weapon, classname, sizeof(classname));
		
		ReplyToCommand(observer, "%d\t%d\t%s", slot, weapon, classname);
	}
}

/**
 * Lists all weapons.
 *
 * @param client		Source client.
 * @param observer	  Client that will receive output.
 */
ListWeapons(client, observer)
{
	ReplyToCommand(observer, "Offset:\tEntity:\tClassname:");
	
	// Loop through entries in m_hMyWeapons.
	for(new offset = 0; offset < 128; offset += 4)	 // +4 to skip to next entry in array.
	{
		new weapon = GetEntDataEnt2(client, m_hMyWeapons + offset);
		
		if (weapon < 0)
		{
			ReplyToCommand(observer, "%d\t(empty/invalid)", offset);
			continue;
		}
		
		new String:classname[64];
		GetEntityClassname(weapon, classname, sizeof(classname));
		
		ReplyToCommand(observer, "%d\t%d\t%s", offset, weapon, classname);
	}
}

/**
 * Remove all weapons.
 * 
 * @param client		Source client.
 * @param observer	  Client that will receive output.
 * @param count		 Optional. Number of slots to list.
 */
RemoveAllClientWeapons(client, observer, count = 5)
{
	// Loop through weapon slots.
	for (new slot = 0; slot < count; slot++)
	{
		new weapon = GetPlayerWeaponSlot(client, slot);
		
		// Remove all weapons in this slot.
		while (weapon > 0)
		{
			// Remove weapon entity.
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
			
			ReplyToCommand(observer, "Removed weapon in slot %d.", slot);
			
			// Get next weapon in this slot, if any.
			weapon = GetPlayerWeaponSlot(client, slot);
		}
	}
}

GiveKnife(client)
{
	GivePlayerItem(client, "weapon_knife");
}
