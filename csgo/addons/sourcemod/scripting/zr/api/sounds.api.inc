/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  Sounds.api.inc
 *  Type:		  Core
 *  Description:   Native handlers for the ZR API. (Sounds module)
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
 * @section Global forward handles.
 */
Handle g_hAPIFwdCountDownTickForward = INVALID_HANDLE;
/**
 * @endsection
 */

/**
 * Initializes all natives and forwards related to infection.
 */
void APISoundsInit()
{
	
	// Forwards
	g_hAPIFwdCountDownTickForward = CreateGlobalForward("ZR_OnContdownWarningTick", ET_Ignore, Param_Cell);
}

Action APIOnCountDownTick(int tick)
{
	// Start forward call.
	Call_StartForward(g_hAPIFwdCountDownTickForward);
	
	// Push the parameters.
	Call_PushCell(tick);
	
	// Finish the call.
	Call_Finish();
}