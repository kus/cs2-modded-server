/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  account.inc
 *  Type:		  Module
 *  Description:   Handles client's accounts. (cash)
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/**
 * Maximum limit for cash in CS:S.
 */
#define ACCOUNT_CASH_MAX 16000

/**
 * Variable to store account offset value.
 */
int g_iToolsAccount;

/**
 * Find account-specific offsets here.
 */
void AccountOnOffsetsFound()
{
	// If offset "m_iAccount" can't be found, then stop the plugin.
	g_iToolsAccount = FindSendPropInfo("CCSPlayer", "m_iAccount");
	if (g_iToolsAccount == -1)
	{
		LogEvent(false, LogType_Fatal, LOG_CORE_EVENTS, LogModule_Account, "Offsets", "Offset \"CCSPlayer::m_iAccount\" was not found.");
	}
}

/**
 * Client is spawning into the game.
 * 
 * @param client	The client index.
 */
void AccountOnClientSpawn(int client)
{
	// If cashfill cvar is disabled, then stop.
	bool accountcashfill = GetConVarBool(g_hCvarsList[CVAR_ACCOUNT_CASHFILL]);
	if (!accountcashfill)
	{
		return;
	}
	
	// Get cash value.
	int cash = GetConVarInt(g_hCvarsList[CVAR_ACCOUNT_CASHFILL_VALUE]);
	
	// Set client's account.
	AccountSetClientCash(client, cash);
}

/** Client has been hurt.
 *
 * @param attacker  The attacker index.
 * @param dmg	   The amount of damage inflicted.
 */
void AccountOnClientHurt(int client, int attacker, int dmg_health)
{
	// If attacker isn't valid, then stop.
	if (!ZRIsClientValid(attacker))
	{
		return;
	}
	
	// If cashdmg cvar is disabled, then stop.
	bool accountcashdmg = GetConVarBool(g_hCvarsList[CVAR_ACCOUNT_CASHDMG]);
	if (!accountcashdmg)
	{
		return;
	}
	
	// If attacker is hurting themself, then stop.
	if (client == attacker)
	{
		return;
	}
	
	// If attacker isn't a human, then stop.
	if (!InfectIsClientHuman(attacker))
	{
		return;
	}
	
	// Get current cash, add the damage done to it, then set new value.
	int cash = AccountGetClientCash(attacker);
	AccountSetClientCash(attacker, cash + dmg_health);
}

/**
 * Get's a client's account value (cash)
 * 
 * @param client	The client index.
 * @return		  The client's current account value.
 */
stock int AccountGetClientCash(int client)
{
	// Set client's cash.
	return GetEntData(client, g_iToolsAccount, 4);
}

/**
 * Set's a client's account value (cash)
 * 
 * @param client	The client index.
 * @param value	The value to set to.
 */
stock void AccountSetClientCash(int client, int value)
{
	// If value if below 0, then set to 0.
	if (value < 0)
	{
		value = 0;
	}
	
	// Set client's cash.
	SetEntData(client, g_iToolsAccount, value, 4);
}
