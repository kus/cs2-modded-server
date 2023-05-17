/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  infect.api.inc
 *  Type:		  Core
 *  Description:   Native handlers for the ZR API. (Infect module)
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
Handle g_hAPIFwdOnClientInfect = INVALID_HANDLE;
Handle g_hAPIFwdOnClientInfected = INVALID_HANDLE;
Handle g_hAPIFwdOnClientHuman = INVALID_HANDLE;
Handle g_hAPIFwdOnClientHumanPost = INVALID_HANDLE;
/**
 * @endsection
 */

/**
 * Initializes all natives and forwards related to infection.
 */
void APIInfectInit()
{
	// Infect module natives/forwards (infect.zr.inc)
	
	// Natives
	CreateNative("ZR_IsClientZombie", APIIsClientZombie);
	CreateNative("ZR_IsClientHuman", APIIsClientHuman);
	CreateNative("ZR_InfectClient", APIInfectClient);
	CreateNative("ZR_HumanClient", APIHumanClient);
	
	// Forwards
	g_hAPIFwdOnClientInfect = CreateGlobalForward("ZR_OnClientInfect", ET_Hook, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_hAPIFwdOnClientInfected = CreateGlobalForward("ZR_OnClientInfected", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_hAPIFwdOnClientHuman = CreateGlobalForward("ZR_OnClientHuman", ET_Hook, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_hAPIFwdOnClientHumanPost = CreateGlobalForward("ZR_OnClientHumanPost", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
}

/**
 * Native call function (ZR_IsClientInfected)
 * Returns true if the client is a zombie, false if not.
 */
public int APIIsClientZombie(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	// Validate the client index.
	APIValidateClientIndex(client, Condition_True);
	
	return InfectIsClientInfected(client);
}

/**
 * Native call function (ZR_IsClientHuman)
 * Returns true if the client is a human, false if not.
 * 
 * bool:InfectIsClientHuman(client)
 */
public int APIIsClientHuman(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	// Validate the client index.
	APIValidateClientIndex(client, Condition_True);
	
	return InfectIsClientHuman(client);
}

/**
 * Native call function (ZR_InfectClient)
 * Infects a client.
 * 
 * native ZR_InfectClient(client, attacker = -1, bool:motherInfect = false, bool:respawnOverride = false, bool:respawn = false);
 */
public int APIInfectClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int attacker = GetNativeCell(2);
	bool motherInfect = view_as<bool>(GetNativeCell(3));
	bool respawnOverride = view_as<bool>(GetNativeCell(4));
	bool respawn = view_as<bool>(GetNativeCell(5));
	
	// Validate the client index.
	APIValidateClientIndex(client, Condition_True);
	
	InfectHumanToZombie(client, attacker, motherInfect, respawnOverride, respawn);
}

/**
 * Native call function (ZR_HumanClient)
 * Turns a zombie back into a human.
 * 
 * native ZR_HumanClient(client, bool:respawn = false, bool:protect = false);
 */
public int APIHumanClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool respawn = view_as<bool>(GetNativeCell(2));
	bool protect = view_as<bool>(GetNativeCell(2));
	
	// Validate the client index.
	APIValidateClientIndex(client, Condition_True);
	
	InfectZombieToHuman(client, respawn, protect);
}

/**
 * Called when a client is about to become a zombie.
 * 
 * @param client			The client to infect.
 * @param attacker		  The attacker who did the infect.
 * @param motherinfect	  Indicates a mother zombie infect.
 * @param respawnoverride   Set to true to override respawn cvar.
 * @param respawn		   Value to override with.
 * 
 * InfectHumanToZombie(client, attacker = -1, bool:motherinfect = false, bool:respawnoverride = false, bool:respawn = false)
 */
Action APIOnClientInfect(int &client, int &attacker, bool &motherinfect, bool &respawnoverride, bool &respawn)
{
	// Start forward call.
	Call_StartForward(g_hAPIFwdOnClientInfect);
	
	// Push the parameters.
	Call_PushCellRef(client);
	Call_PushCellRef(attacker);
	Call_PushCellRef(motherinfect);
	Call_PushCellRef(respawnoverride);
	Call_PushCellRef(respawn);
	
	// Get what they returned.
	Action result;
	Call_Finish(result);
	return result;
}

/**
 * Called after a client has become a zombie.
 * 
 * @param client			The client to infect.
 * @param attacker		  The attacker who did the infect.
 * @param motherinfect	  Indicates a mother zombie infect.
 * @param respawnoverride   Set to true to override respawn cvar.
 * @param respawn		   Value to override with.
 * 
 * InfectHumanToZombie(client, attacker = -1, bool:motherinfect = false, bool:respawnoverride = false, bool:respawn = false)
 */
void APIOnClientInfected(int client, int attacker, bool motherinfect, bool respawnoverride, bool respawn)
{
	// Start forward call.
	Call_StartForward(g_hAPIFwdOnClientInfected);
	
	// Push the parameters.
	Call_PushCell(client);
	Call_PushCell(attacker);
	Call_PushCell(motherinfect);
	Call_PushCell(respawnoverride);
	Call_PushCell(respawn);
	
	// Finish the call.
	Call_Finish();
}

/**
 * Called when a client is about to become a human. (Through either zr_human or admin menu)
 * 
 * @param client			The client index.
 * @param respawn		   True if the client was respawned, false if not.
 * @param protect		   True if the client spawn protected, false if not.
 * 
 * InfectZombieToHuman(client, bool:respawn = false, bool:protect = false)
 */
Action APIOnClientHuman(int &client, bool &respawn, bool &protect)
{
	// Start forward call.
	Call_StartForward(g_hAPIFwdOnClientHuman);
	
	// Push the parameters.
	Call_PushCellRef(client);
	Call_PushCellRef(respawn);
	Call_PushCellRef(protect);
	
	// Get what they returned.
	Action result;
	Call_Finish(result);
	return result;
}

/**
 * Called after a client has become a human. (Through either zr_human or admin menu)
 * 
 * @param client			The client index.
 * @param respawn		   True if the client was respawned, false if not.
 * @param protect		   True if the client spawn protected, false if not.
 *  
 * InfectZombieToHuman(client, bool:respawn = false, bool:protect = false)
 */
void APIOnClientHumanPost(int client, bool respawn, bool protect)
{
	// Start forward call.
	Call_StartForward(g_hAPIFwdOnClientHumanPost);
	
	// Push the parameters.
	Call_PushCell(client);
	Call_PushCell(respawn);
	Call_PushCell(protect);
	
	// Finish the call.
	Call_Finish();
}
