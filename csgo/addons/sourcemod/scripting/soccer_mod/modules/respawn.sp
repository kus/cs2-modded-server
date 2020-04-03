Handle respawnTimers[MAXPLAYERS + 1];

// ************************************************************************************************************
// ************************************************** EVENTS **************************************************
// ************************************************************************************************************
public void RespawnOnClientPutInServer(int client)
{
    respawnTimers[client] = null;
}

public void RespawnOnClientDisconnect(int client)
{
    if (respawnTimers[client] != null)
    {
        KillTimer(respawnTimers[client]);
        respawnTimers[client] = null;
    }
}

public void RespawnEventPlayer(Event event)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    respawnTimers[client] = CreateTimer(respawnDelay, TimerRespawn, client);
}

// ************************************************************************************************************
// ************************************************** TIMERS **************************************************
// ************************************************************************************************************
public Action TimerRespawn(Handle timer, any client)
{
    respawnTimers[client] = null;

    if (client > 0 && IsClientInGame(client) && IsClientConnected(client) && !IsPlayerAlive(client) && !roundEnded && GetClientTeam(client) > 1) CS_RespawnPlayer(client);
}