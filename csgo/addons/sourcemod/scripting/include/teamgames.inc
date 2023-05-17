#if defined _teamgames_included_
  #endinput
#endif
#define _teamgames_included_

#include <menus>

public SharedPlugin:__pl_teamgames =
{
	name = "TeamGames",
	file = "TeamGames.smx",
	required = 1
};

public __pl_teamgames_SetNTVOptional()
{
	MarkNativeAsOptional("TG_GetPlayerTeam");
	MarkNativeAsOptional("TG_SetPlayerTeam");
	MarkNativeAsOptional("TG_IsGameTypeAvailable");
	MarkNativeAsOptional("TG_LoadPlayerWeapons");
	MarkNativeAsOptional("TG_FenceCreate");
	MarkNativeAsOptional("TG_FenceDestroy");
	MarkNativeAsOptional("TG_FencePlayerCross");
	MarkNativeAsOptional("TG_SpawnMark");
	MarkNativeAsOptional("TG_DestroyMark");
	MarkNativeAsOptional("TG_GetTeamCount");
	MarkNativeAsOptional("TG_ClearTeam");
	MarkNativeAsOptional("TG_SetTeamsLock");
	MarkNativeAsOptional("TG_GetTeamsLock");
	MarkNativeAsOptional("TG_RegGame");
	MarkNativeAsOptional("TG_IsModuleReged");
	MarkNativeAsOptional("TG_GetRegedModules");
	MarkNativeAsOptional("TG_RemoveGame");
	MarkNativeAsOptional("TG_FakeSelect");
	MarkNativeAsOptional("TG_RegMenuItem");
	MarkNativeAsOptional("TG_RemoveMenuItem");
	MarkNativeAsOptional("TG_GetModuleName");
	MarkNativeAsOptional("TG_StartGame");
	MarkNativeAsOptional("TG_GetCurrentGameID");
	MarkNativeAsOptional("TG_IsCurrentGameID");
	MarkNativeAsOptional("TG_GetCurrentDataPack");
	MarkNativeAsOptional("TG_GetCurrentStarter");
	MarkNativeAsOptional("TG_GetCurrentGameSettings");
	MarkNativeAsOptional("TG_GetCurrentGameType");
	MarkNativeAsOptional("TG_GetGameType");
	MarkNativeAsOptional("TG_StopGame");
	MarkNativeAsOptional("TG_SetModuleVisibility");
	MarkNativeAsOptional("TG_GetModuleVisibility");
	MarkNativeAsOptional("TG_GetGameStatus");
	MarkNativeAsOptional("TG_IsGameStatus");
	MarkNativeAsOptional("TG_LogMessage");
	MarkNativeAsOptional("TG_LogRoundMessage");
	MarkNativeAsOptional("TG_LogGameMessage");
	MarkNativeAsOptional("TG_ShowPlayerSelectMenu");
}

//------------------------------------------------------------------------------------------------
// Defines
#define TG_MODULE_ID_LENGTH 	64 // Max module ID length
#define TG_MODULE_NAME_LENGTH 	64 // Max module name length
#define TG_GAME_SETTINGS_LENGTH 64 // Max game settings length

//------------------------------------------------------------------------------------------------
// Enums

/**
 * TeamGames teams
 */
enum TG_Team
{
	TG_ErrorTeam = -1, // CTs, dead Ts, etc...
	TG_NoneTeam, // Ts who are not in TeamGames team
	TG_RedTeam, // Ts who are in TeamGames Red team
	TG_BlueTeam // Ts who are in TeamGames Blue team
};

/**
 * TeamGames game status
 */
enum TG_GameProgress
{
	TG_NoGame = 0, // There is no game running or in preparation. TG_GetCurrentGameID and TG_GetGameName("CurrentGameId") returns "Core_NoGame"
	TG_InPreparation, // The game is in preparation
	TG_InProgress // The game is running
};

/**
 * TeamGames game type
 */
enum TG_GameType
{
	TG_None = 0,
	TG_TeamGame = (1 << 1), // TeamGame game type: RedTeam vs. BlueTeam
	TG_RedOnly = (1 << 2) // RedOnly game type: only red players are allowed
};

/**
 * TeamGames module type
 */
enum TG_ModuleType
{
	TG_Game = 0, // Game module
	TG_MenuItem // Menu item (appears in TeamGames main menu)
};

/**
 * TeamGames menu item status
 */
enum TG_MenuItemStatus
{
	TG_Active = 0, // Menu item is in menu and selecable
	TG_Inactive, // Menu item is in menu, but not selectable
	TG_Disabled // Menu item is not in menu
};

/**
 * TeamGames player triggers/reasons of leaving game or emptying team
 */
enum TG_PlayerTrigger
{
	TG_Death, // Player died
	TG_Rebel, // Player became a rebel
	TG_ChangeTGTeam, // Player changed TeamGames team
	TG_GameEnd, // TeamGames game ended
	TG_Disconnect, // Player disconnected
	TG_Other // Currently not used
};

//------------------------------------------------------------------------------------------------
// TeamGames includes
#include <teamgames-natives>
#include <teamgames-forwards>
#include <teamgames-stocks>
