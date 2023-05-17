/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  infect.inc
 *  Type:		  Core
 *  Description:   Client infection functions.
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

public int ZR_OnContdownWarningTick(int tick)
{
	if(tick <= 10 && tick >= 1 && g_hCvarsList.g_bCVAR_COUNTDOWN_SOUNDS)
	{
		// Get infection sound.
		char ContMamPath[PLATFORM_MAX_PATH];
		char ContWomPath[PLATFORM_MAX_PATH];

		Format(ContMamPath, sizeof(ContMamPath), "%s%i.mp3", g_hCvarsList.g_sCVAR_COUNTDOWN_MAM_PATH, tick);
		Format(ContWomPath, sizeof(ContWomPath), "%s%i.mp3", g_hCvarsList.g_sCVAR_COUNTDOWN_WOMAN_PATH, tick);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				
				if(g_iCountDownCookie[i] == 1) EmitSoundToClient(i, ContMamPath, SOUND_FROM_PLAYER, SNDCHAN_AUTO, _, _, g_fZrSoundsCookie[i]);
				if(g_iCountDownCookie[i] == 2) EmitSoundToClient(i, ContWomPath, SOUND_FROM_PLAYER, SNDCHAN_AUTO, _, _, g_fZrSoundsCookie[i]);
			}
		}
	}
}