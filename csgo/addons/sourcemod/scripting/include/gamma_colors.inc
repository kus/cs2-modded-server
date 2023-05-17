#if defined _gammacolors_included
	#endinput
#endif
#define _gammacolors_included

/*	Colors .inc by GAMMACASE;
*	ver 1.1.0
*/	

#define COLORS 14
#define MAX_MESSAGE_LENGTH 512

char g_sColorNames[][] = {"{DEFAULT}", "{RED}", "{LIGHTPURPLE}", "{GREEN}", "{LIME}", "{LIGHTGREEN}", "{LIGHTRED}", "{GRAY}", "{LIGHTOLIVE}", "{LIGHTBLUE}", "{BLUE}", "{PURPLE}", "{DARKORANGE}", "{GOLD}"},
	g_sColorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06", "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E", "\x0F", "\x10"};
 
char g_sShortColorNames[][] = {"{D}", "{R}", "{LP}", "{G}", "{LM}", "{LG}", "{LR}", "{GR}", "{LO}", "{LB}", "{B}", "{P}", "{DO}", "{GL}"},
	g_sShortColorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06", "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E", "\x0F", "\x10"};

stock void GCPrintToChat(int client, const char[] format, any ...)
{
	char buff[MAX_MESSAGE_LENGTH];
	VFormat(buff, sizeof(buff), format, 3);
	
	for(int i = 0; i < COLORS; i++) 
	{
		ReplaceString(buff, sizeof(buff), g_sColorNames[i], g_sColorCodes[i], false);
		ReplaceString(buff, sizeof(buff), g_sShortColorNames[i], g_sShortColorCodes[i], false);
	}
	
	PrintToChat(client, "%s%s", (buff[0] == ' ' ? "" : " "), buff);
}

stock void GCPrintToChatAll(const char[] format, any ...)
{
	char buff[MAX_MESSAGE_LENGTH];
	VFormat(buff, sizeof(buff), format, 2);
	
	for(int i = 0; i < COLORS; i++) 
	{
		ReplaceString(buff, sizeof(buff), g_sColorNames[i], g_sColorCodes[i], false);
		ReplaceString(buff, sizeof(buff), g_sShortColorNames[i], g_sShortColorCodes[i], false);
	}
	
	PrintToChatAll("%s%s", (buff[0] == ' ' ? "" : " "), buff);
}

stock void GCReplyToCommand(int client, const char[] format, any ...)
{
	char buff[MAX_MESSAGE_LENGTH];
	VFormat(buff, sizeof(buff), format, 3);
	
	for(int i = 0; i < COLORS; i++) 
	{
		ReplaceString(buff, sizeof(buff), g_sColorNames[i], g_sColorCodes[i], false);
		ReplaceString(buff, sizeof(buff), g_sShortColorNames[i], g_sShortColorCodes[i], false);
	}
	
	ReplyToCommand(client, "%s%s", ((buff[0] == ' ' || GetCmdReplySource() == SM_REPLY_TO_CONSOLE) ? "" : " "), buff);
}

stock void GCShowActivity(int client, const char[] format, any ...)
{
	char buff[MAX_MESSAGE_LENGTH];
	VFormat(buff, sizeof(buff), format, 3);
	
	for(int i = 0; i < COLORS; i++) 
	{
		ReplaceString(buff, sizeof(buff), g_sColorNames[i], g_sColorCodes[i], false);
		ReplaceString(buff, sizeof(buff), g_sShortColorNames[i], g_sShortColorCodes[i], false);
	}
	
	ShowActivity(client, "%s%s", (buff[0] == ' ' ? "" : " "), buff);
}

stock void GCShowActivity2(int client, const char[] tag, const char[] format, any ...)
{
	char buff[MAX_MESSAGE_LENGTH];
	VFormat(buff, sizeof(buff), format, 4);
	
	for(int i = 0; i < COLORS; i++) 
	{
		ReplaceString(buff, sizeof(buff), g_sColorNames[i], g_sColorCodes[i], false);
		ReplaceString(buff, sizeof(buff), g_sShortColorNames[i], g_sShortColorCodes[i], false);
	}
	
	ShowActivity2(client, "%s%s", tag, buff);
}