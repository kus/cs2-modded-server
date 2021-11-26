void StartNoBlockTimer()
{
	CreateTimer(0.5, Timer_NoBlock, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_NoBlock(Handle timer)
{
	if(!Ready())
		return Plugin_Continue;
	
	if(g_iRoundStart == 0)
		return Plugin_Continue;
	
	LoopAlivePlayers(iClient)
	{
		bool bStuck;
		
		// IF player is solid and not stuck, continue
		if(Entity_GetCollisionGroupEx(iClient) ==  COLLISION_GROUP_PLAYER && !(bStuck = IsPlayerStuck(iClient)))
			continue;
		
		if(bStuck)
			Entity_SetPushable(iClient); // Set pushable if stuck to push the other players away
		else Entity_SetBlockable(iClient); // If player is not stuck give back collision
	}
	
	return Plugin_Continue;
}

public void OnEntityCreated(int iEntity, const char[] classname)
{
	if(!Ready())
		return;
	
	// Prevent stucking inside grenades
	if (StrContains(sProjectiles, classname) != -1)
		Entity_SetNoblockable(iEntity);
}

void Entity_SetBlockable(int iEntity)
{
	Entity_SetCollisionGroupEx(iEntity, COLLISION_GROUP_PLAYER);
}

void Entity_SetNoblockable(int iEntity)
{
	Entity_SetCollisionGroupEx(iEntity, COLLISION_GROUP_DEBRIS_TRIGGER);
}

void Entity_SetPushable(int iEntity)
{
	Entity_SetCollisionGroupEx(iEntity, COLLISION_GROUP_PUSHAWAY);
}

void Entity_SetCollisionGroupEx(int iEntity, int colGroup)
{
	static int iColGroup = -1;
	
	if(iColGroup == -1)
		iColGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	SetEntData(iEntity, iColGroup, colGroup, _, true);
}

int Entity_GetCollisionGroupEx(int iEntity)
{
	static int iColGroup = -1;
	
	if(iColGroup == -1)
		iColGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	return GetEntData(iEntity, iColGroup);
}