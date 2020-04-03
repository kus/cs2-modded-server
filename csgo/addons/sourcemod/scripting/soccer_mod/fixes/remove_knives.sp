public void RemoveKnivesEventPlayerSpawn(Event event)
{
    int maxEntities = GetMaxEntities();
    char className[64];
    for (int index = MaxClients; index < maxEntities; index++)
    {
        if (IsValidEntity(index) && IsValidEdict(index) && GetEdictClassname(index, className, sizeof(className)) && 
            StrEqual(className, "weapon_knife") && GetEntPropEnt(index, Prop_Send, "m_hOwnerEntity") == -1) RemoveEdict(index);
    }
}