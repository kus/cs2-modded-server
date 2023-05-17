/*
 * MyJailbreak - HL Gangs Support.
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
#include <hl_gangs>
#include <myjailbreak>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required


// Info
public Plugin myinfo = {
	name = "MyJailbreak - HL Gangs",
	author = "shanapu",
	description = "Disable Gang Perks on Event days", 
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};


public void Gangs_OnPerksSetPre(int client, bool &shouldGive)
{
	if (MyJailbreak_IsEventDayRunning() || MyJailbreak_IsEventDayPlanned())
	{
		shouldGive = false;
	}
}