void StartPointsTimer()
{
	CreateTimer(1.0, Timer_GivePoints, _, TIMER_REPEAT);
}

/* Helpers */

void CreateShopList()
{
	if(g_aShopName != null)
		return;
	
	g_aShopName = new ArrayList(32);
	g_aShopTeam = new ArrayList();
	g_aShopPoints = new ArrayList();
	g_aShopSort = new ArrayList();
	g_aShopUnlockTime = new ArrayList();
	g_aShopReqFrozen = new ArrayList();
	g_aShopItemDisabled = new ArrayList();
	
	LoopClients(iClient)
		g_aClientShopItemDisabled[iClient] = new ArrayList(32);
}

float GetPoints(int iClient)
{
	return g_fPoints[iClient];
}

float AddPoints(int iClient, float fPoints)
{
	g_fPoints[iClient] += fPoints;
	return g_fPoints[iClient];
}

float SetPoints(int iClient, float fPoints)
{
	g_fPoints[iClient] = fPoints;
	return g_fPoints[iClient];
}

float TakePoints(int iClient, float fPoints)
{
	g_fPoints[iClient] -= fPoints;
	
	if(g_fPoints[iClient] < 0.0)
		g_fPoints[iClient] = 0.0;
	
	return g_fPoints[iClient];
}

void SortStopItems()
{
	for(int j = 0; j < g_aShopName.Length - 1; j++)
	{
		for(int i = 0; i < g_aShopName.Length - 1; i++)
		{
			if(i > 0 && TrySwitch(i, i - 1))
				 i = 0;
			else if(i < g_aShopName.Length - 1 && TrySwitch(i, i + 1))
				i = 0;
		}
	}
}

bool TrySwitch(int i1, int i2)
{
	// Custom
	if(g_cvShopSortMode.IntValue == 0)
	{
		if((i1 < i2 && g_aShopSort.Get(i1) > g_aShopSort.Get(i2)) || (i1 > i2 && g_aShopSort.Get(i1) < g_aShopSort.Get(i2)))
		{
			Switch(i1, i2);
			return true;
		}
	}
	// Price ASC
	else if(g_cvShopSortMode.IntValue == 1)
	{
		if((i1 < i2 && g_aShopPoints.Get(i1) > g_aShopPoints.Get(i2)) || (i1 > i2 && g_aShopPoints.Get(i1) < g_aShopPoints.Get(i2)))
		{
			Switch(i1, i2);
			return true;
		}
	}
	// Price DESC
	else if(g_cvShopSortMode.IntValue == 2)
	{
		if((i1 > i2 && g_aShopPoints.Get(i1) < g_aShopPoints.Get(i2)) || (i1 < i2 && g_aShopPoints.Get(i1) > g_aShopPoints.Get(i2)))
		{
			Switch(i1, i2);
			return true;
		}
	}
	
	return false;
}

void Switch(int i1, int i2)
{
	g_aShopName.SwapAt(i1, i2);
	g_aShopTeam.SwapAt(i1, i2);
	g_aShopPoints.SwapAt(i1, i2);
	g_aShopSort.SwapAt(i1, i2);
	g_aShopUnlockTime.SwapAt(i1, i2);
	g_aShopReqFrozen.SwapAt(i1, i2);
}

/* Add new shoop item */

int RegisterShopItem(char sName[32], int iTeam, int iPoints, int iSort, int iUnlockTime, bool reqFrozen)
{
	if(iPoints <= -1)
		return -1;
	
	int iIndex = g_aShopName.FindString(sName);
	if(iIndex != -1)
	{
		g_aShopTeam.Set(iIndex, iTeam);
		g_aShopPoints.Set(iIndex, iPoints);
		g_aShopSort.Set(iIndex, iSort);
		g_aShopUnlockTime.Set(iIndex, iUnlockTime);
		g_aShopReqFrozen.Set(iIndex, reqFrozen);
		return iIndex;
	}
	
	g_aShopName.PushString(sName);
	
	g_aShopTeam.Push(iTeam);
	g_aShopPoints.Push(iPoints);
	g_aShopSort.Push(iSort);
	g_aShopUnlockTime.Push(iUnlockTime);
	g_aShopReqFrozen.Push(reqFrozen);
	
	iIndex = g_aShopName.FindString(sName);
	
	return iIndex;
}

/* Shop */

void Menu_Shop(int iClient)
{
	if(!Ready())
		return;
	
	int iTeam = GetClientTeam(iClient);
	
	if(iTeam <= CS_TEAM_SPECTATOR)
		return;
		
	if(g_cvShopEnable.IntValue != 1 && g_cvShopEnable.IntValue != iTeam)
		return;
	
	if(!IsPlayerAlive(iClient))
		return;
	
	if(PH_CanChangeModel() > 0 && iTeam == CS_TEAM_T)
	{
		FakeClientCommand(iClient, "hide");
		return;
	}
		
	Menu menu = new Menu(MenuHandler_ShopMain);
	
	if(iTeam == CS_TEAM_T)
		menu.SetTitle("Hider Shop\n", RoundToFloor(g_fPoints[iClient]));
	else menu.SetTitle("Seeker Shop\n", RoundToFloor(g_fPoints[iClient]));
	
	char sBuffer[64];
	for (int iItem = 0; iItem < g_aShopName.Length; iItem++)
	{
		// Check team
		int iTeam2 = g_aShopTeam.Get(iItem);
		
		if(iTeam != iTeam2 && iTeam2 > CS_TEAM_SPECTATOR)
			continue;
		
		char sName[32];
		g_aShopName.GetString(iItem, sName, sizeof(sName));
		
		// Item disabled for all players
		if(g_aShopItemDisabled.FindString(sName) != -1)
			continue;
		
		// Item disabled for this player
		if(g_aClientShopItemDisabled[iClient].FindString(sName) != -1)
			continue;
		
		// Item unlocked by round time
		int iUnlockTime = g_aShopUnlockTime.Get(iItem);
		
		// Shop item disabled by cvar?
		if(iUnlockTime < 0)
			continue;
		
		bool bUnlocked = iUnlockTime <= GetTime() - g_iRoundStart;
		
		if(!bUnlocked)
			continue;
		
		int iPrice = g_aShopPoints.Get(iItem);
		
		if(iPrice == 0)
			Format(sBuffer, sizeof(sBuffer), "free - %s", sName);
		else Format(sBuffer, sizeof(sBuffer), "$%i - %s", iPrice, sName);
		
		menu.AddItem(sName, sBuffer, !bUnlocked  ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	
	SetMenuExitButton(menu, true);
	
	menu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_ShopMain(Menu menu, MenuAction action, int iClient, int iInfo)
{
	if (action == MenuAction_Select)
	{
		if(!IsPlayerAlive(iClient))
			return;
		
		char sInfo[32];
		menu.GetItem(iInfo, sInfo, sizeof(sInfo));
		
		int iIndex = g_aShopName.FindString(sInfo);
		
		if(iIndex == -1)
			return;
		
		if(GetClientTeam(iClient) != g_aShopTeam.Get(iIndex))
			return;
		
		if(g_aShopItemDisabled.FindString(sInfo) != -1)
		{
			CPrintToChat(iClient, "%s %t", PREFIX , "Buy Disabled");
			return;
		}
		
		if(g_aClientShopItemDisabled[iClient].FindString(sInfo) != -1)
		{
			CPrintToChat(iClient, "%s %t", PREFIX , "Buy Disabled2");
			return;
		}
		
		// Item unlocked by round time
		int iUnlockTime = g_aShopUnlockTime.Get(iIndex);
		bool bUnlocked = iUnlockTime <= GetTime() - g_iRoundStart;
		
		if(!bUnlocked)
		{
			CPrintToChat(iClient, "%s %t", PREFIX , "Not Unlocked");
			return;
		}
		
		// This item requires the player to be frozen
		bool bReqFrozen = g_aShopReqFrozen.Get(iIndex);
		if(bReqFrozen && !PH_IsFrozen(iClient))
		{
			CPrintToChat(iClient, "%s %t", PREFIX , "Req Frozen");
			return;
		}
		
		int iPoints = RoundToFloor(g_fPoints[iClient]);
		int iPrice = g_aShopPoints.Get(iIndex);
		
		if(iPoints >= iPrice || iPrice == 0)
		{
			Action aResult;
			Call_StartForward(g_OnBuyShopItem);
			Call_PushCell(iClient);
			Call_PushString(sInfo);
			Call_PushCellRef(iPrice);
			Call_Finish(aResult);
			
			if((aResult == Plugin_Handled || aResult == Plugin_Changed))
			{
				Call_StartForward(g_OnBuyShopItemPost);
				Call_PushCell(iClient);
				Call_PushString(sInfo);
				Call_PushCell(iPrice);
				Call_Finish();
				
				CPrintToChat(iClient, "%s %t", PREFIX , "Spent points", iPrice, iPrice > 0 ? RoundToFloor(TakePoints(iClient, float(iPrice))) : RoundToFloor(GetPoints(iClient)));
			}
		}
		else CPrintToChat(iClient, "%s %t", PREFIX , "Not enough points", iPrice, iPoints);
	}
	else if (action == MenuAction_End)
		delete menu;
}

/* Taunt */

public void PH_OnTaunt(int iClient, float fLength)
{
	AddPoints(iClient, GetRandomFloat(g_cvTauntPointsMin.FloatValue, g_cvTauntPointsMax.FloatValue));
	AddPoints(iClient, fLength * GetRandomFloat(g_cvTauntLengthPointsMin.FloatValue, g_cvTauntLengthPointsMax.FloatValue));
}

public void PH_OnForceTaunt(int iClient, int iHider, float fLength)
{
	AddPoints(iHider, GetRandomFloat(g_cvTauntPointsMin.FloatValue, g_cvTauntPointsMax.FloatValue));
	AddPoints(iHider, fLength * GetRandomFloat(g_cvTauntLengthPointsMin.FloatValue, g_cvTauntLengthPointsMax.FloatValue));
}

/* Timers */

public Action Timer_GivePoints(Handle timer, any data)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iCountT, iCountCT;
	LoopAlivePlayers(iClient)
	{
		if(GetClientTeam(iClient) == CS_TEAM_T)
			iCountT++;
		else iCountCT++;
	}
	
	// TODO add cvars
	
	float fMulT = float(iCountT + 2) / float(iCountT + iCountCT + 1);
	float fMulCT = float(iCountCT + 2) / float(iCountT + iCountCT + 1);
	
	float fBasePointsT = fMulT * 2.0;
	float fBasePointsCT = fMulCT * 2.0;
	
	LoopAlivePlayers(iClient)
	{
		if(GetClientTeam(iClient) == CS_TEAM_T)
		{
			if(PH_IsFrozen(iClient))
				g_fPoints[iClient] += 1.42 * fBasePointsT;
			else g_fPoints[iClient] += 0.57 * fBasePointsT;
		}
		else
		{
			if(PH_IsFrozen(iClient))
				g_fPoints[iClient] += 3.73 * fBasePointsCT;
			else g_fPoints[iClient] += 1.67 * fBasePointsCT;
		}
	}
	
	return Plugin_Continue;
}

void ResetShopItems(int iClient)
{
	if(g_aClientShopItemDisabled[iClient] == null)
		g_aClientShopItemDisabled[iClient] = new ArrayList(32);
		
	g_aClientShopItemDisabled[iClient].Clear();
	
	g_fPoints[iClient] = 0.0;
	g_bUpgradeFreezeAir[iClient] = false;
}