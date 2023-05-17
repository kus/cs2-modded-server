/*
 * MyJailbreak - Fog Module.
 * by: shanapu
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
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

// Integers
int FogIndex = -1;

// Floats
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Magic
void DoFog()
{
	if (FogIndex != -1)
	{
		DispatchKeyValue(FogIndex, "fogblend", "0");
		DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
		DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
		DispatchKeyValueFloat(FogIndex, "fogstart", mapFogStart);
		DispatchKeyValueFloat(FogIndex, "fogend", mapFogEnd);
		DispatchKeyValueFloat(FogIndex, "fogmaxdensity", mapFogDensity);
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Start
public void Fog_OnMapStart()
{
	int ent = FindEntityByClassname(-1, "env_fog_controller");

	if (ent != -1) 
	{
		FogIndex = ent;
	}
	else
	{
		FogIndex = CreateEntityByName("env_fog_controller");
		DispatchSpawn(FogIndex);
	}

	DoFog();

	AcceptEntityInput(FogIndex, "TurnOff");
}

/******************************************************************************
                   NATIVES
******************************************************************************/

// Set Map fog in module
public int Native_FogOn(Handle plugin, int argc)
{
	AcceptEntityInput(FogIndex, "TurnOn");
}

// Remove Map fog OFF in module
public int Native_FogOff(Handle plugin, int argc)
{
	AcceptEntityInput(FogIndex, "TurnOff");
}