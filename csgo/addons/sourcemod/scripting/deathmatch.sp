#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <csgocolors>
#include <clientprefs>

#pragma newdecls required

#define PLUGIN_VERSION          "2.0.9"
#define PLUGIN_NAME             "[CS:GO] Deathmatch"
#define PLUGIN_AUTHOR           "Maxximou5"
#define PLUGIN_DESCRIPTION      "Enables deathmatch style gameplay (respawning, gun selection, spawn protection, etc)."
#define PLUGIN_URL              "https://github.com/Maxximou5/csgo-deathmatch/"

public Plugin myinfo =
{
    name                        = PLUGIN_NAME,
    author                      = PLUGIN_AUTHOR,
    description                 = PLUGIN_DESCRIPTION,
    version                     = PLUGIN_VERSION,
    url                         = PLUGIN_URL
}

/* Defined Variables */
#define MAX_SPAWNS 200
#define HIDEHUD_RADAR 1 << 12
#define DMG_HEADSHOT (1 << 30)

/* Native Console Variables */
ConVar g_cvMP_ct_default_primary;
ConVar g_cvMP_t_default_primary;
ConVar g_cvMP_ct_default_secondary;
ConVar g_cvMP_t_default_secondary;
ConVar g_cvMP_startmoney;
ConVar g_cvMP_playercashawards;
ConVar g_cvMP_teamcashawards;
ConVar g_cvMP_friendlyfire;
ConVar g_cvMP_autokick;
ConVar g_cvMP_tkpunish;
ConVar g_cvMP_teammates_are_enemies;
ConVar g_cvFF_damage_reduction_bullets;
ConVar g_cvFF_damage_reduction_grenade;
ConVar g_cvFF_damage_reduction_other;
ConVar g_cvAmmo_grenade_limit_default;
ConVar g_cvAmmo_grenade_limit_flashbang;
ConVar g_cvAmmo_grenade_limit_total;

/* Native Backup Variables */
int g_iBackup_mp_startmoney;
int g_iBackup_mp_playercashawards;
int g_iBackup_mp_teamcashawards;
int g_iBackup_mp_friendlyfire;
int g_iBackup_mp_autokick;
int g_iBackup_mp_tkpunish;
int g_iBackup_mp_teammates_are_enemies;
int g_iBackup_ammo_grenade_limit_default;
int g_iBackup_ammo_grenade_limit_flashbang;
int g_iBackup_ammo_grenade_limit_total;
float g_fBackup_ff_damage_reduction_bullets;
float g_fBackup_ff_damage_reduction_grenade;
float g_fBackup_ff_damage_reduction_other;

/* Baked Cookies */
Handle g_hWeapon_Primary_Cookie;
Handle g_hWeapon_Secondary_Cookie;
Handle g_hWeapon_Remember_Cookie;
Handle g_hWeapon_First_Cookie;
Handle g_hHSOnly_Cookie;

/* Console variables */
ConVar g_cvDM_enabled;
ConVar g_cvDM_valvedm;
ConVar g_cvDM_welcomemsg;
ConVar g_cvDM_free_for_all;
ConVar g_cvDM_hide_radar;
ConVar g_cvDM_display_panel;
ConVar g_cvDM_display_panel_damage;
ConVar g_cvDM_sounds_bodyshots;
ConVar g_cvDM_sounds_headshots;
ConVar g_cvDM_headshot_only;
ConVar g_cvDM_headshot_only_allow_client;
ConVar g_cvDM_headshot_only_allow_world;
ConVar g_cvDM_headshot_only_allow_knife;
ConVar g_cvDM_headshot_only_allow_taser;
ConVar g_cvDM_headshot_only_allow_nade;
ConVar g_cvDM_remove_objectives;
ConVar g_cvDM_respawning;
ConVar g_cvDM_respawn_time;
ConVar g_cvDM_gun_menu_mode;
ConVar g_cvDM_los_spawning;
ConVar g_cvDM_los_attempts;
ConVar g_cvDM_spawn_distance;
ConVar g_cvDM_spawn_protection_time;
ConVar g_cvDM_loadout_style;
ConVar g_cvDM_fast_equip;
ConVar g_cvDM_no_knife_damage;
ConVar g_cvDM_remove_weapons;
ConVar g_cvDM_replenish_ammo_empty;
ConVar g_cvDM_replenish_ammo_reload;
ConVar g_cvDM_replenish_ammo_kill;
ConVar g_cvDM_replenish_ammo_type;
ConVar g_cvDM_replenish_grenade;
ConVar g_cvDM_replenish_hegrenade;
ConVar g_cvDM_replenish_grenade_kill;
ConVar g_cvDM_hp_start;
ConVar g_cvDM_hp_max;
ConVar g_cvDM_hp_kill;
ConVar g_cvDM_hp_headshot;
ConVar g_cvDM_hp_knife;
ConVar g_cvDM_hp_nade;
ConVar g_cvDM_hp_messages;
ConVar g_cvDM_ap_max;
ConVar g_cvDM_ap_kill;
ConVar g_cvDM_ap_headshot;
ConVar g_cvDM_ap_knife;
ConVar g_cvDM_ap_nade;
ConVar g_cvDM_ap_messages;
ConVar g_cvDM_nade_messages;
ConVar g_cvDM_cash_messages;
ConVar g_cvDM_armor;
ConVar g_cvDM_armor_full;
ConVar g_cvDM_zeus;
ConVar g_cvDM_nades_incendiary;
ConVar g_cvDM_nades_molotov;
ConVar g_cvDM_nades_decoy;
ConVar g_cvDM_nades_flashbang;
ConVar g_cvDM_nades_he;
ConVar g_cvDM_nades_smoke;
ConVar g_cvDM_nades_tactical;

/* Plugin Variables */
bool g_bHSOnlyClient[MAXPLAYERS + 1];
bool g_bRoundEnded = false;

/* Player Color Variables */
int g_iDefaultColor[4] = { 255, 255, 255, 255 };
int g_iColorT[4] = { 255, 0, 0, 200 };
int g_iColorCT[4] = { 0, 0, 255, 200 };

/* Respawn Variables */
int g_iSpawnPointCount = 0;
bool g_bInEditMode = false;
bool g_bSpawnPointOccupied[MAX_SPAWNS] = {false, ...};
float g_fSpawnPositions[MAX_SPAWNS][3];
float g_fSpawnAngles[MAX_SPAWNS][3];
float g_fEyeOffset[3] = { 0.0, 0.0, 64.0 }; /* CSGO offset. */
float g_fSpawnPointOffset[3] = { 0.0, 0.0, 20.0 };

/* Weapon Info */
ArrayList g_aPrimaryWeaponsAvailable;
ArrayList g_aSecondaryWeaponsAvailable;
StringMap g_smWeaponMenuNames;
StringMap g_smWeaponLimits;
StringMap g_smWeaponCounts;
StringMap g_smWeaponSkinsTeam;

/* Menus */
Handle g_hPrimaryMenus[MAXPLAYERS + 1];
Handle g_hSecondaryMenus[MAXPLAYERS + 1];
Handle g_hDamageDisplay[MAXPLAYERS+1];

/* Player settings */
int g_iLastEditorSpawnPoint[MAXPLAYERS + 1] = {-1, ...};
char g_cPrimaryWeapon[MAXPLAYERS + 1][24];
char g_cSecondaryWeapon[MAXPLAYERS + 1][24];
bool g_bInfoMessage[MAXPLAYERS + 1] = {false, ... };
bool g_bFirstWeaponSelection[MAXPLAYERS + 1] = {true, ...};
bool g_bWeaponsGivenThisRound[MAXPLAYERS + 1] = {false, ...};
bool g_bRememberChoice[MAXPLAYERS + 1] = {false, ...};
bool g_bPlayerMoved[MAXPLAYERS + 1] = {false, ...};

/* Player Glow Sprite */
int g_iGlowSprite;

/* Offsets */
int g_iAmmoOffset;

/* Spawn stats */
int g_iNumberOfPlayerSpawns = 0;
int g_iLosSearchAttempts = 0;
int g_iLosSearchSuccesses = 0;
int g_iLosSearchFailures = 0;
int g_iDistanceSearchAttempts = 0;
int g_iDistanceSearchSuccesses = 0;
int g_iDistanceSearchFailures = 0;
int g_iSpawnPointSearchFailures = 0;

public void OnPluginStart()
{
    /* Let's not waste our time here... */
    if (GetEngineVersion() != Engine_CSGO)
    {
        SetFailState("ERROR: This plugin is designed only for CS:GO.");
    }

    /* Load translations for multi-language */
    LoadTranslations("deathmatch.phrases");
    LoadTranslations("common.phrases");

    g_iAmmoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");

    /* Create arrays to store available weapons loaded by config */
    g_aPrimaryWeaponsAvailable =  new ArrayList(24);
    g_aSecondaryWeaponsAvailable =  new ArrayList(11);

    /* Create stringmap to store weapon limits, counts, and teams */
    g_smWeaponLimits = new StringMap();
    g_smWeaponCounts = new StringMap();
    g_smWeaponSkinsTeam = new StringMap();

    /* Create trie to store menu names for weapons */
    BuildWeaponMenuNames();

    /* Create Console Variables */
    CreateConVar("dm_m5_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_cvDM_enabled = CreateConVar("dm_enabled", "1", "Enable Deathmatch.");
    g_cvDM_valvedm = CreateConVar("dm_enable_valve_deathmatch", "0", "Enable compatibility for Valve's Deathmatch (game_type 1 & game_mode 2) or Custom (game_type 3 & game_mode 0).");
    g_cvDM_welcomemsg = CreateConVar("dm_welcomemsg", "1", "Display a message saying that your server is running Deathmatch.");
    g_cvDM_free_for_all = CreateConVar("dm_free_for_all", "0", "Free for all mode.");
    g_cvDM_hide_radar = CreateConVar("dm_hide_radar", "0", "Hides the radar from players.");
    g_cvDM_display_panel = CreateConVar("dm_display_panel", "0", "Display a panel showing health of the victim.");
    g_cvDM_display_panel_damage = CreateConVar("dm_display_panel_damage", "0", "Display a panel showing damage done to a player. Requires dm_display_panel set to 1.");
    g_cvDM_sounds_bodyshots = CreateConVar("dm_sounds_bodyshots", "1", "Enable the sounds of bodyshots.");
    g_cvDM_sounds_headshots = CreateConVar("dm_sounds_headshots", "1", "Enable the sounds of headshots.");
    g_cvDM_headshot_only = CreateConVar("dm_headshot_only", "0", "Headshot only mode.");
    g_cvDM_headshot_only_allow_client = CreateConVar("dm_headshot_only_allow_client", "1", "Enable clients to have their own personal headshot only mode.");
    g_cvDM_headshot_only_allow_world = CreateConVar("dm_headshot_only_allow_world", "0", "Enable world damage during headshot only mode.");
    g_cvDM_headshot_only_allow_knife = CreateConVar("dm_headshot_only_allow_knife", "0", "Enable knife damage during headshot only mode.");
    g_cvDM_headshot_only_allow_taser = CreateConVar("dm_headshot_only_allow_taser", "0", "Enable taser damage during headshot only mode.");
    g_cvDM_headshot_only_allow_nade = CreateConVar("dm_headshot_only_allow_nade", "0", "Enable grenade damage during headshot only mode.");
    g_cvDM_remove_objectives = CreateConVar("dm_remove_objectives", "1", "Remove objectives (disables bomb sites, and removes c4 and hostages).");
    g_cvDM_respawning = CreateConVar("dm_respawning", "1", "Enable respawning.");
    g_cvDM_respawn_time = CreateConVar("dm_respawn_time", "1.0", "Respawn time.");
    g_cvDM_gun_menu_mode = CreateConVar("dm_gun_menu_mode", "1", "Gun menu mode. 1) Enabled. 2) Primary weapons only. 3) Secondary weapons only. 4) Random weapons only. 5) Disabled.");
    g_cvDM_los_spawning = CreateConVar("dm_los_spawning", "1", "Enable line of sight spawning. If enabled, players will be spawned at a point where they cannot see enemies, and enemies cannot see them.");
    g_cvDM_los_attempts = CreateConVar("dm_los_attempts", "10", "Maximum number of attempts to find a suitable line of sight spawn point.");
    g_cvDM_spawn_distance = CreateConVar("dm_spawn_distance", "0.0", "Minimum distance from enemies at which a player can spawn.");
    g_cvDM_spawn_protection_time = CreateConVar("dm_spawn_protection_time", "1.0", "Spawn protection time.");
    g_cvDM_loadout_style = CreateConVar("dm_loadout_style", "1", "When players can receive weapons. 1) On respawn. 2) Immediately.");
    g_cvDM_fast_equip = CreateConVar("dm_fast_equip", "0", "Enable fast weapon equipping.");
    g_cvDM_no_knife_damage = CreateConVar("dm_no_knife_damage", "0", "Knives do NO damage to players.");
    g_cvDM_remove_weapons = CreateConVar("dm_remove_weapons", "1", "Remove ground weapons.");
    g_cvDM_replenish_ammo_empty = CreateConVar("dm_replenish_ammo_empty", "1", "Replenish ammo when weapon is empty.");
    g_cvDM_replenish_ammo_reload = CreateConVar("dm_replenish_ammo_reload", "0", "Replenish ammo on reload action.");
    g_cvDM_replenish_ammo_kill = CreateConVar("dm_replenish_ammo_kill", "1", "Replenish ammo clip on kill.");
    g_cvDM_replenish_ammo_type = CreateConVar("dm_replenish_ammo_type", "2", "Replenish type. 1) Clip only. 2) Reserve only. 3) Both.");
    g_cvDM_replenish_grenade = CreateConVar("dm_replenish_grenade", "0", "Unlimited player grenades.");
    g_cvDM_replenish_hegrenade = CreateConVar("dm_replenish_hegrenade", "0", "Unlimited hegrenades.");
    g_cvDM_replenish_grenade_kill = CreateConVar("dm_replenish_grenade_kill", "0", "Give players their grenade back on successful kill.");
    g_cvDM_nade_messages = CreateConVar("dm_nade_messages", "1", "Disable grenade messages.");
    g_cvDM_cash_messages = CreateConVar("dm_cash_messages", "1", "Disable cash award messages.");
    g_cvDM_hp_start = CreateConVar("dm_hp_start", "100", "Spawn Health Points (HP).");
    g_cvDM_hp_max = CreateConVar("dm_hp_max", "100", "Maximum Health Points (HP).");
    g_cvDM_hp_kill = CreateConVar("dm_hp_kill", "5", "Health Points (HP) per kill.");
    g_cvDM_hp_headshot = CreateConVar("dm_hp_headshot", "10", "Health Points (HP) per headshot kill.");
    g_cvDM_hp_knife = CreateConVar("dm_hp_knife", "50", "Health Points (HP) per knife kill.");
    g_cvDM_hp_nade = CreateConVar("dm_hp_nade", "30", "Health Points (HP) per nade kill.");
    g_cvDM_hp_messages = CreateConVar("dm_hp_messages", "1", "Display HP messages.");
    g_cvDM_ap_max = CreateConVar("dm_ap_max", "100", "Maximum Armor Points (AP).");
    g_cvDM_ap_kill = CreateConVar("dm_ap_kill", "5", "Armor Points (AP) per kill.");
    g_cvDM_ap_headshot = CreateConVar("dm_ap_headshot", "10", "Armor Points (AP) per headshot kill.");
    g_cvDM_ap_knife = CreateConVar("dm_ap_knife", "50", "Armor Points (AP) per knife kill.");
    g_cvDM_ap_nade = CreateConVar("dm_ap_nade", "30", "Armor Points (AP) per nade kill.");
    g_cvDM_ap_messages = CreateConVar("dm_ap_messages", "1", "Display AP messages.");
    g_cvDM_armor = CreateConVar("dm_armor", "0", "Give players chest armor.");
    g_cvDM_armor_full = CreateConVar("dm_armor_full", "1", "Give players head and chest armor.");
    g_cvDM_zeus = CreateConVar("dm_zeus", "0", "Give players a taser.");
    g_cvDM_nades_incendiary = CreateConVar("dm_nades_incendiary", "0", "Number of incendiary grenades to give each player.");
    g_cvDM_nades_molotov = CreateConVar("dm_nades_molotov", "0", "Number of molotov grenades to give each player.");
    g_cvDM_nades_decoy = CreateConVar("dm_nades_decoy", "0", "Number of decoy grenades to give each player.");
    g_cvDM_nades_flashbang = CreateConVar("dm_nades_flashbang", "0", "Number of flashbang grenades to give each player.");
    g_cvDM_nades_he = CreateConVar("dm_nades_he", "0", "Number of HE grenades to give each player.");
    g_cvDM_nades_smoke = CreateConVar("dm_nades_smoke", "0", "Number of smoke grenades to give each player.");
    g_cvDM_nades_tactical = CreateConVar("dm_nades_tactical", "0", "Number of tactical grenades to give each player.");

    /* Load DM Config */
    LoadConfig();

    /* Admin Commands */
    RegAdminCmd("dm_spawn_menu", Command_SpawnMenu, ADMFLAG_CHANGEMAP, "Opens the spawn point menu.");
    RegAdminCmd("dm_respawn_all", Command_RespawnAll, ADMFLAG_CHANGEMAP, "Respawns all players.");
    RegAdminCmd("dm_stats", Command_Stats, ADMFLAG_CHANGEMAP, "Displays spawn statistics.");
    RegAdminCmd("dm_reset_stats", Command_ResetStats, ADMFLAG_CHANGEMAP, "Resets spawn statistics.");

    /* Hook Console Variables */
    g_cvDM_enabled.AddChangeHook(Event_CvarChange);
    g_cvDM_valvedm.AddChangeHook(Event_CvarChange);
    g_cvDM_welcomemsg.AddChangeHook(Event_CvarChange);
    g_cvDM_free_for_all.AddChangeHook(Event_CvarChange);
    g_cvDM_hide_radar.AddChangeHook(Event_CvarChange);
    g_cvDM_display_panel.AddChangeHook(Event_CvarChange);
    g_cvDM_display_panel_damage.AddChangeHook(Event_CvarChange);
    g_cvDM_sounds_bodyshots.AddChangeHook(Event_CvarChange);
    g_cvDM_sounds_headshots.AddChangeHook(Event_CvarChange);
    g_cvDM_headshot_only.AddChangeHook(Event_CvarChange);
    g_cvDM_headshot_only_allow_client.AddChangeHook(Event_CvarChange);
    g_cvDM_headshot_only_allow_world.AddChangeHook(Event_CvarChange);
    g_cvDM_headshot_only_allow_knife.AddChangeHook(Event_CvarChange);
    g_cvDM_headshot_only_allow_taser.AddChangeHook(Event_CvarChange);
    g_cvDM_headshot_only_allow_nade.AddChangeHook(Event_CvarChange);
    g_cvDM_remove_objectives.AddChangeHook(Event_CvarChange);
    g_cvDM_respawning.AddChangeHook(Event_CvarChange);
    g_cvDM_respawn_time.AddChangeHook(Event_CvarChange);
    g_cvDM_gun_menu_mode.AddChangeHook(Event_CvarChange);
    g_cvDM_los_spawning.AddChangeHook(Event_CvarChange);
    g_cvDM_los_attempts.AddChangeHook(Event_CvarChange);
    g_cvDM_spawn_distance.AddChangeHook(Event_CvarChange);
    g_cvDM_spawn_protection_time.AddChangeHook(Event_CvarChange);
    g_cvDM_loadout_style.AddChangeHook(Event_CvarChange);
    g_cvDM_fast_equip.AddChangeHook(Event_CvarChange);
    g_cvDM_no_knife_damage.AddChangeHook(Event_CvarChange);
    g_cvDM_remove_weapons.AddChangeHook(Event_CvarChange);
    g_cvDM_replenish_ammo_empty.AddChangeHook(Event_CvarChange);
    g_cvDM_replenish_ammo_reload.AddChangeHook(Event_CvarChange);
    g_cvDM_replenish_ammo_kill.AddChangeHook(Event_CvarChange);
    g_cvDM_replenish_ammo_type.AddChangeHook(Event_CvarChange);
    g_cvDM_replenish_grenade.AddChangeHook(Event_CvarChange);
    g_cvDM_replenish_hegrenade.AddChangeHook(Event_CvarChange);
    g_cvDM_replenish_grenade_kill.AddChangeHook(Event_CvarChange);
    g_cvDM_hp_start.AddChangeHook(Event_CvarChange);
    g_cvDM_hp_max.AddChangeHook(Event_CvarChange);
    g_cvDM_hp_kill.AddChangeHook(Event_CvarChange);
    g_cvDM_hp_headshot.AddChangeHook(Event_CvarChange);
    g_cvDM_hp_knife.AddChangeHook(Event_CvarChange);
    g_cvDM_hp_nade.AddChangeHook(Event_CvarChange);
    g_cvDM_hp_messages.AddChangeHook(Event_CvarChange);
    g_cvDM_ap_max.AddChangeHook(Event_CvarChange);
    g_cvDM_ap_kill.AddChangeHook(Event_CvarChange);
    g_cvDM_ap_headshot.AddChangeHook(Event_CvarChange);
    g_cvDM_ap_knife.AddChangeHook(Event_CvarChange);
    g_cvDM_ap_nade.AddChangeHook(Event_CvarChange);
    g_cvDM_ap_messages.AddChangeHook(Event_CvarChange);
    g_cvDM_nade_messages.AddChangeHook(Event_CvarChange);
    g_cvDM_cash_messages.AddChangeHook(Event_CvarChange);
    g_cvDM_armor.AddChangeHook(Event_CvarChange);
    g_cvDM_armor_full.AddChangeHook(Event_CvarChange);
    g_cvDM_zeus.AddChangeHook(Event_CvarChange);
    g_cvDM_nades_incendiary.AddChangeHook(Event_CvarChange);
    g_cvDM_nades_molotov.AddChangeHook(Event_CvarChange);
    g_cvDM_nades_decoy.AddChangeHook(Event_CvarChange);
    g_cvDM_nades_flashbang.AddChangeHook(Event_CvarChange);
    g_cvDM_nades_he.AddChangeHook(Event_CvarChange);
    g_cvDM_nades_smoke.AddChangeHook(Event_CvarChange);
    g_cvDM_nades_tactical.AddChangeHook(Event_CvarChange);

    /* Listen For Client Commands */
    AddCommandListener(Event_Say, "say");
    AddCommandListener(Event_Say, "say_team");

    /* Hook Client Messages */
    HookUserMessage(GetUserMessageId("TextMsg"), Event_TextMsg, true);
    HookUserMessage(GetUserMessageId("HintText"), Event_HintText, true);
    HookUserMessage(GetUserMessageId("RadioText"), Event_RadioText, true);

    /* Hook Events */
    HookEvent("player_team", Event_PlayerTeam);
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
    HookEvent("round_prestart", Event_RoundPrestart, EventHookMode_PostNoCopy);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("weapon_fire_on_empty", Event_WeaponFireOnEmpty, EventHookMode_Post);
    HookEvent("hegrenade_detonate", Event_HegrenadeDetonate, EventHookMode_Post);
    HookEvent("smokegrenade_detonate", Event_SmokegrenadeDetonate, EventHookMode_Post);
    HookEvent("flashbang_detonate", Event_FlashbangDetonate, EventHookMode_Post);
    HookEvent("molotov_detonate", Event_MolotovDetonate, EventHookMode_Post);
    HookEvent("inferno_startburn", Event_InfernoStartburn, EventHookMode_Post);
    HookEvent("decoy_started", Event_DecoyStarted, EventHookMode_Post);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("bomb_pickup", Event_BombPickup);

    /* Hook Sound Events */
    AddNormalSoundHook(view_as<NormalSHook>(Event_Sound));

    /* Create Global Timers */
    CreateTimer(0.5, UpdateSpawnPointStatus, INVALID_HANDLE, TIMER_REPEAT);
    CreateTimer(1.0, RemoveGroundWeapons, INVALID_HANDLE, TIMER_REPEAT);

    /* Baked Cookies */
    g_hWeapon_Primary_Cookie = RegClientCookie("dm_weapon_primary", "Primary Weapon Selection", CookieAccess_Protected);
    g_hWeapon_Secondary_Cookie = RegClientCookie("dm_weapon_secondary", "Secondary Weapon Selection", CookieAccess_Protected);
    g_hWeapon_Remember_Cookie = RegClientCookie("dm_weapon_remember", "Remember Weapon Selection", CookieAccess_Protected);
    g_hWeapon_First_Cookie = RegClientCookie("dm_weapon_first", "First Weapon Selection", CookieAccess_Protected);
    g_hHSOnly_Cookie = RegClientCookie("dm_hsonly", "Headshot Only", CookieAccess_Protected);

    /* Late Load Cookies */
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i) && IsValidClient(i) && !IsFakeClient(i))
            OnClientCookiesCached(i);
    }

    /* SDK Hooks For Clients */
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            OnClientPutInServer(i);
    }

    /* Update and Retrieve */
    RetrieveVariables();
    UpdateState();
}

public void OnClientCookiesCached(int client)
{
    char cPrimary[24];
    char cSecondary[24];
    char cRemember[24];
    char cFirst[24];
    char cHSOnly[24];
    GetClientCookie(client, g_hWeapon_Primary_Cookie, cPrimary, sizeof(cPrimary));
    GetClientCookie(client, g_hWeapon_Secondary_Cookie, cSecondary, sizeof(cSecondary));
    GetClientCookie(client, g_hWeapon_Remember_Cookie, cRemember, sizeof(cRemember));
    GetClientCookie(client, g_hWeapon_First_Cookie, cFirst, sizeof(cFirst));
    GetClientCookie(client, g_hHSOnly_Cookie, cHSOnly, sizeof(cHSOnly));
    if (!StrEqual(cPrimary, ""))
        g_cPrimaryWeapon[client] = cPrimary;
    else g_cPrimaryWeapon[client] = "none";
    if (!StrEqual(cSecondary, ""))
        g_cSecondaryWeapon[client] = cSecondary;
    else g_cSecondaryWeapon[client] = "none";
    if (!StrEqual(cRemember, ""))
        g_bRememberChoice[client] = view_as<bool>(StringToInt(cRemember));
    else g_bRememberChoice[client] = false;
    if (!StrEqual(cFirst, ""))
        g_bFirstWeaponSelection[client] = view_as<bool>(StringToInt(cFirst));
    else g_bFirstWeaponSelection[client] = false;
    if (!StrEqual(cHSOnly, ""))
        g_bHSOnlyClient[client] = view_as<bool>(StringToInt(cHSOnly));
    else g_bHSOnlyClient[client] = false;
}

public void OnPluginEnd()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        DisableSpawnProtection(INVALID_HANDLE, i);
        OnClientDisconnect(i);
    }
    SetBuyZones("Enable");
    SetObjectives("Enable");
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_hPrimaryMenus[i] != INVALID_HANDLE)
            CancelMenu(g_hPrimaryMenus[i]);
    }
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_hSecondaryMenus[i] != INVALID_HANDLE)
            CancelMenu(g_hSecondaryMenus[i]);
    }
    RestoreCashState();
    RestoreGrenadeState();
    DisableFFA();
}

public void OnConfigsExecuted()
{
    RetrieveVariables();
    UpdateState();
}

public void OnMapStart()
{
    /* Precache Sprite */
    g_iGlowSprite = PrecacheModel("sprites/glow01.vmt", true);

    InitialiseWeaponCounts();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i))
            ResetClientSettings(i);
    }
    LoadMapConfig();
    if (g_iSpawnPointCount > 0)
    {
        for (int i = 0; i < g_iSpawnPointCount; i++)
            g_bSpawnPointOccupied[i] = false;
    }
    if (g_cvDM_enabled.BoolValue)
    {
        SetBuyZones("Disable");
        if (g_cvDM_remove_objectives.BoolValue)
        {
            SetObjectives("Disable");
            RemoveHostages();
        }
        SetCashState();
        SetGrenadeState();
        SetNoSpawnWeapons();
        if (g_cvDM_free_for_all.BoolValue)
            EnableFFA();
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientPostAdminCheck(int client)
{
    if (g_cvDM_enabled.BoolValue)
        ResetClientSettings(client);
}

public void OnClientDisconnect(int client)
{
    RemoveRagdoll(client);
    SDKUnhook(client, SDKHook_TraceAttack, OnTraceAttack);
    SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

bool IsValidClient(int client)
{
    if (!(0 < client <= MaxClients)) return false;
    if (!IsClientInGame(client)) return false;
    return true;
}

void ResetClientSettings(int client)
{
    g_iLastEditorSpawnPoint[client] = -1;
    SetClientGunModeSettings(client);
    g_bInfoMessage[client] = false;
    g_bWeaponsGivenThisRound[client] = false;
    g_bPlayerMoved[client] = false;
}

void SetClientGunSettings(int client, char[] primary, char[] secondary, bool firstweapon)
{
    strcopy(g_cPrimaryWeapon[client], sizeof(g_cPrimaryWeapon[]), primary);
    strcopy(g_cSecondaryWeapon[client], sizeof(g_cSecondaryWeapon[]), secondary);
    g_bFirstWeaponSelection[client] = firstweapon;
}

void SetClientGunModeSettings(int client)
{
    switch (g_cvDM_gun_menu_mode.IntValue)
    {
        case 1:
        {
            if (IsFakeClient(client))
                SetClientGunSettings(client, "random", "random", false);
        }
        case 2:
        {
            if (IsFakeClient(client))
                SetClientGunSettings(client, "random", "none", false);
        }
        case 3:
        {
            if (IsFakeClient(client))
                SetClientGunSettings(client, "none", "random", false);
        }
        case 4:
        {
            SetClientGunSettings(client, "random", "random", false);
            if (!IsFakeClient(client))
            {
                SetClientCookie(client, g_hWeapon_Primary_Cookie, "random");
                SetClientCookie(client, g_hWeapon_Secondary_Cookie, "random");
                SetClientCookie(client, g_hWeapon_First_Cookie, "0");
            }
        }
        case 5:
        {
            if (IsFakeClient(client))
            {
                SetClientGunSettings(client, "random", "random", false);
                g_bRememberChoice[client] = true;
            }
        }
    }
}

public void Event_CvarChange(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    UpdateState();
}

void LoadConfig()
{
    KeyValues kv = new KeyValues("Deathmatch Config");
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/deathmatch/deathmatch.ini");

    if (!FileToKeyValues(kv, path))
        SetFailState("The configuration file could not be read.");

    if (!kv.JumpToKey("Options"))
        SetFailState("The configuration file is corrupt (\"Options\" section could not be found).");

    char key[25];
    char value[25];

    kv.GetString("dm_enabled", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_enabled.SetString(value);

    kv.GetString("dm_enable_valve_deathmatch", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_valvedm.SetString(value);

    kv.GetString("dm_welcomemsg", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_welcomemsg.SetString(value);

    kv.GetString("dm_free_for_all", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_free_for_all.SetString(value);

    kv.GetString("dm_hide_radar", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_hide_radar.SetString(value);

    kv.GetString("dm_display_panel", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_display_panel.SetString(value);

    kv.GetString("dm_display_panel_damage", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_display_panel_damage.SetString(value);

    kv.GetString("dm_sounds_bodyshots", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_sounds_bodyshots.SetString(value);

    kv.GetString("dm_sounds_headshots", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_sounds_headshots.SetString(value);

    kv.GetString("dm_headshot_only", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_headshot_only.SetString(value);

    kv.GetString("dm_headshot_only_allow_client", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_headshot_only_allow_client.SetString(value);

    kv.GetString("dm_headshot_only_allow_world", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_headshot_only_allow_world.SetString(value);

    kv.GetString("dm_headshot_only_allow_knife", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_headshot_only_allow_knife.SetString(value);

    kv.GetString("dm_headshot_only_allow_taser", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_headshot_only_allow_taser.SetString(value);

    kv.GetString("dm_headshot_only_allow_nade", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_headshot_only_allow_nade.SetString(value);

    kv.GetString("dm_remove_objectives", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_remove_objectives.SetString(value);

    kv.GetString("dm_respawning", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_respawning.SetString(value);

    kv.GetString("dm_respawn_time", value, sizeof(value), "2.0");
    g_cvDM_respawn_time.SetString(value);

    kv.GetString("dm_gun_menu_mode", value, sizeof(value), "1");
    g_cvDM_gun_menu_mode.SetString(value);

    kv.GetString("dm_los_spawning", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_los_spawning.SetString(value);

    kv.GetString("dm_los_attempts", value, sizeof(value), "10");
    g_cvDM_los_attempts.SetString(value);

    kv.GetString("dm_spawn_distance", value, sizeof(value), "0.0");
    g_cvDM_spawn_distance.SetString(value);

    kv.GetString("dm_spawn_protection_time", value, sizeof(value), "1.0");
    g_cvDM_spawn_protection_time.SetString(value);

    kv.GetString("dm_loadout_style", value, sizeof(value), "1");
    g_cvDM_loadout_style.SetString(value);

    kv.GetString("dm_fast_equip", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_fast_equip.SetString(value);

    kv.GetString("dm_no_knife_damage", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_no_knife_damage.SetString(value);

    kv.GetString("dm_remove_weapons", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_remove_weapons.SetString(value);

    kv.GetString("dm_replenish_ammo_empty", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_replenish_ammo_empty.SetString(value);

    kv.GetString("dm_replenish_ammo_reload", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_replenish_ammo_reload.SetString(value);

    kv.GetString("dm_replenish_ammo_kill", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_replenish_ammo_kill.SetString(value);

    kv.GetString("dm_replenish_ammo_type", value, sizeof(value), "2");
    g_cvDM_replenish_ammo_type.SetString(value);

    kv.GetString("dm_replenish_grenade", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_replenish_grenade.SetString(value);

    kv.GetString("dm_replenish_hegrenade", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_replenish_hegrenade.SetString(value);

    kv.GetString("dm_replenish_grenade_kill", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_replenish_grenade_kill.SetString(value);

    kv.GetString("dm_nade_messages", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_nade_messages.SetString(value);

    kv.GetString("dm_cash_messages", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_cash_messages.SetString(value);

    kv.GetString("dm_hp_start", value, sizeof(value), "100");
    g_cvDM_hp_start.SetString(value);

    kv.GetString("dm_hp_max", value, sizeof(value), "100");
    g_cvDM_hp_max.SetString(value);

    kv.GetString("dm_hp_kill", value, sizeof(value), "5");
    g_cvDM_hp_kill.SetString(value);

    kv.GetString("dm_hp_headshot", value, sizeof(value), "10");
    g_cvDM_hp_headshot.SetString(value);

    kv.GetString("dm_hp_knife", value, sizeof(value), "50");
    g_cvDM_hp_knife.SetString(value);

    kv.GetString("dm_hp_kill", value, sizeof(value), "30");
    g_cvDM_hp_nade.SetString(value);

    kv.GetString("dm_hp_messages", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_hp_messages.SetString(value);

    kv.GetString("dm_ap_max", value, sizeof(value), "100");
    g_cvDM_ap_max.SetString(value);

    kv.GetString("dm_ap_kill", value, sizeof(value), "5");
    g_cvDM_ap_kill.SetString(value);

    kv.GetString("dm_ap_headshot", value, sizeof(value), "10");
    g_cvDM_ap_headshot.SetString(value);

    kv.GetString("dm_ap_knife", value, sizeof(value), "50");
    g_cvDM_ap_knife.SetString(value);

    kv.GetString("dm_ap_nade", value, sizeof(value), "30");
    g_cvDM_ap_nade.SetString(value);

    kv.GetString("dm_ap_messages", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_ap_messages.SetString(value);

    kv.GoBack();

    if (!kv.JumpToKey("Weapons"))
        SetFailState("The configuration file is corrupt (\"Weapons\" section could not be found).");

    if (!kv.JumpToKey("Primary"))
        SetFailState("The configuration file is corrupt (\"Primary\" section could not be found).");

    if (kv.GotoFirstSubKey(false))
    {
        do {
            kv.GetSectionName(key, sizeof(key));
            int limit = kv.GetNum(NULL_STRING, -1);
            if (limit == 0) {continue;}
            g_aPrimaryWeaponsAvailable.PushString(key);
            g_smWeaponLimits.SetValue(key, limit);
        } while (kv.GotoNextKey(false));
    }

    kv.GoBack();
    kv.GoBack();

    if (!kv.JumpToKey("Secondary"))
        SetFailState("The configuration file is corrupt (\"Secondary\" section could not be found).");

    if (kv.GotoFirstSubKey(false))
    {
        do {
            kv.GetSectionName(key, sizeof(key));
            int limit = kv.GetNum(NULL_STRING, -1);
            if (limit == 0) {continue;}
            g_aSecondaryWeaponsAvailable.PushString(key);
            g_smWeaponLimits.SetValue(key, limit);
        } while (kv.GotoNextKey(false));
    }

    kv.GoBack();
    kv.GoBack();

    if (!kv.JumpToKey("Misc"))
        SetFailState("The configuration file is corrupt (\"Misc\" section could not be found).");

    kv.GetString("armor (chest)", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_armor.SetString(value);

    kv.GetString("armor (full)", value, sizeof(value), "yes");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_armor_full.SetString(value);

    kv.GetString("zeus", value, sizeof(value), "no");
    value = (StrEqual(value, "yes")) ? "1" : "0";
    g_cvDM_zeus.SetString(value);

    kv.GoBack();

    if (!kv.JumpToKey("Grenades"))
        SetFailState("The configuration file is corrupt (\"Grenades\" section could not be found).");

    kv.GetString("incendiary", value, sizeof(value), "0");
    g_cvDM_nades_incendiary.SetString(value);

    kv.GetString("molotov", value, sizeof(value), "0");
    g_cvDM_nades_incendiary.SetString(value);

    kv.GetString("decoy", value, sizeof(value), "0");
    g_cvDM_nades_decoy.SetString(value);

    kv.GetString("flashbang", value, sizeof(value), "0");
    g_cvDM_nades_flashbang.SetString(value);

    kv.GetString("he", value, sizeof(value), "0");
    g_cvDM_nades_he.SetString(value);

    kv.GetString("smoke", value, sizeof(value), "0");
    g_cvDM_nades_smoke.SetString(value);

    kv.GetString("tactical", value, sizeof(value), "0");
    g_cvDM_nades_tactical.SetString(value);

    kv.GoBack();

    if (!kv.JumpToKey("TeamSkins"))
        SetFailState("The configuration file is corrupt (\"TeamSkins\" section could not be found).");

    if (kv.GotoFirstSubKey(false))
    {
        do {
            kv.GetSectionName(key, sizeof(key));
            kv.GetString(NULL_STRING, value, sizeof(value), "");
            int team = 0;
            if (StrEqual(value, "CT", false))
                team = CS_TEAM_CT;
            else if (StrEqual(value, "T", false))
                team = CS_TEAM_T;
            g_smWeaponSkinsTeam.SetValue(key, team);
        } while (kv.GotoNextKey(false));
        kv.GoBack();
    }

    delete kv;
}

void RetrieveVariables()
{
    /* Retrieve Native Console Variables */
    g_cvMP_ct_default_primary = FindConVar("mp_ct_default_primary");
    g_cvMP_t_default_primary = FindConVar("mp_t_default_primary");
    g_cvMP_ct_default_secondary = FindConVar("mp_ct_default_secondary");
    g_cvMP_t_default_secondary = FindConVar("mp_t_default_secondary");
    g_cvMP_startmoney = FindConVar("mp_startmoney");
    g_cvMP_playercashawards = FindConVar("mp_playercashawards");
    g_cvMP_teamcashawards = FindConVar("mp_teamcashawards");
    g_cvMP_friendlyfire = FindConVar("mp_friendlyfire");
    g_cvMP_autokick = FindConVar("mp_autokick");
    g_cvMP_tkpunish = FindConVar("mp_tkpunish");
    g_cvMP_teammates_are_enemies = FindConVar("mp_teammates_are_enemies");
    g_cvFF_damage_reduction_bullets = FindConVar("ff_damage_reduction_bullets");
    g_cvFF_damage_reduction_grenade = FindConVar("ff_damage_reduction_grenade");
    g_cvFF_damage_reduction_other = FindConVar("ff_damage_reduction_other");
    g_cvAmmo_grenade_limit_default = FindConVar("ammo_grenade_limit_default");
    g_cvAmmo_grenade_limit_flashbang = FindConVar("ammo_grenade_limit_flashbang");
    g_cvAmmo_grenade_limit_total = FindConVar("ammo_grenade_limit_total");
    /* Retrieve Native Console Variable Values */
    g_iBackup_mp_startmoney = g_cvMP_startmoney.IntValue;
    g_iBackup_mp_playercashawards = g_cvMP_playercashawards.IntValue;
    g_iBackup_mp_teamcashawards = g_cvMP_teamcashawards.IntValue;
    g_iBackup_mp_friendlyfire = g_cvMP_friendlyfire.IntValue;
    g_iBackup_mp_autokick = g_cvMP_autokick.IntValue;
    g_iBackup_mp_tkpunish = g_cvMP_tkpunish.IntValue;
    g_iBackup_mp_teammates_are_enemies = g_cvMP_teammates_are_enemies.IntValue;
    g_fBackup_ff_damage_reduction_bullets = g_cvFF_damage_reduction_bullets.FloatValue;
    g_fBackup_ff_damage_reduction_grenade = g_cvFF_damage_reduction_grenade.FloatValue;
    g_fBackup_ff_damage_reduction_other = g_cvFF_damage_reduction_other.FloatValue;
    g_iBackup_ammo_grenade_limit_default = g_cvAmmo_grenade_limit_default.IntValue;
    g_iBackup_ammo_grenade_limit_flashbang = g_cvAmmo_grenade_limit_flashbang.IntValue;
    g_iBackup_ammo_grenade_limit_total = g_cvAmmo_grenade_limit_total.IntValue;
}

void UpdateState()
{
    if (g_cvDM_respawn_time.FloatValue < 0.0) g_cvDM_respawn_time.FloatValue = 0.0;
    if (g_cvDM_gun_menu_mode.IntValue < 1) g_cvDM_gun_menu_mode.IntValue = 1;
    if (g_cvDM_gun_menu_mode.IntValue > 5) g_cvDM_gun_menu_mode.IntValue = 5;
    if (g_cvDM_los_attempts.IntValue < 0) g_cvDM_los_attempts.IntValue = 0;
    if (g_cvDM_spawn_distance.FloatValue < 0.0) g_cvDM_spawn_distance.FloatValue = 0.0;
    if (g_cvDM_spawn_protection_time.FloatValue < 0.0) g_cvDM_spawn_protection_time.FloatValue = 0.0;
    if (g_cvDM_hp_start.IntValue < 1) g_cvDM_hp_start.IntValue = 1;
    if (g_cvDM_hp_max.IntValue < 1) g_cvDM_hp_max.IntValue = 1;
    if (g_cvDM_hp_kill.IntValue < 0) g_cvDM_hp_kill.IntValue = 0;
    if (g_cvDM_hp_headshot.IntValue < 0) g_cvDM_hp_headshot.IntValue = 0;
    if (g_cvDM_hp_knife.IntValue < 0) g_cvDM_hp_knife.IntValue = 0;
    if (g_cvDM_hp_nade.IntValue < 0) g_cvDM_hp_nade.IntValue = 0;
    if (g_cvDM_ap_max.IntValue < 0) g_cvDM_ap_max.IntValue = 0;
    if (g_cvDM_ap_kill.IntValue < 0) g_cvDM_ap_kill.IntValue = 0;
    if (g_cvDM_ap_headshot.IntValue < 0) g_cvDM_ap_headshot.IntValue = 0;
    if (g_cvDM_ap_knife.IntValue < 0) g_cvDM_ap_knife.IntValue = 0;
    if (g_cvDM_ap_nade.IntValue < 0) g_cvDM_ap_nade.IntValue = 0;
    if (g_cvDM_nades_incendiary.IntValue < 0) g_cvDM_nades_incendiary.IntValue = 0;
    if (g_cvDM_nades_molotov.IntValue < 0) g_cvDM_nades_molotov.IntValue = 0;
    if (g_cvDM_nades_decoy.IntValue < 0) g_cvDM_nades_decoy.IntValue = 0;
    if (g_cvDM_nades_flashbang.IntValue < 0) g_cvDM_nades_flashbang.IntValue = 0;
    if (g_cvDM_nades_he.IntValue < 0) g_cvDM_nades_he.IntValue = 0;
    if (g_cvDM_nades_smoke.IntValue < 0) g_cvDM_nades_smoke.IntValue = 0;
    if (g_cvDM_nades_tactical.IntValue < 0) g_cvDM_nades_tactical.IntValue = 0;

    if (g_cvDM_enabled.BoolValue)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientConnected(i))
                ResetClientSettings(i);
        }
        RespawnAll();
        SetBuyZones("Disable");
        char status[10];
        status = (g_cvDM_remove_objectives.BoolValue) ? "Disable" : "Enable";
        SetObjectives(status);
        SetCashState();
        SetNoSpawnWeapons();
    }
    else if (!g_cvDM_enabled.BoolValue)
    {
        for (int i = 1; i <= MaxClients; i++)
            DisableSpawnProtection(INVALID_HANDLE, i);
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_hPrimaryMenus[i] != INVALID_HANDLE)
                CancelMenu(g_hPrimaryMenus[i]);
        }
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_hSecondaryMenus[i] != INVALID_HANDLE)
                CancelMenu(g_hSecondaryMenus[i]);
        }
        SetBuyZones("Enable");
        SetObjectives("Enable");
        RestoreCashState();
        RestoreGrenadeState();
    }

    if (g_cvDM_enabled.BoolValue)
    {
        if (g_cvDM_gun_menu_mode.IntValue)
        {
            if (g_cvDM_gun_menu_mode.IntValue == 5)
            {
                for (int i = 1; i <= MaxClients; i++)
                    CancelClientMenu(i);
            }
            /* Only if the plugin was enabled before the state update do we need to update the client's gun mode settings. If it was disabled before, then */
            /* the entire client settings (including gun mode settings) are reset above. */
            for (int i = 1; i <= MaxClients; i++)
            {
                if (IsClientConnected(i))
                    SetClientGunModeSettings(i);
            }
        }
        if (g_cvDM_remove_objectives.BoolValue)
            RemoveC4();

        SetGrenadeState();

        if (g_cvDM_free_for_all.BoolValue)
            EnableFFA();
        else
            DisableFFA();
    }
}

void SetNoSpawnWeapons()
{
    g_cvMP_ct_default_primary.SetString("");
    g_cvMP_t_default_primary.SetString("");
    g_cvMP_ct_default_secondary.SetString("");
    g_cvMP_t_default_secondary.SetString("");
}

void SetCashState()
{
    g_cvMP_startmoney.SetInt(0);
    g_cvMP_playercashawards.SetInt(0);
    g_cvMP_teamcashawards.SetInt(0);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
            SetEntProp(i, Prop_Send, "m_iAccount", 0);
    }
}

void RestoreCashState()
{
    g_cvMP_startmoney.SetInt(g_iBackup_mp_startmoney);
    g_cvMP_playercashawards.SetInt(g_iBackup_mp_playercashawards);
    g_cvMP_teamcashawards.SetInt(g_iBackup_mp_teamcashawards);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
            SetEntProp(i, Prop_Send, "m_iAccount", g_iBackup_mp_startmoney);
    }
}

void SetGrenadeState()
{
    int maxGrenadesSameType = 0;
    if (g_cvDM_nades_incendiary.IntValue > maxGrenadesSameType) maxGrenadesSameType = g_cvDM_nades_incendiary.IntValue;
    if (g_cvDM_nades_molotov.IntValue > maxGrenadesSameType) maxGrenadesSameType = g_cvDM_nades_molotov.IntValue;
    if (g_cvDM_nades_decoy.IntValue > maxGrenadesSameType) maxGrenadesSameType = g_cvDM_nades_decoy.IntValue;
    if (g_cvDM_nades_flashbang.IntValue > maxGrenadesSameType) maxGrenadesSameType = g_cvDM_nades_flashbang.IntValue;
    if (g_cvDM_nades_he.IntValue > maxGrenadesSameType) maxGrenadesSameType = g_cvDM_nades_he.IntValue;
    if (g_cvDM_nades_smoke.IntValue > maxGrenadesSameType) maxGrenadesSameType = g_cvDM_nades_smoke.IntValue;
    if (g_cvDM_nades_tactical.IntValue > maxGrenadesSameType) maxGrenadesSameType = g_cvDM_nades_tactical.IntValue;
    g_cvAmmo_grenade_limit_default.SetInt(maxGrenadesSameType);
    g_cvAmmo_grenade_limit_flashbang.SetInt(g_cvDM_nades_flashbang.IntValue);
    g_cvAmmo_grenade_limit_total.SetInt(
        g_cvDM_nades_incendiary.IntValue + 
        g_cvDM_nades_molotov.IntValue + 
        g_cvDM_nades_decoy.IntValue + 
        g_cvDM_nades_flashbang.IntValue + 
        g_cvDM_nades_he.IntValue + 
        g_cvDM_nades_smoke.IntValue + 
        g_cvDM_nades_tactical.IntValue);
}

void RestoreGrenadeState()
{
    g_cvAmmo_grenade_limit_default.SetInt(g_iBackup_ammo_grenade_limit_default);
    g_cvAmmo_grenade_limit_flashbang.SetInt(g_iBackup_ammo_grenade_limit_flashbang);
    g_cvAmmo_grenade_limit_total.SetInt(g_iBackup_ammo_grenade_limit_total);
}

void EnableFFA()
{
    g_cvMP_teammates_are_enemies.SetInt(1);
    g_cvMP_friendlyfire.SetInt(1);
    g_cvMP_autokick.SetInt(0);
    g_cvMP_tkpunish.SetInt(0);
    g_cvFF_damage_reduction_bullets.SetFloat(1.0);
    g_cvFF_damage_reduction_grenade.SetFloat(1.0);
    g_cvFF_damage_reduction_other.SetFloat(1.0);
}

void DisableFFA()
{
    g_cvMP_teammates_are_enemies.SetInt(g_iBackup_mp_teammates_are_enemies);
    g_cvMP_friendlyfire.SetInt(g_iBackup_mp_friendlyfire);
    g_cvMP_autokick.SetInt(g_iBackup_mp_autokick);
    g_cvMP_tkpunish.SetInt(g_iBackup_mp_tkpunish);
    g_cvFF_damage_reduction_bullets.SetFloat(g_fBackup_ff_damage_reduction_bullets);
    g_cvFF_damage_reduction_grenade.SetFloat(g_fBackup_ff_damage_reduction_grenade);
    g_cvFF_damage_reduction_other.SetFloat(g_fBackup_ff_damage_reduction_other);
}

void GetCurrentWorkshopMap(char[] map, int mapbuffer, char[] workshopID, int workshopbuffer)
{
    char currentmap[128]
    char currentmapbuffer[2][64]

    GetCurrentMap(currentmap, 127)
    ReplaceString(currentmap, sizeof(currentmap), "workshop/", "", false)
    ExplodeString(currentmap, "/", currentmapbuffer, 2, 63)

    strcopy(map, mapbuffer, currentmapbuffer[1])
    strcopy(workshopID, workshopbuffer, currentmapbuffer[0])
}

void LoadMapConfig()
{
    char path[PLATFORM_MAX_PATH];
    char workshopID[PLATFORM_MAX_PATH];
    char map[PLATFORM_MAX_PATH];
    char workshop[PLATFORM_MAX_PATH];
    GetCurrentMap(map, PLATFORM_MAX_PATH);

    BuildPath(Path_SM, path, sizeof(path), "configs/deathmatch/spawns");
    if (!DirExists(path))
        if (!CreateDirectory(path, 511))
            LogError("Failed to create directory %s", path);

    BuildPath(Path_SM, path, sizeof(path), "configs/deathmatch/spawns/workshop");
    if (!DirExists(path))
        if (!CreateDirectory(path, 511))
            LogError("Failed to create directory %s", path);

    if (StrContains(map, "workshop", false) != -1)
    {
        GetCurrentWorkshopMap(workshop, PLATFORM_MAX_PATH, workshopID, sizeof(workshopID) - 1);
        BuildPath(Path_SM, path, sizeof(path), "configs/deathmatch/spawns/workshop/%s", workshopID);
        if (!DirExists(path))
            if (!CreateDirectory(path, 511))
                LogError("Failed to create directory %s", path);

        BuildPath(Path_SM, path, sizeof(path), "configs/deathmatch/spawns/workshop/%s/%s.txt", workshopID, workshop);
    }
    else
        BuildPath(Path_SM, path, sizeof(path), "configs/deathmatch/spawns/%s.txt", map);

    g_iSpawnPointCount = 0;

    /* Open file */
    File file = OpenFile(path, "r");
    if (file != null)
    {
        /* Read file */
        char buffer[256];
        char parts[6][16];
        while (!IsEndOfFile(file) && ReadFileLine(file, buffer, sizeof(buffer)))
        {
            ExplodeString(buffer, " ", parts, 6, 16);
            g_fSpawnPositions[g_iSpawnPointCount][0] = StringToFloat(parts[0]);
            g_fSpawnPositions[g_iSpawnPointCount][1] = StringToFloat(parts[1]);
            g_fSpawnPositions[g_iSpawnPointCount][2] = StringToFloat(parts[2]);
            g_fSpawnAngles[g_iSpawnPointCount][0] = StringToFloat(parts[3]);
            g_fSpawnAngles[g_iSpawnPointCount][1] = StringToFloat(parts[4]);
            g_fSpawnAngles[g_iSpawnPointCount][2] = StringToFloat(parts[5]);
            g_iSpawnPointCount++;
        }
    }
    /* Close file */
    delete file;
}

bool WriteMapConfig()
{
    char map[64];
    GetCurrentMap(map, sizeof(map));

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/deathmatch/spawns/%s.txt", map);

    /* Open file */
    File file = OpenFile(path, "w");
    if (file == null)
    {
        LogError("Could not open spawn point file \"%s\" for writing.", path);
        return false;
    }
    /* Write spawn points */
    for (int i = 0; i < g_iSpawnPointCount; i++)
        WriteFileLine(file, "%f %f %f %f %f %f", g_fSpawnPositions[i][0], g_fSpawnPositions[i][1], g_fSpawnPositions[i][2], g_fSpawnAngles[i][0], g_fSpawnAngles[i][1], g_fSpawnAngles[i][2]);
    /* Close file */
    delete file;

    return true;
}

public Action Event_Say(int client, const char[] command, int argc)
{
    static char menuTriggers[][] = { "gun", "!gun", "/gun", "guns", "!guns", "/guns", "menu", "!menu", "/menu", "weapon", "!weapon", "/weapon", "weapons", "!weapons", "/weapons" };
    static char hsOnlyTriggers[][] = { "hs", "!hs", "/hs", "headshot", "!headshot", "/headshot" };

    if (g_cvDM_enabled.BoolValue && IsValidClient(client) && (GetClientTeam(client) >= CS_TEAM_T))
    {
        /* Retrieve and clean up text. */
        char text[24];
        GetCmdArgString(text, sizeof(text));
        StripQuotes(text);
        TrimString(text);

        for (int i = 0; i < sizeof(menuTriggers); i++)
        {
            if (StrEqual(text, menuTriggers[i], false))
            {
                if (g_cvDM_gun_menu_mode.IntValue == 1 || g_cvDM_gun_menu_mode.IntValue == 2 || g_cvDM_gun_menu_mode.IntValue == 3)
                    DisplayOptionsMenu(client);
                else
                    CPrintToChat(client, "[\x04DM\x01] %t", "Guns Disabled");
                return Plugin_Handled;
            }
        }
        if (g_cvDM_headshot_only_allow_client.BoolValue)
        {
            for (int i = 0; i < sizeof(hsOnlyTriggers); i++)
            {
                if (StrEqual(text, hsOnlyTriggers[i], false))
                {
                    g_bHSOnlyClient[client] = !g_bHSOnlyClient[client];
                    char buffer[64];
                    char cEnable[32];
                    char cHSOnly[16];
                    cEnable = g_bHSOnlyClient[client] ? "Enabled" : "Disabled";
                    cHSOnly =  g_bHSOnlyClient[client] ? "1" : "0";
                    Format(buffer, sizeof(buffer), "HS Only Client %s", cEnable);
                    CPrintToChat(client, "[\x04DM\x01]  %t", buffer);
                    SetClientCookie(client, g_hHSOnly_Cookie, cHSOnly);
                    return Plugin_Handled;
                }
            }
        }
    }
    return Plugin_Continue;
}

void BuildWeaponMenuNames()
{
    g_smWeaponMenuNames = new StringMap();
    /* Primary weapons */
    g_smWeaponMenuNames.SetString("weapon_ak47", "AK-47");
    g_smWeaponMenuNames.SetString("weapon_m4a1", "M4A1");
    g_smWeaponMenuNames.SetString("weapon_m4a1_silencer", "M4A1-S");
    g_smWeaponMenuNames.SetString("weapon_sg556", "SG 553");
    g_smWeaponMenuNames.SetString("weapon_aug", "AUG");
    g_smWeaponMenuNames.SetString("weapon_galilar", "Galil AR");
    g_smWeaponMenuNames.SetString("weapon_famas", "FAMAS");
    g_smWeaponMenuNames.SetString("weapon_awp", "AWP");
    g_smWeaponMenuNames.SetString("weapon_ssg08", "SSG 08");
    g_smWeaponMenuNames.SetString("weapon_g3sg1", "G3SG1");
    g_smWeaponMenuNames.SetString("weapon_scar20", "SCAR-20");
    g_smWeaponMenuNames.SetString("weapon_m249", "M249");
    g_smWeaponMenuNames.SetString("weapon_negev", "Negev");
    g_smWeaponMenuNames.SetString("weapon_nova", "Nova");
    g_smWeaponMenuNames.SetString("weapon_xm1014", "XM1014");
    g_smWeaponMenuNames.SetString("weapon_sawedoff", "Sawed-Off");
    g_smWeaponMenuNames.SetString("weapon_mag7", "MAG-7");
    g_smWeaponMenuNames.SetString("weapon_mac10", "MAC-10");
    g_smWeaponMenuNames.SetString("weapon_mp9", "MP9");
    g_smWeaponMenuNames.SetString("weapon_mp7", "MP7");
	g_smWeaponMenuNames.SetString("weapon_mp5sd", "MP5SD");
    g_smWeaponMenuNames.SetString("weapon_ump45", "UMP-45");
    g_smWeaponMenuNames.SetString("weapon_p90", "P90");
    g_smWeaponMenuNames.SetString("weapon_bizon", "PP-Bizon");
    /* Secondary weapons */
    g_smWeaponMenuNames.SetString("weapon_glock", "Glock-18");
    g_smWeaponMenuNames.SetString("weapon_p250", "P250");
    g_smWeaponMenuNames.SetString("weapon_cz75a", "CZ75-A");
    g_smWeaponMenuNames.SetString("weapon_usp_silencer", "USP-S");
    g_smWeaponMenuNames.SetString("weapon_fiveseven", "Five-SeveN");
    g_smWeaponMenuNames.SetString("weapon_deagle", "Desert Eagle");
    g_smWeaponMenuNames.SetString("weapon_revolver", "R8");
    g_smWeaponMenuNames.SetString("weapon_elite", "Dual Berettas");
    g_smWeaponMenuNames.SetString("weapon_tec9", "Tec-9");
    g_smWeaponMenuNames.SetString("weapon_hkp2000", "P2000");
    /* Random */
    g_smWeaponMenuNames.SetString("random", "Random");
}

void InitialiseWeaponCounts()
{
    for (int i = 0; i < g_aPrimaryWeaponsAvailable.Length; i++)
    {
        char weapon[24];
        g_aPrimaryWeaponsAvailable.GetString(i, weapon, sizeof(weapon));
        g_smWeaponCounts.SetValue(weapon, 0);
    }
    for (int i = 0; i < g_aSecondaryWeaponsAvailable.Length; i++)
    {
        char weapon[24];
        g_aSecondaryWeaponsAvailable.GetString(i, weapon, sizeof(weapon));
        g_smWeaponCounts.SetValue(weapon, 0);
    }
}

void DisplayOptionsMenu(int client)
{
    int allowSameWeapons = (g_bRememberChoice[client]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
    Menu menu = new Menu(MenuHandler);
    menu.SetTitle("Weapon Menu:");
    menu.AddItem("New", "New weapons");
    menu.AddItem("Same", "Same weapons", allowSameWeapons);
    menu.AddItem("Random", "Random weapons");
    menu.ExitBackButton = false;
    menu.Display(client, MENU_TIME_FOREVER);
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        /* If the player joins spectator, close any open menu, and remove their ragdoll. */
        if ((client != 0) && (GetClientTeam(client) == CS_TEAM_SPECTATOR))
        {
            CancelClientMenu(client);
            RemoveRagdoll(client);
        }
        if (g_cvDM_enabled.BoolValue && g_cvDM_respawning.BoolValue)
            CreateTimer(g_cvDM_respawn_time.FloatValue, Timer_Respawn, GetClientSerial(client));
    }
}

public Action Event_RoundPrestart(Event event, const char[] name, bool dontBroadcast)
{
    g_bRoundEnded = false;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue)
    {
        if (g_cvDM_remove_objectives.BoolValue)
            RemoveHostages();

        if (g_cvDM_remove_weapons.BoolValue)
            RemoveGroundWeapons(INVALID_HANDLE);
    }
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    g_bRoundEnded = true;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && GetClientTeam(client) >= CS_TEAM_T)
        {
            if (!IsFakeClient(client))
            {
                if (g_cvDM_welcomemsg.BoolValue && !g_bInfoMessage[client])
                {
                    PrintHintText(client, "This server is running:\n <font color='#00FF00'>Deathmatch</font> v%s", PLUGIN_VERSION);
                    CPrintToChat(client, "[\x04DM\x01] This server is running \x04Deathmatch \x01v%s", PLUGIN_VERSION);
                }
                /* Hide radar. */
                if (g_cvDM_free_for_all.BoolValue || g_cvDM_hide_radar.BoolValue)
                {
                    RequestFrame(Frame_RemoveRadar, GetClientSerial(client));
                }
                /* Display help message. */
                if (!g_bInfoMessage[client])
                {
                    if (g_cvDM_headshot_only.BoolValue)
                        CPrintToChat(client, "[\x04DM\x01] %t", "HS Only");

                    if (g_cvDM_headshot_only_allow_client.BoolValue)
                        CPrintToChat(client, "[\x04DM\x01] %t", "HS Only Client");

                    if (g_cvDM_gun_menu_mode.IntValue <= 3)
                        CPrintToChat(client, "[\x04DM\x01] %t", "Guns Menu");

                    g_bInfoMessage[client] = true;
                }
                /* Display the panel for attacker information. */
                if (g_cvDM_display_panel.BoolValue)
                    g_hDamageDisplay[client] = CreateTimer(1.0, Timer_PanelDisplay, GetClientSerial(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
            }
            /* Teleport player to custom spawn point. */
            if (g_iSpawnPointCount > 0)
                MovePlayer(client);
            /* Enable player spawn protection. */
            if (g_cvDM_spawn_protection_time.FloatValue > 0.0)
                EnableSpawnProtection(client);
            /* Set health. */
            if (g_cvDM_hp_start.IntValue != 100)
                SetEntityHealth(client, g_cvDM_hp_start.IntValue);
            /* Give equipment */
            if (g_cvDM_armor.BoolValue)
            {
                SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
            }
            else if (g_cvDM_armor_full.BoolValue)
            {
                SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
            }
            else if (!g_cvDM_armor_full.BoolValue || !g_cvDM_armor.BoolValue)
            {
                SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
                SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
            }
            /* Give weapons or display menu. */
            g_bWeaponsGivenThisRound[client] = false;
            RemoveClientWeapons(client);
            if (!IsFakeClient(client))
            {
                char cRemember[24];
                GetClientCookie(client, g_hWeapon_Remember_Cookie, cRemember, sizeof(cRemember));
                g_bRememberChoice[client] = view_as<bool>(StringToInt(cRemember));
            }
            if (g_bRememberChoice[client] || IsFakeClient(client))
            {
                if (g_cvDM_gun_menu_mode.IntValue == 1 || g_cvDM_gun_menu_mode.IntValue == 4)
                    GiveSavedWeapons(client, true, true);
                /* Give only primary weapons if remembered. */
                else if (g_cvDM_gun_menu_mode.IntValue == 2)
                    GiveSavedWeapons(client, true, false)
                /* Give only secondary weapons if remembered. */
                else if (g_cvDM_gun_menu_mode.IntValue == 3)
                    GiveSavedWeapons(client, false, true);
            }
            /* Display the gun menu to new users. */
            else if (!IsFakeClient(client))
            {
                /* All weapons menu. */
                if (g_cvDM_gun_menu_mode.IntValue <= 3)
                    DisplayOptionsMenu(client);
            }
            /* Remove C4. */
            if (g_cvDM_remove_objectives.BoolValue)
                StripC4(client);
        }
    }
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue)
    {
        int victim = GetClientOfUserId(event.GetInt("userid"));
        int attacker = GetClientOfUserId(event.GetInt("attacker"));

        char weapon[32];
        event.GetString("weapon", weapon, sizeof(weapon));

        bool validAttacker = IsValidClient(attacker) && IsPlayerAlive(attacker);

        /* Reward the attacker with ammo. */
        if (validAttacker && g_cvDM_replenish_ammo_kill.BoolValue)
            RequestFrame(Frame_GiveAmmo, GetClientSerial(attacker));

        /* Reward attacker with HP. */
        if (validAttacker)
        {
            bool knifed = StrEqual(weapon, "knife");
            bool naded = StrEqual(weapon, "hegrenade");
            bool decoy = StrEqual(weapon, "decoy");
            bool inferno = StrEqual(weapon, "inferno");
            bool tactical = StrEqual(weapon, "tagrenade_projectile");
            bool headshot = event.GetBool("headshot");

            if ((knifed && (g_cvDM_hp_knife.IntValue > 0)) || (!knifed && (g_cvDM_hp_kill.IntValue > 0)) || (headshot && (g_cvDM_hp_headshot.IntValue > 0)) || (!headshot && (g_cvDM_hp_kill.IntValue > 0)))
            {
                int attackerHP = GetClientHealth(attacker);

                if (attackerHP < g_cvDM_hp_max.IntValue)
                {
                    int addHP;

                    if (knifed)
                        addHP = g_cvDM_hp_knife.IntValue;
                    else if (headshot)
                        addHP = g_cvDM_hp_headshot.IntValue;
                    else if (naded || decoy || inferno)
                        addHP = g_cvDM_hp_nade.IntValue;
                    else
                        addHP = g_cvDM_hp_kill.IntValue;

                    int newHP = attackerHP + addHP;

                    if (newHP > g_cvDM_hp_max.IntValue)
                        newHP = g_cvDM_hp_max.IntValue;

                    SetEntProp(attacker, Prop_Send, "m_iHealth", newHP, 1);
                }

                if (g_cvDM_hp_messages.BoolValue && !g_cvDM_ap_messages.BoolValue)
                {
                    if (attackerHP < g_cvDM_hp_max.IntValue)
                    {
                        if (knifed)
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_knife.IntValue, "HP Knife Kill");
                        else if (headshot)
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_headshot.IntValue, "HP Headshot Kill");
                        else if (naded || decoy || inferno)
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_nade.IntValue, "HP Nade Kill");
                        else 
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_kill.IntValue, "HP Kill");
                    }
                }
            }

            /* Reward attacker with AP. */
            if ((knifed && (g_cvDM_ap_knife.IntValue > 0)) || (!knifed && (g_cvDM_ap_kill.IntValue > 0)) || (headshot && (g_cvDM_ap_headshot.IntValue > 0)) || (!headshot && (g_cvDM_ap_kill.IntValue > 0)))
            {
                int attackerAP = GetClientArmor(attacker);

                if (attackerAP < g_cvDM_ap_max.IntValue)
                {
                    int addAP;

                    if (knifed)
                        addAP = g_cvDM_ap_knife.IntValue;
                    else if (headshot)
                        addAP = g_cvDM_ap_headshot.IntValue;
                    else if (naded || decoy || inferno)
                        addAP = g_cvDM_ap_nade.IntValue;
                    else
                        addAP = g_cvDM_ap_kill.IntValue;

                    int newAP = attackerAP + addAP;

                    if (newAP > g_cvDM_ap_max.IntValue)
                        newAP = g_cvDM_ap_max.IntValue;

                    SetEntProp(attacker, Prop_Send, "m_ArmorValue", newAP, 1);
                }

                if (g_cvDM_ap_messages.BoolValue && !g_cvDM_hp_messages.BoolValue)
                {
                    if (attackerAP < g_cvDM_ap_max.IntValue)
                    {
                        if (knifed)
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_knife.IntValue, "AP Knife Kill");
                        else if (headshot)
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_headshot.IntValue, "AP Headshot Kill");
                        else if (naded || decoy || inferno)
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_nade.IntValue, "AP Nade Kill");
                        else
                            CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_kill.IntValue, "AP Kill");
                    }
                }
            }

            if ((g_cvDM_hp_messages.BoolValue && g_cvDM_ap_messages.BoolValue))
            {
                int attackerAP = GetClientArmor(attacker);
                int attackerHP = GetClientHealth(attacker);
                bool bchanged = true;

                if (attackerAP < g_cvDM_ap_max.IntValue && attackerHP < g_cvDM_hp_max.IntValue)
                {
                    if (knifed)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 & \x04+%i AP\x01 %t", g_cvDM_hp_knife.IntValue, g_cvDM_ap_knife.IntValue, "HP Knife Kill", "AP Knife Kill");
                    else if (headshot)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 & \x04+%i AP\x01 %t", g_cvDM_hp_headshot.IntValue, g_cvDM_ap_headshot.IntValue, "HP Headshot Kill", "AP Headshot Kill");
                    else if (naded || decoy || inferno)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 & \x04+%i AP\x01 %t", g_cvDM_hp_nade.IntValue, g_cvDM_ap_nade.IntValue, "HP Nade Kill", "AP Nade Kill");
                    else
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 & \x04+%i AP\x01 %t", g_cvDM_hp_kill.IntValue, g_cvDM_ap_kill.IntValue, "HP Kill", "AP Kill");

                    bchanged = false;
                }
                else if (bchanged && attackerHP < g_cvDM_hp_max.IntValue)
                {
                    if (knifed)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_knife.IntValue, "HP Knife Kill");
                    else if (headshot)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_headshot.IntValue, "HP Headshot Kill");
                    else if (naded || decoy || inferno)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_nade.IntValue, "HP Nade Kill");
                    else 
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i HP\x01 %t", g_cvDM_hp_kill.IntValue, "HP Kill");

                    bchanged = false;
                }
                else if (bchanged && attackerAP < g_cvDM_ap_max.IntValue)
                {
                    if (knifed)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_knife.IntValue, "AP Knife Kill");
                    else if (headshot)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_headshot.IntValue, "AP Headshot Kill");
                    else if (naded || decoy || inferno)
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_nade.IntValue, "AP Nade Kill");
                    else
                        CPrintToChat(attacker, "[\x04DM\x01] \x04+%i AP\x01 %t", g_cvDM_ap_kill.IntValue, "AP Kill");
                }
            }

            if (g_cvDM_replenish_grenade_kill.BoolValue)
            {
                if (IsClientInGame(attacker) && IsPlayerAlive(attacker))
                {
                    if (naded)
                        GivePlayerItem(attacker, "weapon_hegrenade");

                    if (inferno)
                    {
                        int clientTeam = GetClientTeam(attacker);
                        if (clientTeam == CS_TEAM_CT)
                            GivePlayerItem(attacker, "weapon_incgrenade");

                        if (clientTeam == CS_TEAM_T)
                            GivePlayerItem(attacker, "weapon_molotov");
                    }

                    if (decoy)
                        GivePlayerItem(attacker, "weapon_decoy");

                    if (tactical)
                        GivePlayerItem(attacker, "weapon_tagrenade");
                }
            }
        }

        if (g_cvDM_respawning.BoolValue)
            CreateTimer(g_cvDM_respawn_time.FloatValue, Timer_Respawn, GetClientSerial(victim));
    }
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue)
    {
        if (g_cvDM_display_panel.BoolValue)
        {
            int victim = GetClientOfUserId(event.GetInt("userid"));
            int attacker = GetClientOfUserId(event.GetInt("attacker"));
            int health = event.GetInt("health");

            if (IsValidClient(attacker) && attacker != victim && victim != 0)
            {
                if (0 < health)
                {
                    if (g_cvDM_display_panel_damage.BoolValue)
                        PrintHintText(attacker, "%t <font color='#FF0000'>%i</font> %t <font color='#00FF00'>%N</font>\n %t <font color='#00FF00'>%i</font>", "Panel Damage Giver", event.GetInt("dmg_health"), "Panel Damage Taker", victim, "Panel Health Remaining", health);
                    else
                        PrintHintText(attacker, "%t <font color='#FF0000'>%i</font>", "Panel Health Remaining", health);
                }
                else
                    PrintHintText(attacker, "\n   %t", "Panel Kill Confirmed");
            }
        }

        int attacker = GetClientOfUserId(event.GetInt("attacker"));
        if (g_cvDM_headshot_only.BoolValue || (g_bHSOnlyClient[attacker] && g_cvDM_headshot_only_allow_client.BoolValue))
        {
            int victim = GetClientOfUserId(event.GetInt("userid"));
            int dhealth = event.GetInt("dmg_health");
            int darmor = event.GetInt("dmg_iArmor");
            int health = event.GetInt("health");
            int armor = event.GetInt("armor");
            char weapon[32];
            event.GetString("weapon", weapon, sizeof(weapon));

            if (!g_cvDM_headshot_only_allow_nade.BoolValue)
            {
                if (StrEqual(weapon, "hegrenade", false))
                {
                    if (attacker != victim && victim != 0)
                    {
                        if (dhealth > 0)
                            SetEntProp(victim, Prop_Send, "m_iHealth", (health + dhealth));

                        if (darmor > 0)
                            SetEntProp(victim, Prop_Send, "m_ArmorValue", (armor + darmor));

                    }
                }
            }

            if (!g_cvDM_headshot_only_allow_taser.BoolValue)
            {
                if (StrEqual(weapon, "taser", false))
                {
                    if (attacker != victim && victim != 0)
                    {
                        if (dhealth > 0)
                            SetEntProp(victim, Prop_Send, "m_iHealth", (health + dhealth));

                        if (darmor > 0)
                            SetEntProp(victim, Prop_Send, "m_ArmorValue", (armor + darmor));
                    }
                }
            }

            if (!g_cvDM_headshot_only_allow_knife.BoolValue)
            {
                if (StrEqual(weapon, "knife", false))
                {
                    if (attacker != victim && victim != 0)
                    {
                        if (dhealth > 0)
                            SetEntProp(victim, Prop_Send, "m_iHealth", (health + dhealth));

                        if (darmor > 0)
                            SetEntProp(victim, Prop_Send, "m_ArmorValue", (armor + darmor));
                    }
                }
            }

            if (!g_cvDM_headshot_only_allow_world.BoolValue)
            {
                if (victim !=0 && attacker == 0)
                {
                    if (dhealth > 0)
                        SetEntProp(victim, Prop_Send, "m_iHealth", (health + dhealth));

                    if (darmor > 0)
                        SetEntProp(victim, Prop_Send, "m_ArmorValue", (armor + darmor));
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action Event_WeaponFireOnEmpty(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_replenish_ammo_empty.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        RequestFrame(Frame_GiveAmmo, GetClientSerial(client));
    }
}

public Action Event_HegrenadeDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && (g_cvDM_replenish_grenade.BoolValue || g_cvDM_replenish_hegrenade.BoolValue))
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && IsPlayerAlive(client))
            GivePlayerItem(client, "weapon_hegrenade");
    }

    return Plugin_Continue;
}

public Action Event_SmokegrenadeDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_replenish_grenade.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && IsPlayerAlive(client))
            GivePlayerItem(client, "weapon_smokegrenade");
    }

    return Plugin_Continue;
}

public Action Event_FlashbangDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_replenish_grenade.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && IsPlayerAlive(client))
            GivePlayerItem(client, "weapon_flashbang");
    }

    return Plugin_Continue;
}

public Action Event_DecoyStarted(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_replenish_grenade.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && IsPlayerAlive(client))
            GivePlayerItem(client, "weapon_decoy");
    }

    return Plugin_Continue;
}

public Action Event_MolotovDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_replenish_grenade.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && IsPlayerAlive(client))
            GivePlayerItem(client, "weapon_molotov");
    }

    return Plugin_Continue;
}

public Action Event_InfernoStartburn(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_replenish_grenade.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && IsPlayerAlive(client))
            GivePlayerItem(client, "weapon_incgrenade");
    }

    return Plugin_Continue;
}

public Action OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
    if (!g_cvDM_enabled.BoolValue)
        return Plugin_Continue;

    if (g_cvDM_no_knife_damage.BoolValue)
    {
        char knife[32];
        GetClientWeapon(attacker, knife, sizeof(knife));
        if (StrEqual(knife, "weapon_knife") || StrEqual(knife, "weapon_bayonet"))
            return Plugin_Handled;
    }

    if (g_cvDM_headshot_only.BoolValue || (g_bHSOnlyClient[attacker] && g_cvDM_headshot_only_allow_client.BoolValue))
    {
        char weapon[32];
        char grenade[32];
        GetEdictClassname(inflictor, grenade, sizeof(grenade));
        GetClientWeapon(attacker, weapon, sizeof(weapon));

        if (hitgroup == 1)
            return Plugin_Continue;
        else if (g_cvDM_headshot_only_allow_knife.BoolValue && (StrEqual(weapon, "weapon_knife") || StrEqual(weapon, "weapon_bayonet")))
            return Plugin_Continue;
        else if (g_cvDM_headshot_only_allow_nade.BoolValue && (StrEqual(grenade, "hegrenade_projectile") || StrEqual(grenade, "decoy_projectile") || StrEqual(grenade, "molotov_projectile") || StrEqual(grenade, "tagrenade_projectile")))
            return Plugin_Continue;
        else if (g_cvDM_headshot_only_allow_taser.BoolValue && StrEqual(weapon, "weapon_taser"))
            return Plugin_Continue;
        else
            return Plugin_Handled;

    }

    return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!g_cvDM_enabled.BoolValue)
        return Plugin_Continue;

    if (g_cvDM_no_knife_damage.BoolValue)
    {
        if (IsValidClient(attacker))
        {
            char knife[32];
            GetClientWeapon(attacker, knife, sizeof(knife));

            if (StrEqual(knife, "weapon_knife") || StrEqual(knife, "weapon_bayonet"))
                return Plugin_Handled;
        }
    }

    if (g_cvDM_headshot_only.BoolValue || (g_bHSOnlyClient[attacker] && g_cvDM_headshot_only_allow_client.BoolValue))
    {
        char grenade[32];
        char weapon[32];

        if (IsValidClient(victim))
        {
            if (damagetype & DMG_FALL || attacker == 0)
            {
                if (g_cvDM_headshot_only_allow_world.BoolValue)
                    return Plugin_Continue;
                else
                    return Plugin_Handled;
            }

            if (IsValidClient(attacker))
            {
                GetEdictClassname(inflictor, grenade, sizeof(grenade));
                GetClientWeapon(attacker, weapon, sizeof(weapon));

                if (damagetype & DMG_HEADSHOT)
                    return Plugin_Continue;
                else
                {
                    if (g_cvDM_headshot_only_allow_knife.BoolValue && (StrEqual(weapon, "weapon_knife") || StrEqual(weapon, "weapon_bayonet")))
                        return Plugin_Continue;
                    else if (g_cvDM_headshot_only_allow_nade.BoolValue && (StrEqual(grenade, "hegrenade_projectile") || StrEqual(grenade, "decoy_projectile") || StrEqual(grenade, "molotov_projectile") || StrEqual(grenade, "tagrenade_projectile")))
                        return Plugin_Continue;
                    else if (g_cvDM_headshot_only_allow_taser.BoolValue && StrEqual(weapon, "weapon_taser"))
                        return Plugin_Continue;
                    return Plugin_Handled;
                }
            }
            else
                return Plugin_Handled;
        }
        else
            return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void OnReloadPost(int weapon, bool bSuccessful)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_replenish_ammo_reload.BoolValue)
    {
        int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
        if (IsValidEntity(client) && IsValidClient(client))
            RequestFrame(Frame_GiveAmmo, GetClientSerial(client));
    }
}

void RespawnAll()
{
    for (int i = 1; i <= MaxClients; i++)
        Timer_Respawn(INVALID_HANDLE, i);
}

public Action Timer_Respawn(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if (!g_bRoundEnded && IsValidClient(client) && (GetClientTeam(client) != CS_TEAM_SPECTATOR) && !IsPlayerAlive(client))
    {
        /* We set this here rather than in Event_PlayerSpawn to catch the spawn sounds which occur before Event_PlayerSpawn is called (even with EventHookMode_Pre). */
        g_bPlayerMoved[client] = false;
        CS_RespawnPlayer(client);
    }
}

public Action Timer_PanelDisplay(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if (IsValidClient(client) && IsPlayerAlive(client))
    {
        int aim = GetClientAimTarget(client, true);

        if (0 < aim)
        {
            PrintHintText(client, "%t %i", "Panel Health Remaining", GetClientHealth(aim));
            return Plugin_Continue;
        }
    }
    return Plugin_Stop;
}

public void Frame_FastSwitch(any serial)
{
    int client = GetClientFromSerial(serial);
    if (!IsValidClient(client) || !IsPlayerAlive(client))
        return;

    int sequence = 0;
    SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime());
    int viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");

    if (IsValidEntity(viewModel))
        SetEntProp(viewModel, Prop_Send, "m_nSequence", sequence);
}

public void Frame_RemoveRadar(any serial)
{
    int client = GetClientFromSerial(serial);
    if (IsValidClient(client) && IsPlayerAlive(client))
        SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_RADAR);
}

public void Frame_GiveAmmo(any serial)
{
    int weaponEntity;
    int client = GetClientFromSerial(serial)
    if (IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
    {
        switch (g_cvDM_replenish_ammo_type.IntValue)
        {
            case 1: 
            {
                weaponEntity = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
                if (weaponEntity != -1)
                    Ammo_ClipRefill(EntIndexToEntRef(weaponEntity), client);

                weaponEntity = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
                if (weaponEntity != -1)
                    Ammo_ClipRefill(EntIndexToEntRef(weaponEntity), client);
            }
            case 2: 
            {
                weaponEntity = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
                if (weaponEntity != -1)
                    Ammo_ResRefill(EntIndexToEntRef(weaponEntity), client);

                weaponEntity = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
                if (weaponEntity != -1)
                    Ammo_ResRefill(EntIndexToEntRef(weaponEntity), client);
            }
            case 3: 
            {
                weaponEntity = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
                if (weaponEntity != -1)
                    Ammo_FullRefill(EntIndexToEntRef(weaponEntity), client);

                weaponEntity = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
                if (weaponEntity != -1)
                    Ammo_FullRefill(EntIndexToEntRef(weaponEntity), client);
            }
        }
    }
}

void Ammo_ClipRefill(int weaponRef, any client)
{
    int weaponEntity = EntRefToEntIndex(weaponRef);
    if (IsValidEdict(weaponEntity))
    {
        char weaponName[64];
        char clipSize;
        char maxAmmoCount;

        if (GetEntityClassname(weaponEntity, weaponName, sizeof(weaponName)))
        {
            clipSize = GetWeaponAmmoCount(weaponName, true);
            maxAmmoCount = GetWeaponAmmoCount(weaponName, false);
            switch (GetEntProp(weaponRef, Prop_Send, "m_iItemDefinitionIndex"))
            {
                case 60: clipSize = 20;
                case 61: clipSize = 12;
                case 63: clipSize = 12;
                case 64: clipSize = 8;
            }
        }

        SetEntProp(client, Prop_Send, "m_iAmmo", maxAmmoCount);
        SetEntProp(weaponEntity, Prop_Send, "m_iClip1", clipSize);
    }
}

void Ammo_ResRefill(int weaponRef, any client)
{
    int weaponEntity = EntRefToEntIndex(weaponRef);
    if (IsValidEdict(weaponEntity))
    {
        char weaponName[64];
        char maxAmmoCount;
        int ammoType = GetEntProp(weaponEntity, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;

        if (GetEntityClassname(weaponEntity, weaponName, sizeof(weaponName)))
        {
            maxAmmoCount = GetWeaponAmmoCount(weaponName, false);
            switch (GetEntProp(weaponRef, Prop_Send, "m_iItemDefinitionIndex"))
            {
                case 60: maxAmmoCount = 40;
                case 61: maxAmmoCount = 24;
                case 63: maxAmmoCount = 12;
                case 64: maxAmmoCount = 8;
            }
        }

        SetEntData(client, g_iAmmoOffset + ammoType, maxAmmoCount, true);
    }
}

void Ammo_FullRefill(int weaponRef, any client)
{
    int weaponEntity = EntRefToEntIndex(weaponRef);
    if (IsValidEdict(weaponEntity))
    {
        char weaponName[35];
        char clipSize;
        int maxAmmoCount;
        int ammoType = GetEntProp(weaponEntity, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;

        if (GetEntityClassname(weaponEntity, weaponName, sizeof(weaponName)))
        {
            clipSize = GetWeaponAmmoCount(weaponName, true);
            maxAmmoCount = GetWeaponAmmoCount(weaponName, false);
            switch (GetEntProp(weaponRef, Prop_Send, "m_iItemDefinitionIndex"))
            {
                case 60: { clipSize = 20;maxAmmoCount = 60; }
                case 61: { clipSize = 12;maxAmmoCount = 24; }
                case 63: { clipSize = 12;maxAmmoCount = 12; }
                case 64: { clipSize = 8;maxAmmoCount = 8; }
            }
        }

        SetEntData(client, g_iAmmoOffset + ammoType, maxAmmoCount, true);
        SetEntProp(weaponEntity, Prop_Send, "m_iClip1", clipSize);
    }
}

int GetWeaponAmmoCount(char[] weaponName, bool currentClip)
{
    if (StrEqual(weaponName,  "weapon_ak47"))
        return currentClip ? 30 : 90;
    else if (StrEqual(weaponName,  "weapon_m4a1"))
        return currentClip ? 30 : 90;
    else if (StrEqual(weaponName,  "weapon_m4a1_silencer"))
        return currentClip ? 20 : 60;
    else if (StrEqual(weaponName,  "weapon_awp"))
        return currentClip ? 10 : 30;
    else if (StrEqual(weaponName,  "weapon_sg552"))
        return currentClip ? 30 : 90;
    else if (StrEqual(weaponName,  "weapon_aug"))
        return currentClip ? 30 : 90;
    else if (StrEqual(weaponName,  "weapon_p90"))
        return currentClip ? 50 : 100;
    else if (StrEqual(weaponName,  "weapon_galilar"))
        return currentClip ? 35 : 90;
    else if (StrEqual(weaponName,  "weapon_famas"))
        return currentClip ? 25 : 90;
    else if (StrEqual(weaponName,  "weapon_ssg08"))
        return currentClip ? 10 : 90;
    else if (StrEqual(weaponName,  "weapon_g3sg1"))
        return currentClip ? 20 : 90;
    else if (StrEqual(weaponName,  "weapon_scar20"))
        return currentClip ? 20 : 90;
    else if (StrEqual(weaponName,  "weapon_m249"))
        return currentClip ? 100 : 200;
    else if (StrEqual(weaponName,  "weapon_negev"))
        return currentClip ? 150 : 200;
    else if (StrEqual(weaponName,  "weapon_nova"))
        return currentClip ? 8 : 32;
    else if (StrEqual(weaponName,  "weapon_xm1014"))
        return currentClip ? 7 : 32;
    else if (StrEqual(weaponName,  "weapon_sawedoff"))
        return currentClip ? 7 : 32;
    else if (StrEqual(weaponName,  "weapon_mag7"))
        return currentClip ? 5 : 32;
    else if (StrEqual(weaponName,  "weapon_mac10"))
        return currentClip ? 30 : 100;
    else if (StrEqual(weaponName,  "weapon_mp9"))
        return currentClip ? 30 : 120;
    else if (StrEqual(weaponName,  "weapon_mp7"))
        return currentClip ? 30 : 120;
    else if (StrEqual(weaponName,  "weapon_ump45"))
        return currentClip ? 25 : 100;
    else if (StrEqual(weaponName,  "weapon_mp5sd"))
        return currentClip ? 30 : 120;
    else if (StrEqual(weaponName,  "weapon_bizon"))
        return currentClip ? 64 : 120;
    else if (StrEqual(weaponName,  "weapon_glock"))
        return currentClip ? 20 : 120;
    else if (StrEqual(weaponName,  "weapon_fiveseven"))
        return currentClip ? 20 : 100;
    else if (StrEqual(weaponName,  "weapon_deagle"))
        return currentClip ? 7 : 35;
    else if (StrEqual(weaponName,  "weapon_revolver"))
        return currentClip ? 8 : 8;
    else if (StrEqual(weaponName,  "weapon_hkp2000"))
        return currentClip ? 13 : 52;
    else if (StrEqual(weaponName,  "weapon_usp_silencer"))
        return currentClip ? 12 : 24;
    else if (StrEqual(weaponName,  "weapon_p250"))
        return currentClip ? 13 : 26;
    else if (StrEqual(weaponName,  "weapon_elite"))
        return currentClip ? 30 : 120;
    else if (StrEqual(weaponName,  "weapon_tec9"))
        return currentClip ? 24 : 120;
    else if (StrEqual(weaponName,  "weapon_cz75a"))
        return currentClip ? 12 : 12;
    return currentClip ? 30 : 90;
}

public void Event_BombPickup(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_remove_objectives.BoolValue)
    {
        int client = GetClientOfUserId(event.GetInt("userid"));
        StripC4(client);
    }
}

public int MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_Select)
    {
        char info[24];
        GetMenuItem(menu, param2, info, sizeof(info));
        SetClientCookie(param1, g_hWeapon_Remember_Cookie, "1");
        g_bRememberChoice[param1] = true;

        if (StrEqual(info, "New"))
        {
            if (g_cvDM_loadout_style.IntValue <= 1)
            {
                if (g_bWeaponsGivenThisRound[param1])
                    CPrintToChat(param1, "[\x04DM\x01] %t", "Guns New Spawn");
            }
            if (g_cvDM_gun_menu_mode.IntValue == 1 || g_cvDM_gun_menu_mode.IntValue == 2)
                BuildDisplayWeaponMenu(param1, true);
            else if (g_cvDM_gun_menu_mode.IntValue == 3)
                BuildDisplayWeaponMenu(param1, false);
        }
        else if (StrEqual(info, "Same"))
        {
            if (g_cvDM_loadout_style.IntValue <= 1)
            {
                if (g_bWeaponsGivenThisRound[param1])
                    CPrintToChat(param1, "[\x04DM\x01] %t", "Guns Same Spawn");
            }
            if (g_cvDM_gun_menu_mode.IntValue == 1 || g_cvDM_gun_menu_mode.IntValue == 4)
                GiveSavedWeapons(param1, true, true);
            else if (g_cvDM_gun_menu_mode.IntValue == 2)
                GiveSavedWeapons(param1, true, false);
            else if (g_cvDM_gun_menu_mode.IntValue == 3)
                GiveSavedWeapons(param1, false, true);
        }
        else if (StrEqual(info, "Random"))
        {
            if (g_cvDM_loadout_style.IntValue <= 1)
            {
                if (g_bWeaponsGivenThisRound[param1])
                    CPrintToChat(param1, "[\x04DM\x01] %t", "Guns Random Spawn");
            }
            if (g_cvDM_gun_menu_mode.IntValue == 1 || g_cvDM_gun_menu_mode.IntValue == 4)
            {
                g_cPrimaryWeapon[param1] = "random";
                g_cSecondaryWeapon[param1] = "random";
                GiveSavedWeapons(param1, true, true);
            }
            else if (g_cvDM_gun_menu_mode.IntValue == 2)
            {
                g_cPrimaryWeapon[param1] = "random";
                g_cSecondaryWeapon[param1] = "none";
                GiveSavedWeapons(param1, true, false);
            }
            else if (g_cvDM_gun_menu_mode.IntValue == 3)
            {
                g_cPrimaryWeapon[param1] = "none";
                g_cSecondaryWeapon[param1] = "random";
                GiveSavedWeapons(param1, false, true);
            }
        }
    }
}

public int MenuPrimary(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char info[24];
        GetMenuItem(menu, param2, info, sizeof(info));
        int weaponCount;
        g_smWeaponCounts.GetValue(info, weaponCount);
        int weaponLimit;
        g_smWeaponLimits.GetValue(info, weaponLimit);

        if ((weaponLimit == -1) || (weaponCount < weaponLimit))
        {
            IncrementWeaponCount(info);
            DecrementWeaponCount(g_cPrimaryWeapon[param1]);
            g_cPrimaryWeapon[param1] = info;
            GiveSavedWeapons(param1, true, false);
            if (g_cvDM_gun_menu_mode.IntValue != 2)
                BuildDisplayWeaponMenu(param1, false)
            else
            {
                DecrementWeaponCount(g_cSecondaryWeapon[param1]);
                g_cSecondaryWeapon[param1] = "none";
                GiveSavedWeapons(param1, false, true);
                SetClientCookie(param1, g_hWeapon_First_Cookie, "0");
                g_bFirstWeaponSelection[param1] = false;
            }
        }
        else
        {
            DecrementWeaponCount(g_cPrimaryWeapon[param1]);
            g_cPrimaryWeapon[param1] = "none";
            GiveSavedWeapons(param1, true, false);
            if (g_cvDM_gun_menu_mode.IntValue != 2)
                BuildDisplayWeaponMenu(param1, false);
            else
            {
                DecrementWeaponCount(g_cSecondaryWeapon[param1]);
                g_cSecondaryWeapon[param1] = "none";
                GiveSavedWeapons(param1, false, true);
                SetClientCookie(param1, g_hWeapon_First_Cookie, "0");
                g_bFirstWeaponSelection[param1] = false;
            }
        }
    }
    else if (action == MenuAction_Cancel)
    {
        if (param2 == MenuCancel_Exit)
        {
            DecrementWeaponCount(g_cPrimaryWeapon[param1]);
            g_cPrimaryWeapon[param1] = "none";
            GiveSavedWeapons(param1, true, false);
            if (g_cvDM_gun_menu_mode.IntValue != 2)
                BuildDisplayWeaponMenu(param1, false);
        }
    }
}

public int MenuSecondary(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char info[24];
        GetMenuItem(menu, param2, info, sizeof(info));
        IncrementWeaponCount(info);
        DecrementWeaponCount(g_cSecondaryWeapon[param1]);
        g_cSecondaryWeapon[param1] = info;
        GiveSavedWeapons(param1, false, true);
        SetClientCookie(param1, g_hWeapon_First_Cookie, "0");
        g_bFirstWeaponSelection[param1] = false;
    }
    else if (action == MenuAction_Cancel)
    {
        if (param2 == MenuCancel_Exit)
        {
            if ((param1 > 0) && (param1 <= MaxClients) && IsClientInGame(param1))
            {
                DecrementWeaponCount(g_cSecondaryWeapon[param1]);
                g_cSecondaryWeapon[param1] = "none";
                GiveSavedWeapons(param1, false, true);
                SetClientCookie(param1, g_hWeapon_First_Cookie, "0");
                g_bFirstWeaponSelection[param1] = false;
            }
        }
    }
}

void GiveSavedWeapons(int client, bool primary, bool secondary)
{
    if (g_cvDM_loadout_style.IntValue >= 2 && IsPlayerAlive(client))
        RemoveClientWeapons(client, primary, secondary);
    if (IsFakeClient(client))
        SetClientGunModeSettings(client);

    if (g_cvDM_loadout_style.IntValue >= 2)
        g_bWeaponsGivenThisRound[client] = false;

    if (!g_bWeaponsGivenThisRound[client])
    {
        if (primary && !StrEqual(g_cPrimaryWeapon[client], "none"))
        {
            if (StrEqual(g_cPrimaryWeapon[client], "random"))
            {
                /* Select random menu item (excluding "Random" option) */
                int random = GetRandomInt(0, g_aPrimaryWeaponsAvailable.Length - 2);
                char randomWeapon[24];
                g_aPrimaryWeaponsAvailable.GetString(random, randomWeapon, sizeof(randomWeapon));
                GiveSkinnedWeapon(client, randomWeapon);
                if (!IsFakeClient(client))
                    SetClientCookie(client, g_hWeapon_Primary_Cookie, "random");
            }
            else
            {
                GiveSkinnedWeapon(client, g_cPrimaryWeapon[client]);
                if (!IsFakeClient(client))
                    SetClientCookie(client, g_hWeapon_Primary_Cookie, g_cPrimaryWeapon[client]);
            }
        }
        if (secondary)
        {
            if (!StrEqual(g_cSecondaryWeapon[client], "none"))
            {
                int entityIndex = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
                if (entityIndex != -1)
                {
                    RemovePlayerItem(client, entityIndex);
                    AcceptEntityInput(entityIndex, "Kill");
                }
                if (StrEqual(g_cSecondaryWeapon[client], "random"))
                {
                    /* Select random menu item (excluding "Random" option) */
                    int random = GetRandomInt(0, g_aSecondaryWeaponsAvailable.Length - 2);
                    char randomWeapon[24];
                    g_aSecondaryWeaponsAvailable.GetString(random, randomWeapon, sizeof(randomWeapon));
                    GiveSkinnedWeapon(client, randomWeapon);
                    if (!IsFakeClient(client))
                        SetClientCookie(client, g_hWeapon_Secondary_Cookie, "random");
                }
                else
                {
                    GiveSkinnedWeapon(client, g_cSecondaryWeapon[client]);
                    if (!IsFakeClient(client))
                        SetClientCookie(client, g_hWeapon_Secondary_Cookie, g_cSecondaryWeapon[client]);
                }
                GivePlayerItem(client, "weapon_knife");
            }
            if (g_cvDM_zeus.BoolValue)
                GivePlayerItem(client, "weapon_taser");
            int clientTeam = GetClientTeam(client);
            for (int i = 0; i < g_cvDM_nades_incendiary.IntValue; i++)
            {
                if (clientTeam == CS_TEAM_CT)
                    GivePlayerItem(client, "weapon_incgrenade");
            }
            for (int i = 0; i < g_cvDM_nades_molotov.IntValue; i++)
            {
                if (clientTeam == CS_TEAM_T)
                    GivePlayerItem(client, "weapon_molotov");
            }
            for (int i = 0; i < g_cvDM_nades_decoy.IntValue; i++)
                GivePlayerItem(client, "weapon_decoy");
            for (int i = 0; i < g_cvDM_nades_flashbang.IntValue; i++)
                GivePlayerItem(client, "weapon_flashbang");
            for (int i = 0; i < g_cvDM_nades_he.IntValue; i++)
                GivePlayerItem(client, "weapon_hegrenade");
            for (int i = 0; i < g_cvDM_nades_smoke.IntValue; i++)
                GivePlayerItem(client, "weapon_smokegrenade");
            for (int i = 0; i < g_cvDM_nades_tactical.IntValue; i++)
                GivePlayerItem(client, "weapon_tagrenade");
            if (g_cvDM_loadout_style.IntValue <= 1)
                g_bWeaponsGivenThisRound[client] = true;
            else if (g_cvDM_loadout_style.IntValue >= 2)
                g_bWeaponsGivenThisRound[client] = false;
            g_bRememberChoice[client] = true;
            if (!IsFakeClient(client))
            {
                int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
                int iSecondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

                if (iPrimary != -1)
                        SDKHook(iPrimary, SDKHook_ReloadPost, OnReloadPost);

                if (iSecondary != -1)
                        SDKHook(iSecondary, SDKHook_ReloadPost, OnReloadPost);

                SetClientCookie(client, g_hWeapon_Remember_Cookie, "1");
            }
        }
    }
}

void RemoveClientWeapons(int client, bool primary = true, bool secondary = false)
{
    if (IsValidClient(client) && IsPlayerAlive(client))
    {
        int weapon;
        if (primary)
            weapon = 0;
        else if (secondary)
            weapon = 1;
        else
            weapon = 1;

        FakeClientCommand(client, "use weapon_knife");
        for (int i = weapon; i < 4; i++)
        {
            if (i == 2) continue; /* Keep knife. */
            int entityIndex;
            while ((entityIndex = GetPlayerWeaponSlot(client, i)) != -1)
            {
                RemovePlayerItem(client, entityIndex);
                AcceptEntityInput(entityIndex, "Kill");
            }
        }
    }
}

public Action RemoveGroundWeapons(Handle timer)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_remove_weapons.BoolValue)
    {
        int maxEntities = GetMaxEntities();
        char class[24];

        for (int i = MaxClients + 1; i < maxEntities; i++)
        {
            if (IsValidEdict(i) && HasEntProp(i, Prop_Send, "m_hOwnerEntity") && (GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == -1))
            {
                GetEdictClassname(i, class, sizeof(class));
                if ((StrContains(class, "weapon_") != -1) || (StrContains(class, "item_") != -1))
                {
                    if (StrEqual(class, "weapon_c4"))
                    {
                        if (!g_cvDM_remove_objectives.BoolValue)
                            continue;
                    }
                    AcceptEntityInput(i, "Kill");
                }
            }
        }
    }
    return Plugin_Continue;
}

void SetBuyZones(const char[] status)
{
    int maxEntities = GetMaxEntities();
    char class[24];

    for (int i = MaxClients + 1; i < maxEntities; i++)
    {
        if (IsValidEdict(i))
        {
            GetEdictClassname(i, class, sizeof(class));
            if (StrEqual(class, "func_buyzone"))
                AcceptEntityInput(i, status);
        }
    }
}

void SetObjectives(const char[] status)
{
    int maxEntities = GetMaxEntities();
    char class[24];

    for (int i = MaxClients + 1; i < maxEntities; i++)
    {
        if (IsValidEdict(i))
        {
            GetEdictClassname(i, class, sizeof(class));
            if (StrEqual(class, "func_bomb_target") || StrEqual(class, "func_hostage_rescue"))
                AcceptEntityInput(i, status);
        }
    }
}

void RemoveC4()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (StripC4(i))
            break;
    }
}

bool StripC4(int client)
{
    if (IsValidClient(client) && IsPlayerAlive(client))
    {
        int c4Index = GetPlayerWeaponSlot(client, CS_SLOT_C4);
        if (c4Index != -1)
        {
            char weapon[24];
            GetClientWeapon(client, weapon, sizeof(weapon));
            /* If the player is holding C4, switch to the best weapon before removing it. */
            if (StrEqual(weapon, "weapon_c4"))
            {
                if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
                    ClientCommand(client, "slot1");
                else if (GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
                    ClientCommand(client, "slot2");
                else
                    ClientCommand(client, "slot3");
            }
            RemovePlayerItem(client, c4Index);
            AcceptEntityInput(c4Index, "Kill");
            return true;
        }
    }
    return false;
}

void RemoveHostages()
{
    int maxEntities = GetMaxEntities();
    char class[24];

    for (int i = MaxClients + 1; i < maxEntities; i++)
    {
        if (IsValidEdict(i))
        {
            GetEdictClassname(i, class, sizeof(class));
            if (StrEqual(class, "hostage_entity"))
                AcceptEntityInput(i, "Kill");
        }
    }
}

void EnableSpawnProtection(int client)
{
    int clientTeam = GetClientTeam(client);
    /* Disable damage */
    SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
    /* Set player color */
    if (clientTeam == CS_TEAM_T)
        SetPlayerColor(client, g_iColorT);
    else if (clientTeam == CS_TEAM_CT)
        SetPlayerColor(client, g_iColorCT);
    /* Create timer to remove spawn protection */
    CreateTimer(g_cvDM_spawn_protection_time.FloatValue, DisableSpawnProtection, client);
}

public Action DisableSpawnProtection(Handle timer, any client)
{
    if (IsValidClient(client) && (GetClientTeam(client) != CS_TEAM_SPECTATOR) && IsPlayerAlive(client))
    {
        /* Enable damage */
        SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
        /* Set player color */
        SetPlayerColor(client, g_iDefaultColor);
    }
}

void SetPlayerColor(int client, const int color[4])
{
    SetEntityRenderMode(client, (color[3] == 255) ? RENDER_NORMAL : RENDER_TRANSCOLOR);
    SetEntityRenderColor(client, color[0], color[1], color[2], color[3]);
}

public Action Command_RespawnAll(int client, int args)
{
    if (client == 0)
    {
        RespawnAll();
        ReplyToCommand(client, "[DM] All players have been respawned.");
        return Plugin_Handled;
    }

    RespawnAll();
    CPrintToChat(client, "[\x04DM\x01] All players have been respawned.");
    return Plugin_Handled;
}

void BuildSpawnEditorMenu(int client)
{
    Menu menu = new Menu(MenuSpawnEditor);
    menu.SetTitle("Spawn Point Editor:");
    menu.ExitButton = true
    char editModeItem[24];
    Format(editModeItem, sizeof(editModeItem), "%s Edit Mode", (!g_bInEditMode) ? "Enable" : "Disable");
    menu.AddItem("Edit", editModeItem);
    menu.AddItem("Nearest", "Teleport to nearest");
    menu.AddItem("Previous", "Teleport to previous");
    menu.AddItem("Next", "Teleport to next");
    menu.AddItem("Add", "Add position");
    menu.AddItem("Insert", "Insert position here");
    menu.AddItem("Delete", "Delete nearest");
    menu.AddItem("Delete All", "Delete all");
    menu.AddItem("Save", "Save Configuration");
    menu.Display(client, MENU_TIME_FOREVER);
}

public Action Command_SpawnMenu(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "[SM] %t", "Command is in-game only");
        return Plugin_Handled;
    }

    BuildSpawnEditorMenu(client);
    return Plugin_Handled;
}

public int MenuSpawnEditor(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char info[24];
        GetMenuItem(menu, param2, info, sizeof(info));

        if (StrEqual(info, "Edit"))
        {
            g_bInEditMode = !g_bInEditMode;
            if (g_bInEditMode)
            {
                CreateTimer(1.0, RenderSpawnPoints, INVALID_HANDLE, TIMER_REPEAT);
                CPrintToChat(param1, "[\x04DM\x01] %t", "Spawn Editor Enabled");
            }
            else
                CPrintToChat(param1, "[\x04DM\x01] %t", "Spawn Editor Disabled");
        }
        else if (StrEqual(info, "Nearest"))
        {
            int spawnPoint = GetNearestSpawn(param1);
            if (spawnPoint != -1)
            {
                TeleportEntity(param1, g_fSpawnPositions[spawnPoint], g_fSpawnAngles[spawnPoint], NULL_VECTOR);
                g_iLastEditorSpawnPoint[param1] = spawnPoint;
                CPrintToChat(param1, "[\x04DM\x01] %t #%i (%i total).", "Spawn Editor Teleported", spawnPoint + 1, g_iSpawnPointCount);
            }
        }
        else if (StrEqual(info, "Previous"))
        {
            if (g_iSpawnPointCount == 0)
                CPrintToChat(param1, "[\x04DM\x01] %t", "Spawn Editor No Spawn");
            else
            {
                int spawnPoint = g_iLastEditorSpawnPoint[param1] - 1;
                if (spawnPoint < 0)
                    spawnPoint = g_iSpawnPointCount - 1;

                TeleportEntity(param1, g_fSpawnPositions[spawnPoint], g_fSpawnAngles[spawnPoint], NULL_VECTOR);
                g_iLastEditorSpawnPoint[param1] = spawnPoint;
                CPrintToChat(param1, "[\x04DM\x01] %t #%i (%i total).", "Spawn Editor Teleported", spawnPoint + 1, g_iSpawnPointCount);
            }
        }
        else if (StrEqual(info, "Next"))
        {
            if (g_iSpawnPointCount == 0)
                CPrintToChat(param1, "[\x04DM\x01] %t", "Spawn Editor No Spawn");
            else
            {
                int spawnPoint = g_iLastEditorSpawnPoint[param1] + 1;
                if (spawnPoint >= g_iSpawnPointCount)
                    spawnPoint = 0;

                TeleportEntity(param1, g_fSpawnPositions[spawnPoint], g_fSpawnAngles[spawnPoint], NULL_VECTOR);
                g_iLastEditorSpawnPoint[param1] = spawnPoint;
                CPrintToChat(param1, "[\x04DM\x01] %t #%i (%i total).", "Spawn Editor Teleported", spawnPoint + 1, g_iSpawnPointCount);
            }
        }
        else if (StrEqual(info, "Add"))
        {
            AddSpawn(param1);
        }
        else if (StrEqual(info, "Insert"))
        {
            InsertSpawn(param1);
        }
        else if (StrEqual(info, "Delete"))
        {
            int spawnPoint = GetNearestSpawn(param1);
            if (spawnPoint != -1)
            {
                DeleteSpawn(spawnPoint);
                CPrintToChat(param1, "[\x04DM\x01] %t #%i (%i total).", "Spawn Editor Deleted Spawn", spawnPoint + 1, g_iSpawnPointCount);
            }
        }
        else if (StrEqual(info, "Delete All"))
        {
            Panel panel = new Panel();
            panel.SetTitle("Delete all spawn points?");
            panel.DrawItem("Yes");
            panel.DrawItem("No");
            panel.Send(param1, PanelConfirmDeleteAllSpawns, MENU_TIME_FOREVER);
            delete panel;
        }
        else if (StrEqual(info, "Save"))
        {
            if (WriteMapConfig())
                CPrintToChat(param1, "[\x04DM\x01] %t", "Spawn Editor Config Saved");
            else
                CPrintToChat(param1, "[\x04DM\x01] %t", "Spawn Editor Config Not Saved");
        }
        if (!StrEqual(info, "Delete All"))
            BuildSpawnEditorMenu(param1);
    }
    else if (action == MenuAction_End)
        delete menu;
}

public int PanelConfirmDeleteAllSpawns(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        if (param2 == 1)
        {
            g_iSpawnPointCount = 0;
            CPrintToChat(param1, "[\x04DM\x01] %t", "Spawn Editor Deleted All");
        }
        BuildSpawnEditorMenu(param1);
    }
}

public Action RenderSpawnPoints(Handle timer)
{
    if (!g_bInEditMode)
        return Plugin_Stop;

    for (int i = 0; i < g_iSpawnPointCount; i++)
    {
        float spawnPosition[3];
        AddVectors(g_fSpawnPositions[i], g_fSpawnPointOffset, spawnPosition);
        TE_SetupGlowSprite(spawnPosition, g_iGlowSprite, 1.0, 0.5, 255);
        TE_SendToAll();
    }
    return Plugin_Continue;
}

int GetNearestSpawn(int client)
{
    if (g_iSpawnPointCount == 0)
    {
        CPrintToChat(client, "[\x04DM\x01] %t", "Spawn Editor No Spawn");
        return -1;
    }

    float clientPosition[3];
    GetClientAbsOrigin(client, clientPosition);

    int nearestPoint = 0;
    float nearestPointDistance = GetVectorDistance(g_fSpawnPositions[0], clientPosition, true);

    for (int i = 1; i < g_iSpawnPointCount; i++)
    {
        float distance = GetVectorDistance(g_fSpawnPositions[i], clientPosition, true);
        if (distance < nearestPointDistance)
        {
            nearestPoint = i;
            nearestPointDistance = distance;
        }
    }
    return nearestPoint;
}

void AddSpawn(int client)
{
    if (g_iSpawnPointCount >= MAX_SPAWNS)
    {
        CPrintToChat(client, "[\x04DM\x01] %t", "Spawn Editor Spawn Not Added");
        return;
    }
    GetClientAbsOrigin(client, g_fSpawnPositions[g_iSpawnPointCount]);
    GetClientAbsAngles(client, g_fSpawnAngles[g_iSpawnPointCount]);
    g_iSpawnPointCount++;
    CPrintToChat(client, "[\x04DM\x01] %t", "Spawn Editor Spawn Added", g_iSpawnPointCount, g_iSpawnPointCount);
}

void InsertSpawn(int client)
{
    if (g_iSpawnPointCount >= MAX_SPAWNS)
    {
        CPrintToChat(client, "[\x04DM\x01] %t", "Spawn Editor Spawn Not Added");
        return;
    }

    if (g_iSpawnPointCount == 0)
        AddSpawn(client);
    else
    {
        /* Move spawn points down the list to make room for insertion. */
        for (int i = g_iSpawnPointCount - 1; i >= g_iLastEditorSpawnPoint[client]; i--)
        {
            g_fSpawnPositions[i + 1] = g_fSpawnPositions[i];
            g_fSpawnAngles[i + 1] = g_fSpawnAngles[i];
        }
        /* Insert new spawn point. */
        GetClientAbsOrigin(client, g_fSpawnPositions[g_iLastEditorSpawnPoint[client]]);
        GetClientAbsAngles(client, g_fSpawnAngles[g_iLastEditorSpawnPoint[client]]);
        g_iSpawnPointCount++;
        CPrintToChat(client, "[\x04DM\x01] %t #%i (%i total).", "Spawn Editor Spawn Inserted", g_iLastEditorSpawnPoint[client] + 1, g_iSpawnPointCount);
    }
}

void DeleteSpawn(int spawnIndex)
{
    for (int i = spawnIndex; i < (g_iSpawnPointCount - 1); i++)
    {
        g_fSpawnPositions[i] = g_fSpawnPositions[i + 1];
        g_fSpawnAngles[i] = g_fSpawnAngles[i + 1];
    }
    g_iSpawnPointCount--;
}

/* Updates the occupation status of all spawn points. */
public Action UpdateSpawnPointStatus(Handle timer)
{
    if (g_cvDM_enabled.BoolValue && (g_iSpawnPointCount > 0))
    {
        /* Retrieve player positions. */
        float playerPositions[MAXPLAYERS+1][3];
        int numberOfAlivePlayers = 0;

        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && (GetClientTeam(i) != CS_TEAM_SPECTATOR) && IsPlayerAlive(i))
            {
                GetClientAbsOrigin(i, playerPositions[numberOfAlivePlayers]);
                numberOfAlivePlayers++;
            }
        }

        /* Check each spawn point for occupation by proximity to alive players */
        for (int i = 0; i < g_iSpawnPointCount; i++)
        {
            g_bSpawnPointOccupied[i] = false;
            for (int j = 0; j < numberOfAlivePlayers; j++)
            {
                float distance = GetVectorDistance(g_fSpawnPositions[i], playerPositions[j], true);
                if (distance < 10000.0)
                {
                    g_bSpawnPointOccupied[i] = true;
                    break;
                }
            }
        }
    }
    return Plugin_Continue;
}

void MovePlayer(int client)
{
    g_iNumberOfPlayerSpawns++; /* Stats */

    int clientTeam = GetClientTeam(client);

    int spawnPoint;
    bool spawnPointFound = false;

    float enemyEyePositions[MAXPLAYERS+1][3];
    int numberOfEnemies = 0;

    /* Retrieve enemy positions if required by LoS/distance spawning (at eye level for LoS checking). */
    if (g_cvDM_los_spawning.BoolValue || (g_cvDM_spawn_distance.FloatValue > 0.0))
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && (GetClientTeam(i) != CS_TEAM_SPECTATOR) && IsPlayerAlive(i))
            {
                bool enemy = (g_cvDM_free_for_all.BoolValue || (GetClientTeam(i) != clientTeam));
                if (enemy)
                {
                    GetClientEyePosition(i, enemyEyePositions[numberOfEnemies]);
                    numberOfEnemies++;
                }
            }
        }
    }

    if (g_cvDM_los_spawning.BoolValue)
    {
        g_iLosSearchAttempts++; /* Stats */

        /* Try to find a suitable spawn point with a clear line of sight. */
        for (int i = 0; i < g_cvDM_los_attempts.IntValue; i++)
        {
            spawnPoint = GetRandomInt(0, g_iSpawnPointCount - 1);

            if (g_bSpawnPointOccupied[spawnPoint])
                continue;

            if (g_cvDM_spawn_distance.FloatValue > 0.0)
            {
                if (!IsPointSuitableDistance(spawnPoint, enemyEyePositions, numberOfEnemies))
                    continue;
            }

            float spawnPointEyePosition[3];
            AddVectors(g_fSpawnPositions[spawnPoint], g_fEyeOffset, spawnPointEyePosition);

            bool hasClearLineOfSight = true;

            for (int j = 0; j < numberOfEnemies; j++)
            {
                Handle trace = TR_TraceRayFilterEx(spawnPointEyePosition, enemyEyePositions[j], MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, TraceEntityFilterPlayer);
                if (!TR_DidHit(trace))
                {
                    hasClearLineOfSight = false;
                    CloseHandle(trace);
                    break;
                }
                CloseHandle(trace);
            }
            if (hasClearLineOfSight)
            {
                spawnPointFound = true;
                break;
            }
        }
        /* Stats */
        if (spawnPointFound)
            g_iLosSearchSuccesses++;
        else
            g_iLosSearchFailures++;
    }

    /* First fallback. Find a random unccupied spawn point at a suitable distance. */
    if (!spawnPointFound && (g_cvDM_spawn_distance.FloatValue > 0.0))
    {
        g_iDistanceSearchAttempts++; /* Stats */

        for (int i = 0; i < 100; i++)
        {
            spawnPoint = GetRandomInt(0, g_iSpawnPointCount - 1);
            if (g_bSpawnPointOccupied[spawnPoint])
                continue;

            if (!IsPointSuitableDistance(spawnPoint, enemyEyePositions, numberOfEnemies))
                continue;

            spawnPointFound = true;
            break;
        }
        /* Stats */
        if (spawnPointFound)
            g_iDistanceSearchSuccesses++;
        else
            g_iDistanceSearchFailures++;
    }

    /* Final fallback. Find a random unoccupied spawn point. */
    if (!spawnPointFound)
    {
        for (int i = 0; i < 100; i++)
        {
            spawnPoint = GetRandomInt(0, g_iSpawnPointCount - 1);
            if (!g_bSpawnPointOccupied[spawnPoint])
            {
                spawnPointFound = true;
                break;
            }
        }
    }

    if (spawnPointFound)
    {
        TeleportEntity(client, g_fSpawnPositions[spawnPoint], g_fSpawnAngles[spawnPoint], NULL_VECTOR);
        g_bSpawnPointOccupied[spawnPoint] = true;
        g_bPlayerMoved[client] = true;
    }

    if (!spawnPointFound) g_iSpawnPointSearchFailures++; /* Stats */
}

bool IsPointSuitableDistance(int spawnPoint, float[][3] enemyEyePositions, int numberOfEnemies)
{
    for (int i = 0; i < numberOfEnemies; i++)
    {
        float distance = GetVectorDistance(g_fSpawnPositions[spawnPoint], enemyEyePositions[i], true);
        if (distance < g_cvDM_spawn_distance.FloatValue)
            return false;
    }
    return true;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
    if ((entity > 0) && (entity <= MaxClients)) return false;
    return true;
}

public Action Command_Stats(int client, int args)
{
    if (client == 0)
    {
        DisplaySpawnStats(client, true);
        return Plugin_Handled;
    }

    DisplaySpawnStats(client, false);
    return Plugin_Handled;
}

public Action Command_ResetStats(int client, int args)
{
    if (client == 0)
    {
        ResetSpawnStats();
        ReplyToCommand(client, "[DM] Spawn statistics have been reset.");
        return Plugin_Handled;
    }

    ResetSpawnStats();
    CPrintToChat(client, "[\x04DM\x01] Spawn statistics have been reset.");
    return Plugin_Handled;
}

void ResetSpawnStats()
{
    g_iNumberOfPlayerSpawns = 0;
    g_iLosSearchAttempts = 0;
    g_iLosSearchSuccesses = 0;
    g_iLosSearchFailures = 0;
    g_iDistanceSearchAttempts = 0;
    g_iDistanceSearchSuccesses = 0;
    g_iDistanceSearchFailures = 0;
    g_iSpawnPointSearchFailures = 0;
}

void DisplaySpawnStats(int client, bool console)
{
    char text[64];
    if (console)
    {
        PrintToServer("////////////////////////////////////////////////////////////////");
        PrintToServer("Spawn Stats:");
        Format(text, sizeof(text), "- Number of player spawns: %i", g_iNumberOfPlayerSpawns);
        PrintToServer("%s", text);
        Format(text, sizeof(text), "- LoS search success rate: %.2f\%", (float(g_iLosSearchSuccesses) / float(g_iLosSearchAttempts)) * 100);
        PrintToServer("%s", text);
        Format(text, sizeof(text), "- LoS search failure rate: %.2f\%", (float(g_iLosSearchFailures) / float(g_iLosSearchAttempts)) * 100);
        PrintToServer("%s", text);
        Format(text, sizeof(text), "- Distance search success rate: %.2f\%", (float(g_iDistanceSearchSuccesses) / float(g_iDistanceSearchAttempts)) * 100);
        PrintToServer("%s", text);
        Format(text, sizeof(text), "- Distance search failure rate: %.2f\%", (float(g_iDistanceSearchFailures) / float(g_iDistanceSearchAttempts)) * 100);
        PrintToServer("%s", text);
        Format(text, sizeof(text), "- Spawn point search failures: %i", g_iSpawnPointSearchFailures);
        PrintToServer("%s", text);
        PrintToServer("////////////////////////////////////////////////////////////////");
    }
    else
    {
        Panel panel = new Panel();
        panel.SetTitle("Spawn Stats:");
        Format(text, sizeof(text), "- Number of player spawns: %i", g_iNumberOfPlayerSpawns);
        panel.DrawText(text);
        Format(text, sizeof(text), "- LoS search success rate: %.2f\%", (float(g_iLosSearchSuccesses) / float(g_iLosSearchAttempts)) * 100);
        panel.DrawText(text);
        Format(text, sizeof(text), "- LoS search failure rate: %.2f\%", (float(g_iLosSearchFailures) / float(g_iLosSearchAttempts)) * 100);
        panel.DrawText(text);
        Format(text, sizeof(text), "- Distance search success rate: %.2f\%", (float(g_iDistanceSearchSuccesses) / float(g_iDistanceSearchAttempts)) * 100);
        panel.DrawText(text);
        Format(text, sizeof(text), "- Distance search failure rate: %.2f\%", (float(g_iDistanceSearchFailures) / float(g_iDistanceSearchAttempts)) * 100);
        panel.DrawText(text);
        Format(text, sizeof(text), "- Spawn point search failures: %i", g_iSpawnPointSearchFailures);
        panel.DrawText(text);
        panel.CurrentKey = GetMaxPageItems(panel.Style);
        panel.DrawItem("Exit", ITEMDRAW_CONTROL);
        panel.Send(client, PanelSpawnStats, MENU_TIME_FOREVER);
        delete panel;
    }
}

public int PanelSpawnStats(Menu menu, MenuAction action, int param1, int param2) { }

public Action Event_Sound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
    if (g_cvDM_enabled.BoolValue)
    {
        if (g_iSpawnPointCount > 0)
        {
            int client;
            if ((entity > 0) && (entity <= MaxClients))
                client = entity;
            else
                client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

            /* Block ammo pickup sounds. */
            if (StrContains(sample, "pickup") != -1)
                return Plugin_Stop;

            /* Block all sounds originating from players not yet moved. */
            if ((client > 0) && (client <= MaxClients) && !g_bPlayerMoved[client])
                return Plugin_Stop;
        }
        if (g_cvDM_free_for_all.BoolValue)
        {
            if (StrContains(sample, "friendlyfire") != -1)
                return Plugin_Stop;
        }
        if (!g_cvDM_sounds_headshots.BoolValue)
        {
            if (StrContains(sample, "physics/flesh/flesh_bloody") != -1 || StrContains(sample, "player/bhit_helmet") != -1 || StrContains(sample, "player/headshot") != -1)
                return Plugin_Stop;
        }
        if (!g_cvDM_sounds_bodyshots.BoolValue)
        {
            if (StrContains(sample, "physics/body") != -1 || StrContains(sample, "physics/flesh") != -1 || StrContains(sample, "player/kevlar") != -1)
                return Plugin_Stop;
        }
    }
    return Plugin_Continue;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    if (g_cvDM_enabled.BoolValue && g_cvDM_respawning.BoolValue && !g_cvDM_valvedm.BoolValue)
    {
        if ((reason == CSRoundEnd_CTWin) || (reason == CSRoundEnd_TerroristWin))
            return Plugin_Handled;
    }
    return Plugin_Continue;
}

void BuildDisplayWeaponMenu(int client, bool primary)
{
    if (primary)
    {
        if (g_hPrimaryMenus[client] != INVALID_HANDLE)
        {
            CancelMenu(g_hPrimaryMenus[client]);
            CloseHandle(g_hPrimaryMenus[client]);
            g_hPrimaryMenus[client] = INVALID_HANDLE;
        }
    }
    else
    {
        if (g_hSecondaryMenus[client] != INVALID_HANDLE)
        {
            CancelMenu(g_hSecondaryMenus[client]);
            CloseHandle(g_hSecondaryMenus[client]);
            g_hSecondaryMenus[client] = INVALID_HANDLE;
        }
    }

    Menu menu;
    if (primary)
    {
        menu = CreateMenu(MenuPrimary);
        menu.SetTitle("Primary Weapon:");
    }
    else
    {
        menu = CreateMenu(MenuSecondary);
        menu.SetTitle("Secondary Weapon:");
    }

    ArrayList weapons;
    weapons = new ArrayList();
    weapons = (primary) ? g_aPrimaryWeaponsAvailable : g_aSecondaryWeaponsAvailable;

    char currentWeapon[24];
    currentWeapon = (primary) ? g_cPrimaryWeapon[client] : g_cSecondaryWeapon[client];

    for (int i = 0; i < weapons.Length; i++)
    {
        char weapon[24];
        weapons.GetString(i, weapon, sizeof(weapon));

        char weaponMenuName[24];
        g_smWeaponMenuNames.GetString(weapon, weaponMenuName, sizeof(weaponMenuName));

        int weaponCount;
        g_smWeaponCounts.GetValue(weapon, weaponCount);

        int weaponLimit;
        g_smWeaponLimits.GetValue(weapon, weaponLimit);

        /* If the client already has the weapon, then the limit does not apply. */
        if (StrEqual(currentWeapon, weapon))
            menu.AddItem(weapon, weaponMenuName);
        else
        {
            if ((weaponLimit == -1) || (weaponCount < weaponLimit))
                menu.AddItem(weapon, weaponMenuName);
            else
            {
                char text[64];
                Format(text, sizeof(text), "%s (Limited)", weaponMenuName);
                menu.AddItem(weapon, text, ITEMDRAW_DISABLED);
            }
        }
    }
    if (primary)
    {
        g_hPrimaryMenus[client] = menu;
        DisplayMenu(g_hPrimaryMenus[client], client, MENU_TIME_FOREVER);
    }
    else
    {
        g_hSecondaryMenus[client] = menu;
        DisplayMenu(g_hSecondaryMenus[client], client, MENU_TIME_FOREVER);
    }
}

void IncrementWeaponCount(char[] weapon)
{
    int weaponCount;
    g_smWeaponCounts.GetValue(weapon, weaponCount);
    g_smWeaponCounts.SetValue(weapon, weaponCount + 1);
}

void DecrementWeaponCount(char[] weapon)
{
    if (!StrEqual(weapon, "none"))
    {
        int weaponCount;
        g_smWeaponCounts.GetValue(weapon, weaponCount);
        g_smWeaponCounts.SetValue(weapon, weaponCount - 1);
    }
}

public Action Event_TextMsg(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
    if (g_cvDM_cash_messages.BoolValue)
    {
        char text[64];
        if (GetUserMessageType() == UM_Protobuf)
            PbReadString(msg, "params", text, sizeof(text), 0);
        else
            BfReadString(msg, text, sizeof(text));

        static char cashTriggers[][] = 
        {
            "#Player_Cash_Award_Killed_Enemy",
            "#Team_Cash_Award_Win_Hostages_Rescue",
            "#Team_Cash_Award_Win_Defuse_Bomb",
            "#Team_Cash_Award_Win_Time",
            "#Team_Cash_Award_Elim_Bomb",
            "#Team_Cash_Award_Elim_Hostage",
            "#Team_Cash_Award_T_Win_Bomb",
            "#Player_Point_Award_Assist_Enemy_Plural",
            "#Player_Point_Award_Assist_Enemy",
            "#Player_Point_Award_Killed_Enemy_Plural",
            "#Player_Point_Award_Killed_Enemy",
            "#Player_Cash_Award_Kill_Hostage",
            "#Player_Cash_Award_Damage_Hostage",
            "#Player_Cash_Award_Get_Killed",
            "#Player_Cash_Award_Respawn",
            "#Player_Cash_Award_Interact_Hostage",
            "#Player_Cash_Award_Killed_Enemy",
            "#Player_Cash_Award_Rescued_Hostage",
            "#Player_Cash_Award_Bomb_Defused",
            "#Player_Cash_Award_Bomb_Planted",
            "#Player_Cash_Award_Killed_Enemy_Generic",
            "#Player_Cash_Award_Killed_VIP",
            "#Player_Cash_Award_Kill_Teammate",
            "#Team_Cash_Award_Win_Hostage_Rescue",
            "#Team_Cash_Award_Loser_Bonus",
            "#Team_Cash_Award_Loser_Zero",
            "#Team_Cash_Award_Rescued_Hostage",
            "#Team_Cash_Award_Hostage_Interaction",
            "#Team_Cash_Award_Hostage_Alive",
            "#Team_Cash_Award_Planted_Bomb_But_Defused",
            "#Team_Cash_Award_CT_VIP_Escaped",
            "#Team_Cash_Award_T_VIP_Killed",
            "#Team_Cash_Award_no_income",
            "#Team_Cash_Award_Generic",
            "#Team_Cash_Award_Custom",
            "#Team_Cash_Award_no_income_suicide",
            "#Player_Cash_Award_ExplainSuicide_YouGotCash",
            "#Player_Cash_Award_ExplainSuicide_TeammateGotCash",
            "#Player_Cash_Award_ExplainSuicide_EnemyGotCash",
            "#Player_Cash_Award_ExplainSuicide_Spectators"
        };

        for (int i = 0; i < sizeof(cashTriggers); i++)
        {
            if (StrEqual(text, cashTriggers[i]))
                return Plugin_Handled;
        }
    }
    if (g_cvDM_free_for_all.BoolValue)
    {
        char text[64];
        if (GetUserMessageType() == UM_Protobuf)
            PbReadString(msg, "params", text, sizeof(text), 0);
        else
            BfReadString(msg, text, sizeof(text));

        if (StrContains(text, "#SFUI_Notice_Killed_Teammate") != -1)
            return Plugin_Handled;

        if (StrContains(text, "#Cstrike_TitlesTXT_Game_teammate_attack") != -1)
            return Plugin_Handled;

        if (StrContains(text, "#Hint_try_not_to_injure_teammates") != -1)
            return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action Event_HintText(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
    if (g_cvDM_free_for_all.BoolValue)
    {
        char text[64];
        if (GetUserMessageType() == UM_Protobuf)
            PbReadString(msg, "text", text, sizeof(text));
        else
            BfReadString(msg, text, sizeof(text));

        if (StrContains(text, "#SFUI_Notice_Hint_careful_around_teammates") != -1)
            return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action Event_RadioText(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
    if (g_cvDM_nade_messages.BoolValue)
    {
        static char grenadeTriggers[][] = 
        {
            "#SFUI_TitlesTXT_Fire_in_the_hole",
            "#SFUI_TitlesTXT_Flashbang_in_the_hole",
            "#SFUI_TitlesTXT_Smoke_in_the_hole",
            "#SFUI_TitlesTXT_Decoy_in_the_hole",
            "#SFUI_TitlesTXT_Molotov_in_the_hole",
            "#SFUI_TitlesTXT_Incendiary_in_the_hole"
        };

        char text[64];
        if (GetUserMessageType() == UM_Protobuf)
        {
            PbReadString(msg, "msg_name", text, sizeof(text));
            /* 0: name */
            /* 1: msg_name == #Game_radio_location ? location : translation phrase */
            /* 2: if msg_name == #Game_radio_location : translation phrase */
            if (StrContains(text, "#Game_radio_location") != -1)
                PbReadString(msg, "params", text, sizeof(text), 2);
            else
                PbReadString(msg, "params", text, sizeof(text), 1);
        }
        else
        {
            BfReadString(msg, text, sizeof(text));
            if (StrContains(text, "#Game_radio_location") != -1)
                BfReadString(msg, text, sizeof(text));
            BfReadString(msg, text, sizeof(text));
            BfReadString(msg, text, sizeof(text));
    }

        for (int i = 0; i < sizeof(grenadeTriggers); i++)
        {
            if (StrEqual(text, grenadeTriggers[i]))
                return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

void RemoveRagdoll(int client)
{
    if (IsValidEdict(client))
    {
        int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
        if (ragdoll != -1)
            AcceptEntityInput(ragdoll, "Kill");
    }
}

public int GetWeaponTeam(const char[] weapon)
{
    int team = 0;
    g_smWeaponSkinsTeam.GetValue(weapon, team);
    return team;
}

public void GiveSkinnedWeapon(int client, const char[] weapon)
{
    int playerTeam = GetEntProp(client, Prop_Data, "m_iTeamNum");
    int weaponTeam = GetWeaponTeam(weapon);

    if (weaponTeam > 0)
        SetEntProp(client, Prop_Data, "m_iTeamNum", weaponTeam);

    GivePlayerItem(client, weapon);
    SetEntProp(client, Prop_Data, "m_iTeamNum", playerTeam);

    if (g_cvDM_fast_equip.BoolValue)
        RequestFrame(Frame_FastSwitch, GetClientSerial(client));
}
