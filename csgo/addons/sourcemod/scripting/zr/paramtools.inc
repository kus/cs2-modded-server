/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   paramtools.inc
 *  Type:		   Core 
 *  Description:	Provides functions for parsing strings with parameters in
 *				  key=value format.
 *
 *				  Note: Does not support spaces or quoted strings.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */


/**
 * Counts number of parameters in a string.
 */
stock int GetParameterCount(const char[] rawString)
{
	int lenRawString = strlen(rawString);
	int paramCount;
	int searchPos;
	int splitPos;
	
	// Check if the raw string is empty.
	if (lenRawString == 0)
	{
		return 0;
	}
	
	// Count number of "=".
	for (splitPos = 0; splitPos < lenRawString; splitPos++)
	{
		// Find next "=".
		searchPos = StrContains(rawString[splitPos], "=", false);
		
		// Note: searchPos is an offset from rawString[splitPos]. If searchPos
		//	   is 0, then the real position is splitPos.
		
		// Check if "=" was found.
		if (searchPos >= 0)
		{
			// Parameter found.
			paramCount++;
			
			// Update split position.
			splitPos += searchPos;
		}
		else
		{
			// No need to continue. "=" not found.
			break;
		}
	}
	
	return paramCount;
}

/**
 * Gets a value from a string in key=value format and writes it to a buffer.
 *
 * Note: No spaces in values or parameter names. Only spaces between each
 *	   key/value set.
 *
 * Example raw string: "key1=val1 key2=5.3 key3=1"
 *
 * @param buffer		Destination string bufffer.
 * @param maxlen		Length of destination buffer.
 * @param rawString	 Source string to read from.
 * @param parameter	 Parameter to read.
 *
 * @return			  Number of cells written. -1 if the parameter wasn't
 *					  found.
 */
stock int GetParameterValue(char[] buffer, int maxlen, const char[] rawString, const char[] parameter)
{
	int paramPos;
	int paramLen;
	int valuePos;
	int valueLen;
	int nextPos;
	int splitPos;
	
	// Get the position of parameter.
	paramPos = StrContains(rawString, parameter, false);
	splitPos = paramPos;
	
	// Check if found.
	if (paramPos >= 0)
	{
		// Get parameter length.
		paramLen = strlen(parameter);
		
		// Get the position of the next parameter by finding the next space.
		nextPos = StrContains(rawString[splitPos], " ");
		
		// Check if the next parameter was found.
		if (nextPos >= 0)
		{
			// Calculate value starting position.
			valuePos = paramPos + paramLen + 1;
			
			// Calculate value length. Note: Adding 1 for space to the null
			// terminator.
			valueLen = nextPos + splitPos - valuePos + 1;
			
			// Check if value length is longer than buffer size.
			if (valueLen > maxlen)
			{
				valueLen = maxlen;
			}
			
			// Copy value to buffer.
			return strcopy(buffer, valueLen, rawString[valuePos]);
			
		}
		else
		{
			// It's the last or only parameter, get the rest of the string.
			return strcopy(buffer, maxlen, rawString[paramPos + paramLen + 1]);
		}
	}
	else
	{
		return -1;
	}
}

/**
 * Gets the name of the parameter at the specified index.
 *
 * @param buffer			Destination string bufffer.
 * @param maxlen			Length of destination buffer.
 * @param rawString		 Source string to read from.
 * @param parameterIndex	The zero-based parameter index to read.
 *
 * @return	  Number of cells written. -1 if failed.
 */
stock int GetParameterName(char[] buffer, int maxlen, const char[] rawString, int parameterIndex)
{
	int paramPos;
	int valuePos;
	int nextValuePos;
	int splitPos;
	
	// Check if the raw string is empty.
	if (strlen(rawString) == 0)
	{
		return -1;
	}
	
	if (parameterIndex > 0)
	{
		// Get the value starting position for the previous index.
		for (int index = 0; index < parameterIndex - 1; index++)
		{
			valuePos = StrContains(rawString[splitPos], "=");
			splitPos += valuePos;
		}
		
		// Find the next space from splitPos where the specified parameter
		// starts.
		paramPos = StrContains(rawString[splitPos], " ") + splitPos + 1;
		
		// Update split position.
		splitPos += paramPos;
		
		// Find the next value position from splitPos to get the end position
		// of the parameter name.
		nextValuePos = StrContains(rawString[splitPos], "=") + splitPos;
		
		// Check if a value is specified.
		if (nextValuePos > 0)
		{
			// Return the parameter name between paramPos and nextValuePos.
			return strcopy(buffer, nextValuePos - paramPos + 1, rawString[paramPos]);   // + 1 to include null terminator.
		}
		else
		{
			// No value specified. Return the rest of rawString from paramPos.
			return strcopy(buffer, maxlen, rawString[paramPos]);
		}
	}
	else
	{
		// It's the first parameter. Read the string until '=' is found.
		valuePos = StrContains(rawString, "=");
		
		// Check if a value is specified.
		if (valuePos > 0)
		{
			// Return the parameter name.
			return strcopy(buffer, valuePos + 1, rawString);		// + 1 to include null terminator.
		}
		else
		{
			// No value specified, return the entire raw string.
			return strcopy(buffer, maxlen, rawString);
		}
	}
}
