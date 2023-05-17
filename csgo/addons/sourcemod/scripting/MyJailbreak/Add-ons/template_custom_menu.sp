/*
 * MyJailbreak - TEMPLATE Custom Menu Items Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */


// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <myjailbreak>
#include <mystocks>
#include <warden>
#include <myjbwarden>


// Compiler Options
#pragma semicolon 1
#pragma newdecls required


// Start
public Plugin myinfo =
{
	name = "MyJailbreak - Add Custom Menu items - Template",
	author = "shanapu",
	description = "",
	version = "",
	url = "https://github.com/shanapu"
};


// Here we add an new item to the beginn of the menu
public void MyJailbreak_MenuStart(int client, Menu menu)
{
	if (warden_iswarden(client))
	{
		char info[64];
		Format(info, sizeof(info), "New Item on beginn for Warden");

		menu.AddItem("WardenSay", info);
	}
	else if (warden_deputy_isdeputy(client))
	{
		char info[64];
		Format(info, sizeof(info), "New Item on beginn for Deputy");

		menu.AddItem("DeputySay", info);
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		char info[64];
		Format(info, sizeof(info), "New Item on beginn for Guards");

		menu.AddItem("GuardSay", info);
	}
	else if (GetClientTeam(client) == CS_TEAM_T)
	{
		char info[64];
		Format(info, sizeof(info), "New Item on beginn for Prisoner");

		menu.AddItem("PrisonerSay", info);
	}
}


// Here we add an new item to the end of themenu
public void MyJailbreak_MenuEnd(int client, Menu menu)
{
	if (warden_iswarden(client))
	{
		char info[64];
		Format(info, sizeof(info), "New Item on end for Warden");

		menu.AddItem("WardenSay", info);
	}
	else if (warden_deputy_isdeputy(client))
	{
		char info[64];
		Format(info, sizeof(info), "New Item on end for Deputy");

		menu.AddItem("DeputySay", info);
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		char info[64];
		Format(info, sizeof(info), "New Item on end for Guards");

		menu.AddItem("GuardSay", info);
	}
	else if (GetClientTeam(client) == CS_TEAM_T)
	{
		char info[64];
		Format(info, sizeof(info), "New Item on end for Prisoner");

		menu.AddItem("PrisonerSay", info);
	}
}


// What should we do when new item was picked?
public void MyJailbreak_MenuHandler(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		if (IsValidClient(client, false, true))
		{
			char info[64];
			menu.GetItem(itemNum, info, sizeof(info));

			if (StrEqual(info, "WardenSay"))
			{
				FakeClientCommand(client, "say warden test item!");
			}
			else if (StrEqual(info, "DeputySay"))
			{
				FakeClientCommand(client, "say deputy test item!");
			}
			else if (StrEqual(info, "GuardSay"))
			{
				FakeClientCommand(client, "say guard test item!");
			}
			else if (StrEqual(info, "PrisonerSay"))
			{
				FakeClientCommand(client, "say prisoner test item!");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}


// Remove this part for your own custom plugin!
public void OnMapStart()
{
	SetFailState("This file is an template for developer and should'nt run on productive servers! please remove");
}

