#if defined _autoexecconfig_included
	#endinput
#endif
#define _autoexecconfig_included


#include <sourcemod>


// Append
#define AUTOEXEC_APPEND_BAD_FILENAME    0
#define AUTOEXEC_APPEND_FILE_NOT_FOUND  1
#define AUTOEXEC_APPEND_BAD_HANDLE      2
#define AUTOEXEC_APPEND_SUCCESS         3



// Find
#define AUTOEXEC_FIND_BAD_FILENAME     10
#define AUTOEXEC_FIND_FILE_NOT_FOUND   11
#define AUTOEXEC_FIND_BAD_HANDLE       12
#define AUTOEXEC_FIND_NOT_FOUND        13
#define AUTOEXEC_FIND_SUCCESS          14



// Clean
#define AUTOEXEC_CLEAN_FILE_NOT_FOUND  20
#define AUTOEXEC_CLEAN_BAD_HANDLE      21
#define AUTOEXEC_CLEAN_SUCCESS         22



// General
#define AUTOEXEC_NO_CONFIG             30



// Formatter
#define AUTOEXEC_FORMAT_BAD_FILENAME   40
#define AUTOEXEC_FORMAT_SUCCESS        41



// Global variables
static char g_sConfigFile[PLATFORM_MAX_PATH];
static char g_sRawFileName[PLATFORM_MAX_PATH];
static char g_sFolderPath[PLATFORM_MAX_PATH];

static StringMap g_hConvarTrie = null;
static bool g_bCacheEnabled = false;

static bool g_bCreateFile = false;
static Handle g_hPluginHandle = null;



// Workaround for now
static int g_iLastFindResult;
static int g_iLastAppendResult;




/**
 * Returns the last result from the parser.
 *
 * @return			Returns one of the AUTOEXEC_FIND values or -1 if not set.
*/
stock int AutoExecConfig_GetFindResult()
{
	return g_iLastFindResult;
}





/**
 * Returns the last result from the appender.
 *
 * @return			Returns one of the AUTOEXEC_APPEND values or -1 if not set.
*/
stock int AutoExecConfig_GetAppendResult()
{
	return g_iLastAppendResult;
}


/**
 * Set if the config file should be created if it doesn't exist yet.
 *
 * @param create 	True if config file should be created, false otherwise.
 * @noreturn
 */
stock void AutoExecConfig_SetCreateFile(bool create)
{
	g_bCreateFile = create;
}


/**
 * Returns if the config file should be created if it doesn't exist.
 *
 * @return			Returns true, if the config file should be created or false if it should not.
 */
stock bool AutoExecConfig_GetCreateFile()
{
	return g_bCreateFile;
}


/**
 * Set the plugin for which the config file should be created.
 * Set to null to use the calling plugin.
 * Used to print the correct filename in the top comment when creating the file.
 *
 * @param plugin 	The plugin to create convars for or null to use the calling plugin.
 * @noreturn
 */
stock void AutoExecConfig_SetPlugin(Handle plugin)
{
	g_hPluginHandle = plugin;
}


/**
 * Returns the plugin for which the config file is created.
 *
 * @return			The plugin handle
 */
stock Handle AutoExecConfig_GetPlugin()
{
	return g_hPluginHandle;
}


/**
 * Set the global autoconfigfile used by functions of this file.
 *
 * @param file			Name of the config file, path and .cfg extension is being added if not given.
 * @param folder		Folder under cfg/ to use.  By default this is "sourcemod."
 * @return				True if formatter returned success, false otherwise.
*/
stock bool AutoExecConfig_SetFile(char[] file, char[] folder="sourcemod")
{
	Format(g_sConfigFile, sizeof(g_sConfigFile), "%s", file);
	
	// Global buffers for cfg execution
	strcopy(g_sRawFileName, sizeof(g_sRawFileName), file);
	strcopy(g_sFolderPath, sizeof(g_sFolderPath), folder);
	
	
	// Format the filename
	return AutoExecConfig_FormatFileName(g_sConfigFile, sizeof(g_sConfigFile), folder) == AUTOEXEC_FORMAT_SUCCESS;
}






/**
 * Get the formatted autoconfigfile used by functions of this file.
 *
 * @param buffer		String to format.
 * @param size			Maximum size of buffer
 * @return				True if filename was set, false otherwise.
*/
stock bool AutoExecConfig_GetFile(char[] buffer,int size)
{
	if (strlen(g_sConfigFile) > 0)
	{
		strcopy(buffer, size, g_sConfigFile);
		
		return true;
	}
	
	// Security for decl users
	buffer[0] = '\0';
	
	return false;
}






/**
 * Creates a convar and appends it to the autoconfigfile if not found.
 * FCVAR_DONTRECORD will be skipped.
 *
 * @param name			Name of new convar.
 * @param defaultValue	String containing the default value of new convar.
 * @param description	Optional description of the convar.
 * @param flags			Optional bitstring of flags determining how the convar should be handled. See FCVAR_* constants for more details.
 * @param hasMin		Optional boolean that determines if the convar has a minimum value.
 * @param min			Minimum floating point value that the convar can have if hasMin is true.
 * @param hasMax		Optional boolean that determines if the convar has a maximum value.
 * @param max			Maximum floating point value that the convar can have if hasMax is true.
 * @return				A handle to the newly created convar. If the convar already exists, a handle to it will still be returned.
 * @error				Convar name is blank or is the same as an existing console command.
*/
stock ConVar AutoExecConfig_CreateConVar(const char[] name, const char[] defaultValue, const char[] description="", int flags=0, bool hasMin=false, float min=0.0, bool hasMax=false, float max=0.0)
{
	// If configfile was set and convar has no dontrecord flag
	if (!(flags & FCVAR_DONTRECORD) && strlen(g_sConfigFile) > 0)
	{
		// Reset the results
		g_iLastFindResult = -1;
		g_iLastAppendResult = -1;
		
		
		// Add it if not found
		char buffer[64];
		
		g_iLastFindResult = AutoExecConfig_FindValue(name, buffer, sizeof(buffer), true);
		
		// We only add this convar if it doesn't exist, or the file doesn't exist and it should be auto-generated
		if (g_iLastFindResult == AUTOEXEC_FIND_NOT_FOUND || (g_iLastFindResult == AUTOEXEC_FIND_FILE_NOT_FOUND && g_bCreateFile))
		{
			g_iLastAppendResult = AutoExecConfig_AppendValue(name, defaultValue, description, flags, hasMin, min, hasMax, max);
		}
	}
	
	
	// Create the convar
	return CreateConVar(name, defaultValue, description, flags, hasMin, min, hasMax, max);
}




/**
 * Executes the autoconfigfile, and adds it to the OnConfigsExecuted forward.
 * If we didn't created it already we let SourceMod create it.
 *
 * @noreturn
*/
stock void AutoExecConfig_ExecuteFile()
{
	// Only let sourcemod create the file, if we didn't do that already. 
	AutoExecConfig(!g_bCreateFile, g_sRawFileName, g_sFolderPath);
}





/**
 * Formats a autoconfigfile, prefixes path and adds .cfg extension if missed.
 *
 * @param buffer		String to format.
 * @param size			Maximum size of buffer.
 * @return				Returns one of the AUTOEXEC_FORMAT values..
*/
stock static int AutoExecConfig_FormatFileName(char[] buffer, int size, char[] folder="sourcemod")
{
	// No config set
	if (strlen(g_sConfigFile) < 1)
	{
		return AUTOEXEC_NO_CONFIG;
	}
	
	
	// Can't be an cfgfile
	if (StrContains(g_sConfigFile, ".cfg") == -1 && strlen(g_sConfigFile) < 4)
	{
		return AUTOEXEC_FORMAT_BAD_FILENAME;
	}
	
	
	// Pathprefix
	char pathprefixbuffer[PLATFORM_MAX_PATH];
	if (strlen(folder) > 0)
	{
		Format(pathprefixbuffer, sizeof(pathprefixbuffer), "cfg/%s/", folder);
	}
	else
	{
		Format(pathprefixbuffer, sizeof(pathprefixbuffer), "cfg/");
	}
	
	
	char filebuffer[PLATFORM_MAX_PATH];
	filebuffer[0] = '\0';
	
	// Add path if file doesn't begin with it
	if (StrContains(buffer, pathprefixbuffer) != 0)
	{
		StrCat(filebuffer, sizeof(filebuffer), pathprefixbuffer);
	}
	
	StrCat(filebuffer, sizeof(filebuffer), g_sConfigFile);
	
	
	// Add .cfg extension if file doesn't end with it
	if (StrContains(filebuffer[strlen(filebuffer) - 4], ".cfg") != 0)
	{
		StrCat(filebuffer, sizeof(filebuffer), ".cfg");
	}
	
	strcopy(buffer, size, filebuffer);
	
	return AUTOEXEC_FORMAT_SUCCESS;
}






/**
 * Appends a convar to the global autoconfigfile
 *
 * @param name			Name of new convar.
 * @param defaultValue	String containing the default value of new convar.
 * @param description	Optional description of the convar.
 * @param flags			Optional bitstring of flags determining how the convar should be handled. See FCVAR_* constants for more details.
 * @param hasMin		Optional boolean that determines if the convar has a minimum value.
 * @param min			Minimum floating point value that the convar can have if hasMin is true.
 * @param hasMax		Optional boolean that determines if the convar has a maximum value.
 * @param max			Maximum floating point value that the convar can have if hasMax is true.
 * @return				Returns one of the AUTOEXEC_APPEND values
*/
stock int AutoExecConfig_AppendValue(const char[] name, const char[] defaultValue, const char[] description, int flags, bool hasMin, float min, bool hasMax, float max)
{
	// No config set
	if (strlen(g_sConfigFile) < 1)
	{
		return AUTOEXEC_NO_CONFIG;
	}
	
	
	char filebuffer[PLATFORM_MAX_PATH];
	strcopy(filebuffer, sizeof(filebuffer), g_sConfigFile);
	
	
	//PrintToServer("pathbuffer: %s", filebuffer);
	
	bool bFileExists = FileExists(filebuffer);
	
	if (g_bCreateFile || bFileExists)
	{
		// If the file already exists we open it in append mode, otherwise we use a write mode which creates the file
		File fFile = OpenFile(filebuffer, (bFileExists ? "a" : "w"));
		char writebuffer[2048];
		
		
		if (fFile == null)
		{
			return AUTOEXEC_APPEND_BAD_HANDLE;
		}
		
		// We just created the file, so add some header about version and stuff
		if (g_bCreateFile && !bFileExists)
		{
			fFile.WriteLine( "// This file was auto-generated by AutoExecConfig read and append beta");
			
			GetPluginFilename(g_hPluginHandle, writebuffer, sizeof(writebuffer));
			Format(writebuffer, sizeof(writebuffer), "// ConVars for plugin \"%s\"", writebuffer);
			fFile.WriteLine(writebuffer);
		}
		
		// Spacer
		fFile.WriteLine("\n");
		

		// This is used for multiline comments
		int newlines = GetCharCountInStr('\n', description);
		if (newlines == 0)
		{
			// We have no newlines, we can write the description to the file as is
			Format(writebuffer, sizeof(writebuffer), "// %s", description);
			fFile.WriteLine(writebuffer);
		}
		else
		{
			char[][] newlineBuf = new char[newlines +1][2048];
			ExplodeString(description, "\n", newlineBuf, newlines +1, 2048, false);
			
			// Each newline gets a commented newline
			for (int i; i <= newlines; i++)
			{
				if (strlen(newlineBuf[i]) > 0)
				{
					fFile.WriteLine("// %s", newlineBuf[i]);
				}
			}
		}
		
		
		// Descspacer
		fFile.WriteLine("// -");
		
		
		// Default
		Format(writebuffer, sizeof(writebuffer), "// Default: \"%s\"", defaultValue);
		fFile.WriteLine(writebuffer);
		
		
		// Minimum
		if (hasMin)
		{		
			Format(writebuffer, sizeof(writebuffer), "// Minimum: \"%f\"", min);
			fFile.WriteLine(writebuffer);
		}
		
		
		// Maximum
		if (hasMax)
		{
			Format(writebuffer, sizeof(writebuffer), "// Maximum: \"%f\"", max);
			fFile.WriteLine(writebuffer);
		}
		
		
		// Write end and defaultvalue
		Format(writebuffer, sizeof(writebuffer), "%s \"%s\"", name, defaultValue);
		fFile.WriteLine(writebuffer);
		
		
		fFile.Close();
		
		
		// Clean up the file
		//AutoExecConfig_CleanFile(filebuffer, false);
		
		
		return AUTOEXEC_APPEND_SUCCESS;
	}
	
	return AUTOEXEC_APPEND_FILE_NOT_FOUND;
}






/**
 * Returns a convars value from the global autoconfigfile
 *
 * @param cvar				Cvar to search for.
 * @param value				Buffer to store result into.
 * @param size				Maximum size of buffer.
 * @param caseSensitive		Whether or not the search should be case sensitive.
 * @return					Returns one of the AUTOEXEC_FIND values
*/
stock int AutoExecConfig_FindValue(const char[] cvar, char[] value, int size, bool caseSensitive=false)
{
	// Security for decl users
	value[0] = '\0';
	
	
	// No config set
	if (strlen(g_sConfigFile) < 1)
	{
		return AUTOEXEC_NO_CONFIG;
	}
	
	if (g_bCacheEnabled)
	{
		char sTrieValue[64];
		
		if (g_hConvarTrie.GetString(cvar, sTrieValue, sizeof(sTrieValue)))
		{
			strcopy(value, size, sTrieValue);
			
			return AUTOEXEC_FIND_SUCCESS;
		}
		
		return AUTOEXEC_FIND_NOT_FOUND;
	}
	
	
	char filebuffer[PLATFORM_MAX_PATH];
	strcopy(filebuffer, sizeof(filebuffer), g_sConfigFile);
	
	
	
	//PrintToServer("pathbuffer: %s", filebuffer);
	
	bool bFileExists = FileExists(filebuffer);
	
	// We want to create the config file and it doesn't exist yet.
	if (g_bCreateFile && !bFileExists)
	{
		return AUTOEXEC_FIND_FILE_NOT_FOUND;
	}
	
	
	if (bFileExists)
	{
		File fFile = OpenFile(filebuffer, "r");
		int valuestart;
		int valueend;
		int cvarend;
		
		// Just an reminder to self, leave the values that high
		char sConvar[64];
		char sValue[64];
		char readbuffer[2048];
		char copybuffer[2048];
		
		if (fFile == null)
		{
			return AUTOEXEC_FIND_BAD_HANDLE;
		}
		
		
		while (!fFile.EndOfFile() && fFile.ReadLine(readbuffer, sizeof(readbuffer)))
		{
			// Is a comment or not valid
			if (IsCharSpace(readbuffer[0]) || readbuffer[0] == '/' || !IsCharAlpha(readbuffer[0]))
			{
				continue;
			}
			
			
			// Has not enough spaces, must have at least 1
			if (GetCharCountInStr(' ', readbuffer) < 1)
			{
				continue;
			}

			
			// Ignore cvars which aren't quoted
			if (GetCharCountInStr('"', readbuffer) != 2)
			{
				continue;
			}
			
			
			
			// Get the start of the value
			if ( (valuestart = StrContains(readbuffer, "\"")) == -1 )
			{
				continue;
			}
			
			
			// Get the end of the value
			if ( (valueend = StrContains(readbuffer[valuestart+1], "\"")) == -1 )
			{
				continue;
			}
			
			
			// Get the start of the cvar, 
			if ( (cvarend = StrContains(readbuffer, " ")) == -1 || cvarend >= valuestart)
			{
				continue;
			}
			
			
			// Skip if cvarendindex is before valuestartindex
			if (cvarend >= valuestart)
			{
				continue;
			}
			
			
			// Convar
			// Tempcopy for security
			strcopy(copybuffer, sizeof(copybuffer), readbuffer);
			copybuffer[cvarend] = '\0';
			
			strcopy(sConvar, sizeof(sConvar), copybuffer);
			

			// Value
			// Tempcopy for security
			strcopy(copybuffer, sizeof(copybuffer), readbuffer[valuestart+1]);
			copybuffer[valueend] = '\0';
			
			strcopy(sValue, sizeof(sValue), copybuffer);
			
			
			//PrintToServer("Cvar %s has a value of %s", sConvar, sValue);
			
			if (StrEqual(sConvar, cvar, caseSensitive))
			{
				Format(value, size, "%s", sConvar);
				
				fFile.Close();
				return AUTOEXEC_FIND_SUCCESS;
			}					
		}
		
		fFile.Close();	
		return AUTOEXEC_FIND_NOT_FOUND;
	}
	
	
	return AUTOEXEC_FIND_FILE_NOT_FOUND;
}






/**
 * Cleans the global autoconfigfile from too much spaces
 *
 * @return					One of the AUTOEXEC_CLEAN values.
*/
stock int AutoExecConfig_CleanFile()
{
	// No config set
	if (strlen(g_sConfigFile) < 1)
	{
		return AUTOEXEC_NO_CONFIG;
	}
	
	
	char sfile[PLATFORM_MAX_PATH];
	strcopy(sfile, sizeof(sfile), g_sConfigFile);
	
	
	// Security
	if (!FileExists(sfile))
	{
		return AUTOEXEC_CLEAN_FILE_NOT_FOUND;
	}
	
	
	
	char sfile2[PLATFORM_MAX_PATH];
	Format(sfile2, sizeof(sfile2), "%s_tempcopy", sfile);
	
	
	char readbuffer[2048];
	int count;
	bool firstreached;
	
	
	// Open files
	File fFile1 = OpenFile(sfile, "r");
	File fFile2 = OpenFile(sfile2, "w");
	
	
	
	// Check filehandles
	if (fFile1 == null || fFile2 == null)
	{
		if (fFile1 != null)
		{
			//PrintToServer("Handle1 invalid");
			fFile1.Close();
		}
		
		if (fFile2 != null)
		{
			//PrintToServer("Handle2 invalid");
			fFile2.Close();
		}
		
		return AUTOEXEC_CLEAN_BAD_HANDLE;
	}
	
	
	
	while (!fFile1.EndOfFile() && fFile1.ReadLine(readbuffer, sizeof(readbuffer)))
	{
		// Is space
		if (IsCharSpace(readbuffer[0]))
		{
			count++;
		}
		// No space, count from start
		else
		{
			count = 0;
		}
		
		
		// Don't write more than 1 space if seperation after informations have been reached
		if (count < 2 || !firstreached)
		{
			ReplaceString(readbuffer, sizeof(readbuffer), "\n", "");
			fFile2.WriteLine(readbuffer);
		}
		
		
		// First bigger seperation after informations has been reached
		if (count == 2)
		{
			firstreached = true;
		}
	}
	
	
	fFile1.Close();
	fFile2.Close();
	
	
	// This might be a risk, for now it works
	DeleteFile(sfile);
	RenameFile(sfile, sfile2);
	
	return AUTOEXEC_CLEAN_SUCCESS;
}






/**
 * Returns how many times the given char occures in the given string.
 *
 * @param str		String to search for in.
 * @return			Occurences of the given char found in string.
*/
stock static int GetCharCountInStr(int character, const char[] str)
{
	int len = strlen(str);
	int count;
	
	for (int i; i < len; i++)
	{
		if (str[i] == character)
		{
			count++;
		}
	}
	
	return count;
}






/**
 * Reads the existing config file and caches any convars and values that were found.
 *
 * @param str		String to search for in.
 * @return			True when config existed and could be read, false otherwise.
*/
stock bool AutoExecConfig_CacheConvars()
{
	if (g_hConvarTrie == null)
	{
		g_hConvarTrie = new StringMap();
	}
		
	// No config set
	if (strlen(g_sConfigFile) < 1)
	{
		return false;
	}
	
	
	char filebuffer[PLATFORM_MAX_PATH];
	strcopy(filebuffer, sizeof(filebuffer), g_sConfigFile);
	
	
	
	//PrintToServer("pathbuffer: %s", filebuffer);
	
	bool bFileExists = FileExists(filebuffer);
	
	// We want to create the config file and it doesn't exist yet.
	if (!bFileExists)
	{
		return false;
	}
	
	
	
	File fFile = OpenFile(filebuffer, "r");
	int valuestart;
	int valueend;
	int cvarend;
	
	// Just an reminder to self, leave the values that high
	char sConvar[64];
	char sValue[64];
	char readbuffer[2048];
	char copybuffer[2048];
	
	if (fFile == null)
	{
		return false;
	}
	
	
	while (!fFile.EndOfFile() && fFile.ReadLine(readbuffer, sizeof(readbuffer)))
	{
		// Is a comment or not valid
		if (IsCharSpace(readbuffer[0]) || readbuffer[0] == '/' || !IsCharAlpha(readbuffer[0]))
		{
			continue;
		}
		
		
		// Has not enough spaces, must have at least 1
		if (GetCharCountInStr(' ', readbuffer) < 1)
		{
			continue;
		}

		
		// Ignore cvars which aren't quoted
		if (GetCharCountInStr('"', readbuffer) != 2)
		{
			continue;
		}
		
		
		
		// Get the start of the value
		if ( (valuestart = StrContains(readbuffer, "\"")) == -1 )
		{
			continue;
		}
		
		
		// Get the end of the value
		if ( (valueend = StrContains(readbuffer[valuestart+1], "\"")) == -1 )
		{
			continue;
		}
		
		
		// Get the start of the cvar, 
		if ( (cvarend = StrContains(readbuffer, " ")) == -1 || cvarend >= valuestart)
		{
			continue;
		}
		
		
		// Skip if cvarendindex is before valuestartindex
		if (cvarend >= valuestart)
		{
			continue;
		}
		
		
		// Convar
		// Tempcopy for security
		strcopy(copybuffer, sizeof(copybuffer), readbuffer);
		copybuffer[cvarend] = '\0';
		
		strcopy(sConvar, sizeof(sConvar), copybuffer);
		

		// Value
		// Tempcopy for security
		strcopy(copybuffer, sizeof(copybuffer), readbuffer[valuestart+1]);
		copybuffer[valueend] = '\0';
		
		strcopy(sValue, sizeof(sValue), copybuffer);
		
		
		//PrintToServer("Cvar %s has a value of %s", sConvar, sValue);
		
		char sTrieValue[64];
		if (!g_hConvarTrie.GetString(sConvar, sTrieValue, sizeof(sTrieValue)))
		{
			//PrintToServer("Adding convar %s to trie", sConvar);
			g_hConvarTrie.SetString(sConvar, sValue);
		}					
	}
	
	fFile.Close();	
	
	g_bCacheEnabled = true;
	
	return true;
}
