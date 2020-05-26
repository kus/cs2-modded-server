void HintBox_OnGameFrame()
{
	
	if(t_Flag > 0 && ct_Flag > 0 && IsValidEntity(t_Flag) && IsValidEntity(ct_Flag))
	{
	
		LoopAllPlayers(i)
		{
			
			char HasFlagMessage[150] = "";
			if(GetFlagCarrier(CS_TEAM_CT) == i)
				HasFlagMessage = "<font size='35' color='#4a75b5'>You got the flag!</font>\n\n";
			else if(GetFlagCarrier(CS_TEAM_T) == i)
				HasFlagMessage = "<font size='35' color='#EB2828'>You got the flag!</font>\n\n";
			
			if(IsFlagInSpawn(CS_TEAM_T)) {
				c_tFlagPlace = "in base";
			} else {
				if(GetFlagCarrier(CS_TEAM_CT) == -1)
					c_tFlagPlace = "dropped";
				else
					c_tFlagPlace = "taken";
			}
				
			if(IsFlagInSpawn(CS_TEAM_CT)) {
				c_ctFlagPlace = "in base";
			} else {
				if(GetFlagCarrier(CS_TEAM_T) == -1)
					c_ctFlagPlace = "dropped";
				else
					c_ctFlagPlace = "taken";
			}

			
			char CtMessage[150], tMessage[150];
			Format(CtMessage, sizeof(CtMessage),"%s<font size='22' color='#4a75b5'> CT FLAG: %i/%i </font><font size='18' color='#0D51B8'>(flag is %s)</font>\n    ",HasFlagMessage,	GetTeamScore(CS_TEAM_CT), MaxFlags, c_ctFlagPlace);
			Format(tMessage, sizeof(tMessage), 	"<font size='22' color='#EB2828'>T FLAG: %i/%i </font><font size='18' color='#D10606'>(flag is %s)</font>", 			GetTeamScore(CS_TEAM_T), MaxFlags, c_tFlagPlace);
			
			PrintHintText(i, "%s%s", CtMessage, tMessage);
		}
	
	}
}