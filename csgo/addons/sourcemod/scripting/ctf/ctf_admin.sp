public Action CMD_CTF(int client, int args)
{
	ShowFlagMenu(client);
	return Plugin_Handled;
}

void ShowFlagMenu(int client)
{
	Menu menu = new Menu(MenuHandler_MenuStuff);
	menu.SetTitle("CTF menu");
	
	menu.AddItem("spawntflag", "Spawn T flag");
	menu.AddItem("spawnctflag", "Spawn CT flag");
	menu.AddItem("saveflags", "Save flags");
	
	menu.ExitButton = true;
	menu.Display(client, 30);
}

public int MenuHandler_MenuStuff(Menu menu2, MenuAction action, int client, int param2)
{
	
	if (action == MenuAction_Select)
	{
		char info[20];
		menu2.GetItem(param2, info, sizeof(info));
		
		if (StrEqual(info, "spawntflag"))
		{
			RemoveFlag(CS_TEAM_T, false);
			SpawnFlag(CS_TEAM_T, FLAGTYPE_AIM, false, client);
		}
		
		else if (StrEqual(info, "spawnctflag"))
		{
			RemoveFlag(CS_TEAM_CT, false);
			SpawnFlag(CS_TEAM_CT, FLAGTYPE_AIM, false, client);	
		}
		
		else if (StrEqual(info, "saveflags"))
			SaveFlagsPositionInConfigFile();
		
		
		ShowFlagMenu(client);
	}
}

void SaveFlagsPositionInConfigFile()
{
	
	KeyValues kvCTF = CreateKeyValues("Flags");
	kvCTF.ImportFromFile(g_CTFconfig);
	
	char mapname[100];
	GetCurrentMap(mapname, sizeof(mapname));
	
	kvCTF.JumpToKey(mapname, true);
	
	char corg[10];
	float org[3];
	
	if (GetTeamFlag(CS_TEAM_T) > 0 && IsValidEntity(GetTeamFlag(CS_TEAM_T)))
	{
		GetEntPropVector(GetTeamFlag(CS_TEAM_T), Prop_Send, "m_vecOrigin", org);
		
		FloatToString(org[0], corg, sizeof(corg));
		kvCTF.SetString("T-posx", corg);
		FloatToString(org[1], corg, sizeof(corg));
		kvCTF.SetString("T-posz", corg);
		FloatToString(org[2], corg, sizeof(corg));
		kvCTF.SetString("T-posy", corg);
		
	}
	
	if (GetTeamFlag(CS_TEAM_CT) > 0 && IsValidEntity(GetTeamFlag(CS_TEAM_CT)))
	{

		GetEntPropVector(GetTeamFlag(CS_TEAM_CT), Prop_Send, "m_vecOrigin", org);

		FloatToString(org[0], corg, sizeof(corg));
		kvCTF.SetString("CT-posx", corg);
		FloatToString(org[1], corg, sizeof(corg));
		kvCTF.SetString("CT-posz", corg);
		FloatToString(org[2], corg, sizeof(corg));
		kvCTF.SetString("CT-posy", corg);
		
	}
	
	//Put it inside config file
	kvCTF.Rewind();
	kvCTF.ExportToFile(g_CTFconfig);
	
	delete kvCTF;
	
	
}