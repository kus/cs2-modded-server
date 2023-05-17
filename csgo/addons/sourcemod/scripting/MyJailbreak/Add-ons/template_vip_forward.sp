/*
 * MyJailbreak - TEMPLATE Custom VIP benefits Plugin.
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
#include <myjailbreak>
#include <vip_core>
#include <stamm>
#include <reputation>
#include <hl_gangs>
#include <mostactive>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required


// Info
public Plugin myinfo = {
	name = "MyJailbreak - Add Custom VIP benefits - Template",
	author = "shanapu",
	description = "", 
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public bool MyJailbreak_OnCheckVIP(int client, char[] feature)
{
	if (StrEqual(feature, "sm_ratio_flag", false))
	{
		if (VIP_IsClientVIP(client))
			return true;
	}
	else if (StrEqual(feature, "sm_warden_flag", false))
	{
		if (STAMM_GetClientPoints(client) > 99)
			return true;
	}
	else if (StrEqual(feature, "sm_warden_bulletsparks_flag", false))
	{
		if (Reputation_GetRep(client) > 99)
			return true;
	}
	else if (StrEqual(feature, "sm_request_flag", false))
	{
		if (Gangs_HasGang(client))
			return true;
	}
	else if (StrEqual(feature, "sm_warden_handcuffs_flag", false))
	{
		if (MostActive_GetPlayTimeCT(client) > 999)
			return true;
	}

	return false;
}

public void OnMapStart()
{
	SetFailState("This file is an template for developer and should'nt run on productive servers, cause it's really shitty! please remove");
}