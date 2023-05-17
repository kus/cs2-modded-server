/*
 * MyJailbreak - Player HUD Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Hexer10
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
#include <myjailbreak>
#include <clientprefs>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjbwarden>
#include <hosties>
#include <lastrequest>
#include <franug_deadgames>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;
bool gp_bMyJBWarden = false;
bool gp_bHosties = false;
bool gp_bDeadGames = false;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_sCustomCommandHUD;
ConVar gc_bAlive;
ConVar gc_bType;
ConVar gc_iRed;
ConVar gc_iBlue;
ConVar gc_iGreen;
ConVar gc_iAlpha;
ConVar gc_fX;
ConVar gc_fY;

// Booleans
bool g_bEnableHud[MAXPLAYERS+1] = true;

// Handle
Handle g_hHUD;
Handle g_hCookie = null;

// Strings
char g_sPrefix[64];

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - Player HUD",
	description = "A player HUD to display game informations",
	author = "shanapu",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.HUD.phrases");

	RegConsoleCmd("sm_hud", Command_HUD, "Allows player to toggle the hud display.");

	g_hCookie = RegClientCookie("PlayerHUD", "MyJailbreak HUD prefs", CookieAccess_Public);
	SetCookiePrefabMenu(g_hCookie, CookieMenu_OnOff_Int, "MyJailbreak HUD", Handler_Cookie);

	// AutoExecConfig
	AutoExecConfig_SetFile("PlayerHUD", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_hud_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hud_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_hud_prefix", "[{green}MyJB.HUD{default}]", "Set your chat prefix for this plugin.");
	gc_bAlive = AutoExecConfig_CreateConVar("sm_hud_alive", "1", "0 - show hud only to alive player, 1 - show hud to dead & alive player", _, true, 0.0, true, 1.0);
	gc_bType = AutoExecConfig_CreateConVar("sm_hud_type", "1", "0 - show hud via a center-bottom hint box (sm_hsay), 1 - show hud via 'new hud' system", _, true, 0.0, true, 1.0);
	gc_fX = AutoExecConfig_CreateConVar("sm_hud_x", "-1", "x coordinate, from 0 to 1. -1.0 is the center of sm_hud_type '1'", _, true, -1.0, true, 1.0);
	gc_fY = AutoExecConfig_CreateConVar("sm_hud_y", "0.1", "y coordinate, from 0 to 1. -1.0 is the center of sm_hud_type '1'", _, true, -1.0, true, 1.0);
	gc_iRed = AutoExecConfig_CreateConVar("sm_hud_red", "0", "Color of sm_hud_type '1' (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iBlue = AutoExecConfig_CreateConVar("sm_hud_green", "200", "Color of sm_hud_type '1' (set R, G and B values to 255 to disable) (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iGreen = AutoExecConfig_CreateConVar("sm_hud_blue", "200", "Color of sm_hud_type '1' (set R, G and B values to 255 to disable) (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_iAlpha = AutoExecConfig_CreateConVar("sm_hud_alpha", "200", "Alpha value of sm_hud_type '1' (set value to 255 to disable for transparency)", _, true, 0.0, true, 255.0);
	gc_sCustomCommandHUD = AutoExecConfig_CreateConVar("sm_hud_cmds", "display", "Set your custom chat commands for toggle HUD(!hud (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks - Events to check for Tag
	HookEvent("player_death", Event_PlayerTeamDeath);
	HookEvent("player_team", Event_PlayerTeamDeath);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			OnClientCookiesCached(i);
		}

		g_bIsLateLoad = false;
	}

	g_hHUD = CreateHudSynchronizer();
}

// Check for optional Plugins
public void OnAllPluginsLoaded()
{
	gp_bMyJBWarden = LibraryExists("myjbwarden");
	gp_bHosties = LibraryExists("lastrequest");
	gp_bDeadGames = LibraryExists("franug_deadgames");
}


public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = false;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = false;
	}
	else if (StrEqual(name, "franug_deadgames"))
	{
		gp_bDeadGames = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = true;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = true;
	}
	else if (StrEqual(name, "franug_deadgames"))
	{
		gp_bDeadGames = true;
	}
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sPrefix)
	{
		strcopy(g_sPrefix, sizeof(g_sPrefix), newValue);
	}
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// HUd
	gc_sCustomCommandHUD.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_HUD, "Allows player to toggle the hud display.");
		}
	}
}

/******************************************************************************
                   COMMANDS & COOKIE
******************************************************************************/

// Toggle hud
public Action Command_HUD(int client, int args)
{
	if (!g_bEnableHud[client])
	{
		g_bEnableHud[client] = true;
		SetClientCookie(client, g_hCookie, "1");

		CReplyToCommand(client, "%s %t", g_sPrefix, "hud_on");
	}
	else
	{
		g_bEnableHud[client] = false;
		SetClientCookie(client, g_hCookie, "0");

		CReplyToCommand(client, "%s %t", g_sPrefix, "hud_off");
	}

	return Plugin_Handled;
}

public void Handler_Cookie(int client, CookieMenuAction action, any info, char [] buffer, int maxlen)
{
	if (action == CookieMenuAction_SelectOption)
	{
		OnClientCookiesCached(client);
	}
}

public void OnClientCookiesCached(int client)
{
	g_bEnableHud[client] = true;
	char sBuffer[8];
	GetClientCookie(client, g_hCookie, sBuffer, sizeof(sBuffer));

	if(sBuffer[0] != '\0')
	{
		g_bEnableHud[client] = view_as<bool>(StringToInt(sBuffer));
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/

// Warden change Team
public void Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast)
{
	ShowHUD();
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Prepare Plugin & modules
public void OnMapStart()
{
	if (gc_bPlugin.BoolValue)
	{
		CreateTimer(1.0, Timer_ShowHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void warden_OnWardenCreatedByUser(int client)
{
	ShowHUD();
}

public void warden_OnWardenCreatedByAdmin(int client)
{
	ShowHUD();
}

public void warden_OnWardenRemoved(int client)
{
	ShowHUD();
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_ShowHUD(Handle timer, Handle pack)
{
	ShowHUD();
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void ShowHUD()
{
	int warden = -1;
	if (gp_bMyJBWarden)
	{
		warden = warden_get();
	}

	int aliveCT = GetPlayerCount(true, CS_TEAM_CT);
	int allCT = GetTeamClientCount(CS_TEAM_CT);
	int aliveT = GetPlayerCount(true, CS_TEAM_T);
	int allT = GetTeamClientCount(CS_TEAM_T);
	int iLastCT = -1;
	char sLastCT[32];
	char sWarden[32];

	if (MyJailbreak_IsLastGuardRule())
	{
		iLastCT = GetLastAlive(CS_TEAM_CT);
		GetClientName(iLastCT, sLastCT, sizeof(sLastCT));
		ReplaceString(sLastCT, sizeof(sLastCT), "<", "", false);
	}

	if (warden != -1)
	{
		GetClientName(warden, sWarden, sizeof(sWarden));
		ReplaceString(sWarden, sizeof(sWarden), "<", "", false);
	}

	char EventDay[64];
	MyJailbreak_GetEventDayName(EventDay);

	if (!gc_bPlugin.BoolValue)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, false, gc_bAlive.BoolValue))
			continue;

		if (!g_bEnableHud[i])
			continue;

		if (gp_bHosties && IsClientInLastRequest(i))
			continue;

		if(gc_bType.BoolValue)
		{
			ClearSyncHud(i, g_hHUD);
			SetHudTextParams(gc_fX.FloatValue, gc_fY.FloatValue, 5.0, gc_iRed.IntValue, gc_iGreen.IntValue, gc_iBlue.IntValue, gc_iAlpha.IntValue, 1, 1.0, 0.0, 0.0);

			if (MyJailbreak_IsLastGuardRule())
			{
				if (iLastCT != -1)
				{
					if (MyJailbreak_IsEventDayPlanned())
					{
						ShowSyncHudText(i, g_hHUD, "%t %s\n%t %s\n%t %i/%i\t%t %i/%i\n", "hud_lastCT", sLastCT, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						ShowSyncHudText(i, g_hHUD, "%t %s\n%t %i/%i\t%t %i/%i\n", "hud_lastCT", sLastCT, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
			}
			else if (MyJailbreak_IsEventDayRunning())
			{
				ShowSyncHudText(i, g_hHUD, "%t %s\n%t %i/%i\t%t %i/%i\n", "hud_running", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
			}
			else if (gp_bMyJBWarden && warden == -1)
			{
				if (MyJailbreak_IsEventDayPlanned())
				{
					ShowSyncHudText(i, g_hHUD, "%t %t\n%t %s\n%t %i/%i\t%t %i/%i", "hud_warden", "hud_nowarden", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
				else
				{
					ShowSyncHudText(i, g_hHUD, "%t %t\n%t %i/%i\t%t %i/%i\n", "hud_warden", "hud_nowarden", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
			}
			else if (gp_bMyJBWarden)
			{
				if (MyJailbreak_IsEventDayPlanned())
				{
					if (warden == i)
					{
						ShowSyncHudText(i, g_hHUD, "%t\n%t %s\n%t %i/%i\t%t %i/%i\n", "hud_youwarden", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						ShowSyncHudText(i, g_hHUD, "%t %s\n%t %s\n%t %i/%i\t%t %i/%i\n", "hud_warden", sWarden, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
				else
				{
					if (warden == i)
					{
						ShowSyncHudText(i, g_hHUD, "%t\n%t %i/%i\t%t %i/%i\n", "hud_youwarden", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						ShowSyncHudText(i, g_hHUD, "%t %s\n%t %i/%i\t%t %i/%i\n", "hud_warden", sWarden, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
			}
			else
			{
				if (MyJailbreak_IsEventDayPlanned())
				{
					ShowSyncHudText(i, g_hHUD, "%t %s\n%t %i/%i\t%t %i/%i\n", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
				else
				{
					ShowSyncHudText(i, g_hHUD, "%t %i/%i\t%t %i/%i\n", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
			}
		}
		else
		{
			if (MyJailbreak_IsLastGuardRule())
			{
				if (iLastCT != -1)
				{
					if (MyJailbreak_IsEventDayPlanned())
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%s</font>\n<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_lastCT", sLastCT, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%s</font>\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_lastCT", sLastCT, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
			}
			else if (MyJailbreak_IsEventDayRunning())
			{
				PrintHintText(i, "<font face='Arial' color='#B980EF'>%t </font>%s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_running", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
			}
			else if (gp_bMyJBWarden && warden == -1)
			{
				if (MyJailbreak_IsEventDayPlanned())
				{
					PrintHintText(i, "<font face='Arial' color='#006699'>%t </font><font face='Arial' color='#FE4040'>%t</font>\n<font color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i", "hud_warden", "hud_nowarden", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
				else
				{
					PrintHintText(i, "<font face='Arial' color='#006699'>%t </font><font face='Arial' color='#FE4040'>%t</font>\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", "hud_nowarden", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
			}
			else if (gp_bMyJBWarden)
			{
				if (MyJailbreak_IsEventDayPlanned())
				{
					if (warden == i)
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t</font>\n<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_youwarden", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%s\n<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", sWarden, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
				else
				{
					if (warden == i)
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t</font>\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_youwarden", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", sWarden, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
			}
			else
			{
				if (MyJailbreak_IsEventDayPlanned())
				{
					PrintHintText(i, "<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
				else
				{
					PrintHintText(i, "<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
			}
		}
	}
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