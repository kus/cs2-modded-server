
#if defined _teamutils_included
    #endinput
#endif
#define _teamutils_included

stock void SwitchTeams() {
    char sName[64];
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            GetClientName(i, sName, sizeof(sName));
            PrintToServer("Switched %s to %d", sName, g_iClientTeam[i]);
            CS_SwitchTeam(i, g_iClientTeam[i]);
            PrintToServer("Did switch");
        }

        g_bClientTeambalanced[i] = false;
    }
}

stock void ChangeTeam(int initialCTCount, int initialTCount) {
    int teamClientCount[5];

    // Check, how many cts are going to get switched to terrorist side at the end of the round
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientConnected(i)) {
            teamClientCount[g_iClientTeam[i]]++;
        }
    }

    //PrintToServer("Debug: %d players are flagged to switch at the end of the round.", iToBeSwitched);
    float fRatio = FloatDiv(float(teamClientCount[CS_TEAM_T]), float(teamClientCount[CS_TEAM_CT]));

    // optimal T/CT ratio
    float fCFGCTRatio = GetConVarFloat(cvar_CTRatio);

    if (FloatCompare(fRatio, fCFGCTRatio) != 0) { // ratio is not optimal
        int numClients;
        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && GetClientTeam(i) != CS_TEAM_SPECTATOR)
                numClients++;
        }
       
        int iOptCTCount = RoundToFloor(FloatDiv(float(numClients), fCFGCTRatio + 1.0));
        int iOptTCount = numClients - iOptCTCount;

        // in any case we don't want empty teams
        if (iOptCTCount == 0 && iOptTCount > 1) {
            iOptCTCount++;
            iOptTCount--;
        }

        if (iOptTCount == 0 && iOptCTCount > 1) {
            iOptCTCount--;
            iOptTCount++;
        }

        while (teamClientCount[CS_TEAM_T] < iOptTCount) {
            if (!SwitchNextSeeker())
                break;

            teamClientCount[CS_TEAM_CT]--;
            teamClientCount[CS_TEAM_T]++;
        }

        while (teamClientCount[CS_TEAM_CT] < iOptCTCount) {
            if (!SwitchNextHiderInQueue())
                break;

            teamClientCount[CS_TEAM_CT]++;
            teamClientCount[CS_TEAM_T]--;
        }
    }

    //PrintToServer("Debug: Initial CTCount: %d TCount: %d Ratio: %f, CFGRatio: %f", iCTCount, iTCount, fRatio, fCFGRatio);

    //PrintToServer("Debug: CT: %d T: %d", iCTCount, iTCount);
}

stock int SimulateTurnsToSeeker(int queueOrder) {
    int turns;
    int guaranteedCTTurns[MAXPLAYERS];
    int queue[MAXPLAYERS];
    for (int i = 1; i <= MaxClients; i++) {
        guaranteedCTTurns[i] = g_iGuaranteedCTTurns[i];
        queue[i] = g_iHiderToSeekerQueue[i];
    }

    while (queueOrder > 0) {
        int switches;
        for (int i = 1; i <= MaxClients; i++) {
            if (guaranteedCTTurns[i] > 0) {
                guaranteedCTTurns[i]--;
            }

            if (guaranteedCTTurns[i] == 0) {
                switches++;
                guaranteedCTTurns[i] = -1;
            }
        }
        queueOrder -= switches;
        turns++;
    }

    return turns;
}

stock bool SwitchNextSeeker() {
    int guaranteedTurnsToSeek = 0;
    while (guaranteedTurnsToSeek <= GetConVarInt(cvar_GuaranteedCTTurns)) {
        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i)
                    && g_iClientTeam[i] == CS_TEAM_CT
                    && !g_bClientTeambalanced[i]
                    && g_iGuaranteedCTTurns[i] == guaranteedTurnsToSeek) {
                g_iClientTeam[i] = CS_TEAM_T;
                g_bClientTeambalanced[i] = true;
                return true;
            }
        }

        guaranteedTurnsToSeek++;
    }

    // there are no clients "really" in CT yet. Choose any.
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)
                && g_iClientTeam[i] == CS_TEAM_CT
                && !g_bClientTeambalanced[i]) {
            g_iClientTeam[i] = CS_TEAM_T;
            g_bClientTeambalanced[i] = true;
            return true;
        }
    }

    return false;
}

stock bool SwitchNextHiderInQueue() {
    if (!g_iHidersInSeekerQueue) {
        int client = GetRandomClient(CS_TEAM_T, false, true);
        if (!client)
            return false;
        g_iClientTeam[client] = CS_TEAM_CT;
        g_bClientTeambalanced[client] = true;
    } else {
        for (int i = 1; i <= MaxClients; i++) {
            if (g_iHiderToSeekerQueue[i] == 1) {
                g_iHidersInSeekerQueue--;
                g_iHiderToSeekerQueue[i] = NOT_IN_QUEUE;

                if (g_iClientTeam[i] == CS_TEAM_CT)
                    return false;

                g_iClientTeam[i] = CS_TEAM_CT;
                g_bClientTeambalanced[i] = true;
            } else if (g_iHiderToSeekerQueue[i] > 1) {
                g_iHiderToSeekerQueue[i]--;
            }
        }
    }

    return true;
}

stock void ScrambleTeams() {
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && GetClientTeam(i) != CS_TEAM_SPECTATOR) {
            int newTeam = (GetRandomInt(0, 1) ? CS_TEAM_CT : CS_TEAM_T);
            g_iClientTeam[i] = newTeam;
        }
    }
}
