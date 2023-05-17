/*
 * MyJailbreak - Warden - Handcuffs Module.
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
#include <emitsoundany>
#include <warden>
#include <myjbwarden>
#include <mystocks>


//Optional Plugins
#undef REQUIRE_PLUGIN
#include <hosties>
#include <lastrequest>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bHandCuff;
ConVar gc_bHandCuffDeputy;
ConVar gc_iHandCuffsNumber;
ConVar gc_iHandCuffsDistance;
ConVar gc_bHandCuffLR;
ConVar gc_bHandCuffCT;
ConVar gc_sAdminFlagCuffs;
ConVar gc_sSoundBreakCuffsPath;
ConVar gc_sSoundUnLockCuffsPath;
ConVar gc_sSoundCuffsPath;
ConVar gc_sOverlayCuffsPath;
ConVar gc_fUnLockTimeMax;
ConVar gc_fUnLockTimeMin;
ConVar gc_iPaperClipUnLockChance;
ConVar gc_iPaperClipGetChance;
ConVar gc_iCuffedColorRed;
ConVar gc_iCuffedColorGreen;
ConVar gc_iCuffedColorBlue;

// Booleans
bool g_bCuffed[MAXPLAYERS+1] = false;

// Integers
int g_iPlayerHandCuffs[MAXPLAYERS+1];
int g_iPlayerPaperClips[MAXPLAYERS+1];
int g_iCuffed = 0;
int TickTime[MAXPLAYERS+1];

// Strings
char g_sSoundCuffsPath[256];
char g_sOverlayCuffsPath[256];
char g_sSoundBreakCuffsPath[256];
char g_sSoundUnLockCuffsPath[256];
char g_sEquipWeapon[MAXPLAYERS+1][32];

// Handles
Handle BreakTimer[MAXPLAYERS+1];
Handle ProgressTimer[MAXPLAYERS+1];

// Info
public void HandCuffs_OnPluginStart()
{
	// AutoExecConfig
	gc_bHandCuff = AutoExecConfig_CreateConVar("sm_warden_handcuffs", "1", "0 - disabled, 1 - enable handcuffs", _, true, 0.0, true, 1.0);
	gc_bHandCuffDeputy = AutoExecConfig_CreateConVar("sm_warden_handcuffs_deputy", "1", "0 - disabled, 1 - enable handcuffs for deputy, too", _, true, 0.0, true, 1.0);
	gc_iHandCuffsNumber = AutoExecConfig_CreateConVar("sm_warden_handcuffs_number", "2", "How many handcuffs a warden got?", _, true, 1.0);
	gc_iHandCuffsDistance = AutoExecConfig_CreateConVar("sm_warden_handcuffs_distance", "2", "How many meters distance from warden to handcuffed T to pick up?", _, true, 1.0);
	gc_bHandCuffLR = AutoExecConfig_CreateConVar("sm_warden_handcuffs_lr", "1", "0 - disabled, 1 - free cuffed terrorists on LR", _, true, 0.0, true, 1.0);
	gc_bHandCuffCT = AutoExecConfig_CreateConVar("sm_warden_handcuffs_ct", "1", "0 - disabled, 1 - Warden can also handcuff CTs", _, true, 0.0, true, 1.0);
	gc_sAdminFlagCuffs = AutoExecConfig_CreateConVar("sm_warden_handcuffs_flag", "", "Set flag for admin/vip must have to get access to lockpicking feature. No flag = lockpicking is available for all players!");
	gc_fUnLockTimeMax = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_maxtime", "35.0", "Time in seconds Ts need free themself with a paperclip.", _, true, 0.1);
	gc_iPaperClipGetChance = AutoExecConfig_CreateConVar("sm_warden_handcuffs_paperclip_chance", "5", "Set the chance (1:x) a cuffed Terroris get a paperclip to free themself", _, true, 1.0);
	gc_iPaperClipUnLockChance = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_chance", "3", "Set the chance (1:x) a cuffed Terroris who has a paperclip to free themself", _, true, 1.0);
	gc_fUnLockTimeMin = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_mintime", "15.0", "Min. Time in seconds Ts need free themself with a paperclip.", _, true, 1.0);
	gc_fUnLockTimeMax = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_maxtime", "35.0", "Max. Time in seconds Ts need free themself with a paperclip.", _, true, 1.0);
	gc_sOverlayCuffsPath = AutoExecConfig_CreateConVar("sm_warden_overlays_cuffs", "overlays/MyJailbreak/cuffs", "Path to the cuffs Overlay DONT TYPE .vmt or .vft");
	gc_sSoundCuffsPath = AutoExecConfig_CreateConVar("sm_warden_sounds_cuffs", "music/MyJailbreak/cuffs.mp3", "Path to the soundfile which should be played for cuffed player.");
	gc_sSoundBreakCuffsPath = AutoExecConfig_CreateConVar("sm_warden_sounds_breakcuffs", "music/MyJailbreak/breakcuffs.mp3", "Path to the soundfile which should be played for break cuffs.");
	gc_sSoundUnLockCuffsPath = AutoExecConfig_CreateConVar("sm_warden_sounds_unlock", "music/MyJailbreak/unlock.mp3", "Path to the soundfile which should be played for unlocking cuffs.");
	gc_iCuffedColorRed = AutoExecConfig_CreateConVar("sm_warden_color_cuffs_red", "0", "What color to turn the cuffed player into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iCuffedColorGreen = AutoExecConfig_CreateConVar("sm_warden_color_cuffs_green", "190", "What color to turn the cuffed player into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iCuffedColorBlue = AutoExecConfig_CreateConVar("sm_warden_color_cuffs_blue", "120", "What color to turn the cuffed player into (rgB): x - blue value", _, true, 0.0, true, 255.0);

	// Hooks
	HookEvent("round_start", HandCuffs_Event_RoundStart);
	HookEvent("round_end", HandCuffs_Event_RoundEnd);
	HookEvent("player_death", HandCuffs_Event_PlayerTeamDeath);
	HookEvent("player_team", HandCuffs_Event_PlayerTeamDeath);
	HookEvent("item_equip", HandCuffs_Event_ItemEquip);
	HookEvent("weapon_fire", HandCuffs_Event_WeaponFire);
	HookConVarChange(gc_sSoundCuffsPath, HandCuffs_OnSettingChanged);
	HookConVarChange(gc_sSoundBreakCuffsPath, HandCuffs_OnSettingChanged);
	HookConVarChange(gc_sSoundUnLockCuffsPath, HandCuffs_OnSettingChanged);
	HookConVarChange(gc_sOverlayCuffsPath, HandCuffs_OnSettingChanged);

	// FindConVar
	gc_sSoundCuffsPath.GetString(g_sSoundCuffsPath, sizeof(g_sSoundCuffsPath));
	gc_sSoundBreakCuffsPath.GetString(g_sSoundBreakCuffsPath, sizeof(g_sSoundBreakCuffsPath));
	gc_sSoundUnLockCuffsPath.GetString(g_sSoundUnLockCuffsPath, sizeof(g_sSoundUnLockCuffsPath));
	gc_sOverlayCuffsPath.GetString(g_sOverlayCuffsPath, sizeof(g_sOverlayCuffsPath));
}

public void HandCuffs_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sSoundCuffsPath)
	{
		strcopy(g_sSoundCuffsPath, sizeof(g_sSoundCuffsPath), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundCuffsPath);
		}
	}
	else if (convar == gc_sSoundBreakCuffsPath)
	{
		strcopy(g_sSoundBreakCuffsPath, sizeof(g_sSoundBreakCuffsPath), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundBreakCuffsPath);
		}
	}
	else if (convar == gc_sSoundUnLockCuffsPath)
	{
		strcopy(g_sSoundUnLockCuffsPath, sizeof(g_sSoundUnLockCuffsPath), newValue);

		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundUnLockCuffsPath);
		}
	}
	else if (convar == gc_sOverlayCuffsPath)
	{
		strcopy(g_sOverlayCuffsPath, sizeof(g_sOverlayCuffsPath), newValue);

		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayCuffsPath);
		}
	}
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void HandCuffs_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bHandCuff.BoolValue)
		return;

	if (!g_bIsLR && gc_bStayWarden.BoolValue)
	{
		if (g_iWarden != -1) GivePlayerItem(g_iWarden, "weapon_taser");
		if (g_iDeputy != -1) GivePlayerItem(g_iDeputy, "weapon_taser");
	}

	g_iCuffed = 0;

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_iPlayerHandCuffs[i] = gc_iHandCuffsNumber.IntValue;
		g_bCuffed[i] = false;
		g_iPlayerPaperClips[i] = 0;
	}
}

public void HandCuffs_Event_ItemEquip(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bHandCuff.BoolValue)
		return;

	int client = GetClientOfUserId(event.GetInt("userid"));

	char weapon[32];
	event.GetString("item", weapon, sizeof(weapon));
	g_sEquipWeapon[client] = weapon;

	if (StrEqual(weapon, "taser") && (IsClientWarden(client) || (IsClientDeputy(client) && gc_bHandCuffDeputy.BoolValue)) && (g_iPlayerHandCuffs[client] != 0))
	{
		PrintCenterText(client, "%t", "warden_cuffs");
	}
}

public void HandCuffs_Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bHandCuff.BoolValue)
		return;

	int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

	if (g_bCuffed[client])
	{
		g_iCuffed--;
		g_bCuffed[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		CreateTimer(0.0, DeleteOverlay, GetClientUserId(client));
	}
}

public void HandCuffs_Event_WeaponFire(Event event, char[] name, bool dontBroadcast)
{
	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bHandCuff.BoolValue)
		return;

	int client = GetClientOfUserId(event.GetInt("userid"));

	if ((IsClientWarden(client) || (IsClientDeputy(client) && gc_bHandCuffDeputy.BoolValue)) && ((g_iPlayerHandCuffs[client] != 0) || ((g_iPlayerHandCuffs[client] == 0) && (g_iCuffed > 0))))
	{
		char sWeapon[64];
		event.GetString("weapon", sWeapon, sizeof(sWeapon));

		if (StrEqual(sWeapon, "weapon_taser"))
		{
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			SetEntProp(weapon, Prop_Data, "m_iClip1", 2);
		}
	}
}

public void HandCuffs_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (g_bCuffed[i]) 
	{
		FreeEm(i, 0);
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public Action HandCuffs_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (buttons & IN_ATTACK2)
	{
		if (gc_bHandCuff.BoolValue && (StrEqual(g_sEquipWeapon[client], "taser")) && (IsClientWarden(client) || (IsClientDeputy(client) && gc_bHandCuffDeputy.BoolValue)))
		{
			int Target = GetClientAimTarget(client, true);
			
			if (IsValidClient(Target, true, false) && g_bCuffed[Target])
			{
				float distance = 0.0;
				
				float clientOrigin[3];
				float targetOrigin[3];
				GetClientAbsOrigin(client, clientOrigin);
				GetClientAbsOrigin(Target, targetOrigin);
				distance = GetVectorDistance(clientOrigin, targetOrigin, false) * 0.01905;  // 0.01905 GAMEUNITS_TO_METERS
				
				if ((gc_iHandCuffsDistance.IntValue > distance) && !IsLookingAtWall(client, GetDistance(client, Target)+40.0))
				{
					float origin[3];
					GetClientAbsOrigin(client, origin);
					float location[3];
					GetClientEyePosition(client, location);
					float ang[3];
					GetClientEyeAngles(client, ang);
					float location2[3];

					location2[0] = (location[0]+(100*((Cosine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
					location2[1] = (location[1]+(100*((Sine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
					ang[0] -= (2*ang[0]);
					location2[2] = origin[2] += 5.0;

					TeleportEntity(Target, location2, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}

	if (g_bCuffed[client])
	{
		for (int i = 0; i < MAX_BUTTONS; i++)
		{
			int button = (1 << i);
			
			if ((buttons & button))
			{
				if (!(g_iLastButtons[client] & button))
				{
					OnButtonPress2(client, button);
				}
			}
			else if ((g_iLastButtons[client] & button))
			{
				OnButtonRelease2(client, button);
			}
		}
		g_iLastButtons[client] = buttons;
	}
}

public void OnButtonPress2(int client, int button)
{
	if (button == IN_USE)
	{
		if (g_iPlayerPaperClips[client] > 0)
		{
			float unlocktime = GetRandomFloat(gc_fUnLockTimeMin.FloatValue, gc_fUnLockTimeMax.FloatValue);
			BreakTimer[client] = CreateTimer(unlocktime, Timer_BreakTheseCuffs, client);
			TickTime[client] = 0;
			ProgressTimer[client] = CreateTimer(unlocktime/14, Timer_Progress, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			if (gc_bSounds) EmitSoundToClientAny(client, g_sSoundUnLockCuffsPath);
		}
	}
}

public void OnButtonRelease2(int client, int button)
{
	if (button == IN_USE)
	{
		if (BreakTimer[client] != null)
		{
			KillTimer(BreakTimer[client]);
			BreakTimer[client] = null;
		}
		if (ProgressTimer[client] != null)
		{
			KillTimer(ProgressTimer[client]);
			ProgressTimer[client] = null;
			PrintCenterText(client, "%t", "warden_pickingaborted");
		}
		if (gc_bSounds) StopSoundAny(client, SNDCHAN_AUTO, g_sSoundUnLockCuffsPath);
		
	}
}

public Action HandCuffs_OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false))
		return Plugin_Continue;

	if (!gc_bPlugin.BoolValue || !g_bEnabled || !gc_bHandCuff.BoolValue)
		return Plugin_Continue;

	if (g_bCuffed[attacker])
		return Plugin_Handled;

	if ((!IsClientWarden(attacker) && !IsClientDeputy(attacker)) || (IsClientDeputy(attacker) && !gc_bHandCuffDeputy.BoolValue) || !IsValidEdict(weapon) || (!gc_bHandCuffCT.BoolValue && (GetClientTeam(victim) == CS_TEAM_CT)))
		return Plugin_Continue;

	char sWeapon[32];
	if (IsValidEntity(weapon)) GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));

	if (!StrEqual(sWeapon, "weapon_taser"))
		return Plugin_Continue;

	if ((g_iPlayerHandCuffs[attacker] == 0) && (g_iCuffed == 0))
		return Plugin_Continue;

	if (g_bCuffed[victim])
	{
		FreeEm(victim, attacker);
	}
	else CuffsEm(victim, attacker);

	return Plugin_Handled;
}

public void HandCuffs_OnAvailableLR(int Announced)
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		g_iPlayerHandCuffs[i] = 0;

		if (gc_bHandCuffLR.BoolValue && g_bCuffed[i])
		{
			FreeEm(i, 0);
		}
	}

	StripZeus(g_iWarden);
	StripZeus(g_iDeputy);
}

public void HandCuffs_OnWardenCreation(int client)
{
	if (gc_bHandCuff.BoolValue && !g_bIsLR) GivePlayerItem(client, "weapon_taser");
}

public void HandCuffs_OnWardenRemoved(int client)
{
	StripZeus(client);
}

public void HandCuffs_OnDeputyCreation(int client)
{
	if (gc_bHandCuff.BoolValue && !g_bIsLR) GivePlayerItem(client, "weapon_taser");
}

public void HandCuffs_OnDeputyRemoved(int client)
{
	StripZeus(client);
}

public void HandCuffs_OnMapStart()
{
	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundCuffsPath);
		PrecacheSoundAnyDownload(g_sSoundBreakCuffsPath);
		PrecacheSoundAnyDownload(g_sSoundUnLockCuffsPath);
	}
	if (gc_bOverlays.BoolValue)
		PrecacheDecalAnyDownload(g_sOverlayCuffsPath);
}

public void HandCuffs_OnClientDisconnect(int client)
{
	if (g_bCuffed[client])
		g_iCuffed--;

	g_iLastButtons[client] = 0;

	if (BreakTimer[client] != null)
	{
		KillTimer(BreakTimer[client]);
		BreakTimer[client] = null;
	}

	if (ProgressTimer[client] != null)
	{
		KillTimer(ProgressTimer[client]);
		ProgressTimer[client] = null;
	}
}


public void HandCuffs_OnMapEnd()
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		if (g_bCuffed[i])
		{
			FreeEm(i, 0);
		}

		if (BreakTimer[i] != null)
		{
			KillTimer(BreakTimer[i]);
			BreakTimer[i] = null;
		}

		if (ProgressTimer[i] != null)
		{
			KillTimer(ProgressTimer[i]);
			ProgressTimer[i] = null;
		}
	}
}

public void HandCuffs_OnClientPutInServer(int client)
{
	g_iPlayerPaperClips[client] = 0;
	SDKHook(client, SDKHook_OnTakeDamage, HandCuffs_OnTakedamage);
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void CuffsEm(int client, int attacker)
{
	if (g_iPlayerHandCuffs[attacker] > 0)
	{
		SetEntityMoveType(client, MOVETYPE_NONE);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		SetEntityRenderColor(client, gc_iCuffedColorRed.IntValue, gc_iCuffedColorGreen.IntValue, gc_iCuffedColorBlue.IntValue, 255);
		StripAllPlayerWeapons(client);
		GivePlayerItem(client, "weapon_knife");
		g_bCuffed[client] = true;
		ShowOverlay(client, g_sOverlayCuffsPath, 0.0);
		g_iPlayerHandCuffs[attacker]--;
		g_iCuffed++;
		if (gc_bSounds)EmitSoundToAllAny(g_sSoundCuffsPath);

		CPrintToChatAll("%s %t", g_sPrefix, "warden_cuffson", attacker, client);
		CPrintToChat(attacker, "%s %t", g_sPrefix, "warden_cuffsgot", g_iPlayerHandCuffs[attacker]);
		if (MyJB_CheckVIPFlags(client, "sm_warden_handcuffs_flag", gc_sAdminFlagCuffs, "sm_warden_handcuffs_flag"))
		{
			CreateTimer (2.5, Timer_HasPaperClip, client);
		}
	}
}

void FreeEm(int client, int attacker)
{
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	g_bCuffed[client] = false;
	CreateTimer(0.0, DeleteOverlay, GetClientUserId(client));
	g_iCuffed--;
	ProgressTimer[client] = null;

	if (gc_bSounds)StopSoundAny(client, SNDCHAN_AUTO, g_sSoundUnLockCuffsPath);
	if ((attacker != 0) && (g_iCuffed == 0) && (g_iPlayerHandCuffs[attacker] < 1))
	{
		int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
		SetEntProp(weapon, Prop_Data, "m_iClip1", 0);
	}
	if (attacker != 0) CPrintToChatAll("%s %t", g_sPrefix, "warden_cuffsoff", attacker, client);
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Does the player get or already have a paperclip?
public Action Timer_HasPaperClip(Handle timer, int client)
{
	if (!IsClientInGame(client))
		return Plugin_Stop;

	if (g_bCuffed[client]) // is player cuffed?
	{
		int paperclip = GetRandomInt(1, gc_iPaperClipGetChance.IntValue);

		if (paperclip == 1)
		{
			g_iPlayerPaperClips[client]++;
		}

		if (g_iPlayerPaperClips[client] > 0) // if yes tell him that
		{
			CPrintToChat(client, "%s %t", g_sPrefix, "warden_gotpaperclip", g_iPlayerPaperClips[client]);
			PrintCenterText(client, "%t", "warden_gotpaperclip", g_iPlayerPaperClips[client]);
		}
	}

	return Plugin_Stop;
}

// Show the progress
public Action Timer_Progress(Handle timer, int client)
{
	if (!IsClientInGame(client))
		return Plugin_Stop;

	if (TickTime[client] == 0)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀█▀█▀█▀█▀█▀█▀█\n\t░░░█■█■█■█■█■█■█■█\n\t<u>▒▒▒▒▒▒▒░░░░░░░░░░█</u>");
	}
	else if (TickTime[client] == 1)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀███▀█▀█▀█▀█▀█\n\t░░░█■█░█■█■█■█■█■█\n\t<u>▒▒▒▒▒▒▒░░░░░░░░░░█</u>");
	}
	else if (TickTime[client] == 2)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀███▀█▀█▀█▀█▀█\n\t░░░█■█░█■█■█■█■█■█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒░░░░░░█</u>");
	}
	else if (TickTime[client] == 3)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀███▀███▀█▀█▀█\n\t░░░█■█░█■█░█■█■█■█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒░░░░░░█</u>");
	}
	else if (TickTime[client] == 4)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀███▀███▀█▀█▀█\n\t░░░█■█░█■█░█■█■█■█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░█</u>");
	}
	else if (TickTime[client] == 5)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀███▀███▀███▀█\n\t░░░█■█░█■█░█■█░█■█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░█</u>");
	}
	else if (TickTime[client] == 6)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀███▀███▀███▀█\n\t░░░█■█░█■█░█■█░█■█\n\t<u>▒▒▒▒▒░░░░░░░░░░░░█</u>");
	}
	else if (TickTime[client] == 7)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█████▀███▀███▀█\n\t░░░█░█░█■█░█■█░█■█\n\t<u>▒▒▒▒▒░░░░░░░░░░░░█</u>");
	}
	else if (TickTime[client] == 8)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█████▀███▀███▀█\n\t░░░█░█░█■█░█■█░█■█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░█</u>");
	}
	else if (TickTime[client] == 9)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█████▀███████▀█\n\t░░░█░█░█■█░█░█░█■█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░█</u>");
	}
	else if (TickTime[client] == 10)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█████▀███████▀█\n\t░░░█░█░█■█░█░█░█■█\n\t<u>▒▒▒▒▒▒▒▒▒░░░░░░░░█</u>");
	}
	else if (TickTime[client] == 11)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█████████████▀█\n\t░░░█░█░█░█░█░█░█■█\n\t<u>▒▒▒▒▒▒▒▒▒░░░░░░░░█</u>");
	}
	else if (TickTime[client] == 12)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█████████████▀█\n\t░░░█░█░█░█░█░█░█■█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█</u>");
		ProgressTimer[client] = null;
	}

	if (TickTime[client] < 13) 
		return Plugin_Continue;

	return Plugin_Stop;
}


// was the lckpick sucessful?
public Action Timer_BreakTheseCuffs(Handle timer, int client)
{
	if (ProgressTimer[client] != null)
	{
		KillTimer(ProgressTimer[client]);
		ProgressTimer[client] = null;
	}

	if (IsValidClient(client, false, false) && g_bCuffed[client])
	{
		int unlocked = GetRandomInt(1, gc_iPaperClipUnLockChance.IntValue);

		if (unlocked == 1) // yes
		{
			CreateTimer(1.5, Timer_ProgressOpen, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		else // no
		{
			CreateTimer(1.5, Timer_ProgressBroke, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	BreakTimer[client] = null;
}

// show open progress and remove cuffs
public Action Timer_ProgressOpen(Handle timer, int client)
{
	if (TickTime[client] == 13)
	{
		TickTime[client] = 0;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░███████████████\n\t░░░<font color='#00FF00'>█░█░█░█░█░█░█░</font>█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█</u>");
		return Plugin_Continue;
	}
	else if (TickTime[client] == 0)
	{
		if (gc_bSounds) StopSoundAny(client, SNDCHAN_AUTO, g_sSoundUnLockCuffsPath);
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀▀▀▀▀▀▀▀▀▀▀▀▀█\n\t░░░<font color='#00FF00'>█░█░█░█░█░█░█░</font>█\n\t<u>░░░░░░░░░░░░░░░░░█</u>");
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_unlock");
		if (gc_bSounds) EmitSoundToAllAny(g_sSoundBreakCuffsPath);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		g_bCuffed[client] = false;
		CreateTimer(0.0, DeleteOverlay, GetClientUserId(client));
		g_iCuffed--;
		g_iPlayerPaperClips[client]--;
	}

	return Plugin_Stop;
}

// show break progress, remove paperclip and tell if he got more than one.
public Action Timer_ProgressBroke(Handle timer, int client)
{
	if (TickTime[client] == 13)
	{
		TickTime[client]++;
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀█▀█▀█▀█▀█▀█▀█\n\t░░░█<font color='#FF0000'>■█■█■█■█■█■█■</font>█\n\t<u>▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█</u>");
		return Plugin_Continue;
	}
	else if (TickTime[client] == 14)
	{
		if (gc_bSounds) StopSoundAny(client, SNDCHAN_AUTO, g_sSoundUnLockCuffsPath);
		PrintCenterText(client, "%s", "<font size='14'>\t░░░█▀█▀█▀█▀█▀█▀█▀█\n\t░░░█<font color='#FF0000'>■█■█■█■█■█■█■</font>█\n\t<u>░░░░░░░░░░░░░░░░░█</u>");
		g_iPlayerPaperClips[client]--;
		TickTime[client]= 0;
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_brokepaperclip");
		return Plugin_Continue;
	}
	else if (TickTime[client] == 0)
	{
		PrintCenterText(client, "%t", "warden_brokepaperclip");
		if (g_iPlayerPaperClips[client] > 0)
		{
			CreateTimer(2.0, Timer_StillPaperClip, client);
		}
	}

	return Plugin_Stop;
}

public Action Timer_StillPaperClip(Handle timer, int client)
{
	if (g_bCuffed[client])
	{
		CPrintToChat(client, "%s %t", g_sPrefix, "warden_gotpaperclip", g_iPlayerPaperClips[client]);
		PrintCenterText(client, "%t", "warden_gotpaperclip", g_iPlayerPaperClips[client]);
	}
}

/******************************************************************************
                   STOCKS
******************************************************************************/

void StripZeus(int client)
{
	if (!IsValidClient(client, true, false))
		return;

	if ((!IsClientWarden(client) && (!IsClientDeputy(client) && gc_bHandCuffDeputy.BoolValue)))
		return;

	char sWeapon[64];
	FakeClientCommand(client, "use weapon_taser");
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if (weapon == -1)
		return;

	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	if (StrEqual(sWeapon, "weapon_taser"))
	{
		SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(weapon, "Kill");
	}
}

bool IsLookingAtWall(int client, float distance=40.0) {

	float posEye[3], posEyeAngles[3];
	bool isClientLookingAtWall = false;

	GetClientEyePosition(client,	posEye);
	GetClientEyeAngles(client,		posEyeAngles);

	posEyeAngles[0] = 0.0;

	Handle trace = TR_TraceRayFilterEx(posEye, posEyeAngles, CONTENTS_SOLID, RayType_Infinite, LookingWall_TraceEntityFilter);

	if (TR_DidHit(trace)) {

		if (TR_GetEntityIndex(trace) > 0) {
			CloseHandle(trace);
			return false;
		}

		float posEnd[3];

		TR_GetEndPosition(posEnd, trace);

		if (GetVectorDistance(posEye, posEnd, true) <= (distance * distance)) {
			isClientLookingAtWall = true;
		}
	}

	CloseHandle(trace);

	return isClientLookingAtWall;
}

public bool LookingWall_TraceEntityFilter(int entity, int contentsMask)
{
	return entity == 0;
}

float GetDistance(int client, int target)
{
	float targetVec[3],clientVec[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetVec);
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientVec);

	return GetVectorDistance(clientVec, targetVec);
}


/******************************************************************************
                   NATIVES
******************************************************************************/

// Remove current Warden
public int Native_GivePaperClip(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	int amount = GetNativeCell(2);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	g_iPlayerPaperClips[client] += amount;
	CreateTimer(2.0, Timer_StillPaperClip, client);
}

// Is Client in handcuffs
public int Native_IsClientCuffed(Handle plugin, int argc)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);

	if (g_bCuffed[client])
		return true;

	return false;
}