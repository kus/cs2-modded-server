bool debuggingEnabled       = false;
char databaseConfig[64]     = "storage-local";
float phys_timescale        = 1.0;
int phys_pushscale          = 900;

public void RegisterServerCommands()
{
    RegServerCmd(
        "soccer_mod_debug",
        ServerCommands,
        "Enables or disables debugging messages - values: 0/1, default: 0"
    );
    RegServerCmd(
        "soccer_mod_downloads_add_dir",
        ServerCommands,
        "Adds a directory and all the subdirectories to the downloads - values: path/to/dir"
    );
    RegServerCmd(
        "soccer_mod_database_config",
        ServerCommands,
        "Sets which database config should be used - default: storage-local"
    );
    RegServerCmd(
        "soccer_mod_prop_value",
        ServerCommands,
        "Sets a property value of an entity - [entity name] [value name] [value]"
    );
    RegServerCmd(
        "soccer_mod_prop_value_float",
        ServerCommands,
        "Sets a float property value of an entity - [entity name] [value name] [value]"
    );
    RegServerCmd(
        "soccer_mod_pushscale",
        ServerCommands,
        "Sets the physics pushscale - default: 900"
    );
    RegServerCmd(
        "soccer_mod_timescale",
        ServerCommands,
        "Sets the physics timescale - default: 1.0"
    );

    RegisterServerCommandsHealth();
    RegisterServerCommandsMatch();
    RegisterServerCommandsRanking();
    RegisterServerCommandsRespawn();
    RegisterServerCommandsSkins();
    RegisterServerCommandsSprint();
    RegisterServerCommandsTraining();
}

public Action ServerCommands(int args)
{
    char serverCommand[50], cmdArg1[32], cmdArg2[32], cmdArg3[32];
    GetCmdArg(0, serverCommand, sizeof(serverCommand));
    GetCmdArg(1, cmdArg1, sizeof(cmdArg1));
    GetCmdArg(2, cmdArg2, sizeof(cmdArg2));
    GetCmdArg(3, cmdArg3, sizeof(cmdArg3));

    if (StrEqual(serverCommand, "soccer_mod_debug"))
    {
        if (StringToInt(cmdArg1))
        {
            debuggingEnabled = true;
            PrintToServer("%s Debugging enabled", PREFIX);
            PrintToChatAll("%s Debugging enabled", PREFIX);
        }
        else
        {
            debuggingEnabled = false;
            PrintToServer("%s Debugging disabled", PREFIX);
            PrintToChatAll("%s Debugging disabled", PREFIX);
        }
    }
    else if (StrEqual(serverCommand, "soccer_mod_downloads_add_dir"))
    {
        char path[PLATFORM_MAX_PATH];
        GetCmdArgString(path, sizeof(path));

        AddDirToDownloads(path);
    }
    else if (StrEqual(serverCommand, "soccer_mod_database_config"))
    {
        databaseConfig = cmdArg1;
        PrintToServer("%s Database config set to %s", PREFIX, cmdArg1);
        PrintToChatAll("%s Database config set to %s", PREFIX, cmdArg1);

        if (db != INVALID_HANDLE) db.Close();
        ConnectToDatabase();
    }
    else if (StrEqual(serverCommand, "soccer_mod_prop_value") || StrEqual(serverCommand, "soccer_mod_prop_value_float"))
    {
        int entity = GetEntityIndexByName(cmdArg1, "prop_physics");

        if (entity != -1)
        {
            if (StrEqual(serverCommand, "soccer_mod_prop_value")) DispatchKeyValue(entity, cmdArg2, cmdArg3);
            else if (StrEqual(serverCommand, "soccer_mod_prop_value_float")) DispatchKeyValueFloat(entity, cmdArg2, StringToFloat(cmdArg3));

            //if (!IsModelPrecached(cmdArg3)) PrecacheModel(cmdArg3);
            //SetEntityModel(entity, cmdArg3);

            PrintToServer("%s Prop value %s of entity %s set to %s", PREFIX, cmdArg2, cmdArg1, cmdArg3);
            PrintToChatAll("%s Prop value %s of entity %s set to %s", PREFIX, cmdArg2, cmdArg1, cmdArg3);
        }
        else
        {
            PrintToServer("%s No entity found with name %s", PREFIX, cmdArg1);
            PrintToChatAll("%s No entity found with name %s", PREFIX, cmdArg1);
        }
    }
    else if (StrEqual(serverCommand, "soccer_mod_pushscale"))
    {
        int value = StringToInt(cmdArg1);
        SetCvarInt("phys_pushscale", value);

        phys_pushscale = value;
        PrintToServer("%s Pushscale set to %i", PREFIX, value);
        PrintToChatAll("%s Pushscale set to %i", PREFIX, value);
    }
    else if (StrEqual(serverCommand, "soccer_mod_timescale"))
    {
        float value = StringToFloat(cmdArg1);
        SetCvarFloat("phys_timescale", value);

        phys_timescale = value;
        PrintToServer("%s Timescale set to %f", PREFIX, value);
        PrintToChatAll("%s Timescale set to %f", PREFIX, value);
    }

    return Plugin_Handled;
}

// **************************************************************************************************************
// ************************************************** INCLUDES **************************************************
// **************************************************************************************************************
#include "soccer_mod\server_commands\health.sp"
#include "soccer_mod\server_commands\match.sp"
#include "soccer_mod\server_commands\ranking.sp"
#include "soccer_mod\server_commands\respawn.sp"
#include "soccer_mod\server_commands\skins.sp"
#include "soccer_mod\server_commands\sprint.sp"
#include "soccer_mod\server_commands\training.sp"