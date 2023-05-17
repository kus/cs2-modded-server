/*
 * MyJailbreak - Custom Menu Items Plugin.
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

// Handles
Handle g_hCommandTrie;

// Strings
char g_sMenuFile[64];

// Start
public Plugin myinfo =
{
	name = "MyJailbreak - Custom Menu items",
	author = "shanapu",
	description = "Additional menu item per cfg",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Info
public void OnPluginStart()
{
	//Configs Path
	BuildPath(Path_SM, g_sMenuFile, sizeof(g_sMenuFile), "configs/MyJailbreak/menu_custom.cfg");
	g_hCommandTrie = CreateTrie();
}


// Here we add an new item to the beginn of the menu
public void MyJailbreak_MenuStart(int client, Menu menu)
{
	File hFile = OpenFile(g_sMenuFile, "rt");

	if (hFile == null)
	{
		delete hFile;
		SetFailState("MyJailbreak Menu - Can't open File: %s", g_sMenuFile);
	}
	delete hFile;

	KeyValues kvMenu = new KeyValues("CustomMenuItems");

	if (!kvMenu.ImportFromFile(g_sMenuFile))
	{
		delete kvMenu;
		SetFailState("MyJailbreak Menu - Can't read %s correctly! (ImportFromFile)", g_sMenuFile);
	}

	if (!kvMenu.GotoFirstSubKey())
	{
		delete kvMenu;
		SetFailState("MyJailbreak Menu - Can't read %s correctly! (GotoFirstSubKey)", g_sMenuFile);
	}
	do
	{
		char sID[32];

		kvMenu.GetString("postion", sID, sizeof(sID));
		if (!StrEqual(sID, "top", false))
		{
			continue;
		}

		char sTitle[64];
		char sRole[32];
		char sFlags[64];
		char sCommand[64];

		kvMenu.GetSectionName(sID, sizeof(sID));
		kvMenu.GetString("title", sTitle, sizeof(sTitle));
		kvMenu.GetString("role", sRole, sizeof(sRole));
		kvMenu.GetString("flags", sFlags, sizeof(sFlags));
		kvMenu.GetString("command", sCommand, sizeof(sCommand));

		if (!CheckVipFlag(client, sFlags))
			continue;

		if (warden_iswarden(client))
		{
			if (StrContains(sRole, "1") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (warden_deputy_isdeputy(client))
		{
			if (StrContains(sRole, "2") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			if (StrContains(sRole, "3") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (GetClientTeam(client) == CS_TEAM_T)
		{
			if (StrContains(sRole, "4") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
		{
			if (StrContains(sRole, "5") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}

		SetTrieString(g_hCommandTrie, sID, sCommand);

	}
	while (kvMenu.GotoNextKey());

	delete kvMenu;

}


// Here we add an new item to the end of the menu
public void MyJailbreak_MenuEnd(int client, Menu menu)
{
	File hFile = OpenFile(g_sMenuFile, "rt");

	if (hFile == null)
	{
		delete hFile;
		SetFailState("MyJailbreak Menu - Can't open File: %s", g_sMenuFile);
	}

	KeyValues kvMenu = new KeyValues("CustomMenuItems");

	if (!kvMenu.ImportFromFile(g_sMenuFile))
	{
		delete kvMenu;
		SetFailState("MyJailbreak Menu - Can't read %s correctly! (ImportFromFile)", g_sMenuFile);
	}

	if (!kvMenu.GotoFirstSubKey())
	{
		delete kvMenu;

		SetFailState("MyJailbreak Menu - Can't read %s correctly! (GotoFirstSubKey)", g_sMenuFile);
	}
	do
	{
		char sID[32];

		kvMenu.GetString("postion", sID, sizeof(sID));
		if (!StrEqual(sID, "bottom", false))
		{
			continue;
		}

		char sTitle[64];
		char sRole[32];
		char sFlags[64];
		char sCommand[64];

		kvMenu.GetSectionName(sID, sizeof(sID));
		kvMenu.GetString("title", sTitle, sizeof(sTitle));
		kvMenu.GetString("role", sRole, sizeof(sRole));
		kvMenu.GetString("flags", sFlags, sizeof(sFlags));
		kvMenu.GetString("command", sCommand, sizeof(sCommand));

		if (!CheckVipFlag(client, sFlags))
			continue;

		if (warden_iswarden(client))
		{
			if (StrContains(sRole, "1") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (warden_deputy_isdeputy(client))
		{
			if (StrContains(sRole, "2") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			if (StrContains(sRole, "3") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (GetClientTeam(client) == CS_TEAM_T)
		{
			if (StrContains(sRole, "4") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
		{
			if (StrContains(sRole, "5") != -1)
			{
				menu.AddItem(sID, sTitle);
			}
		}
		SetTrieString(g_hCommandTrie, sID, sCommand);

	}
	while (kvMenu.GotoNextKey());

	delete hFile;
	delete kvMenu;
}


// What should we do when new item was picked?
public void MyJailbreak_MenuHandler(Menu menu, MenuAction action, int client, int itemNum)
{
	char command[24];

	if (action == MenuAction_Select)
	{
		if (IsValidClient(client, false, true))
		{
			char info[64];
			menu.GetItem(itemNum, info, sizeof(info));

			if (GetTrieString(g_hCommandTrie, info, command, sizeof(command)))
			{
				FakeClientCommand(client, command);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}