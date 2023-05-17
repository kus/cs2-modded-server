/** Double-include prevention */
#if defined _togsclantags_included_
  #endinput
#endif
#define _togsclantags_included_

/**
 * Check if plugin is using mysql setups (else cfg file).
 * 
 * @return 1 if using mysql, 0 otherwise.
 */
native int TOGsClanTags_UsingMysql();

/**
 * Reloads clan tags plugin.
 * 
 * @return None.
 */
native void TOGsClanTags_Reload();

/**
 * Apply an extra chat tag to the client.
 *
 * @param	client			Client index
 * @param	sExtTag			String to use as tag text
 * 
 * @return true if tags applied successfully.
 * @error if invalid client (not in game or invalid index).
 */
native bool TOGsClanTags_SetExtTag(int client, char[] sExtTag);

/**
 * Notify clan tags plugin to reload.
 * 
 * @param	client			Client index
 *
 * @return true if client tags reloaded successfully.
 * @error if invalid client (not in game or invalid index).
 */
native bool TOGsClanTags_ReloadPlayer(int client);

/**
 * Check if client has a clan tag set through the plugin, either through the main function or by an external plugin using natives.
 * 
 * @param	client			Client index
 *
 * @return true if client has a tag set, false if no tag is set by plugin.
 * @error if invalid client (not in game or invalid index).
 */
native bool TOGsClanTags_HasAnyTag(int client);

/**
 * Check if client has a clan tag set through the main plugin functions.
 * 
 * @param	client			Client index
 *
 * @return true if client has a tag set, false if no tag is set by plugin.
 * @error if invalid client (not in game or invalid index).
 */
native bool TOGsClanTags_HasMainTag(int client);

/**
 * Check if client has a clan tag set through the plugin by an external plugin.
 * 
 * @param	client			Client index
 *
 * @return true if client has a tag set, false if no tag is set by plugin.
 * @error if invalid client (not in game or invalid index).
 */
native bool TOGsClanTags_HasExtTag(int client);

/* 
 * Called on plugin load / reload.
 * 
 * @return	None.
 */ 
//forward void TOGsClanTagsLoaded();

/* 
 * Called when a client finishes loading.
 * 
 * @return	None.
 */ 
//forward void TOGsClanTagsClientLoaded(int client);

public SharedPlugin __pl_togsclantags =
{
	name = "togsclantags",
	file = "togsclantags.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_togsclantags_SetNTVOptional()
{
	MarkNativeAsOptional("TOGsClanTags_SetExtTag");
	MarkNativeAsOptional("TOGsClanTags_Reload");
	MarkNativeAsOptional("TOGsClanTags_ReloadPlayer");
	MarkNativeAsOptional("TOGsClanTags_UsingMysql");
	MarkNativeAsOptional("TOGsClanTags_HasAnyTag");
	MarkNativeAsOptional("TOGsClanTags_HasMainTag");
	MarkNativeAsOptional("TOGsClanTags_HasExtTag");
}
#endif
