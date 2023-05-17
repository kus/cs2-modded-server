/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  immunityhandler.h.inc
 *  Type:		  Header
 *  Description:   Immunity modes.
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
 * Immunity modes.
 */
enum ImmunityMode
{
	Immunity_Invalid = -1,  /** Invalid immunity mode. Used by validators. */
	Immunity_None,		  /** No immunity mode. */
	Immunity_Kill,		  /** Humans are instantly killed when infected by zombies. */
	Immunity_Full,		  /** Completely immune. Humans can't be infected, zombies don't receive damage or knock back. Admin commands may override this. */
	Immunity_Infect,		/** Humans are immune to infections until HP go below a threshold. Threshold at zero enable stabbing to death. */
	Immunity_Damage,		/** Zombies are immune to damage from humans/grenades, but still vulnerable to knock back. */
	Immunity_Delay,		 /** Delay infection for a certain amount of seconds. */
	Immunity_Shield		 /** Shield against infections (humans) or knock back (zombies) for a certain amount of seconds (similar to TF2's übercharge). */
}
