#if defined _smlib_debug_included
	#endinput
#endif
#define _smlib_debug_included

#include <sourcemod>

/**
 * Prints the values of a static Float-Array to the server console.
 *
 * @param array		Static Float-Array.
 * @param size		Size of the Array.
 * @noreturn
 */
stock Debug_FloatArray(const Float:array[], size=3)
{
	new String:output[64] = "";

	for (new i=0; i < size; ++i) {
		
		if (i > 0 && i < size) {
			StrCat(output, sizeof(output), ", ");
			
		}

		Format(output, sizeof(output), "%s%f", output, array[i]);
	}

	PrintToServer("[DEBUG] Vector[%d] = { %s }", size, output);
}
