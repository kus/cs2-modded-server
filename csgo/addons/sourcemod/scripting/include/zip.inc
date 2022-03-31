/*
 * Copyright (c) 2013 Peter Rowlands
 *
 * This file is a part of sm-zip.
 *
 * sm-zip is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sm-zip is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with sm-zip.  If not, see <http://www.gnu.org/licenses/>.
 *
 * vim: set ts=4 et ft=sourcepawn :
 */
/**
 * @file
 * @brief sm-zip sourcepawn includes
 *
 * @author Peter "astroman" Rowlands <peter@pmrowla.com>
 */

#if defined _zip_included
 #endinput
#endif
#define _zip_included

enum Zip_AppendStatus
{
    ZIP_APPEND_STATUS_CREATE = 0,
    ZIP_APPEND_STATUS_CREATEAFTER = 1,
    ZIP_APPEND_STATUS_ADDINZIP = 2,
}

/**
 * Open a zip archive for writing
 *
 * @param filename the file to open
 * @param append file append status
 *
 * @return the handle to the new zipfile
 */
native Handle Zip_Open(const char[] filename, Zip_AppendStatus append);

/**
* Add a file to the specified zip archive and compress it
*
* @param handle a zip archive handle that was previously created by Zip_Open()
* @param filename the file to add to the archive
*
* @return true on success or false on error
*/
native bool Zip_AddFile(Handle handle, const char[] filename);

/**
 * Do not edit below this line!
 */
public Extension __ext_zip = 
{
    name = "Zip",
    file = "smzip.ext",
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
