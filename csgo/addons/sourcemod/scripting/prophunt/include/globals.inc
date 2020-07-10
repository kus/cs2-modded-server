
#if defined _globals_included
    #endinput
#endif
#define _globals_included

#define PREFIX              "\x03[PropHunt] \x05"

#define NOT_IN_QUEUE        -1
#define FFADE_STAYOUT       0x0008
#define FFADE_PURGE         0x0010
#define MAP_CONFIG_PATH     "configs/prophunt/maps"
#define WHISTLE_CONFIG_PATH "configs/prophunt/whistles.cfg"
#define MAX_WHISTLES        128
#define MAX_WHISTLE_LENGTH  128

/* cvars ------------------------------------------------- */

Handle cvar_FreezeCTs = INVALID_HANDLE;
Handle cvar_FreezeTime = INVALID_HANDLE;
Handle cvar_ChangeLimit = INVALID_HANDLE;
Handle cvar_ChangeLimittime = INVALID_HANDLE;
Handle cvar_AutoChoose = INVALID_HANDLE;
Handle cvar_Whistle = INVALID_HANDLE;
Handle cvar_WhistleTimes = INVALID_HANDLE;
Handle cvar_WhistleSeeker = INVALID_HANDLE;
Handle cvar_HiderWinFrags = INVALID_HANDLE;
Handle cvar_SlaySeekers = INVALID_HANDLE;
Handle cvar_HPSeekerEnable = INVALID_HANDLE;
Handle cvar_HPSeekerDec = INVALID_HANDLE;
Handle cvar_HPSeekerInc = INVALID_HANDLE;
Handle cvar_HPSeekerIncShotgun = INVALID_HANDLE;
Handle cvar_HPSeekerBonus = INVALID_HANDLE;
Handle cvar_HiderSpeed = INVALID_HANDLE;
Handle cvar_DisableDucking = INVALID_HANDLE;
Handle cvar_AutoThirdPerson = INVALID_HANDLE;
Handle cvar_HiderFreezeMode = INVALID_HANDLE;
Handle cvar_HideBlood = INVALID_HANDLE;
Handle cvar_ShowHelp = INVALID_HANDLE;
Handle cvar_CTRatio = INVALID_HANDLE;
Handle cvar_DisableUse = INVALID_HANDLE;
Handle cvar_HiderFreezeInAir = INVALID_HANDLE;
Handle cvar_HidePlayerLocation = INVALID_HANDLE;
Handle cvar_AutoFreezeTime = INVALID_HANDLE;
Handle cvar_GuaranteedCTTurns = INVALID_HANDLE;
Handle cvar_KnifeSpeed = INVALID_HANDLE;
Handle cvar_LimitSpec = INVALID_HANDLE;
Handle cvar_IncludeDefaultModels = INVALID_HANDLE;
Handle cvar_ForcePeriodicWhistle = INVALID_HANDLE;
Handle cvar_PeriodicWhistleDelay = INVALID_HANDLE;
Handle cvar_TurnsToScramble = INVALID_HANDLE;

/* server cvars ------------------------------------------------- */

char protected_cvars[][] = {
    "mp_flashlight",
    "sv_footsteps",
    "mp_limitteams",
    "mp_autoteambalance",
    "mp_freezetime",
    "sv_nonemesis",
    "sv_nomvp",
    "sv_nostats",
    "mp_playerid",
    "sv_allowminmodels",
    "sv_turbophysics",
    "mp_teams_unbalance_limit",
    "mp_show_voice_icons",
    "spec_freeze_time",
    "mp_default_team_winner_no_objective"
};

int forced_values[sizeof(protected_cvars)] = {
    0, // mp_flashlight
    0, // sv_footsteps
    0, // mp_limitteams
    0, // mp_autoteambalance
    0, // mp_freezetime
    1, // sv_nonemesis
    1, // sv_nomvp
    1, // sv_nostats
    1, // mp_playerid
    0, // sv_allowminmodels
    1, // sv_turbophysics
    0, // mp_teams_unbalance_limit
    0, // mp_show_voice_icons
    -1,// spec_freeze_time
    3, // mp_default_team_winner_no_objective
};

int previous_values[sizeof(protected_cvars)] = {0, ...}; 
Handle g_hProtectedConvar[sizeof(protected_cvars)] = {INVALID_HANDLE, ...}; 
Handle g_hForceCamera = INVALID_HANDLE;

/* timers ------------------------------------------------- */

Handle g_hAutoFreezeTimers[MAXPLAYERS] = {INVALID_HANDLE, ...};
Handle g_hAllowModelChangeTimer[MAXPLAYERS] = {INVALID_HANDLE, ...};
Handle g_hShowCountdownTimer = INVALID_HANDLE;
Handle g_hFreezeCTTimer[MAXPLAYERS] = {INVALID_HANDLE, ...};
Handle g_hRoundTimeTimer = INVALID_HANDLE;
Handle g_hPeriodicWhistleTimer = INVALID_HANDLE;
Handle g_hAfterFreezeTimer = INVALID_HANDLE;
Handle g_hRoundEndTimer = INVALID_HANDLE;

/* team balance ------------------------------------------------- */

int g_iClientTeam[MAXPLAYERS] = {CS_TEAM_SPECTATOR, ...};
int g_iHidersInSeekerQueue = 0;
int g_iGuaranteedCTTurns[MAXPLAYERS] = {-1, ...};
int g_iHiderToSeekerQueue[MAXPLAYERS] = {NOT_IN_QUEUE, ...};
bool g_bClientTeambalanced[MAXPLAYERS];

/* menus ------------------------------------------------- */

Handle g_hModelMenu = INVALID_HANDLE;
KeyValues g_hMenuKV;

/* offsets ------------------------------------------------- */

int g_Freeze;
int g_flLaggedMovementValue;

/* models ------------------------------------------------- */

bool g_bAllowModelChange[MAXPLAYERS] = {true, ...};
bool g_bShowFakeProp[MAXPLAYERS];
int g_iTotalModelsAvailable = 0;
int g_iModelChangeCount[MAXPLAYERS] = {0, ...};
int g_iLowModelSteps[MAXPLAYERS] = {0, ...};

/* sounds ------------------------------------------------- */

ArrayList g_WhistleSounds;
char g_sndFreeze[] = "prophunt/beep.mp3";

/* misc ------------------------------------------------- */

bool g_bRoundEnded = false;
bool g_bInThirdPersonView[MAXPLAYERS] = {false, ...};
bool g_bShotgun[MAXPLAYERS] = {false, ...};
bool g_bFirstSpawn[MAXPLAYERS] = {true, ...};
bool g_bIsCTWaiting[MAXPLAYERS] = {false, ...}; // waiting for round start
int g_iWhistleCount[MAXPLAYERS] = {0, ...};
int g_iPlayerScore[MAXPLAYERS] = {0, ...};
int g_iFirstCTSpawn;
int g_iFirstTSpawn;
int g_iTurnsToScramble;
float g_fSpawnPosition[MAXPLAYERS][3];
Handle g_hWhistleDelay = INVALID_HANDLE;
