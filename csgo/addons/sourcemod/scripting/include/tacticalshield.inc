/*
*   This file is part of Tactical Shield.
*   Copyright (C) 2017  Keplyx
*
*   This program is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#if defined _tacticalshield_included
 #endinput
#endif

#define _tacticalshield_included
 

/**
 * Give the specified player a shield, if he can have one.
 * It is the same as the command ts_buy but without using money.
 *
 * @param client			Client index.
 * @return
 * @error					Invalid client.
 */
native void GivePlayerShield(int client);

/**
 * Override shield status for the specified player.
 *
 * @param client			Client index.
 * @param override			Override parameter: 0= no override, 1= force no shields, 2= force shields.
 * @return
 * @error					Invalid client.
 */
native void OverridePlayerShield(int client, int override);