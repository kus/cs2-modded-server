#if defined _smlib_entities_included
	#endinput
#endif
#define _smlib_entities_included

#include <sourcemod>
#include <sdktools_entinput>
#include <sdktools_functions>

/**
 * Macro for iterating trough all children (entities it is parent of) of an entity.
 *
 * @param 1		Entity Index of the parent.
 * @param 2		Name of the children entity index variable (will be only valid in the loop).
 */
#define LOOP_CHILDREN(%1,%2) for (new %2=Entity_GetNextChild(%1); %2 != INVALID_ENT_REFERENCE; %2=Entity_GetNextChild(%1, ++%2))

/*
 * Checks if an entity is valid and exists.
 *
 * @param entity		Entity Index.
 * @return				True if the entity is valid, false otherwise.
 */
stock Entity_IsValid(entity)
{
	return IsValidEntity(entity);
}

/**
 * Finds an entity by its name.
 * You can optionally specify the classname to search for.
 * Note: If the classname is specified it uses The Sourcemod native
 * function FindEntityByClassname() which uses the engine's
 * linked entity list for finding entities. This might be
 * cheaper, use this if you call this function very often.
 *
 * @param name			Name of the entity you want so search.
 * @param className		Optional: Classname of the entity
 * @return				Entity index or INVALID_ENT_REFERENCE if not matching entity was found.
 */
stock Entity_FindByName(const String:name[], const String:className[]="")
{
	if (className[0] == '\0') {
		// Hack: Double the limit to gets none-networked entities too.
		new realMaxEntities = GetMaxEntities() * 2;
		for (new entity=0; entity < realMaxEntities; entity++) {
			
			if (!IsValidEntity(entity)) {
				continue;
			}
			
			if (Entity_NameMatches(entity, name)) {
				return entity;
			}
		}
	}
	else {
		new entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, className)) != INVALID_ENT_REFERENCE) {

			if (Entity_NameMatches(entity, name)) {
				return entity;
			}
		}
	}

	return INVALID_ENT_REFERENCE;
}

/**
 * Finds an entity by its HammerID.
 * The newer version of Valve's Hammer editor
 * sets a unique ID for each entity in a map.
 * It only finds the first occurence.
 * Note: If the classname is specified it uses The Sourcemod native
 * function FindEntityByClassname() which uses the engine's
 * linked entity list for finding entities. This might be
 * cheaper, use this if you call this function very often.
 *
 * @param hammerId		Hammer editor ID
 * @param className		Optional: Classname of the entity
 * @return				Edict Index or INVALID_ENT_REFERENCE if no entity was found.
 */
stock Entity_FindByHammerId(hammerId, const String:className[]="")
{
	if (className[0] == '\0') {
		// Hack: Double the limit to gets none-networked entities too.
		new realMaxEntities = GetMaxEntities() * 2;
		for (new entity=0; entity < realMaxEntities; entity++) {
			
			if (!IsValidEntity(entity)) {
				continue;
			}
			
			if (Entity_GetHammerId(entity) == hammerId) {
				return entity;
			}
		}
	}
	else {
		new entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, className)) != INVALID_ENT_REFERENCE) {
			
			if (Entity_GetHammerId(entity) == hammerId) {
				return entity;
			}
		}
	}

	return INVALID_ENT_REFERENCE;
}

/**
 * Searches for an entity by classname.
 * This is a wrapper around FindEntityByClassname
 * and has been added for completion.
 *
 * @param startEnt		The entity index after which to begin searching from. Use -1 to start from the first entity.
 * @param classname		Classname of the entity to find.
 * @return				Entity index >= 0 if found, -1 otherwise.
 */
 
stock Entity_FindByClassName(startEntity, const String:className[])
{
	return FindEntityByClassname(startEntity, className);
}

/**
 * Checks if an entity (partially) matches a specific entity class.
 *
 * @param entity		Entity Index.
 * @param className		Classname String.
 * @partialMatch		If to do a partial classname check.
 * @return				True if the classname matches, false otherwise.
 */
stock bool:Entity_ClassNameMatches(entity, const String:className[], partialMatch=false)
{
	decl String:entity_className[64];
	Entity_GetClassName(entity, entity_className, sizeof(entity_className));

	if (partialMatch) {
		return (StrContains(entity_className, className) != -1);
	}

	return StrEqual(entity_className, className);
}

/**
 * Checks if an entity matches a name
 *
 * @param entity		Entity Index.
 * @param class			Name String.
 * @return				True if the name matches, false otherwise.
 */
stock bool:Entity_NameMatches(entity, const String:name[])
{
	decl String:entity_name[128];
	Entity_GetName(entity, entity_name, sizeof(entity_name));

	return StrEqual(name, entity_name);
}

/**
 * Gets the Name of an entity.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock Entity_GetName(entity, String:buffer[], size)
{
	return GetEntPropString(entity, Prop_Data, "m_iName", buffer, size);
}

/**
 * Sets the Name of an entity.
 *
 * @param entity			Entity index.
 * @param name				The name you want to give.
 * @return					True on success, false otherwise.
 */
stock Entity_SetName(entity, const String:name[], any:...)
{
	decl String:format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "targetname", format);
}

/**
 * Gets the Classname of an entity.
 * This is like GetEdictClassname(), except it works for ALL
 * entities, not just edicts.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock Entity_GetClassName(entity, String:buffer[], size)
{
	return GetEntPropString(entity, Prop_Data, "m_iClassname", buffer, size);	
}

/**
 * Sets the Classname of an entity.
 *
 * @param entity			Entity index.
 * @param name				The name you want to give.
 * @return					True on success, false otherwise.
 */
stock Entity_SetClassName(entity, const String:className[])
{
	return DispatchKeyValue(entity, "classname", className);
}

/**
 * Gets the Target name of an other entity
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock Entity_GetTargetName(entity, String:buffer[], size)
{
	return GetEntPropString(entity, Prop_Data, "m_target", buffer, size);
}

/**
 * Sets the Target name of an other Entity
 *
 * @param entity			Entity index.
 * @param name				The target name you want to set
 * @return					True on success, false otherwise.
 */
stock Entity_SetTargetName(entity, const String:name[], any:...)
{
	decl String:format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "target", format);
}

/**
 * Gets the Global Name of an entity.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock Entity_GetGlobalName(entity, String:buffer[], size)
{
	return GetEntPropString(entity, Prop_Data, "m_iGlobalname", buffer, size);
}

/**
 * Sets the Global Name of an entity.
 *
 * @param entity			Entity index.
 * @param name				The global name you want to set.
 * @return					True on success, false otherwise.
 */
stock Entity_SetGlobalName(entity, const String:name[], any:...)
{
	decl String:format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "globalname", format);
}

/**
 * Gets the Parent name of an entity.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock Entity_GetParentName(entity, String:buffer[], size)
{
	return GetEntPropString(entity, Prop_Data, "m_iParent", buffer, size);
}

/**
 * Sets the Parent name of an entity.
 *
 * @param entity			Entity index.
 * @param name				The parent name you want to set.
 * @return					True on success, false otherwise.
 */
stock Entity_SetParentName(entity, const String:name[], any:...)
{
	decl String:format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "parentname", format);
}

/**
 * Gets the Hammer-ID of an entity.
 * The Hammer Editor gives every entity a unique ID.
 * Note: Old maps don't have Hammer-ID's set for entities
 *
 * @param entity			Entity index.
 * @return					Hammer ID.
 */
stock Entity_GetHammerId(entity)
{	
	return GetEntProp(entity, Prop_Data, "m_iHammerID");
}

/**
 * Gets the radius (m_flRadius) of an entity.
 *
 * @param entity			Entity index.
 * @return					Radius
 */
stock Float:Entity_GetRadius(entity)
{
	return GetEntPropFloat(entity, Prop_Data, "m_flRadius");
}

/**
 * Sets the radius (m_flRadius) of an entity.
 *
 * @param entity			Entity index.
 * @param radius			Radius value
 * @noreturn
 */
stock Entity_SetRadius(entity, Float:radius)
{
	SetEntPropFloat(entity, Prop_Data, "m_flRadius", radius);
}

/**
 * Gets the Mins of an entity.
 *
 * @param entity			Entity index.
 * @param vec				Vector.
 * @noreturn
 */
stock Entity_GetMinSize(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecMins", vec);	
}

/**
 * Sets the Mins of an entity.
 *
 * @param entity			Entity index.
 * @param vec				Vector.
 * @noreturn
 */
stock Entity_SetMinSize(entity, const Float:vecMins[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecMins);
}

/**
 * Gets the Mins of an entity.
 * This functions isn't safe to use, use Entity_SetMinMaxSize() instead.
 *
 * @param entity			Entity index
 * @param vec				return vector.
 * @noreturn
 */
stock Entity_GetMaxSize(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vec);
}

/**
 * Sets the Maxs of an entity.
 * This functions isn't safe to use, use Entity_SetMinMaxSize() instead.
 *
 * @param entity			Entity index.
 * @param vec				Vector.
 * @noreturn
 */
stock Entity_SetMaxSize(entity, const Float:vecMaxs[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxs);
}

/**
 * Sets the Min and Max Size of an entity.
 * Code is taken from HL2SDK and rewritten for Sourcemod.
 *
 * @param entity			Entity index.
 * @param vecMins			Min size Vector
 * @param vecMaxs			Max size Vector
 * @noreturn
 */
stock Entity_SetMinMaxSize(entity, Float:vecMins[3], Float:vecMaxs[3])
{
	// Taken from hl2sdk-ob-valve\game\server\util.cpp SetMinMaxSize()
	// Todo: Replace this by a SDK call
	for (new i=0; i<3; i++) {

		if (vecMins[i] > vecMaxs[i]) {
			ThrowError("Error: mins[%d] > maxs[%d] of entity %d", i, i, EntRefToEntIndex(entity));
		}
	}
	
	decl Float:m_vecMins[3], Float:m_vecMaxs[3];
	Entity_GetMinSize(entity, m_vecMins);
	Entity_GetMaxSize(entity, m_vecMaxs);

	if (Math_VectorsEqual(m_vecMins, vecMins) && Math_VectorsEqual(m_vecMaxs, vecMaxs)) {
		return;
	}

	Entity_SetMinSize(entity, vecMins);
	Entity_SetMaxSize(entity, vecMaxs);
	
	decl Float:vecSize[3];
	SubtractVectors(vecMaxs, vecMins, vecSize);
	Entity_SetRadius(entity, GetVectorLength(vecSize) * 0.5);

	Entity_MarkSurrBoundsDirty(entity);
}

/*
 * Spawn Flags
 * Many entities define their specific spawnflags, check the HL2SDK.
 */

/*
 * Phys prop spawnflags
 * Taken from hl2sdk-ob-valve\game\shared\props_shared.h
 */
#define SF_PHYSPROP_START_ASLEEP				0x000001
#define SF_PHYSPROP_DONT_TAKE_PHYSICS_DAMAGE	0x000002		// this prop can't be damaged by physics collisions
#define SF_PHYSPROP_DEBRIS						0x000004
#define SF_PHYSPROP_MOTIONDISABLED				0x000008		// motion disabled at startup (flag only valid in spawn - motion can be enabled via input)
#define	SF_PHYSPROP_TOUCH						0x000010		// can be 'crashed through' by running player (plate glass)
#define SF_PHYSPROP_PRESSURE					0x000020		// can be broken by a player standing on it
#define SF_PHYSPROP_ENABLE_ON_PHYSCANNON		0x000040		// enable motion only if the player grabs it with the physcannon
#define SF_PHYSPROP_NO_ROTORWASH_PUSH			0x000080		// The rotorwash doesn't push these
#define SF_PHYSPROP_ENABLE_PICKUP_OUTPUT		0x000100		// If set, allow the player to +USE this for the purposes of generating an output
#define SF_PHYSPROP_PREVENT_PICKUP				0x000200		// If set, prevent +USE/Physcannon pickup of this prop
#define SF_PHYSPROP_PREVENT_PLAYER_TOUCH_ENABLE	0x000400		// If set, the player will not cause the object to enable its motion when bumped into
#define SF_PHYSPROP_HAS_ATTACHED_RAGDOLLS		0x000800		// Need to remove attached ragdolls on enable motion/etc
#define SF_PHYSPROP_FORCE_TOUCH_TRIGGERS		0x001000		// Override normal debris behavior and respond to triggers anyway
#define SF_PHYSPROP_FORCE_SERVER_SIDE			0x002000		// Force multiplayer physics object to be serverside
#define SF_PHYSPROP_RADIUS_PICKUP				0x004000		// For Xbox, makes small objects easier to pick up by allowing them to be found 
#define SF_PHYSPROP_ALWAYS_PICK_UP				0x100000		// Physcannon can always pick this up, no matter what mass or constraints may apply.
#define SF_PHYSPROP_NO_COLLISIONS				0x200000		// Don't enable collisions on spawn
#define SF_PHYSPROP_IS_GIB						0x400000		// Limit # of active gibs

/*
 * Physbox Spawnflags. Start at 0x01000 to avoid collision with CBreakable's
 * Taken from hl2sdk-ob-valve\game\server\physobj.h
 */
#define SF_PHYSBOX_ASLEEP						0x01000
#define SF_PHYSBOX_IGNOREUSE					0x02000
#define SF_PHYSBOX_DEBRIS						0x04000
#define SF_PHYSBOX_MOTIONDISABLED				0x08000
#define SF_PHYSBOX_USEPREFERRED					0x10000
#define SF_PHYSBOX_ENABLE_ON_PHYSCANNON			0x20000
#define SF_PHYSBOX_NO_ROTORWASH_PUSH			0x40000			// The rotorwash doesn't push these
#define SF_PHYSBOX_ENABLE_PICKUP_OUTPUT			0x80000
#define SF_PHYSBOX_ALWAYS_PICK_UP		  		0x100000		// Physcannon can always pick this up, no matter what mass or constraints may apply.
#define SF_PHYSBOX_NEVER_PICK_UP				0x200000		// Physcannon will never be able to pick this up.
#define SF_PHYSBOX_NEVER_PUNT					0x400000		// Physcannon will never be able to punt this object.
#define SF_PHYSBOX_PREVENT_PLAYER_TOUCH_ENABLE	0x800000		// If set, the player will not cause the object to enable its motion when bumped into

/*
 * Spawnflags for func breakable
 * Taken from hl2sdk-ob-valve\game\server\func_break.h
 */
#define SF_BREAK_TRIGGER_ONLY				0x0001	// may only be broken by trigger
#define	SF_BREAK_TOUCH						0x0002	// can be 'crashed through' by running player (plate glass)
#define SF_BREAK_PRESSURE					0x0004	// can be broken by a player standing on it
#define SF_BREAK_PHYSICS_BREAK_IMMEDIATELY	0x0200	// the first physics collision this breakable has will immediately break it
#define SF_BREAK_DONT_TAKE_PHYSICS_DAMAGE	0x0400	// this breakable doesn't take damage from physics collisions
#define SF_BREAK_NO_BULLET_PENETRATION		0x0800  // don't allow bullets to penetrate

/*
 * Spawnflags for func_pushable (it's also func_breakable, so don't collide with those flags)
 * Taken from hl2sdk-ob-valve\game\server\func_break.h
 */
#define SF_PUSH_BREAKABLE					0x0080
#define SF_PUSH_NO_USE						0x0100	// player cannot +use pickup this ent

/**
 * Gets the Spawnflags of an entity.
 *
 * @param entity			Entity index.
 * @return					Spawnflags value
 */
stock Entity_GetSpawnFlags(entity)
{
	return GetEntProp(entity, Prop_Data, "m_spawnflags");
}

/**
 * Sets the Spawnflags of an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @noreturn
 */
stock Entity_SetSpawnFlags(entity, flags)
{
	SetEntProp(entity, Prop_Data, "m_spawnflags", flags);
}

/**
 * Adds Spawnflags to an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @noreturn
 */
stock Entity_AddSpawnFlags(entity, flags)
{
	new spawnFlags = Entity_GetSpawnFlags(entity);
	spawnFlags |= flags;
	Entity_SetSpawnFlags(entity, spawnFlags);
}

/**
 * Removes Spawnflags from an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @noreturn
 */
stock Entity_RemoveSpawnFlags(entity, flags)
{
	new spawnFlags = Entity_GetSpawnFlags(entity);
	spawnFlags &= ~flags;
	Entity_SetSpawnFlags(entity, spawnFlags);
}

/**
 * Clears all Spawnflags of an entity.
 *
 * @param entity			Entity index.
 * @noreturn
 */
stock Entity_ClearSpawnFlags(entity)
{
	Entity_SetSpawnFlags(entity, 0);
}

/**
 * Returns whether the entity has specific Spawnflags.
 *
 * @param entity			Entity index.
 * @param flags				Flags value.
 * @return					True if the entity has the spawnflags set, false otherwise.
 */
stock bool:Entity_HasSpawnFlags(entity, flags)
{	
	return bool:(Entity_GetSpawnFlags(entity) & flags);
}

/*
 * Entity flags, CBaseEntity::m_iEFlags
 * Taken from: hl2sdk-ob-valve\game\shared\shareddefs.h
 */
enum Entity_Flags
{
	EFL_KILLME =							(1<<0),	// This entity is marked for death -- This allows the game to actually delete ents at a safe time
	EFL_DORMANT	=							(1<<1),	// Entity is dormant, no updates to client
	EFL_NOCLIP_ACTIVE =						(1<<2),	// Lets us know when the noclip command is active.
	EFL_SETTING_UP_BONES =					(1<<3),	// Set while a model is setting up its bones.
	EFL_KEEP_ON_RECREATE_ENTITIES = 		(1<<4), // This is a special entity that should not be deleted when we restart entities only

	EFL_HAS_PLAYER_CHILD=					(1<<4),	// One of the child entities is a player.

	EFL_DIRTY_SHADOWUPDATE =				(1<<5),	// Client only- need shadow manager to update the shadow...
	EFL_NOTIFY =							(1<<6),	// Another entity is watching events on this entity (used by teleport)

	// The default behavior in ShouldTransmit is to not send an entity if it doesn't
	// have a model. Certain entities want to be sent anyway because all the drawing logic
	// is in the client DLL. They can set this flag and the engine will transmit them even
	// if they don't have a model.
	EFL_FORCE_CHECK_TRANSMIT =				(1<<7),

	EFL_BOT_FROZEN =						(1<<8),	 // This is set on bots that are frozen.
	EFL_SERVER_ONLY =						(1<<9),	 // Non-networked entity.
	EFL_NO_AUTO_EDICT_ATTACH =				(1<<10), // Don't attach the edict; we're doing it explicitly
	
	// Some dirty bits with respect to abs computations
	EFL_DIRTY_ABSTRANSFORM =				(1<<11),
	EFL_DIRTY_ABSVELOCITY =					(1<<12),
	EFL_DIRTY_ABSANGVELOCITY =				(1<<13),
	EFL_DIRTY_SURR_COLLISION_BOUNDS =		(1<<14),
	EFL_DIRTY_SPATIAL_PARTITION = 			(1<<15),
//	UNUSED						=			(1<<16),

	EFL_IN_SKYBOX =							(1<<17), // This is set if the entity detects that it's in the skybox.
													 // This forces it to pass the "in PVS" for transmission.
	EFL_USE_PARTITION_WHEN_NOT_SOL = 		(1<<18), // Entities with this flag set show up in the partition even when not solid
	EFL_TOUCHING_FLUID =					(1<<19), // Used to determine if an entity is floating

	// FIXME: Not really sure where I should add this...
	EFL_IS_BEING_LIFTED_BY_BARNACLE =		(1<<20),
	EFL_NO_ROTORWASH_PUSH =					(1<<21), // I shouldn't be pushed by the rotorwash
	EFL_NO_THINK_FUNCTION =					(1<<22),
	EFL_NO_GAME_PHYSICS_SIMULATION =		(1<<23),

	EFL_CHECK_UNTOUCH =						(1<<24),
	EFL_DONTBLOCKLOS =						(1<<25), // I shouldn't block NPC line-of-sight
	EFL_DONTWALKON =						(1<<26), // NPC;s should not walk on this entity
	EFL_NO_DISSOLVE =						(1<<27), // These guys shouldn't dissolve
	EFL_NO_MEGAPHYSCANNON_RAGDOLL =			(1<<28), // Mega physcannon can't ragdoll these guys.
	EFL_NO_WATER_VELOCITY_CHANGE =			(1<<29), // Don't adjust this entity's velocity when transitioning into water
	EFL_NO_PHYSCANNON_INTERACTION =			(1<<30), // Physcannon can't pick these up or punt them
	EFL_NO_DAMAGE_FORCES =					(1<<31), // Doesn't accept forces from physics damage
};

/**
 * Gets the Entity flags (m_iEFlags) of an entity.
 *
 * @param entity			Entity index.
 * @return					Entity flags value
 */
stock Entity_Flags:Entity_GetEFlags(entity)
{
	return Entity_Flags:GetEntProp(entity, Prop_Data, "m_iEFlags");
}

/**
 * Sets the entity's Entity flags (m_iEFlags).
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @noreturn
 */
stock Entity_SetEFlags(entity, Entity_Flags:flags)
{
	SetEntProp(entity, Prop_Data, "m_iEFlags", flags);
}

/**
 * Adds Entity flags (m_iEFlags) to an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @noreturn
 */
stock Entity_AddEFlags(entity, Entity_Flags:flags)
{
	new Entity_Flags:setFlags = Entity_GetEFlags(entity);
	setFlags |= flags;
	Entity_SetEFlags(entity, setFlags);
}

/**
 * Removes Entity flags (m_iEFlags) from an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @noreturn
 */
stock Entity_RemoveEFlags(entity, Entity_Flags:flags)
{
	new Entity_Flags:setFlags = Entity_GetEFlags(entity);
	setFlags &= ~flags;
	Entity_SetEFlags(entity, setFlags);
}

/**
 * Checks if the entity has specific Entity flags (m_iEFlags) set.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @return					True if the flags are set, false otherwise.
 */
stock bool:Entity_HasEFlags(entity, Entity_Flags:flags)
{
	new Entity_Flags:currentEFlags = Entity_GetEFlags(entity);
	
	return bool:(currentEFlags & flags);
}

/**
 * Marks the surrounding bounds of an entity as outdated.
 * You normally call this when a collision setting has changed.
 *
 * @param entity			Entity index.
 * @noreturn
 */
stock Entity_MarkSurrBoundsDirty(entity)
{
	Entity_AddEFlags(entity, EFL_DIRTY_SURR_COLLISION_BOUNDS);
}

/*
 * CBaseEntity::m_fFlags Functions
 * Use the FL_ Defines (FL_ONGROUND, ...) or
 * special entity specific flags.
 * Note: The flag FL_AIMTARGET probably doesn't work as
 * we have current no way of adding/removing it to the AimTarget List.
 */

/**
 * Gets the Flags of an entity.
 *
 * @param entity			Entity Index.
 * @return					Entity Flags.
 */
stock Entity_GetFlags(entity)
{
	return GetEntProp(entity, Prop_Data, "m_fFlags");
}

/**
 * Sets the Flags of an entity.
 *
 * @param entity			Entity index.
 * @param flags				New Flags value
 * @noreturn
 */
stock Entity_SetFlags(entity, flags)
{
	SetEntProp(entity, Prop_Data, "m_fFlags", flags);
}

/**
 * Adds Flags to the entity
 *
 * @param entity			Entity index.
 * @param flags				Flags to add
 * @noreturn
 */
stock Entity_AddFlags(entity, flags)
{
	new setFlags = Entity_GetFlags(entity);
	setFlags |= flags;
	Entity_SetFlags(entity, flags);
}

/**
 * Removes flags from the entity
 *
 * @param entity			Entity index.
 * @param flags				Flags to remove
 * @noreturn
 */
stock Entity_RemoveFlags(entity, flags)
{
	new setFlags = Entity_GetFlags(entity);
	setFlags &= ~flags;
	Entity_SetFlags(entity, setFlags);
}

/**
 * Toggles the specified flag on the entity.
 * Adds the flag to the entity if it doesn't exists
 * or removes it otherwise.
 *
 * @param entity			Entity index.
 * @param flags				Flag to Toggle
 * @noreturn
 */
stock Entity_ToggleFlag(entity, flag)
{
	new setFlag = Entity_GetFlags(entity);
	setFlag ^= flag;
	Entity_SetFlags(entity, setFlag);
}

/**
 * Removes all flags from the entity
 *
 * @param entity			Entity index.
 * @noreturn
 */
stock Entity_ClearFlags(entity)
{
	Entity_SetFlags(entity, 0);
}

/* edict->solid values
 * NOTE: Some movetypes will cause collisions independent of SOLID_NOT/SOLID_TRIGGER when the entity moves
 * SOLID only effects OTHER entities colliding with this one when they move - UGH!
 *
 * Solid type basically describes how the bounding volume of the object is represented
 * NOTE: These numerical values are used in the FGD by the prop code (see prop_dynamic)
 * Taken from: hl2sdk-ob-valve\public\const.h
 */
 
enum SolidFlags_t
{
	FSOLID_CUSTOMRAYTEST		= 0x0001,	// Ignore solid type + always call into the entity for ray tests
	FSOLID_CUSTOMBOXTEST		= 0x0002,	// Ignore solid type + always call into the entity for swept box tests
	FSOLID_NOT_SOLID			= 0x0004,	// Are we currently not solid?
	FSOLID_TRIGGER				= 0x0008,	// This is something may be collideable but fires touch functions
											// even when it's not collideable (when the FSOLID_NOT_SOLID flag is set)
	FSOLID_NOT_STANDABLE		= 0x0010,	// You can't stand on this
	FSOLID_VOLUME_CONTENTS		= 0x0020,	// Contains volumetric contents (like water)
	FSOLID_FORCE_WORLD_ALIGNED	= 0x0040,	// Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
	FSOLID_USE_TRIGGER_BOUNDS	= 0x0080,	// Uses a special trigger bounds separate from the normal OBB
	FSOLID_ROOT_PARENT_ALIGNED	= 0x0100,	// Collisions are defined in root parent's local coordinate space
	FSOLID_TRIGGER_TOUCH_DEBRIS	= 0x0200,	// This trigger will touch debris objects

	FSOLID_MAX_BITS	= 10
};

/**
 * Gets the solid flags of the entity
 *
 * @param entity			Entity index.
 * @return					Solid Flags.
 */
stock SolidFlags_t:Entity_GetSolidFlags(entity)
{
	return SolidFlags_t:GetEntProp(entity, Prop_Data, "m_usSolidFlags", 2);
}

/**
 * Sets the solid flags of the entity
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 * @noreturn
 */
stock Entity_SetSolidFlags(entity, SolidFlags_t:flags)
{	
	new SolidFlags_t:oldFlags = Entity_GetSolidFlags(entity);
	flags = flags & SolidFlags_t:0xFFFF;

	if (oldFlags == flags) {
		return;
	}
	
	SetEntProp(entity, Prop_Data, "m_usSolidFlags", flags, 2);

	// These two flags, if changed, can produce different surrounding bounds
	if ((oldFlags & (FSOLID_FORCE_WORLD_ALIGNED | FSOLID_USE_TRIGGER_BOUNDS)) !=
			(flags & (FSOLID_FORCE_WORLD_ALIGNED | FSOLID_USE_TRIGGER_BOUNDS)))
	{
		Entity_MarkSurrBoundsDirty(entity);
	}
}

/**
 * Adds solid flags to the entity
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 * @noreturn
 */
stock Entity_AddSolidFlags(entity, SolidFlags_t:flags)
{
	new SolidFlags_t:newFlags = Entity_GetSolidFlags(entity);
	newFlags |= flags;
	Entity_SetSolidFlags(entity, newFlags);
}

/**
 * Removes solid flags from the entity.
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 * @noreturn
 */
stock Entity_RemoveSolidFlags(entity, SolidFlags_t:flags)
{
	new SolidFlags_t:newFlags = Entity_GetSolidFlags(entity);
	newFlags &= ~flags;
	Entity_SetSolidFlags(entity, newFlags);
}

/**
 * Removes all solid flags from the entity.
 *
 * @param entity			Entity index.
 * @noreturn
 */
stock Entity_ClearSolidFlags(entity)
{
	Entity_SetSolidFlags(entity, SolidFlags_t:0);
}

/**
 * Checks whether certain solid flags are set on the entity.
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 * @return					True if the specified flags are set, false otherwise.
 */
stock bool:Entity_SolidFlagsSet(entity, SolidFlags_t:flagMask)
{
	return bool:(Entity_GetSolidFlags(entity) & flagMask);
}

enum SolidType_t
{
	SOLID_NONE			= 0,	// no solid model
	SOLID_BSP			= 1,	// a BSP tree
	SOLID_BBOX			= 2,	// an AABB
	SOLID_OBB			= 3,	// an OBB (not implemented yet)
	SOLID_OBB_YAW		= 4,	// an OBB, constrained so that it can only yaw
	SOLID_CUSTOM		= 5,	// Always call into the entity for tests
	SOLID_VPHYSICS		= 6,	// solid vphysics object, get vcollide from the model and collide with that
	SOLID_LAST,
};

/**
 * Gets the solidity type of the entity
 *
 * @param entity			Entity index.
 * @return					Solid Type
 */
stock SolidType_t:Entity_GetSolidType(entity)
{
	return SolidType_t:GetEntProp(entity, Prop_Data, "m_nSolidType", 1);
}

/**
 * Sets the solidity type of the entity
 *
 * @param entity			Entity index.
 * @param					Solid Type value.
 * @noreturn
 */
stock Entity_SetSolidType(entity, SolidType_t:value)
{
	SetEntProp(entity, Prop_Send, "m_nSolidType", value, 1);
	Entity_MarkSurrBoundsDirty(entity);
}

/**
 * Checks whether the entity is solid or not.
 *
 * @param entity			Entity index.
 * @return					True if the entity is solid, false otherwise.
 */
stock bool:Entity_IsSolid(entity)
{
	return (Entity_GetSolidType(entity) != SOLID_NONE &&
			!Entity_SolidFlagsSet(entity, FSOLID_NOT_SOLID));
}

/**
 * Retrieves the model path of a given entity.
 * Returns "*num" for Brush entities.
 *
 * @param entity		entity reference or index
 * @param model			buffer String for the model
 * @param size			max size of buffer string
 * @return				Number of non-null bytes written.
 */
stock Entity_GetModel(entity, String:buffer[], size)
{	
	return GetEntPropString(entity, Prop_Data, "m_ModelName", buffer, size);
}

/**
 * Sets the model to a given entity.
 * Be sure it has been precached.
 * This is an alias for SetEntityModel()
 *
 * @param entity		Entity index
 * @param model			Model name
 * @noreturn				
 */
stock Entity_SetModel(entity, const String:model[])
{
	SetEntityModel(entity, model);
}

/**
 * Gets the entity's model index, if it has one set.
 *
 * @param entity			Entity index.
 * @return					The Entity's model index
 */
stock Entity_GetModelIndex(entity)
{
	return GetEntProp(entity, Prop_Data, "m_nModelIndex", 2);
}

/**
 * Sets the entity's model index (must be precached)
 *
 * @param entity			Entity index.
 * @param index				Model Index.
 * @noreturn
 */
stock Entity_SetModelIndex(entity, index)
{
	SetEntProp(entity, Prop_Data, "m_nModelIndex", index, 2);
}

/**
* Sets the entity's maxspeed to the given value (in units per second)
*
* @param entity		Entity index
* @param maxspeed	the maximum speed the entity can move
* @noreturn
*/
stock Entity_SetMaxSpeed(entity, Float:value)
{
	SetEntPropFloat(entity, Prop_Data, "m_flMaxspeed", value);
}

/*
 * Collision groups
 * Taken from hl2sdk-ob-valve/public/const.h
 */
enum Collision_Group_t
{
	COLLISION_GROUP_NONE  = 0,
	COLLISION_GROUP_DEBRIS,				// Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER,		// Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEB,	// Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,		// Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,	// For HL2, same as Collision_Group_Player, for
										// TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,				// Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,			// for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,				// for any weapons that need collision detection
	COLLISION_GROUP_VEHICLE_CLIP,		// vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,			// Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,		// Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,		// Doors that the player shouldn't collide with
	COLLISION_GROUP_DISSOLVING,			// Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,			// Nonsolid on client and server, pushaway in player code

	COLLISION_GROUP_NPC_ACTOR,			// Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED		// USed for NPCs in scripts that should not collide with each other
};

/**
 * Gets the collision group of an entity.
 *
 * @param entity		entity index
 * @return				Entity collision group.
 */
stock Collision_Group_t:Entity_GetCollisionGroup(entity)
{
	return Collision_Group_t:GetEntProp(entity, Prop_Data, "m_CollisionGroup");
}

/**
 * Sets the collision group of an entity.
 *
 * @param entity		entity index
 * @param value			the new collision group.
 * @noreturn
 */
stock Entity_SetCollisionGroup(entity, Collision_Group_t:value)
{
	SetEntProp(entity, Prop_Data, "m_CollisionGroup", value);
}

/**
 * Functions for getting / setting the origin (position) of an entity.
 * Go to http://developer.valvesoftware.com/wiki/Origin
 * if you want to learn more about origins
 */

/**
 * Gets the Absolute Origin (position) of an entity.
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 * @noreturn
 */
stock Entity_GetAbsOrigin(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec);
}

/**
 * Sets the Absolute Origin (position) of an entity.
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 * @noreturn
 */
stock Entity_SetAbsOrigin(entity, const Float:vec[3])
{
	// We use TeleportEntity to set the origin more safely
	// Todo: Replace this with a call to UTIL_SetOrigin() or CBaseEntity::SetLocalOrigin()
	TeleportEntity(entity, vec, NULL_VECTOR, NULL_VECTOR);
}

/**
 * Functions for getting / setting the angles (rotation) of an entity.
 * http://developer.valvesoftware.com/wiki/Angles
 * if you want to learn more about angles
 */

/**
 * Gets the Angles of an entity
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 * @noreturn
 */ 
stock Entity_GetAbsAngles(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", vec);
}

/**
 * Sets the Angles of an entity
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 * @noreturn
 */ 
stock Entity_SetAbsAngles(entity, const Float:vec[3])
{
	// We use TeleportEntity to set the angles more safely
	// Todo: Replace this with a call to CBaseEntity::SetLocalAngles()
	TeleportEntity(entity, NULL_VECTOR, vec, NULL_VECTOR);
}

/**
 * Functions for getting / setting the velocity of an entity.
 * Go to http://developer.valvesoftware.com/wiki/Velocity
 * if you want to learn more about the different kind of velocities.
 */

/**
 * Gets the Local velocity of an entity.
 * The local velocity is the velocity generated by the entity.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 * @noreturn
 */
stock Entity_GetLocalVelocity(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vec);
}

/**
 * Sets the Local velocity of an entity.
 * The local velocity is the velocity generated by the entity.
 * Only use this if you know what you are doing,
 * the entity can overwrite this value on next frame.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 * @noreturn
 */
stock Entity_SetLocalVelocity(entity, const Float:vec[3])
{
	SetEntPropVector(entity, Prop_Data, "m_vecVelocity", vec);
}

/**
 * Gets the Base velocity of an entity.
 * The base velocity is the velocity applied
 * to the entity from other sources .
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 * @noreturn
 */
stock Entity_GetBaseVelocity(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecBaseVelocity", vec);
}

/**
 * Sets the Base velocity of an entity.
 * The base velocity is the velocity applied
 * to the entity from other sources .
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 * @noreturn
 */
stock Entity_SetBaseVelocity(entity, const Float:vec[3])
{
	SetEntPropVector(entity, Prop_Data, "m_vecBaseVelocity", vec);
}

/**
 * Gets the Absolute velocity of an entity.
 * The absolute velocity is the sum of the local
 * and base velocities. It's the actual value used to move.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 * @noreturn
 */
stock Entity_GetAbsVelocity(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vec);
}

/**
 * Sets the Absolute velocity of an entity.
 * The absolute velocity is the sum of the local
 * and base velocities. It's the actual value used to move.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 * @noreturn
 */
stock Entity_SetAbsVelocity(entity, const Float:vec[3])
{
	// We use TeleportEntity to set the velocity more safely
	// Todo: Replace this with a call to CBaseEntity::SetAbsVelocity()
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vec);
}

/**
 * Returns true if the entity is locked.
 *
 * @param entity		Entity index.
 * @return				True if locked otherwise false.
 */
stock bool:Entity_IsLocked(entity)
{
	return bool:GetEntProp(entity, Prop_Data, "m_bLocked", 1);
}

/**
 * Locks an entity.
 *
 * @param entity		Entity index.
 * @noreturn
 */
stock Entity_Lock(entity)
{
	SetEntProp(entity, Prop_Data, "m_bLocked", 1, 1);
}
/**
 * Unlocks an entity.
 *
 * @param entity		Entity index.
 * @noreturn
 */
stock Entity_UnLock(entity)
{
	SetEntProp(entity, Prop_Data, "m_bLocked", 0, 1);
}

/**
 * Gets the health of an entity.
 *
 * @param entity			entity index.
 * @return				current health points
 */
stock Entity_GetHealth(entity)
{	
	return GetEntProp(entity, Prop_Data, "m_iHealth");
}

/**
 * Sets the health of an entity.
 *
 * @param entity			entity index.
 * @param value			health to set (anything above 511 will overload)
 * @noreturn
 */
stock Entity_SetHealth(entity, value, ignoreMax=false, kill=true)
{
	new health = value;
	
	if (!ignoreMax) {
		new maxHealth = Entity_GetMaxHealth(entity);
		
		if (health > maxHealth) {
			health = maxHealth;
		}
	}

	if (health < 0) {
		health = 0;
	}
	
	SetEntProp(entity, Prop_Data, "m_iHealth", health);

	if (health <= 0) {
		Entity_Kill(entity);
	}
	
	return health;
}

/**
 * Add health to an entity
 *
 * @param entity		entity index
 * @param value			health to add
 * @return				returns the new health value set
 */
stock Entity_AddHealth(entity, value, ignoreMax=false, kill=true)
{
	new health = Entity_GetHealth(entity);
	
	health += value;

	return Entity_SetHealth(entity, health, ignoreMax, kill);
}

/**
 * Takes health from an entity
 *
 * @param entity		entity index
 * @param value			health to add
 * @return				returns the new health value set
 */
stock Entity_TakeHealth(entity, value, ignoreMax=false, kill=true)
{
	new health = Entity_GetHealth(entity);
	
	health -= value;
	
	return Entity_SetHealth(entity, health, ignoreMax, kill);
}

/**
 * Get the max health of an entity
 *
 * @param entity		Entity Index
 * @return				Max health points
 */
stock Entity_GetMaxHealth(entity)
{	
	return GetEntProp(entity, Prop_Data, "m_iMaxHealth");
}


/**
 * Set the max health of an entity.
 *
 * @param entity		Entity index
 * @param value			Max health to set (anything above 511 will overload)
 * @noreturn
 */
stock Entity_SetMaxHealth(entity, value)
{	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", value);
	return value;
}

/**
 * Returns the Float distance between an entity
 * and a vector origin.
 *
 * @param entity		Entity Index.
 * @param target		Vector Origin.
 * @return				Distance Float value.
 */
stock Float:Entity_GetDistanceOrigin(entity, const Float:vec[3])
{
	new Float:entityVec[3];
	Entity_GetAbsOrigin(entity, entityVec);
	
	return GetVectorDistance(entityVec, vec);
}

/**
 * Returns the Float distance between two entities.
 * Both entities must be valid.
 *
 * @param entity		Entity Index.
 * @param target		Target Entity Index.
 * @return				Distance Float value.
 */
stock Float:Entity_GetDistance(entity, target)
{
	new Float:targetVec[3];
	Entity_GetAbsOrigin(target, targetVec);
	
	return Entity_GetDistanceOrigin(entity, targetVec);
}

/**
 * Checks if the given 2 entitys are within a given range.
 *
 * @param entity		Entity Index.
 * @param target		Target Entity Index.
 * @param distance		Max Float distance.
 * @return				True if the given entities are closer than the given distance value, false otherwise.
 */
stock bool:Entity_InRange(entity, target, Float:distance)
{
	if (Entity_GetDistance(entity, target) > distance) {
		return false;
	}
	
	return true;
}

/**
 * Enables the motion of an entity.
 *
 * @param entity		Entity index.
 * @return				True on success, false otherwise
 */
stock bool:Entity_EnableMotion(entity)
{	
	return AcceptEntityInput(entity, "enablemotion");
}

/**
 * Disables the motion of an entity.
 *
 * @param entity		Entity index.
 * @return 				True on success, false otherwise
 */
stock bool:Entity_DisableMotion(entity)
{
	return AcceptEntityInput(entity, "disablemotion");
}

/**
 * Freezes an entity by setting the FL_FROZEN flag.
 *
 * @param entity		Entity index.
 * @return				True on success, false otherwise
 */
stock Entity_Freeze(entity)
{
	Entity_AddFlags(entity, FL_FROZEN);
}

/**
 * Unfreezes an entity by removing the FL_FROZEN flag.
 *
 * @param entity		Entity index.
 * @return 				True on success, false otherwise
 */
stock Entity_UnFreeze(entity)
{
	Entity_RemoveFlags(entity, FL_FROZEN);
}


/**
 * This function points an entity to another with the targetname
 * and name. Useful for allot of entities like trigger_teleport.
 * If the name is not specified it will be generated automatically.
 *
 * @param entity			Entity index.
 * @param target			Target entity index.
 * @param				Optional: target name
 * @noreturn
 */
stock Entity_PointAtTarget(entity, target, const String:name[]="")
{
	decl String:targetName[128];
	Entity_GetTargetName(entity, targetName, sizeof(targetName));

	if (name[0] == '\0') {

		if (targetName[0] == '\0') {
			// Let's generate our own name
			Format(
				targetName,
				sizeof(targetName),
				"_smlib_Entity_PointAtTarget:%d",
				target
			);
		}
	}
	else {
		strcopy(targetName, sizeof(targetName), name);
	}
	
	Entity_SetTargetName(entity, targetName);
	Entity_SetName(target, targetName);
}

/**
 * This function points a point_hurt entity to another damage target entity..
 * and name. Useful for allot of entities like trigger_teleport.
 * If the name is not specified it will be generated automatically.
 *
 * @param entity			Entity index.
 * @param target			Target entity index.
 * @param					Optional: target name
 * @noreturn
 */
stock Entity_PointHurtAtTarget(entity, target, const String:name[]="")
{
	decl String:targetName[128];
	Entity_GetTargetName(entity, targetName, sizeof(targetName));

	if (name[0] == '\0') {

		if (targetName[0] == '\0') {
			// Let's generate our own name
			Format(
				targetName,
				sizeof(targetName),
				"_smlib_Entity_PointHurtAtTarget:%d",
				target
			);
		}
	}
	else {
		strcopy(targetName, sizeof(targetName), name);
	}

	DispatchKeyValue(entity, "DamageTarget", targetName);
	Entity_SetName(target, targetName);
}

/**
 * Checks if an entity is a player or not.
 * No checks are done if the entity is actually valid,
 * the player is connected or ingame.
 *
 * @param entity			Entity index.
 * @return 				True if the entity is a player, false otherwise.
 */
stock bool:Entity_IsPlayer(entity)
{
	if (entity < 1 || entity > MaxClients) {
		return false;
	}
	
	return true;
}

/**
 *  Creates an entity by classname.
 *
 * @param className			Classname String.
 * @param ForceEdictIndex	Edict Index to use.
 * @return 					Entity Index or INVALID_ENT_REFERENCE if the slot is already in use.
 */
stock Entity_Create(const String:className[], ForceEdictIndex=-1)
{
	if (ForceEdictIndex != -1 && Entity_IsValid(ForceEdictIndex)) {
		return INVALID_ENT_REFERENCE;
	}

	return CreateEntityByName(className, ForceEdictIndex);
}

/**
 * Kills an entity on the next frame (delayed).
 * It is safe to use with entity loops.
 * If the entity is is player ForcePlayerSuicide() is called.
 *
 * @param kenny			Entity index.
 * @param killChildren	When true, kennys children are killed too.
 * @return 				True on success, false otherwise.
 */
stock bool:Entity_Kill(kenny, killChildren=false)
{
	if (Entity_IsPlayer(kenny)) {
		// Oh My God! They Killed Kenny!!
		ForcePlayerSuicide(kenny);
		return true;
	}
	
	if(killChildren){
		return AcceptEntityInput(kenny, "KillHierarchy");
	}
	else {
		return AcceptEntityInput(kenny, "Kill");
	}
}

/**
 * Kills all entities with the given networked classname.
 *  It is safe to use with entity loops.
 * If the entity is is player ForcePlayerSuicide() is called.
 *
 * @param className		Entity Network Class to search for.
 * @return 				Number of entities killed.
 */
stock Entity_KillAllByClassName(const String:className[])
{
	new x = 0;

	new entity = INVALID_ENT_REFERENCE;
	while ((entity = FindEntityByClassname(entity, className)) != INVALID_ENT_REFERENCE) {
		AcceptEntityInput(entity, "kill");
		x++;
	}
	
	return x;
}

/**
 * Gets the owner of an entity.
 * For example the owner of a weapon entity.
 *
 * @param entity		Entity index.
 * @return 				Ground Entity or -1
 */
stock Entity_GetOwner(entity)
{
	return GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
}

/**
 * Sets the owner of an entity.
 * For example the owner of a weapon entity.
 *
 * @param entity			Entity index.
 * @noreturn
 */
stock Entity_SetOwner(entity, newOwner)
{
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", newOwner);
}

/**
 * Get's the ground entity this entity stands on.
 *
 * @param entity		Entity index.
 * @return 				Ground Entity or -1
 */
stock Entity_GetGroundEntity(entity)
{
	return GetEntPropEnt(entity, Prop_Data, "m_hGroundEntity");
}

/*
 *  Damage definitions
 */

#if !defined DMG_GENERIC

#define DMG_GENERIC			0			// generic damage was done
#define DMG_CRUSH			(1 << 0)	// crushed by falling or moving object. 
										// NOTE: It's assumed crush damage is occurring as a result of physics collision, so no extra physics force is generated by crush damage.
										// DON'T use DMG_CRUSH when damaging entities unless it's the result of a physics collision. You probably want DMG_CLUB instead.
#define DMG_BULLET			(1 << 1)	// shot
#define DMG_SLASH			(1 << 2)	// cut, clawed, stabbed
#define DMG_BURN			(1 << 3)	// heat burned
#define DMG_VEHICLE			(1 << 4)	// hit by a vehicle
#define DMG_FALL			(1 << 5)	// fell too far
#define DMG_BLAST			(1 << 6)	// explosive blast damage
#define DMG_CLUB			(1 << 7)	// crowbar, punch, headbutt
#define DMG_SHOCK			(1 << 8)	// electric shock
#define DMG_SONIC			(1 << 9)	// sound pulse shockwave
#define DMG_ENERGYBEAM		(1 << 10)	// laser or other high energy beam 
#define DMG_PREVENT_PHYSICS_FORCE		(1 << 11)	// Prevent a physics force 
#define DMG_NEVERGIB		(1 << 12)	// with this bit OR'd in, no damage type will be able to gib victims upon death
#define DMG_ALWAYSGIB		(1 << 13)	// with this bit OR'd in, any damage type can be made to gib victims upon death.
#define DMG_DROWN			(1 << 14)	// Drowning


#define DMG_PARALYZE		(1 << 15)	// slows affected creature down
#define DMG_NERVEGAS		(1 << 16)	// nerve toxins, very bad
#define DMG_POISON			(1 << 17)	// blood poisoning - heals over time like drowning damage
#define DMG_RADIATION		(1 << 18)	// radiation exposure
#define DMG_DROWNRECOVER	(1 << 19)	// drowning recovery
#define DMG_ACID			(1 << 20)	// toxic chemicals or acid burns
#define DMG_SLOWBURN		(1 << 21)	// in an oven

#define DMG_REMOVENORAGDOLL	(1<<22)		// with this bit OR'd in, no ragdoll will be created, and the target will be quietly removed.
										// use this to kill an entity that you've already got a server-side ragdoll for

#define DMG_PHYSGUN			(1<<23)		// Hit by manipulator. Usually doesn't do any damage.
#define DMG_PLASMA			(1<<24)		// Shot by Cremator
#define DMG_AIRBOAT			(1<<25)		// Hit by the airboat's gun

#define DMG_DISSOLVE		(1<<26)		// Dissolving!
#define DMG_BLAST_SURFACE	(1<<27)		// A blast on the surface of water that cannot harm things underwater
#define DMG_DIRECT			(1<<28)
#define DMG_BUCKSHOT		(1<<29)		// not quite a bullet. Little, rounder, different.

#endif

/**
 * Does damage to an entity.
 * This is a powerful function that allows you to specify
 * who the attacker is, the damage type and also what weapon
 * should be displayed in the hud kill message.
 * Note that for entities that fire another entity (RPG's, Crossbow's,
 * you have to pass the bullet's class, not the weapon's class !
 * It hasn't been tested how expensive this function is, as it
 * uses the entity point_hurt.
 * If you need a cheaper function use Entity_RemoveHealth().
 *
 * @param entity			Entity index.
 * @param damage			Amount of damage.
 * @param attacker		Entity Index of the attacker.
 * @param damageType		Use the DMG_ definations.
 * @param fakeClassName	Classname to fake, you can set this if you
 * 						want a specific weapon to be shown in the HUD kill message.
 * @return 				True on success, false otherwise.
 */
stock bool:Entity_Hurt(entity, damage, attacker=0, damageType=DMG_GENERIC, const String:fakeClassName[]="")
{
	static point_hurt = INVALID_ENT_REFERENCE;
	
	if (point_hurt == INVALID_ENT_REFERENCE || !IsValidEntity(point_hurt)) {
		point_hurt = EntIndexToEntRef(Entity_Create("point_hurt"));
		
		if (point_hurt == INVALID_ENT_REFERENCE) {
			return false;
		}
		
		DispatchSpawn(point_hurt);
	}
	
	AcceptEntityInput(point_hurt, "TurnOn");
	SetEntProp(point_hurt, Prop_Data, "m_nDamage", damage);
	SetEntProp(point_hurt, Prop_Data, "m_bitsDamageType", damageType);
	Entity_PointHurtAtTarget(point_hurt, entity);
	
	if (fakeClassName[0] != '\0') {
		Entity_SetClassName(point_hurt, fakeClassName);
	}
	
	AcceptEntityInput(point_hurt, "Hurt", attacker);
	AcceptEntityInput(point_hurt, "TurnOff");
	
	if (fakeClassName[0] != '\0') {
		Entity_SetClassName(point_hurt, "point_hurt");
	}
	
	return true;
}

/*
 * Gets the parent entity of an entity.
 * 
 * @param entity		Entity Index.
 * @return				Entity Index of the parent.
 */
stock Entity_GetParent(entity)
{
	return GetEntPropEnt(entity, Prop_Data, "m_pParent");
}

/*
 * Clears the parent of an entity.
 * 
 * @param entity		Entity Index.
 * @noreturn
 */
stock Entity_ClearParent(entity)
{
	SetVariantString("");
	AcceptEntityInput(entity, "ClearParent");
}

/*
 * Sets the parent entity of an entity.
 * 
 * @param entity		Entity Index.
 * @param parentEntity	Entity Index of the new parent.
 * @noreturn
 */
stock Entity_SetParent(entity, parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}


/*
 * Callback for Change_OverTime.
 * Note that every parameter is a reference and can be changed during this callback.
 * You can get the elapsed time since start by multiply tick with currentCall.
 * 
 * @param entity		Entity Index.
 * @param interval		The current interval from the current game time to execute the next call of this function.
 * @param currentCall	The current call number (0 is the 1st call at 0.0 seconds, 1 the 2nd call at tick*1 seconds, ...).
 * @return				When true this callback will be called again at the next defined tick, otherwise it won't.
 */
functag Entity_ChangeOverTimeCallback bool:public(&entity, &Float:interval, &currentCall);

/*
 * Creates a timer and provides a callback to change various things about an entity over time.
 * 
 * @param entity			Entity Index.
 * @param interval			Interval from the current game time to execute the given function.
 * @noreturn
 */
stock Entity_ChangeOverTime(entity, Float:interval=0.1, Entity_ChangeOverTimeCallback:valueCallback)
{	
	new Handle:dataPack = CreateDataPack();
	WritePackCell(dataPack, EntIndexToEntRef(entity));
	WritePackFloat(dataPack, interval);
	WritePackCell(dataPack, 0);
#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 7
	WritePackFunction(dataPack, valueCallback);
#else
	WritePackCell(dataPack, _:valueCallback);
#endif
	ResetPack(dataPack);
	__smlib_Timer_ChangeOverTime(INVALID_HANDLE,dataPack);
}

public Action:__smlib_Timer_ChangeOverTime(Handle:Timer, Handle:dataPack)
{
	new entity = EntRefToEntIndex(ReadPackCell(dataPack));
	if(!Entity_IsValid(entity)){
		return Plugin_Stop;
	}
	
	new Float:interval = ReadPackFloat(dataPack);
	new currentCall = ReadPackCell(dataPack);
#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 7
	new Function:callback = ReadPackFunction(dataPack);
#else
	new Function:callback = Function:ReadPackCell(dataPack);
#endif
	
	new any:result;
	Call_StartFunction(INVALID_HANDLE, callback);
	Call_PushCellRef(entity);
	Call_PushFloatRef(interval);
	Call_PushCellRef(currentCall);
	Call_Finish(result);
	
	if(result == false){
		return Plugin_Stop;
	}
	
	ResetPack(dataPack,true);
	WritePackCell(dataPack, EntIndexToEntRef(entity));
	WritePackFloat(dataPack, interval);
	WritePackCell(dataPack, currentCall+1);
#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 7
	WritePackFunction(dataPack, callback);
#else
	WritePackCell(dataPack, _:callback);
#endif
	ResetPack(dataPack);
	CreateTimer(interval,__smlib_Timer_ChangeOverTime,dataPack);
	return Plugin_Stop;
}


/**
 * Gets the next child, entity is parent of.
 *
 * @param client		Entity Index (of Parent)
 * @param start			Start Index.
 * @return				Entity Index or -1 if no entity was found.
 */
stock Entity_GetNextChild(parent, start=0)
{
	for (new entity=start; entity <= 2048; entity++) {

		if (!Entity_IsValid(entity)) {
			continue;
		}

		if (entity > 0 && entity <= MaxClients && !IsClientConnected(entity)) {
			continue;
		}

		if (Entity_GetParent(entity) == parent) {
			return entity;
		}
	}

	return INVALID_ENT_REFERENCE;
}
/**
 * Gets the move/open direction of an entity (only available for func_door*, prop_door* and func_movelinear).
 * Ex: if vec[2] is 1.0 a func_door moves straight up.
 * 
 * @param entity			Entity index.
 * @param vec				Vector.
 * @noreturn
 */
stock Entity_GetMoveDirection(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecMoveDir", vec);
}
/**
 * Sets the move/open direction of an entity (only available for func_door*, prop_door* and func_movelinear).
 * Ex: if vec[2] is 1.0 a func_door moves straight up.
 * 
 * @param entity			Entity index.
 * @param vec				Vector.
 * @noreturn
 */
stock Entity_SetMoveDirection(entity, const Float:vec[3])
{
	SetEntPropVector(entity, Prop_Data, "m_vecMoveDir", vec);
}

/**
 * Returns if the entity will force close (won't be blockable by players and/or objects) or not when triggered to move.
 * 
 * @param entity			Entity index.
 * @return					True if the door will force close, otherwise false.
 */
stock bool:Entity_GetForceClose(entity)
{
	return bool:GetEntProp(entity, Prop_Data, "m_bForceClosed");
}

/**
 * Sets if the door should force close (souldn't be blockable by players and/or objects) or not when triggered to move.
 * 
 * @param entity			Entity index.
 * @param forceClose		If true the door will force close, otherwise it won't.
 * @noreturn
 */
stock Entity_SetForceClose(entity, bool:forceClose)
{
	SetEntProp(entity, Prop_Data, "m_bForceClosed", forceClose);
}

/**
 * Gets the speed of a moving entity (like doors: open close speed).
 * 
 * @param entity			Entity index.
 * @return					Speed of the entity.
 */
stock Float:Entity_GetSpeed(entity)
{
	return GetEntPropFloat(entity, Prop_Data, "m_flSpeed");
}

/**
 * Sets how fast an entity moves (like doors: open close speed).
 * 
 * @param entity			Entity index.
 * @param speed				The new speed of the entity.
 * @noreturn
 */
stock Entity_SetSpeed(entity, Float:speed)
{
	SetEntPropFloat(entity, Prop_Data, "m_flSpeed", speed);
}

/**
 * Gets the damage of a moving entity when blocked (like doors when open or close and players and/or objects are between the entity and something else).
 * Note: Negative values add health to the blocking entity.
 *
 * @param entity			Entity index.
 * @return					Damage.
 */
stock Float:Entity_GetBlockDamage(entity)
{
	return GetEntPropFloat(entity, Prop_Data, "m_flBlockDamage");
}

/**
 * Sets the damage of a moving entity when blocked (like doors when open or close and players and/or objects are between the entity and something else).
 * Note: Negative values add health to the blocking entity.
 * 
 * @param entity			Entity index.
 * @param damage			Damage.
 * @noreturn
 */
stock Entity_SetBlockDamage(entity, Float:damage)
{
	SetEntPropFloat(entity, Prop_Data, "m_flBlockDamage", damage);
}

/**
 * Returns if the given entity is disabled or not.
 * 
 * @param entity			Entity index.
 * @return					True if entity is disabled, otherwise false.
 */
stock bool:Entity_IsDisabled(entity)
{
	return bool:GetEntProp(entity, Prop_Data, "m_bDisabled", 1);
}

/**
 * Disables the given entity.
 * 
 * @param entity			Entity index.
 * @return					True if successful otherwise false.
 */
stock Entity_Disable(entity)
{
	return AcceptEntityInput(entity, "Disable");
}

/**
 * Enables the given entity.
 * 
 * @param entity			Entity index.
 * @return					True if successful otherwise false.
 */
stock Entity_Enable(entity)
{
	return AcceptEntityInput(entity, "Enable");
}


// settings for m_takedamage taken from hl2sdk-ob-valve\game\shared\shareddefs.h
#define		DAMAGE_NO			0
#define 	DAMAGE_EVENTS_ONLY	1		// Call damage functions, but don't modify health
#define		DAMAGE_YES			2
#define		DAMAGE_AIM			3

/**
 * Sets the mode for an entity to take damage.
 * Note: This is used to give a client god mode (DAMAGE_NO).
 * 
 * @param entity			Entity index.
 * @param value				Mode, use DAMAGE_* defines.
 * @noreturn
 */
stock Entity_SetTakeDamage(entity, value)
{
	SetEntProp(entity, Prop_Data, "m_takedamage", value, 1);
}

/**
 * Gets the mode for an entity to take damage.
 * Note: When the return value is DAMAGE_NO then the client is using godmode.
 * 
 * @param entity			Entity index.
 * @return					Take damage mode (DAMAGE_*).
 */
stock Entity_GetTakeDamage(entity)
{
	return GetEntProp(entity, Prop_Data, "m_takedamage", 1);
}

/**
 * Sets the minimum of damage required to hurt this entity.
 * Example: This is used to block any damage done by projectile weapons against a gun ship in Half-Life 2.
 * 
 * @param entity			Entity index.
 * @param minDamage			Minimum required damage.
 * @noreturn
 */
stock Entity_SetMinHealthDamage(entity, minDamage)
{
	SetEntProp(entity, Prop_Data, "m_iMinHealthDmg", minDamage);
}

/**
 * Gets the minimum of damage required to hurt this entity.
 * Example: This is used to block any damage done by projectile weapons against a gun ship in Half-Life 2.
 * 
 * @param entity			Entity index.
 * @return					Minimum required damage.
 */
stock Entity_GetMinHealthDamage(entity)
{
	return GetEntProp(entity, Prop_Data, "m_iMinHealthDmg");
}

/**
 * Gets an entity's color.
 *
 * @param entity	Entity index
 * @param color 	4 dimensional array where [r,g,b,a] values are stored
 * @noreturn
 * @error			Invalid entity index, or lack of mod compliance.
 */
stock Entity_GetRenderColor(entity, color[4])
{
	static bool:gotconfig = false;
	static String:prop[32];

	if (!gotconfig) {
		new Handle:gc = LoadGameConfigFile("core.games");
		new bool:exists = GameConfGetKeyValue(gc, "m_clrRender", prop, sizeof(prop));
		CloseHandle(gc);

		if (!exists) {
			strcopy(prop, sizeof(prop), "m_clrRender");
		}
		
		gotconfig = true;
	}

	new offset = GetEntSendPropOffs(entity, prop);

	if (offset <= 0) {
		ThrowError("SetEntityRenderColor not supported by this mod");
	}

	for (new i=0; i < 4; i++) {
		color[i] = GetEntData(entity, offset + i + 1, 1);
	}
}

/**
 * Sets an entity's color.
 * Doesn't change the value, if set to -1.
 *
 * @param entity	Entity index
 * @param r 		Amount of red (0-255)
 * @param g 		Amount of green (0-255)
 * @param b 		Amount of blue (0-255)
 * @param a 		Amount of alpha (0-255)
 * @noreturn
 * @error			Invalid entity index, or lack of mod compliance.
 */
stock Entity_SetRenderColor(entity, r=-1, g=-1, b=-1, a=-1)
{
	static bool:gotconfig = false;
	static String:prop[32];

	if (!gotconfig) {
		new Handle:gc = LoadGameConfigFile("core.games");
		new bool:exists = GameConfGetKeyValue(gc, "m_clrRender", prop, sizeof(prop));
		CloseHandle(gc);

		if (!exists) {
			strcopy(prop, sizeof(prop), "m_clrRender");
		}

		gotconfig = true;
	}

	new offset = GetEntSendPropOffs(entity, prop);

	if (offset <= 0) {
		ThrowError("SetEntityRenderColor not supported by this mod");
	}

	if(r != -1) {
		SetEntData(entity, offset, r, 1, true);
	}

	if(g != -1) {
		SetEntData(entity, offset + 1, g, 1, true);
	}

	if(b != -1) {
		SetEntData(entity, offset + 2, b, 1, true);
	}

	if(a != -1) {
		SetEntData(entity, offset + 3, a, 1, true);
	}
}

/**
 * Sends the 'addouput' command to an entity.
 *
 * @param entity		Entity Index.
 * @param input			Input command.
 * @param activator		Entity index which initiated the sequence of actions (-1 for a NULL entity).
 * @param caller		Entity index from which this event is sent (-1 for a NULL entity).
 * @param outputid		Unknown.
 * @return				True if successful, otherwise false.
 */
stock bool:Entity_AddOutput(entity, const String:input[], activator=-1, caller=-1, outputid=0)
{
	SetVariantString(input);
	return AcceptEntityInput(entity, "addoutput", activator, caller, outputid);
}

