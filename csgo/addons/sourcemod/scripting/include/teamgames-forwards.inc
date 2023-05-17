#if defined _teamgames_forwards_included_
  #endinput
#endif
#define _teamgames_forwards_included_

/**
 * Called when player is about to be moved to TeamGames team.
 *
 * @param client		Client index of switched player.
 * @param activator		Client index of activator (see TG_SetPlayerTeam).
 * @param teamBefore	Team before.
 * @param teamAfter		Team after.
 * @return				Plugin_Handled to prevent player changing team.
 */
forward Action:TG_OnPlayerTeam(client, activator, TG_Team:teamBefore, TG_Team:teamAfter);

/**
 * Called right after player was moved to TeamGames team.
 *
 * @param client		Client index of switched player.
 * @param activator		Client index of activator (see TG_SetPlayerTeam).
 * @param teamBefore	Team before.
 * @param teamAfter		Team after.
 * @noreturn
 */
forward TG_OnPlayerTeamPost(client, activator, TG_Team:teamBefore, TG_Team:teamAfter);

/**
 * Called when player is about to become a rebel.
 *
 * @param client		Client index.
 * @param team			Player team.
 * @return				Plugin_Handled to prevent player becoming a rebel.
 */
forward Action:TG_OnPlayerRebel(client, TG_Team:team);

/**
 * Called right after player became a rebel.
 *
 * @param client		Client index.
 * @param team			Player team.
 * @noreturn
 */
forward TG_OnPlayerRebelPost(client, TG_Team:team);

/**
 * Called when player is crossing the laser fence.
 *
 * @param client		Client index.
 * @param punishTime	Punishment length.
 * @return 				Plugin_Handled to block punishment and TG_OnLaserFenceCrossed.
 */
forward Action:TG_OnLaserFenceCross(client, Float:punishTime);

/**
 * Called right after player crossed the laser fence.
 *
 * @param client		Client index.
 * @param punishTime	Punishment length.
 * @noreturn
 */
forward TG_OnLaserFenceCrossed(client, Float:punishTime);

/**
 * Called when fence is about to be created.
 *
 * @param client		Client index.
 * @param a		Coordinates of point a.
 * @param c		Coordinates of point c.
 * @return		Plugin_Handled to block laser fence creation.
 */
forward Action:TG_OnLaserFenceCreate(client, Float:a[3], Float:c[3]);

/**
 * Called right after the laser fence was created.
 *
 * @param client		Client index.
 * @param a		Coordinates of point a.
 * @param c		Coordinates of point c.
 * @noreturn
 */
forward TG_OnLaserFenceCreated(client, Float:a[3], Float:c[3]);

/**
 * Called right before the laser fence is destroyed.
 *
 * @param a		Coordinates of point a.
 * @param c		Coordinates of point c.
 * @noreturn
 */
forward TG_OnLaserFenceDestroyed(Float:a[3], Float:c[3]);

/**
 * Called when mark is about to spawn.
 *
 * @param client 		Client index.
 * @param team 			Player team.
 * @param position 		Mark position.
 * @param life 			Mark life.
 * @return 				Plugin_Handled to block mark creation.
 */
forward Action:TG_OnMarkSpawn(client, TG_Team:team, Float:position[3], Float:life);

/**
 * Called right after the mark was spawned.
 *
 * @param client 		Client index.
 * @param team 			Player team.
 * @param position 		Mark position.
 * @param life 			Mark life.
 * @param mark 			Mark handle.
 * @param markent 		Mark entity (env_sprite) or INVALID_ENT_REFERENCE if entity wasn't created.
 * @noreturn
 */
forward TG_OnMarkSpawned(client, TG_Team:team, Float:position[3], Float:life, Handle:mark, markent);

/**
 * Called right after the mark was destroyed.
 *
 * @param client 		Client index.
 * @param team 			Player team.
 * @param position 		Mark position.
 * @param life 			Mark life.
 * @param mark 			Mark handle.
 * @param markent 		Mark entity (env_sprite) or INVALID_ENT_REFERENCE if entity wasn't created.
 * @noreturn
 */
forward TG_OnMarkDestroyed(client, TG_Team:team, Float:position[3], Float:life, Handle:mark, markent);

/**
 * Called before game start menu is opened.
 *
 * @param id			Game ID.
 * @param gameType		Game type.
 * @param client		Client index of game starter.
 * @param gameSettings	Game settings.
 * @param dataPack		Game datapack.
 * @return 				Plugin_Handled to block start menu from opening.
 */
forward Action:TG_OnGameStartMenu(const String:id[], TG_GameType:gameType, client, const String:gameSettings[], Handle:dataPack);

/**
 * Called right before game preparation starts.
 *
 * @param id			Game ID.
 * @param gameType		Game type.
 * @param client		Client index of game starter.
 * @param gameSettings	Game settings.
 * @param dataPack		Game datapack.
 * @return 				Plugin_Handled to block game preparation from starting (and so game).
 */
forward Action:TG_OnGamePreparePre(const String:id[], TG_GameType:gameType, client, const String:gameSettings[], Handle:dataPack);

/**
 * Called when game preparation started.
 *
 * @param id			Game ID.
 * @param gameType		Game type.
 * @param client		Client index of game starter.
 * @param gameSettings	Game settings.
 * @param dataPack		Game datapack.
 * @noreturn
 */
forward TG_OnGamePrepare(const String:id[], TG_GameType:gameType, client, const String:gameSettings[], Handle:dataPack);

/**
 * Called when game started.
 *
 * @param id			Game ID.
 * @param gameType		Game type.
 * @param client		Client index of game starter.
 * @param gameSettings	Game settings.
 * @param dataPack		Game datapack.
 * @noreturn
 */
forward TG_OnGameStart(const String:id[], TG_GameType:gameType, client, const String:gameSettings[], Handle:dataPack);

/**
 * Called when some error happened in TG_StartGame().
 *
 * @param id				Game ID.
 * @param gameType			Game type.
 * @param client			Client index of game starter.
 * @param errorID			Game start error id.
 * @param errorDescription	Game start error description.
 * @noreturn
 */
forward TG_OnGameStartError(const String:id[], TG_GameType:gameType, client, errorID, const String:errorDescription[]);

forward Action:TG_OnTraceAttack(bool:inTeamGame, victim, &attacker, &inflictor, &Float:damage, &damageType, &ammoType, hitBox, hitGroup);
forward Action:TG_OnPlayerDamage(bool:inTeamGame, victim, &attacker, &inflictor, &Float:damage, &damageType);

/**
 * Called when player (from RedTeam or BlueTeam) dies.
 *
 * @param attacker		Client index of attacker.
 * @param attackerTeam	Attacker's TG team.
 * @param victim		Client index of victim.
 * @param victimTeam	Victim's TG team.
 * @param headshot		Was it headshot?
 * @param weapon		Killer's weapon.
 * @param gameStatus	Game status.
 * @param gameID		Game ID.
 * @param gameType		Game type.
 * @noreturn
 */
forward TG_OnPlayerDeath(attacker, TG_Team:attackerTeam, victim, TG_Team:victimTeam, bool:headshot, const String:weapon[], TG_GameProgress:gameStatus, const String:gameID[], TG_GameType:gameType);

/**
 * Called on TG_StopGame() (or one TG team is empty - depending of settings).
 *
 * @param id			Game ID.
 * @param gameType		Game type.
 * @param team			Winner team.
 * @param winners		Array of winners (all alive players in winner team by default).
 * @param winnersCount	Number of winners.
 * @param dataPack		Game datapack.
 * @noreturn
 */
forward TG_OnGameEnd(const String:id[], TG_GameType:gameType, TG_Team:team, winners[], winnersCount, Handle:dataPack);

/**
 * Called when one TG team was emptied.
 *
 * @param id			Game ID ("Core_NoGame" if there is no game running).
 * @param gameType		Game type.
 * @param client		Client index.
 * @param team			Player's TG team.
 * @param trigger		How was the team emptied.
 * @noreturn
 */
forward TG_OnTeamEmpty(const String:id[], TG_GameType:gameType, client, TG_Team:team, TG_PlayerTrigger:trigger);

/**
 * Called when player leave TG game.
 *
 * @param id			Game ID.
 * @param gameType		Game type.
 * @param client		Client index.
 * @param team			Player's TG team.
 * @param trigger		Why player left the game.
 * @noreturn
 */
forward TG_OnPlayerLeaveGame(const String:id[], TG_GameType:gameType, client, TG_Team:team, TG_PlayerTrigger:trigger);

/**
 * Called when player is about to stop (interrupt) a game.
 *
 * @param client		Client index.
 * @param id			Game ID.
 * @return 				Plugin_Handled to prevent player from stopping a game.
 */
forward Action:TG_OnPlayerStopGame(client, const String:id[]);

/**
 * Called when player is stopping (interrupting) a game (the game is not stopped yet).
 *
 * @param client		Client index.
 * @param id			Game ID.
 * @noreturn
 */
forward TG_OnPlayerStopGamePost(client, const String:id[]);

/**
 * Called right before the TeamGames menu is displayed.
 *
 * @param client		Client index.
 * @return				Plugin_Handled to block menu from displaying.
 */
forward Action:TG_OnMenuDisplay(client);

/**
 * Called after the TeamGames menu was displayed.
 *
 * @param client		Client index.
 * @noreturn
 */
forward TG_OnMenuDisplayed(client);

/**
 * Called right before player selects an item in TeamGames menu.
 *
 * Might be: core item, module item or game!
 *
 * @param type 			Module type.
 * @param id			Module ID.
 * @param gameType		Game type used when selecting a game
 * @param client		Client index.
 * @return 				Plugin_Handled to block item from selecting.
 */
forward Action:TG_OnMenuSelect(TG_ModuleType:type, const String:id[], TG_GameType:gameType, client);

/**
 * Called after player selected an item in TeamGames menu.
 *
 * Might be: core item, module item or game!
 *
 * @param type 			Module type.
 * @param id			Module ID.
 * @param gameType		Game type used when selecting a game
 * @param client		Client index.
 * @noreturn
 */
forward TG_OnMenuSelected(TG_ModuleType:type, const String:id[], TG_GameType:gameType, client);

/**
 * Core asks module for name.
 *
 * @param type 			Module type
 * @param id			Module ID
 * @param client		Client index (target for translation)
 * @param name			Buffer for module name
 * @param nameSize		Max size of the buffer
 * @param status		Menu item status
 * @noreturn.
 */
forward TG_AskModuleName(TG_ModuleType:type, const String:id[], client, String:name[], nameSize, &TG_MenuItemStatus:status);

/**
 * Called right before core starts parsing the TeamGames downloads config.
 */
forward TG_OnDownloadsStart();

/**
 * Called when core finds a prefixed file in TeamGames downloads config.
 *
 * Note: If it's called for your prefixed file, set arg. known as true! Otherwise, core will log error.
 *
 * @param file 			File path.
 * @param prefixName	File prefix.
 * @param args			Prefix arguments (Use DTC).
 * @param known			Is the prefix known or not.
 * @noreturn
 */
forward TG_OnDownloadFile(String:file[], String:prefixName[], Handle:args, &bool:known);

/**
 * Called right after core ended parsing the TeamGames downloads config.
 */
forward TG_OnDownloadsEnd();
