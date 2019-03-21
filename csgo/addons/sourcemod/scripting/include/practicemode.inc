#if defined _practicemode_included
#endinput
#endif
#define _practicemode_included

// #include "pugsetup.inc"

#define OPTION_NAME_LENGTH 128  // max length of a setting name/id
#define CVAR_NAME_LENGTH 64     // max length of a cvar
#define CVAR_VALUE_LENGTH 128   // max length of a cvar value

/**
 * Called when practice mode is enabled.
 */
forward void PM_OnPracticeModeEnabled();

/**
 * Called when practice mode is disabled.
 */
forward void PM_OnPracticeModeDisabled();

/**
 * Called after practice mode reads its setting config file.
 */
forward void PM_OnSettingsRead();

/**
 * Called when a client saves a grenade position.
 *
 * @return Plugin_Handled or a higher action to block the save.
 */
forward Action PM_OnGrenadeSaved(int client, const float origin[3], const float angle[3],
                                 const char[] name);

/**
 * Called when a practice mode setting is changed.
 */
forward void PM_OnSettingChanged(int settingNumber, const char[] settingId,
                                 const char[] displayName, bool enabled);

/**
 * Starts practice mode, returning if it was started.
 */
native bool PM_StartPracticeMode();

/**
 * Exits practice mode, returning if it was exited.
 */
native bool PM_ExitPracticeMode();

/**
 * Adds a new setting to practice mode.
 * @note The practicemode plugin will take over ownership of the enabledCvars and enabledValues
 * arrays.
 * @return the settingNumber value for the new setting.
 */
native int PM_AddSetting(const char[] settingId, const char[] name, ArrayList enabledCvars,
                         ArrayList enabledValues, bool defaultEnabled = false,
                         bool changeable = true, ArrayList disabledCvars = null,
                         ArrayList disabeldValues = null);

/**
 * Returns if practice mode is enabled.
 */
native bool PM_IsPracticeModeEnabled();

/**
 * Returns if a practice mode setting is currently enabled.
 */
native bool PM_IsSettingEnabled(int settingNumber);

native void PM_Message(int client, const char[] format, any:...);

native void PM_MessageToAll(const char[] format, any:...);

native void PM_AddChatAlias(const char[] alias, const char[] command);

public SharedPlugin __pl_practicemode = {
    name = "practicemode", file = "practicemode.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_practicemode_SetNTVOptional() {
  MarkNativeAsOptional("PM_StartPracticeMode");
  MarkNativeAsOptional("PM_ExitPracticeMode");
  MarkNativeAsOptional("PM_AddSetting");
  MarkNativeAsOptional("PM_IsPracticeModeEnabled");
  MarkNativeAsOptional("PM_IsSettingEnabled");
  MarkNativeAsOptional("PM_Message");
  MarkNativeAsOptional("PM_MessageToAll");
  MarkNativeAsOptional("PM_AddChatAlias");
}
#endif
