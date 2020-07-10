
#include "prophunt/include/clientutils.inc"

public Action Cmd_spec_next(int client, const char[] command, int argc) {
    return SpecNext(client);
}

public Action SpecNext(int client) {
    if (client == 0 || !IsClientInGame(client) || IsPlayerAlive(client))
        return Plugin_Handled;

    int allowedTeams = DetermineAllowedSpecTeams(client);
    if (allowedTeams == -1)
        return Plugin_Continue;

    int target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
    int nextTarget = GetNextClient(target, true, allowedTeams);
    
    //PrintToServer("Debug: next spectator target requested");

    if (nextTarget != -1)
        SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", nextTarget);

    return Plugin_Handled;
}

public Action Cmd_spec_prev(int client, const char[] command, int argc) {
    return SpecPrev(client);
}

public Action SpecPrev(int client) {
    if (client == 0 || !IsClientInGame(client) || IsPlayerAlive(client))
        return Plugin_Handled;

    int allowedTeams = DetermineAllowedSpecTeams(client);
    if (allowedTeams == -1)
        return Plugin_Continue;

    int target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
    int nextTarget = GetNextClient(target, false, allowedTeams);

    if (nextTarget != -1)
        SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", nextTarget);

    return Plugin_Handled;
}

public Action Cmd_spec_player(int client, const char[] command, int argc) {
    if (client == 0 || !IsClientInGame(client) || IsPlayerAlive(client))
        return Plugin_Handled;

    if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
        return Plugin_Continue;

    int allowedTeams = DetermineAllowedSpecTeams(client);

    if (allowedTeams == -1)
        return Plugin_Continue;

    char arg[128];
    GetCmdArg(1, arg, sizeof(arg));
    if (arg[0]) {
        char targetName[128];
        int targets[MAXPLAYERS];
        bool tn_is_ml;
        int numTargets = ProcessTargetString(
                arg,
                client,
                targets,
                MaxClients,
                COMMAND_FILTER_CONNECTED,
                targetName,
                sizeof(targetName),
                tn_is_ml);

        if (numTargets <= 0) {
            ReplyToTargetError(client, numTargets);
            return SpecNext(client);
        }

        if (numTargets != 1) {
            //PrintToServer("Debug: Bad target count");
            return SpecNext(client);
        }

        int target = targets[0];

        if (GetClientTeam(target) != allowedTeams) {
            SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", GetRandomClient(allowedTeams, true));
            return Plugin_Handled;
        }

        SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", target);
    }

    return Plugin_Handled;
}

public Action Cmd_spec_mode(int client, const char[] command, int argc) {
    if (client == 0 || !IsClientInGame(client) || IsPlayerAlive(client))
        return Plugin_Handled;

    int observerMode = DetermineSpecMode(client);
    SetEntProp(client, Prop_Send, "m_iObserverMode", observerMode);

    return Plugin_Handled;
}

public Action Timer_SetObserv(Handle timer, int client) {
    if (IsClientInGame(client) && !IsPlayerAlive(client)) {
        int allowedTeams = DetermineAllowedSpecTeams(client);
        int target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

        if (target == -1 || (allowedTeams != -1 && GetClientTeam(target) != allowedTeams)) {
            if (target == -1)
                target = client;

            int nextTarget = GetNextClient(target, true, allowedTeams);
            if (nextTarget != -1)
                SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", nextTarget);
        }

        CreateTimer(0.1, Timer_SetMode, client);
    }
}

// make any players observing a dead CT observe another CT 
public Action Timer_CheckObservers(Handle timer, int client) {
    if (IsClientInGame(client) && !IsPlayerAlive(client)) {
        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && !IsPlayerAlive(i) && i != client) {

                // who this player is observing now
                int target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
                if (target == client) {
                    int allowedTeams = DetermineAllowedSpecTeams(client);

                    // if it's the dead player, pick a int target
                    int nextTarget = GetNextClient(client, true, allowedTeams);
                    if (nextTarget > 0)
                        SetEntPropEnt(i, Prop_Send, "m_hObserverTarget", nextTarget);
                }
            }
        }
    }
}

public Action Timer_SetMode(Handle timer, int client) {
    if (IsClientConnected(client) && IsClientInGame(client) && !IsPlayerAlive(client)) {
        int observerMode = DetermineSpecMode(client);
        SetEntProp(client, Prop_Send, "m_iObserverMode", observerMode);
    }
}

