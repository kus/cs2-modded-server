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
	if(GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true))
	{
		char query[255];
		FormatEx(query, sizeof(query), "SELECT * FROM %sweapons WHERE steamid = '%s'", g_TablePrefix, steamid);
		db.Query(T_GetPlayerDataCallback, query, GetClientUserId(client));
	}
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
			if(GetClientAuthId(clientIndex, AuthId_Steam2, steamid, sizeof(steamid), true))
			{
				char query[255];
				FormatEx(query, sizeof(query), "INSERT INTO %sweapons (steamid) VALUES ('%s')", g_TablePrefix, steamid);
				DataPack pack = new DataPack();
				pack.WriteString(steamid);
				pack.WriteString(query);
				db.Query(T_InsertCallback, query, pack);
			}
		}
		else
		{
			if(results.FetchRow())
			{
				for(int i = 2, j = 0; j < sizeof(g_WeaponClasses); i += 6, j++) 
				{
					g_iSkins[clientIndex][j] = results.FetchInt(i);
					g_fFloatValue[clientIndex][j] = results.FetchFloat(i + 1);
					g_iStatTrak[clientIndex][j] = results.FetchInt(i + 2);
					g_iStatTrakCount[clientIndex][j] = results.FetchInt(i + 3);
					results.FetchString(i + 4, g_NameTag[clientIndex][j], 128);
					g_iWeaponSeed[clientIndex][j] = results.FetchInt(i + 5);
				}
				g_iKnife[clientIndex] = results.FetchInt(1);
			}
			char steamid[32];
			if(GetClientAuthId(clientIndex, AuthId_Steam2, steamid, sizeof(steamid), true))
			{
				char query[255];
				FormatEx(query, sizeof(query), "REPLACE INTO %sweapons_timestamps (steamid, last_seen) VALUES ('%s', %d)", g_TablePrefix, steamid, GetTime());
				DataPack pack = new DataPack();
				pack.WriteString(query);
				db.Query(T_TimestampCallback, query, pack);
			}
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
	delete pack;
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
	delete pack;
}

void UpdatePlayerData(int client, char[] updateFields)
{
	char steamid[32];
	if(GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true))
	{
		char query[1024];
		FormatEx(query, sizeof(query), "UPDATE %sweapons SET %s WHERE steamid = '%s'", g_TablePrefix, updateFields, steamid);
		DataPack pack = new DataPack();
		pack.WriteString(query);
		db.Query(T_UpdatePlayerDataCallback, query, pack);
	}
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
	delete pack;
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
		char dbIdentifier[10];
	
		db.Driver.GetIdentifier(dbIdentifier, sizeof(dbIdentifier));
		bool mysql = StrEqual(dbIdentifier, "mysql");
		
		CreateMainTable(mysql);
	}
}

void CreateMainTable(bool mysql, bool recreate = false)
{
	char createQuery[20480];
	
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
			awp_seed int(10) NOT NULL DEFAULT '-1',							\
			ak47 int(4) NOT NULL DEFAULT '0', 								\
			ak47_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			ak47_trak int(1) NOT NULL DEFAULT '0', 							\
			ak47_trak_count int(10) NOT NULL DEFAULT '0', 					\
			ak47_tag varchar(256) NOT NULL DEFAULT '', 						\
			ak47_seed int(10) NOT NULL DEFAULT '-1',						\
			m4a1 int(4) NOT NULL DEFAULT '0', 								\
			m4a1_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			m4a1_trak int(1) NOT NULL DEFAULT '0', 							\
			m4a1_trak_count int(10) NOT NULL DEFAULT '0', 					\
			m4a1_tag varchar(256) NOT NULL DEFAULT '',						\
			m4a1_seed int(10) NOT NULL DEFAULT '-1', ", g_TablePrefix);
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			m4a1_silencer int(4) NOT NULL DEFAULT '0', 						\
			m4a1_silencer_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
			m4a1_silencer_trak int(1) NOT NULL DEFAULT '0', 				\
			m4a1_silencer_trak_count int(10) NOT NULL DEFAULT '0', 			\
			m4a1_silencer_tag varchar(256) NOT NULL DEFAULT '', 			\
			m4a1_silencer_seed int(10) NOT NULL DEFAULT '-1',				\
			deagle int(4) NOT NULL DEFAULT '0', 							\
			deagle_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			deagle_trak int(1) NOT NULL DEFAULT '0', 						\
			deagle_trak_count int(10) NOT NULL DEFAULT '0', 				\
			deagle_tag varchar(256) NOT NULL DEFAULT '', 					\
			deagle_seed int(10) NOT NULL DEFAULT '-1',						\
			usp_silencer int(4) NOT NULL DEFAULT '0', 						\
			usp_silencer_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
			usp_silencer_trak int(1) NOT NULL DEFAULT '0', 					\
			usp_silencer_trak_count int(10) NOT NULL DEFAULT '0', 			\
			usp_silencer_tag varchar(256) NOT NULL DEFAULT '', 				\
			usp_silencer_seed int(10) NOT NULL DEFAULT '-1',				\
			hkp2000 int(4) NOT NULL DEFAULT '0', 							\
			hkp2000_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			hkp2000_trak int(1) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			hkp2000_trak_count int(10) NOT NULL DEFAULT '0', 				\
			hkp2000_tag varchar(256) NOT NULL DEFAULT '', 					\
			hkp2000_seed int(10) NOT NULL DEFAULT '-1',						\
			glock int(4) NOT NULL DEFAULT '0', 								\
			glock_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			glock_trak int(1) NOT NULL DEFAULT '0', 						\
			glock_trak_count int(10) NOT NULL DEFAULT '0', 					\
			glock_tag varchar(256) NOT NULL DEFAULT '', 					\
			glock_seed int(10) NOT NULL DEFAULT '-1',						\
			elite int(4) NOT NULL DEFAULT '0', 								\
			elite_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			elite_trak int(1) NOT NULL DEFAULT '0', 						\
			elite_trak_count int(10) NOT NULL DEFAULT '0', 					\
			elite_tag varchar(256) NOT NULL DEFAULT '', 					\
			elite_seed int(10) NOT NULL DEFAULT '-1',						\
			p250 int(4) NOT NULL DEFAULT '0', 								\
			p250_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			p250_trak int(1) NOT NULL DEFAULT '0', 							\
			p250_trak_count int(10) NOT NULL DEFAULT '0', 					\
			p250_tag varchar(256) NOT NULL DEFAULT '', 						\
			p250_seed int(10) NOT NULL DEFAULT '-1',						\
			cz75a int(4) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			cz75a_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			cz75a_trak int(1) NOT NULL DEFAULT '0', 						\
			cz75a_trak_count int(10) NOT NULL DEFAULT '0', 					\
			cz75a_tag varchar(256) NOT NULL DEFAULT '', 					\
			cz75a_seed int(10) NOT NULL DEFAULT '-1',						\
			fiveseven int(4) NOT NULL DEFAULT '0', 							\
			fiveseven_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
			fiveseven_trak int(1) NOT NULL DEFAULT '0', 					\
			fiveseven_trak_count int(10) NOT NULL DEFAULT '0', 				\
			fiveseven_tag varchar(256) NOT NULL DEFAULT '', 				\
			fiveseven_seed int(10) NOT NULL DEFAULT '-1',					\
			tec9 int(4) NOT NULL DEFAULT '0', 								\
			tec9_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			tec9_trak int(1) NOT NULL DEFAULT '0', 							\
			tec9_trak_count int(10) NOT NULL DEFAULT '0', 					\
			tec9_tag varchar(256) NOT NULL DEFAULT '', 						\
			tec9_seed int(10) NOT NULL DEFAULT '-1',						\
			revolver int(4) NOT NULL DEFAULT '0', 							\
			revolver_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
			revolver_trak int(1) NOT NULL DEFAULT '0', 						\
			revolver_trak_count int(10) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			revolver_tag varchar(256) NOT NULL DEFAULT '', 					\
			revolver_seed int(10) NOT NULL DEFAULT '-1',					\
			nova int(4) NOT NULL DEFAULT '0', 								\
			nova_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			nova_trak int(1) NOT NULL DEFAULT '0', 							\
			nova_trak_count int(10) NOT NULL DEFAULT '0', 					\
			nova_tag varchar(256) NOT NULL DEFAULT '', 						\
			nova_seed int(10) NOT NULL DEFAULT '-1',						\
			xm1014 int(4) NOT NULL DEFAULT '0', 							\
			xm1014_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			xm1014_trak int(1) NOT NULL DEFAULT '0', 						\
			xm1014_trak_count int(10) NOT NULL DEFAULT '0', 				\
			xm1014_tag varchar(256) NOT NULL DEFAULT '', 					\
			xm1014_seed int(10) NOT NULL DEFAULT '-1',						\
			mag7 int(4) NOT NULL DEFAULT '0', 								\
			mag7_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			mag7_trak int(1) NOT NULL DEFAULT '0', 							\
			mag7_trak_count int(10) NOT NULL DEFAULT '0', 					\
			mag7_tag varchar(256) NOT NULL DEFAULT '', 						\
			mag7_seed int(10) NOT NULL DEFAULT '-1',						\
			sawedoff int(4) NOT NULL DEFAULT '0', 							\
			sawedoff_float decimal(3,2) NOT NULL DEFAULT '0.0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			sawedoff_trak int(1) NOT NULL DEFAULT '0', 						\
			sawedoff_trak_count int(10) NOT NULL DEFAULT '0', 				\
			sawedoff_tag varchar(256) NOT NULL DEFAULT '', 					\
			sawedoff_seed int(10) NOT NULL DEFAULT '-1',					\
			m249 int(4) NOT NULL DEFAULT '0', 								\
			m249_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			m249_trak int(1) NOT NULL DEFAULT '0', 							\
			m249_trak_count int(10) NOT NULL DEFAULT '0', 					\
			m249_tag varchar(256) NOT NULL DEFAULT '', 						\
			m249_seed int(10) NOT NULL DEFAULT '-1',						\
			negev int(4) NOT NULL DEFAULT '0', 								\
			negev_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			negev_trak int(1) NOT NULL DEFAULT '0', 						\
			negev_trak_count int(10) NOT NULL DEFAULT '0', 					\
			negev_tag varchar(256) NOT NULL DEFAULT '', 					\
			negev_seed int(10) NOT NULL DEFAULT '-1',						\
			mp9 int(4) NOT NULL DEFAULT '0', 								\
			mp9_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
			mp9_trak int(1) NOT NULL DEFAULT '0', 							\
			mp9_trak_count int(10) NOT NULL DEFAULT '0', 					\
			mp9_tag varchar(256) NOT NULL DEFAULT '',						\
			mp9_seed int(10) NOT NULL DEFAULT '-1', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			mac10 int(4) NOT NULL DEFAULT '0', 								\
			mac10_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			mac10_trak int(1) NOT NULL DEFAULT '0', 						\
			mac10_trak_count int(10) NOT NULL DEFAULT '0', 					\
			mac10_tag varchar(256) NOT NULL DEFAULT '', 					\
			mac10_seed int(10) NOT NULL DEFAULT '-1',						\
			mp7 int(4) NOT NULL DEFAULT '0', 								\
			mp7_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
			mp7_trak int(1) NOT NULL DEFAULT '0', 							\
			mp7_trak_count int(10) NOT NULL DEFAULT '0', 					\
			mp7_tag varchar(256) NOT NULL DEFAULT '', 						\
			mp7_seed int(10) NOT NULL DEFAULT '-1',							\
			ump45 int(4) NOT NULL DEFAULT '0', 								\
			ump45_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			ump45_trak int(1) NOT NULL DEFAULT '0', 						\
			ump45_trak_count int(10) NOT NULL DEFAULT '0', 					\
			ump45_tag varchar(256) NOT NULL DEFAULT '', 					\
			ump45_seed int(10) NOT NULL DEFAULT '-1',						\
			p90 int(4) NOT NULL DEFAULT '0', 								\
			p90_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
			p90_trak int(1) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			p90_trak_count int(10) NOT NULL DEFAULT '0', 					\
			p90_tag varchar(256) NOT NULL DEFAULT '', 						\
			p90_seed int(10) NOT NULL DEFAULT '-1',							\
			bizon int(4) NOT NULL DEFAULT '0', 								\
			bizon_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			bizon_trak int(1) NOT NULL DEFAULT '0', 						\
			bizon_trak_count int(10) NOT NULL DEFAULT '0', 					\
			bizon_tag varchar(256) NOT NULL DEFAULT '', 					\
			bizon_seed int(10) NOT NULL DEFAULT '-1',						\
			famas int(4) NOT NULL DEFAULT '0', 								\
			famas_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			famas_trak int(1) NOT NULL DEFAULT '0', 						\
			famas_trak_count int(10) NOT NULL DEFAULT '0', 					\
			famas_tag varchar(256) NOT NULL DEFAULT '', 					\
			famas_seed int(10) NOT NULL DEFAULT '-1',						\
			galilar int(4) NOT NULL DEFAULT '0', 							\
			galilar_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			galilar_trak int(1) NOT NULL DEFAULT '0', 						\
			galilar_trak_count int(10) NOT NULL DEFAULT '0', 				\
			galilar_tag varchar(256) NOT NULL DEFAULT '', 					\
			galilar_seed int(10) NOT NULL DEFAULT '-1',						\
			ssg08 int(4) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			ssg08_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			ssg08_trak int(1) NOT NULL DEFAULT '0', 						\
			ssg08_trak_count int(10) NOT NULL DEFAULT '0', 					\
			ssg08_tag varchar(256) NOT NULL DEFAULT '', 					\
			ssg08_seed int(10) NOT NULL DEFAULT '-1',						\
			aug int(4) NOT NULL DEFAULT '0', 								\
			aug_float decimal(3,2) NOT NULL DEFAULT '0.0', 					\
			aug_trak int(1) NOT NULL DEFAULT '0', 							\
			aug_trak_count int(10) NOT NULL DEFAULT '0', 					\
			aug_tag varchar(256) NOT NULL DEFAULT '', 						\
			aug_seed int(10) NOT NULL DEFAULT '-1',							\
			sg556 int(4) NOT NULL DEFAULT '0', 								\
			sg556_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			sg556_trak int(1) NOT NULL DEFAULT '0', 						\
			sg556_trak_count int(10) NOT NULL DEFAULT '0', 					\
			sg556_tag varchar(256) NOT NULL DEFAULT '', 					\
			sg556_seed int(10) NOT NULL DEFAULT '-1',						\
			scar20 int(4) NOT NULL DEFAULT '0', 							\
			scar20_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			scar20_trak int(1) NOT NULL DEFAULT '0', 						\
			scar20_trak_count int(10) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			scar20_tag varchar(256) NOT NULL DEFAULT '', 					\
			scar20_seed int(10) NOT NULL DEFAULT '-1',						\
			g3sg1 int(4) NOT NULL DEFAULT '0', 								\
			g3sg1_float decimal(3,2) NOT NULL DEFAULT '0.0', 				\
			g3sg1_trak int(1) NOT NULL DEFAULT '0', 						\
			g3sg1_trak_count int(10) NOT NULL DEFAULT '0', 					\
			g3sg1_tag varchar(256) NOT NULL DEFAULT '', 					\
			g3sg1_seed int(10) NOT NULL DEFAULT '-1',						\
			knife_karambit int(4) NOT NULL DEFAULT '0', 					\
			knife_karambit_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
			knife_karambit_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_karambit_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_karambit_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_karambit_seed int(10) NOT NULL DEFAULT '-1',				\
			knife_m9_bayonet int(4) NOT NULL DEFAULT '0', 					\
			knife_m9_bayonet_float decimal(3,2) NOT NULL DEFAULT '0.0', 	\
			knife_m9_bayonet_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_m9_bayonet_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_m9_bayonet_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_m9_bayonet_seed int(10) NOT NULL DEFAULT '-1',			\
			bayonet int(4) NOT NULL DEFAULT '0', 							\
			bayonet_float decimal(3,2) NOT NULL DEFAULT '0.0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			bayonet_trak int(1) NOT NULL DEFAULT '0', 						\
			bayonet_trak_count int(10) NOT NULL DEFAULT '0', 				\
			bayonet_tag varchar(256) NOT NULL DEFAULT '', 					\
			bayonet_seed int(10) NOT NULL DEFAULT '-1',						\
			knife_survival_bowie int(4) NOT NULL DEFAULT '0', 				\
			knife_survival_bowie_float decimal(3,2) NOT NULL DEFAULT '0.0', \
			knife_survival_bowie_trak int(1) NOT NULL DEFAULT '0', 			\
			knife_survival_bowie_trak_count int(10) NOT NULL DEFAULT '0', 	\
			knife_survival_bowie_tag varchar(256) NOT NULL DEFAULT '', 		\
			knife_survival_bowie_seed int(10) NOT NULL DEFAULT '-1',		\
			knife_butterfly int(4) NOT NULL DEFAULT '0', 					\
			knife_butterfly_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
			knife_butterfly_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_butterfly_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_butterfly_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_butterfly_seed int(10) NOT NULL DEFAULT '-1',				\
			knife_flip int(4) NOT NULL DEFAULT '0', 						\
			knife_flip_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
			knife_flip_trak int(1) NOT NULL DEFAULT '0', 					\
			knife_flip_trak_count int(10) NOT NULL DEFAULT '0', 			\
			knife_flip_tag varchar(256) NOT NULL DEFAULT '',				\
			knife_flip_seed int(10) NOT NULL DEFAULT '-1', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			knife_push int(4) NOT NULL DEFAULT '0', 						\
			knife_push_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
			knife_push_trak int(1) NOT NULL DEFAULT '0', 					\
			knife_push_trak_count int(10) NOT NULL DEFAULT '0', 			\
			knife_push_tag varchar(256) NOT NULL DEFAULT '', 				\
			knife_push_seed int(10) NOT NULL DEFAULT '-1',					\
			knife_tactical int(4) NOT NULL DEFAULT '0', 					\
			knife_tactical_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
			knife_tactical_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_tactical_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_tactical_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_tactical_seed int(10) NOT NULL DEFAULT '-1',				\
			knife_falchion int(4) NOT NULL DEFAULT '0', 					\
			knife_falchion_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
			knife_falchion_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_falchion_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_falchion_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_falchion_seed int(10) NOT NULL DEFAULT '-1',				\
			knife_gut int(4) NOT NULL DEFAULT '0', 							\
			knife_gut_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
			knife_gut_trak int(1) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			knife_gut_trak_count int(10) NOT NULL DEFAULT '0', 				\
			knife_gut_tag varchar(256) NOT NULL DEFAULT '', 				\
			knife_gut_seed int(10) NOT NULL DEFAULT '-1',					\
			knife_ursus int(4) NOT NULL DEFAULT '0', 						\
			knife_ursus_float decimal(3,2) NOT NULL DEFAULT '0.0', 			\
			knife_ursus_trak int(1) NOT NULL DEFAULT '0', 					\
			knife_ursus_trak_count int(10) NOT NULL DEFAULT '0', 			\
			knife_ursus_tag varchar(256) NOT NULL DEFAULT '', 				\
			knife_ursus_seed int(10) NOT NULL DEFAULT '-1',					\
			knife_gypsy_jackknife int(4) NOT NULL DEFAULT '0', 				\
			knife_gypsy_jackknife_float decimal(3,2) NOT NULL DEFAULT '0.0',\
			knife_gypsy_jackknife_trak int(1) NOT NULL DEFAULT '0', 		\
			knife_gypsy_jackknife_trak_count int(10) NOT NULL DEFAULT '0', 	\
			knife_gypsy_jackknife_tag varchar(256) NOT NULL DEFAULT '', 	\
			knife_gypsy_jackknife_seed int(10) NOT NULL DEFAULT '-1',		\
			knife_stiletto int(4) NOT NULL DEFAULT '0', 					\
			knife_stiletto_float decimal(3,2) NOT NULL DEFAULT '0.0', 		\
			knife_stiletto_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_stiletto_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_stiletto_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_stiletto_seed int(10) NOT NULL DEFAULT '-1',				\
			knife_widowmaker int(4) NOT NULL DEFAULT '0', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			knife_widowmaker_float decimal(3,2) NOT NULL DEFAULT '0.0', 	\
			knife_widowmaker_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_widowmaker_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_widowmaker_tag varchar(256) NOT NULL DEFAULT '',			\
			knife_widowmaker_seed int(10) NOT NULL DEFAULT '-1',			\
			mp5sd int(4) NOT NULL DEFAULT '0', 								\
			mp5sd_float decimal(3,2) NOT NULL DEFAULT '0.0',				\
			mp5sd_trak int(1) NOT NULL DEFAULT '0', 						\
			mp5sd_trak_count int(10) NOT NULL DEFAULT '0',					\
			mp5sd_tag varchar(256) NOT NULL DEFAULT '',						\
			mp5sd_seed int(10) NOT NULL DEFAULT '-1',						\
			knife_css int(4) NOT NULL DEFAULT '0', 							\
			knife_css_float decimal(3,2) NOT NULL DEFAULT '0.0',			\
			knife_css_trak int(1) NOT NULL DEFAULT '0', 					\
			knife_css_trak_count int(10) NOT NULL DEFAULT '0', 				\
			knife_css_tag varchar(256) NOT NULL DEFAULT '', 				\
			knife_css_seed int(10) NOT NULL DEFAULT '-1',					\
			knife_cord int(4) NOT NULL DEFAULT '0', 						\
			knife_cord_float decimal(3,2) NOT NULL DEFAULT '0.0',			\
			knife_cord_trak int(1) NOT NULL DEFAULT '0', 					\
			knife_cord_trak_count int(10) NOT NULL DEFAULT '0', 			\
			knife_cord_tag varchar(256) NOT NULL DEFAULT '', ");
	index += FormatEx(createQuery[index], sizeof(createQuery) - index, "	\
			knife_cord_seed int(10) NOT NULL DEFAULT '-1',					\
			knife_canis int(4) NOT NULL DEFAULT '0', 						\
			knife_canis_float decimal(3,2) NOT NULL DEFAULT '0.0',			\
			knife_canis_trak int(1) NOT NULL DEFAULT '0', 					\
			knife_canis_trak_count int(10) NOT NULL DEFAULT '0', 			\
			knife_canis_tag varchar(256) NOT NULL DEFAULT '', 				\
			knife_canis_seed int(10) NOT NULL DEFAULT '-1',					\
			knife_outdoor int(4) NOT NULL DEFAULT '0', 						\
			knife_outdoor_float decimal(3,2) NOT NULL DEFAULT '0.0',		\
			knife_outdoor_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_outdoor_trak_count int(10) NOT NULL DEFAULT '0', 			\
			knife_outdoor_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_outdoor_seed int(10) NOT NULL DEFAULT '-1',				\
			knife_skeleton int(4) NOT NULL DEFAULT '0', 					\
			knife_skeleton_float decimal(3,2) NOT NULL DEFAULT '0.0',		\
			knife_skeleton_trak int(1) NOT NULL DEFAULT '0', 				\
			knife_skeleton_trak_count int(10) NOT NULL DEFAULT '0', 		\
			knife_skeleton_tag varchar(256) NOT NULL DEFAULT '', 			\
			knife_skeleton_seed int(10) NOT NULL DEFAULT '-1')");
	
	if (mysql)
	{
		 index += FormatEx(createQuery[index], sizeof(createQuery) - index, " ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
	}
	
	if (recreate)
	{
		db.Query(T_ReCreateMainTableCallback, createQuery, mysql, DBPrio_High);
	}
	else
	{
		db.Query(T_CreateMainTableCallback, createQuery, mysql, DBPrio_High);
	}
}

public void T_ReCreateMainTableCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Recreating the main table has failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		int index = 0;
		
		char migrateQuery[8192];

		index += FormatEx(migrateQuery[index], sizeof(migrateQuery) - index, "																	\
			INSERT INTO %sweapons (steamid, knife, awp, awp_float, awp_trak, awp_trak_count, awp_tag, ak47, ak47_float, 					\
			ak47_trak, ak47_trak_count, ak47_tag, m4a1, m4a1_float, m4a1_trak, m4a1_trak_count, m4a1_tag, m4a1_silencer, 					\
			m4a1_silencer_float, m4a1_silencer_trak, m4a1_silencer_trak_count, m4a1_silencer_tag, deagle, deagle_float, 					\
			deagle_trak, deagle_trak_count, deagle_tag, usp_silencer, usp_silencer_float, usp_silencer_trak, 								\
			usp_silencer_trak_count, usp_silencer_tag, hkp2000, hkp2000_float, hkp2000_trak, hkp2000_trak_count, 							\
			hkp2000_tag, glock, glock_float, glock_trak, glock_trak_count, glock_tag, elite, elite_float, elite_trak, ", g_TablePrefix);
		index += FormatEx(migrateQuery[index], sizeof(migrateQuery) - index, "																	\
			elite_trak_count, elite_tag, p250, p250_float, p250_trak, p250_trak_count, p250_tag, cz75a, cz75a_float, 						\
			cz75a_trak, cz75a_trak_count, cz75a_tag, fiveseven, fiveseven_float, fiveseven_trak, fiveseven_trak_count, 						\
			fiveseven_tag, tec9, tec9_float, tec9_trak, tec9_trak_count, tec9_tag, revolver, revolver_float, revolver_trak, 				\
			revolver_trak_count, revolver_tag, nova, nova_float, nova_trak, nova_trak_count, nova_tag, xm1014, xm1014_float, 				\
			xm1014_trak, xm1014_trak_count, xm1014_tag, mag7, mag7_float, mag7_trak, mag7_trak_count, mag7_tag, sawedoff, 					\
			sawedoff_float, sawedoff_trak, sawedoff_trak_count, sawedoff_tag, m249, m249_float, m249_trak, m249_trak_count, 				\
			m249_tag, negev, negev_float, negev_trak, negev_trak_count, negev_tag, mp9, mp9_float, mp9_trak, mp9_trak_count, ");
		index += FormatEx(migrateQuery[index], sizeof(migrateQuery) - index, "																	\
			mp9_tag, mac10, mac10_float, mac10_trak, mac10_trak_count, mac10_tag, mp7, mp7_float, mp7_trak, mp7_trak_count, 				\
			mp7_tag, ump45, ump45_float, ump45_trak, ump45_trak_count, ump45_tag, p90, p90_float, p90_trak, p90_trak_count, 				\
			p90_tag, bizon, bizon_float, bizon_trak, bizon_trak_count, bizon_tag, famas, famas_float, famas_trak, 							\
			famas_trak_count, famas_tag, galilar, galilar_float, galilar_trak, galilar_trak_count, galilar_tag, ssg08, 						\
			ssg08_float, ssg08_trak, ssg08_trak_count, ssg08_tag, aug, aug_float, aug_trak, aug_trak_count, aug_tag, sg556, 				\
			sg556_float, sg556_trak, sg556_trak_count, sg556_tag, scar20, scar20_float, scar20_trak, scar20_trak_count, 					\
			scar20_tag, g3sg1, g3sg1_float, g3sg1_trak, g3sg1_trak_count, g3sg1_tag, knife_karambit, knife_karambit_float, 					\
			knife_karambit_trak, knife_karambit_trak_count, knife_karambit_tag, knife_m9_bayonet, knife_m9_bayonet_float, ");
		index += FormatEx(migrateQuery[index], sizeof(migrateQuery) - index, "																	\
			knife_m9_bayonet_trak, knife_m9_bayonet_trak_count, knife_m9_bayonet_tag, bayonet, bayonet_float, bayonet_trak, 				\
			bayonet_trak_count, bayonet_tag, knife_survival_bowie, knife_survival_bowie_float, knife_survival_bowie_trak, 					\
			knife_survival_bowie_trak_count, knife_survival_bowie_tag, knife_butterfly, knife_butterfly_float, knife_butterfly_trak, 		\
			knife_butterfly_trak_count, knife_butterfly_tag, knife_flip, knife_flip_float, knife_flip_trak, knife_flip_trak_count, 			\
			knife_flip_tag, knife_push, knife_push_float, knife_push_trak, knife_push_trak_count, knife_push_tag, knife_tactical, 			\
			knife_tactical_float, knife_tactical_trak, knife_tactical_trak_count, knife_tactical_tag, knife_falchion, 						\
			knife_falchion_float, knife_falchion_trak, knife_falchion_trak_count, knife_falchion_tag, knife_gut, knife_gut_float, ");
		index += FormatEx(migrateQuery[index], sizeof(migrateQuery) - index, "																	\
			knife_gut_trak, knife_gut_trak_count, knife_gut_tag, knife_ursus, knife_ursus_float, knife_ursus_trak, 							\
			knife_ursus_trak_count, knife_ursus_tag, knife_gypsy_jackknife, knife_gypsy_jackknife_float, knife_gypsy_jackknife_trak, 		\
			knife_gypsy_jackknife_trak_count, knife_gypsy_jackknife_tag, knife_stiletto, knife_stiletto_float, knife_stiletto_trak, 		\
			knife_stiletto_trak_count, knife_stiletto_tag, knife_widowmaker, knife_widowmaker_float, knife_widowmaker_trak, 				\
			knife_widowmaker_trak_count, knife_widowmaker_tag, mp5sd, mp5sd_float, mp5sd_trak, mp5sd_trak_count, mp5sd_tag, knife_css, 		\
			knife_css_float, knife_css_trak, knife_css_trak_count, knife_css_tag, knife_css_seed)											\
			SELECT * FROM %sweapons_tmp", g_TablePrefix);
		
		db.Query(T_MigrateOldDataCallback, migrateQuery, mysql, DBPrio_High);
	}
}

public void T_MigrateOldDataCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Migrating old data has failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		LogMessage("%s Old data has been migrated successfully", (mysql ? "MySQL" : "SQLite"));
		
		char dropTableQuery[512];
		Format(dropTableQuery, sizeof(dropTableQuery), "DROP TABLE %sweapons_tmp", g_TablePrefix);
		db.Query(T_DropOldTableCallback, dropTableQuery, mysql, DBPrio_High);
	}
}

public void T_DropOldTableCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Dropping old table has failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		LogMessage("%s Old table has been dropped successfully", (mysql ? "MySQL" : "SQLite"));
		if(++g_iDatabaseState > 1)
		{
			LogMessage("%s DB connection successful", (mysql ? "MySQL" : "SQLite"));
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientAuthorized(i))
				{
					OnClientPostAdminCheck(i);
				}
			}
			DeleteInactivePlayerData();
		}
	}
}

public void T_CreateMainTableCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Creating the main table has failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		g_iMigrationStep = 0;
		AddWeaponColumns(mysql, "knife_ursus", false);
		
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

void addSeedColumns(bool mysql)
{
	char seedCheckQuery[128];
	FormatEx(seedCheckQuery, sizeof(seedCheckQuery), "SELECT awp_seed FROM %sweapons", g_TablePrefix);

	db.Query(T_SeedColumnCallback, seedCheckQuery, mysql, DBPrio_High);
}

public void T_SeedColumnCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogMessage("%s Attempting to create seed columns", (mysql ? "MySQL" : "SQLite"));
		
		char seedColumnsQuery[8192];
		
		int index = 0;
		
		if (mysql)
		{
			index += FormatEx(seedColumnsQuery[index], sizeof(seedColumnsQuery) - index, "										\
				ALTER TABLE %sweapons																						\
					ADD COLUMN awp_seed int(10) NOT NULL DEFAULT '-1' AFTER awp_tag,										\
					ADD COLUMN ak47_seed int(10) NOT NULL DEFAULT '-1' AFTER ak47_tag,										\
					ADD COLUMN m4a1_seed int(10) NOT NULL DEFAULT '-1' AFTER m4a1_tag,										\
					ADD COLUMN m4a1_silencer_seed int(10) NOT NULL DEFAULT '-1' AFTER m4a1_silencer_tag,					\
					ADD COLUMN deagle_seed int(10) NOT NULL DEFAULT '-1' AFTER deagle_tag,									\
					ADD COLUMN usp_silencer_seed int(10) NOT NULL DEFAULT '-1' AFTER usp_silencer_tag,						\
					ADD COLUMN hkp2000_seed int(10) NOT NULL DEFAULT '-1' AFTER hkp2000_tag,								\
					ADD COLUMN glock_seed int(10) NOT NULL DEFAULT '-1' AFTER glock_tag,									\
					ADD COLUMN elite_seed int(10) NOT NULL DEFAULT '-1' AFTER elite_tag,									\
					ADD COLUMN p250_seed int(10) NOT NULL DEFAULT '-1' AFTER p250_tag,										\
					ADD COLUMN cz75a_seed int(10) NOT NULL DEFAULT '-1' AFTER cz75a_tag,									\
					ADD COLUMN fiveseven_seed int(10) NOT NULL DEFAULT '-1' AFTER fiveseven_tag,							\
					ADD COLUMN tec9_seed int(10) NOT NULL DEFAULT '-1' AFTER tec9_tag,										\
					ADD COLUMN revolver_seed int(10) NOT NULL DEFAULT '-1' AFTER revolver_tag,								\
					ADD COLUMN nova_seed int(10) NOT NULL DEFAULT '-1' AFTER nova_tag,										\
					ADD COLUMN xm1014_seed int(10) NOT NULL DEFAULT '-1' AFTER xm1014_tag,									\
					ADD COLUMN mag7_seed int(10) NOT NULL DEFAULT '-1' AFTER mag7_tag,										\
					ADD COLUMN sawedoff_seed int(10) NOT NULL DEFAULT '-1' AFTER sawedoff_tag,								\
					ADD COLUMN m249_seed int(10) NOT NULL DEFAULT '-1' AFTER m249_tag,										\
					ADD COLUMN negev_seed int(10) NOT NULL DEFAULT '-1' AFTER negev_tag,									\
					ADD COLUMN mp9_seed int(10) NOT NULL DEFAULT '-1' AFTER mp9_tag, ", g_TablePrefix);
			index += FormatEx(seedColumnsQuery[index], sizeof(seedColumnsQuery) - index, "										\
					ADD COLUMN mac10_seed int(10) NOT NULL DEFAULT '-1' AFTER mac10_tag,									\
					ADD COLUMN mp7_seed int(10) NOT NULL DEFAULT '-1' AFTER mp7_tag,										\
					ADD COLUMN ump45_seed int(10) NOT NULL DEFAULT '-1' AFTER ump45_tag,									\
					ADD COLUMN p90_seed int(10) NOT NULL DEFAULT '-1' AFTER p90_tag,										\
					ADD COLUMN bizon_seed int(10) NOT NULL DEFAULT '-1' AFTER bizon_tag,									\
					ADD COLUMN famas_seed int(10) NOT NULL DEFAULT '-1' AFTER famas_tag,									\
					ADD COLUMN galilar_seed int(10) NOT NULL DEFAULT '-1' AFTER galilar_tag,								\
					ADD COLUMN ssg08_seed int(10) NOT NULL DEFAULT '-1' AFTER ssg08_tag,									\
					ADD COLUMN aug_seed int(10) NOT NULL DEFAULT '-1' AFTER aug_tag,										\
					ADD COLUMN sg556_seed int(10) NOT NULL DEFAULT '-1' AFTER sg556_tag,									\
					ADD COLUMN scar20_seed int(10) NOT NULL DEFAULT '-1' AFTER scar20_tag,									\
					ADD COLUMN g3sg1_seed int(10) NOT NULL DEFAULT '-1' AFTER g3sg1_tag,									\
					ADD COLUMN knife_karambit_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_karambit_tag,					\
					ADD COLUMN knife_m9_bayonet_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_m9_bayonet_tag,				\
					ADD COLUMN bayonet_seed int(10) NOT NULL DEFAULT '-1' AFTER bayonet_tag,								\
					ADD COLUMN knife_survival_bowie_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_survival_bowie_tag,		\
					ADD COLUMN knife_butterfly_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_butterfly_tag,				\
					ADD COLUMN knife_flip_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_flip_tag,							\
					ADD COLUMN knife_push_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_push_tag,							\
					ADD COLUMN knife_tactical_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_tactical_tag,					\
					ADD COLUMN knife_falchion_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_falchion_tag,					\
					ADD COLUMN knife_gut_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_gut_tag,							\
					ADD COLUMN knife_ursus_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_ursus_tag,						\
					ADD COLUMN knife_gypsy_jackknife_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_gypsy_jackknife_tag,	\
					ADD COLUMN knife_stiletto_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_stiletto_tag,					\
					ADD COLUMN knife_widowmaker_seed int(10) NOT NULL DEFAULT '-1' AFTER knife_widowmaker_tag,				\
					ADD COLUMN mp5sd_seed int(10) NOT NULL DEFAULT '-1' AFTER mp5sd_tag");
			
			db.Query(T_SeedConfirmationCallback, seedColumnsQuery, mysql, DBPrio_High);
		}
		else
		{
			char renameQuery[512];
			Format(renameQuery, sizeof(renameQuery), "ALTER TABLE %sweapons RENAME TO %sweapons_tmp", g_TablePrefix, g_TablePrefix);
			db.Query(T_RenameCallback, renameQuery, mysql, DBPrio_High);
		}
	}
	else
	{
		if(++g_iDatabaseState > 1)
		{
			LogMessage("%s DB connection successful", (mysql ? "MySQL" : "SQLite"));
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientAuthorized(i))
				{
					OnClientPostAdminCheck(i);
				}
			}
			DeleteInactivePlayerData();
		}
	}
}

public void T_RenameCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Renaming old table has failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		CreateMainTable(mysql, true);
	}
}

public void T_SeedConfirmationCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		LogError("%s Seed column creation failed! %s", (mysql ? "MySQL" : "SQLite"), error);
	}
	else
	{
		LogMessage("Successfully created seed columns");
		if(++g_iDatabaseState > 1)
		{
			LogMessage("%s DB connection successful", (mysql ? "MySQL" : "SQLite"));
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientAuthorized(i))
				{
					OnClientPostAdminCheck(i);
				}
			}
			DeleteInactivePlayerData();
		}
	}
}

void AddWeaponColumns(bool mysql, const char[] weapon, bool seedColumn = true)
{
	Transaction txn = new Transaction();
	char query[512];
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s int(4) NOT NULL DEFAULT '0'", g_TablePrefix, weapon);
	txn.AddQuery(query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_float decimal(3,2) NOT NULL DEFAULT '0.0'", g_TablePrefix, weapon);
	txn.AddQuery(query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_trak int(1) NOT NULL DEFAULT '0'", g_TablePrefix, weapon);
	txn.AddQuery(query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_trak_count int(10) NOT NULL DEFAULT '0'", g_TablePrefix, weapon);
	txn.AddQuery(query);
	Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_tag varchar(256) NOT NULL DEFAULT ''", g_TablePrefix, weapon);
	txn.AddQuery(query);
	if (seedColumn)
	{
		Format(query, sizeof(query), "ALTER TABLE %sweapons ADD %s_seed int(10) NOT NULL DEFAULT '-1'", g_TablePrefix, weapon);
		txn.AddQuery(query);
	}
	db.Execute(txn, Txn_OnSucess, Txn_OnFail, mysql);
}

public void Txn_OnSucess(Database database, bool mysql, int numQueries, DBResultSet[] results, any[] queryData)
{
	if(++g_iMigrationStep >= sizeof(g_MigrationWeapons))
	{
		addSeedColumns(mysql);
	}
	else
	{
		AddWeaponColumns(mysql, g_MigrationWeapons[g_iMigrationStep], g_iMigrationStep > 4);
	}
}

public void Txn_OnFail(Database database, bool mysql, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	if(++g_iMigrationStep >= sizeof(g_MigrationWeapons))
	{
		addSeedColumns(mysql);
	}
	else
	{
		AddWeaponColumns(mysql, g_MigrationWeapons[g_iMigrationStep], g_iMigrationStep > 4);
	}
}

public void T_CreateTimestampTableCallback(Database database, DBResultSet results, const char[] error, bool mysql)
{
	if (results == null)
	{
		if(++g_iDatabaseState > 1)
		{
			LogMessage("%s DB connection successful", (mysql ? "MySQL" : "SQLite"));
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientAuthorized(i))
				{
					OnClientPostAdminCheck(i);
				}
			}
			DeleteInactivePlayerData();
		}
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
		if(++g_iDatabaseState > 1)
		{
			LogMessage("%s DB connection successful", (mysql ? "MySQL" : "SQLite"));
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientAuthorized(i))
				{
					OnClientPostAdminCheck(i);
				}
			}
			DeleteInactivePlayerData();
		}
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
	delete pack;
}