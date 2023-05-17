#if defined _entityIO_included
 #endinput
#endif
#define _entityIO_included

enum EntityIO_VariantType
{
	EntityIO_VariantType_None,
	EntityIO_VariantType_Float,
	EntityIO_VariantType_String,
	EntityIO_VariantType_Vector,
	EntityIO_VariantType_Integer,
	EntityIO_VariantType_Boolean,
	EntityIO_VariantType_Character,
	EntityIO_VariantType_Color,
	EntityIO_VariantType_Entity,
	EntityIO_VariantType_PosVector
}

enum struct EntityIO_VariantInfo
{
	bool bValue;
	int iValue;
	float flValue;
	char sValue[256];
	int clrValue[4];
	float vecValue[3];
	EntityIO_VariantType variantType;
}

/**
 * Called when an entity receives an input.
 *
 * @param entity             Entity's index.
 * @param input              Input's name.
 * @param activator          Activator's index.
 * @param caller             Caller's index.
 * @param variantInfo        Parameter's type and value.
 * @param outputId           Output's ID.
 * @return                   Plugin_Handled or Plugin_Stop to block the input from being processed, Plugin_Continue otherwise.
 */
forward Action EntityIO_OnEntityInput(int entity, char input[256], int& activator, int& caller, EntityIO_VariantInfo variantInfo, int outputId);

/**
 * Called after an entity receives an input.
 *
 * @param entity           Entity's index.
 * @param input            Input's name.
 * @param activator        Activator's index.
 * @param caller           Caller's index.
 * @param param            Parameter's type and value.
 * @param outputId         Output's ID.
 */
forward void EntityIO_OnEntityInput_Post(int entity, const char[] input, int activator, int caller, EntityIO_VariantInfo variantInfo, int outputId);

/**
 * Returns whether or not an input can be accepted by an entity.
 *
 * @param entity        Entity's index.
 * @param input         Input's name.
 * @error               Invalid entity index.
 * @return              True if the input can be accepted, false otherwise.
 */
native bool EntityIO_HasEntityInput(int entity, const char[] input);

/**
 * Retrieves the first input from an entity.
 *
 * @param entity        Entity's index.
 * @error               Invalid entity index.
 * @return              On succes, a Handle is returned, which must be closed via CloseHandle(). On failure, INVALID_HANDLE is returned.
 */
native Handle EntityIO_FindEntityFirstInput(int entity);

/**
 * Retrieves the next input from an entity.
 *
 * @param iterator        Handle to search.
 * @error                 Invalid handle.
 * @return                True if an input was found, false otherwise.
 */
native bool EntityIO_FindEntityNextInput(Handle iterator);

/**
 * Retrieves an input's name from an entity.
 *
 * @param iterator        Handle to search.
 * @param input           Buffer to store the input's name.
 * @param maxLen          Maximum length of string buffer.
 * @error                 Invalid handle.
 * @return                Number of cells written.
 */
native int EntityIO_GetEntityInputName(Handle iterator, char[] input, int maxLen);

/**
 * Returns whether or not an output can be fired by an entity.
 *
 * @param entity        Entity's index.
 * @param output        Output's name.
 * @error               Invalid entity index.
 * @return              True if the output can be fired, false otherwise.
 */
native bool EntityIO_HasEntityOutput(int entity, const char[] output);

/**
 * Retrieves an output's offset.
 *
 * @param entity        Entity's index.
 * @param output        Output's name.
 * @error               Invalid entity index.
 * @return              Output's offset, -1 on failure.
 */
native int EntityIO_FindEntityOutputOffset(int entity, const char[] output);

/**
 * Retrieves the first output from an entity.
 *
 * @param entity        Entity's index.
 * @error               Invalid entity index.
 * @return              On succes, a Handle is returned, which must be closed via CloseHandle(). On failure, INVALID_HANDLE is returned.
 */
native Handle EntityIO_FindEntityFirstOutput(int entity);

/**
 * Retrieves the next output from an entity.
 *
 * @param iterator        Handle to search.
 * @error                 Invalid handle.
 * @return                True if an output was found, false otherwise.
 */
native bool EntityIO_FindEntityNextOutput(Handle iterator);

/**
 * Retrieves an output's name from an entity.
 *
 * @param iterator        Handle to search.
 * @param output          Buffer to store the output's name.
 * @param maxLen          Maximum length of string buffer.
 * @error                 Invalid handle.
 * @return                Number of cells written.
 */
native int EntityIO_GetEntityOutputName(Handle iterator, char[] output, int maxLen);

/**
 * Retrieves an output's offset from an entity.
 *
 * @param iterator        Handle to search.
 * @error                 Invalid handle.
 * @return                Output's offset, -1 on failure.
 */
native int EntityIO_GetEntityOutputOffset(Handle iterator);

/**
 * Adds an action to an entity's output.
 *
 * @param entity             Entity's index.
 * @param output             Output's name.
 * @param target             Action's target.
 * @param input              Action's input.
 * @param param              Action's parameter.
 * @param delay              Action's delay.
 * @param timesToFire        Action's times to fire, -1 for infinite times.
 * @return                   True if the action has been added, false otherwise.
 * @error                    Invalid entity index.
 */
native bool EntityIO_AddEntityOutputAction(int entity, const char[] output, const char[] target, const char[] input, const char[] param, float delay, int timesToFire);

/**
 * Retrieves the first action from an entity's output.
 *
 * @param entity        Entity's index.
 * @param offset        Output's offset.
 * @error               Invalid entity index, invalid output offset.
 * @return              On succes, a Handle is returned, which must be closed via CloseHandle(). On failure, INVALID_HANDLE is returned.
 */
native Handle EntityIO_FindEntityFirstOutputAction(int entity, int offset);

/**
 * Retrieves the next action from an entity's output.
 *
 * @param iterator        Handle to search.
 * @error                 Invalid handle.
 * @return                True if an action was found, false otherwise.
 */
native bool EntityIO_FindEntityNextOutputAction(Handle iterator);

/**
 * Retrieves an action's target from an entity's output.
 *
 * @param iterator        Handle to search.
 * @param target          Buffer to store the action's target.
 * @param maxLen          Maximum length of string buffer.
 * @error                 Invalid handle.
 * @return                Number of cells written.
 */
native int EntityIO_GetEntityOutputActionTarget(Handle iterator, char[] target, int maxLen);

/**
 * Retrieves an action's input from an entity's output.
 *
 * @param iterator        Handle to search.
 * @param input           Buffer to store the action's input.
 * @param maxLen          Maximum length of string buffer.
 * @error                 Invalid handle.
 * @return                Number of cells written.
 */
native int EntityIO_GetEntityOutputActionInput(Handle iterator, char[] input, int maxLen);

/**
 * Retrieves an action's parameter from an entity's output.
 *
 * @param iterator        Handle to search.
 * @param param           Buffer to store the action's parameter.
 * @param maxLen          Maximum length of string buffer.
 * @error                 Invalid handle.
 * @return                Number of cells written.
 */
native int EntityIO_GetEntityOutputActionParam(Handle iterator, char[] param, int maxLen);

/**
 * Retrieves an action's remaining times to fire from an entity's output.
 *
 * @param iterator        Handle to search.
 * @error                 Invalid handle.
 * @return                Action's remaining times to fire.
 */
native int EntityIO_GetEntityOutputActionTimesToFire(Handle iterator);

/**
 * Retrieves an action's ID from an entity's output.
 *
 * @param iterator        Handle to search.
 * @error                 Invalid handle.
 * @return                Action's ID.
 */
native int EntityIO_GetEntityOutputActionID(Handle iterator);

/**
 * Retrieves an action's delay from an entity's output.
 *
 * @param iterator        Handle to search.
 * @error                 Invalid handle.
 * @return                Action's delay.
 */
native float EntityIO_GetEntityOutputActionDelay(Handle iterator);

/* DO NOT EDIT BELOW THIS LINE */

public SharedPlugin __pl_entityIO = 
{
	name = "entityIO",
	file = "entityIO.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_entityIO_SetNTVOptional()
{
	MarkNativeAsOptional("EntityIO_HasEntityInput");
	MarkNativeAsOptional("EntityIO_FindEntityFirstInput");
	MarkNativeAsOptional("EntityIO_FindEntityNextInput");
	MarkNativeAsOptional("EntityIO_GetEntityInputName");
	
	MarkNativeAsOptional("EntityIO_HasEntityOutput");
	MarkNativeAsOptional("EntityIO_FindEntityOutputOffset");
	MarkNativeAsOptional("EntityIO_FindEntityFirstOutput");
	MarkNativeAsOptional("EntityIO_FindEntityNextOutput");
	MarkNativeAsOptional("EntityIO_GetEntityOutputName");
	MarkNativeAsOptional("EntityIO_GetEntityOutputOffset");
	
	MarkNativeAsOptional("EntityIO_AddEntityOutputAction");
	MarkNativeAsOptional("EntityIO_FindEntityFirstOutputAction");
	MarkNativeAsOptional("EntityIO_FindEntityNextOutputAction");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionTarget");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionInput");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionParams");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionDelay");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionTimesToFire");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionID");
}
#endif