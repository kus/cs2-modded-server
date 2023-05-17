#if defined _ps
 #endinput
#endif
#define _ps

/**
 * Gets the status of the points system
 *
 * @return Boolean value corresponding to the status of the points system. false if disabled, true if enabled.
 */
native bool PS_IsSystemEnabled();

/**
 * Gets the version of PS
 *
 * @return				current version of ps system in form of a float
 */
native float PS_GetVersion();

/**
 * Sets a client's points
 *
 * @param client			client index
 * @param newval			new value of a client's points
 * @return				none
 */
native void PS_SetPoints(int iClientIndex, int iPoints);

/**
 * Deduct's points from client
 *
 * @param iClientIndex		client index
 * @param iCost				Points to deduct
 * @return					none
 */
native void PS_RemovePoints(int iClientIndex, int iCost);

/**
 * Sets a client's item string
 *
 * @param client			client index
 * @param newstring			new value of a client's item string
 * @return				none
 */
native void PS_SetItem(int iClientIndex, const char[] sPurchaseCmd);

/**
 * Sets a client's item cost
 *
 * @param client			client index
 * @param newval			new value of a client's points
 * @return				none
 */
native void PS_SetCost(int iClientIndex, int iPoints);

/**
 * Sets a client's bought string
 *
 * @param client			client index
 * @param newstring			new value of a client's bought string
 * @return				none
 */
native void PS_SetBought(int iClientIndex, const char[] sPurchaseCmd);

/**
 * Sets a client's bought cost
 *
 * @param client			client index
 * @param newval			new value of a client's points
 * @return				none
 */
native void PS_SetBoughtCost(int iClientIndex, int iCost);

/**
 * Sets up an uncommon mob
 *
 * @param newval		amount of uncommon to spawn
 * @return				none
 */
native void PS_SetupUMob(int iNumUCommon);

/**
 * Gets a client's bought cost
 *
 * @param client			client index
 * @return				boughtcost
 */
native int PS_GetBoughtCost(int iClientIndex);

/**
 * Gets a client's points
 *
 * @param client			client index
 * @return				points
 */
native int PS_GetPoints(int iClientIndex);

/**
 * Gets a client's current item cost
 *
 * @param client			client index
 * @return				cost
 */
native int PS_GetCost(int iClientIndex);

/**
 * Gets a client's current item
 *
 * @param client			client index
 * @param dest				destination for the item string to go
 * @return				cost
 */
native int PS_GetItem(int iClientIndex, char[] sItem);

/**
 * Gets a client's current bought item
 *
 * @param client		client index
 * @param dest			destination for the bought string to go
 * @return				cost
 */
native int PS_GetBought(int iClientIndex, char[] sItem);

/**
 * Registers a module for points system
 *
 * @param modulename	String that contains the module to be registered's name
 * @return				false if successful true if already registered
 */
 native bool PS_RegisterModule(char[] sModuleName);
 
 /**
  * Unregisters a module for points system
  *
  * @param modulename	String that contains the module to be unregistered's name
  * @return				none
  */
 native void PS_UnregisterModule(char[] sModuleName);
 
 /**
  * Called when Points System is loaded
  *
  * @param late			if PS was late loaded this will be true
  * @return				none
  */
 forward void OnPSLoaded(bool bLate);
 
 /**
  * Called when Points System is unloaded
  *
  * @param late			if PS was late loaded this will be true
  * @return				none
  */
 forward void OnPSUnloaded();