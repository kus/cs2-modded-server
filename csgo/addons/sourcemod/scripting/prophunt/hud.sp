#define HUD_CH_HELP 1
#define HUD_COUNTDOWN 2
#define HUD_HIDERSLEFT 2
#define HUD_CH_POINTS 3
#define HUD_CH_SHOP_CD 4

void Toggle_HUD(int iClient)
{
	// disabled -- > help
	if(g_iHudMode[iClient] == HUD_DISABLED)
	{
		g_iHudMode[iClient] = HUD_HELP;
		CPrintToChat(iClient, "%s %t", PREFIX, "HUD Mode Help");
	}
	// help -- > normal
	else if(g_iHudMode[iClient] == HUD_HELP)
	{
		g_iHudMode[iClient] = HUD_NORMAL;
		CPrintToChat(iClient, "%s %t", PREFIX, "HUD Mode Normal");
	}
	// normal -- > disabled
	else
	{
		g_iHudMode[iClient] = HUD_DISABLED;
		CPrintToChat(iClient, "%s %t", PREFIX, "HUD Mode Disabled");
	}
	
	char sBuffer[8];
	IntToString(g_iHudMode[iClient], sBuffer, sizeof(sBuffer));
	SetClientCookie(iClient, g_hCookieHudMode, sBuffer);
}

void StartHUDTimer()
{
	CreateTimer(1.0, Timer_HUD, _, TIMER_REPEAT);
}

int iAliveHiders;

public Action Timer_HUD(Handle timer, any data)
{
	if(!Ready())
		return Plugin_Continue;
	
	iAliveHiders = 0;
	
	LoopAlivePlayers(i)
	{
		if (GetClientTeam(i) == CS_TEAM_T)
		{
			iAliveHiders++;
		}
	}
	
	LoopIngamePlayers(iClient)
	{
		if(g_iHudMode[iClient] == HUD_DISABLED)
			continue;
		
		int iTarget = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
		if(iTarget > 0 && !IsPlayerAlive(iClient))
		{
			if(!IsClientInGame(iTarget) || !IsPlayerAlive(iTarget))
				continue;
		}
		else iTarget = iClient;
		
		if(GetClientTeam(iClient) > CS_TEAM_SPECTATOR)
		{
			HUD_Announce(iClient, iTarget);
			HUD_Countdown(iClient, iTarget);
			if(IsPlayerAlive(iClient))
				HUD_Points(iClient);
			HUD_ShopCooldown(iClient, iTarget);
		}
	}
	
	return Plugin_Continue;
}

void HUD_Announce(int iTarget, int iClient)
{
	if(!Ready())
		return;
	
	if(g_iHudMode[iClient] != HUD_HELP)
		return;
	
	char sBuffer[512];
	int iTeam = GetClientTeam(iClient);
	if(iTeam == CS_TEAM_T && g_cvHudHelpHider.BoolValue)
	{
		Format(sBuffer, sizeof(sBuffer), "%t", "HUD Help Hider");
		ShowGameText(iTarget, HUD_CH_HELP, { 255, 180, 59, 255 }, -1.0, 0.85, 1.1, sBuffer);
	}
	else if(iTeam == CS_TEAM_CT && g_cvHudHelpSeeker.BoolValue)
	{
		Format(sBuffer, sizeof(sBuffer), "%t", "HUD Help Seeker");
		ShowGameText(iTarget, 1, { 255, 180, 59, 255 }, -1.0, 0.85, 1.1, sBuffer);
		ShowGameText(iTarget, HUD_CH_HELP, { 255, 180, 59, 255 }, -1.0, 0.85, 1.1, sBuffer);
	}
}

void HUD_Countdown(int iTarget, int iClient)
{
	if(!Ready())
		return;
	
	int iHideTime = PH_CanChangeModel();
	int iTeam = GetClientTeam(iClient);
	char sBuffer[512];
	
	if(iHideTime > 0)
	{
		if(g_cvHudCountdownHide.BoolValue)
		{
			Format(sBuffer, sizeof(sBuffer), "Hide Time: %is", iHideTime);
			ShowGameText(iTarget, HUD_COUNTDOWN, { 255, 55, 55, 255 }, -1.0, 0.35, 1.1, sBuffer);
		}
	}
	else if (iTeam == CS_TEAM_CT && iAliveHiders > 0)
	{
		if(g_cvHudHidersLeft.BoolValue)
		{
			Format(sBuffer, sizeof(sBuffer), "%i Hider%s left", iAliveHiders, iAliveHiders == 1 ? "" : "s");
			ShowGameText(iTarget, HUD_HIDERSLEFT, { 255, 55, 55, 255 }, -1.0, 0.35, 1.1, sBuffer);
		}
	}
}

void HUD_Points(int iClient)
{
	if(!g_cvHudPoints.BoolValue)
		return;
	
	char sBuffer[512];
	
	static float fPoints[MAXPLAYERS + 1];
	float fDiff = g_fPoints[iClient] - fPoints[iClient];
	int iDiff = RoundToFloor(fDiff);
	if (fDiff <= -1.0)
	{
		Format(sBuffer, sizeof(sBuffer), "- %i", -iDiff);
		ShowGameText(iClient, HUD_CH_POINTS, { 255, 55, 55, 255 }, -1.0, 0.45, 1.1, sBuffer);
	}
	if (iDiff >= 9.0)
	{
		Format(sBuffer, sizeof(sBuffer), "+ %i", iDiff);
		ShowGameText(iClient, HUD_CH_POINTS, { 55, 255, 55, 255 }, -1.0, 0.45, 1.1, sBuffer);
	}
	fPoints[iClient] = g_fPoints[iClient];
}

void HUD_ShopCooldown(int iTarget, int iClient)
{
	if(!g_cvHudShopCd.BoolValue)
		return;
	
	char sBuffer[512];
	Format(sBuffer, sizeof(sBuffer), "Points: $%i", RoundToFloor(g_fPoints[iClient]));
	
	int iTeam = GetClientTeam(iClient);
	
	int iCount;
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
		if(g_aClientShopItemDisabled[iClient] == null || g_aClientShopItemDisabled[iClient].FindString(sName) != -1)
			continue;
		
		// Item unlocked by round time
		int iUnlockTime = g_aShopUnlockTime.Get(iItem);
		int iCountdown = iUnlockTime - (GetTime() - g_iRoundStart);
		bool bUnlocked = iUnlockTime <= GetTime() - g_iRoundStart;
		
		if(bUnlocked || iCountdown > 10)
			continue;
		
		Format(sBuffer, sizeof(sBuffer), "%s\n%is - %s", sBuffer, iCountdown, sName);
		
		iCount++;
	}
	
	ShowGameText(iTarget, HUD_CH_SHOP_CD, { 255, 255, 55, 255 }, 0.01, 0.27, 1.1, sBuffer);
}