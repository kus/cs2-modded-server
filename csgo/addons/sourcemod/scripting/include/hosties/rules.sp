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
#include <cstrike>
#include <sdktools>
#include <hosties>

new Handle:gH_Cvar_RulesOn = INVALID_HANDLE;
new bool:gShadow_RulesOn;
new Handle:gH_Cvar_Announce_Rules = INVALID_HANDLE;
new bool:gShadow_Announce_Rules;
new Handle:gH_Cvar_Rules_Mode = INVALID_HANDLE;
new gShadow_Rules_Mode = 1;
new Handle:gH_Cvar_Rules_Website = INVALID_HANDLE;
new String:gShadow_Rules_Website[192];
new Handle:gH_DArray_Rules = INVALID_HANDLE;

Rules_OnPluginStart()
{
	gH_Cvar_RulesOn = CreateConVar("sm_hosties_rules_enable", "1", "Enable or disable rules showing up at !rules command (if you need to disable the command registration on plugin startup, add a file in your sourcemod/configs/ named hosties_rulesdisable.ini with any content): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gShadow_RulesOn = true;
	
	gH_Cvar_Announce_Rules = CreateConVar("sm_hosties_announce_rules", "1", "Enable or disable rule announcements in the beginning of every round ('please follow the rules listed in !rules'): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gShadow_Announce_Rules = true;
	
	gH_Cvar_Rules_Mode = CreateConVar("sm_hosties_rules_mode", "1", "1 - Panel Mode, 2 - Website", 0, true, 1.0, true, 2.0);
	gShadow_Rules_Mode = 2;
	
	gH_Cvar_Rules_Website = CreateConVar("sm_hosties_rules_website", "http://www.youtube.com/watch?v=oHg5SJYRHA0", "The website for the rules page.", 0);
	Format(gShadow_Rules_Website, sizeof(gShadow_Rules_Website), "http://www.youtube.com/watch?v=oHg5SJYRHA0");
	
	HookConVarChange(gH_Cvar_RulesOn, Rules_CvarChanged);
	HookConVarChange(gH_Cvar_Announce_Rules, Rules_CvarChanged);
	HookConVarChange(gH_Cvar_Rules_Mode, Rules_CvarChanged);
	HookConVarChange(gH_Cvar_Rules_Website, Rules_CvarChanged);
	
	HookEvent("round_start", Rules_RoundStart);
	
	// Provided for backwards comparibility
	decl String:file[256];
	BuildPath(Path_SM, file, 255, "configs/hosties_rulesdisable.ini");
	new Handle:fileh = OpenFile(file, "r");
	if (fileh == INVALID_HANDLE)
	{
		RegConsoleCmd("sm_rules", Command_Rules);
	}
	
	gH_DArray_Rules = CreateArray(255);
}

public Rules_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_Announce_Rules)
	{
		PrintToChatAll(CHAT_BANNER, "Please Follow Rules");
	}
}

Rules_OnConfigsExecuted()
{
	gShadow_RulesOn = GetConVarBool(gH_Cvar_RulesOn);
	gShadow_Announce_Rules = GetConVarBool(gH_Cvar_Announce_Rules);
	gShadow_Rules_Mode = GetConVarInt(gH_Cvar_Rules_Mode);
	GetConVarString(gH_Cvar_Rules_Website, gShadow_Rules_Website, sizeof(gShadow_Rules_Website));
	
	ParseTheRulesFile();
}

void ParseTheRulesFile()
{
	ClearArray(gH_DArray_Rules);
	
	decl String:pathRules[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, pathRules, sizeof(pathRules), "configs/hosties_rules.ini");
	new Handle:rulesFile = OpenFile(pathRules, "r");
	
	if (rulesFile != INVALID_HANDLE)
	{
		decl String:sRulesLine[256];
		
		while(ReadFileLine(rulesFile, sRulesLine, sizeof(sRulesLine)))
		{
			PushArrayString(gH_DArray_Rules, sRulesLine);
		}
	}
}

public Rules_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_RulesOn)
	{
		gShadow_RulesOn = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Announce_Rules)
	{
		gShadow_Announce_Rules = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Rules_Mode)
	{
		gShadow_Rules_Mode = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Rules_Website)
	{
		Format(gShadow_Rules_Website, sizeof(gShadow_Rules_Website), newValue);
	}
}

public Action:Command_Rules(client, args)
{
	if (gShadow_RulesOn)
	{
		switch (gShadow_Rules_Mode)
		{
			case 1:
			{
				new iNumOfRules = GetArraySize(gH_DArray_Rules);
				
				if (iNumOfRules > 0)
				{
					new Handle:Hosties_Rules_Panel = CreatePanel();
					decl String:sPanelText[256];	
					Format(sPanelText, sizeof(sPanelText), "%t", "Server Rules");
					SetPanelTitle(Hosties_Rules_Panel, sPanelText);
					DrawPanelText(Hosties_Rules_Panel, " ");		
					
					for (new line = 0; line < iNumOfRules; line++)
					{
						GetArrayString(gH_DArray_Rules, line, sPanelText, sizeof(sPanelText));
						DrawPanelText(Hosties_Rules_Panel, sPanelText);
					}
					
					DrawPanelText(Hosties_Rules_Panel, "0. to Exit");
					
					SendPanelToClient(Hosties_Rules_Panel, client, Panel_Handler, MENU_TIME_FOREVER);
					CloseHandle(Hosties_Rules_Panel);
				}
			}
			case 2:
			{
				ShowMOTDPanel(client, "Rules", gShadow_Rules_Website, MOTDPANEL_TYPE_URL);
			}
		}
	}

	return Plugin_Handled;
}

public Panel_Handler(Handle:panel, MenuAction:action, param1, param2)
{
	// regardless of what the MenuAction is, do nothing
}
