
#if defined _sqlitebans_included
	#endinput
#endif
#define _sqlitebans_included

enum enPenaltyType
{
	Penalty_Ban = 0,
	Penalty_Gag,
	Penalty_Mute,
	Penalty_Silence,
	enPenaltyType_LENGTH
}


stock void PenaltyAliasByType(enPenaltyType PenaltyType, char[] PenaltyAlias, int len, bool bPast = true)
{
	if(bPast)
	{
		switch(PenaltyType)
		{
			case Penalty_Gag: FormatEx(PenaltyAlias, len, "gagged");
			case Penalty_Mute: FormatEx(PenaltyAlias, len, "muted");
			case Penalty_Silence: FormatEx(PenaltyAlias, len, "silenced");
		}
	}
	else
	{
		switch(PenaltyType)
		{
			case Penalty_Gag: FormatEx(PenaltyAlias, len, "gag");
			case Penalty_Mute: FormatEx(PenaltyAlias, len, "mute");
			case Penalty_Silence: FormatEx(PenaltyAlias, len, "silence");
		}
	}
}

/**
 * Bans a client.
 *
 * @param client		Client being banned.
 * @param time			Time (in minutes) to ban (0 = permanent).
 * @param flags			BANFLAG_AUTHID for an authid ban, BANFLAG_IP for an IP ban, BANFLAG_AUTO for a full ban. ( both IP and AuthId )
 * 						If you added "|BANFLAG_NOKICK" on top of the first flag and kick_message is not null, SQLiteBans will handle the kick message
 * 						and will kick the client.
 * @param reason		Reason to ban the client for.
 * @param kick_message	Message to display to the user when kicking. If you added "|BANFLAG_NOKICK" to the flags, change this to anything you want
 *						and SQLiteBans will kick the client by itself ( must not be null, the actual value of kick_message doesn't matter at all )
 * @param command		Command string to identify the source. If this is left empty the ban will fail and
 *						the regular banning mechanism of the game will be used.
 * @param source		The admin ( doesn't have to be an admin ) that is doing the banning
 *						or 0 for console.
 * @return				True on success, false on failure.
 * @error				Invalid client index or client not in game.
 * @note				In order to let SQLiteBans kick the client by itself, set kick_message to anything you want and add "|BANFLAG_NOKICK" to the flags you've set.
 * @note				At the current version of 1.2, the param command has no meaning and it only mustn't be null.
 */

/*
native bool BanClient(int client, 
					  int time, 
					  int flags, 
					  const char[] reason, 
					  const char[] kick_message="", 
					  const char[] command="",
					  any source=0);

*/

/**
 * Bans an identity (either an IP address or auth string).
 *
 * @param identity		String to ban (ip or authstring).
 * @param time			Time to ban for (0 = permanent).
 * @param flags			BANFLAG_AUTHID if the identity is an AuthId, BANFLAG_IP if the identity is an IP Address, BANFLAG_AUTO for full ban, identity is either and must check notes
 * @param reason		Ban reason string.
 * @param command		Command string to identify the source. If this is left empty the ban will fail and
 *						the regular banning mechanism of the game will be used.
 * @param source		The admin ( doesn't have to be an admin ) that is doing the banning
 *						or 0 for console.
 * @return				True on success, false on failure.
 * @note				At the current version of 1.2, the param command has no meaning and it only mustn't be null.
 * @note 				If flags are set to BANFLAG_AUTO, you must call the forward SQLiteBans_OnBanIdentity and edit both AuthId & IPAddress
 */

/*
native bool BanIdentity(const char[] identity, 
						int time, 
						int flags, 
						const char[] reason,
						const char[] command="",
						any source=0);

*/

// returns false if client cannot be authenticated ( GetClientAuthId ) or if requires penalty extension with dontExtend set to true.
native bool SQLiteBans_CommPunishClient(int client, enPenaltyType PenaltyType, int time, const char[] reason, int source, bool dontExtend);

// always returns true unless you gave an invalid penalty type, which will result in a native error.
native bool SQLiteBans_CommPunishIdentity(const char[] AuthId, enPenaltyType PenaltyType, const char[] name, int time, const char[] reason, int source, bool dontExtend);

native bool SQLiteBans_CommUnpunishClient(int client, enPenaltyType PenaltyType, int source);
native bool SQLiteBans_CommUnpunishIdentity(const char[] AuthId, enPenaltyType PenaltyType, int source);


// flags = ban flags
// identity = identity that is getting banned.
// AuthId = copyback of authid to ban. Only used with flags & BANFLAG_AUTO
// IPAddress = copyback of IP to ban. Only used with flags & BANFLAG_AUTO
// Name = Player's name to ban
// @note -			This is only called for identity bans, while OnBanIdentity_Post applies on ALL bans.
// @noreturn
forward void SQLiteBans_OnBanIdentity(int flags, const char identity[35], char AuthId[35], char IPAddress[32], char Name[64]);

// AuthId = copyback of authid to ban. Only used with flags & BANFLAG_AUT
// Name = Player's name to ban
// @note -			This is only called for identity bans, while OnBanIdentity_Post applies on ALL bans.
// @note - 			This purposely hides IP Address to prevent issues of IP address leaks.
// @noreturn
forward void SQLiteBans_OnBanIdentity_Post(const char AuthId[35], const char Name[64], const char AdminAuthId[35], const char AdminName[64], const char reason[256], int time);

// PenaltyType = Penalty type as found in enum enPenaltyType.
// AuthId = copyback of authid to ban. Only used with flags & BANFLAG_AUTO
// Name = Player's name to ban
// @note -			This is only called for identity bans, while OnBanIdentity_Post applies on ALL bans.
// @note - 			This purposely hides IP Address to prevent issues of IP address leaks.
// @noreturn
forward void SQLiteBans_OnCommPunishIdentity_Post(enPenaltyType PenaltyType, const char AuthId[35], const char Name[64], const char AdminAuthId[35], const char AdminName[64], const char reason[256], int time);

// AuthId = copyback of authid to ban.
// Name = Player's name to ban
// @note -			This is only called for identity bans, while OnBanIdentity_Post applies on ALL bans.
// @note - 			This purposely hides IP Address to prevent issues of IP address leaks.
// @noreturn
forward void SQLiteBans_OnUnbanIdentity_Post(const char AuthId[35], const char Name[64], const char AdminAuthId[35], const char AdminName[64]);

// AuthId = copyback of authid to ban.
// Name = Player's name to ban
// @note -			This is only called for identity bans, while OnBanIdentity_Post applies on ALL bans.
// @note - 			This purposely hides IP Address to prevent issues of IP address leaks.
// @noreturn
forward void SQLiteBans_OnCommUnpunishIdentity_Post(enPenaltyType PenaltyType, const char AuthId[35], const char Name[64], const char AdminAuthId[35], const char AdminName[64]);

public SharedPlugin __pl_SQLiteBans = {
	name = "SQLiteBans", file = "SQLiteBans.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_SQLiteBans_SetNTVOptional() {
  MarkNativeAsOptional("SQLiteBans_CommPunishClient");
  MarkNativeAsOptional("SQLiteBans_CommPunishIdentity");
  MarkNativeAsOptional("SQLiteBans_CommUnpunishClient");
  MarkNativeAsOptional("SQLiteBans_CommUnpunishIdentity");
}
#endif