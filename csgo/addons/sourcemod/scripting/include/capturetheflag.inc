#if defined _capturetheflag_included
 #endinput
#endif
#define _capturetheflag_included

/**
* Checks if player has flag
*
* @param int				Player to check
* @return					true or false
*/
native bool CaptureTheFlag_HasFlag(client);

/**
* Event on flag taken
*
* @param int				Player who took the flag from other team
*/
forward int CaptureTheFlag_OnFlagTaken(client);

/**
* Event on flag dropped
*
* @param int				Player who dropped the flag
*/
forward int CaptureTheFlag_OnFlagDropped(client);

/**
* Event on flag returned to base (team score)
*
* @param int				Player who score for the team
*/
forward int CaptureTheFlag_OnFlagScore(client);


public void __pl_basebuilder__SetNTVOptional() 
{
	MarkNativeAsOptional("CaptureTheFlag_HasFlag");
}