/*--------------------------------------------------------------------------------
 / vim: set ts=4 :
 /--------------------------------------------------------------------------------
 / CTX Extension
 / Copyright (C) 2011 A.W. 'Swixel' Stanley.
 /--------------------------------------------------------------------------------
 /
 / This program is free software: you can redistribute it and/or modify
 / it under the terms of the GNU Affero General Public License as published by
 / the Free Software Foundation, either version 3 of the License, or
 / (at your option) any later version.
 /
 / This program is distributed in the hope that it will be useful,
 / but WITHOUT ANY WARRANTY; without even the implied warranty of
 / MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 / GNU Affero General Public License for more details.
 /
 / You should have received a copy of the GNU Affero General Public License
 / along with this program.  If not, see <http://www.gnu.org/licenses/>.
 /
 / As a special exception, AlliedModders LLC gives you permission to link the
 / code of this program (as well as its derivative works) to "Half-Life 2," the
 / "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 / by the Valve Corporation.  You must obey the GNU General Public License in
 / all respects for all other code used.  Additionally, AlliedModders LLC grants
 / this exception to all derivative works.  AlliedModders LLC defines further
 / exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 / or <http://www.sourcemod.net/license.php>.
 /------------------------------------------------------------------------------*/

#if defined _ctx_included
 #endinput
#endif
#define _ctx_included

/*--------------------------------------------------------------------------------
/ Constants
/-------------------------------------------------------------------------------*/

// CTX Types
#define CTX_PLAYER 0
#define CTX_PLAYER_TEAM2 1
#define CTX_WEAPON 2
#define CTX_OBJECT 3

/*--------------------------------------------------------------------------------
/ Natives Reset
/-------------------------------------------------------------------------------*/

/**
 * Reset a single player, player (team 2), weapon, or object.
 * @param CTX_TYPE				CTX Type
 * @param strClassName          Identifier of the "class" being reset.
 * @return						Success (bool).
 */
 native bool:CTX_Reset(CTX_TYPE, String:strClassName[]);

/**
 * Resets all players, players (team 2), weapons, objects, or everything (CTX_ALL).
 * @param CTX_TYPE				CTX Type
 * @return						Success (bool).
 */
native bool:CTX_ResetAll(CTX_TYPE);

/*--------------------------------------------------------------------------------
/ Natives Set/Get
/-------------------------------------------------------------------------------*/

/**
 * Set a single bool value in an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname.  
 * @param NewValue				Input.
 * @return						Success (bool).
 */
native bool:CTX_SetBool(CTX_TYPE, String:Variable[], String:strClassName[], bool:NewValue);

/**
 * Get a single bool value from an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname. 
 * @param ReturnBuffer			Return buffer.
 * @return						Success (bool).
 */
native bool:CTX_GetBool(CTX_TYPE, String:Variable[], String:strClassName[], &bool:ReturnedBool);

/**
 * Set a single float value in an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname.  
 * @param NewValue				Input.
 * @return						Success (bool).
 */
native bool:CTX_SetFloat(CTX_TYPE, String:Variable[], String:strClassName[], Float:NewValue);

/**
 * Get a single float value from an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname. 
 * @param ReturnBuffer			Return buffer.
 * @return						Success (bool).
 */
native bool:CTX_GetFloat(CTX_TYPE, String:Variable[], String:strClassName[], &Float:ReturnedFloat);

/**
 * Set a single int value in an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname.  
 * @param NewValue				Input.
 * @return						Success (bool).
 */
native bool:CTX_SetInt(CTX_TYPE, String:Variable[], String:strClassName[], NewValue);

/**
 * Get a single int value from an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname. 
 * @param ReturnBuffer			Return buffer.
 * @return						Success (bool).
 */
native bool:CTX_GetInt(CTX_TYPE, String:Variable[], String:strClassName[], &ReturnedInt);


/**
 * Set a single string value in an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname.  
 * @param NewValue				Input.
 * @return						Success (bool).
 */
 native bool:CTX_SetString(CTX_TYPE, String:Variable[], String:strClassName[], String:NewValue[]);

/**
 * Get a single string value from an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname. 
 * @param ReturnBuffer			Return buffer.
 * @return						Success (bool).
 */
native bool:CTX_GetString(CTX_TYPE, String:Variable[], String:strClassName[], String:ReturnBuffer[]);

/**
 * Set a single string value in an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname.  
 * @param NewValue				Input.
 * @return						Success (bool).
 */
 native bool:CTX_SetStringPtr(CTX_TYPE, String:Variable[], String:strClassName[], String:NewValue[]);


/**
 * Get a single string ptr value from an item.
 * @param CTX_TYPE				CTX Type
 * @param Variable				Variable/Offset alias (see readme files).
 * @param strClassName          Item classname. 
 * @param ReturnBuffer			Return buffer.
 * @return						Success (bool).
 */
native bool:CTX_GetStringPtr(CTX_TYPE, String:Variable[], String:strClassName[], String:ReturnBuffer[]);


/* Edit nothing below this line */
public Extension:__ext_ctx =
{
	name = "ctx",
	file = "ctx.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_EXTENSIONS
public __ext_ctx_SetNTVOptional()
{
MarkNativeAsOptional("CTX_ResetOne");
MarkNativeAsOptional("CTX_ResetAll");
MarkNativeAsOptional("CTX_Get");
MarkNativeAsOptional("CTX_Set");
}
#endif