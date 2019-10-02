#if defined _smlib_dynarray_included
	#endinput
#endif
#define _smlib_dynarray_included

#include <sourcemod>

/**
 * Retrieves a cell value from an array.
 * This is a wrapper around the Sourcemod Function GetArrayCell,
 * but it casts the result as bool
 *
 * @param array			Array Handle.
 * @param index			Index in the array.
 * @param block			Optionally specify which block to read from
 *						(useful if the blocksize > 0).
 * @param asChar		Optionally read as a byte instead of a cell.
 * @return				Value read.
 * @error				Invalid Handle, invalid index, or invalid block.
 */
stock bool:DynArray_GetBool(Handle:array, index, block=0, bool:asChar=false)
{
	return bool:GetArrayCell(array, index, block, asChar);
}
