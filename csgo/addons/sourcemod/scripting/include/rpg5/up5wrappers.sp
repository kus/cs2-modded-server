_Wrappers_OnPluginStart()
{
	RegConsoleCmd("heal", Survivor_BuyInstantHeal);
	RegConsoleCmd("incap", Survivor_BuyIncapProtection);

	HookEvent("tank_spawn", Event_TankSpawn);
}

stock bool:IsHuman(client)
{
	if (!IsClientIndexOutOfRange(client) && IsClientInGame(client) && !IsFakeClient(client)) return true;
	else return false;
}

public Action:Survivor_BuyInstantHeal(client, args)
{
	if (IsClientIndexOutOfRange(client)) return;
	if (GetClientTeam(client) != 2 || !IsPlayerAlive(client)) return;
	if (L4D2_GetInfectedAttacker(client) != -1 && IsIncapacitated(client))
	{
		PrintToChat(client, "%s \x01You are ensnared and incapped! Healing would kill you!", ERROR_INFO);
		return;
	}
	Ensnared[client] = false;
	ItemName[client] = "health";
	PurchaseItem[client] = 2;
	SurvivorPurchaseFunc(client);
}

public Action:Survivor_BuyIncapProtection(client, args)
{
	if (IsClientIndexOutOfRange(client)) return;
	if (GetClientTeam(client) != 2 || !IsPlayerAlive(client)) return;
	if (IncapProtection[client] == -1)
	{
		PrintToChat(client, "%s \x01Incap Protection is on cooldown.", ERROR_INFO);
		return;
	}
	if (IncapProtection[client] > 0)
	{
		PrintToChat(client, "%s \x01still have \x05%d \x01uses remaining.", ERROR_INFO, IncapProtection[client]);
		return;
	}
	ItemName[client] = "incap_protection";
	PurchaseItem[client] = 2;
	SurvivorPurchaseFunc(client);
}

/*	*
	*
	* Print a message to all survivor players.
	*
	*
	*/

stock PrintToSurvivors(const String:format[], any:...)
{
	decl String:buffer[1024];
	VFormat(buffer, sizeof(buffer), format, 2);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i)) continue;
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 2) continue;
		PrintToChat(i, buffer);
	}
}

/*	*
	*
	* Print a message to all infected players.
	*
	*
	*/

stock PrintToInfected(const String:format[], any:...)
{
	decl String:buffer[1024];
	VFormat(buffer, sizeof(buffer), format, 2);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i)) continue;
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 3) continue;
		PrintToChat(i, buffer);
	}
}

/*	*
	*
	* Allows a client to execute a cheat command, such as give, z_spawn, and so on.
	*
	*
	*/

ExecCheatCommand(client = 0,const String:command[],const String:parameters[] = "")
{
	new iFlags = GetCommandFlags(command);
	SetCommandFlags(command,iFlags & ~FCVAR_CHEAT);

	if(IsClientIndexOutOfRange(client) || !IsClientInGame(client) || IsFakeClient(client))
	{
		ServerCommand("%s %s",command,parameters);
	}
	else
	{
		FakeClientCommand(client,"%s %s",command,parameters);
	}

	SetCommandFlags(command,iFlags);
	SetCommandFlags(command,iFlags|FCVAR_CHEAT);
}

/*	*
	*
	* Checks to see if the client is incapacitated
	*
	*
	*/

stock bool:IsIncapacitated(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

BlindPlayer(client, amount)
{
	if (IsClientIndexOutOfRange(client)) return;
	if (!IsClientInGame(client) || IsFakeClient(client)) return;
	new clients[2];
	clients[0] = client;

	BlindMsgID = GetUserMessageId("Fade");
	new Handle:message = StartMessageEx(BlindMsgID, clients, 1);
	BfWriteShort(message, 1536);
	BfWriteShort(message, 1536);
	
	if (amount == 0)
	{
		BfWriteShort(message, (0x0001 | 0x0010));
	}
	else
	{
		BfWriteShort(message, (0x0002 | 0x0008));
	}
	
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	BfWriteByte(message, 0);
	BfWriteByte(message, amount);
	
	EndMessage();
}

bool:LockedWeaponUsed(attacker)
{
	if (IsClientIndexOutOfRange(attacker)) return true;
	if (!IsClientInGame(attacker) || IsFakeClient(attacker)) return true;
	new String:WeaponUsed[64];
	GetClientWeapon(attacker, WeaponUsed, sizeof(WeaponUsed));
	
	if ((StrEqual(WeaponUsed, "weapon_pistol_magnum", true) && PistolLevel[attacker] < GetConVarInt(PistolDeagleLevel)) || 
		(StrEqual(WeaponUsed, "weapon_smg", true) && (UziLevel[attacker] < GetConVarInt(UziMp5Level) || PhysicalLevel[attacker] < GetConVarInt(UziLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_smg_silenced", true) && (UziLevel[attacker] < GetConVarInt(UziTmpLevel) || PhysicalLevel[attacker] < GetConVarInt(UziLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_smg_mp5", true) && (UziLevel[attacker] < GetConVarInt(UziMp5Level) || PhysicalLevel[attacker] < GetConVarInt(UziLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_autoshotgun", true) && (ShotgunLevel[attacker] < GetConVarInt(ShotgunAutoLevel) || PhysicalLevel[attacker] < GetConVarInt(ShotgunLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_pumpshotgun", true) && (ShotgunLevel[attacker] < GetConVarInt(ShotgunPumpLevel) || PhysicalLevel[attacker] < GetConVarInt(ShotgunLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_shotgun_chrome", true) && (ShotgunLevel[attacker] < GetConVarInt(ShotgunChromeLevel) || PhysicalLevel[attacker] < GetConVarInt(ShotgunLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_shotgun_spas", true) && (ShotgunLevel[attacker] < GetConVarInt(ShotgunSpasLevel) || PhysicalLevel[attacker] < GetConVarInt(ShotgunLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_rifle", true) && (RifleLevel[attacker] < GetConVarInt(RifleM16Level) || PhysicalLevel[attacker] < GetConVarInt(RifleLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_rifle_ak47", true) && (RifleLevel[attacker] < GetConVarInt(RifleAK47Level) || PhysicalLevel[attacker] < GetConVarInt(RifleLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_rifle_desert", true) && (RifleLevel[attacker] < GetConVarInt(RifleDesertLevel) || PhysicalLevel[attacker] < GetConVarInt(RifleLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_rifle_m60", true) && (RifleLevel[attacker] < GetConVarInt(RifleM60Level) || PhysicalLevel[attacker] < GetConVarInt(RifleLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_rifle_sg552", true) && (RifleLevel[attacker] < GetConVarInt(RifleSG552Level) || PhysicalLevel[attacker] < GetConVarInt(RifleLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_sniper_awp", true) && (SniperLevel[attacker] < GetConVarInt(SniperAwpLevel) || PhysicalLevel[attacker] < GetConVarInt(SniperLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_sniper_scout", true) && (SniperLevel[attacker] < GetConVarInt(SniperScoutLevel) || PhysicalLevel[attacker] < GetConVarInt(SniperLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_sniper_military", true) && (SniperLevel[attacker] < GetConVarInt(SniperMilitaryLevel) || PhysicalLevel[attacker] < GetConVarInt(SniperLevelUnlock))) || 
		(StrEqual(WeaponUsed, "weapon_hunting_rifle", true) && (SniperLevel[attacker] < GetConVarInt(SniperHuntingLevel) || PhysicalLevel[attacker] < GetConVarInt(SniperLevelUnlock))))
	{
		// If the player is using a gun they haven't unlocked, we don't let them use the custom ammo type.
		// They might have it for that weapon category because they purchased it on another weapon they do have
		// unlocked in that weapon category, and then tried to switch weapons.
		// So we stop them from exploiting that here.
		return true;
	}
	else return false;
}

stock bool:IsClientIndexOutOfRange(client)
{
	if (client <= 0 || client > MaxClients) return true;
	else return false;
}

public Action:CheckBlackWhite(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientIndexOutOfRange(i)) continue;
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 2 || !IsPlayerAlive(i) || Ensnared[i]) continue;
		if (VipName == i)
		{
			if (GetEntProp(i, Prop_Send, "m_currentReviveCount") >= 2 && IncapProtection[i] < 1)
			{
				SetEntityRenderMode(i, RENDER_TRANSCOLOR);
				SetEntityRenderColor(i, GetConVarInt(VipColor[0]), GetConVarInt(VipColor[1]), GetConVarInt(VipColor[2]), 200);
			}
			else
			{
				SetEntityRenderMode(i, RENDER_TRANSCOLOR);
				SetEntityRenderColor(i, GetConVarInt(VipColor[0]), GetConVarInt(VipColor[1]), GetConVarInt(VipColor[2]), 255);
			}
		}
		else if (GetEntProp(i, Prop_Send, "m_currentReviveCount") >= 2 && IncapProtection[i] < 1)
		{
			SetEntityRenderMode(i, RENDER_TRANSCOLOR);
			SetEntityRenderColor(i, GetConVarInt(BlackWhiteColor[0]), GetConVarInt(BlackWhiteColor[1]), GetConVarInt(BlackWhiteColor[2]), 255);
		}
		else
		{
			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i, 255, 255, 255, 255);
		}
	}
}

stock PrintToAdmins(const String:format[], any:...)
{
	decl String:buffer[1024];
	VFormat(buffer, sizeof(buffer), format, 2);
	for (new i = 1; i <= MaxClients;i++)
	{
		if (!IsClientInGame(i)) continue;
		if (IsFakeClient(i)) continue;
		new flags = GetUserFlagBits(i);
		if (!(flags & ADMFLAG_ROOT || flags & ADMFLAG_GENERIC)) continue;

		PrintToChat(i, buffer);
	}
}

stock CreateFireEx(client)
{
	if (IsClientIndexOutOfRange(client)) return;
	if (!IsClientInGame(client) || IsFakeClient(client)) return;
	decl Float:BombOrigin[3];
	GetClientAbsOrigin(client, BombOrigin);
	CreateFire(BombOrigin);
}

public Hook_SpawnAnywhere(victim)
{
	if (IsClientIndexOutOfRange(victim)) return;
	if (!SpawnAnywhere[victim] || !IsPlayerGhost(victim)) return;
	SetEntProp(victim, Prop_Send, "m_ghostSpawnState", 0);
}

stock bool:IsPlayerGhost(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isGhost", 1);
}

static const String:MODEL_GASCAN[] = "models/props_junk/gascan001a.mdl";

stock CreateFire(const Float:BombOrigin[3])
{
	new entity = CreateEntityByName("prop_physics");
	DispatchKeyValue(entity, "physdamagescale", "0.0");
	if (!IsModelPrecached(MODEL_GASCAN))
	{
		PrecacheModel(MODEL_GASCAN);
	}
	DispatchKeyValue(entity, "model", MODEL_GASCAN);
	DispatchSpawn(entity);
	TeleportEntity(entity, BombOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(entity, MOVETYPE_VPHYSICS);
	AcceptEntityInput(entity, "Break");
}

public Action:SurvivorRespawnTimer(Handle:timer)
{
	static Float:count = -1.0;
	if (count == -1.0) count = GetConVarFloat(SurvivorRespawnQueue);
	if (count > 0.0)
	{
		count -= 1.0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientIndexOutOfRange(i)) continue;
			if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != 2 || RespawnType[i] == 0 || IsPlayerAlive(i)) continue;
			PrintHintText(i, "survivors will respawn in\n%2.1f second(s).", count);
			if (RescueCalled)
			{
				RespawnType[i] = 0;
				PrintHintText(i, "Finale has begun!\nRespawn cancelled.");
			}
		}
		return Plugin_Continue;
	}
	if (count < 2.0)
	{
		count = GetConVarFloat(SurvivorRespawnQueue);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientIndexOutOfRange(i)) continue;
			if (!IsClientInGame(i) || IsFakeClient(i) || 
				GetClientTeam(i) != 2 || RespawnType[i] == 0 || IsPlayerAlive(i)) continue;
			if (RespawnType[i] == 1) respawnatstart(i);
			else respawnatcorpse(i);
			RespawnType[i] = 0;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

respawnatstart(i)
{
	if (IsClientIndexOutOfRange(i)) return;
	if (!IsClientInGame(i) || IsFakeClient(i) || IsPlayerAlive(i)) return;
	SDKCall(hRoundRespawn, i);
	if (!StrEqual(LastWeaponOwned[i], "none", false)) ExecCheatCommand(i, "give", LastWeaponOwned[i]);
	ExecCheatCommand(i, "upgrade_add", "LASER_SIGHT");
}

respawnatcorpse(i)
{
	if (IsClientIndexOutOfRange(i)) return;
	if (!IsClientInGame(i) || IsFakeClient(i) || IsPlayerAlive(i)) return;
	SDKCall(hRoundRespawn, i);
	TeleportEntity(i, Float:SurvivorDeathSpot[i], NULL_VECTOR, NULL_VECTOR);
	if (!StrEqual(LastWeaponOwned[i], "none", false)) ExecCheatCommand(i, "give", LastWeaponOwned[i]);
	ExecCheatCommand(i, "upgrade_add", "LASER_SIGHT");
}

public Action:L4D_OnSpawnTank(const Float:vector[3], const Float:qangle[3])
{
	// Don't let the director spawn a tank if it's versus.
	return Plugin_Handled;
}

public Action:Event_TankSpawn(Handle:event, String:event_name[], bool:dontBroadcast)
{
	decl String:GameTypeVote[256];
	GetConVarString(FindConVar("mp_gamemode"), GameTypeVote, 256);
	if (!StrEqual(GameTypeVote, "realism")) return Plugin_Handled;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientIndexOutOfRange(client)) return Plugin_Handled;
	if (!IsFakeClient(client)) return Plugin_Handled;

	SetEntityHealth(client, 100000);
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, GetConVarInt(InfectedTier4Color[0]), GetConVarInt(InfectedTier4Color[1]), GetConVarInt(InfectedTier4Color[2]), 200);
	SetEntDataFloat(client, laggedMovementOffset, 1.0, true);
	return Plugin_Handled;
}