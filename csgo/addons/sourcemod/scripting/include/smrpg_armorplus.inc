#if defined _smrpg_armorplus_included
  #endinput
#endif
#define _smrpg_armorplus_included

/** Default maximal armor in Counter-Strike */
#define DEFAULT_MAX_ARMOR 100

/** Technical maximal armor value in Counter-Strike */
#define CS_MAX_ARMOR 127 // m_ArmorValue is a signed byte

/**
 * Get the maximal health for a client.
 * Returns the default maxhealth value, if client doesn't have the health upgrade or SM:RPG is disabled.
 *
 * @param client  The client whos maxhealth you want to know.
 * @return        The client's maxhealth depending on his SM:RPG maxhealth level.
 */
native int SMRPG_Armor_GetClientMaxArmorEx(int client);

/**
 * Get the maximal health for a client, if the smrpg_upgrade_health plugin is loaded.
 * Returns the default maxhealth value, if smrpg_upgrade_health is not laded.
 *
 * @param client  The client whos maxhealth you want to know.
 * @return        The client's maxhealth depending on his SM:RPG maxhealth level, or default maxhealth, if SM:RPG unavailable.
 */
stock int SMRPG_Armor_GetClientMaxArmor(int client)
{
	// Use Armor+ maxlevel, if available.
	if(GetFeatureStatus(FeatureType_Native, "SMRPG_Armor_GetClientMaxArmorEx") == FeatureStatus_Available)
		return SMRPG_Armor_GetClientMaxArmorEx(client);
	
	return DEFAULT_MAX_ARMOR;
}

public SharedPlugin __pl_smrpg_armorplus = 
{
	name = "smrpg_armorplus",
	file = "smrpg_upgrade_armorplus_cstrike.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_smrpg_armorplus_SetNTVOptional()
{
	MarkNativeAsOptional("SMRPG_Armor_GetClientMaxArmorEx");
}
#endif