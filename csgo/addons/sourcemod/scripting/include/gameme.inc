/**
 * gameME Plugin
 * http://www.gameme.com
 * Copyright (C) 2007-2019 TTS Oetzel & Goerz GmbH
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#if defined _gameme_included_
  #endinput
#endif
#define _gameme_included_


// raw message handling
#define RAW_MESSAGE_RANK				1
#define RAW_MESSAGE_PLACE				2
#define RAW_MESSAGE_KDEATH				3
#define RAW_MESSAGE_SESSION_DATA		4
#define RAW_MESSAGE_TOP10				5
#define RAW_MESSAGE_NEXT				6

// callbacks
#define RAW_MESSAGE_CALLBACK_PLAYER		101
#define RAW_MESSAGE_CALLBACK_TOP10		102
#define RAW_MESSAGE_CALLBACK_NEXT		103


forward onGameMEStatsRank(command, client, String: message_prefix[], &Handle: datapack);
forward onGameMEStatsPublicCommand(command, client, String: message_prefix[], &Handle: datapack);
forward onGameMEStatsTop10(command, client, String: message_prefix[], &Handle: datapack);
forward onGameMEStatsNext(command, client, String: message_prefix[], &Handle: datapack);


functag gameMEStatsCallback public(command, payload, client, &Handle: datapack);
/**
 * Query gameME Stats data from a client
 * 
 * @param request		Request type (only 'playerinfo' available)
 * @param client		Client index.
 * @param func			Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryGameMEStats(String: request[], client, gameMEStatsCallback: callback, payload = 0);


functag gameMEStatsTop10Callback public(command, payload, &Handle: datapack);

/**
 * Query Top10 players from gameME Stats
 * 
 * @param request		Request type (currently only 'top10' available)
 * @param client		Client index.
 * @param func			Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryGameMEStatsTop10(String: request[], client, gameMEStatsTop10Callback: callback, payload = 0);


functag gameMEStatsNextCallback public(command, payload, client, &Handle: datapack);

/**
 * Query next players from gameME Stats for s specified client
 * 
 * @param request		Request type (currently only 'next' available)
 * @param client		Client index.
 * @param func			Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryGameMEStatsNext(String: request[], client, gameMEStatsNextCallback: callback, payload = 0);


functag gameMEStatsIntCallback public(command, payload, caller[MAXPLAYERS + 1], target[MAXPLAYERS + 1], const String: message_prefix[], const String: message[]);

/**
 * Query internal (preformatted) gameME Stats data
 * 
 * @param request		Request type.
 * @param client		Client index.
 * @param func			Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryIntGameMEStats(String: request[], client, gameMEStatsIntCallback: callback, payload = 0, limit = 0);


/**
 * Display internal gameME Stats menu.
 *
 * @param client    	The client index the menu is displayed to.
 * @param time    		How long should the menu be displayed.
 * @param message    	The menu message.
 * @param need_handler  Define, if a menu handler is needed.
 * @noreturn
 */
native DisplayGameMEStatsMenu(client, time, String: message[], need_handler); 


/**
 * Color gameME entitites
 *
 * @param message	String.
 */
native gameMEStatsColorEntities(String: message[]); 


public SharedPlugin:__pl_gameme = 
{
	name = "gameme",
	file = "gameme.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
}

#if !defined REQUIRE_PLUGIN
public __pl_gameme_SetNTVOptional()
{
	MarkNativeAsOptional("QueryGameMEStats");
	MarkNativeAsOptional("QueryGameMEStatsTop10");
	MarkNativeAsOptional("QueryGameMEStatsNext");
	MarkNativeAsOptional("QueryIntGameMEStats");
	MarkNativeAsOptional("DisplayGameMEStatsMenu");
	MarkNativeAsOptional("gameMEStatsColorEntities");
}
#endif
