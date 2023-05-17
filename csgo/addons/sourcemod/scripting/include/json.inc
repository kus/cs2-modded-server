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

#if defined _json_included
 #endinput
#endif
#define _json_included

#include <string>
#include <json/definitions>
#include <json/helpers/decode>
#include <json/helpers/string>
#include <json/object>
#include <json/array>

/**
 * Encodes a JSON instance into its string representation.
 *
 * @param obj       Object to encode.
 * @param output    String buffer to store output.
 * @param max_size  Maximum size of string buffer.
 * @param options   Bitwise combination of JSON_ENCODE_* options.
 *                  [default: JSON_NONE]
 * @param depth     The current depth of the encoder. [default: 0]
 */
stock void json_encode(
    JSON_Object obj,
    char[] output,
    int max_size,
    int options = JSON_NONE,
    int depth = 0
)
{
    bool pretty_print = (options & JSON_ENCODE_PRETTY) != 0;

    bool is_array = obj.IsArray;
    JSON_Array arr = null;
    if (is_array) {
        arr = view_as<JSON_Array>(obj);
    }

    StringMapSnapshot snap = null;
    int json_size = 0;
    if (is_array) {
        json_size = arr.Length;

        strcopy(output, max_size, "[");
    } else {
        snap = obj.Snapshot();
        json_size = snap.Length;

        strcopy(output, max_size, "{");
    }

    // used in key iterator
    int builder_size = 0;
    int str_length = 1;
    JSON_Object child = null;
    int cell_length = 0;
    bool is_empty = true;

    int key_length = 0;
    for (int i = 0; i < json_size; i += 1) {
        key_length = is_array ? JSON_INT_BUFFER_SIZE : snap.KeyBufferSize(i);
        char[] key = new char[key_length];

        if (is_array) {
            IntToString(i, key, key_length);
        } else {
            snap.GetKey(i, key, key_length);

            // skip meta-keys
            if (json_is_meta_key(key)) {
                continue;
            }
        }

        // skip keys that are marked as hidden
        if (obj.GetKeyHidden(key)) {
            continue;
        }

        JSONCellType type = obj.GetKeyType(key);
        // skip keys of unknown type
        if (type == JSON_Type_Invalid) {
            continue;
        }

        // determine the length of the char[] needed to represent our cell data
        cell_length = 0;
        switch (type) {
            case JSON_Type_String: {
                str_length = obj.GetKeyLength(key);
                cell_length = json_cell_string_size(str_length);
            }
            case JSON_Type_Int: {
                cell_length = JSON_INT_BUFFER_SIZE;
            }
            case JSON_Type_Float: {
                cell_length = JSON_FLOAT_BUFFER_SIZE;
            }
            case JSON_Type_Bool: {
                cell_length = JSON_BOOL_BUFFER_SIZE;
            }
            case JSON_Type_Object: {
                child = obj.GetObject(key);
                cell_length = child != null ? max_size : JSON_NULL_BUFFER_SIZE;
            }
        }

        // fit the contents into the cell
        char[] cell = new char[cell_length];
        switch (type) {
            case JSON_Type_String: {
                char[] value = new char[str_length + 1];
                obj.GetString(key, value, str_length + 1);
                json_cell_string(value, cell, cell_length);
            }
            case JSON_Type_Int: {
                int value = obj.GetInt(key);
                IntToString(value, cell, cell_length);
            }
            case JSON_Type_Float: {
                float value = obj.GetFloat(key);
                FloatToString(value, cell, cell_length);

                // trim trailing 0s from float output up until decimal point
                int last_char = strlen(cell) - 1;
                while (cell[last_char] == '0' && cell[last_char - 1] != '.') {
                    cell[last_char--] = '\0';
                }
            }
            case JSON_Type_Bool: {
                bool value = obj.GetBool(key);
                strcopy(cell, cell_length, value ? "true" : "false");
            }
            case JSON_Type_Object: {
                if (child != null) {
                    json_encode(child, cell, cell_length, options, depth + 1);
                } else {
                    strcopy(cell, cell_length, "null");
                }
            }
        }

        // make the builder fit our key:value
        // use previously determined cell length and + 1 for ,
        builder_size = cell_length + 1;
        if (! is_array) {
            // get the length of the key and + 1 for :
            builder_size += json_cell_string_size(strlen(key)) + 1;

            if (pretty_print) {
                builder_size += strlen(JSON_PP_AFTER_COLON);
            }
        }

        char[] builder = new char[builder_size];
        strcopy(builder, builder_size, "");

        // add the key if we're working with an object
        if (! is_array) {
            json_cell_string(key, builder, builder_size);
            StrCat(builder, builder_size, ":");

            if (pretty_print) {
                StrCat(builder, builder_size, JSON_PP_AFTER_COLON);
            }
        }

        // add the value and a trailing comma
        StrCat(builder, builder_size, cell);
        StrCat(builder, builder_size, ",");

        // prepare pretty printing then send builder to output afterwards
        if (pretty_print) {
            StrCat(output, max_size, JSON_PP_NEWLINE);

            for (int j = 0; j < depth + 1; j += 1) {
                StrCat(output, max_size, JSON_PP_INDENT);
            }
        }

        StrCat(output, max_size, builder);

        is_empty = false;
    }

    if (snap != null) {
        delete snap;
    }

    if (! is_empty) {
        // remove the final comma
        output[strlen(output) - 1] = '\0';

        if (pretty_print) {
            StrCat(output, max_size, JSON_PP_NEWLINE);

            for (int j = 0; j < depth; j += 1) {
                StrCat(output, max_size, JSON_PP_INDENT);
            }
        }
    }

    // append closing bracket
    StrCat(output, max_size, is_array ? "]" : "}");
}

/**
 * Decodes a JSON string into a JSON instance.
 *
 * @param buffer    Buffer to decode.
 * @param options   Bitwise combination of JSON_DECODE_* options.
 *                  [default: JSON_NONE]
 * @param pos       Current position of the decoder as bytes
 *                  offset into the buffer.
 * @param depth     Current nested depth of the decoder.
 * @returns         JSON instance or null if decoding failed becase
 *                  the buffer didn't contain valid JSON.
 * @error           If the buffer does not contain valid JSON,
 *                  an error will be thrown.
 */
stock JSON_Object json_decode(
    const char[] buffer,
    int options = JSON_NONE,
    int &pos = 0,
    int depth = 0
)
{
    int length = strlen(buffer);
    // skip preceding whitespace
    if (! json_skip_whitespace(buffer, length, pos)) {
        LogError("json_decode: buffer ended early at position %d", pos);

        return null;
    }

    bool is_array = false;
    JSON_Array arr = null;
    JSON_Object obj = null;
    if (buffer[pos] == '{') {
        is_array = false;
        obj = new JSON_Object();
    } else if (buffer[pos] == '[') {
        is_array = true;
        arr = new JSON_Array();
    } else {
        LogError(
            "json_decode: no object or array found at position %d",
            pos
        );

        return null;
    }

    bool allow_single_quotes = (options & JSON_DECODE_SINGLE_QUOTES) > 0;

    bool empty_checked = false;

    // while we haven't reached the end of our structure
    while (
        (! is_array && buffer[pos] != '}')
        || (is_array && buffer[pos] != ']')
    ) {
        // pos is either an opening structure or comma, so increment past it
        pos += 1;

        // skip any whitespace preceding the element
        if (! json_skip_whitespace(buffer, length, pos)) {
            LogError("json_decode: buffer ended early at position %d", pos);
            json_cleanup_and_delete(obj);
            json_cleanup_and_delete(arr);

            return null;
        }

        // if we haven't checked for empty yet and we are at the end
        // of an object or array, we can stop here (empty structure)
        if (! empty_checked) {
            if (
                (! is_array && buffer[pos] == '}')
                || (is_array && buffer[pos] == ']')
            ) {
                break;
            }

            empty_checked = true;
        }

        int key_length = 1;
        if (! is_array) {
            // if dealing with an object, look for the key and determine length
            if (! json_is_string(buffer[pos], allow_single_quotes)) {
                LogError(
                    "json_decode: expected key string at position %d",
                    pos
                );
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }

            key_length = json_extract_string_size(
                buffer,
                length,
                pos,
                is_array
            );
        }

        char[] key = new char[key_length];

        if (! is_array) {
            // extract the key from the buffer
            json_extract_string(buffer, length, pos, key, key_length, is_array);

            // skip any whitespace following the key
            if (! json_skip_whitespace(buffer, length, pos)) {
                LogError("json_decode: buffer ended early at position %d", pos);
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }

            // ensure that we find a colon
            if (buffer[pos++] != ':') {
                LogError(
                    "json_decode: expected colon after key at position %d",
                    pos
                );
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }

            // skip any whitespace following the colon
            if (! json_skip_whitespace(buffer, length, pos)) {
                LogError("json_decode: buffer ended early at position %d", pos);
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }
        }

        int cell_length = 1;
        JSONCellType cell_type = JSON_Type_Invalid;
        if (buffer[pos] == '{' || buffer[pos] == '[') {
            cell_type = JSON_Type_Object;
        } else if (json_is_string(buffer[pos], allow_single_quotes)) {
            cell_type = JSON_Type_String;
            cell_length = json_extract_string_size(
                buffer,
                length,
                pos,
                is_array
            );
        } else {
            // in this particular instance, we use JSON_Type_Invalid to
            // represent any type that isn't an object or string
            cell_length = json_extract_until_end_size(
                buffer,
                length,
                pos,
                is_array
            );
        }

        char[] cell = new char[cell_length];
        switch (cell_type) {
            case JSON_Type_Object: {
                // if we are dealing with an object or array, decode recursively
                JSON_Object value = json_decode(
                    buffer,
                    options,
                    pos,
                    depth + 1
                );

                // decoding failed, error will be logged in json_decode
                if (value == null) {
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (is_array) {
                    arr.PushObject(value);
                } else {
                    obj.SetObject(key, value);
                }
            }
            case JSON_Type_String: {
                // if we are dealing with a string, attempt to extract it
                if (! json_extract_string(
                    buffer,
                    length,
                    pos,
                    cell,
                    cell_length,
                    is_array
                )) {
                    LogError(
                        "json_decode: couldn't extract string at position %d",
                        pos
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (is_array) {
                    arr.PushString(cell);
                } else {
                    obj.SetString(key, cell);
                }
            }
            case JSON_Type_Invalid: {
                if (! json_extract_until_end(
                    buffer,
                    length,
                    pos,
                    cell,
                    cell_length,
                    is_array
                )) {
                    LogError(
                        "json_decode: couldn't extract until end at position %d",
                        pos
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (strlen(cell) == 0) {
                    LogError(
                        "json_decode: empty cell encountered at position %d",
                        pos
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (json_is_int(cell)) {
                    int value = StringToInt(cell);
                    if (is_array) {
                        arr.PushInt(value);
                    } else {
                        obj.SetInt(key, value);
                    }
                } else if (json_is_float(cell)) {
                    float value = StringToFloat(cell);
                    if (is_array) {
                        arr.PushFloat(value);
                    } else {
                        obj.SetFloat(key, value);
                    }
                } else if (StrEqual(cell, "true") || StrEqual(cell, "false")) {
                    bool value = StrEqual(cell, "true");
                    if (is_array) {
                        arr.PushBool(value);
                    } else {
                        obj.SetBool(key, value);
                    }
                } else if (StrEqual(cell, "null")) {
                    if (is_array) {
                        arr.PushObject(null);
                    } else {
                        obj.SetObject(key, null);
                    }
                } else {
                    LogError(
                        "json_decode: unknown type encountered at position %d: %s",
                        pos,
                        cell
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }
            }
        }

        if (! json_skip_whitespace(buffer, length, pos)) {
            LogError("json_decode: buffer ended early at position %d", pos);
            json_cleanup_and_delete(obj);
            json_cleanup_and_delete(arr);

            return null;
        }
    }

    // skip remaining whitespace and ensure we're at the end of the buffer
    pos += 1;
    if (json_skip_whitespace(buffer, length, pos) && depth == 0) {
        LogError(
            "json_decode: unexpected data after structure end at position %d",
            pos
        );
        json_cleanup_and_delete(obj);
        json_cleanup_and_delete(arr);

        return null;
    }

    JSON_Object result;
    result = is_array ? view_as<JSON_Object>(arr) : view_as<JSON_Object>(obj);

    return result;
}

/**
 * Merges the entries from the second object to the first,
 * optionally replacing existing entries with the same key.
 *
 * @param to        Object to merge on to.
 * @param from      Object to merge entries from.
 * @param options   Bitwise combination of JSON_MERGE_* options.
 *                  [default: JSON_MERGE_REPLACE]
 * @returns         True on success, false otherwise.
 * @error           If the objects are not the same structure type
 *                  as one another, an error will be thrown.
 *                  For example, an object cannot be reliably merged over an
 *                  array and vice versa. Only array over array and
 *                  object over object merging is supported.
 */
stock bool json_merge(
    JSON_Object to,
    JSON_Object from,
    int options = JSON_MERGE_REPLACE
)
{
    if (to.IsArray && ! from.IsArray) {
        LogError("json_merge: attempting to merge an object onto an array");

        return false;
    } else if (! to.IsArray && from.IsArray) {
        LogError("json_merge: attempting to merge an array onto an object");

        return false;
    }

    bool replace = (options & JSON_MERGE_REPLACE) > 0;
    bool autocleanup = (options & JSON_MERGE_CLEANUP) > 0;

    bool is_array = to.IsArray;
    JSON_Array to_arr = null;
    if (is_array) {
        to_arr = view_as<JSON_Array>(to);
    }

    StringMapSnapshot snap = null;
    int json_size = 0;
    if (is_array) {
        JSON_Array from_arr = view_as<JSON_Array>(from);
        json_size = from_arr.Length;
    } else {
        snap = from.Snapshot();
        json_size = snap.Length;
    }

    int key_length = 0;
    for (int i = 0; i < json_size; i += 1) {
        key_length = is_array ? JSON_INT_BUFFER_SIZE : snap.KeyBufferSize(i);
        char[] key = new char[key_length];

        bool key_already_exists = false;
        if (is_array) {
            IntToString(i, key, key_length);
        } else {
            snap.GetKey(i, key, key_length);

            // skip meta-keys
            if (json_is_meta_key(key)) {
                continue;
            }

            // skip already existing keys if we aren't in replace mode
            key_already_exists = to.HasKey(key);
            if (! replace && key_already_exists) {
                continue;
            }
        }

        JSONCellType type = from.GetKeyType(key);
        // skip keys of unknown type
        if (type == JSON_Type_Invalid) {
            continue;
        }

        // merge value onto structure
        switch (type) {
            case JSON_Type_String: {
                int length = from.GetKeyLength(key);
                char[] value = new char[length + 1];
                from.GetString(key, value, length + 1);

                if (is_array) {
                    to_arr.PushString(value);
                } else {
                    to.SetString(key, value);
                }
            }
            case JSON_Type_Int: {
                int value = from.GetInt(key);

                if (is_array) {
                    to_arr.PushInt(value);
                } else {
                    to.SetInt(key, value);
                }
            }
            case JSON_Type_Float: {
                float value = from.GetFloat(key);

                if (is_array) {
                    to_arr.PushFloat(value);
                } else {
                    to.SetFloat(key, value);
                }
            }
            case JSON_Type_Bool: {
                bool value = from.GetBool(key);

                if (is_array) {
                    to_arr.PushBool(value);
                } else {
                    to.SetBool(key, value);
                }
            }
            case JSON_Type_Object: {
                JSON_Object value = from.GetObject(key);

                if (is_array) {
                    to_arr.PushObject(value);
                } else {
                    if (autocleanup && key_already_exists) {
                        JSON_Object existing = to.GetObject(key);
                        if (existing != null && existing != value) {
                            existing.Cleanup();
                            delete existing;
                        }
                    }

                    to.SetObject(key, value);
                }
            }
        }

        // set hidden attribute
        bool hidden = from.GetKeyHidden(key);
        if (is_array) {
            to_arr.SetKeyHidden(to_arr.Length - 1, hidden);
        } else {
            to.SetKeyHidden(key, hidden);
        }
    }

    return true;
}

/**
 * Creates a shallow copy of the specified object.
 *
 * @param obj   Object to copy.
 * @returns     A shallow copy of the specified object.
 */
stock JSON_Object json_copy_shallow(JSON_Object obj)
{
    JSON_Object result = obj.IsArray ?
        view_as<JSON_Object>(new JSON_Array())
        : new JSON_Object();
    result.Merge(obj);

    return result;
}

/**
 * Creates a deep copy of the specified object.
 *
 * @param obj   Object to copy.
 * @returns     A deep copy of the specified object.
 */
stock JSON_Object json_copy_deep(JSON_Object obj)
{
    JSON_Object result = obj.IsArray ?
        view_as<JSON_Object>(new JSON_Array())
        : new JSON_Object();
    result.Merge(obj);

    int key_length = 0;
    StringMapSnapshot snap = result.Snapshot();
    for (int i = 0; i < snap.Length; i += 1) {
        key_length = snap.KeyBufferSize(i);
        char[] key = new char[key_length];

        // ignore meta keys
        snap.GetKey(i, key, key_length);
        if (json_is_meta_key(key)) {
            continue;
        }

        // only deep copy objects
        JSONCellType type = obj.GetKeyType(key);
        if (type != JSON_Type_Object) {
            continue;
        }

        JSON_Object value = obj.GetObject(key);
        result.SetObject(key, value.DeepCopy());
    }

    return result;
}

/**
 * Recursively cleans up a JSON instance and any JSON instances stored within.
 *
 * @param obj   JSON instance to clean up.
 */
stock void json_cleanup(JSON_Object obj)
{
    int key_length = 0;
    StringMapSnapshot snap = obj.Snapshot();
    for (int i = 0; i < snap.Length; i += 1) {
        key_length = snap.KeyBufferSize(i);
        char[] key = new char[key_length];

        // ignore meta keys
        snap.GetKey(i, key, key_length);
        if (json_is_meta_key(key)) {
            continue;
        }

        // only clean up objects
        JSONCellType type = obj.GetKeyType(key);
        if (type != JSON_Type_Object) {
            continue;
        }

        JSON_Object value = obj.GetObject(key);
        if (value != null) {
            json_cleanup(value);
            delete value;
        }
    }
    delete snap;

    if (obj.IsArray) {
        JSON_Array obj_arr = view_as<JSON_Array>(obj);
        obj_arr.Clear();
    } else {
        obj.Clear();
    }
}

/**
 * Cleans up and deletes an object, ensuring all resources are freed.
 * Also sets the passed variable to null.
 *
 * @param obj   Object to clean up.
 */
stock void json_cleanup_and_delete(JSON_Object &obj)
{
    if (obj == null) {
        return;
    }

    obj.Cleanup();
    delete obj;

    obj = null;
}
