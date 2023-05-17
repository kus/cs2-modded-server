#if defined _file_vault_included
	#endinput
#endif

#define _file_vault_included

/**
 * FVault was created by Exolent on 8/24/08
 * This vault system uses actual files and no modules
 * It is very flexible and has many features
 * Visit this page for more information: http://forums.alliedmods.net/showthread.php?t=76453
 */
 
stock const String:_vault_dir[] = "addons/sourcemod/data/file_vault";
stock const String:_temp_vault[] = "fvault_temp.txt";

/** 
 * Retrieves a key name specified by its number
 * 
 * @param vaultname	Vault name to look in
 * @param keynum	Key number within the vault to find key name
 * @param key		String which key name will be copied to
 * @param Length		Length of key name
 * @return		Returns 1 on success, 0 on failue.
 */
stock FvaultGetKeyname(const String:vaultname[], const keynum, String:key[], Length)
{
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	if( !FileExists(filename, true) )
	{
		return 0;
	}
	
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new String:_data[64];
	
	new line = -1;
	
	while( !IsEndOfFile(vault) )
	{
		ReadFileLine(vault, _data, sizeof(_data) - 1);
		
		if( ++line == keynum )
		{
			BreakString(_data, key, Length);
			
			CloseHandle(vault);
			
			return 1;
		}
	}
	
	CloseHandle(vault);
	
	return 0;
}

/** 
 * Retrieves a key number specified by its name
 * 
 * @param vaultname	Vault name to look in
 * @param key		Key name to search for
 * @return		Returns key number on success, -1 on failure
 */
stock FvaultGetKeynum(const String:vaultname[], const String:key[])
{
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	if( !FileExists(filename, true) )
	{
		return -1;
	}
	
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new String:_data[70], String:_key[64], String:_other[3], String:bit[2][64];
	
	new line = -1;
	
	while( !IsEndOfFile(vault) )
	{
		ReadFileLine(vault, _data, sizeof(_data) - 1);
		
		BreakString(_data, _key, sizeof(_key) - 1);
		
		line++;
		
		if( StrEqual(_key, key, true) )
		{
			CloseHandle(vault);
			
			return line;
		}
	}
	
	CloseHandle(vault);
	
	return -1;
}

/** 
 * Retrieves data specified by a key
 * 
 * @param vaultname	Vault name to look in
 * @param key		Key name to look for the data
 * @param data		String which data will be copied to
 * @param Length		Length of data
 * @param timestamp	The unix time of when the data was last set ( -1 if permanent data, 0 if old fvault version ) ( optional param )
 * @return		Returns 1 on success, 0 on failue.
 */
stock FvaultGetData(const String:vaultname[], const String:key[], String:data[], Length, &timestamp=0)
{
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	if( !FileExists(filename, true) )
	{
		return 0;
	}
	
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new String:_data[512], String:_key[64], String:_time[32], String:bit[2][64];
	
	while( !IsEndOfFile(vault) )
	{
		
		ReadFileLine(vault, _data, sizeof(_data) - 1);
		
		BreakString(_data, _key, sizeof(_key));
		
		if( StrEqual(_key, key) )
		{
			new _len = strlen(_key) + 4; // + 2 = quotes on key, + 1 = space, + 1 = first quote
			for( new i = FormatEx(data, Length, _data[_len]) - 1; i > 0; i-- )
			{
				if( data[i] == '"' ) break;
				
				if( data[i] == ' '
				&& data[i - 1] == '"' )
				{
					data[i - 1] = '^0';
					
					FormatEx(_time, sizeof(_time) - 1, data[i + 1]);
					timestamp = str_to_num(_time);
					break;
				}
			}
			
			FileClose(vault);
			
			return 1;
		}
	}
	
	FileClose(vault);
	
	FormatEx(data, Length, "");
	
	return 0;
}

/** 
 * Sets data of a key with current timestamp
 * 
 * @param vaultname	Vault name to look in
 * @param key		Key name to which data will be set
 * @param data		Data to set to key
 * @return		Does not return a value.
 */
stock FvaultSetData(const String:vaultname[], const String:key[], const String:data[])
{
	_fvault_set_data(vaultname, key, data, GetTime());
}

/** 
 * Sets data of a key permanently (can't be removed with fvault_prune)
 * 
 * @param vaultname	Vault name to look in
 * @param key		Key name to which data will be set
 * @param data		Data to set to key
 * @return		Does not return a value.
 */
stock FvaultPsetData(const String:vaultname[], const String:key[], const String:data[])
{
	_fvault_set_data(vaultname, key, data, -1);
}

_fvault_set_data(const String:vaultname[], const String:key[], const String:data[], const timestamp)
{
	new Handle:file = OpenFile(_temp_vault, "wt", true);
	
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new String:_data[512], String:_key[64];
	
	new bool:replaced = false;
	
	while( !IsEndOfFile(vault) )
	{	
		ReadFileLine(vault, _data, sizeof(_data) - 1);
		
		BreakString(_data, _key, sizeof(_key) - 1);

		if( StrEqual(_key, key, true) && !replaced )
		{
			WriteFileLine(file, "\"%s\" \"%s\" %i\n", key, data, timestamp);
			
			replaced = true;
		}
		else
		{
			WriteFileLine(file, _data);
		}
	}
	
	CloseHandle(file);
	CloseHandle(vault);
	
	if( !replaced )
	{
		file = OpenFile(filename, "a+", true);
		WriteFileLine(file, "\"%s\" \"%s\" %i\n", key, data, timestamp);
		CloseHandle(file);
		
		DeleteFile(_temp_vault, true);
	}
	else
	{
		DeleteFile(filename, true);
		
		while( !RenameFile(_temp_vault, filename, true) ) { }
	}
}

/** 
 * Removes a key from a vault
 * 
 * @param vaultname	Vault name to look in
 * @param key		Key to remove
 * @return		No return
 */
stock FvaultRemoveKey(const String:vaultname[], const String:key[])
{
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	if( !FileExists(filename, true) )
	{
		return;
	}
	
	new Handle:file = OpenFile(_temp_vault, "wt", true);
	
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new String:_data[512], String:_key[64], String:_other[3], String:bit[2][64];
	new bool:found_key;
	
	while( !IsEndOfFile(vault) )
	{	
		ReadFileLine(vault, _data, sizeof(_data) - 1);
		
		BreakString(_data, _key, sizeof(_key) - 1);
		
		if( StrEqual(_key, key, true) )
		{
			found_key = true;
			continue;
		}
		
		WriteFileLine(file, _data);
	}
	
	CloseHandle(file);
	CloseHandle(vault);
	
	if( found_key )
	{
		DeleteFile(filename, true);
		
		while( !RenameFile(_temp_vault, filename, true) ) { }
	}
	else
	{
		DeleteFile(_temp_vault, true);
	}
}

/**
 * Prunes the vault for keys that are within the given timestamps
 * 
 * @param vaultname	Vault name to look in
 * @param start		If timestamp is after this Unix Time (set -1 to prune from very start)
 * @param end		If timestamp is before this Unix Time (set -1 to prune to most time)
 * @return		Returns number of keys pruned
 */

stock FvaultPrune(const String:vaultname[], const start=-1, const end=-1)
{
	if( start == -1 && end == -1 )
	{
		new keys = fvault_size(vaultname);
		if( keys )
		{
			fvault_clear(vaultname);
		}
		
		return keys;
	}
	
	new filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	if( !FileExists(filename, true) )
	{
		return 0;
	}
	
	new Handle:file = OpenFile(_temp_vault, "wt", true);
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new keys;
	
	new String:data[512], i, String:_time[32], timestamp;
	while( !IsEndOfFile(vault) )
	{
		ReadFileLine(vault, data, sizeof(data) - 1);
		
		if( data[0] )
		{
			_time[0] = 0;
			
			for( i = strlen(data) - 1; i >= 0; i-- )
			{
				if( data[i] == '"' ) break;
				
				if( data[i] == ' ' )
				{
					FormatEx(_time, sizeof(_time) - 1, data[i + 1]);
					break;
				}
			}
			
			timestamp = StringToInt(_time);
			if( timestamp != -1 )
			{
				if( start == -1 && timestamp <= end
				|| end == -1 && timestamp >= start
				|| start <= timestamp <= end )
				{
					keys++;
					continue;
				}
			}
		}
		
		WriteFileLine(file, data);
	}
	
	CloseHandle(file);
	CloseHandle(vault);
	
	if( keys )
	{
		DeleteFile(filename);
		
		while( !RenameFile(_temp_vault, filename, true) ) { }
	}
	else
	{
		DeleteFile(_temp_vault);
	}
	
	return keys;
}

/**
 * Updates the timestamp on a key located within the vault
 * 
 * @param vaultname	Vault name to look in
 * @param key		Key to update timestamp (if it doesn't exist, a blank value will be set)
 * @param timestamp	Unix Time to set for the key (-1 for current time)
 * @return		Returns 2 on new entry, 1 on success, 0 on failure for the key having a permanent timestamp
 */
stock FvaultTouch(const String:vaultname[], const String:key[], const timestamp=-1)
{
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	static new_time;
	if( (new_time = timestamp) == -1 )
	{
		new_time = get_systime();
	}
	
	if( !FileExists(filename, true) )
	{
		new Handle:vault = OpenFile(filename, "wt", true);
		WriteFileLine(vault, "\"%s\" \"\" %i\n", key, new_time);
		CloseHandle(vault);
		return 2;
	}
	
	new Handle:file = OpenFile(_temp_vault, "wt", true);
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new bool:updated;
	
	new String:data[512], String:_key[64], Length, i, String:_time[32], String:bit[2][64];
	while( !IsEndOfFile(vault) )
	{
		
		ReadFileLine(vault, data, sizeof(data) - 1);
		
		BreakString(data, _key, sizeof(_key) - 1);
		
		if( StrEqual(_key, key, true) )
		{
			_time[0] = 0;
			
			for( i = strlen(data) - 1; i >= 0; i-- )
			{
				if( data[i] == '"' ) break;
				
				if( data[i] == ' ' )
				{
					data[i] = '^0';
					FormatEx(_time, sizeof(_time) - 1, data[i + 1]);
					break;
				}
			}
			
			if( StringToInt(_time) == -1 )
			{
				CloseHandle(file);
				CloseHandle(vault);
				
				DeleteFile(_temp_vault);
				
				return 0;
			}
			
			WriteFileLine(file, "%s %i\n", data, new_time);
			
			updated = true;
		}
		else
		{
			WriteFileLine(file, data);
		}
	}
	
	if( !updated )
	{
		WriteFileLine(file, "\"%s\" \"\" %i\n", key, new_time);
	}
	
	CloseHandle(file);
	CloseHandle(vault);
	
	DeleteFile(filename, true);
	
	while( !RenameFile(_temp_vault, filename, true) ) { }
	
	return (_:(!updated) + 1);
}

/** 
 * Retrieves total keys located within the vault
 * 
 * @param vaultname	Vault name to look in
 * @return		Returns amount of keys in vault
 */
stock FvaultSize(const String:vaultname[])
{
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	if(!FileExists(filename, true))
		return 0;
	
	new Handle:vault = OpenFile(filename, "rt", true);
	
	new keys;
	
	new String:data[1];
	
	while( !IsEndOfFile(vault) )
	{
		ReadFileLine(vault, data, 0);
		
		if( data[0] )
		{
			keys++;
		}
	}
	
	CloseHandle(vault);
	return keys
}

/** 
 * Clears all key entries for a vault
 * 
 * @param vaultname	Vault name to erase
 * @return		No return
 */
stock FvaultClear(const String:vaultname[])
{
 	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	CloseHandle(OpenFile(filename, "wt", true));
}

/** 
 * Retrieves a vault name specified by its number
 * 
 * @param vaultnum	Vault number to find the vault name
 * @param vaultname	String which vault name will be copied to
 * @param Length		Length of vault name
 * @return		Returns 1 on success, 0 on failue.
 */
stock FvaultGetVaultname(const vaultnum, String:vaultname[], Length)
{
	if( !DirExists(_vault_dir, true) )
	{
		CreateDirectory(_vault_dir, 511, true);
		return 0;
	}
	
	new filenum;
	
	new Handle:dir = OpenDirectory(_vault_dir, true);

	while( ReadDirEntry(dir, vaultname, Length) )
	{
		if( StrEqual(vaultname, ".", true) || StrEqual(vaultname, "..", true) )
		{
			continue;
		}
		
		if( filenum == vaultnum )
		{
			CloseHandle(dir);
			
			ReplaceStringeEx(vaultname, Length, ".txt", "");
			
			return 1;
		}
		
		filenum++;
	}
	
	CloseHandle(dir);
	
	FormatEx(vaultname, Length, "");
	
	return 0;
}

/** 
 * Retrieves a vault number specified by its name
 * 
 * @param vaultname	Vault name to find the number
 * @return		Returns vault number on success, -1 on failure
 */
stock FvaultGetVaultnum(const String:vaultname[])
{
	if( !DirExists(_vault_dir, true) )
	{
		CreateDirectory(_vault_dir, 511, true);

		return -1;
	}
	
	new String:filename[128], filenum;
	
	new Handle:dir = OpenDirectory(_vault_dir, true);
	
	while( ReadDirEntry(dir, filename, sizeof(filename) - 1) )
	{
		if( StrEqual(filename, ".", true) || StrEqual(filename, "..", true) )
		{
			continue;
		}
		
		ReplaceStringEx(filename, sizeof(filename) - 1, ".txt", "");
		
		if( StrEqual(filename, vaultname, true) )
		{
			CloseHandle(dir);
			
			return filenum;
		}
		
		filenum++;
	}
	
	CloseHandle(dir);
	
	FormatEx(vaultname, Length, "");
	
	return -1;
}

/** 
 * Retrieves total vaults ever created
 * 
 * @return		Returns amount of vaults
 */
stock FvaultTotal()
{
	if( !DirExists(_vault_dir, true) )
	{
		CreateDirectory(_vault_dir, 511, true);
		return 0;
	}
	
	new String:vaultname[128], String:filename[128], filenum;
	
	new Handle:dir = OpenDirectory(_vault_dir, true);

	while( ReadDirEntry(dir, vaultname, sizeof(vaultname) - 1) )
	{
		if( StrEqual(vaultname, ".", true) || StrEqual(vaultname, "..", true) )
		{
			continue;
		}
		
		FormatEx(filename, sizeof(filename) - 1, "%s/%s", _vault_dir, vaultname);
		if( FileExists(filename, true) )
		{
			filenum++;
		}
	}
	
	CloseHandle(dir);
	
	return filenum;
}

/**
 * Gets all vault keys, data, and timestamps
 * 
 * @param		vaultname - Vault name to look in
 * @param		keys - cellarray holding all of the keys
 * @param		datas - cellarray holding all of the data values
 * @param		timestamps - cellarray holding all of the timestamps
 * 
 * @return		Returns total number of entries in vault
 * 
 * @note		keys needs to be created like this: ArrayCreate(64)
 * 			datas needs to be created like this: ArrayCreate(512)
 * 			timestamps need to be created like this: ArrayCreate()
 */
stock FvaultLoad(const String:vaultname[], Handle:keys=INVALID_HANDLE, Handle:datas=INVALID_HANDLE, Handle:timestamps=INVALID_HANDLE)
{
	new String:filename[128];
	_FormatVaultName(vaultname, filename, sizeof(filename) - 1);
	
	if( !FileExists(filename, true) )
	{
		return 0;
	}
	
	new Handle:vault = OpenFile(filename, "rt");
	
	new array_size;
	
	new String:filedata[1024];
	new String:key[64], String:data[512], String:timestamp[32], String:bit[3][512];
	while( !IsEndOfFile(vault) )
	{	
		ReadFileLine(vault, filedata, sizeof(filedata) - 1);
		

		if(BreakString(filedata, key, sizeof(key)) == -1)
			continue;
		
		ReplaceStringEx(filedata, sizeof(filedata), key, "");
		
		if(BreakString(filedata, data, sizeof(data)) == -1)
			continue;
		
		ReplaceStringEx(filedata, sizeof(filedata), data, "");
		
		if(BreakString(filedata, timestamp, sizeof(timestamp)) == -1)
			continue;

		
		if( keys != INVALID_HANDLE )
		{
			ArrayPushString(keys, key);
		}
		if( datas != INVALID_HANDLE )
		{
			ArrayPushString(datas, data);
		}
		if( timestamps != INVALID_HANDLE )
		{
			ArrayPushCell(timestamps, str_to_num(timestamp));
		}
		
		array_size++;
	}
	
	CloseHandle(vault);
	
	return array_size;
}

stock _FormatVaultName(const String:vaultname[], String:filename[], Length)
{
	new const String:invalid_chars[][] =
	{
		"/", "*"//, "\", ":", "?", "\"", "<", ">", "|"
	};
	
	static String:tempvault[128], i;
	FormatEx(tempvault, sizeof(tempvault) - 1, vaultname);
	
	for( i = 0; i < sizeof(invalid_chars); i++ )
	{
		ReplaceString(tempvault, sizeof(tempvault) - 1, invalid_chars[i], "");
	}
	
	if( !DirExists(_vault_dir, true) )
	{
		CreateDirectory(_vault_dir, 511, true);
	}
	
	FormatEx(filename, Length, "%s/%s.txt", _vault_dir, tempvault);
}
