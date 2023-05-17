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

#if defined _json_array_included
 #endinput
#endif
#define _json_array_included

#include <string>
#include <json/definitions>
#include <json/object>

methodmap JSON_Array < JSON_Object
{
    /**
     * @section Helpers
     */

    /**
     * Views the instance as its superclass to access overridden methods.
     */
    property JSON_Object Super
    {
        public get()
        {
            return view_as<JSON_Object>(this);
        }
    }

    /**
     * The number of elements in the array.
     */
    property int Length
    {
        public get()
        {
            int length = 0;
            this.Super.GetValue(JSON_ARRAY_INDEX_KEY, length);

            return length;
        }

        public set(int value)
        {
            this.Super.SetValue(JSON_ARRAY_INDEX_KEY, value);
        }
    }

    /**
     * The enforced type of the array.
     */
    property JSONCellType Type
    {
        public get()
        {
            JSONCellType type = JSON_Type_Invalid;
            this.Super.GetValue(JSON_ARRAY_TYPE_KEY, type);

            return type;
        }

        public set(JSONCellType value)
        {
            if (value == JSON_Type_Invalid) {
                this.Super.Super.Remove(JSON_ARRAY_TYPE_KEY);
            } else {
                this.Super.SetValue(JSON_ARRAY_TYPE_KEY, value);
            }
        }
    }

    /**
     * Checks whether the array accepts the type provided.
     *
     * @param type  Type to check for enforcement.
     * @returns     True if the type can be used, false otherwise.
     */
    public bool CanUseType(JSONCellType type)
    {
        return this.Type == JSON_Type_Invalid || this.Type == type;
    }

    /**
     * Checks whether the object has an index.
     *
     * @param index     Index to check existence of.
     * @returns         True if the index exists, false otherwise.
     */
    public bool HasKey(int index)
    {
        return index >= 0 && index < this.Length;
    }

    /**
     * Outputs an index as a string with optional validation.
     *
     * @param index     Index to output.
     * @param output    String buffer to store output.
     * @param max_size  Maximum size of string buffer.
     * @param validate  Should we check that the index is valid before
     *                  converting it to a string? [default: true]
     * @returns         True if the index is valid, false otherwise.
     */
    public bool GetIndexAsString(
        int index,
        char[] output,
        int max_size,
        bool validate = true
    )
    {
        if (validate && ! this.HasKey(index)) {
            return false;
        }

        return IntToString(index, output, max_size) > 0;
    }

    /**
     * @section Metadata Getters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetMetadata
     */
    public any GetMetadata(int index, JSONMetaInfo meta, any default_value)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetMetadata(key, meta, default_value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetKeyType
     */
    public JSONCellType GetKeyType(int index)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return JSON_Type_Invalid;
        }

        return this.Super.GetKeyType(key);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetKeyLength
     */
    public int GetKeyLength(int index)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return -1;
        }

        return this.Super.GetKeyLength(key);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetKeyHidden
     */
    public bool GetKeyHidden(int index)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.GetKeyHidden(key);
    }

    /**
     * @section Metadata Setters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetMetadata
     */
    public bool SetMetadata(int index, JSONMetaInfo meta, any value)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetMetadata(key, meta, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.RemoveMetadata
     */
    public bool RemoveMetadata(int index, JSONMetaInfo meta)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.RemoveMetadata(key, meta);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetKeyType
     */
    public bool SetKeyType(int index, JSONCellType type)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetKeyType(key, type);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetKeyLength
     */
    public bool SetKeyLength(int index, int length)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetKeyLength(key, length);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetKeyHidden
     */
    public bool SetKeyHidden(int index, bool hidden)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetKeyHidden(key, hidden);
    }

    /**
     * @section Getters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetValue
     */
    public bool GetValue(int index, any &value)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.GetValue(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetString
     */
    public bool GetString(int index, char[] value, int max_size, int &size = 0)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.GetString(key, value, max_size, size);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetInt
     */
    public int GetInt(int index, int default_value = -1)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetInt(key, default_value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetFloat
     */
    public float GetFloat(int index, float default_value = -1.0)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetFloat(key, default_value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetBool
     */
    public bool GetBool(int index, bool default_value = false)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetBool(key, default_value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetObject
     */
    public JSON_Object GetObject(int index, JSON_Object default_value = null)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetObject(key, default_value);
    }

    /**
     * @section Setters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetString
     */
    public bool SetString(int index, const char[] value)
    {
        if (! this.CanUseType(JSON_Type_String)){
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetString(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetInt
     */
    public bool SetInt(int index, int value)
    {
        if (! this.CanUseType(JSON_Type_Int)){
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetInt(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetFloat
     */
    public bool SetFloat(int index, float value)
    {
        if (! this.CanUseType(JSON_Type_Float)){
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetFloat(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetBool
     */
    public bool SetBool(int index, bool value)
    {
        if (! this.CanUseType(JSON_Type_Bool)){
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetBool(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetObject
     */
    public bool SetObject(int index, JSON_Object value)
    {
        if (! this.CanUseType(JSON_Type_Object)){
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetObject(key, value);
    }

    /**
     * @section Pushers
     */

    /**
     * Pushes a string to the end of the array.
     *
     * @param value     Value to push.
     * @returns         The element's index on success, -1 otherwise.
     */
    public int PushString(const char[] value)
    {
        int index = this.Length;
        this.Length += 1;
        if (! this.SetString(index, value)) {
            this.Length -= 1;

            return -1;
        }

        return index;
    }

    /**
     * Pushes an int to the end of the array.
     *
     * @param value     Value to push.
     * @returns         The element's index on success, -1 otherwise.
     */
    public int PushInt(int value)
    {
        int index = this.Length;
        this.Length += 1;
        if (! this.SetInt(index, value)) {
            this.Length -= 1;

            return -1;
        }

        return index;
    }

    /**
     * Pushes a float to the end of the array.
     *
     * @param value     Value to push.
     * @returns         The element's index on success, -1 otherwise.
     */
    public int PushFloat(float value)
    {
        int index = this.Length;
        this.Length += 1;
        if (! this.SetFloat(index, value)) {
            this.Length -= 1;

            return -1;
        }

        return index;
    }

    /**
     * Pushes a bool to the end of the array.
     *
     * @param value     Value to push.
     * @returns         The element's index on success, -1 otherwise.
     */
    public int PushBool(bool value)
    {
        int index = this.Length;
        this.Length += 1;
        if (! this.SetBool(index, value)) {
            this.Length -= 1;

            return -1;
        }

        return index;
    }

    /**
     * Pushes a JSON object to the end of the array.
     *
     * @param value     Value to push.
     * @returns         The element's index on success, -1 otherwise.
     */
    public int PushObject(JSON_Object value)
    {
        int index = this.Length;
        this.Length += 1;
        if (! this.SetObject(index, value)) {
            this.Length -= 1;

            return -1;
        }

        return index;
    }

    /**
     * @section Search Helpers
     */

    /**
     * Finds the index of a value in the array.
     *
     * @param value     Value to search for.
     * @returns         The index of the value if it is found, -1 otherwise.
     */
    public int IndexOf(any value)
    {
        any current;
        for (int i = 0; i < this.Length; i += 1) {
            if (this.GetValue(i, current) && value == current) {
                return i;
            }
        }

        return -1;
    }

    /**
     * Finds the index of a string in the array.
     *
     * @param value     String to search for.
     * @returns         The index of the string if it is found, -1 otherwise.
     */
    public int IndexOfString(const char[] value)
    {
        for (int i = 0; i < this.Length; i += 1) {
            if (this.GetKeyType(i) != JSON_Type_String) {
                continue;
            }

            int current_size = this.GetKeyLength(i) + 1;
            char[] current = new char[current_size];
            this.GetString(i, current, current_size);
            if (StrEqual(value, current)) {
                return i;
            }
        }

        return -1;
    }

    /**
     * Determines whether the array contains a value.
     *
     * @param value     Value to search for.
     * @returns         True if the value is found, false otherwise.
     */
    public bool Contains(any value)
    {
        return this.IndexOf(value) != -1;
    }

    /**
     * Determines whether the array contains a string.
     *
     * @param value     String to search for.
     * @returns         True if the string is found, false otherwise.
     */
    public bool ContainsString(const char[] value)
    {
        return this.IndexOfString(value) != -1;
    }

    /**
     * @section StringMap Overrides
     */

    /**
     * Clears all entries and ensures the array index is re-set.
     */
    public void Clear()
    {
        this.Super.Clear();
        this.Length = 0;
    }

    /**
     * Removes an index and its related meta-keys from the array,
     * and shifts down all following element indices.
     *
     * @param key   Key to remove.
     * @returns     True on success, false if the value was never set.
     */
    public bool Remove(int index)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetIndexAsString(index, key, sizeof(key))) {
            return false;
        }

        // remove existing value at index
        if (! this.Super.Remove(key)) {
            return false;
        }

        // shift all following elements down
        for (int i = index + 1; i < this.Length; i += 1) {
            int target = i - 1;
            JSONCellType type = this.GetKeyType(i);

            switch (type) {
                case JSON_Type_String: {
                    int str_length = this.GetKeyLength(i);
                    char[] str_value = new char[str_length];

                    this.GetString(i, str_value, str_length + 1);
                    this.SetString(target, str_value);
                }
                case JSON_Type_Int: {
                    this.SetInt(target, this.GetInt(i));
                }
                case JSON_Type_Float: {
                    this.SetFloat(target, this.GetFloat(i));
                }
                case JSON_Type_Bool: {
                    this.SetBool(target, this.GetBool(i));
                }
                case JSON_Type_Object: {
                    this.SetObject(target, this.GetObject(i));
                }
            }

            this.SetKeyHidden(target, this.GetKeyHidden(i));

            char current_key[JSON_INT_BUFFER_SIZE];
            if (this.GetIndexAsString(
                i,
                current_key,
                sizeof(current_key),
                false
            )) {
                this.Super.Remove(current_key);
            }
        }

        this.Length -= 1;

        return true;
    }

    /**
     * Typed Helpers
     */

    /**
     * The length of the longest string in the array.
     */
    property int MaxStringLength
    {
        public get()
        {
            int max = -1;
            int current = -1;
            for (int i = 0; i < this.Length; i += 1) {
                if (this.GetKeyType(i) != JSON_Type_String) {
                    continue;
                }

                current = this.GetKeyLength(i);
                if (current > max) {
                    max = current;
                }
            }

            return max;
        }
    }

    /**
     * Sets the array to enforce a specific type.
     * This will fail if there are any existing elements
     * in the array which are not of the same type.
     *
     * @param type  Type to enforce.
     * @returns     True if the type was enforced successfully, false otherwise.
     */
    public bool SetType(JSONCellType type)
    {
        if (type == JSON_Type_Invalid) {
            this.Type = type;

            return true;
        }

        for (int i = 0; i < this.Length; i += 1) {
            if (this.GetKeyType(i) != type) {
                return false;
            }
        }

        this.Type = type;

        return true;
    }

    /**
     * Imports a native array's values into the instance.
     *
     * @param type      Type of native values.
     * @param values    Array of values.
     * @param size      Size of array.
     * @returns         True on success, false otherwise.
     */
    public bool ImportValues(JSONCellType type, any[] values, int size)
    {
        bool success = true;
        for (int i = 0; i < size; i += 1) {
            switch (type) {
                case JSON_Type_Int: {
                    success = success && this.PushInt(values[i]) > -1;
                }
                case JSON_Type_Float: {
                    success = success && this.PushFloat(values[i]) > -1;
                }
                case JSON_Type_Bool: {
                    success = success && this.PushBool(values[i]) > -1;
                }
                case JSON_Type_Object: {
                    success = success && this.PushObject(values[i]) > -1;
                }
            }
        }

        return success;
    }

    /**
     * Imports a native array's strings into the instance.
     *
     * @param strings   Array of strings.
     * @param size      Size of array.
     * @returns         True on success, false otherwise.
     */
    public bool ImportStrings(const char[][] strings, int size)
    {
        bool success = true;
        for (int i = 0; i < size; i += 1) {
            success = success && this.PushString(strings[i]) > -1;
        }

        return success;
    }

    /**
     * Exports the instance's values into a native array.
     *
     * @param values    Array to export to.
     * @param size      Size of array.
     */
    public void ExportValues(any[] values, int max_size)
    {
        if (this.Length < max_size) {
            max_size = this.Length;
        }

        for (int i = 0; i < max_size; i += 1) {
            this.GetValue(i, values[i]);
        }
    }

    /**
     * Exports the instance's strings into a native array.
     *
     * @param values    Array to export to.
     * @param size      Size of array.
     */
    public void ExportStrings(
        char[][] values,
        int max_size,
        int max_string_size
    )
    {
        if (this.Length < max_size) {
            max_size = this.Length;
        }

        for (int i = 0; i < max_size; i += 1) {
            this.GetString(i, values[i], max_string_size);
        }
    }

    /**
     * @section Constructor and json.inc Aliases
     */

    /**
     * Creates a new JSON_Array.
     *
     * @param type  The type to enforce for this array, or
     *              JSON_Type_Invalid for no enforced type.
     * @returns     A new JSON_Array.
     */
    public JSON_Array(JSONCellType type = JSON_Type_Invalid)
    {
        JSON_Array self = view_as<JSON_Array>(new JSON_Object());
        self.Length = 0;

        if (type != JSON_Type_Invalid) {
            self.SetType(type);
        }

        return self;
    }

    /**
     * Calls the json_copy_shallow method, replacing the 'obj' parameter
     * with this instance and casting the return value to an array.
     *
     * @see json_copy_shallow
     */
    public JSON_Array ShallowCopy()
    {
        return view_as<JSON_Array>(this.Super.ShallowCopy());
    }

    /**
     * Calls the json_copy_deep method, replacing the 'obj' parameter
     * with this instance and casting the return value to an array.
     *
     * @see json_copy_deep
     */
    public JSON_Array DeepCopy()
    {
        return view_as<JSON_Array>(this.Super.DeepCopy());
    }
};
