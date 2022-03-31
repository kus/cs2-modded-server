/***
base64.inc - Base64 Encoding and Decoding Library Functions

Version: 1.0.1
Date: 2009-08-27
Author: SirLamer

Provides some basic Base64 encoding and decoding functions.

Adopted from Base64 AMX Mod X library function found here:
http://forums.alliedmods.net/showthread.php?t=87252

For an example application, check out the Jukebox for Source plugin, written by SirLamer:
http://forums.alliedmods.net/showthread.php?t=100537

***/

#if defined _Base64_included
	#endinput
#endif

#define _Base64_included

// The encoding table
new const String:sBase64Table[] =
  // 0000000000111111111122222222223333333333444444444455555555556666
  // 0123456789012345678901234567890123456789012345678901234567890123
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

// The decoding table
new const DecodeTable[] = {
//  0   1   2   3   4   5   6   7   8   9
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   //   0 -   9
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   //  10 -  19
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   //  20 -  29
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   //  30 -  39
    0,  0,  0,  62, 0,  0,  0,  63, 52, 53,  //  40 -  49
    54, 55, 56, 57, 58, 59, 60, 61, 0,  0,   //  50 -  59
    0,  0,  0,  0,  0,  0,  1,  2,  3,  4,   //  60 -  69
    5,  6,  7,  8,  9,  10, 11, 12, 13, 14,  //  70 -  79
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24,  //  80 -  89
    25, 0,  0,  0,  0,  0,  0,  26, 27, 28,  //  90 -  99
    29, 30, 31, 32, 33, 34, 35, 36, 37, 38,  // 100 - 109
    39, 40, 41, 42, 43, 44, 45, 46, 47, 48,  // 110 - 119
    49, 50, 51, 0,  0,  0,  0,  0,  0,  0,   // 120 - 129
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 130 - 139
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 140 - 149
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 150 - 159
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 160 - 169
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 170 - 179
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 180 - 189
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 190 - 199
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 200 - 209
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 210 - 219
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 220 - 229
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 230 - 239
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,   // 240 - 249
    0,  0,  0,  0,  0,  0                    // 250 - 256
};

// For some reason the standard demands a string in 24-bit (3 character) intervals.  This fill character is used to identify unused bytes at the end of the string.
new const cFillChar = '=';

// The conversion characters between the standard and URL-compliance Base64 protocols
new const String:mime_chars[] = "+/=";
new const String:url_chars[] = "-_.";


/***
EncodeBase64(String:sResult[], len, const String:sString[], sourcelen=0)
Encodes a string or binary data into Base64
- sResult: The storage buffer for the Base64-encoded result.
- len: The maximum length of the storage buffer, in characters/bytes.
- sString: The input string or binary data to be encoded.
- sourcelen (optional): The number of characters or length in bytes to be read from the input source.  This is not needed for a text string, but is important for binary data since there is no end-of-line character.

Return: The length of the written Base64 string, in bytes.
***/
stock EncodeBase64(String:sResult[], len, const String:sString[], sourcelen=0) {

	new nLength; // The string length to be read from the input
	new resPos; // The string position in the result buffer

  // If the read length was specified, use it; otherwise, pull the string length from the input.
	if (sourcelen > 0) {
		nLength = sourcelen;
	} else {
		nLength = strlen(sString);
	}

	// Loop through and generate the Base64 encoded string
	// NOTE: This performs the standard encoding process.  Do not manipulate the logic within this loop.
	for ( new nPos = 0 ; nPos < nLength ; nPos++ ) {
		new cCode;

		cCode = (sString[nPos] >> 2) & 0x3f;

		resPos += FormatEx(sResult[resPos], len - resPos, "%c", sBase64Table[cCode]);

		cCode = (sString[nPos] << 4) & 0x3f;
		if(++nPos < nLength)
			cCode |= (sString[nPos] >> 4) & 0x0f;
		resPos += FormatEx(sResult[resPos], len - resPos, "%c", sBase64Table[cCode]);

		if ( nPos < nLength ) {
			cCode = (sString[nPos] << 2) & 0x3f;
			if(++nPos < nLength)
				cCode |= (sString[nPos] >> 6) & 0x03;

			resPos += FormatEx(sResult[resPos], len - resPos, "%c", sBase64Table[cCode]);
		}
		else {
			nPos++;
			resPos += FormatEx(sResult[resPos], len - resPos, "%c", cFillChar);
		}

		if(nPos < nLength) {
			cCode = sString[nPos] & 0x3f;
			resPos += FormatEx(sResult[resPos], len - resPos, "%c", sBase64Table[cCode]);
		}
		else
			resPos += FormatEx(sResult[resPos], len - resPos, "%c", cFillChar);
	}

	return resPos;
}


/***
DecodeBase64(String:sResult[], len, const String:sString[])
Decodes a Base64 string.

- sResult: The storage buffer for the decoded text strihg or binary data.
- len: The maximum length of the storage buffer, in characters/bytes.
- sString: The input string in compliant Base64 format to be decoded.

Return: The length of the decoded data, in bytes.

***/
stock DecodeBase64(String:sResult[], len, const String:sString[]) {

	new nLength = strlen(sString); // The string length to be read from the input
	new resPos; // The string position in the result buffer

	// Loop through and generate the Base64 encoded string
	// NOTE: This performs the standard encoding process.  Do not manipulate the logic within this loop.
	for ( new nPos = 0 ; nPos < nLength ; nPos++) {

		new c, c1;

		c = DecodeTable[sString[nPos++]];
		c1 = DecodeTable[sString[nPos]];

		c = (c << 2) | ( (c1 >> 4) & 0x3 );

		resPos += FormatEx(sResult[resPos], len - resPos, "%c", c);

		if ( ++nPos < nLength ) {

			c = sString[nPos];

			if ( c == cFillChar )
				break;

			c = DecodeTable[sString[nPos]];
			c1 = ( (c1 << 4) & 0xf0 ) | ( ( c >> 2) & 0xf );

			resPos += FormatEx(sResult[resPos], len - resPos, "%c", c1);
		}

		if ( ++nPos < nLength ) {

			c1 = sString[nPos];

			if ( c1 == cFillChar )
				break;

			c1 = DecodeTable[sString[nPos]];
			c = ( (c << 6) & 0xc0 ) | c1;

			resPos += FormatEx(sResult[resPos], len - resPos, "%c", c);
		}
	}

	return resPos;
}


/***
Base64MimeToUrl(String:sResult[], len, const String:sString[])
Converts a standards-compliant Base64 string to the commonly accepted URL-compliant alternative.

- sResult: The storage buffer for the URL-compliant result.
- len: The maximum length of the storage buffer in characters/bytes.
- sString: The standards-compliant Base64 input string to converted.

Return: Number of cells written.

Note: The result will be the same length as the input string as long as the output buffer is large enough.
***/
stock Base64MimeToUrl(String:sResult[], len, const String:sString[]) {

	new chars_len = sizeof(mime_chars); // Length of the two standards vs. URL character lists
	new nLength; // The string length to be read from the input
	new temp_char; // Buffer character

	nLength = strlen(sString);

	new String:sTemp[nLength+1]; // Buffer string
	
	// Loop through string
	for(new i = 0; i < nLength; i++) {
		temp_char = sString[i];
		for(new j = 0; j < chars_len; j++) {
			if(temp_char == mime_chars[j]) {
				temp_char = url_chars[j];
				break;
			}
		}
		sTemp[i] = temp_char;
	}
	sTemp[nLength] = '\0';

	return strcopy(sResult, len, sTemp);
}

/***
Base64UrlToMime(String:sResult[], len, const String:sString[], sourcelen)
Converts a URL-compliant Base64 string to the standards-compliant version.

- sResult: The storage buffer for the standards-compliant result.
- len: The maximum length of the storage buffer in characters/bytes.
- sString: The URL-compliant Base64 input string to converted.

Return: Number of cells written.

Note: The result will be the same length as the input string as long as the output buffer is large enough.
***/
stock Base64UrlToMime(String:sResult[], len, const String:sString[], sourcelen) {

	new chars_len = sizeof(mime_chars); // Length of the two standards vs. URL character lists
	new nLength; // The string length to be read from the input
	new temp_char; // Buffer character

	nLength = strlen(sString);

	new String:sTemp[nLength+1]; // Buffer string
	
	// Loop through string
	for(new i = 0; i < nLength; i++) {
		temp_char = sString[i];
		for(new j = 0; j < chars_len; j++) {
			if(temp_char == url_chars[j]) {
				temp_char = mime_chars[j];
				break;
			}
		}
		sTemp[i] = temp_char;
	}
	sTemp[nLength] = '\0';

	return strcopy(sResult, len, sTemp);
}