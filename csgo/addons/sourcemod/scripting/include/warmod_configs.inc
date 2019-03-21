void CheckConFigFiles(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	char dirName[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, cfgFile, sizeof(cfgFile), "plugins/warmod_configs_updater.smx");
	if (FileExists(cfgFile))
	{
		DeleteFile(cfgFile);
	}
	
	BuildPath(Path_SM, cfgFile, sizeof(cfgFile), "plugins/warmod_b.smx");
	if (FileExists(cfgFile))
	{
		DeleteFile(cfgFile);
	}
	
	Format(dirName, sizeof(dirName), "cfg/sourcemod");
	if (!DirExists(dirName))
	{
		CreateDirectory(dirName, 511);
	}
	
	CreateTranslationFile();
	
	Format(cfgFile, sizeof(cfgFile), "cfg/sourcemod/plugin.warmod.cfg");
	if (!FileExists(cfgFile))
	{
		CreateAutoExecConfigFile(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/gamemode_competitive_server.cfg");
	if (!FileExists(cfgFile))
	{
		Gamemode_Competitive_Server(WM_VERSION);
	}
	
	Format(dirName, sizeof(dirName), "cfg/warmod");
	if (!DirExists(dirName))
	{
		CreateDirectory(dirName, 511);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_global.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_Global(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_default.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_Default(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_overtime.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_OverTime(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_playout.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_PlayOut(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_warmup.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_WarmUp(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/practice.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_Practice(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_map_load.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_OnMapLoad(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_knife.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_Knife(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_match_end.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_OnMatchEnd(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/veto_maps_list.txt");
	if (!FileExists(cfgFile))
	{
		CreateVetoMapListFile();
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/team_captains.txt");
	if (!FileExists(cfgFile))
	{
		Team_Captains_File();
	}
}

static void CreateAutoExecConfigFile(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/sourcemod/plugin.warmod.cfg");
	
	Handle file = OpenFile(cfgFile, "w");
	WriteFileLine(file, "// WarMod [BFG] - Auto Executed Config File");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This file will execute when warmod is loaded");
	WriteFileString(file, "exec warmod/on_map_load.cfg", false); // no newline at the end
	CloseHandle(file);
}

static void Gamemode_Competitive_Server(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/gamemode_competitive_server.cfg");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Gamemode Competitive Server Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This config is the base for all the CS:GO server commands");
	WriteFileLine(file, "// Only edit this file for NON-warmod commands");
	WriteFileLine(file, "// This is a modified version of the ESL 5v5 ladder config");
	WriteFileLine(file, "");
	WriteFileLine(file, "ammo_grenade_limit_default 1");
	WriteFileLine(file, "ammo_grenade_limit_flashbang 2");
	WriteFileLine(file, "ammo_grenade_limit_total 4");
	WriteFileLine(file, "");
	WriteFileLine(file, "bot_quota \"0\"					// Determines the total number of bots in the game");
	WriteFileLine(file, "");
	WriteFileLine(file, "cash_player_bomb_defused 300");
	WriteFileLine(file, "cash_player_bomb_planted 300");
	WriteFileLine(file, "cash_player_damage_hostage -30");
	WriteFileLine(file, "cash_player_interact_with_hostage 150");
	WriteFileLine(file, "cash_player_killed_enemy_default 300");
	WriteFileLine(file, "cash_player_killed_enemy_factor 1");
	WriteFileLine(file, "cash_player_killed_hostage -1000");
	WriteFileLine(file, "cash_player_killed_teammate -300");
	WriteFileLine(file, "cash_player_rescued_hostage 1000");
	WriteFileLine(file, "cash_team_elimination_bomb_map 3250");
	WriteFileLine(file, "cash_team_hostage_alive 150");
	WriteFileLine(file, "cash_team_hostage_interaction 150");
	WriteFileLine(file, "cash_team_loser_bonus 1400");
	WriteFileLine(file, "cash_team_loser_bonus_consecutive_rounds 500");
	WriteFileLine(file, "cash_team_planted_bomb_but_defused 800");
	WriteFileLine(file, "cash_team_rescued_hostage 750");
	WriteFileLine(file, "cash_team_terrorist_win_bomb 3500");
	WriteFileLine(file, "cash_team_win_by_defusing_bomb 3500");
	WriteFileLine(file, "cash_team_win_by_hostage_rescue 3500");
	WriteFileLine(file, "cash_player_get_killed 0");
	WriteFileLine(file, "cash_player_respawn_amount 0");
	WriteFileLine(file, "cash_team_elimination_hostage_map_ct 2000");
	WriteFileLine(file, "cash_team_elimination_hostage_map_t 1000");
	WriteFileLine(file, "cash_team_win_by_time_running_out_bomb 3250");
	WriteFileLine(file, "cash_team_win_by_time_running_out_hostage 3250");
	WriteFileLine(file, "");
	WriteFileLine(file, "");
	WriteFileLine(file, "ff_damage_reduction_grenade 0.85           	// How much to reduce damage done to teammates by a thrown grenade.  Range is from 0 - 1 (with 1 being damage equal to what is done to an enemy)");
	WriteFileLine(file, "ff_damage_reduction_bullets 0.33           	// How much to reduce damage done to teammates when shot.  Range is from 0 - 1 (with 1 being damage equal to what is done to an enemy)");
	WriteFileLine(file, "ff_damage_reduction_other 0.4              	// How much to reduce damage done to teammates by things other than bullets and grenades.  Range is from 0 - 1 (with 1 being damage equal to what is done to an enemy)");
	WriteFileLine(file, "ff_damage_reduction_grenade_self 1         	// How much to damage a player does to himself with his own grenade.  Range is from 0 - 1 (with 1 being damage equal to what is done to an enemy)");
	WriteFileLine(file, "");
	WriteFileLine(file, "mp_afterroundmoney 0				// amount of money awared to every player after each round");
	WriteFileLine(file, "mp_autokick 0					// Kick idle/team-killing players");
	WriteFileLine(file, "mp_autoteambalance 0");
	WriteFileLine(file, "mp_buytime 15                           	// How many seconds after round start players can buy items for.");
	WriteFileLine(file, "mp_c4timer 40                           	// How long from when the C4 is armed until it blows");
	WriteFileLine(file, "mp_death_drop_defuser 1				// Drop defuser on player death");
	WriteFileLine(file, "mp_death_drop_grenade 2				// Which grenade to drop on player death: 0=none, 1=best, 2=current or best");
	WriteFileLine(file, "mp_death_drop_gun 1				// Which gun to drop on player death: 0=none, 1=best, 2=current or best");
	WriteFileLine(file, "mp_defuser_allocation 0				// How to allocate defusers to CTs at start or round: 0=none, 1=random, 2=everyone");
	WriteFileLine(file, "mp_do_warmup_period 1				// Whether or not to do a warmup period at the start of a match.");
	WriteFileLine(file, "mp_forcecamera 1                        	// Restricts spectator modes for dead players");
	WriteFileLine(file, "mp_force_pick_time 160				// The amount of time a player has on the team screen to make a selection before being auto-teamed ");
	WriteFileLine(file, "mp_free_armor 0					// Determines whether armor and helmet are given automatically.");
	WriteFileLine(file, "mp_freezetime 12                        	// How many seconds to keep players frozen when the round starts");
	WriteFileLine(file, "mp_friendlyfire 1                       	// Allows team members to injure other members of their team");
	WriteFileLine(file, "mp_halftime 1					// Determines whether or not the match has a team-swapping halftime event.");
	WriteFileLine(file, "mp_halftime_duration 15				// Number of seconds that halftime lasts");
	WriteFileLine(file, "mp_join_grace_time 30				// Number of seconds after round start to allow a player to join a game");
	WriteFileLine(file, "mp_limitteams 0                         	// Max # of players 1 team can have over another (0 disables check)");
	WriteFileLine(file, "mp_logdetail 3                          	// Logs attacks.  Values are: 0=off, 1=enemy, 2=teammate, 3=both)");
	WriteFileLine(file, "mp_molotovusedelay 0                    	// Number of seconds to delay before the molotov can be used after acquiring it");
	WriteFileLine(file, "mp_playercashawards 1				// Players can earn money by performing in-game actions");
	WriteFileLine(file, "mp_playerid 0					// Controls what information player see in the status bar: 0 all names; 1 team names; 2 no names ");
	WriteFileLine(file, "mp_playerid_delay 0.5				// Number of seconds to delay showing information in the status bar");
	WriteFileLine(file, "mp_playerid_hold 0.25				// Number of seconds to keep showing old information in the status bar");
	WriteFileLine(file, "mp_round_restart_delay 5			// Number of seconds to delay before restarting a round after a win");
	WriteFileLine(file, "mp_roundtime 1.92                       	// How many minutes each round takes.");
	WriteFileLine(file, "mp_roundtime_defuse 1.92                	// How many minutes each round takes on defusal maps.");
	WriteFileLine(file, "mp_solid_teammates 1 				// Determines whether teammates are solid or not.");
	WriteFileLine(file, "mp_teamcashawards 1				// Teams can earn money by performing in-game actions");
	WriteFileLine(file, "mp_timelimit 0                           	// game time per map in minutes");
	WriteFileLine(file, "mp_tkpunish 0					// Will a TK'er be punished in the next round?  {0=no,  1=yes}");
	WriteFileLine(file, "mp_warmuptime 1					// If true, there will be a warmup period/round at the start of each match to allow");
	WriteFileLine(file, "mp_weapons_allow_map_placed 1             	// If this convar is set, when a match starts, the game will not delete weapons placed in the map.");
	WriteFileLine(file, "mp_weapons_allow_zeus 1				// Determines whether the Zeus is purchasable or not.");
	WriteFileLine(file, "mp_win_panel_display_time 15	                // The amount of time to show the win panel between matches / halfs");
	WriteFileLine(file, "");
	WriteFileLine(file, "spec_freeze_time 5.0                            // Time spend frozen in observer freeze cam.");
	WriteFileLine(file, "spec_freeze_panel_extended_time 0               // Time spent with the freeze panel still up after observer freeze cam is done.");
	WriteFileLine(file, "");
	WriteFileLine(file, "sv_accelerate 5.5			        // ( def. \"10\" ) client notify replicated ");
	WriteFileLine(file, "sv_stopspeed 80					//");
	WriteFileLine(file, "sv_allow_votes 0				// Allow voting?");
	WriteFileLine(file, "sv_allow_wait_command 0			        // Allow or disallow the wait command on clients connected to this server.");
	WriteFileLine(file, "sv_alltalk 0					// Players can hear all other players' voice communication, no team restrictions");
	WriteFileLine(file, "sv_alternateticks 0				// If set, server only simulates entities on even numbered ticks.");
	WriteFileLine(file, "sv_cheats 0                                     // Allow cheats on server");
	WriteFileLine(file, "sv_clockcorrection_msecs 15                     // The server tries to keep each player's m_nTickBase withing this many msecs of the server absolute tickcount");
	WriteFileLine(file, "sv_consistency 0				// Whether the server enforces file consistency for critical files");
	WriteFileLine(file, "sv_contact 0					// Contact email for server sysop");
	WriteFileLine(file, "sv_damage_print_enable 1                        // Turn this off to disable the player's damage feed in the console after getting killed.");
	WriteFileLine(file, "sv_dc_friends_reqd 0			        // Set this to 0 to allow direct connects to a game in progress even if no presents");
	WriteFileLine(file, "sv_deadtalk 1					// Dead players can speak (voice, text) to the living");
	WriteFileLine(file, "sv_forcepreload 0				// Force server side preloading.");
	WriteFileLine(file, "sv_friction 5.2					// World friction.");
	WriteFileLine(file, "sv_full_alltalk 0				// Any player (including Spectator team) can speak to any other player");
	WriteFileLine(file, "sv_gameinstructor_disable 1		        // Force all clients to disable their game instructors.");
	WriteFileLine(file, "sv_ignoregrenaderadio 0                         // Turn off Fire in the hole messages");
	WriteFileLine(file, "sv_kick_players_with_cooldown 0                 // (0: do not kick; 1: kick Untrusted players; 2: kick players with any cooldown)");
	WriteFileLine(file, "sv_kick_ban_duration 0                          // How long should a kick ban from the server should last (in minutes)");
	WriteFileLine(file, "sv_lan 0                                        // Server is a lan server ( no heartbeat, no authentication, no non-class C addresses )");
	WriteFileLine(file, "sv_log_onefile 0				// Log server information to only one file.");
	WriteFileLine(file, "sv_logbans 1					// Log server bans in the server logs.");
	WriteFileLine(file, "sv_logecho 1					// Echo log information to the console.");
	WriteFileLine(file, "sv_logfile 1					// Log server information in the log file.");
	WriteFileLine(file, "sv_logflush 0					// Flush the log file to disk on each write (slow).");
	WriteFileLine(file, "sv_logsdir logfiles                             // Folder in the game directory where server logs will be stored.");
	WriteFileLine(file, "sv_maxrate 0					// min. 0.000000 max. 30000.000000 replicated  Max bandwidth rate allowed on server, 0 == unlimited");
	WriteFileLine(file, "sv_mincmdrate 64				// This sets the minimum value for cl_cmdrate. 0 == unlimited.");
	WriteFileLine(file, "sv_minupdaterate 64			// This sets the minimum value for cl_updaterate. 0 == unlimited.");
	WriteFileLine(file, "sv_minrate 80000				// Min bandwidth rate allowed on server, 0 == unlimited");
	WriteFileLine(file, "sv_competitive_minspec 1                        // Enable to force certain client convars to minimum/maximum values to help prevent competitive advantages.");
	WriteFileLine(file, "sv_competitive_official_5v5 1			// Enable to force the server to show 5v5 scoreboards and allows spectators to see characters through walls.");
	WriteFileLine(file, "sv_pausable 1                                   // Is the server pausable.");
	WriteFileLine(file, "sv_pure 1");
	WriteFileLine(file, "sv_pure_kick_clients 1                          // If set to 1, the server will kick clients with mismatching files. Otherwise, it will issue a warning to the client.");
	WriteFileLine(file, "sv_pure_trace 0					// If set to 1, the server will print a message whenever a client is verifying a CR");
	WriteFileLine(file, "sv_spawn_afk_bomb_drop_time 30                 	// Players that spawn and don't move for longer than sv_spawn_afk_bomb_drop_time (default 15 seconds) will automatically drop the bomb.");
	WriteFileLine(file, "sv_steamgroup_exclusive 0                     	// If set, only members of Steam group will be able to join the server when it's empty, public people will be able to join the server only if it has players.");
	WriteFileLine(file, "sv_voiceenable 1");
	WriteFileLine(file, "sv_coaching_enabled 1			// To enable coaches.  To coach a team, type either 'coach t' or 'coach ct'.", false); // no newline at the end
	CloseHandle(file);
}

static void RuleSet_Global(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_global.cfg");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Global Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This config is executed by all other rulesets");
	WriteFileLine(file, "// It holds the majority of commands, so that each ruleset can use as a base configuration");
	WriteFileLine(file, "//Remove prac commands");
	WriteFileLine(file, "");
	WriteFileLine(file, "sv_infinite_ammo				\"0\"	//Players active weapon will never run out of ammo. If set to 2 then player has infinite total ammo but still has to reload the weapon");
	WriteFileLine(file, "sv_showimpacts				\"0\"	//Shows client (red) and server (blue) bullet impact point (1=both, 2=client-only, 3=server-only)");
	WriteFileLine(file, "sv_cheats				\"0\"	//Allow cheats on server (cheat console commands not hacks)");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Multiplayer");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_active				\"1\"	//Enable or disable WarMod as active");
	WriteFileLine(file, "wm_max_players				\"10\"	//Sets the maximum players allowed on both teams combined, others will be forced to spectator (0 = unlimited)");
	WriteFileLine(file, "wm_round_money				\"1\"	//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "wm_min_ready				\"10\"	//Sets the minimum required ready players to Live on 3");
	WriteFileLine(file, "wm_ingame_scores			\"1\"	//Enable or disable ingame scores to be showed at the end of each round");
	WriteFileLine(file, "wm_lock_teams				\"1\"	//Enable or disable locked teams when a match is running");
	WriteFileLine(file, "tv_enable					\"1\"	//GOTV enabled?");
	WriteFileLine(file, "wm_auto_record				\"1\"	//Enable or disable auto SourceTV demo record on Live on 3");
	WriteFileLine(file, "");
	WriteFileLine(file, "//Damage Printer");
	WriteFileLine(file, "wm_damageprint_auto_color		 \"1\"	//Whether colors are automatically inserted for damage values, changing depending on if the damage resulted in a kill");
	WriteFileLine(file, "wm_damageprint_enabled			\"0\"	//Whether to enabled damage print to client on round end");
	WriteFileLine(file, "wm_damageprint_format			\"--> ({DMG_TO} dmg / {HITS_TO} hits) to ({DMG_FROM} dmg / {HITS_FROM} hits) from {NAME} ({HEALTH} HP)\"	//Format of the damage output string. Avaliable tags are in the default, color tags such as {LIGHT_RED} and {GREEN} also work.");
	
	WriteFileLine(file, "//WarMod Knife");
	WriteFileLine(file, "wm_auto_knife				\"0\"	//Enable or disable the knife round before going live");
	WriteFileLine(file, "wm_knife_auto_start			\"0\"	//Enable or disable after knife round to be forced lived");
	WriteFileLine(file, "wm_knife_hegrenade			\"0\"	//Enable or disable giving a player a hegrenade on Knife on 3");
	WriteFileLine(file, "wm_knife_flashbang			\"0\"	//Sets how many flashbangs to give a player on Knife on 3");
	WriteFileLine(file, "wm_knife_smokegrenade			\"0\"	//Enable or disable giving a player a smokegrenade on Knife on 3");
	WriteFileLine(file, "wm_knife_zeus				\"0\"	//Enable or disable giving a player a zeus on Knife on 3");
	WriteFileLine(file, "wm_knife_armor				\"1\"	//Enable or disable giving a player Armor on Knife on 3");
	WriteFileLine(file, "wm_knife_helmet				\"0\"	//Enable or disable giving a player a Helmet on Knife on 3 [requires armor active]");
	WriteFileLine(file, "wm_name_fix				\"0\"	//Fix name swap after knife round");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Pause");
	WriteFileLine(file, "");
	WriteFileLine(file, "sv_pausable				\"1\"	//Is the server pausable");
	WriteFileLine(file, "wm_auto_pause			\"0\"	//Will pause server if team players equals less than half of wm_max_players: 0 = off, 1 = on");
	WriteFileLine(file, "wm_pause_confirm			\"0\"	//Wait for other team to confirm pause: 0 = off, 1 = on");
	WriteFileLine(file, "wm_unpause_confirm		\"1\"	//Wait for other team to confirm unpause: 0 = off, 1 = on");
	WriteFileLine(file, "wm_auto_unpause			\"1\"	//Sets auto unpause: 0 = off, 1 = on");
	WriteFileLine(file, "wm_auto_unpause_delay		\"180\"	//Sets the seconds to wait before auto unpause");
	WriteFileLine(file, "wm_pause_limit			\"5\"	//Sets max pause count per team per half");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Misc");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_show_info				\"1\"	//Enable or disable the display of the Ready System to players");
	WriteFileLine(file, "wm_rcon_only				\"0\"	//Enable or disable admin commands to be only executed via RCON or console");
	WriteFileLine(file, "wm_require_names			\"0\"	//Enable or disable the requirement of set team names for lo3");
	WriteFileLine(file, "wm_require_logos			\"0\"	//Enable or disable the requirement of set team logos for lo3");
	WriteFileLine(file, "wm_logos_menu_only			\"0\"	//Set to use the Menu only for Logo Selection");
	WriteFileLine(file, "wm_random_team_names			\"0\"	//Enable or disable the random set of a pro team name for the match");
	WriteFileLine(file, "wm_auto_ready				\"1\"	//Enable or disable the ready system being automatically enabled on map change");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Ban");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_ban_on_disconnect		\"0\"	//Enable or disable players banned on disconnect if match is live");
	WriteFileLine(file, "wm_ban_percentage		\"0.75\"	//Percentage of wm_max_players that will be banned on disconnect");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Warmod Veto");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_veto					\"1\"	//Veto Style: 0 = off, 1 = Bo1, 2 = Bo2, 3 = Bo3, 5 = Bo5");
	WriteFileLine(file, "wm_veto_knife				\"1\"	//Requires a knife round to determine who votes first: 0 = off, 1 = on");
	WriteFileLine(file, "wm_veto_bo3				\"0\"	//Veto Style: 0 = Normal, 1 = New");
	WriteFileLine(file, "wm_veto_random				\"0\"	//After the vetoing is done, will a map be picked at random?");
	WriteFileLine(file, "wm_veto_select				\"1\"	//On last two maps of Veto Bo1 will it be select map to play: 0 = No, 1 = Yes");
	WriteFileLine(file, "wm_captain_from_file		\"0\"	//Get team captains from file? 0 = No, 1 = Yes");
	WriteFileLine(file, "wm_pugsetup_maplist_file			\"warmod/veto_maps_list.txt\"	//Veto Map List to read from. Located in cfg folder");
	WriteFileLine(file, "wm_pugsetup_randomize_maps		\"1\"	//When maps are shown in the map vote/veto, should their order be randomized?");
	WriteFileLine(file, "");
	WriteFileLine(file, "exec gamemode_competitive_server.cfg", false);// no newline at the end
	CloseHandle(file);
}

static void RuleSet_Default(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_default.cfg");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Default Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change Default commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_default.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"6\"		//When overtime is enabled play additional rounds to determine winner");
	WriteFileLine(file, "mp_overtime_startmoney		\"10000\"		//Money assigned to all players at start of every overtime half");
	WriteFileLine(file, "mp_startmoney		\"800\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.92\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Default Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static void RuleSet_PlayOut(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_playout.cfg");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - PlayOut Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change PlayOut commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_playout.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"0\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"6\"		//When overtime is enabled play additional rounds to determine winner");
	WriteFileLine(file, "mp_overtime_startmoney		\"10000\"		//Money assigned to all players at start of every overtime half");
	WriteFileLine(file, "mp_startmoney		\"800\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.92\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] PlayOut Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static void RuleSet_OverTime(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_overtime.cfg");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - OverTime Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change OverTime commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_overtime.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"1\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"6\"		//When overtime is enabled play additional rounds to determine winner");
	WriteFileLine(file, "mp_overtime_startmoney 		\"10000\"		//Money assigned to all players at start of every overtime half");
	WriteFileLine(file, "mp_startmoney		\"800\"		//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.92\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] OverTime Config Loaded", false);// no newline at the end
	CloseHandle(file);
}

static void RuleSet_WarmUp(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_warmup.cfg");

	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - WarmUp Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change WarmUp commands");
	WriteFileLine(file, "wm_warmup_respawn		\"1\"		//Enable or disable the respawning of players in warmup");
	WriteFileLine(file, "wm_block_warm_up_grenades		\"1\"	//Enable or disable grenade blocking in warmup");
	WriteFileLine(file, "mp_warmuptime		\"300\"		//How long the warmup period lasts. Changing this value resets warmup.");
	WriteFileLine(file, "mp_buytime		\"120\"		//How many seconds after round start players can buy items for.");
	WriteFileLine(file, "mp_freezetime		\"0\"		//How many seconds to keep players frozen when the round starts");
	WriteFileLine(file, "mp_autokick		\"0\"		//Kick idle/team-killing/team-damaging players");
	WriteFileLine(file, "mp_friendlyfire		\"0\"		//Allows team members to injure other members of their team");
	WriteFileLine(file, "mp_startmoney		\"16000\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_warmup_pausetimer		\"1\"		//Set to 1 to stay in warmup indefinitely. Set to 0 to resume the timer.");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "sv_infinite_ammo		\"0\"		//Player's active weapon will never run out of ammo.");
	WriteFileLine(file, "sv_showimpacts		\"0\"			//Shows client (red) and server (blue) bullet impact point");
	WriteFileLine(file, "sv_cheats			\"0\"			//Allow cheats on server");
	WriteFileLine(file, "mp_buy_anywhere		\"0\"		//When set, players can buy anywhere, not only in buyzones");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "mp_death_drop_defuser	\"0\"			// Drop defuser on player death");
	WriteFileLine(file, "mp_death_drop_grenade	\"0\"			// Which grenade to drop on player death: 0=none, 1=best, 2=current or best");
	WriteFileLine(file, "mp_death_drop_gun	\"0\"			// Which gun to drop on player death: 0=none, 1=best, 2=current or best");
	WriteFileLine(file, "wm_active			\"1\"		//Enable or disable WarMod as active");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] WarmUp Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static void RuleSet_Practice(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/practice.cfg");

	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Practice Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change WarmUp commands");
	WriteFileLine(file, "wm_warmup_respawn		\"0\"		//Enable or disable the respawning of players in warmup");
	WriteFileLine(file, "wm_block_warm_up_grenades		\"0\"	//Enable or disable grenade blocking in warmup");
	WriteFileLine(file, "mp_buytime		\"120\"		//How many seconds after round start players can buy items for.");
	WriteFileLine(file, "mp_freezetime		\"0\"		//How many seconds to keep players frozen when the round starts");
	WriteFileLine(file, "mp_autokick		\"0\"		//Kick idle/team-killing/team-damaging players");
	WriteFileLine(file, "mp_startmoney		\"16000\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "sv_infinite_ammo		\"2\"		//Player's active weapon will never run out of ammo.");
	WriteFileLine(file, "sv_showimpacts		\"2\"			//Shows client (red) and server (blue) bullet impact point");
	WriteFileLine(file, "sv_cheats			\"1\"			//Allow cheats on server");
	WriteFileLine(file, "mp_buy_anywhere		\"1\"		//When set, players can buy anywhere, not only in buyzones");
	WriteFileLine(file, "mp_roundtime_defuse		\"9999\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "bot_quota			\"0\"		//Determines the total number of bots in the game.");
	WriteFileLine(file, "wm_active			\"0\"		//Enable or disable WarMod as active");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Practice Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static void RuleSet_OnMapLoad(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_map_load.cfg");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - On Map Load Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This config file is executed on every map change, including when the server first starts");
	WriteFileLine(file, "// Note: Plugins have been loaded by now");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Updater");
	WriteFileLine(file, "");
	WriteFileLine(file, "sm_updater 			\"2\"		//Determines update functionality. (1 = Notify, 2 = Download, 3 = Include source code)");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Configs");
	WriteFileLine(file, "wm_warmod_safemode		\"0\"		//This disables features that usually break on a CS:GO update");
	WriteFileLine(file, "wm_match_config			\"warmod/ruleset_default.cfg\"	//Sets the match config to load on Live on 3");
	WriteFileLine(file, "wm_default_config			\"warmod/ruleset_default.cfg\"	//Sets the match config to load when the default command is called");
	WriteFileLine(file, "wm_overtime_config			\"warmod/ruleset_overtime.cfg\"	//Sets the match config to load when the overtime command is called");
	WriteFileLine(file, "wm_playout_config			\"warmod/ruleset_playout.cfg\"	//Sets the match config to load when the play out command is called");
	WriteFileLine(file, "wm_prac_config			\"warmod/practice.cfg\"	//Loads when the practice command is called");
	WriteFileLine(file, "wm_reset_config			\"warmod/on_match_end.cfg\"	//Sets the config to load at the end/reset of a match");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Stats");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_save_dir				\"warmod\"	//Directory to store SourceTV demos and WarMod logs");
	WriteFileLine(file, "wm_prefix_logs			\"1\"		//Enable or disable the prefixing of \"_\" to uncompleted match SourceTV demos and WarMod logs");
	WriteFileLine(file, "wm_stats_enabled			\"1\"		//Enable or disable statistical logging");
	WriteFileLine(file, "wm_stats_method			\"2\"		//Sets the stats logging method: 0 = UDP stream/server logs, 1 = WarMod logs, 2 = both");
	WriteFileLine(file, "wm_stats_trace			\"0\"		//Enable or disable updating all player positions, every wm_stats_trace_delay seconds");
	WriteFileLine(file, "wm_stats_trace_delay		\"5\"		//The ammount of time between sending player position updates");
	WriteFileLine(file, "mp_teamname_1 			\"\"		//A non-empty string overrides the first team's name");
	WriteFileLine(file, "mp_teamname_2 			\"\"		//A non-empty string overrides the second team's name");
	WriteFileLine(file, "mp_teamlogo_1 			\"\"		//Enter a team's shorthand image name to display their logo");
	WriteFileLine(file, "mp_teamlogo_2 			\"\"		//Enter a team's shorthand image name to display their logo");
	WriteFileLine(file, "wm_competition			\"WarMod BFG\"	//Name of host for a competition. eg. ESEA, Cybergamer, CEVO, ESL");
	WriteFileLine(file, "wm_event					\"Scrim\"		//Name of event. eg. Season #, ODC #, Ladder");
	WriteFileLine(file, "wm_chat_prefix			\"WarMod BFG\"	//Change the chat prefix. Default is WarMod_BFG");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Stats Site");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_site_location			\"\"		//Location of where the stats site is uploaded for download. Do not have '/' at end of string. eg. www.warmod.com");
	WriteFileLine(file, "wm_site_data			\"warmod.bitbucket.org/stats\"		//Location of where the sites images, css and js files are. Do not have '/' at end of string. eg. warmod.bitbucket.org/stats");
	WriteFileLine(file, "wm_demo_location			\"\"		//Location of where the demo is uploaded for download. eg. www.warmod.com/demos/");
	WriteFileLine(file, "wm_forums_location			\"\"		//Location of where the community forums are. eg. www.warmod.com/forums/");
	WriteFileLine(file, "");
	WriteFileLine(file, "// FTP Upload");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_upload_results						\"0\"			//Enable or disable the uploading of match results via MySQL");
	WriteFileLine(file, "wm_table_name							\"wm_results\"	//The MySQL table name to store match results in)");
	WriteFileLine(file, "wm_table_name_players					\"wm_players\"	//The MySQL table name to store match players in)");
	WriteFileLine(file, "");
	WriteFileLine(file, "// FTP Upload");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_autodemoupload_enable				\"1\"			//Automatically upload demos when finished recording");
	WriteFileLine(file, "wm_autodemoupload_bzip2				\"9\"			//Compression level. If set > 0 demos will be compressed before uploading (Requires bzip2 extension)");
	WriteFileLine(file, "wm_autodemoupload_delete				\"0\"			//Delete the demo (and the bz2) if upload was successful");
	WriteFileLine(file, "wm_autodemoupload_ftptargetdemo			\"demos\"		//The ftp target to use for demo uploads");
	WriteFileLine(file, "wm_autodemoupload_ftptargetlog			\"logs\"		//The ftp target to use for log uploads");
	WriteFileLine(file, "wm_autodemoupload_ftptargetstats			\"stats\"		//The ftp target to use for stats site uploads");
	WriteFileLine(file, "wm_autodemoupload_completed			\"0\"			//Only upload demos when match is completed");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Voice Communications");
	WriteFileLine(file, "");
	WriteFileLine(file, "sm_deadtalk					\"0\"			//Controls how dead communicate 0 - Off, 1 - Dead players ignore teams, 2 - Dead players talk to living teammates");
	WriteFileLine(file, "");
	WriteFileLine(file, "exec warmod/ruleset_warmup.cfg", false);// no newline at the end
	CloseHandle(file);
}

static void RuleSet_Knife(char[] WM_VERSION)
{
	ServerCommand("exec warmod/ruleset_knife.cfg");
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_knife.cfg");
	
	DeleteFile(cfgFile);
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Knife Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change Knife commands");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_startmoney		\"0\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"60.00\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"60.00\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Knife Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static void RuleSet_OnMatchEnd(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_match_end.cfg");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - On Match End Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This config is executed at the end or reset of a match");
	WriteFileLine(file, "mp_teamname_1 			\"\"		//A non-empty string overrides the first team's name");
	WriteFileLine(file, "mp_teamname_2 			\"\"		//A non-empty string overrides the second team's name");
	WriteFileLine(file, "mp_teamlogo_1 			\"\"		//Enter a team's shorthand image name to display their logo");
	WriteFileLine(file, "mp_teamlogo_2 			\"\"		//Enter a team's shorthand image name to display their logo", false);
	CloseHandle(file);
}

static void Team_Captains_File()
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/team_captains.txt");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "\"Captains\"");
	WriteFileLine(file, "{");
	WriteFileLine(file, "	\"STEAM_1:0:635066\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"name\"		\"Versatile BFG\"");
	WriteFileLine(file, "		\"teamname\"	\"BFG\"");
	WriteFileLine(file, "		\"teamlogo\"	\"bfg\"");
	WriteFileLine(file, "		\"teamflag\"	\"au\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "}", false);
	CloseHandle(file);
}

static void CreateTranslationFile()
{
	char cfgFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, cfgFile, PLATFORM_MAX_PATH, "translations/warmod.phrases.txt");
	Handle file = OpenFile(cfgFile, "w");
	WriteFileLine(file, "\"Phrases\"");
	WriteFileLine(file, "{");
	WriteFileLine(file, "	\"Safe Mode\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Safe Mode Enabled. Feature is disabled.\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Practice Mode Active\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Practice Mode Activated\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Reset\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match Reset - Game is not live!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Half Reset\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match Half Reset - Game is not live!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Half Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Half Time! Please swap teams...\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Half Time Auto Swap\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Half Time! Swapping teams...\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Full Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Full Time!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Over Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"Overtime! MR{1}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Over Time Sudden Death\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Overtime! Sudden Death\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Playing Out Notice\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"Note: All {1} rounds must be played out!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have been marked as ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have been marked as not ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Score Overtime\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Overtime: \"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Score Overall\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Overall: \"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Round Cancelled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife Round cancelled - Not Live\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Round Inactive\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife Round is not active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System Enabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Ready System - Enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System Disabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Ready System - Disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Active\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Set to Active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Inactive\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Set to Inactive\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Console Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Console cannot be marked as ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Console Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Console cannot be marked as not ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Not on Team\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You are not on a team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Already Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have already been marked as ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Already Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have already been marked as not ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Forced Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Forced all players ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Forced Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Forced all players unready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Forced Spectate\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Forced all players to spectate\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Not In Progress\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match is not in progress!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"T Winning\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"{1} are winning\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Tied\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Scores are tied\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"CT Winning\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"{1} are winning\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Change Teams Midgame\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Blocked - Match is in progress\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Maximum Players\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Teams have reached the maximum player limit\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Nightvision Blocked\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Night vision is disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Grenades Blocked\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Grenades in warmup are disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Ready System\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Begin Msg\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"Match will begin after {1} players are ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"No Players Found\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"No players found\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Info Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Unready:\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Info Exit\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Exit\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System Disabled2\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The Ready System is not enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"ShowInfo Disabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The Ready System display is not enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Is Live\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The match is live\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"WarMod Inactive\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"WarMod is not active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Change T Name\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"Terrorists name set to '{1}'\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Change CT Name\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"Counter-Terrorists name set to '{1}'\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Console\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Console: \"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Available Commands\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Available client commands\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"No Permission\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You do not have permission to use this command\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Minready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"wm_min_ready set to {1}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Maxrounds\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"wm_max_rounds set to {1}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"WarMod Rcon Only\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Admin commands have been restricted to RCON only\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Password\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"sv_password set to '{1}'\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Autokick\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have been automatically kicked from the server\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Names Required\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match will not lo3 until both team names have been set\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Freeze Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Game will pause at freeze time\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Round End\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Game will pause at the end of the round\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Limit\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have used all your pauses already\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on T or CT to use /pause\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a Pause. Please type /pause to pause the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Not Enabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"sv_pauseable is set to 0. Pause function not enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Notice\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match is now Paused. Please type /unpause to unpause the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked to unpause the game. Please type /unpause to unpause the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpaused Match\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have unpaused the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on T or CT to use /unpause\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Pause offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Timer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"seconds until game is auto unpaused\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Auto\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match was auto Unpaused because time limit reached\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Auto Pause Notice\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"Match will be paused because a player from '{1}' has left the server\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Auto Unpause Notice\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"Match has been auto paused because a player from '{1}' has left the server\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Paused Via Rcon\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Server is not paused or was paused via rcon\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Vote Team\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"are voting to stay or switch teams\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Vote\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Please type /stay or /switch\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Stay\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have voted to stay\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Switch\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have voted to switch teams\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name CT\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"CT's please set team name\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name T\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"T's please set team name\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name Both\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Teams please set team name\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name CMD\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"To set team name please type /name TeamName\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Logos Required\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match will not lo3 until both team logos have been set\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Logo CT\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"CT's please set team logo\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Logo T\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"T's please set team logo\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Logo Both\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Teams please set team logos\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Logo CMD\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"To set team logo please type /logo\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The match is now LIVE!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live on 3\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Live on 3\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live on 2\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Live on 2\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live on 1\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Live on 1\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife On 3\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife on 3\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife on 2\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife on 2\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife on 1\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife on 1\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"KNIFE!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Zeus\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"ZEUS!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Good Luck\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Good Luck, Have Fun!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Powered By\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Powered by\"");
	WriteFileLine(file, "	}	");
	WriteFileLine(file, "	\"Admin_Menu WarMod Commands\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"WarMod Commands\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Enable ReadyUp\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Enable ReadyUp\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Disable ReadyUp\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Disable ReadyUp\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Knife\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Force Start\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force Start\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Force End\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force End\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Cancel Half\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Cancel Half\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Cancel Match\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Cancel Match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Cancel Knife\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Cancel Knife\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu ForceAllReady\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force All Ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu ForceAllUnready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force All Unready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu ForceAllSpectate\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force All Spectate\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Activate WarMod\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Activate WarMod\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Deactivate WarMod\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Deactivate WarMod\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Warm Up Active\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Warm Up Active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"FTP Upload Failed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Failed uploading demo file. Check the server log files.\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"FTP Log Upload Successful\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Log file uploaded successfully\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"FTP Demo Upload Successful\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Demo uploaded successfully\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Veto offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto No Maps\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"No maps in bo{1} list\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Bo3 Map List\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s},{2:s},{3:s}\"");
	WriteFileLine(file, "		\"en\"			\"Map 1 = {1}, Map 2 = {2}, Map 3 = {3}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Bo5 Map List\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s},{2:s},{3:s},{4:s},{5:s}\"");
	WriteFileLine(file, "		\"en\"			\"Map 1 = {1}, Map 2 = {2}, Map 3 = {3}, Map 4 = {4}, Map 5 = {5}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Bo2 Map List\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s},{2:s}\"");
	WriteFileLine(file, "		\"en\"			\"Map 1 = {1}, Map 2 = {2}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Disabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Veto system is disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on Terrorist or Counter Terrorist to use !veto\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"have asked for a veto Bo{1}. Please type !veto to start\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Captain\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"captain will be\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto First Second\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"is picking to go first or second in the veto\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on Terrorist or Counter Terrorist to use this command\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Default Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a default match. Please type !default to accept\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Default Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Default offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"PlayOut Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a play out match. Please type !playout to accept\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"PlayOut Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Play Out offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"OverTime Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a over time match. Please type !overtime to accept\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"OverTime Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Over Time offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "}", false);
	CloseHandle(file);
}

static void CreateVetoMapListFile()
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/veto_maps_list.txt");
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "de_dust2");
	WriteFileLine(file, "de_inferno");
	WriteFileLine(file, "de_mirage");
	WriteFileLine(file, "de_train");
	WriteFileLine(file, "de_overpass");
	WriteFileLine(file, "de_cache");
	WriteFileLine(file, "de_cbble", false); // no newline at the end
	CloseHandle(file);
}

void Update_Configs(char[] WM_VERSION)
{
	UpdateRuleSet_Global(WM_VERSION);
}

static void UpdateRuleSet_Global(char[] WM_VERSION)
{
	ServerCommand("exec warmod/ruleset_global.cfg");
	
	char dirName[PLATFORM_MAX_PATH];
	Format(dirName, sizeof(dirName), "cfg/warmod");
	if (!DirExists(dirName))
		CreateDirectory(dirName, 751);
	
	char cfgFile[PLATFORM_MAX_PATH];
	char convarString[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_global.cfg");
	
	DeleteFile(cfgFile);
	
	
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Global Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// This config is executed by all other rulesets");
	WriteFileLine(file, "// It holds the majority of commands, so that each ruleset can use a base configuration");
	WriteFileLine(file, "//Remove prac commands");
	WriteFileLine(file, "");
	WriteFileLine(file, "sv_infinite_ammo				\"0\"	//Players active weapon will never run out of ammo. If set to 2 then player has infinite total ammo but still has to reload the weapon");
	WriteFileLine(file, "sv_showimpacts				\"0\"	//Shows client (red) and server (blue) bullet impact point (1=both, 2=client-only, 3=server-only)");
	WriteFileLine(file, "sv_cheats				\"0\"	//Allow cheats on server (cheat console commands not hacks)");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Multiplayer");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_active				\"%i\"	//Enable or disable WarMod as active", GetConVarInt(FindConVar("wm_active")));
	WriteFileLine(file, "wm_max_players				\"%i\"	//Sets the maximum players allowed on both teams combined, others will be forced to spectator (0 = unlimited)", GetConVarInt(FindConVar("wm_max_players")));
	WriteFileLine(file, "wm_round_money				\"%i\"	//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)", GetConVarInt(FindConVar("wm_round_money")));
	WriteFileLine(file, "wm_min_ready				\"%i\"	//Sets the minimum required ready players to Live on 3", GetConVarInt(FindConVar("wm_min_ready")));
	WriteFileLine(file, "wm_ingame_scores			\"%i\"	//Enable or disable ingame scores to be showed at the end of each round", GetConVarInt(FindConVar("wm_ingame_scores")));
	WriteFileLine(file, "wm_lock_teams				\"%i\"	//Enable or disable locked teams when a match is running", GetConVarInt(FindConVar("wm_lock_teams")));
	WriteFileLine(file, "tv_enable					\"%i\"	//GOTV enabled?", GetConVarInt(FindConVar("tv_enable")));
	WriteFileLine(file, "wm_auto_record				\"%i\"	//Enable or disable auto SourceTV demo record on Live on 3", GetConVarInt(FindConVar("wm_auto_record")));
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Knife");
	WriteFileLine(file, "wm_auto_knife				\"%i\"	//Enable or disable the knife round before going live", GetConVarInt(FindConVar("wm_auto_knife")));
	WriteFileLine(file, "wm_knife_auto_start			\"%i\"	//Enable or disable after knife round to be forced lived", GetConVarInt(FindConVar("wm_knife_auto_start")));
	WriteFileLine(file, "wm_knife_hegrenade			\"%i\"	//Enable or disable giving a player a hegrenade on Knife on 3", GetConVarInt(FindConVar("wm_knife_hegrenade")));
	WriteFileLine(file, "wm_knife_flashbang			\"%i\"	//Sets how many flashbangs to give a player on Knife on 3", GetConVarInt(FindConVar("wm_knife_flashbang")));
	WriteFileLine(file, "wm_knife_smokegrenade			\"%i\"	//Enable or disable giving a player a smokegrenade on Knife on 3", GetConVarInt(FindConVar("wm_knife_smokegrenade")));
	WriteFileLine(file, "wm_knife_zeus				\"%i\"	//Enable or disable giving a player a zeus on Knife on 3", GetConVarInt(FindConVar("wm_knife_zeus")));
	WriteFileLine(file, "wm_knife_armor				\"%i\"	//Enable or disable giving a player Armor on Knife on 3", GetConVarInt(FindConVar("wm_knife_armor")));
	WriteFileLine(file, "wm_knife_helmet				\"%i\"	//Enable or disable giving a player a Helmet on Knife on 3 [requires armor active]", GetConVarInt(FindConVar("wm_knife_helmet")));
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Pause");
	WriteFileLine(file, "");
	WriteFileLine(file, "sv_pausable				\"%i\"	//Is the server pausable.", GetConVarInt(FindConVar("sv_pausable")));
	WriteFileLine(file, "wm_auto_pause			\"%i\"	//Will pause server if team players equals less than half of wm_max_players: 0 = off, 1 = on", GetConVarInt(FindConVar("wm_auto_pause")));
	WriteFileLine(file, "wm_pause_confirm			\"%i\"	//Wait for other team to confirm pause: 0 = off, 1 = on", GetConVarInt(FindConVar("wm_pause_confirm")));
	WriteFileLine(file, "wm_unpause_confirm			\"%i\"	//Wait for other team to confirm unpause: 0 = off, 1 = on", GetConVarInt(FindConVar("wm_unpause_confirm")));
	WriteFileLine(file, "wm_auto_unpause				\"%i\"	//Sets auto unpause: 0 = off, 1 = on", GetConVarInt(FindConVar("wm_auto_unpause")));
	WriteFileLine(file, "wm_auto_unpause_delay			\"%i\"	//Sets the seconds to wait before auto unpause", GetConVarInt(FindConVar("wm_auto_unpause_delay")));
	WriteFileLine(file, "wm_pause_limit				\"%i\"	//Sets max pause count per team per half", GetConVarInt(FindConVar("wm_pause_limit")));
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Misc");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_show_info				\"%i\"	//Enable or disable the display of the Ready System to players", GetConVarInt(FindConVar("wm_show_info")));
	WriteFileLine(file, "wm_rcon_only				\"%i\"	//Enable or disable admin commands to be only executed via RCON or console", GetConVarInt(FindConVar("wm_rcon_only")));
	WriteFileLine(file, "wm_require_names			\"%i\"	//Enable or disable the requirement of set team names for lo3", GetConVarInt(FindConVar("wm_require_names")));
	WriteFileLine(file, "wm_require_logos			\"%i\"	//Enable or disable the requirement of set team logos for lo3", GetConVarInt(FindConVar("wm_require_logos")));
	WriteFileLine(file, "wm_logos_menu_only			\"%i\"	//Set to use the Menu only for Logo Selection", GetConVarInt(FindConVar("wm_logos_menu_only")));
	WriteFileLine(file, "wm_random_team_names			\"%i\"	//Enable or disable the random set of a pro team name for the match", GetConVarInt(FindConVar("wm_random_team_names")));
	WriteFileLine(file, "wm_auto_ready				\"%i\"	//Enable or disable the ready system being automatically enabled on map change", GetConVarInt(FindConVar("wm_auto_ready")));
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Ban");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_ban_on_disconnect		\"%i\"	//Enable or disable players banned on disconnect if match is live", GetConVarInt(FindConVar("wm_ban_on_disconnect")));
	WriteFileLine(file, "wm_ban_percentage		\"%-.2f%\"	//Percentage of wm_max_players that will be banned on disconnect", GetConVarFloat(FindConVar("wm_ban_percentage")));
	WriteFileLine(file, "");
	WriteFileLine(file, "// Warmod Veto");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_veto					\"%i\"	//Veto Style: 0 = off, 1 = Bo1, 2 = Bo2, 3 = Bo3, 5 = Bo5", GetConVarInt(FindConVar("wm_veto")));
	WriteFileLine(file, "wm_veto_knife				\"%i\"	//Requires a knife round to determine who votes first: 0 = off, 1 = on", GetConVarInt(FindConVar("wm_veto_knife")));
	WriteFileLine(file, "wm_veto_bo3				\"%i\"	//Veto Style: 0 = Normal, 1 = New", GetConVarInt(FindConVar("wm_veto_bo3")));
	WriteFileLine(file, "wm_veto_random				\"%i\"	//After the vetoing is done, will a map be picked at random?", GetConVarInt(FindConVar("wm_veto_random")));
	WriteFileLine(file, "wm_veto_select				\"%i\"	//On last two maps of Veto Bo1 will it be select map to play: 0 = No, 1 = Yes", GetConVarInt(FindConVar("wm_veto_select")));
	WriteFileLine(file, "wm_captain_from_file		\"%i\"	//Get team captains from file? 0 = No, 1 = Yes", GetConVarInt(FindConVar("wm_captain_from_file")));
	GetConVarString(FindConVar("wm_pugsetup_maplist_file"), convarString, sizeof(convarString));
	if (StrEqual(convarString, "configs/maps.txt", false))
	{
		Format(convarString, sizeof(convarString), "warmod/veto_maps_list.txt");
	}
	WriteFileLine(file, "wm_pugsetup_maplist_file			\"%s\"	//Veto Map List to read from. Located in cfg folder", convarString);
	WriteFileLine(file, "wm_pugsetup_randomize_maps		\"%i\"	//When maps are shown in the map vote/veto, should their order be randomized?", GetConVarInt(FindConVar("wm_pugsetup_randomize_maps")));
	WriteFileLine(file, "");
	WriteFileLine(file, "exec gamemode_competitive_server.cfg", false);// no newline at the end
	CloseHandle(file);
	
	UpdateRuleSet_Default(WM_VERSION);
}

static void UpdateRuleSet_Default(char[] WM_VERSION)
{
	ServerCommand("exec warmod/ruleset_default.cfg");
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_default.cfg");
	
	DeleteFile(cfgFile);
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Default Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change Default commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_default.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"%i\"		//When overtime is enabled play additional rounds to determine winner", GetConVarInt(FindConVar("mp_overtime_maxrounds")));
	WriteFileLine(file, "mp_overtime_startmoney		\"%i\"		//Money assigned to all players at start of every overtime half", GetConVarInt(FindConVar("mp_overtime_startmoney")));
	WriteFileLine(file, "mp_startmoney		\"800\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.92\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Default Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
	
	UpdateRuleSet_PlayOut(WM_VERSION);
}

static void UpdateRuleSet_PlayOut(char[] WM_VERSION)
{
	ServerCommand("exec warmod/ruleset_playout.cfg");
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_playout.cfg");
	
	DeleteFile(cfgFile);
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - PlayOut Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change PlayOut commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_playout.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"0\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"%i\"		//When overtime is enabled play additional rounds to determine winner", GetConVarInt(FindConVar("mp_overtime_maxrounds")));
	WriteFileLine(file, "mp_overtime_startmoney		\"%i\"		//Money assigned to all players at start of every overtime half", GetConVarInt(FindConVar("mp_overtime_startmoney")));
	WriteFileLine(file, "mp_startmoney		\"800\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.92\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Play Out Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
	
	UpdateRuleSet_OverTime(WM_VERSION);
}

static void UpdateRuleSet_OverTime(char[] WM_VERSION)
{
	ServerCommand("exec warmod/ruleset_overtime.cfg");
	
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_overtime.cfg");
	
	DeleteFile(cfgFile);
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - OverTime Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change OverTime commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_overtime.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"1\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"%i\"		//When overtime is enabled play additional rounds to determine winner", GetConVarInt(FindConVar("mp_overtime_maxrounds")));
	WriteFileLine(file, "mp_overtime_startmoney 		\"%i\"		//Money assigned to all players at start of every overtime half", GetConVarInt(FindConVar("mp_overtime_startmoney")));
	WriteFileLine(file, "mp_startmoney		\"800\"		//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.92\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] OverTime Config Loaded", false);// no newline at the end
	CloseHandle(file);
	
	UpdateWarmUp(WM_VERSION);
}

static void UpdateWarmUp(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_warmup.cfg");

	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - WarmUp Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change WarmUp commands");
	WriteFileLine(file, "wm_warmup_respawn		\"1\"		//Enable or disable the respawning of players in warmup");
	WriteFileLine(file, "wm_block_warm_up_grenades		\"1\"	//Enable or disable grenade blocking in warmup");
	WriteFileLine(file, "mp_warmuptime		\"300\"		//How long the warmup period lasts. Changing this value resets warmup.");
	WriteFileLine(file, "mp_buytime		\"120\"		//How many seconds after round start players can buy items for.");
	WriteFileLine(file, "mp_freezetime		\"0\"		//How many seconds to keep players frozen when the round starts");
	WriteFileLine(file, "mp_autokick		\"0\"		//Kick idle/team-killing/team-damaging players");
	WriteFileLine(file, "mp_friendlyfire		\"0\"		//Allows team members to injure other members of their team");
	WriteFileLine(file, "mp_startmoney		\"16000\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_warmup_pausetimer		\"1\"		//Set to 1 to stay in warmup indefinitely. Set to 0 to resume the timer.");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "sv_infinite_ammo		\"0\"		//Player's active weapon will never run out of ammo.");
	WriteFileLine(file, "sv_showimpacts		\"0\"			//Shows client (red) and server (blue) bullet impact point");
	WriteFileLine(file, "sv_cheats			\"0\"			//Allow cheats on server");
	WriteFileLine(file, "mp_buy_anywhere		\"0\"		//When set, players can buy anywhere, not only in buyzones");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.92\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "mp_death_drop_defuser	\"0\"			// Drop defuser on player death");
	WriteFileLine(file, "mp_death_drop_grenade	\"0\"			// Which grenade to drop on player death: 0=none, 1=best, 2=current or best");
	WriteFileLine(file, "mp_death_drop_gun	\"0\"			// Which gun to drop on player death: 0=none, 1=best, 2=current or best");
	WriteFileLine(file, "wm_active			\"1\"		//Enable or disable WarMod as active");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] WarmUp Config Loaded", false); // no newline at the end
	CloseHandle(file);
	UpdatePractice(WM_VERSION);
}

static void UpdatePractice(char[] WM_VERSION)
{
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/practice.cfg");

	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Practice Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change WarmUp commands");
	WriteFileLine(file, "wm_warmup_respawn		\"0\"		//Enable or disable the respawning of players in warmup");
	WriteFileLine(file, "wm_block_warm_up_grenades		\"0\"	//Enable or disable grenade blocking in warmup");
	WriteFileLine(file, "mp_buytime		\"120\"		//How many seconds after round start players can buy items for.");
	WriteFileLine(file, "mp_freezetime		\"0\"		//How many seconds to keep players frozen when the round starts");
	WriteFileLine(file, "mp_autokick		\"0\"		//Kick idle/team-killing/team-damaging players");
	WriteFileLine(file, "mp_startmoney		\"16000\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "sv_infinite_ammo		\"2\"		//Player's active weapon will never run out of ammo.");
	WriteFileLine(file, "sv_showimpacts		\"2\"			//Shows client (red) and server (blue) bullet impact point");
	WriteFileLine(file, "sv_cheats			\"1\"			//Allow cheats on server");
	WriteFileLine(file, "mp_buy_anywhere		\"1\"		//When set, players can buy anywhere, not only in buyzones");
	WriteFileLine(file, "mp_roundtime_defuse		\"9999\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "bot_quota			\"0\"		//Determines the total number of bots in the game.");
	WriteFileLine(file, "wm_active			\"0\"		//Enable or disable WarMod as active");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Practice Config Loaded", false); // no newline at the end
	CloseHandle(file);
	UpdateRuleSet_Knife(WM_VERSION);
}

static void UpdateRuleSet_Knife(char[] WM_VERSION)
{
	ServerCommand("exec warmod/ruleset_knife.cfg");
	char cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_knife.cfg");
	
	DeleteFile(cfgFile);
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Knife Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change Knife commands");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_startmoney		\"0\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"60.00\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"60.00\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Knife Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
	
	UpdateOn_Map_Load(WM_VERSION);
}

static void UpdateOn_Map_Load(char[] WM_VERSION)
{
	ServerCommand("exec warmod/on_map_load.cfg");
	
	char cfgFile[PLATFORM_MAX_PATH];
	char convarString[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_map_load.cfg");
	DeleteFile(cfgFile);
	Handle file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - On Map Load Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// This config file is executed on every map change, including when the server first starts");
	WriteFileLine(file, "// Note: Plugins have been loaded by now");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Updater");
	WriteFileLine(file, "");
	if (LibraryExists("updater"))
	{
		WriteFileLine(file, "sm_updater 			\"%i\"		//Determines update functionality. (1 = Notify, 2 = Download, 3 = Include source code)", GetConVarInt(FindConVar("sm_updater")));
	}
	else
	{
		WriteFileLine(file, "sm_updater 			\"2\"		//Determines update functionality. (1 = Notify, 2 = Download, 3 = Include source code)");
	}
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Configs");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_warmod_safemode		\"%i\"		//This disables features that usually break on a CS:GO update", GetConVarInt(FindConVar("wm_warmod_safemode")));
	GetConVarString(FindConVar("wm_match_config"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_match_config			\"%s\"	//Sets the match config to load on Live on 3", convarString);
	GetConVarString(FindConVar("wm_default_config"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_default_config				\"%s\"	//Sets the default match config to load on Live on 3", convarString);
	GetConVarString(FindConVar("wm_overtime_config"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_overtime_config				\"%s\"	//Sets the overtime match config to load on Live on 3", convarString);
	GetConVarString(FindConVar("wm_playout_config"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_playout_config				\"%s\"	//Sets the play out match config to load on Live on 3", convarString);
	GetConVarString(FindConVar("wm_prac_config"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_prac_config				\"%s\"	//Loads when the practice command is called", convarString);
	GetConVarString(FindConVar("wm_reset_config"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_reset_config				\"%s\"	//Sets the config to load at the end/reset of a match", convarString);
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Stats");
	WriteFileLine(file, "");
	GetConVarString(FindConVar("wm_save_dir"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_save_dir			\"%s\"	//Directory to store SourceTV demos and WarMod logs", convarString);
	WriteFileLine(file, "wm_prefix_logs			\"%i\"		//Enable or disable the prefixing of \"_\" to uncompleted match SourceTV demos and WarMod logs", GetConVarInt(FindConVar("wm_prefix_logs")));
	WriteFileLine(file, "wm_stats_enabled			\"%i\"		//Enable or disable statistical logging", GetConVarInt(FindConVar("wm_stats_enabled")));
	WriteFileLine(file, "wm_stats_method			\"%i\"		//Sets the stats logging method: 0 = UDP stream/server logs, 1 = WarMod logs, 2 = both", GetConVarInt(FindConVar("wm_stats_method")));
	WriteFileLine(file, "wm_stats_trace			\"%i\"		//Enable or disable updating all player positions, every wm_stats_trace_delay seconds", GetConVarInt(FindConVar("wm_stats_trace")));
	WriteFileLine(file, "wm_stats_trace_delay		\"%i\"		//The ammount of time between sending player position updates", GetConVarInt(FindConVar("wm_stats_trace_delay")));
	GetConVarString(FindConVar("mp_teamname_1"), convarString, sizeof(convarString));
	WriteFileLine(file, "mp_teamname_1 			\"%s\"	//A non-empty string overrides the first team's name", convarString);
	GetConVarString(FindConVar("mp_teamname_2"), convarString, sizeof(convarString));
	WriteFileLine(file, "mp_teamname_2 			\"%s\"		//A non-empty string overrides the second team's name", convarString);
	GetConVarString(FindConVar("mp_teamlogo_1"), convarString, sizeof(convarString));
	WriteFileLine(file, "mp_teamlogo_1 			\"%s\"		//Enter a team's shorthand image name to display their logo", convarString);
	GetConVarString(FindConVar("mp_teamlogo_2"), convarString, sizeof(convarString));
	WriteFileLine(file, "mp_teamlogo_2 			\"%s\"		//Enter a team's shorthand image name to display their logo", convarString);
	GetConVarString(FindConVar("wm_competition"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_competition			\"%s\"	//Name of host for a competition. eg. ESEA, Cybergamer, CEVO, ESL", convarString);
	GetConVarString(FindConVar("wm_event"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_event			\"%s\"		//Name of event. eg. Season #, ODC #, Ladder", convarString);
	GetConVarString(FindConVar("wm_chat_prefix"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_chat_prefix			\"%s\"	//Change the chat prefix. Default is WarMod_BFG", convarString);
	WriteFileLine(file, "");
	if (LibraryExists("warmod_stats"))
	{
		WriteFileLine(file, "// Stats Site");
		WriteFileLine(file, "");
		GetConVarString(FindConVar("wm_site_location"), convarString, sizeof(convarString));
		WriteFileLine(file, "wm_site_location			\"%s\"		//Location of where the demo is uploaded for download. Do not have '/' at end of string. eg. www.warmod.com", convarString);
		GetConVarString(FindConVar("wm_site_data"), convarString, sizeof(convarString));
		WriteFileLine(file, "wm_site_data			\"%s\"		//Location of where the sites images, css and js files are. Do not have '/' at end of string. eg. warmod.bitbucket.org/stats", convarString);
		GetConVarString(FindConVar("wm_demo_location"), convarString, sizeof(convarString));
		WriteFileLine(file, "wm_demo_location			\"%s\"		//Location of where the demo is uploaded for download. eg. www.warmod.com/demos/", convarString);
		GetConVarString(FindConVar("wm_forums_location"), convarString, sizeof(convarString));
		WriteFileLine(file, "wm_forums_location			\"%s\"		//Location of where the community forums are. eg. www.warmod.com/forums/", convarString);
		WriteFileLine(file, "");
	}
	else
	{
		WriteFileLine(file, "// Stats Site");
		WriteFileLine(file, "");
		WriteFileLine(file, "wm_site_location			\"\"		//Location of where the stats site is uploaded for download. Do not have '/' at end of string. eg. www.warmod.com");
		WriteFileLine(file, "wm_site_data			\"warmod.bitbucket.org/stats\"		//Location of where the sites images, css and js files are. Do not have '/' at end of string. eg. warmod.bitbucket.org/stats");
		WriteFileLine(file, "wm_demo_location			\"\"		//Location of where the demo is uploaded for download. eg. www.warmod.com/demos/");
		WriteFileLine(file, "wm_forums_location			\"\"		//Location of where the community forums are. eg. www.warmod.com/forums/");
		WriteFileLine(file, "");
	}
	WriteFileLine(file, "// FTP Upload");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_upload_results						\"%i\"			//Enable or disable the uploading of match results via MySQL", GetConVarInt(FindConVar("wm_upload_results")));
	GetConVarString(FindConVar("wm_table_name"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_table_name							\"%s\"	//The MySQL table name to store match results in)", convarString);
	GetConVarString(FindConVar("wm_table_name_players"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_table_name_players							\"%s\"	//The MySQL table name to store match players in)", convarString);
	WriteFileLine(file, "");
	WriteFileLine(file, "// FTP Upload");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_autodemoupload_enable				\"%i\"			//Automatically upload demos when finished recording.", GetConVarInt(FindConVar("wm_autodemoupload_enable")));
	WriteFileLine(file, "wm_autodemoupload_bzip2				\"%i\"			//Compression level. If set > 0 demos will be compressed before uploading. (Requires bzip2 extension.)", GetConVarInt(FindConVar("wm_autodemoupload_bzip2")));
	WriteFileLine(file, "wm_autodemoupload_delete				\"%i\"			//Delete the demo (and the bz2) if upload was successful.", GetConVarInt(FindConVar("wm_autodemoupload_delete")));
	GetConVarString(FindConVar("wm_autodemoupload_ftptargetdemo"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_autodemoupload_ftptargetdemo			\"%s\"		//The ftp target to use for demo uploads.", convarString);
	GetConVarString(FindConVar("wm_autodemoupload_ftptargetlog"), convarString, sizeof(convarString));
	WriteFileLine(file, "wm_autodemoupload_ftptargetlog			\"%s\"		//The ftp target to use for log uploads.", convarString);
	if (LibraryExists("warmod_stats"))
	{
		GetConVarString(FindConVar("wm_autodemoupload_ftptargetstats"), convarString, sizeof(convarString));
		WriteFileLine(file, "wm_autodemoupload_ftptargetstats			\"%s\"		//The ftp target to use for stats site uploads.", convarString);
	}
	else
	{
		WriteFileLine(file, "wm_autodemoupload_ftptargetstats			\"stats\"		//The ftp target to use for stats site uploads");
	}
	WriteFileLine(file, "wm_autodemoupload_completed			\"%i\"			//Only upload demos when match is completed.", GetConVarInt(FindConVar("wm_autodemoupload_completed")));
	WriteFileLine(file, "");
	WriteFileLine(file, "// Voice Communications");
	WriteFileLine(file, "");
	if (LibraryExists("basecomm"))
	{
		WriteFileLine(file, "sm_deadtalk					\"%i\"			//Controls how dead communicate. 0 - Off. 1 - Dead players ignore teams. 2 - Dead players talk to living teammates.", GetConVarInt(FindConVar("sm_deadtalk")));
	}
	else
	{
		WriteFileLine(file, "sm_deadtalk					\"0\"			//Controls how dead communicate. 0 - Off. 1 - Dead players ignore teams. 2 - Dead players talk to living teammates.");
	}
	WriteFileLine(file, "");
	WriteFileLine(file, "exec warmod/ruleset_warmup.cfg", false);// no newline at the end
	CloseHandle(file);
}