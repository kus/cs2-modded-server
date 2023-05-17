/*
 * SourceMod Hosties Project
 * by: SourceMod Hosties Dev Team
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <hosties>
#include <lastrequest>

new Handle:gH_Cvar_Advanced_FK_Prevention = INVALID_HANDLE;
new bool:gShadow_Advanced_FK_Prevention = false;

new g_iLastKillTime[MAXPLAYERS+1];
new g_iConsecutiveKills[MAXPLAYERS+1];
new Handle:gH_Reset_Kill_Counter[MAXPLAYERS+1];

Freekillers_OnPluginStart()
{
	gH_Cvar_Freekill_Sound = CreateConVar("sm_hosties_freekill_sound", "sm_hosties/freekill1.mp3", "What sound to play if a non-rebelling T gets 'freekilled', relative to the sound-folder: -1 - disable, path - path to sound file", 0);
	Format(gShadow_Freekill_Sound, PLATFORM_MAX_PATH, "sm_hosties/freekill1.mp3");
	gH_Cvar_Freekill_Threshold = CreateConVar("sm_hosties_freekill_treshold", "0", "The amount of non-rebelling terrorists a CT is allowed to kill before action is taken: 0 - disabled, >0 - amount of Ts", 0, true, 0.0, true, 64.0);
	gShadow_Freekill_Threshold = 0;
	gH_Cvar_Freekill_Notify = CreateConVar("sm_hosties_freekill_notify", "0", "Whether to notify CTs who kills a non-rebelling T about how many 'freekills' they have, or not: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gShadow_Freekill_Notify = false;
	gH_Cvar_Freekill_BanLength = CreateConVar("sm_hosties_freekill_ban_length", "60", "The length of an automated freekill ban (if sm_hosties_freekill_punishment is 2): x - ban length in minutes", _, true, 0.0);
	gShadow_Freekill_BanLength = 60;
	gH_Cvar_Freekill_Punishment = CreateConVar("sm_hosties_freekill_punishment", "0", "The punishment to give to a CT who overrides the treshold: 0 - slay, 1 - kick, 2 - ban", 0, true, 0.0, true, 2.0);
	gShadow_Freekill_Punishment = FP_Slay;
	gH_Cvar_Freekill_Reset = CreateConVar("sm_hosties_freekill_reset", "0", "When to reset the 'freekill counter' for all CTs: 0 - on round start, 1 - on map end", 0, true, 0.0, true, 1.0);
	gShadow_Freekill_Reset = 0;
	gH_Cvar_Freekill_Sound_Mode = CreateConVar("sm_hosties_freekill_sound_mode", "1", "When to play the 'freekill sound': 0 - on freeATTACK, 1 - on freeKILL", 0, true, 0.0, true, 1.0);
	gShadow_Freekill_Sound_Mode = 1;
	
	gH_Cvar_Advanced_FK_Prevention = CreateConVar("sm_hosties_freekill_adv_prot", "1", "Turns on or off the advanced freekill protection system.", 0, true, 0.0, true, 1.0);
	gShadow_Advanced_FK_Prevention = true;
	
	HookEvent("player_death", Freekillers_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_end", Freekillers_RoundEnd);
	
	HookConVarChange(gH_Cvar_Freekill_Sound, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Threshold, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Notify, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_BanLength, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Punishment, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Reset, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Sound_Mode, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Advanced_FK_Prevention, Freekillers_CvarChanged);
	
	ResetNumFreekills();
	
	for (new kidx = 1; kidx < MaxClients; kidx++)
	{	
		if (IsClientInGame(kidx))
		{
			SDKHook(kidx, SDKHook_OnTakeDamage, Freekill_Damage_Adjustment);
		}
	}
}

ResetNumFreekills()
{
	for (new fidx = 1; fidx < MaxClients; fidx++)
	{
		gH_Reset_Kill_Counter[fidx] = INVALID_HANDLE;
		g_iLastKillTime[fidx] = 0;
		g_iConsecutiveKills[fidx] = 0;
		gA_FreekillsOfCT[fidx] = 0;
	}
}

Freekillers_OnMapEnd()
{
	if (gShadow_Freekill_Reset == 1)
	{
		ResetNumFreekills();
	}
}

public Action:Freekill_Damage_Adjustment(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if ((victim != attacker) && (victim > 0) && (victim <= MaxClients) && (attacker > 0) && (attacker <= MaxClients))
	{
		if (gShadow_Advanced_FK_Prevention && (g_iConsecutiveKills[attacker] > 0))
		{
			new Float:f_percentChange = 0.01*(100.0 - 20.0*float(g_iConsecutiveKills[attacker]));			
			if (f_percentChange < 0.01)
			{
				f_percentChange = 0.01;
			}
			damage = f_percentChange * damage;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

Freekillers_ClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Freekill_Damage_Adjustment); 
}

Freekillers_OnConfigsExecuted()
{
	// check for -1 for backward compatibility
	GetConVarString(gH_Cvar_Freekill_Sound, gShadow_Freekill_Sound, sizeof(gShadow_Freekill_Sound));
	if ((strlen(gShadow_Freekill_Sound) > 0) && !StrEqual(gShadow_Freekill_Sound, "-1"))
	{
		new MediaType:soundfile = type_Sound;
		CacheTheFile(gShadow_Freekill_Sound, soundfile);
	}
	
	gShadow_Freekill_Threshold = GetConVarInt(gH_Cvar_Freekill_Threshold);
	gShadow_Freekill_Notify = GetConVarBool(gH_Cvar_Freekill_Notify);
	gShadow_Freekill_BanLength = GetConVarInt(gH_Cvar_Freekill_BanLength);
	gShadow_Freekill_Punishment = FreekillPunishment:GetConVarInt(gH_Cvar_Freekill_Punishment);
	gShadow_Freekill_Reset = GetConVarInt(gH_Cvar_Freekill_Reset);
	gShadow_Freekill_Sound_Mode = GetConVarInt(gH_Cvar_Freekill_Sound_Mode);
	gShadow_Advanced_FK_Prevention = GetConVarBool(gH_Cvar_Advanced_FK_Prevention);
}

public Freekillers_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_Freekill_Sound)
	{
		Format(gShadow_Freekill_Sound, PLATFORM_MAX_PATH, newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Threshold)
	{
		gShadow_Freekill_Threshold = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Notify)
	{
		gShadow_Freekill_Notify = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_BanLength)
	{
		gShadow_Freekill_BanLength = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Punishment)
	{
		gShadow_Freekill_Punishment = FreekillPunishment:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Reset)
	{
		gShadow_Freekill_Reset = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Sound_Mode)
	{
		gShadow_Freekill_Sound_Mode = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Advanced_FK_Prevention)
	{
		gShadow_Advanced_FK_Prevention = bool:StringToInt(newValue);
	}
}

public Freekillers_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_Freekill_Reset == 0)
	{
		ResetNumFreekills();
	}
}

public Freekillers_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	// if attacker was a counter-terrorist and target was a terrorist
	if (attacker && victim && (GetClientTeam(attacker) == CS_TEAM_CT) && \
		(GetClientTeam(victim) == CS_TEAM_T))
	{
		// advanced freekill tracking
		new iTime = GetTime();
		new iTimeSinceKill = iTime - g_iLastKillTime[attacker];
		g_iLastKillTime[attacker] = iTime;
		
		if ((iTimeSinceKill <= 4) || g_iConsecutiveKills[attacker] == 0)
		{
			g_iConsecutiveKills[attacker]++;
			
			if (gH_Reset_Kill_Counter[attacker] != INVALID_HANDLE)
			{
				CloseHandle(gH_Reset_Kill_Counter[attacker]);				
			}
			
			gH_Reset_Kill_Counter[attacker] = CreateTimer(4.0, Timer_ResetKills, attacker, TIMER_FLAG_NO_MAPCHANGE);
		}
		
		if (!g_bIsARebel[victim])
		{
			new iArraySize = GetArraySize(gH_DArray_LR_Partners);
			if (iArraySize == 0)
			{
				TakeActionOnFreekiller(attacker);
			}
			else
			{
				// check if victim was in an LR and not the attacker pair
				for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
				{
					new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
					new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
					new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
					
					if (type != LR_Rebel && (victim == LR_Player_Prisoner) && (attacker != LR_Player_Guard))
					{
						TakeActionOnFreekiller(attacker);
					}
				}
			}
		}
	}
}

public Action:Timer_ResetKills(Handle:timer, any:client)
{
	g_iConsecutiveKills[client] = 0;
	gH_Reset_Kill_Counter[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

TakeActionOnFreekiller(attacker)
{
	// FREEEEEKILL... rawr...
	if (gShadow_Freekill_Threshold > 0)
	{
		if (gA_FreekillsOfCT[attacker] >= gShadow_Freekill_Threshold)
		{
			// Take action...
			switch(gShadow_Freekill_Punishment)
			{
				case FP_Slay:
				{
					ForcePlayerSuicide(attacker);
					PrintToChatAll(CHAT_BANNER, "Freekill Slay", attacker);
					gA_FreekillsOfCT[attacker] = 0;
				}
				case FP_Kick:
				{
					KickClient(attacker, "%t", "Freekill Kick Reason");
					PrintToChatAll(CHAT_BANNER, "Freekill Kick", attacker);
					LogMessage("%N was kicked for killing too many non-rebelling terrorists.", attacker);
				}
				case FP_Ban:
				{
					if (g_bSBAvailable)
					{
						SBBanPlayer(0, attacker, gShadow_Freekill_BanLength, "SM_Hosties: Freekilling");
					}
					else
					{
						decl String:ban_message[128];
						Format(ban_message, sizeof(ban_message), "%T", "Freekill Ban Reason", attacker);
						BanClient(attacker, gShadow_Freekill_BanLength, BANFLAG_AUTO, "SM_Hosties: Freekilling", ban_message);
						PrintToChatAll(CHAT_BANNER, "Freekill Ban", attacker);
					}
				}
			}
		}
		else
		{
			// Add 1 freekill to the records...
			gA_FreekillsOfCT[attacker]++;

			// Notify the player if the server owner so desires...
			if (gShadow_Freekill_Notify)
			{
				PrintHintText(attacker, "%t", "Freekill Record Increased", gA_FreekillsOfCT[attacker], gShadow_Freekill_Threshold+1);
			}
		}
		
		// check for -1 for backward compatibility
		if ((strlen(gShadow_Freekill_Sound) > 0) && !StrEqual(gShadow_Freekill_Sound, "-1"))
		{
			EmitSoundToAllAny(gShadow_Freekill_Sound);
		}
	}
}