void LoadTauntSoundPacks()
{
	g_iTauntSoundPacks = 0;
	
	char ConfigPath[255];
	BuildPath(Path_SM, ConfigPath, 255, "configs/prophunt/taunt_packs.cfg");
	
	Handle hFile = OpenFile(ConfigPath, "r");
	if (hFile != INVALID_HANDLE)
	{
		char sBuffer[255];
		while (ReadFileLine(hFile, sBuffer, sizeof(sBuffer)))
		{
			TrimString(sBuffer);
			
			// Allow Comments & empty lines
			if(strlen(sBuffer) < 3) 
				continue;
			
			// If the line contains "VIP-Pack:" it's a new VIP only pack
			else if(ReplaceString(sBuffer, 255, "VIP-Pack:", "", true) > 0)
			{
				strcopy(g_sWpNames[g_iTauntSoundPacks], 255, sBuffer); 
				g_iTauntSoundPacksFileCount[g_iTauntSoundPacks] = 0;
				g_sWpVIPOnly[g_iTauntSoundPacks] = true;
				g_iTauntSoundPacks++;
			}
			// If the line contains "Pack:" it's a new pack
			else if(ReplaceString(sBuffer, 255, "Pack:", "", true) > 0)
			{
				strcopy(g_sWpNames[g_iTauntSoundPacks], 255, sBuffer); 
				g_iTauntSoundPacksFileCount[g_iTauntSoundPacks] = 0;
				g_sWpVIPOnly[g_iTauntSoundPacks] = false;
				g_iTauntSoundPacks++;
			}
			// Read taunt sounds
			else if(g_iTauntSoundPacks > 0)
			{
				// Fix incompability with prophunt-taunt
				ReplaceString(sBuffer, sizeof(sBuffer), "//VIP", ""); 
				ReplaceString(sBuffer, sizeof(sBuffer), "//DEFAULT", ""); 
				
				// Precache and add to downloadtable
				if(PrepareSound(sBuffer))
				{
					// Store sound length
					g_fWpSoundLength[g_iTauntSoundPacks - 1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]] = GetSoundLengthEx(sBuffer);
					// Store sound path
					strcopy(g_sWpFiles[g_iTauntSoundPacks-1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks-1]], 255, sBuffer);
					//Count pack sounds
					g_iTauntSoundPacksFileCount[g_iTauntSoundPacks-1]++;
				}
			}
		}
		
		delete hFile;
	}
}

public Action Cmd_Taunt(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	PlayTaunt(iClient);
	return Plugin_Handled;
}

stock void PlayTaunt(int iClient)
{
	if(!iClient || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;
	
	if(GetClientTeam(iClient) <= CS_TEAM_SPECTATOR)
		return;
	
	int iTime = GetTime();
	
	bool bReady = iTime > g_iTauntNextUse[iClient];
	
	// Prevent chat spam
	if(iTime < g_iTauntNextTry[iClient])
		return;
	
	g_iTauntNextTry[iClient] = iTime + 2;
	
	if(!bReady)
	{
		CPrintToChat(iClient, "%s %t", PREFIX, "Try again in s", 1 + g_iTauntNextUse[iClient] - iTime);
		return;
	}
	
	if(GetClientTeam(iClient) == CS_TEAM_T)
	{
		char sClientName[64];
		GetClientName(iClient, sClientName, sizeof(sClientName));
		
		int iLength = PlayTauntSound(iClient, iClient, false, true);
		
		if(iLength != -1)
		{
			iLength += g_cvTauntCooldownExtra.IntValue;
			
			if(iLength < g_cvTauntCooldownMin.IntValue)
				iLength = g_cvTauntCooldownMin.IntValue;
			
			g_iTauntNextUse[iClient] = iTime + iLength;
			g_iTauntCooldownLength[iClient] = iLength;
			CPrintToChatAll("%s %t", PREFIX, "Taunted", sClientName);
		}
	}
	else
	{
		// Not allowed?
		if(!g_cvTauntForce.BoolValue)
			return;
		
		int iTarget;
		int iCount;
		float maxrange;
		float range;
		
		LoopAlivePlayers(i)
		{
			if(GetClientTeam(i) == CS_TEAM_T)
			{
				iCount++;
				range = Entity_GetDistance(iClient, i);
				// target is closer
				if(range > maxrange)
				{
					maxrange = range;
					iTarget = i;
				}
			}
		}
		
		if(iCount == 1 && g_cvTauntForceLastHider.IntValue == 0)
		{
			CPrintToChat(iClient, "%s %t", PREFIX, "You can't force the last hider to taunt.");
		}
		else if(iCount > 0)
		{
			if(iCount > 1 || g_cvTauntForceLastHider.IntValue == 1 || g_cvTauntForceLastHider.IntValue <= GetRandomInt(0, 100))
			{
				char sClientName[64], sTargetName[64];
				GetClientName(iClient, sClientName, sizeof(sClientName));
				GetClientName(iTarget, sTargetName, sizeof(sTargetName));
				
				int iLength = PlayTauntSound(iTarget, iClient, true, true);
				
				if(iLength != -1)
				{
					iLength += g_cvTauntForceCooldownExtra.IntValue;
					
					if(iLength < g_cvTauntForceCooldownMin.IntValue)
						iLength = g_cvTauntForceCooldownMin.IntValue;
					
					g_iTauntNextUse[iClient] = iTime + iLength;
					g_iTauntCooldownLength[iClient] = iLength;
					
					CPrintToChatAll("%s %t", PREFIX, "Taunt Forced", sClientName, sTargetName);
				}
			}
			else 
			{
				g_iTauntNextUse[iClient] = iTime + g_cvTauntForceFailedCooldown.IntValue;
				g_iTauntCooldownLength[iClient] = g_cvTauntForceFailedCooldown.IntValue;
				
				CPrintToChatAll("%s %t", PREFIX, "Force Taunt: failed");
			}
		}
		else CPrintToChat(iClient, "%s %t", PREFIX, "No alive hiders found.");
	}
}

int ForceTaunt(int iClient, int iForcer)
{
	if(GetTime() > g_iTauntNextUse[iClient])
		return PlayTauntSound(iClient, iForcer, true, false);
	
	return 0;
}

int PlayTauntSound(int iClient, int packowner, bool bForced, bool bPreForward)
{
	int soundid = GetRandomInt(0, g_iTauntSoundPacksFileCount[g_iTauntPack[packowner]]-1);
	
	/* Pre forward
	
	Return:
	* Plugin_Continue: play sound
	* Plugin_Changed: block sound only, edit sound length
	* Plugin_Handled: block completly
				
	*/
	
	Action result;
	float length = g_fWpSoundLength[g_iTauntPack[packowner]][soundid];
	if(bPreForward)
	{
		if(bForced)
		{
			Call_StartForward(g_OnForceTauntPre);
			Call_PushCell(packowner);
		}
		else Call_StartForward(g_OnTauntPre);
		Call_PushCell(iClient);
		
		Call_PushFloatRef(length);
		
		Call_Finish(result);
		
		/* Sound blocked? */
		
		if(result > Plugin_Changed)
			return -1;
	}
	
	/* Play Sound */
	
	if(!bPreForward || result != Plugin_Changed)
	{
		float fPos[3];
		GetClientAbsOrigin(iClient, fPos);
		fPos[2] += 8.0;
		
		EmitAmbientSoundAny(g_sWpFiles[g_iTauntPack[packowner]][soundid], fPos, iClient, 120, _, 0.8);
	}
	
	/* Post forward */
	
	if(bForced)
	{
		Call_StartForward(g_OnForceTaunt);
		Call_PushCell(packowner);
	}
	else Call_StartForward(g_OnTaunt);
	Call_PushCell(iClient);
	Call_PushFloat(length);
	Call_Finish();
	
	return RoundToFloor(length);
}

public Action Cmd_WP(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	if(!iClient || !IsClientInGame(iClient))
		return Plugin_Handled;
	
	Action result;
	Call_StartForward(g_OnOpenTauntMenu);
	Call_PushCell(iClient);
	Call_Finish(result);
	
	/* Sound blocked? */
	
	if(result == Plugin_Continue)
		Menu_TauntPacks(iClient);
		
	return Plugin_Handled;
}

void Menu_TauntPacks(int iClient)
{
	if(!Ready())
		return;
	
	Handle menu = CreateMenu(SoundPack_Handler);
	SetMenuTitle(menu, "Select your taunt sound pack");
	
	for (int i = 0; i < g_iTauntSoundPacks; i++)
	{
		char idx[8];
		IntToString(i, idx, 8);
		
		// Already selected
		if(g_iTauntPack[iClient] == i)
		{
			char sBuffer[128];
			Format(sBuffer, 128, "%s ( ✓ )", g_sWpNames[i]);
			AddMenuItem(menu, idx, sBuffer);
		}
		// No access / VIP only
		else if (g_sWpVIPOnly[i] && !(Client_HasAdminFlags(iClient, ADMFLAG_CUSTOM1) || Client_HasAdminFlags(iClient, ADMFLAG_ROOT)))
		{
			char sBuffer[128];
			Format(sBuffer, 128, "%s ( ♔ )", g_sWpNames[i]);
			AddMenuItem(menu, idx, sBuffer, ITEMDRAW_DISABLED);
		}
		else AddMenuItem(menu, idx, g_sWpNames[i]);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, iClient, 360);
}

public int SoundPack_Handler(Handle menu, MenuAction action, int iClient, int itemNum)
{
	if ( action == MenuAction_Select )
	{
		char info[255];
		char info2[255];
		bool found = GetMenuItem(menu, itemNum, info, sizeof(info), _, info2, sizeof(info2));

		if(found)
		{
			g_iTauntPack[iClient] = StringToInt(info);
			SetCookieInt(iClient, g_hCookieTauntPack, g_iTauntPack[iClient]);
			
			Menu_TauntPacks(iClient);
			
			// Preview soundpack
			EmitSoundToClientAny(iClient, g_sWpFiles[g_iTauntPack[iClient]][GetRandomInt(0, g_iTauntSoundPacksFileCount[g_iTauntPack[iClient]]-1)]);
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

void StartTauntOverloadTimer()
{
	CreateTimer(1.0, Timer_CheckTauntOverload, _, TIMER_REPEAT);
}

public Action Timer_CheckTauntOverload(Handle timer, any data)
{
	if(!Ready())
		return Plugin_Continue;
	
	if(g_cvTauntOverloadTime.IntValue < 0)
		return Plugin_Continue;
	
	int iTime = GetTime();
	LoopAlivePlayers(iClient)
	{
		if(GetClientTeam(iClient) != CS_TEAM_T)
			continue;
		
		if(g_iTauntNextUse[iClient] <= 0)
			g_iTauntNextUse[iClient] = iTime;
		
		bool bWarn = iTime - g_iTauntNextUse[iClient] > g_cvTauntOverloadTime.IntValue - g_cvTauntOverloadWarnTime.IntValue;
		bool bOverload = iTime - g_iTauntNextUse[iClient] > g_cvTauntOverloadTime.IntValue;
		
		if(bWarn)
		{
			// Punish player
			if(bOverload)
			{
				OverloadHider(iClient);
				break; // Don't overload multiple hiders at the same time
			}
			// Warn player
			else CPrintToChat(iClient, "%s %t", PREFIX, "Taunt Overload Warn");
		}
	}
	
	return Plugin_Continue;
}

void OverloadHider(int iClient)
{
	g_fPoints[iClient] = 0.0;
	
	char sClientName[64];
	GetClientName(iClient, sClientName, sizeof(sClientName));
	CPrintToChatAll("%s %t", PREFIX, "Taunt Overload", sClientName);
	
	PlayTauntSound(iClient, iClient, false, false);
	g_iTauntNextUse[iClient] = GetTime() - (g_cvTauntOverloadTime.IntValue - g_cvTauntOverloadCooldown.IntValue);
}