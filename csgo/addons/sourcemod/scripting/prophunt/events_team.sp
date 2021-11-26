// disable team join messages

public Action Event_OnPlayerTeam_Pre(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	SetEventBroadcast(event, true);
	return Plugin_Continue;
}

// player joined team
public Action Event_OnPlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	if(!Ready())
		return Plugin_Continue;
	
	StartCheckTeamsTimer();
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!IsClientConnected(iClient))
		return Plugin_Continue;
	
	int team = GetEventInt(event, "team");
	bool disconnect = GetEventBool(event, "disconnect");
	
	Client_SetFreezed(iClient, false);
	
	// Player joined spectator?
	if (!disconnect && team != CS_TEAM_T)
		// show weapons again
		SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 1);
	
	return Plugin_Continue;
}