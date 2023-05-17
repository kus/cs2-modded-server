/*
 * MyJailbreak - Stamm Support.
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
#include <cstrike>
#include <colors>
#include <autoexecconfig>
#include <mystocks>
#include <stamm>
#include <myjailbreak>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_iMinStammPointsRatio;
ConVar gc_iMinStammPointsWarden;

char g_sPrefixW[64];
char g_sPrefixR[64];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Stamm Support for Ratio & Warden", 
	author = "shanapu, Addicted, good_live", 
	description = "Adds support for popoklopsi stamm plugin to MyJB ratio & warden", 
	version = MYJB_VERSION, 
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");
	LoadTranslations("MyJailbreak.Warden.phrases");

	// AutoExecConfig
	AutoExecConfig_SetFile("Ratio", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	gc_iMinStammPointsRatio = AutoExecConfig_CreateConVar("sm_ratio_stamm", "0", "0 - disabled, how many stamm points a player need to join ct? (only if stamm is available)", _, true, 0.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// AutoExecConfig
	AutoExecConfig_SetFile("Warden", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	gc_iMinStammPointsWarden = AutoExecConfig_CreateConVar("sm_warden_stamm", "0", "0 - disabled, how many stamm points a player need to become warden? (only if stamm is available)", _, true, 0.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("myratio") && !LibraryExists("warden"))
	{
		SetFailState("MyJailbreaks Ratio (ratio.smx) and Warden (warden.smx) plugins are missing. You need at least one of them.");
	}
}

public void OnConfigsExecuted()
{
	ConVar cBuffer = FindConVar("sm_ratio_prefix");
	cBuffer.GetString(g_sPrefixR, sizeof(g_sPrefixR));

	cBuffer = FindConVar("sm_warden_prefix");
	cBuffer.GetString(g_sPrefixW, sizeof(g_sPrefixW));
}

public Action MyJailbreak_OnJoinGuardQueue(int client)
{
	if (STAMM_GetClientPoints(client) < gc_iMinStammPointsRatio.IntValue)
	{
		CPrintToChat(client, "%s %t", g_sPrefixR, "ratio_stamm", gc_iMinStammPointsRatio.IntValue);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action warden_OnWardenCreate(int client, int caller)
{
	if (STAMM_GetClientPoints(client) < gc_iMinStammPointsWarden.IntValue)
	{
		CPrintToChat(client, "%s %t", g_sPrefixW, "warden_stamm", gc_iMinStammPointsWarden.IntValue);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool bDontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!IsValidClient(client, false, false))
		return Plugin_Continue;

	if (GetClientTeam(client) != CS_TEAM_CT)
		return Plugin_Continue;

	if (MyJailbreak_IsEventDayRunning())
		return Plugin_Continue;

	if (STAMM_GetClientPoints(client) < gc_iMinStammPointsRatio.IntValue)
	{
		CPrintToChat(client, "%s %t", g_sPrefixR, "ratio_stamm", gc_iMinStammPointsRatio.IntValue);
		CreateTimer(5.0, Timer_SlayPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}

	return Plugin_Continue;
}

public Action Timer_SlayPlayer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if ((IsValidClient(client, false, false)) && (GetClientTeam(client) == CS_TEAM_CT))
	{
		ForcePlayerSuicide(client);
		ChangeClientTeam(client, CS_TEAM_T);
		CS_RespawnPlayer(client);
		MinusDeath(client);
	}

	return Plugin_Stop;
}

void MinusDeath(int client)
{
	if (IsValidClient(client, true, true))
	{
		int frags = GetEntProp(client, Prop_Data, "m_iFrags");
		int deaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		SetEntProp(client, Prop_Data, "m_iFrags", (frags+1));
		SetEntProp(client, Prop_Data, "m_iDeaths", (deaths-1));
	}
}