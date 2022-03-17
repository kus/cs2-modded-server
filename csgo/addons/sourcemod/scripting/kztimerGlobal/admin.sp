public OnAdminMenuReady(Handle:topmenu)
{
	if (topmenu == g_hAdminMenu)
		return;

	g_hAdminMenu = topmenu;
	new TopMenuObject:serverCmds = FindTopMenuCategory(g_hAdminMenu, ADMINMENU_SERVERCOMMANDS);
	AddToTopMenu(g_hAdminMenu, "sm_kzadmin", TopMenuObject_Item, TopMenuHandler2, serverCmds, "sm_kzadmin", ADMFLAG_RCON);
}

public TopMenuHandler2(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "KZ Timer");

	else 
		if (action == TopMenuAction_SelectOption)
			Admin_KzPanel(param, 0);
}

public Action:Admin_KzPanel(client, args)
{
	if (!client || (GetUserFlagBits(client) & ADMFLAG_ROOT))
	{
		PrintToConsole(client,"\n[KZ ROOT ADMIN]");
		PrintToConsole(client," sm_refreshprofile <steamid> (recalculates player profile for given steamid)\n sm_deleteproreplay <mapname> (Deletes pro replay file for a given map)\n sm_deletetpreplay <mapname> (Deletes tp replay file for a given map)\n ");
		PrintToConsole(client,"[PLAYER RANKING]\n sm_resetplayerchallenges <steamid> (Resets (won) challenges for given steamid)\n sm_resetextrapoints (Resets given extra points for all players)\n ");
		PrintToConsole(client,"[PLAYER TIMES]\n sm_resetmaptimes <map> (Resets player times for given map)\n sm_resetplayertimes <steamid> [<map>] (Resets tp and pro times + extra points for given steamid with or without given map)\n sm_resetplayertptime <steamid> <map> (Resets tp map time for given steamid and map)\n sm_resetplayerprotime <steamid> <map> (Resets pro map time for given steamid and map)\n \n[PLAYER JUMPSTATS]");
		PrintToConsole(client," sm_resetallljrecords (Resets all lj records)\n sm_resetallcjrecords (Resets all cj records)\n sm_resetallljblockrecords (Resets all lj block records)\n sm_resetallwjrecords (Resets all wj records)\n sm_resetallbhoprecords (Resets all bhop records)\n sm_resetallmultibhoprecords (Resets all multi bhop records)\n sm_resetalldropbhopecords (Resets all drop bhop records)\n sm_resetallladderjumprecords (Resets all ladder jump records)");
		PrintToConsole(client," sm_resetplayerjumpstats <steamid> (Resets jump stats for given steamid)\n sm_resetljrecord <steamid> (Resets lj record for given steamid)\n sm_resetcjrecord <steamid> (Resets cj record for given steamid)\n sm_resetljblockrecord <steamid> (Resets lj block record for given steamid)\n sm_resetwjrecord <steamid> (Resets wj record for given steamid)\n sm_resetbhoprecord <steamid> (Resets bhop record for given steamid)\n sm_resetmultibhoprecord <steamid> (Resets multi bhop record for given steamid)\n sm_resetdropbhoprecord <steamid> (Resets drop bhop record for given steamid)\n sm_resetladderjumprecord <steamid> (Resets ladder jump record for given steamid)");
		
		if(!client)
			return Plugin_Handled;
		else
			PrintToChat(client, "[%cKZ%c] See console for more commands", LIMEGREEN,WHITE);
	}
	else
		PrintToConsole(client," >> FULL ACCESS requires a 'z' (root) flag.) << ");
		
	StopClimbersMenu(client);
	g_bClimbersMenuOpen[client] = false;
	g_bMenuOpen[client]=true;
	CreateTimer(0.1, OpenAdminMenu, client,TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

static void AddMenuItemWithEnableDisableText(Handle menu, bool conditional, style = ITEMDRAW_DEFAULT, char[] displayAndInfo)
{
	char buffer[256];
	FormatEx(buffer, sizeof(buffer), "%s", displayAndInfo);
	
	if (conditional)
	{
		StrCat(buffer, sizeof(buffer), "  -  Enabled");
	}
	else
	{
		StrCat(buffer, sizeof(buffer), "  -  Disabled");
	}
	
	AddMenuItem(menu, displayAndInfo, buffer, style);
}

public KzAdminMenu(client)
{
	if(!IsValidClient(client) || (!(GetUserFlagBits(client) & ADMFLAG_GENERIC) &&  !(GetUserFlagBits(client) & ADMFLAG_ROOT)))
		return;
	g_bClimbersMenuOpen[client] = false;
	g_bMenuOpen[client]=true;
	decl String:szTmp[128];
	
	new Handle:adminmenu = CreateMenu(AdminPanelHandler);
	if (GetUserFlagBits(client) & ADMFLAG_ROOT)
		Format(szTmp, sizeof(szTmp), "KZTimer %s Admin Menu (full access)\nNoclip: bind KEY +noclip",VERSION); 	
	else
		Format(szTmp, sizeof(szTmp), "KZTimer %s Admin Menu (limited access)\nNoclip: bind KEY +noclip",VERSION); 	
	SetMenuTitle(adminmenu, szTmp);
	
	if (GetUserFlagBits(client) & ADMFLAG_ROOT)
	{
		if (g_pr_RankingRecalc_InProgress)
		{
			AddMenuItem(adminmenu, "Recalculate player ranks", "Stop the recalculation");
		}
		else
		{
			AddMenuItem(adminmenu, "Recalculate player ranks", "Recalculate player ranks");
		}
	}
	else
	{
		AddMenuItem(adminmenu, "Recalculate player ranks", "Recalculate player ranks", ITEMDRAW_DISABLED);
	}
	
	AddMenuItem(adminmenu, "Set start button", "Set start button");
	AddMenuItem(adminmenu, "Set stop button", "Set stop button");
	AddMenuItem(adminmenu, "Remove buttons", "Remove buttons");
	AddMenuItemWithEnableDisableText(adminmenu, g_bEnforcer,         ITEMDRAW_DEFAULT, "KZ settings enforcer");
	AddMenuItemWithEnableDisableText(adminmenu, g_bgodmode,          ITEMDRAW_DEFAULT, "Godmode");
	AddMenuItemWithEnableDisableText(adminmenu, g_bAllowCheckpoints, ITEMDRAW_DEFAULT, "Checkpoints");
	AddMenuItemWithEnableDisableText(adminmenu, g_bAutoRespawn,      ITEMDRAW_DEFAULT, "Autorespawn");
	AddMenuItemWithEnableDisableText(adminmenu, g_bCleanWeapons,     ITEMDRAW_DEFAULT, "Strip weapons");
	AddMenuItemWithEnableDisableText(adminmenu, g_bRestore,          ITEMDRAW_DEFAULT, "Restore function");
	AddMenuItemWithEnableDisableText(adminmenu, g_bPauseServerside,  ITEMDRAW_DEFAULT, "!pause command");
	AddMenuItemWithEnableDisableText(adminmenu, g_bGoToServer,       ITEMDRAW_DEFAULT, "!goto command");
	AddMenuItemWithEnableDisableText(adminmenu, g_bRadioCommands,    ITEMDRAW_DEFAULT, "Radio commands");
	AddMenuItemWithEnableDisableText(adminmenu, g_bReplayBot,        ITEMDRAW_DEFAULT, "Replay bot");
	AddMenuItemWithEnableDisableText(adminmenu, g_bPreStrafe,        ITEMDRAW_DEFAULT, "Prestrafe");
	AddMenuItemWithEnableDisableText(adminmenu, g_bPointSystem,      ITEMDRAW_DEFAULT, "Player point system");
	AddMenuItemWithEnableDisableText(adminmenu, g_bCountry,          ITEMDRAW_DEFAULT, "Player country tag");
	AddMenuItemWithEnableDisableText(adminmenu, g_bPlayerSkinChange, ITEMDRAW_DEFAULT, "Allow custom models");
	
	if (g_iNoClipMode == NOCLIPMODE_DISABLED)
		Format(szTmp, sizeof(szTmp), "+noclip  -  Disabled");
	else if (g_iNoClipMode == NOCLIPMODE_NORMAL)
		Format(szTmp, sizeof(szTmp), "+noclip  -  Enabled for VIP/top rank/map finished");
	else if (g_iNoClipMode == NOCLIPMODE_PRIVILEGED)
		Format(szTmp, sizeof(szTmp), "+noclip  -  Enabled for only VIP/top rank");
	else
		Format(szTmp, sizeof(szTmp), "+noclip  -  Enabled for everyone");
	AddMenuItem(adminmenu, "+noclip", szTmp);
	
	AddMenuItemWithEnableDisableText(adminmenu, g_bJumpStats,            ITEMDRAW_DEFAULT, "Jumpstats");
	AddMenuItemWithEnableDisableText(adminmenu, g_bAdminClantag,         ITEMDRAW_DEFAULT, "Admin clan tag");
	AddMenuItemWithEnableDisableText(adminmenu, g_bVipClantag,           ITEMDRAW_DEFAULT, "VIP clan tag");
	AddMenuItemWithEnableDisableText(adminmenu, g_bMapEnd,               ITEMDRAW_DEFAULT, "Allow map changes");
	AddMenuItemWithEnableDisableText(adminmenu, g_bConnectMsg,           ITEMDRAW_DEFAULT, "Connect message");
	AddMenuItemWithEnableDisableText(adminmenu, g_bInfoBot,              ITEMDRAW_DEFAULT, "Info bot");
	AddMenuItemWithEnableDisableText(adminmenu, g_bAttackSpamProtection, ITEMDRAW_DEFAULT, "Attack spam protection");
	AddMenuItemWithEnableDisableText(adminmenu, g_bSingleTouch,          ITEMDRAW_DEFAULT, "Bhop block single-touch");
	AddMenuItemWithEnableDisableText(adminmenu, g_bChallengePoints,      ITEMDRAW_DEFAULT, "Allow challenge points");
	AddMenuItemWithEnableDisableText(adminmenu, g_bAllowRoundEndCvar,    ITEMDRAW_DEFAULT, "Allow to end the current round");
	
	if (g_iDoubleDuckCvar == 1)
		Format(szTmp, sizeof(szTmp), "Double-Duck technique  -  Enabled");
	else if (g_iDoubleDuckCvar == 0)
		Format(szTmp, sizeof(szTmp), "Double-Duck technique  -  Disabled in runs");
	else
		Format(szTmp, sizeof(szTmp), "Double-Duck technique  -  Disabled"); 
	AddMenuItem(adminmenu, "Double-Duck technique", szTmp);
	
	AddMenuItemWithEnableDisableText(adminmenu, g_bTierMessages,         ITEMDRAW_DEFAULT, "Tier chat messages");
	AddMenuItemWithEnableDisableText(adminmenu, g_bEnableChatProcessing, ITEMDRAW_DEFAULT, "KZTimer Chat Processing");
	AddMenuItemWithEnableDisableText(adminmenu, g_bEnableGroupAdverts,   ITEMDRAW_DEFAULT, "KZTimer Steam Group Adverts");
	
	SetMenuExitButton(adminmenu, true);
	SetMenuOptionFlags(adminmenu, MENUFLAG_BUTTON_EXIT);
	
	DisplayMenuAtItem(adminmenu, client, g_AdminMenuLastPage[client], MENU_TIME_FOREVER);
}


public AdminPanelHandler(Handle:adminmenu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		char info[64];
		GetMenuItem(adminmenu, param2, info, sizeof(info));
		
		if (StrEqual(info, "Recalculate player ranks"))
		{ 
			if (!g_pr_RankingRecalc_InProgress)
			{
				PrintToChat(param1, "%t", "PrUpdateStarted", MOSSGREEN,WHITE);
				g_bManualRecalc=true;
				g_pr_Recalc_AdminID=param1;
				RefreshPlayerRankTable(MAX_PR_PLAYERS);
			}
			else
			{
				for(new i = 66; i <	MAX_PR_PLAYERS; i++) 
					g_bProfileRecalc[i]=false;	
				g_bTop100Refresh = false;
				g_bManualRecalc = false;
				g_pr_RankingRecalc_InProgress = false;
				PrintToChat(param1, "%t", "StopRecalculation", MOSSGREEN,WHITE);
			}
		}
		else if (StrEqual(info, "Set start button"))
		{ 
			SetStandingStartButton(param1);
			KzAdminMenu(param1);
		}
		else if (StrEqual(info, "Set stop button"))
		{ 
			SetStandingStopButton(param1);
			KzAdminMenu(param1);
		}
		else if (StrEqual(info, "Remove buttons"))
		{ 
			DeleteButtons(param1);
			db_deleteMapButtons(g_szMapName);
			PrintToChat(param1,"[%cKZ%c] Timer buttons deleted", MOSSGREEN,WHITE,GREEN,WHITE);
			KzAdminMenu(param1);
		}
		else if (StrEqual(info, "KZ settings enforcer"))
		{
			if (!g_bEnforcer)
				ServerCommand("kz_settings_enforcer 1");
			else
				ServerCommand("kz_settings_enforcer 0");
		}
		else if (StrEqual(info, "Godmode"))
		{
		
			if (!g_bgodmode)
				ServerCommand("kz_godmode 1");
			else	
				ServerCommand("kz_godmode 0");
		}		
		else if (StrEqual(info, "Checkpoints"))
		{
			if (!g_bAllowCheckpoints)
				ServerCommand("kz_checkpoints 1");
			else
				ServerCommand("kz_checkpoints 0");
		}		
		else if (StrEqual(info, "Autorespawn"))
		{
			if (!g_bAutoRespawn)
				ServerCommand("kz_autorespawn 1");
			else
				ServerCommand("kz_autorespawn 0");
		}					
		else if (StrEqual(info, "Strip weapons"))
		{
			if (!g_bCleanWeapons)
				ServerCommand("kz_clean_weapons 1");
			else	
				ServerCommand("kz_clean_weapons 0");
		}
		else if (StrEqual(info, "Restore function"))
		{
			if (!g_bRestore)
				ServerCommand("kz_restore 1");
			else
				ServerCommand("kz_restore 0");
		}
		else if (StrEqual(info, "!pause command"))
		{
			if (!g_bPauseServerside)
				ServerCommand("kz_pause 1");
			else
				ServerCommand("kz_pause 0");
		}
		else if (StrEqual(info, "!goto command"))
		{
			if (!g_bGoToServer)
				ServerCommand("kz_goto 1");
			else
				ServerCommand("kz_goto 0");
		}		
		else if (StrEqual(info, "Radio commands"))
		{
			// FIXME: this doesn't work for some reason.
			if (!g_bRadioCommands)
				ServerCommand("kz_radio 1");
			else
				ServerCommand("kz_radio 0");
		}
		else if (StrEqual(info, "Replay bot"))
		{
			if (!g_bReplayBot)
				ServerCommand("kz_replay_bot 1");
			else
				ServerCommand("kz_replay_bot 0");
		}	
		else if (StrEqual(info, "Prestrafe"))
		{
			if (!g_bPreStrafe)
				ServerCommand("kz_prestrafe 1");
			else
				ServerCommand("kz_prestrafe 0");
		}	
		else if (StrEqual(info, "Player point system"))
		{
			if (!g_bPointSystem)
				ServerCommand("kz_point_system 1");
			else
				ServerCommand("kz_point_system 0");
		}	
		else if (StrEqual(info, "Player country tag"))
		{
			if (!g_bCountry)
				ServerCommand("kz_country_tag 1");
			else
				ServerCommand("kz_country_tag 0");
		}	
		else if (StrEqual(info, "Allow custom models"))
		{
			if (!g_bPlayerSkinChange)
				ServerCommand("kz_custom_models 1");
			else
				ServerCommand("kz_custom_models 0");
		}	
		else if (StrEqual(info, "+noclip"))
		{
			ServerCommand("kz_noclip %i", (g_iNoClipMode + 1) % MAX_NOCLIPMODES);
		}
		else if (StrEqual(info, "Jumpstats"))
		{
			if (!g_bJumpStats)
				ServerCommand("kz_jumpstats 1");
			else
				ServerCommand("kz_jumpstats 0");
		}
		else if (StrEqual(info, "Admin clan tag"))
		{
			if (!g_bAdminClantag)
				ServerCommand("kz_admin_clantag 1");
			else
				ServerCommand("kz_admin_clantag 0");
		}	
		else if (StrEqual(info, "VIP clan tag"))
		{
			if (!g_bVipClantag)
				ServerCommand("kz_vip_clantag 1");
			else
				ServerCommand("kz_vip_clantag 0");
		}	
		else if (StrEqual(info, "Allow map changes"))
		{
			if (!g_bMapEnd)
				ServerCommand("kz_map_end 1");
			else
				ServerCommand("kz_map_end 0");
		}	
		else if (StrEqual(info, "Connect message"))
		{
			if (!g_bConnectMsg)
				ServerCommand("kz_connect_msg 1");
			else
				ServerCommand("kz_connect_msg 0");
		}	
		else if (StrEqual(info, "Info bot"))
		{
			if (!g_bInfoBot)
				ServerCommand("kz_info_bot 1");
			else
				ServerCommand("kz_info_bot 0");
		}	
		else if (StrEqual(info, "Attack spam protection"))
		{
			if (!g_bAttackSpamProtection)
				ServerCommand("kz_attack_spam_protection 1");
			else
				ServerCommand("kz_attack_spam_protection 0");
		}
		else if (StrEqual(info, "Bhop block single-touch"))
		{
			if (!g_bSingleTouch)
				ServerCommand("kz_bhop_single_touch 1");
			else
				ServerCommand("kz_bhop_single_touch 0");
		}
		else if (StrEqual(info, "Allow challenge points"))
		{
			if (!g_bChallengePoints)
				ServerCommand("kz_challenge_points 1");
			else
				ServerCommand("kz_challenge_points 0");
		}
		else if (StrEqual(info, "Allow to end the current round"))
		{
			if (!g_bAllowRoundEndCvar)
				ServerCommand("kz_round_end 1");
			else
				ServerCommand("kz_round_end 0");
		}
		else if (StrEqual(info, "Double-Duck technique"))
		{
			if (g_iDoubleDuckCvar == 2)
				ServerCommand("kz_double_duck 0");
			else if (g_iDoubleDuckCvar == 0 && !g_bEnforcer)
				ServerCommand("kz_double_duck 1");
			else
				ServerCommand("kz_double_duck 2");
		}
		else if (StrEqual(info, "Tier chat messages"))
		{
			if (!g_bTierMessages)
				ServerCommand("kz_tier_messages 1");
			else
				ServerCommand("kz_tier_messages 0");
		}
		else if (StrEqual(info, "KZTimer Chat Processing"))
		{
			if (!g_bEnableChatProcessing)
				ServerCommand("kz_chat_enable 1");
			else
				ServerCommand("kz_chat_enable 0");
		}
		else if (StrEqual(info, "KZTimer Steam Group Adverts"))
		{
			if (!g_bEnableGroupAdverts)
				ServerCommand("kz_steamgroup_advert 1");
			else
				ServerCommand("kz_steamgroup_advert 0");
		}
		
		g_AdminMenuLastPage[param1] = param2 - (param2 % GetMenuPagination(adminmenu));
		if (adminmenu != INVALID_HANDLE)
			CloseHandle(adminmenu);
		CreateTimer(0.1, RefreshAdminMenu, param1,TIMER_FLAG_NO_MAPCHANGE);
	}
				
	if(action == MenuAction_Cancel)
		g_bMenuOpen[param1] = false;

	if(action == MenuAction_End)
	{
		//test
		if (IsValidClient(param1))
		{
			g_bMenuOpen[param1] = false;
			if (adminmenu != INVALID_HANDLE)
				CloseHandle(adminmenu);
		}
	}
}

//Drop Map from DB
public Action:Admin_DropAllMapRecords(client, args)
{
	db_dropPlayer(client);
	return Plugin_Handled;
}

public Action:Admin_DropChallenges(client, args)
{
	db_dropChallenges(client);
	return Plugin_Handled;
}

public Action:Admin_DropPlayerRanks(client, args)
{
	db_dropPlayerRanks(client);
	return Plugin_Handled;
}

public Action:Admin_DropPlayerJump(client, args)
{	
	db_dropPlayerJump(client);
	return Plugin_Handled;
}

public Action:Admin_ResetAllLjRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET ljrecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "ladder jump records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_LjRank[i] = 99999999;
			g_js_fPersonal_Lj_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllLadderJumpRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET ladderjumprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "ladderjump records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_LadderJumpRank[i] = 99999999;
			g_js_fPersonal_LadderJump_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}


public Action:Admin_ResetAllWjRecords(client, args)
{
	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET wjrecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "wj records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_WjRank[i] = 99999999;
			g_js_fPersonal_Wj_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllCjRecords(client, args)
{
	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET cjrecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "cj records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_CJRank[i] = 99999999;
			g_js_fPersonal_CJ_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllBhopRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET bhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	       
	PrintToConsole(client, "bhop records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_BhopRank[i] = 99999999;
			g_js_fPersonal_Bhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllDropBhopRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET dropbhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	
	PrintToConsole(client, "dropbhop records reseted.");	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_DropBhopRank[i] = 99999999;
			g_js_fPersonal_DropBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllMultiBhopRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET multibhoprecord=-1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	
	PrintToConsole(client, "multibhop records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_MultiBhopRank[i] = 99999999;
			g_js_fPersonal_MultiBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetAllLjBlockRecords(client, args)
{
 	decl String:szQuery[255];      
	Format(szQuery, 255, "UPDATE playerjumpstats3 SET ljblockdist=-1");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);	
	PrintToConsole(client, "ljblock records reseted.");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			g_js_MultiBhopRank[i] = 99999999;
			g_js_fPersonal_MultiBhop_Record[i] = -1.0;
		}
	}
	return Plugin_Handled;
}


public Action:Admin_ResetRecords(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayertimes <steamid> [<mapname>]");
		return Plugin_Handled;
	}
	else 
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		if(args == 5)
		{
			db_resetPlayerRecords(client, szSteamID);
		}
		else if(args == 6)
		{
			decl String:szMapName[128];
			GetCmdArg(6, szMapName, 128);	
			db_resetPlayerRecords2(client, szSteamID, szMapName);
		}
	}
	return Plugin_Handled;
}

public Action:Admin_RefreshProfile(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_refreshprofile <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		RecalcPlayerRank(client, szSteamID);
	}
	return Plugin_Handled;
}


public Action:Admin_ResetRecordTp(client, args)
{
	if(args != 6)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayertptime <steamid> <mapname>");
		return Plugin_Handled;
	}
	else 
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		if(args == 6)
		{
			decl String:szMapName[128];
			GetCmdArg(6, szMapName, 128);	
			db_resetPlayerRecordTp(client, szSteamID, szMapName);
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetRecordPro(client, args)
{
	if(args != 6)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayerprotime <steamid> <mapname>");
		return Plugin_Handled;
	}
	else 
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		if(args == 6)
		{
			decl String:szMapName[128];
			GetCmdArg(6, szMapName, 128);	
			db_resetPlayerRecordPro(client, szSteamID, szMapName);
		}
	}
	return Plugin_Handled;
}

public Action:Admin_ResetChallenges(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayerchallenges <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerResetChallenges(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetMapRecords(client, args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetmaptimes <mapname>");
		return Plugin_Handled;
	}
	if(args == 1)
	{
		decl String:szMapName[128];
		GetCmdArg(1, szMapName, 128);		
		db_resetMapRecords(client, szMapName);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetLadderJumpRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetladderjumprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerLadderJumpRecord(client, szSteamID);
	}
	return Plugin_Handled;
}
public Action:Admin_ResetLjRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetljrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerLjRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetCjRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetcjrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerCjRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetLjBlockRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetljblockrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerLjBlockRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_DeleteProReplay(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetproreplay <mapname>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szMap[128];
		decl String:szArg[128];
		Format(szMap, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szMap, 128, "%s%s",  szMap, szArg); 
		}
		DeleteReplay(client, 0, szMap);
	}
	return Plugin_Handled;
}

public Action:Admin_DeleteTpReplay(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resettpreplay <mapname>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szMap[128];
		decl String:szArg[128];
		Format(szMap, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szMap, 128, "%s%s",  szMap, szArg); 
		}
		DeleteReplay(client, 1, szMap);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetWjRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetwjrecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerWJRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetPlayerJumpstats(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetplayerjumpstats <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerJumpstats(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetDropBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetdropbhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerDropBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}


public Action:Admin_ResetBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetbhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetMultiBhopRecords(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[KZ] Usage: sm_resetmultibhoprecord <steamid>");
		return Plugin_Handled;
	}
	if(args > 0)
	{
		decl String:szSteamID[128];
		decl String:szArg[128];
		Format(szSteamID, 128, "");
		for (new i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s",  szSteamID, szArg); 
		}
		db_resetPlayerMultiBhopRecord(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action:Admin_ResetExtraPoints(client, args)
{
	SQL_TQuery(g_hDb, sql_selectMutliplierCallback, "UPDATE playerrank SET multiplier ='0'", client);	
	return Plugin_Handled;
}

public sql_selectMutliplierCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{ 
	new client = data;
	PrintToConsole(client, "Extra points for all players reseted.");
}