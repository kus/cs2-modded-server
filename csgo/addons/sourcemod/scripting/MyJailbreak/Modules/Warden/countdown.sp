/*
 * MyJailbreak - Warden - Countdown Timer Module.
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
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <myjbwarden>
#include <mystocks>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bCountDown;
ConVar gc_bCountDownDeputy;
ConVar gc_bCountdownOverlays;
ConVar gc_sCountdownOverlayStartPath;
ConVar gc_sCountdownOverlayStopPath;
ConVar gc_bCountdownSounds;
ConVar gc_sCountdownSoundStartPath;
ConVar gc_sCountdownSoundStopPath;
ConVar gc_sCustomCommandCD;

// Booleans
bool g_bIsCountDown = false;

// Strings
char g_sCountdownSoundStartPath[256];
char g_sCountdownSoundStopPath[256];
char g_sCountdownOverlayStopPath[256];
char g_sCountdownOverlayStartPath[256];

// Handles
Handle g_hStartTimer = null;
Handle g_hStopTimer = null;
Handle g_hStartStopTimer = null;

// Integers
int g_iCountStartTime = 9;
int g_iCountStopTime = 9;
int g_iSetCountStartStopTime;

// Start
public void Countdown_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_cdstart", Command_StartCountDown, "Allows the Warden to start a START Countdown! (start after 10sec.) - start without menu");
	RegConsoleCmd("sm_cdmenu", Command_CountDownMenu, "Allows the Warden to open the Countdown Menu");
	RegConsoleCmd("sm_cdstartstop", Command_StartStopMenu, "Allows the Warden to start a START/STOP Countdown! (start after 10sec./stop after 20sec.) - start without menu");
	RegConsoleCmd("sm_cdstop", Command_StopCountDown, "Allows the Warden to start a STOP Countdown! (stop after 20sec.) - start without menu");

	// AutoExecConfig
	gc_bCountDown = AutoExecConfig_CreateConVar("sm_warden_countdown", "1", "0 - disabled, 1 - enable countdown for warden", _, true, 0.0, true, 1.0);
	gc_bCountDownDeputy = AutoExecConfig_CreateConVar("sm_warden_countdown_deputy", "1", "0 - disabled, 1 - enable countdown for deputy, too", _, true, 0.0, true, 1.0);
	gc_bCountdownOverlays = AutoExecConfig_CreateConVar("sm_warden_countdown_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sCountdownOverlayStartPath = AutoExecConfig_CreateConVar("sm_warden_countdown_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sCountdownOverlayStopPath = AutoExecConfig_CreateConVar("sm_warden_countdown_overlays_stop", "overlays/MyJailbreak/stop", "Path to the stop Overlay DONT TYPE .vmt or .vft");
	gc_bCountdownSounds = AutoExecConfig_CreateConVar("sm_warden_countdown_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sCountdownSoundStartPath = AutoExecConfig_CreateConVar("sm_warden_countdown_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start countdown.");
	gc_sCountdownSoundStopPath = AutoExecConfig_CreateConVar("sm_warden_countdown_sounds_stop", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played for stop countdown.");
	gc_sCustomCommandCD = AutoExecConfig_CreateConVar("sm_warden_cmds_countdown", "cd, countdown, timer", "Set your custom chat commands for countdown menu(!cdmenu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");

	// Hooks
	HookEvent("round_end", Countdown_Event_RoundEnd);
	HookConVarChange(gc_sCountdownSoundStartPath, Countdown_OnSettingChanged);
	HookConVarChange(gc_sCountdownSoundStopPath, Countdown_OnSettingChanged);
	HookConVarChange(gc_sCountdownOverlayStartPath, Countdown_OnSettingChanged);
	HookConVarChange(gc_sCountdownOverlayStopPath, Countdown_OnSettingChanged);

	// FindConVar
	gc_sCountdownSoundStartPath.GetString(g_sCountdownSoundStartPath, sizeof(g_sCountdownSoundStartPath));
	gc_sCountdownSoundStopPath.GetString(g_sCountdownSoundStopPath, sizeof(g_sCountdownSoundStopPath));
	gc_sCountdownOverlayStartPath.GetString(g_sCountdownOverlayStartPath, sizeof(g_sCountdownOverlayStartPath));
	gc_sCountdownOverlayStopPath.GetString(g_sCountdownOverlayStopPath, sizeof(g_sCountdownOverlayStopPath));
}

public void Countdown_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sCountdownSoundStartPath)
	{
		strcopy(g_sCountdownSoundStartPath, sizeof(g_sCountdownSoundStartPath), newValue);
		if (gc_bCountdownSounds.BoolValue) PrecacheSoundAnyDownload(g_sCountdownSoundStartPath);
	}
	else if (convar == gc_sCountdownSoundStopPath)
	{
		strcopy(g_sCountdownSoundStopPath, sizeof(g_sCountdownSoundStopPath), newValue);
		if (gc_bCountdownSounds.BoolValue) PrecacheSoundAnyDownload(g_sCountdownSoundStopPath);
	}
	else if (convar == gc_sCountdownOverlayStartPath)
	{
		strcopy(g_sCountdownOverlayStartPath, sizeof(g_sCountdownOverlayStartPath), newValue);
		if (gc_bCountdownOverlays.BoolValue) PrecacheDecalAnyDownload(g_sCountdownOverlayStartPath);
	}
	else if (convar == gc_sCountdownOverlayStopPath)
	{
		strcopy(g_sCountdownOverlayStopPath, sizeof(g_sCountdownOverlayStopPath), newValue);
		if (gc_bCountdownOverlays.BoolValue) PrecacheDecalAnyDownload(g_sCountdownOverlayStopPath);
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_CountDownMenu(int client, int args)
{
	if (gc_bCountDown.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bCountDownDeputy.BoolValue))
		{
			char menuinfo[255];
			Menu menu = new Menu(Handler_CountDownMenu);
			
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_title", client);
			menu.SetTitle(menuinfo);

			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_start", client);
			menu.AddItem("start", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_stop", client);
			menu.AddItem("stop", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_startstop", client);
			menu.AddItem("startstop", menuinfo);

			menu.ExitButton = true;
			menu.ExitBackButton = true;
			menu.Display(client, 20);
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}


public Action Command_CancelCountDown(int client, int args)
{
	if (g_bIsCountDown)
	{
		g_iCountStopTime = -1;
		g_iCountStartTime = -1;
		g_hStartTimer = null;
		g_hStartStopTimer = null;
		g_hStopTimer = null;
		g_bIsCountDown = false;
		CPrintToChatAll("%s %t", g_sPrefix, "warden_countdowncanceled");
	}

	return Plugin_Handled;
}


public Action Command_StartStopMenu(int client, int args)
{
	if (gc_bCountDown.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bCountDownDeputy.BoolValue))
		{
			char menuinfo[255];
			Menu menu = new Menu(Handler_StartStopMenu);

			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_title2", client);
			menu.SetTitle(menuinfo);

			Format(menuinfo, sizeof(menuinfo), "%T", "warden_15", client);
			menu.AddItem("15", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_30", client);
			menu.AddItem("30", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_45", client);
			menu.AddItem("45", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_60", client);
			menu.AddItem("60", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_90", client);
			menu.AddItem("90", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_120", client);
			menu.AddItem("120", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_180", client);
			menu.AddItem("180", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_300", client);
			menu.AddItem("300", menuinfo);

			menu.ExitBackButton = true;
			menu.ExitButton = true;
			menu.Display(client, 20);
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

public Action Command_StartCountDown(int client, int args)
{
	if (gc_bCountDown.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bCountDownDeputy.BoolValue))
		{
			if (!g_bIsCountDown)
			{
				g_iCountStopTime = 9;
				g_hStartTimer = CreateTimer(1.0, Timer_StartCountdown, GetClientUserId(client), TIMER_REPEAT);
				
				CPrintToChatAll("%s %t", g_sPrefix, "warden_startcountdownhint");
				
				if (gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_startcountdownhint_nc");
				}
				
				g_bIsCountDown = true;
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_countdownrunning");
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

public Action Command_StopCountDown(int client, int args)
{
	if (gc_bCountDown.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bCountDownDeputy.BoolValue))
		{
			if (!g_bIsCountDown)
			{
				g_iCountStopTime = 20;
				g_hStopTimer = CreateTimer(1.0, Timer_StopCountdown, GetClientUserId(client), TIMER_REPEAT);

				CPrintToChatAll("%s %t", g_sPrefix, "warden_stopcountdownhint");

				if (gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_stopcountdownhint_nc");
				}

				g_bIsCountDown = true;
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_countdownrunning");
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Countdown_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (g_hStopTimer != null) KillTimer(g_hStopTimer);
	if (g_hStartTimer != null) KillTimer(g_hStartTimer);
	if (g_hStartStopTimer != null) KillTimer(g_hStartStopTimer);

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		Command_CancelCountDown(i, 0);
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void Countdown_OnMapStart()
{
	if (gc_bCountdownSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sCountdownSoundStopPath);
		PrecacheSoundAnyDownload(g_sCountdownSoundStartPath);
	}

	if (gc_bCountdownOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sCountdownOverlayStartPath);
		PrecacheDecalAnyDownload(g_sCountdownOverlayStopPath);
	}
}

public void Countdown_OnMapEnd()
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) Command_CancelCountDown(i, 0);
}

public void Countdown_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Countdown
	gc_sCustomCommandCD.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_CountDownMenu, "Allows the Warden to open the Countdown Menu");
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void SetStartStopCountDown(int client)
{
	if (gc_bCountDown.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bCountDownDeputy.BoolValue))
		{
			if (!g_bIsCountDown)
			{
				g_iCountStartTime = 9;
				g_hStartTimer = CreateTimer(1.0, Timer_StartCountdown, GetClientUserId(client), TIMER_REPEAT);
				g_hStartStopTimer = CreateTimer(1.0, Timer_StopStartStopCountdown, GetClientUserId(client), TIMER_REPEAT);

				CPrintToChatAll("%s %t", g_sPrefix, "warden_startstopcountdownhint");

				if (gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_startstopcountdownhint_nc");
				}

				g_bIsCountDown = true;
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_countdownrunning");
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}
}


/******************************************************************************
                   MENUS
******************************************************************************/


public int Handler_CountDownMenu(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if (strcmp(info, "start") == 0)
		{
			FakeClientCommand(client, "sm_cdstart");
			
			if (g_bMenuClose != null)
			{
				if (!g_bMenuClose)
				{
					FakeClientCommand(client, "sm_menu");
				}
			}
		}
		else if (strcmp(info, "stop") == 0)
		{
			FakeClientCommand(client, "sm_cdstop");
			
			if (g_bMenuClose != null)
			{
				if (!g_bMenuClose)
				{
					FakeClientCommand(client, "sm_menu");
				}
			}
		}
		else if (strcmp(info, "startstop") == 0)
		{
		FakeClientCommand(client, "sm_cdstartstop");
		}
	}
	else if (selection == MenuCancel_ExitBack) 
	{
		FakeClientCommand(client, "sm_menu");
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}


public int Handler_StartStopMenu(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if (strcmp(info, "15") == 0)
		{
			g_iSetCountStartStopTime = 25;
			SetStartStopCountDown(client);
		}
		else if (strcmp(info, "30") == 0)
		{
			g_iSetCountStartStopTime = 40;
			SetStartStopCountDown(client);
		}
		else if (strcmp(info, "45") == 0)
		{
			g_iSetCountStartStopTime = 55;
			SetStartStopCountDown(client);
		}
		else if (strcmp(info, "60") == 0)
		{
			g_iSetCountStartStopTime = 70;
			SetStartStopCountDown(client);
		}
		else if (strcmp(info, "90") == 0)
		{
			g_iSetCountStartStopTime = 100;
			SetStartStopCountDown(client);
		}
		else if (strcmp(info, "120") == 0)
		{
			g_iSetCountStartStopTime = 130;
			SetStartStopCountDown(client);
		}
		else if (strcmp(info, "180") == 0)
		{
			g_iSetCountStartStopTime = 190;
			SetStartStopCountDown(client);
		}
		else if (strcmp(info, "300") == 0)
		{
			g_iSetCountStartStopTime = 310;
			SetStartStopCountDown(client);
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
		if (selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_cdmenu");
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

public Action Timer_StartCountdown(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (g_iCountStartTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (g_iCountStartTime < 6) 
			{
				PrintCenterText(client, "%t", "warden_startcountdown_nc", g_iCountStartTime);
				CPrintToChatAll("%s %t", g_sPrefix, "warden_startcountdown", g_iCountStartTime);
			}
		}

		g_iCountStartTime--;

		return Plugin_Continue;
	}

	if (g_iCountStartTime == 0)
	{
		if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintCenterText(client, "%t", "warden_countdownstart_nc");
			CPrintToChatAll("%s %t", g_sPrefix, "warden_countdownstart");

			if (gc_bCountdownOverlays.BoolValue)
			{
				ShowOverlayAll(g_sCountdownOverlayStartPath, 2.0);
			}

			if (gc_bCountdownSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sCountdownSoundStartPath);
			}

			g_hStartTimer = null;
			g_bIsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;

			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

public Action Timer_StopCountdown(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (g_iCountStopTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (g_iCountStopTime < 16) 
			{
				PrintCenterText(client, "%t", "warden_stopcountdown_nc", g_iCountStopTime);
				CPrintToChatAll("%s %t", g_sPrefix, "warden_stopcountdown", g_iCountStopTime);
			}
		}

		g_iCountStopTime--;

		return Plugin_Continue;
	}

	if (g_iCountStopTime == 0)
	{
		if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintCenterText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%s %t", g_sPrefix, "warden_countdownstop");

			if (gc_bCountdownOverlays.BoolValue)
			{
				ShowOverlayAll(g_sCountdownOverlayStopPath, 2.0);
			}

			if (gc_bCountdownSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sCountdownSoundStopPath);
			}

			g_hStopTimer = null;
			g_bIsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;

			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

public Action Timer_StopStartStopCountdown(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (g_iSetCountStartStopTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (g_iSetCountStartStopTime < 11) 
			{
				PrintCenterText(client, "%t", "warden_stopcountdown_nc", g_iSetCountStartStopTime);
				CPrintToChatAll("%s %t", g_sPrefix, "warden_stopcountdown", g_iSetCountStartStopTime);
			}
		}

		g_iSetCountStartStopTime--;
		g_bIsCountDown = true;

		return Plugin_Continue;
	}

	if (g_iSetCountStartStopTime == 0)
	{
		if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintCenterText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%s %t", g_sPrefix, "warden_countdownstop");

			if (gc_bCountdownOverlays.BoolValue)
			{
				ShowOverlayAll(g_sCountdownOverlayStopPath, 2.0);
			}

			if (gc_bCountdownSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sCountdownSoundStopPath);
			}

			g_hStartStopTimer = null;
			g_bIsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;

			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}