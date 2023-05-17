/*
 *  Thanks to Indarello - https://forums.alliedmods.net/member.php?u=265280 
 *  for the idea of blocking default map models.
 */

#include <sourcemod>
#include <sdktools>
#include <n_arms_fix>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_TAG "[-N- Arms Fix]"
#define PLUGIN_VERSION "2.0.3"

#define TEAM_T 		0
#define TEAM_CT     1

#define LEGACY_MODELS_PATH          "models/player/custom_player/legacy/"
#define MODELS_PATH                 "models/player/"

static int g_iConfigFileChange;
static int g_iProtectedMapsFileChange;

ConVar g_cvAutoSpawnCvar;
ConVar g_cvAutoSpawnBotsCvar;

Handle g_fOnClientReady;

bool g_bAutoSpawn;
bool g_bAutoSpawnBots;
bool g_bLegacyModels = true;
bool g_bProtectedMapsChanged;

char g_sCurrentMap[PLATFORM_MAX_PATH];
char g_sProtectedMapsFilePath[PLATFORM_MAX_PATH];
ArrayList g_aProtectedMaps = null;

// Config models / arms
char g_aConfigArms[2][128] = { "models/weapons/t_arms.mdl", "models/weapons/ct_arms.mdl" };
char g_aConfigModels[2][1][128] = {
    {
        "tm_leet_variantA"
    },
    {
        "ctm_st6"
    }
};

// Default models / arms - community maps
char g_aDefaultArms[2][128] = { "models/weapons/t_arms_phoenix.mdl", "models/weapons/ct_arms_sas.mdl" };
char g_aDefaultModels[2][6][128] = {
    {
        "tm_phoenix",
        "tm_phoenix_variantA",
        "tm_phoenix_variantA",
        "tm_phoenix_variantB",
        "tm_phoenix_variantC",
        "tm_phoenix_variantD"
    },
    {
        "ctm_sas",
        "ctm_sas_variantA",
        "ctm_sas_variantB",
        "ctm_sas_variantC",
        "ctm_sas_variantD",
        "ctm_sas_variantE"
    }    
};

ArrayList g_aDefaultTModels = null;
ArrayList g_aDefaultCTModels = null;

// Map models / arms - Valve maps
char g_aMapArms[2][128];
ArrayList g_aMapTModels = null;
ArrayList g_aMapCTModels = null;

public Plugin myinfo = 
{
    name = "-N- Arms Fix",
    author = "NomisCZ (-N-)",
    description = "CS:GO models arms fix",
    version = PLUGIN_VERSION,
    url = "https://github.com/NomisCZ"
};

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);

    g_cvAutoSpawnCvar = CreateConVar("sm_arms_fix_autospawn", "1", "Enable auto spawn fix (automatically sets default gloves)? 0 = False, 1 = True", _, true, 0.0, true, 1.0);
    g_cvAutoSpawnBotsCvar = CreateConVar("sm_arms_fix_bots", "1", "Enable auto spawn fix for bots? 0 = False, 1 = True", _, true, 0.0, true, 1.0);

    g_cvAutoSpawnCvar.AddChangeHook(OnConVarChanged);
    g_cvAutoSpawnBotsCvar.AddChangeHook(OnConVarChanged);

    BuildPath(Path_SM, g_sProtectedMapsFilePath, sizeof(g_sProtectedMapsFilePath), "configs/N_ArmsFix_ProtectedMaps.txt");

    InitDefaultModels();
    GenerateConfigFiles();
}

public void OnPluginEnd()
{
    DestroyAllArrayLists();
}

public void OnMapEnd()
{
    DestroyArrayList(g_aMapTModels);
    DestroyArrayList(g_aMapCTModels);
    ClearArrayList(g_aProtectedMaps);
    
    strcopy(g_aMapArms[TEAM_T], sizeof(g_aMapArms[]), "");
    strcopy(g_aMapArms[TEAM_CT], sizeof(g_aMapArms[]), "");
}

public void OnMapStart()
{
    GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));

    LoadProtectedMaps();
    GenerateConfigFiles();
    GetMapConfig();
}

public void OnConfigsExecuted()
{
    g_bAutoSpawn = g_cvAutoSpawnCvar.BoolValue;
    g_bAutoSpawnBots = g_cvAutoSpawnBotsCvar.BoolValue;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (convar == g_cvAutoSpawnCvar) {
        g_bAutoSpawn = view_as<bool>(StringToInt(newValue));
    } else if (convar == g_cvAutoSpawnBotsCvar) {
        g_bAutoSpawnBots = view_as<bool>(StringToInt(newValue));
    }
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("N_ArmsFix");

	g_fOnClientReady = CreateGlobalForward("N_ArmsFix_OnClientReady", ET_Ignore, Param_Cell);

	CreateNative("N_ArmsFix_SetClientDefaults", Native_SetClientDefault);
	CreateNative("N_ArmsFix_HasClientDefaultArms", Native_HasClientDefaultArms);
	CreateNative("N_ArmsFix_SetClientDefaultArms", Native_SetClientDefaultArms);
	CreateNative("N_ArmsFix_SetClientDefaultModel", Native_SetClientDefaultModel);

	return APLRes_Success;
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));

    if (!IsValidClient(client, false, g_bAutoSpawnBots)) {
        return;
    }

    if (g_bAutoSpawn) {
        SetClientDefault(client);
    }

    ClientReadyForward(client);
}

public void DestroyAllArrayLists()
{
    DestroyArrayList(g_aDefaultTModels);
    DestroyArrayList(g_aDefaultCTModels);
    DestroyArrayList(g_aMapTModels);
    DestroyArrayList(g_aMapCTModels);
    DestroyArrayList(g_aProtectedMaps);

    strcopy(g_aMapArms[TEAM_T], sizeof(g_aMapArms[]), "");
    strcopy(g_aMapArms[TEAM_CT], sizeof(g_aMapArms[]), "");
}

public void InitDefaultModels()
{
    g_aDefaultTModels = new ArrayList(128);
    g_aDefaultCTModels = new ArrayList(128);

    for (int i = 0; i < sizeof(g_aDefaultModels[]); i++) {
        g_aDefaultTModels.PushString(g_aDefaultModels[TEAM_T][i]);
    }

    for (int i = 0; i < sizeof(g_aDefaultModels[]); i++) {
        g_aDefaultCTModels.PushString(g_aDefaultModels[TEAM_CT][i]);
    }
}

public void LoadProtectedMaps()
{
    if (!FileExists(g_sProtectedMapsFilePath)) {

        SetFailState("Unable to find N_ArmsFix_ProtectedMaps.txt in %s", g_sProtectedMapsFilePath);
        return;
    }

    if (!IsValidArrayList(g_aProtectedMaps)) {
        g_aProtectedMaps = new ArrayList(PLATFORM_MAX_PATH);
    }

    File file = OpenFile(g_sProtectedMapsFilePath, "r");

    char fileLine[PLATFORM_MAX_PATH];
    int len;

    while (file.ReadLine(fileLine, sizeof(fileLine))) {

        len = strlen(fileLine);

        if (fileLine[len-1] == '\n') {
            fileLine[--len] = '\0';
        }

        TrimString(fileLine);

        g_aProtectedMaps.PushString(fileLine);

        if (file.EndOfFile()) {
            break;
        }
    }

    int fileLastChangeTime = GetFileTime(g_sProtectedMapsFilePath, FileTime_LastChange);

    if (fileLastChangeTime != g_iProtectedMapsFileChange) {

        g_iProtectedMapsFileChange = fileLastChangeTime;
        g_bProtectedMapsChanged = true;

    } else {
        
        g_bProtectedMapsChanged = false;
    }

    delete file;
}

public void GenerateConfigFiles()
{
    if (!FileExists("gamemodes.txt")) {

        SetFailState("Can't find gamemodes.txt file, your server is probably broken.");
        return;
    }

    if ((GetFileTime("gamemodes_server.txt", FileTime_LastChange) == g_iConfigFileChange) && !g_bProtectedMapsChanged) {

        PrintToServer("%s Nothing changed, config is ready.", PLUGIN_TAG);
        return;
    }

    KeyValues kvServer = new KeyValues("GameModes.txt");
    KeyValues kvCustom = new KeyValues("GameModes_Server.txt");

    kvServer.ImportFromFile("gamemodes.txt");
    kvServer.JumpToKey("maps");

    if (FileExists("gamemodes_server.txt")) {
        kvCustom.ImportFromFile("gamemodes_server.txt");
    } else {
        kvCustom.ExportToFile("gamemodes_server.txt");
    }
    
    kvCustom.JumpToKey("maps", true);

    DirectoryListing mapDirList = OpenDirectory("maps");

    if (mapDirList == null) {

        SetFailState("Can't find map folder.");
        return;
    }

    FileType fileType;
    char mapName[256];
    bool foundMap;

    while (mapDirList.GetNext(mapName, sizeof(mapName), fileType)) {

        if (fileType != FileType_File || StrContains(mapName, ".bsp", false) == -1) {
            continue;
        }

        foundMap = false;
        ReplaceString(mapName, sizeof(mapName), ".bsp", "", false);

        if (IsMapProtected(mapName)) {

            PrintToServer("%s Map %s is protected ...", PLUGIN_TAG, mapName);
            continue;
        }

        if (kvServer.JumpToKey(mapName)) {
            foundMap = true;
        }
 
        // + Key: mapName +
        kvCustom.JumpToKey(mapName, true);

        char nameId[128];
        char imageName[128];
        int defaultGameType;
        int defaultGameMode;
        char modelName[128];

        if (foundMap) {
            
            kvServer.GetString("nameID", nameId, sizeof(nameId), NULL_STRING);
            kvServer.GetString("imagename", imageName, sizeof(imageName), NULL_STRING);
            defaultGameType = kvServer.GetNum("default_game_type", 0);
            defaultGameMode = kvServer.GetNum("default_game_mode", 0);
            
            // + Key: original +
            kvCustom.JumpToKey("original", true);

            kvServer.GetString("t_arms", modelName, sizeof(modelName));
            kvCustom.SetString("t_arms", modelName);

            // + Key: t_models +
            GetKvKeysToKv(kvServer, "t_models", kvCustom, "t_models");
            // - Key: t_models -

            kvServer.GetString("ct_arms", modelName, sizeof(modelName));
            kvCustom.SetString("ct_arms", modelName);

            // + Key: ct_models +
            GetKvKeysToKv(kvServer, "ct_models", kvCustom, "ct_models");
            // - Key: ct_models -

            kvCustom.GoBack();
            // - Key: original -

            kvServer.DeleteThis();
            kvServer.GoBack();

        } else {

            kvCustom.GetString("nameID", nameId, sizeof(nameId), NULL_STRING);
            kvCustom.GetString("imagename", imageName, sizeof(imageName), NULL_STRING);
            defaultGameType = kvCustom.GetNum("default_game_type", 0);
            defaultGameMode = kvCustom.GetNum("default_game_mode", 0);
        }

        kvCustom.SetString("name", mapName);
        kvCustom.SetString("nameID", nameId);
        kvCustom.SetString("imagename", imageName);
        kvCustom.SetNum("default_game_type", defaultGameType);
        kvCustom.SetNum("default_game_mode", defaultGameMode);
        
        kvCustom.SetString("t_arms", g_aConfigArms[TEAM_T]);
        
        // + Key: t_models +
        kvCustom.JumpToKey("t_models", true);
        kvCustom.SetString(g_aConfigModels[TEAM_T][0], NULL_STRING);
        kvCustom.GoBack();
        // - Key: t_models -
        
        kvCustom.SetString("ct_arms", g_aConfigArms[TEAM_CT]);
        
        // + Key: ct_models +
        kvCustom.JumpToKey("ct_models", true);
        kvCustom.SetString(g_aConfigModels[TEAM_CT][0], NULL_STRING);
        kvCustom.GoBack();
        // - Key: ct_models -

        kvCustom.GoBack();
        // - Key: mapName -
    }
    
    kvServer.Rewind();
    ExportKvToFile(kvServer, "gamemodes.txt");

    kvCustom.Rewind();
    ExportKvToFile(kvCustom, "gamemodes_server.txt");
    
    delete mapDirList;
    delete kvServer;
    delete kvCustom;
    
    g_iConfigFileChange = GetFileTime("gamemodes_server.txt", FileTime_LastChange);
}

public void GetMapConfig()
{    
    if (!FileExists("gamemodes_server.txt")) {

        LogError("Oh crap, config generation failed and I can't load map config.");
        return;
    }

    bool inError = false;
    
    KeyValues kvCustom = new KeyValues("GameModes_Server.txt");
    kvCustom.ImportFromFile("gamemodes_server.txt");

    if (!kvCustom.JumpToKey("maps") || !kvCustom.JumpToKey(g_sCurrentMap)) {
        inError = true;
    }

    if (!kvCustom.JumpToKey("original")) {
        inError = true;
    }

    if (inError) {

        _GetMapConfig_Done(false);
        return;
    }

    g_aMapTModels = new ArrayList(256);
    g_aMapCTModels = new ArrayList(256);

    kvCustom.GetString("t_arms", g_aMapArms[TEAM_T], sizeof(g_aMapArms[]));
    GetKvKeysToArrayList(kvCustom, "t_models", g_aMapTModels);

    kvCustom.GetString("ct_arms", g_aMapArms[TEAM_CT], sizeof(g_aMapArms[]));
    GetKvKeysToArrayList(kvCustom, "ct_models", g_aMapCTModels);

    delete kvCustom;

    _GetMapConfig_Done(true);
}

public void _GetMapConfig_Done(bool map)
{
    PrecacheModels(map);
    PrecacheArms(map);
}

public void PrecacheModels(bool map)
{
    char modelsPath[64];
    Format(modelsPath, sizeof(modelsPath), "%s", g_bLegacyModels ? LEGACY_MODELS_PATH : MODELS_PATH);

    if (map && HasMapModels(TEAM_T) && HasMapModels(TEAM_CT)) {

        PrecacheModelsArrayList(g_aMapTModels, modelsPath);
        PrecacheModelsArrayList(g_aMapCTModels, modelsPath);

    } else {

        PrecacheModelsArrayList(g_aDefaultTModels, modelsPath);
        PrecacheModelsArrayList(g_aDefaultCTModels, modelsPath);    
    }
}

public void PrecacheArms(bool map)
{
    if (map && HasMapArms(TEAM_T) && HasMapArms(TEAM_CT)) {
        PrecacheModelsArray(g_aMapArms, sizeof(g_aMapArms));
    } else {
        PrecacheModelsArray(g_aDefaultArms, sizeof(g_aDefaultArms));
    }
}

public void SetClientDefault(int client)
{
    SetClientDefaultModel(client);
    SetClientDefaultArms(client);
}

public void SetClientDefaultModel(int client)
{
    if (!IsValidClient(client, false, g_bAutoSpawnBots)) {
        return;
    }

    SetEntityModel(client, GetClientNewRandomModel(client));
}

public void SetClientDefaultArms(int client)
{
    if (!IsValidClient(client, false, g_bAutoSpawnBots) || HasClientGloves(client)) {
        return;
    }

    int team = (GetClientTeam(client) == 2) ? TEAM_T : TEAM_CT;

    SetEntPropString(client, Prop_Send, "m_szArmsModel", HasMapArms(team) ? g_aMapArms[team] : g_aDefaultArms[team]);
}

public void ClientReadyForward(int client)
{	
    Call_StartForward(g_fOnClientReady);
    Call_PushCell(client);
    Call_Finish();
}

public int Native_SetClientDefault(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    SetClientDefaultModel(client);
}

public int Native_HasClientDefaultArms(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return view_as<bool>(HasClientDefaultArms(client));
}

public int Native_SetClientDefaultArms(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    SetClientDefaultArms(client);
}

public int Native_SetClientDefaultModel(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    SetClientDefaultModel(client);
}

char GetClientNewRandomModel(int client)
{
    char modelPath[64];
    char model[256];
    int team = (GetClientTeam(client) == 2) ? TEAM_T : TEAM_CT;

    Format(modelPath, sizeof(modelPath), "%s", g_bLegacyModels ? LEGACY_MODELS_PATH : MODELS_PATH);

    if (team == TEAM_T) {
        
        if (HasMapModels(team)) {
            g_aMapTModels.GetString(GetRandomInt(0 , g_aMapTModels.Length - 1), model, sizeof(model));
        } else {
            g_aDefaultTModels.GetString(GetRandomInt(0 , g_aDefaultTModels.Length - 1), model, sizeof(model));
        }

        Format(model, sizeof(model), "%s%s.mdl", modelPath, model);

    } else if (team == TEAM_CT) {

        if (HasMapModels(team)) {
            g_aMapCTModels.GetString(GetRandomInt(0 , g_aMapCTModels.Length - 1), model, sizeof(model));
        } else {
            g_aDefaultCTModels.GetString(GetRandomInt(0 , g_aDefaultCTModels.Length - 1), model, sizeof(model));
        }

        Format(model, sizeof(model), "%s%s.mdl", modelPath, model);
    }    

    return model;
}

bool HasMapArms(int team = TEAM_T)
{
    return g_aMapArms[team][0] != '\0';
}

bool HasMapModels(int team = TEAM_T)
{
    int arraySize = 0;

    if (team == TEAM_T && g_aMapTModels != null) {
        arraySize = g_aMapTModels.Length;
    } else if (team == TEAM_CT && g_aMapCTModels != null) {
        arraySize = g_aMapCTModels.Length;
    }

    return arraySize > 0;
}

public bool HasClientDefaultArms(int client)
{
    if (!IsValidClient(client, false)) {
        return false;
    }

    int team = (GetClientTeam(client) == 2) ? TEAM_T : TEAM_CT;
    char armsModel[256];

    GetEntPropString(client, Prop_Send, "m_szArmsModel", armsModel, sizeof(armsModel));

    return (StrEqual(armsModel, (HasMapArms(team)) ? g_aMapArms[team] : g_aDefaultArms[team]) || StrEqual(armsModel, "")) ? true : false;
}

public void GetKvKeysToArrayList(KeyValues &kv, const char[] key, ArrayList &dest)
{
    char entity[256];

    if (kv.JumpToKey(key)) {
            
        if (kv.GotoFirstSubKey(false)) {

            do {

                kv.GetSectionName(entity, sizeof(entity));
                dest.PushString(entity);

            } while (kv.GotoNextKey(false));

            kv.GoBack();
        }

        kv.GoBack();
    }
}

public void GetKvKeysToKv(KeyValues &kv, const char[] key, KeyValues &kvDest, const char[] destKey)
{
    char entity[256];

    kvDest.JumpToKey(destKey, true);

    if (kv.JumpToKey(key)) {
            
        if (kv.GotoFirstSubKey(false)) {

            do {

                kv.GetSectionName(entity, sizeof(entity));
                kvDest.SetString(entity, NULL_STRING);

            } while (kv.GotoNextKey(false));

            kv.GoBack();
        }

        kv.GoBack();
    }

    kvDest.GoBack();
}

public void PrecacheModelsArrayList(ArrayList &models, const char[] modelsPath)
{
    char model[256];

    for (int i = 0; i < models.Length; i++) {

        models.GetString(i, model, sizeof(model));

        if (model[0] == '\0') {
            continue;
        }

        Format(model, sizeof(model), "%s%s.mdl", modelsPath, model);

        if (!IsModelPrecached(model)) {
            PrecacheModel(model);
        }
    }
}

public void PrecacheModelsArray(const char[][] models, int size)
{
    for (int i = 0; i < size; i++) {

        if (models[i][0] != '\0' && !IsModelPrecached(models[i])) {
            PrecacheModel(models[i]);
        }
    }
}

/**
 * Export KV to file with NULL values
 * https://forums.alliedmods.net/showthread.php?t=274070
 * 
 * @return  true/false
 */
public bool ExportKvToFile(KeyValues kv, const char[] file) 
{ 
    File fh = OpenFile(file, "wb"); 
     
    if (fh == null) {
        return false;
    } 
     
    IterateKvKeys(kv, fh, 0); 
     
    delete fh; 
     
    return true; 
}

/**
 * Iterate KV keys
 * https://forums.alliedmods.net/showthread.php?t=274070
 * 
 * @return  no return
 */
public void IterateKvKeys(KeyValues kv, File fh, int tab) 
{ 
    char buffer[512], buffer2[512]; 
     
    kv.GetSectionName(buffer, sizeof(buffer)); 
     
    WriteKvLine(fh, tab, "\"%s\"", buffer); 
     
    WriteKvLine(fh, tab, "{"); 
     
    if (kv.GotoFirstSubKey(false)) {

        do {

            if (kv.GetDataType(NULL_STRING) == KvData_None) {

                IterateKvKeys(kv, fh, tab + 1);

            } else {

                kv.GetSectionName(buffer, sizeof(buffer)); 
                kv.GetString(NULL_STRING, buffer2, sizeof(buffer2)); 
                WriteKvLine(fh, tab + 1, "\"%s\"        \"%s\"", buffer, buffer2); 
            }

        } while (kv.GotoNextKey(false)); 
         
        kv.GoBack(); 
    } 
     
    WriteKvLine(fh, tab, "}"); 
} 

/**
 * Write KV line
 * https://forums.alliedmods.net/showthread.php?t=274070
 * 
 * @return  no return
 */
public void WriteKvLine(File fh, int tab, const char[] string, any ...) 
{ 
    char buffer[512]; 

    VFormat(buffer, sizeof(buffer), string, 4); 
    Format(buffer, sizeof(buffer), "%s\n", buffer);

    for (int i = 0; i < tab; i++) {
        Format(buffer, sizeof(buffer), "    %s", buffer); 
    }

    fh.WriteString(buffer, false); 
}

bool IsValidClient(int client, bool AllowDead = true, bool AllowBots = false)
{
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !AllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!AllowDead && !IsPlayerAlive(client))) {
        return false;
    }
    return true;
}

public bool HasClientGloves(int client)
{
    if (!IsValidClient(client, false)) {
        return false;
    }

    return GetEntPropEnt(client, Prop_Send, "m_hMyWearables") != -1;
}

public bool IsMapProtected(const char[] mapName)
{
    if (g_aProtectedMaps == null) {
        return false;
    }

    return (g_aProtectedMaps.FindString(mapName)) != -1;
}

public void DestroyArrayList(ArrayList &array)
{
    if (array != null && array != INVALID_HANDLE) {
        delete array;
    }
}

public void ClearArrayList(ArrayList &array)
{
    if (array != null && array != INVALID_HANDLE) {
        array.Clear();
    }
}

public bool IsValidArrayList(ArrayList &array)
{
    return (array != null && array != INVALID_HANDLE);
}
