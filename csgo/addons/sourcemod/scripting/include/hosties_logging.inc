#if defined _hosties_logging_included
 #endinput
#endif
#define _hosties_logging_included

#define ExLo_VERSION "1.0.0"

enum H_LOG_LEVEL
{
	DEFAULT = 0,
	TRACE,
	DEBUG,
	INFO,
	WARN,
	ERROR
}

new String:g_sHLogLevel[6][32] = {
	"default",
	"trace",
	"debug",
	"info",
	"warn",
	"error"
}

/**
 * Logs a message to any file.
 *
 * @param path			Path to file (default: addons/sourcemod/logs).
 * @param file			File name (default: file).
 * @param date			Date for better overview (default: no date).
 * @param format		String format.
 * @param ...			Format arguments.
 * @noreturn
 * @error				File could not be opened/written.
 */
stock Log_Default(const String:path[] = "", const String:file[] = "file", const String:date[] = "",  const String:format[], any:...)
{
	decl String:sBuffer[1024];
	VFormat(sBuffer, sizeof(sBuffer), format, 5);
	Log_File(path, file, date, DEFAULT, sBuffer);
}

/**
 * Logs a trace message to any file.
 *
 * @param path			Path to file (default: addons/sourcemod/logs).
 * @param file			File name (default: file).
 * @param date			Date for better overview (default: no date).
 * @param format		String format.
 * @param ...			Format arguments.
 * @noreturn
 * @error				File could not be opened/written.
 */
stock Log_Trace(const String:path[] = "", const String:file[] = "file", const String:date[] = "",  const String:format[], any:...)
{
	decl String:sBuffer[1024];
	VFormat(sBuffer, sizeof(sBuffer), format, 5);
	Log_File(path, file, date, TRACE, sBuffer);
}

/**
 * Logs a debug message to any file.
 *
 * @param path			Path to file (default: addons/sourcemod/logs).
 * @param file			File name (default: file).
 * @param date			Date for better overview (default: no date).
 * @param format		String format.
 * @param ...			Format arguments.
 * @noreturn
 * @error				File could not be opened/written.
 */
stock Log_Debug(const String:path[] = "", const String:file[] = "file", const String:date[] = "",  const String:format[], any:...)
{
	decl String:sBuffer[1024];
	VFormat(sBuffer, sizeof(sBuffer), format, 5);
	Log_File(path, file, date, DEBUG, sBuffer);
}

/**
 * Logs a info message to any file.
 *
 * @param path			Path to file (default: addons/sourcemod/logs).
 * @param file			File name (default: file).
 * @param date			Date for better overview (default: no date).
 * @param format		String format.
 * @param ...			Format arguments.
 * @noreturn
 * @error				File could not be opened/written.
 */
stock Log_Info(const String:path[] = "", const String:file[] = "file", const String:date[] = "",  const String:format[], any:...)
{
	decl String:sBuffer[1024];
	VFormat(sBuffer, sizeof(sBuffer), format, 5);
	Log_File(path, file, date, INFO, sBuffer);
}

/**
 * Logs a warning message to any file.
 *
 * @param path			Path to file (default: addons/sourcemod/logs).
 * @param file			File name (default: file).
 * @param date			Date for better overview (default: no date).
 * @param format		String format.
 * @param ...			Format arguments.
 * @noreturn
 * @error				File could not be opened/written.
 */
stock Log_Warn(const String:path[] = "", const String:file[] = "file", const String:date[] = "",  const String:format[], any:...)
{
	decl String:sBuffer[1024];
	VFormat(sBuffer, sizeof(sBuffer), format, 5);
	Log_File(path, file, date, WARN, sBuffer);
}

/**
 * Logs a error message to any file.
 *
 * @param path			Path to file (default: addons/sourcemod/logs).
 * @param file			File name (default: file).
 * @param date			Date for better overview (default: no date).
 * @param format		String format.
 * @param ...			Format arguments.
 * @noreturn
 * @error				File could not be opened/written.
 */
stock Log_Error(const String:path[] = "", const String:file[] = "file", const String:date[] = "",  const String:format[], any:...)
{
	decl String:sBuffer[1024];
	VFormat(sBuffer, sizeof(sBuffer), format, 5);
	Log_File(path, file, date, ERROR, sBuffer);
}

/**
 * Logs a message to any file.
 * Level: 0/6+ - DEFAULT, 1 - TRACE, 2 - DEBUG,
 *        3 - INFO, 4 - WARN, 5 - ERROR
 *
 * @param path			Path to file (default: addons/sourcemod/logs).
 * @param file			File name (default: file).
 * @param date			Date for better overview (default: no date).
 * @param level			Log level (default: INFO).
 * @param format		String format.
 * @param ...			Format arguments.
 * @noreturn
 * @error				File could not be opened/written.
 */
stock Log_File(const String:path[] = "", const String:file[] = "file", const String:date[] = "", H_LOG_LEVEL:level = INFO, const String:format[], any:...)
{
	decl String:sPath[PLATFORM_MAX_PATH + 1];
	decl String:sLevelPath[PLATFORM_MAX_PATH + 1];
	decl String:sFile[PLATFORM_MAX_PATH + 1];
	decl String:sBuffer[1024];

	if(StrEqual(path, "", false))
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "logs");
	}
	else
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "logs/%s", path);
		
		if(!DirExists(sPath))
		{
			CreateDirectory(sPath, 755);
		}
	}

	if(level < TRACE || level > ERROR)
	{
		Format(sLevelPath, sizeof(sLevelPath), "%s", sPath);
	}
	else
	{
		Format(sLevelPath, sizeof(sLevelPath), "%s/%s", sPath, g_sHLogLevel[level]);
	}

	
	if(!DirExists(sLevelPath))
	{
		CreateDirectory(sLevelPath, 755);
	}

	if(StrEqual(date, "", false))
	{
		Format(sFile, sizeof(sFile), "%s/%s.log", sLevelPath, file);
	}
	else
	{
		Format(sFile, sizeof(sFile), "%s/%s_%s.log", sLevelPath, file, date);
	}

	VFormat(sBuffer, sizeof(sBuffer), format, 6);

	if(GetEngineVersion() == Engine_CSGO)
	{
		C_RemoveTags(sBuffer, sizeof(sBuffer));
	}
	else if (GetEngineVersion() == Engine_CSS)
	{
		MC_RemoveTags(sBuffer, sizeof(sBuffer));
	}

	LogToFile(sFile, sBuffer);
}