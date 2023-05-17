
#if defined _cURL_included
  #endinput
#endif
#define _cURL_included

#include <cURL_header>


/*
========================================
The Following CURLOPT_* NOT support 
ERRORBUFFER              // use curl_get_error_buffer
WRITEINFO                // ???
PROGRESSFUNCTION         // unused
PROGRESSDATA             // same
HEADERFUNCTION           // unused
DEBUGFUNCTION            // unused
DEBUGDATA                // same
SHARE                    // unsupport
PRIVATE                  // unsupport
SSL_CTX_FUNC             // unused
SSL_CTX_DATA             // same
IOCTLFUNCTION            // unused
IOCTLDATA                // same
CONV_FROM_NETWORK_FUNC   // unused
CONV_TO_NETWORK_FUNC     // unused
CONV_FROM_UTF8_FUNC      // unused
SOCKOPTFUNCTION          // unused
SOCKOPTDATA              // unused
OPENSOCKETFUNCTION       // used
OPENSOCKETDATA           // used
COPYPOSTFIELDS           // unsupport
SEEKFUNCTION             // unused
SEEKDATA                 // unused
SOCKS5_GSSAPI_SERVICE    // unsupport
SOCKS5_GSSAPI_NEC        // unsupport
SSH_KEYFUNCTION          // unsupport
SSH_KEYDATA              // unsupport
INTERLEAVEFUNCTION       // unsupport
CHUNK_BGN_FUNC           // unsupport
CHUNK_END_FUNC           // unsupport
FNMATCH_FUNC             // unsupport
CHUNK_DATA               // unsupport
FNMATCH_DATA             // unsupport
TLSAUTH_USERNAME         // unsupport, require tls-srp
TLSAUTH_PASSWORD         // unsupport, require tls-srp
TLSAUTH_TYPE             // unsupport, require tls-srp
CLOSESOCKETFUNCTION      // unsupport
CLOSESOCKETDATA          // unsupport
========================================*/

/*
========================================
The Following CURLOPT_* supports the "file //" notation.
COOKIEFILE
COOKIEJAR
RANDOM_FILE
EGDSOCKET
SSLKEY
CAPATH
NETRC_FILE
SSH_PUBLIC_KEYFILE
SSH_PRIVATE_KEYFILE
_CRLFILE
ISSUERCERT
SSH_KNOWNHOSTS

========================================*/

/*
========================================
The Following CURLINFO_* NOT support 
CURLINFO_SLIST

========================================*/

/*
========================================
The Following CURLFORM_* NOT support 
CURLFORM_PTRNAME
CURLFORM_PTRCONTENTS
CURLFORM_ARRAY
CURLFORM_BUFFER
CURLFORM_BUFFERPTR
CURLFORM_BUFFERLENGTH
CURLFORM_STREAM

========================================*/




/*************************************************************************************************/
/******************************************** OPTIONS ********************************************/
/*************************************************************************************************/


/**
 * The Send & Receive Action
 * Using on CURL_OnSend, CURL_OnReceive
 * SendRecv_Act_GOTO_SEND = go to send
 * SendRecv_Act_GOTO_RECV = go to receive
 * SendRecv_Act_GOTO_WAIT = go to wait
 * SendRecv_Act_GOTO_END = end the connection
 * SendRecv_Act_GOTO_SEND_NO_WAIT = go to send but no select
 * SendRecv_Act_GOTO_RECV_NO_WAIT = go to receive but no select
 * To see how it work? see curl_echo_test.sp & curl_rcon_test.sp examples
 */
enum SendRecv_Act {
	SendRecv_Act_NOTHING = 0,

	SendRecv_Act_GOTO_SEND,
	SendRecv_Act_GOTO_RECV,
	SendRecv_Act_GOTO_WAIT,
	SendRecv_Act_GOTO_END,
	SendRecv_Act_GOTO_SEND_NO_WAIT,
	SendRecv_Act_GOTO_RECV_NO_WAIT,

	SendRecv_Act_LAST,
};

/**
 * Hash type for curl_hash_file, curl_hash_string
 */
enum Openssl_Hash {
	Openssl_Hash_MD5 = 0,
	Openssl_Hash_MD4,
	Openssl_Hash_MD2,
	Openssl_Hash_SHA,
	Openssl_Hash_SHA1,
	Openssl_Hash_SHA224,
	Openssl_Hash_SHA256,
	Openssl_Hash_SHA384,
	Openssl_Hash_SHA512,
	Openssl_Hash_RIPEMD160,
};


/*************************************************************************************************/
/******************************************* CALLBACKS *******************************************/
/*************************************************************************************************/


/**
 * called if curl_easy_perform_thread() or curl_easy_send_recv() Complete
 * @ param Handle	hndl		The curl handle
 * @ param CURLcode	code		The CURLcode code, see cURL_header.inc
 * @ param any		data		Data passed to curl_easy_perform_thread()
 * @ noreturn
 */
typeset CURL_OnComplete
{
	function void (Handle hndl, CURLcode code);
	function void (Handle hndl, CURLcode code , any data);
};

/**
 * called if curl_easy_send_recv() before sending data
 * @ param Handle	hndl				The curl handle
 * @ param CURLcode	code				The last CURLcode code, see cURL_header.inc
 * @ param cell_t	last_sent_dataSize	The last sent datasize
 * @ param any		data				Data passed to curl_easy_send_recv()
 * @ return 								SendRecv_Act
 */
typeset CURL_OnSend
{
	function SendRecv_Act (Handle hndl, CURLcode code, const int last_sent_dataSize);
	function SendRecv_Act (Handle hndl, CURLcode code, const int last_sent_dataSize, any data);
}

/**
 * called if curl_easy_send_recv() after received data
 * @ param Handle	hndl		The curl handle
 * @ param CURLcode	code		The CURLcode code, see cURL_header.inc
 * @ param String	dataSize	The received datasize
 * @ param any		data		Data passed to curl_easy_send_recv()
 * @ return 						SendRecv_Act
 */
typeset CURL_OnReceive
{
	function SendRecv_Act (Handle hndl, CURLcode code, const char[] receiveData, const int dataSize);
	function SendRecv_Act (Handle hndl, CURLcode code, const char[] receiveData, const int dataSize, any data);
}

/**
 * called if Openssl_Hash_file() after hashed the file
 * @ param bool		success		True on success, false if hash file fail
 * @ param String	buffer		The hash string
 * @ param any		data		Data passed to Openssl_Hash_file()
 * @ noreturn
 */
typeset Openssl_Hash_Complete
{
	function void (const bool success, const char[] buffer);
	function void (const bool success, const char[] buffer, any data);
}


typeset CURL_Function_CB
{
	// CURLOPT_WRITEFUNCTION
	function void (Handle hndl, const char[] buffer, const int bytes, const int nmemb);
	function void (Handle hndl, const char[] buffer, const int bytes, const int nmemb, any data);
	
	// CURLOPT_READFUNCTION
	function void (Handle hndl, const int bytes, const int nmemb);
	function void (Handle hndl, const int bytes, const int nmemb, any data);
}

/*************************************************************************************************/
/******************************************** NATIVES ********************************************/
/*************************************************************************************************/


/**
 * Create a curl handle
 * @ return Handle				The curl handle. Returns INVALID_HANDLE on failure
 */
native Handle curl_easy_init();

/**
 * Set a curl option for CURLOPTTYPE_OBJECTPOINT type
 *
 * @ param Handle		hndl	The handle of the curl to be used. May be INVALID_HANDLE if not essential.
 * @ param CURLoption	opt		The option to add (see enum CURLoption for details).
 * @ param String		buffer	The value to set the option to.
 * @ return bool				1 on success. 0 = The option not accept string or unsupport.
 */
native bool curl_easy_setopt_string(Handle hndl, CURLoption opt, const char[] buffer);

/**
 * Set a curl option for CURLOPTTYPE_LONG type
 *
 * @ param Handle		hndl	The handle of the curl to be used. May be INVALID_HANDLE if not essential.
 * @ param CURLoption	opt		The option to add (see enum CURLoption for details).
 * @ param cell_t		value	The value to set the option to.
 * @ return bool				1 on success. 0 = The option not accept integer or unsupport.
 */
native bool curl_easy_setopt_int(Handle hndl, CURLoption opt, int value);

/**
 * Set a curl option for CURLOPTTYPE_LONG type
 * @ example"
	new opt[][2] = {
		{_ CURLOPT_NOPROGRESS,1},
		{_ CURLOPT_VERBOSE,0}
	};
 *
 * @ param Handle		hndl		The handle of the curl to be used. May be INVALID_HANDLE if not essential.
 * @ param cell_t		array		The option array to add (see enum CURLoption for details).
 * @ param cell_t		array_size	The array size.
 * @ return bool					1 on success. 0 = The option not accept integer or unsupport.
 */
native bool curl_easy_setopt_int_array(Handle hndl, int[][] array, int array_size); // int array[][2]

/**
 * Set a curl option for CURLOPTTYPE_OFF_T type
 *
 * @ param Handle		hndl	The handle of the curl to be used. May be INVALID_HANDLE if not essential.
 * @ param CURLoption	opt		The option to add (see enum CURLoption for details).
 * @ param String		buffer	The value to set the option to.
 * @ return bool				1 on success. 0 = The option not accept string or unsupport.
 */
native bool curl_easy_setopt_int64(Handle hndl, CURLoption opt, const char buffer);

/**
 * Set a curl option for CURLOPTTYPE_OBJECTPOINT type
 * @ note only accept the following handle type
 	curl_OpenFile()
 	curl_httppost()
 	curl_slist()
 *
 * @ param Handle		hndl		The handle of the curl to be used. May be INVALID_HANDLE if not essential.
 * @ param CURLoption	opt			The option to add (see enum CURLoption for details).
 * @ param Handle		other_hndl	The other handle to set the option to.
 * @ return bool					1 on success. 0 = The option not accept string or unsupport.
 */
native bool curl_easy_setopt_handle(Handle hndl, CURLoption opt, Handle other_hndl);

/**
 * Set a curl option for CURLOPTTYPE_FUNCTIONPOINT type
 *
 * @ param Handle				hndl		The handle of the curl to be used. May be INVALID_HANDLE if not essential.
 * @ param CURLoption			opt			The option to add (see enum CURLoption for details).
 * @ param CURL_Function_CB		callback	The value to set the option to.
 * @ param cell_t				value		Value to set.
 * @ return bool							1 on success. 0 = The option unsupport or invalid callback function.
 */
native bool curl_easy_setopt_function(Handle hndl, CURLoption opt, CURL_Function_CB callback, any value=0);

/**
 * Load all CURLoption to curl Handle
 * @ note
 * 		Using curl_easy_perform_thread() will load option in thread
 * 		Use this on curl_easy_perform or check all CURLoption are valid or not
 * 		Only can use one time for each curl handle
 * @ return 		The CURLcode code, see cURL_header.inc
 */
native CURLcode curl_load_opt(Handle hndl);

/**
 * Perform a file transfer
 * @ return 		The CURLcode code, see cURL_header.inc
 */
native CURLcode curl_easy_perform(Handle hndl);

/**
 * Perform a file transfer, using thread
 * @ param Handle			hndl				The handle of the curl to be used. May be INVALID_HANDLE if not essential.
 * @ param CURL_OnComplete	perform_callback	The complete callback.
 * @ param cell_t			value				Value to set.
 * @ noreturn
 */
native void curl_easy_perform_thread(Handle hndl, CURL_OnComplete perform_callback, any value=0);

/**
 * Create a send & receive function for a connected curl handle
 * @ param Handle			hndl				The handle of the curl to be used.
 * @ param CURL_OnSend		send_callback		The send callback.
 * @ param CURL_OnReceive	receive_callback	The receive callback.
 * @ param CURL_OnComplete	complete_callback	The complete callback.
 * @ param SendRecv_Act		act 				The first SendRecv_Act action
 * @ param cell_t			send_timeout 		Send timeout value in milliseconds.
 * @ param cell_t			recv_timeout 		Receive timeout value in milliseconds.
 * @ param cenn_t			recv_buffer_Size	Receive buffer size.
 * @ param cell_t			value				Value to set.
 * @ noreturn
 */
native void curl_easy_send_recv(Handle hndl, CURL_OnSend send_callback, CURL_OnReceive receive_callback, CURL_OnComplete complete_callback, SendRecv_Act act, int send_timeout, int recv_timeout, int recv_buffer_Size = 1024, any value=0);

/**
 * Send a signal to a send & receive curl handle 
 * @ param Handle			hndl			The handle of the send & receive curl to be used.
 * @ param SendRecv_Act		act				The SendRecv_Act action after the singal
 * @ return bool							1 on success. 0 = not a curl_easy_send_recv() curl, or not running/waiting
 */
native bool curl_send_recv_Signal(Handle hndl, SendRecv_Act act);

/**
 * Check send & receive curl handle is Waiting or not
 * @ param Handle			hndl			The handle of the send & receive curl to be used.
 * @ return bool		1 = is waiting. 0 = not a curl_easy_send_recv() curl, or not running/waiting
 */
native bool curl_send_recv_IsWaiting(Handle hndl);

/**
 * Send the send buffer for send & receive curl handle
 * @ param Handle			hndl			The handle of the send & receive curl to be used.
 * @ param cell_t			data			The data to send
 * @ param cell_t			size			if specified the \0 terminator will not be included
 * @ noreturn
 */
native void curl_set_send_buffer(Handle hndl, const char[] data, int size=-1);

/**
 * Send the receive data size for send & receive curl handle
 * @ param Handle			hndl			The handle of the send & receive curl to be used.
 * @ param cell_t			size			The receive size
 * @ noreturn
 */
native void curl_set_receive_size(Handle hndl, int size);

/**
 * Set send timeout for curl_easy_send_recv()
 * @ param Handle			hndl			The handle of the send & receive curl to be used.
 * @ param cell_t			timeout			How long will try to send data before it timeout (milliseconds).
 * @ noreturn
 */
native void curl_set_send_timeout(Handle hndl, int timeout);

/**
 * Set receive timeout for curl_easy_send_recv()
 * @ param Handle			hndl			The handle of the send & receive curl to be used.
 * @ param cell_t			timeout			How long will try to receive data before it timeout (milliseconds).
 * @ noreturn
 */
native void curl_set_recv_timeout(Handle hndl, int timeout);

/**
 * Get CURLOPT_ERRORBUFFER error string in curl handle
 * @ param Handle		hndl		The handle of the curl to be used.
 * @ param String		buffer		Destination string buffer to copy to.
 * @ param cell_t		maxlen		Destination buffer length (includes null terminator).
 * @ noreturn
 */
native void curl_get_error_buffer(Handle hndl, char[] buffer, int maxlen);

/**
 * Extract information from a curl handle. (CURLINFO_STRING only)
 * @ param Handle		hndl		The handle of the curl to be used.
 * @ param CURLINFO		info		The enum CURLINFO, see cURL_header.inc
 * @ param String		buffer		Destination string buffer to copy to.
 * @ param cell_t		maxlen		Destination buffer length (includes null terminator).
 * @ return 						The CURLcode code, see cURL_header.inc
 */
native CURLcode curl_easy_getinfo_string(Handle hndl, CURLINFO info, char[] buffer, int maxlen);

/**
 * Extract information from a curl handle. (CURLINFO_LONG, CURLINFO_DOUBLE only)
 * @ param Handle		hndl		The handle of the curl to be used.
 * @ param CURLINFO		info		The enum CURLINFO, see cURL_header.inc
 * @ param 				value		Variable to store the value.
 * @ return 						The CURLcode code, see cURL_header.inc
 */
native CURLcode curl_easy_getinfo_int(Handle hndl, CURLINFO info, any &value);

/**
 * URL encodes the given string 
 * @ param Handle		hndl		The handle of the curl to be used.
 * @ param String		url			The string to encodes.
 * @ param String		buffer		Destination string buffer to copy to.
 * @ param cell_t		maxlen		Destination buffer length (includes null terminator).
 * @ return 						1 on success.
 */
native bool curl_easy_escape(Handle hndl, const char[] url, char[] buffer, int maxlen);

/**
 * URL decodes the given string 
 * @ param Handle		hndl		The handle of the curl to be used.
 * @ param String		url			The string to dencodes.
 * @ param String		buffer		Destination string buffer to copy to.
 * @ param cell_t		maxlen		Destination buffer length (includes null terminator).
 * @ return 						The output length.
 */
native int curl_easy_unescape(Handle hndl, const char[] url, char[] buffer, int maxlen);

/**
 * Return string describing error code
 * @ param CURLcode		code		The CURLcode code, see cURL_header.inc
 * @ param String		buffer		Destination string buffer to copy to.
 * @ param cell_t		maxlen		Destination buffer length (includes null terminator).
 * @ noreturn
 */
native void curl_easy_strerror(CURLcode code, char[] buffer, int maxlen);

/**
 * Returns the libcurl version string
 * @ param String		buffer		Destination string buffer to copy to.
 * @ param cell_t		maxlen		Destination buffer length (includes null terminator).
 * @ noreturn
 */
native void curl_version(char[] buffer, int maxlen);

/**
 * Returns the libcurl supported protocols string
 * @ param String		buffer		Destination string buffer to copy to.
 * @ param cell_t		maxlen		Destination buffer length (includes null terminator).
 * @ noreturn
 */
native void curl_protocols(char[] buffer, int maxlen);

/**
 * Returns the libcurl supported features
 * @ return			The currently features bits. see CURL_VERSION_*
 */
native int curl_features();

/**
 * This funcitopn same as Sourcemod OpenFile()
 * For the following CUROPT_* only
 * 		CURLOPT_WRITEDATA
 *		CURLOPT_HEADERDATA
 *		CURLOPT_READDATA
 *		CURLOPT_STDERR
 *		CURLOPT_INTERLEAVEDATA
 *
 * @ note
 * 		Should not share to another threaded curl handle.
 *
 * @ param file			File to open.
 * @ param mode			Open mode.
 * @ return				A Handle to the file, INVALID_HANDLE on open error.
 */
native Handle curl_OpenFile(const char[] file, const char[] mode);


/**
 * Create a curl_httppost struct
 * For the following CUROPT_* only
 * 		CURLOPT_HTTPPOST
 * @ note
 * 		Should not share to another threaded curl handle.
 *
 * @ return				A Handle to the curl_httppost, INVALID_HANDLE on error.
 */
native Handle curl_httppost();

/**
 * Add a section to a multipart/formdata HTTP POST
 * @ note
 *		Check enum CURLformoption (cURL_head.inc) to see which option supported
 *
 * @ param Handle		hndl		The handle of the curl_httppost to be used.
 * @ param 				...			Variable number of format parameters.
 * @ return 						The CURLFORMcode code, see cURL_header.inc
 */
native CURLFORMcode curl_formadd(Handle handl, any ...);

/**
 * Create a curl_slist struct
 * For the following CUROPT_* only
 * 		CURLOPT_QUOTE
 *		CURLOPT_HTTPHEADER
 *		CURLOPT_POSTQUOTE
 *		CURLOPT_TELNETOPTIONS
 *		CURLOPT_PREQUOTE
 *		CURLOPT_HTTP200ALIASES
 *		CURLOPT_MAIL_RCPT
 *		CURLOPT_RESOLVE
 *
 * @ note
 * 		Should not share to another threaded curl handle.
 *
 * @ return				A Handle to the curl_slist, INVALID_HANDLE on error.
 */
native Handle curl_slist();

/**
 *  Add a string to an slist
 * @ param Handle		hndl		The handle of the curl_slist to be used.
 * @ param String		buffer		The string to add
 * @ noreturn
 */
native void curl_slist_append(Handle hndl, const char[] buffer);

/**
 * Hash a file
 * @ parma String					file 				The file path. supports the "file //" notation.
 * @ param Openssl_Hash				algorithm			Hash Algorithm.
 * @ param Openssl_Hash_Complete	complete_callback	The complete callback.
 * @ param cell_t					value				Value to set.
 * @ noreturn
 */
native void curl_hash_file(const char[] file, Openssl_Hash algorithm, Openssl_Hash_Complete complete_callback, any value=0);

/**
 * Hash a string
 * @ parma String			input			The string to hash.
 * @ param cell_t			dataSize		The input string size.
 * @ param Openssl_Hash		algorithm		Hash Algorithm.
 * @ param String			buffer			Destination string buffer to copy to.
 * @ param cell_t			maxlen			Destination buffer length (includes null terminator).
 * @ return									1 on success
 */
native bool curl_hash_string(const char[] input, int dataSize, Openssl_Hash algorithm, char[] buffer, int maxlength);


/**
 * Do not edit below this line!
 */
public Extension __ext_curl = {
	name = "curl",
	file = "curl.ext",
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
