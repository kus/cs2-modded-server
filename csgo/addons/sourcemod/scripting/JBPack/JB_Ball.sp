public Plugin myinfo = 
{
	name = "JB_Ball",
	author = "mottzi, edit by Eyal282",
	description = "Ball for CS:GO",
	version = "1.0",
	url = "https://forums.alliedmods.net/showthread.php?p=2423345 ( Do not use this URL )"
}

#include <sourcemod>
#include <sdkhooks>
#include <emitsoundany>
#undef REQUIRE_PLUGIN
#include <fuckZones>

#pragma semicolon 1
#pragma newdecls required

// *** 
// only modify if you know what you're doing
#define BALL_ENTITY_NAME "simpleball"
#define BALL_CFG_FILE "configs/ballspawns.cfg"
#define BALL_PLAYER_DISTANCE 35.0
#define BALL_KICK_DISTANCE 35.0
#define BALL_KICK_POWER 600.0
#define BALL_HOLD_HEIGHT 15
#define BALL_KICK_HEIGHT_ADDITION 25
#define BALL_RADIUS 16.0
#define BALL_AUTO_RESPAWN 35.0
#define BALL_ADMIN_MENU_FLAG ADMFLAG_BAN
// thanks.
// *** 

#define FSOLID_NOT_SOLID 0x0004
#define FSOLID_TRIGGER 0x0008


enum Collision_Group_t {
	COLLISION_GROUP_NONE = 0,
	COLLISION_GROUP_DEBRIS,                // Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER,        // Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEBRIS,    // Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,           // Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,    // For HL2, same as Collision_Group_Player, for
	                                    // TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,                // Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,         // for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,             // for any weapons that need collision detection
	COLLISION_GROUP_VEHICLE_CLIP,       // vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,         // Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,       // Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,      // Doors that the player shouldn't collide with
	COLLISION_GROUP_DISSOLVING,         // Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,           // Nonsolid on client and server, pushaway in player code

	COLLISION_GROUP_NPC_ACTOR,       // Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED,    // USed for NPCs in scripts that should not collide with each other

	LAST_SHARED_COLLISION_GROUP
};

int g_BallRef = INVALID_ENT_REFERENCE;
int g_BallHolder;
float g_fNextTouch[MAXPLAYERS+1];

float g_BallSpawnOrigin[3];
bool g_BallSpawnExists;

Handle g_TimerRespawn = INVALID_HANDLE;

void InitializeVariables()
{
	g_BallHolder = 0;
	g_BallSpawnExists = false;
	g_TimerRespawn = INVALID_HANDLE;
}

public void OnPluginEnd()
{
	DestroyBall();
}

public void OnPluginStart()
{
	RegAdminCmd("sm_ball", CommandBallMenu, BALL_ADMIN_MENU_FLAG);
	
	AddNormalSoundHook(Event_SoundPlayed);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_use", Event_PlayerUse, EventHookMode_Post);
}

public Action CommandBallMenu(int client, int args)
{
	if(client == 0)
		return Plugin_Handled;
	
	BallMenu(client);
	
	return Plugin_Handled;
}

void BallMenu(int client)
{
	Menu menu = new Menu(BallMenuHandler);
	
	menu.SetTitle("Ball Menu");
	
	menu.AddItem("", "Remove Ball");
	menu.AddItem("", "Add Ball");
	menu.AddItem("", "Reset Ball");
		
	menu.Display(client, MENU_TIME_FOREVER);
}

public int BallMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				// remove ball
				case 0:
				{
					if(g_BallSpawnExists)
					{
						DestroyBall();
						InitializeVariables();
						
						char szPathConfig[PLATFORM_MAX_PATH];
						BuildPath(Path_SM, szPathConfig, sizeof szPathConfig, BALL_CFG_FILE);
						
						Handle ConfigTree = CreateKeyValues("Spawns");
						FileToKeyValues(ConfigTree, szPathConfig);

						if(!ConfigTree)
						{
							PrintToChat(param1, "[SM] Loading from %s failed.", szPathConfig);
							CloseHandle(ConfigTree);
							return 0;
						}
					
						char szMap[50];
						GetCurrentMap(szMap, sizeof szMap);
						
						if(KvJumpToKey(ConfigTree, szMap))
						{
							KvDeleteThis(ConfigTree);
						}
						
						KvRewind(ConfigTree);
						KeyValuesToFile(ConfigTree, szPathConfig);
						
						CloseHandle(ConfigTree);
						
						PrintToChat(param1, "[SM] Ball removed.");
					}
				}
				// add ball
				case 1:
				{
					DestroyBall();
					InitializeVariables();
					
					char szPathConfig[PLATFORM_MAX_PATH];
					BuildPath(Path_SM, szPathConfig, sizeof(szPathConfig), BALL_CFG_FILE);
					
					Handle ConfigTree = CreateKeyValues("Spawns");
					FileToKeyValues(ConfigTree, szPathConfig);

					if(!ConfigTree)
					{
						PrintToChat(param1, "[SM] Loading from %s failed.", szPathConfig);
						CloseHandle(ConfigTree);
						return 0;
					}
					
					char szMap[50];
					GetCurrentMap(szMap, sizeof szMap);
					
					if(KvJumpToKey(ConfigTree, szMap, true))
					{
						float fOrigin[3];
						GetPlayerEyeViewPoint(param1, fOrigin);
						fOrigin[2] += 20.0;
	
						KvSetFloat(ConfigTree, "x", fOrigin[0]);
						KvSetFloat(ConfigTree, "y", fOrigin[1]);
						KvSetFloat(ConfigTree, "z", fOrigin[2]);
						
						g_BallSpawnOrigin = fOrigin;
						g_BallSpawnExists = true;
				
						RespawnBall();
					}
					
					KvRewind(ConfigTree);
					KeyValuesToFile(ConfigTree, szPathConfig);
					
					CloseHandle(ConfigTree);
					
					PrintToChat(param1, "[SM] Ball added.");
				}
				case 2:
				{
					if(g_BallSpawnExists)
					{
						RespawnBall();
						
						PrintToChat(param1, "[SM] Ball was reset.");
					}
				}
			}
			
			BallMenu(param1);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

char g_BallModel[256] = "models/props/de_dust/hr_dust/dust_soccerball/dust_soccer_ball001.mdl";

public void OnMapStart()
{
	for(int i=0;i < sizeof(g_fNextTouch);i++)
	{
		g_fNextTouch[i] = 0.0;
	}

	InitializeVariables();
	
	PrecacheModel("models/error.mdl", true);

	PrecacheSound("knastjunkies/bounce.mp3", true);
	AddFileToDownloadsTable("sound/knastjunkies/bounce.mp3");
	PrecacheSound("knastjunkies/gotball.mp3", true);
	AddFileToDownloadsTable("sound/knastjunkies/gotball.mp3");
	

	if(FileExists("models/knastjunkies/soccerball.mdl"))
	{
		g_BallModel = "models/knastjunkies/soccerball.mdl";
		PrecacheModel(g_BallModel, true);
		AddFileToDownloadsTable("models/knastjunkies/soccerball.mdl");
		AddFileToDownloadsTable("models/knastjunkies/SoccerBall.dx90.vtx");
		AddFileToDownloadsTable("models/knastjunkies/SoccerBall.phy");
		AddFileToDownloadsTable("models/knastjunkies/soccerball.vvd");
	}
	else
	{
		PrecacheModel(g_BallModel, true);
	}
	AddFileToDownloadsTable("materials/knastjunkies/Material__0.vmt");
	AddFileToDownloadsTable("materials/knastjunkies/Material__1.vmt");
	
	LoadBall();
}

public void OnGameFrame()
{
	if(GetFeatureStatus(FeatureType_Native, "fuckZones_GetZoneList") != FeatureStatus_Available)
		return;

	int ball = EntRefToEntIndex(g_BallRef);

	if(ball == INVALID_ENT_REFERENCE)
		return;

	else if(g_BallHolder > 0)
		 return;

	float fOrigin[3];
	GetEntPropVector(ball, Prop_Data, "m_vecAbsOrigin", fOrigin);

	ArrayList zones = fuckZones_GetZoneList();

	for(int i=0;i < zones.Length;i++)
	{ 
		char zoneName[64];
		int zone = EntRefToEntIndex(zones.Get(i));

		if(!fuckZones_GetZoneName(zone, zoneName, sizeof(zoneName)))
			continue;

		else if(StrContains(zoneName, "Net", false) == -1)
			continue;

		else if(!fuckZones_IsPointInZone(zone, fOrigin))
			continue;

		DestroyBall();

		if(g_TimerRespawn != INVALID_HANDLE)
		{
			CloseHandle(g_TimerRespawn);
			g_TimerRespawn = INVALID_HANDLE;
		}

		g_TimerRespawn = CreateTimer(2.0, TimerRespawnBall, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	delete zones;
}

public Action Event_SoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	int ball = EntRefToEntIndex(g_BallRef);


	if(ball == entity && StrEqual(sample, "~)weapons/hegrenade/he_bounce-1.wav"))
	{
		float fOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", fOrigin);

		sample = "knastjunkies/bounce.mp3";
		
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	if (IsClientInGame(client))
	{
		if (client == g_BallHolder)
		{
			RemoveBallHolder();
			
			StartRespawnTimer();
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{	
	if(client == g_BallHolder)
	{
		if(buttons & IN_USE && !(GetEntProp(client, Prop_Send, "m_nOldButtons") & IN_USE))
		{
			KickBall(client, BALL_KICK_POWER);
		}
		else
		{
			SetBallInFront(client);
		}
	}

	return Plugin_Continue;
}

public Action Event_PlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client == g_BallHolder)
	{
		RemoveBallHolder();
		
		StartRespawnTimer();
	}

	return Plugin_Continue;
}

public Action Event_PlayerUse(Handle event, char[] name, bool dontBroadcast)
{
	int entity = GetEventInt(event, "entity");

	int ball = EntRefToEntIndex(g_BallRef);

	if(ball == INVALID_ENT_REFERENCE)
		return Plugin_Continue;

	if(g_BallHolder > 0 && (entity == g_BallHolder || entity == ball))
	{
		KickBall(g_BallHolder, 500.0);
	}

	return Plugin_Continue;
}

public Action Event_RoundStart(Handle event, char[] name, bool dontBroadcast) 
{
	if(g_BallSpawnExists)
	{
		RespawnBall();
	}
	
	StopRespawnTimer();

	return Plugin_Continue;
}

void StartRespawnTimer()
{
	if(g_TimerRespawn == INVALID_HANDLE)
	{
		g_TimerRespawn = CreateTimer(BALL_AUTO_RESPAWN, TimerRespawnBall, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

void StopRespawnTimer()
{
	if(g_TimerRespawn != INVALID_HANDLE)
	{
		KillTimer(g_TimerRespawn);
	}
	
	g_TimerRespawn = INVALID_HANDLE;
}

public Action TimerRespawnBall(Handle h)
{
	StopRespawnTimer();
	RespawnBall();

	return Plugin_Continue;
}


void SetBallHolder(int client)
{
	if (client != g_BallHolder)
	{	
		g_BallHolder = client;

		float v[3];
		GetClientAbsOrigin(client, v);
		
		EmitAmbientSound("knastjunkies/gotball.mp3", v);
		
		StopRespawnTimer();
	}
}
/*
public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup) 
{ 
	if(victim == g_BallHolder && IsClientValid(attacker) && IsClientValid(victim) && victim != attacker)
	{
		KickBall(victim, 500.0);
	}
} */

int RecreateBall()
{
	DestroyBall();
	return CreateBall();
}

int CreateBall()
{
	int ball = CreateEntityByName("hegrenade_projectile");
	DispatchKeyValue(ball, "targetname", BALL_ENTITY_NAME);
	
	DispatchSpawn(ball);
	SetEntityModel(ball, g_BallModel);
	SetEntProp(ball, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS_TRIGGER);

	SetEntProp(ball, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID | FSOLID_TRIGGER);
	SetEntPropFloat(ball, Prop_Data, "m_flModelScale", 0.60);

	SetEntPropEnt(ball, Prop_Send, "m_hThrower", 1);
	SetEntProp(ball, Prop_Data, "m_iTeamNum", 2);
	SetEntPropEnt(ball, Prop_Send, "m_hOwnerEntity", 1);
	
	Entity_SetMinSize(ball, view_as<float>({-BALL_RADIUS, -BALL_RADIUS, -BALL_RADIUS}));
	Entity_SetMaxSize(ball, view_as<float>({BALL_RADIUS, BALL_RADIUS, BALL_RADIUS}));
	
	SetEntityGravity(ball, 0.8);
	
	SDKHook(ball, SDKHook_StartTouchPost, OnBallTouch);

	g_BallRef = EntIndexToEntRef(ball);
	
	return ball;
}

public void OnBallTouch(int ball, int entity)
{
	if(g_BallHolder <= 0)
	{
		if(IsPlayer(entity) && IsPlayerAlive(entity) && (g_fNextTouch[entity] <= GetGameTime() || g_BallHolder != -1 * entity))
		{
			SetBallHolder(entity);
		}

		// Prevent ball bounced on wall from going through you.
		else if(entity == 0)
		{
			g_BallHolder = 0;
		}
	}
}

void DestroyBall()
{
	int ball = EntRefToEntIndex(g_BallRef);

	if(ball == INVALID_ENT_REFERENCE)
		return;

	
	SetEntProp(ball, Prop_Send, "m_fEffects", GetEntProp(ball, Prop_Send, "m_fEffects") | 32);
	AcceptEntityInput(ball, "Kill");

	g_BallRef = INVALID_ENT_REFERENCE;
}

public bool BallTraceFilter(int entity, int mask, any client)
{
	int ball = EntRefToEntIndex(g_BallRef);

	return !IsPlayer(entity) && entity != ball;
}

void RespawnBall()
{
	int ball = ClearBall();

	if(!IsValidEntity(ball))
		return;

	SetEntityMoveType(ball, MOVETYPE_FLYGRAVITY);
	TeleportEntity(ball, g_BallSpawnOrigin, NULL_VECTOR, view_as<float>({0.0, 0.0, 100.0}));
}

void RemoveBallHolder()
{
	g_BallHolder = 0;
}

int ClearBall()
{
	RemoveBallHolder();
	return RecreateBall();
}

void KickBall(int client, float power)
{
	if(IsInterferenceForKick(client, BALL_KICK_DISTANCE))
	{
		return;
	}

	int ball = RecreateBall();
	
	float clientEyeAngles[3];
	GetClientEyeAngles(client, clientEyeAngles);
	
	float angleVectors[3];
	GetAngleVectors(clientEyeAngles, angleVectors, NULL_VECTOR, NULL_VECTOR);
	
	float ballVelocity[3];
	ballVelocity[0] = angleVectors[0] * power;
	ballVelocity[1] = angleVectors[1] * power;
	ballVelocity[2] = angleVectors[2] * power;
	
	float frontOrigin[3];
	GetClientFrontBallOrigin(client, BALL_KICK_DISTANCE, BALL_HOLD_HEIGHT + BALL_KICK_HEIGHT_ADDITION, frontOrigin);
	
	float kickOrigin[3];
	kickOrigin[0] = frontOrigin[0];
	kickOrigin[1] = frontOrigin[1];
	kickOrigin[2] = frontOrigin[2] + BALL_KICK_HEIGHT_ADDITION;

	TeleportEntity(ball, kickOrigin, NULL_VECTOR, ballVelocity);

	g_fNextTouch[client] = GetGameTime() + 0.4;
	
	g_BallHolder = -1 * client;
	
	StartRespawnTimer();
}

bool IsInterferenceForKick(int client, float kickDistance)
{
	float clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);
	
	float clientEyeAngles[3];
	GetClientEyeAngles(client, clientEyeAngles);
		
	float cos = Cosine(DegToRad(clientEyeAngles[1]));
	float sin = Sine(DegToRad(clientEyeAngles[1]));
	
	float leftBottomOrigin[3];
	leftBottomOrigin[0] = clientOrigin[0] - sin * BALL_RADIUS;
	leftBottomOrigin[1] = clientOrigin[1] - cos * BALL_RADIUS;
	leftBottomOrigin[2] = clientOrigin[2] + BALL_HOLD_HEIGHT + BALL_KICK_HEIGHT_ADDITION - BALL_RADIUS;
	
	float startOriginAddtitions[3];
	startOriginAddtitions[0] = sin * BALL_RADIUS;
	startOriginAddtitions[1] = cos * BALL_RADIUS;
	startOriginAddtitions[2] = BALL_RADIUS;
	
	float testOriginAdditions[3];
	testOriginAdditions[0] = cos * (kickDistance + BALL_RADIUS);
	testOriginAdditions[1] = sin * (kickDistance + BALL_RADIUS);
	testOriginAdditions[2] = 0.0;	
	
	float startOrigin[3];
	float testOrigin[3];
	
	for(int x = 0; x < 3; x++)
	{
		for(int y = 0; y < 3; y++)
		{
			for(int z = 0; z < 3; z++)
			{
				startOrigin[0] = leftBottomOrigin[0] + x * startOriginAddtitions[0];
				startOrigin[1] = leftBottomOrigin[1] + y * startOriginAddtitions[1];
				startOrigin[2] = leftBottomOrigin[2] + z * startOriginAddtitions[2];
				
				for (int j = 0; j < 3; j++)
				{
					testOrigin[j] = startOrigin[j] + testOriginAdditions[j];
				}
				
				TR_TraceRayFilter(startOrigin, testOrigin, MASK_SOLID, RayType_EndPoint, BallTraceFilter, client);
				
				if(TR_DidHit())
				{
					return true;
				}
			}
		}
	}
	
	return false;
}

void SetBallInFront(int client)
{	
	int ball = EntRefToEntIndex(g_BallRef);

	if(ball == INVALID_ENT_REFERENCE)
		return;

	float origin[3];
	GetClientFrontBallOrigin(client, BALL_PLAYER_DISTANCE, BALL_HOLD_HEIGHT, origin);

	TeleportEntity(ball, origin, NULL_VECTOR, view_as<float>({0.0, 0.0, 100.0}));
}

void GetClientFrontBallOrigin(int client, float distance, int height, float destOrigin[3])
{
	float clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);
	
	float clientEyeAngles[3];
	GetClientEyeAngles(client, clientEyeAngles);
	
	float cos = Cosine(DegToRad(clientEyeAngles[1]));
	float sin = Sine(DegToRad(clientEyeAngles[1]));
	
	destOrigin[0] = clientOrigin[0] + cos * distance;
	destOrigin[1] = clientOrigin[1] + sin * distance;
	destOrigin[2] = clientOrigin[2] + height;
}

void LoadBall() 
{
	char szPathConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPathConfig, sizeof szPathConfig, BALL_CFG_FILE);
	
	Handle ConfigTree = CreateKeyValues("Spawns");
	FileToKeyValues(ConfigTree, szPathConfig);

	char szMap[50];
	GetCurrentMap(szMap, sizeof szMap);
	
	if(KvJumpToKey(ConfigTree, szMap)) 
	{
		g_BallSpawnOrigin[0] = KvGetFloat(ConfigTree, "x");
		g_BallSpawnOrigin[1] = KvGetFloat(ConfigTree, "y");
		g_BallSpawnOrigin[2] = KvGetFloat(ConfigTree, "z");
		
		g_BallSpawnExists = true;
		CreateBall();
		RespawnBall();
	}
	
	CloseHandle(ConfigTree);
}

stock void Entity_SetMinSize(int entity, float vecMins[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecMins);
}

stock void Entity_SetMaxSize(int entity, float vecMaxs[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxs);
}

stock bool GetPlayerEyeViewPoint(int iClient, float fPosition[3])
{
	float fAngles[3];
	GetClientEyeAngles(iClient, fAngles);

	float fOrigin[3];
	GetClientEyePosition(iClient, fOrigin);

	Handle hTrace = TR_TraceRayFilterEx(fOrigin, fAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if(TR_DidHit(hTrace))
	{
		TR_GetEndPosition(fPosition, hTrace);
		CloseHandle(hTrace);
		
		return true;
	}
	
	CloseHandle(hTrace);
	
	return false;
}

public bool TraceEntityFilterPlayer(int iEntity, int iContentsMask)
{
	return iEntity > MaxClients;
}	

stock bool IsPlayer(int client)
{
	if(client == 0)
		return false;
	
	else if(client > MaxClients)
		return false;
	
	return true;
}
