new const String:DATE[] = __DATE__;
new const String:TIME[] = __TIME__;

/* PlayerState[client] */
#define KNIFE_ELITE         (1<<0)
#define FIRST_JOIN          (1<<1)
#define GRENADE_LEVEL       (1<<2)

enum Sounds
{
    Welcome,
    Knife,
    Nade,
    Steal,
    Up,
    Down,
    Triple,
    AutoFF,
    MultiKill,
    Winner,
    WarmupTimerSound,
    MaxSounds
}

new String:g_WeaponName[MAX_WEAPONS_COUNT][MAX_WEAPON_NAME_LEN];
new Slots:g_WeaponSlot[MAX_WEAPONS_COUNT];
new g_WeaponAmmo[MAX_WEAPONS_COUNT];
new bool:g_WeaponDropKnife[MAX_WEAPONS_COUNT];
new g_WeaponLevelIndex[MAX_WEAPONS_COUNT];

new String:EventSounds[Sounds:MaxSounds][PLATFORM_MAX_PATH];

/* Default values for weapon order.*/
new WeaponOrderId[GUNGAME_MAX_LEVEL];
new String:WeaponOrderName[GUNGAME_MAX_LEVEL][24];
new WeaponOrderCount;
new RandomWeaponOrderMap[GUNGAME_MAX_LEVEL];
new bool:RandomWeaponOrder;

// ConVar Pointer
new Handle:mp_friendlyfire = INVALID_HANDLE;
new Handle:mp_restartgame = INVALID_HANDLE;
new Handle:gungame_enabled = INVALID_HANDLE;

/* Status forwards */
new Handle:FwdLevelChange = INVALID_HANDLE;
new Handle:FwdWarmupEnd = INVALID_HANDLE;
new Handle:FwdWarmupStart = INVALID_HANDLE;
new Handle:FwdWinner = INVALID_HANDLE;
new Handle:FwdSoundWinner = INVALID_HANDLE;
new Handle:FwdTripleLevel = INVALID_HANDLE;
new Handle:FwdLeader = INVALID_HANDLE;
new Handle:FwdVoteStart = INVALID_HANDLE;
new Handle:FwdDisableRtv = INVALID_HANDLE;
new Handle:FwdDeath = INVALID_HANDLE;
new Handle:FwdPoint = INVALID_HANDLE;
new Handle:FwdStart = INVALID_HANDLE;
new Handle:FwdShutdown = INVALID_HANDLE;

new Handle:WarmupTimer = INVALID_HANDLE;

new bool:IsActive = false;
new bool:IsObjectiveHooked;
new HostageEntInfo;
new Handle:PlayerLevelsBeforeDisconnect = INVALID_HANDLE;
new Handle:g_Timer_HandicapUpdate = INVALID_HANDLE;
new Handle:PlayerHandicapTimes = INVALID_HANDLE;
new bool:g_SkipSpawn[MAXPLAYERS+1] = {false, ...};

new GameName:g_GameName = GameName:None;
new g_WeaponsMaxId              = 0;

new g_WeaponIdKnife             = 0;
new g_WeaponIdHegrenade         = 0;
new g_WeaponIdSmokegrenade      = 0;
new g_WeaponIdFlashbang         = 0;
new g_WeaponIdTaser             = 0;

new g_WeaponLevelIdKnife        = 0;
new g_WeaponLevelIdHegrenade    = 0;
new g_WeaponLevelIdTaser        = 0;
new g_WeaponLevelIdMolotov      = 0;

new g_WeaponAmmoTypeHegrenade       = 0;
new g_WeaponAmmoTypeFlashbang       = 0;
new g_WeaponAmmoTypeSmokegrenade    = 0;
new g_WeaponAmmoTypeMolotov         = 0;
new g_WeaponAmmoTypeTaser           = 0;
new bool:g_BlockFastSwitchOnChange[MAXPLAYERS+1]    = {false, ...};
