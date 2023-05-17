/***************************************************************************
 *                                                                         *
 *                      BoneMerge Workaround                               *
 *                     Author: Master Xykon                                *
 *                         Version: 1.0.0                                  *
 *                                                                         *
 **************************************************************************/
 
#include <tf2>
#include <tf2_stocks>

  #if defined _attachments_included
 #endinput
#endif
#define _attachments_included

// ---- Engine flags ---------------------------------------------------------------
#define EF_BONEMERGE            (1 << 0)
#define EF_NOSHADOW             (1 << 4)
#define EF_BONEMERGE_FASTCULL   (1 << 7)
#define EF_PARENT_ANIMATES      (1 << 9)

new Handle:attachments_array = INVALID_HANDLE;
new gItem[MAXPLAYERS+1];
new bool:delete_enabled[MAXPLAYERS+1] = false;
new gLink[MAXPLAYERS+1];

new bool:g_bSdkStarted = false;
new Handle:g_hSdkEquipWearable;
new Handle:g_hSdkRemoveWearable;

/** 
 * Attaches a child to a parent.
 * 
 * @param child      Child entity. 
 * @param parent        Parent entity. 
 * @param variant      Attachment point. Empty for none. 
 * @return            True if able to create attachment. False if fail.
 *  
 * On error/Errors:  If unable to create attachment.
 */ 
stock CAttach(child, parent, client, String:modelname[]) {
    if (attachments_array == INVALID_HANDLE) attachments_array = CreateArray(2);
    if (!IsValidEntity(child)) return false;
    if (!IsValidEntity(parent)) return false;
    new link = CGetLink(child);
    if (link == -1 || !IsValidEntity(link)) link = CAddLink(child, client);
    if (link == -1 || !IsValidEntity(link)) {
        decl String:Classname[128];
        if (GetEdictClassname(child, Classname, sizeof(Classname))) ThrowError("Unable to create link for entity %s", Classname);
        else ThrowError("Unable to create link for unknown entity");
        return false;
    }
    
    new String:name[16];
    Format(name, sizeof(name), "target%i", parent);
    DispatchKeyValue(parent, "targetname", name);

    new String:name2[32];
    GetEntPropString(parent, Prop_Data, "m_iName", name2, sizeof(name2));
    DispatchKeyValue(link, "parentname", name2);
    
    
    SetVariantString(name2);
    AcceptEntityInput(link, "SetParent", link, link, 0);
    
    SetVariantString("head");
    AcceptEntityInput(link, "SetParentAttachment", link, link, 0);
    
    return true;
}

/** 
 * Detaches an entity from all its parents. Should be called before the entity is killed.
 * 
 * @param ent          Entity to detach. 
 * @return            True if an attachment is destroyed. False if no attachment.
 *  
 * On error/Errors:  Never.
 */ 
stock CDetach(ent) {
    if (attachments_array == INVALID_HANDLE) attachments_array = CreateArray(2);
    
    if (!IsValidEntity(ent)) return false;
    
    new link = CGetLink(ent);
    if (link != -1) {
        AcceptEntityInput(ent, "SetParent", -1, -1, 0);
        if (IsValidEntity(link)) AcceptEntityInput(link, "kill");
        for (new i = 0; i < GetArraySize(attachments_array); i++) {
            new ent2 = GetArrayCell(attachments_array, i);
            if (ent == ent2) RemoveFromArray(attachments_array, i);
        }
        
        return true;
    }
    return false;
}

stock CGetLink(ent) {
    for (new i = 0; i < GetArraySize(attachments_array); i++) {
        new ent2 = GetArrayCell(attachments_array, i);
        if (ent == ent2) return (GetArrayCell(attachments_array, i, 1));
    }
    return -1;
}

stock CAddLink(ent, client) {
    new String:name_ent[16]; 
    Format(name_ent, sizeof(name_ent), "target%i", ent);
    DispatchKeyValue(ent, "targetname", name_ent);

    new link = CreateEntityByName("prop_dynamic_override");
    if (IsValidEntity(link)) {
        new String:name_link[16]; 
        Format(name_link, sizeof(name_link), "target%i", link);
        DispatchKeyValue(link, "targetname", name_link);
        
        DispatchKeyValue(link, "classname", "prop_dynamic_override");
        DispatchKeyValue(link, "spawnflags", "1");
        SetEntPropFloat(link, Prop_Send, "m_flModelScale", 0.000000001);
        
        SetEntProp(link, Prop_Send, "m_CollisionGroup",    11);
        
        SetEntProp(link, Prop_Send, "m_fEffects",               EF_BONEMERGE|EF_NOSHADOW|EF_PARENT_ANIMATES);
        
        decl String:m_szModelName[PLATFORM_MAX_PATH];
        GetEntPropString(client, Prop_Data, "m_ModelName", STRING(m_szModelName));
        SetEntityModel(link, m_szModelName);
        
        new m_iTeam = GetClientTeam(client);
        SetEntProp(link, Prop_Send, "m_nSkin",  (m_iTeam-2));
        
        SetEntityRenderMode(link, RENDER_NONE);
        AcceptEntityInput(link, "TurnOff", link, link, 0);
        
        SetVariantString(name_link);
        AcceptEntityInput(ent, "SetParent", ent, ent, 0);
        
        SetVariantString("head");
        AcceptEntityInput(ent, "SetParentAttachment", ent, ent, 0);
        
        return link;
    }
    return -1;
}

stock Attachable_CreateAttachable(client, parent, String:modelname[])
{
    new m_iTeam = GetClientTeam(client);
    gItem[client] = CreateEntityByName("prop_dynamic_override");
    
    if (IsValidEdict(gItem[client]))
    {
        SetEntProp(gItem[client], Prop_Send, "m_nSkin",             (m_iTeam-2));
        SetEntProp(gItem[client], Prop_Send, "m_CollisionGroup",       11);
        
        SetEntProp(gItem[client], Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_PARENT_ANIMATES);
        
        DispatchKeyValue(gItem[client], "model", modelname);
        
        DispatchSpawn(gItem[client]);
        ActivateEntity(gItem[client]);
        AcceptEntityInput(gItem[client], "Start");
        
        CAttach(gItem[client], parent, client, modelname);
        
        delete_enabled[client] = true;
    }
    
    return gItem[client];
}

stock Attachable_UnhookEntity(client, ent)
{
    if (delete_enabled[client] == true)
    {
        CDetach(ent);
        AcceptEntityInput(ent, "KillHierarchy");
    }
}

stock TF2_SpawnWearable(iOwner, iDef=138, iLevel=22, iQuality=9)
{
    new m_iTeam = GetClientTeam(iOwner);
    new iItem = CreateEntityByName("tf_wearable");
    
    if (IsValidEdict(iItem))
    {
        //SetEntProp(iItem, Prop_Send, "m_bInitialized", 1);    // Disabling this avoids the crashes related to spies
        // disguising as someone with hat in Windows.
        
        // Using reference data from Batter's Helmet. Thanks to MrSaturn.
        SetEntProp(iItem, Prop_Send, "m_fEffects",           EF_BONEMERGE|EF_NOSHADOW|EF_PARENT_ANIMATES);
        SetEntProp(iItem, Prop_Send, "m_iTeamNum",           m_iTeam);
        SetEntProp(iItem, Prop_Send, "m_nSkin",             (m_iTeam-2));
        SetEntProp(iItem, Prop_Send, "m_CollisionGroup",       11);
        SetEntProp(iItem, Prop_Send, "m_iItemDefinitionIndex", iDef);
        SetEntProp(iItem, Prop_Send, "m_iEntityLevel",       iLevel);
        SetEntProp(iItem, Prop_Send, "m_iEntityQuality",       iQuality);
        
        // Spawn.
        DispatchSpawn(iItem);
    }
    
    return iItem;
}

stock TF2_EquipWearable(iOwner, iItem)
{
    if (g_bSdkStarted == false) TF2_SdkStartup();
    
    SDKCall(g_hSdkEquipWearable, iOwner, iItem);
}

stock TF2_SdkStartup()
{
    
    new Handle:hGameConf = LoadGameConfigFile("TF2_EquipmentManager");
    if (hGameConf != INVALID_HANDLE)
    {
        StartPrepSDKCall(SDKCall_Player);
        PrepSDKCall_SetFromConf(hGameConf,SDKConf_Virtual,"EquipWearable");
        PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
        g_hSdkEquipWearable = EndPrepSDKCall();
        
        StartPrepSDKCall(SDKCall_Player);
        PrepSDKCall_SetFromConf(hGameConf,SDKConf_Virtual,"RemoveWearable");
        PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
        g_hSdkRemoveWearable = EndPrepSDKCall();
        
        CloseHandle(hGameConf);
        g_bSdkStarted = true;
    } else {
        SetFailState("Couldn't load SDK functions (TF2_EquipmentManager).");
    }
}