public Action MIM_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	SpawnModels_RoundStart();
}

public void OnClientPutInServer(int client)
{
	MoveModels_OnClietPutInServer(client);
}

public void Function_OnPluginStart()
{
	MoveModels_OnPluginStart();
	//SpawnModels_OnPluginStart();
}

public void OnMapStart()
{
	SpawnModels_OnMapStart();
}