
public Action:Client_JumpstatsTop(client, args)
{
	if (!IsValidClient(client))
	{
		return Plugin_Handled;
	}

	else if (!gB_KZTimerAPI)
	{
		PrintToChat(client, "Server is not using API");
		return Plugin_Handled;
	}

	else
	{
		KZTimerAPI_PrintGlobalJumpstatsTopMenu(client);
	}
	return Plugin_Handled;
}

public Action:Client_APIGlobalTop(client, args)
{
	if (!IsValidClient(client))
	{
		return Plugin_Handled;
	}

	else if (!gB_KZTimerAPI)
	{
		PrintToChat(client, "Server is not using API");
		return Plugin_Handled;
	}

	else if (args <= 0)
	{
		KZTimerAPI_PrintGlobalRecordTopMenu(client);
	}
	
	else if (args == 1)
	{
		char mapName[128];
		GetCmdArg(1, mapName, sizeof(mapName));

		KZTimerAPI_PrintGlobalRecordTop(client, mapName);
	}
	
	else if (args == 2)
	{
		char mapName[128];
		char runType[30];
		GetCmdArg(1, mapName, sizeof(mapName));
		GetCmdArg(2, runType, sizeof(runType));

		KZTimerAPI_PrintGlobalRecordTop(client, mapName, runType);
	}
	
	else if (args >= 3)
	{
		char mapName[128];
		char runType[30];
		char tickRate[30];
		GetCmdArg(1, mapName, sizeof(mapName));
		GetCmdArg(2, runType, sizeof(runType));
		GetCmdArg(3, tickRate, sizeof(tickRate));

		KZTimerAPI_PrintGlobalRecordTop(client, mapName, runType, StringToInt(tickRate));
	}
	return Plugin_Handled;
}

////////////////////////////////////////////////////////
//REAL BHOP BLOCK..
HookTriggerPushes()
{
    // hook trigger_pushes to disable velocity calculation in these, allowing
    // the push to be applied correctly
    new index = -1;
    while ((index = FindEntityByClassname2(index, "trigger_push")) != -1) {
        SDKHook(index, SDKHook_StartTouch, Event_EntityOnStartTouch);
        SDKHook(index, SDKHook_EndTouch, Event_EntityOnEndTouch);
    }
}

FindEntityByClassname2(startEnt, const String:classname[])
{
    /* If startEnt isn't valid shifting it back to the nearest valid one */
    while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;

    return FindEntityByClassname(startEnt, classname);
}

public Event_EntityOnStartTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client)) {
        PlayerInTriggerPush[client] = true;
    }
}

public Event_EntityOnEndTouch(entity, client)
{
    if (client <= MAXPLAYERS
        && IsValidEntity(client)
        && IsClientInGame(client)) {
        PlayerInTriggerPush[client] = false;
    }
}

public Action:Client_GlobalCheck(client, args)
{
	if (gB_KZTimerAPI)
	{
		KZTimerAPI_GlobalCheck(client);
	}
	
	if (g_global_SelfBuiltButtons)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Self-built climb buttons detected. (only built-in buttons supported)",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	else
	if (!g_bEnforcer)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: Server settings enforcer disabled.",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	else
	if (g_iDoubleDuckCvar == 1)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kz_double_duck is set to 1.",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	else if (!g_bMomsurffixAvailable)
	{
		PrintToChat(client, "[%cKZ%c] %cGlobal Records disabled. Reason: kztimer-momsurffix is not available.",MOSSGREEN,WHITE,RED);
		return Plugin_Handled;
	}
	PrintToChat(client, "[%cKZ%c] %cGlobal records are enabled.",MOSSGREEN,WHITE,GREEN);
	return Plugin_Handled;
}
