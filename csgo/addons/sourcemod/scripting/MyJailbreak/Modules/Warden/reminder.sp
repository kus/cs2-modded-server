/*
 * MyJailbreak - Warden - Reminder Module.
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
#include <warden>
#include <myjbwarden>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bg_hTimerReminder;

// Handles
Handle g_hTimerReminder;

// Start
public void Reminder_OnPluginStart()
{
	// AutoExecConfig
	gc_bg_hTimerReminder = AutoExecConfig_CreateConVar("sm_warden_roundtime_reminder", "1", "0 - disabled, 1 - announce remaining round time in chat & hud 3min, 2min, 1min, 30sec before roundend.", _, true, 0.0, true, 1.0);

	// Hooks
	HookEvent("round_start", Reminder_Event_RoundStart);
	HookEvent("round_end", Reminder_Event_RoundEnd);
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Reminder_OnMapStart()
{
	PrecacheSound("weapons/c4/c4_beep1.wav", true);
}

public void Reminder_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	delete g_hTimerReminder;
}

public void Reminder_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (gc_bg_hTimerReminder.BoolValue)
	{
		g_hTimerReminder = CreateTimer(1.0, Timer_g_hTimerReminder, _, TIMER_REPEAT);
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void Reminder_OnMapEnd()
{
	delete g_hTimerReminder;
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_g_hTimerReminder(Handle timer)
{
	if (g_iRoundTime >= 1)
	{
		if (gp_bMyJailBreak) if (MyJailbreak_IsLastGuardRule())
		{
			g_hTimerReminder = null;
			return Plugin_Stop;
		}

		g_iRoundTime--;
		char timeinfo[64];

		if (g_iRoundTime == 180 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_180", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_180", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}

		if (g_iRoundTime == 120 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_120", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_120", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}

		if (g_iRoundTime == 60 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_60", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_60", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}

		if (g_iRoundTime == 30 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_30", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_30", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}

		// Deputy
		if (g_iRoundTime == 180 && (g_iDeputy != -1))
		{
			EmitSoundToClient(g_iDeputy, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_180", g_iDeputy, "warden_remaining", g_iDeputy);
			CPrintToChat(g_iDeputy, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_180", g_iDeputy, "warden_remaining", g_iDeputy);
			PrintCenterText(g_iDeputy, timeinfo);
		}

		if (g_iRoundTime == 120 && (g_iDeputy != -1))
		{
			EmitSoundToClient(g_iDeputy, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_120", g_iDeputy, "warden_remaining", g_iDeputy);
			CPrintToChat(g_iDeputy, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_120", g_iDeputy, "warden_remaining", g_iDeputy);
			PrintCenterText(g_iDeputy, timeinfo);
		}

		if (g_iRoundTime == 60 && (g_iDeputy != -1))
		{
			EmitSoundToClient(g_iDeputy, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_60", g_iDeputy, "warden_remaining", g_iDeputy);
			CPrintToChat(g_iDeputy, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_60", g_iDeputy, "warden_remaining", g_iDeputy);
			PrintCenterText(g_iDeputy, timeinfo);
		}

		if (g_iRoundTime == 30 && (g_iDeputy != -1))
		{
			EmitSoundToClient(g_iDeputy, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%s %T %T", g_sPrefix, "warden_30", g_iDeputy, "warden_remaining", g_iDeputy);
			CPrintToChat(g_iDeputy, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_30", g_iDeputy, "warden_remaining", g_iDeputy);
			PrintCenterText(g_iDeputy, timeinfo);
		}

		return Plugin_Continue;
	}

	g_hTimerReminder = null;

	return Plugin_Stop;
}
