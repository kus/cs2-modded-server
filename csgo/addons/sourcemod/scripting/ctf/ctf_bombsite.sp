void BombSite_LocationChange()
{
	float pos[3];
	int index = -1;
	index = FindEntityByClassname(index, "cs_player_manager"); 

	KeyValues kvModelPath = CreateKeyValues("Flags");
	
	kvModelPath.ImportFromFile(g_CTFconfig);
	char mapname[120];
	GetCurrentMap(mapname, sizeof(mapname));
	kvModelPath.JumpToKey(mapname);
	
	pos[0] = kvModelPath.GetFloat("T-posx");
	pos[1] = kvModelPath.GetFloat("T-posz");
	pos[2] = kvModelPath.GetFloat("T-posy");
	
	if (index != -1) 
		SetEntPropVector(index, Prop_Send, "m_bombsiteCenterA", pos); 


	pos[0] = kvModelPath.GetFloat("CT-posx");
	pos[1] = kvModelPath.GetFloat("CT-posz");
	pos[2] = kvModelPath.GetFloat("CT-posy");
	
	if (index != -1) 
		SetEntPropVector(index, Prop_Send, "m_bombsiteCenterB", pos); 
	
}