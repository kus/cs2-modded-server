/*  CS:GO Weapons&Knives SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

void GetPlayerData(int client)
{
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true);
	char query[255];
	FormatEx(query, sizeof(query), "SELECT * FROM %sweapons WHERE steamid = '%s'", g_TablePrefix, steamid);
	db.Query(T_GetPlayerDataCallback, query, GetClientUserId(client));
}

public void T_GetPlayerDataCallback(Database database, DBResultSet results, const char[] error, int userid)
{
	int clientIndex = GetClientOfUserId(userid);
	if(IsValidClient(clientIndex))
	{
		if (results == null)
		{
			LogError("Query failed! %s", error);
		}
		else if (results.RowCount == 0)
		{
			char steamid[32];
			GetClientAuthId(clientIndex, AuthId_Steam2, steamid, sizeof(steamid), true);
			char query[255];
			FormatEx(query, sizeof(query), "INSERT INTO %sweapons (steamid) VALUES ('%s')", g_TablePrefix, steamid);
			DataPack pack = new DataPack();
			pack.WriteString(steamid);
			pack.WriteString(query);
			db.Query(T_InsertCallback, query, pack);
			for(int i = 0; i < sizeof(g_WeaponClasses); i++)
			{
				g_iSkins[clientIndex][i] = 0;
				g_iStatTrak[clientIndex][i] = 0;
				g_iStatTrakCount[clientIndex][i] = 0;
				g_NameTag[clientIndex][i] = "";
				g_fFloatValue[clientIndex][i] = 0.0;
			}
			g_iKnife[clientIndex] = 0;
		}
		else
		{
			if(results.FetchRow())
			{
				for(int i = 2, j = 0; j < sizeof(g_WeaponClasses); i += 5, j++) 
				{
					g_iSkins[clientIndex][j] = results.FetchInt(i);
					g_fFloatValue[clientIndex][j] = results.FetchFloat(i + 1);
					g_iStatTrak[clientIndex][j] = results.FetchInt(i + 2);
					g_iStatTrakCount[clientIndex][j] = results.FetchInt(i + 3);
					results.FetchString(i + 4, g_NameTag[clientIndex][j], 128);
				}
				g_iKnife[clientIndex] = results.FetchInt(1);
			}
			char steamid[32];
			GetClientAuthId(clientIndex, AuthId_Steam2, steamid, sizeof(steamid), true);
			char query[255];
			FormatEx(query, sizeof(query), "REPLACE INTO %sweapons_timestamps (steamid, last_seen) VALUES ('%s', %d)", g_TablePrefix, steamid, GetTime());
			DataPack pack = new DataPack();
			pack.WriteString(query);
			db.Query(T_TimestampCallback, query, pack);
		}
	}
}

public void T_InsertCallback(Database database, DBResultSet results, const char[] error, DataPack pack)
{
	pack.Reset();
	char steamid[32];
	pack.ReadString(steamid, 32);
	if (results == null)
	{
		char buffer[1024];
		pack.ReadString(buffer, 1024);
		LogError("Insert Query failed! query: \"%s\" error: \"%s\"", buffer, error);
	}
	else
	{
		char query[255];
		FormatEx(query, sizeof(query), "REPLACE INTO %sweapons_timestamps (steamid, last_seen) VALUES ('%s', %d)", g_TablePrefix, steamid, GetTime());
		DataPack newPack = new DataPack();
		newPack.WriteString(query);
		db.Query(T_TimestampCallback, query, newPack);
	}
	CloseHandle(pack);
}

public void T_TimestampCallback(Database database, DBResultSet results, const char[] error, DataPack pack)
{
	if (results == null)
	{
		pack.Reset();
		char buffer[1024];
		pack.ReadString(buffer, 1024);
		LogError("Timestamp Query failed! query: \"%s\" error: \"%s\"", buffer, error);
	}
	CloseHandle(pack);
}

void UpdatePlayerData(int client, char[] updateFields)
{
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true);
	char query[1024];
	FormatEx(query, sizeof(query), "UPDATE %sweapons SET %s WHERE steamid = '%s'", g_TablePrefix, updateFields, steamid);
	DataPack pack = new DataPack();
	pack.WriteString(query);
	db.Query(T_UpdatePlayerDataCallback, query, pack);
}

public void T_UpdatePlayerDataCallback(Database database, DBResultSet results, const char[] error, DataPack pack)
{
	if (results == null)
	{
		pack.Reset();
		char buffer[1024];
		pack.ReadString(buffer, 1024);
		LogError("Update Player failed! query: \"%s\" error: \"%s\"", buffer, error);
	}
	CloseHandle(pack);
}

public void SQLConnectCallback(Database database, const char[] error, any data)
{
	if (database == null)
	{
		LogError("Database failure: %s", error);
	}
	else
	{
		db = database;
		char createQuery[20480];
		char dbIdentifier[10];
		
		int index = 0;

		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			CREATE TABLE IF NOT EXISTS %sweapons (								\
				steamid varchar(32) NOT NULL PRIMARY KEY, 						\
				knife int(4) NOT NULL DEFAULT '0', 								\
				awp int(4) NOT NULL DEFAULT '0', 								\
				awp_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
				awp_trak int(1) NOT NULL DEFAULT '0', 							\
				awp_trak_count int(10) NOT NULL DEFAULT '0', 					\
				awp_tag varchar(256) NOT NULL DEFAULT '', 						\
				ak47 int(4) NOT NULL DEFAULT '0', 								\
				ak47_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				ak47_trak int(1) NOT NULL DEFAULT '0', 							\
				ak47_trak_count int(10) NOT NULL DEFAULT '0', 					\
				ak47_tag varchar(256) NOT NULL DEFAULT '', 						\
				m4a1 int(4) NOT NULL DEFAULT '0', 								\
				m4a1_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				m4a1_trak int(1) NOT NULL DEFAULT '0', 							\
				m4a1_trak_count int(10) NOT NULL DEFAULT '0', 					\
				m4a1_tag varchar(256) NOT NULL DEFAULT '', ", g_TablePrefix);
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				m4a1_silencer int(4) NOT NULL DEFAULT '0', 						\
				m4a1_silencer_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
				m4a1_silencer_trak int(1) NOT NULL DEFAULT '0', 				\
				m4a1_silencer_trak_count int(10) NOT NULL DEFAULT '0', 			\
				m4a1_silencer_tag varchar(256) NOT NULL DEFAULT '', 			\
				deagle int(4) NOT NULL DEFAULT '0', 							\
				deagle_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				deagle_trak int(1) NOT NULL DEFAULT '0', 						\
				deagle_trak_count int(10) NOT NULL DEFAULT '0', 				\
				deagle_tag varchar(256) NOT NULL DEFAULT '', 					\
				usp_silencer int(4) NOT NULL DEFAULT '0', 						\
				usp_silencer_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
				usp_silencer_trak int(1) NOT NULL DEFAULT '0', 					\
				usp_silencer_trak_count int(10) NOT NULL DEFAULT '0', 			\
				usp_silencer_tag varchar(256) NOT NULL DEFAULT '', 				\
				hkp2000 int(4) NOT NULL DEFAULT '0', 							\
				hkp2000_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				hkp2000_trak int(1) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				hkp2000_trak_count int(10) NOT NULL DEFAULT '0', 				\
				hkp2000_tag varchar(256) NOT NULL DEFAULT '', 					\
				glock int(4) NOT NULL DEFAULT '0', 								\
				glock_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				glock_trak int(1) NOT NULL DEFAULT '0', 						\
				glock_trak_count int(10) NOT NULL DEFAULT '0', 					\
				glock_tag varchar(256) NOT NULL DEFAULT '', 					\
				elite int(4) NOT NULL DEFAULT '0', 								\
				elite_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				elite_trak int(1) NOT NULL DEFAULT '0', 						\
				elite_trak_count int(10) NOT NULL DEFAULT '0', 					\
				elite_tag varchar(256) NOT NULL DEFAULT '', 					\
				p250 int(4) NOT NULL DEFAULT '0', 								\
				p250_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				p250_trak int(1) NOT NULL DEFAULT '0', 							\
				p250_trak_count int(10) NOT NULL DEFAULT '0', 					\
				p250_tag varchar(256) NOT NULL DEFAULT '', 						\
				cz75a int(4) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				cz75a_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				cz75a_trak int(1) NOT NULL DEFAULT '0', 						\
				cz75a_trak_count int(10) NOT NULL DEFAULT '0', 					\
				cz75a_tag varchar(256) NOT NULL DEFAULT '', 					\
				fiveseven int(4) NOT NULL DEFAULT '0', 							\
				fiveseven_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
				fiveseven_trak int(1) NOT NULL DEFAULT '0', 					\
				fiveseven_trak_count int(10) NOT NULL DEFAULT '0', 				\
				fiveseven_tag varchar(256) NOT NULL DEFAULT '', 				\
				tec9 int(4) NOT NULL DEFAULT '0', 								\
				tec9_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				tec9_trak int(1) NOT NULL DEFAULT '0', 							\
				tec9_trak_count int(10) NOT NULL DEFAULT '0', 					\
				tec9_tag varchar(256) NOT NULL DEFAULT '', 						\
				revolver int(4) NOT NULL DEFAULT '0', 							\
				revolver_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
				revolver_trak int(1) NOT NULL DEFAULT '0', 						\
				revolver_trak_count int(10) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				revolver_tag varchar(256) NOT NULL DEFAULT '', 					\
				nova int(4) NOT NULL DEFAULT '0', 								\
				nova_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				nova_trak int(1) NOT NULL DEFAULT '0', 							\
				nova_trak_count int(10) NOT NULL DEFAULT '0', 					\
				nova_tag varchar(256) NOT NULL DEFAULT '', 						\
				xm1014 int(4) NOT NULL DEFAULT '0', 							\
				xm1014_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				xm1014_trak int(1) NOT NULL DEFAULT '0', 						\
				xm1014_trak_count int(10) NOT NULL DEFAULT '0', 				\
				xm1014_tag varchar(256) NOT NULL DEFAULT '', 					\
				mag7 int(4) NOT NULL DEFAULT '0', 								\
				mag7_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				mag7_trak int(1) NOT NULL DEFAULT '0', 							\
				mag7_trak_count int(10) NOT NULL DEFAULT '0', 					\
				mag7_tag varchar(256) NOT NULL DEFAULT '', 						\
				sawedoff int(4) NOT NULL DEFAULT '0', 							\
				sawedoff_float decimal(3,2) NOT NULL DEFAULT '0.0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				sawedoff_trak int(1) NOT NULL DEFAULT '0', 						\
				sawedoff_trak_count int(10) NOT NULL DEFAULT '0', 				\
				sawedoff_tag varchar(256) NOT NULL DEFAULT '', 					\
				m249 int(4) NOT NULL DEFAULT '0', 								\
				m249_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				m249_trak int(1) NOT NULL DEFAULT '0', 							\
				m249_trak_count int(10) NOT NULL DEFAULT '0', 					\
				m249_tag varchar(256) NOT NULL DEFAULT '', 						\
				negev int(4) NOT NULL DEFAULT '0', 								\
				negev_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				negev_trak int(1) NOT NULL DEFAULT '0', 						\
				negev_trak_count int(10) NOT NULL DEFAULT '0', 					\
				negev_tag varchar(256) NOT NULL DEFAULT '', 					\
				mp9 int(4) NOT NULL DEFAULT '0', 								\
				mp9_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
				mp9_trak int(1) NOT NULL DEFAULT '0', 							\
				mp9_trak_count int(10) NOT NULL DEFAULT '0', 					\
				mp9_tag varchar(256) NOT NULL DEFAULT '', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				mac10 int(4) NOT NULL DEFAULT '0', 								\
				mac10_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				mac10_trak int(1) NOT NULL DEFAULT '0', 						\
				mac10_trak_count int(10) NOT NULL DEFAULT '0', 					\
				mac10_tag varchar(256) NOT NULL DEFAULT '', 					\
				mp7 int(4) NOT NULL DEFAULT '0', 								\
				mp7_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
				mp7_trak int(1) NOT NULL DEFAULT '0', 							\
				mp7_trak_count int(10) NOT NULL DEFAULT '0', 					\
				mp7_tag varchar(256) NOT NULL DEFAULT '', 						\
				ump45 int(4) NOT NULL DEFAULT '0', 								\
				ump45_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				ump45_trak int(1) NOT NULL DEFAULT '0', 						\
				ump45_trak_count int(10) NOT NULL DEFAULT '0', 					\
				ump45_tag varchar(256) NOT NULL DEFAULT '', 					\
				p90 int(4) NOT NULL DEFAULT '0', 								\
				p90_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
				p90_trak int(1) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				p90_trak_count int(10) NOT NULL DEFAULT '0', 					\
				p90_tag varchar(256) NOT NULL DEFAULT '', 						\
				bizon int(4) NOT NULL DEFAULT '0', 								\
				bizon_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				bizon_trak int(1) NOT NULL DEFAULT '0', 						\
				bizon_trak_count int(10) NOT NULL DEFAULT '0', 					\
				bizon_tag varchar(256) NOT NULL DEFAULT '', 					\
				famas int(4) NOT NULL DEFAULT '0', 								\
				famas_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				famas_trak int(1) NOT NULL DEFAULT '0', 						\
				famas_trak_count int(10) NOT NULL DEFAULT '0', 					\
				famas_tag varchar(256) NOT NULL DEFAULT '', 					\
				galilar int(4) NOT NULL DEFAULT '0', 							\
				galilar_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				galilar_trak int(1) NOT NULL DEFAULT '0', 						\
				galilar_trak_count int(10) NOT NULL DEFAULT '0', 				\
				galilar_tag varchar(256) NOT NULL DEFAULT '', 					\
				ssg08 int(4) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				ssg08_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				ssg08_trak int(1) NOT NULL DEFAULT '0', 						\
				ssg08_trak_count int(10) NOT NULL DEFAULT '0', 					\
				ssg08_tag varchar(256) NOT NULL DEFAULT '', 					\
				aug int(4) NOT NULL DEFAULT '0', 								\
				aug_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
				aug_trak int(1) NOT NULL DEFAULT '0', 							\
				aug_trak_count int(10) NOT NULL DEFAULT '0', 					\
				aug_tag varchar(256) NOT NULL DEFAULT '', 						\
				sg556 int(4) NOT NULL DEFAULT '0', 								\
				sg556_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				sg556_trak int(1) NOT NULL DEFAULT '0', 						\
				sg556_trak_count int(10) NOT NULL DEFAULT '0', 					\
				sg556_tag varchar(256) NOT NULL DEFAULT '', 					\
				scar20 int(4) NOT NULL DEFAULT '0', 							\
				scar20_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				scar20_trak int(1) NOT NULL DEFAULT '0', 						\
				scar20_trak_count int(10) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				scar20_tag varchar(256) NOT NULL DEFAULT '', 					\
				g3sg1 int(4) NOT NULL DEFAULT '0', 								\
				g3sg1_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
				g3sg1_trak int(1) NOT NULL DEFAULT '0', 						\
				g3sg1_trak_count int(10) NOT NULL DEFAULT '0', 					\
				g3sg1_tag varchar(256) NOT NULL DEFAULT '', 					\
				knife_karambit int(4) NOT NULL DEFAULT '0', 					\
				knife_karambit_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
				knife_karambit_trak int(1) NOT NULL DEFAULT '0', 				\
				knife_karambit_trak_count int(10) NOT NULL DEFAULT '0', 		\
				knife_karambit_tag varchar(256) NOT NULL DEFAULT '', 			\
				knife_m9_bayonet int(4) NOT NULL DEFAULT '0', 					\
				knife_m9_bayonet_float decimal(3,2) NOT NULL DEFAULT '0.0', 	\
				knife_m9_bayonet_trak int(1) NOT NULL DEFAULT '0', 				\
				knife_m9_bayonet_trak_count int(10) NOT NULL DEFAULT '0', 		\
				knife_m9_bayonet_tag varchar(256) NOT NULL DEFAULT '', 			\
				bayonet int(4) NOT NULL DEFAULT '0', 							\
				bayonet_float decimal(3,2) NOT NULL DEFAULT '0.0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				bayonet_trak int(1) NOT NULL DEFAULT '0', 						\
				bayonet_trak_count int(10) NOT NULL DEFAULT '0', 				\
				bayonet_tag varchar(256) NOT NULL DEFAULT '', 					\
				knife_survival_bowie int(4) NOT NULL DEFAULT '0', 				\
				knife_survival_bowie_float decimal(3,2) NOT NULL DEFAULT '0.0', \
				knife_survival_bowie_trak int(1) NOT NULL DEFAULT '0', 			\
				knife_survival_bowie_trak_count int(10) NOT NULL DEFAULT '0', 	\
				knife_survival_bowie_tag varchar(256) NOT NULL DEFAULT '', 		\
				knife_butterfly int(4) NOT NULL DEFAULT '0', 					\
				knife_butterfly_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
				knife_butterfly_trak int(1) NOT NULL DEFAULT '0', 				\
				knife_butterfly_trak_count int(10) NOT NULL DEFAULT '0', 		\
				knife_butterfly_tag varchar(256) NOT NULL DEFAULT '', 			\
				knife_flip int(4) NOT NULL DEFAULT '0', 						\
				knife_flip_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
				knife_flip_trak int(1) NOT NULL DEFAULT '0', 					\
				knife_flip_trak_count int(10) NOT NULL DEFAULT '0', 			\
				knife_flip_tag varchar(256) NOT NULL DEFAULT '', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				knife_push int(4) NOT NULL DEFAULT '0', 						\
				knife_push_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
				knife_push_trak int(1) NOT NULL DEFAULT '0', 					\
				knife_push_trak_count int(10) NOT NULL DEFAULT '0', 			\
				knife_push_tag varchar(256) NOT NULL DEFAULT '', 				\
				knife_tactical int(4) NOT NULL DEFAULT '0', 					\
				knife_tactical_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
				knife_tactical_trak int(1) NOT NULL DEFAULT '0', 				\
				knife_tactical_trak_count int(10) NOT NULL DEFAULT '0', 		\
				knife_tactical_tag varchar(256) NOT NULL DEFAULT '', 			\
				knife_falchion int(4) NOT NULL DEFAULT '0', 					\
				knife_falchion_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
				knife_falchion_trak int(1) NOT NULL DEFAULT '0', 				\
				knife_falchion_trak_count int(10) NOT NULL DEFAULT '0', 		\
				knife_falchion_tag varchar(256) NOT NULL DEFAULT '', 			\
				knife_gut int(4) NOT NULL DEFAULT '0', 							\
				knife_gut_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
				knife_gut_trak int(1) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				knife_gut_trak_count int(10) NOT NULL DEFAULT '0', 				\
				knife_gut_tag varchar(256) NOT NULL DEFAULT '', 				\
				knife_ursus int(4) NOT NULL DEFAULT '0', 						\
				knife_ursus_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
				knife_ursus_trak int(1) NOT NULL DEFAULT '0', 					\
				knife_ursus_trak_count int(10) NOT NULL DEFAULT '0', 			\
				knife_ursus_tag varchar(256) NOT NULL DEFAULT '', 				\
				knife_gypsy_jackknife int(4) NOT NULL DEFAULT '0', 				\
				knife_gypsy_jackknife_float decimal(3,2) NOT NULL DEFAULT '0.0',\
				knife_gypsy_jackknife_trak int(1) NOT NULL DEFAULT '0', 		\
				knife_gypsy_jackknife_trak_count int(10) NOT NULL DEFAULT '0', 	\
				knife_gypsy_jackknife_tag varchar(256) NOT NULL DEFAULT '', 	\
				knife_stiletto int(4) NOT NULL DEFAULT '0', 					\
				knife_stiletto_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
				knife_stiletto_trak int(1) NOT NULL DEFAULT '0', 				\
				knife_stiletto_trak_count int(10) NOT NULL DEFAULT '0', 		\
				knife_stiletto_tag varchar(256) NOT NULL DEFAULT '', 			\
				knife_widowmaker int(4) NOT NULL DEFAULT '0', ");
		index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
				knife_widowmaker_float decimal(3,2) NOT NULL DEFAULT '0.0', 	\
				knife_widowmaker_trak int(1) NOT NULL DEFAULT '0', 				\
				knife_widowmaker_trak_count int(10) NOT NULL DEFAULT '0', 		\
				knife_widowmaker_tag varchar(256) NOT NULL DEFAULT '', 			\
				mp5sd int(4) NOT NULL DEFAULT '0', 								\
				mp5sd_float decimal(3,2) NOT NULL DEFAULT '0.0',				\
				mp5sd_trak int(1) NOT NULL DEFAULT '0', 						\
				mp5sd_trak_count int(10) NOT NULL DEFAULT '0', 					\
				mp5sd_tag varchar(256) NOT NULL DEFAULT '')");
		
		db.Driver.GetIdentifier(dbIdentifier, sizeof(dbIdentifier));
		bool mysql = StrEqual(dbIdentifier, "mysql");
		if (mysql)
		{
			 index += FormatEx(createQuery[index], sizeof(createQuery) - index, " ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
		}
		
		db.Query(T_CreateMainTableCallback, createQuery, mysql, DBPrio_High);
	}
}

public void T_CreateMainTableCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Create main table failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		AddWeaponColumns("knife_ursus");
		AddWeaponColumns("knife_gypsy_jackknife");
		AddWeaponColumns("knife_stiletto");
		AddWeaponColumns("knife_widowmaker");
		AddWeaponColumns("mp5sd");
		
		char createQuery[512];
		Format(createQuery, sizeof(createQuery), "			\
			CREATE TABLE %sweapons_timestamps ( 			\
				steamid varchar(32) NOT NULL PRIMARY KEY, 	\
				last_seen int(11) NOT NULL)", g_TablePrefix);
		
		if (mysql)
		{
			 Format(createQuery, sizeof(createQuery), "%s ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;", createQuery);
		}
		
		db.Query(T_CreateTimestampTableCallback, createQuery, mysql, DBPrio_High);
	}
}

void AddWeaponColumns(const char[] weapon)
{
	char query[512];
	
	SQL_LockDatabase(db);
	
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s int(4) NOT NULL DEFAULT '0'", g_TablePrefix, weapon);
	SQL_FastQuery(db, query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_float decimal(3,2) NOT NULL DEFAULT '0.0'", g_TablePrefix, weapon);
	SQL_FastQuery(db, query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_trak int(1) NOT NULL DEFAULT '0'", g_TablePrefix, weapon);
	SQL_FastQuery(db, query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_trak_count int(10) NOT NULL DEFAULT '0'", g_TablePrefix, weapon);
	SQL_FastQuery(db, query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_tag varchar(256) NOT NULL DEFAULT ''", g_TablePrefix, weapon);
	SQL_FastQuery(db, query);
	
	SQL_UnlockDatabase(db);
}

public void T_CreateTimestampTableCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogMessage("%s DB connection successful", (mysql ? "MySQL" : "SQLite"));
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				OnClientPutInServer(i);
				if(IsClientAuthorized(i))
				{
					OnClientPostAdminCheck(i);
				}
			}
		}
		DeleteInactivePlayerData();
	}
	else
	{
		char insertQuery[512];
		Format(insertQuery, sizeof(insertQuery), "	\
			INSERT INTO %sweapons_timestamps  		\
				SELECT steamid, %d FROM %sweapons", g_TablePrefix, GetTime(), g_TablePrefix);
		
		db.Query(T_InsertTimestampsCallback, insertQuery, mysql, DBPrio_High);
	}
}

public void T_InsertTimestampsCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Insert timestamps failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		LogMessage("%s DB connection successful", (mysql ? "MySQL" : "SQLite"));
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				OnClientPutInServer(i);
				if(IsClientAuthorized(i))
				{
					OnClientPostAdminCheck(i);
				}
			}
		}
		DeleteInactivePlayerData();
	}
}

void DeleteInactivePlayerData()
{
	if(g_iGraceInactiveDays > 0)
	{
		char query[255];
		int now = GetTime();
		FormatEx(query, sizeof(query), "DELETE FROM %sweapons WHERE steamid in (SELECT steamid FROM %sweapons_timestamps WHERE last_seen < %d - (%d * 86400))", g_TablePrefix, g_TablePrefix, now, g_iGraceInactiveDays);
		DataPack pack = new DataPack();
		pack.WriteCell(now);
		pack.WriteString(query);
		db.Query(T_DeleteInactivePlayerDataCallback, query, pack);
	}
}

public void T_DeleteInactivePlayerDataCallback(Database database, DBResultSet results, const char[] error, DataPack pack)
{
	pack.Reset();
	int now = pack.ReadCell();
	if (results == null)
	{
		char buffer[1024];
		pack.ReadString(buffer, 1024);
		LogError("Delete Inactive Player Data failed! query: \"%s\" error: \"%s\"", buffer, error);
	}
	else
	{
		if(now > 0)
		{
			char query[255];
			FormatEx(query, sizeof(query), "DELETE FROM %sweapons_timestamps WHERE last_seen < %d - (%d * 86400)", g_TablePrefix, now, g_iGraceInactiveDays);
			DataPack newPack = new DataPack();
			newPack.WriteCell(0);
			newPack.WriteString(query);
			db.Query(T_DeleteInactivePlayerDataCallback, query, newPack);
		}
		else
		{
			LogMessage("Inactive players' data has been deleted");
		}
	}
	CloseHandle(pack);
}