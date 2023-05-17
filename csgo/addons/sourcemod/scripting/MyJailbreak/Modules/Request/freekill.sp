/*
 * MyJailbreak - Request Freekill Module.
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
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <warden>
#include <myjbwarden>
#include <myjailbreak>
#include <smartjaildoors>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_sCustomCommandFreekill;
ConVar gc_bFreeKill;
ConVar gc_iFreeKillLimit;
ConVar gc_bFreeKillRespawn;
ConVar gc_bFreeKillKill;
ConVar gc_bFreeKillFreeDay;
ConVar gc_bFreeKillSwap;
ConVar gc_bFreeKillFreeDayVictim;
ConVar gc_bReportAdmin;
ConVar gc_bReportAdminSpec;
ConVar gc_bReportWarden;
ConVar gc_bRespawnCellClosed;
ConVar gc_sAdminFlag;

// Booleans
bool g_bFreeKilled[MAXPLAYERS+1];

// Integers
int g_iFreeKillCounter[MAXPLAYERS+1];

// Strings
char g_sFreeKillLogFile[PLATFORM_MAX_PATH];

// Start
public void Freekill_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_freekill", Command_Freekill, "Allows a Dead Terrorist report a Freekill");

	// AutoExecConfig
	gc_bFreeKill = AutoExecConfig_CreateConVar("sm_freekill_enable", "1", "0 - disabled, 1 - enable freekill report");
	gc_sCustomCommandFreekill = AutoExecConfig_CreateConVar("sm_freekill_cmds", "fk, reportfk, rfk", "Set your custom chat commands for freekill(!freekill (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_iFreeKillLimit = AutoExecConfig_CreateConVar("sm_freekill_limit", "2", "Сount how many times you can report a freekill");
	gc_bFreeKillRespawn = AutoExecConfig_CreateConVar("sm_freekill_respawn", "1", "0 - disabled, 1 - Allow the warden to respawn a Freekill victim");
	gc_bRespawnCellClosed = AutoExecConfig_CreateConVar("sm_freekill_respawn_cell", "1", "0 - cells are still open, 1 - cells will close on respawn in cell - need smartjaildoors");
	gc_bFreeKillKill = AutoExecConfig_CreateConVar("sm_freekill_kill", "1", "0 - disabled, 1 - Allow the warden to Kill a Freekiller");
	gc_bFreeKillFreeDay = AutoExecConfig_CreateConVar("sm_freekill_freeday", "1", "0 - disabled, 1 - Allow the warden to set a freeday next round as pardon for all player");
	gc_bFreeKillFreeDayVictim= AutoExecConfig_CreateConVar("sm_freekill_freeday_victim", "1", "0 - disabled, 1 - Allow the warden to set a personal freeday next round as pardon for the victim");
	gc_bFreeKillSwap = AutoExecConfig_CreateConVar("sm_freekill_swap", "1", "0 - disabled, 1 - Allow the warden to swap a freekiller to terrorist");
	gc_bReportAdmin = AutoExecConfig_CreateConVar("sm_freekill_admin", "1", "0 - disabled, 1 - Report will be send to admins - if there is no admin its send to warden");
	gc_bReportAdminSpec = AutoExecConfig_CreateConVar("sm_freekill_admin_spec", "1", "0 - disabled, 1 - Report will be send to admins even if he is in spec");
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_freekill_flag", "g", "Set flag for admin/vip get reported freekills to decide.");
	gc_bReportWarden = AutoExecConfig_CreateConVar("sm_freekill_warden", "1", "0 - disabled, 1 - Report will be send to Warden if there is no admin");

	// Hooks 
	HookEvent("round_start", Freekill_Event_RoundStart);
	HookEvent("player_death", Freekill_Event_PlayerDeath);

	// Logs
	SetLogFile(g_sFreeKillLogFile, "Freekills", "MyJailbreak");
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_Freekill(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bFreeKill.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && (!IsPlayerAlive(client)))
			{
				if (!g_bIsRequest)
				{
					int attacker = GetClientOfUserId(g_iKilledBy[client]);
					
					if (IsValidClient(attacker, true, true) && IsValidClient(client, true, true))
					{
						if (g_iFreeKillCounter[client] < gc_iFreeKillLimit.IntValue)
						{
							g_bIsRequest = true;
							g_hTimerRequest = CreateTimer (20.0, Timer_IsRequest);
							g_bFreeKilled[client] = true;
							
							
							int a = GetRandomAdmin();
							if ((a != -1) && gc_bReportAdmin.BoolValue)
							{
								if (!gc_bReportAdminSpec.BoolValue && GetClientTeam(a) == CS_TEAM_SPECTATOR && (gp_bWarden || gp_bMyJBWarden))
								{
									for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true)) if (warden_iswarden(i) && gc_bReportWarden.BoolValue)
									{
										g_iFreeKillCounter[client]++;
										FreeKillAcceptMenu(i);
										CPrintToChatAll("%s %t", g_sPrefix, "request_freekill", client, attacker, i);
										if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Player %L claiming %L freekilled him. Reported to warden %L", client, attacker, i);
									}
								}
								else
								{
									g_iFreeKillCounter[client]++;
									FreeKillAcceptMenu(a);
									CPrintToChatAll("%s %t", g_sPrefix, "request_freekill", client, attacker, a);
									if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Player %L claiming %L freekilled him. Reported to admin %L", client, attacker, a);
								}
							}
							else for (int i = 1; i <= MaxClients; i++) if (gp_bWarden || gp_bMyJBWarden) if (IsValidClient(i, false, true)) if (warden_iswarden(i) && gc_bReportWarden.BoolValue)
							{
								g_iFreeKillCounter[client]++;
								FreeKillAcceptMenu(i);
								CPrintToChatAll("%s %t", g_sPrefix, "request_freekill", client, attacker, i);
								if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Player %L claiming %L freekilled him. Reported to warden %L", client, attacker, i);
							}
						}
						else CReplyToCommand(client, "%s %t", g_sPrefix, "request_freekilltimes", gc_iFreeKillLimit.IntValue);
					}
					else CReplyToCommand(client, "%s %t", g_sPrefix, "request_nokiller");
				}
				else CReplyToCommand(client, "%s %t", g_sPrefix, "request_processing");
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "request_aliveorct");
		}
	}
	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Freekill_Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_iFreeKillCounter[i] = 0;
		g_bFreeKilled[i] = false;
	}
}

public void Freekill_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

	if (IsValidClient(victim, false, true))
	{
		GetClientAbsOrigin(victim, g_fDeathOrigin[victim]);
	}
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void Freekill_OnMapStart()
{
	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
	}
}

public void Freekill_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Report freekill
	gc_sCustomCommandFreekill.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_Freekill, "Allows a Dead Terrorist report a Freekill");
	}
}

public void Freekill_OnClientPutInServer(int client)
{
	g_iFreeKillCounter[client] = 0;
}

/******************************************************************************
                   MENUS
******************************************************************************/

public Action FreeKillAcceptMenu(int client)
{
	if (IsValidClient(client, false, true))
	{
		char info[255];
		Menu menu1 = CreateMenu(FreeKillAcceptHandler);
		Format(info, sizeof(info), "%T", "request_pardonfreekill", client);
		menu1.SetTitle(info);
		Format(info, sizeof(info), "%T", "warden_no", client);
		menu1.AddItem("0", info);
		Format(info, sizeof(info), "%T", "warden_yes", client);
		menu1.AddItem("1", info);
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
}

public int FreeKillAcceptHandler(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);
		if (choice == 1) // yes
		{
			char info[255];
			
			Menu menu1 = CreateMenu(FreeKillHandler);
			Format(info, sizeof(info), "%T", "request_handlefreekill", client);
			menu1.SetTitle(info);
			Format(info, sizeof(info), "%T", "request_respawnvictim", client);
			if (gc_bFreeKillRespawn.BoolValue) menu1.AddItem("1", info);
			Format(info, sizeof(info), "%T", "request_killfreekiller", client);
			if (gc_bFreeKillKill.BoolValue) menu1.AddItem("2", info);
			Format(info, sizeof(info), "%T", "request_freeday", client);
			if (gc_bFreeKillFreeDay.BoolValue) menu1.AddItem("3", info);
			Format(info, sizeof(info), "%T", "request_freedayvictim", client);
			if (gc_bFreeKillFreeDayVictim.BoolValue && gp_bMyJBWarden) menu1.AddItem("5", info);
			Format(info, sizeof(info), "%T", "request_swapfreekiller", client);
			if (gc_bFreeKillSwap.BoolValue) menu1.AddItem("4", info);
			menu1.Display(client, MENU_TIME_FOREVER);
			for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (g_bFreeKilled[i]) CPrintToChatAll("%s %t", g_sPrefix, "request_accepted", i, client);
		}
		if (choice == 0) // no
		{
			g_bIsRequest = false;
			g_hTimerRequest = null;
			
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i])
			{
				CPrintToChatAll("%s %t", g_sPrefix, "request_noaccepted", i, client);
				g_bFreeKilled[i] = false;
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public int FreeKillHandler(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);

		g_bIsRequest = false;
		g_hTimerRequest = null;

		if (choice == 1) // respawn
		{
			char info[255];

			Menu menu1 = CreateMenu(RespawnHandler);
			Format(info, sizeof(info), "%T", "request_handlerespawn", client);
			menu1.SetTitle(info);
			Format(info, sizeof(info), "%T", "request_respawnbody", client);
			menu1.AddItem("1", info);
			Format(info, sizeof(info), "%T", "request_respawncell", client);
			menu1.AddItem("2", info);
			Format(info, sizeof(info), "%T", "request_respawnwarden", client);
			if (gp_bWarden || gp_bMyJBWarden) if (warden_exist()) menu1.AddItem("3", info);
			menu1.Display(client, MENU_TIME_FOREVER);
		}
		if (choice == 2) // kill freekiller
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;

				int attacker = GetClientOfUserId(g_iKilledBy[i]);
				ForcePlayerSuicide(attacker);

				if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L  and killed %L", client, i, attacker);
				CPrintToChat(attacker, "%s %t", g_sPrefix, "request_killbcfreekill");
				CPrintToChatAll("%s %t", g_sPrefix, "request_killbcfreekillall", attacker);
			}
		}
		if (choice == 3) // freeday event for all
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L give a freeday", client, i);
				FakeClientCommand(client, "sm_setfreeday");
			}
		}
		if (choice == 4) // swap freekiller
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i])
			{
				int attacker = GetClientOfUserId(g_iKilledBy[i]);

				g_bFreeKilled[i] = false;
				ClientCommand(attacker, "jointeam %i", CS_TEAM_T);
				CPrintToChat(attacker, "%s %t", g_sPrefix, "request_swapbcfreekill");
				if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L  and swaped %L to T", client, i, attacker);
				CPrintToChatAll("%s %t", g_sPrefix, "request_swapbcfreekillall", i);
			}
		}
		if (choice == 5) // freeday to victim
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i])
			{
			// 	g_bHaveFreeDay[i] = true;
				warden_freeday_set(i);
				g_bFreeKilled[i] = false;
				CPrintToChat(i, "%s %t", g_sPrefix, "warden_freedayforyou");
				if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L gave him a personal freeday", client, i);
				CPrintToChatAll("%s %t", g_sPrefix, "warden_personalfreeday", i);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public int RespawnHandler(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);

		g_bIsRequest = false;
		g_hTimerRequest = null;

		if (choice == 1) // respawnbody
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				CS_RespawnPlayer(i);
				
				TeleportEntity(i, g_fDeathOrigin[i], NULL_VECTOR, NULL_VECTOR);
				
				if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request and respawned %L on his body", client, i);
				CPrintToChat(i, "%s %t", g_sPrefix, "request_respawned");
				CPrintToChatAll("%s %t", g_sPrefix, "request_respawnedall", i);
			}
		}
		if (choice == 2) // respawncell
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				
				if (gp_bSmartJailDoors && gc_bRespawnCellClosed.BoolValue) SJD_CloseDoors();
				CS_RespawnPlayer(i);
				
				if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request and respawned %L in cell", client, i);
				CPrintToChat(i, "%s %t", g_sPrefix, "request_respawned");
				CPrintToChatAll("%s %t", g_sPrefix, "request_respawnedall", i);
			}
		}
		if (choice == 3) // respawnwarden
		{
			for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true)) if (g_bFreeKilled[i] && warden_exist())
			{
				g_bFreeKilled[i] = false;
				CS_RespawnPlayer(i);
				
				int warden = warden_get();
				
				float origin[3];
				GetClientAbsOrigin(warden, origin);
				float location[3];
				GetClientEyePosition(warden, location);
				float ang[3];
				GetClientEyeAngles(warden, ang);
				float location2[3];
				location2[0] = (location[0]+(100*((Cosine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
				location2[1] = (location[1]+(100*((Sine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
				ang[0] -= (2*ang[0]);
				location2[2] = origin[2] += 5.0;
				
				TeleportEntity(i, location2, NULL_VECTOR, NULL_VECTOR);
				
				if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request and respawned %L in front of warden", client, i);
				CPrintToChat(i, "%s %t", g_sPrefix, "request_respawned");
				CPrintToChatAll("%s %t", g_sPrefix, "request_respawnedall", i);
			}
		}
	}
}

/******************************************************************************
                   STOCKS
******************************************************************************/

int GetRandomAdmin()
{
	int[] admins = new int[MaxClients];
	int adminsCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, false, true))
			continue;

		if (!MyJB_CheckVIPFlags(i, "sm_freekill_flag", gc_sAdminFlag, "sm_freekill_flag"))
			continue;

		admins[adminsCount++] = i;
	}

	return (adminsCount == 0) ? -1 : admins[GetRandomInt(0, adminsCount-1)];
}