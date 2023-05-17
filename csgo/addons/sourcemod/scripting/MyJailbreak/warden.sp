/*
 * MyJailbreak - Warden Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Hexer10, NomisCZ
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
#include <smartdm>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <basecomm>
#include <sourcecomms>
#include <myjailbreak>
#include <hosties>
#include <lastrequest>
#include <smartjaildoors>
#include <voiceannounce_ex>
#include <chat-processor>
#include <scp>
#include <CustomPlayerSkins>
#include <franug_deadgames>
#define REQUIRE_PLUGIN

#include <mystocks>

// Defines
#define MAX_BUTTONS 25
#define WARDEN_SPAM 5

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bVote;
ConVar gc_bStayWarden;
ConVar gc_bBecomeWarden;
ConVar gc_bChooseRandom;
ConVar gc_iLimitWarden;
ConVar gc_iCoolDownRemove;
ConVar gc_iCoolDownLimit;
ConVar gc_iCoolDownMinPlayer;
ConVar gc_bSounds;
ConVar gc_bOverlays;
ConVar gc_sOverlayPath;
ConVar gc_sWarden;
ConVar gc_sYouWarden;
ConVar gc_sUnWarden;
ConVar gc_bRemoveLR;
ConVar gc_sModelPathWarden;
ConVar gc_bModel;
ConVar gc_bBetterNotes;
ConVar gc_sCustomCommandWarden;
ConVar gc_sCustomCommandUnWarden;
ConVar gc_sCustomCommandVetoWarden;
ConVar gc_sCustomCommandSetWarden;
ConVar gc_sCustomCommandRemoveWarden;
ConVar gc_fRandomTimer;
ConVar gc_fCMDCooldown;

ConVar gc_bChoiceWarden;
ConVar gc_bChoiceTeam;
ConVar gc_iApplicationTime;
ConVar gc_iChoiceTime;
ConVar gc_iListType;

// 3rd party Convars
ConVar g_bMenuClose;

// Booleans
bool g_bEnabled = true;
bool g_bIsLateLoad = false;
bool g_bIsLR = false;
bool gp_bMyJailBreak = false;
bool gp_bHosties = false;
bool gp_bLastRequest = false;
bool gp_bSmartJailDoors = false;
bool gp_bChatProcessor = false;
bool gp_bSimpleChatProcessor = false;
bool gp_bBasecomm = false;
bool gp_bSourceComms = false;
bool gp_bCustomPlayerSkins = false;
bool gp_bDeadGames = false;

// Integers
int g_iApplicationTime= 0;
int g_iCMDCoolDown[MAXPLAYERS+1] = 0;
int g_iCMDCoolDownSpam[MAXPLAYERS+1] = 0;
int g_iWarden = -1;
int g_iLastWarden = -1;
int g_iTempWarden[MAXPLAYERS+1] = -1;
int g_iVoteCount;
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iSmokeSprite;
int g_iLastButtons[MAXPLAYERS+1];
int g_iColors[8][4] = 
{
	{255, 255, 255, 255}, // white
	{255, 0, 0, 255}, // red
	{20, 255, 20, 255}, // green
	{0, 65, 255, 255}, // blue
	{255, 255, 0, 255}, // yellow
	{0, 255, 255, 255}, // cyan
	{255, 0, 255, 255}, // magenta
	{255, 80, 0, 255}  // orange
};

// Handles
Handle gF_OnWardenCreate;
Handle gF_OnWardenRemoved;
Handle gF_OnWardenCreated;
Handle gF_OnWardenCreatedByUser;
Handle gF_OnWardenCreatedByAdmin;
Handle gF_OnWardenDisconnected;
Handle gF_OnWardenDeath;
Handle gF_OnWardenRemovedBySelf;
Handle gF_OnWardenRemovedByAdmin;
Handle g_hTimerRandom;
Handle g_hCooldown;
Handle g_hLimit;
ArrayList g_aApplicationQueue;

// Strings
char g_sPrefix[64];
char g_sHasVoted[1500];
char g_sModelPathPrevious[256];
char g_sModelPathWarden[256];
char g_sOverlayPath[256];
char g_sUnWarden[256];
char g_sWarden[256];
char g_sYouWarden[256];
char g_sMyJBLogFile[PLATFORM_MAX_PATH];
char g_sRestrictedSound[32] = "buttons/button11.wav";

// Modules
#include "MyJailbreak/Modules/Warden/celldoors.sp"
#include "MyJailbreak/Modules/Warden/deputy.sp"
#include "MyJailbreak/Modules/Warden/mute.sp"
#include "MyJailbreak/Modules/Warden/bulletsparks.sp"
#include "MyJailbreak/Modules/Warden/countdown.sp"
#include "MyJailbreak/Modules/Warden/math.sp"
#include "MyJailbreak/Modules/Warden/disarm.sp"
#include "MyJailbreak/Modules/Warden/noblock.sp"
#include "MyJailbreak/Modules/Warden/extendtime.sp"
#include "MyJailbreak/Modules/Warden/friendlyfire.sp"
#include "MyJailbreak/Modules/Warden/reminder.sp"
#include "MyJailbreak/Modules/Warden/randomkill.sp"
#include "MyJailbreak/Modules/Warden/handcuffs.sp"
#include "MyJailbreak/Modules/Warden/backstab.sp"
#include "MyJailbreak/Modules/Warden/gundrop.sp"
#include "MyJailbreak/Modules/Warden/marker.sp"
#include "MyJailbreak/Modules/Warden/color.sp"
#include "MyJailbreak/Modules/Warden/laser.sp"
#include "MyJailbreak/Modules/Warden/painter.sp"
#include "MyJailbreak/Modules/Warden/rebel.sp"
#include "MyJailbreak/Modules/Warden/counter.sp"
#include "MyJailbreak/Modules/Warden/shootguns.sp"
#include "MyJailbreak/Modules/Warden/orders.sp"
#include "MyJailbreak/Modules/Warden/freedays.sp"
#include "MyJailbreak/Modules/Warden/withheldLR.sp"
#include "MyJailbreak/Modules/Warden/glow.sp"

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Warden",
	author = "shanapu",
	description = "Jailbreak Warden script",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");

	// Client commands
	RegConsoleCmd("sm_warden", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_unwarden", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_vetowarden", Command_VoteWarden, "Allows the player to vote to retire Warden");

	// Admin commands
	RegAdminCmd("sm_setwarden", AdminCommand_SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_removewarden", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);

	// AutoExecConfig
	AutoExecConfig_SetFile("Warden", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_warden_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_warden_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_warden_prefix", "[{green}MyJB.Warden{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandWarden = AutoExecConfig_CreateConVar("sm_warden_cmds_become", "w, simon", "Set your custom chat commands for become warden(!warden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandUnWarden = AutoExecConfig_CreateConVar("sm_warden_cmds_retire", "uw, unsimon", "Set your custom chat commands for retire from warden(!unwarden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandVetoWarden = AutoExecConfig_CreateConVar("sm_warden_cmds_veto", "vw, votewarden", "Set your custom chat commands for vote against warden(!vetowarden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSetWarden = AutoExecConfig_CreateConVar("sm_warden_cmds_set", "sw, newwarden", "Set your custom chat commands for admins to set a new warden(!setwarden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandRemoveWarden = AutoExecConfig_CreateConVar("sm_warden_cmds_remove", "rw, firewarden, fw", "Set your custom chat commands for admins to remove a warden(!removewarden (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_bBecomeWarden = AutoExecConfig_CreateConVar("sm_warden_become", "1", "0 - disabled, 1 - enable !w / !warden - player can choose to be warden. If disabled you should need sm_warden_choose_random 1", _, true, 0.0, true, 1.0);
	gc_bChooseRandom = AutoExecConfig_CreateConVar("sm_warden_choose_random", "0", "0 - disabled, 1 - enable pick random warden if there is still no warden after sm_warden_choose_time", _, true, 0.0, true, 1.0);
	gc_fRandomTimer = AutoExecConfig_CreateConVar("sm_warden_choose_time", "45.0", "Time in seconds a random warden will picked when no warden was set. need sm_warden_choose_random 1", _, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_warden_vote", "1", "0 - disabled, 1 - enable player vote against warden", _, true, 0.0, true, 1.0);
	gc_iLimitWarden = AutoExecConfig_CreateConVar("sm_warden_limit", "5", "0 - disabled, rounds in a row a player can be warden", _, true, 0.0);
	gc_iCoolDownMinPlayer = AutoExecConfig_CreateConVar("sm_warden_limit_minplayer", "3", "How many CT must be online before sm_warden_limit is active", _, true, 1.0);
	gc_iCoolDownLimit = AutoExecConfig_CreateConVar("sm_warden_cooldown_limit", "3", "0 - disabled, rounds player can't become warden after he reached the warden limit (sm_warden_limit)", _, true, 0.0);
	gc_iCoolDownRemove = AutoExecConfig_CreateConVar("sm_warden_cooldown_remove", "3", "0 - disabled, rounds player can't become warden after he was vote out or removed by admin", _, true, 0.0);
	gc_bStayWarden = AutoExecConfig_CreateConVar("sm_warden_stay", "1", "0 - disabled, 1 - enable warden stay after round end", _, true, 0.0, true, 1.0);
	gc_bRemoveLR = AutoExecConfig_CreateConVar("sm_warden_remove_lr", "0", "0 - disabled, 1 - enable warden will be removed on last request", _, true, 0.0, true, 1.0);
	gc_fCMDCooldown = AutoExecConfig_CreateConVar("sm_warden_cooldown_roundstart", "15.0", "Time in seconds a the warden of last round must wait until become warden again, to give other player chance to be warden (need sm_warden_stay '0')", _, true, 0.0);
	gc_bBetterNotes = AutoExecConfig_CreateConVar("sm_warden_better_notifications", "1", "0 - disabled, 1 - Will use hint and center text", _, true, 0.0, true, 1.0);
	gc_bModel = AutoExecConfig_CreateConVar("sm_warden_model", "1", "0 - disabled, 1 - enable warden model", 0, true, 0.0, true, 1.0);
	gc_sModelPathWarden = AutoExecConfig_CreateConVar("sm_warden_model_path", "models/player/custom_player/legacy/security/security.mdl", "Path to the model for warden.");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_warden_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_warden", "music/MyJailbreak/warden.mp3", "Path to the soundfile which should be played to all player for new warden.");
	gc_sYouWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_youwarden", "music/MyJailbreak/youwarden.mp3", "Path to the soundfile which should be played for the new warden.");
	gc_sUnWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_unwarden", "music/MyJailbreak/unwarden.mp3", "Path to the soundfile which should be played when there is no warden anymore.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_warden_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayPath = AutoExecConfig_CreateConVar("sm_warden_overlays_warden", "overlays/MyJailbreak/warden", "Path to the warden Overlay DONT TYPE .vmt or .vft");

	gc_bChoiceWarden = AutoExecConfig_CreateConVar("sm_warden_choice", "0", "0 - disabled, 1 - enable player choose their warden - ignores cooldowns", _, true, 0.0, true, 1.0);
	gc_bChoiceTeam = AutoExecConfig_CreateConVar("sm_warden_choice_team", "1", "0 - only Prisoner, 1 - Prisoner & guards can choose their warden", _, true, 0.0, true, 1.0);
	gc_iApplicationTime = AutoExecConfig_CreateConVar("sm_warden_choice_application_time", "22", "How many seconds after roundstart guards can applicate for warden", _, true, 1.0);
	gc_iChoiceTime = AutoExecConfig_CreateConVar("sm_warden_choice_vote_time", "12", "How many seconds player can vote their warden", _, true, 1.0);
	gc_iListType = AutoExecConfig_CreateConVar("sm_warden_choice_list", "1", "0 - remove all applicans after vote, 1 - remove just the voted warden after vote, 2 - players stay on applicans list until !uw", _, true, 0.0, true, 2.0);

	// Warden module
	Deputy_OnPluginStart();
	Mute_OnPluginStart();
	Disarm_OnPluginStart();
	BulletSparks_OnPluginStart();
	Countdown_OnPluginStart();
	Math_OnPluginStart();
	NoBlock_OnPluginStart();
	CellDoors_OnPluginStart();
	ExtendTime_OnPluginStart();
	FriendlyFire_OnPluginStart();
	Reminder_OnPluginStart();
	RandomKill_OnPluginStart();
	HandCuffs_OnPluginStart();
	BackStab_OnPluginStart();
	Marker_OnPluginStart();
	GunDropPrevention_OnPluginStart();
	Color_OnPluginStart();
	Laser_OnPluginStart();
	Painter_OnPluginStart();
	MarkRebel_OnPluginStart();
	Counter_OnPluginStart();
	ShootGuns_OnPluginStart();
	Orders_OnPluginStart();
	Freedays_OnPluginStart();
	NoLR_OnPluginStart();
	Glow_OnPluginStart();

	// AutoExecConfig
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_poststart", Event_PostRoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("round_end", Event_RoundEnd);
	HookConVarChange(gc_sModelPathWarden, OnSettingChanged);
	HookConVarChange(gc_sUnWarden, OnSettingChanged);
	HookConVarChange(gc_sWarden, OnSettingChanged);
	HookConVarChange(gc_sYouWarden, OnSettingChanged);
	HookConVarChange(gc_sOverlayPath, OnSettingChanged);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// FindConVar
	gc_sWarden.GetString(g_sWarden, sizeof(g_sWarden));
	gc_sYouWarden.GetString(g_sYouWarden, sizeof(g_sYouWarden));
	gc_sUnWarden.GetString(g_sUnWarden, sizeof(g_sUnWarden));
	gc_sOverlayPath.GetString(g_sOverlayPath, sizeof(g_sOverlayPath));
	gc_sModelPathWarden.GetString(g_sModelPathWarden, sizeof(g_sModelPathWarden));

	// Set directory for LogFile - must be created before
	SetLogFile(g_sMyJBLogFile, "MyJB", "MyJailbreak");

	g_hCooldown = CreateTrie();
	g_hLimit = CreateTrie();
	g_aApplicationQueue = CreateArray();

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

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sWarden)
	{
		strcopy(g_sWarden, sizeof(g_sWarden), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sWarden);
		}
	}
	else if (convar == gc_sYouWarden)
	{
		strcopy(g_sYouWarden, sizeof(g_sYouWarden), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sYouWarden);
		}
	}
	else if (convar == gc_sUnWarden)
	{
		strcopy(g_sUnWarden, sizeof(g_sUnWarden), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sUnWarden);
		}
	}
	else if (convar == gc_sOverlayPath)
	{
		strcopy(g_sOverlayPath, sizeof(g_sOverlayPath), newValue);

		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayPath);
		}
	}
	else if (convar == gc_sModelPathWarden)
	{
		strcopy(g_sModelPathWarden, sizeof(g_sModelPathWarden), newValue);

		if (gc_bModel.BoolValue) 
		{
			Downloader_AddFileToDownloadsTable(g_sModelPathWarden);
			PrecacheModel(g_sModelPathWarden);
		}
	}
	else if (convar == gc_sPrefix)
	{
		strcopy(g_sPrefix, sizeof(g_sPrefix), newValue);
	}
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	// FindConVar
	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	gc_sWarden.GetString(g_sWarden, sizeof(g_sWarden));
	gc_sUnWarden.GetString(g_sUnWarden, sizeof(g_sUnWarden));
	gc_sYouWarden.GetString(g_sYouWarden, sizeof(g_sYouWarden));
	gc_sOverlayPath.GetString(g_sOverlayPath, sizeof(g_sOverlayPath));
	gc_sModelPathWarden.GetString(g_sModelPathWarden, sizeof(g_sModelPathWarden));

	Deputy_OnConfigsExecuted();
	Math_OnConfigsExecuted();
	RandomKill_OnConfigsExecuted();
	CellDoors_OnConfigsExecuted();
	Laser_OnConfigsExecuted();
	Mute_OnConfigsExecuted();
	NoBlock_OnConfigsExecuted();
	Painter_OnConfigsExecuted();
	Rebel_OnConfigsExecuted();
	Countdown_OnConfigsExecuted();
	ExtendTime_OnConfigsExecuted();
	Counter_OnConfigsExecuted();
	Orders_OnConfigsExecuted();
	Freedays_OnConfigsExecuted();
	FriendlyFire_OnConfigsExecuted();
	NoLR_OnConfigsExecuted();

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Become warden
	gc_sCustomCommandWarden.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_BecomeWarden, "Allows the warde taking the charge over prisoners");
		}
	}

	// Exit warden
	gc_sCustomCommandUnWarden.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_ExitWarden, "Allows the player to retire from the position");
		}
	}

	// Veto warden
	gc_sCustomCommandVetoWarden.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_VoteWarden, "Allows the player to vote against Warden");
		}
	}

	// Set warden
	gc_sCustomCommandSetWarden.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegAdminCmd(sCommand, AdminCommand_SetWarden, ADMFLAG_GENERIC, "Allows the admin to set a new Warden");
		}
	}

	// Remove warden
	gc_sCustomCommandRemoveWarden.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegAdminCmd(sCommand, AdminCommand_RemoveWarden, ADMFLAG_GENERIC, "Allows the admin to remove the Warden");
		}
	}
}

public void OnAllPluginsLoaded()
{
	// FindConVar
	g_bMenuClose = FindConVar("sm_menu_close");

	// FindLibarys
	gp_bMyJailBreak = LibraryExists("myjailbreak");
	gp_bHosties = LibraryExists("hosties");
	gp_bLastRequest = LibraryExists("lastrequest");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bSimpleChatProcessor = LibraryExists("scp");
	gp_bChatProcessor = LibraryExists("chat-processor");
	gp_bBasecomm = LibraryExists("basecomm");
	gp_bSourceComms = LibraryExists("sourcecomms");
	gp_bCustomPlayerSkins = LibraryExists("CustomPlayerSkins");
	gp_bDeadGames = LibraryExists("franug_deadgames");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailBreak = false;
	}
	else if (StrEqual(name, "hosties"))
	{
		gp_bHosties = false;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bLastRequest = false;
	}
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = false;
	}
	else if (StrEqual(name, "chat-processor"))
	{
		gp_bChatProcessor = false;
	}
	else if (StrEqual(name, "scp"))
	{
		gp_bSimpleChatProcessor = false;
	}
	else if (StrEqual(name, "basecomm"))
	{
		gp_bBasecomm = false;
	}
	else if (StrEqual(name, "sourcecomms"))
	{
		gp_bSourceComms = false;
	}
	else if (StrEqual(name, "CustomPlayerSkins"))
	{
		gp_bCustomPlayerSkins = false;
	}
	else if (StrEqual(name, "franug_deadgames"))
	{
		gp_bDeadGames = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailBreak = true;
	}
	else if (StrEqual(name, "hosties"))
	{
		gp_bHosties = true;
	}
	else if (StrEqual(name, "lastrequest"))
	{
		gp_bLastRequest = true;
	}
	else if (StrEqual(name, "smartjaildoors"))
	{
		gp_bSmartJailDoors = true;
	}
	else if (StrEqual(name, "chat-processor"))
	{
		gp_bChatProcessor = true;
	}
	else if (StrEqual(name, "scp"))
	{
		gp_bSimpleChatProcessor = true;
	}
	else if (StrEqual(name, "basecomm"))
	{
		gp_bBasecomm = true;
	}
	else if (StrEqual(name, "sourcecomms"))
	{
		gp_bSourceComms = true;
	}
	else if (StrEqual(name, "CustomPlayerSkins"))
	{
		gp_bCustomPlayerSkins = true;
	}
	else if (StrEqual(name, "franug_deadgames"))
	{
		gp_bDeadGames = true;
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Become Warden
public Action Command_BecomeWarden(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || (g_bIsLR && gc_bRemoveLR.BoolValue))  // "sm_warden_enable" "1" and no last request
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_disabled");
		return Plugin_Handled;
	}

	if (g_iWarden != -1)  // Is there already a warden
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_exist", g_iWarden);

		return Plugin_Handled;
	}

	if (!gc_bBecomeWarden.BoolValue)  // "sm_warden_become" "1"
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_nobecome", g_iWarden);
		return Plugin_Handled;
	}

	if (GetClientTeam(client) != CS_TEAM_CT)  // Is player a guard
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_ctsonly");
		return Plugin_Handled;
	}

	if (gc_bChoiceWarden.BoolValue)
	{
		if(g_iApplicationTime < 1)
			return Plugin_Handled;

		int iIndex = g_aApplicationQueue.FindValue(client);

		if(iIndex != -1)
			return Plugin_Handled;

		g_aApplicationQueue.Push(client);
		CPrintToChatAll("%s %t", g_sPrefix, "warden_apply_added", client);

		return Plugin_Handled;
	}

	if (!IsPlayerAlive(client))  // Alive?
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_playerdead");
		return Plugin_Handled;
	}

	if (GetCoolDown(client) > 0)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_cooldown", GetCoolDown(client));
		return Plugin_Handled;
	}

	if (g_iCMDCoolDown[client] > GetTime())
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_wait", RoundFloat(gc_fCMDCooldown.FloatValue));
		return Plugin_Handled;
	}
	
	if (GetLimit(client) < gc_iLimitWarden.IntValue || gc_iLimitWarden.IntValue == 0 || (gc_iCoolDownMinPlayer.IntValue > GetTeamPlayersCount(CS_TEAM_CT)))
	{
		if (g_iCMDCoolDownSpam[client] > GetTime())
		{
			CReplyToCommand(client, "%s %t", g_sPrefix, "warden_wait_spam_become");
		}
		else if (SetTheWarden(client, client) != Plugin_Handled)
		{
			Forward_OnWardenCreatedByUser(client);
		}
	}
	else
	{
		SetCoolDown(client, gc_iCoolDownLimit.IntValue);
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_limit", gc_iLimitWarden.IntValue, GetCoolDown(client));

		CheckWardenCoolDowns();
	}

	return Plugin_Handled;
}

// Exit / Retire Warden
public Action Command_ExitWarden(int client, int args) 
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)  // "sm_warden_enable" "1"
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_disabled");
		return Plugin_Handled;
	}

	if (!IsClientWarden(client))  // Is client the warden
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
		return Plugin_Handled;
	}

	if (gc_bChoiceWarden.BoolValue && !IsClientWarden(client))
	{
		int iIndex = g_aApplicationQueue.FindValue(client);

		if(g_iApplicationTime > 0 && iIndex != -1)
		{
			g_aApplicationQueue.Erase(iIndex);
			CReplyToCommand(client, "%s %t", g_sPrefix, "warden_apply_removed");
		}
		return Plugin_Handled;
	}
	
	if (g_iCMDCoolDownSpam[client] > GetTime())
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_wait_spam_retire");
		return Plugin_Handled;
	}
	g_iCMDCoolDownSpam[client] = GetTime() + WARDEN_SPAM;

	Forward_OnWardenRemovedBySelf(client);
	RemoveTheWarden();

	CPrintToChatAll("%s %t", g_sPrefix, "warden_retire", client);
	if (gc_bBetterNotes.BoolValue)
	{
		PrintCenterTextAll("%t", "warden_retire_nc", client);
	}

	return Plugin_Handled;
}

// Voting against Warden
public Action Command_VoteWarden(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)  // "sm_warden_enable" "1"
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_disabled");
		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)  // "sm_warden_vote" "1"
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_voting");
		return Plugin_Handled;
	}

	if (g_iWarden == -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_noexist");
		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid)); // Get client steam ID

	if (StrContains(g_sHasVoted, steamid, true) != -1)  // Check steam ID has already voted
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_voted");
		return Plugin_Handled;
	}

	int playercount = (GetClientCount(true) / 2);
	g_iVoteCount++;
	int Missing = playercount - g_iVoteCount + 1;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "%s, %s", g_sHasVoted, steamid);

	if (g_iVoteCount < playercount)
	{
		CPrintToChatAll("%s %t", g_sPrefix, "warden_need", Missing, client);
		return Plugin_Handled;
	}

	SetCoolDown(g_iWarden, gc_iCoolDownRemove.IntValue);

	RemoveTheWarden();
	CPrintToChatAll("%s %t", g_sPrefix, "warden_votesuccess");

	if (!gp_bMyJailBreak)
		return Plugin_Handled;

	if (!MyJailbreak_ActiveLogging())
		return Plugin_Handled;

	LogToFileEx(g_sMyJBLogFile, "Player %L was kick as warden by voting", g_iLastWarden);

	return Plugin_Handled;
}

// Remove Warden for Admins
public Action AdminCommand_RemoveWarden(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)  // "sm_warden_enable" "1"
		return Plugin_Handled;

	if (g_iWarden == -1)
	{
		CReplyToCommand(client, "%s %t", g_sPrefix, "warden_noexist");
		return Plugin_Handled;
	}

	SetCoolDown(g_iWarden, gc_iCoolDownRemove.IntValue);

	RemoveTheWarden();
	Forward_OnWardenRemovedByAdmin(client);

	CPrintToChatAll("%s %t", g_sPrefix, "warden_removed", client, g_iLastWarden); 
	if (gc_bBetterNotes.BoolValue)
	{
		PrintCenterTextAll("%t", "warden_removed_nc", client, g_iLastWarden);
	}

	if (!gp_bMyJailBreak)
		return Plugin_Handled;

	if (!MyJailbreak_ActiveLogging())
		return Plugin_Handled;

	LogToFileEx(g_sMyJBLogFile, "Admin %L removed player %L as warden", client, g_iLastWarden);

	return Plugin_Handled;
}


// Set new Warden for Admins
public Action AdminCommand_SetWarden(int client, int args)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)  // "sm_warden_enable" "1"
		return Plugin_Handled;

	Menu_SetWarden(client);

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Warden Died
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

	if (IsClientWarden(client))  // The Warden is dead
	{
		Forward_OnWardenDeath(client);
		Forward_OnWardenRemoved(client);

		CPrintToChatAll("%s %t", g_sPrefix, "warden_dead", client);

		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_dead_nc", client);
		}

		if (gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}

		delete g_hTimerRandom;

		g_hTimerRandom = CreateTimer(gc_fRandomTimer.FloatValue, Timer_ChooseRandom);

		g_iLastWarden = g_iWarden;
		g_iWarden = -1;
	}
}

// Warden change Team
public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the clients id

	if (IsClientWarden(client))  // The Warden changed team
	{
		Forward_OnWardenDeath(client);
		RemoveTheWarden();

		CPrintToChatAll("%s %t", g_sPrefix, "warden_retire", client);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_retire_nc", client);
		}
	}

	int iIndex = g_aApplicationQueue.FindValue(client);
	if(iIndex != -1)
	{
		g_aApplicationQueue.Erase(iIndex);
	}
}

// Round Start Post
public void Event_PostRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)
		return;

	if ((g_iWarden == -1) && gc_bBecomeWarden.BoolValue && !gc_bChoiceWarden.BoolValue)
	{
		delete g_hTimerRandom;

		g_hTimerRandom = CreateTimer(gc_fRandomTimer.FloatValue, Timer_ChooseRandom);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, false, false))
				continue;

			CPrintToChat(i, "%s %t", g_sPrefix, "warden_nowarden");
			
			if (gc_bBetterNotes.BoolValue)
			{
				PrintCenterText(i, "%t", "warden_nowarden_nc");
			}
		}
	}
	else if ((g_iWarden == -1) && gc_bChoiceWarden.BoolValue)  // Start applications timer
	{
		g_iApplicationTime = gc_iApplicationTime.IntValue;

		CreateTimer(1.0, Timer_Application, _, TIMER_REPEAT);
	}
}

// Round Start Post
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled)
	{
		if (g_iWarden != -1)
		{
			CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));
			SetEntityModel(g_iWarden, g_sModelPathPrevious);
			Forward_OnWardenRemoved(g_iWarden);
			g_iLastWarden = g_iWarden;
			g_iWarden = -1;
		}
	}

	if (gp_bMyJailBreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			if (g_iWarden != -1)
			{
				CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));
				SetEntityModel(g_iWarden, g_sModelPathPrevious);
				Forward_OnWardenRemoved(g_iWarden);
				g_iLastWarden = g_iWarden;
				g_iWarden = -1;
			}
		}
	}

	if (!gc_bStayWarden.BoolValue)
	{
		if (g_iWarden != -1)
		{
			CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));
			SetEntityModel(g_iWarden, g_sModelPathPrevious);
			Forward_OnWardenRemoved(g_iWarden);
			g_iLastWarden = g_iWarden;
			g_iWarden = -1;
		}

		if (g_iLastWarden != -1 && GetAlivePlayersCount(CS_TEAM_CT) > 1 )
		{
			g_iCMDCoolDown[g_iLastWarden] = GetTime() + RoundFloat(gc_fCMDCooldown.FloatValue);
		}
	}

	if (gc_iLimitWarden.IntValue != 0)
	{
		for (int i = 1; i <= MaxClients; i++) 
		{
			if (!IsClientInGame(i))
				continue;

			// /shiiet 
			if (GetLimit(i) && (i != g_iLastWarden) && (i != g_iWarden))
			{
				SetLimit(i, GetLimit(i)-1); // mode rounds in ROW - so when round with  no warden set 0 / or mode round behinds - so when round with no warden set 'limit'-1 
			}

			if (gp_bMyJailBreak && GetLimit(i))
			{
				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);
				if (!StrEqual(EventDay, "none", false) && i == g_iLastWarden)
				{
					SetLimit(i, GetLimit(i)-1); // mode rounds in ROW - so when round with  no warden set 0 / or mode round behinds - so when round with no warden set 'limit'-1 
				}
			}
		}
	}

	if (gc_iCoolDownRemove.IntValue != 0) // 
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (GetCoolDown(i) != 0) 
		{
			SetCoolDown(i, GetCoolDown(i)-1);
		}
	}

	if (g_iWarden != -1)  // warden exists
	{
		if (gc_iLimitWarden.IntValue != 0 && (GetLimit(g_iWarden) >= gc_iLimitWarden.IntValue) && (GetTeamPlayersCount(CS_TEAM_CT) >= gc_iCoolDownMinPlayer.IntValue)) // remove
		{
			SetCoolDown(g_iWarden, gc_iCoolDownLimit.IntValue);
			SetLimit(g_iWarden, 0);
			CPrintToChat(g_iWarden, "%s %t", g_sPrefix, "warden_limit", gc_iLimitWarden.IntValue, GetCoolDown(g_iWarden));
			CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));
			SetEntityModel(g_iWarden, g_sModelPathPrevious);
			Forward_OnWardenRemoved(g_iWarden);
			g_iLastWarden = g_iWarden;
			g_iWarden = -1;

			CheckWardenCoolDowns();
		}
		else // stay warden
		{
			if (gc_bModel.BoolValue)
			{
				SetEntityModel(g_iWarden, g_sModelPathWarden);
			}

			SetLimit(g_iWarden, GetLimit(g_iWarden)+1);
			Glow_OnWardenCreation(g_iWarden);
		}
	}

	g_bIsLR = false;
}


public Action Timer_Application(Handle timer)
{
	g_iApplicationTime--;

	if (g_iApplicationTime > 0)
	{
		PrintCenterTextAll("%t", "warden_apply_time", g_iApplicationTime);
		return Plugin_Continue;
	}

	Voting_ChooseWarden();

	return Plugin_Stop;
}

void Voting_ChooseWarden()
{
	if (g_aApplicationQueue.Length < 1)
	{
		int warden = GetRandomPlayer(CS_TEAM_CT);
		if (SetTheWarden(warden, 0) != Plugin_Handled)
		{
			Forward_OnWardenCreatedByAdmin(warden);
			CPrintToChatAll("%s %t", g_sPrefix, "warden_no_applications");
		}
		else
		{
			g_hTimerRandom = CreateTimer(gc_fRandomTimer.FloatValue, Timer_ChooseRandom);
		}

		return;
	}

	if (g_aApplicationQueue.Length == 1)
	{
		int warden = g_aApplicationQueue.Get(0);
		if (SetTheWarden(warden, 0) != Plugin_Handled)
		{
			Forward_OnWardenCreatedByAdmin(warden);
			CPrintToChatAll("%s %t", g_sPrefix, "warden_one_application");
		}
		else
		{
			g_hTimerRandom = CreateTimer(gc_fRandomTimer.FloatValue, Timer_ChooseRandom);
		}

		return;
	}

	PrintCenterTextAll("%s %t", g_sPrefix, "warden_apply_time_over");

	char menuinfo[64];
	Menu menu = new Menu(Voting_MenuHandler);
	menu.VoteResultCallback = VotingResults;
	Format(menuinfo, sizeof(menuinfo), "%t", "warden_vote_applicants", LANG_SERVER);
	menu.SetTitle(menuinfo);

	for (int i = 0; i < g_aApplicationQueue.Length; i++)
	{
		if (!IsValidClient(g_aApplicationQueue.Get(i), true, true))
			continue;

		char userid[11];
		char username[MAX_NAME_LENGTH];
		IntToString(GetClientUserId(i+1), userid, sizeof(userid));
		Format(username, sizeof(username), "%N", g_aApplicationQueue.Get(i));
		menu.AddItem(userid, username);
	}
	
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, false, false))
			continue;

		if (!gc_bChoiceTeam.BoolValue && GetClientTeam(i) != CS_TEAM_T)
			continue;

		clients[clientCount++] = i;
	}

	menu.ExitButton = false;
	menu.DisplayVote(clients, clientCount, gc_iChoiceTime.IntValue, _);
}

public int VotingResults(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	int winner = 0;
	if (num_items > 1 && (item_info[0][VOTEINFO_ITEM_VOTES] == item_info[1][VOTEINFO_ITEM_VOTES]))
	{
		winner = GetRandomInt(0, 1);
		CPrintToChatAll("%s %t", g_sPrefix, "warden_vote_draw");
	}
	char event[64];
	menu.GetItem(item_info[winner][VOTEINFO_ITEM_INDEX], event, sizeof(event));

	int warden = GetClientOfUserId(StringToInt(event));

	if (SetTheWarden(warden, 0) != Plugin_Handled)
	{
		Forward_OnWardenCreatedByAdmin(warden);
		CPrintToChatAll("%s %t", g_sPrefix, "warden_vote_won", warden);

		if (gc_iListType.IntValue == 0)
		{
			g_aApplicationQueue.Clear();
		}
		else if (gc_iListType.IntValue == 1)
		{
			g_aApplicationQueue.Erase(g_aApplicationQueue.FindValue(warden));
		}
	}
	else
	{
		g_hTimerRandom = CreateTimer(gc_fRandomTimer.FloatValue, Timer_ChooseRandom);
	}

}


public int Voting_MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		delete menu;
	}
}



// Round End
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bIsLR = false;

	if (gc_bChoiceWarden.BoolValue) // Start applications
	{
		g_iApplicationTime = gc_iApplicationTime.IntValue;
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Prepare Plugin & modules
public void OnMapStart()
{
	Deputy_OnMapStart();
	Countdown_OnMapStart();
	Math_OnMapStart();
	HandCuffs_OnMapStart();
	Marker_OnMapStart();
	Reminder_OnMapStart();
	Laser_OnMapStart();
	Painter_OnMapStart();
	Orders_OnMapStart();
	Freedays_OnMapStart();

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sWarden);
		PrecacheSoundAnyDownload(g_sYouWarden);
		PrecacheSoundAnyDownload(g_sUnWarden);
	}

	if (gc_bModel.BoolValue)
	{
		Downloader_AddFileToDownloadsTable(g_sModelPathWarden);
		PrecacheModel(g_sModelPathWarden);
	}

	if (gc_bOverlays.BoolValue && strlen(g_sOverlayPath) > 0)
	{
		PrecacheDecalAnyDownload(g_sOverlayPath);
	}

	g_iVoteCount = 0;
	g_bEnabled = true;

	g_iSmokeSprite = PrecacheModel("materials/sprites/steam1.vmt");
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	PrecacheSound(SOUND_THUNDER, true);

	ClearTrie(g_hCooldown);
	ClearTrie(g_hLimit);
}

// Prepare client for Plugin & modules
public void OnClientPutInServer(int client)
{
	BulletSparks_OnClientPutInServer(client);
	HandCuffs_OnClientPutInServer(client);
	BackStab_OnClientPutInServer(client);
	Laser_OnClientPutInServer(client);
	Painter_OnClientPutInServer(client);
	FriendlyFire_OnClientPutInServer(client);
}

// Warden disconnect
public void OnClientDisconnect(int client)
{
	HandCuffs_OnClientDisconnect(client); // this is prioritised to fix a crash with the StripZeus function
	
	if (IsClientWarden(client))
	{
		CPrintToChatAll("%s %t", g_sPrefix, "warden_disconnected", client);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_disconnected_nc", client);
		}

		Forward_OnWardenRemoved(client);
		Forward_OnWardenDisconnected(client);

		if (gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}

		g_iLastWarden = -1;
		g_iWarden = -1;
	}

	if (gc_bChoiceWarden.BoolValue)
	{
		int iIndex = g_aApplicationQueue.FindValue(client);
		if(iIndex != -1)
		{
			g_aApplicationQueue.Erase(iIndex);
		}
	}

	Deputy_OnClientDisconnect(client);
	Painter_OnClientDisconnect(client);
	Freedays_OnClientDisconnect(client);
}

// Close open timer & reset warden/module
public void OnMapEnd()
{
	if (g_iWarden != -1)
	{
		CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));

		Forward_OnWardenRemoved(g_iWarden);
		g_iWarden = -1;
		g_iLastWarden = -1;
	}

	Deputy_OnMapEnd();
	Math_OnMapEnd();
	Mute_OnMapEnd();
	Countdown_OnMapEnd();
	Reminder_OnMapEnd();
	HandCuffs_OnMapEnd();
	Marker_OnMapEnd();
	Painter_OnMapEnd();
}

// When a last request is available
public void OnAvailableLR(int Announced)
{
	g_bIsLR = true;

	GunDropPrevention_OnAvailableLR(Announced);
	Mute_OnAvailableLR(Announced);
	HandCuffs_OnAvailableLR(Announced);
	Deputy_OnAvailableLR(Announced);
	Marker_OnAvailableLR(Announced);
	NoBlock_OnAvailableLR();

	if (gc_bRemoveLR.BoolValue && g_iWarden != -1)
	{
		RemoveTheWarden();
		Forward_OnWardenRemovedByAdmin(0); // 0 = console
	}
}

// When a event game starts during round.
public void MyJailbreak_OnEventDayStart(char[] EventDayName)
{
	if (g_iWarden != -1)
	{
		CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));
		SetEntityModel(g_iWarden, g_sModelPathPrevious);
		Forward_OnWardenRemoved(g_iWarden);
		g_iLastWarden = g_iWarden;
		g_iWarden = -1;
	}
}

// Check Keyboard Input for modules
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if ((IsClientWarden(client) || IsClientDeputy(client)) && gc_bPlugin.BoolValue && g_bEnabled)
	{
		Marker_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
		Laser_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
	}

	Painter_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
	HandCuffs_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Set a new warden
Action SetTheWarden(int client, int caller)
{
	if (!IsValidClient(client, true, false))
	{
		return Plugin_Handled;
	}

	if (gc_bPlugin.BoolValue && g_bEnabled)
	{
		Action res = Plugin_Continue;

		Call_StartForward(gF_OnWardenCreate);
		Call_PushCell(client);
		Call_PushCell(caller);
		Call_Finish(res);

		if (res >= Plugin_Handled)
		{
			ClientCommand(client, "play %s", g_sRestrictedSound);
			return Plugin_Handled;
		}

		OnWardenCreation(client);

		CPrintToChatAll("%s %t", g_sPrefix, "warden_new", client);
		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_new_nc", client);
		}

		g_iWarden = client;

		if (GetLimit(client))
		{
			SetLimit(client, GetLimit(client)+1);
		}
		else
		{
			SetLimit(client, 1);
		}
		
		g_iCMDCoolDownSpam[client] = GetTime() + WARDEN_SPAM;

		GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPathPrevious, sizeof(g_sModelPathPrevious));

		if (gc_bModel.BoolValue)
		{
			SetEntityModel(client, g_sModelPathWarden);
		}

		if (gc_bOverlays.BoolValue && strlen(g_sOverlayPath) > 0)
		{
			ShowOverlay(client, g_sOverlayPath, 2.5);
		}

		SetClientListeningFlags(client, VOICE_NORMAL);

		if (gc_bSounds.BoolValue)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i, false, true))
					continue;

				if (i == client)
				{
					EmitSoundToClientAny(i, g_sYouWarden);
					continue;
				}

				EmitSoundToClientAny(i, g_sWarden);
			}
		}

		delete g_hTimerRandom;
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_disabled");

	return Plugin_Continue;
}

// Remove the current warden
void RemoveTheWarden()
{
	CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));
	SetEntityModel(g_iWarden, g_sModelPathPrevious);

	g_hTimerRandom = CreateTimer(gc_fRandomTimer.FloatValue, Timer_ChooseRandom);

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sUnWarden);
	}

	g_iVoteCount = 0;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "");
	g_sHasVoted[0] = '\0';

	Forward_OnWardenRemoved(g_iWarden);
	g_iLastWarden = g_iWarden;
	g_iWarden = -1;
}

int GetCoolDown(int client)
{
	char steamid[24];
	int cooldown;

	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (!GetTrieValue(g_hCooldown, steamid, cooldown))
	{
		cooldown = 0;
	}

	return cooldown;
}

void SetCoolDown(int client, int cooldown)
{
	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (cooldown == 0)
	{
		RemoveFromTrie(g_hCooldown, steamid);
	}
	else SetTrieValue(g_hCooldown, steamid, cooldown);
}

int GetLimit(int client)
{
	char steamid[24];
	int limit;

	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (!GetTrieValue(g_hLimit, steamid, limit))
	{
		limit = 0;
	}

	return limit;
}

void SetLimit(int client, int limit)
{
	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (limit == 0)
	{
		RemoveFromTrie(g_hLimit, steamid);
	}
	else SetTrieValue(g_hLimit, steamid, limit);
}

void CheckWardenCoolDowns()
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, false, false))
			continue;

		if (GetClientTeam(i) != CS_TEAM_CT)
			continue;

		if (GetCoolDown(i) > 0)
		{
			count++;
		}
	}

	if (count < GetAlivePlayersCount(CS_TEAM_CT))
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, false, true))
			continue;

		if (GetClientTeam(i) != CS_TEAM_CT)
			continue;

		SetCoolDown(i, 0);
	}

	CPrintToChatAll("%s %t", g_sPrefix, "warden_cooldown_reset");
}

/******************************************************************************
                   MENUS
******************************************************************************/

// Admin set (new) Warden menu
void Menu_SetWarden(int client)
{
	char info1[255];
	Menu menu = CreateMenu(Handler_SetWarden);

	Format(info1, sizeof(info1), "%T", "warden_choose", client);
	menu.SetTitle(info1);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, false))
			continue;

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

// Handler set (new) Warden menu with overwrite/remove query
public int Handler_SetWarden(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i, true, false))
				continue;

			if (GetClientTeam(i) == CS_TEAM_CT && !IsClientWarden(i))
			{
				char info4[255], info2[255], info3[255];
				int userid = GetClientUserId(i);

				if (userid == StringToInt(Item))
				{
					if (g_iWarden != -1)  // if (g_iWarden != -1)
					{
						g_iTempWarden[client] = userid;
						Menu menu1 = CreateMenu(Handler_SetWardenOverwrite);
						Format(info4, sizeof(info4), "%T", "warden_remove", client);
						menu1.SetTitle(info4);
						Format(info3, sizeof(info3), "%T", "warden_yes", client);
						Format(info2, sizeof(info2), "%T", "warden_no", client);
						menu1.AddItem("1", info3);
						menu1.AddItem("0", info2);
						menu1.ExitBackButton = true;
						menu1.ExitButton = true;
						menu1.Display(client, MENU_TIME_FOREVER);
					}
					else
					{
						if (SetTheWarden(i, client) != Plugin_Handled)
						{
							Forward_OnWardenCreatedByAdmin(i);
						}
					}
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

// Handler overwrite/remove query menu
public int Handler_SetWardenOverwrite(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);

		if (choice == 1)
		{
			int newwarden = GetClientOfUserId(g_iTempWarden[client]);
			if (g_iWarden != -1)
			{
				CPrintToChatAll("%s %t", g_sPrefix, "warden_removed", client, g_iWarden);
			}

			RemoveTheWarden();
			Forward_OnWardenRemovedByAdmin(client);
			if (SetTheWarden(newwarden, client) != Plugin_Handled)
			{
				Forward_OnWardenCreatedByAdmin(newwarden);

				if (gp_bMyJailBreak)
				{
					if (MyJailbreak_ActiveLogging())
					{
						LogToFileEx(g_sMyJBLogFile, "Admin %L kick player %L warden and set %L as new", client, g_iWarden, newwarden);
					}
				}
			}
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

// Choose a random Warden after a defined time
public Action Timer_ChooseRandom(Handle timer)
{
	g_hTimerRandom = null;
	
	if (!gc_bPlugin.BoolValue || !g_bEnabled || (g_bIsLR && gc_bRemoveLR.BoolValue) || g_iWarden != -1 || !gc_bChooseRandom.BoolValue)
	{
		return Plugin_Stop;
	}

	int i = GetRandomPlayer(CS_TEAM_CT);

	if (SetTheWarden(i, 0) != Plugin_Handled)
	{
		CPrintToChatAll("%s %t", g_sPrefix, "warden_randomwarden");
	}
	else
	{
		g_hTimerRandom = CreateTimer(0.1, Timer_ChooseRandom);
	}

	return Plugin_Stop;
}


/******************************************************************************
                   STOCKS
******************************************************************************/

bool IsClientWarden(int client)
{
	if (client != g_iWarden)
	{
		return false;
	}

	return true;
}

/******************************************************************************
                   NATIVES
******************************************************************************/

// Register Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Natives
	CreateNative("warden_enable", Native_Enable);
	CreateNative("warden_isenabled", Native_IsEnabled);
	
	CreateNative("warden_exist", Native_ExistWarden);
	CreateNative("warden_iswarden", Native_IsWarden);
	CreateNative("warden_set", Native_SetWarden);
	CreateNative("warden_removed", Native_RemoveWarden);

	CreateNative("warden_get", Native_GetWarden);
	CreateNative("warden_getlast", Native_GetLastWarden);

	CreateNative("warden_deputy_exist", Native_ExistDeputy);
	CreateNative("warden_deputy_isdeputy", Native_IsDeputy);
	CreateNative("warden_deputy_set", Native_SetDeputy);
	CreateNative("warden_deputy_removed", Native_RemoveDeputy);
	CreateNative("warden_deputy_get", Native_GetDeputy);
	CreateNative("warden_deputy_getlast", Native_GetLastDeputy);

	CreateNative("warden_handcuffs_givepaperclip", Native_GivePaperClip);
	CreateNative("warden_handcuffs_iscuffed", Native_IsClientCuffed);

	CreateNative("warden_freeday_set", Native_GiveFreeday);
	CreateNative("warden_freeday_has", Native_HasClientFreeday);

	// Forwards
	gF_OnWardenCreate = CreateGlobalForward("warden_OnWardenCreate", ET_Event, Param_Cell, Param_Cell);
	gF_OnWardenCreated = CreateGlobalForward("warden_OnWardenCreated", ET_Ignore, Param_Cell);
	gF_OnWardenRemoved = CreateGlobalForward("warden_OnWardenRemoved", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByUser = CreateGlobalForward("warden_OnWardenCreatedByUser", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByAdmin = CreateGlobalForward("warden_OnWardenCreatedByAdmin", ET_Ignore, Param_Cell);
	gF_OnWardenDisconnected = CreateGlobalForward("warden_OnWardenDisconnected", ET_Ignore, Param_Cell);
	gF_OnWardenDeath = CreateGlobalForward("warden_OnWardenDeath", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedBySelf = CreateGlobalForward("warden_OnWardenRemovedBySelf", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedByAdmin = CreateGlobalForward("warden_OnWardenRemovedByAdmin", ET_Ignore, Param_Cell);


	RegPluginLibrary("warden");
	RegPluginLibrary("myjbwarden");

	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Booleans Exist Warden
public int Native_ExistWarden(Handle plugin, int argc)
{
	if (g_iWarden == -1)
	{
		return false;
	}

	return true;
}

// Booleans Is Client Warden
public int Native_IsWarden(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	if (IsClientWarden(client))
		return true;

	return false;
}


// Set Client as Warden
public int Native_SetWarden(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	int caller = GetNativeCell(2);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	if (g_iWarden == -1)
		SetTheWarden(client, caller);
}

// Remove current Warden
public int Native_RemoveWarden(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	if (IsClientWarden(client))
		RemoveTheWarden();
}

// Get Warden Client Index
public int Native_GetWarden(Handle plugin, int argc)
{
	return g_iWarden;
}

// Get last wardens Client Index
public int Native_GetLastWarden(Handle plugin, int argc)
{
	return g_iLastWarden;
}

// Get last wardens Client Index
public int Native_Enable(Handle plugin, int argc)
{
	g_bEnabled = GetNativeCell(1);
	
	if (!g_bEnabled && g_iWarden != -1)
	{
		CreateTimer(0.1, Timer_RemoveColor, GetClientUserId(g_iWarden));
		SetEntityModel(g_iWarden, g_sModelPathPrevious);
		Forward_OnWardenRemoved(g_iWarden);
		g_iLastWarden = g_iWarden;
		g_iWarden = -1;
	}
}

// Get last wardens Client Index
public int Native_IsEnabled(Handle plugin, int argc)
{
	return g_bEnabled;
}

/******************************************************************************
                   FORWARDS CALL
******************************************************************************/

// New Warden was set (will only fire on set ByUser)
void Forward_OnWardenCreatedByUser(int client)
{
	Call_StartForward(gF_OnWardenCreatedByUser);
	Call_PushCell(client);
	Call_Finish();

	Call_StartForward(gF_OnWardenCreated);
	Call_PushCell(client);
	Call_Finish();
}

// New Warden was set (will only fire on set ByAdmin)
void Forward_OnWardenCreatedByAdmin(int client)
{
	Call_StartForward(gF_OnWardenCreatedByAdmin);
	Call_PushCell(client);
	Call_Finish();

	Call_StartForward(gF_OnWardenCreated);
	Call_PushCell(client);
	Call_Finish();
}

// Warden was removed (will fire all time - *BySelf *ByAdmin *Death ...)
void Forward_OnWardenRemoved(int client)
{
	Call_StartForward(gF_OnWardenRemoved);
	Call_PushCell(client);
	Call_Finish();

	Deputy_OnWardenRemoved(client);
	Marker_OnWardenRemoved();
	Color_OnWardenRemoved(client);
	Laser_OnWardenRemoved(client);
	Painter_OnWardenRemoved(client);
	HandCuffs_OnWardenRemoved(client);
	Glow_OnWardenRemoved(client);
}

// Warden was removed (will only fire on ByAdmin)
void Forward_OnWardenRemovedByAdmin(int client)
{
	Call_StartForward(gF_OnWardenRemovedByAdmin);
	Call_PushCell(client);
	Call_Finish();
}

// Warden was removed (will only fire on BySelf)
void Forward_OnWardenRemovedBySelf(int client)
{
	Call_StartForward(gF_OnWardenRemovedBySelf);
	Call_PushCell(client);
	Call_Finish();

	Deputy_OnWardenRemovedBySelf(client);
}

// Warden was removed (will only fire on Disconnect)
void Forward_OnWardenDisconnected(int client)
{
	Call_StartForward(gF_OnWardenDisconnected);
	Call_PushCell(client);
	Call_Finish();
}

// Warden was removed (will only fire on Death)
void Forward_OnWardenDeath(int client)
{
	Call_StartForward(gF_OnWardenDeath);
	Call_PushCell(client);
	Call_Finish();
}

// Not a real forward
void OnWardenCreation(int client)
{
	Deputy_OnWardenCreation(client);
	Color_OnWardenCreation(client);
	Laser_OnWardenCreation(client);
	HandCuffs_OnWardenCreation(client);
	Glow_OnWardenCreation(client);
}

bool MyJB_CheckVIPFlags(int client, const char[] command, ConVar flags, char[] feature)
{
	if (gp_bMyJailBreak)
		return MyJailbreak_CheckVIPFlags(client, command, flags, feature);

	char sBuffer[32];
	flags.GetString(sBuffer, sizeof(sBuffer));

	if (strlen(sBuffer) == 0) // ???
		return true;

	int iFlags = ReadFlagString(sBuffer);

	return CheckCommandAccess(client, command, iFlags);
}