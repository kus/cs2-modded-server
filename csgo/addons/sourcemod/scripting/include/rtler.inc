// code by alongub https://github.com/alongubkin/

#if defined _rtler_included
 #endinput
#endif
#define _rtler_included

#pragma semicolon 1

/**
 * Converts a string that contains words in RTL languages to be displayed correctly in-game.
 *
 * @param dest 			Destination string buffer to copy the RTL-ed string to.
 * @param destLen		Destination buffer length (includes null terminator).
 * @param original		Original non-rtled string.
 *
 * @return The amount of words that needed RTLifying.
 */
native int RTLify(char[] dest, int destLen, const char[] original);

public SharedPlugin __pl_rtler =
{
	name = "rtler",
	file = "rtler.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public void __pl_rtler_SetNTVOptional()
{
	MarkNativeAsOptional("RTLify");
}
