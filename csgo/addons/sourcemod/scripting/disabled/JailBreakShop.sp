/* put the line below after all of the includes!
#pragma newdecls required
*/


#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <smartdm>

#define STANDALONE_BUILD 1

#define SECONDS_IN_A_DAY 86400

#define STORE_MAX_ITEMS 32

enum struct Pet
{
	char name[64]
	char model[PLATFORM_MAX_PATH];
	char run[64];
	char idle[64];
	int price;
	float fPosition[3];
	float fAngles[3];
}

Pet g_ePets[STORE_MAX_ITEMS];
int g_iPets = 0;
int g_unClientPet[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE, ...};
int g_unLastAnimation[MAXPLAYERS+1]={-1,...};

int ClientPet[MAXPLAYERS+1], ClientSelectedPet[MAXPLAYERS+1];

#define PLUGIN_VERSION "1.0"

#define PREFIX " \x04[WePlay #Shop]\x01"

public Plugin myinfo = 
{
	name = "JailBreak Shop",
	author = "Eyal282",
	description = "A shop plugin for JailBreak with Knives",
	version = PLUGIN_VERSION,
	url = ""
}

native void FPVMI_AddViewModelToClient(int client, char[] weapon, int weaponview_index=-1);
native void FPVMI_RemoveViewModelToClient(int client, char[] weapon);

/**

*	@note			This forward is called when SQLite VIP API has connected to it's database.

*/

forward void SQLiteVIPAPI_OnDatabaseConnected();

/**

* @param client		Client index that was authenticated.
* @param VIPLevel	VIP Level of the client, or 0 if the player is not VIP.
 
* @note				This forward is called for non-vip players as well as VIPs.
* @note				This forward can be called more than once in a client's lifetime, assuming his VIP Level has changed.
* @noreturn		
*/

forward void SQLiteVIPAPI_OnClientAuthorized(client, &VIPLevel);

/**

* @param client		Client index that was authenticated.
* @param VIPLevel	VIP Level of the client, or 0 if the player is not VIP.
 
* @note				This forward is called for non-vip players as well as VIPs.
* @note				This forward can be called more than once in a client's lifetime, assuming his VIP Level has changed.
* @noreturn		
*/

forward void SQLiteVIPAPI_OnClientAuthorizedPost(client, VIPLevel);

/**

* @param client			Client index that changed his preference.
* @param FeatureSerial	Feature serial whose setting was changed.
* @param SettingValue	The new setting of the feature the client has set.
 
* @note					This forward is called whenever a client changes his feature preference.
* @note					This can be easily spammed by a client, and therefore should be noted.
* @noreturn		
*/

forward void SQLiteVIPAPI_OnClientFeatureChanged(client, FeatureSerial, SettingValue);
/**

* @return			true if SQLite VIP API has connected to the database already, false otherwise.

*/

native bool SQLiteVIPAPI_IsDatabaseConnected();

/**

* @param client		Client index to check.
 
* @note				This forward is called for non-vip players as well as VIPs.
* @note				With the proper cvars, this isn't guaranteed to be called once, given the VIP Level of the VIP has decreased due to expiration of a better level / all of the levels.

* @return			VIP Level of the client, or 0 if the client is not a VIP. returns -1 if client was yet to be authenticated. If an error is thrown, returns -2 instead.

* @error			Client index is not in-game.
*/

native int SQLiteVIPAPI_GetClientVIPLevel(client);

/**
* @param FeatureName	The name of the feature to be displayed in !settings.
* @param VIPLevelList	An arrayList containing each setting's VIP Level requirement
* @param NameList		An arrayList containing each setting's Name
* @param AlreadyExisted	Optional param to determine if the feature's name has already existed and therefore no feature was added. 

* @note					Only higher settings should be allowed to have higher VIP Levels than their lower ones.
* @note					You can execute this on "OnAllPluginsLoaded" even if the database is broken it'll still cache it.

* @return				Feature serial ID on success, 
* @error				List of setting variations exceed 25 ( it's too much anyways  )
*/

native int SQLiteVIPAPI_AddFeature(const char FeatureName[64], Handle VIPLevelList, Handle NameList, bool &AlreadyExisted=false);

/**

* @param client			Client index to check.
* @param FeatureSerial	Feature serial whose setting to find.

* @note 				Reduces to highest allowed value for the client if he lost a VIP status.
* @note					Returns -1 if the feature is entirely out of the client's league VIP wise. If an error is thrown, returns -2 instead.

* @return				Client's VIP setting for the feature given by the serial.

* @error				Client index is not in-game.

*/

native int SQLiteVIPAPI_GetClientVIPFeature(client, FeatureSerial);

enum struct enKnifeStats
{
	int KnifePrice;
	char KnifeName[64];
	char KnifeModel[PLATFORM_MAX_PATH];
	int KnifeHP; // And Damage
	int KnifeArmor;
	float KnifeSlagChance; // Percents up to 100.0%
}


ArrayList Array_KnifeStats;
char KnifePath[] = "configs/JailBreakShop/knives.cfg";
char PetsPath[] = "configs/JailBreakShop/pets.cfg";

// Client Variables

bool ClientLoadedFromDB[MAXPLAYERS+1];

int ClientCash[MAXPLAYERS+1], ClientKnife[MAXPLAYERS+1], ClientSelectedKnife[MAXPLAYERS+1];

bool ClientDoubleCash[MAXPLAYERS+1], Client50ChanceGamble[MAXPLAYERS+1], ClientAutoBunnyHop[MAXPLAYERS+1], ClientSelectedAutoBunnyHop[MAXPLAYERS+1];

int GambleCooldown[MAXPLAYERS+1];

int LastItem[MAXPLAYERS+1];

Handle hTimer_Slag[MAXPLAYERS+1] = INVALID_HANDLE;
Handle hTimer_PlayCash[MAXPLAYERS+1] = INVALID_HANDLE;

Handle dbShop = INVALID_HANDLE;

Handle Trie_ModelIndex = INVALID_HANDLE;

Handle hcv_AutoBunnyHopping = INVALID_HANDLE;

native int JailBreakShop_GetClientCash(int client);

native int JailBreakShop_GiveClientCash(int client, int amount, bool includeMultipliers);

native void JailBreakShop_SetClientCash(int client, int amount);

public APLRes AskPluginLoad2(Handle myself, bool bLate, char[] Error, int errorLength)
{
	CreateNative("JailBreakShop_GetClientCash", Native_GetClientCash);
	CreateNative("JailBreakShop_SetClientCash", Native_SetClientCash);
	CreateNative("JailBreakShop_GiveClientCash", Native_GiveClientCash);
	CreateNative("JailBreakShop_GiveClientDoubleCash", Native_GiveClientDoubleCash);
	CreateNative("JailBreakShop_GiveClient50ChanceGamble", Native_GiveClient50ChanceGamble);
}

public int Native_GetClientCash(Handle plugin, int params)
{
	int client = GetNativeCell(1);
	
	return ClientCash[client];
}

public int Native_SetClientCash(Handle plugin, int params)
{
	int client = GetNativeCell(1);
	int amount = GetNativeCell(2);
	
	SetClientCash(client, amount);
}

public int Native_GiveClientCash(Handle plugin, int params)
{
	int client = GetNativeCell(1);
	int amount = GetNativeCell(2);
	
	bool includeMultipliers = view_as<bool>(GetNativeCell(3));
	
	return GiveClientCash(client, amount, includeMultipliers);
}

public int Native_GiveClientDoubleCash(Handle plugin, int params)
{
	int client = GetNativeCell(1);
	int days = GetNativeCell(2);
	
	GiveClientDoubleCash(client, days);
}

public int Native_GiveClient50ChanceGamble(Handle plugin, int params)
{
	int client = GetNativeCell(1);
	
	int days = GetNativeCell(2);
	
	GiveClient50ChanceGamble(client, days);
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	RegConsoleCmd("sm_c", Command_Cash);
	RegAdminCmd("sm_givecash", Command_GiveCash, ADMFLAG_ROOT);
	
	RegConsoleCmd("sm_cash", Command_Cash);
	RegConsoleCmd("sm_shop", Command_Shop);
	RegConsoleCmd("sm_knife", Command_Knife);
	RegConsoleCmd("sm_pet", Command_Pet);
	RegConsoleCmd("sm_pets", Command_Pet);
	RegConsoleCmd("sm_gamble", Command_Gamble);
	RegConsoleCmd("sm_g", Command_Gamble);
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);

	Trie_ModelIndex = CreateTrie();
	
	Array_KnifeStats = new ArrayList(sizeof(enKnifeStats));

	HookEvent("player_spawn", Pets_PlayerSpawn);
	HookEvent("player_death", Pets_PlayerDeath);
	HookEvent("player_team", Pets_PlayerTeam);
	
	hcv_AutoBunnyHopping = FindConVar("sv_autobunnyhopping");
	
	if(hcv_AutoBunnyHopping != INVALID_HANDLE)
	{
		new flags = GetConVarFlags(hcv_AutoBunnyHopping);

		flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
		
		SetConVarFlags(hcv_AutoBunnyHopping, flags);
	}
	LoadKnivesFromConfig();
	LoadPetsFromConfig();
	
	ConnectToDatabase();
}

public void OnMapStart()
{
	if(Array_KnifeStats.Length > 0)
	{
		for(int i=0;i < Array_KnifeStats.Length;i++)
		{
			enKnifeStats ArrayKnifeInfo;
			
			Array_KnifeStats.GetArray(i, ArrayKnifeInfo);
			
			if(ArrayKnifeInfo.KnifeModel[0] != EOS)
			{
				int modelIndex = PrecacheModel(ArrayKnifeInfo.KnifeModel, true);
				
				Downloader_AddFileToDownloadsTable(ArrayKnifeInfo.KnifeModel);
				
				SetTrieValue(Trie_ModelIndex, ArrayKnifeInfo.KnifeModel, modelIndex);
			}
			else
				SetTrieValue(Trie_ModelIndex, ArrayKnifeInfo.KnifeModel, -1);
		}
	}
	for(int i=0;i < sizeof(hTimer_Slag);i++)
	{
		hTimer_Slag[i] = INVALID_HANDLE;
		hTimer_PlayCash[i] = INVALID_HANDLE;
	}
	
	if(g_iPets > 0)
	{
		for(int i=0;i<g_iPets;++i)
		{
			if(g_ePets[i].model[0] != EOS)
			{
				PrecacheModel(g_ePets[i].model, true);
				Downloader_AddFileToDownloadsTable(g_ePets[i].model);
			}
		}
	}
}

void LoadKnivesFromConfig()
{
	char FullPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, FullPath, sizeof(FullPath), KnifePath, sizeof(KnifePath));
	
	if(!FileExists(FullPath))
		UC_CreateEmptyFile(FullPath);
		
	KeyValues kv = new KeyValues("JailBreak Shop");
	kv.ImportFromFile(FullPath);
	
	kv.SavePosition();
	
	kv.JumpToKey("Knives");
	
	if(!kv.GotoFirstSubKey())
		return;
	
	enKnifeStats ArrayToPush;

	do
	{
		kv.GetSectionName(ArrayToPush.KnifeName, sizeof(enKnifeStats::KnifeName));
		
		kv.GetString("model", ArrayToPush.KnifeModel, sizeof(enKnifeStats::KnifeModel));
		ArrayToPush.KnifePrice = kv.GetNum("price", 0);
		ArrayToPush.KnifeHP = kv.GetNum("BonusHP&Damage", 0);
		ArrayToPush.KnifeArmor = kv.GetNum("BonusArmor", 0);
		ArrayToPush.KnifeSlagChance = kv.GetFloat("SlagChance", 0.0);
		
		if(ArrayToPush.KnifeModel[0] != EOS && !FileExists(ArrayToPush.KnifeModel, true))
		{
			SetFailState("Tried to add non-existent knife model \"%s\"", ArrayToPush.KnifeModel);
			
			return;
		}
			
		PushArrayArray(Array_KnifeStats, ArrayToPush);
	}
	while(kv.GotoNextKey());
	
	delete kv;
}

void LoadPetsFromConfig()
{
	char FullPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, FullPath, sizeof(FullPath), PetsPath, sizeof(PetsPath));
	
	if(!FileExists(FullPath))
		UC_CreateEmptyFile(FullPath);
		
	KeyValues kv = new KeyValues("JailBreak Shop");
	kv.ImportFromFile(FullPath);
	
	kv.SavePosition();
	
	kv.JumpToKey("Pets");
	
	if(!kv.GotoFirstSubKey())
		return;

	do
	{
		decl Float:m_fTemp[3];
		KvGetSectionName(kv, g_ePets[g_iPets].name, 64);
		KvGetString(kv, "model", g_ePets[g_iPets].model, PLATFORM_MAX_PATH);
		KvGetString(kv, "idle", g_ePets[g_iPets].idle, 64);
		KvGetString(kv, "run", g_ePets[g_iPets].run, 64);
		g_ePets[g_iPets].price = KvGetNum(kv, "price");
		KvGetVector(kv, "position", m_fTemp);
		g_ePets[g_iPets].fPosition=m_fTemp;
		KvGetVector(kv, "angles", m_fTemp);
		g_ePets[g_iPets].fAngles=m_fTemp;

		if(g_ePets[g_iPets].model[0] != EOS && !(FileExists(g_ePets[g_iPets].model, true)))
		{
			SetFailState("Tried to add non-existent pet model \"%s\"", g_ePets[g_iPets].model);
			
			return;
		}
		++g_iPets;
	}
	while(kv.GotoNextKey());
	
	delete kv;
}

	/*
	Store_SetDataIndex(itemid, g_iPets);
	
	decl Float:m_fTemp[3];
	KvGetString(kv, "model", g_ePets[g_iPets][model], PLATFORM_MAX_PATH);
	KvGetString(kv, "idle", g_ePets[g_iPets][idle], 64);
	KvGetString(kv, "run", g_ePets[g_iPets][run], 64);
	KvGetVector(kv, "position", m_fTemp);
	g_ePets[g_iPets][fPosition]=m_fTemp;
	KvGetVector(kv, "angles", m_fTemp);
	g_ePets[g_iPets][fAngles]=m_fTemp;

	if(!(FileExists(g_ePets[g_iPets][model], true)))
		return false;
	
	++g_iPets;
	return true;
	*/
void ConnectToDatabase()
{
	char Error[256];
	if((dbShop = SQLite_UseDatabase("JailBreakShop", Error, sizeof(Error))) == INVALID_HANDLE)
		SetFailState(Error);

	else
	{
		SQL_TQuery(dbShop, SQLCB_Error, "CREATE TABLE IF NOT EXISTS Shop_players (AuthId VARCHAR(35) NOT NULL UNIQUE, Cash INT(11) NOT NULL, Knife INT(11) NOT NULL, SelectedKnife INT(11) NOT NULL)", _, DBPrio_High); 
		SQL_TQuery(dbShop, SQLCB_Error, "CREATE TABLE IF NOT EXISTS Shop_playersPerks (AuthId VARCHAR(35) NOT NULL UNIQUE, DoubleCashExpire INT(11) NOT NULL, FiftyChanceGambleExpire INT(11) NOT NULL)", _, DBPrio_High); 
		
		SQL_TQuery(dbShop, SQLCB_ErrorIgnore, "ALTER TABLE Shop_players ADD COLUMN Pet INT(11) NOT NULL DEFAULT 0", _, DBPrio_High);
		SQL_TQuery(dbShop, SQLCB_ErrorIgnore, "ALTER TABLE Shop_players ADD COLUMN SelectedPet INT(11) NOT NULL DEFAULT 0", _, DBPrio_High);
		SQL_TQuery(dbShop, SQLCB_ErrorIgnore, "ALTER TABLE Shop_playersPerks ADD COLUMN AutoBunnyHop INT(11) NOT NULL DEFAULT 0", _, DBPrio_High);
		SQL_TQuery(dbShop, SQLCB_ErrorIgnore, "ALTER TABLE Shop_playersPerks ADD COLUMN SelectedAutoBunnyHop INT(11) NOT NULL DEFAULT 0", _, DBPrio_High);
		
		for(int i=1;i <= MaxClients;i++)
		{
			if(!IsClientInGame(i))
				continue;
				
			else if(!IsClientAuthorized(i))
				continue;
				
			ClientLoadedFromDB[i] = false;
			
			OnClientPostAdminCheck(i);
		}
	}
}

public void SQLCB_Error(Handle db, Handle hndl, const char[] Error, int Data) 
{ 
	/* If something fucked up. */ 
	if (hndl == null) 
		ThrowError(Error); 
}

public void SQLCB_ErrorIgnore(Handle db, Handle hndl, const char[] Error, int Data) 
{ 
}
public void OnClientConnected(int client)
{
	ClientLoadedFromDB[client] = false;
	
	ClientDoubleCash[client] = false;
	Client50ChanceGamble[client] = false;
	
	ClientSelectedPet[client] = -1;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SDKEvent_OnTakeDamage);

	SDKHook(client, SDKHook_PreThinkPost, SDKEvent_PreThinkPost);
	
	if(hTimer_PlayCash[client] == INVALID_HANDLE)
		hTimer_PlayCash[client] = CreateTimer(300.0, Timer_GetPlayCash, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public SDKEvent_PreThinkPost(client)
{
	SetConVarBool(hcv_AutoBunnyHopping, ClientSelectedAutoBunnyHop[client]);
}

public Action:Timer_GetPlayCash(Handle:hTimer, UserId)
{
	new client = GetClientOfUserId(UserId);
	
	if(client == 0)
		return;
		
	new amount = 7;
		
	amount = GiveClientCash(client, amount, true);
	
	// BAR COLOR
	PrintToChat(client, " %s \x05You \x01got \x07%i \x01cash for playing for \x075 \x01minutes on the server.", PREFIX, amount);
	
}
public void OnClientPostAdminCheck(int client)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "SELECT * FROM Shop_players WHERE AuthId = '%s'", AuthId);
	SQL_TQuery(dbShop, SQLCB_LoadPlayerCash, sQuery, GetClientUserId(client));
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "SELECT * FROM Shop_playersPerks WHERE AuthId = '%s'", AuthId);
	SQL_TQuery(dbShop, SQLCB_LoadPlayerPerks, sQuery, GetClientUserId(client));
}

public void OnClientDisconnect(int client)
{
	if(hTimer_Slag[client] != INVALID_HANDLE)
	{
		CloseHandle(hTimer_Slag[client]);
		
		hTimer_Slag[client] = INVALID_HANDLE;
	}
	
	if(hTimer_PlayCash[client] != INVALID_HANDLE)
	{
		CloseHandle(hTimer_PlayCash[client]);
		
		hTimer_PlayCash[client] = INVALID_HANDLE;
	}
	
	ClientSelectedPet[client] = -1;
}

public void SQLCB_LoadPlayerCash(Handle owner, Handle hndl, char[] error, any data)
{
	if(hndl == null)
	{
		SetFailState(error);
	}

	int client = GetClientOfUserId(data);
	
	if(client == 0)
		return;

	if(SQL_GetRowCount(hndl) != 0)
	{
		SQL_FetchRow(hndl);
		
		ClientCash[client] = SQL_FetchInt(hndl, 1);
		ClientKnife[client] = SQL_FetchInt(hndl, 2);
		ClientSelectedKnife[client] = SQL_FetchInt(hndl, 3);
		ClientPet[client] = SQL_FetchInt(hndl, 4);
		ClientSelectedPet[client] = SQL_FetchInt(hndl, 5);
		
		ClientLoadedFromDB[client] = true;
	}
	else
	{
		char AuthId[35];
		GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
		
		int defaultCash = 0;
		ClientCash[client] = defaultCash;
		ClientKnife[client] = 0;
		ClientSelectedKnife[client] = 0;
		
		ClientLoadedFromDB[client] = true;
		
		char sQuery[512];
		
		SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "INSERT INTO Shop_players (AuthId, Cash, Knife, SelectedKnife, Pet, SelectedPet) VALUES ('%s', %i, 0, 0, 0, 0)", AuthId, defaultCash);
		SQL_TQuery(dbShop, SQLCB_Error, sQuery, DBPrio_High);
	}
	
	OnClientPutInServer(client);
}


public void SQLCB_LoadPlayerPerks(Handle owner, Handle hndl, char[] error, any data)
{
	if(hndl == null)
	{
		SetFailState(error);
	}

	int client = GetClientOfUserId(data);
	
	if(client == 0)
		return;

	if(SQL_GetRowCount(hndl) != 0)
	{
		SQL_FetchRow(hndl);
		
		ClientDoubleCash[client] = SQL_FetchInt(hndl, 1) > GetTime() ? true : false;
		Client50ChanceGamble[client] = SQL_FetchInt(hndl, 2) > GetTime() ? true : false;
		ClientAutoBunnyHop[client] = view_as<bool>(SQL_FetchInt(hndl, 3));
		
		SetClientSelectedAutoBunnyHop(client, view_as<bool>(SQL_FetchInt(hndl, 4))); 
		
		if(SQLiteVIPAPI_GetClientVIPLevel(client) >= 3)
		{
			ClientDoubleCash[client] = true;
			Client50ChanceGamble[client] = true;
		}
	}
	else
	{
		char AuthId[35];
		GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
		
		char sQuery[512];
		
		SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "INSERT INTO Shop_playersPerks (AuthId, DoubleCashExpire, FiftyChanceGambleExpire) VALUES ('%s', 0, 0)", AuthId);
		
		SQL_TQuery(dbShop, SQLCB_Error, sQuery, DBPrio_High);
	}
}

public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	RequestFrame(Frame_PlayerSpawn, client);
	
	UpdateKnifeModel(client);
}

public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
	
	if(IsEntityPlayer(attacker) && attacker != victim && (GetClientTeam(victim) == CS_TEAM_CT || GetAliveTeamCount(CS_TEAM_T) == 0))
	{
		int amount = GiveClientCash(attacker, 7, true);
		
		// BAR COLOR
		PrintToChatAll("%s \x07%N \x01killed \x07%N \x01and got \x07%i \x01cash",PREFIX , attacker, victim, amount);
	}
}

public Action SDKEvent_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	if(!IsEntityPlayer(attacker))
		return Plugin_Continue;
	
	else if(damage <= 0.0)
		return Plugin_Continue;
	int activeWeapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	
	if(activeWeapon == -1)
		return Plugin_Continue;
		
	char Classname[64];
	GetEdictClassname(activeWeapon, Classname, sizeof(Classname));
	
	if(strncmp(Classname, "weapon_knife", 12) != 0)
		return Plugin_Continue;
	
	else if(!(damagetype & DMG_SLASH) && !(damagetype & DMG_CLUB))
		return Plugin_Continue;
	
	enKnifeStats ArrayKnifeInfo;
		
	Array_KnifeStats.GetArray(ClientSelectedKnife[attacker], ArrayKnifeInfo);
	
	damage *= ((float(ArrayKnifeInfo.KnifeHP) + 100.0) / 100.0);
	
	float RNG = GetRandomFloat(0.0, 100.0);
	
	if(RNG < ArrayKnifeInfo.KnifeSlagChance)
	{
		SetEntityMoveType(victim, MOVETYPE_NONE);
		
		if(hTimer_Slag[victim] != INVALID_HANDLE)
		{
			CloseHandle(hTimer_Slag[victim]);
			
			hTimer_Slag[victim] = INVALID_HANDLE;
		}
	
		hTimer_Slag[victim] = CreateTimer(1.5, Timer_Unslag, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
		
		// BAR COLOR 
		
		PrintToChatAll(" \x04%N \x01was slagged by \x07%N! \x01( \x07%.1f%% \x01slag chance )", victim, attacker, ArrayKnifeInfo.KnifeSlagChance);
		
		PrintCenterText(victim, " \x04You \x01have been slagged by \x07%N \x01for \x041.5 \x01seconds!", attacker);
	}
	
	return Plugin_Changed;
}

public Action Timer_Unslag(Handle hTimer, int UserId)
{
	int victim = GetClientOfUserId(UserId);
	
	if(victim == 0)
		return;
	
	hTimer_Slag[victim] = INVALID_HANDLE;
	
	SetEntityMoveType(victim, MOVETYPE_WALK);
	
}

public void Frame_PlayerSpawn(int client)
{
	if(!IsClientInGame(client)) // No need for User ID, because in a single frame only disconnect can occur.
		return;
		
	else if(!IsPlayerAlive(client))
		return;
		
	enKnifeStats ArrayKnifeInfo;
		
	Array_KnifeStats.GetArray(ClientSelectedKnife[client], ArrayKnifeInfo);
	
	SetEntityHealth(client, GetEntityHealth(client) + ArrayKnifeInfo.KnifeHP);
	SetClientArmor(client, GetClientArmor(client) + ArrayKnifeInfo.KnifeArmor);
}

public Action Command_Cash(int client, int args)
{
	if(!ClientLoadedFromDB[client])
	{
		ReplyToCommand(client, "Couldn't load you from the database. Try again soon.");
		return Plugin_Handled;
	}
	
	PrintToChat(client, "%s \x05You \x01have \x07%i \x01cash.", PREFIX, ClientCash[client]);
	
	for(int i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
		
		if(i == client)
			continue;
		
		PrintToChat(i, "%s \x05%N \x01have \x07%i \x01cash.", PREFIX, client, ClientCash[client]);
	}
	
	return Plugin_Handled;
}

public Action Command_GiveCash(int client, int args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "Usage: sm_givecash <#userid|name> <amount>");
		return Plugin_Handled;
	}
	
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	if(!StrEqual(AuthId, "STEAM_1:0:49508144") && !StrEqual(AuthId, "STEAM_1:1:110581296"))
	{
		ReplyToCommand(client, "אתה לא בר ולא אייל");
		return Plugin_Handled;
	}
	
	char TargetArg[50];
	GetCmdArg(1, TargetArg, sizeof(TargetArg));
	
	char sValue[11];
	GetCmdArg(2, sValue, sizeof(sValue));
	
	int amount = StringToInt(sValue);
	
	char target_name[MAX_TARGET_LENGTH];
	int[] target_list = new int[MaxClients+1];
	int target_count;
	
	bool tn_is_ml;
	
	target_count = ProcessTargetString(
					TargetArg,
					client,
					target_list,
					MaxClients,
					0,
					target_name,
					sizeof(target_name),
					tn_is_ml);

	if(target_count <= COMMAND_TARGET_NONE) 	// If we don't have dead players
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for(int i=0;i < target_count;i++)
	{
		int target = target_list[i];
			
		if(!ClientLoadedFromDB[target])
		{
			PrintToChat(client, " \x04%N \x01wasn't loaded from the database yet, and couldn't be given his \x07cash.", target);
			continue;
		}
		
		GiveClientCash(target, amount);
	}
	
	return Plugin_Handled;
}

public Action Command_Shop(int client, int args)
{
	if(!ClientLoadedFromDB[client])
	{
		ReplyToCommand(client, "Couldn't load you from the database. Try again soon.");
		return Plugin_Handled;
	}
	
	Handle hMenu = CreateMenu(Shop_MenuHandler);
	
	AddMenuItem(hMenu, "", "Knife Shop\n");
	AddMenuItem(hMenu, "", "Pet Shop");
	AddMenuItem(hMenu, "", "Auto Bunny Hop");
	
	if(CheckCommandAccess(client, "sm_rcon", ADMFLAG_ROOT, true))
		AddMenuItem(hMenu, "", "[Owner] Reset Player");
	
	SetMenuTitle(hMenu, "[WePlay] JailBreak Shop | Cash: %i", ClientCash[client], ClientDoubleCash[client] ? "Enabled" : "Disabled", Client50ChanceGamble[client] ? "Enabled" : "Disabled"); // \nDouble Cash: %s\n50%% Gamble: %s
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}


public int Shop_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{
		switch(item)
		{
			case 0: Command_Knife(client, 0);
			case 1: Command_Pet(client, 0);
			case 2: Command_AutoBunnyHop(client, 0);
			case 3:
			{
				if(!CheckCommandAccess(client, "sm_rcon", ADMFLAG_ROOT, true))
					return;
			
				ShowResetPlayerMenu(client);
			}
		}
	}
}

public void ShowResetPlayerMenu(int client)
{
	Handle hMenu = CreateMenu(ResetPlayer_MenuHandler);
	
	for(int i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		char sUserId[11], Name[64];
		
		IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
		GetClientName(i, Name, sizeof(Name));
		
		AddMenuItem(hMenu, sUserId, Name);
	}
	
	SetMenuTitle(hMenu, "[WePlay] JailBreak Shop\nReset player data");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}


public int ResetPlayer_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{
		char sUserId[11], Name[64];
		
		int dummy_value;
		
		GetMenuItem(hMenu, item, sUserId, sizeof(sUserId), dummy_value, Name, sizeof(Name));
		
		int target = GetClientOfUserId(StringToInt(sUserId));
		
		if(target == 0)
		{
			PrintToChat(client, " \x01The target player has \x07left \x01the server.");
			return;
		}
		
		ShowConfirmResetPlayerMenu(client, sUserId, Name);
	}
}

public void ShowConfirmResetPlayerMenu(int client, char[] sUserId, char[] Name)
{
	Handle hMenu = CreateMenu(ResetPlayerConfirm_MenuHandler);
	
	AddMenuItem(hMenu, sUserId, "Yes");
	AddMenuItem(hMenu, Name, "No");
	
	SetMenuTitle(hMenu, "[WePlay] JailBreak Shop\nAre you sure you want to reset %s's data?", Name);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int ResetPlayerConfirm_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select && item == 0)
	{
		char sUserId[11], Name[64];
		
		GetMenuItem(hMenu, 0, sUserId, sizeof(sUserId));
		GetMenuItem(hMenu, 1, Name, sizeof(Name));
		
		int target = GetClientOfUserId(StringToInt(sUserId));
		
		if(target == 0)
		{
			PrintToChat(client, " \x01The target player has \x07left \x01the server.");
			return;
		}
		
		SetClientCash(target, 0);
		
		SetClientKnife(target, 0);
		SetClientSelectedKnife(target, 0);
		
		PrintToChat(target, "%s \x05%N \x01reset your \x07knife \x01and cash!", PREFIX, client);
		PrintToChat(client, "%s \x05Successfully \x01reset \x07%N's \x01knife and cash!", PREFIX, target);
	}
}

public Action Command_Knife(int client, int args)
{
	if(!ClientLoadedFromDB[client])
	{
		ReplyToCommand(client, "Couldn't load you from the database. Try again soon.");
		return Plugin_Handled;
	}
	
	ShowKnifeMenu(client);
	
	return Plugin_Handled;
}


public Action Command_Pet(int client, int args)
{
	if(!ClientLoadedFromDB[client])
	{
		ReplyToCommand(client, "Couldn't load you from the database. Try again soon.");
		return Plugin_Handled;
	}
	
	ShowPetMenu(client);
	
	return Plugin_Handled;
}

public Action Command_AutoBunnyHop(int client, int args)
{
	Handle hMenu = CreateMenu(AutoBunnyHopInfo_MenuHandler);
	
	char TempFormat[128];
	
	AddMenuItem(hMenu, "", "Buy Auto Bunny Hop", !ClientAutoBunnyHop[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	FormatEx(TempFormat, sizeof(TempFormat), "%s Auto Bunny Hop", !ClientSelectedAutoBunnyHop[client] ? "Enable" : "Disable");
	AddMenuItem(hMenu, "", TempFormat, ClientAutoBunnyHop[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	SetMenuExitBackButton(hMenu, true);
	
	SetMenuTitle(hMenu, "[WePlay Shop] Auto Bunny Hop\nPrice: %i", 1500);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int AutoBunnyHopInfo_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Cancel && item == MenuCancel_ExitBack)
	{
		ShowKnifeMenu(client, LastItem[client]);
	}
	
	else if(action == MenuAction_Select)
	{
		switch(item)
		{
			case 0:
			{	
				if(ClientCash[client] < 1500)
				{
					PrintToChat(client, "%s \x05You \x01need \x07%i \x01more cash to buy this skill \x07( %i )", PREFIX, 1500 - ClientCash[client], 1500);
					
					return;
				}
				
				GiveClientCash(client, -1 * 1500);
				
				SetClientAutoBunnyHop(client, true);
				SetClientSelectedAutoBunnyHop(client, true);
			}
			
			case 1:
			{
				if(!ClientAutoBunnyHop[client])
				{
					PrintToChat(client, "%s \x05You \x07don't \x01own this \x05skill.", PREFIX);
					
					return;
				}
				
				SetClientSelectedAutoBunnyHop(client, !ClientSelectedAutoBunnyHop[client]);
			}
		}
		
		Command_AutoBunnyHop(client, 0);
	}
}
void ShowKnifeMenu(int client, int item = 0)
{
	Handle hMenu = CreateMenu(Knife_MenuHandler);
	
	char TempFormat[256];
	for(int i=0;i < Array_KnifeStats.Length;i++)
	{
		enKnifeStats ArrayKnifeInfo;
		
		Array_KnifeStats.GetArray(i, ArrayKnifeInfo);
		
		Format(TempFormat, sizeof(TempFormat), "%s%s%s", ArrayKnifeInfo.KnifeName, ClientKnife[client] >= i ? " [DONE]" : "", ClientSelectedKnife[client] == i ? " [EQUIPPED]" : "");		
		
		AddMenuItem(hMenu, "", TempFormat);
	}
	
	SetMenuExitBackButton(hMenu, true);
	
	SetMenuTitle(hMenu, ".וינפלש םיניכסה לכ תא הנוק התאש ינפל ןיכס תונקל לוכי אל התא :הרעה");
	
	DisplayMenuAtItem(hMenu, client, item, MENU_TIME_FOREVER);
}


public int Knife_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Cancel && item == MenuCancel_ExitBack)
	{
		Command_Shop(client, 0);
	}
	else if(action == MenuAction_Select)
	{
		ShowKnifeStatsMenu(client, item);
		
		LastItem[client] = GetMenuSelectionPosition();
	}
}

public void ShowKnifeStatsMenu(int client, int item)
{
	Handle hMenu = CreateMenu(KnifeStats_MenuHandler);
	
	char TempFormat[256];
	
	enKnifeStats ArrayKnifeInfo;
		
	Array_KnifeStats.GetArray(item, ArrayKnifeInfo);
	
	Format(TempFormat, sizeof(TempFormat), "Health: %i", ArrayKnifeInfo.KnifeHP);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);
	
	Format(TempFormat, sizeof(TempFormat), "Armor: %i", ArrayKnifeInfo.KnifeArmor);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);
	
	Format(TempFormat, sizeof(TempFormat), "Slag Chance: %.1f%%", ArrayKnifeInfo.KnifeSlagChance);
	AddMenuItem(hMenu, "", TempFormat, ITEMDRAW_DISABLED);
	
	IntToString(item, TempFormat, sizeof(TempFormat));
	AddMenuItem(hMenu, TempFormat, "Buy Knife", ClientKnife[client] < item ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	AddMenuItem(hMenu, "", "Equip Knife", ClientKnife[client] >= item ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	SetMenuExitBackButton(hMenu, true);
	
	SetMenuTitle(hMenu, "[WePlay Shop] %s\nPrice: %i", ArrayKnifeInfo.KnifeName, ArrayKnifeInfo.KnifePrice);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int KnifeStats_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Cancel && item == MenuCancel_ExitBack)
	{
		ShowKnifeMenu(client, LastItem[client]);
	}
	
	else if(action == MenuAction_Select)
	{
		switch(item)
		{
			case 3:
			{	
				char sKnife[11];
				GetMenuItem(hMenu, 3, sKnife, sizeof(sKnife));
				
				int Knife = StringToInt(sKnife);
				
				enKnifeStats ArrayKnifeInfo;
		
				Array_KnifeStats.GetArray(Knife, ArrayKnifeInfo);
				
				if(ClientKnife[client] + 1 != Knife)
				{
					if(ClientKnife[client] > Knife)
					{
						PrintToChat(client, "%s \x05You \x01already own this \x07knife.", PREFIX);
						
						return;
					}
					else
					{
						PrintToChat(client, "%s \x05You \x01must buy all knives below this one \x07before \x01you can buy it.", PREFIX);
						
						return;
					}
				}
				
				else if(ClientCash[client] < ArrayKnifeInfo.KnifePrice)
				{
					PrintToChat(client, "%s \x05You \x01need \x07%i \x01more cash to buy this knife \x07( %i )", PREFIX, ArrayKnifeInfo.KnifePrice - ClientCash[client], ArrayKnifeInfo.KnifePrice);
					
					return;
				}
				
				GiveClientCash(client, -1 * ArrayKnifeInfo.KnifePrice);
				
				SetClientKnife(client, Knife);
				SetClientSelectedKnife(client, Knife);
			}
			
			case 4:
			{
				char sKnife[11];
				GetMenuItem(hMenu, 3, sKnife, sizeof(sKnife));
				
				int Knife = StringToInt(sKnife);
				
				if(ClientKnife[client] < Knife)
				{
					PrintToChat(client, "%s \x05You \x07don't \x01own this \x05knife.", PREFIX);
					
					return;
				}
				
				SetClientSelectedKnife(client, Knife);
			}
		}
	}
}


void ShowPetMenu(int client, int item = 0)
{
	Handle hMenu = CreateMenu(Pet_MenuHandler);
	
	char TempFormat[256];
	for(int i=0;i < g_iPets;i++)
	{
		Format(TempFormat, sizeof(TempFormat), "%s%s%s", g_ePets[i].name, ClientPet[client] >= i ? " [DONE]" : "", ClientSelectedPet[client] == i ? " [EQUIPPED]" : "");		
		
		AddMenuItem(hMenu, "", TempFormat);
	}
	
	SetMenuExitBackButton(hMenu, true);
	
	SetMenuTitle(hMenu, ".וינפלש תויחה לכ תא הנוק התאש ינפל היח תונקל לוכי אל התא :הרעה");
	
	DisplayMenuAtItem(hMenu, client, item, MENU_TIME_FOREVER);
}


public int Pet_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Cancel && item == MenuCancel_ExitBack)
	{
		Command_Shop(client, 0);
	}
	else if(action == MenuAction_Select)
	{
		ShowPetConfirmMenu(client, item);
		
		LastItem[client] = GetMenuSelectionPosition();
	}
}

public void ShowPetConfirmMenu(int client, int item)
{
	Handle hMenu = CreateMenu(PetConfirm_MenuHandler);
	
	new String:TempFormat[128];
	
	IntToString(item, TempFormat, sizeof(TempFormat));
	AddMenuItem(hMenu, TempFormat, "Buy Pet", ClientPet[client] < item ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	AddMenuItem(hMenu, "", "Equip Pet", ClientPet[client] >= item ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	SetMenuExitBackButton(hMenu, true);
	
	SetMenuTitle(hMenu, "[WePlay Shop] %s\nPrice: %i", g_ePets[item].name, g_ePets[item].price);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public int PetConfirm_MenuHandler(Handle hMenu, MenuAction action, int client, int item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Cancel && item == MenuCancel_ExitBack)
	{
		ShowPetMenu(client, LastItem[client]);
	}
	
	else if(action == MenuAction_Select)
	{
		switch(item)
		{
			case 0:
			{	
				char sPet[11];
				GetMenuItem(hMenu, 0, sPet, sizeof(sPet));
				
				int iPet = StringToInt(sPet);
				
				if(ClientPet[client] + 1 != iPet)
				{
					if(ClientPet[client] > iPet)
					{
						PrintToChat(client, "%s \x05You \x01already own this \x07pet.", PREFIX);
						
						return;
					}
					else
					{
						PrintToChat(client, "%s \x05You \x01must buy all pets below this one \x07before \x01you can buy it.", PREFIX);
						
						return;
					}
				}
				
				else if(ClientCash[client] < g_ePets[iPet].price)
				{
					PrintToChat(client, "%s \x05You \x01need \x07%i \x01more cash to buy this pet \x07( %i )", PREFIX, g_ePets[iPet].price - ClientCash[client], g_ePets[iPet].price);
					
					return;
				}
				
				GiveClientCash(client, -1 * g_ePets[iPet].price);
				
				SetClientPet(client, iPet);
				SetClientSelectedPet(client, iPet);
			}
			
			case 1:
			{
				char sPet[11];
				GetMenuItem(hMenu, 0, sPet, sizeof(sPet));
				
				int iPet = StringToInt(sPet);
				
				if(ClientPet[client] < iPet)
				{
					PrintToChat(client, "%s \x05You \x07don't \x01own this \x05knife.", PREFIX);
					
					return;
				}
				
				SetClientSelectedPet(client, iPet);
			}
		}
	}
}

public Action Command_Gamble(int client, int args)
{
	int maxGamble = 10000;
	int minGamble = 25;
	
	if(GambleCooldown[client] > GetTime())
	{
		PrintToChat(client, " %s \x04You \x01may use this command once at \x075 \x01seconds", PREFIX);
		return Plugin_Handled;
	}
	
	if (args != 1)
	{
		PrintToChat(client, " %s \x01Usage: sm_gamble <amount | all>", PREFIX);
		return Plugin_Handled;
	}
	char arg1[64];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int amount = StringToInt(arg1);
	
	if(amount > ClientCash[client])
	{
		PrintToChat(client, " %s \x01You don't have \x07%d \x01cash!", PREFIX, amount);
		return Plugin_Handled;
	}
	
	else if(StrEqual(arg1, "all", false) || StrEqual(arg1, "allin", false))
	{
		amount = ClientCash[client] > maxGamble ? maxGamble : ClientCash[client];
	}
	
	if(amount < minGamble)
	{
		PrintToChat(client, " %s \x01You must gamble at least on \x0725 \x01credits!", PREFIX);
		return Plugin_Handled;
	}
	else if(amount > maxGamble)
	{
		PrintToChat(client, " %s \x01Max amount of gambling is \x0710,000 \x01credits", PREFIX);
		return Plugin_Handled;
	}
	int RNG = GetRandomInt(1, 100);
	
	bool Won = false;

	int InitialChance = 40;
	int GambleChanceBonus = 0;
	
	if(SQLiteVIPAPI_GetClientVIPLevel(client) == 1)
		GambleChanceBonus = 3;
	
	if(SQLiteVIPAPI_GetClientVIPLevel(client) == 2)
		GambleChanceBonus = 5;
		
	if(SQLiteVIPAPI_GetClientVIPLevel(client) == 3 || Client50ChanceGamble[client])
		GambleChanceBonus = 10;
	
	int Chance = InitialChance + GambleChanceBonus;
	
	Won = RNG <= Chance;
	
	if(amount == ClientCash[client])
		PrintToChatAll(" %s \x07%N \x01has gambled all-in \x07%d \x01cash and %s", PREFIX, client, amount, Won ? "\x04WON!" : "\x02LOST!");
	else
		PrintToChatAll(" %s \x07%N \x01has gambled \x07%d \x01cash and %s", PREFIX, client, amount, Won ? "\x04WON!" : "\x02LOST!");
		
	if(!Won)
		amount *= -1;
		
	GiveClientCash(client, amount, false);
	GambleCooldown[client] = GetTime() + 5;
	
	return Plugin_Handled;
}

// returns amount after multipliers
stock int GiveClientCash(int client, int amount, bool includeMultipliers = false)
{	
	if(includeMultipliers)
	{
		int VIPLevel = SQLiteVIPAPI_GetClientVIPLevel(client);
		if(VIPLevel == 3 || ClientDoubleCash[client])
			amount *= 2;
			
		else if(VIPLevel == 2)
			amount = RoundFloat(float(amount) * 1.5);
		
		else if(VIPLevel == 1)
			amount = RoundFloat(float(amount) * 1.25);
	}
	
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_players SET Cash = Cash + %i WHERE AuthId = '%s'", amount, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientCash[client] += amount;
	
	return amount;
}

stock void SetClientCash(int client, int amount)
{	
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_players SET Cash = %i WHERE AuthId = '%s'", amount, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientCash[client] = amount;
}

stock void SetClientKnife(int client, int Knife)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_players SET Knife = %i WHERE AuthId = '%s'", Knife, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientKnife[client] = Knife;
}

stock void SetClientSelectedKnife(int client, int Knife)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_players SET SelectedKnife = %i WHERE AuthId = '%s'", Knife, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientSelectedKnife[client] = Knife;
	
	UpdateKnifeModel(client);
}


stock void SetClientAutoBunnyHop(int client, bool Value)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_playersPerks SET AutoBunnyHop = %i WHERE AuthId = '%s'", Value, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientAutoBunnyHop[client] = Value;
}

stock void SetClientSelectedAutoBunnyHop(int client, bool Value)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_playersPerks SET SelectedAutoBunnyHop = %i WHERE AuthId = '%s'", Value, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientSelectedAutoBunnyHop[client] = Value;
	
	SendConVarValue(client, hcv_AutoBunnyHopping, ClientSelectedAutoBunnyHop[client] ? "1" : "0");
}

stock void SetClientPet(int client, int iPet)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_players SET Pet = %i WHERE AuthId = '%s'", iPet, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientPet[client] = iPet;
}

stock void SetClientSelectedPet(int client, int iPet)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_players SET SelectedPet = %i WHERE AuthId = '%s'", iPet, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	ClientSelectedPet[client] = iPet;
	
	ResetPet(client);
	
	if(!IsPlayerAlive(client))
		return;
		
	CreatePet(client);
}


stock void GiveClientDoubleCash(int client, int days)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_playersPerks SET DoubleCashExpire = max(DoubleCashExpire, %i) + %i WHERE AuthId = '%s'", GetTime(), SECONDS_IN_A_DAY * days, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	if(days > 0)
		ClientDoubleCash[client] = true;
}

stock void GiveClient50ChanceGamble(int client, int days)
{
	char AuthId[35];
	GetClientAuthId(client, AuthId_Engine, AuthId, sizeof(AuthId));
	
	char sQuery[256];
	
	SQL_FormatQuery(dbShop, sQuery, sizeof(sQuery), "UPDATE Shop_playersPerks SET FiftyChanceGambleExpire = max(FiftyChanceGambleExpire, %i) + %i WHERE AuthId = '%s'", GetTime(), SECONDS_IN_A_DAY * days, AuthId);
	SQL_TQuery(dbShop, SQLCB_Error, sQuery);
	
	if(days > 0)
		Client50ChanceGamble[client] = true;
}

stock void UpdateKnifeModel(int client)
{
	int modelIndex = -1;
	
	enKnifeStats ArrayKnifeInfo;

	Array_KnifeStats.GetArray(ClientSelectedKnife[client], ArrayKnifeInfo);
	
	if(GetTrieValue(Trie_ModelIndex, ArrayKnifeInfo.KnifeModel, modelIndex) && modelIndex != -1)
	{
		FPVMI_AddViewModelToClient(client, "weapon_knife", modelIndex);
	}
	else
	{
		FPVMI_RemoveViewModelToClient(client, "weapon_knife");
	}
}

stock int GetEntityHealth(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iHealth");
}

stock int SetClientArmor(int client, int amount)
{		
	SetEntProp(client, Prop_Send, "m_ArmorValue", amount);
}

stock bool IsEntityPlayer(int entity)
{
	if(entity == 0 || entity > MaxClients)
		return false;
		
	return true;
}


stock int GetAliveTeamCount(int Team)
{
	int count = 0;
	
	for(int i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		else if(GetClientTeam(i) != Team)
			continue;
			
		else if(!IsPlayerAlive(i))
			continue;
			
		count++;
	}
	
	return count;
}	


stock UC_CreateEmptyFile(const char[] sPath)
{
	CloseHandle(OpenFile(sPath, "a"));
}

public Pets_Reset()
{
	g_iPets = 0;
}


public Action:Pets_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client) || !(2<=GetClientTeam(client)<=3))
		return Plugin_Continue;

	ResetPet(client);
	CreatePet(client);

	return Plugin_Continue;
}

public Action:Pets_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client)
		return Plugin_Continue;

	ResetPet(client);

	return Plugin_Continue;
}

public Action:Pets_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || !IsClientInGame(client))
		return Plugin_Continue;

	ResetPet(client);

	return Plugin_Continue;
}

// Lo mizman arahti et ze le optimize.
public Action:OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (IsPlayerAlive(client))
	{
		if(g_unClientPet[client] == INVALID_ENT_REFERENCE)
		{
			if(tickcount % 5 == 0 && EntRefToEntIndex(g_unClientPet[client]) != -1)
			{
				new Float:vec[3];
				decl Float:dist;
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vec);
				dist = GetVectorLength(vec);
				if(g_unLastAnimation[client] != 1 && dist > 0.0)
				{
					SetVariantString(g_ePets[ClientSelectedPet[client]].run);
					AcceptEntityInput(EntRefToEntIndex(g_unClientPet[client]), "SetAnimation");

					g_unLastAnimation[client] = 1;
				}
				else if(g_unLastAnimation[client] != 2 && dist == 0.0)
				{
					SetVariantString(g_ePets[ClientSelectedPet[client]].idle);
					AcceptEntityInput(EntRefToEntIndex(g_unClientPet[client]), "SetAnimation");
					g_unLastAnimation[client]=2;
				}
			}
		}
	}
}

public CreatePet(client)
{
	if(g_unClientPet[client] != INVALID_ENT_REFERENCE)
		return;

	if(ClientSelectedPet[client] <= 0)
		return;

	new m_iData = ClientSelectedPet[client];

	new m_unEnt = CreateEntityByName("prop_dynamic_override");
	
	if (IsValidEntity(m_unEnt))
	{
		new Float:m_flPosition[3];
		new Float:m_flAngles[3];
		new Float:m_flClientOrigin[3];
		new Float:m_flClientAngles[3];
		GetClientAbsOrigin(client, m_flClientOrigin);
		GetClientAbsAngles(client, m_flClientAngles);
	
		m_flPosition[0]=g_ePets[m_iData].fPosition[0];
		m_flPosition[1]=g_ePets[m_iData].fPosition[1];
		m_flPosition[2]=g_ePets[m_iData].fPosition[2];
		m_flAngles[0]=g_ePets[m_iData].fAngles[0];
		m_flAngles[1]=g_ePets[m_iData].fAngles[1];
		m_flAngles[2]=g_ePets[m_iData].fAngles[2];

		decl Float:m_fForward[3];
		decl Float:m_fRight[3];
		decl Float:m_fUp[3];
		GetAngleVectors(m_flClientAngles, m_fForward, m_fRight, m_fUp);

		m_flClientOrigin[0] += m_fRight[0]*m_flPosition[0]+m_fForward[0]*m_flPosition[1]+m_fUp[0]*m_flPosition[2];
		m_flClientOrigin[1] += m_fRight[1]*m_flPosition[0]+m_fForward[1]*m_flPosition[1]+m_fUp[1]*m_flPosition[2];
		m_flClientOrigin[2] += m_fRight[2]*m_flPosition[0]+m_fForward[2]*m_flPosition[1]+m_fUp[2]*m_flPosition[2];
		m_flAngles[1] += m_flClientAngles[1];

		DispatchKeyValue(m_unEnt, "model", g_ePets[m_iData].model);
		DispatchKeyValue(m_unEnt, "spawnflags", "256");
		DispatchKeyValue(m_unEnt, "solid", "0");
		SetEntPropEnt(m_unEnt, Prop_Send, "m_hOwnerEntity", client);
		
		DispatchSpawn(m_unEnt);	
		AcceptEntityInput(m_unEnt, "TurnOn", m_unEnt, m_unEnt, 0);
		
		// Teleport the pet to the right fPosition and attach it
		TeleportEntity(m_unEnt, m_flClientOrigin, m_flAngles, NULL_VECTOR); 
		
		SetVariantString("!activator");
		AcceptEntityInput(m_unEnt, "SetParent", client, m_unEnt, 0);
		
		SetVariantString("letthehungergamesbegin");
		AcceptEntityInput(m_unEnt, "SetParentAttachmentMaintainOffset", m_unEnt, m_unEnt, 0);
	  
		g_unClientPet[client] = EntIndexToEntRef(m_unEnt);
		g_unLastAnimation[client] = -1;
	}
}

public ResetPet(client)
{
	if(g_unClientPet[client] == INVALID_ENT_REFERENCE)
		return;

	new m_unEnt = EntRefToEntIndex(g_unClientPet[client]);
	g_unClientPet[client] = INVALID_ENT_REFERENCE;
	if(m_unEnt == INVALID_ENT_REFERENCE)
		return;

	AcceptEntityInput(m_unEnt, "Kill");
}