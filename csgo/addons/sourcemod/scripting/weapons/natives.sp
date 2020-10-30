public int Weapons_GetClientKnife_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	char KnifeName[64];
	GetClientKnife(client, KnifeName, sizeof(KnifeName));
	SetNativeString(2, KnifeName, GetNativeCell(3));
	return 0;
}

public int Weapons_SetClientKnife_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	char KnifeName[64];
	GetNativeString(2, KnifeName, 64);
	bool update = !!GetNativeCell(3);
	SetClientKnife(client, KnifeName, true, update);
	return 0;
}
