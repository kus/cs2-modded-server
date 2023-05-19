#include <sourcemod>
#include <sdktools>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "CSGOFixes",
	author = "Vauff + xen",
	description = "Various fixes for CS:GO",
	version = "2.0",
	url = "https://github.com/Vauff/CSGOFixes"
};

#define FSOLID_TRIGGER 0x0008

DynamicDetour g_hInputTestActivator, g_hDeactivate, g_hPhysicsTouchTriggers, g_hUpdateOnRemove, g_hPhysFrictionEffect;
DynamicHook g_hExplode;
Handle g_hGameStringPool_Remove;

char g_sPatchNames[][] = {"ThinkAddFlag", "InputSpeedModFlashlight"};

Address g_aPatchedAddresses[sizeof(g_sPatchNames)];
int g_iPatchedByteCount[sizeof(g_sPatchNames)];
int g_iPatchedBytes[sizeof(g_sPatchNames)][128]; // Increase this if a PatchBytes value in gamedata exceeds 128
int g_iSolidFlags;
int g_iRecentFrictionParticles;

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
		SetFailState("This plugin only runs on CS:GO!");

	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "gamedata/csgofixes.games.txt");

	if (!FileExists(path))
		SetFailState("Can't find csgofixes.games.txt gamedata.");

	GameData gameData = LoadGameConfigFile("csgofixes.games");
	
	if (gameData == INVALID_HANDLE)
		SetFailState("Can't find csgofixes.games.txt gamedata.");

	ApplyPatches(gameData);

	SetupDetour(gameData, g_hInputTestActivator, "CBaseFilter::InputTestActivator", Detour_InputTestActivator, Hook_Pre);
	SetupDetour(gameData, g_hDeactivate, "CGameUI::Deactivate", Detour_Deactivate, Hook_Pre);
	SetupDetour(gameData, g_hPhysicsTouchTriggers, "CBaseEntity::PhysicsTouchTriggers", Detour_PhysicsTouchTriggers, Hook_Pre);
	SetupDetour(gameData, g_hUpdateOnRemove, "CBaseEntity::UpdateOnRemove", Detour_UpdateOnRemove, Hook_Pre);
	SetupDetour(gameData, g_hPhysFrictionEffect, "PhysFrictionEffect", Detour_PhysFrictionEffect, Hook_Pre);

	g_hExplode = DynamicHook.FromConf(gameData, "CBaseGrenade::Explode");
	if (!g_hExplode)
		LogError("Failed to setup hook for CBaseGrenade::Explode");

	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(gameData, SDKConf_Signature, "CGameStringPool::Remove"))
	{
		LogError("Failed to get CGameStringPool::Remove");
		delete gameData;
		return;
	}

	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	g_hGameStringPool_Remove = EndPrepSDKCall();
	if (!g_hGameStringPool_Remove)
		LogError("Unable to prepare SDKCall for CGameStringPool::Remove");

	delete gameData;
}

public void OnMapStart()
{
	g_iSolidFlags = FindDataMapInfo(0, "m_usSolidFlags");
	g_iRecentFrictionParticles = 0;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	// Hook all grenade projectiles that implement CBaseGrenade::Explode
	if (StrEqual(classname, "hegrenade_projectile") || StrEqual(classname, "breachcharge_projectile") || StrEqual(classname, "bumpmine_projectile"))
		g_hExplode.HookEntity(Hook_Pre, entity, Hook_Explode);
}

MRESReturn Hook_Explode(int pThis, DHookParam hParams)
{
	int thrower = GetEntPropEnt(pThis, Prop_Send, "m_hThrower");

	// If null thrower (disconnected before explosion), block possible server crash from certain damage filters
	if (thrower == -1)
	{
		RemoveEntity(pThis);
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

MRESReturn Detour_InputTestActivator(DHookParam hParams)
{
	int pActivator = hParams.GetObjectVar(1, 0, ObjectValueType_CBaseEntityPtr);

	// If null activator, block the real function from executing and crashing the server
	if (pActivator == -1)
		return MRES_Supercede;

	return MRES_Ignored;
}

MRESReturn Detour_Deactivate(Address pThis, DHookParam hParams)
{
	Address pActivator = hParams.Get(1);

	// If null activator, fake activator as !self to prevent a possible server crash
	if (pActivator == Address_Null)
	{
		hParams.Set(1, pThis);
		return MRES_ChangedHandled;
	}

	return MRES_Ignored;
}

MRESReturn Detour_PhysicsTouchTriggers(int iEntity)
{
	// This function does two things as far as triggers are concerned, invalidate its touchstamp and calls SV_TriggerMoved.
	// SV_TriggerMoved is what checks if the moving trigger (hence the name) is touching anything.
	// But valve for whatever reason ifdef'd out a crucial function that actually performs the ray checks on dedicated servers.
	// As a result, the touchlink never gets updated on the trigger's side, which ends up deleting the touchlink.
	// And so, the player touches the trigger on the very next tick through SV_SolidMoved (which functions properly), and the cycle repeats...
	if (!IsValidEntity(iEntity))
		return MRES_Ignored;

	if (GetEntData(iEntity, g_iSolidFlags) & FSOLID_TRIGGER)
		return MRES_Supercede;

	return MRES_Ignored;
}

MRESReturn Detour_UpdateOnRemove(int iEntity)
{
	// This function deletes both the entity's targetname and script handle from the game stringtable, but only if it was part of a template with name fixup.
	// The intention was to prevent stringtable leaks from fixed up entity names since they're unique, but script handles are always unique regardless.
	// So there's really no reason not to unconditionally delete script handles when they're no longer needed.
	if (!IsValidEntity(iEntity) || (1 <= iEntity <= MaxClients))
		return MRES_Ignored;

	char szScriptId[64];

	if (GetEntPropString(iEntity, Prop_Data, "m_iszScriptId", szScriptId, sizeof(szScriptId)))
		SDKCall(g_hGameStringPool_Remove, szScriptId);

	return MRES_Handled;
}

MRESReturn Detour_PhysFrictionEffect()
{
	// Rate limit the particles PhysFrictionEffect creates, because server chat/command processing can fall very far behind when this function is spammed
	if (g_iRecentFrictionParticles > 10)
		return MRES_Supercede;

	g_iRecentFrictionParticles++;
	CreateTimer(0.1, Timer_DecrementFrictionParticles);

	return MRES_Handled;
}

Action Timer_DecrementFrictionParticles(Handle timer)
{
	if (g_iRecentFrictionParticles > 0)
		g_iRecentFrictionParticles--;

	return Plugin_Stop;
}

void SetupDetour(GameData gameData, DynamicDetour detour, char[] name, DHookCallback callback, HookMode mode)
{
	detour = DynamicDetour.FromConf(gameData, name);

	if (!detour)
	{
		LogError("Failed to setup detour for %s", name);
		return;
	}

	if (!detour.Enable(mode, callback))
		LogError("Failed to detour %s", name);
}

void ApplyPatches(GameData gameData)
{
	// Iterate our patch names (these are dependent on what's in gamedata)
	for (int i = 0; i < sizeof(g_sPatchNames); i++)
	{
		char patchName[64];
		Format(patchName, sizeof(patchName), g_sPatchNames[i]);

		// Get the location of this patches signature
		Address addr = gameData.GetMemSig(patchName);

		if (addr == Address_Null)
		{
			LogError("%s patch failed: Can't find %s address in gamedata.", patchName, patchName);
			continue;
		}

		char cappingOffsetName[64];
		Format(cappingOffsetName, sizeof(cappingOffsetName), "CappingOffset_%s", patchName);

		// Get how many bytes we should move forward from the signature location before starting patching
		int cappingOffset = gameData.GetOffset(cappingOffsetName);

		if (cappingOffset == -1)
		{
			LogError("%s patch failed: Can't find %s offset in gamedata.", patchName, cappingOffsetName);
			continue;
		}

		// Get patch location
		addr += view_as<Address>(cappingOffset);

		char patchBytesName[64];
		Format(patchBytesName, sizeof(patchBytesName), "PatchBytes_%s", patchName);

		// Find how many bytes after the patch location should be NOP'd
		int patchBytes = gameData.GetOffset(patchBytesName);

		if (patchBytes == -1)
		{
			LogError("%s patch failed: Can't find %s offset in gamedata.", patchName, patchBytesName);
			continue;
		}

		// Store this patches address and byte count as it's being applied for unpatching on plugin unload
		g_aPatchedAddresses[i] = addr;
		g_iPatchedByteCount[i] = patchBytes;

		// Iterate each byte we need to patch
		for (int j = 0; j < patchBytes; j++)
		{
			// Store the original byte here for unpatching on plugin unload
			g_iPatchedBytes[i][j] = LoadFromAddress(addr, NumberType_Int8);

			// NOP this byte
			StoreToAddress(addr, 0x90, NumberType_Int8);

			// Move on to next byte
			addr++;
		}
	}
}

public void OnPluginEnd()
{
	// Iterate our currently applied patches and get their location
	for (int i = 0; i < sizeof(g_aPatchedAddresses); i++)
	{
		Address addr = g_aPatchedAddresses[i];

		// Iterate the original bytes in that location and restore them (undo the NOP)
		for (int j = 0; j < g_iPatchedByteCount[i]; j++)
		{
			StoreToAddress(addr, g_iPatchedBytes[i][j], NumberType_Int8);
			addr++;
		}
	}
}