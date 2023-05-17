/*
 * MyJailbreak - Request Capitulation Module.
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
#include <mystocks>

#undef REQUIRE_PLUGIN
#include <warden>
#include <myjbwarden>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_fCapitulationTime;
ConVar gc_bCapitulation;
ConVar gc_bCapitulationAccept;
ConVar gc_fRebelTime;
ConVar gc_bCapitulationDamage;
ConVar gc_bCapitulationWeapons;
ConVar gc_iCapitulationColorRed;
ConVar gc_iCapitulationColorGreen;
ConVar gc_iCapitulationColorBlue;
ConVar gc_sSoundCapitulationPath;
ConVar gc_sCustomCommandCapitulation;

// Booleans
bool g_bCapitulated[MAXPLAYERS+1];
bool g_bHasCapitulated[MAXPLAYERS+1];

// Handles
Handle g_hTimerCapitulation[MAXPLAYERS+1];
Handle g_hTimerRebel[MAXPLAYERS+1];

// Strings
char g_sSoundCapitulationPath[256];

// Start
public void Capitulation_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_capitulation", Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");

	// AutoExecConfig
	gc_bCapitulation = AutoExecConfig_CreateConVar("sm_capitulation_enable", "1", "0 - disabled, 1 - enable Capitulation", _, true, 0.0, true, 1.0);
	gc_sCustomCommandCapitulation = AutoExecConfig_CreateConVar("sm_capitulation_cmds", "sur, surrender, capi, capitulate, pardon, p", "Set your custom chat commands for Capitulation(!capitulation (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_fCapitulationTime = AutoExecConfig_CreateConVar("sm_capitulation_timer", "10.0", "Time to decide to accept the capitulation");
	gc_fRebelTime = AutoExecConfig_CreateConVar("sm_capitulation_rebel_timer", "10.0", "Time to give a rebel on not accepted capitulation his knife back");
	gc_bCapitulationAccept = AutoExecConfig_CreateConVar("sm_capitulation_accept", "1", "0 - disabled, 1 - the warden have to accept capitulation on menu popup", _, true, 0.0, true, 1.0);
	gc_bCapitulationDamage = AutoExecConfig_CreateConVar("sm_capitulation_damage", "1", "0 - disabled, 1 - enable Terror make no damage after capitulation", _, true, 0.0, true, 1.0);
	gc_bCapitulationWeapons = AutoExecConfig_CreateConVar("sm_capitulation_weapons", "1", "0 - disabled, 1 - enable Terror can not pick up weapons after capitulation", _, true, 0.0, true, 1.0);
	gc_iCapitulationColorRed = AutoExecConfig_CreateConVar("sm_capitulation_color_red", "0", "What color to turn the capitulation Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iCapitulationColorGreen = AutoExecConfig_CreateConVar("sm_capitulation_color_green", "250", "What color to turn the capitulation Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iCapitulationColorBlue = AutoExecConfig_CreateConVar("sm_capitulation_color_blue", "0", "What color to turn the capitulation Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sSoundCapitulationPath = AutoExecConfig_CreateConVar("sm_capitulation_sound", "music/MyJailbreak/capitulation.mp3", "Path to the soundfile which should be played for a capitulation.");

	// Hooks 
	HookEvent("round_start", Capitulation_Event_RoundStart);
	HookConVarChange(gc_sSoundCapitulationPath, Capitulation_OnSettingChanged);

	// FindConVar
	gc_sSoundCapitulationPath.GetString(g_sSoundCapitulationPath, sizeof(g_sSoundCapitulationPath));
}


public void Capitulation_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sSoundCapitulationPath)
	{
		strcopy(g_sSoundCapitulationPath, sizeof(g_sSoundCapitulationPath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
		}
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_Capitulation(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bCapitulation.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
			{
				if (!g_bCapitulated[client] && !g_bHasCapitulated[client])
				{
					if ((gp_bWarden || gp_bMyJBWarden) && gc_bCapitulationAccept.BoolValue)
					{
						if (warden_exist() && !g_bIsRequest)
						{
							g_bIsRequest = true;
							g_hTimerRequest = CreateTimer (gc_fCapitulationTime.FloatValue, Timer_IsRequest);
							g_bCapitulated[client] = true;
							CPrintToChatAll("%s %t", g_sPrefix, "request_capitulation", client);
							
							float DoubleTime = (gc_fRebelTime.FloatValue * 2);
							g_hTimerRebel[client] = CreateTimer(DoubleTime, Timer_RebelNoAction, GetClientUserId(client));
						// 	StripAllPlayerWeapons(client);
							for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) Menu_CapitulationMenu(i);
							if (gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundCapitulationPath);
						}
						else CReplyToCommand(client, "%s %t", g_sPrefix, "request_processing");
					}
					else if (!gc_bCapitulationAccept.BoolValue)
					{
						StripAllPlayerWeapons(client);
						SetEntityRenderColor(client, gc_iCapitulationColorRed.IntValue, gc_iCapitulationColorGreen.IntValue, gc_iCapitulationColorBlue.IntValue, 255);
						g_hTimerCapitulation[client] = CreateTimer(gc_fCapitulationTime.FloatValue, Timer_GiveKnifeCapitulated, GetClientUserId(client));
						CPrintToChatAll("%s %t", g_sPrefix, "request_capitulated", client);
						ChangeRebelStatus(client, false);
					}
					else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_noexist");
				}
				else CReplyToCommand(client, "%s %t", g_sPrefix, "request_alreadycapitulated");
			}
			else CReplyToCommand(client, "%s %t", g_sPrefix, "request_notalivect");
		}
	}
	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Capitulation_Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		delete g_hTimerCapitulation[i];
		delete g_hTimerRebel[i];

		g_bCapitulated[i] = false;
		g_bHasCapitulated[i] = false;
	}
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void Capitulation_OnMapStart()
{
	if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
		}
}

public void Capitulation_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Capitulation
	gc_sCustomCommandCapitulation.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
			RegConsoleCmd(sCommand, Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
	}
}

public void Capitulation_OnClientPutInServer(int client)
{
	g_bCapitulated[client] = false;
	g_bHasCapitulated[client] = false;

	SDKHook(client, SDKHook_WeaponCanUse, Capitulation_OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, Capitulation_OnTakedamage);
}

public void Capitulation_OnClientDisconnect(int client)
{
	delete g_hTimerRebel[client];
	delete g_hTimerCapitulation[client];
}

public Action Capitulation_OnWeaponCanUse(int client, int weapon)
{
	if (g_bCapitulated[client] || g_bHasCapitulated[client] && gc_bCapitulationWeapons.BoolValue)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		
		if (!StrEqual(sWeapon, "weapon_knife") && !StrEqual(sWeapon, "weapon_healthshot") && !StrEqual(sWeapon, "weapon_c4"))
		{
			if (IsValidClient(client, true, false))
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public Action Capitulation_OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidClient(attacker, true, false) && GetClientTeam(attacker) == CS_TEAM_T && IsPlayerAlive(attacker))
	{
		if ((g_bCapitulated[attacker] || g_bHasCapitulated[attacker]) && gc_bCapitulationDamage.BoolValue && !IsClientInLastRequest(attacker))
		{
			CPrintToChat(attacker, "%s %t", g_sPrefix, "request_nodamage");
			
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public void Capitulation_OnAvailableLR(int Announced)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_bCapitulated[i] = false;
		g_bHasCapitulated[i] = false;
	}
}

/******************************************************************************
                   MENUS
******************************************************************************/

public Action Menu_CapitulationMenu(int warden)
{
	if (warden_iswarden(warden))
	{
		char info5[255], info6[255], info7[255];
		Menu menu1 = CreateMenu(Handler_CapitulationMenu);
		Format(info5, sizeof(info5), "%T", "request_acceptcapitulation", warden);
		menu1.SetTitle(info5);
		Format(info6, sizeof(info6), "%T", "warden_no", warden);
		Format(info7, sizeof(info7), "%T", "warden_yes", warden);
		menu1.AddItem("1", info7);
		menu1.AddItem("0", info6);
		menu1.Display(warden, gc_fCapitulationTime.IntValue);
	}
}

public int Handler_CapitulationMenu(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);
		if (choice == 1)  // yes
		{
			for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (g_bCapitulated[i])
			{
				g_bIsRequest = false;
				if (g_hTimerRequest != null)
					KillTimer(g_hTimerRequest);
				g_hTimerRequest = null;
				if (g_hTimerRebel[i] != null)
					KillTimer(g_hTimerRebel[i]);
				g_bHasCapitulated[i] = true;
				g_bCapitulated[i] = false;
				g_hTimerRebel[i] = null;
				StripAllPlayerWeapons(i);
				SetEntityRenderColor(client, gc_iCapitulationColorRed.IntValue, gc_iCapitulationColorGreen.IntValue, gc_iCapitulationColorBlue.IntValue, 255);
				g_hTimerCapitulation[i] = CreateTimer(gc_fCapitulationTime.FloatValue, Timer_GiveKnifeCapitulated, GetClientUserId(i));
				CPrintToChatAll("%s %t", g_sPrefix, "request_capitulated", i, client);
				ChangeRebelStatus(i, false);
			}
		}
		if (choice == 0)  // no
		{
			for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (g_bCapitulated[i])
			{
				g_bIsRequest = false;
				if (g_hTimerRequest != null)
					KillTimer(g_hTimerRequest);
				g_hTimerRequest = null;
				SetEntityRenderColor(i, 255, 0, 0, 255); // todo
				g_bCapitulated[i] = false;
				if (g_hTimerRebel[i] != null)
					KillTimer(g_hTimerRebel[i]);
				g_hTimerRebel[i] = null;
				CPrintToChatAll("%s %t", g_sPrefix, "request_noaccepted", i, client);
				ChangeRebelStatus(i, true);
			}
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

public Action Timer_GiveKnifeCapitulated(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client,true,false))
	{
		GivePlayerItem(client, "weapon_knife");
		CPrintToChat(client, "%s %t", g_sPrefix, "request_knifeback");
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}

	g_hTimerCapitulation[client] = null;
}

public Action Timer_RebelNoAction(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client,true,false))
	{
		SetEntityRenderColor(client, 255, 0, 0, 255);
	}

	g_bCapitulated[client] = false;
	g_hTimerRebel[client] = null;
}