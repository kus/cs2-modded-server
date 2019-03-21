#define UPDATE_URL "https://dl.whiffcity.com/plugins/practicemode/practicemode.txt"

#include <clientprefs>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#include <smlib>
#include <sourcemod>

#undef REQUIRE_PLUGIN
#include "include/botmimic.inc"
#include "include/csutils.inc"

#include <get5>
#include <pugsetup>
#include <updater>

#include "include/practicemode.inc"
#include "include/restorecvars.inc"
#include "practicemode/util.sp"

#pragma semicolon 1
#pragma newdecls required

bool g_InPracticeMode = false;
bool g_PugsetupLoaded = false;
bool g_CSUtilsLoaded = false;
bool g_BotMimicLoaded = false;

// These data structures maintain a list of settings for a toggle-able option:
// the name, the cvar/value for the enabled option, and the cvar/value for the disabled option.
// Note: the first set of values for these data structures is the overall-practice mode cvars,
// which aren't toggle-able or named.
ArrayList g_BinaryOptionIds;
ArrayList g_BinaryOptionNames;
ArrayList g_BinaryOptionEnabled;
ArrayList g_BinaryOptionChangeable;
ArrayList g_BinaryOptionEnabledCvars;
ArrayList g_BinaryOptionEnabledValues;
ArrayList g_BinaryOptionDisabledCvars;
ArrayList g_BinaryOptionDisabledValues;
ArrayList g_BinaryOptionCvarRestore;

ArrayList g_MapList;

/** Chat aliases loaded **/
#define ALIAS_LENGTH 64
#define COMMAND_LENGTH 64
ArrayList g_ChatAliases;
ArrayList g_ChatAliasesCommands;

// Plugin cvars
ConVar g_AlphabetizeNadeMenusCvar;
ConVar g_AutostartCvar;
ConVar g_BotRespawnTimeCvar;
ConVar g_DryRunFreezeTimeCvar;
ConVar g_MaxGrenadesSavedCvar;
ConVar g_MaxHistorySizeCvar;
ConVar g_PracModeCanBeStartedCvar;
ConVar g_SharedAllNadesCvar;
ConVar g_FastfowardRequiresZeroVolumeCvar;

// Infinite money data
ConVar g_InfiniteMoneyCvar;

// Client cvars cached
int g_ClientColors[MAXPLAYERS + 1][4];
float g_ClientVolume[MAXPLAYERS + 1];

// Grenade trajectory fix data
int g_BeamSprite = -1;
ConVar g_PatchGrenadeTrajectoryCvar;
ConVar g_GrenadeTrajectoryClientColorCvar;
ConVar g_RandomGrenadeTrajectoryCvar;

ConVar g_AllowNoclipCvar;
ConVar g_GrenadeTrajectoryCvar;
ConVar g_GrenadeThicknessCvar;
ConVar g_GrenadeTimeCvar;
ConVar g_GrenadeSpecTimeCvar;

// Other cvars.
ConVar g_FlashEffectiveThresholdCvar;
ConVar g_TestFlashTeleportDelayCvar;
ConVar g_VersionCvar;

// Saved grenade locations data
#define GRENADE_DESCRIPTION_LENGTH 256
#define GRENADE_NAME_LENGTH 64
#define GRENADE_ID_LENGTH 16
#define GRENADE_CATEGORY_LENGTH 128
#define AUTH_LENGTH 64
#define AUTH_METHOD AuthId_Steam2
char g_GrenadeLocationsFile[PLATFORM_MAX_PATH];
KeyValues
    g_GrenadeLocationsKv;  // Inside any global function, we expect this to be at the root level.
int g_CurrentSavedGrenadeId[MAXPLAYERS + 1];
bool g_UpdatedGrenadeKv = false;  // whether there has been any changed the kv structure this map
int g_NextID = 0;

// Grenade history data
int g_GrenadeHistoryIndex[MAXPLAYERS + 1];
ArrayList g_GrenadeHistoryPositions[MAXPLAYERS + 1];
ArrayList g_GrenadeHistoryAngles[MAXPLAYERS + 1];

ArrayList g_ClientGrenadeThrowTimes[MAXPLAYERS + 1];  // ArrayList of <int:entity, float:throw time>
                                                      // pairs of live grenades
bool g_TestingFlash[MAXPLAYERS + 1];
float g_TestingFlashOrigins[MAXPLAYERS + 1][3];
float g_TestingFlashAngles[MAXPLAYERS + 1][3];

bool g_ClientNoFlash[MAXPLAYERS + 1];
float g_LastFlashDetonateTime[MAXPLAYERS + 1];

bool g_RunningRepeatedCommand[MAXPLAYERS + 1];
char g_RunningRepeatedCommandArg[MAXPLAYERS][256];

ArrayList g_RunningRoundRepeatedCommandDelay[MAXPLAYERS + 1]; /* float */
ArrayList g_RunningRoundRepeatedCommandArg[MAXPLAYERS + 1];   /* char[256] */

GrenadeType g_LastGrenadeType[MAXPLAYERS + 1];
float g_LastGrenadeOrigin[MAXPLAYERS + 1][3];
float g_LastGrenadeVelocity[MAXPLAYERS + 1][3];

// Respawn values set by clients in the current session
bool g_SavedRespawnActive[MAXPLAYERS + 1];
float g_SavedRespawnOrigin[MAXPLAYERS + 1][3];
float g_SavedRespawnAngles[MAXPLAYERS + 1][3];

ArrayList g_KnownNadeCategories = null;

ArrayList g_ClientBots[MAXPLAYERS + 1];  // Bots owned by each client.
bool g_IsPMBot[MAXPLAYERS + 1];
float g_BotSpawnOrigin[MAXPLAYERS + 1][3];
float g_BotSpawnAngles[MAXPLAYERS + 1][3];
char g_BotSpawnWeapon[MAXPLAYERS + 1][64];
bool g_BotCrouching[MAXPLAYERS + 1];
int g_BotNameNumber[MAXPLAYERS + 1];
float g_BotDeathTime[MAXPLAYERS + 1];

bool g_BotInit = false;
bool g_InBotReplayMode = false;
KeyValues g_ReplaysKv;

#define PLAYER_HEIGHT 72.0
#define CROUCH_PLAYER_HEIGHT (PLAYER_HEIGHT - 18.0)
#define CLASS_LENGTH 64

const int kMaxBackupsPerMap = 50;

// These must match the values used by cl_color.
enum ClientColor {
  ClientColor_Yellow = 0,
  ClientColor_Purple = 1,
  ClientColor_Green = 2,
  ClientColor_Blue = 3,
  ClientColor_Orange = 4,
};

int g_LastNoclipCommand[MAXPLAYERS + 1];

enum TimerType {
  TimerType_Movement = 0,
  TimerType_Manual = 1,
}

bool g_RunningTimeCommand[MAXPLAYERS + 1];
bool g_RunningLiveTimeCommand[MAXPLAYERS + 1];
TimerType g_TimerType[MAXPLAYERS + 1];
float g_LastTimeCommand[MAXPLAYERS + 1];

MoveType g_PreFastForwardMoveTypes[MAXPLAYERS + 1];

enum GrenadeMenuType {
  GrenadeMenuType_Invalid = -1,
  GrenadeMenuType_PlayersAndCategories = 0,
  GrenadeMenuType_Categories = 1,
  GrenadeMenuType_OnePlayer = 2,
  GrenadeMenuType_OneCategory = 3,  // Note: empty category "" = all nades.
  GrenadeMenuType_MatchingName = 4,
  GrenadeMenuType_MatchingId = 5,
};

// All the data we need to call GiveGrenadeMenu for a client to reopen the .nades menu
// where they left off. The first set are for the 'top' menus where you select a player or category.
// The second set are for the lower level menus of selecting a single grenade from a
// player/category menu.
GrenadeMenuType g_ClientLastTopMenuType[MAXPLAYERS + 1];
int g_ClientLastTopMenuPos[MAXPLAYERS + 1];
char g_ClientLastTopMenuData[MAXPLAYERS + 1][AUTH_LENGTH];

GrenadeMenuType g_ClientLastMenuType[MAXPLAYERS + 1];
int g_ClientLastMenuPos[MAXPLAYERS + 1];
char g_ClientLastMenuData[MAXPLAYERS + 1][AUTH_LENGTH];

// Data storing spawn priorities.
ArrayList g_CTSpawns = null;
ArrayList g_TSpawns = null;
KeyValues g_NamedSpawnsKv = null;

enum UserSetting {
  UserSetting_ShowAirtime,
  UserSetting_LeaveNadeMenuOpen,
  UserSetting_NoGrenadeTrajectory,
  UserSetting_SwitchToNadeOnSelect,
  UserSetting_StopsRecordingInspectKey,
  UserSetting_NumSettings,
};
#define USERSETTING_DISPLAY_LENGTH 128
Handle g_UserSettingCookies[UserSetting_NumSettings];
bool g_UserSettingDefaults[UserSetting_NumSettings];
char g_UserSettingDisplayName[UserSetting_NumSettings][USERSETTING_DISPLAY_LENGTH];

// Forwards
Handle g_OnGrenadeSaved = INVALID_HANDLE;
Handle g_OnPracticeModeDisabled = INVALID_HANDLE;
Handle g_OnPracticeModeEnabled = INVALID_HANDLE;
Handle g_OnPracticeModeSettingChanged = INVALID_HANDLE;
Handle g_OnPracticeModeSettingsRead = INVALID_HANDLE;

#define CHICKEN_MODEL "models/chicken/chicken.mdl"

#include "practicemode/grenade_iterators.sp"

#include "practicemode/botreplay.sp"
#include "practicemode/botreplay_data.sp"
#include "practicemode/botreplay_editor.sp"
#include "practicemode/botreplay_utils.sp"

#include "practicemode/backups.sp"
#include "practicemode/bots.sp"
#include "practicemode/bots_menu.sp"
#include "practicemode/commands.sp"
#include "practicemode/debug.sp"
#include "practicemode/grenade_commands.sp"
#include "practicemode/grenade_filters.sp"
#include "practicemode/grenade_menus.sp"
#include "practicemode/grenade_utils.sp"
#include "practicemode/natives.sp"
#include "practicemode/pugsetup_integration.sp"
#include "practicemode/settings_menu.sp"
#include "practicemode/spawns.sp"

// clang-format off
public Plugin myinfo = {
  name = "CS:GO PracticeMode",
  author = "splewis",
  description = "A practice mode that can be launched through the .setup menu",
  version = PLUGIN_VERSION,
  url = "https://github.com/splewis/csgo-practice-mode"
};
// clang-format on

public void OnPluginStart() {
  g_InPracticeMode = false;
  AddCommandListener(Command_TeamJoin, "jointeam");
  AddCommandListener(Command_Noclip, "noclip");
  AddCommandListener(Command_SetPos, "setpos");

  // Forwards
  g_OnGrenadeSaved = CreateGlobalForward("PM_OnPracticeModeEnabled", ET_Event, Param_Cell,
                                         Param_Array, Param_Array, Param_String);
  g_OnPracticeModeDisabled = CreateGlobalForward("PM_OnPracticeModeEnabled", ET_Ignore);
  g_OnPracticeModeEnabled = CreateGlobalForward("PM_OnPracticeModeEnabled", ET_Ignore);
  g_OnPracticeModeSettingChanged = CreateGlobalForward(
      "PM_OnPracticeModeEnabled", ET_Ignore, Param_Cell, Param_String, Param_String, Param_Cell);
  g_OnPracticeModeSettingsRead = CreateGlobalForward("PM_OnPracticeModeEnabled", ET_Ignore);

  // Init data structures to be read from the config file
  g_BinaryOptionIds = new ArrayList(OPTION_NAME_LENGTH);
  g_BinaryOptionNames = new ArrayList(OPTION_NAME_LENGTH);
  g_BinaryOptionEnabled = new ArrayList();
  g_BinaryOptionChangeable = new ArrayList();
  g_BinaryOptionEnabledCvars = new ArrayList();
  g_BinaryOptionEnabledValues = new ArrayList();
  g_BinaryOptionDisabledCvars = new ArrayList();
  g_BinaryOptionDisabledValues = new ArrayList();
  g_BinaryOptionCvarRestore = new ArrayList();
  g_MapList = new ArrayList(PLATFORM_MAX_PATH + 1);
  ReadPracticeSettings();

  // Setup stuff for grenade history
  HookEvent("weapon_fire", Event_WeaponFired);
  HookEvent("flashbang_detonate", Event_FlashDetonate);
  HookEvent("smokegrenade_detonate", Event_SmokeDetonate);
  HookEvent("player_blind", Event_PlayerBlind);
  HookEvent("player_death", Event_PlayerDeath);

  for (int i = 0; i <= MAXPLAYERS; i++) {
    g_GrenadeHistoryPositions[i] = new ArrayList(3);
    g_GrenadeHistoryAngles[i] = new ArrayList(3);
    g_ClientGrenadeThrowTimes[i] = new ArrayList(2);
    g_ClientBots[i] = new ArrayList();
    g_RunningRoundRepeatedCommandArg[i] = new ArrayList(256);
    g_RunningRoundRepeatedCommandDelay[i] = new ArrayList();
  }

  {
    RegAdminCmd("sm_prac", Command_LaunchPracticeMode, ADMFLAG_CHANGEMAP, "Launches practice mode");
    RegAdminCmd("sm_launchpractice", Command_LaunchPracticeMode, ADMFLAG_CHANGEMAP,
                "Launches practice mode");
    RegAdminCmd("sm_practice", Command_LaunchPracticeMode, ADMFLAG_CHANGEMAP,
                "Launches practice mode");
    PM_AddChatAlias(".prac", "sm_prac");

    RegAdminCmd("sm_practicemap", Command_Map, ADMFLAG_CHANGEMAP);
    PM_AddChatAlias(".map", "sm_practicemap");

    RegAdminCmd(
        "practicemode_debuginfo", Command_DebugInfo, ADMFLAG_CHANGEMAP,
        "Dumps debug info to a file (addons/sourcemod/logs/practicemode_debuginfo.txt by default)");
  }

  RegAdminCmd("sm_exitpractice", Command_ExitPracticeMode, ADMFLAG_CHANGEMAP,
              "Exits practice mode");
  RegAdminCmd("sm_translategrenades", Command_TranslateGrenades, ADMFLAG_CHANGEMAP,
              "Translates all grenades on this map");
  RegAdminCmd("sm_fixgrenades", Command_FixGrenades, ADMFLAG_CHANGEMAP,
              "Reset grenade ids so they are consecutive and start at 1.");

  // Grenade history commands
  {
    RegConsoleCmd("sm_grenadeback", Command_GrenadeBack);
    PM_AddChatAlias(".back", "sm_grenadeback");

    RegConsoleCmd("sm_grenadeforward", Command_GrenadeForward);
    PM_AddChatAlias(".forward", "sm_grenadeforward");

    RegConsoleCmd("sm_lastgrenade", Command_LastGrenade);
    PM_AddChatAlias(".last", "sm_lastgrenade");

    RegConsoleCmd("sm_nextgrenade", Command_NextGrenade);
    PM_AddChatAlias(".next", "sm_nextgrenade");
    PM_AddChatAlias(".nextid", "sm_nextgrenade");

    RegConsoleCmd("sm_clearnades", Command_ClearNades);
    PM_AddChatAlias(".clearnades", "sm_clearnades");

    RegConsoleCmd("sm_savepos", Command_SavePos);
    PM_AddChatAlias(".savepos", "sm_savepos");
  }

  // Spawn commands
  {
    RegConsoleCmd("sm_gotospawn", Command_GotoSpawn);
    PM_AddChatAlias(".spawn", "sm_gotospawn");
    PM_AddChatAlias(".bestspawn", "sm_gotospawn");

    RegConsoleCmd("sm_gotospawnct", Command_GotoSpawnCT);
    PM_AddChatAlias(".ctspawn", "sm_gotospawnct");

    RegConsoleCmd("sm_gotospawnt", Command_GotoSpawnT);
    PM_AddChatAlias(".tspawn", "sm_gotospawnt");

    RegConsoleCmd("sm_worstspawn", Command_GotoWorstSpawn);
    PM_AddChatAlias(".worstspawn", "sm_worstspawn");

    RegConsoleCmd("sm_namespawn", Command_SaveSpawn);
    PM_AddChatAlias(".namespawn", "sm_namespawn");
  }

  // csutils powered nade stuff.
  {
    RegConsoleCmd("sm_throw", Command_Throw);
    PM_AddChatAlias(".throw", "sm_throw");
    PM_AddChatAlias(".rethrow", "sm_throw");
  }

  // Bot commands
  {
    RegConsoleCmd("sm_bot", Command_Bot);
    PM_AddChatAlias(".bot", "sm_bot");
    PM_AddChatAlias(".addbot", "sm_bot");

    RegConsoleCmd("sm_tbot", Command_TBot);
    PM_AddChatAlias(".tbot", "sm_tbot");
    RegConsoleCmd("sm_ctbot", Command_CTBot);
    PM_AddChatAlias(".ctbot", "sm_ctbot");

    RegConsoleCmd("sm_movebot", Command_MoveBot);
    PM_AddChatAlias(".movebot", "sm_movebot");

    RegConsoleCmd("sm_crouchbot", Command_CrouchBot);
    PM_AddChatAlias(".crouchbot", "sm_crouchbot");
    PM_AddChatAlias(".cbot", "sm_crouchbot");

    RegConsoleCmd("sm_botplace", Command_BotPlace);
    PM_AddChatAlias(".botplace", "sm_botplace");
    PM_AddChatAlias(".bot2", "sm_botplace");

    RegConsoleCmd("sm_swapbot", Command_SwapBot);
    PM_AddChatAlias(".swapbot", "sm_swapbot");
    PM_AddChatAlias(".botswap", "sm_swapbot");

    RegConsoleCmd("sm_boost", Command_Boost);
    PM_AddChatAlias(".boost", "sm_boost");

    RegConsoleCmd("sm_crouchboost", Command_CrouchBoost);
    PM_AddChatAlias(".crouchboost", "sm_crouchboost");
    PM_AddChatAlias(".cboost", "sm_crouchboost");

    RegConsoleCmd("sm_removebot", Command_RemoveBot);
    PM_AddChatAlias(".removebot", "sm_removebot");
    PM_AddChatAlias(".kickbot", "sm_removebot");
    PM_AddChatAlias(".clearbot", "sm_removebot");
    PM_AddChatAlias(".nobot", "sm_removebot");
    PM_AddChatAlias(".deletebot", "sm_removebot");

    RegConsoleCmd("sm_removebots", Command_RemoveBots);
    PM_AddChatAlias(".kickbots", "sm_removebots");
    PM_AddChatAlias(".clearbots", "sm_removebots");
    PM_AddChatAlias(".nobots", "sm_removebots");

    RegConsoleCmd("sm_savebots", Command_SaveBots);
    PM_AddChatAlias(".savebots", "sm_savebots");

    RegConsoleCmd("sm_loadbots", Command_LoadBots);
    PM_AddChatAlias(".loadbots", "sm_loadbots");

    RegConsoleCmd("sm_botsmenu", Command_BotsMenu);
    PM_AddChatAlias(".bots", "sm_botsmenu");
  }

  // Bot replay commands
  {
    AddCommandListener(Command_LookAtWeapon, "+lookatweapon");

    RegConsoleCmd("sm_replay", Command_Replay);
    RegConsoleCmd("sm_replays", Command_Replays);
    PM_AddChatAlias(".replay", "sm_replay");
    PM_AddChatAlias(".replays", "sm_replays");

    RegConsoleCmd("sm_namereplay", Command_NameReplay);
    PM_AddChatAlias(".namereplay", "sm_namereplay");

    RegConsoleCmd("sm_namerole", Command_NameRole);
    PM_AddChatAlias(".namerole", "sm_namerole");

    RegConsoleCmd("sm_cancel", Command_Cancel);
    PM_AddChatAlias(".cancel", "sm_cancel");

    RegConsoleCmd("sm_finishrecording", Command_FinishRecording);
    PM_AddChatAlias(".finish", "sm_finishrecording");

    RegConsoleCmd("sm_playrecording", Command_PlayRecording);
    PM_AddChatAlias(".play", "sm_playrecording");
  }

  // Saved grenade location commands
  {
    RegConsoleCmd("sm_gotogrenade", Command_GotoNade);
    PM_AddChatAlias(".goto", "sm_gotogrenade");

    RegConsoleCmd("sm_grenades", Command_Grenades);
    PM_AddChatAlias(".nades", "sm_grenades");
    PM_AddChatAlias(".grenades", "sm_grenades");

    RegConsoleCmd("sm_find", Command_Find);
    PM_AddChatAlias(".find", "sm_find");

    RegConsoleCmd("sm_renamegrenade", Command_RenameGrenade);
    PM_AddChatAlias(".rename", "sm_renamegrenade");

    RegConsoleCmd("sm_savegrenade", Command_SaveGrenade);
    PM_AddChatAlias(".addnade", "sm_savegrenade");
    PM_AddChatAlias(".savenade", "sm_savegrenade");
    PM_AddChatAlias(".save", "sm_savegrenade");

    RegConsoleCmd("sm_movegrenade", Command_MoveGrenade);
    PM_AddChatAlias(".resave", "sm_movegrenade");
    PM_AddChatAlias(".move", "sm_movegrenade");

    RegConsoleCmd("sm_savethrow", Command_SaveThrow);
    PM_AddChatAlias(".savethrow", "sm_savethrow");
    PM_AddChatAlias(".updatethrow", "sm_savethrow");

    RegConsoleCmd("sm_updategrenade", Command_UpdateGrenade);
    PM_AddChatAlias(".update", "sm_updategrenade");

    RegConsoleCmd("sm_savedelay", Command_SetDelay);
    PM_AddChatAlias(".setdelay", "sm_savedelay");
    PM_AddChatAlias(".savedelay", "sm_savedelay");

    RegConsoleCmd("sm_clearthrow", Command_ClearThrow);
    PM_AddChatAlias(".clearthrow", "sm_clearthrow");

    RegConsoleCmd("sm_adddescription", Command_GrenadeDescription);
    PM_AddChatAlias(".desc", "sm_adddescription");

    RegConsoleCmd("sm_deletegrenade", Command_DeleteGrenade);
    PM_AddChatAlias(".delete", "sm_deletegrenade");

    RegConsoleCmd("sm_categories", Command_Categories);

    RegConsoleCmd("sm_addcategory", Command_AddCategory);
    PM_AddChatAlias(".category", "sm_addcategory");
    PM_AddChatAlias(".cat", "sm_addcategory");
    PM_AddChatAlias(".cats", "sm_categories");
    PM_AddChatAlias(".addcategory", "sm_addcategory");
    PM_AddChatAlias(".addcat", "sm_addcategory");

    RegConsoleCmd("sm_addcategories", Command_AddCategories);
    PM_AddChatAlias(".addcats", "sm_addcategories");

    RegConsoleCmd("sm_removecategory", Command_RemoveCategory);
    PM_AddChatAlias(".removecategory", "sm_removecategory");
    PM_AddChatAlias(".removecat", "sm_removecategory");

    RegConsoleCmd("sm_deletecategory", Command_DeleteCategory);
    PM_AddChatAlias(".deletecat", "sm_deletecategory");

    RegConsoleCmd("sm_clearcategories", Command_ClearGrenadeCategories);
    PM_AddChatAlias(".clearcats", "sm_clearcategories");

    RegConsoleCmd("sm_copygrenade", Command_CopyGrenade);
    PM_AddChatAlias(".copy", "sm_copygrenade");

    RegConsoleCmd("sm_respawn", Command_Respawn);
    PM_AddChatAlias(".respawn", "sm_respawn");

    RegConsoleCmd("sm_stoprespawn", Command_Respawn);
    PM_AddChatAlias(".stoprespawn", "sm_stoprespawn");

    RegConsoleCmd("sm_spec", Command_Spec);
    PM_AddChatAlias(".spec", "sm_spec");

    RegConsoleCmd("sm_joint", Command_JoinT);
    PM_AddChatAlias(".t", "sm_joint");

    RegConsoleCmd("sm_joinct", Command_JoinCT);
    PM_AddChatAlias(".ct", "sm_joinct");
  }

  // Other commands
  {
    RegConsoleCmd("sm_testflash", Command_TestFlash);

    PM_AddChatAlias(".flash", "sm_testflash");
    PM_AddChatAlias(".testflash", "sm_testflash");
    PM_AddChatAlias(".startflash", "sm_testflash");

    RegConsoleCmd("sm_stopflash", Command_StopFlash);
    PM_AddChatAlias(".endflash", "sm_stopflash");
    PM_AddChatAlias(".stopflash", "sm_stopflash");

    RegConsoleCmd("sm_noflash", Command_NoFlash);
    PM_AddChatAlias(".noflash", "sm_noflash");

    RegConsoleCmd("sm_time", Command_Time);
    PM_AddChatAlias(".timer", "sm_time");
    PM_AddChatAlias(".time", "sm_time");

    RegConsoleCmd("sm_time2", Command_Time2);
    PM_AddChatAlias(".timer2", "sm_time2");

    RegConsoleCmd("sm_fastforward", Command_FastForward);
    PM_AddChatAlias(".fastforward", "sm_fastforward");
    PM_AddChatAlias(".fast", "sm_fastforward");
    PM_AddChatAlias(".ff", "sm_fastforward");

    RegConsoleCmd("sm_pmsettings", Command_Settings);
    PM_AddChatAlias(".settings", "sm_pmsettings");

    RegConsoleCmd("sm_repeat", Command_Repeat);
    PM_AddChatAlias(".repeat", "sm_repeat");

    RegConsoleCmd("sm_stoprepeat", Command_StopRepeat);
    PM_AddChatAlias(".stoprepeat", "sm_stoprepeat");

    RegConsoleCmd("sm_delay", Command_Delay);
    PM_AddChatAlias(".delay", "sm_delay");

    RegConsoleCmd("sm_stopall", Command_StopAll);
    PM_AddChatAlias(".stop", "sm_stopall");

    RegConsoleCmd("sm_roundrepeat", Command_RoundRepeat);
    PM_AddChatAlias(".roundrepeat", "sm_roundrepeat");
    PM_AddChatAlias(".rrepeat", "sm_roundrepeat");

    RegConsoleCmd("sm_dryrun", Command_DryRun);
    PM_AddChatAlias(".dry", "sm_dryrun");
    PM_AddChatAlias(".dryrun", "sm_dryrun");

    RegConsoleCmd("sm_enablesetting", Command_Enable);
    PM_AddChatAlias(".enable", "sm_enablesetting");

    RegConsoleCmd("sm_disablesetting", Command_Disable);
    PM_AddChatAlias(".disable", "sm_disablesetting");

    RegConsoleCmd("sm_god", Command_God);
    PM_AddChatAlias(".god", "sm_god");

    RegConsoleCmd("sm_endround", Command_EndRound);
    PM_AddChatAlias(".endround", "sm_endround");

    RegConsoleCmd("sm_break", Command_Break);
    PM_AddChatAlias(".break", "sm_break");
  }

  // New Plugin cvars
  g_AlphabetizeNadeMenusCvar = CreateConVar("sm_practicemode_alphabetize_nades", "0",
                                            "Whether menus of grenades are alphabetized by name.");
  g_BotRespawnTimeCvar = CreateConVar("sm_practicemode_bot_respawn_time", "3.0",
                                      "How long it should take bots placed with .bot to respawn");
  g_AutostartCvar = CreateConVar("sm_practicemode_autostart", "0",
                                 "Whether the plugin is automatically started on mapstart");
  g_DryRunFreezeTimeCvar = CreateConVar("sm_practicemode_dry_run_freeze_time", "6",
                                        "Freezetime after running the .dryrun command.");
  g_MaxHistorySizeCvar =
      CreateConVar("sm_practicemode_max_grenade_history_size", "50000",
                   "Maximum number of grenades throws saved in history per-client");
  g_MaxGrenadesSavedCvar = CreateConVar("sm_practicemode_max_grenades_saved", "512",
                                        "Maximum number of grenades saved per-map per-client");
  g_PracModeCanBeStartedCvar =
      CreateConVar("sm_practicemode_can_be_started", "1", "Whether practicemode may be started");
  g_SharedAllNadesCvar = CreateConVar(
      "sm_practicemode_share_all_nades", "0",
      "When set to 1, grenades aren't per-user; they are shared amongst all users that have grenade access. Grenades are not displayed by user, but displayed in 1 grouping. Anyone on the server can edit other users' grenades.");

  g_FlashEffectiveThresholdCvar =
      CreateConVar("sm_practicemode_flash_effective_threshold", "2.0",
                   "How many seconds a flash must last to be considered effective");
  g_TestFlashTeleportDelayCvar =
      CreateConVar("sm_practicemode_test_flash_delay", "0.3",
                   "Seconds to wait before teleporting a player using .flash");

  g_FastfowardRequiresZeroVolumeCvar = CreateConVar(
      "sm_practicemode_fastforward_requires_zero_volume", "1",
      "Whether all players must have a very low volume to allow the .ff command to be used.");

  g_VersionCvar = CreateConVar("sm_practicemode_version", PLUGIN_VERSION,
                               "Current practicemode version", FCVAR_NOTIFY | FCVAR_DONTRECORD);
  g_VersionCvar.SetString(PLUGIN_VERSION);

  AutoExecConfig(true, "practicemode");

  // New cvars we don't want saved in the autoexec'd file
  g_InfiniteMoneyCvar = CreateConVar("sm_infinite_money", "0",
                                     "Whether clients recieve infinite money", FCVAR_DONTRECORD);
  g_AllowNoclipCvar =
      CreateConVar("sm_allow_noclip", "0",
                   "Whether players may use .noclip in chat to toggle noclip", FCVAR_DONTRECORD);

  g_PatchGrenadeTrajectoryCvar =
      CreateConVar("sm_patch_grenade_trajectory_cvar", "1",
                   "Whether the plugin patches sv_grenade_trajectory with its own grenade trails");
  g_GrenadeTrajectoryClientColorCvar =
      CreateConVar("sm_grenade_trajectory_use_player_color", "0",
                   "Whether to use client colors when drawing grenade trajectories");
  g_RandomGrenadeTrajectoryCvar =
      CreateConVar("sm_grenade_trajectory_random_color", "0",
                   "Whether to randomize all grenade trajectory colors");

  // Patched builtin cvars
  g_GrenadeTrajectoryCvar = GetCvar("sv_grenade_trajectory");
  g_GrenadeThicknessCvar = GetCvar("sv_grenade_trajectory_thickness");
  g_GrenadeTimeCvar = GetCvar("sv_grenade_trajectory_time");
  g_GrenadeSpecTimeCvar = GetCvar("sv_grenade_trajectory_time_spectator");

  // Set default client cvars
  for (int i = 0; i <= MAXPLAYERS; i++) {
    g_ClientColors[i][0] = 0;
    g_ClientColors[i][1] = 255;
    g_ClientColors[i][2] = 0;
    g_ClientColors[i][3] = 255;
    g_ClientVolume[i] = 1.0;
  }

  g_CTSpawns = new ArrayList();
  g_TSpawns = new ArrayList();
  g_KnownNadeCategories = new ArrayList(GRENADE_CATEGORY_LENGTH);

  // Create client cookies.
  RegisterUserSetting(UserSetting_ShowAirtime, "practicemode_grenade_airtime", true,
                      "Show grenade airtime");
  RegisterUserSetting(UserSetting_LeaveNadeMenuOpen, "practicemode_leave_menu_open", false,
                      "Leave .nades menu open after selection");
  RegisterUserSetting(UserSetting_NoGrenadeTrajectory, "practicemode_no_traject", false,
                      "Disable grenade trajectories");
  RegisterUserSetting(UserSetting_SwitchToNadeOnSelect, "practicemode_use_ade", true,
                      "Switch to nade on .nades select");
  RegisterUserSetting(UserSetting_StopsRecordingInspectKey, "practicemode_stop_inspect", true,
                      "Stop bot recording on inspect command");

  // Remove cheats so sv_cheats isn't required for this:
  RemoveCvarFlag(g_GrenadeTrajectoryCvar, FCVAR_CHEAT);

  HookEvent("server_cvar", Event_CvarChanged, EventHookMode_Pre);
  HookEvent("player_spawn", Event_PlayerSpawn);
  HookEvent("player_hurt", Event_BotDamageDealtEvent, EventHookMode_Pre);
  HookEvent("player_hurt", Event_ReplayBotDamageDealtEvent, EventHookMode_Pre);
  HookEvent("player_death", Event_PlayerDeath);
  HookEvent("round_freeze_end", Event_FreezeEnd);

  g_PugsetupLoaded = LibraryExists("pugsetup");
  g_CSUtilsLoaded = LibraryExists("csutils");

  CreateTimer(1.0, Timer_GivePlayersMoney, _, TIMER_REPEAT);
  CreateTimer(0.1, Timer_RespawnBots, _, TIMER_REPEAT);
  CreateTimer(1.0, Timer_CleanupLivingBots, _, TIMER_REPEAT);
  CreateTimer(1.0, Timer_UpdateClientCvars, _, TIMER_REPEAT);
}

public void OnPluginEnd() {
  OnMapEnd();
}

public void OnLibraryAdded(const char[] name) {
  g_PugsetupLoaded = LibraryExists("pugsetup");
  g_CSUtilsLoaded = LibraryExists("csutils");
  g_BotMimicLoaded = LibraryExists("botmimic");
  if (LibraryExists("updater")) {
    Updater_AddPlugin(UPDATE_URL);
  }
}

public void OnLibraryRemoved(const char[] name) {
  g_PugsetupLoaded = LibraryExists("pugsetup");
  g_CSUtilsLoaded = LibraryExists("csutils");
  g_BotMimicLoaded = LibraryExists("botmimic");
}

/**
 * Silences all cvar changes in practice mode.
 */
public Action Event_CvarChanged(Event event, const char[] name, bool dontBroadcast) {
  if (g_InPracticeMode) {
    event.BroadcastDisabled = true;
  }
  return Plugin_Continue;
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
  CheckAutoStart();
  if (!g_InPracticeMode) {
    return Plugin_Continue;
  }

  int client = GetClientOfUserId(event.GetInt("userid"));
  if (IsPlayer(client) && g_SavedRespawnActive[client]) {
    TeleportEntity(client, g_SavedRespawnOrigin[client], g_SavedRespawnAngles[client], NULL_VECTOR);
  }
  if (IsPMBot(client)) {
    GiveBotParams(client);
  }

  // TODO: move this elsewhere and save it properly.
  if (g_InBotReplayMode && g_BotMimicLoaded && IsReplayBot(client)) {
    Client_SetArmor(client, 100);
    SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), true);
  }

  return Plugin_Continue;
}

public void OnClientConnected(int client) {
  g_CurrentSavedGrenadeId[client] = -1;
  g_GrenadeHistoryIndex[client] = -1;
  ClearArray(g_GrenadeHistoryPositions[client]);
  ClearArray(g_GrenadeHistoryAngles[client]);
  ClearArray(g_ClientGrenadeThrowTimes[client]);
  g_TestingFlash[client] = false;
  g_ClientNoFlash[client] = false;
  g_RunningTimeCommand[client] = false;
  g_RunningLiveTimeCommand[client] = false;
  g_SavedRespawnActive[client] = false;
  g_LastGrenadeType[client] = GrenadeType_None;
  g_RunningRepeatedCommand[client] = false;
  g_RunningRoundRepeatedCommandDelay[client].Clear();
  g_RunningRoundRepeatedCommandArg[client].Clear();
  CheckAutoStart();
}

public void OnMapStart() {
  ReadPracticeSettings();
  g_BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
  g_KnownNadeCategories.Clear();

  EnforceDirectoryExists("data/practicemode");
  EnforceDirectoryExists("data/practicemode/bots");
  EnforceDirectoryExists("data/practicemode/bots/backups");
  EnforceDirectoryExists("data/practicemode/grenades");
  EnforceDirectoryExists("data/practicemode/grenades/backups");
  EnforceDirectoryExists("data/practicemode/spawns");
  EnforceDirectoryExists("data/practicemode/spawns/backups");
  EnforceDirectoryExists("data/practicemode/replays");
  EnforceDirectoryExists("data/practicemode/replays/backups");

  // This supports backwards compatability for grenades saved in the old location
  // data/practicemode_grenades. The data is transferred to the new
  // location if they are read from the legacy location.
  char legacyDir[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, legacyDir, sizeof(legacyDir), "data/practicemode_grenades");

  char map[PLATFORM_MAX_PATH];
  GetCleanMapName(map, sizeof(map));

  char legacyFile[PLATFORM_MAX_PATH];
  Format(legacyFile, sizeof(legacyFile), "%s/%s.cfg", legacyDir, map);

  BuildPath(Path_SM, g_GrenadeLocationsFile, sizeof(g_GrenadeLocationsFile),
            "data/practicemode/grenades/%s.cfg", map);

  if (!FileExists(g_GrenadeLocationsFile) && FileExists(legacyFile)) {
    LogMessage("Moving legacy grenade data from %s to %s", legacyFile, g_GrenadeLocationsFile);
    g_GrenadeLocationsKv = new KeyValues("Grenades");
    g_GrenadeLocationsKv.ImportFromFile(legacyFile);
    g_UpdatedGrenadeKv = true;
  } else {
    g_GrenadeLocationsKv = new KeyValues("Grenades");
    g_GrenadeLocationsKv.ImportFromFile(g_GrenadeLocationsFile);
    g_UpdatedGrenadeKv = false;
  }

  MaybeCorrectGrenadeIds();

  FindGrenadeCategories();
  Spawns_MapStart();
  BotReplay_MapStart();
}

public void OnConfigsExecuted() {
  // Disable legacy plugin if found.
  char legacyPluginFile[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, legacyPluginFile, sizeof(legacyPluginFile),
            "plugins/pugsetup_practicemode.smx");
  if (FileExists(legacyPluginFile)) {
    char disabledLegacyPluginName[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, disabledLegacyPluginName, sizeof(disabledLegacyPluginName),
              "plugins/disabled/pugsetup_practicemode.smx");
    ServerCommand("sm plugins unload pugsetup_practicemode");
    if (FileExists(disabledLegacyPluginName))
      DeleteFile(disabledLegacyPluginName);
    RenameFile(disabledLegacyPluginName, legacyPluginFile);
    LogMessage("%s was unloaded and moved to %s", legacyPluginFile, disabledLegacyPluginName);
  }

  CheckAutoStart();
}

public void CheckAutoStart() {
  // Autostart practicemode if enabled.
  if (g_AutostartCvar.IntValue != 0 && !g_InPracticeMode) {
    bool pugsetup_live = g_PugsetupLoaded && PugSetup_GetGameState() != GameState_None;
    if (!pugsetup_live) {
      LaunchPracticeMode();
    }
  }
}

public void OnClientDisconnect(int client) {
  MaybeWriteNewGrenadeData();

  if (g_InPracticeMode) {
    KickAllClientBots(client);
  }

  g_IsPMBot[client] = false;

  // If the server empties out, exit practice mode.
  int playerCount = 0;
  for (int i = 0; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      playerCount++;
    }
  }
  if (playerCount == 0 && g_InPracticeMode) {
    ExitPracticeMode();
  }
}

public void OnMapEnd() {
  MaybeWriteNewGrenadeData();

  if (g_InPracticeMode) {
    ExitPracticeMode();
  }

  Spawns_MapEnd();
  BotReplay_MapEnd();
  delete g_GrenadeLocationsKv;
}

static void MaybeWriteNewGrenadeData() {
  if (g_UpdatedGrenadeKv) {
    g_GrenadeLocationsKv.Rewind();
    BackupFiles("grenades");
    DeleteFile(g_GrenadeLocationsFile);
    if (!g_GrenadeLocationsKv.ExportToFile(g_GrenadeLocationsFile)) {
      LogError("Failed to write grenade data to %s", g_GrenadeLocationsFile);
    }
    g_UpdatedGrenadeKv = false;
  }
}

public void OnClientSettingsChanged(int client) {
  UpdateClientCvars(client);
}

public void OnClientPutInServer(int client) {
  UpdateClientCvars(client);
}

static void UpdateClientCvars(int client) {
  if (!g_InPracticeMode) {
    return;
  }

  QueryClientConVar(client, "cl_color", QueryClientColor, client);
  QueryClientConVar(client, "volume", QueryClientVolume, client);
}

public void QueryClientColor(QueryCookie cookie, int client, ConVarQueryResult result,
                      const char[] cvarName, const char[] cvarValue) {
  int color = StringToInt(cvarValue);
  GetColor(view_as<ClientColor>(color), g_ClientColors[client]);
}

public void QueryClientVolume(QueryCookie cookie, int client, ConVarQueryResult result,
                       const char[] cvarName, const char[] cvarValue) {
  g_ClientVolume[client] = StringToFloat(cvarValue);
}

public void GetColor(ClientColor c, int array[4]) {
  int r, g, b;
  switch (c) {
    case ClientColor_Yellow: {
      r = 229;
      g = 224;
      b = 44;
    }
    case ClientColor_Purple: {
      r = 150;
      g = 45;
      b = 225;
    }
    case ClientColor_Green: {
      r = 23;
      g = 255;
      b = 102;
    }
    case ClientColor_Blue: {
      r = 112;
      g = 191;
      b = 255;
    }
    case ClientColor_Orange: {
      r = 227;
      g = 152;
      b = 33;
    }
    default: {
      r = 23;
      g = 255;
      b = 102;
    }
  }
  array[0] = r;
  array[1] = g;
  array[2] = b;
  array[3] = 255;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3],
                      int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed,
                      int mouse[2]) {
  if (!g_InPracticeMode) {
    return Plugin_Continue;
  }

  if (IsPMBot(client)) {
    if (g_BotCrouching[client]) {
      buttons |= IN_DUCK;
    } else {
      buttons &= ~IN_DUCK;
    }
    return Plugin_Continue;
  }

  if (!IsPlayer(client)) {
    return Plugin_Continue;
  }

  bool moving = MovingButtons(buttons);
  if (g_RunningTimeCommand[client] && g_TimerType[client] == TimerType_Movement) {
    if (g_RunningLiveTimeCommand[client]) {
      // The movement timer is already running; stop it.
      if (!moving && GetEntityFlags(client) & FL_ONGROUND) {
        g_RunningTimeCommand[client] = false;
        g_RunningLiveTimeCommand[client] = false;
        StopClientTimer(client);
      }
    } else {
      //  We're pending a movement timer start.
      if (moving) {
        g_RunningLiveTimeCommand[client] = true;
        StartClientTimer(client);
      }
    }
  }

  return Plugin_Continue;
}

static bool MovingButtons(int buttons) {
  return buttons & IN_FORWARD != 0 || buttons & IN_MOVELEFT != 0 || buttons & IN_MOVERIGHT != 0 ||
         buttons & IN_BACK != 0;
}

public Action Command_TeamJoin(int client, const char[] command, int argc) {
  if (!IsValidClient(client) || argc < 1)
    return Plugin_Handled;

  if (g_InPracticeMode) {
    char arg[4];
    GetCmdArg(1, arg, sizeof(arg));
    int team = StringToInt(arg);
    SwitchPlayerTeam(client, team);

    // Since we force respawns off during bot replay, make teamswitches respawn players.
    if (g_InBotReplayMode && team != CS_TEAM_SPECTATOR && team != CS_TEAM_NONE) {
      CS_RespawnPlayer(client);
    }

    return Plugin_Handled;
  }

  return Plugin_Continue;
}

public Action Command_Noclip(int client, const char[] command, int argc) {
  PerformNoclipAction(client);
  return Plugin_Handled;
}

public Action Command_SetPos(int client, const char[] command, int argc) {
  SetEntityMoveType(client, MOVETYPE_WALK);
  return Plugin_Continue;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] text) {
  if (g_AllowNoclipCvar.IntValue != 0 && StrEqual(text, ".noclip") && IsPlayer(client)) {
    PerformNoclipAction(client);
  }
}

public void PerformNoclipAction(int client) {
  // The move type is also set on the next frame. This is a dirty trick to deal
  // with clients that have a double-bind of "noclip; say .noclip" to work on both
  // ESEA-practice and local sv_cheats servers. Since this plugin can have both enabled
  // (sv_cheats and allow noclip), this double bind would cause the noclip type to be toggled twice.
  // Therefore the fix is to only perform 1 noclip action per-frame per-client at most, implemented
  // by saving the frame count of each use in g_LastNoclipCommand.
  if (g_LastNoclipCommand[client] == GetGameTickCount() ||
      (g_AllowNoclipCvar.IntValue == 0 && GetCvarIntSafe("sv_cheats") == 0)) {
    return;
  }

  // Stop recording if we are.
  if (g_BotMimicLoaded && g_InBotReplayMode) {
    FinishRecording(client, false);
  }

  g_LastNoclipCommand[client] = GetGameTickCount();
  MoveType t = GetEntityMoveType(client);
  MoveType next = (t == MOVETYPE_WALK) ? MOVETYPE_NOCLIP : MOVETYPE_WALK;
  SetEntityMoveType(client, next);

  if (next == MOVETYPE_WALK) {
    SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
  } else {
    SetEntProp(client, Prop_Data, "m_CollisionGroup", 0);
  }
}

public void ReadPracticeSettings() {
  ClearArray(g_BinaryOptionIds);
  ClearArray(g_BinaryOptionNames);
  ClearArray(g_BinaryOptionEnabled);
  ClearArray(g_BinaryOptionChangeable);
  ClearNestedArray(g_BinaryOptionEnabledCvars);
  ClearNestedArray(g_BinaryOptionEnabledValues);
  ClearNestedArray(g_BinaryOptionDisabledCvars);
  ClearNestedArray(g_BinaryOptionDisabledValues);
  ClearArray(g_BinaryOptionCvarRestore);
  ClearArray(g_MapList);

  char filePath[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, filePath, sizeof(filePath), "configs/practicemode.cfg");

  KeyValues kv = new KeyValues("practice_settings");
  if (!kv.ImportFromFile(filePath)) {
    LogError("Failed to import keyvalue from practice config file \"%s\"", filePath);
    delete kv;
    return;
  }

  // Read in the binary options
  if (kv.JumpToKey("binary_options")) {
    if (kv.GotoFirstSubKey()) {
      // read each option
      do {
        char id[128];
        kv.GetSectionName(id, sizeof(id));

        char name[OPTION_NAME_LENGTH];
        kv.GetString("name", name, sizeof(name));

        char enabledString[64];
        kv.GetString("default", enabledString, sizeof(enabledString), "enabled");
        bool enabled =
            StrEqual(enabledString, "enabled", false) || StrEqual(enabledString, "enable", false);

        bool changeable = (kv.GetNum("changeable", 1) != 0);

        // read the enabled cvar list
        ArrayList enabledCvars = new ArrayList(CVAR_NAME_LENGTH);
        ArrayList enabledValues = new ArrayList(CVAR_VALUE_LENGTH);
        if (kv.JumpToKey("enabled")) {
          ReadCvarKv(kv, enabledCvars, enabledValues);
          kv.GoBack();
        }

        ArrayList disabledCvars = new ArrayList(CVAR_NAME_LENGTH);
        ArrayList disabledValues = new ArrayList(CVAR_VALUE_LENGTH);
        if (kv.JumpToKey("disabled")) {
          ReadCvarKv(kv, disabledCvars, disabledValues);
          kv.GoBack();
        }

        PM_AddSetting(id, name, enabledCvars, enabledValues, enabled, changeable, disabledCvars,
                      disabledValues);

      } while (kv.GotoNextKey());
    }
  }
  kv.Rewind();

  char map[PLATFORM_MAX_PATH + 1];
  if (kv.JumpToKey("maps")) {
    if (kv.GotoFirstSubKey(false)) {
      do {
        kv.GetSectionName(map, sizeof(map));
        g_MapList.PushString(map);
      } while (kv.GotoNextKey(false));
    }
    kv.GoBack();
  }
  if (g_MapList.Length == 0) {
    g_MapList.PushString("de_cache");
    g_MapList.PushString("de_cbble");
    g_MapList.PushString("de_dust2");
    g_MapList.PushString("de_inferno");
    g_MapList.PushString("de_mirage");
    g_MapList.PushString("de_nuke");
    g_MapList.PushString("de_overpass");
    g_MapList.PushString("de_train");
  }

  Call_StartForward(g_OnPracticeModeSettingsRead);
  Call_Finish();

  delete kv;
}

public void LaunchPracticeMode() {
  ServerCommand("exec sourcemod/practicemode_start.cfg");

  g_InPracticeMode = true;
  ReadPracticeSettings();
  for (int i = 0; i < g_BinaryOptionNames.Length; i++) {
    ChangeSetting(i, PM_IsSettingEnabled(i), false, true);
  }

  PM_MessageToAll("Practice mode is now enabled.");
  Call_StartForward(g_OnPracticeModeEnabled);
  Call_Finish();
}

stock bool ChangeSetting(int index, bool enabled, bool print = true, bool force_setting = false) {
  bool previousSetting = g_BinaryOptionEnabled.Get(index);
  if (enabled == previousSetting && !force_setting) {
    return false;
  }

  g_BinaryOptionEnabled.Set(index, enabled);

  if (enabled) {
    ArrayList cvars = g_BinaryOptionEnabledCvars.Get(index);
    ArrayList values = g_BinaryOptionEnabledValues.Get(index);
    g_BinaryOptionCvarRestore.Set(index, SaveCvars(cvars));
    ExecuteCvarLists(cvars, values);
  } else {
    ArrayList cvars = g_BinaryOptionDisabledCvars.Get(index);
    ArrayList values = g_BinaryOptionDisabledValues.Get(index);

    if (cvars != null && cvars.Length > 0 && values != null && values.Length == cvars.Length) {
      // If there are are disabled cvars explicity set.
      ExecuteCvarLists(cvars, values);
    } else {
      // If there are no "disabled" cvars explicity set, we'll just restore to the cvar
      // values before the option was enabled.
      Handle cvarRestore = g_BinaryOptionCvarRestore.Get(index);
      if (cvarRestore != INVALID_HANDLE) {
        RestoreCvars(cvarRestore, true);
        g_BinaryOptionCvarRestore.Set(index, INVALID_HANDLE);
      }
    }
  }

  char id[OPTION_NAME_LENGTH];
  char name[OPTION_NAME_LENGTH];
  g_BinaryOptionIds.GetString(index, id, sizeof(id));
  g_BinaryOptionNames.GetString(index, name, sizeof(name));

  if (print) {
    char enabledString[32];
    GetEnabledString(enabledString, sizeof(enabledString), enabled);
    if (!StrEqual(name, "")) {
      PM_MessageToAll("%s is now %s.", name, enabledString);
    }
  }

  Call_StartForward(g_OnPracticeModeSettingChanged);
  Call_PushCell(index);
  Call_PushString(id);
  Call_PushString(name);
  Call_PushCell(enabled);
  Call_Finish();

  return true;
}

public void ExitPracticeMode() {
  if (!g_InPracticeMode) {
    return;
  }

  Call_StartForward(g_OnPracticeModeDisabled);
  Call_Finish();

  for (int i = 1; i <= MaxClients; i++) {
    if (IsClientInGame(i) && IsFakeClient(i) && g_IsPMBot[i]) {
      KickClient(i);
      g_IsPMBot[i] = false;
    }
  }

  for (int i = 0; i < g_BinaryOptionNames.Length; i++) {
    ChangeSetting(i, false, false);

    // Restore the cvar values if they haven't already been.
    Handle cvarRestore = g_BinaryOptionCvarRestore.Get(i);
    if (cvarRestore != INVALID_HANDLE) {
      RestoreCvars(cvarRestore, true);
      g_BinaryOptionCvarRestore.Set(i, INVALID_HANDLE);
    }
  }

  g_InPracticeMode = false;

  // force turn noclip off for everyone
  for (int i = 1; i <= MaxClients; i++) {
    g_TestingFlash[i] = false;
    if (IsValidClient(i)) {
      SetEntityMoveType(i, MOVETYPE_WALK);
    }
  }

  ServerCommand("exec sourcemod/practicemode_end.cfg");
  PM_MessageToAll("Practice mode is now disabled.");
}

public Action Timer_GivePlayersMoney(Handle timer) {
  int maxMoney = GetCvarIntSafe("mp_maxmoney", 16000);
  if (g_InfiniteMoneyCvar.IntValue != 0) {
    for (int i = 1; i <= MaxClients; i++) {
      if (IsPlayer(i)) {
        SetEntProp(i, Prop_Send, "m_iAccount", maxMoney);
      }
    }
  }

  return Plugin_Continue;
}

public Action Timer_UpdateClientCvars(Handle timer) {
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      UpdateClientCvars(i);
    }
  }
  return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] className) {
  if (!IsValidEntity(entity)) {
    return;
  }

  SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawned);
}

// We artifically delay the work here in OnEntitySpawned because the csutils
// plugin will spawn grenades and set the owner on spawn, and we want to be sure
// the owner is set by the time practicemode gets to the grenade.
public int OnEntitySpawned(int entity) {
  RequestFrame(DelayedOnEntitySpawned, entity);
}

public int DelayedOnEntitySpawned(int entity) {
  if (!IsValidEdict(entity)) {
    return;
  }

  char className[CLASS_LENGTH];
  GetEdictClassname(entity, className, sizeof(className));

  if (IsGrenadeProjectile(className)) {
    // Get the cl_color value for the client that threw this grenade.
    int client = Entity_GetOwner(entity);
    if (IsPlayer(client) && g_InPracticeMode &&
        GrenadeFromProjectileName(className) == GrenadeType_Smoke) {
      int index = g_ClientGrenadeThrowTimes[client].Push(EntIndexToEntRef(entity));
      g_ClientGrenadeThrowTimes[client].Set(index, view_as<int>(GetEngineTime()), 1);
    }

    if (IsValidEntity(entity)) {
      if (g_GrenadeTrajectoryCvar.IntValue != 0 && g_PatchGrenadeTrajectoryCvar.IntValue != 0) {
        // Send a temp ent beam that follows the grenade entity to all other clients.
        for (int i = 1; i <= MaxClients; i++) {
          if (!IsClientConnected(i) || !IsClientInGame(i)) {
            continue;
          }

          if (GetSetting(client, UserSetting_NoGrenadeTrajectory)) {
            continue;
          }

          // Note: the technique using temporary entities is taken from InternetBully's NadeTails
          // plugin which you can find at https://forums.alliedmods.net/showthread.php?t=240668
          float time = (GetClientTeam(i) == CS_TEAM_SPECTATOR) ? g_GrenadeSpecTimeCvar.FloatValue
                                                               : g_GrenadeTimeCvar.FloatValue;

          int colors[4];
          if (g_RandomGrenadeTrajectoryCvar.IntValue > 0) {
            colors[0] = GetRandomInt(0, 255);
            colors[1] = GetRandomInt(0, 255);
            colors[2] = GetRandomInt(0, 255);
            colors[3] = 255;
          } else if (g_GrenadeTrajectoryClientColorCvar.IntValue > 0 && IsPlayer(client)) {
            colors = g_ClientColors[client];
          } else {
            colors = g_ClientColors[0];
          }

          TE_SetupBeamFollow(entity, g_BeamSprite, 0, time, g_GrenadeThicknessCvar.FloatValue * 5,
                             g_GrenadeThicknessCvar.FloatValue * 5, 1, colors);
          TE_SendToClient(i);
        }
      }

      // If the user recently indicated they are testing a flash (.flash),
      // teleport to that spot.
      if (GrenadeFromProjectileName(className) == GrenadeType_Flash && g_TestingFlash[client]) {
        float delay = g_TestFlashTeleportDelayCvar.FloatValue;
        if (delay <= 0.0) {
          delay = 0.1;
        }

        CreateTimer(delay, Timer_TeleportClient, GetClientSerial(client));
      }
    }
  }
}

public Action Timer_TeleportClient(Handle timer, int serial) {
  int client = GetClientFromSerial(serial);
  if (g_InPracticeMode && IsPlayer(client) && g_TestingFlash[client]) {
    float velocity[3];
    TeleportEntity(client, g_TestingFlashOrigins[client], g_TestingFlashAngles[client], velocity);
    SetEntityMoveType(client, MOVETYPE_NONE);
  }
}

public Action Timer_FakeGrenadeBack(Handle timer, int serial) {
  int client = GetClientFromSerial(serial);
  if (g_InPracticeMode && IsPlayer(client)) {
    FakeClientCommand(client, "sm_lastgrenade");
  }
}

public Action Event_WeaponFired(Event event, const char[] name, bool dontBroadcast) {
  if (!g_InPracticeMode) {
    return;
  }

  int userid = event.GetInt("userid");
  int client = GetClientOfUserId(userid);
  char weapon[CLASS_LENGTH];
  event.GetString("weapon", weapon, sizeof(weapon));

  if (IsGrenadeWeapon(weapon) && IsPlayer(client)) {
    AddGrenadeToHistory(client);
  }
}

public Action Event_SmokeDetonate(Event event, const char[] name, bool dontBroadcast) {
  if (!g_InPracticeMode) {
    return;
  }
  GrenadeDetonateTimerHelper(event, "smoke grenade");
}

public void GrenadeDetonateTimerHelper(Event event, const char[] grenadeName) {
  int userid = event.GetInt("userid");
  int client = GetClientOfUserId(userid);
  int entity = event.GetInt("entityid");

  if (IsPlayer(client)) {
    for (int i = 0; i < g_ClientGrenadeThrowTimes[client].Length; i++) {
      int ref = g_ClientGrenadeThrowTimes[client].Get(i, 0);
      if (EntRefToEntIndex(ref) == entity) {
        float dt = GetEngineTime() - view_as<float>(g_ClientGrenadeThrowTimes[client].Get(i, 1));
        g_ClientGrenadeThrowTimes[client].Erase(i);
        if (GetSetting(client, UserSetting_ShowAirtime)) {
          PM_Message(client, "Airtime of %s: %.1f seconds", grenadeName, dt);
        }
        break;
      }
    }
  }
}

public Action Event_FlashDetonate(Event event, const char[] name, bool dontBroadcast) {
  if (!g_InPracticeMode) {
    return;
  }

  int userid = event.GetInt("userid");
  int client = GetClientOfUserId(userid);
  if (IsPlayer(client) && g_TestingFlash[client]) {
    // Get the impact of the flash next frame, since doing it in
    // this frame doesn't work.
    RequestFrame(GetTestingFlashInfo, GetClientSerial(client));
  }

  g_LastFlashDetonateTime[client] = GetGameTime();
}

public void GetTestingFlashInfo(int serial) {
  int client = GetClientFromSerial(serial);
  if (IsPlayer(client) && g_TestingFlash[client]) {
    float flashDuration = GetFlashDuration(client);
    PM_Message(client, "Flash duration: %.1f seconds", flashDuration);

    if (flashDuration < g_FlashEffectiveThresholdCvar.FloatValue) {
      PM_Message(client, "Ineffective flash");
      CreateTimer(1.0, Timer_FakeGrenadeBack, GetClientSerial(client));
    } else {
      float delay = flashDuration - 1.0;
      if (delay <= 0.0)
        delay = 0.1;

      CreateTimer(delay, Timer_FakeGrenadeBack, GetClientSerial(client));
    }
  }
}

public Action Event_FreezeEnd(Event event, const char[] name, bool dontBroadcast) {
  if (!g_InPracticeMode) {
    return Plugin_Handled;
  }

  for (int i = 1; i <= MaxClients; i++) {
    if (!IsPlayer(i)) {
      continue;
    }

    if (g_ClientNoFlash[i]) {
      g_ClientNoFlash[i] = false;
      PM_Message(i, "Disabled noflash on round start.");
    }

    if (GetEntityMoveType(i) == MOVETYPE_NOCLIP) {
      SetEntityMoveType(i, MOVETYPE_WALK);
      PM_Message(i, "Disabled noclip on round start.");
    }

    FreezeEnd_RoundRepeat(i);
  }

  return Plugin_Handled;
}

static bool CheckChatAlias(const char[] alias, const char[] command, const char[] chatCommand,
                           const char[] chatArgs, int client) {
  if (StrEqual(chatCommand, alias, false)) {
    // Get the original cmd reply source so it can be restored after the fake client command.
    // This means and ReplyToCommand will go into the chat area, rather than console, since
    // *chat* aliases are for *chat* commands.
    ReplySource replySource = GetCmdReplySource();
    SetCmdReplySource(SM_REPLY_TO_CHAT);
    char fakeCommand[256];
    Format(fakeCommand, sizeof(fakeCommand), "%s %s", command, chatArgs);
    FakeClientCommand(client, fakeCommand);
    SetCmdReplySource(replySource);
    return true;
  }
  return false;
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs) {
  if (!IsPlayer(client))
    return;

  // splits to find the first word to do a chat alias command check
  char chatCommand[COMMAND_LENGTH];
  char chatArgs[255];
  int index = SplitString(sArgs, " ", chatCommand, sizeof(chatCommand));

  if (index == -1) {
    strcopy(chatCommand, sizeof(chatCommand), sArgs);
  } else if (index < strlen(sArgs)) {
    strcopy(chatArgs, sizeof(chatArgs), sArgs[index]);
  }

  if (chatCommand[0]) {
    char alias[ALIAS_LENGTH];
    char cmd[COMMAND_LENGTH];
    for (int i = 0; i < GetArraySize(g_ChatAliases); i++) {
      g_ChatAliases.GetString(i, alias, sizeof(alias));
      g_ChatAliasesCommands.GetString(i, cmd, sizeof(cmd));

      if (CheckChatAlias(alias, cmd, chatCommand, chatArgs, client)) {
        break;
      }
    }
  }

  if (!g_PugsetupLoaded) {
    if (StrEqual(chatCommand, ".setup")) {
      if (CheckCommandAccess(client, "sm_prac", ADMFLAG_CHANGEMAP)) {
        GivePracticeMenu(client);
      } else {
        PM_Message(client, "You don't have permission to access practicemode.");
      }
    } else if (StrEqual(chatCommand, ".help")) {
      ShowHelpInfo(client);
    }
  }
}

public void ShowHelpInfo(int client) {
  char url[256];
  char version[64];
#if defined COMMIT_STRING_LONG
  Format(version, sizeof(version), COMMIT_STRING_LONG);
#else
  Format(version, sizeof(version), PLUGIN_VERSION);
#endif

  Format(url, sizeof(url), "http://whiffcity.com/redirect_practicemode_help_version/%s", version);
  ShowMOTDPanel(client, "Practicemode Help", url, MOTDPANEL_TYPE_URL);
  QueryClientConVar(client, "cl_disablehtmlmotd", CheckMOTDAllowed, client);
}

public void CheckMOTDAllowed(QueryCookie cookie, int client, ConVarQueryResult result,
                      const char[] cvarName, const char[] cvarValue) {
  if (!StrEqual(cvarValue, "0")) {
    PrintToChat(client, "You must have \x04cl_disablehtmlmotd 0 \x01to use that command.");
  }
}

bool CanStartPracticeMode(int client) {
  if (g_PracModeCanBeStartedCvar.IntValue == 0) {
    return false;
  }
  return CheckCommandAccess(client, "sm_prac", ADMFLAG_CHANGEMAP);
}

public void CSU_OnThrowGrenade(int client, int entity, GrenadeType grenadeType, const float origin[3],
                        const float velocity[3]) {
  g_LastGrenadeType[client] = grenadeType;
  g_LastGrenadeOrigin[client] = origin;
  g_LastGrenadeVelocity[client] = velocity;
  Replays_OnThrowGrenade(client, entity, grenadeType, origin, velocity);
}
