void CreateForwards()
{
	g_OnFreezeTimeEnd = CreateGlobalForward("PH_OnFreezeTimeEnd", ET_Ignore);
	
	g_OnHiderSpawn = CreateGlobalForward("PH_OnHiderSpawn", ET_Ignore, Param_Cell);
	g_OnHiderReady = CreateGlobalForward("PH_OnHiderReady", ET_Ignore, Param_Cell);
	g_OnHiderSetModel = CreateGlobalForward("PH_OnHiderSetModel", ET_Ignore, Param_Cell);
	g_OnHiderDeath = CreateGlobalForward("PH_OnHiderDeath", ET_Ignore, Param_Cell, Param_Cell);
	
	g_OnSeekerSpawn = CreateGlobalForward("PH_OnSeekerSpawn", ET_Ignore, Param_Cell);
	g_OnSeekerDeath = CreateGlobalForward("PH_OnSeekerDeath", ET_Ignore, Param_Cell, Param_Cell);
	
	g_OnHiderFreeze = CreateGlobalForward("PH_OnHiderFreeze", ET_Event, Param_Cell);
	g_OnHiderUnFreeze = CreateGlobalForward("PH_OnHiderUnFreeze", ET_Ignore, Param_Cell);
	
	g_OnOpenTauntMenu = CreateGlobalForward("PH_OnOpenTauntMenu", ET_Event, Param_Cell);
	
	g_OnTauntPre = CreateGlobalForward("PH_OnTauntPre", ET_Event, Param_Cell, Param_FloatByRef);
	g_OnTaunt = CreateGlobalForward("PH_OnTaunt", ET_Ignore, Param_Cell, Param_Float);
	g_OnForceTauntPre = CreateGlobalForward("PH_OnForceTauntPre", ET_Event, Param_Cell, Param_Cell, Param_FloatByRef);
	g_OnForceTaunt = CreateGlobalForward("PH_OnForceTaunt", ET_Ignore, Param_Cell, Param_Cell, Param_Float);
	
	g_OnSeekerUseWeapon = CreateGlobalForward("PH_OnSeekerUseWeapon", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef);
	g_OnHiderHit = CreateGlobalForward("PH_OnHiderHit", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_FloatByRef, Param_CellByRef, Param_CellByRef);
	
	g_OnBuildModelMenu = CreateGlobalForward("PH_OnBuildModelMenu", ET_Ignore, Param_Cell, Param_CellByRef);
	
	g_OnBuyShopItem = CreateGlobalForward("PH_OnBuyShopItem", ET_Event, Param_Cell, Param_String, Param_CellByRef);
	g_OnBuyShopItemPost = CreateGlobalForward("PH_OnBuyShopItemPost", ET_Ignore, Param_Cell, Param_String, Param_Cell);
}

void CreateNatives()
{
	CreateNative("PH_IsFrozen", Native_IsFrozen);
	CreateNative("PH_CanChangeModel", Native_CanChangeModel);
	CreateNative("PH_GetModelChangeCount", Native_GetModelChangeCount);
	CreateNative("PH_DisableFakeProp", Native_DisableFakeProp);
	CreateNative("PH_IsFakePropBlocked", Native_IsFakePropBlocked);
	CreateNative("PH_GetFakeProp", Native_GetFakeProp);
	
	CreateNative("PH_GetModelPath", Native_GetModelPath);
	CreateNative("PH_GetModelName", Native_GetModelName);
	CreateNative("PH_GetModelOffset", Native_GetModelOffset);
	CreateNative("PH_GetModelAngles", Native_GetModelAngles);
	CreateNative("PH_GetModelColor", Native_GetModelColor);
	
	CreateNative("PH_GetModelSpeed", Native_GetModelSpeed);
	CreateNative("PH_GetModelGravity", Native_GetModelGravity);
	CreateNative("PH_GetModelSkin", Native_GetModelSkin);
	CreateNative("PH_GetModelHealth", Native_GetModelHealth);
	//CreateNative("PH_GetModelHealthMax", Native_GetModelHealthMax);
	
	CreateNative("PH_GetClientModelPath", Native_GetClientModelPath);
	CreateNative("PH_GetClientModelName", Native_GetClientModelName);
	CreateNative("PH_GetClientModelOffset", Native_GetClientModelOffset);
	CreateNative("PH_GetClientModelAngles", Native_GetClientModelAngles);
	CreateNative("PH_GetClientModelColor", Native_GetClientModelColor);
	
	CreateNative("PH_GetClientModelSpeed", Native_GetClientModelSpeed);
	CreateNative("PH_GetClientModelGravity", Native_GetClientModelGravity);
	CreateNative("PH_GetClientModelSkin", Native_GetClientModelSkin);
	CreateNative("PH_GetClientModelHealth", Native_GetClientModelHealth);
	//CreateNative("PH_GetClientModelHealthMax", Native_GetClientModelHealthMax);
	
	CreateNative("PH_GetClientFreezeAngles", Native_GetClientFreezeAngles);
	
	CreateNative("PH_ForceTaunt", Native_ForceTaunt);
	CreateNative("PH_GetTauntCooldown", Native_GetTauntCooldown);
	CreateNative("PH_GetTauntCooldownLength", Native_GetTauntCooldownLength);
	
	CreateNative("PH_GetPoints", Native_GetPoints);
	CreateNative("PH_SetPoints", Native_SetPoints);
	CreateNative("PH_GivePoints", Native_GivePoints);
	CreateNative("PH_TakePoints", Native_TakePoints);
	
	CreateNative("PH_RegisterShopItem", Native_RegisterShopItem);
	
	CreateNative("PH_DisableShopItem", Native_DisableShopItem);
	CreateNative("PH_DisableShopItemForAll", Native_DisableShopItemForAll);
	CreateNative("PH_EnableShopItem", Native_EnableShopItem);
	CreateNative("PH_EnableShopItemForAll", Native_EnableShopItemForAll);
}

public int Native_IsFrozen(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	
	int iTeam = GetClientTeam(iClient);
	
	if(iTeam == CS_TEAM_T)
		return Client_IsFreezed(iClient);
		
	if(iTeam == CS_TEAM_CT)
		return Seeker_IsBlinded(iClient);
	
	return false;
}

public int Native_CanChangeModel(Handle plugin, int numParams)
{
	return GetHideTimeLeft();
}

public int Native_GetModelChangeCount(Handle plugin, int numParams)
{
	return g_iModelChangeCount[GetNativeCell(1)];
}

public int Native_DisableFakeProp(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	
	g_bBlockFakeProp[iClient] = true;
	
	Client_SetFreezed(iClient, false);
	Client_RemoveFakeProp(iClient);
	SetEntityRenderMode(iClient, RENDER_TRANSCOLOR);
}

public int Native_IsFakePropBlocked(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	
	return g_bBlockFakeProp[iClient];
}

public int Native_GetFakeProp(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	
	return Client_GetFakeProp(iClient);
}

public int Native_GetClientModelPath(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	
	return SetNativeString(2, m_sModel[iClient], PLATFORM_MAX_PATH, true) != SP_ERROR_NONE;
}

public int Native_GetClientModelName(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	
	return SetNativeString(2, m_sName[iClient], 32, true) != SP_ERROR_NONE;
}

public int Native_GetClientModelOffset(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	SetNativeArray(2, m_fOffset[iClient], 3);
}

public int Native_GetClientModelAngles(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	SetNativeArray(2, m_fAngle[iClient], 3);
}

public int Native_GetClientModelColor(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	SetNativeArray(2, m_iColor[iClient], 4);
}

public int Native_GetClientModelSpeed(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	SetNativeCellRef(2, m_fSpeed[iClient]);
}

public int Native_GetClientModelGravity(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	SetNativeCellRef(2, m_fGravity[iClient]);
}

public int Native_GetClientModelSkin(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	return m_iSkin[iClient];
}

public int Native_GetClientModelHealth(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	return m_iHP[iClient];
}

/*

public int Native_GetClientModelHealthMax(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	return m_iHPMax[iClient];
}
*/

public int Native_GetClientFreezeAngles(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	SetNativeArray(2, m_fFreezeAngle[iClient], 3);
}

public int Native_GetModelName(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	
	char sName[32];
	KvGetString(g_kvModels, "name", sName, sizeof(sName), "*ERROR*");
	
	KvRewind(g_kvModels);
	
	return SetNativeString(2, sName, 32, true) != SP_ERROR_NONE;
}

public int Native_GetModelPath(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	
	char sPath[PLATFORM_MAX_PATH];
	KvGetSectionName(g_kvModels, sPath, sizeof(sPath));
	FormatEx(sPath, sizeof(sPath), "models/%s.mdl", sPath);
	
	KvRewind(g_kvModels);
	
	return SetNativeString(2, sPath, PLATFORM_MAX_PATH, true) != SP_ERROR_NONE;
}

public int Native_GetModelOffset(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	
	float offset[3];
	offset[0] = KvGetFloat(g_kvModels, "offset_x", 0.0);
	offset[1] = KvGetFloat(g_kvModels, "offset_y", 0.0);
	offset[2] = KvGetFloat(g_kvModels, "offset_z", 0.0);
	
	KvRewind(g_kvModels);
	
	SetNativeArray(2, offset, 3);
}

public int Native_GetModelAngles(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	
	float angle[3];
	angle[0] = KvGetFloat(g_kvModels, "rotation_x", 0.0);
	angle[1] = KvGetFloat(g_kvModels, "rotation_y", 0.0);
	angle[2] = KvGetFloat(g_kvModels, "rotation_z", 0.0);
	
	KvRewind(g_kvModels);
	
	SetNativeArray(2, angle, 3);
}

public int Native_GetModelColor(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	
	int color[4];
	KvGetColor(g_kvModels, "color", color[0], color[1], color[2], color[3]);
	if(color[0] == 0 && color[1] == 0 && color[2] == 0 && color[3] == 0)
	{
		color[0] = 255;
		color[1] = 255;
		color[2] = 255;
		color[3] = 255;
	}
	
	KvRewind(g_kvModels);
	
	SetNativeArray(2, color, 4);
}

public int Native_GetModelSpeed(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	float speed = KvGetFloat(g_kvModels, "speed", 1.0);
	KvRewind(g_kvModels);
	
	SetNativeCellRef(2, speed);
}

public int Native_GetModelGravity(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	float gravity = KvGetFloat(g_kvModels, "gravity", 1.0);
	KvRewind(g_kvModels);
	
	SetNativeCellRef(2, gravity);
}

public int Native_GetModelSkin(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	int skin = KvGetNum(g_kvModels, "skin", 0);
	KvRewind(g_kvModels);
	
	return skin;
}

public int Native_GetModelHealth(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	int hp = KvGetNum(g_kvModels, "hp", 100);
	KvRewind(g_kvModels);
	
	return hp;
}

/*
public int Native_GetModelHealthMax(Handle plugin, int numParams)
{
	int iIndex = GetNativeCell(1);
	
	KV_JumpTo(g_kvModels, iIndex);
	int maxhp = KvGetNum(g_kvModels, "hp_max", 250.0);
	KvRewind(g_kvModels);
	
	return maxhp;
}
*/

public int Native_ForceTaunt(Handle plugin, int numParams)
{
	return ForceTaunt(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetTauntCooldown(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	
	
	int iTime = GetTime();
	
	if (iTime > g_iTauntNextUse[iClient] + 1)
		return 0;
	
	return 1+ g_iTauntNextUse[iClient] - iTime;
}

public int Native_GetTauntCooldownLength(Handle plugin, int numParams)
{
	return g_iTauntCooldownLength[GetNativeCell(1)];
}

public int Native_GetPoints(Handle plugin, int numParams)
{
	return RoundToFloor(GetPoints(GetNativeCell(1)));
}

public int Native_SetPoints(Handle plugin, int numParams)
{
	return RoundToFloor(SetPoints(GetNativeCell(1), GetNativeCell(2)));
}

public int Native_GivePoints(Handle plugin, int numParams)
{
	return RoundToFloor(AddPoints(GetNativeCell(1), GetNativeCell(2)));
}

public int Native_TakePoints(Handle plugin, int numParams)
{
	return RoundToFloor(TakePoints(GetNativeCell(1), GetNativeCell(2)));
}

public int Native_RegisterShopItem(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(1, sName, sizeof(sName));
	return RegisterShopItem(sName, GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5), GetNativeCell(6));
}

public int Native_DisableShopItem(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(1, sName, sizeof(sName));
	
	if(g_aClientShopItemDisabled[GetNativeCell(2)].FindString(sName) == -1)
		g_aClientShopItemDisabled[GetNativeCell(2)].PushString(sName);
}

public int Native_DisableShopItemForAll(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(1, sName, sizeof(sName));
	
	if(g_aShopItemDisabled.FindString(sName) == -1)
		g_aShopItemDisabled.PushString(sName);
}

public int Native_EnableShopItem(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(1, sName, sizeof(sName));
	
	int iClient = GetNativeCell(2);
	int iIndex = g_aClientShopItemDisabled[iClient].FindString(sName);
	
	if(iIndex != -1)
		g_aClientShopItemDisabled[iClient].Erase(iIndex);
}

public int Native_EnableShopItemForAll(Handle plugin, int numParams)
{
	char sName[32];
	GetNativeString(1, sName, sizeof(sName));
	
	int iIndex = g_aShopItemDisabled.FindString(sName);
	
	if(iIndex != -1)
		g_aShopItemDisabled.Erase(iIndex);
}