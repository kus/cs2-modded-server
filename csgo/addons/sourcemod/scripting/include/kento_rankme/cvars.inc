ConVar g_cvarAnnounceAdmin;
ConVar g_cvarAnnounceConnect;
ConVar g_cvarAnnounceConnectChat;
ConVar g_cvarAnnounceConnectHint;
ConVar g_cvarAnnounceDisconnect;
ConVar g_cvarAnnounceTopConnect;
ConVar g_cvarAnnounceTopConnectChat;
ConVar g_cvarAnnounceTopConnectHint;
ConVar g_cvarAnnounceTopPosConnect;
ConVar g_cvarAutopurge;
ConVar g_cvarChatChange;
ConVar g_cvarChatTriggers;
ConVar g_cvarDaysToNotShowOnRank;
ConVar g_cvarDumpDB;
ConVar g_cvarEnabled;
ConVar g_cvarFfa;
ConVar g_cvarGatherStats;
ConVar g_cvarGatherStatsWarmup;
ConVar g_cvarMinimalKills;
ConVar g_cvarMinimumPlayers;
ConVar g_cvarMysql;
ConVar g_cvarNSAllSnipers;
ConVar g_cvarPercentPointsLose;
ConVar g_cvarPointsAssistKill;
ConVar g_cvarPointsBombDefusedPlayer;
ConVar g_cvarPointsBombDefusedTeam;
ConVar g_cvarPointsBombDropped;
ConVar g_cvarPointsBombExplodePlayer;
ConVar g_cvarPointsBombExplodeTeam;
ConVar g_cvarPointsBombPickup;
ConVar g_cvarPointsBombPlantedPlayer;
ConVar g_cvarPointsBombPlantedTeam;
ConVar g_cvarPointsCtRoundLose;
ConVar g_cvarPointsCtRoundWin;
ConVar g_cvarPointsFb;
ConVar g_cvarPointsHostageRescPlayer;
ConVar g_cvarPointsHostageRescTeam;
ConVar g_cvarPointsHs;
ConVar g_cvarPointsKillBonusCt;
ConVar g_cvarPointsKillBonusDifCt;
ConVar g_cvarPointsKillBonusDifTr;
ConVar g_cvarPointsKillBonusTr;
ConVar g_cvarPointsKillCt;
ConVar g_cvarPointsKillTr;
ConVar g_cvarPointsKnifeMultiplier;
ConVar g_cvarPointsLoseRoundCeil;
ConVar g_cvarPointsLoseSuicide;
ConVar g_cvarPointsLoseTk;
ConVar g_cvarPointsMatchDraw;
ConVar g_cvarPointsMatchLose;
ConVar g_cvarPointsMatchWin;
ConVar g_cvarPointsMin;
ConVar g_cvarPointsMinEnabled;
ConVar g_cvarPointsMvpCt;
ConVar g_cvarPointsMvpTr;
ConVar g_cvarPointsNS;
ConVar g_cvarPointsStart;
ConVar g_cvarPointsTaserMultiplier;
ConVar g_cvarPointsTrRoundLose;
ConVar g_cvarPointsTrRoundWin;
ConVar g_cvarPointsVipEscapedPlayer;
ConVar g_cvarPointsVipEscapedTeam;
ConVar g_cvarPointsVipKilledPlayer;
ConVar g_cvarPointsVipKilledTeam;
ConVar g_cvarRankAllTimer;
ConVar g_cvarRankBy;
ConVar g_cvarRankCache;
ConVar g_cvarRankMode;
ConVar g_cvarRankbots;
ConVar g_cvarResetOwnRank;
ConVar g_cvarSQLTable;
ConVar g_cvarShowBotsOnRank;
ConVar g_cvarShowRankAll;
ConVar g_cvarVipEnabled;

Handle g_arrayRankCache[3];
bool firstblood = false;
bool g_bAnnounceConnect;
bool g_bAnnounceConnectChat;
bool g_bAnnounceConnectHint;
bool g_bAnnounceDisconnect;
bool g_bAnnounceTopConnect;
bool g_bAnnounceTopConnectChat;
bool g_bAnnounceTopConnectHint;
bool g_bChatChange;
bool g_bChatTriggers;
bool g_bDumpDB;
bool g_bEnabled;
bool g_bFfa;
bool g_bGatherStats;
bool g_bGatherStatsWarmup;
bool g_bMysql;
bool g_bNSAllSnipers;
bool g_bPointsLoseRoundCeil;
bool g_bPointsMinEnabled;
bool g_bRankBots;
bool g_bRankCache;
bool g_bResetOwnRank;
bool g_bShowBotsOnRank;
bool g_bShowRankAll;
bool g_bVipEnabled;
char g_sAnnounceAdmin[AdminFlags_TOTAL];
char g_sBufferClientName[MAXPLAYERS+1][MAX_NAME_LENGTH];
float g_fPercentPointsLose;
float g_fPointsKnifeMultiplier;
float g_fPointsTaserMultiplier;
float g_fRankAllTimer;
int g_AnnounceTopPosConnect;
int g_DaysToNotShowOnRank;
int g_MinimalKills;
int g_MinimumPlayers;
int g_PointsAssistKill;
int g_PointsBombDefusedPlayer;
int g_PointsBombDefusedTeam;
int g_PointsBombDropped;
int g_PointsBombExplodePlayer;
int g_PointsBombExplodeTeam;
int g_PointsBombPickup;
int g_PointsBombPlantedPlayer;
int g_PointsBombPlantedTeam;
int g_PointsFb;
int g_PointsHostageRescPlayer;
int g_PointsHostageRescTeam;
int g_PointsHs;
int g_PointsKillBonusDif[4];
int g_PointsKillBonus[4];
int g_PointsKill[4];
int g_PointsLoseSuicide;
int g_PointsLoseTk;
int g_PointsMatchDraw;
int g_PointsMatchLose;
int g_PointsMatchWin;
int g_PointsMin;
int g_PointsMvpCt;
int g_PointsMvpTr;
int g_PointsNS;
int g_PointsRoundLose[4];
int g_PointsRoundWin[4];
int g_PointsStart;
int g_PointsVipEscapedPlayer;
int g_PointsVipEscapedTeam;
int g_PointsVipKilledPlayer;
int g_PointsVipKilledTeam;
int g_RankBy;
int g_RankMode;
int g_aPointsOnConnect[MAXPLAYERS+1];
int g_aPointsOnDisconnect[MAXPLAYERS+1];
int g_aRankOnConnect[MAXPLAYERS+1];

void CreateCvars()
{
	g_cvarEnabled = CreateConVar("rankme_enabled", "1", "Is RankMe enabled? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarRankbots = CreateConVar("rankme_rankbots", "0", "Rank bots? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarAutopurge = CreateConVar("rankme_autopurge", "0", "Auto-Purge inactive players? X = Days  0 = Off", _, true, 0.0);
	g_cvarPointsBombDefusedTeam = CreateConVar("rankme_points_bomb_defused_team", "2", "How many points CTs got for defusing the C4?", _, true, 0.0);
	g_cvarPointsBombDefusedPlayer = CreateConVar("rankme_points_bomb_defused_player", "2", "How many points the CT who defused got additional?", _, true, 0.0);
	g_cvarPointsBombPlantedTeam = CreateConVar("rankme_points_bomb_planted_team", "2", "How many points TRs got for planting the C4?", _, true, 0.0);
	g_cvarPointsBombPlantedPlayer = CreateConVar("rankme_points_bomb_planted_player", "2", "How many points the TR who planted got additional?", _, true, 0.0);
	g_cvarPointsBombExplodeTeam = CreateConVar("rankme_points_bomb_exploded_team", "2", "How many points TRs got for exploding the C4?", _, true, 0.0);
	g_cvarPointsBombExplodePlayer = CreateConVar("rankme_points_bomb_exploded_player", "2", "How many points the TR who planted got additional?", _, true, 0.0);
	g_cvarPointsHostageRescTeam = CreateConVar("rankme_points_hostage_rescued_team", "2", "How many points CTs got for rescuing the hostage?", _, true, 0.0);
	g_cvarPointsHostageRescPlayer = CreateConVar("rankme_points_hostage_rescued_player", "2", "How many points the CT who rescued got additional?", _, true, 0.0);
	g_cvarPointsHs = CreateConVar("rankme_points_hs", "1", "How many additional points a player got for a HeadShot?", _, true, 0.0);
	g_cvarPointsKillCt = CreateConVar("rankme_points_kill_ct", "2", "How many points a CT got for killing?", _, true, 0.0);
	g_cvarPointsKillTr = CreateConVar("rankme_points_kill_tr", "2", "How many points a TR got for killing?", _, true, 0.0);
	g_cvarPointsKillBonusCt = CreateConVar("rankme_points_kill_bonus_ct", "1", "How many points a CT got for killing additional by the diffrence of points?", _, true, 0.0);
	g_cvarPointsKillBonusTr = CreateConVar("rankme_points_kill_bonus_tr", "1", "How many points a TR got for killing additional by the diffrence of points?", _, true, 0.0);
	g_cvarPointsKillBonusDifCt = CreateConVar("rankme_points_kill_bonus_dif_ct", "100", "How many points of diffrence is needed for a CT to got the bonus?", _, true, 0.0);
	g_cvarPointsKillBonusDifTr = CreateConVar("rankme_points_kill_bonus_dif_tr", "100", "How many points of diffrence is needed for a TR to got the bonus?", _, true, 0.0);
	g_cvarPointsCtRoundWin = CreateConVar("rankme_points_ct_round_win", "0", "How many points CT got for winning the round?", _, true, 0.0);
	g_cvarPointsTrRoundWin = CreateConVar("rankme_points_tr_round_win", "0", "How many points TR got for winning the round?", _, true, 0.0);
	g_cvarPointsCtRoundLose = CreateConVar("rankme_points_ct_round_lose", "0", "How many points CT lost for losing the round?", _, true, 0.0);
	g_cvarPointsTrRoundLose = CreateConVar("rankme_points_tr_round_lose", "0", "How many points TR lost for losing the round?", _, true, 0.0);
	g_cvarPointsKnifeMultiplier = CreateConVar("rankme_points_knife_multiplier", "2.0", "Multiplier of points by knife", _, true, 0.0);
	g_cvarPointsTaserMultiplier = CreateConVar("rankme_points_taser_multiplier", "2.0", "Multiplier of points by taser", _, true, 0.0);
	g_cvarPointsStart = CreateConVar("rankme_points_start", "1000", "Starting points", _, true, 0.0);
	g_cvarMinimalKills = CreateConVar("rankme_minimal_kills", "0", "Minimal kills for entering the rank", _, true, 0.0);
	g_cvarPercentPointsLose = CreateConVar("rankme_percent_points_lose", "1.0", "Multiplier of losing points. (WARNING: MAKE SURE TO INPUT IT AS FLOAT) 1.0 equals lose same amount as won by the killer, 0.0 equals no lose", _, true, 0.0);
	g_cvarPointsLoseRoundCeil = CreateConVar("rankme_points_lose_round_ceil", "1", "If the points is f1oat, round it to next the highest or lowest? 1 = highest 0 = lowest", _, true, 0.0, true, 1.0);
	g_cvarChatChange = CreateConVar("rankme_changes_chat", "1", "Show points changes on chat? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarShowRankAll = CreateConVar("rankme_show_rank_all", "0", "When rank command is used, show for all the rank of the player? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarRankAllTimer = CreateConVar("rankme_rank_all_timer", "30.0", "Cooldown timer to prevent rank command spam.\n0.0 = disabled", _, true, 0.0);
	g_cvarShowBotsOnRank = CreateConVar("rankme_show_bots_on_rank", "0", "Show bots on rank/top/etc? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarResetOwnRank = CreateConVar("rankme_resetownrank", "0", "Allow player to reset his own rank? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarMinimumPlayers = CreateConVar("rankme_minimumplayers", "2", "Minimum players to start giving points", _, true, 0.0);
	g_cvarVipEnabled = CreateConVar("rankme_vip_enabled", "0", "Show AS_ maps statiscs (VIP mod) on statsme and session?", _, true, 0.0, true, 1.0);
	g_cvarPointsVipEscapedTeam = CreateConVar("rankme_points_vip_escaped_team", "2", "How many points CTs got helping the VIP to escaping?", _, true, 0.0);
	g_cvarPointsVipEscapedPlayer = CreateConVar("rankme_points_vip_escaped_player", "2", "How many points the VIP got for escaping?", _, true, 0.0);
	g_cvarPointsVipKilledTeam = CreateConVar("rankme_points_vip_killed_team", "2", "How many points TRs got for killing the VIP?", _, true, 0.0);
	g_cvarPointsVipKilledPlayer = CreateConVar("rankme_points_vip_killed_player", "2", "How many points the TR who killed the VIP got additional?", _, true, 0.0);
	g_cvarPointsLoseTk = CreateConVar("rankme_points_lose_tk", "0", "How many points a player lose for Team Killing?", _, true, 0.0);
	g_cvarPointsLoseSuicide = CreateConVar("rankme_points_lose_suicide", "0", "How many points a player lose for Suiciding?", _, true, 0.0);
	g_cvarPointsFb = CreateConVar("rankme_points_fb", "1", "How many additional points a player got for a First Blood?", _, true, 0.0);
	g_cvarPointsNS = CreateConVar("rankme_points_ns", "1", "How many additional points a player got for a no scope kill?", _, true, 0.0);	
	g_cvarNSAllSnipers = CreateConVar("rankme_points_ns_allsnipers", "0", "0: ssg08 and awp only, 1: ssg08, awp, g3sg1, scar20", _, true, 0.0, true, 1.0);	
	g_cvarRankBy = CreateConVar("rankme_rank_by", "0", "Rank players by? 0 = STEAM:ID 1 = Name 2 = IP", _, true, 0.0, true, 2.0);
	g_cvarFfa = CreateConVar("rankme_ffa", "0", "Free-For-All (FFA) mode? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarMysql = CreateConVar("rankme_mysql", "0", "Using MySQL? 1 = true 0 = false (SQLite)", _, true, 0.0, true, 1.0);
	g_cvarDumpDB = CreateConVar("rankme_dump_db", "0", "Dump the Database to SQL file? (required to be 1 if using the web interface and SQLite, case MySQL, it won't be dumped) 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarGatherStats = CreateConVar("rankme_gather_stats", "1", "Gather Statistics (a.k.a count points)? (turning this off won't disallow to see the stats already gathered) 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarDaysToNotShowOnRank = CreateConVar("rankme_days_to_not_show_on_rank", "0", "Days inactive to not be shown on rank? X = days 0 = off", _, true, 0.0);
	g_cvarRankMode = CreateConVar("rankme_rank_mode", "1", "Rank by what? 1 = by points 2 = by KDR ", _, true, 1.0, true, 2.0);
	g_cvarSQLTable = CreateConVar("rankme_sql_table", "rankme", "The name of the table that will be used. (Max: 100)");
	g_cvarChatTriggers = CreateConVar("rankme_chat_triggers", "1", "Enable (non-command) chat triggers. (e.g: rank, statsme, top) Recommended to be set to 0 when running with EventScripts for avoiding double responses. 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarPointsMvpCt = CreateConVar("rankme_points_mvp_ct", "1", "How many points a CT got for being the MVP?", _, true, 0.0);
	g_cvarPointsMvpTr = CreateConVar("rankme_points_mvp_tr", "1", "How many points a TR got for being the MVP?", _, true, 0.0);
	g_cvarPointsBombPickup = CreateConVar("rankme_points_bomb_pickup", "0", "How many points a player gets for picking up the bomb?", _, true, 0.0);
	g_cvarPointsBombDropped = CreateConVar("rankme_points_bomb_dropped", "0", "How many points a player loess for dropping the bomb?", _, true, 0.0);
	g_cvarPointsMatchWin = CreateConVar("rankme_points_match_win", "2", "How many points a player win for winning the match?", _, true, 0.0);
	g_cvarPointsMatchLose = CreateConVar("rankme_points_match_lose", "2", "How many points a player loess for losing the match?", _, true, 0.0);
	g_cvarPointsMatchDraw = CreateConVar("rankme_points_match_draw", "0", "How many points a player win when match draw?", _, true, 0.0);
	g_cvarPointsAssistKill = CreateConVar("rankme_points_assiist_kill","1","How many points a player gets for assist kill?",_,true,0.0);
	g_cvarGatherStatsWarmup = CreateConVar("rankme_gather_stats_warmup","1","Gather Statistics In Warmup?", _, true, 0.0, true, 1.0);
	g_cvarPointsMinEnabled = CreateConVar("rankme_points_min_enabled", "1", "Is minimum points enabled? 1 = true 0 = false", _, true, 0.0, true, 1.0);
	g_cvarPointsMin = CreateConVar("rankme_points_min", "0", "Minimum points", _, true, 0.0);
	g_cvarRankCache = CreateConVar("rankme_rank_cache", "0", "Get player rank via cache, auto build cache on every OnMapStart.", _, true, 0.0, true, 1.0);
	g_arrayRankCache[0] = CreateArray(ByteCountToCells(128));
	g_arrayRankCache[1] = CreateArray(ByteCountToCells(128));
	g_arrayRankCache[2] = CreateArray(ByteCountToCells(128));
	g_cvarAnnounceConnect = CreateConVar("rankme_announcer_player_connect","1","Announce when a player connect with position and points?",_,true,0.0,true,1.0);
	g_cvarAnnounceConnectChat = CreateConVar("rankme_announcer_player_connect_chat","1","Announce when a player connect at chat?",_,true,0.0,true,1.0);
	g_cvarAnnounceConnectHint = CreateConVar("rankme_announcer_player_connect_hint","0","Announce when a player connect at hintbox?",_,true,0.0,true,1.0);
	g_cvarAnnounceDisconnect = CreateConVar("rankme_announcer_player_disconnect","1","Announce when a player disconnect with position and points?",_,true,0.0,true,1.0);
	g_cvarAnnounceTopConnect = CreateConVar("rankme_announcer_top_player_connect","1","Announce when a top player connect?",_,true,0.0,true,1.0);
	g_cvarAnnounceTopPosConnect = CreateConVar("rankme_announcer_top_pos_player_connect","10","Max position to announce that a top player connect?",_,true,0.0);
	g_cvarAnnounceTopConnectChat = CreateConVar("rankme_announcer_top_player_connect_chat","1","Announce when a top player connect at chat?",_,true,0.0,true,1.0);
	g_cvarAnnounceTopConnectHint = CreateConVar("rankme_announcer_top_player_connect_hint","0","Announce when a top player connect at hintbox?",_,true,0.0,true,1.0);
	g_cvarAnnounceAdmin = CreateConVar("rankme_announcer_admin","","Admin flag to disable announce. blank = disabled");

	// CVAR HOOK
	g_cvarEnabled.AddChangeHook(OnConVarChanged);
	g_cvarChatChange.AddChangeHook(OnConVarChanged);
	g_cvarShowBotsOnRank.AddChangeHook(OnConVarChanged);
	g_cvarShowRankAll.AddChangeHook(OnConVarChanged);
	g_cvarRankAllTimer.AddChangeHook(OnConVarChanged);
	g_cvarResetOwnRank.AddChangeHook(OnConVarChanged);
	g_cvarMinimumPlayers.AddChangeHook(OnConVarChanged);
	g_cvarRankbots.AddChangeHook(OnConVarChanged);
	g_cvarAutopurge.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombDefusedTeam.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombDefusedPlayer.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombPlantedTeam.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombPlantedPlayer.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombExplodeTeam.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombExplodePlayer.AddChangeHook(OnConVarChanged);
	g_cvarPointsHostageRescTeam.AddChangeHook(OnConVarChanged);
	g_cvarPointsHostageRescPlayer.AddChangeHook(OnConVarChanged);
	g_cvarPointsHs.AddChangeHook(OnConVarChanged);
	g_cvarPointsKillCt.AddChangeHook(OnConVarChanged);
	g_cvarPointsKillTr.AddChangeHook(OnConVarChanged);
	g_cvarPointsKillBonusCt.AddChangeHook(OnConVarChanged);
	g_cvarPointsKillBonusTr.AddChangeHook(OnConVarChanged);
	g_cvarPointsKillBonusDifCt.AddChangeHook(OnConVarChanged);
	g_cvarPointsKillBonusDifTr.AddChangeHook(OnConVarChanged);
	g_cvarPointsCtRoundWin.AddChangeHook(OnConVarChanged);
	g_cvarPointsTrRoundWin.AddChangeHook(OnConVarChanged);
	g_cvarPointsCtRoundLose.AddChangeHook(OnConVarChanged);
	g_cvarPointsTrRoundLose.AddChangeHook(OnConVarChanged);
	g_cvarPointsKnifeMultiplier.AddChangeHook(OnConVarChanged);
	g_cvarPointsTaserMultiplier.AddChangeHook(OnConVarChanged);
	g_cvarPointsStart.AddChangeHook(OnConVarChanged);
	g_cvarMinimalKills.AddChangeHook(OnConVarChanged);
	g_cvarPercentPointsLose.AddChangeHook(OnConVarChanged);
	g_cvarPointsLoseRoundCeil.AddChangeHook(OnConVarChanged);
	g_cvarVipEnabled.AddChangeHook(OnConVarChanged);
	g_cvarPointsVipEscapedTeam.AddChangeHook(OnConVarChanged);
	g_cvarPointsVipEscapedPlayer.AddChangeHook(OnConVarChanged);
	g_cvarPointsVipKilledTeam.AddChangeHook(OnConVarChanged);
	g_cvarPointsVipKilledPlayer.AddChangeHook(OnConVarChanged);
	g_cvarPointsLoseTk.AddChangeHook(OnConVarChanged);
	g_cvarPointsLoseSuicide.AddChangeHook(OnConVarChanged);
	g_cvarRankBy.AddChangeHook(OnConVarChanged);
	g_cvarFfa.AddChangeHook(OnConVarChanged);
	g_cvarDumpDB.AddChangeHook(OnConVarChanged);
	g_cvarGatherStats.AddChangeHook(OnConVarChanged);
	g_cvarDaysToNotShowOnRank.AddChangeHook(OnConVarChanged);
	g_cvarRankMode.AddChangeHook(OnConVarChanged);
	g_cvarMysql.AddChangeHook(OnConVarChanged_MySQL);
	g_cvarSQLTable.AddChangeHook(OnConVarChanged_SQLTable);
	g_cvarChatTriggers.AddChangeHook(OnConVarChanged);
	g_cvarPointsMvpCt.AddChangeHook(OnConVarChanged);
	g_cvarPointsMvpTr.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombPickup.AddChangeHook(OnConVarChanged);
	g_cvarPointsBombDropped.AddChangeHook(OnConVarChanged);
	g_cvarPointsMatchWin.AddChangeHook(OnConVarChanged);
	g_cvarPointsMatchDraw.AddChangeHook(OnConVarChanged);
	g_cvarPointsMatchLose.AddChangeHook(OnConVarChanged);
	g_cvarPointsFb.AddChangeHook(OnConVarChanged);
	g_cvarPointsNS.AddChangeHook(OnConVarChanged);
	g_cvarNSAllSnipers.AddChangeHook(OnConVarChanged);
	g_cvarPointsAssistKill.AddChangeHook(OnConVarChanged);
	g_cvarGatherStatsWarmup.AddChangeHook(OnConVarChanged);
	g_cvarPointsMinEnabled.AddChangeHook(OnConVarChanged);
	g_cvarPointsMin.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceConnect.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceConnectChat.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceConnectHint.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceDisconnect.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceTopConnect.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceTopPosConnect.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceTopConnectChat.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceTopConnectHint.AddChangeHook(OnConVarChanged);
	g_cvarAnnounceAdmin.AddChangeHook(OnConVarChanged);
}

void GetCvarValues()
{
	g_bShowBotsOnRank = g_cvarShowBotsOnRank.BoolValue;
	g_RankBy = g_cvarRankBy.IntValue;
	g_bEnabled = g_cvarEnabled.BoolValue;
	g_bChatChange = g_cvarChatChange.BoolValue;
	g_bShowRankAll = g_cvarShowRankAll.BoolValue;
	g_fRankAllTimer = g_cvarRankAllTimer.FloatValue;
	g_bRankBots = g_cvarRankbots.BoolValue;
	g_bFfa = g_cvarFfa.BoolValue;
	g_bDumpDB = g_cvarDumpDB.BoolValue;
	g_PointsBombDefusedTeam = g_cvarPointsBombDefusedTeam.IntValue;
	g_PointsBombDefusedPlayer = g_cvarPointsBombDefusedPlayer.IntValue;
	g_PointsBombPlantedTeam = g_cvarPointsBombPlantedTeam.IntValue;
	g_PointsBombPlantedPlayer = g_cvarPointsBombPlantedPlayer.IntValue;
	g_PointsBombExplodeTeam = g_cvarPointsBombExplodeTeam.IntValue;
	g_PointsBombExplodePlayer = g_cvarPointsBombExplodePlayer.IntValue;
	g_PointsHostageRescTeam = g_cvarPointsHostageRescTeam.IntValue;
	g_PointsHostageRescPlayer = g_cvarPointsHostageRescPlayer.IntValue;
	g_PointsHs = g_cvarPointsHs.IntValue;
	g_PointsKill[CT] = g_cvarPointsKillCt.IntValue;
	g_PointsKill[TR] = g_cvarPointsKillTr.IntValue;
	g_PointsKillBonus[CT] = g_cvarPointsKillBonusCt.IntValue;
	g_PointsKillBonus[TR] = g_cvarPointsKillBonusTr.IntValue;
	g_PointsKillBonusDif[CT] = g_cvarPointsKillBonusDifCt.IntValue;
	g_PointsKillBonusDif[TR] = g_cvarPointsKillBonusDifTr.IntValue;
	g_PointsStart = g_cvarPointsStart.IntValue;
	g_fPointsKnifeMultiplier = g_cvarPointsKnifeMultiplier.FloatValue;
	g_fPointsTaserMultiplier = g_cvarPointsTaserMultiplier.FloatValue;
	g_PointsRoundWin[TR] = g_cvarPointsTrRoundWin.IntValue;
	g_PointsRoundWin[CT] = g_cvarPointsCtRoundWin.IntValue;
	g_PointsRoundLose[TR] = g_cvarPointsTrRoundLose.IntValue;
	g_PointsRoundLose[CT] = g_cvarPointsCtRoundLose.IntValue;
	g_MinimalKills = g_cvarMinimalKills.IntValue;
	g_fPercentPointsLose = g_cvarPercentPointsLose.FloatValue;
	g_bPointsLoseRoundCeil = g_cvarPointsLoseRoundCeil.BoolValue;
	g_MinimumPlayers = g_cvarMinimumPlayers.IntValue;
	g_bResetOwnRank = g_cvarResetOwnRank.BoolValue;
	g_PointsVipEscapedTeam = g_cvarPointsVipEscapedTeam.IntValue;
	g_PointsVipEscapedPlayer = g_cvarPointsVipEscapedPlayer.IntValue;
	g_PointsVipKilledTeam = g_cvarPointsVipKilledTeam.IntValue;
	g_PointsVipKilledPlayer = g_cvarPointsVipKilledPlayer.IntValue;
	g_bVipEnabled = g_cvarVipEnabled.BoolValue;
	g_PointsLoseTk = g_cvarPointsLoseTk.IntValue;
	g_PointsLoseSuicide = g_cvarPointsLoseSuicide.IntValue;
	g_DaysToNotShowOnRank = g_cvarDaysToNotShowOnRank.IntValue;
	g_bGatherStats = g_cvarGatherStats.BoolValue;
	g_RankMode = g_cvarRankMode.IntValue;
	g_bChatTriggers = g_cvarChatTriggers.BoolValue;
	g_PointsMvpCt = g_cvarPointsMvpCt.IntValue;
	g_PointsMvpTr = g_cvarPointsMvpTr.IntValue;
	g_PointsBombDropped = g_cvarPointsBombDropped.IntValue;
	g_PointsBombPickup = g_cvarPointsBombPickup.IntValue;
	g_PointsMatchWin = g_cvarPointsMatchWin.IntValue;
	g_PointsMatchDraw = g_cvarPointsMatchDraw.IntValue;
	g_PointsMatchLose = g_cvarPointsMatchLose.IntValue;
	g_PointsFb = g_cvarPointsFb.IntValue;
	g_PointsNS = g_cvarPointsNS.IntValue;
	g_bNSAllSnipers = g_cvarNSAllSnipers.BoolValue;
	
	/* Assist */
	g_PointsAssistKill = g_cvarPointsAssistKill.IntValue;
	
	/* Enable Or Disable Points In Warmup */
	g_bGatherStatsWarmup = g_cvarGatherStatsWarmup.BoolValue;
	
	/* Min points */
	g_PointsMin = g_cvarPointsMin.IntValue;
	g_bPointsMinEnabled = g_cvarPointsMin.BoolValue;
	
	/*RankMe Connect Announcer*/
	g_bAnnounceConnect = g_cvarAnnounceConnect.BoolValue;
	g_bAnnounceConnectChat = g_cvarAnnounceConnectChat.BoolValue;
	g_bAnnounceConnectHint = g_cvarAnnounceConnectHint.BoolValue;
	g_bAnnounceDisconnect = g_cvarAnnounceDisconnect.BoolValue;
	g_bAnnounceTopConnect = g_cvarAnnounceTopConnect.BoolValue;
	g_AnnounceTopPosConnect = g_cvarAnnounceTopPosConnect.BoolValue;
	g_bAnnounceTopConnectChat = g_cvarAnnounceTopConnectChat.BoolValue;
	g_bAnnounceTopConnectHint = g_cvarAnnounceTopConnectHint.BoolValue;
	g_cvarAnnounceAdmin.GetString(g_sAnnounceAdmin, sizeof(g_sAnnounceAdmin));
}

public void OnConVarChanged(Handle convar, const char[] oldValue, const char[] newValue) {
	int g_bQueryPlayerCount;
	
	if (convar == g_cvarShowBotsOnRank) {
		g_bShowBotsOnRank = g_cvarShowBotsOnRank.BoolValue;
		g_bQueryPlayerCount = true;
	}
	else if (convar == g_cvarRankBy) {
		g_RankBy = g_cvarRankBy.IntValue;
	}
	else if (convar == g_cvarEnabled) {
		g_bEnabled = g_cvarEnabled.BoolValue;
	}
	else if (convar == g_cvarShowRankAll) {
		g_bShowRankAll = g_cvarShowRankAll.BoolValue;
	}
	else if (convar == g_cvarRankAllTimer) {
		g_fRankAllTimer = g_cvarRankAllTimer.FloatValue;
	}
	else if (convar == g_cvarChatChange) {
		g_bChatChange = g_cvarChatChange.BoolValue;
	}
	else if (convar == g_cvarRankbots) {
		g_bRankBots = g_cvarRankbots.BoolValue;
		g_bQueryPlayerCount = true;
		if(g_hStatsDb != INVALID_HANDLE)	CheckUnique();
	}
	else if (convar == g_cvarFfa) {
		g_bFfa = g_cvarFfa.BoolValue;
	}
	else if (convar == g_cvarDumpDB) {
		g_bDumpDB = g_cvarDumpDB.BoolValue;
	}
	else if (convar == g_cvarPointsBombDefusedTeam) {
		g_PointsBombDefusedTeam = g_cvarPointsBombDefusedTeam.IntValue;
	}
	else if (convar == g_cvarPointsBombDefusedPlayer) {
		g_PointsBombDefusedPlayer = g_cvarPointsBombDefusedPlayer.IntValue;
	}
	else if (convar == g_cvarPointsBombPlantedTeam) {
		g_PointsBombPlantedTeam = g_cvarPointsBombPlantedTeam.IntValue;
	}
	else if (convar == g_cvarPointsBombPlantedPlayer) {
		g_PointsBombPlantedPlayer = g_cvarPointsBombPlantedPlayer.IntValue;
	}
	else if (convar == g_cvarPointsBombExplodeTeam) {
		g_PointsBombExplodeTeam = g_cvarPointsBombExplodeTeam.IntValue;
	}
	else if (convar == g_cvarPointsBombExplodePlayer) {
		g_PointsBombExplodePlayer = g_cvarPointsBombExplodePlayer.IntValue;
	}
	else if (convar == g_cvarPointsHostageRescTeam) {
		g_PointsHostageRescTeam = g_cvarPointsHostageRescTeam.IntValue;
	}
	else if (convar == g_cvarPointsHostageRescPlayer) {
		g_PointsHostageRescPlayer = g_cvarPointsHostageRescPlayer.IntValue;
	}
	else if (convar == g_cvarPointsHs) {
		g_PointsHs = g_cvarPointsHs.IntValue;
	}
	else if (convar == g_cvarPointsKillCt) {
		g_PointsKill[CT] = g_cvarPointsKillCt.IntValue;
	}
	else if (convar == g_cvarPointsKillTr) {
		g_PointsKill[TR] = g_cvarPointsKillTr.IntValue;
	}
	else if (convar == g_cvarPointsKillBonusCt) {
		g_PointsKillBonus[CT] = g_cvarPointsKillBonusCt.IntValue;
	}
	else if (convar == g_cvarPointsKillBonusTr) {
		g_PointsKillBonus[TR] = g_cvarPointsKillBonusTr.IntValue;
	}
	else if (convar == g_cvarPointsKillBonusDifCt) {
		g_PointsKillBonusDif[CT] = g_cvarPointsKillBonusDifCt.IntValue;
	}
	else if (convar == g_cvarPointsKillBonusDifTr) {
		g_PointsKillBonusDif[TR] = g_cvarPointsKillBonusDifTr.IntValue;
	}
	else if (convar == g_cvarPointsStart) {
		g_PointsStart = g_cvarPointsStart.IntValue;
	}
	else if (convar == g_cvarPointsKnifeMultiplier) {
		g_fPointsKnifeMultiplier = g_cvarPointsKnifeMultiplier.FloatValue;
	}
	else if (convar == g_cvarPointsTaserMultiplier) {
		g_fPointsTaserMultiplier = g_cvarPointsTaserMultiplier.FloatValue;
	}
	else if (convar == g_cvarPointsTrRoundWin) {
		g_PointsRoundWin[TR] = g_cvarPointsTrRoundWin.IntValue;
	}
	else if (convar == g_cvarPointsCtRoundWin) {
		g_PointsRoundWin[CT] = g_cvarPointsCtRoundWin.IntValue;
	}
	else if (convar == g_cvarPointsTrRoundLose) {
		g_PointsRoundLose[TR] = g_cvarPointsTrRoundLose.IntValue;
	}
	else if (convar == g_cvarPointsCtRoundLose) {
		g_PointsRoundLose[CT] = g_cvarPointsCtRoundLose.IntValue;
	}
	else if (convar == g_cvarMinimalKills) {
		g_MinimalKills = g_cvarMinimalKills.IntValue;
	}
	else if (convar == g_cvarPercentPointsLose) {
		g_fPercentPointsLose = g_cvarPercentPointsLose.FloatValue;
	}
	else if (convar == g_cvarPointsLoseRoundCeil) {
		g_bPointsLoseRoundCeil = g_cvarPointsLoseRoundCeil.BoolValue;
	}
	else if (convar == g_cvarMinimumPlayers) {
		g_MinimumPlayers = g_cvarMinimumPlayers.IntValue;
	}
	else if (convar == g_cvarResetOwnRank) {
		g_bResetOwnRank = g_cvarResetOwnRank.BoolValue;
	}
	else if (convar == g_cvarPointsVipEscapedTeam) {
		g_PointsVipEscapedTeam = g_cvarPointsVipEscapedTeam.IntValue;
	}
	else if (convar == g_cvarPointsVipEscapedPlayer) {
		g_PointsVipEscapedPlayer = g_cvarPointsVipEscapedPlayer.IntValue;
	}
	else if (convar == g_cvarPointsVipKilledTeam) {
		g_PointsVipKilledTeam = g_cvarPointsVipKilledTeam.IntValue;
	}
	else if (convar == g_cvarPointsVipKilledPlayer) {
		g_PointsVipKilledPlayer = g_cvarPointsVipKilledPlayer.IntValue;
	}
	else if (convar == g_cvarVipEnabled) {
		g_bVipEnabled = g_cvarVipEnabled.BoolValue;
	}
	else if (convar == g_cvarDaysToNotShowOnRank) {
		g_DaysToNotShowOnRank = g_cvarDaysToNotShowOnRank.IntValue;
		g_bQueryPlayerCount = true;
	}
	else if (convar == g_cvarGatherStats) {
		g_bGatherStats = g_cvarGatherStats.BoolValue;
	}
	else if (convar == g_cvarRankMode) {
		g_RankMode = g_cvarRankMode.IntValue;
		BuildRankCache();
	}
	else if (convar == g_cvarChatTriggers) {
		g_bChatTriggers = g_cvarChatTriggers.BoolValue;
	}
	else if (convar == g_cvarPointsMvpCt) {
		g_PointsMvpCt = g_cvarPointsMvpCt.IntValue;
	}
	else if (convar == g_cvarPointsMvpTr) {
		g_PointsMvpTr = g_cvarPointsMvpTr.IntValue;
	}
	else if (convar == g_cvarPointsBombPickup) {
		g_PointsBombDropped = g_cvarPointsBombPickup.IntValue;
	}
	else if (convar == g_cvarPointsBombDropped) {
		g_PointsBombDropped = g_cvarPointsBombDropped.IntValue;
	}
	
	/*RankMe Connect Announcer*/
	else if(convar == g_cvarAnnounceConnect) {
		g_bAnnounceConnect = g_cvarAnnounceConnect.BoolValue;
	}
	
	else if(convar == g_cvarAnnounceConnectChat) {
		g_bAnnounceConnectChat = g_cvarAnnounceConnectChat.BoolValue;
	}
	
	else if(convar == g_cvarAnnounceConnectHint) {
		g_bAnnounceConnectHint = g_cvarAnnounceConnectHint.BoolValue;
	}
	
	else if(convar == g_cvarAnnounceDisconnect) {
		g_bAnnounceDisconnect = g_cvarAnnounceDisconnect.BoolValue;
	}
	
	else if(convar == g_cvarAnnounceTopConnect) {
		g_bAnnounceTopConnect = g_cvarAnnounceTopConnect.BoolValue;
	}
	
	else if(convar == g_cvarAnnounceTopPosConnect) {
		g_AnnounceTopPosConnect = g_cvarAnnounceTopPosConnect.IntValue;
	}
	
	else if(convar == g_cvarAnnounceTopConnectChat) {
		g_bAnnounceTopConnectChat = g_cvarAnnounceTopConnectChat.BoolValue;
	}
	
	else if(convar == g_cvarAnnounceTopConnectHint) {
		g_bAnnounceTopConnectHint = g_cvarAnnounceTopConnectHint.BoolValue;
	}

	else if(convar == g_cvarAnnounceAdmin) {
		g_cvarAnnounceAdmin.GetString(g_sAnnounceAdmin, sizeof(g_sAnnounceAdmin));
	}
	
	/* Assist */
	else if (convar == g_cvarPointsAssistKill){
		g_PointsAssistKill = g_cvarPointsAssistKill.IntValue;
	}
	
	/* Enable Or Disable Points In Warmup */
	else if (convar == g_cvarGatherStatsWarmup){
		g_bGatherStatsWarmup = g_cvarGatherStatsWarmup.BoolValue;
	}
	
	/* Min points */
	else if (convar == g_cvarPointsMin){
		g_PointsMin = g_cvarPointsMin.IntValue;
	}
	
	else if (convar == g_cvarPointsMinEnabled){
		g_bPointsMinEnabled = g_cvarPointsMinEnabled.BoolValue;
	}
	
	/* Rank Cache */
	else if (convar == g_cvarRankCache) {
		g_bRankCache = g_cvarRankCache.BoolValue;
	}
	
	else if (convar == g_cvarPointsMatchWin) {
		g_PointsMatchWin = g_cvarPointsMatchWin.IntValue;
	}
	
	else if (convar == g_cvarPointsMatchDraw) {
		g_PointsMatchDraw = g_cvarPointsMatchDraw.IntValue;
	}
	
	else if (convar == g_cvarPointsMatchLose) {
		g_PointsMatchLose = g_cvarPointsMatchLose.IntValue;
	}
	
	else if (convar == g_cvarPointsFb) {
		g_PointsFb = g_cvarPointsFb.IntValue;
	}
	
	else if (convar == g_cvarPointsNS) {
		g_PointsNS = g_cvarPointsNS.IntValue;
	}
	
	else if (convar == g_cvarNSAllSnipers) {
		g_bNSAllSnipers = g_cvarNSAllSnipers.BoolValue;
	}
	
	if (g_bQueryPlayerCount && g_hStatsDb != INVALID_HANDLE) {
		char query[10000];
		MakeSelectQuery(query, sizeof(query));
		SQL_TQuery(g_hStatsDb, SQL_GetPlayersCallback, query);
	}
}