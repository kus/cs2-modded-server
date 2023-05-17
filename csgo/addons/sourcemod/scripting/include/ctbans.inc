#if defined _CTBANS_included
 #endinput
#endif
#define _CTBANS_included

/*********************************************************
 * returns if client is CT Banned
 *
 * @param client The client to run the check on
 * @true on banned, false if not
 *********************************************************/
native CTBans_IsCTBanned(int client);