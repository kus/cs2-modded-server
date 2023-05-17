#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <store>

#undef REQUIRE_PLUGIN
#undef REQUIRE_EXTENSIONS
#tryinclude < autoexecconfig>
#define REQUIRE_PLUGIN
#define REQUIRE_EXTENSIONS

#pragma semicolon 1
#pragma newdecls  required

#define PLUGIN_VERSION "1.0"

bool JackpotStarted = false;

Handle Trie_Jackpot = INVALID_HANDLE;

bool FullyAuthorized[MAXPLAYERS + 1];
int  JackpotCredits;

Handle dbJackpot = INVALID_HANDLE;

Handle hcv_MinCredits = INVALID_HANDLE;
Handle hcv_MaxCredits = INVALID_HANDLE;

public Plugin myinfo =
{
	name        = "Store Module - Jackpot",
	author      = "Eyal282",
	description = "A jackpot system for store",
	version     = PLUGIN_VERSION,
	url         = ""
};

public void OnPluginStart()
{
	AutoExecConfig_SetFile("JB_Jackpot", "sourcemod/JBPack");

	hcv_MinCredits = UC_CreateConVar("shop_jackpot_min_credits", "25", "Jackpot Minimum");
	hcv_MaxCredits = UC_CreateConVar("shop_jackpot_max_credits", "65000", "Jackpot Maximum");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

	Trie_Jackpot = CreateTrie();
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);

	RegConsoleCmd("sm_jackpot", Command_Jackpot, "Places a bet on the jackpot");
	RegConsoleCmd("sm_j", Command_Jackpot, "Places a bet on the jackpot");

	ConnectToDatabase();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsClientAuthorized(i))
			continue;

		OnClientPostAdminCheck(i);
	}

#if defined _autoexecconfig_included

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

#endif
}

public void OnClientPostAdminCheck(int client)
{
	FullyAuthorized[client] = true;
	CreateTimer(10.0, Timer_LoadJackpotDebt, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientDisconnect(int client)
{
	FullyAuthorized[client] = false;
}

void ConnectToDatabase()
{
	char Error[256];
	if ((dbJackpot = SQLite_UseDatabase("JailBreakJackpot-debts", Error, sizeof(Error))) == INVALID_HANDLE)
		SetFailState(Error);

	else
		SQL_TQuery(dbJackpot, SQLCB_Error, "CREATE TABLE IF NOT EXISTS Jackpot_Debt (AuthId VARCHAR(35) NOT NULL UNIQUE, credits INT(11) NOT NULL)");
}

public void SQLCB_Error(Handle db, Handle hResults, const char[] Error, int data)
{
	/* If something fucked up. */
	if (hResults == null)
		ThrowError(Error);
}

public void OnMapEnd()
{
	CheckJackpotEnd();
}

public void OnPluginEnd()
{
	CheckJackpotEnd();
}

public Action Event_RoundEnd(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	CheckJackpotEnd();

	return Plugin_Continue;
}

public void CheckJackpotEnd()
{
	if (!JackpotStarted)
		return;

	Handle Trie_Snapshot = CreateTrieSnapshot(Trie_Jackpot);

	int RNG = GetRandomInt(1, JackpotCredits);

	int initValue;

	char WinnerAuthId[35];

	int size = TrieSnapshotLength(Trie_Snapshot);
	for (int i = 0; i < size; i++)
	{
		char AuthId[35];
		GetTrieSnapshotKey(Trie_Snapshot, i, AuthId, sizeof(AuthId));

		int credits;
		GetTrieValue(Trie_Jackpot, AuthId, credits);

		if (RNG > initValue && RNG <= (initValue + credits))
		{
			WinnerAuthId = AuthId;
			break;
		}
		initValue += credits;
	}

	CloseHandle(Trie_Snapshot);

	int Winner = FindClientByAuthId(WinnerAuthId);

	if (Winner == 0)
	{
		SaveJackpotDebt(WinnerAuthId, JackpotCredits);
		PrintToChatAll("\x01The winner \x07disconnected, \x01saving his \x07%i \x01credits for next time he joins. Winner's \x01Steam ID: \x07%s", JackpotCredits, WinnerAuthId);
	}
	else
	{
		Store_SetClientCredits(Winner, Store_GetClientCredits(Winner) + JackpotCredits);

		PrintToChatAll("The jackpot winner is %N, he won %i credits ( %.1f%% )", Winner, JackpotCredits, GetJackpotChance(WinnerAuthId));
	}

	JackpotStarted = false;
	JackpotCredits = 0;
	ClearTrie(Trie_Jackpot);
}

public Action Command_Jackpot(int client, int args)
{
	if (args != 1)
	{
		UC_ReplyToCommand(client, "Usage: sm_jackpot <amount>");
		return Plugin_Handled;
	}

	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	if (GetTrieValue(Trie_Jackpot, AuthId, args))
	{
		UC_ReplyToCommand(client, "You \x05already \x01joined the \x07jackpot.");
		return Plugin_Handled;
	}
	char Arg[35];
	GetCmdArg(1, Arg, sizeof(Arg));

	int joinCredits = StringToInt(Arg);

	int credits = Store_GetClientCredits(client);

	if (StrEqual(Arg, "all", false))
	{
		joinCredits = credits;

		if (joinCredits > GetConVarInt(hcv_MaxCredits))
			joinCredits = GetConVarInt(hcv_MaxCredits);
	}

	if (credits < joinCredits)
	{
		UC_ReplyToCommand(client, "You \x07don't \x01have enough \x07credits.");
		return Plugin_Handled;
	}

	else if (GetConVarInt(hcv_MinCredits) > joinCredits)
	{
		UC_ReplyToCommand(client, " \x01The \x07Minimum \x01amount of \x07credits \x01to join the jackpot is \x05%i", GetConVarInt(hcv_MinCredits));
		return Plugin_Handled;
	}

	else if (GetConVarInt(hcv_MaxCredits) < joinCredits)
	{
		UC_ReplyToCommand(client, " \x01The \x07Maximum \x01amount of \x07credits \x01to join the jackpot is \x05%i", GetConVarInt(hcv_MaxCredits));
		return Plugin_Handled;
	}

	Store_SetClientCredits(client, Store_GetClientCredits(client) - joinCredits);

	SetTrieValue(Trie_Jackpot, AuthId, joinCredits);

	JackpotStarted = true;

	JackpotCredits += joinCredits;

	PrintToChatAll(" \x04%N \x01joined the \x07jackpot \x01with \x07%i \x01credits! \x07Total: \x05%i \x07( %.2f%% )", client, joinCredits, JackpotCredits, GetJackpotChance(AuthId));

	return Plugin_Handled;
}

public void SaveJackpotDebt(const char[] AuthId, int amount)
{
	char sQuery[256];

	Format(sQuery, sizeof(sQuery), "UPDATE OR IGNORE Jackpot_Debt SET credits = credits + %i WHERE AuthId = '%s'", amount, AuthId);
	SQL_TQuery(dbJackpot, SQLCB_Error, sQuery);

	Format(sQuery, sizeof(sQuery), "INSERT OR IGNORE INTO Jackpot_Debt (AuthId, credits) VALUES ('%s', %d)", AuthId, amount);
	SQL_TQuery(dbJackpot, SQLCB_Error, sQuery);
}

public Action Timer_LoadJackpotDebt(Handle hTimer, int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (client == 0)
			return Plugin_Continue;

	char sQuery[256];
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	Format(sQuery, sizeof(sQuery), "SELECT * FROM Jackpot_Debt WHERE AuthId = '%s'", AuthId);
	SQL_TQuery(dbJackpot, SQLCB_LoadDebt, sQuery, GetClientUserId(client));

	return Plugin_Continue;
}

public int SQLCB_LoadDebt(Handle db, Handle hResults, const char[] Error, int UserId)
{
	if (hResults == null)
		ThrowError(Error);

	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return 0;

	else if (!FullyAuthorized[client])
		return 0;

	else if (SQL_GetRowCount(hResults) > 0)
	{
		SQL_FetchRow(hResults);

		int debt = SQL_FetchInt(hResults, 1);

		char AuthId[35];
		GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

		char sQuery[256];
		Format(sQuery, sizeof(sQuery), "DELETE FROM Jackpot_Debt WHERE AuthId = '%s'", AuthId);

		SQL_TQuery(dbJackpot, SQLCB_Error, sQuery, _, DBPrio_High);

		PrintToChat(client, "Jackpot system owed you \x07%i \x01credits because you left before you \x04WON", debt);

		Store_SetClientCredits(client, Store_GetClientCredits(client) + debt);
	}

	return 0;
}

stock float GetJackpotChance(const char[] AuthId)
{
	int clientCredits;
	GetTrieValue(Trie_Jackpot, AuthId, clientCredits);

	if (JackpotCredits == 0.0)
		return 0.0;

	return 100.0 * (float(clientCredits) / float(JackpotCredits));
}

stock int FindClientByAuthId(const char[] AuthId)
{
	char iAuthId[35];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!FullyAuthorized[i])    // Only due to Store's absolutely trash methods of setting a player's credits
			continue;

		GetClientAuthId(i, AuthId_Steam2, iAuthId, sizeof(iAuthId));

		if (StrEqual(AuthId, iAuthId, true))
			return i;
	}

	return 0;
}