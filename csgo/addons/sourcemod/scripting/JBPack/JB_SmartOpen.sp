/* put the line below after all of the includes!
#pragma newdecls required
*/

#include <cstrike>
#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <entityIO>

#define PLUGIN_VERSION "1.1"

#pragma semicolon 1
#pragma newdecls  required

char   PREFIX[256];
Handle hcv_Prefix = INVALID_HANDLE;

Handle hcv_Close           = INVALID_HANDLE;
Handle hcv_Mode            = INVALID_HANDLE;
Handle hcv_Auto            = INVALID_HANDLE;
Handle hcv_GraceBeforeOpen = INVALID_HANDLE;
Handle hcv_EmptyRebel      = INVALID_HANDLE;
Handle hcv_LRChainsaw      = INVALID_HANDLE;

Handle dbLocal;

Handle Trie_Retriers = INVALID_HANDLE;

Handle hTimer_AutoOpen = INVALID_HANDLE;

bool OpenedThisRound = false;

char MapName[64];

int ButtonHID = -1, IsolationHID = -1;

float g_fNextOpen;

bool CanBeGraced[MAXPLAYERS + 1];

Handle fw_OnCellsOpened;

public Plugin myinfo =
{
	name        = "Smart Open",
	author      = "Eyal282",
	description = "JailBreak Cells Open that works in a smart way",
	version     = PLUGIN_VERSION,
	url         = ""

};

enum struct enQueue
{
	int ref;
	char output[64];
}

ArrayList g_aQueueOutputs;
ArrayList g_aTargetnamesOpen;
ArrayList g_aTargetnamesBreak;

native bool JailBreakDays_IsDayActive();
native bool SmartOpen_AreCellsOpen();

// returns false if couldn't open cells. Forced may fail if not assigned.
native bool SmartOpen_OpenCells(bool forced, bool isolation);

public APLRes AskPluginLoad2(Handle myself, bool bLate, char[] Error, int errorLength)
{
	CreateNative("SmartOpen_AreCellsOpen", Native_AreCellsOpen);
	CreateNative("SmartOpen_OpenCells", Native_OpenCells);

	return APLRes_Success;
}

public any Native_AreCellsOpen(Handle plugin, int numParams)
{
	return OpenedThisRound;
}

public any Native_OpenCells(Handle plugin, int numParams)
{
	bool forced    = GetNativeCell(1);
	bool isolation = GetNativeCell(2);

	if (OpenedThisRound && !forced)
		return false;

	bool openedCells = OpenCells();

	if (isolation)
		isolation = OpenIsolation();

	if (!openedCells && !isolation)
		return false;

	return true;
}

public void OnPluginStart()
{

	g_aQueueOutputs = new ArrayList(sizeof(enQueue));
	g_aTargetnamesOpen = new ArrayList(256);
	g_aTargetnamesBreak = new ArrayList(256);

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_freeze_end", Event_RoundFreezeEnd, EventHookMode_PostNoCopy);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawnOrDeath, EventHookMode_Post);

	RegConsoleCmd("sm_open", Command_Open, "Opens jail cells");
	RegConsoleCmd("sm_hardopen", Command_HardOpen, "Opens jail cells and isolation");
	RegConsoleCmd("sm_close", Command_Close, "Closes jail cells and isolation");

	RegAdminCmd("sm_open_override", Command_OpenOverride, ADMFLAG_SLAY, "Command used for override purposes");
	RegAdminCmd("sm_assignopen", Command_AssignOpen, ADMFLAG_SLAY);
	RegAdminCmd("sm_assignisol", Command_AssignIsolation, ADMFLAG_SLAY);
	RegAdminCmd("sm_assignisolation", Command_AssignIsolation, ADMFLAG_SLAY);

	AutoExecConfig_SetFile("JB_SmartOpen", "sourcemod/JBPack");

	hcv_Close            = UC_CreateConVar("close_cells", "2", "0 - Close Cells does not work, 1 - Close Cells works if button is assigned to map, 2 - Close cells always works.");
	hcv_Mode            = UC_CreateConVar("open_cells_mode", "1", "0 - Command will not work if an admin didn't assign a button to the map, 1 - Uses all buttons in the map if button wasn't assigned to map");
	hcv_Auto            = UC_CreateConVar("open_cells_auto", "60", "After how much time to open the cells, set to -1 to disable");
	hcv_GraceBeforeOpen = UC_CreateConVar("open_cells_grace_pre_open", "1", "1 - Players will respawn when joining before cells open");
	hcv_EmptyRebel      = UC_CreateConVar("open_cells_allow_empty_rebel", "1", "If there are no CT ( probably server empty ) terrorists are able to use !open");
	hcv_LRChainsaw      = UC_CreateConVar("open_cells_lr_chainsaw", "1", "Last terrorist can execute !open with his lr chainsaw");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

	// cmd = Were the cells opened by command or with button.
	// note: This forward will fire if sm_open was used in any way.
	// note: This forward will NOT fire if the cells were opened without being assigned.
	// public void SmartOpen_OnCellsOpened(bool cmd)
	fw_OnCellsOpened = CreateGlobalForward("SmartOpen_OnCellsOpened", ET_Ignore, Param_Cell);
	Trie_Retriers    = CreateTrie();
}

public void LastRequest_OnLRStarted(int Prisoner, int Guard)
{
	ServerCommand("sm_hardopen");
}
public void OnAllPluginsLoaded()
{
	hcv_Prefix = FindConVar("sm_prefix_cvar");

	GetConVarString(hcv_Prefix, PREFIX, sizeof(PREFIX));
	HookConVarChange(hcv_Prefix, cvChange_Prefix);

}

public void cvChange_Prefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(PREFIX, sizeof(PREFIX), newValue);
}

bool blockOpen = false;

public void OnMapStart()
{
	g_aTargetnamesOpen.Clear();
	g_aTargetnamesBreak.Clear();

	ButtonHID       = -1;
	OpenedThisRound = false;
	ConnectToDatabase();

	hTimer_AutoOpen = INVALID_HANDLE;

	g_fNextOpen = 0.0;
}

public void OnClientAuthorized(int client)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	int dummy_value;
	if (!GetTrieValue(Trie_Retriers, AuthId, dummy_value))
		CanBeGraced[client] = true;
}

public void OnClientPutInServer(int client)
{
	// Weird error was given. Keep an eye because if OpenCells throws an error, blockOpen won't necessarily be switched off.
	if(GetClientCount(true) == 1)
	{
		blockOpen = true;
		OpenCells();
		blockOpen = false;
	}
}

public void OnClientDisconnect(int client)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	SetTrieValue(Trie_Retriers, AuthId, 1, true);
}

public void ConnectToDatabase()
{
	char Error[256];
	if ((dbLocal = SQLite_UseDatabase("SmartOpen", Error, sizeof(Error))) == INVALID_HANDLE)
		LogError(Error);

	else
	{
		SQL_TQuery(dbLocal, SQLCB_Error, "CREATE TABLE IF NOT EXISTS SmartOpen_Maps (MapName VARCHAR(64) NOT NULL UNIQUE, ButtonHammerID INT(15) NOT NULL, IsolationHammerID INT(15) NOT NULL)", _, DBPrio_High);

		char sQuery[256];
		GetCurrentMap(MapName, sizeof(MapName));
		SQL_FormatQuery(dbLocal, sQuery, sizeof(sQuery), "SELECT * FROM SmartOpen_Maps WHERE MapName = '%s'", MapName);

		SQL_TQuery(dbLocal, SQLCB_GetButtonHammerID, sQuery, _, DBPrio_High);
	}
}

public void SQLCB_GetButtonHammerID(Handle db, Handle hndl, const char[] sError, int dummy_value)
{
	if (hndl == null)
		ThrowError(sError);

	else if (SQL_GetRowCount(hndl) == 0)
	{
		char sQuery[256];
		SQL_FormatQuery(dbLocal, sQuery, sizeof(sQuery), "INSERT OR IGNORE INTO SmartOpen_Maps (MapName, ButtonHammerID, IsolationHammerID) VALUES ('%s', -1, -1)", MapName);

		SQL_TQuery(dbLocal, SQLCB_Error, sQuery, _, DBPrio_High);

		ButtonHID    = -1;
		IsolationHID = -1;
		return;
	}

	if (!SQL_FetchRow(hndl))
	{
		char sQuery[256];
		SQL_FormatQuery(dbLocal, sQuery, sizeof(sQuery), "INSERT OR IGNORE INTO SmartOpen_Maps (MapName, ButtonHammerID, IsolationHammerID) VALUES ('%s', -1, -1)", MapName);

		SQL_TQuery(dbLocal, SQLCB_Error, sQuery, _, DBPrio_High);

		ButtonHID    = -1;
		IsolationHID = -1;
		return;
	}

	ButtonHID    = SQL_FetchInt(hndl, 1);
	IsolationHID = SQL_FetchInt(hndl, 2);
}

public void SQLCB_Error(Handle db, Handle hndl, const char[] sError, int data)
{
	if (hndl == null)
		ThrowError(sError);
}

public Action Event_PlayerTeam(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (!GetConVarBool(hcv_GraceBeforeOpen))
		return Plugin_Continue;

	if (ButtonHID == -1)
		return Plugin_Continue;

	int NewTeam = GetEventInt(hEvent, "team");

	if (NewTeam <= CS_TEAM_SPECTATOR)
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (client == 0)
		return Plugin_Continue;

	if (!CanBeGraced[client])
		return Plugin_Continue;

	if (OpenedThisRound)
		return Plugin_Continue;

	RequestFrame(Frame_GraceSpawn, GetClientUserId(client));

	return Plugin_Continue;
}

public void Frame_GraceSpawn(int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return;

	if (!CanBeGraced[client])
		return;

	if (OpenedThisRound)
		return;

	if (GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return;

	if (IsPlayerAlive(client))
		return;

	CS_RespawnPlayer(client);

	CanBeGraced[client] = false;
}

public Action Event_PlayerSpawnOrDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (client == 0)
		return Plugin_Continue;

	else if (!IsValidTeam(client))
		return Plugin_Continue;

	CanBeGraced[client] = false;

	return Plugin_Continue;
}

public Action Event_RoundStart(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	g_aQueueOutputs.Clear();

	UnhookEntityOutput("func_button", "OnPressed", OnButtonPressed);

	if (ButtonHID != -1)
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "func_button")) != -1)
		{
			if (GetEntProp(ent, Prop_Data, "m_iHammerID") == ButtonHID)
				break;
		}

		if (ent != -1)
			HookSingleEntityOutput(ent, "OnPressed", OnButtonPressed);
	}
	OpenedThisRound = false;

	DestroyTimer(hTimer_AutoOpen);

	if (GetConVarFloat(hcv_Auto) != -1)
		hTimer_AutoOpen = CreateTimer(GetConVarFloat(hcv_Auto), AutoOpenCells, _, TIMER_FLAG_NO_MAPCHANGE);

	for (int i = 1; i <= MaxClients; i++)
	{
		CanBeGraced[i] = true;
	}

	ClearTrie(Trie_Retriers);

	return Plugin_Continue;
}

public Action Event_RoundFreezeEnd(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	g_fNextOpen = 0.0;

	if(GetTeamPlayerCount(CS_TEAM_CT) <= 0 || GetTeamPlayerCount(CS_TEAM_T) == 1)
		OpenCells();

	else
	{
		g_fNextOpen = 0.0;
		blockOpen = true;
		OpenCells();
		blockOpen = false;
		g_fNextOpen = 0.0;
	}


	return Plugin_Continue;
}

public void OnButtonPressed(const char[] output, int caller, int activator, float delay)
{
	if (GetEntProp(caller, Prop_Data, "m_iHammerID") != ButtonHID)
	{
		UnhookSingleEntityOutput(caller, "PressIn", OnButtonPressed);
		return;
	}

	else if (OpenedThisRound)
	{
		UnhookSingleEntityOutput(caller, "PressIn", OnButtonPressed);
		return;
	}

	OpenedThisRound = true;

	UnhookSingleEntityOutput(caller, "PressIn", OnButtonPressed);

	QueueOpenDoorsForOutput(caller, "OnPressed");
	QueueOpenDoorsForOutput(caller, "OnIn");
	QueueOpenDoorsForOutput(caller, "OnUseLocked");
	QueueOpenDoorsForOutput(caller, "OnDamaged");

	char strBuffer[255];

	FormatEx(strBuffer, sizeof(strBuffer), "OnUser1 !self:Unlock:0:2.5:1");

	SetVariantString(strBuffer);
	AcceptEntityInput(caller, "AddOutput");
	AcceptEntityInput(caller, "FireUser1");

	FormatEx(strBuffer, sizeof(strBuffer), "OnUser2 !self:Lock:0:0.01:10");

	SetVariantString(strBuffer);
	AcceptEntityInput(caller, "AddOutput");
	AcceptEntityInput(caller, "FireUser2");

	Call_StartForward(fw_OnCellsOpened);

	Call_PushCell(false);

	Call_Finish();
}

public Action AutoOpenCells(Handle hTimer)
{
	if (ButtonHID != -1)
		OpenCells();

	hTimer_AutoOpen = INVALID_HANDLE;

	return Plugin_Continue;
}

public Action Command_AssignOpen(int client, int args)
{
	int ent = FindEntityByAim(client, "func_button");

	if (ent < 0)
	{
		UC_PrintToChat(client, "%s Couldn't find a \x07func_button \x01entity at your aim, please try \x07again", PREFIX);
		return Plugin_Handled;
	}

	char Classname[64];
	GetEdictClassname(ent, Classname, sizeof(Classname));

	if (!StrEqual(Classname, "func_button", true))
	{
		UC_PrintToChat(client, "%s Couldn't find a \x07func_button \x01entity at your aim, please try \x07again", PREFIX);
		return Plugin_Handled;
	}

	ButtonHID = GetEntProp(ent, Prop_Data, "m_iHammerID");

	char sQuery[256];

	SQL_FormatQuery(dbLocal, sQuery, sizeof(sQuery), "UPDATE SmartOpen_Maps SET ButtonHammerID = %i WHERE MapName = '%s'", ButtonHID, MapName);

	SQL_TQuery(dbLocal, SQLCB_Error, sQuery, _, DBPrio_Normal);

	UC_PrintToChat(client, "%s \x05Successfully \x01made the button you're aiming at as the button that opens the cells for \x07!open", PREFIX);
	return Plugin_Handled;
}

public Action Command_AssignIsolation(int client, int args)
{
	int ent = FindEntityByAim(client, "func_door");

	if (ent < 0)
	{
		UC_PrintToChat(client, "%s Couldn't find a \x07func_door \x01entity at your aim, please try \x07again", PREFIX);
		return Plugin_Handled;
	}

	char Classname[64];
	GetEdictClassname(ent, Classname, sizeof(Classname));

	if (!StrEqual(Classname, "func_door", true))
	{
		UC_PrintToChat(client, "%s Couldn't find a func_door entity at your aim, please try again", PREFIX);
		return Plugin_Handled;
	}

	IsolationHID = GetEntProp(ent, Prop_Data, "m_iHammerID");

	char sQuery[256];

	SQL_FormatQuery(dbLocal, sQuery, sizeof(sQuery), "UPDATE SmartOpen_Maps SET IsolationHammerID = %i WHERE MapName = '%s'", IsolationHID, MapName);

	SQL_TQuery(dbLocal, SQLCB_Error, sQuery, _, DBPrio_Normal);

	UC_PrintToChat(client, "%s \x05Successfully \x01made the door you're aiming at as the door of the isolation for \x07!hardopen", PREFIX);

	return Plugin_Handled;
}

public Action Command_OpenOverride(int client, int args)
{
	return Plugin_Handled;
}

public Action Command_Open(int client, int args)
{
	if (JailBreakDays_IsDayActive() || CanEmptyRebel() || CanLRChainsaw())
	{
		// Must open isolation otherwise the isolation will never open...
		Command_HardOpen(client, 0);
		return Plugin_Handled;
	}
	else if (client != 0 && GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_open_override", ADMFLAG_SLAY, false) && !CanEmptyRebel() && !CanLRChainsaw())
	{
		UC_PrintToChat(client, "%s You must be \x0BCT \x01to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	else if (OpenedThisRound)
	{
		UC_PrintToChat(client, "%s Cells were \x07already \x01opened this round!", PREFIX);
		return Plugin_Handled;
	}

	else if (ButtonHID == -1 && GetConVarInt(hcv_Mode) == 0)
	{
		UC_PrintToChat(client, "Map does not have an assigned open button!");
		UC_PrintToChat(client, "An admin must use !assignopen to assign a button.");
		UC_PrintToChat(client, "An admin can also use !assignisolation to assign a button to open isolation room");
		return Plugin_Handled;
	}

	if (!OpenCells())
	{
		UC_PrintToChat(client, "The map's assigned open button is bugged!");
		return Plugin_Handled;
	}

	char Title[64];

	if (client != 0)
	{
		int Team = GetClientTeam(client);

		if (Team == CS_TEAM_CT)
			Title = "Guard";

		else if (Team == CS_TEAM_T && CanEmptyRebel())
			Title = "Rebel";

		else if (Team == CS_TEAM_T && CanLRChainsaw())
			Title = "LR";

		else if (CheckCommandAccess(client, "sm_open_override", ADMFLAG_SLAY, false))
			Title = "Admin";
	}
	else
		Title = "Admin";

	if (client != 0)
		UC_PrintToChatAll("%s %s \x05%N \x01opened the \x07jail \x01cells!", PREFIX, Title, client);

	return Plugin_Handled;
}

public Action Command_HardOpen(int client, int args)
{
	if (client != 0 && GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_open_override", ADMFLAG_SLAY, false) && !CanEmptyRebel() && !CanLRChainsaw())
	{
		UC_PrintToChat(client, "%s You must be \x0BCT \x01to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	else if (ButtonHID == -1 && GetConVarInt(hcv_Mode) == 0)
	{
		UC_PrintToChat(client, "Map does not have an assigned open button!");
		UC_PrintToChat(client, "An admin must use !assignopen to assign a button.");
		return Plugin_Handled;
	}

	else if (OpenedThisRound && !JailBreakDays_IsDayActive() && !CanEmptyRebel() && !CanLRChainsaw())
	{
		OpenIsolation();
		UC_PrintToChat(client, "%s Cells were \x07already \x01opened this \x05round!", PREFIX);
		return Plugin_Handled;
	}
	else if (!OpenCells())
	{
		UC_PrintToChat(client, "The map's assigned open button is bugged!");
		return Plugin_Handled;
	}

	char Title[64];

	if (client != 0)
	{
		int Team = GetClientTeam(client);

		if (Team == CS_TEAM_CT)
			Title = "Guard";

		else if (Team == CS_TEAM_T && CanEmptyRebel())
			Title = "Rebel";

		else if (Team == CS_TEAM_T && CanLRChainsaw())
			Title = "LR";

		else if (CheckCommandAccess(client, "sm_open_override", ADMFLAG_SLAY, false))
			Title = "Admin";
	}
	else
		Title = "Admin";

	if (client != 0)
		UC_PrintToChatAll("%s %s \x05%N \x01hard opened the \x07jail \x01cells!", PREFIX, Title, client);

	OpenIsolation();
	return Plugin_Handled;
}


public Action Command_Close(int client, int args)
{
	switch(GetConVarInt(hcv_Close))
	{
		case 0:
		{
			UC_PrintToChat(client, "%s This command is disabled.", PREFIX);
			return Plugin_Handled;
		}
		case 1:
		{
			if(ButtonHID == -1)
			{
				UC_PrintToChat(client, "Map does not have an assigned open button!");
				UC_PrintToChat(client, "An admin must use !assignopen to assign a button.");
				return Plugin_Handled;
			}
		}
	}
	if (client != 0 && GetClientTeam(client) != CS_TEAM_CT && !CheckCommandAccess(client, "sm_open_override", ADMFLAG_SLAY, false))
	{
		UC_PrintToChat(client, "%s You must be \x0BCT \x01to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	else if (!OpenedThisRound)
	{
		UC_PrintToChat(client, "%s Cells are \x07already \x01closed!", PREFIX);
		return Plugin_Handled;
	}
	else if (!CloseCells())
	{
		UC_PrintToChat(client, "The map's assigned open button is bugged!");
		return Plugin_Handled;
	}

	char Title[64];

	if (client != 0)
	{
		int Team = GetClientTeam(client);

		if (Team == CS_TEAM_CT)
			Title = "Guard";

		else if (Team == CS_TEAM_T && CanEmptyRebel())
			Title = "Rebel";

		else if (Team == CS_TEAM_T && CanLRChainsaw())
			Title = "LR";

		else if (CheckCommandAccess(client, "sm_open_override", ADMFLAG_SLAY, false))
			Title = "Admin";
	}
	else
		Title = "Admin";

	if (client != 0)
		UC_PrintToChatAll("%s %s \x05%N \x01closed the \x07jail \x01cells!", PREFIX, Title, client);

	CloseIsolation();
	return Plugin_Handled;
}

stock bool OpenCells()
{
	if(g_fNextOpen > GetGameTime())
		return true;

	g_fNextOpen = GetGameTime() + 2.5;

	int ent = -1;
	if (ButtonHID == -1)
	{
		if(g_aTargetnamesOpen.Length > 0 || g_aTargetnamesBreak.Length > 0)
		{

			// blockOpen is meant to just register the targetnames without opening.
			if(!blockOpen)
			{
				for(int i=0;i < g_aTargetnamesOpen.Length;i++)
				{
					char sTarget[256];
					g_aTargetnamesOpen.GetString(i, sTarget, sizeof(sTarget));

					AcceptEntityInputForTargetname(sTarget, "Open");
				}

				for(int i=0;i < g_aTargetnamesBreak.Length;i++)
				{
					char sTarget[256];
					g_aTargetnamesBreak.GetString(i, sTarget, sizeof(sTarget));

					AcceptEntityInputForTargetname(sTarget, "Break");
				}			
			}
		}
		else if(GetClientCount(true) > 0)
		{
			while ((ent = FindEntityByClassname(ent, "func_button")) != -1)
			{
				if(blockOpen)
				{
					OpenDoorsForOutput(ent, "OnPressed");
					OpenDoorsForOutput(ent, "OnIn");
					OpenDoorsForOutput(ent, "OnUseLocked");
					OpenDoorsForOutput(ent, "OnDamaged");
				}
				else
				{
					QueueOpenDoorsForOutput(ent, "OnPressed");
					QueueOpenDoorsForOutput(ent, "OnIn");
					QueueOpenDoorsForOutput(ent, "OnUseLocked");
					QueueOpenDoorsForOutput(ent, "OnDamaged");
				}

			}

			while ((ent = FindEntityByClassname(ent, "func_door")) != -1)
			{
				if(blockOpen)
				{
					QueueOpenDoorsForOutput(ent, "OnOpen");
					QueueOpenDoorsForOutput(ent, "OnClose");
				}
				else
				{
					OpenDoorsForOutput(ent, "OnOpen");
					OpenDoorsForOutput(ent, "OnClose");
				}
			}
		}
	}

	else if(!blockOpen)
	{
		if(g_aTargetnamesOpen.Length > 0 || g_aTargetnamesBreak.Length > 0)
		{

			// blockOpen is meant to just register the targetnames without opening.
			if(!blockOpen)
			{
				for(int i=0;i < g_aTargetnamesOpen.Length;i++)
				{
					char sTarget[256];
					g_aTargetnamesOpen.GetString(i, sTarget, sizeof(sTarget));

					AcceptEntityInputForTargetname(sTarget, "Open");
				}

				for(int i=0;i < g_aTargetnamesBreak.Length;i++)
				{
					char sTarget[256];
					g_aTargetnamesBreak.GetString(i, sTarget, sizeof(sTarget));

					AcceptEntityInputForTargetname(sTarget, "Break");
				}			
			}
		}
		else
		{
			bool Found = false;
			while ((ent = FindEntityByClassname(ent, "func_button")) != -1)
			{
				if (GetEntProp(ent, Prop_Data, "m_iHammerID") == ButtonHID)
				{
					Found = true;
					break;
				}
			}

			if (!Found)
				return false;
				
				
			if(blockOpen)
			{
				OpenDoorsForOutput(ent, "OnPressed");
				OpenDoorsForOutput(ent, "OnIn");
				OpenDoorsForOutput(ent, "OnUseLocked");
				OpenDoorsForOutput(ent, "OnDamaged");
			}
			else
			{
				QueueOpenDoorsForOutput(ent, "OnPressed");
				QueueOpenDoorsForOutput(ent, "OnIn");
				QueueOpenDoorsForOutput(ent, "OnUseLocked");
				QueueOpenDoorsForOutput(ent, "OnDamaged");
			}

			AcceptEntityInput(ent, "Lock");

			char strBuffer[255];

			FormatEx(strBuffer, sizeof(strBuffer), "OnUser1 !self:Unlock:0:2.5:1");

			SetVariantString(strBuffer);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");
		}
	}

	if(!blockOpen)
	{
		OpenedThisRound = true;
		
		Call_StartForward(fw_OnCellsOpened);

		Call_PushCell(true);

		Call_Finish();
	}

	return true;
}

stock bool OpenIsolation()
{
	int target;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		target = i;
		break;
	}

	if (target == 0)
		return false;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_CT)
			continue;

		target = i;
		break;
	}
	bool Found = false;

	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_door")) != -1)
	{
		if (GetEntProp(ent, Prop_Data, "m_iHammerID") == IsolationHID)
		{
			Found = true;
			break;
		}
	}

	if (!Found)
		return false;

	AcceptEntityInput(ent, "Open", target);

	return true;
}

stock bool CloseCells()
{
	if(g_fNextOpen > GetGameTime())
		return true;

	g_fNextOpen = GetGameTime() + 2.5;

	if (ButtonHID == -1)
	{
		if(g_aTargetnamesOpen.Length > 0 || g_aTargetnamesBreak.Length > 0)
		{

			for(int i=0;i < g_aTargetnamesOpen.Length;i++)
			{
				char sTarget[256];
				g_aTargetnamesOpen.GetString(i, sTarget, sizeof(sTarget));

				AcceptEntityInputForTargetname(sTarget, "Close");
			}
		}
	}

	else if(!blockOpen)
	{
		if(g_aTargetnamesOpen.Length > 0 || g_aTargetnamesBreak.Length > 0)
		{

			// blockOpen is meant to just register the targetnames without opening.
			if(!blockOpen)
			{
				for(int i=0;i < g_aTargetnamesOpen.Length;i++)
				{
					char sTarget[256];
					g_aTargetnamesOpen.GetString(i, sTarget, sizeof(sTarget));

					AcceptEntityInputForTargetname(sTarget, "Close");
				}		
			}
		}
	}

	OpenedThisRound = false;

	return true;
}

stock bool CloseIsolation()
{
	int target;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		target = i;
		break;
	}

	if (target == 0)
		return false;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_CT)
			continue;

		target = i;
		break;
	}
	bool Found = false;

	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_door")) != -1)
	{
		if (GetEntProp(ent, Prop_Data, "m_iHammerID") == IsolationHID)
		{
			Found = true;
			break;
		}
	}

	if (!Found)
		return false;

	AcceptEntityInput(ent, "Close", target);

	return true;
}

stock void DestroyTimer(Handle& timer)
{
	if (timer != INVALID_HANDLE)
	{
		CloseHandle(timer);
		timer = INVALID_HANDLE;
	}
}

stock int FindEntityByAim(int client, const char[] Classname)
{
	float eyeOrigin[3], eyeAngles[3];

	GetClientEyePosition(client, eyeOrigin);
	GetClientEyeAngles(client, eyeAngles);

	Handle DP = CreateDataPack();

	WritePackString(DP, Classname);
	TR_TraceRayFilter(eyeOrigin, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRay_HitClassname, DP);

	CloseHandle(DP);

	if (!TR_DidHit(INVALID_HANDLE))
		return -1;

	return TR_GetEntityIndex(INVALID_HANDLE);
}

public bool TraceRay_HitClassname(int entityhit, int mask, Handle DP)
{
	char Classname[64], Classname2[64];

	ResetPack(DP);
	ReadPackString(DP, Classname, sizeof(Classname));

	GetEdictClassname(entityhit, Classname2, sizeof(Classname2));

	return StrEqual(Classname, Classname2, true);
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

stock int GetAliveTeamCount(int Team)
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) != Team)
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		count++;
	}

	return count;
}

stock bool CanEmptyRebel()
{
	return (GetConVarBool(hcv_EmptyRebel) && GetTeamPlayerCount(CS_TEAM_CT) == 0);
}

stock bool CanLRChainsaw()
{
	return (GetConVarBool(hcv_LRChainsaw) && GetAliveTeamCount(CS_TEAM_T) == 1);
}

stock bool IsValidTeam(int client)
{
	return GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T;
}

public void OnGameFrame()
{
	OnFramedGame(10);
}

public void OnFramedGame(int count)
{
	if(g_aQueueOutputs.Length == 0 || count == 0)
		return;

	enQueue queue;

	g_aQueueOutputs.GetArray(0, queue);
	g_aQueueOutputs.Erase(0);

	int ent = EntRefToEntIndex(queue.ref);

	if(ent == INVALID_ENT_REFERENCE)
	{
		OnFramedGame(count);
		return;
	}

	else if(!OpenDoorsForOutput(ent, queue.output))
	{
		OnFramedGame(count);
		return;
	}

	OnFramedGame(count-1);
}

stock void QueueOpenDoorsForOutput(int ent, const char[] output, bool recursive=false)
{
	enQueue queue;

	queue.ref = EntIndexToEntRef(ent);
	FormatEx(queue.output, sizeof(enQueue::output), output);

	g_aQueueOutputs.PushArray(queue);
}


stock bool OpenDoorsForOutput(int ent, const char[] output, bool recursive=false)
{
	int offset = EntityIO_FindEntityOutputOffset(ent, output);

	if (offset == -1)
		return false;
	
	Handle actionIter = EntityIO_FindEntityFirstOutputAction(ent, offset);

	if (actionIter == INVALID_HANDLE)
		return false;

	do
	{
		char sTarget[256];
		EntityIO_GetEntityOutputActionTarget(actionIter, sTarget, sizeof(sTarget));
		
		char input[256];
		EntityIO_GetEntityOutputActionInput(actionIter, input, sizeof(input));
		
		int targetEnt = -1;
		
		if(StrEqual(input, "Toggle") || StrEqual(input, "Open") || strncmp(input, "OpenAwayFrom", 12) == 0 || strncmp(input,"SetPosition", 11) == 0)
		{
			if(g_aTargetnamesOpen.FindString(sTarget) == -1)
			{
				g_aTargetnamesOpen.PushString(sTarget);

				if(!blockOpen)
					AcceptEntityInputForTargetname(sTarget, "Open");
			}
		}
		
		else if(StrEqual(input, "Break"))
		{
			if(g_aTargetnamesBreak.FindString(sTarget) == -1)
			{
				g_aTargetnamesBreak.PushString(sTarget);

				if(!blockOpen)
					AcceptEntityInputForTargetname(sTarget, "Break");
			}
		}
		else if(StrEqual(input, "Trigger") && !recursive)
		{
			while((targetEnt = FindEntityByValveTargetname(targetEnt, sTarget)) != -1)
			{
				OpenDoorsForOutput(targetEnt, "OnTrigger", true);
			}
		}
		
		
	} while (EntityIO_FindEntityNextOutputAction(actionIter));

	delete actionIter;

	DeleteDummyEntity();

	return true;
}

stock int FindEntityByValveTargetname(int entity, const char[] strTargetname)
{
	char strBuffer[255];
	FormatEx(strBuffer, sizeof(strBuffer), strTargetname);

	int pos = StrContains(strBuffer, "*");

	if(pos != -1)
		strBuffer[pos] = EOS;

	return FindEntityByTargetname(entity, strBuffer, true, pos != -1 ? true : false);
}



stock int FindEntityByTargetname(int startEnt, const char[] TargetName, bool caseSensitive, bool Contains)    // Same as FindEntityByClassname with sensitivity and contain features
{
	char EntTargetName[300];

	int i = startEnt;

	while((i = FindEntityByClassname(i, "*")) != -1)
	{
		if (!IsValidEntity(i))
			continue;
		
		GetEntPropString(i, Prop_Data, "m_iName", EntTargetName, sizeof(EntTargetName));

		if ((!Contains && StrEqual(EntTargetName, TargetName, caseSensitive)) || (Contains && StrContains(EntTargetName, TargetName, caseSensitive) != -1))
			return i;
	}

	return -1;
}

int dummy_entity = INVALID_ENT_REFERENCE;

stock int CreateDummyEntity()
{
	int ent = CreateEntityByName("info_target");
	
	DispatchSpawn(ent);

	ActivateEntity(ent);

	dummy_entity = EntIndexToEntRef(ent);

	return ent;
}

stock void DeleteDummyEntity()
{
	if(dummy_entity != INVALID_ENT_REFERENCE)
	{
		int ent = EntRefToEntIndex(dummy_entity);

		if(ent != INVALID_ENT_REFERENCE)
		{
			char strBuffer[256];

			FormatEx(strBuffer, sizeof(strBuffer), "OnUser1 !self:Kill:0:0.1:1");

			SetVariantString(strBuffer);
			AcceptEntityInput(ent, "AddOutput");
			AcceptEntityInput(ent, "FireUser1");
		}
	}

	dummy_entity = INVALID_ENT_REFERENCE;
}
stock void AcceptEntityInputForTargetname(const char[] sTargetname, const char[] input)
{
	int ent = -1;

	if(dummy_entity == INVALID_ENT_REFERENCE || (ent = EntRefToEntIndex(dummy_entity)) == INVALID_ENT_REFERENCE)
		ent = CreateDummyEntity();

	char strBuffer[255];

	FormatEx(strBuffer, sizeof(strBuffer), "OnUser1 %s:%s:0:0.0:1", sTargetname, input);

	SetVariantString(strBuffer);
	AcceptEntityInput(ent, "AddOutput");
	AcceptEntityInput(ent, "FireUser1");
}