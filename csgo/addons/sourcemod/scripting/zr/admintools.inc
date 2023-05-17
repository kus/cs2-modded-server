/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  admintools.inc
 *  Type:		  Core 
 *  Description:   Functions for checking extended admin privileges.
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
 * @section Pre-defined SourceMod group names for authenticating players.
 */
#define ZR_GROUP_ADMINS		 "zr_admins"
#define ZR_GROUP_MODERATORS	 "zr_moderators"
#define ZR_GROUP_CONFIGURATORS  "zr_configurators"
/**
 * @endsection
 */

/**
 * List of operation types to specify the category of a admin operation.
 */
enum OperationTypes
{
	OperationType_Invalid = -1,	 /** Invalid operation type. */
	OperationType_Generic,		  /** Generic events like infecting or teleporting players. */
	OperationType_Configuration,	/** Changing settings. */
}


/**
 * Returns whether a player is allowed to do a certain operation or not.
 *
 * @param client			The client index.
 * @param operationType	 The operation category.
 * @return				  True if allowed, false otherwise.
 */
stock bool ZRIsClientPrivileged(int client, OperationTypes operationType = OperationType_Generic)
{
	// Check if console.
	if (client == 0)
	{
		// Console always has full access no matter what.
		return true;
	}
	
	// Validate client index.
	if (!ZRIsClientValid(client))
	{
		return false;
	}
	
	// Check if group authentication is used.
	bool groupauth = GetConVarBool(g_hCvarsList[CVAR_PERMISSIONS_USE_GROUPS]);
	if (groupauth)
	{
		/**********************************
		 *								*
		 *   GROUP BASED AUTHENTICATION   *
		 *								*
		 **********************************/
		 
		// Check if client is full admin.
		if (ZRIsClientInGroup(client, ZR_GROUP_ADMINS))
		{
			return true;
		}
		
		// Check operation type.
		switch (operationType)
		{
			case OperationType_Generic:
			{
				return ZRIsClientInGroup(client, ZR_GROUP_MODERATORS);
			}
			case OperationType_Configuration:
			{
				return ZRIsClientInGroup(client, ZR_GROUP_CONFIGURATORS);
			}
		}
		
		// Invalid operation type.
		return false;
	}
	else
	{
		/*********************************
		 *							   *
		 *   FLAG BASED AUTHENTICATION   *
		 *							   *
		 *********************************/
		
		AdminFlag flag;
		
		// Check operation type.
		switch (operationType)
		{
			case OperationType_Generic:
			{
				flag = Admin_Generic;
			}
			case OperationType_Configuration:
			{
				flag = Admin_Config;
			}
			default:
			{
				// Invalid operation type.
				return false;
			}
		}
		
		return GetAdminFlag(GetUserAdmin(client), flag);
	}
}

/**
 * Returns whether a player is in a spesific group or not.
 *
 * @param client		The client index.
 * @param groupName	 SourceMod group name to check.
 * @return			  True if in the group, false otherwise.
 */
stock bool ZRIsClientInGroup(int client, const char[] groupName)
{
	AdminId id = GetUserAdmin(client);
	
	// Validate id.
	if (id == INVALID_ADMIN_ID)
	{
		return false;
	}
	
	// Get number of groups.
	int groupnum = GetAdminGroupCount(id);
	char groupname[64];
	
	// Validate number of groups.
	if (groupnum > 0)
	{
		// Loop through each group.
		for (int group = 0; group < groupnum; group++)
		{
			// Get group name.
			GetAdminGroup(id, group, groupname, sizeof(groupname));
			
			// Compare names.
			if (StrEqual(groupName, groupname, false))
			{
				return true;
			}
		}
	}
	
	// No groups or no match.
	return false;
}
