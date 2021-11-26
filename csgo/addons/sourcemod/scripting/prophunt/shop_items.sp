void RegisterItems()
{
	RegisterShopItem("Heal", 		CS_TEAM_T, g_cvShopHiderHealPrice.IntValue, 			g_cvShopHiderHealSort.IntValue, 			g_cvShopHiderHealUnlockTime.IntValue, false);
	RegisterShopItem("Change Model (Random)", 				CS_TEAM_T, g_cvShopHiderMorphPrice.IntValue, 			g_cvShopHiderMorphSort.IntValue, 		g_cvShopHiderMorphUnlockTime.IntValue, false);
	RegisterShopItem("Freeze Height Limit Upgrade", 	CS_TEAM_T, g_cvShopHiderAirFreezePrice.IntValue, 		g_cvShopHiderAirFreezeSort.IntValue, 	g_cvShopHiderAirFreezeUnlockTime.IntValue, false);
	RegisterShopItem("Speed Upgrade", 	CS_TEAM_T, g_cvShopHiderSpeedPrice.IntValue, 		g_cvShopHiderSpeedSort.IntValue, 	g_cvShopHiderSpeedUnlockTime.IntValue, false);
	RegisterShopItem("Low Gravity Upgrade", 	CS_TEAM_T, g_cvShopHiderGravityPrice.IntValue, 		g_cvShopHiderGravitySort.IntValue, 	g_cvShopHiderGravityUnlockTime.IntValue, false);
	
	RegisterShopItem("Healthshot",			 CS_TEAM_CT, g_cvShopSeekerHealthshotPrice.IntValue, 	g_cvShopSeekerHealthshotSort.IntValue, 	g_cvShopSeekerHealthshotUnlockTime.IntValue, false);
	RegisterShopItem("Grenade", 			CS_TEAM_CT, g_cvShopSeekerGrenadePrice.IntValue, 		g_cvShopSeekerGrenadeSort.IntValue, 	g_cvShopSeekerGrenadeUnlockTime.IntValue, false);
	RegisterShopItem("FiveSeven", 			CS_TEAM_CT, g_cvShopSeekerFiveSevenPrice.IntValue, 		g_cvShopSeekerFiveSevenSort.IntValue, 	g_cvShopSeekerFiveSevenUnlockTime.IntValue, false);
	RegisterShopItem("XM1014", 			CS_TEAM_CT, g_cvShopSeekerXM1014Price.IntValue, 		g_cvShopSeekerXM1014Sort.IntValue, 	g_cvShopSeekerXM1014UnlockTime.IntValue, false);
	RegisterShopItem("MP9", 				CS_TEAM_CT, g_cvShopSeekerMP9Price.IntValue, 			g_cvShopSeekerMP9Sort.IntValue, 		g_cvShopSeekerMP9UnlockTime.IntValue, false);
	RegisterShopItem("M4A1", 				CS_TEAM_CT, g_cvShopSeekerM4A1Price.IntValue,			g_cvShopSeekerM4A1Sort.IntValue, 		g_cvShopSeekerM4A1UnlockTime.IntValue, false);
	RegisterShopItem("AWP", 				CS_TEAM_CT, g_cvShopSeekerAWPPrice.IntValue, 			g_cvShopSeekerAWPSort.IntValue, 		g_cvShopSeekerAWPUnlockTime.IntValue, false);
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &points)
{
	if(StrEqual(sName, "Heal"))
	{
		int iHealth = GetClientHealth(iClient);
		if(iHealth >= m_iHP[iClient])
		{
			CPrintToChat(iClient, "%s %t", PREFIX , "Shop Heal Full");
			return Plugin_Continue;
		}
		
		return Plugin_Handled;
	}
	else if(StrEqual(sName, "Change Model (Random)"))
		return Plugin_Handled;
	else if(StrEqual(sName, "Speed Upgrade"))
		return Plugin_Handled;
	else if(StrEqual(sName, "Low Gravity Upgrade"))
		return Plugin_Handled;
	else if(StrEqual(sName, "Freeze Height Limit Upgrade"))
		return Plugin_Handled;
	else if(StrEqual(sName, "Healthshot"))
		return Plugin_Handled;
	else if(StrEqual(sName, "Grenade"))
		return Plugin_Handled;
	else if(StrEqual(sName, "FiveSeven"))
		return Plugin_Handled;
	else if(StrEqual(sName, "XM1014"))
		return Plugin_Handled;
	else if(StrEqual(sName, "MP9"))
		return Plugin_Handled;
	else if(StrEqual(sName, "M4A1"))
		return Plugin_Handled;
	else if(StrEqual(sName, "AWP"))
		return Plugin_Handled;
	
	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int points)
{
	if(StrEqual(sName, "Heal"))
	{
		int iHealth = GetClientHealth(iClient);
		SetEntityHealth(iClient, m_iHP[iClient]);
		CPrintToChat(iClient, "%s %t", PREFIX , "Shop Heal Bought", m_iHP[iClient] - iHealth);
		return;
	}
	else if(StrEqual(sName, "Change Model (Random)"))
	{
		SetModel(iClient);
		return;
	}
	else if(StrEqual(sName, "Speed Upgrade"))
	{
		float fTime = g_cvShopHiderSpeedTime.FloatValue;
		if(fTime <= 0.0)
		{
			PH_DisableShopItem("Speed Upgrade", iClient); // If time is not set it's a one-time purchase
			fTime = -1.0; // The speedrules plugin uses -1.0 as infinite
		}
		
		int iType = g_cvShopHiderSpeedBonusType.IntValue == 0 ? SR_Add : SR_Mul;
		SpeedRules_ClientAdd(iClient, "shop_speed_upgrade", iType, g_cvShopHiderSpeedBonus.FloatValue, fTime, g_cvShopHiderSpeedPriority.IntValue);
	}
	else if(StrEqual(sName, "Low Gravity Upgrade"))
	{
		m_fGravity[iClient] -= g_cvShopHiderGravityBonus.FloatValue;
		float fMinGravity = g_cvShopHiderGravityMin.FloatValue;
		if(fMinGravity > m_fGravity[iClient])
			m_fGravity[iClient] = fMinGravity;
		SetEntityGravity(iClient, m_fGravity[iClient]);
		PH_DisableShopItem("Low Gravity Upgrade", iClient);
	}
	else if(StrEqual(sName, "Freeze Height Limit Upgrade"))
	{
		CPrintToChat(iClient, "%s %t", PREFIX , "Freeze Air Upgrade");
		PH_DisableShopItem("Upgrade Freeze Height Limit", iClient);
		g_bUpgradeFreezeAir[iClient] = true;
	}
	else if(StrEqual(sName, "Healthshot"))
	{
		GivePlayerItem(iClient, "weapon_healthshot");
	}
	else if(StrEqual(sName, "Grenade"))
	{
		GivePlayerItem(iClient, "weapon_hegrenade");
	}
	else if(StrEqual(sName, "FiveSeven"))
	{
		GivePlayerItem(iClient, "weapon_fiveseven");
		PH_DisableShopItem("FiveSeven", iClient);
	}
	else if(StrEqual(sName, "XM1014"))
	{
		GivePlayerItem(iClient, "weapon_xm1014");
		PH_DisableShopItem("XM1014", iClient);
	}
	else if(StrEqual(sName, "MP9"))
	{
		GivePlayerItem(iClient, "weapon_mp9");
		PH_DisableShopItem("MP9", iClient);
	}
	else if(StrEqual(sName, "M4A1"))
	{
		GivePlayerItem(iClient, "weapon_m4a1");
		PH_DisableShopItem("AWP", iClient);
	}
	else if(StrEqual(sName, "AWP"))
	{
		GivePlayerItem(iClient, "weapon_awp");
		PH_DisableShopItem("AWP", iClient);
	}
}