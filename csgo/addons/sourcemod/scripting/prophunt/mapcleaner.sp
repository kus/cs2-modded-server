void StartCleanupTimer()
{
	if(g_hCleanupTimer != null)
		return; // When all players get equipped the same tick we don't need to cleanup multiple times
	
	g_hCleanupTimer = CreateTimer(0.0, Timer_CleanupWeapons);
}

public Action Timer_CleanupWeapons(Handle timer, any data)
{
	//CleanupWeapons();
	RemoveFootstepShadows(); // Idk why I put this here :3
	g_hCleanupTimer = null;
}