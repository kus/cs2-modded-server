/* put the line below after all of the includes!
#pragma newdecls required
*/

#include <cstrike>
#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls  required

native bool IsPlayerBannedFromGuardsTeam(int client);
native void LR_FinishTimers(Handle hTimer_Ignore = INVALID_HANDLE);
native void JailBreakDays_StartVoteDay();

#define MAX_INT   2147483647
#define MAX_FLOAT 2147483647.0

#define PLUGIN_VERSION "1.0"

enum enGame
{
	Game_FirstWrites = 0,
	Game_RandomNumber,
	Game_ComboContest,
	Game_RandomPlayer,
	Game_MathContest,
	Game_ElectionDay,
	Game_MAX
};

char GameInfo[Game_MAX][] = {
	"First Writes {VOTE_COUNT}\nRepeat the text on your screen",
	"Random Number {VOTE_COUNT}\nChoose a number between 1-300 and hope to be the closest answer to the chosen number",
	"Combo Contest {VOTE_COUNT}\nRepeat the moves that will appear in your screen to win",
	"Random Player {VOTE_COUNT}\nA random player will become CT automatically",
	"Math Contest {VOTE_COUNT}\nA very easy math question from the multiplication table",
	"Election Day {VOTE_COUNT}\nThe players will vote on who will become CT"
};

char   PREFIX[256];
Handle hcv_Prefix = INVALID_HANDLE;

char GameTitle[Game_MAX][] = {
	"First Writes\nBe the first player to repeat the text to become CT",
	"Random Number\nChoose a number between 1-300, closest result to the chosen number becomes CT",
	"Combo Contest\nRepeat the moves before everybody else to become CT",
	"Random Player\nWould you like to become CT?",
	"Math Contest\nA very easy question from the multiplication table e.g. 9x3",
	"Election Day\nWould you like to become CT?"
};

float ExpireGraceTime = 0.0;

ArrayList g_aCTQueue;
ArrayList g_aWardenQueue;

Handle hVoteCTMenu;
bool   VoteCTDisabled = false, VoteCTRunning;
enGame ChosenGame;
float  VoteCTStart;
float  VoteCTTimeLeft;

Handle hElectionDayMenu;
float  ElectionDayStart;

bool IsPreviewRound, AlreadyDonePreviewRound;

int PreviewRoundTimeLeft;

bool NextRoundSpecialDay;

char GameValue[64];

int MathFirstNumber = 0, MathSecondNumber = 0;

int NumberSelected[MAXPLAYERS + 1];

bool WantsToBeCT[MAXPLAYERS + 1];

int ComboMoves[10], ComboProgress[MAXPLAYERS + 1], LastButtons[MAXPLAYERS + 1];

int votedItem[MAXPLAYERS + 1];

int ComboCount = 6;

char ComboNames[][] = {
	"Attack",
	"Attack2",
	"Jump",
	"Score",
	"Moveleft",
	"Moveright",
	"Forward",
	"Back",
	"Use",
	"Reload",
	"Duck",

	"-- Attack --",
	"-- Attack2 --",
	"-- Jump --",
	"-- Score --",
	"-- Moveleft --",
	"-- Moveright --",
	"-- Forward --",
	"-- Back --",
	"-- Use --",
	"-- Reload --",
	"-- Duck --"
};

int ComboBits[] = { 
	IN_ATTACK,
	IN_ATTACK2,
	IN_JUMP,
	IN_SCORE,
	IN_MOVELEFT,
	IN_MOVERIGHT,
	IN_FORWARD,
	IN_BACK,
	IN_USE,
	IN_RELOAD, 
	IN_DUCK
};

int ChosenUserId;

int  RoundsLeft = 0;
bool NextRoundPreviewRound;

Handle hTimer_StartGame    = INVALID_HANDLE;
Handle hTimer_FailGame     = INVALID_HANDLE;
Handle hTimer_PreviewRound = INVALID_HANDLE;

Handle hcv_VoteCTMin = INVALID_HANDLE;
Handle hcv_WardenSystem = INVALID_HANDLE;

Handle hcv_CTRatio = INVALID_HANDLE;
Handle hcv_CTRatioRebel = INVALID_HANDLE;

Handle hcv_MaxRounds        = INVALID_HANDLE;
Handle hcv_ForbidUnassigned = INVALID_HANDLE;

Handle hcv_PreviewRound = INVALID_HANDLE;
Handle hcv_PreviewRoundOnce = INVALID_HANDLE;
Handle hcv_PreviewRoundTime = INVALID_HANDLE;

Handle hcv_ForcePickTime   = INVALID_HANDLE;
Handle hcv_JoinGraceTime   = INVALID_HANDLE;
Handle hcv_AutoTeamBalance = INVALID_HANDLE;

Handle fw_VoteCTStart     = INVALID_HANDLE;
Handle fw_VoteCTStartAuto = INVALID_HANDLE;
Handle fw_RoundEnd        = INVALID_HANDLE;
Handle fw_SetChosen       = INVALID_HANDLE;

public Plugin myinfo =
{
	name        = "Vote CT",
	author      = "Eyal282",
	description = "Vote-CT",
	version     = PLUGIN_VERSION,
	url         = ""


}

native bool
	SmartOpen_AreCellsOpen();

// returns false if couldn't open cells. Forced may fail if not assigned.
native bool SmartOpen_OpenCells(bool forced, bool isolation);

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Eyal282_VoteCT_StopVoteCT", Native_StopVoteCT);
	CreateNative("Eyal282_VoteCT_IsChosen", Native_IsChosen);
	CreateNative("Eyal282_VoteCT_GetChosenUserId", Native_GetChosenUserId);
	CreateNative("Eyal282_VoteCT_IsTreatedWarden", Native_IsTreatedWarden);
	CreateNative("Eyal282_VoteCT_IsPreviewRound", Native_IsPreviewRound);

	CreateNative("Eyal282_VoteCT_SetChosen", Native_SetChosen);

	return APLRes_Success;
}

public int Native_StopVoteCT(Handle plugin, int numParams)
{
	EndVoteCT();

	return 0;
}

public int Native_IsChosen(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return GetClientOfUserId(ChosenUserId) == client;
}

public int Native_GetChosenUserId(Handle plugin, int numParams)
{
	return ChosenUserId;
}

// Is Treated Warden asks if the client is the warden, but if Vote CT is enabled, all CT are treated as warden ( minus !ctlist and !kickct )
public int Native_IsTreatedWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if(GetClientTeam(client) != CS_TEAM_CT)
		return false;

	if(GetConVarBool(hcv_WardenSystem))
	{
		if(GetClientOfUserId(ChosenUserId) == client)
			return true;

		return false;
	}

	return true;
}
public int Native_IsPreviewRound(Handle plugin, int numParams)
{
	return IsPreviewRound;
}

public int Native_SetChosen(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	SetChosenCT(client);

	EndVoteCT();

	return 0;
}

public void OnPluginStart()
{
	g_aCTQueue = CreateArray(1);
	g_aWardenQueue = CreateArray(1);

	LoadTranslations("common.phrases"); // Fixing errors in target
	
	RegAdminCmd("sm_disablevotect", Command_DisableVoteCT, ADMFLAG_GENERIC);
	RegAdminCmd("sm_votect", Command_VoteCT, ADMFLAG_GENERIC);
	RegAdminCmd("sm_stopvotect", Command_StopVoteCT, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setchosen", Command_SetChosen, ADMFLAG_GENERIC);
	RegConsoleCmd("sm_givechosen", Command_GiveChosen);
	RegConsoleCmd("sm_givect", Command_GiveChosen);
	RegConsoleCmd("sm_givect", Command_GiveChosen);

	RegConsoleCmd("sm_w", Command_Warden);
	RegConsoleCmd("sm_chosen", Command_Chosen);
	RegConsoleCmd("sm_nivhar", Command_Chosen);
	RegConsoleCmd("sm_kickct", Command_KickCT);
	RegConsoleCmd("sm_tlist", Command_TList);
	RegConsoleCmd("sm_ctlist", Command_TList);
	RegConsoleCmd("sm_endpreviewround", Command_EndPreviewRound);
	RegConsoleCmd("sm_egr", Command_EndPreviewRound);
	RegConsoleCmd("sm_epr", Command_EndPreviewRound, "End preview round.");

	AutoExecConfig_SetFile("JB_VoteCT", "sourcemod/JBPack");

	hcv_VoteCTMin        = UC_CreateConVar("votect_min", "2", "Minimum amount of players to start a vote CT. Ignored if Warden system is enabled.");
	hcv_WardenSystem        = UC_CreateConVar("votect_warden_enabled", "0", "Enable Warden System over Vote CT");
	hcv_CTRatio        = UC_CreateConVar("votect_ratio", "6", "Ratio of CT to T");
	hcv_CTRatioRebel        = UC_CreateConVar("votect_ratio", "4", "Ratio of CT to T in maps containing ''_rebel''");

	hcv_MaxRounds        = UC_CreateConVar("votect_max_rounds", "5", "Maximum amount of rounds CT get before swapping");
	hcv_ForbidUnassigned = UC_CreateConVar("votect_forbid_unassigned", "1", "Forbid unassigned players");
	hcv_PreviewRound = 		UC_CreateConVar("votect_preview_round", "0", "If set to 1, T will get a preview round during the first vote CT if 4+ players. Disallowing a preiew round will also disallow Crazy Knife");
	hcv_PreviewRoundOnce = UC_CreateConVar("votect_preview_round_once", "0", "If set to 1, Preview round will only work once per map");
	hcv_PreviewRoundTime = UC_CreateConVar("votect_preview_round_time", "45", "If set to 1, Preview round will only work once per map");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

	// public Eyal282_VoteCT_OnRoundEnd(&ChosenUserId, &RoundsLeft);
	// public Eyal282_VoteCT_OnVoteCTStart(ChosenUserId);
	// public Eyal282_VoteCT_OnSetChosen(ChosenUserId, &NewChosen, &RoundsToPlay)

	fw_RoundEnd        = CreateGlobalForward("Eyal282_VoteCT_OnRoundEnd", ET_Ignore, Param_CellByRef, Param_CellByRef);
	fw_VoteCTStart     = CreateGlobalForward("Eyal282_VoteCT_OnVoteCTStart", ET_Ignore, Param_Cell);
	fw_VoteCTStartAuto = CreateGlobalForward("Eyal282_VoteCT_OnVoteCTStartAutoPre", ET_Event);
	fw_SetChosen       = CreateGlobalForward("Eyal282_VoteCT_OnSetChosen", ET_Ignore, Param_Cell, Param_CellByRef, Param_CellByRef);

	AddCommandListener(Listener_Say, "say");
	AddCommandListener(Listener_JoinTeam, "jointeam");

	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_prestart", Event_RoundStartBeforePlayerSpawn, EventHookMode_PostNoCopy);
	HookEvent("round_freeze_end", Event_RoundFreezeEnd, EventHookMode_PostNoCopy);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);

	hcv_JoinGraceTime   = FindConVar("mp_join_grace_time");
	hcv_ForcePickTime   = FindConVar("mp_force_pick_time");
	hcv_AutoTeamBalance = FindConVar("mp_autoteambalance");

	SetConVarInt(hcv_ForcePickTime, MAX_INT);
	SetConVarBool(hcv_AutoTeamBalance, false);

	HookConVarChange(hcv_ForcePickTime, cvChange_ForcePickTime);
	HookConVarChange(hcv_AutoTeamBalance, cvChange_AutoTeamBalance);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		OnClientPutInServer(i);
	}
}

public void OnAllPluginsLoaded()
{
	hcv_Prefix = FindConVar("sm_prefix_cvar");

	GetConVarString(hcv_Prefix, PREFIX, sizeof(PREFIX));
	HookConVarChange(hcv_Prefix, cvChange_Prefix);

}

// client -> Client index to start the LR.
// String:Message[256] -> Message to send the client if he can't start an LR.
// Handle:hTimer_Ignore -> A timer handle which you're required to insert in LR_FinishTimers()'s first argument if you use it.

// return Plugin_Continue if LR can start, anything higher to disallow.
public Action LastRequest_OnCanStartLR(int client, char Message[256], Handle hTimer_Ignore)
{
	if (IsPreviewRound)
	{
		LR_FinishTimers(hTimer_Ignore);
		Format(Message, sizeof(Message), "\x05You \x01cannot start an \x07LR \x01during Preview Round!");
		return Plugin_Changed;
	}
	else if (VoteCTRunning)
	{
		LR_FinishTimers(hTimer_Ignore);
		Format(Message, sizeof(Message), "\x05You \x01cannot start an \x07LR \x01during a vote CT!");
		return Plugin_Changed;
	}
	else if (IsVoteInProgress())
	{
		LR_FinishTimers(hTimer_Ignore);
		Format(Message, sizeof(Message), "\x05You \x01cannot start an \x07LR \x01during a vote!");
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public void cvChange_Prefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(PREFIX, sizeof(PREFIX), newValue);
}

public void cvChange_ForcePickTime(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (StringToInt(newValue) < MAX_INT)
		SetConVarInt(convar, MAX_INT);
}

public void cvChange_AutoTeamBalance(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (view_as<bool>(StringToInt(newValue)) != false)
		SetConVarBool(convar, false);
}

public void OnMapStart()
{
	VoteCTDisabled = false;
	ChosenUserId   = -1;
	EndVoteCT(INVALID_HANDLE, true);

	CreateTimer(3.0, Timer_CheckVoteCT, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	AlreadyDonePreviewRound = false;

	RoundsLeft = 0;
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if (!VoteCTRunning || ChosenGame != Game_ComboContest || hTimer_StartGame != INVALID_HANDLE)
		return;

	else if (buttons == 0)
		return;

	if (buttons & ComboBits[ComboMoves[ComboProgress[client]]])
	{
		ComboProgress[client]++;

		if (ComboProgress[client] == ComboCount)
		{
			UC_PrintToChatAll("%s  \x05%N \x01won \x07Combo Contest! \x01He becomes CT. ", PREFIX, client);

			EndVoteCT();

			SetChosenCT(client);
		}
	}
	else if (buttons != LastButtons[client])
		ComboProgress[client] = 0;

	LastButtons[client] = buttons;

	ShowComboMenu(client);
}

public Action Timer_CheckVoteCT(Handle hTimer)
{
	int Chosen = GetClientOfUserId(ChosenUserId);

	switch(GetConVarBool(hcv_WardenSystem))
	{
		case true:
		{
			
			int count = GetTeamPlayerCount(CS_TEAM_CT);

			if(count > 0)
			{
				if(GetTeamAliveCount(CS_TEAM_T) <= 1)
					return Plugin_Continue;

				else if(GetGameTime() >= ExpireGraceTime)
					return Plugin_Continue;
			}		

			while(GetAvailableInviteCT() > 0)
			{
				int client = GetNextClientInCTQueue();

				if(client == 0)
				{
					// Not continue, return.
					return Plugin_Continue;
				}

				else if(!TryRemoveClientFromCTQueue(client))
				{
					// Not continue, return on bugs.
					return Plugin_Continue;
				}

				CS_SwitchTeam(client, CS_TEAM_CT);
				CS_RespawnPlayer(client);

				if(count == 0)
				{
					ServerCommand("mp_restartgame 1");
					// To block another restart within the loop.
					count = MAX_INT;
				}
			}

			if(count != MAX_INT && Chosen == 0)
			{
				int client = GetNextClientInWardenQueue();

				if(client == 0)
				{
					// Not continue, return.
					return Plugin_Continue;
				}

				else if(!TryRemoveClientFromWardenQueue(client))
				{
					// Not continue, return on bugs.
					return Plugin_Continue;
				}

				ChosenUserId = GetClientUserId(client);
				AddClientToWardenQueue(client);

				UC_PrintToChatAll("%s \x03%N\x01 is now the Warden of this prison.", PREFIX, client);
			}
		}	
		case false:
		{
			if ((Chosen == 0 || GetClientTeam(Chosen) == CS_TEAM_T) && !VoteCTDisabled && !VoteCTRunning)
			{
				if (GetValidPlayerCount() >= GetConVarInt(hcv_VoteCTMin))
				{
					Action CallReturn;
					Call_StartForward(fw_VoteCTStartAuto);

					Call_Finish(CallReturn);

					if (CallReturn < Plugin_Handled)
					{
						for (int i = 1; i <= MaxClients; i++)
						{
							if (!IsClientInGame(i))
								continue;

							else if (IsPlayerAlive(i))
								continue;

							CS_RespawnPlayer(i);
						}
						StartVoteCT();
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public void OnClientConnected(int client)
{
	NumberSelected[client] = 0;
	WantsToBeCT[client]    = false;
	ComboProgress[client]  = 0;
	LastButtons[client]    = 0;
}

public void OnClientDisconnect(int client)
{
	WantsToBeCT[client] = false;
	votedItem[client]   = -1;
	if (GetClientOfUserId(ChosenUserId) == client)
	{
		ServerCommand("mp_restartgame 1");

		CreateTimer(1.0, Timer_CheckVoteCT, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnClientPutInServer(int client)
{
	if (GetConVarBool(hcv_ForbidUnassigned))
		CreateTimer(15.0, Timer_CheckUnassigned, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public Action Hook_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (VoteCTRunning || IsPreviewRound)
	{
		damage = 0.0;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action Timer_CheckUnassigned(Handle hTimer, int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return Plugin_Continue;

	if (GetClientTeam(client) == CS_TEAM_NONE)
	{
		ClientCommand(client, "jointeam %i", CS_TEAM_SPECTATOR);

		CreateTimer(0.1, JoinTeam_SpectatorCheck, UserId, TIMER_FLAG_NO_MAPCHANGE);    // Another plugin could easily block spectator, let's see if it did.
	}

	return Plugin_Continue;
}

public Action JoinTeam_SpectatorCheck(Handle hTimer, int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return Plugin_Continue;

	else if (GetClientTeam(client) == CS_TEAM_NONE)
		ClientCommand(client, "jointeam %i", CS_TEAM_T);

	return Plugin_Continue;
}

public Action Listener_Say(int client, const char[] command, int args)
{
	if (!VoteCTRunning || GameValue[0] == EOS)
		return Plugin_Continue;

	else if (IsPlayerBannedFromGuardsTeam(client))
	{
		UC_PrintToChat(client, "%s You're \x07banned \x01from \x0BCT, \x01you cannot attempt to win it ", PREFIX);

		return Plugin_Continue;
	}

	char Arg[64];
	GetCmdArg(1, Arg, sizeof(Arg));
	switch (ChosenGame)
	{
		case Game_FirstWrites, Game_MathContest:
		{
			if (StrEqual(Arg, GameValue))
			{
				EndVoteCT();

				SetChosenCT(client);

				if (ChosenGame == Game_FirstWrites)
					UC_PrintToChatAll("%s  \x05%N \x01won \x07First Writes! \x01He becomes CT. ", PREFIX, client);

				else
					UC_PrintToChatAll("%5 \x05%N \x01won \x07Math Contest! \x01He becomes CT. ", PREFIX, client);

				return Plugin_Handled;
			}
		}

		case Game_RandomNumber:
		{
			int number = StringToInt(Arg);

			if (NumberSelected[client] != 0)
			{
				UC_PrintToChat(client, "%s \x05You \x01have already selected a \x05number. ", PREFIX);
				return Plugin_Continue;
			}
			if (number < 1 || number > 300)
			{
				UC_PrintToChat(client, "%s Number is out of \x07allowed \x01range! Choose a number between \x071-300. ", PREFIX);
				return Plugin_Continue;
			}

			bool NumberTaken = false;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				else if (NumberSelected[i] == number)
				{
					NumberTaken = true;
					break;
				}
			}

			if (NumberTaken)
			{
				UC_PrintToChat(client, "%s Number is \x07already \x01taken by another player. ", PREFIX);
				return Plugin_Handled;
			}

			NumberSelected[client] = number;

			UC_PrintToChat(client, "%s \x07Successfully \x01chose \x05%i \x01as your number. ", PREFIX, number);

			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action Listener_JoinTeam(int client, const char[] command, int args)
{
	switch(GetConVarBool(hcv_WardenSystem))
	{
		case true:
		{
			char Arg[32];
			GetCmdArg(1, Arg, sizeof(Arg));

			int Team = StringToInt(Arg);

			// Auto select
			if(Team == CS_TEAM_NONE)
			{
				if(TryRemoveClientFromCTQueue(client))
				{
					UC_PrintToChat(client, "%s You have left the CT queue", PREFIX);
					UC_CloseTeamMenu(client);
					return Plugin_Stop;
				}
			}

			else if(Team != CS_TEAM_SPECTATOR && Team != CS_TEAM_T)
			{
				if(IsClientInCTQueue(client))
				{
					UC_PrintToChat(client, "%s You are #%i in CT queue", PREFIX, GetClientPosInCTQueue(client));
					UC_CloseTeamMenu(client);
					return Plugin_Stop;
				}
				else if(GetClientTeam(client) == CS_TEAM_CT)
				{
					return Plugin_Handled;
				}

				if(AddClientToCTQueue(client))
					UC_PrintToChat(client, "%s You are #%i in CT queue", PREFIX, GetClientPosInCTQueue(client));

				UC_CloseTeamMenu(client);
				return Plugin_Stop;
			}
			else if(Team == CS_TEAM_T)
			{
				TryRemoveClientFromCTQueue(client);
			}

			return Plugin_Continue;
		}
		case false:
		{
			char Arg[32];
			GetCmdArg(1, Arg, sizeof(Arg));

			int Team = StringToInt(Arg);
			if (Team != CS_TEAM_SPECTATOR && Team != CS_TEAM_T)
			{
				ClientCommand(client, "play buttons/button11");

				UC_PrintToChat(client, "%s \x04You \x01can not join this team. ", PREFIX);
				UC_CloseTeamMenu(client);
				return Plugin_Stop;
			}

			return Plugin_Continue;
		}
	}
	
	// Not possible to reach here.
	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (GetClientOfUserId(ChosenUserId) == 0)
		return Plugin_Continue;

	RoundsLeft--;

	Call_StartForward(fw_RoundEnd);

	Call_PushCellRef(ChosenUserId);
	Call_PushCellRef(RoundsLeft);

	Call_Finish();

	if (RoundsLeft <= 0)
	{
		StartVoteCT();

		UC_PrintToChatAll("%s \x01CT's time is over, \x05starting \x01a new \x07Vote-CT. ", PREFIX);

		RoundsLeft = GetConVarInt(hcv_MaxRounds);

		return Plugin_Continue;
	}

	else if (RoundsLeft == 1)
	{
		NextRoundSpecialDay = true;
	}

	IsPreviewRound = false;
	UC_PrintToChatAll("%s \x05Vote-CT \x01will start in \x07%i \x01round%s. ", PREFIX, RoundsLeft, RoundsLeft == 1 ? "" : "s");

	return Plugin_Continue;
}

public Action Event_RoundStart(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	IsPreviewRound  = false;
	ExpireGraceTime = MAX_FLOAT;

	if (NextRoundSpecialDay)
	{
		StartVoteDay();
	}
	else if (GetConVarBool(hcv_PreviewRound) && NextRoundPreviewRound && (!AlreadyDonePreviewRound || !GetConVarBool(hcv_PreviewRoundOnce)))
	{
		IsPreviewRound = true;

		ServerCommand("sm_hardopen");

		LR_FinishTimers();

		PreviewRoundTimeLeft = GetConVarInt(hcv_PreviewRoundTime);

		hTimer_PreviewRound = CreateTimer(1.0, Timer_CheckPreviewRound, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		// Color
		UC_PrintToChatAll("%s Preview Round has started. It will \x05end \x01in \x07%i seconds. ", PREFIX, GetConVarInt(hcv_PreviewRoundTime));

		AlreadyDonePreviewRound = true;
	}

	NextRoundPreviewRound = false;
	NextRoundSpecialDay   = false;

	return Plugin_Continue;
}

public Action Event_RoundStartBeforePlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{	
	ExpireGraceTime = MAX_FLOAT;

	if(GetConVarBool(hcv_WardenSystem))
	{
		ChosenUserId = 0;
	}

	TriggerTimer(CreateTimer(0.0, Timer_CheckVoteCT, _, TIMER_FLAG_NO_MAPCHANGE));

	return Plugin_Continue;
}

void StartVoteDay()
{
	EndVoteCT();

	if (!IsNewVoteAllowed())
		return;

	JailBreakDays_StartVoteDay();
}

public Action Timer_CheckPreviewRound(Handle hTimer)
{
	if (!IsPreviewRound)
	{
		hTimer_PreviewRound = INVALID_HANDLE;

		return Plugin_Stop;
	}
	PreviewRoundTimeLeft--;
	if (PreviewRoundTimeLeft <= 0)
	{
		ServerCommand("mp_restartgame 1");

		IsPreviewRound = false;

		hTimer_PreviewRound = INVALID_HANDLE;

		return Plugin_Stop;
	}
	else
	{
		SetHudTextParams(0.3, 0.2, 1.0, 255, 0, 0, 255, 0, 0.0, 0.0, 0.0);
		ShowHudTextAll(2, "Preview round will end in %i seconds.", PreviewRoundTimeLeft);

		return Plugin_Continue;
	}
}

public Action Event_RoundFreezeEnd(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	ExpireGraceTime = GetGameTime() + GetConVarFloat(hcv_JoinGraceTime);

	return Plugin_Continue;
}

public Action Event_PlayerTeam(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int UserId  = GetEventInt(hEvent, "userid");
	int NewTeam = GetEventInt(hEvent, "team");
	int client  = GetClientOfUserId(UserId);

	if (NewTeam == CS_TEAM_SPECTATOR && client != 0)
		ForcePlayerSuicide(client);

	if (NewTeam != CS_TEAM_CT && UserId == ChosenUserId && UserId != 0)
		ChosenUserId = 0;

	if (ChosenUserId == 0)
	{
		CreateTimer(1.0, Timer_CheckVoteCT, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	if (ChosenGame == Game_ComboContest && (NewTeam == CS_TEAM_CT || NewTeam == CS_TEAM_T))
	{
		if (client != 0)
			CS_RespawnPlayer(client);
	}

	return Plugin_Continue;
}


public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int UserId  = GetEventInt(hEvent, "userid");

	if (GetConVarBool(hcv_WardenSystem) && UserId == ChosenUserId && UserId != 0)
		ChosenUserId = 0;

	if (ChosenUserId == 0)
	{
		TriggerTimer(CreateTimer(0.0, Timer_CheckVoteCT, _, TIMER_FLAG_NO_MAPCHANGE));
	}

	return Plugin_Continue;
}


public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int UserId = GetEventInt(hEvent, "userid");

	if (UserId == ChosenUserId && UserId != 0)
	{
		int client = GetClientOfUserId(UserId);

		if (GetClientTeam(client) != CS_TEAM_CT)
			return Plugin_Continue;

		else if (GetAvailableInviteCT() > 0 && GetConVarBool(hcv_WardenSystem))
			Command_TList(client, 0);
	}

	return Plugin_Continue;
}

public Action Command_KickCT(int client, int args)
{
	if(GetConVarBool(hcv_WardenSystem))
		return Plugin_Handled;

	int Chosen = GetClientOfUserId(ChosenUserId);

	if (client != Chosen)
	{
		UC_PrintToChat(client, "%s \x05You \x01are not the chosen \x07CT. ", PREFIX);

		return Plugin_Handled;
	}

	else if (SmartOpen_AreCellsOpen())
	{
		// BAR COLOR
		UC_ReplyToCommand(client, "Error: You cannot kick CT when cells are open");

		return Plugin_Handled;
	}

	Handle hMenu = CreateMenu(KickCT_MenuHandler);
	char   sUserId[11];

	SetMenuTitle(hMenu, "Select a CT to kick from your team into T:");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (client == i)
			continue;

		else if (GetClientTeam(i) != CS_TEAM_CT)
			continue;

		char Name[64];
		IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
		GetClientName(i, Name, sizeof(Name));
		AddMenuItem(hMenu, sUserId, Name);
	}

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int KickCT_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		char sUserId[11];
		GetMenuItem(hMenu, item, sUserId, sizeof(sUserId));

		int target = GetClientOfUserId(StringToInt(sUserId));

		int Chosen = GetClientOfUserId(ChosenUserId);

		if (Chosen != client)
			return 0;

		if (target == 0 || GetClientTeam(target) != CS_TEAM_CT)
		{
			UC_PrintToChat(client, "%s \x01Target player is not \x05connected. ", PREFIX);

			return 0;
		}

		CS_SwitchTeam(target, CS_TEAM_T);

		if (GetGameTime() < ExpireGraceTime)
			CS_RespawnPlayer(target);

		else
			ForcePlayerSuicide(target);
	}

	return 0;
}

public Action Command_TList(int client, int args)
{
	if(GetConVarBool(hcv_WardenSystem))
		return Plugin_Handled;
		
	int Chosen = GetClientOfUserId(ChosenUserId);

	if (client != Chosen)
	{
		UC_PrintToChat(client, "%s \x05You \x01are not the chosen \x07CT. ", PREFIX);

		return Plugin_Handled;
	}

	else if (GetAvailableInviteCT() == 0)
	{
		UC_PrintToChat(client, "%s \x01There are not enough terrorists to bring another \x07CT. ", PREFIX);

		return Plugin_Handled;
	}

	Handle hMenu = CreateMenu(TList_MenuHandler);
	char   sUserId[11];

	SetMenuTitle(hMenu, "Select a T to invite to become a CT:");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (client == i)
			continue;

		else if (GetClientTeam(i) != CS_TEAM_T)
			continue;

		if (IsPlayerBannedFromGuardsTeam(i))
		{
			char Name[64];
			IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
			GetClientName(i, Name, sizeof(Name));

			Format(Name, sizeof(Name), "%s [BANNED]", Name);
			AddMenuItem(hMenu, sUserId, Name, ITEMDRAW_DISABLED);
		}
		else
		{
			char Name[64];
			IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
			GetClientName(i, Name, sizeof(Name));
			AddMenuItem(hMenu, sUserId, Name);
		}
	}

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int TList_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		char sUserId[11];
		GetMenuItem(hMenu, item, sUserId, sizeof(sUserId));

		int target = GetClientOfUserId(StringToInt(sUserId));

		int Chosen = GetClientOfUserId(ChosenUserId);

		if (Chosen != client)
			return 0;

		if (target == 0 || GetClientTeam(target) != CS_TEAM_T || IsPlayerBannedFromGuardsTeam(target))
		{
			UC_PrintToChat(client, "%s \x01Target player is not \x05connected. ", PREFIX);

			return 0;
		}

		ShowAcceptInviteMenu(target);
	}

	return 0;
}

public Action Command_EndPreviewRound(int client, int args)
{
	int Chosen = GetClientOfUserId(ChosenUserId);

	if (client != 0 && client != Chosen && !CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC))
	{
		UC_ReplyToCommand(client, "%s \x05You \x01are not the chosen \x07CT. ", PREFIX);

		return Plugin_Handled;
	}

	else if (!IsPreviewRound)
	{
		UC_ReplyToCommand(client, "%s \x01Preview round is not \x07Active!", PREFIX);

		return Plugin_Handled;
	}

	ServerCommand("mp_restartgame 1");

	IsPreviewRound = false;

	return Plugin_Handled;
}

public void ShowAcceptInviteMenu(int client)
{
	Handle hMenu = CreateMenu(AcceptInvite_MenuHandler);

	SetMenuTitle(hMenu, "You were invited by %N to join the CT team. Accept the invite?", GetClientOfUserId(ChosenUserId));

	AddMenuItem(hMenu, "", "Yes");
	AddMenuItem(hMenu, "", "No");

	DisplayMenu(hMenu, client, 10);
}

public int AcceptInvite_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (GetClientTeam(client) != CS_TEAM_T)
			return 0;

		else if (item != 0)
			return 0;

		else if (GetAvailableInviteCT() == 0)
			return 0;

		else if (IsPlayerBannedFromGuardsTeam(client))
		{
			UC_PrintToChat(client, "%s \x01You're \x07banned \x01from \x05CT ", PREFIX);
			return 0;
		}

		CS_SwitchTeam(client, CS_TEAM_CT);

		if (GetGameTime() < ExpireGraceTime)
			CS_RespawnPlayer(client);

		else
			ForcePlayerSuicide(client);
	}

	return 0;
}

public Action Command_Chosen(int client, int args)
{
	int Chosen = GetClientOfUserId(ChosenUserId);

	if (Chosen == 0)
	{
		UC_PrintToChat(client, "%s \x01There is no chosen \x05CT. ", PREFIX);

		return Plugin_Handled;
	}

	UC_PrintToChat(client, "%s \x01The chosen CT is \x05%N ", PREFIX, Chosen);

	return Plugin_Handled;
}

public Action Command_DisableVoteCT(int client, int args)
{
	if (VoteCTDisabled)
	{
		UC_ReplyToCommand(client, "%s \x05Vote-CT \x01system is already \x07disabled. ", PREFIX);
		return Plugin_Handled;
	}

	UC_PrintToChatAll("%s \x05%N \x01has disabled \x07Vote CT \x01system. ", PREFIX, client);

	VoteCTDisabled = true;
	VoteCTRunning  = false;

	if (hTimer_StartGame != INVALID_HANDLE)
	{
		CloseHandle(hTimer_StartGame);
		hTimer_StartGame = INVALID_HANDLE;
	}

	if (hTimer_FailGame != INVALID_HANDLE)
	{
		CloseHandle(hTimer_FailGame);
		hTimer_FailGame = INVALID_HANDLE;
	}

	return Plugin_Handled;
}

public Action Command_VoteCT(int client, int args)
{
	if(GetConVarBool(hcv_WardenSystem))
		return Plugin_Handled;

	if (!IsNewVoteAllowed())
	{
		EndVoteCT();

		UC_PrintToChat(client, "A vote is already in progress, try !cancelvote to stop it.");
		return Plugin_Handled;
	}
	VoteCTDisabled = false;

	StartVoteCT();

	UC_PrintToChatAll("%s \x05%N \x01started a \x07Vote CT. ", PREFIX, client);

	return Plugin_Handled;
}

public Action Command_StopVoteCT(int client, int args)
{
	if (!VoteCTRunning)
	{
		UC_ReplyToCommand(client, "There isn't a running Vote-CT.");
		return Plugin_Handled;
	}

	UC_PrintToChatAll("%s \x05%N \x01stopped current \x07Vote CT.", PREFIX, client);

	EndVoteCT();

	return Plugin_Handled;
}

public Action Command_SetChosen(int client, int args)
{
	if(GetConVarBool(hcv_WardenSystem))
		return Plugin_Handled;

	if (args == 0)
	{
		UC_ReplyToCommand(client, "Usage: sm_setchosen <target>");
		return Plugin_Handled;
	}
	char Arg[64];
	GetCmdArgString(Arg, sizeof(Arg));

	int target = FindTarget(client, Arg, false, false);

	if (target == -1)
		return Plugin_Handled;

	EndVoteCT();

	SetChosenCT(target);

	UC_PrintToChatAll("%s \x05%N \x01set the new chosen CT as \x07%N! ", PREFIX, client, target);
	return Plugin_Handled;
}

public Action Command_GiveChosen(int client, int args)
{
	if(GetConVarBool(hcv_WardenSystem))
		return Plugin_Handled;

	else if (args == 0)
	{
		UC_ReplyToCommand(client, "Usage: sm_givect <target>");
		return Plugin_Handled;
	}

	else if (SmartOpen_AreCellsOpen())
	{
		// BAR COLOR
		UC_ReplyToCommand(client, "Error: You cannot give chosen CT when cells are open");

		return Plugin_Handled;
	}

	int Chosen = GetClientOfUserId(ChosenUserId);

	if (client != Chosen)
	{
		UC_PrintToChat(client, "%s \x05You \x01are not the chosen \x07CT. ", PREFIX);

		return Plugin_Handled;
	}

	char Arg[64];
	GetCmdArgString(Arg, sizeof(Arg));

	int target = FindTarget(client, Arg, false, false);

	if (target == -1)
		return Plugin_Handled;

	EndVoteCT();

	SetChosenCT(target, false, true);

	UC_PrintToChatAll("%s \x05%N \x01gave the chosen CT to \x07%N! ", PREFIX, client, target);
	return Plugin_Handled;
}

public Action Command_Warden(int client, int args)
{
	if(!GetConVarBool(hcv_WardenSystem))
		return Plugin_Handled;

	else if(client == 0)
		return Plugin_Handled;

	else if(GetClientTeam(client) != CS_TEAM_CT)
	{
		int Chosen = GetClientOfUserId(ChosenUserId);

		if(Chosen == 0)
			UC_PrintToChat(client, "%s There is no current warden.", PREFIX);

		else
			UC_PrintToChat(client, "%s The current warden is\x03 %N", PREFIX, Chosen);
	}
	else
	{
		int Chosen = GetClientOfUserId(ChosenUserId);

		if(client == Chosen)
		{
			UC_PrintToChatAll("%s \x03%N\x01 resigned as the warden.", PREFIX, client);
		}
		else
		{
			if(AddClientToWardenQueue(client))
			{
				UC_PrintToChat(client, "%s You are #%i in Warden queue.", PREFIX, GetClientPosInWardenQueue(client));
			}
			else
			{
				UC_PrintToChat(client, "%s You left the Warden queue.", PREFIX);
			}
		}

	}

	return Plugin_Handled;
}
void StartVoteCT()
{
	if (!IsNewVoteAllowed() || NextRoundSpecialDay)
		return;

	Call_StartForward(fw_VoteCTStart);

	Call_PushCell(ChosenUserId);
	Call_Finish();

	EndVoteCT();

	ServerCommand("sm_hardopen");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) == CS_TEAM_CT)
		{
			ChangeClientTeam(i, CS_TEAM_T);
			CS_RespawnPlayer(i);
		}
	}

	GameValue[0]  = EOS;
	VoteCTRunning = true;
	ChosenGame    = Game_MAX;

	RoundsLeft = GetConVarInt(hcv_MaxRounds);

	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		NumberSelected[i] = 0;
		WantsToBeCT[i]    = false;
		ComboProgress[i]  = 0;
		LastButtons[i]    = 0;
	}

	VoteCTStart = GetGameTime();

	BuildUpVoteCTMenu();

	VoteMenuToAll(hVoteCTMenu, 15);

	CreateTimer(1.0, Timer_DrawVoteCTMenu, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

public Action Timer_DrawVoteCTMenu(Handle hTimer)
{
	if (RoundToFloor((VoteCTStart + 15) - GetGameTime()) <= 0)
		return Plugin_Stop;

	else if (!VoteCTRunning)
		return Plugin_Stop;

	BuildUpVoteCTMenu();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsVoteInProgress() || !IsClientInVotePool(i))
			continue;

		RedrawClientVoteMenu(i);
	}

	return Plugin_Continue;
}

void BuildUpVoteCTMenu()
{
	if (hVoteCTMenu == INVALID_HANDLE)
		hVoteCTMenu = CreateMenu(VoteCT_VoteHandler);

	SetMenuTitle(hVoteCTMenu, "Choose how the CT will be chosen: [%i]", RoundFloat((VoteCTStart + 15) - GetGameTime()));

	RemoveAllMenuItems(hVoteCTMenu);

	int VoteList[MAXPLAYERS + 1];

	VoteList = CalculateVotes();

	char TempFormat[128], replace[16];

	for (int i = 0; i < sizeof(GameInfo); i++)
	{
		FormatEx(TempFormat, sizeof(TempFormat), "%s", GameInfo[i]);

		FormatEx(replace, sizeof(replace), "[%i]", VoteList[i]);

		ReplaceStringEx(TempFormat, sizeof(TempFormat), "{VOTE_COUNT}", replace);
		AddMenuItem(hVoteCTMenu, "", TempFormat);
	}

	SetMenuPagination(hVoteCTMenu, MENU_NO_PAGINATION);
}

public int VoteCT_VoteHandler(Handle hMenu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hMenu);
		hVoteCTMenu = INVALID_HANDLE;
	}
	else if (action == MenuAction_VoteCancel)
	{
		if (param1 == VoteCancel_NoVotes)
		{
			CheckVoteCTResult();
		}
	}
	else if (action == MenuAction_VoteEnd)
	{
		if (!VoteCTRunning)
			return 0;

		CheckVoteCTResult();
	}
	else if (action == MenuAction_Select)
	{
		votedItem[param1] = param2;
	}

	return 0;
}

void CheckVoteCTResult()
{
	int VoteList[MAXPLAYERS + 1];

	VoteList = CalculateVotes();

	ChosenGame = Game_MAX;

	for (int i = 0; i < view_as<int>(Game_MAX); i++)
	{
		if (VoteList[i] > 0 && (VoteList[i] > VoteList[ChosenGame] || (VoteList[i] == VoteList[ChosenGame] && GetRandomInt(0, 1) == 1)))
			ChosenGame = view_as<enGame>(i);
	}

	// 0 Votes.
	if (ChosenGame == Game_MAX)
	{
		EndVoteCT();
		return;
	}

	if (ChosenGame == Game_RandomNumber)
		IntToString(GetRandomInt(1, 300), GameValue, sizeof(GameValue));

	else if (ChosenGame == Game_ComboContest)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			if (!IsValidTeam(i))
				continue;

			CS_RespawnPlayer(i);
		}
	}
	VoteCTTimeLeft = 15.0;

	StartGameTimer();
}

void StartGameTimer()
{
	hTimer_StartGame = CreateTimer(0.1, Timer_StartGame, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	for (int i = 1; i <= MaxClients; i++)    // Announce them that they're banned, which may cause confusion otherwise.
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerBannedFromGuardsTeam(i))
			continue;

		UC_PrintToChat(i, "%s You're \x07banned \x01from CT. You won't be able to participate.", PREFIX);
	}
}

public Action Timer_StartGame(Handle hTimer)
{
	VoteCTTimeLeft -= 0.1;

	if (VoteCTTimeLeft > 0.0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			char TempFormat[256];

			switch (ChosenGame)
			{
				case Game_FirstWrites:
				{
					Handle hMenu = CreateMenu(dummyvalue_MenuHandler);

					SetMenuTitle(hMenu, GameTitle[ChosenGame]);

					FormatEx(TempFormat, sizeof(TempFormat), "The First Writes game will start in %.1f seconds", VoteCTTimeLeft);

					AddMenuItem(hMenu, "", TempFormat);

					DisplayMenu(hMenu, i, 1);
				}
				case Game_RandomNumber:
				{
					Handle hMenu = CreateMenu(dummyvalue_MenuHandler);

					SetMenuTitle(hMenu, GameTitle[ChosenGame]);

					FormatEx(TempFormat, sizeof(TempFormat), "The Random Number game will end in %.1f seconds.\nType a number between 1-300.", VoteCTTimeLeft);

					AddMenuItem(hMenu, "", TempFormat);

					DisplayMenu(hMenu, i, 1);
				}

				case Game_ComboContest:
				{
					Handle hMenu = CreateMenu(dummyvalue_MenuHandler);

					SetMenuTitle(hMenu, GameTitle[ChosenGame]);

					FormatEx(TempFormat, sizeof(TempFormat), "The Combo Contest game will start in %.1f seconds", VoteCTTimeLeft);

					AddMenuItem(hMenu, "", TempFormat);

					DisplayMenu(hMenu, i, 1);
				}
				case Game_RandomPlayer:
				{
					Handle hMenu = CreateMenu(RandomPlayer_MenuHandler);

					SetMenuTitle(hMenu, GameTitle[ChosenGame]);

					FormatEx(TempFormat, sizeof(TempFormat), "Yes%s", WantsToBeCT[i] ? " ☆" : "");
					AddMenuItem(hMenu, "", TempFormat);

					FormatEx(TempFormat, sizeof(TempFormat), "No%s\nThe Random Player will be selected in %.1f seconds.", !WantsToBeCT[i] ? " ☆" : "", VoteCTTimeLeft);
					AddMenuItem(hMenu, "", TempFormat);

					DisplayMenu(hMenu, i, 1);
				}

				case Game_MathContest:
				{
					Handle hMenu = CreateMenu(dummyvalue_MenuHandler);

					SetMenuTitle(hMenu, GameTitle[ChosenGame]);

					FormatEx(TempFormat, sizeof(TempFormat), "The Math Contest game will start in %.1f seconds", VoteCTTimeLeft);

					AddMenuItem(hMenu, "", TempFormat);

					DisplayMenu(hMenu, i, 1);
				}

				case Game_ElectionDay:
				{
					Handle hMenu = CreateMenu(RandomPlayer_MenuHandler);    // Can have the same callbacks due to identical answers.

					SetMenuTitle(hMenu, GameTitle[ChosenGame]);

					FormatEx(TempFormat, sizeof(TempFormat), "Yes%s", WantsToBeCT[i] ? " ☆" : "");
					AddMenuItem(hMenu, "", TempFormat);

					FormatEx(TempFormat, sizeof(TempFormat), "No%s\nThe Elections will be held in %.1f seconds.", !WantsToBeCT[i] ? " ☆" : "", VoteCTTimeLeft);
					AddMenuItem(hMenu, "", TempFormat);

					DisplayMenu(hMenu, i, 1);
				}
			}
		}
	}
	else
	{
		StartGame(hTimer_StartGame);

		hTimer_StartGame = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public int dummyvalue_MenuHandler(Handle hMenu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	return 0;
}

public int RandomPlayer_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (IsPlayerBannedFromGuardsTeam(client))
		{
			UC_PrintToChat(client, "%s You're \x07banned \x01from CT, you cannot attempt to win it", PREFIX);

			return 0;
		}
		if (item == 0)
			WantsToBeCT[client] = true;

		else if (item == 1)
			WantsToBeCT[client] = false;
	}

	return 0;
}

void StartGame(Handle hTimer_Ignore)
{
	char TempFormat[128];

	switch (ChosenGame)
	{
		case Game_FirstWrites:
		{
			FormatEx(GameValue, sizeof(GameValue), "%i%i%i%i%i%i%i%i%i", GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9), GetRandomInt(0, 9));

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				Handle hMenu = CreateMenu(dummyvalue_MenuHandler);

				Format(TempFormat, sizeof(TempFormat), "The random combination of numbers is: %s", GameValue);
				AddMenuItem(hMenu, "", TempFormat);

				DisplayMenu(hMenu, i, 20);
			}

			hTimer_FailGame = CreateTimer(20.0, Timer_FailGame, _, TIMER_FLAG_NO_MAPCHANGE);
		}

		case Game_RandomNumber:
		{
			int WinningNumber = StringToInt(GameValue);

			int winner, MultipleWinners[2], MultipleWinnersNum = 0;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				else if (NumberSelected[i] == 0)
					continue;

				if (winner == 0)
				{
					winner                              = i;
					MultipleWinners[MultipleWinnersNum] = i;
					MultipleWinnersNum++;
				}

				else if (Abs(NumberSelected[i] - WinningNumber) < Abs(NumberSelected[winner] - WinningNumber))
				{
					NumberSelected[0] = 0;
					NumberSelected[1] = 0;

					MultipleWinnersNum = 0;
					winner             = i;

					MultipleWinners[MultipleWinnersNum++] = i;
				}

				else if (Abs(NumberSelected[i] - WinningNumber) == Abs(NumberSelected[winner] - WinningNumber))
					MultipleWinners[MultipleWinnersNum++] = i;
			}

			if (MultipleWinnersNum > 1)
			{
				UC_PrintToChatAll("%s \x05%N \x01and \x05%N \x01both won, picking the numbers \x07%i \x01and \x07%i. \x01Selecting a random winner... ", PREFIX, MultipleWinners[0], MultipleWinners[1], NumberSelected[MultipleWinners[0]], NumberSelected[MultipleWinners[1]]);
				winner = MultipleWinners[GetRandomInt(0, 1)];
			}

			EndVoteCT(hTimer_Ignore);

			if (winner == 0)
			{
				SetChosenCT(0);

				UC_PrintToChatAll("%s Nobody won the \x07Random Number \x01game, as nobody chose a number. ", PREFIX);

				ServerCommand("mp_restartgame 1");
			}
			else
			{
				SetChosenCT(winner);

				UC_PrintToChatAll("%s \x05%N won \x07Random Number! \x01He becomes CT. His number was \x07%i, \x01with the random number being \x07%i. ", PREFIX, winner, NumberSelected[winner], WinningNumber);
			}
		}

		case Game_ComboContest:
		{
			Handle NoRepeatRNG = CreateArray(1);

			for (int i = 0; i < sizeof(ComboBits); i++)
				PushArrayCell(NoRepeatRNG, i);

			for (int i = 0; i < ComboCount; i++)
			{
				int pos = GetRandomInt(0, GetArraySize(NoRepeatRNG) - 1);

				ComboMoves[i] = GetArrayCell(NoRepeatRNG, pos);
				RemoveFromArray(NoRepeatRNG, pos);
			}

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				ShowComboMenu(i);
			}

			hTimer_FailGame = CreateTimer(40.0, Timer_FailGame, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		case Game_RandomPlayer:
		{
			int clients[MAXPLAYERS + 1], count;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				else if (WantsToBeCT[i])
					clients[count++] = i;
			}

			if (count == 0)
			{
				UC_PrintToChatAll("%s Nobody won the \x07Random Player, \x01as nobody wanted to win. ", PREFIX);

				ServerCommand("mp_restartgame 1");

				EndVoteCT(hTimer_Ignore);

				return;
			}
			EndVoteCT(hTimer_Ignore);

			int winner = clients[GetRandomInt(0, count - 1)];

			if (winner == 0)
			{
				UC_PrintToChatAll("%s Nobody won the \x07Random Player, \x01as nobody wanted to win. ", PREFIX);

				ServerCommand("mp_restartgame 1");

				return;
			}

			SetChosenCT(winner);

			UC_PrintToChatAll("%s \x05%N \x01was selected as the \x07Random Player! \x01He becomes CT. ", PREFIX, winner);
		}

		case Game_MathContest:
		{
			MathFirstNumber  = GetRandomInt(1, 10);
			MathSecondNumber = GetRandomInt(1, 10);
			IntToString((MathFirstNumber * MathSecondNumber), GameValue, sizeof(GameValue));

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				Handle hMenu = CreateMenu(dummyvalue_MenuHandler);

				Format(TempFormat, sizeof(TempFormat), "Solve to become CT: %i x %i = ???", MathFirstNumber, MathSecondNumber);
				AddMenuItem(hMenu, "", TempFormat);

				DisplayMenu(hMenu, i, 20);
			}

			hTimer_FailGame = CreateTimer(20.0, Timer_FailGame, _, TIMER_FLAG_NO_MAPCHANGE);
		}

		case Game_ElectionDay:
		{
			int candidates[MAXPLAYERS + 1], candidateCount;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				else if (WantsToBeCT[i])
					candidates[candidateCount++] = i;
			}

			if (candidateCount == 0)
			{
				EndVoteCT(hTimer_Ignore);

				SetChosenCT(0);

				UC_PrintToChatAll(" %s \x01Nobody won the \x07Election Day, \x01as nobody wanted to win. ", PREFIX);

				ServerCommand("mp_restartgame 1");

				return;
			}
			else if (candidateCount == 1)
			{
				EndVoteCT(hTimer_Ignore);

				int winner = candidates[0];

				// BAR COLOR
				UC_PrintToChatAll(" %s \x04%N \x01won the \x07Election Day, \x01as he was the only participant that wanted to \x05win. ", PREFIX, winner);

				SetChosenCT(winner);

				return;
			}

			for (int i = 1; i <= MaxClients; i++)
			{
				votedItem[i] = -1;
			}

			ElectionDayStart = GetGameTime();

			BuildUpElectionDayMenu();

			VoteMenuToAll(hElectionDayMenu, 20);

			CreateTimer(1.0, Timer_DrawElectionDayMenu, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		}
	}
}

public Action Timer_DrawElectionDayMenu(Handle hTimer)
{
	if (RoundToFloor((ElectionDayStart + 20) - GetGameTime()) <= 0)
		return Plugin_Stop;

	else if (!VoteCTRunning)
		return Plugin_Stop;

	BuildUpElectionDayMenu();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsClientInVotePool(i))
			continue;

		RedrawClientVoteMenu(i);
	}

	return Plugin_Continue;
}

void BuildUpElectionDayMenu()
{
	if (hElectionDayMenu == INVALID_HANDLE)
		hElectionDayMenu = CreateMenu(ElectionDay_VoteHandler);

	SetMenuTitle(hElectionDayMenu, "Choose who will become CT: [%i]", RoundFloat((ElectionDayStart + 20) - GetGameTime()));

	RemoveAllMenuItems(hElectionDayMenu);

	int VoteList[MAXPLAYERS + 1];

	VoteList = CalculateVotes();

	char TempFormat[128];

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!WantsToBeCT[i])
			continue;

		char Name[64], sUserId[11];
		GetClientName(i, Name, sizeof(Name));
		FormatEx(TempFormat, sizeof(TempFormat), "%s [%i]", Name, VoteList[i]);
		IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));

		AddMenuItem(hElectionDayMenu, sUserId, TempFormat);
	}

	SetMenuPagination(hElectionDayMenu, MENU_NO_PAGINATION);
}

public int ElectionDay_VoteHandler(Handle hMenu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hMenu);
		hElectionDayMenu = INVALID_HANDLE;
	}
	else if (action == MenuAction_VoteCancel)
	{
		if (param1 == VoteCancel_NoVotes)
		{
			CheckElectionDayResult();
		}
	}
	else if (action == MenuAction_VoteEnd)
	{
		if (!VoteCTRunning)
			return 0;

		CheckElectionDayResult();
	}
	else if (action == MenuAction_Select)
	{
		char sUserId[11];
		GetMenuItem(hMenu, param2, sUserId, sizeof(sUserId));

		int target = GetClientOfUserId(StringToInt(sUserId));

		if (target == 0)
			votedItem[param1] = -1;

		else
			votedItem[param1] = target;
	}

	return 0;
}

void CheckElectionDayResult()
{
	int VoteList[MAXPLAYERS + 1];

	VoteList = CalculateVotes();

	int winner = 0;

	for (int i = 1; i <= MaxClients + 1; i++)
	{
		if (!WantsToBeCT[i])
			continue;

		else if (VoteList[i] > 0 && (VoteList[i] > VoteList[winner] || (VoteList[i] == VoteList[winner] && GetRandomInt(0, 1) == 1)))
			winner = i;
	}

	// 0 Votes.
	if (winner == 0)
	{
		EndVoteCT();

		SetChosenCT(0);

		// BAR COLOR
		UC_PrintToChatAll(" \x01No votes were casted at \x07all, \x01not even someone voting for \x05himself...");

		return;
	}

	EndVoteCT();

	UC_PrintToChatAll("%s \x05%N \x01was elected in \x07Election Day! \x01He becomes CT. ", PREFIX, winner);

	SetChosenCT(winner);
}

public Action Timer_FailGame(Handle hTimer)
{
	hTimer_FailGame = INVALID_HANDLE;

	SetChosenCT(0);

	// BAR COLOR
	UC_PrintToChatAll(" \x01Nobody won the \x05Vote CT! \x01Picking another game...");

	EndVoteCT(hTimer_FailGame);

	return Plugin_Continue;
}

public void ShowComboMenu(int client)
{
	Handle hMenu = CreateMenu(dummyvalue_MenuHandler);

	SetMenuTitle(hMenu, GameTitle[Game_ComboContest]);

	for (int i = 0; i < ComboCount; i++)
	{
		if (ComboProgress[client] == i)
			AddMenuItem(hMenu, "", ComboNames[ComboMoves[i] + sizeof(ComboBits)]);

		else
			AddMenuItem(hMenu, "", ComboNames[ComboMoves[i]]);
	}
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

void EndVoteCT(Handle hTimer_Ignore = INVALID_HANDLE, bool MapStart = false)
{
	GameValue[0]  = EOS;
	VoteCTRunning = false;

	for (int i = 0; i < sizeof(WantsToBeCT); i++)
	{
		WantsToBeCT[i] = false;
		votedItem[i]   = -1;
	}

	if (MapStart)
	{
		hTimer_StartGame    = INVALID_HANDLE;
		hTimer_FailGame     = INVALID_HANDLE;
		hTimer_PreviewRound = INVALID_HANDLE;
		hVoteCTMenu         = INVALID_HANDLE;
	}
	else
	{
		if (hTimer_StartGame != INVALID_HANDLE && hTimer_StartGame != hTimer_Ignore)
		{
			CloseHandle(hTimer_StartGame);
			hTimer_StartGame = INVALID_HANDLE;
		}

		if (hTimer_FailGame != INVALID_HANDLE && hTimer_FailGame != hTimer_Ignore)
		{
			CloseHandle(hTimer_FailGame);
			hTimer_FailGame = INVALID_HANDLE;
		}

		if (hTimer_PreviewRound != INVALID_HANDLE && hTimer_PreviewRound != hTimer_Ignore)
		{
			CloseHandle(hTimer_PreviewRound);
			hTimer_PreviewRound = INVALID_HANDLE;
		}

		if (hVoteCTMenu != INVALID_HANDLE)
		{
			CancelMenu(hVoteCTMenu);
			hVoteCTMenu = INVALID_HANDLE;
		}
	}
}

stock void SetChosenCT(int client, bool dontKickCT = false, bool swapped = false)
{
	if (client != 0)
	{
		if (!swapped)
			RoundsLeft = GetConVarInt(hcv_MaxRounds);

		Call_StartForward(fw_SetChosen);

		Call_PushCell(ChosenUserId);

		Call_PushCellRef(client);
		Call_PushCellRef(RoundsLeft);

		Call_Finish();
	}
	if (!dontKickCT)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			else if (GetClientTeam(i) != CS_TEAM_CT)
				continue;

			else if (i == client)
				continue;

			CS_SwitchTeam(i, CS_TEAM_T);
			CS_RespawnPlayer(i);
		}

		if (GetPlayerCount() > 4)
			NextRoundPreviewRound = true;
	}

	if (client != 0)
	{
		ChosenUserId = GetClientUserId(client);

		CS_SwitchTeam(client, CS_TEAM_CT);

		CS_RespawnPlayer(client);

		if (!swapped)
			ServerCommand("mp_restartgame 1");
	}

	else
		ChosenUserId = 0;
}


stock int GetTeamAliveCount(int Team)
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if(!IsPlayerAlive(i))
			continue;

		else if (GetClientTeam(i) == Team)
			count++;
	}
	return count;
}

stock int GetTeamPlayerCount(int Team)
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) == Team)
			count++;
	}
	return count;
}

stock int Abs(int value)
{
	if (value > 0)
		return value;

	return -1 * value;
}

// This stock will return the amount of players the chosen one can invite into his team totally calculated.

// Ratio of 6 T to 1 CT.
// 6 T <==> 1 CT
// 6 T <==> 2 CT
// 11 T <==> 2 CT.
// 12 T <==> 2 CT.
// 13 T <==> 2 CT.
// 13 T <==> 3 CT.
// 18 T <==> 3 CT.
// 19 T <==> 3 CT.
// 19 T <==> 4 CT.

stock int GetAvailableInviteCT()
{ 
	if(GetTeamPlayerCount(CS_TEAM_T) == 1 && GetTeamPlayerCount(CS_TEAM_CT) == 0)
	{
		if(GetConVarBool(hcv_WardenSystem))
			return 1;

		else
		{
			if(GetConVarInt(hcv_VoteCTMin) > 1)
				return 0;

			return 1;
		}
	}
	int ratio = GetConVarInt(hcv_CTRatio);

	char MapName[64];
	GetCurrentMap(MapName, sizeof(MapName));

	if(StrContains(MapName, "_rebel", false) != -1 || StrContains(MapName, "rebel_", false) != -1)
		ratio = GetConVarInt(hcv_CTRatioRebel);

	int playerCount = GetTeamPlayerCount(CS_TEAM_T) + GetTeamPlayerCount(CS_TEAM_CT);
	int totalAllowed = RoundToCeil((playerCount-1) / float(ratio));

	totalAllowed -= GetTeamPlayerCount(CS_TEAM_CT);

	if (totalAllowed < 0)
		totalAllowed = 0;

	return totalAllowed;
}

stock bool AddClientToCTQueue(int client)
{
	CleanupCTQueue();

	if(IsClientInCTQueue(client))
		return false;

	else if(GetClientTeam(client) == CS_TEAM_CT)
		return false;

	g_aCTQueue.Push(GetClientUserId(client));

	return true;
}

stock void CleanupCTQueue()
{
	for(int i=0;i < g_aCTQueue.Length;i++)
	{
		int client = GetClientOfUserId(g_aCTQueue.Get(i));

		if(client == 0)
		{
			g_aCTQueue.Erase(i);
			i--;
			continue;
		}
		else if(IsPlayerBannedFromGuardsTeam(client))
		{
			g_aCTQueue.Erase(i);
			i--;
			continue;
		}
		else if(GetClientTeam(client) == CS_TEAM_CT)
		{
			g_aCTQueue.Erase(i);
			i--;
			continue;
		}
	}
}

stock bool TryRemoveClientFromCTQueue(int client)
{
	int pos = g_aCTQueue.FindValue(GetClientUserId(client));

	if(pos == -1)
		return false;

	g_aCTQueue.Erase(pos);
	return true;
}

stock bool IsClientInCTQueue(int client)
{
	return g_aCTQueue.FindValue(GetClientUserId(client)) >= 0;
}


stock int GetClientPosInCTQueue(int client)
{
	return g_aCTQueue.FindValue(GetClientUserId(client)) + 1;
}

stock int GetNextClientInCTQueue()
{
	CleanupCTQueue();

	if(g_aCTQueue.Length == 0)
		return 0;

	int client = GetClientOfUserId(g_aCTQueue.Get(0));

	return client;
}

stock void ClearCTQueue()
{
	g_aCTQueue.Clear();
}


stock bool AddClientToWardenQueue(int client)
{
	CleanupWardenQueue();

	if(IsClientInWardenQueue(client))
		return false;

	else if(GetClientTeam(client) == CS_TEAM_CT)
		return false;

	g_aWardenQueue.Push(GetClientUserId(client));

	return true;
}

stock void CleanupWardenQueue()
{
	for(int i=0;i < g_aWardenQueue.Length;i++)
	{
		int client = GetClientOfUserId(g_aWardenQueue.Get(i));

		if(client == 0)
		{
			g_aWardenQueue.Erase(i);
			i--;
			continue;
		}
		else if(IsPlayerBannedFromGuardsTeam(client))
		{
			g_aWardenQueue.Erase(i);
			i--;
			continue;
		}
		else if(GetClientTeam(client) == CS_TEAM_CT)
		{
			g_aWardenQueue.Erase(i);
			i--;
			continue;
		}
	}
}

stock bool TryRemoveClientFromWardenQueue(int client)
{
	int pos = g_aWardenQueue.FindValue(GetClientUserId(client));

	if(pos == -1)
		return false;

	g_aWardenQueue.Erase(pos);
	return true;
}

stock bool IsClientInWardenQueue(int client)
{
	return g_aWardenQueue.FindValue(GetClientUserId(client)) >= 0;
}


stock int GetClientPosInWardenQueue(int client)
{
	return g_aWardenQueue.FindValue(GetClientUserId(client)) + 1;
}

stock int GetNextClientInWardenQueue()
{
	CleanupWardenQueue();

	if(g_aWardenQueue.Length == 0)
		return 0;

	int client = GetClientOfUserId(g_aWardenQueue.Get(0));

	return client;
}

stock void ClearWardenQueue()
{
	g_aWardenQueue.Clear();
}


stock int PositiveOrZero(int value)
{
	if (value < 0)
		return 0;

	return value;
}

stock void ShowHudTextAll(int channel, const char[] format, any...)
{
	char buffer[512];
	VFormat(buffer, sizeof(buffer), format, 3);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		ShowHudText(i, channel, buffer);
	}
}

stock int GetValidPlayerCount()
{
	int count;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) <= CS_TEAM_SPECTATOR)    // I want CS_TEAM_NONE to be able to count if the map just started.
			continue;

		count++;
	}

	return count;
}

stock int GetPlayerCount()
{
	int count;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) == CS_TEAM_SPECTATOR)    // I want CS_TEAM_NONE to be able to count if the map just started.
			continue;

		count++;
	}

	return count;
}

stock bool IsValidTeam(int client)
{
	return GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T;
}

stock int[] CalculateVotes()
{
	int arr[MAXPLAYERS + 1];

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (votedItem[i] == -1)
			continue;

		arr[votedItem[i]]++;
	}

	return arr;
}

stock void UC_CloseTeamMenu(int client)
{
	if(IsFakeClient(client))
		return;
		
	Event fakeevent = CreateEvent("player_team");
	
	fakeevent.SetInt("userid", GetClientUserId(client));
	fakeevent.FireToClient(client);
	
	CancelCreatedEvent(fakeevent);
}