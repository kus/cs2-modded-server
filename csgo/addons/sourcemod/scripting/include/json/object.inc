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

#if defined _json_object_included
 #endinput
#endif
#define _json_object_included

#include <string>
#include <json/definitions>

methodmap JSON_Object < StringMap
{
    /**
     * @section Helpers
     */

    /**
     * Views the instance as its superclass to access overridden methods.
     */
    property StringMap Super
    {
        public get()
        {
            return view_as<StringMap>(this);
        }
    }

    /**
     * Checks whether the object has a key.
     *
     * @param key   Key to check existence of.
     * @returns     True if the key exists, false otherwise.
     */
    public bool HasKey(const char[] key)
    {
        int dummy_int;
        char dummy_str[1];

        return this.GetValue(key, dummy_int)
            || this.GetString(key, dummy_str, sizeof(dummy_str));
    }

    /**
     * Whether the current object is an array.
     */
    property bool IsArray {
        public get()
        {
            return this.HasKey(JSON_ARRAY_INDEX_KEY);
        }
    }

    /**
     * The number of keys in the object (including meta-keys).
     */
    property int Length {
        public get()
        {
            StringMapSnapshot snap = this.Snapshot();
            int length = snap.Length;
            delete snap;

            return length;
        }
    }

    /**
     * @section Metadata Getters
     */

    public any GetMetadata(
        const char[] key,
        JSONMetaInfo meta,
        any default_value
    )
    {
        int max_size = json_meta_key_length(key);
        char[] meta_key = new char[max_size];
        json_format_meta_key(meta_key, max_size, key, meta);

        if (meta == JSON_Meta_Hidden) {
            return this.HasKey(meta_key);
        }

        any value;
        return this.GetValue(meta_key, value) ? value : default_value;
    }

    /**
     * Gets the cell type stored at a key.
     *
     * @param key   Key to get value type for.
     * @returns     Value type for key provided,
     *              or JSON_Type_Invalid if it does not exist.
     */
    public JSONCellType GetKeyType(const char[] key)
    {
        return view_as<JSONCellType>(
            this.GetMetadata(key, JSON_Meta_Type, JSON_Type_Invalid)
        );
    }

    /**
     * Gets the length of the string stored at a key.
     *
     * @param key   Key to get string length for.
     * @returns     Length of string at key provided,
     *              or -1 if it is not a string/does not exist.
     */
    public int GetKeyLength(const char[] key)
    {
        return view_as<int>(this.GetMetadata(key, JSON_Meta_Length, -1));
    }

    /**
     * Gets whether the key should be hidden from encoding.
     *
     * @param key   Key to get hidden state for.
     * @returns     Whether or not the key should be hidden.
     */
    public bool GetKeyHidden(const char[] key)
    {
        return view_as<bool>(this.GetMetadata(key, JSON_Meta_Hidden, false));
    }

    /**
     * @section Metadata Setters
     */

    public bool SetMetadata(const char[] key, JSONMetaInfo meta, any value)
    {
        int max_size = json_meta_key_length(key);
        char[] meta_key = new char[max_size];
        json_format_meta_key(meta_key, max_size, key, meta);

        if (meta == JSON_Meta_Hidden && ! view_as<bool>(value)) {
            this.Super.Remove(meta_key);

            return true;
        }

        return this.SetValue(meta_key, value);
    }

    public bool RemoveMetadata(const char[] key, JSONMetaInfo meta)
    {
        int max_size = json_meta_key_length(key);
        char[] meta_key = new char[max_size];
        json_format_meta_key(meta_key, max_size, key, meta);

        return this.Super.Remove(meta_key);
    }

    /**
     * Sets the cell type stored at a key.
     *
     * @param key   Key to set value type for.
     * @param type  Type to set key to.
     * @returns     True on success, false otherwise.
     */
    public bool SetKeyType(const char[] key, JSONCellType type)
    {
        return this.SetMetadata(key, JSON_Meta_Type, type);
    }

    /**
     * Sets the length of the string stored at a key.
     *
     * @param key       Key to set string length for.
     * @param length    Length to set string to.
     * @returns         True on success, false otherwise.
     */
    public bool SetKeyLength(const char[] key, int length)
    {
        return this.SetMetadata(key, JSON_Meta_Length, length);
    }

    /**
     * Sets whether the key should be hidden from encoding.
     *
     * @param key       Key to set hidden state for.
     * @param hidden    Wheter or not the key should be hidden.
     * @returns         True on success, false otherwise.
     */
    public bool SetKeyHidden(const char[] key, bool hidden)
    {
        return this.SetMetadata(key, JSON_Meta_Hidden, hidden);
    }

    /**
     * @section Getters
     */

    // GetValue is implemented natively by StringMap

    // GetString is implemented natively by StringMap

    /**
     * Retrieves the int stored at a key.
     *
     * @param key           Key to retrieve int value for.
     * @param default_value  Value to return if the key does not exist.
     * @returns             Value stored at key.
     */
    public int GetInt(const char[] key, int default_value = -1)
    {
        int value;
        return this.GetValue(key, value) ? value : default_value;
    }

    /**
     * Retrieves the float stored at a key.
     *
     * @param key           Key to retrieve float value for.
     * @param default_value  Value to return if the key does not exist.
     * @returns             Value stored at key.
     */
    public float GetFloat(const char[] key, float default_value = -1.0)
    {
        float value;
        return this.GetValue(key, value) ? value : default_value;
    }

    /**
     * Retrieves the bool stored at a key.
     *
     * @param key           Key to retrieve bool value for.
     * @param default_value  Value to return if the key does not exist.
     * @returns             Value stored at key.
     */
    public bool GetBool(const char[] key, bool default_value = false)
    {
        bool value;
        return this.GetValue(key, value) ? value : default_value;
    }

    /**
     * Retrieves the JSON object stored at a key.
     *
     * @param key           Key to retrieve object value for.
     * @param default_value  Value to return if the key does not exist.
     * @returns             Value stored at key.
     */
    public JSON_Object GetObject(
        const char[] key,
        JSON_Object default_value = null
    )
    {
        JSON_Object value;
        return this.GetValue(key, value) ? value : default_value;
    }

    /**
     * @section Setters
     */

    /**
     * Sets the string stored at a key.
     *
     * @param key       Key to set to string value.
     * @param value     Value to set.
     * @returns         True on success, false otherwise.
     */
    public bool SetString(const char[] key, const char[] value)
    {
        return this.Super.SetString(key, value)
            && this.SetKeyType(key, JSON_Type_String)
            && this.SetKeyLength(key, strlen(value));
    }

    /**
     * Sets the int stored at a key.
     *
     * @param key       Key to set to int value.
     * @param value     Value to set.
     * @returns         True on success, false otherwise.
     */
    public bool SetInt(const char[] key, int value)
    {
        return this.SetValue(key, value)
            && this.SetKeyType(key, JSON_Type_Int);
    }

    /**
     * Sets the float stored at a key.
     *
     * @param key       Key to set to float value.
     * @param value     Value to set.
     * @returns         True on success, false otherwise.
     */
    public bool SetFloat(const char[] key, float value)
    {
        return this.SetValue(key, value)
            && this.SetKeyType(key, JSON_Type_Float);
    }

    /**
     * Sets the bool stored at a key.
     *
     * @param key       Key to set to bool value.
     * @param value     Value to set.
     * @returns         True on success, false otherwise.
     */
    public bool SetBool(const char[] key, bool value)
    {
        return this.SetValue(key, value)
            && this.SetKeyType(key, JSON_Type_Bool);
    }

    /**
     * Sets the JSON object stored at a key.
     *
     * @param key       Key to set to object value.
     * @param value     Value to set.
     * @returns         True on success, false otherwise.
     */
    public bool SetObject(const char[] key, JSON_Object value)
    {
        return this.SetValue(key, value)
            && this.SetKeyType(key, JSON_Type_Object);
    }

    /**
     * @section StringMap Overrides
     */

    /**
     * Removes an item from the object by key.
     *
     * @param key       Key of object to remove.
     * @returns         True on success, false if the value was never set.
     */
    public bool Remove(const char[] key)
    {
        for (int i = 0; i < sizeof(JSON_ALL_METADATA); i += 1) {
            this.RemoveMetadata(key, JSON_ALL_METADATA[i]);
        }

        return this.Super.Remove(key);
    }

    /**
     * @section Constructor and json.inc Aliases
     */

    /**
     * Creates a new JSON_Object.
     *
     * @returns     A new JSON_Object.
     */
    public JSON_Object()
    {
        return view_as<JSON_Object>(CreateTrie());
    }

    /**
     * Calls the json_encode method, replacing the 'obj' parameter
     * with this instance.
     *
     * @see json_encode
     */
    public void Encode(
        char[] output,
        int max_size,
        int options = JSON_NONE,
        int depth = 0
    )
    {
        json_encode(this, output, max_size, options, depth);
    }

    /**
     * Calls the json_merge method, replacing the 'to' parameter
     * ith this instance.
     *
     * @see json_merge
     */
    public bool Merge(JSON_Object from, int options = JSON_MERGE_REPLACE)
    {
        return json_merge(this, from, options);
    }

    /**
     * Calls the json_copy_shallow method, replacing the 'obj' parameter
     * with this instance.
     *
     * @see json_copy_shallow
     */
    public JSON_Object ShallowCopy()
    {
        return json_copy_shallow(this);
    }

    /**
     * Calls the json_copy_deep method, replacing the 'obj' parameter
     * with this instance.
     *
     * @see json_copy_deep
     */
    public JSON_Object DeepCopy()
    {
        return json_copy_deep(this);
    }

    /**
     * Calls the json_cleanup method, replacing the 'obj' parameter
     * with this instance.
     *
     * @see json_cleanup
     */
    public void Cleanup()
    {
        json_cleanup(this);
    }
};
