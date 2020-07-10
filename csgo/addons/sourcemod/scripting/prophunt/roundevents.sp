
#include "prophunt/include/roundutils.inc"

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast) {
    g_bRoundEnded = false;

    // When disabling +use or "e" button open all doors on the map and keep them opened.
    bool isUseDisabled = GetConVarBool(cvar_DisableUse);

    RemoveGameplayEdicts();
    if (isUseDisabled)
        OpenDoors();

    for (int i = 1; i <= MaxClients; i++) {
        if (g_iHiderToSeekerQueue[i] != NOT_IN_QUEUE) {
            PrintToChat(i, "%s%t", PREFIX, "turns until switch", SimulateTurnsToSeeker(g_iHiderToSeekerQueue[i]));
        }

        if (IsClientInGame(i)) {
            SetEntProp(i, Prop_Data, "m_iFrags", g_iPlayerScore[i]);
        }
    }

    int iTimeLeft = GameRules_GetProp("m_iRoundTime");
    PrintToServer("Debug: %d", iTimeLeft);
    g_hRoundEndTimer = CreateTimer(float(iTimeLeft) - 0.5, Timer_RoundEnd, _, TIMER_FLAG_NO_MAPCHANGE);
    g_hAfterFreezeTimer = CreateTimer(GetConVarFloat(cvar_FreezeTime), Timer_AfterFreezeTime, _, TIMER_FLAG_NO_MAPCHANGE); 

    if (GetConVarBool(cvar_TurnsToScramble)) {
        if (g_iTurnsToScramble == 0)
            g_iTurnsToScramble = GetConVarInt(cvar_TurnsToScramble);
        g_iTurnsToScramble--;
    }

    return Plugin_Continue;
}
/*
// make sure terrorists win on round time end
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason) {
    if (reason != CSRoundEnd_TerroristWin) {
        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) {
                reason = CSRoundEnd_TerroristWin; 
                return Plugin_Changed;
            }
        }
    }

    return Plugin_Continue;
}
*/
public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast) {

    // round has ended. used to not decrease seekers hp on shoot
    g_bRoundEnded = true;

    g_iFirstCTSpawn = 0;
    g_iFirstTSpawn = 0;

    UnsetHandle(g_hShowCountdownTimer);
    UnsetHandle(g_hRoundTimeTimer);
    UnsetHandle(g_hWhistleDelay);
    UnsetHandle(g_hAfterFreezeTimer);
    UnsetHandle(g_hPeriodicWhistleTimer);
    UnsetHandle(g_hRoundEndTimer);

    if (!GetConVarInt(cvar_TurnsToScramble))
        ManageCTQueue();

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i))
            g_iPlayerScore[i] = GetEntProp(i, Prop_Data, "m_iFrags");
    }

    //PrintToServer("Debug: %b", GetConVarBool(cvar_TurnsToScramble));

    // scramble teams
    if (GetConVarInt(cvar_TurnsToScramble) && g_iTurnsToScramble == 0) {
        ScrambleTeams();
        PrintToChatAll("%s%t", PREFIX, "scrambling");
    }

    // balance teams
    if (GetConVarFloat(cvar_CTRatio) > 0.0) {
        ChangeTeam(GetTeamClientCount(CS_TEAM_CT), GetTeamClientCount(CS_TEAM_T));

        // if teams were'nt just scrambled, announce balancing
        if (!(GetConVarBool(cvar_TurnsToScramble) && g_iTurnsToScramble == 0)) {
            PrintToChatAll("%s%t", PREFIX, "balancing");
        }
    }

    // Switch the flagged players' teams
    //CreateTimer(0.1, Timer_SwitchTeams, _, TIMER_FLAG_NO_MAPCHANGE);
    SwitchTeams();

    return Plugin_Continue;
}

// give terrorists frags
public Action Event_OnRoundEnd_Pre(Handle event, const char[] name, bool dontBroadcast) {
    int winnerTeam = GetEventInt(event, "winner");

    if (winnerTeam == CS_TEAM_T) {
        int increaseFrags = GetConVarInt(cvar_HiderWinFrags);
        bool aliveTerrorists = GiveAliveTerroristsFrags(increaseFrags);

        if (aliveTerrorists) {
            PrintToChatAll("%s%t", PREFIX, "got frags", increaseFrags);
        }

        if (GetConVarBool(cvar_SlaySeekers)) {
            SlayTeam(CS_TEAM_CT);
        }
    }

    return Plugin_Continue;
}

public Action Timer_RoundEnd(Handle timer) {
    g_hRoundEndTimer = INVALID_HANDLE;

    int winnerTeam;
    bool aliveTs;

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i)) {
            if (GetClientTeam(i) == CS_TEAM_T)
                aliveTs = true;
        }
    }

    if (aliveTs) {
        winnerTeam = CS_TEAM_T;
    } else {
        winnerTeam = CS_TEAM_CT;
    }

    ForceRoundEnd(winnerTeam);
    return Plugin_Continue;
}

public Action Timer_SwitchTeams(Handle timer) {
    SwitchTeams();
    return Plugin_Continue;
}

public Action Timer_AfterFreezeTime(Handle timer) { 
    g_hAfterFreezeTimer = INVALID_HANDLE;

    if (GetConVarBool(cvar_ForcePeriodicWhistle)) {
        int whistleDelay = GetConVarInt(cvar_PeriodicWhistleDelay);
        g_hPeriodicWhistleTimer = CreateTimer(FloatDiv(float(whistleDelay), 2.0), Timer_MakeRandomClientWhistle, true, TIMER_FLAG_NO_MAPCHANGE);
    }

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i))
            UnFreezePlayer(i);
    }

    return Plugin_Continue;
}

public Action Timer_MakeRandomClientWhistle(Handle timer, bool firstcall) { 
    float repeatDelay = FloatDiv(GetConVarFloat(cvar_ForcePeriodicWhistle), 2.0);

    if (firstcall) {
        PrintToChatAll("%s%t", PREFIX, "will whistle", RoundToFloor(repeatDelay));
    } else {
        int client = GetRandomClient(CS_TEAM_T, true);
        MakeClientWhistle(client);

        char name[32];
        GetClientName(client, name, sizeof(name));
        PrintToChatAll("%s%t", PREFIX, "periodic whistle", name);
    }

    g_hPeriodicWhistleTimer = CreateTimer(repeatDelay, Timer_MakeRandomClientWhistle, !firstcall, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}
