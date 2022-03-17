// author = "sneaK, shavit", thanks!!!
Handle g_hGetPlayerMaxSpeed = null;		// Used to uncap speed regardless of player weapon.

public void WeapSpeedOnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "dhooks"))
	{
		SetUpWeapSpeedDhook();
	}
}

void SetUpWeapSpeedDhook()
{
	// Optionally setup a hook on CCSPlayer::GetPlayerMaxSpeed to allow full run speed with all weapons.
	if (g_hGetPlayerMaxSpeed != null)
	{
		return;
	}
	
	Handle gameData = LoadGameConfigFile(KZTIMER_GAMEDATA_FILE);
	
	if (gameData != null)
	{
		int offset = GameConfGetOffset(gameData, "GetPlayerMaxSpeed");
		CloseHandle(gameData);
		
		if (offset != -1)
		{
			g_hGetPlayerMaxSpeed = DHookCreate(offset, HookType_Entity, ReturnType_Float, ThisPointer_CBaseEntity, DHook_GetMaxPlayerSpeed);
			
			if (g_hGetPlayerMaxSpeed == INVALID_HANDLE)
			{
				SetFailState("Couldn't create a DHook for GetPlayerMaxSpeed");
			}
		}
		else
		{
			SetFailState("Couldn't find gamedata offset for GetPlayerMaxspeed in "...KZTIMER_GAMEDATA_FILE);
		}
	}
	else
	{
		SetFailState("Couldn't load gamedata: "...KZTIMER_GAMEDATA_FILE);
	}
}

public void WeapSpeedOnPluginStart()
{
	if (LibraryExists("dhooks"))
	{
		SetUpWeapSpeedDhook();
	}
}
	
public void WeapSpeedOnClientPutInServer(int client)
{
	if (LibraryExists("dhooks"))
	{
		if (g_hGetPlayerMaxSpeed != INVALID_HANDLE)
		{
			DHookEntity(g_hGetPlayerMaxSpeed, true, client);
		}
		else
		{
			SetUpWeapSpeedDhook();
			DHookEntity(g_hGetPlayerMaxSpeed, true, client);
		}
	}
}

public MRESReturn DHook_GetMaxPlayerSpeed(int client, Handle hReturn)
{
	if (!IsValidClient(client) && !IsPlayerAlive(client))
	{
		return MRES_Ignored;
	}
	
	DHookSetReturn(hReturn, 250.0);
	
	return MRES_Override;
}