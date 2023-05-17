/*
 * MyJailbreak - Request - Refuse Module.
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

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_fRefuseTime;
ConVar gc_bRefuse;
ConVar gc_bWardenAllowRefuse;
ConVar gc_iRefuseLimit;
ConVar gc_iRefuseColorRed;
ConVar gc_iRefuseColorGreen;
ConVar gc_iRefuseColorBlue;
ConVar gc_sSoundRefusePath;
ConVar gc_sSoundRefuseStopPath;
ConVar gc_sCustomCommandRefuse;
ConVar gc_sAdminFlagRefuse;

// Booleans
bool g_bRefused[MAXPLAYERS+1];
bool g_bAllowRefuse;

// Integers
int g_iRefuseCounter[MAXPLAYERS+1];
int g_iCountStopTime;

// Handles
Handle g_hTimerRefuse[MAXPLAYERS+1];
Handle g_hTimerAllowRefuse;

// Strings
char g_sSoundRefusePath[256];
char g_sSoundRefuseStopPath[256];
char g_sAdminFlagRefuse[64];

// Start
public void Refuse_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_refuse", Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");

	// AutoExecConfig
	gc_bRefuse = AutoExecConfig_CreateConVar("sm_refuse_enable", "1", "0 - disabled, 1 - enable Refuse");
	gc_sCustomCommandRefuse = AutoExecConfig_CreateConVar("sm_refuse_cmds", "ref, r", "Set your custom chat commands for Refuse(!refuse (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bWardenAllowRefuse = AutoExecConfig_CreateConVar("sm_refuse_allow", "0", "0 - disabled, 1 - Warden must allow !refuse before T can use it");
	gc_iRefuseLimit = AutoExecConfig_CreateConVar("sm_refuse_limit", "1", "Сount how many times you can use the command");
	gc_fRefuseTime = AutoExecConfig_CreateConVar("sm_refuse_time", "5.0", "Time the player gets to refuse after warden open refuse with !refuse / colortime");
	gc_iRefuseColorRed = AutoExecConfig_CreateConVar("sm_refuse_color_red", "0", "What color to turn the refusing Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iRefuseColorGreen = AutoExecConfig_CreateConVar("sm_refuse_color_green", "250", "What color to turn the refusing Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iRefuseColorBlue = AutoExecConfig_CreateConVar("sm_refuse_color_blue", "250", "What color to turn the refusing Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sSoundRefusePath = AutoExecConfig_CreateConVar("sm_refuse_sound", "music/MyJailbreak/refuse.mp3", "Path to the soundfile which should be played for a refusing.");
	gc_sSoundRefuseStopPath = AutoExecConfig_CreateConVar("sm_refuse_stop_sound", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played after a refusing.");
	gc_sAdminFlagRefuse = AutoExecConfig_CreateConVar("sm_refuse_flag", "a", "Set flag for admin/vip to get one more refuse. No flag = feature is available for all players!");

	// Hooks 
	HookEvent("round_start", Refuse_Event_RoundStart);
	HookConVarChange(gc_sSoundRefusePath, Refuse_OnSettingChanged);
	HookConVarChange(gc_sSoundRefuseStopPath, Refuse_OnSettingChanged);
	HookConVarChange(gc_sAdminFlagRefuse, Refuse_OnSettingChanged);

	// FindConVar
	gc_sSoundRefusePath.GetString(g_sSoundRefusePath, sizeof(g_sSoundRefusePath));
	gc_sSoundRefuseStopPath.GetString(g_sSoundRefuseStopPath, sizeof(g_sSoundRefuseStopPath));
	gc_sAdminFlagRefuse.GetString(g_sAdminFlagRefuse, sizeof(g_sAdminFlagRefuse));
}

public void Refuse_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sSoundRefusePath)
	{
		strcopy(g_sSoundRefusePath, sizeof(g_sSoundRefusePath), newValue);
		if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefusePath);
	}
	else if (convar == gc_sSoundRefuseStopPath)
	{
		strcopy(g_sSoundRefuseStopPath, sizeof(g_sSoundRefuseStopPath), newValue);
		if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefuseStopPath);
	}
	else if (convar == gc_sAdminFlagRefuse)
	{
		strcopy(g_sAdminFlagRefuse, sizeof(g_sAdminFlagRefuse), newValue);
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_refuse(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bRefuse.BoolValue)
		{
			if ((gp_bWarden || gp_bMyJBWarden) && warden_iswarden(client) && gc_bWardenAllowRefuse.BoolValue)
			{
				if (!g_bAllowRefuse)
				{
					g_bAllowRefuse = true;
					g_hTimerAllowRefuse = CreateTimer(1.0, Timer_NoAllowRefuse, _, TIMER_REPEAT);
					CPrintToChatAll("%s %t", g_sPrefix, "request_openrefuse");
				}
			}
			if ((!gp_bWarden && !gp_bMyJBWarden) || !warden_iswarden(client))
			{
				if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
				{
					if (g_hTimerRefuse[client] == null)
					{
						if (g_bAllowRefuse || !gc_bWardenAllowRefuse.BoolValue)
						{
							if (g_iRefuseCounter[client] < gc_iRefuseLimit.IntValue)
							{
								g_iRefuseCounter[client]++;
								g_bRefused[client] = true;
								SetEntityRenderColor(client, gc_iRefuseColorRed.IntValue, gc_iRefuseColorGreen.IntValue, gc_iRefuseColorBlue.IntValue, 255);
								CPrintToChatAll("%s %t", g_sPrefix, "request_refusing", client);
								g_iCountStopTime = gc_fRefuseTime.IntValue;
								g_hTimerRefuse[client] = CreateTimer(gc_fRefuseTime.FloatValue, Timer_ResetColorRefuse, GetClientUserId(client));
								if (warden_exist()) for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) RefuseMenu(i);
								if (gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundRefusePath);
							}
							else CReplyToCommand(client, "%s %t", g_sPrefix, "request_refusedtimes", gc_iRefuseLimit.IntValue);
						}
						else CReplyToCommand(client, "%s %t", g_sPrefix, "request_refuseallow");
					}
					else CReplyToCommand(client, "%s %t", g_sPrefix, "request_alreadyrefused");
				}
				else CReplyToCommand(client, "%s %t", g_sPrefix, "request_notalivect");
			}
		}
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Refuse_Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		delete g_hTimerRefuse[i];
		delete g_hTimerAllowRefuse;

		g_iRefuseCounter[i] = 0;
		g_bRefused[i] = false;
		g_bAllowRefuse = false;

		if (MyJB_CheckVIPFlags(i, "sm_refuse_flag", gc_sAdminFlagRefuse, "sm_refuse_flag"))
		{
			g_iRefuseCounter[i] = -1;
		}
	}

	g_iCountStopTime = gc_fRefuseTime.IntValue;
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void Refuse_OnMapStart()
{
	if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefusePath);
	if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefuseStopPath);
}

public void Refuse_OnConfigsExecuted()
{
	g_iCountStopTime = gc_fRefuseTime.IntValue;

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Refuse Game
	gc_sCustomCommandRefuse.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");
	}
}

public void Refuse_OnClientPutInServer(int client)
{
	g_iRefuseCounter[client] = 0;

	if (MyJB_CheckVIPFlags(client, "sm_refuse_flag", gc_sAdminFlagRefuse, "sm_refuse_flag"))
	{
		g_iRefuseCounter[client] = -1;
	}

	g_bRefused[client] = false;
}

public void Refuse_OnClientDisconnect(int client)
{
	delete g_hTimerRefuse[client];
}

/******************************************************************************
                   MENUS
******************************************************************************/

public Action RefuseMenu(int client)
{
	if (warden_iswarden(client) || warden_deputy_isdeputy(client))
	{
		char info1[255];
		Panel InfoPanel = new Panel();
		Format(info1, sizeof(info1), "%T", "request_refuser", client);
		InfoPanel.SetTitle(info1);
		InfoPanel.DrawText("-----------------------------------");
		InfoPanel.DrawText("                                   ");

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, false, true))
				continue;

			if (!g_bRefused[i])
				continue;

			char userid[11];
			char username[MAX_NAME_LENGTH];
			IntToString(GetClientUserId(i), userid, sizeof(userid));
			Format(username, sizeof(username), "%N", i);
			InfoPanel.DrawText(username);
		}

		InfoPanel.DrawText("                                   ");
		InfoPanel.DrawText("-----------------------------------");
		Format(info1, sizeof(info1), "%T", "request_close", client);
		InfoPanel.DrawItem(info1);
		InfoPanel.Send(client, Handler_NullCancel, 23);
	}
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_ResetColorRefuse(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client,true,false))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}

	g_hTimerRefuse[client] = null;
	g_bRefused[client] = false;
}

public Action Timer_NoAllowRefuse(Handle timer)
{
	if (g_iCountStopTime > 0)
	{
		if (g_iCountStopTime < 4)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, false, true))
					continue;

				PrintCenterText(i, "%t", "request_stopcountdown_nc", g_iCountStopTime);
			}
			CPrintToChatAll("%s %t", g_sPrefix, "request_stopcountdown", g_iCountStopTime);
		}
		g_iCountStopTime--;
		return Plugin_Continue;
	}

	if (g_iCountStopTime == 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, false, true))
				continue;

			if (gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundRefuseStopPath);
			}

			g_bAllowRefuse = false;
			g_hTimerAllowRefuse = null;
			g_iCountStopTime = gc_fRefuseTime.IntValue;

			PrintCenterText(i, "%t", "request_countdownstop_nc");
			return Plugin_Stop;
		}
		CPrintToChatAll("%s %t", g_sPrefix, "request_countdownstop");
	}

	return Plugin_Continue;
}