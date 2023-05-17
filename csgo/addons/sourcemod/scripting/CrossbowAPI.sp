#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <smlib>
#include <emitsoundany>
#include <customweapons>

#pragma semicolon 1

#define PLUGIN_VERSION "1.0"

#define BLOOD_LIFETIME 10.0
#define FIRE_RATE 1.0
#define MAX_AMMO 5

// Make sure this is not one of the damage types when shooting with an awp.
// If you don't, then the crossbow will deal 0 damage.
#define DMG_CROSSBOW DMG_GENERIC

public Plugin myinfo = 
{
	name = "[CS:GO] Crossbow API", 
	author = "Eyal282", 
	description = "Crossbow gun like in the TTT server of backwards'", 
	version = PLUGIN_VERSION, 
	url = "N/A"
}

#define EF_NODRAW 32


GlobalForward hcv_ShouldCrossbow;

bool bHasCrossbow[MAXPLAYERS + 1];
bool bHoldingCrossbow[MAXPLAYERS + 1];

int SpawnSerial[MAXPLAYERS + 1];

ConVar hcv_mpTeammatesAreEnemies;

ArrayList crossbows;

char HitSound[] = "hostage/hpain/hpain6.wav";

public void OnMapStart()
{
	if(!FileExists("models/weapons/eminem/advanced_crossbow/v_advanced_crossbow.mdl"))
	{
		char filename[256];
		GetPluginFilename(INVALID_HANDLE, filename, sizeof(filename));

		ServerCommand("sm_rcon sm plugins unload %s", filename);

		return;
	}

	RegPluginLibrary("CrossbowAPI");

	LoadDirOfModels("materials/models/weapons/eminem/advanced_crossbow");
	LoadDirOfModels("models/weapons/eminem/advanced_crossbow");
	LoadDirOfModels("sound/weapons/eminem/advanced_crossbow");
	PrecacheModel("models/weapons/eminem/advanced_crossbow/v_advanced_crossbow.mdl", true);
	PrecacheModel("models/weapons/eminem/advanced_crossbow/w_advanced_crossbow.mdl", true);
	PrecacheModel("models/weapons/eminem/advanced_crossbow/w_advanced_crossbow_dropped.mdl", true);
	PrecacheModel("models/weapons/eminem/advanced_crossbow/w_crossbow_bolt_dropped.mdl", true);
	
	PrecacheSoundAny(HitSound);
	PrecacheSound("weapons/eminem/advanced_crossbow/crossbow-1.wav", true);
	
}

public void OnPluginStart()
{
	crossbows = new ArrayList(1);

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
	
	hcv_mpTeammatesAreEnemies = FindConVar("mp_teammates_are_enemies");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		Func_OnClientPutInServer(i);
	}

	// return true to make client have crossbow when swapping to AWP.
	// public bool OnShouldPlayerHaveCrossbow(int client)
	hcv_ShouldCrossbow = CreateGlobalForward("OnShouldPlayerHaveCrossbow", ET_Event, Param_Cell);
}

public void OnClientConnected(int client)
{
	SpawnSerial[client] = 0;
}
public void OnClientPutInServer(int client)
{
	Func_OnClientPutInServer(client);
}

public void Func_OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponDropPost, OnWeaponDrop);
}

public Action OnWeaponDrop(int client, int wpnid)
{
	if(!bHasCrossbow[client] || !bHoldingCrossbow[client])
		return Plugin_Continue;

	else if(wpnid < 1)
		return Plugin_Continue;
	
	CreateTimer(0.0, SetWorldModel, EntIndexToEntRef(wpnid));
	return Plugin_Continue;
}


public Action SetWorldModel(Handle tmr, any ref)
{
	int weapon = EntRefToEntIndex(ref);
	
	if(weapon == INVALID_ENT_REFERENCE || !IsValidEntity(weapon) || !IsValidEdict(weapon))
		return Plugin_Continue;
	
	else if(!IsEntityM4A1(weapon))
		return Plugin_Continue;
		
	SetEntityModel(weapon, "models/weapons/eminem/advanced_crossbow/w_advanced_crossbow.mdl");
	
	return Plugin_Continue;
}

// Only relevant for axe...
/*
public Action OnWeaponCanUse(int client, int weapon)
{
	if (weapon == -1)
		return Plugin_Continue;
	
	else if (!IsEntityM4A1(weapon))
		return Plugin_Continue;
	

	GivePlayerAwp(client);
	AcceptEntityInput(weapon, "Kill");
	return Plugin_Handled;
}
*/

public void OnWeaponEquipPost(int client, int weapon)
{	
	if (weapon == -1)
		return;
	
	else if (!IsEntityM4A1(weapon))
		return;
	
	bHoldingCrossbow[client] = true;

	Call_StartForward(hcv_ShouldCrossbow);

	Call_PushCell(client);

	bool bCrossbow;
	Call_Finish(bCrossbow);

	if(bCrossbow)
	{
		char iName[2];
		GetEntPropString(weapon, Prop_Data, "m_iName", iName, sizeof(iName));

		if(iName[0] == EOS)
		{
			SetEntPropString(weapon, Prop_Data, "m_iName", "Crossbow");

			if(GetEntProp(weapon, Prop_Data, "m_iClip1") > MAX_AMMO)
				SetEntProp(weapon, Prop_Data, "m_iClip1", MAX_AMMO);

			SDKHook(weapon, SDKHook_ReloadPost, OnReloadPost);
			crossbows.Push(weapon);

			CustomWeapon cWeapon = CustomWeapon(weapon);
			
			cWeapon.SetModel(CustomWeaponModel_View, "models/weapons/eminem/advanced_crossbow/v_advanced_crossbow.mdl");
			cWeapon.SetModel(CustomWeaponModel_World, "models/weapons/eminem/advanced_crossbow/w_advanced_crossbow.mdl");
			cWeapon.SetShotSound("weapons/eminem/advanced_crossbow/crossbow-1.wav");
		}

		bHasCrossbow[client] = true;
	}
	else
	{
		bHasCrossbow[client] = false;

		CustomWeapon cWeapon = CustomWeapon(weapon);

		char sModel[256];

		cWeapon.GetModel(CustomWeaponModel_View, sModel, sizeof(sModel));

		if(StrEqual(sModel, "models/weapons/eminem/advanced_crossbow/v_advanced_crossbow.mdl"))
		{
			cWeapon.SetModel(CustomWeaponModel_View, "");
			cWeapon.SetModel(CustomWeaponModel_World, "");
			cWeapon.SetShotSound("");
		}
	}	
}



public Action OnTakeDamage(int victim, int & attacker, int & inflictor, float & damage, int & damagetype)
{
	if (!IsPlayer(attacker))
		return Plugin_Continue;
	
	else if(!bHasCrossbow[attacker] || !bHoldingCrossbow[attacker])
		return Plugin_Continue;

	if (damagetype != DMG_CROSSBOW)
	{
		damage = 0.0;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public void OnStartTouch(int bullet, int toucher)
{
	int owner = GetEntPropEnt(bullet, Prop_Send, "m_hOwnerEntity");
	
	if (owner == -1)
		return;

	
	if (IsPlayer(toucher))
	{
		if (toucher == owner)
			return;
		
		else if (GetClientTeam(toucher) == GetClientTeam(owner) && !hcv_mpTeammatesAreEnemies.BoolValue)
			return;
		
		OnPlayerHitByCrossbow(toucher, owner, bullet);
	}
	
	else
	{

		char Classname[64];
		GetEdictClassname(toucher, Classname, sizeof(Classname));

		if(strncmp(Classname, "weapon_", 7) == 0)
			return;

		// hegrenade_projectile, smokegrenade_projectile...
		else if(StrContains(Classname, "projectile", false) != -1)
			return;

		else if(strncmp(Classname, "trigger_", 8) == 0)
			return;

		// If you hit glass or a JailBreak vent, break it!
		SDKHooks_TakeDamage(toucher, bullet, owner, 128.0, DMG_CROSSBOW);
	}
	
	AcceptEntityInput(bullet, "Kill");
}

public void OnPlayerHitByCrossbow(int victim, int attacker, int bullet)
{
	float fOrigin[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", fOrigin);

	EmitSoundByDistanceAny(3000.0, HitSound, -2, 0, 75, 0, 1.0, 100, -1, fOrigin, NULL_VECTOR, true, 0.0);
	
	DataPack DP, DP2;
	
	CreateDataTimer(0.2, Timer_TakeBleedDamage, DP, TIMER_REPEAT);
	
	DP.WriteCell(GetClientUserId(victim));
	DP.WriteCell(GetClientUserId(attacker));
	DP.WriteCell(SpawnSerial[victim]);
	
	Handle hTimer = CreateDataTimer(0.5, Timer_AnimateBleed, DP2, TIMER_REPEAT);
	
	DP2.WriteCell(GetClientUserId(victim));
	DP2.WriteCell(SpawnSerial[victim]);
	
	TriggerTimer(hTimer, true);
}
public bool TraceRayOnlyHitTarget(int entityhit, int mask, int target)
{
	return entityhit == target;
}

public Action Timer_TakeBleedDamage(Handle hTimer, DataPack DP)
{
	DP.Reset();
	
	int victim = GetClientOfUserId(DP.ReadCell());
	int attacker = GetClientOfUserId(DP.ReadCell());
	int serial = DP.ReadCell();


	Call_StartForward(hcv_ShouldCrossbow);

	Call_PushCell(attacker);

	bool bCrossbow;
	Call_Finish(bCrossbow);

	bHasCrossbow[attacker] = bCrossbow;

	if (victim == 0 || attacker == 0)
		return Plugin_Stop;
	
	else if (!IsPlayerAlive(victim))
		return Plugin_Stop;
	
	else if (serial != SpawnSerial[victim])
		return Plugin_Stop;

	else if(!bHasCrossbow[attacker])
		return Plugin_Stop;
	
	SetClientArmor(victim, 0);
	SDKHooks_TakeDamage(victim, victim, attacker, 1.0, DMG_CROSSBOW);
	
	return Plugin_Continue;
}

public Action Timer_AnimateBleed(Handle hTimer, DataPack DP)
{
	DP.Reset();
	
	int victim = GetClientOfUserId(DP.ReadCell());
	int serial = DP.ReadCell();
	
	if (victim == 0)
		return Plugin_Stop;
	
	else if (!IsPlayerAlive(victim))
		return Plugin_Stop;
	
	else if (serial != SpawnSerial[victim])
		return Plugin_Stop;
	
	CreateParticle(victim, "blood_pool");
	
	return Plugin_Continue;
}
void CreateParticle(int victim, char[] szName)
{
	// We should stop if we have too much entities..
	if(GetEntityCount() > 1700)
		return;

	int iEntity = CreateEntityByName("info_particle_system");
	
	if (IsValidEdict(iEntity))
	{
		// Get players current position
		float vPosition[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", vPosition);
		
		// Move particle to player
		TeleportEntity(iEntity, vPosition, NULL_VECTOR, NULL_VECTOR);
		
		// Set entity name
		DispatchKeyValue(iEntity, "targetname", "particle");
		
		// Get player entity name
		char szParentName[64];
		GetEntPropString(victim, Prop_Data, "m_iName", szParentName, sizeof(szParentName));
		
		// Set the effect name
		DispatchKeyValue(iEntity, "effect_name", szName);
		
		// Spawn the particle
		DispatchSpawn(iEntity);
		
		// Activate the entity (starts animation)
		ActivateEntity(iEntity);
		AcceptEntityInput(iEntity, "Start");
		
		// Attach to parent model
		SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", victim);
		
		CreateTimer(BLOOD_LIFETIME, Timer_DeleteEntity, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE);
		
		SetFlags(iEntity);
		SDKHook(iEntity, SDKHook_SetTransmit, OnSetTransmit);
	}
}

public Action Timer_DeleteEntity(Handle hTimer, int Ref)
{
	int entity = EntRefToEntIndex(Ref);
	
	if (entity == INVALID_ENT_REFERENCE)
		return Plugin_Continue;
	
	AcceptEntityInput(entity, "Stop");
	AcceptEntityInput(entity, "Kill");

	return Plugin_Continue;
}

public void SetFlags(int iEdict)
{
	if (GetEdictFlags(iEdict) & FL_EDICT_ALWAYS)
	{
		SetEdictFlags(iEdict, (GetEdictFlags(iEdict) ^ FL_EDICT_ALWAYS));
	}
}

public Action OnSetTransmit(int iEnt, int iClient)
{
	int iOwner = GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity");
	SetFlags(iEnt);
	if (iOwner && IsClientInGame(iOwner))
	{
		return Plugin_Continue;
		
	}
	
	return Plugin_Continue;
}

public void Frame_NoGravity(DataPack DP)
{
	ResetPack(DP);
	
	int bullet = DP.ReadCell();
	
	if (!IsValidEntity(bullet))
	{
		delete DP;
		return;
	}
	float Velocity[3];
	
	GetEntPropVector(bullet, Prop_Data, "m_vecVelocity", Velocity);
	
	Velocity[2] = DP.ReadFloat();
	
	TeleportEntity(bullet, NULL_VECTOR, NULL_VECTOR, Velocity);
	
	RequestFrame(Frame_NoGravity, DP);
}
public void Frame_GiveModel(int bullet)
{
	SetEntityModel(bullet, "models/weapons/eminem/advanced_crossbow/w_crossbow_bolt_dropped.mdl");
	
	SetEntProp(bullet, Prop_Send, "m_fEffects", GetEntProp(bullet, Prop_Send, "m_fEffects") & ~EF_NODRAW);
	//new Float:Origin[3];
}


public void OnReloadPost(int weapon, bool successful)
{
	if(!successful)
		return;

	else if(weapon == -1)
		return;

	else if(crossbows.FindValue(weapon) == -1)
		return;


	int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");

	if(client == -1)
		return;

	else if(!bHasCrossbow[client] || !bHoldingCrossbow[client])
		return;

	CreateTimer(0.1, Timer_CheckCrossbowReload, EntIndexToEntRef(weapon), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CheckCrossbowReload(Handle hTimer, int Ref)
{
	int weapon = EntRefToEntIndex(Ref);

	if(weapon == INVALID_ENT_REFERENCE)
		return Plugin_Stop;

	if(GetEntProp(weapon, Prop_Data, "m_iClip1") > MAX_AMMO)
	{
		SetEntProp(weapon, Prop_Data, "m_iClip1", MAX_AMMO);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Event_WeaponFire(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(client == 0)
		return Plugin_Continue;

	else if(!bHasCrossbow[client] || !bHoldingCrossbow[client])
		return Plugin_Continue;

	int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(activeWeapon == -1)
		return Plugin_Continue;

	else if(crossbows.FindValue(activeWeapon) == -1)
		return Plugin_Continue;

	else if(GetEntProp(activeWeapon, Prop_Data, "m_iClip1") > MAX_AMMO)
		SetEntProp(activeWeapon, Prop_Data, "m_iClip1", MAX_AMMO);

	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + FIRE_RATE);

	int bullet = CreateEntityByName("smokegrenade_projectile");
	
	// A random model to create a physics object.
	SetEntityModel(bullet, "models/weapons/w_eq_fraggrenade_dropped.mdl");

	DispatchSpawn(bullet);
	ActivateEntity(bullet);

	SetEntProp(bullet, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS_TRIGGER);

	SetEntProp(bullet, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID | FSOLID_TRIGGER);
	
	//SetEntityMoveType(bullet, MOVETYPE_FLY);
	
	float speed = 1024.0;
	
	float fOrigin[3], fAngles[3], fFwd[3];
	
	GetClientEyePosition(client, fOrigin);
	GetClientEyeAngles(client, fAngles);
	
	GetAngleVectors(fAngles, fFwd, NULL_VECTOR, NULL_VECTOR);
	
	//fAngles = fFwd;
	NormalizeVector(fFwd, fFwd);
	ScaleVector(fFwd, speed);
	
	// While the bullet is a smokegrenade model, make it invisible.
	SetEntProp(bullet, Prop_Send, "m_fEffects", GetEntProp(bullet, Prop_Send, "m_fEffects") | EF_NODRAW);
	
	//AcceptEntityInput(bullet, "EnableMotion");
	
	TeleportEntity(bullet, fOrigin, fAngles, fFwd);
	
	//SetEntityMoveType(bullet, MOVETYPE_VPHYSICS);
	
	DataPack DP = new DataPack();
	DP.WriteCell(bullet);
	DP.WriteFloat(fFwd[2]);
	
	RequestFrame(Frame_NoGravity, DP);
	
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 1.0);
	
	// After the entity is created, give the real model.
	
	SetEntPropEnt(bullet, Prop_Send, "m_hOwnerEntity", client);
	SDKHook(bullet, SDKHook_StartTouchPost, OnStartTouch);
	RequestFrame(Frame_GiveModel, bullet);
	
	return Plugin_Continue;
}

public Action Event_RoundStart(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	crossbows.Clear();

	return Plugin_Continue;
}

public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	SpawnSerial[client]++;
	
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	bHasCrossbow[client] = false;
	bHoldingCrossbow[client] = false;
	
	if (weapon == -1)
		return Plugin_Continue;
	
	else if (!IsEntityM4A1(weapon))
		return Plugin_Continue;
	
	OnWeaponEquipPost(client, weapon);

	return Plugin_Continue;
}

stock void LoadDirOfModels(char[] dirofmodels)
{
	char path[256];
	FileType type;
	char FileAfter[256];
	Handle dir = OpenDirectory(dirofmodels, false, "GAME");
	
	if (!dir)
	{
		return;
	}
	while (ReadDirEntry(dir, path, 256, type))
	{
		if (type == FileType_File)
		{
			FormatEx(FileAfter, 256, "%s/%s", dirofmodels, path);
			AddFileToDownloadsTable(FileAfter);
		}
	}
	CloseHandle(dir);
	dir = INVALID_HANDLE;
	return;
}
/*
stock int GivePlayerAwp(int client)
{
	int entity = CreateEntityByName("weapon_m4a1");
	
	EquipPlayerWeapon(client, entity);
	
	return entity;
}
*/

stock bool IsPlayer(int entity)
{
	if (entity < 1)
		return false;
	
	else if (entity > MaxClients)
		return false;
	
	return true;
}

stock bool IsEntityM4A1(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex") == CS_WeaponIDToItemDefIndex(CSWeapon_M4A1);
}

stock void SetClientArmor(int client, int amount)
{
	SetEntProp(client, Prop_Send, "m_ArmorValue", amount);
}

stock EmitSoundByDistanceAny(Float:distance, const String:sample[], 
				entity = SOUND_FROM_PLAYER, 
				channel = SNDCHAN_AUTO, 
				level = SNDLEVEL_NORMAL, 
				flags = SND_NOFLAGS, 
				Float:volume = SNDVOL_NORMAL, 
				pitch = SNDPITCH_NORMAL, 
				speakerentity = -1, 
				const Float:origin[3], 
				const Float:dir[3] = NULL_VECTOR, 
				bool:updatePos = true, 
				Float:soundtime = 0.0)
{
	if(IsNullVector(origin))
	{
		ThrowError("Origin must not be null!");
	}
	
	new clients[MAXPLAYERS+1], count;
	
	for(new i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		new Float:iOrigin[3];
		GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", iOrigin);
		
		if(GetVectorDistance(origin, iOrigin, false) < distance)
			clients[count++] = i;
	}
	
	EmitSoundAny(clients, count, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}


