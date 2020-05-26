public void SpawnModels_OnMapStart()
{
	SpawnModelsOnLoad();
}

public int SpawnModels_RoundStart()
{
	SpawnModelsOnLoad();
}

public void SpawnModelsOnLoad()
{
	KeyValues kvSpawn = CreateKeyValues("models");
	if(!kvSpawn.ImportFromFile(g_sModelConfig)) return;
	
	char mapname[50];
	GetCurrentMap(mapname, sizeof(mapname));
	
	if(!kvSpawn.JumpToKey(mapname, false)) return;
	if(!kvSpawn.GotoFirstSubKey()) return;
	
	char name[200];
	char pos[10];
	do
	{
		kvSpawn.GetSectionName(name, sizeof(name));
		
		//Getting model path
		KeyValues kvModelPath = CreateKeyValues("models2");

		if(!kvModelPath.ImportFromFile(g_sModelConfig2)) return;
		kvModelPath.JumpToKey(name);
			
		char model_path[PLATFORM_MAX_PATH];
		char solid[10];
		char rotate[10];
		char rotate_speed[10];
		char model_size[10];
		kvModelPath.GetString("model_path", model_path, sizeof(model_path));
		kvModelPath.GetString("solid", solid, sizeof(solid));
		kvModelPath.GetString("rotate", rotate, sizeof(rotate));
		kvModelPath.GetString("rotate_speed", rotate_speed, sizeof(rotate_speed));
		kvModelPath.GetString("size", model_size, sizeof(model_size), "1.0");
		
		delete kvModelPath;
		//
		
		float org[3];
		float ang[3];
		kvSpawn.GetString("posx", pos, sizeof(pos));
		org[0] = StringToFloat(pos);
		kvSpawn.GetString("posz", pos, sizeof(pos));
		org[1] = StringToFloat(pos);
		kvSpawn.GetString("posy", pos, sizeof(pos));
		org[2] = StringToFloat(pos);
		
		kvSpawn.GetString("angx", pos, sizeof(pos));
		ang[0] = StringToFloat(pos);
		kvSpawn.GetString("angz", pos, sizeof(pos));
		ang[1] = StringToFloat(pos);
		kvSpawn.GetString("angy", pos, sizeof(pos));
		ang[2] = StringToFloat(pos);
		
		if(!IsModelPrecached(model_path))
			PrecacheModel(model_path);
			
		int entity = CreateEntityByName("prop_dynamic");
		SetEntityModel(entity, model_path);
		
		float fsize = StringToFloat(model_size);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", fsize);
		
		if(StringToInt(solid) == 1)
			SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
		else
			SetEntProp(entity, Prop_Send, "m_nSolidType", 1);
			
		if(StringToInt(rotate) == 1)
		{
			int speed = StringToInt(rotate_speed);
			
			if(speed == 0)
				speed = 20;
				
			DataPack pack;
			CreateDataTimer(0.1, RotateBlockTmr, pack);
			pack.WriteCell(entity);
			pack.WriteCell(speed);
			pack.WriteCell(StringToInt(solid));
			
		}
			
		Entity_SetGlobalName(entity, name);
		TeleportEntity(entity, org, ang, NULL_VECTOR);

	} while (kvSpawn.GotoNextKey());
	
	delete kvSpawn;
}


public Action RotateBlockTmr(Handle timer, Handle pack)
{

	int entity;
	int speed;
	int solid;
 
	ResetPack(pack);
	entity = ReadPackCell(pack);
	speed = ReadPackCell(pack);
	solid = ReadPackCell(pack);
 
 	char c_speed[30];
 	IntToString(speed, c_speed, sizeof(c_speed));
	
	float org[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", org);

	int rotateEnt = CreateEntityByName("func_rotating");
	if (rotateEnt != -1)
	{
		DispatchKeyValue(rotateEnt, "maxspeed", c_speed);
		DispatchSpawn(rotateEnt);
		TeleportEntity(rotateEnt, org, NULL_VECTOR, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", rotateEnt, entity, 0);
		AcceptEntityInput(rotateEnt, "Start");
		
		if(solid == 1)
		{
			//SetEntProp(rotateEnt, Prop_Send, "m_nSolidType", 6);
			SetEntProp(entity, Prop_Send, "m_nSolidType", 6);	
		}
		else
		{
			//SetEntProp(rotateEnt, Prop_Send, "m_nSolidType", 1);
			SetEntProp(entity, Prop_Send, "m_nSolidType", 1);	
		}
		
	}
	
}