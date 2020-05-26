#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

// Plugin Informaiton  
#define VERSION "1.03"

//Paths
#define CONFIG_BASE_PATH "configs/easydownloader/"
#define CONFIG_MAX_LINE_LENGTH 1024
#define EXTENSION_MAX_LENGTH 255
#define MAX_OPTIONS_GROUPS 2
#define OPTIONS_GROUP_SEPARATOR "|"
#define OPTIONS_EXTS_ARGPREFIX "exts="
#define OPTIONS_EXTS_SEPARATOR ","

//Enums
enum Mode
{
  Mode_Decals,
  Mode_Generics,
  Mode_Models,
  Mode_SentenceFiles,
  Mode_Sounds,
  Mode_DownloadOnly
};

char g_ModelNiceNames[Mode][PLATFORM_MAX_PATH];
bool g_ShouldFakePrecacheSound = false;

public Plugin myinfo =
{
  name = "Easy Downloader",
  author = "Invex | Byte",
  description = "Download/Precache Files.",
  version = VERSION,
  url = "http://www.invexgaming.com.au"
};

public void OnPluginStart()
{
  g_ModelNiceNames[Mode_Decals] = "decals.txt";
  g_ModelNiceNames[Mode_Generics] = "generics.txt";
  g_ModelNiceNames[Mode_Models] = "models.txt";
  g_ModelNiceNames[Mode_SentenceFiles] = "sentencefiles.txt";
  g_ModelNiceNames[Mode_Sounds] = "sounds.txt";
  g_ModelNiceNames[Mode_DownloadOnly] = "downloadonly.txt";
  
  EngineVersion engineVersion = GetEngineVersion();
  if (engineVersion == Engine_CSGO || engineVersion == Engine_DOTA) {
    g_ShouldFakePrecacheSound = true;
  }
}

public void OnMapStart()
{
  //Read and process config files for all modes
  ReadAndProcessConfig(Mode_Decals);
  ReadAndProcessConfig(Mode_Generics);
  ReadAndProcessConfig(Mode_Models);
  ReadAndProcessConfig(Mode_SentenceFiles);
  ReadAndProcessConfig(Mode_Sounds);
  ReadAndProcessConfig(Mode_DownloadOnly);
}

/**
* Read and process config files based on input mode 
*/
public void ReadAndProcessConfig(Mode mode)
{
  char configFilePath[PLATFORM_MAX_PATH];
  Format(configFilePath, sizeof(configFilePath), "%s%s", CONFIG_BASE_PATH, g_ModelNiceNames[mode]);
  BuildPath(Path_SM, configFilePath, PLATFORM_MAX_PATH, configFilePath);
  
  if (FileExists(configFilePath)) {
    //Open config file
    File file = OpenFile(configFilePath, "r");
    
    if (file != null) {
      char buffer[CONFIG_MAX_LINE_LENGTH];
      
      //For each file in the text file
      while (file.ReadLine(buffer, sizeof(buffer))) {
        //Remove final new line
        //buffer length > 0 check needed in case file is completely empty and there is no new line '\n' char after empty string ""
        if (strlen(buffer) > 0 && buffer[strlen(buffer) - 1] == '\n')
          buffer[strlen(buffer) - 1] = '\0';
        
        //Remove any whitespace at either end
        TrimString(buffer);
        
        //Ignore empty lines
        if (strlen(buffer) == 0)
          continue;
          
        //Ignore comment lines
        if (StrContains(buffer, "//") == 0)
          continue; 
        
        //Variables
        char path[PLATFORM_MAX_PATH];
        ArrayList exts = new ArrayList(EXTENSION_MAX_LENGTH);
        
        //Process option groups (separated by spaces)
        char buffers[MAX_OPTIONS_GROUPS][255];
        int numOptionGroups = ExplodeString(buffer, OPTIONS_GROUP_SEPARATOR, buffers, sizeof(buffers), sizeof(buffers[]), false);
        
        if (numOptionGroups == -1) {
          //No option groups, path is complete buffer
          StripQuotes(buffer);
          Format(path, sizeof(path), buffer);
        }
        else {
          //Process Option Groups
          for (int i = 0; i < numOptionGroups; ++i) {
            
            //Path is always first option group
            if (i == 0) {
              TrimString(buffers[i]);
              StripQuotes(buffers[i]);
              Format(path, sizeof(path), buffers[i]);
              continue;
            }
            
            //Extension whitelist option group
            if (StrContains(buffers[i], OPTIONS_EXTS_ARGPREFIX) == 0) {
              char extsBuffer[32][EXTENSION_MAX_LENGTH];
              
              int numExts = ExplodeString(buffers[i][strlen(OPTIONS_EXTS_ARGPREFIX)], OPTIONS_EXTS_SEPARATOR, extsBuffer, sizeof(extsBuffer), sizeof(extsBuffer[]), false);
              if (numExts != -1) {
                for (int j = 0; j < numExts; ++j) {
                  exts.PushString(extsBuffer[j]);
                }
              }
            }
          }
        }
        
        //Proceed if directory or file exists
        if (DirExists(path))
          ProcessDirectory(path, mode, exts);
        else if (FileExists(path))
          DownloadAndPrecache(path, mode, exts);
        else
          LogError("File/Directory '%s' does not exist. Please check entry in config file: '%s'", path, g_ModelNiceNames[mode]);
        
        //Cleanup
        delete exts;
      }
      
      file.Close();
    }
  } else {
    LogError("Missing required config file: '%s'", configFilePath);
  }
}

/**
* Process a directory recursively to precache all subfiles
*/
void ProcessDirectory(char[] directory, Mode mode, ArrayList &exts)
{
  if (DirExists(directory)) {
    //Ignore inode maps
    if (StrContains(directory, "/.") == strlen(directory)-2 || StrContains(directory, "/..") == strlen(directory)-3)
      return;
  
    DirectoryListing listing = OpenDirectory(directory);
    char subFile[PLATFORM_MAX_PATH];
    FileType subFileType;

    while (listing.GetNext(subFile, sizeof(subFile), subFileType)) {
      //Construct absolute path
      char subFilePath[PLATFORM_MAX_PATH];
      Format(subFilePath, sizeof(subFilePath), "%s/%s", directory, subFile);
    
      if (subFileType == FileType_File)
        DownloadAndPrecache(subFilePath, mode, exts);
      else if (subFileType == FileType_Directory)
        ProcessDirectory(subFilePath, mode, exts);
    }
  }
}

/**
* Given a file path and mode, downloads and precaches files
*/
void DownloadAndPrecache(char[] file, Mode mode, ArrayList &exts)
{
  if (FileExists(file)) {
    
    //Extension Option
    if (exts.Length != 0) {
      //Check if extension is whitelisted
      char fileExtension[EXTENSION_MAX_LENGTH];
      GetFileExtension(file, fileExtension, sizeof(fileExtension));
      
      //If not in whitelist, ignore this file
      if (exts.FindString(fileExtension) == -1)
        return;
    }
    
    //Add file to downloads table
    AddFileToDownloadsTable(file);
    
    //Precache file based on mode
    if (mode == Mode_Decals) {
      PrecacheDecal(file, true);
    }
    else if (mode == Mode_Generics) {
      PrecacheGeneric(file, true);
    }
    else if (mode == Mode_Models) {
      PrecacheModel(file, true);
    }
    else if (mode == Mode_SentenceFiles) {
      PrecacheSentenceFile(file, true);
    }
    else if (mode == Mode_Sounds) {
      //Remove sound prefix
      ReplaceStringEx(file, PLATFORM_MAX_PATH, "sound/", "", -1, -1, false);
      
      if (g_ShouldFakePrecacheSound) {
        char pathStar[PLATFORM_MAX_PATH];
        Format(pathStar, sizeof(pathStar), "*%s", file);
        AddToStringTable(FindStringTable("soundprecache"), pathStar);
      } else {
        PrecacheSound(file, true);
      }
    }
  }
}

/**
* Get the extension given a file path
*/
stock bool GetFileExtension(const char[] path, char[] ext, int maxlen)
{
  //Find first dot
  int index = FindCharInString(path, '.');
  if (index == -1) {
    return false;
  }
  
  //Everything past first dot is the extension
  Format(ext, maxlen, path[index]);
  return true;
}
