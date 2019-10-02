#if defined _smlib_game_included
	#endinput
#endif
#define _smlib_game_included

#include <sourcemod>
#include <sdktools_functions>
#include <sdktools_entinput>

/*
 * End's the game and displays the scoreboard with intermission time.
 *
 * @noparam
 * @return				True on success, false otherwise
 */
stock bool:Game_End()
{
	new game_end = FindEntityByClassname(-1, "game_end");

	if (game_end == -1) {
		game_end = CreateEntityByName("game_end");
		
		if (game_end == -1) {
			ThrowError("Unable to find or create entity \"game_end\"");
		}
	}

	return AcceptEntityInput(game_end, "EndGame");
}

/*
 * End's the current round, allows specifying the winning
 * team and more.
 * This function currently works in TF2 only (it uses the game_round_win entity).
 *
 * @param team			The winning Team, pass 0 for Sudden Death mode (no winning team)
 * @param forceMapReset If to force the map to reset during the force respawn after the round is over.
 * @param switchTeams	If to switch the teams when the game is going to be reset. 
 * @return				True on success, false otherwise
 */
stock bool:Game_EndRound(team=0, bool:forceMapReset=false, bool:switchTeams=false)
{
	new game_round_win = FindEntityByClassname(-1, "game_round_win");

	if (game_round_win == -1) {
		game_round_win = CreateEntityByName("game_end");

		if (game_round_win == -1) {
			ThrowError("Unable to find or create entity \"game_round_win\"");
		}
	}

	DispatchKeyValue(game_round_win, "TeamNum"			, (team			? "true" : "false"));
	DispatchKeyValue(game_round_win, "force_map_reset"	, (forceMapReset? "true" : "false"));
	DispatchKeyValue(game_round_win, "switch_teams"		, (switchTeams	? "true" : "false"));

	return AcceptEntityInput(game_round_win, "RoundWin");
}
