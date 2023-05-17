/*
 * MyJailbreak EventDays - Sourcemod store credits
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
#include <myjailbreak>
#include <mystocks>
#include <store/store-core>
#include <autoexecconfig>
#include <colors>

// ConVars
ConVar gc_iAmount;
ConVar gc_bAlive;

// Strings
char g_sPrefix[64];

public Plugin myinfo = 
{
	name = "MyJailbreak - Sourcemod Store Credits",
	author = "shanapu",
	description = "Sourcemod Store Credits for winner team on MyJailbreaks Event Days",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public void OnPluginStart()
{
	AutoExecConfig_SetFile("plugin.store");
	AutoExecConfig_SetCreateFile(true);

	gc_iAmount = AutoExecConfig_CreateConVar("sm_store_credit_amount_eventdays", "10", "Number of credits to give out for winning an eventday", _, true, 1.0);
	gc_bAlive = AutoExecConfig_CreateConVar("sm_store_credit_eventdays_alive", "1", "Give out credits for winning an eventday for dead & alive player", _, true, 0.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}

public void OnConfigsExecuted()
{
	ConVar cBuffer = FindConVar("sm_store_chat_tag");
	cBuffer.GetString(g_sPrefix, sizeof(g_sPrefix));
}

public void MyJailbreak_OnEventDayEnd(char[] name, int winner)
{
	if (winner <= 1)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, false, gc_bAlive.BoolValue))
			continue;

		if (GetClientTeam(i) == winner)
		{
			int accountId = Store_GetClientAccountID(i);
			int oldCredits = Store_GetCreditsEx(accountId);
			Store_GiveCredits(accountId, (oldCredits + gc_iAmount.IntValue));

			CPrintToChat(i, "%s You earned %i credits for winning the EventDay.", g_sPrefix, gc_iAmount.IntValue);
		}
	}
}