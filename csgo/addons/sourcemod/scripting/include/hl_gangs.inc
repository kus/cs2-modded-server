#if defined hl_gangs_include
  #endinput
#endif
#define hl_gangs_include
 
 
#define GANGS_VERSION "1.1.9.1"

/* Gang Ranks */
enum GangRank
{
	Rank_Invalid = -1,
	Rank_Normal,
	Rank_Admin,
	Rank_Owner
}

/**
 * Outputs a formatted message to the client
 *
 * @param	client			client index
 * @return  int				gang size
 */
native void Gangs_Message(int client, const char[] format, any ...);

/**
 * Outputs a formatted message to all clients
 *
 * @param	client			client index
 * @return  int				gang size
 */
native void Gangs_MessageToAll(int client, const char[] format, any ...);

/**
 * Returns the size of a client's gang
 *
 * @param	client			client index
 * @return  int				gang size
 */
native int Gangs_GetGangSize(int client);

/**
 * Returns if a client is a member of a gang
 *
 * @param	client			client index
 * @return  bool			gang status
 */
native bool Gangs_HasGang(int client);

/**
 * Get a client's gang rank
 *
 * @param	client			client index
 * @return  GangRank		gang rank
 */
native GangRank Gangs_GetGangRank(int client);

/**
 * Get a client's gang name
 *
 * @param	client			client index
 * @return					no return
 */
native void Gangs_GetGangName(int client, char[] buffer, int maxlength);

/**
 * Returns a client's damage modifier
 *
 * @param	client			client index
 * @return  float			damage modifier
 */
native float Gangs_GetDamageModifier(int client);

/**
 * Called after the main menu is built, but before it's displayed.
 * @param client Player's index.
 * @param menu Menu being displayed to the client.
 * @noreturn
 */
forward void Gangs_OnMenuCreated(int client, Menu menu);

/**
 * Called once a main menu item has been selected
 * @param menu Menu displayed
 * @param action Menu Action
 * @param param1 client index
 * @param param2 
 * @noreturn
 */
forward void Gangs_OnMenuCallback(Menu menu, MenuAction action, int param1, int param2);

/**
 * Called after the perk menu is built, but before it's displayed.
 * This is where you can add custom perks. See Gangs_OnPerkMenuCallback
 *
 * @param client Player's index.
 * @param menu Menu being displayed to the client.
 * @noreturn
 */
forward void Gangs_OnPerkMenuCreated(int client, Menu menu);

/**
 * Called once a perk menu item has been selected
 * @param menu Menu displayed
 * @param action Menu Action
 * @param param1 client index
 * @param param2 
 * @noreturn
 */
forward void Gangs_OnPerkMenuCallback(Menu menu, MenuAction action, int param1, int param2);


/**
 * Called immediately before perks are given. Set shouldGive to false in order to skip giving perks.
 
 * @param int client index
 * @param &bool shouldGive
 * @noreturn
 */
forward void Gangs_OnPerksSetPre(int client, bool &shouldGive);

public SharedPlugin __pl_hl_gangs  =
{
	name = "hl_gangs",
	file = "hl_gangs.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_hl_gangs_SetNTVOptional()
{	
	MarkNativeAsOptional("Gangs_GetDamageModifier");
	MarkNativeAsOptional("Gangs_GetGangName");
	MarkNativeAsOptional("Gangs_GetGangRank");
	MarkNativeAsOptional("Gangs_HasGang");
	MarkNativeAsOptional("Gangs_GetGangSize");
	MarkNativeAsOptional("Gangs_Message");
	MarkNativeAsOptional("Gangs_MessageToAll");
}
#endif