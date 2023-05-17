#if defined _smrpg_effects_included
  #endinput
#endif
#define _smrpg_effects_included

/**
 * Freezes a client in place. Can play optional effects on him.
 *
 * @param client             The client index.
 * @param fTime              The time to freeze the player for.
 * @param fDamageLimit       DEPRECATED: Overwritten by freeze_limit_damage.cfg! Don't allow more damage than this if victim is frozen. Set to 0, if you don't want to limit the damage.
 * @param sUpgradeName       Upgrade shortname which issues the freeze. Used to see if clients want to see the visual/sound effects.
 * @param bPlaySound         Play a random icy sound?
 * @param bFadeColor         Fade the player's model from blue to normal?
 * @param bResetVelocity     Reset the velocity of the client as well? You can just freeze him temporarily and keep the velocity. Useful for surfing.
 * @return                   True if client was frozen, false otherwise.
 * @error                    Invalid client index.
 */
native bool SMRPG_FreezeClient(int client, float fTime, float fDamageLimit, const char[] sUpgradeName, bool bPlaySound=true, bool bFadeColor=true, bool bResetVelocity=false);

/**
 * Unfreeze a client, if he was frozen by SMRPG_FreezeClient previously.
 *
 * @param client             The client index.
 * @error                    Invalid client index or client not frozen.
 */
native void SMRPG_UnfreezeClient(int client);

/**
 * Checks whether a client is frozen by this plugin.
 *
 * @param client             The client index.
 * @return                   True if frozen, false otherwise.
 * @error                    Invalid client index.
 */
native bool SMRPG_IsClientFrozen(int client);

/**
 * Ignites a client. Can play optional effects on him.
 *
 * @param client             The client index.
 * @param fTime              The time to let the player burn.
 * @param sUpgradeName       Upgrade shortname which issues the ignition. Used to see if clients want to see the visual/sound effects.
 * @param bFadeColor         Fade the player's model from red to normal?
 * @param attacker           The client index of the player responsible for the ignition. (-1 if not applicable)
 * @return                   True if client was ignited, false otherwise.
 * @error                    Invalid client index.
 */
native bool SMRPG_IgniteClient(int client, float fTime, const char[] sUpgradeName, bool bFadeColor=true, int attacker=-1);

/**
 * Extinguish a client, if he was ignited by SMRPG_IgniteClient previously.
 *
 * @param client             The client index.
 * @error                    Invalid client index or client not burning.
 */
native void SMRPG_ExtinguishClient(int client);

/**
 * Checks whether a client is ignited by this plugin.
 *
 * @param client             The client index.
 * @return                   True if burning, false otherwise.
 * @error                    Invalid client index.
 */
native bool SMRPG_IsClientBurning(int client);

/**
 * Set the default color of the player to reset to after some effects are run.
 * Color is not touched, if set to -1.
 *
 * @param client             The client index.
 * @param r                  The red channel (0-255) or -1 to leave unchanged.
 * @param g                  The green channel (0-255) or -1 to leave unchanged.
 * @param b                  The blue channel (0-255) or -1 to leave unchanged.
 * @param a                  The alpha channel (0-255) or -1 to leave unchanged.
 * @error                    Invalid client index.
 */
native void SMRPG_SetClientDefaultColor(int client, int r=-1, int g=-1, int b=-1, int a=-1);

/**
 * Set the render color of the player.
 * Color is not touched, if set to -1.
 *
 * @param client             The client index.
 * @param r                  The red channel (0-255) or -1 to leave unchanged.
 * @param g                  The green channel (0-255) or -1 to leave unchanged.
 * @param b                  The blue channel (0-255) or -1 to leave unchanged.
 * @param a                  The alpha channel (0-255) or -1 to leave unchanged.
 * @error                    Invalid client index.
 */
native void SMRPG_SetClientRenderColor(int client, int r=-1, int g=-1, int b=-1, int a=-1);

/**
 * Start fading the render color from the current value to this target color.
 * Uses the stepsize set with SMRPG_SetClientRenderColorFadeStepsize.
 * Color is not touched, if set to -1.
 *
 * @param client             The client index.
 * @param r                  The red channel (0-255) or -1 to leave unchanged.
 * @param g                  The green channel (0-255) or -1 to leave unchanged.
 * @param b                  The blue channel (0-255) or -1 to leave unchanged.
 * @param a                  The alpha channel (0-255) or -1 to leave unchanged.
 * @error                    Invalid client index.
 */
native void SMRPG_SetClientRenderColorFadeTarget(int client, int r=-1, int g=-1, int b=-1, int a=-1);

/**
 * Set the fade stepsize for each channel. Every frame the channel moves by that stepsize towards the fade target.
 * Stepsize is not touched, if set to -1.
 *
 * @param client             The client index.
 * @param r                  The step size for the red channel or -1 to leave unchanged.
 * @param g                  The step size for the green channel or -1 to leave unchanged.
 * @param b                  The step size for the blue channel or -1 to leave unchanged.
 * @param a                  The step size for the alpha channel or -1 to leave unchanged.
 * @error                    Invalid client index.
 */
native int SMRPG_SetClientRenderColorFadeStepsize(int client, float r=-1.0, float g=-1.0, float b=-1.0, float a=-1.0);

/**
 * Reset the render color of the client back to the set default color.
 * @see SMRPG_SetClientDefaultColor
 *
 * Only sets the color back, if it was last set by the same plugin.
 * This is to prevent prematurely resetting the effect of some other plugin, if that had our effect overwritten.
 *
 * @param client             The client index.
 * @param bResetRed          Should we reset the red channel back to default?
 * @param bResetGreen        Should we reset the green channel back to default?
 * @param bResetBlue         Should we reset the blue channel back to default?
 * @param bResetAlpha        Should we reset the alpha channel back to default?
 * @param bForceReset        Ignore which plugin last changed the channels and force a reset?
 * @error                    Invalid client index.
 */
native void SMRPG_ResetClientToDefaultColor(int client, bool bResetRed, bool bResetGreen, bool bResetBlue, bool bResetAlpha, bool bForceReset=false);

/**
 * Determines if the player was slowed down or sped up.
 */
enum LaggedMovementType {
	LMT_Slower = 0, // Player was slowed down.
	LMT_Faster // Player was sped up.
};

/**
 * Slow down or speed up the client for fTime seconds.
 * Default speed is 1.0 (100%). This native takes care for concurring slow downs vs. speed ups.
 *
 * Example:
 * Plugin 1 sets the speed to 0.7, so wants to slow the player down by 30%.
 * Plugin 2 sets the speed to 1.2, so wants to speed the player up by 20%.
 * The effective speed is set to 1.0 - 0.3 + 0.2 = 0.9!
 * 
 * You can reset one part of the speed change using @see SMRPG_ResetClientLaggedMovement's LaggedMovementType.
 *
 * @param client             The client index.
 * @param fValue             The percent of the players maxspeed you want to set him to. Defaults to 1.0. To slow down by 20% set to 0.8, to speed up by 30% to 1.3 etc.
 * @param fTime              How long do you want to change the speed in seconds?
 * @return                   True if players speed was changed, false otherwise. Could return false if the client is already slowed down further by another plugin than you want to set it to.
 * @error                    Invalid client index, negative fValue, negative fTime or fValue == 1.0. Use SMRPG_ResetClientLaggedMovement to reset to 1.0.
 */
native bool SMRPG_ChangeClientLaggedMovement(int client, float fValue, float fTime);

/**
 * Reset the previously changed speed of the player before the set time runs out.
 * You can reset the Slowdown or the speed up.
 * @see LaggedMovementType
 *
 * @param client             The client index.
 * @param type               The type of the speed change you want to reset. LMT_Slower or LMT_Faster, depending on how you changed it before.
 * @param bForce             Force it to reset that speed, even if your plugin didn't last set it.
 * @return                   True if the speed of that type was reset, false otherwise.
 * @error                    Invalid client index.
 */
native bool SMRPG_ResetClientLaggedMovement(int client, LaggedMovementType type, bool bForce=false);

/**
 * Check whether a client has his speed changed up or down (or both).
 * 
 * @param client             The client index.
 * @param type               The type of the speed change to check for. LMT_Slower or LMT_Faster.
 * @param bByMe              Set to true to only count changes done by your plugin or to false to also check for speed changes done by other plugins.
 * @return                   True if speed was changed, false otherwise.
 * @error                    Invalid client index.
 */
native bool SMRPG_IsClientLaggedMovementChanged(int client, LaggedMovementType type, bool bByMe=false);

/**
 * Called when a client is about to be frozen for fTime seconds.
 *
 * @param client     The client index.
 * @param &fTime     The time to freeze for. You can change it and return Plugin_Changed.
 * @return           >= Plugin_Handled to block, Plugin_Continue to allow freezing.
 */
forward Action SMRPG_OnClientFreeze(int client, float &fTime);

/**
 * Called when a client was frozen for fTime seconds.
 *
 * @param client     The client index.
 * @param fTime      The time to freeze for.
 */
forward void SMRPG_OnClientFrozen(int client, float fTime);

/**
 * Called when a client was unfrozen.
 *
 * @param client     The client index.
 */
forward void SMRPG_OnClientUnfrozen(int client);

/**
 * Called when a client is about to be ignited for fTime seconds.
 *
 * @param client     The client index.
 * @param &fTime     The time to burn for. You can change it and return Plugin_Changed.
 * @return           >= Plugin_Handled to block, Plugin_Continue to allow burning.
 */
forward Action SMRPG_OnClientIgnite(int client, float &fTime);

/**
 * Called when a client was ignited for fTime seconds.
 *
 * @param client     The client index.
 * @param fTime      The time to freeze for.
 */
forward void SMRPG_OnClientIgnited(int client, float fTime);

/**
 * Called when a client was extinguished.
 *
 * @param client     The client index.
 */
forward void SMRPG_OnClientExtinguished(int client);

/**
 * Called when the speed of a client is about to be changed for fTime seconds.
 *
 * @param client     The client index.
 * @param type       The type of the speed change. LMT_Faster or LMT_Slower.
 * @param &fTime     The time to change the speed for. You can change it and return Plugin_Changed.
 * @return           >= Plugin_Handled to block, Plugin_Continue to allow the change of the speed.
 */
forward Action SMRPG_OnClientLaggedMovementChange(int client, LaggedMovementType type, float &fTime);

/**
 * Called after the speed of a client was changed.
 *
 * @param client     The client index.
 * @param type       The type of the speed change. LMT_Faster or LMT_Slower.
 * @param fTime      The time the speed is changed for.
 */
forward void SMRPG_OnClientLaggedMovementChanged(int client, LaggedMovementType type, float fTime);

/**
 * Called when the speed of the client is reset to normal for the set type.
 * 
 * @param client     The client index.
 * @param type       The type of the reset speed change. LMT_Faster or LMT_Slower.
 */
forward void SMRPG_OnClientLaggedMovementReset(int client, LaggedMovementType type);

public SharedPlugin __pl_smrpg_effects = 
{
	name = "smrpg_effects",
	file = "smrpg_effects.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_smrpg_effects_SetNTVOptional()
{
	MarkNativeAsOptional("SMRPG_FreezeClient");
	MarkNativeAsOptional("SMRPG_UnfreezeClient");
	MarkNativeAsOptional("SMRPG_IsClientFrozen");
	
	MarkNativeAsOptional("SMRPG_IgniteClient");
	MarkNativeAsOptional("SMRPG_ExtinguishClient");
	MarkNativeAsOptional("SMRPG_IsClientBurning");
	
	MarkNativeAsOptional("SMRPG_SetClientDefaultColor");
	MarkNativeAsOptional("SMRPG_SetClientRenderColor");
	MarkNativeAsOptional("SMRPG_SetClientRenderColorFadeTarget");
	MarkNativeAsOptional("SMRPG_SetClientRenderColorFadeStepsize");
	MarkNativeAsOptional("SMRPG_ResetClientToDefaultColor");
	
	MarkNativeAsOptional("SMRPG_ChangeClientLaggedMovement");
	MarkNativeAsOptional("SMRPG_ResetClientLaggedMovement");
	MarkNativeAsOptional("SMRPG_IsClientLaggedMovementChanged");
}
#endif