#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <SteamWorks>
#include <warmod>
#undef REQUIRE_PLUGIN
#include <updater>
#pragma newdecls required


//#define CHATPREFIX "[CyberGamer]"
#define KEY "iBxGx7AcJXdZ8x2zTpN0QZRzq23m3QOY"
//#define QUERY_URL "http://au.cybergamer.com/indexxml.php"
#define UPDATE_URL    "https://warmod.bitbucket.io/updatefile_cg.txt"
#define CHAT_PREFIX "CyberGamer"

/* Who Is & Elite */
bool g_prem_list[MAXPLAYERS + 1] = false;
//bool already_called[MAXPLAYERS + 1] = false;
//char g_prem_prefix[32] = "[CG Premium]";
char g_cg_name[MAXPLAYERS + 1][512];
//char g_team_name_cache[16][64];

ConVar cg_pug_id;
ConVar cg_is_debug;
ConVar cg_force_name;
ConVar cg_nonprem_name;
bool bLateLoad = false;
char NetIP[32];
char NetPort[10];

public Plugin myinfo = {
	name        = "CyberGamer Pug Service",
	author      = "Versatile_BFG",
	description = "A service for CG pug system",
	version     = "0.65",
	url         = "http://au.cybergamer.com/"
};

public void OnPluginStart() {
	
	if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
	
	int pieces[4];
	int longip = GetConVarInt(FindConVar("hostip"));
	pieces[0] = (longip >> 24) & 0x000000FF;
	pieces[1] = (longip >> 16) & 0x000000FF;
	pieces[2] = (longip >> 8) & 0x000000FF;
	pieces[3] = longip & 0x000000FF;
	Format(NetIP, sizeof(NetIP), "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);
	Format(NetPort, sizeof(NetPort), "%i", GetConVarInt(FindConVar("hostport")));
	cg_pug_id = CreateConVar("cg_pug_id", "0", "Sets the pug id for the current match", FCVAR_PROTECTED);
	cg_is_debug = CreateConVar("cg_is_debug", "0", "Debug mode", FCVAR_PROTECTED);
	cg_force_name = CreateConVar("cg_force_name", "1", "Force client name to CG name", FCVAR_PROTECTED);
	cg_nonprem_name = CreateConVar("cg_nonprem_name", "1", "Adds star to name if non_premium, 2 stars if not in database", FCVAR_PROTECTED);
	
	RegServerCmd("cg_stest", CG_Score_Test);
	
	HookConVarChange(cg_pug_id, OnPugIDChange);
	
	if (bLateLoad) {
		for (int i=1; i<=MaxClients; i++) {	
			if (IsClientInGame(i)) {
				if (!IsFakeClient(i)) {
					char auth_id[18];
					GetClientAuthId(i, AuthId_SteamID64, auth_id, sizeof(auth_id));
					GetCGName(i, auth_id, sizeof(auth_id));
				}
			}
		}
	}
}

public void OnLibraryAdded(const char[]name) {
	if (StrEqual(name, "updater")) {
		Updater_AddPlugin(UPDATE_URL);
	}
}

public Action SteamWorks_RestartRequested() {
	
	char pug_id[10];
	IntToString(GetConVarInt(cg_pug_id), pug_id, sizeof(pug_id));
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "http://au.cybergamer.com/indexxml.php?p=csgowarmodapi");
	//SteamWorks_SetHTTPRequestGetOrPostParameter(request, "p", "csgowarmodapi");
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "action", "update_server");  
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "api_key", KEY);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ip", NetIP);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "port", NetPort);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "pug_id", pug_id);
	
	SteamWorks_SetHTTPCallbacks(request, OnSendUpdateServerComplete);
	
	SteamWorks_SendHTTPRequest(request);
	return Plugin_Continue;
}

public int OnSendUpdateServerComplete(Handle request, bool bIOFailure, bool successful, EHTTPStatusCode status) {
	if (!successful) {
		LogError("SteamWorks error (status code %i). Request successful: %s", view_as<int>(status), successful ? "True" : "False");
	}
	CloseHandle(request);
}

public void OnPugIDChange(Handle cvar, const char[]oldVal, const char[]newVal)
{
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "http://au.cybergamer.com/indexxml.php?p=csgowarmodapi");
	//SteamWorks_SetHTTPRequestGetOrPostParameter(request, "p", "csgowarmodapi");
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "action", "match_settings");  
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "api_key", KEY);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ip", NetIP);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "port", NetPort);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "pug_id", newVal);
	
	SteamWorks_SetHTTPCallbacks(request, OnSendPugIDComplete);
	
	SteamWorks_SendHTTPRequest(request);
}

public int OnSendPugIDComplete(Handle request, bool bIOFailure, bool successful, EHTTPStatusCode status) {
	if (successful) {
		int m_iLength = 1;
		SteamWorks_GetHTTPResponseBodySize(request, m_iLength);
		char[] m_szBuffer = new char[m_iLength+2];
		SteamWorks_GetHTTPResponseBodyData(request, m_szBuffer, m_iLength);
		
		char[] data = new char[m_iLength+1];
		Format(data, m_iLength, "%s", m_szBuffer);
		StripString(data, m_iLength);
		char exstring[20][128];
		ExplodeString(data, ",", exstring, 20, 128);
		char success[2][32];
		ExplodeString(exstring[0], ":", success, 2, 32);
		if (StrEqual(success[1], "false", false)) {
			char message[2][64];
			ExplodeString(exstring[1], ":", message, 2, 64);
			LogError("Action: match_settings, Post Error: %s", message[1]);
		} else {
			//todo
			
		}
	} else {
		LogError("SteamWorks error (status code %i). Request successful: %s", view_as<int>(status), successful ? "True" : "False");
	}
	
	CloseHandle(request);
}

public Action CG_Score_Test(int args) {
	char g_t_name[64];
	char g_ct_name[64];
	char g_t_score[4];
	char g_ct_score[4];
	
	Format(g_ct_name, sizeof(g_ct_name), "ct_name");
	Format(g_t_name, sizeof(g_t_name), "t_name");
	Format(g_ct_score, sizeof(g_ct_score), "35");
	Format(g_t_score, sizeof(g_t_score), "45");

	char pug_id[10];
	IntToString(GetConVarInt(cg_pug_id), pug_id, sizeof(pug_id));

	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "http://au.cybergamer.com/indexxml.php?p=csgowarmodapi");
	//SteamWorks_SetHTTPRequestGetOrPostParameter(request, "p", "csgowarmodapi");
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "action", "pug_scores");  
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "api_key", KEY);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ip", NetIP);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "port", NetPort);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "pug_id", pug_id);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ct_name", g_ct_name);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ct_score", g_ct_score);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "t_name", g_t_name);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "t_score", g_t_score);
	
	SteamWorks_SetHTTPCallbacks(request, OnSendScoreComplete);
//	SteamWorks_SetHTTPRequestContextValue(request, client);
	
	SteamWorks_SendHTTPRequest(request);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	//... code here ...
	RegPluginLibrary("CG_Pug_Service");
	bLateLoad = late;
	return APLRes_Success;
}


public void OnClientPostAdminCheck(int client) {
	if (client == 0) {
		return;
	}
	
	if (IsFakeClient(client)) {	
		return;
	}
	
	char auth_id[18];
	GetClientAuthId(client, AuthId_SteamID64, auth_id, sizeof(auth_id));
	GetCGName(client, auth_id, sizeof(auth_id));
}

public void GetCGName(int client, char[] auth_id, int size) {
	//steamworks//
	
	char pug_id[10];
	IntToString(GetConVarInt(cg_pug_id), pug_id, sizeof(pug_id));
	char is_debug[2];
	IntToString(GetConVarInt(cg_is_debug), is_debug, sizeof(is_debug));
	
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "http://au.cybergamer.com/indexxml.php?p=csgowarmodapi");
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "action", "getPlayerMemberInfo");  
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "api_key", KEY);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ip", NetIP);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "port", NetPort);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "pug_id", pug_id);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "steam_id", auth_id);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "is_debug", is_debug);
	
	SteamWorks_SetHTTPCallbacks(request, OnGetPlayerMemberInfoComplete);
	SteamWorks_SetHTTPRequestContextValue(request, client);
	
	SteamWorks_SendHTTPRequest(request);
}

public int OnGetPlayerMemberInfoComplete(Handle request, bool bIOFailure, bool successful, EHTTPStatusCode status, any client) {
	if (successful) {
		int m_iLength = 1;
		SteamWorks_GetHTTPResponseBodySize(request, m_iLength);
		char[] m_szBuffer = new char[m_iLength+2];
		SteamWorks_GetHTTPResponseBodyData(request, m_szBuffer, m_iLength);
		
		char player_name[64];
		GetClientName(client, player_name, sizeof(player_name));
		char auth_id2[18];
		GetClientAuthId(client, AuthId_Steam2, auth_id2, sizeof(auth_id2));
		char auth_id[18];
		GetClientAuthId(client, AuthId_SteamID64, auth_id, sizeof(auth_id));
		char[] data = new char[m_iLength+1];
		Format(data, m_iLength, "%s", m_szBuffer);
		StripString(data, m_iLength);
		char exstring[20][128];
		ExplodeString(data, ",", exstring, 20, 128);
		char success[2][32];
		ExplodeString(exstring[0], ":", success, 2, 32);
		if (StrEqual(success[1], "false", false)) {
			char message[2][64];
			ExplodeString(exstring[1], ":", message, 2, 64);
			LogError("Action: getPlayerMemberInfo, Post Error: %s", message[1]);
			strcopy(g_cg_name[client], 64, "null");
		} else {
			char team_name[64];
			char extra_status[64];
			char league_name[64];
			char user_id[64];
			char acc_days[64];
			for (int i = 0; i < 20; i++) {
				char temp[2][64];
				ExplodeString(exstring[i], ":", temp, 2, 64);
				if (StrEqual(temp[0], "is_prem", false)) {
					if (StrEqual(temp[1], "1", false)) {
						g_prem_list[client] = true;
					} else {
						g_prem_list[client] = false;
					}
				} else if (StrEqual(temp[0], "username", false)) {
					strcopy(g_cg_name[client], 64, temp[1]);
				} else if (StrEqual(temp[0], "team_name", false)) {
					strcopy(team_name, 64, temp[1]);
				} else if (StrEqual(temp[0], "extra_status", false)) {
					strcopy(extra_status, 64, temp[1]);
				} else if (StrEqual(temp[0], "league_name", false)) {
					strcopy(league_name, 64, temp[1]);
				} else if (StrEqual(temp[0], "user_id", false)) {
					strcopy(user_id, 64, temp[1]);
				} else if (StrEqual(temp[0], "acc_days", false)) {
					strcopy(acc_days, 64, temp[1]);
				}
				
			}
			
			if (StrContains(player_name, g_cg_name[client], false) == -1 && GetConVarBool(cg_force_name)) {
				if (GetConVarBool(cg_nonprem_name)) {
					if (g_prem_list[client]) {
						SetClientName(client, g_cg_name[client]);
					} else if (StrEqual(success[1], "false", false)) {
						Format(player_name, sizeof(player_name), "%s**", player_name);
						SetClientName(client, player_name);
					} else {
						Format(g_cg_name[client], 64, "%s*", g_cg_name[client]);
						SetClientName(client, g_cg_name[client]);
					}
				} else {
					SetClientName(client, g_cg_name[client]);
				}
			} else if (StrEqual(success[1], "false", false) && GetConVarBool(cg_nonprem_name)) {
				Format(player_name, sizeof(player_name), "%s**", player_name);
				SetClientName(client, player_name);
			} else if (!g_prem_list[client] && GetConVarBool(cg_nonprem_name)) {
				Format(player_name, sizeof(player_name), "%s*", player_name);
				SetClientName(client, player_name);
			}
			
			if (StrEqual(extra_status, "NULL", false)) {
				PrintToChatAll("\x01 [\x0C%s\x01]\x04 Player: \x06%s", CHAT_PREFIX, g_cg_name[client]);
			} else {
				PrintToChatAll("\x01 [\x0C%s\x01]\x04 Player: \x06%s\x01 (\x0C%s\x01)", CHAT_PREFIX, g_cg_name[client], extra_status);
			}
			PrintToChatAll("\x01 \x04%s: \x06%s\x01 - \x04CGID: \x06%s", league_name, team_name, user_id);
			PrintToChatAll("\x01 \x04Joined: \x06%s days ago\x01 - \x04SteamID: \x06%s", acc_days, auth_id2);
		}
	} else {
		LogError("SteamWorks error (status code %i). Request successful: %s", view_as<int>(status), successful ? "True" : "False");
	}
	
	CloseHandle(request);
}

stock void StripString(char[] filename, int size) {
	ReplaceString(filename, size, "{", "");
	ReplaceString(filename, size, "}", "");
	ReplaceString(filename, size, "\"", "");
	//"
}

/*public void OnClientSettingsChanged(int client) {
	if (client == 0) {
		return;
	}
	
	if (IsFakeClient(client)) {	
		return;
	}
	
	char player_name[128];
	GetClientName(client, player_name, sizeof(player_name));
	
	if (StrContains(player_name, g_cg_name[client], false) == -1 && GetConVarBool(cg_force_name)) {
		if (GetConVarBool(cg_nonprem_name)) {
			if (g_prem_list[client]) {
				SetClientName(client, g_cg_name[client]);
			} else if (StrEqual(g_cg_name[client], "null", false) && (FindCharInString(player_name, '*', true) == -1)) {
				Format(player_name, sizeof(player_name), "%s**", player_name);
				SetClientName(client, player_name);
			} else if (FindCharInString(player_name, '*', true) == -1){
				Format(g_cg_name[client], 64, "%s*", g_cg_name[client]);
				SetClientName(client, g_cg_name[client]);
			}
			} else {
			SetClientName(client, g_cg_name[client]);
		}
	} else if (StrEqual(g_cg_name[client], "null", false) && GetConVarBool(cg_nonprem_name) && (FindCharInString(player_name, '*', true) == -1)) {
		Format(player_name, sizeof(player_name), "%s**", player_name);
		SetClientName(client, player_name);
	} else if (!g_prem_list[client] && GetConVarBool(cg_nonprem_name) && (FindCharInString(player_name, '*', true) == -1)) {
		
		Format(player_name, sizeof(player_name), "%s*", player_name);
		SetClientName(client, player_name);
	}
}*/

public void SendScores(const char[] ct_name, int ct_score, int t_score, const char[] t_name) {
	char g_t_name[64];
	char g_ct_name[64];
	char g_t_score[4];
	char g_ct_score[4];
	
	Format(g_ct_name, sizeof(g_ct_name), ct_name);
	Format(g_t_name, sizeof(g_t_name), t_name);
	IntToString(ct_score, g_ct_score, sizeof(g_ct_score));
	IntToString(t_score, g_t_score, sizeof(g_t_score));

	char pug_id[10];
	IntToString(GetConVarInt(cg_pug_id), pug_id, sizeof(pug_id));

	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "http://au.cybergamer.com/indexxml.php?p=csgowarmodapi");
//	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "p", "csgowarmodapi");
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "action", "pug_scores");  
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "api_key", KEY);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ip", NetIP);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "port", NetPort);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "pug_id", pug_id);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ct_name", g_ct_name);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "ct_score", g_ct_score);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "t_name", g_t_name);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "t_score", g_t_score);
	SteamWorks_SetHTTPCallbacks(request, OnSendScoreComplete);
	SteamWorks_SendHTTPRequest(request);
}

public void OnRoundEnd(const char[] ct_name, int ct_score, int t_score, const char[] t_name) {
	SendScores(ct_name, ct_score, t_score, t_name);
}

public void OnEndMatch(const char[] ct_name, int ct_score, int t_score, const char[] t_name) {
	SendScores(ct_name, ct_score, t_score, t_name);
}

public void OnHalfTime(const char[] ct_name, int ct_score, int t_score, const char[] t_name) {
	SendScores(ct_name, ct_score, t_score, t_name);
}

public int OnSendScoreComplete(Handle request, bool bIOFailure, bool successful, EHTTPStatusCode status) {
	if (successful) {
		int m_iLength = 2048;
		SteamWorks_GetHTTPResponseBodySize(request, m_iLength);
		char[] m_szBuffer = new char[m_iLength+1];
		SteamWorks_GetHTTPResponseBodyData(request, m_szBuffer, m_iLength);
		
		char data[PLATFORM_MAX_PATH];
		Format(data, sizeof(data), "%s", m_szBuffer);
		StripString(data, sizeof(data));
		LogAction(-1, -1, "Cybergamer score submitted: %s", data);
		
	} else {
		LogError("SteamWorks error (status code %i). Request successful: %s", view_as<int>(status), successful ? "True" : "False");
	}
	
	CloseHandle(request);
}