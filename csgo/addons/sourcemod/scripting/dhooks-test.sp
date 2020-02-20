#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <dhooks>

// int CBaseCombatCharacter::BloodColor(void)
new Handle:hBloodColor;

// bool CBaseCombatCharacter::Weapon_CanUse(CBaseCombatWeapon *)
new Handle:hHookCanUse;

// Vector CBasePlayer::GetPlayerMaxs()
new Handle:hGetMaxs;

// string_t CBaseEntity::GetModelName(void)
new Handle:hGetModelName;

// bool CGameRules::CanHaveAmmo(CBaseCombatCharacter *, int)
new Handle:hCanHaveAmmo;

// void CBaseEntity::SetModel(char  const*)
new Handle:hSetModel;

//float CCSPlayer::GetPlayerMaxSpeed()
new Handle:hGetSpeed;

//int CCSPlayer::OnTakeDamage(CTakeDamageInfo const&)
new Handle:hTakeDamage;

// bool CBaseEntity::AcceptInput(char  const*, CBaseEntity*, CBaseEntity*, variant_t, int)
new Handle:hAcceptInput;

//int CBaseCombatCharacter::GiveAmmo(int, int, bool)
new Handle:hGiveAmmo;

// CVEngineServer::ClientPrintf(edict_t *, char  const*)
new Handle:hClientPrintf;

public OnPluginStart()
{
	new Handle:temp = LoadGameConfigFile("dhooks-test.games");
	
	if(temp == INVALID_HANDLE)
	{
		SetFailState("Why you no has gamedata?");
	}
	
	new offset;
	
	offset = GameConfGetOffset(temp, "BloodColor");
	hBloodColor = DHookCreate(offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, BloodColorPost);
	
	offset = GameConfGetOffset(temp, "GetModelName");
	hGetModelName = DHookCreate(offset, HookType_Entity, ReturnType_String, ThisPointer_CBaseEntity, GetModelName);
	
	offset = GameConfGetOffset(temp, "GetMaxs");
	hGetMaxs = DHookCreate(offset, HookType_Entity, ReturnType_Vector, ThisPointer_Ignore);
	
	offset = GameConfGetOffset(temp, "CanUse");
	hHookCanUse = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, CanUsePost);
	DHookAddParam(hHookCanUse, HookParamType_CBaseEntity);
	
	offset = GameConfGetOffset(temp, "CanHaveAmmo");
	hCanHaveAmmo = DHookCreate(offset, HookType_GameRules, ReturnType_Bool, ThisPointer_Ignore, CanHaveAmmoPost);
	DHookAddParam(hCanHaveAmmo, HookParamType_CBaseEntity);
	DHookAddParam(hCanHaveAmmo, HookParamType_Int);
	
	offset = GameConfGetOffset(temp, "SetModel");
	hSetModel = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, SetModel);
	DHookAddParam(hSetModel, HookParamType_CharPtr);
	
	offset = GameConfGetOffset(temp, "AcceptInput");
	hAcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, AcceptInput);
	DHookAddParam(hAcceptInput, HookParamType_CharPtr);
	DHookAddParam(hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(hAcceptInput, HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP); //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(hAcceptInput, HookParamType_Int);
		
	offset = GameConfGetOffset(temp, "GetMaxPlayerSpeed");
	hGetSpeed = DHookCreate(offset, HookType_Entity, ReturnType_Float, ThisPointer_CBaseEntity);
		
	offset = GameConfGetOffset(temp, "GiveAmmo");
	hGiveAmmo = DHookCreate(offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, GiveAmmo);
	DHookAddParam(hGiveAmmo, HookParamType_Int);
	DHookAddParam(hGiveAmmo, HookParamType_Int);
	DHookAddParam(hGiveAmmo, HookParamType_Bool);
		
	offset = GameConfGetOffset(temp, "OnTakeDamage");
	hTakeDamage = DHookCreate(offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, OnTakeDamage);
	DHookAddParam(hTakeDamage, HookParamType_ObjectPtr, -1, DHookPass_ByRef);
	
	DHookAddEntityListener(ListenType_Created, EntityCreated);
	
	//Add client printf hook pThis requires effort
	StartPrepSDKCall(SDKCall_Static);
	if(!PrepSDKCall_SetFromConf(temp, SDKConf_Signature, "CreateInterface"))
	{
		SetFailState("Failed to get CreateInterface");
		CloseHandle(temp);
	}
	
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	
	new String:iface[64];
	if(!GameConfGetKeyValue(temp, "EngineInterface", iface, sizeof(iface)))
	{
		SetFailState("Failed to get engine interface name");
		CloseHandle(temp);
	}
	
	new Handle:call = EndPrepSDKCall();
	new Address:addr = SDKCall(call, iface, 0);
	CloseHandle(call);
	
	if(!addr)
	{
		SetFailState("Failed to get engine ptr");
	}
	
	offset = GameConfGetOffset(temp, "ClientPrintf");
	hClientPrintf = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Ignore, Hook_ClientPrintf);
	DHookAddParam(hClientPrintf, HookParamType_Edict);
	DHookAddParam(hClientPrintf, HookParamType_CharPtr);
	DHookRaw(hClientPrintf, false, addr);
	
	CloseHandle(temp);
	
}

public MRESReturn:Hook_ClientPrintf(Handle:hParams)
{
	new client = DHookGetParam(hParams, 1);
	decl String:buffer[1024];
	DHookGetParamString(hParams, 2, buffer, sizeof(buffer));
	PrintToChat(client, "BUFFER %s", buffer);
	return MRES_Ignored;
}

public MRESReturn:AcceptInput(pThis, Handle:hReturn, Handle:hParams)
{
	new String:command[128];
	DHookGetParamString(hParams, 1, command, sizeof(command));
	new type = DHookGetParamObjectPtrVar(hParams, 4, 16,ObjectValueType_Int);
	new String:wtf[128];
	DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, wtf, sizeof(wtf));
	PrintToServer("Command %s Type %i String %s", command, type, wtf);
	DHookSetReturn(hReturn, false);
	return MRES_Supercede;
}

public OnMapStart()
{
	//Hook Gamerules function in map start
	DHookGamerules(hCanHaveAmmo, true, RemovalCB);
}

public OnClientPutInServer(client)
{
	DHookEntity(hSetModel, false, client, RemovalCB);
	DHookEntity(hHookCanUse, true, client, RemovalCB);
	DHookEntity(hGetSpeed, true, client, RemovalCB, GetMaxPlayerSpeedPost);
	DHookEntity(hGiveAmmo, false, client);
	DHookEntity(hGetModelName, true, client);
	DHookEntity(hTakeDamage, false, client);
	DHookEntity(hGetMaxs, true, client, _ , GetMaxsPost);
	DHookEntity(hBloodColor, true, client);
}

public EntityCreated(entity, const String:classname[])
{
	if(strcmp(classname, "point_servercommand") == 0)
	{
		DHookEntity(hAcceptInput, false, entity);
	}
}

//int CCSPlayer::OnTakeDamage(CTakeDamageInfo const&)
public MRESReturn:OnTakeDamage(pThis, Handle:hReturn, Handle:hParams)
{
	PrintToServer("DHooksHacks = Victim %i, Attacker %i, Inflictor %i, Damage %f", pThis, DHookGetParamObjectPtrVar(hParams, 1, 40, ObjectValueType_Ehandle), DHookGetParamObjectPtrVar(hParams, 1, 36, ObjectValueType_Ehandle), DHookGetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float));
	
	if(pThis <= MaxClients && pThis > 0 && !IsFakeClient(pThis))
	{
		DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, 0.0);
		PrintToChat(pThis, "Pimping your hp");
	}
}

// int CBaseCombatCharacter::GiveAmmo(int, int, bool)
public MRESReturn:GiveAmmo(pThis, Handle:hReturn, Handle:hParams)
{
	PrintToChat(pThis, "Giving %i of %i supress %i", DHookGetParam(hParams, 1), DHookGetParam(hParams, 2), DHookGetParam(hParams, 3));
	return MRES_Ignored;
}

// void CBaseEntity::SetModel(char  const*)
public MRESReturn:SetModel(pThis, Handle:hParams)
{
	//Change all bot skins to phoenix one
	if(IsFakeClient(pThis))
	{
		DHookSetParamString(hParams, 1, "models/player/t_phoenix.mdl");
		return MRES_ChangedHandled;
	}
	return MRES_Ignored;
}

//float CCSPlayer::GetPlayerMaxSpeed()
public MRESReturn:GetMaxPlayerSpeedPost(pThis, Handle:hReturn)
{
	//Make bots slow
	if(IsFakeClient(pThis))
	{
		DHookSetReturn(hReturn, 100.0);
		return MRES_Override;
	}
	return MRES_Ignored;
}

// bool CGameRules::CanHaveAmmo(CBaseCombatCharacter *, int)
public MRESReturn:CanHaveAmmoPost(Handle:hReturn, Handle:hParams)
{
	PrintToServer("Can has ammo? %s %i", DHookGetReturn(hReturn)?"true":"false", DHookGetParam(hParams, 2));
	return MRES_Ignored;
}

// string_t CBaseEntity::GetModelName(void)
public MRESReturn:GetModelName(pThis, Handle:hReturn)
{
	new String:returnval[128];
	DHookGetReturnString(hReturn, returnval, sizeof(returnval));
	
	if(IsFakeClient(pThis))
	{
		PrintToServer("It is a bot, Model should be: models/player/t_phoenix.mdl It is %s", returnval);
	}
	
	return MRES_Ignored;
}

// Vector CBasePlayer::GetPlayerMaxs()
public MRESReturn:GetMaxsPost(Handle:hReturn)
{
	new Float:vec[3];
	DHookGetReturnVector(hReturn, vec);
	PrintToServer("Get maxes %.3f, %.3f, %.3f", vec[0], vec[1], vec[2]);
	
	return MRES_Ignored;
}

// bool CBaseCombatCharacter::Weapon_CanUse(CBaseCombatWeapon *)
public MRESReturn:CanUsePost(pThis, Handle:hReturn, Handle:hParams)
{
	//Bots get nothing.
	if(IsFakeClient(pThis))
	{
		DHookSetReturn(hReturn, false);
		return MRES_Override;
	}
	return MRES_Ignored;
}

// int CBaseCombatCharacter::BloodColor(void)
public MRESReturn:BloodColorPost(pThis, Handle:hReturn)
{
	//Change the bots blood color to goldish yellow
	if(IsFakeClient(pThis))
	{
		DHookSetReturn(hReturn, 2);
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public RemovalCB(hookid)
{
	PrintToServer("Removed hook %i", hookid);
}