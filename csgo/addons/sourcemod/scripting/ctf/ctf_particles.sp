


void CreateParticle(char []particle, int team)
{
	
	KeyValues kvModelPath = CreateKeyValues("Flags");

	if(!kvModelPath.ImportFromFile(g_CTFconfig)) return;
	char mapname[120];
	GetCurrentMap(mapname, sizeof(mapname));
	kvModelPath.JumpToKey(mapname);
	
	float org[3];
	
	if(team == CS_TEAM_CT)
	{
		org[0] = kvModelPath.GetFloat("T-posx");
		org[1] = kvModelPath.GetFloat("T-posz");
		org[2] = kvModelPath.GetFloat("T-posy");	
			
		EmitSoundToAllAny("weapons/party_horn_01.wav", GetTeamFlag(CS_TEAM_T));
	}
	
	if(team == CS_TEAM_T)
	{
		//Counter terrorist flag spawn
		org[0] = kvModelPath.GetFloat("CT-posx");
		org[1] = kvModelPath.GetFloat("CT-posz");
		org[2] = kvModelPath.GetFloat("CT-posy");
		
		EmitSoundToAllAny("weapons/party_horn_01.wav", GetTeamFlag(CS_TEAM_CT));
	}
	
	delete kvModelPath;
	
	int i, ent;
	for (i = 0; i < 11; i++)
	{
		ent = CreateEntityByName("info_particle_system");
	
		DispatchKeyValue(ent , "start_active", "0");
		DispatchKeyValue(ent, "effect_name", particle);
		DispatchSpawn(ent);
		TeleportEntity(ent , org, NULL_VECTOR,NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Start");
	}

	

}