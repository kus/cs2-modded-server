/**
 * Reads gunagme system config file.
 */
OnKeyValueStart()
{
    /* Make sure to use unique section name just incase someone else uses it */
    KvWeapon = CreateKeyValues("gg_WeaponInfo", BLANK, BLANK);
    if (g_GameName == GameName:Css) {
        FormatEx(WeaponFile, sizeof(WeaponFile), "cfg\\gungame\\css\\weaponinfo.txt");
    } else if (g_GameName == GameName:Csgo) {
        FormatEx(WeaponFile, sizeof(WeaponFile), "cfg\\gungame\\csgo\\weaponinfo.txt");
    }

    if ( !FileExists(WeaponFile) )
    {
        decl String:Error[PLATFORM_MAX_PATH + 64];
        FormatEx(Error, sizeof(Error), "FATAL ERROR File does not exists [%s]", WeaponFile);
        SetFailState(Error);
    }

    WeaponOpen = FileToKeyValues(KvWeapon, WeaponFile);

    if ( TrieWeapon == INVALID_HANDLE )
    {
        TrieWeapon = CreateTrie();
    }
    else
    {
        ClearTrie(TrieWeapon);
    }
    
    if ( !WeaponOpen )
    {
        return;
    }

    KvRewind(KvWeapon);

    if ( !KvGotoFirstSubKey(KvWeapon) )
    {
        return;
    }

    new String:name[MAX_WEAPON_NAME_LEN];
    new index;
    g_WeaponsMaxId          = 0;
    g_WeaponIdKnife         = 0;
    g_WeaponIdHegrenade     = 0;
    g_WeaponIdSmokegrenade  = 0;
    g_WeaponIdFlashbang     = 0;
    g_WeaponIdTaser         = 0;

    g_WeaponAmmoTypeHegrenade       = 0;
    g_WeaponAmmoTypeFlashbang       = 0;
    g_WeaponAmmoTypeSmokegrenade    = 0;
    g_WeaponAmmoTypeMolotov         = 0;
    g_WeaponAmmoTypeTaser           = 0;

    for (;;) {
        if ( !KvGetSectionName(KvWeapon, name, sizeof(name)) ) {
            break;
        }

        index = KvGetNum(KvWeapon, "index");
        UTIL_StringToLower(name);

        // init weapons by name array
        SetTrieValue(TrieWeapon, name, index);
        // init weapons count
        g_WeaponsMaxId++;
        // init weapons full names (to use in give commands)
        FormatEx(g_WeaponName[index], sizeof(g_WeaponName[]), "weapon_%s", name);
        // init weapons slots
        g_WeaponSlot[index] = Slots:KvGetNum(KvWeapon, "slot", 0);
        // init weapons clip size
        g_WeaponAmmo[index] = KvGetNum(KvWeapon, "clipsize", 0);
        // init weapons that need drop knife
        g_WeaponDropKnife[index] = bool:KvGetNum(KvWeapon, "drop_knife", 0);
        // level index (different weapons but the same level)
        g_WeaponLevelIndex[index] = KvGetNum(KvWeapon, "level_index", 0);

        if (!g_WeaponLevelIndex[index]) {
            decl String:Error[1024];
            FormatEx(Error, sizeof(Error), "FATAL ERROR: Level index should not be zero for %s. You should update you %s and take it from the release zip file.", 
                name, WeaponFile);
            SetFailState(Error);
        }

        if (KvGetNum(KvWeapon, "is_knife", 0)) {
            g_WeaponIdKnife                 = index;
            g_WeaponLevelIdKnife            = g_WeaponLevelIndex[index];
        } else if (KvGetNum(KvWeapon, "is_hegrenade", 0)) {
            g_WeaponIdHegrenade             = index;
            g_WeaponLevelIdHegrenade        = g_WeaponLevelIndex[index];
            g_WeaponAmmoTypeHegrenade       = KvGetNum(KvWeapon, "ammotype", 0);
        } else if (KvGetNum(KvWeapon, "is_smokegrenade", 0)) {
            g_WeaponIdSmokegrenade          = index;
            g_WeaponAmmoTypeSmokegrenade    = KvGetNum(KvWeapon, "ammotype", 0);
        } else if (KvGetNum(KvWeapon, "is_flashbang", 0)) {
            g_WeaponIdFlashbang             = index;
            g_WeaponAmmoTypeFlashbang       = KvGetNum(KvWeapon, "ammotype", 0);
        } else if (KvGetNum(KvWeapon, "is_molotov", 0)) {
            g_WeaponLevelIdMolotov          = g_WeaponLevelIndex[index];
            g_WeaponAmmoTypeMolotov         = KvGetNum(KvWeapon, "ammotype", 0);
        } else if (KvGetNum(KvWeapon, "is_taser", 0)) {
            g_WeaponIdTaser                 = index;
            g_WeaponLevelIdTaser            = g_WeaponLevelIndex[index];
            g_WeaponAmmoTypeTaser           = KvGetNum(KvWeapon, "ammotype", 0);
        } 

        if ( !KvGotoNextKey(KvWeapon) ) {
            break;
        }
    }

    KvRewind(KvWeapon);

    if (!(  g_WeaponsMaxId
            && g_WeaponIdKnife
            && g_WeaponIdHegrenade
            && g_WeaponIdSmokegrenade
            && g_WeaponIdFlashbang
    )) {
        decl String:Error[1024];
        FormatEx(Error, sizeof(Error), "FATAL ERROR: Some of the weapons not found MAXID=[%i] KNIFE=[%i] HE=[%i] SMOKE=[%i] FLASH=[%i]. You should update you %s and take it from the release zip file.", 
            g_WeaponsMaxId, g_WeaponIdKnife, g_WeaponIdHegrenade, g_WeaponIdSmokegrenade, g_WeaponIdFlashbang, WeaponFile);
        SetFailState(Error);
    }

    if (!(  g_WeaponAmmoTypeHegrenade
            && g_WeaponAmmoTypeFlashbang
            && g_WeaponAmmoTypeSmokegrenade
    )) {
        decl String:Error[1024];
        FormatEx(Error, sizeof(Error), "FATAL ERROR: Some of the ammo types not found HE=[%i] FLASH=[%i] SMOKE=[%i]. You should update you %s and take it from the release zip file.", 
            g_WeaponAmmoTypeHegrenade, g_WeaponAmmoTypeFlashbang, g_WeaponAmmoTypeSmokegrenade, WeaponFile);
        SetFailState(Error);
    }

    if (g_GameName == GameName:Csgo) {
        if (!(  g_WeaponIdTaser
        )) {
            decl String:Error[1024];
            FormatEx(Error, sizeof(Error), "FATAL ERROR: Some of the weapons not found TASER=[%i]. You should update you %s and take it from the release zip file.", 
                g_WeaponIdTaser, WeaponFile);
            SetFailState(Error);
        }
    
        if (!(  g_WeaponAmmoTypeMolotov
                && g_WeaponAmmoTypeTaser
        )) {
            decl String:Error[1024];
            FormatEx(Error, sizeof(Error), "FATAL ERROR: Some of the ammo types not found MOLOTOV=[%i] TASER=[%i]. You should update you %s and take it from the release zip file.", 
                g_WeaponAmmoTypeMolotov, g_WeaponAmmoTypeTaser, WeaponFile);
            SetFailState(Error);
        }
    }
}
