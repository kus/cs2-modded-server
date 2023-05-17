#if !defined _smartdm_include
#define _smartdm_include

#define STRING(%1) %1, sizeof(%1)

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
stock Downloader_AddFileToDownloadsTable(char[] filename)
{
	int len = strlen(filename);
	ReplaceString(filename, len, "\\", "/");
	for(int ch=0; ch<len; ch++){
		filename[ch] = CharToLower(filename[ch]);
	}
	
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

	decl String:m_szExt[32];
	new m_iDot = FindCharInString(filename, '.', true);
	if(m_iDot == -1)
		return true;

	new m_iNumFiles = 0;

	strcopy(m_szExt, sizeof(m_szExt), filename[m_iDot]);
	decl String:m_szMaterials[16][PLATFORM_MAX_PATH];
	decl m_iNum;
	if(strcmp(m_szExt, ".mdl") == 0)
	{
		decl String:m_szFiles[sizeof(g_szModelExts)][PLATFORM_MAX_PATH];
		new String:m_szInternal[64];

		m_iNum = Downloader_ParseMDL(filename, STRING(m_szInternal), m_szMaterials, sizeof(m_szMaterials), sizeof(m_szMaterials[]));
		for(new i=0;i<m_iNum;++i)
		{
			if(FileExists2(m_szMaterials[i])){
				m_iNumFiles += Downloader_AddFileToDownloadsTable(m_szMaterials[i])+1;
			}
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
			int len = strlen(m_szPath);
			ReplaceString(m_szPath, len, "\\", "/");
			for(int ch=0; ch<len; ch++){
				m_szPath[ch] = CharToLower(m_szPath[ch]);
			}
			SetTrieString(g_hCustomFiles, m_szPath[m_unOffset], m_szPath);
		}
	}
	CloseHandle(m_hDir);
}

stock Handle:OpenFile2(const String:file[], const String:mode[])
{
	if(g_hCustomFiles == INVALID_HANDLE)
		CacheCustomDirectory();

	decl String:file2[PLATFORM_MAX_PATH];
	strcopy(file2, PLATFORM_MAX_PATH, file);
	
	int len = strlen(file2);
	ReplaceString(file2, len, "\\", "/");
	for(int ch=0; ch<len; ch++){
		file2[ch] = CharToLower(file2[ch]);
	}
	
	decl String:m_szPath[PLATFORM_MAX_PATH];
	if(!GetTrieString(g_hCustomFiles, file2, STRING(m_szPath)))
	{
		strcopy(STRING(m_szPath), file2);
	}

	return OpenFile(m_szPath, mode);
}

stock bool:FileExists2(const String:file[])
{
	if(g_hCustomFiles == INVALID_HANDLE){
		CacheCustomDirectory();
	}
	
	decl String:file2[PLATFORM_MAX_PATH];
	strcopy(file2, PLATFORM_MAX_PATH, file);
	
	int len = strlen(file2);
	ReplaceString(file2, len, "\\", "/");
	for(int ch=0; ch<len; ch++){
		file2[ch] = CharToLower(file2[ch]);
	}
			
	decl String:m_szPath[PLATFORM_MAX_PATH];
	if(!GetTrieString(g_hCustomFiles, file2, STRING(m_szPath))){
		return FileExists(file2);
	}
	return FileExists(m_szPath);
}

#endif