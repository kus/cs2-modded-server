new Float:InfectedPoints[MAXPLAYERS + 1];
new Float:InfectedTeamPoints;
new Handle:InfectedTier2Level;
new Handle:InfectedTier3Level;
new Handle:InfectedTier4Level;
new Handle:WallOfFireLevel;
new Handle:SpawnAnywhereLevel;
new bool:BerserkerKill[MAXPLAYERS + 1];
new Handle:InfectedTier2Color[3];
new Handle:InfectedTier3Color[3];
new Handle:InfectedTier4Color[3];
new bool:ClassHunter[MAXPLAYERS + 1];
new bool:ClassSmoker[MAXPLAYERS + 1];
new bool:ClassBoomer[MAXPLAYERS + 1];
new bool:ClassJockey[MAXPLAYERS + 1];
new bool:ClassCharger[MAXPLAYERS + 1];
new bool:ClassSpitter[MAXPLAYERS + 1];
new bool:ClassTank[MAXPLAYERS + 1];
new bool:UpgradeHunter[MAXPLAYERS + 1];
new bool:UpgradeSmoker[MAXPLAYERS + 1];
new bool:UpgradeBoomer[MAXPLAYERS + 1];
new bool:UpgradeJockey[MAXPLAYERS + 1];
new bool:UpgradeCharger[MAXPLAYERS + 1];
new bool:UpgradeSpitter[MAXPLAYERS + 1];
new bool:InJump[MAXPLAYERS + 1];
new Float:BoomerActionPoints[MAXPLAYERS + 1];
new Handle:HealthPerLevel;
new Handle:TankHealthPerLevel;
new Handle:SpeedPerLevel;
new Handle:PhysicalHealthPerLevel;
new Handle:BoomerAwardPoints;
new Float:PlayerMovementSpeed[MAXPLAYERS + 1];
new Handle:TankCooldown;
new Float:TankCooldownTime;
new Handle:HurtAwardTankPoints;

new Float:HurtAward[MAXPLAYERS + 1];
new Float:HunterHurtAward[MAXPLAYERS + 1];
new Float:SmokerHurtAward[MAXPLAYERS + 1];
new Float:BoomerHurtAward[MAXPLAYERS + 1];
new Float:JockeyHurtAward[MAXPLAYERS + 1];
new Float:ChargerHurtAward[MAXPLAYERS + 1];
new Float:SpitterHurtAward[MAXPLAYERS + 1];
new Float:TankHurtAward[MAXPLAYERS + 1];
new Handle:SmokerBurnDamage;

new Handle:StickySpitTime;
new Handle:StickySpitImmuneTime;
new Handle:StickySpitSpeed;
new bool:SpitterImmune[MAXPLAYERS + 1];

new Handle:HunterStartXP;
new Handle:SmokerStartXP;
new Handle:BoomerStartXP;
new Handle:JockeyStartXP;
new Handle:ChargerStartXP;
new Handle:SpitterStartXP;
new Handle:TankStartXP;
new Handle:InfectedStartXP;
new Handle:TankDefaultHealth;

new Handle:BileHitXP;
new Handle:BoomerPointsTime;
new Handle:BoomerBilePoints;
new Handle:BoomerBlowPoints;
new WhoWasBoomer[MAXPLAYERS + 1];
new Handle:SurvivorCount;
new Handle:LevelDifferencePoints;
new Handle:HurtAwardInfectedXP;
new Handle:HurtAwardInfectedPoints;
new Handle:SaveSurvivorPoints;
new Handle:HunterDistanceMultiplier;
new Hunter[MAXPLAYERS + 1];
new bool:Ensnared[MAXPLAYERS + 1];
new Float:StartPounceLocation[MAXPLAYERS + 1][3];

new bool:JockeyJumping[MAXPLAYERS + 1];
new Float:StartingJockeyLocation[MAXPLAYERS + 1][3];
new Handle:JockeyDistanceMultiplier;
new JockeyRideBonus[MAXPLAYERS + 1];
new bool:IsSmoking[MAXPLAYERS + 1];
new Float:StartSmokeLocation[MAXPLAYERS + 1][3];
new Handle:SurvivorEnsnareValue;
new Handle:SmokeDistanceMultiplier;

new Float:StartChargeLocation[MAXPLAYERS + 1][3];
new Handle:ChargeDistanceMultiplier;
new Handle:SurvivorImpactPoints;
new Handle:ImpactBlindTime;

new PurchaseItem[MAXPLAYERS + 1];
new String:ItemName[MAXPLAYERS + 1][128];
new ClassType[MAXPLAYERS + 1];
new bool:InfectedTeamPurchase[MAXPLAYERS + 1];

new Float:ItemCost[MAXPLAYERS + 1];
new Float:SpecialPurchaseValue[MAXPLAYERS + 1];
new Float:TankPurchaseValue[MAXPLAYERS + 1];
new Float:UncommonPurchaseValue[MAXPLAYERS + 1];
new Float:TeamUpgradesPurchaseValue[MAXPLAYERS + 1];
new Float:UncommonPanicEventCount;
new Handle:UncommonPanicEventTimer;
new Handle:PanicAmount;

new Handle:IncrementSpecialCost;
new Handle:IncrementTankCost;
new Handle:IncrementUncommonCost;
new Handle:IncrementTeamUpgradesCost;

new Handle:SpecialPurchaseStart;
new Handle:TankPurchaseStart;
new Handle:UncommonPurchaseStart;
new Handle:TeamUpgradesPurchaseStart;
new Handle:PersonalUpgradesPurchaseStart;

new Handle:TankLimitStart;
new Handle:TankLimitIncrement;
new Handle:TankLimitMax;

new TankCount;
new TankLimit;

new Handle:UncommonDropAmount;
new Handle:UncommonQueueAmount;
new String:LastUncommon[64];
new UncommonType;
new UncommonRemaining;

new bool:SteelTongue;
new DeepFreezeAmount;
new Handle:SpawnTimerStart;
new SpawnTimer;
new bool:CommonHeadshots;
new Handle:CommonLimitIncrease;
new bool:MoreCommons;
new Handle:DeepFreezeIncrement;
new Handle:CommonLimitNormal;
new Handle:SpawnTimerSubtract;
new Handle:SpawnTimerMin;
new Handle:DeepFreezeMax;

new Handle:DeepFreezeSlowDown;
new Handle:DeepFreezeTime;
new bool:SurvivorRealism;

new Handle:HunterDamageNerf;
new Handle:SmokerDamageNerf;
new Handle:BoomerDamageNerf;
new Handle:JockeyDamageNerf;
new Handle:ChargerDamageNerf;
new Handle:SpitterDamageNerf;
new JockeyRideTime[MAXPLAYERS + 1];

new PersonalUpgrades[MAXPLAYERS + 1];
new bool:SuperUpgradeHunter[MAXPLAYERS + 1];
new bool:SuperUpgradeSmoker[MAXPLAYERS + 1];
new bool:SuperUpgradeBoomer[MAXPLAYERS + 1];
new bool:SuperUpgradeJockey[MAXPLAYERS + 1];
new bool:SuperUpgradeCharger[MAXPLAYERS + 1];
new bool:SuperUpgradeSpitter[MAXPLAYERS + 1];

new bool:SpawnAnywhere[MAXPLAYERS + 1];
new bool:WallOfFire[MAXPLAYERS + 1];

new Handle:BlackWhiteColor[3];
new bool:IsBlackWhite[MAXPLAYERS + 1];
new SmokeVictim[MAXPLAYERS + 1];
new bool:SmokerWhipCooldown[MAXPLAYERS + 1];

new Handle:SmokerWhipForceMin;
new Handle:SmokerWhipForceMax;
new Handle:SmokerWhipMin1;
new Handle:SmokerWhipMin2;
new Handle:SmokerWhipMax1;
new Handle:SmokerWhipMax2;
new Handle:SmokerWhipPullMin1;
new Handle:SmokerWhipPullMin2;
new Handle:SmokerWhipPullMax1;
new Handle:SmokerWhipPullMax2;

new Float:PersonalUpgradesPurchaseValue[MAXPLAYERS + 1];
new Handle:ChargerSpeedIncrease;
new Handle:SpitterDamageIncrease;

new bool:IsRiding[MAXPLAYERS + 1];

new Handle:JockeyRideJumpForce;
new bool:JockeyJumpCooldown[MAXPLAYERS + 1];
new JockeyVictim[MAXPLAYERS + 1];

new Handle:IncrementPersonalUpgradesCost;

new Handle:InfectedTeamPointsMP;

new bool:UncommonCooldown;
new Handle:UncommonCooldownTime;
new Float:UncommonCooldownCount;

new MapBestDamage[2];
new MapBestInfectedDamage;
new String:MapBestInfectedDamageName[256];
new Handle:MapDamageXPEach;
new RoundDamage[MAXPLAYERS + 1];

new Handle:DeepFreezeDisableTime;
new bool:DeepFreezeCooldown;

new Handle:SpitterInvisTime;

new Handle:BerserkRideTime;

new BrokenLegs[MAXPLAYERS + 1];
new Handle:BrokenLegsSpeed;

new Handle:VipAward;
new VipName;
new VipExperience;
new Handle:VipColor[3];
new Handle:VipMinimumLevel;

new Handle:FireTankDamage;
new Handle:FireTankMinimumHealth;
new Handle:FireTankTime;
new Handle:FireTankHealthEnd;
new bool:FireTankImmune[MAXPLAYERS + 1];
new Float:FireTankCount[MAXPLAYERS + 1];

new bool:InfectedGhost[MAXPLAYERS + 1];
new JockeyRidingMe[MAXPLAYERS + 1];