/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  menu.inc
 *  Type:		  Core
 *  Description:   Base menu functions for the plugin.
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
 * @section Some defined lengths of menu lines throughout the plugin.
 */
#define MENU_LINE_SMALL_LENGTH 32
#define MENU_LINE_REG_LENGTH 64
#define MENU_LINE_BIG_LENGTH 128
#define MENU_LINE_HUGE_LENGTH 256

#define MENU_LINE_TITLE_LENGTH MENU_LINE_BIG_LENGTH
/**
 * @endsection
 */

/**
 * Return itemdraw flag for SM menus.
 * 
 * @param condition	 If this is true, item will be drawn normally.
 */
stock int MenuGetItemDraw(bool condition)
{
	return condition ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
}
