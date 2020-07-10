
#if defined _clientutils_included
    #endinput
#endif
#define _clientutils_included

#include "prophunt/include/phclient.inc"

#define SPECMODE_NONE           0
#define SPECMODE_FIRSTPERSON    4
#define SPECMODE_THIRDPERSON    5
#define SPECMODE_FREELOOK       6

stock void OfferClientModel(int client) {
    float changeLimitTime = GetConVarFloat(cvar_ChangeLimittime);

    if (GetConVarBool(cvar_AutoChoose))
        SetRandomModel(client);
    else if (changeLimitTime > 0.0)
        DisplayMenu(g_hModelMenu, client, RoundToFloor(changeLimitTime));
    else 
        DisplayMenu(g_hModelMenu, client, MENU_TIME_FOREVER);
}

stock int GetRandomClient(int team, bool onlyAlive=false, bool onlyNonSwitching=false) {
    int clientIndex;
    int[] clients = new int[MaxClients];
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && GetClientTeam(i) == team && (IsPlayerAlive(i) || !onlyAlive)) {
            bool isBeingSwitched = g_iClientTeam[i] != team;
            if (!onlyNonSwitching || !isBeingSwitched) {
                clients[clientIndex] = i;
                clientIndex++;
            }
        }
    }

    return clients[GetRandomInt(0, clientIndex-1)];
}

stock void PreventCTFire(PHClient client, int &buttons) {
    if (!client || client.team != CS_TEAM_CT)
        return;

    char weaponName[30];

    GetClientWeapon(client.index, weaponName, sizeof(weaponName));
    if (g_bIsCTWaiting[client.index] && (buttons & IN_ATTACK || buttons & IN_ATTACK2)) {
        // dont allow shooting in the beginning of the round
        buttons &= ~IN_ATTACK;
        buttons &= ~IN_ATTACK2;
    } else if (buttons & IN_ATTACK2 && StrEqual(weaponName, "weapon_knife")) {

        // disable rightclick knifing
        buttons &= ~IN_ATTACK2;
    }
}

stock void BlindClient(int client, bool blind=true) {
    Handle hFadeClient = StartMessageOne("Fade", client);
    PbSetInt(hFadeClient, "duration", 1);
    PbSetInt(hFadeClient, "hold_time", 3);

    if (blind) {
        PbSetInt(hFadeClient, "flags", FFADE_STAYOUT);
    } else {
        PbSetInt(hFadeClient, "flags", FFADE_PURGE);
    }

    int color[] = {255, 0, 0, 255};
    PbSetColor(hFadeClient, "clr", color);
    EndMessage();
}

stock void StripClientWeapons(int client) {
    int iWeapon = -1;
    for (int i = CS_SLOT_PRIMARY; i <= CS_SLOT_C4; i++) {
        while ((iWeapon = GetPlayerWeaponSlot(client, i)) != -1) {
            RemovePlayerItem(client, iWeapon);
            RemoveEdict(iWeapon);
        }
    }
}

stock void SetModelChangeTimer(int client) {
    float changeLimitTime = GetConVarFloat(cvar_ChangeLimittime);

    // only set the timer if it's not unlimited
    if (changeLimitTime > 0.0)
        g_hAllowModelChangeTimer[client] = CreateTimer(changeLimitTime, DisableModelMenu, client);
}

stock bool IsPlayerAFK(int client) {
    float fOrigin[3];
    GetClientAbsOrigin(client, fOrigin);

    // Did he move after spawn?
    return UTIL_VectorEqual(fOrigin, g_fSpawnPosition[client], 0.1);
}

stock void RemoveClientRadar(int client) {
    int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
    SetEntProp(client, Prop_Send, "m_iHideHUD", hud | 1<<12);
}

stock void SlayClient(PHClient client) {
    if (client && client.isAlive)
        ForcePlayerSuicide(client.index);
}

stock void FreezePlayer(PHClient client) {

    // Force him to watch at the ground.
    float fPlayerEyes[3];
    GetClientEyeAngles(client.index, fPlayerEyes);
    fPlayerEyes[0] = 180.0;
    client.Teleport(NULL_VECTOR, fPlayerEyes, NULL_VECTOR);
    SetEntData(client.index, g_Freeze, FL_CLIENT | FL_ATCONTROLS, 4, true);
    client.SetMoveType(MOVETYPE_NONE);
    BlindClient(client.index, true);
}

stock void UnFreezePlayer(int client) {
    SetEntData(client, g_Freeze, FL_FAKECLIENT | FL_ONGROUND | FL_PARTIALGROUND, 4, true);
    SetEntityMoveType(client, MOVETYPE_WALK);
    BlindClient(client, false);
    g_bIsCTWaiting[client] = false;
    EmitSoundToClient(client, "radio/go.wav");
    PrintToChat(client, "%s%t", PREFIX, "Go search");
}

stock void CheckClientHasKnife(PHClient client) {
    if (client.isAlive) {
        int iWeapon = GetPlayerWeaponSlot(client.index, 2);
        if (iWeapon == -1) {
            iWeapon = GivePlayerItem(client.index, "weapon_knife");
        }
    }
}

stock void SaveClientSpawnPosition(PHClient client) {
    client.GetOrigin(g_fSpawnPosition[client]);
}

static stock bool UTIL_VectorEqual(const float vec1[3], const float vec2[3], const float tolerance) {
    for (int i = 0; i < 3; i++)
        if (vec1[i] > (vec2[i] + tolerance) || vec1[i] < (vec2[i] - tolerance))
            return false;
    return true;
}

/**
 * Returns the next or previous client by id.
 *
 * @param client        Client from which the searching begins
 * @param fw            If false, returns a previous client instead of next.
 * @param team          Limit searching to a specific team, or -1 to search any.
 * @return The next or previous client.
 */
stock int GetNextClient(int client, bool fw=true, int team=-1) {
    int d = (fw ? 1 : -1);
    int i = client + d;
    int begin = (fw ? 1 : MaxClients);
    int limit = (fw ? MaxClients + 1 : 0);

    while (!IsClientInTeam(i, team)) {

        // move index; if index == limit, move it to the beginning
        i = (i + d == limit ? begin : i + d);

        // we made a full circle. no suitable client found
        if (i == client)
            return -1;
    }

    return i;
}

stock bool IsClientInTeam(int client, int team) {
    return client != 0
            && IsClientConnected(client)
            && IsPlayerAlive(client)
            && (GetClientTeam(client) == team || team == -1);
}

stock int DetermineSpecMode(int client) {
    int currMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
    int limitSpec = GetConVarInt(cvar_LimitSpec);
    int newMode = currMode + 1;
    if (newMode > SPECMODE_FREELOOK)
        newMode = SPECMODE_FIRSTPERSON;

    if (limitSpec == 1 && newMode == SPECMODE_FREELOOK)
        newMode = SPECMODE_FIRSTPERSON;
    else if (limitSpec == 2)
        newMode = SPECMODE_FIRSTPERSON;

    return newMode;
}

stock int DetermineAllowedSpecTeams(int client) {
    int limitSpec = GetConVarInt(cvar_LimitSpec);
    int team = -1;
    if (limitSpec == 1)
        team = GetClientTeam(client);
    else if (limitSpec == 2)
        team = CS_TEAM_CT;

    return team;
}

stock void MakeClientWhistle(int client) {
    char buffer[128], sound[MAX_WHISTLE_LENGTH];
    int soundIndex = GetRandomInt(0, g_WhistleSounds.Length - 1);
    g_WhistleSounds.GetString(soundIndex, sound, MAX_WHISTLE_LENGTH);
    Format(buffer, sizeof(buffer), "*/%s", sound);

    EmitSoundToAll(buffer, client, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
}
