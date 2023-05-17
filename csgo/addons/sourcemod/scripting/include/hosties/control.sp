/*
 * SourceMod Hosties Project
 * by: SourceMod Hosties Dev Team
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

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <hosties>

// Menus
#define MENU_SIMON			"##simonsays##"
#define MENU_FIRST			"##firstreaction##"
#define MENU_LAST				"##lastreaction##"
#define MENU_JUMP				"##jump##"
#define MENU_CROUCH			"##crouch##"
#define MENU_NONE				"##none##"
#define MENU_FOLLOW			"##followme##"
#define MENU_GOTO				"##goto##"
#define MENU_FREE				"##freeday##"

// Actions IDs
#define ACTION_ID_JUMP		0
#define ACTION_ID_CROUCH	1
#define ACTION_ID_FOLLOW	2
#define ACTION_ID_GOTO		3
#define ACTION_ID_FREE		4

#define ACTION_COUNT			5

// Tasks IDs
#define TASK_ID_SIMON		0
#define TASK_ID_FIRST		1
#define TASK_ID_LAST			2

#define TASK_COUNT			3

new bool:g_bController[MAXPLAYERS + 1] = false;
new bool:g_bInControl[MAXPLAYERS + 1] = false;
new bool:g_bActComplete[MAXPLAYERS + 1] = false;
new bool:g_bHasController = false;
new bool:g_bCanControl = false;
new bool:g_bInSimonSays = false;
new bool:g_bInAction = false;
new bool:g_bCanStop = false;
new Float:g_fDelay = 0.0;
new g_iState = 0;
new Handle:gH_ControllerMenu = INVALID_HANDLE;
new String:g_sActionSound[ACTION_COUNT][PLATFORM_MAX_PATH] = {"sm_hosties/control/jump.mp3", "sm_hosties/control/crouch.mp3", "sm_hosties/control/follow.mp3", "sm_hosties/control/go.mp3", "sm_hosties/control/freeday.mp3"};
new String:g_sTaskSound[TASK_COUNT][PLATFORM_MAX_PATH] = {"sm_hosties/control/simon.mp3", "sm_hosties/control/first.mp3", "sm_hosties/control/last.mp3"};

Control_OnPluginStart()
{
	RegConsoleCmd("sm_control", Command_Control);
	RegConsoleCmd("sm_hostiescontrol", Command_Control);
	RegConsoleCmd("sm_hc", Command_Control);
	HookEvent("player_death", Control_PlayerDeath);
	HookEvent("player_disconnect", Control_PlayerDisconnect);
}

public Control_Menu(client)
{
	if(g_bHasController && Control_GetController() == client)
	{
		if(gH_ControllerMenu == INVALID_HANDLE)
		{
			gH_ControllerMenu = CreateMenu(ControllerMenuHandle, MenuAction:MENU_ACTIONS_ALL);
			if(g_iState == 0)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "Main");
				AddMenuItem(gH_ControllerMenu, MENU_SIMON, "Simon"); // state 1
				AddMenuItem(gH_ControllerMenu, MENU_FIRST, "First"); // state 2
				AddMenuItem(gH_ControllerMenu, MENU_LAST, "Last"); // state 3
				AddMenuItem(gH_ControllerMenu, MENU_NONE, "None"); // state 4
			}
			else if(g_iState == 1)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "Simon");
				AddMenuItem(gH_ControllerMenu, MENU_FIRST, "First"); // state 11
				AddMenuItem(gH_ControllerMenu, MENU_LAST, "Last"); // state 12
				AddMenuItem(gH_ControllerMenu, MENU_NONE, "None"); // state 13
			}
			else if(g_iState == 2)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "First");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 3)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "Last");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 4)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "None");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_FOLLOW, "Follow");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
				AddMenuItem(gH_ControllerMenu, MENU_FREE, "Freeday");
			}
			else if(g_iState == 11)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control Action", "Simon", "First");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 12)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control Action", "Simon", "Last");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 13)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control Action", "Simon", "None");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_FOLLOW, "Follow");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
				AddMenuItem(gH_ControllerMenu, MENU_FREE, "Freeday");
			}
			/*
			AddMenuItem(gH_ControllerMenu, MENU_SIMON, "Simon");
			AddMenuItem(gH_ControllerMenu, MENU_FIRST, "First");
			AddMenuItem(gH_ControllerMenu, MENU_LAST, "Last");
			AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
			AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
			AddMenuItem(gH_ControllerMenu, MENU_FOLLOW, "Follow");
			AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			AddMenuItem(gH_ControllerMenu, MENU_FREE, "Freeday");
			AddMenuItem(gH_ControllerMenu, MENU_NONE, "None");*/
			SetMenuExitButton(gH_ControllerMenu, true);
			DisplayMenu(gH_ControllerMenu, client, 0);
		}
	}
}

public ControllerMenuHandle(Handle:menu, MenuAction:action, param1, param2)
{
	/*if(action == MenuAction_DisplayItem)
	{
		if(GetMenuItemCount(menu) - 1 == param2)
		{
			decl String:selection[64], String:buffer[255];
			GetMenuItem(menu, param2, selection, sizeof(selection));
			if(strcmp(selection, MENU_SIMON, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Simon", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_FIRST, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "First", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_LAST, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Last", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_JUMP, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Jump", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_CROUCH, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Crouch", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_FOLLOW, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Follow", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_GOTO, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Goto", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_FREE, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Freeday", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_NONE, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "None", param1);
				return RedrawMenuItem(buffer);					
			}
		}
	}*/
	if (action == MenuAction_Select)
	{
		if(GetMenuItemCount(menu) - 1 == param2)
		{
			decl String:selection[64];
			GetMenuItem(menu, param2, selection, sizeof(selection));
			new bool:ReturnMenu = true;
			if(strcmp(selection, MENU_SIMON, false) == 0)
			{
				g_iState = 1;
			}
			else if(strcmp(selection, MENU_FIRST, false) == 0)
			{
				if(g_iState == 0)
				{
					g_iState = 2;
				}
				else if(g_iState == 1)
				{
					g_iState = 11;
				}
			}
			else if(strcmp(selection, MENU_LAST, false) == 0)
			{
				if(g_iState == 0)
				{
					g_iState = 3;
				}
				else if(g_iState == 1)
				{
					g_iState = 12;
				}
			}
			else if(strcmp(selection, MENU_JUMP, false) == 0)
			{
				if(g_iState == 2)
				{
					Control_PlayAction("FirstJump");
				}
				else if(g_iState == 3)
				{
					Control_PlayAction("LastJump");
				}
				else if(g_iState == 4)
				{
					Control_PlayAction("Jump");
				}
				else if(g_iState == 11)
				{
					Control_PlayAction("SimonFirstJump");
				}
				else if(g_iState == 12)
				{
					Control_PlayAction("SimonLastJump");
				}
				else if(g_iState == 13)
				{
					Control_PlayAction("SimonJump");
				}
			}
			else if(strcmp(selection, MENU_CROUCH, false) == 0)
			{
				if(g_iState == 2)
				{
					Control_PlayAction("FirstCrouch");
				}
				else if(g_iState == 3)
				{
					Control_PlayAction("LastCrouch");
				}
				else if(g_iState == 4)
				{
					Control_PlayAction("Crouch");
				}
				else if(g_iState == 11)
				{
					Control_PlayAction("SimonFirstCrouch");
				}
				else if(g_iState == 12)
				{
					Control_PlayAction("SimonLastCrouch");
				}
				else if(g_iState == 13)
				{
					Control_PlayAction("SimonCrouch");
				}
			}
			else if(strcmp(selection, MENU_FOLLOW, false) == 0)
			{
				
			}
			else if(strcmp(selection, MENU_GOTO, false) == 0)
			{
				if(g_iState == 2)
				{
					Control_PlayAction("FirstGoto");
				}
				else if(g_iState == 3)
				{
					Control_PlayAction("LastGoto");
				}
				else if(g_iState == 4)
				{
					Control_PlayAction("Goto");
				}
				else if(g_iState == 11)
				{
					Control_PlayAction("SimonFirstGoto");
				}
				else if(g_iState == 12)
				{
					Control_PlayAction("SimonLastGoto");
				}
				else if(g_iState == 13)
				{
					Control_PlayAction("SimonGoto");
				}
			}
			else if(strcmp(selection, MENU_FREE, false) == 0)
			{
				ReturnMenu = false;
				Control_PlayAction("Freeday");
			}
			else if(strcmp(selection, MENU_NONE, false) == 0)
			{
				if(g_iState == 0)
				{
					g_iState = 4;
				}
				else if(g_iState == 1)
				{
					g_iState = 13;
				}
			}
			if(ReturnMenu)
			{
				gH_ControllerMenu = INVALID_HANDLE;
				Control_Menu(param1);
			}
			CloseHandle(menu);
		}
	}
	if (action == MenuAction_Cancel)
	{
		// ToDo: Add Yes/No menu when leaving this menu (no = return to this menu, yes = stop control)
	}
}

public Control_PlayAction(String:Act[])
{
	if(StrEqual(Act, "Jump"))
	{
		EmitSoundToAllAny(g_sActionSound[ACTION_ID_JUMP]);
	}
}

Control_OnMapStart()
{
	if (g_Game == Game_CSS)
	{
		BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
		HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/lgtning.vmt");
		LaserHalo = PrecacheModel("materials/sprites/plasmahalo.vmt");
	}
	else if (g_Game == Game_CSGO)
	{
		BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		HaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		LaserHalo = PrecacheModel("materials/sprites/light_glow02.vmt");
	}
	
	for(new i = 0; i < ACTION_COUNT; i++)
	{
		if(!StrEqual(g_sActionSound[i], "", false))
		{
			PrecacheSoundAny(g_sActionSound[i]);
		}
	}
	
	for(new i = 0; i < TASK_COUNT; i++)
	{
		if(!StrEqual(g_sTaskSound[i], "", false))
		{
			PrecacheSoundAny(g_sTaskSound[i]);
		}
	}
}

public Control_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_bHasController && g_bController[client] == true)
	{
		Control_Controller(client, false, 0, true);
	}
}

public Action:Command_Control(client, args)
{
	if (GetClientTeam(client) != 3)
	{
		PrintToChat(client, CHAT_BANNER, "Must Be CT");
		return Plugin_Handled;
	}
	
	if(g_bHasController && Control_GetController() != 0)
	{
		PrintToChat(client, CHAT_BANNER, "Control Already Taken");
	}
	else
	{
		Control_Controller(client, true, -1, true);
		PrintToChat(client, CHAT_BANNER, "Control Taken");
	}
	
	return Plugin_Handled;
}

public Control_GetController()
{
	if(!g_bHasController)
	{
		return 0;
	}
	
	for(new i = 1; i <= MaxClients ; i++)
	{
		if(g_bController[i] == true)
		{
			if(IsClientInGame(i) || IsPlayerAlive(i) || GetClientTeam(i) == 3)
			{
				return i;
			}
			else
			{
				Control_Controller(i, false, -1, false);
				return 0;
			}
		}
	}
	return 0;
}

public Control_Controller(client, bool:controller, reason, bool:ann)
{
	if(controller)
	{
		if(!g_bHasController && !g_bController[client] && Control_GetController() == 0)
		{
			g_bController[client] = true;
			g_bHasController = true;
			g_iState = 0;
			Control_Menu(client);
			PrintToChatAll(CHAT_BANNER, "The New Controller");
		}
	}
	else
	{
		if(Control_GetController() == client)
		{
			g_bController[client] = false;
			g_bHasController = false;
			if(ann)
			{
				if(reason == -1)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller", client);
				}
				else if(reason == 0)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller Reason", client, "Disconncted");
				}
				else if(reason == 1)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller Reason", client, "Died");
				}
				else if(reason == 2)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller Reason", client, "Stopped controlling");
				}
			}
			else
			{
				PrintToChatAll(CHAT_BANNER, "No Controller");
			}
		}
	}
}

public Control_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_bHasController && g_bController[client] == true)
	{
		Control_Controller(client, false, 1, true);
	}
}