#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <cstrike>
#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#pragma tabsize 0

#define VERSION "1.2"
#define ADMIN_LEVEL ADMFLAG_ROOT
#define DEBUG 0
#define WHITE 0x01
#define DARKRED 0x02
#define PURPLE 0x03
#define GREEN 0x04
#define MOSSGREEN 0x05
#define LIMEGREEN 0x06
#define RED 0x07
#define GRAY 0x08
#define YELLOW 0x10
#define LIGHTYELLOW 0x09
#define DARKGREY 0x0A
#define BLUE 0x0B
#define DARKBLUE 0x0C
#define LIGHTBLUE 0x0D
#define PINK 0x0E
#define LIGHTRED 0x0F
#define QUOTE 0x22
#define PERCENT 0x25
#define CPLIMIT 50
#define MYSQL 0
#define SQLITE 1
#define MAX_STRAFES 100

new Handle:g_hDb = INVALID_HANDLE;
new Handle:g_hdist_good_weird = INVALID_HANDLE;
new Float:g_dist_good_weird;
new Handle:g_hdist_pro_weird = INVALID_HANDLE;
new Float:g_dist_pro_weird;
new Handle:g_hdist_leet_weird = INVALID_HANDLE;
new Float:g_dist_leet_weird;
new Handle:g_hdist_ownage_weird = INVALID_HANDLE;
new Float:g_dist_ownage_weird;
new Handle:g_hdist_good_dropbhop = INVALID_HANDLE;
new Float:g_dist_good_dropbhop;
new Handle:g_hdist_pro_dropbhop = INVALID_HANDLE;
new Float:g_dist_pro_dropbhop;
new Handle:g_hdist_leet_dropbhop = INVALID_HANDLE;
new Float:g_dist_leet_dropbhop;
new Handle:g_hdist_ownage_dropbhop = INVALID_HANDLE;
new Float:g_dist_ownage_dropbhop;
new Handle:g_hdist_good_bhop = INVALID_HANDLE;
new Float:g_dist_good_bhop;
new Handle:g_hdist_pro_bhop = INVALID_HANDLE;
new Float:g_dist_pro_bhop;
new Handle:g_hdist_leet_bhop = INVALID_HANDLE;
new Float:g_dist_leet_bhop;
new Handle:g_hdist_ownage_bhop = INVALID_HANDLE;
new Float:g_dist_ownage_bhop;
new Handle:g_hdist_good_multibhop = INVALID_HANDLE;
new Float:g_dist_good_multibhop;
new Handle:g_hdist_pro_multibhop = INVALID_HANDLE;
new Float:g_dist_pro_multibhop;
new Handle:g_hdist_leet_multibhop = INVALID_HANDLE;
new Float:g_dist_leet_multibhop;
new Handle:g_hdist_ownage_multibhop = INVALID_HANDLE;
new Float:g_dist_ownage_multibhop;
new Handle:g_hdist_good_lj = INVALID_HANDLE;
new Float:g_dist_good_lj;
new Handle:g_hdist_pro_lj = INVALID_HANDLE;
new Float:g_dist_pro_lj;
new Handle:g_hdist_leet_lj = INVALID_HANDLE;
new Float:g_dist_leet_lj;
new Handle:g_hdist_ownage_lj = INVALID_HANDLE;
new Float:g_dist_ownage_lj;
new Handle: g_ct_jumpstats;


new bool:g_js_bPlayerJumped[MAXPLAYERS+1];
new bool:g_js_bDropJump[MAXPLAYERS+1];
new bool:g_js_bInvalidGround[MAXPLAYERS+1];
new bool:g_js_bBhop[MAXPLAYERS+1];
new bool:g_js_Strafing_AW[MAXPLAYERS+1];
new bool:g_js_Strafing_SD[MAXPLAYERS+1];
new bool:g_bColorChat[MAXPLAYERS+1];
new bool:g_bLJBlock[MAXPLAYERS + 1];
new bool:g_bLjStarDest[MAXPLAYERS + 1];
new bool:g_bInfoPanel[MAXPLAYERS+1];
new bool:g_bStrafeSync[MAXPLAYERS+1];
new bool:g_bLastInvalidGround[MAXPLAYERS+1];
new bool:g_bPrestrafeTooHigh[MAXPLAYERS+1];
new bool:g_bEnableQuakeSounds[MAXPLAYERS+1];
new bool:g_bLJBlockValidJumpoff[MAXPLAYERS + 1];
new bool:g_js_bFuncMoveLinear[MAXPLAYERS+1];
new bool:g_bLastButtonJump[MAXPLAYERS+1];
new bool:g_bdetailView[MAXPLAYERS+1];
new bool:g_bFirstTeamJoin[MAXPLAYERS+1];

new g_iCtJumpstats;
new g_Beam[2];
new g_js_Personal_LjBlock_Record[MAXPLAYERS+1]=-1;
new g_js_BhopRank[MAXPLAYERS+1];
new g_js_MultiBhopRank[MAXPLAYERS+1];
new g_js_LjRank[MAXPLAYERS+1];
new g_js_LjBlockRank[MAXPLAYERS+1];
new g_js_DropBhopRank[MAXPLAYERS+1];
new g_js_WjRank[MAXPLAYERS+1];
new g_js_Sync_Final[MAXPLAYERS+1];
new g_js_GroundFrames[MAXPLAYERS+1];
new g_js_StrafeCount[MAXPLAYERS+1];
new g_js_Strafes_Final[MAXPLAYERS+1];
new g_js_LeetJump_Count[MAXPLAYERS+1];
new g_js_OwnageJump_Count[MAXPLAYERS+1];
new g_js_MultiBhop_Count[MAXPLAYERS+1];
new g_js_Last_Ground_Frames[MAXPLAYERS+1];
new g_LastButton[MAXPLAYERS + 1];
new g_BlockDist[MAXPLAYERS + 1];
new String:g_js_szLastJumpDistance[MAXPLAYERS+1][256];
new Float:g_fLastSpeed[MAXPLAYERS+1];
new Float:g_flastHeight[MAXPLAYERS +1];
new Float:g_fBlockHeight[MAXPLAYERS + 1];
new Float:g_fEdgeVector[MAXPLAYERS + 1][3];
new Float:g_fEdgeDist[MAXPLAYERS + 1];
new Float:g_fEdgePoint[MAXPLAYERS + 1][3];
new Float:g_fOriginBlock[MAXPLAYERS + 1][2][3];
new Float:g_fDestBlock[MAXPLAYERS + 1][2][3];
new Float:g_fLastPosition[MAXPLAYERS + 1][3];
new Float:g_fLastAngles[MAXPLAYERS + 1][3];
new Float:g_fSpeed[MAXPLAYERS+1];
new Float:g_fLastPositionOnGround[MAXPLAYERS+1][3];
new Float:g_fAirTime[MAXPLAYERS+1];
new Float:g_js_fJump_JumpOff_Pos[MAXPLAYERS+1][3];
new Float:g_js_fJump_Landing_Pos[MAXPLAYERS+1][3];
new Float:g_js_fJump_JumpOff_PosLastHeight[MAXPLAYERS+1];
new Float:g_js_fJump_DistanceX[MAXPLAYERS+1];
new Float:g_js_fJump_DistanceZ[MAXPLAYERS+1];
new Float:g_js_fJump_Distance[MAXPLAYERS+1];
new Float:g_js_fPreStrafe[MAXPLAYERS+1];
new Float:g_js_fJumpOff_Time[MAXPLAYERS+1];
new Float:g_js_fDropped_Units[MAXPLAYERS+1];
new Float:g_js_fMax_Speed[MAXPLAYERS+1];
new Float:g_js_fMax_Speed_Final[MAXPLAYERS +1];
new Float:g_js_fMax_Height[MAXPLAYERS+1];
new Float:g_js_fLast_Jump_Time[MAXPLAYERS+1];
new Float:g_js_Good_Sync_Frames[MAXPLAYERS+1];
new Float:g_js_Sync_Frames[MAXPLAYERS+1];
new Float:g_js_Strafe_Good_Sync[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_js_Strafe_Frames[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_js_Strafe_Gained[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_js_Strafe_Max_Speed[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_js_Strafe_Lost[MAXPLAYERS+1][MAX_STRAFES];
new Float:g_js_fPersonal_Wj_Record[MAXPLAYERS+1]=-1.0;
new Float:g_js_fPersonal_DropBhop_Record[MAXPLAYERS+1]=-1.0;
new Float:g_js_fPersonal_Bhop_Record[MAXPLAYERS+1]=-1.0;
new Float:g_js_fPersonal_MultiBhop_Record[MAXPLAYERS+1]=-1.0;
new Float:g_js_fPersonal_Lj_Record[MAXPLAYERS+1]=-1.0;
new Float:g_js_fPersonal_LjBlockRecord_Dist[MAXPLAYERS+1]=-1.0;

// consts
new const String:LEETJUMP_FULL_SOUND_PATH[] = "sound/quake/godlike.mp3";
new const String:LEETJUMP_RELATIVE_SOUND_PATH[] = "*quake/godlike.mp3";
//
new const String:LEETJUMP_RAMPAGE_FULL_SOUND_PATH[] = "sound/quake/rampage.mp3";
new const String:LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH[] = "*quake/rampage.mp3";
//
new const String:LEETJUMP_DOMINATING_FULL_SOUND_PATH[] = "sound/quake/dominating.mp3";
new const String:LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH[] = "*quake/dominating.mp3";
//
new const String:PROJUMP_FULL_SOUND_PATH[] = "sound/quake/perfect.mp3";
new const String:PROJUMP_RELATIVE_SOUND_PATH[] = "*quake/perfect.mp3";
//
new const String:OWNAGEJUMP_FULL_SOUND_PATH[] = "sound/quake/ownage.mp3";
new const String:OWNAGEJUMP_RELATIVE_SOUND_PATH[] = "*quake/ownage.mp3";

//TABLE JUMMPSTATS
new String:sql_createPlayerjumpstats[] 			= "CREATE TABLE IF NOT EXISTS playerjumpstats (steamid VARCHAR(32), name VARCHAR(32), multibhoprecord FLOAT NOT NULL DEFAULT '-1.0',  multibhoppre FLOAT NOT NULL DEFAULT '-1.0', multibhopmax FLOAT NOT NULL DEFAULT '-1.0', multibhopstrafes INT(12),multibhopcount INT(12),multibhopsync INT(12), multibhopheight FLOAT NOT NULL DEFAULT '-1.0', bhoprecord FLOAT NOT NULL DEFAULT '-1.0',  bhoppre FLOAT NOT NULL DEFAULT '-1.0', bhopmax FLOAT NOT NULL DEFAULT '-1.0', bhopstrafes INT(12),bhopsync INT(12), bhopheight FLOAT NOT NULL DEFAULT '-1.0', ljrecord FLOAT NOT NULL DEFAULT '-1.0', ljpre FLOAT NOT NULL DEFAULT '-1.0', ljmax FLOAT NOT NULL DEFAULT '-1.0', ljstrafes INT(12),ljsync INT(12), ljheight FLOAT NOT NULL DEFAULT '-1.0', ljblockdist INT(12) NOT NULL DEFAULT '-1',ljblockrecord FLOAT NOT NULL DEFAULT '-1.0', ljblockpre FLOAT NOT NULL DEFAULT '-1.0', ljblockmax FLOAT NOT NULL DEFAULT '-1.0', ljblockstrafes INT(12),ljblocksync INT(12), ljblockheight FLOAT NOT NULL DEFAULT '-1.0', dropbhoprecord FLOAT NOT NULL DEFAULT '-1.0',  dropbhoppre FLOAT NOT NULL DEFAULT '-1.0', dropbhopmax FLOAT NOT NULL DEFAULT '-1.0', dropbhopstrafes INT(12),dropbhopsync INT(12), dropbhopheight FLOAT NOT NULL DEFAULT '-1.0', wjrecord FLOAT NOT NULL DEFAULT '-1.0', wjpre FLOAT NOT NULL DEFAULT '-1.0', wjmax FLOAT NOT NULL DEFAULT '-1.0', wjstrafes INT(12),wjsync INT(12), wjheight FLOAT NOT NULL DEFAULT '-1.0', standupbhoprecord FLOAT NOT NULL DEFAULT '-1.0',  standupbhoppre FLOAT NOT NULL DEFAULT '-1.0', standupbhopmax FLOAT NOT NULL DEFAULT '-1.0', standupbhopstrafes INT(12),standupbhopcount INT(12),standupbhopsync INT(12), standupbhopheight FLOAT NOT NULL DEFAULT '-1.0', dropstandupbhoprecord FLOAT NOT NULL DEFAULT '-1.0',  dropstandupbhoppre FLOAT NOT NULL DEFAULT '-1.0', dropstandupbhopmax FLOAT NOT NULL DEFAULT '-1.0', dropstandupbhopstrafes INT(12), dropstandupbhopcount INT(12), dropstandupbhopsync INT(12), dropstandupbhopheight FLOAT NOT NULL DEFAULT '-1.0', ladderjumprecord FLOAT NOT NULL DEFAULT '-1.0',  ladderjumppre FLOAT NOT NULL DEFAULT '-1.0', ladderjumpmax FLOAT NOT NULL DEFAULT '-1.0', ladderjumpstrafes INT(12), ladderjumpcount INT(12), ladderjumpsync INT(12), ladderjumpheight FLOAT NOT NULL DEFAULT '-1.0', ladderbhoprecord FLOAT NOT NULL DEFAULT '-1.0',  ladderbhoppre FLOAT NOT NULL DEFAULT '-1.0', ladderbhopmax FLOAT NOT NULL DEFAULT '-1.0', ladderbhopstrafes INT(12), ladderbhopcount INT(12), ladderbhopsync INT(12), ladderbhopheight FLOAT NOT NULL DEFAULT '-1.0',  PRIMARY KEY(steamid));";
new String:sql_insertPlayerJumpBhop[] 			= "INSERT INTO playerjumpstats (steamid, name, bhoprecord, bhoppre, bhopmax, bhopstrafes, bhopsync, bhopheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpLj[] 			= "INSERT INTO playerjumpstats (steamid, name, ljrecord, ljpre, ljmax, ljstrafes, ljsync, ljheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpLjBlock[] 		= "INSERT INTO playerjumpstats (steamid, name, ljblockdist, ljblockrecord, ljblockpre, ljblockmax, ljblockstrafes, ljblocksync, ljblockheight) VALUES('%s', '%s', '%i', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpMultiBhop[] 		= "INSERT INTO playerjumpstats (steamid, name, multibhoprecord, multibhoppre, multibhopmax, multibhopstrafes, multibhopcount, multibhopsync, multibhopheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpDropBhop[] 		= "INSERT INTO playerjumpstats (steamid, name, dropbhoprecord, dropbhoppre, dropbhopmax, dropbhopstrafes, dropbhopsync, dropbhopheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";
new String:sql_insertPlayerJumpWJ[] 			= "INSERT INTO playerjumpstats (steamid, name, wjrecord, wjpre, wjmax, wjstrafes, wjsync, wjheight) VALUES('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%f');";

new String:sql_updateLjBlock[] 					= "UPDATE playerjumpstats SET name='%s', ljblockdist ='%i', ljblockrecord ='%f', ljblockpre ='%f', ljblockmax ='%f', ljblockstrafes='%i', ljblocksync='%i', ljblockheight='%f' WHERE steamid = '%s';";
new String:sql_updateLj[] 						= "UPDATE playerjumpstats SET name='%s', ljrecord ='%f', ljpre ='%f', ljmax ='%f', ljstrafes='%i', ljsync='%i', ljheight='%f' WHERE steamid = '%s';";
new String:sql_updateBhop[] 					= "UPDATE playerjumpstats SET name='%s', bhoprecord ='%f', bhoppre ='%f', bhopmax ='%f', bhopstrafes='%i', bhopsync='%i', bhopheight='%f' WHERE steamid = '%s';";
new String:sql_updateMultiBhop[] 				= "UPDATE playerjumpstats SET name='%s', multibhoprecord ='%f', multibhoppre ='%f', multibhopmax ='%f', multibhopstrafes='%i', multibhopcount='%i', multibhopsync='%i', multibhopheight='%f' WHERE steamid = '%s';";
new String:sql_updateDropBhop[] 				= "UPDATE playerjumpstats SET name='%s', dropbhoprecord ='%f', dropbhoppre ='%f', dropbhopmax ='%f', dropbhopstrafes='%i', dropbhopsync='%i', dropbhopheight='%f' WHERE steamid = '%s';";
new String:sql_updateWJ[] 						= "UPDATE playerjumpstats SET name='%s', wjrecord ='%f', wjpre ='%f', wjmax ='%f', wjstrafes='%i', wjsync='%i', wjheight='%f' WHERE steamid = '%s';";

new String:sql_selectPlayerJumpTopLJBlock[] 	= "SELECT name, ljblockdist, ljblockrecord, ljblockstrafes, steamid FROM playerjumpstats WHERE ljblockdist > -1 ORDER BY ljblockdist DESC, ljblockrecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopLJ[] 			= "SELECT name, ljrecord, ljstrafes, steamid FROM playerjumpstats WHERE ljrecord > -1.0 ORDER BY ljrecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopBhop[] 		= "SELECT name, bhoprecord, bhopstrafes, steamid FROM playerjumpstats WHERE bhoprecord > -1.0 ORDER BY bhoprecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopMultiBhop[] 	= "SELECT name, multibhoprecord, multibhopstrafes, steamid FROM playerjumpstats WHERE multibhoprecord > -1.0 ORDER BY multibhoprecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopDropBhop[] 	= "SELECT name, dropbhoprecord, dropbhopstrafes, steamid FROM playerjumpstats WHERE dropbhoprecord > -1.0 ORDER BY dropbhoprecord DESC LIMIT 20";
new String:sql_selectPlayerJumpTopWJ[] 			= "SELECT name, wjrecord, wjstrafes, steamid FROM playerjumpstats WHERE wjrecord > -1.0 ORDER BY wjrecord DESC LIMIT 20";
new String:sql_selectPlayerJumpLJBlock[] 		= "SELECT steamid, name, ljblockdist, ljblockrecord FROM playerjumpstats WHERE steamid = '%s';";
new String:sql_selectPlayerJumpLJ[] 			= "SELECT steamid, name, ljrecord FROM playerjumpstats WHERE steamid = '%s';";
new String:sql_selectPlayerJumpBhop[] 			= "SELECT steamid, name, bhoprecord FROM playerjumpstats WHERE steamid = '%s';";
new String:sql_selectPlayerJumpMultiBhop[] 		= "SELECT steamid, name, multibhoprecord FROM playerjumpstats WHERE steamid = '%s';";
new String:sql_selectPlayerJumpWJ[] 			= "SELECT steamid, name, wjrecord FROM playerjumpstats WHERE steamid = '%s';";
new String:sql_selectPlayerJumpDropBhop[] 		= "SELECT steamid, name, dropbhoprecord FROM playerjumpstats WHERE steamid = '%s';";
new String:sql_selectJumpStats[] 				= "SELECT steamid, name, bhoprecord,bhoppre,bhopmax,bhopstrafes,bhopsync, ljrecord, ljpre, ljmax, ljstrafes,ljsync, multibhoprecord,multibhoppre, multibhopmax, multibhopstrafes,multibhopcount,multibhopsync, wjrecord, wjpre, wjmax, wjstrafes, wjsync, dropbhoprecord, dropbhoppre, dropbhopmax, dropbhopstrafes, dropbhopsync, ljheight, bhopheight, multibhopheight, dropbhopheight, wjheight,ljblockdist,ljblockrecord, ljblockpre, ljblockmax, ljblockstrafes,ljblocksync, ljblockheight FROM playerjumpstats WHERE (wjrecord > -1.0 OR dropbhoprecord > -1.0 OR ljrecord > -1.0 OR bhoprecord > -1.0 OR multibhoprecord > -1.0) AND steamid = '%s';";
new String:sql_selectPlayerRankMultiBhop[]		= "SELECT name FROM playerjumpstats WHERE multibhoprecord >= (SELECT multibhoprecord FROM playerjumpstats WHERE steamid = '%s' AND multibhoprecord > -1.0) AND multibhoprecord  > -1.0 ORDER BY multibhoprecord;";
new String:sql_selectPlayerRankLj[] 			= "SELECT name FROM playerjumpstats WHERE ljrecord >= (SELECT ljrecord FROM playerjumpstats WHERE steamid = '%s' AND ljrecord > -1.0) AND ljrecord  > -1.0 ORDER BY ljrecord;";
new String:sql_selectPlayerRankLjBlock[] 		= "SELECT name FROM playerjumpstats WHERE ljblockdist >= (SELECT ljblockdist FROM playerjumpstats WHERE steamid = '%s' AND ljblockdist > -1.0) AND ljblockdist  > -1.0 ORDER BY ljblockdist DESC, ljblockrecord DESC;";
new String:sql_selectPlayerRankBhop[] 			= "SELECT name FROM playerjumpstats WHERE bhoprecord >= (SELECT bhoprecord FROM playerjumpstats WHERE steamid = '%s' AND bhoprecord > -1.0) AND bhoprecord  > -1.0 ORDER BY bhoprecord;";
new String:sql_selectPlayerRankWJ[] 			= "SELECT name FROM playerjumpstats WHERE wjrecord >= (SELECT wjrecord FROM playerjumpstats WHERE steamid = '%s' AND wjrecord > -1.0) AND wjrecord  > -1.0 ORDER BY wjrecord;";
new String:sql_selectPlayerRankDropBhop[] 		= "SELECT name FROM playerjumpstats WHERE dropbhoprecord >= (SELECT dropbhoprecord FROM playerjumpstats WHERE steamid = '%s' AND dropbhoprecord > -1.0) AND dropbhoprecord  > -1.0 ORDER BY dropbhoprecord;";
new String:sql_resetBhopRecord[] 				= "UPDATE playerjumpstats SET bhoprecord = '-1.0' WHERE steamid = '%s';";
new String:sql_resetDropBhopRecord[] 			= "UPDATE playerjumpstats SET dropbhoprecord = '-1.0' WHERE steamid = '%s';";
new String:sql_resetWJRecord[] 					= "UPDATE playerjumpstats SET wjrecord = '-1.0' WHERE steamid = '%s';";
new String:sql_resetLjRecord[] 					= "UPDATE playerjumpstats SET ljrecord = '-1.0' WHERE steamid = '%s';";
new String:sql_resetLjBlockRecord[] 			= "UPDATE playerjumpstats SET ljblockdist = '-1' WHERE steamid = '%s';";
new String:sql_resetMultiBhopRecord[] 			= "UPDATE playerjumpstats SET multibhoprecord = '-1.0' WHERE steamid = '%s';";
new String:sql_resetJumpStats[] 				= "UPDATE playerjumpstats SET multibhoprecord = '-1.0', ljrecord = '-1.0', wjrecord = '-1.0', dropbhoprecord = '-1.0', bhoprecord = '-1.0', ljblockdist = '-1' WHERE steamid = '%s';";


public Plugin:myinfo =
{
	name = "KZ JumpStats",
	author = "1NutWunDeR, powerind",
	description = "Modified version of KZJumpStats that has ownages.",
	version = VERSION,
	url = "1.3"
};

public OnPluginStart()
{
	//lanuage file
	LoadTranslations("kzjumpstats.phrases");

	//db setup
	db_setupDatabase();

	//ConVars
	CreateConVar("KZJumpstats_version", VERSION, "KZ Jumpstats Version.", FCVAR_DONTRECORD|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_hdist_good_lj    			= CreateConVar("js_dist_min_lj", "230.0", "Minimum distance for longjumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_pro_lj   			= CreateConVar("js_dist_pro_lj", "245.0", "Minimum distance for longjumps to be considered pro [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 220.0, true, 999.0);
	g_hdist_leet_lj    			= CreateConVar("js_dist_leet_lj", "250.0", "Minimum distance for longjumps to be considered leet [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
	g_hdist_ownage_lj    		= CreateConVar("js_dist_ownage_lj", "280.0", "Minimum distance for longjumps to be considered ownage [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 245.0, true, 999.0);
	g_hdist_good_weird  		= CreateConVar("js_dist_min_wj", "200.0", "Minimum distance for weird jumps to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_pro_weird  			= CreateConVar("js_dist_pro_wj", "260.0", "Minimum distance for weird jumps to be considered pro [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_leet_weird   		= CreateConVar("js_dist_leet_wj", "270.0", "Minimum distance for weird jumps to be considered leet [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_ownage_weird   		= CreateConVar("js_dist_ownage_wj", "290.0", "Minimum distance for weird jumps to be considered ownage [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_good_dropbhop  		= CreateConVar("js_dist_min_dropbhop", "230.0", "Minimum distance for drop bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_pro_dropbhop  		= CreateConVar("js_dist_pro_dropbhop", "260.0", "Minimum distance for drop bhops to be considered pro [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_leet_dropbhop   	= CreateConVar("js_dist_leet_dropbhop", "270.0", "Minimum distance for drop bhops to be considered leet [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_ownage_dropbhop   	= CreateConVar("js_dist_ownage_dropbhop", "290.0", "Minimum distance for drop bhops to be considered ownage [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_good_bhop  			= CreateConVar("js_dist_min_bhop", "240.0", "Minimum distance for bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_pro_bhop  			= CreateConVar("js_dist_pro_bhop", "260.0", "Minimum distance for bhops to be considered pro [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_leet_bhop   		= CreateConVar("js_dist_leet_bhop", "270.0", "Minimum distance for bhops to be considered leet [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_ownage_bhop   		= CreateConVar("js_dist_ownage_bhop", "290.0", "Minimum distance for bhops to be considered ownage [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 999.0);
	g_hdist_good_multibhop  	= CreateConVar("js_dist_min_multibhop", "240.0", "Minimum distance for multi-bhops to be considered good [Client Message]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
	g_hdist_pro_multibhop  		= CreateConVar("js_dist_pro_multibhop", "260.0", "Minimum distance for multi-bhops to be considered pro [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
	g_hdist_leet_multibhop   	= CreateConVar("js_dist_leet_multibhop", "270.0", "Minimum distance for multi-bhops to be considered leet [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
	g_hdist_ownage_multibhop 	= CreateConVar("js_dist_ownage_multibhop", "290.0", "Minimum distance for multi-bhops to be considered ownage [JumpStats Colorchat All]", FCVAR_NOTIFY, true, 200.0, true, 9999.0);
	g_ct_jumpstats				= CreateConVar("js_ct_jumpstats", "0.0", "Disable CT Jumpstats? 1 = Disable 0 = Enable", FCVAR_NOTIFY, true, 1.0, true, 0.0);

	////////////////////////////////////////////////////////////////

	g_dist_good_weird	= GetConVarFloat(g_hdist_good_weird);
	HookConVarChange(g_hdist_good_weird, OnSettingChanged);

	g_dist_pro_weird	= GetConVarFloat(g_hdist_pro_weird);
	HookConVarChange(g_hdist_pro_weird, OnSettingChanged);

	g_dist_leet_weird    = GetConVarFloat(g_hdist_leet_weird);
	HookConVarChange(g_hdist_leet_weird, OnSettingChanged);

	g_dist_ownage_weird    = GetConVarFloat(g_hdist_ownage_weird);
	HookConVarChange(g_hdist_ownage_weird, OnSettingChanged);

	////////////////////////////////////////////////////////////////

	g_dist_good_dropbhop	= GetConVarFloat(g_hdist_good_dropbhop);
	HookConVarChange(g_hdist_good_dropbhop, OnSettingChanged);

	g_dist_pro_dropbhop	= GetConVarFloat(g_hdist_pro_dropbhop);
	HookConVarChange(g_hdist_pro_dropbhop, OnSettingChanged);

	g_dist_leet_dropbhop    = GetConVarFloat(g_hdist_leet_dropbhop);
	HookConVarChange(g_hdist_leet_dropbhop, OnSettingChanged);

	g_dist_ownage_dropbhop    = GetConVarFloat(g_hdist_ownage_dropbhop);
	HookConVarChange(g_hdist_ownage_dropbhop, OnSettingChanged);
	////////////////////////////////////////////////////////////////

	g_dist_good_bhop	= GetConVarFloat(g_hdist_good_bhop);
	HookConVarChange(g_hdist_good_bhop, OnSettingChanged);

	g_dist_pro_bhop	= GetConVarFloat(g_hdist_pro_bhop);
	HookConVarChange(g_hdist_pro_bhop, OnSettingChanged);

	g_dist_leet_bhop    = GetConVarFloat(g_hdist_leet_bhop);
	HookConVarChange(g_hdist_leet_bhop, OnSettingChanged);

	g_dist_ownage_bhop    = GetConVarFloat(g_hdist_ownage_bhop);
	HookConVarChange(g_hdist_ownage_bhop, OnSettingChanged);

	////////////////////////////////////////////////////////////////

	g_dist_good_multibhop	= GetConVarFloat(g_hdist_good_multibhop);
	HookConVarChange(g_hdist_good_multibhop, OnSettingChanged);

	g_dist_pro_multibhop	= GetConVarFloat(g_hdist_pro_multibhop);
	HookConVarChange(g_hdist_pro_multibhop, OnSettingChanged);

	g_dist_leet_multibhop    = GetConVarFloat(g_hdist_leet_multibhop);
	HookConVarChange(g_hdist_leet_multibhop, OnSettingChanged);

	g_dist_ownage_multibhop    = GetConVarFloat(g_hdist_ownage_multibhop);
	HookConVarChange(g_hdist_ownage_multibhop, OnSettingChanged);

	////////////////////////////////////////////////////////////////

	g_dist_good_lj      = GetConVarFloat(g_hdist_good_lj);
	HookConVarChange(g_hdist_good_lj, OnSettingChanged);

	g_dist_pro_lj      = GetConVarFloat(g_hdist_pro_lj);
	HookConVarChange(g_hdist_pro_lj, OnSettingChanged);

	g_dist_leet_lj      = GetConVarFloat(g_hdist_leet_lj);
	HookConVarChange(g_hdist_leet_lj, OnSettingChanged);

	g_dist_ownage_lj      = GetConVarFloat(g_hdist_ownage_lj);
	HookConVarChange(g_hdist_ownage_lj, OnSettingChanged);

	////////////////////////////////////////////////////////////////
	
	g_iCtJumpstats			= GetConVarInt(g_ct_jumpstats);
	HookConVarChange(g_ct_jumpstats, OnSettingChanged);
	
	////////////////////////////////////////////////////////////////

	//config
	AutoExecConfig(true, "KZJumpStats");

	//commands
	RegConsoleCmd("sm_showkeys", Client_InfoPanel, "on/off speed/showkeys center panel");
	RegConsoleCmd("sm_speed", Client_InfoPanel, "on/off speed/showkeys center panel");
	RegConsoleCmd("sm_sync", Client_StrafeSync,"on/off strafe sync in chat");
	RegConsoleCmd("sm_stats", Client_Stats,"on/off strafe sync in chat");
	RegConsoleCmd("sm_sound", Client_QuakeSounds,"on/off quake sounds");
	RegConsoleCmd("sm_ljblock", Client_Ljblock,"registers a lj block");
	RegConsoleCmd("sm_colorchat", Client_Colorchat, "on/off jumpstats messages of others in chat");
	RegConsoleCmd("sm_jumptop", Client_Top, "jump top");
	RegAdminCmd("sm_resetjumpstats", Admin_DropPlayerJump, ADMIN_LEVEL, "[JS] Resets jump stats - requires z flag");
	RegAdminCmd("sm_resetallljrecords", Admin_ResetAllLjRecords, ADMIN_LEVEL, "[JS] Resets all lj records - requires z flag");
	RegAdminCmd("sm_resetallljblockrecords", Admin_ResetAllLjBlockRecords, ADMIN_LEVEL, "[JS] Resets all lj block records - requires z flag");
	RegAdminCmd("sm_resetallwjrecords", Admin_ResetAllWjRecords, ADMIN_LEVEL, "[JS] Resets all wj records - requires z flag");
	RegAdminCmd("sm_resetallbhoprecords", Admin_ResetAllBhopRecords, ADMIN_LEVEL, "[JS] Resets all bhop records - requires z flag");
	RegAdminCmd("sm_resetalldropbhopecords", Admin_ResetAllDropBhopRecords, ADMIN_LEVEL, "[JS] Resets all drop bjop records - requires z flag");
	RegAdminCmd("sm_resetallmultibhoprecords", Admin_ResetAllMultiBhopRecords, ADMIN_LEVEL, "[JS] Resets all multi bhop records - requires z flag");
	RegAdminCmd("sm_resetljrecord", Admin_ResetLjRecords, ADMIN_LEVEL, "[JS] Resets lj record for given steamid - requires z flag");
	RegAdminCmd("sm_resetljblockrecord", Admin_ResetLjBlockRecords, ADMIN_LEVEL, "[JS] Resets lj block record for given steamid - requires z flag");
	RegAdminCmd("sm_resetbhoprecord", Admin_ResetBhopRecords, ADMIN_LEVEL, "[JS] Resets bhop record for given steamid - requires z flag");
	RegAdminCmd("sm_resetdropbhoprecord", Admin_ResetDropBhopRecords, ADMIN_LEVEL, "[JS] Resets drop bhop record for given steamid - requires z flag");
	RegAdminCmd("sm_resetwjrecord", Admin_ResetWjRecords, ADMIN_LEVEL, "[JS] Resets wj record for given steamid - requires z flag");
	RegAdminCmd("sm_resetmultibhoprecord", Admin_ResetMultiBhopRecords, ADMIN_LEVEL, "[JS] Resets multi bhop record for given steamid - requires z flag");
	RegAdminCmd("sm_resetplayerjumpstats", Admin_ResetPlayerJumpstats, ADMIN_LEVEL, "[JS] Resets jump stats for given steamid - requires z flag");

	//Hooks
	HookEvent("player_jump", Event_OnJump, EventHookMode_Pre);
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);

	//plugin loaded?
	for(new z=1;z<=MaxClients;z++)
			OnClientPutInServer(z);
}

public OnMapStart()
{
	//timers
	CreateTimer(0.1, Timer1, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	InitPrecache();

	new ent = -1;
	SDKHook(0,SDKHook_Touch,Touch_Wall);
	while((ent = FindEntityByClassname(ent,"func_breakable")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_illusionary")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_wall")) != -1)
		SDKHook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_push")) != -1)
		SDKHook(ent,SDKHook_Touch,Push_Touch);

}

public OnMapEnd()
{
	new ent = -1;
	SDKUnhook(0,SDKHook_Touch,Touch_Wall);
	while((ent = FindEntityByClassname(ent,"func_breakable")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_illusionary")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent,"func_wall")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Touch_Wall);
	ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_push")) != -1)
		SDKUnhook(ent,SDKHook_Touch,Push_Touch);
}


public OnClientPutInServer(client)
{
	if (!IsValidEntity(client) || IsFakeClient(client) || !IsClientInGame(client))
		return;

	SDKHook(client, SDKHook_StartTouch, Hook_OnTouch);

	g_bdetailView[client] = false;
	g_bFirstTeamJoin[client] = true;
	g_js_bPlayerJumped[client] = false;
	g_bPrestrafeTooHigh[client] = false;
	g_js_bFuncMoveLinear[client] = false;
	g_bInfoPanel[client] = true;
	g_js_Last_Ground_Frames[client] = 11;
	g_js_MultiBhop_Count[client] = 1;
	g_js_GroundFrames[client] = 0;
	g_js_fJump_JumpOff_PosLastHeight[client] = -1.012345;
	g_js_Good_Sync_Frames[client] = 0.0;
	g_js_Sync_Frames[client] = 0.0;
	g_js_LeetJump_Count[client] = 0;
	g_bEnableQuakeSounds[client]=true;
	g_bColorChat[client]=true;
	Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>0.0 units</font>");

	// set default values
	for( new i = 0; i < MAX_STRAFES; i++ )
	{
		g_js_Strafe_Good_Sync[client][i] = 0.0;
		g_js_Strafe_Frames[client][i] = 0.0;
	}

	decl String:szSteamId[32];
	GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	db_viewPersonalBhopRecord(client, szSteamId);
	db_viewPersonalMultiBhopRecord(client, szSteamId);
	db_viewPersonalWeirdRecord(client, szSteamId);
	db_viewPersonalDropBhopRecord(client, szSteamId);
	db_viewPersonalLJBlockRecord(client, szSteamId);
	db_viewPersonalLJRecord(client, szSteamId);
}

public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client != 0 && g_bFirstTeamJoin[client])
	{
		CreateTimer(15.0, AdvertTimer, client,TIMER_FLAG_NO_MAPCHANGE);
		g_bFirstTeamJoin[client] = false;
	}
}

public Action:AdvertTimer(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		PrintToChat(client, "This server is using %cKZTimer Jumpstats by %cpowerind", GRAY, YELLOW);
}

public Hook_OnTouch(client, other)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new String:classname[32];
		if (IsValidEdict(other))
			GetEntityClassname(other, classname, 32);
		if (StrEqual(classname,"func_movelinear"))
		{
			g_js_bFuncMoveLinear[client] = true;
			return;
		}
		if (!(GetEntityFlags(client) & FL_ONGROUND) || other != 0)
			ResetJump(client);
	}
}

public db_setupDatabase()
{
	decl String:szError[255];
	g_hDb = SQL_Connect("kzjumpstats", false, szError, 255);

	if(g_hDb == INVALID_HANDLE)
	{
		SetFailState("[kzjumspstats] Unable to connect to database (%s)",szError);
		return;
	}

	decl String:szIdent[8];
	SQL_ReadDriver(g_hDb, szIdent, 8);

	SQL_FastQuery(g_hDb,"SET NAMES  'utf8'");
	db_createTables();
}


public db_createTables()
{
	SQL_LockDatabase(g_hDb);
	SQL_FastQuery(g_hDb, sql_createPlayerjumpstats);
	SQL_UnlockDatabase(g_hDb);
}

public InitPrecache()
{
	AddFileToDownloadsTable( LEETJUMP_FULL_SOUND_PATH );
	FakePrecacheSound( LEETJUMP_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( OWNAGEJUMP_FULL_SOUND_PATH );
	FakePrecacheSound( OWNAGEJUMP_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( LEETJUMP_DOMINATING_FULL_SOUND_PATH );
	FakePrecacheSound( LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( LEETJUMP_RAMPAGE_FULL_SOUND_PATH );
	FakePrecacheSound( LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH );
	AddFileToDownloadsTable( PROJUMP_FULL_SOUND_PATH );
	FakePrecacheSound( PROJUMP_RELATIVE_SOUND_PATH );
	g_Beam[0] = PrecacheModel("materials/sprites/laser.vmt");
	g_Beam[1] = PrecacheModel("materials/sprites/halo01.vmt");
}

stock bool:IsValidClient(client)
{
    if(client >= 1 && client <= MaxClients && IsValidEntity(client) && IsClientConnected(client) && IsClientInGame(client))
        return true;
    return false;
}

public Action:Push_Touch(ent,client)
{
	if(IsValidClient(client) && g_js_bPlayerJumped[client])
	{
		ResetJump(client);
	}
	return Plugin_Continue;
}

public Action:Touch_Wall(ent,client)
{
	if(IsValidClient(client))
	{
		if(!(GetEntityFlags(client)&FL_ONGROUND)  && g_js_bPlayerJumped[client])
		{
			new Float:origin[3], Float:temp[3];
			GetGroundOrigin(client, origin);
			GetClientAbsOrigin(client, temp);
			if(temp[2] - origin[2] <= 0.2)
			{
				ResetJump(client);
			}
		}
	}
	return Plugin_Continue;
}

///////////////////////////////////////////////////////////////

public OnSettingChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(convar == g_hdist_good_multibhop)
		g_dist_good_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_pro_multibhop)
		g_dist_pro_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_leet_multibhop)
		g_dist_leet_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_ownage_multibhop)
		g_dist_ownage_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_bhop)
		g_dist_good_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_pro_bhop)
		g_dist_pro_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_leet_bhop)
		g_dist_leet_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_ownage_bhop)
		g_dist_ownage_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_dropbhop)
		g_dist_good_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_pro_dropbhop)
		g_dist_pro_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_leet_dropbhop)
		g_dist_leet_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_ownage_dropbhop)
		g_dist_ownage_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_weird)
		g_dist_good_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_pro_weird)
		g_dist_pro_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_leet_weird)
		g_dist_leet_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_ownage_weird)
		g_dist_ownage_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_lj)
		g_dist_good_lj = StringToFloat(newValue[0]);

	if(convar == g_hdist_pro_lj)
		g_dist_pro_lj = StringToFloat(newValue[0]);

	if(convar == g_hdist_leet_lj)
		g_dist_leet_lj = StringToFloat(newValue[0]);

	if(convar == g_hdist_ownage_lj)
		g_dist_ownage_lj = StringToFloat(newValue[0]);
		
	if(convar == g_ct_jumpstats)
		g_iCtJumpstats = StringToInt(newValue[0]);

///////////////////////////////////////////////////////////////

}

public Action:Event_OnJump(Handle:event, const String:Name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_fAirTime[client] =  GetEngineTime()
	new bool:touchwall = WallCheck(client);
	if (!touchwall)
		Prethink(client, Float:{0.0,0.0,0.0},0.0);
}

public Action:BhopCheck(Handle:timer, any:client)
{
	if (!g_js_bBhop[client])
		g_js_LeetJump_Count[client] = 0;
}

public Float:GetSpeed(client)
{
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	new Float:speed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
	return speed;
}


public Float:GetVelocity(client)
{
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	new Float:speed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0)+Pow(fVelocity[2],2.0));
	return speed;
}


// OnPlayerRunCmd
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	new Float: origin[3],Float:ang[3];
	if (!IsValidClient(client))
		return Plugin_Continue;

	//some methods..
	if(IsPlayerAlive(client))
	{
		GetClientAbsOrigin(client, origin);
		GetClientEyeAngles(client, ang);
		new Float:flSpeed = GetSpeed(client);

		if (g_js_bPlayerJumped[client] == false && GetEntityFlags(client) & FL_ONGROUND && ((buttons & IN_MOVERIGHT) || (buttons & IN_MOVELEFT) || (buttons & IN_BACK) || (buttons & IN_FORWARD)))
			g_js_GroundFrames[client]++;

		//get player speed
		g_fSpeed[client] = GetSpeed(client);

		//jumpstats/timer
		NoClipCheck(client);
		WaterCheck(client);
		GravityCheck(client);
		BoosterCheck(client);
		WjJumpPreCheck(client,buttons);
		CalcJumpMaxSpeed(client, flSpeed);
		CalcJumpHeight(client);
		CalcJumpSync(client, flSpeed, ang[1], buttons);
		CalcLastJumpHeight(client, buttons, origin);

	//ljblock
		if (g_js_bPlayerJumped[client] == false && GetEntityFlags(client) & FL_ONGROUND && ((buttons & IN_JUMP)))
		{
			decl Float:temp[3], Float: pos[3];
			GetClientAbsOrigin(client,pos);
			g_bLJBlockValidJumpoff[client]=false;
			if(g_bLJBlock[client])
			{
				g_bLJBlockValidJumpoff[client]=true;
				g_bLjStarDest[client]=false;
				GetEdgeOrigin(client, origin, temp);
				g_fEdgeDist[client] = GetVectorDistance(temp, origin);
				if(!IsCoordInBlockPoint(pos,g_fOriginBlock[client],false))
					if(IsCoordInBlockPoint(pos,g_fDestBlock[client],false))
					{
						g_bLjStarDest[client]=true;
					}
					else
						g_bLJBlockValidJumpoff[client]=false;
			}
		}
		if(g_bLJBlock[client])
		{
			TE_SendBlockPoint(client, g_fDestBlock[client][0], g_fDestBlock[client][1], g_Beam[0]);
			TE_SendBlockPoint(client, g_fOriginBlock[client][0], g_fOriginBlock[client][1], g_Beam[0]);
		}
	}

	// postthink jumpstats (landing)
	if(GetEntityFlags(client) & FL_ONGROUND && !g_js_bInvalidGround[client] && !g_bLastInvalidGround[client] && g_js_bPlayerJumped[client] == true && weapon != -1 && IsValidEntity(weapon) && GetEntProp(client, Prop_Data, "m_nWaterLevel") < 1)
	{
		GetGroundOrigin(client, g_js_fJump_Landing_Pos[client]);
		g_fAirTime[client] = GetEngineTime() - g_fAirTime[client];
		Postthink(client);
	}

	//reset/save current values
	if (GetEntityFlags(client) & FL_ONGROUND)
	{
		g_fLastPositionOnGround[client] = origin;
		g_bLastInvalidGround[client] = g_js_bInvalidGround[client];
	}

	if (!(GetEntityFlags(client) & FL_ONGROUND) && g_js_bPlayerJumped[client] == false)
		g_js_GroundFrames[client] = 0;

	g_fLastAngles[client] = ang;
	g_fLastSpeed[client] = g_fSpeed[client];
	g_fLastPosition[client] = origin;
	g_LastButton[client] = buttons;
	return Plugin_Continue;
}

public CalcJumpMaxSpeed(client, Float: fspeed)
{
	if (g_js_bPlayerJumped[client])
		if (g_fLastSpeed[client] <= fspeed)
			g_js_fMax_Speed[client] = fspeed;
}

public CalcJumpHeight(client)
{
	if (g_js_bPlayerJumped[client])
	{
		new Float:height[3];
		GetClientAbsOrigin(client, height);
		if (height[2] > g_js_fMax_Height[client])
			g_js_fMax_Height[client] = height[2];
		g_flastHeight[client] = height[2];
	}
}

public CalcLastJumpHeight(client, &buttons, Float: origin[3])
{
	if(GetEntityFlags(client) & FL_ONGROUND && g_js_bPlayerJumped[client] == false && g_js_GroundFrames[client] > 11)
	{
		decl Float:flPos[3];
		GetClientAbsOrigin(client, flPos);
		g_js_fJump_JumpOff_PosLastHeight[client] = flPos[2];
	}
	new Float:distance = GetVectorDistance(g_fLastPosition[client], origin);
	if(distance > 25.0)
	{
		if(g_js_bPlayerJumped[client])
			g_js_bPlayerJumped[client] = false;
	}
}

public CalcJumpSync(client, Float: speed, Float: ang, &buttons)
{
	if (g_js_bPlayerJumped[client])
	{
		new bool: turning_right = false;
		new bool: turning_left = false;

		if( ang < g_fLastAngles[client][1])
			turning_right = true;
		else
			if( ang > g_fLastAngles[client][1])
				turning_left = true;

		//strafestats
		if(turning_left || turning_right)
		{
			if( !g_js_Strafing_AW[client] && ((buttons & IN_FORWARD) || (buttons & IN_MOVELEFT)) && !(buttons & IN_MOVERIGHT) && !(buttons & IN_BACK) )
			{
				g_js_Strafing_AW[client] = true;
				g_js_Strafing_SD[client] = false;
				g_js_StrafeCount[client]++;
				g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client]-1] = 0.0;
				g_js_Strafe_Frames[client][g_js_StrafeCount[client]-1] = 0.0;
				g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] = speed;
			}
			else if( !g_js_Strafing_SD[client] && ((buttons & IN_BACK) || (buttons & IN_MOVERIGHT)) && !(buttons & IN_MOVELEFT) && !(buttons & IN_FORWARD) )
			{
				g_js_Strafing_AW[client] = false;
				g_js_Strafing_SD[client] = true;
				g_js_StrafeCount[client]++;
				g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client]-1] = 0.0;
				g_js_Strafe_Frames[client][g_js_StrafeCount[client]-1] = 0.0;
				g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] = speed;
			}
		}
		//sync
		if( g_fLastSpeed[client] < speed )
		{
			g_js_Good_Sync_Frames[client]++;
			if( 0 < g_js_StrafeCount[client] <= MAX_STRAFES )
			{
				g_js_Strafe_Good_Sync[client][g_js_StrafeCount[client] - 1]++;
				g_js_Strafe_Gained[client][g_js_StrafeCount[client] - 1] += (speed - g_fLastSpeed[client]);
			}
		}
		else
			if( g_fLastSpeed[client] > speed )
			{
				if( 0 < g_js_StrafeCount[client] <= MAX_STRAFES )
					g_js_Strafe_Lost[client][g_js_StrafeCount[client] - 1] += (g_fLastSpeed[client] - speed);
			}

		//strafe frames
		if( 0 < g_js_StrafeCount[client] <= MAX_STRAFES )
		{
			g_js_Strafe_Frames[client][g_js_StrafeCount[client] - 1]++;
			if( g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] < speed )
				g_js_Strafe_Max_Speed[client][g_js_StrafeCount[client] - 1] = speed;
		}
		//total frames
		g_js_Sync_Frames[client]++;
	}
}

public WjJumpPreCheck(client, &buttons)
{
	if(GetEntityFlags(client) & FL_ONGROUND && g_js_bPlayerJumped[client] == false && g_js_GroundFrames[client] > 11)
	{
		if (buttons & IN_JUMP)
			g_bLastButtonJump[client] = true;
		else
			g_bLastButtonJump[client] = false;
	}
}

public BoosterCheck(client)
{
	new Float:flbaseVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", flbaseVelocity);
	if (flbaseVelocity[0] != 0.0 || flbaseVelocity[1] != 0.0 || flbaseVelocity[2] != 0.0 && g_js_bPlayerJumped[client])
		ResetJump(client);
}

public WaterCheck(client)
{
	if (GetEntProp(client, Prop_Data, "m_nWaterLevel") > 0 && g_js_bPlayerJumped[client])
		ResetJump(client);
}

public SurfCheck(client)
{
	if (g_js_bPlayerJumped[client] && WallCheck(client))
	{
		ResetJump(client);
	}
}

public NoClipCheck(client)
{
	new MoveType:mt = GetEntityMoveType(client);
	if(mt == MOVETYPE_NOCLIP && (g_js_bPlayerJumped[client]))
	{
		if (g_js_bPlayerJumped[client])
			ResetJump(client);
	}
}

public ResetJump(client)
{
	Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>", g_js_fJump_Distance[client]);
	g_js_GroundFrames[client] = 0;
	g_js_bPlayerJumped[client] = false;
}

public bool:WallCheck(client)
{
	decl Float:pos[3];
	decl Float:endpos[3];
	decl Float:angs[3];
	decl Float:vecs[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, angs);
	GetAngleVectors(angs, vecs, NULL_VECTOR, NULL_VECTOR);
	angs[1] = -180.0;
	while (angs[1] != 180.0)
	{
		new Handle:trace = TR_TraceRayFilterEx(pos, angs, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

		if(TR_DidHit(trace))
		{
				TR_GetEndPosition(endpos, trace);
				new Float: fdist = GetVectorDistance(endpos, pos, false);
				if (fdist <= 25.0)
				{
					CloseHandle(trace);
					return true;
				}
		}
		CloseHandle(trace);
		angs[1]+=15.0;
	}
	return false;
}

public bool:TraceFilterPlayers(entity,contentsMask)
{
	return (entity > MaxClients) ? true : false;
}

stock GetGroundOrigin(client, Float:pos[3])
{
	new Float:fOrigin[3], Float:result[3];
	GetClientAbsOrigin(client, fOrigin);
	TraceClientGroundOrigin(client, result, 100.0);
	pos = fOrigin;
	pos[2] = result[2];
}

stock TraceClientGroundOrigin(client, Float:result[3], Float:offset)
{
	new Float:temp[2][3];
	GetClientEyePosition(client, temp[0]);
	temp[1] = temp[0];
	temp[1][2] -= offset;
	new Float:mins[]={-16.0, -16.0, 0.0};
	new Float:maxs[]={16.0, 16.0, 60.0};
	new Handle:trace = TR_TraceHullFilterEx(temp[0], temp[1], mins, maxs, MASK_SHOT, TraceEntityFilterPlayer);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
    return entity > MaxClients;
}

public GravityCheck(client)
{
	new Float:flGravity = GetEntityGravity(client);
	if ((flGravity != 0.0 && flGravity !=1.0) && g_js_bPlayerJumped[client])
		ResetJump(client);
}


public CenterHudAlive(client)
{
	if (!IsValidClient(client))
		return;

	if (g_bInfoPanel[client])
	{
		decl String:sResult[256];
		new Buttons;
		Buttons = g_LastButton[client];
		if (Buttons & IN_MOVELEFT)
			Format(sResult, sizeof(sResult), "<b>Keys</b>: A");
		else
			Format(sResult, sizeof(sResult), "<b>Keys</b>: _");
		if (Buttons & IN_FORWARD)
			Format(sResult, sizeof(sResult), "%s W", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);
		if (Buttons & IN_BACK)
			Format(sResult, sizeof(sResult), "%s S", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);
		if (Buttons & IN_MOVERIGHT)
			Format(sResult, sizeof(sResult), "%s D", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);
		if (Buttons & IN_DUCK)
			Format(sResult, sizeof(sResult), "%s - DUCK", sResult);
		else
			Format(sResult, sizeof(sResult), "%s - _", sResult);
		if (Buttons & IN_JUMP)
			Format(sResult, sizeof(sResult), "%s JUMP", sResult);
		else
			Format(sResult, sizeof(sResult), "%s _", sResult);

		if (IsValidEntity(client) && 1 <= client <= MaxClients)
			PrintHintText(client,"<pre><font color='#948d8d'><b>Last Jump</b>: %s\n<b>Speed</b>: %.1f u/s (%.0f)\n%s</font></pre>",g_js_szLastJumpDistance[client],g_fSpeed[client],g_js_fPreStrafe[client],sResult);
	}
}

public Action:Timer1(Handle:timer)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client))
		{
			CenterHudAlive(client)
			SurfCheck(client);
		}
	}
	return Plugin_Continue;
}

stock TraceClientViewEntity(client)
{
	new Float:m_vecOrigin[3];
	new Float:m_angRotation[3];
	GetClientEyePosition(client, m_vecOrigin);
	GetClientEyeAngles(client, m_angRotation);
	new Handle:tr = TR_TraceRayFilterEx(m_vecOrigin, m_angRotation, MASK_VISIBLE, RayType_Infinite, TRDontHitSelf, client);
	new pEntity = -1;
	if (TR_DidHit(tr))
	{
		pEntity = TR_GetEntityIndex(tr);
		CloseHandle(tr);
		return pEntity;
	}
	CloseHandle(tr);
	return -1;
}

public bool:TRDontHitSelf(entity, mask, any:data)
{
	if (entity == data)
		return false;
	return true;
}

public Function_BlockJump(client)
{
	decl Float:pos[3], Float:origin[3];
	GetAimOrigin(client, pos);
	TraceClientGroundOrigin(client, origin, 100.0);
	new bool:funclinear;
	//get aim target
	new String:classname[32];
	new target = TraceClientViewEntity(client);
	if (IsValidEdict(target))
		GetEntityClassname(target, classname, 32);
	if (StrEqual(classname,"func_movelinear"))
		funclinear=true;

	if((FloatAbs(pos[2] - origin[2]) <= 0.002) || (funclinear && FloatAbs(pos[2] - origin[2]) <= 0.6))
	{
		GetBoxFromPoint(origin, g_fOriginBlock[client]);
		GetBoxFromPoint(pos, g_fDestBlock[client]);
		CalculateBlockGap(client, origin, pos);
		g_fBlockHeight[client] = pos[2];
	}
	else
	{
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock1",MOSSGREEN,WHITE,RED);
	}
}

stock TE_SendBlockPoint(client, const Float:pos1[3], const Float:pos2[3], model)
{
	new Float:buffer[4][3];
	buffer[2] = pos1;
	buffer[3] = pos2;
	buffer[0] = buffer[2];
	buffer[0][1] = buffer[3][1];
	buffer[1] = buffer[3];
	buffer[1][1] = buffer[2][1];
	decl randco[4];
	randco[0] = GetRandomInt(0, 255);
	randco[1] = GetRandomInt(0, 255);
	randco[2] = GetRandomInt(0, 255);
	randco[3] = GetRandomInt(125, 255);
	TE_SetupBeamPoints(buffer[3], buffer[0], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[0], buffer[2], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[2], buffer[1], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[1], buffer[3], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
}

GetEdgeOrigin(client, Float:ground[3], Float:result[3])
{
	result[0] = (g_fEdgeVector[client][0]*ground[0] + g_fEdgeVector[client][1]*g_fEdgePoint[client][0])/(g_fEdgeVector[client][0]+g_fEdgeVector[client][1]);
	result[1] = (g_fEdgeVector[client][1]*ground[1] - g_fEdgeVector[client][0]*g_fEdgePoint[client][1])/(g_fEdgeVector[client][1]-g_fEdgeVector[client][0]);
	result[2] = ground[2];
}


stock TraceWallOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

stock TraceGroundOrigin(Float:fOrigin[3], Float:result[3])
{
	new Float:vAngles[3] = {90.0, 0.0, 0.0};
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

stock GetBeamEndOrigin(Float:fOrigin[3], Float:vAngles[3], Float:distance, Float:result[3])
{
	decl Float:AngleVector[3];
	GetAngleVectors(vAngles, AngleVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(AngleVector, AngleVector);
	ScaleVector(AngleVector, distance);
	AddVectors(fOrigin, AngleVector, result);
}

stock GetBeamHitOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    if(TR_DidHit(trace))
    {
        TR_GetEndPosition(result, trace);
        CloseHandle(trace);
    }
}

stock GetAimOrigin(client, Float:hOrigin[3])
{
    new Float:vAngles[3], Float:fOrigin[3];
    GetClientEyePosition(client,fOrigin);
    GetClientEyeAngles(client, vAngles);

    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

    if(TR_DidHit(trace))
    {
        TR_GetEndPosition(hOrigin, trace);
        CloseHandle(trace);
        return 1;
    }

    CloseHandle(trace);
    return 0;
}

stock GetBoxFromPoint(Float:origin[3], Float:result[2][3])
{
	decl Float:temp[3];
	temp = origin;
	temp[2] += 1.0;
	new Float:ang[4][3];
	ang[1][1] = 90.0;
	ang[2][1] = 180.0;
	ang[3][1] = -90.0;
	new bool:edgefound[4];
	new Float:dist[4];
	decl Float:tempdist[4], Float:position[3], Float:ground[3], Float:Last[4], Float:Edge[4][3];
	for(new i = 0; i < 4; i++)
	{
		TraceWallOrigin(temp, ang[i], Edge[i]);
		tempdist[i] = GetVectorDistance(temp, Edge[i]);
		Last[i] = origin[2];
		while(dist[i] < tempdist[i])
		{
			if(edgefound[i])
				break;
			GetBeamEndOrigin(temp, ang[i], dist[i], position);
			TraceGroundOrigin(position, ground);
			if((Last[i] != ground[2])&&(Last[i] > ground[2]))
			{
				Edge[i] = ground;
				edgefound[i] = true;
			}
			Last[i] = ground[2];
			dist[i] += 10.0;
		}
		if(!edgefound[i])
		{
			TraceGroundOrigin(Edge[i], Edge[i]);
			edgefound[i] = true;
		}
		else
		{
			ground = Edge[i];
			ground[2] = origin[2];
			MakeVectorFromPoints(ground, origin, position);
			GetVectorAngles(position, ang[i]);
			ground[2] -= 1.0;
			GetBeamHitOrigin(ground, ang[i], Edge[i]);
		}
		Edge[i][2] = origin[2];
	}
	if(edgefound[0]&&edgefound[1]&&edgefound[2]&&edgefound[3])
	{
		result[0][2] = origin[2];
		result[1][2] = origin[2];
		result[0][0] = Edge[0][0];
		result[0][1] = Edge[1][1];
		result[1][0] = Edge[2][0];
		result[1][1] = Edge[3][1];
	}
}

CalculateBlockGap(client, Float:origin[3], Float:target[3])
{
	new Float:distance = GetVectorDistance(origin, target);
	new Float:rad = DegToRad(15.0);
	new Float:newdistance = distance/Cosine(rad);
	decl Float:eye[3], Float:eyeangle[2][3];
	new Float:temp = 0.0;
	GetClientEyePosition(client, eye);
	GetClientEyeAngles(client, eyeangle[0]);
	eyeangle[0][0] = 0.0;
	eyeangle[1] = eyeangle[0];
	eyeangle[0][1] += 10.0;
	eyeangle[1][1] -= 10.0;
	decl Float:position[3], Float:ground[3], Float:Last[2], Float:Edge[2][3];
	new bool:edgefound[2];
	while(temp < newdistance)
	{
		temp += 10.0;
		for(new i = 0; i < 2 ; i++)
		{
			if(edgefound[i])
				continue;
			GetBeamEndOrigin(eye, eyeangle[i], temp, position);
			TraceGroundOrigin(position, ground);
			if(temp == 10.0)
			{
				Last[i] = ground[2];
			}
			else
			{
				if((Last[i] != ground[2])&&(Last[i] > ground[2]))
				{
					Edge[i] = ground;
					edgefound[i] = true;
				}
				Last[i] = ground[2];
			}
		}
	}
	decl Float:temp2[2][3];
	if(edgefound[0] && edgefound[1])
	{
		for(new i = 0; i < 2 ; i++)
		{
			temp2[i] = Edge[i];
			temp2[i][2] = origin[2] - 1.0;
			if(eyeangle[i][1] > 0)
			{
				eyeangle[i][1] -= 180.0;
			}
			else
			{
				eyeangle[i][1] += 180.0;
			}
			GetBeamHitOrigin(temp2[i], eyeangle[i], Edge[i]);
		}
	}
	else
	{
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock2",MOSSGREEN,WHITE,RED);
		return;
	}



	g_fEdgePoint[client] = Edge[0];
	MakeVectorFromPoints(Edge[0], Edge[1], position);
	g_fEdgeVector[client] = position;
	NormalizeVector(g_fEdgeVector[client], g_fEdgeVector[client]);
	CorrectEdgePoint(client);
	GetVectorAngles(position, position);
	position[1] += 90.0;
	GetBeamHitOrigin(Edge[0], position, Edge[1]);
	distance = GetVectorDistance(Edge[0], Edge[1]);
	g_BlockDist[client] = RoundToNearest(distance);


	new Float:surface = GetVectorDistance(g_fDestBlock[client][0],g_fDestBlock[client][1]);
	surface *= surface;
	if (surface > 1000000)
	{
		PrintToChat(client, "%t", "LJblock3",MOSSGREEN,WHITE,RED);
		return;
	}


	if(!IsCoordInBlockPoint(Edge[1],g_fDestBlock[client],true))
	{
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock4",MOSSGREEN,WHITE,RED);
		return;
	}
	TE_SetupBeamPoints(Edge[0], Edge[1], g_Beam[0], 0, 0, 0, 1.0, 1.0, 1.0, 10, 0.0, {0,255,255,155}, 0);
	TE_SendToClient(client);

	if(g_BlockDist[client] > 225 && g_BlockDist[client] <= 300)
	{
		PrintToChat(client, "%t", "LJblock5", MOSSGREEN,WHITE, LIMEGREEN,GREEN, g_BlockDist[client],LIMEGREEN);
		g_bLJBlock[client] = true;
	}
	else
	{
		if (g_BlockDist[client] < 225)
			PrintToChat(client, "%t", "LJblock6", MOSSGREEN,WHITE, RED,DARKRED,g_BlockDist[client],RED);
		else
			if (g_BlockDist[client] > 300)
				PrintToChat(client, "%t", "LJblock7", MOSSGREEN,WHITE, RED,DARKRED,g_BlockDist[client],RED);
	}
}

stock bool:IsCoordInBlockPoint(const Float:origin[3], const Float:pos[2][3], bool:ignorez)
{
	new bool:bX, bool:bY, bool:bZ;
	decl Float:temp[2][3];
	temp[0] = pos[0];
	temp[1] = pos[1];
	temp[0][0] += 16.0;
	temp[0][1] += 16.0;
	temp[1][0] -= 16.0;
	temp[1][1] -= 16.0;
	if (ignorez)
		bZ=true;

	if(temp[0][0] > temp[1][0])
	{
		if(temp[0][0] >= origin[0] >= temp[1][0])
		{
			bX = true;
		}
	}
	else
	{
		if(temp[1][0] >= origin[0] >= temp[0][0])
		{
			bX = true;
		}
	}
	if(temp[0][1] > temp[1][1])
	{
		if(temp[0][1] >= origin[1] >= temp[1][1])
		{
			bY = true;
		}
	}
	else
	{
		if(temp[1][1] >= origin[1] >= temp[0][1])
		{
			bY = true;
		}
	}
	if(temp[0][2] + 0.002 >= origin[2] >= temp[0][2])
	{
		bZ = true;
	}

	if(bX&&bY&&bZ)
	{
		return true;
	}
	else
	{
		return false;
	}
}


CorrectEdgePoint(client)
{
	decl Float:vec[3];
	vec[0] = 0.0 - g_fEdgeVector[client][1];
	vec[1] = g_fEdgeVector[client][0];
	vec[2] = 0.0;
	ScaleVector(vec, 16.0);
	AddVectors(g_fEdgePoint[client], vec, g_fEdgePoint[client]);
}

public Prethink (client, Float:pos[3], Float:vel)
{
	//booster or moving plattform?
	new Float:flVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", flVelocity);
	if (flVelocity[0] != 0.0 || flVelocity[1] != 0.0 || flVelocity[2] != 0.0)
		g_js_bInvalidGround[client] = true;
	else
		g_js_bInvalidGround[client] = false;

	//reset vars
	g_js_Good_Sync_Frames[client] = 0.0;
	g_js_Sync_Frames[client] = 0.0;
	for( new i = 0; i < MAX_STRAFES; i++ )
	{
		g_js_Strafe_Good_Sync[client][i] = 0.0;
		g_js_Strafe_Frames[client][i] = 0.0;
		g_js_Strafe_Gained[client][i] = 0.0;
		g_js_Strafe_Lost[client][i] = 0.0;
		g_js_Strafe_Max_Speed[client][i] = 0.0;
	}

	g_js_fJumpOff_Time[client] = GetEngineTime();
	g_js_fMax_Speed[client] = 0.0;
	g_js_StrafeCount[client] = 0;
	g_js_bDropJump[client] = false;
	g_js_bPlayerJumped[client] = true;
	g_js_Strafing_AW[client] = false;
	g_js_Strafing_SD[client] = false;
	g_js_bFuncMoveLinear[client] = false;
	g_js_fMax_Height[client] = -99999.0;
	g_js_fLast_Jump_Time[client] = GetEngineTime();

	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	g_js_fPreStrafe[client] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));
	GetGroundOrigin(client, g_js_fJump_JumpOff_Pos[client]);
	if (g_js_fJump_JumpOff_PosLastHeight[client] != -1.012345)
	{
		new Float: fGroundDiff = g_js_fJump_JumpOff_Pos[client][2] - g_js_fJump_JumpOff_PosLastHeight[client];
		if (fGroundDiff > -0.1 && fGroundDiff < 0.1)
			fGroundDiff = 0.0;
		if(fGroundDiff <= -1.5)
		{
			g_js_bDropJump[client] = true;
			g_js_fDropped_Units[client] = FloatAbs(fGroundDiff);
		}
	}

	if (g_js_GroundFrames[client]<11)
		g_js_bBhop[client] = true;
	else
		g_js_bBhop[client] = false;


	//last InitialLastHeight
	g_js_fJump_JumpOff_PosLastHeight[client] = g_js_fJump_JumpOff_Pos[client][2];
}

public Postthink(client) {

	if(!IsValidClient(client)) 
		return;
	
	new ground_frames = g_js_GroundFrames[client];
	new strafes = g_js_StrafeCount[client];
	g_js_GroundFrames[client] = 0;
	g_js_fMax_Speed_Final[client] = g_js_fMax_Speed[client];
	decl String:szName[128];
	GetClientName(client, szName, 128);

	//get landing position & calc distance
	g_js_fJump_DistanceX[client] = g_js_fJump_Landing_Pos[client][0] - g_js_fJump_JumpOff_Pos[client][0];
	if(g_js_fJump_DistanceX[client] < 0)
		g_js_fJump_DistanceX[client] = -g_js_fJump_DistanceX[client];
	g_js_fJump_DistanceZ[client] = g_js_fJump_Landing_Pos[client][1] - g_js_fJump_JumpOff_Pos[client][1];
	if(g_js_fJump_DistanceZ[client] < 0)
		g_js_fJump_DistanceZ[client] = -g_js_fJump_DistanceZ[client];
	g_js_fJump_Distance[client] = SquareRoot(Pow(g_js_fJump_DistanceX[client], 2.0) + Pow(g_js_fJump_DistanceZ[client], 2.0));

	g_js_fJump_Distance[client] = g_js_fJump_Distance[client] + 32;

	//ground diff
	new Float: fGroundDiff = g_js_fJump_Landing_Pos[client][2] - g_js_fJump_JumpOff_Pos[client][2];
	new Float: fJump_Height;
	if (fGroundDiff > -0.1 && fGroundDiff < 0.1)
		fGroundDiff = 0.0;
	//workaround
	if (g_js_bFuncMoveLinear[client] && fGroundDiff < 0.6 && fGroundDiff > -0.6)
		fGroundDiff = 0.0;

	//ground diff 2
	new Float: groundpos[3];
	GetClientAbsOrigin(client, groundpos);
	new Float: fGroundDiff2 = groundpos[2] - g_fLastPositionOnGround[client][2];

	//GetHeight
	if (FloatAbs(g_js_fJump_JumpOff_Pos[client][2]) > FloatAbs(g_js_fMax_Height[client]))
		fJump_Height =  FloatAbs(g_js_fJump_JumpOff_Pos[client][2]) - FloatAbs(g_js_fMax_Height[client]);
	else
		fJump_Height =  FloatAbs(g_js_fMax_Height[client]) - FloatAbs(g_js_fJump_JumpOff_Pos[client][2]);
	g_flastHeight[client] = fJump_Height;

	//sync/strafes
	new sync = RoundToNearest(g_js_Good_Sync_Frames[client] / g_js_Sync_Frames[client] * 100.0);
	g_js_Strafes_Final[client] = strafes;
	g_js_Sync_Final[client] = sync;

	//Calc & format strafe sync for chat output
	new String:szStrafeSync[255];
	new String:szStrafeSync2[255];
	new strafe_sync;
	if (g_bStrafeSync[client] && strafes > 1)
	{
		for (new i = 0; i < strafes; i++)
		{
			if (i==0)
				Format(szStrafeSync, 255, "[%cKZ%c] %cSync:",MOSSGREEN,WHITE,GRAY);
			if (g_js_Strafe_Frames[client][i] == 0.0 || g_js_Strafe_Good_Sync[client][i] == 0.0)
				strafe_sync = 0;
			else
				strafe_sync = RoundToNearest(g_js_Strafe_Good_Sync[client][i] / g_js_Strafe_Frames[client][i] * 100.0);
			if (i==0)
				Format(szStrafeSync2, 255, " %c%i.%c %i%c",GRAY, (i+1),LIMEGREEN,strafe_sync,PERCENT);
			else
				Format(szStrafeSync2, 255, "%c - %i.%c %i%c",GRAY, (i+1),LIMEGREEN,strafe_sync,PERCENT);
			StrCat(szStrafeSync, sizeof(szStrafeSync), szStrafeSync2);
			if ((i+1) == strafes)
			{
				Format(szStrafeSync2, 255, " %c[%c%i%c%c]",GRAY,PURPLE, sync,PERCENT,GRAY);
				StrCat(szStrafeSync, sizeof(szStrafeSync), szStrafeSync2);
			}
		}
	}
	else
		Format(szStrafeSync,255, "");

	new String:szStrafeStats[1024];
	new String:szGained[16];
	new String:szLost[16];

	//Format StrafeStats Console
	if(strafes > 1)
	{
		Format(szStrafeStats,1024, " #. Sync        Gained      Lost        MaxSpeed\n");
		for( new i = 0; i < strafes; i++ )
		{
			new sync2 = RoundToNearest(g_js_Strafe_Good_Sync[client][i] / g_js_Strafe_Frames[client][i] * 100.0);
			if (sync2 < 0)
				sync2 = 0;
			if (g_js_Strafe_Gained[client][i] < 10.0)
				Format(szGained,16, "%.3f ", g_js_Strafe_Gained[client][i]);
			else
				Format(szGained,16, "%.3f", g_js_Strafe_Gained[client][i]);
			if (g_js_Strafe_Lost[client][i] < 10.0)
				Format(szLost,16, "%.3f ", g_js_Strafe_Lost[client][i]);
			else
				Format(szLost,16, "%.3f", g_js_Strafe_Lost[client][i]);
			Format(szStrafeStats,1024, "%s%2i. %3i%s        %s      %s      %3.3f\n",\
			szStrafeStats,\
			i + 1,\
			sync2,\
			PERCENT,\
			szGained,\
			szLost,\
			g_js_Strafe_Max_Speed[client][i]);
		}
	}
	else
		Format(szStrafeStats,1024, "");


	//vertical jump
	if (fGroundDiff2 > 1.82 || fGroundDiff2 < -1.82 || fGroundDiff != 0.0)
	{
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>vertical</font>");
		PostThinkPost(client, ground_frames);
		return;
	}
	//invalid jump
	if (g_fAirTime[client] > 0.83)
	{
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
		PostThinkPost(client, ground_frames);
		return;
	}
	// ct jumpstats
	if(GetClientTeam(client) != CS_TEAM_T && g_iCtJumpstats == 1) {
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#ff0000'>T Only Buddy</font>");
		PostThinkPost(client, ground_frames);
		return;
	}


	new bool: ValidJump=false;
	//Chat Output
	//LongJump
	if (ground_frames > 11 && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_js_fJump_Distance[client] < 300.0 && g_js_fMax_Speed_Final[client] > 200.0)
	{
		//prestrafe on/off
		decl String:szVr[16];
		Format(szVr, 16, "Pre");
		new bool: prestrafe;
		prestrafe = true;
		//strafe hack block (aimware is pretty smart :/) (2/2)
		if (g_js_fPreStrafe[client] > 278.0 || g_js_fPreStrafe[client] < 200.0)
		{
			if (g_js_fPreStrafe[client] < 200.0)
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.1f units</font>", g_js_fJump_Distance[client]);
			PostThinkPost(client, ground_frames);
			return;
		}
		//
		new bool:ljblock=false;
		decl String:sBlockDist[32];
		Format(sBlockDist, 32, "");
		decl String:sBlockDistCon[32];
		Format(sBlockDistCon, 32, "");
		if(g_bLJBlock[client] && g_BlockDist[client] > 225 && g_js_fJump_Distance[client] >= float(g_BlockDist[client]))
		{
			if (g_bLJBlockValidJumpoff[client])
			{
				if (g_bLjStarDest[client])
				{
					if (IsCoordInBlockPoint(g_js_fJump_Landing_Pos[client],g_fOriginBlock[client],true))
					{
						Format(sBlockDist, 32, "%t", "LjBlock", GRAY,LIGHTYELLOW,g_BlockDist[client],GRAY);
						Format(sBlockDistCon, 32, " [%i block]", g_BlockDist[client]);
						ljblock=true;
					}
				}
				else
				{
					if (IsCoordInBlockPoint(g_js_fJump_Landing_Pos[client],g_fDestBlock[client],true))
					{
						Format(sBlockDist, 32, "%t", "LjBlock", GRAY,LIGHTYELLOW,g_BlockDist[client],GRAY);
						Format(sBlockDistCon, 32, " [%i block]", g_BlockDist[client]);
						ljblock=true;
					}
				}
			}
		}

		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.1f units</font>", g_js_fJump_Distance[client]);
		ValidJump=true;
		//good?
		if (g_js_fJump_Distance[client] >= g_dist_good_lj && g_js_fJump_Distance[client] < g_dist_pro_lj)
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.1f units</b></font>", g_js_fJump_Distance[client]);
			CreateTimer(0.1, BhopCheck, client,TIMER_FLAG_NO_MAPCHANGE);
			if (prestrafe)
				PrintToChat(client, "%t", "ClientLongJump1", MOSSGREEN,WHITE,GRAY, g_js_fJump_Distance[client],LIMEGREEN,strafes,GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
			else
				PrintToChat(client, "%t", "ClientLongJump2",MOSSGREEN,WHITE,GRAY, g_js_fJump_Distance[client],LIMEGREEN,strafes,GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);

			PrintToConsole(client, "        ");
			PrintToConsole(client, "[JS] %s jumped %0.4f units with a LongJump [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync]%s",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], szVr,g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,sBlockDistCon);
			PrintToConsole(client, "%s", szStrafeStats);
		}
		else if (g_js_fJump_Distance[client] >= g_dist_pro_lj && g_js_fJump_Distance[client] < g_dist_leet_lj)
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
			CreateTimer(0.1, BhopCheck, client,TIMER_FLAG_NO_MAPCHANGE);
			//chat & sound client
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[JS] %s jumped %0.4f units with a LongJump [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync]%s",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client],szVr, g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,sBlockDistCon);
			PrintToConsole(client, "%s", szStrafeStats);
			if (prestrafe)
				PrintToChat(client, "%t", "ClientLongJump3",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
			else
				PrintToChat(client, "%t", "ClientLongJump4",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);

			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH);
			if (g_bEnableQuakeSounds[client])
				ClientCommand(client, buffer);
			//chat all
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (g_bColorChat[i] && i != client)
						PrintToChat(i, "%t", "Jumpstats_LjAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN,sBlockDist);
				}
			}
		}
		//ownage?
		else if (g_js_fJump_Distance[client] >= g_dist_ownage_lj && g_js_fMax_Speed_Final[client] > 275.0)
		{
			// strafe hack protection & Ladderbug fix. We'll only apply this to ownages since the types below aren't really impressive with ladderbugs :P
				if (strafes == 0  /*g_js_fPreStrafe[client] > 251.0 || g_js_fPreStrafe[client] < 245.0*/) {
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
					PostThinkPost(client, ground_frames);
					return;
				}
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#e3ad39'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
			g_js_OwnageJump_Count[client]++;
			//client
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[JS] %s jumped %0.4f units with a LongJump [%i Strafes | %.3f %s | %.3f Max | Height %.1f | %i%c Sync]%s",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client],szVr, g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,sBlockDistCon);
			PrintToConsole(client, "%s", szStrafeStats);
			if (prestrafe)
				PrintToChat(client, "%t", "ClientLongJump3",MOSSGREEN,WHITE,YELLOW,GRAY,YELLOW,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
			else
				PrintToChat(client, "%t", "ClientLongJump4",MOSSGREEN,WHITE,YELLOW,GRAY,YELLOW,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
			if (g_js_OwnageJump_Count[client]==3)
				PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
			else
				if (g_js_OwnageJump_Count[client]==5)
					PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);

			//all
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (g_bColorChat[i] && i != client)
					{
						PrintToChat(i, "%t", "Jumpstats_LjAll",MOSSGREEN,WHITE,YELLOW,szName, LIGHTYELLOW,YELLOW, g_js_fJump_Distance[client],LIGHTYELLOW,YELLOW,sBlockDist);
						if (g_js_OwnageJump_Count[client]==3)
							PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
						else
							if (g_js_OwnageJump_Count[client]==5)
								PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
					}
				}
			}
					PlayOwnageJumpSound(client);
					if (g_js_OwnageJump_Count[client] != 3 && g_js_OwnageJump_Count[client] != 5) {
						for (new i = 1; i <= MaxClients+1; i++) { 
							if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
								ClientCommand(i, "play %s", OWNAGEJUMP_RELATIVE_SOUND_PATH);
							}
						}
					}
			else
				CreateTimer(0.1, BhopCheck, client,TIMER_FLAG_NO_MAPCHANGE);

		}
		//leet?
		else {
			if (g_js_fJump_Distance[client] >= g_dist_leet_lj && g_js_fMax_Speed_Final[client] > 275.0)
			{
				// strafe hack protection
				if (strafes == 0)
				{
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
					PostThinkPost(client, ground_frames);
					return;
				}
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
				g_js_LeetJump_Count[client]++;
				//client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[JS] %s jumped %0.4f units with a LongJump [%i Strafes | %.3f %s | %.3f Max | Height %.1f | %i%c Sync]%s",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client],szVr, g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,sBlockDistCon);
				PrintToConsole(client, "%s", szStrafeStats);
				if (prestrafe)
					PrintToChat(client, "%t", "ClientLongJump3",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
				else
					PrintToChat(client, "%t", "ClientLongJump4",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
				if (g_js_LeetJump_Count[client]==3)
					PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
				else
					if (g_js_LeetJump_Count[client]==5)
						PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);

				//all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						if (g_bColorChat[i] && i != client)
						{
							PrintToChat(i, "%t", "Jumpstats_LjAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED,sBlockDist);
							if (g_js_LeetJump_Count[client]==3)
								PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
							else
								if (g_js_LeetJump_Count[client]==5)
									PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);
						}
					}
				}
				PlayLeetJumpSound(client);
				if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
				{
					decl String:buffer[255];
					Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH);
				}
			}
			else
				CreateTimer(0.1, BhopCheck, client,TIMER_FLAG_NO_MAPCHANGE);

		}

		//strafe sync chat
		if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_lj)
			PrintToChat(client,"%s", szStrafeSync);

		//new best
		if (((g_js_fPersonal_Lj_Record[client] < g_js_fJump_Distance[client]) || (ljblock && g_js_Personal_LjBlock_Record[client] < g_BlockDist[client]) || (ljblock && g_js_Personal_LjBlock_Record[client] == g_BlockDist[client] && g_js_fPersonal_LjBlockRecord_Dist[client] < g_js_fJump_Distance[client])) && !IsFakeClient(client))
		{
			if (ValidJump)
			{
				if (g_js_fPersonal_Lj_Record[client] > 0.0 && g_js_fPersonal_Lj_Record[client] < g_js_fJump_Distance[client])
					PrintToChat(client, "%t", "Jumpstats_BeatLjBest",MOSSGREEN,WHITE,LIGHTYELLOW, g_js_fJump_Distance[client]);
				if (ljblock && g_js_Personal_LjBlock_Record[client] > 0 && ((g_js_Personal_LjBlock_Record[client] < g_BlockDist[client]) || (g_js_Personal_LjBlock_Record[client] == g_BlockDist[client] && g_js_fPersonal_LjBlockRecord_Dist[client] < g_js_fJump_Distance[client])))
					PrintToChat(client, "%t", "Jumpstats_BeatLjBlockBest",MOSSGREEN,WHITE,LIGHTYELLOW, g_BlockDist[client],g_js_fJump_Distance[client]);
				if (g_js_fPersonal_Lj_Record[client] < g_js_fJump_Distance[client])
				{
					g_js_fPersonal_Lj_Record[client] = g_js_fJump_Distance[client];
					db_updateLjRecord(client);
				}
				if (g_js_Personal_LjBlock_Record[client] < g_BlockDist[client] && ljblock || (ljblock && g_js_Personal_LjBlock_Record[client] == g_BlockDist[client] && g_js_fPersonal_LjBlockRecord_Dist[client] < g_js_fJump_Distance[client]))
				{
					g_js_Personal_LjBlock_Record[client] = g_BlockDist[client];
					g_js_fPersonal_LjBlockRecord_Dist[client] = g_js_fJump_Distance[client];
					db_updateLjBlockRecord(client);
				}
			}
		}
	}
	//Multi Bhop
	if (g_js_Last_Ground_Frames[client] < 11 && ground_frames < 11 && fGroundDiff == 0.0  && fJump_Height <= 67.0 && !g_js_bDropJump[client])
	{

		g_js_MultiBhop_Count[client]++;
		//strafe hack block
		if (strafes > 20)
		{
			PostThinkPost(client, ground_frames);
			return;
		}

		//format bhop count
		decl String:szBhopCount[255];
		Format(szBhopCount, sizeof(szBhopCount), "%i", g_js_MultiBhop_Count[client]);
		if (g_js_MultiBhop_Count[client] > 8)
			Format(szBhopCount, sizeof(szBhopCount), "> 8");

		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.1f units</font>", g_js_fJump_Distance[client]);
		ValidJump=true;
		//good?
		if (g_js_fJump_Distance[client] >= g_dist_good_multibhop && g_js_fJump_Distance[client] < g_dist_pro_multibhop)
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.1f units</b></font>", g_js_fJump_Distance[client]);
			g_js_LeetJump_Count[client]=0;
			PrintToChat(client, "%t", "ClientMultiBhop1",MOSSGREEN,WHITE, GRAY, g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN, sync,PERCENT,GRAY);
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[JS] %s jumped %0.4f units with a MultiBhop [%i Strafes | %3.f Pre | %3.f Max | Height %.1f | %s Bhops | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], fJump_Height,szBhopCount,sync,PERCENT);
			PrintToConsole(client, "%s", szStrafeStats);
		}
		else
			//pro?
			if (g_js_fJump_Distance[client] >= g_dist_pro_multibhop && g_js_fJump_Distance[client] < g_dist_leet_multibhop)
			{
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
				g_js_LeetJump_Count[client]=0;
				//Client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[JS] %s jumped %0.4f units with a MultiBhop [%i Strafes | %.3f Pre | %.3f Max |  Height %.1f | %s Bhops | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], fJump_Height,szBhopCount,sync,PERCENT);
				PrintToConsole(client, "%s", szStrafeStats);
				PrintToChat(client, "%t", "ClientMultiBhop2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,szBhopCount,GRAY,LIMEGREEN, sync,PERCENT,GRAY);

				decl String:buffer[255];
				Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH);
				if (g_bEnableQuakeSounds[client])
					ClientCommand(client, buffer);
				//all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						if (g_bColorChat[i] && i != client)
							PrintToChat(i, "%t", "Jumpstats_MultiBhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN);
					}
				}
			}
			//ownage?
			else
			if (g_js_fJump_Distance[client] >= g_dist_ownage_multibhop)
			{
				// strafe hack protection
				if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
				{
					ValidJump=false;
					PostThinkPost(client, ground_frames);
					return;
				}
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#e3ad39'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
				g_js_OwnageJump_Count[client]++;
				//Client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[JS] %s jumped %0.4f units with a MultiBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %s Bhops | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], fJump_Height,szBhopCount,sync,PERCENT);
				PrintToConsole(client, "%s", szStrafeStats);
				PrintToChat(client, "%t", "ClientMultiBhop2",MOSSGREEN,WHITE,YELLOW,GRAY,YELLOW,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,szBhopCount,GRAY,LIMEGREEN, sync,PERCENT,GRAY);
				if (g_js_OwnageJump_Count[client]==3)
					PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
				else
				if (g_js_OwnageJump_Count[client]==5)
					PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);

				//all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						if (g_bColorChat[i] && i != client)
						{
							PrintToChat(i, "%t", "Jumpstats_MultiBhopAll",MOSSGREEN,WHITE,YELLOW,szName, LIGHTYELLOW,YELLOW, g_js_fJump_Distance[client],LIGHTYELLOW,YELLOW);
							if (g_js_OwnageJump_Count[client]==3)
									PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
								else
								if (g_js_OwnageJump_Count[client]==5)
									PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
						}
					}
				}
					PlayOwnageJumpSound(client);
					if (g_js_OwnageJump_Count[client] != 3 && g_js_OwnageJump_Count[client] != 5) {
						for (new i = 1; i <= MaxClients+1; i++) { 
							if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
								ClientCommand(i, "play %s", OWNAGEJUMP_RELATIVE_SOUND_PATH);
							}
						}
					}
			}

			//leet?
			else
			if (g_js_fJump_Distance[client] >= g_dist_leet_multibhop)
			{
				// strafe hack protection
				if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
				{
					ValidJump=false;
					PostThinkPost(client, ground_frames);
					return;
				}
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
				g_js_LeetJump_Count[client]++;
				//Client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[JS] %s jumped %0.4f units with a MultiBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %s Bhops | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], fJump_Height,szBhopCount,sync,PERCENT);
				PrintToConsole(client, "%s", szStrafeStats);
				PrintToChat(client, "%t", "ClientMultiBhop2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,szBhopCount,GRAY,LIMEGREEN, sync,PERCENT,GRAY);
				if (g_js_LeetJump_Count[client]==3)
					PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
				else
				if (g_js_LeetJump_Count[client]==5)
					PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);

				//all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						if (g_bColorChat[i] && i != client)
						{
							PrintToChat(i, "%t", "Jumpstats_MultiBhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED);
							if (g_js_LeetJump_Count[client]==3)
									PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
								else
								if (g_js_LeetJump_Count[client]==5)
									PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);
						}
					}
				}
				PlayLeetJumpSound(client);
				if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
				{
					decl String:buffer[255];
					Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH);
				}
			}
			else
				g_js_LeetJump_Count[client]=0;

		//strafe sync chat
		if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_multibhop)
			PrintToChat(client,"%s", szStrafeSync);

		//new best
		if (g_js_fPersonal_MultiBhop_Record[client] < g_js_fJump_Distance[client] &&  !IsFakeClient(client) && ValidJump)
		{
			if (g_js_fPersonal_MultiBhop_Record[client] > 0.0)
				PrintToChat(client, "%t", "Jumpstats_BeatMultiBhopBest",MOSSGREEN,WHITE,LIGHTYELLOW, g_js_fJump_Distance[client]);
			g_js_fPersonal_MultiBhop_Record[client] = g_js_fJump_Distance[client];
			db_updateMultiBhopRecord(client);
		}
	}
	else
		g_js_MultiBhop_Count[client] = 1;

	//dropbhop
	if (ground_frames < 11 && g_js_Last_Ground_Frames[client] > 11 && g_bLastButtonJump[client] && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_js_bDropJump[client])
	{
		if (g_js_fDropped_Units[client] > 150.0)
		{
			if (g_js_fDropped_Units[client] < 300.0)
				PrintToChat(client, "%t", "DropBhop1",MOSSGREEN,WHITE,RED,g_js_fDropped_Units[client],WHITE,GREEN,WHITE,GRAY,WHITE);
		}
		else
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.1f units</font>", g_js_fJump_Distance[client]);
			ValidJump = true;
			//good
			if (g_js_fJump_Distance[client] >= g_dist_good_dropbhop && g_js_fJump_Distance[client] < g_dist_pro_dropbhop)
			{
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.1f units</b></font>", g_js_fJump_Distance[client]);
				g_js_LeetJump_Count[client]=0;
				PrintToChat(client, "%t", "ClientDropBhop1",MOSSGREEN,WHITE, GRAY,g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN,fJump_Height,GRAY, LIMEGREEN,sync,PERCENT,GRAY);
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[JS] %s jumped %0.4f units with a DropBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
				PrintToConsole(client, "%s", szStrafeStats);
			}
			else
				//pro
				if (g_js_fJump_Distance[client] >= g_dist_pro_dropbhop && g_js_fJump_Distance[client] < g_dist_leet_dropbhop)
				{
					g_js_LeetJump_Count[client]=0;
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
					PrintToConsole(client, "        ");
					PrintToChat(client, "%t", "ClientDropBhop2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,sync,PERCENT,GRAY);
					PrintToConsole(client, "[JS] %s jumped %0.4f units with a DropBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
					PrintToConsole(client, "%s", szStrafeStats);
					decl String:buffer[255];
					Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH);
					if (g_bEnableQuakeSounds[client])
						ClientCommand(client, buffer);
					//all
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i))
						{
							if (g_bColorChat[i]==true && i != client)
								PrintToChat(i, "%t", "Jumpstats_DropBhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN);
						}
					}
				}
				//ownage?
				else
					if (g_js_fJump_Distance[client] >= g_dist_ownage_dropbhop  && g_js_fMax_Speed_Final[client] > 330.0)
					{
						// strafe hack protection
						if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
						{
							ValidJump = false;
							Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
							PostThinkPost(client, ground_frames);
							return;
						}
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#e3ad39'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
						g_js_OwnageJump_Count[client]++;
						//Client
						PrintToConsole(client, "        ");
						PrintToChat(client, "%t", "ClientDropBhop2",MOSSGREEN,WHITE,YELLOW,GRAY,YELLOW,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
						PrintToConsole(client, "[JS] %s jumped %0.4f units with a DropBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
						PrintToConsole(client, "%s", szStrafeStats);
						if (g_js_OwnageJump_Count[client]==3)
							PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
						else
							if (g_js_OwnageJump_Count[client]==5)
								PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);

						//all
						for (new i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								if (g_bColorChat[i]==true && i != client)
								{
									PrintToChat(i, "%t", "Jumpstats_DropBhopAll",MOSSGREEN,WHITE,YELLOW,szName, LIGHTYELLOW,YELLOW, g_js_fJump_Distance[client], LIGHTYELLOW,YELLOW);
									if (g_js_OwnageJump_Count[client]==3)
											PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
									else
										if (g_js_OwnageJump_Count[client]==5)
											PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
								}
							}
						}
					PlayOwnageJumpSound(client);
					if (g_js_OwnageJump_Count[client] != 3 && g_js_OwnageJump_Count[client] != 5) {
						for (new i = 1; i <= MaxClients+1; i++) { 
							if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
								ClientCommand(i, "play %s", OWNAGEJUMP_RELATIVE_SOUND_PATH);
							}
						}
					}
					}
				//leet
				else
					if (g_js_fJump_Distance[client] >= g_dist_leet_dropbhop  && g_js_fMax_Speed_Final[client] > 330.0)
					{
						// strafe hack protection
						if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
						{
							ValidJump = false;
							Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
							PostThinkPost(client, ground_frames);
							return;
						}
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
						g_js_LeetJump_Count[client]++;
						//Client
						PrintToConsole(client, "        ");
						PrintToChat(client, "%t", "ClientDropBhop2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
						PrintToConsole(client, "[JS] %s jumped %0.4f units with a DropBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
						PrintToConsole(client, "%s", szStrafeStats);
						if (g_js_LeetJump_Count[client]==3)
							PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
						else
							if (g_js_LeetJump_Count[client]==5)
								PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);

						//all
						for (new i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								if (g_bColorChat[i]==true && i != client)
								{
									PrintToChat(i, "%t", "Jumpstats_DropBhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client], RED,DARKRED);
									if (g_js_LeetJump_Count[client]==3)
											PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
									else
										if (g_js_LeetJump_Count[client]==5)
											PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
								}
							}
						}
						PlayLeetJumpSound(client);
						if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
						{
							decl String:buffer[255];
							Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH);
						}
					}
					else
						g_js_LeetJump_Count[client]=0;

			//strafesync chat
			if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_dropbhop)
				PrintToChat(client,"%s", szStrafeSync);

			//new best
			if (g_js_fPersonal_DropBhop_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
			{
				if (g_js_fPersonal_DropBhop_Record[client] > 0.0)
					PrintToChat(client, "%t", "Jumpstats_BeatDropBhopBest",MOSSGREEN,WHITE,LIGHTYELLOW, g_js_fJump_Distance[client]);
				g_js_fPersonal_DropBhop_Record[client] = g_js_fJump_Distance[client];
				db_updateDropBhopRecord(client);
			}

		}
	}
	// WeirdJump
	if (ground_frames < 11 && !g_bLastButtonJump[client] && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_js_bDropJump[client])
	{
			if (g_js_fDropped_Units[client] > 150.0)
			{
				if (g_js_fDropped_Units[client] < 300.0)
					PrintToChat(client, "%t", "Wj1",MOSSGREEN,WHITE,RED,g_js_fDropped_Units[client],WHITE,GREEN,WHITE,GRAY,WHITE);
			}
			else
			{
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.1f units</font>", g_js_fJump_Distance[client]);
				ValidJump = true;
				//good?
				if (g_js_fJump_Distance[client] >= g_dist_good_weird && g_js_fJump_Distance[client] < g_dist_pro_weird)
				{
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.1f units</b></font>", g_js_fJump_Distance[client]);
					g_js_LeetJump_Count[client]=0;
					PrintToChat(client, "%t", "ClientWeirdJump1",MOSSGREEN,WHITE, GRAY,g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
					PrintToConsole(client, "        ");
					PrintToConsole(client, "[JS] %s jumped %0.4f units with a WeirdJump [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
					PrintToConsole(client, "%s", szStrafeStats);
				}
				//pro?
				else
					if (g_js_fJump_Distance[client] >= g_dist_pro_weird && g_js_fJump_Distance[client] < g_dist_leet_weird)
					{
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
						g_js_LeetJump_Count[client]=0;
						//Client
						PrintToConsole(client, "        ");
						PrintToChat(client, "%t", "ClientWeirdJump2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
						PrintToConsole(client, "[JS] %s jumped %0.4f units with a WeirdJump [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
						PrintToConsole(client, "%s", szStrafeStats);
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH);
						if (g_bEnableQuakeSounds[client])
							ClientCommand(client, buffer);
						//all
						for (new i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								if (g_bColorChat[i]==true && i != client)
									PrintToChat(i, "%t", "Jumpstats_WeirdAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN);
							}
						}
					}
					//ownage?
					else
						if (g_js_fJump_Distance[client] >= g_dist_ownage_weird)
						{
							// strafe hack protection
							if (strafes == 0 || g_js_fPreStrafe[client] < 255.0)
							{
								ValidJump = false;
								Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
								PostThinkPost(client, ground_frames);
								return;
							}
							Format(g_js_szLastJumpDistance[client], 256, "<font color='#e3ad39'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
							g_js_OwnageJump_Count[client]++;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "%t", "ClientWeirdJump2",MOSSGREEN,WHITE,YELLOW,GRAY,YELLOW,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
							PrintToConsole(client, "[JS] %s jumped %0.4f units with a WeirdJump [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
							PrintToConsole(client, "%s", szStrafeStats);
							if (g_js_OwnageJump_Count[client]==3)
								PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
							else
								if (g_js_OwnageJump_Count[client]==5)
									PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);

							//all
							for (new i = 1; i <= MaxClients; i++)
							{
								if (IsValidClient(i))
								{
									if (g_bColorChat[i]==true && i != client)
									{
										PrintToChat(i, "%t", "Jumpstats_WeirdAll",MOSSGREEN,WHITE,YELLOW,szName, LIGHTYELLOW,YELLOW, g_js_fJump_Distance[client],LIGHTYELLOW,YELLOW);
										if (g_js_OwnageJump_Count[client]==3)
												PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
											else
											if (g_js_OwnageJump_Count[client]==5)
												PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
									}
								}
							}
					PlayOwnageJumpSound(client);
					if (g_js_OwnageJump_Count[client] != 3 && g_js_OwnageJump_Count[client] != 5) {
						for (new i = 1; i <= MaxClients+1; i++) { 
							if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
								ClientCommand(i, "play %s", OWNAGEJUMP_RELATIVE_SOUND_PATH);
							}
						}
					}
						}
					//leet?
					else
						if (g_js_fJump_Distance[client] >= g_dist_leet_weird)
						{
							// strafe hack protection
							if (strafes == 0 || g_js_fPreStrafe[client] < 255.0)
							{
								ValidJump = false;
								Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
								PostThinkPost(client, ground_frames);
								return;
							}
							Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
							g_js_LeetJump_Count[client]++;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "%t", "ClientWeirdJump2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
							PrintToConsole(client, "[JS] %s jumped %0.4f units with a WeirdJump [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
							PrintToConsole(client, "%s", szStrafeStats);
							if (g_js_LeetJump_Count[client]==3)
								PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
							else
								if (g_js_LeetJump_Count[client]==5)
									PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);

							//all
							for (new i = 1; i <= MaxClients; i++)
							{
								if (IsValidClient(i))
								{
									if (g_bColorChat[i]==true && i != client)
									{
										PrintToChat(i, "%t", "Jumpstats_WeirdAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED);
										if (g_js_LeetJump_Count[client]==3)
												PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
											else
											if (g_js_LeetJump_Count[client]==5)
												PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);
									}
								}
							}
					PlayLeetJumpSound(client);
					if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
					{
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH);
					}
						}
						else
							g_js_LeetJump_Count[client]=0;

				//strafesync chat
				if (g_bStrafeSync[client]  && g_js_fJump_Distance[client] >= g_dist_good_weird)
					PrintToChat(client,"%s", szStrafeSync);

				//new best
				if (g_js_fPersonal_Wj_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
				{
					if (g_js_fPersonal_Wj_Record[client] > 0.0)
						PrintToChat(client, "%t", "Jumpstats_BeatWjBest",MOSSGREEN,WHITE,LIGHTYELLOW, g_js_fJump_Distance[client]);
					g_js_fPersonal_Wj_Record[client] = g_js_fJump_Distance[client];
					db_updateWjRecord(client);
				}
			}
	}
	//BunnyHop
	if (ground_frames < 11 && g_js_Last_Ground_Frames[client] > 10 && fGroundDiff == 0.0 && fJump_Height <= 67.0 && !g_js_bDropJump[client] && g_js_fPreStrafe[client] > 200.0)
	{
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.1f units</font>", g_js_fJump_Distance[client]);
		ValidJump=true;
		//good?
		if (g_js_fJump_Distance[client] >= g_dist_good_bhop && g_js_fJump_Distance[client] < g_dist_pro_bhop)
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.1f units</b></font>", g_js_fJump_Distance[client]);
			g_js_LeetJump_Count[client]=0;
			PrintToChat(client, "%t", "ClientBunnyhop1",MOSSGREEN,WHITE,GRAY, g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[JS] %s jumped %0.4f units with a Bhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT);
			PrintToConsole(client, "%s", szStrafeStats);
		}
		else
			//pro?
			if (g_js_fJump_Distance[client] >= g_dist_pro_bhop && g_js_fJump_Distance[client] < g_dist_leet_bhop)
			{
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
				g_js_LeetJump_Count[client]=0;
				PrintToConsole(client, "        ");
				PrintToChat(client, "%t", "ClientBunnyhop2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
				PrintToConsole(client, "[JS] %s jumped %0.4f units with a Bhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height, sync,PERCENT);
				PrintToConsole(client, "%s", szStrafeStats);
				decl String:buffer[255];
				Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH);
				if (g_bEnableQuakeSounds[client])
					ClientCommand(client, buffer);
				//all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						if (g_bColorChat[i]==true && i != client)
							PrintToChat(i, "%t", "Jumpstats_BhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN);
					}
				}
			}
			else
			{
				//ownage?
				if (g_js_fJump_Distance[client] >= g_dist_ownage_bhop && g_js_fMax_Speed_Final[client] > 330.0)
				{
					// strafe hack protection
					if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
					{
						ValidJump=false;
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
						PostThinkPost(client, ground_frames);
						return;
					}
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#e3ad39'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
					g_js_OwnageJump_Count[client]++;
					//Client
					PrintToConsole(client, "        ");
					PrintToChat(client, "%t", "ClientBunnyhop2",MOSSGREEN,WHITE,YELLOW,GRAY,YELLOW,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
					PrintToConsole(client, "[JS] %s jumped %0.4f units with a Bhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height, sync,PERCENT);
					PrintToConsole(client, "%s", szStrafeStats);
					if (g_js_OwnageJump_Count[client]==3)
						PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
					else
					if (g_js_OwnageJump_Count[client]==5)
								PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);

					//all
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i))
						{
							if (g_bColorChat[i]==true && i != client)
							{
								PrintToChat(i, "%t", "Jumpstats_BhopAll",MOSSGREEN,WHITE,YELLOW,szName, LIGHTYELLOW,YELLOW, g_js_fJump_Distance[client],LIGHTYELLOW,YELLOW);
								if (g_js_OwnageJump_Count[client]==3)
									PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
								else
									if (g_js_OwnageJump_Count[client]==5)
										PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
							}
						}
					}
					PlayOwnageJumpSound(client);
					if (g_js_OwnageJump_Count[client] != 3 && g_js_OwnageJump_Count[client] != 5) {
						for (new i = 1; i <= MaxClients+1; i++) { 
							if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
								ClientCommand(i, "play %s", OWNAGEJUMP_RELATIVE_SOUND_PATH);
							}
						}
					}
				}
				else
				{
					g_js_OwnageJump_Count[client]=0;
				}
			}

		//strafe sync chat
		if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_bhop)
				PrintToChat(client,"%s", szStrafeSync);


			else
			{
				//leet?
				if (g_js_fJump_Distance[client] >= g_dist_leet_bhop && g_js_fJump_Distance[client] < g_dist_ownage_bhop && g_js_fMax_Speed_Final[client] > 330.0)
				{
					// strafe hack protection
					if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
					{
						ValidJump=false;
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
						PostThinkPost(client, ground_frames);
						return;
					}
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.2f units</b></font>", g_js_fJump_Distance[client]);
					g_js_LeetJump_Count[client]++;
					//Client
					PrintToConsole(client, "        ");
					PrintToChat(client, "%t", "ClientBunnyhop2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
					PrintToConsole(client, "[JS] %s jumped %0.4f units with a Bhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_js_fJump_Distance[client],strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height, sync,PERCENT);
					PrintToConsole(client, "%s", szStrafeStats);
					if (g_js_LeetJump_Count[client]==3)
						PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
					else
					if (g_js_LeetJump_Count[client]==5)
								PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);

					//all
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i))
						{
							if (g_bColorChat[i]==true && i != client)
							{
								PrintToChat(i, "%t", "Jumpstats_BhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED);
								if (g_js_LeetJump_Count[client]==3)
									PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,DARKRED,szName);
								else
									if (g_js_LeetJump_Count[client]==5)
										PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,DARKRED,szName);
							}
						}
					}
					PlayLeetJumpSound(client);
					if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
					{
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH);
					}
				}
				else
				{
					g_js_LeetJump_Count[client]=0;
				}
			}

		//strafe sync chat
		if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_bhop)
				PrintToChat(client,"%s", szStrafeSync);

		//new best
		if (g_js_fPersonal_Bhop_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
		{
			if (g_js_fPersonal_Bhop_Record[client] > 0.0)
				PrintToChat(client, "%t", "Jumpstats_BeatBhopBest",MOSSGREEN,WHITE,LIGHTYELLOW, g_js_fJump_Distance[client]);
			g_js_fPersonal_Bhop_Record[client] = g_js_fJump_Distance[client];
			db_updateBhopRecord(client);
		}
		
		// Thanks to hiiamu for telling me how to fix the godlike bhop bug
		
		//new best
		if (g_js_fPersonal_Bhop_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
		{
			if (g_js_fPersonal_Bhop_Record[client] > 0.0)
				PrintToChat(client, "%t", "Jumpstats_BeatBhopBest",MOSSGREEN,WHITE,LIGHTYELLOW, g_js_fJump_Distance[client]);
			g_js_fPersonal_Bhop_Record[client] = g_js_fJump_Distance[client];
			db_updateBhopRecord(client);
		}


	}
	if (!ValidJump)
		g_js_LeetJump_Count[client]=0;
	PostThinkPost(client, ground_frames);
}

public PostThinkPost(client, ground_frames)
{
	g_js_bPlayerJumped[client] = false;
	g_js_Last_Ground_Frames[client] = ground_frames;
}

public Action:Client_Ljblock(client, args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
		LJBlockMenu(client);
	return Plugin_Handled;
}

public LJBlockMenu(client)
{
	new Handle:menu = CreateMenu(LjBlockMenuHandler);
	SetMenuTitle(menu, "LJ Block Jump Menu");
	AddMenuItem(menu, "0", "Select Destination");
	AddMenuItem(menu, "0", "Reset Destination");
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public LjBlockMenuHandler(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			Function_BlockJump(client);
			LJBlockMenu(client);
		}
		else if(select == 1)
		{
			g_bLJBlock[client] = false;
			LJBlockMenu(client);
		}
	}
}

public Action:Client_InfoPanel(client, args)
{
	InfoPanel(client);
	if (g_bInfoPanel[client] == true)
		PrintToChat(client, "%t", "Info1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Info2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public InfoPanel(client)
{
	if (g_bInfoPanel[client])
		g_bInfoPanel[client] = false;
	else
	{
		g_bInfoPanel[client] = true;
	}
}

public Action:Client_StrafeSync(client, args)
{
	StrafeSync(client);
	if (g_bStrafeSync[client])
		PrintToChat(client, "%t", "StrafeSync1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "StrafeSync2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public Action:Client_Stats(client, args)
{
	g_bdetailView[client]=false;
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	db_viewJumpStats(client, szSteamId)
	return Plugin_Handled;
}


public StrafeSync(client)
{
	if (g_bStrafeSync[client])
		g_bStrafeSync[client] = false;
	else
		g_bStrafeSync[client] = true;
}

public Action:Client_QuakeSounds(client, args)
{
	QuakeSounds(client);
	if (g_bEnableQuakeSounds[client])
		PrintToChat(client, "%t", "QuakeSounds1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "QuakeSounds2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public QuakeSounds(client)
{
	if (g_bEnableQuakeSounds[client])
		g_bEnableQuakeSounds[client] = false;
	else
		g_bEnableQuakeSounds[client] = true;
}

public Action:Client_Colorchat(client, args)
{
	ColorChat(client);
	if (g_bColorChat[client])
		PrintToChat(client, "%t", "Colorchat1", MOSSGREEN,WHITE);
	else
		PrintToChat(client, "%t", "Colorchat2", MOSSGREEN,WHITE);
	return Plugin_Handled;
}

public PlayOwnageJumpSound(client) {
	if (g_js_OwnageJump_Count[client] == 3 || g_js_OwnageJump_Count[client] == 5) {
		for (new i = 1; i <= MaxClients+1; i++) { 
			if(IsValidClient(i) && !IsFakeClient(i) && i != client && g_bColorChat[i] && g_bEnableQuakeSounds[i]) {	
				if (g_js_OwnageJump_Count[client]==3) {
					ClientCommand(i, "play %s", LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH);
				} else if (g_js_OwnageJump_Count[client]==5) {
					ClientCommand(i, "play %s", LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH);
				}
			}
		}
	}
	
	if (IsValidClient(client) && !IsFakeClient(client) && g_bEnableQuakeSounds[client]) {
		if (g_js_OwnageJump_Count[client] != 3 && g_js_OwnageJump_Count[client] != 5) {
			for (new i = 1; i <= MaxClients+1; i++) { 
				if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
					ClientCommand(i, "play %s", OWNAGEJUMP_RELATIVE_SOUND_PATH);
				}
			}
		} else if (g_js_OwnageJump_Count[client]==3) {
			for (new i = 1; i <= MaxClients+1; i++) {
				if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
					ClientCommand(i, "play %s", LEETJUMP_RELATIVE_SOUND_PATH);
				}
			}
		} else if (g_js_OwnageJump_Count[client]==5) {
			for (new i = 1; i <= MaxClients+1; i++) {
				if(IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i]) {
					ClientCommand(i, "play %s", LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH);
				}
			}
		}
	}
}
public PlayLeetJumpSound(client)
{
	decl String:buffer[255];

	//all sound
	if (g_js_LeetJump_Count[client] == 3 || g_js_LeetJump_Count[client] == 5)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i) && !IsFakeClient(i) && i != client && g_bColorChat[i] && g_bEnableQuakeSounds[i])
			{
					if (g_js_LeetJump_Count[client]==3)
					{
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH);
						ClientCommand(i, buffer);
					}
					else
						if (g_js_LeetJump_Count[client]==5)
						{
							Format(buffer, sizeof(buffer), "play %s", LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH);
							ClientCommand(i, buffer);
						}
			}
		}
	}

	//client sound
	if 	(IsValidClient(client) && !IsFakeClient(client) && g_bEnableQuakeSounds[client])
	{
		if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
		{
			Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH);
			ClientCommand(client, buffer);
		}
			else
			if (g_js_LeetJump_Count[client]==3)
			{
				Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RAMPAGE_RELATIVE_SOUND_PATH);
				ClientCommand(client, buffer);
			}
			else
			if (g_js_LeetJump_Count[client]==5)
			{
				Format(buffer, sizeof(buffer), "play %s", LEETJUMP_DOMINATING_RELATIVE_SOUND_PATH);
				ClientCommand(client, buffer);
			}
	}
}

public ColorChat(client)
{
	if (g_bColorChat[client])
		g_bColorChat[client] = false;
	else
		g_bColorChat[client] = true;
}

public Action:Client_Top(client, args)
{
	JumpTopMenu(client);
	return Plugin_Handled;
}

public JumpTopMenu(client)
{
	new Handle:topmenu2 = CreateMenu(JumpTopMenuHandler);
	SetMenuTitle(topmenu2, "Jump Top");
	AddMenuItem(topmenu2, "!lj", "Top 20 Longjump");
	AddMenuItem(topmenu2, "!ljblock", "Top 20 Block Longjump");
	AddMenuItem(topmenu2, "!bhop", "Top 20 Bunnyhop");
	AddMenuItem(topmenu2, "!multibhop", "Top 20 Multi-Bunnyhop");
	AddMenuItem(topmenu2, "!dropbhop", "Top 20 Drop-Bunnyhop");
	AddMenuItem(topmenu2, "!wj", "Top 20 Weirdjump");
	SetMenuOptionFlags(topmenu2, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(topmenu2, client, MENU_TIME_FOREVER);
}

public JumpTopMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: db_selectTopLj(param1);
			case 1: db_selectTopLjBlock(param1);
			case 2: db_selectTopBhop(param1);
			case 3: db_selectTopMultiBhop(param1);
			case 4: db_selectTopDropBhop(param1);
			case 5: db_selectTopWj(param1);
		}
	}
}


///SQL

public db_updateLjRecord(client)
{
	decl String:szQuery[255];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 255, sql_selectPlayerJumpLJ, szSteamId);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateLjRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateLjBlockRecord(client)
{
	decl String:szQuery[255];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 255, sql_selectPlayerJumpLJBlock, szSteamId);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateLjBlockRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateWjRecord(client)
{
	decl String:szQuery[255];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 255, sql_selectPlayerJumpWJ, szSteamId);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateWjRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateBhopRecord(client)
{
	decl String:szQuery[255];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 255, sql_selectPlayerJumpBhop, szSteamId);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateDropBhopRecord(client)
{
	decl String:szQuery[255];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 255, sql_selectPlayerJumpDropBhop, szSteamId);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateDropBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public db_updateMultiBhopRecord(client)
{
	decl String:szQuery[255];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 255, sql_selectPlayerJumpMultiBhop, szSteamId);
	if (!IsFakeClient(client))
		SQL_TQuery(g_hDb, SQL_UpdateMultiBhopRecordCallback, szQuery, client,DBPrio_Low);
}


public SQL_UpdateLjRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szSteamId[32];
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateLj, szName, g_js_fPersonal_Lj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], szSteamId);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpLj, szSteamId, szName, g_js_fPersonal_Lj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		db_viewLjRecord2(client);
	}
}

public SQL_viewBhop2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
		if (rank < 21 && rank < g_js_BhopRank[client])
		{
			g_js_BhopRank[client] = rank;
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i) && !IsFakeClient(i))
				{
					PrintToChat(i, "%t", "Jumpstats_BhopTop", MOSSGREEN, WHITE, LIGHTYELLOW, szName, rank, g_js_fPersonal_Bhop_Record[client]);
					PrintToConsole(i, "[JS] %s is now #%i in the Bunnyhop Top 20! [%.3f units]", szName, rank, g_js_fPersonal_Bhop_Record[client]);
				}
			}
		}
	}
}

public SQL_viewDropBhop2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
		if (rank < 21 && rank < g_js_DropBhopRank[client])
		{
			g_js_DropBhopRank[client] = rank;
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i) && !IsFakeClient(i))
				{
					PrintToChat(i, "%t", "Jumpstats_DropBhopTop", MOSSGREEN, WHITE, LIGHTYELLOW, szName, rank, g_js_fPersonal_DropBhop_Record[client]);
					PrintToConsole(i, "[JS] %s is now #%i in the Drop-Bunnyhop Top 20! [%.3f units]", szName, rank, g_js_fPersonal_DropBhop_Record[client]);
				}
			}
		}
	}
}

public db_viewMultiBhopRecord2(client)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 512, sql_selectPlayerJumpMultiBhop, szSteamId);
	SQL_TQuery(g_hDb, SQL_viewMultiBhop2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewMultiBhop2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);
		Format(szQuery, 512, sql_selectPlayerRankMultiBhop, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewMultiBhop2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewMultiBhop2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);
		if (rank < 21 && rank < g_js_MultiBhopRank[client])
		{
			g_js_MultiBhopRank[client] = rank;
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i) && !IsFakeClient(i))
				{
					PrintToChat(i, "%t", "Jumpstats_MultiBhopTop", MOSSGREEN, WHITE, LIGHTYELLOW, szName, rank, g_js_fPersonal_MultiBhop_Record[client]);
					PrintToConsole(i, "[JS] %s is now #%i in the Multi-Bunnyhop Top 20! [%.3f units]", szName, rank, g_js_fPersonal_MultiBhop_Record[client]);
				}
			}
		}
	}
}

public db_viewLjRecord2(client)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 512, sql_selectPlayerJumpLJ, szSteamId);
	SQL_TQuery(g_hDb, SQL_viewLj2RecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewLjBlockRecord2(client)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 512, sql_selectPlayerJumpLJBlock, szSteamId);
	SQL_TQuery(g_hDb, SQL_viewLjBlock2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewLjBlock2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);
		Format(szQuery, 512, sql_selectPlayerRankLjBlock, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewLjBlock2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}


public SQL_viewLj2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);
		Format(szQuery, 512, sql_selectPlayerRankLj, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewLj2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewLjBlock2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);

		if (rank < 21 && rank < g_js_LjBlockRank[client])
		{
			g_js_LjBlockRank[client] = rank;
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i) && !IsFakeClient(i))
				{
					PrintToChat(i, "%t", "Jumpstats_LjBlockTop", MOSSGREEN, WHITE, LIGHTYELLOW, szName, rank, g_js_Personal_LjBlock_Record[client],g_js_fPersonal_LjBlockRecord_Dist[client]);
					PrintToConsole(i, "[JS] %s is now #%i in the Longjump 20! [%i units block/%.3f units jump]", szName, rank, g_js_Personal_LjBlock_Record[client],g_js_fPersonal_LjBlockRecord_Dist[client]);
				}
			}
		}
	}
}

public SQL_viewLj2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);

		if (rank < 21 && rank < g_js_LjRank[client])
		{
			g_js_LjRank[client] = rank;
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i) && !IsFakeClient(i))
				{
					PrintToChat(i, "%t", "Jumpstats_LjTop", MOSSGREEN, WHITE, LIGHTYELLOW, szName, rank, g_js_fPersonal_Lj_Record[client]);
					PrintToConsole(i, "[JS] %s is now #%i in the Longjump 20! [%.3f units]", szName, rank, g_js_fPersonal_Lj_Record[client]);
				}
			}
		}
	}
}

public db_viewWjRecord2(client)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 512, sql_selectPlayerJumpWJ, szSteamId);
	SQL_TQuery(g_hDb, SQL_viewWj2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewWj2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);
		Format(szQuery, 512, sql_selectPlayerRankWJ, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewWj2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewWj2RecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szName[MAX_NAME_LENGTH];
		new rank = SQL_GetRowCount(hndl);
		new Handle:pack = data;
		ResetPack(pack);
		new client = ReadPackCell(pack);
		ReadPackString(pack, szName, MAX_NAME_LENGTH);
		CloseHandle(pack);

		if (rank < 21 && rank < g_js_WjRank[client])
		{
			g_js_WjRank[client] = rank;
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i) && !IsFakeClient(i))
				{
					PrintToChat(i, "%t", "Jumpstats_WjTop", MOSSGREEN, WHITE, LIGHTYELLOW, szName, rank, g_js_fPersonal_Wj_Record[client]);
					PrintToConsole(i, "[JS] %s is now #%i in the Weirdjump 20! [%.3f units]", szName, rank, g_js_fPersonal_Wj_Record[client]);
				}
			}
		}
	}
}

public SQL_UpdateLjBlockRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szSteamId[32];
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateLjBlock, szName, g_js_Personal_LjBlock_Record[client], g_js_fPersonal_LjBlockRecord_Dist[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], szSteamId);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
			}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpLjBlock , szSteamId, szName, g_js_Personal_LjBlock_Record[client], g_js_fPersonal_LjBlockRecord_Dist[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
			}
		db_viewLjBlockRecord2(client);
	}
}

public SQL_UpdateWjRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szSteamId[32];
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateWJ, szName, g_js_fPersonal_Wj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], szSteamId);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpWJ, szSteamId, szName, g_js_fPersonal_Wj_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
	}
	db_viewWjRecord2(client);
}

public SQL_UpdateDropBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		decl String:szSteamId[32];
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateDropBhop, szName, g_js_fPersonal_DropBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], szSteamId);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpDropBhop, szSteamId, szName, g_js_fPersonal_DropBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
	}
	db_viewDropBhopRecord2(client);
}

public db_viewDropBhopRecord2(client)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 512, sql_selectPlayerJumpDropBhop, szSteamId);
	SQL_TQuery(g_hDb, SQL_viewDropBhop2RecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_viewDropBhop2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);
		Format(szQuery, 512, sql_selectPlayerRankDropBhop, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewDropBhop2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_viewBhop2RecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szQuery[512];
		decl String:szName[MAX_NAME_LENGTH];
		decl String:szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		new Handle:pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szName);
		Format(szQuery, 512, sql_selectPlayerRankBhop, szSteamId);
		SQL_TQuery(g_hDb, SQL_viewBhop2RecordCallback2, szQuery, pack,DBPrio_Low);
	}
}

public SQL_UpdateBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		decl String:szSteamId[32];
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateBhop, szName, g_js_fPersonal_Bhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client], szSteamId);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpBhop, szSteamId, szName, g_js_fPersonal_Bhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		db_viewBhopRecord2(client);
	}
}

public db_viewBhopRecord2(client)
{
	decl String:szQuery[512];
	decl String:szSteamId[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
	else
		return;
	Format(szQuery, 512, sql_selectPlayerJumpBhop, szSteamId);
	SQL_TQuery(g_hDb, SQL_viewBhop2RecordCallback, szQuery, client,DBPrio_Low);
}


public SQL_UpdateMultiBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (IsValidClient(client))
	{
		decl String:szQuery[512];
		decl String:szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		decl String:szName[MAX_NAME_LENGTH*2+1];
		decl String:szSteamId[32];
		if (IsValidClient(client))
			GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
		else
			return;
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH*2+1);
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 512, sql_updateMultiBhop, szName, g_js_fPersonal_MultiBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_MultiBhop_Count[client],g_js_Sync_Final[client],g_flastHeight[client], szSteamId);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		else
		{
			Format(szQuery, 512, sql_insertPlayerJumpMultiBhop, szSteamId, szName, g_js_fPersonal_MultiBhop_Record[client], g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], g_js_Strafes_Final[client],g_js_MultiBhop_Count[client],g_js_Sync_Final[client],g_flastHeight[client]);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery,DBPrio_Low);
		}
		db_viewMultiBhopRecord2(client);
	}
}

public db_selectTopLj(client)
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectPlayerJumpTopLJ);
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopLJCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopLjBlock(client)
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectPlayerJumpTopLJBlock);
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopLJBlockCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopWj(client)
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectPlayerJumpTopWJ);
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopWJCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopBhop(client)
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectPlayerJumpTopBhop);
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopBhopCallback, szQuery, client,DBPrio_Low);
}

public db_selectTopDropBhop(client)
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectPlayerJumpTopDropBhop);
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopDropBhopCallback, szQuery, client,DBPrio_Low);
}


public db_selectTopMultiBhop(client)
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectPlayerJumpTopMultiBhop);
	SQL_TQuery(g_hDb, sql_selectPlayerJumpTopMultiBhopCallback, szQuery, client,DBPrio_Low);
}

public sql_selectPlayerJumpTopLJBlockCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	decl String:szSteamID[32];
	new ljblock;
	new Float:ljrecord;
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(LjBlockJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Block Longjump\n    Rank    Block   Distance           Strafes      Player");
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ljblock = SQL_FetchInt(hndl, 1);
			ljrecord = SQL_FetchFloat(hndl, 2);
			strafes = SQL_FetchInt(hndl, 3);
			SQL_FetchString(hndl, 4, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes);
			else
				Format(szStrafes, 32, "%i", strafes);
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %i     %.3f units       %s      » %s", i, ljblock,ljrecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %i     %.3f units       %s      » %s", i, ljblock,ljrecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}


public sql_selectPlayerJumpTopLJCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	decl String:szSteamID[32];
	new Float:ljrecord;
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(LjJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Longjump\n    Rank    Distance           Strafes      Player");
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ljrecord = SQL_FetchFloat(hndl, 1);
			strafes = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes);
			else
				Format(szStrafes, 32, "%i", strafes);
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopWJCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:ljrecord;
	new String:szStrafes[32];
	decl String:szSteamID[32];
	new strafes;
	new Handle:menu = CreateMenu(WjJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Weirdjump\n    Rank    Distance           Strafes      Player");
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ljrecord = SQL_FetchFloat(hndl, 1);
			strafes = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes);
			else
				Format(szStrafes, 32, "%i", strafes);
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, ljrecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopBhopCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:bhoprecord;
	decl String:szSteamID[32];
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(BhopJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Bunnyhop\n    Rank    Distance           Strafes      Player");
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			bhoprecord = SQL_FetchFloat(hndl, 1);
			strafes = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes);
			else
				Format(szStrafes, 32, "%i", strafes);
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopDropBhopCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:bhoprecord;
	decl String:szSteamID[32];
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(DropBhopJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Drop-Bunnyhop\n    Rank    Distance           Strafes      Player");
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			bhoprecord = SQL_FetchFloat(hndl, 1);
			strafes = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes);
			else
				Format(szStrafes, 32, "%i", strafes);
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, bhoprecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public sql_selectPlayerJumpTopMultiBhopCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	decl String:szValue[128];
	decl String:szName[64];
	new Float:multibhoprecord;
	decl String:szSteamID[32];
	new String:szStrafes[32];
	new strafes;
	new Handle:menu = CreateMenu(MultiBhopJumpMenuHandler1);
	SetMenuTitle(menu, "Top 20 Multi-Bunnyhop\n    Rank    Distance           Strafes      Player");
	SetMenuPagination(menu, 5);
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			multibhoprecord = SQL_FetchFloat(hndl, 1);
			strafes = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, szSteamID, 32);
			if (strafes < 10)
				Format(szStrafes, 32, " %i ", strafes);
			else
				Format(szStrafes, 32, "%i", strafes);
			if (i < 10)
					Format(szValue, 128, "[0%i.]    %.3f units      %s      » %s", i, multibhoprecord,szStrafes, szName);
				else
					Format(szValue, 128, "[%i.]    %.3f units      %s      » %s", i, multibhoprecord,szStrafes, szName);
			AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public LjBlockJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		JumpTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public LjJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		g_bdetailView[param1]=true;
		decl String:id[32];
		GetMenuItem(menu, param2, id, sizeof(id));
		db_viewJumpStats(param1, id);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public WjJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		g_bdetailView[param1]=true;
		decl String:id[32];
		GetMenuItem(menu, param2, id, sizeof(id));
		db_viewJumpStats(param1, id);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public BhopJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		g_bdetailView[param1]=true;
		decl String:id[32];
		GetMenuItem(menu, param2, id, sizeof(id));
		db_viewJumpStats(param1, id);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public DropBhopJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		g_bdetailView[param1]=true;
		decl String:id[32];
		GetMenuItem(menu, param2, id, sizeof(id));
		db_viewJumpStats(param1, id);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MultiBhopJumpMenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		g_bdetailView[param1]=true;
		decl String:id[32];
		GetMenuItem(menu, param2, id, sizeof(id));
		db_viewJumpStats(param1, id);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public SQL_CheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
}

public db_viewJumpStats(client, String:szSteamId[32])
{
	decl String:szQuery[1024];
	Format(szQuery, 1024, sql_selectJumpStats, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewJumpStatsCallback, szQuery, client,DBPrio_Low);
}

public SQL_ViewJumpStatsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		decl String:szSteamId[32];
		decl String:szName[17];
		decl String:szVr[255];

		//get the result
		SQL_FetchString(hndl, 0, szSteamId, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 1, szName, 17);
		new Float:bhoprecord = SQL_FetchFloat(hndl, 2);
		new Float:bhoppre = SQL_FetchFloat(hndl, 3);
		new Float:bhopmax = SQL_FetchFloat(hndl, 4);
		new bhopstrafes = SQL_FetchInt(hndl, 5);
		new bhopsync = SQL_FetchInt(hndl, 6);
		new Float:ljrecord = SQL_FetchFloat(hndl, 7);
		new Float:ljpre = SQL_FetchFloat(hndl, 8);
		new Float:ljmax = SQL_FetchFloat(hndl, 9);
		new ljstrafes = SQL_FetchInt(hndl, 10);
		new ljsync = SQL_FetchInt(hndl, 11);
		new Float:multibhoprecord = SQL_FetchFloat(hndl, 12);
		new Float:multibhoppre = SQL_FetchFloat(hndl, 13);
		new Float:multibhopmax = SQL_FetchFloat(hndl, 14);
		new multibhopstrafes = SQL_FetchInt(hndl, 15);
		new multibhopsync = SQL_FetchInt(hndl, 17);
		new Float:wjrecord = SQL_FetchFloat(hndl, 18);
		new Float:wjpre = SQL_FetchFloat(hndl, 19);
		new Float:wjmax = SQL_FetchFloat(hndl, 20);
		new wjstrafes = SQL_FetchInt(hndl, 21);
		new wjsync = SQL_FetchInt(hndl, 22);
		new Float:dropbhoprecord = SQL_FetchFloat(hndl, 23);
		new Float:dropbhoppre = SQL_FetchFloat(hndl, 24);
		new Float:dropbhopmax = SQL_FetchFloat(hndl, 25);
		new dropbhopstrafes = SQL_FetchInt(hndl, 26);
		new dropbhopsync = SQL_FetchInt(hndl, 27);
		new Float:ljheight = SQL_FetchFloat(hndl, 28);
		new Float:bhopheight = SQL_FetchFloat(hndl, 29);
		new Float:multibhopheight = SQL_FetchFloat(hndl, 30);
		new Float:dropbhopheight = SQL_FetchFloat(hndl, 31);
		new Float:wjheight = SQL_FetchFloat(hndl, 32);
		new ljblockdist = SQL_FetchInt(hndl, 33);
		new Float:ljblockrecord = SQL_FetchFloat(hndl, 34);
		new Float:ljblockpre = SQL_FetchFloat(hndl, 35);
		new Float:ljblockmax = SQL_FetchFloat(hndl, 36);
		new ljblockstrafes = SQL_FetchInt(hndl, 37);
		new ljblocksync = SQL_FetchInt(hndl, 38);
		new Float:ljblockheight = SQL_FetchFloat(hndl, 39);


		if (bhoprecord >0.0 || ljrecord > 0.0 || multibhoprecord > 0.0 || wjrecord > 0.0 || dropbhoprecord > 0.0 || ljblockdist > 0)
		{
			Format(szVr, 255, "JS: %s\nSteamID: %s\nType               Distance  Strafes Pre        Max      Height  Sync", szName, szSteamId);
			new Handle:menu = CreateMenu(JumpStatsMenuHandler);
			SetMenuTitle(menu, szVr);
			if (ljrecord > 0.0)
			{
				if (ljstrafes>9)
					Format(szVr, 255, "LJ:              %.3f     %i      %.2f   %.2f  %.1f    %i%c", ljrecord,ljstrafes,ljpre,ljmax,ljheight,ljsync,PERCENT);
				else
					Format(szVr, 255, "LJ:              %.3f       %i      %.2f   %.2f  %.1f    %i%c", ljrecord,ljstrafes,ljpre,ljmax,ljheight,ljsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);
			}
			if (ljblockdist > 0)
			{
				if (ljstrafes>9)
					Format(szVr, 255, "BlockLJ:     %i|%.1f %i      %.2f   %.2f  %.1f    %i%c", ljblockdist,ljblockrecord,ljblockstrafes,ljblockpre,ljblockmax,ljblockheight,ljblocksync,PERCENT);
				else
					Format(szVr, 255, "BlockLJ:     %i|%.1f   %i      %.2f   %.2f  %.1f    %i%c", ljblockdist,ljblockrecord,ljblockstrafes,ljblockpre,ljblockmax,ljblockheight,ljblocksync,PERCENT);
				AddMenuItem(menu, szVr, szVr);
			}
			if (bhoprecord > 0.0)
			{
				if (bhopstrafes>9)
					Format(szVr, 255, "Bhop:         %.3f     %i      %.2f   %.2f  %.1f    %i%c", bhoprecord,bhopstrafes,bhoppre,bhopmax,bhopheight,bhopsync,PERCENT);
				else
					Format(szVr, 255, "Bhop:         %.3f       %i      %.2f   %.2f  %.1f    %i%c", bhoprecord,bhopstrafes,bhoppre,bhopmax,bhopheight,bhopsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);
			}
			if (dropbhoprecord > 0.0)
			{
				if (dropbhopstrafes>9)
					Format(szVr, 255, "DropBhop: %.3f     %i      %.2f   %.2f  %.1f    %i%c", dropbhoprecord,dropbhopstrafes,dropbhoppre,dropbhopmax,dropbhopheight,dropbhopsync,PERCENT);
				else
					Format(szVr, 255, "DropBhop: %.3f       %i      %.2f   %.2f  %.1f    %i%c", dropbhoprecord,dropbhopstrafes,dropbhoppre,dropbhopmax,dropbhopheight,dropbhopsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);
			}
			if (multibhoprecord > 0.0)
			{
				if (multibhopstrafes>9)
					Format(szVr, 255, "MultiBhop: %.3f     %i      %.2f   %.2f  %.1f    %i%c", multibhoprecord,multibhopstrafes,multibhoppre,multibhopmax,multibhopheight,multibhopsync,PERCENT);
				else
					Format(szVr, 255, "MultiBhop: %.3f       %i      %.2f   %.2f  %.1f    %i%c", multibhoprecord,multibhopstrafes,multibhoppre,multibhopmax,multibhopheight,multibhopsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);
			}
			if (wjrecord > 0.0)
			{
				if (wjstrafes>9)
					Format(szVr, 255, "WJ:            %.3f     %i      %.2f   %.2f  %.1f    %i%c", wjrecord,wjstrafes,wjpre,wjmax,wjheight,wjsync,PERCENT);
				else
					Format(szVr, 255, "WJ:            %.3f       %i      %.2f   %.2f  %.1f    %i%c", wjrecord,wjstrafes,wjpre,wjmax,wjheight,wjsync,PERCENT);
				AddMenuItem(menu, szVr, szVr);
			}
			//SetMenuPagination(menu, 5);
			SetMenuPagination(menu, MENU_NO_PAGINATION);
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
		else
			PrintToChat(client, "%t", "noJumpRecords",MOSSGREEN,WHITE);


	}
	else
	{
		PrintToChat(client, "%t", "noJumpRecords",MOSSGREEN,WHITE);
	}
}

public JumpStatsMenuHandler(Handle:menu, MenuAction:action, param1,param2)
{
	if (action ==  MenuAction_Cancel || action ==  MenuAction_Select)
	{
		if (g_bdetailView[param1])
		{
			g_bdetailView[param1] = false;
			JumpTopMenu(param1);
		}
	}
}

public db_viewPersonalLJRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerJumpLJ, szSteamId);
	SQL_TQuery(g_hDb, SQL_LJRecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_LJRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_Lj_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_Lj_Record[client] > -1.0)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];
			if (IsValidClient(client))
			{
				GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
				Format(szQuery, 255, sql_selectPlayerRankLj, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewLjRecordCallback2, szQuery, client,DBPrio_Low);
			}
		}
		else
		{
			g_js_LjRank[client] = 99999999;
			g_js_fPersonal_Lj_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_LjRank[client] = 99999999;
		g_js_fPersonal_Lj_Record[client] = -1.0;
	}
}

public db_viewPersonalLJBlockRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerJumpLJBlock, szSteamId);
	SQL_TQuery(g_hDb, SQL_LJBlockRecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewPersonalBhopRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerJumpBhop, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public db_viewPersonalDropBhopRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerJumpDropBhop, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewDropBhopRecordCallback, szQuery, client,DBPrio_Low);
}


public db_viewPersonalWeirdRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerJumpWJ, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewWeirdRecordCallback, szQuery, client,DBPrio_Low);
}

stock FakePrecacheSound( const String:szPath[] )
{
	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
}

public db_viewPersonalMultiBhopRecord(client, String:szSteamId[32])
{
	decl String:szQuery[512];
	Format(szQuery, 512, sql_selectPlayerJumpMultiBhop, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewMultiBhopRecordCallback, szQuery, client,DBPrio_Low);
}

public SQL_LJBlockRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_Personal_LjBlock_Record[client] = SQL_FetchInt(hndl, 2);
		g_js_fPersonal_LjBlockRecord_Dist[client] = SQL_FetchFloat(hndl, 3);
		if (g_js_Personal_LjBlock_Record[client] > -1)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];
			if (IsValidClient(client))
			{
				GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
				Format(szQuery, 255, sql_selectPlayerRankLjBlock, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewLjBlockRecordCallback2, szQuery, client,DBPrio_Low);
			}
		}
		else
		{
		g_js_LjBlockRank[client] = 99999999;
		g_js_Personal_LjBlock_Record[client] = -1;
		g_js_fPersonal_LjBlockRecord_Dist[client] = -1.0;
		}
	}
	else
	{
		g_js_LjBlockRank[client] = 99999999;
		g_js_Personal_LjBlock_Record[client] = -1;
		g_js_fPersonal_LjBlockRecord_Dist[client] = -1.0;
	}
}

public SQL_viewLjRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_LjRank[client]= SQL_GetRowCount(hndl);
	}
}

public SQL_viewLjBlockRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_LjBlockRank[client]= SQL_GetRowCount(hndl);
	}
}

public SQL_ViewBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_Bhop_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_Bhop_Record[client] > -1.0)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];
			if (IsValidClient(client))
			{
				GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
				Format(szQuery, 255, sql_selectPlayerRankBhop, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewBhopRecordCallback2, szQuery, client,DBPrio_Low);
			}
		}
		else
		{
			g_js_BhopRank[client] = 99999999;
			g_js_fPersonal_Bhop_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_BhopRank[client] = 99999999;
		g_js_fPersonal_Bhop_Record[client] = -1.0;
	}
}

public SQL_ViewDropBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_DropBhop_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_DropBhop_Record[client] > -1.0)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];

			if (IsValidClient(client))
			{
				GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
				Format(szQuery, 255, sql_selectPlayerRankDropBhop, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewDropBhopRecordCallback2, szQuery, client,DBPrio_Low);
			}

		}
		else
		{
			g_js_DropBhopRank[client] = 99999999;
			g_js_fPersonal_DropBhop_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_DropBhopRank[client] = 99999999;
		g_js_fPersonal_DropBhop_Record[client] = -1.0;
	}
}

public SQL_viewDropBhopRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_DropBhopRank[client]= SQL_GetRowCount(hndl);
}

public SQL_ViewWeirdRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_Wj_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_Wj_Record[client] > -1.0)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];

			if (IsValidClient(client))
			{
				GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
				Format(szQuery, 255, sql_selectPlayerRankWJ, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewWeirdRecordCallback2, szQuery, client,DBPrio_Low);
			}

		}
		else
		{
			g_js_WjRank[client] = 99999999;
			g_js_fPersonal_Wj_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_WjRank[client] = 99999999;
		g_js_fPersonal_Wj_Record[client] = -1.0;
	}
}

public SQL_viewWeirdRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_WjRank[client]= SQL_GetRowCount(hndl);
}

public SQL_ViewMultiBhopRecordCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_js_fPersonal_MultiBhop_Record[client] = SQL_FetchFloat(hndl, 2);
		if (g_js_fPersonal_MultiBhop_Record[client] > -1.0)
		{
			decl String:szSteamId[32];
			decl String:szQuery[512];

			if (IsValidClient(client))
			{
				GetClientAuthId(client, AuthId_Steam2, szSteamId, 32);
				Format(szQuery, 255, sql_selectPlayerRankMultiBhop, szSteamId);
				SQL_TQuery(g_hDb, SQL_viewMultiBhopRecordCallback2, szQuery, client,DBPrio_Low);
			}
		}
		else
		{
			g_js_MultiBhopRank[client] = 99999999;
			g_js_fPersonal_MultiBhop_Record[client] = -1.0;
		}
	}
	else
	{
		g_js_MultiBhopRank[client] = 99999999;
		g_js_fPersonal_MultiBhop_Record[client] = -1.0;
	}
}

public SQL_viewBhopRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_BhopRank[client]= SQL_GetRowCount(hndl);
}

public SQL_viewMultiBhopRecordCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_js_MultiBhopRank[client]= SQL_GetRowCount(hndl);
}

//admin stuff
public Action:Admin_DropPlayerJump(client, args)
{
	db_dropPlayerJump(client);
	return Plugin_Handled;
}

public Action:Admin_ResetAllLjRecords(client, args)
{
 	decl String:szQuery[255];
	Format(szQuery, 255, "UPDATE playerjumpstats SET ljrecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	PrintToConsole(client, "lj records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			g_js_LjRank[i] = 99999999;
			g_js_fPersonal_Lj_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllWjRecords(client, args)
{
	decl String:szQuery[255];
	Format(szQuery, 255, "UPDATE playerjumpstats SET wjrecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	PrintToConsole(client, "wj records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			g_js_WjRank[i] = 99999999;
			g_js_fPersonal_Wj_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllBhopRecords(client, args)
{
 	decl String:szQuery[255];
	Format(szQuery, 255, "UPDATE playerjumpstats SET bhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	PrintToConsole(client, "bhop records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			g_js_BhopRank[i] = 99999999;
			g_js_fPersonal_Bhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllDropBhopRecords(client, args)
{
 	decl String:szQuery[255];
	Format(szQuery, 255, "UPDATE playerjumpstats SET dropbhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	PrintToConsole(client, "dropbhop records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			g_js_DropBhopRank[i] = 99999999;
			g_js_fPersonal_DropBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllMultiBhopRecords(client, args)
{
 	decl String:szQuery[255];
	Format(szQuery, 255, "UPDATE playerjumpstats SET multibhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	PrintToConsole(client, "multibhop records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			g_js_MultiBhopRank[i] = 99999999;
			g_js_fPersonal_MultiBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllLjBlockRecords(client, args)
{
 	decl String:szQuery[255];
	Format(szQuery, 255, "UPDATE playerjumpstats SET ljblockdist=-1");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	PrintToConsole(client, "ljblock records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			g_js_MultiBhopRank[i] = 99999999;
			g_js_fPersonal_MultiBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetLjRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetljrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg);
		}
		db_resetPlayerLjRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetLjBlockRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetljblockrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg);
		}
		db_resetPlayerLjBlockRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetWjRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetwjrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg);
		}
		db_resetPlayerWJRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetPlayerJumpstats(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayerjumpstats <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg);
		}
		db_resetPlayerJumpstats(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetDropBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetdropbhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg);
		}
		db_resetPlayerDropBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}


public Action:Admin_ResetBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetbhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg);
		}
		db_resetPlayerBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetMultiBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetmultibhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg);
		}
		db_resetPlayerMultiBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}


public db_resetPlayerBhopRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_EscapeString(g_hDb, steamid, szsteamid, 128*2+1);
	Format(szQuery, 255, sql_resetBhopRecord, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, pack);
	PrintToConsole(client, "bhop record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			decl String:szSteamId2[32];
			GetClientAuthId(client, AuthId_Steam2, szSteamId2, 32);
			if(StrEqual(szSteamId2,szsteamid))
			{
				g_js_BhopRank[i] = 99999999;
				g_js_fPersonal_Bhop_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerDropBhopRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_EscapeString(g_hDb, steamid, szsteamid, 128*2+1);
	Format(szQuery, 255, sql_resetDropBhopRecord, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, pack);
	PrintToConsole(client, "dropbhop record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			decl String:szSteamId2[32];
			GetClientAuthId(client, AuthId_Steam2, szSteamId2, 32);
			if(StrEqual(szSteamId2,szsteamid))
			{
				g_js_DropBhopRank[i] = 99999999;
				g_js_fPersonal_DropBhop_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerWJRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_EscapeString(g_hDb, steamid, szsteamid, 128*2+1);
	Format(szQuery, 255, sql_resetWJRecord, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, pack);
	PrintToConsole(client, "wj record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			decl String:szSteamId2[32];
			GetClientAuthId(client, AuthId_Steam2, szSteamId2, 32);
			if(StrEqual(szSteamId2,szsteamid))
			{
				g_js_WjRank[i] = 99999999;
				g_js_fPersonal_Wj_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerJumpstats(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_EscapeString(g_hDb, steamid, szsteamid, 128*2+1);
	Format(szQuery, 255, sql_resetJumpStats, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, pack);
	PrintToConsole(client, "jumpstats cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			decl String:szSteamId2[32];
			GetClientAuthId(client, AuthId_Steam2, szSteamId2, 32);
			if(StrEqual(szSteamId2,szsteamid))
			{
				g_js_MultiBhopRank[i] = 99999999;
				g_js_fPersonal_MultiBhop_Record[i] = -1.0;
				g_js_WjRank[i] = 99999999;
				g_js_fPersonal_Wj_Record[i] = -1.0;
				g_js_DropBhopRank[i] = 99999999;
				g_js_fPersonal_DropBhop_Record[i] = -1.0;
				g_js_BhopRank[i] = 99999999;
				g_js_fPersonal_Bhop_Record[i] = -1.0;
				g_js_LjRank[i] = 99999999;
				g_js_fPersonal_Lj_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerMultiBhopRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_EscapeString(g_hDb, steamid, szsteamid, 128*2+1);
	Format(szQuery, 255, sql_resetMultiBhopRecord, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, pack);
	PrintToConsole(client, "multibhop record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			decl String:szSteamId2[32];
			GetClientAuthId(client, AuthId_Steam2, szSteamId2, 32);
			if(StrEqual(szSteamId2,szsteamid))
			{
				g_js_MultiBhopRank[i] = 99999999;
				g_js_fPersonal_MultiBhop_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerLjRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_EscapeString(g_hDb, steamid, szsteamid, 128*2+1);
	Format(szQuery, 255, sql_resetLjRecord, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, pack);
	PrintToConsole(client, "lj record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			decl String:szSteamId2[32];
			GetClientAuthId(client, AuthId_Steam2, szSteamId2, 32);
			if(StrEqual(szSteamId2,szsteamid))
			{
				g_js_LjRank[i] = 99999999;
				g_js_fPersonal_Lj_Record[i] = -1.0;
			}
		}
	}
}

public db_resetPlayerLjBlockRecord(client, String:steamid[128])
{
	decl String:szQuery[255];
	decl String:szsteamid[128*2+1];
	SQL_EscapeString(g_hDb, steamid, szsteamid, 128*2+1);
	Format(szQuery, 255, sql_resetLjBlockRecord, szsteamid);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, steamid);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, pack);
	PrintToConsole(client, "ljblock record cleared (%s).", szsteamid);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			decl String:szSteamId2[32];
			GetClientAuthId(client, AuthId_Steam2, szSteamId2, 32);
			if(StrEqual(szSteamId2,szsteamid))
			{
				g_js_LjBlockRank[i] = 99999999;
				g_js_Personal_LjBlock_Record[i] = -1;
			}
		}
	}
}

public db_dropPlayerJump(client)
{
	decl String:szQuery[255];
	Format(szQuery, 255, "UPDATE playerjumpstats SET wjrecord=-1.0, bhoprecord=-1.0, ljrecord=-1.0,dropbhoprecord=-1.0,multibhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);
	PrintToConsole(client, "jumpstats records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			g_js_LjRank[i] = 99999999;
			g_js_fPersonal_Lj_Record[i] = -1.0;
			g_js_WjRank[i] = 99999999;
			g_js_fPersonal_Wj_Record[i] = -1.0;
			g_js_BhopRank[i] = 99999999;
			g_js_fPersonal_Bhop_Record[i] = -1.0;
			g_js_DropBhopRank[i] = 99999999;
			g_js_fPersonal_DropBhop_Record[i] = -1.0;
			g_js_MultiBhopRank[i] = 99999999;
			g_js_fPersonal_MultiBhop_Record[i] = -1.0;
		}
	}
}
