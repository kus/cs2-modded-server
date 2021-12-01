stock void ReadMapModelConfig()
{
	RemoveMapModels();
	
	g_iMapModelsID = 0;
	
	delete g_kvMapModels;
	
	char sPath[256], sDisplay[256], sMap[256];
	GetCurrentMap(sMap, sizeof(sMap));
	GetMapDisplayName(sMap, sDisplay, sizeof(sDisplay)); // Workshop map support
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s/%s_static.cfg", MAP_CONFIG_PATH,  sDisplay);
	
	g_kvMapModels = CreateKeyValues("Models");
	if(!FileToKeyValues(g_kvMapModels, sPath))
		KeyValuesToFile(g_kvMapModels, sPath);
	
	// Precache models
	char path[255], sID[32];
	
	KvGotoFirstSubKey(g_kvMapModels, false);
	do 
	{
		KvGetSectionName(g_kvMapModels, sID, sizeof(sID));
		
		int iID = StringToInt(sID);
		
		if(iID > g_iMapModelsID)
			g_iMapModelsID = iID;
		
		// get the model path and precache it
		KvGetString(g_kvMapModels, "path", path, sizeof(path), "error");
		
		if(!StrEqual(path, "error"))
			ValidateModel(path);
		
	} while (KvGotoNextKey(g_kvMapModels, false));
	KvRewind(g_kvMapModels);
}

void SpawnMapModels()
{
	if(g_iMapModelsID == 0)
		return;
	
	int iCount;
	
	char path[255];
	KvGotoFirstSubKey(g_kvMapModels, false);
	do 
	{
		// get the model path and precache it
		KvGetString(g_kvMapModels, "path", path, sizeof(path), "error");
		
		int iRandom = KvGetNum(g_kvMapModels, "random", 0);
		
		if(!StrEqual(path, "error") && GetRandomInt(1, 100) <= iRandom && (iCount < 50 || iRandom == 100))
		{
			iCount++;
			
			float fPos[3];
			fPos[0] = KvGetFloat(g_kvMapModels, "pos_x", 0.0);
			fPos[1] = KvGetFloat(g_kvMapModels, "pos_y", 0.0);
			fPos[2] = KvGetFloat(g_kvMapModels, "pos_z", 0.0);
			
			float fAngle[3];
			fAngle[0] = KvGetFloat(g_kvMapModels, "angle_x", 0.0);
			fAngle[1] = KvGetFloat(g_kvMapModels, "angle_xy", 0.0);
			fAngle[2] = KvGetFloat(g_kvMapModels, "angle_xz", 0.0);
			
			int iSkin;
			iSkin = KvGetNum(g_kvMapModels, "skin", 0);
			
			int iColor[4];
			iColor[0] = KvGetNum(g_kvMapModels, "color_r", 255);
			iColor[1] = KvGetNum(g_kvMapModels, "color_g", 255);
			iColor[2] = KvGetNum(g_kvMapModels, "color_b", 255);
			iColor[3] = KvGetNum(g_kvMapModels, "color_a", 255);
			
			SpawnMapModel(path, fPos, fAngle, iSkin, iColor);
		}
		
	} while (KvGotoNextKey(g_kvMapModels, false));
	KvRewind(g_kvMapModels);
}

void AddMapModel(int iClient, bool random)
{
	int iChild = Client_GetFakeProp(iClient);
	
	if(iChild <= 0)
		return;
	
	float fPos[3];
	Entity_GetAbsOrigin(iChild, fPos);
	
	float fAngles[3];
	Entity_GetAbsAngles(iChild, fAngles);
	
	/**/
	
	g_iMapModelsID++;
	
	char sInfo[32];
	IntToString(g_iMapModelsID, sInfo, sizeof(sInfo));
	
	KvJumpToKey(g_kvMapModels, sInfo, true);
	
	KvSetSectionName(g_kvMapModels, sInfo);
	
	// get the model path and precache it
	KvSetString(g_kvMapModels, "path", m_sModel[iClient]);
	
	KvSetFloat(g_kvMapModels, "pos_x", fPos[0]);
	KvSetFloat(g_kvMapModels, "pos_y", fPos[1]);
	KvSetFloat(g_kvMapModels, "pos_z", fPos[2]);
	
	KvSetFloat(g_kvMapModels, "angle_x", m_fFreezeAngle[iClient][0]);
	KvSetFloat(g_kvMapModels, "angle_xy", m_fFreezeAngle[iClient][1]);
	KvSetFloat(g_kvMapModels, "angle_xz", m_fFreezeAngle[iClient][2]);
	
	KvSetNum(g_kvMapModels, "skin", m_iSkin[iClient]);
	
	KvSetNum(g_kvMapModels, "random", random ? 30 : 100);
	
	KvSetNum(g_kvMapModels, "color_r", m_iColor[iClient][0]);
	KvSetNum(g_kvMapModels, "color_g", m_iColor[iClient][1]);
	KvSetNum(g_kvMapModels, "color_b", m_iColor[iClient][2]);
	KvSetNum(g_kvMapModels, "color_a", m_iColor[iClient][3]);
	
	KvRewind(g_kvMapModels);
	
	char sPath[256], sDisplay[256], sMap[256];
	GetCurrentMap(sMap, sizeof(sMap));
	GetMapDisplayName(sMap, sDisplay, sizeof(sDisplay)); // Workshop map support
	
	BuildPath(Path_SM, sPath, 255, "%s/%s_static.cfg", MAP_CONFIG_PATH,  sDisplay);
	
	KeyValuesToFile(g_kvMapModels, sPath);
	ReadMapModelConfig();
}

void SpawnMapModel(char[] path, float fPos[3], float fAngle[3], int iSkin, int iColor[4])
{
	static int iFreeze = -1;
	
	if(iFreeze == -1)
		iFreeze = FindSendPropInfo("CBasePlayer", "m_fFlags");
	
	int iEntity = CreateEntityByName("prop_physics_override");
	
	DispatchKeyValue(iEntity, "physdamagescale", "0.0");
	DispatchKeyValue(iEntity, "model", path);
	SetEntityMoveType(iEntity, MOVETYPE_NONE);
	
	DispatchSpawn(iEntity);
	
	SetEntData(iEntity, iFreeze, FL_CLIENT | FL_ATCONTROLS, 4, true);
	SetEntityMoveType(iEntity, MOVETYPE_NONE);
	
	SetEntProp(iEntity, Prop_Send, "m_nSkin", iSkin);
	
	FX_Render(iEntity, view_as<FX>(FxDistort), iColor[0], iColor[1], iColor[2], view_as<Render>(RENDER_TRANSADD), iColor[3]);
	
	TeleportEntity(iEntity, fPos, fAngle, NULL_VECTOR);
	
	g_aMapModels.Push(EntIndexToEntRef(iEntity));
}

void RemoveMapModels()
{
	if(g_aMapModels == null)
	{
		g_aMapModels = new ArrayList();
		return;
	}
	
	int iEntity;
	
	LoopArray(iIndex, g_aMapModels)
	{
		iEntity = EntRefToEntIndex(g_aMapModels.Get(iIndex));
		
		if(iEntity != INVALID_ENT_REFERENCE)
		{
			AcceptEntityInput(iEntity, "Kill");
		}
	}
	
	g_aMapModels.Clear();
}