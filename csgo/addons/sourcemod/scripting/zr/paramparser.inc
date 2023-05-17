/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   paramparser.inc
 *  Type:		   Core 
 *  Description:	Provides functions for parsing single line strings with
 *				  flags, and parameters in key=value format.
 *
 *				  Supports quoted strings and escaped characters like "\n"
 *				  and "\t".
 *
 *				  Examle raw string:
 *				  "type=interval -disabled msg="Title:\n\"Example\"."
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
 * @section Limit settings.
 */
#define PARAM_NAME_MAXLEN   64	  /** Maximum length of key name or flag name. */
#define PARAM_VALUE_MAXLEN  256	 /** Maximum length of value string. */
/**
 * @endsection
 */

/**
 * @section Parsing error codes.
 */
#define PARAM_ERROR_EMPTY			   1   /** Source string is empty. */
#define PARAM_ERROR_FULL				2   /** Destination array is full. */
#define PARAM_ERROR_UNEXPECTED_KEY	  3   /** Unexpected key name. Could not find a equation sign (=) after previous key name. */
#define PARAM_ERROR_UNEXPECTED_END	  4   /** Unexpected end of source string. */
#define PARAM_ERROR_MISSING_QUOTE	   5   /** Unexpected end of source string. Missing end quote character. */
#define PARAM_ERROR_UNKNOWN			 6   /** Unknown error. The parser got a invalid result from a search function it couldn't handle. */
/**
 * @endsection
 */

/**
 * Modes for what to do and expect when parsing. White space characters between
 * modes are ignored.
 */
enum ParamModes
{
	ParamMode_TypeCheck,  /** Check if it's a flag or a key. */
	ParamMode_Flag,	   /** Expect a flag name (starts with "-"). */
	ParamMode_Key,		/** Expect a key name. */
	ParamMode_Equal,	  /** Expect a equation sign. */
	ParamMode_Value	   /** Expect a value string. */
}

/**
 * Structure for storing a key/value pair.
 */
enum ParamParseResult
{
	bool:Param_IsFlag,					  /** Specifies whether it's a flag or not. */
	String:Param_Name[PARAM_NAME_MAXLEN],   /** Key or flag name. */
	String:Param_Value[PARAM_VALUE_MAXLEN]  /** Value. Only used if a key. */
}



/**************************************
 *									*
 *	   PARAMETER FUNCTIONS		  *
 *									*
 **************************************/

/**
 * Parses a parameter string in "key=value" format and store the result in a
 * ParamParseResult array.
 *
 * @param buffer		A ParamParseResult array to store results.
 * @param maxlen		Maximum number of keys that can be stored (first
 *					  dimension of buffer).
 * @param paramString   The source string to parse. String is trimmed before
 *					  parsing.
 * @param err		   Opional output: Error code if parsing error.
 * @param errPos		Opional output: Position in paramString where the error
 *					  occoured.
 * @return			  Number of keys parsed.
 */
stock int ParamParseString(buffer[][ParamParseResult], int maxlen, char[] paramString, int &err = 0, int &errPos = -1)
{
	/*
	 *  VALIDATION OF INPUT AND BUFFERS
	 */
	
	// Trim raw string.
	TrimString(paramString);
	
	// Check if raw string is empty.
	if (strlen(paramString) == 0)
	{
		err = PARAM_ERROR_EMPTY;
		errPos = 0;
		return 0;
	}
	
	// Validate specified length of destination buffer.
	if (maxlen == 0)
	{
		err = PARAM_ERROR_FULL;
		errPos = 0;
		return 0;
	}
	
	
	/*
	 *  PARSE LOOP
	 */
	
	// Get raw string length.
	int rawlen = sizeof(paramString);
	
	// Initialize. Expect the start to be a key or a flag.
	ParamModes mode = ParamMode_TypeCheck;
	
	// Counter for number of parameters parsed.
	int paramcount;
	
	// Buffers for temp values.
	int startpos;
	int endpos;
	bool quoteon;
	char value[PARAM_VALUE_MAXLEN];
	
	// Loop through all characters in the string. Exclude null terminator.
	for (int strpos = 0; strpos < rawlen - 1; strpos++)
	{
		// Check if there's space left in the destination buffer.
		if (paramcount > maxlen)
		{
			// Exit loop. No more parameters can be parsed.
			err = PARAM_ERROR_FULL;
			errPos = strpos;
			break;
		}
		
		
		/*
		 *  MODE CHECK
		 */
		
		// Check mode for deciding what to do.
		switch (mode)
		{
			case ParamMode_TypeCheck:
			{
				// Find start position of first non white space character.
				startpos = ParamFindStartPos(paramString, strpos);
				
				// Check if it's a flag type.
				if (paramString[startpos] == '-')
				{
					// It's a flag, change mode.
					mode = ParamMode_Flag;
					
					// Update current position.
					strpos = startpos;
				}
				else
				{
					// Expect a key name.
					mode = ParamMode_Key;
					
					// Update current position. Substract by one to include
					// the current character in next mode.
					strpos = startpos - 1;
				}
			}
			case ParamMode_Flag:
			{
				// Find stop position (last non white space character).
				endpos = ParamFindEndPos(paramString, strpos);
				
				// Extract key name.
				StrExtract(value, sizeof(value), paramString, strpos, endpos);
				
				// Copy flag to destination buffer.
				strcopy(buffer[paramcount][Param_Name], PARAM_NAME_MAXLEN, value);
				
				// Set flag type.
				buffer[paramcount][Param_IsFlag] = true;
				
				// Increment parameter counter.
				paramcount++;
				
				// Set next parse mode.
				mode = ParamMode_TypeCheck;
			}
			case ParamMode_Key:
			{
				// Find stop position.
				endpos = ParamFindEndPos(paramString, strpos);
				
				// Extract key name.
				StrExtract(value, sizeof(value), paramString, strpos, endpos);
				
				// Copy key name to destination buffer.
				strcopy(buffer[paramcount][Param_Name], PARAM_NAME_MAXLEN, value);
				
				// Make sure flag type is not set.
				buffer[paramcount][Param_IsFlag] = false;
				
				// Note: Do not increment parameter counter until the
				//	   entire key/value pair is parsed.
				
				// Set next parse mode. Expect a equation sign.
				mode = ParamMode_Equal;
			}
			case ParamMode_Equal:
			{
				// Find start position of first non white space character.
				startpos = ParamFindStartPos(paramString, strpos);
				
				// Validate position.
				if (startpos >= 0)
				{
					// Check if it's a equation sign.
					if (paramString[startpos] == '=')
					{
						// Change mode to expect a value at next position.
						mode = ParamMode_Value;
						
						// Update current position.
						strpos = startpos;
					}
					else
					{
						// Parse error.
						err = PARAM_ERROR_UNEXPECTED_KEY;
						errPos = startpos;
						break;
					}
				}
				else
				{
					// Parse error.
					err = PARAM_ERROR_UNEXPECTED_END;
					errPos = strpos;
					break;
				}
			}
			case ParamMode_Value:
			{
				// Find start position of first non white space character.
				startpos = ParamFindStartPos(paramString, strpos);
				
				// Validate start position.
				if (startpos >= 0)
				{
					// Reset quote and escape settings.
					quoteon = false;
					
					// Loop through all characters starting from the current
					// position. Exclude null terminator.
					for (strpos = startpos; strpos < rawlen - 1; strpos++)
					{
						// Check if the current character is a special character.
						if (paramString[startpos] == '"')
						{
							// Toggle quote if the current quote is not escaped.
							if (paramString[startpos - 1] != '\\')
							{
								quoteon = !quoteon;
							}
							
							// Check quote state.
							if (quoteon)
							{
								// Quote started, update start position.
								startpos = strpos + 1;
							}
							else
							{
								// Quote end, set end position.
								endpos = strpos - 1;
							}
						}
						
						// Check if it's a white space character or end of the string.
						else if (!quoteon && (IsCharSpace(paramString[strpos]) || strpos == rawlen - 1))
						{
							// End of value reached. Save positions.
							endpos = strpos - 1;
							
							// Exit loop.
							break;
						}
					}
					
					// Check if quote still haven't ended.
					if (quoteon)
					{
						// Parse error.
						err = PARAM_ERROR_MISSING_QUOTE;
						errPos = strpos;
						break;
					}
					
					// Extract value string.
					StrExtract(value, sizeof(value), paramString, startpos, endpos);
					
					// Unescape string (converting "\n" to newline, etc.).
					StrUnescape(value);
					
					// Copy value string to destination buffer.
					strcopy(buffer[paramcount][Param_Value], PARAM_VALUE_MAXLEN, value);
					
					// Make sure flag type is not set.
					buffer[paramcount][Param_IsFlag] = false;
					
					// Increment parameter counter.
					paramcount++;
					
					// Set next parse mode. Expect a key or a flag.
					mode = ParamMode_TypeCheck;
				}
				else
				{
					// Parse error.
					err = PARAM_ERROR_UNEXPECTED_END;
					errPos = strpos;
					break;
				}
			}
		}
	}
	
	// Return number of parameters parsed.
	return paramcount;
}

/**
 * Finds the first key index in a parameter array matching the specified key.
 *
 * @param params			A ParamParseResult array to search through.
 * @param maxlen			Size of parameter array (first dimension).
 * @param key			   Key to find.
 * @param caseSensitive	 Specifies whether the search is case sensitive or
 *						  not (default).
 * @return				  Index of the key if found, -1 otherwise.
 */
stock int ParamFindKey(const params[][ParamParseResult], int maxlen, const char[] key, bool caseSensitive = false)
{
	// Loop through all parameters.
	for (int index = 0; index < maxlen; index++)
	{
		// Check parameter type.
		if (params[index][Param_IsFlag])
		{
			// It's a flag type, skip index.
			continue;
		}
		
		// Match key name.
		if (StrEqual(params[index][Param_Name], key, caseSensitive))
		{
			// Key found, return the key index.
			return index;
		}
	}
	
	return -1;
}

/**
 * Checks if the specified flag is set in a parameter array.
 *
 * @param params			A ParamParseResult array to search through.
 * @param maxlen			Size of parameter array (first dimension).
 * @param flag			  Flag to check.
 * @param caseSensitive	 Specifies whether the search is case sensitive or
 *						  not (default).
 * @return				  True flag is found, false otherwise.
 */
stock bool ParamHasFlag(const params[][ParamParseResult], int maxlen, const char[] flag, bool caseSensitive = false)
{
	// Loop through all parameters.
	for (int index = 0; index < maxlen; index++)
	{
		// Check parameter type.
		if (!params[index][Param_IsFlag])
		{
			// It's a key type, skip index.
			continue;
		}
		
		// Match flag name.
		if (StrEqual(params[index][Param_Name], flag, caseSensitive))
		{
			// Flag found.
			return true;
		}
	}
	
	return false;
}



/**************************************
 *									*
 *		 HELPER FUNCTIONS		   *
 *									*
 **************************************/

/**
 * Finds the position of the last non white space character from a specified start position.
 *
 * @param paramString   Raw string search in.
 * @param startPos	  Optional. Position to start searching from.
 * @return			  Position of the last non white space character, or -1
 *					  if failed.
 */
stock int ParamFindEndPos(const char[] paramString, int startPos = 0)
{
	int rawlen = sizeof(paramString);
	
	// Validate string length.
	if (rawlen == 0)
	{
		return -1;
	}
	
	// Loop through all characters from the specified start position.
	for (int strpos = startPos; strpos < rawlen; strpos++)
	{
		// Check if white space or if current position is the last
		// character before the null terminator.
		if (IsCharSpace(paramString[strpos]) || strpos == rawlen - 1)
		{
			return strpos - 1;
		}
	}
	
	// It should never reach this place. Added to satisfy compiler.
	return -1;
}

/**
 * Finds the first non white space character in a string, starting from the
 * specified position.
 *
 * @param paramString   Raw string to search in.
 * @param startPos	  Optional. Position to start searching from.
 * @return			  Position of first character or -1 if failed.
 */
stock int ParamFindStartPos(const char[] paramString, int startPos = 0)
{
	int rawlen = sizeof(paramString);
	
	// Validate string length.
	if (rawlen == 0)
	{
		return -1;
	}
	
	// Loop through all characters from the specified start position.
	for (int strpos = startPos; strpos < rawlen; strpos++)
	{
		// Check if not white space.
		if (!IsCharSpace(paramString[strpos]))
		{
			return strpos;
		}
	}
	
	// No character found.
	return -1;
}

/**
 * Extracts a area in a string between two positions.
 *
 * @param buffer	Destination string buffer.
 * @param maxlen	Size of destination buffer.
 * @param source	Source string to extract from.
 * @param startpos  Start position of string to extract.
 * @param endpos	End position of string to extract.
 * @return		  Number of cells written.
 */
stock int StrExtract(char[] buffer, int maxlen, const char[] source, int startpos, int endpos)
{
	int len;
	
	// Calculate string length. Also add space for null terminator.
	len = endpos - startpos + 1;
	
	// Validate length.
	if (len < 0)
	{
		return 0;
	}
	
	// Extract string and store it in the buffer.
	return strcopy(buffer, len, source[startpos]);
}

/**
 * Unescapes a string (replaces "\n" with newlines, etc.).
 *
 * @param str   String to unescape.
 */
stock void StrUnescape(char[] str)
{
	int len = sizeof(str);
	
	ReplaceString(str, len, "\\n", "\n");
	ReplaceString(str, len, "\\r", "\r");
	ReplaceString(str, len, "\\t", "\t");
	ReplaceString(str, len, "\\\"", "\"");
	ReplaceString(str, len, "\\\\", "\\");
}
