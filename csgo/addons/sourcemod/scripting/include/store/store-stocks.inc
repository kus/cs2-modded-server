#if defined _store_stocks_included
#endinput
#endif
#define _store_stocks_included

//////////////////////////////////////////////
//General Stocks for the Store system to use. Some are from SMLib, some are from other places.

#define SIZE_OF_INT         2147483647 // without 0

//From SMLib
stock int String_GetRandom(char[] buffer, int size, int length = 32, const char[] chrs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234556789")
{
	int random; int len;
	size--;
	
	if (chrs[0] != '\0')
	{
		len = strlen(chrs) - 1;
	}
	
	int n = 0;
	while (n < length && n < size)
	{
		if (chrs[0] == '\0')
		{
			random = Math_GetRandomInt(33, 126);
			buffer[n] = random;
		}
		else
		{
			random = Math_GetRandomInt(0, len);
			buffer[n] = chrs[random];
		}
		
		n++;
	}
	
	buffer[length] = '\0';
}

//From SMLib
stock Math_GetRandomInt(min, max)
{
	new random = GetURandomInt();
	
	if (random == 0) {
		random++;
	}
	
	return RoundToCeil(float(random) / (float(SIZE_OF_INT) / float(max - min + 1))) + min - 1;
}

//My own Invention (Drixevel) (Designed for handles)
stock bool ClearArray2(Handle hGlobalArray)
{
	if (hGlobalArray != null)
	{
		for (int i = 0; i < GetArraySize(hGlobalArray); i++)
		{
			Handle hArray = GetArrayCell(hGlobalArray, i);
			
			if (hArray != null)
			{
				CloseHandle(hArray);
				hArray = null;
			}
		}
		
		ClearArray(hGlobalArray);
		
		return true;
	}
	
	return false;
}

//Debug Stock... Don't ask why.
stock void GenerateDebugPrint(const char[] sFunc = "N/A")
{
	char sName[64];
	GetPluginFilename(INVALID_HANDLE, sName, sizeof(sName));
	PrintToServer("Name: %s - Function Call: %s", sName, sFunc);
}

//Because Useful (Kappas all around to KissLick)
stock void PushMenuCell(Handle hndl, const char[] id, int data)
{
	char DataString[64];
	IntToString(data, DataString, sizeof(DataString));
	AddMenuItem(hndl, id, DataString, ITEMDRAW_IGNORE);
}

stock int GetMenuCell(Handle hndl, const char[] id, int DefaultValue = 0)
{
	int ItemCount = GetMenuItemCount(hndl);
	char info[64]; char data[64];
	
	for (int i = 0; i < ItemCount; i++)
	{
		GetMenuItem(hndl, i, info, sizeof(info), _, data, sizeof(data));
		
		if (StrEqual(info, id))
		{
			return StringToInt(data);
		}
	}
	
	return DefaultValue;
}

stock bool AddMenuItemFormat(Handle &menu, const char[] info, int style = ITEMDRAW_DEFAULT, const char[] format, any...)
{
	char display[128];
	VFormat(display, sizeof(display), format, 5);
	
	return AddMenuItem(menu, info, display, style);
}

stock void PushMenuString(Handle hndl, const char[] id, const char[] data)
{
	AddMenuItem(hndl, id, data, ITEMDRAW_IGNORE);
}

stock bool GetMenuString(Handle hndl, const char[] id, char[] Buffer, int size)
{
	int ItemCount = GetMenuItemCount(hndl);
	char info[64]; char data[64];
	
	for (int i = 0; i < ItemCount; i++)
	{
		GetMenuItem(hndl, i, info, sizeof(info), _, data, sizeof(data));
		
		if (StrEqual(info, id))
		{
			strcopy(Buffer, size, data);
			return true;
		}
	}
	
	return false;
}