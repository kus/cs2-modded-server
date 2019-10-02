#if defined _smlib_server_included
	#endinput
#endif
#define _smlib_server_included

#include <sourcemod>
#include <smlib/general>

/*
 * Gets the server's public/external (default) or
 * private/local (usually server's behind a NAT) IP.
 * If your server is behind a NAT Router, you need the SteamTools
 * extension available at http://forums.alliedmods.net/showthread.php?t=129763
 * to get the public IP. <steamtools> has to be included BEFORE <smlib>.
 * If the server is not behind NAT, the public IP is the same as the private IP.
 * 
 * @param public		Set to true to retrieve the server's public/external IP, false otherwise.
 * @return				Long IP or 0 if the IP couldn't be retrieved.
 */
stock Server_GetIP(bool:public_=true)
{
	new ip = 0;

	static Handle:cvHostip = INVALID_HANDLE;

	if (cvHostip == INVALID_HANDLE) {
		cvHostip = FindConVar("hostip");
		MarkNativeAsOptional("Steam_GetPublicIP");
	}

	if (cvHostip != INVALID_HANDLE) {
		ip = GetConVarInt(cvHostip);
	}

	if (ip != 0 && IsIPLocal(ip) == public_) {
		ip = 0;
	}

#if defined _steamtools_included
	if (ip == 0) {
		if (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "Steam_GetPublicIP") == FeatureStatus_Available) {
			decl octets[4];
			Steam_GetPublicIP(octets);

			ip =
				octets[0] << 24	|
				octets[1] << 16	|
				octets[2] << 8	|
				octets[3];

			if (IsIPLocal(ip) == public_) {
				ip = 0;
			}
		}
	}
#endif

	return ip;
}

/*
 * Gets the server's public/external (default) or
 * private/local (usually server's behind a NAT) as IP String in dotted format.
 * If your server is behind a NAT Router, you need the SteamTools
 * extension available at http://forums.alliedmods.net/showthread.php?t=129763
 * to get the public IP. <steamtools> has to be included BEFORE <smlib>.
 * If the public IP couldn't be found, an empty String is returned.
 * If the server is not behind NAT, the public IP is the same as the private IP.
 * 
 * @param buffer		String buffer (size=16)
 * @param size			String buffer size.
 * @param public		Set to true to retrieve the server's public/external IP, false otherwise.
 * @return				True on success, false otherwise.
 */
stock bool:Server_GetIPString(String:buffer[], size, bool:public_=true)
{
	new ip;
	
	if ((ip = Server_GetIP(public_)) == 0) {
		buffer[0] = '\0';
		return false;
	}

	LongToIP(ip, buffer, size);

	return true;
}

/*
 * Gets the server's local port.
 *
 * @noparam
 * @return			The server's port, 0 if there is no port.
 */
stock Server_GetPort()
{
	static Handle:cvHostport = INVALID_HANDLE;
	
	if (cvHostport == INVALID_HANDLE) {
		cvHostport = FindConVar("hostport");
	}

	if (cvHostport == INVALID_HANDLE) {
		return 0;
	}

	new port = GetConVarInt(cvHostport);

	return port;
}

/*
 * Gets the server's hostname
 *
 * @param hostname		String buffer
 * @param size			String buffer size
 * @return				True on success, false otherwise.
 */
stock bool:Server_GetHostName(String:buffer[], size)
{	
	static Handle:cvHostname = INVALID_HANDLE;
	
	if (cvHostname == INVALID_HANDLE) {
		cvHostname = FindConVar("hostname");
	}

	if (cvHostname == INVALID_HANDLE) {
		buffer[0] = '\0';
		return false;
	}

	GetConVarString(cvHostname, buffer, size);

	return true;
}
