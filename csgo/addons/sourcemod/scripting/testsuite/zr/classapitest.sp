/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  classapitest.sp
 *  Type:		  Test plugin
 *  Description:   Tests the class API.
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
#include <zombiereloaded>

public Plugin:myinfo =
{
	name = "Zombie:Reloaded Class API Test",
	author = "Greyscale | Richard Helgeby",
	description = "Tests the class API for ZR",
	version = "1.0.0",
	url = "http://code.google.com/p/zombiereloaded/"
};

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	RegConsoleCmd("zrtest_is_valid_class_index", IsValidClassCommand, "Returns whether the specified class index is valid or not. Usage: zrtest_is_valid_class_index <class index>");
	RegConsoleCmd("zrtest_get_active_class", GetActiveClassCommand, "Gets the current class the specified player is using. Usage: zrtest_get_active_class <target>");
	RegConsoleCmd("zrtest_select_class", SelectClassCommand, "Selects a class for a player. Usage: zrtest_select_class <target> <class index>");
	RegConsoleCmd("zrtest_get_class_by_name", GetClassCommand, "Gets class index by class name. Usage: zrtest_get_class_by_name <class name>");
	RegConsoleCmd("zrtest_get_class_display_name", GetNameCommand, "Gets class display name. Usage: zrtest_get_class_display_name <class index>");
}

public Action:IsValidClassCommand(client, argc)
{
	new classIndex = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		classIndex = StringToInt(valueString);
	}
	else
	{
		ReplyToCommand(client, "Returns whether the specified class index is valid or not. Usage: zrtest_is_valid_class_index <class index>");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Class %d is valid: %d", classIndex, ZR_IsValidClassIndex(classIndex));
	
	return Plugin_Handled;
}

public Action:GetActiveClassCommand(client, argc)
{
	new target = -1;
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
	}
	else
	{
		ReplyToCommand(client, "Gets the current class the specified player is using. Usage: zrtest_get_active_class <target>");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Active class of client %d: %d", target, ZR_GetActiveClass(target));
	
	return Plugin_Handled;
}

public Action:SelectClassCommand(client, argc)
{
	new target = -1;
	new classIndex = -1;
	new bool:applyIfPossible = true;
	new bool:saveIfEnabled = true;
	
	new String:valueString[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		target = FindTarget(client, valueString);
		
		GetCmdArg(2, valueString, sizeof(valueString));
		classIndex = StringToInt(valueString);
		
		if (argc >= 4)
		{
			GetCmdArg(3, valueString, sizeof(valueString));
			applyIfPossible = bool:StringToInt(valueString);
			
			GetCmdArg(4, valueString, sizeof(valueString));
			saveIfEnabled = bool:StringToInt(valueString);
		}
	}
	else
	{
		ReplyToCommand(client, "Selects a class for a player. Usage: zrtest_select_class <target> <class index> [<apply if possible> <save if enabled>]");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Selected class %d for client %d. Result: %d", classIndex, target, ZR_SelectClientClass(target, classIndex, applyIfPossible, saveIfEnabled));
	
	return Plugin_Handled;
}

public Action:GetClassCommand(client, argc)
{
	new String:className[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, className, sizeof(className));
	}
	else
	{
		ReplyToCommand(client, "Gets class index by class name. Usage: zrtest_get_class_by_name <class name>");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Class index of \"%s\": %d", className, ZR_GetClassByName(className));
	
	return Plugin_Handled;
}

public Action:GetNameCommand(client, argc)
{
	new classIndex = -1;
	new String:valueString[64];
	new String:displayName[64];
	
	if (argc >= 1)
	{
		GetCmdArg(1, valueString, sizeof(valueString));
		classIndex = StringToInt(valueString);
		
		if (!ZR_IsValidClassIndex(classIndex))
		{
			ReplyToCommand(client, "Invalid class index: %d", classIndex);
			return Plugin_Handled;
		}
	}
	else
	{
		ReplyToCommand(client, "Gets class display name. Usage: zrtest_get_class_display_name <class index>");
		return Plugin_Handled;
	}
	
	ZR_GetClassDisplayName(classIndex, displayName, sizeof(displayName));
	ReplyToCommand(client, "Display name of class %d: \"%s\"", classIndex, displayName);
	
	return Plugin_Handled;
}
