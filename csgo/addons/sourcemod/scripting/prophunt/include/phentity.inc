#if defined _phentity_included
    #endinput
#endif
#define _phentity_included

#define MAXENTITIES 2048

methodmap PHEntity __nullable__
{
    /**
     * Creates a new PHEntity wrapper for an entity.
     *
     * @param entity     Entity to wrap.
     */
    public PHEntity(int entity) {
        return view_as<PHEntity>(entity);
    }

    /**
     * Returns the underlying entity.
     */ 
    property int index {
        public get() {
            return view_as<int>(this);
        }
    }

    /**
     * Returns true if this entity has a child entity,
     * and the child is a valid entity.
     */
    property bool hasChild {
        public get() {
            return PHEntity_HasChild(this);
        }
    }

    /**
     * Returns the entity whose parent this entity is,
     * if any.
     */
    property PHEntity child {
        public get() {
            return PHEntity_GetChild(this);
        }
    }

    /**
     * Gets the absolute origin (position) of this entity.
     * 
     * @param vec       Vector array to hold the origin.
     * @noreturn
     */ 
    public void GetOrigin(float vec[3]) {
        PHEntity_GetOrigin(this, vec);
    }

    /**
     * Gets the absolute angles (rotation) of this entity.
     * 
     * @param vec       Vector array to hold the angles.
     * @noreturn
     */ 
    public void GetAbsAngles(float vec[3]) {
        PHEntity_GetAbsAngles(this, vec);
    }

    /**
     * Gets the absolute velocity of this entity.
     * 
     * @param vec       Vector array to hold the velocity.
     * @noreturn
     */ 
    public void GetVelocity(float vec[3]) {
        PHEntity_GetVelocity(this, vec);
    }

    /**
     * Sets this entity's movetype.
     *
     * @mt          New MoveType.
     * @noreturn
     */
    public void SetMoveType(MoveType mt) {
        PHEntity_SetMoveType(this, mt);
    }

    /**
     * Sets this entity's movement speed multiplier.
     *
     * @param speed     New speed multiplier. 1.0 for original speed.
     * @noreturn
     */
    public void SetMovementSpeed(float speed) {
        PHEntity_SetMovementSpeed(this, speed);
    }

    /**
     * Makes this entity an entity's parent.
     *
     * @param entity    Child entity.
     * @noreturn

     */
    public void SetChild(PHEntity entity) {
        PHEntity_SetChild(this, entity);
    }

    /**
     * Detaches and forgets the entity whose parent this entity is.
     * Attaching will no more be possible with AttachChild().
     *
     * @noreturn
     */
    public void RemoveChild() {
        PHEntity_RemoveChild(this);
    }

    /**
     * Attaches this entity's child to this entity, if previously detached.
     * Not possible if the child has been removed.
     *
     * @noreturn
     */
    public void AttachChild() {
        PHEntity_AttachChild(this);
    }
    
    /**
     * Detaches this entity's child from this entity. It may be reattached
     * with AttachChild().
     *
     * @noreturn
     */
    public void DetachChild() {
        PHEntity_DetachChild(this);
    }

    /**
     * Teleports this entity.
     *
     * @param origin    New origin (position), or NULL_VECTOR for no change.
     * @param angles    New angles, or NULL_VECTOR for no change.
     * @param velocity  New velocity (position), or NULL_VECTOR for no change.
     * @noreturn
     */
    public void Teleport(const float origin[3], const float angles[3], const float velocity[3]) {
        PHEntity_Teleport(this, origin, angles, velocity);
    }

    /**
     * Teleports this entity to another entity.
     *
     * @param target    Entity to teleport to.
     * @param ang       New angles, or NULL_VECTOR for no change.
     * @param vel       New velocity, or NULL_VECTOR for no change.
     * @noreturn
     */
    public void TeleportTo(PHEntity target, const float ang[3]=NULL_VECTOR, const float vel[3]=NULL_VECTOR) {
        PHEntity_TeleportTo(this, target, ang, vel);
    }

}

PHEntity g_iEntities[MAXENTITIES+1] = {null, ...};
PHEntity g_iEntityChildren[MAXENTITIES+1] = {null, ...};

/**
 * Returns true if an entity has a child entity,
 * and the child is a valid entity.
 *
 * @param entity    Entity.
 */
stock bool PHEntity_HasChild(PHEntity entity) {
    PHEntity child = g_iEntityChildren[entity.index];
    return child != null && IsValidEntity(child.index);
}

/**
 * Returns the entity whose parent this entity is,
 * if any.
 *
 * @param entity    Entity.
 */
stock PHEntity PHEntity_GetChild(PHEntity entity) {
    return g_iEntityChildren[entity.index];
}

/**
 * Gets the absolute origin (position) of an entity.
 * 
 * @param entity    Entity.
 * @param vec       Vector array to hold the origin.
 * @noreturn
 */ 
stock void PHEntity_GetOrigin(PHEntity entity, float vec[3]) {
    GetEntPropVector(entity.index, Prop_Send, "m_vecOrigin", vec);
}

/**
 * Gets the absolute angles (rotation) of an entity.
 * 
 * @param entity    Entity.
 * @param vec       Vector array to hold the angles.
 * @noreturn
 */ 
stock void PHEntity_GetAbsAngles(PHEntity entity, float vec[3]) {
    GetEntPropVector(entity.index, Prop_Send, "m_angAbsRotation", vec);
}

/**
 * Gets the absolute velocity of an entity.
 * 
 * @param entity    Entity.
 * @param vec       Vector array to hold the velocity.
 * @noreturn
 */ 
stock void PHEntity_GetVelocity(PHEntity entity, float vec[3]) {
    GetEntPropVector(entity.index, Prop_Send, "m_vecAbsVelocity", vec);
}

/**
 * Sets an entity's movetype.
 *
 * @param entity    Entity.
 * @mt              New MoveType.
 * @noreturn
 */
stock void PHEntity_SetMoveType(PHEntity entity, MoveType mt) {
    SetEntityMoveType(entity.index, mt);
}

/**
 * Sets an entity's movement speed multiplier.
 *
 * @param entity    Entity.
 * @param speed     New speed multiplier. 1.0 for original speed.
 * @noreturn
 */
stock void PHEntity_SetMovementSpeed(PHEntity entity, float speed) {
    SetEntPropFloat(entity.index, Prop_Send, "m_flLaggedMovementValue", speed);
}

/**
 * Makes an entity some entity's parent.
 *
 * @param entity    Entity.
 * @param entity    Child entity.
 * @noreturn

 */
stock void PHEntity_SetChild(PHEntity entity, PHEntity child) {
    if (entity.hasChild)
        entity.RemoveChild();

    g_iEntityChildren[entity.index] = child;
    entity.AttachChild();
}

/**
 * Detaches and forgets the entity whose parent this entity is.
 * Attaching will no more be possible with PHEntity_AttachChild.
 *
 * @param entity    Entity.
 * @noreturn
 */
stock void PHEntity_RemoveChild(PHEntity entity) {
    if (entity.hasChild) {
        entity.DetachChild();
        g_iEntityChildren[entity.index] = null;
    }
}

/**
 * Attaches an entity's child to the entity, if previously detached.
 * Not possible if the child has been removed.
 *
 * @param entity    Entity.
 * @noreturn
 */
stock void PHEntity_AttachChild(PHEntity entity) {
    if (entity.hasChild) {
        PHEntity child = entity.child;
        child.TeleportTo(entity);

        SetVariantString("!activator");
        AcceptEntityInput(entity.child.index, "SetParent", entity.index, child.index, 0);
    }
}

/**
 * Detaches an entity's child from this entity. It may be reattached
 * with AttachChild().
 *
 * @param entity    Entity.
 * @noreturn
 */
stock void PHEntity_DetachChild(PHEntity entity) {
    if (entity.hasChild) {
        SetVariantString("");
        AcceptEntityInput(entity.child.index, "ClearParent");
    }
}

/**
 * Teleports an entity.
 *
 * @param entity    Entity.
 * @param origin    New origin (position), or NULL_VECTOR for no change.
 * @param angles    New angles, or NULL_VECTOR for no change.
 * @param velocity  New velocity (position), or NULL_VECTOR for no change.
 * @noreturn
 */
stock void PHEntity_Teleport(PHEntity entity, const float origin[3], const float angles[3], const float velocity[3]) {
    TeleportEntity(entity.index, origin, angles, velocity);
}

/**
 * Teleports an entity to another entity.
 *
 * @param entity    Entity.
 * @param target    Entity to teleport to.
 * @param ang       New angles, or NULL_VECTOR for no change.
 * @param vel       New velocity, or NULL_VECTOR for no change.
 * @noreturn
 */
stock void PHEntity_TeleportTo(PHEntity entity, PHEntity target, const float ang[3]=NULL_VECTOR, const float vel[3]=NULL_VECTOR) {
    float orig[3];
    target.GetOrigin(orig);
    PHEntity_Teleport(entity, orig, ang, vel);
}

stock PHEntity GetPHEntity(int entity) {
    if (entity < 1 || entity > MAXENTITIES)
        return null;

    return g_iEntities[entity];
}

stock PHEntity RegisterPHEntity(int entity) {
    if (entity < 1 || entity > MAXENTITIES)
        return null;

    g_iEntities[entity] = new PHEntity(entity);
    return g_iEntities[entity];
}

stock void UnregisterPHEntity(int _entity) {
    PHEntity entity = GetPHEntity(_entity);
    if (entity) {
        entity.RemoveChild();
        g_iEntities[entity.index] = null;
    }
}
