void CreateConfigs()
{
	AutoExecConfig_SetFile("capturetheflag");
	
	HookConVarChange(h_MaxFlags 	=	AutoExecConfig_CreateConVar("sm_maxflags", 		"3", "How many times players need to score (return flag to base)"), 	OnCvarChanged);
	HookConVarChange(h_RoundTime 	=	AutoExecConfig_CreateConVar("sm_roundtime", 	"15","How long will be the main game (minutes). Game is one round!"), 	OnCvarChanged);
	HookConVarChange(h_RespawnTime 	=	AutoExecConfig_CreateConVar("sm_respawntime", 	"8", "After how many seconds player will respawn."), 					OnCvarChanged);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}

public void OnCvarChanged(Handle hConvar, const char[] chOldValue, const char[] chNewValue)
{
	UpdateConvars();
}

public void UpdateConvars()
{
	MaxFlags 	= GetConVarInt(h_MaxFlags);
	RoundTime	= GetConVarInt(h_RoundTime);	
	RespawnTime	= GetConVarInt(h_RespawnTime);
}