new PlayerState[MAXPLAYERS + 1];
new PlayerOnGrenade;

new CTcount;
new Tcount;

/* Checks to make sure clients only gain level by objective during Round Started and not during Round End*/
new bool:RoundStarted;

/* Changes the default MinKillsPerWeapon setting if value is greater than 0. */
new CustomKillPerLevel[GUNGAME_MAX_LEVEL];

new PlayerLevel[MAXPLAYERS + 1];
new CurrentKillsPerWeap[MAXPLAYERS + 1];
new CurrentLevelPerRound[MAXPLAYERS + 1];
new CurrentLevelPerRoundTriple[MAXPLAYERS + 1];
new CurrentLeader;
new GameWinner;
new bool:g_teamChange[MAXPLAYERS + 1];
new g_NumberOfNades[MAXPLAYERS + 1];
new bool:g_BlockSwitch[MAXPLAYERS + 1];
