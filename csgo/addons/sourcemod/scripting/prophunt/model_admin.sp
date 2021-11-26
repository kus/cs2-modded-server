void ShowAdminMenu(int iClient)
{
	if(!Ready())
		return;
	
	g_iAdminSelectedMenuItem[iClient] = 0;
	g_mModelMenuAdmin.Display(iClient, MENU_TIME_FOREVER);
}

public int Menu_ModelsAdmin(Menu menu, MenuAction action, int iClient, int iInfo)
{
	if (action == MenuAction_Select)
	{
		if(iClient <= 0 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
			return;
		
		if (GetClientTeam(iClient) != CS_TEAM_T)
			return;
		
		char sInfo[32];
		menu.GetItem(iInfo, sInfo, sizeof(sInfo), _, m_sName[iClient], sizeof(sInfo));
		
		g_iAdminSelectedMenuItem[iClient] = iInfo;
		
		if(m_iIndex[iClient] != g_iAdminSelectedMenuItem[iClient])
		{
			SetModel(iClient, g_iAdminSelectedMenuItem[iClient]);
			g_mModelMenuAdmin.DisplayAt(iClient, GetFirstPageItem(g_iAdminSelectedMenuItem[iClient]), MENU_TIME_FOREVER);
		}
		else DisplayModelManager(iClient);
	}
}

void DisplayModelManager(int iClient, int iInfo = 0)
{
	// Menu
	Menu menu = new Menu(DisplayModelManager_Callback);
	menu.SetTitle("< Model Manager > ID: %i\nPath: %s", m_iIndex[iClient], m_sModel[iClient]);
	menu.ExitButton = true;
	
	char sBuffer[128];
	
	menu.AddItem("0", "Back");
	
	Format(sBuffer, sizeof(sBuffer), "Name: %s\nMax 32 chars", m_sName[iClient]);
	menu.AddItem("1", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "Weight: %d\nDefault 10 / Min 1 / Max 50", m_iWeight[iClient]);
	menu.AddItem("13", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "HP: %i\nDefault 100 / Min 1 / Max 500", m_iHP[iClient]);
	menu.AddItem("2", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Speed: %.1f\nDefault 1.0 / Min 0.3 / Max 1.5", m_fSpeed[iClient]);
	menu.AddItem("4", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Gravity: %.1f\nDefault 1.0 / Min 0.5 / Max 1.5", m_fGravity[iClient]);
	menu.AddItem("5", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Position (Towards/Away): %.1f\nDefault 0", m_fOffset[iClient][0]);
	menu.AddItem("7", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Position (Right/Left): %.1f\nDefault 0", m_fOffset[iClient][1]);
	menu.AddItem("8", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Position (Up/Down): %.1f\nDefault 0", m_fOffset[iClient][2]);
	menu.AddItem("6", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Rotation (Top): %.1f\nDefault 0 / Min -180 / Max 180", m_fAngle[iClient][1]);
	menu.AddItem("10", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Rotation (Front): %.1f\nDefault 0 / Min -180 / Max 180", m_fAngle[iClient][2]);
	menu.AddItem("11", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Rotation (Side): %.1f\nDefault 0 / Min -180 / Max 180", m_fAngle[iClient][0]);
	menu.AddItem("9", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Skin: %d\nDefault 0 / Depends on the model", m_iSkin[iClient]);
	menu.AddItem("12", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Color: %d %d %d\nR: 0-255 G: 0-255 B: 0-255", m_iColor[iClient][0], m_iColor[iClient][1], m_iColor[iClient][2]);
	menu.AddItem("14", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Add to Map (Permanent)");
	menu.AddItem("15", sBuffer);
	
	Format(sBuffer, sizeof(sBuffer), "Add to Map (Random)");
	menu.AddItem("16", sBuffer);
	
	menu.DisplayAt(iClient, GetFirstPageItem(iInfo), MENU_TIME_FOREVER);
}

public int DisplayModelManager_Callback(Menu menu, MenuAction action, int iClient, int iInfo)
{
	if (action == MenuAction_Select)
	{
		char sInfo[32];
		menu.GetItem(iInfo, sInfo, sizeof(sInfo));
		
		int iMode = StringToInt(sInfo);
		
		g_iAdminSelectedMenuItemSub[iClient] = iInfo;
		g_iAdminSelectedMenuMode[iClient] = iMode;
		
		if(iMode == 0)
			g_mModelMenuAdmin.DisplayAt(iClient, GetFirstPageItem(g_iAdminSelectedMenuItem[iClient]), MENU_TIME_FOREVER);
		else if(iMode == 15)
		{
			if(Client_IsFreezed(iClient))
			{
				PrintToChat(iClient, "%t", "The model has been saved and will be spawned here every round!");
				AddMapModel(iClient, false);
			}
			else PrintToChat(iClient, "%t", "You need to freeze first before you can do this!");
			DisplayModelManager(iClient, g_iAdminSelectedMenuItemSub[iClient]);
		}
		else if(iMode == 16)
		{
			if(Client_IsFreezed(iClient))
			{
				PrintToChat(iClient, "%t", "The model has been saved and will be spawned here randomly per round!");
				AddMapModel(iClient, true);
			}
			else PrintToChat(iClient, "%t", "You need to freeze first before you can do this!");
			DisplayModelManager(iClient, g_iAdminSelectedMenuItemSub[iClient]);
		}
		else 
		{
			PrintToChat(iClient, "%t", "Write the new setting to chat or abort");
			DisplayModelManager(iClient, iInfo);
		}
		
	}
	else if(action == MenuAction_End)
		delete menu;
}

public Action Command_Say(int iClient, const char[] command, int argc)
{
	if(!Ready())
		return Plugin_Continue;
	
	// Ignore console
	if(!iClient || g_iAdminSelectedMenuMode[iClient] == 0)
		return Plugin_Continue;
	
	char aArgs[128], sBuffer[32];
	GetCmdArgString(aArgs, sizeof(aArgs));
	BreakString(aArgs, sBuffer, sizeof(sBuffer));
	
	if(strlen(sBuffer) < 1)
	{
		PrintToChat(iClient, "Input Aborted: Invalid param: \"%s\"", sBuffer);
		g_iAdminSelectedMenuMode[iClient] = 0;
		return Plugin_Handled;
	}
	
	if(StrEqual(sBuffer, "abort") || StrEqual(sBuffer, "no") ||StrEqual(sBuffer, "none"))
	{
		PrintToChat(iClient, "Input Aborted");
		g_iAdminSelectedMenuMode[iClient] = 0;
		return Plugin_Handled;
	}
	
	// Backup before editing
	BackupMapConfig();
	
	KV_JumpTo(g_kvModels, m_iIndex[iClient]);
	
	switch(g_iAdminSelectedMenuMode[iClient])
	{
		case 1: // Name
		{
			KvSetString(g_kvModels, "name", sBuffer);
			PrintToChat(iClient, "%t", "Name set to", sBuffer);
		}
		case 2: // HP
		{
			if(String_IsNumeric(sBuffer) && StringToInt(sBuffer) > 0)
			{
				KvSetNum(g_kvModels, "hp", StringToInt(sBuffer));
				PrintToChat(iClient, "%t", "HP set to", StringToInt(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 3: // HP MAX
		{
			if(String_IsNumeric(sBuffer) && StringToInt(sBuffer) > 0)
			{
				KvSetNum(g_kvModels, "hp_max", StringToInt(sBuffer));
				PrintToChat(iClient, "%t", "Max HP set to", StringToInt(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 4: // Speed
		{
			if(String_IsNumeric(sBuffer) && StringToFloat(sBuffer) > 0)
			{
				KvSetFloat(g_kvModels, "speed", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Speed set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 5: // Gravity
		{
			if(String_IsNumeric(sBuffer) && StringToFloat(sBuffer) > 0)
			{
				KvSetFloat(g_kvModels, "gravity", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Gravity set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 6: // Height
		{
			if(String_IsNumeric(sBuffer))
			{
				KvSetFloat(g_kvModels, "offset_z", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Height set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 7: // Off - X
		{
			if(String_IsNumeric(sBuffer))
			{
				KvSetFloat(g_kvModels, "offset_x", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Offset x set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 8: // Off - Y
		{
			if(String_IsNumeric(sBuffer))
			{
				KvSetFloat(g_kvModels, "offset_y", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Offset y set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 9: // Rot - X
		{
			if(String_IsNumeric(sBuffer) && -180.0 <= StringToFloat(sBuffer) <= 180.0)
			{
				KvSetFloat(g_kvModels, "rotation_x", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Rotation X set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 10: // Rot - Y
		{
			if(String_IsNumeric(sBuffer) && -180.0 <= StringToFloat(sBuffer) <= 180.0)
			{
				KvSetFloat(g_kvModels, "rotation_y", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Rotation Y set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 11: // Rot - Z
		{
			if(String_IsNumeric(sBuffer) && -180.0 <= StringToFloat(sBuffer) <= 180.0)
			{
				KvSetFloat(g_kvModels, "rotation_z", StringToFloat(sBuffer));
				PrintToChat(iClient, "%t", "Rotation Z set to", StringToFloat(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 12: // Skin
		{
			if(String_IsNumeric(sBuffer) && StringToInt(sBuffer) >= 0)
			{
				KvSetNum(g_kvModels, "skin", StringToInt(sBuffer));
				PrintToChat(iClient, "%t", "Skin set to", StringToInt(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 13: // Weight
		{
			if(String_IsNumeric(sBuffer) && StringToInt(sBuffer) > 0)
			{
				KvSetNum(g_kvModels, "weight", StringToInt(sBuffer));
				PrintToChat(iClient, "%t", "Weight set to", StringToInt(sBuffer));
			}
			else CPrintToChat(iClient, "Invalid number: \"%s\"", sBuffer);
		}
		case 14: // Color
		{
			char sColor[3][8];
			ExplodeString(sBuffer, " ", sColor, 3, 8);
			int iColor[3];
			iColor[0] = StringToInt(sColor[0]);
			iColor[1] = StringToInt(sColor[1]);
			iColor[2] = StringToInt(sColor[2]);
			
			if(0 <= iColor[0] <= 255 && 0 <= iColor[1] <= 255 && 0 <= iColor[2] <= 255)
			{
				char sColor2[32];
				Format(sColor2, sizeof(sColor2), "%i %i %i 255", iColor[0], iColor[1], iColor[2]);
				KvSetString(g_kvModels, "color", sColor2);
				PrintToChat(iClient, "%t", "Color set to", iColor[0], iColor[1], iColor[2]);
			}
			else CPrintToChat(iClient, "Invalid color: \"%s\"", sBuffer);
		}
	}
	
	g_iAdminSelectedMenuMode[iClient] = 0;
	
	KvRewind(g_kvModels);
	
	char sPath[256], sDisplay[256], sMap[256];
	GetCurrentMap(sMap, sizeof(sMap));
	GetMapDisplayName(sMap, sDisplay, sizeof(sDisplay)); // Workshop map support
	
	BuildPath(Path_SM, sPath, 255, "%s/%s.cfg", MAP_CONFIG_PATH, sDisplay);
	
	KeyValuesToFile(g_kvModels, sPath);
	
	ReadModelConfig();
	
	SetModel(iClient, m_iIndex[iClient]);
	
	DisplayModelManager(iClient, g_iAdminSelectedMenuItemSub[iClient]);

	return Plugin_Handled;
}
	
void BackupMapConfig()
{
	char sPath[256], sDisplay[256], sMap[256];
	GetCurrentMap(sMap, sizeof(sMap));
	GetMapDisplayName(sMap, sDisplay, sizeof(sDisplay)); // Workshop map support
	
	char sTime[32];
	FormatTime(sTime, sizeof(sTime), "%Y-%m-%d_%H-%M-%S", GetTime());
	
	BuildPath(Path_SM, sPath, 255, "%s/%s_%s.cfg", MAP_CONFIG_PATH, sDisplay, sTime);
	
	KeyValuesToFile(g_kvModels, sPath);
}