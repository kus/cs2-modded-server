#if defined _bzip2_included
 #endinput
#endif
#define _bzip2_included

enum BZ_Error {
	BZ_OK				= 0,
	BZ_RUN_OK			= 1,
	BZ_FLUSH_OK			= 2,
	BZ_FINISH_OK		= 3,
	BZ_STREAM_END		= 4,
	BZ_SEQUENCE_ERROR	= -1,
	BZ_PARAM_ERROR		= -2,
	BZ_MEM_ERROR		= -3,
	BZ_DATA_ERROR		= -4,
	BZ_DATA_ERROR_MAGIC	= -5,
	BZ_IO_ERROR			= -6,
	BZ_UNEXPECTED_EOF	= -7,
	BZ_OUTBUFF_FULL		= -8,
	BZ_CONFIG_ERROR		= -9,
	BZ_IO_ERROR_INPUT	= -101,
	BZ_IO_ERROR_OUTPUT	= -102,
};

typeset  BZ2Callback { 
	function void (BZ_Error iError, char inFile[], char outFile[], any data);
}

native BZ2_DecompressFile(String:inFile[], String:outFile[], BZ2Callback:cb, any:data = 0);
native BZ2_CompressFile(String:inFile[], String:outFile[], iCompressionLevel, BZ2Callback:cb, any:data = 0);

stock BZ2_Error(BZ_Error:iError, String:sError[], iErrorStringLength) {
	switch(iError) {
		case BZ_OK: strcopy(sError, iErrorStringLength, "BZ_OK");
		case BZ_RUN_OK: strcopy(sError, iErrorStringLength, "BZ_RUN_OK");
		case BZ_FLUSH_OK: strcopy(sError, iErrorStringLength, "BZ_FLUSH_OK");
		case BZ_FINISH_OK: strcopy(sError, iErrorStringLength, "BZ_FINISH_OK");
		case BZ_STREAM_END: strcopy(sError, iErrorStringLength, "BZ_STREAM_END");
		case BZ_SEQUENCE_ERROR: strcopy(sError, iErrorStringLength, "BZ_SEQUENCE_ERROR");
		case BZ_PARAM_ERROR: strcopy(sError, iErrorStringLength, "BZ_PARAM_ERROR");
		case BZ_MEM_ERROR: strcopy(sError, iErrorStringLength, "BZ_MEM_ERROR");
		case BZ_DATA_ERROR: strcopy(sError, iErrorStringLength, "BZ_DATA_ERROR");
		case BZ_DATA_ERROR_MAGIC: strcopy(sError, iErrorStringLength, "BZ_DATA_ERROR_MAGIC");
		case BZ_IO_ERROR: strcopy(sError, iErrorStringLength, "BZ_IO_ERROR");
		case BZ_UNEXPECTED_EOF: strcopy(sError, iErrorStringLength, "BZ_UNEXPECTED_EOF");
		case BZ_OUTBUFF_FULL: strcopy(sError, iErrorStringLength, "BZ_OUTBUFF_FULL");
		case BZ_CONFIG_ERROR: strcopy(sError, iErrorStringLength, "BZ_CONFIG_ERROR");
		case BZ_IO_ERROR_INPUT: strcopy(sError, iErrorStringLength, "BZ_IO_ERROR_INPUT");
		case BZ_IO_ERROR_OUTPUT: strcopy(sError, iErrorStringLength, "BZ_IO_ERROR_OUTPUT");
	}
}

stock LogBZ2Error(BZ_Error:iError, const String:sSuffix[] = "") {
	new String:sError[255];
	BZ2_Error(iError, sError, sizeof(sError));
	LogError("bzip2 Error: %s %s", sError, sSuffix);
}

/**
 * Do not edit below this line!
 */
public Extension:__ext_bzip2 =
{
	name = "SMbz2",
	file = "smbz2.ext",
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
public __ext_bzip2_SetNTVOptional()
{
	MarkNativeAsOptional("BZ2_DecompressFile");
	MarkNativeAsOptional("BZ2_CompressFile");
}
#endif