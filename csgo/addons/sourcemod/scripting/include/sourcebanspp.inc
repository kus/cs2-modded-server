// *************************************************************************
//  This file is part of SourceBans++.
//
//  Copyright (C) 2014-2016 SourceBans++ Dev Team <https://github.com/sbpp>
//
//  SourceBans++ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, per version 3 of the License.
//
//  SourceBans++ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with SourceBans++. If not, see <http://www.gnu.org/licenses/>.
//
//  This file based off work(s) covered by the following copyright(s):
//
//   SourceBans 1.4.11
//   Copyright (C) 2007-2015 SourceBans Team - Part of GameConnect
//   Licensed under GNU GPL version 3, or later.
//   Page: <http://www.sourcebans.net/> - <https://github.com/GameConnect/sourcebansv1>
//
// *************************************************************************

#if defined _sourcebanspp_included
#endinput
#endif
#define _sourcebanspp_included

public SharedPlugin __pl_sourcebanspp =
{
	name = "sourcebans++",
	file = "sbpp_main.smx",
	#if defined REQUIRE_PLUGIN
	required = 1
	#else
	required = 0
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_sourcebanspp_SetNTVOptional()
{
	MarkNativeAsOptional("SBBanPlayer");
	MarkNativeAsOptional("SBPP_BanPlayer");
	MarkNativeAsOptional("SBPP_BanAccountId");
	MarkNativeAsOptional("SBPP_ReportPlayer");
}
#endif


/*********************************************************
 * Ban Player from server
 *
 * @param iAdmin	The client index of the admin who is banning the client
 * @param iTarget	The client index of the player to ban
 * @param iTime		The time to ban the player for (in minutes, 0 = permanent)
 * @param sReason	The reason to ban the player from the server
 * @noreturn
 *********************************************************/
#pragma deprecated Use SBPP_BanPlayer() instead.
native void SBBanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);

/*********************************************************
 * Ban Player from server
 *
 * @param iAdmin	The client index of the admin who is banning the client
 * @param iTarget	The client index of the player to ban
 * @param iTime		The time to ban the player for (in minutes, 0 = permanent)
 * @param sReason	The reason to ban the player from the server
 * @noreturn
 *********************************************************/
native void SBPP_BanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);
/*********************************************************
 * Ban Identity from server
 *
 * @param AccountId		The AccountId to ban as found in GetSteamAccountId
 * @param admin			The admin's client index
 * @param time			The time to ban the player for (in minutes, 0 = permanent)
 * @param reason		The reason to ban the player from the server
 * @param kick			True if to kick the banned player if he is inside the server.
 * @param name			The name of the banned client that owns the identity.
 * @noreturn
 *********************************************************/
native void SBPP_BanAccountId(const int AccountId, int iAdmin, int iTime, const char[] sReason, bool kick=true, const char[] Name="");

/*********************************************************
 * Reports a player
 *
 * @param iReporter	The client index of the reporter
 * @param iTarget	The client index of the player to report
 * @param sReason	The reason to report the player
 * @noreturn
 *********************************************************/
native void SBPP_ReportPlayer(int iReporter, int iTarget, const char[] sReason);

/*********************************************************
 * Called when the admin banning the player.
 *
 * @param iAdmin	The client index of the admin who is banning the client
 * @param iTarget    The client index of the player to ban
 * @param iTime      The time to ban the player for (in minutes, 0 = permanent)
 * @param sReason    The reason to ban the player from the server
 *********************************************************/
forward void SBPP_OnBanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);

/*********************************************************
 * Called when a new report is inserted
 *
 * @param iReporter	The client index of the reporter
 * @param iTarget	The client index of the player to report
 * @param sReason	The reason to report the player
 * @noreturn
 *********************************************************/
forward void SBPP_OnReportPlayer(int iReporter, int iTarget, const char[] sReason);

//Yarr!