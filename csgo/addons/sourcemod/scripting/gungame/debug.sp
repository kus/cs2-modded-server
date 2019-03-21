OnCreateDebug() {
    RegConsoleCmd("gungamesm_display", _CmdDisplay);
    RegConsoleCmd("gungamesm_set_level", _CmdSetLevel);
}

public Action:_CmdSetLevel(client, args) {
    decl String:Arg[10];
    GetCmdArg(1, Arg, sizeof(Arg));

    new oldLevel = PlayerLevel[client];
    new setLevel = StringToInt(Arg)-1;
    if ( setLevel < 0 || setLevel >= WeaponOrderCount ) {
        setLevel = 0;
    }
    new newLevel = UTIL_ChangeLevel(client, setLevel - oldLevel); // todo: need to test this
    decl String:name[MAX_NAME_SIZE];
    if ( client && IsClientConnected(client) && IsClientInGame(client) ) {
        GetClientName(client, name, sizeof(name));
    } else {
        Format(name, sizeof(name), "[Client#%d]", client);
    }

    PrintLeaderToChat(client, oldLevel, newLevel, name);
    
    return Plugin_Handled;
}

public Action:_CmdDisplay(client, args) {
    decl String:Args[64];
    decl String:Args2[64];
    GetCmdArg(1, Args, sizeof(Args));
    GetCmdArg(2, Args2, sizeof(Args2));

    if (strcmp("weapons", Args) == 0) {
        //for(new i = 0; i <
    } else if(strcmp("config", Args) == 0) {
        Debug_DisplayConfig(client);
    } else if(strcmp("get_weapon_index", Args) == 0) {
        Debug_DisplayGetWeaponIndex(client, Args2);
    }
    // else if strcmp other commands

    return Plugin_Handled;
}

Debug_DisplayConfig(client) {
    // todo
    PrintToConsole(client, "Not implemented yet");
}

Debug_DisplayGetWeaponIndex(client, const String:weaponName[]) {
    PrintToConsole(client, "Weapon index=%i for weapon name=%s", UTIL_GetWeaponIndex(weaponName), weaponName);
}
