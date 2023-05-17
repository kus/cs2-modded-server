 /*
    Include file for Bank.sp
    Provide simple functions to manage a player's bank.
    
    Created by Arkarr (Alliedmodders) EDITED/FIXED BY ShawnCZek
*/

#if defined _bank_included
 #endinput
#endif
#define _bank_included

/**
 * Create a new bank. Can't create bank with same name at once.
 *
 * @param bankName  The name of the bank
 * @return            True on sucess, false otherwise.
 */
native bool Bank_Create(const char[] bankName)

/**
 * Add or substract a certain ammount of credits of a player's balance.
 *
 * @param bank             The name of the bank
 * @param client        The client to add/substract to.
 * @param ammount       The ammount to add/substract.
 * @param forcecreate   Create the user if not found in the bank.
 * @return            True on sucess, false otherwise.
 */
native bool Bank_EditBalance(const char[] bank, int client, int ammount, bool forcecreate = true)

/**
 * Get the balance of a client in a specific bank.
 *
 * @param bank             The name of the bank
 * @param client    The client to get the balance of.
 * @return            The ammount of credits. -1 if no account found.
 */
native int Bank_GetBalance(const char[] bank, int client)

/**
 * Set the balance of a client in a specific bank.
 *
 * @param bank             The name of the bank
 * @param client        The client to set the balance of.
 * @param ammount       The ammount to set the balance of the player. That wasn't english.
 * @param forcecreate   Create the user if not found in the bank.
 * @return            True on sucess, false otherwise.
 */
native bool Bank_SetBalance(const char[] bank, int client, int ammount, bool forcecreate = true)

/**
 * Set the balance of a client in a specific bank.
 *
 * @param bank             The name of the bank
 * @param steamID        The client to set the balance of.
 * @param ammount       The ammount to set the balance of the player. That wasn't english.
 * @param forcecreate   Create the user if not found in the bank.
 * @return            True on sucess, false otherwise.
 */
native bool Bank_SetBalanceSteam(const char[] bank, const char[] steamID, int ammount, bool forcecreate = true)