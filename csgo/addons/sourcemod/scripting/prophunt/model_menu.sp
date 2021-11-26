/* Build model menu*/

stock bool ReadModelConfig()
{
	g_bLoaded = false;
	
	delete g_mModelMenuAdmin;
	delete g_kvModels;
	
	g_mModelMenuAdmin = new Menu(Menu_ModelsAdmin);
	g_mModelMenuAdmin.SetTitle("Admin Model Menu");
	g_mModelMenuAdmin.ExitButton = true;
	
	char sPath[256], sDisplay[256], sMap[256];
	GetCurrentMap(sMap, sizeof(sMap));
	GetMapDisplayName(sMap, sDisplay, sizeof(sDisplay)); // Workshop map support
	
	g_iTotalModelsAvailable = 0;
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s/%s.cfg", MAP_CONFIG_PATH,  sDisplay);
	
	g_kvModels = CreateKeyValues("Models");
	FileToKeyValues(g_kvModels, sPath);
	
	char name[32], path[100], pathFull[100];
	
	// Reset arrays
	delete g_aModelIndex;
	delete g_aModelName;
	delete g_aModelHP;
	delete g_aModelSpeed;
	delete g_aModelGravity;
	
	// Create arrays
	g_aModelIndex = CreateArray(1);
	g_aModelName = CreateArray(32);
	g_aModelHP = CreateArray(1);
	g_aModelSpeed = CreateArray(1);
	g_aModelGravity = CreateArray(1);
	
	// Loop config entries
	KvGotoFirstSubKey(g_kvModels, false);
	do 
	{
		// get the model path and precache it
		KvGetSectionName(g_kvModels, path, sizeof(path));
		
		// Model Name
		// TODO translation support :3
		KvGetString(g_kvModels, "name", name, sizeof(name));
		
		// Prepare path
		ReplaceString(path, sizeof(path), ".mdl", "", false);
		FormatEx(pathFull, sizeof(pathFull), "models/%s.mdl", path);
		
		char sInfo[11];
		IntToString(g_iTotalModelsAvailable, sInfo, sizeof(sInfo));
		
		// Precache model
		if(!ValidateModel(pathFull))
			continue;
		
		g_mModelMenuAdmin.AddItem(sInfo, name);
		
		// Get settings
		int weight = KvGetNum(g_kvModels, "weight", 10);
		int HP = KvGetNum(g_kvModels, "hp", 100);
		float speed = KvGetFloat(g_kvModels, "speed", 1.0);
		float gravity = KvGetFloat(g_kvModels, "gravity", 1.0);
		
		// Add to pool
		for (int i = 0; i < weight; i++)
		{
			PushArrayCell(g_aModelIndex, g_iTotalModelsAvailable);
			PushArrayString(g_aModelName, name);
			PushArrayCell(g_aModelHP, HP);
			PushArrayCell(g_aModelSpeed, speed);
			PushArrayCell(g_aModelGravity, gravity);
		}
		g_iTotalModelsAvailable++;
	} while (KvGotoNextKey(g_kvModels, false));
	KvRewind(g_kvModels);
	
	// Prepare menu for all players
	LoopAlivePlayers(iClient)
	{
		if(GetClientTeam(iClient) == CS_TEAM_T)
			BuildModelMenu(iClient, true);
	}
	
	// Any models loaded?
	if (g_iTotalModelsAvailable == 0)
	{
		LogError("No models parsed in %s.cfg", sDisplay);
		return false;
	}
	else if (g_iTotalModelsAvailable < 15)
	{
		LogError("Not enough models parsed in %s.cfg: %i (min = 15).", sDisplay, g_iTotalModelsAvailable);
		return false;
	}
	
	g_bLoaded = true;
	
	return true;
}

stock void GetRandomModels(Handle list, int[] iOutput, int iNum, bool bUnique)
{
	//int iMax = GetArraySize(g_aModelIndex);
	int iMax = GetArraySize(list);
	
	// Loop aslong we don't have a unique set 
	for (int i = 0; i < iNum; i++)
	{
		iOutput[i] = GetRandomInt(0, iMax-1);
		
		// Ignore checks for first or a random model
		if(i == 0 || !bUnique)
			continue;
		
		// Check if random num is unique
		for (int x = 0; x <= i; x++)
		{
			//if(x != i && GetArrayCell(g_aModelIndex, iOutput[i]) == GetArrayCell(g_aModelIndex, iOutput[x]))
			if(x != i && GetArrayCell(list, iOutput[i]) == GetArrayCell(list, iOutput[x]))
			{
				i--; // Jump one back and cancel check
				break;
			}
		}
	}
}

/* Show model menu */

public Action Cmd_SelectModelMenu(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	if(iClient <= 0 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return Plugin_Handled;
	
	if (GetClientTeam(iClient) != CS_TEAM_T)
		return Plugin_Handled;
	
	ShowModelMenu(iClient);
	
	return Plugin_Handled;
}

bool ShowModelMenu(int iClient)
{
	if(g_cvHiderModels.IntValue < 2)
		return false;
	
	if (g_mModelMenu[iClient] == null)
		return false;
	
	int iTimeleft = GetHideTimeLeft() - 1;
	
	if (iTimeleft <= 0)
		return false;
	
	UpdateModelMenuTitle(iClient);
	return g_mModelMenu[iClient].Display(iClient, iTimeleft);
}

void UpdateModelMenuTitle(int iClient)
{
	char sBuffer[64];
	Format(sBuffer, sizeof(sBuffer), "Model: %s\nHP: %i\nSpeed: %i\n",
		m_sName[iClient], m_iHP[iClient], RoundToFloor((m_fSpeed[iClient]+0.001)*100.0));
	
	if(m_fGravity[iClient] != 1.0)
		Format(sBuffer, sizeof(sBuffer), "%sGravity: %i\n", sBuffer, RoundToFloor((m_fGravity[iClient]+0.001)*100.0));
	
	Format(sBuffer, sizeof(sBuffer), "%s\n ", sBuffer, RoundToFloor((m_fGravity[iClient]+0.001)*100.0));
		
	g_mModelMenu[iClient].SetTitle(sBuffer);
}

#define MAX_MENU_MODELS 10

void BuildModelMenu(int iClient, bool silent = false)
{
	delete g_mModelMenu[iClient];
	
	// Default amout of models to list
	int iModels = g_cvHiderModels.IntValue;
	
	// Forward
	Call_StartForward(g_OnBuildModelMenu);
	Call_PushCell(iClient);
	Call_PushCellRef(iModels);
	Call_Finish();
	
	// Limit max models
	if(iModels > 9)
		iModels = 9;
	
	// Generate random list
	int iRandom[MAX_MENU_MODELS];
	GetRandomModels(g_aModelIndex, iRandom, iModels, true); // unique
	
	g_mModelMenu[iClient] = new Menu(Menu_Models);
	UpdateModelMenuTitle(iClient);
	
	// No exit button and no pagination
	g_mModelMenu[iClient].ExitButton = false;
	SetMenuPagination(g_mModelMenu[iClient], MENU_NO_PAGINATION);
	
	// Add models
	for (int i = 0; i < iModels; i++)
	{
		char sName[64];
		GetArrayString(g_aModelName, iRandom[i], sName, sizeof(sName));
		
		char sText[256];
		Format(sText, sizeof(sText), "%s", sName);
		
		int iIndex = GetArrayCell(g_aModelIndex, iRandom[i]);
		
		char sInfo[11];
		IntToString(iIndex, sInfo, sizeof(sInfo));
		
		g_mModelMenu[iClient].AddItem(sInfo, sText);
	}
 
	if(!silent)
		ShowModelMenu(iClient);
}

public int Menu_Models(Menu menu, MenuAction action, int iClient, int iInfo)
{
	if (action == MenuAction_Select)
	{
		if(iClient <= 0 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
			return;
		
		if (GetClientTeam(iClient) != CS_TEAM_T)
			return;
		
		char sInfo[32];
		menu.GetItem(iInfo, sInfo, sizeof(sInfo));
		
		SetModel(iClient, StringToInt(sInfo));
		g_iModelChangeCount[iClient]++;
		
		ShowModelMenu(iClient);
	}
}

// Bot Only
public Action Timer_BotSetModel(Handle timer, int userid)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0)
		return Plugin_Handled;
	
	SetModel(iClient);
	
	return Plugin_Handled;
}

bool ValidateModel(char[] path)
{
	if(!FileExists(path, false) && !FileExists(path, true))
	{
		LogError("File not found or precached: \"%s\"", path);
		return false;
	}
	
	return PrecacheModel(path, true) > 0;
}

void ShowHelpMenu(int iClient)
{
	// show help menu on first spawn
	if (g_bFirstSpawn[iClient])
	{
		// TODO
		g_bFirstSpawn[iClient] = false;
	}
}

// set a (random) model to a client
void SetModel(int iClient, int index = -1)
{
	// give him a random one.
	char ModelPath[PLATFORM_MAX_PATH];
	
	if(index == -1)
		index = GetRandomInt(0, g_iTotalModelsAvailable - 1);
	
	KV_JumpTo(g_kvModels, index);
	
	KvGetSectionName(g_kvModels, ModelPath, sizeof(ModelPath));
	FormatEx(m_sModel[iClient], sizeof(m_sModel[]), "models/%s.mdl", ModelPath);
	
	KvGetString(g_kvModels, "name", m_sName[iClient], sizeof(m_sName[]), "*ERROR*");
	if(StrEqual(m_sName[iClient], "*ERROR*"))
	{
		LogError("No name found for \"%s\"", ModelPath);
		
		// Reset KV position
		KvRewind(g_kvModels);
		return;
	}
	
	m_iIndex[iClient] = index;
	
	m_fOffset[iClient][0] = KvGetFloat(g_kvModels, "offset_x", 0.0);
	m_fOffset[iClient][1] = KvGetFloat(g_kvModels, "offset_y", 0.0);
	m_fOffset[iClient][2] = KvGetFloat(g_kvModels, "offset_z", 0.0);
	
	m_fAngle[iClient][0] = KvGetFloat(g_kvModels, "rotation_x", 0.0);
	m_fAngle[iClient][1] = KvGetFloat(g_kvModels, "rotation_y", 0.0);
	m_fAngle[iClient][2] = KvGetFloat(g_kvModels, "rotation_z", 0.0);
	
	KvGetColor(g_kvModels, "color", m_iColor[iClient][0], m_iColor[iClient][1], m_iColor[iClient][2], m_iColor[iClient][3]);
	if(m_iColor[iClient][0] == 0 && m_iColor[iClient][1] == 0 && m_iColor[iClient][2] == 0 && m_iColor[iClient][3] == 0)
	{
		m_iColor[iClient][0] = 255;
		m_iColor[iClient][1] = 255;
		m_iColor[iClient][2] = 255;
		m_iColor[iClient][3] = 255;
	}
	
	m_iSkin[iClient] = KvGetNum(g_kvModels, "skin", 0);
	
	m_iWeight[iClient] = KvGetNum(g_kvModels, "weight", 10);
	
	m_iHP[iClient] = KvGetNum(g_kvModels, "hp", 100);
	SetEntityHealth(iClient, m_iHP[iClient]);
	
	m_fSpeed[iClient] = KvGetFloat(g_kvModels, "speed", 1.0);
	SpeedRules_ClientResetName(iClient, "hider_model"); // Remove speed rules of other models first
	SpeedRules_ClientAdd(iClient, "hider_model", SR_Base, m_fSpeed[iClient], -1.0, 0); // Set rule for base speed
	
	m_fGravity[iClient] = KvGetFloat(g_kvModels, "gravity", 1.0);
	SetEntityGravity(iClient, m_fGravity[iClient]);
	
	delete g_hAutoFreezeTimers[iClient];
	
	Client_ReCreateFakeProp(iClient);
	
	// Reset KV position
	KvRewind(g_kvModels);
	
	g_iModelChangeCount[iClient]++;
	
	// Show model name in chat
	CPrintToChat(iClient, "%s %t", PREFIX, "whoami", m_sName[iClient]);
	
	Call_StartForward(g_OnHiderSetModel);
	Call_PushCell(iClient);
	Call_Finish();
}

void SaveClientSpawnPosition(int iClient)
{
	Entity_GetAbsOriginAlt(iClient, g_fSpawnPosition[iClient]);
}