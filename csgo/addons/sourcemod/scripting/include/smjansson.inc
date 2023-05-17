#if defined _jansson_included_
	#endinput
#endif
#define _jansson_included_


/**
 * --- Type
 *
 * The JSON specification (RFC 4627) defines the following data types:
 * object, array, string, number, boolean, and null.
 * JSON types are used dynamically; arrays and objects can hold any
 * other data type, including themselves. For this reason, Jansson�s
 * type system is also dynamic in nature. There�s one Handle type to
 * represent all JSON values, and the referenced structure knows the
 * type of the JSON value it holds.
 *
 */
enum json_type {
	JSON_OBJECT,
	JSON_ARRAY,
	JSON_STRING,
	JSON_INTEGER,
	JSON_REAL,
	JSON_TRUE,
	JSON_FALSE,
	JSON_NULL
}

/**
 * Return the type of the JSON value.
 *
 * @param hObj              Handle to the JSON value
 *
 * @return                  json_type of the value.
 */
native json_type:json_typeof(Handle:hObj);

/**
 * The type of a JSON value is queried and tested using these macros
 *
 * @param %1                Handle to the JSON value
 *
 * @return                  True if the value has the correct type.
 */
#define json_is_object(%1)			( json_typeof(%1) == JSON_OBJECT )
#define json_is_array(%1)			( json_typeof(%1) == JSON_ARRAY )
#define json_is_string(%1)			( json_typeof(%1) == JSON_STRING )
#define json_is_integer(%1)			( json_typeof(%1) == JSON_INTEGER )
#define json_is_real(%1)			( json_typeof(%1) == JSON_REAL )
#define json_is_true(%1)			( json_typeof(%1) == JSON_TRUE )
#define json_is_false(%1)			( json_typeof(%1) == JSON_FALSE )
#define json_is_null(%1)			( json_typeof(%1) == JSON_NULL )
#define json_is_number(%1)			( json_typeof(%1) == JSON_INTEGER || json_typeof(%1) == JSON_REAL )
#define json_is_boolean(%1)			( json_typeof(%1) == JSON_TRUE || json_typeof(%1) == JSON_FALSE )

/**
 * Saves json_type as a String in out
 *
 * @param input                json_type value to convert to string
 * @param out               Buffer to store the json_type value
 * @param maxlength         Maximum length of string buffer.
 *
 * @return                  False if the type does not exist.
 */
stock bool:Stringify_json_type(json_type:input, String:out[], maxlength) {
	switch(input) {
		case JSON_OBJECT:		strcopy(out, maxlength, "Object");
		case JSON_ARRAY:		strcopy(out, maxlength, "Array");
		case JSON_STRING:		strcopy(out, maxlength, "String");
		case JSON_INTEGER:		strcopy(out, maxlength, "Integer");
		case JSON_REAL:			strcopy(out, maxlength, "Real");
		case JSON_TRUE:			strcopy(out, maxlength, "True");
		case JSON_FALSE:		strcopy(out, maxlength, "False");
		case JSON_NULL:			strcopy(out, maxlength, "Null");
		default: return false;
	}

	return true;
}



/**
 * --- Equality
 *
 * - Two integer or real values are equal if their contained numeric
 *   values are equal. An integer value is never equal to a real value,
 *   though.
 * - Two strings are equal if their contained UTF-8 strings are equal,
 *   byte by byte. Unicode comparison algorithms are not implemented.
 * - Two arrays are equal if they have the same number of elements and
 *   each element in the first array is equal to the corresponding
 *   element in the second array.
 * - Two objects are equal if they have exactly the same keys and the
 *   value for each key in the first object is equal to the value of
 *   the corresponding key in the second object.
 * - Two true, false or null values have no "contents", so they are
 *   equal if their types are equal.
 *
 */

/**
 * Test whether two JSON values are equal.
 *
 * @param hObj              Handle to the first JSON object
 * @param hOther            Handle to the second JSON object
 *
 * @return                  Returns false if they are inequal or one
 *                          or both of the pointers are NULL.
 */
native bool:json_equal(Handle:hObj, Handle:hOther);




/**
 * --- Copying
 *
 * Jansson supports two kinds of copying: shallow and deep. There is
 * a difference between these methods only for arrays and objects.
 *
 * Shallow copying only copies the first level value (array or object)
 * and uses the same child values in the copied value.
 *
 * Deep copying makes a fresh copy of the child values, too. Moreover,
 * all the child values are deep copied in a recursive fashion.
 *
 */

/**
 * Get a shallow copy of the passed object
 *
 * @param hObj              Handle to JSON object to be copied
 *
 * @return                  Returns a shallow copy of the object,
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_copy(Handle:hObj);

/**
 * Get a deep copy of the passed object
 *
 * @param hObj              Handle to JSON object to be copied
 *
 * @return                  Returns a deep copy of the object,
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_deep_copy(Handle:hObj);




/**
 * --- Objects
 *
 * A JSON object is a dictionary of key-value pairs, where the
 * key is a Unicode string and the value is any JSON value.
 *
 */

/**
 * Returns a handle to a new JSON object, or INVALID_HANDLE on error.
 * Initially, the object is empty.
 *
 * @return                  Handle to a new JSON object.
 */
native Handle:json_object();

/**
 * Returns the number of elements in hObj
 *
 * @param hObj              Handle to JSON object
 *
 * @return                  Number of elements in hObj,
 *                          or 0 if hObj is not a JSON object.
 */
native json_object_size(Handle:hObj);

/**
 * Get a value corresponding to sKey from hObj
 *
 * @param hObj              Handle to JSON object to get a value from
 * @param sKey              Key to retrieve
 *
 * @return                  Handle to a the JSON object or
 *                          INVALID_HANDLE on error.
 */
native Handle:json_object_get(Handle:hObj, const String:sKey[]);

/**
 * Set the value of sKey to hValue in hObj.
 * If there already is a value for key, it is replaced by the new value.
 *
 * @param hObj              Handle to JSON object to set a value on
 * @param sKey              Key to store in the object
 *                          Must be a valid null terminated UTF-8 encoded
 *                          Unicode string.
 * @param hValue            Value to store in the object
 *
 * @return					True on success.
 */
native bool:json_object_set(Handle:hObj, const String:sKey[], Handle:hValue);

/**
 * Set the value of sKey to hValue in hObj.
 * If there already is a value for key, it is replaced by the new value.
 * This function automatically closes the Handle to the value object.
 *
 * @param hObj              Handle to JSON object to set a value on
 * @param sKey              Key to store in the object
 *                          Must be a valid null terminated UTF-8 encoded
 *                          Unicode string.
 * @param hValue            Value to store in the object
 *
 * @return					True on success.
 */
native bool:json_object_set_new(Handle:hObj, const String:sKey[], Handle:hValue);

/**
 * Delete sKey from hObj if it exists.
 *
 * @param hObj              Handle to JSON object to delete a key from
 * @param sKey              Key to delete
 *
 * @return                  True on success.
 */
native bool:json_object_del(Handle:hObj, const String:sKey[]);

/**
 * Remove all elements from hObj.
 *
 * @param hObj              Handle to JSON object to remove all
 *                          elements from.
 *
 * @return                  True on success.
 */
native bool:json_object_clear(Handle:hObj);

/**
 * Update hObj with the key-value pairs from hOther, overwriting
 * existing keys.
 *
 * @param hObj              Handle to JSON object to update
 * @param hOther            Handle to JSON object to get update
 *                          keys/values from.
 *
 * @return                  True on success.
 */
native bool:json_object_update(Handle:hObj, Handle:hOther);

/**
 * Like json_object_update(), but only the values of existing keys
 * are updated. No new keys are created.
 *
 * @param hObj              Handle to JSON object to update
 * @param hOther            Handle to JSON object to get update
 *                          keys/values from.
 *
 * @return                  True on success.
 */
native bool:json_object_update_existing(Handle:hObj, Handle:hOther);

/**
 * Like json_object_update(), but only new keys are created.
 * The value of any existing key is not changed.
 *
 * @param hObj              Handle to JSON object to update
 * @param hOther            Handle to JSON object to get update
 *                          keys/values from.
 *
 * @return                  True on success.
 */
native bool:json_object_update_missing(Handle:hObj, Handle:hOther);




/**
 * Object iteration
 *
 * Example code:
 *  - We assume hObj is a Handle to a valid JSON object.
 *
 *
 * new Handle:hIterator = json_object_iter(hObj);
 * while(hIterator != INVALID_HANDLE)
 * {
 *     	new String:sKey[128];
 *      json_object_iter_key(hIterator, sKey, sizeof(sKey));
 *
 *      new Handle:hValue = json_object_iter_value(hIterator);
 *
 *      // Do something with sKey and hValue
 *
 *      CloseHandle(hValue);
 *
 *      hIterator = json_object_iter_next(hObj, hIterator);
 * }
 *
 */

/**
 * Returns a handle to an iterator which can be used to iterate over
 * all key-value pairs in hObj.
 * If you are not iterating to the end of hObj make sure to close the
 * handle to the iterator manually.
 *
 * @param hObj              Handle to JSON object to get an iterator
 *                          for.
 *
 * @return                  Handle to JSON object iterator,
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_object_iter(Handle:hObj);

/**
 * Like json_object_iter(), but returns an iterator to the key-value
 * pair in object whose key is equal to key.
 * Iterating forward to the end of object only yields all key-value
 * pairs of the object if key happens to be the first key in the
 * underlying hash table.
 *
 * @param hObj              Handle to JSON object to get an iterator
 *                          for.
 * @param sKey              Start key for the iterator
 *
 * @return                  Handle to JSON object iterator,
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_object_iter_at(Handle:hObj, const String:key[]);

/**
 * Returns an iterator pointing to the next key-value pair in object.
 * This automatically closes the Handle to the iterator hIter.
 *
 * @param hObj              Handle to JSON object.
 * @param hIter             Handle to JSON object iterator.
 *
 * @return                  Handle to JSON object iterator,
 *                          or INVALID_HANDLE on error, or if the
 *                          whole object has been iterated through.
 */
native Handle:json_object_iter_next(Handle:hObj, Handle:hIter);

/**
 * Extracts the associated key of hIter as a null terminated UTF-8
 * encoded string in the passed buffer.
 *
 * @param hIter             Handle to the JSON String object
 * @param sKeyBuffer        Buffer to store the value of the String.
 * @param maxlength         Maximum length of string buffer.
 * @error                   Invalid JSON Object Iterator.
 * @return                  Length of the returned string or -1 on error.
 */
native json_object_iter_key(Handle:hIter, String:sKeyBuffer[], maxlength);

/**
 * Returns a handle to the value hIter is pointing at.
 *
 * @param hIter             Handle to JSON object iterator.
 *
 * @return                  Handle to value or INVALID_HANDLE on error.
 */
native Handle:json_object_iter_value(Handle:hIter);

/**
 * Set the value of the key-value pair in hObj, that is pointed to
 * by hIter, to hValue.
 *
 * @param hObj              Handle to JSON object.
 * @param hIter             Handle to JSON object iterator.
 * @param hValue            Handle to JSON value.
 *
 * @return                  True on success.
 */
native bool:json_object_iter_set(Handle:hObj, Handle:hIter, Handle:hValue);

/**
 * Set the value of the key-value pair in hObj, that is pointed to
 * by hIter, to hValue.
 * This function automatically closes the Handle to the value object.
 *
 * @param hObj              Handle to JSON object.
 * @param hIter             Handle to JSON object iterator.
 * @param hValue            Handle to JSON value.
 *
 * @return                  True on success.
 */
native bool:json_object_iter_set_new(Handle:hObj, Handle:hIter, Handle:hValue);




/**
 * Arrays
 *
 * A JSON array is an ordered collection of other JSON values.
 *
 */

/**
 * Returns a handle to a new JSON array, or INVALID_HANDLE on error.
 *
 * @return                  Handle to the new JSON array
 */
native Handle:json_array();

/**
 * Returns the number of elements in hArray
 *
 * @param hObj              Handle to JSON array
 *
 * @return                  Number of elements in hArray,
 *                          or 0 if hObj is not a JSON array.
 */
native json_array_size(Handle:hArray);

/**
 * Returns the element in hArray at position iIndex.
 *
 * @param hArray            Handle to JSON array to get a value from
 * @param iIndex            Position to retrieve
 *
 * @return                  Handle to a the JSON object or
 *                          INVALID_HANDLE on error.
 */
native Handle:json_array_get(Handle:hArray, iIndex);

/**
 * Replaces the element in array at position iIndex with hValue.
 * The valid range for iIndex is from 0 to the return value of
 * json_array_size() minus 1.
 *
 * @param hArray            Handle to JSON array
 * @param iIndex            Position to replace
 * @param hValue            Value to store in the array
 *
 * @return					True on success.
 */
native bool:json_array_set(Handle:hArray, iIndex, Handle:hValue);

/**
 * Replaces the element in array at position iIndex with hValue.
 * The valid range for iIndex is from 0 to the return value of
 * json_array_size() minus 1.
 * This function automatically closes the Handle to the value object.
 *
 * @param hArray            Handle to JSON array
 * @param iIndex            Position to replace
 * @param hValue            Value to store in the array
 *
 * @return					True on success.
 */
native bool:json_array_set_new(Handle:hArray, iIndex, Handle:hValue);

/**
 * Appends value to the end of array, growing the size of array by 1.
 *
 * @param hArray            Handle to JSON array
 * @param hValue            Value to append to the array
 *
 * @return					True on success.
 */
native bool:json_array_append(Handle:hArray, Handle:hValue);

/**
 * Appends value to the end of array, growing the size of array by 1.
 * This function automatically closes the Handle to the value object.
 *
 * @param hArray            Handle to JSON array
 * @param hValue            Value to append to the array
 *
 * @return					True on success.
 */
native bool:json_array_append_new(Handle:hArray, Handle:hValue);

/**
 * Inserts value to hArray at position iIndex, shifting the elements at
 * iIndex and after it one position towards the end of the array.
 *
 * @param hArray            Handle to JSON array
 * @param iIndex            Position to insert at
 * @param hValue            Value to store in the array
 *
 * @return					True on success.
 */
native bool:json_array_insert(Handle:hArray, iIndex, Handle:hValue);

/**
 * Inserts value to hArray at position iIndex, shifting the elements at
 * iIndex and after it one position towards the end of the array.
 * This function automatically closes the Handle to the value object.
 *
 * @param hArray            Handle to JSON array
 * @param iIndex            Position to insert at
 * @param hValue            Value to store in the array
 *
 * @return					True on success.
 */
native bool:json_array_insert_new(Handle:hArray, iIndex, Handle:hValue);

/**
 * Removes the element in hArray at position iIndex, shifting the
 * elements after iIndex one position towards the start of the array.
 *
 * @param hArray            Handle to JSON array
 * @param iIndex            Position to insert at
 *
 * @return					True on success.
 */
native bool:json_array_remove(Handle:hArray, iIndex);

/**
 * Removes all elements from hArray.
 *
 * @param hArray            Handle to JSON array
 *
 * @return					True on success.
 */
native bool:json_array_clear(Handle:hArray);

/**
 * Appends all elements in hOther to the end of hArray.
 *
 * @param hArray            Handle to JSON array to be extended
 * @param hOther            Handle to JSON array, source to copy from
 *
 * @return					True on success.
 */
native bool:json_array_extend(Handle:hArray, Handle:hOther);




/**
 * Booleans & NULL
 *
 */

/**
 * Returns a handle to a new JSON Boolean with value true,
 * or INVALID_HANDLE on error.
 *
 * @return                  Handle to the new Boolean object
 */
native Handle:json_true();

/**
 * Returns a handle to a new JSON Boolean with value false,
 * or INVALID_HANDLE on error.
 *
 * @return                  Handle to the new Boolean object
 */
native Handle:json_false();

/**
 * Returns a handle to a new JSON Boolean with the value passed
 * in bState or INVALID_HANDLE on error.
 *
 * @param bState            Value for the new Boolean object
 * @return                  Handle to the new Boolean object
 */
native Handle:json_boolean(bool:bState);

/**
 * Returns a handle to a new JSON NULL or INVALID_HANDLE on error.
 *
 * @return                  Handle to the new NULL object
 */
native Handle:json_null();




/**
 * Strings
 *
 * Jansson uses UTF-8 as the character encoding. All JSON strings must
 * be valid UTF-8 (or ASCII, as it�s a subset of UTF-8). Normal null
 * terminated C strings are used, so JSON strings may not contain
 * embedded null characters.
 *
 */

/**
 * Returns a handle to a new JSON string, or INVALID_HANDLE on error.
 *
 * @param sValue            Value for the new String object
 *							Must be a valid UTF-8 encoded Unicode string.
 * @return                  Handle to the new String object
 */
native Handle:json_string(const String:sValue[]);

/**
 * Saves the associated value of hString as a null terminated UTF-8
 * encoded string in the passed buffer.
 *
 * @param hString           Handle to the JSON String object
 * @param sValueBuffer      Buffer to store the value of the String.
 * @param maxlength         Maximum length of string buffer.
 * @error                   Invalid JSON String Object.
 * @return                  Length of the returned string or -1 on error.
 */
native json_string_value(Handle:hString, String:sValueBuffer[], maxlength);

/**
 * Sets the associated value of JSON String object to value.
 *
 * @param hString           Handle to the JSON String object
 * @param sValue            Value to set the object to.
 *                          Must be a valid UTF-8 encoded Unicode string.
 * @error                   Invalid JSON String Object.
 * @return                  True on success.
 */
native bool:json_string_set(Handle:hString, String:sValue[]);




/**
 * Numbers
 *
 * The JSON specification only contains one numeric type, 'number'.
 * The C (and Pawn) programming language has distinct types for integer
 * and floating-point numbers, so for practical reasons Jansson also has
 * distinct types for the two. They are called 'integer' and 'real',
 * respectively. (Whereas 'real' is a 'Float' for Pawn).
 * Therefore a number is represented by either a value of the type
 * JSON_INTEGER or of the type JSON_REAL.
 *
 */

/**
 * Returns a handle to a new JSON integer, or INVALID_HANDLE on error.
 *
 * @param iValue            Value for the new Integer object
 * @return                  Handle to the new Integer object
 */
native Handle:json_integer(iValue);

/**
 * Returns the associated value of a JSON Integer Object.
 *
 * @param hInteger          Handle to the JSON Integer object
 * @error                   Invalid JSON Integer Object.
 * @return                  Value of the hInteger,
 *                          or 0 if hInteger is not a JSON integer.
 */
native json_integer_value(Handle:hInteger);

/**
 * Sets the associated value of JSON Integer to value.
 *
 * @param hInteger          Handle to the JSON Integer object
 * @param iValue            Value to set the object to.
 * @error                   Invalid JSON Integer Object.
 * @return                  True on success.
 */
native bool:json_integer_set(Handle:hInteger, iValue);

/**
 * Returns a handle to a new JSON real, or INVALID_HANDLE on error.
 *
 * @param fValue            Value for the new Real object
 * @return                  Handle to the new String object
 */
native Handle:json_real(Float:fValue);

/**
 * Returns the associated value of a JSON Real.
 *
 * @param hReal             Handle to the JSON Real object
 * @error                   Invalid JSON Real Object.
 * @return                  Float value of hReal,
 *                          or 0.0 if hReal is not a JSON Real.
 */
native Float:json_real_value(Handle:hReal);

/**
 * Sets the associated value of JSON Real to fValue.
 *
 * @param hReal             Handle to the JSON Integer object
 * @param fValue            Value to set the object to.
 * @error                   Invalid JSON Real handle.
 * @return                  True on success.
 */
native bool:json_real_set(Handle:hReal, Float:value);

/**
 * Returns the associated value of a JSON integer or a
 * JSON Real, cast to Float regardless of the actual type.
 *
 * @param hNumber           Handle to the JSON Number
 * @error                   Not a JSON Real or JSON Integer
 * @return                  Float value of hNumber,
 *                          or 0.0 on error.
 */
native Float:json_number_value(Handle:hNumber);




/**
 * Decoding
 *
 * This sections describes the functions that can be used to decode JSON text
 * to the Jansson representation of JSON data. The JSON specification requires
 * that a JSON text is either a serialized array or object, and this
 * requirement is also enforced with the following functions. In other words,
 * the top level value in the JSON text being decoded must be either array or
 * object.
 *
 */

/**
 * Decodes the JSON string sJSON and returns the array or object it contains.
 * Errors while decoding can be found in the sourcemod error log.
 *
 * @param sJSON             String containing valid JSON

 * @return                  Handle to JSON object or array.
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_load(const String:sJSON[]);

/**
 * Decodes the JSON string sJSON and returns the array or object it contains.
 * This function provides additional error feedback and does not log errors
 * to the sourcemod error log.
 *
 * @param sJSON             String containing valid JSON
 * @param sErrorText        This buffer will be filled with the error
 *                          message.
 * @param maxlen            Size of the buffer
 * @param iLine             This int will contain the line of the error
 * @param iColumn           This int will contain the column of the error
 *
 * @return                  Handle to JSON object or array.
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_load_ex(const String:sJSON[], String:sErrorText[], maxlen, &iLine, &iColumn);

/**
 * Decodes the JSON text in file sFilePath and returns the array or object
 * it contains.
 * Errors while decoding can be found in the sourcemod error log.
 *
 * @param sFilePath         Path to a file containing pure JSON
 *
 * @return                  Handle to JSON object or array.
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_load_file(const String:sFilePath[PLATFORM_MAX_PATH]);

/**
 * Decodes the JSON text in file sFilePath and returns the array or object
 * it contains.
 * This function provides additional error feedback and does not log errors
 * to the sourcemod error log.
 *
 * @param sFilePath         Path to a file containing pure JSON
 * @param sErrorText        This buffer will be filled with the error
 *                          message.
 * @param maxlen            Size of the buffer
 * @param iLine             This int will contain the line of the error
 * @param iColumn           This int will contain the column of the error
 *
 * @return                  Handle to JSON object or array.
 *                          or INVALID_HANDLE on error.
 */
native Handle:json_load_file_ex(const String:sFilePath[PLATFORM_MAX_PATH], String:sErrorText[], maxlen, &iLine, &iColumn);



/**
 * Encoding
 *
 * This sections describes the functions that can be used to encode values
 * to JSON. By default, only objects and arrays can be encoded directly,
 * since they are the only valid root values of a JSON text.
 *
 */

/**
 * Saves the JSON representation of hObject in sJSON.
 *
 * @param hObject           String containing valid JSON
 * @param sJSON             Buffer to store the created JSON string.
 * @param maxlength         Maximum length of string buffer.
 * @param iIndentWidth      Indenting with iIndentWidth spaces.
 *                          The valid range for this is between 0 and 31 (inclusive),
 *                          other values result in an undefined output. If this is set
 *                          to 0, no newlines are inserted between array and object items.
 * @param bEnsureAscii      If this is set, the output is guaranteed
 *                          to consist only of ASCII characters. This is achieved
 *                          by escaping all Unicode characters outside the ASCII range.
 * @param bSortKeys         If this flag is used, all the objects in output are sorted
 *                          by key. This is useful e.g. if two JSON texts are diffed
 *                          or visually compared.
 * @param bPreserveOrder    If this flag is used, object keys in the output are sorted
 *                          into the same order in which they were first inserted to
 *                          the object. For example, decoding a JSON text and then
 *                          encoding with this flag preserves the order of object keys.
 * @return                  Length of the returned string or -1 on error.
 */
native json_dump(Handle:hObject, String:sJSON[], maxlength, iIndentWidth = 4, bool:bEnsureAscii = false, bool:bSortKeys = false, bool:bPreserveOrder = false);

/**
 * Write the JSON representation of hObject to the file sFilePath.
 * If sFilePath already exists, it is overwritten.
 *
 * @param hObject           String containing valid JSON
 * @param sFilePath         Buffer to store the created JSON string.
 * @param iIndentWidth      Indenting with iIndentWidth spaces.
 *                          The valid range for this is between 0 and 31 (inclusive),
 *                          other values result in an undefined output. If this is set
 *                          to 0, no newlines are inserted between array and object items.
 * @param bEnsureAscii      If this is set, the output is guaranteed
 *                          to consist only of ASCII characters. This is achieved
 *                          by escaping all Unicode characters outside the ASCII range.
 * @param bSortKeys         If this flag is used, all the objects in output are sorted
 *                          by key. This is useful e.g. if two JSON texts are diffed
 *                          or visually compared.
 * @param bPreserveOrder    If this flag is used, object keys in the output are sorted
 *                          into the same order in which they were first inserted to
 *                          the object. For example, decoding a JSON text and then
 *                          encoding with this flag preserves the order of object keys.
 * @return                  Length of the returned string or -1 on error.
 */
native bool:json_dump_file(Handle:hObject, const String:sFilePath[], iIndentWidth = 4, bool:bEnsureAscii = false, bool:bSortKeys = false, bool:bPreserveOrder = false);



/**
 * Convenience stocks
 *
 * These are some custom functions to ease the development using this
 * extension.
 *
 */

/**
 * Returns a handle to a new JSON string, or INVALID_HANDLE on error.
 * Formats the string according to the SourceMod format rules.
 * The result must be a valid UTF-8 encoded Unicode string.
 *
 * @param sFormat           Formatting rules.
 * @param ...			    Variable number of format parameters.
 * @return                  Handle to the new String object
 */
stock Handle:json_string_format(const String:sFormat[], any:...) {
	new String:sTmp[4096];
	VFormat(sTmp, sizeof(sTmp), sFormat, 2);

	return json_string(sTmp);
}

/**
 * Returns a handle to a new JSON string, or INVALID_HANDLE on error.
 * This stock allows to specify the size of the temporary buffer used
 * to create the string. Use this if the default of 4096 is not enough
 * for your string.
 * Formats the string according to the SourceMod format rules.
 * The result must be a valid UTF-8 encoded Unicode string.
 *
 * @param tmpBufferLength   Size of the temporary buffer
 * @param sFormat           Formatting rules.
 * @param ...			    Variable number of format parameters.
 * @return                  Handle to the new String object
 */
stock Handle:json_string_format_ex(tmpBufferLength, const String:sFormat[], any:...) {
	new String:sTmp[tmpBufferLength];
	VFormat(sTmp, sizeof(sTmp), sFormat, 3);

	return json_string(sTmp);
}


/**
 * Returns the boolean value of the element in hArray at position iIndex.
 *
 * @param hArray            Handle to JSON array to get a value from
 * @param iIndex            Position to retrieve
 *
 * @return                  True if it's a boolean and TRUE,
 *                          false otherwise.
 */
stock bool:json_array_get_bool(Handle:hArray, iIndex) {
	new Handle:hElement = json_array_get(hArray, iIndex);

	new bool:bResult = (json_is_true(hElement) ? true : false);

	CloseHandle(hElement);
	return bResult;
}

/**
 * Returns the float value of the element in hArray at position iIndex.
 *
 * @param hArray            Handle to JSON array to get a value from
 * @param iIndex            Position to retrieve
 *
 * @return                  Float value,
 *                          or 0.0 if element is not a JSON Real.
 */
stock Float:json_array_get_float(Handle:hArray, iIndex) {
	new Handle:hElement = json_array_get(hArray, iIndex);

	new Float:fResult = (json_is_number(hElement) ? json_number_value(hElement) : 0.0);

	CloseHandle(hElement);
	return fResult;
}

/**
 * Returns the integer value of the element in hArray at position iIndex.
 *
 * @param hArray            Handle to JSON array to get a value from
 * @param iIndex            Position to retrieve
 *
 * @return                  Integer value,
 *                          or 0 if element is not a JSON Integer.
 */
stock json_array_get_int(Handle:hArray, iIndex) {
	new Handle:hElement = json_array_get(hArray, iIndex);

	new iResult = (json_is_integer(hElement) ? json_integer_value(hElement) : 0);

	CloseHandle(hElement);
	return iResult;
}

/**
 * Saves the associated value of the element in hArray at position iIndex
 * as a null terminated UTF-8 encoded string in the passed buffer.
 *
 * @param hArray            Handle to JSON array to get a value from
 * @param iIndex            Position to retrieve
 * @param sBuffer           Buffer to store the value of the String.
 * @param maxlength         Maximum length of string buffer.
 *
 * @error                   Element is not a JSON String.
 * @return                  Length of the returned string or -1 on error.
 */
stock json_array_get_string(Handle:hArray, iIndex, String:sBuffer[], maxlength) {
	new Handle:hElement = json_array_get(hArray, iIndex);

	new iResult = -1;
	if(json_is_string(hElement)) {
		iResult = json_string_value(hElement, sBuffer, maxlength);
	}
	CloseHandle(hElement);

	return iResult;
}

/**
 * Returns the boolean value of the element in hObj at entry sKey.
 *
 * @param hObj              Handle to JSON object to get a value from
 * @param sKey              Entry to retrieve
 *
 * @return                  True if it's a boolean and TRUE,
 *                          false otherwise.
 */
stock bool:json_object_get_bool(Handle:hObj, const String:sKey[]) {
	new Handle:hElement = json_object_get(hObj, sKey);

	new bool:bResult = (json_is_true(hElement) ? true : false);

	CloseHandle(hElement);
	return bResult;
}

/**
 * Returns the float value of the element in hObj at entry sKey.
 *
 * @param hObj              Handle to JSON object to get a value from
 * @param sKey              Position to retrieve
 *
 * @return                  Float value,
 *                          or 0.0 if element is not a JSON Real.
 */
stock Float:json_object_get_float(Handle:hObj, const String:sKey[]) {
	new Handle:hElement = json_object_get(hObj, sKey);
	if (hElement == INVALID_HANDLE)
		return 0.0;
	new Float:fResult = (json_is_number(hElement) ? json_number_value(hElement) : 0.0);

	CloseHandle(hElement);
	return fResult;
}

/**
 * Returns the integer value of the element in hObj at entry sKey.
 *
 * @param hObj              Handle to JSON object to get a value from
 * @param sKey              Position to retrieve
 *
 * @return                  Integer value,
 *                          or 0 if element is not a JSON Integer.
 */
stock json_object_get_int(Handle:hObj, const String:sKey[]) {
	new Handle:hElement = json_object_get(hObj, sKey);
	if (hElement == INVALID_HANDLE)
		return 0;

	new iResult = (json_is_integer(hElement) ? json_integer_value(hElement) : 0);

	CloseHandle(hElement);
	return iResult;
}

/**
 * Saves the associated value of the element in hObj at entry sKey
 * as a null terminated UTF-8 encoded string in the passed buffer.
 *
 * @param hObj              Handle to JSON object to get a value from
 * @param sKey              Entry to retrieve
 * @param sBuffer           Buffer to store the value of the String.
 * @param maxlength         Maximum length of string buffer.
 *
 * @error                   Element is not a JSON String.
 * @return                  Length of the returned string or -1 on error.
 */
stock json_object_get_string(Handle:hObj, const String:sKey[], String:sBuffer[], maxlength) {
	new Handle:hElement = json_object_get(hObj, sKey);

	new iResult = -1;
	if(json_is_string(hElement)) {
		iResult = json_string_value(hElement, sBuffer, maxlength);
	}
	CloseHandle(hElement);

	return iResult;
}



/**
 * Pack String Rules
 *
 * Here�s the full list of format characters:
 *  n    Output a JSON null value. No argument is consumed.
 *  s    Output a JSON string, consuming one argument.
 *  b    Output a JSON bool value, consuming one argument.
 *  i    Output a JSON integer value, consuming one argument.
 *  f    Output a JSON real value, consuming one argument.
 *  r    Output a JSON real value, consuming one argument.
 *  []   Build an array with contents from the inner format string,
 *       recursive value building is supported.
 *       No argument is consumed.
 *  {}   Build an array with contents from the inner format string.
 *       The first, third, etc. format character represent a key,
 *       and must be s (as object keys are always strings). The
 *       second, fourth, etc. format character represent a value.
 *       Recursive value building is supported.
 *       No argument is consumed.
 *
 */

/**
 * This method can be used to create json objects/arrays directly
 * without having to create the structure.
 * See 'Pack String Rules' for more details.
 *
 * @param sPackString       Pack string similiar to Format()s fmt.
 *                          See 'Pack String Rules'.
 * @param hParams           ADT Array containing all keys and values
 *                          in the order they appear in the pack string.
 *
 * @error                   Invalid pack string or pack string and
 *                          ADT Array don't match up regarding type
 *                          or size.
 * @return                  Handle to JSON element.
 */
stock Handle:json_pack(const String:sPackString[], Handle:hParams) {
	new iPos = 0;
	return json_pack_element_(sPackString, iPos, hParams);
}





/**
* Internal stocks used by json_pack(). Don't use these directly!
*
*/
stock Handle:json_pack_array_(const String:sFormat[], &iPos, Handle:hParams) {
	new Handle:hObj = json_array();
	new iStrLen = strlen(sFormat);
	for(; iPos < iStrLen;) {
		new this_char = sFormat[iPos];

		if(this_char == 32 || this_char == 58 || this_char == 44) {
			// Skip whitespace, ',' and ':'
			iPos++;
			continue;
		}

		if(this_char == 93) {
			// array end
			iPos++;
			break;
		}

		// Get the next entry as value
		// This automatically increments the position!
		new Handle:hValue = json_pack_element_(sFormat, iPos, hParams);

		// Append the value to the array.
		json_array_append_new(hObj, hValue);
	}

	return hObj;
}

stock Handle:json_pack_object_(const String:sFormat[], &iPos, Handle:hParams) {
	new Handle:hObj = json_object();
	new iStrLen = strlen(sFormat);
	for(; iPos < iStrLen;) {
		new this_char = sFormat[iPos];

		if(this_char == 32 || this_char == 58 || this_char == 44) {
			// Skip whitespace, ',' and ':'
			iPos++;
			continue;
		}

		if(this_char == 125) {
			// } --> object end
			iPos++;
			break;
		}

		if(this_char != 115) {
			LogError("Object keys must be strings at %d.", iPos);
			return INVALID_HANDLE;
		}

		// Get the key string for this object from
		// the hParams array.
		decl String:sKey[255];
		GetArrayString(hParams, 0, sKey, sizeof(sKey));
		RemoveFromArray(hParams, 0);

		// Advance one character in the pack string,
		// because we've just read the Key string for
		// this object.
		iPos++;

		// Get the next entry as value
		// This automatically increments the position!
		new Handle:hValue = json_pack_element_(sFormat, iPos, hParams);

		// Insert into object
		json_object_set_new(hObj, sKey, hValue);
	}

	return hObj;
}

stock Handle:json_pack_element_(const String:sFormat[], &iPos, Handle:hParams) {
	new this_char = sFormat[iPos];
	while(this_char == 32 || this_char == 58 || this_char == 44) {
		iPos++;
		this_char = sFormat[iPos];
	}

	// Advance one character in the pack string
	iPos++;

	switch(this_char) {
		case 91: {
			// {  --> Array
			return json_pack_array_(sFormat, iPos, hParams);
		}

		case 123: {
			// {  --> Object
			return json_pack_object_(sFormat, iPos, hParams);

		}

		case 98: {
			// b  --> Boolean
			new iValue = GetArrayCell(hParams, 0);
			RemoveFromArray(hParams, 0);

			return json_boolean(bool:iValue);
		}

		case 102, 114: {
			// r,f  --> Real (Float)
			new Float:iValue = GetArrayCell(hParams, 0);
			RemoveFromArray(hParams, 0);

			return json_real(iValue);
		}

		case 110: {
			// n --> NULL
			return json_null();
		}

		case 115: {
			// s  --> String
			decl String:sKey[255];
			GetArrayString(hParams, 0, sKey, sizeof(sKey));
			RemoveFromArray(hParams, 0);

			return json_string(sKey);
		}

		case 105: {
			// i  --> Integer
			new iValue = GetArrayCell(hParams, 0);
			RemoveFromArray(hParams, 0);

			return json_integer(iValue);
		}
	}

	SetFailState("Invalid pack String '%s'. Type '%s' not supported at %i", sFormat, this_char, iPos);
	return json_null();
}





/**
 * Not yet implemented
 *
 * native json_object_foreach(Handle:hObj, ForEachCallback:cb);
 * native Handle:json_unpack(const String:sFormat[], ...);
 *
 */






/**
 * Do not edit below this line!
 */
public Extension:__ext_smjansson =
{
	name = "SMJansson",
	file = "smjansson.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_EXTENSIONS
public __ext_smjansson_SetNTVOptional()
{
	MarkNativeAsOptional("json_typeof");
	MarkNativeAsOptional("json_equal");

	MarkNativeAsOptional("json_copy");
	MarkNativeAsOptional("json_deep_copy");

	MarkNativeAsOptional("json_object");
	MarkNativeAsOptional("json_object_size");
	MarkNativeAsOptional("json_object_get");
	MarkNativeAsOptional("json_object_set");
	MarkNativeAsOptional("json_object_del");
	MarkNativeAsOptional("json_object_clear");
	MarkNativeAsOptional("json_object_update");
	MarkNativeAsOptional("json_object_update_existing");
	MarkNativeAsOptional("json_object_update_missing");

	MarkNativeAsOptional("json_object_iter");
	MarkNativeAsOptional("json_object_iter_at");
	MarkNativeAsOptional("json_object_iter_next");
	MarkNativeAsOptional("json_object_iter_key");
	MarkNativeAsOptional("json_object_iter_value");
	MarkNativeAsOptional("json_object_iter_set");

	MarkNativeAsOptional("json_array");
	MarkNativeAsOptional("json_array_size");
	MarkNativeAsOptional("json_array_get");
	MarkNativeAsOptional("json_array_set");
	MarkNativeAsOptional("json_array_append");
	MarkNativeAsOptional("json_array_insert");
	MarkNativeAsOptional("json_array_remove");
	MarkNativeAsOptional("json_array_clear");
	MarkNativeAsOptional("json_array_extend");

	MarkNativeAsOptional("json_string");
	MarkNativeAsOptional("json_string_value");
	MarkNativeAsOptional("json_string_set");

	MarkNativeAsOptional("json_integer");
	MarkNativeAsOptional("json_integer_value");
	MarkNativeAsOptional("json_integer_set");

	MarkNativeAsOptional("json_real");
	MarkNativeAsOptional("json_real_value");
	MarkNativeAsOptional("json_real_set");
	MarkNativeAsOptional("json_number_value");

	MarkNativeAsOptional("json_load");
	MarkNativeAsOptional("json_load_file");

	MarkNativeAsOptional("json_dump");
	MarkNativeAsOptional("json_dump_file");
}
#endif