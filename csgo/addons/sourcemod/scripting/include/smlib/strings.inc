#if defined _smlib_strings_included
	#endinput
#endif
#define _smlib_strings_included

#include <sourcemod>
#include <smlib/math>

/**
 * Checks if the string is numeric.
 * This correctly handles + - . in the String.
 *
 * @param str				String to check.
 * @return					True if the String is numeric, false otherwise..
 */
stock bool:String_IsNumeric(const String:str[])
{	
	new x=0;
	new dotsFound=0;
	new numbersFound=0;

	if (str[x] == '+' || str[x] == '-') {
		x++;
	}

	while (str[x] != '\0') {

		if (IsCharNumeric(str[x])) {
			numbersFound++;
		}
		else if (str[x] == '.') {
			dotsFound++;
			
			if (dotsFound > 1) {
				return false;
			}
		}
		else {
			return false;
		}
		
		x++;
	}
	
	if (!numbersFound) {
		return false;
	}
	
	return true;
}

/**
 * Trims a string by removing the specified chars from beginning and ending.
 * Removes all ' ', '\t', '\r', '\n' characters by default.
 * The Output String can be the same as the Input String.
 *
 * @param str				Input String.
 * @param output			Output String (Can be the as the input).
 * @param size				Size of the output String.
 * @param chars				Characters to remove.
 * @noreturn
 */
stock String_Trim(const String:str[], String:output[], size, const String:chrs[]=" \t\r\n")
{	
	new x=0;
	while (str[x] != '\0' && FindCharInString(chrs, str[x]) != -1) {
		x++;
	}
	
	x = strcopy(output, size, str[x]);
	x--;

	while (x >= 0 && FindCharInString(chrs, output[x]) != -1) {
		x--;
	}
	
	output[++x] = '\0';
}

/**
 * Removes a list of strings from a string.
 *
 * @param buffer			Input/Ourput buffer.
 * @param removeList		A list of strings which should be removed from buffer.
 * @param size				Number of Strings in the List.
 * @param caseSensitive		If true, comparison is case sensitive. If false (default), comparison is case insensitive.
 * @noreturn
 */
stock String_RemoveList(String:buffer[], String:removeList[][], size, bool:caseSensitive=false)
{	
	for (new i=0; i < size; i++) {
		ReplaceString(buffer, SIZE_OF_INT, removeList[i], "", caseSensitive);
	}
}

/**
 * Converts the whole String to lower case.
 * Only works with alphabetical characters (not ÖÄÜ) because Sourcemod suxx !
 * The Output String can be the same as the Input String.
 *
 * @param input				Input String.
 * @param output			Output String.
 * @param size				Max Size of the Output string
 * @noreturn
 */
stock String_ToLower(const String:input[], String:output[], size)
{
	size--;

	new x=0;
	while (input[x] != '\0' && x < size) {
		
		output[x] = CharToLower(input[x]);
		
		x++;
	}

	output[x] = '\0';
}

/**
 * Converts the whole String to upper case.
 * Only works with alphabetical characters (not öäü) because Sourcemod suxx !
 * The Output String can be the same as the Input String.
 *
 * @param input				Input String.
 * @param output			Output String.
 * @param size				Max Size of the Output string
 * @noreturn
 */
stock String_ToUpper(const String:input[], String:output[], size)
{
	size--;

	new x=0;
	while (input[x] != '\0' && x < size) {
		
		output[x] = CharToUpper(input[x]);
		
		x++;
	}

	output[x] = '\0';
}

/**
 * Generates a random string.
 * 
 *
 * @param buffer			String Buffer.
 * @param size				String Buffer size (must be length+1)
 * @param length			Number of characters being generated.
 * @param chrs				String for specifying the characters used for random character generation.
 * 							By default it will use all letters of the alphabet (upper and lower) and all numbers.
 * 							If you pass an empty String, it will use all readable ASCII characters (33 - 126)
 * @noreturn
 */
stock String_GetRandom(String:buffer[], size, length=32, const String:chrs[]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234556789")
{
	new random, len;
	size--;
	
	if (chrs[0] != '\0') {
		len = strlen(chrs) - 1;
	}

	new n = 0;
	while (n < length && n < size) {

		if (chrs[0] == '\0') {
			random = Math_GetRandomInt(33, 126);
			buffer[n] = random;
		}
		else {
			random = Math_GetRandomInt(0, len);
			buffer[n] = chrs[random];
		}
		
		n++;
	}

	buffer[length] = '\0';
}

/**
 * Checks if string str starts with subString.
 * 
 *
 * @param str				String to check
 * @param subString			Sub-String to check in str
 * @return					True if str starts with subString, false otherwise.
 */
stock bool:String_StartsWith(const String:str[], const String:subString[])
{
	new n = 0;
	while (str[n] != '\0' && subString[n] != '\0') {

		if (str[n] != subString[n]) {
			return false;
		}

		n++;
	}

	return true;
}

/**
 * Checks if string str ends with subString.
 * 
 *
 * @param str				String to check
 * @param subString			Sub-String to check in str
 * @return					True if str ends with subString, false otherwise.
 */
stock bool:String_EndsWith(const String:str[], const String:subString[])
{
	new n_str = strlen(str) - 1;
	new n_subString = strlen(subString) - 1;

	while (n_str != 0 && n_subString != 0) {

		if (str[n_str--] != subString[n_subString--]) {
			return false;
		}
	}

	return true;
}
