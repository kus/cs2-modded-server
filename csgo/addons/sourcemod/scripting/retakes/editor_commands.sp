public Action Command_EditSpawns(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    if (!g_EditMode) {
        g_EditMode = true;
        StartPausedWarmup();
        for (int i = 1; i <= MaxClients; i++) {
            if (IsValidClient(i) && !IsFakeClient(i)) {
                MovePlayerToEditMode(i);
            }
        }

        Retakes_MessageToAll("Edit mode launched, basic commands:");
        Retakes_MessageToAll("!edit to bring up the editor menu");
        Retakes_MessageToAll("!show <a/b> to display spawn points for a site");
        Retakes_MessageToAll("!new <ct/t> <a/b> to add a spawn point");
        Retakes_MessageToAll("!delete to delete the nearest spawn");
    }

    GiveEditorMenu(client);
    return Plugin_Handled;
}

public Action Command_ReloadSpawns(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    ReloadSpawns();
    return Plugin_Handled;
}

public Action Command_SaveSpawns(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    SaveSpawns();
    Retakes_Message(client, "Saved %d spawns.", g_NumSpawns);
    return Plugin_Handled;
}

public Action Command_AddSpawn(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    if (!g_EditMode) {
        Retakes_Message(client, "You are not in edit mode.");
        return Plugin_Handled;
    }

    char arg1[32];
    char arg2[32];
    if (args >= 2 && GetCmdArg(1, arg1, sizeof(arg1)) && GetCmdArg(2, arg2, sizeof(arg2))) {
        int team;
        if (StrEqual(arg1, "CT", false)) {
            team = CS_TEAM_CT;
        } else if (StrEqual(arg1, "T", false)) {
            team = CS_TEAM_T;
        } else {
            ReplyToCommand(client, "Invalid team name: %s", arg1);
            return Plugin_Handled;
        }

        Bombsite site;
        if (StrEqual(arg2, "A", false)) {
            site = BombsiteA;
        } else if (StrEqual(arg2, "B", false)) {
            site = BombsiteB;
        } else {
            ReplyToCommand(client, "Invalid bomb site name: %s", arg2);
            return Plugin_Handled;
        }

        g_EditingSpawnTeams[client] = team;
        g_EditingSite = site;
        g_EditingSpawnTypes[client] = SpawnType_Normal;
        AddSpawn(client);
    } else {
        GiveNewSpawnMenu(client);
    }

    return Plugin_Handled;
}

public Action Command_Show(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    if (!g_EditMode) {
        Retakes_Message(client, "You are not in edit mode.");
        return Plugin_Handled;
    }

    char arg[32];
    if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
        Bombsite site = StrEqual(arg, "A", false) ? BombsiteA : BombsiteB;
        ShowSpawns(site);
    } else {
        ReplyToCommand(client, "Usage: sm_show <site>");
    }
    return Plugin_Handled;
}

public Action Command_DeleteSpawn(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    if (!g_EditMode) {
        Retakes_Message(client, "You are not in edit mode.");
        return Plugin_Handled;
    }

    DeleteClosestSpawn(client);
    return Plugin_Handled;
}

public Action Command_DeleteMapSpawns(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    DeleteMapSpawns();
    return Plugin_Handled;
}

public Action Command_IterateSpawns(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    if (!g_EditMode) {
        Retakes_Message(client, "You are not in edit mode.");
        return Plugin_Handled;
    }

    int startIndex = 0;
    char buf[32];
    if (args >= 1 && GetCmdArg(1, buf, sizeof(buf))) {
        startIndex = StringToInt(buf);
    }

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientSerial(client));
    pack.WriteCell(startIndex);
    CreateDataTimer(2.0, Timer_IterateSpawns, pack);
    return Plugin_Handled;
}

public Action Timer_IterateSpawns(Handle timer, Handle data) {
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int serial = pack.ReadCell();
    int spawnIndex = pack.ReadCell();
    int client = GetClientFromSerial(serial);

    if (!IsPlayer(client))
        return Plugin_Handled;

    MoveToSpawnInEditor(client, spawnIndex);

    spawnIndex++;
    while (g_SpawnDeleted[spawnIndex] && spawnIndex < g_NumSpawns) {
        spawnIndex++;
    }

    if (!g_SpawnDeleted[spawnIndex] && !g_SpawnDeleted[spawnIndex]) {
        pack = new DataPack();
        pack.WriteCell(serial);
        pack.WriteCell(spawnIndex);
        CreateDataTimer(2.0, Timer_IterateSpawns, pack);
    }

    return Plugin_Handled;
}

public Action Command_GotoSpawn(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    if (!g_EditMode) {
        Retakes_Message(client, "You are not in edit mode.");
        return Plugin_Handled;
    }

    char buffer[32];
    if (args >= 1 && GetCmdArg(1, buffer, sizeof(buffer))) {
        int spawn = StringToInt(buffer);
        if (IsValidSpawn(spawn)) {
            MoveToSpawnInEditor(client, spawn);
        }
    }

    return Plugin_Handled;
}

public Action Command_GotoNearestSpawn(int client, int args) {
    if (g_hEditorEnabled.IntValue == 0) {
        Retakes_Message(client, "The editor is currently disabled.");
        return Plugin_Handled;
    }

    if (!g_EditMode) {
        Retakes_Message(client, "You are not in edit mode.");
        return Plugin_Handled;
    }

    int spawn = FindClosestSpawn(client);
    if (IsValidSpawn(spawn)) {
        MoveToSpawnInEditor(client, spawn);
    }

    return Plugin_Handled;
}
