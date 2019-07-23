#define MESSAGE_PREFIX "[\x05Retakes\x01]"

#define CHECK_CONNECTED(%1) if (!IsClientConnected(%1)) ThrowNativeError(SP_ERROR_PARAM, "Client %d is not connected", %1)

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    CreateNative("Retakes_IsJoined", Native_IsJoined);
    CreateNative("Retakes_IsInQueue", Native_IsInQueue);
    CreateNative("Retakes_Message", Native_RetakeMessage);
    CreateNative("Retakes_MessageToAll", Native_RetakeMessageToAll);
    CreateNative("Retakes_GetNumActiveTs", Native_GetNumActiveTs);
    CreateNative("Retakes_GetNumActiveCTs", Native_GetNumActiveCTs);
    CreateNative("Retakes_GetNumActivePlayers", Native_GetNumActivePlayers);
    CreateNative("Retakes_GetCurrrentBombsite", Native_GetCurrrentBombsite);
    CreateNative("Retakes_GetRoundPoints", Native_GetRoundPoints);
    CreateNative("Retakes_SetRoundPoints", Native_SetRoundPoints);
    CreateNative("Retakes_ChangeRoundPoints", Native_ChangeRoundPoints);
    CreateNative("Retakes_GetPlayerInfo", Native_GetPlayerInfo);
    CreateNative("Retakes_SetPlayerInfo", Native_SetPlayerInfo);
    CreateNative("Retakes_GetRetakeRoundsPlayed", Native_GetRetakeRoundsPlayed);
    CreateNative("Retakes_InEditMode", Native_InEditMode);
    CreateNative("Retakes_InWarmup", Native_InWarmup);
    CreateNative("Retakes_Enabled", Native_Enabled);
    CreateNative("Retakes_GetMaxPlayers", Native_GetMaxPlayers);
    RegPluginLibrary("retakes");
    return APLRes_Success;
}

public int Native_IsJoined(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if (!IsPlayer(client))
        return false;
    return GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT || Queue_Find(g_hWaitingQueue, client) != -1;
}

public int Native_IsInQueue(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if (!IsPlayer(client))
        return false;
    return Queue_Find(g_hWaitingQueue, client) != -1;
}

public int Native_RetakeMessage(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    SetGlobalTransTarget(client);
    char buffer[1024];
    int bytesWritten = 0;
    FormatNativeString(0, 2, 3, sizeof(buffer), bytesWritten, buffer);

    char finalMsg[1024];
    Format(finalMsg, sizeof(finalMsg), "%s %s", MESSAGE_PREFIX, buffer);

    if (client == 0) {
        Colorize(finalMsg, sizeof(finalMsg), true);
        PrintToConsole(client, finalMsg);
    } else {
        Colorize(finalMsg, sizeof(finalMsg));
        PrintToChat(client, finalMsg);
    }

}

public int Native_RetakeMessageToAll(Handle plugin, int numParams) {
    char buffer[1024];
    char finalMsg[1024];
    int bytesWritten = 0;

    FormatNativeString(0, 1, 2, sizeof(buffer), bytesWritten, buffer);
    Format(finalMsg, sizeof(finalMsg), "%s %s", MESSAGE_PREFIX, buffer);
    Colorize(finalMsg, sizeof(finalMsg), true);
    PrintToConsole(0, finalMsg);

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            SetGlobalTransTarget(i);
            FormatNativeString(0, 1, 2, sizeof(buffer), bytesWritten, buffer);
            Format(finalMsg, sizeof(finalMsg), "%s %s", MESSAGE_PREFIX, buffer);
            Colorize(finalMsg, sizeof(finalMsg));
            PrintToChat(i, finalMsg);
        }
    }
}

public int Native_GetNumActiveTs(Handle plugin, int numParams) {
    return g_NumT;
}

public int Native_GetNumActiveCTs(Handle plugin, int numParams) {
    return g_NumCT;
}

public int Native_GetNumActivePlayers(Handle plugin, int numParams) {
    return g_NumT + g_NumCT;
}

public int Native_GetCurrrentBombsite(Handle plugin, int numParams) {
    return view_as<int>(g_Bombsite);
}

public int Native_GetRoundPoints(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    CHECK_CONNECTED(client);
    return g_RoundPoints[client];
}

public int Native_SetRoundPoints(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    CHECK_CONNECTED(client);
    int points = GetNativeCell(2);
    g_RoundPoints[client] = points;
}

public int Native_ChangeRoundPoints(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    CHECK_CONNECTED(client);
    int dp = GetNativeCell(2);
    g_RoundPoints[client] += dp;
}

public int Native_GetPlayerInfo(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    CHECK_CONNECTED(client);
    SetNativeString(2, g_PlayerPrimary[client], WEAPON_STRING_LENGTH);
    SetNativeString(3, g_PlayerSecondary[client], WEAPON_STRING_LENGTH);
    SetNativeString(4, g_PlayerNades[client], NADE_STRING_LENGTH);

    SetNativeCellRef(5, g_PlayerHealth[client]);
    SetNativeCellRef(6, g_PlayerArmor[client]);
    SetNativeCellRef(7, g_PlayerHelmet[client]);
    SetNativeCellRef(8, g_PlayerKit[client]);
}

public int Native_SetPlayerInfo(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    CHECK_CONNECTED(client);

    GetNativeString(2, g_PlayerPrimary[client], WEAPON_STRING_LENGTH);
    GetNativeString(3, g_PlayerSecondary[client], WEAPON_STRING_LENGTH);
    GetNativeString(4, g_PlayerNades[client], NADE_STRING_LENGTH);

    g_PlayerHealth[client] = GetNativeCell(5);
    g_PlayerArmor[client] = GetNativeCell(6);
    g_PlayerHelmet[client] = GetNativeCell(7);
    g_PlayerKit[client] = GetNativeCell(8);
}

public int Native_GetRetakeRoundsPlayed(Handle plugin, int numParams) {
    return g_RoundCount;
}

public int Native_InEditMode(Handle plugin, int numParams) {
    return g_EditMode;
}

public int Native_InWarmup(Handle plugin, int numParams) {
    return GameRules_GetProp("m_bWarmupPeriod");
}

public int Native_Enabled(Handle plugin, int numParams) {
    return g_Enabled;
}

public int Native_GetMaxPlayers(Handle plugin, int numParams) {
    return g_hMaxPlayers.IntValue;
}
