#if defined _smlib_crypt_included
	#endinput
#endif
#define _smlib_crypt_included

#include <sourcemod>

/**********************************************************************************
 *
 * Base64 Encoding/Decoding Functions
 * All Credits to to SirLamer & ScriptCoderPro
 * Taken from http://forums.alliedmods.net/showthread.php?t=101764
 *
 ***********************************************************************************/

// The Base64 encoding table
static const String:base64_sTable[] =
  // 0000000000111111111122222222223333333333444444444455555555556666
  // 0123456789012345678901234567890123456789012345678901234567890123
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

// The Base64 decoding table
static const base64_decodeTable[] = {
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

/*
 * For some reason the standard demands a string in 24-bit (3 character) intervals.
 * This fill character is used to identify unused bytes at the end of the string.
 */
static const base64_cFillChar			= '=';

// The conversion characters between the standard and URL-compliance Base64 protocols
static const String:base64_mime_chars[]	= "+/=";
static const String:base64_url_chars[]	= "-_.";

/*
 * Encodes a string or binary data into Base64
 *
 * @param sString		The input string or binary data to be encoded.
 * @param sResult		The storage buffer for the Base64-encoded result.
 * @param len			The maximum length of the storage buffer, in characters/bytes.
 * @param sourcelen 	(optional): The number of characters or length in bytes to be read from the input source.
 *						This is not needed for a text string, but is important for binary data since there is no end-of-line character.
 * @return				The length of the written Base64 string, in bytes.
 */
stock Crypt_Base64Encode(const String:sString[], String:sResult[], len, sourcelen=0)
{
	new nLength;	// The string length to be read from the input
	new resPos;		// The string position in the result buffer

	// If the read length was specified, use it; otherwise, pull the string length from the input.
	if (sourcelen > 0) {
		nLength = sourcelen;
	}
	else {
		nLength = strlen(sString);
	}

	// Loop through and generate the Base64 encoded string
	// NOTE: This performs the standard encoding process.  Do not manipulate the logic within this loop.
	for (new nPos = 0; nPos < nLength; nPos++) {
		new cCode;

		cCode = (sString[nPos] >> 2) & 0x3f;

		resPos += FormatEx(sResult[resPos], len - resPos, "%c", base64_sTable[cCode]);

		cCode = (sString[nPos] << 4) & 0x3f;
		if (++nPos < nLength) {
			cCode |= (sString[nPos] >> 4) & 0x0f;
		}
		resPos += FormatEx(sResult[resPos], len - resPos, "%c", base64_sTable[cCode]);

		if ( nPos < nLength ) {
			cCode = (sString[nPos] << 2) & 0x3f;
			if (++nPos < nLength) {
				cCode |= (sString[nPos] >> 6) & 0x03;
			}

			resPos += FormatEx(sResult[resPos], len - resPos, "%c", base64_sTable[cCode]);
		}
		else {
			nPos++;
			resPos += FormatEx(sResult[resPos], len - resPos, "%c", base64_cFillChar);
		}

		if (nPos < nLength) {
			cCode = sString[nPos] & 0x3f;
			resPos += FormatEx(sResult[resPos], len - resPos, "%c", base64_sTable[cCode]);
		}
		else {
			resPos += FormatEx(sResult[resPos], len - resPos, "%c", base64_cFillChar);
		}
	}

	return resPos;
}


/*
 * Decodes a Base64 string.
 *
 * @param sString		The input string in compliant Base64 format to be decoded.
 * @param sResult		The storage buffer for the decoded text strihg or binary data.
 * @param len			The maximum length of the storage buffer, in characters/bytes.
 * @return				The length of the decoded data, in bytes.
 */
stock Crypt_Base64Decode(const String:sString[], String:sResult[], len)
{
	new nLength = strlen(sString);	// The string length to be read from the input
	new resPos;						// The string position in the result buffer

	// Loop through and generate the Base64 encoded string
	// NOTE: This performs the standard encoding process.  Do not manipulate the logic within this loop.
	for (new nPos = 0; nPos < nLength; nPos++) {

		new c, c1;

		c	= base64_decodeTable[sString[nPos++]];
		c1	= base64_decodeTable[sString[nPos]];

		c = (c << 2) | ((c1 >> 4) & 0x3);

		resPos += FormatEx(sResult[resPos], len - resPos, "%c", c);

		if (++nPos < nLength) {

			c = sString[nPos];

			if (c == base64_cFillChar)
				break;

			c = base64_decodeTable[sString[nPos]];
			c1 = ((c1 << 4) & 0xf0) | ((c >> 2) & 0xf);

			resPos += FormatEx(sResult[resPos], len - resPos, "%c", c1);
		}

		if (++nPos < nLength) {

			c1 = sString[nPos];

			if (c1 == base64_cFillChar)
				break;

			c1 = base64_decodeTable[sString[nPos]];
			c = ((c << 6) & 0xc0) | c1;

			resPos += FormatEx(sResult[resPos], len - resPos, "%c", c);
		}
	}

	return resPos;
}


/*
 * Converts a standards-compliant Base64 string to the commonly accepted URL-compliant alternative.
 * Note: The result will be the same length as the input string as long as the output buffer is large enough.
 *
 * @param sString		The standards-compliant Base64 input string to converted.
 * @param sResult		The storage buffer for the URL-compliant result.
 * @param len			The maximum length of the storage buffer in characters/bytes.
 * @return				Number of cells written.
 */
stock Crypt_Base64MimeToUrl(const String:sString[], String:sResult[], len)
{
	new chars_len = sizeof(base64_mime_chars);	// Length of the two standards vs. URL character lists
	new nLength;								// The string length to be read from the input
	new temp_char;								// Buffer character

	nLength = strlen(sString);

	new String:sTemp[nLength+1]; // Buffer string

	// Loop through string
	for (new i = 0; i < nLength; i++) {
		temp_char = sString[i];

		for (new j = 0; j < chars_len; j++) {

			if(temp_char == base64_mime_chars[j]) {
				temp_char = base64_url_chars[j];
				break;
			}
		}

		sTemp[i] = temp_char;
	}

	sTemp[nLength] = '\0';

	return strcopy(sResult, len, sTemp);
}

/*
 * Base64UrlToMime(String:sResult[], len, const String:sString[], sourcelen)
 * Converts a URL-compliant Base64 string to the standards-compliant version.
 * Note: The result will be the same length as the input string as long as the output buffer is large enough.
 *
 * @param sString		The URL-compliant Base64 input string to converted.
 * @param sResult		The storage buffer for the standards-compliant result.
 * @param len			The maximum length of the storage buffer in characters/bytes.
 * @return				Number of cells written.
 */
stock Crypt_Base64UrlToMime(const String:sString[], String:sResult[], len)
{
	new chars_len = sizeof(base64_mime_chars);	// Length of the two standards vs. URL character lists
	new nLength;								// The string length to be read from the input
	new temp_char;								// Buffer character

	nLength = strlen(sString);

	new String:sTemp[nLength+1]; // Buffer string

	// Loop through string
	for (new i = 0; i < nLength; i++) {
		temp_char = sString[i];
		for (new j = 0; j < chars_len; j++) {
			if (temp_char == base64_url_chars[j]) {
				temp_char = base64_mime_chars[j];
				break;
			}
		}

		sTemp[i] = temp_char;
	}

	sTemp[nLength] = '\0';

	return strcopy(sResult, len, sTemp);
}

/**********************************************************************************
 *
 * MD5 Encoding Functions
 * All Credits go to sslice
 * RSA Data Security, Inc. MD5 Message Digest Algorithm
 * Taken from http://forums.alliedmods.net/showthread.php?t=67683
 *
 ***********************************************************************************/

/*
 * Calculate the md5 hash of a string.
 *
 * @param str			Input String
 * @param output		Output String Buffer
 * @param maxlen		Size of the Output String Buffer
 * @noreturn
 */
stock Crypt_MD5(const String:str[], String:output[], maxlen)
{
	decl x[2];
	decl buf[4];
	decl input[64];
	new i, ii;

	new len = strlen(str);

	// MD5Init
	x[0] = x[1] = 0;
	buf[0] = 0x67452301;
	buf[1] = 0xefcdab89;
	buf[2] = 0x98badcfe;
	buf[3] = 0x10325476;

	// MD5Update
	new update[16];

	update[14] = x[0];
	update[15] = x[1];

	new mdi = (x[0] >>> 3) & 0x3F;

	if ((x[0] + (len << 3)) < x[0]) {
		x[1] += 1;
	}

	x[0] += len << 3;
	x[1] += len >>> 29;

	new c = 0;
	while (len--) {
		input[mdi] = str[c];
		mdi += 1;
		c += 1;

		if (mdi == 0x40) {

			for (i = 0, ii = 0; i < 16; ++i, ii += 4)
			{
				update[i] = (input[ii + 3] << 24) | (input[ii + 2] << 16) | (input[ii + 1] << 8) | input[ii];
			}

			// Transform
			MD5Transform(buf, update);

			mdi = 0;
		}
	}

	// MD5Final
	new padding[64] = {
		0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	};

	new inx[16];
	inx[14] = x[0];
	inx[15] = x[1];

	mdi = (x[0] >>> 3) & 0x3F;

	len = (mdi < 56) ? (56 - mdi) : (120 - mdi);
	update[14] = x[0];
	update[15] = x[1];

	mdi = (x[0] >>> 3) & 0x3F;

	if ((x[0] + (len << 3)) < x[0]) {
		x[1] += 1;
	}

	x[0] += len << 3;
	x[1] += len >>> 29;

	c = 0;
	while (len--) {
		input[mdi] = padding[c];
		mdi += 1;
		c += 1;

		if (mdi == 0x40) {

			for (i = 0, ii = 0; i < 16; ++i, ii += 4) {
				update[i] = (input[ii + 3] << 24) | (input[ii + 2] << 16) | (input[ii + 1] << 8) | input[ii];
			}

			// Transform
			MD5Transform(buf, update);

			mdi = 0;
		}
	}

	for (i = 0, ii = 0; i < 14; ++i, ii += 4) {
		inx[i] = (input[ii + 3] << 24) | (input[ii + 2] << 16) | (input[ii + 1] << 8) | input[ii];
	}

	MD5Transform(buf, inx);

	new digest[16];
	for (i = 0, ii = 0; i < 4; ++i, ii += 4) {
		digest[ii] = (buf[i]) & 0xFF;
		digest[ii + 1] = (buf[i] >>> 8) & 0xFF;
		digest[ii + 2] = (buf[i] >>> 16) & 0xFF;
		digest[ii + 3] = (buf[i] >>> 24) & 0xFF;
	}

	FormatEx(output, maxlen, "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
		digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7],
		digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]);
}

static stock MD5Transform_FF(&a, &b, &c, &d, x, s, ac)
	{
	a += (((b) & (c)) | ((~b) & (d))) + x + ac;
	a = (((a) << (s)) | ((a) >>> (32-(s))));
	a += b;
}

static stock MD5Transform_GG(&a, &b, &c, &d, x, s, ac)
	{
	a += (((b) & (d)) | ((c) & (~d))) + x + ac;
	a = (((a) << (s)) | ((a) >>> (32-(s))));
	a += b;
}

static stock MD5Transform_HH(&a, &b, &c, &d, x, s, ac)
	{
	a += ((b) ^ (c) ^ (d)) + x + ac;
	a = (((a) << (s)) | ((a) >>> (32-(s))));
	a += b;
}

static stock MD5Transform_II(&a, &b, &c, &d, x, s, ac)
{
	a += ((c) ^ ((b) | (~d))) + x + ac;
	a = (((a) << (s)) | ((a) >>> (32-(s))));
	a += b;
}

static stock MD5Transform(buf[], input[]){
	new a = buf[0];
	new b = buf[1];
	new c = buf[2];
	new d = buf[3];

	MD5Transform_FF(a, b, c, d, input[0], 7, 0xd76aa478);
	MD5Transform_FF(d, a, b, c, input[1], 12, 0xe8c7b756);
	MD5Transform_FF(c, d, a, b, input[2], 17, 0x242070db);
	MD5Transform_FF(b, c, d, a, input[3], 22, 0xc1bdceee);
	MD5Transform_FF(a, b, c, d, input[4], 7, 0xf57c0faf);
	MD5Transform_FF(d, a, b, c, input[5], 12, 0x4787c62a);
	MD5Transform_FF(c, d, a, b, input[6], 17, 0xa8304613);
	MD5Transform_FF(b, c, d, a, input[7], 22, 0xfd469501);
	MD5Transform_FF(a, b, c, d, input[8], 7, 0x698098d8);
	MD5Transform_FF(d, a, b, c, input[9], 12, 0x8b44f7af);
	MD5Transform_FF(c, d, a, b, input[10], 17, 0xffff5bb1);
	MD5Transform_FF(b, c, d, a, input[11], 22, 0x895cd7be);
	MD5Transform_FF(a, b, c, d, input[12], 7, 0x6b901122);
	MD5Transform_FF(d, a, b, c, input[13], 12, 0xfd987193);
	MD5Transform_FF(c, d, a, b, input[14], 17, 0xa679438e);
	MD5Transform_FF(b, c, d, a, input[15], 22, 0x49b40821);

	MD5Transform_GG(a, b, c, d, input[1], 5, 0xf61e2562);
	MD5Transform_GG(d, a, b, c, input[6], 9, 0xc040b340);
	MD5Transform_GG(c, d, a, b, input[11], 14, 0x265e5a51);
	MD5Transform_GG(b, c, d, a, input[0], 20, 0xe9b6c7aa);
	MD5Transform_GG(a, b, c, d, input[5], 5, 0xd62f105d);
	MD5Transform_GG(d, a, b, c, input[10], 9, 0x02441453);
	MD5Transform_GG(c, d, a, b, input[15], 14, 0xd8a1e681);
	MD5Transform_GG(b, c, d, a, input[4], 20, 0xe7d3fbc8);
	MD5Transform_GG(a, b, c, d, input[9], 5, 0x21e1cde6);
	MD5Transform_GG(d, a, b, c, input[14], 9, 0xc33707d6);
	MD5Transform_GG(c, d, a, b, input[3], 14, 0xf4d50d87);
	MD5Transform_GG(b, c, d, a, input[8], 20, 0x455a14ed);
	MD5Transform_GG(a, b, c, d, input[13], 5, 0xa9e3e905);
	MD5Transform_GG(d, a, b, c, input[2], 9, 0xfcefa3f8);
	MD5Transform_GG(c, d, a, b, input[7], 14, 0x676f02d9);
	MD5Transform_GG(b, c, d, a, input[12], 20, 0x8d2a4c8a);

	MD5Transform_HH(a, b, c, d, input[5], 4, 0xfffa3942);
	MD5Transform_HH(d, a, b, c, input[8], 11, 0x8771f681);
	MD5Transform_HH(c, d, a, b, input[11], 16, 0x6d9d6122);
	MD5Transform_HH(b, c, d, a, input[14], 23, 0xfde5380c);
	MD5Transform_HH(a, b, c, d, input[1], 4, 0xa4beea44);
	MD5Transform_HH(d, a, b, c, input[4], 11, 0x4bdecfa9);
	MD5Transform_HH(c, d, a, b, input[7], 16, 0xf6bb4b60);
	MD5Transform_HH(b, c, d, a, input[10], 23, 0xbebfbc70);
	MD5Transform_HH(a, b, c, d, input[13], 4, 0x289b7ec6);
	MD5Transform_HH(d, a, b, c, input[0], 11, 0xeaa127fa);
	MD5Transform_HH(c, d, a, b, input[3], 16, 0xd4ef3085);
	MD5Transform_HH(b, c, d, a, input[6], 23, 0x04881d05);
	MD5Transform_HH(a, b, c, d, input[9], 4, 0xd9d4d039);
	MD5Transform_HH(d, a, b, c, input[12], 11, 0xe6db99e5);
	MD5Transform_HH(c, d, a, b, input[15], 16, 0x1fa27cf8);
	MD5Transform_HH(b, c, d, a, input[2], 23, 0xc4ac5665);

	MD5Transform_II(a, b, c, d, input[0], 6, 0xf4292244);
	MD5Transform_II(d, a, b, c, input[7], 10, 0x432aff97);
	MD5Transform_II(c, d, a, b, input[14], 15, 0xab9423a7);
	MD5Transform_II(b, c, d, a, input[5], 21, 0xfc93a039);
	MD5Transform_II(a, b, c, d, input[12], 6, 0x655b59c3);
	MD5Transform_II(d, a, b, c, input[3], 10, 0x8f0ccc92);
	MD5Transform_II(c, d, a, b, input[10], 15, 0xffeff47d);
	MD5Transform_II(b, c, d, a, input[1], 21, 0x85845dd1);
	MD5Transform_II(a, b, c, d, input[8], 6, 0x6fa87e4f);
	MD5Transform_II(d, a, b, c, input[15], 10, 0xfe2ce6e0);
	MD5Transform_II(c, d, a, b, input[6], 15, 0xa3014314);
	MD5Transform_II(b, c, d, a, input[13], 21, 0x4e0811a1);
	MD5Transform_II(a, b, c, d, input[4], 6, 0xf7537e82);
	MD5Transform_II(d, a, b, c, input[11], 10, 0xbd3af235);
	MD5Transform_II(c, d, a, b, input[2], 15, 0x2ad7d2bb);
	MD5Transform_II(b, c, d, a, input[9], 21, 0xeb86d391);

	buf[0] += a;
	buf[1] += b;
	buf[2] += c;
	buf[3] += d;
}

/**********************************************************************************
 *
 * RC4 Encoding Functions
 * All Credits go to SirLamer and Raydan
 * Taken from http://forums.alliedmods.net/showthread.php?t=101834
 *
 ***********************************************************************************/

/*
 * Encrypts a text string using RC4.
 * Note: This function is NOT binary safe.
 * Use EncodeRC4Binary to encode binary data.
 *
 * @param input			The source data to be encrypted.
 * @param pwd			The password/key used to encode and decode the data.
 * @param output		The encoded result.
 * @param maxlen		The maximum length of the output buffer.
 *
 * @noreturn
 */
stock Crypt_RC4Encode(const String:input[], const String:pwd[], String:output[], maxlen)
{
	decl pwd_len,str_len,i,j,a,k;
	decl key[256];
	decl box[256];
	decl tmp;

	pwd_len = strlen(pwd);
	str_len = strlen(input);

	if (pwd_len > 0 && str_len > 0) {

		for (i=0; i < 256; i++) {
			key[i] = pwd[i%pwd_len];
			box[i]=i;
		}

		i=0; j=0;

		for (; i < 256; i++) {
			j = (j + box[i] + key[i]) % 256;
			tmp = box[i];
			box[i] = box[j];
			box[j] = tmp;
		}

		i=0; j=0; a=0;

		for (; i < str_len; i++)	{
			a = (a + 1) % 256;
			j = (j + box[a]) % 256;
			tmp = box[a];
			box[a] = box[j];
			box[j] = tmp;
			k = box[((box[a] + box[j]) % 256)];
			FormatEx(output[2*i], maxlen-2*i, "%02x", input[i] ^ k);
		}
	}
}

/*
 * Encrypts binary data using RC4.
 *
 * @param input			The source data to be encrypted.
 * @param str_len		The length of the source data.
 * @param pwd			The password/key used to encode and decode the data.
 * @param output		The encoded result.
 * @param maxlen		The maximum length of the output buffer.
 * @noreturn
 */
stock Crypt_RC4EncodeBinary(const String:input[], str_len, const String:pwd[], String:output[], maxlen)
{
	decl pwd_len,i,j,a,k;
	decl key[256];
	decl box[256];
	decl tmp;

	pwd_len = strlen(pwd);

	if (pwd_len > 0 && str_len > 0) {

		for(i=0;i<256;i++) {
			key[i] = pwd[i%pwd_len];
			box[i]=i;
		}

		i=0; j=0;

		for (; i < 256; i++) {
			j = (j + box[i] + key[i]) % 256;
			tmp = box[i];
			box[i] = box[j];
			box[j] = tmp;
		}

		i=0; j=0; a=0;

		if (str_len+1 > maxlen) {
			str_len = maxlen - 1;
		}

		for(; i < str_len; i++)	{
			a = (a + 1) % 256;
			j = (j + box[a]) % 256;
			tmp = box[a];
			box[a] = box[j];
			box[j] = tmp;
			k = box[((box[a] + box[j]) % 256)];
			FormatEx(output[i], maxlen-i, "%c", input[i] ^ k);
		}

		/*
		 * i = number of written bits (remember increment occurs at end of for loop, and THEN it fails the loop condition)
		 * Since we're working with binary data, the calling function should not depend on the escape
		 * character, but putting it here prevents crashes in case someone tries to read the data like a string
		 */
		output[i] = '\0';

		return i;
	}
	else {
		return -1;
	}
}
