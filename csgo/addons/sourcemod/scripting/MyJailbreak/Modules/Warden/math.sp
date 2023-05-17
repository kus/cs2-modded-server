/*
 * MyJailbreak - Warden - Math Quiz Module.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 * Contributer: Hexer10
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
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
 */

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <myjbwarden>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <chat-processor>

#tryinclude <scp>
#if !defined _scp_included
#include <cp-scp-wrapper>
#endif

#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Defines
#define PLUS "+"
#define MINUS "-"
#define DIVISOR "/"
#define MULTIPL "*"

// Console Variables
ConVar gc_bMath;
ConVar gc_bMathDeputy;
ConVar gc_bOp;
ConVar gc_iMinimumNumber;
ConVar gc_iMaximumNumber;
ConVar gc_bMathOverlays;
ConVar gc_bAllowCT;
ConVar gc_sMathOverlayStopPath;
ConVar gc_bMathSounds;
ConVar gc_sMathSoundStopPath;
ConVar gc_iTimeAnswer;
ConVar gc_sCustomCommandMath;
ConVar gc_bMode;

// Booleans
bool g_bIsMathQuiz = false;
bool g_bCanAnswer = false;

// Handles
Handle g_hMathTimer = null;

// Integers
int g_iMathMin;
int g_iMathMax;
int g_iMathResult;

// Strings
char g_sMathSoundStopPath[256];
char g_sMathOverlayStopPath[256];
char g_sOp[32];
char g_sOperators[4][2] = {"+", "-", "/", "*"};

// Start
public void Math_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_math", Command_MathQuestion, "Allows the Warden to start a MathQuiz. Show player with first right Answer");

	// AutoExecConfig
	gc_bMath = AutoExecConfig_CreateConVar("sm_warden_math", "1", "0 - disabled, 1 - enable mathquiz for warden", _, true, 0.0, true, 1.0);
	gc_bMathDeputy = AutoExecConfig_CreateConVar("sm_warden_math_deputy", "1", "0 - disabled, 1 - enable mathquiz for deputy, too", _, true, 0.0, true, 1.0);
	gc_iMinimumNumber = AutoExecConfig_CreateConVar("sm_warden_math_min", "1", "What should be the minimum number for questions?", _, true, 1.0);
	gc_iMaximumNumber = AutoExecConfig_CreateConVar("sm_warden_math_max", "100", "What should be the maximum number for questions?", _, true, 2.0);
	gc_bOp = AutoExecConfig_CreateConVar("sm_warden_math_mode", "1", "0 - only addition & subtraction, 1 -  addition, subtraction, multiplication & division", _, true, 0.0, true, 1.0);
	gc_bMode = AutoExecConfig_CreateConVar("sm_warden_math_input", "1", "0 - use chat trigger to recieve chat input e.g. answer = '!math 526'. This is forced when no chat-processor is installed / 1 - use a chat-processor to recieve chat input e.g. answer = '526' / use '0' when chat input of will not recognized cause conflics with chat manipulation plugins like 'CCC'", _, true, 0.0, true, 1.0);
	gc_iTimeAnswer = AutoExecConfig_CreateConVar("sm_warden_math_time", "10", "Time in seconds to give a answer to a question.", _, true, 3.0);
	gc_bAllowCT = AutoExecConfig_CreateConVar("sm_warden_math_allow_ct", "1", "0 - disabled, 1 - cts answers will also recognized", _, true, 0.0, true, 1.0);
	gc_bMathSounds = AutoExecConfig_CreateConVar("sm_warden_math_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sMathSoundStopPath = AutoExecConfig_CreateConVar("sm_warden_math_sounds_stop", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played for stop countdown.");
	gc_bMathOverlays = AutoExecConfig_CreateConVar("sm_warden_math_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sMathOverlayStopPath = AutoExecConfig_CreateConVar("sm_warden_math_overlays_stop", "overlays/MyJailbreak/stop", "Path to the stop Overlay DONT TYPE .vmt or .vft");
	gc_sCustomCommandMath = AutoExecConfig_CreateConVar("sm_warden_cmds_math", "m, quiz", "Set your custom chat commands for become warden(!math (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	// Hooks
	HookConVarChange(gc_sMathSoundStopPath, Math_OnSettingChanged);
	HookConVarChange(gc_sMathOverlayStopPath, Math_OnSettingChanged);

	// FindConVar
	gc_sMathSoundStopPath.GetString(g_sMathSoundStopPath, sizeof(g_sMathSoundStopPath));
	gc_sMathOverlayStopPath.GetString(g_sMathOverlayStopPath, sizeof(g_sMathOverlayStopPath));
}

public void Math_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sMathSoundStopPath)
	{
		strcopy(g_sMathSoundStopPath, sizeof(g_sMathSoundStopPath), newValue);
		if (gc_bMathSounds.BoolValue) PrecacheSoundAnyDownload(g_sMathSoundStopPath);
	}
	else if (convar == gc_sMathOverlayStopPath)
	{
		strcopy(g_sMathOverlayStopPath, sizeof(g_sMathOverlayStopPath), newValue);
		if (gc_bMathOverlays.BoolValue) PrecacheDecalAnyDownload(g_sMathOverlayStopPath);
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_MathQuestion(int client, int args)
{
	if (gc_bMath.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bMathDeputy.BoolValue))
		{
			if (!g_bIsMathQuiz)
			{
				CreateTimer(4.0, Timer_CreateMathQuestion, GetClientUserId(client));
				
				CPrintToChatAll("%s %t", g_sPrefix, "warden_startmathquiz");
				
				if (gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_startmathquiz_nc");
				}
				
				g_bIsMathQuiz = true;

				return Plugin_Handled;
			}
		}
		if (g_bIsMathQuiz && (!gc_bMode.BoolValue || (!gp_bSimpleChatProcessor && !gp_bChatProcessor)))
		{
			if (args != 1) // Not enough parameters
			{
				CReplyToCommand(client, "%s Use: sm_math <number>", g_sPrefix);

				return Plugin_Handled;
			}
			
			if (!g_bCanAnswer) return Plugin_Handled;
			
			char strAnswer[10];
			GetCmdArg(1, strAnswer, sizeof(strAnswer));
			
			if (ProcessSolution(client, StringToInt(strAnswer)))
			SendEndMathQuestion(client);
		}
		else CReplyToCommand(client, "%s %t", g_sPrefix, "warden_notwarden");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void Math_OnConfigsExecuted()
{
	g_iMathMin = gc_iMinimumNumber.IntValue;
	g_iMathMax = gc_iMaximumNumber.IntValue;

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Math quiz
	gc_sCustomCommandMath.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (!CommandExists(sCommand))
		{
			RegConsoleCmd(sCommand, Command_MathQuestion, "Allows the Warden to start a MathQuiz. Show player with first right Answer");
		}
	}
}

public void Math_OnMapStart()
{
	if (gc_bMathSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sMathSoundStopPath);
	}

	if (gc_bMathOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sMathOverlayStopPath);
	}
}

public void Math_OnMapEnd()
{
	g_bIsMathQuiz = false;
	g_bCanAnswer = false;
}

public Action OnChatMessage(int &author, Handle recipients, char [] name, char [] message)
{
	if (g_bIsMathQuiz && g_bCanAnswer && !gp_bChatProcessor)
	{
		if (!IsPlayerAlive(author))
			return Plugin_Continue;

		if (!gc_bAllowCT.BoolValue && GetClientTeam(author) != CS_TEAM_T)
			return Plugin_Continue;

		char bit[1][5];
		ExplodeString(message, " ", bit, sizeof bit, sizeof bit[]);

		if (ProcessSolution(author, StringToInt(bit[0])))
		{
			SendEndMathQuestion(author);
		}
	}

	return Plugin_Continue;
}

public Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if (g_bIsMathQuiz && g_bCanAnswer)
	{
		if (!IsPlayerAlive(author))
			return Plugin_Continue;

		if (!gc_bAllowCT.BoolValue && GetClientTeam(author) != CS_TEAM_T)
			return Plugin_Continue;

		char bit[2][5];
		ExplodeString(message, "{default}", bit, sizeof bit, sizeof bit[]);

		if (ProcessSolution(author, StringToInt(bit[1])))
		{
			SendEndMathQuestion(author);
		}

	}

	return Plugin_Continue;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

public bool ProcessSolution(int client, int number)
{
	if (g_iMathResult == number)
	{
		return true;
	}
	else
	{
		return false;
	}
}

public void SendEndMathQuestion(int client)
{
	if (g_hMathTimer != INVALID_HANDLE)
	{
		KillTimer(g_hMathTimer);
		g_hMathTimer = INVALID_HANDLE;
	}

	char answer[264];

	if (client != -1)
	{
		Format(answer, sizeof(answer), "%s %t", g_sPrefix, "warden_math_correct", client, g_iMathResult);
		CreateTimer(5.0, Timer_RemoveColor, GetClientUserId(client));
		SetEntityRenderColor(client, 0, 255, 0, 255);
	}
	else Format(answer, sizeof(answer), "%s %t", g_sPrefix, "warden_math_time", g_iMathResult);

	if (gc_bMathOverlays.BoolValue)
	{
		ShowOverlayAll(g_sMathOverlayStopPath, 2.0);
	}

	if (gc_bMathSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sMathSoundStopPath);
	}

	Handle pack = CreateDataPack();
	CreateDataTimer(0.3, Timer_AnswerQuestion, pack);
	WritePackString(pack, answer);
	g_bCanAnswer = false;
	g_bIsMathQuiz = false;
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_CreateMathQuestion(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (gc_bMath.BoolValue)
	{
		int NumOne = GetRandomInt(g_iMathMin, g_iMathMax);
		int NumTwo = GetRandomInt(g_iMathMin, g_iMathMax);

		if (gc_bOp.BoolValue) 
		{
			Format(g_sOp, sizeof(g_sOp), g_sOperators[GetRandomInt(0, 3)]);
		}
		else
		{
			Format(g_sOp, sizeof(g_sOp), g_sOperators[GetRandomInt(0, 1)]);
		}

		if (StrEqual(g_sOp, PLUS))
		{
			g_iMathResult = NumOne + NumTwo;
		}
		else if (StrEqual(g_sOp, MINUS))
		{
			g_iMathResult = NumOne - NumTwo;
		}
		else if (StrEqual(g_sOp, DIVISOR))
		{
			do
			{
				NumOne = GetRandomInt(g_iMathMin, g_iMathMax);
				NumTwo = GetRandomInt(g_iMathMin, g_iMathMax);
			}
			while (NumOne % NumTwo != 0);

			g_iMathResult = NumOne / NumTwo;
		}
		else if (StrEqual(g_sOp, MULTIPL))
		{
			g_iMathResult = NumOne * NumTwo;
		}

		CPrintToChatAll("%s %N: %i %s %i = ?? ", g_sPrefix, client, NumOne, g_sOp, NumTwo);

		if (gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%i %s %i = ?? ", NumOne, g_sOp, NumTwo);
		}

		if (!gp_bChatProcessor && !gp_bSimpleChatProcessor)
		{
			CPrintToChatAll("%s Use: sm_math <number>", g_sPrefix);
		}

		g_bCanAnswer = true;

		g_hMathTimer = CreateTimer(gc_iTimeAnswer.FloatValue, Timer_EndMathQuestion);
	}
}

public Action Timer_EndMathQuestion(Handle timer)
{
	SendEndMathQuestion(-1);
}

public Action Timer_AnswerQuestion(Handle timer, Handle pack)
{
	char str[264];
	ResetPack(pack);
	ReadPackString(pack, str, sizeof(str));
	CPrintToChatAll(str);
}
