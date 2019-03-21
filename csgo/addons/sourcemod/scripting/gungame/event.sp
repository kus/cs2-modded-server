OnEventStart()
{
    // Events
    HookEvent("round_start", _RoundState);
    HookEvent("round_end", _RoundState);
    HookEvent("player_death", _PlayerDeath);
    HookEvent("player_spawn", _PlayerSpawn);
    HookEvent("player_team", _PlayerTeam);
    HookEvent("item_pickup", _ItemPickup);
    HookEvent("hegrenade_detonate",_HeExplode);

    if ( g_SdkHooksEnabled && g_Cfg_BlockWeaponSwitchIfKnife ) {
        StartSwitchHook();
    }

    if ( g_Cfg_SelfKillProtection ) {
        AddCommandListener(Event_KillCommand, "kill");
    }
}

OnEventShutdown()
{
    // Events
    UnhookEvent("round_start", _RoundState);
    UnhookEvent("round_end", _RoundState);
    UnhookEvent("player_death", _PlayerDeath);
    UnhookEvent("player_spawn", _PlayerSpawn);
    UnhookEvent("player_team", _PlayerTeam);
    UnhookEvent("item_pickup", _ItemPickup);
    UnhookEvent("hegrenade_detonate",_HeExplode);

    if ( g_SdkHooksEnabled && g_Cfg_BlockWeaponSwitchIfKnife ) {
        StopSwitchHook();
    }

    if ( g_Cfg_SelfKillProtection ) {
        RemoveCommandListener(Event_KillCommand, "kill");
    }
}

StartSwitchHook() {
    for (new client = 1; client <= MaxClients; client++) { 
        if ( IsClientInGame(client) ) { 
            g_BlockSwitch[client] = false;
            #if defined WITH_SDKHOOKS
            SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
            #endif
        } 
    }
}

StopSwitchHook() {
    for (new client = 1; client <= MaxClients; client++) { 
        if ( IsClientInGame(client) ) { 
            #if defined WITH_SDKHOOKS
            SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
            #endif
        } 
    }
}

public _ItemPickup(Handle:event, const String:name[], bool:dontBroadcast) {
    if (!IsActive){
        return;
    }

    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (KnifeElite) {
        if (client && PlayerState[client] & KNIFE_ELITE) {
            UTIL_ForceDropAllWeapon(client, false);
        }
    }
}

public _BombPickup(Handle:event, const String:name[], bool:dontBroadcast) {
    if (IsActive && MapStatus & OBJECTIVE_REMOVE_BOMB) {
        new client = GetClientOfUserId(GetEventInt(event, "userid"));
        if (client) {
            UTIL_ForceDropC4(client);
        }
    }
}

public _PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
    new oldTeam         = GetEventInt(event, "oldteam");
    new newTeam         = GetEventInt(event, "team");
    new bool:disconnect = GetEventBool(event, "disconnect");
    
    switch ( oldTeam )
    {
        case TEAM_T:
        {
            Tcount--;
        }
        case TEAM_CT:
        {
            CTcount--;
        }
    }

    /* Player disconnected and didn't join a new team */
    if ( !disconnect )
    {
        switch ( newTeam )
        {
            case TEAM_T:
            {
                Tcount++;
            }
            case TEAM_CT:
            {
                CTcount++;
            }
        }
    }

    if ( UnlimitedNadesMinPlayers )
    {
        UnlimitedNades = ( Tcount <= UnlimitedNadesMinPlayers || CTcount <= UnlimitedNadesMinPlayers );
    }

    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( client && !disconnect && (oldTeam >= 2) && IsClientInGame(client) && IsPlayerAlive(client) )
    {
        UTIL_StopTripleEffects(client);
    }
    if ( !client || disconnect || (oldTeam < 2) || (newTeam < 2) || !IsPlayerAlive(client) || (oldTeam == newTeam) )
    {
        return;
    }
    g_teamChange[client] = true;
}

public _RoundState(Handle:event, const String:name[], bool:dontBroadcast)
{
    if ( !IsActive )
    {
        return;
    }

    /**
     * round_start
     * round_end
     * 0123456
     */
    if(name[6] == 's')
    {
        if (GameWinner) {
            /* Lock all player since the winner was declare already if new round happened. */
            if (g_Cfg_WinnerFreezePlayers) {
                UTIL_FreezeAllPlayers();
            }
        }

        /* Round has Started. */
        RoundStarted = true;

        /* Only remove the hostages on after it been initialized */
        if(MapStatus & OBJECTIVE_HOSTAGE && MapStatus & OBJECTIVE_REMOVE_HOSTAGE)
        {
            /*Delay for 0.1 because data need to be filled for hostage entity index */
            CreateTimer(0.1, RemoveHostages);
        }

        UTIL_PlaySoundForLeaderLevel();

        // Disable warmup
        if ( WarmupEnabled && DisableWarmupOnRoundEnd )
        {
            WarmupEnabled = false;
            DisableWarmupOnRoundEnd = false;
        }

        UTIL_RemoveEntityByClassName("game_player_equip");
    } else {
        /* Round has ended. */
        RoundStarted = false;

        if ( WarmupEnabled && WarmupRandomWeaponMode == 2 )
        {
            WarmupRandomWeaponLevel = -1;
        }
    }
}

public Action:RemoveHostages(Handle:timer)
{
    /**
     * m_bHostageAlive
     * I wonder if I have to set the other Hostage items.
     * */

    if(HostageEntInfo)
    {
        for(new i = 0, edict; i < MAXHOSTAGE; i++)
        {
            // Will this return 0 if there is no hostage id in the store? from m_iHostageEntityIDs
            edict = GetEntData(HostageEntInfo, OffsetHostage + (i * 4));

            if( (edict > 0) && IsValidEntity(edict) )
            {
                RemoveEdict(edict);
                SetEntData(HostageEntInfo, OffsetHostage + (i * 4), 0, _, true);

            } else {
                break;
            }
        }
    }
}

public _PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    // Player has died.
    if ( !IsActive )
    {
        return;
    }
    
    new Victim = GetClientOfUserId(GetEventInt(event, "userid"));
    UTIL_StopTripleEffects(Victim);
    
    new Killer = GetClientOfUserId(GetEventInt(event, "attacker"));
    UTIL_UpdatePlayerScoreDelayed(Victim);
    UTIL_UpdatePlayerScoreDelayed(Killer);
    
    /* They change team at round end don't punish them. */
    if ( !RoundStarted && !AllowLevelUpAfterRoundEnd )
    {
        return;
    }
    
    decl String:Weapon[MAX_WEAPON_NAME_SIZE], String:vName[MAX_NAME_SIZE], String:kName[MAX_NAME_SIZE];

    GetEventString(event, "weapon", Weapon, sizeof(Weapon));
    GetClientName(Victim, vName, sizeof(vName));
    GetClientName(Killer, kName, sizeof(kName));

    #if defined GUNGAME_DEBUG
        LogError("[DEBUG-GUNGAME] EVENT PLAYER_DEATH weapon=%s victim=%s killer=%s", Weapon, vName, kName);
    #endif

    /* Kill self with world spawn */
    if ( Victim && !Killer )
    {
        if ( RoundStarted && WorldspawnSuicide )
        {
            ClientSuicide(Victim, vName, WorldspawnSuicide);
        }
        return;
    }

    /* They killed themself by kill command or by hegrenade etc */
    if ( Victim == Killer ) 
    {
        /* (Weapon is event weapon name, can be 'world' or 'hegrenade' etc) */
        if ( CommitSuicide && ( RoundStarted || /* weapon is not 'world' (ie not kill command) */ Weapon[0] != 'w') && (!g_teamChange[Victim]) )
        {
            ClientSuicide(Victim, vName, CommitSuicide);
        }
        return;
    }

    // Victim > 0 && Killer > 0

    new WeaponIndex = UTIL_GetWeaponIndex(Weapon), WeaponLevelIndex = g_WeaponLevelIndex[WeaponIndex];
    new Action:ret;

    if ( WarmupEnabled )
    {
        if ( ReloadWeapon )
        {
            UTIL_ReloadActiveWeapon(Killer, WeaponIndex);
        }
        return;
    }

    new bool:TeamKill = (!FFA) && (GetClientTeam(Victim) == GetClientTeam(Killer));
    Call_StartForward(FwdDeath);
    Call_PushCell(Killer);
    Call_PushCell(Victim);
    Call_PushCell(WeaponIndex);
    Call_PushCell(TeamKill && GetConVarInt(mp_friendlyfire));
    Call_Finish(ret);

    if ( ret || TeamKill )
    {
        if ( ret == Plugin_Changed )
        {
            UTIL_ReloadActiveWeapon(Killer, WeaponIndex);
        }
        return;
    }

    new level = PlayerLevel[Killer], WeaponLevel = WeaponOrderId[level], PlayerLevelIndex = g_WeaponLevelIndex[WeaponLevel];

    /* Give them another grenade if they killed another person with another weapon */
    if ( (PlayerLevelIndex == g_WeaponLevelIdHegrenade) 
        && (WeaponLevelIndex != g_WeaponLevelIdHegrenade) 
        && !( (WeaponLevelIndex == g_WeaponLevelIdKnife) && KnifeProHE ) // TODO: Remove this statement and make check if killer not leveled up, than give extra nade.
    ) {
        #if defined GUNGAME_DEBUG
            LogError("[DEBUG-GUNGAME] ... call UTIL_GiveExtraNade, killer=%i knife=%i", Killer, (WeaponLevelIndex == g_WeaponLevelIdKnife));
        #endif
        UTIL_GiveExtraNade(Killer, (WeaponLevelIndex == g_WeaponLevelIdKnife));
    }

    /* Give them another taser if they killed another person with another weapon */
    if ( (PlayerLevelIndex == g_WeaponLevelIdTaser) 
        && (WeaponLevelIndex == g_WeaponLevelIdKnife)
        && g_Cfg_ExtraTaserOnKnifeKill
    ) {
        UTIL_GiveExtraTaser(Killer);
    }

    /* Give them another molotov if they killed another person with another weapon */
    if ((PlayerLevelIndex == g_WeaponLevelIdMolotov)
        && (WeaponLevelIndex == g_WeaponLevelIdKnife)
        && g_Cfg_ExtraMolotovOnKnifeKill
    ) {
        UTIL_GiveExtraMolotov(Killer, WeaponLevel);
    }

    if ( MaxLevelPerRound && CurrentLevelPerRound[Killer] >= MaxLevelPerRound )
    {
        return;
    }

    /**
     * Steal level from other player.
     */
    if ( KnifePro && (WeaponLevelIndex == g_WeaponLevelIdKnife) )
    {
        for (;;)
        {
            new VictimLevel = PlayerLevel[Victim];

            if ( VictimLevel < KnifeProMinLevel )
            {
                CPrintToChatEx(Killer, Victim, "%t", "Is lower than the minimum knife stealing level", vName, KnifeProMinLevel);
                break;
            }

            if ( g_Cfg_KnifeProMaxDiff && ( g_Cfg_KnifeProMaxDiff < level - VictimLevel ) )
            {
                CPrintToChatEx(Killer, Victim, "%t", "You can not steal level from %s, your levels difference is more then %d", vName, g_Cfg_KnifeProMaxDiff);
                break;
            }

            if ( !g_Cfg_DisableLevelDown ) {
                new ChangedLevel = UTIL_ChangeLevel(Victim, -1, true);
                if ( VictimLevel )
                {
                    if ( ChangedLevel == VictimLevel ) {
                        break;
                    }
                    CPrintToChatAllEx(Killer, "%t", "Has stolen a level from", kName, vName);
                }
            }

            if ( (PlayerLevelIndex == g_WeaponLevelIdKnife) )
            {
                if ( UTIL_GetCustomKillPerLevel(level) > 1 ) {
                    break;
                }
            }

            if ( !KnifeProHE && PlayerLevelIndex == g_WeaponLevelIdHegrenade ) {
                return;
            }

            if (PlayerLevelIndex == g_WeaponLevelIdTaser) {
                return;
            }

            if (PlayerLevelIndex == g_WeaponLevelIdMolotov) {
                return;
            }

            new oldLevelKiller = level;
            level = UTIL_ChangeLevel(Killer, 1, true, Victim);
            if ( oldLevelKiller == level ) {
                return;
            }

            PrintLeaderToChat(Killer, oldLevelKiller, level, kName);
            CurrentLevelPerRound[Killer]++;
                   
            if ( TurboMode ) {
                UTIL_GiveNextWeapon(Killer, level, (WeaponLevelIndex == g_WeaponLevelIdKnife));
            }

            CheckForTripleLevel(Killer);

            return;
        }
    }

    new LevelUpWithPhysics = false;

    /* They didn't kill with the weapon required */
    if (WeaponLevelIndex != PlayerLevelIndex) {
        if (WeaponLevelIndex == g_WeaponLevelIdHegrenade) {
            // Killed with grenade made by map author
            if ( 
                g_Cfg_CanLevelUpWithMapNades
                && ( 
                    g_Cfg_CanLevelUpWithNadeOnKnife
                    || !(PlayerLevelIndex == g_WeaponLevelIdKnife)
                )
            ) {
                LevelUpWithPhysics = true;
            } else {
                return;
            }
        } else {
            // Maybe killed with physics made by map author
            if ( 
                g_Cfg_CanLevelUpWithPhysics
                && ( StrEqual(Weapon, "prop_physics") || StrEqual(Weapon, "prop_physics_multiplayer") ) 
                && ( 
                    ( ( PlayerLevelIndex != g_WeaponLevelIdHegrenade) && !(PlayerLevelIndex == g_WeaponLevelIdKnife) )
                    || ( g_Cfg_CanLevelUpWithPhysicsG && (PlayerLevelIndex == g_WeaponLevelIdHegrenade) )
                    || ( g_Cfg_CanLevelUpWithPhysicsK && (PlayerLevelIndex == g_WeaponLevelIdKnife) )
                )
            ) {
                LevelUpWithPhysics = true;
            } else {
                return;
            }
        }
    }

    new killsPerLevel = UTIL_GetCustomKillPerLevel(level);
    if ( ( killsPerLevel > 1 ) && !LevelUpWithPhysics )
    {
        new kills = ++CurrentKillsPerWeap[Killer], Handled;

        if ( kills <= killsPerLevel )
        {
            Call_StartForward(FwdPoint);
            Call_PushCell(Killer);
            Call_PushCell(kills);
            Call_PushCell(1);
            Call_Finish(Handled);

            if ( Handled )
            {
                CurrentKillsPerWeap[Killer]--;
                return;
            }

            if ( kills < killsPerLevel )
            {
                if ( MultiKillChat )
                {
                    if ( !g_Cfg_ShowSpawnMsgInHintBox )
                    {
                        decl String:subtext[64];
                        FormatLanguageNumberTextEx(Killer, subtext, sizeof(subtext), killsPerLevel - kills, "points");
                        CPrintToChat(Killer, "%t", "You need kills to advance to the next level", subtext, kills, killsPerLevel);
                    }
                    else
                    {
                        SetGlobalTransTarget(Killer);
                        decl String:textHint[256];
                        decl String:subtext[64];
                        FormatLanguageNumberTextEx(Killer, subtext, sizeof(subtext), killsPerLevel - kills, "points");
                        Format(textHint, sizeof(textHint), "%t", "You need kills to advance to the next level", subtext, kills, killsPerLevel);
                        CRemoveTags(textHint, sizeof(textHint));
                        
                        UTIL_ShowHintTextMulti(Killer, textHint, 3, 1.0);
                    }
                }
                

                UTIL_PlaySound(Killer, MultiKill);
                if ( ReloadWeapon )
                {
                    UTIL_ReloadActiveWeapon(Killer, WeaponLevel);
                }
                return;
            }
        }
    }
        
    // reload weapon
    if ( !TurboMode && ReloadWeapon )
    {
        UTIL_ReloadActiveWeapon(Killer, WeaponLevel);
    }
    
    if ( KnifeElite )
    {
        PlayerState[Killer] |= KNIFE_ELITE;
    }

    new oldLevelKiller = level;
    level = UTIL_ChangeLevel(Killer, 1, _, Victim);
    if ( oldLevelKiller == level )
    {
        return;
    }

    CurrentLevelPerRound[Killer]++;

    PrintLeaderToChat(Killer, oldLevelKiller, level, kName);

    if ( TurboMode || KnifeElite )
    {
        UTIL_GiveNextWeapon(Killer, level, (WeaponLevelIndex == g_WeaponLevelIdKnife));
    }

    CheckForTripleLevel(Killer);
}

// Player has spawned
public _PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    if ( !IsActive )
    {
        return;
    }

    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    if ( !client )
    {
        return;
    }

    if ( g_SkipSpawn[client] ) {
        g_SkipSpawn[client] = false;
        return;
    }

    UTIL_UpdatePlayerScoreLevel(client);
    UTIL_StopBonusGravity(client);
    
    g_teamChange[client] = false;
    
    new team = GetClientTeam(client);

    if ( team != TEAM_T && team != TEAM_CT )
    {
        return;
    }

    /* Reset Knife Elite state */
    if ( KnifeElite )
    {
        PlayerState[client] &= ~KNIFE_ELITE;
    }

    /* They are not alive don't proccess */
    if ( !IsPlayerAlive(client) )
    {
        return;
    }

    if ( !(PlayerState[client] & FIRST_JOIN) )
    {
        PlayerState[client] |= FIRST_JOIN;

        if ( !IsFakeClient(client) )
        {
            UTIL_PlaySoundDelayed(1.5, client, Welcome);

            /**
             * Show join message.
             */

            if ( JoinMessage )
            {
                ShowJoinMsgPanel(client);
            }
        }
        
        if ( !StatsEnabled || GG_IsPlayerWinsLoaded(client) ) /* HINT: gungame_stats */
        {
            UTIL_SetHandicapForClient(client);
        }
    }

    if ( g_Cfg_ArmorKevlar )
    {
        /* Set armor to 100. */
        SetEntData(client, OffsetArmor, 100);
    }
    if ( g_Cfg_ArmorHelmet )
    {
        /* Set user with helm. */
        SetEntData(client, OffsetHelm, 1);
    }

    CurrentLevelPerRound[client] = 0;
    CurrentLevelPerRoundTriple[client] = 0;

    if ( team == TEAM_CT )
    {
        if ( MapStatus & OBJECTIVE_BOMB && !(MapStatus & OBJECTIVE_REMOVE_BOMB) )
        {
            // Give them a defuser if objective is not removed
            SetEntData(client, OffsetDefuser, 1);
        }
    }

    new Level = PlayerLevel[client];
    UTIL_ForceDropAllWeapon(client, false);

    /* For deathmatch when they get respawn after round start freeze after game winner. */
    if (GameWinner) {
        if (g_Cfg_WinnerFreezePlayers) {
            UTIL_FreezePlayer(client);
        }
    }

    if ( WarmupEnabled && !DisableWarmupOnRoundEnd )
    {
        if ( !WarmupInitialized ) {
            CPrintToChat(client, "%t", "Warmup round has not started yet");
        } else {
            CPrintToChat(client, "%t", "Warmup round is in progress");
        }

        UTIL_GiveWarmUpWeaponDelayed(0.3, client);
        return;
    }

    UTIL_GiveNextWeapon(client, Level, false, 0.3, true);

    // spawn chat messages
    new killsPerLevel = UTIL_GetCustomKillPerLevel(Level);

    if ( !g_Cfg_ShowSpawnMsgInHintBox )
    {
        CPrintToChat(client, "%t", "You are on level", Level + 1, WeaponOrderName[Level]);

        if ( MultiKillChat && ( killsPerLevel > 1 ) )
        {
            new kills = CurrentKillsPerWeap[client];
            decl String:subtext[64];
            FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), killsPerLevel - kills, "points");
            CPrintToChat(client, "%t", "You need kills to advance to the next level", subtext, kills, killsPerLevel);
        }
    }
    else
    {
        SetGlobalTransTarget(client);
        decl String:textHint[512], String:textHint2[256];
        Format(textHint, sizeof(textHint), "%t", "You are on level", Level + 1, WeaponOrderName[Level]);
        CRemoveTags(textHint, sizeof(textHint));
        if ( g_Cfg_ShowLeaderInHintBox && CurrentLeader )
        {
            new leaderLevel = PlayerLevel[CurrentLeader];
            if ( client == CurrentLeader ) {
                Format(textHint2, sizeof(textHint2), "\n%t", "LevelPanel: You are currently the leader");
            } else if ( Level == leaderLevel ) {
                Format(textHint2, sizeof(textHint2), "\n%t", "LevelPanel: You have tied with the leader");
            } else {
                Format(textHint2, sizeof(textHint2), "\n%t", "Hint: Leader is on level", leaderLevel + 1, WeaponOrderName[leaderLevel]);
            }
            
            StrCat(textHint, sizeof(textHint), textHint2);
        }
        if ( MultiKillChat && ( killsPerLevel > 1 ) )
        {
            new kills = CurrentKillsPerWeap[client];
            decl String:subtext[64];
            FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), killsPerLevel - kills, "points");
            Format(textHint2, sizeof(textHint2), "\n%t", "You need kills to advance to the next level", subtext, kills, killsPerLevel);
            CRemoveTags(textHint2, sizeof(textHint2));
            StrCat(textHint, sizeof(textHint), textHint2);
        }
        UTIL_ShowHintTextMulti(client, textHint, 3, 1.0);
    }
}

public _BombState(Handle:event, const String:name[], bool:dontBroadcast)
{
    if ( !IsActive || !ObjectiveBonus || (!RoundStarted && name[5] != 'e') )
    {
        return;
    }
    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    if ( !client || !IsClientConnected(client) || !IsClientInGame(client) )
    {
        return;
    }
    UTIL_UpdatePlayerScoreDelayed(client);
    
    if ( !ObjectiveBonusWin && ( PlayerLevel[client] >= WeaponOrderCount - ObjectiveBonus ) )
    {
        return;
    }

    if ( ( g_Cfg_ObjectiveBonusExplode && name[5] == 'p' ) ||
         ( !g_Cfg_ObjectiveBonusExplode && name[5] == 'e' ) )
    {
        return;
    }
    
    /* Give them a level if give level for objective */
    new oldLevel = PlayerLevel[client];
    new newLevel = UTIL_ChangeLevel(client, ObjectiveBonus);
    if ( newLevel == oldLevel )
    {
        return;
    }
    decl String:cname[MAX_NAME_SIZE];
    GetClientName(client, cname, sizeof(cname));
    PrintLeaderToChat(client, oldLevel, newLevel, cname);

    decl String:subtext[64];
    FormatLanguageNumberTextEx(client, subtext, sizeof(subtext), ObjectiveBonus, "levels");
    if ( name[5] == 'p' )
    {
        CPrintToChat(client, "%t", "You gained level by planting the bomb", subtext);
    }
    else if ( name[5] == 'e' )
    {
        CPrintToChat(client, "%t", "You gained level by exploding the bomb", subtext);
    }
    else
    {
        CPrintToChat(client, "%t", "You gained level by defusing the bomb", subtext);
    }
}

public _HostageKilled(Handle:event, const String:name[], bool:dontBroadcast)
{
    if ( !IsActive || !RoundStarted )
    {
        return;
    }

    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    if ( !client )
    {
        return;
    }

    decl String:Name[MAX_NAME_SIZE];
    GetClientName(client, Name, sizeof(Name));

    new oldLevel = PlayerLevel[client];
    new newLevel = UTIL_ChangeLevel(client, -1);
    if ( oldLevel == newLevel )
    {
        return;
    }
    PrintLeaderToChat(client, oldLevel, newLevel, Name);
    CPrintToChatAllEx(client, "%t", "Has lost a level by killing a hostage", Name);
}

ClientSuicide(client, const String:Name[], loose)
{
    new oldLevel = PlayerLevel[client];
    new newLevel = UTIL_ChangeLevel(client, -loose);
    if ( oldLevel == newLevel )
    {
        return;
    }
    if ( loose > 1 )
    {
        decl String:subtext[64];
        for ( new i = 1; i <= MaxClients; i++ )
        {
            if ( IsClientInGame(i) )
            {
                SetGlobalTransTarget(i);
                FormatLanguageNumberTextEx(i, subtext, sizeof(subtext), oldLevel - newLevel, "levels");
                CPrintToChatEx(i, client, "%t", "Has lost levels by suicided", Name, subtext);
            }
        }
    }
    else
    {
        CPrintToChatAllEx(client, "%t", "Has lost a level by suicided", Name);
    }
    
    PrintLeaderToChat(client, oldLevel, newLevel, Name);
}

public _HeExplode(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( !IsClientInGame(client) || !IsPlayerAlive(client) ) {
        return;
    }

    if ( ( WarmupNades && WarmupEnabled )
         || ( g_WeaponLevelIndex[WeaponOrderId[PlayerLevel[client]]] == g_WeaponLevelIdHegrenade
            && ( UnlimitedNades 
               || ( NumberOfNades && g_NumberOfNades[client] ) ) ) )
    {
        /* Do not give them another nade if they already have one */
        if (!UTIL_HasClientHegrenade(client)) {
            if ( NumberOfNades ) {
                g_NumberOfNades[client]--;
            }

            new bool:blockSwitch = g_SdkHooksEnabled && g_Cfg_BlockWeaponSwitchOnNade;
            new newWeapon = GivePlayerItemWrapper(client, g_WeaponName[g_WeaponIdHegrenade], blockSwitch);
            if (!blockSwitch) {
                UTIL_UseWeapon(client, g_WeaponIdHegrenade);
                UTIL_FastSwitchWithCheck(client, newWeapon, true, g_WeaponIdHegrenade);
            }
        }
    }
}

public Action:OnWeaponSwitch(client, weapon) {
    if ( g_BlockSwitch[client] ) {
        return Plugin_Handled;
    } else if (g_Cfg_FastSwitchOnChangeWeapon && weapon) {

        if (!g_BlockFastSwitchOnChange[client]) {
            new Handle:data;
            data = CreateDataPack();
            WritePackCell(data, client);
            WritePackCell(data, weapon);

            CreateTimer(0.1, Timer_FastSwitch, data);
        }

        return Plugin_Continue;
    }
    return Plugin_Continue;
}

public Action:Timer_FastSwitch(Handle:timer, any:data) {
    ResetPack(data);
    new client = ReadPackCell(data);
    new weapon = ReadPackCell(data);
    CloseHandle(data);

    if (client && IsClientInGame(client) && IsPlayerAlive(client) && weapon && IsValidEdict(weapon)) {
        UTIL_FastSwitch(client, weapon, false);
    }
}

public Action:Event_KillCommand(client, const String:command[], argc) {
    return Plugin_Handled;
}

public Action:OnGetGameDescription(String:gameDesc[64]) {
    if ( !g_CfgGameDesc[0] ) {
        return Plugin_Continue;
    }

    strcopy(gameDesc, sizeof(gameDesc), g_CfgGameDesc);
    return Plugin_Changed;
}

public Event_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) {
    if ( cvar == g_Cvar_Turbo ) {
        TurboMode = GetConVarBool(g_Cvar_Turbo);
        return;
    } else if ( cvar == g_Cvar_MultiLevelAmount ) {
        g_Cfg_MultiLevelAmount = GetConVarInt(g_Cvar_MultiLevelAmount);
        if ( g_Cfg_MultiLevelAmount < 0 ) {
            g_Cfg_MultiLevelAmount = 1;
        }
        return;
    }
}

public Action:CS_OnCSWeaponDrop(client, weapon) {
    if (!IsActive) {
        return Plugin_Continue;
    }
    if (StripDeadPlayersWeapon == 1) {
        // do not allow drop weapon
        return Plugin_Stop;
    } else if (StripDeadPlayersWeapon == 2) {
        new Handle:data = CreateDataPack();
        WritePackCell(data, client);
        WritePackCell(data, weapon);
        
        CreateTimer(0.1, Timer_RemoveDroppedWeapon, data);
        // allow drop weapon
        return Plugin_Continue;
    } else {
        // allow drop weapon
        return Plugin_Continue;
    }
}

public Action:Timer_RemoveDroppedWeapon(Handle:timer, any:data) {
    new client, weapon;

    ResetPack(data);
    client = ReadPackCell(data);
    weapon = ReadPackCell(data);
    CloseHandle(data);
    
    if (!IsValidEntity(weapon) || !IsValidEdict(weapon)) {
        // entity is invalid
        return Plugin_Handled;
    }
    // entity is valid

    new parent = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
    if (parent > 0) {
        // weapon is owned by someone
        return Plugin_Handled;
    }
    // weapon is not owned by someone

    if (IsClientInGame(client) && IsPlayerAlive(client)) {
        if ((g_GameName == GameName:Csgo)
            && UTIL_IsWeaponTaser(weapon)
            && UTIL_IsTaserEmpty(weapon)
        ) {
            UTIL_Remove(weapon);
        }

        // client, that dropped weapon, is alive
        return Plugin_Handled;
    }
    // client, that dropped weapon, is not alive or does not exist

    // remove weapon
    UTIL_Remove(weapon);

    return Plugin_Handled;
}
