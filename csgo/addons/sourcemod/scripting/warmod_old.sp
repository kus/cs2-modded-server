#pragma semicolon 1

#include <sourcemod>
#include <protobuf>
#include <sdktools>
#include <geoip>
#include <cstrike>
#include <socket>
#include <warmod_old>
#include <basecomm>
#undef REQUIRE_PLUGIN
#include <adminmenu>
#include <updater>
#include <tEasyFTP>
#undef REQUIRE_EXTENSIONS
#include <bzip2>
#include <zip>

new g_player_list[MAXPLAYERS + 1];
new bool:g_premium_list[MAXPLAYERS + 1] = false;
new String:g_premium_prefix[MAXPLAYERS + 1][MAX_PARAM_SIZE];
new bool:g_cancel_list[MAXPLAYERS + 1];
new g_scores[2][2];
new g_scores_overtime[2][256][2];
new g_overtime_count = 0;

new g_last_scores[2] =
{
	-1, 0
};
new g_last_maxrounds;
new String:g_last_names[2][64] = {DEFAULT_T_NAME, DEFAULT_CT_NAME};

/* miscellaneous */
new String:g_map[64];
new Float:g_match_start;

/* stats */
new bool:g_log_warmod_dir = false;
new String:g_log_filename[128];
new Handle:g_log_file = INVALID_HANDLE;
new String:weapon_list[][] = {"ak47", "m4a1_silencer", "m4a1_silencer_off", "m4a1", "galilar", "famas", "awp", "p250", "cz75a", "glock", "hkp2000", "usp_silencer", "usp_silencer_off", "ump45", "p90", "bizon", "mp7", "nova", "knife", "elite", "fiveseven", "deagle", "tec9", "ssg08", "scar20", "aug", "sg556", "g3sg1", "mac10", "mp9", "mag7", "negev", "m249", "sawedoff", "incgrenade", "flashbang", "smokegrenade", "hegrenade", "molotov", "decoy", "taser"};
new weapon_stats[MAXPLAYERS + 1][NUM_WEAPONS][LOG_HIT_NUM];
new clutch_stats[MAXPLAYERS + 1][CLUTCH_NUM];
new assist_stats[MAXPLAYERS + 1][ASSIST_NUM];
new String:last_weapon[MAXPLAYERS + 1][64];
new bool:g_planted = false;
new Handle:g_stats_trace_timer = INVALID_HANDLE;
new Handle:g_h_competition = INVALID_HANDLE;
new Handle:g_h_event = INVALID_HANDLE;
new String:g_competition[255];
new String:g_event[255];
new String:g_server[255];

/* forwards */
new Handle:g_f_on_lo3 = INVALID_HANDLE;
new Handle:g_f_on_half_time = INVALID_HANDLE;
new Handle:g_f_on_reset_half = INVALID_HANDLE;
new Handle:g_f_on_reset_match = INVALID_HANDLE;
new Handle:g_f_on_end_match = INVALID_HANDLE;

/* cvars */
new Handle:g_h_lw_enabled = INVALID_HANDLE;
new Handle:g_h_lw_address = INVALID_HANDLE;
new Handle:g_h_lw_port = INVALID_HANDLE;
new Handle:g_h_lw_bindaddress = INVALID_HANDLE;
new Handle:g_h_lw_group_name = INVALID_HANDLE;
new Handle:g_h_lw_group_password = INVALID_HANDLE;
new Handle:g_h_active = INVALID_HANDLE;
new Handle:g_h_stats_enabled = INVALID_HANDLE;
new Handle:g_h_stats_method = INVALID_HANDLE;
new Handle:g_h_stats_trace_enabled = INVALID_HANDLE;
new Handle:g_h_stats_trace_delay = INVALID_HANDLE;
new Handle:g_h_rcon_only = INVALID_HANDLE;
new Handle:g_h_global_chat = INVALID_HANDLE;
new Handle:g_h_stv_chat = INVALID_HANDLE;
new Handle:g_h_locked = INVALID_HANDLE;
new Handle:g_h_min_ready = INVALID_HANDLE;
new Handle:g_h_max_players = INVALID_HANDLE;
new Handle:g_h_match_config = INVALID_HANDLE;
new Handle:g_h_end_config = INVALID_HANDLE;
new Handle:g_h_warmup_config = INVALID_HANDLE;
new Handle:g_h_prac_config = INVALID_HANDLE;
new Handle:g_h_half_time_config = INVALID_HANDLE;
new Handle:g_h_half_time_break = INVALID_HANDLE;
new Handle:g_h_over_time_break = INVALID_HANDLE;
new Handle:g_h_round_money = INVALID_HANDLE;
new Handle:g_h_ingame_scores = INVALID_HANDLE;
new Handle:g_h_max_rounds = INVALID_HANDLE;
new Handle:g_h_warm_up_grens = INVALID_HANDLE;
new Handle:g_h_knife_hegrenade = INVALID_HANDLE;
new Handle:g_h_knife_flashbang = INVALID_HANDLE;
new Handle:g_h_knife_smokegrenade = INVALID_HANDLE;
new Handle:g_h_knife_zeus = INVALID_HANDLE;
new Handle:g_h_knife_armor = INVALID_HANDLE;
new Handle:g_h_knife_helmet = INVALID_HANDLE;
new Handle:g_h_req_names = INVALID_HANDLE;
new Handle:g_h_show_info = INVALID_HANDLE;
new Handle:g_h_auto_ready = INVALID_HANDLE;
new Handle:g_h_auto_knife = INVALID_HANDLE;
new Handle:g_h_auto_kick_team = INVALID_HANDLE;
new Handle:g_h_auto_kick_delay = INVALID_HANDLE;
new Handle:g_h_score_mode = INVALID_HANDLE;
new Handle:g_h_overtime = INVALID_HANDLE;
new Handle:g_h_overtime_mr = INVALID_HANDLE;
new Handle:g_h_overtime_money = INVALID_HANDLE;
new Handle:g_h_auto_record = INVALID_HANDLE;
new Handle:g_h_save_file_dir = INVALID_HANDLE;
new Handle:g_h_prefix_logs = INVALID_HANDLE;
new Handle:g_h_warmup_respawn = INVALID_HANDLE;
new Handle:g_h_status = INVALID_HANDLE;
new Handle:g_h_upload_results = INVALID_HANDLE;
new Handle:g_h_sql_beta = INVALID_HANDLE;
new Handle:g_h_table_name = INVALID_HANDLE;
new Handle:g_h_chat_prefix = INVALID_HANDLE;
new Handle:g_h_t = INVALID_HANDLE;
new Handle:g_h_ct = INVALID_HANDLE;
//new Handle:g_h_notify_version = INVALID_HANDLE;
new Handle:g_h_t_score = INVALID_HANDLE;
new Handle:g_h_ct_score = INVALID_HANDLE;
new Handle:g_h_play_out = INVALID_HANDLE;

new Handle:g_h_mp_startmoney = INVALID_HANDLE;
new Handle:g_h_hostname = INVALID_HANDLE;

/* ready system */
new Handle:g_m_ready_up = INVALID_HANDLE;
new bool:g_ready_enabled = false;

/* switches */
new bool:g_active = true;
new bool:g_start = false;
new bool:g_match = false;
new bool:g_live = false;
new bool:g_half_swap = true;
new bool:g_play_out = false;
new bool:g_playing_out = false;
new bool:g_first_half = true;
new bool:g_overtime = false;
new bool:g_t_money = false;
new bool:g_t_score = false;
new bool:g_t_knife = true;
new bool:g_t_had_knife = false;
new bool:g_second_half_first = false;
new g_p_ct_name = false;
new g_p_t_name = false;
new g_knife_winner = 0;
new g_knife_vote = false;

/* FTP Auto upload code [By Thrawn from tAutoDemoUpload] */
new Handle:g_hCvarEnabled = INVALID_HANDLE;
new bool:g_bEnabled = false;
new Handle:g_hCvarBzip = INVALID_HANDLE;
new g_iBzip2 = 9;
new Handle:g_hCvarFtpTargetDemo = INVALID_HANDLE;
new Handle:g_hCvarFtpTargetLog = INVALID_HANDLE;
new String:g_sFtpTargetDemo[255];
new String:g_sFtpTargetLog[255];
new Handle:g_hCvarDelete = INVALID_HANDLE;
new bool:g_bDelete = false;
new String:g_sDemoPath[PLATFORM_MAX_PATH];
new String:g_sDemoName[64];
new String:g_sLogPath[PLATFORM_MAX_PATH];
new bool:g_bRecording = false;
new Handle:g_hOnMatchCompleted = INVALID_HANDLE;
new bool:g_UploadOnMatchCompleted = true;
new bool:g_MatchComplete = false;

/* Warmod safemode */
new Handle:g_h_warmod_safemode = INVALID_HANDLE;
new bool:g_warmod_safemode = false;

/* livewire */
new Handle:g_h_lw_socket = INVALID_HANDLE;
new bool:g_lw_connecting = false;
new bool:g_lw_connected = false;

/* modes */
new g_overtime_mode = 0;

/* chat prefix */
new String:CHAT_PREFIX[64];

/* teams */
new String:g_t_name[64];
new String:g_t_name_escaped[64]; // pre-escaped for warmod logs
new String:g_ct_name[64];
new String:g_ct_name_escaped[64]; // pre-escaped for warmod logs

/* Pause and Unpause */
new bool:g_pause_freezetime = false;
new bool:g_pause_offered_t = false;
new bool:g_pause_offered_ct = false;
new bool:g_paused = false;
new bool:FreezeTime = false;

new Handle:sv_pausable;
new Handle:g_h_auto_unpause = INVALID_HANDLE;
new Handle:g_h_auto_unpause_delay = INVALID_HANDLE;
//new Handle:g_h_pause_freezetime = INVALID_HANDLE;
new Handle:g_h_pause_confirm = INVALID_HANDLE;
new Handle:g_h_pause_limit = INVALID_HANDLE;
new g_t_pause_count = 0;
new g_ct_pause_count = 0;
new Handle:g_h_stored_timer = INVALID_HANDLE;
new Handle:g_h_stored_timer_p = INVALID_HANDLE;

/* admin menu */
new Handle:g_h_menu = INVALID_HANDLE;

/* Plugin info */
#define UPDATE_URL				"http://warmod.bitbucket.org/updatefile_old.txt"
#define WM_VERSION				"0.2.5.7"
#define WM_DESCRIPTION			"An automative service for CS:GO competition matches"

public Plugin:myinfo = {
	name = "WarMod [BFG]",
	author = "Versatile_BFG",
	description = WM_DESCRIPTION,
	version = WM_VERSION,
	url = "www.sourcemod.net"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("Zip_Open");
	MarkNativeAsOptional("Zip_AddFile");
	MarkNativeAsOptional("EasyFTP_UploadFile");
	MarkNativeAsOptional("Set_StartMoney");
	RegPluginLibrary("warmod");
	return APLRes_Success;
}

public OnPluginStart()
{
	//auto update
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	
	LoadTranslations("warmod.phrases");
	LoadTranslations("common.phrases");
	
	new Handle:topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		OnAdminMenuReady(topmenu);
	}
	
	g_f_on_lo3 = CreateGlobalForward("OnLiveOn3", ET_Ignore);
	g_f_on_half_time = CreateGlobalForward("OnHalfTime", ET_Ignore);
	g_f_on_reset_half = CreateGlobalForward("OnResetHalf", ET_Ignore);
	g_f_on_reset_match = CreateGlobalForward("OnResetMatch", ET_Ignore);
	g_f_on_end_match = CreateGlobalForward("OnEndMatch", ET_Ignore);
	
	RegConsoleCmd("score", ConsoleScore);
	RegConsoleCmd("wm_version", WMVersion);
	RegConsoleCmd("say", SayChat);
	RegConsoleCmd("say_team", SayChat);
	RegConsoleCmd("buy", RestrictBuy);
	AddCommandListener(Command_JoinTeam, "jointeam");
	RegConsoleCmd("jointeam", ChooseTeam);
	RegConsoleCmd("spectate", ChooseTeam);
	RegConsoleCmd("wm_readylist", ReadyList);
	RegConsoleCmd("wmrl", ReadyList);
	//AddCommandListener(CommandListener_Record, "tv_record");
	
	RegConsoleCmd("wm_cash", AskTeamMoney);
	RegConsoleCmd("name", Name);
	
	RegAdminCmd("last_score", LastMatch, ADMFLAG_CUSTOM1, "Displays the score of the last match to the console");
	RegAdminCmd("last", LastMatch, ADMFLAG_CUSTOM1, "Displays the score of the last match to the console");
	
	RegAdminCmd("notlive", NotLive, ADMFLAG_CUSTOM1, "Declares half not live and restarts the round");
	RegAdminCmd("nl", NotLive, ADMFLAG_CUSTOM1, "Declares half not live and restarts the round");
	RegAdminCmd("cancelhalf", NotLive, ADMFLAG_CUSTOM1, "Declares half not live and restarts the round");
	RegAdminCmd("ch", NotLive, ADMFLAG_CUSTOM1, "Declares half not live and restarts the round");
	
	RegAdminCmd("cancelmatch", CancelMatch, ADMFLAG_CUSTOM1, "Declares match not live and restarts round");
	RegAdminCmd("cm", CancelMatch, ADMFLAG_CUSTOM1, "Declares match not live and restarts round");
	
	RegAdminCmd("readyup", ReadyToggle, ADMFLAG_CUSTOM1, "Starts or stops the ReadyUp System");
	RegAdminCmd("ru", ReadyToggle, ADMFLAG_CUSTOM1, "Starts or stops the ReadyUp System");
	
	RegAdminCmd("t", ChangeT, ADMFLAG_CUSTOM1, "Team starting terrorists - Designed for score purposes");
	RegAdminCmd("ct", ChangeCT, ADMFLAG_CUSTOM1, "Team starting counter-terrorists - Designed for score purposes");
	RegAdminCmd("sst", SetScoreT, ADMFLAG_CUSTOM1, "Setting terrorists score");
	RegAdminCmd("ssct", SetScoreCT, ADMFLAG_CUSTOM1, "Setting counter-terrorists scores");
	
	RegAdminCmd("swap", SwapAll, ADMFLAG_CUSTOM1, "Swap all players to the opposite team");
	
	RegAdminCmd("prac", Practice, ADMFLAG_CUSTOM1, "Puts server into a practice mode state");
	RegAdminCmd("warmup", WarmUp, ADMFLAG_CUSTOM1, "Puts server into a warm up state");
	
	RegAdminCmd("pwd", ChangePassword, ADMFLAG_PASSWORD, "Set or display the sv_password console variable");
	RegAdminCmd("pw", ChangePassword, ADMFLAG_PASSWORD, "Set or display the sv_password console variable");
	
	RegAdminCmd("active", ActiveToggle, ADMFLAG_CUSTOM1, "Toggle the wm_active console variable");
	
	RegAdminCmd("minready", ChangeMinReady, ADMFLAG_CUSTOM1, "Set or display the wm_min_ready console variable");
	
	RegAdminCmd("maxrounds", ChangeMaxRounds, ADMFLAG_CUSTOM1, "Set or display the wm_max_rounds console variable");
	
	RegAdminCmd("knife", KnifeOn3, ADMFLAG_CUSTOM1, "Remove all weapons except knife and lo3");
	RegAdminCmd("ko3", KnifeOn3, ADMFLAG_CUSTOM1, "Remove all weapons except knife and lo3");
	
	RegAdminCmd("cancelknife", CancelKnife, ADMFLAG_CUSTOM1, "Declares knife not live and restarts round");
	RegAdminCmd("ck", CancelKnife, ADMFLAG_CUSTOM1, "Declares knife not live and restarts round");
	
	RegAdminCmd("forceallready", ForceAllReady, ADMFLAG_CUSTOM1, "Forces all players to become ready");
	RegAdminCmd("far", ForceAllReady, ADMFLAG_CUSTOM1, "Forces all players to become ready");
	RegAdminCmd("forceallunready", ForceAllUnready, ADMFLAG_CUSTOM1, "Forces all players to become unready");
	RegAdminCmd("faur", ForceAllUnready, ADMFLAG_CUSTOM1, "Forces all players to become unready");
	RegAdminCmd("forceallspectate", ForceAllSpectate, ADMFLAG_CUSTOM1, "Forces all players to become a spectator");
	RegAdminCmd("fas", ForceAllSpectate, ADMFLAG_CUSTOM1, "Forces all players to become a spectator");
	
	RegAdminCmd("lo3", ForceStart, ADMFLAG_CUSTOM1, "Starts the match regardless of player and ready count");
	RegAdminCmd("forcestart", ForceStart, ADMFLAG_CUSTOM1, "Starts the match regardless of player and ready count");
	RegAdminCmd("fs", ForceStart, ADMFLAG_CUSTOM1, "Starts the match regardless of player and ready count");
	RegAdminCmd("forceend", ForceEnd, ADMFLAG_CUSTOM1, "Ends the match regardless of status");
	RegAdminCmd("fe", ForceEnd, ADMFLAG_CUSTOM1, "Ends the match regardless of status");
	
	RegAdminCmd("readyon", ReadyOn, ADMFLAG_CUSTOM1, "Turns on or restarts the ReadyUp System");
	RegAdminCmd("ron", ReadyOn, ADMFLAG_CUSTOM1, "Turns on or restarts the ReadyUp System");
	RegAdminCmd("readyoff", ReadyOff, ADMFLAG_CUSTOM1, "Turns off the ReadyUp System if enabled");
	RegAdminCmd("roff", ReadyOff, ADMFLAG_CUSTOM1, "Turns off the ReadyUp System if enabled");
	
	RegAdminCmd("wm_debug_create_table", CreateTable, ADMFLAG_ROOT, "Testing purposes only, connects to the WarMod database and creates a match results table (if it does not already exist)");
	RegAdminCmd("lw_reconnect", LiveWire_ReConnect, ADMFLAG_ROOT, "Reconnects LiveWire if lw_enabled is 1");
	
	g_h_active = CreateConVar("wm_active", "1", "Enable or disable WarMod as active", FCVAR_NOTIFY);
	g_h_lw_enabled = CreateConVar("lw_enabled", "1", "Enable or disable LiveWire", FCVAR_NOTIFY);
	g_h_lw_address = CreateConVar("lw_address", "stream.livewire.gametech.com.au", "Sets the ip/host that LiveWire will use to connect", FCVAR_NOTIFY);
	g_h_lw_port = CreateConVar("lw_port", "12012", "Sets the port that LiveWire will use to connect", FCVAR_NOTIFY, true, 1.0);
	g_h_lw_bindaddress = CreateConVar("lw_bindaddress", "", "Optional setting to specify which ip LiveWire will bind to (for servers with multiple ips) - blank = automatic/primary", FCVAR_NOTIFY);
	g_h_lw_group_name = CreateConVar("lw_group_name", "", "Sets the group name that LiveWire will use", FCVAR_PROTECTED|FCVAR_DONTRECORD);
	g_h_lw_group_password = CreateConVar("lw_group_password", "", "Sets the group password that LiveWire will use", FCVAR_PROTECTED|FCVAR_DONTRECORD);
	
	g_h_stats_enabled = CreateConVar("wm_stats_enabled", "1", "Enable or disable statistical logging", FCVAR_NOTIFY);
	g_h_stats_method = CreateConVar("wm_stats_method", "2", "Sets the stats logging method: 0 = UDP stream/server logs, 1 = WarMod logs, 2 = both", FCVAR_NOTIFY, true, 0.0);
	g_h_stats_trace_enabled = CreateConVar("wm_stats_trace", "0", "Enable or disable updating all player positions, every wm_stats_trace_delay seconds", FCVAR_NOTIFY);
	g_h_stats_trace_delay = CreateConVar("wm_stats_trace_delay", "5", "The ammount of time between sending player position updates", FCVAR_NOTIFY, true, 0.0);
	g_h_rcon_only = CreateConVar("wm_rcon_only", "0", "Enable or disable admin commands to be only executed via RCON or console");
	g_h_global_chat = CreateConVar("wm_global_chat", "1", "Enable or disable the global chat command (@ prefix in messagemode)");
	g_h_stv_chat = CreateConVar("wm_tv_chat", "1", "Enable or disable the players chat being relayed to Source TV");
	g_h_locked = CreateConVar("wm_lock_teams", "1", "Enable or disable locked teams when a match is running", FCVAR_NOTIFY);
	g_h_min_ready = CreateConVar("wm_min_ready", "10", "Sets the minimum required ready players to Live on 3", FCVAR_NOTIFY);
	g_h_max_players = CreateConVar("wm_max_players", "10", "Sets the maximum players allowed on both teams combined, others will be forced to spectator (0 = unlimited)", FCVAR_NOTIFY, true, 0.0);
	g_h_match_config = CreateConVar("wm_match_config", "warmod/ruleset_mr15.cfg", "Sets the match config to load on Live on 3");
	g_h_end_config = CreateConVar("wm_reset_config", "warmod/on_match_end.cfg", "Sets the config to load at the end/reset of a match");
	g_h_warmup_config = CreateConVar("wm_warmup_config", "warmod/ruleset_warmup.cfg", "Sets the config to load up for warmup");
	g_h_prac_config = CreateConVar("wm_prac_config", "warmod/prac.cfg", "Sets the config to load up for practice");
	g_h_half_time_config = CreateConVar("wm_half_time_config", "warmod/on_match_half_time.cfg", "Sets the config to load at half time of a match (including overtime)");
	g_h_half_time_break = CreateConVar("wm_half_time_break", "0", "Pause game at halftime for a break, No break = 0, break = 1");
	g_h_over_time_break = CreateConVar("wm_over_time_break", "0", "Pause game at overtime for a break, No break = 0, break = 1");
	g_h_round_money = CreateConVar("wm_round_money", "1", "Enable or disable a client's team mates money to be displayed at the start of a round (to him only)", FCVAR_NOTIFY);
	g_h_ingame_scores = CreateConVar("wm_ingame_scores", "1", "Enable or disable ingame scores to be showed at the end of each round", FCVAR_NOTIFY);
	g_h_max_rounds = CreateConVar("wm_max_rounds", "15", "Sets maxrounds before auto team switch", FCVAR_NOTIFY);
	g_h_warm_up_grens = CreateConVar("wm_block_warm_up_grenades", "0", "Enable or disable grenade blocking in warmup", FCVAR_NOTIFY);
	g_h_knife_hegrenade = CreateConVar("wm_knife_hegrenade", "0", "Enable or disable giving a player a hegrenade on Knife on 3", FCVAR_NOTIFY);
	g_h_knife_flashbang = CreateConVar("wm_knife_flashbang", "0", "Sets how many flashbangs to give a player on Knife on 3", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	g_h_knife_smokegrenade = CreateConVar("wm_knife_smokegrenade", "0", "Enable or disable giving a player a smokegrenade on Knife on 3", FCVAR_NOTIFY);
	g_h_knife_zeus = CreateConVar("wm_knife_zeus", "0", "Enable or disable giving a player a zeus on Knife on 3", FCVAR_NOTIFY);
	g_h_knife_armor = CreateConVar("wm_knife_armor", "1", "Enable or disable giving a player Armor on Knife on 3", FCVAR_NOTIFY);
	g_h_knife_helmet = CreateConVar("wm_knife_helmet", "0", "Enable or disable giving a player a Helmet on Knife on 3 [requires armor active]", FCVAR_NOTIFY);
	g_h_req_names = CreateConVar("wm_require_names", "0", "Enable or disable the requirement of set team names for lo3", FCVAR_NOTIFY);
	g_h_show_info = CreateConVar("wm_show_info", "1", "Enable or disable the display of the Ready System to players", FCVAR_NOTIFY);
	g_h_auto_ready = CreateConVar("wm_auto_ready", "1", "Enable or disable the ready system being automatically enabled on map change", FCVAR_NOTIFY);
	g_h_auto_knife = CreateConVar("wm_auto_knife", "0", "Enable or disable the knife round before going live", FCVAR_NOTIFY);
	g_h_auto_kick_team = CreateConVar("wm_auto_kick_team", "0", "Enable or disable the automatic kicking of the losing team", FCVAR_NOTIFY);
	g_h_auto_kick_delay = CreateConVar("wm_auto_kick_delay", "10", "Sets the seconds to wait before kicking the losing team", FCVAR_NOTIFY, true, 0.0);
	g_h_score_mode = CreateConVar("wm_score_mode", "1", "Sets score mode: 1 = Best Of, 2 = First To (based on wm_max_rounds)", FCVAR_NOTIFY);
	g_h_overtime = CreateConVar("wm_overtime", "0", "Sets overtime mode: 0 = off, 1 = Maxrounds (based on wm_overtime_max_rounds), NOTE: UNSUPPORTED - 2 = Sudden Death", FCVAR_NOTIFY);
	g_h_overtime_mr = CreateConVar("wm_overtime_max_rounds", "3", "Sets overtime maxrounds", FCVAR_NOTIFY, true, 0.0);
	g_h_overtime_money = CreateConVar("wm_overtime_start_money", "10000", "Sets overtime startmoney", FCVAR_NOTIFY, true, 0.0);
	g_h_auto_record = CreateConVar("wm_auto_record", "1", "Enable or disable auto SourceTV demo record on Live on 3", FCVAR_NOTIFY);
	g_h_save_file_dir = CreateConVar("wm_save_dir", "warmod", "Directory to store SourceTV demos and WarMod logs");
	g_h_prefix_logs = CreateConVar("wm_prefix_logs", "1", "Enable or disable the prefixing of \"_\" to uncompleted match SourceTV demos and WarMod logs", FCVAR_NOTIFY);
	g_h_warmup_respawn = CreateConVar("wm_warmup_respawn", "0", "Enable or disable the respawning of players in warmup", FCVAR_NOTIFY);
	g_h_status = CreateConVar("wm_status", "0", "WarMod automatically updates this value to the corresponding match status code", FCVAR_NOTIFY);
	g_h_upload_results = CreateConVar("wm_upload_results", "0", "Enable or disable the uploading of match results via MySQL", FCVAR_NOTIFY);
	g_h_sql_beta = CreateConVar("wm_sql_beta", "0", "Enable or disable the beta uploading of match results via MySQL", FCVAR_NOTIFY);
	g_h_table_name = CreateConVar("wm_table_name", "wm_results", "The MySQL table name to store match results in");
	g_h_chat_prefix = CreateConVar("wm_chat_prefix", "WarMod_BFG", "Change the chat prefix. Default is WarMod_BFG", FCVAR_PROTECTED);
	g_h_t = CreateConVar("wm_t", DEFAULT_T_NAME, "Team starting terrorists, designed for score and demo naming purposes", FCVAR_NOTIFY);
	g_h_ct = CreateConVar("wm_ct", DEFAULT_CT_NAME, "Team starting counter-terrorists, designed for score and demo naming purposes", FCVAR_NOTIFY);
	g_h_t_score = CreateConVar("wm_t_score", "0", "WarMod automatically updates this value to the Terrorist's total score", FCVAR_NOTIFY);
	g_h_ct_score = CreateConVar("wm_ct_score", "0", "WarMod automatically updates this value to the Counter-Terrorist's total score", FCVAR_NOTIFY);
//	g_h_notify_version = CreateConVar("wm_version_notify", WM_VERSION, WM_DESCRIPTION, FCVAR_NOTIFY|FCVAR_REPLICATED);
	CreateConVar("wm_version_notify", WM_VERSION, WM_DESCRIPTION, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_hCvarEnabled = CreateConVar("wm_autodemoupload_enable", "1", "Automatically upload demos when finished recording.", FCVAR_NOTIFY|FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarBzip = CreateConVar("wm_autodemoupload_bzip2", "9", "Compression level. If set > 0 demos will be compressed before uploading. (Requires bzip2 extension.)", FCVAR_PLUGIN, true, 0.0, true, 9.0);
	g_hCvarDelete = CreateConVar("wm_autodemoupload_delete", "0", "Delete the demo (and the bz2) if upload was successful.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarFtpTargetDemo = CreateConVar("wm_autodemoupload_ftptargetdemo", "demos", "The ftp target to use for uploads.", FCVAR_PLUGIN);
	g_hCvarFtpTargetLog = CreateConVar("wm_autodemoupload_ftptargetlog", "logs", "The ftp target to use for uploads.", FCVAR_PLUGIN);
	g_hOnMatchCompleted  = CreateConVar("wm_autodemoupload_completed", "1", "Only upload demos when match is completed.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_h_competition = CreateConVar("wm_competition", "WarMod BFG", "Name of host for a competition. eg. ESEA, Cybergamer, CEVO, ESL", FCVAR_PLUGIN);
	g_h_event = CreateConVar("wm_event", "scrim", "Name of event. eg. Season #, ODC #, Ladder", FCVAR_PLUGIN);
	// Pause and Unpause stuff
	sv_pausable = FindConVar ("sv_pausable");
	g_h_pause_confirm = CreateConVar("wm_pause_confirm", "1", "Wait for other team to confirm pause: 0 = off, 1 = on", FCVAR_NOTIFY);
	g_h_auto_unpause = CreateConVar("wm_auto_unpause", "1", "Sets auto unpause: 0 = off, 1 = on", FCVAR_NOTIFY);
	g_h_auto_unpause_delay = CreateConVar("wm_auto_unpause_delay", "180", "Sets the seconds to wait before auto unpause", FCVAR_NOTIFY, true, 0.0);
	g_h_pause_limit = CreateConVar("wm_pause_limit", "1", "Sets max pause count per team per half", FCVAR_NOTIFY);
//	g_h_pause_freezetime = CreateConVar("wm_pause_freezetime", "1", "Wait for freeze time to pause: 0 = off, 1 = on", FCVAR_NOTIFY);
	g_h_warmod_safemode = CreateConVar("wm_warmod_safemode", "0", "This disables features that usually break on a CS:GO update", FCVAR_NOTIFY);
	
	g_h_mp_startmoney = FindConVar("mp_startmoney");
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	g_h_hostname = FindConVar("hostname");
	
	g_h_play_out = FindConVar("mp_match_can_clinch");
	
	HookConVarChange(g_h_active, OnActiveChange);
	HookConVarChange(g_h_req_names, OnReqNameChange);
	HookConVarChange(g_h_min_ready, OnMinReadyChange);
	HookConVarChange(g_h_stats_trace_enabled, OnStatsTraceChange);
	HookConVarChange(g_h_stats_trace_delay, OnStatsTraceDelayChange);
	HookConVarChange(g_h_auto_ready, OnAutoReadyChange);
	HookConVarChange(g_h_max_rounds, OnMaxRoundChange);
	HookConVarChange(FindConVar("mp_maxrounds"), OnMaxRoundChangeMP);
	HookConVarChange(g_h_overtime, OnOverTimeChange);
	HookConVarChange(FindConVar("mp_overtime_enable"), OnOverTimeChangeMP);
	HookConVarChange(g_h_overtime_mr, OnOverTimeMaxRoundChange);
	HookConVarChange(FindConVar("mp_overtime_maxrounds"), OnOverTimeMaxRoundChangeMP);
	HookConVarChange(g_h_overtime_money, OnOverTimeMoneyChange);
	HookConVarChange(FindConVar("mp_overtime_startmoney"), OnOverTimeMoneyChangeMP);
	HookConVarChange(FindConVar("mp_match_can_clinch"), OnPlayOutChangeMP);
	HookConVarChange(g_h_lw_enabled, OnLiveWireChange);
	HookConVarChange(g_h_t, OnTChange);
	HookConVarChange(g_h_ct, OnCTChange);
	
	HookConVarChange(g_h_warmod_safemode, Cvar_Changed);
	HookConVarChange(g_hCvarFtpTargetDemo, Cvar_Changed);
	HookConVarChange(g_hCvarFtpTargetLog, Cvar_Changed);
	HookConVarChange(g_hCvarDelete, Cvar_Changed);
	HookConVarChange(g_hCvarBzip, Cvar_Changed);
	HookConVarChange(g_hCvarEnabled, Cvar_Changed);
	HookConVarChange(g_hOnMatchCompleted, Cvar_Changed);
	
	HookConVarChange(g_h_competition, Cvar_Changed);
	HookConVarChange(g_h_event, Cvar_Changed);
	HookConVarChange(g_h_hostname, Cvar_Changed);
	
	HookEvent("round_start", Event_Round_Start);
	HookEvent("round_end", Event_Round_End);
	HookConVarChange(FindConVar("mp_restartgame"), Event_Round_Restart);
	HookEvent("round_freeze_end", Event_Round_Freeze_End);
	
	HookEvent("player_blind", Event_Player_Blind);
	HookEvent("player_hurt",  Event_Player_Hurt);
	HookEvent("player_death",  Event_Player_Death);
	HookEvent("player_changename", Event_Player_Name);
	HookEvent("player_disconnect", Event_Player_Disc_Pre, EventHookMode_Pre);
	HookEvent("player_team", Event_Player_Team);
	HookEvent("player_team", Event_Player_Team_Pre, EventHookMode_Pre);
	
	HookEvent("bomb_pickup", Event_Bomb_PickUp);
	HookEvent("bomb_dropped", Event_Bomb_Dropped);
	HookEvent("bomb_beginplant", Event_Bomb_Plant_Begin);
	HookEvent("bomb_abortplant", Event_Bomb_Plant_Abort);
	HookEvent("bomb_planted", Event_Bomb_Planted);
	HookEvent("bomb_begindefuse", Event_Bomb_Defuse_Begin);
	HookEvent("bomb_abortdefuse", Event_Bomb_Defuse_Abort);
	HookEvent("bomb_defused", Event_Bomb_Defused);
	
	HookEvent("weapon_fire", Event_Weapon_Fire);
	
	HookEvent("flashbang_detonate", Event_Detonate_Flash);
	HookEvent("smokegrenade_detonate", Event_Detonate_Smoke);
	HookEvent("hegrenade_detonate", Event_Detonate_HeGrenade);
	HookEvent("molotov_detonate", Event_Detonate_Molotov);
	HookEvent("decoy_detonate", Event_Detonate_Decoy);
	
	HookEvent("item_pickup", Event_Item_Pickup);
	
	CreateTimer(15.0, HelpText, 0, TIMER_REPEAT);
	//CreateTimer(15.0, CheckNames, 0, TIMER_REPEAT);
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public OnConfigsExecuted()
{
	GetConVarString(g_h_chat_prefix, CHAT_PREFIX, sizeof(CHAT_PREFIX));
	GetConVarString(g_h_event, g_event, sizeof(g_event));
	GetConVarString(g_h_competition, g_competition, sizeof(g_competition));
	GetConVarString(g_h_hostname, g_server, sizeof(g_server));
	
	g_h_play_out = FindConVar("mp_match_can_clinch");
	if (g_h_play_out)
	{
		g_play_out = false;
	}
	else
	{
		g_play_out = true;
	}
	
	g_warmod_safemode = GetConVarBool(g_h_warmod_safemode);
	g_bEnabled = GetConVarBool(g_hCvarEnabled);
	g_iBzip2 = GetConVarBool(g_hCvarBzip);
	g_bDelete = GetConVarBool(g_hCvarDelete);
	g_UploadOnMatchCompleted = GetConVarBool(g_hOnMatchCompleted);
	GetConVarString(g_hCvarFtpTargetDemo, g_sFtpTargetDemo, sizeof(g_sFtpTargetDemo));
	GetConVarString(g_hCvarFtpTargetLog, g_sFtpTargetLog, sizeof(g_sFtpTargetLog));
}

public Action:LiveWire_ReConnect(client, args)
{
	if (GetConVarBool(g_h_lw_enabled))
	{
		LiveWire_Disconnect();
		LiveWire_Connect();
	}
	else
	{
		ReplyToCommand(client, "\x01 \x09[\x04%s\x09]\x01 LiveWire not enabled!", CHAT_PREFIX);
	}
	return Plugin_Handled;
}

LiveWire_Connect()
{
	if (!g_lw_connecting)
	{
		g_h_lw_socket = SocketCreate(SOCKET_TCP, OnSocketError);
		new String:address[256];
		GetConVarString(g_h_lw_address, address, sizeof(address));
		new port = GetConVarInt(g_h_lw_port);
		
		// bind socket to ip address - used for servers with multiple ips
		new String:bindaddress[32];
		GetConVarString(g_h_lw_bindaddress, bindaddress, sizeof(bindaddress));
		if (StrEqual(bindaddress, ""))
		{
			new hostIP = GetConVarInt(FindConVar("hostip"));
			Format(bindaddress, 32, "%d.%d.%d.%d", hostIP >> 24, hostIP >> 16 & 255, hostIP >> 8 & 255, hostIP & 255);
		}
		// TODO: validate as ip?
		PrintToServer("<LiveWire> Binding socket to \"%s\"", bindaddress);
		SocketBind(g_h_lw_socket, bindaddress, 0);
		
		PrintToServer("<LiveWire> Connecting to \"%s:%d\"", address, port);
		
		SocketConnect(g_h_lw_socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, address, port);
		g_lw_connecting = true;
	}
}

LiveWire_Send(const String:format[], any:...)
{
	decl String:event[1024];
	// format arguments
	VFormat(event, sizeof(event), format, 2);
	if (GetConVarBool(g_h_lw_enabled) && g_lw_connected)
	{
		// add a newline to each event
		StrCat(event, sizeof(event), "\n");
		// send to socket
		SocketSend(g_h_lw_socket, event);
	}
}

LiveWire_Disconnect()
{
	g_lw_connecting = false;
	// check if connected
	if (g_lw_connected)
	{
		g_lw_connected = false;
		// close socket
		CloseHandle(g_h_lw_socket);
	}
}

public OnSocketConnected(Handle:socket, any:arg)
{
	g_lw_connecting = false;
	g_lw_connected = true;
	PrintToServer("<LiveWire> Connected");
	new String:username[64];
	new String:password[512];
	GetConVarString(g_h_lw_group_name, username, sizeof(username));
	GetConVarString(g_h_lw_group_password, password, sizeof(password));
	
	new hostIP = GetConVarInt(FindConVar("hostip"));
	new String:ipAddress[32];
	// convert ip address to standard dotted notation
	Format(ipAddress, sizeof(ipAddress), "%d.%d.%d.%d", hostIP >>> 24, 0xFF & (hostIP >>> 16), 0xFF & (hostIP >>> 8), 0xFF & hostIP);
	
	EscapeString(username, sizeof(username));
	EscapeString(password, sizeof(password));
	LogLiveWireEvent("{\"event\": \"server_status\", \"game\": \"csgo\", \"version\": \"%s\", \"ip\": \"%s\", \"port\": %d, \"username\": \"%s\", \"password\": \"%s\", \"unixTime\": %d}", WM_VERSION, ipAddress, GetConVarInt(FindConVar("hostport")), username, password, GetTime());
	
	LogPlayers(true);
}

public OnSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:arg)
{
	/* do nothing */
}

public OnSocketDisconnected(Handle:socket, any:arg)
{
	g_lw_connecting = false;
	g_lw_connected = false;
	CloseHandle(socket);
	PrintToServer("<LiveWire> Disconnected");
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:hFile)
{
	g_lw_connecting = false;
	g_lw_connected = false;
	LogError("GameTech LiveWire - Socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

public OnMapStart()
{
	decl String:g_MapName[64], String:g_WorkShopID[64];
	decl String:g_CurMap[128];
	GetCurrentMap(g_CurMap, sizeof(g_CurMap));
	if (StrContains(g_CurMap, "workshop", false) != -1)
	{
		GetCurrentWorkshopMap(g_MapName, sizeof(g_MapName), g_WorkShopID, sizeof(g_WorkShopID));
		LogMessage("Current Map: %s  Workshop ID: %s", g_MapName, g_WorkShopID);
	}
	else
	{
		strcopy(g_map, sizeof(g_map), g_CurMap);
		LogMessage("Current Map: %s", g_CurMap);
	}
	StringToLower(g_map, sizeof(g_map));
	
	if (GetConVarBool(g_h_lw_enabled) && !g_lw_connected)
	{
		// connect to livewire
		LiveWire_Connect();
	}
	
	if (GetConVarBool(g_h_stats_trace_enabled))
	{
		// start trace timer
		g_stats_trace_timer = CreateTimer(GetConVarFloat(g_h_stats_trace_delay), Stats_Trace, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// reset any matches
	ResetMatch(true);
	g_bRecording = false;
}

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "adminmenu"))
	{
		g_h_menu = INVALID_HANDLE;
	}
}

public OnAdminMenuReady(Handle:topmenu)
{
	if (topmenu == g_h_menu)
	{
		return;
	}
	
	g_h_menu = topmenu;
	new TopMenuObject:new_menu = AddToTopMenu(g_h_menu, "WarModCommands", TopMenuObject_Category, MenuHandler, INVALID_TOPMENUOBJECT);
	
	if (new_menu == INVALID_TOPMENUOBJECT)
	{
		return;
	}
	
	// add menu items
	AddToTopMenu(g_h_menu, "forcestart", TopMenuObject_Item, MenuHandler, new_menu, "forcestart", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "readyup", TopMenuObject_Item, MenuHandler, new_menu, "readyup", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "knife", TopMenuObject_Item, MenuHandler, new_menu, "knife", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "cancelhalf", TopMenuObject_Item, MenuHandler, new_menu, "cancelhalf", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "cancelmatch", TopMenuObject_Item, MenuHandler, new_menu, "cancelmatch", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "forceallready", TopMenuObject_Item, MenuHandler, new_menu, "forceallready", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "forceallunready", TopMenuObject_Item, MenuHandler, new_menu, "forceallunready", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "forceallspectate", TopMenuObject_Item, MenuHandler, new_menu, "forceallspectate", ADMFLAG_CUSTOM1);
	AddToTopMenu(g_h_menu, "toggleactive", TopMenuObject_Item, MenuHandler, new_menu, "toggleactive", ADMFLAG_CUSTOM1);
}

public OnClientConnected(client)
{
	if (!GetConVarBool(g_h_lw_enabled)) {
		return;
	}
	
	new count = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			count++;
		}
	}
	if (count == 1)
	{
		// reconnect livewire on first player join, server seems to go to sleep
		// when there are no players in the server (e.g. server start)
		LiveWire_ReConnect(0, 0);
	}
}

public OnClientPostAdminCheck(client)
{
	if (client == 0)
	{
		return;
	}
	
	new String:ip_address[32];
	GetClientIP(client, ip_address, sizeof(ip_address));
	IsFakeClient(client);
	if (!IsActive(0, true))
	{
		// warmod is disabled
		return;
	}
	
	if (GetConVarBool(g_h_stats_enabled) && client != 0)
	{
		new String:log_string[384];
		CS_GetLogString(client, log_string, sizeof(log_string));
		
		new String:country[4];
		GeoipCode2(ip_address, country);
		
		EscapeString(ip_address, sizeof(ip_address));
		LogEvent("{\"event\": \"player_connect\", \"player\": %s, \"address\": \"%s\", \"country\": \"%s\"}", log_string, ip_address, country);
	}
}

public OnClientPutInServer(client)
{
	// reset client state
	g_player_list[client] = PLAYER_DISC;
	g_cancel_list[client] = false;
}

public OnClientDisconnect(client)
{
	// reset client state
	g_player_list[client] = PLAYER_DISC;
	g_premium_list[client] = false;
	g_cancel_list[client] = false;
	
	// log player stats
	LogPlayerStats(client);
	
	if (!IsActive(client, true))
	{
		// warmod is disabled
		return;
	}
	
	if (g_ready_enabled && !g_live)
	{
		// display ready system
		ShowInfo(client, true, false, 0);
	}
}

ResetMatch(bool:silent)
{
	if (g_match)
	{
		Call_StartForward(g_f_on_reset_match);
		Call_Finish();
		if (GetConVarBool(g_h_stats_enabled))
		{
			new String:event_name[] = "match_reset";
			LogSimpleEvent(event_name, sizeof(event_name));
		}
		// end of log
		new String:event_name[] = "log_end";
		LogSimpleEvent(event_name, sizeof(event_name));
		// execute relevant server config
		new String:end_config[128];
		GetConVarString(g_h_end_config, end_config, sizeof(end_config));
		ServerCommand("exec %s", end_config);
		//stop demo from uploading
		g_MatchComplete = false;
	}
	
	if (g_log_file != INVALID_HANDLE)
	{
		// close log file
		FlushFile(g_log_file);
		CloseHandle(g_log_file);
		g_log_file = INVALID_HANDLE;
	}
	
	// reset state
	g_start = false;
	g_match = false;
	g_live = false;
	g_half_swap = true;
	g_first_half = true;
	g_second_half_first = false;
	g_t_money = false;
	g_t_score = false;
	g_t_knife = false;
	g_t_had_knife = false;
	g_playing_out = false;
	SetAllCancelled(false);
	ReadyChangeAll(0, false, true);
	ResetMatchScores();
	ResetTeams();
	g_overtime = false;
	g_overtime_count = 0;
	g_t_pause_count = 0;
	g_ct_pause_count = 0;
	ServerCommand("mp_unpause_match 1");
	if (g_h_stored_timer != INVALID_HANDLE)
	{
		KillTimer(g_h_stored_timer);
		g_h_stored_timer = INVALID_HANDLE;
	}
	if (g_h_stored_timer_p != INVALID_HANDLE)
	{
		KillTimer(g_h_stored_timer_p);
		g_h_stored_timer_p = INVALID_HANDLE;
	}
	UpdateStatus();
	
	// stop tv recording after 5 seconds
	CreateTimer(5.0, StopRecord);
	CreateTimer(5.0, LogFileUpload);
	
	if (GetConVarBool(g_h_auto_ready))
	{
		// enable ready system
		ReadySystem(true);
		ShowInfo(0, true, false, 0);
		// update status code
		UpdateStatus();
	}
	else if (g_ready_enabled)
	{
		// disable ready system
		ReadySystem(false);
		ShowInfo(0, false, false, 1);
	}
	
	if (!silent)
	{
		// message display to players
		for (new x = 1; x <= 3; x++)
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Match Reset");
		}
		// restart round
		ServerCommand("mp_restartgame 1");
	}
}

ResetHalf(bool:silent)
{
	if (g_match)
	{
		Call_StartForward(g_f_on_reset_half);
		Call_Finish();
		if (GetConVarBool(g_h_stats_enabled))
		{
			new String:event_name[] = "match_half_reset";
			LogSimpleEvent(event_name, sizeof(event_name));
		}
	}
	if (!g_first_half)
	{
		g_half_swap = true;
	}
	
	// reset half state
	g_live = false;
	g_t_money = false;
	g_t_score = false;
	g_t_knife = false;
	g_playing_out = false;
	SetAllCancelled(false);
	ReadyChangeAll(0, false, true);
	ResetHalfScores();
	UpdateStatus();
	g_t_pause_count = 0;
	g_ct_pause_count = 0;
	ServerCommand("mp_unpause_match 1");
	if (g_h_stored_timer != INVALID_HANDLE)
	{
		KillTimer(g_h_stored_timer);
		g_h_stored_timer = INVALID_HANDLE;
	}
	if (g_h_stored_timer_p != INVALID_HANDLE)
	{
		KillTimer(g_h_stored_timer_p);
		g_h_stored_timer_p = INVALID_HANDLE;
	}
	
	if (GetConVarBool(g_h_auto_ready))
	{
		// display ready system
		ReadySystem(true);
		ShowInfo(0, true, false, 0);
		UpdateStatus();
	}
	else
	{
		// disable ready system
		ReadySystem(false);
		ShowInfo(0, false, false, 1);
	}
	
	if (!silent)
	{
		// display message for players
		for (new x = 1; x <= 3; x++)
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Reset");
		}
		// restart round
		ServerCommand("mp_restartgame 1");
	}
}

ResetTeams()
{
	// set team names to default
	g_t_name = DEFAULT_T_NAME;
	g_t_name_escaped = g_t_name;
	EscapeString(g_t_name_escaped, sizeof(g_t_name_escaped));
	g_ct_name = DEFAULT_CT_NAME;
	g_ct_name_escaped = g_ct_name;
	EscapeString(g_ct_name_escaped, sizeof(g_ct_name_escaped));
	SetConVarStringHidden(g_h_t, DEFAULT_T_NAME);
	SetConVarStringHidden(g_h_ct, DEFAULT_CT_NAME);
}

ResetMatchScores()
{
	// reset match scores
	g_scores[SCORE_T][SCORE_FIRST_HALF] = 0;
	g_scores[SCORE_T][SCORE_SECOND_HALF] = 0;
	
	g_scores[SCORE_CT][SCORE_FIRST_HALF] = 0;
	g_scores[SCORE_CT][SCORE_SECOND_HALF] = 0;
	
	// reset overtime scores
	for (new i = 0; i <= g_overtime_count; i++)
	{
		g_scores_overtime[SCORE_T][i][SCORE_FIRST_HALF] = 0;
		g_scores_overtime[SCORE_T][i][SCORE_SECOND_HALF] = 0;
		
		g_scores_overtime[SCORE_CT][i][SCORE_FIRST_HALF] = 0;
		g_scores_overtime[SCORE_CT][i][SCORE_SECOND_HALF] = 0;
	}
}
ResetHalfScores()
{
	// reset scores for the current half
	if (!g_overtime)
	{
		// not overtime
		if (g_first_half)
		{
			// first half
			g_scores[SCORE_T][SCORE_FIRST_HALF] = 0;
			g_scores[SCORE_CT][SCORE_FIRST_HALF] = 0;
		}
		else
		{
			// second half
			g_scores[SCORE_T][SCORE_SECOND_HALF] = 0;
			g_scores[SCORE_CT][SCORE_SECOND_HALF] = 0;
		}
	}
	else
	{
		// overtime
		if (g_first_half)
		{
			// first half overtime
			g_scores_overtime[SCORE_T][g_overtime_count][SCORE_FIRST_HALF] = 0;
			g_scores_overtime[SCORE_CT][g_overtime_count][SCORE_FIRST_HALF] = 0;
		}
		else
		{
			// second half overtime
			g_scores_overtime[SCORE_T][g_overtime_count][SCORE_SECOND_HALF] = 0;
			g_scores_overtime[SCORE_CT][g_overtime_count][SCORE_SECOND_HALF] = 0;
		}
	}
}

public Action:ReadyToggle(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (IsLive(client, false))
	{
		// match is live
		return Plugin_Handled;
	}
	
	// change ready state
	ReadyChangeAll(client, false, true);
	SetAllCancelled(false);
	
	if (!IsReadyEnabled(client, true))
	{
		// display ready system
		ReadySystem(true);
		ShowInfo(client, true, false, 0);
		if (client != 0)
		{
			PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Enabled");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Ready System Enabled", LANG_SERVER);
		}
		// check if anyone is ready
		CheckReady();
	}
	else
	{
		// disable ready system
		ShowInfo(client, false, false, 1);
		ReadySystem(false);
		if (client != 0)
		{
			PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Disabled");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Ready System Disabled", LANG_SERVER);
		}
	}
	
	LogAction(client, -1, "\"ready_toggle\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:ActiveToggle(client, args)
{
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (GetConVarBool(g_h_active))
	{
		// disable warmod
		SetConVarBool(g_h_active, false);
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Inactive");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Set Inactive", LANG_SERVER);
		}
	}
	else
	{
		// enable warmod
		SetConVarBool(g_h_active, true);
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Active");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Set Active", LANG_SERVER);
		}
	}
	
	LogAction(client, -1, "\"active_toggle\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

//Pause and Unpause Commands + timers
public Action:Pause(client, args)
{
    if (GetConVarBool(sv_pausable) && g_live)
    {
        if (GetConVarBool(g_h_pause_confirm))
        {
			if (GetClientTeam(client) == 2 && g_pause_offered_ct == true)
			{
				if(g_h_stored_timer_p != INVALID_HANDLE)
				{
					KillTimer(g_h_stored_timer_p);
					g_h_stored_timer_p = INVALID_HANDLE;
				}
				
				g_pause_offered_ct = false;
				g_ct_pause_count++;
				
				//if (GetConVarBool(g_h_pause_freezetime))
				//{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Freeze Time", LANG_SERVER);
				g_pause_freezetime = true;
				/*}
				else
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
					if (GetConVarBool(g_h_auto_unpause))
					{
						PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
						g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
					}*/
				g_paused = true;
				if (FreezeTime)
				{
						//Pause command fire on round end May change to on round start
					if (g_pause_freezetime == true)
					{
						g_pause_freezetime = false;
						PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
						if(GetConVarBool(g_h_auto_unpause))
						{
							PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
							g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
						}
						ServerCommand("mp_pause_match 1");
					}
				}
				return;
			}
			else if (GetClientTeam(client) == 3 && g_pause_offered_t == true)
			{
				if(g_h_stored_timer_p != INVALID_HANDLE)
				{
					KillTimer(g_h_stored_timer_p);
					g_h_stored_timer_p = INVALID_HANDLE;
				}
				g_pause_offered_t = false;
				g_t_pause_count++;
				
				//if (GetConVarBool(g_h_pause_freezetime))
				//{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Round End", LANG_SERVER);
				g_pause_freezetime = true;
				/*}
				else
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
					if (GetConVarBool(g_h_auto_unpause))
					{
						PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
						g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
					}*/
				g_paused = true;
				if (FreezeTime)
				{
						//Pause command fire on round end May change to on round start
					if (g_pause_freezetime == true)
					{
						g_pause_freezetime = false;
						PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
						if(GetConVarBool(g_h_auto_unpause))
						{
							PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
							g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
						}
						ServerCommand("mp_pause_match 1");
					}
				}
				return;
				//}
			}
			else if (GetClientTeam(client) == 2 && g_t_pause_count == GetConVarInt(g_h_pause_limit))
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Limit", LANG_SERVER);
			}
			else if (GetClientTeam(client) == 3 && g_ct_pause_count == GetConVarInt(g_h_pause_limit))
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Limit", LANG_SERVER);
			}
			else if (GetClientTeam(client) < 2 )
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Non-player", LANG_SERVER);
			}
			else if (GetClientTeam(client) == 3 && g_ct_pause_count != GetConVarInt(g_h_pause_limit) && g_pause_offered_ct == false)
			{
				g_pause_offered_ct = true;
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_ct_name, "Pause Offer", LANG_SERVER);
				g_h_stored_timer_p = CreateTimer(30.0, PauseTimeout);
			}
			else if (GetClientTeam(client) == 2 && g_t_pause_count != GetConVarInt(g_h_pause_limit) && g_pause_offered_t == false)
			{
				g_pause_offered_t = true;
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_t_name, "Pause Offer", LANG_SERVER);
				g_h_stored_timer_p = CreateTimer(30.0, PauseTimeout);
			}
		}
		else if (GetClientTeam(client) == 3 && g_ct_pause_count != GetConVarInt(g_h_pause_limit) && !GetConVarBool(g_h_pause_confirm))
		{
			g_ct_pause_count++;
			//if (GetConVarBool(g_h_pause_freezetime))
			//{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Freeze Time", LANG_SERVER);
			g_pause_freezetime = true;
			/*}
			else
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
				if(GetConVarBool(g_h_auto_unpause))
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
					g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
				}*/
			g_paused = true;
			if (FreezeTime)
			{
					//Pause command fire on round end May change to on round start
				if (g_pause_freezetime == true)
				{
					g_pause_freezetime = false;
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
					if(GetConVarBool(g_h_auto_unpause))
					{
						PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
						g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
					}
					ServerCommand("mp_pause_match 1");
				}
			}
			return;
			//}
		}
		else if (GetClientTeam(client) == 2 &&  g_t_pause_count != GetConVarInt(g_h_pause_limit) && GetConVarBool(g_h_pause_confirm) == false)
		{
			g_t_pause_count++;
			//if (GetConVarBool(g_h_pause_freezetime))
			//{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Freeze Time", LANG_SERVER);
			g_pause_freezetime = true;
			/*}
			else
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
				if(GetConVarBool(g_h_auto_unpause))
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
					g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
				}*/
			g_paused = true;
			if (FreezeTime)
			{
					//Pause command fire on round end May change to on round start
				if (g_pause_freezetime == true)
				{
					g_pause_freezetime = false;
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
					if(GetConVarBool(g_h_auto_unpause))
					{
						PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
						g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
					}
					ServerCommand("mp_pause_match 1");
				}
			}
			return;
			//}
		}
		else if (GetClientTeam(client) == 2 && g_t_pause_count == GetConVarInt(g_h_pause_limit))
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Limit", LANG_SERVER);
		}
		else if (GetClientTeam(client) == 3 && g_ct_pause_count == GetConVarInt(g_h_pause_limit))
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Limit", LANG_SERVER);
		}
		else if (GetClientTeam(client) < 2)
		{
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Non-player", LANG_SERVER);
		}
	}
	else if (!g_live)
	{
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Match Not In Progress", LANG_SERVER);
	}
	else
	{
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Not Enabled", LANG_SERVER);
	}
}

public Action:Unpause(client, args)
{
	if (g_paused)
	{
		if (GetConVarBool(g_h_pause_confirm))
		{
			if (GetClientTeam(client) == 3 && g_pause_offered_ct == false && g_pause_offered_t == false)
			{
				g_pause_offered_ct = true;
				PrintToConsoleAll("<WarMod_BFG> CT have asked to unpause the game. Please type /unpause to unpause the match.");
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_ct_name, "Unpause Offer", LANG_SERVER);
			}
			else if (GetClientTeam(client) == 2 && g_pause_offered_t == false && g_pause_offered_ct == false)
			{
				g_pause_offered_t = true;
				PrintToConsoleAll("<WarMod_BFG> T have asked to unpause the game. Please type /unpause to unpause the match.");
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_t_name, "Unpause Offer", LANG_SERVER);
			}
			else if (GetClientTeam(client) == 2 && g_pause_offered_ct == true)
			{
				g_pause_offered_ct = false;
				g_paused = false;
				ServerCommand("mp_unpause_match 1");
				if (g_h_stored_timer != INVALID_HANDLE)
				{
					KillTimer(g_h_stored_timer);
					g_h_stored_timer = INVALID_HANDLE;
				}
			}
			else if (GetClientTeam(client) == 3 && g_pause_offered_t == true)
			{
				g_pause_offered_t = false;
				g_paused = false;
				ServerCommand("mp_unpause_match 1");
				if (g_h_stored_timer != INVALID_HANDLE)
				{
					KillTimer(g_h_stored_timer);
					g_h_stored_timer = INVALID_HANDLE;
				}
			}
			else if (GetClientTeam(client) < 2 )
			{
				PrintToConsole(client, "<WarMod_BFG> You must be on T or CT to enable /unpause");
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Non-player", LANG_SERVER);
			}
		}
		else
		{
			if (GetClientTeam(client) == 2)
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_t_name, "Unpaused Match", LANG_SERVER);
				g_paused = false;
				ServerCommand("mp_unpause_match 1");
				if (g_h_stored_timer != INVALID_HANDLE)
				{
					KillTimer(g_h_stored_timer);
					g_h_stored_timer = INVALID_HANDLE;
				}
			}
			else if (GetClientTeam(client) == 3)
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_ct_name, "Unpaused Match", LANG_SERVER);
				g_paused = false;
				ServerCommand("mp_unpause_match 1");
				if (g_h_stored_timer != INVALID_HANDLE)
				{
					KillTimer(g_h_stored_timer);
					g_h_stored_timer = INVALID_HANDLE;
				}
			}
			else if (GetClientTeam(client) < 2 )
			{
				PrintToConsole(client, "<WarMod_BFG> You must be on T or CT to enable /unpause");
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Non-player", LANG_SERVER);
			}
		}
	}
	else
	{
		PrintToChat(client,"\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Paused Via Rcon", LANG_SERVER);
		PrintToConsole(client,"<WarMod_BFG> Server is not paused or was paused via rcon");
	}
}

public Action:PauseTimeout(Handle:timer)
{
	g_h_stored_timer_p = INVALID_HANDLE;
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Pause Offer Not Confirmed", LANG_SERVER);
	g_pause_offered_ct = false;
	g_pause_offered_t = false;
}

public Action:UnPauseTimer(Handle:timer)
{
	g_h_stored_timer = INVALID_HANDLE;
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Auto", LANG_SERVER);
	ServerCommand("mp_unpause_match 1");
	g_pause_offered_ct = false;
	g_pause_offered_t = false;
}

public Action:UploadResults(Handle:timer)
{
	new match_length = RoundFloat(GetEngineTime() - g_match_start);
	if (GetConVarBool(g_h_sql_beta))
	{
		MySQL_UploadResultsBeta(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
	}
	else
	{
		MySQL_UploadResults(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
	}
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Results uploaded", CHAT_PREFIX);
}

public Action:Name(client, args)
{
	if (!IsValidClient(client))
	{
		return;
	}
	else if (!g_p_ct_name && GetClientTeam(client) == 3)
	{
		return;
	}
	else if (!g_p_t_name && GetClientTeam(client) == 2)
	{
		return;
	}
	else if (GetClientTeam(client) < 2)
	{
		return;
	}
	
	new String:sName[64];
	GetCmdArgString(sName, sizeof(sName));
	StripQuotes(sName);
	
	if (g_p_t_name && GetClientTeam(client) == 2)
	{
		new String:name_old[64];
		Format(name_old, sizeof(name_old), "%s", g_t_name);
		Format(g_t_name, sizeof(g_t_name), "%s", sName);
		g_t_name_escaped = g_t_name;
		EscapeString(g_t_name_escaped, sizeof(g_t_name_escaped));
		SetConVarStringHidden(g_h_t, sName);
		LogEvent("{\"event\": \"name_change\", \"team\": 2, \"old\": %s, \"new\": %s}", name_old, g_t_name);
		ServerCommand("mp_teamname_2 %s", g_t_name);
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Terrorists are called \x09%s", CHAT_PREFIX, g_t_name);
		g_p_t_name = false;
	}
	
	if (g_p_ct_name && GetClientTeam(client) == 3)
	{
		new String:name_old[64];
		Format(name_old, sizeof(name_old), "%s", g_ct_name);
		Format(g_ct_name, sizeof(g_ct_name), "%s", sName);
		g_ct_name_escaped = g_ct_name;
		EscapeString(g_ct_name_escaped, sizeof(g_ct_name_escaped));
		SetConVarStringHidden(g_h_ct, sName);
		LogEvent("{\"event\": \"name_change\", \"team\": 3, \"old\": %s, \"new\": %s}", name_old, g_ct_name);
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Counter Terrorists are called \x09%s", CHAT_PREFIX, g_ct_name);
		ServerCommand("mp_teamname_1 %s", g_ct_name);
		g_p_ct_name = false;
	}
	
	CheckReady();
}

public Action:ResetMatchTimer(Handle:timer)
{
	ResetMatch(true);
}

stock bool:IsValidClient(client)
{
	if (client <= 0 || client > MaxClients) 
	{
		return false;
	}
	
	if (!IsClientInGame(client)) 
	{
		return false;
	}
	
	if (IsFakeClient(client))
	{
		return false;
	}
	
	if (!IsClientConnected(client))
	{
		return false;
	}
	
	if (IsClientSourceTV(client) || IsClientReplay(client)) 
	{
		return false;
	}
	
	return true;
}

public Action:ChangeMinReady(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	new String:arg[128];
	new minready;
	
	if (GetCmdArgs() > 0)
	{
		// setter
		GetCmdArg(1, arg, sizeof(arg));
		minready = StringToInt(arg);
		SetConVarInt(g_h_min_ready, minready);
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Minready", minready);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Set Minready", LANG_SERVER, minready);
		}
		LogAction(client, -1, "\"set_min_ready\" (player \"%L\") (min_ready \"%d\")", client, minready);
	}
	else
	{
		// getter
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 wm_min_ready = %d", CHAT_PREFIX, GetConVarInt(g_h_min_ready));
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 - wm_min_ready = %d", CHAT_PREFIX, GetConVarInt(g_h_min_ready));
		}
	}
	
	return Plugin_Handled;
}

public Action:ChangeMaxRounds(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	new String:arg[128];
	new maxrounds;
	
	if (GetCmdArgs() > 0)
	{
		// setter
		GetCmdArg(1, arg, sizeof(arg));
		maxrounds = StringToInt(arg);
		SetConVarInt(g_h_max_rounds, maxrounds);
		new rounds = (maxrounds*2);
		ServerCommand("mp_maxrounds %i", rounds);
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Maxrounds", maxrounds);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Set Maxrounds", LANG_SERVER, maxrounds);
		}
		LogAction(client, -1, "\"set_max_rounds\" (player \"%L\") (max_rounds \"%d\")", client, maxrounds);
	}
	else
	{
		// getter
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 wm_max_rounds = %d", CHAT_PREFIX, GetConVarInt(g_h_max_rounds));
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 - wm_max_rounds = %d", CHAT_PREFIX, GetConVarInt(g_h_max_rounds));
		}
	}
	
	return Plugin_Handled;
}

public Action:ChangePassword(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	new String:new_password[128];
	
	if (GetCmdArgs() > 0)
	{
		// setter
		GetCmdArg(1, new_password, sizeof(new_password));
		ServerCommand("sv_password \"%s\"", new_password);
		
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Password", new_password);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Set Password", LANG_SERVER, new_password);
		}
		
		LogAction(client, -1, "\"set_password\" (player \"%L\")", client);
	}
	else
	{
		// getter
		new String:passwd[128];
		GetConVarString(FindConVar("sv_password"), passwd, sizeof(passwd));
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 sv_password = '%s'", CHAT_PREFIX, passwd);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 - sv_password = '%s'", CHAT_PREFIX, passwd);
		}
	}
	
	return Plugin_Handled;
}

ReadyUp(client)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return;
	}
	
	if (!IsReadyEnabled(client, false) || client == 0)
	{
		// ready system not enabled or client is the console
		return;
	}
	
	if (IsLive(client, false))
	{
		// match already live
		return;
	}
	
	if (g_player_list[client] != PLAYER_READY)
	{
		if (GetClientTeam(client) > 1)
		{
			// set player as ready
			ReadyServ(client, true, false, true, false);
		}
		else
		{
			// player is not on a valid team
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Not on Team");
		}
	}
	else
	{
		// player is already ready
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Already Ready");
	}
}

ReadyDown(client)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return;
	}
	
	if (!IsReadyEnabled(client, false) || client == 0)
	{
		// ready system not enabled or client is the console
		return;
	}
	
	if (IsLive(client, false))
	{
		return;
	}
	
	if (g_player_list[client] != PLAYER_UNREADY)
	{
		if (GetClientTeam(client) > 1)
		{
			// set player as ready
			ReadyServ(client, false, false, true, false);
		}
		else
		{
			// player is not on a valid team
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Not on Team");
		}
	}
	else
	{
		// player is already ready
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Already Not Ready");
	}
}

public Action:ForceAllReady(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (g_ready_enabled)
	{
		// force all players to ready
		ReadyChangeAll(client, true, true);
		// check if there is enough players
		CheckReady();
		
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Forced Ready");
		}
		else
		{
			PrintToConsole(client, "<WarMod_BFG> %T", "Forced Ready", LANG_SERVER);
		}
		
		// display ready system
		ShowInfo(client, true, false, 0);
	}
	else
	{
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Disabled2");
		}
		else
		{
			PrintToConsole(client, "<WarMod_BFG> %T", "Ready System Disabled2", LANG_SERVER);
		}
	}
	
	LogAction(client, -1, "\"force_all_ready\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:ForceAllUnready(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (g_ready_enabled)
	{
		// force all players to unready
		ReadyChangeAll(client, false, true);
		CheckReady();
		
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Forced Not Ready");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Forced Not Ready", LANG_SERVER);
		}
		
		// display readym system
		ShowInfo(client, true, false, 0);
	}
	else
	{
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Disabled2");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Ready System Disabled2", LANG_SERVER);
		}
	}
	
	LogAction(client, -1, "\"force_all_unready\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:ForceAllSpectate(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}

	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	// reset half and restart
	ForceSpectate();
	ResetHalf(true);
	ShowInfo(0, false, false, 1);
	SetAllCancelled(false);
	ReadySystem(false);
	
	LogAction(client, -1, "\"force__all_spec\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

ForceSpectate()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if(GetClientTeam(i) != 1)
			{
				ChangeClientTeam(i, 1);
			}
			else
			{
				PrintToChat(i, "You are already a spectator.");
			}
		}
	}
}

public Action:ForceStart(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (!g_t_had_knife && !g_match && GetConVarBool(g_h_auto_knife))
	{
		ShowInfo(0, false, false, 1);
		SetAllCancelled(false);
		ReadySystem(false);
		KnifeOn3(0, 0);
		LogAction(client, -1, "\"force_start\" (player \"%L\")", client);
		return Plugin_Handled;
	}
	// reset half and restart
	ResetHalf(true);
	ShowInfo(0, false, false, 1);
	SetAllCancelled(false);
	ReadySystem(false);
	ServerCommand("mp_warmup_end");
	LiveOn3(true);
	
	LogAction(client, -1, "\"force_start\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:ForceEnd(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:event_name[] = "force_end";
		LogSimpleEvent(event_name, sizeof(event_name));
	}
	
	// reset match
	ResetMatch(true);
	
	LogAction(client, -1, "\"force_end\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:ReadyOn(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (IsLive(client, false))
	{
		return Plugin_Handled;
	}
	
	// reset ready system
	ReadyChangeAll(client, false, true);
	SetAllCancelled(false);
	
	// enable ready system
	ReadySystem(true);
	ShowInfo(client, true, false, 0);
	if (client != 0)
	{
		PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Enabled");
	}
	else
	{
		PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Ready System Enabled", LANG_SERVER);
	}
	CheckReady();
	
	LogAction(client, -1, "\"ready_on\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:ReadyOff(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (IsLive(client, false))
	{
		return Plugin_Handled;
	}
	
	// reset ready system
	ReadyChangeAll(client, false, true);
	SetAllCancelled(false);
	
	if (IsReadyEnabled(client, true))
	{
		// disable ready sytem
		ShowInfo(client, false, false, 1);
		ReadySystem(false);
	}
	
	if (client != 0)
	{
		PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Disabled");
	}
	else
	{
		PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Ready System Disabled", LANG_SERVER);
	}
	
	LogAction(client, -1, "\"ready_off\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:ConsoleScore(client, args)
{
	// display score
	if (g_match)
	{
		if (g_live)
		{
			if (client != 0)
			{
				PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01 %t:", CHAT_PREFIX, "Match Is Live");
			}
			else
			{
				PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T:", CHAT_PREFIX, "Match Is Live", LANG_SERVER);
			}
		}
		PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01  %s: [%d] %s: [%d] MR%d", CHAT_PREFIX, g_t_name, GetTScore(), g_ct_name, GetCTScore(), GetConVarInt(g_h_max_rounds));
		if (g_overtime)
		{
			PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01 %t (%d): %s: [%d], %s: [%d] MR%d", CHAT_PREFIX, "Score Overtime", g_overtime_count + 1, g_t_name, GetTOTScore(), g_ct_name, GetCTOTScore(), GetConVarInt(g_h_overtime_mr));
		}
	}
	else
	{
		if (client != 0)
		{
			PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Match Not In Progress");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Match Not In Progress", LANG_SERVER);
		}
	}
	
	return Plugin_Handled;
}

stock PrintToConsoleAll(const String:message[])
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			PrintToConsole(i, message);
		}
	}
}  

public Action:LastMatch(client, args)
{
	// display details of last match to the console
	if (g_last_scores[SCORE_T] != -1)
	{
		PrintToConsole(client, "\x01 \x09[\x04%s\x09]\x01  Last Match: \x02%s [%d] \x0C%s [%d] \x01MR%d", CHAT_PREFIX, g_last_names[SCORE_T], g_last_scores[SCORE_T], g_last_names[SCORE_CT], g_last_scores[SCORE_CT], g_last_maxrounds);
	}
	else
	{
		PrintToConsole(client, "<WarMod_BFG> No Matches Played");
	}
	return Plugin_Handled;
}

// work in progress
public Action:SetScoreT(client, args)
{
	if (IsAdminCmd(client, false))
	{
		decl String:argstring[16];
		GetCmdArgString(argstring, sizeof(argstring));
		new intToUse;
		
		if(strlen(argstring) < 1)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 Choose a score between 0 and 30", CHAT_PREFIX);
		}
		else
		{
			if (isNumeric(argstring))
			{
				intToUse = StringToInt(argstring);
			}
			else
			{
				intToUse = -1;
			}

			if (g_live)
			{
				if (intToUse > 30 || intToUse < 0)
				{
					PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 Choose a score between 0 and 30", CHAT_PREFIX);
				}
				else
				{
					if (!g_warmod_safemode)
					{
						CS_SetTeamScore(TERRORIST_TEAM, intToUse);
						SetTeamScore(TERRORIST_TEAM, intToUse);
						g_scores[SCORE_T][SCORE_FIRST_HALF] = intToUse;
						PrintToChatAll("\x01 \x09[\x04%s\x09] \x02Terrorists \x01score changed to \x04%d", CHAT_PREFIX, intToUse);
					}
					else
					{
						PrintToChatAll("\x01 \x09[\x04%s\x09] %t", CHAT_PREFIX, "Safe Mode");
					}
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action:SetScoreCT(client, args)
{
	if (IsAdminCmd(client, false))
	{
		decl String:argstring[16];
		GetCmdArgString(argstring, sizeof(argstring));
		new intToUse;
		
		if(strlen(argstring) < 1)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 Choose a score between 0 and 30", CHAT_PREFIX);
		}
		else
		{
			if (isNumeric(argstring))
			{
				intToUse = StringToInt(argstring);
			}
			else
			{
				intToUse = -1;
			}

			if (g_live)
			{
				if (intToUse > 30 || intToUse < 0)
				{
					PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 Choose a score between 0 and 30", CHAT_PREFIX);
				}
				else
				{
					if (!g_warmod_safemode)
					{
						CS_SetTeamScore(COUNTER_TERRORIST_TEAM, intToUse);
						SetTeamScore(COUNTER_TERRORIST_TEAM, intToUse);
						g_scores[SCORE_CT][SCORE_FIRST_HALF] = intToUse;
						PrintToChatAll("\x01 \x09[\x04%s\x09] \x0CCounter Terrorists \x01score changed to \x04%d", CHAT_PREFIX, intToUse);
					}
					else
					{
						PrintToChatAll("\x01 \x09[\x04%s\x09] %t", CHAT_PREFIX, "Safe Mode");
					}
				}
			}
		}
	}
	return Plugin_Handled;
}

ShowScore(client)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return;
	}
	
	if (g_match)
	{
		// display score
		if (!g_overtime)
		{
			DisplayScore(client, 0, true);
		}
		else
		{
			DisplayScore(client, 1, true);
		}
	}
	else
	{
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Match Not In Progress");
	}
	
	return;
}

DisplayScore(client, msgindex, bool:priv)
{
	if (!GetConVarBool(g_h_ingame_scores))
	{
		return;
	}
	
	if (msgindex == 0) // standard play score
	{
		new String:score_msg[192];
		GetScoreMsg(client, score_msg, sizeof(score_msg), GetTScore(), GetCTScore());
		if (priv)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01  %s", CHAT_PREFIX, score_msg);
		}
		else
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01  %s", CHAT_PREFIX, score_msg);
		}
	}
	else if (msgindex == 1) // overtime play score
	{
		new String:score_msg[192];
		GetScoreMsg(client, score_msg, sizeof(score_msg), GetTOTScore(), GetCTOTScore());
		if (priv)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t%s", CHAT_PREFIX, "Score Overtime", score_msg);
		}
		else
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t%s", CHAT_PREFIX, "Score Overtime", score_msg);
		}
	}
	else if (msgindex == 2) // overall play score
	{
		new String:score_msg[192];
		GetScoreMsg(client, score_msg, sizeof(score_msg), GetTTotalScore(), GetCTTotalScore());
		if (priv)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t%s", CHAT_PREFIX, "Score Overall", score_msg);
		}
		else
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t%s", CHAT_PREFIX, "Score Overall", score_msg);
		}
	}
}

public GetScoreMsg(client, String:result[], maxlen, t_score, ct_score)
{
	SetGlobalTransTarget(client);
	if (t_score > ct_score)
	{
		Format(result, maxlen, "\x02%t \x04%d\x03-\x04%d", "T Winning", g_t_name, t_score, ct_score);
	}
	else if (t_score == ct_score)
	{
		Format(result, maxlen, "\x01%t \x04%d\03-\x04%d", "Tied", t_score, ct_score);
	}
	else
	{
		Format(result, maxlen, "\x0C%t \x04%d\x03-\x04%d", "CT Winning", g_ct_name, ct_score, t_score);
	}
}

ReadyInfoPriv(client)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return;
	}
	
	if (!IsReadyEnabled(client, false))
	{
		return;
	}
	
	if (client != 0 && !g_live)
	{
		g_cancel_list[client] = false;
		ShowInfo(client, true, true, 0);
	}
}

public Event_Round_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	FreezeTime = true;
	
	//Pause command fire on round end May change to on round start
	if (g_pause_freezetime == true)
	{
		g_pause_freezetime = false;
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Unpause Notice", LANG_SERVER);
		if(GetConVarBool(g_h_auto_unpause))
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %i %T", CHAT_PREFIX, GetConVarInt(g_h_auto_unpause_delay), "Unpause Timer", LANG_SERVER);
			g_h_stored_timer = CreateTimer(GetConVarFloat(g_h_auto_unpause_delay), UnPauseTimer);
		}
		g_paused = true;
		ServerCommand("mp_pause_match 1");
	}
	
	if (GetConVarBool(g_h_stats_enabled))
	{
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"knife_round_start\", \"freezeTime\": %d}", GetConVarInt(FindConVar("mp_freezetime")));
		}
		else
		{
			LogEvent("{\"event\": \"round_start\", \"freezeTime\": %d}", GetConVarInt(FindConVar("mp_freezetime")));
		}
	}

	if (g_second_half_first)
	{
		LiveOn3Override();
		g_second_half_first = false;
	}
	
	g_planted = false;
	
	ResetClutchStats();
	
	if (!g_t_score)
	{
		g_t_score = true;
	}
	
	if (g_t_knife)
	{
		// give player specified grenades
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) > 1)
			{
				SetEntData(i, g_iAccount, 0);
				CS_StripButKnife(i);
				if (GetConVarBool(g_h_knife_hegrenade))
				{
					GivePlayerItem(i, "weapon_hegrenade");
				}
				if (GetConVarInt(g_h_knife_flashbang) >= 1)
				{
					GivePlayerItem(i, "weapon_flashbang");
					if (GetConVarInt(g_h_knife_flashbang) >= 2)
					{
						GivePlayerItem(i, "weapon_flashbang");
					}
				}
				if (GetConVarBool(g_h_knife_smokegrenade))
				{
					GivePlayerItem(i, "weapon_smokegrenade");
				}
				if (GetConVarBool(g_h_knife_zeus))
				{
					GivePlayerItem(i, "weapon_taser");
				}
				if (GetConVarBool(g_h_knife_armor))
				{
					SetEntProp(i, Prop_Send, "m_ArmorValue", 100);
					if (GetConVarBool(g_h_knife_helmet))
					{
						SetEntProp(i, Prop_Send, "m_bHasHelmet", 1);
					}
				}
			}
		}
	}
	
	/*if (!g_match || !g_t_money || !GetConVarBool(g_h_round_money) || g_iAccount == -1)
	{
		return;
	}*/
	if (g_t_money == true && GetConVarBool(g_h_round_money))
	{
		new the_money[MAXPLAYERS + 1];
		new num_players;
		
		// sort by money
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
			{
				the_money[num_players] = i;
				num_players++;
			}
		}
		
		SortCustom1D(the_money, num_players, SortMoney);
		
		new String:player_name[64];
		new String:player_money[10];
		new String:has_weapon[1];
		new pri_weapon;
		
		// display team players money
		for (new i = 1; i <= MaxClients; i++)
		{
			for (new x = 0; x < num_players; x++)
			{
				GetClientName(the_money[x], player_name, sizeof(player_name));
				if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == GetClientTeam(the_money[x]))
				{
					pri_weapon = GetPlayerWeaponSlot(the_money[x], 0);
					if (pri_weapon == -1)
					{
						has_weapon = ">";
					}
					else
					{
						has_weapon = "\0";
					}
					IntToMoney(GetEntData(the_money[x], g_iAccount), player_money, sizeof(player_money));
					PrintToChat(i, "\x01$%s \x04%s> \x03%s", player_money, has_weapon, player_name);
				}
			}
		}
	}
}
public Action:AskTeamMoney(client, args)
{
	// show team money
	ShowTeamMoney(client);
	return Plugin_Handled;
}

stock ShowTeamMoney(client)
{
	// show team money
	new the_money[MAXPLAYERS + 1];
	new num_players;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
		{
			the_money[num_players] = i;
			num_players++;
		}
	}
	
	SortCustom1D(the_money, num_players, SortMoney);
	
	new String:player_name[64];
	new String:player_money[10];
	new String:has_weapon[1];
	new pri_weapon;
	
	PrintToChat(client, "\x01--------");
	for (new x = 0; x < num_players; x++)
	{
		GetClientName(the_money[x], player_name, sizeof(player_name));
		if (IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == GetClientTeam(the_money[x]))
		{
			pri_weapon = GetPlayerWeaponSlot(the_money[x], 0);
			if (pri_weapon == -1)
			{
				has_weapon = ">";
			}
			else
			{
				has_weapon = "\0";
			}
			IntToMoney(GetEntData(the_money[x], g_iAccount), player_money, sizeof(player_money));
			PrintToChat(client, "\x01$%s \x04%s> \x03%s", player_money, has_weapon, player_name);
		}
	}
}

stock GetCurrentWorkshopMap(String:g_MapName[], iMapBuf, String:g_WorkShopID[], iWorkShopBuf)
{
	decl String:g_CurMap[128];
	decl String:g_CurMapSplit[2][64];
		
	GetCurrentMap(g_CurMap, sizeof(g_CurMap));
	
	ReplaceString(g_CurMap, sizeof(g_CurMap), "workshop/", "", false);
	
	ExplodeString(g_CurMap, "/", g_CurMapSplit, 2, 64);
	
	strcopy(g_WorkShopID, iWorkShopBuf, g_CurMapSplit[0]);
	strcopy(g_MapName, iMapBuf, g_CurMapSplit[1]);
	strcopy(g_map, iMapBuf, g_CurMapSplit[1]);
}

public Event_Round_End(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}

	new winner = GetEventInt(event, "winner");
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == winner)
			{
				clutch_stats[i][CLUTCH_WON] = 1;
			}
			LogPlayerStats(i);
			LogClutchStats(i);
		}
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"knife_round_end\", \"winner\": %d, \"reason\": %d}", winner, GetEventInt(event, "reason"));
		}
		else
		{
			LogEvent("{\"event\": \"round_end\", \"winner\": %d, \"reason\": %d}", winner, GetEventInt(event, "reason"));
		}
	}
	
	if (winner > 1 && g_t_score)
	{
		if (g_t_knife)
		{
			if (winner == 2)
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_t_name, "Knife Vote Team", LANG_SERVER);
			}
			else
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_ct_name, "Knife Vote Team", LANG_SERVER);
			}
			
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Knife Vote");
			g_knife_winner = GetEventInt(event, "winner");
			g_knife_vote = true;
			g_t_knife = false;
			g_t_had_knife = true;
			ServerCommand("mp_pause_match 1");
			UpdateStatus();
			
		}
		
		if (!g_live)
		{
			return;
		}
		
		if (!g_t_money)
		{
			g_t_money = true;
		}
		
		AddScore(winner);
		CheckScores();
		UpdateStatus();
		
	}
}

public Event_Round_Restart(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled) && !StrEqual(newVal, "0"))
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			ResetPlayerStats(i);
			clutch_stats[i][CLUTCH_LAST] = 0;
			clutch_stats[i][CLUTCH_VERSUS] = 0;
			clutch_stats[i][CLUTCH_FRAGS] = 0;
			clutch_stats[i][CLUTCH_WON] = 0;
		}
		LogEvent("{\"event\": \"round_restart\", \"delay\": %d}", StringToInt(newVal));
	}
}

public Event_Round_Freeze_End(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	FreezeTime = false;
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		if (g_t_knife)
		{
			new String:event_name[] = "knife_round_freeze_end";
			LogSimpleEvent(event_name, sizeof(event_name));
		}
		else
		{
			new String:event_name[] = "round_freeze_end";
			LogSimpleEvent(event_name, sizeof(event_name));
		}
	}
}

public Event_Player_Blind(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (client > 0)
		{
			new String:log_string[384];
			CS_GetAdvLogString(client, log_string, sizeof(log_string));
			LogEvent("{\"event\": \"player_blind\", \"player\": %s, \"duration\": %.2f}", log_string, GetEntPropFloat(client, Prop_Send, "m_flFlashDuration"));
		}
	}
}

public Event_Player_Hurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		new victim = GetClientOfUserId(GetEventInt(event, "userid"));
		new damage = GetEventInt(event, "dmg_health");
		new damage_armor = GetEventInt(event, "dmg_armor");
		new hitgroup = GetEventInt(event, "hitgroup");
		new String: weapon[64];
		GetEventString(event, "weapon", weapon, sizeof(weapon));
		
		if (StrEqual(weapon, "m4a1"))
		{
			new iWeapon = GetPlayerWeaponSlot(attacker, CS_SLOT_PRIMARY);
			new pWeapon = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
			if (pWeapon == 60)
			{
				weapon = "m4a1_silencer";
			}
		}
		else if (StrEqual(weapon, "hkp2000") || StrEqual(weapon, "p250"))
		{
			new iWeapon = GetPlayerWeaponSlot(attacker, CS_SLOT_SECONDARY);
			new pWeapon = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
			if (pWeapon == 61)
			{
				weapon = "usp_silencer";
			}
			else if (pWeapon == 63)
			{
				weapon = "cz75a";
			}
		}
		
		if (attacker > 0)
		{
			new weapon_index = GetWeaponIndex(weapon);
			if (victim > 0)
			{
				GetClientWeapon(victim, last_weapon[victim], 64);
				ReplaceString(last_weapon[victim], 64, "weapon_", "");
				new String:attacker_log_string[384];
				new String:victim_log_string[384];
				CS_GetAdvLogString(attacker, attacker_log_string, sizeof(attacker_log_string));
				CS_GetAdvLogString(victim, victim_log_string, sizeof(victim_log_string));
				EscapeString(weapon, sizeof(weapon));
				if (g_t_knife)
				{
					LogEvent("{\"event\": \"knife_player_hurt\", \"attacker\": %s, \"victim\": %s, \"weapon\": \"%s\", \"damage\": %d, \"damageArmor\": %d, \"hitGroup\": %d}", attacker_log_string, victim_log_string, weapon, damage, damage_armor, hitgroup);
				}
				else
				{
					LogEvent("{\"event\": \"player_hurt\", \"attacker\": %s, \"victim\": %s, \"weapon\": \"%s\", \"damage\": %d, \"damageArmor\": %d, \"hitGroup\": %d}", attacker_log_string, victim_log_string, weapon, damage, damage_armor, hitgroup);
				}
			}
			if (weapon_index > -1)
			{
				weapon_stats[attacker][weapon_index][LOG_HIT_HITS]++;
				weapon_stats[attacker][weapon_index][LOG_HIT_DAMAGE] += damage;
				if (hitgroup < 8)
				{
					weapon_stats[attacker][weapon_index][hitgroup + LOG_HIT_OFFSET]++;
				}
			}
		}
	}
}

public Event_Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new assister = GetClientOfUserId(GetEventInt(event, "assister"));
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new bool:headshot = GetEventBool(event, "headshot");
	new String: weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	if (StrEqual(weapon, "m4a1_silencer_off"))
	{
		weapon = "m4a1_silencer";
	}
	else if (StrEqual(weapon, "usp_silencer_off"))
	{
		weapon = "usp_silencer";
	}
	new victim_team = GetClientTeam(victim);
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		if (attacker > 0 && victim > 0 && attacker != victim)
		{
			// normal frag
			new String:attacker_log_string[384];
			new String:assister_log_string[384];
			new String:victim_log_string[384];
			CS_GetAdvLogString(attacker, attacker_log_string, sizeof(attacker_log_string));
			CS_GetAdvLogString(assister, assister_log_string, sizeof(assister_log_string));
			CS_GetAdvLogString(victim, victim_log_string, sizeof(victim_log_string));
			EscapeString(weapon, sizeof(weapon));
			if (g_t_knife)
			{
				LogEvent("{\"event\": \"knife_player_death\", \"attacker\": %s, \"assister\": %s, \"victim\": %s, \"weapon\": \"%s\", \"headshot\": %d}", attacker_log_string, assister_log_string, victim_log_string, weapon, headshot);
			}
			else
			{
				LogEvent("{\"event\": \"player_death\", \"attacker\": %s, \"assister\": %s, \"victim\": %s, \"weapon\": \"%s\", \"headshot\": %d}", attacker_log_string, assister_log_string, victim_log_string, weapon, headshot);
			}
		}
		else if (victim > 0 && victim == attacker || StrEqual(weapon, "worldspawn"))
		{
			// suicide
			new String:log_string[384];
			new String:assister_log_string[384];
			CS_GetAdvLogString(assister, assister_log_string, sizeof(assister_log_string));
			CS_GetAdvLogString(victim, log_string, sizeof(log_string));
			ReplaceString(weapon, sizeof(weapon), "worldspawn", "world");
			EscapeString(weapon, sizeof(weapon));
			if (g_t_knife)
			{
				LogEvent("{\"event\": \"knife_player_suicide\", \"player\": %s, \"assister\": %s, \"weapon\": \"%s\"}", log_string, assister_log_string, weapon);
			}
			else
			{
				LogEvent("{\"event\": \"player_suicide\", \"player\": %s, \"assister\": %s, \"weapon\": \"%s\"}", log_string, assister_log_string, weapon);
			}
		}
		if (victim > 0)
		{
			// record weapon stats
			new weapon_index = GetWeaponIndex(weapon);
			if (attacker > 0)
			{
				new attacker_team = GetClientTeam(attacker);
				if (weapon_index > -1)
				{
					weapon_stats[attacker][weapon_index][LOG_HIT_KILLS]++;
					if (headshot == true)
					{
						weapon_stats[attacker][weapon_index][LOG_HIT_HEADSHOTS]++;
					}
					if (attacker_team == victim_team)
					{
						weapon_stats[attacker][weapon_index][LOG_HIT_TEAMKILLS]++;
					}
				}
				new victim_num_alive = GetNumAlive(victim_team);
				new attacker_num_alive = GetNumAlive(attacker_team);
				if (victim_num_alive == 0)
				{
					clutch_stats[victim][CLUTCH_LAST] = 1;
					if (clutch_stats[victim][CLUTCH_VERSUS] == 0)
					{
						clutch_stats[victim][CLUTCH_VERSUS] = attacker_num_alive;
					}
				}
				if (attacker_num_alive == 1)
				{
					if (attacker_team != victim_team)
					{
						clutch_stats[attacker][CLUTCH_FRAGS]++;
						if (clutch_stats[attacker][CLUTCH_LAST] == 0)
						{
							clutch_stats[attacker][CLUTCH_VERSUS] = victim_num_alive + 1;
						}
						clutch_stats[attacker][CLUTCH_LAST] = 1;
					}
				}
			}

			new victim_weapon_index = GetWeaponIndex(last_weapon[victim]);
			if (victim_weapon_index > -1)
			{
				weapon_stats[victim][victim_weapon_index][LOG_HIT_DEATHS]++;
			}
		}
		if (assister > 0)
		{
			new assister_team = GetClientTeam(assister);
			if (assister_team == victim_team)
			{
				assist_stats[assister][ASSIST_COUNT_TK]++;
			}
			if (assister_team == GetClientTeam(attacker))
			{
				assist_stats[assister][ASSIST_COUNT]++;
			}
		}
	}
	
	if (!g_live && GetConVarBool(g_h_warmup_respawn))
	{
		// respawn if warmup
		CreateTimer(0.1, RespawnPlayer, victim);
	}
}

public Event_Player_Name(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetLogString(client, log_string, sizeof(log_string));
		new String:newName[64];
		GetEventString(event, "newname", newName, sizeof(newName));
		EscapeString(newName, sizeof(newName));
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"knife_player_name\", \"player\": %s, \"newName\": \"%s\"}", log_string, newName);
		}
		else
		{
			LogEvent("{\"event\": \"player_name\", \"player\": %s, \"newName\": \"%s\"}", log_string, newName);
		}
	}
	if (g_ready_enabled && !g_live)
	{
		CreateTimer(0.1, UpdateInfo);
	}
}

public Event_Player_Disc_Pre(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// stats
	if (GetConVarBool(g_h_stats_enabled) && client != 0)
	{
		new String:log_string[384];
		CS_GetLogString(client, log_string, sizeof(log_string));
		new String:reason[128];
		GetEventString(event, "reason", reason, sizeof(reason));
		EscapeString(reason, sizeof(reason));
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"knife_player_disconnect\", \"player\": %s, \"reason\": \"%s\"}", log_string, reason);
		}
		else
		{
			LogEvent("{\"event\": \"player_disconnect\", \"player\": %s, \"reason\": \"%s\"}", log_string, reason);
		}
	}
}

public Event_Player_Team_Pre(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new new_team = GetEventInt(event, "team");
	
	if (!GetEventBool(event, "silent") && g_premium_list[client] && client > 0)
	{
		// silence normal message, create own
		SetEventBroadcast(event, true);
		
		new String:team_name[64];
		if (new_team == SPECTATOR_TEAM)
		{
			strcopy(team_name, sizeof(team_name), "Spectators");
		}
		else if (new_team == TERRORIST_TEAM)
		{
			strcopy(team_name, sizeof(team_name), "Terrorist force");
		}
		else if (new_team == COUNTER_TERRORIST_TEAM)
		{
			strcopy(team_name, sizeof(team_name), "Counter-Terrorist force");
		}
		
		PrintToChatAll("%s\x01%N is joining the %s", g_premium_prefix[client], client, team_name);
	}
}

public Event_Player_Team(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new old_team = GetEventInt(event, "oldteam");
	new new_team = GetEventInt(event, "team");
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetLogString(client, log_string, sizeof(log_string));
		LogEvent("{\"event\": \"player_team\", \"player\": %s, \"oldTeam\": %d, \"newTeam\": %d}", log_string, old_team, new_team);
	}
	
	if (old_team < 2)
	{
		// came from spec/joining server
		CreateTimer(4.0, ShowPluginInfo, client);
		if (!g_live && g_ready_enabled && !GetEventBool(event, "disconnect") && !IsFakeClient(client))
		{
			CreateTimer(4.0, UpdateInfo);
		}
	}
	
	if (old_team == 0)
	{
		// joining server
		CreateTimer(2.0, HelpText, client, TIMER_FLAG_NO_MAPCHANGE);
		
		CreateTimer(2.0, AdvertGameTech, client);
	}
	
	if (!g_live && g_ready_enabled && !GetEventBool(event, "disconnect") && !IsFakeClient(client))
	{
		// show ready system if applicable
		if (new_team != SPECTATOR_TEAM)
		{
			if (g_player_list[client] == PLAYER_READY)
			{
				ReadyServ(client, false, false, true, false);
			}
			else
			{
				ReadyServ(client, false, true, true, false);
			}
		}
		else
		{
			g_player_list[client] = PLAYER_DISC;
			ShowInfo(client, true, false, 0);
		}
	}
	
	if (new_team > 1 && !g_live && GetConVarBool(g_h_warmup_respawn))
	{
		// spawn player if warmup
		CreateTimer(0.1, RespawnPlayer, client);
	}
}

public Event_Bomb_PickUp(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"bomb_pickup\", \"player\": %s}", log_string);
		}
		else
		{
			LogEvent("{\"event\": \"bomb_pickup\", \"player\": %s}", log_string);
		}
	}
}

public Event_Bomb_Dropped(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"knife_bomb_dropped\", \"player\": %s}", log_string);
		}
		else
		{
			LogEvent("{\"event\": \"bomb_dropped\", \"player\": %s}", log_string);
		}
	}
}

public Event_Bomb_Plant_Begin(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"bomb_plant_begin\", \"player\": %s, \"site\": %d}", log_string, GetEventInt(event, "site"));
	}
}

public Event_Bomb_Plant_Abort(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"bomb_plant_abort\", \"player\": %s, \"site\": %d}", log_string, GetEventInt(event, "site"));
	}
}

public Event_Bomb_Planted(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_planted = true;
	
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"bomb_planted\", \"player\": %s, \"site\": %d}", log_string, GetEventInt(event, "site"));
	}
}

public Event_Bomb_Defuse_Begin(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(client, log_string, sizeof(log_string));
		LogEvent("{\"event\": \"bomb_defuse_begin\", \"player\": %s, \"kit\": %d}", log_string, GetEventInt(event, "site"), GetEventBool(event, "haskit"));
	}
}

public Event_Bomb_Defuse_Abort(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"bomb_defuse_abort\", \"player\": %s}", log_string);
	}
}

public Event_Bomb_Defused(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(client, log_string, sizeof(log_string));
		LogEvent("{\"event\": \"bomb_defused\", \"player\": %s, \"site\": %d}", log_string, GetEventInt(event, "site"));
	}
}

public Event_Weapon_Fire(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (client > 0)
		{
			new String: weapon[64];
			GetEventString(event, "weapon", weapon, sizeof(weapon));
			if (StrEqual(weapon, "m4a1"))
			{
				new iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
				new pWeapon = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
				if (pWeapon == 60)
				{
					weapon = "m4a1_silencer";
				}
			}
			else if (StrEqual(weapon, "hkp2000") || StrEqual(weapon, "p250"))
			{
				new iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
				new pWeapon = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
				if (pWeapon == 61)
				{
					weapon = "usp_silencer";
				}
				else if (pWeapon == 63)
				{
					weapon = "cz75a";
				}
			}
			new weapon_index = GetWeaponIndex(weapon);
			if (weapon_index > -1)
			{
				weapon_stats[client][weapon_index][LOG_HIT_SHOTS]++;
			}
		}
	}
}

public Event_Detonate_Flash(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"grenade_detonate\", \"player\": %s, \"grenade\": \"flashbang\"}", log_string);
	}
}

public Event_Detonate_Smoke(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats	
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"grenade_detonate\", \"player\": %s, \"grenade\": \"smokegrenade\"}", log_string);
	}
}

public Event_Detonate_HeGrenade(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"grenade_detonate\", \"player\": %s, \"grenade\": \"hegrenade\"}", log_string);
	}
}

public Event_Detonate_Molotov(Handle:event, String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"grenade_detonate\", \"player\": %s, \"grenade\": \"molotov\"}", log_string);
	}
}

public Event_Detonate_Decoy(Handle:event, String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		LogEvent("{\"event\": \"grenade_detonate\", \"player\": %s, \"grenade\": \"decoy\"}", log_string);
	}
}

public Event_Item_Pickup(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		CS_GetAdvLogString(GetClientOfUserId(GetEventInt(event, "userid")), log_string, sizeof(log_string));
		new String:item[64];
		GetEventString(event, "item", item, sizeof(item));
		EscapeString(item, sizeof(item));
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"knife_item_pickup\", \"player\": %s, \"item\": \"%s\"}", log_string, item);
		}
		else
		{
			LogEvent("{\"event\": \"item_pickup\", \"player\": %s, \"item\": \"%s\"}", log_string, item);
		}
	}
}

AddScore(team)
{
	if (!g_overtime)
	{
		if (team == TERRORIST_TEAM)
		{
			if (g_first_half)
			{
				g_scores[SCORE_T][SCORE_FIRST_HALF]++;
			}
			else
			{
				g_scores[SCORE_T][SCORE_SECOND_HALF]++;
			}
		}
		
		if (team == COUNTER_TERRORIST_TEAM)
		{
			if (g_first_half)
			{
				g_scores[SCORE_CT][SCORE_FIRST_HALF]++;
			}
			else
			{
				g_scores[SCORE_CT][SCORE_SECOND_HALF]++;
			}
		}
	}
	else
	{
		if (team == TERRORIST_TEAM)
		{
			if (g_first_half)
			{
				g_scores_overtime[SCORE_T][g_overtime_count][SCORE_FIRST_HALF]++;
			}
			else
			{
				g_scores_overtime[SCORE_T][g_overtime_count][SCORE_SECOND_HALF]++;
			}
		}
		
		if (team == COUNTER_TERRORIST_TEAM)
		{
			if (g_first_half)
			{
				g_scores_overtime[SCORE_CT][g_overtime_count][SCORE_FIRST_HALF]++;
			}
			else
			{
				g_scores_overtime[SCORE_CT][g_overtime_count][SCORE_SECOND_HALF]++;
			}
		}
	}
	
	// stats
	if (GetConVarBool(g_h_stats_enabled))
	{
		LogEvent("{\"event\": \"score_update\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
	}
	
	SetConVarIntHidden(g_h_t_score, GetTTotalScore());
	SetConVarIntHidden(g_h_ct_score, GetCTTotalScore());
}

CheckScores()
{
	if (GetConVarInt(g_h_score_mode) == 1)
	{
		if (!g_overtime)
		{
			if (GetScore() == GetConVarInt(g_h_max_rounds)) // half time
			{
				if (!g_first_half)
				{
					return;
				}
				Call_StartForward(g_f_on_half_time);
				Call_Finish();
				if (GetConVarBool(g_h_stats_enabled))
				{
					LogEvent("{\"event\": \"half_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
				}
				DisplayScore(0, 0, false);
				
				/*if (!GetConVarBool(g_h_auto_swap))
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Time");
				}
				else
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Time Auto Swap");
					CreateTimer(GetConVarFloat(g_h_auto_swap_delay), Swap, TIMER_FLAG_NO_MAPCHANGE);
				}*/
				
				g_t_money = false;
				g_first_half = false;
				SetAllCancelled(false);
				ReadyChangeAll(0, false, true);
				SwitchScores();
				g_t_pause_count = 0;
				g_ct_pause_count = 0;
				
				if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					SwitchTeamNames();
				}
				else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					g_t_name = DEFAULT_T_NAME;
					SwitchTeamNames();
				}
				else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
				{
					g_ct_name = DEFAULT_CT_NAME;
					SwitchTeamNames();
				}
				
				/*if (GetConVarBool(g_h_auto_ready) || GetConVarBool(g_h_half_auto_ready))
				{
					ReadySystem(true);
					CreateTimer(GetConVarFloat(g_h_auto_swap_delay) + 0.5, UpdateInfo, TIMER_FLAG_NO_MAPCHANGE);
				}*/
				
				new String:half_time_config[128];
				GetConVarString(g_h_half_time_config, half_time_config, sizeof(half_time_config));
				ServerCommand("exec %s", half_time_config);
				if (GetConVarInt(g_h_half_time_break))
				{
					g_half_swap = false;
					g_live = false;
					ReadySystem(true);
					ShowInfo(0, true, false, 0);
					ServerCommand("mp_halftime_pausetimer 1");
				}
				SetRoundMoney();
			}
			else if (GetTScore() == GetConVarInt(g_h_max_rounds) && GetCTScore() == GetConVarInt(g_h_max_rounds)) // complete draw
			{
				if (GetConVarInt(g_h_overtime) == 1)
				{ // max rounds overtime
					if (GetConVarBool(g_h_stats_enabled))
					{
						LogEvent("{\"event\": \"over_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
					}
					DisplayScore(0, 0, false);
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Over Time", GetConVarInt(g_h_overtime_mr));
//					g_live = false;
					g_t_money = false;
					g_overtime = true;
					g_overtime_mode = 1;
					g_first_half = true;
					SetAllCancelled(false);
					ReadyChangeAll(0, false, true);
					
					if (GetConVarInt(g_h_half_time_break) || GetConVarInt(g_h_over_time_break))
					{
						g_half_swap = false;
						g_live = false;
						ReadySystem(true);
						ShowInfo(0, true, false, 0);
						ServerCommand("mp_overtime_halftime_pausetimer 1");
					}
					SetRoundMoney();
					
					/*if (GetConVarBool(g_h_auto_ready) || GetConVarBool(g_h_half_auto_ready))
					{
						ReadySystem(true);
						ShowInfo(0, true, false, 0);
						CheckReady();
					}*/
				}
				else if (GetConVarInt(g_h_overtime) == 2) // sudden death overtime
				{
					if (GetConVarBool(g_h_stats_enabled))
					{
						LogEvent("{\"event\": \"over_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
					}
					DisplayScore(0, 0, false);
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Over Time Sudden Death");
//					g_live = false;
					g_t_money = false;
					g_overtime = true;
					g_overtime_mode = 2;
					g_first_half = true;
					
					SetAllCancelled(false);
					ReadyChangeAll(0, false, true);
					
					/*if (GetConVarBool(g_h_auto_ready) || GetConVarBool(g_h_half_auto_ready))
					{
						ReadySystem(true);
						ShowInfo(0, true, false, 0);
						CheckReady();
					}*/
				}
				else
				{
					Call_StartForward(g_f_on_end_match);
					Call_Finish();
					
					g_last_maxrounds = GetConVarInt(g_h_max_rounds);
					if (GetConVarBool(g_h_stats_enabled))
					{
						LogEvent("{\"event\": \"full_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
					}
					if (GetConVarBool(g_h_prefix_logs))
					{
						RenameLogs();
					}
					DisplayScore(0, 0, false);
					if (GetConVarBool(g_h_auto_kick_team))
					{
						CreateTimer(GetConVarFloat(g_h_auto_kick_delay), KickLoserTeam, GetLoserTeam());
					}
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Full Time");
					
					if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
					{
						SwitchTeamNames();
					}
					else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
					{
						g_t_name = DEFAULT_T_NAME;
						SwitchTeamNames();
					}
					else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
					{
						g_ct_name = DEFAULT_CT_NAME;
						SwitchTeamNames();
					}
					SwitchScores();
					SetLastScore();
					
					if (GetConVarBool(g_h_upload_results))
					{
						CreateTimer(3.0, UploadResults);
						//new match_length = RoundFloat(GetEngineTime() - g_match_start);
						//MySQL_UploadResults(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
					}
					CreateTimer(4.0, ResetMatchTimer);
					//ResetMatch(true);
				}
			}
			else if (GetScore() == GetConVarInt(g_h_max_rounds) * 2) // full time (all rounds have been played out)
			{
				Call_StartForward(g_f_on_end_match);
				Call_Finish();
				
				g_last_maxrounds = GetConVarInt(g_h_max_rounds);
				if (GetConVarBool(g_h_stats_enabled))
				{
					LogEvent("{\"event\": \"full_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
				}
				if (GetConVarBool(g_h_prefix_logs))
				{
					RenameLogs();
				}
				DisplayScore(0, 0, false);
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Full Time");
				if (GetConVarBool(g_h_auto_kick_team))
				{
					CreateTimer(GetConVarFloat(g_h_auto_kick_delay), KickLoserTeam, GetLoserTeam());
				}
				
				if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					SwitchTeamNames();
				}
				else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					g_t_name = DEFAULT_T_NAME;
					SwitchTeamNames();
				}
				else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
				{
					g_ct_name = DEFAULT_CT_NAME;
					SwitchTeamNames();
				}
				SwitchScores();
				SetLastScore();
				
				if (GetConVarBool(g_h_upload_results))
				{
					CreateTimer(3.0, UploadResults);
					//new match_length = RoundFloat(GetEngineTime() - g_match_start);
					//MySQL_UploadResults(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
				}
				CreateTimer(4.0, ResetMatchTimer);
				//ResetMatch(true);
			}
			else if (!g_playing_out && GetTScore() == GetConVarInt(g_h_max_rounds) + 1 || GetCTScore() == GetConVarInt(g_h_max_rounds) + 1) // full time
			{
				DisplayScore(0, 0, false);
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Full Time");
				
				if (!g_play_out)
				{
					Call_StartForward(g_f_on_end_match);
					Call_Finish();
					
					g_last_maxrounds = GetConVarInt(g_h_max_rounds);
					if (GetConVarBool(g_h_stats_enabled))
					{
						LogEvent("{\"event\": \"full_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
					}
					if (GetConVarBool(g_h_prefix_logs))
					{
						RenameLogs();
					}
					
					if (GetConVarBool(g_h_auto_kick_team))
					{
						CreateTimer(GetConVarFloat(g_h_auto_kick_delay), KickLoserTeam, GetLoserTeam());
					}
					
					if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
					{
						SwitchTeamNames();
					}
					else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
					{
						g_t_name = DEFAULT_T_NAME;
						SwitchTeamNames();
					}
					else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
					{
						g_ct_name = DEFAULT_CT_NAME;
						SwitchTeamNames();
					}
					SwitchScores();
					SetLastScore();
					
					if (GetConVarBool(g_h_upload_results))
					{
						CreateTimer(3.0, UploadResults);
						//new match_length = RoundFloat(GetEngineTime() - g_match_start);
						//MySQL_UploadResults(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
					}
					CreateTimer(4.0, ResetMatchTimer);
					//ResetMatch(true);
				}
				else
				{
					if (GetConVarBool(g_h_stats_enabled))
					{
						LogEvent("{\"event\": \"full_time_playing_out\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
					}
					g_playing_out = true;
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Playing Out Notice", (GetConVarInt(g_h_max_rounds) * 2));
				}
			}
			else
			{
				DisplayScore(0, 0, false);
			}
		}
		else
		{
			if (GetOTScore() == GetConVarInt(g_h_overtime_mr)) // half time
			{
				if (!g_first_half)
				{
					return;
				}
				Call_StartForward(g_f_on_half_time);
				Call_Finish();
				if (GetConVarBool(g_h_stats_enabled))
				{
					LogEvent("{\"event\": \"over_half_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
				}
				DisplayScore(0, 1, false);
				
				/*if (!GetConVarBool(g_h_auto_swap))
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Time");
				}
				else
				{
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Time Auto Swap");
					CreateTimer(GetConVarFloat(g_h_auto_swap_delay), Swap, TIMER_FLAG_NO_MAPCHANGE);
				}*/
				
//				g_live = false;
				g_t_money = false;
				g_first_half = false;
				SetAllCancelled(false);
				ReadyChangeAll(0, false, true);
				SwitchScores();
				
				if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					SwitchTeamNames();
				}
				else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					g_t_name = DEFAULT_T_NAME;
					SwitchTeamNames();
				}
				else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
				{
					g_ct_name = DEFAULT_CT_NAME;
					SwitchTeamNames();
				}
				
				if (GetConVarInt(g_h_half_time_break))
				{
					g_half_swap = false;
					g_live = false;
					ReadySystem(true);
					ShowInfo(0, true, false, 0);
					ServerCommand("mp_overtime_halftime_pausetimer 1");
				}
				SetRoundMoney();
				/*if (GetConVarBool(g_h_auto_ready) || GetConVarBool(g_h_half_auto_ready))
				{
					ReadySystem(true);
					CreateTimer(GetConVarFloat(g_h_auto_swap_delay) + 0.5, UpdateInfo, TIMER_FLAG_NO_MAPCHANGE);
					CheckReady();
				}*/
				
//				new String:half_time_config[128];
//				GetConVarString(g_h_half_time_config, half_time_config, sizeof(half_time_config));
//				ServerCommand("exec %s", half_time_config);
			}
			else if (GetTOTScore() == GetConVarInt(g_h_overtime_mr) && GetCTOTScore() == GetConVarInt(g_h_overtime_mr)) // complete draw
			{
				if (g_overtime_mode == 1)
				{ // max rounds overtime
					if (GetConVarBool(g_h_stats_enabled))
					{
						LogEvent("{\"event\": \"over_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
					}
					DisplayScore(0, 1, false);
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Over Time", GetConVarInt(g_h_overtime_mr));
//					g_live = false;
//					g_t_money = false;
					g_overtime_count++;
					g_first_half = true;
					SetAllCancelled(false);
					ReadyChangeAll(0, false, true);
					
					if (GetConVarInt(g_h_half_time_break) || GetConVarInt(g_h_over_time_break))
					{
						g_half_swap = false;
						g_live = false;
						ReadySystem(true);
						ShowInfo(0, true, false, 0);
						ServerCommand("mp_overtime_halftime_pausetimer 1");
					}
					SetRoundMoney();
					/*if (GetConVarBool(g_h_auto_ready) || GetConVarBool(g_h_half_auto_ready))
					{
						ReadySystem(true);
						ShowInfo(0, true, false, 0);
						CheckReady();
					}*/
					
					return;
				}
				else if (g_overtime_mode == 2) // sudden death overtime
				{
					Call_StartForward(g_f_on_end_match);
					Call_Finish();
					
					if (GetConVarBool(g_h_stats_enabled))
					{
						LogEvent("{\"event\": \"over_full_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
					}
					
					g_last_maxrounds = GetConVarInt(g_h_max_rounds);
					if (GetConVarBool(g_h_auto_kick_team))
					{
						CreateTimer(GetConVarFloat(g_h_auto_kick_delay), KickLoserTeam, GetLoserTeam());
					}
					
					if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
					{
						SwitchTeamNames();
					}
					else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
					{
						g_t_name = DEFAULT_T_NAME;
						SwitchTeamNames();
					}
					else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
					{
						g_ct_name = DEFAULT_CT_NAME;
						SwitchTeamNames();
					}
					SwitchScores();
					SetLastScore();
					
					if (GetConVarBool(g_h_upload_results))
					{
						CreateTimer(3.0, UploadResults);
						//new match_length = RoundFloat(GetEngineTime() - g_match_start);
						//MySQL_UploadResults(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
					}
					
					if (GetConVarBool(g_h_prefix_logs))
					{
						RenameLogs();
					}
					DisplayScore(0, 2, false);
					PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Full Time");
					CreateTimer(4.0, ResetMatchTimer);
					//ResetMatch(true);
					return;
				}
			}
			else if (GetTOTScore() == GetConVarInt(g_h_overtime_mr) + 1 || GetCTOTScore() == GetConVarInt(g_h_overtime_mr) + 1) // full time
			{
				Call_StartForward(g_f_on_end_match);
				Call_Finish();
				
				if (GetConVarBool(g_h_auto_kick_team))
				{
					CreateTimer(GetConVarFloat(g_h_auto_kick_delay), KickLoserTeam, GetLoserTeam());
				}
				if (GetConVarBool(g_h_stats_enabled))
				{
					LogEvent("{\"event\": \"over_full_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
				}
				if (GetConVarBool(g_h_prefix_logs))
				{
					RenameLogs();
				}
				DisplayScore(0, 2, false);
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Full Time");
				
				if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					SwitchTeamNames();
				}
				else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
				{
					g_t_name = DEFAULT_T_NAME;
					SwitchTeamNames();
				}
				else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
				{
					g_ct_name = DEFAULT_CT_NAME;
					SwitchTeamNames();
				}
				SwitchScores();
				SetLastScore();
				
				if (GetConVarBool(g_h_upload_results))
				{
					CreateTimer(3.0, UploadResults);
					//new match_length = RoundFloat(GetEngineTime() - g_match_start);
					//MySQL_UploadResults(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
				}
				CreateTimer(4.0, ResetMatchTimer);
				//ResetMatch(true);
				return;
			}
			else
			{
				DisplayScore(0, 1, false);
			}
		}
	}
	else
	{
		if (g_first_half /*&& GetConVarBool(g_h_auto_swap)*/ && (GetTScore() == RoundToFloor(GetConVarFloat(g_h_max_rounds) / 2) || GetCTScore() == RoundToFloor(GetConVarFloat(g_h_max_rounds) / 2)))
		{
			if (!g_first_half)
			{
				return;
			}
			Call_StartForward(g_f_on_half_time);
			Call_Finish();
			if (GetConVarBool(g_h_stats_enabled))
			{
				LogEvent("{\"event\": \"half_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
			}
			DisplayScore(0, 0, false);
			
			/*if (!GetConVarBool(g_h_auto_swap))
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Time");
			}
			else
			{
				PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Time Auto Swap");
				CreateTimer(GetConVarFloat(g_h_auto_swap_delay), Swap, TIMER_FLAG_NO_MAPCHANGE);
			}*/
			
			g_live = false;
			g_t_money = false;
			g_first_half = false;
			SetAllCancelled(false);
			ReadyChangeAll(0, false, true);
			SwitchScores();
			
			if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
			{
				SwitchTeamNames();
			}
			else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
			{
				g_t_name = DEFAULT_T_NAME;
				SwitchTeamNames();
			}
			else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
			{
				g_ct_name = DEFAULT_CT_NAME;
				SwitchTeamNames();
			}
			
			/*if (GetConVarBool(g_h_auto_ready) || GetConVarBool(g_h_half_auto_ready))
			{
				ReadySystem(true);
				CreateTimer(GetConVarFloat(g_h_auto_swap_delay) + 0.5, UpdateInfo, TIMER_FLAG_NO_MAPCHANGE);
			}*/
			
			new String:half_time_config[128];
			GetConVarString(g_h_half_time_config, half_time_config, sizeof(half_time_config));
			ServerCommand("exec %s", half_time_config);
		}
		else if (GetTScore() == GetConVarInt(g_h_max_rounds) || GetCTScore() == GetConVarInt(g_h_max_rounds))
		{
			Call_StartForward(g_f_on_end_match);
			Call_Finish();
			
			g_last_maxrounds = GetConVarInt(g_h_max_rounds);
			if (GetConVarBool(g_h_stats_enabled))
			{
				LogEvent("{\"event\": \"full_time\", \"teams\": [{\"name\": \"%s\", \"team\": %d, \"score\": %d}, {\"name\": \"%s\", \"team\": %d, \"score\": %d}]}", g_t_name_escaped, TERRORIST_TEAM, GetTTotalScore(), g_ct_name_escaped, COUNTER_TERRORIST_TEAM, GetCTTotalScore());
			}
			if (GetConVarBool(g_h_prefix_logs))
			{
				RenameLogs();
			}
			DisplayScore(0, 0, false);
			if (GetConVarBool(g_h_auto_kick_team))
			{
				CreateTimer(GetConVarFloat(g_h_auto_kick_delay), KickLoserTeam, GetLoserTeam());
			}
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Full Time");
			
			if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
			{
				SwitchTeamNames();
			}
			else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
			{
				g_t_name = DEFAULT_T_NAME;
				SwitchTeamNames();
			}
			else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
			{
				g_ct_name = DEFAULT_CT_NAME;
				SwitchTeamNames();
			}
			SwitchScores();
			SetLastScore();
			
			if (GetConVarBool(g_h_upload_results))
			{
				CreateTimer(3.0, UploadResults);
				//new match_length = RoundFloat(GetEngineTime() - g_match_start);
				//MySQL_UploadResults(match_length, g_map, GetConVarInt(g_h_max_rounds), GetConVarInt(g_h_overtime_mr), g_overtime_count, g_play_out, g_t_name, GetTTotalScore(), g_scores[SCORE_T][SCORE_FIRST_HALF], g_scores[SCORE_T][SCORE_SECOND_HALF], GetTOTTotalScore(), g_ct_name, GetCTTotalScore(), g_scores[SCORE_CT][SCORE_FIRST_HALF], g_scores[SCORE_CT][SCORE_SECOND_HALF], GetCTOTTotalScore());
			}
			CreateTimer(4.0, ResetMatchTimer);
			//ResetMatch(true);
		}
		else
		{
			DisplayScore(0, 0, false);
		}
	}
}

GetScore()
{
	return GetTScore() + GetCTScore();
}

GetTScore()
{
	return g_scores[SCORE_T][SCORE_FIRST_HALF] + g_scores[SCORE_T][SCORE_SECOND_HALF];
}

GetCTScore()
{
	return g_scores[SCORE_CT][SCORE_FIRST_HALF] + g_scores[SCORE_CT][SCORE_SECOND_HALF];
}

GetOTScore()
{
	return GetTOTScore() + GetCTOTScore();
}

GetTOTScore()
{
	return g_scores_overtime[SCORE_T][g_overtime_count][SCORE_FIRST_HALF] + g_scores_overtime[SCORE_T][g_overtime_count][SCORE_SECOND_HALF];
}

GetCTOTScore()
{	
	return g_scores_overtime[SCORE_CT][g_overtime_count][SCORE_FIRST_HALF] + g_scores_overtime[SCORE_CT][g_overtime_count][SCORE_SECOND_HALF];
}

GetTOTTotalScore()
{
	new result;
	for (new i = 0; i <= g_overtime_count; i++)
	{
		result += g_scores_overtime[SCORE_T][i][SCORE_FIRST_HALF] + g_scores_overtime[SCORE_T][i][SCORE_SECOND_HALF];
	}
	return result;
}

GetCTOTTotalScore()
{
	new result;
	for (new i = 0; i <= g_overtime_count; i++)
	{
		result += g_scores_overtime[SCORE_CT][i][SCORE_FIRST_HALF] + g_scores_overtime[SCORE_CT][i][SCORE_SECOND_HALF];
	}
	return result;
}

GetTTotalScore()
{
	new result;
	result = GetTScore();
	for (new i = 0; i <= g_overtime_count; i++)
	{
		result += g_scores_overtime[SCORE_T][i][SCORE_FIRST_HALF] + g_scores_overtime[SCORE_T][i][SCORE_SECOND_HALF];
	}
	return result;
}

GetCTTotalScore()
{
	new result;
	result = GetCTScore();
	for (new i = 0; i <= g_overtime_count; i++)
	{
		result += g_scores_overtime[SCORE_CT][i][SCORE_FIRST_HALF] + g_scores_overtime[SCORE_CT][i][SCORE_SECOND_HALF];
	}
	return result;
}

public SortMoney(elem1, elem2, const array[], Handle:hndl)
{
	new money1 = GetEntData(elem1, g_iAccount);
	new money2 = GetEntData(elem2, g_iAccount);
	
	if (money1 > money2)
	{
		return -1;
	}
	else if (money1 == money2)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

ReadyServ(client, bool:ready, bool:silent, bool:show, bool:priv)
{
	new String:log_string[384];
	CS_GetLogString(client, log_string, sizeof(log_string));
	if (ready)
	{
		if (GetConVarBool(g_h_stats_enabled) && g_player_list[client] == PLAYER_UNREADY)
		{
			LogEvent("{\"event\": \"player_ready\", \"player\": %s}", log_string);
		}
		g_player_list[client] = PLAYER_READY;
		if (!silent)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready");
		}
	}
	else
	{
		if (GetConVarBool(g_h_stats_enabled) && g_player_list[client] == PLAYER_READY)
		{
			LogEvent("{\"event\": \"player_unready\", \"player\": %s}", log_string);
		}
		g_player_list[client] = PLAYER_UNREADY;
		if (!silent)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Not Ready");
		}
	}
	
	if (show)
	{
		ShowInfo(client, true, priv, 0);
	}
	
	CheckReady();
}

CheckReady()
{	
	if (g_live)
	{
		return;
	}
	if ((GetConVarBool(g_h_req_names) && GetTeamClientCount(COUNTER_TERRORIST_TEAM) >= (GetConVarInt(g_h_min_ready)/2) && GetTeamClientCount(TERRORIST_TEAM) >= (GetConVarInt(g_h_min_ready)/2) && (StrEqual(g_t_name, DEFAULT_T_NAME, false) || StrEqual(g_ct_name, DEFAULT_CT_NAME, false))))
	{
		if (!g_warmod_safemode)
		{
			if (StrEqual(g_t_name, DEFAULT_T_NAME, false))
			{
				getTerroristTeamName();
			}
		
			if (StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
			{
				getCounterTerroristTeamName();
			}
		}
		

		if (StrEqual(g_t_name, DEFAULT_T_NAME, false) && (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false)))
		{
			g_p_t_name = true;
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Names Required");
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Name T");
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Name CMD");	
			return;
		}
		else if (StrEqual(g_ct_name, DEFAULT_CT_NAME, false) && (!StrEqual(g_t_name, DEFAULT_T_NAME, false)))
		{
			g_p_ct_name = true;
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Names Required");
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Name CT");
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Name CMD");	
			return;
		}
		else if (StrEqual(g_t_name, DEFAULT_T_NAME, false) && StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
		{
			g_p_ct_name = true;
			g_p_t_name = true;
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Names Required");
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Name Both");
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Set Name CMD");	
			return;
		}
	}
	
	new ready_num;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_player_list[i] == PLAYER_READY && IsClientInGame(i) && !IsFakeClient(i))
		{
			ready_num++;
		}
	}
	
	if (g_ready_enabled && !g_live && (ready_num >= GetConVarInt(g_h_min_ready) || GetConVarInt(g_h_min_ready) == 0))
	{
		if (!g_t_had_knife && !g_match && GetConVarBool(g_h_auto_knife))
		{
			ShowInfo(0, false, false, 1);
			SetAllCancelled(false);
			ReadySystem(false);
			KnifeOn3(0, 0);
			return;
		}
		ShowInfo(0, false, false, 1);
		SetAllCancelled(false);
		ReadySystem(false);
		ServerCommand("mp_warmup_end");
		LiveOn3(true);
	}
}

ReadyChecked()
{
	if (!g_start)
	{
		g_match_start = GetEngineTime();
	
		new String:date[32];
		FormatTime(date, sizeof(date), "%Y-%m-%d-%H%M");
		
		if (!g_warmod_safemode)
		{
			if (StrEqual(g_t_name, DEFAULT_T_NAME))
			{
				getTerroristTeamName();
			}
		
			if (StrEqual(g_ct_name, DEFAULT_CT_NAME))
			{
				getCounterTerroristTeamName();
			}
		}
		
		new String:t_name[64];
		new String:ct_name[64];
		t_name = g_t_name;
		ct_name = g_ct_name;
	
		StripFilename(t_name, sizeof(t_name));
		StripFilename(ct_name, sizeof(ct_name));
		StringToLower(t_name, sizeof(t_name));
		StringToLower(ct_name, sizeof(ct_name));
		if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) || !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
		{
			Format(g_log_filename, sizeof(g_log_filename), "%s-%04x-%s-%s-vs-%s", date, GetConVarInt(FindConVar("hostport")), g_map, t_name, ct_name);
		}
		else
		{
			Format(g_log_filename, sizeof(g_log_filename), "%s-%04x-%s", date, GetConVarInt(FindConVar("hostport")), g_map);
		}
	
		new String:save_dir[128];
		GetConVarString(g_h_save_file_dir, save_dir, sizeof(save_dir));
		new String:file_prefix[1];
		if (GetConVarBool(g_h_prefix_logs))
		{
			file_prefix = "_";
		}
		if (GetConVarBool(g_h_auto_record))
		{
			ServerCommand("tv_stoprecord");
			if (DirExists(save_dir) && !StrEqual(save_dir, ""))
			{
				ServerCommand("tv_record \"%s/%s%s.dem\"", save_dir, file_prefix, g_log_filename);
				g_log_warmod_dir = true;
				Format(g_sDemoPath, sizeof(g_sDemoPath), "%s/%s%s.dem", save_dir, file_prefix, g_log_filename);
				Format(g_sDemoName, sizeof(g_sDemoName), "%s%s.dem", file_prefix, g_log_filename);
				g_bRecording = true;
			}
			else
			{
				ServerCommand("tv_record \"%s%s.dem\"", file_prefix, g_log_filename);
				g_log_warmod_dir = false;
				Format(g_sDemoPath, sizeof(g_sDemoPath), "%s%s.dem", file_prefix, g_log_filename);
				Format(g_sDemoName, sizeof(g_sDemoName), "%s%s.dem", file_prefix, g_log_filename);
				g_bRecording = true;
			}
		}
		
		if (GetConVarBool(g_h_stats_enabled))
		{
			new String:filepath[128];
			if (DirExists(save_dir) && !StrEqual(save_dir, ""))
			{
				Format(filepath, sizeof(filepath), "%s/%s%s.log", save_dir, file_prefix, g_log_filename);
				Format(g_sLogPath, sizeof(g_sLogPath), "%s/%s%s.log", save_dir, file_prefix, g_log_filename);
				g_log_file = OpenFile(filepath, "w");
				g_log_warmod_dir = true;
			}
			else if (DirExists("logs"))
			{
				Format(filepath, sizeof(filepath), "logs/%s%s.log", file_prefix, g_log_filename);
				Format(g_sLogPath, sizeof(g_sLogPath), "logs/%s%s.log", file_prefix, g_log_filename);
				g_log_file = OpenFile(filepath, "w");
				g_log_warmod_dir = false;
			}
			
			LogEvent("{\"event\": \"log_start\", \"unixTime\": %d}", GetTime());
		}
	
		LogPlayers();
	}
}

LiveOn3(bool:e_war)
{
	ServerCommand("mp_warmup_end");
	Call_StartForward(g_f_on_lo3);
	Call_Finish();
	
	g_t_score = false;

	
	new String:match_config[64];
	GetConVarString(g_h_match_config, match_config, sizeof(match_config));
	
	if (e_war && !StrEqual(match_config, ""))
	{
		ServerCommand("exec %s", match_config);
	}
	
/*	if (!g_match)
	{
		g_match_start = GetEngineTime();
		
		new String:date[32];
		FormatTime(date, sizeof(date), "%Y-%m-%d-%H%M");
		
		if (!g_warmod_safemode)
		{
			if (StrEqual(g_t_name, DEFAULT_T_NAME))
			{
				getTerroristTeamName();
			}
		
			if (StrEqual(g_ct_name, DEFAULT_CT_NAME))
			{
				getCounterTerroristTeamName();
			}
		}
		
		new String:t_name[64];
		new String:ct_name[64];
		t_name = g_t_name;
		ct_name = g_ct_name;

		StripFilename(t_name, sizeof(t_name));
		StripFilename(ct_name, sizeof(ct_name));
		StringToLower(t_name, sizeof(t_name));
		StringToLower(ct_name, sizeof(ct_name));
		if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) || !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
		{
			Format(g_log_filename, sizeof(g_log_filename), "%s-%04x-%s-%s-vs-%s", date, GetConVarInt(FindConVar("hostport")), g_map, t_name, ct_name);
		}
		else
		{
			Format(g_log_filename, sizeof(g_log_filename), "%s-%04x-%s", date, GetConVarInt(FindConVar("hostport")), g_map);
		}
		
		new String:save_dir[128];
		GetConVarString(g_h_save_file_dir, save_dir, sizeof(save_dir));
		new String:file_prefix[1];
		if (GetConVarBool(g_h_prefix_logs))
		{
			file_prefix = "_";
		}
		if (GetConVarBool(g_h_auto_record))
		{
			ServerCommand("tv_stoprecord");
			if (DirExists(save_dir))
			{
				ServerCommand("tv_record \"%s/%s%s.dem\"", save_dir, file_prefix, g_log_filename);
				g_log_warmod_dir = true;
				Format(g_sDemoPath, sizeof(g_sDemoPath), "%s/%s%s.dem", save_dir, file_prefix, g_log_filename);
				Format(g_sDemoName, sizeof(g_sDemoName), "%s%s.dem", file_prefix, g_log_filename);
				g_bRecording = true;
			}
			else
			{
				ServerCommand("tv_record \"%s%s.dem\"", file_prefix, g_log_filename);
				g_log_warmod_dir = false;
				Format(g_sDemoPath, sizeof(g_sDemoPath), "%s%s.dem", file_prefix, g_log_filename);
				Format(g_sDemoName, sizeof(g_sDemoName), "%s%s.dem", file_prefix, g_log_filename);
				g_bRecording = true;
			}
		}
		
		if (GetConVarBool(g_h_stats_enabled))
		{
			new String:filepath[128];
			if (DirExists(save_dir))
			{
				Format(filepath, sizeof(filepath), "%s/%s%s.log", save_dir, file_prefix, g_log_filename);
				Format(g_sLogPath, sizeof(g_sLogPath), "%s/%s%s.log", save_dir, file_prefix, g_log_filename);
				g_log_file = OpenFile(filepath, "w");
				g_log_warmod_dir = true;
			}
			else if (DirExists("logs"))
			{
				Format(filepath, sizeof(filepath), "logs/%s%s.log", file_prefix, g_log_filename);
				Format(g_sLogPath, sizeof(g_sLogPath), "logs/%s%s.log", file_prefix, g_log_filename);
				g_log_file = OpenFile(filepath, "w");
				g_log_warmod_dir = false;
			}
			
			LogEvent("{\"event\": \"log_start\", \"unixTime\": %d}", GetTime());
		}
		
		LogPlayers();
	}	*/
	
	ReadyChecked();
	g_start = true;
	g_match = true;
	g_live = true;
	g_MatchComplete = true;	
	SetConVarIntHidden(g_h_t_score, GetTTotalScore());
	SetConVarIntHidden(g_h_ct_score, GetCTTotalScore());
	LiveOn3Override();
}

stock LiveOn3Override()
{
	if (!g_half_swap)
	{
		ServerCommand("mp_halftime_pausetimer 0");
		ServerCommand("mp_overtime_halftime_pausetimer 0");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Live");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Good Luck");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t \x0EWarMod [BFG]", CHAT_PREFIX, "Powered By");
		g_half_swap = true;
		return true;
	}
	
	ServerCommand("mp_unpause_match 1");
	ServerCommand("mp_warmup_end");
	ServerCommand("mp_restartgame 3");
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Live on 3");
	ServerCommand("mp_teamname_1 %s", g_ct_name);
	ServerCommand("mp_teamname_2 %s", g_t_name);
	CreateTimer(2.5, LiveOn3Text);
	g_t_pause_count = 0;
	g_ct_pause_count = 0;
	
	if (GetConVarBool(g_h_stats_enabled))
	{
		LogEvent("{\"event\": \"live_on_3\", \"map\": \"%s\", \"teams\": [{\"name\": \"%s\", \"team\": %d}, {\"name\": \"%s\", \"team\": %d}], \"status\": %d, \"server\": \"%s\", \"competition\": \"%s\", \"event_name\": \"%s\", \"version\": \"%s\"}", g_map, g_t_name_escaped, TERRORIST_TEAM, g_ct_name_escaped, COUNTER_TERRORIST_TEAM, UpdateStatus(), g_server, g_competition, g_event, WM_VERSION);
	}
	return true;
}

public Action:LiveOn3Text(Handle:timer)
{
	SetRoundMoney();
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Live");
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Good Luck");
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t \x03WarMod [BFG]", CHAT_PREFIX, "Powered By");
	if (!g_warmod_safemode)
	{
		CS_SetTeamScore(COUNTER_TERRORIST_TEAM, g_scores[SCORE_CT][SCORE_FIRST_HALF]);
		CS_SetTeamScore(TERRORIST_TEAM, g_scores[SCORE_T][SCORE_FIRST_HALF]);
		SetTeamScore(COUNTER_TERRORIST_TEAM, g_scores[SCORE_CT][SCORE_FIRST_HALF]);
		SetTeamScore(TERRORIST_TEAM, g_scores[SCORE_T][SCORE_FIRST_HALF]);
	}
}

public Action:AdvertGameTech(Handle:timer, any:client)
{
	if (IsClientConnected(client) && IsFakeClient(client))
	{
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t \x03WarMod [BFG]", CHAT_PREFIX, "Powered By");
	}
}

public Action:AdvertGameTechSpecs(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsFakeClient(i))
		{
			PrintToChat(i, "\x01 \x09[\x04%s\x09]\x01 %t \x03WarMod [BFG]", CHAT_PREFIX, "Powered By");
		}
	}
}

public Action:KnifeOn3(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	ReadyChecked();
	g_t_knife = true;
	g_t_score = false;
	
	if (GetConVarBool(g_h_stats_enabled))
	{
		LogEvent("{\"event\": \"knife_on_3\", \"map\": \"%s\", \"teams\": [{\"name\": \"%s\", \"team\": %d}, {\"name\": \"%s\", \"team\": %d}]}", g_map, g_t_name_escaped, TERRORIST_TEAM, g_ct_name_escaped, COUNTER_TERRORIST_TEAM);
	}
	
	new String:match_config[64];
	GetConVarString(g_h_match_config, match_config, sizeof(match_config));
	
	if (!StrEqual(match_config, ""))
	{
		ServerCommand("exec %s", match_config);
	}
	g_start = true;
	KnifeOn3Override();
	UpdateStatus();
	LogAction(client, -1, "\"knife_on_3\" (player \"%L\")", client);
	return Action:3;
}

stock KnifeOn3Override()
{
	ServerCommand("mp_warmup_end");
	ServerCommand("mp_restartgame 3");
	PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Knife On 3");

	CreateTimer(2.5, KnifeOn3Text);
	
	return true;
}

public Action:KnifeOn3Text(Handle:timer)
{
	if (GetConVarBool(g_h_knife_zeus))
	{
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 \x02ZEUS!", CHAT_PREFIX);
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 \x02%t", CHAT_PREFIX, "Knife");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 \x02%t", CHAT_PREFIX, "Knife");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Good Luck");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t \x03WarMod [BFG]", CHAT_PREFIX, "Powered By");
	}
	else
	{
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 \x02%t", CHAT_PREFIX, "Knife");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 \x02%t", CHAT_PREFIX, "Knife");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 \x02%t", CHAT_PREFIX, "Knife");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Good Luck");
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t \x03WarMod [BFG]", CHAT_PREFIX, "Powered By");
	}
}

public Action:Command_JoinTeam(client, const String:command[], args)
{
	if (!IsActive(client, true))
	{
		return Plugin_Continue;
	}

	if (client == 0)
	{
		return Plugin_Continue;
	}

	if (g_match && GetClientTeam(client) > 1 && GetConVarBool(g_h_locked))
	{
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Change Teams Midgame");
		return Plugin_Stop;
	}

	new max_players = GetConVarInt(g_h_max_players);
	if ((g_ready_enabled || g_match) && max_players != 0 && GetClientTeam(client) <= 1 && CS_GetPlayingCount() >= max_players)
	{
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Maximum Players");
		ChangeClientTeam(client, SPECTATOR_TEAM);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action:ChooseTeam(client, args)
{
	if (!IsActive(client, true))
	{
		return Plugin_Continue;
	}

	if (client == 0)
	{
		return Plugin_Continue;
	}

	if (g_match && GetClientTeam(client) > 1 && GetConVarBool(g_h_locked))
	{
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Change Teams Midgame");
		return Plugin_Stop;
	}

	new max_players = GetConVarInt(g_h_max_players);
	if ((g_ready_enabled || g_match) && max_players != 0 && GetClientTeam(client) <= 1 && CS_GetPlayingCount() >= max_players)
	{
		PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Maximum Players");
		ChangeClientTeam(client, SPECTATOR_TEAM);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action:RestrictBuy(client, args)
{
	if (!IsActive(client, true))
	{
		return Plugin_Continue;
	}

	if (client == 0)
	{
		return Plugin_Continue;
	}

	new String:arg[128];
	GetCmdArgString(arg, 128);
	if (!g_live && GetConVarBool(g_h_warm_up_grens))
	{
		new String:the_weapon[32];
		Format(the_weapon, sizeof(the_weapon), "%s", arg);
		ReplaceString(the_weapon, sizeof(the_weapon), "weapon_", "");
		ReplaceString(the_weapon, sizeof(the_weapon), "item_", "");

		if (StrContains(the_weapon, "hegren", false) != -1 || StrContains(the_weapon, "flash", false) != -1 || StrContains(the_weapon, "smokegrenade", false) != -1 || StrContains(the_weapon, "molotov", false) != -1 || StrContains(the_weapon, "incgrenade", false) != -1 || StrContains(the_weapon, "decoy", false) != -1)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Grenades Blocked");
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action:ReadyList(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	new String:player_name[64];
	new player_count;
	
	ReplyToCommand(client, "\x01 \x09[\x04%s\x09]\x01 %T:", CHAT_PREFIX, "Ready System", LANG_SERVER);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
		{
			GetClientName(i, player_name, sizeof(player_name));
			if (g_player_list[i] == PLAYER_UNREADY)	{
				ReplyToCommand(client, "unready > %s", player_name);
				player_count++;
			}
		}
	}
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
		{
			GetClientName(i, player_name, sizeof(player_name));
			if (g_player_list[i] == PLAYER_READY)
			{
				ReplyToCommand(client, "ready > %s", player_name);
				player_count++;
			}
		}
	}
	if (player_count == 0)
	{
		ReplyToCommand(client, "%T", "No Players Found", LANG_SERVER);
	}
	
	return Plugin_Handled;
}

public Action:NotLive(client, args)
{ 
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	ResetHalf(false);
	
	if (client == 0)
	{
		PrintToServer("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Half Reset", LANG_SERVER);
	}
	
	LogAction(client, -1, "\"half_reset\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:WarmUp(client, args)
{
	if (g_live)
	{
		// warmod is disabled
		PrintToChat(client,"\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Match is LIVE", LANG_SERVER);
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	new String:warmup_config[128];
	GetConVarString(g_h_warmup_config, warmup_config, sizeof(warmup_config));
	ServerCommand("exec %s", warmup_config);
	ServerCommand("mp_warmup_start");
	
	if (client == 0)
	{
		PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Warm Up Active", LANG_SERVER);
	}
	
	return Plugin_Handled;
}

public Action:Practice(client, args)
{
	if (g_live)
	{
		// warmod is disabled
		PrintToChat(client,"\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Match is LIVE", LANG_SERVER);
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	new String:prac_config[128];
	GetConVarString(g_h_prac_config, prac_config, sizeof(prac_config));
	ServerCommand("exec %s", prac_config);
	
	if (client == 0)
	{
		PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Practice Mode Active", LANG_SERVER);
	}
	
	return Plugin_Handled;
}

public Action:CancelMatch(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	ResetMatch(false);
	
	if (client == 0)
	{
		PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Match Reset", LANG_SERVER);
	}
	
	LogAction(client, -1, "\"match_reset\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:CancelKnife(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	if (g_t_knife)
	{
		if (GetConVarBool(g_h_stats_enabled))
		{
			new String:event_name[] = "knife_reset";
			LogSimpleEvent(event_name, sizeof(event_name));
		}
		
		g_t_knife = false;
		g_t_had_knife = false;
		ServerCommand("mp_restartgame 1");
		for (new x = 1; x <= 3; x++)
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Knife Round Cancelled");
		}
		if (client == 0)
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Knife Round Cancelled", LANG_SERVER);
		}
	}
	else
	{
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Knife Round Inactive");
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Knife Round Inactive", LANG_SERVER);
		}
	}
	
	UpdateStatus();
	
	LogAction(client, -1, "\"knife_reset\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

ReadySystem(bool:enable)
{
	if (enable)
	{
		if (GetConVarBool(g_h_stats_enabled))
		{
			if (g_t_knife)
			{
				LogEvent("{\"event\": \"knife_ready_system\", \"enabled\": true}");
			}
			else
			{
				LogEvent("{\"event\": \"ready_system\", \"enabled\": true}");
			}
		}
		g_ready_enabled = true;
	}
	else
	{
		if (GetConVarBool(g_h_stats_enabled))
		{
			if (g_t_knife)
			{
				LogEvent("{\"event\": \"knife_ready_system\", \"enabled\": false}");
			}
			else
			{
				LogEvent("{\"event\": \"ready_system\", \"enabled\": false}");
			}
		}
		g_ready_enabled = false;
	}
}

ShowInfo(client, bool:enable, bool:priv, time)
{
	if (!IsActive(client, true))
	{
		return;
	}
	
	if (priv && g_cancel_list[client])
	{
		return;
	}
	
	if (!GetConVarBool(g_h_show_info))
	{
		return;
	}
	
	if (!enable)
	{
		g_m_ready_up = CreatePanel();
		new String:panel_title[128];
		Format(panel_title, sizeof(panel_title), "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Disabled", client);
		SetPanelTitle(g_m_ready_up, panel_title);
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				SendPanelToClient(g_m_ready_up, i, Handler_DoNothing, time);
			}
		}
		
		CloseHandle(g_m_ready_up);
		
		UpdateStatus();
		
		return;
	}
	
	new String:players_unready[192];
	new String:player_name[64];
	new String:player_temp[192];
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_player_list[i] == PLAYER_UNREADY && IsClientInGame(i) && !IsFakeClient(i))
		{
			GetClientName(i, player_name, sizeof(player_name));
			Format(player_temp, sizeof(player_temp), "  %s\n", player_name);
			StrCat(players_unready, sizeof(players_unready), player_temp);
		}
	}
	
	if (priv)
	{
		DispInfo(client, players_unready, time);
	}
	else
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && !g_cancel_list[i])
			{
				DispInfo(i, players_unready, time);
			}
		}
	}
	UpdateStatus();
}

DispInfo(client, String:players_unready[], time)
{
	new String:Temp[128];
	SetGlobalTransTarget(client);
	g_m_ready_up = CreatePanel();
	Format(Temp, sizeof(Temp), "WarMod [BFG]- %t\nAdvanced Gaming Modifications", "Ready System");
	SetPanelTitle(g_m_ready_up, Temp);
	DrawPanelText(g_m_ready_up, "\n \n");
	Format(Temp, sizeof(Temp), "%t", "Match Begin Msg", GetConVarInt(g_h_min_ready));
	DrawPanelItem(g_m_ready_up, Temp);
	DrawPanelText(g_m_ready_up, "\n \n");	
	Format(Temp, sizeof(Temp), "%t", "Info Not Ready");
	DrawPanelItem(g_m_ready_up, Temp);
	DrawPanelText(g_m_ready_up, players_unready);
	DrawPanelText(g_m_ready_up, " \n");
	Format(Temp, sizeof(Temp), "%t", "Info Exit");
	DrawPanelItem(g_m_ready_up, Temp);
	SendPanelToClient(g_m_ready_up, client, Handler_ReadySystem, time);
	CloseHandle(g_m_ready_up);
}

ReadyChangeAll(client, bool:up, bool:silent)
{
	if (up)
	{
		if (GetConVarBool(g_h_stats_enabled))
		{
			new String:event_name[] = "ready_all";
			LogSimpleEvent(event_name, sizeof(event_name));
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) &&  GetClientTeam(i) > 1)
			{
				g_player_list[i] = PLAYER_READY;
			}
		}
	}
	else
	{
		if (GetConVarBool(g_h_stats_enabled))
		{
			new String:event_name[] = "unready_all";
			LogSimpleEvent(event_name, sizeof(event_name));
			
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) &&  GetClientTeam(i) > 1)
			{
				g_player_list[i] = PLAYER_UNREADY;
			}
		}
	}
	if (!silent)
	{
		ShowInfo(client, true, true, 0);
	}
}

IsReadyEnabled(client, bool:silent)
{
	if (g_ready_enabled)
	{
		return true;
	}
	else
	{
		if (!silent)
		{
			if (client != 0)
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Disabled2");
			}
			else
			{
				PrintToServer("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Ready System Disabled2", LANG_SERVER);
			}
		}
	}
	return false;
}

IsLive(client, bool:silent)
{
	if (!g_live)
	{
		return false;
	}
	else
	{
		if (!silent)
		{
			if (client != 0)
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Match Is Live");
			}
			else
			{
				PrintToServer("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Match Is Live", LANG_SERVER);
			}
		}
	}
	return true;
}

IsActive(client, bool:silent)
{
	if (g_active)
	{
		return true;
	}
	else
	{
		if (!silent)
		{
			if (client != 0)
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "WarMod Inactive");
			}
			else
			{
				PrintToServer("\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "WarMod Inactive", LANG_SERVER);
			}
		}
	}
	return false;
}

IsAdminCmd(client, bool:silent)
{
	if (client == 0 || !GetConVarBool(g_h_rcon_only))
	{
		return true;
	}
	else
	{
		if (!silent)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "WarMod Rcon Only");
		}
	}
	return false;
}

public OnActiveChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (StringToInt(newVal) != 0)
	{
		g_active = true;
	}
	else
	{
		g_active = false;
	}
}
public OnReqNameChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	CheckReady();
}

public OnMinReadyChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	if (!g_live && g_ready_enabled)
	{
		ShowInfo(0, true, false, 0);
	}
	
	if (!g_match && g_ready_enabled)
	{
		CheckReady();
	}
}

public OnStatsTraceChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (g_stats_trace_timer != INVALID_HANDLE)
	{
		KillTimer(g_stats_trace_timer);
		g_stats_trace_timer = INVALID_HANDLE;
	}
	if (!StrEqual(newVal, "0", false))
	{
		g_stats_trace_timer = CreateTimer(GetConVarFloat(g_h_stats_trace_delay), Stats_Trace, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public OnStatsTraceDelayChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (g_stats_trace_timer != INVALID_HANDLE)
	{
		KillTimer(g_stats_trace_timer);
		g_stats_trace_timer = INVALID_HANDLE;
	}
	if (GetConVarBool(g_h_stats_trace_enabled))
	{
		g_stats_trace_timer = CreateTimer(GetConVarFloat(g_h_stats_trace_delay), Stats_Trace, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public OnAutoReadyChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	if (!g_match && !g_ready_enabled && StrEqual(newVal, "1", false))
	{
		ReadySystem(true);
		ReadyChangeAll(0, false, true);
		SetAllCancelled(false);
		ShowInfo(0, true, false, 0);
	}
}

public OnMaxRoundChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new maxrounds;
	maxrounds = (GetConVarInt(g_h_max_rounds)*2);
	ServerCommand("mp_maxrounds %i", maxrounds);

	if (g_live)
	{
		CheckScores();
	}
}

public OnMaxRoundChangeMP(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new maxrounds;
	maxrounds = (GetConVarInt(FindConVar("mp_maxrounds"))/2);
	ServerCommand("wm_max_rounds %i", maxrounds);

	if (g_live)
	{
		CheckScores();
	}
}

public OnOverTimeChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (GetConVarInt(FindConVar("mp_overtime_enable")) != GetConVarInt(g_h_overtime))
	{
		new overTime = GetConVarInt(g_h_overtime);
		if (overTime == 2)
		{
			ServerCommand("mp_overtime_enable 1");
			ServerCommand("mp_overtime_maxrounds 1");
			ServerCommand("wm_overtime_max_rounds 1");
		}
		else
		{
			ServerCommand("mp_overtime_enable %i", overTime);
		}
	}
}

public OnOverTimeChangeMP(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (GetConVarInt(FindConVar("mp_overtime_enable")) != GetConVarInt(g_h_overtime))
	{
		if(GetConVarInt(g_h_overtime) < 2)
		{
			new overTime;
			overTime = GetConVarInt(FindConVar("mp_overtime_enable"));
			ServerCommand("wm_overtime %i", overTime);
		}
	}
}

public OnOverTimeMaxRoundChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (GetConVarInt(FindConVar("mp_overtime_maxrounds")) != (GetConVarInt(g_h_overtime_mr)*2))
	{
		if(GetConVarInt(g_h_overtime) < 2)
		{
			new overTimeMR;
			overTimeMR = (GetConVarInt(g_h_overtime_mr)*2);
			ServerCommand("mp_overtime_maxrounds %i", overTimeMR);
		}
	}
}

public OnOverTimeMaxRoundChangeMP(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (GetConVarInt(FindConVar("mp_overtime_maxrounds")) != (GetConVarInt(g_h_overtime_mr)*2))
	{
		if(GetConVarInt(g_h_overtime) < 2)
		{	
			new overTimeMR;
			overTimeMR = (GetConVarInt(FindConVar("mp_overtime_maxrounds"))/2);
			ServerCommand("wm_overtime_max_rounds %i", overTimeMR);
		}
	}
}

public OnOverTimeMoneyChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (GetConVarInt(FindConVar("mp_overtime_startmoney")) != GetConVarInt(g_h_overtime_money))
	{
		new overTimeMoney;
		overTimeMoney = GetConVarInt(g_h_overtime_money);
		ServerCommand("mp_overtime_startmoney %i", overTimeMoney);
	}
}

public OnOverTimeMoneyChangeMP(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (GetConVarInt(FindConVar("mp_overtime_startmoney")) != GetConVarInt(g_h_overtime_money))
	{
		new overTimeMoney;
		overTimeMoney = GetConVarInt(FindConVar("mp_overtime_startmoney"));
		ServerCommand("wm_overtime_start_money %i", overTimeMoney);
	}
}

public OnPlayOutChangeMP(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_h_play_out = FindConVar("mp_match_can_clinch");
	if (GetConVarInt(FindConVar("mp_match_can_clinch")) == 0)
	{
		g_play_out = true;
	}
	else
	{
		g_play_out = false;
	}
}

public OnLiveWireChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (StrEqual(newVal, "1"))
	{
		LiveWire_Connect();
		CreateTimer(600.0, LiveWire_Check, 0, TIMER_REPEAT);
		CreateTimer(1800.0, LiveWire_Ping, _, TIMER_REPEAT);
	}
	else
	{
		LiveWire_Disconnect();
	}
}

public OnTChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (!StrEqual(newVal, ""))
	{
		Format(g_t_name, sizeof(g_t_name), "%s", newVal);
	}
	else
	{
		Format(g_t_name, sizeof(g_t_name), "%s", DEFAULT_T_NAME);
		SetConVarStringHidden(g_h_t, DEFAULT_T_NAME);
	}
	g_t_name_escaped = g_t_name;
	EscapeString(g_t_name_escaped, sizeof(g_t_name_escaped));
	
	CheckReady();
}

public OnCTChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (!StrEqual(newVal, ""))
	{
		Format(g_ct_name, sizeof(g_ct_name), "%s", newVal);
	}
	else
	{
		Format(g_ct_name, sizeof(g_ct_name), "%s", DEFAULT_CT_NAME);
		SetConVarStringHidden(g_h_ct, DEFAULT_CT_NAME);
	}
	g_ct_name_escaped = g_ct_name;
	EscapeString(g_ct_name_escaped, sizeof(g_ct_name_escaped));
	
	CheckReady();
}

public Handler_ReadySystem(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 3)
		{
			g_cancel_list[param1] = true;
		}
	}
}

//Knife vote stay
public Action:Stay(client)
{
	if ((g_knife_vote) && GetClientTeam(client) == g_knife_winner)
	{
		if (g_knife_winner == 2)
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_t_name, "Knife Stay", LANG_SERVER);
		}
		else
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_ct_name, "Knife Stay", LANG_SERVER);
		}
		// show ready system
		ReadyChangeAll(0, false, true);
		SetAllCancelled(false);
		ReadySystem(true);
		ShowInfo(0, true, false, 0);
		g_knife_winner = 0;
		g_knife_vote = false;
		UpdateStatus();
	}
}

//Knife vote switch
public Action:Switch(client)
{
	if ((g_knife_vote) && GetClientTeam(client) == g_knife_winner)
	{
		if (g_knife_winner == 2)
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_t_name, "Knife Switch", LANG_SERVER);
		}
		else
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 %s %T", CHAT_PREFIX, g_ct_name, "Knife Switch", LANG_SERVER);
		}
		
		if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
		{
			SwitchTeamNames();
		}
		else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
		{
			g_t_name = DEFAULT_T_NAME;
			SwitchTeamNames();
		}
		else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
		{
			g_ct_name = DEFAULT_CT_NAME;
			SwitchTeamNames();
		}
		
		ServerCommand("mp_swapteams");
		// show ready system
		ReadyChangeAll(0, false, true);
		SetAllCancelled(false);
		ReadySystem(true);
		ShowInfo(0, true, false, 0);
		g_knife_winner = 0;
		g_knife_vote = false;
		UpdateStatus();
	}
}

public SetRoundMoney()
{
	if (LibraryExists("wm_savescores"))
	{
		new cash;
		if (g_overtime)
		{
			cash = GetConVarInt(FindConVar("mp_overtime_startmoney"));
		}
		else
		{
			cash = GetConVarInt(FindConVar("mp_startmoney"));
		}
		Set_StartMoney(cash);
	}
}

public Handler_DoNothing(Handle:menu, MenuAction:action, param1, param2)
{
	/* Do nothing */
}

public SetAllCancelled(bool:cancelled)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
		{
			g_cancel_list[i] = cancelled;
		}
	}
}

//Eddylad created this part for me. There was no way I could of come up with this. Thanks Eddy =D
 public getTerroristTeamName()
{
	new String:clanTags[MAXPLAYERS+1][MAX_NAME_LENGTH];
	new j = 0;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == 2)
		{
			CS_GetClientClanTag(i, clanTags[j], sizeof(clanTags[])); 
			j++;
		}
		//j++;
	}
	
	decl String:finalTag[MAX_NAME_LENGTH];
	//new finalCount = 0;
	//new storedCount = 0;
	//new arraySize = sizeof(clanTags[]);
	
	if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]) && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[2]) > 0 && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[2]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[2]) > 0 && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[2]);
	}
	else if (strlen(clanTags[2]) > 0 && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[2]);
	}
	else if (strlen(clanTags[3]) > 0 && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[3]);
	}
	else
	{
		finalTag = DEFAULT_T_NAME;
	}
	/*for (new k = 0; k < arraySize; k++)
	{
		for (new z = 0; z < arraySize; z++)
		{
			if (strlen(clanTags[k]) > 1 && strlen(clanTags[z]) > 1 && StrEqual(clanTags[k], clanTags[z]))
			{
				finalCount++;
			}
		}
		
		if(finalCount > storedCount)
		{
			storedCount = finalCount;
			Format(finalTag, sizeof(finalTag), clanTags[k]);
		}
	}*/
	
	if (!StrEqual(finalTag, DEFAULT_T_NAME))
	{
		new String:name_old[64];
		Format(name_old, sizeof(name_old), "%s", g_t_name);
		Format(g_t_name, sizeof(g_t_name), finalTag);
		Format(g_t_name_escaped, sizeof(g_t_name_escaped), finalTag);
		EscapeString(g_t_name_escaped, sizeof(g_t_name_escaped));
		SetConVarStringHidden(g_h_t, g_t_name);
		ServerCommand("mp_teamname_2 %s", g_t_name);
		LogEvent("{\"event\": \"name_change\", \"team\": 2, \"old\": %s, \"new\": %s}", name_old, g_t_name);
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Terrorists are called \x02%s", CHAT_PREFIX, g_t_name);
	}
}

//Eddylad created this part for me. There was no way I could of come up with this. Thanks Eddy =D
 public getCounterTerroristTeamName()
{
	new String:clanTags[MAXPLAYERS+1][MAX_NAME_LENGTH];
	new j = 0;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == 3)
		{
			CS_GetClientClanTag(i, clanTags[j], sizeof(clanTags[])); 
			j++;
		}
		//j++;
	}
	
	decl String:finalTag[MAX_NAME_LENGTH];
	//new finalCount = 0;
	//new storedCount = 0;
	//new arraySize = sizeof(clanTags[]);
	
	if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[2]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]) && StrEqual(clanTags[1], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]) && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]) && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[2]) > 0 && StrEqual(clanTags[2], clanTags[3]) && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[2]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[1]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[2]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[0]) > 0 && StrEqual(clanTags[0], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[0]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[2]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[1]) > 0 && StrEqual(clanTags[1], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[1]);
	}
	else if (strlen(clanTags[2]) > 0 && StrEqual(clanTags[2], clanTags[3]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[2]);
	}
	else if (strlen(clanTags[2]) > 0 && StrEqual(clanTags[2], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[2]);
	}
	else if (strlen(clanTags[3]) > 0 && StrEqual(clanTags[3], clanTags[4]))
	{
		Format(finalTag, sizeof(finalTag), clanTags[3]);
	}
	else
	{
		finalTag = DEFAULT_CT_NAME;
	}
	/*for (new k = 0; k < arraySize; k++)
	{
		for (new z = 0; z < arraySize; z++)
		{
			if (strlen(clanTags[k]) > 0 && strlen(clanTags[z]) > 0 && StrEqual(clanTags[k], clanTags[z]))
			{
				finalCount++;
			}
		}
		
		if(finalCount > storedCount)
		{
			storedCount = finalCount;
			Format(finalTag, sizeof(finalTag), clanTags[k]);
		}
	}*/
	if (!StrEqual(finalTag, DEFAULT_CT_NAME))
	{
		new String:name_old[64];
		Format(name_old, sizeof(name_old), "%s", g_ct_name);
		Format(g_ct_name, sizeof(g_ct_name), finalTag);
		Format(g_ct_name_escaped, sizeof(g_ct_name_escaped), finalTag);
		EscapeString(g_ct_name_escaped, sizeof(g_ct_name_escaped));
		SetConVarStringHidden(g_h_ct, g_ct_name);
		ServerCommand("mp_teamname_1 %s", g_ct_name);
		LogEvent("{\"event\": \"name_change\", \"team\": 3, \"old\": %s, \"new\": %s}", name_old, g_ct_name);
		PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Counter Terrorists are called \x09%s", CHAT_PREFIX, g_ct_name);
	}
}

public Action:ChangeT(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	new String:name[64];
	
	if (GetCmdArgs() > 0)
	{
		GetCmdArgString(name, sizeof(name));
		new String:name_old[64];
		Format(name_old, sizeof(name_old), "%s", g_t_name);
		Format(g_t_name, sizeof(g_t_name), "%s", name);
		g_t_name_escaped = g_t_name;
		EscapeString(g_t_name_escaped, sizeof(g_t_name_escaped));
		SetConVarStringHidden(g_h_t, name);
		LogEvent("{\"event\": \"name_change\", \"team\": 2, \"old\": %s, \"new\": %s}", name_old, g_t_name);
		ServerCommand("mp_teamname_2 %s", name);
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Change T Name", name);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Change T Name", LANG_SERVER, name);
		}
		CheckReady();
		LogAction(client, -1, "\"set_t_name\" (player \"%L\") (name \"%s\")", client, name);
	}
	else
	{
		GetConVarString(g_h_t, name, sizeof(name));
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 wm_t = %s", CHAT_PREFIX, name);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 - wm_t = %s", CHAT_PREFIX, name);
		}
	}
	
	return Plugin_Handled;
}

public Action:ChangeCT(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	new String:name[64];
	
	if (GetCmdArgs() > 0)
	{
		GetCmdArgString(name, sizeof(name));
		new String:name_old[64];
		Format(name_old, sizeof(name_old), "%s", g_ct_name);
		Format(g_ct_name, sizeof(g_ct_name), "%s", name);
		g_ct_name_escaped = g_ct_name;
		EscapeString(g_ct_name_escaped, sizeof(g_ct_name_escaped));
		SetConVarStringHidden(g_h_ct, name);
		LogEvent("{\"event\": \"name_change\", \"team\": 3, \"old\": %s, \"new\": %s}", name_old, g_ct_name);
		ServerCommand("mp_teamname_1 %s", name);
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Change CT Name", name);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 %T", CHAT_PREFIX, "Change CT Name", LANG_SERVER, name);
		}
		CheckReady();
		LogAction(client, -1, "\"set_ct_name\" (player \"%L\") (name \"%s\")", client, name);
	}
	else
	{
		GetConVarString(g_h_ct, name, sizeof(name));
		if (client != 0)
		{
			PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 wm_ct = %s", CHAT_PREFIX, name);
		}
		else
		{
			PrintToServer("\x01 \x09[\x04%s\x09]\x01 - wm_ct = %s", CHAT_PREFIX, name);
		}
	}
	
	return Plugin_Handled;
}

/*********************************************************
 *  Display message from player, simulates say and say_team
 * 
 * @noreturn
 *********************************************************/

stock SayText2(client, String:message[], size, bool:teamOnly=false, bool:silence=false)
{
	if (!silence && !LibraryExists("PES_ELITE"))
	{
		new String:client_name[64];
		GetClientName(client, client_name, sizeof(client_name));
		new client_team = GetClientTeam(client);
		new client_list[MAXPLAYERS + 1];
		new client_num = 0;
		new includeSTV = GetConVarBool(g_h_stv_chat);
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (
				IsClientInGame(i) // valid client
				&& (IsPlayerAlive(client) || !IsPlayerAlive(i)) // either player is alive or target is dead
				&& (!teamOnly || GetClientTeam(i) == client_team) // either don't care about team or same team
				&& (includeSTV || !IsFakeClient(i)) // either don't care about bots or they are human
			)
			{
				client_list[client_num] = i;
				client_num++;
			}
		}
		
		new String:status_prefix[12] = "";
		if (!IsPlayerAlive(client))
		{
			if (client_team == SPECTATOR_TEAM)
			{
				strcopy(status_prefix, sizeof(status_prefix), "*SPEC* ");
			}
			else
			{
				strcopy(status_prefix, sizeof(status_prefix), "*DEAD* ");
			}
		}
		
		new String:team_prefix[12] = "";
		if (teamOnly)
		{
			strcopy(team_prefix, sizeof(team_prefix), "\x01(TEAM) ");
		}

		new Handle:h_message = StartMessageEx(GetUserMessageId("SayText2"), client_list, client_num, 0);
		if (GetUserMessageType() == UM_Protobuf)
		{
			new String:format[384];
			Format(format, sizeof(format), "\x01%s\x01%s%s\x03%%s1 \x01:  %%s2", g_premium_prefix[client], status_prefix, team_prefix);
			PbSetInt(h_message, "ent_idx", client);
			PbSetBool(h_message, "chat", true);
			PbSetString(h_message, "msg_name", format);
			PbAddString(h_message, "params", client_name);
			PbAddString(h_message, "params", message);
			PbAddString(h_message, "params", "");
			PbAddString(h_message, "params", "");
		}
		else
		{
			BfWriteByte(h_message, client);
			BfWriteByte(h_message, true);
			new String:format[384];
			Format(format, sizeof(format), "\x01%s\x01%s%s\x03%%s1 \x01:  %%s2", g_premium_prefix[client], status_prefix, team_prefix);
			BfWriteString(h_message, format);
			BfWriteString(h_message, client_name);
			BfWriteString(h_message, message);
		}
		EndMessage();
	}
	
	new String:standard_log_string[192];
	CS_GetStandardLogString(client, standard_log_string, sizeof(standard_log_string));
	
	if (teamOnly)
	{
		LogToGame("\"%s\" say_team \"%s\"", standard_log_string, message);
	}
	else
	{
		LogToGame("\"%s\" say \"%s\"", standard_log_string, message);
	}
	
	new String:log_string[192];
	CS_GetLogString(client, log_string, sizeof(log_string));
	
	EscapeString(message, size);
	if (g_t_knife)
	{
		LogEvent("{\"event\": \"knife_player_say\", \"player\": %s, \"message\": \"%s\", \"teamOnly\": %d}", log_string, message, teamOnly);
	}
	else
	{
		LogEvent("{\"event\": \"player_say\", \"player\": %s, \"message\": \"%s\", \"teamOnly\": %d}", log_string, message, teamOnly);
	}
}

public Action:SayChat(client, args)
{
	if (!IsActive(0, true) || args < 1)
	{
		// warmod is disabled or no arguments
		return Plugin_Continue;
	}
	
	if (client > 0 && BaseComm_IsClientGagged(client))
	{
		// client is gagged
		return Plugin_Continue;
	}
	
	new String:type[64];
	GetCmdArg(0, type, sizeof(type));
	
	new bool:teamOnly = false;
	new bool:silence = false;
	
	if (StrEqual(type, "say_team", false))
	{
		// true if not console, as console is always global
		teamOnly = !! client;
	}
	
	new String:message[192];
	GetCmdArgString(message, sizeof(message));
	StripQuotes(message);
	
	if (StrEqual(message, ""))
	{
		// no message
		return Plugin_Continue;
	}
	
	if (client == 0)
	{
		if (!LibraryExists("PES_ELITE"))
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09] \x03%t\x01%s", CHAT_PREFIX, "Console", message);
			silence = true;
		}
		return Plugin_Continue;
	}
	else if (message[0] == '@' && message[1] != '\0' && GetConVarBool(g_h_global_chat))
	{
		if (!LibraryExists("PES_ELITE"))
		{
			if (CheckAdminForChat(client))
			{
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i))
					{
						PrintToChat(i, "\x03%t\x01%s", "Console", message[1]);
					}
				}
				silence = true;
			}
			else
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "No Permission");
			}
		}
	}
	else if (message[0] == '!' || message[0] == '.' || message[0] == '/')
	{
		new String:command[192];
		new String:message_parts[2][64];
		ExplodeString(message[1], " ", message_parts, 2, 64);
		strcopy(command, 192, message_parts[0]);
		
		new validCommand = true;
		if (StrEqual(command, "ready", false) || StrEqual(command, "rdy", false) || StrEqual(command, "r", false))
		{
			ReadyUp(client);
		}
		else if (StrEqual(command, "unready", false) || StrEqual(command, "notready", false) || StrEqual(command, "unrdy", false) || StrEqual(command, "notrdy", false) || StrEqual(command, "ur", false) || StrEqual(command, "nr", false))
		{
			ReadyDown(client);
		}
		else if (StrEqual(command, "scores", false) || StrEqual(command, "score", false) || StrEqual(command, "s", false))
		{
			ShowScore(client);
		}
		else if (StrEqual(command, "stay", false))
		{
			Stay(client);
		}
		else if (StrEqual(command, "switch", false))
		{
			Switch(client);
		}
		else if (StrEqual(command, "pause", false) || StrEqual(command, "pauses", false) || StrEqual(command, "p", false))
		{
			Pause(client, args);
		}
		else if (StrEqual(command, "unpause", false) || StrEqual(command, "unpauses", false) || StrEqual(command, "up", false))
		{
			Unpause(client, args);
		}
		else if (StrEqual(command, "info", false) || StrEqual(command, "i", false))
		{
			if (GetConVarBool(g_h_show_info))
			{
				ReadyInfoPriv(client);
			}
			else
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "ShowInfo Disabled");
			}
		}
		else if (StrEqual(command, "help", false))
		{
			DisplayHelp(client);
		}
		else
		{
			validCommand = false;
		}
		
		if (validCommand && !silence)
		{
			silence = true;
		}
	}
	
	if (IsChatTrigger())
	{
		return Plugin_Continue;
	}
	
	SayText2(client, message, sizeof(message), teamOnly, silence);
	
	return Plugin_Handled;
}

SwitchScores()
{
	new temp;
	
	temp = g_scores[SCORE_T][SCORE_FIRST_HALF];
	g_scores[SCORE_T][SCORE_FIRST_HALF] = g_scores[SCORE_CT][SCORE_FIRST_HALF];
	g_scores[SCORE_CT][SCORE_FIRST_HALF] = temp;
	
	temp = g_scores[SCORE_T][SCORE_SECOND_HALF];
	g_scores[SCORE_T][SCORE_SECOND_HALF] = g_scores[SCORE_CT][SCORE_SECOND_HALF];
	g_scores[SCORE_CT][SCORE_SECOND_HALF] = temp;
	
	for (new i = 0; i <= g_overtime_count; i++)
	{
		temp = g_scores_overtime[SCORE_T][i][SCORE_FIRST_HALF];
		g_scores_overtime[SCORE_T][i][SCORE_FIRST_HALF] = g_scores_overtime[SCORE_CT][i][SCORE_FIRST_HALF];
		g_scores_overtime[SCORE_CT][i][SCORE_FIRST_HALF] = temp;
		
		temp = g_scores_overtime[SCORE_T][i][SCORE_SECOND_HALF];
		g_scores_overtime[SCORE_T][i][SCORE_SECOND_HALF] = g_scores_overtime[SCORE_CT][i][SCORE_SECOND_HALF];
		g_scores_overtime[SCORE_CT][i][SCORE_SECOND_HALF] = temp;
	}
}

SwitchTeamNames()
{
	new String:temp[64];
	temp = g_t_name;
	g_t_name = g_ct_name;
	SetConVarStringHidden(g_h_t, g_ct_name);
	g_ct_name = temp;
	SetConVarStringHidden(g_h_ct, temp);
	
	g_t_name_escaped = g_t_name;
	EscapeString(g_t_name_escaped, sizeof(g_t_name_escaped));
	g_ct_name_escaped = g_ct_name;
	EscapeString(g_ct_name_escaped, sizeof(g_ct_name_escaped));
}

SetLastScore()
{
	g_last_scores[SCORE_T] = GetTTotalScore();
	g_last_names[SCORE_T] = g_t_name;
	g_last_scores[SCORE_CT] = GetCTTotalScore();
	g_last_names[SCORE_CT] = g_ct_name;
}

public Action:SwapAll(client, args)
{
	if (!IsActive(client, false))
	{
		// warmod is disabled
		return Plugin_Handled;
	}
	
	if (!IsAdminCmd(client, false))
	{
		// not allowed, rcon only
		return Plugin_Handled;
	}
	
	CS_SwapTeams();
	SwitchScores();
	
	if (!StrEqual(g_t_name, DEFAULT_T_NAME, false) && !StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
	{
		SwitchTeamNames();
	}
	else if (!StrEqual(g_ct_name, DEFAULT_CT_NAME, false))
	{
		g_t_name = DEFAULT_T_NAME;
		SwitchTeamNames();
	}
	else if (!StrEqual(g_t_name, DEFAULT_T_NAME, false))
	{
		g_ct_name = DEFAULT_CT_NAME;
		SwitchTeamNames();
	}
	
	LogAction(client, -1, "\"team_swap\" (player \"%L\")", client);
	
	return Plugin_Handled;
}

public Action:Swap(Handle:timer)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	if (!g_live)
	{
		CS_SwapTeams();
	}
}

public Action:UpdateInfo(Handle:timer)
{
	if (!IsActive(0, true))
	{
		return;
	}
	
	if (!g_live)
	{
		ShowInfo(0, true, false, 0);
	}
}

public Action:StopRecord(Handle:timer)
{
	if (!g_match)
	{
		// only stop if another match hasn't started
		ServerCommand("tv_stoprecord");
		if (g_bEnabled && g_bRecording && LibraryExists("teftp"))
		{
			if (g_UploadOnMatchCompleted)
			{
				if (g_MatchComplete)
				{
					new Handle:hDataPack = CreateDataPack();
					CreateDataTimer(1.0, Timer_UploadDemo, hDataPack);
					WritePackString(hDataPack, g_sDemoPath);
					Format(g_sDemoPath, sizeof(g_sDemoPath), "");
				}
			}
			else
			{
				new Handle:hDataPack = CreateDataPack();
				CreateDataTimer(1.0, Timer_UploadDemo, hDataPack);
				WritePackString(hDataPack, g_sDemoPath);
				Format(g_sDemoPath, sizeof(g_sDemoPath), "");
			}
		}
		else if (!LibraryExists("teftp"))
		{
			LogError("Plug-in tEasyFTP.smx required to auto upload demos");
		}
		CreateTimer(2.0, RecordingFalse);
	}
}

public Action:RecordingFalse(Handle:timer)
{
	g_bRecording = false;
}

public Action:LogFileUpload(Handle:timer)
{
	if (!g_match)
	{
		if (g_bEnabled && g_bRecording && LibraryExists("teftp"))
		{
			if (g_UploadOnMatchCompleted)
			{
				if (g_MatchComplete)
				{
					new Handle:hDataPackLog = CreateDataPack();
					CreateDataTimer(1.0, Timer_UploadLog, hDataPackLog);
					WritePackString(hDataPackLog, g_sLogPath);
					Format(g_sLogPath, sizeof(g_sLogPath), "");
				}
			}
			else
			{
				new Handle:hDataPackLog = CreateDataPack();
				CreateDataTimer(1.0, Timer_UploadLog, hDataPackLog);
				WritePackString(hDataPackLog, g_sLogPath);
				Format(g_sLogPath, sizeof(g_sLogPath), "");
			}
		}
	}
}

//Coded by Thrawn2 from tAutoDemoUpload plugin [Built in for better execution]
public Action:Timer_UploadDemo(Handle:timer, Handle:hDataPack)
{
	if (LibraryExists("teftp"))
	{
		ResetPack(hDataPack);

		decl String:sDemoPath[PLATFORM_MAX_PATH];
		ReadPackString(hDataPack, sDemoPath, sizeof(sDemoPath));
		if(g_iBzip2 > 0 && LibraryExists("zip"))
		{
//			new bool:bStepResult = true;
			decl String:sZipPath[PLATFORM_MAX_PATH];
			Format(sZipPath, sizeof(sZipPath), "%s.zip", sDemoPath);
			new Handle:hZip = Zip_Open(sZipPath, ZIP_APPEND_STATUS_CREATE);
			if (INVALID_HANDLE != hZip)
			{
				if (!Zip_AddFile(hZip, sDemoPath))
				{
					LogError("Could not compress demo file %s", sDemoPath, sZipPath);
					CloseHandle(hZip);
					EasyFTP_UploadFile(g_sFtpTargetDemo, sZipPath, "/", UploadComplete);
	//				DeleteFile(sZipPath);
				}
				else
				{
					CloseHandle(hZip);
					LogToGame("Wrote compressed demo %s", sZipPath);
					EasyFTP_UploadFile(g_sFtpTargetDemo, sZipPath, "/", UploadComplete);
				}
			}
			else
			{
				LogError("Could not open %s for writing", sZipPath);
			}
/*			if (hZip == INVALID_HANDLE)
			{
				LogError("Failed to create Zip archive");
//	Should add backup for uploading here
			}
//			Test_IsNot(hTest, hZip, INVALID_HANDLE, "Creating zip archive");
			bStepResult = Zip_AddFile(hZip, sDemoPath);
			if (bStepResult == false)
			{
				LogError("Failed to add to Zip archive");
//	Should add backup for uploading here				
			}
		Test_Ok(hTest, bStepResult, "Adding file to archive");
			CloseHandle(hZip);
			EasyFTP_UploadFile(g_sFtpTargetDemo, sZipPath, "/", UploadComplete);*/
		}
		else if(g_iBzip2 > 0 && g_iBzip2 < 10 && LibraryExists("bzip2"))
		{
			decl String:sBzipPath[PLATFORM_MAX_PATH];
			Format(sBzipPath, sizeof(sBzipPath), "%s.bz2", sDemoPath);
			BZ2_CompressFile(sDemoPath, sBzipPath, g_iBzip2, CompressionComplete);
		}
		else
		{
			EasyFTP_UploadFile(g_sFtpTargetDemo, sDemoPath, "/", UploadComplete);
		}
	}
}

public Action:Timer_UploadLog(Handle:timer, Handle:hDataPackLog)
{
	if (LibraryExists("teftp"))
	{
		ResetPack(hDataPackLog);
	
		decl String:sLogPath[PLATFORM_MAX_PATH];
		ReadPackString(hDataPackLog, sLogPath, sizeof(sLogPath));
	
		EasyFTP_UploadFile(g_sFtpTargetLog, sLogPath, "/", UploadComplete);
	}
}

public CompressionComplete(BZ_Error:iError, String:inFile[], String:outFile[], any:data)
{
	if (LibraryExists("teftp"))
	{
		if(iError == BZ_OK)
		{
			LogMessage("%s compressed to %s", inFile, outFile);
			EasyFTP_UploadFile(g_sFtpTargetDemo, outFile, "/", UploadComplete);
		}
		else
		{
			LogBZ2Error(iError);
		}
	}
}

public UploadComplete(const String:sTarget[], const String:sLocalFile[], const String:sRemoteFile[], iErrorCode, any:data) {
	if(iErrorCode == 0 && g_bDelete)
	{
		DeleteFile(sLocalFile);
		if(StrEqual(sLocalFile[strlen(sLocalFile)-4], ".bz2") || StrEqual(sLocalFile[strlen(sLocalFile)-4], ".zip"))
		{
			new String:sLocalNoCompressFile[PLATFORM_MAX_PATH];
			strcopy(sLocalNoCompressFile, strlen(sLocalFile)-3, sLocalFile);
			DeleteFile(sLocalNoCompressFile);
		}
	}

	if(iErrorCode == 0)
	{
		if(StrEqual(sLocalFile[strlen(sLocalFile)-4], ".log"))
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Log file uploaded successfully", CHAT_PREFIX);
		}
		else
		{
			PrintToChatAll("\x01 \x09[\x04%s\x09]\x01 Demo uploaded successfully", CHAT_PREFIX);
		}
	}
	else
	{
		for(new client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetAdminFlag(GetUserAdmin(client), Admin_Reservation))
			{
				PrintToChat(client, "\x01 \x09[\x04%s\x09]\x01 Failed uploading demo file. Check the server log files.", CHAT_PREFIX);
			}
		}
	}
}

public Cvar_Changed(Handle:convar, const String:oldValue[], const String:newValue[])
{
	OnConfigsExecuted();
}

public GetConVarValueInt(const String:sConVar[])
{
	new Handle:hConVar = FindConVar(sConVar);
	new iResult = GetConVarInt(hConVar);
	CloseHandle(hConVar);
	return iResult;
}

public Action:HalfTime(Handle:timer)
{
	// starts warmup for second half
	ServerCommand("mp_warmuptime 5000");
	ServerCommand("mp_warmup_start");
	ReadySystem(true);
	ShowInfo(0, true, false, 0);
}

public Action:KickLoserTeam(Handle:timer, any:team)
{
	if (team != -1)
	{
		KickTeam(team);
	}
}

stock LogSimpleEvent(String:event_name[], size)
{
	new String:json[384];
	EscapeString(event_name, size);

	Format(json, sizeof(json), "{\"event\": \"%s\"}", event_name);
	LogEvent("%s", json);
}

stock LogEvent(const String:format[], any:...)
{
	decl String:event[1024];
	VFormat(event, sizeof(event), format, 2);
	new stats_method = GetConVarInt(g_h_stats_method);
	if (stats_method == 0 || stats_method == 2)
	{
		// standard server log files + udp stream
		LogToGame("\x01 \x09[\x04%s\x09]\x01  %s", CHAT_PREFIX, event);
	}
	
	// inject timestamp into JSON object, hacky but quite simple
	new String:timestamp[64];
	FormatTime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S");
	
	// remove leading '{' from the event and add the timestamp in, including new '{'
	Format(event, sizeof(event), "{\"timestamp\": \"%s\", %s", timestamp, event[1]);
	
	if ((stats_method == 1 || stats_method == 2) && g_log_file != INVALID_HANDLE)
	{
		WriteFileLine(g_log_file, event);
	}
	
	LiveWire_Send(event);
}

stock LogLiveWireEvent(const String:format[], any:...)
{
	decl String:event[1024];
	VFormat(event, sizeof(event), format, 2);
	
	// inject timestamp into JSON object, hacky but quite simple
	new String:timestamp[64];
	FormatTime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S");
	
	// remove leading '{' from the event and add the timestamp in, including new '{'
	Format(event, sizeof(event), "{\"timestamp\": \"%s\", %s", timestamp, event[1]);
	
	LiveWire_Send(event);
}

LogPlayers(bool:livewire_only=false)
{
	new String:ip_address[32];
	new String:country[2];
	new String:log_string[384];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			GetClientIP(i, ip_address, sizeof(ip_address));
			GeoipCode2(ip_address, country);
			CS_GetLogString(i, log_string, sizeof(log_string));
			
			EscapeString(ip_address, sizeof(ip_address));
			EscapeString(country, sizeof(country));
			if (!livewire_only)
			{
				LogEvent("{\"event\": \"player_status\", \"player\": %s, \"address\": \"%s\", \"country\": \"%s\"}", log_string, ip_address, country);
			}
			else
			{
				LogLiveWireEvent("{\"event\": \"player_status\", \"player\": %s, \"address\": \"%s\", \"country\": \"%s\"}", log_string, ip_address, country);
			}
		}
	}
}

public Action:Stats_Trace(Handle:timer)
{
	if (GetConVarBool(g_h_stats_enabled))
	{
		new String:log_string[384];
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) > 1 && IsPlayerAlive(i))
			{
				CS_GetAdvLogString(i, log_string, sizeof(log_string));
				if (g_t_knife)
				{
					LogEvent("{\"event\": \"knife_player_trace\", \"player\": %s}", log_string);
				}
				else
				{
					LogEvent("{\"event\": \"player_trace\", \"player\": %s}", log_string);
				}
			}
		}
	}
}

RenameLogs()
{
	new String:save_dir[128];
	GetConVarString(g_h_save_file_dir, save_dir, sizeof(save_dir));
	if (g_log_file != INVALID_HANDLE)
	{
		FlushFile(g_log_file);
		CloseHandle(g_log_file);
		g_log_file = INVALID_HANDLE;
		new String:old_log_filename[128];
		new String:new_log_filename[128];
		if (g_log_warmod_dir)
		{
			Format(old_log_filename, sizeof(old_log_filename), "%s/_%s.log", save_dir, g_log_filename);
			Format(new_log_filename, sizeof(new_log_filename), "%s/%s.log", save_dir, g_log_filename);
		}
		else
		{
			Format(old_log_filename, sizeof(old_log_filename), "logs/_%s.log", g_log_filename);
			Format(new_log_filename, sizeof(new_log_filename), "logs/%s.log", g_log_filename);
		}
		RenameFile(new_log_filename, old_log_filename);
	}
	CreateTimer(15.0, RenameDemos);
}

public Action:RenameDemos(Handle:timer)
{
	new String:save_dir[128];
	GetConVarString(g_h_save_file_dir, save_dir, sizeof(save_dir));
	new String:old_demo_filename[128];
	new String:new_demo_filename[128];
	if (g_log_warmod_dir)
	{
		Format(old_demo_filename, sizeof(old_demo_filename), "%s/_%s.dem", save_dir, g_log_filename);
		Format(new_demo_filename, sizeof(new_demo_filename), "%s/%s.dem", save_dir, g_log_filename);
	}
	else
	{
		Format(old_demo_filename, sizeof(old_demo_filename), "_%s.dem", g_log_filename);
		Format(new_demo_filename, sizeof(new_demo_filename), "%s.dem", g_log_filename);	
	}
	RenameFile(new_demo_filename, old_demo_filename);
}

ResetPlayerStats(client)
{
	for (new i = 0; i < NUM_WEAPONS; i++)
	{
		for (new x = 0; x < LOG_HIT_NUM; x++)
		{
			weapon_stats[client][i][x] = 0;
		}
	}
	for (new z = 0; z < ASSIST_NUM; z++)
	{
		assist_stats[client][z] = 0;
	}
}

ResetClutchStats()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		clutch_stats[i][CLUTCH_LAST] = 0;
		clutch_stats[i][CLUTCH_VERSUS] = 0;
		clutch_stats[i][CLUTCH_FRAGS] = 0;
		clutch_stats[i][CLUTCH_WON] = 0;
	}
}

LogPlayerStats(client)
{
	if (IsClientInGame(client) && GetClientTeam(client) > 1)
	{
		new String:log_string[384];
		CS_GetLogString(client, log_string, sizeof(log_string));
		for (new i = 0; i < NUM_WEAPONS; i++)
		{
			if (weapon_stats[client][i][LOG_HIT_SHOTS] > 0 || weapon_stats[client][i][LOG_HIT_DEATHS] > 0)
			{
				if (g_t_knife)
				{
					LogEvent("{\"event\": \"knife_weapon_stats\", \"player\": %s, \"weapon\": \"%s\", \"shots\": %d, \"hits\": %d, \"kills\": %d, \"headshots\": %d, \"tks\": %d, \"damage\": %d, \"deaths\": %d, \"head\": %d, \"chest\": %d, \"stomach\": %d, \"leftArm\": %d, \"rightArm\": %d, \"leftLeg\": %d, \"rightLeg\": %d, \"generic\": %d}", log_string, weapon_list[i], weapon_stats[client][i][LOG_HIT_SHOTS], weapon_stats[client][i][LOG_HIT_HITS], weapon_stats[client][i][LOG_HIT_KILLS], weapon_stats[client][i][LOG_HIT_HEADSHOTS], weapon_stats[client][i][LOG_HIT_TEAMKILLS], weapon_stats[client][i][LOG_HIT_DAMAGE], weapon_stats[client][i][LOG_HIT_DEATHS], weapon_stats[client][i][LOG_HIT_HEAD], weapon_stats[client][i][LOG_HIT_CHEST], weapon_stats[client][i][LOG_HIT_STOMACH], weapon_stats[client][i][LOG_HIT_LEFTARM], weapon_stats[client][i][LOG_HIT_RIGHTARM], weapon_stats[client][i][LOG_HIT_LEFTLEG], weapon_stats[client][i][LOG_HIT_RIGHTLEG], weapon_stats[client][i][LOG_HIT_GENERIC]);
				}
				else
				{
					LogEvent("{\"event\": \"weapon_stats\", \"player\": %s, \"weapon\": \"%s\", \"shots\": %d, \"hits\": %d, \"kills\": %d, \"headshots\": %d, \"tks\": %d, \"damage\": %d, \"deaths\": %d, \"head\": %d, \"chest\": %d, \"stomach\": %d, \"leftArm\": %d, \"rightArm\": %d, \"leftLeg\": %d, \"rightLeg\": %d, \"generic\": %d}", log_string, weapon_list[i], weapon_stats[client][i][LOG_HIT_SHOTS], weapon_stats[client][i][LOG_HIT_HITS], weapon_stats[client][i][LOG_HIT_KILLS], weapon_stats[client][i][LOG_HIT_HEADSHOTS], weapon_stats[client][i][LOG_HIT_TEAMKILLS], weapon_stats[client][i][LOG_HIT_DAMAGE], weapon_stats[client][i][LOG_HIT_DEATHS], weapon_stats[client][i][LOG_HIT_HEAD], weapon_stats[client][i][LOG_HIT_CHEST], weapon_stats[client][i][LOG_HIT_STOMACH], weapon_stats[client][i][LOG_HIT_LEFTARM], weapon_stats[client][i][LOG_HIT_RIGHTARM], weapon_stats[client][i][LOG_HIT_LEFTLEG], weapon_stats[client][i][LOG_HIT_RIGHTLEG], weapon_stats[client][i][LOG_HIT_GENERIC]);
				}
			}
		}
		new round_stats[LOG_HIT_NUM];
		for (new i = 0; i < NUM_WEAPONS; i++)
		{
			for (new x = 0; x < LOG_HIT_NUM; x++)
			{
				round_stats[x] += weapon_stats[client][i][x];
			}
		}
		if (g_t_knife)
		{
			LogEvent("{\"event\": \"knife_round_stats\", \"player\": %s, \"shots\": %d, \"hits\": %d, \"kills\": %d, \"headshots\": %d, \"tks\": %d, \"damage\": %d, \"assists\": %d, \"assists_tk\": %d, \"deaths\": %d, \"head\": %d, \"chest\": %d, \"stomach\": %d, \"leftArm\": %d, \"rightArm\": %d, \"leftLeg\": %d, \"rightLeg\": %d, \"generic\": %d}", log_string, round_stats[LOG_HIT_SHOTS], round_stats[LOG_HIT_HITS], round_stats[LOG_HIT_KILLS], round_stats[LOG_HIT_HEADSHOTS], round_stats[LOG_HIT_TEAMKILLS], round_stats[LOG_HIT_DAMAGE], assist_stats[client][ASSIST_COUNT], assist_stats[client][ASSIST_COUNT_TK], round_stats[LOG_HIT_DEATHS], round_stats[LOG_HIT_HEAD], round_stats[LOG_HIT_CHEST], round_stats[LOG_HIT_STOMACH], round_stats[LOG_HIT_LEFTARM], round_stats[LOG_HIT_RIGHTARM], round_stats[LOG_HIT_LEFTLEG], round_stats[LOG_HIT_RIGHTLEG], round_stats[LOG_HIT_GENERIC]);
		}
		else
		{
			LogEvent("{\"event\": \"round_stats\", \"player\": %s, \"shots\": %d, \"hits\": %d, \"kills\": %d, \"headshots\": %d, \"tks\": %d, \"damage\": %d, \"assists\": %d, \"assists_tk\": %d, \"deaths\": %d, \"head\": %d, \"chest\": %d, \"stomach\": %d, \"leftArm\": %d, \"rightArm\": %d, \"leftLeg\": %d, \"rightLeg\": %d, \"generic\": %d}", log_string, round_stats[LOG_HIT_SHOTS], round_stats[LOG_HIT_HITS], round_stats[LOG_HIT_KILLS], round_stats[LOG_HIT_HEADSHOTS], round_stats[LOG_HIT_TEAMKILLS], round_stats[LOG_HIT_DAMAGE], assist_stats[client][ASSIST_COUNT], assist_stats[client][ASSIST_COUNT_TK], round_stats[LOG_HIT_DEATHS], round_stats[LOG_HIT_HEAD], round_stats[LOG_HIT_CHEST], round_stats[LOG_HIT_STOMACH], round_stats[LOG_HIT_LEFTARM], round_stats[LOG_HIT_RIGHTARM], round_stats[LOG_HIT_LEFTLEG], round_stats[LOG_HIT_RIGHTLEG], round_stats[LOG_HIT_GENERIC]);
		}
		ResetPlayerStats(client);
	}
}

LogClutchStats(client)
{
	if (IsClientInGame(client) && GetClientTeam(client) > 1)
	{
		if (clutch_stats[client][CLUTCH_LAST] == 1)
		{
			new String:log_string[384];
			CS_GetLogString(client, log_string, sizeof(log_string));
			if (g_t_knife)
			{
				LogEvent("{\"event\": \"knife_player_clutch\", \"player\": %s, \"versus\": %d, \"frags\": %d, \"bombPlanted\": %d, \"won\": %d}", log_string, clutch_stats[client][CLUTCH_VERSUS], clutch_stats[client][CLUTCH_FRAGS], g_planted, clutch_stats[client][CLUTCH_WON]);
			}
			else
			{
				LogEvent("{\"event\": \"player_clutch\", \"player\": %s, \"versus\": %d, \"frags\": %d, \"bombPlanted\": %d, \"won\": %d}", log_string, clutch_stats[client][CLUTCH_VERSUS], clutch_stats[client][CLUTCH_FRAGS], g_planted, clutch_stats[client][CLUTCH_WON]);
			}
			clutch_stats[client][CLUTCH_LAST] = 0;
			clutch_stats[client][CLUTCH_VERSUS] = 0;
			clutch_stats[client][CLUTCH_FRAGS] = 0;
			clutch_stats[client][CLUTCH_WON] = 0;
		}
	}
}

GetWeaponIndex(const String:weapon[])
{
	for (new i = 0; i < NUM_WEAPONS; i++)
	{
		if (StrEqual(weapon, weapon_list[i], false))
		{
			return i;
		}
	}
	return -1;
}

Handle:MySQL_Connect()
{
	new String:error[256];
	new Handle:dbc = INVALID_HANDLE;
	
	if (SQL_CheckConfig("warmod"))
	{
		dbc = SQL_Connect("warmod", true, error, sizeof(error));
		if (dbc == INVALID_HANDLE)
		{
			LogError(error);
		}
	}
	else
	{
		LogError("No WarMod database configuration found (note: case-sensitive)!");
	}
	
	return dbc;
}

public Action:CreateTable(client, args)
{
	new Handle:dbc = MySQL_Connect();
	if (dbc == INVALID_HANDLE)
	{
		return;
	}
	
	new String:table_name[128];
	GetConVarString(g_h_table_name, table_name, sizeof(table_name));
	new success;
	if (GetConVarBool(g_h_sql_beta))
	{
		success = MySQL_CreateTableBeta(dbc, table_name);
	}
	else
	{
		success = MySQL_CreateTable(dbc, table_name);
	}
	if (success)
	{
		ReplyToCommand(client, "WarMod results table creation successful!");
	}
	
	CloseHandle(dbc);
}

MySQL_CreateTableBeta(Handle:dbc, String:table_name[])
{
	new String:query_str[1024];
	Format(query_str, sizeof(query_str), "CREATE TABLE IF NOT EXISTS `%s` (`match_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT, `match_start` DATETIME NOT NULL, `match_end` DATETIME NOT NULL, `map` VARCHAR(64) NOT NULL, `max_rounds` TINYINT(3) unsigned NOT NULL, `overtime_max_rounds` TINYINT(3) UNSIGNED NOT NULL, `overtime_count` TINYINT(3) UNSIGNED NOT NULL, `played_out` TINYINT(1) NOT NULL, `t_name` VARCHAR(128) NOT NULL, `t_overall_score` TINYINT(3) UNSIGNED NOT NULL, `t_first_half_score` TINYINT(3) UNSIGNED NOT NULL, `t_second_half_score` TINYINT(3) UNSIGNED NOT NULL, `t_overtime_score` TINYINT(3) UNSIGNED NOT NULL, `ct_name` VARCHAR(128) NOT NULL, `ct_overall_score` TINYINT(3) UNSIGNED NOT NULL, `ct_first_half_score` TINYINT(3) UNSIGNED NOT NULL, `ct_second_half_score` TINYINT(3) UNSIGNED NOT NULL, `ct_overtime_score` TINYINT(3) UNSIGNED NOT NULL, `demo_name` VARCHAR(128), PRIMARY KEY (`match_id`));", table_name);
	new success = SQL_FastQuery(dbc, query_str);
	if (!success)
	{
		new String:error[256];
		SQL_GetError(dbc, error, sizeof(error));
		
		LogError(error);
		return false;
	}
	return true;
}

MySQL_CreateTable(Handle:dbc, String:table_name[])
{
	new String:query_str[1024];
	Format(query_str, sizeof(query_str), "CREATE TABLE IF NOT EXISTS `%s` (`match_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT, `match_start` DATETIME NOT NULL, `match_end` DATETIME NOT NULL, `map` VARCHAR(64) NOT NULL, `max_rounds` TINYINT(3) unsigned NOT NULL, `overtime_max_rounds` TINYINT(3) UNSIGNED NOT NULL, `overtime_count` TINYINT(3) UNSIGNED NOT NULL, `played_out` TINYINT(1) NOT NULL, `t_name` VARCHAR(128) NOT NULL, `t_overall_score` TINYINT(3) UNSIGNED NOT NULL, `t_first_half_score` TINYINT(3) UNSIGNED NOT NULL, `t_second_half_score` TINYINT(3) UNSIGNED NOT NULL, `t_overtime_score` TINYINT(3) UNSIGNED NOT NULL, `ct_name` VARCHAR(128) NOT NULL, `ct_overall_score` TINYINT(3) UNSIGNED NOT NULL, `ct_first_half_score` TINYINT(3) UNSIGNED NOT NULL, `ct_second_half_score` TINYINT(3) UNSIGNED NOT NULL, `ct_overtime_score` TINYINT(3) UNSIGNED NOT NULL, PRIMARY KEY (`match_id`));", table_name);
	new success = SQL_FastQuery(dbc, query_str);
	if (!success)
	{
		new String:error[256];
		SQL_GetError(dbc, error, sizeof(error));
		
		LogError(error);
		return false;
	}
	return true;
}

MySQL_UploadResultsBeta(match_length, String:map[], max_rounds, overtime_max_rounds, overtime_count, bool:played_out, String:t_name[], t_overall_score, t_first_half_score, t_second_half_score, t_overtime_score, String:ct_name[], ct_overall_score, ct_first_half_score, ct_second_half_score, ct_overtime_score)
{
	new Handle:dbc = MySQL_Connect();
	if (dbc == INVALID_HANDLE)
	{
		LogError("Invalid database connection - cannot upload match results");
		return;
	}
	
	new String:error[256];
	new String:query_str[1024];
	new String:table_name[128];
	
	GetConVarString(g_h_table_name, table_name, sizeof(table_name));
	SQL_EscapeString(dbc, table_name, table_name, sizeof(table_name));
	
	MySQL_CreateTable(dbc, table_name);
	
	Format(query_str, sizeof(query_str), "INSERT INTO `%s` (`match_id`, `match_start`, `match_end`, `map`, `max_rounds`, `overtime_max_rounds`, `overtime_count`, `played_out`, `t_name`, `t_overall_score`, `t_first_half_score`, `t_second_half_score`, `t_overtime_score`, `ct_name`, `ct_overall_score`, `ct_first_half_score`, `ct_second_half_score`, `ct_overtime_score`, `demo_name`) VALUES (NULL, DATE_SUB(UTC_TIMESTAMP(), INTERVAL ? SECOND), UTC_TIMESTAMP(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", table_name);
	new Handle:db_query = SQL_PrepareQuery(dbc, query_str, error, sizeof(error));
	
	if (db_query == INVALID_HANDLE)
	{
		return;
	}
	
	new pid = 0;
	
	SQL_BindParamInt(db_query, pid++, match_length, false);
	SQL_BindParamString(db_query, pid++, map, false);
	SQL_BindParamInt(db_query, pid++, max_rounds, false);
	SQL_BindParamInt(db_query, pid++, overtime_max_rounds, false);
	SQL_BindParamInt(db_query, pid++, overtime_count, false);
	if (played_out)
	{
		SQL_BindParamInt(db_query, pid++, 1, false);
	}
	else
	{
		SQL_BindParamInt(db_query, pid++, 0, false);
	}
	SQL_BindParamString(db_query, pid++, t_name, false);
	SQL_BindParamInt(db_query, pid++, t_overall_score, false);
	SQL_BindParamInt(db_query, pid++, t_first_half_score, false);
	SQL_BindParamInt(db_query, pid++, t_second_half_score, false);
	SQL_BindParamInt(db_query, pid++, t_overtime_score, false);
	SQL_BindParamString(db_query, pid++, ct_name, false);
	SQL_BindParamInt(db_query, pid++, ct_overall_score, false);
	SQL_BindParamInt(db_query, pid++, ct_first_half_score, false);
	SQL_BindParamInt(db_query, pid++, ct_second_half_score, false);
	SQL_BindParamInt(db_query, pid++, ct_overtime_score, false);
	SQL_BindParamString(db_query, pid++, g_sDemoName, false);
	
	SQL_Execute(db_query);
	
	CloseHandle(db_query);
	
	CloseHandle(dbc);
}

MySQL_UploadResults(match_length, String:map[], max_rounds, overtime_max_rounds, overtime_count, bool:played_out, String:t_name[], t_overall_score, t_first_half_score, t_second_half_score, t_overtime_score, String:ct_name[], ct_overall_score, ct_first_half_score, ct_second_half_score, ct_overtime_score)
{
	new Handle:dbc = MySQL_Connect();
	if (dbc == INVALID_HANDLE)
	{
		LogError("Invalid database connection - cannot upload match results");
		return;
	}
	
	new String:error[256];
	new String:query_str[1024];
	new String:table_name[128];
	
	GetConVarString(g_h_table_name, table_name, sizeof(table_name));
	SQL_EscapeString(dbc, table_name, table_name, sizeof(table_name));
	
	MySQL_CreateTable(dbc, table_name);
	
	Format(query_str, sizeof(query_str), "INSERT INTO `%s` (`match_id`, `match_start`, `match_end`, `map`, `max_rounds`, `overtime_max_rounds`, `overtime_count`, `played_out`, `t_name`, `t_overall_score`, `t_first_half_score`, `t_second_half_score`, `t_overtime_score`, `ct_name`, `ct_overall_score`, `ct_first_half_score`, `ct_second_half_score`, `ct_overtime_score`) VALUES (NULL, DATE_SUB(UTC_TIMESTAMP(), INTERVAL ? SECOND), UTC_TIMESTAMP(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", table_name);
	new Handle:db_query = SQL_PrepareQuery(dbc, query_str, error, sizeof(error));
	
	if (db_query == INVALID_HANDLE)
	{
		return;
	}
	
	new pid = 0;
	
	SQL_BindParamInt(db_query, pid++, match_length, false);
	SQL_BindParamString(db_query, pid++, map, false);
	SQL_BindParamInt(db_query, pid++, max_rounds, false);
	SQL_BindParamInt(db_query, pid++, overtime_max_rounds, false);
	SQL_BindParamInt(db_query, pid++, overtime_count, false);
	if (played_out)
	{
		SQL_BindParamInt(db_query, pid++, 1, false);
	}
	else
	{
		SQL_BindParamInt(db_query, pid++, 0, false);
	}
	SQL_BindParamString(db_query, pid++, t_name, false);
	SQL_BindParamInt(db_query, pid++, t_overall_score, false);
	SQL_BindParamInt(db_query, pid++, t_first_half_score, false);
	SQL_BindParamInt(db_query, pid++, t_second_half_score, false);
	SQL_BindParamInt(db_query, pid++, t_overtime_score, false);
	SQL_BindParamString(db_query, pid++, ct_name, false);
	SQL_BindParamInt(db_query, pid++, ct_overall_score, false);
	SQL_BindParamInt(db_query, pid++, ct_first_half_score, false);
	SQL_BindParamInt(db_query, pid++, ct_second_half_score, false);
	SQL_BindParamInt(db_query, pid++, ct_overtime_score, false);
	
	SQL_Execute(db_query);
	
	CloseHandle(db_query);
	
	CloseHandle(dbc);
}

public AddToDatabase(Handle:owner, Handle:hQuery, const String:error[], any:client)
{
	if (hQuery == INVALID_HANDLE)
	{
		LogToGame("[CommsTools] There was an error writing to the Database, %s",error);
		PrintToServer("[CommsTools] There was an error writing to the Database");
		
		return;
	}
	else
	{
		CloseHandle(hQuery);
	}
	
}

public MenuHandler(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	new String:menu_name[256];
	GetTopMenuObjName(topmenu, object_id, menu_name, sizeof(menu_name));
	SetGlobalTransTarget(param);
	
	if (StrEqual(menu_name, "WarModCommands"))
	{
		if (action == TopMenuAction_DisplayTitle)
		{
			Format(buffer, maxlength, "%t:", "Admin_Menu WarMod Commands");
		}
		else if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu WarMod Commands");
		}
	}
	else if (StrEqual(menu_name, "forcestart"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu Force Start");
		}
		else if (action == TopMenuAction_SelectOption)
		{
			ForceStart(param, 0);
		}
	}
	else if (StrEqual(menu_name, "readyup"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			if (g_ready_enabled)
			{
				Format(buffer, maxlength, "%t", "Admin_Menu Disable ReadyUp");
			}
			else
			{
				Format(buffer, maxlength, "%t", "Admin_Menu Enable ReadyUp");
			}
		}
		else if (action == TopMenuAction_SelectOption)
		{
			ReadyToggle(param, 0);
		}
	}
	else if (StrEqual(menu_name, "knife"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu Knife");
		}
		else if (action == TopMenuAction_SelectOption)
		{
			KnifeOn3(param, 0);
		}
	}
	else if (StrEqual(menu_name, "cancelhalf"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu Cancel Half");
		}
		else if (action == TopMenuAction_SelectOption)
		{
			NotLive(param, 0);
		}
	}
	else if (StrEqual(menu_name, "cancelmatch"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu Cancel Match");
		}
		else if (action == TopMenuAction_SelectOption)
		{
			CancelMatch(param, 0);
		}
	}
	else if (StrEqual(menu_name, "forceallready"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu ForceAllReady");
		}
		else if (action == TopMenuAction_SelectOption)
		{
			ForceAllReady(param, 0);
		}
	}
	else if (StrEqual(menu_name, "forceallunready"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu ForceAllUnready");
		}
		else if (action == TopMenuAction_SelectOption)
		{
			ForceAllUnready(param, 0);
		}
	}
	else if (StrEqual(menu_name, "forceallspectate"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			Format(buffer, maxlength, "%t", "Admin_Menu ForceAllSpectate");
		}
		else if (action == TopMenuAction_SelectOption)
		{
			ForceAllSpectate(param, 0);
		}
	}
	else if (StrEqual(menu_name, "toggleactive"))
	{
		if (action == TopMenuAction_DisplayOption)
		{
			if (GetConVarBool(g_h_active))
			{
				Format(buffer, maxlength, "%t", "Admin_Menu Deactivate WarMod");
			}
			else
			{
				Format(buffer, maxlength, "%t", "Admin_Menu Activate WarMod");
			}
		}
		else if (action == TopMenuAction_SelectOption)
		{
			ActiveToggle(param, 0);
		}
	}
}

public Action:RestartRound(Handle:timer, any:delay)
{
	ServerCommand("mp_restartgame %d", delay);
}

public Action:PrintToChatDelayed(Handle:timer, Handle:datapack)
{
	decl String:text[128];
	ResetPack(datapack);
	ReadPackString(datapack, text, sizeof(text));
	ServerCommand("say %s", text);
}

public Action:CheckNames(Handle:timer, any:client)
{
	if ((GetConVarBool(g_h_req_names) && g_ready_enabled && !g_live && (StrEqual(g_t_name, DEFAULT_T_NAME, false) || StrEqual(g_ct_name, DEFAULT_CT_NAME, false))) && (!GetConVarBool(g_h_auto_knife) || g_t_had_knife))
	{
		new num_ready;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (g_player_list[i] == PLAYER_READY && IsClientInGame(i) && !IsFakeClient(i))
			{
				num_ready++;
			}
		}
		if (num_ready >= GetConVarInt(g_h_min_ready))
		{
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					PrintToChat(i, "\x01 \x09[\x04%s\x09]\x01 %t", CHAT_PREFIX, "Names Required");
				}
			}
		}
	}
}

public Action:RespawnPlayer(Handle:timer, any:client)
{
	CS_RespawnPlayer(client);
	SetEntData(client, g_iAccount, GetConVarInt(g_h_mp_startmoney));
}

public Action:HelpText(Handle:timer, any:client)
{
	if (!IsActive(0, true))
	{
		return Plugin_Handled;
	}
	
	if (!g_live && g_ready_enabled)
	{
		DisplayHelp(client);
	}
	
	return Plugin_Handled;
}

public Action:LiveWire_Check(Handle:timer)
{
	if (!g_live && !g_lw_connected && GetConVarBool(g_h_lw_enabled))
	{
		LiveWire_Connect();
	}
}

public Action:LiveWire_Ping(Handle:timer)
{
	if (g_lw_connected)
	{
		LogLiveWireEvent("{\"event\": \"ping\"}");
	}
}

public DisplayHelp(client)
{
	if (client == 0)
	{
		PrintHintTextToAll("%t: /ready /unready /info /score", "Available Commands");
	}
	else
	{
		if (IsClientConnected(client) && IsClientInGame(client))
		{
			PrintHintText(client, "%t: /ready /unready /info /score", "Available Commands");
		}
	}
}

public Action:ShowPluginInfo(Handle:timer, any:client)
{
	if (client != 0 && IsClientConnected(client) && IsClientInGame(client))
	{
		new String:max_rounds[64];
		GetConVarName(g_h_max_rounds, max_rounds, sizeof(max_rounds));
		new String:min_ready[64];
		GetConVarName(g_h_min_ready, min_ready, sizeof(min_ready));
		PrintToConsole(client, "===============================================================================");
		PrintToConsole(client, "This server is running WarMod [BFG] %s Server Plugin", WM_VERSION);
		PrintToConsole(client, "");
		PrintToConsole(client, "Created by Twelve-60 and updated by Versatile [BFG]");
		PrintToConsole(client, "");
		PrintToConsole(client, "Messagemode commands:				Aliases:");
		PrintToConsole(client, "  /ready - Mark yourself as ready 		  /rdy /r");
		PrintToConsole(client, "  /unready - Mark yourself as not ready 	  /notready /unrdy /notrdy /ur /nr");
		PrintToConsole(client, "  /info - Display the Ready System if enabled 	  /i");
		PrintToConsole(client, "  /scores - Display the match score if live 	  /score /s");
		PrintToConsole(client, "");
		PrintToConsole(client, "Current settings: %s: %d / %s: %d / mp_match_can_clinch: %d", max_rounds, GetConVarInt(g_h_max_rounds), min_ready, GetConVarInt(g_h_min_ready), GetConVarInt(g_h_play_out));
		PrintToConsole(client, "===============================================================================");
	}
}

public Action:WMVersion(client, args)
{
	if (client == 0)
	{
		PrintToServer("\"wm_version\" = \"%s\"\n - <WarMod_BFG> %s", WM_VERSION, WM_DESCRIPTION);
	}
	else
	{
		PrintToConsole(client, "\"wm_version\" = \"%s\"\n - <WarMod_BFG> %s", WM_VERSION, WM_DESCRIPTION);
	}
	
	return Plugin_Handled;
}

bool:CheckAdminForChat(client)
{
	new AdminId:aid = GetUserAdmin(client);
	if (aid == INVALID_ADMIN_ID)
	{
		return false;			
	}
	return GetAdminFlag(aid, Admin_Chat, Access_Effective);
}

UpdateStatus()
{
	new value;
	if (!g_match)
	{
		if (!g_t_knife)
		{
			if (!g_ready_enabled)
			{
				if (!g_t_had_knife)
				{
					value = 0;
				}
				else
				{
					value = 3;
				}
			}
			else
			{
				if (!g_t_had_knife && GetConVarBool(g_h_auto_knife))
				{
					value = 1;
				}
				else
				{
					value = 4;
				}
			}
		}
		else
		{
			value = 2;
		}
	}
	else
	{
		if (!g_overtime)
		{
			if (!g_live)
			{
				if (!g_ready_enabled)
				{
					if (g_first_half)
					{
						value = 3;
					}
					else
					{
						value = 6;
					}
				}
				else
				{
					if (g_first_half)
					{
						value = 4;
					}
					else
					{
						value = 7;
					}
				}
			}
			else
			{
				if (g_first_half)
				{
					value = 5;
				}
				else
				{
					value = 8;
				}
			}
		}
		else
		{
			if (!g_live)
			{
				if (!g_ready_enabled)
				{
					value = 9;
				}
				else
				{
					value = 10;
				}
			}
			else
			{
				if (g_first_half)
				{
					value = 11 + (g_overtime_count * 2);
				}
				else
				{
					value = 12 + (g_overtime_count * 2);
				}
			}
		}
	}
	SetConVarIntHidden(g_h_status, value);
	return value;
}

GetLoserTeam()
{
	if (GetTTotalScore() > GetCTTotalScore())
	{
		return COUNTER_TERRORIST_TEAM;
	}
	else if (GetTTotalScore() < GetCTTotalScore())
	{
		return TERRORIST_TEAM;
	}
	else
	{
		return -1;
	}
}

KickTeam(team)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == team)
		{
			KickClient(i, "%t", "Autokick");
		}
	}
}

bool:isNumeric(String:argstring[])
{
	new argeLength = strlen(argstring);
	for (new i = 0; i < argeLength; i++)
	{
		if (!IsCharNumeric(argstring[i]))
		{
			return false;
		}
	}
	return true;
}

/*bool:IsAlphaNumeric(const String:TeamName[])
{
	new nameLength = strlen(TeamName);
	for (new i = 0; i < nameLength; i++)
	{
		if (!IsCharAlpha(TeamName[i]) && !IsCharNumeric(TeamName[i]))
		{
			return false;
		}
	}
	return true;
}*/