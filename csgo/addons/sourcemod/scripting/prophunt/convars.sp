void InitConVars()
{
	g_cvEnabled = CreateConVar("ph_enabled", "1", "Enables this plugin.");
	
	g_cvHideTime = CreateConVar("ph_hide_time", "30.0", "Amount of sec. hiders can change their model from round start.");
	g_cvAutoFreezeTime = CreateConVar("ph_auto_freeze_time", "1.5", "Auto. freeze hiders when they didn't move for this amount of time.");
	
	int iCount  = sizeof(g_cvBalancer);
	for (int i = 0; i < iCount; i++)
	{
		char sName[32];
		char sDefault[32];
		char sDescription[128];
		
		Format(sName, sizeof(sName), "ph_balancer_%i_minplayers", i + 1);
		Format(sDefault, sizeof(sDefault), "%i", (64 - (i + 1) * iCount));
		Format(sDescription, sizeof(sDescription), "Min amount of players to allow this amount of seekers.");
		g_cvBalancer[i][0] = CreateConVar(sName, sDefault, sDescription);
		
		Format(sName, sizeof(sName), "ph_balancer_%i_seekers", i + 1);
		Format(sDefault, sizeof(sDefault), "%i", (iCount - i));
		Format(sDescription, sizeof(sDescription), "Amount of seekers to allow per round.");
		g_cvBalancer[i][1] = CreateConVar(sName, sDefault, sDescription);
	}
	
	// Hider Speed
	
	g_cvHiderSpeedMax = CreateConVar("ph_hider_speed_max", "1.5", "Max speed a hider can get.");
	g_cvHiderSpeedMaxPriority = CreateConVar("ph_hider_speed_max_priority", "0", "Priority used by speedrules, set this to a high number if you don't want it to be overwritten by other features.");
	
	g_cvHiderSpeedHideTime = CreateConVar("ph_hider_speed_hide_time", "1.5", "Speed hiders have during hide time (roundstart).");
	g_cvHiderSpeedHideTimePriority = CreateConVar("ph_hider_speed_hide_time_priority", "1", "Priority used by speedrules, set this to a high number if you don't want it to be overwritten by other features.");
	
	g_cvHiderSpeedHideTimeMax = CreateConVar("ph_hider_speed_hide_time_max", "1.5", "Max speed a hider can get during hide timer (roundstart).");
	g_cvHiderSpeedHideTimeMaxPriority = CreateConVar("ph_hider_speed_hide_time_max_priority", "1", "Priority used by speedrules, set this to a high number if you don't want it to be overwritten by other features.");
	
	// Seeker Speed
	
	g_cvSeekerSpeedBase = CreateConVar("ph_seeker_speed_base", "1.0", "Base speed seekers team.");
	g_cvSeekerSpeedBasePriority = CreateConVar("ph_seeker_speed_base_priority", "1", "Priority used by speedrules, set this to a high number if you don't want it to be overwritten by other features.");	
	g_cvSeekerSpeedMax = CreateConVar("ph_seeker_speed_max", "1.5", "Max speed a seekers can get.");
	g_cvSeekerSpeedMaxPriority = CreateConVar("ph_seeker_speed_max_priority", "1", "Priority used by speedrules, set this to a high number if you don't want it to be overwritten by other features.");
	
	// Take health for firing weapons
	
	g_cvWeaponUseHealthDefault = CreateConVar("ph_weapon_use_default", "0", "Amount of health to take when using an unknown weapon.");
	g_cvWeaponUseHealth[WEAPONTYPE_KNIFE] = CreateConVar("ph_weapon_use_knife", "20", "Amount of health to take when using a knife.");
	g_cvWeaponUseHealth[WEAPONTYPE_PISTOL] = CreateConVar("ph_weapon_use_pistol", "5", "Amount of health to take when using a pistol.");
	g_cvWeaponUseHealth[WEAPONTYPE_SUBMACHINEGUN] = CreateConVar("ph_weapon_use_sub", "4", "Amount of health to take when using a sub machine gun.");
	g_cvWeaponUseHealth[WEAPONTYPE_RIFLE] = CreateConVar("ph_weapon_use_rifle", "3", "Amount of health to take when using a rifle.");
	g_cvWeaponUseHealth[WEAPONTYPE_SHOTGUN] = CreateConVar("ph_weapon_use_shotgun", "8", "Amount of health to take when using a shotgun.");
	g_cvWeaponUseHealth[WEAPONTYPE_SNIPER_RIFLE] = CreateConVar("ph_weapon_use_sniper", "25", "Amount of health to take when using a sniper.");
	g_cvWeaponUseHealth[WEAPONTYPE_MACHINEGUN] = CreateConVar("ph_weapon_use_mg", "3", "Amount of health to take when using a machine gun.");
	g_cvWeaponUseHealth[WEAPONTYPE_TASER] = CreateConVar("ph_weapon_use_taser", "0", "Amount of health to take when using a taser (It's recommended to leave this at 0).");
	g_cvWeaponUseHealth[WEAPONTYPE_GRENADE] = CreateConVar("ph_weapon_use_grenade", "0", "Amount of health to take when using a grenade (It's recommended to leave this at 0).");
	g_cvWeaponUseHealth[WEAPONTYPE_HEALTHSHOT] = CreateConVar("ph_weapon_use_healthshot", "0", "Amount of health to take when using a healthshot (It's recommended to leave this at 0).");
	
	g_cvWeaponHitHealthDefault = CreateConVar("ph_weapon_hit_default", "0", "Amount of health to give back when hitting a hider with an unknown weapon.");
	g_cvWeaponHitHealth[WEAPONTYPE_KNIFE] = CreateConVar("ph_weapon_hit_knife", "20", "Amount of health to give back when hitting a hider with a knife.");
	g_cvWeaponHitHealth[WEAPONTYPE_PISTOL] = CreateConVar("ph_weapon_hit_pistol", "5", "Amount of health to give back when hitting a hider with a pistol.");
	g_cvWeaponHitHealth[WEAPONTYPE_SUBMACHINEGUN] = CreateConVar("ph_weapon_hit_sub", "4", "Amount of health to give back when hitting a hider with a sub machine gun.");
	g_cvWeaponHitHealth[WEAPONTYPE_RIFLE] = CreateConVar("ph_weapon_hit_rifle", "3", "Amount of health to give back when hitting a hider with a rifle.");
	g_cvWeaponHitHealth[WEAPONTYPE_SHOTGUN] = CreateConVar("ph_weapon_hit_shotgun", "8", "Amount of health to give back when hitting a hider with a shotgun.");
	g_cvWeaponHitHealth[WEAPONTYPE_SNIPER_RIFLE] = CreateConVar("ph_weapon_hit_sniper", "50", "Amount of health to give back when hitting a hider with a sniper.");
	g_cvWeaponHitHealth[WEAPONTYPE_MACHINEGUN] = CreateConVar("ph_weapon_hit_mg", "3", "Amount of health to give back when hitting a hider with a machine gun.");
	g_cvWeaponHitHealth[WEAPONTYPE_TASER] = CreateConVar("ph_weapon_hit_taser", "0", "Amount of health to give back when hitting a hider with a taser.");
	g_cvWeaponHitHealth[WEAPONTYPE_GRENADE] = CreateConVar("ph_weapon_hit_grenade", "0", "Amount of health to give back when hitting a hider with a grenade (It's recommended to leave this at 0).");
	
	g_cvWeaponKillHealthDefault = CreateConVar("ph_weapon_kill_default", "0", "Amount of health to give back when killing a hider with an unknown weapon.");
	g_cvWeaponKillHealth[WEAPONTYPE_KNIFE] = CreateConVar("ph_weapon_kill_knife", "50", "Amount of health to give back when killing a hider with a knife.");
	g_cvWeaponKillHealth[WEAPONTYPE_PISTOL] = CreateConVar("ph_weapon_kill_pistol", "20", "Amount of health to give back when killing a hider with a pistol.");
	g_cvWeaponKillHealth[WEAPONTYPE_SUBMACHINEGUN] = CreateConVar("ph_weapon_kill_sub", "20", "Amount of health to give back when killing a hider with a sub machine gun.");
	g_cvWeaponKillHealth[WEAPONTYPE_RIFLE] = CreateConVar("ph_weapon_kill_rifle", "30", "Amount of health to give back when killing a hider with a rifle.");
	g_cvWeaponKillHealth[WEAPONTYPE_SHOTGUN] = CreateConVar("ph_weapon_kill_shotgun", "15", "Amount of health to give back when killing a hider with a shotgun.");
	g_cvWeaponKillHealth[WEAPONTYPE_SNIPER_RIFLE] = CreateConVar("ph_weapon_kill_sniper", "35", "Amount of health to give back when killing a hider with a sniper.");
	g_cvWeaponKillHealth[WEAPONTYPE_MACHINEGUN] = CreateConVar("ph_weapon_kill_mg", "20", "Amount of health to give back when killing a hider with a machine gun.");
	g_cvWeaponKillHealth[WEAPONTYPE_TASER] = CreateConVar("ph_weapon_kill_taser", "100", "Amount of health to give back when killing a hider with a taser.");
	g_cvWeaponKillHealth[WEAPONTYPE_GRENADE] = CreateConVar("ph_weapon_kill_grenade", "60", "Amount of health to give back when killing a hider with a grenade.");
	
	// Seeker Health
	
	g_cvSeekerCanKillSelf = CreateConVar("ph_seeker_kill_self", "0", "If enabled seekers can die by shooting and if disabled stays at 1HP.");
	g_cvSeekerMaxHealth = CreateConVar("ph_seeker_health_max", "150", "Max HP a seeker can get.");
	
	// Hide Menu
	
	g_cvHiderModels = CreateConVar("ph_hider_models", "5", "Amount of models a hider can choose from.");
	
	// Freeze limits
	
	g_cvHiderFreezeFallspeedMax = CreateConVar("ph_hider_freeze_fallspeed_max", "-320.0", "When a hider is falling faster than this he can't freeze (Usefull for maps like vertigo).");
	g_cvHiderFreezeHeightMax = CreateConVar("ph_hider_freeze_height_max", "80.0", "Max distance above ground wher players can freeze (Usefull for maps like vertigo).");
	g_cvHiderFreezeAboveWater = CreateConVar("ph_hider_freeze_above_water", "0", "If disabled freezing above water is blocked (Usefull for maps like seaside & overgrown).");
	
	// Taunt Points
	
	g_cvTauntPointsMin = CreateConVar("ph_taunt_points_min", "8.5", "Min points a hider gets for taunting.");
	g_cvTauntPointsMax = CreateConVar("ph_taunt_points_max", "24.0", "Max points a hider gets for taunting.");
	g_cvTauntLengthPointsMin = CreateConVar("ph_taunt_length_points_min", "0.6", "Min points a hider gets for taunting, based on the sound length (1.0 = 100%).");
	g_cvTauntLengthPointsMax = CreateConVar("ph_taunt_length_points_max", "1.0", "Max points a hider gets for taunting, based on the sound length (1.0 = 100%).");
	
	// Taunt Cooldown
	
	g_cvTauntCooldownMin = CreateConVar("ph_taunt_cooldown_min", "9", "Min amount of seconds a player has to wait until he can taunt again (else use sound length).");
	g_cvTauntCooldownExtra = CreateConVar("ph_taunt_cooldown_extra", "5", "Extra cooldown amount added to taunt sound length before checking for min amount of time.");
	g_cvTauntOverloadTime = CreateConVar("ph_taunt_overload_time", "60", "Time until first punishment starts for not playing a taunt sound.");
	g_cvTauntOverloadWarnTime = CreateConVar("ph_taunt_overload_warn_time", "10", "Warn time before punishment kicks in.");
	g_cvTauntOverloadCooldown = CreateConVar("ph_taunt_overload_cooldown", "30", "Time until punishment repeats.");
	
	// Taunt Force Points
	
	g_cvTauntForce = CreateConVar("ph_taunt_force", "0", "Allow seekers to force hiders to taunt.");
	g_cvTauntForceLastHider = CreateConVar("ph_taunt_force_last", "12", "If ph_taunt_force is enabled seekers can force even the last hider to taunt (0: Disabled, 1: Always, 2-100: Chance of success).");
	g_cvTauntForceFailedCooldown = CreateConVar("ph_taunt_force_failed", "30", "Force taunt cooldown when failed.");
	
	g_cvTauntForceCooldownMin = CreateConVar("ph_taunt_force_cooldown_min", "15", "Min amount of seconds a player has to wait until he can taunt again (else use sound length).");
	g_cvTauntForceCooldownExtra = CreateConVar("ph_taunt_force_cooldown_extran", "10", "Extra cooldown amount added to taunt sound length before checking for min amount of time.");
	
	// Shop
	
	g_cvShopEnable = CreateConVar("ph_shop_enable", "1", "0: Disable shop 1: Both teams 2: T only 3: CT only.");
	g_cvShopSortMode = CreateConVar("ph_shop_sort_mode", "2", "0: Custom; 1: Price ASC; 2: Price DESC.");
	
	// Shop Hider
	
	g_cvShopHiderHealPrice = CreateConVar("ph_shop_hider_heal_price", "50", "Shop price to buy bonus HP for hiders.");
	g_cvShopHiderHealSort = CreateConVar("ph_shop_hider_heal_sort", "30", "Sort order.");
	g_cvShopHiderHealUnlockTime = CreateConVar("ph_shop_hider_heal_unlock", "0", "Unlock time.");
	
	g_cvShopHiderMorphPrice = CreateConVar("ph_shop_hider_morth_price", "100", "Shop price to allow a hider to morth (Get new random model).");
	g_cvShopHiderMorphSort = CreateConVar("ph_shop_hider_morth_sort", "40", "Sort order.");
	g_cvShopHiderMorphUnlockTime = CreateConVar("ph_shop_hider_morth_unlock", "0", "Unlock time.");
	
	g_cvShopHiderAirFreezeHeight = CreateConVar("ph_shop_hider_air_freeze_height", "350.0", "Height to check when air freeze is active.");
	
	g_cvShopHiderAirFreezePrice = CreateConVar("ph_shop_hider_air_freeze_price", "75", "Shop price to allow a hider to freeze more up into the air.");
	g_cvShopHiderAirFreezeSort = CreateConVar("ph_shop_hider_air_freeze_sort", "50", "Sort order.");
	g_cvShopHiderAirFreezeUnlockTime = CreateConVar("ph_shop_hider_air_freeze_unlock", "60", "Unlock time.");

	g_cvShopHiderSpeedTime = CreateConVar("ph_shop_hider_speed_time", "30.0", "How long the speed buff should be active (0: no limit).");
	g_cvShopHiderSpeedBonus = CreateConVar("ph_shop_hider_speed_bonus", "0.3", "How much speed to give additionally. (Example 0.3 makes the player 30% faster. where 100% is the engine's default speed)");
	g_cvShopHiderSpeedBonusType = CreateConVar("ph_shop_hider_speed_bonus_type", "0", "0: Add, 1: Multiply base speed");
	g_cvShopHiderSpeedPriority = CreateConVar("ph_shop_hider_speed_bonus_priority", "0", "Priority used by speedrules, set this to a high number if you don't want it to be overwritten by other features.");
	g_cvShopHiderSpeedPrice = CreateConVar("ph_shop_hider_speed_price", "170", "Price for speed buff.");
	g_cvShopHiderSpeedSort = CreateConVar("ph_shop_hider_speed_sort", "11", "Speed buff shop sort order.");
	g_cvShopHiderSpeedUnlockTime = CreateConVar("ph_shop_hider_speed_unlock", "150", "Speed buff shop unlock time.");

	g_cvShopHiderGravityMin = CreateConVar("ph_shop_hider_gravity_min", "0.5", "Min gravity.");
	g_cvShopHiderGravityBonus = CreateConVar("ph_shop_hider_gravity_bonus", "0.3", "How much to reduce gravity.");
	g_cvShopHiderGravityPrice = CreateConVar("ph_shop_hider_gravity_price", "270", "Price to unlock low gravity.");
	g_cvShopHiderGravitySort = CreateConVar("ph_shop_hider_gravity_sort", "10", "Low graity shop sort order.");
	g_cvShopHiderGravityUnlockTime = CreateConVar("ph_shop_hider_gravity_unlock", "130", "Low gravity shop unlock time.");
	
	// Shop Seeker
	
	g_cvShopSeekerHealthshotPrice = CreateConVar("ph_shop_seeker_healthshot_price", "75", "Shop price to buy a healthshot as seeker.");
	g_cvShopSeekerHealthshotSort = CreateConVar("ph_shop_seeker_healthshot_sort", "1", "Sort order.");
	g_cvShopSeekerHealthshotUnlockTime = CreateConVar("ph_shop_seeker_healthshot_unlock", "0", "Unlock time.");
	
	g_cvShopSeekerGrenadePrice = CreateConVar("ph_shop_seeker_grenade_price", "70", "Shop price to buy a grenade as seeker.");
	g_cvShopSeekerGrenadeSort = CreateConVar("ph_shop_seeker_grenade_sort", "2", "Sort order.");
	g_cvShopSeekerGrenadeUnlockTime = CreateConVar("ph_shop_seeker_grenade_unlock", "60", "Unlock time.");
	
	g_cvShopSeekerFiveSevenPrice = CreateConVar("ph_shop_seeker_fiveseven_price", "45", "Shop price to buy a healthshot as seeker.");
	g_cvShopSeekerFiveSevenSort = CreateConVar("ph_shop_seeker_fiveseven_sort", "9", "Sort order.");
	g_cvShopSeekerFiveSevenUnlockTime = CreateConVar("ph_shop_seeker_fiveseven_unlock", "0", "Unlock time.");
	
	g_cvShopSeekerXM1014Price = CreateConVar("ph_shop_seeker_xm1014_price", "180", "Shop price to buy a healthshot as seeker.");
	g_cvShopSeekerXM1014Sort = CreateConVar("ph_shop_seeker_xm1014_sort", "7", "Sort order.");
	g_cvShopSeekerXM1014UnlockTime = CreateConVar("ph_shop_seeker_xm1014_unlock", "85", "Unlock time.");
	
	g_cvShopSeekerMP9Price = CreateConVar("ph_shop_seeker_mp9_price", "135", "Shop price to buy a healthshot as seeker.");
	g_cvShopSeekerMP9Sort = CreateConVar("ph_shop_seeker_mp9_sort", "8", "Sort order.");
	g_cvShopSeekerMP9UnlockTime = CreateConVar("ph_shop_seeker_mp9_unlock", "75", "Unlock time.");
	
	g_cvShopSeekerM4A1Price = CreateConVar("ph_shop_seeker_m4a1_price", "300", "Shop price to buy a healthshot as seeker.");
	g_cvShopSeekerM4A1Sort = CreateConVar("ph_shop_seeker_m4a1_sort", "6", "Sort order.");
	g_cvShopSeekerM4A1UnlockTime = CreateConVar("ph_shop_seeker_m4a1_unlock", "100", "Unlock time.");
	
	g_cvShopSeekerAWPPrice = CreateConVar("ph_shop_seeker_awp_price", "400", "Shop price to buy a healthshot as seeker.");
	g_cvShopSeekerAWPSort = CreateConVar("ph_shop_seeker_awp_sort", "5", "Sort order.");
	g_cvShopSeekerAWPUnlockTime = CreateConVar("ph_shop_seeker_awp_unlock", "115", "Unlock time.");

	// Points
	
	g_cvPointsSeekerKill = CreateConVar("ph_points_seeker_kill", "20", "Amount of points to give a seeker for killing a hider.");
	g_cvPointsSeekerSteal = CreateConVar("ph_shop_seeker_steal", "0.08", "Part of points a seeker can steal from a hider he killed.");

	// HUD
	g_cvHudHelpSeeker = CreateConVar("ph_hud_help_seeker", "1", "Show help info to seekers.");
	g_cvHudHelpHider = CreateConVar("ph_hud_help_hider", "1", "Show help info to hider.");
	g_cvHudCountdownHide = CreateConVar("ph_hud_countdown", "1", "Show time left to hide.");
	g_cvHudHidersLeft = CreateConVar("ph_hud_hiders_left", "1", "Show hiders left to seekers.");
	g_cvHudPoints = CreateConVar("ph_hud_points", "1", "Show current shop points.");
	g_cvHudShopCd = CreateConVar("ph_hud_shop_cd", "1", "Show shop items unlock countdown.");
	
	// Other
	
	g_cvAlterHurt = CreateConVar("ph_alter_hurt_method", "0", "Use an alternate way to do damage to players, usually for fixing kill feedback");
	g_cvInfAmmo = CreateConVar("ph_inf_ammo", "0", "Enable infinite ammo for seekers (bullets only).");
	
	AutoExecConfig(true, "prophunt");
}
