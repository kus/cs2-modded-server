/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  clientoverlays.inc
 *  Type:		  Core 
 *  Description:   Handles overlays on clients, as a part of class attributes.
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
 * @section Suicide intercept defines.
 */
#define CLASSOVERLAY_TOGGLE_MAX_CMDS 5
#define CLASSOVERLAY_TOGGLE_MAX_LENGTH 16
/**
 * @endsection
 */

/**
 * Name of the cookie for toggle state the class overlay.
 */
#define CLASSOVERLAY_COOKIE_ENABLED "zr_overlay"

/**
 * Cookie handle for the toggle state of an overlay.
 */
Handle g_hOverlayEnabledCookie = INVALID_HANDLE;

/**
 * Creates command clallbacks for listed overlay commands.
 */
void ClassOverlayOnCommandsHook()
{
	char togglecmds[CLASSOVERLAY_TOGGLE_MAX_CMDS * CLASSOVERLAY_TOGGLE_MAX_LENGTH];
	GetConVarString(g_hCvarsList[CVAR_CLASSES_OVERLAY_TOGGLECMDS], togglecmds, sizeof(togglecmds));
	
	// Array to store commands.
	char arrayCmds[CLASSOVERLAY_TOGGLE_MAX_CMDS][CLASSOVERLAY_TOGGLE_MAX_LENGTH];
	
	// Put the commands into an array.
	int cmdcount = ExplodeString(togglecmds, ",", arrayCmds, sizeof(arrayCmds), sizeof(arrayCmds[]));
	
	// Register all overlay commands.
	for (int i = 0; i < cmdcount; i++)
	{
		TrimString(arrayCmds[i]);
		RegConsoleCmd(arrayCmds[i], ClassOverlayEnableCommand);
	}
}

/**
 * Create class overlay-related cookies here.
 */
void ClassOverlayOnCookiesCreate()
{
	// Create cookie handle only if it don't exist.
	if (g_hOverlayEnabledCookie == INVALID_HANDLE)
	{
		g_hOverlayEnabledCookie = RegClientCookie(CLASSOVERLAY_COOKIE_ENABLED, "The toggle state of the class overlay.", CookieAccess_Protected);
	}
}

/**
 * Called once a client's saved cookies have been loaded from the database.
 * 
 * @param client		Client index.
 */
void ClassOverlayOnCookiesCached(int client)
{
	// Get overlay toggle cvar values.
	bool overlaytoggle = GetConVarBool(g_hCvarsList[CVAR_CLASSES_OVERLAY_TOGGLE]);
	bool overlaydefault = GetConVarBool(g_hCvarsList[CVAR_CLASSES_OVERLAY_DEFAULT]);
	
	// Get ZHP enabled cookie value.
	char overlayenabled[8];
	GetClientCookie(client, g_hOverlayEnabledCookie, overlayenabled, sizeof(overlayenabled));
	
	// If the cookie is empty, then set the default value.
	if (!overlayenabled[0])
	{
		// Set cookie to default value from cvar.
		bool overlayvalue = overlaytoggle ? overlaydefault : true;
		CookiesSetClientCookieBool(client, g_hOverlayEnabledCookie, overlayvalue);
	}
}

/**
 * Client has been killed.
 * 
 * @param client	The client index.
 */
void ClassOverlayOnClientDeath(int client)
{
	// Disable overlay.
	OverlaysClientSetChannelState(client, OVERLAYS_CHANNEL_CLASSES, true, false, false, true);
}

public int ClassOverlayInitialize(int client, const char[] overlay)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	// If overlay path is empty, then disable channel, then stop.
	if (!overlay[0])
	{
		OverlaysClientSetChannelState(client, OVERLAYS_CHANNEL_CLASSES, true, false, false, true);
		return;
	}
	
	// If overlay toggle is enabled and class has an overlay, then send center text.
	bool overlaytoggle = GetConVarBool(g_hCvarsList[CVAR_CLASSES_OVERLAY_TOGGLE]);
	
	char overlaypath[PLATFORM_MAX_PATH];
	ClassGetOverlayPath(client, overlaypath, sizeof(overlaypath));
	
	if (overlaytoggle && overlaypath[0])
	{
		char togglecmds[CLASSOVERLAY_TOGGLE_MAX_CMDS * CLASSOVERLAY_TOGGLE_MAX_LENGTH];
		GetConVarString(g_hCvarsList[CVAR_CLASSES_OVERLAY_TOGGLECMDS], togglecmds, sizeof(togglecmds));
		
		TranslationPrintHintText(client, "Classes overlay toggle", togglecmds);
	}
	
	// Display class overlays.
	OverlaysClientSetChannelPath(client, OVERLAYS_CHANNEL_CLASSES, overlay);
	OverlaysClientSetChannelState(client, OVERLAYS_CHANNEL_CLASSES, true, false, CookiesGetClientCookieBool(client, g_hOverlayEnabledCookie));
}

/**
 * Command callback. (See zr_classes_overlay_togglecmds)
 * Toggles nightvision of a client.
 *   
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action ClassOverlayEnableCommand(int client, int argc)
{
	// If client isn't valid, then stop.
	if (!ZRIsClientValid(client))
	{
		return;
	}
	
	// If overlay toggle is disabled, then stop.
	bool overlaytoggle = GetConVarBool(g_hCvarsList[CVAR_CLASSES_OVERLAY_TOGGLE]);
	if (!overlaytoggle)
	{
		return;
	}
	
	// Toggle current overlay channel, retrieve new value, and update cookie.
	bool overlayenabled = OverlaysClientSetChannelState(client, OVERLAYS_CHANNEL_CLASSES, true, true);
	CookiesSetClientCookieBool(client, g_hOverlayEnabledCookie, overlayenabled);
}
