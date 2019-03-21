public bool CanHear(int shooter, int client) {
  if (!IsValidClient(shooter) || !IsValidClient(client) || shooter == client) {
    return true;
  }

  float pos[3];
  GetClientAbsOrigin(client, pos);

  // Block the transmisson.
  if (Multi1v1_GetArenaNumber(shooter) != FindClosestArenaNumber(pos)) {
    return false;
  }

  // Transmit by default.
  return true;
}

public Action Hook_ShotgunShot(const char[] te_name, const int[] players, int numClients, float delay) {
  if (g_MuteOtherArenasCvar.IntValue == 0 || g_EnabledCvar.IntValue == 0) {
    return Plugin_Continue;
  }

  int shooterIndex = TE_ReadNum("m_iPlayer") + 1;

  // Check which clients need to be excluded.
  int[] newClients = new int[MaxClients];
  int newTotal = 0;

  for (int i = 0; i < numClients; i++) {
    int client = players[i];

    bool rebroadcast = true;
    if (!IsPlayer(client)) {
      rebroadcast = true;
    } else {
      rebroadcast = CanHear(shooterIndex, client);
    }

    if (rebroadcast) {
      // This Client should be able to hear it.
      newClients[newTotal] = client;
      newTotal++;
    }
  }

  // No clients were excluded.
  if (newTotal == numClients) {
    return Plugin_Continue;
  }

  // All clients were excluded and there is no need to broadcast.
  if (newTotal == 0) {
    return Plugin_Stop;
  }

  // Re-broadcast to clients that still need it.
  float vTemp[3];
  TE_Start("Shotgun Shot");
  TE_ReadVector("m_vecOrigin", vTemp);
  TE_WriteVector("m_vecOrigin", vTemp);
  TE_WriteFloat("m_vecAngles[0]", TE_ReadFloat("m_vecAngles[0]"));
  TE_WriteFloat("m_vecAngles[1]", TE_ReadFloat("m_vecAngles[1]"));
  TE_WriteNum("m_weapon", TE_ReadNum("m_weapon"));
  TE_WriteNum("m_iMode", TE_ReadNum("m_iMode"));
  TE_WriteNum("m_iSeed", TE_ReadNum("m_iSeed"));
  TE_WriteNum("m_iPlayer", TE_ReadNum("m_iPlayer"));
  TE_WriteFloat("m_fInaccuracy", TE_ReadFloat("m_fInaccuracy"));
  TE_WriteFloat("m_fSpread", TE_ReadFloat("m_fSpread"));
  TE_Send(newClients, newTotal, delay);

  return Plugin_Stop;
}
