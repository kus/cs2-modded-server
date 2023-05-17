new bool:RescueCalled;
new laggedMovementOffset = -1;
new bool:BurnDamageImmune[MAXPLAYERS + 1];
new showinfo[MAXPLAYERS + 1];
new showpoints[MAXPLAYERS + 1];
new SkyPoints[MAXPLAYERS + 1];
new Float:SurvivorPoints[MAXPLAYERS + 1];
new Float:SurvivorTeamPoints;
new Handle:CategoryIncrement;
new Handle:PhysicalIncrement;
new Handle:PistolStartXP;
new Handle:MeleeStartXP;
new Handle:UziStartXP;
new Handle:ShotgunStartXP;
new Handle:SniperStartXP;
new Handle:RifleStartXP;
new Handle:GrenadeStartXP;
new Handle:ItemStartXP;
new Handle:PhysicalStartXP;
new Handle:HSXP;
new Handle:SIXP;
new IncapProtection[MAXPLAYERS + 1];
new Handle:IncapCount;

new GrenadeCount[MAXPLAYERS + 1];
new Handle:GrenadeSupply;
new HealCount[MAXPLAYERS + 1];
new TempHealCount[MAXPLAYERS + 1];
new Handle:HealSupply;
new Handle:TempHealSupply;

new Handle:HHP;
new Handle:HHPMULT;

new Float:SurvivorMultiplier[MAXPLAYERS + 1];
new Handle:HealPoints;
new Meds[MAXPLAYERS + 1];
new Difference[MAXPLAYERS + 1];

new Handle:MedsAmount;

new bool:CoveredInBile[MAXPLAYERS + 1];

new Handle:BlindAmmoTime;
new Handle:BlindAmmoCooldown;
new Handle:BlindAmount;
new BlindAmmo[MAXPLAYERS + 1];
new bool:BlindAmmoImmune[MAXPLAYERS + 1];

new Handle:BloatAmmoTime;
new Handle:BloatAmmoCooldown;
new Handle:BloatAmount;
new BloatAmmo[MAXPLAYERS + 1];
new bool:BloatAmmoImmune[MAXPLAYERS + 1];

new Handle:IceAmmoTime;
new Handle:IceAmmoCooldown;
new Handle:IceAmount;
new IceAmmo[MAXPLAYERS + 1];
new bool:IceAmmoImmune[MAXPLAYERS + 1];

new UserMsg:BlindMsgID;
new Handle:BlindAmmoAmount;
new Handle:BloatAmmoAmount;
new Handle:IceAmmoAmount;

new AssistHurtInfected[MAXPLAYERS + 1][MAXPLAYERS + 1];

new RoundKills[MAXPLAYERS + 1];
new RoundAward[MAXPLAYERS + 1];
new Handle:XPPerRoundDamageSurvivor;
new Handle:XPPerTankDamageSurvivor;

new bool:Scout[MAXPLAYERS + 1];

new Handle:SurvivorAssistPoints;
new Handle:SurvivorAssistMultiplier;
new Handle:SurvivorTankAssistPoints;
new bool:IncapDisabled[MAXPLAYERS + 1];
new Handle:IncapProtectionDisabled;

new TeamSpecialValue;
new TeamCommonValue;
new TeamSpecialGoal;
new TeamCommonGoal;
new Handle:SurvivorTeamSpecialStart;
new Handle:SurvivorTeamCommonStart;
new SurvivorHeadshotValue[MAXPLAYERS + 1];
new SurvivorSpecialValue[MAXPLAYERS + 1];
new SurvivorCommonValue[MAXPLAYERS + 1];
new SurvivorPistolValue[MAXPLAYERS + 1];
new SurvivorMeleeValue[MAXPLAYERS + 1];
new SurvivorSmgValue[MAXPLAYERS + 1];
new SurvivorShotgunValue[MAXPLAYERS + 1];
new SurvivorRifleValue[MAXPLAYERS + 1];
new SurvivorSniperValue[MAXPLAYERS + 1];
new SurvivorHeadshotGoal[MAXPLAYERS + 1];
new SurvivorSpecialGoal[MAXPLAYERS + 1];
new SurvivorCommonGoal[MAXPLAYERS + 1];
new SurvivorPistolGoal[MAXPLAYERS + 1];
new SurvivorMeleeGoal[MAXPLAYERS + 1];
new SurvivorSmgGoal[MAXPLAYERS + 1];
new SurvivorShotgunGoal[MAXPLAYERS + 1];
new SurvivorRifleGoal[MAXPLAYERS + 1];
new SurvivorSniperGoal[MAXPLAYERS + 1];

new Handle:SurvivorHeadshotStart;
new Handle:SurvivorSpecialStart;
new Handle:SurvivorCommonStart;
new Handle:SurvivorPistolStart;
new Handle:SurvivorMeleeStart;
new Handle:SurvivorSmgStart;
new Handle:SurvivorShotgunStart;
new Handle:SurvivorRifleStart;
new Handle:SurvivorSniperStart;

new Handle:SurvivorMaxMultiplier;
new Handle:SurvivorMultiplierIncrement;
new Handle:SurvivorMultiplierGoal;

new Handle:MultiplierGoalPoints;
new Handle:HealAmmoLevel;
new HealAmmo[MAXPLAYERS + 1];
new Handle:SpecialAmmoUnlock;
new Handle:HealAmmoAmount;

new bool:BloatAmmoPistol[MAXPLAYERS + 1];
new bool:BlindAmmoPistol[MAXPLAYERS + 1];
new bool:IceAmmoPistol[MAXPLAYERS + 1];
new bool:HealAmmoPistol[MAXPLAYERS + 1];
new BloatAmmoAmountPistol[MAXPLAYERS + 1];
new BlindAmmoAmountPistol[MAXPLAYERS + 1];
new IceAmmoAmountPistol[MAXPLAYERS + 1];
new HealAmmoAmountPistol[MAXPLAYERS + 1];

new bool:BloatAmmoSmg[MAXPLAYERS + 1];
new bool:BlindAmmoSmg[MAXPLAYERS + 1];
new bool:IceAmmoSmg[MAXPLAYERS + 1];
new bool:HealAmmoSmg[MAXPLAYERS + 1];
new BloatAmmoAmountSmg[MAXPLAYERS + 1];
new BlindAmmoAmountSmg[MAXPLAYERS + 1];
new IceAmmoAmountSmg[MAXPLAYERS + 1];
new HealAmmoAmountSmg[MAXPLAYERS + 1];

new bool:BloatAmmoShotgun[MAXPLAYERS + 1];
new bool:BlindAmmoShotgun[MAXPLAYERS + 1];
new bool:IceAmmoShotgun[MAXPLAYERS + 1];
new bool:HealAmmoShotgun[MAXPLAYERS + 1];
new BloatAmmoAmountShotgun[MAXPLAYERS + 1];
new BlindAmmoAmountShotgun[MAXPLAYERS + 1];
new IceAmmoAmountShotgun[MAXPLAYERS + 1];
new HealAmmoAmountShotgun[MAXPLAYERS + 1];

new bool:BloatAmmoRifle[MAXPLAYERS + 1];
new bool:BlindAmmoRifle[MAXPLAYERS + 1];
new bool:IceAmmoRifle[MAXPLAYERS + 1];
new bool:HealAmmoRifle[MAXPLAYERS + 1];
new BloatAmmoAmountRifle[MAXPLAYERS + 1];
new BlindAmmoAmountRifle[MAXPLAYERS + 1];
new IceAmmoAmountRifle[MAXPLAYERS + 1];
new HealAmmoAmountRifle[MAXPLAYERS + 1];

new bool:BloatAmmoSniper[MAXPLAYERS + 1];
new bool:BlindAmmoSniper[MAXPLAYERS + 1];
new bool:IceAmmoSniper[MAXPLAYERS + 1];
new bool:HealAmmoSniper[MAXPLAYERS + 1];
new BloatAmmoAmountSniper[MAXPLAYERS + 1];
new BlindAmmoAmountSniper[MAXPLAYERS + 1];
new IceAmmoAmountSniper[MAXPLAYERS + 1];
new HealAmmoAmountSniper[MAXPLAYERS + 1];


new String:LastWeaponOwned[MAXPLAYERS + 1][128];
new bool:SurvivorTeamPurchase[MAXPLAYERS + 1];
new Float:Tier2Cost[MAXPLAYERS + 1];
new Handle:Tier2IncrementCost;
new Handle:Tier2StartCost;

new Float:HealthItemCost[MAXPLAYERS + 1];
new Handle:HealthItemIncrementCost;
new Handle:HealthItemStartCost;

new Float:PersonalAbilitiesCost[MAXPLAYERS + 1];
new Handle:PersonalAbilitiesIncrementCost;
new Handle:PersonalAbilitiesStartCost;

new Float:WeaponUpgradeCost[MAXPLAYERS + 1];
new Handle:WeaponUpgradeIncrementCost;
new Handle:WeaponUpgradeStartCost;

new HazmatBoots[MAXPLAYERS + 1];
new EyeGoggles[MAXPLAYERS + 1];
new GravityBoots[MAXPLAYERS + 1];
new RespawnType[MAXPLAYERS + 1];				// 0 - none | 1 - start of map | 2 - corpse
new Handle:GravityBootsGravity;
new Handle:PersonalAbilityAmmo;
new Handle:PersonalAbilityLossMin;
new Handle:PersonalAbilityLossMax;

new BestKills[2];
new BestSurvivorDamage[2];
new BestSurvivorHS[2];
new BestHealing[2];
new BestRescuer[2];

new RoundSurvivorDamage[MAXPLAYERS + 1];
new RoundHS[MAXPLAYERS + 1];

new MapBestKills;
new String:MapBestKillsName[256];
new MapBestSurvivorDamage;
new String:MapBestSurvivorDamageName[256];
new MapBestSurvivorHS;
new String:MapBestSurvivorHSName[256];
new MapBestHealing;
new String:MapBestHealingName[256];
new MapBestRescuer;
new String:MapBestRescuerName[256];

new Handle:MapRescuerXPEach;
new RoundRescuer[MAXPLAYERS + 1];
new RoundHealing[MAXPLAYERS + 1];
new Handle:MapHealingXPEach;

new Handle:MapKillsXPEach;
new Handle:MapHSXPEach;

new Float:SurvivorDeathSpot[MAXPLAYERS + 1][3];
new Handle:SurvivorRespawnQueue;

new Handle:SurvivorTeamPointsMP;

new Handle:WeaponBonusDamage;

new Handle:CategoryMaxIncrement;
new Handle:PhysicalMaxIncrement;
new RangeCheck[MAXPLAYERS + 1];

new bool:LocationSaved[MAXPLAYERS + 1];
new Handle:MapSurvivorDamageXPEach;

new Handle:UnlockPresetLevel[3];
new PresetViewer[MAXPLAYERS + 1];

new Handle:BuyPistolXP;
new Handle:BuyPistolXPCost;
new Handle:BuyMeleeXP;
new Handle:BuyMeleeXPCost;
new Handle:BuyUziXP;
new Handle:BuyUziXPCost;
new Handle:BuyShotgunXP;
new Handle:BuyShotgunXPCost;
new Handle:BuySniperXP;
new Handle:BuySniperXPCost;
new Handle:BuyRifleXP;
new Handle:BuyRifleXPCost;
new Handle:BuyGrenadeXP;
new Handle:BuyGrenadeXPCost;
new Handle:BuyItemXP;
new Handle:BuyItemXPCost;
new Handle:BuyPhysicalXP;
new Handle:BuyPhysicalXPCost;
new Handle:BuyHunterXP;
new Handle:BuyHunterXPCost;
new Handle:BuySmokerXP;
new Handle:BuySmokerXPCost;
new Handle:BuyBoomerXP;
new Handle:BuyBoomerXPCost;
new Handle:BuyJockeyXP;
new Handle:BuyJockeyXPCost;
new Handle:BuyChargerXP;
new Handle:BuyChargerXPCost;
new Handle:BuySpitterXP;
new Handle:BuySpitterXPCost;
new Handle:BuyTankXP;
new Handle:BuyTankXPCost;
new Handle:BuyInfectedXP;
new Handle:BuyInfectedXPCost;

new Handle:BuyPresetCost;

new String:Nemesis[MAXPLAYERS + 1][64];
new String:NemesisName[MAXPLAYERS + 1][256];
new Handle:NemesisAward;

new bool:M60CD[MAXPLAYERS + 1];
new Float:M60COUNT[MAXPLAYERS + 1];
new Handle:M60CDTIME;
new LastToHurtMe[MAXPLAYERS + 1];

new bool:HeavyBySpit[MAXPLAYERS + 1];

new bool:OnDrugs[MAXPLAYERS + 1];
new Handle:DrugAddiction;
new Handle:DrugDealerLevel;
new DrugsUsed[MAXPLAYERS + 1];
new bool:DrugEffect[MAXPLAYERS + 1];
new Handle:DrugEffectTime;
new Float:DrugTimer[MAXPLAYERS + 1];
new Handle:DrugTimerStart;
new Handle:DrugBonusDamage;
new bool:JockeyRideBlind[MAXPLAYERS + 1];

new Handle:HealAmmoCooldown;
new bool:HealAmmoDisabled[MAXPLAYERS + 1];
new Float:HealAmmoCounter[MAXPLAYERS + 1];

new Handle:BuyXPMultiplier;
new Handle:BuyXPMultiplierAmount;
new Handle:BuyXPMultiplierCost;
new Handle:UnlockXPCap;
new Handle:UnlockXPIncrement;

new XPMultiplierTime[MAXPLAYERS + 1];
new bool:XPMultiplierTimer[MAXPLAYERS + 1];