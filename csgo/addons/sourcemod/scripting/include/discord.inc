#if defined _discord_included
 #endinput
#endif
#define _discord_included

native void Discord_SendMessage(const char[] webhook, const char[] message);

public SharedPlugin __pl_discord =
{
	name = "discord",
	file = "discord.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN

public __pl_discord_SetNTVOptional()
{
	MarkNativeAsOptional("Discord_SendMessage");
}

#endif

stock void Discord_EscapeString(char[] string, int maxlen)
{
	ReplaceString(string, maxlen, "@", "＠");
	ReplaceString(string, maxlen, "'", "＇");
	ReplaceString(string, maxlen, "\"", "＂");
}
