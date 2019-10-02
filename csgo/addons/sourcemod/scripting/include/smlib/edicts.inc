#if defined _smlib_edicts_included
	#endinput
#endif
#define _smlib_edicts_included

#include <sourcemod>
#include <smlib/entities>

/*
 * Finds an edict by it's name
 * It only finds the first occurence.
 *
 * @param name			Name of the entity you want so search.
 * @return				Edict Index or INVALID_ENT_REFERENCE if no entity was found.
 */
stock Edict_FindByName(const String:name[])
{
	new maxEntities = GetMaxEntities();
	for (new edict=0; edict < maxEntities; edict++) {
		
		if (!IsValidEdict(edict)) {
			continue;
		}

		if (Entity_NameMatches(edict, name)) {
			return edict;
		}
	}

	return INVALID_ENT_REFERENCE;
}

/*
 * Finds an edict by its HammerID.
 * The newer version of Valve's Hammer editor
 * sets a unique ID for each entity in a map.
 * It only finds the first occurence.
 *
 * @param hammerId		Hammer editor ID
 * @return				Edict Index or INVALID_ENT_REFERENCE if no entity was found.
 */
stock Edict_FindByHammerId(hammerId)
{
	new maxEntities = GetMaxEntities();
	for (new edict=0; edict < maxEntities; edict++) {
		
		if (!IsValidEdict(edict)) {
			continue;
		}
		
		if (Entity_GetHammerId(edict) == hammerId) {
			return edict;
		}
	}

	return INVALID_ENT_REFERENCE;
}

/**
 * Searches for the closest edict in relation to the given origin
 *
 * @param vecOrigin_center	3 dimensional origin array
 * @param clientsOnly		True if you only want to search for clients
 * @param ignoreEntity		Ignore this entity
 * @return					Edict Index or INVALID_ENT_REFERENCE if no entity was found.
 */
stock Edict_GetClosest(Float:vecOrigin_center[3], bool:clientsOnly=false, ignoreEntity=-1)
{	
	decl Float:vecOrigin_edict[3];
	new Float:smallestDistance = 0.0;
	new closestEdict = INVALID_ENT_REFERENCE;
	
	new maxEntities;
	
	if (clientsOnly) {
		maxEntities = MaxClients;
	}
	else {
		maxEntities = GetMaxEntities();
	}

	for (new edict=1; edict <= maxEntities; edict++) {
		
		if (!IsValidEdict(edict)) {
			continue;
		}
		
		if (ignoreEntity >= 0 && edict == ignoreEntity) {
			continue;
		}
			
		if (GetEntSendPropOffs(edict, "m_vecOrigin") == -1) {
			continue;
		}

		Entity_GetAbsOrigin(edict, vecOrigin_edict);
		
		new Float:edict_distance = GetVectorDistance(vecOrigin_center, vecOrigin_edict, true);
		
		if (edict_distance < smallestDistance || smallestDistance == 0.0) {
			smallestDistance = edict_distance;
			closestEdict = edict;
		}
	}
	
	return closestEdict;
}

/**
 * Searches for the closest edict in relation to the given edict.
 *
 * @param edict				Edict index
 * @param clientsOnly		True if you only want to search for clients
 * @return					The closest edict or INVALID_ENT_REFERENCE
 */
stock Edict_GetClosestToEdict(edict, bool:clientsOnly=false)
{	
	decl Float:vecOrigin[3];
	
	if (GetEntSendPropOffs(edict, "m_vecOrigin") == -1) {
		return INVALID_ENT_REFERENCE;
	}
	
	Entity_GetAbsOrigin(edict, vecOrigin);

	return Edict_GetClosest(vecOrigin, clientsOnly, edict);
}
