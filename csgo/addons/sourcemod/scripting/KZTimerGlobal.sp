#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>
#include <cstrike>
#include <button>
#include <entity>
#include <smlib>
#include <kztimer>
#include <geoip>
#include <colors>
#include <basecomm>
#include <dhooks>
#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#include <sourcebans>
#include <mapchooser>

//API
#include <KZTimer-API>
#include <updater>
bool gB_KZTimerAPI = false;

#define VERSION "1.91_1"
#define PLUGIN_VERSION 200
#define UPDATER "http://updater.kztimerglobal.com/KZTimerGlobal.txt"

#pragma tabsize 0
#define ADMIN_LEVEL ADMFLAG_UNBAN
#define ADMIN_LEVEL2 ADMFLAG_ROOT
#define MYSQL 0
#define SQLITE 1
#define WHITE 0x01
#define DARKRED 0x02
#define PURPLE 0x03
#define GREEN 0x04
#define MOSSGREEN 0x05
#define LIMEGREEN 0x06
#define RED 0x07
#define GRAY 0x08
#define YELLOW 0x09
#define ORANGE 0x10
#define DARKGREY 0x0A
#define BLUE 0x0B
#define DARKBLUE 0x0C
#define LIGHTBLUE 0x0D
#define PINK 0x0E
#define LIGHTRED 0x0F
#define QUOTE 0x22
#define PERCENT 0x25
#define CPLIMIT 50
#define MAX_PR_PLAYERS 1066
#define MAX_BHOPBLOCKS 2048
#define BLOCK_TELEPORT 0.05
#define BLOCK_COOLDOWN 0.1
#define HIDE_CHAT ( 1<<7 )
#define SF_BUTTON_DONTMOVE (1<<0)
#define SF_BUTTON_TOUCH_ACTIVATES (1<<8)
#define SF_DOOR_PTOUCH (1<<10)
#define BM_MAGIC 0xBAADF00D
#define BINARY_FORMAT_VERSION 0x02
#define ADDITIONAL_FIELD_TELEPORTED_ORIGIN (1<<0)
#define ADDITIONAL_FIELD_TELEPORTED_ANGLES (1<<1)
#define ADDITIONAL_FIELD_TELEPORTED_VELOCITY (1<<2)
#define FRAME_INFO_SIZE 15
#define AT_SIZE 10
#define ORIGIN_SNAPSHOT_INTERVAL 150
#define FILE_HEADER_LENGTH 138 // 74
#define SOURCEBANS_AVAILABLE()	(GetFeatureStatus(FeatureType_Native, "SBBanPlayer") == FeatureStatus_Available)
#define MANIFEST_FOLDER         "maps/"
#define MANIFEST_EXTENSION      "_particles.txt"
#pragma dynamic 131072
#pragma tabsize 0


enum FrameInfo
{
	playerButtons = 0,
	playerImpulse,
	Float:actualVelocity[3],
	Float:predictedVelocity[3],
	Float:predictedAngles[2],
	CSWeaponID:newWeapon,
	playerSubtype,
	playerSeed,
	additionalFields,
	pause,
}

enum AdditionalTeleport
{
	Float:atOrigin[3],
	Float:atAngles[3],
	Float:atVelocity[3],
	atFlags
}

enum FileHeader
{
	FH_binaryFormatVersion = 0,
	String:FH_player_ip[32],
	String:FH_steamID[32],
	String:FH_Time[32],
	String:FH_Playername[32],
	FH_Checkpoints,
	FH_tickCount,
	Float:FH_initialPosition[3],
	Float:FH_initialAngles[3],
	Handle:FH_frames
}

enum VelocityOverride
{
	VelocityOvr_None = 0,
	VelocityOvr_Velocity,
	VelocityOvr_OnlyWhenNegative,
	VelocityOvr_InvertReuseVelocity
}

enum EJoinTeamReason
{
	k_OneTeamChange=0,
	k_TeamsFull=1,
	k_TTeamFull=2,
	k_CTTeamFull=3
}

// kztimer decl.
new g_DbType;
new g_ReplayRecordTps;
new Handle:g_hFWD_TimerStart;
new Handle:g_hFWD_TimerStopped;
new Handle:g_hFWD_TimerStoppedValid;
new Handle:g_hFWD_OnJumpstatStarted;
new Handle:g_hFWD_OnJumpstatCompleted;
new Handle:g_hFWD_OnJumpstatInvalid;
new Handle:g_hReplayRouteArray = INVALID_HANDLE;
new Handle:g_hFullAlltalk = INVALID_HANDLE;
new Handle:g_hStaminaLandCost = INVALID_HANDLE;
new Handle:g_hMaxSpeed = INVALID_HANDLE;
new Handle:g_hWaterAccelerate = INVALID_HANDLE;
new Handle:g_hStaminaJumpCost = INVALID_HANDLE;
new Handle:g_hGravity = INVALID_HANDLE;
new Handle:g_hAirAccelerate = INVALID_HANDLE;
new Handle:g_hFriction = INVALID_HANDLE;
new Handle:g_hAccelerate = INVALID_HANDLE;
new Handle:g_hMaxVelocity = INVALID_HANDLE;
new Handle:g_hCheats = INVALID_HANDLE;
new Handle:g_hDropKnifeEnable = INVALID_HANDLE;
new Handle:g_hMaxRounds = INVALID_HANDLE;
new Handle:g_hEnableBunnyhoping = INVALID_HANDLE;
new Handle:g_hsv_ladder_scale_speed = INVALID_HANDLE;
new Handle:g_hAccelerateUseWeaponSpeed = INVALID_HANDLE;
new Handle:g_hWaterMovespeedMultiplier = INVALID_HANDLE;
new Handle:g_hWaterSwimMode = INVALID_HANDLE;
new Handle:g_hWeaponEncumbranceScale = INVALID_HANDLE;
new Handle:g_hAirMaxWishspeed = INVALID_HANDLE;
new Handle:g_hLedgeMantleHelper = INVALID_HANDLE;
new Handle:g_hStandableNormal = INVALID_HANDLE;
new Handle:g_hWalkableNormal = INVALID_HANDLE;

new Handle:g_hAmmoGrenadeLimitBumpmine = INVALID_HANDLE;
new Handle:g_hBumpmineDetonateDelay = INVALID_HANDLE;
new Handle:g_hShieldSpeedDeployed = INVALID_HANDLE;
new Handle:g_hShieldSpeedHolstered = INVALID_HANDLE;
new Handle:g_hExojumpJumpbonusForward = INVALID_HANDLE;
new Handle:g_hExojumpJumpbonusUp = INVALID_HANDLE;
new Handle:g_hExojumpJumpcost = INVALID_HANDLE;
new Handle:g_hExojumpLandcost = INVALID_HANDLE;
new Handle:g_hJumpImpulseExojumpMultiplier = INVALID_HANDLE;

//Test
new Handle:g_hAutoBhop = INVALID_HANDLE;
new Handle:g_hClampVel = INVALID_HANDLE;
new Handle:g_hJumpImpulse = INVALID_HANDLE;
new bool:g_bCantJoin[MAXPLAYERS + 1];
new bool:g_bCantPause[MAXPLAYERS + 1];
new bool:g_bGlobalDisconnected[MAXPLAYERS+1];
new bool:g_bDisconnected[MAXPLAYERS+1];
new Float:g_fUnpauseDelay[MAXPLAYERS+1];
new bool:g_bUnpausedSoon[MAXPLAYERS+1];

new Handle:g_hTeleport = INVALID_HANDLE;
new Handle:g_hMainMenu = INVALID_HANDLE;
new Handle:g_hSDK_Touch = INVALID_HANDLE;
new Handle:g_hAdminMenu = INVALID_HANDLE;
new Handle:g_MapList = INVALID_HANDLE;
new Handle:g_hDb = INVALID_HANDLE;
new Handle:hStartPress = INVALID_HANDLE;
new Handle:hEndPress = INVALID_HANDLE;
new Handle:g_hRecording[MAXPLAYERS+1];
new Handle:g_hSpecAdvertTimer;
new Handle:g_hLoadedRecordsAdditionalTeleport = INVALID_HANDLE;
new Handle:g_hBotMimicsRecord[MAXPLAYERS+1] = {INVALID_HANDLE,...};
new Handle:g_hP2PRed[MAXPLAYERS+1] = { INVALID_HANDLE,... };
new Handle:g_hP2PGreen[MAXPLAYERS+1] = { INVALID_HANDLE,... };
new Handle:g_hRecordingAdditionalTeleport[MAXPLAYERS+1];
new Handle:g_hclimbersmenu[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:g_hRouteArray[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:g_hTopJumpersMenu[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:g_hWelcomeMsg = INVALID_HANDLE;
new String:g_sWelcomeMsg[512];
new Handle:g_hReplayBotPlayerModel = INVALID_HANDLE;
new String:g_sReplayBotPlayerModel[256];
new Handle:g_hReplayBotArmModel = INVALID_HANDLE;
new String:g_sReplayBotArmModel[256];
new Handle:g_hReplayBotPlayerModel2 = INVALID_HANDLE;
new String:g_sReplayBotPlayerModel2[256];
new Handle:g_hReplayBotArmModel2 = INVALID_HANDLE;
new String:g_sReplayBotArmModel2[256];
new Handle:g_hPlayerModel = INVALID_HANDLE;
new String:g_sPlayerModel[256];
new Handle:g_hArmModel = INVALID_HANDLE;
new String:g_sArmModel[256];
new Handle:g_hdist_good_weird = INVALID_HANDLE;
new Float:g_dist_min_weird;
new Handle:g_hdist_impressive_weird = INVALID_HANDLE;
new Float:g_dist_impressive_weird;
new Handle:g_hdist_perfect_weird = INVALID_HANDLE;
new Float:g_dist_perfect_weird;
new Handle:g_hdist_godlike_weird = INVALID_HANDLE;
new Float:g_dist_god_weird;
new Handle:g_hdist_good_dropbhop = INVALID_HANDLE;
new Float:g_dist_min_dropbhop;
new Handle:g_hdist_impressive_dropbhop = INVALID_HANDLE;
new Float:g_dist_impressive_dropbhop;
new Handle:g_hdist_perfect_dropbhop = INVALID_HANDLE;
new Float:g_dist_perfect_dropbhop;
new Handle:g_hdist_godlike_dropbhop = INVALID_HANDLE;
new Float:g_dist_god_dropbhop;
new Handle:g_hdist_good_bhop = INVALID_HANDLE;
new Float:g_dist_min_bhop;
new Handle:g_hdist_impressive_bhop = INVALID_HANDLE;
new Float:g_dist_impressive_bhop;
new Handle:g_hdist_perfect_bhop = INVALID_HANDLE;
new Float:g_dist_perfect_bhop;
new Handle:g_hdist_godlike_bhop = INVALID_HANDLE;
new Float:g_dist_god_bhop;
new Handle:g_hdist_good_multibhop = INVALID_HANDLE;
new Float:g_dist_min_multibhop;
new Handle:g_hdist_impressive_multibhop = INVALID_HANDLE;
new Float:g_dist_impressive_multibhop;
new Handle:g_hdist_perfect_multibhop = INVALID_HANDLE;
new Float:g_dist_perfect_multibhop;
new Handle:g_hdist_godlike_multibhop = INVALID_HANDLE;
new Float:g_dist_god_multibhop;
new Handle:g_hdist_good_ladder = INVALID_HANDLE;
new Float:g_dist_min_ladder;
new Handle:g_hdist_perfect_ladder = INVALID_HANDLE;
new Float:g_dist_perfect_ladder;
new Handle:g_hdist_impressive_ladder = INVALID_HANDLE;
new Float:g_dist_impressive_ladder;
new Handle:g_hdist_godlike_ladder = INVALID_HANDLE;
new Float:g_dist_god_ladder;
new Handle:g_hBanDuration = INVALID_HANDLE;
new Float:g_fBanDuration;
new Handle:g_hdist_good_lj = INVALID_HANDLE;
new Float:g_dist_min_lj;
new Handle:g_hdist_impressive_lj = INVALID_HANDLE;
new Float:g_dist_impressive_lj;
new Handle:g_hdist_perfect_lj = INVALID_HANDLE;
new Float:g_dist_perfect_lj;
new Handle:g_hdist_godlike_lj = INVALID_HANDLE;
new Float:g_dist_god_lj;
new Handle:g_hdist_good_countjump = INVALID_HANDLE;
new Float:g_dist_min_countjump;
new Handle:g_hdist_impressive_countjump = INVALID_HANDLE;
new Float:g_dist_impressive_countjump;
new Handle:g_hdist_perfect_countjump = INVALID_HANDLE;
new Float:g_dist_perfect_countjump;
new Handle:g_hdist_godlike_countjump = INVALID_HANDLE;
new Float:g_dist_god_countjump;
new Handle:g_hBhopSpeedCap = INVALID_HANDLE;
new Float:g_fBhopSpeedCap;
new Handle:g_hMaxBhopPreSpeed = INVALID_HANDLE;
new Float:g_fMaxBhopPreSpeed;
new Handle:g_hcvarRestore = INVALID_HANDLE;
new bool:g_bRestore;
new Handle:g_hAllowRoundEndCvar = INVALID_HANDLE;
new bool:g_bAllowRoundEndCvar;
new Handle:g_hNoClipS = INVALID_HANDLE;
new bool:g_bNoClipS;
new Handle:g_hReplayBot = INVALID_HANDLE;
new bool:g_bReplayBot;
new Handle:g_hAutoBan = INVALID_HANDLE;
new bool:g_bAutoBan;
new Handle:g_hEnableChatProcessing = INVALID_HANDLE;
new bool:g_bEnableChatProcessing;
new Handle:g_hEnableGroupAdverts = INVALID_HANDLE;
new bool:g_bEnableGroupAdverts;
new Handle:g_hSlayPlayers = INVALID_HANDLE;
new bool:g_bSlayPlayers;
new Handle:g_hDoubleDuckCvar = INVALID_HANDLE;
new bool:g_bDoubleDuckCvar;
new Handle:g_hPauseServerside = INVALID_HANDLE;
new bool:g_bPauseServerside;
new Handle:g_hChallengePoints = INVALID_HANDLE;
new bool:g_bChallengePoints;
new Handle:g_hAutoBhopConVar = INVALID_HANDLE;
new bool:g_bAutoBhopConVar;
new bool:g_bAutoBhop;
new Handle:g_hTierMessages = INVALID_HANDLE;
new bool:g_bTierMessages;
new Handle:g_hVipClantag = INVALID_HANDLE;
new bool:g_bVipClantag;
new Handle:g_hDynamicTimelimit = INVALID_HANDLE;
new bool:g_bDynamicTimelimit;
new Handle:g_hAdminClantag = INVALID_HANDLE;
new bool:g_bAdminClantag;
new Handle:g_hConnectMsg = INVALID_HANDLE;
new bool:g_bConnectMsg;
new Handle:g_hRadioCommands = INVALID_HANDLE;
new bool:g_bRadioCommands;
new Handle:g_hInfoBot = INVALID_HANDLE;
new bool:g_bInfoBot;
new Handle:g_hAttackSpamProtection = INVALID_HANDLE;
new bool:g_bAttackSpamProtection;
new Handle:g_hGoToServer = INVALID_HANDLE;
new bool:g_bGoToServer;
new Handle:g_hPlayerSkinChange = INVALID_HANDLE;
new bool:g_bPlayerSkinChange;
new Handle:g_hJumpStats = INVALID_HANDLE;
new bool:g_bJumpStats;
new Handle:g_hCountry = INVALID_HANDLE;
new bool:g_bCountry;
new Handle:g_hAutoRespawn = INVALID_HANDLE;
new bool:g_bAutoRespawn;
new Handle:g_hGlobalBanListArray = INVALID_HANDLE;
new Handle:g_hAllowCheckpoints = INVALID_HANDLE;
new bool:g_bAllowCheckpoints;
new Handle:g_hSingleTouch = INVALID_HANDLE;
new bool:g_bSingleTouch;
new Handle:g_hPointSystem = INVALID_HANDLE;
new bool:g_bPointSystem;
new Handle:g_hCleanWeapons = INVALID_HANDLE;
new bool:g_bCleanWeapons;
new Handle:g_hcvargodmode = INVALID_HANDLE;
new bool:g_bAutoTimer;
new Handle:g_hAutoTimer = INVALID_HANDLE;
new bool:g_bgodmode;
new Handle:g_hEnforcer = INVALID_HANDLE;
new bool:g_bEnforcer;
new Handle:g_hPreStrafe = INVALID_HANDLE;
new bool:g_bPreStrafe;
new Handle:g_hMapEnd = INVALID_HANDLE;
new bool:g_bMapEnd;
new Handle:g_hTransPlayerModels = INVALID_HANDLE;
new g_TransPlayerModels;
new Handle:g_hAutohealing_Hp = INVALID_HANDLE;
new g_Autohealing_Hp;
new Handle:g_hDefaultLanguage = INVALID_HANDLE;
new g_DefaultLanguage;
new Handle:g_hTeam_Restriction = INVALID_HANDLE;
new g_Team_Restriction;
new Handle:g_hExtraPoints = INVALID_HANDLE;
new g_ExtraPoints;
new Handle:g_hExtraPoints2 = INVALID_HANDLE;
new g_ExtraPoints2;
new Handle:g_hSpecsAdvert = INVALID_HANDLE;
new Float:g_fSpecsAdvert;
new Handle:g_hMinSkillGroup = INVALID_HANDLE;
new g_MinSkillGroup;
new Handle:g_hReplayBotProColor = INVALID_HANDLE;
new Handle:g_hReplayBotTpColor = INVALID_HANDLE;
new Float:g_fMapStartTime;
new Float:g_fBhopDoorSp[300];
new Float:g_fSpawnTime[MAXPLAYERS+1];
new Float:g_fTeleportValidationTime[MAXPLAYERS+1];
new Float:g_fvMeasurePos[MAXPLAYERS+1][2][3];
new Float:g_fafAvgJumps[MAXPLAYERS+1] = {1.0, ...};
new Float:g_fafAvgSpeed[MAXPLAYERS+1] = {250.0, ...};
new Float:g_favVEL[MAXPLAYERS+1][3];
new Float:g_fafAvgPerfJumps[MAXPLAYERS+1] = {0.3333, ...};
new Float:g_fLastJump[MAXPLAYERS+1] = {0.0, ...};
new Float:g_fBlockHeight[MAXPLAYERS + 1];
new Float:g_fEdgeVector[MAXPLAYERS + 1][3];
new Float:g_fEdgeDistJumpOff[MAXPLAYERS + 1];
new Float:g_fEdgePoint1[MAXPLAYERS + 1][3];
new Float:g_fEdgePoint2[MAXPLAYERS + 1][3];
new Float:g_fOriginBlock[MAXPLAYERS + 1][2][3];
new Float:g_fDestBlock[MAXPLAYERS + 1][2][3];
new Float:g_fStartTime[MAXPLAYERS+1];
new Float:g_fFinalTime[MAXPLAYERS+1];
new Float:g_fPauseTime[MAXPLAYERS+1];
new Float:g_fLastTimeNoClipUsed[MAXPLAYERS+1];
new Float:g_fLastOverlay[MAXPLAYERS+1];
new Float:g_fStartPauseTime[MAXPLAYERS+1];
new Float:g_fPlayerCordsLastPosition[MAXPLAYERS+1][3];
new Float:g_fPlayerLastTime[MAXPLAYERS+1];
new Float:g_fPlayerAnglesLastPosition[MAXPLAYERS+1][3];
new Float:g_fPlayerCords[MAXPLAYERS+1][CPLIMIT][3];
new Float:g_fPlayerAngles[MAXPLAYERS+1][CPLIMIT][3];
new Float:g_fPlayerCordsRestart[MAXPLAYERS+1][3];
new Float:g_fPlayerAnglesRestart[MAXPLAYERS+1][3];
new Float:g_fPlayerSSPPos[MAXPLAYERS+1][3];
new Float:g_fPlayerSSPAngles[MAXPLAYERS+1][3];
new Float:g_fPlayerCordsRestore[MAXPLAYERS+1][3];
new g_PlayerEntityFlagRestore[MAXPLAYERS+1];
new Float:g_fPlayerAnglesRestore[MAXPLAYERS+1][3];
new Float:g_fPlayerCordsUndoTp[MAXPLAYERS+1][3];
new Float:g_fPlayerAnglesUndoTp[MAXPLAYERS+1][3];
new Float:g_fLastPositionOnGround[MAXPLAYERS+1][3];
new Float:g_fPersonalRecord[MAXPLAYERS+1];
new Float:g_fPersonalRecordPro[MAXPLAYERS+1];
new Float:g_fCurrentRunTime[MAXPLAYERS+1];
new Float:g_fVelocityModifierLastChange[MAXPLAYERS+1];
new Float:g_fLastTimeButtonSound[MAXPLAYERS+1];
new Float:g_fLastChatMsg[MAXPLAYERS+1];
new Float:g_fPlayerConnectedTime[MAXPLAYERS+1];
new Float:g_fStartCommandUsed_LastTime[MAXPLAYERS+1];
new Float:g_fProfileMenuLastQuery[MAXPLAYERS+1];
new Float:g_favg_protime;
new Float:g_favg_tptime;
new Float:g_js_fJump_JumpOff_Pos[MAXPLAYERS+1][3];
new Float:g_js_fJump_Landing_Pos[MAXPLAYERS+1][3];
new Float:g_js_fJump_JumpOff_PosLastHeight[MAXPLAYERS+1];
new Float:g_js_fJump_DistanceX[MAXPLAYERS+1];
new Float:g_js_fJump_DistanceZ[MAXPLAYERS+1];
new Float:g_js_fJump_Distance[MAXPLAYERS+1];
new Float:g_js_fPreStrafe[MAXPLAYERS+1];
new Float:g_js_fDropped_Units[MAXPLAYERS+1];
new Float:g_js_fMax_Speed[MAXPLAYERS+1];
new Float:g_js_fMax_Speed_Final[MAXPLAYERS +1];
new Float:g_js_fMax_Height[MAXPLAYERS+1];
new Float:g_js_AvgLadderSpeed[MAXPLAYERS+1];
new Float:g_js_Good_Sync_Frames[MAXPLAYERS+1];
new Float:g_js_Sync_Frames[MAXPLAYERS+1];
new Float:g_js_Strafe_Air_Time[MAXPLAYERS+1][25];
new Float:g_js_Strafe_Good_Sync[MAXPLAYERS+1][25];
new g_js_Strafe_Frames[MAXPLAYERS+1][25];
new Float:g_js_Strafe_Gained[MAXPLAYERS+1][25];
new Float:g_js_Strafe_Max_Speed[MAXPLAYERS+1][25];
new Float:g_js_Strafe_Lost[MAXPLAYERS+1][25];
new Float:g_js_fPersonal_CJ_Record[MAX_PR_PLAYERS]=-1.0;
new Float:g_js_fPersonal_Wj_Record[MAX_PR_PLAYERS]=-1.0;
new Float:g_js_fPersonal_DropBhop_Record[MAX_PR_PLAYERS]=-1.0;
new Float:g_js_fPersonal_Bhop_Record[MAX_PR_PLAYERS]=-1.0;
new Float:g_js_fPersonal_MultiBhop_Record[MAX_PR_PLAYERS]=-1.0;
new Float:g_js_fPersonal_Lj_Record[MAX_PR_PLAYERS]=-1.0;
new Float:g_js_fPersonal_LadderJump_Record[MAX_PR_PLAYERS]=-1.0;
new Float:g_js_fPersonal_LjBlockRecord_Dist[MAX_PR_PLAYERS]=-1.0;
new Float:g_fLastSpeed[MAXPLAYERS+1];
new Float:g_fLastPauseUsed[MAXPLAYERS+1];
new Float:g_fJumpButtonLastTimeUsed[MAXPLAYERS+1];
new Float:g_vCurrent[MAXPLAYERS + 1][3];
new Float:g_vLast[MAXPLAYERS + 1][3];
new Float:g_fCrouchButtonLastTimeUsed[MAXPLAYERS+1];
new Float:g_fFailedLandingPos[MAXPLAYERS+1][3];
new Float:g_fAirTime[MAXPLAYERS+1];
new Float:g_fLastTimeDoubleDucked[MAXPLAYERS+1];
new Float:g_fJumpOffTime[MAXPLAYERS+1];
new Float:g_fLandingTime[MAXPLAYERS+1];
new Float:g_fLastUndo[MAXPLAYERS +1];
new Float:g_flastHeight[MAXPLAYERS +1];
new Float:g_fInitialPosition[MAXPLAYERS+1][3];
new Float:g_fInitialAngles[MAXPLAYERS+1][3];
new Float:g_PrestrafeVelocity[MAXPLAYERS+1];
new Float:g_fChallenge_RequestTime[MAXPLAYERS+1];
new Float:g_fLastPosition[MAXPLAYERS + 1][3];
new Float:g_fMovingDirection[MAXPLAYERS+1];
new Float:g_fLastAngles[MAXPLAYERS + 1][3];
new Float:g_fLastTimeBhopBlock[MAXPLAYERS+1];
new Float:g_js_fLadderDirection[MAXPLAYERS+1];
new Float:g_fRecordTime;
new Float:g_fRecordTimePro;
new Float:g_fStartButtonPos[3];
new Float:g_fEndButtonPos[3];
new Float:g_pr_finishedmaps_tp_perc[MAX_PR_PLAYERS];
new Float:g_pr_finishedmaps_pro_perc[MAX_PR_PLAYERS];
new MoveType:g_LastMoveType[MAXPLAYERS+1];
new bool:g_bLateLoaded = false;
new bool:g_bRoundEnd;
new bool:g_bFirstStartButtonPush;
new bool:g_bFirstEndButtonPush;
new bool:g_bProReplay;
new bool:g_bTpReplay;
new bool:g_pr_RankingRecalc_InProgress;
new bool:g_bMapChooser;
new bool:g_bTop100Refresh;
new bool:g_bManualRecalc;
new bool:g_bNewTpBot;
new bool:g_bNewProBot;
new bool:g_bRoutePro;
new g_TmpRouteID;
new g_RouteTick[MAXPLAYERS+1];
new bool:g_bLadderJump[MAXPLAYERS+1];
new bool:g_bFirstButtonTouch[MAXPLAYERS+1];
new bool:g_bLJBlock[MAXPLAYERS + 1];
new bool:g_bCountJump[MAXPLAYERS + 1];
new bool:g_js_block_lj_jumpoff_pos[MAXPLAYERS + 1];
new bool:g_bClientOwnReason[MAXPLAYERS + 1];
new bool:g_js_block_lj_valid[MAXPLAYERS + 1];
new bool:g_js_bFuncMoveLinear[MAXPLAYERS+1];
new bool:g_pr_Calculating[MAXPLAYERS+1];
new bool:g_bChallenge_Checkpoints[MAXPLAYERS+1];
new bool:g_bTopMenuOpen[MAXPLAYERS+1];
new bool:g_bMapMenuOpen[MAXPLAYERS+1];
new bool:g_bNoClipUsed[MAXPLAYERS+1];
new bool:g_bMenuOpen[MAXPLAYERS+1];
new bool:g_bRespawnAtTimer[MAXPLAYERS+1];
new bool:g_bLastOnGround[MAXPLAYERS + 1];
new bool:g_bCanPause[MAXPLAYERS+1];
new bool:g_bPause[MAXPLAYERS+1];
new bool:g_bOverlay[MAXPLAYERS+1];
new bool:g_bLastButtonJump[MAXPLAYERS+1];
new bool:g_js_bPlayerJumped[MAXPLAYERS+1];
new bool:g_js_bPerfJumpOff[MAXPLAYERS+1];
new bool:g_js_bPerfJumpOff2[MAXPLAYERS+1];
new bool:g_bSpectate[MAXPLAYERS+1];
new bool:g_bTimeractivated[MAXPLAYERS+1];
new bool:g_bFirstTeamJoin[MAXPLAYERS+1];
new bool:g_bFirstSpawn[MAXPLAYERS+1];
new bool:g_bMissedTpBest[MAXPLAYERS+1];
new bool:g_bMissedProBest[MAXPLAYERS+1];
new bool:g_bRestorePosition[MAXPLAYERS+1];
new bool:g_bRestorePositionMsg[MAXPLAYERS+1];
new bool:g_bClimbersMenuOpen[MAXPLAYERS+1];
new bool:g_bNoClip[MAXPLAYERS+1];
new bool:g_bOnBhopPlattform[MAXPLAYERS+1];
new bool:g_bMapFinished[MAXPLAYERS+1];
new bool:g_bRespawnPosition[MAXPLAYERS+1];
new bool:g_bKickStatus[MAXPLAYERS+1];
new bool:g_bTouchedBooster[MAXPLAYERS+1];
new bool:g_bProfileRecalc[MAX_PR_PLAYERS];
new bool:g_bProfileSelected[MAXPLAYERS+1];
new bool:g_bClientGroundFlag[MAXPLAYERS+1];
new bool:g_bSelectProfile[MAXPLAYERS+1];
new bool:g_bClimbersMenuwasOpen[MAXPLAYERS+1];
new bool:g_js_bDropJump[MAXPLAYERS+1];
new bool:g_js_bInvalidGround[MAXPLAYERS+1];
new bool:g_bChallenge_Abort[MAXPLAYERS+1];
new bool:g_bLastInvalidGround[MAXPLAYERS+1];
new bool:g_bValidTeleportCall[MAXPLAYERS+1];
new bool:g_bMapRankToChat[MAXPLAYERS+1];
new bool:g_bChallenge[MAXPLAYERS+1];
new bool:g_js_bBhop[MAXPLAYERS+1];
new bool:g_bChallenge_Request[MAXPLAYERS+1];
new bool:g_js_Strafing_AW[MAXPLAYERS+1];
new bool:g_js_Strafing_SD[MAXPLAYERS+1];
new bool:g_pr_showmsg[MAXPLAYERS+1];
new bool:g_CMOpen[MAXPLAYERS+1];
new bool:g_bBeam[MAXPLAYERS+1];
new bool:g_bInvalidUndoGround[MAXPLAYERS+1];
new bool:g_bReplayRoute[MAXPLAYERS+1];
new bool:g_bRecalcRankInProgess[MAXPLAYERS+1];
new g_ColorChat[MAXPLAYERS+1];
new bool:g_bNewReplay[MAXPLAYERS+1];
new bool:g_bPositionRestored[MAXPLAYERS+1];
new bool:g_bInfoPanel[MAXPLAYERS+1];
new bool:g_bClimbersMenuSounds[MAXPLAYERS+1];
new g_EnableQuakeSounds[MAXPLAYERS+1];
new bool:g_bShowNames[MAXPLAYERS+1];
new bool:g_bShowTimerInfo[MAXPLAYERS+1];
new bool:g_bSpecInfo[MAXPLAYERS+1];
new bool:g_bStrafeSync[MAXPLAYERS+1];
new bool:g_bStartWithUsp[MAXPLAYERS+1];
new bool:g_bGoToClient[MAXPLAYERS+1];
new bool:g_bShowTime[MAXPLAYERS+1];
new bool:g_bHide[MAXPLAYERS+1];
new bool:g_bSayHook[MAXPLAYERS+1];
new g_ShowSpecs[MAXPLAYERS+1];
new bool:g_bFlagged[MAXPLAYERS+1];
new bool:g_bMeasurePosSet[MAXPLAYERS+1][2];
new bool:g_bCPTextMessage[MAXPLAYERS+1];
new bool:g_bAdvancedClimbersMenu[MAXPLAYERS+1];
new bool:g_bAutoBhopClient[MAXPLAYERS+1];
new bool:g_bJumpBeam[MAXPLAYERS+1];
new bool:g_bHideChat[MAXPLAYERS+1];
new bool:g_bViewModel[MAXPLAYERS+1];
new bool:g_bAdvInfoPanel[MAXPLAYERS+1];
new bool:g_borg_AdvInfoPanel[MAXPLAYERS+1];
new bool:g_borg_ViewModel[MAXPLAYERS+1];
new bool:g_borg_HideChat[MAXPLAYERS+1];
new bool:g_borg_JumpBeam[MAXPLAYERS+1];
new bool:g_borg_StartWithUsp[MAXPLAYERS+1];
new g_org_ColorChat[MAXPLAYERS+1];
new bool:g_borg_InfoPanel[MAXPLAYERS+1];
new bool:g_borg_ReplayRoute[MAXPLAYERS+1];
new bool:g_borg_ClimbersMenuSounds[MAXPLAYERS+1];
new g_org_EnableQuakeSounds[MAXPLAYERS+1];
new bool:g_borg_ShowNames[MAXPLAYERS+1];
new bool:g_borg_StrafeSync[MAXPLAYERS+1];
new bool:g_borg_GoToClient[MAXPLAYERS+1];
new bool:g_borg_ShowTime[MAXPLAYERS+1];
new bool:g_borg_Hide[MAXPLAYERS+1];
new g_org_ShowSpecs[MAXPLAYERS+1];
new bool:g_borg_CPTextMessage[MAXPLAYERS+1];
new bool:g_borg_AdvancedClimbersMenu[MAXPLAYERS+1];
new bool:g_borg_AutoBhopClient[MAXPLAYERS+1];
new bool:g_bErrorSounds[MAXPLAYERS+1];
new bool:g_borg_ErrorSounds[MAXPLAYERS + 1];
new bool:g_bOnGround[MAXPLAYERS+1];
new bool:g_bOnGroundBindFix[MAXPLAYERS+1];
new bool:g_bWasDucking[MAXPLAYERS + 1];
new bool:g_bJumping[MAXPLAYERS + 1];
new g_org_ClientLang[MAXPLAYERS+1];
new g_ClientLang[MAXPLAYERS+1];
new bool:g_bPrestrafeTooHigh[MAXPLAYERS+1];
new g_Beam[3];
new g_BhopMultipleList[MAX_BHOPBLOCKS];
new g_BhopMultipleTeleList[MAX_BHOPBLOCKS];
new g_BhopMultipleCount;
new g_BhopDoorList[MAX_BHOPBLOCKS];
new g_BhopDoorTeleList[MAX_BHOPBLOCKS];
new g_BhopDoorCount;
new g_BhopButtonList[MAX_BHOPBLOCKS];
new g_BhopButtonTeleList[MAX_BHOPBLOCKS];
new g_BhopButtonCount;
new g_Offs_vecOrigin = -1;
new g_Offs_vecMins = -1;
new g_Offs_vecMaxs = -1;
new g_DoorOffs_vecPosition1 = -1;
new g_DoorOffs_vecPosition2 = -1;
new g_DoorOffs_flSpeed = -1;
new g_DoorOffs_spawnflags = -1;
new g_DoorOffs_NoiseMoving = -1;
new g_DoorOffs_sLockedSound = -1;
new g_DoorOffs_bLocked = -1;
new g_ButtonOffs_vecPosition1 = -1;
new g_ButtonOffs_vecPosition2 = -1;
new g_ButtonOffs_flSpeed = -1;
new g_ButtonOffs_spawnflags = -1;
new g_TSpawns=-1;
new g_CTSpawns=-1;
new g_ownerOffset;
new g_ragdolls = -1;
new g_Server_Tickrate;
new g_MapTimesCountPro;
new g_MapTimesCountTp;
new g_ProBot=-1;
new g_TpBot=-1;
new g_InfoBot=-1;
new g_ReplayBotTpColor[3];
new g_ReplayBotProColor[3];
new g_pr_Recalc_ClientID = 0;
new g_pr_Recalc_AdminID=-1;
new g_pr_AllPlayers;
new g_pr_RankedPlayers;
new g_pr_MapCount;
new g_pr_MapCountTp;
new g_pr_rank_Percentage[9];
new g_pr_PointUnit;
new g_pr_TableRowCount;
new g_pr_points[MAX_PR_PLAYERS];
new g_pr_maprecords_row_counter[MAX_PR_PLAYERS];
new g_pr_maprecords_row_count[MAX_PR_PLAYERS];
new g_pr_oldpoints[MAX_PR_PLAYERS];
new g_pr_multiplier[MAX_PR_PLAYERS];
new g_pr_finishedmaps_tp[MAX_PR_PLAYERS];
new g_pr_finishedmaps_pro[MAX_PR_PLAYERS];
new g_js_Personal_LjBlock_Record[MAX_PR_PLAYERS]=-1;
new g_js_BhopRank[MAX_PR_PLAYERS];
new g_js_MultiBhopRank[MAX_PR_PLAYERS];
new g_js_LjRank[MAX_PR_PLAYERS];
new g_js_LadderJumpRank[MAX_PR_PLAYERS];
new g_js_LjBlockRank[MAX_PR_PLAYERS];
new g_js_DropBhopRank[MAX_PR_PLAYERS];
new g_js_WjRank[MAX_PR_PLAYERS];
new g_js_CJRank[MAX_PR_PLAYERS];
new g_BlueGlowSprite;
new g_js_LadderDirectionCounter[MAXPLAYERS+1];
new g_js_TotalGroundFrames[MAXPLAYERS+1];
new g_js_Sync_Final[MAXPLAYERS+1];
new g_js_GroundFrames[MAXPLAYERS+1];
new g_js_LadderFrames[MAXPLAYERS+1];
new g_js_StrafeCount[MAXPLAYERS+1];
new g_js_Strafes_Final[MAXPLAYERS+1];
new g_js_GODLIKE_Count[MAXPLAYERS+1];
new g_js_MultiBhop_Count[MAXPLAYERS+1];
new g_js_Last_Ground_Frames[MAXPLAYERS+1];
new g_js_DuckCounter[MAXPLAYERS+1];
new g_PlayerRank[MAXPLAYERS+1];
new g_Skillgroup[MAXPLAYERS+1];
new g_LastGroundEnt[MAXPLAYERS+1];
new g_BotMimicRecordTickCount[MAXPLAYERS+1] = {0,...};
new g_BotActiveWeapon[MAXPLAYERS+1] = {-1,...};
new g_CurrentAdditionalTeleportIndex[MAXPLAYERS+1];
new g_RecordedTicks[MAXPLAYERS+1];
new g_RecordPreviousWeapon[MAXPLAYERS+1];
new g_OriginSnapshotInterval[MAXPLAYERS+1];
new g_BotMimicTick[MAXPLAYERS+1] = {0,...};
new g_BlockDist[MAXPLAYERS + 1];
new g_AttackCounter[MAXPLAYERS + 1];
new g_aiJumps[MAXPLAYERS+1] = {0, ...};
new g_aaiLastJumps[MAXPLAYERS+1][30];
new g_fps_max[MAXPLAYERS+1];
new g_NumberJumpsAbove[MAXPLAYERS+1];
new g_MenuLevel[MAXPLAYERS+1];
new g_Challenge_Bet[MAXPLAYERS+1];
new g_MapRankTp[MAXPLAYERS+1];
new g_MapRankPro[MAXPLAYERS+1];
new g_OldMapRankPro[MAXPLAYERS+1];
new g_Time_Type[MAXPLAYERS+1];
new g_Sound_Type[MAXPLAYERS+1];
new g_TpRecordCount[MAXPLAYERS+1];
new g_ProRecordCount[MAXPLAYERS+1];
new g_FinishingType[MAXPLAYERS+1];
new g_OldMapRankTp[MAXPLAYERS+1];
new g_Challenge_WinRatio[MAX_PR_PLAYERS];
new g_CountdownTime[MAXPLAYERS+1];
new g_Challenge_PointsRatio[MAX_PR_PLAYERS];
new g_CurrentCp[MAXPLAYERS+1];
new g_CounterCp[MAXPLAYERS+1];
new g_OverallCp[MAXPLAYERS+1];
new g_OverallTp[MAXPLAYERS+1];
new g_SpecTarget[MAXPLAYERS+1];
new g_SpecTarget2[MAXPLAYERS+1];//test
new g_PrestrafeFrameCounter[MAXPLAYERS+1];
new g_LastButton[MAXPLAYERS + 1];
new g_CurrentButton[MAXPLAYERS+1];
new g_MVPStars[MAXPLAYERS+1];
new g_Tp_Final[MAXPLAYERS+1];
new g_JumpCheck1[MAXPLAYERS+1];
new g_JumpCheck2[MAXPLAYERS+1];
new g_AdminMenuLastPage[MAXPLAYERS+1];
new g_OptionsMenuLastPage[MAXPLAYERS+1];
new String:g_js_szLastJumpDistance[MAXPLAYERS+1][256];
new String:g_pr_chat_coloredrank[MAXPLAYERS+1][32];
new String:g_pr_rankname[MAXPLAYERS+1][32];
new String:g_pr_szrank[MAXPLAYERS+1][512];
new String:g_pr_szName[MAX_PR_PLAYERS][64];
new String:g_pr_szSteamID[MAX_PR_PLAYERS][32];
new String:g_szMapPrefix[2][32];
new String:g_szMapmakers[100][32];
new String:g_szReplayName[128];
new String:g_szReplayTime[128];
new String:g_szReplayNameTp[128];
new String:g_szReplayTimeTp[128];
new String:g_szChallenge_OpponentID[MAXPLAYERS+1][32];
new String:g_szTimeDifference[MAXPLAYERS+1][32];
new String:g_szFinalTime[MAXPLAYERS+1][32];
new String:g_szMapName[128];
new String:g_szMapTopName[MAXPLAYERS+1][128];
new String:g_szTimerTitle[MAXPLAYERS+1][255];
new String:g_szRecordPlayerPro[MAX_NAME_LENGTH];
new String:g_szRecordPlayer[MAX_NAME_LENGTH];
new String:g_szProfileName[MAXPLAYERS+1][MAX_NAME_LENGTH];
new String:g_szPlayerPanelText[MAXPLAYERS+1][512];
new String:g_szProfileSteamId[MAXPLAYERS+1][32];
new String:g_szCountry[MAXPLAYERS+1][100];
new String:g_szCountryCode[MAXPLAYERS+1][16];
new String:g_szSteamID[MAXPLAYERS+1][32];
new String:g_szSkillGroups[9][32];
new String:g_szServerName[64];
new String:g_szMapPath[256];
new String:g_szServerIp[32];
new String:g_szServerCountry[100];
new String:g_szServerCountryCode[32];
new const String:MAPPERS_PATH[] = "configs/kztimer/mapmakers.txt";
new const String:KZ_REPLAY_PATH[] = "data/kz_replays/";
new const String:ANTICHEAT_LOG_PATH[] = "logs/kztimer_anticheat.log";
new const String:BLOCKED_LIST_PATH[] = "configs/kztimer/hidden_chat_commands.txt";
new const String:EXCEPTION_LIST_PATH[] = "configs/kztimer/exception_list.txt";
new String:CP_FULL_SOUND_PATH[128];
new String:CP_RELATIVE_SOUND_PATH[128];
new String:PRO_FULL_SOUND_PATH[128];
new String:PRO_RELATIVE_SOUND_PATH[128];
new String:UNSTOPPABLE_SOUND_PATH[128];
new String:UNSTOPPABLE_RELATIVE_SOUND_PATH[128];
new String:GODLIKE_FULL_SOUND_PATH[128];
new String:GODLIKE_RELATIVE_SOUND_PATH[128];
new String:GODLIKE_RAMPAGE_FULL_SOUND_PATH[128];
new String:GODLIKE_RAMPAGE_RELATIVE_SOUND_PATH[128];
new String:GODLIKE_DOMINATING_FULL_SOUND_PATH[128];
new String:GODLIKE_DOMINATING_RELATIVE_SOUND_PATH[128];
new String:PERFECT_FULL_SOUND_PATH[128];
new String:PERFECT_RELATIVE_SOUND_PATH[128];
new String:IMPRESSIVE_FULL_SOUND_PATH[128];
new String:IMPRESSIVE_RELATIVE_SOUND_PATH[128];
new String:GOLDEN_FULL_SOUND_PATH[128];
new String:GOLDEN_RELATIVE_SOUND_PATH[128];
new String:g_szLanguages[][128] = {"English", "German", "Swedish", "French", "Russian", "SChinese", "Brazilian", "Finnish"};
new String:RadioCMDS[][] = {"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog",
	"getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin",
	"getout", "negative","enemydown","cheer","thanks","nice","compliment"};
new String:g_BlockedChatText[256][256];
new String:g_szReplay_PlayerName[MAXPLAYERS+1][64];
new bool:g_bJumpBugged[MAXPLAYERS + 1];
new bool:g_bSSPSet[MAXPLAYERS + 1];

//global decls
new Handle:g_hDbGlobal = INVALID_HANDLE;
new g_global_EntityCount = 0;
new g_global_MapFileSize;
new g_global_VersionBlocked;
new g_global_maptier;
new g_global_maprank_tp[MAXPLAYERS+1];
new g_global_maprank_pro[MAXPLAYERS+1];
new bool:g_global_Disabled;
new bool:g_global_Access;
new bool:g_global_ValidedMap;
new bool:g_global_ValidFileSize;
new bool:g_global_IntegratedButtons;
new bool:g_global_EntityCheck;
new bool:g_global_EntCounter;
new bool:g_global_SelfBuiltButtons;
new bool:g_global_AutoTimerOnStart[MAXPLAYERS+1];
new bool:g_global_AutoBhopDetected[MAXPLAYERS+1];
new bool:g_global_WrongMapVersion;
new bool:g_global_Enforcer[MAXPLAYERS+1];
new bool:g_global_DoubleDuck[MAXPLAYERS+1];
new String:g_global_szGlobalMapName[128];
new String:g_global_szLatestGlobalVersion[32];
new String:g_global_szMapDifficulty[255];
new String:g_global_szApprover[255];
new String:g_GlobalRecordPro_Name[MAX_NAME_LENGTH];
new String:g_GlobalRecordTp_Name[MAX_NAME_LENGTH];
new Float:g_fGlobalRecordTp_Time=9999999.0;
new Float:g_fGlobalRecordPro_Time=9999999.0;

//realbhop
new bool:AfterJumpFrame[MAXPLAYERS + 1];
new FloorFrames[MAXPLAYERS + 1];
new bool:PlayerOnGround[MAXPLAYERS + 1];
new Float:AirSpeed[MAXPLAYERS + 1][3];
new bool:PlayerInTriggerPush[MAXPLAYERS + 1];

// Gold jumpstats
new Float:g_hdist_golden_countjump;
new Float:g_hdist_golden_lj;
new Float:g_hdist_golden_weird;
new Float:g_hdist_golden_dropbhop;
new Float:g_hdist_golden_bhop;
new Float:g_hdist_golden_multibhop;
new Float:g_hdist_golden_ladder;

#include "kztimerGlobal/admin.sp"
#include "kztimerGlobal/commands.sp"
#include "kztimerGlobal/hooks.sp"
#include "kztimerGlobal/buttonpress.sp"
#include "kztimerGlobal/global.sp"
#include "kztimerGlobal/sql.sp"
#include "kztimerGlobal/misc.sp"
#include "kztimerGlobal/timer.sp"
#include "kztimerGlobal/replay.sp"
#include "kztimerGlobal/jumpstats.sp"
//#include "kztimerGlobal/addons/sound.sp"

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RegPluginLibrary("KZTimer");
	MarkNativeAsOptional("HasEndOfMapVoteFinished");
	MarkNativeAsOptional("EndOfMapVoteEnabled");
	hStartPress = CreateGlobalForward("CL_OnStartTimerPress", ET_Ignore, Param_Cell);
	hEndPress = CreateGlobalForward("CL_OnEndTimerPress", ET_Ignore, Param_Cell);
	CreateNative("KZTimer_GetTimerStatus", Native_GetTimerStatus);
	CreateNative("KZTimer_StopUpdatingOfClimbersMenu", Native_StopUpdatingOfClimbersMenu);
	CreateNative("KZTimer_StopTimer", Native_StopTimer);
	CreateNative("KZTimer_EmulateStartButtonPress", Native_EmulateStartButtonPress);
	CreateNative("KZTimer_EmulateStopButtonPress", Native_EmulateStopButtonPress);
	CreateNative("KZTimer_GetCurrentTime", Native_GetCurrentTime);
	CreateNative("KZTimer_GetAvgTimeTp", Native_GetAvgTimeTp);
	CreateNative("KZTimer_GetAvgTimePro", Native_GetAvgTimePro);
	CreateNative("KZTimer_GetSkillGroup", Native_GetSkillGroup);
	CreateNative("KZTimer_GetVersion", Native_GetVersion);
	CreateNative("KZTimer_GetVersion_Desc", Native_GetVersion_Desc);
	g_bLateLoaded = late;
	g_hFWD_TimerStart = CreateGlobalForward("KZTimer_TimerStarted", ET_Event, Param_Cell);
	g_hFWD_TimerStopped = CreateGlobalForward("KZTimer_TimerStopped", ET_Event, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	g_hFWD_TimerStoppedValid = CreateGlobalForward("KZTimer_TimerStoppedValid", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Float);
	g_hFWD_OnJumpstatStarted = CreateGlobalForward("KZTimer_OnJumpstatStarted", ET_Ignore, Param_Cell);
	g_hFWD_OnJumpstatCompleted= CreateGlobalForward("KZTimer_OnJumpstatCompleted", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	g_hFWD_OnJumpstatInvalid = CreateGlobalForward("KZTimer_OnJumpstatInvalid", ET_Ignore, Param_Cell);
	
	return APLRes_Success;
}

public OnPluginStart()
{

	//GameCheck
	new String:gameDir[64];
	GetGameFolderName(gameDir, sizeof(gameDir));
	if(StrContains(gameDir, "csgo", false) == -1)
		SetFailState("Sorry, this game isn't supported by KZTimer. (%s)", gameDir);

	//TickrateCheck
	new Float:fltickrate = 1.0 / GetTickInterval( );
	if (fltickrate > 65)
		if (fltickrate < 103)
			g_Server_Tickrate = 102;
		else
			g_Server_Tickrate = 128;
	else
		g_Server_Tickrate= 64;


	RegServerConVars();
	RegConsoleCmds();
	db_setupDatabase();
	AutoExecConfig(true, "KZTimerGlobal");
	LoadTranslations("kztimer.phrases");
	SetupHooksAndCommandListener();
	SetServerConvars();
	SetSoundPath();

	//admin menu
	new Handle:topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
		OnAdminMenuReady(topmenu);
		
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATER);
	}

	//mapcycle array
	new arraySize = ByteCountToCells(PLATFORM_MAX_PATH);
	g_MapList = CreateArray(arraySize);

	//replay bots
	CreateNavFiles();
	CheatFlag("bot_zombie", false, true);
	CheatFlag("bot_mimic", false, true);
	g_hLoadedRecordsAdditionalTeleport = CreateTrie();

	//offsets
	g_Offs_vecOrigin = FindSendPropInfo("CBaseEntity","m_vecOrigin");
	g_Offs_vecMins = FindSendPropInfo("CBaseEntity","m_vecMins");
	g_Offs_vecMaxs = FindSendPropInfo("CBaseEntity","m_vecMaxs");
	g_ownerOffset = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	g_ragdolls = FindSendPropInfo("CCSPlayer","m_hRagdoll");

	// MultiPlayer Bunny Hops: Source
	// https://forums.alliedmods.net/showthread.php?p=808724
	new Handle:hGameConf = LoadGameConfigFile("sdkhooks.games")
	StartPrepSDKCall(SDKCall_Entity)
	PrepSDKCall_SetFromConf(hGameConf,SDKConf_Virtual,"Touch")
	PrepSDKCall_AddParameter(SDKType_CBaseEntity,SDKPass_Pointer)
	g_hSDK_Touch = EndPrepSDKCall()
	CloseHandle(hGameConf)
	if(g_hSDK_Touch == INVALID_HANDLE)
	{
		SetFailState("Unable to prepare virtual function CBaseEntity::Touch")
		return
	}

	if(g_bLateLoaded)
		CreateTimer(3.0, LoadPlayerSettings, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);

	//CleanupDB();
}

public OnPluginPauseChange(bool:bPause)
{
	if (bPause)
	{
		AlterBhopBlocks(true);
		g_BhopDoorCount = 0;
		g_BhopButtonCount = 0;
		for(new i = 0; i < g_BhopMultipleCount; i++)
		{
			new ent = g_BhopMultipleList[i];
			if(IsValidEntity(ent))
				SDKUnhook(ent,SDKHook_StartTouch,Entity_Touch2);
		}
	}
	else
	{
		g_BhopDoorCount = 0;
		g_BhopButtonCount = 0;
		g_BhopMultipleCount = 0;
		FindBhopBlocks();
		FindMultipleBlocks();
	}
}

public OnLibraryAdded(const String:name[])
{
	new Handle:tmp = FindPluginByFile("mapchooser_extended.smx");
	if ((StrEqual("mapchooser", name)) ||(tmp != INVALID_HANDLE && GetPluginStatus(tmp) == Plugin_Running))
		g_bMapChooser = true;
	if (tmp != INVALID_HANDLE)
		CloseHandle(tmp);
		
	if (StrEqual(name, "KZTimer-API"))
	{
		gB_KZTimerAPI = true;
	}
	
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATER);
	}

	//botmimic 2
	if(StrEqual(name, "dhooks") && g_hTeleport == INVALID_HANDLE)
	{
		// Optionally setup a hook on CBaseEntity::Teleport to keep track of sudden place changes
		new Handle:hGameData = LoadGameConfigFile("sdktools.games");
		if(hGameData == INVALID_HANDLE)
			return;
		new iOffset = GameConfGetOffset(hGameData, "Teleport");
		CloseHandle(hGameData);
		if(iOffset == -1)
			return;

		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		if(g_hTeleport == INVALID_HANDLE)
			return;
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_ObjectPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		if(GetEngineVersion() == Engine_CSGO)
			DHookAddParam(g_hTeleport, HookParamType_Bool);

		for(new i=1;i<=MaxClients;i++)
		{
			if(IsValidClient(i))
				OnClientPutInServer(i);
		}
	}
}

public OnPluginEnd()
{
	//remove climb buttons
	DeleteButtons(67);

	//remove clan tags
	for (new x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x))
		{
			SetEntPropEnt(x, Prop_Send, "m_bSpotted", 1);
			SetEntProp(x, Prop_Send, "m_iHideHUD", 0);
			SetEntProp(x, Prop_Send, "m_iAccount", 1);
			CS_SetClientClanTag(x, "");
			OnClientDisconnect(x);
		}
 	}

	//unhook
	UnhookEntityOutput("trigger_teleport", "OnStartTouch", Teleport_OnStartTouch);
	UnhookEntityOutput("trigger_multiple", "OnStartTouch", Teleport_OnStartTouch);
	UnhookEntityOutput("trigger_teleport", "OnEndTouch", Teleport_OnEndTouch);
	UnhookEntityOutput("trigger_multiple", "OnEndTouch", Teleport_OnEndTouch);
	UnhookEntityOutput("trigger_gravity", "OnStartTouch", Trigger_GravityTouch);
	UnhookEntityOutput("trigger_gravity", "OnEndTouch", Trigger_GravityTouch);
	UnhookEntityOutput("func_button", "OnPressed", ButtonPress);

	//set server convars back to default
	ServerCommand("sm_cvar sv_enablebunnyhopping 0;sv_friction 5.2;sv_accelerate 5.5;sv_airaccelerate 10;sv_maxvelocity 2000;sv_staminajumpcost .08;sv_staminalandcost .050");
	ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0;mp_respawnwavetime_ct 10.0;mp_respawnwavetime_t 10.0;bot_zombie 0;mp_ignore_round_win_conditions 0");
	ServerCommand("sv_infinite_ammo 0;mp_endmatch_votenextmap 1;mp_do_warmup_period 1;mp_warmuptime 60;mp_match_can_clinch 1;mp_match_end_changelevel 0");
	ServerCommand("mp_match_restart_delay 15;mp_endmatch_votenextleveltime 20;mp_endmatch_votenextmap 1;mp_halftime 0;mp_do_warmup_period 1;mp_maxrounds 0;bot_quota 0");
	ServerCommand("mp_startmoney 800; mp_playercashawards 1; mp_teamcashawards 1");
}

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "adminmenu"))
		g_hAdminMenu = INVALID_HANDLE;
	if(StrEqual(name, "dhooks"))
		SetFailState("<KZTIMER> Dhooks extension is not loaded.");
		
	if (StrEqual(name, "KZTimer-API"))
	{
		gB_KZTimerAPI = false;
	}
	
	if (StrEqual(name, "updater"))
	{
		Updater_RemovePlugin();
	}
}

public OnMapStart()
{
	new timeleft;
	GetMapTimeLeft(timeleft);
	ServerCommand("sv_pure 0;bot_quota 0;mp_warmup_end");
	SetServerConvars();
	CheckSpawnPoints();
	HookTriggerPushes();
	AddMapmakers();
	AddHiddenChatCommands();
	SetupExceptions(true);
	InitPrecache();
	SetCashState();

	//set defaults
	for (new i = 1; i <= MaxClients; i++)
		g_Skillgroup[i] = 0;
	g_hReplayRouteArray = CreateArray(3);
	g_global_MapFileSize = -1;
	g_bFirstStartButtonPush=true;
	g_bFirstEndButtonPush=true;
	g_fMapStartTime = GetEngineTime();
	g_global_SelfBuiltButtons=false;
	g_global_IntegratedButtons=true;
	g_global_Disabled=false;
	g_fRecordTime=9999999.0;
	g_fRecordTimePro=9999999.0;
	g_fGlobalRecordPro_Time = 9999999.0;
	g_fGlobalRecordTp_Time = 9999999.0;
	g_fStartButtonPos = Float:{-999999.9,-999999.9,-999999.9};
	g_fEndButtonPos = Float:{-999999.9,-999999.9,-999999.9};
	g_MapTimesCountPro = 0;
	g_MapTimesCountTp = 0;
	g_ProBot = -1;
	g_TpBot = -1;
	g_InfoBot = -1
	g_bAutoBhop=false;
	g_bRoundEnd=false;
	g_global_EntityCheck = false;
	g_global_EntCounter = true;
	g_hDbGlobal = INVALID_HANDLE;
	CheatFlag("bot_zombie", false, true);

	//global
	Format(g_global_szMapDifficulty,255,"undefined");
	Format(g_global_szGlobalMapName,128,"");
	Format(g_global_szApprover,255,"Unknown");

	//get mapname
	new bool: fileFound;
	GetCurrentMap(g_szMapName, 128);
	Format(g_szMapPath, sizeof(g_szMapPath), "maps/%s.bsp", g_szMapName);
	fileFound = FileExists(g_szMapPath);

	//workshop fix
	new String:mapPieces[6][128];
	new lastPiece = ExplodeString(g_szMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(g_szMapName, sizeof(g_szMapName), "%s", mapPieces[lastPiece-1]);

	//get map tag
	ExplodeString(g_szMapName, "_", g_szMapPrefix, 2, 32);
	g_global_ValidFileSize=false;
	StrToLower(g_szMapName);
	StrToLower(g_szMapPrefix[0]);


	//sql
	ConnectToGlobalDB();
	db_GetMapRecord_CP();
	db_GetMapRecord_Pro();
	db_CalculatePlayerCount();
	db_viewMapProRankCount();
	db_viewMapTpRankCount();
	db_VersionCheck();
	db_MapTierCheck();
	db_ClearLatestRecords();
	db_GetDynamicTimelimit();
	db_CalcAvgRunTime();

	//timers
	CreateTimer(0.1, KZTimer1, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, KZTimer2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(2.0, OnMapStartTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(60.0, AttackTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(600.0, PlayerRanksTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1800.0, VersionCheckTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	g_hSpecAdvertTimer = CreateTimer(g_fSpecsAdvert, SpecAdvertTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	if (fileFound)
	{
		g_global_MapFileSize =  FileSize(g_szMapPath);
		if (g_hDbGlobal != INVALID_HANDLE)
		{
			if(StrEqual(g_szMapPrefix[0],"kz") || StrEqual(g_szMapPrefix[0],"xc") || StrEqual(g_szMapPrefix[0],"bkz") || StrEqual(g_szMapPrefix[0],"kzpro"))
				dbCheckFileSize();
		}
	}

	//AutoBhop?
	if(StrEqual(g_szMapPrefix[0],"surf") || StrEqual(g_szMapPrefix[0],"bhop") || StrEqual(g_szMapPrefix[0],"mg"))
		if (g_bAutoBhopConVar)
			g_bAutoBhop=true;

	//server infos
	CreateTimer(5.0, GetServerInfo);

	//Bhop block stuff
	g_BhopDoorCount = 0;
	g_BhopButtonCount = 0;
	g_BhopMultipleCount = 0;
	FindBhopBlocks();
	FindMultipleBlocks();

	if (g_bLateLoaded)
	{
		OnConfigsExecuted();
		OnAutoConfigsBuffered();
	}
	dbGetGlobalBanList();

	decl String:sManifestFullPath[PLATFORM_MAX_PATH];
	FormatEx(sManifestFullPath, sizeof(sManifestFullPath), "%s%s%s", MANIFEST_FOLDER, g_szMapName, MANIFEST_EXTENSION);
	if (FileExists(sManifestFullPath, true, NULL_STRING))
		ProcessParticleManifest(sManifestFullPath);
}

public OnMapEnd()
{
	AlterBhopBlocks(true);
	SetupExceptions(false);
	ResetHandle(g_hGlobalBanListArray);
	ResetHandle(g_hReplayRouteArray);
	g_BhopDoorCount = 0;
	g_ProBot = -1;
	g_TpBot = -1;
	g_BhopButtonCount = 0;
	g_BhopMultipleCount = 0;
	for(new i = 0; i < g_BhopMultipleCount; i++)
	{
		new ent = g_BhopMultipleList[i];
		if(IsValidEntity(ent))
		{
			SDKUnhook(ent,SDKHook_StartTouch,Entity_Touch2);
		}
	}
	ServerCommand("bot_quota 0");
	db_Cleanup();
}

public OnConfigsExecuted()
{
	new String:map[128];
	new String:map2[128];
	new mapListSerial = -1;
	new MapCountPro;
	g_pr_MapCount=0;
	g_pr_MapCountTp = 0;
	if (ReadMapList(g_MapList,
			mapListSerial,
			"mapcyclefile",
			MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_NO_DEFAULT)
		== INVALID_HANDLE)
	{
		if (mapListSerial == -1)
		{
			SetFailState("<KZTIMER> Mapcycle.txt is empty or does not exists.");
		}
	}
	for (new i = 0; i < GetArraySize(g_MapList); i++)
	{
		GetArrayString(g_MapList, i, map, sizeof(map));
		if (!StrEqual(map, "", false))
		{
			//fix workshop map name
			new String:mapPieces[6][128];
			new String:prefix[2][32];
			new lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
			Format(map2, sizeof(map2), "%s", mapPieces[lastPiece-1]);
			SetArrayString(g_MapList, i, map2);
			g_pr_MapCount++;

			ExplodeString(map2, "_", prefix, 2, 32);
			if(StrEqual(prefix[0],"kzpro"))
				MapCountPro++;
		}
	}
	g_pr_MapCountTp = g_pr_MapCount - MapCountPro;

	//skillgroups
	SetSkillGroups();

	//get mapname
	GetCurrentMap(g_szMapName, 128);
	Format(g_szMapPath, sizeof(g_szMapPath), "maps/%s.bsp", g_szMapName);

	//workshop fix
	new String:mapPieces[6][128];
	new lastPiece = ExplodeString(g_szMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(g_szMapName, sizeof(g_szMapName), "%s", mapPieces[lastPiece-1]);

	//get map tag
	ExplodeString(g_szMapName, "_", g_szMapPrefix, 2, 32);
	StrToLower(g_szMapName);
	StrToLower(g_szMapPrefix[0]);

	//AutoBhop?
	if(StrEqual(g_szMapPrefix[0],"surf") || StrEqual(g_szMapPrefix[0],"bhop") || StrEqual(g_szMapPrefix[0],"mg"))
		if (g_bAutoBhopConVar)
			g_bAutoBhop=true;

	ServerCommand("sv_pure 0");
}


public OnAutoConfigsBuffered()
{
	//just to be sure that it's not empty
	decl String:szMap[128];
	decl String:szPrefix[2][32];
	GetCurrentMap(szMap, 128);
	decl String:mapPieces[6][128];
	new lastPiece = ExplodeString(szMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(szMap, sizeof(szMap), "%s", mapPieces[lastPiece-1]);
 	ExplodeString(szMap, "_", szPrefix, 2, 32);
	StrToLower(szPrefix[0]);

	//map tag kzpro?
	if (StrEqual("kzpro", szPrefix[0]))
		Format(szPrefix[0], 32, "kz");

	//map config
	decl String:szPath[256];
	Format(szPath, sizeof(szPath), "sourcemod/kztimer/map_types/%s_.cfg",szPrefix[0]);
	decl String:szPath2[256];
	Format(szPath2, sizeof(szPath2), "cfg/%s",szPath);
	if (FileExists(szPath2))
		ServerCommand("exec %s", szPath);
	else
		SetFailState("<KZTIMER> %s not found.", szPath2);

	SetServerTags();
}

public OnClientPutInServer(client)
{
	if (!IsValidClient(client))
		return;

	g_hRouteArray[client] = CreateArray(3);
	g_RouteTick[client] = 0;
	if (LibraryExists("dhooks") && g_hTeleport != INVALID_HANDLE)
		DHookEntity(g_hTeleport, false, client);
	//g_bGlobal_Disconnected[client] = false; //Not sure if this is needed
	g_pr_Calculating[client]=true;
	g_bCantJoin[client] = true;
	g_MVPStars[client] = 0;
	g_bShowTimerInfo[client] = true;

	//SDKHooks/Dhooks
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKHook(client, SDKHook_StartTouch, Hook_OnTouch);
	SDKHook(client, SDKHook_PostThink, Hook_PostThinkPost);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponSwitchPost);

	if (IsFakeClient(client))
	{
		g_hRecordingAdditionalTeleport[client] = CreateArray(_:AdditionalTeleport);
		CS_SetMVPCount(client,1);
		return;
	}

	//Team Delay Timer
	CreateTimer(1.5, TeamDelay, client, TIMER_FLAG_NO_MAPCHANGE);

	//defaults
	SetClientDefaults(client);

	//client country
	GetCountry(client);

	//get client data
	
	if (!GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], sizeof(g_szSteamID[]), true))
	{
		KickClient(client, "Failed to authorize with Steam, please try again later");
		return;
	}

	decl String:szSteamID[32];
	new String:idpieces[3][32];
	new lastPiece = ExplodeString(g_szSteamID[client], ":", idpieces, sizeof(idpieces), sizeof(idpieces[]));
	Format(szSteamID, sizeof(szSteamID), "%s", idpieces[lastPiece-1]);

	if (g_hGlobalBanListArray != INVALID_HANDLE)
	{
		for (new i = 0; i < GetArraySize(g_hGlobalBanListArray); i++)
		{
			decl String:szAuthID[32];
			GetArrayString(g_hGlobalBanListArray,i,szAuthID,32);
			TrimString(szAuthID);
			if (StrEqual(szAuthID,szSteamID))
			{
				KickClient(client, "You are globally banned! For more information visit kzstats.com");
				return;
			}
		}
	}

	db_viewPlayerOptions(client, g_szSteamID[client]);
 	db_viewPersonalRecords(client,g_szSteamID[client],g_szMapName);
	db_viewPersonalBhopRecord(client, g_szSteamID[client]);
	db_viewPersonalMultiBhopRecord(client, g_szSteamID[client]);
	db_viewPersonalWeirdRecord(client, g_szSteamID[client]);
	db_viewPersonalDropBhopRecord(client, g_szSteamID[client]);
	db_viewPersonalLJBlockRecord(client, g_szSteamID[client]);
	db_viewPersonalLadderJumpRecord(client, g_szSteamID[client]);
	db_viewPersonalCJRecord(client, g_szSteamID[client]);
	db_viewPersonalLJRecord(client, g_szSteamID[client]);
	CreateTimer(2.0, GetGlobalMapRank_Timer, client,TIMER_FLAG_NO_MAPCHANGE);

	// ' char fix
	FixPlayerName(client);

	//position restoring
	if(g_bRestore)
		db_selectLastRun(client);

	//console info
	PrintConsoleInfo(client);

	if (g_bLateLoaded && IsPlayerAlive(client))
		PlayerSpawn(client);
}

public OnClientDisconnect(client)
{
	g_bDisconnected[client] = true;

	ResetHandle(g_hRouteArray[client]);

	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKUnhook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKUnhook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKUnhook(client, SDKHook_StartTouch, Hook_OnTouch);
	SDKUnhook(client, SDKHook_PostThink, Hook_PostThinkPost);
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKUnhook(client, SDKHook_WeaponEquipPost, OnWeaponSwitchPost);

	if (client == g_ProBot || client == g_TpBot)
	{
		StopPlayerMimic(client);
		if (client == g_ProBot)
			g_ProBot = -1;
		else
			g_TpBot = -1;
		return;
	}

	//Database
	if (IsValidClient(client))
	{
		db_insertLastPosition(client,g_szMapName);
		db_updatePlayerOptions(client);
		g_bSSPSet[client] = false;
	}
	StopRecording(client);

	// Macrodox
	ResetPos(client);
	g_aiJumps[client] = 0;
	g_fafAvgJumps[client] = 5.0;
	g_fafAvgSpeed[client] = 250.0;
	g_fafAvgPerfJumps[client] = 0.3333;
	g_bFlagged[client] = false;
	g_favVEL[client][2] = 0.0;
}

public OnClientAuthorized(client)
{
	if (g_bConnectMsg && !IsFakeClient(client))
	{
		decl String:s_Country[32];
		decl String:s_clientName[32];
		decl String:s_address[32];
		GetClientIP(client, s_address, 32);
		GetClientName(client, s_clientName, 32);
		Format(s_Country, 100, "Unknown");
		GeoipCountry(s_address, s_Country, 100);
		if(!strcmp(s_Country, NULL_STRING))
			Format( s_Country, 100, "Unknown", s_Country );
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
				Format( s_Country, 100, "The %s", s_Country );
			}

		if (StrEqual(s_Country, "Unknown",false) || StrEqual(s_Country, "Localhost",false))
		{
			for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != client)
				PrintToChat(i, "%t", "Connected1", WHITE,MOSSGREEN, s_clientName, WHITE);
		}
		else
		{
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i) && i != client)
					PrintToChat(i, "%t", "Connected2", WHITE, MOSSGREEN,s_clientName, WHITE,GREEN,s_Country);
		}
	}
}

public OnSettingChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(convar == g_hGoToServer)
	{
		if(newValue[0] == '1')
			g_bGoToServer = true;
		else
			g_bGoToServer = false;
	}
	if(convar == g_hChallengePoints)
	{
		if(newValue[0] == '1')
			g_bChallengePoints = true;
		else
			g_bChallengePoints = false;
	}
	if(convar == g_hPreStrafe)
	{
		if(newValue[0] == '1')
			g_bPreStrafe = true;
		else
		{
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					SetEntPropFloat(i, Prop_Send, "m_flVelocityModifier", 1.0);
			g_bPreStrafe = false;
		}
	}
	if(convar == g_hNoClipS)
	{
		if(newValue[0] == '1')
			g_bNoClipS = true;
		else
			g_bNoClipS = false;
	}
	if(convar == g_hAutoBan)
	{
		if(newValue[0] == '1')
			g_bAutoBan = true;
		else
			g_bAutoBan = false;
	}
	if(convar == g_hReplayBot)
	{
		if(newValue[0] == '1')
		{
			g_bReplayBot = true;
			LoadReplays();
		}
		else
		{
			for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i))
			{
				if (i == g_TpBot || i == g_ProBot)
				{
					StopPlayerMimic(i);
					KickClient(i);
				}
				else
				{
					if(g_hRecording[i] != INVALID_HANDLE)
						StopRecording(i);
				}
			}
			if (g_bInfoBot)
				ServerCommand("bot_quota 1");
			else
				ServerCommand("bot_quota 0");
			g_bReplayBot = false;
		}
	}
	if(convar == g_hAdminClantag)
	{
		if(newValue[0] == '1')
		{
			g_bAdminClantag = true;
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bAdminClantag = false;
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if(convar == g_hVipClantag)
	{
		if(newValue[0] == '1')
		{
			g_bVipClantag = true;
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bVipClantag = false;
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if(convar == g_hAutoTimer)
	{
		if(newValue[0] == '1')
			g_bAutoTimer = true;
		else
			g_bAutoTimer = false;
	}
	if(convar == g_hPauseServerside)
	{
		if(newValue[0] == '1')
			g_bPauseServerside = true;
		else
			g_bPauseServerside = false;
	}
	if (convar == g_hTierMessages)
	{
		if(newValue[0] == '1')
			g_bTierMessages = true;
		else
			g_bTierMessages = false;
	}
	if (convar == g_hEnableChatProcessing)
	{
		if(newValue[0] == '1')
			g_bEnableChatProcessing = true;
		else
			g_bEnableChatProcessing = false;
	}
	if (convar == g_hEnableGroupAdverts)
	{
		if(newValue[0] == '1')
			g_bEnableGroupAdverts = true;
		else
			g_bEnableGroupAdverts = false;
	}
	if(convar == g_hDynamicTimelimit)
	{
		if(newValue[0] == '1')
			g_bDynamicTimelimit = true;
		else
			g_bDynamicTimelimit = false;
	}
	if(convar == g_hDefaultLanguage)
		g_DefaultLanguage = StringToInt(newValue[0]);
	if(convar == g_hAutohealing_Hp)
		g_Autohealing_Hp = StringToInt(newValue[0]);
	if(convar == g_hTeam_Restriction)
		g_Team_Restriction = StringToInt(newValue[0]);
	if(convar == g_hAutoRespawn)
	{
		if(newValue[0] == '1')
		{
			ServerCommand("mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1;mp_respawnwavetime_ct 3.0;mp_respawnwavetime_t 3.0");
			g_bAutoRespawn = true;
		}
		else
		{
			ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0");
			g_bAutoRespawn = false;
		}
	}
	if(convar == g_hAllowCheckpoints)
	{
		if(newValue[0] == '1')
			g_bAllowCheckpoints = true;
		else
			g_bAllowCheckpoints = false;
	}
	if(convar == g_hRadioCommands)
	{
		if(newValue[0] == '1')
			g_bRadioCommands = true;
		else
			g_bRadioCommands = false;
	}
	if(convar == g_hcvarRestore)
	{
		if(newValue[0] == '1')
			g_bRestore = true;
		else
			g_bRestore = false;
	}
	if(convar == g_hMapEnd)
	{
		if(newValue[0] == '1')
			g_bMapEnd = true;
		else
			g_bMapEnd = false;
	}
	if(convar == g_hConnectMsg)
	{
		if(newValue[0] == '1')
			g_bConnectMsg = true;
		else
			g_bConnectMsg = false;
	}
	if(convar == g_hPlayerSkinChange)
	{
		if(newValue[0] == '1')
		{
			g_bPlayerSkinChange = true;
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
				{
					if (i == g_TpBot)
					{
						SetEntPropString(i, Prop_Send, "m_szArmsModel", g_sReplayBotArmModel2);
						SetEntityModel(i,  g_sReplayBotPlayerModel2);
					}
					else
						if (i == g_ProBot)
						{
							SetEntPropString(i, Prop_Send, "m_szArmsModel", g_sReplayBotPlayerModel);
							SetEntityModel(i,  g_sReplayBotPlayerModel);
						}
						else
						{
							SetEntPropString(i, Prop_Send, "m_szArmsModel", g_sArmModel);
							SetEntityModel(i,  g_sPlayerModel);
						}
				}
		}
		else
			g_bPlayerSkinChange = false;
	}
	if(convar == g_hPointSystem)
	{
		if(newValue[0] == '1')
		{
			g_bPointSystem = true;
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (new i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
				{
					Format(g_pr_rankname[i], 32, "");
					CreateTimer(0.0, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
				}
			g_bPointSystem = false;
		}
	}
	if(convar == g_hAttackSpamProtection)
	{
		if(newValue[0] == '1')
		{
			g_bAttackSpamProtection = true;
		}
		else
		{
			g_bAttackSpamProtection = false;
		}
	}
	if(convar == g_hCleanWeapons)
	{
		if(newValue[0] == '1')
		{
			decl String:szclass[32];
			g_bCleanWeapons = true;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i))
				{
					for(new j = 0; j < 4; j++)
					{
						new weapon = GetPlayerWeaponSlot(i, j);
						if(weapon != -1 && j != 2)
						{
							GetEdictClassname(weapon, szclass, sizeof(szclass));
							RemovePlayerItem(i, weapon);
							RemoveEdict(weapon);
							new equipweapon = GetPlayerWeaponSlot(i, 2)
							if (equipweapon != -1)
								EquipPlayerWeapon(i, equipweapon);
						}
					}
				}
			}

		}
		else
			g_bCleanWeapons = false;
	}
	if(convar == g_hEnforcer)
	{
		if(newValue[0] == '1')
		{
			new Float:JumpImpulseValue = GetConVarFloat(g_hJumpImpulse);

			g_bEnforcer = true;
			SetConVarFloat(g_hStaminaLandCost, 0.0);
			SetConVarFloat(g_hStaminaJumpCost, 0.0);
			SetConVarFloat(g_hMaxSpeed, 320.0);
			SetConVarFloat(g_hGravity, 800.0);
			SetConVarFloat(g_hAirAccelerate, 100.0);
			SetConVarFloat(g_hFriction, 5.0);
			SetConVarFloat(g_hAccelerate, 6.5);
			SetConVarFloat(g_hMaxVelocity, 2000.0);
			SetConVarFloat(g_hBhopSpeedCap, 380.0);
			SetConVarFloat(g_hWaterAccelerate, 10.0);
			SetConVarInt(g_hCheats, 0);
			SetConVarInt(g_hEnableBunnyhoping, 1);
			SetConVarInt(g_hReplayBot, 1);
			SetConVarInt(g_hDropKnifeEnable, 0);
			SetConVarInt(g_hAutoBhop, 0);
			SetConVarInt(g_hClampVel, 0);
			SetConVarFloat(g_hsv_ladder_scale_speed, 1.0);
			SetConVarFloat(g_hJumpImpulse, 301.993377);
			SetConVarInt(g_hAccelerateUseWeaponSpeed, 0);
			SetConVarFloat(g_hWaterMovespeedMultiplier, 0.8);
			SetConVarInt(g_hWaterSwimMode, 0);
			SetConVarFloat(g_hWeaponEncumbranceScale, 0.0);
			SetConVarFloat(g_hAirMaxWishspeed, 30.0);
			SetConVarInt(g_hLedgeMantleHelper, 0);
			SetConVarFloat(g_hStandableNormal, 0.7);
			SetConVarFloat(g_hWalkableNormal, 0.7);
			SetConVarInt(g_hAmmoGrenadeLimitBumpmine, 0);
			SetConVarFloat(g_hBumpmineDetonateDelay, 99999.9);
			SetConVarFloat(g_hShieldSpeedDeployed, 250.0);
			SetConVarFloat(g_hShieldSpeedHolstered, 250.0);
			SetConVarFloat(g_hExojumpJumpbonusForward, 0.0);
			SetConVarFloat(g_hExojumpJumpbonusUp, 0.0);
			SetConVarFloat(g_hExojumpJumpcost, 0.0);
			SetConVarFloat(g_hExojumpLandcost, 0.0);
			SetConVarFloat(g_hJumpImpulseExojumpMultiplier, 1.0);

			if (FloatAbs(JumpImpulseValue - 301.993377) > 0.00000)
				ServerCommand("sv_jump_impulse 301.993377");
		}
		else
			g_bEnforcer = false;
	}
	if(convar == g_hJumpStats)
	{
		if(newValue[0] == '1')
			g_bJumpStats = true;
		else
			g_bJumpStats = false;
	}
	if(convar == g_hDoubleDuckCvar)
	{
		if(newValue[0] == '1')
			g_bDoubleDuckCvar = true;
		else
			g_bDoubleDuckCvar = false;
	}
	if(convar == g_hSlayPlayers)
	{
		if(newValue[0] == '1')
			g_bSlayPlayers = true;
		else
			g_bSlayPlayers = false;
	}
	if(convar == g_hAllowRoundEndCvar)
	{
		if(newValue[0] == '1')
		{
			ServerCommand("mp_ignore_round_win_conditions 0");
			g_bAllowRoundEndCvar = true;
		}
		else
		{
			ServerCommand("mp_ignore_round_win_conditions 1;mp_maxrounds 1");
			g_bAllowRoundEndCvar = false;
		}
	}
	if(convar == g_hSingleTouch)
	{
		if(newValue[0] == '1')
			g_bSingleTouch = true;
		else
			g_bSingleTouch = false;
	}
	if(convar == g_hAutoBhopConVar)
	{
		if(newValue[0] == '1')
		{
			g_bAutoBhopConVar = true;
			if(StrEqual(g_szMapPrefix[0],"surf") || StrEqual(g_szMapPrefix[0],"bhop") || StrEqual(g_szMapPrefix[0],"mg"))
			{
				g_bAutoBhop = true;
			}
		}
		else
		{
			g_bAutoBhopConVar = false;
			g_bAutoBhop = false;
		}
	}

	if(convar == g_hCountry)
	{
		if(newValue[0] == '1')
		{
			g_bCountry = true;
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					GetCountry(i);
					if (g_bPointSystem)
						CreateTimer(0.5, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		else
		{
			g_bCountry = false;
			if (g_bPointSystem)
				for (new i = 1; i <= MaxClients; i++)
					if (IsValidClient(i))
						CreateTimer(0.5, SetClanTag, i,TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if(convar == g_hMinSkillGroup)
		g_MinSkillGroup = StringToInt(newValue[0]);

	if(convar == g_hExtraPoints)
		g_ExtraPoints = StringToInt(newValue[0]);

	if(convar == g_hExtraPoints2)
		g_ExtraPoints2 = StringToInt(newValue[0]);

	if(convar == g_hSpecsAdvert)
	{
		g_fSpecsAdvert = StringToFloat(newValue[0]);
		if(g_hSpecAdvertTimer)
			KillTimer(g_hSpecAdvertTimer);
		g_hSpecAdvertTimer	= CreateTimer(g_fSpecsAdvert, SpecAdvertTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	if(convar == g_hdist_good_multibhop)
		g_dist_min_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_impressive_multibhop)
		g_dist_impressive_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_perfect_multibhop)
		g_dist_perfect_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_godlike_multibhop)
		g_dist_god_multibhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_bhop)
		g_dist_min_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_impressive_bhop)
		g_dist_impressive_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_perfect_bhop)
		g_dist_perfect_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_godlike_bhop)
		g_dist_god_bhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_dropbhop)
		g_dist_min_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_impressive_dropbhop)
		g_dist_impressive_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_perfect_dropbhop)
		g_dist_perfect_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_godlike_dropbhop)
		g_dist_god_dropbhop = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_weird)
		g_dist_min_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_impressive_weird)
		g_dist_impressive_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_perfect_weird)
		g_dist_perfect_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_godlike_weird)
		g_dist_god_weird = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_lj)
		g_dist_min_lj = StringToFloat(newValue[0]);

	if(convar == g_hdist_impressive_lj)
		g_dist_impressive_lj = StringToFloat(newValue[0]);

	if(convar == g_hdist_perfect_lj)
		g_dist_perfect_lj = StringToFloat(newValue[0]);

	if(convar == g_hdist_godlike_lj)
		g_dist_god_lj = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_countjump)
		g_dist_min_countjump = StringToFloat(newValue[0]);

	if(convar == g_hdist_impressive_countjump)
		g_dist_impressive_countjump = StringToFloat(newValue[0]);

	if(convar == g_hdist_perfect_countjump)
		g_dist_perfect_countjump = StringToFloat(newValue[0]);

	if(convar == g_hdist_godlike_countjump)
		g_dist_god_countjump = StringToFloat(newValue[0]);

	if(convar == g_hdist_good_ladder)
		g_dist_min_ladder = StringToFloat(newValue[0]);

	if(convar == g_hdist_impressive_ladder)
		g_dist_impressive_ladder = StringToFloat(newValue[0]);

	if(convar == g_hdist_perfect_ladder)
		g_dist_perfect_ladder = StringToFloat(newValue[0]);

	if(convar == g_hdist_godlike_ladder)
		g_dist_god_ladder = StringToFloat(newValue[0]);

	if(convar == g_hBanDuration)
		g_fBanDuration = StringToFloat(newValue[0]);

	if(convar == g_hTransPlayerModels)
	{
		g_TransPlayerModels = StringToInt(newValue[0]);
		for (new client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client))
			{
				if (client == g_ProBot)
					SetEntityRenderColor(client, g_ReplayBotProColor[0], g_ReplayBotProColor[1], g_ReplayBotProColor[2], g_TransPlayerModels);
				else
					if (client == g_TpBot)
						SetEntityRenderColor(client, g_ReplayBotTpColor[0], g_ReplayBotTpColor[1], g_ReplayBotTpColor[2], g_TransPlayerModels);
					else
						SetEntityRenderColor(client, 255, 255, 255, g_TransPlayerModels);
			}
		}
	}
	if(convar == g_hMaxBhopPreSpeed)
		g_fMaxBhopPreSpeed = StringToFloat(newValue[0]);

	if(convar == g_hcvargodmode)
	{
		if(newValue[0] == '1')
			g_bgodmode = true;
		else
			g_bgodmode = false;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if (g_bgodmode)
					SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
				else
					SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			}
		}
	}
	if(convar == g_hInfoBot)
	{
		if(newValue[0] == '1')
		{
			g_bInfoBot = true;
			LoadInfoBot();
		}
		else
		{
			g_bInfoBot = false;
			for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && IsFakeClient(i))
			{
				if (i == g_InfoBot)
				{
					new count = 0;
					g_InfoBot = -1;
					KickClient(i);
					decl String:szBuffer[64];
					if(g_bProReplay)
						count++;
					if(g_bTpReplay)
						count++;
					Format(szBuffer, sizeof(szBuffer), "bot_quota %i", count);
					ServerCommand(szBuffer);
				}
			}
		}
	}
	if(convar == g_hReplayBotPlayerModel)
	{
		Format(g_sReplayBotPlayerModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);
		AddFileToDownloadsTable(g_sReplayBotPlayerModel);
		if (g_ProBot != -1)
			SetEntityModel(g_ProBot,  newValue[0]);
	}
	if(convar == g_hReplayBotArmModel)
	{
		Format(g_sReplayBotArmModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);
		AddFileToDownloadsTable(g_sReplayBotArmModel);
		if (g_ProBot != -1)
				SetEntPropString(g_ProBot, Prop_Send, "m_szArmsModel", newValue[0]);
	}
	if(convar == g_hReplayBotPlayerModel2)
	{
		Format(g_sReplayBotPlayerModel2,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);
		AddFileToDownloadsTable(g_sReplayBotPlayerModel2);
		if (g_TpBot != -1)
			SetEntityModel(g_TpBot,  newValue[0]);
	}
	if(convar == g_hReplayBotArmModel2)
	{
		Format(g_sReplayBotArmModel2,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);
		AddFileToDownloadsTable(g_sReplayBotArmModel2);
		if (g_TpBot != -1)
				SetEntPropString(g_TpBot, Prop_Send, "m_szArmsModel", newValue[0]);
	}
	if(convar == g_hPlayerModel)
	{
		Format(g_sPlayerModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);
		AddFileToDownloadsTable(g_sPlayerModel);
		if (!g_bPlayerSkinChange)
			return;
		for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != g_TpBot && i != g_ProBot)
				SetEntityModel(i,  newValue[0]);
	}
	if(convar == g_hArmModel)
	{
		Format(g_sArmModel,256,"%s", newValue[0]);
		PrecacheModel(newValue[0],true);
		AddFileToDownloadsTable(g_sArmModel);
		if (!g_bPlayerSkinChange)
			return;
		for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != g_TpBot && i != g_ProBot)
				SetEntPropString(i, Prop_Send, "m_szArmsModel", newValue[0]);
	}
	if(convar == g_hWelcomeMsg)
		Format(g_sWelcomeMsg,512,"%s", newValue[0]);

	if(convar == g_hReplayBotTpColor)
	{
		decl String:color[256];
		Format(color,256,"%s", newValue[0]);
		GetRGBColor(1,color);
	}
	if(convar == g_hReplayBotProColor)
	{
		decl String:color[256];
		Format(color,256,"%s", newValue[0]);
		GetRGBColor(0,color);
	}


	//Settings Enforcer
	if(convar == g_hBhopSpeedCap)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 380.0)
			SetConVarFloat(g_hBhopSpeedCap, 380.0);
		else
			g_fBhopSpeedCap = StringToFloat(newValue[0]);
	}

	if(convar == g_hStaminaLandCost)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 0.0)
			SetConVarFloat(g_hStaminaLandCost, 0.0);
	}
	if(convar == g_hStaminaJumpCost)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 0.0)
			SetConVarFloat(g_hStaminaJumpCost, 0.0);
	}
	if(convar == g_hMaxSpeed)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 320.0)
			SetConVarFloat(g_hMaxSpeed, 320.0);
	}

	if(convar == g_hGravity)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 800.0)
			SetConVarFloat(g_hGravity, 800.0);
	}
	if(convar == g_hAirAccelerate)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 100.0)
			SetConVarFloat(g_hAirAccelerate, 100.0);
	}
	if(convar == g_hFriction)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 5.0)
			SetConVarFloat(g_hFriction, 5.0);
	}
	if(convar == g_hAccelerate)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 6.5)
			SetConVarFloat(g_hAccelerate, 6.5);
	}
	if(convar == g_hMaxVelocity)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 2000.0)
			SetConVarFloat(g_hMaxVelocity, 2000.0);
	}
	if(convar == g_hWaterAccelerate)
	{
		new Float:fTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && fTmp != 10.0)
			SetConVarFloat(g_hWaterAccelerate, 10.0);
	}
	if(convar == g_hCheats)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
			SetConVarInt(g_hCheats, 0);
	}
	if(convar == g_hDropKnifeEnable)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
			SetConVarInt(g_hDropKnifeEnable, 0);
	}
	if(convar == g_hMaxRounds)
	{
		if (!g_bAllowRoundEndCvar)
			SetConVarInt(g_hMaxRounds, 1);
	}
	if(convar == g_hEnableBunnyhoping)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 1)
			SetConVarInt(g_hEnableBunnyhoping, 1);
	}

	if(convar == g_hsv_ladder_scale_speed)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 1.0)
			SetConVarFloat(g_hsv_ladder_scale_speed, 1.0);
	}
	if (convar == g_hReplayBot)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 1)
			SetConVarInt(g_hReplayBot, 1);
	}
	if(convar == g_hAutoBhop)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
			SetConVarInt(g_hAutoBhop, 0);
	}
	if(convar == g_hClampVel)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
			SetConVarInt(g_hClampVel, 0);
	}
	if(convar == g_hJumpImpulse)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		new Float:JumpImpulseValue = GetConVarFloat(g_hJumpImpulse);

			if (g_bEnforcer && flTmp != 301.993377)
			{
				SetConVarFloat(g_hJumpImpulse, 301.993377);
			}

			if (g_bEnforcer && FloatAbs(JumpImpulseValue - 301.993377) > 0.00000)
			{
				ServerCommand("sv_jump_impulse 301.993377");
			}
	}
	if (convar == g_hAccelerateUseWeaponSpeed)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
		{
			SetConVarInt(g_hAccelerateUseWeaponSpeed, 0);
		}
	}
	if (convar == g_hWaterMovespeedMultiplier)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.8)
		{
			SetConVarFloat(g_hWaterMovespeedMultiplier, 0.8);
		}
	}
	if (convar == g_hWaterSwimMode)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
		{
			SetConVarInt(g_hWaterSwimMode, 0);
		}
	}
	if (convar == g_hWeaponEncumbranceScale)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.0)
		{
			SetConVarFloat(g_hWeaponEncumbranceScale, 0.0);
		}
	}
	if (convar == g_hAirMaxWishspeed)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 30.0)
		{
			SetConVarFloat(g_hAirMaxWishspeed, 30.0);
		}
	}
	if (convar == g_hLedgeMantleHelper)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
		{
			SetConVarInt(g_hLedgeMantleHelper, 0);
		}
	}
	if (convar == g_hStandableNormal)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.7)
		{
			SetConVarFloat(g_hStandableNormal, 0.7);
		}
	}
	if (convar == g_hWalkableNormal)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.7)
		{
			SetConVarFloat(g_hWalkableNormal, 0.7);
		}
	}
	if (convar == g_hAmmoGrenadeLimitBumpmine)
	{
		new iTmp = StringToInt(newValue[0]);
		if (g_bEnforcer && iTmp != 0)
		{
			SetConVarInt(g_hAmmoGrenadeLimitBumpmine, 0);
		}
	}
	if (convar == g_hBumpmineDetonateDelay)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 99999.9)
		{
			SetConVarFloat(g_hBumpmineDetonateDelay, 99999.9);
		}
	}
	if (convar == g_hShieldSpeedDeployed)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 250.0)
		{
			SetConVarFloat(g_hShieldSpeedDeployed, 250.0);
		}
	}
	if (convar == g_hShieldSpeedHolstered)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 250.0)
		{
			SetConVarFloat(g_hShieldSpeedHolstered, 250.0);
		}
	}
	if (convar == g_hExojumpJumpbonusForward)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.0)
		{
			SetConVarFloat(g_hExojumpJumpbonusForward, 0.0);
		}
	}
	if (convar == g_hExojumpJumpbonusUp)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.0)
		{
			SetConVarFloat(g_hExojumpJumpbonusUp, 0.0);
		}
	}
	if (convar == g_hExojumpJumpcost)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.0)
		{
			SetConVarFloat(g_hExojumpJumpcost, 0.0);
		}
	}
	if (convar == g_hExojumpLandcost)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 0.0)
		{
			SetConVarFloat(g_hExojumpLandcost, 0.0);
		}
	}
	if (convar == g_hJumpImpulseExojumpMultiplier)
	{
		new Float:flTmp = StringToFloat(newValue[0]);
		if (g_bEnforcer && flTmp != 1.0)
		{
			SetConVarFloat(g_hJumpImpulseExojumpMultiplier, 1.0);
		}
	}
}

public Native_GetTimerStatus(Handle:plugin, numParams)
	return g_bTimeractivated[GetNativeCell(1)];

public Native_GetVersion(Handle plugin, int numParams)
{
	return PLUGIN_VERSION;
}

public Native_GetVersion_Desc(Handle plugin, int numParams)
{
	SetNativeString(1, VERSION, GetNativeCell(2));
}

public Native_StopUpdatingOfClimbersMenu(Handle:plugin, numParams)
{
	g_bMenuOpen[GetNativeCell(1)] = true;
	if (g_hclimbersmenu[GetNativeCell(1)] != INVALID_HANDLE)
	{
		g_hclimbersmenu[GetNativeCell(1)] = INVALID_HANDLE;
	}
	if (g_bClimbersMenuOpen[GetNativeCell(1)])
		g_bClimbersMenuwasOpen[GetNativeCell(1)]=true;
	else
		g_bClimbersMenuwasOpen[GetNativeCell(1)]=false;
	g_bClimbersMenuOpen[GetNativeCell(1)] = false;
}

public Native_StopTimer(Handle:plugin, numParams)
	Client_Stop(GetNativeCell(1),0);

public Native_GetCurrentTime(Handle:plugin, numParams)
	return _:g_fCurrentRunTime[GetNativeCell(1)];

public Native_GetSkillGroup(Handle:plugin, numParams)
	return g_Skillgroup[GetNativeCell(1)];

public Native_GetAvgTimeTp(Handle:plugin, numParams)
{
	if (g_MapTimesCountTp==0)
		return _:0.0;
	else
		return _:g_favg_tptime;
}

public Native_GetAvgTimePro(Handle:plugin, numParams)
{
	if (g_MapTimesCountPro==0)
		return _:0.0;
	else
		return _:g_favg_protime;
}

// Deprecate these for now
public Native_EmulateStartButtonPress(Handle:plugin, numParams)
{
	int client = GetNativeCell(1);
	PrintToChat(client, "This feature is deprecated");
}

public Native_EmulateStopButtonPress(Handle:plugin, numParams)
{
	int client = GetNativeCell(1);
	PrintToChat(client, "This feature is deprecated");
}


void Call_KZTimer_OnJumpstatInvalid(int client) {
	Call_StartForward(g_hFWD_OnJumpstatInvalid);
	Call_PushCell(client);
	Call_Finish();
}

void Call_KZTimer_OnJumpstatCompleted(int client, int jump_type, int jump_color, float distance, bool personal_best) {
	Call_StartForward(g_hFWD_OnJumpstatCompleted);
	Call_PushCell(client);
	Call_PushCell(jump_type);
	Call_PushCell(jump_color);
	Call_PushFloat(distance);
	Call_PushCell(personal_best);
	Call_Finish();
}

void Call_KZTimer_OnJumpstatStarted(int client) {
	Call_StartForward(g_hFWD_OnJumpstatStarted);
	Call_PushCell(client);
	Call_Finish();
}

//Credits: Macrodox by Inami (https://forums.alliedmods.net/showthread.php?p=1678026)
public OnGameFrame()
{
	//realbhop
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsPlayerAlive(i) && !PlayerInTriggerPush[i] && !g_bPause[i])
		{
			if(GetEntityFlags(i) & FL_ONGROUND)
			{ // on ground
				if (!PlayerOnGround[i]) { // first ground frame

					// player now on ground
					PlayerOnGround[i] = true;
					// reset floor frame counter
					FloorFrames[i] = 0;
				}
				else
				{ // another ground frame
					if (FloorFrames[i] <= 12)
					{
						FloorFrames[i]++;
					}
				}
			}
			else
			{ // in air
				if (AfterJumpFrame[i])
				{ // apply the boostsecond air frame
										 // to prevent some glitchiness
					// only apply within the maxbhopframes range
					if (FloorFrames[i] <= 12)
					{
						decl Float:flbaseVelocity[3];
						GetEntPropVector(i, Prop_Data, "m_vecBaseVelocity", flbaseVelocity);
						if (flbaseVelocity[0] != 0.0 || flbaseVelocity[1] != 0.0 || flbaseVelocity[2] != 0.0)
						{
							g_JumpCheck1[i]++;
						}
					}
					AfterJumpFrame[i] = false;
				}

				if (PlayerOnGround[i])
				{
					// player not on ground anymore
					PlayerOnGround[i] = false;
					AfterJumpFrame[i] = true;
				}
				else
				{
					// get air speed
					// NOTE: this has to be done every airframe
					// to have the last speed value of the frame _before_ landing,
					// not of the landing frame itself, as the speed is already changed
					// in that frame if the player lands on sloped surfaces in some
					// angles :/
					GetEntPropVector(i, Prop_Data, "m_vecVelocity", AirSpeed[i]);
				}
			}
		}
	}
}

public Plugin:myinfo =
{
	name = "KZTimer",
	author = "1NutWunDeR",
	description = "timer plugin",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=223274"
}
