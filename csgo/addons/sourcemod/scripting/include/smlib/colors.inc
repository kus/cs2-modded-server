#if defined _smlib_colors_included
	#endinput
#endif
#define _smlib_colors_included

#include <sourcemod>
#include <smlib/arrays>
#include <smlib/teams>

#define CHATCOLOR_NOSUBJECT -2
#define SMLIB_COLORS_GAMEDATAFILE "smlib_colors.games"

enum ChatColorSubjectType
{
	ChatColorSubjectType_none		= -3,

	// Subject/Team colors
	ChatColorSubjectType_player		= -2,
	ChatColorSubjectType_undefined	= -1,
	ChatColorSubjectType_world		= 0
	// Anything higher is a specific team
}

enum ChatColorInfo
{
	ChatColorInfo_Code,
	ChatColorInfo_Alternative,
	bool:ChatColorInfo_Supported,
	ChatColorSubjectType:ChatColorInfo_SubjectType
};

enum ChatColor
{
	ChatColor_Normal,
	ChatColor_Orange,
	ChatColor_Red,
	ChatColor_RedBlue,
	ChatColor_Blue,
	ChatColor_BlueRed,
	ChatColor_Team,
	ChatColor_Lightgreen,
	ChatColor_Gray,
	ChatColor_Green,
	ChatColor_Olivegreen,
	ChatColor_Black
}

static String:chatColorTags[][] = {
	"N",	// Normal
	"O",	// Orange
	"R",	// Red
	"RB",	// Red, Blue
	"B",	// Blue
	"BR",	// Blue, Red
	"T",	// Team
	"L",	// Light green
	"GRA",	// GRAy 
	"G",	// Green
	"OG",	// Olive green
	"BLA"	// BLAck
};

static String:chatColorNames[][] = {
	"normal",		// Normal
	"orange",		// Orange
	"red",			// Red
	"redblue",		// Red, Blue
	"blue",			// Blue
	"bluered",		// Blue, Red
	"team",			// Team
	"lightgreen",	// Light green
	"gray",			// GRAy 
	"green",		// Green
	"olivegreen",	// Olive green
	"black"			// BLAck
};

static chatColorInfo[][ChatColorInfo] =
{
	// Code , alternative	, Is Supported?	Chat color subject type 		   Color name
	{ '\x01', -1/* None	 */	, true,			ChatColorSubjectType_none,	},	// Normal
	{ '\x01', 0	/* None	 */	, true,			ChatColorSubjectType_none,	},	// Orange
	{ '\x03', 9	/* Green */	, true,			ChatColorSubjectType:2		},	// Red
	{ '\x03', 4	/* Blue	 */	, true,			ChatColorSubjectType:2		},	// Red, Blue
	{ '\x03', 9	/* Green */	, true,			ChatColorSubjectType:3		},	// Blue
	{ '\x03', 2	/* Red	 */	, true,			ChatColorSubjectType:3		},	// Blue, Red
	{ '\x03', 9	/* Green */	, true,			ChatColorSubjectType_player	},	// Team
	{ '\x03', 9	/* Green */	, true,			ChatColorSubjectType_world	},	// Light green
	{ '\x03', 9	/* Green */	, true,			ChatColorSubjectType_undefined},// GRAy 
	{ '\x04', 0	/* Normal*/	, true,			ChatColorSubjectType_none	},	// Green
	{ '\x05', 9	/* Green */	, true,			ChatColorSubjectType_none	},	// Olive green
	{ '\x06', 9	/* Green */	, true,			ChatColorSubjectType_none	}	// BLAck
};

static bool:checkTeamPlay			= false;
static Handle:mp_teamplay			= INVALID_HANDLE;
static bool:isSayText2_supported	= true;
static chatSubject					= CHATCOLOR_NOSUBJECT;

/**
 * Sets the subject (a client) for the chat color parser.
 * Call this before Color_ParseChatText() or Client_PrintToChat().
 *
 * @param client			Client Index/Subject
 * @noreturn
 */
stock Color_ChatSetSubject(client)
{
	chatSubject = client;
}

/**
 * Gets the subject used for the chat color parser.
 *
 * @return					Client Index/Subject, or CHATCOLOR_NOSUBJECT if none
 */
stock Color_ChatGetSubject()
{
	return chatSubject;
}

/**
 * Clears the subject used for the chat color parser.
 * Call this after Color_ParseChatText().
 *
 * @noreturn
 */
stock Color_ChatClearSubject()
{
	chatSubject = CHATCOLOR_NOSUBJECT;
}

/**
 * Parses a chat string and converts all color tags to color codes.
 * This is a very powerful function that works recursively over the color information
 * table. The support colors are hardcoded, but can be overriden for each game by
 * creating the file gamedata/smlib_colors.games.txt.
 *
 * @param str				Chat String
 * @param subject			Output Buffer
 * @param size				Output Buffer size
 * @return					Returns a value for the subject
 */
stock Color_ParseChatText(const String:str[], String:buffer[], size)
{
	new
		bool:inBracket = false,
		x = 0, x_buf = 0, x_tag = 0,
		subject = CHATCOLOR_NOSUBJECT;

	decl
		String:sTag[10]         = "",     // This should be able to hold "\x08RRGGBBAA"\0
		String:colorCode[10]    = "",     // This should be able to hold "\x08RRGGBBAA"\0
		String:currentColor[10] = "\x01"; // Initialize with normal color

	size--;

	// Every chat message has to start with a
	// color code, otherwise it will ignore all colors.
	buffer[x_buf++] = '\x01';

	while (str[x] != '\0') {

		if (size == x_buf) {
			break;
		}

		new character = str[x++];
		
		if (inBracket) {
			// We allow up to 9 characters in the tag (#RRGGBBAA)
			if (character == '}' || x_tag > 9) {
				inBracket   = false;
				sTag[x_tag] = '\0';
				x_tag       = 0;

				if (character == '}') {
					Color_TagToCode(sTag, subject, colorCode);

					if (colorCode[0] == '\0') {
						// We got an unknown tag, ignore this
						// and forward it to the buffer.

						// Terminate buffer with \0 so Format can handle it.
						buffer[x_buf] = '\0';
						x_buf = Format(buffer, size, "%s{%s}", buffer, sTag);

						// We 'r done here
						continue;
					}
					else if (!StrEqual(colorCode, currentColor)) {
						// If we are already using this color,
						// we don't need to set it again.

						// Write the color code to our buffer.
						// x_buf will be increased by the number of cells written.
						x_buf += strcopy(buffer[x_buf], size - x_buf, colorCode);

						// Remember the current color.
						strcopy(currentColor, sizeof(currentColor), colorCode);
					}
				}
				else {
					// If the tag character limit exceeds 9,
					// we have to do something.

					// Terminate buffer with \0 so Format can handle it.
					buffer[x_buf] = '\0';
					x_buf = Format(buffer, size, "%s{%s%c", buffer, sTag, character);
				}
			}
			else if (character == '{' && !x_tag) {
				buffer[x_buf++] = '{';
				inBracket = false;
			}
			else {
				sTag[x_tag++] = character;
			}
		}
		else if (character == '{') {
			inBracket = true;
		}
		else {
			buffer[x_buf++] = character;
		}
	}

	// Write remaining text to the buffer,
	// if we have been inside brackets.
	if (inBracket) {
		buffer[x_buf] = '\0';
		x_buf = Format(buffer, size, "%s{%s", buffer, sTag);
	}

	buffer[x_buf] = '\0';
	
	return subject;
}

/**
 * Converts a chat color tag to its code character.
 *
 * @param tag				Color Tag String.
 * @param subject			Subject variable to pass
 * @param result            The result as character sequence (string). This will be \0 if the tag is unkown.
 * @noreturn
 */
stock Color_TagToCode(const String:tag[], &subject=-1, String:result[10])
{
	// Check if the tag starts with a '#'.
	// We will handle it has RGB(A)-color code then.
	if (tag[0] == '#') {
		new length_tag = strlen(tag);
		switch (length_tag - 1) {
			// #RGB      -> \07RRGGBB
			case 3: {
				FormatEx(
					result, sizeof(result), "\x07%c%c%c%c%c%c",
					tag[1], tag[1], tag[2], tag[2], tag[3], tag[3]
				);
			}
			// #RGBA     -> \08RRGGBBAA
			case 4: {
				FormatEx(
					result, sizeof(result), "\x08%c%c%c%c%c%c%c%c",
					tag[1], tag[1], tag[2], tag[2], tag[3], tag[3], tag[4], tag[4]
				);
			}
			// #RRGGBB   -> \07RRGGBB
			case 6: {
				FormatEx(result, sizeof(result), "\x07%s", tag[1]);
			}
			// #RRGGBBAA -> \08RRGGBBAA
			case 8: {
				FormatEx(result, sizeof(result), "\x08%s", tag[1]);
			}
			default: {
				result[0] = '\0';
			}
		}

		return;
	}
	else {
		// Try to handle this string as color name
		new n = Array_FindString(chatColorTags, sizeof(chatColorTags), tag);

		// Check if this tag is invalid
		if (n == -1) {
			result[0] = '\0';
			return;
		}

		// Check if the color is actually supported 'n stuff.
		Color_GetChatColorInfo(n, subject);

		result[0] = chatColorInfo[n][ChatColorInfo_Code];
		result[1] = '\0';
	}

	return;
}

/**
 * Strips all color control characters in a string.
 * The Output buffer can be the same as the input buffer.
 * Original code by Psychonic, thanks.
 *
 * @param input				Input String.
 * @param output			Output String.
 * @param size				Max Size of the Output string
 * @noreturn
 */
stock Color_StripFromChatText(const String:input[], String:output[], size)
{
	new x = 0;
	for (new i=0; input[i] != '\0'; i++) {
	
		if (x+1 == size) {
			break;
		}

		new character = input[i];
		
		if (character > 0x08) {
			output[x++] = character;
		}
	}
	
	output[x] = '\0';
}

/**
 * Checks the gamename and sets default values.
 * For example if some colors are supported, or
 * if a game uses another color code for a specific color.
 * All those hardcoded default values can be overriden in
 * smlib's color gamedata file.
 *
 * @noreturn
 */
static stock Color_ChatInitialize()
{
	static initialized = false;

	if (initialized) {
		return;
	}

	initialized = true;

	decl String:gameFolderName[32];
	GetGameFolderName(gameFolderName, sizeof(gameFolderName));

	chatColorInfo[ChatColor_Black][ChatColorInfo_Supported]		    = false;

	if (strncmp(gameFolderName, "left4dead", 9, false) != 0 &&
		!StrEqual(gameFolderName, "cstrike", false) &&
		!StrEqual(gameFolderName, "tf", false))
	{
		chatColorInfo[ChatColor_Lightgreen][ChatColorInfo_Supported]= false;
		chatColorInfo[ChatColor_Gray][ChatColorInfo_Supported]		= false;
	}

	if (StrEqual(gameFolderName, "tf", false)) {
		chatColorInfo[ChatColor_Black][ChatColorInfo_Supported]		= true;

		chatColorInfo[ChatColor_Gray][ChatColorInfo_Code]			= '\x01';
		chatColorInfo[ChatColor_Gray][ChatColorInfo_SubjectType]	= ChatColorSubjectType_none;
	}
	else if (strncmp(gameFolderName, "left4dead", 9, false) == 0) {
		chatColorInfo[ChatColor_Red][ChatColorInfo_SubjectType]		= ChatColorSubjectType:3;
		chatColorInfo[ChatColor_RedBlue][ChatColorInfo_SubjectType]	= ChatColorSubjectType:3;
		chatColorInfo[ChatColor_Blue][ChatColorInfo_SubjectType]	= ChatColorSubjectType:2;
		chatColorInfo[ChatColor_BlueRed][ChatColorInfo_SubjectType]	= ChatColorSubjectType:2;

		chatColorInfo[ChatColor_Orange][ChatColorInfo_Code]			= '\x04';
		chatColorInfo[ChatColor_Green][ChatColorInfo_Code]			= '\x05';
	}
	else if (StrEqual(gameFolderName, "hl2mp", false)) {
		chatColorInfo[ChatColor_Red][ChatColorInfo_SubjectType]		= ChatColorSubjectType:3;
		chatColorInfo[ChatColor_RedBlue][ChatColorInfo_SubjectType]	= ChatColorSubjectType:3;
		chatColorInfo[ChatColor_Blue][ChatColorInfo_SubjectType]	= ChatColorSubjectType:2;
		chatColorInfo[ChatColor_BlueRed][ChatColorInfo_SubjectType]	= ChatColorSubjectType:2;
		chatColorInfo[ChatColor_Black][ChatColorInfo_Supported]		= true;

		checkTeamPlay												= true;
	}
	else if (StrEqual(gameFolderName, "dod", false)) {
		chatColorInfo[ChatColor_Gray][ChatColorInfo_Code]			= '\x01';
		chatColorInfo[ChatColor_Gray][ChatColorInfo_SubjectType]	= ChatColorSubjectType_none;

		chatColorInfo[ChatColor_Black][ChatColorInfo_Supported]		= true;
		chatColorInfo[ChatColor_Orange][ChatColorInfo_Supported]	= false;
	}

	if (GetUserMessageId("SayText2") == INVALID_MESSAGE_ID) {
		isSayText2_supported = false;
	}

	decl String:path_gamedata[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path_gamedata, sizeof(path_gamedata), "gamedata/%s.txt", SMLIB_COLORS_GAMEDATAFILE);

	if (FileExists(path_gamedata)) {
		new Handle:gamedata = INVALID_HANDLE;
		
		if ((gamedata = LoadGameConfigFile(SMLIB_COLORS_GAMEDATAFILE)) != INVALID_HANDLE) {

			decl String:keyName[32], String:buffer[6];
			
			for (new i=0; i < sizeof(chatColorNames); i++) {

				Format(keyName, sizeof(keyName), "%s_code",			chatColorNames[i]);
				if (GameConfGetKeyValue(gamedata, keyName, buffer, sizeof(buffer))) {
					chatColorInfo[i][ChatColorInfo_Code]			= StringToInt(buffer);
				}

				Format(keyName, sizeof(keyName), "%s_alternative",	chatColorNames[i]);
				if (GameConfGetKeyValue(gamedata, keyName, buffer, sizeof(buffer))) {
					chatColorInfo[i][ChatColorInfo_Alternative]		= buffer[0];
				}

				Format(keyName, sizeof(keyName), "%s_supported",	chatColorNames[i]);
				if (GameConfGetKeyValue(gamedata, keyName, buffer, sizeof(buffer))) {
					chatColorInfo[i][ChatColorInfo_Supported]		= StrEqual(buffer, "true");
				}

				Format(keyName, sizeof(keyName), "%s_subjecttype",	chatColorNames[i]);
				if (GameConfGetKeyValue(gamedata, keyName, buffer, sizeof(buffer))) {
					chatColorInfo[i][ChatColorInfo_SubjectType]		= ChatColorSubjectType:StringToInt(buffer);
				}
			}

			if (GameConfGetKeyValue(gamedata, "checkteamplay", buffer, sizeof(buffer))) {
				checkTeamPlay = StrEqual(buffer, "true");
			}

			CloseHandle(gamedata);
		}
	}

	mp_teamplay = FindConVar("mp_teamplay");
}

/**
 * Checks if the passed color index is actually supported
 * for the current game. If not, the index will be overwritten
 * The color resolving works recursively until a valid color is found.
 * 
 * @param index
 * @param subject A client index or CHATCOLOR_NOSUBJECT
 * @noreturn
 */
static stock Color_GetChatColorInfo(&index, &subject=CHATCOLOR_NOSUBJECT)
{
	Color_ChatInitialize();

	if (index == -1) {
		index = 0;
	}

	while (!chatColorInfo[index][ChatColorInfo_Supported]) {

		new alternative = chatColorInfo[index][ChatColorInfo_Alternative];

		if (alternative == -1) {
			index = 0;
			break;
		}

		index = alternative;
	}

	if (index == -1) {
		index = 0;
	}

	new newSubject = CHATCOLOR_NOSUBJECT;
	new ChatColorSubjectType:type = chatColorInfo[index][ChatColorInfo_SubjectType];

	switch (type) {

		case ChatColorSubjectType_none: {
		}
		case ChatColorSubjectType_player: {
			newSubject = chatSubject;
		}
		case ChatColorSubjectType_undefined: {
			newSubject = -1;
		}
		case ChatColorSubjectType_world: {
			newSubject = 0;
		}
		default: {

			if (!checkTeamPlay || GetConVarBool(mp_teamplay)) {

				if (subject > 0 && subject <= MaxClients) {

					if (GetClientTeam(subject) == _:type) {
						newSubject = subject;
					}
				}
				else if (subject == CHATCOLOR_NOSUBJECT) {
					new client = Team_GetAnyClient(_:type);

					if (client != -1) {
						newSubject = client;
					}
				}
			}
		}
	}

	if (type > ChatColorSubjectType_none &&
		((subject != CHATCOLOR_NOSUBJECT && subject != newSubject) || newSubject == CHATCOLOR_NOSUBJECT || !isSayText2_supported))
	{
		index = chatColorInfo[index][ChatColorInfo_Alternative];
		newSubject = Color_GetChatColorInfo(index, subject);
	}

	// Only set the subject if there is no subject set already.
	if (subject == CHATCOLOR_NOSUBJECT) {
		subject = newSubject;
	}
	
	return newSubject;
}
