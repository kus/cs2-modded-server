#if defined _anymap_included
 #endinput
#endif
#define _anymap_included

// An AnyMapSnapshot is created via AnyMap.Snapshot(). It captures the
// keys on a map so they can be read. Snapshots must be freed with delete or
// CloseHandle().
methodmap AnyMapSnapshot < Handle
{
	public static any DecodeKey(char key[6])
	{
		return ((key[0] & ~0x80) << 28) | ((key[1] & ~0x80) << 21) | 
		((key[2] & ~0x80) << 14) | ((key[3] & ~0x80) << 7)  | (key[4] & ~0x80);
	}

	// Returns the number of keys in the map snapshot.
	property int Length 
	{
		public get()
		{
			return view_as<StringMapSnapshot>(this).Length;
		}
	}

	// Retrieves the value of a given key in a map snapshot.
	// 	
	// @param index      Key index (starting from 0).
	// @return           Value used as the key.
	// @error            Index out of range.
	public int GetKey(int index)
	{
		char encoded[6];
		view_as<StringMapSnapshot>(this).GetKey(index, encoded, sizeof(encoded));
		return AnyMapSnapshot.DecodeKey(encoded);
	}
};

methodmap AnyMap < Handle
{
	// Creates a hash map. A hash map is a container that can map values (called
	// "keys") to arbitrary values (cells, arrays, or strings). Keys in a hash map
	// are unique. That is, there is at most one entry in the map for a given key.
	//
	// Insertion, deletion, and lookup in a hash map are all considered to be fast
	// operations, amortized to O(1), or constant time.
	//
	// The StringMap must be freed via delete or CloseHandle().

	public AnyMap()
	{
		return view_as<AnyMap>(new StringMap());
	}

	public static void EncodeKey(any value, char dest[6])
	{
		dest[0] = view_as<char>(((value >>> 28) & 0x7F) | 0x80); 
		dest[1] = view_as<char>(((value >>> 21) & 0x7F) | 0x80); 
		dest[2] = view_as<char>(((value >>> 14) & 0x7F) | 0x80); 
		dest[3] = view_as<char>(((value >>> 7) & 0x7F) | 0x80);
		dest[4] = view_as<char>((value & 0x7F) | 0x80);
		dest[5] = '\0';
	}

#if SOURCEMOD_V_MINOR > 10 && SOURCEMOD_V_REV > 6597

	// Clones a map, returning a new handle with the same size and data.
	// This should NOT be confused with CloneHandle. This is a completely new
	// handle with the same data but no relation to the original. It should be
	// closed when no longer needed with delete or CloseHandle().
	//
	// @return              New handle to the cloned map
	public AnyMap Clone()
	{
		return view_as<AnyMap>(view_as<StringMap>(this).Clone());
	}
#endif

	// Sets a value in a map, either inserting a new entry or replacing an old one.
	//
	// @param key        Value to use as the key.
	// @param value      Value to store at this key.
	// @param replace    If false, operation will fail if the key is already set.
	// @return           True on success, false on failure.
	public bool SetValue(const any key, any value, bool replace=true)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).SetValue(encoded, value, replace);
	}

	// Sets an array value in a map, either inserting a new entry or replacing an old one.
	//
	// @param key        Value to use as the key.
	// @param array      Array to store.
	// @param num_items  Number of items in the array.
	// @param replace    If false, operation will fail if the key is already set.
	// @return           True on success, false on failure.
	public bool SetArray(const any key, const any[] array, int num_items, bool replace=true)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).SetArray(encoded, array, num_items, replace);
	}

	// Sets a string value in a map, either inserting a new entry or replacing an old one.
	//
	// @param key        Value to use as the key.
	// @param value      String to store.
	// @param replace    If false, operation will fail if the key is already set.
	// @return           True on success, false on failure.
	public bool SetString(const any key, const char[] value, bool replace=true)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).SetString(encoded, value, replace);
	}

	// Retrieves a value in a map.
	//
	// @param key        Value to use as the key.
	// @param value      Variable to store value.
	// @return           True on success. False if the key is not set, or the key is set 
	//                   as an array or string (not a value).
	public bool GetValue(const any key, any &value)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).GetValue(encoded, value);
	}

	// Retrieves an array in a map.
	//
	// @param key        Value to use as the key.
	// @param array      Buffer to store array.
	// @param max_size   Maximum size of array buffer.
	// @param size       Optional parameter to store the number of elements written to the buffer.
	// @return           True on success. False if the key is not set, or the key is set 
	//                   as a value or string (not an array).
	public bool GetArray(const any key, any[] array, int max_size, int &size=0)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).GetArray(encoded, array, max_size, size);
	}

	// Retrieves a string in a map.
	//
	// @param key        Value to use as the key.
	// @param value      Buffer to store value.
	// @param max_size   Maximum size of string buffer.
	// @param size       Optional parameter to store the number of bytes written to the buffer.
	// @return           True on success. False if the key is not set, or the key is set 
	//                   as a value or array (not a string).
	public bool GetString(const any key, char[] value, int max_size, int &size=0)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).GetString(encoded, value, max_size, size);
	}
#if SOURCEMOD_V_MINOR > 10 && SOURCEMOD_V_REV > 6645

	// Checks whether a key is present in a map.
	//
	// @param key        Value to use as the key.
	// @return           True if the key has been found, else false.
	public bool ContainsKey(const any key)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).ContainsKey(encoded);
	}
#endif

	// Removes a key entry from a Map.
	//
	// @param key        Value to use as the key.
	// @return           True on success, false if the value was never set.
	public bool Remove(const any key)
	{
		char encoded[6];
		AnyMap.EncodeKey(key, encoded);
		return view_as<StringMap>(this).Remove(encoded);
	}

	// Clears all entries from a map.
	public void Clear()
	{
		view_as<StringMap>(this).Clear();
	}

	// Create a snapshot of the map's keys. See AnyMapSnapshot.
	public AnyMapSnapshot Snapshot()
	{
		return view_as<AnyMapSnapshot>(view_as<StringMap>(this).Snapshot());
	}

	// Retrieves the number of elements in a map.
	property int Size 
	{
		public get()
		{
			return view_as<StringMap>(this).Size;
		}
	}
};