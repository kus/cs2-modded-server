/* ------------------------------------------------------------------

                            ABOUT / CREDITS

This is a revived version of PropHunt for CS:GO, written by
Statistician (I sometimes go by the alias Tilastokeskus).

Although this plugin has essentially been written from scratch,
many snippets originate from the earlier CS:S plugin written
(and abandoned) by SelaX. Anyone who thinks I should give credit
to other people should call me out on it, and I'll make sure
they will be mentioned appropriately.


                               LICENCE

I'm publishing this under the MIT licence, but I don't really give a shit.

------------------------------------------------------------------ */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike> 
#include <sdkhooks>
#include "prophunt/include/globals.inc"
#include "prophunt/include/keyvalues.inc"
#include "prophunt/include/utils.inc"
#pragma newdecls required

#define PLUGIN_VERSION "1.0.5"

public Plugin myinfo = {
    name = "PropHunt",
    author = "Statistician",
    description = "Terrorists choose a model and hide, CTs try to find and kill them.",
    version = PLUGIN_VERSION,
    url = "http://github.com/tilastokeskus/sm-PropHunt"
};

public void OnPluginStart() {
    Handle hVersion = CreateConVar("ph_version", PLUGIN_VERSION, "PropHunt", 
            FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    SetConVarString(hVersion, PLUGIN_VERSION);

    CreateConVars();
    RegisterCommands();
    AddListeners();
    SetOffsets();
    LoadLang();

    // init clients
    for (int x = 1; x <= MaxClients; x++) {
        if (IsClientInGame(x))
            OnClientPutInServer(x);
    }

    CreateTimer(120.0, SpamCommands, 0);
    g_hForceCamera = FindConVar("mp_forcecamera");

    AutoExecConfig(true, "prophunt");
}

public void OnPluginEnd() {
    ServerCommand("mp_restartgame 1");

    for (int client = 1; client <= MaxClients; client++) {
        if (g_hAutoFreezeTimers[client] != INVALID_HANDLE) {
            KillTimer(g_hAutoFreezeTimers[client]);
            g_hAutoFreezeTimers[client] = INVALID_HANDLE;
        }
    }
}

public void OnConfigsExecuted() {

    // set bad server cvars
    for (int i = 0; i < sizeof(protected_cvars); i++) {
        g_hProtectedConvar[i] = FindConVar(protected_cvars[i]);
        if (g_hProtectedConvar[i] == INVALID_HANDLE)
            continue;

        previous_values[i] = GetConVarInt(g_hProtectedConvar[i]);
        SetConVarInt(g_hProtectedConvar[i], forced_values[i], true);
        HookConVarChange(g_hProtectedConvar[i], OnCvarChange);
    }
}

// teach the players the /whistle and /tp commands
public Action SpamCommands(Handle timer, int data) {
    if (GetConVarBool(cvar_Whistle) && data == 1)
        PrintToChatAll("%s%t", PREFIX, "T type /whistle");
    else if (!GetConVarBool(cvar_Whistle) || data == 0) {
        for (int i = 1; i <= MaxClients; i++)
            if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T)
                PrintToChat(i, "%s%t", PREFIX, "T type /tp");
    }
    
    CreateTimer(120.0, SpamCommands, (data == 0 ? 1 : 0));
    return Plugin_Continue;
}

// prevent changes to protected cvars
public void OnCvarChange(Handle convar, const char[] oldValue, const char[] newValue) {
    char cvarName[50];
    GetConVarName(convar, cvarName, sizeof(cvarName));
    for (int i = 0; i < sizeof(protected_cvars); i++) {
        if (StrEqual(protected_cvars[i], cvarName) && StringToInt(newValue) != forced_values[i]) {
            SetConVarInt(convar, forced_values[i]);
            PrintToServer("Hide and Seek: %T", "protected cvar", LANG_SERVER);
            break;
        }
    }
}

// prevent changes to hider speed
public void OnChangeHiderSpeed(Handle convar, const char[] oldValue, const char[] newValue) {
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
            SetEntDataFloat(i, g_flLaggedMovementValue, GetConVarFloat(cvar_HiderSpeed), true);
    }
}

static void CreateConVars() {
    cvar_FreezeCTs = CreateConVar("ph_freezects", "1", "Should CTs get freezed and blinded on spawn?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvar_FreezeTime = CreateConVar("ph_freezetime", "45.0", "How long should the CTs be freezed after spawn?", FCVAR_PLUGIN, true, 1.00, true, 120.00);
    cvar_ChangeLimit = CreateConVar("ph_changelimit", "2", "How often a T is allowed to choose his model ingame? 0 = unlimited", FCVAR_PLUGIN, true, 0.00);
    cvar_ChangeLimittime = CreateConVar("ph_changelimittime", "30.0", "How long should a T be allowed to change his model again after spawn?", FCVAR_PLUGIN, true, 0.00);
    cvar_AutoChoose = CreateConVar("ph_autochoose", "0", "Should the plugin choose models for the hiders automatically?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvar_Whistle = CreateConVar("ph_whistle", "1", "Are terrorists allowed to whistle?", FCVAR_PLUGIN);
    cvar_WhistleTimes = CreateConVar("ph_whistle_times", "5", "How many times a hider is allowed to whistle per round?", FCVAR_PLUGIN);
    cvar_WhistleSeeker = CreateConVar("ph_whistle_seeker", "0", "Allow CTs to enforce T whistle?", FCVAR_PLUGIN);
    cvar_HiderWinFrags = CreateConVar("ph_hider_win_frags", "5", "How many frags should surviving terrorists gain?", FCVAR_PLUGIN, true, 0.00, true, 10.00);
    cvar_SlaySeekers = CreateConVar("ph_slay_seekers", "0", "Should we slay all seekers on round end and there are still some hiders alive? (Default: 0)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvar_HPSeekerEnable = CreateConVar("ph_hp_seeker_enable", "1", "Should CT lose HP when shooting, 0 = off/1 = on.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvar_HPSeekerDec = CreateConVar("ph_hp_seeker_dec", "5", "How many hp should a CT lose on shooting?", FCVAR_PLUGIN, true, 0.00);
    cvar_HPSeekerInc = CreateConVar("ph_hp_seeker_inc", "15", "How many hp should a CT gain when hitting a hider?", FCVAR_PLUGIN, true, 0.00);
    cvar_HPSeekerIncShotgun = CreateConVar("ph_hp_seeker_inc_shotgun", "5", "How many hp should a CT gain when hitting a hider with shotgun? (CS:GO only)", FCVAR_PLUGIN, true, 0.00);
    cvar_HPSeekerBonus = CreateConVar("ph_hp_seeker_bonus", "50", "How many hp should a CT gain when killing a hider?", FCVAR_PLUGIN, true, 0.00);
    cvar_HiderSpeed = CreateConVar("ph_hidersspeed", "1.00", "Hiders speed (Default: 1.00).", FCVAR_PLUGIN, true, 1.00, true, 3.00);
    cvar_DisableDucking = CreateConVar("ph_disable_ducking", "1", "Disable ducking. (Default: 1).", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_AutoThirdPerson = CreateConVar("ph_auto_thirdperson", "1", "Enable thirdperson view for hiders automatically. (Default: 1)", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_HiderFreezeMode = CreateConVar("ph_hider_freeze_mode", "1", "0: Disables /freeze command for hiders, 1: Only freeze on position, be able to move camera, 2: Freeze completely (no cameramovements) (Default: 2)", FCVAR_PLUGIN, true, 0.00, true, 2.00);
    cvar_HideBlood = CreateConVar("ph_hide_blood", "1", "Hide blood on hider damage. (Default: 1)", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_ShowHelp = CreateConVar("ph_show_help", "0", "Show help explaining the game on first player spawn. (Default: 0)", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_CTRatio = CreateConVar("ph_ct_ratio", "3", "The ratio of hiders to 1 seeker. 0 to disables teambalance. (Default: 3)", FCVAR_PLUGIN, true, 0.00, true, 64.00);
    cvar_DisableUse = CreateConVar("ph_disable_use", "1", "Disable CTs pushing things. (Default: 1)", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_HiderFreezeInAir = CreateConVar("ph_hider_freeze_inair", "0", "Are hiders allowed to freeze in the air? (Default: 0)", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_HidePlayerLocation = CreateConVar("ph_hide_player_locations", "1", "Hide the location info shown next to players name on voice chat and teamsay? (Default: 1)", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_AutoFreezeTime = CreateConVar("ph_auto_freeze_time", "5", "Time after which stationary players should freeze automatically (Default: 5) - 0 to disable", FCVAR_PLUGIN, true, 0.00);
    cvar_GuaranteedCTTurns = CreateConVar("ph_guaranteed_ct_turns", "3", "Turns after which CTs might be switched to the T side (Default: 3) - 0 to never switch", FCVAR_PLUGIN, true, 0.00);
    cvar_KnifeSpeed = CreateConVar("ph_knifespeed", "1.40", "Running speed when holding a knife (multiplier)", FCVAR_PLUGIN, true, 0.00);
    cvar_LimitSpec = CreateConVar("ph_limitspec", "2", "0: Do not limit spectating, 1: Limit spectating to own team, 2: Limit spectating to CT. (Default: 2)", FCVAR_PLUGIN, true, 0.00, true, 2.00);
    cvar_IncludeDefaultModels = CreateConVar("ph_include_default_models", "1", "0: Include default model list only when there isn't one for the current map, 1: Always include default model list. (Default: 1)", FCVAR_PLUGIN, true, 0.00, true, 1.00);
    cvar_ForcePeriodicWhistle = CreateConVar("ph_force_periodic_whistle", "0", "Periodically, every x seconds, force a random hider to whistle. 0 to disable. (Default: 0)", FCVAR_PLUGIN, true, 0.00);
    cvar_PeriodicWhistleDelay = CreateConVar("ph_periodic_whistle_delay", "60", "Number of seconds for the first periodic whistle, if they are enabled. (Default: 60)", FCVAR_PLUGIN, true, 0.00);
    cvar_TurnsToScramble = CreateConVar("ph_turns_to_scramble", "0", "Scramble teams every x turns. 0 to disable scrambling. Disables the /ct command if enabled. (Default: 0)", FCVAR_PLUGIN, true, 0.00);
}

static void RegisterCommands() {
    RegConsoleCmd("rules", Cmd_DisplayHelp, "Displays a panel with information on how to play.");
    RegConsoleCmd("hide", Cmd_SelectModelMenu, "Opens a menu with different models to choose as hider.");
    RegConsoleCmd("prop", Cmd_SelectModelMenu, "Opens a menu with different models to choose as hider.");
    RegConsoleCmd("model", Cmd_SelectModelMenu, "Opens a menu with different models to choose as hider.");
    RegConsoleCmd("tp", Cmd_ToggleThirdPerson, "Toggles the view to thirdperson for hiders.");
    RegConsoleCmd("thirdperson", Cmd_ToggleThirdPerson, "Toggles the view to thirdperson for hiders.");
    RegConsoleCmd("third", Cmd_ToggleThirdPerson, "Toggles the view to thirdperson for hiders.");
    RegConsoleCmd("jointeam", Cmd_JoinTeam);
    RegConsoleCmd("whistle", Cmd_PlayWhistle, "Plays a random sound from the hiders position to give the seekers a hint.");
    RegConsoleCmd("whoami", Cmd_DisplayModelName, "Displays the current models description in chat.");
    RegConsoleCmd("freeze", Cmd_Freeze, "Toggles freezing for hiders.");
    RegConsoleCmd("ct", Cmd_RequestCT, "Requests a switch to the seeking side.");

    RegAdminCmd("ph_force_whistle", ForceWhistle, ADMFLAG_CHAT, "Force a player to whistle");
    RegAdminCmd("ph_reload_models", ReloadModels, ADMFLAG_RCON, "Reload the modellist from the map config file.");
}

static void AddListeners() {
    HookConVarChange(cvar_HiderSpeed, OnChangeHiderSpeed);

    HookEvent("player_spawn", Event_OnPlayerSpawn);
    HookEvent("weapon_fire", Event_OnWeaponFire);
    HookEvent("player_death", Event_OnPlayerDeath);
    //HookEvent("player_death", Event_OnPlayerDeath_Pre, EventHookMode_Pre);
    HookEvent("round_start", Event_OnRoundStart);
    HookEvent("round_end", Event_OnRoundEnd);
    HookEvent("round_end", Event_OnRoundEnd_Pre, EventHookMode_Pre);
    HookEvent("player_team", Event_OnPlayerTeam);
    //HookEvent("teamchange_pending", Event_OnTeamChange);
    HookEvent("item_equip", Event_ItemEquip);

    AddCommandListener(Cmd_spec_next, "spec_next");
    AddCommandListener(Cmd_spec_prev, "spec_prev");
    AddCommandListener(Cmd_spec_player, "spec_player");
    AddCommandListener(Cmd_spec_mode, "spec_mode");
}

static void SetOffsets() {
    g_Freeze = FindSendPropOffs("CBasePlayer", "m_fFlags");
    g_flLaggedMovementValue = FindSendPropOffs("CCSPlayer", "m_flLaggedMovementValue");
}

static void LoadLang() {
    LoadTranslations("plugin.prophunt");
    LoadTranslations("common.phrases");
}

#include "prophunt/roundevents.sp"
#include "prophunt/mapevents.sp"
#include "prophunt/clientevents.sp"
#include "prophunt/commands.sp"
#include "prophunt/menus.sp"
#include "prophunt/models.sp"
#include "prophunt/spectate.sp"
#include "prophunt/teamevents.sp"

