/*  CS:GO Weapons&Knives SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <PTaH>
#include <weapons>

#pragma semicolon 1
#pragma newdecls required

#include "weapons/globals.sp"
#include "weapons/forwards.sp"
#include "weapons/hooks.sp"
#include "weapons/helpers.sp"
#include "weapons/database.sp"
#include "weapons/config.sp"
#include "weapons/menus.sp"
#include "weapons/natives.sp"

//#define DEBUG

public Plugin myinfo = 
{
	name = "Weapons & Knives",
	author = "kgns | oyunhost.net",
	description = "All in one weapon skin management",
	version = "1.7.1",
	url = "https://www.oyunhost.net"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("weapons");

	CreateNative("Weapons_SetClientKnife", Weapons_SetClientKnife_Native);
	CreateNative("Weapons_GetClientKnife", Weapons_GetClientKnife_Native);
	
	g_hOnKnifeSelect_Pre = CreateGlobalForward("Weapons_OnClientKnifeSelectPre", ET_Event, Param_Cell, Param_Cell, Param_String);
	g_hOnKnifeSelect_Post = CreateGlobalForward("Weapons_OnClientKnifeSelectPost", ET_Ignore, Param_Cell, Param_Cell, Param_String);
	return APLRes_Success;
}

public void OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Only CS:GO servers are supported!");
		return;
	}
	
	if(PTaH_Version() < 101000)
	{
		char sBuf[16];
		PTaH_Version(sBuf, sizeof(sBuf));
		SetFailState("PTaH extension needs to be updated. (Installed Version: %s - Required Version: 1.1.0+) [ Download from: https://ptah.zizt.ru ]", sBuf);
		return;
	}
	
	LoadTranslations("weapons.phrases");
	
	g_Cvar_DBConnection 			= CreateConVar("sm_weapons_db_connection", 			"storage-local", 	"Database connection name in databases.cfg to use");
	g_Cvar_TablePrefix 			= CreateConVar("sm_weapons_table_prefix", 			"", 				"Prefix for database table (example: 'xyz_')");
	g_Cvar_ChatPrefix 			= CreateConVar("sm_weapons_chat_prefix", 			"[oyunhost.net]", 	"Prefix for chat messages");
	g_Cvar_KnifeStatTrakMode 		= CreateConVar("sm_weapons_knife_stattrak_mode", 	"0", 				"0: All knives show the same StatTrak counter (total knife kills) 1: Each type of knife shows its own separate StatTrak counter");
	g_Cvar_EnableFloat 			= CreateConVar("sm_weapons_enable_float", 			"1", 				"Enable/Disable weapon float options");
	g_Cvar_EnableNameTag 			= CreateConVar("sm_weapons_enable_nametag", 		"1", 				"Enable/Disable name tag options");
	g_Cvar_EnableStatTrak 			= CreateConVar("sm_weapons_enable_stattrak", 		"1", 				"Enable/Disable StatTrak options");
	g_Cvar_EnableSeed				= CreateConVar("sm_weapons_enable_seed",			"1",				"Enable/Disable Seed options");
	g_Cvar_FloatIncrementSize 		= CreateConVar("sm_weapons_float_increment_size", 	"0.05", 			"Increase/Decrease by value for weapon float");
	g_Cvar_EnableWeaponOverwrite 	= CreateConVar("sm_weapons_enable_overwrite", 		"1", 				"Enable/Disable players overwriting other players' weapons (picked up from the ground) by using !ws command");
	g_Cvar_GracePeriod 			= CreateConVar("sm_weapons_grace_period", 			"0", 				"Grace period in terms of seconds counted after round start for allowing the use of !ws command. 0 means no restrictions");
	g_Cvar_InactiveDays 			= CreateConVar("sm_weapons_inactive_days", 			"30", 				"Number of days before a player (SteamID) is marked as inactive and his data is deleted. (0 or any negative value to disable deleting)");
	
	AutoExecConfig(true, "weapons");
	
	RegConsoleCmd("buyammo1", CommandWeaponSkins);
	RegConsoleCmd("sm_ws", CommandWeaponSkins);
	RegConsoleCmd("buyammo2", CommandKnife);
	RegConsoleCmd("sm_knife", CommandKnife);
	RegConsoleCmd("sm_nametag", CommandNameTag);
	RegConsoleCmd("sm_wslang", CommandWSLang);
	RegConsoleCmd("sm_seed", CommandSeedMenu);
	
	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, GiveNamedItemPost);
	
	ConVar g_cvGameType = FindConVar("game_type");
	ConVar g_cvGameMode = FindConVar("game_mode");
	
	if(g_cvGameType.IntValue == 1 && g_cvGameMode.IntValue == 2)
	{
		PTaH(PTaH_WeaponCanUsePre, Hook, WeaponCanUsePre);
	}
	
	AddCommandListener(ChatListener, "say");
	AddCommandListener(ChatListener, "say2");
	AddCommandListener(ChatListener, "say_team");

	#if defined DEBUG
	RegAdminCmd("sm_setknife", Command_SetKnife, ADMFLAG_ROOT, "Sets knife of specific player.");
	RegAdminCmd("sm_getknife", Command_GetClientKnife, ADMFLAG_ROOT, "Gets specific player's knife class name.");
	#endif
	
	for(int i = 0; i < sizeof(g_iWeaponSeed); i++)
	{
		for(int j = 0; j < sizeof(g_iWeaponSeed[]); j++)
		{
			g_iWeaponSeed[i][j] = -1;
		}
	}
}

#if defined DEBUG
public Action Command_SetKnife(int client, int args)
{
	if(args != 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setknife <playername> <weaponname>");
		return Plugin_Handled;
	}
	char buffer[64];
	GetCmdArg(1, buffer, sizeof(buffer));
	int target = FindTarget(client, buffer);
	if(target == -1)
	{
		ReplyToCommand(client, "[SM] Please enter valid playername!");
		return Plugin_Handled;
	}
	GetCmdArg(2, buffer, sizeof(buffer));
	if(SetClientKnife(target, buffer) == -1)
	{
		ReplyToCommand(client, "[SM] Knife %s is not valid.", buffer);
		return Plugin_Handled;
	}
	ReplyToCommand(client, "[SM] Successfully set %N's knife.", target);
	return Plugin_Handled;
}

public Action Command_GetClientKnife(int client, int args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_getknife <playername>");
		return Plugin_Handled;
	}
	char buffer[32];
	GetCmdArg(1, buffer, sizeof(buffer));
	int target = FindTarget(client, buffer);
	if(target == -1)
	{
		ReplyToCommand(client, "[SM] Please enter valid playername!");
		return Plugin_Handled;
	}
	char sKnife[64];
	GetClientKnife(client, sKnife, sizeof(sKnife));
	ReplyToCommand(client, "[SM] %N's knife is %s.", target, sKnife);
	return Plugin_Handled;
}
#endif

public Action CommandWeaponSkins(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateMainMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandSeedMenu(int client, int args)
{
	if(!g_bEnableSeed)
	{
		ReplyToCommand(client, " %s \x02%T", g_ChatPrefix, "SeedDisabled", client);
		return Plugin_Handled;
	}
	ReplyToCommand(client, " %s \x04%T", g_ChatPrefix, "SeedExplanation", client);
	return Plugin_Handled;
}

public Action CommandKnife(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateKnifeMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandWSLang(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateLanguageMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandNameTag(int client, int args)
{
	if(!g_bEnableNameTag)
	{
		ReplyToCommand(client, " %s \x02%T", g_ChatPrefix, "NameTagDisabled", client);
		return Plugin_Handled;
	}
	ReplyToCommand(client, " %s \x04%T", g_ChatPrefix, "NameTagNew", client);
	return Plugin_Handled;
}

void SetWeaponProps(int client, int entity)
{
	int index = GetWeaponIndex(entity);
	if (index > -1 && g_iSkins[client][index] != 0)
	{
		static int IDHigh = 16384;
		SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);
		SetEntProp(entity, Prop_Send, "m_iItemIDHigh", IDHigh++);
		SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", g_iSkins[client][index] == -1 ? GetRandomSkin(client, index) : g_iSkins[client][index]);
		SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", !g_bEnableFloat || g_fFloatValue[client][index] == 0.0 ? 0.000001 : g_fFloatValue[client][index] == 1.0 ? 0.999999 : g_fFloatValue[client][index]);
		if (g_bEnableSeed && g_iWeaponSeed[client][index] != -1)
		{
			SetEntProp(entity, Prop_Send, "m_nFallbackSeed", g_iWeaponSeed[client][index]);
		}
		else
		{
			g_iSeedRandom[client][index] = GetRandomInt(0, 8192);
			SetEntProp(entity, Prop_Send, "m_nFallbackSeed", g_iSeedRandom[client][index]);
		}
		
		if(!IsKnife(entity))
		{
			if(g_bEnableStatTrak)
			{
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 1 ? g_iStatTrakCount[client][index] : -1);
				SetEntProp(entity, Prop_Send, "m_iEntityQuality", g_iStatTrak[client][index] == 1 ? 9 : 0);
			}
		}
		else
		{
			if(g_bEnableStatTrak)
			{
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 0 ? -1 : g_iKnifeStatTrakMode == 0 ? GetTotalKnifeStatTrakCount(client) : g_iStatTrakCount[client][index]);
			}
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 3);
		}
		if (g_bEnableNameTag && strlen(g_NameTag[client][index]) > 0)
		{
			SetEntDataString(entity, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), g_NameTag[client][index], 128);
		}
		SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);
	}
}

void RefreshWeapon(int client, int index, bool defaultKnife = false)
{
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	
	for (int i = 0; i < size; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if (IsValidWeapon(weapon))
		{
			bool isKnife = IsKnife(weapon);
			if ((!defaultKnife && GetWeaponIndex(weapon) == index) || (isKnife && (defaultKnife || IsKnifeClass(g_WeaponClasses[index]))))
			{
				if(!g_bOverwriteEnabled)
				{
					int previousOwner;
					if ((previousOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && previousOwner != client)
					{
						return;
					}
				}
				
				int clip = -1;
				int ammo = -1;
				int offset = -1;
				int reserve = -1;
				
				if (!isKnife)
				{
					offset = FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
					ammo = GetEntData(client, offset);
					clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
					reserve = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
				}
				
				RemovePlayerItem(client, weapon);
				AcceptEntityInput(weapon, "KillHierarchy");
				
				if (!isKnife)
				{
					weapon = GivePlayerItem(client, g_WeaponClasses[index]);
					if (clip != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
					}
					if (reserve != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", reserve);
					}
					if (offset != -1 && ammo != -1)
					{
						DataPack pack;
						CreateDataTimer(0.1, ReserveAmmoTimer, pack);
						pack.WriteCell(GetClientUserId(client));
						pack.WriteCell(offset);
						pack.WriteCell(ammo);
					}
				}
				else
				{
					GivePlayerItem(client, "weapon_knife");
				}
				break;
			}
		}
	}
}

public Action ReserveAmmoTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientIndex = GetClientOfUserId(pack.ReadCell());
	int offset = pack.ReadCell();
	int ammo = pack.ReadCell();
	
	if(clientIndex > 0 && IsClientInGame(clientIndex))
	{
		SetEntData(clientIndex, offset, ammo, 4, true);
	}
}
