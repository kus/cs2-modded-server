/**
 * SourceBans Include File
 *
 * @author GameConnect
 * @version 2.0.0
 * @copyright SourceBans (C)2007-2016 GameConnect.net.  All rights reserved.
 * @package SourceBans
 * @link http://www.sourcebans.net
 */

#if defined _sb_bans_included
  #endinput
#endif
#define _sb_bans_included

/**
 * Reports a player to SourceBans
 *
 * @param client	The index of the reporting client
 * @param target	The index of the reported client
 * @param reason	The reason for reporting the player
 */
native void SB_ReportPlayer(int client, int target, const char[] reason);

public SharedPlugin __pl_sb_bans =
{
    name = "sb_bans",
    file = "sb_bans.smx",
    #if defined REQUIRE_PLUGIN
    required = 1
    #else
    required = 0
    #endif
};

#if !defined REQUIRE_PLUGIN
public __pl_sb_bans_SetNTVOptional()
{
    MarkNativeAsOptional("SB_ReportPlayer");
}
#endif
