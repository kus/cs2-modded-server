/*
 *  • Manage all the necessary hooks for all the model types to function properly.
 *  • Initializes client global vars that related to models.
 */

#if !defined COMPILING_FROM_MAIN
#error "Attemped to compile from the wrong file"
#endif

void ModelsManagerHooks()
{
	// Called in 'CBasePlayer::Spawn'.
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

// Called on 'OnClientPutInServer()'
void ModelsManagerClientHooks(int client)
{
	// Perform client SDK hooks.
	SDKHook(client, SDKHook_WeaponEquip, Hook_OnWeaponEquip);
	SDKHook(client, SDKHook_WeaponDropPost, Hook_OnWeaponDropPost);
	SDKHook(client, SDKHook_PostThinkPost, Hook_OnPostThinkPost);
}

void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client)
	{
		// Only needs to be initialized here once since CPredictedViewModel entity
		// is created for the client in 'CBasePlayer::Spawn' (`CreateViewModel();`).
		g_Players[client].InitViewModel();
	}
}

// Apply custom view model on weapons.
void ModelsMgr_OnWeaponSwitchPost(int client, int weapon)
{
	// Try to retrieve and validate the weapon customization data.
	// If it failed, that means that there are no customizations applied on this weapon.
	CustomWeaponData custom_weapon_data;
	if (!custom_weapon_data.GetMyself(weapon) || !custom_weapon_data.view_model[0])
	{
		return;
	}
	
	int predicted_view_model = g_Players[client].GetViewModel();
	if (predicted_view_model == -1)
	{
		return;
	}
	
	if (Call_OnModel(client, weapon, CustomWeaponModel_View, custom_weapon_data.view_model) >= Plugin_Handled)
	{
		return;
	}
	
	int precache_index = GetModelPrecacheIndex(custom_weapon_data.view_model);
	if (precache_index == INVALID_STRING_INDEX)
	{
		return;
	}
	
	// Remove the original model.
	SetEntProp(weapon, Prop_Send, "m_nModelIndex", -1);
	
	// Apply the new one.
	SetEntProp(predicted_view_model, Prop_Send, "m_nModelIndex", precache_index);
}

Action Hook_OnWeaponEquip(int client, int weapon)
{
	// Try to retrieve and validate the weapon customization data.
	// If it failed, that means that there are no customizations applied on this weapon.
	CustomWeaponData custom_weapon_data;
	if (!custom_weapon_data.GetMyself(weapon) || !custom_weapon_data.world_model[0])
	{
		return Plugin_Continue;
	}
	
	// A FIX for: Failed to set custom material for 'x', no matching material name found on model y
	// Not really a smart one, the real cause is unknown at the moment.
	if (custom_weapon_data.dropped_model[0] && !IsModelPrecached(custom_weapon_data.dropped_model))
	{
		PrecacheModel(custom_weapon_data.dropped_model);
	}
	
	if (Call_OnModel(client, weapon, CustomWeaponModel_World, custom_weapon_data.world_model) >= Plugin_Handled)
	{
		return Plugin_Continue;
	}
	
	int precache_index = GetModelPrecacheIndex(custom_weapon_data.world_model);
	if (precache_index == INVALID_STRING_INDEX)
	{
		return Plugin_Continue;
	}
	
	int weapon_world_model = GetEntPropEnt(weapon, Prop_Send, "m_hWeaponWorldModel");
	if (weapon_world_model != -1)
	{
		SetEntProp(weapon_world_model, Prop_Send, "m_nModelIndex", precache_index);
	}
	
	return Plugin_Continue;
}

void Hook_OnWeaponDropPost(int client, int weapon)
{
	if (weapon == -1)
	{
		return;
	}
	
	// Too early to override the dropped model here, 
	// do it in the next frame!
	RequestFrame(Frame_SetDroppedModel, EntIndexToEntRef(weapon));
}

void Frame_SetDroppedModel(any weapon_reference)
{
	int weapon = EntRefToEntIndex(weapon_reference);
	if (weapon == -1)
	{
		return;
	}
	
	// Try to retrieve and validate the weapon customization data.
	// If it failed, that means that there are no customizations applied on this weapon.
	CustomWeaponData custom_weapon_data;
	if (!custom_weapon_data.GetMyselfByReference(weapon_reference)
		 || !custom_weapon_data.dropped_model[0]
		 || Call_OnModel(0, weapon, CustomWeaponModel_Dropped, custom_weapon_data.dropped_model) >= Plugin_Handled)
	{
		return;
	}
	
	SetEntityModel(weapon, custom_weapon_data.dropped_model);
}

void Hook_OnPostThinkPost(int client)
{
	static int last_sequecne[MAXPLAYERS + 1];
	static float last_cycle[MAXPLAYERS + 1];
	
	int predicted_view_model = g_Players[client].GetViewModel();
	if (predicted_view_model == -1)
	{
		return;
	}
	
	// Get the client active weapon by 'predicted_view_model'.
	int weapon = GetEntPropEnt(predicted_view_model, Prop_Send, "m_hWeapon");
	if (weapon == -1)
	{
		return;
	}
	
	// Retrieve and validate the entity reference.
	int entity_reference = EntIndexToEntRef(weapon);
	if (entity_reference == -1)
	{
		return;
	}
	
	// Try to retrieve and validate the weapon customization data.
	// If it failed, that means that there are no customizations applied on this weapon.
	CustomWeaponData custom_weapon_data;
	if (!g_CustomWeapons.GetArray(entity_reference, custom_weapon_data, sizeof(custom_weapon_data)))
	{
		return;
	}
	
	char classname[32];
	GetEntityClassname(weapon, classname, sizeof(classname));
	
	static int m_nSequenceOffset, m_flCycleOffset;
	
	if (!m_nSequenceOffset)
	{
		m_nSequenceOffset = FindSendPropInfo("CPredictedViewModel", "m_nSequence");
	}
	
	if (!m_flCycleOffset)
	{
		m_flCycleOffset = FindDataMapInfo(predicted_view_model, "m_flCycle");
	}
	
	int sequence = GetEntData(predicted_view_model, m_nSequenceOffset);
	float cycle = GetEntDataFloat(predicted_view_model, m_flCycleOffset);
	
	if (cycle < last_cycle[client] && sequence == last_sequecne[client])
	{
		int new_sequence = FixSequence(classname, sequence);
		
		SetEntData(predicted_view_model, m_nSequenceOffset, new_sequence);
	}
	
	last_sequecne[client] = sequence;
	last_cycle[client] = cycle;
}

/*
CBaseViewModel *pViewModel = pPlayer->GetViewModel();
if (pViewModel)
{
	int nSequence = pViewModel->LookupSequence("idle");
	if (nSequence != ACTIVITY_NOT_AVAILABLE)
	{
		pViewModel->ForceCycle(0);
		pViewModel->ResetSequence(nSequence);
	}
}
*/

// Credit for FPVMI, should find a better solution.
stock int FixSequence(char[] classname, int sequence)
{
	if (StrEqual(classname, "weapon_knife"))
	{
		switch (sequence)
		{
			case 3:return 4;
			case 4:return 3;
			case 5:return 6;
			case 6:return 5;
			case 7:return 8;
			case 8:return 7;
			case 9:return 10;
			case 10:return 11;
			case 11:return 10;
		}
	}
	else if (StrEqual(classname, "weapon_ak47"))
	{
		switch (sequence)
		{
			case 3:return 2;
			case 2:return 1;
			case 1:return 3;
		}
	}
	else if (StrEqual(classname, "weapon_mp7"))
	{
		switch (sequence)
		{
			case 3:return -1;
		}
	}
	else if (StrEqual(classname, "weapon_awp"))
	{
		switch (sequence)
		{
			case 1:return -1;
		}
	}
	else if (StrEqual(classname, "weapon_deagle"))
	{
		switch (sequence)
		{
			case 3:return 2;
			case 2:return 1;
			case 1:return 3;
		}
	}
	
	return sequence;
} 