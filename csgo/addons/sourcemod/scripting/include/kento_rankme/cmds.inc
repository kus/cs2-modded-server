// FROM SMLIB
#define GAMEUNITS_TO_METERS	0.01905

stock int Array_FindHighestValue(any[] array, int size, int start = 0)
{
	if (start < 0) start = 0;

	any value = array[start];
	any tempValue;
	int x = start;
	
	for (int i=start; i < size; i++) 
	{
		tempValue = array[i];
		
		if (tempValue > value) 
		{
			value = tempValue;
			x = i;
		}
	}
	
	return x;
}

stock float Math_UnitsToMeters(float units)
{
	return (units * GAMEUNITS_TO_METERS);
}

stock float Entity_GetDistanceOrigin(int entity, const float vec[3])
{
	float entityVec[3];
	Entity_GetAbsOrigin(entity, entityVec);

	return GetVectorDistance(entityVec, vec);
}

stock float Entity_GetDistance(int entity, int target)
{
	float targetVec[3];
	Entity_GetAbsOrigin(target, targetVec);

	return Entity_GetDistanceOrigin(entity, targetVec);
}

stock void Entity_GetAbsOrigin(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec);
}

public Action CMD_ResetRank(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	char arg1[64];
	GetCmdArg(1,arg1,sizeof(arg1));
	char sEscapeArg1[129];
	SQL_EscapeString(g_hStatsDb,arg1,sEscapeArg1,sizeof(sEscapeArg1));
	//ReplaceString(arg1,sizeof(arg1)," ","");
	//ReplaceString(arg1,sizeof(arg1),"\"","");
	char query[2000];
	if(g_RankBy == 1){
		Format(query,sizeof(query),"DELETE FROM `%s` WHERE name='%s'",g_sSQLTable,sEscapeArg1);
	} else if (g_RankBy == 0){
		Format(query,sizeof(query),"DELETE FROM `%s` WHERE steam='%s'",g_sSQLTable,sEscapeArg1);
	} else if (g_RankBy == 2){
		Format(query,sizeof(query),"DELETE FROM `%s` WHERE lastip='%s'",g_sSQLTable,sEscapeArg1);
	}
	SQL_TQuery(g_hStatsDb,SQL_NothingCallback,query);
	LogAction(client,-1,"[RankMe]: Rank has been reset (%s)",arg1);
	char auth[64];
	char name[MAX_NAME_LENGTH];
	char ip[64];
	for(int i=1;i<=MaxClients;i++){
		if(IsClientInGame(i)){		
			if(g_RankBy == 1){
				GetClientName(i,name,sizeof(name));				
				if(StrEqual(name,arg1,false))
					OnClientPutInServer(i);			
			} else if(g_RankBy == 0){
				GetClientAuthId(i,AuthId_Steam2,auth,sizeof(auth));	
				if(StrEqual(auth,arg1,false))
					OnClientPutInServer(i);
			} else if(g_RankBy == 2){			
				GetClientIP(i,ip,sizeof(ip));				
				if(StrEqual(ip,arg1,false))
					OnClientPutInServer(i);
			}
		}
	}
	CPrintToChat(client, "%s %T", MSG, "The rank has been reset",client);
	return Plugin_Handled;
}

public Action CMD_ResetRankAll(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
		
	char query[2000];
	Format(query,sizeof(query),"DELETE FROM `%s` WHERE 1=1",g_sSQLTable);
	SQL_TQuery(g_hStatsDb,SQL_NothingCallback,query);
	
	LogAction(client,-1,"[RankMe]: All rank data has been reset");
	
	for(int i=1;i<=MaxClients;i++){
		if(IsClientInGame(i))
			OnClientPutInServer(i);
	}
	CPrintToChat(client, "%s %T", MSG, "All rank data has been reset",client);
	return Plugin_Handled;
}

public Action CMD_Purge(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	char arg1[64];
	
	GetCmdArg(1,arg1,sizeof(arg1));
	char sEscapeArg1[129];
	SQL_EscapeString(g_hStatsDb,arg1,sEscapeArg1,sizeof(sEscapeArg1));
	//ReplaceString(arg1,sizeof(arg1)," ","");
	//ReplaceString(arg1,sizeof(arg1),"\"","");
	
	int deletebefore;
	if(StringToInt(arg1) == 0){
		CPrintToChat(client, "%s %T", MSG, "Usagepurge",client);
		return Plugin_Handled;
	}
	deletebefore = GetTime() - (StringToInt(arg1)*86400);
	char query[2000];
	Format(query,sizeof(query),"DELETE FROM `%s` WHERE lastconnect < '%d'",g_sSQLTable,deletebefore);
	SQL_TQuery(g_hStatsDb,SQL_PurgeCallback,query);
	LogAction(client,-1,"[RankMe]: Purged rank (%s days inactivity)",arg1);
	CPrintToChat(client, "%s %T", MSG, "Purged",client);
	return Plugin_Handled;
}

public void SQL_GetPlayersCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	g_TotalPlayers =SQL_GetRowCount(hndl);
}

public Action CMD_TopWeapon(int client, int args){
	
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	if(args > 0){
		char arg1[20];
		char arg2[5];
		GetCmdArg(1,arg1,sizeof(arg1));
		GetCmdArg(2,arg2,sizeof(arg2));
		if(!StrEqual(arg1,"") && StringToInt(arg2) != 0){
			ShowTOPWeapon(client,GetWeaponNum(arg1),StringToInt(arg2));
		}	else if(!StrEqual(arg1,"")){
			ShowTOPWeapon(client,GetWeaponNum(arg1),0);
		}
	} else {
		Menu menu = CreateMenu(MenuHandler_TopWeapon_Choose);
		menu.SetTitle("Top Weapon:");
		for(int i=0;i<42;i++){
			menu.AddItem(g_sWeaponsNamesGame[i],g_sWeaponsNamesFull[i]);
		}
		menu.Display(client,MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public int MenuHandler_TopWeapon_Choose(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTOPWeapon(param1,GetWeaponNum(temp),0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

void ShowTOPWeapon(int client, int weapon, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	WritePackCell(Datapack,weapon);
	if(at>0){
		WritePackCell(Datapack,at-1);
		
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY %s DESC LIMIT %i, 10",query,g_sWeaponsNamesGame[weapon],at-1);
	
	SQL_TQuery(g_hStatsDb,SQL_TopWeaponCallback,query,Datapack);

}

public void SQL_TopWeaponCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
		
	int weapon = ReadPackCell(Datapack);
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTOPWeapon(client,weapon,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), MenuHandler_TopWeapon);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];

	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		i++;
		SQL_FetchString(hndl,2,name,sizeof(name));
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %T: %d\n",i+at,name,SQL_FetchInt(hndl,4),"Kills",client,SQL_FetchInt(hndl,17+weapon));
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	char temp1[20];
	Format(temp1,sizeof(temp1),"%d;%d",weapon,0);
	menu.AddItem(temp1,temp);
	
	
	Format(temp,sizeof(temp),"%d;%d",weapon,at+i);
	
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	Format(temp,sizeof(temp),"%d;%d",weapon,at-i);
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);
	
	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopWeapon(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		
		char v[2][5];
		ExplodeString(temp,";",v,2,5);
		if(StringToInt(v[1]) >= 0){
			ShowTOPWeapon(param1,StringToInt(v[0]),StringToInt(v[1])+1);
		} else {
			ShowTOPWeapon(param1,StringToInt(v[0]),0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_Top(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	
	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTOP(client,StringToInt(arg1));
	}	else {
		ShowTOP(client,0);
	}
	return Plugin_Handled;
}

void ShowTOP(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	if(g_RankMode == 1)
		Format(query,sizeof(query),"%s ORDER BY score DESC LIMIT %i, 10",query,at-1);
	else if(g_RankMode == 2){
		if(g_bMysql)
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as DECIMAL)/CAST(Case when deaths=0 then 1 ELSE deaths END as DECIMAL) DESC, score DESC LIMIT %i, 10",query,at-1);
		else
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as float)/CAST(Case when deaths=0 then 1 ELSE deaths END as float) DESC, score DESC LIMIT %i, 10",query,at-1);
	}
	
	SQL_TQuery(g_hStatsDb,SQL_TopCallback,query,Datapack);

}

public void SQL_TopCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTOP(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_Top);
	
	float kdr;
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
		int deaths;
		if(SQL_FetchInt(hndl,6) == 0)
			deaths = 1;
		else 
			deaths=SQL_FetchInt(hndl,6);
		
		kdr = SQL_FetchFloat(hndl,5)/deaths;
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - KDR: %.2f\n",i+at,name,SQL_FetchInt(hndl,4),kdr);
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);
	
	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_Top(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTOP(param1,StringToInt(temp)+1);
		} else {
			ShowTOP(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_TopHS(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopHS(client,StringToInt(arg1));
	}	else {
		ShowTopHS(client,0);
	}
	return Plugin_Handled;
}

void ShowTopHS(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY headshots DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopHSCallback,query,Datapack);
}

public void SQL_TopHSCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopHS(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopHS);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
	
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %t: %d\n",i+at,name,SQL_FetchInt(hndl,4),"Headshots",SQL_FetchInt(hndl,12));
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopHS(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopHS(param1,StringToInt(temp)+1);
		} else {
			ShowTopHS(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_TopKills(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopKills(client,StringToInt(arg1));
	}	else {
		ShowTopKills(client,0);
	}
	return Plugin_Handled;
}

void ShowTopKills(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY kills DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopKillsCallback,query,Datapack);

}

public void SQL_TopKillsCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopKills(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopKills);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
	
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %t: %d\n",i+at,name,SQL_FetchInt(hndl,4),"Kills",SQL_FetchInt(hndl,5));
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopKills(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopKills(param1,StringToInt(temp)+1);
		} else {
			ShowTopKills(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_TopDeaths(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopDeaths(client,StringToInt(arg1));
	}	else {
		ShowTopDeaths(client,0);
	}
	return Plugin_Handled;
}

void ShowTopDeaths(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY deaths DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopDeathsCallback,query,Datapack);

}

public void SQL_TopDeathsCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopDeaths(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), MenuHandler_TopDeaths);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
	
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %t: %d\n",i+at,name,SQL_FetchInt(hndl,4),"Deaths",SQL_FetchInt(hndl,6));
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopDeaths(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopDeaths(param1,StringToInt(temp)+1);
		} else {
			ShowTopDeaths(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_TopAcc(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	
	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopAcc(client,StringToInt(arg1));
	}	else {
		ShowTopAcc(client,0);
	}
	return Plugin_Handled;
}

void ShowTopAcc(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	
	if(g_bMysql)
		Format(query,sizeof(query),"%s ORDER BY CAST(hits as DECIMAL)/CAST(Case when shots=0 then 1 ELSE shots END as DECIMAL) DESC LIMIT %i, 10",query,at-1);
	else
		Format(query,sizeof(query),"%s ORDER BY CAST(hits as float)/CAST(Case when shots=0 then 1 ELSE shots END as float) DESC LIMIT %i, 10",query,at-1);
	
	SQL_TQuery(g_hStatsDb,SQL_TopAccCallback,query,Datapack);

}

public void SQL_TopAccCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopAcc(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopAcc);

	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	int shots;
	int hits;
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		shots = SQL_FetchInt(hndl,10);
		if(shots == 0)
			shots = 1;
		
		hits = SQL_FetchInt(hndl,11);
		
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %T: %.2f%%\n",i+at,name,SQL_FetchInt(hndl,4),"Accuracy",client,IntToFloat(hits)/shots*100);
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);
	
	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopAcc(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopAcc(param1,StringToInt(temp)+1);
		} else {
			ShowTopAcc(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_TopTime(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopTime(client,StringToInt(arg1));
	}	else {
		ShowTopTime(client,0);
	}
	return Plugin_Handled;
}

void ShowTopTime(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY connected DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopTimeCallback,query,Datapack);

}

public void SQL_TopTimeCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopTime(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopTime);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	int time;
	int hours;
	int minutes;
	
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		time = SQL_FetchInt(hndl,13);
		hours = RoundToFloor(time/3600.0);
		time = time-(hours*3600);
		minutes = RoundToFloor(time/60.0);
		time = time-(minutes*60);
		
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %d:%d:%d\n",i+at,name,SQL_FetchInt(hndl,4),hours,minutes,time);
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopTime(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopTime(param1,StringToInt(temp)+1);
		} else {
			ShowTopTime(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public int MenuHandler_DoNothing(Menu menu, MenuAction action, int param1, int param2){
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_Rank(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	//LogToFile("rankme.debug.log","\"sm_rank\" command called by client %d.",client);
	if(g_aStats[client][KILLS] < g_MinimalKills){
		CPrintToChat(client,"%s %T",MSG,"NotRanked",client,g_aStats[client][KILLS],g_MinimalKills);
		return Plugin_Handled;
	}
	
	// check cooldown
	if(g_bShowRankAll && hRankTimer[client] != INVALID_HANDLE)
	{
		CPrintToChat(client,"%s %T",MSG,"RankCooldown",client);
		return Plugin_Handled;
	}
	
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	
	if(g_RankMode == 1)
		Format(query,sizeof(query),"%s ORDER BY score DESC",query);
	else if(g_RankMode == 2){
		if(g_bMysql)
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as DECIMAL)/CAST(Case when deaths=0 then 1 ELSE deaths END as DECIMAL) DESC, score DESC",query);
		else
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as float)/CAST(Case when deaths=0 then 1 ELSE deaths END as float) DESC, score DESC",query);
	}	
		
	SQL_TQuery(g_hStatsDb,SQL_RankCallback,query,client);
	return Plugin_Handled;
}

public void SQL_RankCallback(Handle owner, Handle hndl, const char[] error, any client){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	if(client == 0 || !IsClientInGame(client))
		return;
	//LogToFile("rankme.debug.log","Rank SQL callback called by client %d.",client);
	int i;
	
	g_TotalPlayers =SQL_GetRowCount(hndl);
	char Name_receive[MAX_NAME_LENGTH];
	char Auth_receive[64];
	char Ip_receive[64];
	
	int ikills = g_aStats[client][KILLS];
	int ideaths=g_aStats[client][DEATHS];
	
	int deaths;
	if(ideaths == 0)
		deaths = 1;
	else 
		deaths=ideaths;
	
	float kills = IntToFloat(ikills);
	
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		i++;
		SQL_FetchString(hndl,2,Name_receive,MAX_NAME_LENGTH*2+1);
		SQL_FetchString(hndl,1,Auth_receive,64);
		SQL_FetchString(hndl,3,Ip_receive,64);
	//	PrintToServer("%d %s %s",i, Name_receive, Auth_receive);
		if((g_RankBy == 1 && StrEqual(Name_receive,g_aClientName[client],false)) || (g_RankBy == 0 && StrEqual(Auth_receive,g_aClientSteam[client],false)) || (g_RankBy == 2 && StrEqual(Ip_receive,g_aClientIp[client],false))){

			if(g_bShowRankAll)
			{
				for(int j = 1; j <= MaxClients;j++)
				{
					if(IsClientInGame(j))
					{
						if(client == j || !hidechat[j])	
							CPrintToChat(j,"%s %T",MSG,"IsRankedAt",j,g_aClientName[client],i,g_TotalPlayers,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][ASSISTS],kills/deaths,g_aStats[client][TK],g_aStats[client][MVP]);
						if(g_fRankAllTimer > 0.0)	hRankTimer[j] = CreateTimer(g_fRankAllTimer, KillRankAllTimer, j);
					}
				}
			} 
			else 
			{
				CPrintToChat(client,"%s %T",MSG,"IsRankedAt",client,g_aClientName[client],i,g_TotalPlayers,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][ASSISTS],kills/deaths,g_aStats[client][TK],g_aStats[client][MVP]);
			}
			break;
		}
	} 
}

public Action KillRankAllTimer(Handle timer, int client)
{
	if(hRankTimer[client] != INVALID_HANDLE)
	{
		hRankTimer[client] = INVALID_HANDLE;
	}
}

public Action CMD_Session(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	Menu panel = CreateMenuEx(_,MenuHandler_DoNothing,MENU_ACTIONS_ALL);
	char text[255];
	char temp[255];
	Format(temp,sizeof(temp),"- %T\n","BasicStats",client);
	StrCat(text,255,temp);
	Format(temp,sizeof(temp),"%T: %i\n","Points",client,g_aSession[client][SCORE]);
	StrCat(text,255,temp);
	int ikills = g_aSession[client][KILLS];
	int ideaths=g_aSession[client][DEATHS];
	int deaths;
	if(ideaths == 0)
		deaths = 1;
	else 
		deaths=ideaths;
	float kills = IntToFloat(ikills);

	int shots;
	if(g_aSession[client][SHOTS] == 0)
		shots = 1;
	else
		shots = g_aSession[client][SHOTS];
	
	int rounds = g_aSession[client][ROUNDS_TR] + g_aSession[client][ROUNDS_CT];
	if((g_aSession[client][ROUNDS_TR] == 0) && (g_aSession[client][ROUNDS_CT] == 0))
	{
		rounds = 1;
	}
	
	int idamage = g_aSession[client][DAMAGE];
	float damage = IntToFloat(idamage);
	
	Format(temp,255,"%T   KDR: %.2f\n","KillsDeathsAssists",client,ikills,ideaths,g_aSession[client][ASSISTS],kills/deaths);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %d\n","Headshots", client, g_aSession[client][HEADSHOTS],"Suicides",client,g_aSession[client][SUICIDES],"TKs",client,g_aSession[client][TK]);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %.2f   %T: %.2f\n ","Damage", client, idamage,"KPR", client, kills/rounds,"DPR", client, damage/rounds);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";

	Format(temp,sizeof(temp),"- %T\n","RoundStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d/%d   %T: %d/%d   %T: %d\n ","TRWins",client,g_aSession[client][TR_WIN],g_aSession[client][ROUNDS_TR],"CTWins",client,g_aSession[client][CT_WIN],g_aSession[client][ROUNDS_CT],"MVPs",client,g_aSession[client][MVP]);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","HitStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %.2f%%\n ","Shots",client,shots,"Hits",client,g_aSession[client][HITS],"Accuracy",client,IntToFloat(g_aSession[client][HITS])/shots*100);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","BombHostagesStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %d\n","PlantedBombs",client,g_aSession[client][C4_PLANTED],"ExplodedBombs",client,g_aSession[client][C4_EXPLODED],"DefusedBombs",client,g_aSession[client][C4_DEFUSED]);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d","RescuedHostages",client,g_aSession[client][HOSTAGES_RESCUED]);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	if(g_bVipEnabled){
		Format(temp,sizeof(temp),"- %T\n","VIPStats",client);
		StrCat(text,255,temp);
		Format(temp,255,"%T: %d/%d   %T: %d\n ","VIPEscapes",client,g_aSession[client][VIP_ESCAPED],g_aSession[client][VIP_PLAYED],"VIPsKilled",client,g_aSession[client][VIP_KILLED]);
		StrCat(text,255,temp);
		panel.AddItem("",text);
		text="";
	}
	
	Format(temp,sizeof(temp),"- %T\n","OtherStats",client);
	StrCat(text,255,temp);
	int time = GetTime()-g_aSession[client][CONNECTED];
	int hours = RoundToFloor(time/3600.0);
	time = time-(hours*3600);
	
	int minutes = RoundToFloor(time/60.0);
	time = time-(minutes*60);
	
	Format(temp,255,"%T","TimeConnected",client,hours,minutes,time);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	panel.Pagination = 2;
	panel.Display(client,MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action CMD_HitBox(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	Menu panel = CreateMenuEx(_,MenuHandler_DoNothing,MENU_ACTIONS_ALL);
	char temp[255];
	int ihits;
	float hits;
	ihits = g_aHitBox[client][1]+g_aHitBox[client][2]+g_aHitBox[client][3]+g_aHitBox[client][4]+g_aHitBox[client][5]+g_aHitBox[client][6]+g_aHitBox[client][7];
	char text[255];
	if(ihits == 0)
		hits= 1.0;
	else
		hits = IntToFloat(ihits);
	
	Format(temp,255,"HitBox:\n");
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d (%.2f%%)\n","Head",client,g_aHitBox[client][1],(g_aHitBox[client][1]/hits)*100);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d (%.2f%%)\n","Chest",client,g_aHitBox[client][2],(g_aHitBox[client][2]/hits)*100);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d (%.2f%%)\n","Stomach",client,g_aHitBox[client][3],(g_aHitBox[client][3]/hits)*100);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d (%.2f%%)\n","LeftArm",client,g_aHitBox[client][4],(g_aHitBox[client][4]/hits)*100);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d (%.2f%%)\n","RightArm",client,g_aHitBox[client][5],(g_aHitBox[client][5]/hits)*100);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d (%.2f%%)\n","LeftLeg",client,g_aHitBox[client][6],(g_aHitBox[client][6]/hits)*100);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d (%.2f%%)","RightLeg",client,g_aHitBox[client][7],(g_aHitBox[client][7]/hits)*100);
	StrCat(text,255,temp);
	panel.AddItem("",text);

	panel.Display(client,MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public Action CMD_WeaponMe(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	int weapons_a[42];
	for(int a=0;a<42;a++){
		weapons_a[a] = g_aWeapons[client][a];
	}
	int weapons_b[42][2];
	int index;
	int start;
	bool indexs[42];
	for(int a =0; a<42;a++){
		index =Array_FindHighestValue(weapons_a, sizeof(weapons_a));
		weapons_b[a][0] = index;
		weapons_b[a][1] = weapons_a[index];
		if(weapons_a[index] == 0){
			start=a;
			break;
		}
		weapons_a[index] = 0;
		indexs[index]=true;
	}

	for(int b=0; b<42; b++){
	
		if(indexs[b] ==false){
			if(start <42)
				weapons_b[start][0]=b;
			
			start++;
		}
	}
	Menu panel = CreateMenu(MenuHandler_DoNothing);
	
	int ikills =g_aStats[client][KILLS];
	
	float hits;
	if(ikills == 0)
		hits= 1.0;
	else
		hits = IntToFloat(ikills);

	char temp[255];
	Format(temp,sizeof(temp),"%T","WeaponsStats",client);
	panel.SetTitle(temp);
	for(int i=0;i<42;i++){
		Format(temp,sizeof(temp),"%s: %d (%.2f%%)",g_sWeaponsNamesFull[weapons_b[i][0]],weapons_b[i][1],(weapons_b[i][1]/hits)*100);
		panel.AddItem(temp,temp,ITEMDRAW_DISABLED);
	}
	
	panel.Display(client,MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action CMD_StatsMe(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	if(g_RankMode == 1)
		Format(query,sizeof(query),"%s ORDER BY score DESC",query);
	else if(g_RankMode == 2){
		if(g_bMysql)
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as DECIMAL)/CAST(Case when deaths=0 then 1 ELSE deaths END as DECIMAL) DESC, score DESC",query);
		else
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as float)/CAST(Case when deaths=0 then 1 ELSE deaths END as float) DESC, score DESC",query);
	}	
	
	SQL_TQuery(g_hStatsDb,SQL_StatsMeCallback,query,client);
	return Plugin_Handled;
	
}

public Action CMD_StatsMe2(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
		
	char arg1[MAX_NAME_LENGTH];
	GetCmdArg(1,arg1,sizeof(arg1));
	StripQuotes(arg1);
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	
	char order[2000];
	if(g_RankMode == 1)
		Format(order,sizeof(order),"ORDER BY score DESC");
	else if(g_RankMode == 2){
		if(g_bMysql)
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as DECIMAL)/CAST(Case when deaths=0 then 1 ELSE deaths END as DECIMAL) DESC, score DESC",query);
		else
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as float)/CAST(Case when deaths=0 then 1 ELSE deaths END as float) DESC, score DESC",query);
	}	
	Handle hDatapack = CreateDataPack();
	
	WritePackCell(hDatapack,client);
	bool tn_is_ml;
	char tname[MAX_NAME_LENGTH];
	int targets[1];
	
	
	if(ProcessTargetString(arg1,0,targets,1,COMMAND_FILTER_NO_MULTI,tname,sizeof(tname),tn_is_ml) == 1){
		int target = targets[0];
	
		WritePackCell(hDatapack,0);
		Format(query,sizeof(query),"%s %s", query,order);
	
		WritePackCell(hDatapack,target);
		
	} else if(StrContains(arg1,"#",false) == 0) {
		
		WritePackCell(hDatapack,1);
		
		if(StringToInt(arg1[1]) > g_TotalPlayers)
			Format(arg1,sizeof(arg1),"#%d",g_TotalPlayers);
			
		Format(query,sizeof(query),"%s %s LIMIT %d, 1",query,order, StringToInt(arg1[1]) - 1);

		WritePackCell(hDatapack,StringToInt(arg1[1]));
		
	} else if(g_RankBy == 0 && StrContains(arg1,"STEAM_") == 0) {
		
		WritePackCell(hDatapack,2);
		
		Format(query,sizeof(query),"%s %s", query,order);
		
		WritePackString(hDatapack,arg1);
		
	} else {
		
		CloseHandle(hDatapack);
		
		CPrintToChat(client,"%s %T", MSG,"UsageStatsme2",client);
		
		return Plugin_Handled;
	}
	
	//PrintToServer(query);
	SQL_TQuery(g_hStatsDb,SQL_StatsMe2Callback,query,hDatapack);
	
	return Plugin_Handled;
	
}

public void SQL_StatsMe2Callback(Handle owner, Handle hndl, const char[] error, any hDatapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	
	ResetPack(hDatapack);
	
	int client = ReadPackCell(hDatapack);
	
	if(client == 0 || !IsClientInGame(client))
		return;
		
	int type = ReadPackCell(hDatapack);
	int i;
	
	char auth[64];
	char name[MAX_NAME_LENGTH];
	
	int target;
	
	if(type == 0){
		
		target = ReadPackCell(hDatapack);
		
		GetClientAuthId(target,AuthId_Steam2,auth,sizeof(auth));
		
		GetClientName(target,name,sizeof(name));
		
	} else if (type == 1) {
		
		i = ReadPackCell(hDatapack);
	
	} else if(type == 2) {
	
		ReadPackString(hDatapack,auth,sizeof(auth));
		
	}
	CloseHandle(hDatapack);
	char Auth_receive[64];
	char Name_receive[MAX_NAME_LENGTH];
	
	if(type != 1){
		
		while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			i++;
			SQL_FetchString(hndl,1,Auth_receive,64);
			
			SQL_FetchString(hndl,2,Name_receive,MAX_NAME_LENGTH);
			
			if((g_RankBy == 1 && StrEqual(name,Name_receive)) || (g_RankBy == 0 && StrEqual(Auth_receive,auth,false)))
				break;
		}

	} else if (SQL_HasResultSet(hndl)){
		SQL_FetchRow(hndl);
		SQL_FetchString(hndl,1,Auth_receive,64);
		
		SQL_FetchString(hndl,2,Name_receive,MAX_NAME_LENGTH);
	} else {
		return;
	}
	
	Menu panel = CreateMenuEx(_,MenuHandler_DoNothing,MENU_ACTIONS_ALL);
	
	panel.SetTitle(Name_receive);
	
	char text[255];
	int ikills = SQL_FetchInt(hndl,5);
	int ideaths= SQL_FetchInt(hndl,6);
	int deaths;
	if(ideaths == 0)
		deaths = 1;
	else 
		deaths=ideaths;
	float kills = IntToFloat(ikills);
	int shots = SQL_FetchInt(hndl,10);
	if(shots == 0)
		shots = 1;
	
	int rounds = SQL_FetchInt(hndl,14) + SQL_FetchInt(hndl,15);
	if((SQL_FetchInt(hndl,14) == 0) && (SQL_FetchInt(hndl,15) == 0))
	{
		rounds = 1;
	}

	int idamage = SQL_FetchInt(hndl,76);
	float damage = IntToFloat(idamage);
	
	int hits = SQL_FetchInt(hndl,11);
	char temp[255];
	Format(temp,sizeof(temp),"- %T\n","BasicStats",client);
	StrCat(text,255,temp);
	if(i == 0)
		Format(temp,sizeof(temp),"%T: %i\n","Points",client,SQL_FetchInt(hndl,4));
	else
		Format(temp,sizeof(temp),"Rank: %i/%i   %T: %i\n",i,g_TotalPlayers,"Points",client,SQL_FetchInt(hndl,4));
	StrCat(text,255,temp);
	Format(temp,255,"%T   KDR: %.2f\n","KillsDeathsAssists",client,ikills,ideaths,SQL_FetchInt(hndl,7),kills/deaths);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %d\n","Headshots", client, SQL_FetchInt(hndl,12),"Suicides",client,SQL_FetchInt(hndl,8),"TKs",client,SQL_FetchInt(hndl,9));
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %.2f   %T: %.2f\n","Damage", client, idamage,"KPR", client, kills/rounds, "DPR", client, damage/rounds);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d  \n ","First Bloods", client, SQL_FetchInt(hndl, 80));
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";

	Format(temp,sizeof(temp),"- %T\n","RoundStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d/%d   %T: %d/%d   %T: %d\n%T: %d   %T: %d   %T: %d\n ","TRWins",client,SQL_FetchInt(hndl,70),SQL_FetchInt(hndl,14),"CTWins",client,SQL_FetchInt(hndl,69),SQL_FetchInt(hndl,15),"MVPs",client,SQL_FetchInt(hndl,75), "MatchWins", client, SQL_FetchInt(hndl, 77), "MatchDraws", client, SQL_FetchInt(hndl, 78), "MatchLosses", client, SQL_FetchInt(hndl, 79));
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","HitStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %.2f%% \n ","Shots",client,shots,"Hits",client,hits,"Accuracy",client,IntToFloat(hits)/shots*100);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","NoScopeStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %.2fm \n ","NoScopes",client,SQL_FetchInt(hndl,81), "Farthest", client, IntToFloat(SQL_FetchInt(hndl,82))/100 );
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","BombHostagesStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %d\n","PlantedBombs",client,SQL_FetchInt(hndl,66),"ExplodedBombs",client,SQL_FetchInt(hndl,67),"DefusedBombs",client,SQL_FetchInt(hndl,68));
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d\n ","RescuedHostages",client,SQL_FetchInt(hndl,71));
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
				
	if(g_bVipEnabled){
		Format(temp,sizeof(temp),"- %T\n","VIPStats",client);
		StrCat(text,255,temp);
		Format(temp,255,"%T: %d/%d   %T: %d\n ","VIPEscapes",client,SQL_FetchInt(hndl,73),SQL_FetchInt(hndl,74),"VIPsKilled",client,SQL_FetchInt(hndl,72));
		StrCat(text,255,temp);
		panel.AddItem("",text);
		text="";
	}
	
	Format(temp,sizeof(temp),"- %T\n","OtherStats",client);
	StrCat(text,255,temp);
	
	int time = SQL_FetchInt(hndl,13);
	if(target != 0 && IsClientInGame(target))
		time += GetTime()-g_aSession[client][CONNECTED];
		
	int hours = RoundToFloor(time/3600.0);
	time = time-(hours*3600);
	
	int minutes = RoundToFloor(time/60.0);
	time = time-(minutes*60);
	
	Format(temp,255,"%T","TimeConnected",client,hours,minutes,time);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	panel.Pagination = 2;
	panel.Display(client,MENU_TIME_FOREVER);
}

public void SQL_StatsMeCallback(Handle owner, Handle hndl, const char[] error, any client){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	if(client == 0 || !IsClientInGame(client))
		return;
	int i;
	
	g_TotalPlayers =SQL_GetRowCount(hndl);
	char Auth_receive[64];
	char Name_receive[MAX_NAME_LENGTH];
	char Ip_receive[64];
	if(g_aStats[client][KILLS] >= g_MinimalKills){
		
		while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			i++;
			SQL_FetchString(hndl,1,Auth_receive,64);
			
			SQL_FetchString(hndl,2,Name_receive,MAX_NAME_LENGTH);
			
			SQL_FetchString(hndl,3,Ip_receive,64);
			
			if((g_RankBy == 1 && StrEqual(g_aClientName[client],Name_receive)) || (g_RankBy == 0 && StrEqual(Auth_receive,g_aClientSteam[client],false)) || (g_RankBy == 2 && StrEqual(Ip_receive,g_aClientIp[client],false)))
				break;
		}
	} else {
		i = 0;
	}
	Menu panel = CreateMenuEx(_,MenuHandler_DoNothing,MENU_ACTIONS_ALL);
	char text[255];
	int ikills = g_aStats[client][KILLS];
	int ideaths=g_aStats[client][DEATHS];
	int deaths;
	if(ideaths == 0)
		deaths = 1;
	else 
		deaths=ideaths;
	float kills = IntToFloat(ikills);
	int shots;
	if(g_aStats[client][SHOTS] == 0)
		shots = 1;
	else
		shots = g_aStats[client][SHOTS];
	
	int rounds = g_aStats[client][ROUNDS_TR] + g_aStats[client][ROUNDS_CT];
	if((g_aStats[client][ROUNDS_TR] ==0) && (g_aStats[client][ROUNDS_CT] == 0))
	{
		rounds = 1;
	}
	
	int idamage = g_aStats[client][DAMAGE];
	float damage = IntToFloat(idamage);

	char temp[255];
	Format(temp,sizeof(temp),"- %T\n","BasicStats",client);
	StrCat(text,255,temp);
	if(i == 0)
		Format(temp,sizeof(temp),"%T: %i [%i]\n","Points",client,g_aStats[client][SCORE],g_aSession[client][SCORE]);
	else
		Format(temp,sizeof(temp),"Rank: %i/%i   %T: %i [%i]\n",i,SQL_GetRowCount(hndl),"Points",client,g_aStats[client][SCORE],g_aSession[client][SCORE]);
	StrCat(text,255,temp);
	Format(temp,255,"%T   KDR: %.2f\n","KillsDeathsAssists",client,ikills,ideaths,g_aStats[client][ASSISTS],kills/deaths);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d  %T: %d  %T: %d\n","Headshots",client,g_aStats[client][HEADSHOTS],"Suicides",client,g_aStats[client][SUICIDES],"TKs",client,g_aStats[client][TK]);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d  %T: %.2f   %T: %.2f\n","Damage", client, idamage,"KPR", client, kills/rounds, "DPR", client, damage/rounds);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d  \n ","First Bloods", client, g_aStats[client][FB]);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","RoundStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d/%d   %T: %d/%d   %T: %d\n%T: %d   %T: %d   %T: %d \n ","TRWins",client,g_aStats[client][TR_WIN],g_aStats[client][ROUNDS_TR],"CTWins",client,g_aStats[client][CT_WIN],g_aStats[client][ROUNDS_CT],"MVPs",client,g_aStats[client][MVP], "MatchWins", client, g_aStats[client][MATCH_WIN], "MatchDraws", client, g_aStats[client][MATCH_DRAW], "MatchLosses", client, g_aStats[client][MATCH_LOSE]);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","HitStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %.2f%%\n ","Shots",client,shots,"Hits",client,g_aStats[client][HITS],"Accuracy",client,IntToFloat(g_aStats[client][HITS])/shots*100);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","NoScopeStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %.2fm \n ","NoScopes",client,g_aStats[client][NS], "Farthest", client, IntToFloat(g_aStats[client][NSD])/100 );
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	
	Format(temp,sizeof(temp),"- %T\n","BombHostagesStats",client);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d   %T: %d   %T: %d\n","PlantedBombs",client,g_aStats[client][C4_PLANTED],"ExplodedBombs",client,g_aStats[client][C4_EXPLODED],"DefusedBombs",client,g_aStats[client][C4_DEFUSED]);
	StrCat(text,255,temp);
	Format(temp,255,"%T: %d \n ","RescuedHostages",client,g_aStats[client][HOSTAGES_RESCUED]);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
				
	if(g_bVipEnabled){
		Format(temp,sizeof(temp),"- %T\n","VIPStats",client);
		StrCat(text,255,temp);
		Format(temp,255,"%T: %d/%d   %T: %d\n ","VIPEscapes",client,g_aStats[client][VIP_ESCAPED],g_aStats[client][VIP_PLAYED],"VIPsKilled",client,g_aStats[client][VIP_KILLED]);
		StrCat(text,255,temp);
		panel.AddItem("",text);
		text="";
	}
	
	Format(temp,sizeof(temp),"- %T\n","OtherStats",client);
	StrCat(text,255,temp);
	int time = g_aStats[client][CONNECTED] + GetTime()-g_aSession[client][CONNECTED];
	int hours = RoundToFloor(time/3600.0);
	time = time-(hours*3600);
	
	int minutes = RoundToFloor(time/60.0);
	time = time-(minutes*60);
	
	Format(temp,255,"%T","TimeConnected",client,hours,minutes,time);
	StrCat(text,255,temp);
	panel.AddItem("",text);
	text="";
	panel.Pagination = 2;
	panel.Display(client,MENU_TIME_FOREVER);
}

public int PanelNoHandle(Menu menu, MenuAction action, int param1, int param2){

	

}

public Action CMD_Next(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	if(g_RankMode == 1)
		Format(query,sizeof(query),"%s ORDER BY score DESC",query);
	else if(g_RankMode == 2){
		if(g_bMysql)
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as DECIMAL)/CAST(Case when deaths=0 then 1 ELSE deaths END as DECIMAL) DESC, score DESC",query);
		else
			Format(query,sizeof(query),"%s ORDER BY CAST(kills as float)/CAST(Case when deaths=0 then 1 ELSE deaths END as float) DESC, score DESC",query);
	}	
	
	SQL_TQuery(g_hStatsDb,SQL_NextCallback,query,client);
	return Plugin_Handled;
}

public void SQL_NextCallback(Handle owner, Handle hndl, const char[] error, any client){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	if(client == 0 || !IsClientInGame(client))
		return;
	int i;
	int a;
	g_TotalPlayers =SQL_GetRowCount(hndl);
	char next_players_name[10][MAX_NAME_LENGTH];
	int next_players_score[10];
	bool dobreak;
	
	char Auth_receive[64];
	char Name_receive[MAX_NAME_LENGTH];
	char Ip_receive[64];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		i++;
		
		SQL_FetchString(hndl,1,Auth_receive,64);
		SQL_FetchString(hndl,2,Name_receive,MAX_NAME_LENGTH);
		SQL_FetchString(hndl,3,Ip_receive,64);
		
		if((g_RankBy == 1 && StrEqual(g_aClientName[client],Name_receive)) || (g_RankBy == 0 && StrEqual(Auth_receive,g_aClientSteam[client],false)) || (g_RankBy == 2 && StrEqual(Ip_receive,g_aClientIp[client],false))){
		
			dobreak=true;
		
		}
		else {
		
			if(i<=10){
				SQL_FetchString(hndl,2,next_players_name[i-1],MAX_NAME_LENGTH-1);
				next_players_score[i-1]=SQL_FetchInt(hndl,4);
			}
			else {
				for(a=0;a<9;a++){
				
					next_players_score[a] = next_players_score[a+1];
					strcopy(next_players_name[a],MAX_NAME_LENGTH-1,next_players_name[a+1]);
				}
				SQL_FetchString(hndl,2,next_players_name[9],MAX_NAME_LENGTH-1);
				next_players_score[9]=SQL_FetchInt(hndl,4);
			}
		}
		if(dobreak)
			break;
	} 
	Menu panel = CreateMenuEx(_,MenuHandler_DoNothing,MENU_ACTIONS_ALL);
	char text[500];
	char temp[255];
	Format(temp,sizeof(temp),"%T\n","Next9Players",client);
	StrCat(text,255,temp);
	
	int max;
	if(i<10){
		max = i-1; 
	} else {
		max = 9;
	}
	for(int b=0;b<=max;b++){
		if(!StrEqual(next_players_name[b],"",false)){
			Format(temp,sizeof(temp),"- %s (%d) => +%d\n",next_players_name[b],next_players_score[b],next_players_score[b]-g_aStats[client][SCORE]);
			StrCat(text,500,temp);
		}
		
	}
	panel.AddItem("",text);
	panel.Display(client,MENU_TIME_FOREVER);
	
	CloseHandle(panel);
}

public Action CMD_ResetOwnRank(int client, int args){

	if(!g_bEnabled || !g_bResetOwnRank || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	char query[2000];
	if(g_RankBy == 1){
		char sEscape[MAX_NAME_LENGTH*2+1];
		SQL_EscapeString(g_hStatsDb,g_aClientName[client],sEscape,sizeof(sEscape));
		Format(query,sizeof(query),"DELETE FROM `%s` WHERE name='%s'",g_sSQLTable,sEscape);
	} else if(g_RankBy == 0){
		Format(query,sizeof(query),"DELETE FROM `%s` WHERE steam='%s'",g_sSQLTable,g_aClientSteam[client]);
	} else if(g_RankBy == 2){
		Format(query,sizeof(query),"DELETE FROM `%s` WHERE lastip='%s'",g_sSQLTable,g_aClientIp[client]);
	}
	SQL_TQuery(g_hStatsDb,SQL_NothingCallback,query);
	LogAction(client,-1,"[RankMe]: Reseted own rank (%s - %s - %s)",g_aClientName[client],g_aClientSteam[client],g_aClientIp[client]);
	OnClientPutInServer(client);
	CPrintToChat(client,"%s %T",MSG,"ResetMyRank", client);
	return Plugin_Handled;
}

public float IntToFloat(int integer){
	char s[300];
	IntToString(integer,s,sizeof(s));
	return StringToFloat(s);
}

public int FloatToInt(float ifloat){
	char s[300];
	FloatToString(ifloat,s,sizeof(s));
	return StringToInt(s);
}

public Action CMD_RankMe(int client, int args){

	Menu hMenu = CreateMenu(MenuHandler_RankMe);
	
	SetMenuExitButton(hMenu,true);
	
	hMenu.SetTitle("%t", "RankMe Menu");
	
	char myrank[512];
	Format(myrank, sizeof(myrank), "%t", "My Rank");
	hMenu.AddItem("rank", myrank);
	
	if(g_bResetOwnRank)
	{
		char resetmyrank[512];
		Format(resetmyrank, sizeof(resetmyrank), "%t", "Reset My Rank");
		hMenu.AddItem("resetmyrank", resetmyrank);
	}
	
	char mystats[512];
	Format(mystats, sizeof(mystats), "%t", "My Stats");
	hMenu.AddItem("statsme", mystats);
	
	char session[512];
	Format(session, sizeof(session), "%t", "Session");
	hMenu.AddItem("session", session);
	
	char otherstats[512];
	Format(otherstats, sizeof(otherstats), "%t", "Show Other Players Stats");
	hMenu.AddItem("statsme2", otherstats);
	
	char hitboxme[512];
	Format(hitboxme, sizeof(hitboxme), "%t", "My HitBox Stats");
	hMenu.AddItem("hitboxme", hitboxme);
	
	char weaponme[512];
	Format(weaponme, sizeof(weaponme), "%t", "My Weapon Stats");
	hMenu.AddItem("weaponme", weaponme);
	
	char next[512];
	Format(next, sizeof(next), "%t", "Show Players Above Me");
	hMenu.AddItem("next", next);
	
	char top10[512];
	Format(top10, sizeof(top10), "%t", "TOP 10");
	hMenu.AddItem("top10", top10);

	char topkills[512];
	Format(topkills, sizeof(topkills), "%t", "TOP Kills");
	hMenu.AddItem("topkills", topkills);

	char topdeaths[512];
	Format(topdeaths, sizeof(topdeaths), "%t", "TOP Deaths");
	hMenu.AddItem("topdeaths", topdeaths);
	
	char topassists[512];
	Format(topassists, sizeof(topassists), "%t", "TOP Assists");
	hMenu.AddItem("topassists", topassists);
	
	char tophs[512];
	Format(tophs, sizeof(tophs), "%t", "TOP HS");
	hMenu.AddItem("tophs", tophs);
	
	char topweapon[512];
	Format(topweapon, sizeof(topweapon), "%t", "TOP Weapon");
	hMenu.AddItem("topweapon", topweapon);
	
	char toptk[512];
	Format(toptk, sizeof(toptk), "%t", "TOP TK");
	hMenu.AddItem("toptk", toptk);
	
	char topmvp[512];
	Format(topmvp, sizeof(topmvp), "%t", "TOP MVP");
	hMenu.AddItem("topmvp", topmvp);
	
	char topdamage[512];
	Format(topdamage, sizeof(topdamage), "%t", "TOP Damage");
	hMenu.AddItem("topdamage", topdamage);
	
	char topacc[512];
	Format(topacc, sizeof(topacc), "%t", "TOP Accuracy");
	hMenu.AddItem("topacc", topacc);

	char toptime[512];
	Format(toptime, sizeof(toptime), "%t", "TOP Time Connected");
	hMenu.AddItem("toptime", toptime);

	char topkdr[512];
	Format(topkdr, sizeof(topkdr), "%t", "TOP KDR");
	hMenu.AddItem("topkdr", topkdr);

	char toppoints[512];
	Format(toppoints, sizeof(toppoints), "%t", "TOP Points");
	hMenu.AddItem("toppoints", toppoints);
	
	if(CheckCommandAccess(client, "sm_resetrank", ADMFLAG_ROOT))
	{
		char resetrank[512];
		Format(resetrank, sizeof(resetrank), "%t", "Reset a player rank");
		hMenu.AddItem("resetrank", resetrank);
	}	
	if(CheckCommandAccess(client, "sm_resetrank_all", ADMFLAG_ROOT))
	{
		char resetrankall[512];
		Format(resetrankall, sizeof(resetrankall), "%t", "Reset all the rank");
		hMenu.AddItem("resetrankall", resetrankall);
	}
	
	hMenu.Display(client,MENU_TIME_FOREVER);
}

public int MenuHandler_RankMe(Menu menu, MenuAction action, int client, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		
		if(StrEqual(temp,"rank"))
			CMD_Rank(client,0);
		
		else if(StrEqual(temp,"resetmyrank"))
			CMD_ResetOwnRank(client,0);
		
		else if(StrEqual(temp,"statsme"))
			CMD_StatsMe(client,0);
			
		else if(StrEqual(temp,"session"))
			CMD_Session(client,0);
		
		else if(StrEqual(temp,"hitboxme"))
			CMD_HitBox(client,0);
			
		else if(StrEqual(temp,"weaponme"))
			CMD_WeaponMe(client,0);
				
		else if(StrEqual(temp,"next"))
			CMD_Next(client,0);
		
		else if(StrEqual(temp,"top10"))
			ShowTOP(client,0);
			
		else if(StrEqual(temp,"topweapon"))
			CMD_TopWeapon(client,0);
		
		else if(StrEqual(temp,"topacc"))
			ShowTopAcc(client,0);
		
		else if(StrEqual(temp,"tophs"))
			ShowTopHS(client,0);
		
		else if(StrEqual(temp,"toptime"))
			ShowTopTime(client,0);
			
		else if(StrEqual(temp,"topkills"))
			ShowTopKills(client,0);
			
		else if(StrEqual(temp,"topdeaths"))
			ShowTopDeaths(client,0);
			
		else if(StrEqual(temp,"topassists"))
			ShowTopAssists(client,0);
			
		else if(StrEqual(temp,"toptk"))
			ShowTopTK(client,0);
			
		else if(StrEqual(temp,"topmvp"))
			ShowTopMVP(client,0);
			
		else if(StrEqual(temp,"topdamage"))
			ShowTopDamage(client,0);
		
		else if(StrEqual(temp,"topkdr"))
			ShowTOPKDR(client,0);

		else if(StrEqual(temp,"toppoints"))
			ShowTOPPoints(client,0);
			
		else if(StrEqual(temp,"resetrank")){
			
			Menu hMenu = CreateMenu(MenuHandler_TargetResetRank);
			AddTargetsToMenu2(hMenu,0,COMMAND_FILTER_NO_BOTS);
			
			hMenu.Display(client,MENU_TIME_FOREVER);
		}
		else if(StrEqual(temp,"statsme2")){
			
			Menu hMenu = CreateMenu(MenuHandler_TargetStatsMe2);
			AddTargetsToMenu2(hMenu,0,COMMAND_FILTER_NO_BOTS);
			
			hMenu.Display(client,MENU_TIME_FOREVER);
		}
		
		else if(StrEqual(temp,"resetrankall"))
			CMD_ResetRankAll(client,0);
		
		
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
	
}

public int MenuHandler_TargetResetRank(Menu menu, MenuAction action, int client, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		int target = GetClientOfUserId(StringToInt(temp));
		
		if(g_RankBy == 1){
			
			ClientCommand(client,"sm_resetrank \"%s\"",g_aClientName[target]);
		} else if(g_RankBy == 0){
			
			ClientCommand(client,"sm_resetrank \"%s\"",g_aClientSteam[target]);
		} else if(g_RankBy == 2){
			
			ClientCommand(client,"sm_resetrank \"%s\"",g_aClientIp[target]);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
	
}

public int MenuHandler_TargetStatsMe2(Menu menu, MenuAction action, int client, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		int target = GetClientOfUserId(StringToInt(temp));
		
		if(g_RankBy == 0 || g_RankBy == 2){
			
			ClientCommand(client,"sm_statsme2 \"%s\"",g_aClientName[target]);
		} else {
			
			ClientCommand(client,"sm_statsme2 \"%s\"",g_aClientSteam[target]);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
	
}

/* Assist */
public Action CMD_TopAssists(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopAssists(client,StringToInt(arg1));
	}	else {
		ShowTopAssists(client,0);
	}
	return Plugin_Handled;
}

void ShowTopAssists(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY assists DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopAssistsCallback,query,Datapack);

}

public void SQL_TopAssistsCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopAssists(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopAssists);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %t: %d\n",i+at,name,SQL_FetchInt(hndl,4),"Assists",SQL_FetchInt(hndl,7));
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopAssists(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopAssists(param1,StringToInt(temp)+1);
		} else {
			ShowTopAssists(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

/* Top TK */
public Action CMD_TopTK(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopTK(client,StringToInt(arg1));
	}	else {
		ShowTopTK(client,0);
	}
	return Plugin_Handled;
}

void ShowTopTK(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY tk DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopTKCallback,query,Datapack);

}

public void SQL_TopTKCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopTK(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopTK);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
	
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %t: %d\n",i+at,name,SQL_FetchInt(hndl,4),"TKs",SQL_FetchInt(hndl,9));
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopTK(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopTK(param1,StringToInt(temp)+1);
		} else {
			ShowTopTK(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

/* Top MVP */
public Action CMD_TopMVP(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopMVP(client,StringToInt(arg1));
	}	else {
		ShowTopMVP(client,0);
	}
	return Plugin_Handled;
}

void ShowTopMVP(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY mvp DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopMVPCallback,query,Datapack);

}

public void SQL_TopMVPCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopMVP(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopMVP);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
	
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %t: %d\n",i+at,name,SQL_FetchInt(hndl,4),"MVPs",SQL_FetchInt(hndl,73));
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopMVP(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopMVP(param1,StringToInt(temp)+1);
		} else {
			ShowTopMVP(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

/* Top Damage */
public Action CMD_TopDamage(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;

	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTopDamage(client,StringToInt(arg1));
	}	else {
		ShowTopDamage(client,0);
	}
	return Plugin_Handled;
}

void ShowTopDamage(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY damage DESC LIMIT %i, 10",query,at-1);
		
	SQL_TQuery(g_hStatsDb,SQL_TopDamageCallback,query,Datapack);

}

public void SQL_TopDamageCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTopDamage(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopDamage);
	
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
	
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - %t: %d\n",i+at,name,SQL_FetchInt(hndl,4),"Damage",SQL_FetchInt(hndl,74));
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);

	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopDamage(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTopDamage(param1,StringToInt(temp)+1);
		} else {
			ShowTopDamage(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}
/* KDR */
public Action CMD_TopKDR(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	
	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTOPKDR(client,StringToInt(arg1));
	}	else {
		ShowTOPKDR(client,0);
	}
	return Plugin_Handled;
}

void ShowTOPKDR(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	if(g_bMysql)
		Format(query,sizeof(query),"%s ORDER BY CAST(kills as DECIMAL)/CAST(Case when deaths=0 then 1 ELSE deaths END as DECIMAL) DESC, score DESC LIMIT %i, 10",query,at-1);
	else
		Format(query,sizeof(query),"%s ORDER BY CAST(kills as float)/CAST(Case when deaths=0 then 1 ELSE deaths END as float) DESC, score DESC LIMIT %i, 10",query,at-1);
	
	SQL_TQuery(g_hStatsDb,SQL_TopKDRCallback,query,Datapack);

}

public void SQL_TopKDRCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTOPKDR(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopKDR);
	
	float kdr;
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
		int deaths;
		if(SQL_FetchInt(hndl,6) == 0)
			deaths = 1;
		else 
			deaths=SQL_FetchInt(hndl,6);
		
		kdr = SQL_FetchFloat(hndl,5)/deaths;
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - KDR: %.2f\n",i+at,name,SQL_FetchInt(hndl,4),kdr);
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);
	
	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopKDR(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTOPKDR(param1,StringToInt(temp)+1);
		} else {
			ShowTOPKDR(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

/* Points */
public Action CMD_TopPoints(int client, int args){
	if(!g_bEnabled || client == 0 || !IsClientInGame(client))
		return Plugin_Handled;
	
	char arg1[5];
	GetCmdArg(1,arg1,sizeof(arg1));
	if(!StrEqual(arg1,"") && StringToInt(arg1) != 0){
		ShowTOPPoints(client,StringToInt(arg1));
	}	else {
		ShowTOPPoints(client,0);
	}
	return Plugin_Handled;
}

void ShowTOPPoints(int client, int at){
	if(client == 0 || !IsClientInGame(client))
		return;
	Handle Datapack= CreateDataPack();
	
	WritePackCell(Datapack,client);
	
	if(at>0){
		WritePackCell(Datapack,at-1);
	}	else {
		WritePackCell(Datapack,0);
		at = 1; // For not needing to build twice the query. (for at > 0 and at <= 0)
	}
	char query[2000];
	MakeSelectQuery(query,sizeof(query));
	Format(query,sizeof(query),"%s ORDER BY score DESC LIMIT %i, 10",query,at-1);
	SQL_TQuery(g_hStatsDb,SQL_TopPointsCallback,query,Datapack);
}

public void SQL_TopPointsCallback(Handle owner, Handle hndl, const char[] error, any Datapack){
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	
	ResetPack(Datapack);
	int i;
	int client = ReadPackCell(Datapack);
	if(client == 0 || !IsClientInGame(client))
		return;
	int at = ReadPackCell(Datapack);
	CloseHandle(Datapack);
	if(!SQL_HasResultSet(hndl) || SQL_GetRowCount(hndl) ==0){
		ShowTOPPoints(client,g_TotalPlayers-9);
		return;
	}
	char name[256];
	char temp[500];
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio),MenuHandler_TopPoints);
	
	float kdr;
	Format(temp,sizeof(temp)," %T\n","Showing",client,at+1,at+10,g_TotalPlayers);
	menu.SetTitle("");
	char sBuffer[200];
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		
		i++;
		
		SQL_FetchString(hndl,2,name,sizeof(name));
			
		
		int deaths;
		if(SQL_FetchInt(hndl,6) == 0)
			deaths = 1;
		else 
			deaths=SQL_FetchInt(hndl,6);
		
		kdr = SQL_FetchFloat(hndl,5)/deaths;
		Format(sBuffer,sizeof(sBuffer),"%d - %s (%d) - KDR: %.2f\n",i+at,name,SQL_FetchInt(hndl,4),kdr);
		
		if(strlen(temp)+strlen(sBuffer) < MAX_LENGTH_MENU){
			Format(temp,sizeof(temp),"%s%s",temp,sBuffer);
			sBuffer="\0";
		}
	} 
	Format(temp,sizeof(temp),"%s\n ",temp);
	menu.AddItem(temp,temp);
	
	
	IntToString(at+i,temp,sizeof(temp));
	char temp1[20];
	Format(temp1,sizeof(temp1),"%T","Next",client);
	if(i>9)
		menu.AddItem(temp,temp1);
	IntToString(at-i,temp,sizeof(temp));
	Format(temp1,sizeof(temp1),"%T","Back",client);
	if(at+i-1 >9)
		menu.AddItem(temp,temp1);
	
	menu.DisplayAt(client,at,MENU_TIME_FOREVER);
}

public int MenuHandler_TopPoints(Menu menu, MenuAction action, int param1, int param2){
	
	if (action == MenuAction_Select)
	{
		char temp[250];
	
		menu.GetItem(param2, temp, sizeof(temp));
		if(StringToInt(temp) >= 0){
			ShowTOPPoints(param1,StringToInt(temp)+1);
		} else {
			ShowTOPPoints(param1,0);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

// Code made by Antithasys
public Action OnSayText(int client, const char[] command, int argc)
{
	if (!g_bEnabled || !g_bChatTriggers || client == SENDER_WORLD || IsChatTrigger())
	{  // Don't parse if plugin is disabled or if is from the console or a chat trigger (e.g: ! or /)
		return Plugin_Continue;
	}
	
	char cpMessage[256];
	char sWords[64][256];
	GetCmdArgString(cpMessage, sizeof(cpMessage)); // Get the message
	StripQuotes(cpMessage); // Text come inside quotes
	//ReplaceString(cpMessage,sizeof(cpMessage),"\"","");
	ExplodeString(cpMessage, " ", sWords, sizeof(sWords), sizeof(sWords[])); // Explode it for use at top, topknife, topnade and topweapon
	
	// Proccess the text
	if (StrEqual(cpMessage, "rank", false))
	{
		//LogToFile("rankme.debug.log","\"rank\" chat hook called by client %d.",client);
		CMD_Rank(client, 0);
	}
	else if (StrEqual(cpMessage, "statsme", false))
	{
		CMD_StatsMe(client, 0);
	}
	else if (StrEqual(cpMessage, "hitboxme", false))
	{
		CMD_HitBox(client, 0);
	}
	else if (StrEqual(cpMessage, "weaponme", false))
	{
		CMD_WeaponMe(client, 0);
	}
	else if (StrEqual(cpMessage, "session", false))
	{
		CMD_Session(client, 0);
	}
	else if (StrEqual(cpMessage[0], "next", false))
	{
		CMD_Next(client, 0);
	}
	else if (StrContains(sWords[0], "toptk", false) == 0)
	{
		CMD_TopTK(client, 0);
	}
	else if (StrContains(sWords[0], "topmvp", false) == 0)
	{
		CMD_TopMVP(client, 0);
	}
	else if (StrContains(sWords[0], "topdamage", false) == 0)
	{
		CMD_TopDamage(client, 0);
	}
	else if (StrContains(sWords[0], "topkdr", false) == 0)
	{
		CMD_TopKDR(client, 0);
	}
	
	else if (StrContains(sWords[0], "tophs", false) == 0)
	{
		if (strcmp(cpMessage, "tophs") == 0)
		{
			ShowTopHS(client, 0);
		}
		else
		{
			ShowTopHS(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topkills", false) == 0)
	{
		if (strcmp(cpMessage, "topkills") == 0)
		{
			ShowTopKills(client, 0);
		}
		else
		{
			ShowTopKills(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topdeaths", false) == 0)
	{
		if (strcmp(cpMessage, "topdeaths") == 0)
		{
			ShowTopDeaths(client, 0);
		}
		else
		{
			ShowTopDeaths(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topassists", false) == 0)
	{
		if (strcmp(cpMessage, "topassists") == 0)
		{
			ShowTopAssists(client, 0);
		}
		else
		{
			ShowTopAssists(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topacc", false) == 0)
	{
		if (strcmp(cpMessage, "topacc") == 0)
		{
			ShowTopAcc(client, 0);
		}
		else
		{
			ShowTopAcc(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "toptime", false) == 0)
	{
		if (strcmp(cpMessage, "toptime") == 0)
		{
			ShowTopTime(client, 0);
		}
		else
		{
			ShowTopTime(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topweapon", false) == 0)
	{
		if (strcmp(cpMessage, "topweapon") == 0)
		{
			CMD_TopWeapon(client, 0); // Build the menu on the next frame
		}
		else
		{
			if (GetWeaponNum(sWords[1]) == 30)
			{
				CMD_TopWeapon(client, 0);
			}
			else
			{
				ShowTOPWeapon(client, GetWeaponNum(sWords[1]), StringToInt(sWords[2]));
			}
		}
	}
	else if (StrContains(sWords[0], "top", false) == 0)
	{
		if (strcmp(cpMessage, "top") == 0)
		{
			ShowTOP(client, 0);
		}
		else
		{
			ShowTOP(client, StringToInt(cpMessage[3]));
		}
	}
	return Plugin_Continue;
}

/* Hide Chat */
public Action CMD_HideChat(int client, int args){
	if(!hidechat[client]){
		SetClientCookie(client, hidechatcookie, "1");
		CPrintToChat(client, "%s %T", MSG, "Hide Rankme Chat", client);
		hidechat[client] = true;
	}
	else if(hidechat[client]){
		SetClientCookie(client, hidechatcookie, "0");
		CPrintToChat(client, "%s %T", MSG, "Show Rankme Chat", client);
		hidechat[client] = false;
	}
}