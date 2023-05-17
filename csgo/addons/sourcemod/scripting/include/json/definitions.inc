/**
 * vim: set ts=4 :
 * =============================================================================
 * sm-json
 * A pure SourcePawn JSON encoder/decoder.
 * https://github.com/clugg/sm-json
 *
 * sm-json (C)2020 James Dickens. (clug)
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */

#if defined _json_definitions_included
 #endinput
#endif
#define _json_definitions_included

#include <string>
#include <json/helpers/string>

/**
 * @section Settings
 */

#define JSON_NONE 0

/* json_encode settings */
#define JSON_ENCODE_PRETTY 1 << 0

/* json_decode settings */
// During decoding, should strings wrapped in single quotes be accepted?
#define JSON_DECODE_SINGLE_QUOTES 1 << 0

/* json_merge settings */
// During merge, should existing keys be replaced if they exist in both objects?
#define JSON_MERGE_REPLACE 1 << 0
/* During merge, should existing objects be cleaned up if they exist in
 * both objects? (only applies when JSON_MERGE_REPLACE is also set) */
#define JSON_MERGE_CLEANUP 1 << 1

/**
 * @section Pretty Print Constants
 *
 * Used to determine how pretty printed JSON should be formatted when encoded.
 * You can modify these if you prefer your JSON formatted differently.
 */

#define JSON_PP_AFTER_COLON " "
#define JSON_PP_INDENT "    "
#define JSON_PP_NEWLINE "\n"

/**
 * @section Buffer Size Constants
 */

// The longest representable integer ("-2147483648") + NULL terminator
#define JSON_INT_BUFFER_SIZE 12

// You may need to change this if you are working with large floats.
#define JSON_FLOAT_BUFFER_SIZE 32

// "true"|"false" + NULL terminator
#define JSON_BOOL_BUFFER_SIZE 6

// "null" + NULL terminator
#define JSON_NULL_BUFFER_SIZE 5

/**
 * @section Array Constants
 */

#define JSON_ARRAY_INDEX_KEY "__array_index"
#define JSON_ARRAY_TYPE_KEY "__array_type"

/**
 * Types of cells within a JSON object
 */
enum JSONCellType {
    JSON_Type_Invalid = -1,
    JSON_Type_String = 0,
    JSON_Type_Int,
    JSON_Type_Float,
    JSON_Type_Bool,
    JSON_Type_Object
};

/**
 * Types of metadata a JSON element can have
 */
enum JSONMetaInfo {
    JSON_Meta_Type = 0,
    JSON_Meta_Length,
    JSON_Meta_Hidden
}

/**
 * An array of all possible meta info values.
 */
JSONMetaInfo[] JSON_ALL_METADATA = {
    JSON_Meta_Type, JSON_Meta_Length, JSON_Meta_Hidden
};

/**
 * Calculates the length required to store a meta key
 * for a specified key/metainfo combination.
 *
 * @param   key
 * @returns The length required to store the meta key.
 */
stock int json_meta_key_length(const char[] key)
{
    // %s:%d
    return strlen(key) + 1 + JSON_INT_BUFFER_SIZE;
}

/**
 * Formats the key/metainfo combination into a buffer.
 *
 * @param output    String buffer to store output.
 * @param max_size  Maximum size of string buffer.
 * @param key       Key to generate metakey for.
 * @param meta      Meta information to generate metakey for.
 */
stock void json_format_meta_key(
    char[] output,
    int max_size,
    const char[] key,
    JSONMetaInfo meta
)
{
    FormatEx(output, max_size, "%s:%d", key, view_as<int>(meta));
}

/**
 * Checks whether the key provided is a metadata key.
 *
 * @param key   Key to check.
 * @returns     True when it is a meta-key, false otherwise.
 */
stock bool json_is_meta_key(const char[] key)
{
    if (
        StrEqual(key, JSON_ARRAY_INDEX_KEY)
        || StrEqual(key, JSON_ARRAY_TYPE_KEY)
    ) {
        return true;
    }

    int max_size = json_meta_key_length("");
    char[] meta_key = new char[max_size];
    for (int i = 0; i < sizeof(JSON_ALL_METADATA); i += 1) {
        json_format_meta_key(meta_key, max_size, "", JSON_ALL_METADATA[i]);

        if (json_string_endswith(key, meta_key)) {
            return true;
        }
    }

    return false;
}
