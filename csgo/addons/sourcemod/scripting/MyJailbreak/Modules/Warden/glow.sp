/*
 * MyJailbreak - Warden - Glow Warden Module.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2018 Thomas Schmidt (shanapu)
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
#include <autoexecconfig>
#include <warden>
#include <myjbwarden>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <CustomPlayerSkins>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bGlow;
ConVar gc_iWardenGlowRed;
ConVar gc_iWardenGlowGreen;
ConVar gc_iWardenGlowBlue;
ConVar gc_iDeputyGlowRed;
ConVar gc_iDeputyGlowGreen;
ConVar gc_iDeputyGlowBlue;
ConVar gc_bWardenGlowRandom;

// Info
public void Glow_OnPluginStart()
{
	// AutoExecConfig
	gc_bGlow = AutoExecConfig_CreateConVar("sm_warden_glow_enable", "1", "0 - disabled, 1 - enable warden glow", _, true, 0.0, true, 1.0);
	gc_bWardenGlowRandom = AutoExecConfig_CreateConVar("sm_warden_glow_random", "0", "0 - disabled, 1 - enable warden random glow everytime / ignores RGB values", _, true, 0.0, true, 1.0);
	gc_iWardenGlowRed = AutoExecConfig_CreateConVar("sm_warden_glow_red", "0", "What glow to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iWardenGlowGreen = AutoExecConfig_CreateConVar("sm_warden_glow_green", "0", "What glow to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iWardenGlowBlue = AutoExecConfig_CreateConVar("sm_warden_glow_blue", "255", "What glow to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_iDeputyGlowRed = AutoExecConfig_CreateConVar("sm_warden_glow_red_deputy", "0", "What glow to turn the deputy into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iDeputyGlowGreen = AutoExecConfig_CreateConVar("sm_warden_glow_green_deputy", "155", "What glow to turn the deputy into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iDeputyGlowBlue = AutoExecConfig_CreateConVar("sm_warden_glow_blue_deputy", "255", "What glow to turn the deputy into (rgB): x - blue value", _, true, 0.0, true, 255.0);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

void Glow_OnWardenCreation(int client)
{
	RequestFrame(NextFrame_WardenGlow, GetClientUserId(client));
}

void Glow_OnWardenRemoved(int client)
{
	RequestFrame(NextFrame_WardenRemoveGlow, GetClientUserId(client));
}

void Glow_OnDeputyCreation(int client)
{
	RequestFrame(NextFrame_WardenGlow, GetClientUserId(client));
}

void Glow_OnDeputyRemoved(int client)
{
	RequestFrame(NextFrame_WardenRemoveGlow, GetClientUserId(client));
}

/******************************************************************************
                   TIMER
******************************************************************************/


void NextFrame_WardenGlow(int userid)
{
	if (!gc_bPlugin.BoolValue || !gc_bGlow.BoolValue || !g_bEnabled || !gp_bCustomPlayerSkins)
		return;

	int client = GetClientOfUserId(userid);

	if (!IsValidClient(client, true, false))
		return;

	if (!IsClientWarden(client) && !IsClientDeputy(client))
		return;

	SetupGlowSkin(client);
}

void NextFrame_WardenRemoveGlow(int userid)
{
	if (!gc_bPlugin.BoolValue || !gc_bGlow.BoolValue || !gp_bCustomPlayerSkins)
		return;

	int client = GetClientOfUserId(userid);

	if (!IsValidClient(client, true, true))
		return;

	UnhookGlow(client);
}

// Perpare client for glow
void SetupGlowSkin(int client)
{
	char sModel[PLATFORM_MAX_PATH];
	GetClientModel(client, sModel, sizeof(sModel));

	int iSkin = CPS_SetSkin(client, sModel, CPS_RENDER);
	if (iSkin == -1)
		return;

	if (SDKHookEx(iSkin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin))
	{
		GlowSkin(iSkin, client);
	}
}

// set client glow
void GlowSkin(int iSkin, int client)
{
	int iOffset;

	if ((iOffset = GetEntSendPropOffs(iSkin, "m_clrGlow")) == -1)
		return;

	SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(iSkin, Prop_Send, "m_nGlowStyle", 1);
	SetEntPropFloat(iSkin, Prop_Send, "m_flGlowMaxDist", 10000000.0);

	int iRed;
	int iGreen;
	int iBlue;

	if (gc_bWardenGlowRandom.BoolValue)
	{
		int i = GetRandomInt(1, 7);
		iRed = g_iColors[i][0];
		iGreen = g_iColors[i][1];
		iBlue = g_iColors[i][2];
		
	}
	else if (IsClientWarden(client))
	{
		iRed = gc_iWardenGlowRed.IntValue;
		iGreen = gc_iWardenGlowGreen.IntValue;
		iBlue = gc_iWardenGlowBlue.IntValue;
	}
	else
	{
		iRed = gc_iDeputyGlowRed.IntValue;
		iGreen = gc_iDeputyGlowGreen.IntValue;
		iBlue = gc_iDeputyGlowBlue.IntValue;
	}

	SetEntData(iSkin, iOffset, iRed, _, true);
	SetEntData(iSkin, iOffset + 1, iGreen, _, true);
	SetEntData(iSkin, iOffset + 2, iBlue, _, true);
	SetEntData(iSkin, iOffset + 3, 255, _, true);
}

// Who can see the glow if vaild
public Action OnSetTransmit_GlowSkin(int iSkin, int client)
{
	if (!IsPlayerAlive(client))
		return Plugin_Handled;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (!CPS_HasSkin(i))
			continue;

		if (EntRefToEntIndex(CPS_GetSkin(i)) != iSkin)
			continue;

		return Plugin_Continue;
	}

	return Plugin_Handled;
}

// remove glow
void UnhookGlow(int client)
{
	int iSkin = CPS_GetSkin(client);
	if (iSkin == INVALID_ENT_REFERENCE)
		return;

	SetEntProp(iSkin, Prop_Send, "m_bShouldGlow", false, true);
	SDKUnhook(iSkin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin);
}