/*
 * MyJailbreak - Menu Plugin.
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
#include <myjailbreak>
#include <adminmenu>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <smartjaildoors>
#include <myweapons>
#include <warden>
#include <myjbwarden>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad;
bool gp_bMyJailShop;
bool gp_bMyJailbreak;
bool gp_bSmartJailDoors;
bool gp_bMyWeapons;

bool gp_bWarden = false;
bool gp_bMyJBWarden = false;

// Integers
int g_iCoolDown;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bTerror;
ConVar gc_bCTerror;
ConVar gc_bWarden;
ConVar gc_bDeputy;
ConVar gc_bDaysSet;
ConVar gc_bDaysVote;
ConVar gc_bClose;
ConVar gc_bStart;
ConVar gc_bWelcome;
ConVar gc_bTeam;
ConVar gc_sCustomCommandMenu;
ConVar gc_sCustomCommandDays;
ConVar gc_sCustomCommandSetDay;
ConVar gc_sCustomCommandVoting;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_sAdminFlag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVoting;
ConVar gc_iAdminMenu;
ConVar gc_bCleanMenu;
ConVar gc_bShuffle;

// 3rd party Convars
ConVar g_bMath;
ConVar g_bMathDeputy;
ConVar g_bCheck;
ConVar g_bFF;
ConVar g_bRules;
ConVar g_bAdminFF;
ConVar g_bAdminFFDeputy;
ConVar g_bMute;
ConVar g_bMuteDeputy;
ConVar g_bExtend;
ConVar g_bExtendDeputy;
ConVar g_bNoLR;
ConVar g_bNoLRDeputy;
ConVar g_bLaserDeputy;
ConVar g_bPainterDeputy;
ConVar g_bLaser;
ConVar g_bPainter;
ConVar g_bNoBlock;
ConVar g_bNoBlockDeputy;
ConVar g_bCountdown;
ConVar g_bCountdownDeputy;
ConVar g_bVote;
ConVar g_bOpen;
ConVar g_bOpenDeputy;
ConVar g_bRandomDeputy;
ConVar g_bRandom;
ConVar g_bRequest;
ConVar g_bDeputy;
ConVar g_bDeputySet;
ConVar g_bDeputyBecome;
ConVar g_bWardenCount;
ConVar g_bWardenRebel;
ConVar g_bWardenCountDeputy;
ConVar g_bWardenRebelDeputy;
ConVar g_bSparksDeputy;
ConVar g_bPlayerFreedayDeputy;
ConVar g_bPlayerFreedayGuard;
ConVar g_bSparks;
ConVar g_bPlayerFreeday;
ConVar g_bEndRound;
ConVar gc_sAdminFlagBulletSparks;
ConVar gc_sAdminFlagLaser;
ConVar gc_sAdminFlagPainter;
ConVar gc_bOrders;
ConVar gc_bOrdersDeputy;
ConVar gc_bVoteNoMenu;

// Strings
char g_sPrefix[64];

// Handles
Handle gH_TopMenu = INVALID_HANDLE;
TopMenuObject gM_MyJB = INVALID_TOPMENUOBJECT;

Handle gF_hMenuStart;
Handle gF_hMenuEnd;
Handle gF_hMenuHandler;

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Menus",
	author = "shanapu",
	description = "Jailbreak Menu",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	gF_hMenuStart = CreateGlobalForward("MyJailbreak_MenuStart", ET_Ignore, Param_Cell, Param_Cell);
	gF_hMenuEnd = CreateGlobalForward("MyJailbreak_MenuEnd", ET_Ignore, Param_Cell, Param_Cell);
	gF_hMenuHandler = CreateGlobalForward("MyJailbreak_MenuHandler", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Menu.phrases");

	// Client Commands
	RegConsoleCmd("sm_menu", Command_OpenMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("buyammo1", Command_OpenMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("sm_eventdays", Command_VoteEventDays, "open a vote EventDays menu for player");
	RegConsoleCmd("sm_setday", Command_SetEventDay, "open a Set EventDays menu for Warden/Admin");
	RegConsoleCmd("sm_voteday", Command_VotingMenu, "Allows warden & admin to opens event day voting");

	// AutoExecConfig
	AutoExecConfig_SetFile("Menu", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_menu_version", MYJB_VERSION, "The version of the SourceMod plugin MyJailbreak - Menu", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_menu_enable", "1", "0 - disabled, 1 - enable jailbrek menu", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_menu_prefix", "[{green}MyJB.Menu{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandMenu = AutoExecConfig_CreateConVar("sm_menu_cmds_menu", "panel, menus, m", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandDays = AutoExecConfig_CreateConVar("sm_menu_cmds_days", "days, day, ed", "Set your custom chat command for open menu(!eventdays (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSetDay = AutoExecConfig_CreateConVar("sm_menu_cmds_setday", "sd, setdays", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandVoting = AutoExecConfig_CreateConVar("sm_menu_cmds_voting", "vd, votedays", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bCTerror = AutoExecConfig_CreateConVar("sm_menu_ct", "1", "0 - disabled, 1 - enable ct jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bTerror = AutoExecConfig_CreateConVar("sm_menu_t", "1", "0 - disabled, 1 - enable t jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bWarden = AutoExecConfig_CreateConVar("sm_menu_warden", "1", "0 - disabled, 1 - enable warden jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bDeputy = AutoExecConfig_CreateConVar("sm_menu_deputy", "1", "0 - disabled, 1 - enable deputy jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bDaysSet = AutoExecConfig_CreateConVar("sm_menu_setdays", "1", "0 - disabled, 1 - enable set eventdays menu", _, true, 0.0, true, 1.0);
	gc_bDaysVote = AutoExecConfig_CreateConVar("sm_menu_votedays", "1", "0 - disabled, 1 - enable vote eventdays menu", _, true, 0.0, true, 1.0);
	gc_bCleanMenu = AutoExecConfig_CreateConVar("sm_menu_clean", "1", "remove 1. & 2. on first page, to avoid conflict with weapon switch", _, true, 0.0, true, 1.0);
	gc_bShuffle = AutoExecConfig_CreateConVar("sm_menu_shuffle", "1", "0 - use 'config/sorting-eventdays.ini' on event day voting / 1 - Shuffle EventDays on voting", _, true, 0.0, true, 1.0);
	gc_bVoteNoMenu = AutoExecConfig_CreateConVar("sm_menu_vote_noevent", "1", "0 - disabled, 1 - allow player vote for 'no Event Day' on eventday voting", _, true, 0.0, true, 1.0);
	gc_bClose = AutoExecConfig_CreateConVar("sm_menu_close", "0", "0 - disabled, 1 - enable close menu after action", _, true, 0.0, true, 1.0);
	gc_bStart = AutoExecConfig_CreateConVar("sm_menu_start", "1", "0 - disabled, 1 - enable open menu on every roundstart", _, true, 0.0, true, 1.0);
	gc_bTeam = AutoExecConfig_CreateConVar("sm_menu_team", "1", "0 - disabled, 1 - enable join team on menu", _, true, 0.0, true, 1.0);
	gc_bWelcome = AutoExecConfig_CreateConVar("sm_menu_welcome", "1", "Show welcome message to newly connected users.", _, true, 0.0, true, 1.0);
	gc_bVoting = AutoExecConfig_CreateConVar("sm_menu_voteday", "1", "0 - disabled, 1 - enable voting for a eventday", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_menu_flag", "g", "Set flag for admin/vip to start a voting & get admin menu");
	gc_iAdminMenu = AutoExecConfig_CreateConVar("sm_menu_admin", "2", "0 - disable admin commands in all menus, 1 - show admin commands only in MyJailbreak menu, 2 - show admin commands only in !admin menu, 3 - show admin commands in all menus", _, true, 0.0, true, 3.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_menu_voteday_warden", "1", "0 - disabled, 1 - allow warden to start a voting", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_menu_voteday_admin", "1", "0 - disabled, 1 - allow admin/vip  to start a voting", _, true, 0.0, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_menu_voteday_cooldown_day", "3", "Rounds cooldown after a voting until voting can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_menu_voteday_cooldown_start", "3", "Rounds until voting can be start after mapchange.", _, true, 0.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("round_start", Event_RoundStart);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			OnClientPutInServer(i);
		}

		g_bIsLateLoad = false;
	}
}

void MyAdminMenuReady(Handle h_TopMenu)
{
	if (gc_iAdminMenu.IntValue < 2)
		return;

	// block double calls
	if (h_TopMenu == gH_TopMenu)
		return;

	gH_TopMenu = h_TopMenu;

	// Build MyJailbreak menu
	gM_MyJB = AddToTopMenu(gH_TopMenu, "MyJailbreak", TopMenuObject_Category, Handler_AdminMenu_Category, INVALID_TOPMENUOBJECT);

	if (gM_MyJB != INVALID_TOPMENUOBJECT)
	{
		if (g_bEndRound.BoolValue)
		{
			AddToTopMenu(gH_TopMenu, "sm_endround", TopMenuObject_Item, Handler_AdminMenu_EndRound, gM_MyJB, "sm_endround");
		}
		if (gc_bVoting.BoolValue)
		{
			AddToTopMenu(gH_TopMenu, "sm_votedays", TopMenuObject_Item, Handler_AdminMenu_VoteDays, gM_MyJB, "sm_voteday");
		}
		if (gc_bDaysSet.BoolValue)
		{
			AddToTopMenu(gH_TopMenu, "sm_setday", TopMenuObject_Item, Handler_AdminMenu_SetDay, gM_MyJB, "sm_setday");
		}
		if (gp_bMyJBWarden)
		{
			AddToTopMenu(gH_TopMenu, "sm_setwarden", TopMenuObject_Item, Handler_AdminMenu_SetWarden, gM_MyJB, "sm_setwarden");
			AddToTopMenu(gH_TopMenu, "sm_removewarden", TopMenuObject_Item, Handler_AdminMenu_RemoveWarden, gM_MyJB, "sm_removewarden");
			AddToTopMenu(gH_TopMenu, "sm_removedeputy", TopMenuObject_Item, Handler_AdminMenu_RemoveDeputy, gM_MyJB, "sm_removedeputy");
		}
		AddToTopMenu(gH_TopMenu, "sm_removequeue", TopMenuObject_Item, Handler_AdminMenu_RemoveQueue, gM_MyJB, "sm_removequeue");
		AddToTopMenu(gH_TopMenu, "sm_clearqueue", TopMenuObject_Item, Handler_AdminMenu_ClearQueue, gM_MyJB, "sm_clearqueue");
	}
}

public void Handler_AdminMenu_Category(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case (TopMenuAction_DisplayTitle):
		{
			Format(buffer, maxlength, "MyJailbreak:");
		}
		case (TopMenuAction_DisplayOption):
		{
			Format(buffer, maxlength, "MyJailbreak");
		}
	}
}

public void Handler_AdminMenu_EndRound(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_endround", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_endround");
		}
	}
}

public void Handler_AdminMenu_VoteDays(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_voteday", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_voteday");
		}
	}
}

public void Handler_AdminMenu_SetDay(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_seteventdays", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_setday");
		}
	}
}

public void Handler_AdminMenu_RemoveWarden(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_removewarden", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_removewarden");
		}
	}
}

public void Handler_AdminMenu_RemoveDeputy(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_removedeputy", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_removedeputy");
		}
	}
}

public void Handler_AdminMenu_SetWarden(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_setwarden", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_setwarden");
		}
	}
}

public void Handler_AdminMenu_RemoveQueue(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_removequeue", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_removequeue");
		}
	}
}

public void Handler_AdminMenu_ClearQueue(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_clearqueue", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_clearqueue");
		}
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

// Check for optional Plugins
public void OnAllPluginsLoaded()
{
	gp_bWarden = LibraryExists("warden");
	gp_bMyJBWarden = LibraryExists("myjbwarden");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bMyJailbreak = LibraryExists("myjailbreak");
	gp_bMyJailShop = LibraryExists("myjailshop");
	gp_bMyWeapons = LibraryExists("myweapons");
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
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = false;
	}
	else if (StrEqual(name, "myjailshop"))
	{
		gp_bMyJailShop = false;
	}
	else if (StrEqual(name, "myweapons"))
	{
		gp_bMyWeapons = false;
	}
	else if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailbreak = false;
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
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = true;
	}
	else if (StrEqual(name, "myjailshop"))
	{
		gp_bMyJailShop = true;
	}
	else if (StrEqual(name, "myweapons"))
	{
		gp_bMyWeapons = true;
	}
	else if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailbreak = true;
	}
}

// FindConVar
public void OnConfigsExecuted()
{
	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));

	g_bDeputy = FindConVar("sm_warden_deputy_enable");
	g_bDeputySet = FindConVar("sm_warden_deputy_set");
	g_bDeputyBecome = FindConVar("sm_warden_deputy_become");
	g_bWardenCountDeputy = FindConVar("sm_warden_counter_deputy");
	g_bWardenRebelDeputy = FindConVar("sm_warden_mark_rebel_deputy");
	g_bWardenCount = FindConVar("sm_warden_counter");
	g_bWardenRebel = FindConVar("sm_warden_mark_rebel");
	g_bRules = FindConVar("sm_hosties_rules_enable");
	g_bCheck = FindConVar("sm_hosties_checkplayers_enable");
	g_bMathDeputy = FindConVar("sm_warden_math_deputy");
	g_bNoBlockDeputy = FindConVar("sm_warden_noblock_deputy");
	g_bExtendDeputy = FindConVar("sm_warden_extend_deputy");
	g_bMath = FindConVar("sm_warden_math");
	g_bNoBlock = FindConVar("sm_warden_noblock");
	g_bExtend = FindConVar("sm_warden_extend");
	g_bMute = FindConVar("sm_warden_mute");
	g_bMuteDeputy = FindConVar("sm_warden_mute_deputy");
	g_bNoLR = FindConVar("sm_warden_withheld_lr_enable");
	g_bNoLRDeputy = FindConVar("sm_warden_withheld_lr_deputy");
	g_bPainter = FindConVar("sm_warden_painter");
	g_bLaser = FindConVar("sm_warden_laser");
	g_bSparks = FindConVar("sm_warden_bulletsparks");
	g_bPainterDeputy = FindConVar("sm_warden_painter_deputy");
	g_bLaserDeputy = FindConVar("sm_warden_laser_deputy");
	g_bSparksDeputy = FindConVar("sm_warden_bulletsparks_deputy");
	g_bCountdown = FindConVar("sm_warden_countdown");
	g_bCountdownDeputy = FindConVar("sm_warden_countdown_deputy");
	g_bVote = FindConVar("sm_warden_vote");
	g_bFF = FindConVar("mp_teammates_are_enemies");
	g_bRequest = FindConVar("sm_request_enable");
	g_bOpen = FindConVar("sm_warden_open_enable");
	g_bAdminFF = FindConVar("sm_warden_ff");
	g_bRandom = FindConVar("sm_warden_random");
	g_bPlayerFreeday = FindConVar("sm_warden_freeday_enable");
	g_bOpenDeputy = FindConVar("sm_warden_open_deputy");
	g_bAdminFFDeputy = FindConVar("sm_warden_ff_deputy");
	g_bRandomDeputy = FindConVar("sm_warden_random_deputy");
	g_bPlayerFreedayDeputy = FindConVar("sm_warden_freeday_deputy");
	g_bPlayerFreedayGuard = FindConVar("sm_warden_freeday_guards");
	gc_sAdminFlagBulletSparks = FindConVar("sm_warden_bulletsparks_flag");
	gc_sAdminFlagLaser = FindConVar("sm_warden_laser_flag");
	gc_sAdminFlagPainter = FindConVar("sm_warden_painter_flag");
	gc_bOrders = FindConVar("sm_warden_orders");
	gc_bOrdersDeputy = FindConVar("sm_warden_orders_deputy");
	g_bEndRound = FindConVar("sm_myjb_allow_endround");

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Menu
	gc_sCustomCommandMenu.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_OpenMenu, "opens the menu depends on players team/rank");
	}

	// Days Menu
	gc_sCustomCommandDays.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_VoteEventDays, "open a vote EventDays menu for player");
	}

	// Set Day
	gc_sCustomCommandSetDay.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_SetEventDay, "open a Set EventDays menu for Warden/Admin");
	}

	// Voting
	gc_sCustomCommandVoting.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_VotingMenu, "Allows warden & admin to opens event day voting");
	}

	Handle topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		MyAdminMenuReady(topmenu);
	}
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Open Menu on Spawn
public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (gc_bStart.BoolValue)
	{
		Command_OpenMenu(client, 0);
	}
}


public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	char EventDay[64];
	MyJailbreak_GetEventDayName(EventDay);

	if (!StrEqual(EventDay, "none", false))
	{
		g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	}
	else if (g_iCoolDown > 0) g_iCoolDown--;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Welcome/Info Message
public void OnClientPutInServer(int client)
{
	if (gc_bWelcome.BoolValue)
	{
		CreateTimer(35.0, Timer_WelcomeMessage, GetClientUserId(client));
	}
}

public void OnMapStart()
{
	g_iCoolDown = gc_iCooldownStart.IntValue +1;
}

/******************************************************************************
                   MENUS
******************************************************************************/

// Main Menu
public Action Command_OpenMenu(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (IsValidClient(client, false, true))
		{
			char menuinfo[255];
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_info_title", client);
			Menu mainmenu = new Menu(JBMenuHandler);
			mainmenu.SetTitle(menuinfo);

			if (gc_bCleanMenu.BoolValue)
			{
				mainmenu.AddItem("1", "0", ITEMDRAW_SPACER);
				mainmenu.AddItem("1", "0", ITEMDRAW_SPACER);
			}

			Call_StartForward(gF_hMenuStart);
			Call_PushCell(client);
			Call_PushCell(mainmenu);
			Call_Finish();

			if (gc_bWarden.BoolValue && gp_bMyJBWarden && warden_iswarden(client))
			{
				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_CT))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}

				if (g_bOpen != null && gp_bSmartJailDoors)
				{
					if (g_bOpen.BoolValue && SJD_IsCurrentMapConfigured())
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_opencell", client);
						mainmenu.AddItem("cellopen", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_closecell", client);
						mainmenu.AddItem("cellclose", menuinfo);
					}
				}

				if (g_bDeputy != null && g_bDeputySet != null)
				{
					if (g_bDeputy.BoolValue && g_bDeputySet.BoolValue && !warden_deputy_exist() && (GetAlivePlayersCount(CS_TEAM_CT) > 1))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_deputyset", client);
						mainmenu.AddItem("setdeputy", menuinfo);
					}
				}

				if (gc_bOrders != null)
				{
					if (gc_bOrders.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_orders", client);
						mainmenu.AddItem("orders", menuinfo);
					}
				}

				if (g_bCountdown != null)
				{
					if (g_bCountdown.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_countdown", client);
						mainmenu.AddItem("countdown", menuinfo);
					}
				}

				if (g_bWardenCount != null)
				{
					if (g_bWardenCount.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_count", client);
						mainmenu.AddItem("count", menuinfo);
					}
				}

				if (g_bPlayerFreeday != null)
				{
					if (g_bPlayerFreeday.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
						mainmenu.AddItem("playerfreeday", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerremovefreeday", client);
						mainmenu.AddItem("playerremovefreeday", menuinfo);
					}
				}

				if (g_bWardenRebel != null)
				{
					if (g_bWardenRebel.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_rebel", client);
						mainmenu.AddItem("rebel", menuinfo);
					}
				}

				if (g_bNoLR != null)
				{
					if (g_bNoLR.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_nolr", client);
						mainmenu.AddItem("nolr", menuinfo);
					}
				}

				if (g_bMath != null)
				{
					if (g_bMath.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_math", client);
						mainmenu.AddItem("math", menuinfo);
					}
				}

				if (gc_bVoting.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteday", client);
					mainmenu.AddItem("voteday", menuinfo);
				}

				if (gc_bDaysSet.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_seteventdays", client);
					mainmenu.AddItem("setdays", menuinfo);
				}

				if (g_bSparks != null)
				{
					if (g_bSparks.BoolValue && MyJB_CheckVIPFlags(client, "sm_warden_bulletsparks_flag", gc_sAdminFlagBulletSparks, "sm_warden_bulletsparks_flag"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_sparks", client);
						mainmenu.AddItem("sparks", menuinfo);
					}
				}

				if (g_bPainter != null)
				{
					if (g_bPainter.BoolValue && MyJB_CheckVIPFlags(client, "sm_warden_painter_flag", gc_sAdminFlagPainter, "sm_warden_painter_flag"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_painter", client);
						mainmenu.AddItem("painter", menuinfo);
					}
				}

				if (g_bLaser != null)
				{
					if (g_bLaser.BoolValue && MyJB_CheckVIPFlags(client, "sm_warden_laser_flag", gc_sAdminFlagLaser, "sm_warden_laser_flag"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_laser", client);
						mainmenu.AddItem("laser", menuinfo);
					}
				}

				if (g_bExtend != null)
				{
					if (g_bExtend.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_extend", client);
						mainmenu.AddItem("extend", menuinfo);
					}
				}

				if (g_bMute != null)
				{
					if (g_bMute.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_mute", client);
						mainmenu.AddItem("mute", menuinfo);
					}
				}

				if (g_bCheck != null)
				{
					if (g_bCheck.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
						mainmenu.AddItem("check", menuinfo);
					}
				}

				if (g_bAdminFF != null)
				{
					if (g_bAdminFF.BoolValue)
					{
						if (!g_bFF.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffon", client);
							mainmenu.AddItem("setff", menuinfo);
						}
						else
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffoff", client);
							mainmenu.AddItem("setff", menuinfo);
						}
					}
				}

				if (g_bNoBlock != null)
				{
					if (g_bNoBlock.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_noblock", client);
						mainmenu.AddItem("noblock", menuinfo);
					}
				}

				if (g_bRandom != null)
				{
					if (g_bRandom.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_randomdead", client);
						mainmenu.AddItem("kill", menuinfo);
					}
				}

				if (g_bDeputy != null && g_bDeputySet != null)
				{
					if (g_bDeputy.BoolValue && g_bDeputySet.BoolValue && warden_deputy_exist())
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_removedeputy", client);
						mainmenu.AddItem("undeputy", menuinfo);
					}
				}

				Format(menuinfo, sizeof(menuinfo), "%T", "menu_unwarden", client);
				mainmenu.AddItem("unwarden", menuinfo);
			}// HERE END THE WARDEN MENU
			else if (gp_bMyJBWarden && warden_deputy_isdeputy(client) && gc_bDeputy.BoolValue && warden_isenabled()) // HERE STARTS THE DEPUTY MENU)
			{
				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_CT))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}

				if (g_bOpen != null && gp_bSmartJailDoors)
				{
					if (g_bOpen.BoolValue && g_bOpenDeputy.BoolValue && SJD_IsCurrentMapConfigured())
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_opencell", client);
						mainmenu.AddItem("cellopen", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_closecell", client);
						mainmenu.AddItem("cellclose", menuinfo);
					}
				}

				if (gc_bOrdersDeputy != null)
				{
					if (gc_bOrdersDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_orders", client);
						mainmenu.AddItem("orders", menuinfo);
					}
				}

				if (g_bCountdown != null)
				{
					if (g_bCountdown.BoolValue && g_bCountdownDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_countdown", client);
						mainmenu.AddItem("countdown", menuinfo);
					}
				}

				if (g_bWardenCount != null)
				{
					if (g_bWardenCount.BoolValue && g_bWardenCountDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_count", client);
						mainmenu.AddItem("count", menuinfo);
					}
				}

				if (g_bPlayerFreeday != null)
				{
					if (g_bPlayerFreeday.BoolValue && g_bPlayerFreedayDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
						mainmenu.AddItem("playerfreeday", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerremovefreeday", client);
						mainmenu.AddItem("playerremovefreeday", menuinfo);
					}
				}

				if (g_bWardenRebel != null)
				{
					if (g_bWardenRebel.BoolValue && g_bWardenRebelDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_rebel", client);
						mainmenu.AddItem("rebel", menuinfo);
					}
				}

				if (g_bNoLR != null)
				{
					if (g_bNoLR.BoolValue && g_bNoLRDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_nolr", client);
						mainmenu.AddItem("nolr", menuinfo);
					}
				}

				if (g_bMath != null)
				{
					if (g_bMath.BoolValue && g_bMathDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_math", client);
						mainmenu.AddItem("math", menuinfo);
					}
				}

				if (g_bSparks != null)
				{
					if (g_bSparks.BoolValue && g_bSparksDeputy.BoolValue && MyJB_CheckVIPFlags(client, "sm_warden_bulletsparks_flag", gc_sAdminFlagBulletSparks, "sm_warden_bulletsparks_flag"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_sparks", client);
						mainmenu.AddItem("sparks", menuinfo);
					}
				}

				if (g_bPainter != null)
				{
					if (g_bPainter.BoolValue && g_bPainterDeputy.BoolValue && MyJB_CheckVIPFlags(client, "sm_warden_painter_flag", gc_sAdminFlagPainter, "sm_warden_painter_flag"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_painter", client);
						mainmenu.AddItem("painter", menuinfo);
					}
				}

				if (g_bLaser != null)
				{
					if (g_bLaser.BoolValue && g_bLaserDeputy.BoolValue && MyJB_CheckVIPFlags(client, "sm_warden_laser_flag", gc_sAdminFlagLaser, "sm_warden_laser_flag"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_laser", client);
						mainmenu.AddItem("laser", menuinfo);
					}
				}

				if (g_bExtend != null)
				{
					if (g_bExtend.BoolValue && g_bExtendDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_extend", client);
						mainmenu.AddItem("extend", menuinfo);
					}
				}

				if (g_bMute != null)
				{
					if (g_bMute.BoolValue && g_bMuteDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_mute", client);
						mainmenu.AddItem("mute", menuinfo);
					}
				}

				if (g_bCheck != null)
				{
					if (g_bCheck.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
						mainmenu.AddItem("check", menuinfo);
					}
				}

				if (g_bAdminFF != null)
				{
					if (g_bAdminFF.BoolValue && g_bAdminFFDeputy.BoolValue)
					{
						if (!g_bFF.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffon", client);
							mainmenu.AddItem("setff", menuinfo);
						}
						else
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffoff", client);
							mainmenu.AddItem("setff", menuinfo);
						}
					}
				}

				if (g_bNoBlock != null)
				{
					if (g_bNoBlock.BoolValue && g_bNoBlockDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_noblock", client);
						mainmenu.AddItem("noblock", menuinfo);
					}
				}

				if (g_bRandom != null)
				{
					if (g_bRandom.BoolValue && g_bRandomDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_randomdead", client);
						mainmenu.AddItem("kill", menuinfo);
					}
				}

				Format(menuinfo, sizeof(menuinfo), "%T", "menu_undeputy", client);
				mainmenu.AddItem("undeputy", menuinfo);
			}// HERE END THE WARDEN MENU
			else if (GetClientTeam(client) == CS_TEAM_CT && gc_bCTerror.BoolValue) // HERE STARTS THE CT MENU
			{

				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_CT))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}

				if (gp_bMyJBWarden && warden_isenabled())
				{
					if (!warden_exist() && IsPlayerAlive(client))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_getwarden", client);
						mainmenu.AddItem("getwarden", menuinfo);
					}

					if (warden_exist() && g_bDeputy.BoolValue && g_bDeputyBecome.BoolValue && !warden_deputy_exist())
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_deputybecome", client);
						mainmenu.AddItem("becomedeputy", menuinfo);
					}
				}

				if (g_bPlayerFreeday != null)
				{
					if (g_bPlayerFreeday.BoolValue && g_bPlayerFreedayGuard.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
						mainmenu.AddItem("playerfreeday", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerremovefreeday", client);
						mainmenu.AddItem("playerremovefreeday", menuinfo);
					}
				}

				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);

				if (StrEqual(EventDay, "none", false)) // is an other event running or set?
				{
					if (gc_bDaysVote.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteeventdays", client);
						mainmenu.AddItem("votedays", menuinfo);
					}
				}

				if (g_bCheck != null)
				{
					if (g_bCheck.BoolValue && IsPlayerAlive(client))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
						mainmenu.AddItem("check", menuinfo);
					}
				}

				if (gc_bTeam.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joint", client);
					mainmenu.AddItem("ChangeTeamT", menuinfo);

					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinspec", client);
					mainmenu.AddItem("ChangeTeamSpec", menuinfo);
				}
			}// HERE END THE CT MENU
			else if (GetClientTeam(client) == CS_TEAM_T && gc_bTerror.BoolValue) // HERE STARTS THE T MENU
			{
				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_T))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}

				if (gp_bMyJailShop)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_jailshop", client);
					mainmenu.AddItem("jailshop", menuinfo);
				}

				if (CommandExists("sm_gangs"))
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_gangs", client);
					mainmenu.AddItem("gangs", menuinfo);
				}

				if (g_bRequest != null)
				{
					if (g_bRequest.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_request", client);
						mainmenu.AddItem("request", menuinfo);
					}
				}

				if (gp_bMyJBWarden)
				{
					if (warden_exist())
					{
						if (g_bVote.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_votewarden", client);
							mainmenu.AddItem("votewarden", menuinfo);
						}
					}
				}

				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);

				if (StrEqual(EventDay, "none", false)) // is an other event running or set?
				{
					if (gc_bDaysVote.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteeventdays", client);
						mainmenu.AddItem("votedays", menuinfo);
					}
				}

				if (gc_bTeam.BoolValue)
				{
					if (CommandExists("sm_guard"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guardct", client);
						mainmenu.AddItem("guard", menuinfo);
					}
					else
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinct", client);
						mainmenu.AddItem("ChangeTeamCT", menuinfo);
					}

					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinspec", client);
					mainmenu.AddItem("ChangeTeamSpec", menuinfo);
				}
			}
			else if (GetClientTeam(client) == CS_TEAM_SPECTATOR) // HERE STARTS THE SPEC MENU
			{
				if (gc_bTeam.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joint", client);
					mainmenu.AddItem("ChangeTeamT", menuinfo);

					if (CommandExists("sm_guard"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guardct", client);
						mainmenu.AddItem("guard", menuinfo);
					}
					else
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinct", client);
						mainmenu.AddItem("ChangeTeamCT", menuinfo);
					}
				}
			}

			Call_StartForward(gF_hMenuEnd);
			Call_PushCell(client);
			Call_PushCell(mainmenu);
			Call_Finish();

			if (g_bRules != null)
			{
				if (g_bRules.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_rules", client);
					mainmenu.AddItem("rules", menuinfo);
				}
			}

			if (MyJB_CheckVIPFlags(client, "sm_menu_flag", gc_sAdminFlag, "sm_menu_flag"))
			{
				/* ADMIN PLACEHOLDER
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
				mainmenu.AddItem("PLACEHOLDER", menuinfo);
				*/
				if (gc_iAdminMenu.IntValue == 1 || gc_iAdminMenu.IntValue == 3)
				{
					if (!MyJailbreak_IsEventDayPlanned() && !MyJailbreak_IsEventDayRunning()) // is an other event running or set?
					{
						if ((gp_bWarden || gp_bMyJBWarden) && !warden_iswarden(client))
						{
							if (gc_bVoting.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteday", client);
								mainmenu.AddItem("voteday", menuinfo);
							}

							if (gc_bDaysSet.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_seteventdays", client);
								mainmenu.AddItem("setdays", menuinfo);
							}
						}
					}
					if (gp_bMyJBWarden)
					{
						if (warden_isenabled())
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_setwarden", client);
							mainmenu.AddItem("setwarden", menuinfo);
							if (warden_exist())
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_removewarden", client);
								mainmenu.AddItem("removewarden", menuinfo);
							}

							if (warden_deputy_exist())
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_removedeputy", client);
								mainmenu.AddItem("undeputy", menuinfo);
							}
						}
					}
					if (LibraryExists("myratio"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_removequeue", client);
						mainmenu.AddItem("removequeue", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_clearqueue", client);
						mainmenu.AddItem("clearqueue", menuinfo);
					}

					if (g_bEndRound != null)
					{
						if (g_bEndRound.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_endround", client);
							mainmenu.AddItem("endround", menuinfo);
						}
					}
				}
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_admin", client);
				mainmenu.AddItem("admin", menuinfo);
			}

			mainmenu.ExitButton = true;
			mainmenu.Display(client, MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}

// Main Handle
public int JBMenuHandler(Menu mainmenu, MenuAction action, int client, int selection)
{
	Call_StartForward(gF_hMenuHandler);
	Call_PushCell(mainmenu);
	Call_PushCell(action);
	Call_PushCell(client);
	Call_PushCell(selection);
	Call_Finish();

	if (action == MenuAction_Select)
	{
		char info[32];
		mainmenu.GetItem(selection, info, sizeof(info));

		if (strcmp(info, "ChangeTeamT") == 0)
		{
			FakeClientCommand(client, "sm_prisoner");
		}

		if (strcmp(info, "ChangeTeamCT") == 0)
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_CT);
		}

		if (strcmp(info, "ChangeTeamSpec") == 0)
		{
			FakeClientCommand(client, "sm_spectator");
		}
		else if (strcmp(info, "endround") == 0)
		{
			FakeClientCommand(client, "sm_endround");
		}
		else if (strcmp(info, "removequeue") == 0)
		{
			FakeClientCommand(client, "sm_removequeue");
		}
		else if (strcmp(info, "clearqueue") == 0)
		{
			FakeClientCommand(client, "sm_clearqueue");
		}
		else if (strcmp(info, "request") == 0)
		{
			FakeClientCommand(client, "sm_request");
		}
		else if (strcmp(info, "lastR") == 0)
		{
			FakeClientCommand(client, "sm_lr");
		}
		else if (strcmp(info, "nolr") == 0)
		{
			FakeClientCommand(client, "sm_nolastrequest");
		}
		else if (strcmp(info, "setwarden") == 0)
		{
			FakeClientCommand(client, "sm_sw");
		}
		else if (strcmp(info, "gangs") == 0)
		{
			FakeClientCommand(client, "sm_gangs");
		}
		else if (strcmp(info, "rules") == 0)
		{
			FakeClientCommand(client, "sm_rules");
		}
		else if (strcmp(info, "jailshop") == 0)
		{
			FakeClientCommand(client, "sm_jailshop");
		}
		else if (strcmp(info, "guns") == 0)
		{
			FakeClientCommand(client, "sm_weapon");
		}
		else if (strcmp(info, "playerfreeday") == 0)
		{
			FakeClientCommand(client, "sm_givefreeday");
		}
		else if (strcmp(info, "playerremovefreeday") == 0)
		{
			FakeClientCommand(client, "sm_removefreeday");
		}
		else if (strcmp(info, "votedays") == 0)
		{
			FakeClientCommand(client, "sm_eventdays");
		}
		else if (strcmp(info, "voteday") == 0)
		{
			FakeClientCommand(client, "sm_voteday");
		}
		else if (strcmp(info, "setdays") == 0)
		{
			FakeClientCommand(client, "sm_setday");
		}
		else if (strcmp(info, "orders") == 0)
		{
			FakeClientCommand(client, "sm_order");
		}
		else if (strcmp(info, "setdeputy") == 0)
		{
			FakeClientCommand(client, "sm_deputy");
		}
		else if (strcmp(info, "count") == 0)
		{
			FakeClientCommand(client, "sm_count");
		}
		else if (strcmp(info, "laser") == 0)
		{
			FakeClientCommand(client, "sm_laser");
		}
		else if (strcmp(info, "painter") == 0)
		{
			FakeClientCommand(client, "sm_painter");
		}
		else if (strcmp(info, "extend") == 0)
		{
			FakeClientCommand(client, "sm_extend");
		}
		else if (strcmp(info, "admin") == 0)
		{
			FakeClientCommand(client, "sm_admin");
		}
		else if (strcmp(info, "countdown") == 0)
		{
			FakeClientCommand(client, "sm_cdmenu");
		}
		else if (strcmp(info, "mute") == 0)
		{
			FakeClientCommand(client, "sm_wmute");
		}
		else if (strcmp(info, "rebel") == 0)
		{
			FakeClientCommand(client, "sm_markrebel");
		}
		else if (strcmp(info, "kill") == 0)
		{
			FakeClientCommand(client, "sm_killrandom");
		}
		else if (strcmp(info, "check") == 0)
		{
			FakeClientCommand(client, "sm_checkplayers");
		}
		else if (strcmp(info, "guard") == 0)
		{
			FakeClientCommand(client, "sm_guard");
		}
		else if (strcmp(info, "getwarden") == 0)
		{
			FakeClientCommand(client, "sm_warden");
			Command_OpenMenu(client, 0);
		}
		else if (strcmp(info, "unwarden") == 0)
		{
			FakeClientCommand(client, "sm_unwarden");
			Command_OpenMenu(client, 0);
		}
		else if (strcmp(info, "undeputy") == 0)
		{
			FakeClientCommand(client, "sm_undeputy");
			Command_OpenMenu(client, 0);
		}
		else if (strcmp(info, "removewarden") == 0)
		{
			FakeClientCommand(client, "sm_removewarden");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "sparks") == 0)
		{
			FakeClientCommand(client, "sm_sparks");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "becomedeputy") == 0)
		{
			FakeClientCommand(client, "sm_deputy");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setff") == 0)
		{
			FakeClientCommand(client, "sm_setff");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "math") == 0)
		{
			FakeClientCommand(client, "sm_math");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "cellclose") == 0)
		{
			FakeClientCommand(client, "sm_close");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "cellopen") == 0)
		{
			FakeClientCommand(client, "sm_open");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "noblock") == 0)
		{
			FakeClientCommand(client, "sm_noblock");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votewarden") == 0)
		{
			FakeClientCommand(client, "sm_vetowarden");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		} 
	}
	else if (action == MenuAction_End)
	{
		delete mainmenu;
	}
}

// Event Day Voting Menu
public Action Command_VoteEventDays(int client, int args)
{
	if (gc_bDaysVote.BoolValue)
	{
		char menuinfo[255];
		Menu menu = new Menu(VoteEventMenuHandler);

		Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlevote", client);
		menu.SetTitle(menuinfo);

		if (gc_bCleanMenu.BoolValue)
		{
			menu.AddItem("1", "0", ITEMDRAW_SPACER);
			menu.AddItem("1", "0", ITEMDRAW_SPACER);
		}

		ArrayList EventDaysArray = new ArrayList(32);
		MyJailbreak_GetEventDays(EventDaysArray);

		char sBuffer[32], sBuffer2[32];

		for (int i = 0; i < EventDaysArray.Length; i++)
		{
			EventDaysArray.GetString(i, sBuffer, sizeof(sBuffer));

			Format(sBuffer2, sizeof(sBuffer2), "sm_%s_vote", sBuffer);
			ConVar cBuffer = FindConVar(sBuffer2);

			if (cBuffer.BoolValue)
			{
				Format(sBuffer2, sizeof(sBuffer2), "menu_%s", sBuffer);
				Format(menuinfo, sizeof(menuinfo), "%t", sBuffer2, LANG_SERVER);
				menu.AddItem(sBuffer, menuinfo);
			}
		}
		menu.ExitButton = true;
		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

// Event Day Voting Handler
public int VoteEventMenuHandler(Menu daysmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		daysmenu.GetItem(selection, info, sizeof(info));

		Format(info, sizeof(info), "sm_%s", info);

		FakeClientCommand(client, info);
		if (!gc_bClose.BoolValue)
		{
			Command_OpenMenu(client, 0);
		}
	}
	else if (action == MenuAction_Cancel) 
	{
		if (selection == MenuCancel_ExitBack) 
		{
			Command_OpenMenu(client, 0);
		}
	}
	else if (action == MenuAction_End)
	{
		delete daysmenu;
	}
}

// Event Days Set Menu
public Action Command_SetEventDay(int client, int args)
{
	if (MyJB_CheckVIPFlags(client, "sm_menu_flag", gc_sAdminFlag, "sm_menu_flag"))
	{
		Command_SetAdminEventDay(client);
	}
	else if ((gp_bWarden || gp_bMyJBWarden) && warden_iswarden(client))
	{
		Command_SetWardenEventDay(client);
	}
}
// Wardens Event Days Set  Menu
void Command_SetWardenEventDay(int client)
{
	if (gc_bDaysSet.BoolValue)
	{
			Menu menu = new Menu(SetEventMenuHandler);
			char menuinfo[255];

			Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlestart", client);
			menu.SetTitle(menuinfo);

			if (gc_bCleanMenu.BoolValue)
			{
				menu.AddItem("1", "0", ITEMDRAW_SPACER);
				menu.AddItem("1", "0", ITEMDRAW_SPACER);
			}

			ArrayList EventDaysArray = new ArrayList(32);
			MyJailbreak_GetEventDays(EventDaysArray);

			char sBuffer[32], sBuffer2[32];

			for (int i = 0; i < EventDaysArray.Length; i++)
			{
				EventDaysArray.GetString(i, sBuffer, sizeof(sBuffer));

				Format(sBuffer2, sizeof(sBuffer2), "sm_%s_warden", sBuffer);
				ConVar cBuffer = FindConVar(sBuffer2);

				if (cBuffer.BoolValue)
				{
					Format(sBuffer2, sizeof(sBuffer2), "menu_%s", sBuffer);
					Format(menuinfo, sizeof(menuinfo), "%t", sBuffer2, LANG_SERVER);
					menu.AddItem(sBuffer, menuinfo);
				}
			}

			menu.ExitButton = true;
			menu.ExitBackButton = true;
			menu.Display(client, MENU_TIME_FOREVER);
	}
}

// Admins Event Days Set Menu
void Command_SetAdminEventDay(int client)
{
	if (gc_bDaysSet.BoolValue)
	{
			Menu menu = new Menu(SetEventMenuHandler);

			char menuinfo[255];

			Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlestart", client);
			menu.SetTitle(menuinfo);

			if (gc_bCleanMenu.BoolValue)
			{
				menu.AddItem("1", "0", ITEMDRAW_SPACER);
				menu.AddItem("1", "0", ITEMDRAW_SPACER);
			}

			ArrayList EventDaysArray = new ArrayList(32);
			MyJailbreak_GetEventDays(EventDaysArray);

			char sBuffer[32], sBuffer2[32];

			for (int i = 0; i < EventDaysArray.Length; i++)
			{
				EventDaysArray.GetString(i, sBuffer, sizeof(sBuffer));

				Format(sBuffer2, sizeof(sBuffer2), "sm_%s_admin", sBuffer);
				ConVar cBuffer = FindConVar(sBuffer2);

				if (cBuffer.BoolValue)
				{
					Format(sBuffer2, sizeof(sBuffer2), "menu_%s", sBuffer);
					Format(menuinfo, sizeof(menuinfo), "%t", sBuffer2, LANG_SERVER);
					menu.AddItem(sBuffer, menuinfo);
				}
			}

			menu.ExitButton = true;
			menu.ExitBackButton = true;
			menu.Display(client, MENU_TIME_FOREVER);
	}
}

// Event Days Set Handler
public int SetEventMenuHandler(Menu daysmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];

		daysmenu.GetItem(selection, info, sizeof(info));

		Format(info, sizeof(info), "sm_set%s", info);

		FakeClientCommand(client, info);
		if (!gc_bClose.BoolValue)
		{
			Command_OpenMenu(client, 0);
		}
	}
	else if (action == MenuAction_Cancel) 
	{
		if (selection == MenuCancel_ExitBack) 
		{
			Command_OpenMenu(client, 0);
		}
	}
	else if (action == MenuAction_End)
	{
		delete daysmenu;
	}
}

public Action Command_VotingMenu(int client, int args)
{
	if (gc_bPlugin.BoolValue && gc_bVoting.BoolValue)
	{
		if (((gp_bWarden || gp_bMyJBWarden) && warden_iswarden(client) && gc_bSetW.BoolValue) || (MyJB_CheckVIPFlags(client, "sm_menu_flag", gc_sAdminFlag, "sm_menu_flag") && gc_bSetA.BoolValue) || client == 0)
		{
			if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0))
			{
				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);

				if (StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						if (IsVoteInProgress())
						{
							return Plugin_Handled;
						}

						char menuinfo[64];
						Menu menu = new Menu(VotingMenuHandler);
						menu.VoteResultCallback = VotingResults;
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voting", LANG_SERVER);
						menu.SetTitle(menuinfo);

						if (gc_bCleanMenu.BoolValue)
						{
							menu.AddItem("1", "0", ITEMDRAW_SPACER);
							menu.AddItem("1", "0", ITEMDRAW_SPACER);
						}

						if (gc_bVoteNoMenu.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_noevent", LANG_SERVER);
							menu.AddItem("No Event", menuinfo);
						}

						ArrayList EventDaysArray = new ArrayList(32);
						MyJailbreak_GetEventDays(EventDaysArray);

						if (gc_bShuffle.BoolValue)
						{
							for (int i = 0; i < EventDaysArray.Length; i++)
							{
								EventDaysArray.SwapAt(i, GetRandomInt(0, EventDaysArray.Length-1));
							}
						}

						char sBuffer[32], sBuffer2[32];

						for (int i = 0; i < EventDaysArray.Length; i++)
						{
							EventDaysArray.GetString(i, sBuffer, sizeof(sBuffer));

							Format(sBuffer2, sizeof(sBuffer2), "sm_%s_vote", sBuffer);
							ConVar cBuffer = FindConVar(sBuffer2);

							if (cBuffer.BoolValue)
							{
								Format(sBuffer2, sizeof(sBuffer2), "menu_%s", sBuffer);
								Format(menuinfo, sizeof(menuinfo), "%t", sBuffer2, LANG_SERVER);
								menu.AddItem(sBuffer, menuinfo);
							}
						}

						menu.ExitButton = true;
						menu.DisplayVoteToAll(25);

						g_iCoolDown = gc_iCooldownDay.IntValue + 1;
					}
					else CReplyToCommand(client, "%s %t", g_sPrefix, "menu_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%s %t", g_sPrefix, "menu_progress", EventDay);
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "menu_minplayer");
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "menu_disabled");

	return Plugin_Handled;
}

public int VotingMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		delete menu;
	}
}

public int VotingResults(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	char EventDay[64];
	MyJailbreak_GetEventDayName(EventDay);

	if (StrEqual(EventDay, "none", false))
	{
		/* See if there were multiple winners */
		int winner = 0;
		if (num_items > 1 && (item_info[0][VOTEINFO_ITEM_VOTES] == item_info[1][VOTEINFO_ITEM_VOTES]))
		{
			winner = GetRandomInt(0, 1);
			CPrintToChatAll("%s %t", g_sPrefix, "menu_votingdraw");
		}
		char event[64];
		menu.GetItem(item_info[winner][VOTEINFO_ITEM_INDEX], event, sizeof(event));
		CPrintToChatAll("%s %t", g_sPrefix, "menu_votingwon", event, num_clients, num_items);

		if (!StrEqual("No Event",event)) ServerCommand("sm_set%s", event);
	}
	else CPrintToChatAll("%s %t", g_sPrefix, "menu_votingcancel", EventDay);
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_WelcomeMessage(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (gc_bWelcome.BoolValue && IsValidClient(client, false, true))
	{
		CPrintToChat(client, "%s %t", g_sPrefix, "menu_info");
	}
}

bool MyJB_CheckVIPFlags(int client, const char[] command, ConVar flags, char[] feature)
{
	if (gp_bMyJailbreak)
		return MyJailbreak_CheckVIPFlags(client, command, flags, feature);

	char sBuffer[32];
	flags.GetString(sBuffer, sizeof(sBuffer));

	if (strlen(sBuffer) == 0) // ???
		return true;

	int iFlags = ReadFlagString(sBuffer);

	return CheckCommandAccess(client, command, iFlags);
}