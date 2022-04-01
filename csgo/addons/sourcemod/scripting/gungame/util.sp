UTIL_FindMapObjective()
{
    new i = FindEntityByClassname(-1, "func_bomb_target");
    
    if(i > MaxClients)
    {
        MapStatus |= OBJECTIVE_BOMB;
    } else {
        if((i = FindEntityByClassname(-1, "info_bomb_target")) > MaxClients)
        {
            MapStatus |= OBJECTIVE_BOMB;
        }
    }
    
    if((i = FindEntityByClassname((i = 0), "hostage_entity")) > MaxClients)
    {
        MapStatus |= OBJECTIVE_HOSTAGE;
    }
    
    HostageEntInfo = FindEntityByClassname(-1, "cs_player_manager");
}

stock UTIL_ConvertWeaponToIndex()
{
    for(new i, b; i < WeaponOrderCount; i++)
    {
        /**
         * Found empty weapon name
         * Probably no more weapons since this one is empty.
         */
        if(!WeaponOrderName[i][0])
            break;

        UTIL_StringToLower(WeaponOrderName[i]);

        /* Future hash/tries or something lookup */
        if(!(b = UTIL_GetWeaponIndex(WeaponOrderName[i])))
        {
            LogMessage("[GunGame] *** FATAL ERROR *** Weapon Order has an invalid entry :: name %s :: level %d", WeaponOrderName[i], i + 1);
        }

        WeaponOrderId[i] = b;
    }
}

stock UTIL_PrintToClient(client, type, const String:szMsg[], any:...)
{
    if(client && IsFakeClient(client))
    {
        return;
    }

    decl String:Buffer[256];
    VFormat(Buffer, sizeof(Buffer), szMsg, 4);

    Buffer[192] = '\0';

    new String:MsgType[] = "TextMsg";
    new Handle:Chat = (!client) ? StartMessageAll(MsgType) : StartMessageOne(MsgType, client);

    if(Chat != INVALID_HANDLE)
    {
        BfWriteByte(Chat, type);
        BfWriteString(Chat, Buffer);
        EndMessage();
    }
}

UTIL_PrintToUpperLeft(r, g, b, const String:source[], any:...)
{
    decl String:Buffer[64];
    new Handle:Msg;
    for ( new i = 1; i <= MaxClients; i++ ) {
        if ( IsClientInGame(i) && !IsFakeClient(i) ) {
            SetGlobalTransTarget(i);
            VFormat(Buffer, sizeof(Buffer), source, 5);
            Msg = CreateKeyValues("msg");

            if ( Msg != INVALID_HANDLE ) {
                KvSetString(Msg, "title", Buffer);
                KvSetColor(Msg, "color", r, g, b, 255);
                KvSetNum(Msg, "level", 0);
                KvSetNum(Msg, "time", 20);

                CreateDialog(i, Msg, DialogType_Msg);

                CloseHandle(Msg);
            }
        }
    }
}

/* Weapon Index Lookup via Trie array */
UTIL_GetWeaponIndex(const String:Weapon[]) {
    if (!WeaponOpen) {
        // weaponinfo file not loaded
        LogError("[GunGame] WeaponInfo file not loaded.");

        return 0;
    }

    new len = 0;
    if ((strlen(Weapon) > 7) && (StrContains(Weapon, "weapon_") == 0)) {
        // truncate weapon name
        len = 7;
    }

    new index;
    if (GetTrieValue(TrieWeapon, Weapon[len], index)) {

        return index;
    }

    if ((strlen(Weapon[len]) > 6) && (StrContains(Weapon[len], "knife_") == 0)) {
        // the weapon is knife

        return g_WeaponIdKnife;
    }

    LogError("[GunGame] Weapon index for \"%s\" not found.", Weapon);

    return 0;
}

stock UTIL_CopyC(String:Dest[], len, const String:Source[], ch)
{
    new i = -1;
    while(++i < len && Source[i] && Source[i] != ch)
    {
        Dest[i] = Source[i];
    }
}

UTIL_ChangeFriendlyFire(bool:Status)
{
    new flags = GetConVarFlags(mp_friendlyfire);

    SetConVarFlags(mp_friendlyfire, flags & ~FCVAR_SPONLY|FCVAR_NOTIFY);
    SetConVarInt(mp_friendlyfire, Status? 1: 0);
    SetConVarFlags(mp_friendlyfire, flags);

    if (Status) {
        CPrintToChatAll("%t", "Friendly Fire has been enabled");
    } else {
        CPrintToChatAll("%t", "Friendly Fire has been disabled");
    }

    UTIL_PlaySound(0, AutoFF);
}

UTIL_SetClientGodMode(client, mode = 0)
{
    SetEntProp(client, Prop_Data, "m_takedamage", mode ? DAMAGE_NO : DAMAGE_YES, 1);
}

/**
 * Recalculate CurrentLeader.
 *
 * @param int client
 * @param int oldLevel
 * @param int newLevel
 * @return void
 */
UTIL_RecalculateLeader(client, oldLevel, newLevel)
{
    if ( newLevel == oldLevel )
    {
        return;
    }
    if ( newLevel < oldLevel )
    {
        if ( !CurrentLeader )
        {
            return;
        }
        if ( client == CurrentLeader )
        {
            // was the leader
            CurrentLeader = FindLeader();
            if ( CurrentLeader != client )
            {
                Call_StartForward(FwdLeader);
                Call_PushCell(CurrentLeader);
                Call_PushCell(newLevel);
                Call_PushCell(WeaponOrderCount);
                Call_Finish();
                UTIL_PlaySoundForLeaderLevel();
            }
            return;
        }
        // was not a leader
        return;
    }
    // newLevel > oldLevel
    if ( !CurrentLeader )
    {
        CurrentLeader = client;
        Call_StartForward(FwdLeader);
        Call_PushCell(CurrentLeader);
        Call_PushCell(newLevel);
        Call_PushCell(WeaponOrderCount);
        Call_Finish();
        UTIL_PlaySoundForLeaderLevel();
        return;
    }
    if ( CurrentLeader == client )
    {
        // still leading
        UTIL_PlaySoundForLeaderLevel();
        return;
    }
    // CurrentLeader != client
    if ( newLevel < PlayerLevel[CurrentLeader] )
    {
        // not leading
        return;
    }
    if ( newLevel > PlayerLevel[CurrentLeader] )
    {
        CurrentLeader = client;
        Call_StartForward(FwdLeader);
        Call_PushCell(CurrentLeader);
        Call_PushCell(newLevel);
        Call_PushCell(WeaponOrderCount);
        Call_Finish();
        // start leading
        UTIL_PlaySoundForLeaderLevel();
        return;
    }
    // new level == leader level
    // tied to the lead
    UTIL_PlaySoundForLeaderLevel();
}

UTIL_PlaySoundForLeaderLevel() {
    if (!CurrentLeader) {
        return;
    }
    new WeapLevelId = g_WeaponLevelIndex[WeaponOrderId[PlayerLevel[CurrentLeader]]];
    if (WeapLevelId == g_WeaponLevelIdHegrenade) {
        UTIL_PlaySound(0, Nade);
        return;
    }
    if (WeapLevelId == g_WeaponLevelIdKnife) {
        UTIL_PlaySound(0, Knife);
        return;
    }
}

UTIL_ChangeLevel(client, difference, bool:KnifeSteal = false, victim = 0)
{
    if ( !difference || !IsActive || WarmupEnabled || GameWinner )
    {
        return PlayerLevel[client];
    }
    
    new oldLevel = PlayerLevel[client], Level = oldLevel + difference;

    if ( Level < 0 ) {
        Level = 0;
    } else if ( Level > WeaponOrderCount ) {
        Level = WeaponOrderCount;
    }

    new ret;

    Call_StartForward(FwdLevelChange);
    Call_PushCell(client);
    Call_PushCell(Level);
    Call_PushCell(difference);
    Call_PushCell(KnifeSteal);
    Call_PushCell(Level == (WeaponOrderCount - 1));
    Call_PushCell(g_WeaponLevelIndex[WeaponOrderId[Level]] == g_WeaponLevelIdKnife);
    Call_Finish(ret);

    if ( ret )
    {
        return PlayerLevel[client] = oldLevel;
    }

    if ( !BotCanWin && IsFakeClient(client) && (Level >= WeaponOrderCount) )
    {
        /* Bot can't win so just keep them at the last level */
        return oldLevel;
    }

    // Client got new level
    PlayerLevel[client] = Level;
    if ( KnifeSteal && g_Cfg_KnifeProRecalcPoints && (oldLevel != Level) ) {
        CurrentKillsPerWeap[client] = CurrentKillsPerWeap[client] * UTIL_GetCustomKillPerLevel(Level) / UTIL_GetCustomKillPerLevel(oldLevel);
    } else {
        CurrentKillsPerWeap[client] = 0;
    }
    
    if ( difference < 0 )
    {
        UTIL_PlaySound(client, Down);
    }
    else 
    {
        if ( KnifeSteal )
        {
            UTIL_PlaySound(client, Steal);
        }
        else
        {
            UTIL_PlaySound(client, Up);
        }
    }

    if ( !IsVotingCalled && Level >= WeaponOrderCount - VoteLevelLessWeaponCount )
    {
        IsVotingCalled = true;
        Call_StartForward(FwdVoteStart);
        Call_Finish();
    }

    if ( g_cfgDisableRtvLevel && !g_isCalledDisableRtv && Level >= g_cfgDisableRtvLevel )
    {
        g_isCalledDisableRtv = true;
        Call_StartForward(FwdDisableRtv);
        Call_Finish();
    }
    
    if ( g_cfgEnableFriendlyFireLevel && !g_isCalledEnableFriendlyFire && Level >= g_cfgEnableFriendlyFireLevel )
    {
        g_isCalledEnableFriendlyFire = true;
        if ( g_cfgFriendlyFireOnOff ) {
            UTIL_ChangeFriendlyFire(true);
        } else {
            UTIL_ChangeFriendlyFire(false);
        }
    }
    
    /* WeaponOrder count is the last weapon. */
    if ( Level >= WeaponOrderCount )
    {
        /* Winner Winner Winner. They won the prize of gaben plus a hat. */
        decl String:Name[MAX_NAME_SIZE];
        GetClientName(client, Name, sizeof(Name));

        new team = GetClientTeam(client);
        new r = (team == TEAM_T ? 255 : 0);
        new g =  team == TEAM_CT ? 128 : (team == TEAM_T ? 0 : 255);
        new b = (team == TEAM_CT ? 255 : 0);
        UTIL_PrintToUpperLeft(r, g, b, "%t", "Has won", Name);

        Call_StartForward(FwdWinner);
        Call_PushCell(client);
        Call_PushString(WeaponOrderName[Level - 1]);
        Call_PushCell(victim);
        Call_Finish();

        GameWinner = client;

        if (g_Cfg_WinnerFreezePlayers) {
            UTIL_FreezeAllPlayers();
        }
        UTIL_EndMultiplayerGameDelayed();

        new result;
        Call_StartForward(FwdSoundWinner);
        Call_PushCell(client);
        Call_Finish(result);

        if ( !result ) {
            UTIL_PlaySound(0, Winner);
        }

        if ( AlltalkOnWin )
        {
            new Handle:sv_alltalk = FindConVar("sv_alltalk");
            if ( sv_alltalk != INVALID_HANDLE )
            {
                SetConVarInt(sv_alltalk,1);
            }
        }
        PlayerLevel[client] = oldLevel;
        return oldLevel;
    }
    UTIL_RecalculateLeader(client, oldLevel, Level);
    UTIL_UpdatePlayerScoreLevel(client);

    return Level;
}

UTIL_FreezeAllPlayers() {
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            UTIL_FreezePlayer(i);
        }
    }
}

UTIL_FreezePlayer(client) {
    SetEntityMoveType(client, MOVETYPE_NONE);
}

/**
 * Force drop C4.
 *
 * @param   int client - Player index.
 * @return  void
 */
UTIL_ForceDropC4(client) {
    new ent = GetPlayerWeaponSlot(client, _:Slot_C4);
    if (ent > 0) {
        CS_DropWeapon(client, ent, false, true);
        UTIL_Remove(ent);
    }
}

UTIL_FindAndRemoveSlotKnife(client) {
    // Remove taser and knife
    for (new j = 0, ent2; j < 2; j++) {
        ent2 = GetPlayerWeaponSlot(client, _:Slot_Knife);
        if (ent2 < 1) {
            break;
        }

        RemovePlayerItem(client, ent2);
        RemoveEdict(ent2);
    }
}

UTIL_FindTaser(client) {
    // Find taser
    for (new j = 0, ent2; j < 128; j += 4) {
        ent2 = GetEntDataEnt2(client, m_hMyWeapons + j);
        if (ent2 <= MaxClients) {
            continue;
        }
        if (UTIL_IsWeaponTaser(ent2)) {
            return ent2;
        }
    }
    return -1;
}

UTIL_IsWeaponTaser(weapon) {
    return g_WeaponAmmoTypeTaser == GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
}

/**
 * @param client        Player index
 * @param DropKnife        Allow knife drop
 * @noreturn
 */
UTIL_ForceDropAllWeapon(client, bool:dropKnife) {
    for (new Slots:i = Slot_Primary, ent; i < Slot_None; i++) {
        if (i == Slot_Grenade) {
            UTIL_DropAllGrenades(client);
            continue;
        } else if (i == Slot_Knife) {
            if (g_GameName == GameName:Csgo) {
                if (dropKnife) {
                    UTIL_FindAndRemoveSlotKnife(client);
                } else {
                    ent = UTIL_FindTaser(client);
                    if (ent != -1) {
                        RemovePlayerItem(client, ent);
                        RemoveEdict(ent);
                    }
                }
                continue;
            } else {
                if (!dropKnife) {
                    continue;
                }
            }
        } else if (i == Slot_C4) {
            if (MapStatus & OBJECTIVE_BOMB && MapStatus & OBJECTIVE_REMOVE_BOMB) {
                UTIL_ForceDropC4(client);
            }
            continue;
        }

        ent = GetPlayerWeaponSlot(client, _:i);
        if (ent > 0) {
            RemovePlayerItem(client, ent);
            RemoveEdict(ent);
        }
    }
}

/**
 * Drop/remove all grenades.
 *
 * @client        Player index
 * @remove        Remove grenade on drop
 * @noreturn
 */
UTIL_DropAllGrenades(client) {
    for (new i = 0, ent; i < 5; i++) {
        ent = GetPlayerWeaponSlot(client, _:Slot_Grenade);
        if (ent < 1) {
            break;
        }

        RemovePlayerItem(client, ent);
        RemoveEdict(ent);
    }
}

/**
 *
 * @param client    Player client
 * @param Grenade    Grenade weapon name. ie weapon_hegrenade
 * @param drop        Drop the grenade
 * @param remove    Removes the weapon from the world
 *
 * @return        -1 if not found or you drop the grenade otherwise will return the Entity index.
 */
stock UTIL_FindGrenadeByName(client, const String:Grenade[], bool:drop = false, bool:remove = false) {
    decl String:Class[64];

    for (new i = 0, ent, type; i < 128; i += 4) {
        ent = GetEntDataEnt2(client, m_hMyWeapons + i);
        if (ent <= MaxClients) {
            continue;
        }
        type = UTIL_WeaponGetGrenadeType(ent);
        if (!UTIL_WeaponTypeIsGrenade(type)) {
            continue;
        }

        GetEdictClassname(ent, Class, sizeof(Class));
        if (strcmp(Class, Grenade, false) == 0) {
            if (drop) {
                if (remove) {
                    RemovePlayerItem(client, ent);
                    RemoveEdict(ent);
                    return -2;
                } else {
                    CS_DropWeapon(client, ent, false, true);
                }
            }

            return ent;
        }

    }

    return -1;
}

/**
 *
 * @param client    Player client
 * @param Grenade    Grenade weapon ammo type. ie 11
 * @param drop        Drop the grenade
 * @param remove    Removes the weapon from the world
 *
 * @return        -1 if not found or you drop the grenade otherwise will return the Entity index.
 */
stock UTIL_FindGrenadeByAmmoType(client, Grenade, bool:drop = false, bool:remove = false) {
    for (new i = 0, ent; i < 128; i += 4) {
        ent = GetEntDataEnt2(client, m_hMyWeapons + i);
        if (ent <= MaxClients) {
            continue;
        }
        if (Grenade == UTIL_WeaponGetGrenadeType(ent)) {
            if (drop) {
                if (remove) {
                    RemovePlayerItem(client, ent);
                    RemoveEdict(ent);
                    return -2;
                } else {
                    CS_DropWeapon(client, ent, false, true);
                }
            }

            return ent;
        }

    }

    return -1;
}

UTIL_CheckForFriendlyFire(client, WeapId)
{
    if ( !AutoFriendlyFire )
    {
        return;
    }
    new pState = PlayerState[client];
    if ( (pState & GRENADE_LEVEL) && (g_WeaponLevelIndex[WeapId] != g_WeaponLevelIdHegrenade) )
    {
        PlayerState[client] &= ~GRENADE_LEVEL;

        if ( --PlayerOnGrenade < 1 )
        {
            if ( g_cfgFriendlyFireOnOff ) {
                UTIL_ChangeFriendlyFire(false);
            } else {
                UTIL_ChangeFriendlyFire(true);
            }
        }
        return;
    }
    if ( !(pState & GRENADE_LEVEL) && (g_WeaponLevelIndex[WeapId] == g_WeaponLevelIdHegrenade) )
    {
        PlayerOnGrenade++;
        PlayerState[client] |= GRENADE_LEVEL;
            
        if ( !GetConVarInt(mp_friendlyfire) )
        {
            if ( g_cfgFriendlyFireOnOff ) {
                UTIL_ChangeFriendlyFire(true);
            } else {
                UTIL_ChangeFriendlyFire(false);
            }
        }
        return;
    }
}

UTIL_GiveNextWeapon(client, level, bool:levelupWithKnife = false, Float:delay = 0.1, bool:spawn = false) {
    new Handle:data = CreateDataPack();
    WritePackCell(data, client);
    WritePackCell(data, level);
    WritePackCell(data, _:levelupWithKnife);
    WritePackCell(data, _:spawn);
       
    CreateTimer(delay, UTIL_Timer_GiveNextWeapon, data);
}

public Action:UTIL_Timer_GiveNextWeapon(Handle:timer, Handle:data) {
    new client, level, bool:levelupWithKnife, bool:spawn;

    ResetPack(data);
    client = ReadPackCell(data);
    level = ReadPackCell(data);
    levelupWithKnife = bool:ReadPackCell(data);
    spawn = bool:ReadPackCell(data);
    CloseHandle(data);

    if ( !IsClientInGame(client) || !IsPlayerAlive(client) ) {
        return;
    }

    UTIL_GiveNextWeaponReal(client, level, levelupWithKnife, spawn);
}

UTIL_GiveNextWeaponReal(client, level, bool:levelupWithKnife, bool:spawn) {
    new WeapId = WeaponOrderId[level], Slots:slot = g_WeaponSlot[WeapId], WeapLevelId = g_WeaponLevelIndex[WeapId];
    new bool:dropKnife = g_WeaponDropKnife[WeapId];
    new bool:blockSwitch = g_SdkHooksEnabled && g_Cfg_BlockWeaponSwitchIfKnife && levelupWithKnife && !dropKnife;
    new newWeapon = 0;

    #if defined GUNGAME_DEBUG
        LogError("[DEBUG-GUNGAME] UTIL GIVE_WEAPON weaponName=%s weaponId=%d slotId=%d clientId=%d levelId=%d", g_WeaponName[WeapId], WeapId, slot, client, level);
    #endif

    // A check to make sure player always has a knife 
    // because some maps do not give the knife.

    if (blockSwitch) {
        g_BlockSwitch[client] = true;
    }

    UTIL_CheckForFriendlyFire(client, WeapId);

    UTIL_ForceDropAllWeapon(client, dropKnife);
    if (!dropKnife && spawn && (GetPlayerWeaponSlot(client, _:Slot_Knife) == -1)) {
        GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdKnife]);
    }

    if (PlayerState[client] & KNIFE_ELITE) { // FIXME: when do we call UTIL_GiveNextWeapon with KNIFE_ELITE flag set in PlayerState?
        if (blockSwitch) {
            g_BlockSwitch[client] = false;
        } else {
            FakeClientCommand(client, "use %s", g_WeaponName[g_WeaponIdKnife]);
        }
        return;
    }

    if (slot == Slot_Grenade) {
        if (WeapLevelId == g_WeaponLevelIdHegrenade) {
            // BONUS WEAPONS FOR HEGRENADE
            if (NumberOfNades) {
                g_NumberOfNades[client] = NumberOfNades - 1;
            }
            if (NadeBonusWeaponId) {
                new ent = GivePlayerItemWrapper(client, g_WeaponName[NadeBonusWeaponId]);
                // Remove bonus weapon ammo! So player can not reload weapon!
                if ( (ent != -1) && RemoveBonusWeaponAmmo ) {
                    new iAmmo = UTIL_GetAmmoType(ent); // TODO: not needed
    
                    if ((iAmmo != -1) && (ent != INVALID_ENT_REFERENCE)) {
                        new Handle:Info = CreateDataPack();
                        WritePackCell(Info, client);
                        WritePackCell(Info, ent);
                        ResetPack(Info);
    
                        CreateTimer(0.1, UTIL_DelayAmmoRemove, Info, TIMER_HNDL_CLOSE);
                    }
                }
            }
            if (NadeSmoke) {
                GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdSmokegrenade], !g_BlockSwitch[client]);
            }
            if (NadeFlash) {
                GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdFlashbang], !g_BlockSwitch[client]);
            }
        } else if (WeapLevelId == g_WeaponLevelIdMolotov) {
            // BONUS WEAPONS FOR MOLOTOV
            if (g_Cfg_MolotovBonusWeaponId) {
                new ent = GivePlayerItemWrapper(client, g_WeaponName[g_Cfg_MolotovBonusWeaponId]);
                // Remove bonus weapon ammo! So player can not reload weapon!
                if ( (ent != -1) && RemoveBonusWeaponAmmo ) {
                    new iAmmo = UTIL_GetAmmoType(ent); // TODO: not needed
    
                    if ((iAmmo != -1) && (ent != INVALID_ENT_REFERENCE)) {
                        new Handle:Info = CreateDataPack();
                        WritePackCell(Info, client);
                        WritePackCell(Info, ent);
                        ResetPack(Info);
    
                        CreateTimer(0.1, UTIL_DelayAmmoRemove, Info, TIMER_HNDL_CLOSE);
                    }
                }
            }
            if (g_Cfg_MolotovBonusSmoke) {
                GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdSmokegrenade], !g_BlockSwitch[client]);
            }
            if (g_Cfg_MolotovBonusFlash) {
                GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdFlashbang], !g_BlockSwitch[client]);
            }
        }
    }

    if (slot == Slot_Knife) {
        if (WeapLevelId == g_WeaponLevelIdKnife) {
            // BONUS WEAPONS FOR KNIFE
            if (g_Cfg_KnifeSmoke) {
                GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdSmokegrenade], !g_BlockSwitch[client]);
            }
            if (g_Cfg_KnifeFlash) {
                GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdFlashbang], !g_BlockSwitch[client]);
            }
            if (dropKnife) {
                // LEVEL WEAPON KNIFEGG
                newWeapon = GivePlayerItemWrapper(client, g_WeaponName[WeapId]);
            }
        } else {
            // LEVEL WEAPON TASER
            // this is, for example, TASER (csgo)
            newWeapon = GivePlayerItemWrapper(client, g_WeaponName[WeapId]);
        }
    } else {
        // LEVEL WEAPON PRIMARY/SECONDARY
        /* Give new weapon */
        newWeapon = GivePlayerItemWrapper(client, g_WeaponName[WeapId]);
    }

    if (blockSwitch) {
        g_BlockSwitch[client] = false;
    } else {
        UTIL_UseWeapon(client, WeapId);
        UTIL_FastSwitchWithCheck(client, newWeapon, true, WeapId);
    }
}

/**
 * This function was created because of the dynamic pricing that was updated in the
 * recent Source update. They are giving full ammo no matter if mp_dynamicpricing was 0 or 1.
 * So I had to delay reseting the hegrenade with glock to 50 bullets by 0.2
 */
public Action:UTIL_DelayAmmoRemove(Handle:timer, Handle:data) {
    new client = ReadPackCell(data);
    new weapon = ReadPackCell(data);

    if (IsClientInGame(client)) {
        UTIL_RemoveAmmo(client, weapon);
    }
}

UTIL_PlaySoundDelayed(Float:delay, client, Sounds:type, entity = SOUND_FROM_PLAYER, bool:stop = false) {
    new Handle:data = CreateDataPack();
    WritePackCell(data, client);
    WritePackCell(data, _:type);
    WritePackCell(data, entity);
    WritePackCell(data, _:stop);
       
    CreateTimer(delay, UTIL_Timer_PlaySound, data);
}

public Action:UTIL_Timer_PlaySound(Handle:timer, Handle:data) {
    new client, Sounds:type, entity, bool:stop;

    ResetPack(data);
    client = ReadPackCell(data);
    type = Sounds:ReadPackCell(data);
    entity = ReadPackCell(data);
    stop = bool:ReadPackCell(data);
    CloseHandle(data);

    if ( !IsClientInGame(client) || !IsPlayerAlive(client) ) {
        return;
    }

    UTIL_PlaySound(client, type, entity, stop);
}

/*
stock EmitSoundToAll(const String:sample[], 
                 entity = SOUND_FROM_PLAYER, 
                 channel = SNDCHAN_AUTO, 
                 level = SNDLEVEL_NORMAL, 
                 flags = SND_NOFLAGS, 
                 Float:volume = SNDVOL_NORMAL, 
                 pitch = SNDPITCH_NORMAL, 
                 speakerentity = -1, 
                 const Float:origin[3] = NULL_VECTOR, 
                 const Float:dir[3] = NULL_VECTOR, 
                 bool:updatePos = true, 
                 Float:soundtime = 0.0)
*/
/**
 * Play gungame sound.
 *
 * @param   int     client  - Emit sound to. 0=play to all, int=play to that client id.
 * @param   Sounds  type    - Type of the sounds (enum Sounds).
 * @param   int     entity  - Emit sound from. Entity, that emits sound.
 * @param   bool    stop    - Stop that sound.
 * @return void
 */
UTIL_PlaySound(client, Sounds:type, entity = SOUND_FROM_PLAYER, bool:stop = false) {
    if (!EventSounds[type][0]) {
        return;
    }
    if (client && (!IsClientInGame(client) || IsFakeClient(client))) {
        return;
    }

    new flags = SND_NOFLAGS;
    if (stop) {
        flags |= SND_STOPLOOPING;
    }

    if (g_Cfg_MultiplySoundVolume < 1) {
        g_Cfg_MultiplySoundVolume = 1;
    }
    if (g_Cfg_MultiplySoundVolume > 5) {
        g_Cfg_MultiplySoundVolume = 5;
    }

    for (new i=0; i<g_Cfg_MultiplySoundVolume; i++) {
        if (!client) {
            EmitSoundToAll(EventSounds[type], entity, _, SNDLEVEL_RAIDSIREN, flags);
        } else {
            EmitSoundToClient(client, EventSounds[type], entity, _, SNDLEVEL_RAIDSIREN, flags);
        }
    }
}

UTIL_DisableBuyZones() {
    new index = -1;
    while ( (index = FindEntityByClassname(index, "func_buyzone")) > 0) {
        AcceptEntityInput(index, "Disable");
    }
}

UTIL_EnableBuyZones() {
    new index = -1;
    while ( (index = FindEntityByClassname(index, "func_buyzone")) > 0) {
        AcceptEntityInput(index, "Enable");
    }
}

UTIL_ReloadActiveWeapon(client, WeaponId) {
    new Slots:slot = g_WeaponSlot[WeaponId];
    if ((slot == Slot_Primary )
        || (slot == Slot_Secondary)
        || (g_WeaponLevelIndex[WeaponId] == g_WeaponLevelIdTaser)
    ) {
        new ent = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if ((ent > -1) && g_WeaponAmmo[WeaponId]) {
            SetEntProp(ent, Prop_Send, "m_iClip1", g_WeaponAmmo[WeaponId] + (g_GameName==GameName:Csgo?1:0)); // "+1" is needed because ammo is refilling before last shot is counted
        }
    }
}

GivePlayerItemWrapper(client, const String:item[], bool:blockSwitch = false) {
    #if defined GUNGAME_DEBUG
        LogError("[DEBUG-GUNGAME] FUNC GivePlayerItemWrapper, client=%i item=%s", client, item);
    #endif

    g_BlockFastSwitchOnChange[client] = true;
    if (blockSwitch) {
        g_BlockSwitch[client] = true;
    }

    new ent = GivePlayerItem(client, item);
    #if defined GUNGAME_DEBUG
        LogError("[DEBUG-GUNGAME] ... offset, client=%i item=%s ammotypesend=%i ammotypedata=%i", 
            client, 
            item, 
            GetEntProp(ent, Prop_Send, "m_iPrimaryAmmoType"), 
            GetEntData(ent, g_iOffs_iPrimaryAmmoType, 1)
        );
    #endif

    if (blockSwitch) {
        g_BlockSwitch[client] = false;
    }
    g_BlockFastSwitchOnChange[client] = false;

    return ent;
}

UTIL_StartTripleEffects(client)
{
    if ( g_tripleEffects[client] ) {
        return;
    }
    g_tripleEffects[client] = 1;
    if ( TripleLevelBonusGodMode ) {
        UTIL_SetClientGodMode(client, 1);
    }
    if ( g_Cfg_TripleLevelBonusGravity ) {
        SetEntityGravity(client, g_Cfg_TripleLevelBonusGravity);
    }
    if ( g_Cfg_TripleLevelBonusSpeed ) {
        SetEntDataFloat(client, OffsetMovement, g_Cfg_TripleLevelBonusSpeed);
    }
    UTIL_PlaySound(0, Triple, client);
    if ( g_Cfg_TripleLevelEffect ) {
        UTIL_StartEffectClient(client);
    }
}

UTIL_StopBonusGravity(client) {
    if ( !g_tripleEffects[client] ) {
        return;
    }
    if ( g_Cfg_TripleLevelBonusGravity ) {
        SetEntityGravity(client, 1.0);
    }
}

UTIL_StopTripleEffects(client)
{
    if ( !g_tripleEffects[client] ) {
        return;
    }
    g_tripleEffects[client] = 0;
    if ( TripleLevelBonusGodMode ) {
        UTIL_SetClientGodMode(client, 0);
    }
    if ( g_Cfg_TripleLevelBonusGravity ) {
        SetEntityGravity(client, 1.0);
    }
    if ( g_Cfg_TripleLevelBonusSpeed ) {
        SetEntDataFloat(client, OffsetMovement, 1.0);
    }
    UTIL_PlaySound(0, Triple, client, true);
    if ( g_Cfg_TripleLevelEffect ) {
        UTIL_StopEffectClient(client);
    }
}

/**
 * Return current leader client.
 *
 * Return 0 if no leaders found.
 *
 * @param bool DisallowBot
 * @return int
 */
FindLeader(bool:DisallowBot = false)
{
    new leaderId      = 0;
    new leaderLevel   = 0;
    new currentLevel  = 0;

    for (new i = 1; i <= MaxClients; i++)
    {
        if ( DisallowBot && IsClientInGame(i) && IsFakeClient(i) )
        {
            continue;
        }

        currentLevel = PlayerLevel[i];

        if ( currentLevel > leaderLevel )
        {
            leaderLevel = currentLevel;
            leaderId = i;
        }
    }

    return leaderId;
}

CheckForTripleLevel(client)
{
    CurrentLevelPerRoundTriple[client]++;
    if ( TripleLevelBonus && CurrentLevelPerRoundTriple[client] == g_Cfg_MultiLevelAmount )
    {
        decl String:Name[MAX_NAME_SIZE];
        GetClientName(client, Name, sizeof(Name));

        decl String:subtext[64];
        for ( new i = 1; i <= MaxClients; i++ )
        {
            if ( IsClientInGame(i) )
            {
                SetGlobalTransTarget(i);
                FormatLanguageNumberTextEx(i, subtext, sizeof(subtext), g_Cfg_MultiLevelAmount, "leveled times");
                CPrintToChatEx(i, client, "%t", "Player has leveled many times", Name, subtext);
            }
        }

        UTIL_StartTripleEffects(client);
        CreateTimer(10.0, RemoveBonus, client);

        Call_StartForward(FwdTripleLevel);
        Call_PushCell(client);
        Call_Finish();
    }
}

public Action:RemoveBonus(Handle:timer, any:client)
{
    CurrentLevelPerRoundTriple[client] = 0;
    if ( IsClientInGame(client) )
    {
        UTIL_StopTripleEffects(client);
    }
}

/**
 * Stocks
 */

stock UTIL_StringToLower(String:Source[])
{
    new len = strlen(Source);

    for(new i = 0; i <= len; i++)
    {
        if(IsCharUpper(Source[i]))
        {
            Source[i] |= (1<<5);
        }
    }

    return 1;
}

stock UTIL_StringToUpper(String:Source[])
{
    new len = strlen(Source);

    /* Should this be i <= len */
    for(new i = 0; i <= len; i++)
    {
        if(IsCharLower(Source[i]))
        {
            Source[i] &= ~(1<<5);
        }
    }

    return 1;
}

UTIL_GiveWarmUpWeaponDelayed(Float:delay, client) {
    new Handle:data = CreateDataPack();
    WritePackCell(data, client);
       
    CreateTimer(delay, UTIL_Timer_GiveWarmUpWeapon, data);
}

public Action:UTIL_Timer_GiveWarmUpWeapon(Handle:timer, Handle:data) {
    new client;

    ResetPack(data);
    client = ReadPackCell(data);
    CloseHandle(data);

    if (!IsClientInGame(client) || !IsPlayerAlive(client)) {
        return;
    }

    UTIL_GiveWarmUpWeapon(client);
}

UTIL_GiveWarmUpWeapon(client) {
    UTIL_ForceDropAllWeapon(client, false);

    if (WarmupRandomWeaponMode) {   
        if (WarmupRandomWeaponMode == 1 || WarmupRandomWeaponMode == 2) {
            if (WarmupRandomWeaponLevel == -1) {
                WarmupRandomWeaponLevel = UTIL_GetRandomInt(0, WeaponOrderCount-1);
            }
            UTIL_GiveNextWeapon(client, WarmupRandomWeaponLevel);
        } else if (WarmupRandomWeaponMode == 3) {
            UTIL_GiveNextWeapon(client, UTIL_GetRandomInt(0, WeaponOrderCount-1));
        }
        return;
    }

    new bool:nades = bool:WarmupNades;
    new bool:wpn = g_Cfg_WarmupWeapon && !(g_WeaponLevelIndex[g_Cfg_WarmupWeapon] == g_WeaponLevelIdKnife);

    if (nades) {
        GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdHegrenade]);
        if (!wpn) {
            FakeClientCommand(client, "use %s", g_WeaponName[g_WeaponIdHegrenade]);
        }
    }
    if (wpn) {
        GivePlayerItemWrapper(client, g_WeaponName[g_Cfg_WarmupWeapon]);
        FakeClientCommand(client, "use %s", g_WeaponName[g_Cfg_WarmupWeapon]);
    }

    if (!nades && !wpn) {
        FakeClientCommand(client, "use %s", g_WeaponName[g_WeaponIdKnife]);
    }
}

UTIL_GetRandomInt(start, end) {
    new rand;
    // if sourcemod version >= 1.3.0
    rand = GetURandomInt();
    return ( rand % (1 + end - start) ) + start;
}

UTIL_GiveExtraNade(client, bool:knifeKill) {
    /* Give them another grenade if they killed another person with another weapon or hegrenade with the option enabled*/
    #if defined GUNGAME_DEBUG
        LogError("[DEBUG-GUNGAME] FUNC UTIL_GiveExtraNade, g_Cfg_ExtraNade=%i knifeKill=%i", g_Cfg_ExtraNade, knifeKill);
    #endif
    if ( g_Cfg_ExtraNade && ( knifeKill || g_Cfg_ExtraNade == 1 ) ) {
        /* Do not give them another nade if they already have one */
        if (!UTIL_HasClientHegrenade(client)) {
            new bool:blockWeapSwitch = g_SdkHooksEnabled && ( g_Cfg_BlockWeaponSwitchIfKnife && knifeKill || g_Cfg_BlockWeaponSwitchOnNade );
            new newWeapon = GivePlayerItemWrapper(
                client, 
                g_WeaponName[g_WeaponIdHegrenade], 
                blockWeapSwitch
            );
            if (!blockWeapSwitch) {
                UTIL_UseWeapon(client, g_WeaponIdHegrenade);
                UTIL_FastSwitchWithCheck(client, newWeapon, true, g_WeaponIdHegrenade);
            }
        }
    }
}

UTIL_GiveExtraMolotov(client, WeaponId) {
    /* Give them another molotov if they killed another person with another weapon*/
    /* Do not give them another nade if they already have one */
    if (!UTIL_HasClientMolotov(client)) {
        new bool:blockWeapSwitch = g_SdkHooksEnabled && g_Cfg_BlockWeaponSwitchIfKnife;
        new newWeapon = GivePlayerItemWrapper(
            client, 
            g_WeaponName[WeaponId], 
            blockWeapSwitch
        );
        if (!blockWeapSwitch) {
            UTIL_UseWeapon(client, WeaponId);
            UTIL_FastSwitchWithCheck(client, newWeapon, true, WeaponId);
        }
    }
}

UTIL_IsTaserEmpty(weapon) {
    return GetEntProp(weapon, Prop_Send, "m_iClip1") == 0;
}

UTIL_GiveExtraTaser(client) {
    /* Give them another molotov if they killed another person with another weapon*/
    /* Do not give them another nade if they already have one */
    new ent = UTIL_FindTaser(client);
    if (ent != -1) {
        if (UTIL_IsTaserEmpty(ent)) {
            SetEntProp(ent, Prop_Send, "m_iClip1", 1); // taser has only one bullet
        }
        return;
    }

    new bool:blockWeapSwitch = g_SdkHooksEnabled && g_Cfg_BlockWeaponSwitchIfKnife;
    new newWeapon = GivePlayerItemWrapper(
        client, 
        g_WeaponName[g_WeaponIdTaser], 
        blockWeapSwitch
    );
    if (!blockWeapSwitch) {
        UTIL_UseWeapon(client, g_WeaponIdTaser);
        UTIL_FastSwitchWithCheck(client, newWeapon, true, g_WeaponIdTaser);
    }
}

UTIL_SetClientScoreAndDeaths(client, score, deaths = -1) {
    SetEntProp(client, Prop_Data, "m_iFrags", score);
    if ( deaths >= 0 ) {
        SetEntProp(client, Prop_Data, "m_iDeaths", deaths);
    }
}

UTIL_UpdatePlayerScoreLevel(client)
{
    if ( WarmupEnabled && !DisableWarmupOnRoundEnd )
    {
        return;
    }
    if ( g_Cfg_LevelsInScoreboard && client && IsClientInGame(client) )
    {
        UTIL_SetClientScoreAndDeaths(client, PlayerLevel[client] + 1, g_Cfg_ScoreboardClearDeaths? 0: -1);
    }
}

UTIL_UpdatePlayerScoreDelayed(client)
{
    if ( g_Cfg_LevelsInScoreboard && client && IsClientInGame(client) )
    {
        CreateTimer(0.1, UTIL_Timer_UpdatePlayerScore, client);
    }
}

public Action:UTIL_Timer_UpdatePlayerScore(Handle:timer, any:client)
{
    UTIL_UpdatePlayerScoreLevel(client);
}

UTIL_ShowHintTextMulti(client, const String:textHint[], times, Float:time)
{
    if ( IsFakeClient(client) )
    {
        return;
    }
    
    new Handle:data = CreateDataPack();
    WritePackCell(data, times);
    WritePackCell(data, client);
    WritePackString(data, textHint);
    
    new Handle:timer = CreateTimer(time, UTIL_Timer_ShowHintText, data, TIMER_REPEAT);
    CreateTimer(0.1, UTIL_Timer_ShowHintTextFirst, timer);
}

public Action:UTIL_Timer_ShowHintTextFirst(Handle:timer, any:data)
{
    TriggerTimer(data);
}

public Action:UTIL_Timer_ShowHintText(Handle:timer, any:data)
{
    new client, String:textHint[512], times;
    
    ResetPack(data);
    times = ReadPackCell(data);
    client = ReadPackCell(data);
    ReadPackString(data, textHint, sizeof(textHint));
    
    if ( !IsClientInGame(client) )
    {
        CloseHandle(data);
        return Plugin_Stop;
    }
    
    PrintHintText(client, textHint);
    if ( --times <= 0 )
    {
        CloseHandle(data);
        return Plugin_Stop;
    }
    else
    {
        SetPackPosition(data, DataPackPos:0);
        WritePackCell(data, times);
        return Plugin_Continue;
    }
}

UTIL_ArrayIntRand(array[], size)
{
    if ( size < 2 )
    {
        return;
    }
    new tmpIndex, tmpValue;
    for ( new i = 0; i < size-1; i++ )
    {
        tmpIndex = UTIL_GetRandomInt(i, size-1);
        if ( tmpIndex == i )
        {
            continue;
        }
        tmpValue = array[tmpIndex];
        
        array[tmpIndex] = array[i];
        array[i] = tmpValue;
    }
}

UTIL_GetCustomKillPerLevel(level)
{
    new killsPerLevel = CustomKillPerLevel[level];
    return killsPerLevel ? killsPerLevel : MinKillsPerLevel;
}

UTIL_GetHandicapLevel(skipClient = 0, aboveLevel = -1)
{
    new level;
    if ( HandicapMode == 1 ) {
        level = UTIL_GetAverageLevel(g_Cfg_HandicapSkipBots, aboveLevel, skipClient);
    } else if ( HandicapMode == 2 ) {
        level = UTIL_GetMinimumLevel(g_Cfg_HandicapSkipBots, aboveLevel, skipClient);
    }
    if ( level == -1 ) {
        return 0;
    }
    level -= g_Cfg_HandicapLevelSubstract;
    if ( g_Cfg_MaxHandicapLevel && g_Cfg_MaxHandicapLevel < level ) {
        level = g_Cfg_MaxHandicapLevel;
    }
    if ( level < 1 ) {
        return 0;
    }
    return level;
}

UTIL_GetMinimumLevel(bool:skipBots = false, aboveLevel = -1, skipClient = 0)
{
    new minimum = -1;
    new level = 0;
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientInGame(i) && ( g_Cfg_HandicapUseSpectators || GetClientTeam(i) > 1 ) )
        {
            if ( ( skipBots && IsFakeClient(i) ) 
                || ( GetClientTeam(i) < 2 )
                || ( skipClient == i ) )
            {
                continue;
            }
            level = PlayerLevel[i];
            if ( aboveLevel >= level ) {
                continue;
            }
            if ( (minimum == -1) || (level < minimum) )
            {                 
                minimum = level;
            }
        }
    }
    return minimum;
}

UTIL_GetAverageLevel(bool:skipBots = false, aboveLevel = -1, skipClient = 0)
{
    new count, level, tmpLevel;
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientInGame(i) && ( g_Cfg_HandicapUseSpectators || GetClientTeam(i) > 1 ) )
        {
            if ( ( skipBots && IsFakeClient(i) ) 
                || ( GetClientTeam(i) < 2 )
                || ( skipClient == i ) )
            {
                continue;
            }
            tmpLevel = PlayerLevel[i];
            if ( aboveLevel >= tmpLevel ) {
                continue;
            }
            level += tmpLevel;
            count++;
        }
    }
    if ( !count ) {
        return -1;
    }
    level /= count;
    return level;
}

bool:UTIL_SetHandicapForClient(client)
{
    if ( g_Cfg_HandicapTimesPerMap )
    {
        decl String:auth[64];
        GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));

        new times = 0;
        if ( !GetTrieValue(PlayerHandicapTimes, auth, times) ) {
            times = 0;
        }

        if ( times >= g_Cfg_HandicapTimesPerMap ) {
            return false;
        }

        times++;
        SetTrieValue(PlayerHandicapTimes, auth, times);
    }
    
    return bool:GG_GiveHandicapLevel(client);
}

UTIL_GetAmmoType(weapon) {
    return GetEntData(weapon, g_iOffs_iPrimaryAmmoType, 1);
}

UTIL_StartEffectClient(client) {
    if ( g_Ent_Effect[client]  > -1 ) {
        return 0;
    }
    g_Ent_Effect[client] = UTIL_CreateEffect(client);
    return 1;
}


UTIL_StopMultilevelEffect1(client) {
    RemoveEdict(g_Ent_Effect[client]);
}

UTIL_StopMultilevelEffect2(client) {
    AcceptEntityInput( g_Ent_Effect[client], "TurnOff" );
    AcceptEntityInput( g_Ent_Effect[client], "Kill" );
}

UTIL_StopEffectClient(client) {
    if ( g_Ent_Effect[client] < 0 ) {
        return;
    }
    if ( IsValidEdict(g_Ent_Effect[client]) ) {
        if ( g_Cfg_MultilevelEffectType == 1 ) {
            UTIL_StopMultilevelEffect1(client);
        } else {
            UTIL_StopMultilevelEffect2(client);
        }
    }
    g_Ent_Effect[client] = -1;
}

UTIL_CreateMultilevelEffect1(client) {
    new ent = CreateEntityByName("env_spritetrail");
    new String:target[32];
    Format(target, sizeof(target), "target%i", client);
     
    DispatchKeyValue(client, "targetname", target);
    DispatchKeyValue(ent, "parentname", target);
    DispatchKeyValue(ent, "lifetime", "1.0");
    DispatchKeyValue(ent, "endwidth", "1.0");
    DispatchKeyValue(ent, "startwidth", "20.0");
    //DispatchKeyValue(ent, "spritename", "materials/sprites/bluelaser1.vmt");
    DispatchKeyValue(ent, "spritename", "materials/sprites/crystal_beam1.vmt");
    DispatchKeyValue(ent, "renderamt", "255");
    //DispatchKeyValue(ent, "rendercolor", "0 128 255");
    DispatchKeyValue(ent, "rendercolor", "255 128 0");
    DispatchKeyValue(ent, "rendermode", "5");
    
    DispatchSpawn(ent);
    
    new Float:Client_Origin[3];
    GetClientAbsOrigin(client,Client_Origin);
    Client_Origin[2] += 20.0; //Beam clips into the floor without this
    TeleportEntity(ent, Client_Origin, NULL_VECTOR, NULL_VECTOR);
    
    SetVariantString(target);
    AcceptEntityInput(ent, "SetParent");
    return ent;
}

UTIL_CreateMultilevelEffect2(client) {
    new particle = CreateEntityByName("env_smokestack");
    if ( !IsValidEdict(particle) ) {
        LogError( "Failed to create env_smokestack (%i) for client %i!", particle, client );
        return -1;
    }

    decl String:Name[32], Float:fPos[3], Float:fAng[3] = { 0.0, 0.0, 0.0 };
    Format( Name, sizeof( Name ), "CSParticle_%i", client );
    GetEntPropVector( client, Prop_Send, "m_vecOrigin", fPos );
    fPos[2] += 28;

    //Set Key Values
    DispatchKeyValueVector( particle, "Origin", fPos );
    DispatchKeyValueVector( particle, "Angles", fAng );
    DispatchKeyValueFloat( particle, "BaseSpread", 15.0 );
    DispatchKeyValueFloat( particle, "StartSize", 2.0 );
    DispatchKeyValueFloat( particle, "EndSize", 6.0 );
    DispatchKeyValueFloat( particle, "Twist", 0.0 );
    
    DispatchKeyValue( particle, "Name", Name );
    DispatchKeyValue( particle, "SmokeMaterial", MULTI_LEVEL_EFFECT2 );
    DispatchKeyValue( particle, "RenderColor", "252 232 131" );
    DispatchKeyValue( particle, "SpreadSpeed", "10" );
    DispatchKeyValue( particle, "RenderAmt", "200" );
    DispatchKeyValue( particle, "JetLength", "13" );
    DispatchKeyValue( particle, "RenderMode", "0" );
    DispatchKeyValue( particle, "Initial", "0" );
    DispatchKeyValue( particle, "Speed", "10" );
    DispatchKeyValue( particle, "Rate", "173" );
    DispatchSpawn( particle );

    //Set Entity Inputs
    SetVariantString( "!activator" );
    AcceptEntityInput( particle, "SetParent", client, particle, 0 );
    AcceptEntityInput( particle, "TurnOn" );
    return particle;
}

UTIL_CreateEffect(client) {
    if ( !IsClientInGame( client ) ) {
        return -1;
    }

    if ( g_Cfg_MultilevelEffectType == 1 ) {
        return UTIL_CreateMultilevelEffect1(client);
    } else {
        return UTIL_CreateMultilevelEffect2(client);
    }
}

stock UTIL_WeaponTypeIsGrenade(type) {
    return type == g_WeaponAmmoTypeHegrenade 
        || type == g_WeaponAmmoTypeFlashbang 
        || type == g_WeaponAmmoTypeSmokegrenade;
}

stock UTIL_WeaponGetGrenadeType(weapon) {
    return GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
}

UTIL_RemoveAmmo(client, weapon) {
    new primaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (primaryAmmoType != -1) {
        SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, primaryAmmoType);
    }
        
    /*
    // NOT USED BECAUSE NOT ALL WEAPONS HAS SECAMMO (TODO: check with mp5navy!)
    new secondaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iSeconaryAmmoType");
    if (secondaryAmmoType != -1) {
        SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, secondaryAmmoType);
    }
    */
    
    // LEAVE ONE CLIP -> COMMENTED REMOVE
    // SetEntProp(weapon, Prop_Send, "m_iClip1", 0);

    // REMOVE EXTRA CLIPS
    SetEntProp(weapon, Prop_Send, "m_iClip2", 0);

    if (g_Cfg_BonusWeaponAmmo > 0) {
        SetEntProp(weapon, Prop_Send, "m_iClip1", g_Cfg_BonusWeaponAmmo);
    }
}

/**
 * Removes from the world.
 *
 * @param entity        entity index
 * @noreturn
 */
UTIL_Remove(entity) {
    if (entity) {
        AcceptEntityInput(entity, "Kill");
    }
}

UTIL_EndMultiplayerGameDelayed() {
    if (g_Cfg_EndGameDelay) {
        CreateTimer(g_Cfg_EndGameDelay, UTIL_Timer_EndMultiplayerGame);
    } else {
        UTIL_EndMultiplayerGame();
    }
}

public Action:UTIL_Timer_EndMultiplayerGame(Handle:timer, any:data) {
    UTIL_EndMultiplayerGame();
}

/**
 * Forces multiplayer game to end so it can go threw intermission and map change.
 *
 * @noparam
 * @noreturn
 */
UTIL_EndMultiplayerGame() {
    if (g_Cfg_EndGameSilent) {
        UTIL_EndMultiplayerGameSilent();
    } else {
        UTIL_EndMultiplayerGameNormal();
    }
}

UTIL_EndMultiplayerGameSilent() {
    new ent = CreateEntityByName("game_end");
    DispatchSpawn(ent);
    AcceptEntityInput(ent, "EndGame");
}

UTIL_EndMultiplayerGameNormal() {
    new Handle:hTimelimit = FindConVar("mp_timelimit"), 
        Handle:hFraglimit = FindConVar("mp_fraglimit"), 
        Handle:hMaxrounds = FindConVar("mp_maxrounds"), 
        Handle:hWinlimit = FindConVar("mp_winlimit");
    SetConVarInt(hTimelimit, 0);
    SetConVarInt(hFraglimit, 0);
    SetConVarInt(hMaxrounds, 0);
    SetConVarInt(hWinlimit, 0);

    if (g_GameName == GameName:Csgo) {
        new Handle:hIgnoreConditions = FindConVar("mp_ignore_round_win_conditions"),
            Handle:hMatchEndChangelevel = FindConVar("mp_match_end_changelevel");
        SetConVarInt(hIgnoreConditions, 0);
        SetConVarInt(hMatchEndChangelevel, 1);
	}
    		
    if (GetClientTeam(GameWinner) == CS_TEAM_T) {
        CS_TerminateRound(0.1, CSRoundEnd_TerroristWin);
    } else {
        CS_TerminateRound(0.1, CSRoundEnd_CTWin);
    }
}

/**
 * Get the count of any grenade type a client has. It does not work for taser or other weapons.
 * 
 * @param client    The client index.
 * @param type      The type of grenade.
 */
stock UTIL_WeaponAmmoGetGrenadeCount(client, type) {
    #if defined GUNGAME_DEBUG
        LogError("[DEBUG-GUNGAME] FUNC UTIL_WeaponAmmoGetGrenadeCount, client=%i type=%i count=%i", client, type, GetEntData(client, g_iOffsetAmmo + (type * 4)));
    #endif

    return GetEntData(client, g_iOffsetAmmo + (type * 4));
}

stock bool:UTIL_HasClientHegrenade(client) {
    return UTIL_WeaponAmmoGetGrenadeCount(client, g_WeaponAmmoTypeHegrenade) > 0;
}

stock bool:UTIL_HasClientMolotov(client) {
    return UTIL_WeaponAmmoGetGrenadeCount(client, g_WeaponAmmoTypeMolotov) > 0;
}


UTIL_FastSwitch(client, weapon, bool:setActiveWeapon) {
    new Float:GameTime = GetGameTime();

    if (setActiveWeapon) {
        SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
        SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GameTime);
    }

    SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GameTime);
    new ViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    if (ViewModel != -1) {
        SetEntProp(ViewModel, Prop_Send, "m_nSequence", 0);
    }
}

UTIL_FastSwitchWithCheck(client, weapon, bool:setActiveWeapon, weaponId) {
    if (g_Cfg_FastSwitchOnLevelUp && (!g_Cfg_FastSwitchSkipWeapons[weaponId]) && weapon) {
        UTIL_FastSwitch(client, weapon, setActiveWeapon);
    }
}

UTIL_UseWeapon(client, WeapId) {
    g_BlockFastSwitchOnChange[client] = true;
    FakeClientCommand(client, "use %s", g_WeaponName[WeapId]);
    g_BlockFastSwitchOnChange[client] = false;
}

UTIL_RemoveEntityByClassName(const String:entityName[]) {
    new ent = -1;
    new prev = 0;
    while ((ent = FindEntityByClassname(ent, entityName)) != -1) {
        UTIL_Remove(prev);
        prev = ent;
    }
    UTIL_Remove(prev);
}

PrecacheSoundFixed(Sounds:soundType) {
    new bool:useDiskStream = false;
    if (g_GameName == GameName:Csgo) {
        new const String:musicFolder[] = "music/";
        decl String:tmpString[sizeof(musicFolder)];
        strcopy(tmpString, sizeof(tmpString), EventSounds[soundType]);
        useDiskStream = !StrEqual(musicFolder, tmpString, false);
    }

    if (useDiskStream) {
        Format(EventSounds[soundType], sizeof(EventSounds[]), "*%s", EventSounds[soundType]);
        // Fake precache
        AddToStringTable(FindStringTable("soundprecache"), EventSounds[soundType]);
    } else {
        PrecacheSound(EventSounds[soundType]);
    }
}
