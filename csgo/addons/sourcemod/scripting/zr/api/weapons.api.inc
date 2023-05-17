/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  class.api.inc
 *  Type:		  Core
 *  Description:   Native handlers for the ZR API. (Class module)
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
 * Initializes all natives and forwards related to infection.
 */

void APIWeapons()
{
	CreateNative("ZR_NoWeaponRestrictions", Native_NoWeaponRestrictions);	
}

public int Native_NoWeaponRestrictions(Handle plugin, int numParams)
{
	g_allweapons[GetNativeCell(1)] = GetNativeCell(2);

}