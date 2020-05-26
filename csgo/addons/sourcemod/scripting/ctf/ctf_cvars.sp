void SetCvars()
{
	char cRoundTime[10];
	IntToString(RoundTime, cRoundTime, sizeof(cRoundTime));
	
	SetCvar("mp_timelimit", 					cRoundTime);
	SetCvar("mp_roundtime_defuse",				cRoundTime);
	SetCvar("mp_roundtime",						cRoundTime);
	SetCvar("mp_roundtime_hostage",				cRoundTime);
	SetCvar("mp_ct_default_secondary", 			" ");
	SetCvar("mp_t_default_secondary", 			" ");
	SetCvar("mp_respawn_on_death_ct", 			"0");
	SetCvar("mp_respawn_on_death_t", 			"0");
	SetCvar("mp_death_drop_gun", 				"0");
	SetCvar("mp_freezetime", 					"2");
	SetCvar("mp_ignore_round_win_conditions", 	"1");
	SetCvar("mp_maxmoney", 						"0");
	SetCvar("mp_friendlyfire", 					"0");
	SetCvar("mp_halftime", 						"0");
	SetCvar("mp_teamcashawards", 				"0");
}

void SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true);
	
	int flags = GetConVarFlags(cvar);
	SetConVarFlags(cvar, flags & ~FCVAR_NOTIFY);
}