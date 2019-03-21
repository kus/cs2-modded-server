/**
 * Top rank and player data will sync after map change.
 */

new bool:SaveProcess;

/* Player Data */
new PlayerWinsData[MAXPLAYERS + 1] = {0, ...};
new bool:IsActive;

new PlayerPlaceData[MAXPLAYERS + 1] = {0, ...};
new TotalWinners = 0;

new Handle:FwdLoadRank = INVALID_HANDLE;
new Handle:FwdLoadPlayerWins = INVALID_HANDLE;
new g_cfgHandicapTopWins = 0;

new bool:g_PlayerWinsLoaded[MAXPLAYERS + 1] = {false, ...};

