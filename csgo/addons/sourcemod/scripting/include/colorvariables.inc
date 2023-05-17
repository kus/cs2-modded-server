#if defined _colorvariables_included
	#endinput
#endif
#define _colorvariables_included "1.3"

// Author: Raska aka KissLick
// Syntax update: Keith Warren (Drixevel) (redwerewolf on Allied Mods)

// ----------------------------------------------------------------------------------------
#define _CV_MAX_MESSAGE_LENGTH 		1024
#define _CV_MAX_VARIABLE_REDIRECTS 	10
#define _CV_CONFIG_DIRECTORY 		"configs/colorvariables"

static bool g_bInit = false;
static Handle g_hColors = INVALID_HANDLE;
static char g_sConfigGlobal[PLATFORM_MAX_PATH];
static char g_sConfig[PLATFORM_MAX_PATH];
static char g_sChatPrefix[64] = "";

static bool g_bIgnorePrefix = false;
static int g_iAuthor;
static bool g_bSkipPlayers[MAXPLAYERS + 1] = {false, ...};

static Handle g_hForwardedVariable;

enum triple {
	unknown = -1,
	yes = true,
	no = false
};
static triple g_IsSource2009 = unknown;
// ----------------------------------------------------------------------------------------

forward void COnForwardedVariable(char[] sCode, char[] sData, int iDataSize, char[] sColor, int iColorSize);

stock void CSetPrefix(const char[] sPrefix, any ...)
{
	VFormat(g_sChatPrefix, sizeof(g_sChatPrefix), sPrefix, 2);
}

stock void CSavePrefix(const char[] sPrefix, any ...)
{
	char m_sPrefix[64];
	VFormat(m_sPrefix, sizeof(m_sPrefix), sPrefix, 2);

	CAddVariable("&prefix", m_sPrefix, true);
}

stock void CSkipNextPrefix()
{
	g_bIgnorePrefix = true;
}

stock void CSetNextAuthor(int iClient)
{
	if (iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient)) {
		ThrowError("Invalid client index %i", iClient);
	}
	g_iAuthor = iClient;
}

stock void CSkipNextClient(int iClient)
{
	if (iClient < 1 || iClient > MaxClients) {
		ThrowError("Invalid client index %i", iClient);
	}
	g_bSkipPlayers[iClient] = true;
}

stock void CPrintToChat(int iClient, const char[] sMessage, any ...)
{
	if (iClient < 1 || iClient > MaxClients) {
		ThrowError("Invalid client index %d", iClient);
	}

	if (!IsClientInGame(iClient)) {
		ThrowError("Client %d is not in game", iClient);
	}

	char sBuffer[_CV_MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(iClient);
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 3);

	AddPrefixAndDefaultColor(sBuffer, sizeof(sBuffer));
	g_bIgnorePrefix = false;

	CProcessVariables(sBuffer, sizeof(sBuffer));
	CAddWhiteSpace(sBuffer, sizeof(sBuffer));

	SendPlayerMessage(iClient, sBuffer, g_iAuthor);
	g_iAuthor = 0;
}

stock void CPrintToChatAll(const char[] sMessage, any ...)
{
	char sBuffer[_CV_MAX_MESSAGE_LENGTH];

	for (int iClient = 1; iClient <= MaxClients; iClient++) {
		if (!IsClientInGame(iClient) || g_bSkipPlayers[iClient]) {
			g_bSkipPlayers[iClient] = false;
			continue;
		}

		SetGlobalTransTarget(iClient);
		VFormat(sBuffer, sizeof(sBuffer), sMessage, 2);

		AddPrefixAndDefaultColor(sBuffer, sizeof(sBuffer));
		g_bIgnorePrefix = false;

		CProcessVariables(sBuffer, sizeof(sBuffer));
		CAddWhiteSpace(sBuffer, sizeof(sBuffer));

		SendPlayerMessage(iClient, sBuffer, g_iAuthor);
	}
	g_iAuthor = 0;
}

stock void CPrintToChatTeam(int iTeam, const char[] sMessage, any ...)
{
	char sBuffer[_CV_MAX_MESSAGE_LENGTH];

	for (int iClient = 1; iClient <= MaxClients; iClient++) {
		if (!IsClientInGame(iClient) || GetClientTeam(iClient) != iTeam || g_bSkipPlayers[iClient]) {
			g_bSkipPlayers[iClient] = false;
			continue;
		}

		SetGlobalTransTarget(iClient);
		VFormat(sBuffer, sizeof(sBuffer), sMessage, 3);

		AddPrefixAndDefaultColor(sBuffer, sizeof(sBuffer));
		g_bIgnorePrefix = false;

		CProcessVariables(sBuffer, sizeof(sBuffer));
		CAddWhiteSpace(sBuffer, sizeof(sBuffer));

		SendPlayerMessage(iClient, sBuffer, g_iAuthor);
	}
	g_iAuthor = 0;
}

stock void CPrintToChatAdmins(int iBitFlags, const char[] sMessage, any ...)
{
	char sBuffer[_CV_MAX_MESSAGE_LENGTH];
	AdminId iAdminID;

	for (int iClient = 1; iClient <= MaxClients; iClient++) {
		if (!IsClientInGame(iClient) || g_bSkipPlayers[iClient]) {
			g_bSkipPlayers[iClient] = false;
			continue;
		}

		iAdminID = GetUserAdmin(iClient);
		if (iAdminID == INVALID_ADMIN_ID || !(GetAdminFlags(iAdminID, Access_Effective) & iBitFlags)) {
			continue;
		}

		SetGlobalTransTarget(iClient);
		VFormat(sBuffer, sizeof(sBuffer), sMessage, 3);

		AddPrefixAndDefaultColor(sBuffer, sizeof(sBuffer));
		g_bIgnorePrefix = false;

		CProcessVariables(sBuffer, sizeof(sBuffer));
		CAddWhiteSpace(sBuffer, sizeof(sBuffer));

		SendPlayerMessage(iClient, sBuffer, g_iAuthor);
	}
	g_iAuthor = 0;
}

stock void CReplyToCommand(int iClient, const char[] sMessage, any ...)
{
	if (iClient < 0 || iClient > MaxClients) {
		ThrowError("Invalid client index %d", iClient);
	}

	if (iClient != 0 && !IsClientInGame(iClient)) {
		ThrowError("Client %d is not in game", iClient);
	}

	char sBuffer[_CV_MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(iClient);
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 3);

	AddPrefixAndDefaultColor(sBuffer, sizeof(sBuffer), "reply2cmd");
	g_bIgnorePrefix = false;

	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
		CRemoveColors(sBuffer, sizeof(sBuffer));
		PrintToConsole(iClient, "%s", sBuffer);
	} else {
		CPrintToChat(iClient, "%s", sBuffer);
	}
}

stock void CShowActivity(int iClient, const char[] sMessage, any ...)
{
	if (iClient < 0 || iClient > MaxClients) {
		ThrowError("Invalid client index %d", iClient);
	}

	if (iClient != 0 && !IsClientInGame(iClient)) {
		ThrowError("Client %d is not in game", iClient);
	}

	char sBuffer[_CV_MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(iClient);
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 3);
	Format(sBuffer, sizeof(sBuffer), "{showactivity}%s", sBuffer);
	CProcessVariables(sBuffer, sizeof(sBuffer));
	CAddWhiteSpace(sBuffer, sizeof(sBuffer));

	ShowActivity(iClient, "%s", sBuffer);
}

stock void CShowActivityEx(int iClient, const char[] sTag, const char[] sMessage, any ...)
{
	if (iClient < 0 || iClient > MaxClients) {
		ThrowError("Invalid client index %d", iClient);
	}

	if (iClient != 0 && !IsClientInGame(iClient)) {
		ThrowError("Client %d is not in game", iClient);
	}

	char sBuffer[_CV_MAX_MESSAGE_LENGTH]; char sBufferTag[_CV_MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(iClient);
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 4);
	Format(sBuffer, sizeof(sBuffer), "{showactivity}%s", sBuffer);
	CProcessVariables(sBuffer, sizeof(sBuffer));
	Format(sBufferTag, sizeof(sBufferTag), "{prefix}%s", sTag);
	CProcessVariables(sBufferTag, sizeof(sBufferTag));
	CAddWhiteSpace(sBuffer, sizeof(sBuffer));
	CAddWhiteSpace(sBufferTag, sizeof(sBufferTag));

	ShowActivityEx(iClient, sBufferTag, " %s", sBuffer);
}

stock void CShowActivity2(int iClient, const char[] sTag, const char[] sMessage, any ...)
{
	if (iClient < 0 || iClient > MaxClients) {
		ThrowError("Invalid client index %d", iClient);
	}

	if (iClient != 0 && !IsClientInGame(iClient)) {
		ThrowError("Client %d is not in game", iClient);
	}

	char sBuffer[_CV_MAX_MESSAGE_LENGTH]; char sBufferTag[_CV_MAX_MESSAGE_LENGTH];
	SetGlobalTransTarget(iClient);
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 4);
	Format(sBuffer, sizeof(sBuffer), "{showactivity}%s", sBuffer);
	CProcessVariables(sBuffer, sizeof(sBuffer));
	Format(sBufferTag, sizeof(sBufferTag), "{prefix}%s", sTag);
	CProcessVariables(sBufferTag, sizeof(sBufferTag));
	CAddWhiteSpace(sBuffer, sizeof(sBuffer));
	CAddWhiteSpace(sBufferTag, sizeof(sBufferTag));

	ShowActivityEx(iClient, sBufferTag, " %s", sBuffer);
}

stock void CAddVariable(char[] sName, char[] sValue, bool bOnlySaveToConfig = false)
{
	if (Init()) {
		if (!FileExists(g_sConfig)) {
			LogError("Cannot add color variable to '%s' - file doesn't exist!", g_sConfig);
			return;
		}

		Handle hKV = CreateKeyValues("colorvariables");

		if (!FileToKeyValues(hKV, g_sConfig)) {
			CloseHandle(hKV);
			LogError("Cannot open file (for adding color variable) '%s' !", g_sConfig);
			return;
		}

		if (!KvJumpToKey(hKV, sName)) {
			StringToLower(sName);
			KvSetString(hKV, sName, sValue);

			if (!bOnlySaveToConfig) {
				Handle hRedirect = CreateArray(64);
				PushArrayString(hRedirect, sName);
				SetTrieString(g_hColors, sName, sValue);
				SolveRedirects(g_hColors, hRedirect);
				CloseHandle(hRedirect);
			}
		}

		KvRewind(hKV);
		KeyValuesToFile(hKV, g_sConfig);
		CloseHandle(hKV);
	}
}

stock void CLoadPluginConfig(const char[] sPluginName, bool bAllowPrefix = true)
{
	if (Init()) {
		char sConfig[PLATFORM_MAX_PATH];
		strcopy(sConfig, sizeof(sConfig), sPluginName);
		ReplaceStringEx(sConfig, sizeof(sConfig), ".smx", "");
		BuildPath(Path_SM, sConfig, sizeof(sConfig), "%s/plugin.%s.cfg", _CV_CONFIG_DIRECTORY, sConfig);

		if (!FileExists(sConfig)) {
			LogError("Cannot load color variables from file '%s' - file doesn't exist!", sConfig);
			return;
		}

		Handle hRedirect = CreateArray(64);
		LoadConfigFile(g_hColors, sConfig, hRedirect, bAllowPrefix);
		SolveRedirects(g_hColors, hRedirect);
		CloseHandle(hRedirect);
	}
}

stock void CLoadPluginVariables(const char[] sPluginName, const char[][] sVariables, int iVariablesCount, bool bAllowPrefix = true)
{
	if (Init() && iVariablesCount > 0) {
		char sConfig[PLATFORM_MAX_PATH];
		strcopy(sConfig, sizeof(sConfig), sPluginName);
		ReplaceStringEx(sConfig, sizeof(sConfig), ".smx", "");
		BuildPath(Path_SM, sConfig, sizeof(sConfig), "%s/plugin.%s.cfg", _CV_CONFIG_DIRECTORY, sConfig);

		if (!FileExists(sConfig)) {
			LogError("Cannot load color variables from file '%s' - file doesn't exist!", sConfig);
			return;
		}

		Handle hVariables = CreateTrie();
		Handle hRedirect = CreateArray(64);
		LoadConfigFile(hVariables, sConfig, hRedirect, bAllowPrefix);
		SolveRedirects(hVariables, hRedirect);
		ClearArray(hRedirect);

		char sCode[64]; char sColor[64];

		for (int i = 0; i < iVariablesCount; i++) {
			strcopy(sCode, sizeof(sCode), sVariables[i]);
			StringToLower(sCode);

			if (GetTrieString(hVariables, sCode, sColor, sizeof(sColor))) {
				SetTrieString(g_hColors, sCode, sColor);
				PushArrayString(hRedirect, sCode);
			}
		}

		SolveRedirects(g_hColors, hRedirect);
		CloseHandle(hRedirect);
		CloseHandle(hVariables);
	}
}

stock void CRemoveColors(char[] sMsg, int iSize)
{
	CProcessVariables(sMsg, iSize, true);
}

stock void CProcessVariables(char[] sMsg, int iSize, bool bRemoveColors = false)
{
	if (!Init()) {
		return;
	}

	char[] sOut = new char[iSize]; char[] sCode = new char[iSize]; char[] sColor = new char[iSize];
	int iOutPos = 0; int iCodePos = -1;
	int iMsgLen = strlen(sMsg);

	for (int i = 0; i < iMsgLen; i++) {
		if (sMsg[i] == '{') {
			iCodePos = 0;
		}

		if (iCodePos > -1) {
			sCode[iCodePos] = sMsg[i];
			sCode[iCodePos + 1] = '\0';

			if (sMsg[i] == '}' || i == iMsgLen - 1) {
				strcopy(sCode, strlen(sCode) - 1, sCode[1]);
				StringToLower(sCode);

				if (CGetColor(sCode, sColor, iSize)) {
					if (!bRemoveColors) {
						StrCat(sOut, iSize, sColor);
						iOutPos += strlen(sColor);
					}
				} else {
					Format(sOut, iSize, "%s{%s}", sOut, sCode);
					iOutPos += strlen(sCode) + 2;
				}

				iCodePos = -1;
				strcopy(sCode, iSize, "");
				strcopy(sColor, iSize, "");
			} else {
				iCodePos++;
			}

			continue;
		}

		sOut[iOutPos] = sMsg[i];
		iOutPos++;
		sOut[iOutPos] = '\0';
	}

	strcopy(sMsg, iSize, sOut);
}

stock bool CGetColor(const char[] sName, char[] sColor, int iColorSize)
{
	if (sName[0] == '\0')
		return false;

	if (sName[0] == '@') {
		int iSpace;
		char sData[64]; char m_sName[64];
		strcopy(m_sName, sizeof(m_sName), sName[1]);

		if ((iSpace = FindCharInString(m_sName, ' ')) != -1 && (iSpace + 1 < strlen(m_sName))) {
			strcopy(m_sName, iSpace + 1, m_sName);
			strcopy(sData, sizeof(sData), m_sName[iSpace + 1]);
		}

		Call_StartForward(g_hForwardedVariable);
		Call_PushString(m_sName);
		Call_PushStringEx(sData, sizeof(sData), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, 0);
		Call_PushCell(sizeof(sData));
		Call_PushStringEx(sColor, iColorSize, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushCell(iColorSize);
		Call_Finish();

		if (sColor[0] != '\0') {
			return true;
		}

	} else if (sName[0] == '#') {
		if (strlen(sName) == 7) {
			Format(sColor, iColorSize, "\x07%s", sName[1]);
			return true;
		}
		if (strlen(sName) == 9) {
			Format(sColor, iColorSize, "\x08%s", sName[1]);
			return true;
		}
	} else if (StrContains(sName, "player ", false) == 0 && strlen(sName) > 7) {
		int iClient = StringToInt(sName[7]);

		if (iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient)) {
			strcopy(sColor, iColorSize, "\x01");
			LogError("Invalid client index %d", iClient);
			return false;
		}

		strcopy(sColor, iColorSize, "\x01");
		switch (GetClientTeam(iClient)) {
			case 1: {GetTrieString(g_hColors, "team0", sColor, iColorSize);}
			case 2: {GetTrieString(g_hColors, "team1", sColor, iColorSize);}
			case 3: {GetTrieString(g_hColors, "team2", sColor, iColorSize);}
		}
		return true;
	} else {
		return GetTrieString(g_hColors, sName, sColor, iColorSize);
	}

	return false;
}

stock bool CExistColor(const char[] sName)
{
	if (sName[0] == '\0' || sName[0] == '@' || sName[0] == '#')
		return false;

	char sColor[64];
	return GetTrieString(g_hColors, sName, sColor, sizeof(sColor));
}

stock void CSayText2(int iClient, char[] sMessage, int iAuthor, bool bChat = true)
{
	Handle hMsg = StartMessageOne("SayText2", iClient, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) {
		PbSetInt(hMsg, "ent_idx", iAuthor);
		PbSetBool(hMsg, "chat", bChat);
		PbSetString(hMsg, "msg_name", sMessage);
		PbAddString(hMsg, "params", "");
		PbAddString(hMsg, "params", "");
		PbAddString(hMsg, "params", "");
		PbAddString(hMsg, "params", "");
	} else {
		BfWriteByte(hMsg, iAuthor);
		BfWriteByte(hMsg, true);
		BfWriteString(hMsg, sMessage);
	}
	EndMessage();
}

stock void CAddWhiteSpace(char[] sBuffer, int iSize)
{
	if (!IsSource2009()) {
		Format(sBuffer, iSize, " %s", sBuffer);
	}
}

// ----------------------------------------------------------------------------------------
// Private stuff
// ----------------------------------------------------------------------------------------

stock bool Init()
{
	if (g_bInit) {
		LoadColors();
		return true;
	}

	char sPluginName[PLATFORM_MAX_PATH];
	char sDirectoryPath[PLATFORM_MAX_PATH];
	Handle hConfig = INVALID_HANDLE;
	GetPluginFilename(INVALID_HANDLE, sPluginName, sizeof(sPluginName));
	ReplaceStringEx(sPluginName, sizeof(sPluginName), "\\", "/");
	int iSlash = FindCharInString(sPluginName, '/', true);
	if (iSlash > -1) {
		strcopy(sPluginName, sizeof(sPluginName), sPluginName[iSlash + 1]);
	}	
	ReplaceStringEx(sPluginName, sizeof(sPluginName), ".smx", "");

	BuildPath(Path_SM, sDirectoryPath, sizeof(sDirectoryPath), "%s/", _CV_CONFIG_DIRECTORY);
	if (!DirExists(sDirectoryPath))
		CreateDirectory(sDirectoryPath, 511);

	char sGlobalVariableList[15][2][64] = {
		{"prefix", 		 "{engine 2}"},
		{"default",		 "{engine 1}"},
		{"reply2cmd",  	 "{engine 1}"},
		{"showactivity", "{engine 1}"},
		{"", ""},
		{"error",		 "{engine 3}"},
		{"", ""},
		{"highlight",	 "{engine 2}"},
		{"player",		 "{engine 2}"},
		{"settings",	 "{engine 2}"},
		{"command",		 "{engine 2}"},
		{"", ""},
		{"team0",		 "{engine 8}"},
		{"team1",		 "{engine 9}"},
		{"team2",		 "{engine 11}"}
	};

	if (IsSource2009()) {
		strcopy(sGlobalVariableList[12][1], 64, "{#cccccc}");
		strcopy(sGlobalVariableList[13][1], 64, "{#ff4040}");
		strcopy(sGlobalVariableList[14][1], 64, "{#4d7942}");
	}

	BuildPath(Path_SM, g_sConfigGlobal, sizeof(g_sConfigGlobal), "%s/global.cfg", _CV_CONFIG_DIRECTORY);
	if (!FileExists(g_sConfigGlobal)) {
		hConfig = OpenFile(g_sConfigGlobal, "w");
		if (hConfig == INVALID_HANDLE) {
			LogError("Cannot create file '%s' !", g_sConfigGlobal);
			return false;
		}

		WriteFileLine(hConfig, "// Version: %s", _colorvariables_included);
		WriteFileLine(hConfig, "\"colorvariables\"");
		WriteFileLine(hConfig, "{");
		for (int i = 0; i < 15; i++) {
			if (sGlobalVariableList[i][0][0] == '\0') {
				WriteFileLine(hConfig, "");
			} else {
				WriteFileLine(hConfig, "\t\"%s\" \"%s\"", sGlobalVariableList[i][0], sGlobalVariableList[i][1]);
			}
		}
		WriteFileLine(hConfig, "}");

		CloseHandle(hConfig);
		hConfig = INVALID_HANDLE;
	} else {
		hConfig = OpenFile(g_sConfigGlobal, "r");
		if (hConfig == INVALID_HANDLE) {
			LogError("Cannot read from file '%s' !", g_sConfigGlobal);
			return false;
		}

		char sVersionLine[64];
		ReadFileLine(hConfig, sVersionLine, sizeof(sVersionLine));
		CloseHandle(hConfig);

		TrimString(sVersionLine);
		strcopy(sVersionLine, sizeof(sVersionLine), sVersionLine[FindCharInString(sVersionLine, ':') + 2]);

		if (StringToFloat(sVersionLine) < StringToFloat(_colorvariables_included)) {
			Handle hKV = CreateKeyValues("colorvariables");

			if (!FileToKeyValues(hKV, g_sConfigGlobal) || !KvGotoFirstSubKey(hKV, false)) {
				CloseHandle(hKV);
				LogError("Cannot read variables from file '%s' !", g_sConfigGlobal);
				return false;
			}

			for (int i = 0; i < 15; i++) {
				if (sGlobalVariableList[i][0][0] == '\0')
					continue;

				if (!KvJumpToKey(hKV, sGlobalVariableList[i][0]))
					KvSetString(hKV, sGlobalVariableList[i][0], sGlobalVariableList[i][1]);
			}

			hConfig = OpenFile(g_sConfigGlobal, "w");
			if (hConfig == INVALID_HANDLE) {
				LogError("Cannot write to file '%s' !", g_sConfigGlobal);
				return false;
			}

			WriteFileLine(hConfig, "// Version: %s", _colorvariables_included);
			WriteFileLine(hConfig, "\"colorvariables\"");
			WriteFileLine(hConfig, "{");

			char sCode[64]; char sColor[64];

			KvGotoFirstSubKey(hKV, false);
			do
			{
				KvGetSectionName(hKV, sCode, sizeof(sCode));
				KvGetString(hKV, NULL_STRING, sColor, sizeof(sColor));
				StringToLower(sCode);
				StringToLower(sColor);

				WriteFileLine(hConfig, "\t\"%s\" \"%s\"", sCode, sColor);
			} while (KvGotoNextKey(hKV, false));

			WriteFileLine(hConfig, "}");

			CloseHandle(hConfig);
			CloseHandle(hKV);
		}
	}

	BuildPath(Path_SM, g_sConfig, sizeof(g_sConfig), "%s/plugin.%s.cfg", _CV_CONFIG_DIRECTORY, sPluginName);
	if (!FileExists(g_sConfig)) {
		hConfig = OpenFile(g_sConfig, "w");
		if (hConfig == INVALID_HANDLE) {
			LogError("Cannot create file '%s' !", g_sConfig);
			return false;
		}

		WriteFileLine(hConfig, "\"colorvariables\"\n{\n}");
		CloseHandle(hConfig);
		hConfig = INVALID_HANDLE;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++) {
		g_bSkipPlayers[iClient] = false;
	}

	g_hForwardedVariable = CreateGlobalForward("COnForwardedVariable", ET_Ignore, Param_String, Param_String, Param_Cell, Param_String, Param_Cell);

	LoadColors();
	g_bInit = true;
	return true;
}

stock void LoadColors()
{
	if (g_hColors == INVALID_HANDLE) {
		g_hColors = CreateTrie();
		Handle hRedirect = CreateArray(64);

		AddColors(g_hColors);
		LoadConfigFile(g_hColors, g_sConfigGlobal, hRedirect);
		LoadConfigFile(g_hColors, g_sConfig, hRedirect);

		SolveRedirects(g_hColors, hRedirect);
		CloseHandle(hRedirect);
	}
}

stock void LoadConfigFile(Handle hTrie, char[] sPath, Handle hRedirect, bool bAllowPrefix = true)
{
	if (!FileExists(sPath)) {
		LogError("Cannot load color variables from file '%s' - file doesn't exist!", sPath);
		return;
	}

	Handle hKV = CreateKeyValues("colorvariables");

	if (!FileToKeyValues(hKV, sPath)) {
		CloseHandle(hKV);
		LogError("Cannot load color variables from file '%s' !", sPath);
		return;
	}

	if (!KvGotoFirstSubKey(hKV, false)) {
		CloseHandle(hKV);
		return;
	}

	char sCode[64]; char sColor[64];

	do
	{
		KvGetSectionName(hKV, sCode, sizeof(sCode));
		KvGetString(hKV, NULL_STRING, sColor, sizeof(sColor));

		if (bAllowPrefix && StrEqual(sCode, "&prefix", false)) {
			CSetPrefix(sColor);
			continue;
		}

		StringToLower(sCode);

		if (HasBrackets(sColor) && sColor[1] == '@') {
			LogError("Variables cannot be redirected to forwarded variables! (variable '%s')", sCode);
			continue;
		}

		if (HasBrackets(sColor)) {
			if (sColor[1] == '#') {
				Format(sColor, sizeof(sColor), "\x07%s", sColor[1]);
			} else {
				PushArrayString(hRedirect, sCode);
			}
		}

		SetTrieString(hTrie, sCode, sColor);
	} while (KvGotoNextKey(hKV, false));

	CloseHandle(hKV);
}

stock void SolveRedirects(Handle hTrie, Handle hRedirect)
{
	char sCode[64]; char sRedirect[64]; char sColor[64]; char sFirstColor[64];
	int iRedirectLife; bool bHasBrackets;

	for (int i = 0; i < GetArraySize(hRedirect); i++) {
		GetArrayString(hRedirect, i, sRedirect, sizeof(sRedirect));
		strcopy(sCode, sizeof(sCode), sRedirect);
		bHasBrackets = true;

		GetTrieString(hTrie, sRedirect, sColor, sizeof(sColor));
		strcopy(sFirstColor, sizeof(sFirstColor), sRedirect);
		iRedirectLife = _CV_MAX_VARIABLE_REDIRECTS;

		do {
			if (!HasBrackets(sColor)) {
				strcopy(sRedirect, sizeof(sRedirect), sColor);
				bHasBrackets = false;
				break;
			}

			strcopy(sColor, strlen(sColor) - 1, sColor[1]);
			if (iRedirectLife > 0) {
				strcopy(sRedirect, sizeof(sRedirect), sColor);
				iRedirectLife--;
			} else {
				strcopy(sRedirect, sizeof(sRedirect), sFirstColor);
				LogError("Too many redirects for variable '%s' !", sCode);
				break;
			}
		} while (GetTrieString(hTrie, sRedirect, sColor, sizeof(sColor)));

		if (bHasBrackets) {
			Format(sRedirect, sizeof(sRedirect), "{%s}", sRedirect);
		}

		StringToLower(sCode);
		StringToLower(sRedirect);
		SetTrieString(hTrie, sCode, sRedirect);
	}
}

stock bool HasBrackets(const char[] sSource)
{
	return (sSource[0] == '{' && sSource[strlen(sSource) - 1] == '}');
}

stock void StringToLower(char[] sSource)
{
	for (int i = 0; i < strlen(sSource); i++) {
		if (sSource[i] == '\0')
			break;

		sSource[i] = CharToLower(sSource[i]);
	}
}

stock void AddColors(Handle hTrie)
{
	if (IsSource2009()) {
		SetTrieString(hTrie, "default", "\x01");
		SetTrieString(hTrie, "teamcolor", "\x03");

		SetTrieString(hTrie, "aliceblue", "\x07F0F8FF");
		SetTrieString(hTrie, "allies", "\x074D7942");
		SetTrieString(hTrie, "ancient", "\x07EB4B4B");
		SetTrieString(hTrie, "antiquewhite", "\x07FAEBD7");
		SetTrieString(hTrie, "aqua", "\x0700FFFF");
		SetTrieString(hTrie, "aquamarine", "\x077FFFD4");
		SetTrieString(hTrie, "arcana", "\x07ADE55C");
		SetTrieString(hTrie, "axis", "\x07FF4040");
		SetTrieString(hTrie, "azure", "\x07007FFF");
		SetTrieString(hTrie, "beige", "\x07F5F5DC");
		SetTrieString(hTrie, "bisque", "\x07FFE4C4");
		SetTrieString(hTrie, "black", "\x07000000");
		SetTrieString(hTrie, "blanchedalmond", "\x07FFEBCD");
		SetTrieString(hTrie, "blue", "\x0799CCFF");
		SetTrieString(hTrie, "blueviolet", "\x078A2BE2");
		SetTrieString(hTrie, "brown", "\x07A52A2A");
		SetTrieString(hTrie, "burlywood", "\x07DEB887");
		SetTrieString(hTrie, "cadetblue", "\x075F9EA0");
		SetTrieString(hTrie, "chartreuse", "\x077FFF00");
		SetTrieString(hTrie, "chocolate", "\x07D2691E");
		SetTrieString(hTrie, "collectors", "\x07AA0000");
		SetTrieString(hTrie, "common", "\x07B0C3D9");
		SetTrieString(hTrie, "community", "\x0770B04A");
		SetTrieString(hTrie, "coral", "\x07FF7F50");
		SetTrieString(hTrie, "cornflowerblue", "\x076495ED");
		SetTrieString(hTrie, "cornsilk", "\x07FFF8DC");
		SetTrieString(hTrie, "corrupted", "\x07A32C2E");
		SetTrieString(hTrie, "crimson", "\x07DC143C");
		SetTrieString(hTrie, "cyan", "\x0700FFFF");
		SetTrieString(hTrie, "darkblue", "\x0700008B");
		SetTrieString(hTrie, "darkcyan", "\x07008B8B");
		SetTrieString(hTrie, "darkgoldenrod", "\x07B8860B");
		SetTrieString(hTrie, "darkgray", "\x07A9A9A9");
		SetTrieString(hTrie, "darkgrey", "\x07A9A9A9");
		SetTrieString(hTrie, "darkgreen", "\x07006400");
		SetTrieString(hTrie, "darkkhaki", "\x07BDB76B");
		SetTrieString(hTrie, "darkmagenta", "\x078B008B");
		SetTrieString(hTrie, "darkolivegreen", "\x07556B2F");
		SetTrieString(hTrie, "darkorange", "\x07FF8C00");
		SetTrieString(hTrie, "darkorchid", "\x079932CC");
		SetTrieString(hTrie, "darkred", "\x078B0000");
		SetTrieString(hTrie, "darksalmon", "\x07E9967A");
		SetTrieString(hTrie, "darkseagreen", "\x078FBC8F");
		SetTrieString(hTrie, "darkslateblue", "\x07483D8B");
		SetTrieString(hTrie, "darkslategray", "\x072F4F4F");
		SetTrieString(hTrie, "darkslategrey", "\x072F4F4F");
		SetTrieString(hTrie, "darkturquoise", "\x0700CED1");
		SetTrieString(hTrie, "darkviolet", "\x079400D3");
		SetTrieString(hTrie, "deeppink", "\x07FF1493");
		SetTrieString(hTrie, "deepskyblue", "\x0700BFFF");
		SetTrieString(hTrie, "dimgray", "\x07696969");
		SetTrieString(hTrie, "dimgrey", "\x07696969");
		SetTrieString(hTrie, "dodgerblue", "\x071E90FF");
		SetTrieString(hTrie, "exalted", "\x07CCCCCD");
		SetTrieString(hTrie, "firebrick", "\x07B22222");
		SetTrieString(hTrie, "floralwhite", "\x07FFFAF0");
		SetTrieString(hTrie, "forestgreen", "\x07228B22");
		SetTrieString(hTrie, "frozen", "\x074983B3");
		SetTrieString(hTrie, "fuchsia", "\x07FF00FF");
		SetTrieString(hTrie, "fullblue", "\x070000FF");
		SetTrieString(hTrie, "fullred", "\x07FF0000");
		SetTrieString(hTrie, "gainsboro", "\x07DCDCDC");
		SetTrieString(hTrie, "genuine", "\x074D7455");
		SetTrieString(hTrie, "ghostwhite", "\x07F8F8FF");
		SetTrieString(hTrie, "gold", "\x07FFD700");
		SetTrieString(hTrie, "goldenrod", "\x07DAA520");
		SetTrieString(hTrie, "gray", "\x07CCCCCC");
		SetTrieString(hTrie, "grey", "\x07CCCCCC");
		SetTrieString(hTrie, "green", "\x073EFF3E");
		SetTrieString(hTrie, "greenyellow", "\x07ADFF2F");
		SetTrieString(hTrie, "haunted", "\x0738F3AB");
		SetTrieString(hTrie, "honeydew", "\x07F0FFF0");
		SetTrieString(hTrie, "hotpink", "\x07FF69B4");
		SetTrieString(hTrie, "immortal", "\x07E4AE33");
		SetTrieString(hTrie, "indianred", "\x07CD5C5C");
		SetTrieString(hTrie, "indigo", "\x074B0082");
		SetTrieString(hTrie, "ivory", "\x07FFFFF0");
		SetTrieString(hTrie, "khaki", "\x07F0E68C");
		SetTrieString(hTrie, "lavender", "\x07E6E6FA");
		SetTrieString(hTrie, "lavenderblush", "\x07FFF0F5");
		SetTrieString(hTrie, "lawngreen", "\x077CFC00");
		SetTrieString(hTrie, "legendary", "\x07D32CE6");
		SetTrieString(hTrie, "lemonchiffon", "\x07FFFACD");
		SetTrieString(hTrie, "lightblue", "\x07ADD8E6");
		SetTrieString(hTrie, "lightcoral", "\x07F08080");
		SetTrieString(hTrie, "lightcyan", "\x07E0FFFF");
		SetTrieString(hTrie, "lightgoldenrodyellow", "\x07FAFAD2");
		SetTrieString(hTrie, "lightgray", "\x07D3D3D3");
		SetTrieString(hTrie, "lightgrey", "\x07D3D3D3");
		SetTrieString(hTrie, "lightgreen", "\x0799FF99");
		SetTrieString(hTrie, "lightpink", "\x07FFB6C1");
		SetTrieString(hTrie, "lightsalmon", "\x07FFA07A");
		SetTrieString(hTrie, "lightseagreen", "\x0720B2AA");
		SetTrieString(hTrie, "lightskyblue", "\x0787CEFA");
		SetTrieString(hTrie, "lightslategray", "\x07778899");
		SetTrieString(hTrie, "lightslategrey", "\x07778899");
		SetTrieString(hTrie, "lightsteelblue", "\x07B0C4DE");
		SetTrieString(hTrie, "lightyellow", "\x07FFFFE0");
		SetTrieString(hTrie, "lime", "\x0700FF00");
		SetTrieString(hTrie, "limegreen", "\x0732CD32");
		SetTrieString(hTrie, "linen", "\x07FAF0E6");
		SetTrieString(hTrie, "magenta", "\x07FF00FF");
		SetTrieString(hTrie, "maroon", "\x07800000");
		SetTrieString(hTrie, "mediumaquamarine", "\x0766CDAA");
		SetTrieString(hTrie, "mediumblue", "\x070000CD");
		SetTrieString(hTrie, "mediumorchid", "\x07BA55D3");
		SetTrieString(hTrie, "mediumpurple", "\x079370D8");
		SetTrieString(hTrie, "mediumseagreen", "\x073CB371");
		SetTrieString(hTrie, "mediumslateblue", "\x077B68EE");
		SetTrieString(hTrie, "mediumspringgreen", "\x0700FA9A");
		SetTrieString(hTrie, "mediumturquoise", "\x0748D1CC");
		SetTrieString(hTrie, "mediumvioletred", "\x07C71585");
		SetTrieString(hTrie, "midnightblue", "\x07191970");
		SetTrieString(hTrie, "mintcream", "\x07F5FFFA");
		SetTrieString(hTrie, "mistyrose", "\x07FFE4E1");
		SetTrieString(hTrie, "moccasin", "\x07FFE4B5");
		SetTrieString(hTrie, "mythical", "\x078847FF");
		SetTrieString(hTrie, "navajowhite", "\x07FFDEAD");
		SetTrieString(hTrie, "navy", "\x07000080");
		SetTrieString(hTrie, "normal", "\x07B2B2B2");
		SetTrieString(hTrie, "oldlace", "\x07FDF5E6");
		SetTrieString(hTrie, "olive", "\x079EC34F");
		SetTrieString(hTrie, "olivedrab", "\x076B8E23");
		SetTrieString(hTrie, "orange", "\x07FFA500");
		SetTrieString(hTrie, "orangered", "\x07FF4500");
		SetTrieString(hTrie, "orchid", "\x07DA70D6");
		SetTrieString(hTrie, "palegoldenrod", "\x07EEE8AA");
		SetTrieString(hTrie, "palegreen", "\x0798FB98");
		SetTrieString(hTrie, "paleturquoise", "\x07AFEEEE");
		SetTrieString(hTrie, "palevioletred", "\x07D87093");
		SetTrieString(hTrie, "papayawhip", "\x07FFEFD5");
		SetTrieString(hTrie, "peachpuff", "\x07FFDAB9");
		SetTrieString(hTrie, "peru", "\x07CD853F");
		SetTrieString(hTrie, "pink", "\x07FFC0CB");
		SetTrieString(hTrie, "plum", "\x07DDA0DD");
		SetTrieString(hTrie, "powderblue", "\x07B0E0E6");
		SetTrieString(hTrie, "purple", "\x07800080");
		SetTrieString(hTrie, "rare", "\x074B69FF");
		SetTrieString(hTrie, "red", "\x07FF4040");
		SetTrieString(hTrie, "rosybrown", "\x07BC8F8F");
		SetTrieString(hTrie, "royalblue", "\x074169E1");
		SetTrieString(hTrie, "saddlebrown", "\x078B4513");
		SetTrieString(hTrie, "salmon", "\x07FA8072");
		SetTrieString(hTrie, "sandybrown", "\x07F4A460");
		SetTrieString(hTrie, "seagreen", "\x072E8B57");
		SetTrieString(hTrie, "seashell", "\x07FFF5EE");
		SetTrieString(hTrie, "selfmade", "\x0770B04A");
		SetTrieString(hTrie, "sienna", "\x07A0522D");
		SetTrieString(hTrie, "silver", "\x07C0C0C0");
		SetTrieString(hTrie, "skyblue", "\x0787CEEB");
		SetTrieString(hTrie, "slateblue", "\x076A5ACD");
		SetTrieString(hTrie, "slategray", "\x07708090");
		SetTrieString(hTrie, "slategrey", "\x07708090");
		SetTrieString(hTrie, "snow", "\x07FFFAFA");
		SetTrieString(hTrie, "springgreen", "\x0700FF7F");
		SetTrieString(hTrie, "steelblue", "\x074682B4");
		SetTrieString(hTrie, "strange", "\x07CF6A32");
		SetTrieString(hTrie, "tan", "\x07D2B48C");
		SetTrieString(hTrie, "teal", "\x07008080");
		SetTrieString(hTrie, "thistle", "\x07D8BFD8");
		SetTrieString(hTrie, "tomato", "\x07FF6347");
		SetTrieString(hTrie, "turquoise", "\x0740E0D0");
		SetTrieString(hTrie, "uncommon", "\x07B0C3D9");
		SetTrieString(hTrie, "unique", "\x07FFD700");
		SetTrieString(hTrie, "unusual", "\x078650AC");
		SetTrieString(hTrie, "valve", "\x07A50F79");
		SetTrieString(hTrie, "vintage", "\x07476291");
		SetTrieString(hTrie, "violet", "\x07EE82EE");
		SetTrieString(hTrie, "wheat", "\x07F5DEB3");
		SetTrieString(hTrie, "white", "\x07FFFFFF");
		SetTrieString(hTrie, "whitesmoke", "\x07F5F5F5");
		SetTrieString(hTrie, "yellow", "\x07FFFF00");
		SetTrieString(hTrie, "yellowgreen", "\x079ACD32");
	} else {
		SetTrieString(hTrie, "default", "\x01");
		SetTrieString(hTrie, "teamcolor", "\x03");

		SetTrieString(hTrie, "red", "\x07");
		SetTrieString(hTrie, "lightred", "\x0F");
		SetTrieString(hTrie, "darkred", "\x02");
		SetTrieString(hTrie, "bluegrey", "\x0A");
		SetTrieString(hTrie, "blue", "\x0B");
		SetTrieString(hTrie, "darkblue", "\x0C");
		SetTrieString(hTrie, "purple", "\x03");
		SetTrieString(hTrie, "orchid", "\x0E");
		SetTrieString(hTrie, "yellow", "\x09");
		SetTrieString(hTrie, "gold", "\x10");
		SetTrieString(hTrie, "lightgreen", "\x05");
		SetTrieString(hTrie, "green", "\x04");
		SetTrieString(hTrie, "lime", "\x06");
		SetTrieString(hTrie, "grey", "\x08");
		SetTrieString(hTrie, "grey2", "\x0D");
	}

	SetTrieString(hTrie, "engine 1", "\x01");
	SetTrieString(hTrie, "engine 2", "\x02");
	SetTrieString(hTrie, "engine 3", "\x03");
	SetTrieString(hTrie, "engine 4", "\x04");
	SetTrieString(hTrie, "engine 5", "\x05");
	SetTrieString(hTrie, "engine 6", "\x06");
	SetTrieString(hTrie, "engine 7", "\x07");
	SetTrieString(hTrie, "engine 8", "\x08");
	SetTrieString(hTrie, "engine 9", "\x09");
	SetTrieString(hTrie, "engine 10", "\x0A");
	SetTrieString(hTrie, "engine 11", "\x0B");
	SetTrieString(hTrie, "engine 12", "\x0C");
	SetTrieString(hTrie, "engine 13", "\x0D");
	SetTrieString(hTrie, "engine 14", "\x0E");
	SetTrieString(hTrie, "engine 15", "\x0F");
	SetTrieString(hTrie, "engine 16", "\x10");
}

stock bool IsSource2009()
{
	if (g_IsSource2009 == unknown) {
		EngineVersion iEngineVersion = GetEngineVersion();
		g_IsSource2009 = (iEngineVersion == Engine_CSS || iEngineVersion == Engine_TF2 || iEngineVersion == Engine_HL2DM || iEngineVersion == Engine_DODS) ? yes : no;
	}

	return view_as<bool>(g_IsSource2009);
}

stock void AddPrefixAndDefaultColor(char[] sMessage, int iSize, char[] sDefaultColor = "default", char[] sPrefixColor = "prefix")
{
	if (g_sChatPrefix[0] != '\0' && !g_bIgnorePrefix) {
		Format(sMessage, iSize, "{%s}[%s]{%s} %s", sPrefixColor, g_sChatPrefix, sDefaultColor, sMessage);
	} else {
		Format(sMessage, iSize, "{%s}%s", sDefaultColor, sMessage);
	}
}

stock void SendPlayerMessage(int iClient, char[] sMessage, int iAuthor  = 0)
{
	if (iAuthor < 1 || iAuthor > MaxClients || !IsClientInGame(iAuthor)) {
		PrintToChat(iClient, sMessage);

		if (iAuthor != 0) {
			LogError("Client %d is not valid or in game", iAuthor);
		}
	} else {
		CSayText2(iClient, sMessage, iAuthor);
	}
}
