/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  antistick.inc
 *  Type:		  Module
 *  Description:   Antistick system.
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
 * @section Collision values.
 */
#define COLLISION_GROUP_NONE				0   /** Default; collides with static and dynamic objects. */
#define COLLISION_GROUP_DEBRIS			  1   /** Collides with nothing but world and static stuff. */
#define COLLISION_GROUP_DEBRIS_TRIGGER	  2   /** Same as debris, but hits triggers. */
#define COLLISION_GROUP_INTERACTIVE_DEBRIS  3   /** Collides with everything except other interactive debris or debris. */
#define COLLISION_GROUP_INTERACTIVE		 4   /** Collides with everything except interactive debris or debris. */
#define COLLISION_GROUP_PLAYER			  5   /** This is the default behavior expected for most prop_physics. */
#define COLLISION_GROUP_BREAKABLE_GLASS	 6   /** Special group for glass debris. */
#define COLLISION_GROUP_VEHICLE			 7   /** Collision group for driveable vehicles. */
#define COLLISION_GROUP_PLAYER_MOVEMENT	 8   /** For HL2, same as Collision_Group_Player. */
#define COLLISION_GROUP_NPC				 9   /** Generic NPC group. */
#define COLLISION_GROUP_IN_VEHICLE		  10  /** For any entity inside a vehicle. */
#define COLLISION_GROUP_WEAPON			  11  /** For any weapons that need collision detection. */
#define COLLISION_GROUP_VEHICLE_CLIP		12  /** Vehicle clip brush to restrict vehicle movement. */
#define COLLISION_GROUP_PROJECTILE		  13  /** Projectiles. */
#define COLLISION_GROUP_DOOR_BLOCKER		14  /** Blocks entities not permitted to get near moving doors. */
#define COLLISION_GROUP_PASSABLE_DOOR	   15  /** Doors that the player shouldn't collide with. */
#define COLLISION_GROUP_DISSOLVING		  16  /** Things that are dissolving are in this group. */
#define COLLISION_GROUP_PUSHAWAY			17  /** Nonsolid on client and server, pushaway in player code. */
#define COLLISION_GROUP_NPC_ACTOR		   18  /** Used so NPCs in scripts ignore the player. */

#define ANTISTICK_COLLISIONS_OFF COLLISION_GROUP_DEBRIS_TRIGGER
#define ANTISTICK_COLLISIONS_ON COLLISION_GROUP_PLAYER
/**
 * @endsection
 */

/**
 * Default player hull width.
 */
#define ANTISTICK_DEFAULT_HULL_WIDTH 32.0

/**
 * Stores "StartTouch" HookID's for each client.
 */
int g_iStartTouchHookID[MAXPLAYERS + 1] = {-1, ...};

/**
 * List of components that make up the model's rectangular boundaries.
 * 
 * F = Front
 * B = Back
 * L = Left
 * R = Right
 * U = Upper
 * D = Down
 */
enum AntiStickBoxBound
{
	BoxBound_FUR = 0, /** Front upper right */
	BoxBound_FUL,	 /** etc.. */
	BoxBound_FDR,
	BoxBound_FDL,
	BoxBound_BUR,
	BoxBound_BUL,
	BoxBound_BDR,
	BoxBound_BDL,
}
/**
 * Create commands related to antistick here.
 */
void AntiStickOnCommandsCreate()
{
	RegConsoleCmd("zr_antistick_dump_group", AntiStickDumpGroupCommand, "Dumps collision group data on one or more players. Usage zr_antistick_dump_group [#userid|name]");
}

/**
 * Client is joining the server.
 * 
 * @param client	The client index.
 */
void AntiStickClientInit(int client)
{
	// Hook "StartTouch" and "EndTouch" on client.
	#if defined USE_SDKHOOKS
		SDKHook(client, SDKHook_StartTouch, AntiStickStartTouch);
		
		// Set dummy value so it think it's hooked.
		g_iStartTouchHookID[client] = 1;
	#else
		g_iStartTouchHookID[client] = ZRTools_HookStartTouch(client, AntiStickStartTouch);
	#endif
}

/**
 * Unhook StartTouch and EndTouch function on a client.
 * 
 * @param client	The client index.
 */
void AntiStickOnClientDisconnect(int client)
{
	// Unhook "StartTouch" callback, and reset variable.
	if (g_iStartTouchHookID[client] != -1)
	{
		#if defined USE_SDKHOOKS
			SDKUnhook(client, SDKHook_StartTouch, AntiStickStartTouch);
		#else
			ZRTools_UnhookStartTouch(g_iStartTouchHookID[client]);
		#endif
		
		g_iStartTouchHookID[client] = -1;
	}
}

/**
 * Callback function for StartTouch.
 * 
 * @param client		The client index.
 * @param entity		The entity index of the entity being touched.
 */
#if defined USE_SDKHOOKS
public void AntiStickStartTouch(int client, int entity)
#else
public ZRTools_Action AntiStickStartTouch(int client, int entity)
#endif
{
	// If antistick is disabled, then stop.
	bool antistick = GetConVarBool(g_hCvarsList[CVAR_ANTISTICK]);
	if (!antistick)
	{
		return;
	}
	
	// If client isn't in-game, then stop.
	if (!IsClientInGame(client))
	{
		return;
	}
	
	// If client is touching themselves, then leave them alone :P
	if (client == entity)
	{
		return;
	}
	
	// If touched entity isn't a valid client, then stop.
	if (!ZRIsClientValid(entity))
	{
		return;
	}
	
	// If the clients aren't colliding, then stop.
	if (!AntiStickIsModelBoxColliding(client, entity))
	{
		return;
	}
		
	// From this point we know that client and entity is more or less within eachother.
	LogEvent(false, LogType_Normal, LOG_DEBUG, LogModule_AntiStick, "Collision", "Player \"%N\" and \"%N\" are intersecting. Removing collisions.", client, entity);
	
	// Get current collision groups of client and entity.
	int clientcollisiongroup = AntiStickGetCollisionGroup(client);
	
	// Note: If zombies get stuck on infection or stuck in a teleport, they'll
	//	   get the COLLISION_GROUP_PUSHAWAY collision group, so check this
	//	   one too.
	
	// If the client is in any other collision group than "off", than we must set them to off, to unstick.
	if (clientcollisiongroup != ANTISTICK_COLLISIONS_OFF)
	{
		// Disable collisions to unstick, and start timers to re-solidify.
		AntiStickSetCollisionGroup(client, ANTISTICK_COLLISIONS_OFF);
		CreateTimer(0.0, AntiStickSolidifyTimer, client, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
}

/**
 * Callback for solidify timer.
 * 
 * @param client		The client index.
 */
public Action AntiStickSolidifyTimer(Handle timer, any client)
{
	// If client has left, then stop.
	if (!IsClientInGame(client))
	{
		return Plugin_Stop;
	}
	
	// If the client is dead, then stop.
	if (!IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	
	// If the client's collisions are already on, then stop.
	if (AntiStickGetCollisionGroup(client) == ANTISTICK_COLLISIONS_ON)
	{
		return Plugin_Stop;
	}
	
	// Loop through all clients and check if client is stuck in them.
	for (int x = 1; x <= MaxClients; x++)
	{
		// If client isn't connected or in-game, then skip it.
		if (!IsClientConnected(x) || !IsClientInGame(x))
		{
			continue;
		}
		
		// If the client is dead, then skip it.
		if (!IsPlayerAlive(x))
		{
			continue;
		}
		
		// Don't compare the same clients.
		if (client == x)
		{
			continue;
		}
		
		// If the client is colliding with a client, then allow timer to continue.
		if (AntiStickIsModelBoxColliding(client, x))
		{
			return Plugin_Continue;
		}
	}
	
	// Change collisions back to normal.
	AntiStickSetCollisionGroup(client, ANTISTICK_COLLISIONS_ON);
	
	// Debug message. May be useful when calibrating antistick.
	LogEvent(false, LogType_Normal, LOG_DEBUG, LogModule_AntiStick, "Collision", "Player \"%N\" is no longer intersecting anyone. Applying normal collisions.", client);
	
	return Plugin_Stop;
}

/**
 * Build the model box by finding all vertices.
 * 
 * @param client		The client index.
 * @param boundaries	Array with 'AntiStickBoxBounds' for indexes to return bounds into.
 * @param width		 The width of the model box.
 */
stock void AntiStickBuildModelBox(int client, float boundaries[AntiStickBoxBound][3], float width)
{
	float clientloc[3];
	float twistang[3];
	float cornerang[3];
	float sideloc[3];
	float finalloc[4][3];
	
	// Get needed vector info.
	GetClientAbsOrigin(client, clientloc);
	
	// Set the pitch to 0.
	twistang[1] = 90.0;
	cornerang[1] = 0.0;
	
	for (int x = 0; x < 4; x++)
	{
		// Jump to point on player's left side.
		AntiStickJumpToPoint(clientloc, twistang, width / 2, sideloc);
		
		// From this point, jump to the corner, which would be half the width from the middle of a side.
		AntiStickJumpToPoint(sideloc, cornerang, width / 2, finalloc[x]);
		
		// Twist 90 degrees to find next side/corner.
		twistang[1] += 90.0;
		cornerang[1] += 90.0;
		
		// Fix angles.
		if (twistang[1] > 180.0)
		{
			twistang[1] -= 360.0;
		}
		
		if (cornerang[1] > 180.0)
		{
			cornerang[1] -= 360.0;
		}
	}
	
	// Copy all horizontal model box data to array.
	boundaries[BoxBound_FUR][0] = finalloc[3][0];
	boundaries[BoxBound_FUR][1] = finalloc[3][1];
	boundaries[BoxBound_FUL][0] = finalloc[0][0];
	boundaries[BoxBound_FUL][1] = finalloc[0][1];
	boundaries[BoxBound_FDR][0] = finalloc[3][0];
	boundaries[BoxBound_FDR][1] = finalloc[3][1];
	boundaries[BoxBound_FDL][0] = finalloc[0][0];
	boundaries[BoxBound_FDL][1] = finalloc[0][1];
	boundaries[BoxBound_BUR][0] = finalloc[2][0];
	boundaries[BoxBound_BUR][1] = finalloc[2][1];
	boundaries[BoxBound_BUL][0] = finalloc[1][0];
	boundaries[BoxBound_BUL][1] = finalloc[1][1];
	boundaries[BoxBound_BDR][0] = finalloc[2][0];
	boundaries[BoxBound_BDR][1] = finalloc[2][1];
	boundaries[BoxBound_BDL][0] = finalloc[1][0];
	boundaries[BoxBound_BDL][1] = finalloc[1][1];
	
	// Set Z bounds.
	float eyeloc[3];
	GetClientEyePosition(client, eyeloc);
	
	boundaries[BoxBound_FUR][2] = eyeloc[2];
	boundaries[BoxBound_FUL][2] = eyeloc[2];
	boundaries[BoxBound_FDR][2] = clientloc[2] + 15.0;
	boundaries[BoxBound_FDL][2] = clientloc[2] + 15.0;
	boundaries[BoxBound_BUR][2] = eyeloc[2];
	boundaries[BoxBound_BUL][2] = eyeloc[2];
	boundaries[BoxBound_BDR][2] = clientloc[2] + 15.0;
	boundaries[BoxBound_BDL][2] = clientloc[2] + 15.0;
}

/**
 * Jumps from a point to another based off angle and distance.
 * 
 * @param vec	   Point to jump from.
 * @param ang	   Angle to base jump off of.
 * @param distance  Distance to jump
 * @param result	Resultant point.
 */
stock void AntiStickJumpToPoint(const float vec[3], const float ang[3], float distance, float result[3])
{
	float viewvec[3];
	
	// Turn client angle, into a vector.
	GetAngleVectors(ang, viewvec, NULL_VECTOR, NULL_VECTOR);
	
	// Normalize vector.
	NormalizeVector(viewvec, viewvec);
	
	// Scale to the given distance.
	ScaleVector(viewvec, distance);
	
	// Add the vectors together.
	AddVectors(vec, viewvec, result);
}

/**
 * Get the max/min value of a 3D box on any axis.
 * 
 * @param axis		  The axis to check.
 * @param boundaries	The boundaries to check.
 * @param min		   Return the min value instead.
 */
stock float AntiStickGetBoxMaxBoundary(int axis, float boundaries[AntiStickBoxBound][3], bool min = false)
{
	// Create 'outlier' with initial value of first boundary.
	float outlier = boundaries[0][axis];
	
	// x = Boundary index. (Start at 1 because we initialized 'outlier' with the 0 index's value)
	int size = sizeof(boundaries);
	for (int x = 1; x < size; x++)
	{
		if (!min && boundaries[x][axis] > outlier)
		{
			outlier = boundaries[x][axis];
		}
		else if (min && boundaries[x][axis] < outlier)
		{
			outlier = boundaries[x][axis];
		}
	}
	
	// Return value.
	return outlier;
}

/**
 * Checks if a player is currently stuck within another player.
 *
 * @param client1   The first client index.
 * @param client2   The second client index.
 * @return		  True if they are stuck together, false if not.
 */
stock bool AntiStickIsModelBoxColliding(int client1, int client2)
{
	float client1modelbox[AntiStickBoxBound][3];
	float client2modelbox[AntiStickBoxBound][3];
	
	// Build model boxes for each client.
	AntiStickBuildModelBox(client1, client1modelbox, ANTISTICK_DEFAULT_HULL_WIDTH);
	AntiStickBuildModelBox(client2, client2modelbox, ANTISTICK_DEFAULT_HULL_WIDTH);
	
	// Compare x values.
	float max1x = AntiStickGetBoxMaxBoundary(0, client1modelbox);
	float max2x = AntiStickGetBoxMaxBoundary(0, client2modelbox);
	float min1x = AntiStickGetBoxMaxBoundary(0, client1modelbox, true);
	float min2x = AntiStickGetBoxMaxBoundary(0, client2modelbox, true);
	
	if (max1x < min2x || min1x > max2x)
	{
		return false;
	}
	
	// Compare y values.
	float max1y = AntiStickGetBoxMaxBoundary(1, client1modelbox);
	float max2y = AntiStickGetBoxMaxBoundary(1, client2modelbox);
	float min1y = AntiStickGetBoxMaxBoundary(1, client1modelbox, true);
	float min2y = AntiStickGetBoxMaxBoundary(1, client2modelbox, true);
	
	if (max1y < min2y || min1y > max2y)
	{
		return false;
	}
	
	// Compare z values.
	float max1z = AntiStickGetBoxMaxBoundary(2, client1modelbox);
	float max2z = AntiStickGetBoxMaxBoundary(2, client2modelbox);
	float min1z = AntiStickGetBoxMaxBoundary(2, client1modelbox, true);
	float min2z = AntiStickGetBoxMaxBoundary(2, client2modelbox, true);
	
	if (max1z < min2z || min1z > max2z)
	{
		return false;
	}
	
	// They are intersecting.
	return true;
}

/**
 * Sets the collision group on a client.
 *
 * @param client			The client index.
 * @param collisiongroup	Collision group flag.
 */
void AntiStickSetCollisionGroup(int client, int collisiongroup)
{
	SetEntProp(client, Prop_Data, "m_CollisionGroup", collisiongroup);
}

/**
 * Gets the collision group on a client.
 *
 * @param client	The client index.
 * @return		  The collision group on the client.
 */
int AntiStickGetCollisionGroup(int client)
{
	return GetEntProp(client, Prop_Data, "m_CollisionGroup");
}

/**
 * Converts a collision group value into a name.
 *
 * @param collisiongroup	The collision group to convert.
 * @param buffer			Destination string buffer.
 * @param maxlen			Size of destination buffer.
 * @return				  Number of cells written.
 */
int AntiStickCollisionGroupToString(int collisiongroup, char[] buffer, int maxlen)
{
	switch (collisiongroup)
	{
		case COLLISION_GROUP_NONE:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_NONE");
		}
		case COLLISION_GROUP_DEBRIS:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_DEBRIS");
		}
		case COLLISION_GROUP_DEBRIS_TRIGGER:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_DEBRIS_TRIGGER");
		}
		case COLLISION_GROUP_INTERACTIVE_DEBRIS:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_INTERACTIVE_DEBRIS");
		}
		case COLLISION_GROUP_INTERACTIVE:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_INTERACTIVE");
		}
		case COLLISION_GROUP_PLAYER:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_PLAYER");
		}
		case COLLISION_GROUP_BREAKABLE_GLASS:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_BREAKABLE_GLASS");
		}
		case COLLISION_GROUP_VEHICLE:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_VEHICLE");
		}
		case COLLISION_GROUP_PLAYER_MOVEMENT:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_PLAYER_MOVEMENT");
		}
		case COLLISION_GROUP_NPC:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_NPC");
		}
		case COLLISION_GROUP_IN_VEHICLE:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_IN_VEHICLE");
		}
		case COLLISION_GROUP_WEAPON:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_WEAPON");
		}
		case COLLISION_GROUP_VEHICLE_CLIP:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_VEHICLE_CLIP");
		}
		case COLLISION_GROUP_PROJECTILE:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_PROJECTILE");
		}
		case COLLISION_GROUP_DOOR_BLOCKER:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_DOOR_BLOCKER");
		}
		case COLLISION_GROUP_PASSABLE_DOOR:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_PASSABLE_DOOR");
		}
		case COLLISION_GROUP_DISSOLVING:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_DISSOLVING");
		}
		case COLLISION_GROUP_PUSHAWAY:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_PUSHAWAY");
		}
		case COLLISION_GROUP_NPC_ACTOR:
		{
			return strcopy(buffer, maxlen, "COLLISION_GROUP_NPC_ACTOR");
		}
	}
	
	// No match. Write a blank string.
	return strcopy(buffer, maxlen, "");
}

/**
 * Command callback (zr_antistick_dump_group)
 * Dumps collision group data.
 * 
 * @param client	The client index.
 * @param argc	  Argument count.
 */
public Action AntiStickDumpGroupCommand(int client, int argc)
{
	int collisiongroup;
	int target;
	char groupname[64];
	char arg[96];
	
	// Write header.
	ReplyToCommand(client, "Player:							 Collision group:\n--------------------------------------------------------------------------------");
	
	if (argc < 1)
	{
		// Dump collision groups on all players.
		
		// Loop through all alive players.
		for (target = 1; target <= MaxClients; target++)
		{
			// Validate client state.
			if (!IsClientConnected(target) || !IsClientInGame(target) || !IsPlayerAlive(target))
			{
				continue;
			}
			
			// Get collision group name.
			collisiongroup = AntiStickGetCollisionGroup(target);
			AntiStickCollisionGroupToString(collisiongroup, groupname, sizeof(groupname));
			
			// List player name and collision group.
			ReplyToCommand(client, "%-35N %s", target, groupname);
		}
	}
	else
	{
		// Get the target.
		GetCmdArg(1, arg, sizeof(arg));
		target = FindTarget(client, arg);
		
		// Validate target.
		if (ZRIsClientValid(target))
		{
			// Get collision group name.
			collisiongroup = AntiStickGetCollisionGroup(target);
			AntiStickCollisionGroupToString(collisiongroup, groupname, sizeof(groupname));
			
			// List player name and collision group.
			ReplyToCommand(client, "%-35N %s", target, groupname);
		}
	}
	
	return Plugin_Handled;
}
