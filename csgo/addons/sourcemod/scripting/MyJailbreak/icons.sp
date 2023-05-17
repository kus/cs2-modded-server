/*
 * MyJailbreak - Icons Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Kxnrl
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
#include <myicons>
#include <clientprefs>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <warden>
#include <myjbwarden>
#include <hosties>
#include <lastrequest>
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bEventDay;
ConVar gc_bIconWarden;
ConVar gc_sIconWardenPath;
ConVar gc_bIconDeputy;
ConVar gc_sIconDeputyPath;
ConVar gc_bIconGuard;
ConVar gc_sIconGuardPath;
ConVar gc_bIconPrisoner;
ConVar gc_sIconPrisonerPath;
ConVar gc_bIconCuffed;
ConVar gc_sIconCuffedPath;
ConVar gc_bIconRebel;
ConVar gc_sIconRebelPath;
ConVar gc_bIconFreeday;
ConVar gc_sIconFreedayPath;
ConVar gc_sCustomCommand;
ConVar gc_sPrefix;

// Bools
bool g_bIsLateLoad = false;
bool gp_bWarden = false;
bool gp_bMyJBWarden = false;
bool gp_bHosties = false;
bool g_bBlockIcon[MAXPLAYERS+1] = {false, ...};

// Integers
int g_iIcon[MAXPLAYERS + 1] = {-1, ...};

// Strings
char g_sIconWardenPath[256];
char g_sIconDeputyPath[256];
char g_sIconGuardPath[256];
char g_sIconPrisonerPath[256];
char g_sIconRebelPath[256];
char g_sIconCuffedPath[256];
char g_sIconFreedayPath[256];
char g_sPrefix[64];


bool g_bEnable[MAXPLAYERS+1] = true;
Handle g_hCookie = null;

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Icons",
	author = "shanapu",
	description = "Show Team & status icons above player heads",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Icons.phrases");

	RegConsoleCmd("sm_icons", Command_Icons, "Allows player to toggle the player icons.");

	g_hCookie = RegClientCookie("PlayerIcons", "MyJailbreak Icons prefs", CookieAccess_Public);
	SetCookiePrefabMenu(g_hCookie, CookieMenu_OnOff_Int, "MyJailbreak Icons", Handler_Cookie);

	// AutoExecConfig
	AutoExecConfig_SetFile("Icons", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	// AutoExecConfig
	gc_bEventDay = AutoExecConfig_CreateConVar("sm_icons_eventday", "1", "0 - use the icons, 1 - disable icons on EventDays", _, true, 0.0, true, 1.0);
	gc_bIconWarden = AutoExecConfig_CreateConVar("sm_icons_warden_enable", "1", "0 - disabled, 1 - enable the icon above the wardens head", _, true, 0.0, true, 1.0);
	gc_sIconWardenPath = AutoExecConfig_CreateConVar("sm_icons_warden_path", "decals/MyJailbreak/warden", "Path to the warden icon DONT TYPE .vmt or .vft");
	gc_bIconDeputy = AutoExecConfig_CreateConVar("sm_icons_deputy_enable", "1", "0 - disabled, 1 - enable the icon above the deputy head", _, true, 0.0, true, 1.0);
	gc_sIconDeputyPath = AutoExecConfig_CreateConVar("sm_icons_deputy_path", "decals/MyJailbreak/warden-2", "Path to the deputy icon DONT TYPE .vmt or .vft");
	gc_bIconGuard = AutoExecConfig_CreateConVar("sm_icons_ct_enable", "1", "0 - disabled, 1 - enable the icon above the guards head", _, true, 0.0, true, 1.0);
	gc_sIconGuardPath = AutoExecConfig_CreateConVar("sm_icons_ct_path", "decals/MyJailbreak/ct", "Path to the guard icon DONT TYPE .vmt or .vft");
	gc_bIconPrisoner = AutoExecConfig_CreateConVar("sm_icons_t_enable", "1", "0 - disabled, 1 - enable the icon above the prisoners head", _, true, 0.0, true, 1.0);
	gc_sIconPrisonerPath = AutoExecConfig_CreateConVar("sm_icons_t_path", "decals/MyJailbreak/terror-fix", "Path to the prisoner icon DONT TYPE .vmt or .vft");
	gc_bIconRebel = AutoExecConfig_CreateConVar("sm_icons_rebel_enable", "1", "0 - disabled, 1 - enable the icon above the rebel prisoners head", _, true, 0.0, true, 1.0);
	gc_sIconRebelPath = AutoExecConfig_CreateConVar("sm_icons_rebel_path", "decals/MyJailbreak/rebel", "Path to the rebel prisoner icon DONT TYPE .vmt or .vft");
	gc_bIconCuffed = AutoExecConfig_CreateConVar("sm_icons_cuffs_enable", "1", "0 - disabled, 1 - enable the icon above the cuffed prisoners head", _, true, 0.0, true, 1.0);
	gc_sIconCuffedPath = AutoExecConfig_CreateConVar("sm_icons_cuffs_path", "decals/MyJailbreak/cuffed", "Path to the cuffed prisoner icon DONT TYPE .vmt or .vft");
	gc_bIconFreeday = AutoExecConfig_CreateConVar("sm_icons_freeday_enable", "1", "0 - disabled, 1 - enable the icon above the prisoners with freeday head", _, true, 0.0, true, 1.0);
	gc_sIconFreedayPath = AutoExecConfig_CreateConVar("sm_icons_freeday", "decals/MyJailbreak/freeday", "Path to the freeday icon DONT TYPE .vmt or .vft");
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_icons_cmds", "icon", "Set your custom chat commands for toggle Icons(!icons (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_icons_prefix", "[{green}MyJB.Icons{default}]", "Set your chat prefix for this plugin.");

	// AutoExecConfig
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_poststart", Event_PostRoundStart);
	HookEvent("player_death", Event_PlayerDeathTeam);
	HookEvent("player_team", Event_PlayerDeathTeam);
	HookConVarChange(gc_sIconWardenPath, OnSettingChanged);
	HookConVarChange(gc_sIconDeputyPath, OnSettingChanged);
	HookConVarChange(gc_sIconGuardPath, OnSettingChanged);
	HookConVarChange(gc_sIconPrisonerPath, OnSettingChanged);
	HookConVarChange(gc_sIconRebelPath, OnSettingChanged);
	HookConVarChange(gc_sIconCuffedPath, OnSettingChanged);
	HookConVarChange(gc_sIconFreedayPath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	gc_sIconWardenPath.GetString(g_sIconWardenPath, sizeof(g_sIconWardenPath));
	gc_sIconWardenPath.GetString(g_sIconDeputyPath, sizeof(g_sIconDeputyPath));
	gc_sIconGuardPath.GetString(g_sIconGuardPath, sizeof(g_sIconGuardPath));
	gc_sIconPrisonerPath.GetString(g_sIconPrisonerPath, sizeof(g_sIconPrisonerPath));
	gc_sIconRebelPath.GetString(g_sIconRebelPath, sizeof(g_sIconRebelPath));
	gc_sIconCuffedPath.GetString(g_sIconCuffedPath, sizeof(g_sIconCuffedPath));
	gc_sIconFreedayPath.GetString(g_sIconFreedayPath, sizeof(g_sIconFreedayPath));

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
}

public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sPrefix)
	{
		strcopy(g_sPrefix, sizeof(g_sPrefix), newValue);
	}
	else if (convar == gc_sIconWardenPath)
	{
		strcopy(g_sIconWardenPath, sizeof(g_sIconWardenPath), newValue);
		if (gc_bIconWarden.BoolValue)
		{
			PrecacheModelAnyDownload(g_sIconWardenPath);
		}
	}
	else if (convar == gc_sIconDeputyPath)
	{
		strcopy(g_sIconDeputyPath, sizeof(g_sIconDeputyPath), newValue);
		if (gc_bIconDeputy.BoolValue)
		{
			PrecacheModelAnyDownload(g_sIconDeputyPath);
		}
	}
	else if (convar == gc_sIconGuardPath)
	{
		strcopy(g_sIconGuardPath, sizeof(g_sIconGuardPath), newValue);
		if (gc_bIconGuard.BoolValue)
		{
			PrecacheModelAnyDownload(g_sIconGuardPath);
		}
	}
	else if (convar == gc_sIconPrisonerPath)
	{
		strcopy(g_sIconPrisonerPath, sizeof(g_sIconPrisonerPath), newValue);
		if (gc_bIconPrisoner.BoolValue)
		{
			PrecacheModelAnyDownload(g_sIconPrisonerPath);
		}
	}
	else if (convar == gc_sIconRebelPath)
	{
		strcopy(g_sIconRebelPath, sizeof(g_sIconRebelPath), newValue);
		if (gc_bIconRebel.BoolValue)
		{
			PrecacheModelAnyDownload(g_sIconRebelPath);
		}
	}
	else if (convar == gc_sIconCuffedPath)
	{
		strcopy(g_sIconCuffedPath, sizeof(g_sIconCuffedPath), newValue);
		if (gc_bIconCuffed.BoolValue)
		{
			PrecacheModelAnyDownload(g_sIconCuffedPath);
		}
	}
	else if (convar == gc_sIconFreedayPath)
	{
		strcopy(g_sIconFreedayPath, sizeof(g_sIconFreedayPath), newValue);
		if (gc_bIconFreeday.BoolValue)
		{
			PrecacheModelAnyDownload(g_sIconFreedayPath);
		}
	}
}

public void OnAllPluginsLoaded()
{
	gp_bWarden = LibraryExists("warden");
	gp_bMyJBWarden = LibraryExists("myjbwarden");
	gp_bHosties = LibraryExists("lastrequest");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "warden"))
	{
		gp_bWarden = false;
	}
	else if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = false;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "warden"))
	{
		gp_bWarden = true;
	}
	else if (StrEqual(name, "myjbwarden"))
	{
		gp_bMyJBWarden = true;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bHosties = true;
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
	gc_sCustomCommand.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_Icons, "Allows player to toggle the player icons.");
		}
	}
}

/******************************************************************************
                   COMMANDS & COOKIE
******************************************************************************/

// Toggle hud
public Action Command_Icons(int client, int args)
{
	if (!g_bEnable[client])
	{
		g_bEnable[client] = true;
		SetClientCookie(client, g_hCookie, "1");

		CReplyToCommand(client, "%s %t", g_sPrefix, "icons_on");
	}
	else
	{
		g_bEnable[client] = false;
		SetClientCookie(client, g_hCookie, "0");

		CReplyToCommand(client, "%s %t", g_sPrefix, "icons_off");
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
	g_bEnable[client] = true;
	char sBuffer[8];
	GetClientCookie(client, g_hCookie, sBuffer, sizeof(sBuffer));

	if(sBuffer[0] != '\0')
	{
		g_bEnable[client] = view_as<bool>(StringToInt(sBuffer));
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/

public void Event_PostRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(0.1, Timer_Delay);
}

public void Event_PlayerDeathTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

	RemoveIcon(client);
}

public void OnClientDisconnect(int client)
{
	RemoveIcon(client);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void OnMapStart()
{
	if (gc_bIconWarden.BoolValue)
	{
		PrecacheModelAnyDownload(g_sIconWardenPath);
	}

	if (gc_bIconGuard.BoolValue)
	{
		PrecacheModelAnyDownload(g_sIconGuardPath);
	}

	if (gc_bIconPrisoner.BoolValue)
	{
		PrecacheModelAnyDownload(g_sIconPrisonerPath);
	}

	if (gc_bIconDeputy.BoolValue)
	{
		PrecacheModelAnyDownload(g_sIconDeputyPath);
	}

	if (gc_bIconRebel.BoolValue)
	{
		PrecacheModelAnyDownload(g_sIconRebelPath);
	}

	if (gc_bIconCuffed.BoolValue)
	{
		PrecacheModelAnyDownload(g_sIconCuffedPath);
	}

	if (gc_bIconFreeday.BoolValue)
	{
		PrecacheModelAnyDownload(g_sIconFreedayPath);
	}

	CreateTimer(0.5, Timer_Delay, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void warden_OnWardenCreatedByUser(int client)
{
	CreateTimer(0.1, Timer_Delay);
}

public void warden_OnWardenCreatedByAdmin(int client)
{
	CreateTimer(0.1, Timer_Delay);
}

public void warden_OnWardenRemoved(int client)
{
	CreateTimer(0.1, Timer_Delay);
}

public void warden_OnDeputyCreated(int client)
{
	CreateTimer(0.1, Timer_Delay);
}

public void warden_OnDeputyRemoved(int client)
{
	CreateTimer(0.1, Timer_Delay);
}

public Action Timer_Delay(Handle timer, Handle pack)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, false))
			continue;

		SpawnIcon(i);
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

public Action Should_TransmitG(int entity, int client)
{
	if (!g_bEnable[client])
		return Plugin_Handled;

	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconGuardPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

public Action Should_TransmitW(int entity, int client)
{
	if (!g_bEnable[client])
		return Plugin_Handled;

	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconWardenPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}


public Action Should_TransmitD(int entity, int client)
{
	if (!g_bEnable[client])
		return Plugin_Handled;

	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconDeputyPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}


public Action Should_TransmitP(int entity, int client)
{
	if (!g_bEnable[client])
		return Plugin_Handled;

	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPrisonerPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

public Action Should_TransmitR(int entity, int client)
{
	if (!g_bEnable[client])
		return Plugin_Handled;

	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconRebelPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}


public Action Should_TransmitC(int entity, int client)
{
	if (!g_bEnable[client])
		return Plugin_Handled;

	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconCuffedPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}


public Action Should_TransmitF(int entity, int client)
{
	if (!g_bEnable[client])
		return Plugin_Handled;

	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconFreedayPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}


/******************************************************************************
                   STOCKS
******************************************************************************/

// TODO bool warden functions

void SpawnIcon(int client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	RemoveIcon(client);

	if (gc_bEventDay.BoolValue && MyJailbreak_IsEventDayRunning())
		return;

	if (g_bBlockIcon[client])
		return;

	g_iIcon[client] = CreateEntityByName("env_sprite");

	if (!g_iIcon[client])
		return;

	char iconbuffer[256];

	if (gp_bWarden)
	{
		if (gc_bIconWarden.BoolValue && warden_iswarden(client))
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconWardenPath);
		}
		else if (gp_bMyJBWarden && gc_bIconDeputy.BoolValue && warden_deputy_isdeputy(client))
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconDeputyPath);
		}
		else if (gp_bMyJBWarden && gc_bIconCuffed.BoolValue && warden_handcuffs_iscuffed(client))
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconCuffedPath);
		}
		else if (gc_bIconGuard.BoolValue && GetClientTeam(client) == CS_TEAM_CT)
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconGuardPath);
		}
		else if (gp_bHosties)
		{
			if (gc_bIconRebel.BoolValue && IsClientRebel(client))
			{
				Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconRebelPath);
			}
				else if (gp_bMyJBWarden && gc_bIconFreeday.BoolValue && warden_freeday_has(client))
			{
				Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconFreedayPath);
			}
				else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
			{
				Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPrisonerPath);
			}
		}
		else if (gp_bMyJBWarden && gc_bIconFreeday.BoolValue && warden_freeday_has(client))
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconFreedayPath);
		}
		else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPrisonerPath);
		}
	}
	else if (gc_bIconGuard.BoolValue && GetClientTeam(client) == CS_TEAM_CT)
	{
		Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconGuardPath);
	}
	else if (gp_bHosties)
	{
		if (gc_bIconRebel.BoolValue && IsClientRebel(client))
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconRebelPath);
		}
		else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
		{
			Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPrisonerPath);
		}
	}
	else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
	{
		Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPrisonerPath);
	}

	DispatchKeyValue(g_iIcon[client], "model", iconbuffer);
	DispatchKeyValue(g_iIcon[client], "classname", "env_sprite");
	DispatchKeyValue(g_iIcon[client], "spawnflags", "1");
	DispatchKeyValue(g_iIcon[client], "scale", "0.3");
	DispatchKeyValue(g_iIcon[client], "rendermode", "1");
	DispatchKeyValue(g_iIcon[client], "rendercolor", "255 255 255");
	DispatchSpawn(g_iIcon[client]);

	float origin[3];
	GetClientAbsOrigin(client, origin);
	origin[2] = origin[2] + 90.0;

	TeleportEntity(g_iIcon[client], origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("!activator");
	AcceptEntityInput(g_iIcon[client], "SetParent", client, g_iIcon[client], 0);

	if (gp_bWarden)
	{
		if (gc_bIconWarden.BoolValue && warden_iswarden(client))
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitW);
		}
		else if (gp_bMyJBWarden && gc_bIconDeputy.BoolValue && warden_deputy_isdeputy(client))
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitD);
		}
		else if (gp_bMyJBWarden && gc_bIconCuffed.BoolValue && warden_handcuffs_iscuffed(client))
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitC);
		}
		else if (gc_bIconGuard.BoolValue && GetClientTeam(client) == CS_TEAM_CT)
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitG);
		}
		else if (gp_bHosties)
		{
			if (gc_bIconRebel.BoolValue && IsClientRebel(client))
			{
				SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitR);
			}
				else if (gp_bMyJBWarden && gc_bIconFreeday.BoolValue && warden_freeday_has(client))
			{
				SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitF);
			}
				else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
			{
				SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitP);
			}
		}
		else if (gp_bMyJBWarden && gc_bIconFreeday.BoolValue && warden_freeday_has(client))
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitF);
		}
		else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitP);
		}
	}
	else if (gc_bIconGuard.BoolValue && GetClientTeam(client) == CS_TEAM_CT)
	{
		SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitG);
	}
	else if (gp_bHosties)
	{
		if (gc_bIconRebel.BoolValue && IsClientRebel(client))
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitR);
		}
		else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
		{
			SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitP);
		}
	}
	else if (gc_bIconPrisoner.BoolValue && GetClientTeam(client) == CS_TEAM_T)
	{
		SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitP);
	}
}

void RemoveIcon(int client) 
{
	if (g_iIcon[client] > 0 && IsValidEdict(g_iIcon[client]))
	{
		AcceptEntityInput(g_iIcon[client], "Kill");
		g_iIcon[client] = -1;
	}
}

/******************************************************************************
                   NATIVES
******************************************************************************/

// Register Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("MyIcons_BlockClientIcon", Native_BlockIcon);

	RegPluginLibrary("myicons");

	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Set state of Block Icon (true/false)
public int Native_BlockIcon(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
	{
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	}

	g_bBlockIcon[client] = GetNativeCell(2);
}