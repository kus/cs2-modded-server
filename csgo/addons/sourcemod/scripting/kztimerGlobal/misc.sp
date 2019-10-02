stock bool:IsValidClient(client)
{
    if(client >= 1 && client <= MaxClients && IsValidEntity(client) && IsClientConnected(client) && IsClientInGame(client))
        return true;
    return false;
}

public SetReplayRoute()
{
	//valid handles?
	new Handle:hReplayRouteArray;
	if (g_hReplayRouteArray != INVALID_HANDLE && GetArraySize(g_hReplayRouteArray) > 2)
		hReplayRouteArray = g_hReplayRouteArray;
	else
	{
		if (g_ProBot==g_TmpRouteID && g_hRouteArray[g_ProBot] != INVALID_HANDLE)
			hReplayRouteArray = g_hRouteArray[g_ProBot];
		else
		if (g_TpBot==g_TmpRouteID && g_hRouteArray[g_TpBot] != INVALID_HANDLE)
			hReplayRouteArray = g_hRouteArray[g_TpBot];
		else
			return;
	}

	//set beam points
	new Handle:hTmpArray;
	hTmpArray = CreateArray(3);
	for (new i = 0; i < GetArraySize(hReplayRouteArray); i++)
	{
		decl Float:fBeamOrigin[3];
		GetArrayArray(hReplayRouteArray, i, fBeamOrigin, 3);
		for (new client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client) && g_bReplayRoute[client] && !IsFakeClient(client))
			{
				decl Float:fClientOrigin[3];
				GetClientAbsOrigin(client, fClientOrigin);
				new Float:distance = GetVectorDistance(fClientOrigin, fBeamOrigin);
				if (distance < 1200.0)
				{
					new bool:valid_beam_point=true;
					for(new j = 0; j < GetArraySize(hTmpArray); j++)
					{
						decl Float:fOrigin[3];
						GetArrayArray(hTmpArray,j,fOrigin,3)
						if (GetVectorDistance(fOrigin, fBeamOrigin) < 100.0)
						{
							valid_beam_point=false;
							break;
						}
					}
					if (valid_beam_point || i == 0)
					{
						TE_SetupGlowSprite(fBeamOrigin, g_BlueGlowSprite, 2.5, 0.17, 100);
						TE_SendToClient(client);
						PushArrayArray(hTmpArray, fBeamOrigin,3);
					}
				}
			}
		}
	}
	ResetHandle(hTmpArray);
}

//credits to AzaZPPL
//http://steamcommunity.com/profiles/76561198001602258/
public SetSoundPath()
{
	decl String:sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/kztimer/sounds.cfg");

	new i = 0;
	new String:ssp[9][128];


	if (FileExists(sPath))
	{
		new Handle:hKeyValues = CreateKeyValues("KZTimer.Sounds");
		if(FileToKeyValues(hKeyValues, sPath) && KvGotoFirstSubKey(hKeyValues))
		{
			do
			{
				if (i < 9)
				{
					KvGetString(hKeyValues, "path", ssp[i], 128);
				}
				i++;
			}
			while (KvGotoNextKey(hKeyValues));
		}

		Format(PRO_FULL_SOUND_PATH, sizeof(PRO_FULL_SOUND_PATH), "sound/%s", ssp[0]);
		Format(PRO_RELATIVE_SOUND_PATH, sizeof(PRO_RELATIVE_SOUND_PATH), "*%s", ssp[0]);

		Format(CP_FULL_SOUND_PATH, sizeof(CP_FULL_SOUND_PATH), "sound/%s", ssp[1]);
		Format(CP_RELATIVE_SOUND_PATH, sizeof(CP_RELATIVE_SOUND_PATH), "*%s", ssp[1]);

		Format(UNSTOPPABLE_SOUND_PATH, sizeof(UNSTOPPABLE_SOUND_PATH), "sound/%s", ssp[2]);
		Format(UNSTOPPABLE_RELATIVE_SOUND_PATH, sizeof(UNSTOPPABLE_RELATIVE_SOUND_PATH), "*%s", ssp[2]);

		Format(GODLIKE_FULL_SOUND_PATH, sizeof(GODLIKE_FULL_SOUND_PATH), "sound/%s", ssp[3]);
		Format(GODLIKE_RELATIVE_SOUND_PATH, sizeof(GODLIKE_RELATIVE_SOUND_PATH), "*%s", ssp[3]);

		Format(GODLIKE_RAMPAGE_FULL_SOUND_PATH, sizeof(GODLIKE_RAMPAGE_FULL_SOUND_PATH), "sound/%s", ssp[4]);
		Format(GODLIKE_RAMPAGE_RELATIVE_SOUND_PATH, sizeof(GODLIKE_RAMPAGE_RELATIVE_SOUND_PATH), "*%s", ssp[4]);

		Format(GODLIKE_DOMINATING_FULL_SOUND_PATH, sizeof(GODLIKE_DOMINATING_FULL_SOUND_PATH), "sound/%s", ssp[5]);
		Format(GODLIKE_DOMINATING_RELATIVE_SOUND_PATH, sizeof(GODLIKE_DOMINATING_RELATIVE_SOUND_PATH), "*%s", ssp[5]);

		Format(PERFECT_FULL_SOUND_PATH, sizeof(PERFECT_FULL_SOUND_PATH), "sound/%s", ssp[6]);
		Format(PERFECT_RELATIVE_SOUND_PATH, sizeof(PERFECT_RELATIVE_SOUND_PATH), "*%s", ssp[6]);

		Format(IMPRESSIVE_FULL_SOUND_PATH, sizeof(IMPRESSIVE_FULL_SOUND_PATH), "sound/%s", ssp[7]);
		Format(IMPRESSIVE_RELATIVE_SOUND_PATH, sizeof(IMPRESSIVE_RELATIVE_SOUND_PATH), "*%s", ssp[7]);


		Format(GOLDEN_FULL_SOUND_PATH, sizeof(GOLDEN_FULL_SOUND_PATH), "sound/%s", ssp[8]);
		Format(GOLDEN_RELATIVE_SOUND_PATH, sizeof(GOLDEN_RELATIVE_SOUND_PATH), "*%s", ssp[8]);

		if (hKeyValues != INVALID_HANDLE)
			CloseHandle(hKeyValues);
	}
	else
		SetFailState("<KZTIMER> addons/sourcemod/configs/kztimer/sounds.cfg not found.");
}

public SetServerConvars()
{
	ConVar cvWinConditions = FindConVar("mp_ignore_round_win_conditions");
	ConVar mp_respawn_on_death_ct = FindConVar("mp_respawn_on_death_ct");
	ConVar mp_respawn_on_death_t = FindConVar("mp_respawn_on_death_t");
	ConVar host_players_show = FindConVar("host_players_show");
	ConVar sv_max_queries_sec = FindConVar("sv_max_queries_sec");
	ConVar sv_infinite_ammo = FindConVar("sv_infinite_ammo");
	ConVar mp_do_warmup_period = FindConVar("mp_do_warmup_period");
	ConVar mp_warmuptime = FindConVar("mp_warmuptime");
	ConVar mp_match_can_clinch = FindConVar("mp_match_can_clinch");
	ConVar mp_match_end_changelevel = FindConVar("mp_match_end_changelevel");
	ConVar mp_match_end_restart = FindConVar("mp_match_end_restart");
	ConVar mp_freezetime = FindConVar("mp_freezetime");
	ConVar mp_match_restart_delay = FindConVar("mp_match_restart_delay");
	ConVar mp_endmatch_votenextleveltime = FindConVar("mp_endmatch_votenextleveltime");
	ConVar mp_endmatch_votenextmap = FindConVar("mp_endmatch_votenextmap");
	ConVar sv_timebetweenducks = FindConVar("sv_timebetweenducks");
	ConVar mp_halftime = FindConVar("mp_halftime");
	ConVar bot_zombie = FindConVar("bot_zombie");
	ConVar sv_disable_immunity_alpha = FindConVar("sv_disable_immunity_alpha");
	ConVar mp_teammates_are_enemies = FindConVar("mp_teammates_are_enemies");
	ConVar mp_death_drop_gun = FindConVar("mp_death_drop_gun");
	ConVar sv_ladder_scale_speed = FindConVar("sv_ladder_scale_speed");

	if (!g_bAllowRoundEndCvar)
	{
		SetConVarBool(cvWinConditions, true);
		SetConVarInt(g_hMaxRounds, 1);
		SetConVarFloat(mp_freezetime, 0.0);
	}
	else
		SetConVarBool(cvWinConditions, false);

	if (g_bEnforcer)
	{
		new Float:JumpImpulseValue = GetConVarFloat(g_hJumpImpulse);

		SetConVarFloat(g_hStaminaLandCost, 0.0);
		SetConVarFloat(g_hStaminaJumpCost, 0.0);
		SetConVarFloat(g_hMaxSpeed, 320.0);
		SetConVarFloat(g_hGravity, 800.0);
		SetConVarFloat(g_hAirAccelerate, 100.0);
		SetConVarFloat(g_hFriction, 5.0);
		SetConVarFloat(g_hAccelerate, 6.5);
		SetConVarFloat(g_hMaxVelocity, 2000.0);
		SetConVarFloat(g_hBhopSpeedCap, 380.0);
		SetConVarFloat(g_hWaterAccelerate, 10.0);
		SetConVarInt(g_hCheats, 0);
		SetConVarInt(g_hDropKnifeEnable, 0);
		SetConVarInt(g_hEnableBunnyhoping, 1);
		SetConVarInt(g_hAutoBhop, 0);
		SetConVarInt(g_hClampVel, 0);
		SetConVarFloat(g_hsv_ladder_scale_speed, 1.0);
		SetConVarFloat(g_hJumpImpulse, 301.993377);
		SetConVarInt(g_hAccelerateUseWeaponSpeed, 0);
		SetConVarFloat(g_hWaterMovespeedMultiplier, 0.8);
		SetConVarInt(g_hWaterSwimMode, 0);
		SetConVarFloat(g_hWeaponEncumbranceScale, 0.0);
		SetConVarFloat(g_hAirMaxWishspeed, 30.0);
		SetConVarInt(g_hLedgeMantleHelper, 0);
		SetConVarFloat(g_hStandableNormal, 0.7);
		SetConVarFloat(g_hWalkableNormal, 0.7);
		SetConVarInt(g_hAmmoGrenadeLimitBumpmine, 0);
		SetConVarFloat(g_hBumpmineDetonateDelay, 99999.9);
		SetConVarFloat(g_hShieldSpeedDeployed, 250.0);
		SetConVarFloat(g_hShieldSpeedHolstered, 250.0);
		SetConVarFloat(g_hExojumpJumpbonusForward, 0.0);
		SetConVarFloat(g_hExojumpJumpbonusUp, 0.0);
		SetConVarFloat(g_hExojumpJumpcost, 0.0);
		SetConVarFloat(g_hExojumpLandcost, 0.0);
		SetConVarFloat(g_hJumpImpulseExojumpMultiplier, 1.0);

		if (FloatAbs(JumpImpulseValue - 301.993377) > 0.00000)
			ServerCommand("sv_jump_impulse 301.993377");

	}

	if (g_bAutoRespawn)
	{
		ConVar mp_respawnwavetime_ct = FindConVar("mp_respawnwavetime_ct");
		ConVar mp_respawnwavetime_t = FindConVar("mp_respawnwavetime_t");
		SetConVarInt(mp_respawn_on_death_ct, 1);
		SetConVarInt(mp_respawn_on_death_t, 1);
		SetConVarFloat(mp_respawnwavetime_ct, 3.0);
		SetConVarFloat(mp_respawnwavetime_t, 3.0);
	}
	else
	{
		SetConVarInt(mp_respawn_on_death_ct, 0);
		SetConVarInt(mp_respawn_on_death_t, 0);
	}
	SetConVarInt(host_players_show, 2);
	SetConVarInt(sv_max_queries_sec, 6);
	SetConVarInt(sv_infinite_ammo, 2);
	SetConVarBool(mp_endmatch_votenextmap, false);
	SetConVarFloat(mp_warmuptime, 5.0);
	SetConVarBool(mp_match_can_clinch, false);
	SetConVarBool(mp_match_end_changelevel, true);
	SetConVarBool(mp_match_end_restart, false);
	SetConVarInt(mp_match_restart_delay, 10);
	SetConVarFloat(mp_endmatch_votenextleveltime, 3.0);
	SetConVarFloat(sv_timebetweenducks, 0.1);
	SetConVarBool(mp_halftime, false);
	SetConVarBool(bot_zombie, true);
	SetConVarBool(mp_do_warmup_period, true);
	SetConVarBool(sv_disable_immunity_alpha, true);
	SetConVarBool(mp_teammates_are_enemies, true);
	SetConVarBool(mp_death_drop_gun, true);
	SetConVarFloat(sv_ladder_scale_speed, 1.0);
}

public DoValidTeleport(client, Float:origin[3],Float:angles[3],Float:vel[3])
{
	if (!IsValidClient(client))
		return;
	
	g_fTeleportValidationTime[client] = GetEngineTime();
	TeleportEntity(client, origin, angles, vel);
}

public LadderCheck(client,Float:speed)
{
	decl Float:pos[3],Float:dist;
	GetClientAbsOrigin(client, pos);
	dist = pos[2]- g_fLastPosition[client][2];
	if (GetEntityMoveType(client) == MOVETYPE_LADDER && dist > 0.5)
	{
		g_js_AvgLadderSpeed[client]+= speed;
		g_js_LadderFrames[client]++;
	}

	if(!(GetEntityFlags(client) & FL_ONGROUND) && GetEntityMoveType(client) == MOVETYPE_WALK && g_LastMoveType[client] == MOVETYPE_LADDER)
	{
		//start ladder jump
		if (g_js_LadderFrames[client] > 20)
		{
			new Float:AvgSpeed = g_js_AvgLadderSpeed[client] / g_js_LadderFrames[client];
			if (AvgSpeed < 100.0)
				Prethink(client, true);
		}
	}
	if (g_js_LadderFrames[client] > 0 && GetEntityMoveType(client) != MOVETYPE_LADDER)
	{
		g_js_AvgLadderSpeed[client] = 0.0;
		g_js_LadderFrames[client] = 0;
	}
}

public CheckSpawnPoints()
{
	new Float:fSpawnpointAngle[3], Float:fSpawnpointOrigin[3];
	if(StrEqual(g_szMapPrefix[0],"kz") || StrEqual(g_szMapPrefix[0],"xc")  || StrEqual(g_szMapPrefix[0],"kzpro") || StrEqual(g_szMapPrefix[0],"bkz") || StrEqual(g_szMapPrefix[0],"surf")  || StrEqual(g_szMapPrefix[0],"bhop"))
	{
		new ent, ct, t, spawnpoint;
		ct = 0;
		t= 0;
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "info_player_terrorist")) != -1)
		{
			if (t==0)
			{
				GetEntPropVector(ent, Prop_Data, "m_angRotation", fSpawnpointAngle);
				GetEntPropVector(ent, Prop_Data, "m_vecOrigin", fSpawnpointOrigin);
			}
			t++;
		}
		while ((ent = FindEntityByClassname(ent, "info_player_counterterrorist")) != -1)
		{
			if (ct==0 && t==0)
			{
				GetEntPropVector(ent, Prop_Data, "m_angRotation", fSpawnpointAngle);
				GetEntPropVector(ent, Prop_Data, "m_vecOrigin", fSpawnpointOrigin);
			}
			ct++;
		}

		if (t > 0 || ct > 0)
		{
			if (t < 64)
			{
				while (t < 64)
				{
					spawnpoint = CreateEntityByName("info_player_terrorist");
					if (IsValidEntity(spawnpoint) && DispatchSpawn(spawnpoint))
					{
						ActivateEntity(spawnpoint);
						TeleportEntity(spawnpoint, fSpawnpointOrigin, fSpawnpointAngle, NULL_VECTOR);
						t++;
					}
				}
			}

			if (ct < 64)
			{
				while (ct < 64)
				{
					spawnpoint = CreateEntityByName("info_player_counterterrorist");
					if (IsValidEntity(spawnpoint) && DispatchSpawn(spawnpoint))
					{
						ActivateEntity(spawnpoint);
						TeleportEntity(spawnpoint, fSpawnpointOrigin, fSpawnpointAngle, NULL_VECTOR);
						ct++;
					}
				}
			}
		}
	}
}

public Action:CallAdmin_OnDrawOwnReason(client)
{
	g_bClientOwnReason[client] = true;
	return Plugin_Continue;
}

public OnMapVoteStarted()
{
   	for(new client = 1; client <= MAXPLAYERS; client++)
	{
		g_bMenuOpen[client] = true;
		if (g_bClimbersMenuOpen[client])
			g_bClimbersMenuwasOpen[client]=true;
		else
			g_bClimbersMenuwasOpen[client]=false;
		g_bClimbersMenuOpen[client] = false;
	}
}

public SetSkillGroups()
{
	//Map Points
	new mapcount;
	if (g_pr_MapCount < 1)
		mapcount = 1;
	else
		mapcount = g_pr_MapCount;
	g_pr_PointUnit = 1;
	new Float: MaxPoints = float(mapcount) * 1300.0 + 4000.0; //1300 = map max, 4000 = jumpstats max
	new g_RankCount = 0;

	decl String:sPath[PLATFORM_MAX_PATH], String:sBuffer[32];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/kztimer/skillgroups.cfg");

	if (FileExists(sPath))
	{
		new Handle:hKeyValues = CreateKeyValues("KZTimer.SkillGroups");
		if(FileToKeyValues(hKeyValues, sPath) && KvGotoFirstSubKey(hKeyValues))
		{
			do
			{
				if (g_RankCount <= 8)
				{
					KvGetString(hKeyValues, "name", g_szSkillGroups[g_RankCount], 32);
					KvGetString(hKeyValues, "percentage", sBuffer,32);
					if (g_RankCount != 0)
						g_pr_rank_Percentage[g_RankCount] = RoundToCeil(MaxPoints * StringToFloat(sBuffer));
				}
				g_RankCount++;
			}
			while (KvGotoNextKey(hKeyValues));
		}
		if (hKeyValues != INVALID_HANDLE)
			CloseHandle(hKeyValues);
	}
	else
		SetFailState("<KZTIMER> addons/sourcemod/configs/kztimer/skillgroups.cfg not found.");
}

public SetServerTags()
{
	new Handle:CvarHandle;
	CvarHandle = FindConVar("sv_tags");
	decl String:szServerTags[2048];
	GetConVarString(CvarHandle, szServerTags, 2048);
	if (StrContains(szServerTags,"KZTimer",true) == -1)
	{
		Format(szServerTags, 2048, "%s, KZTimer",szServerTags);
		SetConVarString(CvarHandle, szServerTags);
	}
	if (StrContains(szServerTags,"KZTimer 1.",true) == -1 && StrContains(szServerTags,"Tickrate",true) == -1)
	{
		Format(szServerTags, 2048, "%s, KZTimer %s, Tickrate %i",szServerTags,VERSION,g_Server_Tickrate);
		SetConVarString(CvarHandle, szServerTags);
	}
	if (CvarHandle != INVALID_HANDLE)
		CloseHandle(CvarHandle);
}

public PrintConsoleInfo(client)
{
	new timeleft;
	GetMapTimeLeft(timeleft)
	new mins, secs;
	decl String:finalOutput[1024];
	mins = timeleft / 60;
	secs = timeleft % 60;
	Format(finalOutput, 1024, "%d:%02d", mins, secs);
	new Float:fltickrate = 1.0 / GetTickInterval( );

	if (g_hDbGlobal != INVALID_HANDLE && !StrEqual(VERSION,g_global_szLatestGlobalVersion,false))
	{
		PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
		PrintToConsole(client,"Latest KZTimer version: %s", g_global_szLatestGlobalVersion);
	}
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
	PrintToConsole(client, "This server is running KZTimer v%s - Author: 1NuTWunDeR - Server tickrate: %i", VERSION, RoundToNearest(fltickrate));
	PrintToConsole(client, "Steam group of KZTimer: http://steamcommunity.com/groups/KZTimerOfficial");
	PrintToConsole(client, "Plugin coder: http://steamcommunity.com/profiles/76561198107281573/");
	if (timeleft > 0)
		PrintToConsole(client, "Timeleft on %s: %s",g_szMapName, finalOutput);
	PrintToConsole(client, "- Menu formatting is optimized for 1920x1080");
	PrintToConsole(client, "- Max. recording time: 60min (replay bots)");
	PrintToConsole(client, "- The speed panel of replays bots is inaccurate");
	PrintToConsole(client, " ");
	PrintToConsole(client, "Player commands:");
	PrintToConsole(client, "!help, !help2, !menu, !options, !checkpoint, !gocheck, !prev, !next, !undo, !profile, !compare, !specs,");
	PrintToConsole(client, "!bhopcheck, !maptop, top, !start, !stop, !pause, !challenge, !surrender, !goto, !spec, !wr, !avg,");
	PrintToConsole(client, "!showsettings, !latest, !measure, !ljblock, !ranks, !flashlight, !usp, !globalcheck, !beam,");
	PrintToConsole(client, "!adv, !speed, !showkeys, !hide, !sync, !bhop, !hidechat, !hideweapon, !stopsound, !route, !mapinfo");
	PrintToConsole(client, " ");
	PrintToConsole(client, "Scoreboard info:");
	PrintToConsole(client, "Kills: Time in seconds");
	PrintToConsole(client, "Assists: Checkpoints");
	PrintToConsole(client, "Deaths: Teleports");
	PrintToConsole(client, "MVP Stars: Number of finished map runs on the current map");
	PrintToConsole(client, " ");
	PrintToConsole(client, "Skill groups:");
	PrintToConsole(client, "%s (%ip), %s (%ip), %s (%ip), %s (%ip)",g_szSkillGroups[1],g_pr_rank_Percentage[1],g_szSkillGroups[2], g_pr_rank_Percentage[2],g_szSkillGroups[3], g_pr_rank_Percentage[3],g_szSkillGroups[4], g_pr_rank_Percentage[4]);
	PrintToConsole(client, "%s (%ip), %s (%ip), %s (%ip), %s (%ip)",g_szSkillGroups[5], g_pr_rank_Percentage[5], g_szSkillGroups[6],g_pr_rank_Percentage[6], g_szSkillGroups[7], g_pr_rank_Percentage[7], g_szSkillGroups[8], g_pr_rank_Percentage[8]);
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
	if (!g_global_Access)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: This server is not whitelisted.");
	else
	if (g_hDbGlobal == INVALID_HANDLE)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: No connection to the global database.");
	else
	if (g_global_Disabled)
		PrintToConsole(client, "[KZ] Global Records have been temporarily disabled. For more information visit the KZTimer steam group!");
	else
	if(!StrEqual(g_szMapPrefix[0],"kz") && !StrEqual(g_szMapPrefix[0],"xc") && !StrEqual(g_szMapPrefix[0],"bkz")  && !StrEqual(g_szMapPrefix[0],"kzpro"))
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: Only bkz_, kz_,kzpro_ and xc_ maps supported!");
	else
	if (g_global_VersionBlocked)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: This server is running an outdated KZTimer version. Contact an server admin!");
	else
	if (g_global_SelfBuiltButtons)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: Self-built climb buttons detected. (only built-in buttons supported)");
	else
	if (!g_global_IntegratedButtons)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: This map does not provide built-in climb buttons.");
	else
	if (!g_bEnforcer)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: Server settings enforcer disabled.");
	else
	if (!g_global_ValidFileSize && g_global_IntegratedButtons)
	{
		if (g_global_WrongMapVersion)
			PrintToConsole(client, "[KZ] Global Records disabled. Reason: Wrong map version. (requires latest+offical workshop version)");
		else
			PrintToConsole(client, "[KZ] Global Records disabled. Reason: Filesize of the current map does not match with the stored global filesize. Please upload the latest workshop version on your server!");
	}
	else
	if (g_bAutoTimer)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: kz_auto_timer enabled.");
	else
	if (g_bDoubleDuckCvar)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: kz_double_duck is set to 1.");
	else
	if (g_bAutoBhop)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: AutoBhop enabled.");
	else
	if (!g_global_ValidedMap)
		PrintToConsole(client, "[KZ] Global Records disabled. Reason: The current map is not approved by a kztimer map tester!");
	else
		PrintToConsole(client, "[KZ] Global records are enabled.");
	PrintToConsole(client," ");
}
stock FakePrecacheSound( const String:szPath[] )
{
	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
}

stock Client_SetAssists(client, value)
{
	new assists_offset = FindDataMapInfo( client, "m_iFrags" ) + 4;
	SetEntData(client, assists_offset, value );
}

public SetStandingStartButton(client)
{
	CreateButton(client,"climb_startbuttonx");
}


public SetStandingStopButton(client)
{
	CreateButton(client,"climb_endbuttonx");
}

public Action:BlockRadio(client, const String:command[], args)
{
	if(!g_bRadioCommands && IsValidClient(client))
	{
		PrintToChat(client, "%t", "RadioCommandsDisabled", LIMEGREEN,WHITE);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public StringToUpper(String:input[])
{
	for(new i = 0; ; i++)
	{
		if(input[i] == '\0')
			return;
		input[i] = CharToUpper(input[i]);
	}
}

public GetCountry(client)
{
	if(client != 0)
	{
		if(!IsFakeClient(client))
		{
			decl String:IP[16];
			decl String:code2[3];
			GetClientIP(client, IP, 16);

			//COUNTRY
			GeoipCountry(IP, g_szCountry[client], 100);
			if(!strcmp(g_szCountry[client], NULL_STRING))
				Format( g_szCountry[client], 100, "Unknown", g_szCountry[client] );
			else
				if( StrContains( g_szCountry[client], "United", false ) != -1 ||
					StrContains( g_szCountry[client], "Republic", false ) != -1 ||
					StrContains( g_szCountry[client], "Federation", false ) != -1 ||
					StrContains( g_szCountry[client], "Island", false ) != -1 ||
					StrContains( g_szCountry[client], "Netherlands", false ) != -1 ||
					StrContains( g_szCountry[client], "Isle", false ) != -1 ||
					StrContains( g_szCountry[client], "Bahamas", false ) != -1 ||
					StrContains( g_szCountry[client], "Maldives", false ) != -1 ||
					StrContains( g_szCountry[client], "Philippines", false ) != -1 ||
					StrContains( g_szCountry[client], "Vatican", false ) != -1 )
				{
					Format( g_szCountry[client], 100, "The %s", g_szCountry[client] );
				}
			//CODE
			if(GeoipCode2(IP, code2))
			{
				Format(g_szCountryCode[client], 16, "%s",code2);
			}
			else
				Format(g_szCountryCode[client], 16, "??");
		}
	}
}

stock StripAllWeapons(client)
{
	new iEnt;
	for (new i = 0; i <= 5; i++)
	{
		if (i != 2)
			while ((iEnt = GetPlayerWeaponSlot(client, i)) != -1)
			{
				if (IsValidEdict(iEnt))
				{
					RemovePlayerItem(client, iEnt);
					AcceptEntityInput(iEnt, "Kill");
				}
			}
	}
	if (GetPlayerWeaponSlot(client, 2) == -1)
		GivePlayerItem(client, "weapon_knife");
}

public PlayButtonSound(client)
{
	if (!IsFakeClient(client))
	{
		decl String:buffer[255];
		Format(buffer, sizeof(buffer), "play *buttons/button3.wav");
		ClientCommand(client, buffer);
	}
	//spec stop sound
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsPlayerAlive(i))
		{
			new SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				new Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if (Target == client)
				{
					decl String:szsound[255];
					Format(szsound, sizeof(szsound), "play *buttons/button3.wav");
					ClientCommand(i,szsound);
				}
			}
		}
	}
}

public PlayUnstoppableSound(client)
{
	decl String:buffer[255];
	Format(buffer, sizeof(buffer), "play %s", UNSTOPPABLE_RELATIVE_SOUND_PATH);
	if (IsValidClient(client) && !IsFakeClient(client) && g_EnableQuakeSounds[client] >= 1)
		ClientCommand(client, buffer);
	//spec stop sound
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsPlayerAlive(i))
		{
			new SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				new Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if (Target == client && g_EnableQuakeSounds[i] >= 1)
					ClientCommand(i,buffer);
			}
		}
	}
}

public DeleteButtons(client)
{
	decl String:classname[32];
	Format(classname,32,"prop_physics_override");
	for (new i; i < GetEntityCount(); i++)
    {
        if (IsValidEdict(i) && GetEntityClassname(i, classname, 32))
		{
			decl String:targetname[64];
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			if (StrEqual(targetname, "climb_startbuttonx", false) || StrEqual(targetname, "climb_endbuttonx", false))
			{
				if (StrEqual(targetname, "climb_startbuttonx", false))
				{
					g_fStartButtonPos[0] = -999999.9;
					g_fStartButtonPos[1] = -999999.9;
					g_fStartButtonPos[2] = -999999.9;
				}
				else
				{
					g_fEndButtonPos[0] = -999999.9;
					g_fEndButtonPos[1] = -999999.9;
					g_fEndButtonPos[2] = -999999.9;
				}
				AcceptEntityInput(i, "Kill");
				RemoveEdict(i);
			}
		}
	}
	Format(classname,32,"env_sprite");
	for (new i; i < GetEntityCount(); i++)
	{
        if (IsValidEdict(i) && GetEntityClassname(i, classname, 32))
		{
			decl String:targetname[64];
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			if (StrEqual(targetname, "starttimersign", false) || StrEqual(targetname, "stoptimersign", false))
			{
				AcceptEntityInput(i, "Kill");
				RemoveEdict(i);
			}
		}
	}
	g_global_SelfBuiltButtons=false;
	g_bFirstEndButtonPush=true;
	g_bFirstStartButtonPush=true;
	
	//stop player times (global record fake)
	for (new i = 1; i <= MaxClients; i++)
	if (IsValidClient(i) && !IsFakeClient(i) && client != 67)
	{
		Client_Stop(i,0);
	}
	if (IsValidClient(client))
		KzAdminMenu(client);
}

public CreateButton(client,String:targetname[])
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		//location (crosshair)
		new Float:locationPlayer[3];
		new Float:location[3];
		GetClientAbsOrigin(client, locationPlayer);
		GetClientEyePosition(client, location);
		new Float:ang[3];
		GetClientEyeAngles(client, ang);
		new Float:location2[3];
		location2[0] = (location[0]+(100*((Cosine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
		location2[1] = (location[1]+(100*((Sine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
		ang[0] -= (2*ang[0]);
		location2[2] = (location[2]+(100*(Sine(DegToRad(ang[0])))));
		location2[2] = locationPlayer[2];

		new ent = CreateEntityByName("prop_physics_override");
		if (ent != -1)
		{
			DispatchKeyValue(ent, "model", "models/props/switch001.mdl");
			DispatchKeyValue(ent, "spawnflags", "264");
			DispatchKeyValue(ent, "targetname",targetname);
			DispatchSpawn(ent);
			ang[0] = 0.0;
			ang[1] += 180.0;
			TeleportEntity(ent, location2, ang, NULL_VECTOR);
			SDKHook(ent, SDKHook_UsePost, OnUsePost);
			new Float:location3[3];
			location3 = location2;
			location3[2]+=150.0;
			if (StrEqual(targetname, "climb_startbuttonx"))
			{
				g_fStartButtonPos = location3;
				PrintToChat(client,"%c[%cKZ%c] Start button built!", WHITE,MOSSGREEN,WHITE);
				g_bFirstStartButtonPush=false;
			}
			else
			{
				g_fEndButtonPos = location3;
				PrintToChat(client,"%c[%cKZ%c] Stop button built!", WHITE,MOSSGREEN,WHITE);
				g_bFirstEndButtonPush = false;
			}
			g_global_SelfBuiltButtons=true;
			ang[1] -= 180.0;
		}
		new sprite = CreateEntityByName("env_sprite");
		if(sprite != -1)
		{
			DispatchKeyValue(sprite, "classname", "env_sprite");
			DispatchKeyValue(sprite, "spawnflags", "1");
			DispatchKeyValue(sprite, "scale", "0.2");
			if (StrEqual(targetname, "climb_startbuttonx"))
			{
				DispatchKeyValue(sprite, "model", "materials/models/props/startkztimer.vmt");
				DispatchKeyValue(sprite, "targetname", "starttimersign");
			}
			else
			{
				DispatchKeyValue(sprite, "model", "materials/models/props/stopkztimer.vmt");
				DispatchKeyValue(sprite, "targetname", "stoptimersign");
			}
			DispatchKeyValue(sprite, "rendermode", "1");
			DispatchKeyValue(sprite, "framerate", "0");
			DispatchKeyValue(sprite, "HDRColorScale", "1.0");
			DispatchKeyValue(sprite, "rendercolor", "255 255 255");
			DispatchKeyValue(sprite, "renderamt", "255");
			DispatchSpawn(sprite);
			location = location2;
			location[2]+=95;
			ang[0] = 0.0;
			TeleportEntity(sprite, location, ang, NULL_VECTOR);
		}

		if (StrEqual(targetname, "climb_startbuttonx"))
		{
			db_updateMapButtons(location2[0],location2[1],location2[2],ang[1],0);
			g_fStartButtonPos = location2;
		}
		else
		{
			db_updateMapButtons(location2[0],location2[1],location2[2],ang[1],1);
			g_fEndButtonPos =  location2;
		}
	}
	else
		PrintToChat(client, "%t", "AdminSetButton", MOSSGREEN,WHITE);
	KzAdminMenu(client);
}

public FixPlayerName(client)
{
	decl String:szName[64];
	decl String:szOldName[64];
	GetClientName(client,szName,64);
	Format(szOldName, 64,"%s ",szName);
	ReplaceChar("'", "`", szName);
	if (!(StrEqual(szOldName,szName)))
	{
		SetClientInfo(client, "name", szName);
		SetEntPropString(client, Prop_Data, "m_szNetname", szName);
		SetClientName(client, szName);
	}
}

public SetClientDefaults(client)
{
	FloorFrames[client] = 12 + 1;
	AirSpeed[client][0] = 0.0;
	AirSpeed[client][1] = 0.0;
	g_fLastUndo[client] = GetEngineTime();
	AfterJumpFrame[client] = false;
	PlayerInTriggerPush[client] = false;
	g_fLastTimeBhopBlock[client] = GetEngineTime();
	g_LastGroundEnt[client] = - 1;
	g_bFlagged[client] = false;
	g_fLastOverlay[client] = GetEngineTime() - 5.0;
	g_bProfileSelected[client]=false;
	g_bNewReplay[client] = false;
	g_bFirstButtonTouch[client]=true;
	g_bTimeractivated[client] = false;
	g_bKickStatus[client] = false;
	g_bSpectate[client] = false;
	g_bFirstTeamJoin[client] = true;
	g_bFirstSpawn[client] = true;
	g_bSayHook[client] = false;
	g_bRespawnAtTimer[client] = false;
	g_js_bPlayerJumped[client] = false;
	g_bRecalcRankInProgess[client] = false;
	g_bClientGroundFlag[client]=false;
	g_bPrestrafeTooHigh[client] = false;
	g_bPause[client] = false;
	g_bPositionRestored[client] = false;
	g_bTopMenuOpen[client] = false;
	g_bMapMenuOpen[client] = false;
	g_bRestorePosition[client] = false;
	g_bRestorePositionMsg[client] = false;
	g_bRespawnPosition[client] = false;
	g_bNoClip[client] = false;
	g_bMapFinished[client] = false;
	g_bMapRankToChat[client] = false;
	g_bOnBhopPlattform[client] = false;
	g_bChallenge[client] = false;
	g_bOverlay[client]=false;
	g_js_bFuncMoveLinear[client] = false;
	g_bChallenge_Request[client] = false;
	g_bClientOwnReason[client] = false;
	g_bSpecInfo[client]=true;
	g_js_Last_Ground_Frames[client] = 11;
	g_js_MultiBhop_Count[client] = 1;
	g_AdminMenuLastPage[client] = 0;
	g_fLastChatMsg[client] = 0.0;
	g_Skillgroup[client] = 0;
	g_OptionsMenuLastPage[client] = 0;
	g_MenuLevel[client] = -1;
	g_CurrentCp[client] = -1;
	g_AttackCounter[client] = 0;
	g_SpecTarget[client] = -1;
	g_CounterCp[client] = 0;
	g_OverallCp[client] = 0;
	g_OverallTp[client] = 0;
	g_pr_points[client] = 0;
	g_PrestrafeFrameCounter[client] = 0;
	g_PrestrafeVelocity[client] = 1.0;
	g_fCurrentRunTime[client] = -1.0;
	g_fPlayerCordsLastPosition[client] = Float:{0.0,0.0,0.0};
	g_fPlayerCordsUndoTp[client] = Float:{0.0,0.0,0.0};
	g_fPlayerConnectedTime[client] = GetEngineTime();
	g_fLastTimeButtonSound[client] = GetEngineTime();
	g_fLastTimeNoClipUsed[client] = -1.0;
	g_fStartTime[client] = -1.0;
	g_fPlayerLastTime[client] = -1.0;
	g_js_GroundFrames[client] = 0;
	g_fStartPauseTime[client] = 0.0;
	g_js_fJump_JumpOff_PosLastHeight[client] = -1.012345;
	g_js_Good_Sync_Frames[client] = 0.0;
	g_js_Sync_Frames[client] = 0.0;
	g_js_GODLIKE_Count[client] = 0;
	g_fPauseTime[client] = 0.0;
	g_MapRankTp[client] = 99999;
	g_MapRankPro[client] = 99999;
	g_OldMapRankPro[client] = 99999;
	g_OldMapRankTp[client] = 99999;
	g_fProfileMenuLastQuery[client] = GetEngineTime();
	g_PlayerRank[client] = 99999;
	g_fTeleportValidationTime[client] = GetEngineTime()-1.01;
	if (g_fTeleportValidationTime[client]  < 0.0)
		g_fTeleportValidationTime[client]  = 0.0;
	Format(g_szPlayerPanelText[client], 512, "");
	Format(g_pr_rankname[client], 32, "");
	Format(g_pr_chat_coloredrank[client], 32, "");
	Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>0.0 units</font>");
	for( new i = 0; i < CPLIMIT; i++ )
		g_fPlayerCords[client][i] = Float:{0.0,0.0,0.0};

	for(new i = 0; i < 30; i++ )
		g_aaiLastJumps[client][i] = -1;

	// Client options
	g_bInfoPanel[client]=false;
	g_bHideChat[client]=false;
	g_bClimbersMenuSounds[client]=true;
	g_EnableQuakeSounds[client]= 1;
	g_bShowNames[client]=true;
	g_bStrafeSync[client]=false;
	g_bGoToClient[client]=true;
	g_bShowTime[client]=true;
	g_bHide[client]=false;
	g_bCPTextMessage[client]=false;
	g_bStartWithUsp[client] = false;
	g_bAdvancedClimbersMenu[client]=true;
	g_ColorChat[client]=1;
	g_ShowSpecs[client]=0;
	g_bAutoBhopClient[client]=true;
	g_bJumpBeam[client]=false;
	g_bViewModel[client]=true;
	g_bAdvInfoPanel[client]=false;
	g_bReplayRoute[client]=false;
	g_ClientLang[client]= g_DefaultLanguage;
	g_bErrorSounds[client] = true;
}


// - Get Runtime -
public GetcurrentRunTime(client)
{
	decl String:szTime[32];
	decl Float:flPause, Float:flTime;
	if (g_bPause[client])
	{
		flPause = GetEngineTime() - g_fStartPauseTime[client];
		flTime =  GetEngineTime() - g_fStartTime[client] - flPause;
		FormatTimeFloat(client, flTime, 1,szTime,sizeof(szTime));
		Format(g_szTimerTitle[client], 255, "%s\n%s (PAUSE)", g_szPlayerPanelText[client],szTime);
	}
	else
	{
		g_fCurrentRunTime[client] = GetEngineTime() - g_fStartTime[client] - g_fPauseTime[client];
		FormatTimeFloat(client, g_fCurrentRunTime[client], 1,szTime,sizeof(szTime));
		if(g_bShowTime[client])
		{
			if(StrEqual(g_szPlayerPanelText[client],""))
				Format(g_szTimerTitle[client], 255, "%s", szTime);
			else
				Format(g_szTimerTitle[client], 255, "%s\n%s", g_szPlayerPanelText[client],szTime);
		}
		else
		{
			Format(g_szTimerTitle[client], 255, "%s", g_szPlayerPanelText[client]);
		}
	}
}

public Float:GetSpeed(client)
{
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	new Float:speed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
	return speed;
}


public Float:GetVelocity(client)
{
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	new Float:speed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0)+Pow(fVelocity[2],2.0));
	return speed;
}

public PlayOwnageSound(client)
{
	//decl String:buffer[255];
	/*for (new i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !IsFakeClient(i) && g_EnableQuakeSounds[i] >= 1 && i != client)
		{
			Format(buffer, sizeof(buffer), "play %s", OWNAGE_RELATIVE_SOUND_PATH);
			ClientCommand(i, buffer);
		}
	}*/
}

public PlayLeetJumpSound(client)
{
	decl String:buffer[255];

	//all sound
	if (g_js_GODLIKE_Count[client] == 3 || g_js_GODLIKE_Count[client] == 5)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i) && !IsFakeClient(i) && i != client && g_ColorChat[i] >= 1 && (g_EnableQuakeSounds[i] >= 1 && g_EnableQuakeSounds[i] <= 2))
			{
					if (g_js_GODLIKE_Count[client]==3)
					{
						Format(buffer, sizeof(buffer), "play %s", GODLIKE_RAMPAGE_RELATIVE_SOUND_PATH);
						ClientCommand(i, buffer);
					}
					else
						if (g_js_GODLIKE_Count[client]==5)
						{
							Format(buffer, sizeof(buffer), "play %s", GODLIKE_DOMINATING_RELATIVE_SOUND_PATH);
							ClientCommand(i, buffer);
						}
			}
		}
	}

	//client sound
	if 	(IsValidClient(client) && !IsFakeClient(client) && (g_EnableQuakeSounds[client] >= 1 && g_EnableQuakeSounds[client] <= 2))
	{
		if (g_js_GODLIKE_Count[client] != 3 && g_js_GODLIKE_Count[client] != 5 && g_EnableQuakeSounds[client])
		{
			Format(buffer, sizeof(buffer), "play %s", GODLIKE_RELATIVE_SOUND_PATH);
			ClientCommand(client, buffer);
		}
			else
			if (g_js_GODLIKE_Count[client]==3 && g_EnableQuakeSounds[client])
			{
				Format(buffer, sizeof(buffer), "play %s", GODLIKE_RAMPAGE_RELATIVE_SOUND_PATH);
				ClientCommand(client, buffer);
			}
			else
			if (g_js_GODLIKE_Count[client]==5 && g_EnableQuakeSounds[client])
			{
				Format(buffer, sizeof(buffer), "play %s", GODLIKE_DOMINATING_RELATIVE_SOUND_PATH);
				ClientCommand(client, buffer);
			}
	}
}

public PlayGoldenJumpSound(client)
{
	decl String:buffer[255];

	//all sound
	for (new i = 1; i <= MaxClients; i++)
	{
		if 	(IsValidClient(i) && !IsFakeClient(i) && i != client && g_ColorChat[i] >= 1 && (g_EnableQuakeSounds[i] >= 1 && g_EnableQuakeSounds[i] <= 2))
		{
			Format(buffer, sizeof(buffer), "play %s", GOLDEN_RELATIVE_SOUND_PATH);
			ClientCommand(i, buffer);
		}
	}

	//client sound
	if (IsValidClient(client) && !IsFakeClient(client) && (g_EnableQuakeSounds[client] >= 1 && g_EnableQuakeSounds[client] <= 2))
	{
		Format(buffer, sizeof(buffer), "play %s", GOLDEN_RELATIVE_SOUND_PATH);
		ClientCommand(client, buffer);
	}
}

public SetCashState()
{
	ServerCommand("mp_startmoney 0; mp_playercashawards 0; mp_teamcashawards 0");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
			SetEntProp(i, Prop_Send, "m_iAccount", 0);
	}
}

public PlayRecordSound(iRecordtype)
{
	decl String:buffer[255];
	if (iRecordtype==1)
	    for(new i = 1; i <= GetMaxClients(); i++)
		{
			if(IsValidClient(i) && !IsFakeClient(i) && g_EnableQuakeSounds[i] >= 1)
			{
				Format(buffer, sizeof(buffer), "play %s", PRO_RELATIVE_SOUND_PATH);
				ClientCommand(i, buffer);
			}
		}
	else
		if (iRecordtype==2 || iRecordtype == 3)
			for(new i = 1; i <= GetMaxClients(); i++)
			{
				if(IsValidClient(i) && !IsFakeClient(i) && g_EnableQuakeSounds[i] >= 1)
				{
					Format(buffer, sizeof(buffer), "play %s", CP_RELATIVE_SOUND_PATH);
					ClientCommand(i, buffer);
				}
			}
}

public InitPrecache()
{
	AddFileToDownloadsTable( UNSTOPPABLE_SOUND_PATH );
	FakePrecacheSound( UNSTOPPABLE_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( PRO_FULL_SOUND_PATH );
	FakePrecacheSound( PRO_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( CP_FULL_SOUND_PATH );
	FakePrecacheSound( CP_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( PRO_FULL_SOUND_PATH );
	FakePrecacheSound( PRO_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( GODLIKE_FULL_SOUND_PATH );
	FakePrecacheSound( GODLIKE_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( GODLIKE_DOMINATING_FULL_SOUND_PATH );
	FakePrecacheSound( GODLIKE_DOMINATING_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( GODLIKE_RAMPAGE_FULL_SOUND_PATH );
	FakePrecacheSound( GODLIKE_RAMPAGE_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( PERFECT_FULL_SOUND_PATH );
	FakePrecacheSound( PERFECT_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( IMPRESSIVE_FULL_SOUND_PATH );
	FakePrecacheSound( IMPRESSIVE_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( GOLDEN_FULL_SOUND_PATH ); // golden
	FakePrecacheSound( GOLDEN_RELATIVE_SOUND_PATH ); // golden
	AddFileToDownloadsTable("models/props/switch001.mdl");
	AddFileToDownloadsTable("models/props/switch001.vvd");
	AddFileToDownloadsTable("models/props/switch001.phy");
	AddFileToDownloadsTable("models/props/switch001.vtx");
	AddFileToDownloadsTable("models/props/switch001.dx90.vtx");
	AddFileToDownloadsTable("materials/models/props/switch.vmt");
	AddFileToDownloadsTable("materials/models/props/switch.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001_normal.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001_normal.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001_lightwarp.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001_lightwarp.vtf");
	AddFileToDownloadsTable("materials/models/props/switch001_exponent.vmt");
	AddFileToDownloadsTable("materials/models/props/switch001_exponent.vtf");
	AddFileToDownloadsTable("materials/models/props/startkztimer.vmt");
	AddFileToDownloadsTable("materials/models/props/startkztimer.vtf");
	AddFileToDownloadsTable("materials/models/props/stopkztimer.vmt");
	AddFileToDownloadsTable("materials/models/props/stopkztimer.vtf");
	AddFileToDownloadsTable("materials/sprites/bluelaser1.vmt");
	AddFileToDownloadsTable("materials/sprites/bluelaser1.vtf");
	AddFileToDownloadsTable("materials/sprites/laser.vmt");
	AddFileToDownloadsTable("materials/sprites/laser.vtf");
	AddFileToDownloadsTable("materials/sprites/halo01.vmt");
	AddFileToDownloadsTable("materials/sprites/halo01.vtf");
	AddFileToDownloadsTable(g_sArmModel);
	AddFileToDownloadsTable(g_sPlayerModel);
	AddFileToDownloadsTable(g_sReplayBotArmModel);
	AddFileToDownloadsTable(g_sReplayBotPlayerModel);
	AddFileToDownloadsTable(g_sReplayBotArmModel2);
	AddFileToDownloadsTable(g_sReplayBotPlayerModel2);
	g_Beam[0] = PrecacheModel("materials/sprites/laser.vmt", true);
	g_Beam[1] = PrecacheModel("materials/sprites/halo01.vmt", true);
	g_Beam[2] = PrecacheModel("materials/sprites/bluelaser1.vmt", true);
	g_BlueGlowSprite = PrecacheModel("sprites/blueglow1.vmt");
	PrecacheModel("materials/models/props/startkztimer.vmt",true);
	PrecacheModel("materials/models/props/stopkztimer.vmt",true);
	PrecacheModel("models/props/switch001.mdl",true);
	PrecacheModel(g_sReplayBotArmModel,true);
	PrecacheModel(g_sReplayBotPlayerModel,true);
	PrecacheModel(g_sReplayBotArmModel2,true);
	PrecacheModel(g_sReplayBotPlayerModel2,true);
	PrecacheModel(g_sArmModel,true);
	PrecacheModel(g_sPlayerModel,true);
}

// thx to V952 https://forums.alliedmods.net/showthread.php?t=212886
stock TraceClientViewEntity(client)
{
	new Float:m_vecOrigin[3];
	new Float:m_angRotation[3];
	GetClientEyePosition(client, m_vecOrigin);
	GetClientEyeAngles(client, m_angRotation);
	new Handle:tr = TR_TraceRayFilterEx(m_vecOrigin, m_angRotation, MASK_VISIBLE, RayType_Infinite, TRDontHitSelf, client);
	new pEntity = -1;
	if (TR_DidHit(tr))
	{
		pEntity = TR_GetEntityIndex(tr);
		CloseHandle(tr);
		return pEntity;
	}
	CloseHandle(tr);
	return -1;
}

// thx to V952 https://forums.alliedmods.net/showthread.php?t=212886
public bool:TRDontHitSelf(entity, mask, any:data)
{
	if (entity == data)
		return false;
	return true;
}

public PrintMapRecords(client)
{
	decl String:szTime[32];

	if (gB_KZTimerAPI)
	{
		KZTimerAPI_PrintGlobalRecord(client);
	}

	if (g_global_ValidedMap && g_global_IntegratedButtons && !g_global_VersionBlocked && !g_global_SelfBuiltButtons && g_hDbGlobal != INVALID_HANDLE && g_bEnforcer && g_global_ValidFileSize && !g_bAutoTimer)
	{
		if (g_fGlobalRecordPro_Time != 9999999.0)
		{
			FormatTimeFloat(client, g_fGlobalRecordPro_Time, 3,szTime,sizeof(szTime));
			switch(g_Server_Tickrate)
			{
				case 64: PrintToChat(client, "%t", "GlobalRecord1_Pro",MOSSGREEN,WHITE, DARKRED,WHITE, szTime, g_GlobalRecordPro_Name);
				case 102: PrintToChat(client, "%t", "GlobalRecord2_Pro",MOSSGREEN,WHITE,DARKRED,WHITE, szTime, g_GlobalRecordPro_Name);
				case 128: PrintToChat(client, "%t", "GlobalRecord3_Pro",MOSSGREEN,WHITE,DARKRED,WHITE, szTime, g_GlobalRecordPro_Name);
			}
		}

		if (g_fGlobalRecordTp_Time != 9999999.0)
		{
			FormatTimeFloat(client, g_fGlobalRecordTp_Time, 3,szTime,sizeof(szTime));
			switch(g_Server_Tickrate)
			{
				case 64: PrintToChat(client, "%t", "GlobalRecord1_Tp",MOSSGREEN,WHITE,RED,WHITE, szTime, g_GlobalRecordTp_Name);
				case 102: PrintToChat(client, "%t", "GlobalRecord2_Tp",MOSSGREEN,WHITE,RED,WHITE, szTime, g_GlobalRecordTp_Name);
				case 128: PrintToChat(client, "%t", "GlobalRecord3_Tp",MOSSGREEN,WHITE,RED,WHITE, szTime, g_GlobalRecordTp_Name);
			}
		}
	}

	if (g_fRecordTimePro != 9999999.0)
	{
		FormatTimeFloat(client, g_fRecordTimePro, 3,szTime,sizeof(szTime));
		PrintToChat(client, "%t", "ProRecord",MOSSGREEN,WHITE,DARKBLUE,WHITE, szTime, g_szRecordPlayerPro);
	}
	if (g_fRecordTime != 9999999.0)
	{
		FormatTimeFloat(client, g_fRecordTime, 3,szTime,sizeof(szTime));
		PrintToChat(client, "%t", "TpRecord",MOSSGREEN,WHITE,YELLOW,WHITE, szTime, g_szRecordPlayer);
	}
}

public PrintMapTier(client)
{
	if (g_hDbGlobal == INVALID_HANDLE)
		PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cNo connection to database (Server most likely not global)%c", MOSSGREEN, WHITE, BLUE, WHITE, RED, WHITE);

	else if (!g_global_ValidedMap)
		PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cCurrent map is not global%c", MOSSGREEN, WHITE, BLUE, WHITE, RED, WHITE);

	else if (g_global_maptier <= 0 && g_global_ValidedMap)
		PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cCurrent map does not have a tier%c", MOSSGREEN, WHITE, BLUE, WHITE, RED, WHITE);

	else
	{

	switch (g_global_maptier)
	{
   	case 1:
		PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cVery Easy%c (See %c!tierhelp %cfor more info)", MOSSGREEN, WHITE, BLUE, WHITE, GREEN, WHITE, GREEN, WHITE);
	case 2:
		PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cEasy%c (See %c!tierhelp %cfor more info)", MOSSGREEN, WHITE, BLUE, WHITE, LIMEGREEN, WHITE, GREEN, WHITE);
	case 3:
	    PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cMedium%c (See %c!tierhelp %cfor more info)", MOSSGREEN, WHITE, BLUE, WHITE, MOSSGREEN, WHITE, GREEN, WHITE);
	case 4:
	    PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cHard%c (See %c!tierhelp %cfor more info)", MOSSGREEN, WHITE, BLUE, WHITE, ORANGE, WHITE, GREEN, WHITE);
	case 5:
	    PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cVery Hard%c (See %c!tierhelp %cfor more info)", MOSSGREEN, WHITE, BLUE, WHITE, DARKRED, WHITE, GREEN, WHITE);
	case 6:
		PrintToChat(client, "[%cKZ%c] %cMap Tier%c: %cDeath%c (See %c!tierhelp %cfor more info)", MOSSGREEN, WHITE, BLUE, WHITE, RED, WHITE, GREEN, WHITE);
		}
	}
	return;
}

public MapFinishedMsgs(client, type)
{
	if (IsValidClient(client))
	{
		decl String:szTime[32];
		decl String:szName[MAX_NAME_LENGTH];
		GetClientName(client, szName, MAX_NAME_LENGTH);
		new count;
		new rank;
		if (type==1)
		{
			count = g_MapTimesCountPro;
			rank = g_MapRankPro[client];
			FormatTimeFloat(client, g_fRecordTimePro, 3, szTime, sizeof(szTime));
		}
		else
		if (type==0)
		{
			count = g_MapTimesCountTp;
			rank = g_MapRankTp[client];
			FormatTimeFloat(client, g_fRecordTime, 3, szTime, sizeof(szTime));
		}
		for(new i = 1; i <= GetMaxClients(); i++)
		{
			if(IsValidClient(i) && !IsFakeClient(i))
			{
				if (g_Time_Type[client] == 0)
				{
					PrintToChat(i, "%t", "MapFinished0",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW,GRAY,  LIMEGREEN, g_szFinalTime[client],GRAY,LIMEGREEN,g_Tp_Final[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,szTime,WHITE);
					PrintToConsole(i, "%s finished with a TP TIME of (%s, TP's: %i). [rank #%i/%i | record %s]",szName,g_szFinalTime[client],g_Tp_Final[client],rank,count,szTime);
				}
				else
				if (g_Time_Type[client] == 1)
				{
					PrintToChat(i, "%t", "MapFinished1",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,DARKBLUE,GRAY,LIMEGREEN, g_szFinalTime[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,szTime,WHITE);
					PrintToConsole(i, "%s finished with a PRO TIME of (%s). [rank #%i/%i | record %s]",szName,g_szFinalTime[client],rank,count,szTime);
				}
				else
					if (g_Time_Type[client] == 2)
					{
						PrintToChat(i, "%t", "MapFinished2",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW,GRAY,LIMEGREEN, g_szFinalTime[client],GRAY,LIMEGREEN,g_Tp_Final[client],GRAY,GREEN, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,szTime,WHITE);
						PrintToConsole(i, "%s finished with a TP TIME of (%s, TP's: %i). Improving their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szFinalTime[client],g_Tp_Final[client],g_szTimeDifference[client],rank,count,szTime);
					}
					else
						if (g_Time_Type[client] == 3)
						{
							PrintToChat(i, "%t", "MapFinished3",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,DARKBLUE,GRAY,LIMEGREEN, g_szFinalTime[client],GRAY,GREEN, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,szTime,WHITE);
							PrintToConsole(i, "%s finished with a PRO TIME of (%s). Improving their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szFinalTime[client],g_szTimeDifference[client],rank,count,szTime);
						}
						else
							if (g_Time_Type[client] == 4)
							{
								PrintToChat(i, "%t", "MapFinished4",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW,GRAY,LIMEGREEN, g_szFinalTime[client],GRAY,LIMEGREEN,g_Tp_Final[client],GRAY,RED, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,szTime,WHITE);
								PrintToConsole(i, "%s finished with a TP TIME of (%s, TP's: %i). Missing their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szFinalTime[client],g_Tp_Final[client],g_szTimeDifference[client],rank,count,szTime);
							}
							else
								if (g_Time_Type[client] == 5)
								{
									PrintToChat(i, "%t", "MapFinished5",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,DARKBLUE,GRAY,LIMEGREEN, g_szFinalTime[client],GRAY,RED, g_szTimeDifference[client],GRAY, WHITE, LIMEGREEN, rank, WHITE,count,LIMEGREEN,szTime,WHITE);
									PrintToConsole(i, "%s finished with a PRO TIME of (%s). Missing their best time by (%s).  [rank #%i/%i | record %s]",szName,g_szFinalTime[client],g_szTimeDifference[client],rank,count,szTime);
								}

				//new record msg
				switch(g_FinishingType[client])
				{
					case 4:
					{
						switch(g_Server_Tickrate)
						{
							case 64:
							{
								PrintToChat(i, "%t", "NewGlobalRecord64_Tp",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,RED);
								PrintToConsole(i, "[KZ] %s has beaten the GLOBAL TP RECORD (64)",szName);
							}
							case 102:
							{
								PrintToChat(i, "%t", "NewGlobalRecord102_Tp",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,RED);
								PrintToConsole(i, "[KZ] %s has beaten the GLOBAL TP RECORD (102)",szName);
							}
							case 128:
							{
								PrintToChat(i, "%t", "NewGlobalRecord128_Tp",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,RED);
								PrintToConsole(i, "[KZ] %s has beaten the GLOBAL TP RECORD",szName);
							}
						}
					}
					case 3:
					{
						switch(g_Server_Tickrate)
						{
							case 64:
							{
								PrintToChat(i, "%t", "NewGlobalRecord64_Pro",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,DARKRED);
								PrintToConsole(i, "[KZ] %s has beaten the GLOBAL PRO RECORD (64)",szName);
							}
							case 102:
							{
								PrintToChat(i, "%t", "NewGlobalRecord102_Pro",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,DARKRED);
								PrintToConsole(i, "[KZ] %s has beaten the GLOBAL PRO RECORD (102)",szName);
							}
							case 128:
							{
								PrintToChat(i, "%t", "NewGlobalRecord128_Pro",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,DARKRED);
								PrintToConsole(i, "[KZ] %s has beaten the GLOBAL PRO RECORD",szName);
							}
						}
					}
					case 2:
					{
						PrintToChat(i, "%t", "NewProRecord",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,DARKBLUE);
						PrintToConsole(i, "[KZ] %s has beaten the PRO RECORD",szName);
					}
					case 1:
					{
						PrintToChat(i, "%t", "NewTpRecord",MOSSGREEN,WHITE,LIMEGREEN,szName,GRAY,YELLOW);
						PrintToConsole(i, "[KZ] %s has beaten the TP RECORD",szName);
					}
				}
			}
		}

		if (rank==99999 && IsValidClient(client))
			PrintToChat(client, "[%cKZ%c] %cFailed to save your data correctly! Please contact an admin.",MOSSGREEN,WHITE,DARKRED,RED,DARKRED);
		else
		{
			Call_StartForward(g_hFWD_TimerStoppedValid);
			Call_PushCell(client);
			Call_PushCell(g_Tp_Final[client]);
			Call_PushCell(rank);
			Call_PushFloat(g_fFinalTime[client]);
			Call_Finish();
		}

		//noclip MsgMsg
		if (IsValidClient(client) && g_bMapFinished[client] == false && !StrEqual(g_pr_rankname[client],g_szSkillGroups[8]) && !(GetUserFlagBits(client) & ADMFLAG_RESERVATION) && !(GetUserFlagBits(client) & ADMFLAG_ROOT) && !(GetUserFlagBits(client) & ADMFLAG_GENERIC) && g_bNoClipS)
			PrintToChat(client, "%t", "NoClipUnlocked",MOSSGREEN,WHITE,YELLOW);
		g_bMapFinished[client] = true;
		CreateTimer(0.0, UpdatePlayerProfile, client,TIMER_FLAG_NO_MAPCHANGE);

		if (g_Time_Type[client] == 0 || g_Time_Type[client] == 1 || g_Time_Type[client] == 2 || g_Time_Type[client] == 3)
			CheckMapRanks(client, g_Tp_Final[client]);
	}
	//recalc avg
	db_CalcAvgRunTime();

	//sound all
	PlayRecordSound(g_Sound_Type[client]);

	//sound Client
	if (g_Sound_Type[client] == 5)
		PlayUnstoppableSound(client);
}

public CheckMapRanks(client, tps)
{
	for (new i = 1; i <= MaxClients; i++)
	if (IsValidClient(i) && !IsFakeClient(i) && i != client)
	{
		if (tps > 0)
		{
			if (g_OldMapRankTp[client] > g_MapRankTp[client] && g_OldMapRankTp[client] > g_MapRankTp[i] && g_MapRankTp[client] <= g_MapRankTp[i])
				g_MapRankTp[i]++;
		}
		else
		{
			if (g_OldMapRankPro[client] < g_MapRankPro[client] && g_OldMapRankPro[client] > g_MapRankPro[i] && g_MapRankPro[client] <= g_MapRankPro[i])
				g_MapRankPro[i]++;
		}
	}
}

public ReplaceChar(String:sSplitChar[], String:sReplace[], String:sString[64])
{
	StrCat(sString, sizeof(sString), " ");
	new String:sBuffer[16][256];
	ExplodeString(sString, sSplitChar, sBuffer, sizeof(sBuffer), sizeof(sBuffer[]));
	strcopy(sString, sizeof(sString), "");
	for (new i = 0; i < sizeof(sBuffer); i++)
	{
		if (strcmp(sBuffer[i], "") == 0)
			continue;
		if (i != 0)
		{
			decl String:sTmpStr[256];
			Format(sTmpStr, sizeof(sTmpStr), "%s%s", sReplace, sBuffer[i]);
			StrCat(sString, sizeof(sString), sTmpStr);
		}
		else
		{
			StrCat(sString, sizeof(sString), sBuffer[i]);
		}
	}
}

public FormatTimeFloat(client, Float:time, type, String:string[], length)
{
	if (!IsValidClient(client))
		return;
	decl String:szMilli[16];
	decl String:szSeconds[16];
	decl String:szMinutes[16];
	decl String:szHours[16];
	decl String:szMilli2[16];
	decl String:szSeconds2[16];
	decl String:szMinutes2[16];
	new imilli;
	new imilli2;
	new iseconds;
	new iminutes;
	new ihours;
	time = FloatAbs(time);
	imilli = RoundToZero(time*100);
	imilli2 = RoundToZero(time*10);
	imilli = imilli%100;
	imilli2 = imilli2%10;
	iseconds = RoundToZero(time);
	iseconds = iseconds%60;
	iminutes = RoundToZero(time/60);
	iminutes = iminutes%60;
	ihours = RoundToZero((time/60)/60);

	if (imilli < 10)
		Format(szMilli, 16, "0%dms", imilli);
	else
		Format(szMilli, 16, "%dms", imilli);
	if (iseconds < 10)
		Format(szSeconds, 16, "0%ds", iseconds);
	else
		Format(szSeconds, 16, "%ds", iseconds);
	if (iminutes < 10)
		Format(szMinutes, 16, "0%dm", iminutes);
	else
		Format(szMinutes, 16, "%dm", iminutes);


	Format(szMilli2, 16, "%d", imilli2);
	if (iseconds < 10)
		Format(szSeconds2, 16, "0%d", iseconds);
	else
		Format(szSeconds2, 16, "%d", iseconds);
	if (iminutes < 10)
		Format(szMinutes2, 16, "0%d", iminutes);
	else
		Format(szMinutes2, 16, "%d", iminutes);
	//Time: 00m 00s 00ms
	if (type==0)
	{
		Format(szHours, 16, "%dm", iminutes);
		if (ihours>0)
		{
			Format(szHours, 16, "%d", ihours);
			if (g_bClimbersMenuOpen[client])
			{
				if (g_bAdvancedClimbersMenu[client])
					Format(string, length, "Time: %s:%s:%s.%s", szHours, szMinutes2,szSeconds2,szMilli2);
				else
					Format(string, length, "%s:%s:%s.%s", szHours, szMinutes2,szSeconds2,szMilli2);
			}
			else
				Format(string, length, "%s:%s:%s.%s", szHours, szMinutes2,szSeconds2,szMilli2);
		}
		else
		{
			if (g_bClimbersMenuOpen[client])
			{
				if (g_bAdvancedClimbersMenu[client])
					Format(string, length, "Time: %s:%s.%s", szMinutes2,szSeconds2,szMilli2);
				else
					Format(string, length, "%s:%s.%s", szMinutes2,szSeconds2,szMilli2);
			}
			else
				Format(string, length, "%s:%s.%s", szMinutes2,szSeconds2,szMilli2);
		}
	}
	//00m 00s 00ms
	if (type==1)
	{
		Format(szHours, 16, "%dm", iminutes);
		if (ihours>0)
		{
			Format(szHours, 16, "%dh", ihours);
			Format(string, length, "%s %s %s %s", szHours, szMinutes,szSeconds,szMilli);
		}
		else
			Format(string, length, "%s %s %s", szMinutes,szSeconds,szMilli);
	}
	else
	//00h 00m 00s 00ms
	if (type==2)
	{
		imilli = RoundToZero(time*1000);
		imilli = imilli%1000;
		if (imilli < 10)
			Format(szMilli, 16, "00%dms", imilli);
		else
		if (imilli < 100)
			Format(szMilli, 16, "0%dms", imilli);
		else
			Format(szMilli, 16, "%dms", imilli);
		Format(szHours, 16, "%dh", ihours);
		Format(string, 32, "%s %s %s %s",szHours, szMinutes,szSeconds,szMilli);
	}
	else
	//00:00:00
	if (type==3)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);
		if (ihours>0)
		{
			Format(szHours, 16, "%d", ihours);
			Format(string, length, "%s:%s:%s.%s", szHours, szMinutes,szSeconds,szMilli);
		}
		else
			Format(string, length, "%s:%s.%s", szMinutes,szSeconds,szMilli);
	}
	//Time: 00:00:00
	if (type==4)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);
		if (ihours>0)
		{
			Format(szHours, 16, "%d", ihours);
			Format(string, length, "Time: %s:%s:%s", szHours, szMinutes,szSeconds);
		}
		else
			Format(string, length, "Time: %s:%s", szMinutes,szSeconds);
	}
	if (type==5)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);
		if (ihours>0)
		{
			Format(szHours, 16, "%d", ihours);
			Format(string, length, "Timeleft: %s:%s:%s", szHours, szMinutes,szSeconds);
		}
		else
			Format(string, length, "Timeleft: %s:%s", szMinutes,szSeconds);
	}
}


public SetPlayerRank(client)
{
	if (!IsValidClient(client) || IsFakeClient(client) || g_pr_Calculating[client])
		return;
	if (g_bPointSystem)
	{
		if (g_pr_points[client] < g_pr_rank_Percentage[1])
		{
			g_Skillgroup[client] = 1;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[0]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",WHITE,g_szSkillGroups[0],WHITE);
		}
		else
		if (g_pr_rank_Percentage[1] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[2])
		{
			g_Skillgroup[client] = 2;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[1]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",WHITE,g_szSkillGroups[1],WHITE);
		}
		else
		if (g_pr_rank_Percentage[2] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[3])
		{
			g_Skillgroup[client] = 3;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[2]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",GRAY,g_szSkillGroups[2],WHITE);
		}
		else
		if (g_pr_rank_Percentage[3] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[4])
		{
			g_Skillgroup[client] = 4;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[3]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",LIGHTBLUE,g_szSkillGroups[3],WHITE);
		}
		else
		if (g_pr_rank_Percentage[4] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[5])
		{
			g_Skillgroup[client] = 5;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[4]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",BLUE,g_szSkillGroups[4],WHITE);
		}
		else
		if (g_pr_rank_Percentage[5] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[6])
		{
			g_Skillgroup[client] = 6;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[5]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",DARKBLUE,g_szSkillGroups[5],WHITE);
		}
		else
		if (g_pr_rank_Percentage[6] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[7])
		{
			g_Skillgroup[client] = 7;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[6]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",PINK,g_szSkillGroups[6],WHITE);
		}
		else
		if (g_pr_rank_Percentage[7] <= g_pr_points[client] && g_pr_points[client] < g_pr_rank_Percentage[8])
		{
			g_Skillgroup[client] = 8;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[7]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",LIGHTRED,g_szSkillGroups[7],WHITE);
		}
		else
		if (g_pr_points[client] >= g_pr_rank_Percentage[8])
		{
			g_Skillgroup[client] = 9;
			Format(g_pr_rankname[client], 32, "%s",g_szSkillGroups[8]);
			Format(g_pr_chat_coloredrank[client], 32, "[%c%s%c]",DARKRED,g_szSkillGroups[8],WHITE);
		}
	}
	else
	{
		g_Skillgroup[client] = 0;
		Format(g_pr_rankname[client], 32, "");
	}


	// DEV Tags -- 1NutWunder, Klyve & Sikari
	if (StrEqual(g_szSteamID[client],"STEAM_1:1:73507922") ||	// 1NutWunder
		StrEqual(g_szSteamID[client],"STEAM_1:0:36685029") ||	// Klyve
		StrEqual(g_szSteamID[client],"STEAM_1:1:21505111") ||	// Sikari
		StrEqual(g_szSteamID[client],"STEAM_1:0:102468802"))	// GameChaos
		{
			Format(g_pr_chat_coloredrank[client], 32, "%s %cDEV%c",g_pr_chat_coloredrank[client],RED,WHITE);
			
			if (g_bAdminClantag && CheckCommandAccess(client, "", ADMFLAG_GENERIC))
			{
				Format(g_pr_rankname[client], 32, "ADMIN");
			}
			
			else if (g_bVipClantag && CheckCommandAccess(client, "", ADMFLAG_RESERVATION))
			{
				Format(g_pr_rankname[client], 32, "VIP");
			}
			
			return;
		}

	// GLOBAL Tags
	if (StrEqual(g_szSteamID[client],"STEAM_1:0:16599865")	||	// Chuckles
		StrEqual(g_szSteamID[client],"STEAM_1:0:8845346")	||	// Zpamm
		StrEqual(g_szSteamID[client],"STEAM_1:1:21505111")	||	// Sikari
		StrEqual(g_szSteamID[client],"STEAM_1:0:79951525"))		// Ruto
		{
			Format(g_pr_chat_coloredrank[client], 32, "%s %cGLOBAL%c",g_pr_chat_coloredrank[client],DARKRED,WHITE);
			
			if (g_bAdminClantag && CheckCommandAccess(client, "", ADMFLAG_GENERIC))
			{
				Format(g_pr_rankname[client], 32, "ADMIN");
			}
			
			else if (g_bVipClantag && CheckCommandAccess(client, "", ADMFLAG_RESERVATION))
			{
				Format(g_pr_rankname[client], 32, "VIP");
			}
			
			return;
		}
	
	//ADMIN tag
	if (g_bAdminClantag && CheckCommandAccess(client, "", ADMFLAG_GENERIC))
	{
		Format(g_pr_chat_coloredrank[client], 32, "%s %cADMIN%c",g_pr_chat_coloredrank[client],LIMEGREEN,WHITE);
		Format(g_pr_rankname[client], 32, "ADMIN");
	}
	// VIP tag
	else if (g_bVipClantag && CheckCommandAccess(client, "", ADMFLAG_RESERVATION))
	{
		Format(g_pr_chat_coloredrank[client], 32, "%s %cVIP%c",g_pr_chat_coloredrank[client],YELLOW,WHITE);
		Format(g_pr_rankname[client], 32, "VIP");
	}

  // Mapper tag
  for(new x = 0; x < 100; x++)
	{
		if ((StrContains(g_szMapmakers[x],"STEAM",true) != -1))
		{
			if (StrEqual(g_szMapmakers[x],g_szSteamID[client]))
			{
				Format(g_pr_chat_coloredrank[client], 32, "%s %cMAPPER%c",g_pr_chat_coloredrank[client],LIMEGREEN,WHITE);
				Format(g_pr_rankname[client], 32, "MAPPER");
				break;
			}
		}
	}
}

stock Action:PrintSpecMessageAll(client)
{
	decl String:szName[32];
	GetClientName(client, szName, sizeof(szName));
	ReplaceString(szName,32,"{darkred}","",false);
	ReplaceString(szName,32,"{green}","",false);
	ReplaceString(szName,32,"{lightgreen}","",false);
	ReplaceString(szName,32,"{blue}","",false);
	ReplaceString(szName,32,"{olive}","",false);
	ReplaceString(szName,32,"{lime}","",false);
	ReplaceString(szName,32,"{red}","",false);
	ReplaceString(szName,32,"{purple}","",false);
	ReplaceString(szName,32,"{grey}","",false);
	ReplaceString(szName,32,"{yellow}","",false);
	ReplaceString(szName,32,"{lightblue}","",false);
	ReplaceString(szName,32,"{steelblue}","",false);
	ReplaceString(szName,32,"{darkblue}","",false);
	ReplaceString(szName,32,"{pink}","",false);
	ReplaceString(szName,32,"{lightred}","",false);
	decl String:szTextToAll[1024];
	GetCmdArgString(szTextToAll, sizeof(szTextToAll));
	StripQuotes(szTextToAll);
	if (StrEqual(szTextToAll,"") || StrEqual(szTextToAll," ") || StrEqual(szTextToAll,"  "))
		return Plugin_Handled;

	ReplaceString(szTextToAll,1024,"{darkred}","",false);
	ReplaceString(szTextToAll,1024,"{green}","",false);
	ReplaceString(szTextToAll,1024,"{lightgreen}","",false);
	ReplaceString(szTextToAll,1024,"{blue}","",false);
	ReplaceString(szTextToAll,1024,"{olive}","",false);
	ReplaceString(szTextToAll,1024,"{lime}","",false);
	ReplaceString(szTextToAll,1024,"{red}","",false);
	ReplaceString(szTextToAll,1024,"{purple}","",false);
	ReplaceString(szTextToAll,1024,"{grey}","",false);
	ReplaceString(szTextToAll,1024,"{yellow}","",false);
	ReplaceString(szTextToAll,1024,"{lightblue}","",false);
	ReplaceString(szTextToAll,1024,"{steelblue}","",false);
	ReplaceString(szTextToAll,1024,"{darkblue}","",false);
	ReplaceString(szTextToAll,1024,"{pink}","",false);
	ReplaceString(szTextToAll,1024,"{lightred}","",false);
	Color_StripFromChatText(szTextToAll, szTextToAll, sizeof(szTextToAll));

	//text right to left?
	decl String:sTextNew[1024];
	if(RTLify(sTextNew, szTextToAll))
		FormatEx(szTextToAll, 1024, sTextNew);

	decl String:szChatRank[64];
	Format(szChatRank, 64, "%s",g_pr_chat_coloredrank[client]);

	if (g_bCountry && (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag)))
		CPrintToChatAll("{green}%s{default} %s *SPEC* {grey}%s{default}: %s",g_szCountryCode[client], szChatRank, szName,szTextToAll);
	else
		if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
			CPrintToChatAll("%s *SPEC* {grey}%s{default}: %s", szChatRank,szName,szTextToAll);
		else
			if (g_bCountry)
				CPrintToChatAll("[{green}%s{default}] *SPEC* {grey}%s{default}: %s", g_szCountryCode[client],szName, szTextToAll);
			else
				CPrintToChatAll("*SPEC* {grey}%s{default}: %s", szName, szTextToAll);
	for (new i = 1; i <= MaxClients; i++)
		if (IsValidClient(i))
		{
			if (g_bCountry && (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag)))
				PrintToConsole(i, "%s [%s] *SPEC* %s: %s", g_szCountryCode[client],g_pr_rankname[client],szName, szTextToAll);
			else
				if (g_bPointSystem || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && g_bAdminClantag) || ((StrEqual(g_pr_rankname[client], "VIP", false)) && g_bVipClantag))
					PrintToConsole(i, "[%s] *SPEC* %s: %s", g_szCountryCode[client],szName, szTextToAll);
				else
					if (g_bPointSystem)
						PrintToConsole(i, "[%s] *SPEC* %s: %s", g_pr_rankname[client],szName, szTextToAll);
						else
							PrintToConsole(i, "*SPEC* %s: %s", szName, szTextToAll);
		}
	return Plugin_Handled;
}

public LjBlockCheck(client, Float:origin[3])
{
	if(g_bLJBlock[client])
	{
		TE_SendBlockPoint(client, g_fDestBlock[client][0], g_fDestBlock[client][1], g_Beam[0]);
		TE_SendBlockPoint(client, g_fOriginBlock[client][0], g_fOriginBlock[client][1], g_Beam[0]);
	}

	if (g_bOnGround[client])
	{
		//LJBlock Stuff
		if (!g_js_bPlayerJumped[client])
		{
			decl Float:temp[3];
			if(g_bLJBlock[client])
			{
				g_js_block_lj_valid[client]=true;
				g_js_block_lj_jumpoff_pos[client]=false;
				if(IsCoordInBlockPoint(origin,g_fDestBlock[client],false))
				{
					//block2
					GetEdgeOrigin2(client, origin, temp);
					g_fEdgeDistJumpOff[client] = GetVectorDistance(temp, origin);
					g_js_block_lj_jumpoff_pos[client]=true;
				}
				else
					if (IsCoordInBlockPoint(origin,g_fOriginBlock[client],false))
					{
						//block1
						GetEdgeOrigin1(client, origin, temp);
						g_fEdgeDistJumpOff[client] = GetVectorDistance(temp, origin);
						g_js_block_lj_jumpoff_pos[client]=false;
					}
					else
						g_js_block_lj_valid[client] = false;
			}
			else
				g_js_block_lj_valid[client] = false;
		}
	}
}

public AttackProtection(client, &buttons)
{
	if (g_bAttackSpamProtection && !IsFakeClient(client))
	{
		decl String:classnamex[64];
		GetClientWeapon(client, classnamex, 64);
		if(StrContains(classnamex,"knife",true) == -1 && g_AttackCounter[client] >= 40)
		{
			if(buttons & IN_ATTACK)
			{
				decl ent;
				ent = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
				if (IsValidEntity(ent))
					SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
			}
		}
	}
}

public StrToLower(String:arg[])
{
	for (new i = 0; i < strlen(arg); i++)
	{
		arg[i] = CharToLower(arg[i]);
	}
}


//http://pastebin.com/YdUWS93H
public bool:CheatFlag(const String:voice_inputfromfile[], bool:isCommand, bool:remove)
{
	if(remove)
	{
		if (!isCommand)
		{
			new Handle:hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != INVALID_HANDLE)
			{
				new flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags &= ~FCVAR_CHEAT);
				CloseHandle(hConVar);
				return true;
			}
			else
			{
				CloseHandle(hConVar);
				return false;
			}
		}
		else
		{
			new flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags &= ~FCVAR_CHEAT))
				return true;
			else
				return false;
		}
	}
	else
	{
		if (!isCommand)
		{
			new Handle:hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != INVALID_HANDLE)
			{
				new flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags & FCVAR_CHEAT);
				CloseHandle(hConVar);
				return true;
			}
			else
			{
				CloseHandle(hConVar);
				return false;
			}


		} else
		{
			new flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags & FCVAR_CHEAT))
				return true;
			else
				return false;

		}
	}
}

public PlayerPanel(client)
{
	if (!IsValidClient(client) || g_bMapMenuOpen[client] || g_bTopMenuOpen[client] || IsFakeClient(client))
		return;

	if (GetClientMenu(client) == MenuSource_None)
	{
		g_bMenuOpen[client] = false;
		g_bClimbersMenuOpen[client] = false;
	}
	if (g_bMenuOpen[client] || g_bClimbersMenuOpen[client])
		return;
	if (g_bTimeractivated[client])
	{
		GetcurrentRunTime(client);
		if(!StrEqual(g_szTimerTitle[client],""))
		{
			new Handle:panel = CreatePanel();
			DrawPanelText(panel, g_szTimerTitle[client]);
			SendPanelToClient(panel, client, PanelHandler, 1);
			CloseHandle(panel);
		}
	}
	else
	{
		decl String:szTmp[255];
		new Handle:panel = CreatePanel();
		if(!StrEqual(g_szPlayerPanelText[client],""))
			Format(szTmp, 255, "%s\nSpeed: %.1f u/s",g_szPlayerPanelText[client],GetSpeed(client));
		else
			Format(szTmp, 255, "Speed: %.1f u/s",GetSpeed(client));

		DrawPanelText(panel, szTmp);
		SendPanelToClient(panel, client, PanelHandler, 1);
		CloseHandle(panel);

	}
}

public GetRGBColor(bot, String:color[256])
{
	decl String:sPart[4];
	new iFirstSpace = FindCharInString(color, ' ', false) + 1;
	new iLastSpace  = FindCharInString(color, ' ', true) + 1;
	strcopy(sPart, iFirstSpace, color);
	if (bot==1)
		g_ReplayBotTpColor[0] = StringToInt(sPart);
	else
		g_ReplayBotProColor[0] = StringToInt(sPart);
	strcopy(sPart, iLastSpace - iFirstSpace, color[iFirstSpace]);
	if (bot==1)
		g_ReplayBotTpColor[1] = StringToInt(sPart);
	else
		g_ReplayBotProColor[1] = StringToInt(sPart);
	strcopy(sPart, strlen(color) - iLastSpace + 1, color[iLastSpace]);
	if (bot==1)
		g_ReplayBotTpColor[2] = StringToInt(sPart);
	else
		g_ReplayBotProColor[2] = StringToInt(sPart);
}

public SpecList(client)
{
	if (!IsValidClient(client) || g_bMapMenuOpen[client] || g_bTopMenuOpen[client]  || IsFakeClient(client) || IsPlayerAlive(client))
		return;

	if (GetClientMenu(client) == MenuSource_None)
	{
		g_bMenuOpen[client] = false;
		g_bClimbersMenuOpen[client] = false;
	}
	if (g_bTimeractivated[client] && !g_bSpectate[client])
		return;
	if (g_bMenuOpen[client] || g_bClimbersMenuOpen[client])
		return;
	if(!StrEqual(g_szPlayerPanelText[client],""))
	{
		new Handle:panel = CreatePanel();
		DrawPanelText(panel, g_szPlayerPanelText[client]);
		SendPanelToClient(panel, client, PanelHandler, 1);
		CloseHandle(panel);
	}
}

public PanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
}

public bool TraceRayDontHitSelfSlope(int entity, int mask, any data)
{
	return entity != data && !(0 < entity <= MaxClients);
}

////https://forums.alliedmods.net/showthread.php?t=266888
public SlopeBoostFix(client)
{
	g_bLastOnGround[client] = g_bOnGround[client];
	g_vLast[client][0]    = g_vCurrent[client][0];
	g_vLast[client][1]    = g_vCurrent[client][1];
	g_vLast[client][2]    = g_vCurrent[client][2];
	g_vCurrent[client][0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	g_vCurrent[client][1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	g_vCurrent[client][2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

	// Check if player landed on the ground
	if (g_bOnGround[client] == true && g_bLastOnGround[client] == false)
	{
		// Set up and do tracehull to find out if the player landed on a slope
		float vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);

		float vMins[3];
		GetEntPropVector(client, Prop_Send, "m_vecMins", vMins);

		float vMaxs[3];
		GetEntPropVector(client, Prop_Send, "m_vecMaxs", vMaxs);

		float vEndPos[3];
		vEndPos[0] = vPos[0];
		vEndPos[1] = vPos[1];
		vEndPos[2] = vPos[2] - FindConVar("sv_maxvelocity").FloatValue;

		TR_TraceHullFilter(vPos, vEndPos, vMins, vMaxs, MASK_PLAYERSOLID_BRUSHONLY, TraceRayDontHitSelfSlope, client);

		if(TR_DidHit())
		{
			// Gets the normal vector of the surface under the player
			float vPlane[3], vLast[3];
			TR_GetPlaneNormal(INVALID_HANDLE, vPlane);

			// Make sure it's not flat ground and not a surf ramp (1.0 = flat ground, < 0.7 = surf ramp)
			if(0.7 <= vPlane[2] && vPlane[2] < 1.0)
			{
				/*
				Copy the ClipVelocity function from sdk2013
				(https://mxr.alliedmods.net/hl2sdk-sdk2013/source/game/shared/gamemovement.cpp#3145)
				With some minor changes to make it actually work
				*/
				vLast[0]  = g_vLast[client][0];
				vLast[1]  = g_vLast[client][1];
				vLast[2]  = g_vLast[client][2];
				vLast[2] -= (FindConVar("sv_gravity").FloatValue * GetTickInterval() * 0.5);

				float fBackOff = GetVectorDotProduct(vLast, vPlane);

				float change, vVel[3];
				for(int i; i < 2; i++)
				{
					change  = vPlane[i] * fBackOff;
					vVel[i] = vLast[i] - change;
				}

				float fAdjust = GetVectorDotProduct(vVel, vPlane);
				if(fAdjust < 0.0)
				{
					for(int i; i < 2; i++)
					{
						vVel[i] -= (vPlane[i] * fAdjust);
					}
				}

				vVel[2] = 0.0;
				vLast[2] = 0.0;

				// Make sure the player is going down a ramp by checking if they actually will gain speed from the boost
				if(GetVectorLength(vVel) > GetVectorLength(vLast))
				{
					// Teleport the player, also adds basevelocity
					if(GetEntityFlags(client) & FL_BASEVELOCITY)
					{
						float vBase[3];
						GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", vBase);

						AddVectors(vVel, vBase, vVel);
					}

					DoValidTeleport(client, NULL_VECTOR, NULL_VECTOR, vVel);
				}
			}
		}
	}
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	return (entity != data);
}

stock bool:IntoBool(status)
{
	if(status > 0)
		return true;
	else
		return false;
}

stock BooltoInt(bool:status)
{
	if(status)
		return 1;
	else
		return 0;
}

public PlayQuakeSound_Spec(client, String:buffer[255])
{
	new SpecMode;
	new bool:god;
	if (StrEqual("play *quake/godlike.mp3", buffer) ||
		StrEqual("play *quake/rampage.mp3", buffer) ||
		StrEqual("play *quake/dominating.mp3", buffer))
		god = true;

	for(new x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x) && !IsPlayerAlive(x) && (g_EnableQuakeSounds[x] >= 1 && g_EnableQuakeSounds[x] <= 2))
		{
			SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				new Target = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");
				if (Target == client)
				{
					if (((god == false && g_EnableQuakeSounds[x] == 1) || (god == true && (g_EnableQuakeSounds[x] >= 1 && g_EnableQuakeSounds[x] <= 2)))  && ((god == false && g_ColorChat[x] == 1) || (god == true && g_ColorChat[x] >= 1)))
						ClientCommand(x, buffer);
				}
			}
		}
	}
}


public SetPlayerBeam(client, Float:origin[3])
{
	if(!g_bBeam[client] || g_bOnGround[client] || !g_js_bPlayerJumped[client])
		return;
	new Float:v1[3], Float:v2[3];
	v1[0] = origin[0];
	v1[1] = origin[1];
	v1[2] = g_js_fJump_JumpOff_Pos[client][2];
	v2[0] = g_fLastPosition[client][0];
	v2[1] = g_fLastPosition[client][1];
	v2[2] = g_js_fJump_JumpOff_Pos[client][2];
	new color[4] = {255, 255, 255, 100};
	TE_SetupBeamPoints(v1, v2, g_Beam[2], 0, 0, 0, 2.5, 3.0, 3.0, 10, 0.0, color, 0);
	if (g_bJumpBeam[client])
		TE_SendToClient(client);
}



public PerformBan(client, String:szbantype[16])
{
	if (IsValidClient(client))
	{
		decl String:szName[64];
		GetClientName(client,szName,64);
		new duration = RoundToZero(g_fBanDuration*60);
		decl String:KickMsg[255];
		Format(KickMsg, sizeof(KickMsg), "KZ-AntiCheat: You have been banned from the server. (reason: %s)",szbantype);

		if (SOURCEBANS_AVAILABLE())
			SBBanPlayer(0, client, duration, szbantype);
		else
			BanClient(client, duration, BANFLAG_AUTO, szbantype, KickMsg, "KZTimer");
		KickClient(client, KickMsg);
		db_DeleteCheater(g_szSteamID[client]);
	}
}

public bool:WallCheck(client)
{
	decl Float:pos[3];
	decl Float:endpos[3];
	decl Float:angs[3];
	decl Float:vecs[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, angs);
	GetAngleVectors(angs, vecs, NULL_VECTOR, NULL_VECTOR);
	angs[1] = -180.0;
	while (angs[1] != 180.0)
	{
		new Handle:trace = TR_TraceRayFilterEx(pos, angs, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

		if(TR_DidHit(trace))
		{
				TR_GetEndPosition(endpos, trace);
				new Float: fdist = GetVectorDistance(endpos, pos, false);
				if (fdist <= 25.0)
				{
					CloseHandle(trace);
					return true;
				}
		}
		CloseHandle(trace);
		angs[1]+=15.0;
	}
	return false;
}
public Prestrafe(client, Float: ang, &buttons)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || !(GetEntityFlags(client) & FL_ONGROUND))
		return;

	//decl.
	new Float:flDefaultKnifeSpeed = 1.0;
	new Float:flMaxKnifeSpeed = 1.104;
	new Float:flDefaultUspSpeed= 1.041667;
	new Float:flMaxUspSpeed = 1.15;
	new Float:flUnarmedSpeed = 0.96154;
	new bool: turning_right;
	new bool: turning_left;
	decl MaxFrameCount;
	decl Float: IncSpeed, Float: DecSpeed;
	new Float: speed = GetSpeed(client);
	new bool: bForward;

	//get weapon
	char classname[128];
	GetClientWeapon(client, classname, sizeof(classname));
	TrimString(classname);

	if (!g_bPreStrafe ||
	(!StrEqual(classname, "weapon_hkp2000") &&
	!StrEqual(classname, "weapon_usp_silencer") &&
	!StrEqual(classname, "weapon_bayonet") &&
	StrContains(classname, "weapon_knife") &&
	StrContains(classname, "weapon")))
	{
		if (StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))
		{
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flDefaultUspSpeed);
		}

		else if ((StrContains(classname, "weapon_knife")) != -1 || (StrContains(classname, "weapon_bayonet") != -1))
		{
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flDefaultKnifeSpeed);
		}

		else
		{
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flUnarmedSpeed);
		}

		return;
	}
	
	// get turning direction
	// Fixed for  -180 180 wrap
	float eye_angle_change = ang - g_fLastAngles[client][1];
	if(eye_angle_change < -180)  
		eye_angle_change += 360;
	if (eye_angle_change > 180)
		eye_angle_change -= 360;
	
	if(eye_angle_change < 0)
		turning_right = true;
	else if(eye_angle_change > 0)
		turning_left = true;

	//get moving direction
	if (GetClientMovingDirection(client,false) > 0.0)
		bForward=true;


	new Float: flVelMd = GetEntPropFloat(client, Prop_Send, "m_flVelocityModifier");
	if ((StrEqual(classname, "weapon_knife") ||
	StrEqual(classname, "weapon_bayonet") ||
	StrContains(classname, "weapon_knife_") != -1) &&
	flVelMd > flMaxKnifeSpeed+0.007)
	{
		SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flMaxKnifeSpeed-0.001);
	}

	//no mouse movement?
	if (!turning_right && !turning_left)
	{
		decl Float: diff;
		diff = GetEngineTime() - g_fVelocityModifierLastChange[client]
		if (diff > 0.2)
		{
			if(StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))
				g_PrestrafeVelocity[client] = flDefaultUspSpeed;
			else
				g_PrestrafeVelocity[client] = flDefaultKnifeSpeed;
			g_fVelocityModifierLastChange[client] = GetEngineTime();
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", g_PrestrafeVelocity[client]);
		}
		return;
	}

	if (((buttons & IN_MOVERIGHT) || (buttons & IN_MOVELEFT)) && speed > 248.9)
	{
		//tickrate depending values
		if (g_Server_Tickrate == 64)
		{
			MaxFrameCount = 45;
			IncSpeed = 0.0015;
			if ((g_PrestrafeVelocity[client] > 1.08 && (StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))) ||
				(g_PrestrafeVelocity[client] > 1.04 && (!StrEqual(classname, "weapon_hkp2000") || !StrEqual(classname, "weapon_usp_silencer"))))
				IncSpeed = 0.001;
			DecSpeed = 0.0045;
		}

		if (g_Server_Tickrate == 102)
		{
			MaxFrameCount = 60;
			IncSpeed = 0.0011;
			if ((g_PrestrafeVelocity[client] > 1.08 && (StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))) ||
				(g_PrestrafeVelocity[client] > 1.04 && (!StrEqual(classname, "weapon_hkp2000") || !StrEqual(classname, "weapon_usp_silencer"))))
				IncSpeed = 0.001;
			DecSpeed = 0.0045;

		}

		if (g_Server_Tickrate == 128)
		{
			MaxFrameCount = 75;
			IncSpeed = 0.0009;
			if ((g_PrestrafeVelocity[client] > 1.08 && (StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))) ||
				(g_PrestrafeVelocity[client] > 1.04 && (!StrEqual(classname, "weapon_hkp2000") || !StrEqual(classname, "weapon_usp_silencer"))))
				IncSpeed = 0.001;
			DecSpeed = 0.0045;
		}
		if (((buttons & IN_MOVERIGHT && turning_right || turning_left && !bForward)) || ((buttons & IN_MOVELEFT && turning_left || turning_right && !bForward)))
		{
			g_PrestrafeFrameCounter[client]++;
			//Add speed if Prestrafe frames are less than max frame count
			if (g_PrestrafeFrameCounter[client] < MaxFrameCount)
			{
				//increase speed
				g_PrestrafeVelocity[client]+= IncSpeed;
				//usp
				if(StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))
				{
					if (g_PrestrafeVelocity[client] > flMaxUspSpeed)
						g_PrestrafeVelocity[client]-=0.007;
				}
				else
				{
					if (g_PrestrafeVelocity[client] > flMaxKnifeSpeed)
					{
						if (g_PrestrafeVelocity[client] > flMaxKnifeSpeed+0.007)
							g_PrestrafeVelocity[client] = flMaxKnifeSpeed-0.001;
						else
							g_PrestrafeVelocity[client]-=0.007;
					}
				}
				g_PrestrafeVelocity[client]+= IncSpeed;
			}
			else
			{
				//decrease speed
				g_PrestrafeVelocity[client]-= DecSpeed;
				g_PrestrafeFrameCounter[client] = g_PrestrafeFrameCounter[client] - 2;

				//usp reset 250.0 speed
				if(StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))
				{
					if (g_PrestrafeVelocity[client]< flDefaultUspSpeed)
					{
						g_PrestrafeFrameCounter[client] = 0;
						g_PrestrafeVelocity[client]= flDefaultUspSpeed;
					}
				}
				else
					//knife reset 250.0 speed
					if (g_PrestrafeVelocity[client]< flDefaultKnifeSpeed)
					{
						g_PrestrafeFrameCounter[client] = 0;
						g_PrestrafeVelocity[client]= flDefaultKnifeSpeed;
					}
			}
		}
		else
		{
			g_PrestrafeVelocity[client] -= 0.04;
			if(StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))
			{
				if (g_PrestrafeVelocity[client]< flDefaultUspSpeed)
					g_PrestrafeVelocity[client]= flDefaultUspSpeed;
			}
			else
			if (g_PrestrafeVelocity[client]< flDefaultKnifeSpeed)
				g_PrestrafeVelocity[client]= flDefaultKnifeSpeed;
		}

		//Set VelocityModifier
		SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", g_PrestrafeVelocity[client]);
		g_fVelocityModifierLastChange[client] = GetEngineTime();
	}
	else
	{
		if(StrEqual(classname, "weapon_hkp2000") || StrEqual(classname, "weapon_usp_silencer"))
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flDefaultUspSpeed);
		else
			SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", flDefaultKnifeSpeed);
		g_PrestrafeFrameCounter[client] = 0;
	}
}

stock Float:GetClientMovingDirection(client, bool:ladder)
{
	new Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fVelocity);

	new Float:fEyeAngles[3];
	GetClientEyeAngles(client, fEyeAngles);

	if(fEyeAngles[0] > 70.0) fEyeAngles[0] = 70.0;
	if(fEyeAngles[0] < -70.0) fEyeAngles[0] = -70.0;

	new Float:fViewDirection[3];

	if (ladder)
		GetEntPropVector(client, Prop_Send, "m_vecLadderNormal", fViewDirection);
	else
		GetAngleVectors(fEyeAngles, fViewDirection, NULL_VECTOR, NULL_VECTOR);

	NormalizeVector(fVelocity, fVelocity);
	NormalizeVector(fViewDirection, fViewDirection);

	new Float:direction = GetVectorDotProduct(fVelocity, fViewDirection);
	if (ladder)
		direction = direction * -1;
	return direction;
}

public MenuTitleRefreshing(client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	if (GetClientMenu(client) == MenuSource_None)
	{
		g_bMenuOpen[client] = false;
		g_bClimbersMenuOpen[client] = false;
	}

	//Timer Panel
	if (!g_bSayHook[client])
	{
		if (g_bTimeractivated[client])
		{
			if (g_bClimbersMenuOpen[client] == false)
				PlayerPanel(client);
		}

		//refresh ClimbersMenu when timer active
		if (g_bTimeractivated[client])
		{
			if (g_bClimbersMenuOpen[client] && !g_bMenuOpen[client])
				ClimbersMenu(client);
			else
				if (g_bClimbersMenuwasOpen[client]  && !g_bMenuOpen[client])
				{
					g_bClimbersMenuwasOpen[client]=false;
					ClimbersMenu(client);
				}
			//Check Time
			if (g_fCurrentRunTime[client] > g_fPersonalRecordPro[client] && !g_bMissedProBest[client] && g_OverallTp[client] == 0 && !g_bPause[client])
			{
				decl String:szTime[32];
				g_bMissedProBest[client]=true;
				FormatTimeFloat(client, g_fPersonalRecordPro[client], 3,szTime, sizeof(szTime));
				if (g_fPersonalRecordPro[client] > 0.0)
					PrintToChat(client, "%t", "MissedProBest", MOSSGREEN,WHITE,GRAY,DARKBLUE,szTime,GRAY);
				EmitSoundToClient(client,"buttons/button18.wav",client);
			}
			else
				if (g_fCurrentRunTime[client] > g_fPersonalRecord[client] && !g_bMissedTpBest[client] && !g_bPause[client])
				{
					decl String:szTime[32];
					g_bMissedTpBest[client]=true;
					FormatTimeFloat(client, g_fPersonalRecord[client], 3, szTime, sizeof(szTime));
					if (g_fPersonalRecord[client] > 0.0)
						PrintToChat(client, "%t", "MissedTpBest", MOSSGREEN,WHITE,GRAY,YELLOW,szTime,GRAY);
					EmitSoundToClient(client,"buttons/button18.wav",client);
				}
		}
	}
}

public WjJumpPreCheck(client, &buttons)
{
	if(g_bOnGround[client] && g_js_bPlayerJumped[client] == false && g_js_GroundFrames[client] > 11)
	{
		if (buttons & IN_JUMP || buttons & IN_DUCK)
			g_bLastButtonJump[client] = true;
		else
			g_bLastButtonJump[client] = false;
	}
}

public MovementCheck(client)
{
	if (StrEqual(g_szMapPrefix[0],"kz") || StrEqual(g_szMapPrefix[0],"xc")  || StrEqual(g_szMapPrefix[0],"kzpro") || StrEqual(g_szMapPrefix[0],"bkz") || StrEqual(g_szMapPrefix[0],"bhop"))
	{
		new Float:VelocityModifier = GetEntPropFloat(client, Prop_Send, "m_flVelocityModifier");
		if (VelocityModifier > 1.16)
		{
			if (g_bTimeractivated[client])
			{
				PrintToChat(client,"[KZ] Timer stopped. Reason: m_flVelocityModifier modified.")
				g_bTimeractivated[client] = false;
			}
			if (g_js_bPlayerJumped[client])
				ResetJump(client);
		}
		new Float:LaggedMovementValue = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
		if (LaggedMovementValue != 1.0)
		{
			if (g_bTimeractivated[client])
			{
				PrintToChat(client,"[KZ] Timer stopped. Reason: m_flLaggedMovementValue modified.")
				g_bTimeractivated[client] = false;
			}
			if (g_js_bPlayerJumped[client])
				ResetJump(client);
		}
	}
	decl MoveType:mt;
	mt = GetEntityMoveType(client);
	if (mt == MOVETYPE_FLYGRAVITY)
	{
		if (g_bTimeractivated[client])
		{
			PrintToChat(client,"[KZ] Timer stopped. Reason: MOVETYPE 'FLYGRAVITY' detected.")
			g_bTimeractivated[client] = false;
		}
		if (g_js_bPlayerJumped[client])
			ResetJump(client);
	}
	if (g_bPause[client] && mt == MOVETYPE_WALK)
		SetEntityMoveType(client, MOVETYPE_NONE);
}

public TeleportCheck(client, Float: origin[3])
{
	if((StrEqual(g_szMapPrefix[0],"kz") || StrEqual(g_szMapPrefix[0],"xc") || StrEqual(g_szMapPrefix[0],"kzpro") || StrEqual(g_szMapPrefix[0],"bkz")) || g_bAutoBhop == false)
	{
		if (!IsFakeClient(client))
		{
			decl Float:sum;
			sum = FloatAbs(origin[0]) - FloatAbs(g_fLastPosition[client][0]);
			if (sum > 15.0 || sum < -15.0)
			{
					if (g_js_bPlayerJumped[client])
					{
						ResetJump(client);
					}
			}
			else
			{
				sum = FloatAbs(origin[1]) - FloatAbs(g_fLastPosition[client][1]);
				if (sum > 15.0 || sum < -15.0)
				{
					if (g_js_bPlayerJumped[client])
					{
						ResetJump(client);
					}
				}
			}
		}
	}
}

public NoClipCheck(client)
{
	decl MoveType:mt;
	mt = GetEntityMoveType(client);
	if(!(g_bOnGround[client]))
	{
		if (mt == MOVETYPE_NOCLIP)
			g_bNoClipUsed[client]=true;
	}
	else
	{
		if (g_js_GroundFrames[client] > 10)
			g_bNoClipUsed[client]=false;
	}
	if(mt == MOVETYPE_NOCLIP && (g_js_bPlayerJumped[client] || g_bTimeractivated[client]))
	{
		if (g_js_bPlayerJumped[client])
			ResetJump(client);
		PrintToConsole(client, "[KZ] Timer stopped. Reason: MOVETYPE 'NOCLIP' detected");
		g_bTimeractivated[client] = false;
	}
}

public SpeedCap(client)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;

	static bool:IsOnGround[MAXPLAYERS + 1];


	new Float:current_speed = GetSpeed(client)
	decl Float:CurVelVec[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);

	//cj addition
	if (!g_js_bPlayerJumped[client] && g_js_DuckCounter[client] > 0)
	{
		if (current_speed > 315.0)
		{
			NormalizeVector(CurVelVec, CurVelVec);
			ScaleVector(CurVelVec, 315.0);
			DoValidTeleport(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
		}
	}
	
	// If jumpbugged, apply bhop speed cap
	if (g_bJumpBugged[client])
	{
		g_bJumpBugged[client] = false; // Reset
		if (GetVectorLength(CurVelVec) > g_fBhopSpeedCap)
		{
			NormalizeVector(CurVelVec, CurVelVec);
			ScaleVector(CurVelVec, g_fBhopSpeedCap);
			DoValidTeleport(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
		}
	}
	
	if (g_bOnGround[client])
	{
		if (!IsOnGround[client])
		{
			IsOnGround[client] = true;
			if (GetVectorLength(CurVelVec) > g_fBhopSpeedCap)
			{

				NormalizeVector(CurVelVec, CurVelVec);
				ScaleVector(CurVelVec, g_fBhopSpeedCap);
				DoValidTeleport(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
			}
		}
	}
	else
		IsOnGround[client] = false;
}

public ButtonPressCheck(client, &buttons, Float: origin[3], Float:speed)
{
	if (IsValidClient(client) && !IsFakeClient(client) && g_LastButton[client] != IN_USE && buttons & IN_USE && ((g_fCurrentRunTime[client] > 0.1 || g_fCurrentRunTime[client] == -1.0)))
	{
		decl Float:diff;
		diff = GetEngineTime() - g_fLastTimeButtonSound[client];
		if (diff > 0.1)
		{
			decl Float:dist;
			dist=70.0;
			decl  Float:distance1;
			distance1 = GetVectorDistance(origin, g_fStartButtonPos);
			decl  Float: distance2;
			distance2 = GetVectorDistance(origin, g_fEndButtonPos);
			if (distance1 < dist && speed < 251.0 && !g_bFirstStartButtonPush)
			{
				new Handle:trace;
				trace = TR_TraceRayFilterEx(origin, g_fStartButtonPos, MASK_SOLID,RayType_EndPoint,TraceFilterPlayers,client)
				if (!TR_DidHit(trace) || g_global_SelfBuiltButtons)
				{
					CL_OnStartTimerPress(client);
					g_fLastTimeButtonSound[client] = GetEngineTime();
				}
				CloseHandle(trace);
			}
			else
				if (distance2 < dist  && !g_bFirstEndButtonPush)
				{
					new Handle:trace;
					trace = TR_TraceRayFilterEx(origin, g_fEndButtonPos, MASK_SOLID,RayType_EndPoint,TraceFilterPlayers,client)
					if (!TR_DidHit(trace) || g_global_SelfBuiltButtons)
					{
						CL_OnEndTimerPress(client);
						g_fLastTimeButtonSound[client] = GetEngineTime();
					}
					CloseHandle(trace);
				}
		}
	}
	else
	{
		if (IsValidClient(client) && IsFakeClient(client) && g_bTimeractivated[client] && g_LastButton[client] != IN_USE && buttons & IN_USE)
		{
			new Float: distance = GetVectorDistance(origin, g_fEndButtonPos);
			if (distance < 75.0  && !g_bFirstEndButtonPush)
			{
				new Handle:trace;
				trace = TR_TraceRayFilterEx(origin, g_fEndButtonPos, MASK_SOLID,RayType_EndPoint,TraceFilterPlayers,client)
				if (!TR_DidHit(trace) || g_global_SelfBuiltButtons)
				{
					CL_OnEndTimerPress(client);
					g_fLastTimeButtonSound[client] = GetEngineTime();
				}
				CloseHandle(trace);
			}
		}
	}
}

public CalcJumpMaxSpeed(client, Float: fspeed)
{
	if (g_js_bPlayerJumped[client])
		if (g_js_fMax_Speed[client] <= fspeed)
		{
			g_js_fMax_Speed[client] = fspeed;
		}
}

public CalcJumpHeight(client)
{
	if (g_js_bPlayerJumped[client])
	{
		new Float:origin[3];
		GetClientAbsOrigin(client, origin);
		if (origin[2] > g_js_fMax_Height[client])
		{
			g_js_fMax_Height[client] = origin[2];

		}
		if (origin[2] > g_js_fJump_JumpOff_Pos[client][2])
			g_fFailedLandingPos[client] = origin;
	}
}

public CalcLastJumpHeight(client, &buttons, Float: origin[3])
{
	if(g_bOnGround[client] && g_js_bPlayerJumped[client] == false && g_js_GroundFrames[client] > 11)
	{
		decl Float:flPos[3];
		GetClientAbsOrigin(client, flPos);
		g_js_fJump_JumpOff_PosLastHeight[client] = flPos[2];
	}
	decl Float:distance;
	distance = GetVectorDistance(g_fLastPosition[client], origin);

	//booster?
	if(distance > 25.0)
	{
		if(g_js_bPlayerJumped[client])
			g_js_bPlayerJumped[client] = false;
	}
}

public CalcJumpSync(client, Float: speed, Float: ang, &buttons)
{
	if (g_js_bPlayerJumped[client])
	{
		decl bool: turning_right;
		turning_right = false;
		decl bool: turning_left;
		turning_left = false;

		if( ang < g_fLastAngles[client][1])
			turning_right = true;
		else
			if( ang > g_fLastAngles[client][1])
				turning_left = true;




		//strafestats
		if(turning_left || turning_right)
		{
			if( !g_js_Strafing_AW[client] && ((buttons & IN_FORWARD) || (buttons & IN_MOVELEFT)) && !(buttons & IN_MOVERIGHT) && !(buttons & IN_BACK) )
			{
				g_js_Strafing_AW[client] = true;
				g_js_Strafing_SD[client] = false;
				g_js_StrafeCount[client]++;
				new count = g_js_StrafeCount[client];
				if (count < 25)
				{
					g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client]] = 0.0;
					g_js_Strafe_Frames[client][g_js_StrafeCount[client]] = 0;
					g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client]] = speed;
					g_js_Strafe_Air_Time[client][g_js_StrafeCount[client]] = GetEngineTime();
				}

			}
			else if( !g_js_Strafing_SD[client] && ((buttons & IN_BACK) || (buttons & IN_MOVERIGHT)) && !(buttons & IN_MOVELEFT) && !(buttons & IN_FORWARD) )
			{
				g_js_Strafing_AW[client] = false;
				g_js_Strafing_SD[client] = true;
				g_js_StrafeCount[client]++;
				if (g_js_StrafeCount[client] < 25)
				{
					g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client]] = 0.0;
					g_js_Strafe_Frames[client][g_js_StrafeCount[client]] = 0;
					g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client]] = speed;
					g_js_Strafe_Air_Time[client][g_js_StrafeCount[client]] = GetEngineTime();
				}
			}
		}

		//sync
		if( g_fLastSpeed[client] < speed)
		{
			g_js_Good_Sync_Frames[client]++;
			if( 0 <= g_js_StrafeCount[client] < 25)
			{
				g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client]]++;
				g_js_Strafe_Gained[client][g_js_StrafeCount[client]] += (speed - g_fLastSpeed[client]);
			}
		}
		else
			if( g_fLastSpeed[client] > speed )
			{
				if( 0 <= g_js_StrafeCount[client] < 25)
					g_js_Strafe_Lost[client][g_js_StrafeCount[client]] += (g_fLastSpeed[client] - speed);
			}

		//strafe frames
		if( 0 <= g_js_StrafeCount[client] < 25)
		{
			g_js_Strafe_Frames[client][g_js_StrafeCount[client]]++;
			if( g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client]] < speed )
				g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client]] = speed;
		}
		//total frames
		g_js_Sync_Frames[client]++;
	}
}

public ServerSidedAutoBhop(client,&buttons)
{
	if (!IsValidClient(client))
		return;
	if (g_bAutoBhop && g_bAutoBhopClient[client])
	{
		if (buttons & IN_JUMP)
			if (!(g_bOnGround[client]))
				if (!(GetEntityMoveType(client) & MOVETYPE_LADDER))
					if (GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
						buttons &= ~IN_JUMP;

	}
}

stock bool:IsEven(num)
{
    return (num & 1) == 0;
}

public BoosterCheck(client)
{
	decl Float:flbaseVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", flbaseVelocity);
	if (flbaseVelocity[0] != 0.0 || flbaseVelocity[1] != 0.0 || flbaseVelocity[2] != 0.0 && g_js_bPlayerJumped[client])
	{
		g_bTouchedBooster[client]=true;
		ResetJump(client);
	}
}

public Action:BindCheck(client, &buttons)
{
	new bool:oldDuck = g_bWasDucking[client];
	new bool:newDuck = view_as<bool>((buttons & IN_DUCK));
	//new bool:startedDucking = (newDuck && !oldDuck);
	
	new bool:oldJumping = g_bJumping[client];
	new bool:newJumping = view_as<bool>((buttons & IN_JUMP));
	//new bool:startedJumping = (newJumping && !oldJumping);
	
	//new bool:oldOnGround = g_bOnGroundBindFix[client];
	new bool:newOnGround = view_as<bool>((GetEntityFlags(client) & FL_ONGROUND));
	//new bool:justLanded = (newOnGround && !oldOnGround);
	//new bool:justLeftGround = (!newOnGround && oldOnGround);
	
	if (!IsValidClient(client))
	{
		return Plugin_Continue;
	}
	
	if (IsPlayerAlive(client))
	{
		if (!oldJumping && !oldDuck && newJumping && newOnGround && newDuck && g_bTimeractivated[client])
		{
			buttons &= ~IN_DUCK;
		}
		
		//Finish up and set onground
		g_bOnGroundBindFix[client] = newOnGround;
		g_bWasDucking[client] = view_as<bool>((buttons & IN_DUCK));
		g_bJumping[client] = view_as<bool>((buttons & IN_JUMP));
	}
	return Plugin_Continue;
}

public WaterCheck(client)
{
	if (GetEntProp(client, Prop_Data, "m_nWaterLevel") > 0 && g_js_bPlayerJumped[client])
		ResetJump(client);
}

public SurfCheck(client)
{
	if (g_js_block_lj_valid[client]) return;
	if (g_js_bPlayerJumped[client] && WallCheck(client))
	{
		ResetJump(client);
	}
}

public ResetJump(client)
{
	Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>", g_js_fJump_Distance[client]);
	g_js_GroundFrames[client] = 0;
	g_bBeam[client] = false;
	g_js_bPerfJumpOff[client] = false;
	g_js_bPerfJumpOff2[client] = false;
	g_js_bPlayerJumped[client] = false;

	if(client != g_ProBot && client != g_TpBot){
		Call_KZTimer_OnJumpstatInvalid(client);
	}
}

public SpecListMenuDead(client)
{
	decl String:szTick[32];
	Format(szTick, 32, "%i", g_Server_Tickrate);
	decl ObservedUser;
	ObservedUser = -1;
	decl String:sSpecs[512];
	Format(sSpecs, 512, "");
	decl SpecMode;
	ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	SpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");

	if (SpecMode == 4 || SpecMode == 5)
	{
		g_SpecTarget[client] = ObservedUser;
		decl count;
		count=0;
		//Speclist
		if (1 <= ObservedUser <= MaxClients)
		{
			decl x;
			decl String:szTime2[32];
			decl String:szTPBest[32];
			decl String:szProBest[32];
			decl String:szPlayerRank[64];
			Format(szPlayerRank,32,"");

			for(x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && !IsFakeClient(client) && !IsPlayerAlive(x) && GetClientTeam(x) >= 1 && GetClientTeam(x) <= 3)
				{

					SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");
					if (SpecMode == 4 || SpecMode == 5)
					{
						decl ObservedUser2;
						ObservedUser2 = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");
						if (ObservedUser == ObservedUser2)
						{
							count++;
							//strip pound symbol from names
							char cleanName[MAX_NAME_LENGTH];
							FormatEx(cleanName, sizeof(cleanName), "%N", x);
							ReplaceString(cleanName, sizeof(cleanName), "#", "",false);
							if (count < 6)
							Format(sSpecs, 512, "%s%s\n", sSpecs, cleanName);
						}
						if (count ==6)
							Format(sSpecs, 512, "%s...", sSpecs);
					}
				}
			}

			//rank
			if (g_bPointSystem)
			{
				if (g_pr_points[ObservedUser] != 0)
				{
					decl String: szRank[32];
					if (g_PlayerRank[ObservedUser] > g_pr_RankedPlayers)
						Format(szRank,32,"-");
					else
						Format(szRank,32,"%i", g_PlayerRank[ObservedUser]);
					Format(szPlayerRank,32,"Rank: #%s/%i",szRank,g_pr_RankedPlayers);
				}
				else
					Format(szPlayerRank,32,"Rank: -/%i",g_pr_RankedPlayers);
			}

			if (g_fPersonalRecord[ObservedUser] > 0.0)
			{
				FormatTimeFloat(client, g_fPersonalRecord[ObservedUser], 3, szTime2, sizeof(szTime2));
				Format(szTPBest, 32, "%s (#%i/%i)", szTime2,g_MapRankTp[ObservedUser],g_MapTimesCountTp);
			}
			else
				Format(szTPBest, 32, "None");
			if (g_fPersonalRecordPro[ObservedUser] > 0.0)
			{
				FormatTimeFloat(client, g_fPersonalRecordPro[ObservedUser], 3, szTime2, sizeof(szTime2));
				Format(szProBest, 32, "%s (#%i/%i)", szTime2,g_MapRankPro[ObservedUser],g_MapTimesCountPro);
			}
			else
				Format(szProBest, 32, "None");

			if(!StrEqual(sSpecs,""))
			{
				decl String:szName[MAX_NAME_LENGTH];
				GetClientName(ObservedUser, szName, MAX_NAME_LENGTH);
				if (g_bSpecInfo[client] && IsFakeClient(ObservedUser))
				{
					g_bSpecInfo[client]=false;
				}
				if (g_bTimeractivated[ObservedUser])
				{
					decl String:szTime[32];
					decl Float:Time;
					Time = GetEngineTime() - g_fStartTime[ObservedUser] - g_fPauseTime[ObservedUser];
					FormatTimeFloat(client, Time, 4, szTime, sizeof(szTime));
					if (!g_bPause[ObservedUser])
					{
						if (!IsFakeClient(ObservedUser))
						{
							switch(g_ShowSpecs[client])
							{
								case 0: Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s\n  \n%s\nTeleports: %i\n \n%s\nPro: %s\nTP: %s", count, sSpecs, szTime,g_OverallTp[ObservedUser],szPlayerRank,szProBest,szTPBest);
								case 1: Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n \n%s\nTeleports: %i\n \n%s\nPro: %s\nTP: %s", count,szTime,g_OverallTp[ObservedUser],szPlayerRank,szProBest,szTPBest);
								case 2: Format(g_szPlayerPanelText[client], 512, "%s\nTeleports: %i\n \n%s\nPro: %s\nTP: %s", szTime,g_OverallTp[ObservedUser],szPlayerRank,szProBest,szTPBest);
							}
						}
						else
						{
							if (ObservedUser == g_ProBot)
							{
								switch(g_ShowSpecs[client])
								{
									case 0: Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\n%s\nTickrate: %s\n \nSpecs (%i):\n%s",szTime,szTick,count, sSpecs);
									case 1: Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\n%s\nTickrate: %s\nSpecs: %i",szTime,szTick,count);
									case 2: Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\n%s\nTickrate: %s",szTime,szTick);
								}
							}
							else
							{
								switch(g_ShowSpecs[client])
								{
									case 0: Format(g_szPlayerPanelText[client], 512, "[TP Replay]\n%s\nTeleports: %i\nTickrate: %s\n \nSpecs (%i):\n%s", szTime,g_ReplayRecordTps,szTick,count,sSpecs);
									case 1: Format(g_szPlayerPanelText[client], 512, "[TP Replay]\n%s\nTeleports: %i\nTickrate: %s\nSpecs: %i", szTime,g_ReplayRecordTps,szTick,count);
									case 2: Format(g_szPlayerPanelText[client], 512, "[TP Replay]\n%s\nTeleports: %i\nTickrate: %s", szTime,g_ReplayRecordTps,szTick);
								}
							}
						}
					}
					else
					{
						if (ObservedUser == g_ProBot)
						{
							switch(g_ShowSpecs[client])
							{
								case 0: Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\nTime: PAUSED\nTickrate: %s\n \nSpecs (%i):\n%s",szTick,count,sSpecs);
								case 1: Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\nTime: PAUSED\nTickrate: %s\nSpecs: %i",szTick,count);
								case 2: Format(g_szPlayerPanelText[client], 512, "[PRO Replay]\nTime: PAUSED\nTickrate: %s",szTick);
							}
						}
						else
						{

							if (ObservedUser == g_TpBot)
							{
								switch(g_ShowSpecs[client])
								{
									case 0: Format(g_szPlayerPanelText[client], 512, "[TP Replay]\nTime: PAUSED\nTeleports: %i\nTickrate: %s\n \nSpecs (%i):\n%s", g_ReplayRecordTps,szTick,count,sSpecs);
									case 1: Format(g_szPlayerPanelText[client], 512, "[TP Replay]\nTime: PAUSED\nTeleports: %i\nTickrate: %s\nSpecs: %i", g_ReplayRecordTps,szTick,count);
									case 2: Format(g_szPlayerPanelText[client], 512, "[TP Replay]\nTime: PAUSED\nTeleports: %i\nTickrate: %s", g_ReplayRecordTps,szTick);
								}
							}
							else
							{
								switch(g_ShowSpecs[client])
								{
									case 0: Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s\n  \nPAUSED", count, sSpecs);
									case 1: Format(g_szPlayerPanelText[client], 512, "Specs : %i\n  \nPAUSED", count);
									case 2: Format(g_szPlayerPanelText[client], 512, "PAUSED");
								}

							}
						}
					}
				}
				else
				{
					if (ObservedUser != g_ProBot && ObservedUser != g_TpBot)
					{
						switch(g_ShowSpecs[client])
						{
							case 0: Format(g_szPlayerPanelText[client], 512, "%Specs (%i):\n%s\n \n%s\nPro: %s\nTP: %s", count, sSpecs,szPlayerRank, szProBest,szTPBest);
							case 1: Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n \n%s\nPro: %s\nTP: %s", count,szPlayerRank,szProBest,szTPBest);
							case 2: Format(g_szPlayerPanelText[client], 512, "%s\nPro: %s\nTP: %s", szPlayerRank,szProBest,szTPBest);
						}
					}
				}

				if (!g_bShowTime[client] && g_ShowSpecs[client] == 0)
				{
					if (ObservedUser != g_ProBot && ObservedUser != g_TpBot)
						Format(g_szPlayerPanelText[client], 512,  "%Specs (%i):\n%s\n \n%s\nPro: %s\nTP: %s", count, sSpecs,szPlayerRank, szProBest,szTPBest);
					else
					{
						if (ObservedUser == g_ProBot)
							Format(g_szPlayerPanelText[client], 512, "PRO replay of\n%s\n \nTickrate: %s\n \nSpecs (%i):\n%s", g_szReplayName,szTick, count, sSpecs);
						else
							Format(g_szPlayerPanelText[client], 512, "TP replay of\n%s\n \nTickrate: %s\n \nSpecs (%i):\n%s", g_szReplayNameTp,szTick, count, sSpecs);

					}
				}
				if (!g_bShowTime[client] && (g_ShowSpecs[client] == 2 || g_ShowSpecs[client] == 1))
				{
					if (ObservedUser != g_ProBot && ObservedUser != g_TpBot)
						Format(g_szPlayerPanelText[client], 512, "%s\nPro: %s\nTP: %s", szPlayerRank,szProBest,szTPBest);
					else
					{
						if (ObservedUser == g_ProBot)
							Format(g_szPlayerPanelText[client], 512, "PRO replay of\n%s\n \nTickrate: %s", g_szReplayName,szTick);
						else
							Format(g_szPlayerPanelText[client], 512, "Tp replay of\n%s\n \nTickrate: %s", g_szReplayNameTp,szTick);

					}
				}
				g_bClimbersMenuOpen[client] = false;

				SpecList(client);
			}
		}
	}
	else
		g_SpecTarget[client] = -1;
}

public SpecListMenuAlive(client)
{

	if (IsFakeClient(client))
		return;

	if (g_ShowSpecs[client] == 2)
	{
		Format(g_szPlayerPanelText[client], 512, "");
		return;
	}

	//Spec list for players
	Format(g_szPlayerPanelText[client], 512, "");
	decl String:sSpecs[512];
	decl SpecMode;
	Format(sSpecs, 512, "");
	decl count;
	count=0;
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(client) && !IsPlayerAlive(i) && !g_bFirstTeamJoin[i] && g_bSpectate[i])
		{
			SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				decl Target;
				Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if (Target == client)
				{
					count++;
					//strip pound symbol from names
					char cleanName[MAX_NAME_LENGTH];
					FormatEx(cleanName, sizeof(cleanName), "%N", i);
					ReplaceString(cleanName, sizeof(cleanName), "#", "", false);
					if (count < 6)
						Format(sSpecs, sizeof(sSpecs), "%s%s\n", sSpecs, cleanName);
				}
				if (count == 6)
					Format(sSpecs, sizeof(sSpecs), "%s...", sSpecs);
			}
		}
	}
	if (count > 0)
	{
		if (g_ShowSpecs[client] == 0)
			Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s ", count, sSpecs);
		else
			if (g_ShowSpecs[client] == 1)
				Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n ", count);
		SpecList(client);
	}
	else
		Format(g_szPlayerPanelText[client], 512, "");
}

//MACRODOX BHOP PROTECTION
//https://forums.alliedmods.net/showthread.php?p=1678026
public PerformStats(client, target,bool:console_only)
{
	if (IsValidClient(client) && !IsFakeClient(target))
	{
		decl String:banstats[512];
		GetClientStats(target, banstats, sizeof(banstats));
		if (!console_only)
			PrintToChat(client, "[%cKZ%c] %s",MOSSGREEN,WHITE,banstats);
		PrintToConsole(client, "[KZ] %s, fps_max: %i, Tickrate: %i",banstats,g_fps_max[target],	g_Server_Tickrate);
		if (g_bAutoBhop)
		{
			PrintToChat(client, "[%cKZ%c] AutoBhop enabled",MOSSGREEN,WHITE);
			PrintToConsole(client, "[KZ] AutoBhop enabled");
		}
	}
}

//MACRODOX BHOP PROTECTION
//https://forums.alliedmods.net/showthread.php?p=1678026
public GetClientStats(client, String:string[], length)
{
	new Float:perf =  g_fafAvgPerfJumps[client] * 100;
	decl String:map[128];
	decl String:szName[64];
	GetClientName(client,szName,64);
	GetCurrentMap(map, 128);
	Format(string, 512, "%cPlayer%c: %c%s%c - %cScroll pattern%c: %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %cAvg. jumps/speed%c: %.1f/%.1f %cperfect jump ratio%c: %.2f%c",
	LIMEGREEN,
	WHITE,
	GREEN,
	szName,
	WHITE,
	LIMEGREEN,
	WHITE,
	g_aaiLastJumps[client][0],
	g_aaiLastJumps[client][1],
	g_aaiLastJumps[client][2],
	g_aaiLastJumps[client][3],
	g_aaiLastJumps[client][4],
	g_aaiLastJumps[client][5],
	g_aaiLastJumps[client][6],
	g_aaiLastJumps[client][7],
	g_aaiLastJumps[client][8],
	g_aaiLastJumps[client][9],
	g_aaiLastJumps[client][10],
	g_aaiLastJumps[client][11],
	g_aaiLastJumps[client][12],
	g_aaiLastJumps[client][13],
	g_aaiLastJumps[client][14],
	g_aaiLastJumps[client][15],
	g_aaiLastJumps[client][16],
	g_aaiLastJumps[client][17],
	g_aaiLastJumps[client][18],
	g_aaiLastJumps[client][19],
	g_aaiLastJumps[client][20],
	g_aaiLastJumps[client][21],
	g_aaiLastJumps[client][22],
	g_aaiLastJumps[client][23],
	g_aaiLastJumps[client][24],
	g_aaiLastJumps[client][25],
	LIMEGREEN,
	WHITE,
	g_fafAvgJumps[client],
	g_fafAvgSpeed[client],
	LIMEGREEN,
	WHITE,
	perf,
	PERCENT);
}

//MACRODOX BHOP PROTECTION - modified by 1NutWunDeR
//https://forums.alliedmods.net/showthread.php?p=1678026
public GetClientStatsLog(client, String:string[], length)
{
	new Float:perf =  g_fafAvgPerfJumps[client] * 100;
	new Float:origin[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin);
	decl String:map[128];
	GetCurrentMap(map, 128);
	Format(string, length, "%L Scroll pattern: %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i, Avg. scroll pattern: %f, Avg. speed: %f, Perfect jump ratio: %.2f%c, fps_max: %i, Tickrate: %i",
	client,
	g_aaiLastJumps[client][0],
	g_aaiLastJumps[client][1],
	g_aaiLastJumps[client][2],
	g_aaiLastJumps[client][3],
	g_aaiLastJumps[client][4],
	g_aaiLastJumps[client][5],
	g_aaiLastJumps[client][6],
	g_aaiLastJumps[client][7],
	g_aaiLastJumps[client][8],
	g_aaiLastJumps[client][9],
	g_aaiLastJumps[client][10],
	g_aaiLastJumps[client][11],
	g_aaiLastJumps[client][12],
	g_aaiLastJumps[client][13],
	g_aaiLastJumps[client][14],
	g_aaiLastJumps[client][15],
	g_aaiLastJumps[client][16],
	g_aaiLastJumps[client][17],
	g_aaiLastJumps[client][18],
	g_aaiLastJumps[client][19],
	g_aaiLastJumps[client][20],
	g_aaiLastJumps[client][21],
	g_aaiLastJumps[client][22],
	g_aaiLastJumps[client][23],
	g_aaiLastJumps[client][24],
	g_aaiLastJumps[client][25],
	g_aaiLastJumps[client][26],
	g_aaiLastJumps[client][27],
	g_aaiLastJumps[client][28],
	g_aaiLastJumps[client][29],
	g_fafAvgJumps[client],
	g_fafAvgSpeed[client],
	perf,
	PERCENT,
	g_fps_max[client],
	g_Server_Tickrate);
}

public MacroBan(int client, bool hack)
{
	if (!g_bAutoBhop && !g_bFlagged[client])
	{
		decl String:globalbanstats[256];
		decl String:banstats[256];
		decl String:reason[256];
		Format(reason, 256, "bhop hack");
		GetClientStatsLog(client, banstats, sizeof(banstats));
		GetClientStatsLog2(client, globalbanstats, sizeof(globalbanstats));

		if (g_hDbGlobal != INVALID_HANDLE)
		{
			decl String:szName[64];
			decl String:szIP[128];
			GetClientName(client,szName,64);
			GetClientIP(client, szIP, 128);
			db_InsertBan(g_szSteamID[client], szName, g_szCountryCode[client], szIP, reason, globalbanstats);

			if (gB_KZTimerAPI)
			{
				if (hack)
				{
					KZTimerAPI_InsertGlobalBan(client, "bhop_hack", reason, globalbanstats);
				}
				else
				{
					KZTimerAPI_InsertGlobalBan(client, "bhop_macro", reason, globalbanstats);
				}
			}
		}
		decl String:sPath[512];
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s", ANTICHEAT_LOG_PATH);
		if (g_bAutoBan)
		{
			LogToFile(sPath, "%s, Reason: bhop hack detected. (autoban)", banstats);
		}
		else
			LogToFile(sPath, "%s, Reason: bhop hack detected.", banstats);
		g_bFlagged[client] = true;
		if (g_bAutoBan)
			PerformBan(client,"BhopHack");
	}
}

//macrodox addon by 1nut
public BhopPatternCheck(client)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || IsFakeClient(client) || g_bPause[client] || g_bAutoBhop || g_bFlagged[client] || g_fafAvgPerfJumps[client] < 0.6 || g_fafAvgSpeed[client] < 300.0)
		return;

	//decl.
	new pattern_array[50];
	new pattern_sum;
	new jumps;

	//analyse the last jumps
	for (new i = 0; i < 30; i++)
	{
		new value = g_aaiLastJumps[client][i];
		if ( 1 < value < 50)
		{
			pattern_sum+=value;
			jumps++;
			pattern_array[value]++;
		}
	}

	//pattern check #1
	new Float:avg_scroll_pattern = float(pattern_sum) / float(jumps);
	if (avg_scroll_pattern > 30.0 && g_fafAvgSpeed[client] > 330.0)
	{
		MacroBan(client, false);
		return;
	}
	//pattern check #2
	for (new j = 2; j < 50; j++)
	{
		if (pattern_array[j] >= 22)
		{
			MacroBan(client, false);
			return;
		}
	}
}

public GetClientStatsLog2(client, String:string[], length)
{
	new Float:perf =  g_fafAvgPerfJumps[client] * 100;
	new Float:origin[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin);
	decl String:map[128];
	GetCurrentMap(map, 128);
	Format(string, length, "Scroll pattern: %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i, Avg. scroll pattern: %f, Avg. speed: %f, Perfect jump ratio: %.2f%c",
	g_aaiLastJumps[client][0],
	g_aaiLastJumps[client][1],
	g_aaiLastJumps[client][2],
	g_aaiLastJumps[client][3],
	g_aaiLastJumps[client][4],
	g_aaiLastJumps[client][5],
	g_aaiLastJumps[client][6],
	g_aaiLastJumps[client][7],
	g_aaiLastJumps[client][8],
	g_aaiLastJumps[client][9],
	g_aaiLastJumps[client][10],
	g_aaiLastJumps[client][11],
	g_aaiLastJumps[client][12],
	g_aaiLastJumps[client][13],
	g_aaiLastJumps[client][14],
	g_aaiLastJumps[client][15],
	g_aaiLastJumps[client][16],
	g_aaiLastJumps[client][17],
	g_aaiLastJumps[client][18],
	g_aaiLastJumps[client][19],
	g_aaiLastJumps[client][20],
	g_aaiLastJumps[client][21],
	g_aaiLastJumps[client][22],
	g_aaiLastJumps[client][23],
	g_aaiLastJumps[client][24],
	g_aaiLastJumps[client][25],
	g_aaiLastJumps[client][26],
	g_aaiLastJumps[client][27],
	g_aaiLastJumps[client][28],
	g_aaiLastJumps[client][29],
	g_fafAvgJumps[client],
	g_fafAvgSpeed[client],
	perf,
	PERCENT);
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public Teleport(client, bhop,bool:mt)
{
	decl i;
	new tele = -1, ent = bhop;

	//search door trigger list
	for (i = 0; i < g_BhopDoorCount; i++)
	{
		if(ent == g_BhopDoorList[i])
		{
			tele = g_BhopDoorTeleList[i];
			break;
		}
	}

	//no destination? search button trigger list
	if(tele == -1)
	{
		for (i = 0; i < g_BhopButtonCount; i++)
		{
			if(ent == g_BhopButtonList[i])
			{
				tele = g_BhopButtonTeleList[i];
				break;
			}
		}
	}

	//no destination? search multiple trigger list
	for (i = 0; i < g_BhopMultipleCount; i++)
	{
		if(ent == g_BhopMultipleList[i])
		{
			tele = g_BhopMultipleTeleList[i];
			break;
		}
	}

	//set teleport destination
	if(tele != -1 && IsValidEntity(tele))
	{
		decl String:targetName[64];
		decl String:destName[64];
		GetEntPropString(tele, Prop_Data, "m_target", targetName, sizeof(targetName));
		new dest = -1;
		while ((dest = FindEntityByClassname(dest, "info_teleport_destination")) != -1)
		{
			GetEntPropString(dest, Prop_Data, "m_iName", destName, sizeof(destName));
			if (StrEqual(destName, targetName))
			{

				new Float: pos[3];
				new Float: ang[3];
				GetEntPropVector(dest, Prop_Data, "m_angRotation", ang);
				GetEntPropVector(dest, Prop_Send, "m_vecOrigin", pos);

				//synergy fix
				if ((StrContains(g_szMapName,"bkz_synergy_ez") != -1 || StrContains(g_szMapName,"bkz_synergy_x") != -1) && StrEqual(targetName,"1-1"))
				{
				}
				else
				{
					DoValidTeleport(client, pos,ang,Float:{0.0,0.0,-100.0});
				}
			}
		}
	}
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public FindBhopBlocks()
{
	decl Float:startpos[3], Float:endpos[3], Float:mins[3], Float:maxs[3], tele;
	new ent = -1;
	new Float:flbaseVelocity[3];
	while((ent = FindEntityByClassname(ent,"func_door")) != -1)
	{
		if(g_DoorOffs_vecPosition1 == -1)
		{
			g_DoorOffs_vecPosition1 = FindDataMapInfo(ent,"m_vecPosition1");
			g_DoorOffs_vecPosition2 = FindDataMapInfo(ent,"m_vecPosition2");
			g_DoorOffs_flSpeed = FindDataMapInfo(ent,"m_flSpeed");
			g_DoorOffs_spawnflags = FindDataMapInfo(ent,"m_spawnflags");
			g_DoorOffs_NoiseMoving = FindDataMapInfo(ent,"m_NoiseMoving");
			g_DoorOffs_sLockedSound = FindDataMapInfo(ent,"m_ls.sLockedSound");
			g_DoorOffs_bLocked = FindDataMapInfo(ent,"m_bLocked");
		}

		GetEntDataVector(ent,g_DoorOffs_vecPosition1,startpos);
		GetEntDataVector(ent,g_DoorOffs_vecPosition2,endpos);


		if(startpos[2] > endpos[2])
		{
			GetEntDataVector(ent,g_Offs_vecMins,mins);
			GetEntDataVector(ent,g_Offs_vecMaxs,maxs);
			GetEntPropVector(ent, Prop_Data, "m_vecBaseVelocity", flbaseVelocity);
			new Float:speed = GetEntDataFloat(ent,g_DoorOffs_flSpeed);

			if((flbaseVelocity[0] != 1100.0 && flbaseVelocity[1] != 1100.0 && flbaseVelocity[2] != 1100.0) && (maxs[2] - mins[2]) < 80 && (startpos[2] > endpos[2] || speed > 100))
			{
				startpos[0] += (mins[0] + maxs[0]) * 0.5;
				startpos[1] += (mins[1] + maxs[1]) * 0.5;
				startpos[2] += maxs[2];

				if((tele = CustomTraceForTeleports(startpos,endpos[2] + maxs[2])) != -1 || (speed > 100 && startpos[2] < endpos[2]))
				{
					g_BhopDoorList[g_BhopDoorCount] = ent;
					g_BhopDoorTeleList[g_BhopDoorCount] = tele;

					if(++g_BhopDoorCount == sizeof g_BhopDoorList)
					{
						break;
					}
				}
			}
		}
	}

	ent = -1;

	while((ent = FindEntityByClassname(ent,"func_button")) != -1)
	{
		if(g_ButtonOffs_vecPosition1 == -1)
		{
			g_ButtonOffs_vecPosition1 = FindDataMapInfo(ent,"m_vecPosition1");
			g_ButtonOffs_vecPosition2 = FindDataMapInfo(ent,"m_vecPosition2");
			g_ButtonOffs_flSpeed = FindDataMapInfo(ent,"m_flSpeed");
			g_ButtonOffs_spawnflags = FindDataMapInfo(ent,"m_spawnflags");
		}

		GetEntDataVector(ent,g_ButtonOffs_vecPosition1,startpos);
		GetEntDataVector(ent,g_ButtonOffs_vecPosition2,endpos);

		if(startpos[2] > endpos[2] && (GetEntData(ent,g_ButtonOffs_spawnflags,4) & SF_BUTTON_TOUCH_ACTIVATES))
		{
			GetEntDataVector(ent,g_Offs_vecMins,mins);
			GetEntDataVector(ent,g_Offs_vecMaxs,maxs);

			startpos[0] += (mins[0] + maxs[0]) * 0.5;
			startpos[1] += (mins[1] + maxs[1]) * 0.5;
			startpos[2] += maxs[2];

			if((tele = CustomTraceForTeleports(startpos,endpos[2] + maxs[2])) != -1)
			{
				g_BhopButtonList[g_BhopButtonCount] = ent;
				g_BhopButtonTeleList[g_BhopButtonCount] = tele;

				if(++g_BhopButtonCount == sizeof g_BhopButtonList)
				{
					break;
				}
			}
		}
	}

	AlterBhopBlocks(false);
}

public Entity_Touch3(bhop,client)
{
	if(IsValidClient(client))
		g_bOnBhopPlattform[client] = false;
}

public Entity_Touch2(bhop,client)
{
	if(IsValidClient(client))
	{
		g_bOnBhopPlattform[client]=true;
		if (g_bSingleTouch)
		{
			if (bhop == g_LastGroundEnt[client] && (GetEngineTime() - g_fLastTimeBhopBlock[client]) <= 0.9)
			{
				g_LastGroundEnt[client] = -1;
				Teleport(client, bhop,true);
			}
			else
			{
				g_fLastTimeBhopBlock[client] = GetEngineTime();
				g_LastGroundEnt[client] = bhop;
			}
		}
	}
}


CustomTraceForTeleports2(const Float:pos[3])
{
	decl teleports[512];
	new tpcount, ent = -1;
	while((ent = FindEntityByClassname(ent,"trigger_teleport")) != -1 && tpcount != sizeof teleports)
		teleports[tpcount++] = ent;

	decl Float:mins[3], Float:maxs[3], Float:origin[3], Float: step, Float:endpos, i;
	origin[0] = pos[0];
	origin[1] = pos[1];
	origin[2] = pos[2];
	step = 1.0;
	endpos = origin[2] - 30;
	do
	{
		for(i = 0; i < tpcount; i++)
		{
			ent = teleports[i];
			GetAbsBoundingBox(ent,mins,maxs);
			if(mins[0] <= origin[0] <= maxs[0] && mins[1] <= origin[1] <= maxs[1] && mins[2] <= origin[2] <= maxs[2])
				return ent;
		}
		origin[2] -= step;
	}
	while(endpos <= origin[2]);
	return -1;
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public AlterBhopBlocks(bool:bRevertChanges)
{
	static Float:vecDoorPosition2[sizeof g_BhopDoorList][3];
	static Float:flDoorSpeed[sizeof g_BhopDoorList];
	static iDoorSpawnflags[sizeof g_BhopDoorList];
	static bool:bDoorLocked[sizeof g_BhopDoorList];
	static Float:vecButtonPosition2[sizeof g_BhopButtonList][3];
	static Float:flButtonSpeed[sizeof g_BhopButtonList];
	static iButtonSpawnflags[sizeof g_BhopButtonList];
	decl ent, i;
	if(bRevertChanges)
	{
		for(i = 0; i < g_BhopDoorCount; i++)
		{
			ent = g_BhopDoorList[i];
			if(IsValidEntity(ent))
			{
				SetEntDataVector(ent,g_DoorOffs_vecPosition2,vecDoorPosition2[i]);
				SetEntDataFloat(ent,g_DoorOffs_flSpeed,flDoorSpeed[i]);
				SetEntData(ent,g_DoorOffs_spawnflags,iDoorSpawnflags[i],4);
				if(!bDoorLocked[i])
				{
					AcceptEntityInput(ent,"Unlock");
				}
				SDKUnhook(ent,SDKHook_Touch,Entity_Touch);
				SDKUnhook(ent,SDKHook_StartTouch,Entity_Touch2);
				SDKUnhook(ent,SDKHook_EndTouch,Entity_Touch3);
			}
		}

		for(i = 0; i < g_BhopButtonCount; i++)
		{
			ent = g_BhopButtonList[i];
			if(IsValidEntity(ent))
			{
				SetEntDataVector(ent,g_ButtonOffs_vecPosition2,vecButtonPosition2[i]);
				SetEntDataFloat(ent,g_ButtonOffs_flSpeed,flButtonSpeed[i]);
				SetEntData(ent,g_ButtonOffs_spawnflags,iButtonSpawnflags[i],4);
				if(flDoorSpeed[i] <= 100)
				{
					SDKUnhook(ent,SDKHook_Touch,Entity_Touch);
					SDKUnhook(ent,SDKHook_StartTouch,Entity_Touch2);
				}
				else
				{
					SDKUnhook(ent,SDKHook_Touch,Entity_BoostTouch);
					SDKUnhook(ent,SDKHook_StartTouch,Entity_Touch2);
				}
			}
		}
	}
	else
	{
		decl Float:startpos[3];
		for (i = 0; i < g_BhopDoorCount; i++)
		{
			ent = g_BhopDoorList[i];
			GetEntDataVector(ent,g_DoorOffs_vecPosition2,vecDoorPosition2[i]);
			flDoorSpeed[i] = GetEntDataFloat(ent,g_DoorOffs_flSpeed);
			iDoorSpawnflags[i] = GetEntData(ent,g_DoorOffs_spawnflags,4);
			bDoorLocked[i] = GetEntData(ent,g_DoorOffs_bLocked,1) ? true : false;
			GetEntDataVector(ent,g_DoorOffs_vecPosition1,startpos);
			SetEntDataVector(ent,g_DoorOffs_vecPosition2,startpos);
			SetEntDataFloat(ent,g_DoorOffs_flSpeed,0.0);
			SetEntData(ent,g_DoorOffs_spawnflags,SF_DOOR_PTOUCH,4);
			AcceptEntityInput(ent,"Lock");
			SetEntData(ent,g_DoorOffs_sLockedSound,GetEntData(ent,g_DoorOffs_NoiseMoving,4),4);
			SDKHook(ent,SDKHook_Touch,Entity_Touch);
			SDKHook(ent,SDKHook_StartTouch,Entity_Touch2);
			SDKHook(ent,SDKHook_EndTouch,Entity_Touch3);
		}

		for (i = 0; i < g_BhopButtonCount; i++)
		{
			ent = g_BhopButtonList[i];
			GetEntDataVector(ent,g_ButtonOffs_vecPosition2,vecButtonPosition2[i]);
			flButtonSpeed[i] = GetEntDataFloat(ent,g_ButtonOffs_flSpeed);
			iButtonSpawnflags[i] = GetEntData(ent,g_ButtonOffs_spawnflags,4);
			GetEntDataVector(ent,g_ButtonOffs_vecPosition1,startpos);
			SetEntDataVector(ent,g_ButtonOffs_vecPosition2,startpos);
			SetEntDataFloat(ent,g_ButtonOffs_flSpeed,0.0);
			SetEntData(ent,g_ButtonOffs_spawnflags,SF_BUTTON_DONTMOVE|SF_BUTTON_TOUCH_ACTIVATES,4);
			if(flDoorSpeed[i] <= 100)
			{
				SDKHook(ent,SDKHook_Touch,Entity_Touch);
				SDKHook(ent,SDKHook_StartTouch,Entity_Touch2);
			}
			else
			{
				g_fBhopDoorSp[i] = flDoorSpeed[i];
				SDKHook(ent,SDKHook_Touch,Entity_BoostTouch);
				SDKHook(ent,SDKHook_StartTouch,Entity_Touch2);
			}
		}
	}
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public Entity_BoostTouch(bhop,client)
{
	if(0 < client <= MaxClients)
	{
		new Float:speed = -1.0;
		static i;
		for(i = 0; i < g_BhopDoorCount; i++)
		{
			if(bhop == g_BhopDoorList[i])
			{
				speed = g_fBhopDoorSp[i]
				break
			}
		}
		if(speed != -1 && speed)
		{

			new Float:ovel[3]
			Entity_GetBaseVelocity(client, ovel)
			new Float:evel[3]
			Entity_GetLocalVelocity(client, evel)
			if(ovel[2] < speed && evel[2] < speed)
			{
				new Float:vel[3]
				vel[0] = Float:0
				vel[1] = Float:0
				vel[2] = speed * 1.8
				Entity_SetBaseVelocity(client, vel)
			}
		}
	}
}

//Credits: MultiPlayer Bunny Hops: Source by DaFox & petsku
//https://forums.alliedmods.net/showthread.php?p=808724
public Entity_Touch(bhop,client)
{
	//bhop = entity
	if(IsValidClient(client))
	{

		g_bOnBhopPlattform[client]=true;

		static Float:flPunishTime[MAXPLAYERS + 1], iLastBlock[MAXPLAYERS + 1] = { -1,... };
		new Float:time = GetEngineTime();
		new Float:diff = time - flPunishTime[client];
		if(iLastBlock[client] != bhop || diff > 0.1)
		{
			//reset cooldown
			iLastBlock[client] = bhop;
			flPunishTime[client] = time + 0.05;

		}
		else
		{
			if(diff > 0.05)
			{
				if(time - g_fLastJump[client] > (0.05 + 0.1))
				{
					Teleport(client, iLastBlock[client],false);
					iLastBlock[client] = -1;
				}
			}
		}
	}
}


//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
CustomTraceForTeleports(const Float:startpos[3],Float:endheight,Float:step=1.0)
{
	decl teleports[512];
	new tpcount, ent = -1;
	while((ent = FindEntityByClassname(ent,"trigger_teleport")) != -1 && tpcount != sizeof teleports)
	{
		teleports[tpcount++] = ent;
	}

	decl Float:mins[3], Float:maxs[3], Float:origin[3], i;
	origin[0] = startpos[0];
	origin[1] = startpos[1];
	origin[2] = startpos[2];
	do
	{
		for(i = 0; i < tpcount; i++)
		{
			ent = teleports[i];
			GetAbsBoundingBox(ent,mins,maxs);

			if(mins[0] <= origin[0] <= maxs[0] && mins[1] <= origin[1] <= maxs[1] && mins[2] <= origin[2] <= maxs[2])
			{
				return ent;
			}
		}
		origin[2] -= step;
	}
	while(origin[2] >= endheight);
	return -1;
}

//MultiPlayer Bunnyhop
//https://forums.alliedmods.net/showthread.php?p=808724
public GetAbsBoundingBox(ent,Float:mins[3],Float:maxs[3])
{
	decl Float:origin[3];
	GetEntDataVector(ent,g_Offs_vecOrigin,origin);
	GetEntDataVector(ent,g_Offs_vecMins,mins);
	GetEntDataVector(ent,g_Offs_vecMaxs,maxs);
	mins[0] += origin[0];
	mins[1] += origin[1];
	mins[2] += origin[2];
	maxs[0] += origin[0];
	maxs[1] += origin[1];
	maxs[2] += origin[2];
}

public FindMultipleBlocks()
{
	decl Float:pos[3], tele;
	new ent = -1;
	while((ent = FindEntityByClassname(ent,"trigger_multiple")) != -1)
	{
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		if((tele = CustomTraceForTeleports2(pos)) != -1)
		{
			g_BhopMultipleList[g_BhopMultipleCount] = ent;
			g_BhopMultipleTeleList[g_BhopMultipleCount] = tele;
			SDKHook(ent,SDKHook_StartTouch,Entity_Touch2);
			if(++g_BhopMultipleCount == sizeof g_BhopMultipleList)
				break;
		}
	}
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
GetPos(client,arg)
{
	decl Float:origin[3],Float:angles[3]
	GetClientEyePosition(client,origin)
	GetClientEyeAngles(client,angles)
	new Handle:trace = TR_TraceRayFilterEx(origin,angles,MASK_SHOT,RayType_Infinite,TraceFilterPlayers,client)
	if(!TR_DidHit(trace))
	{
		CloseHandle(trace);
		PrintToChat(client, "%t", "Measure3",MOSSGREEN,WHITE);
		return;
	}
	TR_GetEndPosition(origin,trace);
	CloseHandle(trace);
	g_fvMeasurePos[client][arg][0] = origin[0];
	g_fvMeasurePos[client][arg][1] = origin[1];
	g_fvMeasurePos[client][arg][2] = origin[2];
	PrintToChat(client, "%t", "Measure4",MOSSGREEN,WHITE,arg+1,origin[0],origin[1],origin[2]);
	if(arg == 0)
	{
		if(g_hP2PRed[client] != INVALID_HANDLE)
		{
			CloseHandle(g_hP2PRed[client]);
			g_hP2PRed[client] = INVALID_HANDLE;
		}
		g_bMeasurePosSet[client][0] = true;
		g_hP2PRed[client] = CreateTimer(1.0,Timer_P2PRed,client,TIMER_REPEAT);
		P2PXBeam(client,0);
	}
	else
	{
		if(g_hP2PGreen[client] != INVALID_HANDLE)
		{
			CloseHandle(g_hP2PGreen[client]);
			g_hP2PGreen[client] = INVALID_HANDLE;
		}
		g_bMeasurePosSet[client][1] = true;
		P2PXBeam(client,1);
		g_hP2PGreen[client] = CreateTimer(1.0,Timer_P2PGreen,client,TIMER_REPEAT);
	}
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Timer_P2PRed(Handle:timer,any:client)
{
	P2PXBeam(client,0);
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public Action:Timer_P2PGreen(Handle:timer,any:client)
{
	P2PXBeam(client,1);
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
P2PXBeam(client,arg)
{
	decl Float:Origin0[3],Float:Origin1[3],Float:Origin2[3],Float:Origin3[3]
	Origin0[0] = (g_fvMeasurePos[client][arg][0] + 8.0);
	Origin0[1] = (g_fvMeasurePos[client][arg][1] + 8.0);
	Origin0[2] = g_fvMeasurePos[client][arg][2];
	Origin1[0] = (g_fvMeasurePos[client][arg][0] - 8.0);
	Origin1[1] = (g_fvMeasurePos[client][arg][1] - 8.0);
	Origin1[2] = g_fvMeasurePos[client][arg][2];
	Origin2[0] = (g_fvMeasurePos[client][arg][0] + 8.0);
	Origin2[1] = (g_fvMeasurePos[client][arg][1] - 8.0);
	Origin2[2] = g_fvMeasurePos[client][arg][2];
	Origin3[0] = (g_fvMeasurePos[client][arg][0] - 8.0);
	Origin3[1] = (g_fvMeasurePos[client][arg][1] + 8.0);
	Origin3[2] = g_fvMeasurePos[client][arg][2];
	if(arg == 0)
	{
		Beam(client,Origin0,Origin1,0.97,2.0,255,0,0);
		Beam(client,Origin2,Origin3,0.97,2.0,255,0,0);
	}
	else
	{
		Beam(client,Origin0,Origin1,0.97,2.0,0,255,0);
		Beam(client,Origin2,Origin3,0.97,2.0,0,255,0);
	}
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
Beam(client,Float:vecStart[3],Float:vecEnd[3],Float:life,Float:width,r,g,b)
{
	TE_Start("BeamPoints")
	TE_WriteNum("m_nModelIndex",g_Beam[2]);
	TE_WriteNum("m_nHaloIndex",0);
	TE_WriteNum("m_nStartFrame",0);
	TE_WriteNum("m_nFrameRate",0);
	TE_WriteFloat("m_fLife",life);
	TE_WriteFloat("m_fWidth",width);
	TE_WriteFloat("m_fEndWidth",width);
	TE_WriteNum("m_nFadeLength",0);
	TE_WriteFloat("m_fAmplitude",0.0);
	TE_WriteNum("m_nSpeed",0);
	TE_WriteNum("r",r);
	TE_WriteNum("g",g);
	TE_WriteNum("b",b);
	TE_WriteNum("a",255);
	TE_WriteNum("m_nFlags",0);
	TE_WriteVector("m_vecStartPoint",vecStart);
	TE_WriteVector("m_vecEndPoint",vecEnd);
	TE_SendToClient(client);
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
ResetPos(client)
{
	if(g_hP2PRed[client] != INVALID_HANDLE)
	{
		CloseHandle(g_hP2PRed[client]);
		g_hP2PRed[client] = INVALID_HANDLE;
	}
	if(g_hP2PGreen[client] != INVALID_HANDLE)
	{
		CloseHandle(g_hP2PGreen[client]);
		g_hP2PGreen[client] = INVALID_HANDLE;
	}
	g_bMeasurePosSet[client][0] = false;
	g_bMeasurePosSet[client][1] = false;

	g_fvMeasurePos[client][0][0] = 0.0; //This is stupid.
	g_fvMeasurePos[client][0][1] = 0.0;
	g_fvMeasurePos[client][0][2] = 0.0;
	g_fvMeasurePos[client][1][0] = 0.0;
	g_fvMeasurePos[client][1][1] = 0.0;
	g_fvMeasurePos[client][1][2] = 0.0;
}

// Measure-Plugin by DaFox
//https://forums.alliedmods.net/showthread.php?t=88830?t=88830
public bool:TraceFilterPlayers(entity,contentsMask)
{
	return (entity > MaxClients) ? true : false;
} //Thanks petsku

//jsfunction.inc
stock GetGroundOrigin(client, Float:pos[3])
{
	decl Float:fOrigin[3], Float:result[3];
	GetClientAbsOrigin(client, fOrigin);
	TraceClientGroundOrigin(client, result, 100.0);
	pos = fOrigin;
	pos[2] = result[2];
}

stock Float:GetGroundDiff(client, Float:pos[3])
{
	decl Float:fOrigin[3], Float:result[3];
	GetClientAbsOrigin(client, fOrigin);
	TraceClientGroundOrigin(client, result, 100.0);
	result[2] = FloatAbs(fOrigin[2]- result[2])
	return result[2];
}


//jsfunction.inc
stock TraceClientGroundOrigin(client, Float:result[3], Float:offset)
{
	decl Float:temp[2][3];
	GetClientEyePosition(client, temp[0]);
	temp[1] = temp[0];
	temp[1][2] -= offset;
	new Float:mins[] ={-16.0, -16.0, 0.0};
	new Float:maxs[] =	{16.0, 16.0, 60.0};
	new Handle:trace = TR_TraceHullFilterEx(temp[0], temp[1], mins, maxs, MASK_SHOT, TraceEntityFilterPlayer);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

//jsfunction.inc
public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
    return entity > MaxClients;
}

public CreateNavFiles()
{
	decl String:DestFile[256];
	decl String:SourceFile[256];
	Format(SourceFile, sizeof(SourceFile), "maps/replay_bot.nav");
	if (!FileExists(SourceFile))
	{
		LogError("<KZTIMER> Failed to create .nav files. Reason: %s doesn't exist!", SourceFile);
		return;
	}
	decl String:map[256];
	new mapListSerial = -1;
	if (ReadMapList(g_MapList,	mapListSerial, "mapcyclefile", MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_NO_DEFAULT) == INVALID_HANDLE)
		if (mapListSerial == -1)
			return;

	for (new i = 0; i < GetArraySize(g_MapList); i++)
	{
		GetArrayString(g_MapList, i, map, sizeof(map));
		if (!StrEqual(map, "", false))
		{
			Format(DestFile, sizeof(DestFile), "maps/%s.nav", map);
			if (!FileExists(DestFile))
				File_Copy(SourceFile, DestFile);
		}
	}
}

public LoadInfoBot()
{
	if (!g_bInfoBot)
		return;

	g_InfoBot = -1;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i) || !IsFakeClient(i) || i == g_TpBot || i == g_ProBot)
			continue;
		g_InfoBot = i;
		break;
	}
	if(IsValidClient(g_InfoBot))
	{
		Format(g_pr_rankname[g_InfoBot], 16, "BOT");
		CS_SetClientClanTag(g_InfoBot, "");
		SetEntProp(g_InfoBot, Prop_Send, "m_iAddonBits", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iPrimaryAddon", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iSecondaryAddon", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(g_InfoBot, Prop_Send, "m_lifeState",2);
		SetInfoBotName(g_InfoBot);
	}
	else
	{
		new count = 0;
		if (g_bTpReplay)
			count++;
		if (g_bProReplay)
			count++;
		if (g_bInfoBot)
			count++;
		if (count==0)
			return;
		decl String:szBuffer2[64];
		Format(szBuffer2, sizeof(szBuffer2), "bot_quota %i", count);
		ServerCommand(szBuffer2);
		CreateTimer(0.5, RefreshInfoBot,TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:RefreshInfoBot(Handle:timer)
{
	LoadInfoBot();
}


public SetInfoBotName(ent)
{
	decl String:szBuffer[64];
	decl String:sNextMap[128];
	if (!IsValidClient(g_InfoBot) || !g_bInfoBot)
		return;
	if(g_bMapChooser && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished())
		Format(sNextMap, sizeof(sNextMap), "Pending Vote");
	else
	{
		GetNextMap(sNextMap, sizeof(sNextMap));
		new String:mapPieces[6][128];
		new lastPiece = ExplodeString(sNextMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
		Format(sNextMap, sizeof(sNextMap), "%s", mapPieces[lastPiece-1]);
	}
	new timeleft;
	GetMapTimeLeft(timeleft);
	new Float:ftime = float(timeleft);
	decl String:szTime[32];
	FormatTimeFloat(g_InfoBot,ftime,5,szTime,sizeof(szTime));
	new Handle:hTmp;
	hTmp = FindConVar("mp_timelimit");
	new iTimeLimit = GetConVarInt(hTmp);
	if (hTmp != INVALID_HANDLE)
		CloseHandle(hTmp);
	if (g_bMapEnd && iTimeLimit > 0)
		Format(szBuffer, sizeof(szBuffer), "%s (%s)",sNextMap, szTime);
	else
		Format(szBuffer, sizeof(szBuffer), "Pending Vote (no time limit)");
	SetClientName(g_InfoBot, szBuffer);
	Client_SetScore(g_InfoBot,9999);
	CS_SetClientClanTag(g_InfoBot, "INFO");
}

public CenterHudDead(client)
{
	decl String:szTick[32];
	Format(szTick, 32, "%i", g_Server_Tickrate);
	decl ObservedUser
	ObservedUser = -1;
	decl SpecMode;
	ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	SpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	if (SpecMode == 4 || SpecMode == 5)
	{
		g_SpecTarget[client] = ObservedUser;
		decl String:sResult[32];
		decl Buttons;

		if (g_bInfoPanel[client] && IsValidClient(ObservedUser))
		{
			Buttons = g_LastButton[ObservedUser];
			if (Buttons & IN_MOVELEFT)
				Format(sResult, sizeof(sResult), "<b>Keys</b>: A");
			else
				Format(sResult, sizeof(sResult), "<b>Keys</b>: _");
			if (Buttons & IN_FORWARD)
				Format(sResult, sizeof(sResult), "%s W", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);
			if (Buttons & IN_BACK)
				Format(sResult, sizeof(sResult), "%s S", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);
			if (Buttons & IN_MOVERIGHT)
				Format(sResult, sizeof(sResult), "%s D", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);
			if (Buttons & IN_DUCK || ((GetEngineTime() - g_fCrouchButtonLastTimeUsed[ObservedUser]) < 0.05))
				Format(sResult, sizeof(sResult), "%s - C", sResult);
			else
				Format(sResult, sizeof(sResult), "%s - _", sResult);
			if (Buttons & IN_JUMP || ((GetEngineTime() - g_fJumpButtonLastTimeUsed[ObservedUser]) < 0.05))
				Format(sResult, sizeof(sResult), "%s J", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);

			//infopanel
			PrintCenterPanelToClient(client,ObservedUser,sResult);
		}
	}
	else
		g_SpecTarget[client] = -1;

}

public CenterHudAlive(client)
{
	if (!IsValidClient(client))
		return;

	//menu check
	if (!g_bTimeractivated[client])
	{
		if (g_bClimbersMenuOpen[client] && !g_bMenuOpen[client])
			ClimbersMenu(client);
		else
			if (g_bClimbersMenuwasOpen[client]  && !g_bMenuOpen[client])
			{
				g_bClimbersMenuwasOpen[client]=false;
				ClimbersMenu(client);
			}
			else
				PlayerPanel(client);
	}

	if (g_bInfoPanel[client] && !g_bOverlay[client])
	{
		decl String:sResult[32];
		decl Buttons;
		Buttons = g_LastButton[client];
		if (Buttons & IN_MOVELEFT)
			Format(sResult, sizeof(sResult), "<b>Keys</b>: A");
		else
			Format(sResult, sizeof(sResult), "<b>Keys</b>: _");
		if (Buttons & IN_FORWARD)
			Format(sResult, sizeof(sResult), "%s W", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);
		if (Buttons & IN_BACK)
			Format(sResult, sizeof(sResult), "%s S", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);
		if (Buttons & IN_MOVERIGHT)
			Format(sResult, sizeof(sResult), "%s D", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);
		if (Buttons & IN_DUCK || ((GetEngineTime() - g_fCrouchButtonLastTimeUsed[client]) < 0.05))
			Format(sResult, sizeof(sResult), "%s - C", sResult);
		else
			Format(sResult, sizeof(sResult), "%s - _", sResult);
		if (Buttons & IN_JUMP || ((GetEngineTime() - g_fJumpButtonLastTimeUsed[client]) < 0.05))
			Format(sResult, sizeof(sResult), "%s J", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);

		PrintCenterPanelToClient(client,client,sResult);
	}
}


public PrintCenterPanelToClient(client,target, String:sKeys[32])
{
	if (!IsValidClient(client))
		return;

	decl String:sPreStrafe[128];
	if (g_bJumpStats)
	{
		if (g_js_bPlayerJumped[target])
		{
			if (!g_bAdvInfoPanel[client])
				PrintHintText(client,"<font color='#948d8d'><b>Last</b>: %s\n<b>Speed</b>: %.1f u/s (%.0f)\n%s</font>",g_js_szLastJumpDistance[target],g_fLastSpeed[target],g_js_fPreStrafe[target],sKeys);
			else
			{
				//LJ?
				if (!g_bLadderJump[target] && g_js_GroundFrames[target] > 11)
				{
					if (g_js_bPerfJumpOff[target])
					{
						if (g_js_bPerfJumpOff2[target])
							Format(sPreStrafe, sizeof(sPreStrafe), "%.0f, CJ <font color='#21982a'>✔</font> -W <font color='#21982a'>✓</font>", g_js_fPreStrafe[target]);
						else
							Format(sPreStrafe, sizeof(sPreStrafe), "%.0f, CJ <font color='#21982a'>✔</font> -W <font color='#9a0909'>Х</font>", g_js_fPreStrafe[target]);
					}
					else
					{
						if (g_js_bPerfJumpOff2[target])
							Format(sPreStrafe, sizeof(sPreStrafe), "%.0f, CJ <font color='#9a0909'>Х</font> -W <font color='#21982a'>✓</font>", g_js_fPreStrafe[target]);
						else
							Format(sPreStrafe, sizeof(sPreStrafe), "%.0f, CJ <font color='#9a0909'>Х</font> -W <font color='#9a0909'>Х</font>", g_js_fPreStrafe[target]);
					}

					PrintHintText(client,"<b>Last</b>: %s\n<b>Speed</b>: %.0f u/s (%s)\n%s",g_js_szLastJumpDistance[target],g_fLastSpeed[target],sPreStrafe,sKeys);
				}
				else
					PrintHintText(client,"<b>Last</b>: %s\n<b>Speed</b>: %.1f u/s (%.0f)\n%s",g_js_szLastJumpDistance[target],g_fLastSpeed[target],g_js_fPreStrafe[target],sKeys);
			}
		}
		else //cc
			PrintHintText(client,"<font color='#948d8d'><b>Last</b>: %s\n<b>Speed</b>: %.1f u/s\n%s</font>",g_js_szLastJumpDistance[target],g_fLastSpeed[target],sKeys);
	}
	else
		PrintHintText(client,"<font color='#948d8d'><b>Speed</b>: %.1f u/s\n<b>Velocity</b>: %.1f u/s\n%s</font>",g_fLastSpeed[target],GetVelocity(target),sKeys);

}

// https://forums.alliedmods.net/showthread.php?t=178279
//  [ANY] RTLer - Support for Right-to-Left Languages
RTLify(String:dest[1024], String:original[1024])
{
	new rtledWords = 0;

	new String:tokens[96][96];
	new String:words[sizeof(tokens)][sizeof(tokens[])];

	new n = ExplodeString(original, " ", tokens, sizeof(tokens), sizeof(tokens[]));

	for (new word = 0; word < n; word++)
	{
		if (WordAnalysis(tokens[word]) >= 0.1)
		{
			ReverseString(tokens[word], sizeof(tokens[]), words[n-1-word]);
			rtledWords++;
		}
		else
		{
			new firstWord = word;
			new lastWord = word;

			while (WordAnalysis(tokens[lastWord]) < 0.1)
			{
				lastWord++;
			}

			for (new t = lastWord - 1; t >= firstWord; t--)
			{
				strcopy(words[n-1-word], sizeof(tokens[]), tokens[t]);

				if (t > firstWord)
					word++;
			}
		}
	}

	ImplodeStrings(words, n, " ", dest, sizeof(words[]));
	return rtledWords;
}

// https://forums.alliedmods.net/showthread.php?t=178279
//  [ANY] RTLer - Support for Right-to-Left Languages
ReverseString(String:str[], maxlength, String:buffer[])
{
	for (new character = strlen(str); character >= 0; character--)
	{
		if (str[character] >= 0xD6 && str[character] <= 0xDE)
			continue;

		if (character > 0 && str[character - 1] >= 0xD7 && str[character - 1] <= 0xD9)
			Format(buffer, maxlength, "%s%c%c", buffer, str[character - 1], str[character]);
		else
			Format(buffer, maxlength, "%s%c", buffer, str[character]);
	}
}

// https://forums.alliedmods.net/showthread.php?t=178279
//  [ANY] RTLer - Support for Right-to-Left Languages
Float:WordAnalysis(String:word[])
{
	new count = 0, length = strlen(word);

	for (new n = 0; n < length - 1; n++)
	{
		if (IsRTLCharacter(word, n))
		{
			count++;
			n++;
		}
	}

	return float(count) * 2 / length;
}

// https://forums.alliedmods.net/showthread.php?t=178279
//  [ANY] RTLer - Support for Right-to-Left Languages
bool:IsRTLCharacter(String:str[], n)
{
	return (str[n] >= 0xD6 && str[n] <= 0xDE && str[n + 1] >= 0x80 && str[n + 1] <= 0xBF);
}

// https://forums.alliedmods.net/showpost.php?p=2308824&postcount=4
// by Mehis
public DoubleDuck(client,&buttons)
{
    if (!IsValidClient(client) || !IsPlayerAlive( client ) || (g_bTimeractivated[client] && !g_bDoubleDuckCvar))
		return;

    static int fFlags;
    fFlags = GetEntityFlags( client );

    if ( fFlags & FL_ONGROUND )
    {
        static bool bAllowDoubleDuck[MAXPLAYERS];

        if ( fFlags & FL_DUCKING )
        {
            bAllowDoubleDuck[client] = false;
            return;
        }

        if ( buttons & IN_DUCK )
        {
            bAllowDoubleDuck[client] = true;
            return;
        }

        if ( GetEntProp( client, Prop_Data, "m_bDucking" ) && bAllowDoubleDuck[client] )
        {
            float vecPos[3];
            GetClientAbsOrigin( client, vecPos );
            vecPos[2] += 40.0;
            if (IsValidPlayerPos(client, vecPos))
			{
				g_js_GroundFrames[client] = 0;
				DoValidTeleport(client, vecPos,NULL_VECTOR,NULL_VECTOR);
				g_js_DuckCounter[client]++;
				g_fLastTimeDoubleDucked[client] = GetEngineTime();
			}
        }

    }
}

// https://forums.alliedmods.net/showpost.php?p=2308824&postcount=4
// by Mehis
public bool IsValidPlayerPos( int client, float vecPos[3] )
{
    static const float vecMins[] = { -16.0, -16.0, 0.0 };
    static const float vecMaxs[] = { 16.0, 16.0, 72.0 };

    TR_TraceHullFilter( vecPos, vecPos, vecMins, vecMaxs, MASK_SOLID, TraceFilter_IgnorePlayer, client );

    return ( !TR_DidHit( null ) );
}

// https://forums.alliedmods.net/showpost.php?p=2308824&postcount=4
// by Mehis
public bool TraceFilter_IgnorePlayer( int ent, int mask, any ignore_me )
{
    return ( ent != ignore_me );
}

public RegServerConVars()
{
	CreateConVar("kztimer_version", VERSION, "kztimer Version.", FCVAR_DONTRECORD|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	g_hDoubleDuckCvar = 	CreateConVar("kz_double_duck", "0", "on/off - Allows you to get up edges that are 32 units high or less without jumping (double duck is always enabled if your timer is disabled; 0 required for global records)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bDoubleDuckCvar     = GetConVarBool(g_hDoubleDuckCvar);
	HookConVarChange(g_hDoubleDuckCvar, OnSettingChanged);

	g_hSlayPlayers = 	CreateConVar("kz_slay_on_endbutton_press", "0", "on/off - Slays other players when someone finishs the map. (helpful on mg_ course maps)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bSlayPlayers     = GetConVarBool(g_hSlayPlayers);
	HookConVarChange(g_hSlayPlayers, OnSettingChanged);

	g_hAllowRoundEndCvar = CreateConVar("kz_round_end", "0", "on/off - Allows to end the current round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAllowRoundEndCvar     = GetConVarBool(g_hAllowRoundEndCvar);
	HookConVarChange(g_hAllowRoundEndCvar, OnSettingChanged);

	g_hConnectMsg = CreateConVar("kz_connect_msg", "1", "on/off - Enables a player connect message with country and disconnect message in chat", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bConnectMsg     = GetConVarBool(g_hConnectMsg);
	HookConVarChange(g_hConnectMsg, OnSettingChanged);

	g_hMapEnd = CreateConVar("kz_map_end", "1", "on/off - Allows to end the current map when the timelimit has run out (mp_timelimit must be greater than 0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bMapEnd     = GetConVarBool(g_hMapEnd);
	HookConVarChange(g_hMapEnd, OnSettingChanged);

	g_hTransPlayerModels = CreateConVar("kz_player_transparency", "80", "Modifies the transparency of players. 0 is invisible and 255 is visible", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	g_TransPlayerModels = GetConVarInt(g_hTransPlayerModels);
	HookConVarChange(g_hTransPlayerModels, OnSettingChanged);

	g_hReplayBot = CreateConVar("kz_replay_bot", "1", "on/off - Bots mimic the local tp and pro record", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bReplayBot     = GetConVarBool(g_hReplayBot);
	HookConVarChange(g_hReplayBot, OnSettingChanged);

	g_hPreStrafe = CreateConVar("kz_prestrafe", "1", "on/off - Prestrafe", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPreStrafe     = GetConVarBool(g_hPreStrafe);
	HookConVarChange(g_hPreStrafe, OnSettingChanged);

	g_hInfoBot	  = CreateConVar("kz_info_bot", "0", "on/off - provides information about nextmap and timeleft in his player name", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bInfoBot     = GetConVarBool(g_hInfoBot);
	HookConVarChange(g_hInfoBot, OnSettingChanged);

	g_hNoClipS = CreateConVar("kz_noclip", "1", "on/off - Allows players to use noclip when they have finished the map", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bNoClipS     = GetConVarBool(g_hNoClipS);
	HookConVarChange(g_hNoClipS, OnSettingChanged);

	g_hVipClantag = 	CreateConVar("kz_vip_clantag", "1", "on/off - VIP clan tag (necessary flag: a)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bVipClantag     = GetConVarBool(g_hVipClantag);
	HookConVarChange(g_hVipClantag, OnSettingChanged);

	g_hTierMessages = CreateConVar("kz_tier_messages", "1", "on/off - Allows server to display messages about tiers", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bTierMessages = GetConVarBool(g_hTierMessages);
	HookConVarChange(g_hTierMessages, OnSettingChanged);

	g_hAdminClantag = 	CreateConVar("kz_admin_clantag", "1", "on/off - Admin clan tag (necessary flag: b - z)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAdminClantag     = GetConVarBool(g_hAdminClantag);
	HookConVarChange(g_hAdminClantag, OnSettingChanged);

	g_hAutoTimer = CreateConVar("kz_auto_timer", "0", "on/off - Timer starts automatically when a player joins a team, dies or uses !start/!r (0 required for global records)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoTimer     = GetConVarBool(g_hAutoTimer);
	HookConVarChange(g_hAutoTimer, OnSettingChanged);

	g_hGoToServer = CreateConVar("kz_goto", "1", "on/off - Allows players to use the !goto command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bGoToServer     = GetConVarBool(g_hGoToServer);
	HookConVarChange(g_hGoToServer, OnSettingChanged);

	g_hcvargodmode = CreateConVar("kz_godmode", "1", "on/off - unlimited hp", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bgodmode     = GetConVarBool(g_hcvargodmode);
	HookConVarChange(g_hcvargodmode, OnSettingChanged);

	g_hPauseServerside    = CreateConVar("kz_pause", "1", "on/off - Allows players to use the !pause command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPauseServerside    = GetConVarBool(g_hPauseServerside);
	HookConVarChange(g_hPauseServerside, OnSettingChanged);

	g_hSingleTouch    = CreateConVar("kz_bhop_single_touch", "0", "on/off - Disallows players to touch a single bhop block multiple times", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bSingleTouch    = GetConVarBool(g_hSingleTouch);
	HookConVarChange(g_hSingleTouch, OnSettingChanged);

	g_hcvarRestore    = CreateConVar("kz_restore", "1", "on/off - Restoring of time and last position after reconnect", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bRestore        = GetConVarBool(g_hcvarRestore);
	HookConVarChange(g_hcvarRestore, OnSettingChanged);

	g_hAttackSpamProtection    = CreateConVar("kz_attack_spam_protection", "1", "on/off - max 40 shots; +5 new/extra shots per minute; 1 he/flash counts like 9 shots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAttackSpamProtection       = GetConVarBool(g_hAttackSpamProtection);
	HookConVarChange(g_hAttackSpamProtection, OnSettingChanged);

	g_hAllowCheckpoints = CreateConVar("kz_checkpoints", "1", "on/off - Allows player to do checkpoints", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAllowCheckpoints     = GetConVarBool(g_hAllowCheckpoints);
	HookConVarChange(g_hAllowCheckpoints, OnSettingChanged);

	g_hEnforcer = CreateConVar("kz_settings_enforcer", "1", "on/off - Kreedz settings enforcer (1 required for global records)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bEnforcer     = GetConVarBool(g_hEnforcer);
	HookConVarChange(g_hEnforcer, OnSettingChanged);

	g_hAutoRespawn = CreateConVar("kz_autorespawn", "1", "on/off - Auto respawn", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoRespawn     = GetConVarBool(g_hAutoRespawn);
	HookConVarChange(g_hAutoRespawn, OnSettingChanged);

	g_hRadioCommands = CreateConVar("kz_use_radio", "0", "on/off - Allows players to use radio commands", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bRadioCommands     = GetConVarBool(g_hRadioCommands);
	HookConVarChange(g_hRadioCommands, OnSettingChanged);

	g_hTeam_Restriction 	= CreateConVar("kz_team_restriction", "0", "Team restriction (0 = both allowed, 1 = only ct allowed, 2 = only t allowed)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	g_Team_Restriction     = GetConVarInt(g_hTeam_Restriction);
	HookConVarChange(g_hTeam_Restriction, OnSettingChanged);

	g_hAutohealing_Hp 	= CreateConVar("kz_autoheal", "50", "Sets HP amount for autohealing (requires kz_godmode 0)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_Autohealing_Hp     = GetConVarInt(g_hAutohealing_Hp);
	HookConVarChange(g_hAutohealing_Hp, OnSettingChanged);

	g_hCleanWeapons 	= CreateConVar("kz_clean_weapons", "1", "on/off - Removes all weapons on the ground", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bCleanWeapons     = GetConVarBool(g_hCleanWeapons);
	HookConVarChange(g_hCleanWeapons, OnSettingChanged);

	g_hJumpStats 	= CreateConVar("kz_jumpstats", "1", "on/off - Measuring of jump distances (longjump, weirdjump, bhop, dropbhop, multibhop, ladderjump)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bJumpStats     = GetConVarBool(g_hJumpStats);
	HookConVarChange(g_hJumpStats, OnSettingChanged);

	g_hCountry 	= CreateConVar("kz_country_tag", "1", "on/off - Country clan tag", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bCountry     = GetConVarBool(g_hCountry);
	HookConVarChange(g_hCountry, OnSettingChanged);

	g_hChallengePoints 	= CreateConVar("kz_challenge_points", "1", "on/off - Allows players to bet points on their challenges", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bChallengePoints     = GetConVarBool(g_hChallengePoints);
	HookConVarChange(g_hChallengePoints, OnSettingChanged);

	g_hAutoBhopConVar 	= CreateConVar("kz_auto_bhop", "0", "on/off - AutoBhop on bhop_ and surf_ maps (climb maps are not supported)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoBhopConVar     = GetConVarBool(g_hAutoBhopConVar);
	HookConVarChange(g_hAutoBhopConVar, OnSettingChanged);

	g_hDynamicTimelimit 	= CreateConVar("kz_dynamic_timelimit", "1", "on/off - Sets a suitable timelimit by calculating the average run time (This method requires kz_map_end 1, greater than 5 map times and a default timelimit in your server config for maps with less than 5 times", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bDynamicTimelimit     = GetConVarBool(g_hDynamicTimelimit);
	HookConVarChange(g_hDynamicTimelimit, OnSettingChanged);

	g_hBhopSpeedCap   = CreateConVar("kz_prespeed_cap", "380.0", "Limits player's pre speed (kz_settings_enforcer must be disabled)", FCVAR_NOTIFY, true, 300.0, true, 5000.0);
	g_fBhopSpeedCap    = GetConVarFloat(g_hBhopSpeedCap);
	HookConVarChange(g_hBhopSpeedCap, OnSettingChanged);

	g_hMinSkillGroup   = CreateConVar("kz_min_skill_group", "1.0", "Minimum skill group to play on this server excluding vips and admins. Everyone below the chosen skill group gets kicked. (1=NEW,2=SCRUB,3=TRAINEE,4=CASUAL,5=REGULAR,6=SKILLED,7=EXPERT,8=SEMIPRO,9=PRO)", FCVAR_NOTIFY, true, 1.0, true, 9.0);
	g_MinSkillGroup    = GetConVarInt(g_hMinSkillGroup);
	HookConVarChange(g_hMinSkillGroup, OnSettingChanged);

	g_hExtraPoints   = CreateConVar("kz_ranking_extra_points_improvements", "10.0", "Gives players x extra points for improving their time.", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_ExtraPoints    = GetConVarInt(g_hExtraPoints);
	HookConVarChange(g_hExtraPoints, OnSettingChanged);

	g_hExtraPoints2   = CreateConVar("kz_ranking_extra_points_firsttime", "25.0", "Gives players x (tp time = x, pro time = 2 * x) extra points for finishing a map (tp and pro) for the first time.", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_ExtraPoints2    = GetConVarInt(g_hExtraPoints2);
	HookConVarChange(g_hExtraPoints2, OnSettingChanged);

	g_hSpecsAdvert   = CreateConVar("kz_speclist_advert_interval", "300.0", "Amount of seconds between spectator list advertisements in chat. This advert appears when there are more than 2 spectators.", FCVAR_NOTIFY, true, 60.0, true, 9999.0);
	g_fSpecsAdvert    = GetConVarFloat(g_hSpecsAdvert);
	HookConVarChange(g_hSpecsAdvert, OnSettingChanged);

	g_hPointSystem    = CreateConVar("kz_point_system", "1", "on/off - Player point system", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPointSystem    = GetConVarBool(g_hPointSystem);
	HookConVarChange(g_hPointSystem, OnSettingChanged);

	g_hPlayerSkinChange 	= CreateConVar("kz_custom_models", "1", "on/off - Allows kztimer to change the models of players and bots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bPlayerSkinChange     = GetConVarBool(g_hPlayerSkinChange);
	HookConVarChange(g_hPlayerSkinChange, OnSettingChanged);

	g_hReplayBotPlayerModel2   = CreateConVar("kz_replay_tpbot_skin", "models/player/tm_professional_var1.mdl", "Replay tp bot skin", FCVAR_NOTIFY);
	GetConVarString(g_hReplayBotPlayerModel2,g_sReplayBotPlayerModel2,256);
	HookConVarChange(g_hReplayBotPlayerModel2, OnSettingChanged);

	g_hReplayBotArmModel2   = CreateConVar("kz_replay_tpbot_arm_skin", "models/weapons/t_arms_professional.mdl", "Replay tp bot arm skin", FCVAR_NOTIFY);
	GetConVarString(g_hReplayBotArmModel2,g_sReplayBotArmModel2,256);
	HookConVarChange(g_hReplayBotArmModel2, OnSettingChanged);

	g_hReplayBotPlayerModel   = CreateConVar("kz_replay_probot_skin", "models/player/tm_professional_var1.mdl", "Replay pro bot skin", FCVAR_NOTIFY);
	GetConVarString(g_hReplayBotPlayerModel,g_sReplayBotPlayerModel,256);
	HookConVarChange(g_hReplayBotPlayerModel, OnSettingChanged);

	g_hReplayBotArmModel   = CreateConVar("kz_replay_probot_arm_skin", "models/weapons/t_arms_professional.mdl", "Replay pro bot arm skin", FCVAR_NOTIFY);
	GetConVarString(g_hReplayBotArmModel,g_sReplayBotArmModel,256);
	HookConVarChange(g_hReplayBotArmModel, OnSettingChanged);

	g_hPlayerModel   = CreateConVar("kz_player_skin", "models/player/ctm_sas_varianta.mdl", "Player skin", FCVAR_NOTIFY);
	GetConVarString(g_hPlayerModel,g_sPlayerModel,256);
	HookConVarChange(g_hPlayerModel, OnSettingChanged);

	g_hArmModel   = CreateConVar("kz_player_arm_skin", "models/weapons/ct_arms_sas.mdl", "Player arm skin", FCVAR_NOTIFY);
	GetConVarString(g_hArmModel,g_sArmModel,256);
	HookConVarChange(g_hArmModel, OnSettingChanged);

	g_hWelcomeMsg   = CreateConVar("kz_welcome_msg", " {yellow}>>{default} {grey}Welcome! This server is using {lime}KZTimer Global","Welcome message (supported color tags: {default}, {darkred}, {green}, {lightgreen}, {blue} {olive}, {lime}, {red}, {purple}, {grey},  {yellow}, {lightblue}, {steelblue}, {darkblue}, {pink}, {lightred})", FCVAR_NOTIFY);
	GetConVarString(g_hWelcomeMsg,g_sWelcomeMsg,512);
	HookConVarChange(g_hWelcomeMsg, OnSettingChanged);

	g_hDefaultLanguage 	= CreateConVar("kz_default_language", "0", "default language of kztimer (0: english,  1: german, 2: swedish, 3: french, 4: russian, 5: simplified chinese, 6: portuguese brazilian)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_DefaultLanguage     = GetConVarInt(g_hDefaultLanguage);
	HookConVarChange(g_hDefaultLanguage, OnSettingChanged);

	g_hReplayBotProColor   = CreateConVar("kz_replay_bot_pro_color", "52 91 248","The default pro replay bot color - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotProColor, OnSettingChanged);
	decl String:szProColor[256];
	GetConVarString(g_hReplayBotProColor,szProColor,256);
	GetRGBColor(0,szProColor);

	g_hReplayBotTpColor   = CreateConVar("kz_replay_bot_tp_color", "223 213 0","The default tp replay bot color - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotTpColor, OnSettingChanged);
	decl String:szTpColor[256];
	GetConVarString(g_hReplayBotTpColor,szTpColor,256);
	GetRGBColor(1,szTpColor);

	g_hAutoBan 	= CreateConVar("kz_anticheat_auto_ban", "1", "on/off - auto-ban (bhop hack) including deletion of their records (anti-cheat log: sourcemod/logs)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bAutoBan     = GetConVarBool(g_hAutoBan);
	HookConVarChange(g_hAutoBan, OnSettingChanged);

	g_hEnableChatProcessing = CreateConVar("kz_chat_enable", "1", "Enable or disable KZ Timer chat processing.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bEnableChatProcessing = GetConVarBool(g_hEnableChatProcessing);
	HookConVarChange(g_hEnableChatProcessing, OnSettingChanged);
	
	g_hEnableGroupAdverts = CreateConVar("kz_steamgroup_advert", "1", "Enable or disable KZTimer's steamgroup adverts", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bEnableGroupAdverts = GetConVarBool(g_hEnableGroupAdverts);
	HookConVarChange(g_hEnableGroupAdverts, OnSettingChanged);
	
	g_hBanDuration   = CreateConVar("kz_anticheat_ban_duration", "72.0", "Ban duration in hours", FCVAR_NOTIFY, true, 0.0, true, 999999.0);
	
	//settings enforcer
	g_hFullAlltalk = FindConVar("sv_full_alltalk");
	g_hStaminaLandCost = FindConVar("sv_staminalandcost");
	g_hStaminaJumpCost = FindConVar("sv_staminajumpcost");
	g_hGravity = FindConVar("sv_gravity");
	g_hAirAccelerate = FindConVar("sv_airaccelerate");
	g_hMaxSpeed = FindConVar("sv_maxspeed");
	g_hWaterAccelerate = FindConVar("sv_wateraccelerate");
	g_hFriction = FindConVar("sv_friction");
	g_hAccelerate = FindConVar("sv_accelerate");
	g_hMaxVelocity = FindConVar("sv_maxvelocity");
	g_hCheats = FindConVar("sv_cheats");
	g_hDropKnifeEnable = FindConVar("sv_cheats");
	g_hEnableBunnyhoping = FindConVar("sv_enablebunnyhopping");

  // New convars
	g_hAutoBhop= FindConVar("sv_autobunnyhopping");
	g_hClampVel= FindConVar("sv_clamp_unsafe_velocities");
	g_hJumpImpulse = FindConVar("sv_jump_impulse");
	g_hAccelerateUseWeaponSpeed = FindConVar("sv_accelerate_use_weapon_speed");
	g_hWaterMovespeedMultiplier = FindConVar("sv_water_movespeed_multiplier");
	g_hWaterSwimMode = FindConVar("sv_water_swim_mode");
	g_hWeaponEncumbranceScale = FindConVar("sv_weapon_encumbrance_scale");
	g_hAirMaxWishspeed = FindConVar("sv_air_max_wishspeed");
	g_hLedgeMantleHelper = FindConVar("sv_ledge_mantle_helper");
	g_hStandableNormal = FindConVar("sv_standable_normal");
	g_hWalkableNormal = FindConVar("sv_walkable_normal");
	g_hAmmoGrenadeLimitBumpmine = FindConVar("ammo_grenade_limit_bumpmine");
	g_hBumpmineDetonateDelay = FindConVar("sv_bumpmine_detonate_delay");
	g_hShieldSpeedDeployed = FindConVar("mp_shield_speed_deployed");
	g_hShieldSpeedHolstered = FindConVar("mp_shield_speed_holstered");
	g_hExojumpJumpbonusForward = FindConVar("sv_exojump_jumpbonus_forward");
	g_hExojumpJumpbonusUp = FindConVar("sv_exojump_jumpbonus_up");
	g_hExojumpJumpcost = FindConVar("sv_exostaminajumpcost");
	g_hExojumpLandcost = FindConVar("sv_exostaminalandcost");
	g_hJumpImpulseExojumpMultiplier = FindConVar("sv_jump_impulse_exojump_multiplier");

	g_hsv_ladder_scale_speed = FindConVar("sv_ladder_scale_speed");
	g_hMaxRounds = FindConVar("mp_maxrounds");
	HookConVarChange(g_hStaminaLandCost, OnSettingChanged);
	HookConVarChange(g_hStaminaJumpCost, OnSettingChanged);
	HookConVarChange(g_hMaxSpeed, OnSettingChanged);
	HookConVarChange(g_hGravity, OnSettingChanged);
	HookConVarChange(g_hWaterAccelerate, OnSettingChanged);
	HookConVarChange(g_hAirAccelerate, OnSettingChanged);
	HookConVarChange(g_hFriction, OnSettingChanged);
	HookConVarChange(g_hAccelerate, OnSettingChanged);
	HookConVarChange(g_hMaxVelocity, OnSettingChanged);
	HookConVarChange(g_hCheats, OnSettingChanged);
	HookConVarChange(g_hDropKnifeEnable, OnSettingChanged);
	HookConVarChange(g_hEnableBunnyhoping, OnSettingChanged);
	HookConVarChange(g_hAutoBhop, OnSettingChanged);
	HookConVarChange(g_hClampVel, OnSettingChanged);
	HookConVarChange(g_hsv_ladder_scale_speed, OnSettingChanged);
	HookConVarChange(g_hMaxRounds, OnSettingChanged);
	HookConVarChange(g_hJumpImpulse, OnSettingChanged);
	HookConVarChange(g_hAccelerateUseWeaponSpeed, OnSettingChanged);
	HookConVarChange(g_hWaterMovespeedMultiplier, OnSettingChanged);
	HookConVarChange(g_hWaterSwimMode, OnSettingChanged);
	HookConVarChange(g_hWeaponEncumbranceScale, OnSettingChanged);
	HookConVarChange(g_hAirMaxWishspeed, OnSettingChanged);
	HookConVarChange(g_hLedgeMantleHelper, OnSettingChanged);
	HookConVarChange(g_hStandableNormal, OnSettingChanged);
	HookConVarChange(g_hWalkableNormal, OnSettingChanged);
	HookConVarChange(g_hAmmoGrenadeLimitBumpmine, OnSettingChanged);
	HookConVarChange(g_hBumpmineDetonateDelay, OnSettingChanged);
	HookConVarChange(g_hShieldSpeedDeployed, OnSettingChanged);
	HookConVarChange(g_hShieldSpeedHolstered, OnSettingChanged);
	HookConVarChange(g_hExojumpJumpbonusForward, OnSettingChanged);
	HookConVarChange(g_hExojumpJumpbonusUp, OnSettingChanged);
	HookConVarChange(g_hExojumpJumpcost, OnSettingChanged);
	HookConVarChange(g_hExojumpLandcost, OnSettingChanged);
	HookConVarChange(g_hJumpImpulseExojumpMultiplier, OnSettingChanged);

	if (g_Server_Tickrate == 64)
	{
		g_hMaxBhopPreSpeed   = CreateConVar("kz_max_prespeed_bhop_dropbhop", "325.0", "Max counted pre speed for bhop,dropbhop (no speed limiter)", FCVAR_NOTIFY, true, 300.0, true, 400.0);
		g_hdist_good_countjump    	= CreateConVar("kz_dist_min_cj", "240.0", "Minimum distance for count jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_perfect_countjump   	= CreateConVar("kz_dist_perfect_cj", "240.0", "Minimum distance for count jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
		g_hdist_impressive_countjump   	= CreateConVar("kz_dist_impressive_cj", "245.0", "Minimum distance for count jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
		g_hdist_godlike_countjump    	= CreateConVar("kz_dist_god_cj", "250.0", "Minimum distance for count jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
		g_hdist_good_lj    	= CreateConVar("kz_dist_min_lj", "235.0", "Minimum distance for long jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_perfect_lj   	= CreateConVar("kz_dist_perfect_lj", "250.0", "Minimum distance for long jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
		g_hdist_impressive_lj   	= CreateConVar("kz_dist_impressive_lj", "255.0", "Minimum distance for long jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
		g_hdist_godlike_lj    	= CreateConVar("kz_dist_god_lj", "260.0", "Minimum distance for long jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
		g_hdist_good_weird  = CreateConVar("kz_dist_min_wj", "250.0", "Minimum distance for weird jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_perfect_weird  = CreateConVar("kz_dist_perfect_wj", "260.0", "Minimum distance for weird jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_impressive_weird  = CreateConVar("kz_dist_impressive_wj", "265.0", "Minimum distance for weird jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_godlike_weird   = CreateConVar("kz_dist_god_wj", "270.0", "Minimum distance for weird jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_good_dropbhop  = CreateConVar("kz_dist_min_dropbhop", "240.0", "Minimum distance for drop bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_perfect_dropbhop  = CreateConVar("kz_dist_perfect_dropbhop", "285.0", "Minimum distance for drop bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_impressive_dropbhop  = CreateConVar("kz_dist_impressive_dropbhop", "290.0", "Minimum distance for drop bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_godlike_dropbhop   = CreateConVar("kz_dist_god_dropbhop", "290.0", "Minimum distance for drop bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_good_bhop  = CreateConVar("kz_dist_min_bhop", "240.0", "Minimum distance for bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_perfect_bhop  = CreateConVar("kz_dist_perfect_bhop", "285.0", "Minimum distance for bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_impressive_bhop  = CreateConVar("kz_dist_impressive_bhop", "290.0", "Minimum distance for bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_godlike_bhop   = CreateConVar("kz_dist_god_bhop", "295.0", "Minimum distance for bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
		g_hdist_good_multibhop  = CreateConVar("kz_dist_min_multibhop", "300.0", "Minimum distance for multi-bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
		g_hdist_perfect_multibhop  = CreateConVar("kz_dist_perfect_multibhop", "330.0", "Minimum distance for multi-bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
		g_hdist_impressive_multibhop  = CreateConVar("kz_dist_impressive_multibhop", "335.0", "Minimum distance for multi-bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
		g_hdist_godlike_multibhop   = CreateConVar("kz_dist_god_multibhop", "340.0", "Minimum distance for multi-bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
		g_hdist_good_ladder  = CreateConVar("kz_dist_min_ladder", "100.0", "Minimum distance for ladder jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 70.0, true, 9999.0);
		g_hdist_perfect_ladder  = CreateConVar("kz_dist_perfect_ladder", "150.0", "Minimum distance for ladder jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
		g_hdist_impressive_ladder  = CreateConVar("kz_dist_impressive_ladder", "155.0", "Minimum distance for ladder jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
		g_hdist_godlike_ladder   = CreateConVar("kz_dist_god_ladder", "160.0", "Minimum distance for ladder jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
		// Golden jumpstats
		g_hdist_golden_countjump = 260.0;
		g_hdist_golden_lj = 265.0;
		g_hdist_golden_weird = 285.0;
		g_hdist_golden_dropbhop = 300.0;
		g_hdist_golden_bhop = 310.0;
		g_hdist_golden_multibhop = 350.0;
		g_hdist_golden_ladder = 175.0;
	}
	else
	{
		if (g_Server_Tickrate == 128)
		{
			g_hMaxBhopPreSpeed   = CreateConVar("kz_max_prespeed_bhop_dropbhop", "360.0", "Max counted pre speed for bhop,dropbhop (no speed limiter)", FCVAR_NOTIFY, true, 300.0, true, 400.0);
			g_hdist_good_countjump    	= CreateConVar("kz_dist_min_cj", "240.0", "Minimum distance for count jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_countjump   	= CreateConVar("kz_dist_perfect_cj", "285.0", "Minimum distance for count jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_impressive_countjump   	= CreateConVar("kz_dist_impressive_cj", "290.0", "Minimum distance for count jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_godlike_countjump    	= CreateConVar("kz_dist_god_cj", "295.0", "Minimum distance for count jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
			g_hdist_good_lj    	= CreateConVar("kz_dist_min_lj", "240.0", "Minimum distance for long jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_lj   	= CreateConVar("kz_dist_perfect_lj", "265.0", "Minimum distance for long jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_impressive_lj   	= CreateConVar("kz_dist_impressive_lj", "270.0", "Minimum distance for long jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_godlike_lj    	= CreateConVar("kz_dist_god_lj", "275.0", "Minimum distance for long jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
			g_hdist_good_weird  = CreateConVar("kz_dist_min_wj", "250.0", "Minimum distance for weird jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_weird  = CreateConVar("kz_dist_perfect_wj", "280.0", "Minimum distance for weird jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_impressive_weird  = CreateConVar("kz_dist_impressive_wj", "285.0", "Minimum distance for weird jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_godlike_weird   = CreateConVar("kz_dist_god_wj", "290.0", "Minimum distance for weird jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_dropbhop  = CreateConVar("kz_dist_min_dropbhop", "240.0", "Minimum distance for drop bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_dropbhop  = CreateConVar("kz_dist_perfect_dropbhop", "315.0", "Minimum distance for drop bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_impressive_dropbhop  = CreateConVar("kz_dist_impressive_dropbhop", "320.0", "Minimum distance for drop bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_godlike_dropbhop   = CreateConVar("kz_dist_god_dropbhop", "325.0", "Minimum distance for drop bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_bhop  = CreateConVar("kz_dist_min_bhop", "240.0", "Minimum distance for bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_bhop  = CreateConVar("kz_dist_perfect_bhop", "320.0", "Minimum distance for bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_impressive_bhop  = CreateConVar("kz_dist_impressive_bhop", "325.0", "Minimum distance for bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_godlike_bhop   = CreateConVar("kz_dist_god_bhop", "330.0", "Minimum distance for bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_multibhop  = CreateConVar("kz_dist_min_multibhop", "300.0", "Minimum distance for multi-bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_perfect_multibhop  = CreateConVar("kz_dist_perfect_multibhop", "340.0", "Minimum distance for multi-bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_impressive_multibhop  = CreateConVar("kz_dist_impressive_multibhop", "345.0", "Minimum distance for multi-bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_godlike_multibhop   = CreateConVar("kz_dist_god_multibhop", "350.0", "Minimum distance for multi-bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_good_ladder  = CreateConVar("kz_dist_min_ladder", "100.0", "Minimum distance for ladder jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 70.0, true, 9999.0);
			g_hdist_perfect_ladder  = CreateConVar("kz_dist_perfect_ladder", "155.0", "Minimum distance for ladder jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
			g_hdist_impressive_ladder  = CreateConVar("kz_dist_impressive_ladder", "165.0", "Minimum distance for ladder jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
			g_hdist_godlike_ladder   = CreateConVar("kz_dist_god_ladder", "175.0", "Minimum distance for ladder jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
			// Golden jumpstats
			g_hdist_golden_countjump = 305.0;
			g_hdist_golden_lj = 285.0;
			g_hdist_golden_weird = 300.0;
			g_hdist_golden_dropbhop = 340.0;
			g_hdist_golden_bhop = 342.0;
			g_hdist_golden_multibhop = 358.0;
			g_hdist_golden_ladder = 193.0;

		}
		else
		{
			g_hMaxBhopPreSpeed   = CreateConVar("kz_max_prespeed_bhop_dropbhop", "350.0", "Max counted pre speed for bhop,dropbhop (no speed limiter)", FCVAR_NOTIFY, true, 300.0, true, 400.0);
			g_hdist_good_countjump    	= CreateConVar("kz_dist_min_cj", "230.0", "Minimum distance for count jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_countjump   	= CreateConVar("kz_dist_perfect_cj", "270.0", "Minimum distance for count jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_impressive_countjump   	= CreateConVar("kz_dist_impressive_cj", "275.0", "Minimum distance for count jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_godlike_countjump    	= CreateConVar("kz_dist_god_cj", "280.0", "Minimum distance for count jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
			g_hdist_good_lj    	= CreateConVar("kz_dist_min_lj", "240.0", "Minimum distance for long jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_lj   	= CreateConVar("kz_dist_perfect_lj", "260.0", "Minimum distance for long jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_impressive_lj   	= CreateConVar("kz_dist_impressive_lj", "265.0", "Minimum distance for long jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
			g_hdist_godlike_lj    	= CreateConVar("kz_dist_god_lj", "270.0", "Minimum distance for long jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
			g_hdist_good_weird  = CreateConVar("kz_dist_min_wj", "250.0", "Minimum distance for weird jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_weird  = CreateConVar("kz_dist_perfect_wj", "270.0", "Minimum distance for weird jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_impressive_weird  = CreateConVar("kz_dist_impressive_wj", "275.0", "Minimum distance for weird jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_godlike_weird   = CreateConVar("kz_dist_god_wj", "280.0", "Minimum distance for weird jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_dropbhop  = CreateConVar("kz_dist_min_dropbhop", "240.0", "Minimum distance for drop bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_dropbhop  = CreateConVar("kz_dist_perfect_dropbhop", "300.0", "Minimum distance for drop bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_impressive_dropbhop  = CreateConVar("kz_dist_impressive_dropbhop", "305.0", "Minimum distance for drop bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_godlike_dropbhop   = CreateConVar("kz_dist_god_dropbhop", "310.0", "Minimum distance for drop bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_bhop  = CreateConVar("kz_dist_min_bhop", "240.0", "Minimum distance for bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_perfect_bhop  = CreateConVar("kz_dist_perfect_bhop", "305.0", "Minimum distance for bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_impressive_bhop  = CreateConVar("kz_dist_impressive_bhop", "310.0", "Minimum distance for bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_godlike_bhop   = CreateConVar("kz_dist_god_bhop", "315.0", "Minimum distance for bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
			g_hdist_good_multibhop  = CreateConVar("kz_dist_min_multibhop", "300.0", "Minimum distance for multi-bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_perfect_multibhop  = CreateConVar("kz_dist_perfect_multibhop", "330.0", "Minimum distance for multi-bhops to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_impressive_multibhop  = CreateConVar("kz_dist_impressive_multibhop", "335.0", "Minimum distance for multi-bhops to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_godlike_multibhop   = CreateConVar("kz_dist_god_multibhop", "340.0", "Minimum distance for multi-bhops to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
			g_hdist_good_ladder  = CreateConVar("kz_dist_min_ladder", "100.0", "Minimum distance for ladder jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 70.0, true, 9999.0);
			g_hdist_perfect_ladder  = CreateConVar("kz_dist_perfect_ladder", "150.0", "Minimum distance for ladder jumps to be considered perfect [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
			g_hdist_impressive_ladder  = CreateConVar("kz_dist_impressive_ladder", "155.0", "Minimum distance for ladder jumps to be considered impressive [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
			g_hdist_godlike_ladder   = CreateConVar("kz_dist_god_ladder", "165.0", "Minimum distance for ladder jumps to be considered godlike [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
			// Golden jumpstats
			g_hdist_golden_countjump = 290.0;
			g_hdist_golden_lj = 280.0;
			g_hdist_golden_weird = 290.0;
			g_hdist_golden_dropbhop = 325.0;
			g_hdist_golden_bhop = 325.0;
			g_hdist_golden_multibhop = 350.0;
			g_hdist_golden_ladder = 180.0;	
		}
	}

	g_fBanDuration    = GetConVarFloat(g_hBanDuration);
	HookConVarChange(g_hBanDuration, OnSettingChanged);

	g_fMaxBhopPreSpeed    = GetConVarFloat(g_hMaxBhopPreSpeed);
	HookConVarChange(g_hMaxBhopPreSpeed, OnSettingChanged);

	g_dist_min_countjump	= GetConVarFloat(g_hdist_good_countjump);
	HookConVarChange(g_hdist_good_countjump, OnSettingChanged);

	g_dist_impressive_countjump    = GetConVarFloat(g_hdist_impressive_countjump);
	HookConVarChange(g_hdist_impressive_countjump, OnSettingChanged);

	g_dist_perfect_countjump	= GetConVarFloat(g_hdist_perfect_countjump);
	HookConVarChange(g_hdist_perfect_countjump, OnSettingChanged);

	g_dist_god_countjump    = GetConVarFloat(g_hdist_godlike_countjump);
	HookConVarChange(g_hdist_godlike_countjump, OnSettingChanged);

	g_dist_min_weird	= GetConVarFloat(g_hdist_good_weird);
	HookConVarChange(g_hdist_good_weird, OnSettingChanged);

	g_dist_impressive_weird    = GetConVarFloat(g_hdist_impressive_weird);
	HookConVarChange(g_hdist_impressive_weird, OnSettingChanged);

	g_dist_perfect_weird	= GetConVarFloat(g_hdist_perfect_weird);
	HookConVarChange(g_hdist_perfect_weird, OnSettingChanged);

	g_dist_god_weird    = GetConVarFloat(g_hdist_godlike_weird);
	HookConVarChange(g_hdist_godlike_weird, OnSettingChanged);

	g_dist_min_dropbhop	= GetConVarFloat(g_hdist_good_dropbhop);
	HookConVarChange(g_hdist_good_dropbhop, OnSettingChanged);

	g_dist_impressive_dropbhop    = GetConVarFloat(g_hdist_impressive_dropbhop);
	HookConVarChange(g_hdist_impressive_dropbhop, OnSettingChanged);

	g_dist_perfect_dropbhop	= GetConVarFloat(g_hdist_perfect_dropbhop);
	HookConVarChange(g_hdist_perfect_dropbhop, OnSettingChanged);

	g_dist_god_dropbhop    = GetConVarFloat(g_hdist_godlike_dropbhop);
	HookConVarChange(g_hdist_godlike_dropbhop, OnSettingChanged);

	g_dist_min_bhop	= GetConVarFloat(g_hdist_good_bhop);
	HookConVarChange(g_hdist_good_bhop, OnSettingChanged);

	g_dist_impressive_bhop    = GetConVarFloat(g_hdist_impressive_bhop);
	HookConVarChange(g_hdist_impressive_bhop, OnSettingChanged);

	g_dist_perfect_bhop	= GetConVarFloat(g_hdist_perfect_bhop);
	HookConVarChange(g_hdist_perfect_bhop, OnSettingChanged);

	g_dist_god_bhop    = GetConVarFloat(g_hdist_godlike_bhop);
	HookConVarChange(g_hdist_godlike_bhop, OnSettingChanged);

	g_dist_min_multibhop	= GetConVarFloat(g_hdist_good_multibhop);
	HookConVarChange(g_hdist_good_multibhop, OnSettingChanged);

	g_dist_impressive_multibhop    = GetConVarFloat(g_hdist_impressive_multibhop);
	HookConVarChange(g_hdist_impressive_multibhop, OnSettingChanged);

	g_dist_perfect_multibhop	= GetConVarFloat(g_hdist_perfect_multibhop);
	HookConVarChange(g_hdist_perfect_multibhop, OnSettingChanged);

	g_dist_god_multibhop    = GetConVarFloat(g_hdist_godlike_multibhop);
	HookConVarChange(g_hdist_godlike_multibhop, OnSettingChanged);

	g_dist_min_lj      = GetConVarFloat(g_hdist_good_lj);
	HookConVarChange(g_hdist_good_lj, OnSettingChanged);

	g_dist_impressive_lj    = GetConVarFloat(g_hdist_impressive_lj);
	HookConVarChange(g_hdist_impressive_lj, OnSettingChanged);

	g_dist_perfect_lj      = GetConVarFloat(g_hdist_perfect_lj);
	HookConVarChange(g_hdist_perfect_lj, OnSettingChanged);

	g_dist_god_lj      = GetConVarFloat(g_hdist_godlike_lj);
	HookConVarChange(g_hdist_godlike_lj, OnSettingChanged);

	g_dist_min_ladder      = GetConVarFloat(g_hdist_good_ladder);
	HookConVarChange(g_hdist_good_ladder, OnSettingChanged);

	g_dist_impressive_ladder    = GetConVarFloat(g_hdist_impressive_ladder);
	HookConVarChange(g_hdist_impressive_ladder, OnSettingChanged);

	g_dist_perfect_ladder      = GetConVarFloat(g_hdist_perfect_ladder);
	HookConVarChange(g_hdist_perfect_ladder, OnSettingChanged);

	g_dist_god_ladder      = GetConVarFloat(g_hdist_godlike_ladder);
	HookConVarChange(g_hdist_godlike_ladder, OnSettingChanged);
}

public RegConsoleCmds()
{
	RegConsoleCmd("kill", BlockKill);
	RegConsoleCmd("sm_usp", Client_Usp, "[KZTimer] spawns a usp silencer");
	RegConsoleCmd("sm_beam", Client_PlayerJumpBeam, "[KZTimer] onf/off - showing the trajectory of the jump");
	RegConsoleCmd("sm_avg", Client_Avg, "[KZTimer] prints in chat the average time of the current map");
	RegConsoleCmd("sm_join", Client_Join, "[KZTimer] Opens the kztimer steam group");
	RegConsoleCmd("sm_accept", Client_Accept, "[KZTimer] allows you to accept a challenge request");
	RegConsoleCmd("sm_goto", Client_GoTo, "[KZTimer] teleports you to a selected player");
	RegConsoleCmd("sm_showkeys", Client_InfoPanel, "[KZTimer] on/off speed/showkeys center panel");
	RegConsoleCmd("sm_sync", Client_StrafeSync,"[KZTimer] on/off strafe sync in chat");
	RegConsoleCmd("sm_surrender", Client_Surrender, "[KZTimer] surrender your current challenge");
	RegConsoleCmd("sm_next", Client_Next,"[KZTimer] goto next checkpoint");
	RegConsoleCmd("sm_bhop", Client_AutoBhop,"[KZTimer] on/off autobhop (only mg_,surf_ and bhop_ maps supported)");
	RegConsoleCmd("sm_undo", Client_Undo,"[KZTimer] undoes your last telepoint");
	RegConsoleCmd("sm_help2", Client_RankingSystem,"[KZTimer] Explanation of the KZTimer ranking system");
	RegConsoleCmd("sm_flashlight", Client_Flashlight,"[KZTimer] on/off flashlight");
	RegConsoleCmd("sm_prev", Client_Prev,"[KZTimer] goto previous checkpoint");
	RegConsoleCmd("sm_ljblock", Client_Ljblock,"[KZTimer] registers a lj block");
	RegConsoleCmd("sm_adv", Client_AdvClimbersMenu, "[KZTimer] advanced climbers menu (additional: !next, !prev and !undo)");
	RegConsoleCmd("sm_unstuck", Client_Prev,"[KZTimer] go to previous checkpoint");
	RegConsoleCmd("sm_maptop", Client_MapTop,"[KZTimer] displays local map top for a given map");
	RegConsoleCmd("sm_stuck", Client_Prev,"[KZTimer] go to previous checkpoint");
	RegConsoleCmd("sm_checkpoint", Client_Save,"[KZTimer] save your current position");
	RegConsoleCmd("sm_gocheck", Client_Tele,"[KZTimer] go to latest checkpoint");
	RegConsoleCmd("sm_compare", Client_Compare, "[KZTimer] compare your challenge results");
	RegConsoleCmd("sm_menu", Client_Kzmenu, "[KZTimer] opens checkpoint menu");
	RegConsoleCmd("sm_cpmenu", Client_Kzmenu, "[KZTimer] opens checkpoint menu");
	RegConsoleCmd("sm_wr", Client_Wr, "[KZTimer] prints records in chat");
	RegConsoleCmd("sm_tier", Client_MapTier, "[KZTimer] prints map tier in chat");
	RegConsoleCmd("sm_tierhelp", Client_TierHelp, "[KZTimer] displays information about map tiers");
	RegConsoleCmd("sm_measure",Command_Menu, "[KZTimer] allows you to measure the distance between 2 points");
	RegConsoleCmd("sm_abort", Client_Abort, "[KZTimer] abort your current challenge");
	RegConsoleCmd("sm_spec", Client_Spec, "[KZTimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_specs", Command_Specs, "[KZTimer] prints in chat a list of all spectators");
	RegConsoleCmd("sm_watch", Client_Spec, "[KZTimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_spectate", Client_Spec, "[KZTimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_challenge", Client_Challenge, "[KZTimer] allows you to start a race against others");
	RegConsoleCmd("sm_helpmenu", Client_Help, "[KZTimer] help menu which displays all kztimer commands");
	RegConsoleCmd("sm_help", Client_Help, "[KZTimer] help menu which displays all kztimer commands");
	RegConsoleCmd("sm_profile", Client_Profile, "[KZTimer] opens a player profile");
	RegConsoleCmd("sm_rank", Client_Profile, "[KZTimer] opens a player profile");
	RegConsoleCmd("sm_route", Client_Route, "[KZTimer] shows the route of the fastest replay bot with glowing dots");
	RegConsoleCmd("sm_hidechat", Client_HideChat, "[KZTimer] hides your ingame chat and voice icons");
	RegConsoleCmd("sm_hideweapon", Client_HideWeapon, "[KZTimer] hides your weapon model");
	RegConsoleCmd("sm_options", Client_OptionMenu, "[KZTimer] opens options menu");
	RegConsoleCmd("sm_top", Client_Top, "[KZTimer] displays top rankings (Top 100 Players, Top 50 overall, Top 20 Pro, Top 20 with Teleports, Top 20 LJ, Top 20 Bhop, Top 20 Multi-Bhop, Top 20 WeirdJump, Top 20 Drop Bunnyhop)");
	RegConsoleCmd("sm_topclimbers", Client_Top, "[KZTimer] displays top rankings (Top 100 Players, Top 50 overall, Top 20 Pro, Top 20 with Teleports, Top 20 LJ, Top 20 Bhop, Top 20 Multi-Bhop, Top 20 WeirdJump, Top 20 Drop Bunnyhop)");
	RegConsoleCmd("sm_start", Client_Start, "[KZTimer] go back to start");
	RegConsoleCmd("sm_stopsound", Client_Stopsound, "[KZTimer] Stops map music");
	RegConsoleCmd("sm_r", Client_Start, "[KZTimer] go back to start");
	RegConsoleCmd("sm_mapinfo", Client_MapTier, "[KZTimer] prints in chat information about the current map");
	RegConsoleCmd("sm_stop", Client_Stop, "[KZTimer] stops your timer");
	RegConsoleCmd("sm_ranks", Client_Ranks, "[KZTimer] prints in chat the available player ranks");
	RegConsoleCmd("sm_speed", Client_InfoPanel, "[KZTimer] on/off speed/showkeys center panel");
	RegConsoleCmd("sm_pause", Client_Pause,"[KZTimer] on/off pause (timer on hold and movement frozen)");
	RegConsoleCmd("sm_showsettings", Client_Showsettings,"[KZTimer] shows kztimer server settings");
	RegConsoleCmd("sm_latest", Client_Latest,"[KZTimer] shows latest map records");
	RegConsoleCmd("sm_hide", Client_Hide, "[KZTimer] on/off - hides other players");
	RegConsoleCmd("sm_globaltop", Client_GlobalTop, "[KZTimer] Global Top");
	RegConsoleCmd("sm_globalcheck", Client_GlobalCheck, "[KZTimer] checks global record requirements");
	RegConsoleCmd("sm_bhopcheck", Command_Stats, "[KZTimer] checks bhop stats for a given player");
	RegConsoleCmd("sm_ipcheck", Global_IPCheck, "[KZTimer] grabs IPs of every client on server");
	RegConsoleCmd("+noclip", NoClip, "[KZTimer] Player noclip on");
	RegConsoleCmd("-noclip", UnNoClip, "[KZTimer] Player noclip off");
	RegConsoleCmd("sm_pb", Client_PersonalBest, "[KZTimer] Prints your best times for the current map");
	RegConsoleCmd("sm_toggle_goto", Client_ToggleGoto, "[KZTimer] Toggle Goto'ing to you");
	RegConsoleCmd("sm_toggle_errorsounds", Client_ToggleErrorSounds, "[KZTimer] Toggle error sounds");
	RegConsoleCmd("sm_toggle_timertext", Client_ToggleTimerText, "[KZTimer] Toggle timer text");
	RegConsoleCmd("sm_toggle_speclist", Client_ToggleSpeclist, "[KZTimer] Toggle specs list");
	RegConsoleCmd("sm_toggle_startweapon", Client_ToggleStartWeapon, "[KZTimer] Toggle starting weapon between usp and knife");
	RegConsoleCmd("sm_toggle_menusounds", Client_ToggleMenuSounds, "[KZTimer] Toggle menu sounds (Selecting items on the menu)");
	RegConsoleCmd("sm_toggle_quakesounds", Client_ToggleQuakeSounds, "[KZTimer] Toggle between quake sounds");
	RegConsoleCmd("sm_toggle_checkpointmsg", Client_ToggleCPDoneMessage, "[KZTimer] Toggle checkpoint done message");
	RegConsoleCmd("sm_toggle_jumpstatcolors", Client_ToggleJumpstatsColorChat, "[KZTimer] Toggle between jumpstats color chat");
	RegConsoleCmd("sm_ssp", Client_SetStartPosition, "[KZTimer] Set Start Position");
	RegConsoleCmd("sm_csp", Client_ClearStartPosition, "[KZTimer] Clear Start Position");
	RegAdminCmd("sm_kzadmin", Admin_KzPanel, ADMIN_LEVEL, "[KZTimer] Displays the kztimer menu panel (requires flag e)");
	RegAdminCmd("sm_refreshprofile", Admin_RefreshProfile, ADMIN_LEVEL, "[KZTimer] Recalculates player profile for given steam id");
	RegAdminCmd("sm_resetchallenges", Admin_DropChallenges, ADMIN_LEVEL2, "[KZTimer] Resets all player challenges (drops table challenges) - requires z flag");
	RegAdminCmd("sm_resettimes", Admin_DropAllMapRecords, ADMIN_LEVEL2, "[KZTimer] Resets all player times (drops table playertimes) - requires z flag");
	RegAdminCmd("sm_resetranks", Admin_DropPlayerRanks, ADMIN_LEVEL2, "[KZTimer] Resets the all player points  (drops table playerrank - requires z flag)");
	RegAdminCmd("sm_resetmaptimes", Admin_ResetMapRecords, ADMIN_LEVEL2, "[KZTimer] Resets player times for given map - requires z flag");
	RegAdminCmd("sm_resetplayerchallenges", Admin_ResetChallenges, ADMIN_LEVEL2, "[KZTimer] Resets (won) challenges for given steamid - requires z flag");
	RegAdminCmd("sm_resetplayertimes", Admin_ResetRecords, ADMIN_LEVEL2, "[KZTimer] Resets tp & pro map times (+extrapoints) for given steamid with or without given map - requires z flag");
	RegAdminCmd("sm_resetplayertptime", Admin_ResetRecordTp, ADMIN_LEVEL2, "[KZTimer] Resets tp map time for given steamid and map - requires z flag");
	RegAdminCmd("sm_resetplayerprotime", Admin_ResetRecordPro, ADMIN_LEVEL2, "[KZTimer] Resets pro map time for given steamid and map - requires z flag");
	RegAdminCmd("sm_resetjumpstats", Admin_DropPlayerJump, ADMIN_LEVEL2, "[KZTimer] Resets jump stats (drops table playerjumpstats) - requires z flag");
	RegAdminCmd("sm_resetallljrecords", Admin_ResetAllLjRecords, ADMIN_LEVEL2, "[KZTimer] Resets all lj records - requires z flag");
	RegAdminCmd("sm_resetallladderjumprecords", Admin_ResetAllLadderJumpRecords, ADMIN_LEVEL2, "[KZTimer] Resets all ladder jump records - requires z flag");
	RegAdminCmd("sm_resetallljblockrecords", Admin_ResetAllLjBlockRecords, ADMIN_LEVEL2, "[KZTimer] Resets all lj block records - requires z flag");
	RegAdminCmd("sm_resetallwjrecords", Admin_ResetAllWjRecords, ADMIN_LEVEL2, "[KZTimer] Resets all wj records - requires z flag");
	RegAdminCmd("sm_resetallcjrecords", Admin_ResetAllCjRecords, ADMIN_LEVEL2, "[KZTimer] Resets all cj records - requires z flag");
	RegAdminCmd("sm_resetallbhoprecords", Admin_ResetAllBhopRecords, ADMIN_LEVEL2, "[KZTimer] Resets all bhop records - requires z flag");
	RegAdminCmd("sm_resetalldropbhopecords", Admin_ResetAllDropBhopRecords, ADMIN_LEVEL2, "[KZTimer] Resets all drop bjop records - requires z flag");
	RegAdminCmd("sm_resetallmultibhoprecords", Admin_ResetAllMultiBhopRecords, ADMIN_LEVEL2, "[KZTimer] Resets all multi bhop records - requires z flag");
	RegAdminCmd("sm_resetljrecord", Admin_ResetLjRecords, ADMIN_LEVEL2, "[KZTimer] Resets lj record for given steamid - requires z flag");
	RegAdminCmd("sm_resetcjrecord", Admin_ResetCjRecords, ADMIN_LEVEL2, "[KZTimer] Resets cj record for given steamid - requires z flag");
	RegAdminCmd("sm_resetladderjumprecord", Admin_ResetLadderJumpRecords, ADMIN_LEVEL2, "[KZTimer] Resets ladderjump record for given steamid - requires z flag");
	RegAdminCmd("sm_resetljblockrecord", Admin_ResetLjBlockRecords, ADMIN_LEVEL2, "[KZTimer] Resets lj block record for given steamid - requires z flag");
	RegAdminCmd("sm_resetbhoprecord", Admin_ResetBhopRecords, ADMIN_LEVEL2, "[KZTimer] Resets bhop record for given steamid - requires z flag");
	RegAdminCmd("sm_resetdropbhoprecord", Admin_ResetDropBhopRecords, ADMIN_LEVEL2, "[KZTimer] Resets drop bhop record for given steamid - requires z flag");
	RegAdminCmd("sm_resetwjrecord", Admin_ResetWjRecords, ADMIN_LEVEL2, "[KZTimer] Resets wj record for given steamid - requires z flag");
	RegAdminCmd("sm_resetmultibhoprecord", Admin_ResetMultiBhopRecords, ADMIN_LEVEL2, "[KZTimer] Resets multi bhop record for given steamid - requires z flag");
	RegAdminCmd("sm_resetplayerjumpstats", Admin_ResetPlayerJumpstats, ADMIN_LEVEL2, "[KZTimer] Resets jump stats for given steamid - requires z flag");
	RegAdminCmd("sm_deleteproreplay", Admin_DeleteProReplay, ADMIN_LEVEL2, "[KZTimer] Deletes pro replay for a given map - requires z flag");
	RegAdminCmd("sm_deletetpreplay", Admin_DeleteTpReplay, ADMIN_LEVEL2, "[KZTimer] Deletes tp replay for a given map - requires z flag");
	RegAdminCmd("sm_resetextrapoints", Admin_ResetExtraPoints, ADMIN_LEVEL2, "[KZTimer] Resets given extra points for all players with or without given steamid");
	RegConsoleCmd("sm_globaltop2", Client_APIGlobalTop);
	RegConsoleCmd("sm_jumpstatstop", Client_JumpstatsTop);
	RegConsoleCmd("sm_jst", Client_JumpstatsTop);
}

public SetupHooksAndCommandListener()
{
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("round_start",Event_OnRoundStart,EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_Pre);
	HookEvent("player_hurt", Event_OnPlayerHurt);
	HookEvent("player_jump", Event_OnJump, EventHookMode_Pre);
	HookEvent("weapon_fire",  Event_OnFire, EventHookMode_Pre);
	HookEvent("player_jump", Event_OnJumpMacroDox, EventHookMode_Post);
	HookEvent("player_team", Event_OnPlayerTeamRestriction, EventHookMode_Pre);
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Post);
	HookEvent("jointeam_failed", Event_JoinTeamFailed, EventHookMode_Pre);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("round_freeze_end", OnNewRound, EventHookMode_Pre);
	HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);
	HookEntityOutput("trigger_teleport", "OnStartTouch", Teleport_OnStartTouch);
	HookEntityOutput("trigger_multiple", "OnStartTouch", Teleport_OnStartTouch);
	HookEntityOutput("trigger_teleport", "OnEndTouch", Teleport_OnEndTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouch", Teleport_OnEndTouch);
	HookEntityOutput("trigger_gravity", "OnStartTouch", Trigger_GravityTouch);
	HookEntityOutput("trigger_gravity", "OnEndTouch", Trigger_GravityTouch);
	HookEntityOutput("func_button", "OnPressed", ButtonPress);

	///////////////////////
	//Command listener
	AddCommandListener(Say_Hook, "say");
	AddCommandListener(Say_Hook, "say_team");
	AddCommandListener(Command_JoinTeam, "jointeam");
	AddCommandListener(Command_Spectate, "spectate");
	AddCommandListener(Command_ext_Menu, "radio1");
	AddCommandListener(Command_ext_Menu, "radio2");
	AddCommandListener(Command_ext_Menu, "radio3");
	AddCommandListener(Command_ext_Menu, "sm_nominate");
	AddCommandListener(Command_ext_Menu, "sm_admin");
	AddCommandListener(Command_ext_Menu, "sm_votekick");
	AddCommandListener(Command_ext_Menu, "sm_voteban");
	AddCommandListener(Command_ext_Menu, "sm_votemenu");
	AddCommandListener(Command_ext_Menu, "sm_revote");
	AddCommandListener(Command_ext_Menu, "sm_globaltop2");
	AddCommandListener(Command_ext_Menu, "sm_jumpstatstop");
	AddCommandListener(Command_ext_Menu, "sm_jst");
	for(new g; g < sizeof(RadioCMDS); g++)
		AddCommandListener(BlockRadio, RadioCMDS[g]);
	AddNormalSoundHook(NormalSHook:NormalSHook_callback);

	/////////////////////////
	//Dhooks OnTeleport
	new Handle:hGameData = LoadGameConfigFile("sdktools.games");
	if(hGameData == INVALID_HANDLE)
	{
		SetFailState("GameConfigFile sdkhooks.games was not found.")
		return
	}
	new iOffset = GameConfGetOffset(hGameData, "Teleport");
	CloseHandle(hGameData);
	if(iOffset == -1)
		return;

	if(LibraryExists("dhooks"))
	{
		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		if(g_hTeleport == INVALID_HANDLE)
			return;
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_ObjectPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_Bool);
	}

	AddTempEntHook("EffectDispatch", TE_OnEffectDispatch);
}

public Action TE_OnEffectDispatch(const char[] te_name, const Players[], int numClients, float delay)
{
	new iEffectIndex = TE_ReadNum("m_iEffectName");
	char sEffectName[64];
	GetEffectName(iEffectIndex, sEffectName, sizeof(sEffectName));
	if(StrEqual(sEffectName, "Impact"))
		return Plugin_Handled;
	return Plugin_Continue;
}

stock int GetEffectName(int index, char[] sEffectName, int maxlen)
{
	new table = INVALID_STRING_TABLE;

	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");

	return ReadStringTable(table, index, sEffectName, maxlen);
}

stock ResetHandle(&Handle: handle)
{
    if (handle != INVALID_HANDLE)
    {
        CloseHandle(handle);
        handle = INVALID_HANDLE;
    }
}

public AddMapmakers()
{
	decl String:sPath[PLATFORM_MAX_PATH];
	decl String:line[64];
	for (new x = 0; x < 100; x++)
		Format(g_szMapmakers[x],sizeof(g_szMapmakers), "");
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", MAPPERS_PATH);
	new count = 0;
	new Handle:fileHandle = OpenFile(sPath,"r");
	while(!IsEndOfFile(fileHandle)&&ReadFileLine(fileHandle,line,sizeof(line)))
	{
		TrimString(line);
		if ((StrContains(line,"//",true) == -1) && count < 100)
		{
			Format(g_szMapmakers[count],sizeof(g_szMapmakers), "%s", line);
			count++;
		}
	}
	if (fileHandle != INVALID_HANDLE)
		ResetHandle(fileHandle);
}

public AddHiddenChatCommands()
{
	decl String:sPath[PLATFORM_MAX_PATH];
	decl String:line[64];
	for (new x = 0; x < 256; x++)
		Format(g_BlockedChatText[x],sizeof(g_BlockedChatText), "");
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", BLOCKED_LIST_PATH);
	new count = 0;
	new Handle:fileHandle = OpenFile(sPath,"r");
	while(!IsEndOfFile(fileHandle)&&ReadFileLine(fileHandle,line,sizeof(line)))
	{
		TrimString(line);
		if ((StrContains(line,"//",true) == -1) && count < 256)
		{
			Format(g_BlockedChatText[count],sizeof(g_BlockedChatText), "%s", line);
			count++;
		}
	}
	if (fileHandle != INVALID_HANDLE)
		ResetHandle(fileHandle);
}

public SetupExceptions(bool:addcommands)
{
	decl String:sPath[PLATFORM_MAX_PATH];
	decl String:line[256];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", EXCEPTION_LIST_PATH);
	new Handle:fileHandle=OpenFile(sPath,"r");
	while(!IsEndOfFile(fileHandle)&&ReadFileLine(fileHandle,line,sizeof(line)))
	{
		if ((StrContains(line,"//",true) == -1))
		{
			TrimString(line);
			if (!StrEqual(line,""))
			{
				if (addcommands)
					AddCommandListener(Command_ext_Menu, line);
				else
					RemoveCommandListener(Command_ext_Menu, line);
			}
		}
	}
	if (fileHandle != INVALID_HANDLE)
		CloseHandle(fileHandle);
}


public Float:GetClientDistanceToGround(Float:fOrigin[3])
{
	new Float:fGround[3];
	TR_TraceRayFilter(fOrigin, Float:{90.0,0.0,0.0}, MASK_PLAYERSOLID, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit())
	{
		TR_GetEndPosition(fGround);
		return GetVectorDistance(fOrigin, fGround);
	}
	return 0.0;
}

public ProcessParticleManifest(const String:path[])
{
	new Handle:hFile = OpenFile(path, "r", true, NULL_STRING);

	new Handle:hKeyValue = CreateKeyValues("particles_manifest");
	FileToKeyValues(hKeyValue, path);

	if (!KvJumpToKey(hKeyValue, "file", false))
	{
		CloseHandle(hKeyValue);
		CloseHandle(hFile);
		return;
	}
	decl String:buffer[256];
	do
	{
		KvGetString(hKeyValue, NULL_STRING, buffer, sizeof(buffer), NULL_STRING);
		PrecacheGeneric(buffer, true);
	}
	while (KvGotoNextKey(hKeyValue, false));

	CloseHandle(hKeyValue);
	CloseHandle(hFile);
}
