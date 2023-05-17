experience_medical_increase(attacker, value)
{
	if (!IsHuman(attacker)) return;
	if (XPMultiplierTimer[attacker]) value += RoundToFloor(value * GetConVarFloat(BuyXPMultiplier));
	experience_verifyfirst(attacker);
	ItemExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
	if (ItemExperience[attacker] >= ItemNextLevel[attacker])
	{
		if (ItemLevel[attacker] >= GetConVarInt(LevelCap)) ItemExperience[attacker] = ItemNextLevel[attacker];
		else
		{
			ItemLevel[attacker]++;
			if (ItemLevel[attacker] < GetConVarInt(UnlockXPCap))
			{
				RangeCheck[attacker] = RoundToFloor(ItemNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - ItemNextLevel[attacker];
				if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) ItemNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
				else ItemNextLevel[attacker] = RoundToFloor((ItemNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
			}
			else
			{
				ItemNextLevel[attacker] = RoundToFloor((ItemNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
			}
			PrintToSurvivors("%s \x03%N \x01has reached \x05Item Lv.\x03%d", LEVELUP_INFO, attacker, ItemLevel[attacker]);
			if (ItemLevel[attacker] == GetConVarInt(HealthPillsLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Pain Killers", LEVELUP_INFO, attacker);
			if (ItemLevel[attacker] == GetConVarInt(HealthPackLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Medical Kit", LEVELUP_INFO, attacker);
			if (ItemLevel[attacker] == GetConVarInt(HealthAdrenLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Adrenaline", LEVELUP_INFO, attacker);
			if (ItemLevel[attacker] == GetConVarInt(HealthHealLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Instant Heal", LEVELUP_INFO, attacker);
			if (ItemLevel[attacker] == GetConVarInt(HealthIncapLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Incap Protection", LEVELUP_INFO, attacker);
		}
	}
	//SaveData(attacker);
}

experience_explosion_increase(attacker, value)
{
	if (!IsHuman(attacker)) return;
	if (XPMultiplierTimer[attacker]) value += RoundToFloor(value * GetConVarFloat(BuyXPMultiplier));
	experience_verifyfirst(attacker);
	GrenadeExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
	if (GrenadeExperience[attacker] >= GrenadeNextLevel[attacker])
	{
		if (GrenadeLevel[attacker] >= GetConVarInt(LevelCap)) GrenadeExperience[attacker] = GrenadeNextLevel[attacker];
		else
		{
			GrenadeLevel[attacker]++;
			if (GrenadeLevel[attacker] < GetConVarInt(UnlockXPCap))
			{
				RangeCheck[attacker] = RoundToFloor(GrenadeNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - GrenadeNextLevel[attacker];
				if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) GrenadeNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
				else GrenadeNextLevel[attacker] = RoundToFloor((GrenadeNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
			}
			else
			{
				GrenadeNextLevel[attacker] = RoundToFloor((GrenadeNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
			}
			PrintToSurvivors("%s \x03%N \x01has reached \x05Grenade Lv.\x03%d", LEVELUP_INFO, attacker, GrenadeLevel[attacker]);
			if (GrenadeLevel[attacker] == GetConVarInt(GrenPipeLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Pipe Bomb", LEVELUP_INFO, attacker);
			if (GrenadeLevel[attacker] == GetConVarInt(GrenJarLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Vomit Jar", LEVELUP_INFO, attacker);
			if (GrenadeLevel[attacker] == GetConVarInt(GrenMolLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Molotov", LEVELUP_INFO, attacker);
			if (GrenadeLevel[attacker] == GetConVarInt(GrenLauncherLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Grenade Launcher", LEVELUP_INFO, attacker);
		}
	}
	//SaveData(attacker);
}

experience_increase(attacker, value)
{
	if (!IsHuman(attacker)) return;
	if (XPMultiplierTimer[attacker]) value += RoundToFloor(value * GetConVarFloat(BuyXPMultiplier));
	experience_verifyfirst(attacker);
	if (GetClientTeam(attacker) == 2)
	{
		new String:weaponused[64];
		GetClientWeapon(attacker, weaponused, sizeof(weaponused));
		if (StrEqual(weaponused, "weapon_pistol", true) || 
			(StrEqual(weaponused, "weapon_pistol_magnum", true) && PistolLevel[attacker] >= GetConVarInt(PistolDeagleLevel)))
		{
			PistolExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		}
			
		else if (StrEqual(weaponused, "weapon_melee", true))
		{
			MeleeExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		}
		
		else if ((StrEqual(weaponused, "weapon_smg", true) && PhysicalLevel[attacker] >= GetConVarInt(UziLevelUnlock) && UziLevel[attacker] >= GetConVarInt(UziMac10Level)) || 
				(StrEqual(weaponused, "weapon_smg_mp5", true) && PhysicalLevel[attacker] >= GetConVarInt(UziLevelUnlock) && UziLevel[attacker] >= GetConVarInt(UziMp5Level)) || 
				(StrEqual(weaponused, "weapon_smg_silenced", true) && PhysicalLevel[attacker] >= GetConVarInt(UziLevelUnlock) && UziLevel[attacker] >= GetConVarInt(UziMp5Level)))
		{
			UziExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		}
				
		else if ((StrEqual(weaponused, "weapon_autoshotgun", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunAutoLevel)) || 
				(StrEqual(weaponused, "weapon_pumpshotgun", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunPumpLevel)) || 
				(StrEqual(weaponused, "weapon_shotgun_chrome", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunChromeLevel)) || 
				(StrEqual(weaponused, "weapon_shotgun_spas", true) && PhysicalLevel[attacker] >= GetConVarInt(ShotgunLevelUnlock) && ShotgunLevel[attacker] >= GetConVarInt(ShotgunSpasLevel)))
		{
			ShotgunExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		}
		else if ((StrEqual(weaponused, "weapon_rifle", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleM16Level)) || 
				(StrEqual(weaponused, "weapon_rifle_ak47", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleAK47Level)) || 
				(StrEqual(weaponused, "weapon_rifle_desert", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleDesertLevel)) || 
				(StrEqual(weaponused, "weapon_rifle_m60", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleM60Level)) || 
				(StrEqual(weaponused, "weapon_rifle_sg552", true) && PhysicalLevel[attacker] >= GetConVarInt(RifleLevelUnlock) && RifleLevel[attacker] >= GetConVarInt(RifleSG552Level)))
		{
			RifleExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		}
		else if ((StrEqual(weaponused, "weapon_sniper_awp", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperAwpLevel)) || 
				(StrEqual(weaponused, "weapon_sniper_military", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperMilitaryLevel)) || 
				(StrEqual(weaponused, "weapon_sniper_scout", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperScoutLevel)) || 
				(StrEqual(weaponused, "weapon_hunting_rifle", true) && PhysicalLevel[attacker] >= GetConVarInt(SniperLevelUnlock) && SniperLevel[attacker] >= GetConVarInt(SniperHuntingLevel)))
		{
			SniperExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		}	
		
		
		// Whether the player has the weapon they are using or not unlocked, they receive physical experience.
		// Physical experience goes towards unlocking new weapons/abilities/items categories.
		PhysicalExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		
		if (PistolExperience[attacker] >= PistolNextLevel[attacker])
		{
			if (PistolLevel[attacker] >= GetConVarInt(LevelCap)) PistolExperience[attacker] = PistolNextLevel[attacker];
			else
			{
				PistolLevel[attacker]++;
				if (PistolLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(PistolNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - PistolNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) PistolNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else PistolNextLevel[attacker] = RoundToFloor((PistolNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					PistolNextLevel[attacker] = RoundToFloor((PistolNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Pistol Lv.\x03%d", LEVELUP_INFO, attacker, PistolLevel[attacker]);
				if (PistolLevel[attacker] == GetConVarInt(PistolDeagleLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Desert Eagle", LEVELUP_INFO, attacker);
			}
		}
		if (MeleeExperience[attacker] >= MeleeNextLevel[attacker])
		{
			if (MeleeLevel[attacker] >= GetConVarInt(LevelCap)) MeleeExperience[attacker] = MeleeNextLevel[attacker];
			else
			{
				MeleeLevel[attacker]++;
				if (MeleeLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(MeleeNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - MeleeNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) MeleeNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else MeleeNextLevel[attacker] = RoundToFloor((MeleeNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					MeleeNextLevel[attacker] = RoundToFloor((MeleeNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Melee Lv.\x03%d", LEVELUP_INFO, attacker, MeleeLevel[attacker]);
			}
		}
		if (UziExperience[attacker] >= UziNextLevel[attacker])
		{
			if (UziLevel[attacker] >= GetConVarInt(LevelCap)) UziExperience[attacker] = UziNextLevel[attacker];
			else
			{
				UziLevel[attacker]++;
				if (UziLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(UziNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - UziNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) UziNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else UziNextLevel[attacker] = RoundToFloor((UziNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					UziNextLevel[attacker] = RoundToFloor((UziNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Uzi Lv.\x03%d", LEVELUP_INFO, attacker, UziLevel[attacker]);
				if (UziLevel[attacker] == GetConVarInt(UziMac10Level)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Mac10", LEVELUP_INFO, attacker);
				if (UziLevel[attacker] == GetConVarInt(UziTmpLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Tmp-Silenced", LEVELUP_INFO, attacker);
			}
		}
		if (ShotgunExperience[attacker] >= ShotgunNextLevel[attacker])
		{
			if (ShotgunLevel[attacker] >= GetConVarInt(LevelCap)) ShotgunExperience[attacker] = ShotgunNextLevel[attacker];
			else
			{
				ShotgunLevel[attacker]++;
				if (ShotgunLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(ShotgunNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - ShotgunNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) ShotgunNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else ShotgunNextLevel[attacker] = RoundToFloor((ShotgunNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					ShotgunNextLevel[attacker] = RoundToFloor((ShotgunNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Shotgun Lv.\x03%d", LEVELUP_INFO, attacker, ShotgunLevel[attacker]);
				if (ShotgunLevel[attacker] == GetConVarInt(ShotgunPumpLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Pump Shotgun", LEVELUP_INFO, attacker);
				if (ShotgunLevel[attacker] == GetConVarInt(ShotgunSpasLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Spas Shotgun", LEVELUP_INFO, attacker);
				if (ShotgunLevel[attacker] == GetConVarInt(ShotgunAutoLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Auto Shotgun", LEVELUP_INFO, attacker);
			}
		}
		if (SniperExperience[attacker] >= SniperNextLevel[attacker])
		{
			if (SniperLevel[attacker] >= GetConVarInt(LevelCap)) SniperExperience[attacker] = SniperNextLevel[attacker];
			else
			{
				SniperLevel[attacker]++;
				if (SniperLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(SniperNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - SniperNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) SniperNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else SniperNextLevel[attacker] = RoundToFloor((SniperNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					ShotgunNextLevel[attacker] = RoundToFloor((ShotgunNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Sniper Lv.\x03%d", LEVELUP_INFO, attacker, SniperLevel[attacker]);
				if (SniperLevel[attacker] == GetConVarInt(SniperScoutLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Scout Rifle", LEVELUP_INFO, attacker);
				if (SniperLevel[attacker] == GetConVarInt(SniperAwpLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Awp Rifle", LEVELUP_INFO, attacker);
				if (SniperLevel[attacker] == GetConVarInt(SniperMilitaryLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Military Rifle", LEVELUP_INFO, attacker);
				if (SniperLevel[attacker] == GetConVarInt(SniperHuntingLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Hunting Rifle", LEVELUP_INFO, attacker);
			}
		}
		if (RifleExperience[attacker] >= RifleNextLevel[attacker])
		{
			if (RifleLevel[attacker] >= GetConVarInt(LevelCap)) RifleExperience[attacker] = RifleNextLevel[attacker];
			else
			{
				RifleLevel[attacker]++;
				if (RifleLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(RifleNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - RifleNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) RifleNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else RifleNextLevel[attacker] = RoundToFloor((RifleNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					RifleNextLevel[attacker] = RoundToFloor((RifleNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Rifle Lv.\x03%d", LEVELUP_INFO, attacker, RifleLevel[attacker]);
				if (RifleLevel[attacker] == GetConVarInt(RifleDesertLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Desert Rifle", LEVELUP_INFO, attacker);
				if (RifleLevel[attacker] == GetConVarInt(RifleM16Level)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05M16", LEVELUP_INFO, attacker);
				if (RifleLevel[attacker] == GetConVarInt(RifleSG552Level)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05SG552", LEVELUP_INFO, attacker);
				if (RifleLevel[attacker] == GetConVarInt(RifleAK47Level)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05AK47", LEVELUP_INFO, attacker);
				if (RifleLevel[attacker] == GetConVarInt(RifleM60Level)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05M60", LEVELUP_INFO, attacker);
			}
		}
		if (ItemExperience[attacker] >= ItemNextLevel[attacker])
		{
			if (ItemLevel[attacker] >= GetConVarInt(LevelCap)) ItemExperience[attacker] = ItemNextLevel[attacker];
			else
			{
				ItemLevel[attacker]++;
				if (ItemLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(ItemNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - ItemNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) ItemNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else ItemNextLevel[attacker] = RoundToFloor((ItemNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					ItemNextLevel[attacker] = RoundToFloor((ItemNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Item Lv.\x03%d", LEVELUP_INFO, attacker, ItemLevel[attacker]);
				if (ItemLevel[attacker] == GetConVarInt(HealthPillsLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Pain Killers", LEVELUP_INFO, attacker);
				if (ItemLevel[attacker] == GetConVarInt(HealthPackLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Medical Pack", LEVELUP_INFO, attacker);
				if (ItemLevel[attacker] == GetConVarInt(HealthAdrenLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Adrenaline", LEVELUP_INFO, attacker);
				if (ItemLevel[attacker] == GetConVarInt(HealthHealLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Instant Heal", LEVELUP_INFO, attacker);
				if (ItemLevel[attacker] == GetConVarInt(HealthIncapLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Incap Protection", LEVELUP_INFO, attacker);
			}
		}
		if (GrenadeExperience[attacker] >= GrenadeNextLevel[attacker])
		{
			if (GrenadeLevel[attacker] >= GetConVarInt(LevelCap)) GrenadeExperience[attacker] = GrenadeNextLevel[attacker];
			else
			{
				GrenadeLevel[attacker]++;
				if (GrenadeLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(GrenadeNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - GrenadeNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) GrenadeNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else GrenadeNextLevel[attacker] = RoundToFloor((GrenadeNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					GrenadeNextLevel[attacker] = RoundToFloor((GrenadeNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Grenade Lv.\x03%d", LEVELUP_INFO, attacker, GrenadeLevel[attacker]);
				if (GrenadeLevel[attacker] == GetConVarInt(GrenPipeLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Pipe Bomb", LEVELUP_INFO, attacker);
				if (GrenadeLevel[attacker] == GetConVarInt(GrenJarLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Vomit Jar", LEVELUP_INFO, attacker);
				if (GrenadeLevel[attacker] == GetConVarInt(GrenMolLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Molotov", LEVELUP_INFO, attacker);
				if (GrenadeLevel[attacker] == GetConVarInt(GrenLauncherLevel)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Grenade Launcher", LEVELUP_INFO, attacker);
			}
		}
		if (PhysicalExperience[attacker] >= PhysicalNextLevel[attacker])
		{
			if (PhysicalLevel[attacker] >= GetConVarInt(LevelCap)) PhysicalExperience[attacker] = PhysicalNextLevel[attacker];
			else
			{
				PhysicalLevel[attacker]++;
				if (PhysicalLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(PhysicalNextLevel[attacker] * GetConVarFloat(PhysicalIncrement)) - PhysicalNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(PhysicalMaxIncrement)) PhysicalNextLevel[attacker] += GetConVarInt(PhysicalMaxIncrement);
					else PhysicalNextLevel[attacker] = RoundToFloor((PhysicalNextLevel[attacker] * GetConVarFloat(PhysicalIncrement)));
				}
				else
				{
					PhysicalNextLevel[attacker] = RoundToFloor((PhysicalNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToSurvivors("%s \x03%N \x01has reached \x05Physical Lv.\x03%d", LEVELUP_INFO, attacker, PhysicalLevel[attacker]);
				if (PhysicalLevel[attacker] == GetConVarInt(UziLevelUnlock)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Uzi Category", UNLOCK_INFO, attacker);
				if (PhysicalLevel[attacker] == GetConVarInt(ShotgunLevelUnlock)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Shotgun Category", UNLOCK_INFO, attacker);
				if (PhysicalLevel[attacker] == GetConVarInt(SniperLevelUnlock)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Sniper Category", UNLOCK_INFO, attacker);
				if (PhysicalLevel[attacker] == GetConVarInt(RifleLevelUnlock)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Rifle Category", UNLOCK_INFO, attacker);
				if (PhysicalLevel[attacker] == GetConVarInt(GrenadeLevelUnlock)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Grenade Category", UNLOCK_INFO, attacker);
				if (PhysicalLevel[attacker] == GetConVarInt(ItemLevelUnlock)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Items Category", UNLOCK_INFO, attacker);
				if (PhysicalLevel[attacker] == GetConVarInt(MeleeLevelUnlock)) PrintToSurvivors("%s \x03%N \x01has \x01unlocked \x05Melee Category", UNLOCK_INFO, attacker);
			}
		}
	}
	else if (GetClientTeam(attacker) == 3)
	{
		if (ClassHunter[attacker]) HunterExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		if (ClassSmoker[attacker]) SmokerExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		if (ClassBoomer[attacker]) BoomerExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		if (ClassJockey[attacker]) JockeyExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		if (ClassCharger[attacker]) ChargerExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		if (ClassSpitter[attacker]) SpitterExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		if (ClassTank[attacker]) TankExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		
		// Whether the player has the weapon they are using or not unlocked, they receive physical experience.
		// Physical experience goes towards unlocking new weapons/abilities/items categories.
		InfectedExperience[attacker] += RoundToFloor(value * GetConVarFloat(EventMoreXPFriday));
		
		if (HunterExperience[attacker] >= HunterNextLevel[attacker])
		{
			if (HunterLevel[attacker] >= GetConVarInt(LevelCap)) HunterExperience[attacker] = HunterNextLevel[attacker];
			else
			{
				HunterLevel[attacker]++;
				if (HunterLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(HunterNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - HunterNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) HunterNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else HunterNextLevel[attacker] = RoundToFloor((HunterNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					HunterNextLevel[attacker] = RoundToFloor((HunterNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Hunter Lv.\x04%d", LEVELUP_INFO, attacker, HunterLevel[attacker]);
				if (HunterLevel[attacker] == GetConVarInt(InfectedTier2Level)) PrintToInfected("%s \x04%N\x01's Hunter reached \x04Tier 2 \x01Level.", LEVELUP_INFO, attacker);
			}
		}
		if (SmokerExperience[attacker] >= SmokerNextLevel[attacker])
		{
			if (SmokerLevel[attacker] >= GetConVarInt(LevelCap)) SmokerExperience[attacker] = SmokerNextLevel[attacker];
			else
			{
				SmokerLevel[attacker]++;
				if (SmokerLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(SmokerNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - SmokerNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) SmokerNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else SmokerNextLevel[attacker] = RoundToFloor((SmokerNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					SmokerNextLevel[attacker] = RoundToFloor((SmokerNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Smoker Lv.\x04%d", LEVELUP_INFO, attacker, SmokerLevel[attacker]);
				if (SmokerLevel[attacker] == GetConVarInt(InfectedTier2Level)) PrintToInfected("%s \x04%N\x01's Smoker reached \x04Tier 2 \x01Level.", LEVELUP_INFO, attacker);
			}
		}
		if (BoomerExperience[attacker] >= BoomerNextLevel[attacker])
		{
			if (BoomerLevel[attacker] >= GetConVarInt(LevelCap)) BoomerExperience[attacker] = BoomerNextLevel[attacker];
			else
			{
				BoomerLevel[attacker]++;
				if (BoomerLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(BoomerNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - BoomerNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) BoomerNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else BoomerNextLevel[attacker] = RoundToFloor((BoomerNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					BoomerNextLevel[attacker] = RoundToFloor((BoomerNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Boomer Lv.\x04%d", LEVELUP_INFO, attacker, BoomerLevel[attacker]);
				if (BoomerLevel[attacker] == GetConVarInt(InfectedTier2Level)) PrintToInfected("%s \x04%N\x01's Boomer reached \x04Tier 2 \x01Level.", LEVELUP_INFO, attacker);
			}
		}
		if (JockeyExperience[attacker] >= JockeyNextLevel[attacker])
		{
			if (JockeyLevel[attacker] >= GetConVarInt(LevelCap)) JockeyExperience[attacker] = JockeyNextLevel[attacker];
			else
			{
				JockeyLevel[attacker]++;
				if (JockeyLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(JockeyNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - JockeyNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) JockeyNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else JockeyNextLevel[attacker] = RoundToFloor((JockeyNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					JockeyNextLevel[attacker] = RoundToFloor((JockeyNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Jockey Lv.\x04%d", LEVELUP_INFO, attacker, JockeyLevel[attacker]);
				if (JockeyLevel[attacker] == GetConVarInt(InfectedTier2Level)) PrintToInfected("%s \x04%N\x01's Jockey reached \x04Tier 2 \x01Level.", LEVELUP_INFO, attacker);
			}
		}
		if (ChargerExperience[attacker] >= ChargerNextLevel[attacker])
		{
			if (ChargerLevel[attacker] >= GetConVarInt(LevelCap)) ChargerExperience[attacker] = ChargerNextLevel[attacker];
			else
			{
				ChargerLevel[attacker]++;
				if (ChargerLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(ChargerNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - ChargerNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) ChargerNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else ChargerNextLevel[attacker] = RoundToFloor((ChargerNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					ChargerNextLevel[attacker] = RoundToFloor((ChargerNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Charger Lv.\x04%d", LEVELUP_INFO, attacker, ChargerLevel[attacker]);
				if (ChargerLevel[attacker] == GetConVarInt(InfectedTier2Level)) PrintToInfected("%s \x04%N\x01's Charger reached \x04Tier 2 \x01Level.", LEVELUP_INFO, attacker);
			}
		}
		if (SpitterExperience[attacker] >= SpitterNextLevel[attacker])
		{
			if (SpitterLevel[attacker] >= GetConVarInt(LevelCap)) SpitterExperience[attacker] = SpitterNextLevel[attacker];
			else
			{
				SpitterLevel[attacker]++;
				if (SpitterLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(SpitterNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - SpitterNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) SpitterNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else SpitterNextLevel[attacker] = RoundToFloor((SpitterNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					SpitterNextLevel[attacker] = RoundToFloor((SpitterNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Spitter Lv.\x04%d", LEVELUP_INFO, attacker, SpitterLevel[attacker]);
				if (SpitterLevel[attacker] == GetConVarInt(InfectedTier2Level)) PrintToInfected("%s \x04%N\x01's Spitter reached \x04Tier 2 \x01Level.", LEVELUP_INFO, attacker);
			}
		}
		if (TankExperience[attacker] >= TankNextLevel[attacker])
		{
			if (TankLevel[attacker] >= GetConVarInt(LevelCap)) TankExperience[attacker] = TankNextLevel[attacker];
			else
			{
				TankLevel[attacker]++;
				if (TankLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(TankNextLevel[attacker] * GetConVarFloat(CategoryIncrement)) - TankNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(CategoryMaxIncrement)) TankNextLevel[attacker] += GetConVarInt(CategoryMaxIncrement);
					else TankNextLevel[attacker] = RoundToFloor((TankNextLevel[attacker] * GetConVarFloat(CategoryIncrement)));
				}
				else
				{
					TankNextLevel[attacker] = RoundToFloor((TankNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Tank Lv.\x04%d", LEVELUP_INFO, attacker, TankLevel[attacker]);
				if (TankLevel[attacker] == GetConVarInt(InfectedTier2Level)) PrintToInfected("%s \x04%N\x01's Tank reached \x04Tier 2 \x01Level.", LEVELUP_INFO, attacker);
			}
		}
		if (InfectedExperience[attacker] >= InfectedNextLevel[attacker])
		{
			if (InfectedLevel[attacker] >= GetConVarInt(LevelCap)) InfectedExperience[attacker] = InfectedNextLevel[attacker];
			else
			{
				InfectedLevel[attacker]++;
				if (InfectedLevel[attacker] < GetConVarInt(UnlockXPCap))
				{
					RangeCheck[attacker] = RoundToFloor(InfectedNextLevel[attacker] * GetConVarFloat(PhysicalIncrement)) - InfectedNextLevel[attacker];
					if (RangeCheck[attacker] > GetConVarInt(PhysicalMaxIncrement)) InfectedNextLevel[attacker] += GetConVarInt(PhysicalMaxIncrement);
					else InfectedNextLevel[attacker] = RoundToFloor((InfectedNextLevel[attacker] * GetConVarFloat(PhysicalIncrement)));
				}
				else
				{
					InfectedNextLevel[attacker] = RoundToFloor((InfectedNextLevel[attacker] * GetConVarFloat(UnlockXPIncrement)));
				}
				PrintToInfected("%s \x04%N \x01reached \x05Infected Lv.\x04%d", LEVELUP_INFO, attacker, InfectedLevel[attacker]);
			}
		}
	}
	//SaveData(attacker);
}

experience_verifyfirst(attacker)
{
	if (!IsHuman(attacker)) return;
	if (PhysicalLevel[attacker] < 1 || PhysicalNextLevel[attacker] < 1)
	{
		// if any level is 0, the player was just instantiated. Set all levels.
		PistolLevel[attacker] = 1;
		PistolNextLevel[attacker] = RoundToFloor(GetConVarFloat(PistolStartXP));
		MeleeLevel[attacker] = 1;
		MeleeNextLevel[attacker] = RoundToFloor(GetConVarFloat(MeleeStartXP));
		UziLevel[attacker] = 1;
		UziNextLevel[attacker] = RoundToFloor(GetConVarFloat(UziStartXP));
		ShotgunLevel[attacker] = 1;
		ShotgunNextLevel[attacker] = RoundToFloor(GetConVarFloat(ShotgunStartXP));
		SniperLevel[attacker] = 1;
		SniperNextLevel[attacker] = RoundToFloor(GetConVarFloat(SniperStartXP));
		RifleLevel[attacker] = 1;
		RifleNextLevel[attacker] = RoundToFloor(GetConVarFloat(RifleStartXP));
		GrenadeLevel[attacker] = 1;
		GrenadeNextLevel[attacker] = RoundToFloor(GetConVarFloat(GrenadeStartXP));
		ItemLevel[attacker] = 1;
		ItemNextLevel[attacker] = RoundToFloor(GetConVarFloat(ItemStartXP));
		PhysicalLevel[attacker] = 1;
		PhysicalNextLevel[attacker] = RoundToFloor(GetConVarFloat(PhysicalStartXP));
	}
	if (InfectedLevel[attacker] < 1 || InfectedNextLevel[attacker] < 1)
	{
		HunterLevel[attacker] = 1;
		HunterNextLevel[attacker] = RoundToFloor(GetConVarFloat(HunterStartXP));
		SmokerLevel[attacker] = 1;
		SmokerNextLevel[attacker] = RoundToFloor(GetConVarFloat(SmokerStartXP));
		BoomerLevel[attacker] = 1;
		BoomerNextLevel[attacker] = RoundToFloor(GetConVarFloat(BoomerStartXP));
		JockeyLevel[attacker] = 1;
		JockeyNextLevel[attacker] = RoundToFloor(GetConVarFloat(JockeyStartXP));
		ChargerLevel[attacker] = 1;
		ChargerNextLevel[attacker] = RoundToFloor(GetConVarFloat(ChargerStartXP));
		SpitterLevel[attacker] = 1;
		SpitterNextLevel[attacker] = RoundToFloor(GetConVarFloat(SpitterStartXP));
		TankLevel[attacker] = 1;
		TankNextLevel[attacker] = RoundToFloor(GetConVarFloat(TankStartXP));
		InfectedLevel[attacker] = 1;
		InfectedNextLevel[attacker] = RoundToFloor(GetConVarFloat(InfectedStartXP));
	}
}