void RegisterCommands()
{
	/* HUD Commands */
	
	RegConsoleCmd("hud", Cmd_HUD, "Toggle HUD mode.");
	
	/* Shop Commands */
	
	RegConsoleCmd("shop", Cmd_WP, "Opens player shop.");
	
	/* Hider Commands */
	
	RegConsoleCmd("hide", Cmd_SelectModelMenu, "Opens a menu with different models to choose as hider.");
	RegConsoleCmd("prop", Cmd_SelectModelMenu, "Opens a menu with different models to choose as hider.");
	RegConsoleCmd("model", Cmd_SelectModelMenu, "Opens a menu with different models to choose as hider.");
	
	RegConsoleCmd("tp", Cmd_ToggleThirdPerson, "Toggles the view to thirdperson for hiders.");
	RegConsoleCmd("thirdperson", Cmd_ToggleThirdPerson, "Toggles the view to thirdperson for hiders.");
	RegConsoleCmd("third", Cmd_ToggleThirdPerson, "Toggles the view to thirdperson for hiders.");
	
	RegConsoleCmd("whoami", Cmd_DisplayModelName, "Displays the current models description in chat.");
	
	AddCommandListener(Cmd_LAW, "+lookatweapon");
	RegConsoleCmd("freeze", Cmd_Freeze, "Toggles freezing for hiders, freeze mid air.");
	
	RegConsoleCmd("taunt", Cmd_Taunt, "Plays a taunt sound.");
	RegConsoleCmd("t", Cmd_Taunt, "Plays a taunt sound.");
	RegConsoleCmd("whistle", Cmd_Taunt, "Plays a taunt sound.");
	RegConsoleCmd("w", Cmd_Taunt, "Plays a taunt sound.");
	
	RegConsoleCmd("wp", Cmd_WP, "Opens taunt sound pack selection menu.");
	RegConsoleCmd("ws", Cmd_WP, "Opens taunt sound pack selection menu.");
	
	/* Seeker Commands*/
	
	RegConsoleCmd("ct", Cmd_RequestCT, "Starts a request to switch to seeker team next round. (Queue system)");
	RegConsoleCmd("seek", Cmd_RequestCT, "Starts a request to switch to seeker team next round. (Queue system)");
	
	/* Admin Commands */
	
	RegAdminCmd("ph_models_reload", Cmd_ReloadModels, ADMFLAG_RCON, "Reloads the modellist from the map config file.");
	RegAdminCmd("ph_models", Cmd_AdminMenu, ADMFLAG_RCON, "Model admin menu for testing and settings.");
}

public Action Cmd_HUD(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	Toggle_HUD(iClient);
	return Plugin_Handled;
}

public Action Cmd_Skills(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	Menu_Shop(iClient);
	return Plugin_Handled;
}

// say /tp /third /thirdperson
public Action Cmd_ToggleThirdPerson(int client, int args)
{
	if(!Ready())
		return Plugin_Continue;
	
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;
	
	// Only allow Terrorists to use thirdperson view
	if (GetClientTeam(client) != CS_TEAM_T)
		return Plugin_Handled;
	
	if (!g_bInThirdPersonView[client])
		SetThirdPersonView(client, true);
	else SetThirdPersonView(client, false);
	
	return Plugin_Continue;
}

// say /freeze
// Freeze hiders in position
public Action Cmd_Freeze(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	if (GetClientTeam(iClient) != CS_TEAM_T || !IsPlayerAlive(iClient))
		return Plugin_Handled;
	
	Client_ToggleFreeze(iClient);
	
	return Plugin_Handled;
}

public Action Cmd_LAW(int iClient, const char[] sCommand, int iArgc) 
{
	if(!Ready())
		return Plugin_Continue;
	
	if (!IsClientInGame(iClient) || GetClientTeam(iClient) != CS_TEAM_T || !IsPlayerAlive(iClient))
		return Plugin_Continue;
	
	Client_ToggleFreeze(iClient);
	
	return Plugin_Handled;
}

// say /whoami
// displays the model name in chat again
public Action Cmd_DisplayModelName(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	// only enable command, if player already chose a model
	if (!IsPlayerAlive(iClient) || g_iModelChangeCount[iClient] == 0)
		return Plugin_Handled;
	
	// only Ts can use a model
	if (GetClientTeam(iClient) != CS_TEAM_T)
		return Plugin_Handled;
	
	CPrintToChat(iClient, "%s %t", PREFIX, "whoami", m_sName[iClient]);
	
	return Plugin_Handled;
}

public Action Cmd_RequestCT(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	if(iClient && IsClientInGame(iClient))
	{
		CPrintToChat(iClient, "%s %t", PREFIX , "You have been added to seeker team", AddClientToQueue(iClient));
	}
	
	return Plugin_Handled;
}

public Action Cmd_ReloadModels(int iClient, int args)
{
	if(!Ready())
		return Plugin_Continue;
	
	OnMapEnd();
	ReadModelConfig();
	ReplyToCommand(iClient, "%T", "PropHunt: Reloaded config", LANG_SERVER);
	return Plugin_Handled;
}

public Action Cmd_AdminMenu(int iClient, int iArgs)
{
	if(!Ready())
		return Plugin_Continue;
	
	if(iClient > 0)
		ShowAdminMenu(iClient);
	
	return Plugin_Handled;
}
