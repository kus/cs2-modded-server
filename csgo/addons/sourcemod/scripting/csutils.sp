// Much of the work for this plugin is credited to Deathknife,
// whose help in getting nades thrown in a working manner wouldn't be possible without.

#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#include <smlib>
#include <sourcemod>

#include "include/csutils.inc"
#include "include/logdebug.inc"

#include "practicemode/util.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_VersionCvar;

Handle g_OnGrenadeThrownForward = INVALID_HANDLE;
Handle g_OnGrenadeExplodeForward = INVALID_HANDLE;

ArrayList g_NadeList;
ArrayList g_SmokeList;

#define SMOKE_EMIT_SOUND "weapons/smokegrenade/smoke_emit.wav"

// clang-format off
public Plugin myinfo = {
  name = "csutils",
  author = "splewis/Deathknife",
  description = "Grenade throwing natives/forwards",
  version = PLUGIN_VERSION,
  url = "https://github.com/splewis"
};
// clang-format on

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  CreateNative("CSU_ThrowGrenade", Native_ThrowGrenade);
  RegPluginLibrary("csutils");
  return APLRes_Success;
}

public void OnPluginStart() {
  InitDebugLog("csutils_debug", "csutils");
  LogDebug("OnPluginStart version=%s", PLUGIN_VERSION);

  g_VersionCvar = CreateConVar("sm_csutils_version", PLUGIN_VERSION, "Current csutils version",
                               FCVAR_NOTIFY | FCVAR_DONTRECORD);
  g_VersionCvar.SetString(PLUGIN_VERSION);

  g_OnGrenadeThrownForward =
      CreateGlobalForward("CSU_OnThrowGrenade", ET_Ignore, Param_Cell, Param_Cell, Param_Cell,
                          Param_Array, Param_Array, Param_Array, Param_Array);
  g_OnGrenadeExplodeForward = CreateGlobalForward("CSU_OnGrenadeExplode", ET_Ignore, Param_Cell,
                                                  Param_Cell, Param_Cell, Param_Array);

  HookEvent("smokegrenade_detonate", Event_SmokeDetonate, EventHookMode_Pre);
}

public void OnMapStart() {
  PrecacheSound(SMOKE_EMIT_SOUND);

  delete g_NadeList;
  g_NadeList = new ArrayList(8);

  delete g_SmokeList;
  g_SmokeList = new ArrayList();
}

public void AddNade(int entRef, GrenadeType type, const float[3] origin, const float[3] velocity) {
  int index = g_NadeList.Push(entRef);
  g_NadeList.Set(index, type, 1);
  for (int i = 0; i < 3; i++) {
    g_NadeList.Set(index, view_as<int>(origin[i]), 2 + i);
    g_NadeList.Set(index, view_as<int>(velocity[i]), 2 + 3 + i);
  }
}

public void GetNade(int index, int& entRef, GrenadeType& type, float origin[3], float velocity[3]) {
  entRef = g_NadeList.Get(index, 0);
  type = g_NadeList.Get(index, 1);
  for (int i = 0; i < 3; i++) {
    origin[i] = g_NadeList.Get(index, 2 + i);
    velocity[i] = g_NadeList.Get(index, 2 + 3 + i);
  }
}

public bool IsManagedNade(int entity, int& index) {
  int ref = EntIndexToEntRef(entity);
  for (int i = 0; i < g_NadeList.Length; i++) {
    if (g_NadeList.Get(i, 0) == ref) {
      index = i;
      return true;
    }
  }
  return false;
}

public int Native_ThrowGrenade(Handle plugin, int numParams) {
  int client = GetNativeCell(1);

  GrenadeType grenadeType = view_as<GrenadeType>(GetNativeCell(2));
  CheckGrenadeType(grenadeType);

  float origin[3];
  GetNativeArray(3, origin, sizeof(origin));

  float velocity[3];
  GetNativeArray(4, velocity, sizeof(velocity));

  LogDebug("CSU_ThrowGrenade client=%d, grenadeType=%d, origin=[%f %f %f], velocity=[%f %f %f]",
           client, grenadeType, origin[0], origin[1], origin[2], velocity[0], velocity[1],
           velocity[2]);

  char classname[64];
  GetProjectileName(grenadeType, classname, sizeof(classname));

  int entity = CreateEntityByName(classname);
  if (entity == -1) {
    LogError("Could not create nade %s", classname);
    return -1;
  }

  AddNade(EntIndexToEntRef(entity), grenadeType, origin, velocity);
  TeleportEntity(entity, origin, NULL_VECTOR, velocity);

  DispatchSpawn(entity);
  DispatchKeyValue(entity, "globalname", "custom");

  int team = CS_TEAM_T;
  if (IsValidClient(client)) {
    team = GetClientTeam(client);
  }

  AcceptEntityInput(entity, "InitializeSpawnFromWorld");
  AcceptEntityInput(entity, "FireUser1", client);

  SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
  SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
  SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);

  if (grenadeType == GrenadeType_Incendiary) {
    SetEntProp(entity, Prop_Send, "m_bIsIncGrenade", true, 1);
    SetEntityModel(entity, "models/weapons/w_eq_incendiarygrenade_dropped.mdl");
  }

  return entity;
}

public void OnGameFrame() {
  for (int i = 0; i < g_SmokeList.Length; i++) {
    int ref = g_SmokeList.Get(i);
    int ent = EntRefToEntIndex(ref);

    if (ent == INVALID_ENT_REFERENCE) {
      g_SmokeList.Erase(i);
      i--;
      continue;
    }

    float vel[3];
    GetEntPropVector(ent, Prop_Data, "m_vecVelocity", vel);
    if (GetVectorLength(vel) <= 0.1) {
      SetEntProp(ent, Prop_Send, "m_nSmokeEffectTickBegin", GetGameTickCount() + 1);
      EmitSoundToAll(SMOKE_EMIT_SOUND, ent, 6, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL,
                     SNDPITCH_NORMAL);
      CreateTimer(15.0, KillNade, ref);
      g_SmokeList.Erase(i);
      i--;
    }
  }
}

public bool HandleNativeRequestedNade(int entity) {
  int ref = EntIndexToEntRef(entity);

  for (int i = 0; i < g_NadeList.Length; i++) {
    if (g_NadeList.Get(i, 0) == ref) {
      int entRef;
      GrenadeType type;
      float origin[3];
      float velocity[3];
      GetNade(i, entRef, type, origin, velocity);

      float angVelocity[3];
      angVelocity[0] = GetRandomFloat(-1000.0, 1000.0);
      angVelocity[1] = 0.0;
      angVelocity[2] = 600.0;

      SetEntProp(entity, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_PROJECTILE);
      SetEntPropFloat(entity, Prop_Data, "m_flElasticity", 0.45);
      SetEntPropFloat(entity, Prop_Data, "m_flGravity", 0.4);
      SetEntPropFloat(entity, Prop_Data, "m_flFriction", 0.2);
      SetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin);
      SetEntPropVector(entity, Prop_Data, "m_vecVelocity", velocity);
      SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", velocity);
      SetEntPropVector(entity, Prop_Data, "m_vecAngVelocity", angVelocity);

      if (type == GrenadeType_HE) {
        SetEntPropFloat(entity, Prop_Data, "m_flDamage", 99.0);
        SetEntPropFloat(entity, Prop_Data, "m_DmgRadius", 350.0);
      }

      TeleportEntity(entity, origin, NULL_VECTOR, velocity);
      if (type == GrenadeType_Smoke) {
        g_SmokeList.Push(ref);
      }
      return true;
    }
  }
  return false;
}

public Action KillNade(Handle timer, int ref) {
  int ent = EntRefToEntIndex(ref);
  if (ent != INVALID_ENT_REFERENCE) {
    AcceptEntityInput(ent, "kill");
  }
}

public void OnEntityCreated(int entity, const char[] className) {
  // Happening before OnMapStart.
  if (g_NadeList == null) {
    return;
  }

  GrenadeType type = GrenadeFromProjectileName(className, entity);
  if (type == GrenadeType_None) {
    return;
  }

  // For "normal" nades, we'll save their parameters so we can fire the forward.
  // For nades we know came through a call of the CSU_ThrowNade native we'll set some props onit.
  SDKHook(entity, SDKHook_SpawnPost, OnGrenadeProjectileSpawned);

  // For some reason, collisions for other nade-types because they crash when they
  // hit players.
  if (type != GrenadeType_Molotov && type != GrenadeType_Incendiary && type != GrenadeType_HE) {
    SDKHook(entity, SDKHook_StartTouch, OnTouch);
  }
}

public void OnEntityDestroyed(int entity) {
  // Happening before OnMapStart.
  if (g_NadeList == null) {
    return;
  }

  if (!IsValidEntity(entity)) {
    return;
  }

  char className[64];
  GetEntityClassname(entity, className, sizeof(className));
  GrenadeType type = GrenadeFromProjectileName(className, entity);
  if (type == GrenadeType_None) {
    return;
  }

  // Fire the CSU_OnGrenadeExplode forward.
  int client = Entity_GetOwner(client);
  float origin[3];
  GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin);

  // Erase the ent ref from the global nade list.
  int index;
  if (IsManagedNade(entity, index)) {
    g_NadeList.Erase(index);
  } else {
    // We handle smokes differently here because the OnEntityDestroyed forward
    // won't get called until the smoke effect goes away, which is later than we want.
    // The smokegrenade_detonate event handler takes care of the forward for smokes.
    //
    // Why not do all nades in the *_detonate handlers? The molotov_detonate event
    // doesn't pass the entityid parameter according to the alliedmods wiki.
    if (type != GrenadeType_Smoke) {
      Call_StartForward(g_OnGrenadeExplodeForward);
      Call_PushCell(client);
      Call_PushCell(entity);
      Call_PushCell(type);
      Call_PushArray(origin, 3);
      Call_Finish();
    }
  }
}

public Action OnTouch(int entity, int other) {
  int unused;
  if (IsValidClient(other) && IsManagedNade(entity, unused)) {
    SetEntPropEnt(entity, Prop_Data, "m_hThrower", other);
    SetEntProp(entity, Prop_Send, "m_iTeamNum", GetClientTeam(other));
  }
}

public void OnGrenadeProjectileSpawned(int entity) {
  RequestFrame(GetGrenadeParameters, entity);
}

public void GetGrenadeParameters(int entity) {
  // For an entity that came for a CSU_ThrowGrenade native call, we'll setup
  // the grenade properties here.
  if (HandleNativeRequestedNade(entity)) {
    return;
  }

  // For other grenades, we'll wait two frames to capture the properties of the nade.
  // Why 2 frames? Testing showed that was needed to get accurate explosion spots based
  // on how the native is implemented. (Accurate replay is the #1 goal of the forward+native).
  RequestFrame(DelayCaptureEntity, entity);
}

public void DelayCaptureEntity(int entity) {
  RequestFrame(CaptureEntity, entity);
}

public void CaptureEntity(int entity) {
  char className[128];
  GetEntityClassname(entity, className, sizeof(className));
  GrenadeType grenadeType = GrenadeFromProjectileName(className, entity);

  int client = Entity_GetOwner(entity);
  float origin[3];
  float velocity[3];
  GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin);
  GetEntPropVector(entity, Prop_Data, "m_vecVelocity", velocity);

  Call_StartForward(g_OnGrenadeThrownForward);
  Call_PushCell(client);
  Call_PushCell(entity);
  Call_PushCell(grenadeType);
  Call_PushArray(origin, 3);
  Call_PushArray(velocity, 3);
  Call_Finish();

  LogDebug(
      "CSU_OnThrowGrenade client=%d, entity=%d, grenadeType=%d, origin=[%f %f %f], velocity=[%f %f %f]",
      client, entity, grenadeType, origin[0], origin[1], origin[2], velocity[0], velocity[1],
      velocity[2]);
}

public void CheckGrenadeType(GrenadeType type) {
  if (type <= GrenadeType_None) {
    ThrowNativeError(SP_ERROR_PARAM, "Invalid grenade type %d", type);
  }
}

public Action Event_SmokeDetonate(Event event, const char[] name, bool dontBroadcast) {
  int userid = event.GetInt("userid");
  int entity = event.GetInt("entityid");
  float origin[3];
  origin[0] = event.GetFloat("x");
  origin[1] = event.GetFloat("y");
  origin[2] = event.GetFloat("z");

  if (!IsValidEntity(entity)) {
    return;
  }

  int unused;
  if (!IsManagedNade(entity, unused)) {
    Call_StartForward(g_OnGrenadeExplodeForward);
    Call_PushCell(GetClientOfUserId(userid));
    Call_PushCell(entity);
    Call_PushCell(GrenadeType_Smoke);
    Call_PushArray(origin, 3);
    Call_Finish();
  }
}
