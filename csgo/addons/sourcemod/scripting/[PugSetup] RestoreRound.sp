#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <autoexecconfig>
#undef REQUIRE_PLUGIN
#include <pugsetup>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

//#define DEBUG

#define MAXROUNDS 150 //including overtime :s

int iRound = 0;
bool g_bStop[MAXPLAYERS+1];
bool g_RepeatTimer = false;
bool g_Restored = false;

bool g_ctUnpaused = false;
bool g_tUnpaused = false;

ConVar gc_sChatTag, gc_fRepeat, gc_bDeleteFile;

char g_ssPrefix[128];

char g_BackupPrefix[PLATFORM_MAX_PATH], g_BackupPrefixPattern[PLATFORM_MAX_PATH];

bool g_RoundEnd;

bool g_Pug;

public Plugin myinfo =
{
    name = "[PugSetup] RestoreRound",
    author = "Cruze",
    description = "Player can type .stop command to restore last round. Admins can type .res to restore any round.",
    version = "1.2",
    url = "http://steamcommunity.com/profiles/76561198132924835"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("PugSetup_GetGameState");
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_team", Event_Changeteam);
	HookUserMessage(GetUserMessageId("TextMsg"), Event_TextMsgHook);
	AddCommandListener(Event_UnpauseMatchCvar, "mp_unpause_match");
	
	RegConsoleCmd("sm_unpause", Command_Unpause, "Requests an unpause");
	RegAdminCmd("sm_restoreround", Command_Restore, ADMFLAG_GENERIC, "Restores last rounds.");
	RegAdminCmd("sm_deleteallbackuprounds", Command_DeleteAllRounds, ADMFLAG_ROOT, "Deletes all backup rounds.");
	
	AutoExecConfig_SetFile("RestoreRound");
	AutoExecConfig_SetCreateFile(true);
	
	gc_sChatTag = AutoExecConfig_CreateConVar("sm_pug_rr_chattag", "[{lightgreen}PUG{default}]", "Chat tag for chat prints");
	gc_fRepeat = AutoExecConfig_CreateConVar("sm_pug_rr_repeat", "5.0", "Repeat message of \"round restore\" and \"unpause to resume match\" every x seconds. 0.0 to disable repeat.");
	gc_bDeleteFile = AutoExecConfig_CreateConVar("sm_pug_rr_delete_file", "0", "Delete backup files every map start/reload? WARNING: If enabled, you can loose backup files when server crashed. It's recommended to use sm_deleteallbackuprounds.");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	LoadTranslations("RestoreRound.phrases");
}
	

public void OnAllPluginsLoaded()
{
	g_Pug = LibraryExists("pugsetup");
}

public void OnLibraryAdded(const char[] name)
{
	if(strcmp(name, "pugsetup") == 0)
	{
		g_Pug = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(strcmp(name, "pugsetup") == 0)
	{
		g_Pug = false;
	}
}

public Action Event_UnpauseMatchCvar(int client, const char[] command, int argc)
{
	if(!(GameRules_GetProp("m_bMatchWaitingForResume") != 0))
	{
		return;
	}
	for(int i = 0; i < MaxClients; i++)
	{
		g_bStop[i] = false;
	}
	g_RepeatTimer = false;
	g_Restored = false;
	g_ctUnpaused = true;
	g_tUnpaused = true;
}

public Action Event_RoundStart(Event ev, const char[] name, bool dbc)
{
	g_RoundEnd = false;
	for(int client = 0; client < MaxClients; client++)
	{
		g_bStop[client] = false;
	}
	g_RepeatTimer = false;
	g_Restored = false;
	g_ctUnpaused = true;
	g_tUnpaused = true;
	if(GameRules_GetProp("m_bWarmupPeriod") != 1)
	{
		iRound++;
		#if defined DEBUG
		PrintToChatAll("[DEBUG] Round: %d", iRound);
		#endif
	}
}

public Action Event_RoundEnd(Event ev, const char[] name, bool dbc)
{
	g_RoundEnd = true;
}

public Action Event_Changeteam(Event ev, const char[] name, bool dbc)
{
	int client = GetClientOfUserId(ev.GetInt("userid"));
	
	if(!client)
	{
		return;
	}
	
	g_bStop[client] = false;
}

public Action Event_TextMsgHook(UserMsg umId, Handle hMsg, const int[] iPlayers, int iPlayersNum, bool bReliable, bool bInit)
{
    //Thank you SM9(); for this!!

	char szName[40]; PbReadString(hMsg, "params", szName, sizeof(szName), 0);
	char szValue[40]; PbReadString(hMsg, "params", szValue, sizeof(szValue), 1);
    
	if (StrEqual(szName, "#SFUI_Notice_Game_will_restart_in", false)) 
	{
		CreateTimer(StringToFloat(szValue), Timer_GameRestarted);
	}
	return Plugin_Continue;
}

public Action Timer_GameRestarted(Handle hTimer)
{
	iRound = 1;
}

public void OnMapStart()
{
	gc_sChatTag.GetString(g_ssPrefix, sizeof(g_ssPrefix));

	FindConVar("mp_backup_round_file").GetString(g_BackupPrefix, sizeof(g_BackupPrefix));
	FindConVar("mp_backup_round_file_pattern").GetString(g_BackupPrefixPattern, sizeof(g_BackupPrefixPattern));

	if(StrContains(g_BackupPrefixPattern, "%date%") != -1 || StrContains(g_BackupPrefixPattern, "%time%") != -1 || StrContains(g_BackupPrefixPattern, "%team1%") != -1 || StrContains(g_BackupPrefixPattern, "%team2%") != -1 || StrContains(g_BackupPrefixPattern, "%map%") != -1 || StrContains(g_BackupPrefixPattern, "%score1%") != -1 || StrContains(g_BackupPrefixPattern, "%score2%") != -1)
	{
		LogError("Keep \"mp_backup_round_file_pattern\"'s value simplified. Only %round% is supported as of now. Plugin may not work properly.");
	}

	ServerCommand("mp_backup_restore_load_autopause 0");
	ServerCommand("mp_backup_round_auto 1");

	for(int client = 0; client < MaxClients; client++)
	{
		g_bStop[client] = false;
	}
	g_RepeatTimer = false;
	g_Restored = false;
	g_ctUnpaused = true;
	g_tUnpaused = true;
	iRound = 0;
	if(gc_bDeleteFile.BoolValue)
	{
		char filepath[PLATFORM_MAX_PATH];
		char num[5];
		for(int i = 0; i <= MAXROUNDS; i++)
		{
			Format(filepath, sizeof(filepath), "%s", g_BackupPrefixPattern);
			ReplaceString(filepath, sizeof(filepath), "%prefix%", g_BackupPrefix);
			if(i < 10)
			{
				Format(num, sizeof(num), "0%d", i);
				ReplaceString(filepath, sizeof(filepath), "%round%", num);
			}
			else
			{
				Format(num, sizeof(num), "%d", i);
				ReplaceString(filepath, sizeof(filepath), "%round%", num);
			}
			if(FileExists(filepath))
			{
				DeleteFile(filepath);
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	g_bStop[client] = false;
}

public void OnClientDisconnect(int client)
{
	OnClientPutInServer(client);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!client)
	{
		return Plugin_Continue;
	}
	if(strcmp(command, "say") != 0 && strcmp(command, "say_team") != 0)
	{
		return Plugin_Continue;
	}
	if(sArgs[0] != '.')
	{
		return Plugin_Continue;
	}
	if(strcmp(sArgs, ".rest", false) == 0 || strcmp(sArgs, ".restore", false) == 0)
	{
		Command_Restore(client, 0);
	}
	if(strcmp(command, "say_team") == 0)
	{
		return Plugin_Continue;
	}
	if(GetClientTeam(client) != 2 && GetClientTeam(client) != 3)
	{
		return Plugin_Continue;
	}
	if(strcmp(sArgs, ".stop", false) == 0)
	{
		DoStopThings(client);
	}
	else if(strcmp(sArgs, ".unpause", false) == 0)
	{
		Command_Unpause(client, 0);
	}
	return Plugin_Continue;
}

public void DoStopThings(int client)
{
	if(GameRules_GetProp("m_bWarmupPeriod") == 1 || g_RoundEnd || (g_Pug && PugSetup_GetGameState() != GameState_Live))
	{
		CPrintToChat(client, "%s %T", g_ssPrefix, "CannotUseRightNow", client);
		return;
	}
	if(g_bStop[client])
	{
		CPrintToChat(client, "%s %T", g_ssPrefix, "UsedCommand", client);
		return;
	}
	if(TeamUsedStop(client))
	{
		CPrintToChat(client, "%s %T", g_ssPrefix, "TeamUsedCommand", client);
		return;
	}
	if(!UsedStop())
	{
		char teamname[64], oppteamname[64];
		if(GetClientTeam(client) == 2)
		{
			Format(teamname, sizeof(teamname), "%T", "T", client);
			Format(oppteamname, sizeof(oppteamname), "%T", "CT", client);
		}
		else if(GetClientTeam(client) == 3)
		{
			Format(teamname, sizeof(teamname), "%T", "CT", client);
			Format(oppteamname, sizeof(oppteamname), "%T", "T", client);
		}
		char sMessage[256];
		Format(sMessage, sizeof(sMessage), "%s %T", g_ssPrefix, "StopRequest", LANG_SERVER, teamname, oppteamname);
		CPrintToChatAll(sMessage);
		if(gc_fRepeat.FloatValue)
		{
			DataPack data = new DataPack();
			CreateDataTimer(gc_fRepeat.FloatValue, Timer_RepeatMSG, data, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			data.WriteString(sMessage);
		}
		g_RepeatTimer = true;
		g_bStop[client] = true;
	}
	else
	{
		RestoreRound(iRound-1);
	}
}

public Action Timer_RepeatMSG(Handle tmr, DataPack pack)
{
	if(!g_RepeatTimer)
	{
		return Plugin_Stop;
	}
	pack.Reset();
	char sMessage[256];
	pack.ReadString(sMessage, sizeof(sMessage));
	CPrintToChatAll(sMessage);
	return Plugin_Continue;
}

stock void RestoreRound(int round, int type = 0)
{
	g_RepeatTimer = false;
	for(int i = 0; i < MaxClients; i++)
	{
		g_bStop[i] = false;
	}

	if(type == 1)
	{
		iRound = round;
	}
	else
	{
		iRound -= 1;
	}

	char filepath[PLATFORM_MAX_PATH];
	char num[5];
	Format(filepath, sizeof(filepath), "%s", g_BackupPrefixPattern);
	ReplaceString(filepath, sizeof(filepath), "%prefix%", g_BackupPrefix);
	if(round < 10)
	{
		Format(num, sizeof(num), "0%d", round);
		ReplaceString(filepath, sizeof(filepath), "%round%", num);
	}
	else
	{
		Format(num, sizeof(num), "%d", round);
		ReplaceString(filepath, sizeof(filepath), "%round%", num);
	}
	
	if(!FileExists(filepath))
	{
		#if defined DEBUG
		PrintToChatAll("[DEBUG] Backup file \"%s\" doesn't exist", filepath);
		#endif
		return;
	}
	
	ServerCommand("mp_pause_match");
	ServerCommand("mp_backup_restore_load_file %s", filepath);
	#if defined DEBUG
	PrintToChatAll("[DEBUG] File: %s", filepath);
	#endif
	CPrintToChatAll("%s %T", g_ssPrefix, "RoundRestored", LANG_SERVER);

	char sMessage[256];
	Format(sMessage, sizeof(sMessage), "%s %T", g_ssPrefix, "UnpauseInst", LANG_SERVER);
	CPrintToChatAll(sMessage);

	if(gc_fRepeat.FloatValue)
	{
		DataPack data = new DataPack();
		CreateDataTimer(gc_fRepeat.FloatValue, Timer_RepeatMSG2, data, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		data.WriteString(sMessage);
	}

	g_Restored = true;
	g_ctUnpaused = false;
	g_tUnpaused = false;
}

public Action Timer_RepeatMSG2(Handle tmr, DataPack pack)
{
	if(g_ctUnpaused || g_tUnpaused)
	{
		return Plugin_Stop;
	}
	char sMessage[256];

	pack.Reset();
	pack.ReadString(sMessage, sizeof(sMessage));
	CPrintToChatAll(sMessage);
	return Plugin_Continue;
}

public Action Command_Restore(int client, int args)
{
	if(!client)
	{
		return Plugin_Handled;
	}
	RestoreMenu(client);
	return Plugin_Handled;
}

public void RestoreMenu(int client)
{
	char info[5], display[16], curr[16], filepath[PLATFORM_MAX_PATH];
	Menu menu = new Menu(Handle_RestoreMenu);
	menu.SetTitle("Round to restore:");
	char num[5];
	for(int i = 0; i <= MAXROUNDS; i++)
	{
		Format(filepath, sizeof(filepath), "%s", g_BackupPrefixPattern);
		ReplaceString(filepath, sizeof(filepath), "%prefix%", g_BackupPrefix);
		if(i < 10)
		{
			Format(num, sizeof(num), "0%d", i);
			ReplaceString(filepath, sizeof(filepath), "%round%", num);
		}
		else
		{
			Format(num, sizeof(num), "%d", i);
			ReplaceString(filepath, sizeof(filepath), "%round%", num);
		}
		if(!FileExists(filepath))
		{
			continue;
		}
		IntToString(i, info, sizeof(info));
		Format(curr, sizeof(curr), "%T", "CurrentShort", client);
		Format(display, sizeof(display), "%T %d%s", "Round", client, i+1, i+1 == iRound ? curr:"");
		menu.AddItem(info, display);
	}
	menu.ExitButton = true;
	if(menu.ItemCount < 1)
	{
		CPrintToChat(client, "%s %T", g_ssPrefix, "NoBackupRounds", client);
	}
	else
	{
		menu.Display(client, 30);
	}
}

public int Handle_RestoreMenu(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(item, info, sizeof(info));
			RestoreRound(StringToInt(info), 1);
		}
	}
}

public Action Command_DeleteAllRounds(int client, int args)
{
	char filepath[PLATFORM_MAX_PATH];
	char num[5];
	for(int i = 0; i <= MAXROUNDS; i++)
	{
		Format(filepath, sizeof(filepath), "%s", g_BackupPrefixPattern);
		ReplaceString(filepath, sizeof(filepath), "%prefix%", g_BackupPrefix);
		if(i < 10)
		{
			Format(num, sizeof(num), "0%d", i);
			ReplaceString(filepath, sizeof(filepath), "%round%", num);
		}
		else
		{
			Format(num, sizeof(num), "%d", i);
			ReplaceString(filepath, sizeof(filepath), "%round%", num);
		}
		if(FileExists(filepath))
		{
			DeleteFile(filepath);
		}
	}
	CPrintToChat(client, "%s %T", g_ssPrefix, "DeletedBackup", client);
	return Plugin_Handled;
}

public Action Command_Unpause(int client, int args)
{
	if (!(GameRules_GetProp("m_bMatchWaitingForResume") != 0) || !client || !g_Restored)
	{
		return Plugin_Handled;
	}

	int team = GetClientTeam(client);
	
	if(team == 2 && g_tUnpaused || team == 3 && g_ctUnpaused )
	{
		return Plugin_Handled;
	}
	
	if (team == 2)
	{
		g_tUnpaused = true;
	}
	else if (team == 3)
	{
		g_ctUnpaused = true;
	}
	LogMessage("%L requested a unpause", client);

	if (g_tUnpaused && g_ctUnpaused)
	{
		ServerCommand("mp_unpause_match");
		LogMessage("Unpausing the game", client);
		g_Restored = false;
	}
	else if (g_tUnpaused && !g_ctUnpaused)
	{
		char sMessage[256];
		Format(sMessage, sizeof(sMessage), "%s %T", g_ssPrefix, "TUnpause", LANG_SERVER);
		CPrintToChatAll(sMessage);
		DataPack data = new DataPack();
		CreateDataTimer(gc_fRepeat.FloatValue, Timer_RepeatMSG3, data, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		data.WriteString(sMessage);
	}
	else if (!g_tUnpaused && g_ctUnpaused)
	{
		char sMessage[256];
		Format(sMessage, sizeof(sMessage), "%s %T", g_ssPrefix, "CTUnpause", LANG_SERVER);
		CPrintToChatAll(sMessage);
		DataPack data = new DataPack();
		CreateDataTimer(gc_fRepeat.FloatValue, Timer_RepeatMSG3, data, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		data.WriteString(sMessage);
	}
	return Plugin_Handled;
}

public Action Timer_RepeatMSG3(Handle tmr, DataPack pack)
{
	if(!g_Restored)
	{
		return Plugin_Stop;
	}
	char sMessage[256];

	pack.Reset();
	pack.ReadString(sMessage, sizeof(sMessage));
	CPrintToChatAll(sMessage);
	return Plugin_Continue;
}

stock bool TeamUsedStop(int client)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == GetClientTeam(client) && g_bStop[i])
		{
			return true;
		}
	}
	return false;
}

stock bool UsedStop()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && g_bStop[i])
		{
			return true;
		}
	}
	return false;
}