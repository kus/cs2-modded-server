#pragma semicolon 1

#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

Address g_iPatchAddress;
int     g_iPatchRestore[100];
int     g_iPatchRestoreBytes;

bool g_bUnlockMovement = true;
char g_szMapName[128];
char g_szMapPrefix[2][32];

#define PLUGIN_VERSION "1.0b"

public Plugin myinfo =
{
	name        = "CS:GO Movement Unlocker",
	author      = "Peace-Maker, St00ne",
	description = "Removes max speed limitation from players on the ground. Feels like CS:S.",
	version     = PLUGIN_VERSION,
	url         = "http://www.wcfan.de/"


}

public void
	OnPluginStart()
{
	// RegConsoleCmd("sm_movementunlocker", Command_MovementUnlocker);

	// Load the gamedata file.
	Handle hGameConf = LoadGameConfigFile("csgo_movement_unlocker.games");
	if (hGameConf == null)
		SetFailState("Can't find csgo_movement_unlocker.games.txt gamedata.");

	// Get the address near our patch area inside CGameMovement::WalkMove
	Address iAddr = GameConfGetAddress(hGameConf, "WalkMoveMaxSpeed");
	if (iAddr == Address_Null)
	{
		CloseHandle(hGameConf);
		SetFailState("Can't find WalkMoveMaxSpeed address.");
	}

	// Get the offset from the start of the signature to the start of our patch area.
	int iCapOffset = GameConfGetOffset(hGameConf, "CappingOffset");
	if (iCapOffset == -1)
	{
		CloseHandle(hGameConf);
		SetFailState("Can't find CappingOffset in gamedata.");
	}

	// Move right in front of the instructions we want to NOP.
	iAddr += view_as<Address>(iCapOffset);
	g_iPatchAddress = iAddr;

	// Get how many bytes we want to NOP.
	g_iPatchRestoreBytes = GameConfGetOffset(hGameConf, "PatchBytes");

	delete hGameConf;

	if (g_iPatchRestoreBytes == -1)
	{
		delete hGameConf;
		SetFailState("Can't find PatchBytes in gamedata.");
	}

	// PrintToServer("CGameMovement::WalkMove VectorScale(wishvel, mv->m_flMaxSpeed/wishspeed, wishvel); ... at address %x", g_iPatchAddress);

	for (int i = 0; i < g_iPatchRestoreBytes; i++)
	{
		// Save the current instructions, so we can restore them on unload.
		g_iPatchRestore[i] = LoadFromAddress(iAddr, NumberType_Int8);

		// NOP
		StoreToAddress(iAddr, 0x90, NumberType_Int8);

		iAddr++;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnPluginEnd()
{
	// Restore the original instructions, if we patched them.
	UnpatchGame();
}

public void OnMapStart()
{
	// Get mapname
	GetCurrentMap(g_szMapName, 128);

	// get map tag
	ExplodeString(g_szMapName, "_", g_szMapPrefix, 2, 32);

	// Workshop fix
	char mapPieces[6][128];
	int  lastPiece = ExplodeString(g_szMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(g_szMapName, sizeof(g_szMapName), "%s", mapPieces[lastPiece - 1]);

	// de_ maps spawn fix
	if ((StrContains(g_szMapName, "surf_", false) != -1) || (StrContains(g_szMapName, "bhop_", false) != -1) || (StrContains(g_szMapName, "xc_", false) != -1) || (StrContains(g_szMapName, "kz_", false) != -1) || (StrContains(g_szMapName, "bkz_", false) != -1))
	{
		g_bUnlockMovement = true;
	}
	else
		g_bUnlockMovement = false;
}

public void OnClientPutInServer(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}

	SDKHook(client, SDKHook_PreThinkPost, Hook_PreThinkPost);
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
}

public void Hook_PreThinkPost(int client)
{
	if (!g_bUnlockMovement)
	{
		UnpatchGame();
	}
}

public void Hook_PostThinkPost(int client)
{
	if (!g_bUnlockMovement)
	{
		RepatchGame();
	}
}

void RepatchGame()
{
	if (g_iPatchAddress != Address_Null)
	{
		for (int i = 0; i < g_iPatchRestoreBytes; i++)
		{
			StoreToAddress(g_iPatchAddress + view_as<Address>(i), 0x90, NumberType_Int8);
		}
	}
}

void UnpatchGame()
{
	if (g_iPatchAddress != Address_Null)
	{
		for (int i = 0; i < g_iPatchRestoreBytes; i++)
		{
			StoreToAddress(g_iPatchAddress + view_as<Address>(i), g_iPatchRestore[i], NumberType_Int8);
		}
	}
}