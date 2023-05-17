#if defined _smrpg_settings_included
  #endinput
#endif
#define _smrpg_settings_included

#include <smrpg>

/**
 * Get the value of some setting from the settings table.
 *
 * @param sKey		The name of the setting.
 * @param sValue	The buffer to store the setting's value in.
 * @param maxlen	The maximum length of the buffer.
 * @return True if the setting existed and was retrieved, false otherwise.
 */
native bool SMRPG_GetSetting(const char[] sKey, char[] sValue, int maxlen);

/**
 * Set a setting variable in the smrpg "settings" table.
 *
 * @param sKey		The name of the setting.
 * @param sValue	The new value of the setting.
 */
native void SMRPG_SetSetting(const char[] sKey, char[] sValue);

/**
 * Called when the settings were loaded from the database.
 */
forward void SMRPG_OnSettingsLoaded();