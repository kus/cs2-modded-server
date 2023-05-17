/**
 * -----------------------------------------------------
 * File        system2.inc
 * Authors     David Ordnung
 * License     GPLv3
 * Web         http://dordnung.de
 * -----------------------------------------------------
 * 
 * Copyright (C) 2013-2018 David Ordnung
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */

#if defined _system2_included
    #endinput
#endif

#define _system2_included

// Include request stuff
#include <system2/request>


/**
 * Max length of a command when using formatted natives.
 */
#define CMD_MAX_LENGTH 2048


/**
 * A list of possible compression levels for the System2_Compress native.
 */
enum CompressLevel
{
    LEVEL_1,            // Weekest
    LEVEL_3,
    LEVEL_5,
    LEVEL_7,
    LEVEL_9             // Strongest
}


/**
 * A list of possible archive formats for the System2_Compress native.
 */
enum CompressArchive
{
    ARCHIVE_ZIP,
    ARCHIVE_7Z,
    ARCHIVE_GZIP,
    ARCHIVE_BZIP2,
    ARCHIVE_TAR
}


/**
 * A list of possible operating systems for the System2_GetOS native.
 */
enum OS
{
    OS_UNKNOWN,         // OS couldn't be determined
    OS_WINDOWS,         // Windows
    OS_UNIX,            // Linux / Unix
    OS_MAC              // MAC
}



/**
 * Called when finished with the System2_CopyFile native.
 *
 * @param success       Whether copying was successful (will fail if couldn't open 'from' or 'to' file).
 * @param from          Path to file that was copied.
 * @param to            Path to the new copied file.
 * @param data          Data passed to the copy native.
 *
 * @noreturn
 */
typeset System2CopyCallback
{
    function void (bool success, const char[] from, const char[] to, any data);
    function void (bool success, const char[] from, const char[] to);
};


/**
 * Called when finished with System2_ExecuteThreaded or System2_ExecuteFormattedThreaded native.
 * The output will only be valid in the callback and will be destroyed afterwards.
 *
 * @param success       Whether the execution was successful or not.
 *                      This not means that the command itself was successful!
 *                      Check the ExitStatus of the output for this.
 * @param command       The executed command.
 * @param output        Output of the execution. Is null if success is false.
 *                      Can't be deleted, as it will be destroyed after the callback!
 * @param data          Data passed to the execution native.
 *
 * @noreturn
 */
typeset System2ExecuteCallback
{
    function void (bool success, const char[] command, System2ExecuteOutput output, any data);
    function void (bool success, const char[] command, System2ExecuteOutput output);
};



/**
 * Methodmap for the output of an execution.
 */
methodmap System2ExecuteOutput < Handle {
    /**
     * Retrieves the output of the command execution.
     *
     * @param output    Buffer to store the output in.
     * @param maxlength Maxlength of the output buffer.
     * @param start     Start byte to start reading from.
     *                  You can use this to retrieve the output step by step.
     * @param delimiter Delimiter until which the content should be retrieved.
     * @param include   Whether the delimiter should be included or not.
     * 
     * @return          Number of read bytes.
     * @error           Invalid Output.
     */
    public native int GetOutput(char[] output, int maxlength, int start = 0, const char[] delimiter = "", bool include = true);

    property int Length {
        /**
         * Returns the length of the complete output.
         *
         * @return      Length of the output.
         * @error       Invalid Output.
         */
        public native get();
    }

    property int ExitStatus {
        /**
         * Returns the exit status of the execution.
         *
         * @return      The exit status.
         * @error       Invalid Output.
         */
        public native get();
    }
}



/**
 * Copies a file to another location.
 *
 * @param callback      Callback function when finished with copying.
 * @param from          Path to the file to copy.
 * @param to            Path to the file to copy to (including filename). File will be replaced if it exists.
 * @param data          Additional data to pass to the callback.
 *
 * @noreturn
 */
native void System2_CopyFile(System2CopyCallback callback, const char[] from, const char[] to, any data = 0);


/**
 * Checks whether 7-ZIP was found and is executable.
 *
 * @param execPath     Buffer which will store the path to the 7-ZIP executable.
 *                     Can be used for example when showing an error message.
 * @param maxlength    Maxlength of the buffer.
 * @param force32Bit   Whether to force using the 32 bit version of 7-ZIP, otherwise the appropriate version will be used.
 *
 * @return             True if 7-ZIP executable could be found and is executable, otherwise false.
 */
native bool System2_Check7ZIP(char[] execPath, int maxlength, bool force32Bit = false);

/**
 * Compresses a file or folder to an archive.
 *
 * @param callback      Callback function when finished with compressing.
 * @param path          Path to the file / folder to compress.
 * @param archive       Path to the archive file to compress to (including filename).
 * @param archiveType   Archive type to use.
 * @param level         Compress level to use.
 * @param data          Additional data to pass to the callback.
 * @param force32Bit    Whether to force using the 32 bit version of 7-ZIP, otherwise the appropriate version will be used.
 *
 * @return              True if compress command could be fired, false when 7-ZIP executable couldn't be found or is not executable.
 */
native bool System2_Compress(System2ExecuteCallback callback, const char[] path, const char[] archive, CompressArchive archiveType = ARCHIVE_ZIP, CompressLevel level = LEVEL_9, any data = 0, bool force32Bit = false);

/**
 * Extracts a lot of archive types with 7zip.
 *
 * @param callback      Callback function when finished with extracting.
 * @param archive       Path to the archive file to extract.
 * @param extractDir    Path to the directory to extract to.
 * @param data          Additional data to pass to the callback.
 * @param force32Bit    Whether to force using the 32 bit version of 7-ZIP, otherwise the appropriate version will be used.
 *
 * @return              True if extract command could be fired, false when 7-ZIP executable couldn't be found or is not executable.
 */
native bool System2_Extract(System2ExecuteCallback callback, const char[] archive, const char[] extractDir, any data = 0, bool force32Bit = false);



/**
 * Executes a threaded system command.
 * Hint: Append 2>&1 to your command to retrieve also output to stderr.
 *
 * @param callback  Callback function when command was executed.
 * @param command   Command to execute.
 * @param data      Data to pass to the callback.
 *
 * @noreturn
 */
native void System2_ExecuteThreaded(System2ExecuteCallback callback, const char[] command, any data = 0);

/**
 * Executes a threaded system command with support for a formatted command.
 * Note that the maxlength of the command is CMD_MAX_LENGTH, use System2_ExecuteThreaded if you need more.
 * Hint: Append 2>&1 to your command to retrieve also output to stderr.
 *
 * @param callback  Callback function when command was executed.
 * @param data      Data to pass to the callback.
 * @param command   Command string format.
 * @param ...       Command string arguments.
 *
 * @noreturn
 */
native void System2_ExecuteFormattedThreaded(System2ExecuteCallback callback, any data, const char[] command, any ...);

/**
 * Executes a non threaded system command.
 * Hint: Append 2>&1 to your command to retrieve also output to stderr.
 *
 * @param output    Buffer to store the output in.
 * @param maxlength Maxlength of the output buffer.
 * @param command   Command to execute.
 *
 * @return          True on success, otherwise false.
 */
native bool System2_Execute(char[] output, int maxlength, const char[] command);

/**
 * Executes a non threaded system command with support for a formatted command.
 * Note that the maxlength of the command is CMD_MAX_LENGTH, use System2_Execute if you need more.
 * Hint: Append 2>&1 to your command to retrieve also output to stderr.
 *
 * @param output    Buffer to store the output in.
 * @param maxlength Maxlength of the output buffer.
 * @param command   Command string format.
 * @param ...       Command string arguments.
 *
 * @return          True on success, otherwise false.
 */
native bool System2_ExecuteFormatted(char[] output, int maxlength, const char[] command, any ...);



/**
 * Retrieves the absolute path to the gamedir of the current running game (e.g. /home/.../.../cstrike).
 * You may need this when executing system commands.
 *
 * @param gamedir       Buffer to store gamedir in.
 * @param maxlength     Maxlength of the buffer.
 *
 * @noreturn
 */
native void System2_GetGameDir(char[] gamedir, int maxlength);

/**
 * Returns the server's operating system.
 *
 * @return              OS_UNKNOWN, OS_WINDOWS, OS_UNIX, OS_MAC.
 */
native OS System2_GetOS();



/**
 * Retrieves the MD5 hex hash of a string.
 *
 * @param string        String to retrieve the MD5 hash of.
 * @param buffer        Buffer to store MD5 hash in.
 * @param maxlength     Maxlength of the buffer. Should be greater or equal to 33 (32 MD5 + 1 terminator).
 *
 * @noreturn
 */
native void System2_GetStringMD5(const char[] str, char[] buffer, int maxlength);

/**
 * Retrieves the MD5 hex hash of a files content.
 *
 * @param file          The path to the file.
 * @param buffer        Buffer to store MD5 hash in.
 * @param maxlength     Maxlength of the buffer. Should be greater or equal to 33 (32 MD5 + 1 terminator).
 *
 * @return              True on success, false when file couldn't be opened.
 */
native bool System2_GetFileMD5(const char[] file, char[] buffer, int maxlength);

/**
 * Retrieves the CRC32 hex hash of a string.
 *
 * @param string        The string to retrieve the CRC32 hash of.
 * @param buffer        Buffer to store CRC32 hash in.
 * @param maxlength     Maxlength of the buffer. Should be greater or equal to 9 (8 CRC32 + 1 terminator).
 *
 * @noreturn
 */
native void System2_GetStringCRC32(const char[] str, char[] buffer, int maxlength);

/**
 * Retrieves the CRC32 hex hash of a files content.
 *
 * @param file          The path to the file.
 * @param buffer        Buffer to store CRC32 hash in.
 * @param maxlength     Maxlength of the buffer. Should be greater or equal to 9 (8 CRC32 + 1 terminator).
 *
 * @return              True on success, false when file couldn't be opened.
 */
native bool System2_GetFileCRC32(const char[] file, char[] buffer, int maxlength);


// Include legacy stuff
#include <system2/legacy>


public Extension __ext_system2 =
{
    name = "System2",
    file = "system2.ext",

    #if defined AUTOLOAD_EXTENSIONS
        autoload = 1,
    #else
        autoload = 0,
    #endif

    #if defined REQUIRE_EXTENSIONS
        required = 1,
    #else
        required = 0,
    #endif
};


#if !defined REQUIRE_EXTENSIONS
    public void __ext_system2_SetNTVOptional()
    {
        MarkNativeAsOptional("System2Request.SetURL");
        MarkNativeAsOptional("System2Request.GetURL");
        MarkNativeAsOptional("System2Request.SetPort");
        MarkNativeAsOptional("System2Request.GetPort");
        MarkNativeAsOptional("System2Request.SetOutputFile");
        MarkNativeAsOptional("System2Request.GetOutputFile");
        MarkNativeAsOptional("System2Request.SetVerifySSL");
        MarkNativeAsOptional("System2Request.GetVerifySSL");
        MarkNativeAsOptional("System2Request.SetProxy");
        MarkNativeAsOptional("System2Request.SetProxyAuthentication");
        MarkNativeAsOptional("System2Request.Timeout.get");
        MarkNativeAsOptional("System2Request.Timeout.set");
        MarkNativeAsOptional("System2Request.Any.get");
        MarkNativeAsOptional("System2Request.Any.set");
        
        MarkNativeAsOptional("System2HTTPRequest.System2HTTPRequest");
        MarkNativeAsOptional("System2HTTPRequest.SetProgressCallback");
        MarkNativeAsOptional("System2HTTPRequest.SetData");
        MarkNativeAsOptional("System2HTTPRequest.GetData");
        MarkNativeAsOptional("System2HTTPRequest.SetHeader");
        MarkNativeAsOptional("System2HTTPRequest.GetHeader");
        MarkNativeAsOptional("System2HTTPRequest.GetHeaderName");
        MarkNativeAsOptional("System2HTTPRequest.SetUserAgent");
        MarkNativeAsOptional("System2HTTPRequest.SetBasicAuthentication");
        MarkNativeAsOptional("System2HTTPRequest.GET");
        MarkNativeAsOptional("System2HTTPRequest.POST");
        MarkNativeAsOptional("System2HTTPRequest.PUT");
        MarkNativeAsOptional("System2HTTPRequest.PATCH");
        MarkNativeAsOptional("System2HTTPRequest.DELETE");
        MarkNativeAsOptional("System2HTTPRequest.HEAD");
        MarkNativeAsOptional("System2HTTPRequest.FollowRedirects.get");
        MarkNativeAsOptional("System2HTTPRequest.FollowRedirects.set");
        MarkNativeAsOptional("System2HTTPRequest.Headers.get");
        
        MarkNativeAsOptional("System2FTPRequest.System2FTPRequest");
        MarkNativeAsOptional("System2FTPRequest.SetProgressCallback");
        MarkNativeAsOptional("System2FTPRequest.SetAuthentication");
        MarkNativeAsOptional("System2FTPRequest.SetInputFile");
        MarkNativeAsOptional("System2FTPRequest.GetInputFile");
        MarkNativeAsOptional("System2FTPRequest.StartRequest");
        MarkNativeAsOptional("System2FTPRequest.AppendToFile.get");
        MarkNativeAsOptional("System2FTPRequest.AppendToFile.set");
        MarkNativeAsOptional("System2FTPRequest.CreateMissingDirs.get");
        MarkNativeAsOptional("System2FTPRequest.CreateMissingDirs.set");
        MarkNativeAsOptional("System2FTPRequest.ListFilenamesOnly.get");
        MarkNativeAsOptional("System2FTPRequest.ListFilenamesOnly.set");
        
        MarkNativeAsOptional("System2Response.GetLastURL");
        MarkNativeAsOptional("System2Response.GetContent");
        MarkNativeAsOptional("System2Response.ContentLength.get");
        MarkNativeAsOptional("System2Response.StatusCode.get");
        MarkNativeAsOptional("System2Response.TotalTime.get");
        MarkNativeAsOptional("System2Response.DownloadSize.get");
        MarkNativeAsOptional("System2Response.UploadSize.get");
        MarkNativeAsOptional("System2Response.DownloadSpeed.get");
        MarkNativeAsOptional("System2Response.UploadSpeed.get");
        
        MarkNativeAsOptional("System2HTTPResponse.GetContentType");
        MarkNativeAsOptional("System2HTTPResponse.GetHeader");
        MarkNativeAsOptional("System2HTTPResponse.GetHeaderName");
        MarkNativeAsOptional("System2HTTPResponse.GetHeadersCount");
        MarkNativeAsOptional("System2HTTPResponse.HTTPVersion.get");
        MarkNativeAsOptional("System2HTTPResponse.Headers.get");

        MarkNativeAsOptional("System2_URLEncode");
        MarkNativeAsOptional("System2_URLDecode");

        MarkNativeAsOptional("System2_CopyFile");

        MarkNativeAsOptional("System2_Check7ZIP");
        MarkNativeAsOptional("System2_Compress");
        MarkNativeAsOptional("System2_Extract");

        MarkNativeAsOptional("System2_ExecuteThreaded");
        MarkNativeAsOptional("System2_ExecuteFormattedThreaded");
        MarkNativeAsOptional("System2ExecuteOutput.GetOutput");
        MarkNativeAsOptional("System2ExecuteOutput.Length.get");
        MarkNativeAsOptional("System2ExecuteOutput.ExitStatus.get");

        MarkNativeAsOptional("System2_Execute");
        MarkNativeAsOptional("System2_ExecuteFormatted");

        MarkNativeAsOptional("System2_GetGameDir");
        MarkNativeAsOptional("System2_GetOS");

        MarkNativeAsOptional("System2_GetStringMD5");
        MarkNativeAsOptional("System2_GetFileMD5");
        MarkNativeAsOptional("System2_GetStringCRC32");
        MarkNativeAsOptional("System2_GetFileCRC32");

        // Deprecated v2 stuff
        MarkNativeAsOptional("System2_GetPage");
        MarkNativeAsOptional("System2_DownloadFile");
        MarkNativeAsOptional("System2_DownloadFTPFile");
        MarkNativeAsOptional("System2_UploadFTPFile");
        MarkNativeAsOptional("System2_CompressFile");
        MarkNativeAsOptional("System2_ExtractArchive");
        MarkNativeAsOptional("System2_RunThreadCommand");
        MarkNativeAsOptional("System2_RunThreadCommandWithData");
        MarkNativeAsOptional("System2_RunCommand");
    }
#endif