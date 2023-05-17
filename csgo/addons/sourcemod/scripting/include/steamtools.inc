#if defined _steamtools_included
#endinput
#endif
#define _steamtools_included

#define USE_CUSTOM_STEAMID -1

/**
 * Called after SteamTools has completely finished loading.
 * No features are available before this point.
 *
 * @noreturn
 */
forward void Steam_FullyLoaded();
forward void Steam_Shutdown();


/**
 * Gets the current status of VAC on the server.
 *
 * @return A bool representing the current VAC status.
 */
native bool Steam_IsVACEnabled();

/**
 * Gets the server's external IP address, as reported by Steam.
 *
 * @param octets Reference to an array to be filled with the octets of
 *               the IP address.
 *
 * @noreturn
 */
native void Steam_GetPublicIP(int octets[4]);


/**
 * Is fired when the Steam master servers report that your server is
 * outdated
 *
 * @return Plugin_Continue to continue normal operation or Plugin_Handled
 *         to block the regular console message.
 */
forward Action Steam_RestartRequested();


/**
 * Requests a client's status in a Steam group.
 * Response is returned in Steam_GroupStatusResult forward.
 *
 * @param client         Client index.
 * @param groupAccountID 32-bit account ID of group.
 *
 * @return A bool representing whether or not the request was sent to
 *         Steam.
 */
native bool Steam_RequestGroupStatus(int client, int groupAccountID);

/**
 * Called when a response to a group status request is recieved.
 * This is called for all responses recieved, not just ones requested by
 * your plugin.
 *
 * @param client         Client index.
 * @param groupAccountID 32-bit account ID of group. Make sure to check
 *                       this agaist the ID you are expecting.
 * @param groupMember    Whether or not the client is a member in the
 *                       specified group.
 * @param groupMember    Whether or not the client is an officer in the
 *                       specified group.
 *
 * @noreturn
 */
forward void Steam_GroupStatusResult(int client, int groupAccountID, bool groupMember, bool groupOfficer);

#pragma deprecated No longer operational
native void Steam_RequestGameplayStats();
forward void Steam_GameplayStats(int rank, int totalConnects, int totalMinutesPlayed);

#pragma deprecated No longer operational
native void Steam_RequestServerReputation();
forward void Steam_Reputation(int reputationScore, bool banned, int bannedIP, int bannedPort, int bannedGameID, int banExpires);


/**
 * Gets the current Steam connection state, the forwards below fire
 * whenever this changes.
 *
 * @return Steam connection state.
 */
native bool Steam_IsConnected();

/**
 * Fired upon a successfull connection to Steam.
 * Is also fired for late-loaded plugins.
 *
 * @noreturn
 */
forward void Steam_SteamServersConnected();

/**
 * Fired upon disconnection from Steam.
 * Is also fired for late-loaded plugins.
 *
 * For plugins loaded with the server, this will normally be fired right
 * after Steam_FullyLoaded, closly followed by Steam_SteamServersConnected
 * if a successfull connection is established.
 *
 * @noreturn
 */
forward void Steam_SteamServersDisconnected();

/**
 * Sets an entry in the server's list of rules. This list is used to
 * build the response to the A2S_RULES query and is generally known as
 * the list of public convars.
 *
 * @param key   Name of the key to set, is created if it does not already
 *              exist.
 * @param value Value of the key to set, the named key is removed if this
 *              is blank.
 *
 * @noreturn
 */
native void Steam_SetRule(const char[] key, const char[] value);

/**
 * Clears the server's list of rules. This list is used to build the
 * response to the A2S_RULES query and is generally known as the list of
 * public convars.
 *
 * @noreturn
 */
native void Steam_ClearRules();


native void Steam_ForceHeartbeat();

#pragma deprecated No longer operational
native bool Steam_AddMasterServer(const char[] serverAddress);
#pragma deprecated No longer operational
native bool Steam_RemoveMasterServer(const char[] serverAddress);
#pragma deprecated No longer operational
native int Steam_GetNumMasterServers();
#pragma deprecated No longer operational
native void Steam_GetMasterServerAddress(int server, char[] serverAddress, int maxlength);

native void Steam_SetGameDescription(char[] gameDescription);

native void Steam_RequestStats(int client);
forward void Steam_StatsReceived(int client);
forward void Steam_StatsUnloaded(int client);
native int Steam_GetStat(int client, const char[] statName);
native float Steam_GetStatFloat(int client, const char[] statName);
native bool Steam_IsAchieved(int client, const char[] achievementName);


native int Steam_GetNumClientSubscriptions(int client);
native int Steam_GetClientSubscription(int client, int index);

native int Steam_GetNumClientDLCs(int client);
native int Steam_GetClientDLC(int client, int index);

stock bool Steam_CheckClientSubscription(int client, int subid)
{
	int subCount = Steam_GetNumClientSubscriptions(client);
	for (int x = 0; x < subCount; x++)
	{
		if (Steam_GetClientSubscription(client, x) == subid)
		{
			return true;
		}
	}

	return false;
}

stock bool Steam_CheckClientDLC(int client, int appid)
{
	int subCount = Steam_GetNumClientDLCs(client);
	for (int x = 0; x < subCount; x++)
	{
		if (Steam_GetClientDLC(client, x) == appid)
		{
			return true;
		}
	}

	return false;
}

native void Steam_GetCSteamIDForClient(int client, char[] steamID, int maxlength);

native bool Steam_SetCustomSteamID(const char[] renderedID);
native bool Steam_GetCustomSteamID(char[] renderedID, int maxlength);

native void Steam_RenderedIDToCSteamID(const char[] renderedID, char[] steamID, int maxlength);
native void Steam_CSteamIDToRenderedID(const char[] steamID, char[] renderedID, int maxlength);

native void Steam_GroupIDToCSteamID(int groupID, char[] steamID, int maxlength);
native void Steam_CSteamIDToGroupID(const char[] steamID);

enum HTTPRequestHandle
{
	INVALID_HTTP_HANDLE = 0,
};

enum HTTPMethod
{
	HTTPMethod_Invalid = 0,
	HTTPMethod_GET,
	HTTPMethod_HEAD,
	HTTPMethod_POST,
};

enum HTTPStatusCode
{
	HTTPStatusCode_Invalid =						0,

	// Informational codes
	HTTPStatusCode_Continue =						100,
	HTTPStatusCode_SwitchingProtocols =				101,

	// Success codes
	HTTPStatusCode_OK =								200,
	HTTPStatusCode_Created =						201,
	HTTPStatusCode_Accepted =						202,
	HTTPStatusCode_NonAuthoritative =				203,
	HTTPStatusCode_NoContent =						204,
	HTTPStatusCode_ResetContent =					205,
	HTTPStatusCode_PartialContent =					206,

	// Redirection codes
	HTTPStatusCode_MultipleChoices =				300,
	HTTPStatusCode_MovedPermanently =				301,
	HTTPStatusCode_Found =							302,
	HTTPStatusCode_SeeOther =						303,
	HTTPStatusCode_NotModified =					304,
	HTTPStatusCode_UseProxy =						305,
	HTTPStatusCode_TemporaryRedirect =				307,

	// Error codes
	HTTPStatusCode_BadRequest =						400,
	HTTPStatusCode_Unauthorized =					401,
	HTTPStatusCode_PaymentRequired =				402,
	HTTPStatusCode_Forbidden =						403,
	HTTPStatusCode_NotFound =						404,
	HTTPStatusCode_MethodNotAllowed =				405,
	HTTPStatusCode_NotAcceptable =					406,
	HTTPStatusCode_ProxyAuthRequired =				407,
	HTTPStatusCode_RequestTimeout =					408,
	HTTPStatusCode_Conflict =						409,
	HTTPStatusCode_Gone =							410,
	HTTPStatusCode_LengthRequired =					411,
	HTTPStatusCode_PreconditionFailed =				412,
	HTTPStatusCode_RequestEntityTooLarge =			413,
	HTTPStatusCode_RequestURITooLong =				414,
	HTTPStatusCode_UnsupportedMediaType =			415,
	HTTPStatusCode_RequestedRangeNotSatisfiable =	416,
	HTTPStatusCode_ExpectationFailed =				417,

	// Server error codes
	HTTPStatusCode_InternalServerError =			500,
	HTTPStatusCode_NotImplemented =					501,
	HTTPStatusCode_BadGateway =						502,
	HTTPStatusCode_ServiceUnavailable =				503,
	HTTPStatusCode_GatewayTimeout =					504,
	HTTPStatusCode_HTTPVersionNotSupported =		505,
};

typeset HTTPRequestComplete
{
	function void(HTTPRequestHandle HTTPRequest, bool requestSuccessful, HTTPStatusCode statusCode);
	function void(HTTPRequestHandle HTTPRequest, bool requestSuccessful, HTTPStatusCode statusCode, any contextData);
};

native HTTPRequestHandle Steam_CreateHTTPRequest(HTTPMethod HTTPRequestMethod, const char[] absoluteURL);
native void Steam_SetHTTPRequestNetworkActivityTimeout(HTTPRequestHandle HTTPRequest, int timeoutSeconds);
native void Steam_SetHTTPRequestHeaderValue(HTTPRequestHandle HTTPRequest, const char[] headerName, const char[] headerValue);
native void Steam_SetHTTPRequestGetOrPostParameter(HTTPRequestHandle HTTPRequest, const char[] paramName, const char[] paramValue);
native bool Steam_SendHTTPRequest(HTTPRequestHandle HTTPRequest, HTTPRequestComplete callbackFunction, any contextData = 0);
native void Steam_DeferHTTPRequest(HTTPRequestHandle HTTPRequest);
native void Steam_PrioritizeHTTPRequest(HTTPRequestHandle HTTPRequest);
native int Steam_GetHTTPResponseHeaderSize(HTTPRequestHandle HTTPRequest, const char[] headerName);
native void Steam_GetHTTPResponseHeaderValue(HTTPRequestHandle HTTPRequest, const char[] headerName, char[] headerValueBuffer, int bufferSize);
native int Steam_GetHTTPResponseBodySize(HTTPRequestHandle HTTPRequest);
native void Steam_GetHTTPResponseBodyData(HTTPRequestHandle HTTPRequest, char[] bodyDataBuffer, int bufferSize);
native void Steam_WriteHTTPResponseBody(HTTPRequestHandle HTTPRequest, const char[] filePath);
native void Steam_ReleaseHTTPRequest(HTTPRequestHandle HTTPRequest);
native float Steam_GetHTTPDownloadProgressPercent(HTTPRequestHandle HTTPRequest);
native bool Steam_SetHTTPRequestRawPostBody(HTTPRequestHandle HTTPRequest, const char[] data, int dataLength, const char[] contentType="text/plain");
native bool Steam_SetHTTPRequestRawPostBodyFile(HTTPRequestHandle HTTPRequest, const char[] filePath, const char[] contentType="text/plain");

public Extension __ext_SteamTools =
{
	name = "SteamTools",
	file = "steamtools.ext",
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
}
