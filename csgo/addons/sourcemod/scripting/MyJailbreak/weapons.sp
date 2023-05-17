/*
 * MyJailbreak - Weapon Plugin.
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
#include <clientprefs>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <hosties>
#include <lastrequest>
#include <myjailbreak>
#include <warden>
#include <myjbwarden>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Integers
int g_iMenuUsages[MAXPLAYERS+1];

// Booleans
bool g_bIsLateLoad = false;
bool g_bWeaponsSelected[MAXPLAYERS+1] = {false, ...};
bool g_bRememberChoice[MAXPLAYERS+1] = {false, ...};
bool g_bTA[MAXPLAYERS+1] = {false, ...};
bool g_bHealth[MAXPLAYERS+1] = {false, ...};
bool gp_bMyJBWarden = false;
bool gp_bWarden = false;
bool gp_bMyJailBreak = false;
bool gp_bHosties = false;
bool g_bAllowCT = true;
bool g_bAllowT = false;

// Handles
Handle g_hMenu1 = null;
Handle g_hMenu2 = null;
Handle g_hMenu3 = null;
Handle g_hMenu4 = null;
Handle g_hTimers[MAXPLAYERS + 1] = null;
Handle g_aPrimary;
Handle g_aSecondary;
Handle g_hWeapons1 = null;
Handle g_hWeapons2 = null;

// Console Variables
ConVar gc_bSpawn;
ConVar gc_bPlugin;
ConVar gc_sPrefix;
ConVar gc_bTAWarden;
ConVar gc_bTADeputy;
ConVar gc_bEventDay;
ConVar gc_bJBmenu;
ConVar gc_bAWP;
ConVar gc_bAutoSniper;
ConVar gc_bM249;
ConVar gc_bNegev;
ConVar gc_bHealthWarden;
ConVar gc_bHealthDeputy;
ConVar gc_bKevlar;
ConVar gc_bKevlarDays;
ConVar gc_sCustomCommandWeapon;
ConVar gc_bCleanMenu;
ConVar gc_iMenuMaxUsages;

// Extern Convars
ConVar g_bTaserWarden;
ConVar g_bTaserDeputy;

// Strings
char g_sPrefix[64];
char primaryWeapon[MAXPLAYERS + 1][24];
char secondaryWeapon[MAXPLAYERS + 1][24];

enum struct g_hWeapons
{
	char ItemName[64];
	char desc[64];
}

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - Weapons",
	author = "shanapu",
	description = "Jailbreak weapons script",
	version = MYJB_VERSION,
	url = "https://github.com/shanapu/MyJailbreak"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("MyWeapons_AllowTeam", Native_AllowTeam);
	CreateNative("MyWeapons_GetTeamStatus", Native_TeamStatus);

	RegPluginLibrary("myweapons");

	g_bIsLateLoad = late;

	return APLRes_Success;
}

public int Native_AllowTeam(Handle plugin, int argc)
{
	int iTeam = GetNativeCell(1);

	if (iTeam == CS_TEAM_CT)
	{
		g_bAllowCT = GetNativeCell(2);
	}
	if (iTeam == CS_TEAM_T)
	{
		g_bAllowT = GetNativeCell(2);
	}
}

public int Native_TeamStatus(Handle plugin, int argc)
{
	int iTeam = GetNativeCell(1);

	if (iTeam == CS_TEAM_CT)
	{
		return g_bAllowCT;
	}
	if (iTeam == CS_TEAM_T)
	{
		return g_bAllowT;
	}

	return false;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Weapons.phrases");

	// Client Commands
	RegConsoleCmd("sm_weapon", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");

	// AutoExecConfig
	AutoExecConfig_SetFile("Weapons", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_weapons_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_weapons_enable", "1", "0 - disabled, 1 - enable weapons menu", _, true, 0.0, true, 1.0);
	gc_sPrefix = AutoExecConfig_CreateConVar("sm_weapons_prefix", "[{green}MyJB.Weapons{default}]", "Set your chat prefix for this plugin.");
	gc_sCustomCommandWeapon = AutoExecConfig_CreateConVar("sm_weapons_cmds", "gun, guns, weapons, gunmenu, weaponmenu, giveweapon, arms", "Set your custom chat command for weapon menu(!weapon (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSpawn = AutoExecConfig_CreateConVar("sm_weapons_spawnmenu", "1", "0 - disabled, 1 -  enable autoopen weapon menu on spawn", _, true, 0.0, true, 1.0);
	gc_bEventDay = AutoExecConfig_CreateConVar("sm_weapons_noeventday", "1", "0 - disabled, 1 - enable the weapon menu on non-EventDays round (normal/simon rounds)", _, true, 0.0, true, 1.0);
	gc_bAWP = AutoExecConfig_CreateConVar("sm_weapons_awp", "1", "0 - disabled, 1 - enable AWP in menu", _, true, 0.0, true, 1.0);
	gc_bAutoSniper = AutoExecConfig_CreateConVar("sm_weapons_autosniper", "1", "0 - disabled, 1 - enable scar20 & g3sg1 in menu", _, true, 0.0, true, 1.0);
	gc_bNegev = AutoExecConfig_CreateConVar("sm_weapons_negev", "1", "0 - disabled, 1 - enable negev in menu", _, true, 0.0, true, 1.0);
	gc_bM249 = AutoExecConfig_CreateConVar("sm_weapons_m249", "1", "0 - disabled, 1 - enable m249 in menu", _, true, 0.0, true, 1.0);
	gc_bTAWarden = AutoExecConfig_CreateConVar("sm_weapons_warden_tagrenade", "1", "0 - disabled, 1 - warden get a TA grenade with weapons - need MyJB warden", _, true, 0.0, true, 1.0);
	gc_bHealthWarden = AutoExecConfig_CreateConVar("sm_weapons_warden_healthshot", "1", "0 - disabled, 1 - warden get a healthshot with weapons - need MyJB warden", _, true, 0.0, true, 1.0);
	gc_bTADeputy = AutoExecConfig_CreateConVar("sm_weapons_warden_tagrenade", "1", "0 - disabled, 1 - warden get a TA grenade with weapons - need MyJB warden", _, true, 0.0, true, 1.0);
	gc_bHealthDeputy = AutoExecConfig_CreateConVar("sm_weapons_warden_healthshot", "1", "0 - disabled, 1 - warden get a healthshot with weapons - need MyJB warden", _, true, 0.0, true, 1.0);
	gc_bKevlar = AutoExecConfig_CreateConVar("sm_weapons_kevlar", "1", "0 - disabled, 1 - CT get Kevlar & helm on Spawn", _, true, 0.0, true, 1.0);
	gc_bKevlarDays = AutoExecConfig_CreateConVar("sm_weapons_kevlar_eventdays", "1", "0 - remove all armor on eventdays, 1 - give all player armor on eventdays", _, true, 0.0, true, 1.0);
	gc_bJBmenu = AutoExecConfig_CreateConVar("sm_weapons_jbmenu", "1", "0 - disabled, 1 - enable autoopen the MyJailbreak !menu after weapon given.", _, true, 0.0, true, 1.0);
	gc_bCleanMenu = AutoExecConfig_CreateConVar("sm_weapons_cleanmenu", "1", "remove 1. & 2. on first page, to avoid conflict with weapon switch", _, true, 0.0, true, 1.0);
	gc_iMenuMaxUsages = AutoExecConfig_CreateConVar("sm_weapons_max_usages", "0", "0 - unlimited, max usages of !guns command allowed", _, true, 0.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookConVarChange(gc_sPrefix, OnSettingChanged);

	// Cookies
	g_hWeapons1 = RegClientCookie("Primary Weapons", "", CookieAccess_Private);
	g_hWeapons2 = RegClientCookie("Secondary Weapons", "", CookieAccess_Private);

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			OnClientPutInServer(i);
			OnClientCookiesCached(i);
		}

		g_bIsLateLoad = false;
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
	else if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailBreak = false;
	}
	else if (StrEqual(name, "hosties"))
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
	else if (StrEqual(name, "myjailbreak"))
	{
		gp_bMyJailBreak = true;
	}
	else if (StrEqual(name, "hosties"))
	{
		gp_bHosties = true;
	}
}

public void OnAllPluginsLoaded()
{
	gp_bWarden = LibraryExists("warden");
	gp_bMyJBWarden = LibraryExists("myjbwarden");
	gp_bMyJailBreak = LibraryExists("myjailbreak");
	gp_bHosties = LibraryExists("hosties");

	// FindConVar
	g_bTaserWarden = FindConVar("sm_warden_handcuffs");
	g_bTaserDeputy = FindConVar("sm_warden_handcuffs_deputy");
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	gc_sPrefix.GetString(g_sPrefix, sizeof(g_sPrefix));
	
	delete g_aPrimary;
	delete g_aSecondary;
	
	delete g_hMenu1;
	delete g_hMenu2;
	delete g_hMenu3;
	delete g_hMenu4;
	
	g_aPrimary = new ArrayList(128);
	g_aSecondary = new ArrayList(128);
	ListWeapons();

	// Create menus
	g_hMenu1 = Menu_BuildOptionsMenu(true);
	g_hMenu2 = Menu_BuildOptionsMenu(false);
	g_hMenu3 = Menu_BuildWeaponsMenu(true);
	g_hMenu4 = Menu_BuildWeaponsMenu(false);

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// weapons
	gc_sCustomCommandWeapon.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Open the weapon menu
public Action Command_Weapons(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (client != 0 && IsClientInGame(client))
		{
			if (gp_bHosties)
			{
				if (IsClientInLastRequest(client) != 0)
					return Plugin_Handled;
			}

			if (gc_iMenuMaxUsages.IntValue <= g_iMenuUsages[client] && gc_iMenuMaxUsages.IntValue != 0)
			{
				CReplyToCommand(client, "%s %t", g_sPrefix, "weapon_menu_max_usages");
				return Plugin_Handled;
			}

			g_bRememberChoice[client] = false;
			DisplayOptionsMenu(client);

			return Plugin_Handled;
		}

		return Plugin_Continue;
	}
	else CReplyToCommand(client, "%s %t", g_sPrefix, "weapons_disabled");

	return Plugin_Continue;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// On Player Spawn
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	KillAllTimer(client);

	g_iMenuUsages[client] = 0;
	g_bHealth[client] = false;
	g_bTA[client] = false;

	if (gc_bSpawn.BoolValue)
	{
		g_hTimers[client] = CreateTimer(1.0, Timer_GetWeapons, GetClientUserId(client));
	}

	if (gc_bKevlar.BoolValue && (GetClientTeam(client) == CS_TEAM_CT))
	{
		SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
	}
	
	if (!gp_bMyJailBreak)
	{
		return;
	}
	
	if (!MyJailbreak_IsEventDayRunning() && !MyJailbreak_IsEventDayPlanned())
	{
		return;
	}

	if (gc_bKevlarDays.BoolValue)
	{
		SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
	}
}

public void MyJailbreak_OnEventDayStart(char [] EventDayName)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true, false))
			continue;

		if (gc_bKevlarDays.BoolValue)
		{
			SetEntProp(i, Prop_Send, "m_ArmorValue", 100);
			SetEntProp(i, Prop_Send, "m_bHasHelmet", 1);
		}
		else
		{
			SetEntProp(i, Prop_Send, "m_ArmorValue", 0);
			SetEntProp(i, Prop_Send, "m_bHasHelmet", 0);
		}
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void GiveSavedWeaponsFix(int client)
{
	if (!gc_bEventDay.BoolValue && !MyJailbreak_IsEventDayRunning())
		return;

	if (IsPlayerAlive(client))
	{
		if (gc_bPlugin.BoolValue)
		{
			if ((g_bAllowT && GetClientTeam(client) == CS_TEAM_T) || (g_bAllowCT && GetClientTeam(client) == CS_TEAM_CT))
			{
				// StripAllPlayerWeapons(client);
				if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1)
				{
					if (StrEqual(primaryWeapon[client], "random"))
					{
						// Select random menu item (excluding "Random" option)
						int random = GetRandomInt(0, GetArraySize(g_aPrimary)-1);
						g_hWeapons Item;
						GetArrayArray(g_aPrimary, random, Item, sizeof(Item));
						GivePlayerItem(client, Item.ItemName);
					}
					else GivePlayerItem(client, primaryWeapon[client]);
				}
				if (GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
				{
					if (StrEqual(secondaryWeapon[client], "random"))
					{
						// Select random menu item (excluding "Random" option)
						int random = GetRandomInt(0, GetArraySize(g_aSecondary)-1);
						g_hWeapons Item;
						GetArrayArray(g_aSecondary, random, Item, sizeof(Item));
						GivePlayerItem(client, Item.ItemName);
					}
					else GivePlayerItem(client, secondaryWeapon[client]);
				}
				if (GetPlayerWeaponSlot(client, CS_SLOT_GRENADE) == -1) GivePlayerItem(client, "weapon_hegrenade");
			}
		}
	}
}

void SetBuyZones(const char[] status)
{
	int maxEntities = GetMaxEntities();
	char class[24];

	for (int i = MaxClients + 1; i < maxEntities; i++)
	{
		if (!IsValidEdict(i))
			continue;

		GetEdictClassname(i, class, sizeof(class));
		if (StrEqual(class, "func_buyzone"))
		{
			AcceptEntityInput(i, status);
		}

	}
}

void GiveSavedWeapons(int client)
{
	if (!gc_bEventDay.BoolValue && !MyJailbreak_IsEventDayRunning())
		return;

	if (((g_bAllowT && GetClientTeam(client) == CS_TEAM_T) || (g_bAllowCT && GetClientTeam(client) == CS_TEAM_CT)) && IsPlayerAlive(client))
	{
		g_iMenuUsages[client]++;
		
		StripAllPlayerWeapons(client);
		GivePlayerItem(client, "weapon_knife");

		if (gp_bWarden)
		{
			if (warden_iswarden(client))
			{
				if (gc_bHealthWarden.BoolValue && !g_bTA[client])
				{
					GivePlayerItem(client, "weapon_healthshot");
					CPrintToChat(client, "%s %t", g_sPrefix, "weapons_health");
					g_bTA[client] = true;
				}

				if (gc_bTAWarden.BoolValue && !g_bHealth[client])
				{
					GivePlayerItem(client, "weapon_tagrenade");
					CPrintToChat(client, "%s %t", g_sPrefix, "weapons_ta");
					g_bHealth[client] = true;
				}

				if ((g_bTaserWarden != null) && g_bTaserWarden.BoolValue)
				{
					GivePlayerItem(client, "weapon_taser");
				}

			}

			if (gp_bMyJBWarden)
			{
				if (warden_deputy_isdeputy(client))
				{
					if (gc_bHealthDeputy.BoolValue && !g_bTA[client])
					{
						GivePlayerItem(client, "weapon_healthshot");
						CPrintToChat(client, "%s %t", g_sPrefix, "weapons_health");
						g_bTA[client] = true;
					}

					if (gc_bTADeputy.BoolValue && !g_bHealth[client])
					{
						GivePlayerItem(client, "weapon_tagrenade");
						CPrintToChat(client, "%s %t", g_sPrefix, "weapons_ta");
						g_bHealth[client] = true;
					}

					if (g_bTaserDeputy.BoolValue)
					{
						GivePlayerItem(client, "weapon_taser");
					}
				}
			}
		}

		if (StrEqual(primaryWeapon[client], "random"))
		{
			// Select random menu item (excluding "Random" option)
			int random = GetRandomInt(0, GetArraySize(g_aPrimary)-1);
			g_hWeapons Item;
			GetArrayArray(g_aPrimary, random, Item, sizeof(Item));
			GivePlayerItem(client, Item.ItemName);
		}
		else GivePlayerItem(client, primaryWeapon[client]);

		if (StrEqual(secondaryWeapon[client], "random"))
		{
			// Select random menu item (excluding "Random" option)
			int random = GetRandomInt(0, GetArraySize(g_aSecondary)-1);
			g_hWeapons Item;
			GetArrayArray(g_aSecondary, random, Item, sizeof(Item));
			GivePlayerItem(client, Item.ItemName);
		}
		else GivePlayerItem(client, secondaryWeapon[client]);

		if (gc_bJBmenu.BoolValue)
		{
			FakeClientCommand(client, "sm_menu");
		}

		g_hTimers[client] = CreateTimer(6.0, Timer_Fix, GetClientUserId(client));
	}
}

void ResetClientSettings(int client)
{
	g_bWeaponsSelected[client] = false;
}

void KillAllTimer(int client)
{
	if (g_hTimers[client] != null)
	{
		KillTimer(g_hTimers[client]);
		g_hTimers[client] = null;
	}
}

void ListWeapons()
{
	ClearArray(g_aPrimary);
	ClearArray(g_aSecondary);

	g_hWeapons Items;

	Format(Items.ItemName, 64, "weapon_m4a1");
	Format(Items.desc, 64, "M4A1");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_m4a1_silencer");
	Format(Items.desc, 64, "M4A1-S");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_ak47");
	Format(Items.desc, 64, "AK-47");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_famas");
	Format(Items.desc, 64, "FAMAS");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_galilar");
	Format(Items.desc, 64, "Galil AR");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_aug");
	Format(Items.desc, 64, "AUG");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_sg556");
	Format(Items.desc, 64, "SG 553");
	PushArrayArray(g_aPrimary, Items);

	if (gc_bNegev.BoolValue)
	{
		Format(Items.ItemName, 64, "weapon_negev");
		Format(Items.desc, 64, "Negev");
		PushArrayArray(g_aPrimary, Items);
	}

	if (gc_bM249.BoolValue)
	{
		Format(Items.ItemName, 64, "weapon_m249");
		Format(Items.desc, 64, "M249");
		PushArrayArray(g_aPrimary, Items);
	}

	if (gc_bAWP.BoolValue)
	{
		Format(Items.ItemName, 64, "weapon_awp");
		Format(Items.desc, 64, "AWP");
		PushArrayArray(g_aPrimary, Items);
	}

	if (gc_bAutoSniper.BoolValue)
	{
		Format(Items.ItemName, 64, "weapon_scar20");
		Format(Items.desc, 64, "SCAR-20");
		PushArrayArray(g_aPrimary, Items);
		
		Format(Items.ItemName, 64, "weapon_g3sg1");
		Format(Items.desc, 64, "G3SG1");
		PushArrayArray(g_aPrimary, Items);
	}

	Format(Items.ItemName, 64, "weapon_bizon");
	Format(Items.desc, 64, "PP-Bizon");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_p90");
	Format(Items.desc, 64, "P90");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_ump45");
	Format(Items.desc, 64, "UMP-45");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_mp5sd");
	Format(Items.desc, 64, "MP5-SD");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_mp7");
	Format(Items.desc, 64, "MP7");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_mp9");
	Format(Items.desc, 64, "MP9");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_mac10");
	Format(Items.desc, 64, "MAC-10");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_ssg08");
	Format(Items.desc, 64, "SSG 08");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_nova");
	Format(Items.desc, 64, "Nova");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_xm1014");
	Format(Items.desc, 64, "XM1014");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_sawedoff");
	Format(Items.desc, 64, "Sawed-Off");
	PushArrayArray(g_aPrimary, Items);

	Format(Items.ItemName, 64, "weapon_mag7");
	Format(Items.desc, 64, "MAG-7");
	PushArrayArray(g_aPrimary, Items);

	// Secondary weapons
	Format(Items.ItemName, 64, "weapon_deagle");
	Format(Items.desc, 64, "Desert Eagle");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_revolver");
	Format(Items.desc, 64, "Revolver");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_tec9");
	Format(Items.desc, 64, "Tec-9");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_elite");
	Format(Items.desc, 64, "Dual Berettas");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_fiveseven");
	Format(Items.desc, 64, "Five-SeveN");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_cz75a");
	Format(Items.desc, 64, "CZ75-Auto");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_glock");
	Format(Items.desc, 64, "Glock-18");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_usp_silencer");
	Format(Items.desc, 64, "USP-S");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_p250");
	Format(Items.desc, 64, "P250");
	PushArrayArray(g_aSecondary, Items);

	Format(Items.ItemName, 64, "weapon_hkp2000");
	Format(Items.desc, 64, "P2000");
	PushArrayArray(g_aSecondary, Items);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void OnMapStart()
{
	SetBuyZones("Disable");

	g_bAllowCT = true;
	g_bAllowT = false;
}

public void OnClientPutInServer(int client)
{
	ResetClientSettings(client);
}

public void OnClientCookiesCached(int client)
{
	GetClientCookie(client, g_hWeapons1, primaryWeapon[client], 24);
	GetClientCookie(client, g_hWeapons2, secondaryWeapon[client], 24);
	g_bRememberChoice[client] = false;
}

public void OnClientDisconnect(int client)
{
	KillAllTimer(client);
	
	SetClientCookie(client, g_hWeapons1, primaryWeapon[client]);
	SetClientCookie(client, g_hWeapons2, secondaryWeapon[client]);
}

/******************************************************************************
                   MENUS
******************************************************************************/

// Menu first site - choosing mode
Handle Menu_BuildOptionsMenu(bool sameWeaponsEnabled)
{
	char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255];

	int sameWeaponsStyle = (sameWeaponsEnabled) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
	Menu menu3 = CreateMenu(Handler_BuildOptionsMenu);

	Format(info1, sizeof(info1), "%T\n ", "weapons_info_title", LANG_SERVER);
	SetMenuTitle(menu3, info1);

	SetMenuExitButton(menu3, true);

	if (gc_bCleanMenu.BoolValue)
	{
		AddMenuItem(menu3, "1", "0", ITEMDRAW_SPACER);
		AddMenuItem(menu3, "1", "0", ITEMDRAW_SPACER);
	}

	Format(info2, sizeof(info2), "%T", "weapons_info_choose", LANG_SERVER);
	AddMenuItem(menu3, "New", info2);
	Format(info3, sizeof(info3), "%T", "weapons_info_same", LANG_SERVER);
	AddMenuItem(menu3, "Same 1", info3, sameWeaponsStyle);
	Format(info4, sizeof(info4), "%T", "weapons_info_sameall", LANG_SERVER);
	AddMenuItem(menu3, "Same All", info4, sameWeaponsStyle);
	Format(info5, sizeof(info5), "%T", "weapons_info_random", LANG_SERVER);
	AddMenuItem(menu3, "Random 1", info5);
	Format(info6, sizeof(info6), "%T", "weapons_info_randomall", LANG_SERVER);
	AddMenuItem(menu3, "Random All", info6);

	return menu3;
}


// Menu Handler first site - choosing mode
public int Handler_BuildOptionsMenu(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[24];
		menu.GetItem(param2, info, sizeof(info));

		if (StrEqual(info, "New"))
		{
			g_bWeaponsSelected[client] = true;
			DisplayMenu(g_hMenu3, client, MENU_TIME_FOREVER);
			g_bRememberChoice[client] = false;
		}
		else if (StrEqual(info, "Same 1"))
		{
			g_bWeaponsSelected[client] = true;
			if (!IsPlayerAlive(client)) CPrintToChat(client, "%s %t", g_sPrefix, "weapons_next");
			else CPrintToChat(client, "%s %t", g_sPrefix, "weapons_same");
			
			GiveSavedWeapons(client);
			g_bRememberChoice[client] = false;
		}
		else if (StrEqual(info, "Same All"))
		{
			if (!IsPlayerAlive(client)) CPrintToChat(client, "%s %t", g_sPrefix, "weapons_next");
			else CPrintToChat(client, "%s %t", g_sPrefix, "weapons_sameall");
			GiveSavedWeapons(client);
			g_bRememberChoice[client] = true;
		}
		else if (StrEqual(info, "Random 1"))
		{
			g_bWeaponsSelected[client] = true;
			if (!IsPlayerAlive(client)) CPrintToChat(client, "%s %t", g_sPrefix, "weapons_next");
			else CPrintToChat(client, "%s %t", g_sPrefix, "weapons_random");
			
			primaryWeapon[client] = "random";
			secondaryWeapon[client] = "random";
			GiveSavedWeapons(client);
			g_bRememberChoice[client] = false;
		}
		else if (StrEqual(info, "Random All"))
		{
			if (!IsPlayerAlive(client)) CPrintToChat(client, "%s %t", g_sPrefix, "weapons_next");
			else CPrintToChat(client, "%s %t", g_sPrefix, "weapons_randomall");
			primaryWeapon[client] = "random";
			secondaryWeapon[client] = "random";
			GiveSavedWeapons(client);
			g_bRememberChoice[client] = true;
		}
	}
}

// Menu choose weapons
Handle Menu_BuildWeaponsMenu(bool primary)
{
	char info7[255], info8[255];
	Menu menu;
	g_hWeapons Items;

	if (primary)
	{
		menu = CreateMenu(Menu_Primary);
		Format(info7, sizeof(info7), "%T\n ", "weapons_info_prim", LANG_SERVER);
		SetMenuTitle(menu, info7);
		menu.ExitButton = true;

		for (int i=0; i<GetArraySize(g_aPrimary);++i)
		{
			GetArrayArray(g_aPrimary, i, Items, sizeof(Items));
			AddMenuItem(menu, Items.ItemName, Items.desc);
		}
	}
	else
	{
		menu = CreateMenu(Menu_Secondary);
		Format(info8, sizeof(info8), "%T\n ", "weapons_info_sec", LANG_SERVER);
		SetMenuTitle(menu, info8);
		menu.ExitButton = true;

		for (int i=0; i<GetArraySize(g_aSecondary);++i)
		{
			GetArrayArray(g_aSecondary, i, Items, sizeof(Items));
			AddMenuItem(menu, Items.ItemName, Items.desc);
		}
	}
	return menu;
}

// Menu choose primary weapons
public int Menu_Primary(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[24];

		menu.GetItem(param2, info, sizeof(info));
		primaryWeapon[client] = info;
		DisplayMenu(g_hMenu4, client, MENU_TIME_FOREVER);
	}
}

// Menu choose secondary weapons
public int Menu_Secondary(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[24];
		menu.GetItem(param2, info, sizeof(info));
		secondaryWeapon[client] = info;
		GiveSavedWeapons(client);
		if (!IsPlayerAlive(client))
			CPrintToChat(client, "%s %t", g_sPrefix, "weapons_next");
	}
}

// Check for display menu
void DisplayOptionsMenu(int client)
{
	if (!gc_bEventDay.BoolValue && !MyJailbreak_IsEventDayRunning())
		return;

	if (gc_bPlugin.BoolValue)
	{
		if ((g_bAllowT && GetClientTeam(client) == CS_TEAM_T) || (g_bAllowCT && GetClientTeam(client) == CS_TEAM_CT))
		{
			if (strcmp(primaryWeapon[client], "") == 0 || strcmp(secondaryWeapon[client], "") == 0)
				DisplayMenu(g_hMenu2, client, 30);
			else
				DisplayMenu(g_hMenu1, client, 30);
		}
	}
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Give choosed weapon timer
public Action Timer_GetWeapons(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	g_hTimers[client] = null;

	if (!gc_bEventDay.BoolValue && !MyJailbreak_IsEventDayRunning())
		return;

	if (IsClientInGame(client))
	{
		if (GetClientTeam(client) > 1 && IsPlayerAlive(client))
		{
			if (gc_bPlugin.BoolValue)
			{
				if (gc_bSpawn.BoolValue)
				{
					if ((g_bAllowT && GetClientTeam(client) == CS_TEAM_T) || (g_bAllowCT && GetClientTeam(client) == CS_TEAM_CT))
					{
						// Give weapons or display menu.
						if (g_bWeaponsSelected[client])
						{
							GiveSavedWeapons(client);
							g_bWeaponsSelected[client] = false;
						}
						else if (g_bRememberChoice[client])
						{
							GiveSavedWeapons(client);
						}
						else
						{
							DisplayOptionsMenu(client);
						}
					}
				}
			}
		}
	}
}

public Action Timer_Fix(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	g_hTimers[client] = null;

	if (IsValidClient(client, false, false))
	{
		if (GetClientTeam(client) > 1)
		{
			GiveSavedWeaponsFix(client);
		}
	}
}
