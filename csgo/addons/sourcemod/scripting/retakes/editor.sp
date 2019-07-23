int g_iBeamSprite = 0;
int g_iHaloSprite = 0;
Bombsite g_EditingSite = BombsiteA;

public void MovePlayerToEditMode(int client) {
    SwitchPlayerTeam(client, CS_TEAM_CT);
    CS_RespawnPlayer(client);
}

public void ShowSpawns(Bombsite site) {
    g_EditingSite = site;
    Retakes_MessageToAll("Showing spawns for bombsite \x04%s.", SITESTRING(site));

    int ct_count = 0;
    int t_count = 0;
    for (int i = 0; i < g_NumSpawns; i++) {
        if (!g_SpawnDeleted[i] && g_SpawnSites[i] == g_EditingSite) {
            if (g_SpawnTeams[i] == CS_TEAM_CT) {
                ct_count++;
            } else {
                t_count++;
            }
        }
    }
    Retakes_MessageToAll("Found %d CT spawns.", ct_count);
    Retakes_MessageToAll("Found %d T spawns.", t_count);
}

public Action Timer_ShowSpawns(Handle timer) {
    if (!g_EditMode || g_hEditorEnabled.IntValue == 0)
        return Plugin_Continue;

    g_iBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
    g_iHaloSprite = PrecacheModel("sprites/halo.vmt", true);
    float origin[3];
    float angle[3];

    for (int i = 1; i <= MaxClients; i++) {
        if (!IsValidClient(i) || IsFakeClient(i)) {
            continue;
        }

        for (int j = 0; j < g_NumSpawns; j++) {
            origin = g_SpawnPoints[j];
            angle = g_SpawnPoints[j];
            if (SpawnFilter(j)) {
                DisplaySpawnPoint(i, origin, angle, 40.0, g_SpawnTeams[j] == CS_TEAM_CT, g_SpawnTypes[j]);
            }
        }
    }

    return Plugin_Continue;
}

stock bool SpawnFilter(int spawn) {
    if (!IsValidSpawn(spawn)) {
        return false;
    }

    if (g_SpawnSites[spawn] != g_EditingSite) {
        return false;
    }

    return true;
}

public void AddSpawn(int client) {
    g_DirtySpawns = true;
    if (g_NumSpawns + 1 >= MAX_SPAWNS) {
        Retakes_MessageToAll("{DARK_RED}WARNING: {NORMAL}the maximum number of spawns has been reached. New spawns cannot be added.");
        LogError("Maximum number of spawns reached");
        return;
    }

    GetClientAbsOrigin(client, g_SpawnPoints[g_NumSpawns]);
    GetClientEyeAngles(client, g_SpawnAngles[g_NumSpawns]);
    g_SpawnSites[g_NumSpawns] = g_EditingSite;
    g_SpawnTeams[g_NumSpawns] = g_EditingSpawnTeams[client];
    g_SpawnTypes[g_NumSpawns] = g_EditingSpawnTypes[client];
    g_SpawnDeleted[g_NumSpawns] = false;

    Retakes_MessageToAll("Added %s spawn for %s (#%d).",
                         TEAMSTRING(g_EditingSpawnTeams[client]),
                         SITESTRING(g_EditingSite),
                         g_NumSpawns);
    g_NumSpawns++;
}

public void DisplaySpawnPoint(int client, const float position[3], const float angles[3],
                              float size, bool ct, SpawnType spawnType) {
    float direction[3];
    GetAngleVectors(angles, direction, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(direction, size/2);
    AddVectors(position, direction, direction);

    int r, g, b;
    if (ct) {
        // blue
        r = 0;
        g = 0;
        b = 255;
    } else {
        if (spawnType == SpawnType_Normal) {
            // red
            r = 255;
            g = 0;
            b = 0;
        } else if (spawnType == SpawnType_OnlyWithBomb) {
            // green
            r = 0;
            g = 255;
            b = 0;
        } else {
            // yellow
            r = 255;
            g = 255;
            b = 0;
        }
    }

    TE_Start("BeamRingPoint");
    TE_WriteVector("m_vecCenter", position);
    TE_WriteFloat("m_flStartRadius", 10.0);
    TE_WriteFloat("m_flEndRadius", size);
    TE_WriteNum("m_nModelIndex", g_iBeamSprite);
    TE_WriteNum("m_nHaloIndex", g_iHaloSprite);
    TE_WriteNum("m_nStartFrame", 0);
    TE_WriteNum("m_nFrameRate", 0);
    TE_WriteFloat("m_fLife", 1.0);
    TE_WriteFloat("m_fWidth", 1.0);
    TE_WriteFloat("m_fEndWidth", 1.0);
    TE_WriteFloat("m_fAmplitude", 0.0);
    TE_WriteNum("r", r);
    TE_WriteNum("g", g);
    TE_WriteNum("b", b);
    TE_WriteNum("a", 255);
    TE_WriteNum("m_nSpeed", 50);
    TE_WriteNum("m_nFlags", 0);
    TE_WriteNum("m_nFadeLength", 0);
    TE_SendToClient(client);

    TE_Start("BeamPoints");
    TE_WriteVector("m_vecStartPoint", position);
    TE_WriteVector("m_vecEndPoint", direction);
    TE_WriteNum("m_nModelIndex", g_iBeamSprite);
    TE_WriteNum("m_nHaloIndex", g_iHaloSprite);
    TE_WriteNum("m_nStartFrame", 0);
    TE_WriteNum("m_nFrameRate", 0);
    TE_WriteFloat("m_fLife", 1.0);
    TE_WriteFloat("m_fWidth", 1.0);
    TE_WriteFloat("m_fEndWidth", 1.0);
    TE_WriteFloat("m_fAmplitude", 0.0);
    TE_WriteNum("r", r);
    TE_WriteNum("g", g);
    TE_WriteNum("b", b);
    TE_WriteNum("a", 255);
    TE_WriteNum("m_nSpeed", 50);
    TE_WriteNum("m_nFlags", 0);
    TE_WriteNum("m_nFadeLength", 0);
    TE_SendToClient(client);
}

stock int FindClosestSpawn(int client) {
    int closest = -1;
    float minDist = 0.0;
    for (int i = 0; i < g_NumSpawns; i++) {
        if (!SpawnFilter(i)) {
            continue;
        }

        float origin[3];
        origin = g_SpawnPoints[i];

        float playerOrigin[3];
        GetClientAbsOrigin(client, playerOrigin);

        float dist = GetVectorDistance(origin, playerOrigin);
        if (closest < 0 || dist < minDist) {
            minDist = dist;
            closest = i;
        }
    }
    return closest;
}

public void DeleteClosestSpawn(int client) {
    g_DirtySpawns = true;
    int closest = FindClosestSpawn(client);
    if (closest >= 0) {
        Retakes_MessageToAll("Deleted spawn #%d.", closest);
        g_SpawnDeleted[closest] = true;
    }
}

public void SaveSpawns() {
    WriteSpawns();
    Retakes_MessageToAll("Map spawns saved.");
}

public void ReloadSpawns() {
    g_NumSpawns = ParseSpawns();
    Retakes_MessageToAll("Imported %d map spawns.", g_NumSpawns);
}

public void DeleteMapSpawns() {
    g_NumSpawns = 0;
    Retakes_MessageToAll("All spawns for this map have been deleted");
}

public void MoveToSpawnInEditor(int client, int spawnIndex) {
    TeleportEntity(client, g_SpawnPoints[spawnIndex], g_SpawnAngles[spawnIndex], NULL_VECTOR);
    Retakes_Message(client, "Teleporting to spawn {GREEN}%d", spawnIndex);
    Retakes_Message(client, "   Team: {MOSS_GREEN}%s", TEAMSTRING(g_SpawnTeams[spawnIndex]));
    Retakes_Message(client, "   Site: {MOSS_GREEN}%s", SITESTRING(g_SpawnSites[spawnIndex]));
}
