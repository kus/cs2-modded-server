#if defined _smlib_menus_included
	#endinput
#endif
#define _smlib_menus_included

#include <sourcemod>
#include <smlib/math>

/**
 * Adds an option to a menu with a String display but an integer
 * identifying the option.
 *
 * @param   menu        Handle to the menu
 * @param   value       Integer value for the option
 * @param   display     Display text for the menu
 * @noreturn
 */
stock Menu_AddIntItem(Handle:menu, any:value, String:display[])
{
	decl String:buffer[INT_MAX_DIGITS + 1];
	IntToString(value, buffer, sizeof(buffer));
	AddMenuItem(menu, buffer, display);
}

/**
 * Retrieves an integer-value choice from a menu, where the
 * menu's information strings were created as integers.
 *
 * @param   menu         Handle to the menu
 * @param   param2       The item position selected from the menu.
 * @return               Integer choice from the menu, or 0 if the integer could not be parsed.
 */
stock any:Menu_GetIntItem(Handle:menu, any:param2)
{
	decl String:buffer[INT_MAX_DIGITS + 1];
	GetMenuItem(menu, param2, buffer, sizeof(buffer));
	return StringToInt(buffer);
}
