#if defined _store_logging_included
#endinput
#endif
#define _store_logging_included

/*
	This whole system was recommended by Arrow, not me. Keep that in mind.
	Based on the standard logging format, more information here: https://en.wikipedia.org/wiki/Syslog
*/

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: System is unusable
 * Example: This level should not be used by applications.
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogEmergency(const char[] format, any...);

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: Should be corrected immediately
 * Example: Loss of the primary ISP connection.
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogAlert(const char[] format, any...);

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: Critical conditions
 * Example: A failure in the system's primary application.
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogCritical(const char[] format, any...);

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: Error conditions
 * Example: An application has exceeded its file storage limit and attempts to write are failing.
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogError(const char[] format, any...);

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: May indicate that an error will occur if action is not taken.
 * Example: A non-root file system has only 2GB remaining.
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogWarning(const char[] format, any...);

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: Events that are unusual, but not error conditions.
 * Example: N/A
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogNotice(const char[] format, any...);

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: Normal operational messages that require no action.
 * Example: An application has started, paused or ended successfully.
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogInformational(const char[] format, any...);

/**
 * Creates a log to a file and if enabled, queries a database to insert the log.
 * Usage: Information useful to developers for debugging the application.
 * Example: N/A
 *
 * @param format        A format string. See http://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)
 * @param ...           Variable number of format parameters.
 *
 * @noreturn
 */
native void Store_LogDebug(const char[] format, any...);

public SharedPlugin __pl_store_logging = 
{
	name = "store-logging", 
	file = "store-logging.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if defined REQUIRE_PLUGIN
public __pl_store_logging_SetNTVOptional()
{
	MarkNativeAsOptional("Store_LogEmergency");
	MarkNativeAsOptional("Store_LogAlert");
	MarkNativeAsOptional("Store_LogCritical");
	MarkNativeAsOptional("Store_LogError");
	MarkNativeAsOptional("Store_LogWarning");
	MarkNativeAsOptional("Store_LogNotice");
	MarkNativeAsOptional("Store_LogInformational");
	MarkNativeAsOptional("Store_LogDebug");
}
#endif
