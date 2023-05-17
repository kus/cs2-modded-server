/*
 * SourceMod Hosties Project
 * by: databomb & dataviruset
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Double include protection
#if defined _LastRequest_Included_
	#endinput
#endif
#define _LastRequest_Included_

// Custom types
enum LastRequest
{
	LR_KnifeFight = 0,
	LR_Shot4Shot,
	LR_GunToss,
	LR_ChickenFight,
	LR_HotPotato,
	LR_Dodgeball,
	LR_NoScope,
	LR_RockPaperScissors,
	LR_Rebel,
	LR_Mag4Mag,
	LR_Race,
	LR_RussianRoulette,
	LR_JumpContest
};

enum PartnersArray
{
	Block_LRType = 0,
	Block_Prisoner,
	Block_Guard,
	Block_PrisonerData,
	Block_GuardData,
	Block_Global1,
	Block_Global2,
	Block_Global3,
	Block_Global4,
	Block_DataPackHandle
};

enum DataType
{
	Type_Int = 0,
	Type_Float,
	Type_Handle,
	Type_LastRequest,
	Type_PartnerArray
};

enum LR_Structure
{
	DataType:LR_Type,
	DataType:Prisoner_Index,
	DataType:Guard_Index,
	DataType:Prisoner_Data,
	DataType:Guard_Data,
	DataType:Global1,
	DataType:Global2,
	DataType:Global3,
	DataType:Global4,
	DataType:TheDataPack
};

public SharedPlugin:__pl_lastrequest =
{
	name = "lastrequest",
	file = "sm_hosties.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public __pl_lastrequest_SetNTVOptional()
{
	MarkNativeAsOptional("IsClientRebel");
	MarkNativeAsOptional("IsClientInLastRequest");
	MarkNativeAsOptional("AddLastRequestToList");
	MarkNativeAsOptional("RemoveLastRequestFromList");
	MarkNativeAsOptional("ProcessAllLastRequests");
	MarkNativeAsOptional("ChangeRebelStatus");
	MarkNativeAsOptional("InitializeLR");
	MarkNativeAsOptional("CleanupLR");
}

functag FuncLastRequest public(type, prisoner, guard);
functag FuncProcessLR public(Handle:array, iLRNumber);


forward OnStartLR(PrisonerIndex, GuardIndex, LR_Type);

forward OnAvailableLR(Announced);

/**
 * Find if a client is listed as a rebel.
 * 
 * @param client				Client index.
 * @return						True if rebel, false otherwise.
 * @error                       Invalid client index.
 */
native bool:IsClientRebel(client);

/**
 * Find if a client is in a last request.
 * 
 * @param client				Client index.
 * @return						False if not in LR
 *									Otherwise client index of partner or -1 if in LR but no partner exists
 * @error                       Invalid client index.
 */
native IsClientInLastRequest(client);

/**
 * Adds a custom last request.
 * 
 * @param Start					Function call to when the LR is started.
 * @param Stop					Function call to when the LR is ended.
 * @param LR_Name				The name for the LR that will appear on the menu.
 * @param AutoStart				Whether the LR will start immediately (true) or if additional menus are needed (false).
 * @return						The type index of the LR added.
 */
native AddLastRequestToList(FuncProcessLR:Start, FuncLastRequest:Stop, String:LR_Name[], bool:AutoStart = true);

/**
 * Removes a custom last request.
 * 
 * @param Start					Function call to when the LR is started.
 * @param Stop					Function call to when the LR is ended.
 * @param LR_Name				Name of the LR that appeared on the menu.
 * @noreturn						
 * @error                     	Last request not found.
 */
native void RemoveLastRequestFromList(FuncProcessLR:Start, FuncLastRequest:Stop, String:LR_Name[]);

/**
 * Provides iteration for all active last requests.
 * 
 * @param ProcessLR				Function call to process each last request.
 * @param iLastRequestIndex		Index number of last request in array.
 * @return						Number of last requests in progress.
 */
native ProcessAllLastRequests(FuncProcessLR:ProcessLR, iLastRequestIndex);

/**
 * Alters the boolean array determining if a given client is considered a rebel.
 *
 * @param client				Client Index
 * @param status				Boolean Rebel Status (true = rebel)
 * @noreturn
 * @error						Invalid parameters
 */
native ChangeRebelStatus(client, status);

/**
 * Starts the lr if autostart is false.
 *
 * @param prisoner				Prisoner Index
 * @noreturn
 * @error						Invalid parameters or wrong client index
 */
native InitializeLR(prisoner);

/**
 * Cleanup the data about the autostart LR for a client.
 * (All the data stored by using the Prisoner's client index)
 *
 * @param prisoner				Prisoner Index
 * @noreturn
 * @error						Invalid parameters or wrong client index
 */
native CleanupLR(prisoner);

stock SetThirdPerson(client)
{
	if (IsValidEntity(client) && IsClientInGame(client))
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(client, Prop_Send, "m_iFOV", 120);
	}
}

stock SetFirstPerson(client)
{
	if (IsValidEntity(client) && IsClientInGame(client))
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 1);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
	}
}

stock CancelAllMenus()
{
	for (new idx = 1; idx < MaxClients; idx++)
	{
		if (IsClientInGame(idx))
		{
			if (GetClientMenu(idx))
			{
				CancelClientMenu(idx);
			}
		}
	}
}

stock ClosePotentialLRMenus()
{
   for (new idx = 1; idx < MaxClients; idx++)
   {
      if (IsClientInGame(idx))
      {
			if (GetClientTeam(idx) == CS_TEAM_T)
			{
				if (GetClientMenu(idx))
				{
					CancelClientMenu(idx);
				}
			}
      }
   }
}

stock bool:PlayerHasGun(client)
{
	if (PlayerHasPrimary(client) || PlayerHasSecondary(client))
	{
		return true;
	}
	return false;
}

stock bool:PlayerHasPrimary(client)
{
	if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
	{
		return true;
	}
	return false;
}

stock bool:PlayerHasSecondary(client)
{
	if (GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
	{
		return true;
	}
	return false;
}

// filter function to ignore everything
public bool:Trace_FilterNothing(entity, contentsMask)
{
	return entity == 0;
}

// Based on Client_IsLookingAtWall, Edict_GetClosestToEdict from SM-LIB with permission from Berni
// detects if it's safe to teleport a player where the player is aiming
stock bool:IsClientTooNearObstacle(client, Float:distance = 110.0, bool:checkAllEntities = false)
{
	decl Float:posEye[3], Float:posEyeAngles[3], Float:vecOrigin[3], Float:vecOrigin_edict[3], String:Class_edict[64];
	new bool:isClientLookingAtWall = false;
	new bool:isClientCloseToEdict = false;
	
	GetClientAbsOrigin(client, vecOrigin);
	
	if (checkAllEntities)
	{
		for (new edict=1; edict <= GetMaxEntities(); edict++)
		{
			
			if (!IsValidEntity(edict))
			{
				continue;
			}
			
			GetEdictClassname(edict, Class_edict, sizeof(Class_edict));
			
			if (StrContains(Class_edict, "player") != -1)
			{
				continue;
			}
			
			if (StrContains(Class_edict, "weapon") != -1)
			{
				continue;
			}
				
			if (GetEntSendPropOffs(edict, "m_vecOrigin") == -1)
			{
				continue;
			}
			
			GetEntPropVector(edict, Prop_Data, "m_vecOrigin", vecOrigin_edict);
			
			new Float:edict_distance = GetVectorDistance(vecOrigin, vecOrigin_edict);
			
			if (edict_distance <= distance)
			{
				isClientCloseToEdict = true;
			}
		}
	}
	
	GetClientEyePosition(client, posEye);
	GetClientEyeAngles(client,	posEyeAngles);
	
	posEyeAngles[0] = 0.0;
	
	new Handle:trace = TR_TraceRayFilterEx(posEye, posEyeAngles, CONTENTS_SOLID, RayType_Infinite, Trace_FilterNothing);
	
	if (TR_DidHit(trace))
	{
		decl Float:posEnd[3];

		TR_GetEndPosition(posEnd, trace);
		
		if (GetVectorDistance(posEye, posEnd) <= distance)
		{
			new Float:m_vHullMin[3] = {-16.0, -16.0, 0.0};
			new Float:m_vHullMax[3] = {16.0, 16.0, 72.0};
			new Handle:hullTrace = 	TR_TraceHullEx(posEye, posEnd, m_vHullMin, m_vHullMax, CONTENTS_SOLID);
			if (TR_DidHit(hullTrace))
			{
				TR_GetEndPosition(posEnd, hullTrace);
				if (GetVectorDistance(posEye, posEnd) <= distance)
				{
					isClientLookingAtWall = true;
				}
			}
			CloseHandle(hullTrace);
		}
	}
	
	CloseHandle(trace);	
	
	if (isClientCloseToEdict || isClientLookingAtWall)
	{
		return true;
	}
	return false;
}