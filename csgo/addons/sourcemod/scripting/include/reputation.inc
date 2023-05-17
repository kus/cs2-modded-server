#if defined _REPUTATION_included
 #endinput
#endif
#define _REPUTATION_included

/**
 * Gets a client's reputation
 *
 * @param client		Client index.
 * @return				Returns reputation amount
 *
 * @error				Invalid client
 */
native Reputation_GetRep(int client);