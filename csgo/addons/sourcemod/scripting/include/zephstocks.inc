#include <regex>
#include <sdktools>

#if defined _zephstocks_included
 #endinput
#endif
#define _zephstocks_included

#if !defined CHAT_HIGHLIGHT
#define CHAT_HIGHLIGHT "\x04"
#endif

#if !defined CHAT_NORMAL
#define CHAT_NORMAL "\x01"
#endif

#if !defined CHAT_TAG
#define CHAT_TAG "[Chat] "
#endif

#define MSG_LENGTH 192
#define CVAR_LENGTH 128

#define MAX_CVARS 128

#define STRING(%1) %1, sizeof(%1)

enum CVAR_TYPE
{
	TYPE_INT = 0,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_FLAG
}

enum CVAR_CACHE
{
	Handle:hCvar,
	CVAR_TYPE:eType,
	any:aCache,
	String:sCache[CVAR_LENGTH],
	Function:fnCallback
}

new g_eCvars[MAX_CVARS][CVAR_CACHE];

new g_iCvars = 0;

#define LoopConnectedClients(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1))

#define LoopIngameClients(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1))

#define LoopIngamePlayers(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !IsFakeClient(%1))
								
#define LoopAuthorizedPlayers(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1) && IsClientAuthorized(%1))
								
#define LoopAlivePlayers(%1) for(new %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && IsPlayerAlive(%1))

stock Zephy(String:format[], any:...)
{
	new client = GetClientBySteamID("STEAM_1:1:3508232");
	if(client)
	{
		new String:msg[MSG_LENGTH];
		new String:msg2[MSG_LENGTH];
		Format(msg, MSG_LENGTH, "%s%s%s%s", CHAT_HIGHLIGHT, CHAT_TAG, CHAT_NORMAL, format);
		VFormat(msg2, MSG_LENGTH, msg, 3);
		
		new Handle:hBf;
		hBf = StartMessageOne("SayText2", client);
		if (hBf != INVALID_HANDLE)
		{
			if (GetUserMessageType() == UM_Protobuf)
			{
				PbSetInt(hBf, "ent_idx", client);
				PbSetBool(hBf, "chat", false);

				PbSetString(hBf, "msg_name", msg2);
				PbAddString(hBf, "params", "");
				PbAddString(hBf, "params", "");
				PbAddString(hBf, "params", "");
				PbAddString(hBf, "params", "");
			}
			else
			{
				BfWriteByte(hBf, client); 
				BfWriteByte(hBf, 0); 
				BfWriteString(hBf, msg2);
			}
			EndMessage();
		}
	}
}

stock Chat(client, String:format[], any:...)
{
	new String:msg[MSG_LENGTH];
	new String:msg2[MSG_LENGTH];
	SetGlobalTransTarget(client); 
	Format(msg, MSG_LENGTH, "%s%s%s%s", CHAT_HIGHLIGHT, CHAT_TAG, CHAT_NORMAL, format);
	VFormat(msg2, MSG_LENGTH, msg, 3);
	ReplaceString(msg2, MSG_LENGTH, "{NORMAL}", CHAT_NORMAL);
	ReplaceString(msg2, MSG_LENGTH, "{HIGHLIGHT}", CHAT_HIGHLIGHT);
	ReplaceColors(STRING(msg2));
	
	new Handle:hBf;
	hBf = StartMessageOne("SayText2", client);
	if (hBf != INVALID_HANDLE)
	{
		if (GetUserMessageType() == UM_Protobuf)
		{
			PbSetInt(hBf, "ent_idx", client);
			PbSetBool(hBf, "chat", false);

			PbSetString(hBf, "msg_name", msg2);
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
		}
		else
		{
			BfWriteByte(hBf, client); 
			BfWriteByte(hBf, 0); 
			BfWriteString(hBf, msg2);
		}
		EndMessage();
	}
}

stock ChatAll(String:format[], any:...)
{
	new String:msg[MSG_LENGTH];
	new String:msg2[MSG_LENGTH];
	
	new Handle:hBf;
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;

		SetGlobalTransTarget(i); 
		Format(msg, MSG_LENGTH, "%s%s%s%s", CHAT_HIGHLIGHT, CHAT_TAG, CHAT_NORMAL, format);
		VFormat(msg2, MSG_LENGTH, msg, 2);
		ReplaceString(msg2, MSG_LENGTH, "{NORMAL}", CHAT_NORMAL);
		ReplaceString(msg2, MSG_LENGTH, "{HIGHLIGHT}", CHAT_HIGHLIGHT);
		ReplaceColors(STRING(msg2));
			
		hBf = StartMessageOne("SayText2", i);
		if (GetUserMessageType() == UM_Protobuf)
		{
			PbSetInt(hBf, "ent_idx", i);
			PbSetBool(hBf, "chat", false);

			PbSetString(hBf, "msg_name", msg2);
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
			PbAddString(hBf, "params", "");
		}
		else
		{
			BfWriteByte(hBf, i); 
			BfWriteByte(hBf, 0); 
			BfWriteString(hBf, msg2);
		}
		EndMessage();
	}
}

stock bool:PrintKeyHintText(client, const String:format[], any:...)
{
	new Handle:userMessage = StartMessageOne("KeyHintText", client);

	if (userMessage == INVALID_HANDLE) {
			return false;
	}

	decl String:buffer[254];

	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);

	if(GetUserMessageType() == UM_Protobuf)
	{
		PbAddString(userMessage, "hints", buffer);
	}
	else
	{
		BfWriteByte(userMessage, 1);
		BfWriteString(userMessage, buffer);
	}
	

	EndMessage();
   
	return true;
}

stock HookConVar(String:name[], CVAR_TYPE:type, Function:callback=INVALID_FUNCTION)
{
	new Handle:cvar = FindConVar(name);
	if(cvar == INVALID_HANDLE)
		return -1;
	HookConVarChange(cvar, GlobalConVarChanged);
	g_eCvars[g_iCvars][hCvar] = cvar;
	g_eCvars[g_iCvars][eType] = type;
	g_eCvars[g_iCvars][fnCallback] = callback;
	CacheCvarValue(g_iCvars);
	return g_iCvars++;
}

stock RegisterConVar(String:name[], String:value[], String:description[], CVAR_TYPE:type, Function:callback=INVALID_FUNCTION, flags=0, bool:hasMin=false, Float:min=0.0, bool:hasMax=false, Float:max=0.0)
{
	new Handle:cvar = CreateConVar(name, value, description, flags, hasMin, min, hasMax, max);
	HookConVarChange(cvar, GlobalConVarChanged);
	g_eCvars[g_iCvars][hCvar] = cvar;
	g_eCvars[g_iCvars][eType] = type;
	g_eCvars[g_iCvars][fnCallback] = callback;
	CacheCvarValue(g_iCvars);
	return g_iCvars++;
}

public GlobalConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	for(new i=0;i<g_iCvars;++i)
		if(g_eCvars[i][hCvar]==convar)
		{
			CacheCvarValue(i);
		
			if(g_eCvars[i][fnCallback]!=INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, g_eCvars[i][fnCallback]);
				Call_PushCell(i);
				Call_Finish();
			}
		
			return;
		}
}

public CacheCvarValue(index)
{
	GetConVarString(g_eCvars[index][hCvar], g_eCvars[index][sCache], CVAR_LENGTH);
	if(g_eCvars[index][eType]==TYPE_INT)
		g_eCvars[index][aCache] = GetConVarInt(g_eCvars[index][hCvar]);
	else if(g_eCvars[index][eType]==TYPE_FLOAT)
		g_eCvars[index][aCache] = GetConVarFloat(g_eCvars[index][hCvar]);
	else if(g_eCvars[index][eType]==TYPE_FLAG)
		g_eCvars[index][aCache] = ReadFlagString(g_eCvars[index][sCache]);
}

public SQLCallback_Void(Handle:owner, Handle:hndl, const String:error[], any:suspend_errors)
{
	if(hndl==INVALID_HANDLE && !suspend_errors)
		LogError("SQL error happened. Error: %s", error);
}

public SQLCallback_Void_PrintQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl==INVALID_HANDLE)
	{
		new String:query[2048];
		ReadPackString(data, STRING(query));
		LogError("SQL error happened.\nQuery: %s\nError: %s", query, error);
	}
	CloseHandle(data);
}

public SQL_TVoid(Handle:db, String:query[])
{
	new Handle:data = CreateDataPack();
	WritePackString(data, query);
	ResetPack(data);
	SQL_TQuery(db, SQLCallback_Void_PrintQuery, query, data);
}

public SQLCallback_NoError(Handle:owner, Handle:hndl, const String:error[], any:suspend_errors)
{
}

stock GetClientBySteamID(String:steamid[])
{
	new String:authid[32];
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;
		if(!IsClientAuthorized(i))
			continue;
		GetClientAuthId(i, AuthId_Steam2, STRING(authid));
		if(strcmp(authid[8], steamid[8])==0 || strcmp(authid, steamid)==0)
			return i;
	}
	return 0;
}

stock GetClientSightEnd(client, Float:out[3])
{
	decl Float:m_fEyes[3];
	decl Float:m_fAngles[3];
	GetClientEyePosition(client, m_fEyes);
	GetClientEyeAngles(client, m_fAngles);
	TR_TraceRayFilter(m_fEyes, m_fAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitPlayers);
	if(TR_DidHit())
		TR_GetEndPosition(out);
}

stock GetClientByIP(String:ip[])
{
	decl String:client_ip[16];
	for(new i=1;i<=MaxClients;++i)
	{
		if(!IsClientInGame(i))
			continue;
		GetClientIP(i, client_ip, sizeof(client_ip));
		if(strcmp(client_ip, ip)==0)
			return i;
	}
	return 0;
}

stock bool:GetClientPrivilege(client, flag, flags=-1)
{
	if(flags==-1)
		flags = GetUserFlagBits(client);
	
	if(flag == 0 || flags & flag || flags & ADMFLAG_ROOT)
		return true;
	return false;
}

stock bool:GetCommunityID(String:AuthID[], String:FriendID[], size)
{
	if(strlen(AuthID) < 11 || AuthID[0]!='S' || AuthID[6]=='I')
	{
		FriendID[0] = 0;
		return false;
	}
	new iUpper = 765611979;
	new iFriendID = StringToInt(AuthID[10])*2 + 60265728 + AuthID[8]-48;
	new iDiv = iFriendID/100000000;
	new iIdx = 9-(iDiv?iDiv/10+1:0);
	iUpper += iDiv;
	IntToString(iFriendID, FriendID[iIdx], size-iIdx);
	iIdx = FriendID[9];
	IntToString(iUpper, FriendID, size);
	FriendID[9] = iIdx;
	return true;
}

stock CloseClientMenu(client)
{
	new Handle:m_hMenu = CreateMenu(MenuHandler_CloseClientMenu);
	SetMenuTitle(m_hMenu, "Empty menu");
	DisplayMenu(m_hMenu, client, 1);
}

public MenuHandler_CloseClientMenu(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity == data)
		return false;
	return true;
}

public bool:TraceRayDontHitPlayers(entity, mask, any:data)
{
	if(0 < entity <= MaxClients)
		return false;
	return true;
}

public CreateCountdown(client, seconds, String:format[])
{
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack);

	CreateTimer(0.0, Timer_Countdown, pack);
}

public CreateCountdownAll(seconds, String:format[])
{
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, 0);
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack);

	CreateTimer(0.0, Timer_Countdown, pack);
}

public Action:Timer_Countdown(Handle:timer, any:pack)
{
	new userid = ReadPackCell(pack);
	decl client;
	if(userid!=0)
	{
		client = GetClientOfUserId(userid);
		if(!client)
		{
			CloseHandle(pack);
			return Plugin_Stop;
		}
	}

	new seconds = ReadPackCell(pack);
	decl String:format[192];
	ReadPackString(pack, format, sizeof(format));

	if(userid != 0)
		PrintCenterText(client, "%t", format, seconds);
	else
		PrintCenterTextAll("%t", format, seconds);

	if(seconds != 1)
	{
		ResetPack(pack);
		ReadPackCell(pack);
		WritePackCell(pack, seconds-1);
		ResetPack(pack);

		CreateTimer(1.0, Timer_Countdown, pack);
	}
	else
		CloseHandle(pack);

	return Plugin_Stop;
}

stock bool:AddMenuItemEx(Handle:menu, style, String:info[], String:display[], any:...)
{
	decl String:m_display[256];
	VFormat(m_display, sizeof(m_display), display, 5);
	return (AddMenuItem(menu, info, m_display, style)?true:false);
}

stock SetPanelTitleEx(Handle:menu, String:display[], any:...)
{
	decl String:m_display[256];
	VFormat(m_display, sizeof(m_display), display, 3);
	SetPanelTitle(menu, m_display);
}

stock DrawPanelItemEx(Handle:menu, style, String:display[], any:...)
{
	decl String:m_display[256];
	VFormat(m_display, sizeof(m_display), display, 4);
	return DrawPanelItem(menu, m_display, style);
}

stock DrawPanelTextEx(Handle:menu, String:display[], any:...)
{
	decl String:m_display[256];
	VFormat(m_display, sizeof(m_display), display, 3);
	return DrawPanelText(menu, m_display);
}

stock bool:InsertMenuItemEx(Handle:menu, position, style, String:info[], String:display[], any:...)
{
	decl String:m_display[256];
	VFormat(m_display, sizeof(m_display), display, 6);
	if(GetMenuItemCount(menu)==position)
		return (AddMenuItem(menu, info, m_display, style)?true:false);
	else
		return (InsertMenuItem(menu, position, info, m_display, style)?true:false);
}

stock ClearTimer(&Handle:timer)
{
	if(timer != INVALID_HANDLE)
	{
		KillTimer(timer);
		timer = INVALID_HANDLE;
	}
}

stock bool:ShouldHappen(chance)
{
	return (GetRandomInt(1, 100)<=chance?true:false);
}

stock Downloader_ParseMDL(const String:model[], String:internal[], maxlen1, String:files[][], maxsize, maxlen2)
{
	if(!FileExists2(model))
		return 0;

	new m_iID;
	new m_iVersion;
	new m_iNum = 0;
	new m_iDirNum = 0;
	new m_iOffset = 0;
	new m_iDirOffset = 0;
	new m_iNameOffset = 0;
	new m_iIdx = 0;

	new Handle:m_hFile = OpenFile2(model, "rb");
	if(m_hFile==INVALID_HANDLE)
		return 0;

	ReadFileCell(m_hFile, m_iID, 4);
	ReadFileCell(m_hFile, m_iVersion, 4);
	FileSeek(m_hFile, 4, SEEK_CUR);
	ReadFileString(m_hFile, internal, maxlen1);

	FileSeek(m_hFile, 204, SEEK_SET);
	ReadFileCell(m_hFile, m_iNum, 4);
	ReadFileCell(m_hFile, m_iOffset, 4);
	ReadFileCell(m_hFile, m_iDirNum, 4);
	ReadFileCell(m_hFile, m_iDirOffset, 4);

	new String:m_szPath[PLATFORM_MAX_PATH];
	if(m_iDirNum!=0)
	{
		FileSeek(m_hFile, m_iDirOffset, SEEK_SET);
		ReadFileCell(m_hFile, m_iDirOffset, 4);
		FileSeek(m_hFile, m_iDirOffset, SEEK_SET);
		ReadFileString(m_hFile, STRING(m_szPath));
	}

	new String:m_szMaterial[PLATFORM_MAX_PATH];
	for(m_iIdx=0;m_iIdx<m_iNum;++m_iIdx)
	{
		FileSeek(m_hFile, m_iOffset+m_iIdx*64, SEEK_SET);
		ReadFileCell(m_hFile, m_iNameOffset, 4);
		FileSeek(m_hFile, m_iNameOffset-4, SEEK_CUR);
		ReadFileString(m_hFile, STRING(m_szMaterial));

		Format(files[m_iIdx], maxlen2, "materials\\%s%s.vmt", m_szPath, m_szMaterial);
	}

	return m_iNum;
}

new String:g_szModelExts[][16] = {".phy", ".sw.vtx", ".dx80.vtx", ".dx90.vtx", ".vtx", ".xbox.vtx", ".vvd"};
stock Downloader_GetModelFiles(const String:model[], const String:internal[], String:files[][], maxsize, maxlen)
{
	decl String:m_szRawPath1[PLATFORM_MAX_PATH];
	decl String:m_szRawPath2[PLATFORM_MAX_PATH];
	strcopy(STRING(m_szRawPath1), model);
	Format(STRING(m_szRawPath2), "models/%s", internal);

	new m_iDot = FindCharInString(m_szRawPath1, '.', true);
	if(m_iDot == -1)
		return 0;
	m_szRawPath1[m_iDot] = 0;

	m_iDot = FindCharInString(m_szRawPath2, '.', true);
	if(m_iDot == -1)
		return 0;
	m_szRawPath2[m_iDot] = 0;

	new m_iNum = 0;
	for(new i=0;i<sizeof(g_szModelExts);++i)
	{
		if(m_iNum == maxsize)
			break;
		Format(files[m_iNum], maxlen, "%s%s", m_szRawPath1, g_szModelExts[i]);
		if(FileExists2(files[m_iNum]))
			++m_iNum;
		else
		{
			Format(files[m_iNum], maxlen, "%s%s", m_szRawPath2, g_szModelExts[i]);
			if(FileExists2(files[m_iNum]))
				++m_iNum;
		}
	}
	return m_iNum;
}

new String:g_szMaterialKeys[][64] = {"$baseTexture", "$bumpmap", "$lightwarptexture"};
stock Downloader_GetMaterialsFromVMT(const String:vmt[], String:materials[][], maxsize, maxlen)
{
	if(!FileExists2(vmt))
		return 0;

	decl String:m_szLine[512];

	new Handle:m_hFile = OpenFile2(vmt, "r");
	
	new bool:m_bFound[sizeof(g_szMaterialKeys)];
	decl m_iPos;
	decl m_iLast;
	new m_iNum = 0;
	while(ReadFileLine(m_hFile, m_szLine, sizeof(m_szLine))!=false)
	{
		if(m_iNum == sizeof(g_szMaterialKeys) || maxsize == m_iNum)
			break;

		for(new i=0;i<sizeof(g_szMaterialKeys);++i)
		{
			if(m_bFound[i])
				continue;
			if((m_iPos = StrContains(m_szLine, g_szMaterialKeys[i], false)) > 0)
			{
				m_bFound[i]=true;
				while(m_szLine[m_iPos] != '"' && m_szLine[m_iPos] != ' ' && m_szLine[m_iPos] != '	')
					++m_iPos;
				while(m_szLine[m_iPos] == ' ' || m_szLine[m_iPos] == '	' || m_szLine[m_iPos] == '"')
					++m_iPos;
				m_iLast = m_iPos;
				while(m_szLine[m_iLast] != '"' && m_szLine[m_iLast] != '\r' && m_szLine[m_iLast] != '\n' && m_szLine[m_iLast] != ' ' && m_szLine[m_iLast] != '	' && m_szLine[m_iLast] != 0)
					++m_iLast;
				m_szLine[m_iLast] = 0;
				strcopy(materials[m_iNum], maxlen, m_szLine[m_iPos]);
				++m_iNum;
			}
		}
	}

	CloseHandle(m_hFile);

	return m_iNum;
}

new Handle:g_hCachedFiles = INVALID_HANDLE;
new Handle:g_hCachedNums = INVALID_HANDLE;
stock Downloader_AddFileToDownloadsTable(const String:filename[])
{
	if(!FileExists2(filename))
		return 0;

	if(g_hCachedNums == INVALID_HANDLE)
	{
		g_hCachedNums = CreateTrie();
		g_hCachedFiles = CreateArray(PLATFORM_MAX_PATH);
	}

	AddFileToDownloadsTable(filename);

	decl m_iValue;
	if(GetTrieValue(g_hCachedNums, filename, m_iValue))
	{
		new m_iStart = FindStringInArray(g_hCachedFiles, filename)+1;
		decl String:m_szFile[PLATFORM_MAX_PATH];
		for(new i=m_iStart-m_iValue-1;i<m_iStart-1;++i)
		{
			if(i<0)
				break;
			GetArrayString(g_hCachedFiles, i, m_szFile, sizeof(m_szFile));
			AddFileToDownloadsTable(m_szFile);
		}
		return true;
	}

	decl String:m_szExt[16];
	new m_iDot = FindCharInString(filename, '.', true);
	if(m_iDot == -1)
		return true;

	new m_iNumFiles = 0;

	strcopy(m_szExt, sizeof(m_szExt), filename[m_iDot]);
	decl String:m_szMaterials[32][PLATFORM_MAX_PATH];
	decl m_iNum;
	if(strcmp(m_szExt, ".mdl") == 0)
	{
		decl String:m_szFiles[sizeof(g_szModelExts)][PLATFORM_MAX_PATH];
		new String:m_szInternal[64];

		m_iNum = Downloader_ParseMDL(filename, STRING(m_szInternal), m_szMaterials, sizeof(m_szMaterials), sizeof(m_szMaterials[]));
		for(new i=0;i<m_iNum;++i)
		{
			if(FileExists2(m_szMaterials[i]))
				m_iNumFiles += Downloader_AddFileToDownloadsTable(m_szMaterials[i])+1;
		}

		m_iNum = Downloader_GetModelFiles(filename, m_szInternal, m_szFiles, sizeof(m_szFiles), sizeof(m_szFiles[]));
		for(new i=0;i<m_iNum;++i)
			m_iNumFiles += Downloader_AddFileToDownloadsTable(m_szFiles[i])+1;
	} else if(strcmp(m_szExt, ".vmt") == 0)
	{
		m_iNum = Downloader_GetMaterialsFromVMT(filename, m_szMaterials, sizeof(m_szMaterials), sizeof(m_szMaterials[]));
		decl String:m_szMaterial[PLATFORM_MAX_PATH];
		for(new i=0;i<m_iNum;++i)
		{
			Format(m_szMaterial, sizeof(m_szMaterial), "materials\\%s.vtf", m_szMaterials[i]);
			if(FileExists2(m_szMaterial))
				m_iNumFiles += Downloader_AddFileToDownloadsTable(m_szMaterial)+1;
		}
	}

	PushArrayString(g_hCachedFiles, filename);
	SetTrieValue(g_hCachedNums, filename, m_iNumFiles);

	return m_iNumFiles;
}

new Handle:g_hCustomFiles = INVALID_HANDLE;

public CacheCustomDirectory()
{
	g_hCustomFiles = CreateTrie();

	new Handle:m_hDir = OpenDirectory("custom");
	if(m_hDir == INVALID_HANDLE)
		return;

	new String:m_szDirectory[PLATFORM_MAX_PATH] = "custom/";
	decl FileType:m_eType;
	new m_unLen = strlen(m_szDirectory);

	while(ReadDirEntry(m_hDir, m_szDirectory[m_unLen], sizeof(m_szDirectory)-m_unLen, m_eType))
	{
		if(m_eType != FileType_Directory)
			continue;

		if(strcmp(m_szDirectory[m_unLen], ".")==0 || strcmp(m_szDirectory[m_unLen], "..")==0)
			continue;

		CacheDirectory(m_szDirectory);
	}
	CloseHandle(m_hDir);
}

public CacheDirectory(const String:directory[])
{
	new Handle:m_hDir = OpenDirectory(directory);
	decl String:m_szPath[PLATFORM_MAX_PATH];
	decl FileType:m_eType;
	Format(STRING(m_szPath), "%s/", directory);
	new m_unLen = strlen(m_szPath);
	new m_unOffset = FindCharInString(m_szPath, '/')+1;
	m_unOffset += FindCharInString(m_szPath[m_unOffset], '/')+1;

	while(ReadDirEntry(m_hDir, m_szPath[m_unLen], sizeof(m_szPath)-m_unLen, m_eType))
	{
		if(strcmp(m_szPath[m_unLen], ".")==0 || strcmp(m_szPath[m_unLen], "..")==0)
			continue;

		if(m_eType == FileType_Directory)
			CacheDirectory(m_szPath);
		else if(m_eType == FileType_File)
		{
			SetTrieString(g_hCustomFiles, m_szPath[m_unOffset], m_szPath);
		}
	}
	CloseHandle(m_hDir);
}

stock Handle:OpenFile2(const String:file[], const String:mode[])
{
	if(g_hCustomFiles == INVALID_HANDLE)
		CacheCustomDirectory();

	decl String:m_szPath[PLATFORM_MAX_PATH];
	if(!GetTrieString(g_hCustomFiles, file, STRING(m_szPath)))
	{
		strcopy(STRING(m_szPath), file);
	}

	return OpenFile(m_szPath, mode);
}

stock bool:FileExists2(const String:file[])
{
	if(g_hCustomFiles == INVALID_HANDLE)
		CacheCustomDirectory();

	decl String:m_szPath[PLATFORM_MAX_PATH];
	if(!GetTrieString(g_hCustomFiles, file, STRING(m_szPath)))
		return FileExists(file);

	return FileExists(m_szPath);
}

// Zeph Colors

new Handle:g_hNormalTrie = INVALID_HANDLE;
new Handle:g_hRGBTrie = INVALID_HANDLE;

new bool:g_bGames = false;
new bool:g_bCSS = false;
new bool:g_bCSGO = false;
new bool:g_bTF = false;
new bool:g_bDOD = false;
new bool:g_bL4D = false;
new bool:g_bL4D2 = false;
new bool:g_bND = false;

stock FillNormalTrie()
{
	g_hNormalTrie = CreateTrie();
	SetTrieValue(g_hNormalTrie, "white", 0x1);
	SetTrieValue(g_hNormalTrie, "default", 0x1);
	SetTrieValue(g_hNormalTrie, "darkred", 0x2);
	SetTrieValue(g_hNormalTrie, "green", 0x4);
	SetTrieValue(g_hNormalTrie, "teamcolor", 0x3);
	SetTrieValue(g_hNormalTrie, "lightgreen", 0x3);
	SetTrieValue(g_hNormalTrie, "red", 0x3);
	SetTrieValue(g_hNormalTrie, "blue", 0x3);
	SetTrieValue(g_hNormalTrie, "olive", 0x5);
	SetTrieValue(g_hNormalTrie, "lime", 0x6);
	SetTrieValue(g_hNormalTrie, "lightred", 0x7);
	SetTrieValue(g_hNormalTrie, "purple", 0x3);
	SetTrieValue(g_hNormalTrie, "grey", 0x8);
	SetTrieValue(g_hNormalTrie, "gray", 0x8);
	SetTrieValue(g_hNormalTrie, "yellow", 0x9);
	SetTrieValue(g_hNormalTrie, "lightblue", 0xB);
	SetTrieValue(g_hNormalTrie, "blue", 0xC);
	SetTrieValue(g_hNormalTrie, "purple", 0xE);
	SetTrieValue(g_hNormalTrie, "darkorange", 0xF);
	SetTrieValue(g_hNormalTrie, "orange", 0x10);
}

stock FillRGBTrie()
{
	g_hRGBTrie = CreateTrie();
	if(g_bTF)
		SetTrieValue(g_hRGBTrie, "default", 0xFBECCB);
	else
		SetTrieValue(g_hRGBTrie, "default", 0xFFB400);
	SetTrieValue(g_hRGBTrie, "aliceblue", 0xF0F8FF);
	SetTrieValue(g_hRGBTrie, "allies", 0x4D7942);
	SetTrieValue(g_hRGBTrie, "antiquewhite", 0xFAEBD7);
	SetTrieValue(g_hRGBTrie, "aqua", 0x00FFFF);
	SetTrieValue(g_hRGBTrie, "aquamarine", 0x7FFFD4);
	SetTrieValue(g_hRGBTrie, "axis", 0xFF4040);
	SetTrieValue(g_hRGBTrie, "azure", 0x007FFF);
	SetTrieValue(g_hRGBTrie, "beige", 0xF5F5DC);
	SetTrieValue(g_hRGBTrie, "bisque", 0xFFE4C4);
	SetTrieValue(g_hRGBTrie, "black", 0x000000);
	SetTrieValue(g_hRGBTrie, "blanchedalmond", 0xFFEBCD);
	SetTrieValue(g_hRGBTrie, "blue", 0x99CCFF);
	SetTrieValue(g_hRGBTrie, "blueviolet", 0x8A2BE2);
	SetTrieValue(g_hRGBTrie, "brown", 0xA52A2A);
	SetTrieValue(g_hRGBTrie, "burlywood", 0xDEB887);
	SetTrieValue(g_hRGBTrie, "cadetblue", 0x5F9EA0);
	SetTrieValue(g_hRGBTrie, "chartreuse", 0x7FFF00);
	SetTrieValue(g_hRGBTrie, "chocolate", 0xD2691E);
	SetTrieValue(g_hRGBTrie, "community", 0x70B04A);
	SetTrieValue(g_hRGBTrie, "coral", 0xFF7F50);
	SetTrieValue(g_hRGBTrie, "cornflowerblue", 0x6495ED);
	SetTrieValue(g_hRGBTrie, "cornsilk", 0xFFF8DC);
	SetTrieValue(g_hRGBTrie, "crimson", 0xDC143C);
	SetTrieValue(g_hRGBTrie, "cyan", 0x00FFFF);
	SetTrieValue(g_hRGBTrie, "darkblue", 0x00008B);
	SetTrieValue(g_hRGBTrie, "darkcyan", 0x008B8B);
	SetTrieValue(g_hRGBTrie, "darkgoldenrod", 0xB8860B);
	SetTrieValue(g_hRGBTrie, "darkgray", 0xA9A9A9);
	SetTrieValue(g_hRGBTrie, "darkgrey", 0xA9A9A9);
	SetTrieValue(g_hRGBTrie, "darkgreen", 0x006400);
	SetTrieValue(g_hRGBTrie, "darkkhaki", 0xBDB76B);
	SetTrieValue(g_hRGBTrie, "darkmagenta", 0x8B008B);
	SetTrieValue(g_hRGBTrie, "darkolivegreen", 0x556B2F);
	SetTrieValue(g_hRGBTrie, "darkorange", 0xFF8C00);
	SetTrieValue(g_hRGBTrie, "darkorchid", 0x9932CC);
	SetTrieValue(g_hRGBTrie, "darkred", 0x8B0000);
	SetTrieValue(g_hRGBTrie, "darksalmon", 0xE9967A);
	SetTrieValue(g_hRGBTrie, "darkseagreen", 0x8FBC8F);
	SetTrieValue(g_hRGBTrie, "darkslateblue", 0x483D8B);
	SetTrieValue(g_hRGBTrie, "darkslategray", 0x2F4F4F);
	SetTrieValue(g_hRGBTrie, "darkslategrey", 0x2F4F4F);
	SetTrieValue(g_hRGBTrie, "darkturquoise", 0x00CED1);
	SetTrieValue(g_hRGBTrie, "darkviolet", 0x9400D3);
	SetTrieValue(g_hRGBTrie, "deeppink", 0xFF1493);
	SetTrieValue(g_hRGBTrie, "deepskyblue", 0x00BFFF);
	SetTrieValue(g_hRGBTrie, "dimgray", 0x696969);
	SetTrieValue(g_hRGBTrie, "dimgrey", 0x696969);
	SetTrieValue(g_hRGBTrie, "dodgerblue", 0x1E90FF);
	SetTrieValue(g_hRGBTrie, "firebrick", 0xB22222);
	SetTrieValue(g_hRGBTrie, "floralwhite", 0xFFFAF0);
	SetTrieValue(g_hRGBTrie, "forestgreen", 0x228B22);
	SetTrieValue(g_hRGBTrie, "fuchsia", 0xFF00FF);
	SetTrieValue(g_hRGBTrie, "fullblue", 0x0000FF);
	SetTrieValue(g_hRGBTrie, "fullred", 0xFF0000);
	SetTrieValue(g_hRGBTrie, "gainsboro", 0xDCDCDC);
	SetTrieValue(g_hRGBTrie, "genuine", 0x4D7455);
	SetTrieValue(g_hRGBTrie, "ghostwhite", 0xF8F8FF);
	SetTrieValue(g_hRGBTrie, "gold", 0xFFD700);
	SetTrieValue(g_hRGBTrie, "goldenrod", 0xDAA520);
	SetTrieValue(g_hRGBTrie, "gray", 0xCCCCCC);
	SetTrieValue(g_hRGBTrie, "grey", 0xCCCCCC);
	SetTrieValue(g_hRGBTrie, "green", 0x3EFF3E);
	SetTrieValue(g_hRGBTrie, "greenyellow", 0xADFF2F);
	SetTrieValue(g_hRGBTrie, "haunted", 0x38F3AB);
	SetTrieValue(g_hRGBTrie, "honeydew", 0xF0FFF0);
	SetTrieValue(g_hRGBTrie, "hotpink", 0xFF69B4);
	SetTrieValue(g_hRGBTrie, "indianred", 0xCD5C5C);
	SetTrieValue(g_hRGBTrie, "indigo", 0x4B0082);
	SetTrieValue(g_hRGBTrie, "ivory", 0xFFFFF0);
	SetTrieValue(g_hRGBTrie, "khaki", 0xF0E68C);
	SetTrieValue(g_hRGBTrie, "lavender", 0xE6E6FA);
	SetTrieValue(g_hRGBTrie, "lavenderblush", 0xFFF0F5);
	SetTrieValue(g_hRGBTrie, "lawngreen", 0x7CFC00);
	SetTrieValue(g_hRGBTrie, "lemonchiffon", 0xFFFACD);
	SetTrieValue(g_hRGBTrie, "lightblue", 0xADD8E6);
	SetTrieValue(g_hRGBTrie, "lightcoral", 0xF08080);
	SetTrieValue(g_hRGBTrie, "lightcyan", 0xE0FFFF);
	SetTrieValue(g_hRGBTrie, "lightgoldenrodyellow", 0xFAFAD2);
	SetTrieValue(g_hRGBTrie, "lightgray", 0xD3D3D3);
	SetTrieValue(g_hRGBTrie, "lightgrey", 0xD3D3D3);
	SetTrieValue(g_hRGBTrie, "lightgreen", 0x99FF99);
	SetTrieValue(g_hRGBTrie, "lightpink", 0xFFB6C1);
	SetTrieValue(g_hRGBTrie, "lightsalmon", 0xFFA07A);
	SetTrieValue(g_hRGBTrie, "lightseagreen", 0x20B2AA);
	SetTrieValue(g_hRGBTrie, "lightskyblue", 0x87CEFA);
	SetTrieValue(g_hRGBTrie, "lightslategray", 0x778899);
	SetTrieValue(g_hRGBTrie, "lightslategrey", 0x778899);
	SetTrieValue(g_hRGBTrie, "lightsteelblue", 0xB0C4DE);
	SetTrieValue(g_hRGBTrie, "lightyellow", 0xFFFFE0);
	SetTrieValue(g_hRGBTrie, "lime", 0x00FF00);
	SetTrieValue(g_hRGBTrie, "limegreen", 0x32CD32);
	SetTrieValue(g_hRGBTrie, "linen", 0xFAF0E6);
	SetTrieValue(g_hRGBTrie, "magenta", 0xFF00FF);
	SetTrieValue(g_hRGBTrie, "maroon", 0x800000);
	SetTrieValue(g_hRGBTrie, "mediumaquamarine", 0x66CDAA);
	SetTrieValue(g_hRGBTrie, "mediumblue", 0x0000CD);
	SetTrieValue(g_hRGBTrie, "mediumorchid", 0xBA55D3);
	SetTrieValue(g_hRGBTrie, "mediumpurple", 0x9370D8);
	SetTrieValue(g_hRGBTrie, "mediumseagreen", 0x3CB371);
	SetTrieValue(g_hRGBTrie, "mediumslateblue", 0x7B68EE);
	SetTrieValue(g_hRGBTrie, "mediumspringgreen", 0x00FA9A);
	SetTrieValue(g_hRGBTrie, "mediumturquoise", 0x48D1CC);
	SetTrieValue(g_hRGBTrie, "mediumvioletred", 0xC71585);
	SetTrieValue(g_hRGBTrie, "midnightblue", 0x191970);
	SetTrieValue(g_hRGBTrie, "mintcream", 0xF5FFFA);
	SetTrieValue(g_hRGBTrie, "mistyrose", 0xFFE4E1);
	SetTrieValue(g_hRGBTrie, "moccasin", 0xFFE4B5);
	SetTrieValue(g_hRGBTrie, "navajowhite", 0xFFDEAD);
	SetTrieValue(g_hRGBTrie, "navy", 0x000080);
	SetTrieValue(g_hRGBTrie, "normal", 0xB2B2B2);
	SetTrieValue(g_hRGBTrie, "oldlace", 0xFDF5E6);
	SetTrieValue(g_hRGBTrie, "olive", 0x9EC34F);
	SetTrieValue(g_hRGBTrie, "olivedrab", 0x6B8E23);
	SetTrieValue(g_hRGBTrie, "orange", 0xFFA500);
	SetTrieValue(g_hRGBTrie, "orangered", 0xFF4500);
	SetTrieValue(g_hRGBTrie, "orchid", 0xDA70D6);
	SetTrieValue(g_hRGBTrie, "palegoldenrod", 0xEEE8AA);
	SetTrieValue(g_hRGBTrie, "palegreen", 0x98FB98);
	SetTrieValue(g_hRGBTrie, "paleturquoise", 0xAFEEEE);
	SetTrieValue(g_hRGBTrie, "palevioletred", 0xD87093);
	SetTrieValue(g_hRGBTrie, "papayawhip", 0xFFEFD5);
	SetTrieValue(g_hRGBTrie, "peachpuff", 0xFFDAB9);
	SetTrieValue(g_hRGBTrie, "peru", 0xCD853F);
	SetTrieValue(g_hRGBTrie, "pink", 0xFFC0CB);
	SetTrieValue(g_hRGBTrie, "plum", 0xDDA0DD);
	SetTrieValue(g_hRGBTrie, "powderblue", 0xB0E0E6);
	SetTrieValue(g_hRGBTrie, "purple", 0x800080);
	SetTrieValue(g_hRGBTrie, "red", 0xFF4040);
	SetTrieValue(g_hRGBTrie, "lightred", 0xFF8080);
	SetTrieValue(g_hRGBTrie, "rosybrown", 0xBC8F8F);
	SetTrieValue(g_hRGBTrie, "royalblue", 0x4169E1);
	SetTrieValue(g_hRGBTrie, "saddlebrown", 0x8B4513);
	SetTrieValue(g_hRGBTrie, "salmon", 0xFA8072);
	SetTrieValue(g_hRGBTrie, "sandybrown", 0xF4A460);
	SetTrieValue(g_hRGBTrie, "seagreen", 0x2E8B57);
	SetTrieValue(g_hRGBTrie, "seashell", 0xFFF5EE);
	SetTrieValue(g_hRGBTrie, "selfmade", 0x70B04A);
	SetTrieValue(g_hRGBTrie, "sienna", 0xA0522D);
	SetTrieValue(g_hRGBTrie, "silver", 0xC0C0C0);
	SetTrieValue(g_hRGBTrie, "skyblue", 0x87CEEB);
	SetTrieValue(g_hRGBTrie, "slateblue", 0x6A5ACD);
	SetTrieValue(g_hRGBTrie, "slategray", 0x708090);
	SetTrieValue(g_hRGBTrie, "slategrey", 0x708090);
	SetTrieValue(g_hRGBTrie, "snow", 0xFFFAFA);
	SetTrieValue(g_hRGBTrie, "springgreen", 0x00FF7F);
	SetTrieValue(g_hRGBTrie, "steelblue", 0x4682B4);
	SetTrieValue(g_hRGBTrie, "strange", 0xCF6A32);
	SetTrieValue(g_hRGBTrie, "tan", 0xD2B48C);
	SetTrieValue(g_hRGBTrie, "teal", 0x008080);
	SetTrieValue(g_hRGBTrie, "thistle", 0xD8BFD8);
	SetTrieValue(g_hRGBTrie, "tomato", 0xFF6347);
	SetTrieValue(g_hRGBTrie, "turquoise", 0x40E0D0);
	SetTrieValue(g_hRGBTrie, "unique", 0xFFD700);
	SetTrieValue(g_hRGBTrie, "unusual", 0x8650AC);
	SetTrieValue(g_hRGBTrie, "valve", 0xA50F79);
	SetTrieValue(g_hRGBTrie, "vintage", 0x476291);
	SetTrieValue(g_hRGBTrie, "violet", 0xEE82EE);
	SetTrieValue(g_hRGBTrie, "wheat", 0xF5DEB3);
	SetTrieValue(g_hRGBTrie, "white", 0xFFFFFF);
	SetTrieValue(g_hRGBTrie, "whitesmoke", 0xF5F5F5);
	SetTrieValue(g_hRGBTrie, "yellow", 0xFFFF00);
	SetTrieValue(g_hRGBTrie, "yellowgreen", 0x9ACD32); 
}

stock ReplaceColors(String:text[], maxlen, client = 0)
{
	if(!g_bGames)
		IdentifyGame();

	if(g_hRGBTrie == INVALID_HANDLE)
		FillRGBTrie();

	if(g_hNormalTrie == INVALID_HANDLE)
		FillNormalTrie();

	new m_iPos = FindCharInString(text, '{');
	if(m_iPos == -1)
		return;

	decl String:m_szBuffer[maxlen];
	new m_iPad = 1;
	if(text[0] != 1)
		m_szBuffer[0]=0x1;
	if(g_bCSGO && text[1] != ' ')
	{
		m_szBuffer[1] = ' ';
		++m_iPad;
	}

	strcopy(m_szBuffer[m_iPad], maxlen-m_iPad, text);

	decl String:m_szSubstring[256];
	decl String:m_szReplace[256];
	decl bool:m_bRet;
	decl m_iValue;

	// Setting a single byte is probably faster and produces less code than checking three
	m_szReplace[1] = 0;
	
	decl m_iEnd;
	do
	{
		m_iEnd = FindCharInString(text[m_iPos], '}');

		if(m_iEnd == -1)
			break;


		strcopy(m_szSubstring, m_iEnd+2, text[m_iPos]);
		m_iPos += m_iEnd+2;

		m_szSubstring[strlen(m_szSubstring)-1] = 0;
		if(g_bCSS || g_bDOD || g_bTF)
		{
			m_bRet = GetTrieValue(g_hRGBTrie, m_szSubstring[1], m_iValue);
			if(client != 0 && !m_bRet && strcmp(m_szSubstring[1], "teamcolor")==0)
			{
				m_bRet = true;
				new m_iTeam = GetClientTeam(client);
				if(m_iTeam == 1)
						m_iValue = 0xCCCCCC;
				else if(g_bDOD)
				{
					if(m_iTeam == 2)
						m_iValue = 0x4D7942;
					else if(m_iTeam == 3)
						m_iValue = 0xFF4040;
				}
				else if(g_bCSS || g_bTF)
				{
					if(m_iTeam == 2)
						m_iValue = 0xFF4040;
					else if(m_iTeam == 3)
						m_iValue = 0x99CCFF;
				}
			}
		}
		else
			m_bRet = GetTrieValue(g_hNormalTrie, m_szSubstring[1], m_iValue);

		if(!m_bRet)
			continue;

		m_szSubstring[strlen(m_szSubstring)] = '}';

		if(g_bCSS || g_bDOD || g_bTF)
			Format(STRING(m_szReplace), "\x07%06X", m_iValue);
		else
			m_szReplace[0] = m_iValue;

		ReplaceString(m_szBuffer, maxlen, m_szSubstring, m_szReplace, false);
	} while ((m_iPos += FindCharInString(text[m_iPos], '{')) != -1);

	strcopy(text, maxlen, m_szBuffer);
}

stock IdentifyGame()
{
	decl String:m_szGameDir[64];
	GetGameFolderName(STRING(m_szGameDir));
	if(strcmp(m_szGameDir, "cstrike")==0)
		g_bCSS = true;
	else if(strcmp(m_szGameDir, "csgo")==0)
		g_bCSGO = true;
	else if(strcmp(m_szGameDir, "tf")==0)
		g_bTF = true;
	else if(strcmp(m_szGameDir, "dod")==0)
		g_bDOD = true;
	else if(strcmp(m_szGameDir, "l4d")==0)
		g_bL4D = true;
	else if(strcmp(m_szGameDir, "l4d2")==0)
		g_bL4D2 = true;
	else if(strcmp(m_szGameDir, "nucleardawn")==0)
		g_bND = true;
}

stock bool:IsPluginLoaded(String:name[])
{
	new String:m_szName[PLATFORM_MAX_PATH];
	new Handle:pluginIterator = GetPluginIterator();
	while (MorePlugins(pluginIterator))
	{
		new Handle:currentPlugin = ReadPlugin(pluginIterator);
		GetPluginFilename(currentPlugin, STRING(m_szName));
		m_szName[strlen(m_szName)-4]=0;
		if(strcmp(name, m_szName)==0)
			return true;
	}
	return false;
}

stock PrecacheModel2(const String:model[], bool:preload=false)
{
	static m_unModelPrecache = INVALID_STRING_TABLE;
	//static m_unDynamicModel = INVALID_STRING_TABLE;
	//static m_unModelPrecacheMax = 0;
	//static m_unDynamicModelMax = 0;
	if(m_unModelPrecache == INVALID_STRING_TABLE)
	{
		m_unModelPrecache = FindStringTable("modelprecache");
		//m_unModelPrecacheMax = GetStringTableMaxStrings(m_unModelPrecache);
	}
	/*if(m_unDynamicModel == INVALID_STRING_TABLE)
	{
		m_unDynamicModel = FindStringTable("dynamicmodel");
		if(m_unDynamicModel == INVALID_STRING_TABLE)
			m_unDynamicModel = -2;
		else
			m_unDynamicModelMax = GetStringTableMaxStrings(m_unDynamicModel);
	}*/

	return PrecacheModel(model, preload);

	/*if(GetStringTableNumStrings(m_unModelPrecache)<m_unModelPrecacheMax)
	{
		return PrecacheModel(model, preload);
	}
	else if(m_unDynamicModel != -2)
	{
		new idx = PrecacheDynamicModel(model);
		return idx;
	}

	return 0;*/
}

stock StringTableContains(const table, const String:model[])
{
	new String:str[PLATFORM_MAX_PATH];
	for(new i=0;i<GetStringTableNumStrings(table);++i)
	{
		ReadStringTable(table, i, STRING(str));
		if(strcmp(str, model)==0)
			return i;
	}
	return 0;
}

stock GetLegacyAuthString(client, String:out[], maxlen, bool:validate=true)
{
	new String:m_szSteamID[32];
	new bool:success = GetClientAuthId(client, AuthId_Steam2, STRING(m_szSteamID), validate);

	if(m_szSteamID[0]=='[')
	{
		new m_unAccountID = StringToInt(m_szSteamID[5]);
		new m_unMod = m_unAccountID % 2;
		Format(out, maxlen, "STEAM_0:%d:%d", m_unMod, (m_unAccountID-m_unMod)/2);
	}
	else
	{
		strcopy(out, maxlen, m_szSteamID);
	}

	return success;
}

stock GetFriendID(client, bool:validate=true)
{
	new String:auth[32];
	GetLegacyAuthString(client, STRING(auth), validate);

	return ToAccountID(auth);
}

stock ToAccountID(String:auth[])
{
	if(strlen(auth)<11)
		return 0;
	return StringToInt(auth[10])*2 + auth[8]-48;
}