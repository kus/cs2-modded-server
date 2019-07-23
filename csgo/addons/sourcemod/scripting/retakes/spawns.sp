static void GetConfigFileName(char[] buffer, int size) {
    // get the map, with any workshop stuff before removed
    char mapName[128];
    GetCleanMapName(mapName, sizeof(mapName));
    BuildPath(Path_SM, buffer, size, "configs/retakes/%s.cfg", mapName);
}

public void FindSites() {
    g_SiteMins.Clear();
    g_SiteMaxs.Clear();

    int maxEnt = GetMaxEntities();
    char sClassName[128];
    for (int i = MaxClients; i < maxEnt; i++) {
        bool valid = IsValidEdict(i) && IsValidEntity(i);
        if (valid && GetEdictClassname(i, sClassName, sizeof(sClassName))) {
            if (StrEqual(sClassName, "func_bomb_target")) {
                float vecBombsiteMin[3];
                float vecBombsiteMax[3];
                GetEntPropVector(i, Prop_Send, "m_vecMins", vecBombsiteMin);
                GetEntPropVector(i, Prop_Send, "m_vecMaxs", vecBombsiteMax);
                g_SiteMins.PushArray(vecBombsiteMin);
                g_SiteMaxs.PushArray(vecBombsiteMax);
            }
        }
    }
}

/**
 * Reads the scenario keyvalues config file and sets up the global scenario and player arrays.
 */
public int ParseSpawns() {
    g_DirtySpawns = false;
    char configFile[PLATFORM_MAX_PATH];
    GetConfigFileName(configFile, sizeof(configFile));

    if (!FileExists(configFile)) {
        LogError("The retakes config file (%s) does not exist", configFile);
        return 0;
    }

    KeyValues kv = new KeyValues("Spawns");
    if (!kv.ImportFromFile(configFile) || !kv.GotoFirstSubKey()) {
        LogError("The retakes config file was empty");
        delete kv;
        return 0;
    }

    int spawn = 0;

    do {
        char sBuf[32];
        float vec[3];

        // throw away the section name
        kv.GetSectionName(sBuf, sizeof(sBuf));

        kv.GetVector("origin", vec, NULL_VECTOR);
        g_SpawnPoints[spawn] = vec;

        kv.GetVector("angle", vec, NULL_VECTOR);
        g_SpawnAngles[spawn] = vec;

        kv.GetString("bombsite", sBuf, sizeof(sBuf), "A");
        g_SpawnSites[spawn] = (StrEqual(sBuf, "A")) ? BombsiteA : BombsiteB;

        kv.GetString("team", sBuf, sizeof(sBuf), "T");
        g_SpawnTeams[spawn] = (StrEqual(sBuf, "CT")) ? CS_TEAM_CT : CS_TEAM_T;

        // Backwards compatibility with "nobomb" key.
        // These are converted into the "type" key when spawns are saved.
        if (kv.GetNum("nobomb") == 1) {
            g_SpawnTypes[spawn] = SpawnType_NeverWithBomb;
        } else {
            g_SpawnTypes[spawn] = view_as<SpawnType>(kv.GetNum("type"));
        }

        g_SpawnDeleted[spawn] = false;

        spawn++;
        if (spawn == MAX_SPAWNS) {
            LogError("Hit the max number of spawns");
            break;
        }

    } while (kv.GotoNextKey());

    delete kv;
    return spawn;
}


/**
 * Writes the stored scenario structures back to the config file.
 */
public void WriteSpawns() {
    KeyValues kv = new KeyValues("Spawns");
    int output_index = 0;

    for (int spawn = 0; spawn < g_NumSpawns; spawn++) {
        if (spawn == MAX_SPAWNS) {
            LogError("Hit the max number (%d) of spawns", MAX_SPAWNS);
            break;
        }

        if (g_SpawnDeleted[spawn])
            continue;

        char sBuf[32];
        IntToString(output_index, sBuf, sizeof(sBuf));
        output_index++;
        kv.JumpToKey(sBuf, true);

        kv.SetVector("origin", g_SpawnPoints[spawn]);
        kv.SetVector("angle", g_SpawnAngles[spawn]);
        kv.SetString("bombsite", SITESTRING(g_SpawnSites[spawn]));
        kv.SetString("team", TEAMSTRING(g_SpawnTeams[spawn]));
        kv.SetNum("type", view_as<int>(g_SpawnTypes[spawn]));

        kv.GoBack();
    }

    char configFile[PLATFORM_MAX_PATH];
    GetConfigFileName(configFile, sizeof(configFile));

    DeleteFile(configFile);
    kv.Rewind();
    kv.ExportToFile(configFile);
    delete kv;
}

/**
 * Sets up a player for the round, giving weapons, teleporting, etc.
 */
public void SetupPlayer(int client) {
    int spawnIndex = g_SpawnIndices[client];
    if (spawnIndex < 0)
        return;

    SwitchPlayerTeam(client, g_Team[client]);
    MoveToSpawn(client, spawnIndex);
    GiveWeapons(client);
}

public void MoveToSpawn(int client, int spawnIndex) {
    TeleportEntity(client, g_SpawnPoints[spawnIndex], g_SpawnAngles[spawnIndex], NULL_VECTOR);
}

public void GiveWeapons(int client) {
    if (!IsValidClient(client)) {
        return;
    }

    Client_RemoveAllWeapons(client);

    if (g_Team[client] == CS_TEAM_T)
        GivePlayerItem(client, "weapon_knife_t");
    else
        GivePlayerItem(client, "weapon_knife");

    GivePlayerItem(client, g_PlayerPrimary[client]);
    GivePlayerItem(client, g_PlayerSecondary[client]);

    Client_SetArmor(client, g_PlayerArmor[client]);
    SetEntityHealth(client, g_PlayerHealth[client]);
    SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), g_PlayerHelmet[client]);

    if (g_Team[client] == CS_TEAM_CT) {
        SetEntProp(client, Prop_Send, "m_bHasDefuser", g_PlayerKit[client]);
    }

    int len = strlen(g_PlayerNades[client]);
    for (int i = 0; i < len; i++) {
        char c = g_PlayerNades[client][i];
        char weapon[32];
        switch(c) {
            case 'h': weapon = "weapon_hegrenade";
            case 'f': weapon = "weapon_flashbang";
            case 'm': weapon = "weapon_molotov";
            case 'i': weapon = "weapon_incgrenade";
            case 's': weapon = "weapon_smokegrenade";
            case 'd': weapon = "weapon_decoy";
        }
        GivePlayerItem(client, weapon);
    }

    if (g_BombOwner == client) {
        g_bombPlantSignal = false;
        GivePlayerItem(client, "weapon_c4");
        CreateTimer(1.0, Timer_StartPlant, client);
    }
}

public Action Timer_StartPlant(Handle timer, int client) {
    if (IsPlayer(client)) {
        g_bombPlantSignal = true;
    }
}

public bool InsideBombSite(float vec[3]) {
    for (int i = 0; i < GetArraySize(g_SiteMaxs); i++) {
        float min[3];
        float max[3];

        GetArrayArray(g_SiteMins, i, min, sizeof(min));
        GetArrayArray(g_SiteMaxs, i, max, sizeof(max));

        bool in_x = (min[0] <= vec[0] && vec[0] <= max[0]) || (max[0] <= vec[0] && vec[0] <= min[0]);
        bool in_y = (min[1] <= vec[1] && vec[1] <= max[1]) || (max[1] <= vec[1] && vec[1] <= min[1]);

        if (in_x && in_y) {
            return true;
        }

    }
    return false;
}

public bool SpawnInsideBombSite(int spawnIndex) {
    return InsideBombSite(g_SpawnPoints[spawnIndex]);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3],
                             int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
    // Forces the player to get the bomb out on their spawn.
    // The signal is fired by a timer after the bomb-carrier's spawn.
    if (g_bombPlantSignal && !g_bombPlanted && client == g_BombOwner) {
        buttons |= IN_USE;
        g_bombPlantSignal = false;
    }

    return Plugin_Continue;
}

public bool CanBombCarrierSpawn(int spawn) {
    if (g_SpawnTeams[spawn] == CS_TEAM_CT)
        return false;
    return (g_SpawnTypes[spawn] != SpawnType_NeverWithBomb) && SpawnInsideBombSite(spawn);
}

public bool CanRegularPlayerSpawn(int spawn) {
    if (g_SpawnTeams[spawn] == CS_TEAM_CT)
        return true;
    return g_SpawnTypes[spawn] != SpawnType_OnlyWithBomb;
}

/**
 * Returns an appropriate spawn index for a player.
 */
public int SelectSpawn(int team, bool bombSpawn) {
    ArrayList potentialSpawns = new ArrayList();
    for (int i = 0; i < g_NumSpawns; i++) {
        if (g_SpawnTeams[i] == team && !g_SpawnTaken[i] && g_Bombsite == g_SpawnSites[i]) {
            if ((bombSpawn && CanBombCarrierSpawn(i)) || (!bombSpawn && CanRegularPlayerSpawn(i))) {
                potentialSpawns.Push(i);
            }
        }
    }

    if (potentialSpawns.Length == 0) {
        delete potentialSpawns;
        char mapName[128];
        GetCurrentMap(mapName, sizeof(mapName));
        if (bombSpawn) {
            LogError("Had to resort to fallback spawn on %s, site=%d", mapName, g_Bombsite);
            return SelectSpawn(team, false);
        } else {
            LogError("Failed to get any spawn on %s, site=%d, team=%d", mapName, g_Bombsite, team);
            return -1;
        }
    } else {
        int choice = RandomElement(potentialSpawns);
        g_SpawnTaken[choice] = true;
        delete potentialSpawns;
        return choice;
    }
}

public bool IsValidSpawn(int index) {
    return index >= 0 && index < g_NumSpawns && !g_SpawnDeleted[index];
}
