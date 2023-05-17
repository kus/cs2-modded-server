/**
 * -----------------------------------------------------
 * File        request.inc
 * Authors     David Ordnung
 * License     GPLv3
 * Web         http://dordnung.de
 * -----------------------------------------------------
 * 
 * Copyright (C) 2013-2018 David Ordnung
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */

#if defined _system2_request_included
    #endinput
#endif

#define _system2_request_included


/**
 *
 * API for making HTTP and FTP requests.
 *
 */


/**
 * A list of possible HTTP request methods.
 */
enum HTTPRequestMethod
{
    METHOD_GET,
    METHOD_POST,
    METHOD_PUT,
    METHOD_PATCH,
    METHOD_DELETE,
    METHOD_HEAD
}

/**
 * A list of possible HTTP versions.
 */
enum HTTPVersion
{
    VERSION_NONE,
    VERSION_1_0,
    VERSION_1_1,
    VERSION_2_0
}


/**
 * Called when a HTTP request was finished.
 *
 * The response will only be valid in the callback and will be destroyed afterwards.
 * The request is a copy of the original request and will be destroyed afterwards.
 * The request can be modified and made again.
 *
 * @param success       Whether the request could made.
 *                      This not means that the request itself was successful, check the StatusCode of the response for that!
 * @param error         If success is false this will contain the error message.
 * @param request       A copy of the made HTTP request.
 *                      Can't be deleted, as it will be destroyed after the callback!
 * @param response      HTTP response of the request. Is null if success is false.
 *                      Can't be deleted, as it will be destroyed after the callback!
 * @param method        The HTTP request method that was made.
 *
 * @noreturn
 */
typeset System2HTTPResponseCallback
{
    function void (bool success, const char[] error, System2HTTPRequest request, System2HTTPResponse response, HTTPRequestMethod method);
};

/**
 * Called when a FTP request was finished.
 *
 * The response will only be valid in the callback and will be destroyed afterwards.
 * The request is a copy of the original request and will be destroyed afterwards.
 * The request can be modified and made again.
 *
 * @param success       Whether the request could made.
 *                      This not means that the request itself was successful, check the StatusCode of the response for that!
 * @param error         If success is false this will contain the error message.
 * @param request       A copy of the made FTP request.
 *                      Can't be deleted, as it will be destroyed after the callback!
 * @param response      FTP response of the request. Is null if success is false.
 *                      Can't be deleted, as it will be destroyed after the callback!
 *
 * @noreturn
 */
typeset System2FTPResponseCallback
{
    function void (bool success, const char[] error, System2FTPRequest request, System2FTPResponse response);
};


/**
 * Called on a frequent interval while data of a HTTP request is being transferred.
 * The request is a copy of the original request and will be destroyed afterwards.
 *
 * @param request       A copy of the made HTTP request.
 *                      Can't be deleted, as it will be destroyed after the callback!
 * @param dlTotal       Total expected download size in bytes.
 * @param dlNow         Downloaded bytes so far.
 * @param ulTotal       Total expected upload size in bytes.
 * @param ulNow         Uploaded bytes so far.
 *
 * @noreturn
 */
typeset System2HTTPProgressCallback
{
    function void (System2HTTPRequest request, int dlTotal, int dlNow, int ulTotal, int ulNow);
};

/**
 * Called on a frequent interval while data of a FTP request is being transferred.
 * The request is a copy of the original request and will be destroyed afterwards.
 *
 * @param request       A copy of the made FTP request.
 *                      Can't be deleted, as it will be destroyed after the callback!
 * @param dlTotal       Total expected download size in bytes.
 * @param dlNow         Downloaded bytes so far.
 * @param ulTotal       Total expected upload size in bytes.
 * @param ulNow         Uploaded bytes so far.
 *
 * @noreturn
 */
typeset System2FTPProgressCallback
{
    function void (System2FTPRequest request, int dlTotal, int dlNow, int ulTotal, int ulNow);
};



/**
 * Basic methodmap for a request.
 * Use System2HTTPRequest or System2FTPRequest to actually create a request.
 */
methodmap System2Request < Handle {
    /**
     * Sets the URL of the request.
     * Query parameters have to be given directly in the URL.
     *
     * Must be URL-encoded (use System2_URLEncode) in the following format:
     * scheme://host:port/path
     *
     * Host is a hostname or dotted numerical IP address. A numerical IPv6 address must be written within [brackets].
     *
     * If the given URL is missing a scheme name (such as "http://" or "ftp://" etc)
     * then system2 will make a guess based on the host.
     *
     * @param url       URL to use for the request.
     * @param ...       URL format arguments.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetURL(const char[] url, any ...);

    /**
     * Retrieves the URL of the request.
     *
     * @param url       Buffer to store URL in.
     * @param maxlength Maxlength of the buffer.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void GetURL(char[] url, int maxlength);

    /**
     * Sets the remote port number to connect to,
     * instead of the one specified in the URL or the default port for the used protocol
     *
     * @param port      Port to use for the request.
     *
     * @noreturn
     * @error           Invalid request.
     * @error           Invalid port number.
     */
    public native void SetPort(int port);

    /**
     * Returns the port of the request.
     *
     * @return          The port of the request or 0 if none set.
     * @error           Invalid request.
     */
    public native int GetPort();

    /**
     * Sets the path to the file to which the output of the request will be written to.
     * Use this to download the output of a response to a file.
     *
     * @param file      File to write the output to.
     * @param ...       File format arguments.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetOutputFile(const char[] file, any ...);

    /**
     * Retrieves the path to the file to which the output of the request will be written to.
     *
     * @param file      Buffer to store file in.
     * @param maxlength Maxlength of the buffer.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void GetOutputFile(char[] file, int maxlength);

    /**
     * Sets whether to verify authenticity of the peer's certificate and server cert is for the server it is known as.
     * Only disable this, when you know what you do!
     *
     * @param verify    True to verify SSL certificates, otherwise false.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetVerifySSL(bool verify);

    /**
     * Returns whether SSL certificates will be verified.
     *
     * @return          True if SSL certificates will be verified, otherwise false.
     * @error           Invalid request.
     */
    public native bool GetVerifySSL();

    /**
     * Sets proxy for the request.
     *
     * @param proxy         Hostname or dotted numerical IP address. A numerical IPv6 address must be written within [brackets].
     *                      To specify port number in this string, append :[port] to the end of the host name (default: 1080).
     *                      The proxy string may be prefixed with [scheme]:// to specify which kind of proxy is used.
     *                      http://
     *                      HTTP Proxy. Default when no scheme is specified.
     *                      https://
     *                      HTTPS Proxy.
     *                      socks4://
     *                      SOCKS4 Proxy.
     *                      socks4a://
     *                      SOCKS4a Proxy. Proxy resolves URL hostname.
     *                      socks5://
     *                      SOCKS5 Proxy.
     *                      socks5h://
     *                      SOCKS5 Proxy. Proxy resolves URL hostname.
     * @param useHttpTunnel Tunnel all operations through the HTTP proxy (use http or https)-
     *                      Tunneling means that an HTTP CONNECT request is sent to the proxy, asking it to connect to a remote host
     *                      on a specific port number and then the traffic is just passed through the proxy. Proxies tend to white-list
    *                       specific port numbers it allows CONNECT requests to and often only port 80 and 443 are allowed.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetProxy(const char[] proxy, bool useHttpTunnel = false);

    /**
     * Sets the username and password to be used in protocol authentication with the proxy.
     *
     * @param username  Username to use for proxy authentication.
     * @param password  Password to use for proxy authentication.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetProxyAuthentication(const char[] username, const char[] password)


    property int Timeout {
        /**
         * Returns the timeout for the request.
         * By default, there is no timeout.
         *
         * @return          The timeout of the request in seconds or -1 if none set.
         * @error           Invalid request.
         */
        public native get();

        /**
         * Sets the timeout for the request in seconds.
         * By default, there is no timeout.
         *
         * @param seconds   The timeout for the request in seconds. 0 to disable.
         *
         * @noreturn
         * @error           Invalid request.
         * @error           Invalid timeout.
         */
        public native set(int seconds);
    }

    property any Any {
        /**
         * Returns the any data that was bound to this request.
         *
         * @return          The any data that was bound or 0 if none set.
         * @error           Invalid request.
         */
        public native get();

        /**
         * Sets any data to bind to the request (which you can then use in callbacks).
         *
         * @param Any       The any data to bind.
         *
         * @noreturn
         * @error           Invalid request.
         */
        public native set(any Any);
    }
}


/**
 * Methodmap to create a HTTP request.
 */
methodmap System2HTTPRequest < System2Request {
    /**
     * Creates a new HTTP Request.
     *
     * @param callback  Response callback to call when the request is finished.
     * @param url       URL to use for the request.
     *                  Query parameters have to be given directly in the URL.
     *
     *                  Must be URL-encoded (use System2_URLEncode) in the following format:
     *                  scheme://host:port/path
     *
     *                  Host is a hostname or dotted numerical IP address. A numerical IPv6 address must be written within [brackets].
     *                  If no scheme is given, HTTP will be used.
     * @param ...       URL format arguments.
     *
     * @noreturn
     * @error           Couldn't create request.
     */
    public native System2HTTPRequest(System2HTTPResponseCallback callback, const char[] url, any ...);

    /**
     * Sets the progress callback for the transfer of the request.
     * This will be called frequently while data is being transferred.
     * This is useful when downloading or uploading stuff.
     *
     * @param callback  Progress callback to call for the transfer.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetProgressCallback(System2HTTPProgressCallback callback);


    /**
     * Sets the body data to send with the request.
     * You must make sure that the data is formatted the way you want the server to receive it.
     * Use System2_URLEncode to encode the data.
     *
     * For example:  parameter=value&parameter2=value2
     * Or with JSON: {"parameter": "value", "parameter2": "value2"}
     *
     * @param data      Body data to send with the request.
     * @param ...       Data format arguments.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetData(const char[] data, any ...);

    /**
     * Retrieves the body data of the request.
     *
     * @param url       Buffer to store data in.
     * @param maxlength Maxlength of the buffer.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void GetData(char[] data, int maxlength);


    /**
     * Sets a HTTP request header.
     * Use System2_URLEncode to encode the header.
     *
     * @param name      Name of the header.
     * @param value     Value to set the header to.
     * @param ...       Value format arguments.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetHeader(const char[] header, const char[] value, any ...);

    /**
     * Retrieves a HTTP request header.
     *
     * @param name      Name of the header to retrieve.
     * @param value     Buffer to store value in.
     * @param maxlength Maxlength of the buffer.
     *
     * @return          True if header was set, otherwise false.
     * @error           Invalid request.
     */
    public native bool GetHeader(const char[] header, char[] value, int maxlength);

    /**
     * Retrieves the name of a header at a given index.
     * Use Headers property to retrieve the maximum index.
     *
     * @param index     Index of the header name.
     * @param name      Buffer to store name in.
     * @param maxlength Maxlength of the buffer.
     *
     * @return          True if header was found, otherwise false.
     * @error           Invalid request.
     */
    public native bool GetHeaderName(int index, char[] name, int maxlength);

    property int Headers {
        /**
         * Returns the number of set headers.
         *
         * @return      The number of set headers.
         * @error       Invalid response.
         */
        public native get();
    }

    /**
     * Returns all set header names of the request as ArrayList.
     * Attention: ArrayList has to be deleted after use!

     * @param maxlength Maxlength of a header.
     *
     * @return          ArrayList with all set request header names. Must be deleted afterwards!
     * @error           Invalid request.
     */
    public ArrayList GetHeaders(int maxlength = 256) {
        ArrayList headers = new ArrayList(maxlength);

        char[] headerName = new char[maxlength];
        for (int i=0; i < this.Headers; i++) {
            this.GetHeaderName(i, headerName, maxlength);
            headers.PushString(headerName);
        }

        return headers;
    }


    /**
     * Sets the user agent for the request.
     * This will set the User-Agent header to the given value.
     *
     * @param userAgent User agent to use.
     * @param ...       User agent format arguments.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetUserAgent(const char[] userAgent, any ...);

    /**
     * Sets basic authentication username and passowrd for the request.
     * This will set the Authorization header to the given values.
     *
     * @param username  Username to use for basic authentication.
     * @param password  Password to use for basic authentication.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetBasicAuthentication(const char[] username, const char[] password);

    /**
     * Sends the request with the HTTP GET method.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void GET();

    /**
     * Sends the request with the HTTP POST method.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void POST();
    
    /**
     * Sends the request with the HTTP PUT method.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void PUT();
    
    /**
     * Sends the request with the HTTP PATCH method.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void PATCH();
    
    /**
     * Sends the request with the HTTP DELETE method.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void DELETE();
    
    /**
     * Sends the request with the HTTP HEAD method.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void HEAD();


    property bool FollowRedirects {
        /**
         * Returns whether the request follow redirects or not.
         * By default, redirects will be followed.
         *
         * @return          True if it follow redirects, otherwise false.
         * @error           Invalid request.
         */
        public native get();

        /**
         * Sets to follow any Location: header that the server sends as part of an HTTP header in a 3xx response.
         * For 301, 302 and 303 responses system2 will switch method to GET. All other 3xx codes will make system2 send the same method again.
         * By default, redirects will be followed.
         *
         * @param follow    True to follow redirects, otherwise false.
         *
         * @noreturn
         * @error           Invalid request.
         */
        public native set(bool follow);
    }
}


/**
 * Methodmap to create a FTP request.
 */
methodmap System2FTPRequest < System2Request {
    /**
     * Creates a new FTP Request.
     *
     * @param callback  Response callback to call when the request is finished.
     * @param url       URL to use for the request.
     *
     *                  Must be URL-encoded (use System2_URLEncode) in the following format:
     *                  scheme://host:port/path
     *
     *                  Host is a hostname or dotted numerical IP address. A numerical IPv6 address must be written within [brackets].
     *                  If no scheme is given, FTP will be used.
     * @param ...       URL format arguments.
     *
     * @noreturn
     * @error           Couldn't create request.
     */
    public native System2FTPRequest(System2FTPResponseCallback callback, const char[] url, any ...);

    /**
     * Sets the progress callback for the transfer of the request.
     * This will be called frequently while data is being transferred.
     *
     * @param callback  Progress callback to call for the transfer.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetProgressCallback(System2FTPProgressCallback callback);


    /**
     * Sets authentication needed to access the FTP server.
     *
     * @param username  Username to use for authentication.
     * @param password  Password to use for authentication.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetAuthentication(const char[] username, const char[] password);


    /**
     * Sets the path to the file which should be uploaded.
     * If this is set, an upload approach will be used.
     *
     * @param file      File to upload.
     * @param ...       File format arguments.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void SetInputFile(const char[] file, any ...);

    /**
     * Retrieves the path to the file which should be uploaded.
     *
     * @param file      Buffer to store file in.
     * @param maxlength Maxlength of the buffer.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void GetInputFile(char[] file, int maxlength);


    /**
     * Starts the request.
     *
     * If a input file is set the request will upload this file.
     * Otherwise it may result in a directory listing or a file download.
     *
     * @noreturn
     * @error           Invalid request.
     */
    public native void StartRequest();


    property bool AppendToFile {
        /**
         * Returns whether the request appends to the FTP file or replaces it when uploading a file.
         * By default, the file will be replaced.
         *
         * @return          True if it appends to the file, false if the file will be replaced.
         * @error           Invalid request.
         */
        public native get();

        /**
         * Sets whether to append to the FTP file or to replace it when uploading a file.
         * By default, the file will be replaced.
         *
         * @param append    True to append to file, false to replace it.
         *
         * @noreturn
         * @error           Invalid request.
         */
        public native set(bool append);
    }

    property bool CreateMissingDirs {
        /**
         * Returns whether the request creates missing dirs when uploading a file.
         * By default, missing dirs will be created.
         *
         * @return          True if it creates missing dirs, otherwise false.
         * @error           Invalid request.
         */
        public native get();

        /**
         * Sets whether to create any remote directory that it fails to "move" into.
         * By default, missing dirs will be created.
         *
         * @param create    True to create missing dirs, otherwise false.
         *
         * @noreturn
         * @error           Invalid request.
         */
        public native set(bool create);
    }

    property bool ListFilenamesOnly {
        /**
         * Returns whether only file names should be fetched for directory listing.
         * By default, all information will be fetched.
         *
         * @return          True if only file names should be fetched, false for full directory listing.
         * @error           Invalid request.
         */
        public native get();

        /**
         * Sets whether to list the names of files in a directory,
         * rather than performing a full directory listing that would normally include file sizes, dates etc.
         * By default, all information will be fetched.
         *
         * @param append    True if only file names should be fetched, false for full directory listing.
         *
         * @noreturn
         * @error           Invalid request.
         */
        public native set(bool append);
    }
}



/**
 * Basic methodmap for a response of a request.
 */
methodmap System2Response < Handle {
    /**
     * Retrieves the last used effective URL.
     * This may differ from the request URL, if a redirect was followed.
     *
     * @param url       Buffer to store last URL in.
     * @param maxlength Maxlength of the URL buffer.
     *
     * @noreturn
     * @error           Invalid response.
     */
    public native void GetLastURL(char[] url, int maxlength);

    /**
     * Retrieves the content of the response.
     * This shouldn't be used when retrieved binary stuff.
     *
     * @param content   Buffer to store the content in.
     * @param maxlength Maxlength of the content buffer.
     * @param start     Start byte to start reading from.
     *                  You can use this to retrieve the content step by step.
     * @param delimiter Delimiter until which the content should be retrieved.
     * @param include   Whether the delimiter should be included or not.
     *
     * @return          Number of read bytes.
     * @error           Invalid response.
     */
    public native int GetContent(char[] content, int maxlength, int start = 0, const char[] delimiter = "", bool include = true);


    property int ContentLength {
        /**
         * Returns the length of the complete response content.
         *
         * @return      Length of the content.
         * @error       Invalid response.
         */
        public native get();
    }

    property int StatusCode {
        /**
         * Returns the status code of the response.
         *
         * @return      The status code.
         * @error       Invalid response.
         */
        public native get();
    }

    property float TotalTime {
        /**
         * Returns the total time from the request until the response in seconds.
         * Includs name resolving, TCP connect etc.
         *
         * @return      Total time from the request until the response in seconds.
         * @error       Invalid response.
         */
        public native get();
    }

    property int DownloadSize {
        /**
         * Returns the total amount of bytes that were downloaded.
         * This counts actual payload data, what's also commonly called body.
         * All meta and header data are excluded and will not be counted in this number.
         *
         * @return      Total amount of bytes that were downloaded.
         * @error       Invalid response.
         */
        public native get();
    }

    property int UploadSize {
        /**
         * Returns the total amount of bytes that were uploaded.
         *
         * @return      Total amount of bytes that were uploaded.
         * @error       Invalid response.
         */
        public native get();
    }

    property int DownloadSpeed {
        /**
         * Returns the average download speed measured for the complete download in bytes per second.
         *
         * @return      Average download speed in bytes per second.
         * @error       Invalid response.
         */
        public native get();
    }

    property int UploadSpeed {
        /**
         * Returns the average upload speed measured for the complete upload in bytes per second.
         *
         * @return      Average upload speed in bytes per second.
         * @error       Invalid response.
         */
        public native get();
    }
}


/**
 * Methodmap for a response of a HTTP request.
 */
methodmap System2HTTPResponse < System2Response {
    /**
     * Retrieves the content type of the response.
     * This is the value read from the Content-Type header.
     *
     * @param type      Buffer to store content type in.
     * @param maxlength Maxlength of the buffer.
     *
     * @noreturn
     * @error           Invalid response.
     */
    public native void GetContentType(const char[] type, int maxlength);

    /**
     * Retrieves a HTTP response header
     *
     * @param name      Name of the header to retrieve.
     * @param value     Buffer to store value in.
     * @param maxlength Maxlength of the buffer.
     *
     * @return          True if header was set, otherwise false.
     * @error           Invalid response.
     */
    public native bool GetHeader(const char[] name, char[] value, int maxlength);

    /**
     * Retrieves the name of a header at a given index.
     * Use Headers property to retrieve the maximum index.
     *
     * @param index     Index of the header name.
     * @param name      Buffer to store name in.
     * @param maxlength Maxlength of the buffer.
     *
     * @return          True if header was found, otherwise false.
     * @error           Invalid response.
     */
    public native bool GetHeaderName(int index, char[] name, int maxlength);

    property int Headers {
        /**
         * Returns the number of set headers in the response.
         *
         * @return      The number of set headers.
         * @error       Invalid response.
         */
        public native get();
    }

    /**
     * Returns all header set names of the response as ArrayList.
     * Attention: ArrayList has to be deleted after use!

     * @param maxlength Maxlength of a header.
     *
     * @return          ArrayList with all set response header names. Must be deleted!
     * @error           Invalid request.
     */
    public ArrayList GetHeaders(int maxlength = 256) {
        ArrayList headers = new ArrayList(maxlength);

        char[] headerName = new char[maxlength];
        for (int i=0; i < this.Headers; i++) {
            this.GetHeaderName(i, headerName, maxlength);
            headers.PushString(headerName);
        }

        return headers;
    }


    property HTTPVersion HTTPVersion {
        /**
         * Returns the HTTP version of the response.
         *
         * @return      The HTTP version.
         * @error       Invalid response.
         */
        public native get();
    }
}


/**
 * Methodmap for a response of a FTP request.
 * Currently there are no special methods for that.
 */
methodmap System2FTPResponse < System2Response {
}



/**
 * Converts a plain string to an URL encoded string.
 * All input characters that are not a-z, A-Z, 0-9, '-', '.', '_' or '~' 
 * are converted to their "URL escaped" version (%NN where NN is a two-digit hexadecimal number).
 *
 * Be aware that the output string may be larger then the input string.
 *
 * @param output        Buffer to store encoded string in. May point to the input string (will replace the input string).
 * @param maxlength     Maxlength of the output buffer.
 * @param input         String to encode.
 * @param ...           Input string format arguments
 *
 * @return              True on success, false otherwise.
 */
native bool System2_URLEncode(char[] output, int maxlength, const char[] input, any ...);

/**
 * Converts an URL encoded string to a plain string.
 * All input characters that are URL encoded (%XX where XX is a two-digit hexadecimal number) are converted to their binary versions.
 *
 * @param output        Buffer to store decoded string in. May point to the input string (will replace the input string).
 * @param maxlength     Maxlength of the output buffer.
 * @param input         String to decode.
 * @param ...           Input string format arguments
 *
 * @return              True on success, false otherwise.
 */
native bool System2_URLDecode(char[] output, int maxlength, const char[] input, any ...);