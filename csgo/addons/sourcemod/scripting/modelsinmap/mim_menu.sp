public Action CMD_Models(int client, int args)
{
	ShowMainMenu(client);
	return Plugin_Handled;
}

//***********************************
//******** MAIN MENU ****************
//***********************************

public void ShowMainMenu(int client)
{
	Menu modelmenu = new Menu(MenuHandler_ModelMenu);
	SetMenuTitle(modelmenu, "Model menu");
	
	modelmenu.AddItem("spawn", 		"Spawn models");
	if(g_bCanMoveModels[client])
		modelmenu.AddItem("edit", 		"Move models (On)");
	else if(!g_bCanMoveModels[client])
		modelmenu.AddItem("edit", 		"Move models (Off)");
	modelmenu.AddItem("delete", 	"Delete models");
	modelmenu.AddItem("save", 		"Save models");
	
	modelmenu.Display(client, 0);	
}

public int MenuHandler_ModelMenu(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			
			char info[200];
			GetMenuItem(menu, item, info, sizeof(info));
			
			if(StrEqual(info, "spawn"))
				ShowSpawnMenu(client);
			
			if(StrEqual(info, "edit"))
				ShowEditMenu(client);
			
			if(StrEqual(info, "delete"))
				ShowDeleteMenu(client);
				
			if(StrEqual(info, "save"))
				SaveModels(client);
		}
		
		case MenuAction_Cancel:
		{
			g_bCanMoveModels[client] = false;
		}
	}
}


//***********************************
//***********************************




//***********************************
//******** SPAWN MODEL MENU *********
//***********************************

public void ShowSpawnMenu(int client)
{
	Menu modelmenu = new Menu(MenuHandler_SpawnModels);
	SetMenuTitle(modelmenu, "Spawn models");
	
	KeyValues kv = CreateKeyValues("models");
	kv.ImportFromFile(g_sModelConfig2);
 
	if (kv.GotoFirstSubKey())
	{
 
		char model_path[PLATFORM_MAX_PATH];
		char name[200];
		char model_size[10];
		do
		{
			kv.GetSectionName(name, sizeof(name));
			kv.GetString("model_path", model_path, sizeof(model_path));
			kv.GetString("size", model_size, sizeof(model_size), "1.0");
			
			char value[200];
			value = name;
			
			StrCat(value, sizeof(value), "-");
			StrCat(value, sizeof(value), model_path);
			StrCat(value, sizeof(value), "-");
			StrCat(value, sizeof(value), model_size);
			
			modelmenu.AddItem(value, name);
		} while (kv.GotoNextKey());
	 
		delete kv;
		modelmenu.Display(client, 0);
	
	}

}

public int MenuHandler_SpawnModels(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			
			char info[200];
			GetMenuItem(menu, item, info, sizeof(info));
			
			char brake[4][200];
			ExplodeString(info, "-", brake, sizeof(brake), sizeof(brake[]));
			
			float modelsize = StringToFloat(brake[2]);
			char model_path[200];
			model_path = brake[1];
			char name[200];
			name = brake[0];
			
			PrecacheModel(model_path);
			
			int entity = CreateEntityByName("prop_dynamic");
			SetEntityModel(entity, model_path);
			SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
			Entity_SetGlobalName(entity, name);
			
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", modelsize);
			
			float playerpos[3];
			GetClientEyePosition(client, playerpos);
	
			float playerangle[3];
			GetClientEyeAngles(client, playerangle);
			
			float final[3];
			AddInFrontOf(playerpos, playerangle, 150.0, final);
			
			TeleportEntity(entity, final, NULL_VECTOR, NULL_VECTOR);
			
			g_bCanMoveModels[client] = true;
			
			ShowMainMenu(client);
		}	
	
		case MenuAction_Cancel:
		{
			ShowMainMenu(client);
		}
	}
}


//***********************************
//***********************************




//***********************************
//******** DELETE MODEL MENU ********
//***********************************

public void ShowDeleteMenu(int client)
{
	Menu modelmenu = new Menu(MenuHandler_DeleteModels);
	SetMenuTitle(modelmenu, "Delete models");
	
	KeyValues kv = CreateKeyValues("models");
	kv.ImportFromFile(g_sModelConfig2);
 
	if (kv.GotoFirstSubKey())
	{
 
		char model_path[PLATFORM_MAX_PATH];
		char name[200];
		do
		{
			kv.GetSectionName(name, sizeof(name));
			kv.GetString("model_path", model_path, sizeof(model_path));
			
			char value[200];
			value = name;
			
			StrCat(value, sizeof(value), "-");
			StrCat(value, sizeof(value), model_path);
			
			modelmenu.AddItem(value, name);
		} while (kv.GotoNextKey());
	 
		delete kv;
		modelmenu.Display(client, 0);
	
	}	
}


public int MenuHandler_DeleteModels(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			
			char info[200];
			GetMenuItem(menu, item, info, sizeof(info));
			
			char brake[4][200];
			ExplodeString(info, "-", brake, sizeof(brake), sizeof(brake[]));
			
			char model_path[200];
			model_path = brake[1];
			char name[200];
			name = brake[0];
			
			int ent;
	
			while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != INVALID_ENT_REFERENCE) {
				if(IsValidEntity(ent) && IsValidEdict(ent)) 
				{
						
					char mapname[50];
					GetCurrentMap(mapname, sizeof(mapname));
					
					char entname[200];
					Entity_GetGlobalName(ent, entname, sizeof(entname));
					
					if (StrEqual(entname, name))
					{
						AcceptEntityInput(ent, "Kill");
						
						//**********

						KeyValues kvDelete = CreateKeyValues("models3");
						kvDelete.ImportFromFile(g_sModelConfig);
						
						kvDelete.JumpToKey(mapname, true);
						kvDelete.JumpToKey(entname, true);
					 
						kvDelete.DeleteThis();
						kvDelete.Rewind();
						kvDelete.ExportToFile(g_sModelConfig);
						delete kvDelete;
						
					}
					
				}
			}
			
			ShowMainMenu(client);
		}	
	
		case MenuAction_Cancel:
		{
			ShowMainMenu(client);
		}
	}
}


//***********************************
//***********************************




//***********************************
//******** EDIT MODEL MENU **********
//***********************************



public void ShowEditMenu(int client)
{
	if(g_bCanMoveModels[client])
		g_bCanMoveModels[client] = false;
	
	else if(!g_bCanMoveModels[client])
		g_bCanMoveModels[client] = true;
		
	
		
	ShowMainMenu(client);
}



//***********************************
//***********************************




//***********************************
//******** SAVE MODELS **************
//***********************************


public void SaveModels(int client)
{
	int ent;
	
	while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != INVALID_ENT_REFERENCE) {
		if(IsValidEntity(ent) && IsValidEdict(ent)) 
		{
			
			if(IsValidEntity(ent)) 
			{
				
				char mapname[50];
				GetCurrentMap(mapname, sizeof(mapname));
				
				char entname[200];
				Entity_GetGlobalName(ent, entname, sizeof(entname));
				
				if (!StrEqual(entname, ""))
				{
				
					KeyValues kvSave = CreateKeyValues("models");
					if(!kvSave.ImportFromFile(g_sModelConfig)) return;
					
					kvSave.JumpToKey(mapname, true);
					kvSave.JumpToKey(entname, true);
					
					float org[3];
					Entity_GetAbsOrigin(ent, org);
					
					float ang[3];
					GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
					
					char corg[10];
					FloatToString(org[0], corg, sizeof(corg));
					kvSave.SetString("posx", corg);
					
					FloatToString(org[1], corg, sizeof(corg));
					kvSave.SetString("posz", corg);
					
					FloatToString(org[2], corg, sizeof(corg));
					kvSave.SetString("posy", corg);
					
					FloatToString(ang[0], corg, sizeof(corg));
					kvSave.SetString("angx", corg);
					
					FloatToString(ang[1], corg, sizeof(corg));
					kvSave.SetString("angz", corg);
					
					FloatToString(ang[2], corg, sizeof(corg));
					kvSave.SetString("angy", corg);
					
					kvSave.Rewind();
					kvSave.ExportToFile(g_sModelConfig);			
					
					delete kvSave;
					
				}
			}
			
		}
	}
	
	PrintToChat(client, "\x1 \x4[MODELS]\x1 Models saved!");
	ShowMainMenu(client);
	
}