#if defined _smrpg_upgrades_included
  #endinput
#endif
#define _smrpg_upgrades_included

#include <smrpg>

/**
 * The reason for the call of the SMRPG_UpgradeQueryCB callback.
 * This helps to determine, if the upgrade's level increased or decreased.
 */
enum UpgradeQueryType
{
	UpgradeQueryType_Buy, // The upgrade was bought by the client. I.e. the upgrade's level just increased.
	UpgradeQueryType_Sell // The upgrade was sold by the client. I.e. the upgrade's level just decreased.
};

/**
 * This callback is called by the core plugin, when the client buys or sells this upgrade.
 * It's also called, when an admin changes the upgrade level of the client, or the client disconnects.
 * The client does not have to be ingame!
 *
 * @param client         The client, whos upgrade level changed.
 * @param type           The type of the change. (buy or sell)
 */
typedef SMRPG_UpgradeQueryCB = function void (int client, UpgradeQueryType type);

/**
 * Called to check, if an upgrade's effect is currently active on a client.
 * This gets called by the SMRPG_IsUpgradeActiveOnClient native, to ask the plugin, which registered the upgrade, if it's currently doing something.
 *
 * This is mostly interesting for active upgrades. Passive upgrades can just check, if the client's upgrade level is > 0.
 *
 * @param client         The client, which should be checked, if the upgrade is currently active on him.
 * @return True, if the upgrade's effect is currently active on the client, false otherwise.
 */
typedef SMRPG_ActiveQueryCB = function bool (int client);

/**
 * Registers a new upgrade to the rpg core.
 * This will show up in the rpgmenu.
 * The shortname is like an unique identifier for this upgrade.
 * Other plugins might use the shortname to check for information of the upgrade.
 *
 * This native registers 8 default convars for the upgrade and saves them in a seperate config file in cfg/sourcemod/smrpg/smrpg_upgrade_<shortname>.cfg
 *  - smrpg_<shortname>_enable     ~ Enable or disable the upgrade. The upgrade needs to check this value and should obey it..
 *  - smrpg_<shortname>_maxlevel   ~ The maximal level a player can buy the upgrade.
 *  - smrpg_<shortname>_startlevel ~ The initial levels players get of this upgrade when they first join the server.
 *  - smrpg_<shortname>_cost       ~ The start cost of this item when purchasing level 1.
 *  - smrpg_<shortname>_icost      ~ The amount to increase the cost for each level: cost for level x = startcost + icost * (level-1)
 *  - smrpg_<shortname>_adminflag  ~ The required admin flag to use this upgrade.
 *  - smrpg_<shortname>_allowbots  ~ Are bots allowed to use this upgrade? Defaults to 1.
 *  - smrpg_<shortname>_teamlock   ~ Restrict access to this upgrade to a team? 0 = Disable, 2: RED/Terrorist team, 3: BLU/Counter-Terrorist team. Defaults to 0.
 *
 * You can add more convars to that file using the SMRPG_CreateUpgradeConVar native.
 *
 * @param name              The full name of the upgrade. This is displayed in the rpgmenu. Set a translation callback to dynamically change it.
 * @param shortname         A short abbreviative name for this upgrade. It's the primary unique identifier used in all other upgrade-specific natives.
 * @param description       A verbose description of the upgrade. Shown in the rpghelp menu.
 * @param maxlevelbarrier   Hardcoded limit you don't want the maxlevel to exceed. You can't set the maxlevel higher than this. This value can't be changed during runtime. (0 doesn't limit the maxlevel)
 * @param bDefaultEnable    Do you want this upgrade to be enabled by default? Default value of the _enable convar.
 * @param iDefaultMaxLevel  The default maxlevel of this upgrade. Players won't be able to buy more levels of this upgrade than this. Default value of the _maxlevel convar.
 * @param iDefaultStartCost The default start costs to buy level 1 of this upgrade. Default of the _cost convar.
 * @param iDefaultCostInc   The default incremential cost to buy higher levels of this upgrade. See _icost comment above. Default of the _icost convar.
 * @param iAdminFlags       Restrict this upgrade to players with certain flags. See ADMFLAG_* defines. Set to 0 to have it usable by everyone by default.
 * @param querycb           Deprecated and optional. @see SMRPG_SetUpgradeBuySellCallback
 * @param activecb          Deprecated and optional. @see SMRPG_SetUpgradeActiveQueryCallback
 * @error Upgrade shortname already exists.
 */
native void SMRPG_RegisterUpgradeType(const char[] name, const char[] shortname, const char[] description, int maxlevelbarrier, bool bDefaultEnable, int iDefaultMaxLevel, int iDefaultStartCost, int iDefaultCostInc, int iAdminFlags=0, SMRPG_UpgradeQueryCB querycb=INVALID_FUNCTION, SMRPG_ActiveQueryCB activecb=INVALID_FUNCTION);

/**
 * Unregisters a given upgrade from the core.
 * It will be hidden from the rpgmenu and all queries regarding this upgrade will fail.
 *
 * Call this in OnPluginEnd()!
 *
 * @param shortname      The shortname of the upgrade you want to unregister.
 * @error Unknown upgrade shortname.
 */
native void SMRPG_UnregisterUpgradeType(const char[] shortname);

/**
 * Create a convar for the upgrade.
 * The convar is added to the upgrade's specific autogenerated config file in cfg/sourcemod/smrpg/smrpg_upgrade_<shortname>.cfg next to the default convars.
 * This helps to keep all upgrade configuration in one centralized uniform place.
 *
 * @param shortname      The shortname of the upgrade you want to register this convar for.
 * @param name           Name of new convar.
 * @param defaultValue   String containing the default value of new convar.
 * @param description    Optional description of the convar.
 * @param flags          Optional bitstring of flags determining how the convar should be handled. See FCVAR_* constants for more details.
 * @param hasMin         Optional boolean that determines if the convar has a minimum value.
 * @param min            Minimum floating point value that the convar can have if hasMin is true.
 * @param hasMax         Optional boolean that determines if the convar has a maximum value.
 * @param max            Maximum floating point value that the convar can have if hasMax is true.
 * @return A handle to the newly created convar. If the convar already exists, a handle to it will still be returned.
 * @error Convar name is blank or is the same as an existing console command.
 */
native ConVar SMRPG_CreateUpgradeConVar(const char[] shortname, const char[] name, const char[] defaultValue, const char[] description="", int flags=0, bool hasMin=false, float min=0.0, bool hasMax=false, float max=0.0);

/**
 * Sets the callback to be called when a player buys or sells the upgrade.
 * 
 * You only need to set this, if you want to do something when the level of the upgrade changes.
 *
 * @param shortname      The shortname of the upgrade you want to receive buy and sell notifications for.
 * @param cb             The callback function to register.
 * @error Invalid upgrade shortname or called from a different plugin than which registered the upgrade in the first place.
 */
native void SMRPG_SetUpgradeBuySellCallback(const char[] shortname, SMRPG_UpgradeQueryCB cb);

/**
 * Sets the callback to be used when another plugin wants to know,
 * if the effect of the upgrade is currently active on a client.
 *
 * You only need to set this, if your upgrade effect is an active effect and not passive.
 * If the effect is always on once the player bought the upgrade, like health regeneration,
 * you don't have to register this callback. The RPG core will handle the queries for you
 * with all the necassary checks.
 * It defaults to something like
 *
 * return SMRPG_IsEnabled() && upgrade[UI_enabled] && SMRPG_GetClientUpgradeLevel(client, UPGRADE_SHORTNAME) > 0;
 *
 * If your upgrade adds an effect in reaction to some event, like adding speed when hit,
 * you should register this query callback and return whether the client is currently
 * under your effect or not.
 *
 * The callback will only be called, if the above general checks pass.
 *
 * @param shortname      The shortname of the upgrade you want to add the active query callback to.
 * @param cb             The callback function to register.
 * @error Invalid upgrade shortname or called from a different plugin than which registered the upgrade in the first place.
 */
native void SMRPG_SetUpgradeActiveQueryCallback(const char[] shortname, SMRPG_ActiveQueryCB cb);

/**
 * Types of translatable information of the upgrade.
 */
enum TranslationType
{
  TranslationType_Name, // Full name of the upgrade
  TranslationType_Description // Verbose description of the upgrade
};

/**
 * Called, when the core plugin wants to print information about this upgrade. (e.g. in the rpgmenu upgrades list)
 * The translation defaults to the strings that were passed when registering the upgrade.
 *
 * @param client         The client, to which language you should translate to.
 * @param shortname      The shortname of the upgrade.
 * @param type           The requested TranslationType (name or description).
 * @param translation    The translation buffer.
 * @param maxlen         The maximal length of the buffer.
 */
typedef SMRPG_TranslateUpgradeCB = function void (int client, const char[] shortname, TranslationType type, char[] translation, int maxlen);

/**
 * Set a translation callback for the named upgrade.
 * This is used to translate the name and description of the upgrade into different languages when needed.
 * This has to be called from the same plugin, which registered the upgrade, therefore AFTER SMRPG_RegisterUpgradeType!
 *
 * @param shortname      The shortname of the upgrade you want to add the translation callback to.
 * @param cb             The callback function to register.
 * @error Unknown upgrade shortname.
 */
native void SMRPG_SetUpgradeTranslationCallback(const char[] shortname, SMRPG_TranslateUpgradeCB cb);

/**
 * Called, when another plugin wants to stop the effect of this upgrade via SMRPG_ResetUpgradeEffectOnClient.
 * You should stop all changes on the client, that your upgrade currently does.
 *
 * Passive upgrades (like regeneration) don't need to register this callback.
 *
 * @param client         Stop all effects on this client.
 */
typedef SMRPG_ResetEffectCB = function void (int client);

/**
 * Set a effect reset callback for the named upgrade.
 * This is used to give other plugins the possiblity to stop interfering effects using SMRPG_ResetUpgradeEffectOnClient.
 * This has to be called from the same plugin, which registered the upgrade, therefore AFTER SMRPG_RegisterUpgradeType!
 *
 * Register this callback, if you do some active effects (like freezing)
 *
 * @param shortname      The shortname of the upgrade you want to add the translation callback to.
 * @param cb             The callback function to register.
 * @error Unknown upgrade shortname.
 */
native void SMRPG_SetUpgradeResetCallback(const char[] shortname, SMRPG_ResetEffectCB cb);

/** List of different cosmetical effects */
enum SMRPG_FX {
  SMRPG_FX_Visuals = 0, // Upgrade has some visual effects
  SMRPG_FX_Sounds       // Upgrade has some sound effects
};

/**
 * Tells the core that this upgrade does some visual and/or sound effects and if they should be enabled by default.
 * Convars to enable/disable the effects will be added to the upgrade's config file
 * - smrpg_<shortname>_visuals
 * - smrpg_<shortname>_sounds
 *
 * Clients have the option to change this setting for each upgrade themselves individually.
 *
 * @param shortname       The shortname of the upgrade.
 * @param effecttype      What kind of effect does this plugin support? See SMRPG_FX enum.
 * @param bDefaultEnable  Should the upgrade show the effects by default?
 * @error Unknown upgrade shortname.
 */
native void SMRPG_SetUpgradeDefaultCosmeticEffect(const char[] shortname, SMRPG_FX effecttype, bool bDefaultEnable);

/**
 * Returns whether a visual or sound effect should be played for a client.
 * 
 * @param client      The client index.
 * @param shortname   The shortname of the upgrade.
 * @param effecttype  The effect type to check for.
 * @return            True if client has that cosmetic type enabled, false otherwise.
 * @error Invalid client index, unknown upgrade shortname.
 */
native bool SMRPG_ClientWantsCosmetics(int client, const char[] shortname, SMRPG_FX effecttype);

/**
 * Signal other plugins that this upgrade is about to do its effects on a client.
 * This calls the SMRPG_OnUpgradeEffect forward, which allows other plugins to block the effect of this upgrade.
 *
 * This should be checked before applying any effects on a client, to see, if some other plugin doesn't want the effects to happen.
 * That way you can e.g. avoid interferences between upgrades that change the same prop.
 *
 * This also returns false, if the issuer doesn't have the required admin permissions (smrpg_[shortname]_adminflag convar) for this upgrade. (see SMRPG_CheckUpgradeAccess)
 *
 * @param target         The client which is about to get some effect applied.
 * @param shortname      The shortname of the upgrade that is about to apply its effect on the client.
 * @param issuer         (Optional) The client which starts the effect on the target. Leave at -1 to use the target as issuer for self effects.
 * @return True, if it's ok to run the effect, false if some other plugin doesn't want you to apply the effects.
 * @error Invalid client index, unknown upgrade shortname.
 */
native bool SMRPG_RunUpgradeEffect(int target, const char[] shortname, int issuer=-1);

/**
 * Check if an upgrade with that shortname exists.
 *
 * @param shortname      The shortname of the upgrade.
 * @return True, if there is an upgrade with that shortname registered, false otherwise.
 */
native bool SMRPG_UpgradeExists(const char[] shortname);

/**
 * The maximal length of the full name of an upgrade
 */
#define MAX_UPGRADE_NAME_LENGTH 64
/**
 * The maximal length of the short name of an upgrade
 */
#define MAX_UPGRADE_SHORTNAME_LENGTH 32
/**
 * The maximal length of the description of an upgrade
 */
#define MAX_UPGRADE_DESCRIPTION_LENGTH 128

/**
 * Detailed upgrade info of some upgrade.
 */
enum UpgradeInfo
{
	bool:UI_enabled, // upgrade enabled?
	UI_maxLevelBarrier, // upper limit of maxlevel setting. Can't set maxlevel higher than that.
	UI_maxLevel, // Maximal level a player can get for this upgrade
	UI_startCost, // The amount of credits the first level costs
	UI_incCost, // The amount of credits each level costs more
	UI_adminFlag, // The admin flag(s) (ADMFLAG_*) this upgrade is restricted to. (See SMRPG_CheckUpgradeAccess and SMRPG_RunUpgradeEffect)
	UI_teamlock, // The team this upgrade is restricted to. 0 = Disabled, 2 = RED/Terrorist team, 3 = BLU/Counter-Terrorist team
	String:UI_name[MAX_UPGRADE_NAME_LENGTH], // Upgrade readable name as given when registering the upgrade.
	String:UI_shortName[MAX_UPGRADE_SHORTNAME_LENGTH], // shortname used as unique identifier in all commands and database
	String:UI_description[MAX_UPGRADE_DESCRIPTION_LENGTH], // Upgrade description as given when registering the upgrade.
	UI_startLevel // Initial level of upgrade when players first join the server.
};

/**
 * Get the UpgradeInfo of an upgrade.
 *
 * @param shortname      The shortname of the upgrade you want to know more about.
 * @param upgrade        An buffer array to hold all the upgrade information.
 * @param size           The size of the buffer array.
 * @error Unkown upgrade shortname.
 */
native void SMRPG_GetUpgradeInfo(const char[] shortname, upgrade[UpgradeInfo], int size=view_as<int>(UpgradeInfo));

/**
 * Ask the plugin controlling an upgrade to remove all active effects from a client.
 * This only works, if the plugin, which registered the shortname named upgrade, has a reset callback set correctly.
 * If the other plugin did not set such a reset callback with SMRPG_SetUpgradeResetCallback, this won't have any effect :(
 *
 * @param client         The client to stop all effects on.
 * @param shortname      The upgrade shortname, which effects should be stopped on the client.
 * @error Invalid client index, unknown upgrade shortname.
 */
native void SMRPG_ResetUpgradeEffectOnClient(int client, const char[] shortname);

/**
 * Checks if an upgrade's effect is currently active on a client.
 * This calls the SMRPG_ActiveQueryCB callback of the upgrade.
 *
 * @param client         The client to check for the effect of an upgrade.
 * @param shortname      The upgrade shortname, which should be checked, if it has some effects active on a client.
 * @return True, if the plugin handling the upgrade said, there is some effect active, false otherwise.
 * @error Invalid client index, unknown upgrade shortname.
 */
native bool SMRPG_IsUpgradeActiveOnClient(int client, const char[] shortname);

/**
 * Checks if a client has access to an upgrade.
 * This checks for the admin flag(s) set in the smrpg_[shortname]_adminflag convar created for the plugin
 * and can be overwritten using an "smrpg_upgrade_[shortname]" like "smrpg_upgrade_health" admin override.
 *
 * ATTENTION: You don't have to check the access manually when running an upgrade effect. SMRPG_RunUpgradeEffect handles this for you.
 *
 * @param client         The client to check for access to an upgrade.
 * @param shortname      The shortname of the upgrade to check the client's access for.
 * @return True, if the client is allowed to use this upgrade, false otherwise.
 * @error Invalid client index, unknown upgrade shortname.
 */
native bool SMRPG_CheckUpgradeAccess(int client, const char[] shortname);

/**
 * Get the selected level of an upgrade of a client.
 * Players can choose to use a lower level of the upgrade than they've purchased.
 * This native returns the selected, active level of the upgrade. If you want to know the maximum purchased level, use SMRPG_GetClientPurchasedUpgradeLevel.
 *
 * @param client         The client which upgrade level you want to know.
 * @param shortname      The upgrade shortname
 * @return The level of the upgrade the client has selected. 0 if he didn't buy it yet or has it disabled.
 * @error Invalid client index, unknown upgrade shortname.
 */
native int SMRPG_GetClientUpgradeLevel(int client, const char[] shortname);

/**
 * Get the maximum purchased level of an upgrade of a client.
 * Players can choose to use a lower level of the upgrade than they've purchased.
 * This native returns the maximum purchased level of the upgrade. If you want to know the actual selected level, use SMRPG_GetClientUpgradeLevel.
 *
 * @param client         The client which upgrade level you want to know.
 * @param shortname      The upgrade shortname
 * @return The level of the upgrade the client has purchased. 0 if he didn't buy it yet.
 * @error Invalid client index, unknown upgrade shortname.
 */
native int SMRPG_GetClientPurchasedUpgradeLevel(int client, const char[] shortname);

/**
 * Check if a client has the reached the maximum level of an upgrade.
 *
 * @param client        The client index.
 * @param shortname     The upgrade shortname.
 * @return True if client has the maximal upgrade level, false otherwise.
 */
stock bool SMRPG_IsClientUpgradeMaxed(int client, const char[] shortname)
{
  new upgrade[UpgradeInfo];
  SMRPG_GetUpgradeInfo(shortname, upgrade);
  
  new iCurrentLevel = SMRPG_GetClientPurchasedUpgradeLevel(client, shortname);
  if(iCurrentLevel >= upgrade[UI_maxLevel])
    return true;
  return false;
}

/**
 * Sets the selected level of the upgrade for a client. This level can't be higher than the level of the upgrade the player has purchased.
 * Players can set their level to lower one than they actually purchased to compensate handycaps or similar.
 *
 * @param client         The client to set the selected upgrade level for.
 * @param shortname      The shortname of the upgrade to set the selected level for.
 * @param iLevel         The new selected level of the upgrade.
 * @error Invalid client index, unknown upgrade shortname or purchased level lower than the one you want to select.
 */
native bool SMRPG_SetClientSelectedUpgradeLevel(int client, const char[] shortname, int iLevel);

/**
 * Lets a client buy an upgrade and increases his upgrade level by 1.
 * Silently caps the level at the maxlevel.
 * This calls the SMRPG_OnBuyUpgrade forward to let other plugins know about the change. They can override that forward to block the buying.
 *
 * @param client         The client, which should buy a level of this upgrade.
 * @param shortname      The upgrade shortname which the client should buy.
 * @return True, if the client bought the upgrade, false if some other plugin stopped the buying in SMRPG_OnBuyUpgrade.
 * @error Invalid client index, unknown upgrade shortname.
 */
native bool SMRPG_ClientBuyUpgrade(int client, const char[] shortname);

/**
 * Lets a client sell an upgrade and decreases his upgrade level by 1.
 * Silently caps the level at 0.
 * This calls the SMRPG_OnSellUpgrade forward to let other plugins know about the change. They can override that forward to block the selling.
 *
 * @param client         The client, which should sell a level of this upgrade.
 * @param shortname      The upgrade shortname which the client should sell.
 * @return True, if the client sold the upgrade, false if some other plugin stopped the selling in SMRPG_OnSellUpgrade.
 * @error Invalid client index, unknown upgrade shortname.
 */
native bool SMRPG_ClientSellUpgrade(int client, const char[] shortname);

/**
 * Called when a client buys an upgrade or in general, when a client's upgrade level increases.
 * You can stop that from happening by returning Plugin_Handled.
 *
 * @param client         The client who is about to buy an upgrade.
 * @param shortname      The upgrade shortname of the upgrade being bought.
 * @param newlevel       The new level, the client's upgrade will be set to.
 * @return >= Plugin_Handled to block the client from buying that upgrade, Plugin_Continue to let it pass.
 */
forward Action SMRPG_OnBuyUpgrade(int client, const char[] shortname, int newlevel);

/**
 * Called after a client bought an upgrade or in general, when a client's upgrade level increased.
 *
 * @param client         The client who bought an upgrade.
 * @param shortname      The upgrade shortname of the upgrade bought.
 * @param newlevel       The new level, the client's upgrade is set to.
 */
forward void SMRPG_OnBuyUpgradePost(int client, const char[] shortname, int newlevel);

/**
 * Called when a client sells an upgrade or in general, when a client's upgrade level decreases.
 * You can stop that from happening by returning Plugin_Handled.
 *
 * @param client         The client who is about to sell an upgrade.
 * @param shortname      The upgrade shortname of the upgrade being sold.
 * @param newlevel       The new level, the client's upgrade will be set to.
 * @return >= Plugin_Handled to block the client from selling that upgrade, Plugin_Continue to let it pass.
 */
forward Action SMRPG_OnSellUpgrade(int client, const char[] shortname, int newlevel);

/**
 * Called after a client sold an upgrade or in general, when a client's upgrade level decreased.
 *
 * @param client         The client who sold an upgrade.
 * @param shortname      The upgrade shortname of the upgrade sold.
 * @param newlevel       The new level, the client's upgrade is set to.
 */
forward void SMRPG_OnSellUpgradePost(int client, const char[] shortname, int newlevel);

/**
 * Called when an upgrade is about to start his effect on a client.
 * The upgrades have to call SMRPG_RunUpgradeEffect for this to work.
 *
 * @param target         The client which is about to get some effect applied by the upgrade.
 * @param shortname      The shortname of the upgrade that is about to apply an effect.
 * @param issuer         (Optional) The client which starts the effect on the target. (Same as target by default)
 * @return >= Plugin_Handled to tell the upgrade to NOT run the effect, Plugin_Continue to let it pass.
 */
forward Action SMRPG_OnUpgradeEffect(int target, const char[] shortname, int issuer);

/**
 * Called after the default convars of an upgrade have changed.
 * @see SMRPG_RegisterUpgradeType
 *
 * @param shortname      The shortname of the upgrade which settings have changed.
 */
forward void SMRPG_OnUpgradeSettingsChanged(const char[] shortname);

/**
 * Called when an upgrade is registered.
 * It's not guaranteed that upgrade levels are loaded for players yet.
 * @see SMRPG_OnClientLoaded.
 *
 * @param shortname      The shortname of the loaded upgrade.
 */
forward void SMRPG_OnUpgradeRegistered(const char[] shortname);

/**
 * Called when an upgrade is unregistered from the core and is no longer available.
 *
 * @param shortname      The shortname of the loaded upgrade.
 */
forward void SMRPG_OnUpgradeUnregistered(const char[] shortname);