#if defined _pugsetup_included
#endinput
#endif
#define _pugsetup_included

// Different ways teams can be selected.
enum TeamType {
  TeamType_Manual,
  TeamType_Random,
  TeamType_Captains,
  TeamType_Autobalanced,  // only allowed if PugSetup_IsTeamBalancerAvaliable() is true
};

// Different ways the map can be selected.
enum MapType {
  MapType_Current,
  MapType_Vote,
  MapType_Veto,
};

// Permission checking values.
enum Permission {
  Permission_All,       // anyone can use the command
  Permission_Captains,  // only captains (and higher) can use the command (note: reverts to
                        // Permission_All when not using captains)
  Permission_Leader,    // only the pug leader (and higher) can use the command
  Permission_Admin,     // only pug admins can use the command
  Permission_None,      // this command is disabled
};

// Pug game state
enum GameState {
  GameState_None,                          // no setup has taken place
  GameState_Warmup,                        // setup done, waiting for players to ready up
  GameState_PickingPlayers,                // only used if TeamType_Captains is the teamtype
  GameState_WaitingForStart,               // waiting for a .start if autolive is disabled
  GameState_Countdown,                     // doing the countdown timer
  GameState_KnifeRound,                    // in the knife round
  GameState_WaitingForKnifeRoundDecision,  // waiting for a .stay/.swap command after the knife
                                           // round
  GameState_GoingLive,                     // in the lo3 process
  GameState_Live,                          // the match is live
};

enum ChatAliasMode {
  ChatAlias_Always,     // Alias is always enabled
  ChatAlias_WhenSetup,  // Alias is only available when game state is not GameState_None
};

/**
 * Called when a setup menu is opened.
 *
 * @param client Client that did the setup menu (e.g. the leader).
 * @param menu The menu being given to the client.
 * @return Whether to display the menu to the client or not.
 */
forward Action PugSetup_OnSetupMenuOpen(int client, Menu menu, bool displayOnly);

/**
 * Called when a setup menu option is selected.
 * You should call PugSetup_GiveSetupMenu to the calling client at the end of this function.
 */
forward void PugSetup_OnSetupMenuSelect(Menu menu, int client, const char[] selected_info,
                                        int selected_position);

/**
 * Called when a setup is completed.
 */
forward void PugSetup_OnSetup();

/**
 * Called when a client force-ends the match.
 *
 * @param client Client that force-ended the match.
 */
forward void PugSetup_OnForceEnd(int client);

/**
 * Called when a player marks themselves as ready.
 */
forward void PugSetup_OnReady(int client);

/**
 * Called when a player marks themselves as not ready.
 */
forward void PugSetup_OnUnready(int client);

/**
 * Called when the match is ready to begin, for example
 * when all players are ready and the captains are now picking players.
 */
forward void PugSetup_OnReadyToStart();

/**
 * Called when a team won the knife round and made their decision.
 */
forward void PugSetup_OnKnifeRoundDecision(bool swapping);

/**
 * Called when the going-live process begins, before the lo3.
 */
forward void PugSetup_OnGoingLive();

/**
 * Called after the last restart when the game is completely live.
 */
forward void PugSetup_OnLive();

/**
 * Called after the warmup config is executed.
 */
forward void PugSetup_OnWarmupCfgExecuted();

/**
 * Called after the live config is executed.
 */
forward void PugSetup_OnLiveCfgExecuted();

/**
 * Called after the postgame config is executed.
 */
forward void PugSetup_OnPostGameCfgExecuted();

/**
 * Called when the match is over.
 * If you plan on using the result of the demo file,
 * I'd suggest adding a slight delay from when this is called
 * to accomodate the time spent flushing the demo to disk.
 *
 * @param hasDemo whether a demo was being recorded
 * @param demoFileName the filename of the demo (including the .dem extension)
 */
forward void PugSetup_OnMatchOver(bool hasDemo, const char[] demoFileName);

/**
 * Called when a client is not picked in a captain-selection game.
 */
forward void PugSetup_OnNotPicked(int client);

/**
 * Called every timer-check for whether the pug is ready to start or not.
 */
forward void PugSetup_OnReadyToStartCheck(int readyPlayers, int totalPlayers);

/**
 * Called when user permissions are being checked. You can change
 * the value of "allow" to change the result of the check and allow
 * or disallow an action.
 *
 * @param client Client that initiated the command
 * @param command The command that was issued
 * @param p Default permissions the plugin checked against
 * @param allow Result of the check
 * @note permissions-checking is only relevent for pugsetup commands.
 */
forward void PugSetup_OnPermissionCheck(int client, const char[] command, Permission p,
                                        bool& allow);

/**
 * Called when a tv_record command is about to be sent.
 *
 * @param demoName The name given when the tv_record command was used (no .dem file extension)
 */
forward void PugSetup_OnStartRecording(char[] demoName);

/**
 * Called before a player gets added to a captain selection menu.
 *
 * @param menu The Menu players are being added to
 * @param client The client being added to the menu
 * @param menuString The menu display string being added for the client
 * @param length Length of the menuString
 */
forward void PugSetup_OnPlayerAddedToCaptainMenu(Menu menu, int client, char[] menuString,
                                                 int length);

/**
 * Called when a client issues a .help command in chat.
 *
 * @param client The client issuing the command
 * @param replyMessages An ArrayList of Strings to reply with (in chat)
 * @param maxMessageSize The max length of a string in the replyMessages list
 * @param block Whether to block the reply message (set to true to have no reply)
 */
forward void PugSetup_OnHelpCommand(int client, ArrayList replyMessages, int maxMessageSize,
                                    bool& block);

/**
 * Called during any game state change.
 */
forward void PugSetup_OnGameStateChanged(GameState before, GameState after);

typedef TeamBalancerFunction = function void(ArrayList players);

/**
 * Returns if a team balancer function has been set for pugsetup to use, if selected in the setup
 * menu.
 */
native bool PugSetup_IsTeamBalancerAvaliable();

/**
 * Sets a team balancer function, returning if the balancer function was set.
 */
native bool PugSetup_SetTeamBalancer(TeamBalancerFunction balancerFunction, bool override = false);

/**
 * Clears any team balancer function set, returning if there was one before clearing.
 */
native bool PugSetup_ClearTeamBalancer();

// Sets a game up with the given settings.
native void PugSetup_SetupGame(TeamType teamType, MapType mapType = MapType_Vote,
                               int playersPerTeam = 5, bool recordDemo = false,
                               bool knifeRound = false, bool autoLive = true);

// Sets the current game options. These can still be overwritten by a user with access to the .setup
// menu.
native void PugSetup_SetSetupOptions(TeamType teamType, MapType mapType, int playersPerTeam = 5,
                                     bool recordDemo = false, bool knifeRound = false,
                                     bool autoLive = true);

// Fetches the current game options.
// @error If there is no game setup yet.
native void PugSetup_GetSetupOptions(TeamType& teamType, MapType& mapType, int& playersPerTeam,
                                     bool& recordDemo, bool& knifeRound, bool& autoLive);

// Readies up a player, optionally printing chat messages
// to the client about readying up.
// Returns if they were successfully readied.
native bool PugSetup_ReadyPlayer(int client, bool chatReply = true);

// Unreadies a player.
// Returns if they were successfully unreadied. (returns false if the client was already not-ready)
native bool PugSetup_UnreadyPlayer(int client);

// Returns whether a client is ready.
// This is only valid when the game is setup AND not live.
native bool PugSetup_IsReady(int client);

// Returns if the game settings have been setup.
native bool PugSetup_IsSetup();

// Returns the team type being used.
// Only valid if PugSetup_IsSetup is true.
native TeamType PugSetup_GetTeamType();

// Returns the map type being used.
// Only valid if PugSetup_IsSetup is true.
native MapType PugSetup_GetMapType();

// Returns the current pug gamestate.
native GameState PugSetup_GetGameState();

// Returns if there is currently a match setup.
native bool PugSetup_IsMatchLive();

// Returns if the match is pending start. (e.g. during the lo3)
native bool PugSetup_IsPendingStart();

// Sets the pug leader.
native void PugSetup_SetLeader(int client);

// Returns the pug leader, or -1 if not set.
native int PugSetup_GetLeader(bool allowLeaderReassignment = true);

// Sets who is a captain.
// A captain number is either 1 or 2.
native void PugSetup_SetCaptain(int captainNumber, int client, bool printIfSame = false);

// Returns captain 1, or -1 if not set.
// A captain number is either 1 or 2.
native int PugSetup_GetCaptain(int captainNumber);

// Prints a plugin-formatted message to a client.
native void PugSetup_Message(int client, const char[] format, any:...);

// Prints a plugin-formatted message to all clients.
native void PugSetup_MessageToAll(const char[] format, any:...);

// Returns the maximum number of players in the pug.
// Only valid if the game has already been setup.
native int PugSetup_GetPugMaxPlayers();

// Returns if a client was present when the game started.
// This doesn't include if the player disconnected and reconnected.
native bool PugSetup_PlayerAtStart(int client);

// Returns if the plugin has identified a player as having elevated permissions.
native bool PugSetup_IsPugAdmin(int client);

// Returns if a client satisfies a permission check.
native bool PugSetup_HasPermissions(int client, Permission p, bool allowLeaderReassignment = true);

// Sets random captains.
native void PugSetup_SetRandomCaptains();

// Adds a chat alias for a command. For example: .setup as a chat trigger for sm_setup
native void PugSetup_AddChatAlias(const char[] alias, const char[] command,
                                  ChatAliasMode mode = ChatAlias_Always);

// Give a client the root setup menu again.
// This is intended to be called in the PugSetup_OnSetupMenuSelect forward.
native void PugSetup_GiveSetupMenu(int client, bool displayOnly = false, int menuPosition = -1);

// Displays the map change menu to a client (bypasses access checks).
native void PugSetup_GiveMapChangeMenu(int client);

// Returns if a console command is a valid pugsetup command.
native bool PugSetup_IsValidCommand(const char[] command);

// Gets the permissions for a command, or throws an error on invalid command.
// Note: permissions-checking is only relevent for pugsetup commands.
native Permission PugSetup_GetPermissions(const char[] command);

// Sets the permissions for a command, returning whether the command already had permissions set.
// Note: permissions-checking is only relevent for pugsetup commands.
native bool PugSetup_SetPermissions(const char[] command, Permission p);

public SharedPlugin __pl_pugsetup = {
    name = "pugsetup", file = "pugsetup.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_pugsetup_SetNTVOptional() {
  MarkNativeAsOptional("PugSetup_SetupGame");
  MarkNativeAsOptional("PugSetup_GetSetupOptions");
  MarkNativeAsOptional("PugSetup_SetSetupOptions");
  MarkNativeAsOptional("PugSetup_ReadyPlayer");
  MarkNativeAsOptional("PugSetup_UnreadyPlayer");
  MarkNativeAsOptional("PugSetup_IsReady");
  MarkNativeAsOptional("PugSetup_IsSetup");
  MarkNativeAsOptional("PugSetup_GetTeamType");
  MarkNativeAsOptional("PugSetup_GetMapType");
  MarkNativeAsOptional("PugSetup_GetGameState");
  MarkNativeAsOptional("PugSetup_IsMatchLive");
  MarkNativeAsOptional("PugSetup_IsPendingStart");
  MarkNativeAsOptional("PugSetup_SetLeader");
  MarkNativeAsOptional("PugSetup_GetLeader");
  MarkNativeAsOptional("PugSetup_SetCaptain");
  MarkNativeAsOptional("PugSetup_GetCaptain");
  MarkNativeAsOptional("PugSetup_Message");
  MarkNativeAsOptional("PugSetup_MessageToAll");
  MarkNativeAsOptional("PugSetup_GetPugMaxPlayers");
  MarkNativeAsOptional("PugSetup_PlayerAtStart");
  MarkNativeAsOptional("PugSetup_IsPugAdmin");
  MarkNativeAsOptional("PugSetup_HasPermissions");
  MarkNativeAsOptional("PugSetup_SetRandomCaptains");
  MarkNativeAsOptional("PugSetup_AddChatAlias");
  MarkNativeAsOptional("PugSetup_GiveSetupMenu");
  MarkNativeAsOptional("PugSetup_GiveMapChangeMenu");
  MarkNativeAsOptional("PugSetup_IsValidCommand");
  MarkNativeAsOptional("PugSetup_GetPermissions");
  MarkNativeAsOptional("PugSetup_SetPermissions");
  MarkNativeAsOptional("PugSetup_SetTeamBalancer");
  MarkNativeAsOptional("PugSetup_IsTeamBalancerAvaliable");
  MarkNativeAsOptional("PugSetup_ClearTeamBalancer");
}
#endif
