/*
 * MyJailbreak - Warden - Mute Module.
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

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <voiceannounce_ex>
#include <basecomm>
#include <sourcecomms>
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bMute;
ConVar gc_bMuteDeputy;
ConVar gc_bMuteEnd;
ConVar gc_bMuteDefault;
ConVar gc_sAdminFlagMute;
ConVar gc_bMuteTalkOver;
ConVar gc_bMuteTalkOverDeputy;
ConVar gc_bMuteTalkOverTeam;
ConVar gc_bMuteTalkOverDead;
ConVar gc_sCustomCommandMute;
ConVar gc_sCustomCommandUnMute;

// Boolean
bool g_bIsMuted[MAXPLAYERS+1] = {false, ...};
bool g_bTempMuted[MAXPLAYERS+1] = {false, ...};


// Strings
char g_sMuteUser[32];

// Start
public void Mute_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_wmute", Command_MuteMenu, "Allows a warden to mute all terrorists for a specified duration or untill the next round.");
	RegConsoleCmd("sm_wunmute", Command_UnMuteMenu, "Allows a warden to unmute the terrorists.");

	// AutoExecConfig
	gc_bMute = AutoExecConfig_CreateConVar("sm_warden_mute", "1", "0 - disabled, 1 - Allow the warden to mute T-side player", _, true, 0.0, true, 1.0);
	gc_bMuteDeputy = AutoExecConfig_CreateConVar("sm_warden_mute_deputy", "1", "0 - disabled, 1 - Allow to mute T-side player for deputy, too", _, true, 0.0, true, 1.0);
	gc_bMuteEnd = AutoExecConfig_CreateConVar("sm_warden_mute_round", "1", "0 - disabled, 1 - Allow the warden to mute a player until roundend", _, true, 0.0, true, 1.0);
	gc_bMuteDefault = AutoExecConfig_CreateConVar("sm_warden_mute_default", "0", "0 - disabled, 1 - Prisoners are muted on roundstart by default. Warden have to unmute them", _, true, 0.0, true, 1.0);
	gc_sAdminFlagMute = AutoExecConfig_CreateConVar("sm_warden_mute_immuntiy", "a", "Set flag for admin/vip Mute immunity. No flag immunity for all. so don't leave blank!");
	gc_bMuteTalkOver = AutoExecConfig_CreateConVar("sm_warden_talkover", "1", "0 - disabled, 1 - temporary mutes all client when the warden speaks", _, true, 0.0, true, 1.0);
	gc_bMuteTalkOverDeputy = AutoExecConfig_CreateConVar("sm_warden_talkover_deputy", "1", "0 - disabled, 1 - temporary mutes all client when the deputy speaks", _, true, 0.0, true, 1.0);
	gc_bMuteTalkOverTeam = AutoExecConfig_CreateConVar("sm_warden_talkover_team", "1", "0 - mute prisoner & guards on talkover, 1 - only mute prisoners on talkover", _, true, 0.0, true, 1.0);
	gc_bMuteTalkOverDead = AutoExecConfig_CreateConVar("sm_warden_talkover_dead", "0", "0 - mute death & alive player on talkover, 1 - only mute alive player on talkover", _, true, 0.0, true, 1.0);
	gc_sCustomCommandMute = AutoExecConfig_CreateConVar("sm_warden_cmds_mute", "wm, mutemenu", "Set your custom chat commands for become warden(!warden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandUnMute = AutoExecConfig_CreateConVar("sm_warden_cmds_unmute", "wum, unmutemenu", "Set your custom chat commands for retire from warden(!unwarden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	// Hooks
	HookEvent("round_end", Mute_Event_RoundEnd);
	HookEvent("round_start", Mute_Event_RoundStart);
}

public void Mute_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Mute
	gc_sCustomCommandMute.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_MuteMenu, "Allows a warden to mute all terrorists for a specified duration or untill the next round.");
	}

	// UnMute
	gc_sCustomCommandUnMute.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_UnMuteMenu, "Allows a warden to unmute the terrorists.");
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_UnMuteMenu(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bMute.BoolValue || !gc_bMute.BoolValue)
		return Plugin_Handled;

	if ((IsClientWarden(client) || (IsClientDeputy(client) && gc_bMuteDeputy.BoolValue)))
	{
		char info1[255];
		Menu menu4 = CreateMenu(Handler_UnMuteMenu);

		Format(info1, sizeof(info1), "%T", "warden_choose", client);
		menu4.SetTitle(info1);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			if (GetClientTeam(i) != CS_TEAM_CT && g_bIsMuted[i])
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				Format(username, sizeof(username), "%N", i);
				menu4.AddItem(userid, username);
			}
		}
		
		menu4.ExitBackButton = true;
		menu4.ExitButton = true;
		menu4.Display(client, MENU_TIME_FOREVER);
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");

	return Plugin_Handled;
}


public Action Command_MuteMenu(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bMute.BoolValue)
		return Plugin_Handled;

	if ((IsClientWarden(client) || (IsClientDeputy(client) && gc_bMuteDeputy.BoolValue)))
	{
		char info[255];
		Menu menu1 = CreateMenu(Handler_MuteMenu);

		Format(info, sizeof(info), "%T", "warden_mute_title", client);
		menu1.SetTitle(info);
		Format(info, sizeof(info), "%T", "warden_menu_mute", client);
		menu1.AddItem("0", info);
		Format(info, sizeof(info), "%T", "warden_menu_unmute", client);
		menu1.AddItem("1", info);
		Format(info, sizeof(info), "%T", "warden_menu_muteall", client);
		menu1.AddItem("2", info);
		Format(info, sizeof(info), "%T", "warden_menu_unmuteall", client);
		menu1.AddItem("3", info);

		menu1.ExitBackButton = true;
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Mute_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bMuteDefault.BoolValue)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;

		if (MyJB_CheckVIPFlags(i, "sm_warden_mute_immuntiy", gc_sAdminFlagMute, "sm_warden_mute_immuntiy"))
			continue;

		if (GetClientTeam(i) != CS_TEAM_CT)
		{
			SetClientListeningFlags(i, VOICE_MUTED);
			g_bIsMuted[i] = true;
		}
	}

	CPrintToChatAll("%s %t", g_sPrefix, "warden_mutedefault");
}

public void Mute_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	UnMuteAll(true);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void Mute_OnAvailableLR(int Announced)
{
	UnMuteAll(false);
}

public void Mute_OnMapEnd()
{
	UnMuteAll(true);
}

// Mute Terror when Warden speaks
public void OnClientSpeakingEx(int client)
{
	if (((warden_iswarden(client) && gc_bMuteTalkOver.BoolValue) || (warden_deputy_isdeputy(client) && gc_bMuteTalkOverDeputy.BoolValue)) && !g_bIsLR)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			if (MyJB_CheckVIPFlags(i, "sm_warden_mute_immuntiy", gc_sAdminFlagMute, "sm_warden_mute_immuntiy"))
				continue;

			if ((GetClientTeam(i) != CS_TEAM_CT) && (!g_bIsMuted[i] || (GetClientListeningFlags(i) != VOICE_MUTED)) || 
				(!gc_bMuteTalkOverTeam.BoolValue && !warden_iswarden(i) && !warden_deputy_isdeputy(i) && (GetClientTeam(i) == CS_TEAM_CT) && (GetClientListeningFlags(i) != VOICE_MUTED)))
			{
				if ((gc_bMuteTalkOverDead.BoolValue && IsPlayerAlive(i)) || !gc_bMuteTalkOverDead.BoolValue)
				{
					PrintCenterText(i, "%t", "warden_talkover");
					g_bTempMuted[i] = true;
					SetClientListeningFlags(i, VOICE_MUTED);
				}
			}
		}
	}
	else if (g_bTempMuted[client])
	{
		PrintCenterText(client, "%t", "warden_talkover");
	}
}

// Mute Terror when Warden end speaking
public void OnClientSpeakingEnd(int client)
{
	if (!gc_bMuteTalkOver.BoolValue)
		return;

	if ((warden_iswarden(client)) || (warden_deputy_isdeputy(client) && gc_bMuteTalkOverDeputy.BoolValue))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			if (!g_bTempMuted[i] || g_bIsMuted[i])
				continue;

			if (gp_bBasecomm)
			{
				if (BaseComm_IsClientMuted(i))
					continue;
			}

			if (gp_bSourceComms)
			{
				if (SourceComms_GetClientMuteType(i) != bNot)
					continue;
			}

			g_bTempMuted[i] = false;
			SetClientListeningFlags(i, VOICE_NORMAL);
		}
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void MuteClient(int client, int time, int muter)
{
	if (!IsValidClient(client, true, true))
		return;

	if (MyJB_CheckVIPFlags(client, "sm_warden_mute_immuntiy", gc_sAdminFlagMute, "sm_warden_mute_immuntiy"))
		return;

	if (GetClientTeam(client) != CS_TEAM_CT)
	{
		SetClientListeningFlags(client, VOICE_MUTED);
		g_bIsMuted[client] = true;

		if (time == 0)
		{
			CPrintToChatAll("%s %t", g_sPrefix, "warden_muteend", muter, client);
			if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Warden/Deputy %L muted player %L until round end", muter, client);
		}
		else
		{
			CPrintToChatAll("%s %t", g_sPrefix, "warden_mute", muter, client, time);
			if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Warden/Deputy %L muted player %L for %i seconds", muter, client, time);
		}
	}

	if (time > 0)
	{
		float timing = float(time);
		CreateTimer(timing, Timer_UnMute, GetClientUserId(client));
	}
}

void UnMuteAll(bool dead, int initiator = -1)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, dead))
			continue;

		if (!g_bIsMuted[i])
			continue;

		UnMuteClient(i, initiator);
	}
}

void UnMuteClient(any client, int initiator)
{
	if (IsValidClient(client, false, true) && g_bIsMuted[client])
	{
		if (gp_bBasecomm)
		{
			if (BaseComm_IsClientMuted(client))
				return;
		}

		if (gp_bSourceComms)
		{
			if (SourceComms_GetClientMuteType(client) != bNot)
				return;
		}

		SetClientListeningFlags(client, VOICE_NORMAL);
		g_bIsMuted[client] = false;

		CPrintToChat(client, "%s %t", g_sPrefix, "warden_unmute", client);

		if (initiator != -1)
		{
			CPrintToChat(initiator, "%s %t", g_sPrefix, "warden_unmute", client);
		}
	}
}

/******************************************************************************
                   MENUS
******************************************************************************/

void MuteMenuPlayer(int client)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || gc_bMute.BoolValue)
		return;

	if ((IsClientWarden(client) || (IsClientDeputy(client) && gc_bMuteDeputy.BoolValue)) && gc_bMute.BoolValue)
	{
		char info1[255];
		Menu menu5 = CreateMenu(Handler_MuteMenuPlayer);

		Format(info1, sizeof(info1), "%T", "warden_choose", client);
		menu5.SetTitle(info1);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, true))
				continue;

			if (MyJB_CheckVIPFlags(i, "sm_warden_mute_immuntiy", gc_sAdminFlagMute, "sm_warden_mute_immuntiy"))
				continue;

			if ((GetClientTeam(i) != CS_TEAM_CT) && !g_bIsMuted[i])
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				Format(username, sizeof(username), "%N", i);
				menu5.AddItem(userid, username);
			}
		}

		menu5.ExitBackButton = true;
		menu5.ExitButton = true;
		menu5.Display(client, MENU_TIME_FOREVER);
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
}

public int Handler_MuteMenuPlayer(Menu menu5, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		menu5.GetItem(Position, g_sMuteUser, sizeof(g_sMuteUser));

		char menuinfo[255];
		Menu menu3 = new Menu(Handler_MuteMenuTime);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_time_title", client);
		menu3.SetTitle(menuinfo);

		if (gc_bMuteEnd.BoolValue)
		{
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_roundend", client);
			menu3.AddItem("0", menuinfo);
		}

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_15", client);
		menu3.AddItem("15", menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_30", client);
		menu3.AddItem("30", menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_45", client);
		menu3.AddItem("45", menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_60", client);
		menu3.AddItem("60", menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_90", client);
		menu3.AddItem("90", menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_120", client);
		menu3.AddItem("120", menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_180", client);
		menu3.AddItem("180", menuinfo);

		Format(menuinfo, sizeof(menuinfo), "%T", "warden_300", client);
		menu3.AddItem("300", menuinfo);

		menu3.ExitBackButton = true;
		menu3.ExitButton = true;
		menu3.Display(client, 20);
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
		delete menu5;
	}
}

public int Handler_MuteMenuTime(Menu menu3, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu3.GetItem(selection, info, sizeof(info));
		int duration = StringToInt(info);
		int user = GetClientOfUserId(StringToInt(g_sMuteUser));

		MuteClient(user, duration, client);

		if (g_bMenuClose != null)
		{
			if (!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_wmute");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu3;
	}
}

public int Handler_UnMuteMenu(Menu menu4, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu4.GetItem(selection, info, sizeof(info));
		int user = GetClientOfUserId(StringToInt(info));

		UnMuteClient(user, client);

		if (g_bMenuClose != null)
		{
			if (!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu4;
	}
}


public int Handler_MuteMenu(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);

		if (choice == 1)
		{
			Command_UnMuteMenu(client, 0);
		}

		if (choice == 0)
		{
			MuteMenuPlayer(client);
		}

		if (choice == 2)
		{
			MuteMenuTeam(client);
		}

		if (choice == 3)
		{
			UnMuteAll(true, client);
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


void MuteMenuTeam(int client)
{
	char menuinfo[255];
	Menu menu6 = new Menu(Handler_MuteMenuTeam);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_time_title", client);
	menu6.SetTitle(menuinfo);

	if (gc_bMuteEnd.BoolValue)
	{
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_roundend", client);
		menu6.AddItem("0", menuinfo);
	}

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_15", client);
	menu6.AddItem("15", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_30", client);
	menu6.AddItem("30", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_45", client);
	menu6.AddItem("45", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_60", client);
	menu6.AddItem("60", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_90", client);
	menu6.AddItem("90", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_120", client);
	menu6.AddItem("120", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_180", client);
	menu6.AddItem("180", menuinfo);

	Format(menuinfo, sizeof(menuinfo), "%T", "warden_300", client);
	menu6.AddItem("300", menuinfo);

	menu6.ExitBackButton = true;
	menu6.ExitButton = true;
	menu6.Display(client, 20);
}


public int Handler_MuteMenuTeam(Menu menu6, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu6.GetItem(selection, info, sizeof(info));
		int duration = StringToInt(info);

		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) MuteClient(i, duration, client);

		if (g_bMenuClose != null)
		{
			if (!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_wmute");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu6;
	}
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_UnMute(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	UnMuteClient(client, -1);
}