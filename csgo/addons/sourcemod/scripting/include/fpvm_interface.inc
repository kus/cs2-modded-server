/** Double-include prevention */
#if defined _fpvm_interface_included_
  #endinput
#endif
#define _fpvm_interface_included_


/**
 * Add a custom view model to a weapon
 *
 * @param client     Player for check
 * @String weapon     Weapon to replace
 * @param weaponview_index     The weapon precached index with the view model.
 * @return no return
 */
native void FPVMI_AddViewModelToClient(int client, char[] weapon, int weaponview_index=-1);

/**
 * Add a custom world model to a weapon
 *
 * @param client     Player for check
 * @String weapon     Weapon to replace
 * @param weaponwold_index    The weapon precached index with the view model. -1 = default model
 * @return no return
 */
native void FPVMI_AddWorldModelToClient(int client, char[] weapon, int weaponworld_index=-1);

/**
 * Add a custom drop model to a weapon
 *
 * @param client     Player for check
 * @String weapon     Weapon to replace
 * @String dropmodel    The weapon model
 * @return no return
 */
native void FPVMI_AddDropModelToClient(int client, char[] weapon, char[] dropmodel="none");

/**
 * Return the custom world model index of a client
 *
 * @param client     Player for check
 * @String weapon     Weapon to search
 * @return Return the custom world model index of a client. -1 if the client dont have a custom world model
 */
native int FPVMI_GetClientWorldModel(int client, char[] weapon);

/**
 * Return the custom view model index of a client
 *
 * @param client     Player for check
 * @String weapon     Weapon to search
 * @return Return the custom wview model index of a client. -1 if the client dont have a custom view model
 */
native int FPVMI_GetClientViewModel(int client, char[] weapon);

/**
 * Return the custom drop model index of a client
 *
 * @param client     Player for check
 * @String weapon     Weapon to search
 * @String drop     copy the dropmodel string
 */
native void FPVMI_GetClientDropModel(int client, char[] weapon, char[] dropmodel);

/**
 * Set a custom view/world model to a weapon
 *
 * @param client     Player for check
 * @String weapon     Weapon to replace
 * @param weapon_index     The weapon precached index with the view model. -1 = default model
 * @param weaponwold_index    The weapon precached index with the view model. -1 = default model
 * @return no return
 */
native void FPVMI_SetClientModel(int client, char[] weapon, int weaponview_index=-1, int weaponworld_index=-1, char[] dropmodel="none");

/**
 * Remove a custom view model to a weapon
 *
 * @param client     Player for check
 * @String weapon     Weapon to replace
 * @return no return
 */
native void FPVMI_RemoveViewModelToClient(int client, char[] weapon);

/**
 * Remove a custom world model to a weapon
 *
 * @param client     Player for check
 * @String weapon     Weapon to replace
 * @return no return
 */
native void FPVMI_RemoveWorldModelToClient(int client, char[] weapon);

/**
 * Remove a custom drop model to a weapon
 *
 * @param client     Player for check
 * @String weapon     Weapon to replace
 * @return no return
 */
native void FPVMI_RemoveDropModelToClient(int client, char[] weapon);

/**
 * Called when a View model has been set.
 *
 * @param client            Client.
 * @String weapon     Weapon
 * @param weapon_index     The weapon precached index 
 */
forward void FPVMI_OnClientViewModel(int client, const char[] weapon, int weapon_index);

/**
 * Called when a World model has been set.
 *
 * @param client            Client.
 * @String weapon     Weapon
 * @param weaponworld_index     The weapon precached index 
 */
forward void FPVMI_OnClientWorldModel(int client, const char[] weapon, int weaponworld_index);

/**
 * Called when a drop model has been set.
 *
 * @param client            Client.
 * @String weapon     Weapon
 * @String dropmodel     The weapon dropmodel
 */
forward void FPVMI_OnClientDropModel(int client, const char[] weapon, char[] dropmodel);