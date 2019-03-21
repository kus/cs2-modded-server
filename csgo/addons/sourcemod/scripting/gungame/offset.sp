OnOffsetStart()
{
    decl String:Error[64];
    
    g_iOffsetAmmo = FindSendPropInfo("CBasePlayer", "m_iAmmo");
    if (g_iOffsetAmmo == INVALID_OFFSET) {
        SetFailState("FATAL ERROR: Offset \"CBasePlayer::m_iAmmo\" was not found.");
    }

    OffsetMovement = FindSendPropOffs("CBasePlayer", "m_flLaggedMovementValue");
    if(OffsetMovement == INVALID_OFFSET)
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR OffsetMovement [%d]. Please contact the author.", OffsetMovement);
        SetFailState(Error);
    }

    m_hMyWeapons = FindSendPropOffs("CBasePlayer", "m_hMyWeapons");
    if(m_hMyWeapons == INVALID_OFFSET)
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR m_hMyWeapons [%d]. Please contact the author.", m_hMyWeapons);
        SetFailState(Error);
    }

    OffsetWeaponParent = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");
    if ( OffsetWeaponParent == INVALID_OFFSET )
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR OffsetWeaponParent [%d]. Please contact the author.", OffsetWeaponParent);
        SetFailState(Error);
    }
    
    g_iOffs_iPrimaryAmmoType = FindSendPropInfo("CBaseCombatWeapon","m_iPrimaryAmmoType");
    if ( g_iOffs_iPrimaryAmmoType == INVALID_OFFSET )
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR g_iOffs_iPrimaryAmmoType [%d]. Please contact the author.", g_iOffs_iPrimaryAmmoType);
        SetFailState(Error);
    }
    
    FindCstrikeOffset();

    /**
     * More research need to be done for the other mods.
     * Golden:S might be good. Not sure of DoD:S
     * FindDoDOffset();
     * FindGSOffset();
     */
}

FindCstrikeOffset()
{
    decl String:Error[64];

    OffsetHostage = FindSendPropOffs("CCSPlayerResource", "m_iHostageEntityIDs");

    if(OffsetHostage == INVALID_OFFSET)
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR OffsetHostage [%d]. Please contact the author.", OffsetHostage);
        SetFailState(Error);
    }

    new String:CCSPlayer[] = "CCSPlayer";
    //Offsets
    OffsetMoney = FindSendPropOffs(CCSPlayer, "m_iAccount");

    if(OffsetMoney == INVALID_OFFSET)
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR OffsetMoney [%d]. Please contact the author.", OffsetMoney);
        SetFailState(Error);
    }

    OffsetArmor = FindSendPropOffs(CCSPlayer, "m_ArmorValue");

    if(OffsetArmor == INVALID_OFFSET)
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR OffsetArmor [%d]. Please contact the author.", OffsetArmor);
        SetFailState(Error);
    }

    OffsetHelm = FindSendPropOffs(CCSPlayer, "m_bHasHelmet");

    if(OffsetHelm == INVALID_OFFSET)
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR OffsetHelm [%d]. Please contact the author.", OffsetHelm);
        SetFailState(Error);
    }

    OffsetDefuser = FindSendPropOffs(CCSPlayer, "m_bHasDefuser");

    if(OffsetDefuser == INVALID_OFFSET)
    {
        FormatEx(Error, sizeof(Error), "FATAL ERROR OffsetDefuser [%d]. Please contact the author.", OffsetDefuser);
        SetFailState(Error);
    }
}
