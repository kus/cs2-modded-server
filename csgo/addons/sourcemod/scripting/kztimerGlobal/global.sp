new String:sqlglobal_selectPlayers64Pro[] 		= "SELECT runtime, steamid, mapname FROM player64_pro WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer64Pro[] 		= "DELETE FROM player64_pro WHERE steamid = '%s' AND mapname = '%s'";
new String:sqlglobal_selectPlayers102Pro[] 	= "SELECT runtime, steamid, mapname FROM player102_pro WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer102Pro[] 		= "DELETE FROM player102_pro WHERE steamid = '%s' AND mapname = '%s'";
new String:sqlglobal_selectPlayers128Pro[] 	= "SELECT runtime, steamid, mapname FROM player128_pro WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer128Pro[] 		= "DELETE FROM player128_pro WHERE steamid = '%s' AND mapname = '%s'";
new String:sqlglobal_selectPlayers64Tp[] 		= "SELECT runtime, steamid, mapname FROM player64_tp WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer64Tp[] 		= "DELETE FROM player64_tp WHERE steamid = '%s' AND mapname = '%s'";
new String:sqlglobal_selectPlayers102Tp[] 		= "SELECT runtime, steamid, mapname FROM player102_tp WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer102Tp[] 		= "DELETE FROM player102_tp WHERE steamid = '%s' AND mapname = '%s'";
new String:sqlglobal_selectPlayers128Tp[] 		= "SELECT runtime, steamid, mapname FROM player128_tp WHERE mapname = '%s' ORDER BY runtime ASC";
new String:sqlglobal_deletePlayer128Tp[] 		= "DELETE FROM player128_tp WHERE steamid = '%s' AND mapname = '%s'";

//insert time statements
new String:sqlglobal_insertPlayer64Tp[] 		= "INSERT INTO player64_tp (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_insertPlayer102Tp[] 		= "INSERT INTO player102_tp (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_insertPlayer128Tp[] 		= "INSERT INTO player128_tp (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_insertPlayer64Pro[] 		= "INSERT INTO player64_pro (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_insertPlayer102Pro[] 		= "INSERT INTO player102_pro (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";
new String:sqlglobal_insertPlayer128Pro[] 		= "INSERT INTO player128_pro (steamid, mapname, player, runtime, teleports, playercountry, playercountrycode,serverip,servername,servercountry,servercountrycode,date) VALUES('%s', '%s', '%s', '%f', '%i', '%s', '%s', '%s', '%s', '%s', '%s', CURRENT_TIMESTAMP);";

//update time statements
new String:sqlglobal_updatePlayer128Tp[] 		= "UPDATE player128_tp SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';";
new String:sqlglobal_updatePlayer102Tp[] 		= "UPDATE player102_tp SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';";
new String:sqlglobal_updatePlayer64Tp[] 		= "UPDATE player64_tp SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';";
new String:sqlglobal_updatePlayer128Pro[] 		= "UPDATE player128_pro SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';";
new String:sqlglobal_updatePlayer102Pro[] 		= "UPDATE player102_pro SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';";
new String:sqlglobal_updatePlayer64Pro[] 		= "UPDATE player64_pro SET date = CURRENT_TIMESTAMP, player = '%s', runtime = '%f', teleports = '%i', playercountry = '%s', playercountrycode = '%s', serverip = '%s', servername = '%s', servercountry  = '%s', servercountrycode = '%s' WHERE steamid = '%s' AND mapname = '%s';";

//top statements
new String:sqlglobal_selectGlobalTop128[] 		= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player128_tp WHERE mapname = '%s' UNION SELECT player, runtime, teleports, steamid,playercountrycode FROM player128_pro WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop102[] 		= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player102_tp WHERE mapname = '%s' UNION SELECT player, runtime, teleports, steamid,playercountrycode FROM player102_pro WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop64[] 		= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player64_tp WHERE mapname = '%s' UNION SELECT player, runtime, teleports, steamid,playercountrycode FROM player64_pro WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop128Pro[] 	= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player128_pro WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop102Pro[] 	= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player102_pro WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop64Pro[] 	= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player64_pro WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop128Tp[] 	= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player128_tp WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop102Tp[] 	= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player102_tp WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";
new String:sqlglobal_selectGlobalTop64Tp[] 	= "SELECT player, runtime, teleports, steamid,playercountrycode FROM player64_tp WHERE mapname = '%s' ORDER BY runtime ASC LIMIT 20";

//ban statements
new String:sqlglobal_insertBan[] 				= "INSERT INTO banlist_new (steamid, playername, playercountrycode, playerip, reason, stats, serverip, servername, unix_timestamp) VALUES('%s', '%s', '%s', '%s', '%s','%s','%s', '%s', '%i');";
new String:sqlglobal_deleteban1[] 				= "DELETE FROM player64_tp WHERE steamid = '%s'";
new String:sqlglobal_deleteban2[] 				= "DELETE FROM player128_tp WHERE steamid = '%s'";
new String:sqlglobal_deleteban3[] 				= "DELETE FROM player102_tp WHERE steamid = '%s'";
new String:sqlglobal_deleteban4[] 				= "DELETE FROM player64_pro WHERE steamid = '%s'";
new String:sqlglobal_deleteban5[] 				= "DELETE FROM player128_pro WHERE steamid = '%s'";
new String:sqlglobal_deleteban6[] 				= "DELETE FROM player102_pro WHERE steamid = '%s'";

//maplist statements
new String:sqlglobal_selectFilesize[] 			= "SELECT filesize, mapname,validated,Difficulty, Approver  FROM maplist where mapname = '%s'";
new String:sqlglobal_insertFilesize[] 			= "INSERT INTO maplist (mapname, filesize, timestamp) VALUES('%s', '%i', CURRENT_TIMESTAMP);";

//only whitelisted ips get access to the database
ConnectToGlobalDB()
{
	g_global_Access=false;
	new Handle:kv = INVALID_HANDLE;
	kv = CreateKeyValues("");
	KvSetString(kv, "driver", "mysql");
	//KvSetString(kv, "host", "127.0.0.1");
	KvSetString(kv, "host", "global.kztimer.com");
	KvSetString(kv, "port", "3306");
	//KvSetString(kv, "database", "hoc_comp");
	KvSetString(kv, "database", "kztimerglobal");
	KvSetString(kv, "user", "kztimerplugin");
	KvSetString(kv, "pass", "hKCZrdxZfgeXs5wg");


	decl String:szError[255];
	g_hDbGlobal = SQL_ConnectCustom(kv, szError, sizeof(szError), true);

	if (g_hDbGlobal != INVALID_HANDLE)
	{
		SQL_FastQuery(g_hDbGlobal,"SET NAMES 'utf8'");
		g_global_Access=true;
	}
}

public GetGlobalRecord()
{
	decl String:mapPath[256];
	new bool: fileFound;
	GetCurrentMap(g_szMapName, 128);
	Format(mapPath, sizeof(mapPath), "maps/%s.bsp", g_szMapName);
	fileFound = FileExists(mapPath);

	if (fileFound && g_hDbGlobal != INVALID_HANDLE)
	{
		g_global_MapFileSize =  FileSize(mapPath);
		//supported map tags
		if(StrEqual(g_szMapPrefix[0],"kz") || StrEqual(g_szMapPrefix[0],"xc") || StrEqual(g_szMapPrefix[0],"bkz"))
			dbCheckFileSize();
	}
}

public CheckForWorkshopMap()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	if (StrContains(g_szMapPath, "/workshop/", true) != -1)
	{
		Format(g_global_szGlobalMapName,128,"%s",g_szMapName);
		g_global_ValidFileSize = true;
		g_global_IntegratedButtons = true;
		db_GetMapRecord_Global();
	}
}

public Action:Client_Join(client, args)
{
	if (IsValidClient(client))
	{
		PrintToChat(client,"[%cKZ%c]%c Loading html page.. (requires cl_disablehtmlmotd 0)", MOSSGREEN,WHITE,LIMEGREEN);
		ShowMOTDPanel(client, "steamgroup" ,"http://tokyo-lane-2453.pancakeapps.com/Steamgroup.html", 2);
	}
	return Plugin_Handled;
}

public Action:Client_GlobalTop(client, args)
{
	if (IsValidClient(client))
	{
		PrintToChat(client,"[%cKZ%c]%c Loading html page.. (requires cl_disablehtmlmotd 0)", MOSSGREEN,WHITE,LIMEGREEN);
		ShowMOTDPanel(client, "globaltop" ,"http://kuala-lumpur-court-8417.pancakeapps.com/global_index.html", 2);
	}
	return Plugin_Handled;
}

public Action:Client_JumpstatsTop(client, args)
{
	if (!IsValidClient(client))
	{
		return Plugin_Handled;
	}

	else if (!gB_KZTimerAPI)
	{
		PrintToChat(client, "Server is not using API");
		return Plugin_Handled;
	}

	else
	{
		KZTimerAPI_PrintGlobalJumpstatsTopMenu(client);
	}
	return Plugin_Handled;
}

public Action:Client_APIGlobalTop(client, args)
{
	if (!IsValidClient(client))
	{
		return Plugin_Handled;
	}

	else if (!gB_KZTimerAPI)
	{
		PrintToChat(client, "Server is not using API");
		return Plugin_Handled;
	}

	else if (args <= 0)
	{
		KZTimerAPI_PrintGlobalRecordTopMenu(client);
	}
	
	else if (args == 1)
	{
		char mapName[128];
		GetCmdArg(1, mapName, sizeof(mapName));

		KZTimerAPI_PrintGlobalRecordTop(client, mapName);
	}
	
	else if (args == 2)
	{
		char mapName[128];
		char runType[30];
		GetCmdArg(1, mapName, sizeof(mapName));
		GetCmdArg(2, runType, sizeof(runType));

		KZTimerAPI_PrintGlobalRecordTop(client, mapName, runType);
	}
	
	else if (args >= 3)
	{
		char mapName[128];
		char runType[30];
		char tickRate[30];
		GetCmdArg(1, mapName, sizeof(mapName));
		GetCmdArg(2, runType, sizeof(runType));
		GetCmdArg(3, tickRate, sizeof(tickRate));

		KZTimerAPI_PrintGlobalRecordTop(client, mapName, runType, StringToInt(tickRate));
	}
	return Plugin_Handled;
}

//SQL STUFF
public dbGetGlobalBanList()
{
	//clear array
	g_hGlobalBanListArray = CreateArray(32);
	if (g_hDbGlobal == INVALID_HANDLE) return;
	SQL_TQuery(g_hDbGlobal, dbGetGlobalBanListCallback, "SELECT DISTINCT steamid from banlist_new WHERE active='1'");
}

public dbGetGlobalBanListCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE || g_hGlobalBanListArray == INVALID_HANDLE)
		return;
	if(SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			decl String:szAuthID[32];
			SQL_FetchString(hndl, 0, szAuthID, 32);
			new String:idpieces[3][32];
			new lastPiece = ExplodeString(szAuthID, ":", idpieces, sizeof(idpieces), sizeof(idpieces[]));
			Format(szAuthID, sizeof(szAuthID), "%s", idpieces[lastPiece-1]);
			PushArrayString(g_hGlobalBanListArray,szAuthID);
		}
	}
}

public dbCheckFileSize()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[256];
	Format(szQuery, 256, sqlglobal_selectFilesize, g_szMapName);
	SQL_TQuery(g_hDbGlobal, sqlglobal_selectFilesizeCallback, szQuery);
}

public bool IsGlobalMap()
{
	if (g_global_ValidedMap && g_global_IntegratedButtons && !g_global_VersionBlocked && g_global_EntityCheck && !g_global_SelfBuiltButtons && g_hDbGlobal != INVALID_HANDLE && g_bEnforcer && g_global_ValidFileSize && !g_bAutoTimer)
		return true;
	return false;
}

public sqlglobal_selectFilesizeCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	g_global_ValidFileSize=false;
	g_global_ValidedMap=false;
	if (hndl == INVALID_HANDLE)	return;
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new filesize = SQL_FetchInt(hndl, 0);
		if (SQL_FetchInt(hndl, 2) == 1)
		{
			g_global_ValidedMap=true;
		}
		SQL_FetchString(hndl, 3, g_global_szMapDifficulty, 255);
		SQL_FetchString(hndl, 4, g_global_szApprover, 255);

		if (filesize == g_global_MapFileSize)
		{
			g_global_ValidFileSize=true;
			Format(g_global_szGlobalMapName,128,"%s",g_szMapName);
			g_global_IntegratedButtons = true;
			db_GetMapRecord_Global();
		}
		else
			CheckForWorkshopMap();
	}
	else
	{
		if (g_hDbGlobal == INVALID_HANDLE) return;
		SQL_TQuery(g_hDbGlobal, sqlglobal_selectFilesizeCallback2, "SELECT filesize, mapname FROM maplist");
	}
}

public sqlglobal_selectFilesizeCallback2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			new filesize = SQL_FetchInt(hndl, 0);
			if (filesize == g_global_MapFileSize)
			{
				SQL_FetchString(hndl, 1, g_global_szGlobalMapName, 128);
				g_global_ValidFileSize=true;
				g_global_IntegratedButtons=true;
				db_GetMapRecord_Global();
				return;
			}
		}

		//does the map contains a func_button?
		new String:classname[32];
		for (new i; i < GetEntityCount(); i++)
		{
			if (IsValidEdict(i) && GetEntityClassname(i, classname, 32) && (StrContains(classname, "player") == -1) && (StrContains(classname, "weapon") == -1) && (StrContains(classname, "predicted_viewmodel") == -1))
			{
				//its not possible to search for the targetname climb_startbutton/climb_endbutton because those func_buttons are not listed on a few maps .. dunno why
				if(StrEqual(classname, "func_button"))
				{
					g_global_IntegratedButtons=true;
					Format(g_global_szGlobalMapName,128,"%s",g_szMapName);
					dbInsertGlobalMap();
					break;
				}
			}
			new x = i+1;
			if (x == GetEntityCount())
				g_global_IntegratedButtons=false;
		}
	}
}

public dbInsertGlobalMap()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[256];
	Format(szQuery, 256, sqlglobal_insertFilesize, g_global_szGlobalMapName,g_global_MapFileSize);
	SQL_TQuery(g_hDbGlobal, sqlglobal_insertFilesizeCallback, szQuery);
}

public db_MapTierCheck()
{
	if (g_hDbGlobal == INVALID_HANDLE)
		return;

	decl String:mapname[128];
    GetCurrentMap(mapname, sizeof(mapname));

    new String:Pieces[6][128];
	new lastPiece = ExplodeString(mapname, "/", Pieces, sizeof(Pieces), sizeof(Pieces[]));
	Format(mapname, sizeof(mapname), "%s", Pieces[lastPiece-1]);

	decl String:szQuery[1024];
	FormatEx(szQuery, 1024, "SELECT difficulty_id FROM maplist WHERE mapname = '%s'", mapname);
	SQL_TQuery(g_hDbGlobal, db_GetMapTierCallback, szQuery, DBPrio_Low);
}

public db_GetMapTierCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    if (hndl == null)
        return;

		if (SQL_GetRowCount(hndl) && SQL_FetchRow(hndl))
			g_global_maptier = SQL_FetchInt(hndl, 0);  // this would return map tier

    return;
}

public db_VersionCheck()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	g_global_VersionBlocked = false;
	decl String:szQuery[128];
	Format(szQuery, 128, "select version, min_version, filesize from version");
	SQL_TQuery(g_hDbGlobal, sqlglobal_VersionCheckCallback, szQuery);
}

public sqlglobal_VersionCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, g_global_szLatestGlobalVersion, 32);
			new version = SQL_FetchInt(hndl, 1);
			if (PLUGIN_VERSION < version)
			{
				if (version == 999)
					g_global_Disabled=true;
				else
					g_global_Disabled=false;
				g_global_VersionBlocked = true;
			}
		}
	}
}

public db_InsertBan(String:szSteamId[32], String:szName[64], String:szCountryCode[16], String:szIP[128], String:szReason[256], String:szStats[256])
{
	if (g_hDbGlobal == INVALID_HANDLE)
		return;

	decl String:szQuery[1024];
	ReplaceChar("'", "`", g_szServerName);
	new UnixTimestamp;
	UnixTimestamp = GetTime();
	Format(szQuery, 1024, sqlglobal_insertBan, szSteamId, szName, szCountryCode, szIP, szReason, szStats, g_szServerIp, g_szServerName, UnixTimestamp);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	Format(szQuery, 1024, sqlglobal_deleteban1, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	Format(szQuery, 1024, sqlglobal_deleteban2, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	Format(szQuery, 1024, sqlglobal_deleteban3, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	Format(szQuery, 1024, sqlglobal_deleteban4, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	Format(szQuery, 1024, sqlglobal_deleteban5, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	Format(szQuery, 1024, sqlglobal_deleteban6, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
	if (g_hGlobalBanListArray != INVALID_HANDLE)
		PushArrayString(g_hGlobalBanListArray,szSteamId)
}

public sqlglobal_insertFilesizeCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	g_global_ValidFileSize=true;
	db_GetMapRecord_Global();
}

public db_deleteInvalidGlobalEntries()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[255];
	decl String:szQuery2[255];

	if (g_Server_Tickrate==64)
	{
		Format(szQuery, 255, sqlglobal_selectPlayers64Tp, g_global_szGlobalMapName);
		Format(szQuery2, 255, sqlglobal_selectPlayers64Pro, g_global_szGlobalMapName);
	}
	if (g_Server_Tickrate==102)
	{
		Format(szQuery, 255, sqlglobal_selectPlayers102Tp, g_global_szGlobalMapName);
		Format(szQuery2, 255, sqlglobal_selectPlayers102Pro, g_global_szGlobalMapName);
	}
	if (g_Server_Tickrate==128)
	{
		Format(szQuery, 255, sqlglobal_selectPlayers128Tp, g_global_szGlobalMapName);
		Format(szQuery2, 255, sqlglobal_selectPlayers128Pro, g_global_szGlobalMapName);
	}

	SQL_TQuery(g_hDbGlobal, sqlglobal_removeinvalidtimes_tp, szQuery,DBPrio_Low);
	SQL_TQuery(g_hDbGlobal, sqlglobal_removeinvalidtimes_pro, szQuery2,DBPrio_Low);
}

public sqlglobal_removeinvalidtimes_tp(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szQuery[255];
	decl String:szMapname[64];
	decl String:szSteamid[32];
	new i=1;
	if(SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			if (i>20)
			{
				SQL_FetchString(hndl, 1, szSteamid, 32);
				SQL_FetchString(hndl, 2, szMapname, 64);
				if (g_Server_Tickrate==64)
					Format(szQuery, 255, sqlglobal_deletePlayer64Tp, szSteamid,szMapname);
				if (g_Server_Tickrate==128)
					Format(szQuery, 255, sqlglobal_deletePlayer128Tp, szSteamid,szMapname);
				if (g_Server_Tickrate==102)
					Format(szQuery, 255, sqlglobal_deletePlayer102Tp, szSteamid,szMapname);
				SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
			}
			i++;
		}
	}
}

public sqlglobal_removeinvalidtimes_pro(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	decl String:szQuery[255];
	decl String:szMapname[64];
	decl String:szSteamid[32];
	new i=1;
	if(SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			if (i>20)
			{
				SQL_FetchString(hndl, 1, szSteamid, 32);
				SQL_FetchString(hndl, 2, szMapname, 64);
				if (g_Server_Tickrate==64)
					Format(szQuery, 255, sqlglobal_deletePlayer64Pro, szSteamid,szMapname);
				if (g_Server_Tickrate==128)
					Format(szQuery, 255, sqlglobal_deletePlayer128Pro, szSteamid,szMapname);
				if (g_Server_Tickrate==102)
					Format(szQuery, 255, sqlglobal_deletePlayer102Pro, szSteamid,szMapname);
				SQL_TQuery(g_hDbGlobal, SQL_CheckCallback, szQuery);
			}
			i++;
		}
	}
}

public db_GetMapRecord_Global()
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[512];

	switch(g_Server_Tickrate)
	{
		case 64:
		{
			Format(szQuery, 512, sqlglobal_selectGlobalTop64Tp, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobalTpCallback, szQuery);
			Format(szQuery, 512, sqlglobal_selectGlobalTop64Pro, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobalProCallback, szQuery);
		}
		case 102:
		{
			Format(szQuery, 512, sqlglobal_selectGlobalTop102Tp, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobalTpCallback, szQuery);
			Format(szQuery, 512, sqlglobal_selectGlobalTop102Pro, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobalProCallback, szQuery);
		}
		case 128:
		{
			Format(szQuery, 512, sqlglobal_selectGlobalTop128Tp, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobalTpCallback, szQuery);
			Format(szQuery, 512, sqlglobal_selectGlobalTop128Pro, g_global_szGlobalMapName);
			SQL_TQuery(g_hDbGlobal, sql_selectMapRecordGlobalProCallback, szQuery);
		}
	}
}

public sql_selectMapRecordGlobalTpCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			if (SQL_FetchFloat(hndl, 0) > -1.0)
			{
				SQL_FetchString(hndl, 0, g_GlobalRecordTp_Name, MAX_NAME_LENGTH);
				g_fGlobalRecordTp_Time = SQL_FetchFloat(hndl, 1);
			}
			else
				g_fGlobalRecordTp_Time = 9999999.0;
		}
		else
			g_fGlobalRecordTp_Time = 9999999.0;

	}
}

public sql_selectMapRecordGlobalProCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			if (SQL_FetchFloat(hndl, 0) > -1.0)
			{
				SQL_FetchString(hndl, 0, g_GlobalRecordPro_Name, MAX_NAME_LENGTH);
				g_fGlobalRecordPro_Time = SQL_FetchFloat(hndl, 1);
			}
			else
				g_fGlobalRecordPro_Time = 9999999.0;
		}
		else
			g_fGlobalRecordPro_Time = 9999999.0;

	}
}

public db_selectGlobalTopClimbers(client, String:mapname[128], top_type)
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[1024];
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, top_type);
	switch(g_Server_Tickrate)
	{
		case 64:
		{
			switch(top_type)
			{
				case 0: Format(szQuery, 1024, sqlglobal_selectGlobalTop64, mapname,mapname);
				case 1: Format(szQuery, 1024, sqlglobal_selectGlobalTop64Pro, mapname);
				case 2: Format(szQuery, 1024, sqlglobal_selectGlobalTop64Tp, mapname);

			}
		}
		case 102:
		{
			switch(top_type)
			{
				case 0: Format(szQuery, 1024, sqlglobal_selectGlobalTop102, mapname,mapname);
				case 1: Format(szQuery, 1024, sqlglobal_selectGlobalTop102Pro, mapname);
				case 2: Format(szQuery, 1024, sqlglobal_selectGlobalTop102Tp, mapname);

			}
		}
		case 128:
		{
			switch(top_type)
			{
				case 0: Format(szQuery, 1024, sqlglobal_selectGlobalTop128, mapname,mapname);
				case 1:	Format(szQuery, 1024, sqlglobal_selectGlobalTop128Pro, mapname);
				case 2:	Format(szQuery, 1024, sqlglobal_selectGlobalTop128Tp, mapname);
			}
		}
	}
	if (g_hDbGlobal != INVALID_HANDLE)
		SQL_TQuery(g_hDbGlobal, sql_selectGlobalTopClimbersCallback, szQuery, pack,DBPrio_High);
}
public sql_selectGlobalTopClimbersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	decl String:mapname[128];
	ReadPackString(pack, mapname, 128);
	new top_type = ReadPackCell(pack);
	CloseHandle(pack);
	if (g_hDbGlobal == INVALID_HANDLE) return;
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl))
		{
			decl String:szValue[128];
			decl String:szName[MAX_NAME_LENGTH];
			decl String:szSteamid[32];
			decl String:szCountry[64];
			decl String:szTeleports[32];
			new Float:time;
			new teleports;
			new Handle:menu = CreateMenu(GlobalMapMenuHandler);
			SetMenuPagination(menu, 5);
			decl String:title[512];
			switch(top_type)
			{
				case 0: Format(title, 512, "Top 20 (Overall) Global Times on %s (Tickrate %i)\nType !globaltop in chat for more information\n                Time            TP's      Player", mapname,g_Server_Tickrate);
				case 1: Format(title, 512, "Top 20 (Pro) Global Times on %s (Tickrate %i)\nType !globaltop in chat for more information\n                Time            TP's      Player", mapname,g_Server_Tickrate);
				case 2: Format(title, 512, "Top 20 (TP) Global Times on %s (Tickrate %i)\nType !globaltop in chat for more information\n                Time            TP's      Player", mapname,g_Server_Tickrate);

			}
			SetMenuTitle(menu, title);
			new i=1;
			while (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
				time = SQL_FetchFloat(hndl, 1);
				teleports = SQL_FetchInt(hndl, 2);
				SQL_FetchString(hndl, 3, szSteamid, 32);
				SQL_FetchString(hndl, 4, szCountry, 64);
				if (teleports < 10)
					Format(szTeleports, 32, "    %i",teleports);
					else
				if (teleports < 100)
					Format(szTeleports, 32, "  %i",teleports);
				else
					Format(szTeleports, 32, "%i",teleports);

				decl String:szTime[32];
				FormatTimeFloat(client, time, 3,szTime,32);
				if (time<3600.0)
					Format(szTime, 32, "   %s", szTime);

				if (i >= 10)
						Format(szValue, 128, "[%i.] %s  |  %s    » %s (%s)", i, szTime, szTeleports, szName, szCountry);
				else
					Format(szValue, 128, "[0%i.] %s  |  %s    » %s (%s)", i, szTime, szTeleports, szName, szCountry);
				AddMenuItem(menu, szValue, szValue, ITEMDRAW_DEFAULT);
				i++;
			}
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			if (i == 1 && IsValidClient(client))
			{
				switch(top_type)
				{
					case 0: PrintToChat(client, "[%cKZ%c] No global records (overall) found. (Tickrate %i, Map: %s)", MOSSGREEN,WHITE, g_Server_Tickrate, mapname);
					case 1: PrintToChat(client, "[%cKZ%c] No global pro records found. (Tickrate %i, Map: %s)", MOSSGREEN,WHITE, g_Server_Tickrate, mapname);
					case 2: PrintToChat(client, "[%cKZ%c] No global tp records found. (Tickrate %i, Map: %s)", MOSSGREEN,WHITE, g_Server_Tickrate, mapname);
				}
			}
		}
	}
}

public db_insertGlobalRecord(client)
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[1024];
	decl String:szSteamId[32];
	decl String:szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
	{
		GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	}
	else
		return;

	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDbGlobal, szUName, szName, MAX_NAME_LENGTH*2+1);
	ReplaceChar("'", "`", g_szServerName);

	if (g_Tp_Final[client]<0)
		g_Tp_Final[client]=0;


	switch(g_Server_Tickrate)
	{
		case 64:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, sqlglobal_insertPlayer64Pro, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
			else
				Format(szQuery, 1024, sqlglobal_insertPlayer64Tp, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
		}
		case 102:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, sqlglobal_insertPlayer102Pro, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
			else
				Format(szQuery, 1024, sqlglobal_insertPlayer102Tp, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
		}
		case 128:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, sqlglobal_insertPlayer128Pro, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
			else
				Format(szQuery, 1024, sqlglobal_insertPlayer128Tp, szSteamId, g_global_szGlobalMapName, szName,g_fFinalTime[client],g_Tp_Final[client], g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode);
		}
	}
	SQL_TQuery(g_hDbGlobal, SQL_GlobalCallback, szQuery,client,DBPrio_Low);

	//update name
	Format(szQuery, 1024, "UPDATE player64_pro SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player102_pro SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player128_pro SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player64_tp SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player102_tp SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player128_tp SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
}

public SQL_GlobalCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	db_deleteInvalidGlobalEntries();
	SQL_GetNewGlobalMapRank(client);
}

public SQL_GetNewGlobalMapRank(client)
{
	decl String:steamid[32];
	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true);
	else
		return;
	decl String:szQuery[1024];
	switch(g_Server_Tickrate)
	{
		case 64:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, "SELECT steamid FROM player64_pro WHERE runtime <= (SELECT runtime FROM player64_pro WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
			else
				Format(szQuery, 1024, "SELECT steamid FROM player64_tp WHERE runtime <= (SELECT runtime FROM player64_tp WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
		}
		case 102:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, "SELECT steamid FROM player102_pro WHERE runtime <= (SELECT runtime FROM player102_pro WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
			else
				Format(szQuery, 1024, "SELECT steamid FROM player102_tp WHERE runtime <= (SELECT runtime FROM player102_tp WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
		}
		case 128:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, "SELECT steamid FROM player128_pro WHERE runtime <= (SELECT runtime FROM player128_pro WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
			else
				Format(szQuery, 1024, "SELECT steamid FROM player128_tp WHERE runtime <= (SELECT runtime FROM player128_tp WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
		}
	}
	if (g_Tp_Final[client] == 0)
		SQL_TQuery(g_hDbGlobal, db_SQL_GetNewGlobalMapRankProCallback, szQuery, client,DBPrio_Low);
	else
		SQL_TQuery(g_hDbGlobal, db_SQL_GetNewGlobalMapRankTpCallback, szQuery, client,DBPrio_Low);
}



public db_SQL_GetNewGlobalMapRankProCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE) return;
	new client = data;
	if (!IsValidClient(client)) return;
	decl String:szName[128];
	GetClientName(client, szName, 128);
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new rank =  SQL_GetRowCount(hndl);
		if (g_global_maprank_pro[client] == -1 || g_global_maprank_pro[client] > rank)
		{
			new Handle:pack;
			CreateDataTimer(3.0, NewGlobalRankTimer, pack,TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, rank);
			WritePackString(pack, szName);
			WritePackString(pack, g_global_szGlobalMapName);
			WritePackString(pack, g_szFinalTime[client]);
			WritePackCell(pack, g_Tp_Final[client]);
		}
		g_global_maprank_pro[client] = rank;
	}
}

public db_SQL_GetNewGlobalMapRankTpCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE) return;
	new client = data;
	if (!IsValidClient(client)) return;
	decl String:szName[128];
	GetClientName(client, szName, 128);
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		new rank =  SQL_GetRowCount(hndl);
		if (g_global_maprank_tp[client] == -1 || g_global_maprank_tp[client] > rank)
		{
			new Handle:pack;
			CreateDataTimer(3.0, NewGlobalRankTimer, pack,TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, rank);
			WritePackString(pack, szName);
			WritePackString(pack, g_global_szGlobalMapName);
			WritePackString(pack, g_szFinalTime[client]);
			WritePackCell(pack, g_Tp_Final[client]);
		}
		g_global_maprank_tp[client] = rank;
	}
}

public Action NewGlobalRankTimer(Handle timer, Handle pack)
{
	if (pack != INVALID_HANDLE)
	{
		decl String:szName[32];
		decl String:szMapName[32];
		decl String:szTime[32];
		ResetPack(pack);
		new rank = ReadPackCell(pack);
		ReadPackString(pack, szName, 32);
		ReadPackString(pack, szMapName, 32);
		ReadPackString(pack, szTime, 32);
		new tps = ReadPackCell(pack);
		if (tps<=0)
			PrintToChatAll("%t", "NewGlobalMapRankPro",DARKRED,WHITE,YELLOW,szName,rank,szMapName,szTime,g_Server_Tickrate);
		else
			PrintToChatAll("%t", "NewGlobalMapRankTp",DARKRED,WHITE,YELLOW,szName,rank,szMapName,szTime,tps, g_Server_Tickrate);
	}
}

public db_updateGlobalRecord(client)
{
	if (g_hDbGlobal == INVALID_HANDLE) return;
	decl String:szQuery[1024];
	decl String:szSteamId[32];
	decl String:szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
	{
		GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	}
	else
		return;

	decl String:szName[MAX_NAME_LENGTH*2+1];
	SQL_QuoteString(g_hDbGlobal, szUName, szName, MAX_NAME_LENGTH*2+1);
	ReplaceChar("'", "`", g_szServerName);

	if (g_Tp_Final[client]<0)
		g_Tp_Final[client]=0;

	switch(g_Server_Tickrate)
	{
		case 64:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, sqlglobal_updatePlayer64Pro, szName,g_fFinalTime[client],g_Tp_Final[client],g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode, szSteamId, g_global_szGlobalMapName);
			else
				Format(szQuery, 1024, sqlglobal_updatePlayer64Tp, szName,g_fFinalTime[client],g_Tp_Final[client],g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode, szSteamId, g_global_szGlobalMapName);
		}
		case 102:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, sqlglobal_updatePlayer102Pro, szName,g_fFinalTime[client],g_Tp_Final[client],g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode, szSteamId, g_global_szGlobalMapName);
			else
				Format(szQuery, 1024, sqlglobal_updatePlayer102Tp, szName,g_fFinalTime[client],g_Tp_Final[client],g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode, szSteamId, g_global_szGlobalMapName);
		}
		case 128:
		{
			if (g_Tp_Final[client] == 0)
				Format(szQuery, 1024, sqlglobal_updatePlayer128Pro, szName,g_fFinalTime[client],g_Tp_Final[client],g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode, szSteamId, g_global_szGlobalMapName);
			else
				Format(szQuery, 1024, sqlglobal_updatePlayer128Tp, szName,g_fFinalTime[client],g_Tp_Final[client],g_szCountry[client],g_szCountryCode[client],g_szServerIp,g_szServerName,g_szServerCountry,g_szServerCountryCode, szSteamId, g_global_szGlobalMapName);

		}
	}
	SQL_TQuery(g_hDbGlobal, SQL_GlobalCallback, szQuery,client,DBPrio_Low);

	//update name
	Format(szQuery, 1024, "UPDATE player64_pro SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player102_pro SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player128_pro SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player64_tp SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player102_tp SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
	Format(szQuery, 1024, "UPDATE player128_tp SET player = '%s' WHERE steamid = '%s'", szName, szSteamId);
	SQL_TQuery(g_hDbGlobal, SQL_CheckCallback,szQuery,DBPrio_Low);
}

public db_GlobalRecord(client)
{
	if (g_hDbGlobal != INVALID_HANDLE)
	{
		decl String:szQuery[1024];
		switch(g_Server_Tickrate)
		{
			case 64:
			{
				if (g_Tp_Final[client] == 0)
					Format(szQuery, 1024, sqlglobal_selectGlobalTop64Pro, g_global_szGlobalMapName);
				else
					Format(szQuery, 1024, sqlglobal_selectGlobalTop64Tp, g_global_szGlobalMapName);
			}
			case 102:
			{
				if (g_Tp_Final[client] == 0)
					Format(szQuery, 1024, sqlglobal_selectGlobalTop102Pro, g_global_szGlobalMapName);
				else
					Format(szQuery, 1024, sqlglobal_selectGlobalTop102Tp, g_global_szGlobalMapName);
			}
			case 128:
			{
				if (g_Tp_Final[client] == 0)
					Format(szQuery, 1024, sqlglobal_selectGlobalTop128Pro, g_global_szGlobalMapName);
				else
					Format(szQuery, 1024, sqlglobal_selectGlobalTop128Tp, g_global_szGlobalMapName);
			}
		}
		SQL_TQuery(g_hDbGlobal, SQL_SelectGlobalPlayersCallback, szQuery, client,DBPrio_Low);
	}
}
public SQL_SelectGlobalPlayersCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	new Float: time;
	decl String:szSteamId[32];
	decl String:szSteamId2[32];
	new counter=0;
	new bool: newtime=false;
	new bool: newpersonalbest=false;


	if (IsValidClient(client))
	{
		GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
		if (hndl == INVALID_HANDLE)
		{
		}
		else
		if(SQL_HasResultSet(hndl))
		{
			while (SQL_FetchRow(hndl))
			{
				time = SQL_FetchFloat(hndl, 1);
				SQL_FetchString(hndl, 3, szSteamId2, 32);
				if (g_fFinalTime[client] < time && (!StrEqual(szSteamId,szSteamId2)))
					newtime=true;
				if (StrEqual(szSteamId,szSteamId2) && g_fFinalTime[client] < time)
					newpersonalbest=true;
				counter++;
			}
			if (newpersonalbest)
			{
				if (StrEqual(g_szCountryCode[client],"??"))
					db_GetPlayerCountry(client,0);
				else
					db_updateGlobalRecord(client);

			}
			else
				if (newtime || counter<20)
				{
					if (StrEqual(g_szCountryCode[client],"??"))
						db_GetPlayerCountry(client,1);
					else
						db_insertGlobalRecord(client);
				}
		}
	}
}

public Action:GetGlobalMapRank_Timer(Handle:timer, any:client)
{
	if (!IsValidClient(client))
		return;
	GetGlobalMapRank(client, g_szSteamID[client])
}

public GetGlobalMapRank(client, String:steamid[32])
{
	g_global_maprank_pro[client] = -1;
	g_global_maprank_tp[client] = -1;
	if (g_hDbGlobal == INVALID_HANDLE)
		return;
	decl String:szQuery[1024];
	decl String:szQuery2[1024];
	if (g_Server_Tickrate==64)
	{
		Format(szQuery, 1024, "SELECT steamid FROM player64_pro WHERE runtime <= (SELECT runtime FROM player64_tp WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
		Format(szQuery2, 1024, "SELECT steamid FROM player64_pro WHERE runtime <= (SELECT runtime FROM player64_pro WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
	}
	if (g_Server_Tickrate==128)
	{
		Format(szQuery, 1024, "SELECT steamid FROM player128_tp WHERE runtime <= (SELECT runtime FROM player128_tp WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
		Format(szQuery2, 1024, "SELECT steamid FROM player128_pro WHERE runtime <= (SELECT runtime FROM player128_pro WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
	}
	if (g_Server_Tickrate==102)
	{
		Format(szQuery, 1024, "SELECT steamid FROM player102_tp WHERE runtime <= (SELECT runtime FROM player102_tp WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
		Format(szQuery2, 1024, "SELECT steamid FROM player102_pro WHERE runtime <= (SELECT runtime FROM player102_pro WHERE steamid = '%s' AND mapname = '%s' AND runtime > -1.0) AND mapname = '%s' AND runtime  > -1.0 ORDER BY runtime;", steamid, g_global_szGlobalMapName, g_global_szGlobalMapName);
	}
	SQL_TQuery(g_hDbGlobal, db_GetGlobalMapRankTpCallback, szQuery, client,DBPrio_Low);
	SQL_TQuery(g_hDbGlobal, db_GetGlobalMapRankProCallback, szQuery2, client,DBPrio_Low);
}

public db_GetGlobalMapRankTpCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (hndl != INVALID_HANDLE)
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
			g_global_maprank_tp[client] = SQL_GetRowCount(hndl);
}

public db_GetGlobalMapRankProCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	if (hndl != INVALID_HANDLE)
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
			g_global_maprank_pro[client] = SQL_GetRowCount(hndl);
}

public db_GetPlayerCountry(client, insert)
{
	if (!IsValidClient(client))
		return;
	decl String:szSteamId[32];
	GetClientAuthId(client, AuthId_Steam2, szSteamId, sizeof(szSteamId), true);
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, insert);

	decl String:szQuery[1024];
	Format(szQuery, 1024, "select playercountry, playercountrycode,date from player128_tp where playercountrycode NOT LIKE '??' and steamid = '%s' UNION select playercountry, playercountrycode,date from player102_tp where playercountrycode NOT LIKE '??' and steamid = '%s' UNION select playercountry, playercountrycode,date from player64_tp where playercountrycode NOT LIKE '??' and steamid = '%s' UNION select playercountry, playercountrycode,date from player128_pro where playercountrycode NOT LIKE '??' and steamid = '%s' UNION select playercountry, playercountrycode,date from player102_pro where playercountrycode NOT LIKE '??' and steamid = '%s' UNION select playercountry, playercountrycode,date from player64_pro where playercountrycode NOT LIKE '??' and steamid = '%s' ORDER BY date DESC LIMIT 1", szSteamId,szSteamId,szSteamId,szSteamId,szSteamId,szSteamId);
	SQL_TQuery(g_hDbGlobal, db_GetPlayerCountryCallback, szQuery,pack);
}


public db_GetPlayerCountryCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new insert = ReadPackCell(pack);

	CloseHandle(pack);
	if (hndl != INVALID_HANDLE)
	{
		if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, g_szCountry[client], 100);
			SQL_FetchString(hndl, 1, g_szCountryCode[client], 16);
			if (insert)
				db_insertGlobalRecord(client);
			else
				db_updateGlobalRecord(client);
		}
		else
		{
			if (insert)
				db_insertGlobalRecord(client);
			else
				db_updateGlobalRecord(client);
		}
	}
}

public GlobalMapMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Cancel || action ==  MenuAction_Select)
	{
		decl String:globalmap[128];
		if (StrEqual(g_szMapTopName[param1],g_szMapName))
			Format(globalmap,128,"%s", g_global_szGlobalMapName);
		else
			Format(globalmap,128,"%s", g_szMapTopName[param1]);
		GlobalTopMenu(param1, globalmap);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

////////////////////////////////////////////////////////
//REAL BHOP BLOCK..
HookTriggerPushes()
{
    // hook trigger_pushes to disable velocity calculation in these, allowing
    // the push to be applied correctly
    new index = -1;
    while ((index = FindEntityByClassname2(index, "trigger_push")) != -1) {
        SDKHook(index, SDKHook_StartTouch, Event_EntityOnStartTouch);
        SDKHook(index, SDKHook_EndTouch, Event_EntityOnEndTouch);
    }
}

FindEntityByClassname2(startEnt, const String:classname[])
{
    /* If startEnt isn't valid shifting it back to the nearest valid one */
    while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;

    return FindEntityByClassname(startEnt, classname);
}

public Event_EntityOnStartTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client)) {
        PlayerInTriggerPush[client] = true;
    }
}

public Event_EntityOnEndTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client)) {
        PlayerInTriggerPush[client] = false;
    }
}

public Action:Client_GlobalCheck(client, args)
{
	if (gB_KZTimerAPI)
	{
		KZTimerAPI_GlobalCheck(client);
	}
	
	if (!g_global_Access)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: This server is not whitelisted.",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	if (g_hDbGlobal == INVALID_HANDLE)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: No connection to the global database.",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	else
		if (g_global_Disabled)
		{
			PrintToChat(client, "[%cKZ%c] %cGlobal Records have been temporarily disabled. For more information visit the KZTimer steam group!",MOSSGREEN,WHITE,RED);
			return Plugin_Handled;
		}
		else
			if(!StrEqual(g_szMapPrefix[0],"kz") && !StrEqual(g_szMapPrefix[0],"xc") && !StrEqual(g_szMapPrefix[0],"bkz")  && !StrEqual(g_szMapPrefix[0],"kzpro"))
			{
				PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Only bkz_, kz_,kzpro_ and xc_ maps supported!",MOSSGREEN,WHITE,RED);
				return Plugin_Handled;
			}
			else
				if (g_global_VersionBlocked)
				{
					PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: This server is running an outdated KZTimer version. Contact an server admin!",MOSSGREEN,WHITE,RED);
					return Plugin_Handled;
				}
				else
					if (g_global_SelfBuiltButtons)
					{
						PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Self-built climb buttons detected. (only built-in buttons supported)",MOSSGREEN,WHITE,RED);
						return Plugin_Handled;
					}
					else
						if (!g_global_IntegratedButtons)
						{
							PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: This map does not provide built-in climb buttons.",MOSSGREEN,WHITE,RED);
							return Plugin_Handled;
						}
						else
							if (!g_bEnforcer)
							{
								PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Server settings enforcer disabled.",MOSSGREEN,WHITE,RED);
								return Plugin_Handled;
							}
							else
								if (!g_global_ValidFileSize && g_global_IntegratedButtons)
								{
									if (g_global_WrongMapVersion)
										PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Wrong map version. (requires latest+offical workshop version)",MOSSGREEN,WHITE,RED);
									else
										PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Filesize of the current map does not match with the stored global filesize. Please upload the latest workshop version on your server!",MOSSGREEN,WHITE,RED);
									return Plugin_Handled;
								}
								else
									if (g_bAutoTimer)
									{
										PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kz_auto_timer enabled.",MOSSGREEN,WHITE,RED);
										return Plugin_Handled;
									}
									else
										if (g_bDoubleDuckCvar)
										{
											PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kz_double_duck is set to 1.",MOSSGREEN,WHITE,RED);
											return Plugin_Handled;
										}
										else
											if (g_bAutoBhop)
											{
												PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: AutoBhop enabled.",MOSSGREEN,WHITE,RED);
												return Plugin_Handled;
											}
											else
												if (!g_global_EntityCheck)
												{
													PrintToChat(client, "[%cKZ%c] %cCustom entities/objects on the current map detected.",MOSSGREEN,WHITE,RED);
													return Plugin_Handled;
												}
												else
												if (!g_global_ValidedMap)
												{
													PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: The current map is not approved by a kztimer map tester!",MOSSGREEN,WHITE,RED);
													return Plugin_Handled;
												}
	PrintToChat(client, "[%cKZ%c] %cGlobal records are enabled.",MOSSGREEN,WHITE,GREEN);
	return Plugin_Handled;
}
