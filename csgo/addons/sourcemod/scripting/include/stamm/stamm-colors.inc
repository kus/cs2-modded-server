#if defined _stamm_colors_included
	#endinput
#endif
#define _stamm_colors_included

#include <morecolors_stamm>
#include <colors>


/* Global var to check whether colors are fixed or not */
new bool:g_bStammColorsFixed = false;





/**
 * Writes a message to a client with the correct stock for the game.
 *
 * @param client        Client index.
 * @param message       Message (formatting rules).
 *
 * @noreturn
 * @error               If the client is not connected an error will be thrown.
 */
stock STAMM_PrintToChat(client, const String:message[], any:...)
{
	decl String:buffer[MAX_MESSAGE_LENGTH_MORE];

	VFormat(buffer, sizeof(buffer), message, 3);


	if (!g_bStammColorsFixed)
	{
		STAMM_FixColors();
	}


	if (STAMM_GetGame() == GameCSGO)
	{
		CPrintToChat(client, buffer);
	}
	else
	{
		MCPrintToChat(client, buffer);
	}
}



/**
 * Writes a message to all clients with the correct stock for the game.
 *
 * @param message       Message (formatting rules).
 *
 * @noreturn
 */
stock STAMM_PrintToChatAll(const String:message[], any:...)
{
	decl String:buffer[MAX_MESSAGE_LENGTH_MORE];

	VFormat(buffer, sizeof(buffer), message, 2);


	if (!g_bStammColorsFixed)
	{
		STAMM_FixColors();
	}


	if (STAMM_GetGame() == GameCSGO)
	{
		CPrintToChatAll(buffer);
	}
	else
	{
		MCPrintToChatAll(buffer);
	}
}





/**
 * Writes a message to a client with the correct stock for the game.
 *
 * @param client        Client index.
 * @param author        Author index.
 * @param message       Message (formatting rules).
 *
 * @noreturn
 * @error               If the client is not connected an error will be thrown.
 */
stock STAMM_PrintToChatEx(client, author, const String:message[], any:...)
{
	decl String:buffer[MAX_MESSAGE_LENGTH_MORE];

	VFormat(buffer, sizeof(buffer), message, 4);


	if (!g_bStammColorsFixed)
	{
		STAMM_FixColors();
	}
	

	if (STAMM_GetGame() == GameCSGO)
	{
		CPrintToChatEx(client, author, buffer);
	}
	else
	{
		MCPrintToChatEx(client, author, buffer);
	}
}



/**
 * Writes a message to all clients with the correct stock for the game.
 *
 * @param author        Author index.
 * @param message       Message (formatting rules).
 *
 * @noreturn
 */
stock STAMM_PrintToChatAllEx(author, const String:message[], any:...)
{
	decl String:buffer[MAX_MESSAGE_LENGTH_MORE];

	VFormat(buffer, sizeof(buffer), message, 3);


	if (!g_bStammColorsFixed)
	{
		STAMM_FixColors();
	}


	if (STAMM_GetGame() == GameCSGO)
	{
		CPrintToChatAllEx(author, buffer);
	}
	else
	{
		MCPrintToChatAllEx(author, buffer);
	}
}



/**
 * Replaces color tags in a string with color codes
 *
 * @param message       String.
 * @param maxlength     Maximum length of the string buffer.
 *
 * @noreturn
 */
stock STAMM_FormatColor(String:message[], maxlength, author=-1)
{
	if (!g_bStammColorsFixed)
	{
		STAMM_FixColors();
	}


	if (STAMM_GetGame() == GameCSGO)
	{
		if (author == 0)
		{
			author = -1;
		}

		CFormat(message, maxlength, author);
	}
	else
	{
		if (author == -1)
		{
			author = 0;
		}

		MCReplaceColorCodes(message, author, false, maxlength);
	}
}



/**
 * Returns whether you can use morecolors or not,
 *
 * @return       True when morecolors allowed, otherwise false.
 */
stock bool:STAMM_IsMoreColorsAvailable()
{
	return STAMM_GetGame() != GameCSGO;
}



/**
 * Fixes missing Lightgreen color.
 *
 * @noreturn
 */
stock STAMM_FixColors()
{
	g_bStammColorsFixed = true;

	// Replace lightgreen if not exists
	if (!CColorAllowed(Color_Lightgreen))
	{
		if (CColorAllowed(Color_Lime))
		{
			CReplaceColor(Color_Lightgreen, Color_Lime);
		}
		else if (CColorAllowed(Color_Olive))
		{
			CReplaceColor(Color_Lightgreen, Color_Olive);
		}
	}
}