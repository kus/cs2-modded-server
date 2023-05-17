/*
 * MyJailbreak - Warden - Random Kill Module.
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
#include <myjailbreak>
#include <hosties>
#include <lastrequest>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Defines
#define SOUND_THUNDER "ambient/weather/thunder3.wav"

// Console Variables
ConVar gc_bRandom;
ConVar gc_bRandomDeputy;
ConVar gc_iRandomMode;
ConVar gc_sCustomCommandRandomKill;

// Extern Convars
ConVar g_iTerrorForLR;


// Start
public void RandomKill_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_killrandom", Command_KillMenu, "Allows the Warden to kill a random T");

	// AutoExecConfig
	gc_bRandom = AutoExecConfig_CreateConVar("sm_warden_random", "1", "0 - disabled, 1 - enable kill a random t for warden", _, true, 0.0, true, 1.0);
	gc_bRandomDeputy = AutoExecConfig_CreateConVar("sm_warden_random_deputy", "1", "0 - disabled, 1 - enable kill a random t for deputy, too", _, true, 0.0, true, 1.0);
	gc_iRandomMode = AutoExecConfig_CreateConVar("sm_warden_random_mode", "2", "1 - all random / 2 - Thunder / 3 - Timebomb / 4 - Firebomb / 5 - NoKill(1, 3, 4 needs funcommands.smx enabled)", _, true, 1.0, true, 4.0);
	gc_sCustomCommandRandomKill = AutoExecConfig_CreateConVar("sm_warden_cmds_randomkill", "randomkill, rk, kr", "Set your custom chat commands for become warden(!killrandom (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_KillMenu(int client, int args)
{
	if (gc_bRandom.BoolValue) 
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bRandomDeputy.BoolValue))
		{
			char info[255];
			Menu menu1 = CreateMenu(Handler_KillMenu);
			Format(info, sizeof(info), "%T", "warden_sure", g_iWarden, client);
			menu1.SetTitle(info);
			Format(info, sizeof(info), "%T", "warden_no", client);
			menu1.AddItem("0", info);
			Format(info, sizeof(info), "%T", "warden_yes", client);
			menu1.AddItem("1", info);
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client, MENU_TIME_FOREVER);
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void RandomKill_OnConfigsExecuted()
{
	// FindConVar
	g_iTerrorForLR = FindConVar("sm_hosties_lr_ts_max");

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Give freeday
	gc_sCustomCommandRandomKill.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_KillMenu, "Allows the Warden to kill a random T");
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

public Action PerformSmite(int client, int target)
{
	// define where the lightning strike ends
	float clientpos[3];
	GetClientAbsOrigin(target, clientpos);
	clientpos[2] -= 26; // increase y-axis by 26 to strike at player's chest instead of the ground

	// get random numbers for the x and y starting positions
	int randomx = GetRandomInt(-500, 500);
	int randomy = GetRandomInt(-500, 500);

	// define where the lightning strike starts
	float startpos[3];
	startpos[0] = clientpos[0] + randomx;
	startpos[1] = clientpos[1] + randomy;
	startpos[2] = clientpos[2] + 800;

	// define the color of the strike
	int color[4] = {255, 255, 255, 255};

	// define the direction of the sparks
	float dir[3] = {0.0, 0.0, 0.0};

	TE_SetupBeamPoints(startpos, clientpos, g_iBeamSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();

	TE_SetupSparks(clientpos, dir, 5000, 1000);
	TE_SendToAll();

	TE_SetupEnergySplash(clientpos, dir, false);
	TE_SendToAll();

	TE_SetupSmoke(clientpos, g_iSmokeSprite, 5.0, 10);
	TE_SendToAll();

	EmitAmbientSound(SOUND_THUNDER, startpos, target, SNDLEVEL_GUNFIRE);

	ForcePlayerSuicide(target);
}


/******************************************************************************
                   MENUS
******************************************************************************/


public int Handler_KillMenu(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char sBuffer[11];
		menu.GetItem(Position, sBuffer, sizeof(sBuffer));
		int choice = StringToInt(sBuffer);

		if (choice == 1)
		{
			int minT;
			int playercount;

			if (gp_bHosties && gp_bLastRequest)
			{
				playercount = GetAlivePlayersCountNonRebel(CS_TEAM_T);
				minT = g_iTerrorForLR.IntValue;
			}
			else
			{
				playercount = GetPlayerCount(true, CS_TEAM_T);
				minT = 1;
			}

			if (playercount > minT)
			{
				int i = GetRandomPlayerInView(CS_TEAM_T, client);

				if (IsValidClient(i, true, false))
				{
					if (gp_bHosties && gp_bLastRequest)
					{
						while (IsClientRebel(i))
						{
							i = GetRandomPlayerInView(CS_TEAM_T, client);
						}
					}

					CreateTimer(1.0, Timer_KillPlayer, GetClientUserId(i));
					CPrintToChatAll("%s %t", g_sPrefix, "warden_israndom", i);

					if (gp_bMyJailBreak)
					{
						if (MyJailbreak_ActiveLogging())
						{
							LogToFileEx(g_sMyJBLogFile, "Warden %L killed random player %L", client, i);
						}
					}
				}
				else CPrintToChatAll("%s %t", g_sPrefix, "warden_novalid");
			}
			else CPrintToChatAll("%s %t", g_sPrefix, "warden_minrandom");
		}
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
                   TIMER
******************************************************************************/

public Action Timer_KillPlayer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (gc_iRandomMode.IntValue == 1)
	{
		int randomnum = GetRandomInt(0, 2);

		if (randomnum == 0) PerformSmite(0, client);
		else if (randomnum == 1) ServerCommand("sm_timebomb %N 1", client);
		else if (randomnum == 2) ServerCommand("sm_firebomb %N 1", client);
	}
	else if (gc_iRandomMode.IntValue == 2) PerformSmite(0, client);
	else if (gc_iRandomMode.IntValue == 3) ServerCommand("sm_timebomb %N 1", client);
	else if (gc_iRandomMode.IntValue == 4) ServerCommand("sm_firebomb %N 1", client);
}

static int GetPlayerCount(bool alive = false, int team = -1)
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, !alive))
			continue;

		if (gp_bDeadGames)
		{
			if(DeadGames_IsOnGame(i))
				continue;
		}

		if (team != -1 && GetClientTeam(i) != team)
			continue;

		iCount++;
	}

	return iCount;
}