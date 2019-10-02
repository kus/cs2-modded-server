#if defined _smlib_concommands_included
	#endinput
#endif
#define _smlib_concommands_included

#include <sourcemod>
#include <smlib/clients>

/**
 * Checks if a ConCommand has one or more flags set.
 *
 * @param    command        ConCommand name.
 * @param    flags        Flags to check.
 * @return                True if flags are set, false otherwise.
 */
stock bool:ConCommand_HasFlags(const String:command[], const flags)
{
    return bool:(GetCommandFlags(command) & flags);
}

/**
 * Adds one or more flags to a ConCommand.
 *
 * @param    command        ConCommand name.
 * @param    flags        Flags to add.
 * @noreturn
 */
stock ConCommand_AddFlags(const String:command[], const flags)
{
    new newFlags = GetCommandFlags(command);
    newFlags |= flags;
    SetCommandFlags(command, newFlags);
}

/**
 * Removes one ore more flags from a ConCommand.
 *
 * @param    command        ConCommand name.
 * @param    flags        Flags to remove
 * @noreturn
 */
stock ConCommand_RemoveFlags(const String:command[], const flags)
{
    new newFlags = GetCommandFlags(command);
    newFlags &= ~flags;
    SetCommandFlags(command, newFlags);
}
