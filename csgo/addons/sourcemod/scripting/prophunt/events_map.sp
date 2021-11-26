public void OnMapStart()
{
	g_iRoundStart = 0;
	
	ReadModelConfig();
	
	if(!Ready())
		return;
		
	ReadMapModelConfig();
	LoadTauntSoundPacks();
	StartNoBlockTimer();
}

public void OnPluginEnd()
{
	g_bLoaded = false;
}

public void OnMapEnd()
{
	for(int i = 0; i <= MaxClients; i++)
		delete g_mModelMenu[i];
	delete g_kvModels;
	
	g_iRoundStart = 0;
	
	delete g_hRoundTimeTimer;
	delete g_hAfterFreezeTimer;
	delete g_hRoundEndTimer;
	
	LoopClients(i)
		delete g_hAutoFreezeTimers[i];
	
	g_hCheckTeams = null;
}

