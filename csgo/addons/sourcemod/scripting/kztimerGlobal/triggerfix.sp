

// Credits:
// RNGFix made by rio https://github.com/jason-e/rngfix


// Engine constants, NOT settings (do not change)
#define LAND_HEIGHT 2.0 					// Maximum height above ground at which you can "land"
#define MIN_STANDABLE_ZNRM 0.7				// Minimum surface normal Z component of a walkable surface

static int processMovementTicks[MAXPLAYERS+1];
static float playerFrameTime[MAXPLAYERS+1];

static bool touchingTrigger[MAXPLAYERS+1][2048];

static int lastGroundEnt[MAXPLAYERS + 1];
static bool duckedLastTick[MAXPLAYERS + 1];
static bool mapTeleportedSequentialTicks[MAXPLAYERS+1];
static bool jumpBugged[MAXPLAYERS + 1];
static float jumpBugOrigin[MAXPLAYERS + 1][3];

static ConVar cvGravity;

static Handle processMovementHookPre;
static Address serverGameEnts;
static Handle markEntitiesAsTouching;

void OnPluginStart_Triggerfix()
{
	HookEvent("player_jump", Event_PlayerJump);
	
	cvGravity = FindConVar("sv_gravity");
	if (cvGravity == null)
	{
		SetFailState("Could not find sv_gravity");
	}
	
	Handle gamedataConf = LoadGameConfigFile("kztimer-triggerfix.games");
	if (gamedataConf == null)
	{
		SetFailState("Failed to load kztimer-triggerfix gamedata");
	}
	
	// CreateInterface
	// Thanks SlidyBat and ici
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(gamedataConf, SDKConf_Signature, "CreateInterface"))
	{
		SetFailState("Failed to get CreateInterface");
	}
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	Handle hCreateInterface = EndPrepSDKCall();
	
	if (hCreateInterface == null)
	{
		SetFailState("Unable to prepare SDKCall for CreateInterface");
	}
	
	char interfaceName[64];
	
	// ProcessMovement
	if (!GameConfGetKeyValue(gamedataConf, "IGameMovement", interfaceName, sizeof(interfaceName)))
	{
		SetFailState("Failed to get IGameMovement interface name");
	}
	Address IGameMovement = SDKCall(hCreateInterface, interfaceName, 0);
	if (!IGameMovement)
	{
		SetFailState("Failed to get IGameMovement pointer");
	}
	
	int offset = GameConfGetOffset(gamedataConf, "ProcessMovement");
	if (offset == -1)
	{
		SetFailState("Failed to get ProcessMovement offset");
	}
	
	processMovementHookPre = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Ignore, DHook_ProcessMovementPre);
	DHookAddParam(processMovementHookPre, HookParamType_CBaseEntity);
	DHookAddParam(processMovementHookPre, HookParamType_ObjectPtr);
	DHookRaw(processMovementHookPre, false, IGameMovement);
	
	// MarkEntitiesAsTouching
	if (!GameConfGetKeyValue(gamedataConf, "IServerGameEnts", interfaceName, sizeof(interfaceName)))
	{
		SetFailState("Failed to get IServerGameEnts interface name");
	}
	serverGameEnts = SDKCall(hCreateInterface, interfaceName, 0);
	if (!serverGameEnts)
	{
		SetFailState("Failed to get IServerGameEnts pointer");
	}
	
	StartPrepSDKCall(SDKCall_Raw);
	if (!PrepSDKCall_SetFromConf(gamedataConf, SDKConf_Virtual, "IServerGameEnts::MarkEntitiesAsTouching"))
	{
		SetFailState("Failed to get IServerGameEnts::MarkEntitiesAsTouching offset");
	}
	PrepSDKCall_AddParameter(SDKType_Edict, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Edict, SDKPass_Pointer);
	markEntitiesAsTouching = EndPrepSDKCall();
	
	if (markEntitiesAsTouching == null)
	{
		SetFailState("Unable to prepare SDKCall for IServerGameEnts::MarkEntitiesAsTouching");
	}
	
	delete hCreateInterface;
	delete gamedataConf;
	
	if (g_bLateLoaded)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) OnClientPutInServer(client);
		}
		
		char classname[64];
		for (int entity = MaxClients+1; entity < sizeof(touchingTrigger[]); entity++)
		{
			if (!IsValidEntity(entity)) continue;
			GetEntPropString(entity, Prop_Data, "m_iClassname", classname, sizeof(classname));
			HookTrigger(entity, classname);
		}
	}
}

void OnEntityCreated_Triggerfix(int entity, const char[] classname)
{
	if (entity >= sizeof(touchingTrigger[]))
	{
		return;
	}
	HookTrigger(entity, classname);
}

void OnClientConnected_Triggerfix(int client)
{
	processMovementTicks[client] = 0;
	for (int i = 0; i < sizeof(touchingTrigger[]); i++)
	{
		touchingTrigger[client][i] = false;
	}
}

void OnClientPutInServer_Triggerfix(int client)
{
	SDKHook(client, SDKHook_PostThink, Hook_PlayerPostThink);
}

static void Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	jumpBugged[client] = !!lastGroundEnt[client];
	if (jumpBugged[client])
	{
		GetClientAbsOrigin(client, jumpBugOrigin[client]);
		// if player's origin is still in the ducking position then adjust for that.
		if (duckedLastTick[client] && !GetDucking(client))
		{
			jumpBugOrigin[client][2] -= 9.0;
		}
	}
}

static Action Hook_TriggerStartTouch(int entity, int other)
{
	if (1 <= other <= MaxClients)
	{
		touchingTrigger[other][entity] = true;
	}
	
	return Plugin_Continue;
}

static Action Hook_TriggerEndTouch(int entity, int other)
{
	if (1 <= other <= MaxClients)
	{
	 	touchingTrigger[other][entity] = false;
	}
	return Plugin_Continue;
}

static MRESReturn DHook_ProcessMovementPre(Handle hParams)
{
	int client = DHookGetParam(hParams, 1);
	
	processMovementTicks[client]++;
	playerFrameTime[client] = GetTickInterval() * GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
	mapTeleportedSequentialTicks[client] = false;
	
	if (IsPlayerAlive(client))
	{
		if (GetEntityMoveType(client) == MOVETYPE_WALK
			&& !CheckWater(client))
		{
			lastGroundEnt[client] = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity");
		}
		duckedLastTick[client] = GetDucking(client);
	}
	
	return MRES_Ignored;
}

static bool GetDucking(int client)
{
	return GetEntProp(client, Prop_Send, "m_bDucked") || GetEntProp(client, Prop_Send, "m_bDucking");
}

static bool DoTriggerjumpFix(int client, const float landingPoint[3], const float landingMins[3], const float landingMaxs[3])
{
	// It's possible to land above a trigger but also in another trigger_teleport, have the teleport move you to
	// another location, and then the trigger jumping fix wouldn't fire the other trigger you technically landed above,
	// but I can't imagine a mapper would ever actually stack triggers like that.
	
	float origin[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", origin);
	
	float landingMaxsBelow[3];
	landingMaxsBelow[0] = landingMaxs[0];
	landingMaxsBelow[1] = landingMaxs[1];
	landingMaxsBelow[2] = origin[2] - landingPoint[2];
	
	ArrayList triggers = new ArrayList();
	
	// Find triggers that are between us and the ground (using the bounding box quadrant we landed with if applicable).
	TR_EnumerateEntitiesHull(landingPoint, landingPoint, landingMins, landingMaxsBelow, true, AddTrigger, triggers);
	
	bool didSomething = false;
	
	for (int i = 0; i < triggers.Length; i++)
	{
		int trigger = triggers.Get(i);
		
		// MarkEntitiesAsTouching always fires the Touch function even if it was already fired this tick.
		// In case that could cause side-effects, manually keep track of triggers we are actually touching
		// and don't re-touch them.
		if (touchingTrigger[client][trigger])
		{
			continue;
		}
		
		SDKCall(markEntitiesAsTouching, serverGameEnts, client, trigger);
		didSomething = true;
	}
	
	delete triggers;
	
	return didSomething;
}

// PostThink works a little better than a ProcessMovement post hook because we need to wait for ProcessImpacts (trigger activation)
static void Hook_PlayerPostThink(int client)
{
	if (!IsPlayerAlive(client)
		|| GetEntityMoveType(client) != MOVETYPE_WALK
		|| CheckWater(client))
	{
		return;
	}
	
	bool landed = (GetEntPropEnt(client, Prop_Data, "m_hGroundEntity") != -1
		&& lastGroundEnt[client] == -1)
		|| jumpBugged[client];
	
	float landingMins[3], landingMaxs[3], landingPoint[3];
	
	// Get info about the ground we landed on (if we need to do landing fixes).
	if (landed)
	{
		float origin[3], nrm[3], velocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", origin);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
		
		if (jumpBugged[client])
		{
			origin = jumpBugOrigin[client];
		}
		
		GetEntPropVector(client, Prop_Data, "m_vecMins", landingMins);
		GetEntPropVector(client, Prop_Data, "m_vecMaxs", landingMaxs);
		
		float originBelow[3];
		originBelow[0] = origin[0];
		originBelow[1] = origin[1];
		originBelow[2] = origin[2] - LAND_HEIGHT;
		
		TR_TraceHullFilter(origin, originBelow, landingMins, landingMaxs, MASK_PLAYERSOLID, PlayerFilter);
		
		if (!TR_DidHit())
		{
			// This should never happen, since we know we are on the ground.
			landed = false;
		}
		else
		{
			TR_GetPlaneNormal(null, nrm);
			
			if (nrm[2] < MIN_STANDABLE_ZNRM)
			{
				// This is rare, and how the incline fix should behave isn't entirely clear because maybe we should
				// collide with multiple faces at once in this case, but let's just get the ground we officially
				// landed on and use that for our ground normal.
				
				// landingMins and landingMaxs will contain the final values used to find the ground after returning.
				if (TracePlayerBBoxForGround(origin, originBelow, landingMins, landingMaxs))
				{
					TR_GetPlaneNormal(null, nrm);
				}
				else
				{
					// This should also never happen.
					landed = false;
				}
			}
			
			TR_GetEndPosition(landingPoint);
		}
	}
	
	// reset it here because we don't need it again
	jumpBugged[client] = false;
	
	if (landed && TR_GetFraction() > 0.0)
	{
		DoTriggerjumpFix(client, landingPoint, landingMins, landingMaxs);
		// Check if a trigger we just touched put us in the air (probably due to a teleport).
		if (GetEntityFlags(client) & FL_ONGROUND == 0)
		{
			landed = false;
		}
	}
}

static bool PlayerFilter(int entity, int mask)
{
	return !(1 <= entity <= MaxClients);
}

static void HookTrigger(int entity, const char[] classname)
{
	if (StrContains(classname, "trigger_") != -1)
	{
		SDKHook(entity, SDKHook_StartTouchPost, Hook_TriggerStartTouch);
		SDKHook(entity, SDKHook_EndTouchPost, Hook_TriggerEndTouch);
	}
}

static bool CheckWater(int client)
{
	// The cached water level is updated multiple times per tick, including after movement happens,
	// so we can just check the cached value here.
	return GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1;
}

static bool AddTrigger(int entity, ArrayList triggers)
{
	TR_ClipCurrentRayToEntity(MASK_ALL, entity);
	if (TR_DidHit())
	{
		triggers.Push(entity);
	}
	
	return true;
}

static bool TracePlayerBBoxForGround(const float origin[3], const float originBelow[3], float mins[3], float maxs[3])
{
	// See CGameMovement::TracePlayerBBoxForGround()
	
	float origMins[3], origMaxs[3];
	origMins = mins;
	origMaxs = maxs;
	
	float nrm[3];
	
	mins = origMins;
	
	// -x -y
	maxs[0] = origMaxs[0] > 0.0 ? 0.0 : origMaxs[0];
	maxs[1] = origMaxs[1] > 0.0 ? 0.0 : origMaxs[1];
	maxs[2] = origMaxs[2];
	
	TR_TraceHullFilter(origin, originBelow, mins, maxs, MASK_PLAYERSOLID, PlayerFilter);
	
	if (TR_DidHit())
	{
		TR_GetPlaneNormal(null, nrm);
		if (nrm[2] >= MIN_STANDABLE_ZNRM)
		{
			return true;
		}
	}
	
	// +x +y
	mins[0] = origMins[0] < 0.0 ? 0.0 : origMins[0];
	mins[1] = origMins[1] < 0.0 ? 0.0 : origMins[1];
	mins[2] = origMins[2];
	
	maxs = origMaxs;
	
	TR_TraceHullFilter(origin, originBelow, mins, maxs, MASK_PLAYERSOLID, PlayerFilter);

	if (TR_DidHit())
	{
		TR_GetPlaneNormal(null, nrm);
		if (nrm[2] >= MIN_STANDABLE_ZNRM)
		{
			return true;
		}
	}
	
	// -x +y
	mins[0] = origMins[0];
	mins[1] = origMins[1] < 0.0 ? 0.0 : origMins[1];
	mins[2] = origMins[2];
	
	maxs[0] = origMaxs[0] > 0.0 ? 0.0 : origMaxs[0];
	maxs[1] = origMaxs[1];
	maxs[2] = origMaxs[2];
	
	TR_TraceHullFilter(origin, originBelow, mins, maxs, MASK_PLAYERSOLID, PlayerFilter);
	
	if (TR_DidHit())
	{
		TR_GetPlaneNormal(null, nrm);
		if (nrm[2] >= MIN_STANDABLE_ZNRM)
		{
			return true;
		}
	}
	
	// +x -y
	mins[0] = origMins[0] < 0.0 ? 0.0 : origMins[0];
	mins[1] = origMins[1];
	mins[2] = origMins[2];
	
	maxs[0] = origMaxs[0];
	maxs[1] = origMaxs[1] > 0.0 ? 0.0 : origMaxs[1];
	maxs[2] = origMaxs[2];
	
	TR_TraceHullFilter(origin, originBelow, mins, maxs, MASK_PLAYERSOLID, PlayerFilter);
	
	if (TR_DidHit())
	{
		TR_GetPlaneNormal(null, nrm);
		if (nrm[2] >= MIN_STANDABLE_ZNRM)
		{
			return true;
		}
	}

	return false;
}
