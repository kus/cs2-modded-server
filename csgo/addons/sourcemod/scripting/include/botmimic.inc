#if defined _botmimic_included
  #endinput
#endif
#define _botmimic_included

#define MAX_RECORD_NAME_LENGTH 64
#define MAX_BOOKMARK_NAME_LENGTH 64
#define DEFAULT_CATEGORY "default"

enum BMError {
	BM_NoError = 0,
	BM_BadClient, // Provided client index is invalid
	BM_FileNotFound, // The file does not exists or can't be opened
	BM_BadFile, // Not a Bot Mimic record.
	BM_NewerBinaryVersion // The record was recorded with a newer version of Bot Mimic and can't be played.
};

enum BMFileHeader {
	BMFH_binaryFormatVersion = 0,
	BMFH_recordEndTime,
	String:BMFH_recordName[MAX_RECORD_NAME_LENGTH],
	BMFH_tickCount,
	Float:BMFH_initialPosition[3],
	Float:BMFH_initialAngles[3],
	BMFH_bookmarkCount
};

/**
 * Start to record the movements of a player.
 * It's stored in memory until told to write to disk.
 * 
 * Make sure the player isn't recording already.
 * 
 * @param client	The client to record
 * @param name		The name of the record (anything, not the filename)
 * @param category	The category to put this record in. This is used as a directory filename inside /data/botmimic/%CATEGORY%/%MAP_NAME%/stuff.rec
 * @param subdir	The subdirectory to organize records physically. This isn't used or retrieved back anywhere, just to better manage files by hand. /data/botmimic/%CATEGORY%/%MAP_NAME%/%SUBDIR%/stuff.rec
 */
native void BotMimic_StartRecording(int client, const char[] name, const char[] category = "", const char[] subdir = "");

/**
 * Pause recording the current record.
 * 
 * @param client	The recording client, which should pause recording.
 * @error			Invalid client index, client not recording or recording already paused.
 */
native void BotMimic_PauseRecording(int client);

/**
 * Resume recording the current record.
 * 
 * @param client		The recording client, which should resume recording.
 * @error				Invalid client index, client not recording or record not paused.
 */
native void BotMimic_ResumeRecording(int client);

/**
 * Check whether a client is currently paused recording a record.
 *
 * @param client	The client index of the player you want to know if he's paused.
 * @return			True if recording is paused, false otherwise.
 * @error			Invalid client index or client not recording.
 */
native bool BotMimic_IsRecordingPaused(int client);

/**
 * Stop recording and save or discard the record
 * 
 * @param client	The client which was recording
 * @param save		Save the record (true) or discard (false)
 */
native void BotMimic_StopRecording(int client, bool save = true);

/**
 * Save the current frame with the given name as bookmark.
 * You can skip to this point when playing back the record using BotMimic_GoToBookmark.
 *
 * @param client	The client which is recording
 * @param name		The name of this bookmark
 * @noreturn
 * @error	Client not recording
 */
native void BotMimic_SaveBookmark(int client, const char[] name);

/**
 * Deletes a record and does some checks, that the file is really a record.
 * 
 * @param path		The Path to the .rec recording file to delete.
 * @return			Number of bots, which were mimicing this record or -1 on error (file not found/invalid)
 */
native int BotMimic_DeleteRecord(const char[] path);

/**
 * Is the player currently recording something?
 * 
 * @param client	The client to check
 * @return			true, if player is recording, false otherwise
 */
native bool BotMimic_IsPlayerRecording(int client);

/**
 * Is the player currently mimicing something?
 * 
 * @param client	The client to check
 * @return			true, if the player is mimicing, false otherwise
 */
native bool BotMimic_IsPlayerMimicing(int client);

/**
 * Get the path to the record file this player is currently mimicing.
 *
 * @param client	The mimicing client
 * @param path		A String where to store the path
 * @param maxlen	The maximal length of the path
 */
native void BotMimic_GetRecordPlayerMimics(int client, char[] path, int maxlen);

/**
 * Let a client start to mimic a record from a file.
 *
 * @param client	The client, which should start mimicing
 * @param path		The path to a .rec recording file
 * @return			BM_NoError if all went smooth, see BMError definition.
 */
native BMError BotMimic_PlayRecordFromFile(int client, const char[] path);

/**
 * Let a client start to mimic a record by providing the record name.
 * Since record names don't have to be unique, this native picks the most recent one.
 *
 * @param client	The client, which should start mimicing.
 * @param name		The name of the record to play.
 * @return			BM_NoError if all went smooth, see BMError definition.
 */
native BMError BotMimic_PlayRecordByName(int client, const char[] name);

/**
 * Have a bot restart the record he's currently playing from the beginning.
 *
 * @param client   The client, who should start over with the record he's currently mimicing.
 */
native void BotMimic_ResetPlayback(int client);

/**
 * Jump the the frame where this bookmark was set in the record.
 * @see BotMimic_SaveBookmark
 *
 * @param client	The client, which is mimicing some record
 * @param name		The name of the bookmark saved during recording using BotMimic_SaveBookmark
 */
native void BotMimic_GoToBookmark(int client, const char[] name);

/**
 * Stops a player from mimicing a record.
 *
 * @param client	The client who should stop mimicing
 */
native void BotMimic_StopPlayerMimic(int client);

/**
 * Get the Handle to a sorted adt_array, containing a list of paths to all loaded record files.
 * DON'T CLOSE THIS HANDLE!
 * Just use GetArrayString to read the path.
 *
 * @return Handle to sorted adt_array containing all paths to records
 */
native ArrayList BotMimic_GetLoadedRecordList();

/**
 * Get the Handle to a sorted adt_array, containing a list of categorys.
 * DON'T CLOSE THIS HANDLE!
 * Just use GetArrayString to read the category.
 *
 * @return Handle to sorted adt_array containing all categories.
 */
native ArrayList BotMimic_GetLoadedRecordCategoryList();

/**
 * Get the header information of a record. This includes the record name.
 *
 * @param path	The path to the .rec record file
 * @param iFileHeader	An array to store the file header in.
 * @return			BM_NoError if all went smooth, see BMError definition.
 */
native BMError BotMimic_GetFileHeaders(const char[] path, int iFileHeader[BMFileHeader], int size = view_as<int>(BMFileHeader));

/**
 * Get the category of a record.
 *
 * @param path			The path to the .rec record file.
 * @param category	The String where to store the category in.
 * @param maxlen		The maximal length of the category buffer.
 * @return				true if category of file found, false otherwise
 */
native bool BotMimic_GetFileCategory(const char[] path, char[] category, int maxlen);

/**
 * Change the name of a record. This doesn't change the filename, but the stored record name inside the file. (BMTP_recordName)
 *
 * @param path	The path to the .rec record file which name to change.
 * @param name	The new name of the record
 * @return			BM_NoError if all went smooth, see BMError definition.
 */
native BMError BotMimic_ChangeRecordName(const char[] path, char[] name);

/**
 * Get a list of all bookmarks stored in this record as an adt_array.
 * You have to close the returned Handle using CloseHandle.
 *
 * @param path		The path to the .rec record file.
 * @param bookmarks	The handle where the bookmark array will be stored in.
 * @return			BM_NoError if all went smooth, see BMError definition.
 */
native BMError BotMimic_GetRecordBookmarks(const char[] path, ArrayList &bookmarks);

/**
 * Called when a player starts recording.
 * path is NOT the path to the .rec file, but just the path to the category folder (by default: Path_SM/data/botmimic/%CATEGORY%)
 *
 * @param client	The client index, who's being recorded
 * @param name		The name of the recording (stored in file header)
 * @param category	The category name
 * @param subdir	The subdir used to organize the record files (no further sense..)
 * @param path		The path to the category folder
 * @return			>= Plugin_Handled to abort recording or Plugin_Continue to let it pass and start recording.
 */
forward Action BotMimic_OnStartRecording(int client, char[] name, char[] category, char[] subdir, char[] path);

/**
 * Called when recording a record is paused or resumed.
 *
 * @param client	The client which recording pause state changed
 * @param paused	True when the recording was paused, false when it was unpaused
 */
forward void BotMimic_OnRecordingPauseStateChanged(int client, bool paused);

/**
 * Called when a bookmark is saved while the client is recording.
 *
 * @param client	The client which is recording.
 * @param bookmark	The name of the saved bookmark.
 * @noreturn
 */
forward void BotMimic_OnRecordingBookmarkSaved(int client, const char[] bookmark);

/**
 * Called when a player stops recording.
 * Change the save param if you want to prevent it from being discarded/written.
 *
 * @param client		The client who was recording.
 * @param name			The name of the record (stored in file header)
 * @param category	The category name.
 * @param subdir		The subdir used to organize the record files (no further sense..)
 * @param path			The path to the category folder
 * @param save			Set to true, if the record should be stored to disk, or false to discard.
 * @return				>= Plugin_Handled to continue recording, Plugin_Continue to let it stop.
 */
forward Action BotMimic_OnStopRecording(int client, char[] name, char[] category, char[] subdir, char[] path, bool &save);

/**
 * Called when a record was saved to file.
 *
 * @param client		The client who was recording.
 * @param name			The name of the record (stored in file header)
 * @param category	The category name.
 * @param subdir		The subdir used to organize the record files (no further sense..)
 * @param file			The actual path to the saved .rec file.
 */
forward void BotMimic_OnRecordSaved(int client, char[] name, char[] category, char[] subdir, char[] file);

/**
 * Called when a record was deleted.
 * 
 * @param name		The name of the record (stored in file header)
 * @param category	The category of the file. (If it wasn't loaded before it defaults to "default".)
 * @param path		The path to the deleted file.
 */
forward void BotMimic_OnRecordDeleted(char[] name, char[] category, char[] path);

/**
 * Called when a player starts to mimic a record
 *
 * @param client		The client which starts mimicing.
 * @param name			The name of the record (stored in file header)
 * @param category	The category of the file.
 * @param path			The path to the record file.
 * @return 					>= Plugin_Handled to stop the player from mimicing, Plugin_Continue to allow
 */
forward Action BotMimic_OnPlayerStartsMimicing(int client, char[] name, char[] category, char[] path);

/**
 * Called when a player stops mimicing a record.
 *
 * @param client		The client who was mimicing
 * @param name			The name of the record (stored in file header)
 * @param category	The category of the file.
 * @param path			The path to the record file.
 */
forward void BotMimic_OnPlayerStopsMimicing(int client, char[] name, char[] category, char[] path);

/**
 * Called everytime a mimicing player starts to mimic the record again from the beginning,
 * when he was teleported back to the start.
 *
 * @param client		The mimicing client
 */
forward void BotMimic_OnPlayerMimicLoops(int client);

/**
 * Called when a bookmark is reached during playback of a record.
 *
 * @param client	The client which is mimicing.
 * @param bookmark	The name of the bookmark.
 */
forward void BotMimic_OnPlayerMimicBookmark(int client, const char[] bookmark);

/**
 * Translate an error id to a human readable string
 * 
 * @param error		The error id
 * @param str		The string to store the error message in
 * @param maxlen	The maximal length of the error message string
 */
stock void BotMimic_GetErrorString(BMError error, char[] str, int maxlen)
{
	switch(error)
	{
		case BM_BadClient:
		{
			strcopy(str, maxlen, "Invalid client index.");
		}
		case BM_FileNotFound:
		{
			strcopy(str, maxlen, "File not found.");
		}
		case BM_NewerBinaryVersion:
		{
			strcopy(str, maxlen, "The file was recorded with a newer version of Bot Mimic and can't be played.");
		}
		case BM_BadFile:
		{
			strcopy(str, maxlen, "The file is not a record. Bad format.");
		}
		case BM_NoError:
		{
			strcopy(str, maxlen, "");
		}
	}
}

public SharedPlugin __pl_botmimic = 
{
	name = "botmimic",
	file = "botmimic.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_botmimic_SetNTVOptional()
{
	MarkNativeAsOptional("BotMimic_StartRecording");
	MarkNativeAsOptional("BotMimic_PauseRecording");
	MarkNativeAsOptional("BotMimic_ResumeRecording");
	MarkNativeAsOptional("BotMimic_IsRecordingPaused");
	MarkNativeAsOptional("BotMimic_StopRecording");
	MarkNativeAsOptional("BotMimic_SaveBookmark");
	MarkNativeAsOptional("BotMimic_GoToBookmark");
	MarkNativeAsOptional("BotMimic_DeleteRecord");
	MarkNativeAsOptional("BotMimic_IsPlayerRecording");
	MarkNativeAsOptional("BotMimic_IsPlayerMimicing");
	MarkNativeAsOptional("BotMimic_GetRecordPlayerMimics");
	MarkNativeAsOptional("BotMimic_PlayRecordFromFile");
	MarkNativeAsOptional("BotMimic_ResetPlayback");
	MarkNativeAsOptional("BotMimic_PlayRecordByName");
	MarkNativeAsOptional("BotMimic_StopPlayerMimic");
	MarkNativeAsOptional("BotMimic_GetLoadedRecordCategoryList");
	MarkNativeAsOptional("BotMimic_GetLoadedRecordList");
	MarkNativeAsOptional("BotMimic_GetFileHeaders");
	MarkNativeAsOptional("BotMimic_GetFileCategory");
	MarkNativeAsOptional("BotMimic_ChangeRecordName");
	MarkNativeAsOptional("BotMimic_GetRecordBookmarks");
}
#endif
