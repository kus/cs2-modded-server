#if defined _sqlite_vip_api_included
  #endinput
#endif
#define _sqlite_vip_api_included

/**

*	@note			This forward is called when SQLite VIP API has connected to it's database.

*/

forward SQLiteVIPAPI_OnDatabaseConnected();

/**

* @param client		Client index that was authenticated.
* @param VIPLevel	VIP Level of the client, or 0 if the player is not VIP.
 
* @note				This forward is called for non-vip players as well as VIPs.
* @note				This forward can be called more than once in a client's lifetime, assuming his VIP Level has changed.
* @noreturn		
*/

forward SQLiteVIPAPI_OnClientAuthorized(client, &VIPLevel);

/**

* @param client		Client index that was authenticated.
* @param VIPLevel	VIP Level of the client, or 0 if the player is not VIP.
 
* @note				This forward is called for non-vip players as well as VIPs.
* @note				This forward can be called more than once in a client's lifetime, assuming his VIP Level has changed.
* @noreturn		
*/

forward SQLiteVIPAPI_OnClientAuthorizedPost(client, VIPLevel);

/**

* @param client			Client index that changed his preference.
* @param FeatureSerial	Feature serial whose setting was changed.
* @param SettingValue	The new setting of the feature the client has set.
 
* @note					This forward is called whenever a client changes his feature preference.
* @note					This can be easily spammed by a client, and therefore should be noted.
* @noreturn		
*/

forward SQLiteVIPAPI_OnClientFeatureChanged(client, FeatureSerial, SettingValue);
/**

* @return			true if SQLite VIP API has connected to the database already, false otherwise.

*/

native SQLiteVIPAPI_IsDatabaseConnected();

/**

* @param client		Client index to check.
 
* @note				This forward is called for non-vip players as well as VIPs.
* @note				With the proper cvars, this isn't guaranteed to be called once, given the VIP Level of the VIP has decreased due to expiration of a better level / all of the levels.

* @return			VIP Level of the client, or 0 if the client is not a VIP. returns -1 if client was yet to be authenticated. If an error is thrown, returns -2 instead.

* @error			Client index is not in-game.
*/

native SQLiteVIPAPI_GetClientVIPLevel(client);

/**
* @param FeatureName	The name of the feature to be displayed in !settings.
* @param VIPLevelList	An arrayList containing each setting's VIP Level requirement
* @param NameList		An arrayList containing each setting's Name
* @param AlreadyExisted	Optional param to determine if the feature's name has already existed and therefore no feature was added. 

* @note					Only higher settings should be allowed to have higher VIP Levels than their lower ones.
* @note					You can execute this on "OnAllPluginsLoaded" even if the database is broken it'll still cache it.

* @return				Feature serial ID on success, 
* @error				List of setting variations exceed 25 ( it's too much anyways  )
*/

native bool:SQLiteVIPAPI_AddFeature(const String:FeatureName[64], Handle:VIPLevelList, Handle:NameList, &bool:AlreadyExisted=false);

/**

* @param client			Client index to check.
* @param FeatureSerial	Feature serial whose setting to find.

* @note 				Reduces to highest allowed value for the client if he lost a VIP status.
* @note					Returns -1 if the feature is entirely out of the client's league VIP wise. If an error is thrown, returns -2 instead.

* @return				Client's VIP setting for the feature given by the serial.

* @error				Client index is not in-game.

*/

native SQLiteVIPAPI_GetClientVIPFeature(client, FeatureSerial);

public SharedPlugin:__pl_sqlite_vip_api = 
{
	name = "SQLite VIP API",
	file = "SQLiteVIPApi.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_sqlite_vip_api_SetNTVOptional()
{
	MarkNativeAsOptional("SQLiteVIPAPI_GetClientVIPFeature");
	MarkNativeAsOptional("SQLiteVIPAPI_AddFeature");
	MarkNativeAsOptional("SQLiteVIPAPI_GetClientVIPLevel");
	MarkNativeAsOptional("SQLiteVIPAPI_IsDatabaseConnected");
}
#endif
