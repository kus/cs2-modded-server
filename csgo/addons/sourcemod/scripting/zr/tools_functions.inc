/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  tools_functions.inc
 *  Type:		  Core
 *  Description:   API for offsets/signatures exposed in tools.inc
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
 * Get or set a client's velocity.
 * @param client		The client index.
 * @param vecVelocity   Array to store vector in, or velocity to set on client.
 * @param retrieve	  True to get client's velocity, false to set it.
 * @param stack		 If modifying velocity, then true will stack new velocity onto the client's
 *					  current velocity, false will reset it.
 */
stock void ToolsClientVelocity(int client, float vecVelocity[3], bool apply = true, bool stack = true)
{
	// If retrieve if true, then get client's velocity.
	if (!apply)
	{
		// x = vector component.
		for (int x = 0; x < 3; x++)
		{
			vecVelocity[x] = GetEntDataFloat(client, g_iToolsVelocity + (x*4));
		}
		
		// Stop here.
		return;
	}
	
	// If stack is true, then add client's velocity.
	if (stack)
	{
		// Get client's velocity.
		float vecClientVelocity[3];
		
		// x = vector component.
		for (int x = 0; x < 3; x++)
		{
			vecClientVelocity[x] = GetEntDataFloat(client, g_iToolsVelocity + (x*4));
		}
		
		AddVectors(vecClientVelocity, vecVelocity, vecVelocity);
	}
	
	// Apply velocity on client.
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

/**
 * Gets client's velocity.
 *
 * @param client		The client index.
 * @param vecVelocity   Array to store vector in.
 */
stock void ToolsGetClientVelocity(int client, float vecVelocity[3])
{
	// x = vector component.
	for (int x = 0; x < 3; x++)
	{
		vecVelocity[x] = GetEntDataFloat(client, g_iToolsVelocity + (x*4));
	}
}

/**
 * Set a client's lagged movement value.
 * @param client	The client index.
 * @param value	 LMV value. (300.0 = default, 600.0 = double)
 */
stock void ToolsSetClientLMV(int client, float fLMV)
{
	// Set lagged movement value of client.
	SetEntDataFloat(client, g_iToolsLMV, fLMV / 300.0, true);
}

/**
 * Get nightvision values on a client.
 * @param client	The client index.
 * @param ownership If true, function will return the value of the client's ownership of nightvision.
 *				  If false, function will return the value of the client's on/off state of the nightvision.
 * @return		  True if aspect of nightvision is enabled on the client, false if not.
 */
stock bool ToolsGetClientNightVision(int client, bool ownership = true)
{
	// If ownership is true, then toggle the ownership of nightvision on client.
	if (ownership)
	{
		return view_as<bool>(GetEntData(client, g_iToolsHasNightVision, 1));
	}
	
	return view_as<bool>(GetEntData(client, g_iToolsNightVisionOn, 1));
}

/**
 * Control nightvision values on a client.
 * @param client	The client index.
 * @param enable	Enable or disable an aspect of nightvision. (see ownership parameter)
 * @param ownership If true, enable will toggle the client's ownership of nightvision.
 *				  If false, enable will toggle the client's on/off state of the nightvision.
 */
stock void ToolsSetClientNightVision(int client, bool enable, bool ownership = true)
{
	// If ownership is true, then toggle the ownership of nightvision on client.
	if (ownership)
	{
		SetEntData(client, g_iToolsHasNightVision, enable, 1, true);
		
		// Stop here.
		return;
	}
	
	SetEntData(client, g_iToolsNightVisionOn, enable, 1, true);
}

/**
 * Set a client's default field of vision.
 * @param client	The client index.
 * @param FOV	   The field of vision of the client.
 */
stock void ToolsSetClientDefaultFOV(int client, int FOV)
{
	SetEntData(client, g_iToolsFOV, FOV, 1, true);
}

/**
 * Get or set a client's score or deaths.
 * 
 * @param client	The client index.
 * @param score	 True to look at score, false to look at deaths.  
 * @param apply	 True to set scores or death, false to get. 
 * @param value	 The value of the client's score or deaths.
 * @return		  The score or death count of the client, -1 if setting.
 */
stock int ToolsClientScore(int client, bool score = true, bool apply = true, int value = 0)
{
	if (!apply)
	{
		if (score)
		{
			// If score is true, then return client's score.
			return GetEntProp(client, Prop_Data, "m_iFrags");
		}
		// Return client's deaths.
		else
		{
			return GetEntProp(client, Prop_Data, "m_iDeaths");
		}
	}
	
	// If score is true, then set client's score.
	if (score)
	{
		SetEntProp(client, Prop_Data, "m_iFrags", value);
	}
	// Set client's deaths.
	else
	{
		SetEntProp(client, Prop_Data, "m_iDeaths", value);
	}
	
	// We set the client's score or deaths.
	return -1;
}

/**
 * Set a client's alpha value.
 * 
 * @param client	The client index.
 * @param alpha	 The alpha value to set client's alpha to. (0-255)
 * @param weapons   Apply alpha to all client's weapons.
 */
stock void ToolsSetClientAlpha(int client, int alpha)
{
	// Turn rendermode on, on the client.
	SetEntityRenderMode(client, RENDER_TRANSALPHA);
	
	// Set alpha value on the client.
	SetEntityRenderColor(client, _, _, _, alpha);
	
	// Forward event to modules.
	WeaponAlphaOnClientAlphaChanged(client, alpha);
}

/**
 * Sets an entity's color. (This is the "get" version of SetEntityRenderColor)
 *
 * @param client	The client index.
 * @return		  The alpha value of the client. (0-255)
 */
stock int ToolsGetEntityAlpha(int entity)
{
	static bool gotconfig = false;
	static char prop[32];
	
	if (!gotconfig)
	{
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_clrRender", prop, sizeof(prop));
		CloseHandle(gc);
		
		if (!exists)
		{
			strcopy(prop, sizeof(prop), "m_clrRender");
		}
		
		gotconfig = true;
	}
	
	int offset = GetEntSendPropOffs(entity, prop);
	
	return GetEntData(entity, offset + 3, 1);
}
