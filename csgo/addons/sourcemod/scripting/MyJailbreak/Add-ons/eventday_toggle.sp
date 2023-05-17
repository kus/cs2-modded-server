/*
 * MyJailbreak - EventDay Toggle Plugin.
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

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Handles
ArrayList g_hNames;
StringMap g_hCommandTrie;
StringMap g_hConVarTrie;
StringMap g_hPluginTrie;

// Strings
char g_sFile[100];

// Start
public Plugin myinfo =
{
	name = "MyJailbreak - EventDay Toggle",
	author = "shanapu",
	description = "Toggle commands, convars & plugins on event days",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Info
public void OnPluginStart()
{
	//Configs Path
	BuildPath(Path_SM, g_sFile, sizeof(g_sFile), "configs/MyJailbreak/eventday_toggle.cfg");

	g_hNames = new ArrayList(32);

	g_hCommandTrie = new StringMap();
	g_hConVarTrie = new StringMap();
	g_hPluginTrie = new StringMap();
}


public void OnConfigsExecuted()
{
	g_hNames.Clear();

	g_hCommandTrie.Clear();
	g_hConVarTrie.Clear();
	g_hPluginTrie.Clear();

	File hFile = OpenFile(g_sFile, "rt");

	if (hFile == null)
	{
		delete hFile;
		SetFailState("MyJailbreak EventDay Toggle - Can't open File: %s", g_sFile);
	}
	delete hFile;

	KeyValues kvMenu = new KeyValues("Toggle");

	if (!kvMenu.ImportFromFile(g_sFile))
	{
		delete kvMenu;
		SetFailState("MyJailbreak EventDay Toggle - Can't read %s correctly! (ImportFromFile)", g_sFile);
	}

	if (!kvMenu.GotoFirstSubKey())
	{
		delete kvMenu;
		SetFailState("MyJailbreak EventDay Toggle - Can't read %s correctly! (GotoFirstSubKey)", g_sFile);
	}
	do
	{
		char sName[32];
		char sType[32];

		char sAction[64];

		kvMenu.GetSectionName(sName, sizeof(sName));
		kvMenu.GetString("type", sType, sizeof(sType));

		if (StrEqual(sType, "convar"))
		{
			kvMenu.GetString("action", sAction, sizeof(sAction));
			g_hConVarTrie.SetString(sName, sAction);
		}
		else if (StrEqual(sType, "command"))
		{
			kvMenu.GetString("action", sAction, sizeof(sAction));
			g_hCommandTrie.SetString(sName, sAction);
		}
		else if (StrEqual(sType, "plugin"))
		{
			kvMenu.GetString("action", sAction, sizeof(sAction));
			g_hPluginTrie.SetString(sName, sAction);
		}
		g_hNames.PushString(sName);

	}
	while (kvMenu.GotoNextKey());

	delete kvMenu;
}

public void MyJailbreak_OnEventDayStart(char[] EventDayName)
{
	for (int i = 0; i < g_hNames.Length; i++)
	{
		char sBuffer[64], sValue[32];
		g_hNames.GetString(i, sBuffer, sizeof(sBuffer));

		if (GetTrieString(g_hConVarTrie, sBuffer, sValue, sizeof(sValue)))
		{
			ConVar cBuffer = FindConVar(sBuffer);
			if(cBuffer == null)
			{
				LogError("ConVar '%s' not found! Can't set value '%s' on Event Day start", sBuffer, sValue);
				continue;
			}

			char sOldValue[32];
			cBuffer.GetString(sOldValue, sizeof(sOldValue));
			g_hConVarTrie.SetString(sBuffer, sOldValue);

			SetCvarString(sBuffer, sValue);
		}
		else if (GetTrieString(g_hCommandTrie, sBuffer, sValue, sizeof(sValue)))
		{
			if(StrEqual(sValue, "block"))
			{
				int flags = GetCommandFlags(sBuffer);
				if(flags == INVALID_FCVAR_FLAGS)
				{
					LogError("Command '%s' not found! Can't block it on Event Day start", sBuffer);
					continue;
				}

				SetCommandFlags(sBuffer, flags | FCVAR_CHEAT);
			}
			else if(StrEqual(sValue, "execute"))
			{
				ServerCommand(sBuffer);
			}
		}
		else if (GetTrieString(g_hPluginTrie, sBuffer, sValue, sizeof(sValue)))
		{
			ServerCommand("sm plugins %s %s", sValue, sBuffer);
		}
	}
}

public void MyJailbreak_OnEventDayEnd(char[] EventDayName, int winner)
{
	for (int i = 0; i < g_hNames.Length; i++)
	{
		char sBuffer[64], sValue[32];
		g_hNames.GetString(i, sBuffer, sizeof(sBuffer));

		if (GetTrieString(g_hConVarTrie, sBuffer, sValue, sizeof(sValue)))
		{
			ConVar cBuffer = FindConVar(sBuffer);
			if(cBuffer == null)
			{
				LogError("ConVar '%s' not found! Can't set default value '%s' on Event Day end", sBuffer, sValue);
				continue;
			}

			char sOldValue[32];
			cBuffer.GetString(sOldValue, sizeof(sOldValue));
			g_hConVarTrie.SetString(sBuffer, sOldValue);

			SetCvarString(sBuffer, sValue);
		}
		else if (GetTrieString(g_hCommandTrie, sBuffer, sValue, sizeof(sValue)))
		{
			if(StrEqual(sValue, "block"))
			{
				int flags = GetCommandFlags(sBuffer);
				if(flags == INVALID_FCVAR_FLAGS)
				{
					LogError("Command '%s' not found! Can't unblock it on Event Day end", sBuffer);
					continue;
				}

				SetCommandFlags(sBuffer, flags ^ FCVAR_CHEAT);
			}
		}
		else if (GetTrieString(g_hPluginTrie, sBuffer, sValue, sizeof(sValue)))
		{
			if (StrEqual(sValue, "load"))
			{
				ServerCommand("sm plugins %s %s", "unload", sBuffer);
			}
			else if (StrEqual(sValue, "unload"))
			{
				ServerCommand("sm plugins %s %s", "load", sBuffer);
			}
		}
	}
}