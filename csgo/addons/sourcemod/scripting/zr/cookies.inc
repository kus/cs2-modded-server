/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  cookies.inc
 *  Type:		  Module
 *  Description:   Extended client cookie API.
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
 * Cookies module init function.
 */ 
void CookiesInit()
{
	// Forward "OnCookiesCreate" event to modules.
	ClassOnCookiesCreate();
	WeaponsOnCookiesCreate();
	ZHPOnCookiesCreate();
}

/**
 * Accepts a bools for setting client cookies.
 * 
 * @param client		The client index.
 * @param cookie		The handle to the cookie.
 * @param cookievalue   The bool value to set cookie as.
 */
void CookiesSetClientCookieBool(int client, Handle cookie, bool cookievalue)
{
	// Convert bool to string.
	char strCookievalue[8];
	ZRBoolToString(cookievalue, strCookievalue, sizeof(strCookievalue));
	
	// Set the converted string to the cookie.
	SetClientCookie(client, cookie, strCookievalue);
}

/**
 * Returns a cookie value as a bool.
 * 
 * @param client	The client index.
 * @param cookie	The handle to the cookie.
 */
bool CookiesGetClientCookieBool(int client, Handle cookie)
{
	// Get cookie string.
	char cookievalue[8];
	GetClientCookie(client, cookie, cookievalue, sizeof(cookievalue));
	
	// Return string casted into an int, then to bool.
	return view_as<bool>(StringToInt(cookievalue));
}

/**
 * Sets a integer value on a cookie.
 *
 * @param client	The client index.
 * @param cookie	The handle to the cookie.
 * @param value	 The value to set.
 */
void CookiesSetInt(int client, Handle cookie, int value)
{
	// Convert value to string.
	char strValue[16];
	IntToString(value, strValue, sizeof(strValue));
	
	// Set string value.
	SetClientCookie(client, cookie, strValue);
}

/**
 * Gets a integer value from a cookie.
 *
 * @param client	The client index.
 * @param cookie	The handle to the cookie.
 */
int CookiesGetInt(int client, Handle cookie)
{
	char strValue[16];
	strValue[0] = 0;
	GetClientCookie(client, cookie, strValue, sizeof(strValue));
	
	return StringToInt(strValue);
}
