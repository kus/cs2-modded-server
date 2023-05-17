/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  clientalpha.inc
 *  Type:		  Core
 *  Description:   Handles transparency on clients.
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
 * Updates the alpha value on a player.
 */
void ClassAlphaUpdate(int client)
{
	int current_health = GetClientHealth(client);
	int max_health	 = ClassGetHealth(client);
	int max_damage	 = ClassGetAlphaDamage(client);
	
	// Calculate if enough damage is done to change alpha.
	if ((max_health - current_health) > max_damage)
	{
		int alpha_damaged = ClassGetAlphaDamaged(client);
		ToolsSetClientAlpha(client, alpha_damaged);
	}
}
