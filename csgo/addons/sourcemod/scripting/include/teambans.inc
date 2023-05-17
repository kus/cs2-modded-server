#if defined _teambans_included
 #endinput
#endif
#define _teambans_included

#define TEAMBANS_PLUGIN_NAME "TeamBans"
#define TEAMBANS_PLUGIN_AUTHOR "Bara"
#define TEAMBANS_PLUGIN_VERSION "1.0.1"
#define TEAMBANS_PLUGIN_DESCRIPTION "With TeamBans you can ban players from a team. (CT and T ban aren't supported)"
#define TEAMBANS_PLUGIN_URL "www.bara.in"

#define TEAMBANS_SERVER 1
#define TEAMBANS_T 2
#define TEAMBANS_CT 3

#define TEAMBANS_TEAMNAME_SIZE 12
#define TEAMBANS_REASON_LENGTH 256

native bool TeamBans_IsClientBanned(int client);

native int TeamBans_GetClientTeam(int client);
native int TeamBans_GetClientLength(int client);
native int TeamBans_GetClientTimeleft(int client);
native void TeamBans_GetClientReason(int client, const char[] reason, int maxlength);

native void TeamBans_SetClientBan(int admin, int client, int team, int length, int timeleft, char[] reason);
native void TeamBans_DelClientBan(int admin, int client);

native void TeamBans_GetTeamNameByNumber(int team, const char[] name, int maxlength, int language = LANG_SERVER);
native int TeamBans_GetTeamNumberByName(char[] team);

forward void TeamBans_OnClientBan_Pre(int admin, int client, int team, int length, int timeleft, const char[] reason);
forward void TeamBans_OnClientBan_Post(int admin, int client, int team, int length, int timeleft, const char[] reason);
forward void TeamBans_OnClientOfflineBan_Pre(int admin, const char[] communityid, int team, int length, int timeleft, const char[] reason);
forward void TeamBans_OnClientOfflineBan_Post(int admin, const char[] communityid, int team, int length, int timeleft, const char[] reason);
forward void TeamBans_OnClientUnban_Pre(int admin, int client, int team, int length, const char[] reason);
forward void TeamBans_OnClientUnban_Post(int admin, int client, int team, int length, const char[] reason);
forward void TeamBans_OnClientOfflineUnban_Pre(int admin, const char[] communityid, int team, const char[] reason);
forward void TeamBans_OnClientOfflineUnban_Post(int admin, const char[] communityid, int team, const char[] reason);

stock bool IsTeamBansLoaded()
{
	return LibraryExists("teambans");
}

public SharedPlugin __pl_teambans = 
{
	name = "teambans",
	file = "teambans.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_teambans_SetNTVOptional()
{
	MarkNativeAsOptional("TeamBans_IsClientBanned");
	MarkNativeAsOptional("TeamBans_GetClientTeam");
	MarkNativeAsOptional("TeamBans_GetClientLength");
	MarkNativeAsOptional("TeamBans_GetClientTimeleft");
	MarkNativeAsOptional("TeamBans_GetClientReason");
	MarkNativeAsOptional("TeamBans_SetClientBan");
	MarkNativeAsOptional("TeamBans_DelClientBan");
	MarkNativeAsOptional("TeamBans_GetTeamNameByNumber");
	MarkNativeAsOptional("TeamBans_GetTeamNumberByName");
}
#endif