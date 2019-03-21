/**
 * Config Setting
 */

new State:ConfigState;
new bool:ConfigReset;

new MapStatus;
new MaxLevelPerRound = 0;
new MinKillsPerLevel = 1;
new bool:TurboMode;
new StripDeadPlayersWeapon;
new bool:AllowLevelUpAfterRoundEnd;
new bool:RemoveBonusWeaponAmmo;
new bool:ReloadWeapon;
new bool:MultiKillChat;
new bool:JoinMessage;
new VoteLevelLessWeaponCount;
new ObjectiveBonus;
new WorldspawnSuicide = 1;
new NadeBonusWeaponId;
new bool:NadeSmoke;
new bool:NadeFlash;
new g_Cfg_ExtraNade;
new bool:UnlimitedNades;
new bool:WarmupNades;
new bool:KnifePro;
new KnifeProMinLevel;
new bool:KnifeElite;
new bool:AutoFriendlyFire;
new bool:BotCanWin;
new bool:WarmupEnabled = true;
new bool:DisableWarmupOnRoundEnd = false;
new bool:WarmupInitialized;
new Warmup_TimeLength = 30;
new WarmupCounter;
new bool:IsVotingCalled = false;
new bool:g_isCalledEnableFriendlyFire = false;
new bool:g_isCalledDisableRtv = false;
new bool:TripleLevelBonus = false;
new bool:KnifeProHE = false;
new bool:ObjectiveBonusWin = false;
new bool:InternalIsActive = true;
new CommitSuicide = 1;
new bool:AlltalkOnWin = false;
new bool:RestoreLevelOnReconnect;
new bool:TripleLevelBonusGodMode;
new HandicapMode;
new bool:TopRankHandicap;
new bool:StatsEnabled;
new WarmupRandomWeaponMode = 0;
new WarmupRandomWeaponLevel = 0;
new UnlimitedNadesMinPlayers = 0;
new FFA = 0;
new NumberOfNades = 0;
new g_Cfg_LevelsInScoreboard = 0;
new g_Cfg_HandicapLevelSubstract = 0;
new g_Cfg_ArmorKevlar = 1;
new g_Cfg_ArmorHelmet = 1;
new Float:g_Cfg_TripleLevelBonusGravity = 0.5;
new Float:g_Cfg_TripleLevelBonusSpeed = 1.5;
new bool:g_Cfg_TripleLevelEffect = false;
new g_Cfg_KnifeSmoke = 0;
new g_Cfg_KnifeFlash = 0;
new g_Cfg_ObjectiveBonusExplode = 0;
new g_Cfg_ShowLeaderWeapon = 0;
new g_Cfg_ShowSpawnMsgInHintBox = 0;
new g_Cfg_ShowLeaderInHintBox = 0;
new g_Cfg_MaxHandicapLevel = 0;
new g_Cfg_ScoreboardClearDeaths = 0;
new g_Cfg_WarmupWeapon = 0;
new g_Cfg_RandomWeaponReservLevels[GUNGAME_MAX_LEVEL];
new Float:g_Cfg_HandicapUpdate;
new g_Cfg_KnifeProRecalcPoints = 0;
new bool:g_Cfg_HandicapSkipBots = false;
new g_Cfg_KnifeProMaxDiff = 0;
new g_Cfg_MultiLevelAmount = 3;
new g_Cfg_HandicapTimesPerMap = 0;
new g_cfgDisableRtvLevel = 0;
new g_cfgEnableFriendlyFireLevel = 0;
new bool:g_cfgFriendlyFireOnOff = true;
new bool:g_Cfg_BlockWeaponSwitchIfKnife = false;
new bool:g_Cfg_BlockWeaponSwitchOnNade = false;
new bool:g_Cfg_HandicapUseSpectators = false;
new bool:g_Cfg_CanLevelUpWithPhysics = false;
new bool:g_Cfg_CanLevelUpWithPhysicsG = false;
new bool:g_Cfg_CanLevelUpWithPhysicsK = false;
new bool:g_Cfg_CanLevelUpWithMapNades = false;
new bool:g_Cfg_CanLevelUpWithNadeOnKnife = false;
new bool:g_Cfg_DisableLevelDown = false;
new bool:g_Cfg_SelfKillProtection = false;
new String:g_CfgGameDesc[64] = "";
new g_Cfg_MultilevelEffectType = 2;

#if defined WITH_SDKHOOKS
new bool:g_SdkHooksEnabled = true;
#else
new bool:g_SdkHooksEnabled = false;
#endif

new Handle:g_Cvar_Turbo;
new Handle:g_Cvar_MultiLevelAmount;
new g_Cfg_MultiplySoundVolume = 0;
new g_Cfg_BonusWeaponAmmo = 0;
new g_Cfg_ExtraTaserOnKnifeKill = 0;

new g_Cfg_MolotovBonusFlash         = 0;
new g_Cfg_MolotovBonusSmoke         = 0;
new g_Cfg_MolotovBonusWeaponId      = 0;
new g_Cfg_ExtraMolotovOnKnifeKill   = 0;

new Float:g_Cfg_EndGameDelay        = 0.0;
new g_Cfg_WinnerFreezePlayers       = 0;
new g_Cfg_FastSwitchOnChangeWeapon  = 0;
new g_Cfg_FastSwitchOnLevelUp       = 0;
new g_Cfg_FastSwitchSkipWeapons[MAX_WEAPONS_COUNT];

new g_Cfg_EndGameSilent = 0;
