/*
*   This file is part of Cameras and Drones.
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

#if defined _camerasanddrones_included
 #endinput
#endif

#define _camerasanddrones_included
 

/**
 * Buy the gear (camera or drone) depending on the player team
 *
 * @param client	Client index.
 * @return
 * @error	Invalid client.
 */
native void BuyPlayerGear(int client);

/**
 * Adds two numbers together.
 *
 * @param client	Client index.
 * @param override	Override parameter: -1= no gear, 0= no override, 1= force cameras, 2= force drones.
 * @return
 * @error	Invalid client.
 */
native void OverridePlayerGear(int client, int override);