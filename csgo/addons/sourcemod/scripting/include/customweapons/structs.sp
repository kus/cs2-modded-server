/*
 *  • Arranges in enum-structs all the data that custom weapon needs in each related subject.
 *  • Initializes global variables for data storage.
 */

#if !defined COMPILING_FROM_MAIN
#error "Attemped to compile from the wrong file"
#endif

enum struct Player
{
    // Our client slot index.
    int client;
    
    // Client 'CPredictedViewModel' entity reference.
    int view_model_reference;
    
    bool default_sounds_enabled;
    
    // Timer that toggling 'default_sounds_enabled'.
    Handle toggle_sounds_timer;
    
    //======================================//
    
    void Init(int client)
    {
        this.client = client;
        this.view_model_reference = INVALID_ENT_REFERENCE;
        
        this.default_sounds_enabled = true;
    }
    
    void Close()
    {
        this.view_model_reference = 0;
        this.default_sounds_enabled = false;
        
        delete this.toggle_sounds_timer;
    }
    
    void InitViewModel()
    {
        this.view_model_reference = EntIndexToEntRef(GetEntPropEnt(this.client, Prop_Send, "m_hViewModel"));
    }
    
    // Retrieves the client predicted view model entity index.
    // Will return -1 if unavailable.
    int GetViewModel()
    {
        return EntRefToEntIndex(this.view_model_reference);
    }
    
    // Used to turn off weapon shot sounds that are client sided.
    // During a use of a custom weapon shot sound this convar will
    // be replicated to the weapon owner.
    void ToggleDefaultShotSounds(bool value)
    {
        static ConVar weapon_sound_falloff_multiplier;
        if (!weapon_sound_falloff_multiplier && !(weapon_sound_falloff_multiplier = FindConVar("weapon_sound_falloff_multiplier")))
        {
            SetFailState("Failed to find convar 'weapon_sound_falloff_multiplier'");
        }
        
        if (!IsFakeClient(this.client))
        {
            weapon_sound_falloff_multiplier.ReplicateToClient(this.client, value ? "1" : "0");
        }
    }
}

// Players data.
Player g_Players[MAXPLAYERS + 1];

// All spawned custom weapons around the map area.
// Keys are entity references.
AnyMap g_CustomWeapons;

enum struct CustomWeaponData
{
    // Registeration plugin handle.
    Handle plugin;
    
    // Custom models. (view, world, dropped)
    char view_model[PLATFORM_MAX_PATH];
    char world_model[PLATFORM_MAX_PATH];
    char dropped_model[PLATFORM_MAX_PATH];
    
    // Weapon custom shot sound,
    // relative to "sounds/*" folder.
    char shot_sound[PLATFORM_MAX_PATH];
    
    //======================================//
    
    // Update/Remove/Get methods for convenience.
    void UpdateMyself(int entity_reference)
    {
        // Copies back the vehicle data to the global trie map.
        g_CustomWeapons.SetArray(entity_reference, this, sizeof(CustomWeaponData));
    }
    
    bool RemoveMyself(int entity_reference)
    {
        // Removes |this| from the global vehicles trie map.
        bool ret = g_CustomWeapons.Remove(entity_reference);
        
        this.Close(EntRefToEntIndex(entity_reference));
        
        return ret;
    }
    
    bool GetMyself(int entity)
    {
        // Retrieves |this| from the global vehicles trie map.
        return this.GetMyselfByReference(EntIndexToEntRef(entity));
    }
    
    bool GetMyselfByReference(int entity_reference)
    {
        // Same function as above, with entity reference support.
        return g_CustomWeapons.GetArray(entity_reference, this, sizeof(CustomWeaponData));
    }
    
    void Close(int entity)
    {
        int weapon_owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
        if (weapon_owner == -1)
        {
            return;
        }
        
        if (this.HasCustomShotSound())
        {
            g_Players[weapon_owner].ToggleDefaultShotSounds(true);
            
            g_Players[weapon_owner].default_sounds_enabled = true;
        }
        
        ReEquipWeaponEntity(entity, weapon_owner);
    }
    
    bool HasCustomShotSound()
    {
        return this.shot_sound[0] != '\0';
    }
}

void InitializeGlobalVariables()
{
    g_CustomWeapons = new AnyMap();
} 