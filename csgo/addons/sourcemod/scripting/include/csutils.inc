#if defined _csutils_included
#endinput
#endif
#define _csutils_included

enum GrenadeType {
  GrenadeType_None = 0,
  GrenadeType_Smoke = 1,
  GrenadeType_Flash = 2,
  GrenadeType_HE = 3,
  GrenadeType_Molotov = 4,
  GrenadeType_Decoy = 5,
  GrenadeType_Incendiary = 6,
};

// Throws a grenade, setting the grenade owner to client.
native int CSU_ThrowGrenade(int client, GrenadeType grenadeType, const float origin[3],
                            const float velocity[3]);

// Called when a client throws a grenade.
// This is *not* called when the grenade came from the CSU_ThrowGrenade native.
forward void CSU_OnThrowGrenade(int client, int entity, GrenadeType grenadeType,
                                const float origin[3], const float velocity[3]);

// Called when a client's grenade "pops" or explodes.
// This is *not* called when the grenade came from the CSU_ThrowGrenade native.
// origin is the position the grenade exploded/popped.
forward void CSU_OnGrenadeExplode(int client, int entity, GrenadeType grenade,
                                  const float origin[3]);

stock bool IsGrenade(GrenadeType g) {
  return g != GrenadeType_None;
}

stock GrenadeType GrenadeFromProjectileName(const char[] projectileName, int entity = 0) {
  if (StrEqual(projectileName, "smokegrenade_projectile")) {
    return GrenadeType_Smoke;
  } else if (StrEqual(projectileName, "flashbang_projectile")) {
    return GrenadeType_Flash;
  } else if (StrEqual(projectileName, "hegrenade_projectile")) {
    return GrenadeType_HE;
  } else if (StrEqual(projectileName, "decoy_projectile")) {
    return GrenadeType_Decoy;
  } else if (StrEqual(projectileName, "molotov_projectile")) {
    if (IsValidEntity(entity)) {
      int isInc = GetEntData(entity, FindSendPropInfo("CMolotovProjectile", "m_bIsIncGrenade"), 1);
      return isInc ? GrenadeType_Incendiary : GrenadeType_Molotov;
    }
    return GrenadeType_Molotov;
  } else {
    return GrenadeType_None;
  }
}

stock void GetProjectileName(GrenadeType type, char[] buffer, int length) {
  switch (type) {
    case GrenadeType_Smoke:
      Format(buffer, length, "smokegrenade_projectile");
    case GrenadeType_Flash:
      Format(buffer, length, "flashbang_projectile");
    case GrenadeType_HE:
      Format(buffer, length, "hegrenade_projectile");
    case GrenadeType_Molotov:
      Format(buffer, length, "molotov_projectile");
    case GrenadeType_Decoy:
      Format(buffer, length, "decoy_projectile");
    case GrenadeType_Incendiary:
      Format(buffer, length, "molotov_projectile");
    default:
      LogError("Unknown grenade type: %d", type);
  }
}

stock void GetGrenadeWeapon(GrenadeType type, char[] buffer, int length) {
  switch (type) {
    case GrenadeType_Smoke:
      Format(buffer, length, "weapon_smokegrenade");
    case GrenadeType_Flash:
      Format(buffer, length, "weapon_flashbang");
    case GrenadeType_HE:
      Format(buffer, length, "weapon_hegrenade");
    case GrenadeType_Molotov:
      Format(buffer, length, "weapon_molotov");
    case GrenadeType_Decoy:
      Format(buffer, length, "weapon_decoy");
    case GrenadeType_Incendiary:
      Format(buffer, length, "weapon_incgrenade");
    default:
      LogError("Unknown grenade type: %d", type);
  }
}

stock GrenadeType GrenadeTypeFromString(const char[] name) {
  if (StrEqual(name, "smoke")) {
    return GrenadeType_Smoke;
  } else if (StrEqual(name, "flash")) {
    return GrenadeType_Flash;
  } else if (StrEqual(name, "he")) {
    return GrenadeType_HE;
  } else if (StrEqual(name, "molotov")) {
    return GrenadeType_Molotov;
  } else if (StrEqual(name, "decoy")) {
    return GrenadeType_Decoy;
  } else if (StrEqual(name, "incendiary")) {
    return GrenadeType_Incendiary;
  } else {
    return GrenadeType_None;
  }
}

stock void GrenadeTypeString(GrenadeType type, char[] buffer, int length) {
  switch (type) {
    case GrenadeType_Smoke:
      Format(buffer, length, "smoke");
    case GrenadeType_Flash:
      Format(buffer, length, "flash");
    case GrenadeType_HE:
      Format(buffer, length, "he");
    case GrenadeType_Molotov:
      Format(buffer, length, "molotov");
    case GrenadeType_Decoy:
      Format(buffer, length, "decoy");
    case GrenadeType_Incendiary:
      Format(buffer, length, "incendiary");
    default:
      LogError("Unknown grenade type: %d", type);
  }
}

stock void CSU_DelayThrowGrenade(float delay, int client, GrenadeType grenadeType,
                                 const float origin[3], const float velocity[3]) {
  DataPack p = new DataPack();
  if (client == 0) {
    p.WriteCell(0);
  } else {
    p.WriteCell(GetClientSerial(client));
  }
  p.WriteCell(grenadeType);
  p.WriteFloat(origin[0]);
  p.WriteFloat(origin[1]);
  p.WriteFloat(origin[2]);
  p.WriteFloat(velocity[0]);
  p.WriteFloat(velocity[1]);
  p.WriteFloat(velocity[2]);
  CreateTimer(delay, __csutils__DelayThrowGrenade, p);
}

public Action __csutils__DelayThrowGrenade(Handle timer, DataPack data) {
  data.Reset();
  int client = GetClientFromSerial(data.ReadCell());
  GrenadeType type = view_as<GrenadeType>(data.ReadCell());
  float origin[3];
  float velocity[3];
  origin[0] = data.ReadFloat();
  origin[1] = data.ReadFloat();
  origin[2] = data.ReadFloat();
  velocity[0] = data.ReadFloat();
  velocity[1] = data.ReadFloat();
  velocity[2] = data.ReadFloat();
  delete data;
  CSU_ThrowGrenade(client, type, origin, velocity);
  return Plugin_Handled;
}

public SharedPlugin __pl_csutils = {
    name = "csutils", file = "csutils.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_csutils_SetNTVOptional() {
  MarkNativeAsOptional("CSU_ThrowGrenade");
}
#endif
