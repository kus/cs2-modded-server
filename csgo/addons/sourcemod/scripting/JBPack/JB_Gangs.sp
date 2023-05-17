

#include <cstrike>
#include <eyal-jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <smlib>
#include <sourcemod>

#define EF_BONEMERGE       (1 << 0)
#define EF_NOSHADOW        (1 << 4)
#define EF_NORECEIVESHADOW (1 << 6)
#define EF_PARENT_ANIMATES (1 << 9)

#define GANG_RENAME_PRICE 2500
#define GANG_PREFIX_PRICE 25000

#define SECONDS_IN_A_WEEK 604800

#pragma semicolon 1
#pragma newdecls  required

char NET_WORTH_ORDER_BY_FORMULA[512];

bool dbFullConnected = false;

native bool JailBreakDays_IsDayActive();

// We must allow 64 total colors.
int GangColors[][] = {
	{255,  0,   0  }, // red
	{ 0,   255, 0  }, // green
	{ 137, 209, 183}, // green כהה
	{ 4,   1,   254}, // Blue
	{ 194, 1,   254}, // perpol
	{ 194, 255, 254}, // d תכלת
	{ 75,  150, 102}, // d ירוק בהיר
	{ 47,  44,  16 }, // d חום
	{ 193, 168, 16 }, // d צהוב זהב
	{ 193, 103, 16 }, // d כתום
	{ 193, 103, 111}, // d pink
	{ 193, 36,  111}, // d pink כהה
	{ 193, 255, 111}, // d green כהה
	{ 253, 255, 111}, // d Yellow כהה
	{ 10,  107, 111}, // d תכלת כהה
	{ 126, 3,   0  }, // d חום חזק
	{ 126, 108, 170}, // d סגלגל
	{ 240, 156, 20 }, // d כתמתם
	{ 234, 30,  80 }, // d ורדורד
	{ 156, 120, 80 }, // d חםחם
	{ 156, 120, 229}, // d סגול פנים
	{ 156, 120, 229}, // d ורוד כהה
	{ 33,  120, 229}, // d כחלכל
	{ 33,  120, 7  }, // d ירקרק
	{ 254, 120, 7  }, // d כתום חזק
	{ 161, 207, 254}, // d תכלת חלש
	{ 254, 207, 254}, // d ורוד פוקסי
	{ 137, 147, 148}, // d אפור
	{ 252, 64,  100}, // d אדם דם
	{ 58,  64,  100}, // d אפור חלש
	{ 55,  51,  72 }, // d שחרחר
	{ 145, 127, 162}  // d סגל גל בהיר
};

Database dbGangs;

Handle hcv_HonorPerKill = INVALID_HANDLE;

#define MIN_PLAYERS_FOR_GC 3

#define GANG_COSTCREATE 10000

#define GANG_HEALTHCOST     7500
#define GANG_HEALTHMAX      5
#define GANG_HEALTHINCREASE 2

#define GANG_COOLDOWNCOST     2000
#define GANG_COOLDOWNMAX      10
#define GANG_COOLDOWNINCREASE 2.0

#define GANG_NADECOST     5000
#define GANG_NADEMAX      10
#define GANG_NADEINCREASE 1.5

#define GANG_GETCREDITSCOST     6000
#define GANG_GETCREDITSMAX      10
#define GANG_GETCREDITSINCREASE 15

#define GANG_FRIENDLYFIRECOST     7500
#define GANG_FRIENDLYFIREMAX      5
#define GANG_FRIENDLYFIREINCREASE 20

#define GANG_INITSIZE     4
#define GANG_SIZEINCREASE 1
#define GANG_SIZECOST     6500
#define GANG_SIZEMAX      3

char PREFIX[256];
char MENU_PREFIX[64];

Handle hcv_Prefix     = INVALID_HANDLE;
Handle hcv_MenuPrefix = INVALID_HANDLE;

// Admin Variables.

bool ClientSpyGang[MAXPLAYERS + 1];

// Variables about the client's gang.

int  ClientRank[MAXPLAYERS + 1], ClientHonor[MAXPLAYERS + 1], ClientGangHonor[MAXPLAYERS + 1], ClientGangNextWeekly[MAXPLAYERS + 1];
bool ClientLoadedFromDb[MAXPLAYERS + 1];
int  ClientGangId[MAXPLAYERS + 1];

char ClientGang[MAXPLAYERS + 1][32], ClientMotd[MAXPLAYERS + 1][100], ClientPrefix[MAXPLAYERS + 1][32];
int  ClientPrefixMethod[MAXPLAYERS + 1];

int ClientHealthPerkT[MAXPLAYERS + 1], ClientCooldownPerk[MAXPLAYERS + 1], ClientNadePerkT[MAXPLAYERS + 1], ClientHealthPerkCT[MAXPLAYERS + 1], ClientGetHonorPerk[MAXPLAYERS + 1], ClientGangSizePerk[MAXPLAYERS + 1], ClientFriendlyFirePerk[MAXPLAYERS + 1];

// ClientAccessManage basically means if the client can either invite, kick, upgrade, promote or MOTD.
int ClientAccessManage[MAXPLAYERS + 1], ClientAccessInvite[MAXPLAYERS + 1], ClientAccessKick[MAXPLAYERS + 1], ClientAccessPromote[MAXPLAYERS + 1], ClientAccessUpgrade[MAXPLAYERS + 1], ClientAccessMOTD[MAXPLAYERS + 1];

// Extra Variables.
bool GangAttemptLeave[MAXPLAYERS + 1], GangAttemptDisband[MAXPLAYERS + 1], GangAttemptStepDown[MAXPLAYERS + 1], MotdShown[MAXPLAYERS + 1];
int  GangStepDownTarget[MAXPLAYERS + 1];
char GangCreateName[MAXPLAYERS + 1][32];
int  ClientMembersCount[MAXPLAYERS + 1];
int  ClientWhiteGlow[MAXPLAYERS + 1], ClientColorfulGlow[MAXPLAYERS + 1], ClientGlowColorSlot[MAXPLAYERS + 1];    // White glow is how gang members see themselves, colorful glow is how other players see gang members.

float ClientNextMOTD[MAXPLAYERS + 1] = { 0.0, ... };

int ClientActionEdit[MAXPLAYERS + 1];

bool CachedSpawn[MAXPLAYERS + 1], CanGetHonor[MAXPLAYERS + 1];

ConVar hcv_WeeklyTax;

Handle Trie_Donated;
Handle Trie_DonatedWeek;

public Plugin myinfo =
{
	name        = "JB Gangs",
	author      = "Eyal282",
	description = "Gang System for JailBreak",
	version     = "1.0",
	url         = "NULL"
};

public void OnPluginStart()
{
	Format(NET_WORTH_ORDER_BY_FORMULA, sizeof(NET_WORTH_ORDER_BY_FORMULA), "%i + GangHonor + GangHealthPerkT*0.5*%i*(GangHealthPerkT+1) + GangHealthPerkCT*0.5*%i*(GangHealthPerkCT+1) + GangCooldownPerk*0.5*%i*(GangCooldownPerk+1) + GangNadePerkT*0.5*%i*(GangNadePerkT+1) + GangGetHonorPerk*0.5*%i*(GangGetHonorPerk+1) + GangSizePerk*0.5*%i*(GangSizePerk+1) + GangFFPerk*0.5*%i*(GangFFPerk+1)", GANG_COSTCREATE, GANG_HEALTHCOST, GANG_HEALTHCOST, GANG_COOLDOWNCOST, GANG_NADECOST, GANG_GETCREDITSCOST, GANG_SIZECOST, GANG_FRIENDLYFIRECOST);

	dbFullConnected = false;

	dbGangs = null;

	ConnectDatabase();

	AddCommandListener(CommandListener_Say, "say");
	AddCommandListener(CommandListener_Say, "say_team");

	RegConsoleCmd("sm_donategang", Command_DonateGang);
	RegConsoleCmd("sm_gifthonor", Command_GiftHonor);
	RegConsoleCmd("sm_motdgang", Command_MotdGang);
	RegConsoleCmd("sm_prefixgang", Command_PrefixGang);
	RegConsoleCmd("sm_renamegang", Command_RenameGang);
	RegConsoleCmd("sm_creategang", Command_CreateGang);
	RegConsoleCmd("sm_confirmleavegang", Command_LeaveGang);
	RegConsoleCmd("sm_confirmdisbandgang", Command_DisbandGang);
	RegConsoleCmd("sm_confirmstepdowngang", Command_StepDown);
	RegConsoleCmd("sm_gang", Command_Gang);
	RegConsoleCmd("sm_gangs", Command_Gang);
	RegConsoleCmd("sm_gethonor", Command_GC);
	RegConsoleCmd("sm_gc", Command_GC);

	RegAdminCmd("sm_spygang", Command_SpyGang, ADMFLAG_ROOT, "Allows you to spy gang chats.");
	RegAdminCmd("sm_breachgang", Command_BreachGang, ADMFLAG_ROOT, "Breaches into a gang as a member.");
	RegAdminCmd("sm_breachgangrank", Command_BreachGangRank, ADMFLAG_ROOT, "Sets your rank within your gang.");

	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_changename", Event_ChangeName, EventHookMode_Pre);
	HookEvent("player_ping", Event_PlayerPingPre, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);

	AutoExecConfig_SetFile("JB_Gangs", "sourcemod/JBPack");

	hcv_HonorPerKill = UC_CreateConVar("gang_system_honor_per_kill", "100", "Amount of honor you get per kill as T", FCVAR_PROTECTED);

	hcv_WeeklyTax = UC_CreateConVar("gang_system_weekly_price", "10000", "Amount of honor a gang pays per week. If a gang reaches negative honor, it is temporarily shut down, and not disbanded", FCVAR_PROTECTED);

	AutoExecConfig_ExecuteFile();

	AutoExecConfig_CleanFile();

	Trie_Donated     = CreateTrie();
	Trie_DonatedWeek = CreateTrie();
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

public Action Event_PlayerPingPre(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	//if (GetEventBool(hEvent, "filtered_by_sourcemod_plugin"))
	//	return Plugin_Continue;

	int entity = GetEventInt(hEvent, "entityid");

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hPlayer");

	if (owner == -1)
		return Plugin_Continue;

	else if (GetClientTeam(owner) != CS_TEAM_T)
		return Plugin_Continue;

	// If player doesn't have a gang, OR if player is in debt.
	if (!AreClientsSameGang(owner, owner))
	{
		AcceptEntityInput(entity, "Kill");

		return Plugin_Handled;
	}

	SDKHook(entity, SDKHook_SetTransmit, SDKEvent_PingSetTransmit);

	for(int i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;

		else if(IsFakeClient(i))
			continue;

		else if(!AreClientsSameGang(i, owner))
			continue;

		Event newEvent = CreateEvent("player_ping", true);

		SetEventInt(newEvent, "userid", GetEventInt(hEvent, "userid"));
		SetEventInt(newEvent, "entityid", GetEventInt(hEvent, "entityid"));

		SetEventFloat(newEvent, "x", GetEventFloat(hEvent, "x"));
		SetEventFloat(newEvent, "y", GetEventFloat(hEvent, "y"));
		SetEventFloat(newEvent, "z", GetEventFloat(hEvent, "z"));

		SetEventBool(newEvent, "urgent", GetEventBool(hEvent, "urgent"));

		//SetEventBool(newEvent, "filtered_by_sourcemod_plugin", true);

		newEvent.FireToClient(i);

		CloseHandle(newEvent);
	}

	return Plugin_Handled;
}

public Action SDKEvent_PingSetTransmit(int pingEntity, int viewer)
{
	if (!IsPlayer(viewer))
		return Plugin_Continue;

	int owner = GetEntPropEnt(pingEntity, Prop_Send, "m_hPlayer");

	if (owner == -1)
		return Plugin_Continue;

	else if (!AreClientsSameGang(owner, viewer))
		return Plugin_Handled;

	return Plugin_Continue;
}

public void OnMapStart()
{
	CreateTimer(1.0, Timer_CheckWeekly, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(31.0, Timer_CheckWeekly, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	for (int i = 1; i <= MaxClients; i++)
	{
		ClientNextMOTD[i] = 0.0;
	}
}

public Action Timer_CheckWeekly(Handle hTimer)
{
	char sQuery[256];
	SQL_FormatQuery(dbGangs, sQuery, sizeof(sQuery), "SELECT GangId, GangHonor FROM GangSystem_Gangs WHERE GangNextWeekly < %i", GetTime());
	dbGangs.Query(SQLCB_CheckWeekly, sQuery);

	return Plugin_Continue;
}

public void SQLCB_CheckWeekly(Handle owner, Handle hndl, char[] error, any data)
{
	if (hndl == null)
	{
		LogError(error);

		return;
	}

	if (SQL_GetRowCount(hndl) == 0)
		return;

	while (SQL_FetchRow(hndl))
	{
		int GangId = SQL_FetchInt(hndl, 0);

		char sQuery[256];
		SQL_FormatQuery(dbGangs, sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET GangHonor = GangHonor - %i, GangNextWeekly = %i WHERE GangId = %i", GetConVarInt(hcv_WeeklyTax), GetTime() + SECONDS_IN_A_WEEK, GangId);

		Handle DP = CreateDataPack();

		WritePackCell(DP, GangId);

		dbGangs.Query(SQLCB_GangDonated, sQuery, DP);
	}
}

public void OnPluginEnd()
{
	for (int i = 1; i < MAXPLAYERS + 1; i++)
	{
		TryDestroyGlow(i);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		TryRemoveGangPrefix(i);
	}
}

public void LastRequest_OnLRStarted(int Prisoner, int Guard)
{
	///	SDKUnhook(Prisoner, SDKHook_PostThink, Event_PreThinkT);
	//	SDKUnhook(Prisoner, SDKHook_PostThink, Event_PreThinkCT);
	// SDKUnhook(Guard, SDKHook_PreThink, Event_PreThinkT);
	// SDKUnhook(Guard, SDKHook_PreThink, Event_PreThinkCT);
}

public void Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (client == 0)
		return;

	CachedSpawn[client] = false;
	RequestFrame(Event_PlayerSpawnPlusFrame, GetEventInt(hEvent, "userid"));
}

public void Event_PlayerSpawnPlusFrame(int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (CachedSpawn[client])
		return;

	else if (!IsValidPlayer(client))
		return;

	else if (!IsPlayerAlive(client))
		return;

	// No gang or in debt
	else if (!AreClientsSameGang(client, client))
		return;

	CachedSpawn[client] = true;

	TryDestroyGlow(client);

	switch (GetClientTeam(client))
	{
		case CS_TEAM_T:
		{
			if (ClientHealthPerkT[client] > 0)
			{
				SetEntityHealth(client, GetEntityHealth(client) + (ClientHealthPerkT[client] * GANG_HEALTHINCREASE));
				SetEntityMaxHealth(client, GetEntityMaxHealth(client) + (ClientHealthPerkT[client] * GANG_HEALTHINCREASE));
			}

			if (ClientNadePerkT[client] > 0)
			{
				if (GetRandomFloat(0.0, 100.0) <= (float(ClientNadePerkT[client]) * GANG_NADEINCREASE))
				{
					switch (GetRandomInt(0, 3))
					{
						case 0: GivePlayerItem(client, "weapon_incgrenade");
						case 1: GivePlayerItem(client, "weapon_flashbang");
						case 2: GivePlayerItem(client, "weapon_hegrenade");
						case 3: GivePlayerItem(client, "weapon_decoy");
					}

					UC_PrintToChat(client, " %s \x05You \x01spawned with a random nade for being in a \x07gang! ", PREFIX);
				}
			}

			if (AreClientsSameGang(client, client) && JailBreakDays_IsDayActive())
				CreateGlow(client);
		}
		case CS_TEAM_CT:
		{
			if (ClientHealthPerkCT[client] > 0)
			{
				SetEntityHealth(client, GetEntityHealth(client) + (ClientHealthPerkCT[client] * GANG_HEALTHINCREASE));
				SetEntityMaxHealth(client, GetEntityMaxHealth(client) + (ClientHealthPerkCT[client] * GANG_HEALTHINCREASE));
			}
		}
	}
}

public Action Event_ChangeName(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (client == 0)
		return Plugin_Continue;

	else if (ClientPrefix[client][0] == EOS)
		return Plugin_Continue;

	char NewName[64];

	GetEventString(hEvent, "newname", NewName, sizeof(NewName));

	if (StrContains(NewName, ClientPrefix[client]) == 0)    // Client's name starts with the prefix.
		return Plugin_Continue;

	Format(NewName, sizeof(NewName), "%s%s", ClientPrefix[client], NewName);

	SetClientNameHidden(client, NewName);

	SetEventString(hEvent, "newname", NewName);

	SetEventBroadcast(hEvent, true);

	return Plugin_Changed;
}

void CreateGlow(int client)
{
	if (ClientWhiteGlow[client] != 0 || ClientColorfulGlow[client] != 0)
	{
		TryDestroyGlow(client);
		ClientWhiteGlow[client]    = 0;
		ClientColorfulGlow[client] = 0;
	}

	CreateWhiteGlow(client);

	CreateColorfulGlow(client);
}

void CreateWhiteGlow(int client)
{
	char  Model[PLATFORM_MAX_PATH];
	float Origin[3], Angles[3];

	// Get the original model path
	GetEntPropString(client, Prop_Data, "m_ModelName", Model, sizeof(Model));

	// Find the location of the weapon
	GetClientEyePosition(client, Origin);
	Origin[2] -= 75.0;
	GetClientEyeAngles(client, Angles);
	int GlowEnt = CreateEntityByName("prop_dynamic_glow");

	DispatchKeyValue(GlowEnt, "model", Model);
	DispatchKeyValue(GlowEnt, "disablereceiveshadows", "1");
	DispatchKeyValue(GlowEnt, "disableshadows", "1");
	DispatchKeyValue(GlowEnt, "solid", "0");
	DispatchKeyValue(GlowEnt, "spawnflags", "256");
	DispatchKeyValue(GlowEnt, "renderamt", "0");
	SetEntProp(GlowEnt, Prop_Send, "m_CollisionGroup", 11);

	// Spawn and teleport the entity
	DispatchSpawn(GlowEnt);

	int fEffects = GetEntProp(GlowEnt, Prop_Send, "m_fEffects");
	SetEntProp(GlowEnt, Prop_Send, "m_fEffects", fEffects | EF_BONEMERGE | EF_NOSHADOW | EF_NORECEIVESHADOW | EF_PARENT_ANIMATES);

	// Give glowing effect to the entity
	SetEntProp(GlowEnt, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(GlowEnt, Prop_Send, "m_nGlowStyle", 0);
	SetEntPropFloat(GlowEnt, Prop_Send, "m_flGlowMaxDist", 10000.0);

	// Set glowing color
	SetVariantColor({ 255, 255, 255, 255 });
	AcceptEntityInput(GlowEnt, "SetGlowColor");

	// Set the activator and group the entity
	SetVariantString("!activator");
	AcceptEntityInput(GlowEnt, "SetParent", client);

	SetVariantString("primary");
	AcceptEntityInput(GlowEnt, "SetParentAttachment", GlowEnt, GlowEnt, 0);

	AcceptEntityInput(GlowEnt, "TurnOn");

	SetEntPropEnt(GlowEnt, Prop_Send, "m_hOwnerEntity", client);

	char iName[32];

	FormatEx(iName, sizeof(iName), "Gang-Glow %i", GetClientUserId(client));
	SetEntPropString(GlowEnt, Prop_Data, "m_iName", iName);

	SDKHook(GlowEnt, SDKHook_SetTransmit, Hook_ShouldSeeWhiteGlow);

	for (float i = 0.1; i < 5.0; i += 0.2)
	{
		CreateTimer(i, Timer_CheckGlowPlayerModel, EntIndexToEntRef(GlowEnt), TIMER_FLAG_NO_MAPCHANGE);
	}

	ClientWhiteGlow[client] = GlowEnt;
}

void CreateColorfulGlow(int client)
{
	char  Model[PLATFORM_MAX_PATH];
	float Origin[3], Angles[3];

	// Get the original model path
	GetEntPropString(client, Prop_Data, "m_ModelName", Model, sizeof(Model));

	// Find the location of the weapon
	GetClientEyePosition(client, Origin);
	Origin[2] -= 75.0;
	GetClientEyeAngles(client, Angles);
	int GlowEnt = CreateEntityByName("prop_dynamic_glow");

	DispatchKeyValue(GlowEnt, "model", Model);
	DispatchKeyValue(GlowEnt, "disablereceiveshadows", "1");
	DispatchKeyValue(GlowEnt, "disableshadows", "1");
	DispatchKeyValue(GlowEnt, "solid", "0");
	DispatchKeyValue(GlowEnt, "spawnflags", "256");
	DispatchKeyValue(GlowEnt, "renderamt", "0");
	SetEntProp(GlowEnt, Prop_Send, "m_CollisionGroup", 11);

	// Spawn and teleport the entity
	DispatchSpawn(GlowEnt);

	int fEffects = GetEntProp(GlowEnt, Prop_Send, "m_fEffects");
	SetEntProp(GlowEnt, Prop_Send, "m_fEffects", fEffects | EF_BONEMERGE | EF_NOSHADOW | EF_NORECEIVESHADOW | EF_PARENT_ANIMATES);

	// Give glowing effect to the entity
	SetEntProp(GlowEnt, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(GlowEnt, Prop_Send, "m_nGlowStyle", 1);
	SetEntPropFloat(GlowEnt, Prop_Send, "m_flGlowMaxDist", 10000.0);

	// Set glowing color

	int VarColor[4] = { 255, 255, 255, 255 };

	for (int i = 0; i < 3; i++)
	{
		VarColor[i] = GangColors[ClientGlowColorSlot[client]][i];
	}

	SetVariantColor(VarColor);
	AcceptEntityInput(GlowEnt, "SetGlowColor");

	// Set the activator and group the entity
	SetVariantString("!activator");
	AcceptEntityInput(GlowEnt, "SetParent", client);

	SetVariantString("primary");
	AcceptEntityInput(GlowEnt, "SetParentAttachment", GlowEnt, GlowEnt, 0);

	AcceptEntityInput(GlowEnt, "TurnOn");

	SetEntPropEnt(GlowEnt, Prop_Send, "m_hOwnerEntity", client);

	char iName[32];

	FormatEx(iName, sizeof(iName), "Gang-Glow %i", GetClientUserId(client));
	SetEntPropString(GlowEnt, Prop_Data, "m_iName", iName);

	SDKHook(GlowEnt, SDKHook_SetTransmit, Hook_ShouldSeeColorfulGlow);

	CreateTimer(0.1, Timer_CheckGlowPlayerModel, EntIndexToEntRef(GlowEnt), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.3, Timer_CheckGlowPlayerModel, EntIndexToEntRef(GlowEnt), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.5, Timer_CheckGlowPlayerModel, EntIndexToEntRef(GlowEnt), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_CheckGlowPlayerModel, EntIndexToEntRef(GlowEnt), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.1, Timer_CheckGlowPlayerModel, EntIndexToEntRef(GlowEnt), TIMER_FLAG_NO_MAPCHANGE);

	ClientColorfulGlow[client] = GlowEnt;
}

public Action Timer_CheckGlowPlayerModel(Handle hTimer, int Ref)
{
	int GlowEnt = EntRefToEntIndex(Ref);

	if (GlowEnt == INVALID_ENT_REFERENCE)
		return Plugin_Continue;

	int client = GetEntPropEnt(GlowEnt, Prop_Send, "m_hOwnerEntity");

	if (client == -1)
		return Plugin_Continue;

	char Model[PLATFORM_MAX_PATH];

	// Get the original model path
	GetEntPropString(client, Prop_Data, "m_ModelName", Model, sizeof(Model));

	SetEntityModel(GlowEnt, Model);

	return Plugin_Continue;
}

public Action Hook_ShouldSeeWhiteGlow(int glow, int viewer)
{
	if (!IsValidEntity(glow))
		return Plugin_Handled;

	int client = GetEntPropEnt(glow, Prop_Send, "m_hOwnerEntity");

	if (client == viewer)
		return Plugin_Handled;

	else if (!IsPlayerAlive(client))
		return Plugin_Handled;

	else if (!JailBreakDays_IsDayActive())
		return Plugin_Handled;

	else if (!AreClientsSameGang(client, viewer))
		return Plugin_Handled;

	else if (GetClientTeam(viewer) != GetClientTeam(client))
		return Plugin_Handled;

	int ObserverTarget = GetEntPropEnt(viewer, Prop_Send, "m_hObserverTarget");    // This is the player the viewer is spectating. No need to check if it's invalid ( -1 )

	if (ObserverTarget == client)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Hook_ShouldSeeColorfulGlow(int glow, int viewer)
{
	if (!IsValidEntity(glow))
		return Plugin_Continue;

	int client = GetEntPropEnt(glow, Prop_Send, "m_hOwnerEntity");

	if (client == viewer)
		return Plugin_Handled;

	else if (!IsPlayerAlive(client))
		return Plugin_Handled;

	else if (GetClientTeam(client) != CS_TEAM_T)
		return Plugin_Handled;

	else if (!JailBreakDays_IsDayActive())
		return Plugin_Handled;

	// If same gang, we don't want to show colorful glow. Running AreClientsSameGang on the same client guarantees true unless in debt.
	else if (AreClientsSameGang(client, viewer) || !AreClientsSameGang(client, client))
		return Plugin_Handled;

	int ObserverTarget = GetEntPropEnt(viewer, Prop_Send, "m_hObserverTarget");    // This is the player the viewer is spectating. No need to check if it's invalid ( -1 )

	if (ObserverTarget == client)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int victim   = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

	TryDestroyGlow(victim);

	if(attacker == 0 || victim == 0)
		return Plugin_Continue;
		
	if (attacker != victim && (GetClientTeam(victim) == CS_TEAM_CT || GetAliveTeamCount(CS_TEAM_T) == 0))
	{
		int honor = GetConVarInt(hcv_HonorPerKill);

		bool IsVIP = CheckCommandAccess(attacker, "sm_null_command", ADMFLAG_CUSTOM2, true);

		if (IsVIP)
			honor *= 2;

		UC_PrintToChat(attacker, "%s \x05You \x01gained \x02%i%s \x01Honor for your \x07kill.", PREFIX, GetConVarInt(hcv_HonorPerKill), IsVIP ? " x 2" : "");

		GiveClientHonor(attacker, honor);
	}

	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		CanGetHonor[i] = true;

		if (IsClientGang(i) && ClientGetHonorPerk[i] > 0 && GetPlayerCount() >= MIN_PLAYERS_FOR_GC)
			UC_PrintToChat(i, " %s \x05You \x01can write \x07!gc \x01in the chat to get \x10%i \x01Honor!", PREFIX, ClientGetHonorPerk[i] * GANG_GETCREDITSINCREASE);
	}

	return Plugin_Continue;
}
void TryDestroyGlow(int client)
{
	if (ClientWhiteGlow[client] != 0 && IsValidEntity(ClientWhiteGlow[client]))
	{
		AcceptEntityInput(ClientWhiteGlow[client], "Kill");
		ClientWhiteGlow[client] = 0;
	}

	if (ClientColorfulGlow[client] != 0 && IsValidEntity(ClientColorfulGlow[client]))
	{
		AcceptEntityInput(ClientColorfulGlow[client], "Kill");
		ClientColorfulGlow[client] = 0;
	}

	int ent = -1;    // Some bugs don't fix themselves...

	while ((ent = FindEntityByClassname(ent, "prop_dynamic_glow")) != -1)
	{
		char iName[32];
		GetEntPropString(ent, Prop_Data, "m_iName", iName, sizeof(iName));

		if (strncmp(iName, "Gang-Glow", 9) != 0)
			continue;

		char dummy_value[1], sUserId[11];
		int  pos = BreakString(iName, dummy_value, 0);

		BreakString(iName[pos], sUserId, sizeof(sUserId));

		int i = GetClientOfUserId(StringToInt(sUserId));

		if (i == 0 || !IsPlayerAlive(i) || i == client)
		{
			AcceptEntityInput(ent, "Kill");
		}
	}
}

public void OnClientSettingsChanged(int client)
{
	if (IsValidPlayer(client))
		StoreClientLastInfo(client);
}

public void ConnectDatabase()
{
	char     error[256];
	Database hndl;
	if ((hndl = SQLite_UseDatabase("JB_Gangs", error, sizeof(error))) == null)
		SetFailState(error);

	else
	{
		dbGangs = hndl;

		dbGangs.Query(SQLCB_Error, "CREATE TABLE IF NOT EXISTS GangSystem_Members (GangId INT(11) NOT NULL, AuthId VARCHAR(32) NOT NULL UNIQUE, GangRank INT(20) NOT NULL, LastName VARCHAR(32) NOT NULL, GangInviter VARCHAR(32) NOT NULL, GangJoinDate INT(20) NOT NULL, LastConnect INT(20) NOT NULL)", 0, DBPrio_High);
		dbGangs.Query(SQLCB_Error, "CREATE TABLE IF NOT EXISTS GangSystem_Gangs (`GangId` INTEGER, GangName VARCHAR(32) UNIQUE, GangPrefix VARCHAR(32) NOT NULL, GangPrefixMethod INT(6) NOT NULL, GangMOTD VARCHAR(512) NOT NULL, GangHonor INT(20) NOT NULL, GangNextWeekly INT(20) NOT NULL, GangHealthPerkT INT(20) NOT NULL, GangHealthPerkCT INT(20) NOT NULL, GangNadePerkT INT(20) NOT NULL, GangCooldownPerk INT(20) NOT NULL, GangGetHonorPerk INT(20) NOT NULL, GangFFPerk INT(11) NOT NULL, GangSizePerk INT(20) NOT NULL, GangMinRankInvite INT(11) NOT NULL, GangMinRankKick INT(11) NOT NULL, GangMinRankPromote INT(11) NOT NULL, GangMinRankUpgrade INT(11), GangMinRankMOTD INT(11) NOT NULL, PRIMARY KEY (`GangId` AUTOINCREMENT))", 1, DBPrio_High);
		dbGangs.Query(SQLCB_Error, "CREATE TABLE IF NOT EXISTS GangSystem_Honor (AuthId VARCHAR(32) NOT NULL UNIQUE, Honor INT(11) NOT NULL)", 2, DBPrio_High);
		dbGangs.Query(SQLCB_Error, "CREATE TABLE IF NOT EXISTS GangSystem_upgradelogs (GangId INT(11) NOT NULL, GangName VARCHAR(32) NOT NULL, AuthId VARCHAR(32) NOT NULL, Perk VARCHAR(32) NOT NULL, BValue INT NOT NULL, AValue INT NOT NULL, timestamp INT NOT NULL)", 3, DBPrio_High);
		dbGangs.Query(SQLCB_Error, "CREATE TABLE IF NOT EXISTS GangSystem_modlogs (GangId INT(11) NOT NULL, AuthId VARCHAR(32) NOT NULL, ModAction INT(6) NOT NULL, ModActionNumber INT(11), ModActionWord VARCHAR(100), ModTarget VARCHAR(128) NOT NULL, timestamp INT NOT NULL)", -1, DBPrio_High);
		dbGangs.Query(SQLCB_Error, "CREATE TABLE IF NOT EXISTS GangSystem_Donations (GangId INT(11) NOT NULL, AuthId VARCHAR(32) NOT NULL, AmountDonated INT(11), timestamp INT(32))", -2, DBPrio_High);

		dbFullConnected = true;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidPlayer(i))
				continue;

			else if (!IsClientAuthorized(i))
				continue;

			char AuthId[35];
			GetClientAuthId(i, AuthId_Steam2, AuthId, sizeof(AuthId));

			UpdateInGameAuthId(AuthId);
		}
	}
}

public void SQLCB_Error(Handle owner, DBResultSet hndl, const char[] Error, int QueryUniqueID)
{
	/* If something fucked up. */
	if (hndl == null)
		SetFailState("%s --> %i", Error, QueryUniqueID);
}

public void SQLCB_ErrorIgnore(Handle owner, DBResultSet hndl, const char[] Error, int Data)
{
}

public void OnClientPutInServer(int client)
{
	ClientWhiteGlow[client]    = 0;
	ClientColorfulGlow[client] = 0;
	ClientSpyGang[client]      = false;
}

public void OnClientConnected(int client)
{
	ResetVariables(client, true);
	ClientNextMOTD[client] = 0.0;
	CanGetHonor[client]    = false;
}

void ResetVariables(int client, bool login = true)
{
	ClientHonor[client]        = 0;
	ClientHealthPerkT[client]  = 0;
	ClientCooldownPerk[client] = 0;
	ClientNadePerkT[client]    = 0;
	ClientHealthPerkCT[client] = 0;

	ClientAccessManage[client]  = RANK_LEADER;
	ClientAccessInvite[client]  = RANK_LEADER;
	ClientAccessKick[client]    = RANK_LEADER;
	ClientAccessPromote[client] = RANK_LEADER;
	ClientAccessUpgrade[client] = RANK_LEADER;
	ClientAccessMOTD[client]    = RANK_LEADER;

	ClientGlowColorSlot[client] = -1;

	if (login)
	{
		GangAttemptLeave[client]     = false;
		GangAttemptDisband[client]   = false;
		GangAttemptStepDown[client]  = false;
		GangStepDownTarget[client]   = -1;
		ClientGang[client]           = GANG_NULL;
		ClientGangId[client]         = GANGID_NULL;
		ClientRank[client]           = RANK_NULL;
		ClientGangHonor[client]      = 0;
		ClientGangNextWeekly[client] = 0;
	}
	ClientMotd[client]         = "";
	ClientLoadedFromDb[client] = false;
}

public void OnClientDisconnect(int client)
{
	char AuthId[35], Name[64];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	Format(Name, sizeof(Name), "%N", client);

	StoreAuthIdLastInfo(AuthId, Name);    // Safer

	TryDestroyGlow(client);
}

public void OnClientPostAdminCheck(int client)
{
	if (!dbFullConnected)
		return;

	MotdShown[client] = false;

	CanGetHonor[client] = false;

	LoadClientGang(client);
}

void LoadClientGang(int client, int LowPrio = false)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE AuthId = '%s'", AuthId);

	if (!LowPrio)
		dbGangs.Query(SQLCB_LoadClientGang, sQuery, GetClientUserId(client));

	else
		dbGangs.Query(SQLCB_LoadClientGang, sQuery, GetClientUserId(client), DBPrio_Low);

	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Honor WHERE AuthId = '%s'", AuthId);

	if (!LowPrio)
		dbGangs.Query(SQLCB_LoadClientHonor, sQuery, GetClientUserId(client));

	else
		dbGangs.Query(SQLCB_LoadClientHonor, sQuery, GetClientUserId(client), DBPrio_Low);
}

public void SQLCB_LoadClientGang(Handle owner, DBResultSet hndl, char[] error, any data)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	int client = GetClientOfUserId(data);
	if (client == 0)
	{
		return;
	}
	else
	{
		StoreClientLastInfo(client);

		ClientGangId[client] = GANGID_NULL;

		if (SQL_GetRowCount(hndl) != 0)
		{
			SQL_FetchRow(hndl);

			ClientGangId[client] = SQL_FetchIntByName(hndl, "GangId");
		}

		if (ClientGangId[client] != GANGID_NULL)
		{
			ClientRank[client] = SQL_FetchIntByName(hndl, "GangRank");

			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i))
					continue;

				if (client == i)
					continue;

				if (!AreClientsSameGang(client, i))
					continue;

				ClientGlowColorSlot[client] = ClientGlowColorSlot[i];
			}

			if (ClientGlowColorSlot[client] == -1)
			{
				for (int i = 0; i < sizeof(GangColors); i++)
				{
					bool glowTaken = false;

					for (int compareClient = 1; compareClient <= MaxClients; compareClient++)
					{
						if (!IsClientInGame(compareClient))
							continue;

						else if (!IsClientGang(compareClient))
							continue;

						if (ClientGlowColorSlot[compareClient] == i)
						{
							glowTaken = true;
						}
					}

					if (!glowTaken)
					{
						ClientGlowColorSlot[client] = i;

						break;
					}
				}
			}
			char sQuery[256];
			dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Gangs WHERE GangId = %i", ClientGangId[client]);
			dbGangs.Query(SQLCB_LoadGangByClient, sQuery, GetClientUserId(client), DBPrio_High);
		}
		else
		{
			ClientLoadedFromDb[client] = true;

			if (IsPlayerAlive(client))
				TryDestroyGlow(client);
		}
	}
}

public void SQLCB_LoadGangByClient(Handle owner, DBResultSet hndl, char[] error, any data)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	int client = GetClientOfUserId(data);

	bool bDeleted = false;

	if (client == 0)
	{
		return;
	}
	else
	{
		if (SQL_GetRowCount(hndl) != 0)
		{
			SQL_FetchRow(hndl);

			SQL_FetchStringByName(hndl, "GangName", ClientGang[client], sizeof(ClientGang[]));

			int fieldNum;
			SQL_FieldNameToNum(hndl, "GangName", fieldNum);

			bDeleted = SQL_IsFieldNull(hndl, fieldNum);

			if (!bDeleted)    // Gang was disbanded
			{
				SQL_FetchStringByName(hndl, "GangMOTD", ClientMotd[client], sizeof(ClientMotd[]));

				ClientGangHonor[client]      = SQL_FetchIntByName(hndl, "GangHonor");
				ClientGangNextWeekly[client] = SQL_FetchIntByName(hndl, "GangNextWeekly");
				ClientGangSizePerk[client]   = SQL_FetchIntByName(hndl, "GangSizePerk");

				TryRemoveGangPrefix(client);

				if (ClientGangHonor[client] >= 0)
				{
					ClientHealthPerkT[client]      = SQL_FetchIntByName(hndl, "GangHealthPerkT");
					ClientHealthPerkCT[client]     = SQL_FetchIntByName(hndl, "GangHealthPerkCT");
					ClientNadePerkT[client]        = SQL_FetchIntByName(hndl, "GangNadePerkT");
					ClientCooldownPerk[client]     = SQL_FetchIntByName(hndl, "GangCooldownPerk");
					ClientGetHonorPerk[client]     = SQL_FetchIntByName(hndl, "GangGetHonorPerk");
					ClientFriendlyFirePerk[client] = SQL_FetchIntByName(hndl, "GangFFPerk");

					SQL_FetchStringByName(hndl, "GangPrefix", ClientPrefix[client], sizeof(ClientPrefix[]));
					ClientPrefixMethod[client] = SQL_FetchIntByName(hndl, "GangPrefixMethod");

					char Name[64];

					GetClientName(client, Name, sizeof(Name));

					if (ClientPrefixMethod[client] == 0 && ClientPrefix[client][0] != EOS)
					{
						Format(ClientPrefix[client], sizeof(ClientPrefix[]), "[%s] ", ClientPrefix[client]);
					}

					if (ClientPrefix[client][0] != EOS)
					{
						Format(Name, sizeof(Name), "%s%s", ClientPrefix[client], Name);

						SetClientNameHidden(client, Name);
					}
				}

				ClientAccessInvite[client]  = SQL_FetchIntByName(hndl, "GangMinRankInvite");
				ClientAccessKick[client]    = SQL_FetchIntByName(hndl, "GangMinRankKick");
				ClientAccessPromote[client] = SQL_FetchIntByName(hndl, "GangMinRankPromote");
				ClientAccessUpgrade[client] = SQL_FetchIntByName(hndl, "GangMinRankUpgrade");
				ClientAccessMOTD[client]    = SQL_FetchIntByName(hndl, "GangMinRankMOTD");

				int Smallest = ClientAccessInvite[client];

				if (ClientAccessKick[client] < Smallest)
					Smallest = ClientAccessKick[client];

				if (ClientAccessPromote[client] < Smallest)
					Smallest = ClientAccessPromote[client];

				if (ClientAccessUpgrade[client] < Smallest)
					Smallest = ClientAccessUpgrade[client];

				if (ClientAccessMOTD[client] < Smallest)
					Smallest = ClientAccessMOTD[client];

				ClientAccessManage[client] = Smallest;

				if (ClientMotd[client][0] != EOS && !MotdShown[client])
				{
					UC_PrintToChat(client, " \x01=======\x07GANG MOTD\x01=========");
					UC_PrintToChat(client, " %s", ClientGang[client]);
					UC_PrintToChat(client, " %s", ClientMotd[client]);
					UC_PrintToChat(client, " \x01=======\x07GANG MOTD\x01=========");
					MotdShown[client] = true;
				}

				if (IsPlayerAlive(client))
					CreateGlow(client);

				char sQuery[256];
				dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE GangId = %i", ClientGangId[client]);

				dbGangs.Query(SQLCB_CheckMemberCount, sQuery, GetClientUserId(client));
			}
		}
		else    // Gang was deleted within the SQL...
		{
			bDeleted = true;
		}

		if (bDeleted)
		{
			char AuthId[35];
			GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

			KickAuthIdFromGang(AuthId, ClientGangId[client]);

			ClientGang[client]   = GANG_NULL;
			ClientGangId[client] = GANGID_NULL;

			ClientPrefix[client] = "";

			if (IsPlayerAlive(client))
				TryDestroyGlow(client);
		}

		ClientLoadedFromDb[client] = true;
	}
}

public void SQLCB_LoadClientHonor(Handle owner, DBResultSet hndl, char[] error, any data)
{
	if (hndl == null)
		SetFailState(error);

	int client = GetClientOfUserId(data);

	if (client == 0)
		return;

	else
	{
		if (SQL_GetRowCount(hndl) != 0)
		{
			SQL_FetchRow(hndl);

			ClientHonor[client] = SQL_FetchIntByName(hndl, "Honor");
		}
		else
		{
			char AuthId[35];
			GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

			// The reason I use INSERT OR IGNORE rather than just INSERT is bots, that can have multiple steam IDs.
			char sQuery[256];
			dbGangs.Format(sQuery, sizeof(sQuery), "INSERT OR IGNORE INTO GangSystem_Honor (AuthId, Honor) VALUES ('%s', 0)", AuthId);

			dbGangs.Query(SQLCB_Error, sQuery, 4);
			ClientHonor[client] = 0;
		}
	}
}

stock void KickClientFromGang(int client, int GangId, int kicker = 0)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	KickAuthIdFromGang(AuthId, GangId, kicker);
}

stock void KickAuthIdFromGang(const char[] AuthId, int GangId, int kicker = 0)
{
	char        sQuery[256];
	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Members SET GangId = %i WHERE AuthId = '%s' AND GangId = %i", GANGID_NULL, AuthId, GangId);
	SQL_AddQuery(transaction, sQuery);

	char kickerAuthId[35];

	if (kicker == 0)
		kickerAuthId = "CONSOLE";

	else
		GetClientAuthId(kicker, AuthId_Steam2, kickerAuthId, sizeof(kickerAuthId));

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_modlogs (GangId, AuthId, ModAction, ModTarget, timestamp) VALUES (%i, '%s', %i, '%s', %i)", GangId, kickerAuthId, MODACTION_KICK, AuthId, GetTime());
	SQL_AddQuery(transaction, sQuery);

	Handle DP = CreateDataPack();

	WritePackCell(DP, GangId);

	dbGangs.Execute(transaction, SQLTrans_GangDonated, SQLTrans_SetFailState, DP);
}

public Action CommandListener_Say(int client, const char[] command, int args)
{
	if (!IsValidPlayer(client))
		return Plugin_Continue;

	char Args[256];
	GetCmdArgString(Args, sizeof(Args));
	StripQuotes(Args);

	if (Args[0] == '#')
	{
		ReplaceStringEx(Args, sizeof(Args), "#", "");

		if (Args[0] == EOS)
		{
			UC_PrintToChat(client, " %s \x01Gang message cannot be \x07empty.", PREFIX);
			return Plugin_Handled;
		}
		char RankName[32];
		GetRankName(GetClientRank(client), RankName, sizeof(RankName));

		PrintToChatGang(ClientGangId[client], "\x04[Gang Chat] \x05%s \x04%N\x01 : %s", RankName, client, Args);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			if (ClientSpyGang[i])
				UC_PrintToChat(i, " \x04[\x05Spy Gang Chat\x01] \x05%s \x04%N\x01 : %s", RankName, client, Args);
		}

		return Plugin_Handled;
	}

	RequestFrame(ListenerSayPlusFrame, GetClientUserId(client));
	return Plugin_Continue;
}

public void ListenerSayPlusFrame(int UserId)
{
	int client = GetClientOfUserId(UserId);

	if (IsClientGang(client))
	{
		if (GangAttemptDisband[client] || GangAttemptLeave[client] || GangAttemptStepDown[client])
			UC_PrintToChat(client, " %s The operation has been \x07aborted!", PREFIX);

		GangAttemptDisband[client]  = false;
		GangAttemptLeave[client]    = false;
		GangAttemptStepDown[client] = false;
		GangStepDownTarget[client]  = -1;
	}
}

public Action Command_MotdGang(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, " %s \x05You \x01have to be in a gang to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!CheckGangAccess(client, ClientAccessMOTD[client]))
	{
		char RankName[32];
		GetRankName(ClientAccessMOTD[client], RankName, sizeof(RankName));
		UC_PrintToChat(client, " %s \x05You \x01have to be a gang \x07%s \x01to use this \x07command!", PREFIX, RankName);
		return Plugin_Handled;
	}
	else if (ClientNextMOTD[client] > GetGameTime())
	{
		UC_PrintToChat(client, " %s \x05You can change the MOTD again in %i seconds.", PREFIX, RoundToFloor(ClientNextMOTD[client] - GetGameTime()));
		return Plugin_Handled;
	}

	char Args[100];
	GetCmdArgString(Args, sizeof(Args));
	StripQuotes(Args);

	if (StringHasInvalidCharacters(Args))
	{
		UC_PrintToChat(client, " %s Invalid motd! \x05You \x01can only use \x07SPACEBAR, \x07a-z, A-Z\x01, _, -, \x070-9", PREFIX);
		return Plugin_Handled;
	}

	ClientNextMOTD[client] = GetGameTime() + 60.0;
	char        sQuery[256];
	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET GangMOTD = '%s' WHERE GangId = %i", Args, ClientGangId[client]);
	SQL_AddQuery(transaction, sQuery);

	char motdAuthId[35];
	GetClientAuthId(client, AuthId_Steam2, motdAuthId, sizeof(motdAuthId));

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_modlogs (GangId, AuthId, ModAction, ModActionWord, ModTarget, timestamp) VALUES (%i, '%s', %i, '%s', '%s', %i)", ClientGangId[client], motdAuthId, MODACTION_MOTD, Args, motdAuthId, GetTime());
	SQL_AddQuery(transaction, sQuery);

	Handle DP = CreateDataPack();

	WritePackCell(DP, ClientGangId[client]);

	// It doesn't really matter to immediately update the MOTD, as it's a login message anyways.
	dbGangs.Execute(transaction, INVALID_FUNCTION, INVALID_FUNCTION, DP);

	UC_PrintToChat(client, "%s The gang's motd has been changed to \x07%s", PREFIX, Args);

	return Plugin_Handled;
}

public Action Command_GiftHonor(int client, int args)
{
	if (args < 1 || args > 2)
	{
		UC_ReplyToCommand(client, "[SM] Usage: sm_gifthonor <#userid|name> <amount>");
		return Plugin_Handled;
	}

	char arg[MAX_NAME_LENGTH], arg2[10];
	GetCmdArg(1, arg, sizeof(arg));

	if (args > 1)
	{
		GetCmdArg(2, arg2, sizeof(arg2));
	}

	int amount = StringToInt(arg2);

	if (StrContains(arg2, "all", false) != -1)
		amount = ClientHonor[client];

	if (amount <= 100)
	{
		UC_PrintToChat(client, "%s Error: Min value to send is 100!", PREFIX);
		return Plugin_Handled;
	}

	char target_name[MAX_TARGET_LENGTH];
	int  target_list[MAXPLAYERS + 1], target_count;
	bool tn_is_ml;

	int targetclient;

	if ((target_count = ProcessTargetString(
			 arg,
			 client,
			 target_list,
			 MAXPLAYERS,
			 COMMAND_FILTER_NO_IMMUNITY | COMMAND_FILTER_NO_MULTI,
			 target_name,
			 sizeof(target_name),
			 tn_is_ml))
	    > 0)
	{
		for (int i = 0; i < target_count; i++)
		{
			targetclient = target_list[i];

			if (targetclient == client || IsFakeClient(targetclient))
				continue;

			else if (amount > ClientHonor[client])
			{
				UC_PrintToChat(client, "%s Error: Not enough honor to send! (Σ: \x05%d\x03)", PREFIX, ClientHonor[client]);
				return Plugin_Handled;
			}

			// Guarantee prevention of duplication...
			ClientHonor[targetclient] = 0;
			ClientHonor[client]       = 0;

			Transaction transaction = SQL_CreateTransaction();

			Transaction_GiveClientHonor(transaction, client, -1 * amount);
			Transaction_GiveClientHonor(transaction, targetclient, amount);

			Handle DP = CreateDataPack();

			WritePackCell(DP, GetClientUserId(client));
			WritePackCell(DP, GetClientUserId(targetclient));

			dbGangs.Execute(transaction, SQLTrans_HonorGifted, SQLTrans_SetFailState, DP);

			char name[33], sendername[33];
			GetClientName(targetclient, name, sizeof(name));
			GetClientName(client, sendername, sizeof(sendername));
			UC_PrintToChat(client, "%s You gave \x05%d\x03 honor to %s.", PREFIX, amount, name);
			UC_PrintToChat(targetclient, "%s %s gave you \x05%d\x03 honor.", PREFIX, sendername, amount);
		}
	}
	else
	{
		ReplyToTargetError(client, target_count);
	}

	return Plugin_Handled;
}

public void SQLTrans_HonorGifted(Database db, any DP, int numQueries, DBResultSet[] results, any[] queryData)
{
	ResetPack(DP);

	int client1, client2;

	client1 = GetClientOfUserId(ReadPackCell(DP));
	client2 = GetClientOfUserId(ReadPackCell(DP));

	CloseHandle(DP);

	if (client1 != 0)
		LoadClientGang(client1);

	if (client2 != 0)
		LoadClientGang(client2);
}

public Action Command_DonateGang(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be in a \x07gang \x01to use this command!", PREFIX);
		return Plugin_Handled;
	}
	char Args[20];
	GetCmdArgString(Args, sizeof(Args));
	StripQuotes(Args);

	int amount = StringToInt(Args);

	if (StrEqual(Args, "all", false))
	{
		amount = ClientHonor[client];

		amount -= amount % 50;
		IntToString(amount, Args, sizeof(Args));
	}
	if (!IsStringNumber(Args) || Args[0] == EOS)
	{
		UC_PrintToChat(client, "%s Invalid Usage! \x07!donategang \x01<amount>", PREFIX);
		return Plugin_Handled;
	}
	else if (amount < 50 || (amount % 50) != 0)
	{
		UC_PrintToChat(client, "%s \x05You \x01must donate at least \x0750 \x01honor and in multiples of \x0750!", PREFIX);
		return Plugin_Handled;
	}
	else if (amount > ClientHonor[client])
	{
		UC_PrintToChat(client, "%s \x05You \x01cannot donate more honor than you \x07have.", PREFIX);
		return Plugin_Handled;
	}
	Handle hMenu = CreateMenu(DonateGang_MenuHandler);

	AddMenuItem(hMenu, Args, "Yes");
	AddMenuItem(hMenu, "", "No");

	SetMenuTitle(hMenu, "%s Gang Donation\n\nAre you sure you want to donate %i honor?", MENU_PREFIX, amount);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int DonateGang_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!IsClientGang(client))
			return 0;

		if (item + 1 == 1)
		{
			char strAmount[20];
			GetMenuItem(hMenu, item, strAmount, sizeof(strAmount));

			int amount = StringToInt(strAmount);
			DonateToGang(client, amount);
		}
	}

	return 0;
}

public Action Command_RenameGang(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be in a \x07gang \x01to use this command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!CheckGangAccess(client, RANK_LEADER))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be the gang's leader to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	char Args[32];
	GetCmdArgString(Args, sizeof(Args));
	StripQuotes(Args);

	if (Args[0] == EOS)
	{
		UC_PrintToChat(client, "%s Invalid Usage! \x07!renamegang \x01<new name>", PREFIX);
		return Plugin_Handled;
	}
	else if (StringHasInvalidCharacters(Args))
	{
		UC_PrintToChat(client, "%s Invalid name! \x05You \x01can only use \x07a-z, A-Z\x01, _, -, \x070-9!", PREFIX);
		return Plugin_Handled;
	}

	Handle hMenu = CreateMenu(RenameGang_MenuHandler);

	AddMenuItem(hMenu, Args, "Yes");
	AddMenuItem(hMenu, "", "No");

	SetMenuTitle(hMenu, "%s Gang Rename\n\nAre you sure you want to pay %i Honor to rename your gang?\nNew Name: %s", MENU_PREFIX, GANG_RENAME_PRICE, Args);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int RenameGang_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!IsClientGang(client))
			return 0;

		else if (!CheckGangAccess(client, RANK_LEADER))
			return 0;

		if (item + 1 == 1)
		{
			if (ClientGangHonor[client] < GANG_RENAME_PRICE)
			{
				char sPriceDifference[16];

				AddCommas(GANG_RENAME_PRICE - ClientGangHonor[client], ",", sPriceDifference, sizeof(sPriceDifference));

				UC_PrintToChat(client, "%s \x05You \x01need \x07%s more honor\x01 to rename your gang!", PREFIX, sPriceDifference);
				return 0;
			}

			char strName[32];
			GetMenuItem(hMenu, item, strName, sizeof(strName));

			Handle DP = CreateDataPack();
			WritePackCell(DP, GetClientUserId(client));
			WritePackString(DP, strName);

			char sQuery[256];
			SQL_FormatQuery(dbGangs, sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Gangs WHERE lower(GangName) = lower('%s')", strName);

			// Normal prio on check taken and high on change ensures if there is a check taken for anything else, it won't allow two gangs with same name.
			SQL_TQuery(dbGangs, SQLCB_RenameGang_CheckTakenName, sQuery, DP);
		}
	}

	return 0;
}

public void SQLCB_RenameGang_CheckTakenName(Handle owner, Handle hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		LogError(error);

		return;
	}

	ResetPack(DP);

	int  client = GetClientOfUserId(ReadPackCell(DP));
	char GangName[32];

	ReadPackString(DP, GangName, sizeof(GangName));

	CloseHandle(DP);

	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		if (SQL_GetRowCount(hndl) == 0)
		{
			PrintToChatGang(ClientGangId[client], "%s The gang was renamed to\x07 %s\x01!", PREFIX, GangName);

			DP = CreateDataPack();

			WritePackCell(DP, ClientGangId[client]);

			char sQuery[256];

			dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET GangName = '%s', GangHonor = GangHonor - %i WHERE GangId = %i", GangName, GANG_RENAME_PRICE, ClientGangId[client]);

			dbGangs.Query(SQLCB_GangDonated, sQuery, DP);
		}
		else    // Gang name is taken.
		{
			UC_PrintToChat(client, "%s The selected gang name is \x07already \x01taken!", PREFIX);
		}
	}
}

public Action Command_PrefixGang(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be in a \x07gang \x01to use this command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!CheckGangAccess(client, RANK_LEADER))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be the gang's leader to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}

	char Args[32];
	GetCmdArgString(Args, sizeof(Args));
	StripQuotes(Args);

	if (Args[0] == EOS)
	{
		UC_PrintToChat(client, "%s Invalid Usage! \x07!prefixgang \x01<new prefix>", PREFIX);
		return Plugin_Handled;
	}
	else if (StringHasInvalidCharacters(Args))
	{
		UC_PrintToChat(client, "%s Invalid prefix! \x05You \x01can only use \x07a-z, A-Z\x01, _, -, \x070-9!", PREFIX);
		return Plugin_Handled;
	}
	else if (strlen(Args) < 3 || strlen(Args) > 5)
	{
		UC_PrintToChat(client, "%s Invalid prefix! \x05You \x01can only use\x03\x01 to\x03 5\x01 characters!", PREFIX);

		return Plugin_Handled;
	}
	Handle hMenu = CreateMenu(PrefixGang_MenuHandler);

	AddMenuItem(hMenu, Args, "Yes");
	AddMenuItem(hMenu, "", "No");

	SetMenuTitle(hMenu, "%s Gang Prefix Change\n\nAre you sure you want to pay $%i to change your gang's prefix?\nNew Prefix: %s", MENU_PREFIX, GANG_PREFIX_PRICE, Args);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int PrefixGang_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (!IsClientGang(client))
			return 0;

		else if (!CheckGangAccess(client, RANK_LEADER))
			return 0;

		if (item + 1 == 1)
		{
			if (ClientGangHonor[client] < GANG_PREFIX_PRICE)
			{
				char sPriceDifference[16];

				AddCommas(GANG_PREFIX_PRICE - ClientGangHonor[client], ",", sPriceDifference, sizeof(sPriceDifference));

				UC_PrintToChat(client, "%s \x05You \x01need \x07$%s more\x01 to change your gang's prefix!", PREFIX, sPriceDifference);
				return 0;
			}

			char strName[32];
			GetMenuItem(hMenu, item, strName, sizeof(strName));

			Handle DP = CreateDataPack();
			WritePackCell(DP, GetClientUserId(client));
			WritePackString(DP, strName);

			char sQuery[256];
			SQL_FormatQuery(dbGangs, sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Gangs WHERE lower(GangPrefix) = lower('%s')", strName);

			// Normal prio on check taken and high on change ensures if there is a check taken for anything else, it won't allow two gangs with same name.
			SQL_TQuery(dbGangs, SQLCB_GangPrefix_CheckTakenPrefix, sQuery, DP);
		}
	}

	return 0;
}

public void SQLCB_GangPrefix_CheckTakenPrefix(Handle owner, Handle hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		LogError(error);

		return;
	}

	ResetPack(DP);

	int  client = GetClientOfUserId(ReadPackCell(DP));
	char GangPrefix[32];

	ReadPackString(DP, GangPrefix, sizeof(GangPrefix));

	CloseHandle(DP);

	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		if (SQL_GetRowCount(hndl) == 0)
		{
			PrintToChatGang(ClientGangId[client], "%s The gang's prefix was changed to\x07 %s\x01!", PREFIX, GangPrefix);

			DP = CreateDataPack();

			WritePackCell(DP, ClientGangId[client]);

			char sQuery[256];

			dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET GangPrefix = '%s', GangHonor = GangHonor - %i WHERE GangId = %i", GangPrefix, GANG_PREFIX_PRICE, ClientGangId[client]);

			dbGangs.Query(SQLCB_GangDonated, sQuery, DP);
		}
		else    // Gang name is taken.
		{
			UC_PrintToChat(client, "%s The selected gang prefix is \x07already \x01taken!", PREFIX);
		}
	}
}

public Action Command_CreateGang(int client, int args)
{
	if (!ClientLoadedFromDb[client])
	{
		UC_PrintToChat(client, "%s \x05You \x01weren't loaded from the database \x07yet!", PREFIX);
		return Plugin_Handled;
	}
	else if (IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to leave your current \x07gang \x01to create a new \x07one!", PREFIX);
		return Plugin_Handled;
	}

	char Args[32];
	GetCmdArgString(Args, sizeof(Args));
	StripQuotes(Args);

	if (Args[0] == EOS)
	{
		UC_PrintToChat(client, "%s Invalid Usage! \x07!creategang \x01<name>", PREFIX);
		return Plugin_Handled;
	}
	else if (StringHasInvalidCharacters(Args))
	{
		UC_PrintToChat(client, "%s Invalid name! \x05You \x01can only use \x07a-z, A-Z\x01, _, -, \x070-9!", PREFIX);
		return Plugin_Handled;
	}

	GangCreateName[client] = Args;
	Handle hMenu           = CreateMenu(CreateGang_MenuHandler);

	AddMenuItem(hMenu, "", "Yes");
	AddMenuItem(hMenu, "", "No");

	SetMenuExitButton(hMenu, false);

	SetMenuTitle(hMenu, "%s Create Gang\nGang Name: %s\nCost: %i", MENU_PREFIX, GangCreateName[client], GANG_COSTCREATE);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public Action Command_LeaveGang(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be in a gang to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!GangAttemptLeave[client])
	{
		UC_PrintToChat(client, "%s \x05You \x01have not made an attempt to leave your gang with \x07!gang.", PREFIX);
		return Plugin_Handled;
	}

	PrintToChatGang(ClientGangId[client], "%s \x03%N \x09has left the gang!", PREFIX, client);
	KickClientFromGang(client, ClientGangId[client], client);

	GangAttemptLeave[client] = false;

	return Plugin_Handled;
}

public Action Command_DisbandGang(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be in a gang to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!CheckGangAccess(client, RANK_LEADER))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be the gang's leader to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!GangAttemptDisband[client])
	{
		UC_PrintToChat(client, "%s \x05You \x01have not made an attempt to disband your gang with \x07!gang.", PREFIX);
		return Plugin_Handled;
	}

	UC_PrintToChatAll("%s \x05%N \x01has disbanded the gang \x07%s!", PREFIX, client, ClientGang[client]);

	char        sQuery[256];
	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET GangName = NULL WHERE GangId = %i", ClientGangId[client]);
	SQL_AddQuery(transaction, sQuery);

	char disbanderAuthId[35];
	GetClientAuthId(client, AuthId_Steam2, disbanderAuthId, sizeof(disbanderAuthId));

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_modlogs (GangId, AuthId, ModAction, ModTarget, timestamp) VALUES (%i, '%s', %i, '%s', %i)", ClientGangId[client], disbanderAuthId, MODACTION_DISBAND, disbanderAuthId, GetTime());
	SQL_AddQuery(transaction, sQuery);

	Handle DP = CreateDataPack();

	WritePackCell(DP, ClientGangId[client]);

	dbGangs.Execute(transaction, SQLTrans_GangDonated, SQLTrans_SetFailState, DP);

	GangAttemptDisband[client] = false;

	return Plugin_Handled;
}

public Action Command_StepDown(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be in a gang to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!CheckGangAccess(client, RANK_LEADER))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be the gang's leader to use this \x07command!", PREFIX);
		return Plugin_Handled;
	}
	else if (!GangAttemptStepDown[client])
	{
		UC_PrintToChat(client, "%s \x05You \x01have not made an attempt to step down from your rank with \x07!gang.", PREFIX);
		return Plugin_Handled;
	}

	int NewLeader = GetClientOfUserId(GangStepDownTarget[client]);

	if (NewLeader == 0)
	{
		UC_PrintToChat(client, "%s The selected target has \x07disconnected.", PREFIX);
		return Plugin_Handled;
	}

	else if (!AreClientsSameGang(client, NewLeader))
	{
		UC_PrintToChat(client, "%s The selected target has left the \x07gang.", PREFIX);
		return Plugin_Handled;
	}

	PrintToChatGang(ClientGangId[client], "%s \x05%N \x01has stepped down to \x07Co-Leader.", PREFIX, client);
	PrintToChatGang(ClientGangId[client], "%s \x05%N \x01is now the gang \x07Leader.", PREFIX, NewLeader);

	char AuthId[35], AuthIdNewLeader[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));
	GetClientAuthId(NewLeader, AuthId_Steam2, AuthIdNewLeader, sizeof(AuthIdNewLeader));

	SetAuthIdRank(AuthId, ClientGangId[client], RANK_COLEADER, client);
	SetAuthIdRank(AuthIdNewLeader, ClientGangId[NewLeader], RANK_LEADER, client);

	GangAttemptStepDown[client] = false;
	GangStepDownTarget[client]  = -1;
	return Plugin_Handled;
}

public int CreateGang_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (IsClientGang(client))
			return 0;

		if (item + 1 == 1)
		{
			if (GangCreateName[client][0] == EOS || StringHasInvalidCharacters(GangCreateName[client]))
				return 0;

			TryCreateGang(client, GangCreateName[client]);
		}
		else
		{
			GangCreateName[client] = GANG_NULL;
		}
	}
	return 0;
}

public Action Command_GC(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01have to be in a gang to use this \x01command!", PREFIX);
		return Plugin_Handled;
	}
	else if (ClientGetHonorPerk[client] <= 0)
	{
		UC_PrintToChat(client, "%s Your gang does not have that \x07perk.", PREFIX);
		return Plugin_Handled;
	}
	else if (!CanGetHonor[client])
	{
		UC_PrintToChat(client, "%s \x05You \x01have already received honor this \x07round!", PREFIX);
		return Plugin_Handled;
	}
	else if (GetPlayerCount() < MIN_PLAYERS_FOR_GC)
	{
		UC_PrintToChat(client, "%s \x05You \x01can only use \x07!gc \x01from \x103 \x01players and above.", PREFIX);
		return Plugin_Handled;
	}

	int received = ClientGetHonorPerk[client] * GANG_GETCREDITSINCREASE;
	GiveClientHonor(client, received);
	UC_PrintToChat(client, "%s \x05You \x01have received \x07%i \x01honor with \x07!gc.", PREFIX, received);
	CanGetHonor[client] = false;

	return Plugin_Handled;
}

public Action Command_SpyGang(int client, int args)
{
	ClientSpyGang[client] = !ClientSpyGang[client];

	UC_PrintToChat(client, "You are no%s spying gang chats", ClientSpyGang[client] ? "w" : " longer");

	return Plugin_Handled;
}

public Action Command_BreachGang(int client, int args)
{
	if (IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01must not be in a gang to move yourself into another \x07gang.", PREFIX);
		return Plugin_Handled;
	}

	if (args == 0)
	{
		UC_PrintToChat(client, "Usage: \x07sm_breachgang \x01<gang id>");
		return Plugin_Handled;
	}

	char sGangId[11];
	GetCmdArgString(sGangId, sizeof(sGangId));
	StripQuotes(sGangId);

	char   AuthId[35];
	Handle DP = CreateDataPack();
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));
	WritePackString(DP, AuthId);

	FinishAddAuthIdToGang(StringToInt(sGangId), AuthId, RANK_MEMBER, AuthId, DP);

	return Plugin_Handled;
}

public Action Command_BreachGangRank(int client, int args)
{
	if (!IsClientGang(client))
	{
		UC_PrintToChat(client, "%s \x05You \x01must be in a gang to set your gang \x07rank.", PREFIX);
		return Plugin_Handled;
	}

	if (args == 0)
	{
		UC_PrintToChat(client, "Usage: sm_breachgangrank <rank {0~%i}>", RANK_COLEADER + 1);
		return Plugin_Handled;
	}

	char RankToSet[11];
	GetCmdArg(1, RankToSet, sizeof(RankToSet));

	int Rank = StringToInt(RankToSet);

	if (Rank > RANK_COLEADER)
		Rank = RANK_LEADER;

	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	SetAuthIdRank(AuthId, ClientGangId[client], Rank);

	return Plugin_Handled;
}

public Action Command_Gang(int client, int args)
{
	if (!ClientLoadedFromDb[client])
	{
		UC_PrintToChat(client, "%s \x05You \x01weren't loaded from the database \x07yet!", PREFIX);
		return Plugin_Handled;
	}
	GangAttemptLeave[client]   = false;
	GangAttemptDisband[client] = false;

	Handle hMenu = CreateMenu(Gang_MenuHandler);

	bool isGang = IsClientGang(client);

	bool isLeader = (IsClientGang(client) && CheckGangAccess(client, RANK_LEADER));

	char TempFormat[100];

	if (!isGang)
	{
		Format(TempFormat, sizeof(TempFormat), "Create Gang [ %i Honor ]", GANG_COSTCREATE);
		AddMenuItem(hMenu, "Create", TempFormat, !isGang ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		SetMenuTitle(hMenu, "%s Gang Menu\nYour Honor: %i\nUse !gifthonor to open a gang as a team.", MENU_PREFIX, ClientHonor[client]);
	}
	else
	{
		AddMenuItem(hMenu, "Donate", "Donate To Gang", isGang ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		AddMenuItem(hMenu, "Member List", "Member List", isGang && ClientGangHonor[client] >= 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		AddMenuItem(hMenu, "Perks", "Gang Perks", isGang && ClientGangHonor[client] >= 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		if (ClientGangHonor[client] >= 0)
			AddMenuItem(hMenu, "Manage", "Manage Gang", CheckGangAccess(client, ClientAccessManage[client]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		else
			AddMenuItem(hMenu, "Disband", "Disband Gang", isLeader ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		AddMenuItem(hMenu, "Leave", "Leave Gang", !isLeader && isGang ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		if (ClientGangHonor[client] >= 0)
			SetMenuTitle(hMenu, "%s Gang Menu [ID: %i]\nCurrent Gang: %s\nYour Honor: %i\nYour Gang's Honor: %i", MENU_PREFIX, ClientGangId[client], ClientGang[client], ClientHonor[client], ClientGangHonor[client]);

		else
			SetMenuTitle(hMenu, "%s Gang Menu [ID: %i]\nCurrent Gang: %s\nYour Honor: %i\nYour Gang's Honor Debt: %i", MENU_PREFIX, ClientGangId[client], ClientGang[client], ClientHonor[client], -1 * ClientGangHonor[client]);
	}

	AddMenuItem(hMenu, "Top", "Top Gangs");

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);

	LoadClientGang(client, true);
	return Plugin_Handled;
}

public int Gang_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		GangAttemptLeave[client]   = false;
		GangAttemptDisband[client] = false;

		char Info[32];
		GetMenuItem(hMenu, item, Info, sizeof(Info));

		if (StrEqual(Info, "Create"))
		{
			UC_PrintToChat(client, "%s Use \x07!creategang \x01<name> to create a \x07gang.", PREFIX);
		}
		else if (StrEqual(Info, "Donate"))
		{
			UC_PrintToChat(client, "%s Use \x07!donategang \x01<amount> to donate to your \x07gang.", PREFIX);
		}
		else if (StrEqual(Info, "Member List"))
		{
			if (IsClientGang(client))
				ShowMembersMenu(client);
		}
		else if (StrEqual(Info, "Perks"))
		{
			if (IsClientGang(client))
				ShowGangPerks(client);
		}
		else if (StrEqual(Info, "Manage"))
		{
			if (IsClientGang(client) && CheckGangAccess(client, ClientAccessManage[client]))
				ShowManageGangMenu(client);
		}
		else if (StrEqual(Info, "Disband"))
		{
			if (!CheckGangAccess(client, RANK_LEADER))
				return 0;

			GangAttemptDisband[client] = true;
			UC_PrintToChat(client, "%s Write \x07!confirmdisbandgang \x01to confirm DELETION of the \x05gang.", PREFIX);
			UC_PrintToChat(client, "%s Write anything else in the chat to abort deleting the \x05gang.", PREFIX);
			UC_PrintToChat(client, "%s ATTENTION! THIS ACTION WILL PERMANENTLY DELETE YOUR \x07GANG\x01, IT IS NOT UNDOABLE AND YOU WILL NOT BE \x07REFUNDED!!!", PREFIX);
		}
		else if (StrEqual(Info, "Leave"))
		{
			if (CheckGangAccess(client, RANK_LEADER) || !IsClientGang(client))
				return 0;

			GangAttemptLeave[client] = true;
			UC_PrintToChat(client, "%s Write \x07!confirmleavegang \x01if you are absolutely sure you want to leave the \x07gang.", PREFIX);
			UC_PrintToChat(client, "%s Write anything else in the chat to \x07abort.", PREFIX);
		}
		else if (StrEqual(Info, "Top"))
		{
			ShowTopGangsMenu(client);
		}
	}

	return 0;
}

void ShowTopGangsMenu(int client)
{
	char sQuery[1024];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT GangName, GangId, (%!s) as net_worth FROM GangSystem_Gangs WHERE GangHonor >= 0 AND GangName IS NOT NULL ORDER BY net_worth DESC", NET_WORTH_ORDER_BY_FORMULA);
	dbGangs.Query(SQLCB_ShowTopGangsMenu, sQuery, GetClientUserId(client));
}

public void SQLCB_ShowTopGangsMenu(Handle owner, DBResultSet hndl, char[] error, int UserId)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return;

	else if (SQL_GetRowCount(hndl) == 0)
		return;

	Handle hMenu = CreateMenu(TopGangs_MenuHandler);

	int Rank = 1;
	while (SQL_FetchRow(hndl))
	{
		char GangName[32];
		SQL_FetchStringByName(hndl, "GangName", GangName, sizeof(GangName));

		int GangId = SQL_FetchIntByName(hndl, "GangId");

		int NetWorth = SQL_FetchIntByName(hndl, "net_worth");

		char TempFormat[256];
		FormatEx(TempFormat, sizeof(TempFormat), "%s [Net worth: %i]", GangName, NetWorth);

		if (ClientGangId[client] == GangId)
			UC_PrintToChat(client, " %s \x01Your gang \x07%s \x01is ranked \x07[%i]. \x01Net Worth: \x07%i \x01honor", PREFIX, GangName, Rank, NetWorth);    // BAR COLOR

		char Info[11];

		IntToString(GangId, Info, sizeof(Info));
		AddMenuItem(hMenu, Info, TempFormat);

		Rank++;
	}

	SetMenuTitle(hMenu, "Top Gangs:");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int TopGangs_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		char Info[11];
		GetMenuItem(hMenu, item, Info, sizeof(Info));

		int GangId = StringToInt(Info);

		char sQuery[128];
		dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Gangs WHERE GangId = %i", GangId);

		dbGangs.Query(SQLCB_ShowGangInfo_LoadGang, sQuery, GetClientUserId(client));
	}

	return 0;
}

public void SQLCB_ShowGangInfo_LoadGang(Handle owner, DBResultSet hndl, char[] error, int UserId)
{
	if (hndl == null)
	{
		LogError(error);

		return;
	}

	int client = GetClientOfUserId(UserId);

	if (client == 0)
	{
		return;
	}
	else
	{
		if (SQL_FetchRow(hndl))
		{
			char GangName[32];

			int GangId = SQL_FetchIntByName(hndl, "GangId");
			SQL_FetchStringByName(hndl, "GangName", GangName, sizeof(GangName));

			int GangHonor = SQL_FetchIntByName(hndl, "GangHonor");

			FindDonationsForGang(GangId);

			char sQuery[256];
			dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE GangId = %i", GangId);

			Handle DP = CreateDataPack();

			WritePackCell(DP, GetClientUserId(client));
			WritePackString(DP, GangName);
			WritePackCell(DP, GangId);
			WritePackCell(DP, GangHonor);

			dbGangs.Query(SQLCB_ShowGangInfo_LoadMembers, sQuery, DP);
		}
	}
}

public void SQLCB_ShowGangInfo_LoadMembers(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		LogError(error);

		return;
	}

	ResetPack(DP);

	int client = GetClientOfUserId(ReadPackCell(DP));

	char GangName[32];

	ReadPackString(DP, GangName, sizeof(GangName));
	int GangId = ReadPackCell(DP);

	int GangHonor = ReadPackCell(DP);

	CloseHandle(DP);

	Handle hMenu = CreateMenu(TopGangs_GangInfo_MenuHandler);

	char TempFormat[200], iAuthId[35], Name[64];
	while (SQL_FetchRow(hndl))
	{
		char strRank[32];
		int  Rank = SQL_FetchIntByName(hndl, "GangRank");
		GetRankName(Rank, strRank, sizeof(strRank));
		SQL_FetchStringByName(hndl, "LastName", Name, sizeof(Name));
		SQL_FetchStringByName(hndl, "AuthId", iAuthId, sizeof(iAuthId));

		int amount;
		GetTrieValue(Trie_Donated, iAuthId, amount);

		char sHonor[16];

		AddCommas(amount, ",", sHonor, sizeof(sHonor));

		FormatEx(TempFormat, sizeof(TempFormat), "%s [%s] - %s [Donated: %s]", Name, strRank, FindClientByAuthId(iAuthId) != 0 ? "ONLINE" : "OFFLINE", sHonor);

		AddMenuItem(hMenu, iAuthId, TempFormat, ITEMDRAW_DISABLED);
	}

	SetMenuTitle(hMenu, "%s Member List of %s:\nGang Id: %i\nGang Honor: %i\n", MENU_PREFIX, GangName, GangId, GangHonor);

	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int TopGangs_GangInfo_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowTopGangsMenu(client);

	return 0;
}

void ShowGangPerks(int client)
{
	Handle hMenu = CreateMenu(Perks_MenuHandler);

	char TempFormat[150];

	Format(TempFormat, sizeof(TempFormat), "Health ( T ) [ %i / %i ] Bonus: +%i [ %i per level ]", ClientHealthPerkT[client], GANG_HEALTHMAX, ClientHealthPerkT[client] * GANG_HEALTHINCREASE, GANG_HEALTHINCREASE);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);

	Format(TempFormat, sizeof(TempFormat), "Cooldown [ %i / %i ] Bonus: +%.1f%% [ %.1f%% per level ]", ClientCooldownPerk[client], GANG_COOLDOWNMAX, ClientCooldownPerk[client] * GANG_COOLDOWNINCREASE, GANG_COOLDOWNINCREASE);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);

	Format(TempFormat, sizeof(TempFormat), "Nade Chance ( T ) [ %i / %i ] Bonus: %.3f%% [ %.3f per level ]", ClientNadePerkT[client], GANG_NADEMAX, ClientNadePerkT[client] * GANG_NADEINCREASE, GANG_NADEINCREASE);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);

	Format(TempFormat, sizeof(TempFormat), "Health ( CT ) [ %i / %i ] Bonus: +%i [ %i per level ]", ClientHealthPerkCT[client], GANG_HEALTHMAX, ClientHealthPerkCT[client] * GANG_HEALTHINCREASE, GANG_HEALTHINCREASE);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);

	Format(TempFormat, sizeof(TempFormat), "Get Honor [ %i / %i ] Bonus: %i [ %i per level ]", ClientGetHonorPerk[client], GANG_GETCREDITSMAX, ClientGetHonorPerk[client] * GANG_GETCREDITSINCREASE, GANG_GETCREDITSINCREASE);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);

	Format(TempFormat, sizeof(TempFormat), "Gang Size [ %i / %i ] Bonus: %i [ %i per level ]", ClientGangSizePerk[client], GANG_SIZEMAX, ClientGangSizePerk[client] * GANG_SIZEINCREASE, GANG_SIZEINCREASE);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);

	Format(TempFormat, sizeof(TempFormat), "Friendly Fire Decrease [ %i / %i ] Bonus: -%i%% [ %i%% per level ]\nNote: Friendly Fire decrease applies on Days only.", ClientFriendlyFirePerk[client], GANG_FRIENDLYFIREMAX, ClientFriendlyFirePerk[client] * GANG_FRIENDLYFIREINCREASE, GANG_FRIENDLYFIREINCREASE);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);

	SetMenuPagination(hMenu, MENU_NO_PAGINATION);
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int Perks_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		Command_Gang(client, 0);

	return 0;
}

stock void ShowManageGangMenu(int client, int item = 0)
{
	Handle hMenu = CreateMenu(ManageGang_MenuHandler);

	AddMenuItem(hMenu, "", "Mod Logs");

	AddMenuItem(hMenu, "", "Invite To Gang", CheckGangAccess(client, ClientAccessInvite[client]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Kick From Gang", CheckGangAccess(client, ClientAccessKick[client]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Promote Member", CheckGangAccess(client, ClientAccessPromote[client]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Upgrade Perks", CheckGangAccess(client, ClientAccessUpgrade[client]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Set Gang MOTD", CheckGangAccess(client, ClientAccessMOTD[client]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Disband Gang", CheckGangAccess(client, RANK_LEADER) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Manage Actions Access", CheckGangAccess(client, RANK_LEADER) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Rename Gang", CheckGangAccess(client, RANK_LEADER) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	AddMenuItem(hMenu, "", "Change Gang Prefix", CheckGangAccess(client, RANK_LEADER) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	char sPrice[16], sTime[32];

	AddCommas(GetConVarInt(hcv_WeeklyTax), ",", sPrice, sizeof(sPrice));

	FormatTime(sTime, sizeof(sTime), "%d/%m/%Y - %X", ClientGangNextWeekly[client]);

	if (GetConVarInt(hcv_WeeklyTax) > 0)
		SetMenuTitle(hMenu, "%s Manage Gang\nWeekly tax: %s Honor\nDate of next Tax: %s", MENU_PREFIX, sPrice, sTime);

	else
		SetMenuTitle(hMenu, "%s Manage Gang", MENU_PREFIX);

	SetMenuExitBackButton(hMenu, true);
	DisplayMenuAtItem(hMenu, client, item, MENU_TIME_FOREVER);
}

public int ManageGang_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		Command_Gang(client, 0);

	else if (action == MenuAction_Select)
	{
		if (!CheckGangAccess(client, ClientAccessManage[client]) || ClientGangHonor[client] < 0)
		{
			Command_Gang(client, 0);
			return 0;
		}
		switch (item)
		{
			case 0:
			{
				if (!CheckGangAccess(client, ClientAccessManage[client]))
					return 0;

				ShowModLogs(client);
			}
			case 1:
			{
				if (!CheckGangAccess(client, ClientAccessInvite[client]))
					return 0;

				else if (ClientMembersCount[client] >= (GANG_INITSIZE + (ClientGangSizePerk[client] * GANG_SIZEINCREASE)))
				{
					UC_PrintToChat(client, "%s The gang is \x07full!", PREFIX);
					return 0;
				}
				ShowInviteMenu(client);
			}

			case 2:
			{
				if (!CheckGangAccess(client, ClientAccessKick[client]))
					return 0;

				ShowKickMenu(client);
			}
			case 3:
			{
				if (!CheckGangAccess(client, ClientAccessPromote[client]))
					return 0;

				ShowPromoteMenu(client);
			}
			case 4:
			{
				if (!CheckGangAccess(client, ClientAccessUpgrade[client]))
					return 0;

				ShowUpgradeMenu(client);
			}
			case 5:
			{
				if (!CheckGangAccess(client, ClientAccessMOTD[client]))
					return 0;

				UC_PrintToChat(client, "%s Use \x07!motdgang \x01<new motd> to change the gang's \x07motd.", PREFIX);

				ShowManageGangMenu(client, GetMenuSelectionPosition());
			}

			case 6:
			{
				if (!CheckGangAccess(client, RANK_LEADER))
					return 0;

				GangAttemptDisband[client] = true;
				UC_PrintToChat(client, "%s Write \x07!confirmdisbandgang \x01to confirm DELETION of the \x05gang.", PREFIX);
				UC_PrintToChat(client, "%s Write anything else in the chat to abort deleting the \x05gang.", PREFIX);
				UC_PrintToChat(client, "%s ATTENTION! THIS ACTION WILL PERMANENTLY DELETE YOUR \x07GANG\x01, IT IS NOT UNDOABLE AND YOU WILL NOT BE \x07REFUNDED!!!", PREFIX);
			}

			case 7:
			{
				if (!CheckGangAccess(client, RANK_LEADER))
					return 0;

				ShowActionAccessMenu(client);
			}
			case 8:
			{
				if (!CheckGangAccess(client, RANK_LEADER))
					return 0;

				UC_PrintToChat(client, "%s Use \x07!renamegang \x01<new name> to change the gang's \x07name.", PREFIX);

				ShowManageGangMenu(client, GetMenuSelectionPosition());
			}

			case 9:
			{
				if (!CheckGangAccess(client, RANK_LEADER))
					return 0;

				UC_PrintToChat(client, "%s Use \x07!prefixgang \x01<new prefix> to change the gang's \x07prefix.", PREFIX);

				ShowManageGangMenu(client, GetMenuSelectionPosition());
			}
		}
	}

	return 0;
}

void ShowActionAccessMenu(int client)
{
	Handle hMenu = CreateMenu(ActionAccess_MenuHandler);
	char   RankName[32];
	char   TempFormat[256];
	GetRankName(ClientAccessInvite[client], RankName, sizeof(RankName));
	Format(TempFormat, sizeof(TempFormat), "Invite to Gang - [%s]", RankName);
	AddMenuItem(hMenu, "", TempFormat);

	GetRankName(ClientAccessKick[client], RankName, sizeof(RankName));
	Format(TempFormat, sizeof(TempFormat), "Kick from Gang - [%s]", RankName);
	AddMenuItem(hMenu, "", TempFormat);

	GetRankName(ClientAccessPromote[client], RankName, sizeof(RankName));
	Format(TempFormat, sizeof(TempFormat), "Promote Member - [%s]", RankName);
	AddMenuItem(hMenu, "", TempFormat);

	GetRankName(ClientAccessUpgrade[client], RankName, sizeof(RankName));
	Format(TempFormat, sizeof(TempFormat), "Upgrade Perks - [%s]", RankName);
	AddMenuItem(hMenu, "", TempFormat);

	GetRankName(ClientAccessMOTD[client], RankName, sizeof(RankName));
	Format(TempFormat, sizeof(TempFormat), "Set Gang MOTD - [%s]", RankName);
	AddMenuItem(hMenu, "", TempFormat);

	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int ActionAccess_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowManageGangMenu(client);

	else if (action == MenuAction_Select)
	{
		if (!CheckGangAccess(client, RANK_LEADER))
			return 0;

		ClientActionEdit[client] = item;

		ShowActionAccessSetRankMenu(client);
	}

	return 0;
}

void ShowActionAccessSetRankMenu(int client)
{
	Handle hMenu = CreateMenu(ActionAccessSetRank_MenuHandler);
	char   RankName[32];

	for (int i = RANK_MEMBER; i <= GetClientRank(client); i++)
	{
		if (i == GetClientRank(client) && !CheckGangAccess(client, RANK_LEADER))
			break;

		else if (i > RANK_COLEADER)
			i = RANK_LEADER;

		GetRankName(i, RankName, sizeof(RankName));

		AddMenuItem(hMenu, "", RankName);
	}
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);

	char RightName[32];

	switch (ClientActionEdit[client])
	{
		case 0: RightName = "Invite";
		case 1: RightName = "Kick";
		case 2: RightName = "Promote";
		case 3: RightName = "Upgrade";
		case 4: RightName = "MOTD";
	}

	SetMenuTitle(hMenu, "Choose which minimum rank will have right to %s", RightName);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int ActionAccessSetRank_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowActionAccessMenu(client);

	else if (action == MenuAction_Select)
	{
		if (!CheckGangAccess(client, RANK_LEADER))
			return 0;

		int TrueRank = item > RANK_COLEADER ? RANK_LEADER : item;

		char ColumnName[32];
		switch (ClientActionEdit[client])
		{
			case 0: ColumnName = "GangMinRankInvite";
			case 1: ColumnName = "GangMinRankKick";
			case 2: ColumnName = "GangMinRankPromote";
			case 3: ColumnName = "GangMinRankUpgrade";
			case 4: ColumnName = "GangMinRankMOTD";
		}

		Handle DP = CreateDataPack();

		WritePackCell(DP, ClientGangId[client]);

		char sQuery[256];
		dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET '%s' = %i WHERE GangId = %i", ColumnName, TrueRank, ClientGangId[client]);
		dbGangs.Query(SQLCB_UpdateGang, sQuery, DP);
	}

	return 0;
}
void ShowUpgradeMenu(int client)
{
	Handle hMenu = CreateMenu(Upgrade_MenuHandler);

	char TempFormat[100], strUpgradeCost[20];

	int upgradecost = GetUpgradeCost(ClientHealthPerkT[client], GANG_HEALTHCOST);
	IntToString(upgradecost, strUpgradeCost, sizeof(strUpgradeCost));
	Format(TempFormat, sizeof(TempFormat), "Health ( T ) [ %i / %i ] Cost: %i", ClientHealthPerkT[client], GANG_HEALTHMAX, upgradecost);
	AddMenuItem(hMenu, strUpgradeCost, TempFormat, ClientGangHonor[client] >= upgradecost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	upgradecost = GetUpgradeCost(ClientCooldownPerk[client], GANG_COOLDOWNCOST);
	IntToString(upgradecost, strUpgradeCost, sizeof(strUpgradeCost));
	Format(TempFormat, sizeof(TempFormat), "Cooldown [ %i / %i ] Cost: %i", ClientCooldownPerk[client], GANG_COOLDOWNMAX, upgradecost);
	AddMenuItem(hMenu, strUpgradeCost, TempFormat, ClientGangHonor[client] >= upgradecost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	upgradecost = GetUpgradeCost(ClientNadePerkT[client], GANG_NADECOST);
	IntToString(upgradecost, strUpgradeCost, sizeof(strUpgradeCost));
	Format(TempFormat, sizeof(TempFormat), "Nade Chance ( T ) [ %i / %i ] Cost: %i", ClientNadePerkT[client], GANG_NADEMAX, upgradecost);
	AddMenuItem(hMenu, strUpgradeCost, TempFormat, ClientGangHonor[client] >= upgradecost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	upgradecost = GetUpgradeCost(ClientHealthPerkCT[client], GANG_HEALTHCOST);
	IntToString(upgradecost, strUpgradeCost, sizeof(strUpgradeCost));
	Format(TempFormat, sizeof(TempFormat), "Health ( CT ) [ %i / %i ] Cost: %i", ClientHealthPerkCT[client], GANG_HEALTHMAX, upgradecost);
	AddMenuItem(hMenu, strUpgradeCost, TempFormat, ClientGangHonor[client] >= upgradecost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	upgradecost = GetUpgradeCost(ClientGetHonorPerk[client], GANG_GETCREDITSCOST);
	IntToString(upgradecost, strUpgradeCost, sizeof(strUpgradeCost));
	Format(TempFormat, sizeof(TempFormat), "Get Honor [ %i / %i ] Cost: %i", ClientGetHonorPerk[client], GANG_GETCREDITSMAX, upgradecost);
	AddMenuItem(hMenu, strUpgradeCost, TempFormat, ClientGangHonor[client] >= upgradecost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	upgradecost = GetUpgradeCost(ClientGangSizePerk[client], GANG_SIZECOST);
	IntToString(upgradecost, strUpgradeCost, sizeof(strUpgradeCost));
	Format(TempFormat, sizeof(TempFormat), "Gang Size [ %i / %i ] Cost: %i", ClientGangSizePerk[client], GANG_SIZEMAX, upgradecost);
	AddMenuItem(hMenu, strUpgradeCost, TempFormat, ClientGangHonor[client] >= upgradecost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	upgradecost = GetUpgradeCost(ClientFriendlyFirePerk[client], GANG_FRIENDLYFIRECOST);
	IntToString(upgradecost, strUpgradeCost, sizeof(strUpgradeCost));
	Format(TempFormat, sizeof(TempFormat), "Friendly Fire Decrease [ %i / %i ] Cost: %i", ClientFriendlyFirePerk[client], GANG_FRIENDLYFIREMAX, upgradecost);
	AddMenuItem(hMenu, strUpgradeCost, TempFormat, ClientGangHonor[client] >= upgradecost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	SetMenuTitle(hMenu, "%s Choose what perks to upgrade:\nYour Gang's Honor: %i", MENU_PREFIX, ClientGangHonor[client]);
	SetMenuPagination(hMenu, MENU_NO_PAGINATION);
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int Upgrade_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowManageGangMenu(client);

	else if (action == MenuAction_Select)
	{
		if (!CheckGangAccess(client, ClientAccessUpgrade[client]))
			return 0;

		char strUpgradeCost[20];
		GetMenuItem(hMenu, item, strUpgradeCost, sizeof(strUpgradeCost));
		LoadClientGang_TryUpgrade(client, item, StringToInt(strUpgradeCost));
	}

	return 0;
}

void LoadClientGang_TryUpgrade(int client, int item, int upgradecost)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE AuthId = '%s'", AuthId);

	Handle DP = CreateDataPack();

	WritePackCell(DP, GetClientUserId(client));
	WritePackCell(DP, item);
	WritePackCell(DP, upgradecost);
	dbGangs.Query(SQLCB_LoadClientGang_TryUpgrade, sQuery, DP, DBPrio_High);
}

public void SQLCB_LoadClientGang_TryUpgrade(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	ResetPack(DP);

	int client = GetClientOfUserId(ReadPackCell(DP));
	if (!IsValidPlayer(client))
	{
		CloseHandle(DP);
		return;
	}
	else
	{
		if (SQL_GetRowCount(hndl) != 0)
		{
			SQL_FetchRow(hndl);

			SQL_FetchStringByName(hndl, "GangName", ClientGang[client], sizeof(ClientGang[]));
			ClientRank[client] = SQL_FetchIntByName(hndl, "GangRank");

			char sQuery[256];
			dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Gangs WHERE GangId = %i", ClientGangId[client]);
			dbGangs.Query(SQLCB_LoadGangByClient_TryUpgrade, sQuery, DP, DBPrio_High);
		}
		else
		{
			CloseHandle(DP);
			ClientLoadedFromDb[client] = true;
		}
	}
}

public void SQLCB_LoadGangByClient_TryUpgrade(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	ResetPack(DP);

	int client      = GetClientOfUserId(ReadPackCell(DP));
	int item        = ReadPackCell(DP);
	int upgradecost = ReadPackCell(DP);

	CloseHandle(DP);
	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		if (SQL_GetRowCount(hndl) != 0)
		{
			SQL_FetchRow(hndl);

			ClientGangId[client] = SQL_FetchIntByName(hndl, "GangId");
			SQL_FetchStringByName(hndl, "GangName", ClientGang[client], sizeof(ClientGang[]));
			SQL_FetchStringByName(hndl, "GangMOTD", ClientMotd[client], sizeof(ClientMotd[]));
			ClientGangHonor[client]    = SQL_FetchIntByName(hndl, "GangHonor");
			ClientHealthPerkT[client]  = SQL_FetchIntByName(hndl, "GangHealthPerkT");
			ClientCooldownPerk[client] = SQL_FetchIntByName(hndl, "GangCooldownPerk");
			ClientNadePerkT[client]    = SQL_FetchIntByName(hndl, "GangNadePerkT");
			ClientHealthPerkCT[client] = SQL_FetchIntByName(hndl, "GangHealthPerkCT");
			ClientGetHonorPerk[client] = SQL_FetchIntByName(hndl, "GangGetHonorPerk");
			ClientGangSizePerk[client] = SQL_FetchIntByName(hndl, "GangSizePerk");

			TryUpgradePerk(client, item, upgradecost);
		}
	}
}

void TryUpgradePerk(int client, int item, int upgradecost)    // Safety accomplished.
{
	if (ClientGangHonor[client] < upgradecost)
	{
		UC_PrintToChat(client, "%s Your gang doesn't have enough honor to \x07upgrade.", PREFIX);
		return;
	}
	int  PerkToUse, PerkMax;
	char PerkName[32], PerkNick[32];

	switch (item + 1)
	{
		case 1: PerkToUse = ClientHealthPerkT[client], PerkMax = GANG_HEALTHMAX, PerkName = "GangHealthPerkT", PerkNick = "Health ( T )";
		case 2: PerkToUse = ClientCooldownPerk[client], PerkMax = GANG_COOLDOWNMAX, PerkName = "GangCooldownPerk", PerkNick = "Cooldown";
		case 3: PerkToUse = ClientNadePerkT[client], PerkMax = GANG_NADEMAX, PerkName = "GangNadePerkT", PerkNick = "Nade Chance ( T )";
		case 4: PerkToUse = ClientHealthPerkCT[client], PerkMax = GANG_HEALTHMAX, PerkName = "GangHealthPerkCT", PerkNick = "Health ( CT )";
		case 5: PerkToUse = ClientGetHonorPerk[client], PerkMax = GANG_GETCREDITSMAX, PerkName = "GangGetHonorPerk", PerkNick = "Get Honor";
		case 6: PerkToUse = ClientGangSizePerk[client], PerkMax = GANG_SIZEMAX, PerkName = "GangSizePerk", PerkNick = "Gang Size";
		case 7: PerkToUse = ClientFriendlyFirePerk[client], PerkMax = GANG_FRIENDLYFIREMAX, PerkName = "GangFFPerk", PerkNick = "Friendly Fire Decrease";
		default: return;
	}

	if (PerkToUse >= PerkMax)
	{
		UC_PrintToChat(client, "%s Your gang has \x07already \x01maxed this perk!", PREFIX);
		return;
	}

	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	char        sQuery[256];
	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET %s = %s + 1, GangHonor = GangHonor - %i WHERE GangId = %i", PerkName, PerkName, upgradecost, ClientGangId[client]);
	SQL_AddQuery(transaction, sQuery);

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_upgradelogs (GangId, GangName, AuthId, Perk, BValue, AValue, timestamp) VALUES (%i, '%s', '%s', '%s', %i, %i, %i)", ClientGangId[client], ClientGang[client], steamid, PerkName, PerkToUse, PerkToUse + 1, GetTime());
	SQL_AddQuery(transaction, sQuery);

	char upgraderAuthId[35];
	GetClientAuthId(client, AuthId_Steam2, upgraderAuthId, sizeof(upgraderAuthId));

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_modlogs (GangId, AuthId, ModAction, ModActionNumber, ModActionWord, ModTarget, timestamp) VALUES (%i, '%s', %i, %i, '%s', '%s', %i)", ClientGangId[client], upgraderAuthId, MODACTION_UPGRADE, PerkToUse + 1, PerkNick, upgraderAuthId, GetTime());
	SQL_AddQuery(transaction, sQuery);

	Handle DP = CreateDataPack();

	WritePackCell(DP, ClientGangId[client]);

	dbGangs.Execute(transaction, SQLTrans_GangDonated, SQLTrans_SetFailState, DP);

	PrintToChatGang(ClientGangId[client], "%s \x05%N \x01has upgraded the gang perk \x07%s!", PREFIX, client, PerkNick);
}

public void SQLCB_UpdateGang(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
		SetFailState(error);

	ResetPack(DP);

	int GangId = ReadPackCell(DP);

	CloseHandle(DP);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		else if (ClientGangId[i] != GangId)
			continue;

		ResetVariables(i, false);

		LoadClientGang(i);
	}
}

void ShowPromoteMenu(int client)
{
	FindDonationsForGang(ClientGangId[client]);

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE GangId = %i ORDER BY LastConnect DESC", ClientGangId[client]);
	dbGangs.Query(SQLCB_ShowPromoteMenu, sQuery, GetClientUserId(client));
}

public void SQLCB_ShowPromoteMenu(Handle owner, DBResultSet hndl, char[] error, int UserId)
{
	if (hndl == null)
	{
		SetFailState(error);
	}
	int client = GetClientOfUserId(UserId);

	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		Handle hMenu = CreateMenu(Promote_MenuHandler);

		char TempFormat[200], Info[250], iAuthId[35], Name[64];
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchStringByName(hndl, "AuthId", iAuthId, sizeof(iAuthId));
			int Rank = SQL_FetchIntByName(hndl, "GangRank");

			char strRank[32];
			GetRankName(Rank, strRank, sizeof(strRank));
			SQL_FetchStringByName(hndl, "LastName", Name, sizeof(Name));

			int LastConnect = SQL_FetchIntByName(hndl, "LastConnect");

			Format(Info, sizeof(Info), "\"%s\" \"%s\" \"%i\" \"%i\"", iAuthId, Name, Rank, LastConnect);

			int amount;
			GetTrieValue(Trie_Donated, iAuthId, amount);

			char sHonor[16];

			AddCommas(amount, ",", sHonor, sizeof(sHonor));

			FormatEx(TempFormat, sizeof(TempFormat), "%s [%s] - %s [Donated: %s]", Name, strRank, FindClientByAuthId(iAuthId) != 0 ? "ONLINE" : "OFFLINE", sHonor);

			AddMenuItem(hMenu, Info, TempFormat, Rank < GetClientRank(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}

		SetMenuTitle(hMenu, "%s Choose who to promote:", MENU_PREFIX);

		SetMenuExitButton(hMenu, true);
		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Promote_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowManageGangMenu(client);

	else if (action == MenuAction_Select)
	{
		char Info[200];
		GetMenuItem(hMenu, item, Info, sizeof(Info));

		PromoteMenu_ChooseRank(client, Info);
	}

	return 0;
}

void PromoteMenu_ChooseRank(int client, const char[] Info)
{
	Handle hMenu = CreateMenu(ChooseRank_MenuHandler);

	for (int i = RANK_MEMBER; i <= GetClientRank(client); i++)
	{
		if (i == GetClientRank(client) && !CheckGangAccess(client, RANK_LEADER))
			break;

		else if (i > RANK_COLEADER)
			i = RANK_LEADER;

		char RankName[20];
		GetRankName(i, RankName, sizeof(RankName));

		AddMenuItem(hMenu, Info, RankName);
	}

	char iAuthId[35], Name[64], strRank[11], strLastConnect[11];

	int len = BreakString(Info, iAuthId, sizeof(iAuthId));

	int len2 = BreakString(Info[len], Name, sizeof(Name));

	int len3 = BreakString(Info[len + len2], strRank, sizeof(strRank));

	BreakString(Info[len + len2 + len3], strLastConnect, sizeof(strLastConnect));

	char Date[64];
	FormatTime(Date, sizeof(Date), "%d/%m/%Y - %H:%M:%S", StringToInt(strLastConnect));

	SetMenuTitle(hMenu, "%s Choose the rank you want to give to %s\nTarget's Last Connect: %s", MENU_PREFIX, Name, Date);

	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, client, 30);
}

public int ChooseRank_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowPromoteMenu(client);

	else if (action == MenuAction_Select)
	{
		char Info[200], iAuthId[35], strRank[20], strLastConnect[11], Name[64];
		GetMenuItem(hMenu, item, Info, sizeof(Info));

		int len = BreakString(Info, iAuthId, sizeof(iAuthId));

		int len2 = BreakString(Info[len], Name, sizeof(Name));

		int len3 = BreakString(Info[len + len2], strRank, sizeof(strRank));

		BreakString(Info[len + len2 + len3], strLastConnect, sizeof(strLastConnect));

		if (item > RANK_COLEADER)
			item = RANK_LEADER;

		if (item < GetClientRank(client))
		{
			char NewRank[32];
			GetRankName(item, NewRank, sizeof(NewRank));
			PrintToChatGang(ClientGangId[client], " %s has been \x07promoted \x01to \x05%s", Name, NewRank);
			SetAuthIdRank(iAuthId, ClientGangId[client], item, client);
		}
		else
		{
			GangAttemptStepDown[client] = true;

			int target = FindClientByAuthId(iAuthId);

			if (target == 0)
			{
				UC_PrintToChat(client, "%s The target must be \x05connected \x01for a step-down action for security \x07reasons.", PREFIX);

				return 0;
			}

			GangStepDownTarget[client] = GetClientUserId(target);

			UC_PrintToChat(client, "%s Attention! \x05You are attempting to promote a player to be the \x07Leader.", PREFIX);
			UC_PrintToChat(client, "%s By doing so you will become a \x07Co-Leader \x01in the gang.", PREFIX);
			UC_PrintToChat(client, "%s This action is irreversible, the new \x07leader \x01can kick you if he wants.", PREFIX);
			UC_PrintToChat(client, "%s If you read all above and sure you want to continue, write \x07!confirmstepdowngang.", PREFIX);
			UC_PrintToChat(client, "%s Write anything else in the chat to abort the \x07action", PREFIX);
		}
	}

	return 0;
}

void ShowKickMenu(int client)
{
	FindDonationsForGang(ClientGangId[client]);

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE GangId = %i ORDER BY LastConnect DESC", ClientGangId[client]);
	dbGangs.Query(SQLCB_ShowKickMenu, sQuery, GetClientUserId(client));
}

public void SQLCB_ShowKickMenu(Handle owner, DBResultSet hndl, char[] error, int UserId)
{
	if (hndl == null)
	{
		SetFailState(error);
	}
	int client = GetClientOfUserId(UserId);

	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		Handle hMenu = CreateMenu(Kick_MenuHandler);

		char TempFormat[200], Info[250], iAuthId[35], Name[64];
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchStringByName(hndl, "AuthId", iAuthId, sizeof(iAuthId));
			int Rank = SQL_FetchIntByName(hndl, "GangRank");

			char strRank[32];
			GetRankName(Rank, strRank, sizeof(strRank));
			SQL_FetchStringByName(hndl, "LastName", Name, sizeof(Name));

			int LastConnect = SQL_FetchIntByName(hndl, "LastConnect");

			Format(Info, sizeof(Info), "\"%s\" \"%s\" \"%i\" \"%i\"", iAuthId, Name, Rank, LastConnect);
			int amount;
			GetTrieValue(Trie_Donated, iAuthId, amount);

			char sHonor[16];

			AddCommas(amount, ",", sHonor, sizeof(sHonor));

			FormatEx(TempFormat, sizeof(TempFormat), "%s [%s] - %s [Donated: %s]", Name, strRank, FindClientByAuthId(iAuthId) != 0 ? "ONLINE" : "OFFLINE", sHonor);

			AddMenuItem(hMenu, Info, TempFormat, Rank < GetClientRank(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}

		SetMenuTitle(hMenu, "%s Choose who to kick:", MENU_PREFIX);

		SetMenuExitButton(hMenu, true);
		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Kick_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowManageGangMenu(client);

	else if (action == MenuAction_Select)
	{
		char Info[200], iAuthId[35], strRank[20], strLastConnect[11], Name[64];
		GetMenuItem(hMenu, item, Info, sizeof(Info));

		int len = BreakString(Info, iAuthId, sizeof(iAuthId));

		int len2 = BreakString(Info[len], Name, sizeof(Name));

		int len3 = BreakString(Info[len + len2], strRank, sizeof(strRank));

		BreakString(Info[len + len2 + len3], strLastConnect, sizeof(strLastConnect));

		if (StringToInt(strRank) >= GetClientRank(client))    // Should never return but better safe than sorry.
			return 0;

		ShowConfirmKickMenu(client, iAuthId, Name, StringToInt(strLastConnect));
	}

	return 0;
}

void ShowConfirmKickMenu(int client, const char[] iAuthId, const char[] Name, int LastConnect)
{
	Handle hMenu = CreateMenu(ConfirmKick_MenuHandler);

	AddMenuItem(hMenu, iAuthId, "Yes");
	AddMenuItem(hMenu, Name, "No");    // This will also be used.

	char Date[64];
	FormatTime(Date, sizeof(Date), "%d/%m/%Y - %H:%M:%S", LastConnect);

	SetMenuTitle(hMenu, "%s Gang Kick\nAre you sure you want to kick %s?\nSteam ID of target: %s\nTarget's last connect: %s", MENU_PREFIX, Name, iAuthId, Date);
	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, client, 60);
}

public int ConfirmKick_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowKickMenu(client);

	else if (action == MenuAction_Select)
	{
		if (item + 1 == 1)
		{
			char iAuthId[35], Name[64];
			GetMenuItem(hMenu, 0, iAuthId, sizeof(iAuthId));
			GetMenuItem(hMenu, 1, Name, sizeof(Name));

			PrintToChatGang(ClientGangId[client], "%s \x05%N \x01has kicked \x07%s \x01from the gang!", PREFIX, client, Name);

			KickAuthIdFromGang(iAuthId, ClientGangId[client], client);
		}
	}

	return 0;
}

stock void ShowModLogs(int client, int item = 0)
{
	char        sQuery[256];
	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT AuthId, LastName FROM GangSystem_Members");
	SQL_AddQuery(transaction, sQuery);

	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_modlogs WHERE GangId = %i ORDER BY timestamp DESC LIMIT 500", ClientGangId[client]);
	SQL_AddQuery(transaction, sQuery);

	DataPack DP = CreateDataPack();

	WritePackCell(DP, GetClientUserId(client));
	WritePackCell(DP, item);

	dbGangs.Execute(transaction, SQLTrans_ShowModLogsMenu, SQLTrans_SetFailState, DP);
}

public void SQLTrans_ShowModLogsMenu(Database db, DataPack DP, int numQueries, DBResultSet[] results, any[] queryData)
{
	ResetPack(DP);

	int client = GetClientOfUserId(ReadPackCell(DP));
	int item   = ReadPackCell(DP);

	CloseHandle(DP);

	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		Handle hMenu = CreateMenu(ModLogs_MenuHandler);

		char TempFormat[200];

		StringMap smNames = new StringMap();

		while (SQL_FetchRow(results[0]))
		{
			char AuthId[35], LastName[64];

			SQL_FetchStringByName(results[0], "AuthId", AuthId, sizeof(AuthId));
			SQL_FetchStringByName(results[0], "LastName", LastName, sizeof(LastName));

			smNames.SetString(AuthId, LastName, true);
		}

		while (SQL_FetchRow(results[1]))
		{
			int modAction = SQL_FetchIntByName(results[1], "ModAction");

			char TargetAuthId[35], TargetLastName[64];
			SQL_FetchStringByName(results[1], "ModTarget", TargetAuthId, sizeof(TargetAuthId));

			smNames.GetString(TargetAuthId, TargetLastName, sizeof(TargetLastName));

			char AuthId[35], LastName[64];
			SQL_FetchStringByName(results[1], "AuthId", AuthId, sizeof(AuthId));

			smNames.GetString(AuthId, LastName, sizeof(LastName));

			DP = CreateDataPack();
			WritePackCell(DP, modAction);

			WritePackString(DP, TargetAuthId);
			WritePackString(DP, TargetLastName);

			WritePackString(DP, AuthId);
			WritePackString(DP, LastName);

			WritePackCell(DP, SQL_FetchIntByName(results[1], "timestamp"));

			switch (modAction)
			{
				case MODACTION_INVITE:
				{
					FormatEx(TempFormat, sizeof(TempFormat), "%s was invited", TargetLastName);

					// Rank.
					WritePackCell(DP, SQL_FetchIntByName(results[1], "ModActionNumber"));
				}

				case MODACTION_KICK:
				{
					FormatEx(TempFormat, sizeof(TempFormat), "%s was kicked", TargetLastName);
				}

				case MODACTION_PROMOTE:
				{
					int  Rank = SQL_FetchIntByName(results[1], "ModActionNumber");
					char RankName[32];
					GetRankName(Rank, RankName, sizeof(RankName));

					FormatEx(TempFormat, sizeof(TempFormat), "%s was promoted to %s", TargetLastName, RankName);

					WritePackCell(DP, Rank);
				}

				case MODACTION_MOTD:
				{
					char MOTD[100];
					SQL_FetchStringByName(results[1], "ModActionWord", MOTD, sizeof(MOTD));

					FormatEx(TempFormat, sizeof(TempFormat), "MOTD changed by %s", LastName);

					WritePackString(DP, MOTD);
				}
				case MODACTION_UPGRADE:
				{
					char PerkNick[32];
					SQL_FetchStringByName(results[1], "ModActionWord", PerkNick, sizeof(PerkNick));

					FormatEx(TempFormat, sizeof(TempFormat), "%s upgraded %s", LastName, PerkNick);

					WritePackCell(DP, SQL_FetchIntByName(results[1], "ModActionNumber"));
					WritePackString(DP, PerkNick);
				}
					// Not needed to put disband here, we must restore the gang from MySQL anyways...
			}

			char sInfo[32];
			IntToString(view_as<int>(DP), sInfo, sizeof(sInfo));

			AddMenuItem(hMenu, sInfo, TempFormat);
		}

		SetMenuTitle(hMenu, "%s Mod Logs, sorting from new to old:", MENU_PREFIX);

		SetMenuExitButton(hMenu, true);
		SetMenuExitBackButton(hMenu, true);
		DisplayMenuAtItem(hMenu, client, item, MENU_TIME_FOREVER);

		delete smNames;
	}
}

public int ModLogs_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
	{
		char sInfo[32];
		int  i = 0;
		while (GetMenuItem(hMenu, i++, sInfo, sizeof(sInfo)))
		{
			delete view_as<DataPack>(StringToInt(sInfo));
		}

		CloseHandle(hMenu);
	}

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowManageGangMenu(client);

	else if (action == MenuAction_Select)
	{
		char sInfo[32];
		GetMenuItem(hMenu, item, sInfo, sizeof(sInfo));

		DataPack DP = view_as<DataPack>(StringToInt(sInfo));

		DP.Reset();

		int modAction = ReadPackCell(DP);

		char TargetAuthId[35], TargetLastName[35];
		ReadPackString(DP, TargetAuthId, sizeof(TargetAuthId));
		ReadPackString(DP, TargetLastName, sizeof(TargetLastName));

		char AuthId[35], LastName[35];
		ReadPackString(DP, AuthId, sizeof(AuthId));
		ReadPackString(DP, LastName, sizeof(LastName));

		int timestamp = ReadPackCell(DP);

		char sTime[32];

		FormatTime(sTime, sizeof(sTime), "%d/%m/%Y - %X", timestamp);

		switch (modAction)
		{
			case MODACTION_INVITE:
			{
				int  Rank = ReadPackCell(DP);
				char RankName[32];
				GetRankName(Rank, RankName, sizeof(RankName));

				if (Rank == RANK_MEMBER)
				{
					UC_PrintToChat(client, "%s [%s] was invited by %s [%s] at %s", TargetLastName, TargetAuthId, LastName, AuthId, sTime);
				}
				else
				{
					UC_PrintToChat(client, "%s [%s] was invited as %s by %s [%s] at %s", TargetLastName, TargetAuthId, RankName, LastName, AuthId, sTime);
				}
			}

			case MODACTION_KICK:
			{
				UC_PrintToChat(client, "%s [%s] was kicked by %s [%s] at %s", TargetLastName, TargetAuthId, LastName, AuthId, sTime);
			}

			case MODACTION_PROMOTE:
			{
				int  Rank = ReadPackCell(DP);
				char RankName[32];
				GetRankName(Rank, RankName, sizeof(RankName));

				UC_PrintToChat(client, "%s [%s] was promoted to %s by %s [%s] at %s", TargetLastName, TargetAuthId, RankName, LastName, AuthId, sTime);
			}

			case MODACTION_MOTD:
			{
				char MOTD[100];
				ReadPackString(DP, MOTD, sizeof(MOTD));

				UC_PrintToChat(client, "%s [%s] changed the MOTD at %s to:", LastName, AuthId, sTime);
				UC_PrintToChat(client, "%s", MOTD);
			}
			case MODACTION_UPGRADE:
			{
				int PerkLevel = ReadPackCell(DP);

				char PerkNick[32];
				ReadPackString(DP, PerkNick, sizeof(PerkNick));

				UC_PrintToChat(client, "%s [%s] upgraded perk %s to level %i", LastName, AuthId, PerkNick, PerkLevel);
			}
				// Not needed to put disband here, we must restore the gang from MySQL anyways...
		}

		ShowModLogs(client, GetMenuSelectionPosition());
	}

	return 0;
}

void ShowInviteMenu(int client)
{
	Handle hMenu = CreateMenu(Invite_MenuHandler);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		else if (IsClientGang(i))
			continue;

		// else if(IsFakeClient(i))
		// continue;

		char strUserId[20], iName[64];
		IntToString(GetClientUserId(i), strUserId, sizeof(strUserId));
		GetClientName(i, iName, sizeof(iName));

		AddMenuItem(hMenu, strUserId, iName);
	}

	SetMenuTitle(hMenu, "%s Choose who to invite:", MENU_PREFIX);

	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int Invite_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		ShowManageGangMenu(client);

	else if (action == MenuAction_Select)
	{
		char strUserId[20];
		GetMenuItem(hMenu, item, strUserId, sizeof(strUserId));

		int target = GetClientOfUserId(StringToInt(strUserId));

		if (IsValidPlayer(target))
		{
			if (!IsClientGang(target))
			{
				if (!IsFakeClient(target))
				{
					char AuthId[35];
					GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));
					ShowAcceptInviteMenu(target, AuthId, ClientGangId[client], ClientGang[client]);
					UC_PrintToChat(client, "%s \x05You \x01have invited \x07%N \x01to join the gang!", PREFIX, target);
				}
				else
				{
					char AuthId[35];
					GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));
					AddClientToGang(target, AuthId, ClientGangId[client]);
				}
			}
		}
	}

	return 0;
}

void ShowAcceptInviteMenu(int target, const char[] AuthIdInviter, int GangId, const char[] GangName)
{
	if (!IsValidPlayer(target))
		return;

	Handle hMenu = CreateMenu(AcceptInvite_MenuHandler);

	char Info[11];
	IntToString(GangId, Info, sizeof(Info));

	AddMenuItem(hMenu, AuthIdInviter, "Yes");
	AddMenuItem(hMenu, Info, "No");    // This info string will also be used.

	SetMenuTitle(hMenu, "%s Gang Invite\nWould you like to join the gang %s?", MENU_PREFIX, GangName);
	DisplayMenu(hMenu, target, 10);
}

public int AcceptInvite_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Select)
	{
		if (item + 1 == 1)
		{
			char AuthIdInviter[35], Info[32];
			GetMenuItem(hMenu, 0, AuthIdInviter, sizeof(AuthIdInviter));
			GetMenuItem(hMenu, 1, Info, sizeof(Info));

			int GangId = StringToInt(Info);

			int LastGangId = ClientGangId[client];

			ClientGangId[client] = GangId;
			PrintToChatGang(ClientGangId[client], "%s \x05%N \x01has joined the \x07gang!", PREFIX, client);
			ClientGangId[client] = LastGangId;

			AddClientToGang(client, AuthIdInviter, GangId);
		}
	}

	return 0;
}

void ShowMembersMenu(int client)
{
	FindDonationsForGang(ClientGangId[client]);

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE GangId = %i ORDER BY LastConnect DESC", ClientGangId[client]);
	dbGangs.Query(SQLCB_ShowMembersMenu, sQuery, GetClientUserId(client));
}

public void SQLCB_ShowMembersMenu(Handle owner, DBResultSet hndl, char[] error, int UserId)
{
	if (hndl == null)
	{
		SetFailState(error);
	}
	int client = GetClientOfUserId(UserId);

	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		if (ClientGangHonor[client] < 0)
			return;

		Handle hMenu = CreateMenu(Members_MenuHandler);

		char TempFormat[200], iAuthId[35], Name[64];
		while (SQL_FetchRow(hndl))
		{
			char strRank[32];

			int Rank = SQL_FetchIntByName(hndl, "GangRank");
			GetRankName(Rank, strRank, sizeof(strRank));

			SQL_FetchStringByName(hndl, "LastName", Name, sizeof(Name));
			SQL_FetchStringByName(hndl, "AuthId", iAuthId, sizeof(iAuthId));

			int amount;
			GetTrieValue(Trie_Donated, iAuthId, amount);

			char sHonor[16];

			AddCommas(amount, ",", sHonor, sizeof(sHonor));

			FormatEx(TempFormat, sizeof(TempFormat), "%s [%s] - %s [Donated: %s]", Name, strRank, FindClientByAuthId(iAuthId) != 0 ? "ONLINE" : "OFFLINE", sHonor);

			AddMenuItem(hMenu, iAuthId, TempFormat);
		}

		SetMenuTitle(hMenu, "%s Member List:", MENU_PREFIX);

		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
}

public int Members_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
		CloseHandle(hMenu);

	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
		Command_Gang(client, 0);

	else if (action == MenuAction_Select)
	{
		char iAuthId[32];

		GetMenuItem(hMenu, item, iAuthId, sizeof(iAuthId));

		int amount, amountWeek;
		GetTrieValue(Trie_Donated, iAuthId, amount);
		GetTrieValue(Trie_DonatedWeek, iAuthId, amountWeek);

		char sHonor[16], sHonorWeek[16];

		AddCommas(amount, ",", sHonor, sizeof(sHonor));
		AddCommas(amountWeek, ",", sHonorWeek, sizeof(sHonorWeek));

		UC_PrintToChat(client, "Total donations: %s. Weekly Donations: %s", sHonor, sHonorWeek);

		ShowMembersMenu(client);
	}

	return 0;
}

void TryCreateGang(int client, const char[] GangName)
{
	if (GangName[0] == EOS)
	{
		GangCreateName[client] = GANG_NULL;
		UC_PrintToChat(client, "%s The selected gang name is \x07invalid.", PREFIX);
		return;
	}
	else if (ClientHonor[client] < GANG_COSTCREATE)
	{
		GangCreateName[client] = GANG_NULL;
		UC_PrintToChat(client, "%s \x05You \x01need \x07%i \x01more honor to open a gang!", PREFIX, GANG_COSTCREATE - ClientHonor[client]);
		return;
	}
	Handle DP = CreateDataPack();
	WritePackCell(DP, GetClientUserId(client));
	WritePackString(DP, GangName);

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Gangs WHERE lower(GangName) = lower('%s')", GangName);
	dbGangs.Query(SQLCB_CreateGang_CheckTakenName, sQuery, DP);
}

public void SQLCB_CreateGang_CheckTakenName(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		SetFailState(error);
	}
	ResetPack(DP);

	int  client = GetClientOfUserId(ReadPackCell(DP));
	char GangName[32];

	ReadPackString(DP, GangName, sizeof(GangName));

	CloseHandle(DP);

	if (!IsValidPlayer(client))
	{
		return;
	}
	else
	{
		if (SQL_GetRowCount(hndl) == 0)
		{
			CreateGang(client, GangName);
			UC_PrintToChat(client, "%s The gang was \x07created!", PREFIX);
		}
		else    // Gang name is taken.
		{
			bool NameTaken = false;

			char iGangName[32];
			while (SQL_FetchRow(hndl))
			{
				SQL_FetchStringByName(hndl, "GangName", iGangName, sizeof(iGangName));

				if (StrEqual(iGangName, GangName, false))
					NameTaken = true;
			}

			if (NameTaken)
			{
				GangCreateName[client] = GANG_NULL;
				UC_PrintToChat(client, "%s The selected gang name is \x07already \x01taken!", PREFIX);
			}
		}
	}
}

void CreateGang(int client, const char[] GangName)
{
	if (ClientHonor[client] < GANG_COSTCREATE)
		return;

	char sQuery[1024];

	char AuthId[35];

	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	Handle DP = CreateDataPack();

	WritePackString(DP, AuthId);
	WritePackString(DP, GangName);

	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_Gangs (GangName, GangPrefix, GangPrefixMethod, GangNextWeekly, GangMOTD, GangHonor, GangHealthPerkT, GangCooldownPerk, GangNadePerkT, GangHealthPerkCT, GangGetHonorPerk, GangFFPerk, GangSizePerk, GangMinRankInvite, GangMinRankKick, GangMinRankPromote, GangMinRankUpgrade, GangMinRankMOTD) VALUES ('%s', '', 0, %i, '', 0, 0, 0, 0, 0, 0, 0, 0, %i, %i, %i, %i, %i)", GangName, GetTime() + SECONDS_IN_A_WEEK, RANK_ENFORCER, RANK_ADVISOR, RANK_MANAGER, RANK_COLEADER, RANK_MANAGER);
	SQL_AddQuery(transaction, sQuery);

	Transaction_GiveClientHonor(transaction, client, -1 * GANG_COSTCREATE);

	dbGangs.Execute(transaction, SQLTrans_GangCreated, SQLTrans_SetFailState, DP, DBPrio_High);
}

public void SQLTrans_GangCreated(Database db, any DP, int numQueries, DBResultSet[] results, any[] queryData)
{
	ResetPack(DP);

	char AuthId[35], GangName[32];
	ReadPackString(DP, AuthId, sizeof(AuthId));
	ReadPackString(DP, GangName, sizeof(GangName));

	CloseHandle(DP);

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT GangId FROM GangSystem_Gangs WHERE GangName = '%s'", GangName);

	DP = CreateDataPack();

	WritePackString(DP, AuthId);

	dbGangs.Query(SQLCB_GangCreated_FindGangId, sQuery, DP);
}

public void SQLCB_GangCreated_FindGangId(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
		SetFailState(error);

	ResetPack(DP);

	char AuthId[35];
	ReadPackString(DP, AuthId, sizeof(AuthId));

	if (SQL_GetRowCount(hndl) != 0)
	{
		SQL_FetchRow(hndl);

		int GangId = SQL_FetchIntByName(hndl, "GangId");

		FinishAddAuthIdToGang(GangId, AuthId, RANK_LEADER, AuthId, DP);
	}
	else
	{
		SetFailState("%s created a gang without possibility of being added.", AuthId);
	}
}

stock void AddClientToGang(int client, const char[] AuthIdInviter, int GangId, int GangRank = RANK_MEMBER)
{
	char AuthId[35];

	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	AddAuthIdToGang(AuthId, AuthIdInviter, GangId, GangRank);
}

stock void AddAuthIdToGang(const char[] AuthId, const char[] AuthIdInviter, int GangId, int GangRank = RANK_MEMBER)
{
	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Gangs WHERE GangId = %i", GangId);

	Handle DP = CreateDataPack();

	WritePackString(DP, AuthId);
	WritePackString(DP, AuthIdInviter);
	WritePackCell(DP, GangId);
	WritePackCell(DP, GangRank);
	dbGangs.Query(SQLCB_AuthIdAddToGang_CheckSize, sQuery, DP);
}

public void SQLCB_AuthIdAddToGang_CheckSize(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
		SetFailState(error);

	if (SQL_GetRowCount(hndl) != 0)
	{
		SQL_FetchRow(hndl);

		int Size = GANG_INITSIZE + (SQL_FetchIntByName(hndl, "GangSizePerk") * GANG_SIZEINCREASE);

		WritePackCell(DP, Size);

		ResetPack(DP);
		char AuthId[1];
		ReadPackString(DP, AuthId, 0);
		ReadPackString(DP, AuthId, 0);
		int GangId = ReadPackCell(DP);

		char sQuery[256];
		dbGangs.Format(sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Members WHERE GangId = %i", GangId);
		dbGangs.Query(SQLCB_AuthIdAddToGang_CheckMemberCount, sQuery, DP);
	}
	else
	{
		CloseHandle(DP);
		return;
	}
}

// This callback is used to get someone's member count
public void SQLCB_CheckMemberCount(Handle owner, DBResultSet hndl, char[] error, int UserId)
{
	int MemberCount = SQL_GetRowCount(hndl);

	int client = GetClientOfUserId(UserId);

	if (client == 0)
		return;

	ClientMembersCount[client] = MemberCount;
}

public void SQLCB_AuthIdAddToGang_CheckMemberCount(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	int MemberCount = SQL_GetRowCount(hndl);

	ResetPack(DP);
	char AuthId[35], AuthIdInviter[35];
	ReadPackString(DP, AuthId, sizeof(AuthId));
	ReadPackString(DP, AuthIdInviter, sizeof(AuthIdInviter));
	int GangId   = ReadPackCell(DP);
	int GangRank = ReadPackCell(DP);
	int Size     = ReadPackCell(DP);

	if (MemberCount >= Size)
	{
		CloseHandle(DP);

		PrintToChatGang(GangId, "%s \x03The gang is full!", PREFIX);
		return;
	}

	FinishAddAuthIdToGang(GangId, AuthId, GangRank, AuthIdInviter, DP);
}

// The DataPack will contain the invited auth ID as the first thing to be added.
public void FinishAddAuthIdToGang(int GangId, const char[] AuthId, int GangRank, char[] AuthIdInviter, Handle DP)
{
	char        sQuery[256];
	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT OR REPLACE INTO GangSystem_Members (GangId, AuthId, GangRank, GangInviter, LastName, GangJoinDate, LastConnect) VALUES (%i, '%s', %i, '%s', '', %i, %i)", GangId, AuthId, GangRank, AuthIdInviter, GetTime(), GetTime());
	SQL_AddQuery(transaction, sQuery);

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_modlogs (GangId, AuthId, ModAction, ModActionNumber, ModTarget, timestamp) VALUES (%i, '%s', %i, %i, '%s', %i)", GangId, AuthIdInviter, MODACTION_INVITE, GangRank, AuthId, GetTime());
	SQL_AddQuery(transaction, sQuery);

	CloseHandle(DP);
	DP = CreateDataPack();

	WritePackString(DP, AuthId);

	// You cannot use GangDonated because it doesn't apply for new members.
	dbGangs.Execute(transaction, SQLTrans_GangInvited, SQLTrans_SetFailState, DP);
}

stock void UpdateInGameAuthId(const char[] AuthId)
{
	char iAuthId[35];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		GetClientAuthId(i, AuthId_Steam2, iAuthId, sizeof(iAuthId));

		if (StrEqual(AuthId, iAuthId, true))
		{
			ClientLoadedFromDb[i] = false;

			TryRemoveGangPrefix(i);
			ResetVariables(i, true);
			LoadClientGang(i);
			break;
		}
	}
}

stock int FindClientByAuthId(const char[] AuthId)
{
	char iAuthId[35];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		GetClientAuthId(i, AuthId_Steam2, iAuthId, sizeof(iAuthId));

		if (StrEqual(AuthId, iAuthId, true))
			return i;
	}

	return 0;
}
stock void StoreClientLastInfo(int client)
{
	char AuthId[35], Name[64];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	Format(Name, sizeof(Name), "%N", client);
	StoreAuthIdLastInfo(AuthId, Name);
}

stock void StoreAuthIdLastInfo(const char[] AuthId, const char[] Name)
{
	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Members SET LastName = '%s', LastConnect = %i WHERE AuthId = '%s'", Name, GetTime(), AuthId);

	dbGangs.Query(SQLCB_Error, sQuery, 9, DBPrio_Low);
}

stock void SetAuthIdRank(const char[] AuthId, int GangId, int Rank = RANK_MEMBER, int promoter = 0)
{
	char        sQuery[256];
	Transaction transaction = SQL_CreateTransaction();

	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Members SET GangRank = %i WHERE AuthId = '%s' AND GangId = %i", Rank, AuthId, GangId);
	SQL_AddQuery(transaction, sQuery);

	char promoterAuthId[35];

	if (promoter == 0)
		promoterAuthId = "CONSOLE";

	else
		GetClientAuthId(promoter, AuthId_Steam2, promoterAuthId, sizeof(promoterAuthId));

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_modlogs (GangId, AuthId, ModAction, ModActionNumber, ModTarget, timestamp) VALUES (%i, '%s', %i, %i, '%s', %i)", GangId, promoterAuthId, MODACTION_PROMOTE, Rank, AuthId, GetTime());
	SQL_AddQuery(transaction, sQuery);

	Handle DP = CreateDataPack();

	WritePackCell(DP, GangId);

	dbGangs.Execute(transaction, SQLTrans_GangDonated, SQLTrans_SetFailState, DP);
}

stock void DonateToGang(int client, int amount)
{
	if (!IsValidPlayer(client))
		return;

	else if (!IsClientGang(client))
		return;

	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	Transaction transaction = SQL_CreateTransaction();

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET GangHonor = GangHonor + %i WHERE GangId = %i", amount, ClientGangId[client]);
	SQL_AddQuery(transaction, sQuery);

	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_Donations (GangId, AuthId, AmountDonated, timestamp) VALUES (%i, '%s', %i, %i)", ClientGangId[client], AuthId, amount, GetTime());
	SQL_AddQuery(transaction, sQuery);

	Transaction_GiveClientHonor(transaction, client, -1 * amount);

	Handle DP = CreateDataPack();

	WritePackCell(DP, ClientGangId[client]);

	dbGangs.Execute(transaction, SQLTrans_GangDonated, SQLTrans_SetFailState, DP);

	PrintToChatGang(ClientGangId[client], "%s \x05%N \x01has donated \x07%i \x01to the gang!", PREFIX, client, amount);
}

public void SQLTrans_SetFailState(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	SetFailState("Transaction at index %i failed:\n%s", failIndex, error);
}

public void SQLTrans_GangDonated(Database db, any DP, int numQueries, DBResultSet[] results, any[] queryData)
{
	ResetPack(DP);

	int GangId = ReadPackCell(DP);

	CloseHandle(DP);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		else if (ClientGangId[i] != GangId)
			continue;

		LoadClientGang(i);
	}
}

public void SQLCB_GangDonated(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	ResetPack(DP);

	int GangId = ReadPackCell(DP);

	CloseHandle(DP);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		else if (ClientGangId[i] != GangId)
			continue;

		LoadClientGang(i);
	}
}

public void SQLTrans_GangInvited(Database db, any DP, int numQueries, DBResultSet[] results, any[] queryData)
{
	ResetPack(DP);

	char AuthId[35];
	ReadPackString(DP, AuthId, sizeof(AuthId));
	CloseHandle(DP);

	UpdateInGameAuthId(AuthId);
}

stock bool IsClientGang(int client)
{
	return ClientGangId[client] > 0;
}

stock int GetClientRank(int client)
{
	return ClientRank[client];
}

// returns true if the clients are in the same gang, this will return false if the gang is in debt.
// If you pass client in both arguments, returns true if client has a gang that isn't in debt.
stock bool AreClientsSameGang(int client, int otherclient)
{
	if (!IsClientGang(client) || !IsClientGang(otherclient))
		return false;

	else if (ClientGangHonor[client] < 0 || ClientGangHonor[otherclient] < 0)
		return false;

	return ClientGangId[client] == ClientGangId[otherclient];
}

stock void PrintToChatGang(int GangId, const char[] format, any...)
{
	char buffer[291];
	VFormat(buffer, sizeof(buffer), format, 3);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (IsFakeClient(i))
			continue;

		else if (ClientGangId[i] != GangId)
			continue;

		UC_PrintToChat(i, buffer);
	}
}

stock bool IsValidPlayer(int client)
{
	if (client <= 0)
		return false;

	else if (client > MaxClients)
		return false;

	return IsClientInGame(client);
}

stock bool IsPlayer(int client)
{
	if (client <= 0)
		return false;

	else if (client > MaxClients)
		return false;

	return true;
}

stock void GetRankName(int Rank, char[] buffer, int length)
{
	switch (Rank)
	{
		case RANK_MEMBER: Format(buffer, length, "Member");
		case RANK_ENFORCER: Format(buffer, length, "Enforcer");
		case RANK_ADVISOR: Format(buffer, length, "Advisor");
		case RANK_MANAGER: Format(buffer, length, "Manager");
		case RANK_COLEADER: Format(buffer, length, "Co-Leader");
		case RANK_LEADER: Format(buffer, length, "Leader");
	}
}

stock bool CheckGangAccess(int client, int Rank)
{
	return (GetClientRank(client) >= Rank);
}

stock bool IsStringNumber(const char[] source)
{
	if (!IsCharNumeric(source[0]) && source[0] != '-')
		return false;

	for (int i = 1; i < strlen(source); i++)
	{
		if (!IsCharNumeric(source[i]))
			return false;
	}

	return true;
}

stock bool StringHasInvalidCharacters(const char[] source)
{
	for (int i = 0; i < strlen(source); i++)
	{
		if (!IsCharNumeric(source[i]) && !IsCharAlpha(source[i]) && source[i] != '-' && source[i] != '_' && source[i] != ' ')
			return true;
	}

	return false;
}

stock int GetEntityHealth(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iHealth");
}

stock int GetEntityMaxHealth(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iMaxHealth");
}

stock void SetEntityMaxHealth(int entity, int amount)
{
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", amount);
}

stock int GetUpgradeCost(int CurrentPerkLevel, int PerkCost)
{
	return (CurrentPerkLevel + 1) * PerkCost;
}

public void JailBreakDays_OnDayStatus(bool DayActive)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		if (DayActive && AreClientsSameGang(i, i))
		{
			CreateGlow(i);
		}
		else
			TryDestroyGlow(i);
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Gangs_HasGang", Native_HasGang);
	CreateNative("Gangs_AreClientsSameGang", Native_AreClientsSameGang);
	CreateNative("Gangs_GetClientGangId", Native_GetClientGangId);
	CreateNative("Gangs_GetClientGlowColorSlot", Native_GetClientGlowColorSlot);
	CreateNative("Gangs_GetClientGangName", Native_GetClientGangName);
	CreateNative("Gangs_GiveGangCredits", Native_GiveGangHonor);
	CreateNative("Gangs_GiveClientCredits", Native_GiveClientHonor);
	CreateNative("Gangs_GiveGangHonor", Native_GiveGangHonor);
	CreateNative("Gangs_GiveClientHonor", Native_GiveClientHonor);
	CreateNative("Gangs_AddClientDonations", Native_AddClientDonations);
	CreateNative("Gangs_PrintToChatGang", Native_PrintToChatGang);
	CreateNative("Gangs_TryDestroyGlow", Native_TryDestroyGlow);
	CreateNative("Gangs_GetFFDamageDecrease", Native_GetFFDamageDecrease);
	CreateNative("Gangs_GetCooldownPercent", Native_GetCooldownPercent);

	RegPluginLibrary("JB Gangs");
	
	return APLRes_Success;
}

public int Native_HasGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return IsClientGang(client);
}

public int Native_AreClientsSameGang(Handle plugin, int numParams)
{
	int client      = GetNativeCell(1);
	int otherClient = GetNativeCell(2);

	return AreClientsSameGang(client, otherClient);
}

public int Native_GetClientGangId(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (ClientGangHonor[client] < 0)
		return GANGID_NULL;

	return ClientGangId[client];
}

// This is the slot of the glow the client takes. It is rarely useful and gets invalidated when an entire gang leaves the server, and created when the first member of a gang joins.
public int Native_GetClientGlowColorSlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (ClientGangHonor[client] < 0)
		return -1;

	return ClientGlowColorSlot[client];
}

public int Native_GetClientGangName(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int len    = GetNativeCell(3);
	if (!IsClientGang(client))
	{
		return 0;
	}

	SetNativeString(2, ClientGang[client], len, false);

	return 0;
}

public int Native_PrintToChatGang(Handle plugin, int numParams)
{
	int  GangId = GetNativeCell(1);
	char buffer[192];

	FormatNativeString(0, 2, 3, sizeof(buffer), _, buffer);

	PrintToChatGang(GangId, buffer);

	return 0;
}

public int Native_TryDestroyGlow(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	TryDestroyGlow(client);

	return 0;
}

public int Native_GiveClientHonor(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int amount = GetNativeCell(2);

	GiveClientHonor(client, amount);

	return 0;
}

public int Native_AddClientDonations(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int amount = GetNativeCell(2);

	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "INSERT INTO GangSystem_Donations (GangId, AuthId, AmountDonated, timestamp) VALUES (%i, '%s', %i, %i)", ClientGangId[client], AuthId, amount, GetTime());

	Handle DP = CreateDataPack();

	WritePackCell(DP, ClientGangId[client]);

	dbGangs.Query(SQLCB_GangDonated, sQuery, DP);

	return 0;
}

public int Native_GiveGangHonor(Handle plugin, int numParams)
{
	int GangId = GetNativeCell(1);

	int amount = GetNativeCell(2);

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Gangs SET GangHonor = GangHonor + %i WHERE GangId = %i", amount, GangId);

	Handle DP = CreateDataPack();

	WritePackCell(DP, GangId);

	dbGangs.Query(SQLCB_GiveGangHonor, sQuery, DP);

	return 0;
}

public any Native_GetFFDamageDecrease(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return float(ClientFriendlyFirePerk[client] * GANG_FRIENDLYFIREINCREASE) / 100.0;
}

public any Native_GetCooldownPercent(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return (ClientCooldownPerk[client] * GANG_COOLDOWNINCREASE) / 100.0;
}

public void SQLCB_GiveGangHonor(Handle owner, DBResultSet hndl, char[] error, Handle DP)
{
	if (hndl == null)
	{
		SetFailState(error);
	}

	ResetPack(DP);

	int GangId = ReadPackCell(DP);

	CloseHandle(DP);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		else if (ClientGangId[i] != GangId)
			continue;

		LoadClientGang(i);
	}
}

stock int GetPlayerCount()
{
	int Count, Team;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidPlayer(i))
			continue;

		Team = GetClientTeam(i);
		if (Team != CS_TEAM_CT && Team != CS_TEAM_T)
			continue;

		Count++;
	}

	return Count;
}

stock void LogGangAction(const char[] format, any...)
{
	char buffer[291], Path[256];
	VFormat(buffer, sizeof(buffer), format, 2);

	BuildPath(Path_SM, Path, sizeof(Path), "logs/JailBreakGangs.txt");
	LogToFile(Path, buffer);
}

stock bool IsKnifeClass(const char[] classname)
{
	if (StrContains(classname, "knife") != -1 || StrContains(classname, "bayonet") > -1)
		return true;

	return false;
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

stock void GiveClientHonor(int client, int amount)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Honor SET Honor = Honor + %i WHERE AuthId = '%s'", amount, AuthId);

	ClientHonor[client] += amount;

	dbGangs.Query(SQLCB_Error, sQuery, 12);
}

stock void Transaction_GiveClientHonor(Transaction txn, int client, int amount)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));

	char sQuery[256];
	dbGangs.Format(sQuery, sizeof(sQuery), "UPDATE GangSystem_Honor SET Honor = Honor + %i WHERE AuthId = '%s'", amount, AuthId);

	SQL_AddQuery(txn, sQuery);

	ClientHonor[client] += amount;
}

stock void FindDonationsForGang(int GangId)
{
	char sQuery[256];

	SQL_FormatQuery(dbGangs, sQuery, sizeof(sQuery), "SELECT * FROM GangSystem_Donations WHERE GangId = %i ORDER BY AuthId", GangId);

	dbGangs.Query(SQLCB_FindDonations, sQuery);
}

public void SQLCB_FindDonations(Handle owner, Handle hndl, char[] error, any data)
{
	if (hndl == null)
	{
		LogError(error);

		return;
	}

	if (SQL_GetRowCount(hndl) != 0)
	{
		DBResultSet query = view_as<DBResultSet>(hndl);

		int amount;
		int amountWeek;

		char LastAuthId[35];

		char AuthId[35];

		while (SQL_FetchRow(hndl))
		{
			SQL_FetchStringByName(query, "AuthId", AuthId, sizeof(AuthId));

			if (LastAuthId[0] == EOS)
				strcopy(LastAuthId, sizeof(LastAuthId), AuthId);

			if (!StrEqual(AuthId, LastAuthId))
			{
				SetTrieValue(Trie_Donated, LastAuthId, amount);
				SetTrieValue(Trie_DonatedWeek, LastAuthId, amountWeek);

				amount     = 0;
				amountWeek = 0;
			}

			strcopy(LastAuthId, sizeof(LastAuthId), AuthId);

			int donated = SQL_FetchIntByName(query, "AmountDonated");

			amount += donated;

			if (RoundToFloor(float(GetTime()) / 604800.0) == RoundToFloor(float(SQL_FetchIntByName(query, "timestamp")) / 604800.0))
				amountWeek += donated;
		}

		SetTrieValue(Trie_Donated, LastAuthId, amount);
		SetTrieValue(Trie_DonatedWeek, LastAuthId, amountWeek);
	}
}

stock void AddCommas(int value, char[] seperator, char[] buffer, int bufferLen)
{
	int divisor = 1000;
	while (value >= 1000 || value <= -1000)
	{
		int offcut = value % divisor;
		value      = RoundToFloor(float(value) / float(divisor));
		Format(buffer, bufferLen, "%c%03.d%s", seperator, offcut, buffer);
	}
	Format(buffer, bufferLen, "%d%s", value, buffer);
}

stock void SetClientNameHidden(int client, const char[] Name)
{
	HookUserMessage(GetUserMessageId("SayText2"), hook_alwaysBlock, true);

	SetClientName(client, Name);

	UnhookUserMessage(GetUserMessageId("SayText2"), hook_alwaysBlock, true);
}

public Action hook_alwaysBlock(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	return Plugin_Handled;
}

stock void TryRemoveGangPrefix(int client)
{
	char Name[64];

	GetClientName(client, Name, sizeof(Name));

	if (ClientPrefix[client][0] != EOS)
	{
		if (StrContains(Name, ClientPrefix[client]) == 0)    // Client's name starts with the prefix.
		{
			ReplaceStringEx(Name, sizeof(Name), ClientPrefix[client], "");

			SetClientNameHidden(client, Name);
		}
	}
}