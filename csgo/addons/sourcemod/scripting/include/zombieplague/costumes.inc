/**
 * =============================================================================
 * Zombie Plague X Copyright (C) 2015-2020 Nikita Ushakov (Ireland, Dublin).
 * =============================================================================
 *
 * This file is part of the Zombie Plague Core.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 **/

#if defined _costumelist_included
 #endinput
#endif
#define _costumelist_included

/**
 * @brief Called before show a costume in the costumes menu.
 * 
 * @param client            The client index.
 * @param costumeID         The costume index.
 *
 * @return                  Plugin_Handled to disactivate showing and Plugin_Stop to disabled showing. Anything else
 *                              (like Plugin_Continue) to allow showing and selecting.
 **/
forward Action ZP_OnClientValidateCostume(int client, int costumeID);

/**
 * @brief Gets the amount of all costumes.
 **/
native int ZP_GetNumberCostume();

/**
 * @brief Gets the costume index of the client.
 *
 * @param client            The client index.
 *
 * @return                  The costume index.  
 **/
native int ZP_GetClientCostume(int client);

/**
 * @brief Sets the costume index to the client.
 *
 * @param client            The client index.
 * @param costumeID         The costume index. 
 **/
native void ZP_SetClientCostume(int client, int costumeID);

/**
 * @brief Gets the index of a costume at a given name.
 *
 * @param name              The costume name.
 *
 * @return                  The costume index, or -1 on failure.
 **/
native int ZP_GetCostumeNameID(char[] name);

/**
 * @brief Gets the name of a costume at a given index.
 *
 * @param costumeID         The costume index.
 * @param name              The string to return name in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetCostumeName(int costumeID, char[] name, int maxlenght = 32);

/**
 * @brief Gets the model of a costume at a given index.
 *
 * @param costumeID         The costume index.
 * @param model             The string to return model in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetCostumeModel(int costumeID, char[] model, int maxlenght = 256);

/**
 * @brief Gets the body index of the costume.
 *
 * @param costumeID         The costume index.
 *
 * @return                  The body index. 
 **/
native int ZP_GetCostumeBody(int costumeID);

/**
 * @brief Gets the skin index of the costume.
 *
 * @param costumeID         The costume index.
 *
 * @return                  The skin index. 
 **/
native int ZP_GetCostumeSkin(int costumeID);

/**
 * @brief Gets the attachment of a costume at a given index.
 *
 * @param costumeID         The costume index.
 * @param attach            The string to return attachment in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetCostumeAttach(int costumeID, char[] attach, int maxlenght = 32);

/**
 * @brief Gets the position of a costume at a given index.
 *
 * @param costumeID         The costume index.
 * @param position          The vector to return position in.
 **/
native void ZP_GetCostumePosition(int costumeID, float position[3]);

/**
 * @brief Gets the angle of a costume at a given index.
 *
 * @param costumeID         The costume index.
 * @param angle             The vector to return angle in.
 **/
native void ZP_GetCostumeAngle(int costumeID, float angle[3]);

/**
 * @brief Gets the group of a costume at a given index.
 *
 * @param costumeID         The costume index.
 * @param group             The string to return group in.
 * @param maxlenght         The lenght of string.
 **/
native void ZP_GetCostumeGroup(int costumeID, char[] group, int maxlenght = 32);

/**
 * @brief Gets the hide value of the costume.
 *
 * @param costumeID         The costume index.
 *
 * @return                  True if costume is hide, false if not.
 **/
native bool ZP_IsCostumeHide(int costumeID);

/**
 * @brief Gets the merge value of the costume.
 *
 * @param costumeID         The costume index.
 *
 * @return                  True if costume is merge, false if not.
 **/
native bool ZP_IsCostumeMerge(int costumeID);

/**
 * @brief Gets the level of the costume.
 *
 * @param classID           The costume index.
 *
 * @return                  The level amount.    
 **/
native int ZP_GetCostumeLevel(int costumeID);