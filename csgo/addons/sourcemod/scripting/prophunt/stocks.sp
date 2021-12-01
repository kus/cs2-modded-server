/* Macros */

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && !IsFakeClient(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define LoopArray(%1,%2) for(int %1=0;%1<GetArraySize(%2);++%1)

stock bool ClientIsValid(int iClient)
{
	return (0 < iClient <= MaxClients && IsClientInGame(iClient));
}

#define SPECMODE_NONE           0
#define SPECMODE_FIRSTPERSON    4
#define SPECMODE_THIRDPERSON    5
#define SPECMODE_FREELOOK       6

#define COLLISION_GROUP_DEBRIS_TRIGGER 2
#define COLLISION_GROUP_PLAYER 5
#define COLLISION_GROUP_PUSHAWAY 17

stock void Client_Blind(int iClient, bool blind = false)
{
	Handle hFadeClient = StartMessageOne("Fade", iClient);
	PbSetInt(hFadeClient, "duration", 1);
	PbSetInt(hFadeClient, "hold_time", 3);
	
	if (blind)
		PbSetInt(hFadeClient, "flags", FFADE_STAYOUT);
	else PbSetInt(hFadeClient, "flags", FFADE_PURGE);
	
	int color[] = {0, 0, 0, 255}; //TODO change color based on countdown
	PbSetColor(hFadeClient, "clr", color);
	EndMessage();
}

stock void Client_BlockControls(int iClient, bool block = false)
{
	static int iFreeze = -1;
	
	if(iFreeze == -1)
		iFreeze = FindSendPropInfo("CBasePlayer", "m_fFlags");
	
	if(block)
	SetEntData(iClient, iFreeze, FL_CLIENT | FL_ATCONTROLS, 4, true);
	else SetEntData(iClient, iFreeze, FL_FAKECLIENT | FL_ONGROUND | FL_PARTIALGROUND, 4, true);
}

stock void Client_StripWeapons(int iClient)
{
    int iWeapon = -1;
    for (int i = CS_SLOT_PRIMARY; i <= CS_SLOT_C4; i++)
    {
        while ((iWeapon = GetPlayerWeaponSlot(iClient, i)) != -1)
        {
        	SDKHooks_DropWeapon(iClient, iWeapon, _, _);
        	AcceptEntityInput(iWeapon, "Kill");
        }
    }
}

stock bool IsPlayerAFK(int iClient)
{
	float fOrigin[3];
	GetClientAbsOrigin(iClient, fOrigin);
	
	// Did he move after spawn?
	return UTIL_VectorEqual(fOrigin, g_fSpawnPosition[iClient], 0.1);
}

#define HIDE_HUD_HIDER (1<<12)

stock void RemoveClientRadar(int iClient)
{
	int hud = GetEntProp(iClient, Prop_Send, "m_iHideHUD");
	SetEntProp(iClient, Prop_Send, "m_iHideHUD", hud | HIDE_HUD_HIDER);
}

stock void SlayClient(int iClient)
{
	if (IsPlayerAlive(iClient))
		ForcePlayerSuicide(iClient);
}

stock void CheckClientHasKnife(int iClient)
{
	if (IsPlayerAlive(iClient))
	{
		int iWeapon = GetPlayerWeaponSlot(iClient, 2);
		if (iWeapon == -1)
			iWeapon = GivePlayerItem(iClient, "weapon_knife");
	}
}

stock bool UTIL_VectorEqual(const float vec1[3], const float vec2[3], const float tolerance)
{
	for (int i = 0; i < 3; i++)
		if (vec1[i] > (vec2[i] + tolerance) || vec1[i] < (vec2[i] - tolerance))
			return false;
	return true;
}

void Entity_GetAbsOriginAlt(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec);
}

stock void Entity_GetAbsAnglesAlt(int entity, float vec[3]) 
{
	GetEntPropVector(entity, Prop_Send, "m_angAbsRotation", vec);
}

stock void Entity_GetVelocity(int entity, float vec[3]) 
{
	GetEntPropVector(entity, Prop_Send, "m_vecAbsVelocity", vec);
}

stock void Entity_SetMovementSpeed(int entity, float speed) 
{
	SetEntPropFloat(entity, Prop_Send, "m_flLaggedMovementValue", speed);
}

stock void SetThirdPersonView(int iClient, bool third)
{
	static Handle m_hAllowTP = INVALID_HANDLE;
	if(m_hAllowTP == INVALID_HANDLE)
		m_hAllowTP = FindConVar("sv_allow_thirdperson");

	SetConVarInt(m_hAllowTP, 1);

	if(third)
		ClientCommand(iClient, "thirdperson");
	else ClientCommand(iClient, "firstperson");
}

#define WEAPONTYPE_UNKNOWN -1

#define WEAPONTYPE_KNIFE 0
#define WEAPONTYPE_PISTOL 1
#define WEAPONTYPE_SUBMACHINEGUN 2
#define WEAPONTYPE_RIFLE 3
#define WEAPONTYPE_SHOTGUN 4
#define WEAPONTYPE_SNIPER_RIFLE 5
#define WEAPONTYPE_MACHINEGUN 6
#define WEAPONTYPE_C4 7
#define WEAPONTYPE_TASER 8 
#define WEAPONTYPE_GRENADE 9 
#define WEAPONTYPE_HEALTHSHOT 11

#define ROUNDEND_CT_WIN  8
#define ROUNDEND_T_WIN   9

// removes hostages and bomb zones
stock void RemoveGameplayEdicts()
{
	int maxent = GetMaxEntities();
	char eName[64];
	for (int i = MaxClients; i < maxent; i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEdictClassname(i, eName, sizeof(eName));
			
			if (StrContains(eName, "hostage_entity") != -1 
				|| StrContains(eName, "func_bomb_target") != -1 
				|| (StrContains(eName, "func_buyzone") != -1 && GetEntProp(i, Prop_Data, "m_iTeamNum", 4) == CS_TEAM_T))
				RemoveEdict(i);
		}
	}
}

stock void SlayTeam(int iTeam)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam)
			ForcePlayerSuicide(i);
	}
}

stock void ForceRoundEnd(int iTeam, bool bUpdateScore)
{
	int iEntity = -1;
	iEntity = FindEntityByClassname(iEntity, "game_round_end");
	
	if (iEntity < 1)
	{
		iEntity = CreateEntityByName("game_round_end");
		if (IsValidEntity(iEntity))
			DispatchSpawn(iEntity);
		else return;
	}
	
	SetVariantFloat(5.0);
	
	if (iTeam == CS_TEAM_T)
		AcceptEntityInput(iEntity, "EndRound_TerroristsWin");
	else AcceptEntityInput(iEntity, "EndRound_CounterTerroristsWin");
	
	if(iTeam <= CS_TEAM_SPECTATOR || !bUpdateScore)
		return;
	
	int iNewScore = CS_GetTeamScore(iTeam) + 1;
	CS_SetTeamScore(iTeam, iNewScore);
}

stock void CleanupWeapons()
{
	static int g_oWeaponParent;
	
	if(g_oWeaponParent <= 0)
		g_oWeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	
	int maxent = GetMaxEntities();
	char sWeapon[64];
	
	for (int i = GetMaxClients(); i < maxent; i++)
	{
		if (!IsValidEdict(i) || !IsValidEntity(i))
			continue;
		
		GetEdictClassname(i, sWeapon, sizeof(sWeapon));
		if (!((StrContains(sWeapon, "weapon_") != -1 || StrContains(sWeapon, "item_") != -1 )))
			continue;
			
		if (GetEntDataEnt2(i, g_oWeaponParent) != -1)
			continue;
		
		RemoveEdict(i);
	}
}

stock void RemoveFootstepShadows()
{
	int iEntity = -1;
	
	while ((iEntity = FindEntityByClassname(iEntity, "env_cascade_light")) != -1)
		AcceptEntityInput(iEntity, "Kill");
}

#define MAX_SECTION_LENGTH  128

stock void ReadySound(char[] relPath)
{
	char fullPath[128];
	Format(fullPath, sizeof(fullPath), "sound/%s", relPath);
	
	char buffer[128];
	Format(buffer, sizeof(buffer), "*/%s", relPath);
	AddFileToDownloadsTable(fullPath);
	AddToStringTable(FindStringTable("soundprecache"), buffer);
}

stock void PlaySoundWithSpeaker(int iClient, char[] soundPath, float fPos[3], int sndCh = SNDCHAN_AUTO, int sndLvl = SNDLEVEL_NORMAL, int sndFlags = SND_NOFLAGS, float sndVol = SNDVOL_NORMAL, int sndPitch = SNDPITCH_NORMAL)
{
	Handle soundfile = OpenSoundFile(soundPath);
	
	if (soundfile == null)
		return;
	
	float fLength = GetSoundLengthFloat(soundfile)+1.0;
	
	delete soundfile; 
	
	int iEntity = SpawnSpeakerEntity(fPos, fLength);
	
	if(iClient != 0)
	{
		char sTargetName[64]; 
		Format(sTargetName, sizeof(sTargetName), "ragdoll%d", iClient);
		DispatchKeyValue(iClient, "targetname", sTargetName);
		
		SetVariantString(sTargetName);
		AcceptEntityInput(iEntity, "SetParent", iEntity, iEntity, 0);
	}

	EmitSoundToAllAny(soundPath, iEntity, sndCh, sndLvl, sndFlags, sndVol, sndPitch, iEntity, fPos, NULL_VECTOR, false);
}

stock int SpawnSpeakerEntity(float fPos[3], float ttl)
{
	int iEntity = CreateEntityByName("prop_physics_override");
	
	if(!IsModelPrecached("models/error.mdl"))
		PrecacheModel("models/error.mdl");
	SetEntityModel(iEntity, "models/error.mdl");
	SetEntityRenderMode(iEntity, RENDER_NONE);
	if(iEntity != -1)
	{
		TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);
		RemoveEntityEx(iEntity, ttl);
	}
	
	return iEntity;
}

stock void RemoveEntityEx(int iEntity, float time = 0.0)
{
	if (time == 0.0)
	{
		if (IsValidEntity(iEntity))
		{
			char edictname[32];
			GetEdictClassname(iEntity, edictname, 32);

			if (!StrEqual(edictname, "player"))
				AcceptEntityInput(iEntity, "kill");
		}
	}
	else if(time > 0.0)
		CreateTimer(time, RemoveEntityTimer, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE);
}

public Action RemoveEntityTimer(Handle Timer, any entityRef)
{
	int entity = EntRefToEntIndex(entityRef);
	if (entity != INVALID_ENT_REFERENCE)
		RemoveEntity(entity); // RemoveEntity(...) is capable of handling references
	
	return Plugin_Stop;
}

stock int GetFirstPageItem(int itemNum, int pagination = 6)
{
	int item = itemNum;
	int firstItem;
	
	while(item >= pagination)
	{
		firstItem += pagination;
		item -= pagination;
	}
	
	return firstItem;
}

stock bool KV_JumpTo(Handle kv, int index)
{
	if (!KvGotoFirstSubKey(g_kvModels, false))
		return false;
	
	for (int i = 0; i < index; i++)
	{
		if (!KvGotoNextKey(g_kvModels, false))
			return false;
	}
	
	return true;
}

enum FX
{
	FxNone = 0,
	FxPulseFast,
	FxPulseSlowWide,
	FxPulseFastWide,
	FxFadeSlow,
	FxFadeFast,
	FxSolidSlow,
	FxSolidFast,
	FxStrobeSlow,
	FxStrobeFast,
	FxStrobeFaster,
	FxFlickerSlow,
	FxFlickerFast,
	FxNoDissipation,
	FxDistort,               // Distort/scale/translate flicker
	FxHologram,              // kRenderFxDistort + distance fade
	FxExplode,               // Scale up really big!
	FxGlowShell,             // Glowing Shell
	FxClampMinScale,         // Keep this sprite from getting very small (SPRITES only!)
	FxEnvRain,               // for environmental rendermode, make rain
	FxEnvSnow,               //  "        "            "    , make snow
	FxSpotlight,     
	FxRagdoll,
	FxPulseFastWider,
};

enum Render
{
	Normal = 0,     // src
	TransColor,     // c*a+dest*(1-a)
	TransTexture,    // src*a+dest*(1-a)
	Glow,        // src*a+dest -- No Z buffer checks -- Fixed size in screen space
	TransAlpha,      // src*srca+dest*(1-srca)
	TransAdd,      // src*a+dest
	Environmental,    // not drawn, used for environmental effects
	TransAddFrameBlend,  // use a fractional frame value to blend between animation frames
	TransAlphaAdd,    // src + dest*(1-a)
	WorldGlow,      // Same as kRenderGlow but not fixed size in screen space
	None,        // Don't render.
};

stock void FX_Render(int iClient, FX fx = FxNone, int r = 255, int g = 255, int b = 255, Render render = Normal, int alpha = 255)
{
	static int iOffRender = -1;
	
	if(iOffRender == -1)
		iOffRender = FindSendPropInfo("CBasePlayer", "m_clrRender");
	
	SetEntProp(iClient, Prop_Send, "m_nRenderFX", fx, 1);
	SetEntProp(iClient, Prop_Send, "m_nRenderMode", render, 1);  
	SetEntData(iClient, iOffRender, r, 1, true);
	SetEntData(iClient, iOffRender + 1, g, 1, true);
	SetEntData(iClient, iOffRender + 2, b, 1, true);
	SetEntData(iClient, iOffRender + 3, alpha, 1, true);  
}

stock void BlockWeapon(int iClient, int iWeapon, bool attack, bool attack2, float time = 1.0)
{
	float unlockTime = GetGameTime() + time;
	
	if(attack)
		SetEntPropFloat(iClient, Prop_Send, "m_flNextAttack", unlockTime);
	
	if(attack2 && iWeapon > 0 && HasEntProp(iWeapon, Prop_Send, "m_flNextSecondaryAttack"))
		SetEntPropFloat(iWeapon, Prop_Send, "m_flNextSecondaryAttack", unlockTime);
}

stock bool IsPlayerStuck(int iClient)
{
	float vOrigin[3], vMins[3], vMaxs[3];
	GetClientAbsOrigin(iClient, vOrigin);
	GetEntPropVector(iClient, Prop_Send, "m_vecMins", vMins);
	GetEntPropVector(iClient, Prop_Send, "m_vecMaxs", vMaxs);
	
	int iTeam = GetClientTeam(iClient);
	
	if(iTeam == CS_TEAM_CT)
		TR_TraceHullFilter(vOrigin, vOrigin, vMins, vMaxs, MASK_ALL, FilterOnlyPlayersT, iClient);
	else TR_TraceHullFilter(vOrigin, vOrigin, vMins, vMaxs, MASK_ALL, FilterOnlyPlayersCT, iClient);
	
	return TR_DidHit();
}

public bool FilterOnlyPlayersT(int iEntity, int contentsMask, any data)
{
	return ((iEntity != data && iEntity > 0 && iEntity <= MaxClients) && GetClientTeam(iEntity) == CS_TEAM_T);
}

public bool FilterOnlyPlayersCT(int iEntity, int contentsMask, any data)
{
	return ((iEntity != data && iEntity > 0 && iEntity <= MaxClients) && GetClientTeam(iEntity) == CS_TEAM_CT);
}

float AngleDown[3] = { 90.0, 0.0, 0.0 };
//float AngleUp[3] = { -90.0, 0.0, 0.0 };

#define	MASK_AIRDROP (CONTENTS_SOLID|MASK_OPAQUE|CONTENTS_IGNORE_NODRAW_OPAQUE|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_PLAYERCLIP|CONTENTS_GRATE)

stock float GetHeightAboveGround(int iClient)
{
	float fPos[3]; 
	
	GetClientAbsOrigin(iClient, fPos);

	Handle trace = TR_TraceRayFilterEx(fPos, AngleDown, MASK_AIRDROP, RayType_Infinite, TraceRay_DontAnything);
	
	if (TR_DidHit(trace)) 
	{
		float posEnd[3];
		TR_GetEndPosition(posEnd, trace);
		delete trace;
		return GetVectorDistance(fPos, posEnd);
	}
	delete trace;
	return 99999.0;
}

stock float GetHeightAboveWater(int iClient)
{
	float fPos[3]; 
	
	GetClientAbsOrigin(iClient, fPos);

	Handle trace = TR_TraceRayFilterEx(fPos, AngleDown, MASK_WATER, RayType_Infinite, TraceRay_DontAnything);
	
	if (TR_DidHit(trace)) 
	{
		float posEnd[3];
		TR_GetEndPosition(posEnd, trace);
		delete trace;
		return GetVectorDistance(fPos, posEnd);
	}
	delete trace;
	return 99999.0;
}

public bool TraceRay_DontAnything(int entity, int mask, any data)
{
	return false;
}

stock void SetCookieInt(int client, Handle hCookie, int value)
{
	char sBuffer[255];
	IntToString(value, sBuffer, sizeof(sBuffer));
	SetClientCookie(client, hCookie, sBuffer);
}

stock bool PrepareSound(char[] sound)
{
	char fileSound[PLATFORM_MAX_PATH];
	FormatEx(fileSound, PLATFORM_MAX_PATH, "sound/%s", sound);
	
	if (FileExists(fileSound, false))
	{
		PrecacheSoundAny(sound, true);
		AddFileToDownloadsTable(fileSound);
		return true;
	}
	else if(FileExists(fileSound, true))
	{
		PrecacheSound(sound, true);
		return true;
	}
	
	LogMessage("File Not Found: %s", fileSound);
	return false;
}

stock float GetSoundLengthEx(char[] path)
{
	Handle hFile = OpenSoundFile(path);
	float fLength = GetSoundLengthFloat(hFile);
	delete hFile;
	
	return fLength;
}

stock void Weapon_AddReserveAmmo(int iWeapon, int iAddAmmo)
{
	int iAmmo = GetEntProp(iWeapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
	iAmmo += iAddAmmo;
	SetEntProp(iWeapon, Prop_Send, "m_iPrimaryReserveAmmoCount", iAmmo);
}

stock int GetParticleEffectName(int index, char[] sEffectName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("ParticleEffectNames");
	
	return ReadStringTable(table, index, sEffectName, maxlen);
}

stock int GetEffectName(int index, char[] sEffectName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");
	
	return ReadStringTable(table, index, sEffectName, maxlen);
}

stock int GetDecalName(int index, char[] sDecalName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("decalprecache");
	
	return ReadStringTable(table, index, sDecalName, maxlen);
}

stock int GetRandomClient(int iTeam, bool onlyAlive = false)
{
	int iClient;
	int[] clients = new int[MaxClients];
	
	LoopIngameClients(i)
	{
		if(IsClientSourceTV(i))
			continue;
		
		if(onlyAlive && !IsPlayerAlive(i))
			continue;
		
		if(iTeam == CS_TEAM_NONE && GetClientTeam(i) <= CS_TEAM_SPECTATOR)
			continue;
		
		if (iTeam != CS_TEAM_NONE && GetClientTeam(i) != iTeam)
			continue;
		
		clients[iClient] = i;
		iClient++;
	}
	
	return iClient == 0 ? 0 : clients[GetRandomInt(0, iClient-1)];
}

stock void MoveRelative(float vecOrigin[3], float vecAngle[3], float offset, float output[3])
{
	float vecAngVectors[3];
	vecAngVectors = vecAngle;
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	
	for (int i; i < 3; i++)
		output[i] = vecOrigin[i] + (vecAngVectors[i] * offset);
}

stock bool CheckLineBox(float B1[3], float B2[3], float L1[3], float L2[3], float Hit[3])
{
	if (L2[0] < B1[0] && L1[0] < B1[0])
		return false;
	if (L2[0] > B2[0] && L1[0] > B2[0]) 
		return false;
	if (L2[1] < B1[1] && L1[1] < B1[1])
		return false;
	if (L2[1] > B2[1] && L1[1] > B2[1])
		return false;
	if (L2[2] < B1[2] && L1[2] < B1[2]) 
		return false;
	if (L2[2] > B2[2] && L1[2] > B2[2]) 
		return false;
	
	if (L1[0] > B1[0] && L1[0] < B2[0] && L1[1] > B1[1] && L1[1] < B2[1] && L1[2] > B1[2] && L1[2] < B2[2])
	{
	    	Hit = L1; 
		return true;
	}
	
	if ((	GetIntersection(L1[0] - B1[0], L2[0] - B1[0], L1, L2, Hit) && InBox(Hit, B1, B2, 1))
	  || (	GetIntersection(L1[1] - B1[1], L2[1] - B1[1], L1, L2, Hit) && InBox(Hit, B1, B2, 2))
	  || (	GetIntersection(L1[2] - B1[2], L2[2] - B1[2], L1, L2, Hit) && InBox(Hit, B1, B2, 3))
	  || (	GetIntersection(L1[0] - B2[0], L2[0] - B2[0], L1, L2, Hit) && InBox(Hit, B1, B2, 1))
	  || (	GetIntersection(L1[1] - B2[1], L2[1] - B2[1], L1, L2, Hit) && InBox(Hit, B1, B2, 2))
	  || (	GetIntersection(L1[2] - B2[2], L2[2] - B2[2], L1, L2, Hit) && InBox(Hit, B1, B2, 3)))
		return true;
	
	return false;
}

stock bool GetIntersection( float fDst1, float fDst2, float P1[3], float P2[3], float Hit[3]) 
{
	if ( (fDst1 * fDst2) >= 0.0)
		return false;
	
	if ( fDst1 == fDst2)
		return false; 
	
	Hit[0] = P1[0] + (P2[0] - P1[0]) * (-fDst1 / (fDst2 - fDst1));
	Hit[1] = P1[1] + (P2[1] - P1[1]) * (-fDst1 / (fDst2 - fDst1));
	Hit[2] = P1[2] + (P2[2] - P1[2]) * (-fDst1 / (fDst2 - fDst1));
	
	return true;
}

stock bool InBox( float Hit[3], float B1[3], float B2[3], int Axis) 
{
	if ( Axis==1 && Hit[2] > B1[2] && Hit[2] < B2[2] && Hit[1] > B1[1] && Hit[1] < B2[1])
		return true;
	
	if ( Axis==2 && Hit[2] > B1[2] && Hit[2] < B2[2] && Hit[0] > B1[0] && Hit[0] < B2[0])
		return true;
	
	if ( Axis==3 && Hit[0] > B1[0] && Hit[0] < B2[0] && Hit[1] > B1[1] && Hit[1] < B2[1])
		return true;
	
	return false;
}

stock float GetFloatMax(float a, float b)
{
	return a > b ?  a : b;
}

float[3] RotatePoint(const float p[3], float angles[3])
{
	float sin[3], cos[3], out[3];
	
	sin[0] = Sine(DegToRad(angles[0]));
	sin[1] = Sine(DegToRad(angles[1]));
	sin[2] = Sine(DegToRad(angles[2]));
	cos[0] = Cosine(DegToRad(angles[0]));
	cos[1] = Cosine(DegToRad(angles[1]));
	cos[2] = Cosine(DegToRad(angles[2]));
	
	out[0] = cos[1] * cos[0] * p[0] + (cos[1] * sin[0] * sin[2] - sin[1] * cos[2]) * p[1] + (sin[1] * sin[2] + cos[1] * sin[0] * cos[2]) * p[2];
	out[1] = sin[1] * cos[0] * p[0] + (cos[1] * cos[2] + sin[1] * sin[0] * sin[2]) * p[1] + (sin[1] * sin[0] * cos[2] - cos[1] * sin[2]) * p[2];
	out[2] = cos[0] * sin[2] * p[1] + cos[0] * cos[2] * p[2] - sin[0] * p[0];
	
	return out;
}

stock void ShowGameText(int iClient, int iChannel, int color[4], float x, float y, float time, char[] sText)
{
	SetHudTextParamsEx(x, y, time, color, _, 0, 0.0, 0.0, 0.0);
	ShowHudText(iClient,iChannel, sText);
}