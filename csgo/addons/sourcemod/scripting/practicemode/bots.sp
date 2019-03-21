stock int CreateBot(int client, bool forceCrouch, const char[] providedName = "",
                    int botTeam = CS_TEAM_NONE) {
  char name[MAX_NAME_LENGTH + 1];
  int botNumberTaken = -1;
  if (StrEqual(providedName, "")) {
    GetClientName(client, name, sizeof(name));
    StrCat(name, sizeof(name), " ");
    botNumberTaken = SelectBotNumber(client);
    if (botNumberTaken > 1) {
      char buf[MAX_NAME_LENGTH + 1];
      Format(buf, sizeof(buf), "%d ", botNumberTaken);
      StrCat(name, sizeof(name), buf);
    }

  } else {
    Format(name, sizeof(name), "%s ", providedName);
  }

  int bot = CreateFakeClient(name);
  if (bot <= 0) {
    PM_Message(client, "Failed to create bot :(");
    return -1;
  }

  g_BotNameNumber[bot] = botNumberTaken;
  g_ClientBots[client].Push(bot);
  g_IsPMBot[bot] = true;

  if (botTeam == CS_TEAM_NONE) {
    botTeam = GetClientTeam(client) == CS_TEAM_CT ? CS_TEAM_T : CS_TEAM_CT;
  }
  ChangeClientTeam(bot, botTeam);

  bool clientCrouching = (GetEntityFlags(client) & FL_DUCKING != 0);
  g_BotCrouching[bot] = forceCrouch || clientCrouching;

  CS_RespawnPlayer(bot);
  return bot;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
  int victim = GetClientOfUserId(event.GetInt("userid"));
  if (IsPMBot(victim)) {
    g_BotDeathTime[victim] = GetGameTime();
  }
}

public Action Timer_RespawnBots(Handle timer) {
  if (!g_InPracticeMode) {
    return Plugin_Continue;
  }

  for (int i = 1; i <= MaxClients; i++) {
    if (IsPMBot(i) && !IsPlayerAlive(i)) {
      bool respawn = true;
      if (GetClientTeam(i) == CS_TEAM_CT) {
        respawn = !!GetCvarIntSafe("mp_respawn_on_death_ct", true);
      } else if (GetClientTeam(i) == CS_TEAM_T) {
        respawn = !!GetCvarIntSafe("mp_respawn_on_death_t", true);
      }

      float dt = GetGameTime() - g_BotDeathTime[i];
      if (respawn && dt >= g_BotRespawnTimeCvar.FloatValue) {
        CS_RespawnPlayer(i);
      }
    }
  }
  return Plugin_Continue;
}

public int SelectBotNumber(int client) {
  if (g_ClientBots[client].Length == 0) {
    return 1;
  }

  for (int i = 1; i <= MaxClients; i++) {
    bool numberTaken = false;
    for (int j = 0; j < g_ClientBots[client].Length; j++) {
      int bot = g_ClientBots[client].Get(j);
      if (g_BotNameNumber[bot] == i) {
        numberTaken = true;
        break;
      }
    }

    if (!numberTaken) {
      return i;
    }
  }

  return -1;
}

bool IsPMBot(int client) {
  return client > 0 && g_IsPMBot[client] && IsClientInGame(client) && IsFakeClient(client);
}

// index=-1 implies the last bot added.
stock int GetClientBot(int client, int index = -1) {
  if (index == -1) {
    int len = g_ClientBots[client].Length;
    if (len == 0) {
      return -1;
    } else {
      return g_ClientBots[client].Get(len - 1);
    }
  }

  if (g_ClientBots[client].Length <= index) {
    return -1;
  }

  int bot = g_ClientBots[client].Get(index);
  if (IsPMBot(bot)) {
    return bot;
  }
  return -1;
}

public int GetBotsOwner(int bot) {
  if (!IsPMBot(bot)) {
    return -1;
  }
  for (int i = 0; i <= MaxClients; i++) {
    ArrayList list = g_ClientBots[i];
    if (list.FindValue(bot) >= 0) {
      return i;
    }
  }
  return -1;
}

public int FindBotIndex(int client, int bot) {
  for (int i = 0; i < g_ClientBots[client].Length; i++) {
    if (g_ClientBots[client].Get(i) == bot) {
      return i;
    }
  }
  return -1;
}

stock bool KickClientBot(int client, int index = -1) {
  int bot = GetClientBot(client, index);
  if (bot > 0) {
    KickClient(bot);
    g_IsPMBot[bot] = false;
    FindAndErase(g_ClientBots[client], bot);
    return true;
  }
  return false;
}

public void KickAllClientBots(int client) {
  for (int i = 0; i < g_ClientBots[client].Length; i++) {
    int bot = g_ClientBots[client].Get(i);
    if (IsPMBot(bot)) {
      KickClient(bot);
    }
  }
  g_ClientBots[client].Clear();
}

void GiveBotParams(int bot) {
  // If we were giving a knife, let's give them a gun. We don't want to accidently try to give a
  // knife our beloved bot doesn't own on the steam market!
  // The bayonet knife is appearently called weapon_bayonet as well :(
  if (StrContains(g_BotSpawnWeapon[bot], "knife", false) >= 0 ||
      StrContains(g_BotSpawnWeapon[bot], "bayonet", false) >= 0) {
    if (GetClientTeam(bot) == CS_TEAM_CT) {
      g_BotSpawnWeapon[bot] = "weapon_m4a1";
    } else {
      g_BotSpawnWeapon[bot] = "weapon_ak47";
    }
  }

  Client_RemoveAllWeapons(bot);
  GivePlayerItem(bot, g_BotSpawnWeapon[bot]);
  TeleportEntity(bot, g_BotSpawnOrigin[bot], g_BotSpawnAngles[bot], NULL_VECTOR);
  Client_SetArmor(bot, 100);
  SetEntData(bot, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), true);
}

// Commands.

public Action Command_Bot(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char name[64];
  if (args >= 1) {
    GetCmdArgString(name, sizeof(name));
  }

  int bot = CreateBot(client, false, name);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  GetClientAbsOrigin(client, g_BotSpawnOrigin[bot]);
  GetClientEyeAngles(client, g_BotSpawnAngles[bot]);
  GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
  GiveBotParams(bot);
  PM_Message(client, "Created bot, use .nobot to remove it.");
  TemporarilyDisableCollisions(client, bot);
  return Plugin_Handled;
}

public Action Command_CTBot(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char name[64];
  if (args >= 1) {
    GetCmdArgString(name, sizeof(name));
  }

  int bot = CreateBot(client, false, name, CS_TEAM_CT);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  GetClientAbsOrigin(client, g_BotSpawnOrigin[bot]);
  GetClientEyeAngles(client, g_BotSpawnAngles[bot]);
  GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
  GiveBotParams(bot);
  PM_Message(client, "Created bot, use .nobot to remove it.");
  TemporarilyDisableCollisions(client, bot);
  return Plugin_Handled;
}

public Action Command_TBot(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char name[64];
  if (args >= 1) {
    GetCmdArgString(name, sizeof(name));
  }

  int bot = CreateBot(client, false, name, CS_TEAM_T);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  GetClientAbsOrigin(client, g_BotSpawnOrigin[bot]);
  GetClientEyeAngles(client, g_BotSpawnAngles[bot]);
  GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
  GiveBotParams(bot);
  PM_Message(client, "Created bot, use .nobot to remove it.");
  TemporarilyDisableCollisions(client, bot);
  return Plugin_Handled;
}

public Action Command_MoveBot(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int bot = GetClientBot(client);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  GetClientAbsOrigin(client, g_BotSpawnOrigin[bot]);
  GetClientEyeAngles(client, g_BotSpawnAngles[bot]);
  GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
  GiveBotParams(bot);

  TemporarilyDisableCollisions(client, bot);
  return Plugin_Handled;
}

public Action Command_CrouchBot(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char name[64];
  if (args >= 1) {
    GetCmdArgString(name, sizeof(name));
  }

  int bot = CreateBot(client, true, name);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  GetClientAbsOrigin(client, g_BotSpawnOrigin[bot]);
  GetClientEyeAngles(client, g_BotSpawnAngles[bot]);
  GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
  GiveBotParams(bot);

  TemporarilyDisableCollisions(client, bot);
  PM_Message(client, "Created bot, use .nobot to remove it.");
  return Plugin_Handled;
}

public Action Command_BotPlace(int client, int args) {
  // Based on Franc1sco's bot_spawner plugin:
  // https://github.com/Franc1sco/BotSpawner/blob/master/bot_spawner.sp
  int bot = CreateBot(client, false);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  float start[3], angle[3], end[3], normal[3];
  GetClientEyePosition(client, start);
  GetClientEyeAngles(client, angle);

  TR_TraceRayFilter(start, angle, MASK_SOLID, RayType_Infinite, RayDontHitSelf, client);
  if (TR_DidHit(INVALID_HANDLE)) {
    TR_GetEndPosition(end, INVALID_HANDLE);
    TR_GetPlaneNormal(INVALID_HANDLE, normal);
    GetVectorAngles(normal, normal);
    normal[0] += 90.0;

    g_BotSpawnOrigin[bot] = end;
    g_BotSpawnAngles[bot] = normal;
    GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
    GiveBotParams(bot);
  }

  PM_Message(client, "Created bot, use .nobot to remove it.");
  return Plugin_Handled;
}

public Action Command_Boost(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int bot = CreateBot(client, false);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  float origin[3];
  GetClientAbsOrigin(client, origin);
  g_BotSpawnOrigin[bot] = origin;

  GetClientEyeAngles(client, g_BotSpawnAngles[bot]);
  GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
  GiveBotParams(bot);

  origin[2] += PLAYER_HEIGHT + 4.0;
  TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
  PM_Message(client, "Created bot, use .nobot to remove it.");
  return Plugin_Handled;
}

public Action Command_CrouchBoost(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  int bot = CreateBot(client, true);
  if (bot <= 0) {
    return Plugin_Handled;
  }

  float origin[3];
  GetClientAbsOrigin(client, origin);
  g_BotSpawnOrigin[bot] = origin;

  GetClientEyeAngles(client, g_BotSpawnAngles[bot]);
  GetClientWeapon(client, g_BotSpawnWeapon[bot], CLASS_LENGTH);
  GiveBotParams(bot);

  origin[2] += CROUCH_PLAYER_HEIGHT + 4.0;
  TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
  PM_Message(client, "Created bot, use .nobot to remove it.");
  return Plugin_Handled;
}

public bool RayDontHitSelf(int entity, int contentsMask, any data) {
  return entity != data;
}

public Action Command_RemoveBot(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  if (g_ClientBots[client].Length == 1) {
    KickClientBot(client, 0);
    return Plugin_Handled;
  }

  int target = GetClientAimTarget(client, true);
  if (IsPMBot(target)) {
    int botIndex = FindBotIndex(client, target);
    if (botIndex >= 0) {
      KickClientBot(client, botIndex);
      return Plugin_Handled;
    } else {
      PM_Message(client, "You can only kick your own bots.");
    }
  } else {
    PM_Message(client, "No bot found. Aim at the bot you want to remove.");
  }

  return Plugin_Handled;
}

public Action Command_RemoveBots(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  KickAllClientBots(client);
  return Plugin_Handled;
}

public Action Event_BotDamageDealtEvent(Event event, const char[] name, bool dontBroadcast) {
  if (!g_InPracticeMode) {
    return Plugin_Continue;
  }

  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  int victim = GetClientOfUserId(event.GetInt("userid"));

  if (IsPMBot(victim) && IsPlayer(attacker)) {
    int damage = event.GetInt("dmg_health");
    int postDamageHealth = event.GetInt("health");
    PM_Message(attacker, "---> %d damage to BOT %N(%d health)", damage, victim, postDamageHealth);
  }

  return Plugin_Continue;
}

// TODO: rework this to print the message to the bot owner AND the flash thrower.
// It probably needs to use the flashbang_detonate event (so piggyback on Event_FlashDetonate).
public Action Event_PlayerBlind(Event event, const char[] name, bool dontBroadcast) {
  if (!g_InPracticeMode) {
    return;
  }

  int userid = event.GetInt("userid");
  int client = GetClientOfUserId(userid);
  if (IsPMBot(client)) {
    int owner = GetBotsOwner(client);
    if (IsPlayer(owner)) {
      PM_Message(owner, "---> %.1f second flash for BOT %N", GetFlashDuration(client), client);
    }

    // Did anyone throw a flash recently? If so, they probably care about this bot being blinded.
    float now = GetGameTime();
    for (int i = 1; i <= MaxClients; i++) {
      if (owner != i && IsPlayer(i) && FloatAbs(now - g_LastFlashDetonateTime[i]) < 0.001) {
        PM_Message(i, "---> %.1f second flash for BOT %N", GetFlashDuration(client), client);
      }
    }
  }

  // TODO: move this into another place (has nothing to do with bots!)
  if (g_ClientNoFlash[client]) {
    RequestFrame(KillFlashEffect, GetClientSerial(client));
  }
}

public void KillFlashEffect(int serial) {
  int client = GetClientFromSerial(serial);
  // Idea used from SAMURAI16 @ https://forums.alliedmods.net/showthread.php?p=685111
  SetEntDataFloat(client, FindSendPropInfo("CCSPlayer", "m_flFlashMaxAlpha"), 0.5);
}

public Action Command_SaveBots(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  bool hasCurrentBots = IsPMBot(GetClientBot(client));
  if (!hasCurrentBots) {
    // This is mostly just to prevent accidental deletion.
    PM_Message(client, "You can't save bots when you have none added.");
    return Plugin_Handled;
  }

  char mapName[PLATFORM_MAX_PATH];
  GetCleanMapName(mapName, sizeof(mapName));
  char path[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, path, sizeof(path), "data/practicemode/bots/%s.cfg", mapName);
  KeyValues botsKv = new KeyValues("Bots");

  int output_index = 0;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPMBot(i)) {
      char sBuf[32];
      IntToString(output_index, sBuf, sizeof(sBuf));
      output_index++;
      botsKv.JumpToKey(sBuf, true);
      botsKv.SetVector("origin", g_BotSpawnOrigin[i]);
      botsKv.SetVector("angle", g_BotSpawnAngles[i]);
      botsKv.SetString("weapon", g_BotSpawnWeapon[i]);
      botsKv.SetNum("crouching", g_BotCrouching[i]);

      if (g_BotNameNumber[i] == -1) {
        char name[MAX_NAME_LENGTH + 1];
        GetClientName(i, name, sizeof(name));
        botsKv.SetString("name", name);
      }

      botsKv.GoBack();
    }
  }

  DeleteFile(path);
  if (!botsKv.ExportToFile(path)) {
    LogError("Failed to write bots file to %s", path);
  }
  delete botsKv;

  PM_MessageToAll("Saved bot spawns.");
  return Plugin_Handled;
}

public Action Command_LoadBots(int client, int args) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  char mapName[PLATFORM_MAX_PATH];
  GetCleanMapName(mapName, sizeof(mapName));
  char path[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, path, sizeof(path), "data/practicemode/bots/%s.cfg", mapName);

  KeyValues botsKv = new KeyValues("Bots");
  botsKv.ImportFromFile(path);
  botsKv.GotoFirstSubKey();

  do {
    char name[MAX_NAME_LENGTH + 1];
    botsKv.GetString("name", name, sizeof(name));
    bool crouching = !!botsKv.GetNum("crouching");

    int bot = CreateBot(client, crouching, name);
    if (bot <= 0) {
      return Plugin_Handled;
    }
    botsKv.GetVector("origin", g_BotSpawnOrigin[bot], NULL_VECTOR);
    botsKv.GetVector("angle", g_BotSpawnAngles[bot], NULL_VECTOR);
    botsKv.GetString("weapon", g_BotSpawnWeapon[bot], 64);
    g_BotCrouching[bot] = crouching;
    GiveBotParams(bot);
  } while (botsKv.GotoNextKey());

  delete botsKv;
  PM_MessageToAll("Loaded bot spawns.");
  return Plugin_Handled;
}

public Action Command_SwapBot(int client, int args) {
  int target = GetClientAimTarget(client, true);
  if (!IsPMBot(target)) {
    target = FindClosestBot(client);
  }

  if (IsPMBot(target)) {
    float origin[3];
    float angles[3];
    GetClientAbsOrigin(client, origin);
    GetClientEyeAngles(client, angles);
    TeleportEntity(client, g_BotSpawnOrigin[target], g_BotSpawnAngles[target], NULL_VECTOR);
    TeleportEntity(target, origin, angles, NULL_VECTOR);
  }

  return Plugin_Handled;
}

public int FindClosestBot(int client) {
  float origin[3];
  GetClientAbsOrigin(client, origin);
  float minDist = 0.0;
  int minBot = -1;
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPMBot(i)) {
      float dist = GetVectorDistance(origin, g_BotSpawnOrigin[i]);
      if (minBot == -1 || dist < minDist) {
        minBot = i;
        minDist = dist;
      }
    }
  }

  return minBot;
}

void TemporarilyDisableCollisions(int client1, int client2) {
  Entity_SetCollisionGroup(client1, COLLISION_GROUP_DEBRIS);
  Entity_SetCollisionGroup(client2, COLLISION_GROUP_DEBRIS);
  DataPack pack;
  CreateDataTimer(0.1, Timer_ResetCollisions, pack, TIMER_REPEAT);
  pack.WriteCell(GetClientSerial(client1));
  pack.WriteCell(GetClientSerial(client2));
}

public Action Timer_ResetCollisions(Handle timer, DataPack pack) {
  pack.Reset();
  int client1 = GetClientFromSerial(pack.ReadCell());
  int client2 = GetClientFromSerial(pack.ReadCell());
  if (!IsValidClient(client1) || !IsValidClient(client2)) {
    return Plugin_Handled;
  }

  if (DoPlayersCollide(client1, client2)) {
    return Plugin_Continue;
  }

  Entity_SetCollisionGroup(client1, COLLISION_GROUP_PLAYER);
  Entity_SetCollisionGroup(client2, COLLISION_GROUP_PLAYER);
  return Plugin_Handled;
}
