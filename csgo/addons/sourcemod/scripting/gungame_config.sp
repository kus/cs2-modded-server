#pragma semicolon 1

#include <sourcemod>
#include <gungame_const>
#include <gungame_config>
#include "gungame/stock.sp"

/**
 * Do map specific config
 * make sure to do partial name config
 *
 * ie .. de.equip.txt
 * ie .. de.config.txt
 * ie .. de_dust.equip.txt
 * ie .. de_dust.config.txt
 *
 * it will be in configs/gungame/map/
 *
 * gungame.cfg will be read first before prefix map name.
 * prefix map name will be executed first before map specfic map.
 * then map specifc config files will be loaded.
 */

public Plugin:myinfo =
{
    name = "GunGame:SM Config Reader",
    author = GUNGAME_AUTHOR,
    description = "GunGame:SM Config Reader",
    version = GUNGAME_VERSION,
    url = GUNGAME_URL
};

new Handle:ConfigParser = INVALID_HANDLE;
new ConfigCount;
new ParseConfigCount;

new Handle:FwdConfigNewSection = INVALID_HANDLE;
new Handle:FwdConfigKeyValue = INVALID_HANDLE;
new Handle:FwdConfigParseEnd = INVALID_HANDLE;
new Handle:FwdConfigEnd = INVALID_HANDLE;

new Handle:g_Cvar_CfgDirName = INVALID_HANDLE;

new GameName:g_GameName = GameName:None;
new String:ConfigGameDirName[PLATFORM_MAX_PATH];

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    RegPluginLibrary("gungame_cfg");
    CreateNative("GG_ConfigGetDir", Native_GG_ConfigGetDir);
    return APLRes_Success;
}

public Native_GG_ConfigGetDir(Handle:plugin, numParams) {
    SetNativeString(1, ConfigGameDirName, GetNativeCell(2));
    return 1;
}

public OnPluginStart() {
    g_GameName = DetectGame();
    if (g_GameName == GameName:None) {
        SetFailState("ERROR: Unsupported game. Please contact the author.");
    }

    FwdConfigNewSection = CreateGlobalForward("GG_ConfigNewSection", ET_Ignore, Param_String);
    FwdConfigKeyValue = CreateGlobalForward("GG_ConfigKeyValue", ET_Ignore, Param_String, Param_String);
    FwdConfigParseEnd = CreateGlobalForward("GG_COnfigParseEnd", ET_Ignore);
    FwdConfigEnd = CreateGlobalForward("GG_ConfigEnd", ET_Ignore);
    g_Cvar_CfgDirName = CreateConVar("sm_gg_cfgdirname", "gungame", "Config directory for gungame (from cfg path)");
}

public OnConfigsExecuted() {
    ReadConfig();
}

ReadConfig()
{
    ConfigParser = SMC_CreateParser();

    SMC_SetParseEnd(ConfigParser, ReadConfig_ParseEnd);
    SMC_SetReaders(ConfigParser, ReadConfig_NewSection, ReadConfig_KeyValue, ReadConfig_EndSection);

    if (ConfigParser == INVALID_HANDLE)
    {
        return;
    }
    
    decl String:ConfigDirName[PLATFORM_MAX_PATH];
    GetConVarString(g_Cvar_CfgDirName, ConfigDirName, sizeof(ConfigDirName));

    if (g_GameName == GameName:Css) {
        FormatEx(ConfigGameDirName, sizeof(ConfigGameDirName), "%s\\css", ConfigDirName);
    } else if (g_GameName == GameName:Csgo) {
        FormatEx(ConfigGameDirName, sizeof(ConfigGameDirName), "%s\\csgo", ConfigDirName);
    }

    decl String:ConfigDir[PLATFORM_MAX_PATH];
    FormatEx(ConfigDir, sizeof(ConfigDir), "cfg\\%s", ConfigGameDirName);

    decl String:ConfigFile[PLATFORM_MAX_PATH], String:EquipFile[PLATFORM_MAX_PATH];
    decl String:Error[PLATFORM_MAX_PATH + 64];
    
    FormatEx(ConfigFile, sizeof(ConfigFile), "%s\\gungame.config.txt", ConfigDir);

    if(FileExists(ConfigFile))
    {
        ConfigCount++;
        PrintToServer("[GunGame] Loading gungame.config.txt config file");
    } else {
        FormatEx(Error, sizeof(Error), "[GunGame] FATAL *** ERROR *** can not find %s", ConfigFile);
        SetFailState(Error);
    }
    
    FormatEx(EquipFile, sizeof(EquipFile), "%s\\gungame.equip.txt", ConfigDir);
    
    if(FileExists(EquipFile))
    {
        ConfigCount++;
        PrintToServer("[GunGame] Loading gungame.equip.txt config file");
    } else {
        FormatEx(Error, sizeof(Error), "[GunGame] FATAL *** ERROR *** can not find %s", EquipFile);
        SetFailState(Error);
    }
    
    /* Build map config and map prefix config*/
    
    /**
     * Thanks sawce for the idea from your prefix map plugin loading for AMX Mod X
     * saved me alot of time doing it this way.
     *
     */

    decl String:Map[32];
    new len = GetCurrentMap(Map, sizeof(Map));
    
    new i, b;
    while(Map[i] != '_' && Map[i] != '\0' && i < len)
    {
        i++;
    }

    decl String:PrefixConfigFile[PLATFORM_MAX_PATH],  String:PrefixEquipFile[PLATFORM_MAX_PATH];
    new bool:EquipOne, bool:ConfigOne;
    
    if(Map[i] == '_')
    {
        b = Map[i];
        Map[i] = '\0';

        FormatEx(PrefixConfigFile, sizeof(PrefixConfigFile), "%s\\maps\\%s.config.txt", ConfigDir, Map);
        FormatEx(PrefixEquipFile, sizeof(PrefixEquipFile), "%s\\maps\\%s.equip.txt", ConfigDir, Map);

        if(FileExists(PrefixConfigFile))
        {
            ConfigOne = true;
            PrintToServer("[GunGame] Loading %s.config.txt config file", Map);
            ConfigCount++;
        }
        
        if(FileExists(PrefixEquipFile))
        {
            EquipOne = true;
            PrintToServer("[GunGame] Loading %s.equip.txt config file", Map);
            ConfigCount++;
        }

        Map[i] = b;
    }

    decl String:MapEquipFile[PLATFORM_MAX_PATH], String:MapConfigFile[PLATFORM_MAX_PATH];
    new bool:EquipTwo, bool:ConfigTwo;
    
    FormatEx(MapConfigFile, sizeof(MapConfigFile), "%s\\maps\\%s.config.txt", ConfigDir, Map);
    FormatEx(MapEquipFile, sizeof(MapEquipFile), "%s\\maps\\%s.equip.txt", ConfigDir, Map);

    if(FileExists(MapConfigFile))
    {
        PrintToServer("[GunGame] Loading %s.config.txt file", Map);
        ConfigTwo = true;
        ConfigCount++;
    }
    
    if(FileExists(MapEquipFile))
    {
        PrintToServer("[GunGame] Loading %s.equip.txt file", Map);
        EquipTwo = true;
        ConfigCount++;
    }
    
    InternalReadConfig(ConfigFile);
    InternalReadConfig(EquipFile);
    
    if(ConfigOne)
    {
        InternalReadConfig(PrefixConfigFile);
    }
    
    if(EquipOne)
    {
        InternalReadConfig(PrefixEquipFile);
    }
    
    if(ConfigTwo)
    {
        InternalReadConfig(MapConfigFile);
    }
    
    if(EquipTwo)
    {
        InternalReadConfig(MapEquipFile);
    }
}

static InternalReadConfig(const String:path[])
{
    new SMCError:err = SMC_ParseFile(ConfigParser, path);

    if (err != SMCError_Okay)
    {
        decl String:buffer[64];
        if (SMC_GetErrorString(err, buffer, sizeof(buffer)))
        {
            PrintToServer("%s", buffer);
        } else {
            PrintToServer("Fatal parse error");
        }
    }
}

public SMCResult:ReadConfig_NewSection(Handle:smc, const String:name[], bool:opt_quotes)
{
    if(name[0])
    {
        Call_StartForward(FwdConfigNewSection);
        Call_PushString(name);
        Call_Finish();
    }

    return SMCParse_Continue;
}

public SMCResult:ReadConfig_KeyValue(Handle:smc,
                                        const String:key[],
                                        const String:value[],
                                        bool:key_quotes,
                                        bool:value_quotes)
{
    /**
     * Is this check really even neccessary?
     */

    if(key[0] && value[0])
    {
        Call_StartForward(FwdConfigKeyValue);
        Call_PushString(key);
        Call_PushString(value);
        Call_Finish();
    }

    return SMCParse_Continue;
}

public SMCResult:ReadConfig_EndSection(Handle:smc)
{
    return SMCParse_Continue;
}

public ReadConfig_ParseEnd(Handle:smc, bool:halted, bool:failed)
{
    Call_StartForward(FwdConfigParseEnd);
    Call_Finish();
    
    if(ConfigCount == ++ParseConfigCount)
    {
        Call_StartForward(FwdConfigEnd);
        Call_Finish();
    }
}