#if defined _hidenseek_included_
  #endinput
#endif
#define _hidenseek_included_

#define HNSMODE_NORMAL		0
#define HNSMODE_RESPAWN		1

/**
 * Check hidenseek plugin status.
 *
 * @return			If plugin enabled true, otherwise false.
 */
native bool HNS_IsEnabled();

/**
 * Get current hidenseek plugin mode.
 *
 * @return			Current mode.
 *
 * @note			See mode defines.
 */
native int HNS_GetMode();

/**
 * Called when CT freeze countdown ended.
 */
forward void HNS_OnCountdownEnd();

/**
 * Called when hidenseek category for adminmenu was added.
 */
forward void HNS_OnCategoryAdded(TopMenu topmenu, TopMenuObject obj);

public SharedPlugin __pl_hidenseek = 
{
	name = "hidenseek",
	file = "hidenseek.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_hidenseek_SetNTVOptional()
{
	MarkNativeAsOptional("HNS_IsEnabled");
	MarkNativeAsOptional("HNS_GetMode");
}
#endif