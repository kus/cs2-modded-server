#include <sourcemod>
#include <sdktools>
#include <store>
#include <eyal-jailbreak>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define semicolon 1
#define newdecls required

enum Prize
{
	Prize_None = 0, 
	Prize_Credits, 
	Prize_Trail, 
	Prize_Skin, 
	Prize_Pet
}

Database g_dDatabase = null;

Handle g_hDailyTimer[MAXPLAYERS + 1];

Prize g_pPlayerPrize[MAXPLAYERS + 1];

char g_szAuth[MAXPLAYERS + 1][64];

int g_iNextDaily[MAXPLAYERS + 1];
int g_iMaxSpins[MAXPLAYERS + 1];
int g_iSpins[MAXPLAYERS + 1];

/* Completly random - dont want to set the credits 1 - 60
1 - Random Credits 1 - 20
2 - Random Trail 21 - 35
3 - Random Credits 36 - 55
4 - Random Skin 56 - 60
5 - Random Credits 61 - 85
6 - Random Pet 86 - 100
*/

public Plugin myinfo = 
{
	name = "[CS:GO] Daily Prize", 
	author = PLUGIN_AUTHOR, 
	description = "Every day you can win a prize", 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrasses");
	
	SQL_MakeConnection();
	
	RegAdminCmd("sm_rdaily", Command_ResetDaily, ADMFLAG_ROOT);
	RegConsoleCmd("sm_daily", Command_Daily);
	RegConsoleCmd("sm_wish", Command_Daily);
}

/* Hooks, Events */

public void OnMapStart()
{
	char szPath[512];
	for (int i = 1; i <= 6; i++)
	{
		Format(szPath, sizeof(szPath), "materials/daily/daily/daily_%i.vmt", i);
		AddFileToDownloadsTable(szPath);
		Format(szPath, sizeof(szPath), "materials/daily/daily/daily_win_%i.vmt", i);
		AddFileToDownloadsTable(szPath);
		
		Format(szPath, sizeof(szPath), "materials/daily/daily/daily_%i.vtf", i);
		AddFileToDownloadsTable(szPath);
		Format(szPath, sizeof(szPath), "materials/daily/daily/daily_win_%i.vtf", i);
		AddFileToDownloadsTable(szPath);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (!GetClientAuthId(client, AuthId_Steam2, g_szAuth[client], sizeof(g_szAuth)))
	{
		KickClient(client, "Verification problem, please reconnect");
		return;
	}
	
	g_pPlayerPrize[client] = Prize_None;
	SQL_LoadUser(client);
}

/* Commands */

public Action Command_ResetDaily(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "%s Usage: sm_rdaily <#userid|name>", PREFIX);
		return Plugin_Handled;
	}
	
	char szArg[32];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	int iTarget = FindTarget(client, szArg, false, false);
	if (iTarget == -1)
		return Plugin_Handled;
	
	g_iNextDaily[iTarget] = 0;
	SQL_UpdateUser(iTarget);
	
	ShowActivity2(client, PREFIX_ACTIVITY, " Resseted \x02%N\x01's Daily Time.", iTarget);
	return Plugin_Handled;
}

public Action Command_Daily(int client, int args)
{
	int iTimeleft = g_iNextDaily[client] - GetTime();
	if (!g_iNextDaily[client] || iTimeleft <= 0)
	{
		int iRandom = GetRandomInt(1, 100);
		if ((1 <= iRandom <= 20) || (36 <= iRandom <= 55) || (61 <= iRandom <= 85))
			g_pPlayerPrize[client] = Prize_Credits;
		else if ((21 <= iRandom <= 35))
			g_pPlayerPrize[client] = Prize_Trail;
		else if ((56 <= iRandom <= 60))
			g_pPlayerPrize[client] = Prize_Skin;
		else
			g_pPlayerPrize[client] = Prize_Pet;
		
		g_iMaxSpins[client] = 12 + getSpinningLeft(g_pPlayerPrize[client]);
		g_hDailyTimer[client] = CreateTimer(0.3, Timer_Daily, client);
		
		g_iNextDaily[client] = GetTime() + 86400;
		SQL_UpdateUser(client);
	} else {
		int iHours = iTimeleft / 3600; //Not using days
		int iMinutes = (iTimeleft / 60) % 60;
		int iSeconds = iTimeleft % 60;
		ReplyToCommand(client, "%s You must wait \x02%i \x01hours, \x02%i \x01minutes and \x02%i \x01seconds.", PREFIX, iHours, iMinutes, iSeconds);
	}
	
	return Plugin_Handled;
}

public Action Timer_Daily(Handle timer, any client)
{
	if (g_iSpins[client] <= g_iMaxSpins[client])
	{
		char szPath[512];
		Format(szPath, sizeof(szPath), "daily/daily/%s_%i.vmt", g_iSpins[client] == g_iMaxSpins[client] ? "daily_win":"daily", getOverlayNumber(g_iSpins[client]));
		setClientOverlay(client, szPath);
		g_iSpins[client]++;
		g_hDailyTimer[client] = CreateTimer(g_iSpins[client] >= 8 ? 0.6:0.3, Timer_Daily, client);
	} else {
		g_iSpins[client] = 1;
		char szPrize[128];
		switch (g_pPlayerPrize[client])
		{
			case Prize_Credits:
			{
				int iRandom = GetRandomInt(1, 750);
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iRandom);
				Format(szPrize, sizeof(szPrize), "%i Credits", iRandom);
			}
			case Prize_Trail:
			{
				ArrayList aItems = new ArrayList(10);
				
				for (int i = 0; i < STORE_MAX_ITEMS; i++)
				{
					any aItemOutput[Store_Item];
					Store_GetItem(i, aItemOutput);
					
					any aHandlerOutput[Type_Handler];
					Store_GetHandler(aItemOutput[iHandler], aHandlerOutput);
					if (StrEqual(aHandlerOutput[szType], "trail") && (aItemOutput[iFlagBits] == 0 || CheckCommandAccess(client, "", aItemOutput[iFlagBits])))
					{
						aItems.Push(i);
					}
				}
				
				int iRandom = GetRandomInt(0, aItems.Length - 1);
				int iItemId = aItems.Get(iRandom);
				
				any aItemOutput[Store_Item]
				Store_GetItem(iItemId, aItemOutput);
				Store_GiveItem(client, iItemId);
				
				Format(szPrize, sizeof(szPrize), "%s (Trail)", aItemOutput[szName])
			}
			case Prize_Skin:
			{
				ArrayList aItems = new ArrayList(10);
				
				for (int i = 0; i < STORE_MAX_ITEMS; i++)
				{
					any aItemOutput[Store_Item];
					Store_GetItem(i, aItemOutput);
					
					any aHandlerOutput[Type_Handler];
					Store_GetHandler(aItemOutput[iHandler], aHandlerOutput);
					if (StrEqual(aHandlerOutput[szType], "playerskin") && (aItemOutput[iFlagBits] == 0 || CheckCommandAccess(client, "", aItemOutput[iFlagBits])))
					{
						aItems.Push(i);
					}
				}
				
				int iRandom = GetRandomInt(0, aItems.Length - 1);
				int iItemId = aItems.Get(iRandom);
				
				any aItemOutput[Store_Item]
				Store_GetItem(iItemId, aItemOutput);
				Store_GiveItem(client, iItemId);
				
				Format(szPrize, sizeof(szPrize), "%s (Player Skin)", aItemOutput[szName])
			}
			case Prize_Pet:
			{
				ArrayList aItems = new ArrayList(10);
				
				for (int i = 0; i < STORE_MAX_ITEMS; i++)
				{
					any aItemOutput[Store_Item];
					Store_GetItem(i, aItemOutput);
					
					any aHandlerOutput[Type_Handler];
					Store_GetHandler(aItemOutput[iHandler], aHandlerOutput);
					if (StrEqual(aHandlerOutput[szType], "pet") && (aItemOutput[iFlagBits] == 0 || CheckCommandAccess(client, "", aItemOutput[iFlagBits])))
					{
						aItems.Push(i);
					}
				}
				
				int iRandom = GetRandomInt(0, aItems.Length - 1);
				int iItemId = aItems.Get(iRandom);
				
				any aItemOutput[Store_Item]
				Store_GetItem(iItemId, aItemOutput);
				Store_GiveItem(client, iItemId);
				
				Format(szPrize, sizeof(szPrize), "%s (Pet)", aItemOutput[szName])
			}
		}
		
		CreateTimer(2.5, Timer_RemoveOverlay, client);
		PrintToChatAll("%s \x07%N \x01has used his Daily Spin and won a \x04%s\x01.", PREFIX, client, szPrize);
	}
}

public Action Timer_RemoveOverlay(Handle timer, any client)
{
	setClientOverlay(client, "");
}

/* Database */

void SQL_MakeConnection()
{
	if (g_dDatabase != null)
		delete g_dDatabase;
	
	char szError[512];
	g_dDatabase = SQL_Connect("daily", true, szError, sizeof(szError));
	if (g_dDatabase == null)
		SetFailState("Cannot connect to database, error: %s", szError);
	
	g_dDatabase.Query(SQL_CheckForErrors, "CREATE TABLE IF NOT EXISTS `daily` (`steamId` VARCHAR(32) NOT NULL, `name` VARCHAR(64) NOT NULL, `nextDaily` INT(10) NOT NULL, UNIQUE(`steamId`))");
	
	for (int i = 1; i <= MaxClients; i++)if (IsClientInGame(i))OnClientPostAdminCheck(i);
}

void SQL_LoadUser(int client)
{
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "SELECT `nextDaily` FROM `daily` WHERE `steamId` = '%s'", g_szAuth[client]);
	g_dDatabase.Query(SQL_LoadUser_CB, szQuery, GetClientSerial(client));
}

public void SQL_LoadUser_CB(Database DB, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data);
	if (results == null)
	{
		LogError("Failed to query, error: %s", error);
		return;
	}
	
	if (results.FetchRow())
	{
		g_iNextDaily[client] = results.FetchInt(0);
		SQL_UpdateUser(client);
	} else {
		g_iNextDaily[client] = 0;
		SQL_RegisterPlayer(client);
	}
}

void SQL_RegisterPlayer(int client)
{
	char szPlayerName[MAX_NAME_LENGTH];
	GetClientName(client, szPlayerName, sizeof(szPlayerName));
	
	int len = strlen(szPlayerName) * 2 + 1;
	char[] szEscapedName = new char[len];
	g_dDatabase.Escape(szPlayerName, szEscapedName, len);
	
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "INSERT INTO `daily` (`steamId`, `name`, `nextDaily`) VALUES ('%s', '%s', 0)", g_szAuth[client], szEscapedName);
	g_dDatabase.Query(SQL_CheckForErrors, szQuery);
}

void SQL_UpdateUser(int client)
{
	char szPlayerName[MAX_NAME_LENGTH];
	GetClientName(client, szPlayerName, sizeof(szPlayerName));
	
	int len = strlen(szPlayerName) * 2 + 1;
	char[] szEscapedName = new char[len];
	g_dDatabase.Escape(szPlayerName, szEscapedName, len);
	
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "UPDATE `daily` SET `name` = '%s', `nextDaily` = %i WHERE `steamId` = '%s'", szEscapedName, g_iNextDaily[client], g_szAuth[client]);
	g_dDatabase.Query(SQL_CheckForErrors, szQuery);
}

public void SQL_CheckForErrors(Database DB, DBResultSet results, const char[] error, any data)
{
	if (results == null)
	{
		LogError("Failed to query, error: %s", error);
		return;
	}
}

/* Stocks, Functions */

void setClientOverlay(int client, char[] path)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	ClientCommand(client, "r_screenoverlay \"%s\"", path);
}

int getSpinningLeft(Prize prize)
{
	switch (prize)
	{
		case Prize_Credits:
		{
			int iRandom = GetRandomInt(1, 3);
			return iRandom == 2 ? 5:iRandom;
		}
		case Prize_Trail:
		{
			return 2;
		}
		case Prize_Skin:
		{
			return 6;
		}
		case Prize_Pet:
		{
			return 4;
		}
	}
	
	return 0;
}

int getOverlayNumber(int num)
{
	int iLeft = num % 6;
	return iLeft ? iLeft:6;
} 