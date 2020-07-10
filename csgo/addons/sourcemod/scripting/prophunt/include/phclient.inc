
#include "prophunt/include/phentity.inc"

#if defined _phclient_included
    #endinput
#endif
#define _phclient_included

float NO_VELOCITY[3] = {0.0, 0.0, 0.0};

methodmap PHClient < PHEntity 
{
    /**
     * Creates a new PHClient wrapper for a client.
     *
     * @param client     Client index to wrap.
     */
    public PHClient(int client) {
        return view_as<PHClient>(client);
    }

    /**
     * Team the client belongs to.
     */ 
    property int team {
        public get() {
            return PHClient_GetTeam(this);
        }
    }

    /**
     * Is this client alive?
     */
    property bool isAlive {
        public get() {
            return PHClient_GetIsAlive(this);
        }
    }

    /**
     * Has this client been freezed?
     */
    property bool isFreezed {
        public get() {
            return PHClient_GetIsFreezed(this);
        }
    }

    /**
     * Is this client connected to the server?
     */
    property bool isConnected {
        public get() {
            return PHClient_GetIsConnected(this);
        }
    }

    /**
     * Freezes or unfreezes the client.
     *
     * @param freezed   True to freeze, false to unfreeze.
     */
    public void SetFreezed(bool freezed) {
        PHClient_SetFreezed(this, freezed);
    }

}

bool g_ClientIsFreezed[MAXPLAYERS] = {false, ...};

/**
 * Returns the team a client belongs to.
 *
 * @param client    Client.
 * @return          Client team
 */ 
stock int PHClient_GetTeam(PHClient client) {
    return GetClientTeam(client.index);
}

/**
 * Is a client alive?
 *
 * @param client    Client.
 * @return          True if alive, false otherwise
 */
stock bool PHClient_GetIsAlive(PHClient client) {
    return IsPlayerAlive(client.index);
}

/**
 * Has a client been freezed?
 *
 * @param client    Client.
 * @return          True if freezed, false otherwise
 */
stock bool PHClient_GetIsFreezed(PHClient client) {
    return g_ClientIsFreezed[client.index];
}

/**
 * Is a client connected to the server?
 *
 * @param client    Client.
 * @return          True if connected, false otherwise
 */
stock bool PHClient_GetIsConnected(PHClient client) {
    return IsClientConnected(client.index);
}

/**
 * Freezes or unfreezes a client.
 *
 * @param freezed   True to freeze, false to unfreeze.
 * @noreturn
 */
stock void PHClient_SetFreezed(PHClient client, bool freeze) {
    if (!client.isFreezed && freeze) { // freeze
        if (GetConVarInt(cvar_HiderFreezeMode) == 1) {
            client.SetMoveType(MOVETYPE_NONE); // Still able to move camera
        } else {
            SetEntData(client.index, g_Freeze, FL_CLIENT | FL_ATCONTROLS, 4, true); // Cant move anything
            client.SetMoveType(MOVETYPE_NONE);
        }

        client.Teleport(NULL_VECTOR, NULL_VECTOR, NO_VELOCITY);
        g_ClientIsFreezed[client.index] = true;

        client.DetachChild();
    } else if (client.isFreezed) { // unfreeze
        if (GetConVarInt(cvar_HiderFreezeMode) == 1) {
            client.SetMoveType(MOVETYPE_WALK);
        } else {
            SetEntData(client.index, g_Freeze, FL_FAKECLIENT | FL_ONGROUND | FL_PARTIALGROUND, 4, true);
            client.SetMoveType(MOVETYPE_WALK);
        }

        g_ClientIsFreezed[client.index] = false;
        client.AttachChild();
    }
}

stock PHClient GetPHClient(int client) {
    if (client < 1 || client > MAXPLAYERS)
        return null;

    return view_as<PHClient>(GetPHEntity(client));
}

stock PHClient RegisterPHClient(int client) {
    if (client < 1 || client > MAXPLAYERS)
        return null;

    return view_as<PHClient>(RegisterPHEntity(client));
}

stock void UnregisterPHClient(int client) {
    UnregisterPHEntity(client);
}

