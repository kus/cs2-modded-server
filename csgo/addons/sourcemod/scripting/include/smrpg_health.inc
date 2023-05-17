#if defined _smrpg_health_included
  #endinput
#endif
#define _smrpg_health_included

/**
 * Get the maximal health for a client.
 * Returns the default maxhealth value, if client doesn't have the health upgrade or SM:RPG is disabled.
 *
 * @param client  The client whos maxhealth you want to know.
 * @return        The client's maxhealth depending on his SM:RPG maxhealth level.
 */
native int SMRPG_Health_GetClientMaxHealthEx(int client);

/**
 * Get the maximal health for a client, if the smrpg_upgrade_health plugin is loaded.
 * Returns the default maxhealth value, if smrpg_upgrade_health is not laded.
 *
 * @param client  The client whos maxhealth you want to know.
 * @return        The client's maxhealth depending on his SM:RPG maxhealth level, or default maxhealth, if SM:RPG unavailable.
 */
stock int SMRPG_Health_GetClientMaxHealth(int client)
{
	// Use Health+ maxlevel, if available.
	if(GetFeatureStatus(FeatureType_Native, "SMRPG_Health_GetClientMaxHealthEx") == FeatureStatus_Available)
		return SMRPG_Health_GetClientMaxHealthEx(client);
	
	return GetEntProp(client, Prop_Data, "m_iMaxHealth");
}

public SharedPlugin __pl_smrpg_health = 
{
	name = "smrpg_health",
	file = "smrpg_upgrade_health.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_smrpg_health_SetNTVOptional()
{
	MarkNativeAsOptional("SMRPG_Health_GetClientMaxHealthEx");
}
#endif