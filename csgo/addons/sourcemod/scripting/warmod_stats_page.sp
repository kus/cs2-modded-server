#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <warmod>
#undef REQUIRE_PLUGIN
#include <updater>
#include <tEasyFTP>

#pragma newdecls required

int match_stats[MAXPLAYERS + 1][MATCH_NUM];
int clutch_stats[MAXPLAYERS + 1][CLUTCH_NUM];
int round_stats[MAXPLAYERS + 1];
int round_health[MAXPLAYERS + 1];
char match_client_name[MAXPLAYERS + 1][64];
char match_client_steam2[MAXPLAYERS + 1][32];
char match_client_steam64[MAXPLAYERS + 1][18];

bool isLive = false;
char demoName[PLATFORM_MAX_PATH];

char g_t_name[64];
char g_ct_name[64];
int g_t_score;
int g_ct_score;

/* miscellaneous */
char g_map[64];
char date[32];
char startHour[4];
char startMin[4];
char endHour[4];
char endMin[4];

bool WasClientInGameAtAll[MAXPLAYERS + 1] = false;
bool WasClientInGame[MAXPLAYERS + 1] = false;
int WasClientTeam[MAXPLAYERS + 1] = 0;


ConVar wm_site_enabled;
ConVar wm_forums_location;
ConVar wm_site_data;
ConVar wm_site_location;
ConVar wm_demo_location;
ConVar wm_autodemoupload_ftptargetstats;
char g_ftp_target[255];
bool g_MODT_popup = false;

/* Plugin info */
#define UPDATE_URL				"http://warmod.bitbucket.org/warmod_stats.txt"
#define WM_VERSION				"0.5"
#define WM_DESCRIPTION			"Statistics page maker for Warmod [BFG]"

public Plugin myinfo = {
	name = "[BFG] WarMod Statistics Page Maker",
	author = "Versatile_BFG",
	description = WM_DESCRIPTION,
	version = WM_VERSION,
	url = "www.sourcemod.net"
};

public  APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("EasyFTP_UploadFile");
	RegPluginLibrary("warmod_stats");
	return APLRes_Success;
}

public void OnPluginStart()
{
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}

	wm_site_enabled = CreateConVar("wm_site_enabled", "1", "Enable or Disable the plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	wm_site_location = CreateConVar("wm_site_location", "", "Location of where the site is uploaded for download. Do not have '/' at end of string. eg. www.warmod.com", FCVAR_PLUGIN);
	wm_site_data = CreateConVar("wm_site_data", "warmod.bitbucket.org/stats", "Location of where the sites images, css and js files are. Do not have '/' at end of string. eg. warmod.bitbucket.org/stats", FCVAR_PLUGIN);
	wm_demo_location = CreateConVar("wm_demo_location", "", "Location of where the demo is uploaded for download. eg. www.warmod.com/demos/", FCVAR_PLUGIN);
	wm_forums_location = CreateConVar("wm_forums_location", "pacifices.net", "Location of where the community forums are. eg. www.warmod.com/forums/", FCVAR_PLUGIN);
	wm_autodemoupload_ftptargetstats = CreateConVar("wm_autodemoupload_ftptargetstats", "stats", "The ftp target to use for stats site uploads.", FCVAR_PLUGIN);
	
	AddCommandListener(Tv_Record, "tv_record");
	
	HookConVarChange(wm_site_enabled, OnActiveChange);
	
	HookEvent("round_start", Event_Round_Start);
	HookEvent("round_end", Event_Round_End);
	HookConVarChange(FindConVar("mp_restartgame"), Event_Round_Restart);
	HookEvent("player_spawned", Event_Player_Spawned);
	HookEvent("player_hurt",  Event_Player_Hurt);
	HookEvent("player_death",  Event_Player_Death);
	HookEvent("weapon_fire", Event_Weapon_Fire);
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public void Updater_OnPluginUpdated()
{
	ReloadPlugin();
}

public void OnActiveChange(Handle cvar, const char[] oldVal, const char[] intVal)
{
	if(!GetConVarBool(wm_site_enabled))
	{
		CreateTimer(5.0, ResetMatch);
	}
}

public void OnLiveOn3()
{
	if(GetConVarBool(wm_site_enabled))
	{
		char g_MapName[64];
		char g_WorkShopID[64];
		char g_CurMap[128];
		GetCurrentMap(g_CurMap, sizeof(g_CurMap));
		if (StrContains(g_CurMap, "workshop", false) != -1)
		{
			GetCurrentWorkshopMap(g_MapName, sizeof(g_MapName), g_WorkShopID, sizeof(g_WorkShopID));
		}
		else
		{
			strcopy(g_map, sizeof(g_map), g_CurMap);
		}
		
		FormatTime(date, sizeof(date), "%Y-%m-%d");
		FormatTime(startHour, sizeof(startHour), "%H");
		FormatTime(startMin, sizeof(startMin), "%M");
		isLive = true;
	}
}

public void OnEndMatch(const char[] ct_name, int ct_score, int t_score, const char[] t_name)
{
	if(GetConVarBool(wm_site_enabled))
	{
		Format(g_ct_name, sizeof(g_ct_name), ct_name);
		Format(g_t_name, sizeof(g_t_name), t_name);
		g_ct_score = ct_score;
		g_t_score = t_score;
		CreateTimer(3.0, MatchStatsHTML);
	}
}

public void OnResetMatch()
{
	CreateTimer(5.0, ResetMatch);
}

public Action ResetMatch(Handle timer)
{
	isLive = false;
	ResetClutchStats();
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		round_stats[i] = 0;
		round_health[i] = 100;
		WasClientInGameAtAll[i] = false;
		WasClientTeam[i] = 0;
		for (int y = 0; y < MATCH_NUM; y++)
		{
			match_stats[i][y] = 0;
		}
	}
}

public Action Tv_Record (int client, const char[] command, int argc)
{
	GetCmdArg(1, demoName, sizeof(demoName));
	char save_dir[128];
	GetConVarString(FindConVar("wm_save_dir"), save_dir, sizeof(save_dir));
	if(!StrEqual(save_dir, ""))
	{
		ReplaceString(demoName, sizeof(demoName), save_dir, "");
		ReplaceString(demoName, sizeof(demoName), "/", "");
	}
	PrintToChatAll("%s", demoName);
}

public void Event_Round_Start(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			WasClientInGame[i] = true;
			WasClientInGameAtAll[i] = true;
			if (GetClientTeam(i) > 1)
			{
				WasClientTeam[i] = GetClientTeam(i);
			}
			GetClientName(i, match_client_name[i], sizeof(match_client_name[]));
			GetClientAuthId(i, AuthId_Steam2, match_client_steam2[i], sizeof(match_client_steam2[]));
			GetClientAuthId(i, AuthId_SteamID64, match_client_steam64[i], sizeof(match_client_steam64[]));
		}
		round_stats[i] = 0;
		round_health[i] = 100;
	}
	ResetClutchStats();
}

public void Event_Round_End(Handle event, const char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	int reason = GetEventInt(event, "reason");
	
	// stats
	if (reason != 15 && reason != 9)
	{
		if (isLive && !InWarmup())
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) == winner && clutch_stats[i][CLUTCH_LAST] == 1)
				{
					clutch_stats[i][CLUTCH_WON] = 1;
					match_stats[i][MATCH_WON]++;
				}
				LogPlayerStats(i);
				LogClutchStats(i);
				WasClientInGame[i] = false;
			}
		}
	}
}

public void Event_Round_Restart(Handle cvar, const char[] oldVal, const char[] intVal)
{
	// stats
	if (isLive && !InWarmup())
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			round_stats[i] = 0;
			round_health[i] = 100;
			for (int z = 0; z < CLUTCH_NUM; z++)
			{
				clutch_stats[i][z] = 0;
			}
			for (int y = 0; y < MATCH_NUM; y++)
			{
				match_stats[i][y] = 0;
			}
			Format(match_client_name[i], sizeof(match_client_name[]), "");
			Format(match_client_steam2[i], sizeof(match_client_steam2[]), "");
			Format(match_client_steam64[i], sizeof(match_client_steam64[]), "");
		}
	}
}

public void Event_Player_Spawned(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	WasClientInGame[client] = true;
	WasClientInGameAtAll[client] = true;
	WasClientTeam[client] = GetClientTeam(client);
	GetClientName(client, match_client_name[client], sizeof(match_client_name[]));
	GetClientAuthId(client, AuthId_Steam2, match_client_steam2[client], sizeof(match_client_steam2[]));
	GetClientAuthId(client, AuthId_SteamID64, match_client_steam64[client], sizeof(match_client_steam64[]));
}

public void Event_Player_Hurt(Handle event, const char[] name, bool dontBroadcast)
{
	// stats
	if (isLive && !InWarmup())
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
		int damage = GetEventInt(event, "dmg_health");
		int vHealth = GetEventInt(event, "health");
		
		if (attacker > 0 && GetClientTeam(attacker) != GetClientTeam(victim))
		{
			match_stats[attacker][MATCH_HITS]++;
			if (vHealth == 0)
			{
				match_stats[attacker][MATCH_DAMAGE] += round_health[victim];
			}
			else
			{
				match_stats[attacker][MATCH_DAMAGE] += damage;
			}
		}
		round_health[victim] = vHealth;
	}
}

public void Event_Player_Death(Handle event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int assister = GetClientOfUserId(GetEventInt(event, "assister"));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	bool headshot = GetEventBool(event, "headshot");
	char weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	
	// stats
	if (isLive && !InWarmup())
	{
		if (attacker > 0 && victim > 0 && attacker != victim)
		{
			// normal frag
			if (GetClientTeam(attacker) == GetClientTeam(victim))
			{
				match_stats[attacker][MATCH_TEAMKILLS]++;
			}
			else
			{
				match_stats[attacker][MATCH_KILLS]++;
				round_stats[attacker]++;
			}
			match_stats[victim][MATCH_DEATHS]++;
			
			if (headshot)
			{
				match_stats[attacker][MATCH_HEADSHOTS]++;
			}
		}
		else if (victim > 0 && victim == attacker || StrEqual(weapon, "worldspawn"))
		{
			// suicide
			match_stats[victim][MATCH_DEATHS]++;
		}
		
		if (victim > 0)
		{
			// record weapon stats
			if (attacker > 0)
			{
				int attacker_team = GetClientTeam(attacker);
				int victim_team = GetClientTeam(victim);
				int victim_num_alive = GetNumAlive(victim_team);
				int attacker_num_alive = GetNumAlive(attacker_team);
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
		}
		
		if (assister > 0)
		{
			if (GetClientTeam(assister) == GetClientTeam(victim))
			{
				match_stats[assister][MATCH_ATA]++;
			}
			else
			{
				match_stats[assister][MATCH_ASSIST]++;
			}
		}
	}
}

public void Event_Weapon_Fire(Handle event, const char[] name, bool dontBroadcast)
{
	// stats
	if (isLive && !InWarmup())
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (client > 0)
		{
			match_stats[client][MATCH_SHOTS]++;
		}
	}
}

void LogPlayerStats(int client)
{
	if (WasClientInGame[client] && WasClientTeam[client] > 1)
	{
		match_stats[client][MATCH_ROUND]++;
		if (round_stats[client] == 1)
		{
			match_stats[client][MATCH_1K]++;
		}
		else if (round_stats[client] == 2)
		{
			match_stats[client][MATCH_2K]++;
		}
		else if (round_stats[client] == 3)
		{
			match_stats[client][MATCH_3K]++;
		}
		else if (round_stats[client] == 4)
		{
			match_stats[client][MATCH_4K]++;
		}
		else if (round_stats[client] == 5)
		{
			match_stats[client][MATCH_5K]++;
		}
	}
}

void LogClutchStats(int client)
{
	if (WasClientInGame[client] && WasClientTeam[client] > 1)
	{
		if (clutch_stats[client][CLUTCH_LAST] == 1)
		{
			match_stats[client][MATCH_LAST]++;
		}
	}
}

void ResetClutchStats()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		for (int z = 0; z < CLUTCH_NUM; z++)
		{
			clutch_stats[i][z] = 0;
		}
	}
}

public Action MatchStatsHTML(Handle timer)
{
	int Kills;	int Deaths; int Assists; int HeadShots; int TeamKills; int AssistsTeamAttack; int Damage; int Hits; int Shots; int k1; int k2; int k3; int k4; int k5; int LastAlive; int ClutchesWon;
	int TKills; int TDeaths; int TAssists; int THeadShots; int TTeamKills; int TAssistsTeamAttack; int TDamage; int THits; int TShots; int Tk1; int Tk2; int Tk3; int Tk4; int Tk5;
	float KDR; float KPR; float DPR; float HS; float AC; float CW; float LA; float TKDR; float TKPR; float TDPR; float THS; float TAC;
	char player_name[64];
	char authid[32];
	char auth_id64[18];
	char siteLocation[PLATFORM_MAX_PATH];
	char siteDataLocation[PLATFORM_MAX_PATH];
	GetConVarString(wm_site_data, siteDataLocation, sizeof(siteDataLocation));
	GetConVarString(wm_site_location, siteLocation, sizeof(siteLocation));
	int rounds = g_t_score + g_ct_score;
	
	// HLTV Rating Calculation Averages //
	int players = 0; int Survival = 0;
	float AverageKPR; float AverageSPR; float AverageRMK; float KillRating; float SurvivalRating; float RoundsWithMultipleKillsRating; float MultiKills; float HLTVRating;

	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (WasClientInGameAtAll[i] && (WasClientTeam[i] == CS_TEAM_T || WasClientTeam[i] == CS_TEAM_CT))
		{
			if (match_stats[i][MATCH_ROUND] > rounds)
			{
				match_stats[i][MATCH_ROUND] = rounds;
			}
			TKills += match_stats[i][MATCH_KILLS];
			TDeaths += match_stats[i][MATCH_DEATHS];
			TAssists += match_stats[i][MATCH_ASSIST];
			THeadShots += match_stats[i][MATCH_HEADSHOTS];
			TTeamKills += match_stats[i][MATCH_TEAMKILLS];
			TAssistsTeamAttack += match_stats[i][MATCH_ATA];
			TDamage += match_stats[i][MATCH_DAMAGE];
			Tk1 += match_stats[i][MATCH_1K];
			Tk2 += match_stats[i][MATCH_2K];
			Tk3 += match_stats[i][MATCH_3K];
			Tk4 += match_stats[i][MATCH_4K];
			Tk5 += match_stats[i][MATCH_5K];
			THits += match_stats[i][MATCH_HITS];
			TShots += match_stats[i][MATCH_SHOTS];
			players++;
			Survival += (match_stats[i][MATCH_ROUND] - match_stats[i][MATCH_DEATHS]);
			TKDR = FloatAdd(TKDR, FloatDiv(float(match_stats[i][MATCH_KILLS]), float(match_stats[i][MATCH_ROUND])));
		}
	}
	
	MultiKills = FloatAdd(float(Tk1), float((4*Tk2) + (9*Tk3) + (16*Tk4) + (25*Tk5)));
	
	AverageKPR = FloatDiv(TKDR, float(players));
	AverageSPR = FloatDiv(FloatDiv(float(Survival), float(players)), float(rounds));
	AverageRMK = FloatDiv(MultiKills, float(rounds));
	// End Prep //
	
	if (StrContains(siteDataLocation, "http", false) == -1)
	{
		Format(siteDataLocation, sizeof(siteDataLocation), "http://%s", siteDataLocation);
	}
	
	if (StrContains(siteDataLocation, "http", false) == -1)
	{
		Format(siteDataLocation, sizeof(siteDataLocation), "http://%s", siteDataLocation);
	}
	
	if (StrContains(siteLocation, "http", false) == -1)
	{
		Format(siteLocation, sizeof(siteLocation), "http://%s", siteLocation);
	}
	
	char MatchStatsFile[PLATFORM_MAX_PATH];
	Format(MatchStatsFile, sizeof(MatchStatsFile), "%s.html", demoName);
	ReplaceString(MatchStatsFile, sizeof(MatchStatsFile), ".dem.", ".", false);
	ReplaceString(MatchStatsFile, sizeof(MatchStatsFile), "..", ".", false);
	DeleteFile(MatchStatsFile);
	
	Handle htmlfile = OpenFile(MatchStatsFile, "w");
	WriteFileLine(htmlfile, "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">");
	WriteFileLine(htmlfile, "<html>");
	WriteFileLine(htmlfile, "<head>");
	WriteFileLine(htmlfile, "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\">");
	WriteFileLine(htmlfile, "<title>WarMod_BFG - %s vs %s</title>", g_t_name, g_ct_name);
	WriteFileLine(htmlfile, "<link rel=\"shortcut icon\" href=\"%s/img/favicon.ico\">", siteDataLocation);
	WriteFileLine(htmlfile, "<LINK href=\"%s/css/layout.css\" rel=\"stylesheet\" type=\"text/css\">", siteDataLocation);
	WriteFileLine(htmlfile, "<script type=\"text/javascript\" src=\"%s/js/sorttable.js\"></script>", siteDataLocation);
	WriteFileLine(htmlfile, "</head>");
	WriteFileLine(htmlfile, "<body>");
	WriteFileLine(htmlfile, "<div id=\"stats\">");
	WriteFileLine(htmlfile, "<div id=\"header\">");
	WriteFileLine(htmlfile, "<div id=\"headerContent\">");
	WriteFileLine(htmlfile, "<div class=\"headerdisplay\">");
	WriteFileLine(htmlfile, "<div id=\"logo\">");
	WriteFileLine(htmlfile, "<a href=\"%s/\" title=\"Go to community index\" rel=\"home\" accesskey=\"1\" class=\\'left\\'><img src=\"%s/img/WarMod_BFG_logo.png\"></a>", siteLocation, siteDataLocation);
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "<div id=\"primary_nav\" class=\"clearfix\">");
	WriteFileLine(htmlfile, "<ul class=\"ipsList_inline\" id=\"community_app_menu\">");
	char g_forums[PLATFORM_MAX_PATH];
	GetConVarString(wm_forums_location, g_forums, sizeof(g_forums));
	if (StrContains(g_forums, "http", false) == -1)
	{
		Format(g_forums, sizeof(g_forums), "http://%s", g_forums);
	}
	WriteFileLine(htmlfile, "<li id=\"nav_app_forums\" class=\"left\"><a href=\"%s\" title=\"Community Forums\">Forums</a></li>", g_forums);
	WriteFileLine(htmlfile, "<li id=\"nav_menu_4\" class=\"left\"><a href=\"%s\" title=\"Statistics and GOTV\">More Matches</a></li>", siteLocation);
	WriteFileLine(htmlfile, "</ul>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "<div id=\"base\">");
	WriteFileLine(htmlfile, "<div id=\"main\" class=\"clearfix\">");
	WriteFileLine(htmlfile, "<div style=\"width:100%%;margin:0;padding:0;border:none;\">");
	WriteFileLine(htmlfile, "<br>");
	WriteFileLine(htmlfile, "<div style=\"float left;width:30%%;\">");
	WriteFileLine(htmlfile, "<table style=\"width: 100%%\">");
	WriteFileLine(htmlfile, "<tbody>");
	WriteFileLine(htmlfile, "<tr class=\"heading\">");
	WriteFileLine(htmlfile, "<th>Summary:</th>");
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	char g_competition[255]; char g_event[255];
	GetConVarString(FindConVar("wm_competition"),g_competition, sizeof(g_competition));
	GetConVarString(FindConVar("wm_event"),g_event, sizeof(g_event));
	WriteFileLine(htmlfile, "<td>Competition: %s : %s</td>", g_competition, g_event);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	WriteFileLine(htmlfile, "<td>Match: %s vs %s</td>", g_ct_name, g_t_name);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	char g_server[255];
	GetConVarString(FindConVar("hostname"), g_server, sizeof(g_server));
	WriteFileLine(htmlfile, "<td>Server: %s</td>", g_server);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	char g_warmod_version[255];
	GetConVarString(FindConVar("wm_version_notify"), g_warmod_version, sizeof(g_warmod_version));
	WriteFileLine(htmlfile, "<td>Warmod version: %s</td>", g_warmod_version);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	WriteFileLine(htmlfile, "<td>Map: %s</td>", g_map);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	WriteFileLine(htmlfile, "<td>Date: %s</td>", date);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	WriteFileLine(htmlfile, "<td>Start Time: %s:%s</td>", startHour, startMin);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	FormatTime(endHour, sizeof(endHour), "%H");
	FormatTime(endMin, sizeof(endMin), "%M");
	int currentHours = StringToInt(endHour);
	int currentMinutes = StringToInt(endMin);
	int keyValueHours = StringToInt(startHour);
	int keyValueMinutes = StringToInt(startMin);
	int timeDifference = ((currentHours*3600)+(currentMinutes*60))-((keyValueHours*3600)+(keyValueMinutes*60));
	int length;
	if (timeDifference >= 0)
	{
		length = timeDifference / 60;
	}
	else
	{
		length = (timeDifference + 86400) / 60;
	}
	WriteFileLine(htmlfile, "<td>Length: %i minutes</td>", length);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	if (GetConVarBool(FindConVar("mp_overtime_enable")))
	{
		WriteFileLine(htmlfile, "<td>Format: MR%d with MR%d Overtime</td>", (GetConVarInt(FindConVar("mp_maxrounds"))/2), (GetConVarInt(FindConVar("mp_overtime_maxrounds"))/2));
	}
	else
	{
		WriteFileLine(htmlfile, "<td>Format: MR%d</td>", (GetConVarInt(FindConVar("mp_maxrounds"))/2));
	}
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	WriteFileLine(htmlfile, "<td>Rounds: %i</td>", rounds);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	char demoLocation[PLATFORM_MAX_PATH];
	int g_iBzip2 = GetConVarInt(FindConVar("wm_autodemoupload_bzip2"));
	if(LibraryExists("zip"))
	{
	Format(demoName, sizeof(demoName), "%s.zip", demoName);
	ReplaceString(demoName, sizeof(demoName), ".dem.", ".", false);
	ReplaceString(demoName, sizeof(demoName), "..", ".", false);
	}
	else if(g_iBzip2 > 0 && g_iBzip2 < 10 && LibraryExists("bzip2"))
	{
		Format(demoName, sizeof(demoName), "%s.bz2", demoName);
	}

	GetConVarString(wm_demo_location, demoLocation, sizeof(demoLocation));
	WriteFileLine(htmlfile, "<td>GOTV Demo: <a href=\"http://%s%s\" target=\"_blank\"><b>Download</b></a></td>", demoLocation, demoName);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "</tbody></table>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "<div style=\"float right; width:65%%\">");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "<table class=\"score\"><tbody><tr>");
	int ct_team; int t_team;
	char ct_name[64]; char t_name[64]; char teamname_1[PLATFORM_MAX_PATH];
	GetConVarString(FindConVar("mp_teamname_1"),teamname_1, sizeof(teamname_1));
	char ct_logo[12]; char t_logo[12];
	GetConVarString(FindConVar("mp_teamlogo_1"), ct_logo, sizeof(ct_logo));
	GetConVarString(FindConVar("mp_teamlogo_2"),t_logo, sizeof(t_logo));
	
	if ((StrEqual(teamname_1, g_ct_name, false)) || (StrEqual(teamname_1, "")))
	{
		if ((StrEqual(ct_logo, "")) || (StrEqual(t_logo, "")))
		{
			WriteFileLine(htmlfile, "<th class=\"blue\" style=\"width: 50%%\"><h1 class=\"left\">%s</h1><h1 class=\"right\">%i</h1></th>", g_ct_name, g_ct_score);
			WriteFileLine(htmlfile, "<th><h1>VS</h1></th>");
			WriteFileLine(htmlfile, "<th class=\"red\" style=\"width: 50%%\"><h1 class=\"left\">%i</h1><h1 class=\"right\">%s</h1>", g_t_score, g_t_name);
		}
		else
		{
			WriteFileLine(htmlfile, "<th><img src=\"%s/img/teams/%s.png\" alt=\"%s\"></th><th class=\"blue\" style=\"width: 50%%\"><h1 class=\"left\">%s</h1><h1 class=\"right\">%i</h1></th>", siteDataLocation, ct_logo, g_ct_name, g_ct_name, g_ct_score);
			WriteFileLine(htmlfile, "<th><h1>VS</h1></th>");
			WriteFileLine(htmlfile, "<th class=\"red\" style=\"width: 50%%\"><h1 class=\"left\">%i</h1><h1 class=\"right\">%s</h1></th><th><img src=\"%s/img/teams/%s.png\" alt=\"%s\">", g_t_score, g_t_name, siteDataLocation, t_logo, g_t_name);
		}
		ct_team = 3;
		t_team = 2;
		Format(ct_name, sizeof(ct_name), g_ct_name);
		Format(t_name, sizeof(t_name), g_t_name);
	}
	else
	{
		if ((StrEqual(ct_logo, "")) || (StrEqual(t_logo, "")))
		{
			WriteFileLine(htmlfile, "<th class=\"blue\" style=\"width: 50%%\"><h1 class=\"left\">%s</h1><h1 class=\"right\">%i</h1></td>", g_t_name, g_t_score);
			WriteFileLine(htmlfile, "<th><h1>VS</h1></th>");
			WriteFileLine(htmlfile, "<th class=\"red\" style=\"width: 50%%\"><h1 class=\"left\">%i</h1><h1 class=\"right\">%s</h1>", g_ct_score, g_ct_name);
		}
		else
		{
			WriteFileLine(htmlfile, "<th><img src=\"%s/img/teams/%s.png\" alt=\"%s\"></th><th class=\"blue\" style=\"width: 50%%\"><h1 class=\"left\">%s</h1><h1 class=\"right\">%i</h1></th>", siteDataLocation, ct_logo, g_t_name, g_t_name, g_t_score);
			WriteFileLine(htmlfile, "<th><h1>VS</h1></th>");
			WriteFileLine(htmlfile, "<th class=\"red\" style=\"width: 50%%\"><h1 class=\"left\">%i</h1><h1 class=\"right\">%s</h1></th><th><img src=\"%s/img/teams/%s.png\" alt=\"%s\">", g_ct_score, g_ct_name, siteDataLocation, t_logo, g_ct_name);
		}
		ct_team = 2;
		t_team = 3;
		Format(ct_name, sizeof(ct_name), g_t_name);
		Format(t_name, sizeof(t_name), g_ct_name);
	}
	WriteFileLine(htmlfile, "</th></tr></tbody></table>");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "<table>");
	WriteFileLine(htmlfile, "<tbody>");
	WriteFileLine(htmlfile, "<tr>");
	WriteFileLine(htmlfile, "<td align=\"middle\"><img src=\"%s/img/maps/%s.png\" alt=\"%s\"></td>", siteDataLocation, g_map, g_map);
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "</tbody></table>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
// Team Stats
	WriteFileLine(htmlfile, "<br style=\"clear:both;\">");
	WriteFileLine(htmlfile, "<h2>Overall team stats:</h2>");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "<a onclick =\"javascript:ShowHide('TeamStats')\" href=\"javascript:;\">Show/Hide</a>");
	WriteFileLine(htmlfile, "<div class=\"mid\" id=\"TeamStats\" style=\"DISPLAY: block\">");
	WriteFileLine(htmlfile, "<table class=\"sortable\">");
	WriteFileLine(htmlfile, "<tbody>");
	WriteFileLine(htmlfile, "<tr class=\"heading\">");
	WriteFileLine(htmlfile, "<th>Team</th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">K<span>Total kills</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">D<span>Total deaths</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">A<span>Kill assists</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">HS<span>Headshots</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">TK<span>Team Kill</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">ATA<span>Assist Team Attack</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">KDR<span>Kill-death ratio</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">KPR<span>Kills per round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">DPR<span>Damage per round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">1k<span>1 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">2k<span>2 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">3k<span>3 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">4k<span>4 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">Ace<span>5 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">AC%<span>Accuaracy: Hits/Shots</span></a></th>");
	WriteFileLine(htmlfile, "</tr>");
	TKills = 0; TDeaths = 0; TAssists = 0; THeadShots = 0; TTeamKills = 0; TAssistsTeamAttack = 0; TDamage = 0; THits = 0; TShots = 0; Tk1 = 0; Tk2 = 0; Tk3 = 0; Tk4 = 0; Tk5 = 0;
	TKDR = 0.0; TKPR = 0.0; TDPR = 0.0; THS = 0.0; TAC = 0.0;
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (WasClientInGameAtAll[i] && WasClientTeam[i] == ct_team)
		{
			TKills += match_stats[i][MATCH_KILLS];
			TDeaths += match_stats[i][MATCH_DEATHS];
			TAssists += match_stats[i][MATCH_ASSIST];
			THeadShots += match_stats[i][MATCH_HEADSHOTS];
			TTeamKills += match_stats[i][MATCH_TEAMKILLS];
			TAssistsTeamAttack += match_stats[i][MATCH_ATA];
			TDamage += match_stats[i][MATCH_DAMAGE];
			Tk1 += match_stats[i][MATCH_1K];
			Tk2 += match_stats[i][MATCH_2K];
			Tk3 += match_stats[i][MATCH_3K];
			Tk4 += match_stats[i][MATCH_4K];
			Tk5 += match_stats[i][MATCH_5K];
			THits += match_stats[i][MATCH_HITS];
			TShots += match_stats[i][MATCH_SHOTS];
		}
	}
	if (TDeaths != 0)
	{
		TKDR = FloatDiv(float(TKills), float(TDeaths));
	}
	if (rounds != 0)
	{
		TKPR = FloatDiv(float(TKills), float(rounds));
		TDPR = FloatDiv(float(TDamage), float(rounds));
	}
	if (TKills != 0)
	{
		THS = FloatDiv(float(THeadShots), float(TKills));
		THS = THS * 100;
	}
	if (TShots != 0)
	{
		TAC = FloatDiv(float(THits), float(TShots));
		TAC = TAC * 100;
	}
	WriteFileLine(htmlfile, "<tr><td><b><font class=\"Blue\">%s</font></b></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%<span>%i/%i</span></a></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td></tr>", ct_name, TKills, TDeaths, TAssists, THeadShots, TTeamKills, TAssistsTeamAttack, TKDR, TKills, TDeaths, TKPR, TKills, rounds, TDPR, TDamage, rounds, Tk1, Tk2, Tk3, Tk4, Tk5, TAC, THits, TShots);
	TKills = 0; TDeaths = 0; TAssists = 0; THeadShots = 0; TTeamKills = 0; TAssistsTeamAttack = 0; TDamage = 0; THits = 0; TShots = 0; Tk1 = 0; Tk2 = 0; Tk3 = 0; Tk4 = 0; Tk5 = 0;
	TKDR = 0.0; TKPR = 0.0; TDPR = 0.0; THS = 0.0; TAC = 0.0;
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (WasClientInGameAtAll[i] && WasClientTeam[i] == t_team)
		{
			TKills += match_stats[i][MATCH_KILLS];
			TDeaths += match_stats[i][MATCH_DEATHS];
			TAssists += match_stats[i][MATCH_ASSIST];
			THeadShots += match_stats[i][MATCH_HEADSHOTS];
			TTeamKills += match_stats[i][MATCH_TEAMKILLS];
			TAssistsTeamAttack += match_stats[i][MATCH_ATA];
			TDamage += match_stats[i][MATCH_DAMAGE];
			Tk1 += match_stats[i][MATCH_1K];
			Tk2 += match_stats[i][MATCH_2K];
			Tk3 += match_stats[i][MATCH_3K];
			Tk4 += match_stats[i][MATCH_4K];
			Tk5 += match_stats[i][MATCH_5K];
			THits += match_stats[i][MATCH_HITS];
			TShots += match_stats[i][MATCH_SHOTS];
		}
	}
	if (TDeaths != 0)
	{
		TKDR = FloatDiv(float(TKills), float(TDeaths));
	}
	if (rounds != 0)
	{
		TKPR = FloatDiv(float(TKills), float(rounds));
		TDPR = FloatDiv(float(TDamage), float(rounds));
	}
	if (TKills != 0)
	{
		THS = FloatDiv(float(THeadShots), float(TKills));
		THS = THS * 100;
	}
	if (TShots != 0)
	{
		TAC = FloatDiv(float(THits), float(TShots));
		TAC = TAC * 100;
	}
	WriteFileLine(htmlfile, "<tr><td><b><font class=\"Red\">%s</font></b></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%<span>%i/%i</span></a></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td></tr>", t_name, TKills, TDeaths, TAssists, THeadShots, TTeamKills, TAssistsTeamAttack, TKDR, TKills, TDeaths, TKPR, TKills, rounds, TDPR, TDamage, rounds, Tk1, Tk2, Tk3, Tk4, Tk5, TAC, THits, TShots);
//	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "</tbody></table>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "");
// Player Stats
	WriteFileLine(htmlfile, "<h2>Player stats:</h2>");
	WriteFileLine(htmlfile, "<a onclick =\"javascript:ShowHide('PlayerStats')\" href=\"javascript:;\">Show/Hide</a>");
	WriteFileLine(htmlfile, "<div class=\"mid\" id=\"PlayerStats\" style=\"DISPLAY: block\" >");
	WriteFileLine(htmlfile, "<table class=\"sortable\">");
	WriteFileLine(htmlfile, "<tbody>");
	WriteFileLine(htmlfile, "<tr class=\"heading\">");
	WriteFileLine(htmlfile, "<th>Player</th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">K<span>Total kills</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">D<span>Total deaths</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">A<span>Kill assists</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">HS<span>Headshots</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">TK<span>Team Kill</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">ATA<span>Assist Team Attack</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">KDR<span>Kill-death ratio</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">KPR<span>Kills per round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">DPR<span>Damage per round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">1k<span>1 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">2k<span>2 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">3k<span>3 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">4k<span>4 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">Ace<span>5 kill round</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">LA%%<span>Last Alive: Clutch Attempts/Rounds</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">CW%%<span>Clutches: Clutches Won/Clutch Attempts</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">AC%%<span>Accuaracy: Hits/Shots</span></a></th>");
	WriteFileLine(htmlfile, "<th><a class=\"tooltip\">Rating<span>HLTV Rating</span></a></th>");
	WriteFileLine(htmlfile, "</tr>");
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (WasClientInGameAtAll[i] && WasClientTeam[i] == ct_team)
		{
			Format(player_name, sizeof(player_name), match_client_name[i]);
			Format(authid, sizeof(authid), match_client_steam2[i]);
			Format(auth_id64, sizeof(auth_id64), match_client_steam64[i]);
			Kills = match_stats[i][MATCH_KILLS];
			Deaths = match_stats[i][MATCH_DEATHS];
			Assists = match_stats[i][MATCH_ASSIST];
			HeadShots = match_stats[i][MATCH_HEADSHOTS];
			TeamKills = match_stats[i][MATCH_TEAMKILLS];
			AssistsTeamAttack = match_stats[i][MATCH_ATA];
			Damage = match_stats[i][MATCH_DAMAGE];
			k1 = match_stats[i][MATCH_1K];
			k2 = match_stats[i][MATCH_2K];
			k3 = match_stats[i][MATCH_3K];
			k4 = match_stats[i][MATCH_4K];
			k5 = match_stats[i][MATCH_5K];
			Hits = match_stats[i][MATCH_HITS];
			Shots = match_stats[i][MATCH_SHOTS];
			LastAlive = match_stats[i][MATCH_LAST];
			ClutchesWon = match_stats[i][MATCH_WON];
			if (match_stats[i][MATCH_DEATHS] != 0)
			{
				KDR = FloatDiv(float(match_stats[i][MATCH_KILLS]), float(match_stats[i][MATCH_DEATHS]));
			}
			if (match_stats[i][MATCH_ROUND] != 0)
			{
				KPR = FloatDiv(float(match_stats[i][MATCH_KILLS]), float(match_stats[i][MATCH_ROUND]));
				DPR = FloatDiv(float(match_stats[i][MATCH_DAMAGE]), float(match_stats[i][MATCH_ROUND]));
			}
			if (match_stats[i][MATCH_KILLS] != 0)
			{
				HS = FloatDiv(float(match_stats[i][MATCH_HEADSHOTS]), float(match_stats[i][MATCH_KILLS]));
				HS = HS * 100;
			}
			if (match_stats[i][MATCH_ROUND] != 0)
			{
				LA = FloatDiv(float(match_stats[i][MATCH_LAST]), float(match_stats[i][MATCH_ROUND]));
				LA = LA * 100;
			}
			if (match_stats[i][MATCH_LAST] != 0)
			{
				CW = FloatDiv(float(match_stats[i][MATCH_WON]), float(match_stats[i][MATCH_LAST]));
				CW = CW * 100;
			}
			if (match_stats[i][MATCH_SHOTS] != 0)
			{
				AC = FloatDiv(float(match_stats[i][MATCH_HITS]), float(match_stats[i][MATCH_SHOTS]));
				AC = AC * 100;
			}
			// HLTV Rating //
			MultiKills = FloatDiv(float(k1 + (4 * k2) + (9 * k3) + (16 * k4) + (25 * k5)), float(match_stats[i][MATCH_ROUND]));
	
			KillRating = FloatDiv(FloatDiv(float(Kills), float(rounds)), AverageKPR);
			SurvivalRating = FloatDiv(FloatDiv(float((match_stats[i][MATCH_ROUND] - Deaths)), float(rounds)), AverageSPR);
			RoundsWithMultipleKillsRating = FloatDiv(MultiKills, AverageRMK);
			
			HLTVRating = FloatDiv(FloatAdd(FloatAdd(KillRating, (0.7 * SurvivalRating)), RoundsWithMultipleKillsRating), 2.7);
			// HLTV Rating End //
			
			WriteFileLine(htmlfile, "<tr><td><b><a href=\"http://steamcommunity.com/profiles/%s\" style=\"text-decoration: none;\" target=\"_blank\" class=\"tooltip\"><font class=\"Blue\">%s</font><span>%s</span></a></b></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f<span>%i/%i</span></a></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td><td>%-.2f</td></tr>", auth_id64, player_name, authid, Kills, Deaths, Assists, HeadShots, TeamKills, AssistsTeamAttack, KDR, Kills, Deaths, KPR, Kills, match_stats[i][MATCH_ROUND], DPR, Damage, match_stats[i][MATCH_ROUND], k1, k2, k3, k4, k5, LA, LastAlive, match_stats[i][MATCH_ROUND], CW, ClutchesWon, LastAlive, AC, Hits, Shots, HLTVRating);
			for (int y = 0; y < MATCH_NUM; y++)
			{
				match_stats[i][y] = 0;
			}
			Format(player_name, sizeof(player_name), "");
			Format(authid, sizeof(authid), "");
			Format(auth_id64, sizeof(auth_id64), "");
			Kills = 0; Deaths = 0; Assists = 0; HeadShots = 0; TeamKills = 0; AssistsTeamAttack = 0; Damage = 0; k1 = 0; k2 = 0; k3 = 0; k4 = 0; k5 = 0; Hits = 0; Shots = 0; LastAlive = 0; ClutchesWon = 0;
			KDR = 0.0; DPR = 0.0; HS = 0.0; LA = 0.0; CW = 0.0; AC = 0.0;
			MultiKills = 0.0; KillRating = 0.0; SurvivalRating = 0.0; RoundsWithMultipleKillsRating = 0.0; HLTVRating = 0.0;
		}
	}
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (WasClientInGameAtAll[i] && WasClientTeam[i] == t_team)
		{
			Format(player_name, sizeof(player_name), match_client_name[i]);
			Format(authid, sizeof(authid), match_client_steam2[i]);
			Format(auth_id64, sizeof(auth_id64), match_client_steam64[i]);
			Kills = match_stats[i][MATCH_KILLS];
			Deaths = match_stats[i][MATCH_DEATHS];
			Assists = match_stats[i][MATCH_ASSIST];
			HeadShots = match_stats[i][MATCH_HEADSHOTS];
			TeamKills = match_stats[i][MATCH_TEAMKILLS];
			AssistsTeamAttack = match_stats[i][MATCH_ATA];
			Damage = match_stats[i][MATCH_DAMAGE];
			k1 = match_stats[i][MATCH_1K];
			k2 = match_stats[i][MATCH_2K];
			k3 = match_stats[i][MATCH_3K];
			k4 = match_stats[i][MATCH_4K];
			k5 = match_stats[i][MATCH_5K];
			Hits = match_stats[i][MATCH_HITS];
			Shots = match_stats[i][MATCH_SHOTS];
			LastAlive = match_stats[i][MATCH_LAST];
			ClutchesWon = match_stats[i][MATCH_WON];
			if (match_stats[i][MATCH_DEATHS] != 0)
			{
				KDR = FloatDiv(float(match_stats[i][MATCH_KILLS]), float(match_stats[i][MATCH_DEATHS]));
			}
			if (match_stats[i][MATCH_ROUND] != 0)
			{
				KPR = FloatDiv(float(match_stats[i][MATCH_KILLS]), float(match_stats[i][MATCH_ROUND]));
				DPR = FloatDiv(float(match_stats[i][MATCH_DAMAGE]), float(match_stats[i][MATCH_ROUND]));
			}
			if (match_stats[i][MATCH_KILLS] != 0)
			{
				HS = FloatDiv(float(match_stats[i][MATCH_HEADSHOTS]), float(match_stats[i][MATCH_KILLS]));
				HS = HS * 100;
			}
			if (match_stats[i][MATCH_ROUND] != 0)
			{
				LA = FloatDiv(float(match_stats[i][MATCH_LAST]), float(match_stats[i][MATCH_ROUND]));
				LA = LA * 100;
			}
			if (match_stats[i][MATCH_LAST] != 0)
			{
				CW = FloatDiv(float(match_stats[i][MATCH_WON]), float(match_stats[i][MATCH_LAST]));
				CW = CW * 100;
			}
			if (match_stats[i][MATCH_SHOTS] != 0)
			{
				AC = FloatDiv(float(match_stats[i][MATCH_HITS]), float(match_stats[i][MATCH_SHOTS]));
				AC = AC * 100;
			}
			// HLTV Rating //
			MultiKills = FloatDiv(float(k1 + (4 * k2) + (9 * k3) + (16 * k4) + (25 * k5)), float(match_stats[i][MATCH_ROUND]));
	
			KillRating = FloatDiv(FloatDiv(float(Kills), float(rounds)), AverageKPR);
			SurvivalRating = FloatDiv(FloatDiv(float((match_stats[i][MATCH_ROUND] - Deaths)), float(rounds)), AverageSPR);
			RoundsWithMultipleKillsRating = FloatDiv(MultiKills, AverageRMK);
			
			HLTVRating = FloatDiv(FloatAdd(FloatAdd(KillRating, (0.7 * SurvivalRating)), RoundsWithMultipleKillsRating), 2.7);
			// HLTV Rating End //
			
			WriteFileLine(htmlfile, "<tr><td><b><a href=\"http://steamcommunity.com/profiles/%s\" style=\"text-decoration: none;\" target=\"_blank\" class=\"tooltip\"><font class=\"Red\">%s</font><span>%s</span></a></b></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f<span>%i/%i</span></a></td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td>%i</td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td><td><a class=\"tooltip\">%-.2f%%<span>%i/%i</span></a></td><td>%-.2f</td></tr>", auth_id64, player_name, authid, Kills, Deaths, Assists, HeadShots, TeamKills, AssistsTeamAttack, KDR, Kills, Deaths, KPR, Kills, match_stats[i][MATCH_ROUND], DPR, Damage, match_stats[i][MATCH_ROUND], k1, k2, k3, k4, k5, LA, LastAlive, match_stats[i][MATCH_ROUND], CW, ClutchesWon, LastAlive, AC, Hits, Shots, HLTVRating);
			for (int y = 0; y < MATCH_NUM; y++)
			{
				match_stats[i][y] = 0;
			}
			Format(player_name, sizeof(player_name), "");
			Format(authid, sizeof(authid), "");
			Format(auth_id64, sizeof(auth_id64), "");
			Kills = 0; Deaths = 0; Assists = 0; HeadShots = 0; TeamKills = 0; AssistsTeamAttack = 0; Damage = 0; k1 = 0; k2 = 0; k3 = 0; k4 = 0; k5 = 0; Hits = 0; Shots = 0; LastAlive = 0; ClutchesWon = 0;
			KDR = 0.0; DPR = 0.0; HS = 0.0; LA = 0.0; CW = 0.0; AC = 0.0;
			MultiKills = 0.0; KillRating = 0.0; SurvivalRating = 0.0; RoundsWithMultipleKillsRating = 0.0; HLTVRating = 0.0;
		}
	}
	WriteFileLine(htmlfile, "</tbody></table>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "<h2>Player information:</h2>");
	WriteFileLine(htmlfile, "<a onclick =\"javascript:ShowHide('PlayerInfo')\" href=\"javascript:;\">Show/Hide</a>");
	WriteFileLine(htmlfile, "<div class=\"mid\" id=\"PlayerInfo\" style=\"DISPLAY: none\" >");
	WriteFileLine(htmlfile, "<table class=\"sortable\">");
	WriteFileLine(htmlfile, "<tbody>");
	WriteFileLine(htmlfile, "<tr class=\"heading\">");
	WriteFileLine(htmlfile, "<th>Player</th> <th>STEAM-ID</th> <th>Profile link</th>");
	WriteFileLine(htmlfile, "</tr>");
	WriteFileLine(htmlfile, "<tr>");
	WriteFileLine(htmlfile, "<tr>");
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (WasClientInGameAtAll[i] && WasClientTeam[i] == ct_team)
		{
			Format(player_name, sizeof(player_name), match_client_name[i]);
			Format(authid, sizeof(authid), match_client_steam2[i]);
			Format(auth_id64, sizeof(auth_id64), match_client_steam64[i]);
			WriteFileLine(htmlfile, "<tr><td><b><a href=\"http://steamcommunity.com/profiles/%s\" style=\"text-decoration: none;\" target=\"_blank\" class=\"tooltip\"><font class=\"Blue\">%s</font><span>%s</span></a></b></td><td>%s</td><td><a href=\"http://steamcommunity.com/profiles/%s\" target=\"_blank\">Link</a></td></tr>", auth_id64, player_name, authid, authid, auth_id64);
		}
	}
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		if (WasClientInGameAtAll[i] && WasClientTeam[i] == t_team)
		{
			Format(player_name, sizeof(player_name), match_client_name[i]);
			Format(authid, sizeof(authid), match_client_steam2[i]);
			Format(auth_id64, sizeof(auth_id64), match_client_steam64[i]);
			WriteFileLine(htmlfile, "<tr><td><b><a href=\"http://steamcommunity.com/profiles/%s\" style=\"text-decoration: none;\" target=\"_blank\" class=\"tooltip\"><font class=\"Red\">%s</font><span>%s</span></a></b></td><td>%s</td><td><a href=\"http://steamcommunity.com/profiles/%s\" target=\"_blank\">Link</a></td></tr>", auth_id64, player_name, authid, authid, auth_id64);
		}
	}
	WriteFileLine(htmlfile, "</tbody></table>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "<br>");
	WriteFileLine(htmlfile, "<h4><a href=\"#\" title=\"Click to return to the top\">Return to the top</a></h4>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "<div id=\"footer\">");
	WriteFileLine(htmlfile, "<div id=\"footer_container\" class=\"clearfix\">");
//	WriteFileLine(htmlfile, "<div class=\"foot_col\">");
	WriteFileLine(htmlfile, "<h3>Copyright</h3>");
	WriteFileLine(htmlfile, "<p>COPYRIGHT 2011-2015 Versatile_BFG</p>");
	WriteFileLine(htmlfile, "</br>");
//	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "</div>");
	WriteFileLine(htmlfile, "");
	WriteFileLine(htmlfile, "</body>");
	WriteFileLine(htmlfile, "</html>", false);// no intline at the end
	CloseHandle(htmlfile);
	
	char MOTDLoadFile[PLATFORM_MAX_PATH];
	Format(MOTDLoadFile, sizeof(MOTDLoadFile), "MOTD_popup%i-%i.html", GetConVarInt(FindConVar("hostip")), GetConVarInt(FindConVar("hostport")));
	DeleteFile(MOTDLoadFile);

	Format(siteLocation, sizeof(siteLocation), "%s/%s", siteLocation, MatchStatsFile);
	
	Handle motdfile = OpenFile(MOTDLoadFile, "w");
	WriteFileLine(motdfile, "<html>");
	WriteFileLine(motdfile, "<head>");
	WriteFileLine(motdfile, "<script type=\"text/javascript\">");
	WriteFileLine(motdfile, "window.onload = function(){");
	WriteFileLine(motdfile, "<!-- var popup=window.open(\"$s\",\"Warmod BFG - Match Stats\",\"height=60,width=393\"); -->", siteLocation);
	WriteFileLine(motdfile, "var x = screen.width * 0.70;");
	WriteFileLine(motdfile, "var y = screen.height * 0.70;");
	WriteFileLine(motdfile, "var popup=window.open(\"%s\",\"Warmod BFG - Match Stats\",'scrollbars=yes,width='+x+',height='+y+',left=0,top=0');", siteLocation);
	WriteFileLine(motdfile, "document.write(x+'x'+y);");
	WriteFileLine(motdfile, "};");
	WriteFileLine(motdfile, "</script>");
	WriteFileLine(motdfile, "</head>");
	WriteFileLine(motdfile, "<body>");
	WriteFileLine(motdfile, "</body>");
	WriteFileLine(motdfile, "</html>");
	CloseHandle(motdfile);
	
	if (LibraryExists("teftp"))
	{
		Handle wDataPack = CreateDataPack();
		CreateDataTimer(1.0, Timer_UploadMOTDSite, wDataPack);
		WritePackString(wDataPack, MOTDLoadFile);
		
		Handle hDataPack = CreateDataPack();
		CreateDataTimer(2.0, Timer_UploadStatsSite, hDataPack);
		WritePackString(hDataPack, MatchStatsFile);
	}
}

public Action Timer_UploadMOTDSite(Handle timer, Handle wDataPack)
{
	if (LibraryExists("teftp"))
	{
		ResetPack(wDataPack);
		char MOTDLoadFile[PLATFORM_MAX_PATH];
		ReadPackString(wDataPack, MOTDLoadFile, sizeof(MOTDLoadFile));
		GetConVarString(wm_autodemoupload_ftptargetstats, g_ftp_target, sizeof(g_ftp_target));
		EasyFTP_UploadFile(g_ftp_target, MOTDLoadFile, "/", UploadCompleteMOTD);
	}
}

public Action Timer_UploadStatsSite(Handle timer, Handle hDataPack)
{
	if (LibraryExists("teftp"))
	{
		ResetPack(hDataPack);
		char MatchStatsFile[PLATFORM_MAX_PATH];
		ReadPackString(hDataPack, MatchStatsFile, sizeof(MatchStatsFile));
		GetConVarString(wm_autodemoupload_ftptargetstats, g_ftp_target, sizeof(g_ftp_target));
		EasyFTP_UploadFile(g_ftp_target, MatchStatsFile, "/", UploadCompleteStats);
	}
}

public int UploadCompleteMOTD(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, int iErrorCode, any data)
{
	if(iErrorCode == 0)
	{
		DeleteFile(sLocalFile);
		g_MODT_popup = true;
	}
	else
	{
		g_MODT_popup = false;
	}
}

public int UploadCompleteStats(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, int iErrorCode, any data)
{
	if(iErrorCode == 0)
	{
		DeleteFile(sLocalFile);
		char siteLocation[PLATFORM_MAX_PATH];
		GetConVarString(wm_site_location, siteLocation, sizeof(siteLocation));
		if (StrContains(siteLocation, "http", false) == -1)
		{
			Format(siteLocation, sizeof(siteLocation), "http://%s", siteLocation);
		}
		Format(siteLocation, sizeof(siteLocation), "%s/MOTD_popup%i-%i.html", siteLocation,  GetConVarInt(FindConVar("hostip")), GetConVarInt(FindConVar("hostport")));
		for (int i = 1; i < MAXPLAYERS; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && g_MODT_popup)
			{
				ShowMOTDPanel(i, "Warmod BFG - Match Stats", siteLocation, MOTDPANEL_TYPE_URL);
			}
		}
		g_MODT_popup = false;
	}
	else
	{
		PrintToChatAll("[WarMod_BFG] Match statistics page failed to upload");
		g_MODT_popup = false;
	}
}

stock void GetCurrentWorkshopMap(char[] g_MapName, int iMapBuf, char[] g_WorkShopID, int iWorkShopBuf)
{
	char g_CurMap[128];
	char g_CurMapSplit[2][64];
		
	GetCurrentMap(g_CurMap, sizeof(g_CurMap));
	
	ReplaceString(g_CurMap, sizeof(g_CurMap), "workshop/", "", false);
	
	ExplodeString(g_CurMap, "/", g_CurMapSplit, 2, 64);
	
	strcopy(g_WorkShopID, iWorkShopBuf, g_CurMapSplit[0]);
	strcopy(g_MapName, iMapBuf, g_CurMapSplit[1]);
	strcopy(g_map, iMapBuf, g_CurMapSplit[1]);
}