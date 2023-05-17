#if defined _abner_sound_included
 #endinput
#endif
#define _abner_sound_included

#include <emitsoundany>
#undef REQUIRE_EXTENSIONS
#tryinclude <soundlib>
#define REQUIRE_EXTENSIONS


//MapSounds Stuff
int g_iSoundEnts[2048];
int g_iNumSounds;


float soundLenght(char[] sound)
{
	float CurrentSoundLenght = 0.0;
	if(soundLib)
	{
		Handle Sound = OpenSoundFile(sound);
		if(Sound != INVALID_HANDLE) {
			CurrentSoundLenght = GetSoundLengthFloat(Sound);
			CloseHandle(Sound);
		}
	}
	return CurrentSoundLenght;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("OpenSoundFile");
	MarkNativeAsOptional("GetSoundLengthFloat");
	return APLRes_Success;
}



public void StopMapMusic()
{
	char sSound[PLATFORM_MAX_PATH];
	int entity = INVALID_ENT_REFERENCE;
	for(int i=1;i<=MaxClients;i++){
		if(!IsClientInGame(i)){ continue; }
		for (int u=0; u<g_iNumSounds; u++){
			entity = EntRefToEntIndex(g_iSoundEnts[u]);
			if (entity != INVALID_ENT_REFERENCE){
				GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
				Client_StopSound(i, entity, SNDCHAN_STATIC, sSound);
			}
		}
	}
}


void Client_StopSound(int client, int entity, int channel, const char[] name)
{
	EmitSoundToClient(client, name, entity, channel, SNDLEVEL_NONE, SND_STOP, 0.0, SNDPITCH_NORMAL, _, _, _, true);
}



void MapSounds() 
{
    /// Ents are recreated every round.
    g_iNumSounds = 0;
    
    // Find all ambient sounds played by the map.
    char sSound[PLATFORM_MAX_PATH];
    int entity = INVALID_ENT_REFERENCE;
    
    while ((entity = FindEntityByClassname(entity, "ambient_generic")) != INVALID_ENT_REFERENCE)
    {
        GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
        
        int len = strlen(sSound);
        if (len > 4 && (StrEqual(sSound[len-3], "mp3") || StrEqual(sSound[len-3], "wav")))
        {
            g_iSoundEnts[g_iNumSounds++] = EntIndexToEntRef(entity);
        }
    }
}


int LoadSounds(ArrayList arraySounds, ConVar pathConVar)
{
	arraySounds.Clear();
	
	char soundPath[PLATFORM_MAX_PATH];
	char soundPathFull[PLATFORM_MAX_PATH];
	GetConVarString(pathConVar, soundPath, sizeof(soundPath));
	
	Format(soundPathFull, sizeof(soundPathFull), "sound/%s/", soundPath);
	DirectoryListing pluginsDir = OpenDirectory(soundPathFull);
	
	if(pluginsDir != null)
	{
		char fileName[128];
		while(pluginsDir.GetNext(fileName, sizeof(fileName)))
		{
			int extPosition = strlen(fileName) - 4;
			if(StrContains(fileName,".mp3",false) == extPosition) //.mp3 Files Only
			{
				char soundName[512];
				Format(soundName, sizeof(soundName), "sound/%s/%s", soundPath, fileName);
				AddFileToDownloadsTable(soundName);
				
				Format(soundName, sizeof(soundName), "%s/%s", soundPath, fileName);
				PrecacheSoundAny(soundName);
				arraySounds.PushString(soundName);
			}
		}
	}
	return arraySounds.Length;
}
 

bool GetSound(ArrayList arraySounds, ConVar pathConVar, bool random, char[] szSound, int soundSize)
{
	if(arraySounds.Length <= 0)
		return false;
		
	int soundToPlay = 0;
	if(random)
	{
		soundToPlay = GetRandomInt(0, arraySounds.Length-1);
	}
	
	arraySounds.GetString(soundToPlay, szSound, soundSize);
	arraySounds.Erase(soundToPlay);
	// PlayMusicAll(szSound);
    
	if(arraySounds.Length == 0)
		LoadSounds(arraySounds, pathConVar);
		
	return true;
}



void PlaySoundClient(int client, char[] szSound, float selectedVolume)
{
    if(!IsValidClient(client))
        return;


    if(GetEngineVersion() == Engine_CSGO)
    { 
        ClientCommand(client, "playgamesound Music.StopAllMusic");
    }
    
    EmitSoundToClientAny(client, szSound, -2, 0, 0, 0, selectedVolume, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}


