#include <clientprefs>
#include <cstrike>
#include <sdktools>
#include <sourcemod>
#include <eyal-jailbreak>

#pragma semicolon 1
#pragma newdecls  required

Handle cpLastRifle  = INVALID_HANDLE;
Handle cpLastPistol = INVALID_HANDLE;
Handle cpNeverShow  = INVALID_HANDLE;

float spawnTimestamp[MAXPLAYERS + 1] = { 0.0, ... };

bool SaveLastGuns[MAXPLAYERS + 1];
bool DontShow[MAXPLAYERS + 1];

enum struct enWeapons
{
	char enWeaponName[64];
	char enWeaponClassname[64];
}

enWeapons RifleList[] = {
	{"M4A1",      "weapon_m4a1"         },
	{ "M4A1-S",   "weapon_m4a1_silencer"},
	{ "AK47",     "weapon_ak47"         },
	{ "AWP",      "weapon_awp"          },
	{ "FAMAS",    "weapon_famas"        },
	{ "Galil AR", "weapon_galilar"      },
	{ "SG553",    "weapon_sg556"        },
	{ "AUG",      "weapon_aug"          },
	{ "UMP-45",   "weapon_ump45"        }
};

enWeapons PistolList[] = {
	{"Desert Eagle",   "weapon_deagle"      },
	{ "USP-S",         "weapon_usp_silencer"},
	{ "P2000",         "weapon_hkp2000"     },
	{ "Glock-18",      "weapon_glock"       },
	{ "P250",          "weapon_p250"        },
	{ "Tec-9",         "weapon_tec9"        },
	{ "Five-Seven",    "weapon_fiveseven"   },
	{ "CZ75-Auto",     "weapon_cz75a"       },
	{ "Dual Berettas", "weapon_elite"       }
};

public Plugin myinfo =
{
	name        = "[CSGO] JailBreak Weapons Menu",
	author      = "Eyal282",
	description = "Gives the Guards a menu to pick their favourite weapon",
	version     = "1.0",
	url         = "None."
};

Handle hcv_Enabled = INVALID_HANDLE;
Handle hcv_MenuLifeSeconds = INVALID_HANDLE;

char PREFIX[256];
char MENU_PREFIX[64];

Handle hcv_Prefix     = INVALID_HANDLE;
Handle hcv_MenuPrefix = INVALID_HANDLE;

public void OnPluginStart()
{
	// The cvar to enable the plugin. 0 = Disabled. Other values = Enabled.

	AutoExecConfig_SetFile("JB_WeaponMenu", "sourcemod/JBPack");
	
	hcv_Enabled = UC_CreateConVar("jb_weapons_enabled", "1", "Enable weapon menu?");
	hcv_MenuLifeSeconds = UC_CreateConVar("jb_weapons_menu_life_seconds", "15", "Time in seconds until gun menu disappears.");

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);

	RegConsoleCmd("sm_guns", Command_Guns, "Disable auto gun choice");

	cpLastRifle  = RegClientCookie("WeaponsMenu_LastRifle", "Player's Last Chosen Rifle", CookieAccess_Private);
	cpLastPistol = RegClientCookie("WeaponsMenu_LastPistol", "Player's Last Chosen Pistol", CookieAccess_Private);
	cpNeverShow  = RegClientCookie("WeaponsMenu_NeverShow", "Should the player see the weapon menu at all?", CookieAccess_Private);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		DontShow[i]     = false;
		SaveLastGuns[i] = false;
	}
}


public void OnAllPluginsLoaded()
{
	hcv_Prefix = FindConVar("sm_prefix_cvar");

	GetConVarString(hcv_Prefix, PREFIX, sizeof(PREFIX));
	HookConVarChange(hcv_Prefix, cvChange_Prefix);

	hcv_MenuPrefix = FindConVar("sm_menu_prefix_cvar");

	GetConVarString(hcv_MenuPrefix, MENU_PREFIX, sizeof(MENU_PREFIX));
	HookConVarChange(hcv_MenuPrefix, cvChange_MenuPrefix);

}


public void cvChange_Prefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(PREFIX, sizeof(PREFIX), newValue);
}

public void cvChange_MenuPrefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(MENU_PREFIX, sizeof(MENU_PREFIX), newValue);
}

public void OnMapStart()
{
	for(int i=0;i < sizeof(spawnTimestamp);i++)
	{
		spawnTimestamp[i] = 0.0;
	}

}
public void OnClientConnected(int client)
{
	DontShow[client]     = false;
	SaveLastGuns[client] = false;
}

public void OnConfigsExecuted()
{
	// hcv_CK = FindConVar("adp_ck_enabled");
}

public Action Command_Guns(int client, int args)
{
	if (SaveLastGuns[client])
	{
		SaveLastGuns[client] = false;
		PrintToChat(client, "%s \x05Last guns save\x01 is now disabled.", PREFIX);
	}

	SetClientDontShow(client, false);
	DontShow[client] = false;
	return Plugin_Handled;
}

public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (GetConVarInt(hcv_Enabled) == 0)
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (!IsClientInGame(client))
		return Plugin_Continue;

	spawnTimestamp[client] = GetGameTime();

	StripPlayerWeapons(client);
	GivePlayerItem(client, "weapon_knife");

	if (GetClientTeam(client) != CS_TEAM_CT)
		return Plugin_Continue;

	else if (DontShow[client])
		return Plugin_Continue;

	else if (GetClientDontShow(client))
		return Plugin_Continue;

	else if (SaveLastGuns[client])
	{
		PrintToChat(client, "%s \x01Type\x05 !guns\x01 to disable\x05 auto gun save\x01.", PREFIX);
		RequestFrame(GivePistol, GetClientUserId(client));
		RequestFrame(GiveRifle, GetClientUserId(client));
		return Plugin_Continue;
	}

	char   TempFormat[150];
	Handle hMenu = CreateMenu(Choice_MenuHandler);

	AddMenuItem(hMenu, "", "Choose your guns");
	AddMenuItem(hMenu, "", "Last Guns");
	AddMenuItem(hMenu, "", "Last Guns + Save");
	AddMenuItem(hMenu, "", "Don't show again");
	AddMenuItem(hMenu, "", "Never show again");

	Format(TempFormat, sizeof(TempFormat), "%s Choose your guns:\n \nLast Rifle: %s\nLast Pistol: %s \n ", MENU_PREFIX, RifleList[GetClientLastRifle(client)], PistolList[GetClientLastPistol(client)]);

	SetMenuTitle(hMenu, TempFormat);

	DisplayMenu(hMenu, client, GetConVarInt(hcv_MenuLifeSeconds));
	return Plugin_Continue;
}

public int Choice_MenuHandler(Handle hMenu, MenuAction action, int client, int item)    // client and item are only valid in MenuAction_Select and something else.
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!IsPlayerAlive(client) || GetClientTeam(client) != CS_TEAM_CT)
			return 0;

		else if(GetGameTime() > spawnTimestamp[client] + GetConVarInt(hcv_MenuLifeSeconds))
		{
			PrintToChat(client, "%s \x01You can only pick guns in the first\x04 %i\x01 seconds of the round.", PREFIX, GetConVarInt(hcv_MenuLifeSeconds));
			return 0;
		}
		switch (item + 1)
		{
			case 1: ShowWeaponsMenu(client);
			case 2:
			{
				RequestFrame(GivePistol, GetClientUserId(client));
				RequestFrame(GiveRifle, GetClientUserId(client));
			}
			case 3:
			{
				RequestFrame(GivePistol, GetClientUserId(client));
				RequestFrame(GiveRifle, GetClientUserId(client));
				SaveLastGuns[client] = true;
			}
			case 4:
			{
				DontShow[client]     = true;
				SaveLastGuns[client] = false;

				PrintToChat(client, "%s \x01Type\x05 !guns\x01 to see the weapon menu again.", PREFIX);
				PrintToChat(client, "%s \x01The weapon menu will not appear again until you reconnect.", PREFIX);
			}
			case 5:
			{
				SetClientDontShow(client, true);
				SaveLastGuns[client] = false;

				PrintToChat(client, "%s \x01Type\x05 !guns\x01 to see the weapon menu again.", PREFIX);
				PrintToChat(client, "%s \x01The weapon menu will never appear again even after you logout.", PREFIX);
			}
		}
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void ShowWeaponsMenu(int client)
{
	Handle hMenu = CreateMenu(Weapons_MenuHandler);

	for (int i = 0; i < sizeof(RifleList); i++)
	{
		AddMenuItem(hMenu, "", RifleList[i].enWeaponName);
	}

	SetMenuTitle(hMenu, "Choose your rifle:");
	SetMenuPagination(hMenu, MENU_NO_PAGINATION);

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int Weapons_MenuHandler(Handle hMenu, MenuAction action, int client, int item)    // client and item are only valid in MenuAction_Select and something else.
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					SetClientLastRifle(client, item);

					RequestFrame(GiveRifle, GetClientUserId(client));

					ShowPistolMenu(client);
				}
			}
		}
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

void ShowPistolMenu(int client)
{
	if (GetConVarInt(hcv_Enabled) == 0)
		return;

	else if (!IsClientInGame(client))
		return;

	else if (GetClientTeam(client) != CS_TEAM_CT)
		return;

	Handle hMenu = CreateMenu(Pistols_MenuHandler);

	for (int i = 0; i < sizeof(PistolList); i++)
	{
		AddMenuItem(hMenu, "", PistolList[i].enWeaponName);
	}

	SetMenuTitle(hMenu, "Choose your pistol:");
	SetMenuPagination(hMenu, MENU_NO_PAGINATION);

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int Pistols_MenuHandler(Handle hMenu, MenuAction action, int client, int item)    // client and item are only valid in MenuAction_Select and something else.
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					SetClientLastPistol(client, item);

					RequestFrame(GivePistol, GetClientUserId(client));
				}
			}
		}
	}

	hMenu = INVALID_HANDLE;

	return 0;
}

public void GivePistol(int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return;

	else if (GetClientTeam(client) != CS_TEAM_CT)
		return;
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

	if (weapon != -1)
		CS_DropWeapon(client, weapon, false, true);

	GivePlayerItem(client, PistolList[GetClientLastPistol(client)].enWeaponClassname);
}

public void GiveRifle(int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return;

	else if (GetClientTeam(client) != CS_TEAM_CT)
		return;

	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

	if (weapon != -1)
		CS_DropWeapon(client, weapon, false, true);

	GivePlayerItem(client, RifleList[GetClientLastRifle(client)].enWeaponClassname);
}
stock void StripPlayerWeapons(int client)
{
	for (int i = 0; i <= 5; i++)
	{
		int weapon = GetPlayerWeaponSlot(client, i);

		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			i--;
		}
	}
}

stock void SetClientArmor(int client, int amount, int helmet = -1)    // helmet: -1 = unchanged, 0 = no helmet, 1 = yes helmet
{
	if (helmet != -1)
		SetEntProp(client, Prop_Send, "m_bHasHelmet", helmet);

	SetEntProp(client, Prop_Send, "m_ArmorValue", amount);
}

stock void SetClientLastPistol(int client, int amount)
{
	char strAmount[30];

	IntToString(amount, strAmount, sizeof(strAmount));

	SetClientCookie(client, cpLastPistol, strAmount);
}

stock int GetClientLastPistol(int client)
{
	char strAmount[30];

	GetClientCookie(client, cpLastPistol, strAmount, sizeof(strAmount));

	int amount = StringToInt(strAmount);

	return amount;
}

stock void SetClientLastRifle(int client, int amount)
{
	char strAmount[30];

	IntToString(amount, strAmount, sizeof(strAmount));

	SetClientCookie(client, cpLastRifle, strAmount);
}

stock int GetClientLastRifle(int client)
{
	char strAmount[30];

	GetClientCookie(client, cpLastRifle, strAmount, sizeof(strAmount));

	int amount = StringToInt(strAmount);

	return amount;
}

stock bool GetClientDontShow(int client)
{
	char strNeverShow[50];
	GetClientCookie(client, cpNeverShow, strNeverShow, sizeof(strNeverShow));

	if (strNeverShow[0] == EOS)
	{
		SetClientDontShow(client, false);
		return true;
	}

	return view_as<bool>(StringToInt(strNeverShow));
}

stock bool SetClientDontShow(int client, bool value)
{
	char strNeverShow[50];

	IntToString(view_as<int>(value), strNeverShow, sizeof(strNeverShow));
	SetClientCookie(client, cpNeverShow, strNeverShow);

	return value;
}