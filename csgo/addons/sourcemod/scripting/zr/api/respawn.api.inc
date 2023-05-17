/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  respawn.api.inc
 *  Type:		  Core
 *  Description:   Native handlers for the ZR API. (Respawn module)
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

/**
 * @section Global forward handles.
 */
Handle g_hAPIFwdOnClientRespawn = INVALID_HANDLE;
Handle g_hAPIFwdOnClientRespawned = INVALID_HANDLE;
/**
 * @endsection
 */

/**
 * Initializes all natives and forwards related to respawn.
 */
void APIRespawnInit()
{
	// Respawn module natives/forwards (respawn.zr.inc)
	
	// Natives
	CreateNative("ZR_RespawnClient", APIRespawnClient);
	CreateNative("ZR_SetKilledByWorld", APISetKilledByWorld);
	CreateNative("ZR_GetKilledByWorld", APIGetKilledByWorld);
	
	// Forwards
	g_hAPIFwdOnClientRespawn = CreateGlobalForward("ZR_OnClientRespawn", ET_Hook, Param_CellByRef, Param_CellByRef);
	g_hAPIFwdOnClientRespawned = CreateGlobalForward("ZR_OnClientRespawned", ET_Ignore, Param_Cell, Param_Cell);
}

/**
 * Native call function (ZR_RespawnClient)
 * Spawns a player into the round following rules set by cvars.
 * 
 * RespawnSpawnClient(client, bool:zombie = false, bool:zombie_if_suicide = false)
 */
public int APIRespawnClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	// Validate index and that player isn't alive.
	APIValidateClientIndex(client, Condition_False);
	
	// Restore respawn condition.
	RespawnCondition condition = view_as<RespawnCondition>(GetNativeCell(2));
	bool zombie;
	bool zombieIfSuicide;
	RespawnRestoreCondition(condition, zombie, zombieIfSuicide);
	
	// Respawn the client.
	RespawnSpawnClient(client, zombie, zombieIfSuicide);
}

/**
 * Called right before ZR is about to respawn a player.
 * 
 * @param client			The client index.
 * @param condition		 Respawn condition. See RespawnCondition for
 *						  details.
 */
Action APIOnClientRespawn(int &client, RespawnCondition &condition)
{
	// Start forward call.
	Call_StartForward(g_hAPIFwdOnClientRespawn);
	
	// Push the parameters.
	Call_PushCellRef(client);
	Call_PushCellRef(condition);
	
	// Get what they returned.
	Action result;
	Call_Finish(result);
	return result;
}

/**
 * Called after a player was respawned.
 * 
 * @param client			The client index.
 * @param condition		 Current condition of the respawned player. See
 *						  RespawnCondition for details.
 */
Action APIOnClientRespawned(int client, RespawnCondition condition)
{
	// Start forward call.
	Call_StartForward(g_hAPIFwdOnClientRespawned);
	
	// Push the parameters.
	Call_PushCell(client);
	Call_PushCell(condition);
	
	// Finish the call.
	Call_Finish();
}

/**
 * Native call function (ZR_SetKilledByWorld)
 * Override if the client died by a suicide.
 */
public int APISetKilledByWorld(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	// Validate the client index.
	APIValidateClientIndex(client, Condition_Either);
	
	bool suicide = view_as<bool>(GetNativeCell(2));
	
	// Override the old value.
	bKilledByWorld[client] = suicide;
}

/**
 * Native call function (ZR_GetKilledByWorld)
 * Read the value of if the client died by a suicide.
 */
public int APIGetKilledByWorld(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	// Validate the client index.
	APIValidateClientIndex(client, Condition_Either);
	
	// Return the value.
	return view_as<int>(bKilledByWorld[client]);
}
