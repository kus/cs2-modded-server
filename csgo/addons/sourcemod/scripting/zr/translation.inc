/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  translation.inc
 *  Type:		  Core
 *  Description:   Translation parsing functions.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/**
 * @section Max length of different message formats.
 */
#define TRANSLATION_MAX_LENGTH_CHAT 192
#define TRANSLATION_MAX_LENGTH_CONSOLE 1024
/**
 * @endsection
 */

/**
 * Prefix on all messages printed from the plugin.
 */
#define TRANSLATION_PHRASE_PREFIX "[ZR]"

/**
 * @section Text color chars.
 */
#define TRANSLATION_TEXT_COLOR_DEFAULT "\x01"
#define TRANSLATION_TEXT_COLOR_LGREEN "\x05"
#define TRANSLATION_TEXT_COLOR_GREEN "\x04"
/**
 * @endsection
 */

/**
 * Load translations file here.
 */
void TranslationInit()
{
	// Load translations phrases used by plugin.
	LoadTranslations("common.phrases.txt");
	LoadTranslations("core.phrases.txt");
	LoadTranslations("zombiereloaded.phrases.txt");
}

/**
 * Translate a phrase in zombiereloaded.phrases.txt
 * 
 * @param client		The client index
 * @param translation   The translated text.
 * @param maxlen		Maximum length of the translated string.
 * @param ...		   Translation formatting parameters.  
 */
stock void TranslationTranslatePhrase(int client, char[] translation, int maxlen, any ...)
{
	// Set translation target to given target.
	SetGlobalTransTarget(client);
	
	// Dump translation into return string.
	VFormat(translation, maxlen, "%t", 3);
}

/**
 * Format the string to the plugin's style.
 * 
 * @param text	  Text to format.
 * @param maxlen	Maximum length of the formatted text.
 */
stock void TranslationPluginFormatString(char[] text, int maxlen, bool color = true)
{
	if (color)
	{
		// Format prefix onto the string.
		Format(text, maxlen, " @green%s @default%s", TRANSLATION_PHRASE_PREFIX, text);
		
		// Replace color tokens with CS:S color chars.
		ReplaceString(text, maxlen, "@default", TRANSLATION_TEXT_COLOR_DEFAULT);
		ReplaceString(text, maxlen, "@lgreen", TRANSLATION_TEXT_COLOR_LGREEN);
		ReplaceString(text, maxlen, "@green", TRANSLATION_TEXT_COLOR_GREEN);
		
		return;
	}
	
	// Format prefix onto the string.
	Format(text, maxlen, "%s %s", TRANSLATION_PHRASE_PREFIX, text);
}

/**
 * Print chat text to client. (with style)
 * 
 * @param client	The client index.
 * @param ...	   Translation formatting parameters.  
 */
stock void TranslationPrintToChat(int client, any ...)
{
	// Set translation target
	SetGlobalTransTarget(client);
	
	// Translate phrase.
	char translation[TRANSLATION_MAX_LENGTH_CHAT];
	VFormat(translation, sizeof(translation), "%t", 2);
	
	// Format string to create plugin style.
	TranslationPluginFormatString(translation, sizeof(translation));
	
	// Print translated phrase to client.
	PrintToChat(client, translation);
}

/**
 * Format the string to the plugin's style.
 * 
 * @param server	True to also print text to server console, false just to clients.
 * @param admin	 True to only print text to admins, false to print to everyone.
 * @param ...	   Translation formatting parameters.
 */
stock void TranslationPrintToChatAll(bool server, bool admin, any ...)
{
	char translation[TRANSLATION_MAX_LENGTH_CHAT];
	
	if (server)
	{
		// Set translation target
		SetGlobalTransTarget(LANG_SERVER);
		
		// Translate phrase.
		VFormat(translation, sizeof(translation), "%t", 3);
		
		// Format string to create plugin style.
		TranslationPluginFormatString(translation, sizeof(translation), false);
		
		// Print phrase to server.
		PrintToServer(translation);
	}
	
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If client isn't an admin, and we're only printing to admins, then stop.
		if (admin && !ZRIsClientAdmin(x))
		{
			continue;
		}
		
		// Set translation target to client.
		SetGlobalTransTarget(x);
		
		// Translate phrase.
		VFormat(translation, sizeof(translation), "%t", 3);
		
		// Format string to create plugin style.
		TranslationPluginFormatString(translation, sizeof(translation));
		
		// Print translated phrase to client.
		PrintToChat(x, translation);
	}
}

/**
 * Print console text to client. (with style)
 * 
 * @param client	The client index.
 * @param ...	   Translation formatting parameters.  
 */
stock void TranslationPrintToConsole(int client, any ...)
{
	// Set translation target
	SetGlobalTransTarget(client);
	
	// Translate phrase.
	char translation[TRANSLATION_MAX_LENGTH_CONSOLE];
	VFormat(translation, sizeof(translation), "%t", 2);
	
	// Format string to create plugin style.
	TranslationPluginFormatString(translation, sizeof(translation), false);
	
	// Print translated phrase to client.
	PrintToConsole(client, translation);
}

/**
 * Format the string to the plugin's style.
 * 
 * @param server	True to also print text to server console, false just to clients.
 * @param ...	   Translation formatting parameters.
 */
stock void TranslationPrintToConsoleAll(bool server, bool admin, any ...)
{
	char translation[TRANSLATION_MAX_LENGTH_CONSOLE];
	
	if (server)
	{
		// Set translation target
		SetGlobalTransTarget(LANG_SERVER);
		
		// Translate phrase.
		VFormat(translation, sizeof(translation), "%t", 3);
		
		// Format string to create plugin style.
		TranslationPluginFormatString(translation, sizeof(translation), false);
		
		// Print phrase to server.
		PrintToServer(translation);
	}
	
	// x = client index.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (!IsClientInGame(x))
		{
			continue;
		}
		
		// If client isn't an admin, and we're only printing to admins, then stop.
		if (admin && !ZRIsClientAdmin(x))
		{
			continue;
		}
		
		// Set translation target
		SetGlobalTransTarget(LANG_SERVER);
		
		// Translate phrase.
		VFormat(translation, sizeof(translation), "%t", 3);
		
		// Format string to create plugin style.
		TranslationPluginFormatString(translation, sizeof(translation), false);
		
		// Print translated phrase to client.
		PrintToConsole(x, translation);
	}
}

/**
 * Print center text to client. (with style)
 * 
 * @param client	The client index.
 * @param ...	   Translation formatting parameters.  
 */
stock void TranslationPrintCenterText(int client, any ...)
{
	// Set translation target
	SetGlobalTransTarget(client);
	
	// Translate phrase.
	char translation[TRANSLATION_MAX_LENGTH_CHAT];
	VFormat(translation, sizeof(translation), "%t", 2);
	
	// Print translated phrase to client.
	PrintCenterText(client, translation);
}

/**
 * Print center text to all clients. (with style)
 * 
 * @param client	The client index.
 * @param ...	   Translation formatting parameters.  
 */
stock void TranslationPrintCenterTextAll(bool admin, any ...)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		// Skip clients not in game.
		if (!IsClientInGame(client))
		{
			continue;
		}
		
		// Skip clients who haven't selected a team yet (team menu open).
		if (GetClientTeam(client) == CS_TEAM_NONE)
		{
			continue;
		}
		
		// Skip non-admins if only printing to admins.
		if (admin && !ZRIsClientAdmin(client))
		{
			continue;
		}
		
		// Set translation target
		SetGlobalTransTarget(client);
		
		// Translate phrase.
		char translation[TRANSLATION_MAX_LENGTH_CHAT];
		VFormat(translation, sizeof(translation), "%t", 2);
		
		// Print translated phrase to client.
		PrintCenterText(client, translation);
	}
}

/**
 * Print HUD text to client. (with style)
 * 
 * @param client	The client index.
 * @param ...	   Translation formatting parameters.  
 */
stock void TranslationPrintHintText(int client, any ...)
{
	// Set translation target
	SetGlobalTransTarget(client);
	
	// Translate phrase.
	char translation[TRANSLATION_MAX_LENGTH_CHAT];
	VFormat(translation, sizeof(translation), "%t", 2);
	
	// Print translated phrase to client.
	PrintHintText(client, translation);
	
	// Stop hint text sound in CS:S.
	if (g_Game == Game_CSS)
	{
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	}
}

/**
 * Print text to server. (with style)
 * 
 * @param ...	   Translation formatting parameters.  
 */
stock void TranslationPrintToServer(any ...)
{
	// Set translation target
	SetGlobalTransTarget(LANG_SERVER);
	
	// Translate phrase.
	char translation[TRANSLATION_MAX_LENGTH_CONSOLE];
	VFormat(translation, sizeof(translation), "%t", 1);
	
	// Format string to create plugin style.
	TranslationPluginFormatString(translation, sizeof(translation), false);
	
	// Print translated phrase to client.
	PrintToServer(translation);
}

/**
 * Print chat text to client. (with style)
 * 
 * @param client	The client index.
 * @param ...	   Translation formatting parameters.  
 */
stock void TranslationReplyToCommand(int client, any ...)
{
	// Set translation target
	SetGlobalTransTarget(client);
	
	// Translate phrase.
	char translation[TRANSLATION_MAX_LENGTH_CONSOLE];
	VFormat(translation, sizeof(translation), "%t", 2);
	
	if (ZRIsClientValid(client))
	{
		// Format string to create plugin style. (color)
		TranslationPluginFormatString(translation, sizeof(translation));
	}
	else
	{
		// Format string to create plugin style. (no color)
		TranslationPluginFormatString(translation, sizeof(translation), false);
	}
	
	// Print translated phrase to server or client's chat/console.
	ReplyToCommand(client, translation);
}
