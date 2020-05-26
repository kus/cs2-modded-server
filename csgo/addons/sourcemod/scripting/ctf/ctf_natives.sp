public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("capturetheflag");
	
	CreateNatives();
	
	g_OnFlagTaken 	= CreateGlobalForward("CaptureTheFlag_OnFlagTaken", 	ET_Ignore, Param_Cell);
	g_OnFlagDropped = CreateGlobalForward("CaptureTheFlag_OnFlagDropped", 	ET_Ignore, Param_Cell);
	g_OnFlagScore 	= CreateGlobalForward("CaptureTheFlag_OnFlagScore", 	ET_Ignore, Param_Cell);
	
	return APLRes_Success;
}







void CreateNatives()
{
	CreateNative("CaptureTheFlag_HasFlag", Native_HasFlag);
}

public int Native_HasFlag(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int team = GetClientTeam(client);
	if(GetFlagCarrier(team) == client)
		return true;
	else
		return false;
}
