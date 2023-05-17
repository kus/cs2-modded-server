#if defined _voiceannounceex_included_
	#endinput
#endif
#define _voiceannounceex_included_

public SharedPlugin __pl_voiceannounceex =
{
	name = "voiceannounce_ex",
	file = "voiceannounce_ex.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public void __pl_voiceannounceex_SetNTVOptional()
{
	MarkNativeAsOptional("IsClientSpeaking");
}

/**
 *
 * Checks whether a client is speaking or not.
 *
 * @param client 	The client index to check against.
 *
 * @error 			Client is not valid, ingame, or client is a bot.
 *
 * @return 			True if client is speaking, false otherwise.
 *
 */

native bool IsClientSpeaking(int client);

/**
 *
 * Called when a client is speaking.
 *
 * @noreturn
 *
 */

forward void OnClientSpeakingEx(int client);

/**
 *
 * Called when a client end of speaking.
 *
 * @param client	The index of the client.
 *
 * @noreturn
 *
 */
forward void OnClientSpeakingEnd(int client);
