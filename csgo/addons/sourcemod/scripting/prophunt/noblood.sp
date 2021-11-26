public Action TE_OnEffectDispatch(const char[] te_name, const Players[], int numClients, float delay)
{
	if(!Ready())
		return Plugin_Continue;
	
	int iEffectIndex = TE_ReadNum("m_iEffectName");
	
	switch(iEffectIndex)
	{
		case 1: return Plugin_Handled; // Bullet hit effect
		case 4: return Plugin_Handled; // Knife hit effect
		case 33: return Plugin_Handled; // Bullet hit effect
	}
	
	char sEffectName[64];

	GetEffectName(iEffectIndex, sEffectName, sizeof(sEffectName));
	
	// Blood effect
	if(StrEqual(sEffectName, "csblood"))
		return Plugin_Handled;
	
	if(StrEqual(sEffectName, "ParticleEffect"))
	{
		int nHitBox = TE_ReadNum("m_nHitBox");
		
		char sParticleEffectName[64];
		GetParticleEffectName(nHitBox, sParticleEffectName, sizeof(sParticleEffectName));
		
		// Impect effect
		if(StrEqual(sParticleEffectName, "impact_helmet_headshot") || StrEqual(sParticleEffectName, "impact_physics_dust"))
			return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action TE_OnWorldDecal(const char[] te_name, const Players[], int numClients, float delay)
{
	if(!Ready())
		return Plugin_Continue;
	
	int nIndex = TE_ReadNum("m_nIndex");

	float vecOrigin[3];
	TE_ReadVector("m_vecOrigin", vecOrigin);
	char sDecalName[64];
	GetDecalName(nIndex, sDecalName, sizeof(sDecalName));
	
	// Blood texture
	if(StrContains(sDecalName, "decals/blood") == 0 && StrContains(sDecalName, "_subrect") != -1)
		return Plugin_Handled;

	return Plugin_Continue;
}