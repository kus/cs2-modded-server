/*
 * MyJailbreak - Warden Deputy Module.
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

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <myjbwarden>
#include <mystocks>
#include <smartdm>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bDeputy;
ConVar gc_sModelPathDeputy;
ConVar gc_sCustomCommandDeputy;
ConVar gc_sCustomCommandUnDeputy;
ConVar gc_sCustomCommandRemoveDeputy;
ConVar gc_bSetDeputy;
ConVar gc_bRemoveLRDeputy;
ConVar gc_bBecomeDeputy;
ConVar gc_bModelDeputy;
ConVar gc_bWardenDead;

// Handles
Handle gF_OnDeputyCreated;
Handle gF_OnDeputyRemoved;

// Integers
int g_iDeputy = -1;
int g_iLastDeputy = -1;
int g_iDeputyDelay;

// Strings
char g_sModelDeputyPathPrevious[256];
char g_sModelPathDeputy[256];

// Start
public void Deputy_OnPluginStart() 
{
	// Client commands
	RegConsoleCmd("sm_deputy", Command_SetDeputy, "Allows the warden to choose a deputy or a player to be deputy");
	RegConsoleCmd("sm_undeputy", Command_ExitDeputy, "Allows the warden to remove the deputy and the deputy to retire from the position");

	// Admin commands
	RegAdminCmd("sm_removedeputy", AdminCommand_RemoveDeputy, ADMFLAG_GENERIC);

	// Forwards
	gF_OnDeputyCreated = CreateGlobalForward("warden_OnDeputyCreated", ET_Ignore, Param_Cell);
	gF_OnDeputyRemoved = CreateGlobalForward("warden_OnDeputyRemoved", ET_Ignore, Param_Cell);

	// AutoExecConfig
	AutoExecConfig_SetFile("Warden", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	gc_bDeputy = AutoExecConfig_CreateConVar("sm_warden_deputy_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_bSetDeputy = AutoExecConfig_CreateConVar("sm_warden_deputy_set", "1", "0 - disabled, 1 - enable !w / !deputy - warden can choose his deputy.", _, true, 0.0, true, 1.0);
	gc_bBecomeDeputy = AutoExecConfig_CreateConVar("sm_warden_deputy_become", "1", "0 - disabled, 1 - enable !w / !deputy - player can choose to be deputy.", _, true, 0.0, true, 1.0);
	gc_bRemoveLRDeputy = AutoExecConfig_CreateConVar("sm_warden_deputy_remove_lr", "0", "0 - disabled, 1 - enable deputy will be removed on last request", _, true, 0.0, true, 1.0);
	gc_bModelDeputy = AutoExecConfig_CreateConVar("sm_warden_deputy_model", "1", "0 - disabled, 1 - enable deputy model", 0, true, 0.0, true, 1.0);
	gc_sModelPathDeputy = AutoExecConfig_CreateConVar("sm_warden_deputy_model_path", "models/player/custom_player/kuristaja/jailbreak/guard3/guard3.mdl", "Path to the model for deputy.");
	gc_sCustomCommandDeputy = AutoExecConfig_CreateConVar("sm_warden_cmds_deputy", "d", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_sCustomCommandUnDeputy = AutoExecConfig_CreateConVar("sm_warden_cmds_undeputy", "ud", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_sCustomCommandRemoveDeputy = AutoExecConfig_CreateConVar("sm_warden_cmds_removedeputy", "rd, fd", "Set your custom chat commands for admins to remove a warden(!removewarden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_bWardenDead = AutoExecConfig_CreateConVar("sm_warden_deputy_warden_dead", "1", "0 - Deputy will removed on warden death, 1 - Deputy will be new warden", _, true, 0.0, true, 1.0);

	// Hooks
	HookEvent("round_start", Deputy_Event_RoundStart);
	HookEvent("player_death", Deputy_Event_PlayerDeath);
	HookEvent("player_team", Deputy_Event_PlayerTeam);
	HookConVarChange(gc_sModelPathDeputy, Deputy_OnSettingChanged);

	// FindConVar
	gc_sModelPathDeputy.GetString(g_sModelPathDeputy, sizeof(g_sModelPathDeputy));
}

// ConVarChange for Strings
public void Deputy_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sModelPathDeputy)
	{
		strcopy(g_sModelPathDeputy, sizeof(g_sModelPathDeputy), newValue);
		if (gc_bModelDeputy.BoolValue) 
		{
			Downloader_AddFileToDownloadsTable(g_sModelPathDeputy);
			PrecacheModel(g_sModelPathDeputy);
		}
	}
}

// Initialize Plugin
public void Deputy_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Set Deputy
	gc_sCustomCommandDeputy.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_SetDeputy, "Allows the warden to choose a deputy or a player to be deputy");
	}

	// UnDeputy
	gc_sCustomCommandUnDeputy.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_ExitDeputy, "Allows the warden to remove the deputy and the deputy to retire from the position");
	}

	// RemoveDeputy
	gc_sCustomCommandRemoveDeputy.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegAdminCmd(sCommand, AdminCommand_RemoveDeputy, ADMFLAG_GENERIC);
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Become Deputy
public Action Command_SetDeputy(int client, int args)
{
	if (!gc_bDeputy.BoolValue || !gc_bPlugin.BoolValue || !g_bEnabled || g_bIsLR)
	{
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_disabled");

		return Plugin_Handled;
	}

	if (g_iDeputy == -1)  // Is there already a deputy
	{
		if (g_iWarden != -1)  // Is there a warden
		{
			if ((gc_bBecomeDeputy.BoolValue && !IsClientWarden(client)) || (gc_bSetDeputy.BoolValue && IsClientWarden(client)))  // "sm_warden_deputy_become" "1"
			{
				if (GetClientTeam(client) == CS_TEAM_CT)  // Is player a guard
				{
					if (IsPlayerAlive(client))  // Alive?
					{
						if (!IsClientWarden(client)) SetTheDeputy(client);
						else Menu_SetDeputy(client);
					}
					else CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_playerdead");
				}
				else CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_ctsonly");
			}
			else if (!gc_bBecomeDeputy.BoolValue && !IsClientWarden(client)) CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_nobecome");
			else if (!gc_bSetDeputy.BoolValue && IsClientWarden(client)) CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_noset");
		}
		else CPrintToChat(client, "%s %t", g_sPrefix, "warden_nowarden");
	}
	else CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_exist", g_iDeputy);
	
	return Plugin_Handled;
}

// Exit / Retire Deputy
public Action Command_ExitDeputy(int client, int args) 
{
	if (!gc_bDeputy.BoolValue || !gc_bPlugin.BoolValue || !g_bEnabled)  // "sm_warden_deputy_enable" "1"
	{
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_disabled");

		return Plugin_Handled;
	}

	if (IsClientDeputy(client))  // Is client the deputy
	{
		RemoveTheDeputy();
		
		CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_retire", client);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_deputy_retire_nc", client);
		}
	}
	else if (IsClientWarden(client) && g_iDeputy != -1)  // Is client the deputy
	{
		CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_fired", client, g_iDeputy);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_deputy_fired_nc", client, g_iDeputy);
		}
		RemoveTheDeputy();
	}
	else CPrintToChat(client, "%s %t", g_sPrefix, "warden_notwarden");
	
	return Plugin_Handled;
}

// Remove Deputy for Admins
public Action AdminCommand_RemoveDeputy(int client, int args)
{
	if (!gc_bDeputy.BoolValue || !gc_bPlugin.BoolValue || !g_bEnabled)  // "sm_warden_deputy_enable" "1"
		return Plugin_Handled;

	if (g_iDeputy != -1)  // Is there a warden to remove
	{
		CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_removed", client, g_iDeputy); // if client is console !=
		if (gc_bBetterNotes.BoolValue) PrintCenterTextAll("%t", "warden_deputy_removed_nc", client, g_iDeputy);
		
		if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Admin %L removed player %L as Deputy", client, g_iDeputy);
		
		RemoveTheDeputy();
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Deputy Died
public void Deputy_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

	if (IsClientDeputy(client))  // The Deputy is dead
	{
		Forward_OnDeputyRemoved(client);
		
		CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_dead", client);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_deputy_dead_nc", client);
		}
		g_iLastDeputy = g_iDeputy;
		g_iDeputy = -1;
	}

	if (IsClientWarden(client))  // The Warden changed team
	{
		if (g_iDeputy != -1)
		{
			if (gc_bWardenDead.BoolValue) CreateTimer (0.5, Timer_DeputyNewWarden);
		}
	}
}

// Deputy change Team
public void Deputy_Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the clients id

	if (IsClientDeputy(client))  // The Deputy changed team
	{
		RemoveTheDeputy();
		
		CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_retire", client);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_deputy_retire_nc", client);
		}
	}

	if (IsClientWarden(client))  // The Warden changed team
	{
		if (g_iDeputy != -1)
		{
			if (gc_bWardenDead.BoolValue) CreateTimer (0.5, Timer_DeputyNewWarden);
		}
	}
}

// Round Start Post
public void Deputy_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bDeputy.BoolValue || !gc_bPlugin.BoolValue || !g_bEnabled)
	{
		if (g_iDeputy != -1)
		{
			CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iDeputy));
			SetEntityModel(g_iDeputy, g_sModelDeputyPathPrevious);
			Forward_OnDeputyRemoved(g_iDeputy);
			g_iLastDeputy = g_iDeputy;
			g_iDeputy = -1;
		}
	}

	if (gp_bMyJailBreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);
		
		if (!StrEqual(EventDay, "none", false) || !gc_bStayWarden.BoolValue)
		{
			if (g_iDeputy != -1)
			{
				CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iDeputy));
				SetEntityModel(g_iDeputy, g_sModelDeputyPathPrevious);
				Forward_OnDeputyRemoved(g_iDeputy);
				g_iLastDeputy = g_iDeputy;
				g_iDeputy = -1;
			}
		}
	}

	if (g_iDeputy != -1)
	{
		if (gc_bModelDeputy.BoolValue)
		{
			SetEntityModel(g_iDeputy, g_sModelPathDeputy);
		}

		Glow_OnDeputyCreation(g_iDeputy);
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Prepare Plugin & modules
public void Deputy_OnMapStart()
{
	if (gc_bModelDeputy.BoolValue)
	{
		Downloader_AddFileToDownloadsTable(g_sModelPathDeputy);
		PrecacheModel(g_sModelPathDeputy);
	}
}

// Deputy disconnect
public void Deputy_OnClientDisconnect(int client)
{
	if (IsClientDeputy(client))
	{
		CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_disconnected", client);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_deputy_disconnected_nc", client);
		}

		Forward_OnDeputyRemoved(client);
		g_iLastDeputy = -1;
		g_iDeputy = -1;
	}
	if (IsClientWarden(client))  // The Warden changed team
	{
		if (g_iDeputy != -1)
		{
			if (gc_bWardenDead.BoolValue) CreateTimer (0.5, Timer_DeputyNewWarden);
		}
	}
}

// Close open timer & reset deputy/module
public void Deputy_OnMapEnd()
{
	if (g_iDeputy != -1)
	{
		CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iDeputy));
		Forward_OnDeputyRemoved(g_iDeputy);
		g_iLastDeputy = -1;
		g_iDeputy = -1;
	}
}

// warden removed
public void Deputy_OnWardenRemoved(int client)
{
	if (g_iDeputy != -1)
	{
		RemoveTheDeputy();
	}
}

// warden retire
public void Deputy_OnWardenRemovedBySelf(int client)
{
	if (g_iDeputy != -1)
	{
		if (gc_bWardenDead.BoolValue) CreateTimer (0.5, Timer_DeputyNewWarden);
	}
}

// Announce feature
public void Deputy_OnWardenCreation(int client)
{
	CreateTimer(10.0, Timer_NoDeputy);
}


// When a last request is available
public void Deputy_OnAvailableLR(int Announced)
{
	g_bIsLR = true;

	if (gc_bRemoveLRDeputy.BoolValue && g_iDeputy != -1)
	{
		RemoveTheDeputy();
	}
}
/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_DeputyNewWarden(Handle timer)
{
	if (IsValidClient(g_iDeputyDelay, true, false))
	{
		SetTheWarden(g_iDeputyDelay, 0);
	}
}

public Action Timer_NoDeputy(Handle timer)
{
	if ((g_iDeputy == -1) && (g_iWarden != -1))
	{
		if (gc_bBecomeDeputy.BoolValue) CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_become");
		if (gc_bSetDeputy.BoolValue) CPrintToChat(g_iWarden, "%s %t", g_sPrefix, "warden_deputy_set");
	}
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Set a new deputy
void SetTheDeputy(int client)
{
	if (!gc_bDeputy.BoolValue || !gc_bPlugin.BoolValue || !g_bEnabled)
	{
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_deputy_disabled");
		return;
	}

	CPrintToChatAll("%s %t", g_sPrefix, "warden_deputy_new", client);
	if (gc_bBetterNotes.BoolValue) PrintCenterTextAll("%t", "warden_deputy_new_nc", client);

	g_iDeputy = client;
	g_iDeputyDelay = g_iDeputy;

	GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelDeputyPathPrevious, sizeof(g_sModelDeputyPathPrevious));
	if (gc_bModelDeputy.BoolValue)
	{
		SetEntityModel(client, g_sModelPathDeputy);
	}
	SetClientListeningFlags(client, VOICE_NORMAL);
	Forward_OnDeputyCreated(client);
}

// Remove the current deputy
void RemoveTheDeputy()
{
	CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iDeputy));
	SetEntityModel(g_iDeputy, g_sModelDeputyPathPrevious);

	Forward_OnDeputyRemoved(g_iDeputy);

	g_iVoteCount = 0;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "");
	g_sHasVoted[0] = '\0';

	g_iLastDeputy = g_iDeputy;
	g_iDeputy = -1;
}

/******************************************************************************
                   MENUS
******************************************************************************/

// Admin set (new) Deputy menu
void Menu_SetDeputy(int client)
{
	char info1[255];
	Menu menu = CreateMenu(Handler_SetDeputy);

	Format(info1, sizeof(info1), "%T", "warden_choose", client);
	menu.SetTitle(info1);

	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
	{
		if (GetClientTeam(i) == CS_TEAM_CT && !IsClientWarden(i))
		{
			char userid[11];
			char username[MAX_NAME_LENGTH];
			IntToString(GetClientUserId(i), userid, sizeof(userid));
			Format(username, sizeof(username), "%N", i);
			menu.AddItem(userid, username);
		}
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

// Handler set (new) Deputy menu with overwrite/remove query
public int Handler_SetDeputy(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));

		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
		{
			if (GetClientTeam(i) == CS_TEAM_CT && !IsClientDeputy(i))
			{
				int userid = GetClientUserId(i);

				if (userid == StringToInt(Item))
				{
					SetTheDeputy(i);
				}
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

/******************************************************************************
                   STOCKS
******************************************************************************/

bool IsClientDeputy(int client)
{
	if (client != g_iDeputy)
	{
		return false;
	}

	return true;
}

/******************************************************************************
                   NATIVES
******************************************************************************/

// Booleans Exist Deputy
public int Native_ExistDeputy(Handle plugin, int argc)
{
	if (g_iDeputy == -1)
	{
		return false;
	}

	return true;
}

// Booleans Is Client Deputy
public int Native_IsDeputy(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	if (IsClientDeputy(client))
		return true;

	return false;
}

// Set Client as Deputy
public int Native_SetDeputy(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	if (g_iDeputy == -1)
		SetTheDeputy(client);
}

// Remove current Deputy
public int Native_RemoveDeputy(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	if (IsClientDeputy(client))
		RemoveTheDeputy();
}

// Get Deputy Client Index
public int Native_GetDeputy(Handle plugin, int argc)
{
	return g_iDeputy;
}

// Get last deputys Client Index
public int Native_GetLastDeputy(Handle plugin, int argc)
{
	return g_iLastDeputy;
}

/******************************************************************************
                   FORWARDS CALL
******************************************************************************/

// New Deputy was set (will fire all time - *ByUser *ByAdmin ...)
void Forward_OnDeputyCreated(int client)
{
	Call_StartForward(gF_OnDeputyCreated);
	Call_PushCell(client);
	Call_Finish();

	Color_OnDeputyCreation(client);
	HandCuffs_OnDeputyCreation(client);
	Glow_OnDeputyCreation(client);
}

// Deputy was removed (will fire all time - *BySelf *ByAdmin *Death ...)
void Forward_OnDeputyRemoved(int client)
{
	Call_StartForward(gF_OnDeputyRemoved);
	Call_PushCell(client);
	Call_Finish();

	Color_OnDeputyRemoved(client);
	HandCuffs_OnDeputyRemoved(client);
	Glow_OnDeputyRemoved(client);
}
