/*
	KZTimer API Helper ~ Include File
*/

#if defined _KZTimer_API_included_
#endinput
#endif
#define _KZTimer_API_included_

#define KZTimerAPI_Version "1.2.0"

// ======================= NATIVES ====================== //

/**
 * Prints a chat message to the client
 *
 * @param client		client index who are we printing to
 * @param useprefix		whether to use prefix
 * @param format		Formatting rules
 * @param any			Variable number of format parameters
 * @noreturn
 */
native void KZTimerAPI_PrintToChat(int client, bool useprefix, const char[] format, any...);

/**
 * Sends a valid record to the Global API
 *
 * @param client		Client index who we are sending to the API
 * @param teleports		Teleports of the record
 * @param time			Time of the record 
 * @noreturn
 */
native void KZTimerAPI_InsertRecord(int client, int teleports, float time);

/**
 * Sends a valid jumpstat to the Global API
 *
 * @param client		Client index who we are sending to the API
 * @param jumptype		Jump type (longjump, bhop..) INT
 * @param distance		Jump distance (285.000)
 * @noreturn
 */
native void KZTimerAPI_InsertJumpstat(int client, int jumptype, float distance);

/**
 * Gets the current map's tier and prints it to the client
 *
 * @param client		Client index who we are printing to
 * @noreturn
 */
native void KZTimerAPI_PrintMapTier(int client);

/**
 * Gets the current map's global record and prints it to the client
 *
 * @param client		Client index who we are printing to
 * @noreturn
 */
native void KZTimerAPI_PrintGlobalRecord(int client);

/**
 * Gets the record top from the given map (current map if not specified)
 *
 * @param client			Client index who we are printing to
 * @param runType			Is the run "TP" or "PRO" run?
 * @param mapName			Map name we want records from, current map if not specified
 * @param tickRate			Tickrate of the record, current tickrate if not specified
 * @noreturn
 */
native void KZTimerAPI_PrintGlobalRecordTop(int client, char[] mapName = "", char[] runType = "pro", int tickRate = -1);


/**
 * Opens the global records selection menu for given client
 *
 * @param client			Client index who we are printing to
 * @noreturn
 */
native void KZTimerAPI_PrintGlobalRecordTopMenu(int client);

/**
 * Opens the global jumpstats jumptype selection menu for given client
 *
 * @param client			Client index who we are printing to
 * @noreturn
 */
native void KZTimerAPI_PrintGlobalJumpstatsTopMenu(int client);

/**
 * Globally bans the client from all Global servers
 *
 * @param client			Client index to ban
 * @param banType			Ban type (Ex. "strafe_hack", "bhop_macro"...)
 * @param banNotes			Notes of the ban
 * @param banStats			Stats of the ban (Usually Macrodox data)
 * @noreturn
 */
native void KZTimerAPI_InsertGlobalBan(int client, char[] banType, char[] banNotes, char[] banStats);

/**
 * Tells the client if the server is currently global
 *
 * @param client			Client index who we are printing to
 * @noreturn
 */
native void KZTimerAPI_GlobalCheck(int client);

// ======================= STOCKS ====================== //

stock char FormatRecordTime(float originalTime)
{
	char formatted[128];
	
	int roundedTime = RoundFloat(originalTime * 100);
	
	int centiseconds = roundedTime % 100;
	roundedTime = (roundedTime - centiseconds) / 100;
	int seconds = roundedTime % 60;
	roundedTime = (roundedTime - seconds) / 60;
	int minutes = roundedTime % 60;
	roundedTime = (roundedTime - minutes) / 60;
	int hours = roundedTime;
	
	if (hours == 0)
	{
		FormatEx(formatted, sizeof(formatted), "%02d:%02d.%02d", minutes, seconds, centiseconds);
	}
	else
	{
		FormatEx(formatted, sizeof(formatted), "%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds);
	}

	return formatted;
}

stock void KZTimerAPI_PrintToChatAll(bool addPrefix, const char[] format, any...)
{
	char buffer[1024];
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			SetGlobalTransTarget(client);
			VFormat(buffer, sizeof(buffer), format, 3);
			KZTimerAPI_PrintToChat(client, addPrefix, buffer);
		}
	}
}

// ======================= PLUGIN INFO ====================== //

public SharedPlugin __pl_KZTimer_API = 
{
	name = "KZTimer-API", 
	file = "KZTimer-API.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

// ======================= SET NATIVES OPTIONAL ====================== //

#if !defined REQUIRE_PLUGIN
public void __pl_KZTimer_API_SetNTVOptional()
{
	MarkNativeAsOptional("KZTimerAPI_PrintMapTier");
	MarkNativeAsOptional("KZTimerAPI_PrintGlobalRecord");
	MarkNativeAsOptional("KZTimerAPI_PrintGlobalRecordTop");
	MarkNativeAsOptional("KZTimerAPI_PrintGlobalRecordTopMenu");
	MarkNativeAsOptional("KZTimerAPI_PrintGlobalJumpstatsTopMenu");
	MarkNativeAsOptional("KZTimerAPI_InsertRecord");
	MarkNativeAsOptional("KZTimerAPI_InsertJumpstat");
	MarkNativeAsOptional("KZTimerAPI_InsertGlobalBan");
	MarkNativeAsOptional("KZTimerAPI_GlobalCheck");
}
#endif