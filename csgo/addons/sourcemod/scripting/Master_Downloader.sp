#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

char g_sAllowedExts[][] = 
{
    "mdl",
    "vvd",
    "vtx",
    "phy",
    "vmt",
    "vtf",
    "pcf",
    "mp3"
};

enum
{
    MDL = 0,
    VVD,
    VTX,
    PHY,
    VMT,
    VTF,
    PCF,
    MP3
}


#define			NAME 		"Simple Downloader"
#define			AUTHOR		"Master"
#define			VERSION		"1.0"
#define			URL			"https://cswild.pl/"

public Plugin myinfo =
{ 
	name	= NAME,
	author	= AUTHOR,
	version	= VERSION,
	url		= URL
};

public void OnMapStart()
{
    LoadFile();
}

void LoadFile()
{
    char sBuffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "configs/Master/Master_Downloader.txt");

    if(!FileExists(sBuffer)) SetFailState("Couldn't open file %s", sBuffer);
    
    File hFile = OpenFile(sBuffer, "r");

    if(hFile == null)
    {
        delete hFile;
        return;
    }

    while(!IsEndOfFile(hFile))
    {
        hFile.ReadLine(sBuffer, sizeof(sBuffer));
        TrimString(sBuffer);

        if(!sBuffer[0]) continue;

        if(StrContains(sBuffer, "//") != -1) continue;

        DownloadAndPrecache(sBuffer);
    }

    delete hFile;
}

void DownloadAndPrecache(char[] sFile)
{
    if(!FileExists(sFile))
    {
        LogError("File: %s doesnt exist", sFile);
        return;
    }

    char sExts[8];
    if(!GetFileExtension(sFile, sExts, sizeof(sExts))) return;

    int iIndex = -1;

    for(int i = 0; i < sizeof(g_sAllowedExts); i++)
    {
        if(StrEqual(sExts, g_sAllowedExts[i]))
        {
            iIndex = i;
            break;
        }
    }

    if(iIndex == -1)
    {
        LogError("Invalid extension: %s", sExts);
        return;
    }

    AddFileToDownloadsTable(sFile);

    if(iIndex == MDL) PrecacheModel(sFile, true);
    else if(iIndex == PCF) PrecacheGeneric(sFile, true);
    else if(iIndex == MP3)
    {
        ReplaceStringEx(sFile, PLATFORM_MAX_PATH, "sound/", "*");
        PrecacheSound(sFile, true);
    }
}

bool GetFileExtension(const char[] sPath, char[] sBuffer, int iSize)
{
    int iIndex = FindCharInString(sPath, '.', true);

    if(iIndex == -1) return false;

    strcopy(sBuffer, iSize, sPath[++iIndex]);
    return true;
}
