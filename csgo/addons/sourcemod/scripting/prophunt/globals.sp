
#define PREFIX "{magenta}[{lime}Prop{yellow}Hunt{darkred}X{magenta}] {yellow}"

bool g_bLoaded;

#define NOT_IN_QUEUE        -1
#define FFADE_STAYOUT       0x0008
#define FFADE_PURGE         0x0010
#define MAP_CONFIG_PATH     "configs/prophunt/maps"

char sProjectiles[] = "decoy_projectile hegrenade_projectile flashbang_projectile smokegrenade_projectile molotov_projectile";

/* Settings */

ConVar g_cvEnabled;

ConVar g_cvHideTime;

ConVar g_cvAutoFreezeTime;
ConVar g_cvBalancer[8][2];

ConVar g_cvWeaponUseHealthDefault;
ConVar g_cvWeaponUseHealth[12] =  { null, ... };
ConVar g_cvWeaponHitHealthDefault;
ConVar g_cvWeaponHitHealth[12] =  { null, ... };
ConVar g_cvWeaponKillHealthDefault;
ConVar g_cvWeaponKillHealth[12] =  { null, ... };

ConVar g_cvSeekerCanKillSelf;
ConVar g_cvSeekerMaxHealth;

ConVar g_cvHiderModels;

ConVar g_cvHiderFreezeFallspeedMax;
ConVar g_cvHiderFreezeHeightMax;
ConVar g_cvHiderFreezeAboveWater;

// Hider Speed

ConVar g_cvHiderSpeedMax;
ConVar g_cvHiderSpeedMaxPriority;

ConVar g_cvHiderSpeedHideTime;
ConVar g_cvHiderSpeedHideTimePriority;
ConVar g_cvHiderSpeedHideTimeMax;
ConVar g_cvHiderSpeedHideTimeMaxPriority;

// Seeker Speed

ConVar g_cvSeekerSpeedBase;
ConVar g_cvSeekerSpeedBasePriority;
ConVar g_cvSeekerSpeedMax;
ConVar g_cvSeekerSpeedMaxPriority;

// Force Taunt + Points

ConVar g_cvTauntForce;
ConVar g_cvTauntForceLastHider;

ConVar g_cvTauntForceCooldownMin;
ConVar g_cvTauntForceCooldownExtra;

ConVar g_cvTauntForceFailedCooldown;

// Taunt Points

ConVar g_cvTauntPointsMin;
ConVar g_cvTauntPointsMax;
ConVar g_cvTauntLengthPointsMin;
ConVar g_cvTauntLengthPointsMax;

// Taunt Cooldown

ConVar g_cvTauntCooldownMin;
ConVar g_cvTauntCooldownExtra;
ConVar g_cvTauntOverloadTime;
ConVar g_cvTauntOverloadWarnTime;
ConVar g_cvTauntOverloadCooldown;

// Shop

ConVar g_cvShopEnable;
ConVar g_cvShopSortMode;

// Shop Hider

ConVar g_cvShopHiderHealPrice;
ConVar g_cvShopHiderHealSort;
ConVar g_cvShopHiderHealUnlockTime;

ConVar g_cvShopHiderMorphPrice;
ConVar g_cvShopHiderMorphSort;
ConVar g_cvShopHiderMorphUnlockTime;

ConVar g_cvShopHiderAirFreezeHeight;
ConVar g_cvShopHiderAirFreezePrice;
ConVar g_cvShopHiderAirFreezeSort;
ConVar g_cvShopHiderAirFreezeUnlockTime;

ConVar g_cvShopHiderSpeedTime;
ConVar g_cvShopHiderSpeedBonus;
ConVar g_cvShopHiderSpeedBonusType;
ConVar g_cvShopHiderSpeedPriority;
ConVar g_cvShopHiderSpeedPrice;
ConVar g_cvShopHiderSpeedSort;
ConVar g_cvShopHiderSpeedUnlockTime;

ConVar g_cvShopHiderGravityMin;
ConVar g_cvShopHiderGravityBonus;
ConVar g_cvShopHiderGravityPrice;
ConVar g_cvShopHiderGravitySort;
ConVar g_cvShopHiderGravityUnlockTime;

// Shop Seeker

ConVar g_cvShopSeekerHealthshotPrice;
ConVar g_cvShopSeekerHealthshotSort;
ConVar g_cvShopSeekerHealthshotUnlockTime;

ConVar g_cvShopSeekerGrenadePrice;
ConVar g_cvShopSeekerGrenadeSort;
ConVar g_cvShopSeekerGrenadeUnlockTime;

ConVar g_cvShopSeekerFiveSevenPrice;
ConVar g_cvShopSeekerFiveSevenSort;
ConVar g_cvShopSeekerFiveSevenUnlockTime;

ConVar g_cvShopSeekerXM1014Price;
ConVar g_cvShopSeekerXM1014Sort;
ConVar g_cvShopSeekerXM1014UnlockTime;

ConVar g_cvShopSeekerMP9Price;
ConVar g_cvShopSeekerMP9Sort;
ConVar g_cvShopSeekerMP9UnlockTime;

ConVar g_cvShopSeekerM4A1Price;
ConVar g_cvShopSeekerM4A1Sort;
ConVar g_cvShopSeekerM4A1UnlockTime;

ConVar g_cvShopSeekerAWPPrice;
ConVar g_cvShopSeekerAWPSort;
ConVar g_cvShopSeekerAWPUnlockTime;

// Points

ConVar g_cvPointsSeekerKill;
ConVar g_cvPointsSeekerSteal;

// HUD

ConVar g_cvHudHelpSeeker;
ConVar g_cvHudHelpHider;
ConVar g_cvHudCountdownHide;
ConVar g_cvHudHidersLeft;
ConVar g_cvHudPoints;
ConVar g_cvHudShopCd;

// Other

ConVar g_cvAlterHurt;
ConVar g_cvInfAmmo;

/* Upgrades */

bool g_bUpgradeFreezeAir[MAXPLAYERS + 1];

/* Forwards */

Handle g_OnFreezeTimeEnd;

Handle g_OnHiderSpawn;
Handle g_OnHiderReady;
Handle g_OnHiderSetModel;
Handle g_OnHiderDeath;

Handle g_OnSeekerSpawn;
Handle g_OnSeekerDeath;

Handle g_OnHiderFreeze;
Handle g_OnHiderUnFreeze;

Handle g_OnOpenTauntMenu;

Handle g_OnTauntPre;
Handle g_OnTaunt;
Handle g_OnForceTauntPre;
Handle g_OnForceTaunt;

Handle g_OnSeekerUseWeapon;
Handle g_OnHiderHit;

Handle g_OnBuildModelMenu;

Handle g_OnBuyShopItem;
Handle g_OnBuyShopItemPost;

/* HUD */

Handle g_hCookieHudMode;
int g_iHudMode[MAXPLAYERS+1];

#define HUD_DISABLED 0
#define HUD_NORMAL 1
#define HUD_HELP 2

/* timers */

Handle g_hAutoFreezeTimers[MAXPLAYERS+1] = {null, ...};
Handle g_hRoundTimeTimer = null;
Handle g_hAfterFreezeTimer = null;
Handle g_hRoundEndTimer = null;
Handle g_hCleanupTimer = null;
Handle g_hCheckTeams = null; // Set if a timer has been started already to check teams delayed

/* menus */

int g_iAdminSelectedMenuMode[MAXPLAYERS + 1] =  { 0, ... };
int g_iAdminSelectedMenuItemSub[MAXPLAYERS + 1] =  { 0, ... };
int g_iAdminSelectedMenuItem[MAXPLAYERS + 1] =  { 0, ... };

Menu g_mModelMenuAdmin = null;
Menu g_mModelMenu[MAXPLAYERS + 1] =  { null, ... };
KeyValues g_kvModels = null;
KeyValues g_kvMapModels = null;
ArrayList g_aMapModels = null;
int g_iMapModelsID;

/* models */

int g_iTotalModelsAvailable = 0;
Handle g_aModelIndex = null;
Handle g_aModelName = null;
Handle g_aModelHP = null;
Handle g_aModelSpeed = null;
Handle g_aModelGravity = null;
bool g_bBlockFakeProp[MAXPLAYERS];
bool g_bShowFakeProp[MAXPLAYERS];
int g_iModelChangeCount[MAXPLAYERS] = {0, ...};
int g_iLowModelSteps[MAXPLAYERS] = {0, ...};

/* models proberties */

int m_iIndex[MAXPLAYERS+1];
char m_sName[MAXPLAYERS+1][255];
char m_sModel[MAXPLAYERS+1][PLATFORM_MAX_PATH];
float m_fOffset[MAXPLAYERS+1][3];
float m_fAngle[MAXPLAYERS+1][3];
int m_iColor[MAXPLAYERS+1][4];

int m_iSkin[MAXPLAYERS+1];
int m_iWeight[MAXPLAYERS+1];
int m_iHP[MAXPLAYERS+1];
float m_fSpeed[MAXPLAYERS+1];
float m_fGravity[MAXPLAYERS+1];

float m_fFreezeAngle[MAXPLAYERS+1][3];

/* Other */

bool g_bIsPlayerDead[MAXPLAYERS] = {false, ...};
bool g_bInThirdPersonView[MAXPLAYERS] = {false, ...};
int g_iWeapontype[MAXPLAYERS] = {false, ...};
bool g_bFirstSpawn[MAXPLAYERS] = {true, ...};
bool g_bClientIsFrozen[MAXPLAYERS] = {false, ...};
int g_iSpawnTime[MAXPLAYERS] = {0, ...};
int g_iRoundStart;
float g_fSpawnPosition[MAXPLAYERS][3];

int g_iDelayedDmg[MAXPLAYERS + 1];

#define MAXENTITIES 2048

int g_iClientFakeProps[MAXENTITIES+1] = {0, ...};

/* Taunt */

#define MAX_WHISTLE_PACKS 32
#define MAX_WHISTLES 128

int g_iTauntSoundPacks;

bool g_sWpVIPOnly[MAX_WHISTLE_PACKS];
char g_sWpNames[MAX_WHISTLE_PACKS][255];

int g_iTauntSoundPacksFileCount[MAX_WHISTLE_PACKS];
char g_sWpFiles[MAX_WHISTLE_PACKS][MAX_WHISTLES][255];
float g_fWpSoundLength[MAX_WHISTLE_PACKS][MAX_WHISTLES];

int g_iTauntPack[MAXPLAYERS + 1] =  { 0, ... };

Handle g_hCookieTauntPack;

int g_iTauntNextUse[MAXPLAYERS + 1];
int g_iTauntNextTry[MAXPLAYERS + 1];
int g_iTauntCooldownLength[MAXPLAYERS + 1];

/* Shop */

float g_fPoints[MAXPLAYERS + 1];

ArrayList g_aShopName = null;

ArrayList g_aShopPoints = null;
ArrayList g_aShopTeam = null;
ArrayList g_aShopSort = null;
ArrayList g_aShopUnlockTime = null;
ArrayList g_aShopReqFrozen = null;
ArrayList g_aShopItemDisabled = null;
ArrayList g_aClientShopItemDisabled[MAXPLAYERS + 1] = {null, ...};

/* Teams */

bool g_bSeeker[MAXPLAYERS + 1];
