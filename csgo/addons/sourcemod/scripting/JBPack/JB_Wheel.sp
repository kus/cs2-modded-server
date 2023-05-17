#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls  required

native int Store_GetClientCredits(int client);
native int Store_SetClientCredits(int client, int amount);

char PLUGIN_VERSION[] = "1.0";

#define SPIN_COOLDOWN_HOURS 12

#define SECONDS_IN_A_HOUR 3600

public Plugin myinfo =
{
	name        = "Store - Wheel of Fortune",
	author      = "Eyal282",
	description = "A Zephyrus store module that adds a wheel of fortune that gives prizes every several hours, giving players an incentive to join",
	version     = PLUGIN_VERSION,
	url         = ""


}

native float Gangs_GetCooldownPercent(int client);

enum PrizeTypes
{
	PRIZE_NULL = 0,
	PRIZE_CREDITS,
	PRIZE_WHEELROLL
}

enum struct enPrizes
{
	char       PrizeName[32];
	int        PrizeCount;
	PrizeTypes PrizeType;
	int        PrizeWeight;    // Prize weight is how likely it is to win relative to others. When you spin the wheel, the actual chance of you getting an item is PrizeWeight divided by the prize weight of all other prizes.
}

enPrizes Prizes[] = {
	{"5,000 Credits",   5000,  PRIZE_CREDITS,   32},
	{ "10,000 Credits", 10000, PRIZE_CREDITS,   23},
	{ "15,000 Credits", 15000, PRIZE_CREDITS,   24},
	{ "25,000 Credits", 25000, PRIZE_CREDITS,   14},
	{ "2 Wheel Rolls",  2,     PRIZE_WHEELROLL, 7 }
};

Handle dbWheel = INVALID_HANDLE;

Handle hcv_Enabled = INVALID_HANDLE;
Handle hcv_FirstJoinSpin = INVALID_HANDLE;

Handle HudSync = INVALID_HANDLE;

bool isSpinning[MAXPLAYERS + 1];

// This error thrower won't work...
/*
#if sizeof(Prizes) < 3

	#error "Plugin needs at least 3 prizes in order to properly set itself up"

#endif
*/
public void OnPluginStart()
{
	RegConsoleCmd("sm_wheel", Command_Wheel);
	RegConsoleCmd("sm_wish", Command_Wheel);

	ConnectToDatabase();

	HudSync = CreateHudSynchronizer();

	AutoExecConfig_SetFile("JB_Wheel", "sourcemod/JBPack");

	hcv_Enabled = UC_CreateConVar("wheel_enabled", "1", "Should this plugin be enabled?");
	hcv_FirstJoinSpin = UC_CreateConVar("wheel_first_join_spin", "1", "If set to 1, joining the server for the first time will allow you to instantly spin the wheel");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();
}

public void OnConfigsExecuted()
{
	CreateTimer(1.0, Timer_CheckConfig, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CheckConfig(Handle hTimer)
{
	if(!GetConVarBool(hcv_Enabled))
	{
		char sFilename[128];
		GetPluginFilename(INVALID_HANDLE, sFilename, sizeof(sFilename));

		UC_PrintToChatEyal(sFilename);
		ServerCommand("sm plugins unload %s", sFilename);
	}

	return Plugin_Continue;
}

void ConnectToDatabase()
{
	char Error[256];
	if ((dbWheel = SQLite_UseDatabase("WheelOfFortune", Error, sizeof(Error))) == INVALID_HANDLE)
		LogError(Error);

	else
		SQL_TQuery(dbWheel, SQLCB_Error, "CREATE TABLE IF NOT EXISTS Wheel_players (AuthId VARCHAR(35) NOT NULL UNIQUE, spins INT(11) NOT NULL, LastSpinTimestamp INT(11) NOT NULL)");
}

public void SQLCB_Error(Handle db, Handle hndl, const char[] Error, int Data)
{
	/* If something fucked up. */
	if (hndl == null)
		ThrowError(Error);
}

public void OnClientPostAdminCheck(int client)
{
	isSpinning[client] = false;
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));

	char sQuery[256];

	SQL_FormatQuery(dbWheel, sQuery, sizeof(sQuery), "INSERT OR IGNORE INTO Wheel_players (AuthId, spins, LastSpinTimestamp) VALUES ('%s', 0, %i)", AuthId, GetConVarBool(hcv_FirstJoinSpin) ? 0 : GetTime());
	SQL_TQuery(dbWheel, SQLCB_Error, sQuery);
}

public Action Command_Wheel(int client, int args)
{
	if (isSpinning[client])
	{
		UC_ReplyToCommand(client, "Cannot open this menu while the wheel is spinning");
		return Plugin_Handled;
	}
	char AuthId[35];
	if (!GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId)))
	{
		UC_ReplyToCommand(client, "Couldn't get your AuthId, please try again soon!");
		return Plugin_Handled;
	}

	char sQuery[256];

	SQL_FormatQuery(dbWheel, sQuery, sizeof(sQuery), "SELECT * FROM Wheel_players WHERE AuthId = '%s'", AuthId);
	SQL_TQuery(dbWheel, SQLCB_GetPlayerSpins, sQuery, GetClientUserId(client));

	return Plugin_Handled;
}

public void SQLCB_GetPlayerSpins(Handle owner, Handle hndl, char[] error, any data)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	int client = GetClientOfUserId(data);

	if (client == 0)
		return;

	if (SQL_GetRowCount(hndl) != 0)
	{
		SQL_FetchRow(hndl);

		int spins             = SQL_FetchInt(hndl, 1);
		int LastSpinTimestamp = SQL_FetchInt(hndl, 2);

		char Time[32];

		if (spins == 0)
		{
			if (LastSpinTimestamp + RoundToFloor((float(SPIN_COOLDOWN_HOURS) * float(SECONDS_IN_A_HOUR) * (1.0 - (Gangs_GetCooldownPercent(client))))) <= GetTime())
				spins = 1;

			else
			{
				FormatTimeHMS(Time, sizeof(Time), RoundToFloor((float(SPIN_COOLDOWN_HOURS) * float(SECONDS_IN_A_HOUR) * (1.0 - (Gangs_GetCooldownPercent(client))))) - (GetTime() - LastSpinTimestamp));
			}
		}

		ShowWheelMenu(client, spins, Time);
	}
}

void ShowWheelMenu(int client, int spins, char[] Time)
{
	Handle hMenu = CreateMenu(Wheel_MenuHandler);

	char TempFormat[128];

	if (spins == 0)
	{
		Format(TempFormat, sizeof(TempFormat), "Spin The Wheel! [%s]", Time);
		AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);
	}
	else
	{
		Format(TempFormat, sizeof(TempFormat), "Spin The Wheel! [%i]", spins);
		AddMenuItem(hMenu, "", TempFormat);
	}

	AddMenuItem(hMenu, "", "Reset For All", CheckCommandAccess(client, "sm_rcon", ADMFLAG_ROOT, true) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	SetMenuTitle(hMenu, "Wheel of fortune\n!Let's go for a spin!");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int Wheel_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		switch (item)
		{
			case 0:
			{
				SpinTheWheel(client);
			}

			case 1:
			{
				if (!CheckCommandAccess(client, "sm_rcon", ADMFLAG_ROOT, true))
					return 0;

				SQL_TQuery(dbWheel, SQLCB_Error, "UPDATE Wheel_players SET spins = 1 WHERE spins = 0", DBPrio_High);

				PrintToChatAll("\x04%N \x01reset the wheel of fortune to all \x07players!", client);
			}
		}
	}

	return 0;
}

void SpinTheWheel(int client)
{
	isSpinning[client] = true;
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));

	char sQuery[350];

	SQL_FormatQuery(dbWheel, sQuery, sizeof(sQuery), "UPDATE Wheel_players SET spins = max(0, spins - 1), LastSpinTimestamp = %i WHERE AuthId = '%s'", GetTime(), AuthId);
	SQL_TQuery(dbWheel, SQLCB_Error, sQuery);

	int TotalWeight;

	for (int i = 0; i < sizeof(Prizes); i++)
	{
		TotalWeight += Prizes[i].PrizeWeight;
	}

	int LuckyNumber = GetRandomInt(1, TotalWeight);

	int LuckyItem;

	int RelativeTotalWeight = 0;

	for (int i = 0; i < sizeof(Prizes); i++)
	{
		if (LuckyNumber <= RelativeTotalWeight + Prizes[i].PrizeWeight)
		{
			LuckyItem = i;

			break;
		}

		RelativeTotalWeight += Prizes[i].PrizeWeight;
	}

	Handle DP;

	CreateDataTimer(1.0, Timer_DisplayWheel, DP);

	WritePackCell(DP, GetClientUserId(client));

	WritePackFloat(DP, 0.1);    // Time before next timer is fired

	WritePackCell(DP, GetRandomInt(0, sizeof(Prizes) - 1));    // Current item in the wheel itself

	WritePackCell(DP, LuckyItem);
}

public Action Timer_DisplayWheel(Handle hTimer, Handle DP)
{
	ResetPack(DP);

	int client = GetClientOfUserId(ReadPackCell(DP));

	float NextTimer = ReadPackFloat(DP);

	int CurrentItem = ReadPackCell(DP);

	int LuckyItem = ReadPackCell(DP);

	SetHudTextParams(-1.0, -1.0, NextTimer * 1.75, 0, 0, 255, 255, 0, 0.0, 0.0, 0.0);

	int RelativeLastPos = CurrentItem - 1;    // Position of item before the item you see on the wheel right now.

	if (RelativeLastPos == -1)
		RelativeLastPos = sizeof(Prizes) - 1;

	int RelativeNextPos = CurrentItem + 1;

	if (RelativeNextPos == sizeof(Prizes))
		RelativeNextPos = 0;

	ShowSyncHudText(client, HudSync, "%s\n\n>>>>> %s <<<<<\n\n%s", Prizes[RelativeLastPos].PrizeName, Prizes[CurrentItem].PrizeName, Prizes[RelativeNextPos].PrizeName);

	if (NextTimer >= 1.0 && CurrentItem == LuckyItem)
	{
		PrintToChatAll("\x04%N \x01just spinned the \x07Wheel \x01of Fortune and won \x07%s!", client, Prizes[LuckyItem].PrizeName);

		isSpinning[client] = false;

		switch (Prizes[LuckyItem].PrizeType)
		{
			case PRIZE_CREDITS:
			{
				int credits = Prizes[LuckyItem].PrizeCount;

				Store_SetClientCredits(client, Store_GetClientCredits(client) + credits);
			}

			case PRIZE_WHEELROLL:
			{
				int SpinsToAdd = Prizes[LuckyItem].PrizeCount;

				char sQuery[256];
				char AuthId[35];

				GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));

				SQL_FormatQuery(dbWheel, sQuery, sizeof(sQuery), "UPDATE Wheel_players SET spins = max(0, spins + %i) WHERE AuthId = '%s'", SpinsToAdd, AuthId);
				SQL_TQuery(dbWheel, SQLCB_Error, sQuery, DBPrio_High);
			}
		}
		return Plugin_Continue;
	}

	CurrentItem += 1;

	if (CurrentItem == sizeof(Prizes))
		CurrentItem = 0;

	if (CurrentItem == 0)
	{
		NextTimer += 0.05;
	}

	if (NextTimer >= 0.5 && CurrentItem == 0)
		NextTimer = 1.0;

	if (NextTimer == 1.0 && RelativeNextPos == LuckyItem)
		NextTimer = 1.5;

	Handle otherDP;

	CreateDataTimer(NextTimer, Timer_DisplayWheel, otherDP);

	WritePackCell(otherDP, GetClientUserId(client));

	WritePackFloat(otherDP, NextTimer);    // Time before next timer is fired

	WritePackCell(otherDP, CurrentItem);    // Current item in the wheel itself

	WritePackCell(otherDP, LuckyItem);

	return Plugin_Continue;
}

stock void FormatTimeHMS(char[] Time, int length, int timestamp, bool LimitTo24H = false)
{
	if (LimitTo24H)
		timestamp %= 86400;

	int HH, MM, SS;

	HH = timestamp / 3600;
	MM = timestamp % 3600 / 60;
	SS = timestamp % 3600 % 60;

	Format(Time, length, "%02d:%02d:%02d", HH, MM, SS);
}