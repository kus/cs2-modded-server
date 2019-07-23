#pragma semicolon  1

#define PLUGIN_VERSION "3.0.3.Kento.31.2"

#include <sourcemod> 
#include <adminmenu>
#include <kento_csgocolors>
#include <geoip>
#include <sdktools>
#include <cstrike>
#include <clientprefs>
#include <kento_rankme/rankme>

#pragma newdecls required
#pragma dynamic 131072 

#define SPEC 1
#define TR 2
#define CT 3

#define SENDER_WORLD 0
#define MAX_LENGTH_MENU 470

static const char g_sSqliteCreate[] = "CREATE TABLE IF NOT EXISTS `%s` (id INTEGER PRIMARY KEY, steam VARCHAR(40) NOT NULL, name TEXT, lastip TEXT, score NUMERIC, kills NUMERIC, deaths NUMERIC, assists NUMERIC, suicides NUMERIC, tk NUMERIC, shots NUMERIC, hits NUMERIC, headshots NUMERIC, connected NUMERIC, rounds_tr NUMERIC, rounds_ct NUMERIC, lastconnect NUMERIC,knife NUMERIC,glock NUMERIC,hkp2000 NUMERIC,usp_silencer NUMERIC,p250 NUMERIC,deagle NUMERIC,elite NUMERIC,fiveseven NUMERIC,tec9 NUMERIC,cz75a NUMERIC,revolver NUMERIC,nova NUMERIC,xm1014 NUMERIC,mag7 NUMERIC,sawedoff NUMERIC,bizon NUMERIC,mac10 NUMERIC,mp9 NUMERIC,mp7 NUMERIC,ump45 NUMERIC,p90 NUMERIC,galilar NUMERIC,ak47 NUMERIC,scar20 NUMERIC,famas NUMERIC,m4a1 NUMERIC,m4a1_silencer NUMERIC,aug NUMERIC,ssg08 NUMERIC,sg556 NUMERIC,awp NUMERIC,g3sg1 NUMERIC,m249 NUMERIC,negev NUMERIC,hegrenade NUMERIC,flashbang NUMERIC,smokegrenade NUMERIC,inferno NUMERIC,decoy NUMERIC,taser NUMERIC,mp5sd NUMERIC,breachcharge NUMERIC,head NUMERIC, chest NUMERIC, stomach NUMERIC, left_arm NUMERIC, right_arm NUMERIC, left_leg NUMERIC, right_leg NUMERIC,c4_planted NUMERIC,c4_exploded NUMERIC,c4_defused NUMERIC,ct_win NUMERIC, tr_win NUMERIC, hostages_rescued NUMERIC, vip_killed NUMERIC, vip_escaped NUMERIC, vip_played NUMERIC, mvp NUMERIC, damage NUMERIC, match_win NUMERIC, match_draw NUMERIC, match_lose NUMERIC, first_blood NUMERIC, no_scope NUMERIC, no_scope_dis NUMERIC)";
static const char g_sMysqlCreate[] = "CREATE TABLE IF NOT EXISTS `%s` (id INTEGER PRIMARY KEY, steam TEXT, name TEXT, lastip TEXT, score NUMERIC, kills NUMERIC, deaths NUMERIC, assists NUMERIC, suicides NUMERIC, tk NUMERIC, shots NUMERIC, hits NUMERIC, headshots NUMERIC, connected NUMERIC, rounds_tr NUMERIC, rounds_ct NUMERIC, lastconnect NUMERIC,knife NUMERIC,glock NUMERIC,hkp2000 NUMERIC,usp_silencer NUMERIC,p250 NUMERIC,deagle NUMERIC,elite NUMERIC,fiveseven NUMERIC,tec9 NUMERIC,cz75a NUMERIC,revolver NUMERIC,nova NUMERIC,xm1014 NUMERIC,mag7 NUMERIC,sawedoff NUMERIC,bizon NUMERIC,mac10 NUMERIC,mp9 NUMERIC,mp7 NUMERIC,ump45 NUMERIC,p90 NUMERIC,galilar NUMERIC,ak47 NUMERIC,scar20 NUMERIC,famas NUMERIC,m4a1 NUMERIC,m4a1_silencer NUMERIC,aug NUMERIC,ssg08 NUMERIC,sg556 NUMERIC,awp NUMERIC,g3sg1 NUMERIC,m249 NUMERIC,negev NUMERIC,hegrenade NUMERIC,flashbang NUMERIC,smokegrenade NUMERIC,inferno NUMERIC,decoy NUMERIC,taser NUMERIC,mp5sd NUMERIC,breachcharge NUMERIC,head NUMERIC, chest NUMERIC, stomach NUMERIC, left_arm NUMERIC, right_arm NUMERIC, left_leg NUMERIC, right_leg NUMERIC,c4_planted NUMERIC,c4_exploded NUMERIC,c4_defused NUMERIC,ct_win NUMERIC, tr_win NUMERIC, hostages_rescued NUMERIC, vip_killed NUMERIC, vip_escaped NUMERIC, vip_played NUMERIC, mvp NUMERIC, damage NUMERIC, match_win NUMERIC, match_draw NUMERIC, match_lose NUMERIC, first_blood NUMERIC, no_scope NUMERIC, no_scope_dis NUMERIC) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
static const char g_sSqlInsert[] = "INSERT INTO `%s` VALUES (NULL,'%s','%s','%s','%d','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');";

/* SM1.9 Fix */
static const char g_sSqlSave[] = "UPDATE `%s` SET score = '%i', kills = '%i', deaths='%i', assists='%i',suicides='%i',tk='%i',shots='%i',hits='%i',headshots='%i', rounds_tr = '%i', rounds_ct = '%i',lastip='%s',name='%s'%s,head='%i',chest='%i', stomach='%i',left_arm='%i',right_arm='%i',left_leg='%i',right_leg='%i' WHERE steam = '%s';";
static const char g_sSqlSaveName[] = "UPDATE `%s` SET score = '%i', kills = '%i', deaths='%i', assists='%i',suicides='%i',tk='%i',shots='%i',hits='%i',headshots='%i', rounds_tr = '%i', rounds_ct = '%i',lastip='%s',name='%s'%s,head='%i',chest='%i', stomach='%i',left_arm='%i',right_arm='%i',left_leg='%i',right_leg='%i' WHERE name = '%s';";
static const char g_sSqlSaveIp[] = "UPDATE `%s` SET score = '%i', kills = '%i', deaths='%i', assists='%i',suicides='%i',tk='%i',shots='%i',hits='%i',headshots='%i', rounds_tr = '%i', rounds_ct = '%i',lastip='%s',name='%s'%s,head='%i',chest='%i', stomach='%i',left_arm='%i',right_arm='%i',left_leg='%i',right_leg='%i' WHERE lastip = '%s';";
static const char g_sSqlSave2[] = "UPDATE `%s` SET c4_planted='%i',c4_exploded='%i',c4_defused='%i',ct_win='%i',tr_win='%i', hostages_rescued='%i',vip_killed = '%d',vip_escaped = '%d',vip_played = '%d', mvp='%i', damage='%i', match_win='%i', match_draw='%i', match_lose='%i', first_blood='%i', no_scope='%i', no_scope_dis='%i', lastconnect='%i', connected='%i' WHERE steam = '%s';";
static const char g_sSqlSaveName2[] = "UPDATE `%s` SET c4_planted='%i',c4_exploded='%i',c4_defused='%i',ct_win='%i',tr_win='%i', hostages_rescued='%i',vip_killed = '%d',vip_escaped = '%d',vip_played = '%d', mvp='%i', damage='%i', match_win='%i', match_draw='%i', match_lose='%i', first_blood='%i', no_scope='%i', no_scope_dis='%i', lastconnect='%i', connected='%i' WHERE name = '%s';";
static const char g_sSqlSaveIp2[] = "UPDATE `%s` SET c4_planted='%i',c4_exploded='%i',c4_defused='%i',ct_win='%i',tr_win='%i', hostages_rescued='%i',vip_killed = '%d',vip_escaped = '%d',vip_played = '%d', mvp='%i', damage='%i', match_win='%i', match_draw='%i', match_lose='%i', first_blood='%i', no_scope='%i', no_scope_dis='%i', lastconnect='%i', connected='%i' WHERE lastip = '%s';";

static const char g_sSqlRetrieveClient[] = "SELECT * FROM `%s` WHERE steam='%s';";
static const char g_sSqlRetrieveClientName[] = "SELECT * FROM `%s` WHERE name='%s';";
static const char g_sSqlRetrieveClientIp[] = "SELECT * FROM `%s` WHERE lastip='%s';";
static const char g_sSqlRemoveDuplicateSQLite[] = "delete from `%s` where `%s`.id > (SELECT min(id) from `%s` as t2 WHERE t2.steam=`%s`.steam);";
static const char g_sSqlRemoveDuplicateNameSQLite[] = "delete from `%s` where `%s`.id > (SELECT min(id) from `%s` as t2 WHERE t2.name=`%s`.name);";
static const char g_sSqlRemoveDuplicateIpSQLite[] = "delete from `%s` where `%s`.id > (SELECT min(id) from `%s` as t2 WHERE t2.lastip=`%s`.lastip);";
static const char g_sSqlRemoveDuplicateMySQL[] = "delete from `%s` USING `%s`, `%s` as vtable WHERE (`%s`.id>vtable.id) AND (`%s`.steam=vtable.steam);";
static const char g_sSqlRemoveDuplicateNameMySQL[] = "delete from `%s` USING `%s`, `%s` as vtable WHERE (`%s`.id>vtable.id) AND (`%s`.name=vtable.name);";
static const char g_sSqlRemoveDuplicateIpMySQL[] = "delete from `%s` USING `%s`, `%s` as vtable WHERE (`%s`.id>vtable.id) AND (`%s`.ip=vtable.ip);";
stock const char g_sWeaponsNamesGame[42][] =  { "knife", "glock", "hkp2000", "usp_silencer", "p250", "deagle", "elite", "fiveseven", "tec9", "cz75a", "revolver", "nova", "xm1014", "mag7", "sawedoff", "bizon", "mac10", "mp9", "mp7", "ump45", "p90", "galilar", "ak47", "scar20", "famas", "m4a1", "m4a1_silencer", "aug", "ssg08", "sg556", "awp", "g3sg1", "m249", "negev", "hegrenade", "flashbang", "smokegrenade", "inferno", "decoy", "taser", "mp5sd", "breachcharge"};
stock const char g_sWeaponsNamesFull[42][] =  { "Knife", "Glock", "P2000", "USP-S", "P250", "Desert Eagle", "Dual Berettas", "Five-Seven", "Tec 9", "CZ75-Auto", "R8 Revolver", "Nova", "XM1014", "Mag 7", "Sawed-off", "PP-Bizon", "MAC-10", "MP9", "MP7", "UMP45", "P90", "Galil AR", "AK-47", "SCAR-20", "Famas", "M4A4", "M4A1-S", "AUG", "SSG 08", "SG 553", "AWP", "G3SG1", "M249", "Negev", "HE Grenade", "Flashbang", "Smoke Grenade", "Inferno", "Decoy", "Zeus x27", "MP5-SD", "Breach Charges"};

char g_sSQLTable[200];
Handle g_hStatsDb;
bool OnDB[MAXPLAYERS + 1];
int g_aSession[MAXPLAYERS + 1][STATS_NAMES];
int g_aStats[MAXPLAYERS + 1][STATS_NAMES];
int g_aWeapons[MAXPLAYERS + 1][WEAPONS_ENUM];
int g_aHitBox[MAXPLAYERS + 1][HITBOXES];
int g_TotalPlayers;

Handle g_fwdOnPlayerLoaded;
Handle g_fwdOnPlayerSaved;

bool DEBUGGING = false;
int g_C4PlantedBy;
char g_sC4PlantedByName[MAX_NAME_LENGTH];

// Preventing duplicates
char g_aClientSteam[MAXPLAYERS + 1][64];
char g_aClientName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
char g_aClientIp[MAXPLAYERS + 1][64];

/* Cooldown Timer */
Handle hRankTimer[MAXPLAYERS + 1] = INVALID_HANDLE;

/* Hide Chat */
Handle hidechatcookie;
bool hidechat[MAXPLAYERS+1];

char MSG[64];

#include <kento_rankme/cvars>
#include <kento_rankme/natives>
#include <kento_rankme/cmds>

public Plugin myinfo =  {
	name = "RankMe", 
	author = "lok1, Scooby, Kento, pracc, Kxnrl, CrazyHackGUT", 
	description = "Improved RankMe for CSGO", 
	version = PLUGIN_VERSION, 
	url = "https://github.com/rogeraabbccdd/Kento-Rankme"
};

public void OnPluginStart() {
	
	// CREATE CVARS
	CreateCvars();
	
	// EVENTS
	HookEventEx("player_death", EventPlayerDeath);
	HookEvent("player_spawn", EventPlayerSpawn);
	HookEventEx("player_hurt", EventPlayerHurt);
	HookEventEx("weapon_fire", EventWeaponFire);
	HookEventEx("bomb_planted", Event_BombPlanted);
	HookEventEx("bomb_defused", Event_BombDefused);
	HookEventEx("bomb_exploded", Event_BombExploded);
	HookEventEx("bomb_dropped", Event_BombDropped);
	HookEventEx("bomb_pickup", Event_BombPickup);
	HookEventEx("hostage_rescued", Event_HostageRescued);
	HookEventEx("vip_killed", Event_VipKilled);
	HookEventEx("vip_escaped", Event_VipEscaped);
	HookEventEx("round_end", Event_RoundEnd);
	HookEventEx("round_start", Event_RoundStart);
	HookEventEx("round_mvp", Event_RoundMVP);
	HookEventEx("player_changename", OnClientChangeName, EventHookMode_Pre);
	HookEventEx("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre); 
	//HookEvent("player_team", Event_PlayerTeam);	
	HookEventEx("cs_win_panel_match", Event_WinPanelMatch);
	
	// ADMNIN COMMANDS
	RegAdminCmd("sm_resetrank", CMD_ResetRank, ADMFLAG_ROOT, "RankMe: Resets the rank of a player");
	RegAdminCmd("sm_rankme_remove_duplicate", CMD_Duplicate, ADMFLAG_ROOT, "RankMe: Removes the duplicated rows on the database");
	RegAdminCmd("sm_rankpurge", CMD_Purge, ADMFLAG_ROOT, "RankMe: Purges from the rank players that didn't connected for X days");
	RegAdminCmd("sm_resetrank_all", CMD_ResetRankAll, ADMFLAG_ROOT, "RankMe: Resets the rank of all players");
	
	// PLAYER COMMANDS
	RegConsoleCmd("sm_session", CMD_Session, "RankMe: Shows the stats of your current session");
	RegConsoleCmd("sm_rank", CMD_Rank, "RankMe: Shows your rank");
	RegConsoleCmd("sm_top", CMD_Top, "RankMe: Shows the TOP");
	RegConsoleCmd("sm_topweapon", CMD_TopWeapon, "RankMe: Shows the TOP ordered by kills with a specific weapon");
	RegConsoleCmd("sm_topacc", CMD_TopAcc, "RankMe: Shows the TOP ordered by accuracy");
	RegConsoleCmd("sm_tophs", CMD_TopHS, "RankMe: Shows the TOP ordered by HeadShots");
	RegConsoleCmd("sm_toptime", CMD_TopTime, "RankMe: Shows the TOP ordered by Connected Time");
	RegConsoleCmd("sm_topkills", CMD_TopKills, "RankMe: Shows the TOP ordered by kills");
	RegConsoleCmd("sm_topdeaths", CMD_TopDeaths, "RankMe: Shows the TOP ordered by deaths");
	RegConsoleCmd("sm_hitboxme", CMD_HitBox, "RankMe: Shows the HitBox stats");
	RegConsoleCmd("sm_weaponme", CMD_WeaponMe, "RankMe: Shows the kills with each weapon");
	RegConsoleCmd("sm_resetmyrank", CMD_ResetOwnRank, "RankMe: Resets your own rank");
	RegConsoleCmd("sm_statsme", CMD_StatsMe, "RankMe: Shows your stats");
	RegConsoleCmd("sm_next", CMD_Next, "RankMe: Shows the next 9 players above you on the TOP");
	RegConsoleCmd("sm_statsme2", CMD_StatsMe2, "RankMe: Shows the stats from a player");
	RegConsoleCmd("sm_rankme", CMD_RankMe, "RankMe: Shows a menu with the basic commands");
	RegConsoleCmd("sm_topassists", CMD_TopAssists, "RankMe: Shows the TOP ordered by Assists");
	RegConsoleCmd("sm_toptk", CMD_TopTK, "RankMe: Shows the TOP ordered by TKs");
	RegConsoleCmd("sm_topmvp", CMD_TopMVP, "RankMe: Shows the TOP ordered by MVPs");
	RegConsoleCmd("sm_topdamage", CMD_TopDamage, "RankMe: Shows the TOP ordered by damage");
	RegConsoleCmd("sm_topkdr", CMD_TopKDR, "RankMe: Shows the TOP ordered by kdr");
	RegConsoleCmd("sm_toppoints", CMD_TopPoints, "RankMe: Shows the TOP ordered by points");
	RegConsoleCmd("sm_rankmechat", CMD_HideChat, "Disable rankme chat messages");

	// LOAD RANKME.CFG
	AutoExecConfig(true, "kento.rankme");
		
	// LOAD TRANSLATIONS
	LoadTranslations("kento.rankme.phrases");
	
	//	Hook the say and say_team for chat triggers
	AddCommandListener(OnSayText, "say");
	AddCommandListener(OnSayText, "say_team");
	
	ConVar cvarVersion = CreateConVar("rankme_version", PLUGIN_VERSION, "RankMe Version", FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	// UPDATE THE CVAR IF NEEDED
	char sVersionOnCvar[10];
	cvarVersion.GetString(sVersionOnCvar, sizeof(sVersionOnCvar));
	if (!StrEqual(PLUGIN_VERSION, sVersionOnCvar))
		cvarVersion.SetString(PLUGIN_VERSION, true, true);
	
	// Create the forwards
	g_fwdOnPlayerLoaded = CreateGlobalForward("RankMe_OnPlayerLoaded", ET_Hook, Param_Cell);
	g_fwdOnPlayerSaved = CreateGlobalForward("RankMe_OnPlayerSaved", ET_Hook, Param_Cell);
	
	/* Hide chat */
	hidechatcookie = RegClientCookie("rankme_hidechat", "Hide rankme chat messages", CookieAccess_Private);

	Format(MSG, sizeof(MSG), "%t", "Chat Prefix");
}

public void OnConVarChanged_SQLTable(Handle convar, const char[] oldValue, const char[] newValue) {

	g_cvarSQLTable.GetString(g_sSQLTable, sizeof(g_sSQLTable));
	DB_Connect(true); // Force reloading the stats
}

public void OnConVarChanged_MySQL(Handle convar, const char[] oldValue, const char[] newValue) {
	DB_Connect(false);
}

public void DB_Connect(bool firstload) {
	
	if (g_bMysql != g_cvarMysql.BoolValue || firstload) {  // NEEDS TO CONNECT IF CHANGED MYSQL CVAR OR NEVER CONNECTED
		g_bMysql = g_cvarMysql.BoolValue;
		g_cvarSQLTable.GetString(g_sSQLTable, sizeof(g_sSQLTable));
		char sError[256];
		if (g_bMysql) {
			g_hStatsDb = SQL_Connect("rankme", false, sError, sizeof(sError));
		} else {
			g_hStatsDb = SQLite_UseDatabase("rankme", sError, sizeof(sError));
		}
		if (g_hStatsDb == INVALID_HANDLE)
		{
			SetFailState("[RankMe] Unable to connect to the database (%s)", sError);
		}
		SQL_LockDatabase(g_hStatsDb);
		char sQuery[9999];
		
		if(g_bMysql)
		{
			Format(sQuery, sizeof(sQuery), g_sMysqlCreate, g_sSQLTable);
			SQL_FastQuery(g_hStatsDb, sQuery);
		}
		if(!g_bMysql)
		{
			Format(sQuery, sizeof(sQuery), g_sSqliteCreate, g_sSQLTable);
			SQL_FastQuery(g_hStatsDb, sQuery);
		}
		
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` MODIFY id INTEGER AUTO_INCREMENT", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN vip_killed NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN vip_escaped NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN vip_played NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN match_win NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN match_draw NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN match_lose NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN mp5sd NUMERIC AFTER taser", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN breachcharge NUMERIC AFTER mp5sd", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN first_blood NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN no_scope NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD COLUMN no_scope_dis NUMERIC", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` CHANGE steam steam VARCHAR(40)", g_sSQLTable);
		SQL_FastQuery(g_hStatsDb, sQuery);
		SQL_UnlockDatabase(g_hStatsDb);
		
		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i))
				OnClientPutInServer(i);
		}
	}
	
}
public void OnConfigsExecuted() {
	if (g_hStatsDb == INVALID_HANDLE)
		DB_Connect(true);
	else
		DB_Connect(false);
	int AutoPurge = g_cvarAutopurge.IntValue;
	char sQuery[1000];
	if (AutoPurge > 0) {
		int DeleteBefore = GetTime() - (AutoPurge * 86400);
		Format(sQuery, sizeof(sQuery), "DELETE FROM `%s` WHERE lastconnect < '%d'", g_sSQLTable, DeleteBefore);
		SQL_TQuery(g_hStatsDb, SQL_PurgeCallback, sQuery);
	}
	
	GetCvarValues();
	
	if (g_bRankBots){
		Format(sQuery, sizeof(sQuery), "SELECT * FROM `%s` WHERE kills >= '%d'", g_sSQLTable, g_MinimalKills);
	}
	else{
		Format(sQuery, sizeof(sQuery), "SELECT * FROM `%s` WHERE kills >= '%d' AND steam <> 'BOT'", g_sSQLTable, g_MinimalKills);
	}
	SQL_TQuery(g_hStatsDb, SQL_GetPlayersCallback, sQuery);

	CheckUnique();
	BuildRankCache();
}

void CheckUnique(){
	char sQuery[1000];
	if(g_bMysql)	Format(sQuery, sizeof(sQuery), "SHOW INDEX FROM `%s` WHERE Key_name = 'steam'", g_sSQLTable);
	else			Format(sQuery, sizeof(sQuery), "PRAGMA INDEX_LIST('%s')", g_sSQLTable);
	SQL_TQuery(g_hStatsDb, SQL_SetUniqueCallback, sQuery);
}

public void SQL_SetUniqueCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Check Unique Key Fail: %s", error);
		return;
	}
	
	bool hasunique;
	if(SQL_GetRowCount(hndl) > 0)	hasunique = true;
	else hasunique = false;

	char sQuery[1000];
	if (g_bRankBots){
		//only drop it when theres unique key
		if(hasunique){
			if(g_bMysql)	Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` DROP INDEX steam", g_sSQLTable);
			else			Format(sQuery, sizeof(sQuery), "DROP INDEX steam");
			SQL_TQuery(g_hStatsDb, SQL_NothingCallback, sQuery);
		}
	}
	else{
		Format(sQuery, sizeof(sQuery), "DELETE FROM `%s` WHERE steam = 'BOT'" ,g_sSQLTable);
		SQL_TQuery(g_hStatsDb, SQL_NothingCallback, sQuery);

		// check unique key is exists or not
		if(SQL_GetRowCount(hndl) < 1){
			if(g_bMysql)	Format(sQuery, sizeof(sQuery), "ALTER TABLE `%s` ADD UNIQUE(steam)" ,g_sSQLTable);
			else			Format(sQuery, sizeof(sQuery), "CREATE UNIQUE INDEX steam ON `%s`(steam)" ,g_sSQLTable);
			SQL_TQuery(g_hStatsDb, SQL_NothingCallback, sQuery);
		}
	}
}

void BuildRankCache()
{
	if(!g_bRankCache)
		return;
	
	ClearArray(g_arrayRankCache[0]);
	ClearArray(g_arrayRankCache[1]);
	ClearArray(g_arrayRankCache[2]);
	
	PushArrayString(g_arrayRankCache[0], "Rank By SteamId: This is First Line in Array");
	PushArrayString(g_arrayRankCache[1], "Rank By Name: This is First Line in Array");
	PushArrayString(g_arrayRankCache[2], "Rank By IP: This is First Line in Array");
	
	char query[1000];
	MakeSelectQuery(query, sizeof(query));

	if (g_RankMode == 1)
		Format(query, sizeof(query), "%s ORDER BY score DESC", query);
	else if(g_RankMode == 2)
		Format(query, sizeof(query), "%s ORDER BY CAST(kills as DECIMAL)/CAST(Case when deaths=0 then 1 ELSE deaths END as DECIMAL) DESC", query);
	
	SQL_TQuery(g_hStatsDb, SQL_BuildRankCache, query);
}

public void SQL_BuildRankCache(Handle owner, Handle hndl, const char[] error, any unuse)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] : build rank cache failed", error);
		return;
	}
	
	if(SQL_GetRowCount(hndl))
	{
		char steamid[32], name[128], ip[32];
		while(SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 1, steamid, 32);
			SQL_FetchString(hndl, 2, name, 128);
			SQL_FetchString(hndl, 3, ip, 32);
			PushArrayString(g_arrayRankCache[0], steamid);
			PushArrayString(g_arrayRankCache[1], name);
			PushArrayString(g_arrayRankCache[2], ip);
		}
	}
	else
		LogMessage("[RankMe] :  No mork rank");
}

public Action OnClientChangeName(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled)
		return Plugin_Continue;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return Plugin_Continue;
	if (IsClientConnected(client))
	{
		char clientnewname[MAX_NAME_LENGTH];
		GetEventString(event, "newname", clientnewname, sizeof(clientnewname));
		if (client == g_C4PlantedBy)
			strcopy(g_sC4PlantedByName, sizeof(g_sC4PlantedByName), clientnewname);
		char Eclientnewname[MAX_NAME_LENGTH * 2 + 1];
		SQL_EscapeString(g_hStatsDb, clientnewname, Eclientnewname, sizeof(Eclientnewname));
		
		//ReplaceString(clientnewname, sizeof(clientnewname), "'", "");
		char query[10000];
		if (g_RankBy == 1) {
			OnDB[client] = false;
			for (int i = 0; i <= 19; i++) {
				g_aSession[client][i] = 0;
				g_aStats[client][i] = 0;
			}
			g_aStats[client][SCORE] = g_PointsStart;
			for (int i = 0; i < 42; i++) {
				g_aWeapons[client][i] = 0;
			}
			g_aSession[client][CONNECTED] = GetTime();
			
			strcopy(g_aClientName[client], MAX_NAME_LENGTH, clientnewname);
			
			Format(query, sizeof(query), g_sSqlRetrieveClientName, g_sSQLTable, Eclientnewname);
			if (DEBUGGING) {
				PrintToServer(query);
				LogError("%s", query);
			}
			SQL_TQuery(g_hStatsDb, SQL_LoadPlayerCallback, query, client);
			
		} else {
			
			if (g_RankBy == 0)
				Format(query, sizeof(query), "UPDATE `%s` SET name='%s' WHERE steam = '%s';", g_sSQLTable, Eclientnewname, g_aClientSteam[client]);
			else
				Format(query, sizeof(query), "UPDATE `%s` SET name='%s' WHERE lastip = '%s';", g_sSQLTable, Eclientnewname, g_aClientIp[client]);
			
			SQL_TQuery(g_hStatsDb, SQL_NothingCallback, query);
		}
	}
	return Plugin_Continue;
}

int GetCurrentPlayers() 
{
	int count;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && (!IsFakeClient(i) || g_bRankBots)) {
			count++;
		}
	}
	return count;
}

public void OnPluginEnd() {
	if (!g_bEnabled)
		return;
	SQL_LockDatabase(g_hStatsDb);
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
				return;
			char name[MAX_NAME_LENGTH];
			GetClientName(client, name, sizeof(name));
			char sEscapeName[MAX_NAME_LENGTH * 2 + 1];
			SQL_EscapeString(g_hStatsDb, name, sEscapeName, sizeof(sEscapeName));
			
			// Make SQL-safe
			//ReplaceString(name, sizeof(name), "'", "");
			
			
			char weapons_query[2000] = "";
			for (int i = 0; i < 42; i++) {
				Format(weapons_query, sizeof(weapons_query), "%s,%s='%d'", weapons_query, g_sWeaponsNamesGame[i], g_aWeapons[client][i]);
			}
			
			/* SM1.9 Fix */
			char query[4000];
			char query2[4000];
	
			if (g_RankBy == 0) 
			{
				Format(query, sizeof(query), g_sSqlSave, g_sSQLTable, g_aStats[client][SCORE], g_aStats[client][KILLS], g_aStats[client][DEATHS], g_aStats[client][ASSISTS], g_aStats[client][SUICIDES], g_aStats[client][TK], 
					g_aStats[client][SHOTS], g_aStats[client][HITS], g_aStats[client][HEADSHOTS], g_aStats[client][ROUNDS_TR], g_aStats[client][ROUNDS_CT], g_aClientIp[client], sEscapeName, weapons_query, 
					g_aHitBox[client][1], g_aHitBox[client][2], g_aHitBox[client][3], g_aHitBox[client][4], g_aHitBox[client][5], g_aHitBox[client][6], g_aHitBox[client][7], g_aClientSteam[client]);
	
				Format(query2, sizeof(query2), g_sSqlSave2, g_sSQLTable, g_aStats[client][C4_PLANTED], g_aStats[client][C4_EXPLODED], g_aStats[client][C4_DEFUSED], g_aStats[client][CT_WIN], g_aStats[client][TR_WIN], 
					g_aStats[client][HOSTAGES_RESCUED], g_aStats[client][VIP_KILLED], g_aStats[client][VIP_ESCAPED], g_aStats[client][VIP_PLAYED], g_aStats[client][MVP], g_aStats[client][DAMAGE], g_aStats[client][MATCH_WIN], g_aStats[client][MATCH_DRAW], g_aStats[client][MATCH_LOSE], g_aStats[client][FB], g_aStats[client][NS], g_aStats[client][NSD], GetTime(), g_aStats[client][CONNECTED] + GetTime() - g_aSession[client][CONNECTED], g_aClientSteam[client]);
			} 
	
			else if (g_RankBy == 1) 
			{
				Format(query, sizeof(query), g_sSqlSaveName, g_sSQLTable, g_aStats[client][SCORE], g_aStats[client][KILLS], g_aStats[client][DEATHS], g_aStats[client][ASSISTS], g_aStats[client][SUICIDES], g_aStats[client][TK], 
					g_aStats[client][SHOTS], g_aStats[client][HITS], g_aStats[client][HEADSHOTS], g_aStats[client][ROUNDS_TR], g_aStats[client][ROUNDS_CT], g_aClientIp[client], sEscapeName, weapons_query, 
					g_aHitBox[client][1], g_aHitBox[client][2], g_aHitBox[client][3], g_aHitBox[client][4], g_aHitBox[client][5], g_aHitBox[client][6], g_aHitBox[client][7], sEscapeName);
	
				Format(query2, sizeof(query2), g_sSqlSaveName2, g_sSQLTable, g_aStats[client][C4_PLANTED], g_aStats[client][C4_EXPLODED], g_aStats[client][C4_DEFUSED], g_aStats[client][CT_WIN], g_aStats[client][TR_WIN], 
					g_aStats[client][HOSTAGES_RESCUED], g_aStats[client][VIP_KILLED], g_aStats[client][VIP_ESCAPED], g_aStats[client][VIP_PLAYED], g_aStats[client][MVP], g_aStats[client][DAMAGE], g_aStats[client][MATCH_WIN], g_aStats[client][MATCH_DRAW], g_aStats[client][MATCH_LOSE], g_aStats[client][FB], g_aStats[client][NS], g_aStats[client][NSD], GetTime(), g_aStats[client][CONNECTED] + GetTime() - g_aSession[client][CONNECTED], sEscapeName);
			} 
	
			else if (g_RankBy == 2) 
			{
				Format(query, sizeof(query), g_sSqlSaveIp, g_sSQLTable, g_aStats[client][SCORE], g_aStats[client][KILLS], g_aStats[client][DEATHS], g_aStats[client][ASSISTS], g_aStats[client][SUICIDES], g_aStats[client][TK], 
					g_aStats[client][SHOTS], g_aStats[client][HITS], g_aStats[client][HEADSHOTS], g_aStats[client][ROUNDS_TR], g_aStats[client][ROUNDS_CT], g_aClientIp[client], sEscapeName, weapons_query, 
					g_aHitBox[client][1], g_aHitBox[client][2], g_aHitBox[client][3], g_aHitBox[client][4], g_aHitBox[client][5], g_aHitBox[client][6], g_aHitBox[client][7], g_aClientIp[client]);
	
				Format(query2, sizeof(query2), g_sSqlSaveIp2,  g_aStats[client][C4_PLANTED], g_aStats[client][C4_EXPLODED], g_aStats[client][C4_DEFUSED], g_aStats[client][CT_WIN], g_aStats[client][TR_WIN], 
					g_aStats[client][HOSTAGES_RESCUED], g_aStats[client][VIP_KILLED], g_aStats[client][VIP_ESCAPED], g_aStats[client][VIP_PLAYED], g_aStats[client][MVP], g_aStats[client][DAMAGE], g_aStats[client][MATCH_WIN], g_aStats[client][MATCH_DRAW], g_aStats[client][MATCH_LOSE], g_aStats[client][FB], g_aStats[client][NS], g_aStats[client][NSD], GetTime(), g_aStats[client][CONNECTED] + GetTime() - g_aSession[client][CONNECTED], g_aClientIp[client]);
			}
			
			LogMessage(query);
			LogMessage(query2);
			SQL_FastQuery(g_hStatsDb, query);
			SQL_FastQuery(g_hStatsDb, query2);
			
			/**
			Start the forward OnPlayerSaved
			*/
			Action fResult;
			Call_StartForward(g_fwdOnPlayerSaved);
			Call_PushCell(client);
			int fError = Call_Finish(fResult);
			
			if (fError != SP_ERROR_NONE)
			{
				ThrowNativeError(fError, "Forward failed");
			}
		}
	}
	SQL_UnlockDatabase(g_hStatsDb);
}

public int GetWeaponNum(char[] weaponname) 
{
	for (int i = 0; i < 42; i++) {
		if (StrEqual(weaponname, g_sWeaponsNamesGame[i]))
			return i;
	}
	return 44;
}

public Action Event_VipEscaped(Handle event, const char[] name, bool dontBroadcast) {
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	for (int i = 1; i <= MaxClients; i++) {
		
		if (IsClientInGame(i) && GetClientTeam(i) == CT) {
			g_aStats[i][SCORE] += g_PointsVipEscapedTeam;
			g_aSession[i][SCORE] += g_PointsVipEscapedTeam;
			
		}
		
	}
	g_aStats[client][VIP_PLAYED]++;
	g_aSession[client][VIP_PLAYED]++;
	g_aStats[client][VIP_ESCAPED]++;
	g_aSession[client][VIP_ESCAPED]++;
	g_aStats[client][SCORE] += g_PointsVipEscapedPlayer;
	g_aSession[client][SCORE] += g_PointsVipEscapedPlayer;
	
	if (!g_bChatChange)
		return;
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "CT_VIPEscaped", i, g_PointsVipEscapedTeam);
	if (client != 0 && (g_bRankBots && !IsFakeClient(client)))
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "VIPEscaped", i, g_aClientName[client], g_aStats[client][SCORE], g_PointsVipEscapedTeam + g_PointsVipEscapedPlayer);
}

public Action Event_VipKilled(Handle event, const char[] name, bool dontBroadcast) {
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	for (int i = 1; i <= MaxClients; i++) {
		
		if (IsClientInGame(i) && GetClientTeam(i) == TR) {
			g_aStats[i][SCORE] += g_PointsVipKilledTeam;
			g_aSession[i][SCORE] += g_PointsVipKilledTeam;
			
		}
		
	}
	g_aStats[client][VIP_PLAYED]++;
	g_aSession[client][VIP_PLAYED]++;
	g_aStats[killer][VIP_KILLED]++;
	g_aSession[killer][VIP_KILLED]++;
	g_aStats[killer][SCORE] += g_PointsVipKilledPlayer;
	g_aSession[killer][SCORE] += g_PointsVipKilledPlayer;
	
	if (!g_bChatChange)
		return;
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "TR_VIPKilled", i, g_PointsVipKilledTeam);
	if (client != 0 && (g_bRankBots && !IsFakeClient(client)))
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "VIPKilled", i, g_aClientName[client], g_aStats[client][SCORE], g_PointsVipKilledTeam + g_PointsVipKilledPlayer);
}

public Action Event_HostageRescued(Handle event, const char[] name, bool dontBroadcast) {
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	
	for (int i = 1; i <= MaxClients; i++) {
		
		if (IsClientInGame(i) && GetClientTeam(i) == CT) {
			g_aStats[i][SCORE] += g_PointsHostageRescTeam;
			g_aSession[i][SCORE] += g_PointsHostageRescTeam;
			
		}
		
	}
	g_aSession[client][HOSTAGES_RESCUED]++;
	g_aStats[client][HOSTAGES_RESCUED]++;
	g_aStats[client][SCORE] += g_PointsHostageRescPlayer;
	g_aSession[client][SCORE] += g_PointsHostageRescPlayer;
	
	if (!g_bChatChange)
		return;
	if (g_PointsHostageRescTeam > 0)
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "CT_Hostage", i, g_PointsHostageRescTeam);
	
	if (g_PointsHostageRescPlayer > 0 && client != 0 && (g_bRankBots && !IsFakeClient(client)))
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "Hostage", i, g_aClientName[client], g_aStats[client][SCORE], g_PointsHostageRescPlayer + g_PointsHostageRescTeam);
	
}

public Action Event_RoundMVP(Handle event, const char[] name, bool dontBroadcast) {
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsClientInGame(client))
		return;
	int team = GetClientTeam(client);
	
	if (((team == 2 && g_PointsMvpTr > 0) || (team == 3 && g_PointsMvpCt > 0)) && client != 0 && (g_bRankBots && !IsFakeClient(client))) {
		
		if (team == 2) {
			
			g_aStats[client][SCORE] += g_PointsMvpTr;
			g_aSession[client][SCORE] += g_PointsMvpTr;
			for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i))
				if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "MVP", i, g_aClientName[client], g_aStats[client][SCORE], g_PointsMvpTr);
			
		} else {
			
			g_aStats[client][SCORE] += g_PointsMvpCt;
			g_aSession[client][SCORE] += g_PointsMvpCt;
			for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i))
				if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "MVP", i, g_aClientName[client], g_aStats[client][SCORE], g_PointsMvpCt);	
		}
	}
	g_aStats[client][MVP]++;
	g_aSession[client][MVP]++;
}
public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast) {
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	int i;
	int Winner = GetEventInt(event, "winner");
	bool announced = false;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && (g_bRankBots || !IsFakeClient(i))) {
			if (Winner == TR) {
				if(GetClientTeam(i) == TR){
					g_aSession[i][TR_WIN]++;
					g_aStats[i][TR_WIN]++;
					if (g_PointsRoundWin[TR] > 0) {
						g_aSession[i][SCORE] += g_PointsRoundWin[TR];
						g_aStats[i][SCORE] += g_PointsRoundWin[TR];
						if (!announced && g_bChatChange) {
							for (int j = 1; j <= MaxClients; j++)
							if (IsClientInGame(j))
								if(!hidechat[j]) CPrintToChat(j, "%s %T", MSG, "TR_Round", j, g_PointsRoundWin[TR]);
						}
					}
				}
				else if(GetClientTeam(i) == CT){
					if (g_PointsRoundLose[CT] > 0) {
						g_aSession[i][SCORE] -= g_PointsRoundLose[CT];
						g_aStats[i][SCORE] -= g_PointsRoundLose[CT];
						if (!announced && g_bChatChange) {
							for (int j = 1; j <= MaxClients; j++)
							if (IsClientInGame(j))
								if(!hidechat[j]) CPrintToChat(j, "%s %T", MSG, "CT_Round_Lose", j, g_PointsRoundLose[CT]);
						}
					}
				}
				announced = true;
			} else if (Winner == CT) {
				if(GetClientTeam(i) == CT){
					g_aSession[i][CT_WIN]++;
					g_aStats[i][CT_WIN]++;
					if (g_PointsRoundWin[CT] > 0) {
						g_aSession[i][SCORE] += g_PointsRoundWin[CT];
						g_aStats[i][SCORE] += g_PointsRoundWin[CT];
						if (!announced && g_bChatChange) {
							for (int j = 1; j <= MaxClients; j++)
							if (IsClientInGame(j))
								if(!hidechat[j]) CPrintToChat(j, "%s %T", MSG, "CT_Round", j, g_PointsRoundWin[CT]);
						}
					}
				}
				else if(GetClientTeam(i) == TR){
					if (g_PointsRoundLose[TR] > 0) {
						g_aSession[i][SCORE] -= g_PointsRoundLose[TR];
						g_aStats[i][SCORE] -= g_PointsRoundLose[TR];
						if (!announced && g_bChatChange) {
							for (int j = 1; j <= MaxClients; j++)
							if (IsClientInGame(j))
								if(!hidechat[j]) CPrintToChat(j, "%s %T", MSG, "TR_Round_Lose", j, g_PointsRoundLose[TR]);
						}
					}
				}
				announced = true;
			}
			SalvarPlayer(i);
		}
	}
	
	DumpDB();
}


public void EventPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	/* Old rounds played, this have been moved to round start.
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!g_bRankBots && IsFakeClient(client))
		return;
	if (GetClientTeam(client) == TR) {
		g_aStats[client][ROUNDS_TR]++;
		g_aSession[client][ROUNDS_TR]++;
	} else if (GetClientTeam(client) == CT) {
		g_aStats[client][ROUNDS_CT]++;
		g_aSession[client][ROUNDS_CT]++;
	}
	*/
}


public void Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
		
	firstblood = false;
	
	int i;
	for(i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TR) 
		{
			g_aStats[i][ROUNDS_TR]++;
			g_aSession[i][ROUNDS_TR]++;
		} 
		else if (IsClientInGame(i) && GetClientTeam(i) == CT) 
		{
			g_aStats[i][ROUNDS_CT]++;
			g_aSession[i][ROUNDS_CT]++;
		}
	}
}

public Action Event_BombPlanted(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	g_C4PlantedBy = client;
	
	for (int i = 1; i <= MaxClients; i++) {
		
		if (IsClientInGame(i) && GetClientTeam(i) == TR) {
			g_aStats[i][SCORE] += g_PointsBombPlantedTeam;
			g_aSession[i][SCORE] += g_PointsBombPlantedTeam;
			
		}
		
	}
	g_aStats[client][C4_PLANTED]++;
	g_aSession[client][C4_PLANTED]++;
	g_aStats[client][SCORE] += g_PointsBombPlantedPlayer;
	g_aSession[client][SCORE] += g_PointsBombPlantedPlayer;
	
	strcopy(g_sC4PlantedByName, sizeof(g_sC4PlantedByName), g_aClientName[client]);
	if (!g_bChatChange)
		return;
	if (g_PointsBombPlantedTeam > 0)
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "TR_Planting", i, g_PointsBombPlantedTeam);
	if (g_PointsBombPlantedPlayer > 0 && client != 0 && (g_bRankBots || !IsFakeClient(client)))
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "Planting", i, g_aClientName[client], g_aStats[client][SCORE], g_PointsBombPlantedTeam + g_PointsBombPlantedPlayer);
	
}

public Action Event_BombDefused(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	for (int i = 1; i <= MaxClients; i++) {
		
		if (IsClientInGame(i) && GetClientTeam(i) == CT) {
			g_aStats[i][SCORE] += g_PointsBombDefusedTeam;
			g_aSession[i][SCORE] += g_PointsBombDefusedTeam;
			
		}
		
	}
	g_aStats[client][C4_DEFUSED]++;
	g_aSession[client][C4_DEFUSED]++;
	g_aStats[client][SCORE] += g_PointsBombDefusedPlayer;
	g_aSession[client][SCORE] += g_PointsBombDefusedPlayer;
	
	if (!g_bChatChange)
		return;
	if (g_PointsBombDefusedTeam > 0)
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "CT_Defusing", i, g_PointsBombDefusedTeam);
	if (g_PointsBombDefusedPlayer > 0 && client != 0 && (g_bRankBots || !IsFakeClient(client)))
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "Defusing", i, g_aClientName[client], g_aStats[client][SCORE], g_PointsBombDefusedTeam + g_PointsBombDefusedPlayer);
}

public Action Event_BombExploded(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
		
	int client = g_C4PlantedBy;
	
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return;
		
	for (int i = 1; i <= MaxClients; i++) {
		
		if (IsClientInGame(i) && GetClientTeam(i) == TR) {
			g_aStats[i][SCORE] += g_PointsBombExplodeTeam;
			g_aSession[i][SCORE] += g_PointsBombExplodeTeam;
			
		}
		
	}
	g_aStats[client][C4_EXPLODED]++;
	g_aSession[client][C4_EXPLODED]++;
	g_aStats[client][SCORE] += g_PointsBombExplodePlayer;
	g_aSession[client][SCORE] += g_PointsBombExplodePlayer;
	
	if (!g_bChatChange)
		return;
	if (g_PointsBombExplodeTeam > 0)
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "TR_Exploding", i, g_PointsBombExplodeTeam);
	if (g_PointsBombExplodePlayer > 0 && client != 0 && (g_bRankBots || !IsFakeClient(client)))
		for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		if(!hidechat[i]) CPrintToChat(i, "%s %T", MSG, "Exploding", i, g_sC4PlantedByName, g_aStats[client][SCORE], g_PointsBombExplodeTeam + g_PointsBombExplodePlayer);
}

public Action Event_BombPickup(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	g_aStats[client][SCORE] += g_PointsBombPickup;
	g_aSession[client][SCORE] += g_PointsBombPickup;
	
	if (!g_bChatChange)
		return;
	if (g_PointsBombPickup > 0)
		if(!hidechat[client])	CPrintToChat(client, "%s %T", MSG, "BombPickup", client, g_aClientName[client], g_aStats[client][SCORE], g_PointsBombPickup);
	
}

public Action Event_BombDropped(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	g_aStats[client][SCORE] -= g_PointsBombDropped;
	g_aSession[client][SCORE] -= g_PointsBombDropped;
	
	if (!g_bChatChange)
		return;
	if (g_PointsBombDropped > 0 && client == 0)
		if(!hidechat[client])	CPrintToChat(client, "%s %T", MSG, "BombDropped", client, g_aClientName[client], g_aStats[client][SCORE], g_PointsBombDropped);
	
}

public Action EventPlayerDeath(Handle event, const char [] name, bool dontBroadcast)
// ----------------------------------------------------------------------------
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int assist = GetClientOfUserId(GetEventInt(event, "assister"));
	
	char weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	ReplaceString(weapon, sizeof(weapon), "weapon_", "");

	if (!g_bRankBots && attacker != 0 && (IsFakeClient(victim) || IsFakeClient(attacker)))
		return;
	
	if (victim == attacker || attacker == 0) {
		g_aStats[victim][SUICIDES]++;
		g_aSession[victim][SUICIDES]++;
		g_aStats[victim][SCORE] -= g_PointsLoseSuicide;
		g_aSession[victim][SCORE] -= g_PointsLoseSuicide;
		
		/* Min points */
		if (g_bPointsMinEnabled)
		{
			if (g_aStats[victim][SCORE] < g_PointsMin)
			{
				g_aStats[victim][SCORE] = g_PointsMin;
			}
		}
		
		if (g_PointsLoseSuicide > 0 && g_bChatChange) {
			if(!hidechat[victim])	CPrintToChat(victim, "%s %T", MSG, "LostSuicide", victim, g_aClientName[victim], g_aStats[victim][SCORE], g_PointsLoseSuicide);
		}
		
	} else if (!g_bFfa && (GetClientTeam(victim) == GetClientTeam(attacker))) {
		if (attacker < MAXPLAYERS) {
			g_aStats[attacker][TK]++;
			g_aSession[attacker][TK]++;
			g_aStats[attacker][SCORE] -= g_PointsLoseTk;
			g_aSession[attacker][SCORE] -= g_PointsLoseTk;
			
			/* Min points */
			if (g_bPointsMinEnabled)
			{
				if (g_aStats[victim][SCORE] < g_PointsMin)
				{
					g_aStats[victim][SCORE] = g_PointsMin;
				}
			}
		
			if (g_PointsLoseTk > 0 && g_bChatChange) {
				if(!hidechat[victim])	CPrintToChat(victim, "%s %T", MSG, "LostTK", victim, g_aClientName[attacker], g_aStats[attacker][SCORE], g_PointsLoseTk, g_aClientName[victim]);
				if(!hidechat[attacker])	CPrintToChat(attacker, "%s %T", MSG, "LostTK", attacker, g_aClientName[attacker], g_aStats[attacker][SCORE], g_PointsLoseTk, g_aClientName[victim]);
			}
		}
	} 
	else {
		int team = GetClientTeam(attacker);
		bool headshot = GetEventBool(event, "headshot");
		
		/* knife */
		if (StrContains(weapon, "knife") != -1 ||  
			StrEqual(weapon, "bayonet") ||
			StrEqual(weapon, "melee") || 
			StrEqual(weapon, "axe") || 
			StrEqual(weapon, "hammer") || 
			StrEqual(weapon, "spanner") ||
			StrEqual(weapon, "fists"))		weapon = "knife";
		
		/* breachcharge has projectile */
		if (StrContains(weapon, "breachcharge") != -1) weapon = "breachcharge";
		
		/* firebomb = molotov */
		if (StrEqual(weapon, "firebomb")) weapon = "molotov";
		
		/* diversion = decoy, and decoy has projectile */
		if (StrContains(weapon, "diversion") != -1 || StrContains(weapon, "decoy") != -1) weapon = "decoy";
		
		int score_dif;
		if (attacker < MAXPLAYERS)
			score_dif = g_aStats[victim][SCORE] - g_aStats[attacker][SCORE];
		
		if (score_dif < 0 || attacker >= MAXPLAYERS) {
			score_dif = g_PointsKill[team];
		} else {
			if (g_PointsKillBonusDif[team] == 0)
				score_dif = g_PointsKill[team] + ((g_aStats[victim][SCORE] - g_aStats[attacker][SCORE]) * g_PointsKillBonus[team]);
			else
				score_dif = g_PointsKill[team] + (((g_aStats[victim][SCORE] - g_aStats[attacker][SCORE]) / g_PointsKillBonusDif[team]) * g_PointsKillBonus[team]);
		}
		if (StrEqual(weapon, "knife")) {
			score_dif = RoundToCeil(score_dif * g_fPointsKnifeMultiplier);
		}
		else if (StrEqual(weapon, "taser")) {
			score_dif = RoundToCeil(score_dif * g_fPointsTaserMultiplier);
		}
		if (headshot && attacker < MAXPLAYERS) {
			g_aStats[attacker][HEADSHOTS]++;
			g_aSession[attacker][HEADSHOTS]++;
		}
		
		g_aStats[victim][DEATHS]++;
		g_aSession[victim][DEATHS]++;
		if (attacker < MAXPLAYERS) {
			g_aStats[attacker][KILLS]++;
			g_aSession[attacker][KILLS]++;
		}
		if (g_bPointsLoseRoundCeil) 
		{
			g_aStats[victim][SCORE] -= RoundToCeil(score_dif * g_fPercentPointsLose);
			g_aSession[victim][SCORE] -= RoundToCeil(score_dif * g_fPercentPointsLose);
			
			/* Min points */
			if (g_bPointsMinEnabled)
			{
				if (g_aStats[victim][SCORE] < g_PointsMin)
				{
					g_aStats[victim][SCORE] = g_PointsMin;
				}
			}
			
		} 
		else 
		{
			g_aStats[victim][SCORE] -= RoundToFloor(score_dif * g_fPercentPointsLose);
			g_aSession[victim][SCORE] -= RoundToFloor(score_dif * g_fPercentPointsLose);
			
			/* Min points */
			if (g_bPointsMinEnabled)
			{
				if (g_aStats[victim][SCORE] < g_PointsMin)
				{
					g_aStats[victim][SCORE] = g_PointsMin;
				}
			}
		}
		if (attacker < MAXPLAYERS) {
			g_aStats[attacker][SCORE] += score_dif;
			g_aSession[attacker][SCORE] += score_dif;
			if (GetWeaponNum(weapon) < 42)
				g_aWeapons[attacker][GetWeaponNum(weapon)]++;
		}
		
		if (g_MinimalKills == 0 || (g_aStats[victim][KILLS] >= g_MinimalKills && g_aStats[attacker][KILLS] >= g_MinimalKills)) {
			if (g_bChatChange) {
				//PrintToServer("%s %T",MSG,"Killing",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE]);
				if(!hidechat[victim])	
				{
					CPrintToChat(victim, "%s %T", MSG, "Killing", victim, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE]);
				}
				if (attacker < MAXPLAYERS)
				{
					if(!hidechat[attacker])
					{
						CPrintToChat(attacker, "%s %T", MSG, "Killing", attacker, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE]);
					}
				}
			}
		} else {
			if (g_aStats[victim][KILLS] < g_MinimalKills && g_aStats[attacker][KILLS] < g_MinimalKills) {
				if (g_bChatChange) {
					if(!hidechat[victim])	CPrintToChat(victim, "%s %T", MSG, "KillingBothNotRanked", victim, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE], g_aStats[attacker][KILLS], g_MinimalKills, g_aStats[victim][KILLS], g_MinimalKills);
					if (attacker < MAXPLAYERS)
						if(!hidechat[attacker])	CPrintToChat(attacker, "%s %T", MSG, "KillingBothNotRanked", attacker, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE], g_aStats[attacker][KILLS], g_MinimalKills, g_aStats[victim][KILLS], g_MinimalKills);
				}
			} else if (g_aStats[victim][KILLS] < g_MinimalKills) {
				if (g_bChatChange) {
					if(!hidechat[victim])	CPrintToChat(victim, "%s %T", MSG, "KillingVictimNotRanked", victim, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE], g_aStats[victim][KILLS], g_MinimalKills);
					if (attacker < MAXPLAYERS)
						if(!hidechat[victim])	CPrintToChat(victim, "%s %T", MSG, "KillingVictimNotRanked", victim, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE], g_aStats[victim][KILLS], g_MinimalKills);
				}
			} else {
				if (g_bChatChange) {
					if(!hidechat[victim])	CPrintToChat(victim, "%s %T", MSG, "KillingKillerNotRanked", victim, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE], g_aStats[attacker][KILLS], g_MinimalKills);
					if (attacker < MAXPLAYERS)
						if(!hidechat[attacker])	CPrintToChat(attacker, "%s %T", MSG, "KillingKillerNotRanked", attacker, g_aClientName[attacker], g_aStats[attacker][SCORE], score_dif, g_aClientName[victim], g_aStats[victim][SCORE], g_aStats[attacker][KILLS], g_MinimalKills);
				}
			}
		}
		if (headshot && attacker < MAXPLAYERS) {
			
			g_aStats[attacker][SCORE] += g_PointsHs;
			g_aSession[attacker][SCORE] += g_PointsHs;
			if (g_bChatChange && g_PointsHs > 0)
				if(!hidechat[attacker])	CPrintToChat(attacker, "%s %T", MSG, "Headshot", attacker, g_aClientName[attacker], g_aStats[attacker][SCORE], g_PointsHs);
		}
		/* First blood */
		if (!firstblood && attacker < MAXPLAYERS) {
			
			g_aStats[attacker][SCORE] += g_PointsFb;
			g_aSession[attacker][SCORE] += g_PointsFb;
			
			g_aStats[attacker][FB] ++;
			g_aSession[attacker][FB] ++;
			if (g_bChatChange && g_PointsFb > 0)
				if(!hidechat[attacker])	CPrintToChat(attacker, "%s %T", MSG, "First Blood", attacker, g_aClientName[attacker], g_aStats[attacker][SCORE], g_PointsFb);
		}
		
		/* No scope */
		if( attacker < MAXPLAYERS && ((StrContains(weapon, "awp") != -1 || StrContains(weapon, "ssg08") != -1) || (g_bNSAllSnipers && (StrContains(weapon, "g3sg1") != -1 || StrContains(weapon, "scar20") != -1))) && (GetEntProp(attacker, Prop_Data, "m_iFOV") <= 0 || GetEntProp(attacker, Prop_Data, "m_iFOV") == GetEntProp(attacker, Prop_Data, "m_iDefaultFOV")))
		{
			g_aStats[attacker][SCORE]+= g_PointsNS;
			g_aSession[attacker][SCORE]+= g_PointsNS;
			g_aStats[attacker][NS]++;
			g_aSession[attacker][NS]++;
			
			float fNSD = Math_UnitsToMeters(Entity_GetDistance(victim, attacker));	
			
			// stats are int, so we change it from m to cm
			int iNSD = RoundToFloor(fNSD * 100);
			if(iNSD > g_aStats[attacker][NSD]) g_aStats[attacker][NSD] = iNSD;
			if(iNSD > g_aSession[attacker][NSD]) g_aSession[attacker][NSD] = iNSD;
			
			if(g_bChatChange && g_PointsNS > 0){
				if(!hidechat[attacker])	
				{
					CPrintToChat(attacker, "%s %T", MSG, "No Scope", attacker, g_aClientName[attacker], g_aStats[attacker][SCORE], g_PointsNS, g_aClientName[victim], weapon, fNSD);
				}
			}
		}
	}
			
	/* Assist */
	if(assist && attacker < MAXPLAYERS){
		
		//Do not attack your teammate, my friend
		if(GetClientTeam(victim) == GetClientTeam(assist))	return;
		else
		{
			g_aStats[assist][SCORE]+= g_PointsAssistKill;
			g_aSession[assist][SCORE]+= g_PointsAssistKill;
			g_aStats[assist][ASSISTS]++;
			g_aSession[assist][ASSISTS]++;
			
			if(g_bChatChange && g_PointsAssistKill > 0){
				if(!hidechat[assist])	CPrintToChat(assist, "%s %T", MSG, "AssistKill", assist, g_aClientName[assist], g_aStats[assist][SCORE], g_PointsAssistKill, g_aClientName[attacker], g_aClientName[victim]);
			}
		}
	}
	
	if (attacker < MAXPLAYERS)
		if (g_aStats[attacker][KILLS] == 50)
		g_TotalPlayers++;
		
	firstblood = true;
}

public Action EventPlayerHurt(Handle event, const char [] name, bool dontBroadcast)
// ----------------------------------------------------------------------------
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (!g_bRankBots && (attacker == 0 || IsFakeClient(victim) || IsFakeClient(attacker)))
		return;
		
	if (victim != attacker && attacker > 0 && attacker < MAXPLAYERS) {
		int hitgroup = GetEventInt(event, "hitgroup");
		if (hitgroup == 0) // Player was hit by knife, he, flashbang, or smokegrenade.
			return;
		
		if(hitgroup == 8) hitgroup = 1;
		
		g_aStats[attacker][HITS]++;
		g_aSession[attacker][HITS]++;
		g_aHitBox[attacker][hitgroup]++;
		
		int damage = GetEventInt(event, "dmg_health");
		g_aStats[attacker][DAMAGE] += damage;
		g_aSession[attacker][DAMAGE] += damage;
		
		//PrintToChat(attacker, "Hitgroup %i: %i hits", hitgroup, g_aHitBox[attacker][hitgroup]);
		//PrintToServer("Stats Hits: %i\nSession Hits: %i\nHitBox %i -> %i",g_aStats[attacker][HITS],g_aSession[attacker][HITS],hitgroup,g_aHitBox[attacker][hitgroup]);
	}
}

public Action EventWeaponFire(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return;
		
	// Don't count knife being used neither hegrenade, flashbang and smokegrenade being threw
	char sWeaponUsed[50];
	GetEventString(event, "weapon", sWeaponUsed, sizeof(sWeaponUsed));
	ReplaceString(sWeaponUsed, sizeof(sWeaponUsed), "weapon_", "");
	if (StrContains(sWeaponUsed, "knife") != -1 || 
		StrEqual(sWeaponUsed, "bayonet") || 
		StrEqual(sWeaponUsed, "melee") || 
		StrEqual(sWeaponUsed, "axe") || 
		StrEqual(sWeaponUsed, "hammer") || 
		StrEqual(sWeaponUsed, "spanner") || 
		StrEqual(sWeaponUsed, "fists") || 
		StrEqual(sWeaponUsed, "hegrenade") || 
		StrEqual(sWeaponUsed, "flashbang") || 
		StrEqual(sWeaponUsed, "smokegrenade") || 
		StrEqual(sWeaponUsed, "inferno") || 
		StrEqual(sWeaponUsed, "molotov") || 
		StrEqual(sWeaponUsed, "incgrenade") ||
		StrContains(sWeaponUsed, "decoy") != -1 ||
		StrEqual(sWeaponUsed, "firebomb") ||
		StrEqual(sWeaponUsed, "diversion") ||
		StrContains(sWeaponUsed, "breachcharge") != -1)
		return; 
	
	g_aStats[client][SHOTS]++;
	g_aSession[client][SHOTS]++;
}

public void SalvarPlayer(int client) {
	if (!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers())
		return;
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return;
	if (!OnDB[client])
		return;
	
	char sEscapeName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hStatsDb, g_aClientName[client], sEscapeName, sizeof(sEscapeName));
	//SQL_EscapeString(g_hStatsDb,name,name,sizeof(name));
	
	// Make SQL-safe
	//ReplaceString(name, sizeof(name), "'", "");
	
	char weapons_query[1000] = "";
	for (int i = 0; i < 42; i++) {
		Format(weapons_query, sizeof(weapons_query), "%s,%s='%d'", weapons_query, g_sWeaponsNamesGame[i], g_aWeapons[client][i]);
	}
	
	/* SM1.9 Fix*/
	char query[4000];
	char query2[4000];
	
	if (g_RankBy == 0) 
	{
		Format(query, sizeof(query), g_sSqlSave, g_sSQLTable, g_aStats[client][SCORE], g_aStats[client][KILLS], g_aStats[client][DEATHS], g_aStats[client][ASSISTS], g_aStats[client][SUICIDES], g_aStats[client][TK], 
			g_aStats[client][SHOTS], g_aStats[client][HITS], g_aStats[client][HEADSHOTS], g_aStats[client][ROUNDS_TR], g_aStats[client][ROUNDS_CT], g_aClientIp[client], sEscapeName, weapons_query, 
			g_aHitBox[client][1], g_aHitBox[client][2], g_aHitBox[client][3], g_aHitBox[client][4], g_aHitBox[client][5], g_aHitBox[client][6], g_aHitBox[client][7], g_aClientSteam[client]);
	
		Format(query2, sizeof(query2), g_sSqlSave2, g_sSQLTable, g_aStats[client][C4_PLANTED], g_aStats[client][C4_EXPLODED], g_aStats[client][C4_DEFUSED], g_aStats[client][CT_WIN], g_aStats[client][TR_WIN], 
			g_aStats[client][HOSTAGES_RESCUED], g_aStats[client][VIP_KILLED], g_aStats[client][VIP_ESCAPED], g_aStats[client][VIP_PLAYED], g_aStats[client][MVP], g_aStats[client][DAMAGE], g_aStats[client][MATCH_WIN], g_aStats[client][MATCH_DRAW], g_aStats[client][MATCH_LOSE], g_aStats[client][FB], g_aStats[client][NS], g_aStats[client][NSD], GetTime(), g_aStats[client][CONNECTED] + GetTime() - g_aSession[client][CONNECTED], g_aClientSteam[client]);
	} 
	
	else if (g_RankBy == 1) 
	{
		Format(query, sizeof(query), g_sSqlSaveName, g_sSQLTable, g_aStats[client][SCORE], g_aStats[client][KILLS], g_aStats[client][DEATHS], g_aStats[client][ASSISTS], g_aStats[client][SUICIDES], g_aStats[client][TK], 
			g_aStats[client][SHOTS], g_aStats[client][HITS], g_aStats[client][HEADSHOTS], g_aStats[client][ROUNDS_TR], g_aStats[client][ROUNDS_CT], g_aClientIp[client], sEscapeName, weapons_query, 
			g_aHitBox[client][1], g_aHitBox[client][2], g_aHitBox[client][3], g_aHitBox[client][4], g_aHitBox[client][5], g_aHitBox[client][6], g_aHitBox[client][7], sEscapeName);
	
		Format(query2, sizeof(query2), g_sSqlSaveName2, g_sSQLTable, g_aStats[client][C4_PLANTED], g_aStats[client][C4_EXPLODED], g_aStats[client][C4_DEFUSED], g_aStats[client][CT_WIN], g_aStats[client][TR_WIN], 
			g_aStats[client][HOSTAGES_RESCUED], g_aStats[client][VIP_KILLED], g_aStats[client][VIP_ESCAPED], g_aStats[client][VIP_PLAYED], g_aStats[client][MVP], g_aStats[client][DAMAGE], g_aStats[client][MATCH_WIN], g_aStats[client][MATCH_DRAW], g_aStats[client][MATCH_LOSE], g_aStats[client][FB], g_aStats[client][NS], g_aStats[client][NSD], GetTime(), g_aStats[client][CONNECTED] + GetTime() - g_aSession[client][CONNECTED], sEscapeName);
	} 
	
	else if (g_RankBy == 2) 
	{
		Format(query, sizeof(query), g_sSqlSaveIp, g_sSQLTable, g_aStats[client][SCORE], g_aStats[client][KILLS], g_aStats[client][DEATHS], g_aStats[client][ASSISTS], g_aStats[client][SUICIDES], g_aStats[client][TK], 
			g_aStats[client][SHOTS], g_aStats[client][HITS], g_aStats[client][HEADSHOTS], g_aStats[client][ROUNDS_TR], g_aStats[client][ROUNDS_CT], g_aClientIp[client], sEscapeName, weapons_query, 
			g_aHitBox[client][1], g_aHitBox[client][2], g_aHitBox[client][3], g_aHitBox[client][4], g_aHitBox[client][5], g_aHitBox[client][6], g_aHitBox[client][7], g_aClientIp[client]);
	
		Format(query2, sizeof(query2), g_sSqlSaveIp2,  g_aStats[client][C4_PLANTED], g_aStats[client][C4_EXPLODED], g_aStats[client][C4_DEFUSED], g_aStats[client][CT_WIN], g_aStats[client][TR_WIN], 
			g_aStats[client][HOSTAGES_RESCUED], g_aStats[client][VIP_KILLED], g_aStats[client][VIP_ESCAPED], g_aStats[client][VIP_PLAYED], g_aStats[client][MVP], g_aStats[client][DAMAGE], g_aStats[client][MATCH_WIN], g_aStats[client][MATCH_DRAW], g_aStats[client][MATCH_LOSE], g_aStats[client][FB], g_aStats[client][NS], g_aStats[client][NSD], GetTime(), g_aStats[client][CONNECTED] + GetTime() - g_aSession[client][CONNECTED], g_aClientIp[client]);
	}
	
	SQL_TQuery(g_hStatsDb, SQL_SaveCallback, query, client, DBPrio_High);
	SQL_TQuery(g_hStatsDb, SQL_SaveCallback, query2, client, DBPrio_High);
	
	if (DEBUGGING) {
		PrintToServer(query);
		PrintToServer(query2);
		LogError("%s", query);
		LogError("%s", query2);
	}
}


public void SQL_SaveCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Save Player Fail: %s", error);
		return;
	}
	
	/**
		Start the forward OnPlayerSaved
	*/
	Action fResult;
	Call_StartForward(g_fwdOnPlayerSaved);
	Call_PushCell(client);
	int fError = Call_Finish(fResult);
	
	if (fError != SP_ERROR_NONE)
	{
		ThrowNativeError(fError, "Forward failed");
	}
	
}

public void OnClientPutInServer(int client) {
	
	// If the database isn't connected, you can't run SQL_EscapeString.
	if (g_hStatsDb != INVALID_HANDLE)
		LoadPlayer(client);
		
	// Cookie
	if(IsValidClient(client) && !IsFakeClient(client)){
		char buffer[5];
		GetClientCookie(client, hidechatcookie, buffer, sizeof(buffer));
		if(StrEqual(buffer, "") || StrEqual(buffer,"0"))	hidechat[client] = false;
		else if(StrEqual(buffer,"1"))	hidechat[client] = true;
	}
}

public void LoadPlayer(int client) {
	
	OnDB[client] = false;
	// stats
	for (int i = 0; i <= 28; i++) {
		g_aSession[client][i] = 0;
		g_aStats[client][i] = 0;
	}
	g_aStats[client][SCORE] = g_PointsStart;
	// weapons
	for (int i = 0; i < 42; i++) {
		g_aWeapons[client][i] = 0;
	}
	g_aSession[client][CONNECTED] = GetTime();
	//hitboxes
	for (int i = 1; i <= 7; i++) {
		g_aHitBox[client][i] = 0;
	}
	
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	strcopy(g_aClientName[client], MAX_NAME_LENGTH, name);
	char sEscapeName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hStatsDb, name, sEscapeName, sizeof(sEscapeName));
	//ReplaceString(name, sizeof(name), "'", "");
	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
	strcopy(g_aClientSteam[client], sizeof(g_aClientSteam[]), auth);
	char ip[32];
	GetClientIP(client, ip, sizeof(ip));
	strcopy(g_aClientIp[client], sizeof(g_aClientIp[]), ip);
	char query[10000];
	if (g_RankBy == 1)
		FormatEx(query, sizeof(query), g_sSqlRetrieveClientName, g_sSQLTable, sEscapeName);
	else if (g_RankBy == 0)
		FormatEx(query, sizeof(query), g_sSqlRetrieveClient, g_sSQLTable, auth);
	else if (g_RankBy == 2)
		FormatEx(query, sizeof(query), g_sSqlRetrieveClientIp, g_sSQLTable, ip);
	
	if (DEBUGGING) {
		PrintToServer(query);
		LogError("%s", query);
	}
	if (g_hStatsDb != INVALID_HANDLE)
		SQL_TQuery(g_hStatsDb, SQL_LoadPlayerCallback, query, client);
	
}

public void SQL_LoadPlayerCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return;
		
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Load Player Fail: %s", error);
		return;
	}
	if (!IsClientInGame(client))
		return;
	
	if (g_RankBy == 1) {
		char name[MAX_NAME_LENGTH];
		GetClientName(client, name, sizeof(name));
		if (!StrEqual(name, g_aClientName[client]))
			return;
	} else if (g_RankBy == 0) {
		char auth[64];
		GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
		if (!StrEqual(auth, g_aClientSteam[client]))
			return;
	} else if (g_RankBy == 2) {
		char ip[64];
		GetClientIP(client, ip, sizeof(ip));
		if (!StrEqual(ip, g_aClientIp[client]))
			return;
	}
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		//Player infos
		for (int i = 0; i <= 11; i++) {
			g_aStats[client][i] = SQL_FetchInt(hndl, 4 + i);
		}
		
		//ALL 41 Weapons
		for (int i = 0; i < 42; i++) {
			g_aWeapons[client][i] = SQL_FetchInt(hndl, 17 + i);
		}
		
		//ALL 8 Hitboxes
		for (int i = 1; i <= 7; i++) {
			g_aHitBox[client][i] = SQL_FetchInt(hndl, 58 + i);
		}
		
		g_aStats[client][C4_PLANTED] = SQL_FetchInt(hndl, 66);
		g_aStats[client][C4_EXPLODED] = SQL_FetchInt(hndl, 67);
		g_aStats[client][C4_DEFUSED] = SQL_FetchInt(hndl, 68);
		g_aStats[client][CT_WIN] = SQL_FetchInt(hndl, 69);
		g_aStats[client][TR_WIN] = SQL_FetchInt(hndl, 70);
		g_aStats[client][HOSTAGES_RESCUED] = SQL_FetchInt(hndl, 71);
		g_aStats[client][VIP_KILLED] = SQL_FetchInt(hndl, 72);
		g_aStats[client][VIP_ESCAPED] = SQL_FetchInt(hndl, 73);
		g_aStats[client][VIP_PLAYED] = SQL_FetchInt(hndl, 74);
		g_aStats[client][MVP] = SQL_FetchInt(hndl, 75);
		g_aStats[client][DAMAGE] = SQL_FetchInt(hndl, 76);
		g_aStats[client][MATCH_WIN] = SQL_FetchInt(hndl, 77);
		g_aStats[client][MATCH_DRAW] = SQL_FetchInt(hndl, 78);
		g_aStats[client][MATCH_LOSE] = SQL_FetchInt(hndl, 79);
		g_aStats[client][FB] = SQL_FetchInt(hndl, 80);
		g_aStats[client][NS] = SQL_FetchInt(hndl, 81);
		g_aStats[client][NSD] = SQL_FetchInt(hndl, 82);
	} else {
		char query[10000];
		char sEscapeName[MAX_NAME_LENGTH * 2 + 1];
		SQL_EscapeString(g_hStatsDb, g_aClientName[client], sEscapeName, sizeof(sEscapeName));
		//SQL_EscapeString(g_hStatsDb,name,name,sizeof(name));
		//ReplaceString(name, sizeof(name), "'", "");
		
		Format(query, sizeof(query), g_sSqlInsert, g_sSQLTable, g_aClientSteam[client], sEscapeName, g_aClientIp[client], g_PointsStart);
		SQL_TQuery(g_hStatsDb, SQL_NothingCallback, query, _, DBPrio_High);
		
		if (DEBUGGING) {
			PrintToServer(query);
			LogError("%s", query);
		}
	}
	OnDB[client] = true;
	/**
	Start the forward OnPlayerLoaded
	*/
	Action fResult;
	Call_StartForward(g_fwdOnPlayerLoaded);
	Call_PushCell(client);
	int fError = Call_Finish(fResult);
	
	if (fError != SP_ERROR_NONE)
	{
		ThrowNativeError(fError, "Forward failed");
	}
}

public void SQL_PurgeCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	
	PrintToServer("[RankMe]: %d players purged by inactivity", SQL_GetAffectedRows(owner));
	if (client != 0) {
		PrintToChat(client, "[RankMe]: %d players purged by inactivity", SQL_GetAffectedRows(owner));
	}
	//LogAction(-1,-1,"[RankMe]: %d players purged by inactivity",SQL_GetAffectedRows(owner));
	
}

public void SQL_NothingCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
}

public void OnClientDisconnect(int client) {
	if (!g_bEnabled)
		return;
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return;
	SalvarPlayer(client);
	OnDB[client] = false;
}

public void DumpDB() {
	if (!g_bDumpDB || g_bMysql)
		return;
	char sQuery[1000];
	FormatEx(sQuery, sizeof(sQuery), "SELECT * from `%s`", g_sSQLTable);
	SQL_TQuery(g_hStatsDb, SQL_DumpCallback, sQuery);
}

public void SQL_DumpCallback(Handle owner, Handle hndl, const char[] error, any Datapack) {
	
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	
	Handle File1;
	char fields_values[600];
	char field[100];
	char prepared_field[200];
	
	fields_values[0] = 0;
	
	File1 = OpenFile("rank.sql", "w");
	if (File1 == INVALID_HANDLE) {
		
		LogError("[RankMe] Unable to open dump file.");
		
	}
	int fields = SQL_GetFieldCount(hndl);
	bool first;
	
	if(g_bMysql)
	{
		WriteFileLine(File1, g_sMysqlCreate, g_sSQLTable);
		WriteFileLine(File1, "");
	}
	
	if(!g_bMysql)
	{
		WriteFileLine(File1, g_sSqliteCreate, g_sSQLTable);
		WriteFileLine(File1, "");
	}
	
	while (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		field = "";
		fields_values = "";
		first = true;
		for (int i = 0; i <= fields - 1; i++) {
			SQL_FetchString(hndl, i, field, sizeof(field));
			// ReplaceString(field, sizeof(field), "\\","\\\\",false);
			// ReplaceString(field,sizeof(field),"\"", "\\\"", false);
			SQL_EscapeString(g_hStatsDb, field, prepared_field, sizeof(prepared_field));
			
			if (first) {
				Format(fields_values, sizeof(fields_values), "\"%s\"", prepared_field);
				first = false;
			}
			else
				Format(fields_values, sizeof(fields_values), "%s,\"%s\"", fields_values, prepared_field);
		}
		
		WriteFileLine(File1, "INSERT INTO `%s` VALUES (%s);", g_sSQLTable, fields_values);
	}
	CloseHandle(File1);
}

stock bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

stock void MakeSelectQuery(char[] sQuery, int strsize) {
	
	// Make basic query
	Format(sQuery, strsize, "SELECT * FROM `%s` WHERE kills >= '%d'", g_sSQLTable, g_MinimalKills);
	
	// Append check for bots
	if (!g_bShowBotsOnRank)
		Format(sQuery, strsize, "%s AND steam <> 'BOT'", sQuery);
	
	// Append check for inactivity
	if (g_DaysToNotShowOnRank > 0)
		Format(sQuery, strsize, "%s AND lastconnect >= '%d'", sQuery, GetTime() - (g_DaysToNotShowOnRank * 86400));
} 

public Action RankMe_OnPlayerLoaded(int client){

	/*RankMe Connect Announcer*/
	if(!g_bAnnounceConnect && !g_bAnnounceTopConnect)
		return Plugin_Handled;
	
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return Plugin_Handled;
	
	RankMe_GetRank(client, RankConnectCallback);
	
	return Plugin_Continue;
}

public Action RankConnectCallback(int client, int rank, any data)
{
	
	if (!g_bRankBots && (!IsValidClient(client) || IsFakeClient(client)))
		return;
		
	g_aPointsOnConnect[client] = RankMe_GetPoints(client);
	
	g_aRankOnConnect[client] = rank;
		
	char sClientName[MAX_NAME_LENGTH];
	GetClientName(client,sClientName,sizeof(sClientName));
	
	/* Geoip, code from cksurf */
	char s_Country[32];
	char s_address[32];		
	GetClientIP(client, s_address, 32);
	Format(s_Country, sizeof(s_Country), "Unknown");
	GeoipCountry(s_address, s_Country, sizeof(s_Country));     
	// if(!strcmp(s_Country, NULL_STRING))
	if (s_Country[0] == 0)
		Format( s_Country, sizeof(s_Country), "Unknown", s_Country );
	else				
		if( StrContains( s_Country, "United", false ) != -1 || 
			StrContains( s_Country, "Republic", false ) != -1 || 
			StrContains( s_Country, "Federation", false ) != -1 || 
			StrContains( s_Country, "Island", false ) != -1 || 
			StrContains( s_Country, "Netherlands", false ) != -1 || 
			StrContains( s_Country, "Isle", false ) != -1 || 
			StrContains( s_Country, "Bahamas", false ) != -1 || 
			StrContains( s_Country, "Maldives", false ) != -1 || 
			StrContains( s_Country, "Philippines", false ) != -1 || 
			StrContains( s_Country, "Vatican", false ) != -1 )
		{
			Format( s_Country, sizeof(s_Country), "The %s", s_Country );
		}			
	
	if(!ShouldHideAnnounce(client))
	{
		if(g_bAnnounceConnect){
			if(g_bAnnounceConnectChat){
				CPrintToChatAll("%s %t",MSG,"PlayerJoinedChat",sClientName,g_aRankOnConnect[client],g_aPointsOnConnect[client],s_Country);
			}
			
			if(g_bAnnounceConnectHint){
				PrintHintTextToAll("%t","PlayerJoinedHint",sClientName,g_aRankOnConnect[client],g_aPointsOnConnect[client],s_Country);		
			}
		}
		
		if(g_bAnnounceTopConnect && rank <= g_AnnounceTopPosConnect){
			
			if(g_bAnnounceTopConnectChat){	
				CPrintToChatAll("%s %t",MSG,"TopPlayerJoinedChat",g_AnnounceTopPosConnect,sClientName,g_aRankOnConnect[client],s_Country);			
			}
			
			if(g_bAnnounceTopConnectHint){
				PrintHintTextToAll("%t","TopPlayerJoinedHint",g_AnnounceTopPosConnect,sClientName,g_aRankOnConnect[client],s_Country);
			}
		}
	}
}

public Action Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	if(!g_bAnnounceDisconnect)
		return;

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(ShouldHideAnnounce(client))	return;
	
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || !g_bRankBots)
		return;
	
	char sName[MAX_NAME_LENGTH];
	GetClientName(client,sName,MAX_NAME_LENGTH);
	strcopy(g_sBufferClientName[client],MAX_NAME_LENGTH,sName);
	
	g_aPointsOnDisconnect[client] = RankMe_GetPoints(client);
	
	char disconnectReason[64];
	GetEventString(event, "reason", disconnectReason, sizeof(disconnectReason));
	
	CPrintToChatAll("%s %t",MSG,"PlayerLeft",g_sBufferClientName[client], g_aPointsOnDisconnect[client], disconnectReason);
}

/* Enable Or Disable Points In Warmup */
public void OnGameFrame()
{
	//If cvar disable
	if(!g_bGatherStatsWarmup)
	{
		//In Warmup
		if(GameRules_GetProp("m_bWarmupPeriod") == 1)
		{
			g_bGatherStats = false;
		}
		
		//Not in warmup
		else 
		{
			g_bGatherStats = true;
		}
	}	
}

public Action Event_WinPanelMatch(Handle event, const char[] name, bool dontBroadcast) {
	if(CS_GetTeamScore(CT) > CS_GetTeamScore(TR))
	{
		for(int i=1;i<=MaxClients;i++)
		{
			if(IsClientInGame(i))
			{
				if(!hidechat[i])
				{
					CPrintToChat(i, "%T", "CT_Win", i, g_PointsMatchWin);
					CPrintToChat(i, "%T", "TR_Lose", i, g_PointsMatchLose);
				}
				
				if(GetClientTeam(i) == TR)
				{
					g_aStats[i][MATCH_LOSE]++;
					g_aStats[i][SCORE] -= g_PointsMatchLose;
				}
				else if (GetClientTeam(i) == CT)
				{
					g_aStats[i][MATCH_WIN]++;
					g_aStats[i][SCORE] += g_PointsMatchWin;
				}
			}
		}
	}
	
	else if(CS_GetTeamScore(CT) == CS_GetTeamScore(TR))
	{
		for(int i=1;i<=MaxClients;i++)
		{
			if (IsClientInGame(i) && (GetClientTeam(i) == TR || GetClientTeam(i) == CT))
			{
				g_aStats[i][MATCH_DRAW]++;
				g_aStats[i][SCORE] += g_PointsMatchDraw;
				
				if(!hidechat[i])	CPrintToChat(i, "%T", "Draw", i, g_PointsMatchDraw);
			}
		}
	}
	
	else if(CS_GetTeamScore(CT) < CS_GetTeamScore(TR))
	{
		for(int i=1;i<=MaxClients;i++)
		{
			if(IsClientInGame(i))
			{
				if(!hidechat[i])
				{
					CPrintToChat(i, "%s %T", MSG, "TR_Win", i, g_PointsMatchWin);
					CPrintToChat(i, "%s %T", MSG, "CT_Lose", i, g_PointsMatchLose);
				}
				
				if(GetClientTeam(i) == TR)
				{
					g_aStats[i][MATCH_WIN]++;
					g_aStats[i][SCORE] += g_PointsMatchWin;
				}
				else if (GetClientTeam(i) == CT)
				{
					g_aStats[i][MATCH_LOSE]++;
					g_aStats[i][SCORE] -= g_PointsMatchLose;
				}
			}
		}
	}
}

stock bool ShouldHideAnnounce(int client)
{
	if(StrEqual(g_sAnnounceAdmin, "") || StrEqual(g_sAnnounceAdmin, " "))	return false;
	else
	{
		if (CheckCommandAccess(client, "rankme_admin", ReadFlagString(g_sAnnounceAdmin), true))	return true;
		else return false;
	}
}

public Action CMD_Duplicate(int client, int args) {
	char sQuery[400];
	
	if (g_bMysql) {
		
		if (g_RankBy == 0)
			FormatEx(sQuery, sizeof(sQuery), g_sSqlRemoveDuplicateMySQL, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable);
		
		else if (g_RankBy == 1)
			FormatEx(sQuery, sizeof(sQuery), g_sSqlRemoveDuplicateNameMySQL, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable);
		
		else if (g_RankBy == 2)
			FormatEx(sQuery, sizeof(sQuery), g_sSqlRemoveDuplicateIpMySQL, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable);
		
	} else {
		
		if (g_RankBy == 0)
			FormatEx(sQuery, sizeof(sQuery), g_sSqlRemoveDuplicateSQLite, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable);
		
		else if (g_RankBy == 1)
			FormatEx(sQuery, sizeof(sQuery), g_sSqlRemoveDuplicateNameSQLite, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable);
		
		else if (g_RankBy == 2)
			FormatEx(sQuery, sizeof(sQuery), g_sSqlRemoveDuplicateIpSQLite, g_sSQLTable, g_sSQLTable, g_sSQLTable, g_sSQLTable);
		
	}
	
	SQL_TQuery(g_hStatsDb, SQL_DuplicateCallback, sQuery, client);
	
	return Plugin_Handled;
}

public void SQL_DuplicateCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	
	PrintToServer("[RankMe]: %d duplicated rows removed", SQL_GetAffectedRows(owner));
	if (client != 0) {
		PrintToChat(client, "[RankMe]: %d duplicated rows removed", SQL_GetAffectedRows(owner));
	}
	//LogAction(-1,-1,"[RankMe]: %d players purged by inactivity",SQL_GetAffectedRows(owner));
	
}