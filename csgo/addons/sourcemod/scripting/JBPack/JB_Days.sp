#include <clientprefs>
#include <cstrike>
#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls  required

#define MENU_SELECT_SOUND "buttons/button14.wav"
#define MENU_EXIT_SOUND   "buttons/combine_button7.wav"

enum enDay
{
	NULL_DAY = 0,
	LR_DAY,
	FS_DAY,
	ZEUS_DAY,
	DODGEBALL_DAY,
	SCOUT_DAY,
	KNIFE_DAY,
	WAR_DAY,
	SDEAGLE_DAY,
	HNR_DAY,
	CROSSBOW_DAY,

	MAX_DAYS
};

char DayName[][] = {
	"IF YOU SEE THIS MESSAGE CONTACT ADMIN!",
	"IF YOU SEE THIS MESSAGE CONTACT ADMIN!",
	"FreeStyle Day",
	"Zeus Day",
	"DodgeBall Day",
	"Scout Day",
	"Knife Day",
	"War Day",
	"Super Deagle Day",
	"Hit'N'Run Day",
	"Crossbow Day"
};

char DayCommand[][] = {
	"NULL AND VOID",
	"NULL AND VOID",
	"sm_startfsday",
	"sm_startzeusday",
	"sm_startdodgeballday",
	"sm_startscoutday",
	"sm_startknifeday",
	"sm_startwarday",
	"sm_startsdeagleday",
	"sm_starthnrday",
	"sm_startcrossbowday",

};

enum struct enWeapon {
	char classname[64];
	char nickname[256];
}

enWeapon WarDayWeapons[] = {
	{"weapon_ak47",    "AK-47"  },
	{ "weapon_awp",    "AWP"    },
	{ "weapon_m4a1",   "M4A4"   },
	{ "weapon_sg556",  "SG-553" },
	{ "weapon_aug",    "AUG"    },
	{ "weapon_scar20", "SCAR-20"}
};

native void Eyal282_VoteCT_StopVoteCT();
native int   Gangs_HasGang(int client);
native int   Gangs_GetClientGangId(int client);
native int   Gangs_GetClientGlowColorSlot(int client);
native int   Gangs_GetClientGangName(int client, char[] GangName, int len);
native int   Gangs_PrintToChatGang(char[] GangName, char[] format, any...);
native int   Gangs_AddClientDonations(int client, int amount);
native int   Gangs_GiveGangCredits(const char[] GangName, int amount);
native int   Gangs_GiveClientCredits(int client, int amount);
native int   Gangs_AreClientsSameGang(int client, int otherClient);
native int   Gangs_TryDestroyGlow(int client);
native float Gangs_GetFFDamageDecrease(int client);
native void LR_CheckAnnounce();
native bool LR_isActive();

char   PREFIX[256];
Handle hcv_Prefix = INVALID_HANDLE;

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
	name        = "JailBreak Days",
	author      = "Eyal282",
	description = "JailBreak Days",
	version     = PLUGIN_VERSION,
	url         = ""
};

bool IgnorePlayerDeaths;

Handle hcv_TeammatesAreEnemies      = INVALID_HANDLE;
Handle hcv_IgnoreRoundWinConditions = INVALID_HANDLE;
Handle hcv_TaserRechargeTime        = INVALID_HANDLE;

Handle fw_OnDayStatus = INVALID_HANDLE;

Handle hTimer_StartDay = INVALID_HANDLE;

Handle hVoteDayMenu;

Handle hVoteWeaponMenu;
Handle hVoteHSMenu;
Handle hVoteBackstabMenu;

float VoteDayStart;

int votedItem[MAXPLAYERS + 1] = { -1, ... };

bool ShowMessage[MAXPLAYERS + 1];

enDay DayActive = NULL_DAY;

char DayWeapon[64];

bool DayHSOnly;

int DayCountDown;

bool GlowRemoved;

char DodgeballModel[] = "models/chicken/chicken.mdl";

int g_Infected;
float g_fNextHNRDeath;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("JailBreakDays_IsDayActive", Native_IsDayActive);
	CreateNative("JailBreakDays_StartVoteDay", Native_StartVoteDay);
	return APLRes_Success;
}

public int Native_IsDayActive(Handle plugin, int numParams)
{
	return DayActive > LR_DAY;
}

public int Native_StartVoteDay(Handle plugin, int numParams)
{
	StartVoteDay();

	return 0;
}

public Action Timer_DrawVoteDayMenu(Handle hTimer)
{
	if (RoundToFloor((VoteDayStart + 15) - GetGameTime()) <= 0)
		return Plugin_Stop;

	else if (!IsVoteInProgress())
		return Plugin_Stop;

	BuildUpVoteDayMenu();

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

void BuildUpVoteDayMenu()
{
	if (hVoteDayMenu == INVALID_HANDLE)
		hVoteDayMenu = CreateMenu(VoteDay_VoteHandler);

	SetMenuTitle(hVoteDayMenu, "Choose which day to play: [%i]", RoundFloat((VoteDayStart + 15) - GetGameTime()));

	RemoveAllMenuItems(hVoteDayMenu);

	int VoteList[16];

	VoteList = CalculateVotes();

	char TempFormat[128], replace[16];

	for (int i = view_as<int>(LR_DAY) + 1; i < view_as<int>(MAX_DAYS); i++)
	{
		if(StrContains(DayName[i], "Crossbow") != -1)
		{
			// Skip crossbow day if no API found.
			if(!LibraryExists("CrossbowAPI"))
				continue;
		}
		FormatEx(TempFormat, sizeof(TempFormat), "%s {VOTE_COUNT}", DayName[i]);

		FormatEx(replace, sizeof(replace), "[%i]", VoteList[i]);

		ReplaceStringEx(TempFormat, sizeof(TempFormat), "{VOTE_COUNT}", replace);
		AddMenuItem(hVoteDayMenu, "", TempFormat);
	}

	SetMenuPagination(hVoteDayMenu, MENU_NO_PAGINATION);
}

public int VoteDay_VoteHandler(Handle hMenu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hMenu);
		hVoteDayMenu = INVALID_HANDLE;
	}
	else if (action == MenuAction_VoteCancel)
	{
		if (param1 == VoteCancel_NoVotes)
		{
			CheckVoteDayResult();
		}
	}
	else if (action == MenuAction_VoteEnd)
	{
		CheckVoteDayResult();
	}
	else if (action == MenuAction_Select)
	{
		votedItem[param1] = param2 + view_as<int>(LR_DAY) + 1;
	}

	return 0;
}

void CheckVoteDayResult()
{
	int VoteList[16];

	VoteList = CalculateVotes();

	DayActive = NULL_DAY;

	for (int i = view_as<int>(LR_DAY) + 1; i < view_as<int>(MAX_DAYS); i++)
	{
		// We cannot use random chance to dictate the winner, because this random chance algorithm can allow no days to be selected.
		if (DayActive == NULL_DAY || VoteList[i] > VoteList[DayActive] || (VoteList[i] == VoteList[DayActive] && GetRandomInt(0, 1) == 1))
			DayActive = view_as<enDay>(i);
	}

	
	ServerCommand(DayCommand[DayActive]);

	EndVoteDay();
}

void EndVoteDay()
{
	for (int i = 0; i < sizeof(votedItem); i++)
		votedItem[i] = -1;

	VoteDayStart = 0.0;
}

public void OnPluginStart()
{
	RegAdminCmd("sm_startvoteday", Command_StartVoteDay, ADMFLAG_GENERIC);
	RegServerCmd("sm_startfsday", Command_StartFSDay);
	RegServerCmd("sm_startzeusday", Command_StartZeusDay);
	RegServerCmd("sm_startdodgeballday", Command_StartDodgeballDay);
	RegServerCmd("sm_startscoutday", Command_StartScoutDay);
	RegServerCmd("sm_startknifeday", Command_StartKnifeDay);
	RegServerCmd("sm_startwarday", Command_StartWarDay);
	RegServerCmd("sm_startsdeagleday", Command_StartSDeagleDay);
	RegServerCmd("sm_starthnrday", Command_StartHNRDay);
	RegServerCmd("sm_startcrossbowday", Command_StartCrossbowDay);

	HookEvent("weapon_fire", Event_WeaponTryFire, EventHookMode_Post);
	HookEvent("weapon_fire_on_empty", Event_WeaponTryFire, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);

	hcv_TeammatesAreEnemies      = FindConVar("mp_teammates_are_enemies");
	hcv_IgnoreRoundWinConditions = FindConVar("mp_ignore_round_win_conditions");
	hcv_TaserRechargeTime        = FindConVar("mp_taser_recharge_time");

	// Called when there's a need to inform plugins of day status. Not guaranteed to be the exact start or stop.
	// public void JailBreakDays_OnDayStatus(bool DayActive)

	fw_OnDayStatus = CreateGlobalForward("JailBreakDays_OnDayStatus", ET_Ignore, Param_Cell);

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

public void cvChange_Prefix(Handle convar, const char[] oldValue, const char[] newValue)
{
	FormatEx(PREFIX, sizeof(PREFIX), newValue);
}

public void OnClientCookiesCached(int client)
{
	ShowMessage[client] = GetClientInfoMessage(client);
}

public Action JBPack_OnShouldSpawnWeapons(int client) 
{
	if(DayActive <= LR_DAY)
		return Plugin_Continue;

	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	switch (DayActive)
	{
		case SCOUT_DAY:
		{
			int wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

			if (wep == -1)
				return Plugin_Continue;

			char Classname[64];
			GetEdictClassname(wep, Classname, sizeof(Classname));

			if (StrEqual(Classname, "weapon_ssg08"))
			{
				// buttons &= ~IN_ATTACK2;

				SetEntPropFloat(wep, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 1.0);
			}
		}

		case DODGEBALL_DAY:
		{
			buttons &= ~IN_ATTACK2;
		}
	}

	return Plugin_Continue;
}

public void OnMapStart()
{
	hTimer_StartDay = INVALID_HANDLE;

	CreateTimer(0.1, Timer_CheckHNRInfected, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action Timer_CheckHNRInfected(Handle hTimer)
{
	if(DayActive != HNR_DAY)
		return Plugin_Continue;

	else if(DayCountDown > 0)
		return Plugin_Continue;

	
	if(g_Infected == 0 || !IsClientInGame(g_Infected) || !IsPlayerAlive(g_Infected))
	{
		g_Infected = 0;
		g_fNextHNRDeath = GetGameTime() + 20.0;
		PrintCenterTextAll("<font color='#FFFFFF'>Nobody is infected\nThe first player to be hit will become infected.</font>");
		return Plugin_Continue;
	}

	float fTimeLeft = g_fNextHNRDeath - GetGameTime();

	if(fTimeLeft <= 0.0)
	{
		ForcePlayerSuicide(g_Infected);
		g_Infected = 0;
		return Plugin_Continue;
	}

	char sTimeColor[16];

	// In case someone changes the HnR timer, don't break colors...
	if(fTimeLeft <= 60.0)
		sTimeColor = "00FF00";

	if(fTimeLeft <= 10.0)
		sTimeColor = "FFFF00";

	if(fTimeLeft <= 5)
		sTimeColor = "FF0000";

	PrintCenterTextAll("<font color='#5e81ac'>Infected:</font> %N\n<font color='#5e81ac'>Time Left:</font><font color='#%s'> %.1f</font>", g_Infected, sTimeColor, fTimeLeft);

	SetEntityRenderMode(g_Infected, RENDER_GLOW);
	SetEntityRenderFx(g_Infected, RENDERFX_GLOWSHELL);

	SetEntityRenderColor(g_Infected, GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);

	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, SDKEvent_WeaponCanUse);
	SDKHook(client, SDKHook_PostThinkPost, SDKEvent_PostThinkPost);
	SDKHook(client, SDKHook_OnTakeDamage, SDKEvent_OnTakeDamage);
	SDKHook(client, SDKHook_TraceAttack, SDKEvent_TraceAttack);

	if (AreClientCookiesCached(client))
		ShowMessage[client] = GetClientInfoMessage(client);
}

public Action SDKEvent_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	if (!IsEntityPlayer(attacker))
	{
		if(DayActive == HNR_DAY)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}

	else if (DayActive <= LR_DAY)
		return Plugin_Continue;

	if(DayActive == HNR_DAY)
	{
		if(g_Infected == 0 || !IsClientInGame(g_Infected) || !IsPlayerAlive(g_Infected))
		{
			SetEntityRenderMode(attacker, RENDER_NORMAL);
			SetEntityRenderFx(attacker, RENDERFX_NONE);

			SetEntityRenderColor(attacker, 255, 255, 255, 255);

			g_Infected = victim;
			g_fNextHNRDeath = GetGameTime() + 20.0;
			ClientCommand(g_Infected, "play error");

			SetEntityRenderMode(g_Infected, RENDER_GLOW);
			SetEntityRenderFx(g_Infected, RENDERFX_GLOWSHELL);

			SetEntityRenderColor(g_Infected, GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);
		}
		else if(g_Infected == attacker)
		{
			SetEntityRenderMode(attacker, RENDER_NORMAL);
			SetEntityRenderFx(attacker, RENDERFX_NONE);

			SetEntityRenderColor(attacker, 255, 255, 255, 255);

			g_Infected = victim;

			ClientCommand(victim, "play error");

			ClientCommand(g_Infected, "play error");

			SetEntityRenderMode(g_Infected, RENDER_GLOW);
			SetEntityRenderFx(g_Infected, RENDERFX_GLOWSHELL);

			SetEntityRenderColor(g_Infected, GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);
		}

		damage = 0.0;
		return Plugin_Stop;
	}

	if (!Gangs_AreClientsSameGang(victim, attacker))
		return Plugin_Continue;

	bool OnlyGangLeft = true;

	int refClient = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_T)
			continue;

		if (refClient == 0)
		{
			refClient = i;

			continue;
		}

		else if (!Gangs_AreClientsSameGang(i, refClient))
		{
			OnlyGangLeft = false;

			break;
		}
	}

	if (!OnlyGangLeft)
	{
		damage *= 1.0 - Gangs_GetFFDamageDecrease(victim);

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action SDKEvent_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if (!IsEntityPlayer(attacker))
		return Plugin_Continue;

	else if (DayActive <= LR_DAY)
		return Plugin_Continue;

	if (GetClientTeam(attacker) != GetClientTeam(victim))
	{
		damage = 0.0;

		return Plugin_Stop;
	}

	else if (!DayHSOnly)
		return Plugin_Continue;

	else if ((hitgroup != 1 && DayActive != KNIFE_DAY) || (damage < 69 && DayActive == KNIFE_DAY))
	{
		damage = 0.0;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action CS_OnCSWeaponDrop(int client, int weapon)
{
	if (DayActive == SCOUT_DAY)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Eyal282_VoteCT_OnVoteCTStartAutoPre()
{
	if (DayActive >= LR_DAY)
	{
		if (hTimer_StartDay == INVALID_HANDLE && !IsVoteInProgress())
		{
			ServerCommand("sm_silentcvar mp_teammates_are_enemies 1");
		}

		return Plugin_Handled;
	}

	if(LR_isActive() || DayActive >= LR_DAY)
		ServerCommand("sm_silentcvar mp_death_drop_gun 0");

	else
		ServerCommand("sm_silentcvar mp_death_drop_gun 1");

	return Plugin_Continue;
}

public Action SDKEvent_WeaponCanUse(int client, int weapon)
{
	if (IgnorePlayerDeaths)    // The very moment a day begins.
		return Plugin_Continue;

	switch (DayActive)
	{
		case ZEUS_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (StrEqual(Classname, "weapon_taser"))
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}
		case DODGEBALL_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (StrEqual(Classname, "weapon_decoy"))
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}
		case SCOUT_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (StrEqual(Classname, "weapon_ssg08"))
				return Plugin_Continue;

			else if (GetAliveTeamCount(CS_TEAM_T) == 2 && strncmp(Classname, "weapon_knife", 12) == 0)
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}

		case KNIFE_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (strncmp(Classname, "weapon_knife", 12) == 0)
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}

		case WAR_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (StrEqual(Classname, DayWeapon))
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}

		case SDEAGLE_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (StrEqual(Classname, "weapon_deagle"))
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}

		case HNR_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));
			
			if (StrEqual(Classname, "weapon_ssg08"))
				return Plugin_Continue;

			else if (strncmp(Classname, "weapon_knife", 12) == 0)
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}

		case CROSSBOW_DAY:
		{
			char Classname[64];
			GetEdictClassname(weapon, Classname, sizeof(Classname));

			if (StrEqual(Classname, "weapon_m4a1"))
				return Plugin_Continue;

			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action SDKEvent_PostThinkPost(int client)
{
	if (DayActive == SCOUT_DAY)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if (weapon != -1)
			SetEntPropFloat(weapon, Prop_Send, "m_fAccuracyPenalty", 0.0);
	}

	return Plugin_Continue;
}

public Action Command_StartVoteDay(int client, int args)
{
	ServerCommand("sm_silentstopck");

	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartVoteDay();

	UC_PrintToChatAll("%s Vote Day has started! ", PREFIX);

	return Plugin_Handled;
}

public Action Command_StartFSDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartFSDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}

public Action Command_StartZeusDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartZeusDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}

public Action Command_StartDodgeballDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartDodgeballDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}

public Action Command_StartScoutDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartScoutDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}

public Action Command_StartKnifeDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	SelectHSKnifeDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}

void SelectHSKnifeDay()
{
	if (IsVoteInProgress())
	{
		ServerCommand("mp_restartgame 1");

		UC_PrintToChatAll("%s Error couldn't start vote for \x07Backstab \x01only, contact \x05Eyal282!", PREFIX);
		return;
	}

	DayActive = KNIFE_DAY;

	VoteDayStart = GetGameTime();

	BuildUpVoteHSKnifeMenu();

	VoteMenuToAll(hVoteBackstabMenu, 15);

	CreateTimer(1.0, Timer_DrawVoteHSKnifeMenu, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

public Action Timer_DrawVoteHSKnifeMenu(Handle hTimer)
{
	if (RoundToFloor((VoteDayStart + 15) - GetGameTime()) <= 0)
		return Plugin_Stop;

	else if (!IsVoteInProgress())
		return Plugin_Stop;

	BuildUpVoteHSKnifeMenu();

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

void BuildUpVoteHSKnifeMenu()
{
	if (hVoteBackstabMenu == INVALID_HANDLE)
		hVoteBackstabMenu = CreateMenu(KnifeDayHS_VoteHandler);

	SetMenuTitle(hVoteBackstabMenu, "Should Backstab Only rules apply? [%i]", RoundFloat((VoteDayStart + 15) - GetGameTime()));

	RemoveAllMenuItems(hVoteBackstabMenu);
	int VoteList[16];

	VoteList = CalculateVotes();

	char TempFormat[128];

	FormatEx(TempFormat, sizeof(TempFormat), "Yes [%i]", VoteList[0]);
	AddMenuItem(hVoteBackstabMenu, "", TempFormat);

	FormatEx(TempFormat, sizeof(TempFormat), "No [%i]", VoteList[1]);
	AddMenuItem(hVoteBackstabMenu, "", TempFormat);

	SetMenuPagination(hVoteBackstabMenu, MENU_NO_PAGINATION);
}

public int KnifeDayHS_VoteHandler(Handle hMenu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hMenu);
		hVoteBackstabMenu = INVALID_HANDLE;
	}
	else if (action == MenuAction_VoteCancel)
	{
		if (param1 == VoteCancel_NoVotes)
		{
			CheckVoteHSResult();
		}
	}
	else if (action == MenuAction_VoteEnd)
	{
		CheckVoteHSKnifeResult();
	}
	else if (action == MenuAction_Select)
	{
		votedItem[param1] = param2;
	}

	return 0;
}

void CheckVoteHSKnifeResult()
{
	int VoteList[16];

	VoteList = CalculateVotes();

	if (VoteList[0] > VoteList[1] || (VoteList[0] == VoteList[1] && GetRandomInt(0, 1) == 1))
		DayHSOnly = true;

	else
		DayHSOnly = false;

	UC_PrintToChatAll("%s Backstab Only is \x07%sactive!", PREFIX, DayHSOnly ? "" : "not ");

	StartKnifeDay();
}

public Action Command_StartWarDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	SelectWeaponWarDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}

public Action Command_StartSDeagleDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartSDeagleDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}


public Action Command_StartHNRDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartHNRDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}

public Action Command_StartCrossbowDay(int args)
{
	ServerCommand("sm_silentstopck");

	EndVoteDay();
	StopDay(false);
	Eyal282_VoteCT_StopVoteCT();
	ServerCommand("sm_egr");

	StartCrossbowDay();

	UC_PrintToChatAll("%s \x07%s\x05 has started! ", PREFIX, DayName[DayActive]);

	return Plugin_Handled;
}
public void StartFSDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = FS_DAY;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	IgnorePlayerDeaths = true;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;
}

public void StartZeusDay()
{
	SetConVarInt(hcv_TaserRechargeTime, 1);
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = ZEUS_DAY;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;
}

public void StartDodgeballDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = DODGEBALL_DAY;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;
}

public void StartScoutDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = SCOUT_DAY;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;
}

public void StartKnifeDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = KNIFE_DAY;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;
}

public void StartSDeagleDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = SDEAGLE_DAY;


	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;
}


public void StartHNRDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = HNR_DAY;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;

	g_Infected = 0;
}

public void StartCrossbowDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DayActive = CROSSBOW_DAY;

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

void SelectWeaponWarDay()
{
	if (IsVoteInProgress())
		CancelVote();

	DayActive = WAR_DAY;

	IgnorePlayerDeaths = true;

	DestroyAllWeapons();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;

	VoteDayStart = GetGameTime();

	BuildUpVoteWeaponMenu();

	VoteMenuToAll(hVoteWeaponMenu, 15);

	CreateTimer(1.0, Timer_DrawVoteWeaponMenu, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

public Action Timer_DrawVoteWeaponMenu(Handle hTimer)
{
	if (RoundToFloor((VoteDayStart + 15) - GetGameTime()) <= 0)
		return Plugin_Stop;

	else if (!IsVoteInProgress())
		return Plugin_Stop;

	BuildUpVoteWeaponMenu();

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

void BuildUpVoteWeaponMenu()
{
	if (hVoteWeaponMenu == INVALID_HANDLE)
		hVoteWeaponMenu = CreateMenu(VoteWeapon_VoteHandler);

	SetMenuTitle(hVoteWeaponMenu, "Choose which weapon will play: [%i]", RoundFloat((VoteDayStart + 15) - GetGameTime()));

	RemoveAllMenuItems(hVoteWeaponMenu);
	int VoteList[16];

	VoteList = CalculateVotes();

	char TempFormat[128];

	for (int i = 0; i < sizeof(WarDayWeapons); i++)
	{
		FormatEx(TempFormat, sizeof(TempFormat), "%s [%i]", WarDayWeapons[i].nickname, VoteList[i]);
		AddMenuItem(hVoteWeaponMenu, "", TempFormat);
	}

	SetMenuPagination(hVoteWeaponMenu, MENU_NO_PAGINATION);
}

public int VoteWeapon_VoteHandler(Handle hMenu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hMenu);
		hVoteWeaponMenu = INVALID_HANDLE;
	}
	else if (action == MenuAction_VoteCancel)
	{
		if (param1 == VoteCancel_NoVotes)
		{
			CheckVoteWeaponResult();
		}
	}
	else if (action == MenuAction_VoteEnd)
	{
		CheckVoteWeaponResult();
	}
	else if (action == MenuAction_Select)
	{
		votedItem[param1] = param2;
	}

	return 0;
}

void CheckVoteWeaponResult()
{
	int VoteList[16];

	VoteList = CalculateVotes();

	int winnerWeapon = 0;

	for (int i = 0; i < sizeof(WarDayWeapons); i++)
	{
		// We actually allow zero votes as we must get a result.
		if (/*VoteList[i] > 0 && */ VoteList[i] > VoteList[winnerWeapon] || (VoteList[i] == VoteList[winnerWeapon] && GetRandomInt(0, 1) == 1))
			winnerWeapon = i;
	}

	FormatEx(DayWeapon, sizeof(DayWeapon), WarDayWeapons[winnerWeapon].classname);

	UC_PrintToChatAll("%s The winning weapon is \x07%s", PREFIX, WarDayWeapons[winnerWeapon].nickname);

	SelectHSWarDay();
}

void SelectHSWarDay()
{
	if (IsVoteInProgress())
	{
		ServerCommand("mp_restartgame 1");

		UC_PrintToChatAll("%s Error couldn't start vote for \x07HS \x01only, contact \x05Eyal282!", PREFIX);
		return;
	}

	EndVoteDay();

	VoteDayStart = GetGameTime();

	BuildUpVoteHSMenu();

	VoteMenuToAll(hVoteHSMenu, 15);

	CreateTimer(1.0, Timer_DrawVoteHSMenu, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

public Action Timer_DrawVoteHSMenu(Handle hTimer)
{
	if (RoundToFloor((VoteDayStart + 15) - GetGameTime()) <= 0)
		return Plugin_Stop;

	else if (!IsVoteInProgress())
		return Plugin_Stop;

	BuildUpVoteHSMenu();

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

void BuildUpVoteHSMenu()
{
	if (hVoteHSMenu == INVALID_HANDLE)
		hVoteHSMenu = CreateMenu(WarDayHS_VoteHandler);

	SetMenuTitle(hVoteHSMenu, "Should HeadShot Only rules apply? [%i]", RoundFloat((VoteDayStart + 15) - GetGameTime()));

	RemoveAllMenuItems(hVoteHSMenu);
	int VoteList[16];

	VoteList = CalculateVotes();

	char TempFormat[128];

	FormatEx(TempFormat, sizeof(TempFormat), "Yes [%i]", VoteList[0]);
	AddMenuItem(hVoteHSMenu, "", TempFormat);

	FormatEx(TempFormat, sizeof(TempFormat), "No [%i]", VoteList[1]);
	AddMenuItem(hVoteHSMenu, "", TempFormat);

	SetMenuPagination(hVoteHSMenu, MENU_NO_PAGINATION);
}

public int WarDayHS_VoteHandler(Handle hMenu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hMenu);
		hVoteHSMenu = INVALID_HANDLE;
	}
	else if (action == MenuAction_VoteCancel)
	{
		if (param1 == VoteCancel_NoVotes)
		{
			CheckVoteHSResult();
		}
	}
	else if (action == MenuAction_VoteEnd)
	{
		CheckVoteHSResult();
	}
	else if (action == MenuAction_Select)
	{
		votedItem[param1] = param2;
	}

	return 0;
}

void CheckVoteHSResult()
{
	int VoteList[16];

	VoteList = CalculateVotes();

	if (VoteList[0] > VoteList[1] || (VoteList[0] == VoteList[1] && GetRandomInt(0, 1) == 1))
		DayHSOnly = true;

	else
		DayHSOnly = false;

	UC_PrintToChatAll("%s HS Only is \x07%sactive!", PREFIX, DayHSOnly ? "" : "not ");

	StartWarDay();
}

void StartWarDay()
{
	SetConVarBool(hcv_IgnoreRoundWinConditions, true);

	DestroyAllWeapons();

	IgnorePlayerDeaths = true;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsValidTeam(i))
			continue;

		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	IgnorePlayerDeaths = false;

	DayCountDown    = 10 + 1;
	hTimer_StartDay = CreateTimer(1.0, Timer_StartDay, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

public Action Timer_StartDay(Handle hTimer)
{
	DayCountDown--;

	if (DayCountDown == 0)
	{
		hTimer_StartDay = INVALID_HANDLE;

		int LivingT = GetAliveTeamCount(CS_TEAM_T);

		if (LivingT <= 1)
		{
			ServerCommand("mp_restartgame 1");

			DayActive = NULL_DAY;

			return Plugin_Stop;
		}

		Call_StartForward(fw_OnDayStatus);

		Call_PushCell(true);

		Call_Finish();

		ProcessPlayerDeath(0);

		SetConVarBool(hcv_TeammatesAreEnemies, true);

		PrintCenterTextAll("<font color='#FF0000'>%s has begun</font>", DayName[DayActive]);

		for (int i = 1; i <= MaxClients; i++)
		{
			ShowMessage[i] = true;
		}

		CreateTimer(0.1, Timer_InfoMessage, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

		return Plugin_Stop;
	}

	PrintCenterTextAll("<font color='#FFFFFF'>%s will begin in </font><font color='#FF0000'>%i</font> <font color='#FFFFFF'>second%s!</font><font color='#FF0000'></font>", DayName[DayActive], DayCountDown, DayCountDown == 1 ? "" : "s");

	return Plugin_Continue;
}

public Action Timer_InfoMessage(Handle hTimer)
{
	if (DayActive <= LR_DAY)
		return Plugin_Stop;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!ShowMessage[i])
			continue;

		ShowInfoMessage(i);
	}

	return Plugin_Continue;
}
void ShowInfoMessage(int client)
{
	if (DayActive <= LR_DAY)
		return;

	Handle hStyleRadio = GetMenuStyleHandle(MenuStyle_Radio);

	Handle hPanel = CreatePanel(hStyleRadio);

	SetPanelCurrentKey(hPanel, 9);
	DrawPanelItem(hPanel, "Exit Forever");

	SetPanelKeys(hPanel, (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 8));

	char TempFormat[2048];
	char PlayerFormat[1024];
	char GangsFormat[1024];
	int  gangsCount = 0;
	int  count      = 0;

	int  gangsPlayers[MAXPLAYERS + 1];
	char gangsNames[MAXPLAYERS + 1][64];

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_T)
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		int gangId = Gangs_GetClientGangId(i);
		if (gangId != GANGID_NULL)
		{
			int glowSlot = Gangs_GetClientGlowColorSlot(i);

			Gangs_GetClientGangName(i, gangsNames[glowSlot], sizeof(gangsNames[]));

			gangsPlayers[glowSlot]++;
		}
		Format(PlayerFormat, sizeof(PlayerFormat), "%s%N [%i HP]%s", PlayerFormat, i, GetEntityHealth(i), count % 2 == 1 ? "\n" : " | ");

		count++;
	}

	for (int i = 0; i < sizeof(gangsNames); i++)
	{
		if (gangsNames[i][0] == EOS)
			continue;

		Format(GangsFormat, sizeof(GangsFormat), "%s%s [%i players]%s", GangsFormat, gangsNames[i], gangsPlayers[i], gangsCount % 2 == 1 ? "\n" : " | ");

		gangsCount++;
	}
	// If count is divisible by 0, it gives " | " with a spacebar to delete, and not with divisible by one.
	PlayerFormat[strlen(PlayerFormat) - (1 + (count % 2))] = EOS;

	if (gangsCount > 0)
	{
		// If count is divisible by 0, it gives " | " with a spacebar to delete, and not with divisible by one.
		GangsFormat[strlen(GangsFormat) - (1 + (gangsCount % 2))] = EOS;

		FormatEx(TempFormat, sizeof(TempFormat), "%s!\n \nPlayers:\n%s \n \nGangs:\n%s\n ", DayName[DayActive], PlayerFormat, GangsFormat);
	}
	else
	{
		FormatEx(TempFormat, sizeof(TempFormat), "%s!\n \nPlayers:\n%s \n", DayName[DayActive], PlayerFormat);
	}

	SetPanelTitle(hPanel, TempFormat, false);

	SendPanelToClient(hPanel, client, PanelHandler_InfoMessage, 1);

	CloseHandle(hPanel);
}

public int PanelHandler_InfoMessage(Handle hPanel, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
	{
		CloseHandle(hPanel);

		return 0;
	}
	else if (action == MenuAction_Select)
	{
		if (item <= 5)
		{
			// Nasty hack that ignores double nades ( molotov and flashbang for example ) but I'll live for now...
			int weapon = GetPlayerWeaponSlot(client, item - 1);

			if (weapon != -1)
			{
				char Classname[64];

				GetEdictClassname(weapon, Classname, sizeof(Classname));

				FakeClientCommand(client, "use %s", Classname);
			}

			ShowInfoMessage(client);
		}
		if (item == 9)
		{
			ShowMessage[client] = false;
			EmitSoundToClient(client, MENU_EXIT_SOUND);    // Fauken panels...
		}
	}

	return 0;
}

stock void StartVoteDay()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if(!IsValidTeam(i))
			continue;
			
		ChangeClientTeam(i, CS_TEAM_T);

		CS_RespawnPlayer(i);
	}

	VoteDayStart = GetGameTime();

	ServerCommand("sm_hardopen");

	BuildUpVoteDayMenu();

	VoteMenuToAll(hVoteDayMenu, 15);

	CreateTimer(1.0, Timer_DrawVoteDayMenu, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}
stock void StopDay(bool Restart = true)
{
	GlowRemoved = false;

	if (DayActive > LR_DAY && IsVoteInProgress())
		CancelVote();

	DayActive = NULL_DAY;

	DayHSOnly = false;

	SetConVarBool(hcv_TeammatesAreEnemies, false);
	SetConVarBool(hcv_IgnoreRoundWinConditions, false);
	ResetConVar(hcv_TaserRechargeTime);

	if (Restart)
		ServerCommand("mp_restartgame 1");

	if (hTimer_StartDay != INVALID_HANDLE)
	{
		CloseHandle(hTimer_StartDay);
		hTimer_StartDay = INVALID_HANDLE;
	}

	Call_StartForward(fw_OnDayStatus);

	Call_PushCell(false);

	Call_Finish();
}

public Action Event_RoundStart(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	StopDay(false);

	return Plugin_Continue;
}

public Action Event_WeaponTryFire(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (DayActive <= LR_DAY)
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(weapon == -1)
		return Plugin_Continue;

	char Classname[64];
	GetEdictClassname(weapon, Classname, sizeof(Classname));

	SetClientAmmo(client, weapon, 999);

	return Plugin_Continue;
}

public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	if (DayActive == NULL_DAY || IgnorePlayerDeaths)
		return Plugin_Continue;

	int victim = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (DayActive == LR_DAY)
	{
		StopDay(true);

		return Plugin_Continue;
	}

	else if(DayActive == HNR_DAY)
	{
		if(g_Infected == victim)
			g_Infected = 0;
	}

	ProcessPlayerDeath(victim);

	return Plugin_Continue;
}

void ProcessPlayerDeath(int victim)
{
	int  LivingT      = GetAliveTeamCount(CS_TEAM_T);
	bool OnlyGangLeft = LivingT > 1;    // Don't care if the day is over

	int refClient = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_T)
			continue;

		if (refClient == 0)
		{
			refClient = i;

			continue;
		}

		else if (!Gangs_AreClientsSameGang(i, refClient))
		{
			OnlyGangLeft = false;

			break;
		}
	}

	if (OnlyGangLeft && !GlowRemoved)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			else if (!IsPlayerAlive(i))
				continue;

			Gangs_TryDestroyGlow(i);
		}

		char GangName[32];
		Gangs_GetClientGangName(refClient, GangName, sizeof(GangName));

		UC_PrintToChatAll("%s The gang \x07%s \x01won the \x05day! \x01it will now fight eachother.", PREFIX, GangName);

		GlowRemoved = true;
	}

	if (LivingT == 2 && DayActive == SCOUT_DAY)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			GivePlayerItem(i, "weapon_knife");
		}

		UC_PrintToChatAll("%s FIGHT FIGHT FIGHT", PREFIX);
		UC_PrintToChatAll("%s FIGHT FIGHT FIGHT", PREFIX);
		UC_PrintToChatAll("%s FIGHT FIGHT FIGHT", PREFIX);
		UC_PrintToChatAll("%s FIGHT FIGHT FIGHT", PREFIX);
		UC_PrintToChatAll("%s FIGHT FIGHT FIGHT", PREFIX);
	}

	if (LivingT != 1)
		return;

	int Winner = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_T)
			continue;

		Winner = i;
		break;
	}

	if (Winner != 0)
	{
		UC_PrintToChatAll("%s \x05%N \x01won the \x07%s! ", PREFIX, Winner, DayName[DayActive]);
		PrintCenterTextAll("<font color='#FF0000'>%N</font><font color='#FFFFFF'> won the %s!</font>", Winner, DayName[DayActive]);

		int Reward = 50 * GetPlayersCount();

		if (Gangs_HasGang(Winner))
		{
			char GangName[64];
			Gangs_GetClientGangName(Winner, GangName, sizeof(GangName));

			Gangs_GiveGangCredits(GangName, Reward);
			Gangs_AddClientDonations(Winner, Reward);

			Gangs_PrintToChatGang(GangName, "%s \x05%N \x01has earned \x07%i \x01honor for his gang by winning the \x07%s! ", PREFIX, Winner, Reward, DayName[DayActive]);
		}

		Reward = RoundFloat(float(Reward) / 1.5);

		UC_PrintToChatAll("%s \x05%N \x01has earned \x07%i \x01gang honor by winning the \x07%s! ", PREFIX, Winner, Reward, DayName[DayActive]);

		Gangs_GiveClientCredits(Winner, Reward);

		RequestFrame(Frame_MoveSecondWinnerToCT, victim);

		DayActive = LR_DAY;

		UC_StripPlayerWeapons(Winner);

		// Fixes awful crossbow bug. Because the crossbow model is set on client instead of on weapon, keeping the M4, or being stripped of the M4 makes the M4 permanent until you swap...
		// ... to another weapon.
		GivePlayerItem(Winner, "weapon_knife");

	}
	else
		ServerCommand("mp_restartgame 1");
}

// We don't immediately change team to prevent player_death of gangs from giving 100 honor.
public void Frame_MoveSecondWinnerToCT(int victim)
{
	if (!IsClientInGame(victim))    // victim can't be replaced in one frame, no need for user id.
		return;

	ChangeClientTeam(victim, CS_TEAM_CT);

	RequestFrame(Frame_RespawnASAP, victim);
}

public void Frame_RespawnASAP(int victim)
{
	if (!IsClientInGame(victim))    // victim can't be replaced in one frame, no need for user id.
		return;

	CS_RespawnPlayer(victim);

	LR_CheckAnnounce();
}

public Action Event_PlayerHurt(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client;
	if (DayActive != NULL_DAY)
	{
		client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

		SetEntityMaxHealth(client, GetEntityHealth(client));
	}

	if (DayActive != SDEAGLE_DAY)
		return Plugin_Continue;

	int attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

	if (attacker == 0 || client == 0)
		return Plugin_Continue;

	BitchSlapBackwards(client, attacker, 5150.0);

	return Plugin_Continue;
}

public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int UserId = GetEventInt(hEvent, "userid");

	int client = GetClientOfUserId(UserId);

	if(client == 0)
		return Plugin_Continue;
	
	else if(DayActive <= LR_DAY)
		return Plugin_Continue;

	if(!IgnorePlayerDeaths && IsPlayerAlive(client) && DayCountDown <= 0)
	{
		ForcePlayerSuicide(client);
	}

	CreateTimer(0.1, Timer_PlayerSpawn, UserId, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action Timer_PlayerSpawn(Handle hTimer, int UserId)
{
	if (DayActive <= LR_DAY)
		return Plugin_Continue;

	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return Plugin_Continue;

	switch (DayActive)
	{
		case FS_DAY, KNIFE_DAY:
		{
			UC_StripPlayerWeapons(client);

			GivePlayerItem(client, "weapon_knife");
		}

		case ZEUS_DAY:
		{
			UC_StripPlayerWeapons(client);

			GivePlayerItem(client, "weapon_taser");
		}
		case DODGEBALL_DAY:
		{
			UC_StripPlayerWeapons(client);

			GivePlayerItem(client, "weapon_decoy");

			SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
		}

		case SCOUT_DAY:
		{
			int LivingT = 0;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				else if (!IsValidTeam(i))
					continue;

				LivingT++;
			}

			UC_StripPlayerWeapons(client);

			GivePlayerItem(client, "weapon_ssg08");

			if (LivingT == 2)
				GivePlayerItem(client, "weapon_knife");
		}

		case WAR_DAY:
		{
			UC_StripPlayerWeapons(client);

			GivePlayerItem(client, DayWeapon);

			SetEntityHealth(client, 250);
		}

		case SDEAGLE_DAY:
		{
			UC_StripPlayerWeapons(client);

			GivePlayerItem(client, "weapon_deagle");

			SetEntityHealth(client, 350);
		}

		case HNR_DAY:
		{
			UC_StripPlayerWeapons(client);

			GivePlayerItem(client, "weapon_ssg08");
			GivePlayerItem(client, "weapon_knife");

			SetEntityHealth(client, 100);
		}

		case CROSSBOW_DAY:
		{
			UC_StripPlayerWeapons(client);

			// The crossbow itself is given in "OnShouldPlayerHaveCrossbow"

			GivePlayerItem(client, "weapon_m4a1");

			SetEntityHealth(client, 350);
		}
	}

	SetEntityMaxHealth(client, GetEntityHealth(client));

	return Plugin_Continue;
}

public bool OnShouldPlayerHaveCrossbow(int client)
{
	if(DayActive == CROSSBOW_DAY)
		return true;

	return false;
}

public void OnEntityCreated(int entity, const char[] Classname)
{
	if (StrEqual(Classname, "decoy_projectile"))
	{
		SDKHook(entity, SDKHook_SpawnPost, SpawnPost_Decoy);
	}
}

public void SpawnPost_Decoy(int entity)
{
	SDKUnhook(entity, SDKHook_SpawnPost, SpawnPost_Decoy);

	if (DayActive != DODGEBALL_DAY)
		return;

	else if (!IsValidEdict(entity))
		return;

	int thrower = GetEntityOwner(entity);

	if (thrower == -1)
		return;

	UC_StripPlayerWeapons(thrower);
	GivePlayerItem(thrower, "weapon_decoy");
	SetEntPropString(entity, Prop_Data, "m_iName", "Dodgeball");
	RequestFrame(Decoy_FixAngles, entity);
	SDKHook(entity, SDKHook_TouchPost, Event_DecoyTouch);
	RequestFrame(Decoy_Chicken, entity);
}

public void Decoy_Chicken(int entity)
{
	SetEntityModel(entity, DodgeballModel);
}

public void Event_DecoyTouch(int decoy, int toucher)
{
	char Classname[50];
	GetEdictClassname(toucher, Classname, sizeof(Classname));
	if (!IsPlayer(toucher))
	{
		int SolidFlags = GetEntProp(toucher, Prop_Send, "m_usSolidFlags");

		if (!(SolidFlags & 0x0004))    // Buy zone and shit..
		{
			if (StrEqual(Classname, "func_breakable"))
			{
				AcceptEntityInput(decoy, "Kill");
				return;
			}
			SetEntPropString(decoy, Prop_Data, "m_iName", "Dodgeball NoKill");
		}
	}
	else
	{
		char TargetName[50];
		GetEntPropString(decoy, Prop_Data, "m_iName", TargetName, sizeof(TargetName));

		if (StrContains(TargetName, "NoKill", false) != -1)
			return;

		int thrower = GetEntityOwner(decoy);

		if (thrower == toucher)
			return;

		FinishHim(toucher, thrower);
		AcceptEntityInput(decoy, "Kill");
	}
}

public void Decoy_FixAngles(int entity)
{
	if (!IsValidEntity(entity))
		return;

	float Angles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

	Angles[2] = 0.0;
	Angles[0] = 0.0;
	SetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

	RequestFrame(Decoy_FixAngles, entity);
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

stock int GetPlayersCount()
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (GetClientTeam(i) != CS_TEAM_T && GetClientTeam(i) != CS_TEAM_CT)
			continue;

		count++;
	}

	return count;
}

stock bool IsValidTeam(int client)
{
	return (GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT);
}

stock void UC_StripPlayerWeapons(int client)
{
	for (int i = 0; i <= 5; i++)
	{
		int weapon = GetPlayerWeaponSlot(client, i);

		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
			i--;    // This is to strip all nades, and zeus & knife
		}
	}
}

stock void SetClientAmmo(int client, int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);    // set reserve to 0

	int ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammotype == -1) return;

	SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}

public void BitchSlapBackwards(int victim, int weapon, float strength)    // Stole the dodgeball tactic from https://forums.alliedmods.net/showthread.php?t=17116
{
	float origin[3], velocity[3];
	GetEntPropVector(weapon, Prop_Data, "m_vecOrigin", origin);
	GetVelocityFromOrigin(victim, origin, strength, velocity);
	velocity[2] = strength / 10.0;

	TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);
}

stock bool GetVelocityFromOrigin(int ent, float fOrigin[3], float fSpeed, float fVelocity[3])    // Will crash server if fSpeed = -1.0
{
	float fEntOrigin[3];
	GetEntPropVector(ent, Prop_Data, "m_vecOrigin", fEntOrigin);

	// Velocity = Distance / Time

	float fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];

	float fTime = (GetVectorDistance(fEntOrigin, fOrigin) / fSpeed);

	if (fTime == 0.0)
		fTime = 1 / (fSpeed + 1.0);

	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;

	return (fVelocity[0] && fVelocity[1] && fVelocity[2]);
}

stock bool IsEntityPlayer(int entity)
{
	if (entity == 0 || entity > MaxClients)
		return false;

	return true;
}

stock void SetEntityMaxHealth(int entity, int amount)
{
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", amount);
}

stock int GetEntityHealth(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iHealth");
}

stock void StringToLower(char[] sSource)
{
	for (int i = 0; i < strlen(sSource); i++)
	{
		if (sSource[i] == '\0')
			break;

		sSource[i] = CharToLower(sSource[i]);
	}
}

stock int[] CalculateVotes()
{
	int arr[16];

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

// Destroys all weapons and their creator entities.
stock void DestroyAllWeapons()
{
	if (DayActive == FS_DAY)
		return;

	int Count = GetEntityCount();

	for (int i = MaxClients + 1; i < Count; i++)
	{
		if (!IsValidEntity(i))
			continue;

		char Classname[64];
		GetEdictClassname(i, Classname, sizeof(Classname));

		if (StrEqual(Classname, "player_weaponstrip")/* || StrContains(Classname, "weapon_") != -1*/)
			AcceptEntityInput(i, "Kill");
	}
}

stock void FinishHim(int victim, int attacker)
{
	if (!IsClientInGame(victim) || !IsClientInGame(attacker))
		return;

	int inflictor = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	SetEntityHealth(victim, 100);
	SetClientGodmode(victim);
	SetClientNoclip(victim);
	SDKHooks_TakeDamage(victim, inflictor, attacker, 32767.0, DMG_SLASH);
}

stock bool FindPlayerWeapon(int attacker, char[] buffer, int length)
{
	int weapon = -1;

	weapon = GetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon");

	if (weapon != -1)
	{
		GetEdictClassname(weapon, buffer, length);
		return true;
	}

	Format(buffer, length, "weapon_knife");
	return false;
}

stock bool IsPlayer(int client)
{
	if (client <= 0)
		return false;

	else if (client > MaxClients)
		return false;

	return true;
}

stock int GetEntityOwner(int entity)
{
	return GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
}

stock void SetClientGodmode(int client, bool godmode = false)
{
	if (godmode)
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);

	else
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
}

stock void SetClientNoclip(int client, bool noclip = false)
{
	if (noclip)
	{
		SetEntProp(client, Prop_Send, "movetype", MOVETYPE_NOCLIP, 1);
	}
	else
		SetEntProp(client, Prop_Send, "movetype", 1, 1);
}

stock bool GetClientInfoMessage(int client)
{
	Handle cpInfoMsg = FindClientCookie("LastRequest_InfoMessage");

	if (cpInfoMsg == INVALID_HANDLE)
		return false;

	char strInfoMessage[50];
	GetClientCookie(client, cpInfoMsg, strInfoMessage, sizeof(strInfoMessage));

	if (strInfoMessage[0] == EOS)
	{
		SetClientInfoMessage(client, true);
		return true;
	}

	return view_as<bool>(StringToInt(strInfoMessage));
}

stock bool SetClientInfoMessage(int client, bool value)
{
	Handle cpInfoMsg = FindClientCookie("LastRequest_InfoMessage");

	if (cpInfoMsg == INVALID_HANDLE)
		return false;

	char strInfoMessage[50];

	IntToString(view_as<int>(value), strInfoMessage, sizeof(strInfoMessage));
	SetClientCookie(client, cpInfoMsg, strInfoMessage);

	return value;
}