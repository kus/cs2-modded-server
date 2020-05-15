/*  CS:GO Gloves SourceMod Plugin
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
	FormatEx(query, sizeof(query), "SELECT * FROM %sgloves WHERE steamid = '%s'", g_TablePrefix, steamid);
	db.Query(T_GetPlayerDataCallback, query, client);
}

public void T_GetPlayerDataCallback(Database database, DBResultSet results, const char[] error, int client)
{
	if(IsValidClient(client))
	{
		if (results == null)
		{
			LogError("Query failed! %s", error);
		}
		else if (results.RowCount == 0)
		{
			char steamid[32];
			GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true);
			char query[255];
			FormatEx(query, sizeof(query), "INSERT INTO %sgloves (steamid) VALUES ('%s')", g_TablePrefix, steamid);
			db.Query(T_InsertCallback, query);
			g_iGroup[client][CS_TEAM_T] = 0;
			g_iGloves[client][CS_TEAM_T] = 0;
			g_fFloatValue[client][CS_TEAM_T] = 0.0;
			g_iGroup[client][CS_TEAM_CT] = 0;
			g_iGloves[client][CS_TEAM_CT] = 0;
			g_fFloatValue[client][CS_TEAM_CT] = 0.0;
		}
		else
		{
			if(results.FetchRow())
			{
				for(int i = 1, j = 2; j < 4; i += 3, j++) 
				{
					g_iGroup[client][j] = results.FetchInt(i);
					g_iGloves[client][j] = results.FetchInt(i + 1);
					g_fFloatValue[client][j] = results.FetchFloat(i + 2);
				}
			}
		}
	}
}

void UpdatePlayerData(int client, char[] updateFields)
{
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true);
	char query[255];
	FormatEx(query, sizeof(query), "UPDATE %sgloves SET %s WHERE steamid = '%s'", g_TablePrefix, updateFields, steamid);
	db.Query(T_UpdatePlayerDataCallback, query, client);
}

public void T_UpdatePlayerDataCallback(Database database, DBResultSet results, const char[] error, int client)
{
	if (results == null)
	{
		LogError("Update Player failed! %s", error);
	}
}

public void T_InsertCallback(Database database, DBResultSet results, const char[] error, any data)
{
	if (results == null)
	{
		LogError("Query failed! %s", error);
	}
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
		char createQuery[1024];
		char dbIdentifier[10];

		Format(createQuery, sizeof(createQuery), "CREATE TABLE IF NOT EXISTS %sgloves (steamid varchar(32) NOT NULL PRIMARY KEY, t_group int(5) NOT NULL DEFAULT '0', t_glove int(5) NOT NULL DEFAULT '0', t_float decimal(3,2) NOT NULL DEFAULT '0.0', ct_group int(5) NOT NULL DEFAULT '0', ct_glove int(5) NOT NULL DEFAULT '0', ct_float decimal(3,2) NOT NULL DEFAULT '0.0')", g_TablePrefix);
		
		db.Driver.GetIdentifier(dbIdentifier, sizeof(dbIdentifier));
		if (StrEqual(dbIdentifier, "mysql"))
		{
			 Format(createQuery, sizeof(createQuery), "%s ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;", createQuery);
		}
		
		db.Query(T_CreateTableCallback, createQuery, _, DBPrio_High);
	}
}

public void T_CreateTableCallback(Database database, DBResultSet results, const char[] error, int client)
{
	if (results == null)
	{
		LogError("Create table failed! %s", error);
	}
	else
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientConnected(i))
			{
				OnClientPostAdminCheck(i);
			}
		}
	}
}